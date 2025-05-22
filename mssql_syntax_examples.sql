/***************************************************************************************************
MS SQL Server Complete Syntax Examples

Purpose:
This script provides a comprehensive collection of T-SQL examples covering various aspects
of SQL Server, including Data Definition Language (DDL), Data Manipulation Language (DML),
Data Query Language (DQL), Transaction Control Language (TCL), Data Control Language (DCL),
and other common T-SQL programming constructs.

How to Use:
1.  Database Context: Most examples are intended to be run within a specific database context
    (created and named 'NewTestDB' in the DDL section). Ensure the `USE NewTestDB;` command
    is executed before running sections that operate on database objects. Exceptions are
    server-level operations (like CREATE LOGIN) which are typically run in `master`.
2.  Execution: It's recommended to run each major section (DDL, DML, etc.) or even
    individual examples separately to understand their effects.
3.  Idempotency: Many DDL statements include `IF EXISTS` or `IF NOT EXISTS` checks to allow
    the script or parts of it to be run multiple times without errors.
4.  Permissions: Some commands, especially in the DCL section (e.g., CREATE LOGIN,
    server-level grants) and DDL section (e.g., CREATE DATABASE), require elevated
    permissions. If you encounter permission errors, you may need to run these parts
    of the script as a user with appropriate administrative rights (e.g., sysadmin).
5.  Cleanup: A comprehensive cleanup script is provided at the end to remove all objects
    created by this script. Uncomment and run it if you wish to revert the changes.

Author: AI Code Generation
Version: 1.0
Last Updated: (Will be updated upon changes)

***************************************************************************************************/

-- Initial Setup: Create the database if it doesn't exist.
-- Note: CREATE DATABASE should ideally be run in the context of the 'master' database,
-- or by a user with permissions to create databases.
-- For simplicity in a single script, we run it here. If issues, run this block separately.
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'NewTestDB')
BEGIN
    CREATE DATABASE NewTestDB;
    PRINT 'Database NewTestDB created.';
END
ELSE
BEGIN
    PRINT 'Database NewTestDB already exists.';
END
GO

-- Switch to the context of NewTestDB for subsequent operations
USE NewTestDB;
GO

----------------------------------------------------------------------------------------------------
-- Data Definition Language (DDL) Examples
----------------------------------------------------------------------------------------------------
PRINT 'Executing DDL Section...';
GO

-- CREATE TABLE: Departments
IF OBJECT_ID('dbo.Departments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Departments (
        DepartmentID INT PRIMARY KEY,
        DepartmentName VARCHAR(100) NOT NULL
    );
    PRINT 'Table dbo.Departments created.';
END
ELSE
BEGIN
    PRINT 'Table dbo.Departments already exists.';
END
GO

-- CREATE TABLE: Employees
IF OBJECT_ID('dbo.Employees', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Employees (
        EmployeeID INT PRIMARY KEY,
        FirstName VARCHAR(50),
        LastName VARCHAR(50),
        BirthDate DATE,
        Email VARCHAR(100),
        DepartmentID INT,
        Salary DECIMAL(10, 2),
        ManagerID INT, -- For Self Join example
        CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID),
        CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerID) REFERENCES dbo.Employees(EmployeeID) -- Self-referencing FK
    );
    PRINT 'Table dbo.Employees created.';
END
ELSE
BEGIN
    PRINT 'Table dbo.Employees already exists.';
END
GO

-- CREATE TABLE: Salaries (for window function examples)
IF OBJECT_ID('dbo.Salaries', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Salaries (
        EmployeeID INT,
        SalaryMonth DATE,
        Amount DECIMAL(10, 2),
        PRIMARY KEY (EmployeeID, SalaryMonth),
        CONSTRAINT FK_Salaries_Employees FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID)
    );
    PRINT 'Table dbo.Salaries created.';
END
ELSE
BEGIN
    PRINT 'Table dbo.Salaries already exists.';
END
GO

-- ALTER TABLE: Example of adding a new column (uncomment to run)
/*
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Employees') AND name = 'HireDate')
BEGIN
    ALTER TABLE dbo.Employees
    ADD HireDate DATE;
    PRINT 'Column HireDate added to dbo.Employees.';
END
ELSE
BEGIN
    PRINT 'Column HireDate already exists in dbo.Employees.';
END
GO
*/

-- CREATE INDEX: IX_Employees_LastName
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employees_LastName' AND object_id = OBJECT_ID('dbo.Employees'))
BEGIN
    CREATE INDEX IX_Employees_LastName
    ON dbo.Employees (LastName);
    PRINT 'Index IX_Employees_LastName created on dbo.Employees.';
END
ELSE
BEGIN
    PRINT 'Index IX_Employees_LastName already exists on dbo.Employees.';
END
GO

-- CREATE INDEX: IX_Employees_DepartmentID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employees_DepartmentID' AND object_id = OBJECT_ID('dbo.Employees'))
BEGIN
    CREATE INDEX IX_Employees_DepartmentID
    ON dbo.Employees (DepartmentID);
    PRINT 'Index IX_Employees_DepartmentID created on dbo.Employees.';
END
ELSE
BEGIN
    PRINT 'Index IX_Employees_DepartmentID already exists on dbo.Employees.';
END
GO

-- CREATE OR ALTER VIEW: V_EmployeeDetails (SQL Server 2016 SP1+)
CREATE OR ALTER VIEW dbo.V_EmployeeDetails AS
SELECT e.EmployeeID, e.FirstName, e.LastName, d.DepartmentName, e.Salary, e.Email
FROM dbo.Employees e
LEFT JOIN dbo.Departments d ON e.DepartmentID = d.DepartmentID;
GO
PRINT 'View dbo.V_EmployeeDetails created or altered.';
GO

