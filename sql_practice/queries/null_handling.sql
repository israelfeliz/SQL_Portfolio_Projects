-- Created this table for practice:

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    bonus DECIMAL(10,2),
    manager_id INT,
    hire_date DATE
);

INSERT INTO employees VALUES
(1, 'John', 'IT', 5000, 500, NULL, '2020-01-15'),
(2, 'Mary', 'HR', 4500, NULL, 1, '2021-03-10'),
(3, 'David', 'IT', NULL, 300, 1, '2022-07-05'),
(4, 'Sarah', NULL, 6000, NULL, 1, '2019-11-20'),
(5, 'Mike', 'Sales', 4000, 200, NULL, NULL),
(6, 'Lisa', 'Sales', NULL, NULL, 5, '2023-01-12'),
(7, 'Tom', NULL, 5500, 400, NULL, '2018-06-30');


-- Beginner Exercises

-- 1. Employees whose salary is NULL
SELECT *
FROM employees
WHERE salary IS NULL;

-- 2. Department is not NULL
SELECT *
FROM employees
WHERE department IS NOT NULL;

-- 3. Display salary as 0 when NULL
SELECT emp_id,
       first_name,
       COALESCE(salary, 0) AS salary
FROM employees;

-- 4. Display bonus as 100 if NULL
SELECT emp_id,
       first_name,
       COALESCE(bonus, 100) AS bonus
FROM employees;

-- 5. Department as 'Unassigned'
SELECT emp_id,
       first_name,
       COALESCE(department, 'Unassigned') AS department
FROM employees;

-- 6. Count employees who have a manager
SELECT COUNT(manager_id)
FROM employees;

-- 

SELECT COUNT(*)
FROM employees
WHERE manager_id IS NOT NULL;

-- 7. Count employees without a manager
SELECT COUNT(*)
FROM employees
WHERE manager_id IS NULL;

-- 8. Employees with NULL hire_date
SELECT *
FROM employees
WHERE hire_date IS NULL;

-- 9. Salary OR bonus missing
SELECT *
FROM employees
WHERE salary IS NULL
   OR bonus IS NULL;

-- 10. Salary AND bonus missing
SELECT *
FROM employees
WHERE salary IS NULL
  AND bonus IS NULL;

-- Intermediate Exercises

-- 11. Total compensation (returns NULL if either value NULL)
SELECT emp_id,
       salary + bonus AS total_compensation
FROM employees;

-- 12. Total compensation treating NULL as 0
SELECT emp_id,
       COALESCE(salary,0) + COALESCE(bonus,0) AS total_compensation
FROM employees;

-- 13. Salary greater than average salary
SELECT *
FROM employees
WHERE salary >
      (SELECT AVG(salary)
       FROM employees);

-- 14. Average salary
SELECT AVG(salary)
FROM employees;

-- 15. Sum of bonuses
SELECT SUM(bonus)
FROM employees;

-- 16. Count all rows
SELECT COUNT(*)
FROM employees;

-- 17. Count non-null salaries
SELECT COUNT(salary)
FROM employees;

-- 18. Count non-null departments
SELECT COUNT(department)
FROM employees;

-- 19. Department with most NULL salaries
SELECT department,
       COUNT(*) AS null_salary_count
FROM employees
WHERE salary IS NULL
GROUP BY department
ORDER BY null_salary_count DESC
LIMIT 1;

-- 20. Sort salaries NULL last
PostgreSQL
SELECT *
FROM employees
ORDER BY salary NULLS LAST;
MySQL
SELECT *
FROM employees
ORDER BY salary IS NULL, salary;

-- COALESCE Practice

-- 21. Replace NULL salary with 3000
SELECT COALESCE(salary,3000)
FROM employees;

-- 22. Replace NULL department
SELECT COALESCE(department,'No Department')
FROM employees;

-- 23. Show salary + bonus using COALESCE. 

SELECT 
        emp_id,
        salary,
        bonus,
        COALESCE(salary, 0) + 
        COALESCE(bonus, 0) 
        AS total_compensation
