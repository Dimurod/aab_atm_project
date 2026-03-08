# bot/webhooks.py
"""
Sends real-time events to the Admin Dashboard via HTTP webhooks.
The admin panel listens on /api/webhook/events.
"""
import aiohttp
import os
import logging
from datetime import datetime

ADMIN_API_URL = os.getenv("ADMIN_WEBHOOK_URL", "http://localhost:8000/api/webhook/events")
WEBHOOK_SECRET = os.getenv("WEBHOOK_SECRET", "change_me")

logger = logging.getLogger(__name__)


async def _send(payload: dict):
    """Fire-and-forget webhook delivery."""
    try:
        async with aiohttp.ClientSession() as session:
            async with session.post(
                ADMIN_API_URL,
                json=payload,
                headers={"X-Webhook-Secret": WEBHOOK_SECRET},
                timeout=aiohttp.ClientTimeout(total=5)
            ) as resp:
                if resp.status != 200:
                    logger.warning(f"Webhook returned {resp.status}")
    except Exception as e:
        logger.error(f"Webhook error: {e}")


async def notify_admin_new_ticket(ticket: dict):
    await _send({
        "event":      "new_ticket",
        "ticket_id":  ticket["id"],
        "ticket_no":  ticket["ticket_no"],
        "category":   ticket["category"],
        "atm_id":     ticket.get("atm_id"),
        "amount":     float(ticket["amount"]) if ticket.get("amount") else None,
        "telegram_id":ticket["telegram_id"],
        "created_at": ticket["created_at"].isoformat() if ticket.get("created_at") else None,
        "escalated":  False,
    })


async def notify_admin_operator_request(ticket: dict, user):
    await _send({
        "event":       "operator_request",
        "ticket_id":   ticket["id"],
        "ticket_no":   ticket["ticket_no"],
        "telegram_id": ticket["telegram_id"],
        "first_name":  getattr(user, "first_name", ""),
        "username":    getattr(user, "username", ""),
        "atm_id":      ticket.get("atm_id"),
        "created_at":  datetime.utcnow().isoformat(),
    })


async def notify_admin_escalation(ticket: dict, user):
    """This event causes RED highlight in the admin panel."""
    await _send({
        "event":       "escalation",
        "ticket_id":   ticket["id"],
        "ticket_no":   ticket["ticket_no"],
        "telegram_id": ticket["telegram_id"],
        "first_name":  getattr(user, "first_name", ""),
        "username":    getattr(user, "username", ""),
        "atm_id":      ticket.get("atm_id"),
        "created_at":  datetime.utcnow().isoformat(),
        "escalated":   True,
    })


async def send_operator_message_to_user(bot, telegram_id: int, text: str, lang: str = "ru"):
    """Called from Admin panel API to deliver operator reply to client."""
    from bot.config import t
    full_text = t(lang, "operator_prefix") + text
    await bot.send_message(telegram_id, full_text, parse_mode="Markdown")
