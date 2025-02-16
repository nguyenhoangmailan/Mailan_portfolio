CREATE TABLE financial_loan (
    id BIGINT PRIMARY KEY,
    address_state VARCHAR(10),
    application_type VARCHAR(50),
    emp_length VARCHAR(20),
    emp_title VARCHAR(255),
    grade CHAR(1),
    home_ownership VARCHAR(20),
    issue_date DATE,
    last_credit_pull_date DATE,
    last_payment_date DATE,
    loan_status VARCHAR(50),
    next_payment_date DATE,
    member_id BIGINT,
    purpose VARCHAR(100),
    sub_grade VARCHAR(10),
    term VARCHAR(20),
    verification_status VARCHAR(50),
    annual_income DECIMAL(15,2),
    dti DECIMAL(10,4),
    installment DECIMAL(15,2),
    int_rate DECIMAL(6,4),
    loan_amount DECIMAL(15,2),
    total_acc INT,
    total_payment DECIMAL(15,2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\financial_loan.csv' 
INTO TABLE financial_loan 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Check for missing values 

SELECT * FROM loan_data
WHERE COALESCE(id, address_state, application_type, emp_length, emp_title, grade, 
               home_ownership, issue_date, last_credit_pull_date, last_payment_date, 
               loan_status, next_payment_date, member_id, purpose, sub_grade, term, 
               verification_status, annual_income, dti, installment, int_rate, 
               loan_amount, total_acc, total_payment) IS NULL;

-- Check for duplicates 

SELECT id, address_state, application_type, emp_length, emp_title, grade, home_ownership, issue_date, last_credit_pull_date, last_payment_date, loan_status, next_payment_date, member_id, purpose, sub_grade, term, verification_status, annual_income, dti, installment, int_rate, loan_amount, total_acc, total_payment, 
COUNT(*) AS duplicate_count
FROM financial_loan
GROUP BY id, address_state, application_type, emp_length, emp_title, grade, home_ownership, issue_date, last_credit_pull_date, last_payment_date, loan_status, next_payment_date, member_id, purpose, sub_grade, term, verification_status, annual_income, dti, installment, int_rate, loan_amount, total_acc, total_payment
HAVING COUNT(*) > 1;

-- Check for Outliers

SELECT 
    MIN(loan_amount), MAX(loan_amount), AVG(loan_amount), STDDEV(loan_amount),
    MIN(interest_rate), MAX(interest_rate), AVG(interest_rate), STDDEV(interest_rate),
    MIN(income), MAX(income), AVG(income), STDDEV(income),
    MIN(credit_score), MAX(credit_score), AVG(credit_score), STDDEV(credit_score)
FROM financial_loan;

-- Identify extreme income or loan amounts:
SELECT * FROM financial_loan
WHERE loan_amount > (SELECT AVG(loan_amount) + 3 * STDDEV(loan_amount) FROM financial_loan);


-- Exploratory Data Analysis
SELECT *
FROM financial_loan;

DESCRIBE financial_loan;

SELECT COUNT(*) AS total_records FROM financial_loan;

-- Summary Statistics

WITH loan_stats_cte AS (
    SELECT
        'loan_amount' AS variable, 
        CONCAT(FORMAT(SUM(loan_amount) / 1e6, 2), ' Million($)') AS total, 
        ROUND(AVG(loan_amount)) AS avg, 
        MIN(loan_amount) AS min, 
        MAX(loan_amount) AS max, 
        ROUND(STDDEV(loan_amount)) AS std_dev
    FROM financial_loan
    UNION ALL -- create table with many statistics 
    SELECT 'total_payment', 
        CONCAT(FORMAT(SUM(total_payment) / 1e6, 2), ' Million($)'), 
        ROUND(AVG(total_payment)), MIN(total_payment), MAX(total_payment), ROUND(STDDEV(total_payment)) 
    FROM financial_loan
    UNION ALL
    SELECT 'installment', 
        FORMAT(SUM(installment), 2), ROUND(AVG(installment), 2), MIN(installment), MAX(installment), ROUND(STDDEV(installment), 2) 
    FROM financial_loan
    UNION ALL
    SELECT 'int_rate', 
        FORMAT(SUM(int_rate), 4), ROUND(AVG(int_rate), 4), MIN(int_rate), MAX(int_rate), ROUND(STDDEV(int_rate), 4) 
    FROM financial_loan
    UNION ALL
    SELECT 'annual_income', 
        CONCAT(FORMAT(SUM(annual_income) / 1e6, 2), ' Million($)'), ROUND(AVG(annual_income)), MIN(annual_income), MAX(annual_income), ROUND(STDDEV(annual_income)) 
    FROM financial_loan
    UNION ALL
    SELECT 'dti', 
        FORMAT(SUM(dti), 4), ROUND(AVG(dti), 4), MIN(dti), MAX(dti), ROUND(STDDEV(dti), 4) 
    FROM financial_loan
    UNION ALL
    SELECT 'total_acc', 
        FORMAT(SUM(total_acc), 2), ROUND(AVG(total_acc), 2), MIN(total_acc), MAX(total_acc), ROUND(STDDEV(total_acc), 2) 
    FROM financial_loan
),
quartile_cte AS (
    SELECT 'loan_amount' AS variable, 
        MAX(CASE WHEN quartile = 1 THEN loan_amount END) AS Q1, 
        MAX(CASE WHEN quartile = 2 THEN loan_amount END) AS Median, 
        MAX(CASE WHEN quartile = 3 THEN loan_amount END) AS Q3
    FROM (SELECT loan_amount, NTILE(4) OVER (ORDER BY loan_amount) AS quartile FROM financial_loan) AS quartile_groups
    UNION ALL
    SELECT 'total_payment', 
        MAX(CASE WHEN quartile = 1 THEN total_payment END), MAX(CASE WHEN quartile = 2 THEN total_payment END), MAX(CASE WHEN quartile = 3 THEN total_payment END) 
    FROM (SELECT total_payment, NTILE(4) OVER (ORDER BY total_payment) AS quartile FROM financial_loan) AS quartile_groups
    UNION ALL
    SELECT 'installment', 
        MAX(CASE WHEN quartile = 1 THEN installment END), MAX(CASE WHEN quartile = 2 THEN installment END), MAX(CASE WHEN quartile = 3 THEN installment END) 
    FROM (SELECT installment, NTILE(4) OVER (ORDER BY installment) AS quartile FROM financial_loan) AS quartile_groups
    UNION ALL
    SELECT 'int_rate', 
        MAX(CASE WHEN quartile = 1 THEN int_rate END), MAX(CASE WHEN quartile = 2 THEN int_rate END), MAX(CASE WHEN quartile = 3 THEN int_rate END) 
    FROM (SELECT int_rate, NTILE(4) OVER (ORDER BY int_rate) AS quartile FROM financial_loan) AS quartile_groups
    UNION ALL
    SELECT 'annual_income', 
        MAX(CASE WHEN quartile = 1 THEN annual_income END), MAX(CASE WHEN quartile = 2 THEN annual_income END), MAX(CASE WHEN quartile = 3 THEN annual_income END) 
    FROM (SELECT annual_income, NTILE(4) OVER (ORDER BY annual_income) AS quartile FROM financial_loan) AS quartile_groups
    UNION ALL
    SELECT 'dti', 
        MAX(CASE WHEN quartile = 1 THEN dti END), MAX(CASE WHEN quartile = 2 THEN dti END), MAX(CASE WHEN quartile = 3 THEN dti END) 
    FROM (SELECT dti, NTILE(4) OVER (ORDER BY dti) AS quartile FROM financial_loan) AS quartile_groups
    UNION ALL
    SELECT 'total_acc', 
        MAX(CASE WHEN quartile = 1 THEN total_acc END), MAX(CASE WHEN quartile = 2 THEN total_acc END), MAX(CASE WHEN quartile = 3 THEN total_acc END) 
    FROM (SELECT total_acc, NTILE(4) OVER (ORDER BY total_acc) AS quartile FROM financial_loan) AS quartile_groups
)
SELECT ls.variable, total, avg, min, max, std_dev, Q1, Median, Q3
FROM loan_stats_cte ls
JOIN quartile_cte qc ON ls.variable = qc.variable;

	-- Some Insights: 
		-- Loan amount: average ~11k with the range 500-35k => some high-value outliers
        -- Avg Total payment > Avg Loan amount => borrowers have to pay interest cost
        -- Installment: most borrowers (~50%) pay between $168-$434 => the small group pay higher than $434 may be suggest: higher loan amount, shorter loan terms, higher IR.
        -- Interest rate: Avg ~12% => low risk (5.4%), high risk (24.6%) => a mix of prime and subprime borrowers
        -- Annual income and DTI ratio: income avg ~ 70k with the maximum of 600k; 
									--  dti ~13% (means 13% of the income goes to debt payments) => reasonable threshold (generally <36% is healthy)
                                    -- => Concern: Why DTI is relatively low but Interest rate is high? => DTI does not indicate IR due to many other factors (credit risk, loan type, lender policies, credit score,...)
		-- Total acc (Credit line): ~22 accounts => moderate credit history; range 2-90 => large spread => concern about age of customers, creidt usage and lenders can adjust the IR and loan approvals based on credit line

-- Classification categories
	
    -- Application Type
SELECT application_type, COUNT(*) AS count,
	CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM financial_loan)*100,2),'%') AS percentage_total
