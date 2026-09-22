------------------------------------------------
-- FILE: 06_revenue_analysis.sql
-- DESC: Revenue at risk analysis
------------------------------------------------

USE TelecomChurn

-- Total revenue at risk
WITH Total_Revenue AS (
    SELECT
        COUNT(*) AS Total_Customers,
        SUM(MonthlyCharges) AS Total_Monthly_Revenue,
        SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges ELSE 0 END) AS Revenue_At_Risk,
        CAST(SUM(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges ELSE 0 END) * 100.0
             / SUM(MonthlyCharges) AS DECIMAL(5,2)) AS Revenue_At_Risk_Pct
    FROM fact_churn
)
SELECT * FROM Total_Revenue

-- Revenue at risk by contract type
WITH Revenue_By_Contract AS (
    SELECT
        c.ContractType,
        SUM(f.MonthlyCharges) AS Total_Revenue,
        SUM(CASE WHEN f.ChurnFlag = 1 THEN f.MonthlyCharges ELSE 0 END) AS Revenue_At_Risk,
        CAST(SUM(CASE WHEN f.ChurnFlag = 1 THEN f.MonthlyCharges ELSE 0 END) * 100.0
             / SUM(f.MonthlyCharges) AS DECIMAL(5,2)) AS Revenue_At_Risk_Pct
    FROM fact_churn f
    JOIN dim_contract c ON f.CustomerID = c.CustomerID
    GROUP BY c.ContractType
)
SELECT * FROM Revenue_By_Contract
ORDER BY Revenue_At_Risk DESC

-- Average charges: churned vs retained
WITH AvgCharges AS (
    SELECT
        AVG(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges END) AS Avg_Churned,
        AVG(CASE WHEN ChurnFlag = 0 THEN MonthlyCharges END) AS Avg_Retained,
        AVG(CASE WHEN ChurnFlag = 0 THEN MonthlyCharges END) -
        AVG(CASE WHEN ChurnFlag = 1 THEN MonthlyCharges END) AS Difference
    FROM fact_churn
)
SELECT * FROM AvgCharges

-- Top 10 highest revenue at risk customers
WITH RevenueRisk AS (
    SELECT
        f.CustomerID,
        c.ContractType,
        cu.Gender,
        f.MonthlyCharges,
        f.Tenure,
        ROW_NUMBER() OVER(ORDER BY f.MonthlyCharges DESC) AS RankNum
    FROM fact_churn f
    JOIN dim_contract c ON f.CustomerID = c.CustomerID
    JOIN dim_customer cu ON f.CustomerID = cu.CustomerID
    WHERE f.ChurnFlag = 1
)
SELECT TOP 10 * FROM RevenueRisk
