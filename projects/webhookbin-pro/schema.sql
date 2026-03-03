-- WebhookBin Pro Database Schema
-- Run with: wrangler d1 execute webhookbin-pro --file=schema.sql

-- Endpoints table (each user gets unique endpoints)
CREATE TABLE IF NOT EXISTS endpoints (
    id TEXT PRIMARY KEY,
    name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    request_count INTEGER DEFAULT 0,
    last_request_at DATETIME
);

-- Requests table (stores all incoming webhook requests)
CREATE TABLE IF NOT EXISTS requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    endpoint_id TEXT NOT NULL,
    method TEXT NOT NULL,
    path TEXT,
    query_string TEXT,
    headers TEXT, -- JSON string
    body TEXT,
    content_type TEXT,
    ip_address TEXT,
    user_agent TEXT,
    received_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (endpoint_id) REFERENCES endpoints(id)
);

-- Index for fast endpoint lookups
CREATE INDEX IF NOT EXISTS idx_requests_endpoint ON requests(endpoint_id);
CREATE INDEX IF NOT EXISTS idx_requests_received ON requests(received_at DESC);
