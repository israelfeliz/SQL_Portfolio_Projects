/* 1. Products More Expensive Than Average
Find all products whose price is greater than the average price of all products.*/

SELECT 
	product_id,
	product_name,
	price
FROM product
WHERE price > 
	(SELECT AVG(price) FROM product)
ORDER BY price DESC

/* 2. Customers Older Than Average
Find customers whose birthdate indicates they are older than the average customer.*/

SELECT * FROM customer 
WHERE EXTRACT(YEAR FROM birthdate)::INTEGER < 
(
	SELECT AVG(EXTRACT(YEAR FROM birthdate))::INTEGER
	FROM customer
)
ORDER BY birthdate DESC

/* 3. Transactions Above Average Sale
Find all transactions whose transaction_total is greater than the average transaction total.*/

SELECT * 
FROM sales_transaction
WHERE transaction_total > 
(
	SELECT AVG(transaction_total)
	FROM sales_transaction
)

/* 4. Most Expensive Product
Find the product(s) with the highest price.*/

SELECT * FROM product
WHERE price = 
(
	SELECT MAX(price) FROM product
)

/* 5. Cheapest Product
Find the product(s) with the lowest price.*/

SELECT * FROM product
WHERE price = 
(
	SELECT MIN(price) FROM product
)

/* 6. Products in the Same Category as Latte
Find all products that belong to the same product category as the product named 'Latte'.*/

SELECT * FROM product 
WHERE product_type_id = 
(
	SELECT product_type_id 
	FROM product
	WHERE product_name = 'Latte'
)

/* 7. Customers Who Made Purchases
Find all customers who have at least one transaction.
Use IN or EXISTS.*/

SELECT * FROM customer
WHERE customer_id IN -- using IN
(
	SELECT customer_id FROM sales_transaction
)

SELECT * FROM customer C
WHERE EXISTS -- using EXISTS
(
	SELECT 1
	FROM sales_transaction st
	WHERE c.customer_id = st.customer_id
)

/* 8. Customers With Above-Average Spending
Find customers whose total spending exceeds the average customer spending.*/

SELECT * FROM 
(SELECT 
	customer_id,
	SUM(transaction_total) AS total_spending,
	ROUND(AVG(SUM(transaction_total)) OVER(), 2) AS avg_customer_spending
FROM sales_transaction
GROUP BY customer_id)t
WHERE total_spending > avg_customer_spending

/* 9. Products Never Sold
Find products that never appear in sales_detail.*/

SELECT * FROM product
WHERE product_id NOT IN -- uing NOT IN
(
	SELECT product_id FROM sales_detail
	WHERE product_id IS NOT NULL
)

SELECT * FROM product p
WHERE NOT EXISTS 
(
	SELECT 1
	FROM sales_detail sd
	WHERE sd.product_id = p.product_id
)

/* 10. Staff With No Sales 
Find staff members who have never processed a transaction. */

SELECT * FROM staff s
WHERE NOT EXISTS
(
    SELECT 1
    FROM sales_transaction st
    WHERE st.staff_id = st.staff_id
);

/* 11. Outlets With Sales Above Company Average
Find outlets whose total revenue exceeds the average revenue of all outlets. */

WITH outlet_revenue AS (
    SELECT 
        outlet_id,
        SUM(transaction_total) AS total_revenue,
		COUNT(*) order_count
    FROM sales_transaction
	GROUP BY outlet_id
)

SELECT 
	so.outlet_id,
	so.city,
	so.manager,
	outlet_revenue.order_count,
	outlet_revenue.total_revenue
FROM sales_outlet so
JOIN outlet_revenue
ON so.outlet_id = outlet_revenue.outlet_id
WHERE outlet_revenue.total_revenue > (
	 SELECT AVG(outlet_revenue.total_revenue) 
	 FROM outlet_revenue)

/* 12. Customers With More Transactions Than Average 
Find customers whose number of transactions is greater than the average number of transactions per customer.*/

WITH customers_transactions_count AS (
	SELECT 
		customer_id,
        COUNT(*) AS transactions_made
    FROM sales_transaction
    GROUP BY customer_id
)

SELECT 
	c.*,
	ct.transactions_made		
FROM customer c
JOIN customers_transactions_count ct
ON c.customer_id = ct.customer_id
WHERE ct.transactions_made > (
	SELECT AVG(transactions_made)
	FROM customers_transactions_count
);

/* 13. Products Sold More Than Average Quantity
Find products whose total quantity sold exceeds the average quantity sold across all products.*/

