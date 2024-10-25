-- Create the 'departments' table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    manager_id INT
);

-- Create the 'employees' table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department_id INT REFERENCES departments(department_id),
    job_title VARCHAR(50),
    hire_date DATE,
    salary DECIMAL(10, 2),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20)
);

-- Create the 'projects' table
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    department_id INT REFERENCES departments(department_id),
    start_date DATE,
    end_date DATE
);

-- Create the 'salaries' table
CREATE TABLE salaries (
    salary_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    salary_amount DECIMAL(10, 2) NOT NULL,
    salary_date DATE NOT NULL
);

-- Create the 'leaves' table
CREATE TABLE leaves (
    leave_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    leave_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    leave_reason TEXT
);

-- Insert into departments
INSERT INTO departments (department_name, manager_id) 
VALUES ('Human Resources', 1), ('Engineering', 2), ('Sales', 3);

-- Insert into employees
INSERT INTO employees (first_name, last_name, department_id, job_title, hire_date, salary, email, phone_number)
VALUES ('John', 'Doe', 1, 'HR Manager', '2020-01-15', 55000.00, 'john.doe@example.com', '123-456-7890');



-- Get all employees with their department
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;


-- Update employee's salary
UPDATE employees
SET salary = 60000.00
WHERE employee_id = 1;


-- Delete an employee
DELETE FROM employees
WHERE employee_id = 2;




-- Get all employees and their corresponding departments
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;




-- Get all departments, including those without employees
SELECT d.department_name, e.first_name, e.last_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id;



-- Function to calculate the total salary of an employee
CREATE OR REPLACE FUNCTION calculate_total_salary(emp_id INT)
RETURNS NUMERIC AS $$
DECLARE
    total_salary NUMERIC;
BEGIN
    SELECT SUM(salary_amount) INTO total_salary
    FROM salaries
    WHERE employee_id = emp_id;
    RETURN total_salary;
END;
$$ LANGUAGE plpgsql;


-- Get total salary for employee with ID 1
SELECT calculate_total_salary(1);



-- Create a log table
CREATE TABLE employee_log (
    log_id SERIAL PRIMARY KEY,
    employee_id INT,
    action VARCHAR(50),
    log_time TIMESTAMP
);

-- Create the trigger function
CREATE OR REPLACE FUNCTION log_employee_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employee_log (employee_id, action, log_time)
    VALUES (NEW.employee_id, 'INSERT', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER after_employee_insert
AFTER INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_insert();



CREATE VIEW active_employees AS
SELECT employee_id, first_name, last_name, department_id, job_title
FROM employees
WHERE employee_id NOT IN (SELECT employee_id FROM leaves WHERE leave_type = 'resigned');


CREATE INDEX idx_last_name ON employees(last_name);



BEGIN;

-- Deduct salary
UPDATE salaries
SET salary_amount = salary_amount - 500
WHERE employee_id = 1;

-- Add a record to the leaves table
INSERT INTO leaves (employee_id, leave_type, start_date, end_date, leave_reason)
VALUES (1, 'unpaid leave', '2024-01-01', '2024-01-10', 'Vacation');

COMMIT;



-- Create a role for HR users
CREATE ROLE hr_role WITH LOGIN PASSWORD 'hr_password';

-- Grant select, insert, and update permissions on employees to hr_role
GRANT SELECT, INSERT, UPDATE ON employees TO hr_role;
