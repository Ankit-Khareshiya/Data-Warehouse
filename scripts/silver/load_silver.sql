/*
===============================================================================
Script: Transform Bronze Layer -> Silver Layer
===============================================================================
Script Purpose:
    This script transforms and loads cleaned data from the 'bronze' schema 
    into the 'silver' schema for standardized storage and analysis.
    It performs the following actions:
    - Truncates existing data from all silver tables.
    - Applies data cleaning, formatting, and transformation logic.
    - Inserts the refined data into corresponding silver tables.

Transformations Applied:
    - Standardized gender and marital status values.
    - Trimmed text fields to remove extra spaces.
    - Handled nulls and invalid dates.
    - Derived product category and product end dates.
    - Validated sales, price, and quantity values.
    - Normalized country codes to full country names.

Tables Involved:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat_g1v2

Usage Notes:
    - Ensure all bronze tables are loaded before running this script.
    - Run TRUNCATE before each INSERT for a clean reload.
===============================================================================
*/



-- silver.crm_cust_info
TRUNCATE TABLE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info (
    cst_id, cst_key, cst_firstname, cst_lastname,
    cst_marital_status, cst_gndr, cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname),
    TRIM(cst_lastname),
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END,
    cst_create_date
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL;

SELECT * FROM silver.crm_cust_info;


-- silver.crm_prd_info
TRUNCATE TABLE silver.crm_prd_info;

INSERT INTO silver.crm_prd_info (
    prd_id, cat_id, prd_key, prd_nm, prd_cost, 
    prd_line, prd_start_dt, prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    COALESCE(prd_cost, 0) AS prd_cost,
    CASE TRIM(prd_line)
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
	END AS prd_line,
    prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;

SELECT * FROM silver.crm_prd_info;


-- silver.crm_sales_details
TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id,
        sls_order_dt, sls_ship_dt, sls_due_dt,
        sls_sales, sls_quantity, sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
         THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales END,
	sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity,0) ELSE sls_price END
FROM bronze.crm_sales_details;

SELECT * FROM silver.crm_sales_details;


-- silver.erp_cust_az12
TRUNCATE TABLE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid FROM 4) ELSE cid END,
        CASE WHEN bdate > now()::DATE THEN NULL ELSE bdate END,
        CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
             WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
             ELSE 'n/a' END
FROM bronze.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12;


-- silver.erp_loc_a101
TRUNCATE TABLE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', ''),
        CASE 
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
            WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
            ELSE TRIM(cntry)
        END
FROM bronze.erp_loc_a101;

SELECT * FROM silver.erp_loc_a101;


-- silver.erp_px_cat_g1v2
TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT id, cat, subcat, maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT * FROM silver.erp_px_cat_g1v2;
