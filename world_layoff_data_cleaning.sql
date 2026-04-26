-- Data cleaning

-- Lets check our imported data
SELECT *
FROM layoffs
;

-- 1. CREATE TABLE COPY ( TO PRESERVE THE RAW DATA IN CASE OF MISTAKES MAKE DURING CLEANING)
-- lets us create a copy of raw data table
CREATE TABLE layoffs_staging
LIKE layoffs
;

-- lets check our staging table
SELECT *
FROM layoffs_staging
;

-- lets insert data in our layoffs
INSERT layoffs_staging
SELECT *
FROM layoffs
;

-- 2. REMOVE DUPLICATES
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off,percentage_laid_off,'date') AS row_num
FROM layoffs_staging
;

-- Filter rows that are more than 1
WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage , country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

-- to verify if indeed there are duplicates
SELECT *
FROM layoffs_staging
WHERE company = 'Casper'
;

-- lets create another table to delete duplicates because CTE does not allow update statements

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
;

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage , country, funds_raised_millions) AS row_num
FROM layoffs_staging
;

-- NOW LETS DELETe
DELETE 
FROM layoffs_staging2
WHERE row_num > 1
;

-- check 
SELECT *
FROM layoffs_staging2
;

-- 2. STANDARDISE DATA
 -- lets get rid of white spaces
SELECT company,
TRIM(company) 
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET company = TRIM(company)
;


-- USE SAME FORMAT 
SELECT DISTINCT industry
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT DISTINCT country
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE industry LIKE 'United States%'
;

-- date format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE
;

-- 3. NULL VALUES

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- set blank to null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
;

-- check for null fields
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
;

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
   ON t1.company = t2.company
   AND t1.location =t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
;

-- populate the null values
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
   ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL
;

-- 4. REMOVE ROWS AND COLUMNS
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;

SELECT *
FROM layoffs_staging2
;