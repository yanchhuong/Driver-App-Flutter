-- ============================================================
-- V2__add_company_user_settlement_chat.sql
-- Adds: companies, app_users, settlements, chat tables
-- ============================================================

-- ─── ENUMS ───────────────────────────────────────────────────

CREATE TYPE user_role       AS ENUM ('ADMIN', 'MANAGER', 'DRIVER', 'USER');
CREATE TYPE user_type       AS ENUM ('CUSTOMER', 'EMPLOYEE');
CREATE TYPE user_status     AS ENUM ('ACTIVE', 'INACTIVE', 'PENDING');
CREATE TYPE settlement_status AS ENUM ('PENDING', 'PAID', 'FAILED', 'REFUNDED');
CREATE TYPE chat_type       AS ENUM ('DIRECT', 'TRIP', 'SUPPORT');
CREATE TYPE message_type    AS ENUM ('TEXT', 'IMAGE', 'FILE', 'SYSTEM');

-- ─── COMPANIES ───────────────────────────────────────────────

CREATE TABLE companies (
    id                  BIGSERIAL       PRIMARY KEY,
    company_name        VARCHAR(255)    NOT NULL,
    company_key         VARCHAR(100)    NOT NULL UNIQUE,    -- normalized slug e.g. "acme-logistics"
    address             VARCHAR(500),
    phone               VARCHAR(50),
    email               VARCHAR(255),
    logo_url            VARCHAR(500),
    currency            VARCHAR(10)     NOT NULL DEFAULT 'USD',
    default_branch_id   VARCHAR(100),
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ─── APP USERS ───────────────────────────────────────────────
-- General user table covering: admin, manager, driver accounts, customers, employees.
-- Named app_users to avoid conflict with PostgreSQL reserved word "user".

CREATE TABLE app_users (
    id              BIGSERIAL       PRIMARY KEY,
    name            VARCHAR(255)    NOT NULL,
    email           VARCHAR(255)    NOT NULL UNIQUE,
    phone           VARCHAR(50),
    role            user_role       NOT NULL DEFAULT 'USER',
    user_type       user_type,                              -- only when role = USER
    company_id      BIGINT          REFERENCES companies(id),
    branch_id       VARCHAR(100),
    status          user_status     NOT NULL DEFAULT 'ACTIVE',
    verified        BOOLEAN         NOT NULL DEFAULT FALSE,
    profile_image   VARCHAR(500),
    created_by      BIGINT          REFERENCES app_users(id),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT NOW(),

    -- employee must belong to a company
    CONSTRAINT chk_employee_company CHECK (
        user_type <> 'EMPLOYEE' OR company_id IS NOT NULL
    )
);

-- Back-fill company owner (manager_id) now that app_users exists
ALTER TABLE companies
    ADD COLUMN manager_id BIGINT REFERENCES app_users(id);

-- ─── SETTLEMENTS ─────────────────────────────────────────────
-- Financial settlement paid to a driver after a trip is completed.

CREATE TABLE settlements (
    id              BIGSERIAL           PRIMARY KEY,
    trip_id         BIGINT              NOT NULL REFERENCES trips(id),
    driver_id       BIGINT              NOT NULL REFERENCES drivers(id),
    company_id      BIGINT              REFERENCES companies(id),
    branch_id       VARCHAR(100),
    amount          DOUBLE PRECISION    NOT NULL,
    currency        VARCHAR(10)         NOT NULL DEFAULT 'USD',
    status          settlement_status   NOT NULL DEFAULT 'PENDING',
    method          payment_method,                         -- reuse enum from V1
    note            TEXT,
    evidence_files  TEXT[],                                 -- array of file URLs
    created_by      BIGINT              REFERENCES app_users(id),
    paid_at         TIMESTAMP,
    created_at      TIMESTAMP           NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP           NOT NULL DEFAULT NOW()
);

-- ─── CHAT CONVERSATIONS ──────────────────────────────────────

CREATE TABLE chat_conversations (
    id                      BIGSERIAL   PRIMARY KEY,
    type                    chat_type   NOT NULL DEFAULT 'DIRECT',
    trip_id                 BIGINT      REFERENCES trips(id),       -- optional: link chat to a trip
    company_id              BIGINT      REFERENCES companies(id),
    branch_id               VARCHAR(100),
    last_message_id         BIGINT,                                 -- FK added after chat_messages
    last_message_preview    VARCHAR(500),
    last_message_at         TIMESTAMP,
    created_at              TIMESTAMP   NOT NULL DEFAULT NOW()
);

-- ─── CHAT MESSAGES ───────────────────────────────────────────

CREATE TABLE chat_messages (
    id                  BIGSERIAL       PRIMARY KEY,
    conversation_id     BIGINT          NOT NULL REFERENCES chat_conversations(id),
    sender_id           BIGINT          NOT NULL REFERENCES app_users(id),
    sender_name         VARCHAR(255)    NOT NULL,
    sender_role         user_role       NOT NULL,
    content             TEXT            NOT NULL,
    type                message_type    NOT NULL DEFAULT 'TEXT',
    attachment_url      VARCHAR(500),
    deleted             BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- Back-fill last_message_id FK now that chat_messages exists
ALTER TABLE chat_conversations
    ADD CONSTRAINT fk_last_message
    FOREIGN KEY (last_message_id) REFERENCES chat_messages(id);

-- ─── CHAT PARTICIPANTS ───────────────────────────────────────

CREATE TABLE chat_participants (
    conversation_id     BIGINT      NOT NULL REFERENCES chat_conversations(id),
    user_id             BIGINT      NOT NULL REFERENCES app_users(id),
    last_read_at        TIMESTAMP,
    muted               BOOLEAN     NOT NULL DEFAULT FALSE,
    joined_at           TIMESTAMP   NOT NULL DEFAULT NOW(),
    PRIMARY KEY (conversation_id, user_id)
);

-- ─── INDEXES ─────────────────────────────────────────────────

-- companies
CREATE INDEX idx_companies_key          ON companies(company_key);
CREATE INDEX idx_companies_manager      ON companies(manager_id);

-- app_users
CREATE INDEX idx_app_users_email        ON app_users(email);
CREATE INDEX idx_app_users_role         ON app_users(role);
CREATE INDEX idx_app_users_company      ON app_users(company_id);
CREATE INDEX idx_app_users_company_role ON app_users(company_id, role);   -- list users per company by role

-- settlements
CREATE INDEX idx_settlements_trip       ON settlements(trip_id);
CREATE INDEX idx_settlements_driver     ON settlements(driver_id);
CREATE INDEX idx_settlements_company    ON settlements(company_id);
CREATE INDEX idx_settlements_status     ON settlements(status);

-- chat
CREATE INDEX idx_chat_conv_trip         ON chat_conversations(trip_id);
CREATE INDEX idx_chat_conv_company      ON chat_conversations(company_id);
CREATE INDEX idx_chat_msg_conversation  ON chat_messages(conversation_id);
CREATE INDEX idx_chat_msg_sender        ON chat_messages(sender_id);
CREATE INDEX idx_chat_part_user         ON chat_participants(user_id);
