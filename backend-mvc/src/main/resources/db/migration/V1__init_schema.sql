-- ============================================================
-- V1__init_schema.sql
-- Driver and Rider — initial schema
-- DB: ride_booking_system (PostgreSQL)
-- ============================================================

-- ─── ENUMS ───────────────────────────────────────────────────

CREATE TYPE driver_status   AS ENUM ('ONLINE', 'OFFLINE', 'ON_TRIP');
CREATE TYPE trip_type       AS ENUM ('RIDE', 'DELIVERY');
CREATE TYPE delivery_type   AS ENUM ('EXPRESS', 'NORMAL');
CREATE TYPE trip_status     AS ENUM ('REQUESTED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');
CREATE TYPE payment_status  AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');
CREATE TYPE payment_method  AS ENUM ('CASH', 'CREDIT_CARD', 'DEBIT_CARD', 'WALLET');

-- ─── RIDERS ──────────────────────────────────────────────────

CREATE TABLE riders (
    id      BIGSERIAL       PRIMARY KEY,
    name    VARCHAR(255)    NOT NULL,
    email   VARCHAR(255)    NOT NULL UNIQUE,
    phone   VARCHAR(50)     NOT NULL,
    rating  DOUBLE PRECISION NOT NULL DEFAULT 5.0
);

-- ─── DRIVERS ─────────────────────────────────────────────────

CREATE TABLE drivers (
    id               BIGSERIAL        PRIMARY KEY,
    name             VARCHAR(255)     NOT NULL,
    email            VARCHAR(255)     NOT NULL UNIQUE,
    phone            VARCHAR(50)      NOT NULL,
    license_number   VARCHAR(100)     NOT NULL UNIQUE,
    vehicle_type     VARCHAR(100),
    vehicle_plate    VARCHAR(50),
    status           driver_status    NOT NULL DEFAULT 'OFFLINE',
    current_latitude  DOUBLE PRECISION,
    current_longitude DOUBLE PRECISION
);

-- ─── TRIPS ───────────────────────────────────────────────────

CREATE TABLE trips (
    id                   BIGSERIAL       PRIMARY KEY,
    rider_id             BIGINT          NOT NULL REFERENCES riders(id),
    driver_id            BIGINT          REFERENCES drivers(id),

    -- type
    trip_type            trip_type       NOT NULL,
    delivery_type        delivery_type,                      -- only when trip_type = DELIVERY

    -- delivery-specific
    package_description  TEXT,
    recipient_name       VARCHAR(255),
    recipient_phone      VARCHAR(50),

    -- locations
    pickup_latitude      DOUBLE PRECISION,
    pickup_longitude     DOUBLE PRECISION,
    pickup_address       VARCHAR(500),
    dropoff_latitude     DOUBLE PRECISION,
    dropoff_longitude    DOUBLE PRECISION,
    dropoff_address      VARCHAR(500),

    -- lifecycle
    status               trip_status     NOT NULL DEFAULT 'REQUESTED',
    requested_at         TIMESTAMP       NOT NULL DEFAULT NOW(),
    accepted_at          TIMESTAMP,
    started_at           TIMESTAMP,
    completed_at         TIMESTAMP,

    -- financials
    fare_amount          DOUBLE PRECISION,
    distance_km          DOUBLE PRECISION,

    -- constraint: delivery_type required when trip_type = DELIVERY
    CONSTRAINT chk_delivery_type CHECK (
        trip_type <> 'DELIVERY' OR delivery_type IS NOT NULL
    )
);

-- ─── PAYMENTS ────────────────────────────────────────────────

CREATE TABLE payments (
    id                      BIGSERIAL       PRIMARY KEY,
    trip_id                 BIGINT          NOT NULL UNIQUE REFERENCES trips(id),
    amount                  DOUBLE PRECISION,
    currency                VARCHAR(10)     NOT NULL DEFAULT 'USD',
    status                  payment_status  NOT NULL DEFAULT 'PENDING',
    method                  payment_method,
    transaction_reference   VARCHAR(255)    UNIQUE,
    processed_at            TIMESTAMP
);

-- ─── INDEXES ─────────────────────────────────────────────────

-- riders
CREATE INDEX idx_riders_email ON riders(email);

-- drivers
CREATE INDEX idx_drivers_email  ON drivers(email);
CREATE INDEX idx_drivers_status ON drivers(status);

-- trips
CREATE INDEX idx_trips_rider_id   ON trips(rider_id);
CREATE INDEX idx_trips_driver_id  ON trips(driver_id);
CREATE INDEX idx_trips_status     ON trips(status);
CREATE INDEX idx_trips_trip_type  ON trips(trip_type);
CREATE INDEX idx_trips_rider_type ON trips(rider_id, trip_type);  -- GET /riders/{id}/trips?tripType=

-- payments
CREATE INDEX idx_payments_trip_id ON payments(trip_id);
CREATE INDEX idx_payments_status  ON payments(status);
