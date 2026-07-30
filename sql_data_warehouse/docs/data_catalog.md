**Project**: SQL Data Warehouse
**Architecture:** Bronze → Silver → Gold
**Database:** PostgreSQL

# Data Catalog for Gold Layer

## Overview

The Gold layer exposes a star schema optimized for reporting and analytics.
---

### **Dimension: gold.dim_customers**
- **Business Purpose:** Provides a consolidated customer profile by combining CRM and ERP customer information.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_id      | INT           | Unique numerical identifier assigned to each customer.                                        |
| customer_number  | NVARCHAR(30)  | Alphanumeric identifier representing the customer, used for tracking and referencing.         |
| first_name       | NVARCHAR(30)  | The customer's first name, as recorded in the system.                                         |
| last_name        | NVARCHAR(30)  | The customer's last name or family name.                                                     |
| country          | NVARCHAR(50)  | The country of residence for the customer (e.g., 'Australia').                               |
| marital_status   | NVARCHAR(10)  | The marital status of the customer (e.g., 'Married', 'Single').                              |
| gender           | NVARCHAR(10)  | The gender of the customer (e.g., 'Male', 'Female', 'n/a').                                  |
| birthdate        | DATE          | The date of birth of the customer, formatted as YYYY-MM-DD (e.g., 1971-10-06).               |
| create_date      | DATE          | The date and time when the customer record was created in the system|

---

### **Dimension: gold.dim_products**
- **Business Purpose:** Provides descriptive information about products.
- **Columns:**

| Column Name         | Data Type     | Description                                                                                   |
|---------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_id          | INT           | A unique identifier assigned to the product for internal tracking and referencing.            |
| product_number      | NVARCHAR(20)  | A structured alphanumeric code representing the product, often used for categorization or inventory. |
| product_name        | NVARCHAR(30)  | Descriptive name of the product, including key details such as type, color, and size.         |
| category_id         | NVARCHAR(30)  | A unique identifier for the product's category, linking to its high-level classification.     |
| category            | NVARCHAR(50)  | The broader classification of the product (e.g., Bikes, Components) to group related items.   |
| subcategory         | NVARCHAR(50)  | A more detailed classification of the product within the category, such as product type.      |
| maintenance_required| NVARCHAR(3)   | Indicates whether the product requires maintenance (e.g., 'Yes', 'No').                       |
| cost                | NUMERIC(10, 2)| The cost or base price of the product, measured in monetary units.                            |
| product_line        | NVARCHAR(30)  | The specific product line or series to which the product belongs (e.g., Road, Mountain).      |
| start_date          | DATE          | The date when the product became available for sale or use, stored in|

---

### **Fact: gold.fact_sales**
- **Business Purpose:** Stores transactional sales events and links customers and products for analysis.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(30)  | A unique alphanumeric identifier for each sales order (e.g., 'SO54496').                      |
| product_id      | INT           | Surrogate key linking the order to the product dimension table.                               |
| customer_id     | INT           | Surrogate key linking the order to the customer dimension table.                              |
| order_date      | DATE          | The date when the order was placed.                                                           |
| shipping_date   | DATE          | The date when the order was shipped to the customer.                                          |
| due_date        | DATE          | The date when the order payment was due.                                                      |
| quantity        | INT           | The number of units of the product ordered for the line item (e.g., 1).                       |
| price           | NUMERIC(10, 2)| The price per unit of the product for the line item, in whole currency units (e.g., 25).      |
| sales_amount    | NUMERIC(10, 2)| The total monetary value of the sale for the line item, in whole currency units (e.g., 25).   |

### Entity Relationship Summary
Fact Table-----------Dimensions
fact_sales-----------dim_customers
fact_sales-----------dim_products

### Data Lineage
CSV Files
     │
     ▼
Bronze Layer (Raw)
     │
     ▼
Silver Layer (Cleaned & Validated)
     │
     ▼
Gold Layer (Star Schema)
     │
     ▼
Reports • Dashboards • BI • Analytics

