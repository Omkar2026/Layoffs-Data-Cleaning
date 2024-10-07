SELECT *
FROM layoffs_staging

-- Findind Duplicates

-- This is how duplicates in this table
SELECT *
FROM layoffs_staging
WHERE company = '5B Solar' AND location = 'Sydney'

WITH cte_first AS(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, date, stage, country,
funds_raised_millions ORDER BY date) AS 'Rownumber'
FROM layoffs_staging)

SELECT *
FROM cte_first
WHERE Rownumber > 1

-- This will create a new table with the same schema as layoffs_staging but without any data.
-- Step 1: Copy the table structure without data
SELECT *
INTO layoffs_staging_pract1
FROM layoffs_staging
WHERE 1 = 0;

-- Step 2: Add the new column
ALTER TABLE layoffs_staging_pract1
ADD Rownumber int;

INSERT INTO layoffs_staging_pract1
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, date, stage, country,
funds_raised_millions ORDER BY date) AS Rownumber
FROM layoffs_staging;


-- DELETE

DELETE 
FROM layoffs_staging_pract1
WHERE Rownumber > 1

-- check that all duplicates are deleted

SELECT *
FROM layoffs_staging_pract1
WHERE Rownumber > 1

-- Standardizing Data

-- using TRIM FOR removing white space at the biggininig

select company, TRIM(company)
FROM layoffs_staging_pract1

UPDATE layoffs_staging_pract1
SET company = TRIM(company)

-- check
SELECT *
FROM layoffs_staging_pract1

-- Find different types of industries and there are redudance in column
-- some columns have same industry name but have different formats


select distinct(industry)
from layoffs_staging_pract1
ORDER BY 1

-- Here are three columns named crypto currency in diffrent manners we want them as 1

SELECT *
FROM layoffs_staging_pract1
where industry like 'Crypto%'


-- we want all of them as Crypto so we update that

update layoffs_staging_pract1
set industry = 'Crypto'
WHERE industry like 'Crypto%'

-- using distinct in country column

SELECT DISTINCT(country)
FROM layoffs_staging_pract1
ORDER BY 1

-- so  there is problem in united states like united states. we have to remove that .

SELECT *
FROM layoffs_staging_pract1
WHERE country like 'United States%'
ORDER BY 1

-- use trim railing to remove .

SELECT DISTINCT(country), TRIM( TRAILING '.' FROM country)
FROM layoffs_staging_pract1
ORDER BY 1

-- updating the change
UPDATE layoffs_staging_pract1
SET country = TRIM( TRAILING '.' FROM country)
WHERE country LIKE 'United States%'

-- change date column data type text to date

SELECT date,CONVERT(Date, date, 101)
FROM layoffs_staging_pract1

-- update the date now

UPDATE layoffs_staging_pract1
SET date = CONVERT(Date, date, 101)

-- now change data type in the column of date
-- dont use on raw table cause it will change entire data type of that table

ALTER TABLE layoffs_staging_pract1
ALTER COLUMN date Date

-- remove blank and NULL values
SELECT *
FROM layoffs_staging_pract1

SELECT *
FROM layoffs_staging_pract1
WHERE industry IS NULL or industry = ' '

-- checking string nulls

SELECT *
FROM layoffs_staging_pract1
WHERE industry = 'NULL' or industry = ' '

-- we can populate null values

SELECT t1.industry, t2.industry
FROM layoffs_staging_pract1 t1
JOIN layoffs_staging_pract1 t2
ON t1.company = t2.company
WHERE (t1.industry is NULL OR t1.industry = ' ') AND t2.industry is not NULL

-- first fill blanks values with null to change

UPDATE layoffs_staging_pract1
SET industry = NULL
WHERE industry = ' '

-- update the table populating the table

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging_pract1 t1
JOIN layoffs_staging_pract1 t2
ON t1.company = t2.company
WHERE (t1.industry is NULL OR t1.industry = ' ') AND t2.industry is not NULL

-- update string null value

SELECT *
FROM layoffs_staging_pract1
WHERE company LIKE 'Bally%'

-- search online to find companyies industry name 
-- then update null string with industry name

UPDATE layoffs_staging_pract1
SET industry = 'Casinos'
WHERE company LIKE 'Bally%'

-- finding NULL values

SELECT *
FROM layoffs_staging_pract1
WHERE percentage_laid_off = 'NULL'

SELECT *
FROM layoffs_staging_pract1

--change data type of coulmn percentage_laid_off navarchar to float
--3 steps for converting to varchar to float
-- Step 1: Identify non-convertible data

SELECT *
FROM layoffs_staging_pract1
WHERE TRY_CAST( percentage_laid_off AS float) IS NULL AND percentage_laid_off is not NULL

-- Step 2: Clean data by setting non-convertible values to NULL
 
 UPDATE layoffs_staging_pract1
 SET percentage_laid_off = NULL
 WHERE TRY_CAST(percentage_laid_off AS float) IS NULL

 -- Optional Step: Validate the cleanup

 SELECT *
 FROM layoffs_staging_pract1
 WHERE TRY_CAST( percentage_laid_off AS float) IS NULL AND percentage_laid_off is not NULL

-- Step 3: Alter the column type

ALTER TABLE layoffs_staging_pract1
ALTER COLUMN percentage_laid_off float null

-- finding null values in two columns

SELECT *
FROM layoffs_staging_pract1
WHERE total_laid_off is NULL AND percentage_laid_off IS NULL

-- DELETE the null values if you are 100% sure confident about it

DELETE 
FROM layoffs_staging_pract1
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL

SELECT *
FROM layoffs_staging_pract1

-- we have to delete the row_num column cause its not usefull

ALTER TABLE layoffs_staging_pract1
DROP COLUMN Rownumber

-- final cleaned table

SELECT *
FROM layoffs_staging_pract1

-- what i did in this project
--1. Remove Duplicates
--2. Standardize the Data
--3. Null values or blank values
--4. Remove any column or row