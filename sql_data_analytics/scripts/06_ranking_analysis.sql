/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
-- Simple Ranking
SELECT
    p.product_name,
	SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_id = p.product_id 
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Complex but Flexibly Ranking Using Window Functions
SELECT * FROM (
    SELECT
        p.product_name,
        SUM(s.sales_amount) AS total_revenue,
        RANK() OVER(ORDER BY SUM(s.sales_amount) DESC)
        AS ranking
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_id = p.product_id 
    GROUP BY p.product_name)
WHERE ranking <= 5;

-- What are the 5 worst-performing products in terms of sales?
SELECT
	p.product_name,
	SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_id = p.product_id 
GROUP BY p.product_name
ORDER BY total_sales
LIMIT 5;

-- Find the top 10 customers who have generated the highest revenue
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_id = s.customer_id 
GROUP BY 
	c.customer_id,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC
LIMIT 10;

-- The 3 customers with the fewest orders placed
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT s.order_number) AS number_of_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_id = s.customer_id 
GROUP BY 
	c.customer_id,
	c.first_name,
	c.last_name
ORDER BY number_of_orders
LIMIT 3