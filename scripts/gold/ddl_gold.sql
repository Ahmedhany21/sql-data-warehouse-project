/*
=====================================================================
DDL Scripts: Create Gold Views
=====================================================================
Scripts Purpose:
    This script creates views for the gold layer in the Data warehouse.
    The Gold Layer represents the final dimension and fact tables (Star schema)

    Each view performs transaformations and combines data from the Silver Layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These Views can be queried directly for analytics and reporting.
=====================================================================
*/

--  =====================================================================
--  CREATE Dimension: gold.dim_customers
--  =====================================================================
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_martial_status AS martial_status,
	CASE 
		WHEN ci.cst_gndr  != 'N/A' THEN ci.cst_gndr  -- CRM is the master for gender info
		ELSE COALESCE(ca.gen, 'N/A')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid;

-- SELECT DISTINCT gender FROM gold.dim_customers;

-- SELECT * FROM gold.dim_customers;

--  =====================================================================
--  CREATE Dimension: gold.dim_products
--  =====================================================================

CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS sub_category,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;

-- SELECT * FROM gold.dim_products;

--  =====================================================================
--  CREATE Dimension: gold.fact_sales
--  =====================================================================

CREATE OR ALTER VIEW gold.fact_sales AS 
SELECT
	sd.sls_ord_num AS order_num,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
ON sd.sls_cust_id = cu.customer_id;

-- SELECT * FROM gold.fact_sales;

-- SELECT * FROM gold.dim_customers;
-- SELECT * FROM gold.dim_products;
-- SELECT * FROM gold.fact_sales;
