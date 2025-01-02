SELECT * FROM ds_salaries; #memanggil dataset

-- 1. Apakah ada data yang Null?
SELECT *
FROM ds_salaries
WHERE work_year IS NULL
OR experience_level IS NULL
OR employment_type IS NULL
OR job_title IS NULL
OR salary IS NULL
OR salary_currency IS NULL
OR salary_in_usd IS NULL
OR employee_residence IS NULL
OR remote_ratio IS NULL
OR company_location IS NULL
OR company_size IS NULL;

-- 2. Melihat terdapat job_tile apa saja
SELECT DISTINCT job_title #Distinct akan membuat nilai duplikat hanya muncul sekali dalam hasil query
FROM ds_salaries 
ORDER BY job_title;

-- 3. Job_title apa saja yang berkaitan dengan data analyst
SELECT DISTINCT job_title
FROM ds_salaries 
WHERE job_title LIKE '%DATA ANALYST%' #Like untuk menjabarkan nama tertentu dan wildcard % untuk mengeluarkan semua yang mengandung tulisan tertentu  
ORDER BY job_title;

-- 4. Rata-rata gaji data analyst perbulan dari usd -> rupiah
SELECT (AVG(salary_in_usd) * 16000) / 12 AS avg_sal_rp_monthly FROM ds_salaries;

-- 4.1 Rata-rata gaji data analyst berdasarkan experience_level
SELECT experience_level,
	(AVG(salary_in_usd) * 16000) / 12 AS avg_sal_rp_monthly 
FROM ds_salaries 
GROUP BY experience_level;

-- 4.2 Rata-rata gaji data analyst berdasarkan experience_level dan jenis employment
SELECT experience_level,
	employment_type,
	(AVG(salary_in_usd) * 16000) / 12 AS avg_sal_rp_monthly 
FROM ds_salaries 
GROUP BY experience_level,
	employment_type
ORDER BY experience_level, employment_type; #Orderby untuk merapihkan

-- 5. Negara dengan gaji yang menarik untuk posisi data analyst, dengan employment_type full time ('FT'), exprience_level entry level ('EN') dan mid level ('MI')
SELECT company_location, 
	AVG(salary_in_usd) AS avg_sal_in_usd
FROM ds_salaries
WHERE job_title LIKE '%DATA ANALYST%'
	AND employment_type = 'FT'
    AND experience_level IN ('MI', 'EN') #In untuk menampilkan 2 nilai atau lebih
GROUP BY company_location
HAVING avg_sal_in_usd > 20000; #Having untuk memfilter

-- 6. Pada tahun berapa terdapat kenaikan gaji dari mid level ke senior level tertinggi
-- (untuk pekerjaan yang berkaitan dengan data analyst, Full Time)
WITH ds_1 AS (
	SELECT work_year,
		AVG(salary_in_usd) AS sal_in_usd_ex
	FROM ds_salaries
    WHERE
		employment_type = 'FT'
        AND experience_level = 'EX'
        AND job_title LIKE '%DATA ANALYST%'
	GROUP BY work_year
), ds_2 AS (
	SELECT work_year,
		AVG(salary_in_usd) AS sal_in_usd_mi
	FROM ds_salaries
    WHERE
		employment_type = 'FT'
        AND experience_level = 'MI'
        AND job_title LIKE '%DATA ANALYST%'
	GROUP BY work_year
), t_year AS (
	SELECT DISTINCT work_year
    FROM ds_salaries
) SELECT t_year.work_year, 
	ds_1.sal_in_usd_ex,
    ds_2.sal_in_usd_mi,
    ds_1.sal_in_usd_ex - ds_2.sal_in_usd_mi AS differences
FROM t_year
LEFT JOIN ds_1 ON ds_1.work_year = t_year.work_year 
LEFT JOIN ds_2 ON ds_2.work_year = t_year.work_year; 