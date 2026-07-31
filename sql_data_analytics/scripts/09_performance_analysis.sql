/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM s.order_date) AS year,
        p.product_name,
        SUM(s.sales_amount) AS current_sales
    FROM gold.fact_sales AS s
    JOIN gold.dim_products AS p
        ON s.product_id = p.product_id
    WHERE s.order_date IS NOT NULL
    GROUP BY
        EXTRACT(YEAR FROM s.order_date),
        p.product_name
),

sales_analysis AS (
    SELECT
        year,
        product_name,
        current_sales,

        ROUND(
            AVG(current_sales) OVER (
                PARTITION BY product_name
                ORDER BY year
            ),
            2
        ) AS avg_sales,

        LAG(current_sales) OVER (
            PARTITION BY product_name
            ORDER BY year
        ) AS prev_year_sales

    FROM yearly_sales
)

SELECT
    year,
    product_name,
    current_sales,
    avg_sales,

    current_sales - avg_sales AS diff_average,

    CASE
        WHEN current_sales > avg_sales THEN 'Above Avg'
        WHEN current_sales < avg_sales THEN 'Below Avg'
        ELSE 'No Change'
    END AS avg_change,

    prev_year_sales,

    current_sales - prev_year_sales AS prev_year_diff,

    CASE
        WHEN prev_year_sales IS NULL THEN NULL
        WHEN current_sales > prev_year_sales THEN 'Increased'
        WHEN current_sales < prev_year_sales THEN 'Decreased'
        ELSE 'No Change'
    END AS prev_year_change

FROM sales_analysis
ORDER BY
    product_name,
	year;
