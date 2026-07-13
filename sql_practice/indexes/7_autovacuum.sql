/*Autovacuum and Index Health

Autovacuum prevents:

Table bloat
Index bloat
Outdated statistics

Check: */

SELECT 
	relname AS table_name,
	last_autovacuum,
	last_autoanalyze
FROM pg_stat_user_tables;



