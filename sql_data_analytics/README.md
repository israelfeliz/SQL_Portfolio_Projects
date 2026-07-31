# SQL Sales Data Analytics Project

## Overview

This project demonstrates how to perform exploratory data analysis (EDA) and business analytics using SQL on a sales dataset organized in a star schema.

The project covers common analytical techniques used by Data Analysts, Data Engineers, and Database Administrators, including:

* Database exploration
* Dimension exploration
* Time-based analysis
* Ranking analysis
* Cumulative metrics
* Performance analysis
* Customer and product reporting
* Business segmentation
* Part-to-whole analysis

The goal is to answer common business questions while practicing advanced SQL concepts such as Common Table Expressions (CTEs), Window Functions, Aggregate Functions, Date Functions, Ranking Functions, and analytical queries.

---

# Dataset

The project uses three CSV files representing a simple star schema.

```
dataset/
├── dim_customers.csv
├── dim_products.csv
└── fact_sales.csv
```

### Tables

### `fact_sales`

Contains sales transactions.

Typical fields include:

* Order Date
* Customer ID
* Product ID
* Sales Amount
* Quantity

### `dim_customers`

Contains customer information.

Examples:

* Customer Name
* Country
* Gender
* Birth Date

### `dim_products`

Contains product information.

Examples:

* Product Name
* Category
* Subcategory
* Cost
* Price

---

# Project Structure

```
.
├── dataset
│   ├── dim_customers.csv
│   ├── dim_products.csv
│   └── fact_sales.csv
│
├── docs
│   └── data_analytics.png
│
└── scripts
    ├── 00_init_database.sql
    ├── 01_database_exploration.sql
    ├── 02_dimensions_exploration.sql
    ├── 03_date_range_exploration.sql
    ├── 04_measures_exploration.sql
    ├── 05_magnitude_analysis.sql
    ├── 06_ranking_analysis.sql
    ├── 07_change_over_time_analysis.sql
    ├── 08_cumulative_analysis.sql
    ├── 09_performance_analysis.sql
    ├── 10_data_segmentation.sql
    ├── 11_part_to_whole_analysis.sql
    ├── 12_report_customers.sql
    └── 13_report_products.sql
```

---

# SQL Scripts

## 00 - Initialize Database

Creates the database objects and imports the CSV files.

---

## 01 - Database Exploration

Explores the database structure and validates the imported data.

Examples:

* List tables
* Count records
* Inspect columns
* Verify data quality

---

## 02 - Dimensions Exploration

Explores descriptive attributes such as:

* Products
* Categories
* Customers
* Countries

---

## 03 - Date Range Exploration

Analyzes the available time period.

Examples:

* Earliest sale
* Latest sale
* Total time span

---

## 04 - Measures Exploration

Calculates key business metrics.

Examples:

* Total Sales
* Average Sales
* Total Quantity
* Number of Orders

---

## 05 - Magnitude Analysis

Measures business volume across dimensions.

Examples:

* Sales by Product
* Sales by Category
* Sales by Customer

---

## 06 - Ranking Analysis

Ranks entities using SQL window functions.

Examples:

* Top Customers
* Best-selling Products
* Highest Revenue Categories

Functions used:

* `ROW_NUMBER()`
* `RANK()`
* `DENSE_RANK()`

---

## 07 - Change Over Time Analysis

Analyzes business trends over time.

Examples:

* Year-over-Year Sales
* Monthly Sales
* Growth Trends

Functions used:

* `LAG()`
* `LEAD()`
* `DATE_TRUNC()`
* `EXTRACT()`

---

## 08 - Cumulative Analysis

Calculates running totals and moving averages.

Examples:

* Running Sales
* Cumulative Revenue
* Rolling Metrics

Functions used:

* `SUM() OVER()`
* `AVG() OVER()`

---

## 09 - Performance Analysis

Evaluates business performance against historical trends.

Examples:

* Current vs Previous Year
* Current vs Average
* Performance Indicators

---

## 10 - Data Segmentation

Groups customers and products into business segments.

Examples:

* High-value Customers
* Low-value Customers
* Product Segments

---

## 11 - Part-to-Whole Analysis

Measures contribution percentages.

Examples:

* Product contribution
* Category contribution
* Market share

Functions used:

* Window Aggregates
* Percentage Calculations

---

## 12 - Customer Report

Generates a customer analytics report containing KPIs such as:

* Total Sales
* Total Orders
* Lifetime Value
* Average Order Value
* Customer Segmentation

---

## 13 - Product Report

Generates a product performance report including:

* Revenue
* Quantity Sold
* Ranking
* Sales Trend
* Product Performance

---

# SQL Concepts Covered

* SELECT
* WHERE
* GROUP BY
* HAVING
* ORDER BY
* Aggregate Functions
* CASE Expressions
* Common Table Expressions (CTEs)
* Window Functions
* Date Functions
* Ranking Functions
* Joins
* Subqueries
* Analytical Queries

---

# Skills Demonstrated

* SQL Data Analysis
* Business Intelligence
* Exploratory Data Analysis (EDA)
* Sales Analytics
* Customer Analytics
* Product Analytics
* Time Series Analysis
* Data Segmentation
* Performance Reporting
* Query Optimization
* Window Functions

---

# Tools

* PostgreSQL
* SQL
* CSV Files

---

# Learning Objectives

By completing this project, you will practice how to:

* Explore relational databases
* Analyze transactional sales data
* Build reusable SQL reports
* Write analytical SQL queries
* Apply window functions effectively
* Generate business insights from raw data
* Organize SQL projects using a professional folder structure

---

# Future Improvements

Potential enhancements include:

* Build interactive dashboards using Power BI or Tableau
* Automate data loading with Python
* Schedule SQL jobs
* Add indexes and query optimization examples
* Convert reports into materialized views
* Expand the dataset with additional business dimensions

---

# License

This project is intended for educational and portfolio purposes.