-- CREATE OR ALTER PROCEDURE: sp_GetEmployeesByDepartment
CREATE OR ALTER PROCEDURE dbo.sp_GetEmployeesByDepartment (@DepartmentID INT)
AS
BEGIN
    SELECT EmployeeID, FirstName, LastName, Email, Salary, DepartmentID
    FROM dbo.Employees
    WHERE DepartmentID = @DepartmentID
    ORDER BY LastName, FirstName;
END;
GO
PRINT 'Procedure dbo.sp_GetEmployeesByDepartment created or altered.';
GO

-- CREATE OR ALTER FUNCTION: fn_GetEmployeeFullName
CREATE OR ALTER FUNCTION dbo.fn_GetEmployeeFullName (@EmployeeID INT)
RETURNS VARCHAR(250)
AS
BEGIN
    DECLARE @FullName VARCHAR(250);
    SELECT @FullName = ISNULL(FirstName, '') + ' ' + ISNULL(LastName, '')
    FROM dbo.Employees
    WHERE EmployeeID = @EmployeeID;
    RETURN @FullName;
END;
GO
PRINT 'Function dbo.fn_GetEmployeeFullName created or altered.';
GO

-- CREATE TABLE: SalaryAudit (for trigger example)
IF OBJECT_ID('dbo.SalaryAudit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SalaryAudit (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeID INT,
        OldSalary DECIMAL(10,2),
        NewSalary DECIMAL(10,2),
        ChangedDate DATETIME DEFAULT GETDATE()
    );
    PRINT 'Table dbo.SalaryAudit created.';
END
ELSE
BEGIN
    PRINT 'Table dbo.SalaryAudit already exists.';
END
GO

-- CREATE OR ALTER TRIGGER: trg_EmployeeSalaryUpdate
CREATE OR ALTER TRIGGER dbo.trg_EmployeeSalaryUpdate
ON dbo.Employees
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Salary) -- Trigger only if Salary column was updated
    BEGIN
        INSERT INTO dbo.SalaryAudit (EmployeeID, OldSalary, NewSalary, ChangedDate)
        SELECT d.EmployeeID, d.Salary, i.Salary, GETDATE()
        FROM deleted d
        INNER JOIN inserted i ON d.EmployeeID = i.EmployeeID
        WHERE d.Salary <> i.Salary; -- Only log if salary actually changed
    END
END;
GO
PRINT 'Trigger dbo.trg_EmployeeSalaryUpdate created or altered on dbo.Employees.';
GO

----------------------------------------------------------------------------------------------------
-- Data Manipulation Language (DML) Examples
----------------------------------------------------------------------------------------------------
PRINT 'Executing DML Section...';
GO

-- Ensure we are using the correct database context
USE NewTestDB;
GO

-- Populate Departments table (Clear existing data first for idempotency)
-- This is a simple approach; for production, consider checking for existing data more carefully.
TRUNCATE TABLE dbo.Departments; -- Clear previous data if any
INSERT INTO dbo.Departments (DepartmentID, DepartmentName)
VALUES
(1, 'Human Resources'),
(2, 'Engineering'),
(3, 'Marketing'),
(4, 'Sales'),
(5, 'Finance');
PRINT 'Data inserted into dbo.Departments.';
GO

-- Populate Employees table (Clear existing data first for idempotency, respecting FKs)
-- For re-runnability, delete in an order that respects FKs or disable/enable them.
-- Simpler for example: if SalaryAudit has FK to Employees, clear it first.
IF OBJECT_ID('dbo.SalaryAudit', 'U') IS NOT NULL TRUNCATE TABLE dbo.SalaryAudit;
IF OBJECT_ID('dbo.Salaries', 'U') IS NOT NULL TRUNCATE TABLE dbo.Salaries;
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DELETE FROM dbo.Employees; -- Use DELETE if there are FKs pointing to Employees not handled by CASCADE DELETE

INSERT INTO dbo.Employees (EmployeeID, FirstName, LastName, BirthDate, Email, DepartmentID, Salary, ManagerID)
VALUES
(1, 'John', 'Doe', '1990-05-15', 'john.doe@example.com', 2, 70000.00, NULL),
(2, 'Jane', 'Smith', '1985-08-22', 'jane.smith@example.com', 2, 75000.00, 1),
(3, 'Alice', 'Johnson', '1992-01-30', 'alice.j@example.com', 1, 60000.00, NULL),
(4, 'Bob', 'Brown', '1978-11-02', 'bob.b@example.com', 3, 65000.00, 3),
(5, 'Mike', 'Davis', '1988-07-10', 'mike.d@example.com', 2, 80000.00, 1),
(6, 'Sarah', 'Wilson', '1995-03-20', 'sarah.w@example.com', 4, 72000.00, NULL),
(7, 'Kevin', 'Lee', '1982-12-05', 'kevin.l@example.com', 4, 71000.00, 6),
(8, 'Emily', 'White', '1993-09-18', 'emily.w@example.com', 1, 62000.00, 3),
(9, 'David', 'Garcia', '1989-06-25', 'david.g@example.com', 5, 90000.00, NULL),
(10, 'Laura', 'Martinez', '1991-04-12', 'laura.m@example.com', 5, 85000.00, 9);
PRINT 'Data inserted into dbo.Employees.';
GO

