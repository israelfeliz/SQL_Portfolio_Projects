-- Index usage monitoring. 
/*Review idx_scan to check how often the index is used and 
depending on the type of index, you decide to delete it or keep it.*/

SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan,
	last_idx_scan,
	idx_tup_read,
	idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan;

-- Check unused indexes only
SELECT
    indexrelname,
    idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0;

-- Check Index Size
SELECT
    indexrelname,
    pg_size_pretty(pg_relation_size(indexrelid))
FROM pg_stat_user_indexes;
