--Problem 1

SELECT TOP 5 e.EmployeeID, e.JobTitle, a.AddressId, a.AddressText
		FROM Employees e
		JOIN Addresses a
		ON e.AddressID = a.AddressID
	ORDER BY a.AddressID

--Problem 2

SELECT TOP 50 e.FirstName, e.LastName, t.Name AS 'Town', a.AddressText 
		FROM Employees e
		JOIN Addresses a
		ON e.AddressID = a.AddressID
		JOIN Towns t
		ON a.TownID = t.TownID
	ORDER BY e.FirstName, e.LastName

--Problem 3

SELECT e.EmployeeID, e.FirstName, e.LastName, d.Name AS 'DepartmentName'
		FROM Employees e
		JOIN Departments d
		ON e.DepartmentID = d.DepartmentID
		WHERE d.Name = 'Sales'
		ORDER BY e.EmployeeID

--Problem 4

SELECT TOP 5 e.EmployeeID, e.FirstName, e.Salary, d.Name AS 'DepartmentName'
		FROM Employees e
		JOIN Departments d
		ON e.DepartmentID = d.DepartmentID
		WHERE e.Salary > 15000
		ORDER BY e.DepartmentID

--Problem 5

SELECT TOP 3 e.EmployeeID, e.FirstName
		FROM Employees e
		LEFT JOIN EmployeesProjects ep
		ON e.EmployeeID = ep.EmployeeID
		WHERE ep.ProjectID IS NULL
		ORDER BY e.EmployeeID

--Problem 6

SELECT e.FirstName, e.LastName, e.HireDate, d.Name AS 'DeptName'
		FROM Employees e
		JOIN Departments d
		ON e.DepartmentID = d.DepartmentID
		WHERE e.HireDate >= '1999/01/01' 
			AND d.Name IN ('Sales', 'Finance')
		ORDER BY e.HireDate

--Problem 7

SELECT TOP 5 e.EmployeeID, e.FirstName, p.Name AS 'ProjectName'
		FROM Employees e
		JOIN EmployeesProjects ep
		ON e.EmployeeID = ep.EmployeeID
		JOIN Projects p
		ON ep.ProjectID = p.ProjectID
		WHERE p.StartDate > '2002/08/13'
			AND p.EndDate IS NULL
		ORDER BY e.EmployeeID

--Problem 8

SELECT e.EmployeeID, e.FirstName,
	CASE
		WHEN p.StartDate >= '2005/01/01' THEN NULL
		ELSE p.Name
	END AS 'ProjectName'
		FROM Employees e
		JOIN EmployeesProjects ep
		ON e.EmployeeID = ep.EmployeeID
		JOIN Projects p
		ON ep.ProjectID = p.ProjectID
		WHERE e.EmployeeID = 24

--Problem 9

SELECT m.EmployeeID, m.FirstName, m.ManagerID, e.FirstName AS 'ManagerName'
		FROM Employees e
		JOIN Employees m
		ON e.EmployeeID = m.ManagerID
		WHERE m.ManagerID IN(3, 7)
		ORDER BY m.EmployeeID

--Problem 10

SELECT TOP 50 m.EmployeeID, m.FirstName + ' ' + m.LastName AS 'EmployeeName', e.FirstName + ' ' + e.LastName AS 'ManagerName', d.Name AS 'DepartmentName'
		FROM Employees e
		JOIN Employees m
		ON e.EmployeeID = m.ManagerID
		JOIN Departments d
		ON m.DepartmentID = d.DepartmentID
		ORDER BY m.EmployeeID

--Problem 11

SELECT TOP 1 AVG(e.Salary) AS 'MinAverageSalary'
		FROM Employees e
		GROUP BY e.DepartmentID
		ORDER BY AVG(e.Salary)

--Problem 12

SELECT mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation
		FROM MountainsCountries	mc
		JOIN Mountains m
		ON mc.MountainId = m.Id
		JOIN Peaks p
		ON m.Id = p.MountainId
		WHERE mc.CountryCode = 'BG'
			AND p.Elevation > 2835
		ORDER BY p.Elevation DESC

--Problem 13

SELECT mc.CountryCode, COUNT(mc.CountryCode)
		FROM MountainsCountries mc
		JOIN Mountains m
		ON mc.MountainId = m.Id
		WHERE mc.CountryCode IN ('US', 'RU', 'BG')
		GROUP BY mc.CountryCode
		
--Problem 14

SELECT TOP 5 c.CountryName, r.RiverName
		FROM Countries c
		LEFT JOIN CountriesRivers cr
		ON c.CountryCode = cr.CountryCode
		LEFT JOIN Rivers r
		ON cr.RiverId = r.Id
		WHERE c.ContinentCode = 'AF'
		ORDER BY c.CountryName

--Problem 15

SELECT x.ContinentCode, x.CurrencyCode, x.CurrencyUsage
		FROM (
SELECT c.ContinentCode, c.CurrencyCode, COUNT(c.CurrencyCode) AS CurrencyUsage, DENSE_RANK() OVER(PARTITION BY c.ContinentCode ORDER BY COUNT(c.CurrencyCode) DESC) AS [Rank]
		FROM Countries c
		GROUP BY c.CurrencyCode, c.ContinentCode
		HAVING COUNT(c.CurrencyCode) > 1
) AS x
	  WHERE x.Rank = 1
	  ORDER BY x.ContinentCode

--Problem 16

select * from Peaks
select * from Countries
select * from MountainsCountries

SELECT COUNT(c.CountryCode) AS 'CountryCode'
		FROM Countries c
		LEFT JOIN MountainsCountries mc
		ON c.CountryCode = mc.CountryCode
		WHERE mc.MountainId IS NULL

--Problem 17

SELECT TOP 5 c.CountryName, MAX(p.Elevation) AS 'HighestPeakElevation', MAX(r.Length) AS 'LongestRiverLength'
		FROM Countries c
		LEFT JOIN MountainsCountries mc
		ON c.CountryCode = mc.CountryCode
		LEFT JOIN Mountains m
		ON mc.MountainId = m.Id
		LEFT JOIN Peaks p
		ON m.Id = p.MountainId
		LEFT JOIN CountriesRivers cr
		ON c.CountryCode = cr.CountryCode
		LEFT JOIN Rivers r
		ON cr.RiverId = r.Id
		GROUP BY c.CountryName
		Order by MAX(p.Elevation) desc, MAX(r.Length) desc 
		

--Problem 18

SELECT TOP 5 c.CountryName, 
	CASE 
		WHEN p.PeakName IS NULL THEN '(no highest peak)' 
		ELSE p.PeakName
	END AS 'Highest Peak Name',
	CASE 
		WHEN MAX(p.Elevation) IS NULL THEN 0
		ELSE MAX(p.Elevation)
	END AS 'Highest Peak Elevation',
	CASE
		WHEN m.MountainRange IS NULL THEN '(no mountain)'
		ELSE m.MountainRange
	END AS 'Mountain'
		FROM Countries c
		LEFT JOIN MountainsCountries mc
		ON c.CountryCode = mc.CountryCode
		LEFT JOIN Mountains m
		ON mc.MountainId = m.Id
		LEFT JOIN Peaks p
		ON m.Id = p.MountainId
		GROUP BY c.CountryName, p.PeakName, m.MountainRange
		ORDER BY c.CountryName, p.PeakName