SELECT 
	t.product_id, 
	p.product_name,
	t.quantity_sold,
	t.avg_quantity_sold	
FROM
(SELECT
    product_id,
    SUM(quantity) AS quantity_sold,
	ROUND(AVG(SUM(quantity)) OVER()) AS avg_quantity_sold
FROM sales_detail
GROUP BY product_id) t
JOIN product p
ON t.product_id = p.product_id
WHERE quantity_sold > avg_quantity_sold


/* 14. Transactions Containing the Most Expensive Product 
Find all transactions that include the most expensive product.*/

SELECT 
	st.transaction_id,
	st.transaction_date,
	st.transaction_total,
	sd.product_id,
	sd.price,
	sd.sale_amount
FROM sales_transaction st
JOIN sales_detail sd
ON st.transaction_id = sd.transaction_id
WHERE product_id = (
		SELECT product_id
		FROM product
		WHERE price = (
 			SELECT MAX(price) FROM product))

/* 15. Highest Transaction Per Customer 
For each customer, find their largest transaction. 
Hint: Correlated subquery comparing each transaction against other transactions of the same customer.*/

SELECT 
	c.customer_id,
	c.customer_name,
	st.transaction_id,
	st.transaction_date,
	st.transaction_total AS max_transaction_amount
FROM customer c
JOIN sales_transaction st
ON c.customer_id =st.customer_id
WHERE st.transaction_total = (
	SELECT MAX(transaction_total)
	FROM sales_transaction st
	WHERE st.customer_id = c.customer_id)
ORDER BY transaction_total DESC

/* 16. Top-Selling Product in Each Product Type
Find the product with the highest quantity sold within each product type.*/

SELECT
    pt.product_type,
    p.product_name,
    SUM(sd.quantity) AS total_quantity_sold
FROM product_type pt
JOIN product p
    ON pt.product_type_id = p.product_type_id
JOIN sales_detail sd
    ON p.product_id = sd.product_id
GROUP BY
    pt.product_type_id,
    pt.product_type,
    p.product_id,
    p.product_name
HAVING SUM(sd.quantity) = (
    SELECT MAX(product_total)
    FROM (
        SELECT
            SUM(sd2.quantity) AS product_total
        FROM product p2
        JOIN sales_detail sd2
            ON p2.product_id = sd2.product_id
        WHERE p2.product_type_id = p.product_type_id
        GROUP BY p2.product_id
    ) AS x
)
ORDER BY pt.product_type;

/* 17. Highest Revenue Transaction Per Outlet
Find the transaction with the highest transaction_total for each outlet.*/

SELECT 
	so.outlet_id,
	so.outlet_type,
	so.city,
	st.transaction_id,
	st.transaction_date, 
	st.transaction_total AS max_transaction_amount
FROM sales_outlet so
JOIN sales_transaction st
ON so.outlet_id = st.outlet_id
WHERE st.transaction_total =
	(SELECT MAX(transaction_total)
	 FROM sales_transaction st
	 WHERE st.outlet_id = so.outlet_id)

/* 18. Customers Who Spend More Than Their Outlet Average
Find customers whose transaction amount is greater than the average transaction amount at
the outlet where the purchase occurred.*/

SELECT * FROM (
	SELECT
		customer_id,
		outlet_id,
		transaction_total,
		ROUND(AVG(transaction_total) 
		OVER(PARTITION BY outlet_id), 2)
		AS avg_transaction_outlet
	FROM sales_transaction)
WHERE transaction_total > avg_transaction_outlet
customer_id, customer_name

/* 19. Products Sold in Every Outlet
Find products that have been sold in all sales outlets.
Hint: Use nested subqueries with COUNT.*/

SELECT
    p.product_id,
    p.product_name
FROM product p
JOIN sales_detail sd
    ON p.product_id = sd.product_id
JOIN sales_transaction st
    ON sd.transaction_id = st.transaction_id
GROUP BY
    p.product_id,
    p.product_name
HAVING COUNT(DISTINCT st.outlet_id) =
(
    SELECT COUNT(*)
    FROM sales_outlet
);

/* 20. Customers Who Purchased Every Product Category
Find customers who have purchased at least one product from every product category.
Hint: Compare the count of distinct categories purchased by a customer against the total
number of categories.*/

SELECT
    c.customer_id,
    c.customer_name
FROM customer c
JOIN sales_transaction st
    ON c.customer_id = st.customer_id
JOIN sales_detail sd
    ON st.transaction_id = sd.transaction_id
