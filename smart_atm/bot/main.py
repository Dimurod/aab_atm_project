# bot/main.py
"""
Smart ATM Assistant — Telegram Bot
Asia Alliance Bank
 
Run locally:   python -m bot.main
Run in Docker: see docker-compose.yml
"""
import asyncio
import logging
import os
import random
import aiohttp
from datetime import datetime
 
from aiogram import Bot, Dispatcher
from aiogram.enums import ParseMode
from aiogram.fsm.storage.memory import MemoryStorage
from aiogram.client.default import DefaultBotProperties
 
from bot.config import BOT_TOKEN, WEBHOOK_PATH, WEBHOOK_URL
from bot.database import get_pool, close_pool
from bot.handlers import start, card_flow, cash_flow, misc
 
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s"
)
logger = logging.getLogger(__name__)
 
 
# ── ATM SIMULATOR ────────────────────────────────────────────────────
SMART_ATM_API = os.getenv("API_BASE_URL", "https://smart-atm-backend.onrender.com")
ATM_PING_SECRET = os.getenv("ATM_PING_SECRET", "atm_secret_2026")
ATM_SIMULATOR_INTERVAL = int(os.getenv("ATM_SIM_INTERVAL", "300"))  # 5 минут
 
# Начальные состояния 10 банкоматов
ATM_STATES = {
    "MU-001": {"cash": 45, "paper": 31, "online": True,  "card_jam": False},
    "MU-002": {"cash": 87, "paper": 35, "online": True,  "card_jam": False},
    "MU-003": {"cash": 91, "paper": 61, "online": True,  "card_jam": False},
    "MU-004": {"cash": 82, "paper": 69, "online": True,  "card_jam": False},
    "MU-005": {"cash": 81, "paper": 69, "online": True,  "card_jam": False},
    "MU-006": {"cash": 88, "paper": 83, "online": True,  "card_jam": False},
    "MU-007": {"cash": 41, "paper": 84, "online": True,  "card_jam": False},
    "MU-008": {"cash": 80, "paper": 71, "online": True,  "card_jam": False},
    "MU-009": {"cash": 44, "paper": 41, "online": True,  "card_jam": False},
    "MU-010": {"cash": 87, "paper": 85, "online": True,  "card_jam": False},
}
 
def simulate_atm_changes():
    """Реалистично меняем данные каждые 5 минут."""
    hour = datetime.now().hour
    for atm_id, s in ATM_STATES.items():
        # Наличные: активнее снижаются днём
        if 9 <= hour <= 20:
            s["cash"] = max(0, s["cash"] - random.randint(1, 3))
        else:
            s["cash"] = max(0, s["cash"] - random.randint(0, 1))
 
        # Бумага снижается медленнее
        s["paper"] = max(0, s["paper"] - random.randint(0, 2))
 
        # 2% шанс офлайн
        if random.random() < 0.02:
            s["online"] = False
        elif not s["online"] and random.random() < 0.5:
            s["online"] = True  # восстановился
 
        # 1% шанс card jam
        if random.random() < 0.01:
            s["card_jam"] = True
        elif s["card_jam"] and random.random() < 0.7:
            s["card_jam"] = False
 
        # Авто-инкассация если наличные < 5%
        if s["cash"] < 5 and random.random() < 0.3:
            s["cash"] = random.randint(80, 95)
            logger.info(f"💰 Симулятор: инкассация {atm_id} → {s['cash']}%")
 
        # Авто-замена ленты если < 3%
        if s["paper"] < 3 and random.random() < 0.5:
            s["paper"] = random.randint(85, 100)
            logger.info(f"🧾 Симулятор: замена ленты {atm_id} → {s['paper']}%")
 
 
