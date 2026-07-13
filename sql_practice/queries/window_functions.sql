-- I asked ChatGPT to give a list of exercises to practice window functions.
/*Part 1 — Aggregate Window Functions (1–40)

Functions:

SUM() OVER()
AVG() OVER()
COUNT() OVER()
MIN() OVER()
MAX() OVER()*/

-- Running Totals

-- 1. Calculate a running total of sales by transaction date.
SELECT 
	transaction_id,
	transaction_date,
	transaction_total,
	SUM(transaction_total) OVER(ORDER BY transaction_date) 
	AS running_total
FROM sales_transaction;

-- 2. Calculate a running total of sales for each outlet.

SELECT 
	transaction_id,
	transaction_date,
	transaction_total,
	outlet_id,
	SUM(transaction_total) 
	OVER(PARTITION BY outlet_id 
	ORDER BY transaction_date) 
	AS running_total
FROM sales_transaction;

-- 3. Calculate a running total of sales for each customer.

SELECT 
	transaction_id,
	transaction_date,
	transaction_total,
	customer_id,
	SUM(transaction_total) 
	OVER(PARTITION BY customer_id 
	ORDER BY transaction_date) 
	AS running_total
FROM sales_transaction;

-- 4. Calculate a running total of product quantities sold.

SELECT
    sd.sales_details_id,
    sd.product_id,
    sd.quantity,
    st.transaction_date AS sales_date,
    SUM(sd.quantity) OVER (
        PARTITION BY sd.product_id
        ORDER BY st.transaction_date, sd.sales_details_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_quantity_sold
FROM sales_detail sd
JOIN sales_transaction st
ON sd.transaction_id = st.transaction_id;

-- 5. Calculate a running total of revenue per product.

SELECT
    sd.sales_details_id,
    sd.product_id,
    sd.sale_amount,
    st.transaction_date AS sales_date,
    SUM(sd.sale_amount) OVER (
        PARTITION BY sd.product_id
        ORDER BY st.transaction_date, sd.sales_details_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue_by_product
FROM sales_detail sd
JOIN sales_transaction st
ON sd.transaction_id = st.transaction_id;

-- Moving Averages

-- 6.Calculate the average transaction amount across all transactions.

SELECT
	transaction_id,
	transaction_date,
	transaction_total,
	ROUND(AVG(transaction_total) OVER(), 2) AS avg_transaction
FROM sales_transaction
	
-- 7. Show each transaction and the overall average transaction amount.

SELECT
	transaction_id,
	transaction_date,
	transaction_total,
	ROUND(AVG(transaction_total) OVER(), 2) AS avg_transaction
FROM sales_transaction

-- 8. Calculate a moving average using the previous 3 transactions.

SELECT
	transaction_id,
	transaction_date,
	transaction_total,
	ROUND(AVG(transaction_total) 
	OVER(ORDER BY transaction_date, transaction_id
	ROWS BETWEEN 3 PRECEDING AND CURRENT ROW), 2) AS avg_3days_transactions
FROM sales_transaction

-- 9. Calculate a moving average using the previous 7 transactions.

SELECT
	transaction_id,
	transaction_date,
	transaction_total,
	ROUND(AVG(transaction_total) 
	OVER(ORDER BY transaction_date, transaction_id
	ROWS BETWEEN 7 PRECEDING AND CURRENT ROW), 2) AS avg_7days_transactions
FROM sales_transaction

-- 10. Calculate a moving average of daily sales.
SELECT
	transaction_id,
	transaction_date,
	transaction_total,
	ROUND(AVG(transaction_total) 
	OVER(ORDER BY transaction_date), 2) 
	AS avg_daily_transactions
FROM sales_transaction

-- Percent of Total

-- 11. Show each transaction's percentage of total revenue.

SELECT
    transaction_id,
    transaction_date,
    transaction_total,
    ROUND(
        transaction_total * 100.0
        / SUM(transaction_total) OVER (),
        2
    ) AS revenue_percent
FROM sales_transaction;

-- 12. Show each outlet's contribution to total revenue.

SELECT 
	outlet_id,
	SUM(transaction_total) AS outlet_revenue,
	ROUND(SUM(transaction_total) * 100 / 
	SUM(SUM(transaction_total)) OVER(), 2)
	AS contribution_percent
FROM sales_transaction
GROUP BY outlet_id

-- 13. Show each product's contribution to total sales.

SELECT 
	sd.product_id,
	p.product_name,
	SUM(sd.sale_amount) AS product_revenue,
	ROUND(SUM(sd.sale_amount) * 100 / 
	SUM(SUM(sd.sale_amount)) OVER(), 2)
	AS revenue_percent
FROM sales_detail sd
JOIN product p
ON sd.product_id = p.product_id
GROUP BY sd.product_id, p.product_name
ORDER BY 3 DESC

-- 14. Show each customer's contribution to revenue.

SELECT 
	customer_id,
	SUM(transaction_total) AS total_spending,
	ROUND(SUM(transaction_total) * 100 / 
	SUM(SUM(transaction_total)) OVER(), 2)
	AS revenue_percent
FROM sales_transaction
GROUP BY customer_id
ORDER BY total_spending DESC

-- 15. Show revenue percentage by product category.

WITH product_details AS (
	SELECT 
		p.product_id,
		pt.product_category
FROM product p
JOIN product_type pt
ON p.product_type_id = pt.product_type_id
)
SELECT 
	pd.product_category,
	SUM(sd.sale_amount) AS revenue_by_category,
	ROUND(SUM(sd.sale_amount) * 100 / 
	SUM(SUM(sd.sale_amount)) 
	OVER(), 2) AS revenue_contrib_percent
FROM sales_detail sd
LEFT JOIN product_details pd
ON sd.product_id = pd.product_id
GROUP BY pd.product_category
ORDER BY revenue_contrib_percent DESC

-- Cumulative Aggregates

-- 16.Calculate cumulative quantity sold.

SELECT
	product_id,
	SUM(quantity) AS quantity_sold,
	SUM(SUM(quantity)) 
	OVER(ORDER BY product_id) 
	AS cum_quantity_sold
FROM sales_detail
GROUP BY product_id
ORDER BY product_id

-- 17. Calculate cumulative revenue by outlet.

SELECT
	 outlet_id,
	 transaction_date,
	 SUM(transaction_total) 
	 OVER(PARTITION BY outlet_id 
	 ORDER BY transaction_date, transaction_id
	 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	 AS cum_revenue_outlet
FROM sales_transaction

-- 18. Calculate cumulative revenue by customer.

SELECT
	 transaction_id,
	 transaction_date,
	 customer_id,
	 transaction_total,
	 SUM(transaction_total) 
	 OVER(PARTITION BY customer_id 
	 ORDER BY transaction_date, transaction_id
	 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	 AS cum_revenue_customer
FROM sales_transaction

-- 19. Calculate cumulative revenue by product.

SELECT
	st.transaction_date,
	sd.product_id,
	sd.sale_amount,
	SUM(sd.sale_amount) 
	OVER(PARTITION BY sd.product_id 
	ORDER BY st.transaction_date
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	AS cum_revenue_product
FROM sales_detail sd
JOIN sales_transaction st
ON st.transaction_id = sd.transaction_id

-- 20. Calculate cumulative revenue by city.

SELECT
	st.transaction_id,
	transaction_date,
	so.city,
	st.transaction_total,
	SUM(transaction_total) 
	OVER(PARTITION BY so.city
	ORDER BY st.transaction_date, transaction_id)
	AS cum_revenue_city
FROM sales_transaction st
JOIN sales_outlet so
ON st.outlet_id = so.outlet_id

-- MIN/MAX Windows

-- 21. Show each transaction and the highest transaction amount.

SELECT
	transaction_id,
	transaction_total,
	MAX(transaction_total)
	OVER() AS highest_transaction
FROM sales_transaction

-- 22. Show each transaction and the lowest transaction amount.

SELECT
	transaction_id,
	transaction_total,
	MIN(transaction_total)
	OVER() AS lowest_transaction
FROM sales_transaction;

-- 23. Show each product and the highest sale amount.

-- 23. Show each product and the highest sale amount.

SELECT 
	p.product_id,
	p.product_name,
	t.highest_sale
FROM (
SELECT 
	product_id,
	MAX(sale_amount) AS highest_sale
FROM sales_detail
GROUP BY product_id
) t
JOIN product p
ON p.product_id = t.product_id
ORDER BY highest_sale DESC;

-- 24. Show each outlet and its maximum transaction.

SELECT 
	outlet_id,
	MAX(transaction_total) 
	AS highest_transaction
FROM sales_transaction
GROUP BY outlet_id
ORDER BY outlet_id;

-- 25. Show each customer and their largest purchase.

SELECT 
	customer_id,
	MAX(transaction_total) 
	AS largest_purchase
FROM sales_transaction
GROUP BY customer_id
ORDER BY customer_id;

-- Comparisons Against Averages

-- 26. Find transactions above overall average.

SELECT * FROM (
SELECT 
	transaction_id,
	transaction_total,
	ROUND(AVG(transaction_total) 
	OVER(), 2) AS avg_transaction
FROM sales_transaction)
WHERE transaction_total > avg_transaction;

-- 27. Find products above average revenue.

WITH product_revenue AS (
    SELECT
        product_id,
        SUM(sale_amount) AS total_revenue
    FROM sales_detail
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    pr.total_revenue
FROM product p
JOIN product_revenue pr
    ON p.product_id = pr.product_id
WHERE pr.total_revenue >
(
    SELECT AVG(total_revenue)
    FROM product_revenue
);

-- 28. Find customers above average spending.

WITH avg_cust_spending AS (
	SELECT 
		customer_id,
		SUM(transaction_total) AS customer_spending,
		ROUND(AVG(SUM(transaction_total))
		OVER (), 2) AS avg_customer_spending
	FROM sales_transaction
	GROUP BY customer_id
)

SELECT 
	c.customer_id,
	c.customer_name,
	ac.customer_spending,
	ac.avg_customer_spending
FROM customer c
JOIN avg_cust_spending ac
ON c.customer_id = ac.customer_id
AND ac.customer_spending >
	ac.avg_customer_spending
	
-- 29. Find outlets above average sales.

WITH outlet_sales AS (
    SELECT
        outlet_id,
        SUM(transaction_total) AS transaction_total
    FROM sales_transaction
    GROUP BY outlet_id
)
SELECT
    outlet_id,
    transaction_total
FROM outlet_sales 
WHERE transaction_total >
(
    SELECT AVG(transaction_total)
    FROM outlet_sales
);

-- 30. Find cities above average revenue. 

SELECT 
	so.city,
	t.transaction_total,
	t.avg_transaction_total
FROM sales_outlet so
JOIN
(SELECT 
	outlet_id,
	SUM(transaction_total) AS transaction_total,
	ROUND(AVG(SUM(transaction_total)) OVER(), 2) AS avg_transaction_total
FROM sales_transaction
GROUP BY outlet_id) t
ON so.outlet_id = t.outlet_id
WHERE t.transaction_total > avg_transaction_total

-- Partitioned Aggregates

-- 31. Calculate average transaction per outlet.

SELECT 
	outlet_id,
	ROUND(AVG(transaction_total), 2)
	AS avg_transaction
FROM sales_transaction
GROUP BY outlet_id

-- 32. Calculate average transaction per city.

SELECT 
	so.city,
	ROUND(AVG(transaction_total), 2)
	AS avg_transaction
FROM sales_transaction st
JOIN sales_outlet so
ON so.outlet_id = st.outlet_id
GROUP BY so.city

-- 33. Calculate average spending per customer.

SELECT 
	customer_id,
	SUM(transaction_total) AS total_spending,
	ROUND(AVG(SUM(transaction_total)) OVER(), 2) AS avg_customer_spending
FROM sales_transaction
GROUP BY customer_id

-- 34. Calculate average product sales by category.

WITH product_sales AS (
    SELECT
        sd.product_id,
        pt.product_category,
        SUM(sd.sale_amount) AS total_sales
    FROM sales_detail sd
    JOIN product p
        ON p.product_id = sd.product_id
    JOIN product_type pt
        ON pt.product_type_id = p.product_type_id
    GROUP BY
        sd.product_id,
        pt.product_category
)
SELECT
    product_category,
    ROUND(AVG(total_sales), 2) AS avg_product_sales
FROM product_sales
GROUP BY product_category
ORDER BY avg_product_sales DESC;

/* My preferred approach, since we can compare the total sales 
by product with other products within the same category */

SELECT 
	sd.product_id,
	p.product_name,
	pt.product_category,
	SUM(sd.sale_amount) AS total_sales,
	ROUND(AVG(SUM(sd.sale_amount)) OVER (PARTITION BY pt.product_category), 2)
	AS avg_product_sales_by_category
FROM sales_detail sd
LEFT JOIN product p
ON p.product_id = sd.product_id
LEFT JOIN product_type pt
ON p.product_type_id = pt.product_type_id
GROUP BY sd.product_id, p.product_name, pt.product_category

-- Other interesting report I found out while exploring the data. 
-- Calculate total sales by category.

SELECT 
	pt.product_category,
	SUM(sd.sale_amount) AS total_sales
FROM sales_detail sd
LEFT JOIN product p
ON p.product_id = sd.product_id
LEFT JOIN product_type pt
ON p.product_type_id = pt.product_type_id
GROUP BY pt.product_category
ORDER BY total_sales DESC

-- 35. Calculate average quantity sold per product.

-- If it is just the average quantity sold per transaction:
SELECT 
	product_id,
	ROUND(AVG(quantity), 2) AS avg_quantity_sold
FROM sales_detail
GROUP BY product_id

-- If is the total quantity sold by products

SELECT
    product_id,
    SUM(quantity) AS quantity_sold
FROM sales_detail
GROUP BY product_id;

-- If it is the average quantity sold across all products

SELECT 
	AVG(quantity_sold)::INTEGER
	AS avg_quantity_sold_by_product
FROM (
SELECT
    product_id,
    SUM(quantity) AS quantity_sold
FROM sales_detail
GROUP BY product_id);

-- Advanced Aggregates

-- 36. Calculate running count of transactions.

SELECT
	 transaction_id,
	 transaction_date,
	 COUNT(transaction_id) 
	 OVER(ORDER BY transaction_date, transaction_id)
FROM sales_transaction


-- 37. Calculate running count of customers acquired by date.

SELECT
    customer_since AS acquisition_date,
    COUNT(customer_id) AS new_customers,
    SUM(COUNT(customer_id)) OVER (
        ORDER BY customer_since
    ) AS running_customers
FROM customer
GROUP BY acquisition_date
ORDER BY acquisition_date;

-- 38. Calculate cumulative number of products sold.

SELECT
	st.transaction_date,
	SUM(sd.quantity) AS products_sold,
	SUM(SUM(sd.quantity)) OVER(ORDER BY st.transaction_date)
	AS cum_products_sold
FROM sales_transaction st
JOIN sales_detail sd
ON st.transaction_id = sd.transaction_id
GROUP BY st.transaction_date

-- 39. Calculate cumulative outlet revenue.

SELECT
    st.transaction_date,
    st.outlet_id,
    SUM(sd.sale_amount) AS daily_revenue,
    SUM(SUM(sd.sale_amount))
        OVER (
            PARTITION BY st.outlet_id
            ORDER BY st.transaction_date
        ) AS cumulative_revenue
FROM sales_transaction st
JOIN sales_detail sd
    ON st.transaction_id = sd.transaction_id
GROUP BY
    st.transaction_date,
    st.outlet_id
ORDER BY
    st.outlet_id,
    st.transaction_date;

-- 40. Calculate cumulative category revenue.

WITH category_revenue AS (
	SELECT
		pt.product_category,
		st.transaction_date,
		SUM(sd.sale_amount) AS daily_revenue
	FROM sales_detail sd
	JOIN sales_transaction st
	ON st.transaction_id = sd.transaction_id
	JOIN product p
	ON sd.product_id = p.product_id
	JOIN product_type pt
	ON p.product_type_id = pt.product_type_id
	GROUP BY pt.product_category, st.transaction_date 
)

SELECT 
	product_category,
	transaction_date,
	daily_revenue,
	SUM(daily_revenue) 
		OVER(
			PARTITION BY product_category
			ORDER BY product_category, transaction_date
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS category_cum_revenue
FROM category_revenue

-- Part 2 — Ranking Functions (41–70)
/*
Functions:

ROW_NUMBER()
RANK()
DENSE_RANK()
NTILE()
PERCENT_RANK()
CUME_DIST()
*/

-- 41. Assign sequential numbers to all transactions.

-- 42. Number transactions within each outlet.

SELECT
	transaction_date,
	transaction_id,
	outlet_id,
	ROW_NUMBER() OVER(
		PARTITION BY outlet_id
		ORDER BY transaction_date, transaction_id)
FROM sales_transaction;

-- 43. Number transactions within each customer.

SELECT
	transaction_date,
	transaction_id,
	customer_id,
	ROW_NUMBER() OVER(
		PARTITION BY customer_id
		ORDER BY transaction_date, transaction_id)
FROM sales_transaction;

-- 44. Number products within each category.

SELECT 
	pt.product_category,
	p.product_name,
	ROW_NUMBER() OVER(
		PARTITION BY pt.product_category
		ORDER BY p.product_name)
	AS product_number
FROM product p
JOIN product_type pt
ON p.product_type_id = pt.product_type_id

-- 45. Find the first transaction for every customer.

WITH customer_transactions AS (
SELECT
	customer_id,
	transaction_id,
	transaction_date,
	ROW_NUMBER() OVER(
		PARTITION BY customer_id
		ORDER BY transaction_date, transaction_id
	) AS transaction_order
FROM sales_transaction
)

SELECT 
	customer_id,
	transaction_id,
	transaction_date
FROM customer_transactions
WHERE transaction_order = 1

-- 46. Find the latest transaction for every customer.

WITH customer_transactions AS (
    SELECT
        customer_id,
        transaction_id,
        transaction_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY transaction_date DESC, transaction_id DESC
        ) AS transaction_order
    FROM sales_transaction
)
SELECT
    customer_id,
    transaction_id,
    transaction_date
FROM customer_transactions
WHERE transaction_order = 1;

-- 47. Find the first transaction for every outlet.

WITH transactions_by_oulet AS (
SELECT
	transaction_id,
	transaction_date,
	outlet_id,
	ROW_NUMBER() OVER(
	PARTITION BY outlet_id
	ORDER BY transaction_date, transaction_id
	) AS rn
FROM sales_transaction
)
SELECT 
	transaction_id,
	transaction_date,
	outlet_id
FROM transactions_by_oulet
WHERE rn = 1

-- 48. Find the latest transaction for every outlet.

WITH transactions_by_oulet AS (
SELECT
	transaction_id,
	transaction_date,
	outlet_id,
	ROW_NUMBER() OVER(
	PARTITION BY outlet_id
	ORDER BY transaction_date DESC, transaction_id DESC
	) AS rn
FROM sales_transaction
)
SELECT 
	transaction_id,
	transaction_date,
	outlet_id
FROM transactions_by_oulet
WHERE rn = 1

-- 49. Identify the first sale of every product.

WITH product_sales AS  (
	SELECT
		sd.product_id,
		p.product_name,
		st.transaction_id,
		st.transaction_date,
		ROW_NUMBER() OVER(
			PARTITION BY sd.product_id
			ORDER BY st.transaction_date, st.transaction_id
		) AS rn
	FROM sales_transaction st
	JOIN sales_detail sd
	ON st.transaction_id = sd.transaction_id
	JOIN product p
	ON p.product_id = sd.product_id
) 

SELECT
    product_id,
    product_name,
    transaction_id,
    transaction_date
FROM product_sales
WHERE rn = 1
ORDER BY product_id;

-- 50 .Identify the most recent sale of every product.

WITH product_sales AS  (
	SELECT
		sd.product_id,
		p.product_name,
		st.transaction_id,
		st.transaction_date,
		ROW_NUMBER() OVER(
			PARTITION BY sd.product_id
			ORDER BY st.transaction_date DESC, st.transaction_id DESC
		) AS rn
	FROM sales_transaction st
	JOIN sales_detail sd
	ON st.transaction_id = sd.transaction_id
	JOIN product p
	ON p.product_id = sd.product_id
) 

SELECT
    product_id,
    product_name,
    transaction_id,
    transaction_date
FROM product_sales
WHERE rn = 1
ORDER BY product_id;

-- RANK()

-- 51. Rank customers by total spending.

SELECT
    customer_id,
    SUM(transaction_total) AS total_spending,
    RANK() OVER (
        ORDER BY SUM(transaction_total) DESC
    ) AS spending_rank
FROM sales_transaction
GROUP BY customer_id;

-- 52. Rank products by total revenue.

SELECT
	sd.product_id,
	p.product_name,
	SUM(sale_amount) product_revenue,
	RANK() OVER(
		ORDER BY SUM(sale_amount) DESC
	) AS rank_by_revenue
FROM sales_detail sd
JOIN product p
ON p.product_id = sd.product_id
GROUP BY sd.product_id, p.product_name

-- 53. Rank outlets by total revenue.

SELECT
	outlet_id,
	SUM(transaction_total) AS outlet_revenue,
	RANK() OVER(
		ORDER BY SUM(transaction_total) DESC
	) AS rank_by_revenue
FROM sales_transaction
GROUP BY outlet_id

-- 54. Rank staff by sales generated.

SELECT
	staff_id,
	SUM(transaction_total) AS sales_generated,
	RANK() OVER(
		ORDER BY SUM(transaction_total) DESC
	) AS rank_by_sales
FROM sales_transaction
GROUP BY staff_id

-- 55. Rank cities by total sales.

SELECT
	so.city,
	SUM(st.transaction_total) AS revenue_by_city,
	RANK() OVER(
		ORDER BY SUM(st.transaction_total) DESC
	) AS rank_by_revenue
FROM sales_transaction st
JOIN sales_outlet so
ON st.outlet_id = so.outlet_id
GROUP BY so.city

-- DENSE_RANK()

-- 56.Dense rank products by revenue.

SELECT
	sd.product_id,
	p.product_name,
	SUM(sale_amount) product_revenue,
	DENSE_RANK() OVER(
		ORDER BY SUM(sale_amount) DESC
	) AS rank_by_revenue
FROM sales_detail sd
JOIN product p
ON p.product_id = sd.product_id
GROUP BY sd.product_id, p.product_name

-- 57. Dense rank customers by spending.

SELECT
    customer_id,
    SUM(transaction_total) AS total_spending,
    DENSE_RANK() OVER (
        ORDER BY SUM(transaction_total) DESC
    ) AS spending_rank
FROM sales_transaction
GROUP BY customer_id;

-- 58. Dense rank outlets by sales.

SELECT
	outlet_id,
	SUM(transaction_total) AS outlet_revenue,
	RANK() OVER(
		ORDER BY SUM(transaction_total) DESC
	) AS rank_by_revenue
FROM sales_transaction
GROUP BY outlet_id

-- 59. Dense rank categories by revenue.

SELECT
	pt.product_category,
	SUM(sd.sale_amount) AS revenue,
	DENSE_RANK() OVER(
		ORDER BY SUM(sd.sale_amount) DESC
	) AS rank_by_revenue
FROM sales_detail sd
JOIN product p
ON p.product_id = sd.product_id
JOIN product_type pt
ON pt.product_type_id = p.product_type_id
GROUP BY pt.product_category

-- 60. Dense rank staff by sales.

SELECT
	staff_id,
	SUM(transaction_total) AS sales_generated,
	DENSE_RANK() OVER(
		ORDER BY SUM(transaction_total) DESC
	) AS rank_by_sales
FROM sales_transaction
GROUP BY staff_id

-- Top-N Problems

-- 61. Find the top 3 customers.

WITH customer_spending AS (
SELECT
    customer_id,
    SUM(transaction_total) AS total_spending,
    RANK() OVER (
        ORDER BY SUM(transaction_total) DESC
    ) AS spending_rank
FROM sales_transaction
GROUP BY customer_id
)
SELECT *
FROM customer_spending
WHERE spending_rank <= 3

-- 62. Find the top 5 products.

WITH ranked_products AS (
SELECT
	sd.product_id,
	p.product_name,
	SUM(sale_amount) product_revenue,
	DENSE_RANK() OVER(
		ORDER BY SUM(sale_amount) DESC
	) AS rank_by_revenue
FROM sales_detail sd
JOIN product p
ON p.product_id = sd.product_id
GROUP BY sd.product_id, p.product_name
)

SELECT * 
FROM ranked_products
WHERE rank_by_revenue <= 5

-- 63. Find the top transaction per outlet.

WITH ranked_transactions AS (
	SELECT
		outlet_id,
		transaction_id,
		transaction_date,
		transaction_total,
		ROW_NUMBER() OVER(
			PARTITION BY outlet_id
			ORDER BY transaction_total DESC
		) AS rk
	FROM sales_transaction
)

SELECT *
FROM ranked_transactions
WHERE rk = 1

-- 64. Find the top 3 products in each category.
WITH ranked_products AS (
SELECT
	pt.product_category,
	sd.product_id,
	p.product_name,
	SUM(sd.sale_amount) AS revenue,
	RANK() OVER(
		PARTITION BY pt.product_category
		ORDER BY SUM(sd.sale_amount) DESC
	) AS product_rank
FROM sales_detail sd
JOIN product p
ON p.product_id = sd.product_id
JOIN product_type pt
ON p.product_type_id = pt.product_type_id
GROUP BY 
	sd.product_id, 
	p.product_name, 
	pt.product_category
)

SELECT * FROM ranked_products
WHERE product_rank <= 3

-- 65. Find the top customer in each city.

WITH ranked_customers AS (
	SELECT 
		so.city,
		st.customer_id,
		SUM(st.transaction_total) AS total_spending,
		RANK() OVER(
			PARTITION BY so.city
			ORDER BY SUM(st.transaction_total) DESC
		) AS customer_rank
	FROM sales_transaction st
	JOIN sales_outlet so
	ON st.outlet_id = so.outlet_id
	GROUP BY st.customer_id, so.city
)

SELECT * 
FROM ranked_customers
WHERE customer_rank = 1

-- NTILE()

-- 66. Divide customers into 4 spending quartiles.

SELECT
    customer_id,
    customer_spending,
    NTILE(4) OVER (ORDER BY customer_spending DESC) AS spending_tier
FROM (
    SELECT 
        customer_id,
        SUM(transaction_total) AS customer_spending
    FROM sales_transaction
    GROUP BY customer_id
) t;

-- 67. Divide products into 5 revenue groups.

SELECT
	product_id,
	product_name,
	product_revenue,
	NTILE(5) OVER(
		ORDER BY product_revenue DESC
	) AS product_tier
FROM (
SELECT 
	p.product_id,
	p.product_name,
	SUM(sd.sale_amount) AS product_revenue
FROM sales_detail sd
JOIN product p
ON p.product_id = sd.product_id
GROUP BY p.product_id, p.product_name)

-- 68. Divide outlets into revenue quartiles.

WITH outlet_revenue AS (
	SELECT
		outlet_id,
		SUM(transaction_total) AS outlet_revenue
	FROM sales_transaction
	GROUP BY outlet_id
)

SELECT
	outlet_id,
	outlet_revenue,
	NTILE(4) OVER(
		ORDER BY outlet_revenue DESC
	) AS quartile
FROM outlet_revenue

-- 69. Divide transactions into 10 buckets.

SELECT
	transaction_id,
	transaction_date,
	NTILE(10) OVER(
		ORDER BY transaction_total
	) AS bucket
FROM sales_transaction

-- 70. Divide staff into performance quartiles.

WITH staff_sales AS (
	SELECT 
		s.staff_id,
		s.first_name,
		s.last_name,
		s.location,
		SUM(st.transaction_total) AS sales
	FROM sales_transaction st
	JOIN staff s
	ON s.staff_id = st.staff_id
	GROUP BY s.staff_id
)

SELECT
	staff_id
	first_name,
	last_name,
	location,
	sales,
	NTILE(4) OVER(
		ORDER BY sales DESC
	) AS performance_tier
FROM staff_sales

-- PERCENT_RANK()

-- 71. Calculate percentile ranking of customers.

WITH customer_spending AS (
    SELECT 
        customer_id,
        SUM(transaction_total) AS total_spending
    FROM sales_transaction
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_spending,
    PERCENT_RANK() OVER (ORDER BY total_spending DESC) AS percentile_rank
FROM customer_spending;

-- 72. Calculate percentile ranking of products.

WITH product_revenue AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(sd.sale_amount) AS total_revenue
    FROM sales_detail sd
    JOIN product p ON p.product_id = sd.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    total_revenue,
    PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS percentile_rank
FROM product_revenue;

-- 73. Calculate percentile ranking of transactions.

SELECT
    transaction_id,
    transaction_total,
    PERCENT_RANK() OVER (ORDER BY transaction_total DESC) AS percentile_rank
FROM sales_transaction;

-- 74. Calculate percentile ranking of outlets.

WITH outlet_revenue AS (
    SELECT 
        o.outlet_id,
		o.city,
        SUM(s.transaction_total) AS total_revenue
    FROM sales_transaction s
    JOIN sales_outlet o ON o.outlet_id = s.outlet_id
    GROUP BY o.outlet_id, o.city
)
SELECT
    outlet_id,
   	city,
    total_revenue,
    PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS percentile_rank
FROM outlet_revenue;

-- 75. Find customers in the top 10%.

WITH customer_spending AS (
    SELECT 
        customer_id,
        SUM(transaction_total) AS total_spending,
		PERCENT_RANK() OVER (ORDER BY SUM(transaction_total) DESC) AS percentile_rank
    FROM sales_transaction
    GROUP BY customer_id
)
SELECT *
FROM customer_spending
WHERE percentile_rank <= 0.10;

-- CUME_DIST()

-- 76. Calculate cumulative distribution of customers by spending.

SELECT
    customer_id,
    SUM(transaction_total) AS total_spending,
    CUME_DIST() OVER (
        ORDER BY SUM(transaction_total) DESC
    ) AS cumulative_distribution
FROM sales_transaction
GROUP BY customer_id;

-- 77. Calculate cumulative distribution of products by revenue.

WITH sales_revenue AS (
	SELECT
		product_id,
		SUM(sale_amount) AS revenue
	FROM sales_detail
	GROUP BY product_id
)

SELECT 
	product_id,
	revenue,
	CUME_DIST() OVER(
		ORDER BY revenue DESC) 
		AS cum_distribution
FROM sales_revenue;

-- 78. Calculate cumulative distribution of transactions.

SELECT
	transaction_id,
	transaction_total,
	CUME_DIST() OVER(
		ORDER BY transaction_total DESC)
		AS cum_distribution
FROM sales_transaction;

-- 79. Find transactions within the top 20%.

WITH transaction_dist AS (
	SELECT
		transaction_id,
		transaction_total,
		CUME_DIST() OVER(
			ORDER BY transaction_total DESC)
			AS cum_distribution
	FROM sales_transaction
)

SELECT * FROM transaction_dist
WHERE cum_distribution < 0.20;

-- 80. Find products within the top 5%.

WITH product_rev AS (
	SELECT
		sd.product_id,
		p.product_name,
		SUM(sd.sale_amount) AS product_revenue
	FROM sales_detail sd
	JOIN product p
	ON sd.product_id = p.product_id
	GROUP BY sd.product_id, p.product_name
),
cum_dist AS (
	SELECT *,
		CUME_DIST() OVER(
		ORDER BY product_revenue DESC)
		AS cumulative_distribution
	FROM product_rev
)

SELECT * FROM cum_dist
WHERE cumulative_distribution <= 0.05;


-- Part 3 — Value Functions (81–100)

-- Functions:
/*
LAG()
LEAD()
FIRST_VALUE()
LAST_VALUE()
NTH_VALUE()
LAG()
*/

-- 81. Show each transaction and previous transaction amount.

SELECT
    transaction_id,
    transaction_date,
    transaction_total,
    LAG(transaction_total, 1, 0) OVER (
        ORDER BY transaction_date, transaction_id
    ) AS previous_amount
FROM sales_transaction;

-- 82. Calculate difference from previous transaction.

WITH previous_trans AS (
    SELECT
        transaction_id,
        transaction_date,
        transaction_total,
        LAG(transaction_total, 1, 0) OVER (
            ORDER BY transaction_date, transaction_id
        ) AS previous_amount
    FROM sales_transaction
)
SELECT
    *,
    transaction_total - previous_amount AS difference
FROM previous_trans;

-- 83. Calculate growth percentage from previous transaction.

WITH previous_trans AS (
    SELECT
        transaction_id,
        transaction_date,
        transaction_total,
        LAG(transaction_total, 1, 0) OVER (
            ORDER BY transaction_date, transaction_id
        ) AS previous_amount
    FROM sales_transaction
)
SELECT
    *,
    transaction_total - previous_amount AS difference,
	ROUND((transaction_total - previous_amount) * 100 /
	NULLIF (previous_amount, 0), 2) AS percent_change	
FROM previous_trans;

-- 84. Compare daily sales to previous day.

WITH daily_sales AS (
    SELECT
        transaction_date,
        SUM(transaction_total) AS daily_sales
    FROM sales_transaction
    GROUP BY transaction_date
),
daily_details AS (
    SELECT
        transaction_date,
        daily_sales,
        LAG(daily_sales, 1, 0) OVER (
            ORDER BY transaction_date
        ) AS previous_day_sales
    FROM daily_sales
)
SELECT
    transaction_date,
    daily_sales,
    previous_day_sales,
    ROUND(
        (daily_sales - previous_day_sales) * 100.0
        / NULLIF(previous_day_sales, 0),
        2
    ) AS percent_change
FROM daily_details;

-- 85. Compare outlet revenue to previous outlet.

WITH outlet_revenue AS (
    SELECT
        outlet_id,
        SUM(transaction_total) AS revenue
    FROM sales_transaction
    GROUP BY outlet_id
),
revenue_comparison AS (
    SELECT
        outlet_id,
        revenue,
        LAG(revenue) OVER (
            ORDER BY revenue DESC
        ) AS previous_revenue
    FROM outlet_revenue
)
SELECT
    outlet_id,
    revenue,
    previous_revenue,
    revenue - previous_revenue AS difference
FROM revenue_comparison;

-- LEAD()

-- 86. Show next transaction amount.

SELECT
    transaction_id,
    transaction_date,
    transaction_total,
    LEAD(transaction_total, 1, 0) OVER (
        ORDER BY transaction_date, transaction_id
    ) AS next_amount
FROM sales_transaction;

-- 87. Calculate difference to next transaction.

WITH next_transaction AS (
    SELECT
        transaction_id,
        transaction_date,
        transaction_total,
        LEAD(transaction_total, 1, 0) OVER (
            ORDER BY transaction_date, transaction_id
        ) AS next_amount
    FROM sales_transaction
)
SELECT
    *,
    next_amount - transaction_total AS difference
FROM next_transaction;

-- 88. Show next purchase date for each customer.

SELECT
    customer_id,
    transaction_id,
    transaction_total,
    transaction_date,
    LEAD(transaction_date) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date, transaction_id
    ) AS next_order
FROM sales_transaction;

-- 89. Calculate days until next purchase.

WITH next_orders AS (
	SELECT
	    customer_id,
	    transaction_id,
	    transaction_total,
	    transaction_date,
	    LEAD(transaction_date) OVER (
	        PARTITION BY customer_id
	        ORDER BY transaction_date, transaction_id
	    ) AS next_order
	FROM sales_transaction
)

SELECT 
	customer_id,
	transaction_id,
	transaction_total,
	transaction_date,
	next_order,
	COALESCE(next_order - transaction_date, 0) AS days_to_next_order
FROM next_orders

-- 90. Show next sale amount for each product.

SELECT
    sd.product_id,
    sd.transaction_id,
    st.transaction_date,
    sd.sale_amount,
    LEAD(sd.sale_amount) OVER (
        PARTITION BY sd.product_id
        ORDER BY st.transaction_date, sd.transaction_id
    ) AS next_sale_amount
FROM sales_detail sd
JOIN sales_transaction st
    ON sd.transaction_id = st.transaction_id;

-- FIRST_VALUE()

-- 91. Show each customer purchase and their first purchase amount.

SELECT
	customer_id,
	transaction_id,
	transaction_date,
	transaction_total,
	FIRST_VALUE(transaction_total) OVER(
		PARTITION BY customer_id
		ORDER BY transaction_date, transaction_id)
	AS first_purchase_amount
FROM sales_transaction

-- 92. Show each outlet transaction and outlet's first transaction.

SELECT
	outlet_id,
	transaction_id,
	transaction_date,
	transaction_total,
	FIRST_VALUE(transaction_total) OVER(
		PARTITION BY outlet_id
		ORDER BY transaction_date, transaction_id)
	AS first_purchase_amount
FROM sales_transaction

-- 93. Show each product sale and first sale price.

SELECT
	p.product_id,
	p.product_name,
	st.transaction_date,
	st.transaction_id,
	sd.sale_amount,
	FIRST_VALUE(sd.sale_amount) OVER(
		PARTITION BY p.product_id
		ORDER BY st.transaction_date, st.transaction_id)
	AS first_sales_amount
FROM sales_detail sd
JOIN sales_transaction st
ON st.transaction_id = sd.transaction_id
JOIN product p
ON p.product_id = sd.product_id

-- 94. Calculate growth from first transaction.

SELECT
    customer_id,
    transaction_id,
    transaction_date,
    transaction_total,
    FIRST_VALUE(transaction_total) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date, transaction_id
    ) AS first_transaction_amount,
    transaction_total
      - FIRST_VALUE(transaction_total) OVER (
            PARTITION BY customer_id
            ORDER BY transaction_date, transaction_id
        ) AS growth_from_first
FROM sales_transaction;

-- 95. Calculate revenue growth from first sale.

SELECT
    customer_id,
    transaction_id,
    transaction_date,
    transaction_total,

    SUM(transaction_total) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_revenue,

    SUM(transaction_total) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    )
    -
    FIRST_VALUE(transaction_total) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date, transaction_id
    ) AS revenue_growth
FROM sales_transaction;

-- LAST_VALUE()

-- 96. Show each transaction and latest transaction amount.

SELECT 
	transaction_id,
	transaction_date,
	transaction_total,
	LAST_VALUE(transaction_total) OVER(
		ORDER BY transaction_date, transaction_id
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS last_transaction_amount
FROM sales_transaction

-- 97. Show each customer purchase and latest purchase amount.

SELECT
	customer_id,
	transaction_id,
	transaction_date,
	transaction_total,
	LAST_VALUE(transaction_total) OVER(
		PARTITION BY customer_id
		ORDER BY transaction_date, transaction_id
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS latest_transaction_amount
FROM sales_transaction

-- 98. Show each outlet transaction and latest transaction.

SELECT
	outlet_id,
	transaction_id,
	transaction_date,
	transaction_total,
	LAST_VALUE(transaction_date) OVER(
		PARTITION BY outlet_id
		ORDER BY transaction_date, transaction_id
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS last_transaction
FROM sales_transaction


-- NTH_VALUE()

-- 99. Show the third purchase made by every customer.

SELECT
	customer_id,
	transaction_id,
	transaction_date,
	transaction_total,
	NTH_VALUE(transaction_total, 3) OVER(
		PARTITION BY customer_id
		ORDER BY transaction_date, transaction_id
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS third_purchase_amount
FROM sales_transaction

-- 100. Show the fifth highest transaction amount for each outlet.

SELECT
	outlet_id,
	transaction_id,
	transaction_date,
	transaction_total,
	NTH_VALUE(transaction_total, 5) OVER(
		PARTITION BY outlet_id
		ORDER BY transaction_total DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	AS fifth_purchase_amount
FROM sales_transaction