/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Which categories contribute the most to overall sales?
WITH cat_revenue AS (
SELECT
	p.category,
	SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
JOIN gold.dim_products p
ON s.product_id = p.product_id
GROUP BY p.category
)

SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER() AS overalL_sales,
	ROUND(((total_sales / SUM(total_sales) OVER()) * 100), 2)
	AS percentage_contribution
FROM cat_revenue

	