-- Update ManagerIDs for self-join and recursive CTE examples
UPDATE dbo.Employees SET ManagerID = 3 WHERE EmployeeID = 1; -- John Doe reports to Alice Johnson
UPDATE dbo.Employees SET ManagerID = 1 WHERE EmployeeID = 4; -- Bob Brown reports to John Doe
PRINT 'ManagerIDs updated in dbo.Employees.';
GO

-- Populate Salaries table
TRUNCATE TABLE dbo.Salaries;
INSERT INTO dbo.Salaries (EmployeeID, SalaryMonth, Amount)
VALUES
(1, '2023-01-01', 68000.00), (1, '2023-02-01', 68000.00), (1, '2023-03-01', 70000.00),
(2, '2023-01-01', 75000.00), (2, '2023-02-01', 75000.00), (2, '2023-03-01', 75000.00),
(5, '2023-01-01', 78000.00), (5, '2023-02-01', 80000.00), (5, '2023-03-01', 80000.00);
PRINT 'Data inserted into dbo.Salaries.';
GO

-- UPDATE example
UPDATE dbo.Employees
SET Email = 'john.d.updated@example.com'
WHERE EmployeeID = 1;
PRINT 'Email updated for EmployeeID 1.';
GO

-- MERGE Example: Staging table setup
IF OBJECT_ID('dbo.Staging_Employees', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Staging_Employees (
        StagingEmployeeID INT PRIMARY KEY,
        FirstName VARCHAR(100),
        LastName VARCHAR(100),
        Email VARCHAR(100),
        DepartmentID INT,
        Salary DECIMAL(10,2),
        Action VARCHAR(10)
    );
    PRINT 'Table dbo.Staging_Employees created.';
END
ELSE
BEGIN
     PRINT 'Table dbo.Staging_Employees already exists. Clearing data.';
    TRUNCATE TABLE dbo.Staging_Employees;
END
GO

INSERT INTO dbo.Staging_Employees (StagingEmployeeID, FirstName, LastName, Email, DepartmentID, Salary, Action)
VALUES
(1, 'John', 'Doe', 'john.new.email@example.com', 2, 72000.00, 'UPDATE'), -- Matched
(11, 'Chris', 'Green', 'chris.g@example.com', 3, 58000.00, 'INSERT');    -- Not Matched by Target
PRINT 'Data inserted into dbo.Staging_Employees.';
GO

MERGE dbo.Employees AS TARGET
USING dbo.Staging_Employees AS SOURCE
ON (TARGET.EmployeeID = SOURCE.StagingEmployeeID)
WHEN MATCHED AND SOURCE.Action = 'UPDATE' THEN
    UPDATE SET
        TARGET.Email = SOURCE.Email,
        TARGET.Salary = SOURCE.Salary,
        TARGET.DepartmentID = SOURCE.DepartmentID
WHEN NOT MATCHED BY TARGET AND SOURCE.Action = 'INSERT' THEN
    INSERT (EmployeeID, FirstName, LastName, Email, DepartmentID, Salary)
    VALUES (SOURCE.StagingEmployeeID, SOURCE.FirstName, SOURCE.LastName, SOURCE.Email, SOURCE.DepartmentID, SOURCE.Salary)
-- Example of WHEN NOT MATCHED BY SOURCE (deletes employees in Target not in Source)
-- WHEN NOT MATCHED BY SOURCE THEN
--     DELETE
OUTPUT $action, Inserted.*, Deleted.*;
GO
PRINT 'MERGE operation completed on dbo.Employees.';
GO

----------------------------------------------------------------------------------------------------
-- Data Query Language (DQL) Examples
----------------------------------------------------------------------------------------------------
PRINT 'Executing DQL Section...';
GO
USE NewTestDB;
GO

-- Example 1: Select all columns and all rows
SELECT *
FROM dbo.Employees;
GO

-- Example 2: Select specific columns
SELECT EmployeeID, FirstName, LastName, Salary
FROM dbo.Employees;
GO

-- Example 3: WHERE clause
SELECT EmployeeID, FirstName, LastName, DepartmentID
FROM dbo.Employees
WHERE DepartmentID = 2; -- Engineering
GO

-- Example 4: ORDER BY clause
SELECT EmployeeID, FirstName, LastName, Salary
FROM dbo.Employees
ORDER BY Salary DESC;
GO

-- Example 5: DISTINCT clause
SELECT DISTINCT DepartmentID
FROM dbo.Employees;
GO

-- Example 6: TOP clause (SQL Server specific)
SELECT TOP 3 EmployeeID, FirstName, LastName, Salary
FROM dbo.Employees
ORDER BY Salary DESC;
GO

-- Example 7: GROUP BY clause
SELECT DepartmentID, COUNT(*) AS NumberOfEmployees
FROM dbo.Employees
GROUP BY DepartmentID;
GO

-- Example 8: HAVING clause
SELECT DepartmentID, COUNT(*) AS NumberOfEmployees
FROM dbo.Employees
GROUP BY DepartmentID
HAVING COUNT(*) > 2;
GO

-- Example 9: Combining WHERE, GROUP BY, HAVING, ORDER BY
SELECT DepartmentID, AVG(Salary) AS AverageSalary
FROM dbo.Employees
WHERE DepartmentID <> 1 -- Exclude HR
GROUP BY DepartmentID
HAVING COUNT(*) > 1
ORDER BY AverageSalary DESC;
GO

-- JOIN operations
-- Example 10: INNER JOIN
SELECT e.FirstName, e.LastName, d.DepartmentName
FROM dbo.Employees e
INNER JOIN dbo.Departments d ON e.DepartmentID = d.DepartmentID;
GO

-- Example 11: LEFT JOIN
SELECT e.FirstName, e.LastName, d.DepartmentName
FROM dbo.Employees e
LEFT JOIN dbo.Departments d ON e.DepartmentID = d.DepartmentID;
GO

-- Example 12: RIGHT JOIN
SELECT e.FirstName, e.LastName, d.DepartmentName
FROM dbo.Departments d
RIGHT JOIN dbo.Employees e ON e.DepartmentID = d.DepartmentID;
GO

-- Example 13: FULL OUTER JOIN
SELECT e.FirstName, e.LastName, d.DepartmentName
FROM dbo.Employees e
FULL OUTER JOIN dbo.Departments d ON e.DepartmentID = d.DepartmentID;
GO

-- Example 14: CROSS JOIN (Use with caution)
/*
SELECT e.FirstName, d.DepartmentName
FROM dbo.Employees e
CROSS JOIN dbo.Departments d;
GO
*/

-- Example 15: SELF JOIN (Employees and their Managers)
SELECT
    e.FirstName AS EmployeeFirstName,
    e.LastName AS EmployeeLastName,
    m.FirstName AS ManagerFirstName,
    m.LastName AS ManagerLastName
FROM dbo.Employees e
INNER JOIN dbo.Employees m ON e.ManagerID = m.EmployeeID;
GO

-- Subqueries
-- Example 16: Scalar Subquery in SELECT
SELECT
    e.FirstName,
    e.LastName,
    (SELECT AVG(Salary) FROM dbo.Employees WHERE DepartmentID = e.DepartmentID) AS DepartmentAverageSalary
FROM dbo.Employees e;
GO

-- Example 17: Subquery in WHERE
SELECT EmployeeID, FirstName, LastName, Salary
FROM dbo.Employees
WHERE Salary > (SELECT AVG(Salary) FROM dbo.Employees);
GO

-- Example 18: Derived Table (Subquery in FROM)
SELECT MAX(AvgDeptSalary) AS MaxAverageDepartmentSalary
FROM (
    SELECT DepartmentID, AVG(Salary) AS AvgDeptSalary
    FROM dbo.Employees
    GROUP BY DepartmentID
) AS DepartmentAverages;
GO

-- Example 19: Correlated Subquery in WHERE
SELECT e1.EmployeeID, e1.FirstName, e1.LastName, e1.DepartmentID, e1.Salary
FROM dbo.Employees e1
WHERE e1.Salary = (
    SELECT MAX(e2.Salary)
    FROM dbo.Employees e2
    WHERE e2.DepartmentID = e1.DepartmentID
);
GO

-- Common Table Expressions (CTEs)
-- Example 20: Single CTE
WITH EngineeringEmployees AS (
    SELECT EmployeeID, FirstName, LastName, Salary, DepartmentID
    FROM dbo.Employees
    WHERE DepartmentID = (SELECT DepartmentID FROM dbo.Departments WHERE DepartmentName = 'Engineering')
)
SELECT * FROM EngineeringEmployees;
GO

-- Example 21: Multiple CTEs
WITH EngineeringEmployees AS (
    SELECT EmployeeID, Salary, DepartmentID
    FROM dbo.Employees
    WHERE DepartmentID = (SELECT DepartmentID FROM dbo.Departments WHERE DepartmentName = 'Engineering')
),
AvgEngSalary AS (
    SELECT AVG(Salary) AS AverageSalary
    FROM EngineeringEmployees
)
SELECT AverageSalary FROM AvgEngSalary;
GO

-- Example 22: Recursive CTE (Employee Hierarchy)
WITH EmployeeHierarchy AS (
    SELECT EmployeeID, FirstName, LastName, ManagerID, 0 AS HierarchyLevel
    FROM dbo.Employees
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmployeeID, e.FirstName, e.LastName, e.ManagerID, eh.HierarchyLevel + 1
    FROM dbo.Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
    WHERE eh.HierarchyLevel < 10 -- Max recursion depth to prevent infinite loops
)
SELECT *
FROM EmployeeHierarchy
ORDER BY HierarchyLevel, ManagerID, EmployeeID;
GO

-- Aggregate functions (Examples 23-28 are straightforward and generally don't need changes for review)
-- ... (keeping them as they are) ...
SELECT COUNT(*) AS TotalEmployees FROM dbo.Employees;
GO
SELECT COUNT(DISTINCT DepartmentID) AS NumberOfUniqueDepartmentsWithEmployees FROM dbo.Employees;
GO
SELECT SUM(Salary) AS TotalSalaryExpense FROM dbo.Employees;
GO
SELECT AVG(Salary) AS AverageSalary FROM dbo.Employees;
GO
SELECT MIN(Salary) AS MinimumSalary FROM dbo.Employees;
GO
SELECT MAX(Salary) AS MaximumSalary FROM dbo.Employees;
GO
SELECT
    DepartmentID,
    COUNT(*) AS NumberOfEmployees,
    SUM(Salary) AS TotalSalary,
    AVG(Salary) AS AverageSalary,
    MIN(Salary) AS MinimumSalary,
    MAX(Salary) AS MaximumSalary
FROM dbo.Employees
GROUP BY DepartmentID;
GO

-- String functions (Examples 29-34)
-- ... (keeping them as they are) ...
SELECT FirstName, LEN(FirstName) AS LengthOfFirstName FROM dbo.Employees;
GO
SELECT LastName, SUBSTRING(LastName, 1, 3) AS SubstringLastName FROM dbo.Employees;
GO
SELECT Email, CHARINDEX('@', Email) AS AtSignPosition FROM dbo.Employees;
GO
SELECT Email, REPLACE(Email, '.com', '.org') AS NewEmailDomain FROM dbo.Employees;
GO
SELECT FirstName, LastName, CONCAT(FirstName, ' ', LastName) AS FullNameConcat FROM dbo.Employees;
GO
SELECT FirstName, UPPER(FirstName) AS UpperFirstName, LOWER(LastName) AS LowerLastName FROM dbo.Employees;
GO


-- Date functions (Examples 35-39)
-- ... (keeping them as they are) ...
SELECT GETDATE() AS CurrentDateTime;
GO
SELECT BirthDate, DATEADD(YEAR, 1, BirthDate) AS BirthDatePlusOneYear FROM dbo.Employees;
GO
SELECT BirthDate, DATEDIFF(YEAR, BirthDate, GETDATE()) AS AgeInYears FROM dbo.Employees;
GO
SELECT BirthDate, YEAR(BirthDate) AS BirthYear, MONTH(BirthDate) AS BirthMonth, DAY(BirthDate) AS BirthDay FROM dbo.Employees;
GO
SELECT BirthDate, FORMAT(BirthDate, 'dd-MM-yyyy') AS FormattedBirthDate_DMY, FORMAT(BirthDate, 'MMMM dd, yyyy') AS FormattedBirthDate_Text FROM dbo.Employees;
GO


-- Window functions (Examples 40-47, using dbo.Employees and dbo.Salaries)
-- ... (schema qualifier added, otherwise fine) ...
SELECT EmployeeID, FirstName, LastName, DepartmentID, Salary, ROW_NUMBER() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS RankInDepartment FROM dbo.Employees;
GO
SELECT EmployeeID, FirstName, LastName, Salary, RANK() OVER (ORDER BY Salary DESC) AS SalaryRankGlobal FROM dbo.Employees;
GO
SELECT EmployeeID, FirstName, LastName, Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryDenseRankGlobal FROM dbo.Employees;
GO
SELECT EmployeeID, FirstName, LastName, Salary, NTILE(4) OVER (ORDER BY Salary DESC) AS SalaryQuartile FROM dbo.Employees;
GO
SELECT EmployeeID, SalaryMonth, Amount, LAG(Amount, 1, 0.00) OVER (PARTITION BY EmployeeID ORDER BY SalaryMonth) AS PreviousMonthSalary FROM dbo.Salaries ORDER BY EmployeeID, SalaryMonth;
GO
SELECT EmployeeID, SalaryMonth, Amount, LEAD(Amount, 1, 0.00) OVER (PARTITION BY EmployeeID ORDER BY SalaryMonth) AS NextMonthSalary FROM dbo.Salaries ORDER BY EmployeeID, SalaryMonth;
GO
SELECT EmployeeID, FirstName, LastName, DepartmentID, Salary, AVG(Salary) OVER (PARTITION BY DepartmentID) AS DepartmentAverageSalary FROM dbo.Employees;
GO
SELECT EmployeeID, FirstName, DepartmentID, Salary, SUM(Salary) OVER (PARTITION BY DepartmentID ORDER BY EmployeeID ROWS UNBOUNDED PRECEDING) AS RunningTotalSalaryInDept FROM dbo.Employees;
GO

----------------------------------------------------------------------------------------------------
-- Transaction Control Language (TCL) Examples
----------------------------------------------------------------------------------------------------
PRINT 'Executing TCL Section...';
GO
USE NewTestDB;
GO

-- Create a sample table for TCL demonstrations
IF OBJECT_ID('dbo.TestAccounts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TestAccounts (
        AccountID INT PRIMARY KEY,
        AccountHolder VARCHAR(100),
        Balance DECIMAL(10, 2)
    );
    PRINT 'Table dbo.TestAccounts created.';
END
ELSE
BEGIN
    PRINT 'Table dbo.TestAccounts already exists. Clearing data.';
    TRUNCATE TABLE dbo.TestAccounts;
END
GO

INSERT INTO dbo.TestAccounts (AccountID, AccountHolder, Balance)
VALUES
(1, 'Alice Wonderland', 1000.00),
(2, 'Bob The Builder', 500.00);
PRINT 'Data inserted into dbo.TestAccounts.';
GO

-- Example 1: BEGIN TRANSACTION and COMMIT TRANSACTION
PRINT 'TCL Example 1: BEGIN TRANSACTION and COMMIT TRANSACTION';
SELECT * FROM dbo.TestAccounts;

BEGIN TRANSACTION;
UPDATE dbo.TestAccounts SET Balance = Balance - 100 WHERE AccountID = 1;
UPDATE dbo.TestAccounts SET Balance = Balance + 100 WHERE AccountID = 2;
IF (SELECT Balance FROM dbo.TestAccounts WHERE AccountID = 1) >= 0
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transaction committed. Money transferred.';
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back. Insufficient funds or other error.';
END
SELECT * FROM dbo.TestAccounts;
GO

-- Example 2: BEGIN TRANSACTION and ROLLBACK TRANSACTION
PRINT 'TCL Example 2: BEGIN TRANSACTION and ROLLBACK TRANSACTION';
SELECT * FROM dbo.TestAccounts;
BEGIN TRANSACTION;
UPDATE dbo.TestAccounts SET Balance = Balance + 2000 WHERE AccountID = 1;
UPDATE dbo.TestAccounts SET Balance = Balance - 2000 WHERE AccountID = 2;
IF (SELECT Balance FROM dbo.TestAccounts WHERE AccountID = 2) < 0
BEGIN
    PRINT 'Bob has insufficient funds. Rolling back transaction.';
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transaction committed (this part should ideally not be reached).';
END
SELECT * FROM dbo.TestAccounts;
GO

-- Example 3: SAVE TRANSACTION (Savepoints)
PRINT 'TCL Example 3: SAVE TRANSACTION';
SELECT * FROM dbo.TestAccounts;
BEGIN TRANSACTION;
UPDATE dbo.TestAccounts SET Balance = Balance + 50 WHERE AccountID = 1;
PRINT 'Alice gets $50 bonus.';
SAVE TRANSACTION Savepoint1;
PRINT 'Savepoint1 created.';
UPDATE dbo.TestAccounts SET Balance = Balance + 25 WHERE AccountID = 2;
PRINT 'Bob gets $25 bonus.';
-- SAVE TRANSACTION Savepoint2; -- This savepoint is not used in the rollback, can be removed or kept
-- PRINT 'Savepoint2 created.';
UPDATE dbo.TestAccounts SET Balance = Balance - (SELECT Balance FROM dbo.TestAccounts WHERE AccountID = 1) - 100 WHERE AccountID = 1; -- Force negative
PRINT 'Attempted to make Alice''s balance negative.';
IF (SELECT Balance FROM dbo.TestAccounts WHERE AccountID = 1) < 0
BEGIN
    PRINT 'Alice balance would be negative. Rolling back to Savepoint1...';
    ROLLBACK TRANSACTION Savepoint1;
    PRINT 'Rolled back to Savepoint1. Bob''s $25 bonus and Alice''s large deduction are undone.';
    COMMIT TRANSACTION; -- Commit the work done up to Savepoint1 (Alice's $50 bonus)
    PRINT 'Transaction committed up to Savepoint1.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'All operations committed (this should not happen in this specific scenario).';
END
SELECT * FROM dbo.TestAccounts;
GO

-- Example 4: Notes on Implicit Transactions and Autocommit (conceptual)
PRINT 'TCL Example 4: Notes on Implicit Transactions and Autocommit are conceptual in the comments.';
GO


----------------------------------------------------------------------------------------------------
-- Data Control Language (DCL) Examples
----------------------------------------------------------------------------------------------------
PRINT 'Executing DCL Section...';
GO
-- Note: DCL commands require specific permissions. Run this section as a high-privileged user.

-- Switch to master database to create login
USE master;
GO
PRINT 'Switched to master database context for LOGIN creation.';

-- Example DCL.1: Create a server login
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'TestUserLogin')
BEGIN
    CREATE LOGIN TestUserLogin WITH PASSWORD = N'aVeryComplexP@ssw0rd!123', CHECK_POLICY = OFF; -- CHECK_POLICY=OFF for example simplicity
    PRINT 'Login TestUserLogin created.';
END
ELSE
BEGIN
    PRINT 'Login TestUserLogin already exists.';
END
GO

-- Switch back to NewTestDB for user creation and permissions
USE NewTestDB;
GO
PRINT 'Switched to NewTestDB database context.';

-- Example DCL.2: Create a database user mapped to the login
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'TestUser')
BEGIN
    CREATE USER TestUser FOR LOGIN TestUserLogin;
    PRINT 'User TestUser created in NewTestDB for login TestUserLogin.';
END
ELSE
BEGIN
    PRINT 'User TestUser already exists in NewTestDB.';
END
GO

-- Example DCL.3: GRANT specific object permissions
PRINT 'DCL Examples: GRANT';
GRANT SELECT ON dbo.Employees TO TestUser;
PRINT 'Granted SELECT on dbo.Employees to TestUser.';
GO
GRANT INSERT, UPDATE ON dbo.Employees TO TestUser;
PRINT 'Granted INSERT, UPDATE on dbo.Employees to TestUser.';
GO
GRANT EXECUTE ON OBJECT::dbo.sp_GetEmployeesByDepartment TO TestUser;
PRINT 'Granted EXECUTE on dbo.sp_GetEmployeesByDepartment to TestUser.';
GO
GRANT SELECT ON dbo.V_EmployeeDetails TO TestUser;
PRINT 'Granted SELECT on dbo.V_EmployeeDetails to TestUser.';
GO

-- Example DCL.4: REVOKE granted permissions
PRINT 'DCL Examples: REVOKE';
REVOKE INSERT, UPDATE ON dbo.Employees FROM TestUser;
PRINT 'Revoked INSERT, UPDATE on dbo.Employees from TestUser.';
GO
REVOKE EXECUTE ON OBJECT::dbo.sp_GetEmployeesByDepartment FROM TestUser;
PRINT 'Revoked EXECUTE on dbo.sp_GetEmployeesByDepartment from TestUser.';
GO

-- Example DCL.5: DENY permissions
PRINT 'DCL Examples: DENY';
DENY DELETE ON dbo.Employees TO TestUser; -- Deny a permission not previously granted for clarity
PRINT 'Denied DELETE on dbo.Employees to TestUser.';
GO
-- To test: EXECUTE AS USER = 'TestUser'; SELECT * FROM Employees; DELETE FROM Employees WHERE EmployeeID = 1; REVERT;
-- Remove the DENY
REVOKE DENY DELETE ON dbo.Employees FROM TestUser;
PRINT 'Revoked DENY DELETE on dbo.Employees from TestUser.';
GO

-- Example DCL.6: Notes on Permissions and Roles (conceptual)
PRINT 'DCL Examples: Notes are conceptual in the comments.';
GO

-- DCL Cleanup (User and Login) is part of the final cleanup script.

----------------------------------------------------------------------------------------------------
-- Other Common T-SQL Constructs
----------------------------------------------------------------------------------------------------
PRINT 'Executing Other Common T-SQL Constructs Section...';
GO
USE NewTestDB;
GO

-- 1. Variables: Declaration and Setting Values
PRINT 'T-SQL Constructs: 1. Variables';
DECLARE @MyInteger INT = 10;
DECLARE @MyString VARCHAR(100) = 'Hello, T-SQL!';
DECLARE @MyDate DATE = GETDATE();
DECLARE @TotalSalary DECIMAL(18,2); -- Increased precision

SELECT @TotalSalary = SUM(Salary) FROM dbo.Employees;
PRINT 'MyInteger: ' + ISNULL(CONVERT(VARCHAR, @MyInteger), 'NULL');
PRINT 'MyString: ' + ISNULL(@MyString, 'NULL');
PRINT 'MyDate: ' + ISNULL(CONVERT(VARCHAR, @MyDate, 120), 'NULL');
PRINT 'TotalSalary: ' + ISNULL(CONVERT(VARCHAR, @TotalSalary), 'NULL');
GO

-- 2. IF...ELSE Conditional Statements
PRINT 'T-SQL Constructs: 2. IF...ELSE';
DECLARE @EmployeeCount INT;
SELECT @EmployeeCount = COUNT(*) FROM dbo.Employees;
IF @EmployeeCount > 5
BEGIN
    PRINT 'There are more than 5 employees.';
    IF EXISTS (SELECT 1 FROM dbo.Departments WHERE DepartmentName = 'Engineering')
        PRINT 'The Engineering department exists.';
END
ELSE IF @EmployeeCount > 0 AND @EmployeeCount <= 5
    PRINT 'There are between 1 and 5 employees.';
ELSE
    PRINT 'There are no employees in the table.';
GO

-- 3. WHILE Loops
PRINT 'T-SQL Constructs: 3. WHILE Loops';
DECLARE @Counter INT = 1;
PRINT 'Simple WHILE loop (1 to 3):';
WHILE @Counter <= 3
BEGIN
    PRINT 'Counter is: ' + CONVERT(VARCHAR, @Counter);
    SET @Counter = @Counter + 1;
END
GO
PRINT 'WHILE loop with CONTINUE and BREAK:';
DECLARE @LoopVar INT = 0;
WHILE @LoopVar < 10
BEGIN
    SET @LoopVar = @LoopVar + 1;
    IF @LoopVar % 2 = 0 CONTINUE;
    IF @LoopVar = 7 BREAK;
    PRINT 'Processing odd number: ' + CONVERT(VARCHAR, @LoopVar);
END
PRINT 'Loop finished. Final LoopVar value: ' + CONVERT(VARCHAR, @LoopVar);
GO

-- 4. TRY...CATCH Blocks
PRINT 'T-SQL Constructs: 4. TRY...CATCH';
BEGIN TRY
    PRINT 'Attempting division by zero...';
    DECLARE @Result INT = 10 / 0;
END TRY
BEGIN CATCH
    PRINT 'Error caught: ' + ERROR_MESSAGE();
END CATCH
GO
BEGIN TRY
    PRINT 'Attempting to insert duplicate PK into TestAccounts...';
    INSERT INTO dbo.TestAccounts (AccountID, AccountHolder, Balance) VALUES (1, 'Duplicate', 0);
END TRY
BEGIN CATCH
    PRINT 'Error caught: ' + ERROR_MESSAGE();
END CATCH
GO

-- 5. Comments (conceptual, shown throughout script)
PRINT 'T-SQL Constructs: 5. Comments example demonstrated throughout the script.';
GO

-- 6. PRINT Statements (shown throughout script)
PRINT 'T-SQL Constructs: 6. PRINT statement example demonstrated throughout the script.';
GO

-- 7. RAISERROR for Custom Error Generation
PRINT 'T-SQL Constructs: 7. RAISERROR';
BEGIN TRY
    DECLARE @UserRole VARCHAR(50) = 'Guest';
    IF @UserRole <> 'Admin'
        RAISERROR('User %s is not authorized.', 16, 1, @UserRole);
END TRY
BEGIN CATCH
    PRINT 'RAISERROR caught: ' + ERROR_MESSAGE();
END CATCH
GO

-- 8. CASE Expressions
PRINT 'T-SQL Constructs: 8. CASE Expressions';
PRINT 'Simple CASE Expression:';
SELECT FirstName, DepartmentID, CASE DepartmentID WHEN 1 THEN 'HR' WHEN 2 THEN 'Eng' ELSE 'Other' END AS DeptCode
FROM dbo.Employees WHERE EmployeeID <= 3;
GO
PRINT 'Searched CASE Expression:';
SELECT FirstName, Salary, CASE WHEN Salary >= 75000 THEN 'High' ELSE 'Standard' END AS SalaryBand
FROM dbo.Employees WHERE EmployeeID <= 3;
GO
IF OBJECT_ID('tempdb..#TempEmployeeStatus') IS NOT NULL DROP TABLE #TempEmployeeStatus;
CREATE TABLE #TempEmployeeStatus (EmployeeID INT, Status VARCHAR(20));
INSERT INTO #TempEmployeeStatus (EmployeeID, Status) SELECT EmployeeID, 'Pending' FROM dbo.Employees WHERE EmployeeID <=3;
UPDATE #TempEmployeeStatus SET Status = CASE EmployeeID WHEN 1 THEN 'Active' ELSE Status END;
SELECT * FROM #TempEmployeeStatus;
DROP TABLE #TempEmployeeStatus;
GO

-- 9. Dynamic SQL (using sp_executesql)
PRINT 'T-SQL Constructs: 9. Dynamic SQL';
DECLARE @TableName NVARCHAR(128) = N'dbo.Employees';
DECLARE @ColumnName NVARCHAR(128) = N'Salary';
DECLARE @Threshold DECIMAL(10,2) = 70000.00;
DECLARE @DynamicSQL NVARCHAR(MAX) = N'SELECT EmployeeID, FirstName, ' + QUOTENAME(@ColumnName) +
                                  N' FROM ' + @TableName + -- QUOTENAME already applied if schema is part of @TableName
                                  N' WHERE ' + QUOTENAME(@ColumnName) + N' > @SalaryThreshold;';
DECLARE @ParamDefinition NVARCHAR(MAX) = N'@SalaryThreshold DECIMAL(10,2)';
PRINT 'Dynamic SQL: ' + @DynamicSQL;
EXEC sp_executesql @DynamicSQL, @ParamDefinition, @SalaryThreshold = @Threshold;
GO
DECLARE @NewViewName NVARCHAR(128) = N'dbo.V_HighEarnersDynamic';
DECLARE @SQLToCreateView NVARCHAR(MAX) = N'
IF OBJECT_ID(''' + REPLACE(@NewViewName, '''', '''''') + ''', ''V'') IS NOT NULL
    DROP VIEW ' + @NewViewName + N';
EXEC(''CREATE VIEW ' + @NewViewName + N' AS
SELECT EmployeeID, FirstName, Salary FROM dbo.Employees WHERE Salary > 75000;'');';
PRINT 'Dynamic SQL for CREATE VIEW: ' + @SQLToCreateView;
EXEC sp_executesql @SQLToCreateView;
IF OBJECT_ID(@NewViewName, 'V') IS NOT NULL
BEGIN
    PRINT 'View ' + @NewViewName + ' created. Querying and dropping.';
    EXEC(N'SELECT TOP 3 * FROM ' + @NewViewName + N'; DROP VIEW ' + @NewViewName + N';');
END
GO

----------------------------------------------------------------------------------------------------
-- FINAL SCRIPT CLEANUP SECTION
----------------------------------------------------------------------------------------------------
PRINT 'Executing Final Cleanup Section...';
GO

-- Switch to NewTestDB context to drop database-level objects
USE NewTestDB;
GO

-- Drop DCL User (if exists)
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'TestUser')
BEGIN
    DROP USER TestUser;
    PRINT 'User TestUser dropped from NewTestDB.';
