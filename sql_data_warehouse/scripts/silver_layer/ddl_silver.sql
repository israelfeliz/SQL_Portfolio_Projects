/*
===============================================================================
Script Name   : silver_ddl.sql
Layer         : Silver
Schema        : silver
Author        : Israel Feliz
Created Date  : 2026-07-29

Description:
    Creates the Silver layer tables used in the data warehouse. The Silver
    layer stores cleansed, validated, standardized, and transformed data
    derived from the Bronze layer, making it suitable for downstream
    reporting, analytics, and business processing.

    This script:
    - Drops existing Silver tables (if they exist).
    - Creates typed tables with appropriate data types.
    - Includes a data warehouse audit column (dwh_create_date) to track
      when records are loaded into the Silver layer.
    - Defines the structure required by the Silver ETL process.

Source Layer:
    - Bronze

Tables Created:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_loc
    - silver.erp_cust
    - silver.erp_px_cat

Data Characteristics:
    - Duplicate records removed.
    - Invalid and missing values handled.
    - Text fields standardized and normalized.
    - Dates converted to DATE data type.
    - Numeric values converted to appropriate numeric types.
    - Business rules applied to improve data quality.

Notes:
    - The Silver layer contains one cleaned and validated version of the data.
    - The dwh_create_date column records the timestamp when each record is
      inserted into the data warehouse.
    - Execute this script before running the Silver load procedure.

Dependencies:
    - Schema: silver
    - Procedure: silver.load_silver()

===============================================================================
*/

DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(20),
    cst_firstname VARCHAR(30),
    cst_lastname VARCHAR(30),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATE,
    dwh_create_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    prd_cat_id VARCHAR(20),
    prd_key VARCHAR(30),
    prd_nm VARCHAR(50),
    prd_cost NUMERIC(10, 2),
    prd_line VARCHAR(20),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num  VARCHAR(30),
    sls_prd_key  VARCHAR(30),
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    NUMERIC(10, 2),
    sls_quantity INT,
    sls_price    NUMERIC(10, 2),
    dwh_create_date TIMESTAMP DEFAULT NOW()    
);

DROP TABLE IF EXISTS silver.erp_loc;
CREATE TABLE silver.erp_loc (
    cid VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT NOW()    
);

DROP TABLE IF EXISTS silver.erp_cust;
CREATE TABLE silver.erp_cust (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(10),
    dwh_create_date TIMESTAMP DEFAULT NOW()    
);

DROP TABLE IF EXISTS silver.erp_px_cat;
CREATE TABLE silver.erp_px_cat (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(10),
    dwh_create_date TIMESTAMP DEFAULT NOW()    
);
