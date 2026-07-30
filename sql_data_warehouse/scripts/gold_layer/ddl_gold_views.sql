/*
===============================================================================
Script Name   : gold_views.sql
Layer         : Gold
Schema        : gold
Author        : <Your Name>
Created Date  : 2026-07-30

Description:
    Creates the Gold layer views that provide business-ready, analytics-focused
    data models. The Gold layer transforms the cleansed Silver data into a
    dimensional model consisting of fact and dimension views optimized for
    reporting, dashboards, and analytical workloads.

    This script creates:
    - Customer dimension (dim_customers)
    - Product dimension (dim_products)
    - Sales fact view (fact_sales)

    The dimensional model follows a star schema design, enabling efficient
    querying and simplifying business intelligence reporting.

Source Layer:
    - Silver

Objects Created:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales

Data Characteristics:
    - Business-friendly column names.
    - Integrated CRM and ERP data.
    - Surrogate key generated for the product dimension.
    - Conformed dimensions shared across analytical queries.
    - Fact table linked to customer and product dimensions.
    - Optimized for BI tools, dashboards, KPIs, and ad hoc analysis.

Star Schema:
                        +--------------------+
                        |   dim_customers    |
                        +--------------------+
                                  |
                                  |
        +-------------------------+-------------------------+
        |                                                   |
        |                 fact_sales                        |
        |                                                   |
        +-------------------------+-------------------------+
                                  |
                                  |
                        +--------------------+
                        |    dim_products    |
                        +--------------------+

Notes:
    - The Gold layer contains presentation-ready data models.
    - Views are built from the validated and standardized Silver layer.
    - No additional data cleansing should be required at this stage.
    - Designed for business intelligence, reporting, and analytics.

Dependencies:
    - Schema: silver
    - Views:
        - silver.crm_cust_info
        - silver.crm_prd_info
        - silver.crm_sales_details
        - silver.erp_cust
        - silver.erp_loc
        - silver.erp_px_cat

===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT 
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	el.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr = 'Unknown' THEN ec.gen
		 ELSE COALESCE(ci.cst_gndr, 'Unknown')
	END gender,
	ec.bdate AS birthdate,
	ci.cst_create_date AS create_date	
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust ec
ON ci.cst_key = ec.cid
LEFT JOIN silver.erp_loc el
ON ci.cst_key = el.cid;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

CREATE OR REPLACE VIEW gold.dim_products AS 
SELECT 
	pr.prd_id AS product_id,
	pr.prd_cat_id AS category_id,
	pr.prd_key AS product_number,
	pr.prd_nm AS product_name,
	pr.prd_cost AS product_cost,
	pr.prd_line AS product_line,
	pr.prd_start_dt AS start_date,
	pr.prd_end_dt AS end_date,
	ct.cat AS category,
	ct.subcat AS subcategory,
	ct.maintenance
FROM silver.crm_prd_info AS pr
LEFT JOIN silver.erp_px_cat AS ct 
ON pr.prd_cat_id = ct.id;

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number,
	pr.prd_id AS product_id,
	sd.sls_cust_id AS customer_id,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price,
	sd.sls_sales AS sales_amount
FROM silver.crm_sales_details sd
LEFT JOIN silver.crm_prd_info pr
ON sd.sls_prd_key = pr.prd_key
WHERE prd_end_dt IS NULL; -- Ensure we don't get duplicates


