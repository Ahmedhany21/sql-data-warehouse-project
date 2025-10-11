/*
=======================================================================================
Quality Checks
=======================================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'Silver' Schema. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data Standardization and consistency.
    - Invalid data ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
*/

USE DataWareHouse;
Go
--------------------------------------------------------------------------------
-- Cleanning Steps for data to be transfered from bronze layer to silver layer
--------------------------------------------------------------------------------

--1) cust_info
-- Check for duplicated values for the primary key
SELECT cst_id, COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

SELECT cst_id
FROM bronze.crm_cust_info
WHERE cst_id IS NULL;

-- Check for all string format if they have space or not 
-- Check for Unwanted Spaces for the first name
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check for Unwanted Spaces for the last name
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check for Unwanted Spaces for the Martial Status
SELECT cst_martial_status
FROM bronze.crm_cust_info
WHERE cst_martial_status!= TRIM(cst_martial_status);

-- Check for Unwanted Spaces for the Gender
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr!= TRIM(cst_gndr);

-- Knowing the distinct values to convert from abbreviation to full friendly-name
SELECT DISTINCT(cst_martial_status)
FROM bronze.crm_cust_info;

-- Knowing the distinct values to convert from abbreviation to User friendly-name
SELECT DISTINCT(cst_gndr)
FROM bronze.crm_cust_info;
--------------------------------------------------------------------

-- 2) prd_info

-- Check for duplicated values for the primary key
SELECT prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for quality for the number
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check for Distinct Values to Convert from abbreviation to User-Friendly name
SELECT DISTINCT(prd_line) FROM bronze.crm_prd_info;

-- Validating the datetime values in last two columns
SELECT * FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

SELECT
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC) - 1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

----------------------------------------------------------------------------
-- 3) crm_sales_details
-- Check Unwanted spaces
SELECT sls_ord_num 
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Check unwanted data types or data values 
SELECT NULLIF(sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101 
OR sls_order_dt < 19000101;

-- Check unwanted data types or data values 
SELECT NULLIF(sls_ship_dt,0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101 
OR sls_ship_dt < 19000101;

-- Check unwanted data types or data values 
SELECT NULLIF(sls_due_dt,0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101 
OR sls_due_dt < 19000101;

SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Putting rules to apply for the problem
-- 1) If sales is negative, zero or null, derive it using Quantity and price
-- 2) If Price is zero or null, calculate it using sales and quantity
-- 3) If price is Negative, convert it to a positive value
SELECT DISTINCT 
sls_sales AS OLD_SALES,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * sls_price THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
sls_quantity,
sls_price AS OLD_PRICE,
CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity,0)
	ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
-- WHERE sls_sales != sls_quantity * sls_price
-- OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
-- OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_sales <= 0
-- ORDER BY sls_sales, sls_quantity, sls_price;
--------------------------------------------------------------------------
-- 4) erp_cust_az12

-- Matching cid in cus_info with cust_az12
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
		ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info);
SELECT * FROM silver.crm_cust_info;

-- Checking for Unwanted or out of range values
SELECT DISTINCT
CASE WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
	 WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female'
	 ELSE 'N/A'
END AS gen
FROM bronze.erp_cust_az12;

------------------------------------------------------------------
-- 5) erp_loc_a101
SELECT 
REPLACE(cid, '-', '') AS cid
from bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info);

SELECT DISTINCT 
cntry,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US' ,'USA') THEN 'United States'
	 WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'N/A'
	 ELSE TRIM(cntry)
END AS new_cntry
FROM bronze.erp_loc_a101;

SELECT distinct cntry FROM bronze.erp_loc_a101;

SELECT * FROM bronze.erp_loc_a101;
SELECT * FROM silver.crm_cust_info;

-----------------------------------------------------------------------
-- 6) erp_px_cat_g1v2

SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2;

SELECT 
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT * FROM silver.crm_prd_info;
