------------------------------------------------
-- FILE: 03_exploration.sql
-- DESC: Initial data exploration queries
------------------------------------------------

USE TelecomChurn

-- Overall churn rate
SELECT
    COUNT(*) AS Total_Customers,
    SUM(ChurnFlag) AS Churned_Customers,
    CAST(SUM(ChurnFlag) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate_Pct
FROM fact_churn

-- Churn by contract type
SELECT
    c.ContractType,
    COUNT(*) AS Total_Customers,
    SUM(f.ChurnFlag) AS Churned_Customers,
    CAST(SUM(f.ChurnFlag) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate_Pct
FROM fact_churn f
JOIN dim_contract c ON f.CustomerID = c.CustomerID
GROUP BY c.ContractType
ORDER BY Churn_Rate_Pct DESC

-- Churn by internet service
SELECT
    s.InternetService,
    COUNT(*) AS Total_Customers,
    SUM(f.ChurnFlag) AS Churned_Customers,
    CAST(SUM(f.ChurnFlag) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate_Pct
FROM fact_churn f
JOIN dim_services s ON f.CustomerID = s.CustomerID
GROUP BY s.InternetService
ORDER BY Churn_Rate_Pct DESC

-- Churn by payment method
SELECT
        c.PaymentMethod,
        COUNT(*) AS Total_Customers,
        SUM(f.ChurnFlag) AS Churned_Customers,
        CAST(SUM(f.ChurnFlag) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate_Pct
    FROM fact_churn f
    JOIN dim_contract c ON f.CustomerID = c.CustomerID
    GROUP BY c.PaymentMethod
    ORDER BY Churn_Rate_Pct DESC
