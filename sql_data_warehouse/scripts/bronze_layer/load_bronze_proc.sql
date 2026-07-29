/*
===============================================================================
Procedure Name : bronze.load_bronze
Schema         : bronze
Author         : Israel Feliz
Created Date   : 2026-07-29

Description:
    Loads raw data from source CSV files into the Bronze layer of the data
    warehouse. This procedure performs a full refresh by truncating each
    Bronze table before importing the latest data from the source systems.

    The procedure executes the following tasks:
    - Truncates all Bronze tables.
    - Loads CRM source files using PostgreSQL COPY.
    - Loads ERP source files using PostgreSQL COPY.
    - Measures and logs execution time for each table load.
    - Logs the total execution time for the batch.
    - Handles unexpected errors and reports diagnostic information.

Source Files:
    source_crm/cust_info.csv
    source_crm/prd_info.csv
    source_crm/sales_details.csv
    source_erp/LOC_A101.csv
    source_erp/CUST_AZ12.csv
    source_erp/PX_CAT_G1V2.csv

Target Tables:
    bronze.crm_cust_info
    bronze.crm_prd_info
    bronze.crm_sales_details
    bronze.erp_loc
    bronze.erp_cust
    bronze.erp_px_cat

Execution:
    CALL bronze.load_bronze();

Notes:
    - Designed for full-refresh ETL loads.
    - No data cleansing or transformations are performed in this layer.
    - Data is loaded exactly as received from the source systems.
    - Intended to be executed before the Silver layer load procedure.
===============================================================================
*/
CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '========================================';

    -----------------------------------------------------
    -- CRM TABLES
    -----------------------------------------------------

    RAISE NOTICE 'Loading CRM Tables';

    -----------------------------------------------------
    -- crm_cust_info
    -----------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE 'Truncating bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE 'Loading bronze.crm_cust_info';

    COPY bronze.crm_cust_info
    FROM '/home/israel/Zdisk/Projects/sql_data_warehouse/data/source_crm/cust_info.csv'
    DELIMITER ','
    CSV HEADER;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    -----------------------------------------------------
    -- crm_prd_info
    -----------------------------------------------------

    start_time := clock_timestamp();

    TRUNCATE TABLE bronze.crm_prd_info;

    COPY bronze.crm_prd_info
    FROM '/home/israel/Zdisk/Projects/sql_data_warehouse/data/source_crm/prd_info.csv'
    DELIMITER ','
    CSV HEADER;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    -----------------------------------------------------
    -- crm_sales_details
    -----------------------------------------------------

    start_time := clock_timestamp();

    TRUNCATE TABLE bronze.crm_sales_details;

    COPY bronze.crm_sales_details
    FROM '/home/israel/Zdisk/Projects/sql_data_warehouse/data/source_crm/sales_details.csv'
    DELIMITER ','
    CSV HEADER;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    -----------------------------------------------------
    -- ERP TABLES
    -----------------------------------------------------

    RAISE NOTICE 'Loading ERP Tables';

    -----------------------------------------------------
    -- erp_loc_a101
    -----------------------------------------------------

    start_time := clock_timestamp();

    TRUNCATE TABLE bronze.erp_loc;

    COPY bronze.erp_loc
    FROM '/home/israel/Zdisk/Projects/sql_data_warehouse/data/source_erp/LOC_A101.csv'
    DELIMITER ','
    CSV HEADER;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    -----------------------------------------------------
    -- erp_cust_az12
    -----------------------------------------------------

    start_time := clock_timestamp();

    TRUNCATE TABLE bronze.erp_cust;

    COPY bronze.erp_cust
    FROM '/home/israel/Zdisk/Projects/sql_data_warehouse/data/source_erp/CUST_AZ12.csv'
    DELIMITER ','
    CSV HEADER;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    -----------------------------------------------------
    -- erp_px_cat_g1v2
    -----------------------------------------------------

    start_time := clock_timestamp();

    TRUNCATE TABLE bronze.erp_px_cat;

    COPY bronze.erp_px_cat
    FROM '/home/israel/Zdisk/Projects/sql_data_warehouse/data/source_erp/PX_CAT_G1V2.csv'
    DELIMITER ','
    CSV HEADER;

    end_time := clock_timestamp();

    RAISE NOTICE 'Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time),2);

    -----------------------------------------------------
    -- Finish
    -----------------------------------------------------

    batch_end_time := clock_timestamp();

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Bronze Layer Loaded Successfully';
    RAISE NOTICE 'Total Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM batch_end_time - batch_start_time),2);
    RAISE NOTICE '========================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '========================================';
        RAISE NOTICE 'ERROR LOADING BRONZE LAYER';
        RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
        RAISE NOTICE 'Message : %', SQLERRM;
        RAISE NOTICE '========================================';
END;
$$;
