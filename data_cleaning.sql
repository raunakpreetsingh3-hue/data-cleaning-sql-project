-- DATA CLEANING
/* 1) remove duplicates
   2) standardize the data
   3) null or blank values
   4) remove any column
*/
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM 
layoffs_staging;

INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

-- to detect the duplicates

SELECT *,
row_number() over(
partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country, funds_raised_millions) as rn
FROM layoffs_staging;


WITH duplicate as(
SELECT *,
row_number() over(
partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country, funds_raised_millions) as rn
FROM layoffs_staging
)
SELECT *
FROM duplicate
where rn>1;


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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT *,
row_number() over(
partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country, funds_raised_millions) as row_num
FROM layoffs_staging;

SELECT * FROM 
layoffs_staging2
WHERE row_num>1;

DELETE FROM
layoffs_staging2
WHERE row_num>1; 
 
-- standardizing data

update layoffs_staging2
set company= trim(company);
-- to see if there is any country with lower case of its first letter
SELECT country
FROM layoffs_staging2
where BINARY left(country,1)=lower(left(country,1)) ;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';


UPDATE layoffs_staging2
SET industry='crypto'
WHERE industry LIKE 'crypto%';


SELECT country, trim(country)
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country='United States'
where country LIKE 'United States%';
-- or 
UPDATE layoffs_staging2
SET country= trim(TRAILING '.' FROM country);

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


SELECT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`= str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY `date` date;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

UPDATE layoffs_staging2
SET industry = null
WHERE industry='';

SELECT * 
FROM layoffs_staging2 s1
JOIN layoffs_staging2 s2
     ON s1.company=s2.company 
     AND s1.location=s2.location
WHERE s1.industry IS NULL 
AND s2.industry IS NOT NULL;

UPDATE layoffs_staging2 s1
JOIN layoffs_staging2 s2
     ON s1.company=s2.company 
     AND s1.location=s2.location
SET s1.industry=s2.industry
WHERE s1.industry IS NULL 
AND s2.industry IS NOT NULL;

WITH ct AS (
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY 
company,location,country,`date`,industry) as rn
FROM layoffs_staging2) 
SELECT * 
FROM ct 
WHERE rn>1;

select *
from layoffs_staging2
where percentage_laid_off is null
and total_laid_off is null ;

DELETE 
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL
AND total_laid_off IS NULL ;

ALTER TABLE layoffs_staging2
DROP row_num;

select count(*)
from layoffs_staging2;








































































