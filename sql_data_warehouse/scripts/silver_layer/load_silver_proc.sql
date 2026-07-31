/*
===============================================================================
Procedure Name : silver.load_silver
Schema         : silver
Author         : Israel Feliz
Created Date   : 2026-07-29

Description:
    Loads data from the Bronze layer into the Silver layer by performing
    data cleansing, standardization, validation, and transformation.

    The procedure executes the following tasks:
    - Truncates all Silver tables before loading.
    - Removes duplicate customer records.
    - Cleans and trims text fields.
    - Standardizes categorical values (gender, marital status, country, etc.).
    - Validates and converts date fields.
    - Corrects missing or inconsistent sales, quantity, and price values.
    - Loads CRM and ERP data into the Silver layer.
    - Measures and logs execution time for each table load.
    - Handles unexpected errors and reports diagnostic information.

Source Tables:
    bronze.crm_cust_info
    bronze.crm_prd_info
    bronze.crm_sales_details
    bronze.erp_cust
    bronze.erp_loc
    bronze.erp_px_cat

Target Tables:
    silver.crm_cust_info
    silver.crm_prd_info
    silver.crm_sales_details
    silver.erp_cust
    silver.erp_loc
    silver.erp_px_cat

Execution:
    CALL silver.load_silver();

Notes:
    - Designed for full-refresh ETL loads.
    - Assumes Bronze layer has already been populated.
    - Intended to be executed before loading the Gold layer.
===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    batch_start_time := clock_timestamp();

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Loading silver Layer';
    RAISE NOTICE '========================================';

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE '-- CRM TABLES ';
    RAISE NOTICE '-----------------------------------------------------';

    RAISE NOTICE 'Loading CRM Tables';

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE '-- crm_cust_info';
    RAISE NOTICE '-----------------------------------------------------';

    start_time := clock_timestamp();

    RAISE NOTICE 'Truncating silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;

    RAISE NOTICE 'Loading silver.crm_cust_info';

	INSERT INTO silver.crm_cust_info
	SELECT
	    cst_id::INT,
	    cst_key,
	    -- Remove unwanted spaces
	    TRIM(cst_firstname) AS cst_firstname,
	    TRIM(cst_lastname) AS cst_lastname,
	    -- Data normalization and standardization
	    CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		ELSE 'Unknown' -- Handling Missing Data
	    END AS cst_marital_status,
	    CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		ELSE 'Unknown' -- Handling Missing Data
	    END AS cst_gndr,
	    cst_create_date::DATE
	FROM (
	    -- Remove duplicates and Null values	
	    SELECT *,
		   ROW_NUMBER() OVER (
		       PARTITION BY cst_id
		       ORDER BY cst_create_date DESC
		   ) AS rn
	    FROM bronze.crm_cust_info
	) t
	WHERE rn = 1
	  AND cst_id IS NOT NULL;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE '-- crm_prd_info';
    RAISE NOTICE '-----------------------------------------------------';
    
    start_time := clock_timestamp();
    
    RAISE NOTICE 'Truncating silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;

    RAISE NOTICE 'Loading silver.crm_prd_info';

	INSERT INTO silver.crm_prd_info
	SELECT 
		prd_id::INT,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,
		SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
		prd_nm,
		COALESCE(prd_cost, '0')::INT AS prd_cost,
		CASE UPPER(TRIM(prd_line))
		     WHEN 'M' THEN 'Mounting'
		     WHEN 'R' THEN 'Road'
			 WHEN 'S' THEN 'Other Sales'
			 WHEN 'T' THEN 'Touring'
			 ELSE 'Unknown'
		END AS prd_line,
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		CAST((LEAD(prd_start_dt) OVER(
			PARTITION BY prd_key
			ORDER BY prd_start_dt)::DATE - 1) AS DATE) AS prd_end_dt
	FROM bronze.crm_prd_info
	ORDER BY prd_id;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE '-- crm_sales_details';
    RAISE NOTICE '-----------------------------------------------------';

    start_time := clock_timestamp();
    
    RAISE NOTICE 'Truncating silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;

    RAISE NOTICE 'Loading silver.crm_sales_details';
    
	INSERT INTO silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
	SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id::INT,
		CASE WHEN LENGTH(sls_order_dt) != 8 THEN NULL
			 ELSE sls_order_dt::DATE
		END AS sls_order_dt,
		CASE WHEN LENGTH(sls_ship_dt) != 8 THEN NULL
			 ELSE sls_ship_dt::DATE
		END AS sls_ship_dt,
		CASE WHEN LENGTH(sls_due_dt) != 8 THEN NULL
			 ELSE sls_due_dt::DATE
		END AS sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales::INT = 0 THEN (ABS(sls_quantity::INT) * ABS(sls_price::INT))
			 WHEN sls_sales::INT != (ABS(sls_quantity::INT) * ABS(sls_price::INT)) THEN (ABS(sls_quantity::INT) * ABS(sls_price::INT))
	    	 ELSE sls_sales::INT
		END sls_sales,
		CASE WHEN sls_quantity IS NULL OR sls_quantity::INT = 0 THEN (sls_sales::INT / NULLIF(sls_price::INT, 0))
			 ELSE ABS(sls_quantity::INT)
		END sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price::INT = 0 THEN (sls_sales::INT / NULLIF(sls_quantity::INT, 0))
		 	 ELSE ABS(sls_price::INT)
		END sls_price
	FROM bronze.crm_sales_details;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE '-- ERP TABLES';
    RAISE NOTICE '-----------------------------------------------------';

    RAISE NOTICE 'Loading ERP Tables';

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE '-- erp_loc';
    RAISE NOTICE '-----------------------------------------------------';

    start_time := clock_timestamp();
    
    RAISE NOTICE 'Truncating silver.erp_loc';
    TRUNCATE TABLE silver.erp_loc;

    RAISE NOTICE 'Loading silver.erp_loc';

	INSERT INTO silver.erp_loc(cid, cntry)
	SELECT
		REPLACE(cid, '-','') cid,
	    CASE
		WHEN LOWER(TRIM(cntry)) IN ('us', 'usa') THEN 'United States'
		WHEN LOWER(TRIM(cntry)) = 'de' THEN 'Germany'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'Unknown'
		ELSE TRIM(cntry)
	    END AS cntry
	FROM bronze.erp_loc;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE '-- erp_cust';
    RAISE NOTICE '-----------------------------------------------------';

    start_time := clock_timestamp();
    
    RAISE NOTICE 'Truncating silver.erp_cust';
    TRUNCATE TABLE silver.erp_cust;

    RAISE NOTICE 'Loading silver.erp_cust';

	INSERT INTO silver.erp_cust
	SELECT 
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) 
			 ELSE cid
		END cid,
		CASE WHEN bdate::DATE > CURRENT_DATE THEN NULL
			 ELSE bdate::DATE
		END bdate,
		CASE WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
			 WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female'
			 WHEN gen IS NULL OR TRIM(gen) = '' THEN 'Unknown'
			 ELSE gen
		END gen
	FROM bronze.erp_cust;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE '-- erp_px_cat';
    RAISE NOTICE '-----------------------------------------------------';

    start_time := clock_timestamp();

    RAISE NOTICE 'Truncating silver.erp_px_cat';
    TRUNCATE TABLE silver.erp_px_cat;

    RAISE NOTICE 'Loading silver.erp_px_cat';

	INSERT INTO silver.erp_px_cat (
		id, 
		cat,
		subcat,
		maintenance
	)
	SELECT * FROM bronze.erp_px_cat;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE '-- Finish';
    RAISE NOTICE '-----------------------------------------------------';

    batch_end_time := clock_timestamp();

    RAISE NOTICE '========================================';
    RAISE NOTICE 'silver Layer Loaded Successfully';
    RAISE NOTICE 'Total Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM batch_end_time - batch_start_time),2);
    RAISE NOTICE '========================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '========================================';
        RAISE NOTICE 'ERROR LOADING silver LAYER';
        RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
        RAISE NOTICE 'Message : %', SQLERRM;
        RAISE NOTICE '========================================';
END;
$$;
