-- ============================================
--  Smart ATM Assistant — PostgreSQL Schema
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ATM Devices
CREATE TABLE atm_devices (
    atm_id        VARCHAR(20)  PRIMARY KEY,
    address       TEXT         NOT NULL,
    latitude      FLOAT8       NOT NULL,
    longitude     FLOAT8       NOT NULL,
    device_type   VARCHAR(50)  DEFAULT 'Unknown',
    status        VARCHAR(20)  DEFAULT 'Online' CHECK (status IN ('Online', 'Offline', 'Maintenance')),
    branch_id     INTEGER,
    installed_at  TIMESTAMP    DEFAULT NOW()
);

-- Bank Branches
CREATE TABLE branches (
    id          SERIAL PRIMARY KEY,
    name        TEXT    NOT NULL,
    address     TEXT    NOT NULL,
    latitude    FLOAT8  NOT NULL,
    longitude   FLOAT8  NOT NULL,
    phone       VARCHAR(30),
    working_hours TEXT  DEFAULT '09:00–18:00'
);

-- Users (Telegram)
CREATE TABLE users (
    telegram_id   BIGINT       PRIMARY KEY,
    language      VARCHAR(5)   DEFAULT 'ru' CHECK (language IN ('ru', 'uz', 'en')),
    first_name    TEXT,
    username      TEXT,
    created_at    TIMESTAMP    DEFAULT NOW(),
    last_seen     TIMESTAMP    DEFAULT NOW()
);

-- Sequence for ticket numbers (Переместили сюда)
CREATE SEQUENCE IF NOT EXISTS ticket_seq START 1000;

-- Tickets / Заявки
CREATE TABLE tickets (
    id            SERIAL       PRIMARY KEY,
    ticket_no     VARCHAR(10)  UNIQUE NOT NULL DEFAULT ('T' || LPAD(nextval('ticket_seq')::TEXT, 4, '0')),
    telegram_id   BIGINT       REFERENCES users(telegram_id),
    atm_id        VARCHAR(20)  REFERENCES atm_devices(atm_id),
    category      VARCHAR(30)  NOT NULL CHECK (category IN ('card_held', 'no_cash', 'other')),
    amount        NUMERIC(15,2),
    status        VARCHAR(20)  DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'escalated')),
    description   TEXT,
    operator_id   BIGINT,
    escalated     BOOLEAN      DEFAULT FALSE,
    created_at    TIMESTAMP    DEFAULT NOW(),
    updated_at    TIMESTAMP    DEFAULT NOW()
);

-- Sessions (FSM state storage)
CREATE TABLE sessions (
    telegram_id   BIGINT      PRIMARY KEY REFERENCES users(telegram_id) ON DELETE CASCADE,
    state         TEXT,
    data          JSONB       DEFAULT '{}',
    atm_id        VARCHAR(20),
    updated_at    TIMESTAMP   DEFAULT NOW()
);

-- Audit log for admin actions
CREATE TABLE audit_log (
    id          SERIAL    PRIMARY KEY,
    operator_id BIGINT    NOT NULL,
    action      TEXT      NOT NULL,
    target_id   TEXT,
    meta        JSONB     DEFAULT '{}',
    created_at  TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_tickets_status    ON tickets(status);
CREATE INDEX idx_tickets_atm       ON tickets(atm_id);
CREATE INDEX idx_tickets_telegram  ON tickets(telegram_id);
CREATE INDEX idx_tickets_created   ON tickets(created_at DESC);

-- Seed data
INSERT INTO branches (name, address, latitude, longitude, phone) VALUES
  ('Главный офис — Юнусабад',    'ул. Амира Темура, 107Б',    41.3375, 69.2925, '+998 71 200-30-00'),
  ('Офис — Мирзо-Улугбек',       'ул. Мирзо-Улугбека, 53',    41.3251, 69.3128, '+998 71 200-30-01'),
  ('Офис — Чиланзар',             'ул. Чиланзарская, 12',      41.2869, 69.2108, '+998 71 200-30-02');

INSERT INTO atm_devices (atm_id, address, latitude, longitude, device_type, branch_id) VALUES
  ('ID4582', 'ул. Тараса Шевченко, 2',   41.2995, 69.2401, 'NCR SelfServ 87', 1),
  ('ID4583', 'ул. Амира Темура, 107Б',   41.3375, 69.2925, 'Diebold Nixdorf', 1),
  ('ID4584', 'ул. Мирзо-Улугбека, 53',   41.3251, 69.3128, 'NCR SelfServ 87', 2),
  ('ID4585', 'ул. Чиланзарская, 12',     41.2869, 69.2108, 'Wincor Nixdorf',  3);