# bot/main.py
"""
Smart ATM Assistant — Telegram Bot
Asia Alliance Bank

Run locally:   python -m bot.main
Run in Docker: see docker-compose.yml
"""
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
 
 
async def on_startup(bot: Bot):
    await get_pool()
    logger.info("✅ Database pool created")
 
    if WEBHOOK_URL:
        await bot.set_webhook(f"{WEBHOOK_URL}{WEBHOOK_PATH}")
        logger.info(f"✅ Webhook set: {WEBHOOK_URL}{WEBHOOK_PATH}")
    else:
        await bot.delete_webhook(drop_pending_updates=True)
        logger.info("✅ Polling mode (no webhook)")
 
 
async def on_shutdown(bot: Bot):
    await close_pool()
    logger.info("🛑 Database pool closed")
    if WEBHOOK_URL:
        await bot.delete_webhook()
 
 
async def main():
    if not BOT_TOKEN:
        raise ValueError("BOT_TOKEN is not set in .env")
 
    # Bot instance
    bot = Bot(
        token=BOT_TOKEN,
        default=DefaultBotProperties(parse_mode=ParseMode.MARKDOWN)
    )
 
    # FSM storage (Memory — no external dependencies needed for demo)
    storage = MemoryStorage()
    dp = Dispatcher(storage=storage)
 
    # Register lifecycle hooks
    dp.startup.register(on_startup)
    dp.shutdown.register(on_shutdown)
 
    # Register routers (order matters)
    dp.include_router(start.router)
    dp.include_router(card_flow.router)
    dp.include_router(cash_flow.router)
    dp.include_router(misc.router)
 
    if WEBHOOK_URL:
        # Production: webhook mode via aiohttp
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
 
        # Keep running
        await asyncio.Event().wait()
    else:
        # Development: long polling
        logger.info("🚀 Starting polling...")
        await dp.start_polling(bot, allowed_updates=dp.resolve_used_update_types())
 
 
if __name__ == "__main__":
    asyncio.run(main())
 