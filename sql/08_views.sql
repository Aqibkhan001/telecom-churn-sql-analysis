------------------------------------------------
-- FILE: 08_views.sql
-- DESC: Reusable views for reporting
------------------------------------------------

USE TelecomChurn

-- Master churn dashboard view
CREATE VIEW vw_ChurnDashboard AS
SELECT
    f.CustomerID,
    cu.Gender,
    c.ContractType,
    s.InternetService,
    c.PaymentMethod,
    f.MonthlyCharges,
    f.Tenure,
    f.ChurnFlag
FROM fact_churn f
JOIN dim_customer cu ON f.CustomerID = cu.CustomerID
JOIN dim_contract c  ON f.CustomerID = c.CustomerID
JOIN dim_services s  ON f.CustomerID = s.CustomerID

-- Revenue at risk view
CREATE VIEW vw_RevenueAtRisk AS
SELECT
    c.ContractType,
    SUM(f.MonthlyCharges) AS Total_Revenue,
    SUM(CASE WHEN f.ChurnFlag = 1 THEN f.MonthlyCharges ELSE 0 END) AS Revenue_At_Risk,
    CAST(SUM(CASE WHEN f.ChurnFlag = 1 THEN f.MonthlyCharges ELSE 0 END) * 100.0
         / SUM(f.MonthlyCharges) AS DECIMAL(5,2)) AS Revenue_At_Risk_Pct
FROM fact_churn f
JOIN dim_contract c ON f.CustomerID = c.CustomerID
GROUP BY c.ContractType

-- Query views
SELECT * FROM vw_ChurnDashboard
SELECT * FROM vw_RevenueAtRisk WHERE Revenue_At_Risk_Pct > 10
