-- ============================================================
-- V3__add_settlement_evidence_files.sql
-- Adds join table for Settlement.evidenceFiles @ElementCollection
-- ============================================================

CREATE TABLE settlement_evidence_files (
    settlement_id   BIGINT          NOT NULL REFERENCES settlements(id) ON DELETE CASCADE,
    file_url        VARCHAR(500)    NOT NULL
);

CREATE INDEX idx_settlement_evidence ON settlement_evidence_files(settlement_id);
