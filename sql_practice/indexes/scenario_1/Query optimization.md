## Query optimization: 

By monitoring expensive queries, I was able to identify a query that was very expensive and was taking about 30 seconds to complete.

-- Top expensive queries:
SELECT
	query,
	calls,
	total_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

This is the query I found:

SELECT 
	so.outlet_id,
	so.outlet_type,
	so.city,
	st.transaction_id,
	st.transaction_date, 
	st.transaction_total AS max_transaction_amount
FROM sales_outlet so
JOIN sales_transaction st
ON so.outlet_id = st.outlet_id
WHERE st.transaction_total =
	(SELECT MAX(transaction_total)
	 FROM sales_transaction st
	 WHERE st.outlet_id = so.outlet_id)

So the next step is analyze it and review the query plan:

EXPLAIN (ANALYZE, BUFFERS) -- -- Detailed Query Plan
SELECT 
	so.outlet_id,
	so.outlet_type,
	so.city,
	st.transaction_id,
	st.transaction_date, 
	st.transaction_total AS max_transaction_amount
FROM sales_outlet so
JOIN sales_transaction st
ON so.outlet_id = st.outlet_id
WHERE st.transaction_total =
	(SELECT MAX(transaction_total)
	 FROM sales_transaction st
	 WHERE st.outlet_id = so.outlet_id)

This is the result:

/Coffee_Shop_Database/indexes/scenario_1/query_execution_plan_before.csv

It is a very complex query and it has a correlated sub-query that by default makes it slower.
I will try to optimize it by creating some b-tree indexes in the sale_transaction table for the foreign keys, which is something I do in my initial indexing strategy, but haven't done so far in this database.
This will help when joining tables and filtering that involve the foreign keys.
In this query the foreign key involved is the "outlet_id" from the "sales_outlet" table.

-- Create a b-tree index(the default in PostgreSQL) in the foreign key:

CREATE INDEX idx_sales_transaction_outlet
ON sales_transaction (outlet_id);

-- Update statistics on the table:

ANALYZE sales_transaction; 

-- Re-run EXPLAIN ANALYZE 

-- Result: It only reduced the execution time by about 4 seconds.

/Coffee_Shop_Database/indexes/scenario_1/query_execution_plan_after.csv

Notice: Without EXPLAIN ANALYZE, It took about 17 seconds, which is not bad, since it was taking about 24 seconds.

I decided to take another approach to this problem. In the end it is not an indexing problem. 
It is a correlated sub-query with loops on a medium size database. This subquery was just for practicing and learning purposes, so, I decided to make the query differently to improve the performance.

SELECT
    so.outlet_id,
    so.outlet_type,
    so.city,
    x.transaction_id,
    x.transaction_date,
    x.transaction_total
FROM (
    SELECT
        transaction_id,
        outlet_id,
        transaction_date,
        transaction_total,
        MAX(transaction_total)
            OVER (PARTITION BY outlet_id) AS max_total
    FROM sales_transaction
) 
JOIN sales_outlet so
    ON so.outlet_id = x.outlet_id
WHERE x.transaction_total = x.max_total;

As you many notice the execution time was reduced tremendously: 

Conclusion: 

This was a great learning experience for me. First of all, even though it was important to create an index for the foreign keys, because it is part of my indexing strategy, and it reduced the execution time of the query; I discovered that the real issue with this particular query was the query itself. Next time, I would evaluate, if I can remake the query to perform better, and then apply the most appropriate indexing strategy if applicable, since not everything could be resolved with indexes and it is not always good to have many indexes, since there is a cost on that.





