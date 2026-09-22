------------------------------------------------
-- PROJECT: Telecom Customer Churn Analysis
-- FILE: 01_create_tables.sql
-- DESC: Star schema database and table creation
------------------------------------------------

USE TelecomChurn

-- Drop tables if they exist
DROP TABLE IF EXISTS fact_churn
DROP TABLE IF EXISTS dim_customer
DROP TABLE IF EXISTS dim_services
DROP TABLE IF EXISTS dim_contract

-- Fact Table
CREATE TABLE fact_churn (
    CustomerID      VARCHAR(20),
    ChurnFlag       INT,
    Tenure          INT,
    MonthlyCharges  DECIMAL(10,2),
    TotalCharges    DECIMAL(10,2)
)

-- Dimension: Customer
CREATE TABLE dim_customer (
    CustomerID      VARCHAR(20),
    Gender          VARCHAR(10),
    SeniorCitizen   INT,
    Partner         VARCHAR(5),
    Dependents      VARCHAR(5)
)

-- Dimension: Services
CREATE TABLE dim_services (
    CustomerID      VARCHAR(20),
    PhoneService    VARCHAR(5),
    InternetService VARCHAR(20),
    StreamingTV     VARCHAR(5),
    TechSupport     VARCHAR(5)
)

-- Dimension: Contract
CREATE TABLE dim_contract (
    CustomerID        VARCHAR(20),
    ContractType      VARCHAR(20),
    PaymentMethod     VARCHAR(30),
    PaperlessBilling  VARCHAR(5)
)

