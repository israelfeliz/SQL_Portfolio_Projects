-- Check for nulls or duplicates in the primary key
-- There should be no duplicates

SELECT cst_id, COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
-- Expectation: no results

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Normalization and standardization

SELECT cst_marital_status, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_marital_status;

SELECT cst_gndr, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_marital_status;

-- Invalid dates

SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt IS NULL 
OR LENGTH(sls_order_dt) != 8
OR sls_order_dt::DATE > CURRENT_DATE -- Check for out of range: Future orders
OR sls_order_dt::DATE <= '19500101'; -- Check for out of range

SELECT sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt IS NULL 
OR LENGTH(sls_ship_dt) != 8
OR sls_ship_dt::DATE > CURRENT_DATE -- Check for out of range: Future orders
OR sls_ship_dt::DATE <= '19500101'; -- Check for out of range

SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt IS NULL 
OR LENGTH(sls_due_dt) != 8
OR sls_due_dt::DATE > CURRENT_DATE -- Check for out of range: Future orders
OR sls_due_dt::DATE <= '19500101' -- Check for out of range

-- Invalid order dates orders, dates comparison
SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check for negative and null values in numeric columns

SELECT 
	sls_sales::INT,
	sls_quantity::INT,
	sls_price::INT
FROM bronze.crm_sales_details
WHERE sls_quantity::INT * sls_price::INT != sls_sales::INT
OR sls_quantity IS NULL
OR sls_sales IS NULL
OR sls_price IS NULL;

-- Invalid dates

SELECT bdate
FROM bronze.erp_cust
WHERE bdate IS NULL 
OR bdate::DATE > CURRENT_DATE -- Check for out of range: Future orders
-- OR bdate <= '1930-01-01'; -- Check for out of range

-- Data Normalization and standardization
SELECT gen, COUNT(*)
FROM bronze.erp_cust
GROUP BY gen

-- Data Normalization and standardization
SELECT cntry, COUNT(*)
FROM bronze.erp_loc
GROUP BY cntry
