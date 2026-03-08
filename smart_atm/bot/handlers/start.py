# bot/handlers/start.py
from aiogram import Router, F
from aiogram.types import Message, CallbackQuery
from aiogram.filters import CommandStart, CommandObject

from bot.config import t
from bot.database import upsert_user, get_atm, save_session, set_user_lang, get_user_lang
from bot.keyboards.inline import lang_keyboard, main_menu

router = Router()


@router.message(CommandStart())
async def cmd_start(message: Message, command: CommandObject):
    """Entry point — handles /start with optional deep link parameter (ATM ID)."""
    user = message.from_user
    await upsert_user(user.id, user.first_name, user.username)

    # Extract ATM ID from deep link: /start ID4582
    atm_id = command.args.strip() if command.args else None
    atm = None

    if atm_id:
        atm = await get_atm(atm_id)

    lang = await get_user_lang(user.id)

    if atm:
        # Save ATM context to session
        await save_session(user.id, "main_menu", atm_id=atm_id)
        text = t(lang, "welcome", address=atm["address"])
    else:
        await save_session(user.id, "main_menu")
        text = t(lang, "welcome_unknown")

    # First time — show language picker
    if lang == "ru" and atm_id:
        await message.answer(text, parse_mode="Markdown", reply_markup=lang_keyboard())
    else:
        await message.answer(text, parse_mode="Markdown")
        await message.answer(
            t(lang, "main_menu"),
            parse_mode="Markdown",
            reply_markup=main_menu(lang)
        )


@router.callback_query(F.data.startswith("lang:"))
async def choose_language(callback: CallbackQuery):
    """Language selection handler."""
    lang = callback.data.split(":")[1]
    await set_user_lang(callback.from_user.id, lang)

    session = await _get_or_create_session(callback.from_user.id)

    await callback.message.edit_text(
        t(lang, "lang_saved"),
        parse_mode="Markdown"
    )

    # Check if we have ATM context
    atm_id = session.get("atm_id") if session else None
    if atm_id:
        atm = await get_atm(atm_id)
        if atm:
            welcome = t(lang, "welcome", address=atm["address"])
            await callback.message.answer(welcome, parse_mode="Markdown")

    await callback.message.answer(
        t(lang, "main_menu"),
        parse_mode="Markdown",
        reply_markup=main_menu(lang)
    )
    await callback.answer()


async def _get_or_create_session(telegram_id: int):
    from bot.database import get_session
    return await get_session(telegram_id)
