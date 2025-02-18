select *
from ds_salaries;

select
	Work_Year, Employment_Type,
    COUNT(*)
    FROM ds_salaries
    WHERE Work_Year = 2022
    group by Work_Year, Employment_Type;
    
    SELECT
	AVG(Salary_in_USD)
from ds_salaries
	where Employment_Type = "CT"
    and Work_Year = 2022;
    
    select
	Work_Year, Employment_Type,
    COUNT(*)
    FROM ds_salaries
    WHERE Work_Year = 2023
    group by Work_Year, Employment_Type;
    
        SELECT
	AVG(Salary_in_USD)
from ds_salaries
	where Employment_Type = "CT"
    and Work_Year = 2023;
    
SELECT
	AVG(Salary_in_USD)
from ds_salaries
	where Employment_Type = "FT"
    and Work_Year = 2023;
    
SELECT
	AVG(Salary_in_USD)
from ds_salaries
	where Employment_Type = "FT"
    and Work_Year = 2022;
    
WITH OrderedSalaries AS (
	SELECT Salary_in_USD,
		ROW_NUMBER() OVER (ORDER BY Salary_in_USD) AS row_num,
        COUNT(*) OVER  () AS total_rows
        FROM ds_salaries
)
SELECT 
	(SELECT Salary_in_USD FROM OrderedSalaries WHERE row_num = FLOOR(total_rows * 0.25)) AS Precentile_25,
    (SELECT Salary_in_USD FROM OrderedSalaries WHERE row_num = FLOOR(total_rows * 0.50)) AS Median,
    (SELECT Salary_in_USD FROM OrderedSalaries WHERE row_num = FLOOR(total_rows * 0.75)) AS Precentile_75
    FROM OrderedSalaries LIMIT 1;
    
    SELECT Experience_Level,
		COUNT(*) AS num_employees,
		ROUND(AVG(Salary_in_USD), 2) AS avg_salary,
		MIN(Salary_in_USD) AS min_salary,
        MAX(Salary_in_USD) AS max_salary
	FROM ds_salaries
    GROUP BY Experience_Level
    ORDER BY avg_salary DESC;
    
WITH SalaryByExperience AS (
    SELECT experience_level, ROUND(AVG(salary_in_usd), 2) AS avg_salary
    FROM ds_salaries
    GROUP BY experience_level
)
SELECT 
    (SELECT avg_salary FROM SalaryByExperience WHERE experience_level = 'MI') / 
    (SELECT avg_salary FROM SalaryByExperience WHERE experience_level = 'EN') AS junior_vs_mid_ratio,

    (SELECT avg_salary FROM SalaryByExperience WHERE experience_level = 'SE') / 
    (SELECT avg_salary FROM SalaryByExperience WHERE experience_level = 'MI') AS mid_vs_senior_ratio;
    
SELECT Company_Location,
	COUNT(*) AS num_employees,
    ROUND(AVG(Salary_in_USD), 2) AS avg_salary
FROM ds_salaries
GROUP BY Company_Location
ORDER BY avg_salary DESC LIMIT 10;

SELECT
	CASE
		WHEN Remote_Ratio = 100 THEN 'Remote'
        WHEN Remote_Ratio = 0 THEN 'On-Site'
        ELSE 'Hybrid'
	END AS Work_Type,
    COUNT(*) AS num_employees, 
    ROUND(AVG(Salary_in_USD), 2) AS avg_salary
FROM ds_salaries
GROUP BY Work_Type
ORDER BY avg_salary DESC;

WITH job_counts AS (
	SELECT 
		Work_Year,
        Job_Title,
        Employment_Type,
        COUNT(*) AS num_employees
	FROM ds_salaries
    WHERE Company_Location = 'US'
		AND Employee_Residence = 'US'
        AND Work_Year IN (2022, 2023)
	GROUP BY Work_Year, Job_Title, Employment_Type
    ),
    total_counts AS (
		SELECT Work_Year,
	SUM(num_employees) AS total_employees
		FROM job_counts
        GROUP BY Work_Year
        ),
	ranked_jobs AS (
		SELECT
			jc.Work_Year,
            jc.Job_Title,
            jc.Employment_Type,
            jc.num_employees,
            tc.total_employees,
            ROW_NUMBER() OVER (PARTITION BY jc.Work_Year ORDER BY jc.num_employees DESC) AS job_rank
		FROM job_counts jc
        Join total_counts tc ON jc.Work_Year = tc.Work_Year
        )
        SELECT
			Work_year,
            Job_Title,
            Employment_Type,
            num_employees,
            total_employees,
            CONCAT(ROUND(100.0 * num_employees / total_employees, 2), ' %') AS percentage
		FROM ranked_jobs
        WHERE job_rank <= 5
        ORDER BY Work_Year, num_employees DESC;
        
WITH WorkTypeByYear AS (
    SELECT 
        Work_Year,
        CASE 
            WHEN Remote_Ratio = 100 THEN 'Remote'
            WHEN Remote_Ratio = 0 THEN 'On-Site'
            ELSE 'Hybrid'
        END AS Work_Type,
        COUNT(*) AS num_employees,
        ROUND(AVG(salary_in_usd), 2) AS avg_salary
    FROM ds_salaries
    GROUP BY Work_Year, Work_Type
),
SalaryGrowth AS (
    SELECT 
        w1.Work_Year,
        w1.Work_Type,
        w1.num_employees,
        w1.avg_salary,
        w1.avg_salary - w2.avg_salary AS salary_growth, 
        ROUND(((w1.avg_salary - w2.avg_salary) / w2.avg_salary) * 100, 2) AS percent_change
    FROM WorkTypeByYear w1
    LEFT JOIN WorkTypeByYear w2 
        ON w1.Work_Type = w2.Work_Type 
        AND w1.Work_Year = w2.Work_Year + 1
)
SELECT * FROM SalaryGrowth
ORDER BY Work_Year DESC, avg_salary DESC;

	SELECT Work_Year,
		SUM(CASE WHEN Company_Location = 'US' AND Employee_Residence = 'US' THEN 1 ELSE 0 END) AS employees_living_US,
        SUM(CASE WHEN Company_Location = 'US' then 1 else 0 end) as employees_US,
        CONCAT(ROUND(100.0 * SUM(CASE WHEN Company_Location = 'US' AND Employee_Residence = 'US' THEN 1 ELSE 0 END) / SUM(CASE WHEN Company_Location = 'US' then 1 else 0 end), 2), ' %') AS precentage_living_US
        FROM ds_salaries
        WHERE Work_Year IN (2022, 2023)
        Group by Work_Year
        Order by Work_Year;
        
SHOW VARIABLES LIKE 'secure_file_priv';

        SELECT * FROM ds_salaries
        INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/da_salaries.csv'
        FIELDS TERMINATED BY ','
        ENCLOSED BY '"'
        LINES TERMINATED BY '\n';
        
SHOW VARIABLES LIKE 'secure_file_priv';