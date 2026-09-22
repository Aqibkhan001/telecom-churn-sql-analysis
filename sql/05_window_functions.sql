------------------------------------------------
-- FILE: 05_window_functions.sql
-- DESC: Window function analysis
------------------------------------------------

USE TelecomChurn

-- Rank all customers by MonthlyCharges
SELECT TOP 10
    CustomerID,
    MonthlyCharges,
    ChurnFlag,
    ROW_NUMBER() OVER(ORDER BY MonthlyCharges DESC) AS RowNum
FROM fact_churn

-- Rank within each contract type
WITH Ranked_ContractType AS (
    SELECT
        f.CustomerID,
        c.ContractType,
        f.MonthlyCharges,
        ROW_NUMBER() OVER(PARTITION BY c.ContractType ORDER BY f.MonthlyCharges DESC) AS RankWithinContract
    FROM fact_churn f
    JOIN dim_contract c ON f.CustomerID = c.CustomerID
)
SELECT TOP 15
    CustomerID,
    ContractType,
    MonthlyCharges,
    RankWithinContract
FROM Ranked_ContractType
ORDER BY ContractType, RankWithinContract

-- Running total of MonthlyCharges
WITH RunningTotal AS (
    SELECT
        CustomerID,
        MonthlyCharges,
        SUM(MonthlyCharges) OVER(ORDER BY CustomerID) AS RunningTotal
    FROM fact_churn
)
SELECT TOP 20 * FROM RunningTotal
ORDER BY CustomerID

-- Top 3 highest paying churned customers per contract type
WITH RankedChurned AS (
    SELECT
        f.CustomerID,
        c.ContractType,
        f.MonthlyCharges,
        ROW_NUMBER() OVER(PARTITION BY c.ContractType ORDER BY f.MonthlyCharges DESC) AS RankWithinContract
    FROM fact_churn f
    JOIN dim_contract c ON f.CustomerID = c.CustomerID
    WHERE f.ChurnFlag = 1
)
SELECT
    CustomerID,
    ContractType,
    MonthlyCharges,
    RankWithinContract
FROM RankedChurned
WHERE RankWithinContract <= 3
