/*
===============================================================================
Script Name   : bronze_ddl.sql
Layer         : Bronze
Schema        : bronze
Author        : Israel
Created Date  : 2026-07-29

Description:
    Creates the Bronze layer tables used in the data warehouse. The Bronze
    layer stores raw data exactly as received from the source systems without
    applying any cleansing, validation, or business transformations.

    This script:
    - Drops existing Bronze tables (if they exist).
    - Creates the Bronze tables using VARCHAR data types to preserve the
      original source values.
    - Serves as the landing area for CRM and ERP source data loaded via the
      PostgreSQL COPY command.

Source Systems:
    - CRM
    - ERP

Tables Created:
    - bronze.crm_cust_info
    - bronze.crm_prd_info
    - bronze.crm_sales_details
    - bronze.erp_loc
    - bronze.erp_cust
    - bronze.erp_px_cat

Notes:
    - All columns are intentionally defined as VARCHAR to avoid data load
      failures caused by invalid or inconsistent source values.
    - Data quality checks, standardization, and type conversions are performed
      in the Silver layer.
    - Execute this script before running the Bronze load procedure.

Dependencies:
    - Schema: bronze
    - Procedure: bronze.load_bronze()

===============================================================================
*/

DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
    cst_id VARCHAR(50),
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
    prd_id VARCHAR(50),
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost VARCHAR(50),
    prd_line VARCHAR(50),
    prd_start_dt VARCHAR(50),
    prd_end_dt VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  VARCHAR(50),
    sls_order_dt VARCHAR(50),
    sls_ship_dt  VARCHAR(50),
    sls_due_dt   VARCHAR(50),
    sls_sales    VARCHAR(50),
    sls_quantity VARCHAR(50),
    sls_price    VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_loc;
CREATE TABLE bronze.erp_loc (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_cust;
CREATE TABLE bronze.erp_cust (
    cid VARCHAR(50),
    bdate VARCHAR(50),
    gen VARCHAR(10)
);

DROP TABLE IF EXISTS bronze.erp_px_cat;
CREATE TABLE bronze.erp_px_cat (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(10)
);
