-- EDA Practice

-- DROP TABLE layoffs;

-- RENAME TABLE
--   tablename TO layoffs;
    
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs;

SELECT *
FROM layoffs
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs;

-- CHANGE DATE FORMAT

SELECT 
    DATE_FORMAT(STR_TO_DATE(`date`, '%m/%d/%y'), '%d-%m-%Y') AS date_formatted
FROM 
    layoffs;

ALTER TABLE layoffs ADD COLUMN layoff_date DATE;

SELECT *
FROM layoffs;

UPDATE layoffs
SET layoff_date = STR_TO_DATE(`date`);

-- ALTER TABLE layoffs
-- DROP COLUMN `date`;

DESCRIBE layoffs;

SELECT industry, SUM(total_laid_off)
FROM layoffs
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs
GROUP BY country
ORDER BY 2 DESC;

SELECT layoff_date, SUM(total_laid_off)
FROM layoffs
GROUP BY layoff_date
ORDER BY 2 DESC;

SELECT layoff_date, SUM(total_laid_off)
FROM layoffs
GROUP BY layoff_date
ORDER BY 2 DESC;

SELECT YEAR(layoff_date), SUM(total_laid_off)
FROM layoffs
GROUP BY YEAR(layoff_date)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs
GROUP BY stage
ORDER BY 2 DESC;

SELECT *
FROM layoffs;

SELECT SUBSTRING(layoff_date,1,7) AS layoff_month, SUM(total_laid_off)
FROM layoffs
WHERE SUBSTRING(layoff_date,1,7) IS NOT NULL 
GROUP BY layoff_month
ORDER BY 1 ASC
;

with Rolling_Total as
(
SELECT SUBSTRING(layoff_date,1,7) AS layoff_month, SUM(total_laid_off) as total_off
FROM layoffs
WHERE SUBSTRING(layoff_date,1,7) IS NOT NULL 
GROUP BY layoff_month
ORDER BY 1 ASC
)
select layoff_month, total_off
, sum(total_off) over(order by layoff_month) as rolling_total
from Rolling_Total
;

select company, year(layoff_date), sum(total_laid_off)
from layoffs
group by company, year(layoff_date)
order by 3 desc;

with Company_year (company, years, total_laid_off) as
(
select company, year(layoff_date), sum(total_laid_off)
from layoffs
group by company, year(layoff_date)
)
select *, 
dense_rank() over (partition by years order by total_laid_off desc) as ranking_laidoff
from Company_year
where years is not null
order by ranking_laidoff asc;

with Company_year (company, years, total_laid_off) as
(
select company, year(layoff_date), sum(total_laid_off)
from layoffs
group by company, year(layoff_date)
), Company_year_rank as 
(select *, 
dense_rank() over (partition by years order by total_laid_off desc) as ranking_laidoff
from Company_year
where years is not null
)
select *
from Company_year_rank
where ranking_laidoff <= 5;




