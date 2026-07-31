/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and product_cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

CREATE OR REPLACE VIEW gold.report_products AS

WITH base_query AS (
    SELECT
	s.order_number,
        s.order_date,
	s.customer_id,
        s.sales_amount,
        s.quantity,
        p.product_id,
        p.product_name,
        p.category,
        p.subcategory,
        p.product_cost
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_id = p.product_id
    WHERE order_date IS NOT NULL  -- only consider valid sales dates
),
product_aggregations AS (
SELECT 
	product_id,
    product_name,
    category,
    subcategory,
    product_cost,
	(EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
	    +
	 EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))
	) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_id) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
	ROUND(AVG(sales_amount) / NULLIF(quantity, 0), 2) AS avg_selling_price
FROM base_query
	GROUP BY
	    product_id,
	    product_name,
	    category,
	    subcategory,
	    product_cost,
		quantity
)

SELECT 
	product_id,
	product_name,
	category,
	subcategory,
	product_cost,
	last_sale_date,
	AGE(last_sale_date) AS recency,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregations 