FROM financial_loan
GROUP BY application_type 
ORDER BY count ASC;
	-- => Individual only

	-- Loan Status Breakdown
SELECT loan_status, COUNT(*) AS count,
	CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM financial_loan)*100,2),'%') AS percentage_total
FROM financial_loan
GROUP BY loan_status 
ORDER BY count ASC;
	-- => Default exists: 13.82%
    
	-- Employment Length Distribution
SELECT emp_length, COUNT(*) AS count,
	CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM financial_loan)*100,2),'%') AS percentage_total
FROM financial_loan
GROUP BY emp_length 
ORDER BY count DESC;
	-- => 10+ year and < 1 year empoyee length tend to borrow (most common: 22.99% and 11.86%)

	-- Loan Grade & Subgrade Analysis
SELECT grade, COUNT(*) AS count,
	CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM financial_loan)*100,2),'%') AS percentage_grade
FROM financial_loan
GROUP BY grade 
ORDER BY grade ASC;
	-- => A, B _ good credit are most common

SELECT sub_grade, COUNT(*) AS count,
	CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM financial_loan)*100,2),'%') AS percentage_sub_grade
FROM financial_loan
GROUP BY sub_grade 
ORDER BY count DESC;

	-- Home Ownership Status
SELECT home_ownership, COUNT(*) AS count,
	CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM financial_loan)*100,2),'%') AS percentage_total
