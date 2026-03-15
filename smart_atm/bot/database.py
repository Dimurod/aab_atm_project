# bot/database.py
import asyncpg
import os
from typing import Optional, Dict, Any
from datetime import datetime
 
_pool: Optional[asyncpg.Pool] = None
 
 
async def get_pool() -> asyncpg.Pool:
    global _pool
    if _pool is None:
        _pool = await asyncpg.create_pool(
            os.getenv("DATABASE_URL"),
            min_size=2,
            max_size=10
        )
    return _pool
 
 
async def close_pool():
    global _pool
    if _pool:
        await _pool.close()
        _pool = None
 
 
# ──────────────────────────────────────────────────────────────────────
#  ATM
# ──────────────────────────────────────────────────────────────────────
 
async def get_atm(atm_id: str) -> Optional[dict]:
    pool = await get_pool()
    row = await pool.fetchrow(
        """
        SELECT a.*, b.name AS branch_name, b.address AS branch_address,
               b.phone AS branch_phone, b.working_hours AS branch_hours,
               b.latitude AS branch_lat, b.longitude AS branch_lon
        FROM atm_devices a
        LEFT JOIN branches b ON b.id = a.branch_id
        WHERE a.atm_id = $1
        """,
        atm_id
    )
    return dict(row) if row else None
 
 
async def get_nearest_branch(latitude: float, longitude: float) -> Optional[dict]:
    pool = await get_pool()
    row = await pool.fetchrow(
        """
        SELECT *,
            ( 6371 * acos(
                cos(radians($1)) * cos(radians(latitude)) *
                cos(radians(longitude) - radians($2)) +
                sin(radians($1)) * sin(radians(latitude))
            )) AS distance
        FROM branches
        ORDER BY distance ASC
        LIMIT 1
        """,
        latitude, longitude
    )
    return dict(row) if row else None
 
 
# ──────────────────────────────────────────────────────────────────────
#  Users
# ──────────────────────────────────────────────────────────────────────
 
async def upsert_user(telegram_id: int, first_name: str = None, username: str = None) -> dict:
    pool = await get_pool()
    row = await pool.fetchrow(
        """
        INSERT INTO users (telegram_id, first_name, username)
        VALUES ($1, $2, $3)
        ON CONFLICT (telegram_id) DO UPDATE
        SET last_seen = NOW(), first_name = EXCLUDED.first_name
        RETURNING *
        """,
        telegram_id, first_name, username
    )
    return dict(row)
 
 
async def get_user_lang(telegram_id: int) -> str:
    pool = await get_pool()
    row = await pool.fetchrow(
        "SELECT language FROM users WHERE telegram_id = $1", telegram_id
    )
    return row["language"] if row else "ru"
 
 
async def set_user_lang(telegram_id: int, lang: str):
    pool = await get_pool()
    await pool.execute(
        "UPDATE users SET language = $1 WHERE telegram_id = $2", lang, telegram_id
    )
 
 
# ──────────────────────────────────────────────────────────────────────
#  Sessions (FSM state)
# ──────────────────────────────────────────────────────────────────────
 
async def save_session(telegram_id: int, state: str, data: dict = None, atm_id: str = None):
    pool = await get_pool()
    import json
    await pool.execute(
        """
        INSERT INTO sessions (telegram_id, state, data, atm_id, updated_at)
        VALUES ($1, $2, $3, $4, NOW())
        ON CONFLICT (telegram_id) DO UPDATE
        SET state = $2, data = $3, atm_id = COALESCE($4, sessions.atm_id), updated_at = NOW()
        """,
        telegram_id, state, json.dumps(data or {}), atm_id
    )
 
 
async def get_session(telegram_id: int) -> Optional[dict]:
    pool = await get_pool()
    row = await pool.fetchrow(
        "SELECT * FROM sessions WHERE telegram_id = $1", telegram_id
    )
    if not row:
        return None
    import json
    result = dict(row)
    result["data"] = json.loads(result["data"]) if result["data"] else {}
    return result
 
 
async def clear_session(telegram_id: int):
    pool = await get_pool()
    await pool.execute(
        "DELETE FROM sessions WHERE telegram_id = $1", telegram_id
    )
 
 
# ──────────────────────────────────────────────────────────────────────
#  Tickets
# ──────────────────────────────────────────────────────────────────────
 
async def create_ticket(
    telegram_id: int,
    atm_id: str,
    category: str,
    amount: float = None,
    description: str = None
) -> dict:
    pool = await get_pool()
    row = await pool.fetchrow(
        """
        INSERT INTO tickets (telegram_id, atm_id, category, amount, description)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *
        """,
        telegram_id, atm_id, category, amount, description
    )
    return dict(row)
 
 
async def get_ticket(ticket_id: int) -> Optional[dict]:
    pool = await get_pool()
    row = await pool.fetchrow("SELECT * FROM tickets WHERE id = $1", ticket_id)
    return dict(row) if row else None
 
 
async def escalate_ticket(ticket_id: int):
    pool = await get_pool()
    await pool.execute(
        "UPDATE tickets SET status = 'escalated', escalated = TRUE, updated_at = NOW() WHERE id = $1",
        ticket_id
    )
 
 
async def update_ticket_status(ticket_id: int, status: str):
    pool = await get_pool()
    await pool.execute(
        "UPDATE tickets SET status = $1, updated_at = NOW() WHERE id = $2",
        status, ticket_id
    )
 
 
# ──────────────────────────────────────────────────────────────────────
#  Admin queries
# ──────────────────────────────────────────────────────────────────────
 
async def get_open_tickets(limit: int = 50) -> list:
    pool = await get_pool()
    rows = await pool.fetch(
        """
        SELECT t.id, t.ticket_no, t.atm_id, t.category, t.status,
               t.escalated, t.amount, t.created_at, t.updated_at,
               t.phone, t.source,
               u.first_name, u.username, u.telegram_id,
               a.address AS atm_address
        FROM tickets t
        LEFT JOIN users u ON u.telegram_id = t.telegram_id
        LEFT JOIN atm_devices a ON a.atm_id = t.atm_id
        WHERE t.status IN ('open', 'in_progress', 'escalated')
        ORDER BY t.escalated DESC, t.created_at DESC
        LIMIT $1
        """,
        limit
    )
    return [dict(r) for r in rows]
 
 
async def get_all_atms() -> list:
    pool = await get_pool()
    rows = await pool.fetch("SELECT * FROM atm_devices ORDER BY atm_id")
    return [dict(r) for r in rows]
 