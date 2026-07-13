-- This table was missing a very important column for the sales amount.
-- Adding a new column. 

ALTER TABLE sales_detail
ADD sale_amount NUMERIC(10, 2);

-- Populate the data from same table, by multiplying quantity by price.

UPDATE sales_detail
SET sale_amount = quantity * price;

-- Adding constraints
-- Setting NOT NULL
ALTER TABLE sales_detail
ALTER COLUMN sale_amount SET NOT NULL;

-- Checking values greater than 0
ALTER TABLE sales_detail
ADD CONSTRAINT chK_sale_amount
CHECK (sale_amount > 0);

---------------------------------------------

-- Adding a new column in the Table sales_transaction

ALTER TABLE sales_transaction
ADD COLUMN transaction_total NUMERIC(10,2);

-- Populating data from another table using Subquery

UPDATE sales_transaction st
SET transaction_total = sd.total
FROM (
    SELECT
        transaction_id,
        SUM(sale_amount) AS total
    FROM sales_detail
    GROUP BY transaction_id
) sd
WHERE st.transaction_id = sd.transaction_id;

-- Populating data from another table using CTE

WITH transaction_amount AS (
    SELECT
        transaction_id,
        SUM(sale_amount) AS total
    FROM sales_detail
    GROUP BY transaction_id
)
UPDATE sales_transaction st
SET transaction_total = ta.total
FROM transaction_amount ta
WHERE st.transaction_id = ta.transaction_id;


