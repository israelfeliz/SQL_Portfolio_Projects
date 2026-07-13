-- Find the total sales per customer (Standalone CTE)
WITH sales_per_customer AS (
	SELECT 
		customer_id,
		SUM(transaction_total) AS total_sales
	FROM sales_transaction
	GROUP BY customer_id
),

-- Find the last transaction date for each customer (Standalone CTE)
last_transaction_date AS (
	SELECT 
		customer_id,
		MAX(transaction_date) AS last_transaction_date
	FROM sales_transaction
		GROUP BY customer_id
),

-- Rank customers based on total sales (Nested CTE)
customer_rank AS (
	SELECT 
		customer_id,
		total_sales,
		RANK() OVER(ORDER BY total_sales DESC) AS customer_rank
	FROM sales_per_customer
),

-- Segment customers based on their total sales
customer_segments AS (
SELECT 
	customer_id,
	total_sales,
	CASE WHEN total_sales > 250 THEN 'High'
		 WHEN total_sales > 150 THEN 'Medium'
		 ELSE 'Low' 
	END AS customer_segment
FROM sales_per_customer
)

SELECT 
	c.customer_id,
	c.customer_name,
	spc.total_sales,
	ltd.last_transaction_date,
	cr.customer_rank,
	cs.customer_segment
FROM customer c
LEFT JOIN sales_per_customer spc
ON c.customer_id = spc.customer_id
LEFT JOIN last_transaction_date ltd
ON c.customer_id = ltd.customer_id
LEFT JOIN customer_rank cr
ON c.customer_id = cr.customer_id
LEFT JOIN customer_segments cs
ON c.customer_id = cs.customer_id

-- Find products above average revenue.

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

-- Find customers above average spending.

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

-- Show revenue percentage by product category.

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

-- Find outlets above average sales.

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

-- Calculate average product sales by category.

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

-- Calculate cumulative number of products sold.

WITH daily_sales AS (
    SELECT
        st.transaction_date,
        SUM(sd.quantity) AS products_sold
    FROM sales_transaction st
    JOIN sales_detail sd
        ON st.transaction_id = sd.transaction_id
    GROUP BY st.transaction_date
)
SELECT
    transaction_date,
    products_sold,
    SUM(products_sold)
        OVER (ORDER BY transaction_date)
        AS cum_products_sold
FROM daily_sales
ORDER BY transaction_date;

-- Calculate cumulative outlet revenue.

WITH outlet_revenue AS (
    SELECT
        st.transaction_date,
        st.outlet_id,
        SUM(sd.sale_amount) AS daily_revenue
    FROM sales_transaction st
    JOIN sales_detail sd
        ON st.transaction_id = sd.transaction_id
    GROUP BY
        st.transaction_date,
        st.outlet_id
)
SELECT
    transaction_date,
    outlet_id,
    daily_revenue,
    SUM(daily_revenue)
        OVER (
            PARTITION BY outlet_id
            ORDER BY transaction_date
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_revenue
FROM outlet_revenue
ORDER BY outlet_id, transaction_date;

-- Calculate cumulative category revenue.

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

-- Find the first transaction for every customer.

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

-- Find the first transaction for every outlet.

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

-- Identify the first sale of every product.

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

-- Identify the most recent sale of every product.

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

-- Rank products by total revenue.

WITH product_revenue AS (
    SELECT
        sd.product_id,
        p.product_name,
        SUM(sd.sale_amount) AS revenue
    FROM sales_detail sd
    JOIN product p
        ON p.product_id = sd.product_id
    GROUP BY sd.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS rank_by_revenue
FROM product_revenue;

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

-- Find the top 3 products in each category.

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

-- Find the top customer in each city.

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

-- Calculate cumulative distribution of customers by spending.

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
    CUME_DIST() OVER (
        ORDER BY total_spending DESC
    ) AS cumulative_distribution
FROM customer_spending;

-- This returns the products whose cumulative distribution places them in the top 20% of revenue.

WITH sales_revenue AS (
    SELECT
        product_id,
        SUM(sale_amount) AS revenue
    FROM sales_detail
    GROUP BY product_id
),
revenue_distribution AS (
    SELECT
        product_id,
        revenue,
        CUME_DIST() OVER (
            ORDER BY revenue DESC
        ) AS cum_distribution
    FROM sales_revenue
)
SELECT *
FROM revenue_distribution
WHERE cum_distribution <= 0.20;

-- Find products within the top 5%.

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
WHERE cumulative_distribution <= 0.05

-- Calculate growth percentage from previous transaction.

WITH previous_transaction AS (
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
FROM previous_transaction;

-- Compare daily sales to previous day.

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

-- Compare outlet revenue to previous outlet.

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

-- Calculate days until next purchase.

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

/* Top 5 Customers by Revenue Without LIMIT in Outer Query
Find the top 5 customers by total spending using a subquery approach rather than simply:
ORDER BY total_spent DESC
LIMIT 5;
Try using a ranking-style subquery. */


WITH customer_spending AS (
	SELECT
		st.customer_id,
		c.customer_name,
		SUM(st.transaction_total) total_spent
	FROM sales_transaction st
	JOIN customer c
	ON st.customer_id = c.customer_id
	GROUP BY st.customer_id, c.customer_name
), 

customer_rank AS (
	SELECT 
		customer_id,
		customer_name,
		total_spent,
		DENSE_RANK() OVER(ORDER BY total_spent DESC) ranking
	FROM customer_spending
)

SELECT * FROM customer_rank
WHERE ranking <= 5