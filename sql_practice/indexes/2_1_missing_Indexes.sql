-- Evaluate queries and see if indexes are being used:

EXPLAIN ANALYZE
SELECT *
FROM sales_transaction
WHERE customer_id = 100;

/*Bad sign: Seq Scan on orders
Good sign:Index Scan using idx_customer*/

-- Result:

"Seq Scan on sales_transaction  (cost=0.00..2160.43 rows=31 width=38) (actual time=0.160..18.024 rows=24.00 loops=1)"
"  Filter: (customer_id = 100)"
"  Rows Removed by Filter: 71530"
"  Buffers: shared hit=1266"
"Planning:"
"  Buffers: shared hit=6 dirtied=1"
"Planning Time: 0.233 ms"
"Execution Time: 18.071 ms"

/*I noticed on this query that the engine was making a 
sequential scan, if this a query that might be used very 
often and it is very slow, I might need to add a index.*/

-- I will add a index on the foreign key for learning purposes 

CREATE INDEX idx_sd_customer_id
ON sales_transaction (customer_id);

-- Review the query again to see if it being used:

EXPLAIN ANALYZE
SELECT *
FROM sales_transaction
WHERE customer_id = 100;

-- Result

"Bitmap Heap Scan on sales_transaction  (cost=4.53..114.37 rows=31 width=38) (actual time=0.099..0.193 rows=24.00 loops=1)"
"  Recheck Cond: (customer_id = 100)"
"  Heap Blocks: exact=24"
"  Buffers: shared hit=26"
"  ->  Bitmap Index Scan on idx_sd_customer_id  (cost=0.00..4.53 rows=31 width=0) (actual time=0.049..0.050 rows=24.00 loops=1)"
"        Index Cond: (customer_id = 100)"
"        Index Searches: 1"
"        Buffers: shared hit=2"
"Planning Time: 0.298 ms"
"Execution Time: 0.263 ms"

/* Execution Time Improvement

Calculation:

18.071 / 0.263
≈ 68.7

The indexed query is approximately 69 times faster. 

Summary:

Initially PostgreSQL performed a Sequential Scan because no suitable index 
existed on customer_id. The query scanned approximately 71,554 rows to return 
only 24 matching rows, resulting in an execution time of 18.071 ms and 1,266 
buffer hits. After creating a B-tree index on customer_id, PostgreSQL switched 
to a Bitmap Index Scan followed by a Bitmap Heap Scan. The optimizer used the 
index to locate matching rows efficiently, reducing buffer usage from 1,266 to 26 
and execution time from 18.071 ms to 0.263 ms. This demonstrates a significant 
improvement in query performance and confirms that the index is being effectively 
utilized.*/


