-- ============================================================
-- V4__add_trip_activities.sql
-- Adds driver-arrival tracking and a full activity log per trip
-- ============================================================

-- ─── arrived_at on trips ────────────────────────────────────
-- Records when the driver physically arrives at the pickup point
-- (separate from IN_PROGRESS which marks the moment the trip starts)

ALTER TABLE trips ADD COLUMN IF NOT EXISTS arrived_at TIMESTAMP;

-- ─── trip_activities ────────────────────────────────────────
-- Immutable audit log of every significant event on a trip.
-- activity_type values:
--   TRIP_REQUESTED, TRIP_ACCEPTED, DRIVER_ARRIVED,
--   TRIP_STARTED, TRIP_COMPLETED, TRIP_CANCELLED
-- performed_by_role values: RIDER, DRIVER, SYSTEM

CREATE TABLE IF NOT EXISTS trip_activities (
    id                  BIGSERIAL       PRIMARY KEY,
    trip_id             BIGINT          NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    activity_type       VARCHAR(50)     NOT NULL,
    performed_by_id     BIGINT,                          -- nullable (SYSTEM events have no actor)
    performed_by_role   VARCHAR(20)     NOT NULL DEFAULT 'SYSTEM',
    performed_by_name   VARCHAR(255),
    note                TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_trip_activities_trip_id ON trip_activities(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_activities_type    ON trip_activities(activity_type);
