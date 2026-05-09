create database Employee_management;
use Employee_management;

CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    salaryrange VARCHAR(50),
    
   CONSTRAINT chk_salaryrange CHECK (salaryrange IS NOT NULL)
);
select *from JobDepartment;

CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT ,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    
    CONSTRAINT fk_employee_job 
    FOREIGN KEY (Job_ID)
    REFERENCES JobDepartment(Job_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

select *from Employee;


CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT NOT NULL,
    amount DECIMAL(10,2) CHECK (amount > 0),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2) DEFAULT 0,
    
    CONSTRAINT fk_salary_job 
    FOREIGN KEY (Job_ID)
    REFERENCES JobDepartment(Job_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
select *from SalaryBonus;

CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT NOT NULL,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    
    CONSTRAINT fk_qualification_emp 
    FOREIGN KEY (Emp_ID)
    REFERENCES Employee(emp_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
select *from Qualification;

CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE ,
    reason TEXT,
    
    CONSTRAINT fk_leave_emp 
    FOREIGN KEY (emp_ID)
    REFERENCES Employee(emp_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
select *from Leaves;

CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT NULL,
    job_ID INT NULL,
    salary_ID INT NULL,
    leave_ID INT,
    date DATE NULL,
    report TEXT,
    total_amount DECIMAL(10,2) CHECK (total_amount >= 0),
    
    CONSTRAINT fk_payroll_emp 
    FOREIGN KEY (emp_ID)
    REFERENCES Employee(emp_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_payroll_job 
    FOREIGN KEY (job_ID)
    REFERENCES JobDepartment(Job_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_payroll_salary 
    FOREIGN KEY (salary_ID)
    REFERENCES SalaryBonus(salary_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fk_payroll_leave 
    FOREIGN KEY (leave_ID)
    REFERENCES Leaves(leave_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);
select *from Payroll;

# 1) EMPLOYEE INSIGHTS
-- 1. Total unique employees
SELECT COUNT(DISTINCT emp_ID) AS total_employees
FROM Employee;

-- 2.Departments with highest number of employees
SELECT jd.jobdept, COUNT(e.emp_ID) AS emp_count
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY emp_count DESC;

-- 3. Average salary per department
SELECT jd.jobdept, AVG(sb.amount) AS avg_salary
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

-- 4.Top 5 highest-paid employees
SELECT e.emp_ID, e.firstname, sb.amount
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;


-- 5. Total salary expenditure
SELECT SUM(amount) AS total_salary
FROM SalaryBonus;

-- 2) JOB ROLE & DEPARTMENT ANALYSIS

-- 1.Number of job roles per department
SELECT jobdept, COUNT(DISTINCT name) AS total_roles
FROM JobDepartment
GROUP BY jobdept;


-- 2. Average salary range per department
SELECT jobdept, AVG(amount) AS avg_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jobdept;

-- 3. Job roles with highest salary
SELECT jd.name, MAX(sb.amount) AS max_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.name
ORDER BY max_salary DESC;

-- 4. Departments with highest total salary allocation
SELECT jd.jobdept, SUM(sb.amount) AS total_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_salary DESC;

-- 3) QUALIFICATION & SKILLS ANALYSIS

-- 1. Employees with at least one qualification
SELECT COUNT(DISTINCT Emp_ID) AS qualified_employees
FROM Qualification;

-- 2. Positions requiring most qualifications
SELECT Position, COUNT(*) AS total_requirements
FROM Qualification
GROUP BY Position
ORDER BY total_requirements DESC;

-- 3. Employees with highest number of qualifications
SELECT e.emp_ID, e.firstname, COUNT(q.QualID) AS total_qualifications
FROM Employee e
JOIN Qualification q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID, e.firstname
ORDER BY total_qualifications DESC;

# 4) LEAVE & ABSENCE PATTERNS

-- 1. Year with most leaves
SELECT YEAR(date) AS year, COUNT(*) AS total_leaves
FROM Leaves
GROUP BY YEAR(date)
ORDER BY total_leaves DESC;

-- 2. Average leaves per department
SELECT jd.jobdept, AVG(leave_count) AS avg_leaves
FROM (
    SELECT emp_ID, COUNT(*) AS leave_count
    FROM Leaves
    GROUP BY emp_ID
) l
JOIN Employee e ON l.emp_ID = e.emp_ID
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- 3. Employees with most leaves
SELECT e.emp_ID, e.firstname, COUNT(l.leave_ID) AS total_leaves
FROM Employee e
JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID, e.firstname
ORDER BY total_leaves DESC;

-- 4. Total leave days company-wide
SELECT COUNT(*) AS total_leaves
FROM Leaves;

-- 5. Leave vs payroll correlation
SELECT e.emp_ID, COUNT(l.leave_ID) AS leave_days,
       AVG(p.total_amount) AS avg_salary
FROM Employee e
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID;
# 5) PAYROLL & COMPENSATION ANALYSIS

-- 1. Total monthly payroll
SELECT MONTH(date) AS month, SUM(total_amount) AS total_payroll
FROM Payroll
GROUP BY MONTH(date)
ORDER BY month;

-- 2. Average bonus per department
SELECT jd.jobdept, AVG(sb.bonus) AS avg_bonus
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;
-- 3. Department with highest bonuses
SELECT jd.jobdept, SUM(sb.bonus) AS total_bonus
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_bonus DESC;
-- 4. Average payroll after leave deduction
SELECT AVG(total_amount) AS avg_payroll
FROM Payroll;

-- Window Functions
#Rank employees within each department
SELECT jd.jobdept, e.emp_ID, e.firstname, sb.amount,
RANK() OVER (PARTITION BY jd.jobdept ORDER BY sb.amount DESC) AS dept_rank
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID;

-- Compare employee salary with department average
SELECT e.emp_ID, e.firstname, sb.amount,
AVG(sb.amount) OVER (PARTITION BY jd.jobdept) AS dept_avg,
(sb.amount - AVG(sb.amount) OVER (PARTITION BY jd.jobdept)) AS difference
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID;

-- CTE (Common Table Expressions)
-- Top 10% highest-paid employees
WITH salary_rank AS (
    SELECT e.emp_ID, e.firstname, sb.amount,
           NTILE(10) OVER (ORDER BY sb.amount DESC) AS percentile
    FROM Employee e
    JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
)
SELECT *
FROM salary_rank
WHERE percentile = 1;

-- PAYROLL vs LEAVE TREND
#Monthly leave vs payroll analysis
SELECT MONTH(p.date) AS month,
       COUNT(l.leave_ID) AS total_leaves,
       SUM(p.total_amount) AS total_payroll
FROM Payroll p
LEFT JOIN Leaves l ON p.emp_ID = l.emp_ID
GROUP BY MONTH(p.date)
ORDER BY month;

# BUSINESS LOGIC USING CASE
-- Categorize employees based on salary
SELECT e.emp_ID, e.firstname, sb.amount,
CASE 
    WHEN sb.amount > 70000 THEN 'High Salary'
    WHEN sb.amount BETWEEN 40000 AND 70000 THEN 'Medium Salary'
    ELSE 'Low Salary'
END AS salary_category
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID;

# SUBQUERY (SMART FILTERING)
-- Employees earning more than department average
SELECT e.emp_ID, e.firstname, sb.amount
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
WHERE sb.amount > (
    SELECT AVG(amount) FROM SalaryBonus
);

select *from qualification;

# MULTI-TABLE COMPLEX JOIN
-- Complete employee report
SELECT e.emp_ID, e.firstname, jd.jobdept,
       sb.amount, sb.bonus,
       COUNT(l.leave_ID) AS total_leaves,
       p.total_amount
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID, e.firstname, jd.jobdept, sb.amount, sb.bonus, p.total_amount;

# DETECT DATA ISSUES
-- Duplicate salary detection

SELECT amount, COUNT(*)
FROM SalaryBonus
GROUP BY amount
HAVING COUNT(*) > 1;

# TREND ANALYSIS (WINDOW + AGG)
-- Running payroll total
SELECT date,
SUM(total_amount) OVER (ORDER BY date) AS running_total
FROM Payroll;

# JOINS 
-- Employees with department & salary (basic join)
SELECT e.emp_ID, e.firstname, jd.jobdept, sb.amount
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID;

-- Dense rank employees by salary
SELECT e.emp_ID, e.firstname, sb.amount,
DENSE_RANK() OVER (ORDER BY sb.amount DESC) AS rank_salary
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID;

-- Salary difference with previous employee
SELECT e.emp_ID, sb.amount,
LAG(sb.amount) OVER (ORDER BY sb.amount) AS prev_salary,
(sb.amount - LAG(sb.amount) OVER (ORDER BY sb.amount)) AS diff
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID;

-- Top 3 employees per department
SELECT *
FROM (
    SELECT e.emp_ID, jd.jobdept, sb.amount,
           RANK() OVER (PARTITION BY jd.jobdept ORDER BY sb.amount DESC) AS rnk
    FROM Employee e
    JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
    JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
) t
WHERE rnk <= 3;

-- Auto update payroll after leave
CREATE TRIGGER deduct_salary
AFTER INSERT ON Leaves
FOR EACH ROW
UPDATE Payroll
SET total_amount = total_amount - 500
WHERE emp_ID = NEW.emp_ID;

-- Department performance ranking
SELECT jd.jobdept,
SUM(p.total_amount) AS total_revenue,
RANK() OVER (ORDER BY SUM(p.total_amount) DESC) AS dept_rank
FROM Payroll p
JOIN JobDepartment jd ON p.job_ID = jd.Job_ID
GROUP BY jd.jobdept;