FROM employees;

-- 24. Show manager_id as 0 when NULL. 
SELECT
        emp_id,
        salary,
        bonus,
        COALESCE(salary, 0) + 
        COALESCE(bonus, 0) 
        AS total_compensation,
        COALESCE(manager_id, 0) AS manager_id
FROM employees;

-- 25. Display hire_date as current date when NULL. 
SELECT
        emp_id,
        salary,
        bonus,
        COALESCE(salary, 0) + 
        COALESCE(bonus, 0) 
        AS total_compensation,
        COALESCE(hire_date, CURRENT_DATE) AS hire_date,
        COALESCE(manager_id, 0) AS manager_id
FROM employees;

-- CASE + NULL Exercises

-- 26. Label employees: Salary Available Salary Missing based on salary. 

SELECT
    emp_id,
    CASE 
    WHEN salary IS NOT NULL 
    THEN 'Salary Available'
    ELSE 'Salary Missing'
    END 
    AS has_salary
FROM employees;

-- 27. Categorize departments: Assigned Unassigned based on NULL status. 

SELECT
    emp_id,
    CASE 
    WHEN department IS NOT NULL 
    THEN 'Assigned'
    ELSE 'Unassigned'
    END 
    AS has_department
FROM employees;

-- 28. Display: Has Manager No Manager using CASE. 

SELECT
    emp_id,
    CASE 
    WHEN manager_id IS NOT NULL 
    THEN 'Has Manager'
    ELSE 'No Manager'
    END 
    AS has_manager
FROM employees;

-- 29. Display: Bonus Available No Bonus 

SELECT
    emp_id,
    CASE 
    WHEN bonus IS NOT NULL 
    THEN 'Bonus Available'
    ELSE 'No Bonus'
    END 
    AS has_bonus
FROM employees;

-- 30. Display: Hire Date Missing Hire Date Present 
SELECT
    emp_id,
    CASE 
    WHEN hire_date IS NOT NULL 
    THEN 'Hire Date Available'
    ELSE 'Hire Date Missing'
    END 
    AS hire_date_avail
FROM employees;

-- Aggregate NULL Exercises

-- 31. Find minimum salary. 
SELECT MIN(salary) FROM employees;

-- 32. Find maximum salary. 
SELECT MAX(salary) FROM employees;

-- 33. Count employees with NULL salary. 

SELECT COUNT(*) FROM employees
WHERE salary IS NULL

-- 34. Calculate average Bonus

SELECT AVG(COALESCE(bonus, 0))
FROM employees

-- 35. Count NULL bonuses. Hint: COUNT(*) - COUNT(bonus) 
SELECT COUNT(*) - COUNT(bonus)
FROM employees
-- My way
SELECT COUNT(*) FROM employees
WHERE bonus IS NULL

-- 36. Find departments where all salaries are NULL. 

(SELECT 
    department,
    COUNT(*) AS null_salaries
FROM employees
WHERE salary IS NULL
GROUP BY department)

-- 37. Find departments where at least one salary is NULL. 
SELECT 
    department,
    COUNT(*) AS null_salaries
FROM employees
WHERE salary IS NULL
GROUP BY department

-- 38. Calculate average salary per department.

SELECT 
    department,
    AVG(COALESCE(salary, 0)) AS avg_salary
FROM employees
GROUP BY department;

-- 39. Count employees per department including NULL department. 
SELECT 
    COALESCE(deparment, 'No Department') as department,
    COUNT(*) AS total_employees
FROM employees
GROUP BY department

-- 40. Calculate total compensation by department treating NULL as 0. 

SELECT 
    COALESCE(deparment, 'No Department') as department,
    SUM(COALESCE(salary, 0) +
    COALESCE(bonus, 0)) AS total_compensation
FROM employees
GROUP BY department

-- Joins and NULL Exercises

-- Create another table:

CREATE TABLE departments (
    department VARCHAR(50) PRIMARY KEY,
    location VARCHAR(50)
);

INSERT INTO departments VALUES
('IT', 'New York'),
('HR', 'Chicago'),
('Sales', 'Dallas');

