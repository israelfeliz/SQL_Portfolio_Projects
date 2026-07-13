## Query optimization: 

In this scenario, I am going to optimize a query that is very long but is well optimized and is not performing bad after all. However, I want to see the difference when I apply my indexing strategy of creating indexes on the foreign keys. That usually reduce the execution time on queries that have joins, filtering, etc.

Besides, this query is in the top 20 of the most expensive queries:

-- Top expensive queries:
SELECT
	query,
	calls,
	total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

This is the query I am targettig to optimize:

-- Find the total sales per customer (Standalone CTE)
WITH sales_per_customer AS (
	SELECT 
		customer_id,
		SUM(transaction_total) AS total_sales
	FROM sales_transaction
	GROUP BY customer_id
),

-- Find the last transaction date for each customer (Standalone CTE)
last_transaction_date AS (
	SELECT 
		customer_id,
		MAX(transaction_date) AS last_transaction_date
	FROM sales_transaction
		GROUP BY customer_id
),

-- Rank customers based on total sales (Nested CTE)
customer_rank AS (
	SELECT 
		customer_id,
		total_sales,
		RANK() OVER(ORDER BY total_sales DESC) AS customer_rank
	FROM sales_per_customer
),

-- Segment customers based on their total sales
customer_segments AS (
SELECT 
	customer_id,
	total_sales,
	CASE WHEN total_sales > 250 THEN 'High'
		 WHEN total_sales > 150 THEN 'Medium'
		 ELSE 'Low' 
	END AS customer_segment
FROM sales_per_customer
)

SELECT 
	c.customer_id,
	c.customer_name,
	spc.total_sales,
	ltd.last_transaction_date,
	cr.customer_rank,
	cs.customer_segment
FROM customer c
LEFT JOIN sales_per_customer spc
ON c.customer_id = spc.customer_id
LEFT JOIN last_transaction_date ltd
ON c.customer_id = ltd.customer_id
LEFT JOIN customer_rank cr
ON c.customer_id = cr.customer_id
LEFT JOIN customer_segments cs
ON c.customer_id = cs.customer_id

Without the query execution plan involved, it took 142 ms.
Query complete 00:00:00.142

First I improved the readability and performance of this query by removing some unnecesaries CTEs and Joins.

-- Find the total sales per customer and the last transaction date
WITH sales_per_customer AS (
	SELECT 
		st.customer_id,
		c.customer_name,
		SUM(transaction_total) AS total_sales,
		MAX(transaction_date) AS last_transaction_date
	FROM sales_transaction st
	LEFT JOIN customer c
	ON st.customer_id = c.customer_id
	GROUP BY st.customer_id, c.customer_name
)
-- Add rank and segment based on their total sales.
SELECT 
	customer_id,
	customer_name,
	total_sales,
	last_transaction_date,
	RANK() OVER(ORDER BY total_sales DESC) AS customer_rank,
	CASE WHEN total_sales > 250 THEN 'High'
		 WHEN total_sales > 150 THEN 'Medium'
		 ELSE 'Low' 
	END AS customer_segment
FROM sales_per_customer

Query complete 00:00:00.113

I think, the query is optimized already, but I still can improve by indexing the foreign key "customer_id" on the "sales_transazction" table.

So the next step is analyze it and review the query plan:

/Coffee_Shop_Database/indexes/scenario_2/query_execution_plan_original.csv
/Coffee_Shop_Database/indexes/scenario_2/query_execution_plan_modified.csv

-- Create a b-tree index(the default in PostgreSQL) in the foreign key:

CREATE INDEX idx_sales_transaction_outlet
ON sales_transaction (outlet_id);

-- Update statistics on the table:

ANALYZE sales_transaction; 

-- Re-run EXPLAIN ANALYZE 

-- Result: The execution time was reduced on both queries.

/Coffee_Shop_Database/indexes/scenario_2/query_execution_plan_original_after.csv
/Coffee_Shop_Database/indexes/scenario_2/query_execution_plan_modified_after.csv






