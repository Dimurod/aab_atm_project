# bot/handlers/card_flow.py
"""
Handles the «Card Retained» step-by-step flow:
  Step 1 → Press Cancel (30 sec)
  Step 2 → Block via app
  Step 3 → Branch address + directions
"""
from aiogram import Router, F
from aiogram.types import CallbackQuery

from bot.config import t
from bot.database import get_user_lang, get_session, get_atm, get_nearest_branch
from bot.keyboards.inline import (
    card_menu, yes_no_keyboard, step2_keyboard, nav_keyboard
)
from bot.utils import google_maps_url

router = Router()


async def _lang_session(user_id: int):
    lang = await get_user_lang(user_id)
    session = await get_session(user_id)
    return lang, session


# ── Open card sub-menu ──────────────────────────────────────────────

@router.callback_query(F.data == "menu:card")
async def card_menu_handler(callback: CallbackQuery):
    lang, _ = await _lang_session(callback.from_user.id)
    await callback.message.edit_text(
        t(lang, "card_held_menu"),
        parse_mode="Markdown",
        reply_markup=card_menu(lang)
    )
    await callback.answer()


# ── Step 1: Press Cancel ────────────────────────────────────────────

@router.callback_query(F.data == "card:held")
async def card_held_step1(callback: CallbackQuery):
    lang, _ = await _lang_session(callback.from_user.id)
    await callback.message.edit_text(
        t(lang, "card_step1"),
        parse_mode="Markdown",
        reply_markup=yes_no_keyboard(lang)
    )
    await callback.answer()


@router.callback_query(F.data == "card_step1:yes")
async def card_step1_yes(callback: CallbackQuery):
    lang, _ = await _lang_session(callback.from_user.id)
    await callback.message.edit_text(
        t(lang, "card_step1_ok"),
        parse_mode="Markdown",
        reply_markup=nav_keyboard(lang)
    )
    await callback.answer()


@router.callback_query(F.data == "card_step1:no")
async def card_step1_no(callback: CallbackQuery):
    lang, _ = await _lang_session(callback.from_user.id)
    await callback.message.edit_text(
        t(lang, "card_step2"),
        parse_mode="Markdown",
        reply_markup=step2_keyboard(lang)
    )
    await callback.answer()


# ── Step 2: Block card in app ───────────────────────────────────────

@router.callback_query(F.data.in_({"card_step2:blocked", "card_step2:no_app"}))
async def card_step2_done(callback: CallbackQuery):
    lang, session = await _lang_session(callback.from_user.id)

    # Get ATM → branch info
    atm_id = session.get("atm_id") if session else None
    branch = None

    if atm_id:
        atm = await get_atm(atm_id)
        if atm and atm.get("branch_name"):
            branch = atm
    
    if not branch:
        # Fallback: use Tashkent center coordinates
        branch_data = await get_nearest_branch(41.2995, 69.2401)
        if branch_data:
            branch = {
                "branch_name":    branch_data["name"],
                "branch_address": branch_data["address"],
                "branch_phone":   branch_data.get("phone", "—"),
                "branch_hours":   branch_data.get("working_hours", "09:00–18:00"),
                "branch_lat":     branch_data["latitude"],
                "branch_lon":     branch_data["longitude"],
            }

    if branch:
        maps_url = google_maps_url(
            branch["branch_lat"],
            branch["branch_lon"],
            branch["branch_name"]
        )
        text = t(
            lang, "card_step3",
            branch_name=branch["branch_name"],
            branch_address=branch["branch_address"],
            branch_phone=branch.get("branch_phone", "—"),
            branch_hours=branch.get("branch_hours", "09:00–18:00"),
            maps_url=maps_url
        )
    else:
        text = t(lang, "error_general")

    await callback.message.edit_text(
        text,
        parse_mode="Markdown",
        reply_markup=nav_keyboard(lang, with_escalate=True),
        disable_web_page_preview=True
    )
    await callback.answer()
