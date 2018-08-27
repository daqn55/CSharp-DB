--Problem 1

SELECT MAX(Id) AS [Count]
	FROM WizzardDeposits

--Problem 2

SELECT MAX(MagicWandSize) AS 'LongestMagicWand'
	FROM WizzardDeposits

--Problem 3

SELECT w.DepositGroup, MAX(w.MagicWandSize) AS 'LongestMagicWand'
	FROM WizzardDeposits AS w
	GROUP BY w.DepositGroup

--Problem 4

SELECT TOP 2 w.DepositGroup
	FROM WizzardDeposits AS w
	GROUP BY w.DepositGroup
	ORDER BY AVG(w.MagicWandSize)

--Problem 5

SELECT w.DepositGroup, SUM(w.DepositAmount) AS 'TotalSum'
	FROM WizzardDeposits AS w
	GROUP BY w.DepositGroup

--Problem 6

SELECT w.DepositGroup, SUM(w.DepositAmount) AS 'TotalSum'
	FROM WizzardDeposits AS w
	GROUP BY w.DepositGroup, w.MagicWandCreator
	HAVING w.MagicWandCreator = 'Ollivander Family'
	
--Problem 7

SELECT w.DepositGroup, SUM(w.DepositAmount) AS TotalSum
	FROM WizzardDeposits AS w
	GROUP BY w.DepositGroup, w.MagicWandCreator
	HAVING w.MagicWandCreator = 'Ollivander Family' AND SUM(w.DepositAmount) < 150000
	ORDER BY TotalSum DESC

--Problem 8

SELECT w.DepositGroup, w.MagicWandCreator, MIN(w.DepositCharge) AS MinDepositCharge
	FROM WizzardDeposits AS w
	GROUP BY w.DepositGroup, w.MagicWandCreator
	ORDER BY w.MagicWandCreator, w.DepositGroup

--Problem 9

SELECT CASE
			WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
			WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
			WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
			WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
			WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
			WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
			ELSE '[61+]'
		END AS AgeGroup, COUNT(Age) AS WizardCount
	FROM WizzardDeposits
	GROUP BY CASE
				WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
				WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
				WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
				WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
				WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
				WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
				ELSE '[61+]'
			END

--Problem 10

SELECT LEFT(w.FirstName, 1) AS FirstLetter
	FROM WizzardDeposits AS w
	GROUP BY LEFT(w.FirstName, 1), w.DepositGroup
	HAVING w.DepositGroup = 'Troll Chest'

--Problem 11

SELECT w.DepositGroup, w.IsDepositExpired, AVG(w.DepositInterest) AS AverageInterest
	FROM WizzardDeposits AS w
	WHERE w.DepositStartDate >= '1985-01-01'
	GROUP BY w.DepositGroup, w.IsDepositExpired
	ORDER BY w.DepositGroup DESC, w.IsDepositExpired

--Problem 12
SELECT SUM(e.Diff) AS SumDiffrence FROM(
SELECT w.DepositAmount - LEAD(w.DepositAmount) OVER (ORDER BY w.Id) AS Diff
	FROM WizzardDeposits AS w
	) AS e


--Problem 13

SELECT e.DepartmentID, SUM(e.Salary) AS TotalSalary
	FROM Employees AS e
	GROUP BY e.DepartmentID
	ORDER BY e.DepartmentID

--Problem 14

SELECT e.DepartmentID, MIN(e.Salary) AS MinimumSalary
	FROM Employees AS e
	WHERE e.DepartmentID IN (2, 5, 7) AND e.HireDate >= '2000-01-01'
	GROUP BY e.DepartmentID

--Problem 15

UPDATE Employees
SET Salary = Salary + 5000
WHERE DepartmentID = 1
DELETE Employees
WHERE ManagerID = 42

SELECT e.DepartmentID, AVG(Salary) AS AverageSalary
	FROM Employees AS e
	WHERE e.Salary > 30000
	GROUP BY e.DepartmentID

--Problem 16

SELECT * FROM(
SELECT e.DepartmentID, MAX(Salary) AS MaxSalary
	FROM Employees AS e
	GROUP BY e.DepartmentID
	) AS s
	WHERE s.MaxSalary < 30000 OR s.MaxSalary > 70000


--Problem 17

SELECT COUNT(*) AS Count FROM(
SELECT e.ManagerID
	FROM Employees AS e
	WHERE e.ManagerID IS NULL
	) AS s

--Problem 18

SELECT s.DepartmentID, s.Salary AS ThirdHighestSalary FROM(
SELECT e.DepartmentID, e.Salary, DENSE_RANK() OVER (PARTITION BY e.DepartmentID ORDER BY e.Salary DESC) AS r
	FROM Employees AS e
	) as s
	WHERE s.r = 3
	GROUP BY s.DepartmentID, s.Salary

--Problem 19

SELECT TOP 10  e.FirstName, e.LastName, e.DepartmentID 
	FROM Employees AS e
	WHERE e.Salary > (SELECT AVG(Salary) FROM Employees WHERE DepartmentID = e.DepartmentID)
	ORDER BY e.DepartmentID

SELECT * FROM Employees