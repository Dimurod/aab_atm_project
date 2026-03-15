# backend/main.py
"""
Smart ATM Assistant — FastAPI Backend
Handles: webhook events from bot, admin API for dashboard, operator chat.
"""
from fastapi import FastAPI, HTTPException, Depends, Header, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import asyncio
import json
import os
import logging
 
logger = logging.getLogger(__name__)
 
app = FastAPI(title="Smart ATM Assistant API", version="1.0.0")
 
# CORS for admin panel
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_methods=["*"],
    allow_headers=["*"],
)
 
WEBHOOK_SECRET = os.getenv("WEBHOOK_SECRET", "change_me")
 
# ── WebSocket connection manager ────────────────────────────────────
 
class ConnectionManager:
    def __init__(self):
        self.active: List[WebSocket] = []
 
    async def connect(self, ws: WebSocket):
        await ws.accept()
        self.active.append(ws)
 
    def disconnect(self, ws: WebSocket):
        self.active.remove(ws)
 
    async def broadcast(self, data: dict):
        dead = []
        for ws in self.active:
            try:
                await ws.send_json(data)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.active.remove(ws)
 
manager = ConnectionManager()
 
 
# ── Pydantic models ─────────────────────────────────────────────────
 
class WebhookEvent(BaseModel):
    event: str
    ticket_id: Optional[int] = None
    ticket_no: Optional[str] = None
    category: Optional[str] = None
    atm_id: Optional[str] = None
    amount: Optional[float] = None
    telegram_id: Optional[int] = None
    first_name: Optional[str] = None
    username: Optional[str] = None
    created_at: Optional[str] = None
    escalated: bool = False
 
 
class OperatorMessage(BaseModel):
    telegram_id: int
    text: str
    lang: str = "ru"
 
 
class TicketStatusUpdate(BaseModel):
    status: str
 
 
class TicketCreate(BaseModel):
    atm_id: str
    category: str
    amount: Optional[float] = None
    source: str = "pwa"
    phone: Optional[str] = None
 
 
# ── Webhook receiver ────────────────────────────────────────────────
 
@app.post("/api/webhook/events")
async def receive_webhook(
    event: WebhookEvent,
    x_webhook_secret: str = Header(None)
):
    """Receive events from the Telegram bot and broadcast to admin dashboard."""
    if x_webhook_secret != WEBHOOK_SECRET:
        raise HTTPException(status_code=403, detail="Invalid webhook secret")
 
    # Broadcast to all connected admin dashboards
    await manager.broadcast(event.model_dump())
 
    logger.info(f"Webhook received: {event.event} | ticket={event.ticket_no}")
    return {"ok": True}
 
 
# ── WebSocket for admin panel (real-time) ───────────────────────────
 
@app.websocket("/ws/admin")
async def admin_websocket(websocket: WebSocket):
    """Admin panel connects here to receive real-time ticket events."""
    await manager.connect(websocket)
    try:
        while True:
            # Keep connection alive, receive operator commands
            data = await websocket.receive_text()
            # Forward operator messages back as events
            await manager.broadcast({"event": "operator_typing", "data": data})
    except WebSocketDisconnect:
        manager.disconnect(websocket)
 
 
# ── Admin API ───────────────────────────────────────────────────────
 
@app.post("/api/tickets")
async def create_ticket(body: TicketCreate):
    """Create a new ticket from PWA client."""
    from bot.database import get_pool
    pool = await get_pool()
    async with pool.acquire() as conn:
        # Generate ticket number
        count = await conn.fetchval("SELECT COUNT(*) FROM tickets")
        ticket_no = f"T-{1000 + count + 1}"
        row = await conn.fetchrow(
            """INSERT INTO tickets (atm_id, category, amount, source, status, ticket_no, phone)
               VALUES ($1, $2, $3, $4, 'open', $5, $6)
               RETURNING id, ticket_no""",
            body.atm_id, body.category, body.amount, body.source, ticket_no, body.phone
        )
        # Broadcast to Flutter dashboard
        await manager.broadcast({
            "event": "new_ticket",
            "ticket_id": row["id"],
            "ticket_no": row["ticket_no"],
            "atm_id": body.atm_id,
            "category": body.category,
            "source": body.source,
        })
    logger.info(f"✅ New PWA ticket: {ticket_no} | ATM: {body.atm_id} | {body.category}")
    return {"id": row["id"], "ticket_no": row["ticket_no"]}
 
 
@app.get("/api/tickets")
async def list_tickets(status: Optional[str] = None, limit: int = 50):
    """List all open/active tickets."""
    from bot.database import get_open_tickets
    tickets = await get_open_tickets(limit)
    if status:
        tickets = [t for t in tickets if t["status"] == status]
    return {"tickets": tickets}
 
 
@app.get("/api/tickets/{ticket_id}")
async def get_ticket(ticket_id: int):
    from bot.database import get_ticket
    ticket = await get_ticket(ticket_id)
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket
 
 
@app.patch("/api/tickets/{ticket_id}/status")
async def update_ticket_status(ticket_id: int, body: TicketStatusUpdate):
    from bot.database import update_ticket_status
    await update_ticket_status(ticket_id, body.status)
    return {"ok": True}
 
 
@app.get("/api/atms")
async def list_atms():
    """Return all ATMs for the map display."""
    from bot.database import get_all_atms
    atms = await get_all_atms()
    return {"atms": atms}
 
 
@app.post("/api/operator/send")
async def operator_send_message(body: OperatorMessage):
    """
    Operator sends a message to a client via the bot.
    Called from the Admin Dashboard Chat interface.
    """
    import importlib
    try:
        # Import bot instance dynamically to avoid circular imports
        from aiogram import Bot
        from bot.config import BOT_TOKEN
        from bot.webhooks import send_operator_message_to_user
 
        bot = Bot(token=BOT_TOKEN)
        await send_operator_message_to_user(
            bot, body.telegram_id, body.text, body.lang
        )
        await bot.session.close()
        return {"ok": True}
    except Exception as e:
        logger.error(f"Operator send error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
 
 
# ── Health check ────────────────────────────────────────────────────
 
@app.get("/health")
async def health():
    return {"status": "ok", "service": "Smart ATM Assistant API"}
 
 
# ── Startup ─────────────────────────────────────────────────────────
 
@app.on_event("startup")
async def startup():
    from bot.database import get_pool
    await get_pool()
    logger.info("✅ API started, DB connected")
 
 
@app.on_event("shutdown")
async def shutdown():
    from bot.database import close_pool
    await close_pool()