FROM financial_loan
GROUP BY home_ownership 
ORDER BY count ASC;
	-- => Mortgage and Rent homeowner status are most common (outweight the own status)

	-- Loan Purpose
SELECT purpose, COUNT(*) AS count,
	CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM financial_loan)*100,2),'%') AS percentage_total
FROM financial_loan
GROUP BY purpose 
ORDER BY count DESC;    
    
    -- Loan Term
SELECT term, COUNT(*) AS count,
	CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM financial_loan)*100,2),'%') AS percentage_total
FROM financial_loan
GROUP BY term 
ORDER BY count ASC;  

	-- Loan verification_status
SELECT verification_status, COUNT(*) AS count,
	CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM financial_loan)*100,2),'%') AS percentage_total
FROM financial_loan
GROUP BY verification_status 
ORDER BY count ASC; 
	-- => Income unverified is most common maybe due to type of loan not requiring 

-- Loan Portfolio Overview (loan_status by grade, term, emp_length, verification_status)
	
    -- Calculate Repayment rate and Default rate, Profit Earned
SELECT 
    loan_status AS "Loan Status",
    COUNT(*) AS "Count",
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM financial_loan) AS "Total %"
FROM financial_loan
GROUP BY loan_status
ORDER BY COUNT(*) DESC;

