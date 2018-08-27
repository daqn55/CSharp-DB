--Problem 1

CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
	SELECT e.FirstName, e.LastName
		FROM Employees e
		WHERE e.Salary > 35000
GO
EXEC usp_GetEmployeesSalaryAbove35000
GO
--Problem 2

CREATE PROC usp_GetEmployeesSalaryAboveNumber(@salary DECIMAL(18,4))
AS
	SELECT e.FirstName, e.LastName
		FROM Employees e
		WHERE e.Salary >= @salary

EXEC usp_GetEmployeesSalaryAboveNumber 48100

GO

--Problem 3

CREATE PROC usp_GetTownsStartingWith(@startingLeter VARCHAR(50))
AS
	SELECT t.Name AS Town
			FROM Towns t
			WHERE t.Name LIKE @startingLeter + '%'

EXEC usp_GetTownsStartingWith b
go
--Problem 4

CREATE PROC usp_GetEmployeesFromTown(@townName VARCHAR(50))
AS
	SELECT e.FirstName, e.LastName
			FROM Employees e
			JOIN Addresses a
			ON e.AddressID = a.AddressID
			JOIN Towns t
			ON a.TownID = t.TownID
			WHERE t.Name = @townName

EXEC usp_GetEmployeesFromTown Sofia
go

--Problem 5

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
RETURNS VARCHAR(10)
AS
	BEGIN
	DECLARE @SalaryLevel VARCHAR(10)
	IF (@salary < 30000)
		BEGIN
			SET @SalaryLevel = 'Low'
		END
	ELSE IF(@salary >= 30000 AND @salary <= 50000)
		BEGIN
			SET @SalaryLevel = 'Average'
		END
	ELSE 
		SET @SalaryLevel = 'High'

	RETURN @SalaryLevel	
	END
go

SELECT e.Salary, [dbo].ufn_GetSalaryLevel(e.Salary) AS 'Salary level'
		FROM Employees e
go
--Problem 6

CREATE PROC usp_EmployeesBySalaryLevel(@levelOfSalary VARCHAR(10))
AS
	SELECT e.FirstName, e.LastName
		FROM Employees e
		WHERE [dbo].ufn_GetSalaryLevel(e.Salary) = @levelOfSalary

go

EXEC usp_EmployeesBySalaryLevel 'High'
GO

--Problem 7

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(255), @word NVARCHAR(255))
RETURNS BIT
AS
BEGIN
	DECLARE @isComprised BIT = 0;

	DECLARE @cnt INT = 0;
	DECLARE @words INT = 0;

	WHILE @cnt <= LEN(@setOfLetters)
	BEGIN
	   
	   DECLARE @index CHAR = SUBSTRING(@setOfLetters, @cnt, 1)
	   
	   IF(CHARINDEX(@index, @word) <> 0)
	   BEGIN
			SET @words += 1
	   END

	   IF(@words = LEN(@word))
		  BEGIN
			SET @isComprised = 1;
			BREAK
		  END

	   SET @cnt += 1;
	END;


	RETURN @isComprised
END

GO

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')
GO

--Problem 8

CREATE OR ALTER PROC usp_DeleteEmployeesFromDepartment(@departmentId INT)
AS
  BEGIN
	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT

	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (
							SELECT e.EmployeeID
							FROM Employees e
							WHERE e.DepartmentID = @departmentId
						)

	UPDATE Employees
	SET ManagerID = NULL
	WHERE ManagerID IN (
							SELECT e.EmployeeID
							FROM Employees e
							WHERE e.DepartmentID = @departmentId
						)

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN (
							SELECT e.EmployeeID
							FROM Employees e
							WHERE e.DepartmentID = @departmentId
						)

	DELETE FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE FROM Departments
	WHERE DepartmentID = @departmentId

	SELECT COUNT(*)
	FROM Employees e
	WHERE e.DepartmentID = @departmentId
  END

EXEC usp_DeleteEmployeesFromDepartment 8
GO

--Problem 9

CREATE PROC usp_GetHoldersFullName
AS
	SELECT ah.FirstName + ' ' + ah.LastName AS FullName 
		FROM AccountHolders ah

GO
--Problem 10

CREATE PROC usp_GetHoldersWithBalanceHigherThan(@money MONEY)
AS
	SELECT ah.FirstName, ah.LastName
			FROM Accounts a
			JOIN AccountHolders ah
			ON a.AccountHolderId = ah.Id
			GROUP BY ah.FirstName, ah.LastName
			HAVING SUM(a.Balance) >= @money

