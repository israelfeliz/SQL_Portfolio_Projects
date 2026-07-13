-- Analyze Query Plans

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
