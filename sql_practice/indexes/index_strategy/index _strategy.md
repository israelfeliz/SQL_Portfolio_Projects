# 1 Initial Indexing Strategy

## OLTP Systems (Transaction Processing)

Goal: Optimize writes while maintaining fast lookups.

Create indexes on:

Primary Keys
Foreign Keys
Frequently searched columns
Frequently joined columns

## OLAP Systems (Analytics)

Goal: Optimize reads.

PostgreSQL doesn't have SQL Server clustered indexes, but I can use:

Partitioning
Materialized Views
BRIN Indexes for huge tables
Columnar extensions (e.g. Citus Columnar)

Example:

CREATE INDEX idx_sales_brin
ON sales_transaction
USING BRIN(transaction_date);

Best for:

Billions of rows
Time-series data
Data warehouses

# 2 Usage Pattern Indexing

## Step 1: Identify Frequently Used Tables

SELECT
    relname AS table_name,
    seq_scan,
    idx_scan
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;

If:
seq_scan > idx_scan, investigate indexing opportunities.

I noticed I have to think about a good indexes strategy on the tables:
product, staff and sales_details.

## Step 2: Find Frequently Used Columns

SELECT userid, calls, query 
FROM pg_stat_statements
ORDER BY calls DESC;

## Step 3: Choose the Right Index

Query Pattern	        PostgreSQL Index
Equality (=)        	B-tree
Range (>, <, BETWEEN)	B-tree
LIKE 'abc%'         	B-tree
Full Text Search	    GIN
JSONB	                GIN
Arrays	                GIN
Geographic	            GiST
Huge Time-Series	    BRIN
Complex Types	        GiST/SP-GiST

## Step 4: Test the Index

Before:

EXPLAIN ANALYZE
SELECT *
FROM customer
WHERE city='New York';

Output:

Seq Scan

After creating index:

CREATE INDEX idx_customer_city
ON customer(city);

Run again:

EXPLAIN ANALYZE
SELECT *
FROM customer
WHERE city='New York';

Output:

Index Scan

# 3 Scenario-Based Indexing

## Identify Slow Queries

-- Top expensive queries:
SELECT
	userid,
    query,
	calls,
	total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Most frequently executed queries:
SELECT
    userid,
    query,
    calls,
    total_exec_time
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 20;

## Check Execution Plan

-- Basic
EXPLAIN
SELECT *
FROM sales_transaction
WHERE customer_id = 100;

-- Real Execution
EXPLAIN ANALYZE
SELECT *
FROM sales_transaction
WHERE customer_id = 100;

-- Detailed Plan
EXPLAIN
(ANALYZE, BUFFERS)
SELECT *
FROM sales_transaction
WHERE customer_id = 100;

## Choose right index 

Query Pattern	        PostgreSQL Index
Equality (=)        	B-tree
Range (>, <, BETWEEN)	B-tree
LIKE 'abc%'         	B-tree
Full Text Search	    GIN
JSONB	                GIN
Arrays	                GIN
Geographic	            GiST
Huge Time-Series	    BRIN
Complex Types	        GiST/SP-GiST

## Test and Compare execution plans

-- Evaluate queries and see if indexes are being used:

EXPLAIN ANALYZE
SELECT *
FROM sales_transaction
WHERE customer_id = 100;

Bad sign: Seq Scan on sales_transaction
Good sign:Index Scan using idx_transsales_customer

# 4 Monitoring & Maintenance

## Monitor Index Usage
-- Index usage monitoring. 
Review idx_scan to check how often the index is used and 
depending on the type of index, you decide to delete it or keep it.

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

## Monitor Missing Indexes

-- Detect Sequential Scans

SELECT
    relname AS table_name,
    seq_scan,
    idx_scan
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;

If:
seq_scan > idx_scan
investigate indexing opportunities.

-- Evaluate queries and see if indexes are being used:

EXPLAIN ANALYZE
SELECT *
FROM sales_transaction
WHERE customer_id = 100;

Bad sign: Seq Scan on orders
Good sign:Index Scan using idx_customer

## Monitor Duplicate Indexes

-- Detect Duplicates
SELECT
    t.relname AS table_name,
    i.relname AS index_name,
    pg_get_indexdef(i.oid) AS index_definition
FROM pg_class t
JOIN pg_index ix ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
WHERE t.relkind = 'r' AND t.relname NOT LIKE 'pg_%'
ORDER BY t.relname;

-- This may be difficult on big datasets
-- since we have to review the indexes manually 

-- More advanced: This will return only duplicate indexes.

WITH indexes AS (
    SELECT
        indrelid,
        indexrelid,
        indkey
    FROM pg_index
)
SELECT *
FROM indexes i1
JOIN indexes i2
ON i1.indrelid = i2.indrelid
AND i1.indkey = i2.indkey
AND i1.indexrelid <> i2.indexrelid;

-- Drop duplicate, make sure not to delete the primary key.

DROP INDEX duplicate_customer_id;

## Update Statistics

PostgreSQL uses AUTOVACUUM.

PostgreSQL optimizer relies heavily on statistics.
Bad statistics = bad execution plans.

-- Check Statistics Age
SELECT
    relname,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables;

ANALYZE customer; -- Update statistics on one table

ANALYZE; -- Update statistics on the whole database

-- Updates statistics and cleans dead tuples.

VACUUM ANALYZE customer; 

VACUUM ANALYZE; -- Whole Database

## Monitor Index Bloat

Index bloat is when a database index grows much larger than it needs
to be because it contains unused or fragmented space.

This commonly happens in databases like PostgreSQL, MySQL, or Oracle 
Database after many INSERT, UPDATE, and DELETE operations.

Install extension:
CREATE EXTENSION pgstattuple;

Check bloat:
SELECT *
FROM pgstatindex('idx_sales_transaction_customer');

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


# PostgreSQL DBA Indexing Workflow:

1. Create PK and FK indexes
            ↓
2. Enable pg_stat_statements
            ↓
3. Identify top slow queries
            ↓
4. EXPLAIN ANALYZE
            ↓
5. Check for Seq Scans
            ↓
6. Choose index type
            ↓
7. Create index
            ↓
8. Compare execution plans
            ↓
9. Monitor pg_stat_user_indexes
            ↓
10. Remove unused indexes
            ↓
11. Monitor bloat
            ↓
12. REINDEX when necessary

