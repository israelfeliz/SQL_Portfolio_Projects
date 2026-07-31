/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
WITH cost_segment AS (
SELECT
	product_cost,
	CASE WHEN product_cost < 100 THEN 'Below 100'
	     WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
	     WHEN product_cost BETWEEN 501 AND 1000 THEN '501-1000'
	     WHEN product_cost > 1000 THEN 'Above 1000'
	END AS cost_range
FROM gold.dim_products
)

SELECT
	cost_range,
	COUNT(cost_range) AS number_of_products
FROM cost_segment
GROUP BY cost_range
ORDER BY number_of_products DESC

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers and total spending by each group 
*/
WITH customer_history AS (
	SELECT
		c.customer_id,
		c.first_name, 
		c.last_name,
		MIN(s.order_date) AS first_order,
		MAX(s.order_date) AS last_order,
		MAX(s.order_date) - MIN(s.order_date) AS lifespan,
		COUNT(s.order_number) AS number_of_orders,
		SUM(sales_amount) AS total_spending
	FROM gold.fact_sales s
	JOIN gold.dim_customers c
	ON c.customer_id = s.customer_id
	GROUP BY 
		c.customer_id,
		c.first_name, 
		c.last_name
),
customer_segmentation AS (
	SELECT *,
		CASE WHEN lifespan > 365 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan > 365 AND total_spending < 5000 THEN 'Regular'
			 WHEN lifespan < 365 AND total_spending > 0 THEN 'New'
			 ELSE 'Uncategorized'
		END AS customer_segment
	FROM customer_history
)
SELECT 
	customer_segment,
	COUNT(*) AS total_customers,
	SUM(total_spending) AS total_spending
FROM customer_segmentation
GROUP BY customer_segment
ORDER BY total_customers DESC
