# SQL Data Warehouse Project

A modern SQL Data Warehouse built with **PostgreSQL** following the **Medallion Architecture (Bronze → Silver → Gold)**. This project demonstrates how to ingest raw data from multiple source systems, clean and standardize it through ETL processes, and expose a business-ready dimensional model for reporting and analytics.

---

## Project Overview

The objective of this project is to build a complete data warehouse from scratch using SQL and PostgreSQL.

The warehouse integrates data from two source systems:

- **CRM** – Customers, Products, and Sales
- **ERP** – Customer demographics, Locations, and Product Categories

The data flows through three layers:

- **Bronze** – Raw data ingestion
- **Silver** – Data cleansing and transformation
- **Gold** – Dimensional model for analytics

---

## Architecture

```
                 Source Systems
              +-------------------+
              |      CRM          |
              |      ERP          |
              +-------------------+
                       |
                       ▼
              +-------------------+
              |   Bronze Layer    |
              |   Raw Data        |
              +-------------------+
                       |
                       ▼
              +-------------------+
              |   Silver Layer    |
              | Clean & Validate  |
              +-------------------+
                       |
                       ▼
              +-------------------+
              |    Gold Layer     |
              | Star Schema Views |
              +-------------------+
                       |
                       ▼
          Reports • Dashboards • Analytics
```

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| Database | PostgreSQL |
| Language | SQL (PL/pgSQL) |
| ETL | Stored Procedures |
| Data Loading | PostgreSQL COPY |
| Version Control | Git |

---

## Project Structure

```
.
├── data
│   ├── source_crm
│   └── source_erp
│
├── docs
│   ├── data_catalog.md
│   ├── naming_conventions.md
│   ├── data_flow.png
│   ├── data_integration.png
│   ├── data_modeling.png
│   ├── dwh_architecture.png
│   └── layers.png
│
├── scripts
│   ├── create_dwh
│   ├── bronze_layer
│   ├── silver_layer
│   └── gold_layer
│
└── tests
    ├── quality_check_silver.sql
    └── quality_checks_gold.sql
```

---

# Data Warehouse Layers

## Bronze Layer

The Bronze layer stores raw data exactly as received from the source systems.

### Responsibilities

- Load CSV files
- Preserve original values
- No transformations
- No validation
- Full refresh loads

### Objects

Tables:

- crm_cust_info
- crm_prd_info
- crm_sales_details
- erp_cust
- erp_loc
- erp_px_cat

Procedure:

```
CALL bronze.load_bronze();
```

---

## Silver Layer

The Silver layer contains cleansed, validated, and standardized data.

### Transformations

- Remove duplicates
- Trim whitespace
- Handle NULL values
- Normalize gender
- Normalize marital status
- Normalize countries
- Convert dates
- Convert numeric values
- Correct inconsistent sales values
- Apply business rules

Procedure:

```
CALL silver.load_silver();
```

---

## Gold Layer

The Gold layer exposes a dimensional model optimized for analytics.

### Views

Dimension tables

- dim_customers
- dim_products

Fact table

- fact_sales

These views are intended to be consumed by BI tools, dashboards, and analytical queries.

---

# ETL Workflow

```
CSV Files
     │
     ▼
Bronze Load Procedure
     │
     ▼
Bronze Tables
     │
     ▼
Silver Load Procedure
     │
     ▼
Silver Tables
     │
     ▼
Gold Views
     │
     ▼
Analytics & Reporting
```

---

# Data Model

The Gold layer follows a simple **Star Schema**.

```
                dim_customers
                      │
                      │
                      ▼
               +-------------+
               | fact_sales  |
               +-------------+
                      ▲
                      │
                      │
                dim_products
```

---

# Running the Project

## 1. Create the Database

Run:

```
scripts/create_dwh/init_database.sql
```

or

```bash
./scripts/create_dwh/init_database.sh
```

---

## 2. Create Bronze Tables

Execute

```
scripts/bronze_layer/ddl_bronze.sql
```

---

## 3. Load Bronze Layer

```sql
CALL bronze.load_bronze();
```

---

## 4. Create Silver Tables

Execute

```
scripts/silver_layer/ddl_silver.sql
```

---

## 5. Load Silver Layer

```sql
CALL silver.load_silver();
```

---

## 6. Create Gold Views

Execute

```
scripts/gold_layer/ddl_gold_views.sql
```

---

## 7. Run Data Quality Checks

Silver

```
tests/quality_check_silver.sql
```

Gold

```
tests/quality_checks_gold.sql
```

---

# Documentation

The **docs/** directory contains additional project documentation.

| Document | Description |
|-----------|-------------|
| data_catalog.md | Data dictionary for all layers |
| naming_conventions.md | SQL naming standards |
| data_flow.png | ETL flow |
| data_integration.png | Source integration |
| data_modeling.png | Data model |
| dwh_architecture.png | Warehouse architecture |
| layers.png | Medallion architecture |

---

# Data Quality

Several validation rules are implemented during the ETL process.

Examples include:

- Duplicate detection
- Invalid dates
- Missing values
- Data standardization
- Business rule validation
- Sales recalculation
- Data type conversion

---

# Future Improvements

- Incremental loading
- Slowly Changing Dimensions (Type 2)
- Surrogate keys for all dimensions
- Index optimization
- Partitioning
- Scheduling with cron or Airflow
- Automated data quality reporting
- CI/CD pipeline
- Containerization with Docker

---

# Learning Objectives

This project demonstrates practical experience with:

- Data Warehouse Design
- Medallion Architecture
- ETL Development
- PostgreSQL
- SQL Programming
- PL/pgSQL Stored Procedures
- Data Cleansing
- Data Validation
- Data Modeling
- Star Schema Design
- Data Quality Testing

---

# Author

**Israel Feliz**

This project was developed as part of a portfolio focused on **Data Engineering** and **Database Administration**, showcasing end-to-end data warehouse design, ETL development, and dimensional modeling using PostgreSQL.