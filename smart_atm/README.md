# 🏧 Smart ATM Assistant — Asia Alliance Bank

Telegram-бот + FastAPI бэкенд для мгновенной поддержки клиентов у банкоматов.

## Быстрый старт

### 1. Клонировать и настроить окружение
```bash
cp .env.example .env
# Заполните .env: BOT_TOKEN, DATABASE_URL, REDIS_URL, GOOGLE_MAPS_API_KEY
```

### 2. Запустить через Docker (рекомендуется)
```bash
docker-compose up -d
```

### 3. Или запустить локально
```bash
pip install -r requirements.txt

# Применить схему БД
psql -U postgres -d smart_atm -f db/schema.sql

# Запустить бота
python -m bot.main

# В отдельном терминале — API
uvicorn backend.main:app --reload --port 8000
```

## Структура проекта

```
smart_atm/
├── bot/
│   ├── main.py              # Точка входа бота
│   ├── config.py            # Конфигурация + все строки локализации (ru/uz/en)
│   ├── database.py          # Все запросы к PostgreSQL
│   ├── utils.py             # Google Maps, форматирование
│   ├── webhooks.py          # Уведомления в Админ-панель
│   ├── handlers/
│   │   ├── start.py         # /start + Deep Linking + выбор языка
│   │   ├── card_flow.py     # Алгоритм «Карта удержана» (3 шага)
│   │   ├── cash_flow.py     # Алгоритм «Невыдача наличных»
│   │   └── misc.py          # Офис, оператор, навигация, эскалация
│   └── keyboards/
│       └── inline.py        # Все inline-кнопки
├── backend/
│   └── main.py              # FastAPI: webhook, WebSocket, Admin API
├── db/
│   └── schema.sql           # PostgreSQL схема + seed данные
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
└── .env.example
```

## Deep Linking (QR-код)

Каждый QR-код на банкомате содержит ссылку:
```
https://t.me/AAB_Support_Bot?start=ID4582
```

При сканировании бот автоматически определяет адрес банкомата
и приветствует клиента с адресом устройства.

## Admin API

| Endpoint | Метод | Описание |
|---|---|---|
| `/api/tickets` | GET | Список активных заявок |
| `/api/tickets/{id}/status` | PATCH | Обновить статус заявки |
| `/api/atms` | GET | Все банкоматы (для карты) |
| `/api/operator/send` | POST | Отправить сообщение клиенту |
| `/ws/admin` | WebSocket | Real-time события в дашборд |
| `/health` | GET | Health check |

## Webhook события (бот → дашборд)

| Событие | Триггер |
|---|---|
| `new_ticket` | Создана новая заявка |
| `operator_request` | Клиент нажал «Связаться с оператором» |
| `escalation` | Клиент нажал «Помощь не получена» → **красная метка** |
