-- Find Expensive Queries

-- Enable: shared_preload_libraries='pg_stat_statements'
-- 1. In psql: SHOW config_file  
-- 2. Result: /etc/postgresql/18/main/postgresql.conf
-- 3. Open the file(Bash): sudo nano /etc/postgresql/18/main/postgresql.conf
-- 4. Add or modify(file): shared_preload_libraries='pg_stat_statements'
-- 5. Restart postgresql(Bash): sudo systemctl restart postgresql
-- 6. Create extension(SQL): CREATE EXTENSION pg_stat_statements;

-- Top expensive queries:
SELECT
	query,
	calls,
	total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Most frequently executed queries:

SELECT
    query,
    calls
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;
