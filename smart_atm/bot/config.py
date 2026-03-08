# bot/config.py
import os
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN         = os.getenv("BOT_TOKEN")
DATABASE_URL      = os.getenv("DATABASE_URL")
REDIS_URL         = os.getenv("REDIS_URL", "redis://localhost:6379/0")
GOOGLE_MAPS_KEY   = os.getenv("GOOGLE_MAPS_API_KEY", "")
API_BASE_URL      = os.getenv("API_BASE_URL", "http://localhost:8000")
WEBHOOK_URL       = os.getenv("WEBHOOK_URL", "")
WEBHOOK_PATH      = os.getenv("WEBHOOK_PATH", "/webhook")

# ============================================
#  Localization strings
# ============================================

TEXTS = {
    "ru": {
        # Welcome
        "welcome":        "👋 Здравствуйте! Вы у банкомата по адресу:\n📍 *{address}*\n\nЧем я могу помочь?",
        "welcome_unknown":"👋 Здравствуйте! Чем я могу помочь?",
        "choose_lang":    "🌐 Выберите язык / Tilni tanlang / Choose language:",
        "lang_saved":     "✅ Язык установлен: Русский",

        # Main menu
        "main_menu":      "📋 Главное меню. Выберите проблему:",
        "btn_card":       "💳 Проблема с картой",
        "btn_cash":       "💵 Проблема с деньгами",
        "btn_office":     "📍 Ближайший офис",
        "btn_operator":   "📞 Связаться с оператором",
        "btn_back":       "◀️ Назад",
        "btn_home":       "🏠 В начало",
        "btn_no_help":    "⚠️ Помощь не получена",

        # Card held flow
        "card_held_menu": "💳 Проблема с картой. Что случилось?",
        "btn_card_held":  "🔒 Карта удержана банкоматом",
        "btn_card_other": "❓ Другая проблема с картой",

        "card_step1":     (
            "📋 *Шаг 1 из 3 — Карта удержана*\n\n"
            "Нажмите кнопку *«Отмена»* на экране банкомата.\n"
            "⏱ Подождите *30 секунд* — банкомат может вернуть карту автоматически.\n\n"
            "Карта вышла?"
        ),
        "btn_yes":        "✅ Да, карта вышла",
        "btn_no":         "❌ Нет, карта не вышла",

        "card_step1_ok":  "🎉 Отлично! Карта возвращена. Если есть другие вопросы — нажмите «В начало».",

        "card_step2":     (
            "📋 *Шаг 2 из 3 — Временная блокировка*\n\n"
            "Рекомендуем немедленно заблокировать карту через мобильное приложение *Asia Alliance Bank*.\n\n"
            "1. Откройте приложение\n"
            "2. Раздел «Карты» → выберите карту\n"
            "3. Нажмите «Заблокировать временно»\n\n"
            "Заблокировали?"
        ),
        "btn_blocked":    "🔐 Карту заблокировал(а)",
        "btn_no_app":     "📵 Нет приложения",

        "card_step3":     (
            "📋 *Шаг 3 из 3 — Получить карту в отделении*\n\n"
            "Ваша карта будет храниться в ближайшем отделении банка.\n\n"
            "🏦 *{branch_name}*\n"
            "📍 {branch_address}\n"
            "📞 {branch_phone}\n"
            "🕐 {branch_hours}\n\n"
            "[📍 Маршрут на карте]({maps_url})\n\n"
            "Возьмите с собой паспорт."
        ),

        # No cash flow
        "no_cash_start":  (
            "💵 *Невыдача наличных*\n\n"
            "Введите сумму (в сумах), которую банкомат не выдал.\n"
            "Например: *500000*"
        ),
        "no_cash_invalid":"❌ Пожалуйста, введите только цифры. Например: *500000*",
        "no_cash_confirm":(
            "📝 Подтвердите заявку:\n\n"
            "💰 Сумма: *{amount:,.0f} сум*\n"
            "🏧 Банкомат: {atm_id} — {address}\n"
            "🕐 Время: {time}\n\n"
            "Создать заявку?"
        ),
        "btn_confirm":    "✅ Подтвердить",
        "btn_cancel":     "❌ Отмена",
        "ticket_created": (
            "✅ *Заявка создана!*\n\n"
            "📋 Номер обращения: *{ticket_no}*\n"
            "⏳ Срок рассмотрения: 3 рабочих дня\n\n"
            "Мы уведомим вас при изменении статуса."
        ),

        # Office
        "nearest_office": (
            "🏦 *Ближайшее отделение*\n\n"
            "*{name}*\n"
            "📍 {address}\n"
            "📞 {phone}\n"
            "🕐 {hours}\n\n"
            "[📍 Построить маршрут]({maps_url})"
        ),

        # Operator
        "operator_wait":  (
            "📞 *Запрос оператора отправлен*\n\n"
            "Среднее время ожидания: 2–5 минут.\n"
            "Оператор напишет вам в этом чате."
        ),

        # Escalation
        "escalated":      (
            "⚠️ *Ваше обращение передано старшему оператору*\n\n"
            "Номер обращения: *{ticket_no}*\n"
            "Ожидайте звонка или сообщения в течение 15 минут."
        ),

        # Operator message prefix
        "operator_prefix": "👨‍💼 *Оператор Asia Alliance Bank:*\n\n",

        # Errors
        "error_atm":      "❌ Банкомат не найден. Попробуйте отсканировать QR-код снова.",
        "error_general":  "❌ Произошла ошибка. Попробуйте позже или свяжитесь с оператором.",
    },

    # ---- UZBEK ----
    "uz": {
        "welcome":        "👋 Salom! Siz bankomat yonida turibsiz:\n📍 *{address}*\n\nQanday yordam bera olaman?",
        "welcome_unknown":"👋 Salom! Qanday yordam bera olaman?",
        "choose_lang":    "🌐 Tilni tanlang:",
        "lang_saved":     "✅ Til saqlandi: O'zbekcha",
        "main_menu":      "📋 Asosiy menyu. Muammoni tanlang:",
        "btn_card":       "💳 Karta muammosi",
        "btn_cash":       "💵 Pul muammosi",
        "btn_office":     "📍 Yaqin filial",
        "btn_operator":   "📞 Operator bilan bog'lanish",
        "btn_back":       "◀️ Orqaga",
        "btn_home":       "🏠 Bosh sahifa",
        "btn_no_help":    "⚠️ Yordam olmadim",
        "card_held_menu": "💳 Karta muammosi. Nima bo'ldi?",
        "btn_card_held":  "🔒 Karta bankomat tomonidan ushlandi",
        "btn_card_other": "❓ Boshqa karta muammosi",
        "card_step1":     (
            "📋 *1-qadam — Karta ushlandi*\n\n"
            "Bankomat ekranidagi *«Bekor qilish»* tugmasini bosing.\n"
            "⏱ *30 soniya* kuting — bankomat kartani avtomatik qaytarishi mumkin.\n\n"
            "Karta chiqdi mi?"
        ),
        "btn_yes":        "✅ Ha, chiqdi",
        "btn_no":         "❌ Yo'q, chiqmadi",
        "card_step1_ok":  "🎉 Ajoyib! Karta qaytarildi.",
        "card_step2":     (
            "📋 *2-qadam — Vaqtincha bloklash*\n\n"
            "*Asia Alliance Bank* ilovasida kartani bloklashni tavsiya etamiz.\n\n"
            "1. Ilovani oching\n"
            "2. «Kartalar» bo'limi → kartani tanlang\n"
            "3. «Vaqtincha bloklash» tugmasini bosing\n\n"
            "Bloklanganmi?"
        ),
        "btn_blocked":    "🔐 Karta bloklandi",
        "btn_no_app":     "📵 Ilova yo'q",
        "card_step3":     (
            "📋 *3-qadam — Filialdan kartani olish*\n\n"
            "Kartangiz yaqin filialdа saqlanadi.\n\n"
            "🏦 *{branch_name}*\n"
            "📍 {branch_address}\n"
            "📞 {branch_phone}\n"
            "🕐 {branch_hours}\n\n"
            "[📍 Yo'nalish]({maps_url})\n\n"
            "Pasportingizni olib keling."
        ),
        "no_cash_start":  "💵 *Pul berilmadi*\n\nBerilmagan summani kiriting (so'mda).\nMasalan: *500000*",
        "no_cash_invalid":"❌ Faqat raqam kiriting. Masalan: *500000*",
        "no_cash_confirm":"📝 Arizani tasdiqlang:\n\n💰 Summa: *{amount:,.0f} so'm*\n🏧 Bankomat: {atm_id} — {address}\n🕐 Vaqt: {time}\n\nAriza yaratilsinmi?",
        "btn_confirm":    "✅ Tasdiqlash",
        "btn_cancel":     "❌ Bekor qilish",
        "ticket_created": "✅ *Ariza yaratildi!*\n\n📋 Murojaat raqami: *{ticket_no}*\n⏳ Ko'rib chiqish muddati: 3 ish kuni",
        "nearest_office": "🏦 *Yaqin filial*\n\n*{name}*\n📍 {address}\n📞 {phone}\n🕐 {hours}\n\n[📍 Yo'nalish]({maps_url})",
        "operator_wait":  "📞 *Operator so'rovi yuborildi*\n\nKutish vaqti: 2–5 daqiqa.",
        "escalated":      "⚠️ *Murojaat yuqori operatorga uzatildi*\n\nMurojaat raqami: *{ticket_no}*\n15 daqiqa ichida bog'lanishadi.",
        "operator_prefix":"👨‍💼 *Asia Alliance Bank operatori:*\n\n",
        "error_atm":      "❌ Bankomat topilmadi. QR-kodni qayta skanerlang.",
        "error_general":  "❌ Xatolik yuz berdi. Keyinroq urinib ko'ring.",
    },

    # ---- ENGLISH ----
    "en": {
        "welcome":        "👋 Hello! You are at the ATM located at:\n📍 *{address}*\n\nHow can I help you?",
        "welcome_unknown":"👋 Hello! How can I help you?",
        "choose_lang":    "🌐 Choose your language:",
        "lang_saved":     "✅ Language set: English",
        "main_menu":      "📋 Main menu. Select your issue:",
        "btn_card":       "💳 Card issue",
        "btn_cash":       "💵 Cash issue",
        "btn_office":     "📍 Nearest branch",
        "btn_operator":   "📞 Contact operator",
        "btn_back":       "◀️ Back",
        "btn_home":       "🏠 Home",
        "btn_no_help":    "⚠️ Issue not resolved",
        "card_held_menu": "💳 Card issue. What happened?",
        "btn_card_held":  "🔒 Card retained by ATM",
        "btn_card_other": "❓ Other card problem",
        "card_step1":     (
            "📋 *Step 1 of 3 — Card Retained*\n\n"
            "Press the *Cancel* button on the ATM screen.\n"
            "⏱ Wait *30 seconds* — the ATM may return the card automatically.\n\n"
            "Did the card come out?"
        ),
        "btn_yes":        "✅ Yes, card returned",
        "btn_no":         "❌ No, it didn't",
        "card_step1_ok":  "🎉 Great! Your card was returned.",
        "card_step2":     (
            "📋 *Step 2 of 3 — Temporary Block*\n\n"
            "We recommend blocking your card immediately via the *Asia Alliance Bank* app.\n\n"
            "1. Open the app\n"
            "2. Go to «Cards» → select card\n"
            "3. Tap «Temporary Block»\n\n"
            "Did you block it?"
        ),
        "btn_blocked":    "🔐 Card blocked",
        "btn_no_app":     "📵 No app",
        "card_step3":     (
            "📋 *Step 3 of 3 — Collect Card at Branch*\n\n"
            "Your card will be held at the nearest branch.\n\n"
            "🏦 *{branch_name}*\n"
            "📍 {branch_address}\n"
            "📞 {branch_phone}\n"
            "🕐 {branch_hours}\n\n"
            "[📍 Get directions]({maps_url})\n\n"
            "Please bring your passport."
        ),
        "no_cash_start":  "💵 *Cash Not Dispensed*\n\nEnter the amount (in UZS) the ATM failed to dispense.\nExample: *500000*",
        "no_cash_invalid":"❌ Please enter numbers only. Example: *500000*",
        "no_cash_confirm":"📝 Confirm your request:\n\n💰 Amount: *{amount:,.0f} UZS*\n🏧 ATM: {atm_id} — {address}\n🕐 Time: {time}\n\nCreate ticket?",
        "btn_confirm":    "✅ Confirm",
        "btn_cancel":     "❌ Cancel",
        "ticket_created": "✅ *Ticket Created!*\n\n📋 Reference: *{ticket_no}*\n⏳ Processing time: 3 business days",
        "nearest_office": "🏦 *Nearest Branch*\n\n*{name}*\n📍 {address}\n📞 {phone}\n🕐 {hours}\n\n[📍 Get directions]({maps_url})",
        "operator_wait":  "📞 *Operator request sent*\n\nAverage wait: 2–5 minutes.",
        "escalated":      "⚠️ *Your issue has been escalated*\n\nTicket: *{ticket_no}*\nYou will be contacted within 15 minutes.",
        "operator_prefix":"👨‍💼 *Asia Alliance Bank Operator:*\n\n",
        "error_atm":      "❌ ATM not found. Please scan the QR code again.",
        "error_general":  "❌ An error occurred. Please try again later.",
    }
}

def t(lang: str, key: str, **kwargs) -> str:
    """Get localized text."""
    lang = lang if lang in TEXTS else "ru"
    text = TEXTS[lang].get(key, TEXTS["ru"].get(key, key))
    return text.format(**kwargs) if kwargs else text
