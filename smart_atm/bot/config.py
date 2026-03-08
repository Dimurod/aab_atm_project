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
#  Localization strings  — МЯГКИЙ ТОН v2.0
# ============================================

TEXTS = {
    "ru": {
        # Welcome
        "welcome": (
            "👋 Здравствуйте! Вы у банкомата:\n"
            "📍 *{address}*\n\n"
            "Я помогу решить любой вопрос быстро и без лишних звонков. "
            "Что случилось?"
        ),
        "welcome_unknown": (
            "👋 Здравствуйте! Я — помощник Asia Alliance Bank.\n\n"
            "Расскажите, чем я могу помочь?"
        ),
        "choose_lang":  "🌐 Выберите язык / Tilni tanlang / Choose language:",
        "lang_saved":   "✅ Язык установлен: Русский",

        # Main menu
        "main_menu":    "📋 Главное меню. Что произошло?",
        "btn_card":     "💳 Проблема с картой",
        "btn_cash":     "💵 Деньги не вышли",
        "btn_office":   "📍 Ближайший офис",
        "btn_operator": "📞 Позвать оператора",
        "btn_back":     "◀️ Назад",
        "btn_home":     "🏠 В начало",
        "btn_no_help":  "⚠️ Проблема не решена",

        # Card held flow
        "card_held_menu": "💳 Понимаю, это неприятная ситуация. Что именно случилось с картой?",
        "btn_card_held":  "🔒 Карта застряла в банкомате",
        "btn_card_other": "❓ Другая проблема",

        "card_step1": (
            "😔 *Не волнуйтесь — мы разберёмся вместе!*\n\n"
            "📋 *Шаг 1 из 3*\n\n"
            "Нажмите кнопку *«Отмена»* на экране банкомата.\n"
            "⏱ Подождите *30 секунд* — иногда банкомат возвращает карту автоматически.\n\n"
            "Карта вышла?"
        ),
        "btn_yes":      "✅ Да, карта вышла",
        "btn_no":       "❌ Нет, не вышла",

        "card_step1_ok": (
            "🎉 *Отлично! Карта возвращена.*\n\n"
            "Если почувствуете что-то странное при следующей оплате — "
            "лучше перестрахуйтесь и временно заблокируйте карту в приложении.\n\n"
            "Удачного вам дня! 😊"
        ),

        "card_step2": (
            "📋 *Шаг 2 из 3 — Защитите деньги*\n\n"
            "Пока карта внутри банкомата — важно сразу её заблокировать, "
            "чтобы никто не смог воспользоваться.\n\n"
            "Откройте приложение *Asia Alliance Bank*:\n"
            "1️⃣ Раздел «Карты» → выберите карту\n"
            "2️⃣ Нажмите «Заблокировать временно»\n\n"
            "Заблокировали?"
        ),
        "btn_blocked":  "🔐 Да, заблокировал(а)",
        "btn_no_app":   "📵 Нет приложения",

        "card_step3": (
            "📋 *Шаг 3 из 3 — Забрать карту в офисе*\n\n"
            "Не переживайте — ваша карта в безопасности. "
            "Она хранится в ближайшем отделении банка.\n\n"
            "🏦 *{branch_name}*\n"
            "📍 {branch_address}\n"
            "📞 {branch_phone}\n"
            "🕐 {branch_hours}\n\n"
            "[📍 Маршрут на карте]({maps_url})\n\n"
            "🪪 Возьмите с собой паспорт. Карту выдадут сразу."
        ),

        # No cash flow
        "no_cash_start": (
            "😔 *Понимаем, как это неприятно.*\n\n"
            "Не волнуйтесь — деньги никуда не пропадут, мы всё зафиксируем.\n\n"
            "📸 *Прямо сейчас сделайте это:*\n"
            "• Сфотографируйте экран банкомата\n"
            "• Сохраните чек, если банкомат его выдал\n"
            "• Сделайте скриншот уведомления от банка\n"
            "• Подождите 2–3 минуты — иногда деньги выходят с задержкой\n\n"
            "💬 Введите сумму (в сумах), которую банкомат не выдал.\n"
            "Например: *500000*"
        ),
        "no_cash_invalid": (
            "❌ Пожалуйста, введите только цифры.\n"
            "Например: *500000*"
        ),
        "no_cash_confirm": (
            "📝 *Проверьте данные заявки:*\n\n"
            "💰 Сумма: *{amount:,.0f} сум*\n"
            "🏧 Банкомат: {atm_id} — {address}\n"
            "🕐 Время: {time}\n\n"
            "Всё верно? Создаём заявку?"
        ),
        "btn_confirm":  "✅ Да, всё верно",
        "btn_cancel":   "❌ Отмена",

        "ticket_created": (
            "✅ *Заявка создана!*\n\n"
            "📋 Номер обращения: *{ticket_no}*\n"
            "⏳ Срок рассмотрения: *3 рабочих дня*\n\n"
            "Деньги будут возвращены на ваш счёт автоматически после проверки.\n"
            "Мы уведомим вас при изменении статуса. 🙏"
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
        "operator_wait": (
            "📞 *Оператор уже получил ваш запрос*\n\n"
            "Среднее время ожидания: *2–5 минут*.\n"
            "Оператор напишет вам прямо в этом чате.\n\n"
            "Пожалуйста, оставайтесь на связи 🙏"
        ),

        # Escalation
        "escalated": (
            "⚠️ *Ваше обращение передано старшему специалисту*\n\n"
            "📋 Номер обращения: *{ticket_no}*\n\n"
            "Мы понимаем, что ситуация неприятная. "
            "Специалист свяжется с вами в течение *15 минут*. "
            "Приносим извинения за неудобство."
        ),

        # Operator message prefix
        "operator_prefix": "👨‍💼 *Оператор Asia Alliance Bank:*\n\n",

        # Errors
        "error_atm":     "❌ Банкомат не найден. Попробуйте отсканировать QR-код ещё раз.",
        "error_general": "❌ Что-то пошло не так. Попробуйте позже или нажмите «Позвать оператора».",
    },

    # ==============================
    #  UZBEK
    # ==============================
    "uz": {
        "welcome": (
            "👋 Assalomu alaykum! Siz bankomat yonida turibsiz:\n"
            "📍 *{address}*\n\n"
            "Har qanday muammoni tez va qo'shimcha qo'ng'iroqlarsiz hal qilishga yordam beraman. "
            "Nima bo'ldi?"
        ),
        "welcome_unknown": (
            "👋 Assalomu alaykum! Men Asia Alliance Bank yordamchisiman.\n\n"
            "Qanday yordam bera olaman?"
        ),
        "choose_lang":  "🌐 Tilni tanlang:",
        "lang_saved":   "✅ Til saqlandi: O'zbekcha",

        "main_menu":    "📋 Asosiy menyu. Nima bo'ldi?",
        "btn_card":     "💳 Karta muammosi",
        "btn_cash":     "💵 Pul chiqmadi",
        "btn_office":   "📍 Yaqin filial",
        "btn_operator": "📞 Operator chaqirish",
        "btn_back":     "◀️ Orqaga",
        "btn_home":     "🏠 Bosh sahifa",
        "btn_no_help":  "⚠️ Muammo hal bo'lmadi",

        "card_held_menu": "💳 Tushunaman, bu noqulay holat. Karta bilan nima bo'ldi?",
        "btn_card_held":  "🔒 Karta bankomat ichida qoldi",
        "btn_card_other": "❓ Boshqa muammo",

        "card_step1": (
            "😔 *Xavotir olmang — birga hal qilamiz!*\n\n"
            "📋 *1-qadam 3 tadan*\n\n"
            "Bankomat ekranidagi *«Bekor qilish»* tugmasini bosing.\n"
            "⏱ *30 soniya* kuting — bankomat kartani avtomatik qaytarishi mumkin.\n\n"
            "Karta chiqdi mi?"
        ),
        "btn_yes":      "✅ Ha, chiqdi",
        "btn_no":       "❌ Yo'q, chiqmadi",

        "card_step1_ok": (
            "🎉 *Ajoyib! Karta qaytarildi.*\n\n"
            "Keyingi to'lovda biror g'ayritabiiy narsa sezсangiz — "
            "ilovada kartani vaqtincha bloklashni maslahat beramiz.\n\n"
            "Xayrli kun! 😊"
        ),

        "card_step2": (
            "📋 *2-qadam — Pulni himoya qiling*\n\n"
            "Karta bankomat ichida turganida uni zudlik bilan bloklash muhim — "
            "begona odam foydalanmasin.\n\n"
            "*Asia Alliance Bank* ilovasini oching:\n"
            "1️⃣ «Kartalar» bo'limi → kartani tanlang\n"
            "2️⃣ «Vaqtincha bloklash» tugmasini bosing\n\n"
            "Bloklanganmi?"
        ),
        "btn_blocked":  "🔐 Ha, bloklandi",
        "btn_no_app":   "📵 Ilova yo'q",

        "card_step3": (
            "📋 *3-qadam — Filialdan kartani olish*\n\n"
            "Xavotir olmang — kartangiz xavfsiz. "
            "U yaqin filiálda saqlanadi.\n\n"
            "🏦 *{branch_name}*\n"
            "📍 {branch_address}\n"
            "📞 {branch_phone}\n"
            "🕐 {branch_hours}\n\n"
            "[📍 Yo'nalish]({maps_url})\n\n"
            "🪪 Pasportingizni olib keling. Karta darhol beriladi."
        ),

        "no_cash_start": (
            "😔 *Tushunaman, bu juda noqulay.*\n\n"
            "Xavotir olmang — pullar yo'qolmaydi, barchasini qayd etamiz.\n\n"
            "📸 *Hoziroq shu ishlarni bajaring:*\n"
            "• Bankomat ekranini suratga oling\n"
            "• Chek chiqgan bo'lsa, saqlang\n"
            "• Bank bildirishnomasi skrinshot qiling\n"
            "• 2–3 daqiqa kuting — ba'zida pul kechikib chiqadi\n\n"
            "💬 Bankomat bermagan summani kiriting (so'mda).\n"
            "Masalan: *500000*"
        ),
        "no_cash_invalid": "❌ Iltimos, faqat raqam kiriting.\nMasalan: *500000*",
        "no_cash_confirm": (
            "📝 *Ariza ma'lumotlarini tekshiring:*\n\n"
            "💰 Summa: *{amount:,.0f} so'm*\n"
            "🏧 Bankomat: {atm_id} — {address}\n"
            "🕐 Vaqt: {time}\n\n"
            "Hammasi to'g'rimi? Ariza yarataymi?"
        ),
        "btn_confirm":  "✅ Ha, to'g'ri",
        "btn_cancel":   "❌ Bekor qilish",

        "ticket_created": (
            "✅ *Ariza yaratildi!*\n\n"
            "📋 Murojaat raqami: *{ticket_no}*\n"
            "⏳ Ko'rib chiqish muddati: *3 ish kuni*\n\n"
            "Pul tekshiruvdan so'ng hisobingizga avtomatik qaytariladi.\n"
            "Holat o'zgarganda xabar beramiz. 🙏"
        ),

        "nearest_office": (
            "🏦 *Yaqin filial*\n\n"
            "*{name}*\n"
            "📍 {address}\n"
            "📞 {phone}\n"
            "🕐 {hours}\n\n"
            "[📍 Yo'nalish]({maps_url})"
        ),

        "operator_wait": (
            "📞 *Operator so'rovingizni qabul qildi*\n\n"
            "Kutish vaqti: *2–5 daqiqa*.\n"
            "Operator shu chatda yozadi.\n\n"
            "Iltimos, aloqada bo'ling 🙏"
        ),

        "escalated": (
            "⚠️ *Murojaat yuqori mutaxassisga uzatildi*\n\n"
            "📋 Murojaat raqami: *{ticket_no}*\n\n"
            "Noqulaylik uchun uzr so'raymiz. "
            "Mutaxassis *15 daqiqa* ichida bog'lanadi."
        ),

        "operator_prefix": "👨‍💼 *Asia Alliance Bank operatori:*\n\n",
        "error_atm":     "❌ Bankomat topilmadi. QR-kodni qayta skanerlang.",
        "error_general": "❌ Xatolik yuz berdi. Keyinroq urinib ko'ring yoki operator chaqiring.",
    },

    # ==============================
    #  ENGLISH
    # ==============================
    "en": {
        "welcome": (
            "👋 Hello! You are at the ATM located at:\n"
            "📍 *{address}*\n\n"
            "I'm here to help you resolve any issue quickly. "
            "What happened?"
        ),
        "welcome_unknown": (
            "👋 Hello! I'm the Asia Alliance Bank assistant.\n\n"
            "How can I help you today?"
        ),
        "choose_lang":  "🌐 Choose your language:",
        "lang_saved":   "✅ Language set: English",

        "main_menu":    "📋 Main menu. What's the issue?",
        "btn_card":     "💳 Card problem",
        "btn_cash":     "💵 Cash not dispensed",
        "btn_office":   "📍 Nearest branch",
        "btn_operator": "📞 Call operator",
        "btn_back":     "◀️ Back",
        "btn_home":     "🏠 Home",
        "btn_no_help":  "⚠️ Issue not resolved",

        "card_held_menu": "💳 I understand this is stressful. What exactly happened with your card?",
        "btn_card_held":  "🔒 Card stuck in ATM",
        "btn_card_other": "❓ Other card issue",

        "card_step1": (
            "😔 *Don't worry — we'll sort this out together!*\n\n"
            "📋 *Step 1 of 3*\n\n"
            "Press the *Cancel* button on the ATM screen.\n"
            "⏱ Wait *30 seconds* — the ATM may return the card automatically.\n\n"
            "Did the card come out?"
        ),
        "btn_yes":      "✅ Yes, card returned",
        "btn_no":       "❌ No, it didn't",

        "card_step1_ok": (
            "🎉 *Great! Your card has been returned.*\n\n"
            "If you notice anything unusual during your next payment, "
            "we'd recommend temporarily blocking your card via the app as a precaution.\n\n"
            "Have a wonderful day! 😊"
        ),

        "card_step2": (
            "📋 *Step 2 of 3 — Protect your money*\n\n"
            "While your card is inside the ATM, it's important to block it immediately "
            "so no one else can use it.\n\n"
            "Open the *Asia Alliance Bank* app:\n"
            "1️⃣ Go to «Cards» → select your card\n"
            "2️⃣ Tap «Temporary Block»\n\n"
            "Have you blocked it?"
        ),
        "btn_blocked":  "🔐 Yes, card blocked",
        "btn_no_app":   "📵 I don't have the app",

        "card_step3": (
            "📋 *Step 3 of 3 — Collect your card at the branch*\n\n"
            "Don't worry — your card is safe. "
            "It's being held at the nearest branch for you.\n\n"
            "🏦 *{branch_name}*\n"
            "📍 {branch_address}\n"
            "📞 {branch_phone}\n"
            "🕐 {branch_hours}\n\n"
            "[📍 Get directions]({maps_url})\n\n"
            "🪪 Please bring your passport. Your card will be returned immediately."
        ),

        "no_cash_start": (
            "😔 *We completely understand how frustrating this is.*\n\n"
            "Don't worry — your money is safe and we'll document everything.\n\n"
            "📸 *Please do this right now:*\n"
            "• Take a photo of the ATM screen\n"
            "• Keep the receipt if the ATM printed one\n"
            "• Screenshot any bank notification\n"
            "• Wait 2–3 minutes — sometimes cash is dispensed with a delay\n\n"
            "💬 Please enter the amount (in UZS) the ATM failed to dispense.\n"
            "Example: *500000*"
        ),
        "no_cash_invalid": "❌ Please enter numbers only.\nExample: *500000*",
        "no_cash_confirm": (
            "📝 *Please confirm your request:*\n\n"
            "💰 Amount: *{amount:,.0f} UZS*\n"
            "🏧 ATM: {atm_id} — {address}\n"
            "🕐 Time: {time}\n\n"
            "Is everything correct? Shall I create the ticket?"
        ),
        "btn_confirm":  "✅ Yes, confirm",
        "btn_cancel":   "❌ Cancel",

        "ticket_created": (
            "✅ *Ticket Created!*\n\n"
            "📋 Reference number: *{ticket_no}*\n"
            "⏳ Processing time: *3 business days*\n\n"
            "Your money will be returned to your account automatically after verification.\n"
            "We'll notify you when the status changes. 🙏"
        ),

        "nearest_office": (
            "🏦 *Nearest Branch*\n\n"
            "*{name}*\n"
            "📍 {address}\n"
            "📞 {phone}\n"
            "🕐 {hours}\n\n"
            "[📍 Get directions]({maps_url})"
        ),

        "operator_wait": (
            "📞 *Your request has been received by an operator*\n\n"
            "Average wait time: *2–5 minutes*.\n"
            "The operator will message you right here in this chat.\n\n"
            "Please stay connected 🙏"
        ),

        "escalated": (
            "⚠️ *Your case has been escalated to a senior specialist*\n\n"
            "📋 Reference: *{ticket_no}*\n\n"
            "We sincerely apologize for the inconvenience. "
            "A specialist will contact you within *15 minutes*."
        ),

        "operator_prefix": "👨‍💼 *Asia Alliance Bank Operator:*\n\n",
        "error_atm":     "❌ ATM not found. Please scan the QR code again.",
        "error_general": "❌ Something went wrong. Please try again or call an operator.",
    }
}

def t(lang: str, key: str, **kwargs) -> str:
    """Get localized text."""
    lang = lang if lang in TEXTS else "ru"
    text = TEXTS[lang].get(key, TEXTS["ru"].get(key, key))
    return text.format(**kwargs) if kwargs else text
