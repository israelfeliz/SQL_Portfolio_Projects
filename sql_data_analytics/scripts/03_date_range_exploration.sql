/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), AGE()
===============================================================================
*/

-- Determine the first and last order date and the orders date range.
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    AGE(MAX(order_date), MIN(order_date)) AS order_range
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT
    MIN(birthdate) AS oldest_birthdate,
    AGE(NOW(), MIN(birthdate)) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    AGE(NOW(), MAX(birthdate)) AS youngest_age
FROM gold.dim_customers;
