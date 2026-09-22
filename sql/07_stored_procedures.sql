------------------------------------------------
-- FILE: 07_stored_procedures.sql
-- DESC: Stored procedures for dynamic analysis
------------------------------------------------

USE TelecomChurn

-- Churn summary by contract type
CREATE PROCEDURE sp_ChurnByContract
    @ContractType VARCHAR(20)
AS
BEGIN
    SELECT
        COUNT(f.CustomerID) AS Total_Customers,
        SUM(f.ChurnFlag) AS Total_Churned,
        CAST(SUM(CAST(f.ChurnFlag AS FLOAT)) / COUNT(f.CustomerID) * 100.0 AS DECIMAL(5,2)) AS Churn_Rate_Pct,
        SUM(CASE WHEN f.ChurnFlag = 1 THEN f.MonthlyCharges ELSE 0 END) AS Revenue_At_Risk
    FROM fact_churn f
    JOIN dim_contract c ON f.CustomerID = c.CustomerID
    WHERE c.ContractType = @ContractType
END

-- Test
EXEC sp_ChurnByContract @ContractType = 'Month-to-month'
EXEC sp_ChurnByContract @ContractType = 'Two year'

-- Churn by tenure bucket with threshold filter
CREATE PROCEDURE sp_TenureChurn
    @MinChurnRate DECIMAL(5,2)
AS
BEGIN
    WITH TenureBuckets AS (
        SELECT
            CustomerID,
            ChurnFlag,
            CASE
                WHEN Tenure <= 12 THEN 'New'
                WHEN Tenure <= 24 THEN 'Developing'
                WHEN Tenure <= 48 THEN 'Established'
                ELSE 'Loyal'
            END AS Tenure_Bucket
        FROM fact_churn
    )
    SELECT
        Tenure_Bucket,
        COUNT(CustomerID) AS Total_Customers,
        SUM(ChurnFlag) AS Total_Churned,
        CAST(SUM(CAST(ChurnFlag AS FLOAT)) / COUNT(CustomerID) * 100.0 AS DECIMAL(5,2)) AS Churn_Rate_Pct
    FROM TenureBuckets
    GROUP BY Tenure_Bucket
    HAVING CAST(SUM(CAST(ChurnFlag AS FLOAT)) / COUNT(CustomerID) * 100.0 AS DECIMAL(5,2)) > @MinChurnRate
END

-- Test
EXEC sp_TenureChurn @MinChurnRate = 15.00
EXEC sp_TenureChurn @MinChurnRate = 40.00