-- 41. Find employees without matching departments.

SELECT e.*
FROM employees e
LEFT JOIN departments d
       ON e.department = d.department
WHERE d.department IS NULL;

-- 42. Show department location, displaying 'Unknown' when no match exists.

SELECT e.*,
	COALESCE(d.location, 'Unknown') location
FROM employees e
LEFT JOIN departments d
ON e.department = d.department

-- 43. Find employees assigned to departments that don't exist.

SELECT e.*
FROM employees e
LEFT JOIN departments d
       ON e.department = d.department
WHERE e.department IS NOT NULL
  AND d.department IS NULL;

-- 44. Count employees per location including unmatched departments.

SELECT
    COALESCE(d.location, 'No Department') AS location,
    COUNT(e.emp_id) AS number_of_employees
FROM employees e
LEFT JOIN departments d
    ON e.department = d.department
GROUP BY d.location;

-- 45. List all employees with department location.

SELECT e.*,
	d.location
FROM employees e
JOIN departments d
ON e.department = d.department

-- Advanced NULL Exercises

-- 46. Find employees whose salary is NULL but bonus is not NULL.

SELECT *
FROM employees
WHERE salary IS NULL AND bonus IS NOT NULL

-- 47. Find employees whose salary is not NULL but bonus is NULL.

SELECT *
FROM employees
WHERE salary IS NOT NULL AND bonus IS NULL

-- 48. Calculate salary percentage of total payroll while handling NULL salaries.

SELECT
    emp_id,
    first_name,
    salary,
    ROUND(
        COALESCE(salary, 0) * 100.0 /
        SUM(COALESCE(salary, 0)) OVER (), 2) 
		AS payroll_percentage
FROM employees;

-- 49. Replace salary using the first available value:
-- salary
-- bonus
-- 1000

SELECT 
	COALESCE(salary, bonus, 1000)	
FROM employees

-- 50. Find rows where exactly one of salary or bonus is NULL.

SELECT *
FROM employees
WHERE 
	(salary IS NULL AND bonus IS NOT NULL) OR 
	(SALARY IS NOT NULL AND bonus IS NULL)

-- Or shirtcut in postgresql

SELECT *
FROM employees
WHERE (salary IS NULL) <> (bonus IS NULL);

-- 51. Use NULLIF to avoid division by zero.
-- salary / NULLIF(bonus,0)

SELECT 
	salary / NULLIF(bonus, 0)
FROM employees

-- 52. Compare COALESCE vs NULLIF.

SELECT
    COALESCE(NULL,10),
    NULLIF(10,10);

-- 53. Use NULLIF to convert empty strings to NULL.

SELECT NULLIF('', '');

-- NULLIF(column_name, '')

-- 54. Use IS DISTINCT FROM to compare values including NULL.

SELECT *
FROM employees
WHERE salary IS DISTINCT FROM bonus;
-- (PostgreSQL only)

-- 55. Use IS NOT DISTINCT FROM.

SELECT *
FROM employees
WHERE salary IS NOT DISTINCT FROM bonus;
-- (PostgreSQL only)

-- MySQL-Specific Practice

-- 56. Rewrite COALESCE examples using:
-- IFNULL()

SELECT IFNULL(salary,0)
FROM employees;

-- 57. Rewrite CASE examples using:
-- IF()

SELECT first_name,
       IF(salary IS NULL,
          'Missing',
          'Present')
FROM employees;

-- 58. Compare: IFNULL() vs COALESCE()

IFNULL(NULL,100)
COALESCE(NULL,100);

-- Both return: 100

-- 59. Use NULLIF() with salary and bonus.

SELECT NULLIF(salary,bonus)
FROM employees;
-- Returns NULL when salary = bonus.

-- 60. Find rows where salary equals bonus, handling NULLs correctly.

-- PostgreSQL
SELECT *
FROM employees
WHERE salary IS NOT DISTINCT FROM bonus;
-- MySQL
SELECT *
FROM employees
WHERE salary <=> bonus;