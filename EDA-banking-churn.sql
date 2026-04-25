-- Creating a schema
CREATE DATABASE bank_churn_db;
USE bank_churn_db;

-- creating a table and importing
CREATE TABLE churn_data (
    row_id INT PRIMARY KEY,
    customer_id INT,
    surname VARCHAR(50),
    credit_score INT,
    geography VARCHAR(50),
    gender VARCHAR(20),
    age INT,
    tenure INT,
    balance DECIMAL(15, 2),
    num_of_products INT,
    has_card TINYINT(1),
    is_active_member TINYINT(1),
    estimated_salary DECIMAL(15, 2),
    exited TINYINT(1)
);


-- summary for our data
SELECT 
    COUNT(*) AS total_customers,
    AVG(credit_score) AS avg_credit,
    AVG(balance) AS avg_balance,
    AVG(age) AS avg_age
FROM churn_data;

-- geographical distribution
SELECT 
    geography, 
    COUNT(*) AS customer_count,
    ROUND(AVG(balance), 2) AS avg_balance
FROM churn_data
GROUP BY geography
ORDER BY customer_count DESC;

-- tenure vs churn
SELECT 
    tenure, 
    COUNT(*) AS total_customers,
    SUM(exited) AS number_exited,
    ROUND((SUM(exited) / COUNT(*)) * 100, 2) AS churn_percentage
FROM churn_data
GROUP BY tenure
ORDER BY tenure ASC;

-- credit score rating that exited
SELECT 
    CASE 
        WHEN credit_score < 500 THEN 'Poor'
        WHEN credit_score BETWEEN 500 AND 650 THEN 'Fair'
        WHEN credit_score BETWEEN 651 AND 750 THEN 'Good'
        ELSE 'Excellent'
    END AS credit_bucket,
    COUNT(*) AS customer_count,
    ROUND(AVG(exited) * 100, 2) AS churn_rate
FROM churn_data
GROUP BY credit_bucket
ORDER BY churn_rate DESC;
-- risk analysis
SELECT 
    is_active_member, 
    exited, 
    COUNT(*) AS count
FROM churn_data
GROUP BY is_active_member, exited;

-- salary vs gender
SELECT 
    gender, 
    ROUND(AVG(estimated_salary), 2) AS avg_salary,
    MAX(estimated_salary) AS max_salary
FROM churn_data
GROUP BY gender;


