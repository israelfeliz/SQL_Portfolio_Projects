-- 1 Initial Indexing Strategy

-- This database was supposed to be for an OLTP System. 
-- So my goal is to optimize writes while maintaining fast lookups.

-- Create indexes on:

-- Primary Keys: All The table were created with their primary keys.
-- This are 2 examples of how I would add primary keys where missing:

ALTER TABLE customer
ADD PRIMARY KEY(customer_id);

ALTER TABLE product
ADD PRIMARY KEY(product_id);

-- Already indexed automatically.

-- Foreign Keys: I will create indexes on the primary keys on the main tables

CREATE INDEX idx_transaction_customer
ON sales_transaction(customer_id);

CREATE INDEX idx_transaction_staff
ON sales_transaction(staff_id);

CREATE INDEX idx_transaction_outlet
ON sales_transaction(outlet_id);

CREATE INDEX idx_salesdetail_product
ON sales_detail(product_id);

CREATE INDEX idx_salesdetail_transaction
ON sales_detail(transaction_id);

-- Unique Index
CREATE UNIQUE INDEX idx_customer_email
ON customer(customer_email);