# bot/handlers/misc.py
"""
Handles: nearest office, operator request, escalation, navigation.
"""
from aiogram import Router, F
from aiogram.types import CallbackQuery

from bot.config import t
from bot.database import (
    get_user_lang, get_session, get_atm, get_nearest_branch,
    create_ticket, escalate_ticket, get_ticket
)
from bot.keyboards.inline import nav_keyboard, main_menu
from bot.utils import google_maps_url
from bot.webhooks import notify_admin_operator_request, notify_admin_escalation

router = Router()


# ── Nearest office ──────────────────────────────────────────────────

@router.callback_query(F.data == "menu:office")
async def nearest_office(callback: CallbackQuery):
    user_id = callback.from_user.id
    lang = await get_user_lang(user_id)

    # Get coordinates from ATM context
    session = await get_session(user_id)
    atm_id = session.get("atm_id") if session else None
    lat, lon = 41.2995, 69.2401  # Default: Tashkent center

    if atm_id:
        atm = await get_atm(atm_id)
        if atm:
            lat = atm["latitude"]
            lon = atm["longitude"]

    branch = await get_nearest_branch(lat, lon)

    if branch:
        maps_url = google_maps_url(branch["latitude"], branch["longitude"], branch["name"])
        text = t(
            lang, "nearest_office",
            name=branch["name"],
            address=branch["address"],
            phone=branch.get("phone", "—"),
            hours=branch.get("working_hours", "09:00–18:00"),
            maps_url=maps_url
        )
    else:
        text = t(lang, "error_general")

    await callback.message.edit_text(
        text,
        parse_mode="Markdown",
        disable_web_page_preview=True,
        reply_markup=nav_keyboard(lang)
    )
    await callback.answer()


# ── Request operator ────────────────────────────────────────────────

@router.callback_query(F.data == "menu:operator")
async def request_operator(callback: CallbackQuery):
    user_id = callback.from_user.id
    lang = await get_user_lang(user_id)

    session = await get_session(user_id)
    atm_id = session.get("atm_id") if session else None

    # Create operator request ticket
    ticket = await create_ticket(
        telegram_id=user_id,
        atm_id=atm_id,
        category="other",
        description="Запрос живого оператора"
    )

    await callback.message.edit_text(
        t(lang, "operator_wait"),
        parse_mode="Markdown",
        reply_markup=nav_keyboard(lang)
    )

    # Notify admin panel
    await notify_admin_operator_request(ticket, callback.from_user)
    await callback.answer()


# ── Escalation (issue not resolved) ────────────────────────────────

@router.callback_query(F.data == "nav:escalate")
async def escalate(callback: CallbackQuery):
    user_id = callback.from_user.id
    lang = await get_user_lang(user_id)

    session = await get_session(user_id)
    atm_id = session.get("atm_id") if session else None

    # Create or escalate ticket
    ticket = await create_ticket(
        telegram_id=user_id,
        atm_id=atm_id,
        category="other",
        description="Клиент не получил помощь — эскалация"
    )
    await escalate_ticket(ticket["id"])

    await callback.message.edit_text(
        t(lang, "escalated", ticket_no=ticket["ticket_no"]),
        parse_mode="Markdown",
        reply_markup=nav_keyboard(lang)
    )

    # Notify admin (will highlight in RED)
    await notify_admin_escalation(ticket, callback.from_user)
    await callback.answer()


# ── Navigation ──────────────────────────────────────────────────────

@router.callback_query(F.data == "nav:home")
async def go_home(callback: CallbackQuery):
    user_id = callback.from_user.id
    lang = await get_user_lang(user_id)

    # Check ATM context for personalised menu
    session = await get_session(user_id)
    atm_id = session.get("atm_id") if session else None
    header = ""

    if atm_id:
        atm = await get_atm(atm_id)
        if atm:
            header = f"📍 *{atm['address']}*\n\n"

    await callback.message.edit_text(
        header + t(lang, "main_menu"),
        parse_mode="Markdown",
        reply_markup=main_menu(lang)
    )
    await callback.answer()