END
GO

-- Drop Tables (in reverse order of creation or dependency)
IF OBJECT_ID('dbo.TestAccounts', 'U') IS NOT NULL DROP TABLE dbo.TestAccounts; PRINT 'Table TestAccounts dropped.';
IF OBJECT_ID('dbo.Salaries', 'U') IS NOT NULL DROP TABLE dbo.Salaries; PRINT 'Table Salaries dropped.';
IF OBJECT_ID('dbo.SalaryAudit', 'U') IS NOT NULL DROP TABLE dbo.SalaryAudit; PRINT 'Table SalaryAudit dropped.';
-- Employees table might have FKs from itself (ManagerID) or other tables.
-- If trg_EmployeeSalaryUpdate exists and refers to SalaryAudit, it should be dropped before Employees or SalaryAudit.
IF OBJECT_ID('dbo.trg_EmployeeSalaryUpdate', 'TR') IS NOT NULL DROP TRIGGER dbo.trg_EmployeeSalaryUpdate; PRINT 'Trigger trg_EmployeeSalaryUpdate dropped.';
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees; PRINT 'Table Employees dropped.';
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments; PRINT 'Table Departments dropped.';
IF OBJECT_ID('dbo.Staging_Employees', 'U') IS NOT NULL DROP TABLE dbo.Staging_Employees; PRINT 'Table Staging_Employees dropped.';
GO