async def ping_one_atm(session: aiohttp.ClientSession, atm_id: str, state: dict):
    """Отправляем один пинг на Smart ATM backend."""
    try:
        payload = {
            "atm_id":      atm_id,
            "cash_level":  state["cash"],
            "paper_level": state["paper"],
            "is_online":   state["online"],
            "card_jam":    state["card_jam"],
            "secret":      ATM_PING_SECRET,
        }
        async with session.post(
            f"{SMART_ATM_API}/api/monitoring/ping",
            json=payload,
            timeout=aiohttp.ClientTimeout(total=10)
        ) as resp:
            result = await resp.json()
            if result.get("auto_tickets"):
                logger.warning(f"🤖 Авто-заявка: {result['auto_tickets']} | {atm_id}")
            return True
    except Exception as e:
        logger.error(f"Ping error {atm_id}: {e}")
        return False
 
 
async def atm_simulator_loop():
    """Фоновая задача — каждые 5 минут пингует backend."""
    logger.info("🏧 ATM Simulator запущен!")
    # Первый пинг через 30 секунд после старта
    await asyncio.sleep(30)
 
    while True:
        try:
            simulate_atm_changes()
            async with aiohttp.ClientSession() as session:
                tasks = [
                    ping_one_atm(session, atm_id, state)
                    for atm_id, state in ATM_STATES.items()
                ]
                results = await asyncio.gather(*tasks, return_exceptions=True)
                ok = sum(1 for r in results if r is True)
                logger.info(f"📡 ATM Simulator: {ok}/{len(ATM_STATES)} пингов отправлено")
        except Exception as e:
            logger.error(f"Simulator error: {e}")
 
        await asyncio.sleep(ATM_SIMULATOR_INTERVAL)
 
 
# ── BOT LIFECYCLE ─────────────────────────────────────────────────────
 
async def on_startup(bot: Bot):
    await get_pool()
    logger.info("✅ Database pool created")
 
    if WEBHOOK_URL:
        await bot.set_webhook(f"{WEBHOOK_URL}{WEBHOOK_PATH}")
        logger.info(f"✅ Webhook set: {WEBHOOK_URL}{WEBHOOK_PATH}")
    else:
        await bot.delete_webhook(drop_pending_updates=True)
        logger.info("✅ Polling mode (no webhook)")
 
    # Запускаем симулятор как фоновую задачу
    asyncio.create_task(atm_simulator_loop())
    logger.info("🏧 ATM Simulator task created")
 
 
async def on_shutdown(bot: Bot):
    await close_pool()
    logger.info("🛑 Database pool closed")
    if WEBHOOK_URL:
        await bot.delete_webhook()
 
 
async def main():
    if not BOT_TOKEN:
        raise ValueError("BOT_TOKEN is not set in .env")
 
    bot = Bot(
        token=BOT_TOKEN,
        default=DefaultBotProperties(parse_mode=ParseMode.MARKDOWN)
    )
 
    storage = MemoryStorage()
    dp = Dispatcher(storage=storage)
 
    dp.startup.register(on_startup)
    dp.shutdown.register(on_shutdown)
 
    dp.include_router(start.router)
    dp.include_router(card_flow.router)
    dp.include_router(cash_flow.router)
    dp.include_router(misc.router)
 
    if WEBHOOK_URL:
        from aiohttp import web
        from aiogram.webhook.aiohttp_server import SimpleRequestHandler, setup_application
 
        app = web.Application()
        handler = SimpleRequestHandler(dispatcher=dp, bot=bot)
        handler.register(app, path=WEBHOOK_PATH)
        setup_application(app, dp, bot=bot)
 
        runner = web.AppRunner(app)
        await runner.setup()
        site = web.TCPSite(runner, host="0.0.0.0", port=int(os.getenv("PORT", 8080)))
        await site.start()
        logger.info("🚀 Webhook server started on port 8080")
        await asyncio.Event().wait()
    else:
        logger.info("🚀 Starting polling...")
        await dp.start_polling(bot, allowed_updates=dp.resolve_used_update_types())
 
 
if __name__ == "__main__":
    asyncio.run(main())
 