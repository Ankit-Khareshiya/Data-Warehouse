/*
===============================================================================
Script: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This script refreshes data in the 'bronze' schema by reloading CSV files. 
    It performs the following actions:
    - Truncates existing data from all bronze tables.
    - Uses pgAdmin's Import/Export Data tool to load data from CSV files into each table.

Tables Involved:
    - bronze.crm_cust_info      ← loads from "cust_info.csv"
    - bronze.crm_prd_info       ← loads from "prd_info.csv"
    - bronze.crm_sales_details  ← loads from "sales_details.csv"
    - bronze.erp_cust_az12      ← loads from "CUST_AZ12.csv"
    - bronze.erp_loc_a101       ← loads from "LOC_A101.csv"
    - bronze.px_cat_g1v2        ← loads from "PX_CAT_G1V2.csv"

Usage Notes:
    - Run TRUNCATE commands first to clear old data.
    - Then use pgAdmin's Import/Export Data feature to import new CSV data.

===============================================================================
*/


TRUNCATE TABLE bronze.crm_cust_info;
-- Load data from external file "cust_info.csv" using Import/Export Data feature of pgAdmin4

TRUNCATE TABLE bronze.crm_prd_info;
-- Load data from external file "prd_info.csv" using Import/Export Data feature of pgAdmin4

TRUNCATE TABLE bronze.crm_sales_details;
-- Load data from external file "sales_details.csv" using Import/Export Data feature of pgAdmin4

TRUNCATE TABLE bronze.erp_cust_az12;
-- Load data from external file "CUST_AZ12.csv" using Import/Export Data feature of pgAdmin4

TRUNCATE TABLE bronze.erp_loc_a101;
-- Load data from external file "LOC_A101.csv" using Import/Export Data feature of pgAdmin4

TRUNCATE TABLE bronze.px_cat_g1v2;
-- Load data from external file "PX_CAT_G1V2.csv" using Import/Export Data feature of pgAdmin4
