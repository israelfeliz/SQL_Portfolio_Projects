/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time 
WITH monthly_sales AS (
SELECT
    DATE_TRUNC('Month', order_date)::DATE AS order_date,
	TO_CHAR(order_date, 'Mon') AS order_month,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
)

SELECT 
	order_date,
	order_month,
	total_sales,
	SUM(total_sales) OVER(
		ORDER BY order_date)
		AS running_total,
	ROUND(AVG(total_sales) OVER(
		ORDER BY order_date), 2)
		AS moving_average
FROM monthly_sales
