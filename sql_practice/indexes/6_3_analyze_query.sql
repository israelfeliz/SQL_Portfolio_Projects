-- Create Covering Indexes
-- PostgreSQL supports INCLUDE.

CREATE INDEX idx_transaction_customer
ON sales_transaction(customer_id)
INCLUDE(transaction_date,transaction_total);

-- Allows to use Index Only Scan.

EXPLAIN ANALYZE
SELECT customer_id,
       transaction_date,
       transaction_total
FROM sales_transaction
WHERE customer_id = 100;

-- Monitor Index-Only Scans: Good indicator of healthy indexing.
-- Look for:

-- Index Only Scan