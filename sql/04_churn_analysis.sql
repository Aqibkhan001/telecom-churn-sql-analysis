------------------------------------------------
-- FILE: 04_churn_analysis.sql
-- DESC: Advanced churn analysis using CTEs
------------------------------------------------

USE TelecomChurn

-- Overall churn summary CTE
WITH ChurnSummary AS (
    SELECT
        COUNT(*) AS Total_Customers,
        SUM(ChurnFlag) AS Churned_Customers,
        CAST(SUM(ChurnFlag) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate_Pct
    FROM fact_churn
)
SELECT * FROM ChurnSummary

-- High churn contracts only
WITH ContractChurn AS (
    SELECT
        c.ContractType,
        COUNT(*) AS Total_Customers,
        SUM(f.ChurnFlag) AS Churned_Customers,
        CAST(SUM(f.ChurnFlag) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate_Pct
    FROM fact_churn f
    JOIN dim_contract c ON f.CustomerID = c.CustomerID
    GROUP BY c.ContractType
)
SELECT * FROM ContractChurn
WHERE Churn_Rate_Pct > 20

-- Cohort analysis by tenure bucket
WITH TenureBuckets AS (
    SELECT
        CASE
            WHEN Tenure BETWEEN 0 AND 12 THEN 'New'
            WHEN Tenure BETWEEN 13 AND 24 THEN 'Developing'
            WHEN Tenure BETWEEN 25 AND 48 THEN 'Established'
            ELSE 'Loyal'
        END AS TenureGroup,
        ChurnFlag
    FROM fact_churn
)
SELECT
    TenureGroup,
    COUNT(*) AS Total_Customers,
    SUM(ChurnFlag) AS Churned_Customers,
    CAST(SUM(ChurnFlag) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate_Pct
FROM TenureBuckets
GROUP BY TenureGroup
ORDER BY Churn_Rate_Pct DESC
