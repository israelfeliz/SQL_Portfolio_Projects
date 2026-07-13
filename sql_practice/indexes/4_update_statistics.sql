-- Update Statistics
/* PostgreSQL optimizer relies heavily on statistics.
Bad statistics = bad execution plans.*/

-- Check Statistics Age
SELECT
    relname,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables;

ANALYZE customer; -- Analyze one table

ANALYZE; -- Analyze the whole database

-- Updates statistics and cleans dead tuples.

VACUUM ANALYZE customer; 

VACUUM ANALYZE; -- Whole Database