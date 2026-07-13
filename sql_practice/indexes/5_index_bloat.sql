-- Monitor Index Bloat
/* Index bloat is when a database index grows much larger than it needs
to be because it contains unused or fragmented space.

This commonly happens in databases like PostgreSQL, MySQL, or Oracle 
Database after many INSERT, UPDATE, and DELETE operations.
*/

-- Check Index Size
SELECT
    relname,
    pg_size_pretty(pg_relation_size(indexrelid))
FROM pg_stat_user_indexes;

-- Find Largest Indexes
SELECT
    relname,
    pg_size_pretty(pg_total_relation_size(relid))
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Rebuild Bloated Indexes when indexes become bloated.

-- Reindex One Index
REINDEX INDEX sales_detail_pkey; 

-- Reindex Table
REINDEX TABLE sales_detail; -- The size of the table was reduced by almost 20%

REINDEX DATABASE coffee_shop;

-- Online Rebuild
REINDEX INDEX CONCURRENTLY sales_detail_pkey;
-- Avoids long blocking.