# Data Dictionary For Gold Layer

## Overview 

The Gold layer is the business-level data representation, structured to support analytical and reporting use cases. It contains of **dimension tables** and **fact tables** for specific bsuiness metrics.
---
### 1. gold.dim_customers
- **Purpose**: Stores customer details enriched with demographic and geographic data.
- **Columns**

| Column_Name       | Data Type    | Description |
| :---:             | :--:         | :--: |
| Cusstomer_key     | INT          | Surrogate key uniquely each customer record in he dimension table |
| Customer_id       | INT          | Unique numerical identifier assigned to each customer |
| customer_number   | NVARCHAR(50) | Alphanumeric identifier assigend to each customer |
| first_name        | NVARCHAR(50) | The customer's first name, as recorded in the system |
| last_name         | NVARCHAR(50) | The customer's last name or family name, as recorded in the system |
| country           | NVARCHAR(50) | The country of residence for the customer (e.g., 'Autrialia') |
| martial_status    | NVARCHAR(50) | The martial status of the customer (e.g., 'Married', 'Single', 'N/A') |
| gender            | NVARCHAR(50) | The gender of he customer (e.g., 'Male', 'Female', 'N/A') |
| birthdate         | DATE         | The date of birth of the customer, formatted as YYYY-MM-DD (e.g., 1971-10-06) |
|create_date        | DATE         | The date and time when the customer record was created in the system |

--- 
