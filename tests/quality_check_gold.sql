/*
=============================================================================
Quality Checks
=============================================================================
Scripts Purpose:
    This script performs quality checks to validate the integrity, consistency, and accuracy of the Gold Layer.
    These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referrential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analtyical purpose.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discriptive found during the checks.
*/

-- Ensuring That after Joining our tables together their is no duplicated values
SELECT cst_id, COUNT(*) FROM
(SELECT
ci.cst_id,
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_martial_status,
ci.cst_gndr,
ci.cst_create_date,
ca.bdate,
ca.gen,
la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid)t GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Making sufficient columns and remove unwanted ones
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr  != 'N/A' THEN ci.cst_gndr  -- CRM is the master for gender info
		 ELSE COALESCE(ca.gen, 'N/A')
	END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid
----------------------------------------------------------------
-- Ensuring That after Joining our tables together their is no duplicated values
SELECT prd_key , COUNT(*) FROM 
(SELECT 
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL)t GROUP BY prd_key
HAVING COUNT(*) > 1; -- Filtering out all historical data
--------------------------------------------------------------------
-- Renamed columns to be user-friendly usuable column names
SELECT 
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
----------------------------------------------------------------------
-- 
SELECT
	sd.sls_ord_num AS order_num,
	pr.product_key,
--	sd.sls_prd_key, -- Removing this to replace with the surrogate key in the gold layer 
--	sd.sls_cust_id, -- Removing this to replace with the surrogate key in the gold layer
	cu.customer_key AS order_key,
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

SELECT * FROM gold.dim_products;
-------------------------------------------------------- 
-- Checking the integrity of Views for the Gold Layer
SELECT *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL;
