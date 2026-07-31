/*
===============================================================================
 PostgreSQL Data Warehouse Initialization Script
===============================================================================

Project:
    Data Warehouse Analytics

Purpose:
    This script initializes the PostgreSQL data warehouse by:

    - Creating the 'gold' schema.
    - Creating dimension and fact tables.
    - Defining primary keys, foreign keys, and constraints.
    - Adding indexes to improve query performance.
    - Enforcing data integrity with CHECK and UNIQUE constraints.
    - Preparing the database for loading CSV data.

Schema:
    gold
        - dim_customers
        - dim_products
        - fact_sales

Design:
    - Star Schema
    - Surrogate keys using GENERATED AS IDENTITY
    - Business keys preserved for source system reference
    - Optimized for analytical workloads

Best Practices Implemented:
    ✔ Primary Keys
    ✔ Foreign Keys
    ✔ CHECK Constraints
    ✔ Identity Columns
    ✔ NUMERIC data types for monetary values
    ✔ Indexes on join and filter columns

Prerequisites:
    - PostgreSQL 12 or later
    - Database 'DataWarehouseAnalytics' already created
    - User has CREATE privileges on the database

Author:
    Israel Feliz

Created:
    2026-07-30

Version:
    1.0

===============================================================================
*/

-- Drop the database if it exists
DROP DATABASE IF EXISTS "DataWarehouseAnalytics";

-- Create the database
CREATE DATABASE "DataWarehouseAnalytics";

-- In psql
\c DataWarehouseAnalytics
-- In pgAdmin, simply reconnect to the new database.

-- Create Schemas

CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE gold.dim_customers (
    customer_key     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id      INTEGER NOT NULL,
    customer_number  VARCHAR(50) NOT NULL,
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    country          VARCHAR(50),
    marital_status   VARCHAR(50),
    gender           VARCHAR(50),
    birthdate        DATE,
    create_date      DATE
);

CREATE TABLE gold.dim_products (
    product_key      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id       INTEGER NOT NULL,
    product_number   VARCHAR(50) NOT NULL,
    product_name     VARCHAR(100) NOT NULL,
    category_id      VARCHAR(50),
    category         VARCHAR(50),
    subcategory      VARCHAR(50),
    maintenance      VARCHAR(50),
    cost             NUMERIC(10,2),
    product_line     VARCHAR(50),
    start_date       DATE
);

CREATE TABLE gold.fact_sales (
    sale_key         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_number     VARCHAR(50) NOT NULL,

    product_key      INTEGER NOT NULL,
    customer_key     INTEGER NOT NULL,

    order_date       DATE NOT NULL,
    shipping_date    DATE,
    due_date         DATE,

    sales_amount     NUMERIC(12,2) NOT NULL,
    quantity         SMALLINT NOT NULL CHECK (quantity > 0),
    price            NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES gold.dim_customers(customer_key),

    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_key)
        REFERENCES gold.dim_products(product_key)
);

TRUNCATE TABLE gold.dim_customers RESTART IDENTITY CASCADE;

\copy gold.dim_customers
FROM '/change/file/path/to/file/dim_customers.csv'
DELIMITER ','
CSV HEADER;

TRUNCATE TABLE gold.dim_products RESTART IDENTITY CASCADE;

\copy gold.dim_customers
FROM '/change/file/path/to/file/dim_products.csv'
DELIMITER ','
CSV HEADER;

TRUNCATE TABLE gold.fact_sales;

\copy gold.dim_customers
FROM '/change/file/path/to/file/fact_sales.csv'
DELIMITER ','
CSV HEADER;

-- Useful Indexes
-- These greatly improve joins and filtering.

CREATE INDEX idx_sales_customer
ON gold.fact_sales(customer_key);

CREATE INDEX idx_sales_product
ON gold.fact_sales(product_key);

CREATE INDEX idx_sales_order_date
ON gold.fact_sales(order_date);

CREATE INDEX idx_products_category
ON gold.dim_products(category);

CREATE INDEX idx_customers_country
ON gold.dim_customers(country);

-- CHECK Constraints. Improve data quality.

CHECK (price >= 0)

CHECK (sales_amount >= 0)

CHECK (cost >= 0)

