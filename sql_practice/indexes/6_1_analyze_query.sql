-- Monitor Index Hit Ratio / Goal: 95%+
-- Measure how often PostgreSQL uses cache.
-- Database Cache Hit Ratio
SELECT
sum(blks_hit) /
(sum(blks_hit)+sum(blks_read)) * 100
AS hit_ratio
FROM pg_stat_database;

