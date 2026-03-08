# bot/keyboards/inline.py
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
from bot.config import t


def lang_keyboard() -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🇺🇿 O'zbekcha",  callback_data="lang:uz")],
        [InlineKeyboardButton(text="🇷🇺 Русский",    callback_data="lang:ru")],
        [InlineKeyboardButton(text="🇬🇧 English",    callback_data="lang:en")],
    ])


def main_menu(lang: str) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text=t(lang, "btn_card"),     callback_data="menu:card")],
        [InlineKeyboardButton(text=t(lang, "btn_cash"),     callback_data="menu:cash")],
        [InlineKeyboardButton(text=t(lang, "btn_office"),   callback_data="menu:office")],
        [InlineKeyboardButton(text=t(lang, "btn_operator"), callback_data="menu:operator")],
    ])


def card_menu(lang: str) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text=t(lang, "btn_card_held"),  callback_data="card:held")],
        [InlineKeyboardButton(text=t(lang, "btn_card_other"), callback_data="card:other")],
        [InlineKeyboardButton(text=t(lang, "btn_home"),       callback_data="nav:home")],
    ])


def yes_no_keyboard(lang: str) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [
            InlineKeyboardButton(text=t(lang, "btn_yes"), callback_data="card_step1:yes"),
            InlineKeyboardButton(text=t(lang, "btn_no"),  callback_data="card_step1:no"),
        ],
        [InlineKeyboardButton(text=t(lang, "btn_home"), callback_data="nav:home")],
    ])


def step2_keyboard(lang: str) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text=t(lang, "btn_blocked"),  callback_data="card_step2:blocked")],
        [InlineKeyboardButton(text=t(lang, "btn_no_app"),   callback_data="card_step2:no_app")],
        [InlineKeyboardButton(text=t(lang, "btn_home"),     callback_data="nav:home")],
    ])


def confirm_keyboard(lang: str) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(inline_keyboard=[
        [
            InlineKeyboardButton(text=t(lang, "btn_confirm"), callback_data="cash:confirm"),
            InlineKeyboardButton(text=t(lang, "btn_cancel"),  callback_data="cash:cancel"),
        ],
    ])


def nav_keyboard(lang: str, with_escalate: bool = False) -> InlineKeyboardMarkup:
    rows = [[InlineKeyboardButton(text=t(lang, "btn_home"), callback_data="nav:home")]]
    if with_escalate:
        rows.append([
            InlineKeyboardButton(text=t(lang, "btn_no_help"), callback_data="nav:escalate")
        ])
    return InlineKeyboardMarkup(inline_keyboard=rows)
