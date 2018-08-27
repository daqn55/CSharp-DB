CREATE DATABASE ReportService
GO

--Problem 1

CREATE TABLE Users(
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	Username NVARCHAR(30) UNIQUE NOT NULL,
	[Password] NVARCHAR(50) NOT NULL,
	[Name] NVARCHAR(50),
	Gender CHAR NOT NULL CHECK(Gender IN('M', 'F')),
	BirthDate DATETIME,
	Age INT,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Departments(
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR NOT NULL CHECK(Gender IN('M', 'F')),
	BirthDate DATETIME,
	Age INT,
	DepartmentId INT NOT NULL

	CONSTRAINT FK_Employees_Department FOREIGN KEY (DepartmentId)
	REFERENCES Departments(Id)
)

CREATE TABLE Categories(
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	DepartmentId INT

	CONSTRAINT FK_Categories_Department FOREIGN KEY (DepartmentId)
	REFERENCES Departments(Id)
)

CREATE TABLE [Status](
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	Label VARCHAR(30) NOT NULL
)

CREATE TABLE Reports(
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	CategoryId INT NOT NULL,
	StatusId INT NOT NULL,
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	[Description] NVARCHAR(200),
	UserId INT NOT NULL,
	EmployeeId INT

	CONSTRAINT FK_Reports_Category FOREIGN KEY (CategoryId)
	REFERENCES Categories(Id),
	CONSTRAINT FK_Reports_Status FOREIGN KEY (StatusId)
	REFERENCES [Status](Id),
	CONSTRAINT FK_Reports_User FOREIGN KEY (UserId)
	REFERENCES Users(Id),
	CONSTRAINT FK_Reports_Employee FOREIGN KEY (EmployeeId)
	REFERENCES Employees(Id)
)

--Problem 2

INSERT INTO Employees (FirstName, LastName, Gender, BirthDate, DepartmentId)
VALUES
		('Marlo', 'O’Malley', 'M', '9/21/1958', 1),
		('Niki', 'Stanaghan', 'F', '11/26/1969', 4),
		('Ayrton', 'Senna', 'M', '03/21/1960', 9),
		('Ronnie', 'Peterson', 'M', '02/14/1944', 9),
		('Giovanna', 'Amati', 'F', '07/20/1959', 5)

INSERT INTO Reports(CategoryId, StatusId, OpenDate, CloseDate, Description, UserId, EmployeeId)
VALUES
		(1, 1, '04/13/2017', NULL, 'Stuck Road on Str.133', 6, 2),
		(6, 3, '09/05/2015', '12/06/2015', 'Charity trail running', 3, 5),
		(14, 2, '09/07/2015', NULL, 'Falling bricks on Str.58', 5, 2),
		(4, 3, '07/03/2017', '07/06/2017', 'Cut off streetlight on Str.11', 1, 1)


--Problem 3

UPDATE Reports
SET StatusId = 2 WHERE StatusId = 1

--Problem 4

DELETE FROM Reports WHERE StatusId = 4

--Problem 5

SELECT u.Username, u.Age
	FROM Users u
	ORDER BY u.Age, u.Username DESC

--Problem 6

SELECT R.Description, R.OpenDate
	FROM Reports r
	WHERE r.EmployeeId IS NULL
	ORDER BY r.OpenDate, r.Description

--Problem 7

SELECT e.FirstName, e.LastName, r.Description, CONVERT(VARCHAR(10), r.OpenDate, 120) AS OpenDate
	FROM Reports r 
	JOIN Employees e ON r.EmployeeId = e.Id
	WHERE r.EmployeeId IS NOT NULL
	ORDER BY e.Id, r.OpenDate, r.Id

--Problem 8

SELECT c.Name AS CategoryName, e.ReportsNumber
	FROM(
			SELECT COUNT(r.CategoryId) AS ReportsNumber, r.CategoryId
				FROM Reports r
				GROUP BY r.CategoryId) AS e
	JOIN Categories c ON e.CategoryId = c.Id
	ORDER BY e.ReportsNumber DESC, c.Name

--Problem 9

SELECT c.Name AS CategoryName, COUNT(e.Id) AS 'Employees Number'
	FROM Categories c
	JOIN Departments d ON c.DepartmentId = d.Id
	JOIN Employees e ON d.Id = e.DepartmentId
	GROUP BY c.Name
	ORDER BY c.Name

--Problem 10

SELECT CONCAT(e.FirstName, ' ', e.LastName) AS [Name], COUNT(r.UserId) AS 'Users Number'
	FROM Reports r
	RIGHT JOIN Employees e ON r.EmployeeId = e.Id
	GROUP BY CONCAT(e.FirstName, ' ', e.LastName)
	ORDER BY COUNT(r.UserId) DESC, CONCAT(e.FirstName, ' ', e.LastName)
	
--Problem 11

SELECT r.OpenDate, r.Description, u.Email AS 'Reporter Email'
	FROM Reports r
	JOIN Categories c ON r.CategoryId = c.Id
	JOIN Departments d ON c.DepartmentId = d.Id
	JOIN Users u ON r.UserId = u.Id
	WHERE r.CloseDate IS NULL AND
		  LEN(r.Description) > 20 AND
		  r.Description LIKE '%str%' AND
		  d.Name IN('Infrastructure', 'Emergency', 'Roads Maintenance')
	ORDER BY r.OpenDate, u.Email, r.Id

--Problem 12

SELECT DISTINCT c.Name AS 'Category Name'
	FROM Reports r
	JOIN Users u ON r.UserId = u.Id
	JOIN Categories c ON r.CategoryId = c.Id
	WHERE MONTH(r.OpenDate) = MONTH(u.BirthDate) AND
			DAY(r.OpenDate) = DAY(u.BirthDate)
	ORDER BY C.Name

--Problem 13

SELECT DISTINCT u.Username
	FROM Reports r
	JOIN Users u ON r.UserId = u.Id
	WHERE LEFT(u.Username, 1) LIKE '[0-9]' AND CONVERT(VARCHAR(100), r.CategoryId) = (LEFT(u.Username, 1)) OR
		  RIGHT(u.Username, 1) LIKE '[0-9]' AND CONVERT(VARCHAR(100), r.CategoryId) = (RIGHT(u.Username, 1))
	ORDER BY u.Username

--Problem 14

SELECT e.Name, CONCAT(SUM(e.Closed), '/', SUM(e.[Open])) AS 'Closed Open Reports'
	FROM(
			SELECT CONCAT(e.FirstName, ' ', e.LastName) AS [Name],
					CASE WHEN (r.CloseDate IS NULL OR YEAR(r.OpenDate) = 2016) AND YEAR(r.OpenDate) = 2016 THEN 1 ELSE 0 END AS [Open],
					CASE WHEN (YEAR(r.OpenDate) < 2016 OR YEAR(r.OpenDate) = 2016) AND YEAR(R.CloseDate) = 2016 THEN 1 ELSE 0 END AS Closed
				FROM Reports r
				JOIN Employees e ON r.EmployeeId = e.Id) AS e
		GROUP BY e.Name
		HAVING CONCAT(SUM(e.Closed), '/', SUM(e.[Open])) <> '0/0'
		ORDER BY e.Name

--Problem 15

SELECT d.Name AS 'Department Name', 
		CASE 
			WHEN AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate)) IS NULL THEN 'no info'
			ELSE CONVERT(VARCHAR(10), AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate)))
		END AS 'Average Duration'
	FROM Reports r
	JOIN Categories c ON r.CategoryId = c.Id
	JOIN Departments d ON c.DepartmentId = d.Id
	GROUP BY d.Name
	ORDER BY d.Name