GO
--Problem 11

CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(15,2), @yearlyInterestRate FLOAT, @year INT)
RETURNS DECIMAL(15, 4)
AS
BEGIN
	DECLARE @value DECIMAL(15, 4)
	DECLARE @t FLOAT = POWER((1 + @yearlyInterestRate), @year)
	SET @value = @sum * @t

	RETURN @value
END

go

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)
GO


--Problem 12

CREATE PROC usp_CalculateFutureValueForAccount(@accountID INT, @interestRate FLOAT)
AS
	SELECT a.AccountHolderId, 
		   ah.FirstName, 
		   ah.LastName, 
		   a.Balance AS 'Current Balance',
		   dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS 'Balance in 5 years'
			FROM Accounts a
			JOIN AccountHolders ah
			ON a.AccountHolderId = ah.Id
			WHERE a.Id = @accountID

GO
--Problem 13

CREATE FUNCTION ufn_CashInUsersGames(@gameName VARCHAR(50))
RETURNS TABLE
AS
RETURN(
	SELECT SUM(e.Cash) AS SumCash
		FROM(
					SELECT ug.Cash, ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS [RowNumber]
						FROM Games g
						JOIN UsersGames ug
						ON g.Id = ug.GameId
							WHERE Name = @gameName) AS e
		WHERE e.RowNumber % 2 = 1
)

GO
select * from dbo.ufn_CashInUsersGames ('Love in a mist')

go

--Problem 14

CREATE TABLE Logs(
	LogId INT IDENTITY PRIMARY KEY NOT NULL,
	AccountId INT NOT NULL,
	OldSum DECIMAL(15, 2) NOT NULL,
	NewSum DECIMAL(15, 2) NOT NULL
)
go

CREATE TRIGGER tr_Accounts
ON Accounts
FOR UPDATE
AS
BEGIN
	DECLARE @AccountId INT = (SELECT Id FROM inserted)
	DECLARE @OldSum DECIMAL(15, 2) = (SELECT Balance FROM deleted)
	DECLARE @NewSum DECIMAL(15, 2) = (SELECT Balance FROM inserted)

	INSERT INTO Logs
	VALUES(@AccountId, @OldSum, @NewSum)
END

UPDATE Accounts
SET Balance = 123.12 WHERE Id = 1

select * from Logs

--Problem 15

CREATE TABLE NotificationEmails(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Recipient INT NOT NULL,
	[Subject] NVARCHAR(255),
	Body NVARCHAR(255) 
)

go

CREATE TRIGGER tr_NotificationEmails
ON Logs
FOR INSERT
AS
BEGIN
	DECLARE @AccountId INT = (SELECT AccountId FROM inserted)
	DECLARE @OldSum DECIMAL(15, 2) = (SELECT OldSum FROM inserted)
	DECLARE @NewSum DECIMAL(15, 2) = (SELECT NewSum FROM inserted)

	DECLARE @subject NVARCHAR(255) = 'Balance change for account: ' +  CONVERT(NVARCHAR(255), @AccountId)
	DECLARE @body NVARCHAR(255) = 'On ' + CONVERT(NVARCHAR(255), GETDATE()) + ' your balance was changed from ' + CONVERT(NVARCHAR(255), @OldSum) + ' to ' + CONVERT(NVARCHAR(255), @NewSum)

	INSERT INTO NotificationEmails
	VALUES (@AccountId, @subject, @body)
END

select * from NotificationEmails

GO
--Problem 16

CREATE PROC usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN
	IF(@MoneyAmount > 0)
	BEGIN
		UPDATE Accounts
		SET Balance += @MoneyAmount WHERE @AccountId = Id
	END
END

select * from Accounts
EXEC usp_DepositMoney 1, 10

go
--Problem 17

CREATE PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN
	DECLARE @AmountInAccount DECIMAL(15, 4) = (SELECT Balance FROM Accounts WHERE Id = @AccountId)
	IF(@MoneyAmount > 0)
	BEGIN
		IF(@AmountInAccount >= @MoneyAmount)
		BEGIN
			UPDATE Accounts
			SET Balance -= @MoneyAmount WHERE @AccountId = Id
		END
	END
END

GO

--Probelm 18