JOIN product p
    ON sd.product_id = p.product_id
JOIN product_type pt
    ON p.product_type_id = pt.product_type_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(DISTINCT pt.product_category) =
(
    SELECT COUNT(DISTINCT product_category)
    FROM product_type
);


/* 21. Top 5 Customers by Revenue Without LIMIT in Outer Query
Find the top 5 customers by total spending using a subquery approach rather than simply:
ORDER BY total_spent DESC
LIMIT 5;
Try using a ranking-style subquery. */

-- I WOULD USE A CTE INSTEAD OF A SUBQUERY, BECAUSE OF READABILITY AND PERFORMANCE(20x FASTER)

SELECT
    customer_id,
    customer_name,
    total_spent
FROM
(
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(st.transaction_total) AS total_spent
    FROM customer c
    JOIN sales_transaction st
        ON c.customer_id = st.customer_id
    GROUP BY c.customer_id, c.customer_name
) customer_totals
WHERE
(
    SELECT COUNT(*)
    FROM
    (
        SELECT
            c.customer_id,
            SUM(st.transaction_total) AS total_spent
        FROM customer c
        JOIN sales_transaction st
            ON c.customer_id = st.customer_id
        GROUP BY c.customer_id
    ) ranked
    WHERE ranked.total_spent > customer_totals.total_spent
) < 5
ORDER BY total_spent DESC;

-- Using CTE

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

-- Return all customers who have made at least one transaction.

SELECT *
FROM customer
WHERE customer_id IN (
    SELECT customer_id 
    FROM sales_transaction)

-- List all products that appear in sales_detail.

SELECT * 
FROM product
WHERE product_id IN (
    SELECT product_id 
    FROM sales_detail)

-- Find customers who never made a transaction.

SELECT customer_id, customer_name 
FROM customer
WHERE customer_id IN (
    SELECT customer_id 
    FROM sales_transaction)

-- Find products that have never appeared in sales_detail.

SELECT * 
FROM product p
WHERE NOT EXISTS (
	SELECT 1
	FROM sales_detail sd
	WHERE p.product_id = sd.product_id)

-- Show transactions whose total is greater than the average transaction total.

SELECT transaction_id, transaction_total
FROM sales_transaction 
WHERE transaction_total > (
    SELECT AVG(transaction_total) 
    FROM sales_transaction
)

-- Return the product with the highest price.

SELECT *
FROM product
WHERE price = (
	SELECT MAX(price)
	FROM product
);

-- Find products whose price equals the minimum price within their category.

WITH all_products AS
	(SELECT 
		product_id,
		product_name,
		price,
		product_type,
		product_category
	FROM product p, product_type pt	
	WHERE p.product_type_id = pt.product_type_id
	ORDER BY product_category)

SELECT *
FROM all_products ap1
WHERE price =
(
    SELECT MIN(price)
    FROM all_products ap2
    WHERE ap2.product_category = ap1.product_category
);

-- Find customers whose total spending exceeds the average spending of all customers.

SELECT customer_id, SUM(transaction_total) AS total_spent
FROM sales_transaction
GROUP BY customer_id
HAVING SUM(transaction_total) > (
	SELECT AVG(total_spending) 
	FROM
		(SELECT 
			SUM(transaction_total) AS total_spending
		FROM sales_transaction
		GROUP BY customer_id))
ORDER BY total_spent DESC;

-- Find all transactions that include products from the "Coffee" category.

SELECT *
FROM sales_transaction
WHERE transaction_id IN
(
    SELECT sd.transaction_id
    FROM sales_detail sd
    WHERE sd.product_id IN
    (
        SELECT p.product_id
        FROM product p
        WHERE p.product_type_id IN
        (
            SELECT pt.product_type_id
            FROM product_type pt
            WHERE pt.product_category = 'Coffee')));

-- Return staff who processed at least one transaction.

SELECT *
FROM staff s
WHERE EXISTS
(
    SELECT 1
    FROM sales_transaction st
    WHERE st.staff_id = s.staff_id
);

-- Find the highest sale_amount recorded for each product.

SELECT product_id, sale_amount
FROM sales_detail
WHERE sale_amount = (
	SELECT MAX(sale_amount)
	FROM sales_detail sd
	WHERE product_id = product_id)

-- Find sales_detail rows where quantity is greater than the average quantity sold for that product.

SELECT * 
FROM sales_detail
WHERE quantity > 
(
	SELECT AVG(quantity)
	FROM sales_detail
	WHERE product_id = product_id
)