select 
	SUM(total_payment) - SUM(loan_amount) AS Total_Profit_Earned
from financial_loan;

	-- Categories
SELECT 
    term,
    (COUNT(CASE WHEN loan_status = 'Fully Paid' THEN 1 END) * 100.0) / COUNT(*) AS Repayment_rate,
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) * 100.0) / COUNT(*) AS Default_rate
FROM financial_loan
GROUP BY term;
	
SELECT 
    home_ownership,
    (COUNT(CASE WHEN loan_status = 'Fully Paid' THEN 1 END) * 100.0) / COUNT(*) AS Repayment_rate,
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) * 100.0) / COUNT(*) AS Default_rate,
    (COUNT(CASE WHEN loan_status = 'Current' THEN 1 END) * 100.0) / COUNT(*) AS Current_rate
FROM financial_loan
GROUP BY home_ownership;

SELECT 
    grade,
    SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) AS Repayment_rate,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS Default_rate,
    SUM(CASE WHEN loan_status = 'Current' THEN 1 ELSE 0 END) AS Current_rate,
    COUNT(*) AS Total_loans,
    CONCAT(COUNT(CASE WHEN loan_status = 'Fully Paid' THEN 1 END) * 100.0) / COUNT(*) AS Repayment_rate_percentage,
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) * 100.0) / COUNT(*) AS Default_rate_percentage
FROM financial_loan
GROUP BY grade
ORDER BY Repayment_rate_percentage DESC;

SELECT 
    emp_length,
    SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) AS Repayment_rate,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS Default_rate,
    SUM(CASE WHEN loan_status = 'Current' THEN 1 ELSE 0 END) AS Current_rate,
    COUNT(*) AS Total_loans,
    CONCAT(COUNT(CASE WHEN loan_status = 'Fully Paid' THEN 1 END) * 100.0) / COUNT(*) AS Repayment_rate_percentage,
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) * 100.0) / COUNT(*) AS Default_rate_percentage
FROM financial_loan
GROUP BY emp_length
ORDER BY Repayment_rate_percentage DESC;

-- Financial Risk Factors

SELECT 
    DATE_FORMAT(issue_date, '%Y-%m') AS month,
    (COUNT(CASE WHEN loan_status = 'Fully Paid' THEN 1 END) * 100.0) / COUNT(*) AS repayment_rate_percentage,
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) * 100.0) / COUNT(*) AS default_rate_percentage
FROM financial_loan
GROUP BY month
ORDER BY month;

SELECT 
    total_acc, 
    loan_amount, 
    dti,
    (CAST(total_acc AS FLOAT) / NULLIF(loan_amount, 0)) AS credit_uti_ratio,
    AVG(dti) OVER () AS avg_dti, 
    (CAST(total_acc AS FLOAT) / NULLIF(loan_amount, 0)) * dti AS loan_default_risk_indicator,
    AVG(loan_amount) OVER () AS avg_loan_amount
FROM financial_loan;

SELECT *
FROM financial_loan;

	-- verification status 
    -- purpose, loan_amount, loan_status, grade    
    -- loan payment to income ratio        -- interest cost
        -- outstanding loan balance    
    -- loan default risk indicator
        -- default rate
        -- repayment loan_amount
        -- consider about term/date?
    
-- Borrower Profile Analysis
	
    select 
		annual_income, emp_length, grade
    from financial_loan
    order by annual_income desc;
    
    -- annual_income    
    -- emp_length    
    -- home ownership
        -- loan purpose
        -- interest rate
        -- dti    
    -- grade, subgrade    
    -- credit utilization ratio

-- Profitability
	-- Loan profitability    
    -- Profit margin?    
    -- most profit loan product?    
    -- most profit loan interest rates/ interest cost?
    
-- Geographical Analysis
	-- across US
    -- State category
    -- Profit earned by state    
    -- distribution...

select *
from financial_loan;



 