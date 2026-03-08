# bot/handlers/cash_flow.py
"""
Handles «Cash Not Dispensed» flow:
  Step 1 → Ask amount
  Step 2 → Confirm
  Step 3 → Create ticket + notify admin via webhook
"""
from aiogram import Router, F
from aiogram.types import CallbackQuery, Message
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup

from bot.config import t
from bot.database import (
    get_user_lang, get_session, get_atm, create_ticket, save_session
)
from bot.keyboards.inline import confirm_keyboard, nav_keyboard, main_menu
from bot.utils import parse_amount, now_str
from bot.webhooks import notify_admin_new_ticket

router = Router()


class CashForm(StatesGroup):
    waiting_for_amount = State()


# ── Open cash flow ──────────────────────────────────────────────────

@router.callback_query(F.data == "menu:cash")
async def cash_start(callback: CallbackQuery, state: FSMContext):
    lang = await get_user_lang(callback.from_user.id)
    await state.set_state(CashForm.waiting_for_amount)
    await callback.message.edit_text(
        t(lang, "no_cash_start"),
        parse_mode="Markdown"
    )
    await callback.answer()


# ── Receive amount from user ────────────────────────────────────────

@router.message(CashForm.waiting_for_amount)
async def cash_got_amount(message: Message, state: FSMContext):
    user_id = message.from_user.id
    lang = await get_user_lang(user_id)

    amount = parse_amount(message.text)
    if amount is None:
        await message.answer(t(lang, "no_cash_invalid"), parse_mode="Markdown")
        return

    # Save amount to FSM
    await state.update_data(amount=amount)

    # Get ATM context
    session = await get_session(user_id)
    atm_id = session.get("atm_id") if session else None
    address = "—"

    if atm_id:
        atm = await get_atm(atm_id)
        if atm:
            address = atm["address"]

    await message.answer(
        t(lang, "no_cash_confirm",
          amount=amount,
          atm_id=atm_id or "—",
          address=address,
          time=now_str()),
        parse_mode="Markdown",
        reply_markup=confirm_keyboard(lang)
    )


# ── Confirm → create ticket ─────────────────────────────────────────

@router.callback_query(F.data == "cash:confirm")
async def cash_confirm(callback: CallbackQuery, state: FSMContext):
    user_id = callback.from_user.id
    lang = await get_user_lang(user_id)

    data = await state.get_data()
    amount = data.get("amount", 0)

    session = await get_session(user_id)
    atm_id = session.get("atm_id") if session else None

    # Create ticket in DB
    ticket = await create_ticket(
        telegram_id=user_id,
        atm_id=atm_id,
        category="no_cash",
        amount=amount,
        description=f"Невыдача наличных. Сумма: {amount:,.0f} сум. ATM: {atm_id}"
    )

    await state.clear()

    await callback.message.edit_text(
        t(lang, "ticket_created", ticket_no=ticket["ticket_no"]),
        parse_mode="Markdown",
        reply_markup=nav_keyboard(lang, with_escalate=True)
    )

    # Notify admin panel via webhook
    await notify_admin_new_ticket(ticket)

    await callback.answer()


@router.callback_query(F.data == "cash:cancel")
async def cash_cancel(callback: CallbackQuery, state: FSMContext):
    user_id = callback.from_user.id
    lang = await get_user_lang(user_id)
    await state.clear()
    await callback.message.edit_text(
        t(lang, "main_menu"),
        parse_mode="Markdown",
        reply_markup=main_menu(lang)
    )
    await callback.answer()
