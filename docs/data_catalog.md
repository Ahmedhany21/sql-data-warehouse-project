# Data Dictionary For Gold Layer

## Overview 

The Gold layer is the business-level data representation, structured to support analytical and reporting use cases. It contains of **dimension tables** and **fact tables** for specific bsuiness metrics.
---
### 1. **gold.dim_customers**
- **Purpose**: Stores customer details enriched with demographic and geographic data.
- **Columns**

| Column_Name       | Data Type    | Description |
| :---:             | :--:         | :--: |
| Customer_key      | INT          | Surrogate key uniquely each customer record in he dimension table |
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

### 2. **gold.dim_products**
- Purpose: Provides information about the products and their attributes 
- **Columns**

| Column_Name           | Data Type    | Description |
| :--:                  | :--:         | :--: |
| Product_key           | INT          | Surrogate key uniquely identifies each product record in he product dimension table |
| Product_id            | INT          | A Unique identifier assigned to the product for internal tracking and refrencing |
| Product_number        | NVARCHAR(50) | A structured alphanumeric code representing the product, often used for categorization or inventory |
| Product_name          | NVARCHAR(50) | Descriptive name of the product, including key details such as type, color and size |
| category_id           | NVARCHAR(50) | A unique identifier for the product's category, linking to its high-level classification |
| category              | NVARCHAR(50) | The broader classification of the product (e.g., Bikes, Components, ...) to group related items |
| subcategory           | NVARCHAR(50) | A more detailed classification of the product within the category, such as product type |
| maintenance_required  | NVARCHAR(50) | Indicates whether the product requires maintenance (e.g., 'Yes', 'No') |
| cost                  | INT          | The cost or base price of the product, measured in monetaury units |
| product_line          | NVARCHAR(50) | The specific product line or series to which the product belongs (e.g., Road, Mountain) |
| start_date            | DATE         | The date when the product became available for sales or use, stored in |

---

### 3. **gold.dim_sales**
- Purpose: Stores transactional sales data for analytical purpose 
- **Columns**

| Column_Name     | Data Type    | Description |
| :--:            | :--:         | :--: |
| order_number    | NVARCHAR(50) | Surrogate key uniquely identifies each product record in he product dimension table |
| product_key     | INT          | A Unique identifier assigned to the product for internal tracking and refrencing |
| customer_key    | INT          | A structured alphanumeric code representing the product, often used for categorization or inventory |
| order_date      | INT          | Descriptive name of the product, including key details such as type, color and size |
| shipping_date   | Date         | A unique identifier for the product's category, linking to its high-level classification |
| due_date        | Date         | The broader classification of the product (e.g., Bikes, Components, ...) to group related items |
| sales_amount    | INT          | A more detailed classification of the product within the category, such as product type |
| quantity        | INT          | Indicates whether the product requires maintenance (e.g., 'Yes', 'No') |
| price           | INT          | The cost or base price of the product, measured in monetaury units |