GO

--Problem 16

SELECT *
	FROM Reports r
	JOIN Categories c ON r.CategoryId = c.Id
	JOIN Departments d ON c.DepartmentId = d.Id


go

--Problem 17

CREATE FUNCTION udf_GetReportsCount(@employeeId INT, @statusId INT)
RETURNS INT
AS
BEGIN
	DECLARE @reportCount INT

	SET @reportCount = (SELECT COUNT(*)
							FROM Reports r
							WHERE r.EmployeeId = @employeeId
							AND r.StatusId = @statusId)

	RETURN @reportCount
END

GO

SELECT Id, FirstName, Lastname, dbo.udf_GetReportsCount(Id, 2) AS ReportsCount
FROM Employees
ORDER BY Id
go

--Problem 18

CREATE PROC usp_AssignEmployeeToReport(@employeeId INT, @reportId INT)
AS
BEGIN
	DECLARE @employeeDepartment INT = (SELECT e.DepartmentId FROM Employees e WHERE e.Id = @employeeId)
	DECLARE @reportDepartment INT = (SELECT c.DepartmentId FROM Reports r JOIN Categories c ON r.CategoryId = c.Id WHERE r.Id = @reportId)

	BEGIN TRANSACTION
	UPDATE Reports
	SET EmployeeId = @employeeId
	WHERE Id = @reportId
		IF(@employeeDepartment <> @reportDepartment)
			BEGIN
				ROLLBACK
				RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1)
				RETURN
			END
	COMMIT
END

EXEC usp_AssignEmployeeToReport 17, 2;
SELECT EmployeeId FROM Reports WHERE id = 2

go

--Problem 19

CREATE TRIGGER tr_ChangeStatusCompleted ON Reports FOR UPDATE
AS
BEGIN
	UPDATE Reports
	SET StatusId = 3
	WHERE Id IN (SELECT Id FROM inserted) AND Reports.CloseDate IS NOT NULL
END

go
UPDATE Reports
SET CloseDate = GETDATE()
WHERE EmployeeId = 22;

go

--Problem 20




SELECT * FROM Users
SELECT * FROM Categories
SELECT * FROM Status
SELECT * FROM Employees
SELECT * FROM Departments
SELECT * FROM Reports