-- Drop Views
IF OBJECT_ID('dbo.V_EmployeeDetails', 'V') IS NOT NULL DROP VIEW dbo.V_EmployeeDetails; PRINT 'View V_EmployeeDetails dropped.';
-- V_HighEarnersDynamic is created and dropped within its example, but check just in case
IF OBJECT_ID('dbo.V_HighEarnersDynamic', 'V') IS NOT NULL DROP VIEW dbo.V_HighEarnersDynamic; PRINT 'View V_HighEarnersDynamic dropped.';
GO

-- Drop Procedures
IF OBJECT_ID('dbo.sp_GetEmployeesByDepartment', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetEmployeesByDepartment; PRINT 'Procedure sp_GetEmployeesByDepartment dropped.';
GO

-- Drop Functions
IF OBJECT_ID('dbo.fn_GetEmployeeFullName', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_GetEmployeeFullName; PRINT 'Function fn_GetEmployeeFullName dropped.';
GO

-- Switch to master database context to drop server-level objects (Login, Database)
USE master;
GO
PRINT 'Switched to master database context for LOGIN and DATABASE cleanup.';

-- Drop DCL Login (if exists)
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = N'TestUserLogin')
BEGIN
    DROP LOGIN TestUserLogin;
    PRINT 'Login TestUserLogin dropped from the server.';
END
GO

-- Drop Database (if exists)
IF DB_ID(N'NewTestDB') IS NOT NULL
BEGIN
    -- Set database to single user mode to ensure connections are closed before dropping
    ALTER DATABASE NewTestDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NewTestDB;
    PRINT 'Database NewTestDB dropped.';
END
ELSE
BEGIN
    PRINT 'Database NewTestDB does not exist or already dropped.';
END
GO

PRINT 'All examples and cleanup finished.';
GO
/***************************************************************************************************
End of MS SQL Server Complete Syntax Examples Script
***************************************************************************************************/
