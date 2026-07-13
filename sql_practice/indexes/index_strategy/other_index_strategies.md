## Monitor Index Hit Ratio / Goal: 95%+

Measure how often PostgreSQL uses cache.

Database Cache Hit Ratio

SELECT
sum(blks_hit) /
(sum(blks_hit)+sum(blks_read)) * 100
AS hit_ratio
FROM pg_stat_database;

## Create Covering Indexes

PostgreSQL supports INCLUDE.

CREATE INDEX idx_transaction_customer
ON sales_transaction(customer_id)
INCLUDE(transaction_date,transaction_total);

-- Allows to use Index Only Scan.

EXPLAIN ANALYZE
SELECT customer_id,
       transaction_date,
       transaction_total
FROM sales_transaction
WHERE customer_id = 100;

-- Monitor Index-Only Scans: Good indicator of healthy indexing.
-- Look for:

-- Index Only Scan

## Autovacuum and Index Health

Autovacuum prevents:

Table bloat
Index bloat
Outdated statistics

Check:

SELECT 
	last_autovacuum,
	last_autoanalyze
FROM pg_stat_user_tables;



