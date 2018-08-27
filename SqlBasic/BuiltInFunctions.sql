--Problem 1

SELECT FirstName, LastName
	FROM Employees
		WHERE FirstName LIKE 'SA%'

--Problem 2

SELECT FirstName, LastName
	FROM Employees
		WHERE LastName LIKE '%ei%'

--Problem 3

SELECT FirstName
	FROM Employees
		WHERE DepartmentID IN(3, 10)
	    AND	HireDate BETWEEN '1995-01-01' AND '2005-12-31'

--Problem 4

SELECT FirstName, LastName
	FROM Employees
		WHERE JobTitle NOT LIKE '%engineer%'

--Problem 5

SELECT Name
	FROM Towns
		WHERE LEN(Name) BETWEEN 5 AND 6
		ORDER BY Name

--Problem 6

SELECT TownID, Name
	FROM Towns
		WHERE Name LIKE 'M%' OR Name LIKE 'K%'
			OR Name LIKE 'B%' OR Name LIKE 'E%'
		ORDER BY Name

--Peoblem 7

SELECT TownID, Name
	FROM Towns
		WHERE Name NOT LIKE 'R%' AND Name NOT LIKE 'D%'
			AND Name NOT LIKE 'B%'
		ORDER BY Name
GO
--Problem 8

CREATE VIEW V_EmployeesHiredAfter2000 AS
	SELECT FirstName, LastName
		FROM Employees
			WHERE HireDate >= '2001-01-01'
GO
--Problem 9

SELECT FirstName, LastName
	FROM Employees
		WHERE LEN(LastName) = 5

--Problem 10

SELECT CountryName, IsoCode
	FROM Countries
		WHERE CountryName LIKE '%a%a%a%'
		ORDER BY IsoCode

--Problem 11

SELECT Peaks.PeakName, Rivers.RiverName, LOWER(LEFT(Peaks.PeakName, LEN(Peaks.PeakName)-1) + Rivers.RiverName) AS Mix
	FROM Peaks
	INNER JOIN Rivers ON RIGHT(Peaks.PeakName, 1) = LEFT(Rivers.RiverName, 1)
	ORDER BY Mix

--Problem 12

SELECT TOP 50 [Name], FORMAT([Start], 'yyyy-MM-dd') AS [Start]
	FROM Games
	WHERE [Start] >= '2011-01-01' AND [Start] <= '2012-12-31'
	ORDER BY [Start], [Name]

--Problem 13

SELECT Username, RIGHT(Email, LEN(Email) - CHARINDEX('@', Email)) AS 'Email Provider'
	FROM Users
	ORDER BY 'Email Provider', Username

--Problem 14

SELECT Username, IpAddress
	FROM Users
	WHERE IpAddress LIKE '[1-9]_%_%.1%.%.[1-9]_%_%'
	ORDER BY Username

--Problem 15

SELECT [Name] AS Game,
		CASE 
			WHEN (DATEPART(hour, [Start]) >= 0 AND DATEPART(hour, [Start]) < 12) THEN 'Morning'
			WHEN (DATEPART(hour, [Start]) >= 12 AND DATEPART(hour, [Start]) < 18) THEN 'Afternoon'
			WHEN (DATEPART(hour, [Start]) >= 18 AND DATEPART(hour, [Start]) < 24) THEN 'Evening'
		END AS 'Part of the Day',
		CASE
			WHEN Duration <= 3 THEN 'Extra Short'
			WHEN Duration > 3 AND Duration <= 6 THEN 'Short'
			WHEN Duration > 6 THEN 'Long'
			WHEN Duration IS NULL THEN 'Extra Long'
		END AS 'Duration'
	FROM Games
		ORDER BY [Name], 'Duration', 'Part of the Day'

--Problem 16

SELECT ProductName, OrderDate, DATEADD(day, 3, OrderDate) AS 'Pay Due', DATEADD(month, 1, OrderDate) AS 'Deliver Due'
	FROM Orders