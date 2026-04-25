-- CLEANING OUR DATASET
-- 1. CLEANING CATEGORICAL TYPOS & STANDARDIZATION
UPDATE churn_modelling 
SET geography = CASE 
    WHEN geography = 'Fance' THEN 'France'
    WHEN geography = 'Gemany' THEN 'Germany'
    ELSE geography 
END,
gender = TRIM(CONCAT(UPPER(SUBSTRING(gender, 1, 1)), LOWER(SUBSTRING(gender, 2))));

-- 2. HANDLING MISSING VALUES 
UPDATE churn_modelling 
SET 
    balance = COALESCE(balance, 0),
    credit_score = COALESCE(credit_score, (SELECT AVG(credit_score) FROM (SELECT * FROM churn_modelling) AS t)),
    suname = TRIM(suname);

-- 3. REMOVING DUPLICATES
DELETE t1 FROM churn_modelling t1
INNER JOIN churn_modelling t2 
WHERE t1.row_number < t2.row_number 
AND t1.customer_id = t2.customer_id;

-- 4. DATA TRANSFORMATION 
-- This column can be used to compare churn rates across credit tiers
ALTER TABLE churn_modelling ADD COLUMN credit_group VARCHAR(20);

UPDATE churn_modelling 
SET credit_group = CASE 
    WHEN credit_score < 500 THEN 'Poor'
    WHEN credit_score BETWEEN 500 AND 650 THEN 'Fair'
    WHEN credit_score BETWEEN 651 AND 750 THEN 'Good'
    ELSE 'Excellent'
END;

-- 5. FINAL AUDIT CHECK
SELECT 
    geography, 
    COUNT(*) AS customer_count, 
    ROUND(AVG(exited) * 100, 2) AS churn_rate_percentage,
    AVG(credit_score) AS avg_credit_score
FROM churn_modelling
GROUP BY geography
ORDER BY churn_rate_percentage DESC;