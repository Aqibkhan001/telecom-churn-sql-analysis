

-- FILE: 02_load_data.sql
-- DESC: ETL - Load data from staging to tables
-- FILE: 02_load_data.sql
-- DESC: ETL - Load data from staging to tables
-- WARNING: Requires stg_telecom staging table.
-- Import CSV first via SSMS Import Flat File wizard.
-- Dataset: https://www.kaggle.com/datasets/blastchar/telco-customer-churn
--------------------------------------------------------------------------

USE TelecomChurn

-- Fix blank TotalCharges in staging
UPDATE stg_telecom
    SET TotalCharges = '0'
    WHERE LTRIM(RTRIM(TotalCharges)) = ''
    OR TotalCharges IS NULL

-- Load fact_churn
INSERT INTO fact_churn (CustomerID, ChurnFlag, Tenure, MonthlyCharges, TotalCharges)
SELECT
    customerID,
    CAST(Churn AS INT),
    tenure,
    MonthlyCharges,
    CAST(TotalCharges AS DECIMAL(10,2))
FROM stg_telecom

-- Load dim_customer
INSERT INTO dim_customer (CustomerID, Gender, SeniorCitizen, Partner, Dependents)
SELECT customerID, gender, SeniorCitizen, Partner, Dependents
FROM stg_telecom

-- Load dim_services
INSERT INTO dim_services (CustomerID, PhoneService, InternetService, StreamingTV, TechSupport)
SELECT customerID, PhoneService, InternetService, StreamingTV, TechSupport
FROM stg_telecom

-- Load dim_contract
INSERT INTO dim_contract (CustomerID, ContractType, PaymentMethod, PaperlessBilling)
SELECT customerID, Contract, PaymentMethod, PaperlessBilling
FROM stg_telecom

-- Verify row counts
SELECT COUNT(*) AS fact_churn_rows     FROM fact_churn
SELECT COUNT(*) AS dim_customer_rows   FROM dim_customer
SELECT COUNT(*) AS dim_services_rows   FROM dim_services
SELECT COUNT(*) AS dim_contract_rows   FROM dim_contract
