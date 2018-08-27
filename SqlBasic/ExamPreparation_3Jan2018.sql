--Problem 1

CREATE TABLE Clients(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Gender CHAR NOT NULL CHECK (Gender IN('M', 'F')),
	BirthDate DATETIME,
	CreditCard NVARCHAR(30) NOT NULL,
	CardValidity DATETIME,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Offices(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(40),
	ParkingPlaces INT,
	TownId INT NOT NULL

	CONSTRAINT FK_Town_Offices FOREIGN KEY(TownId)
	REFERENCES Towns(Id)
)

CREATE TABLE Models(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Manufacturer NVARCHAR(50) NOT NULL,
	Model NVARCHAR(50) NOT NULL,
	ProductionYear DATETIME,
	Seats INT,
	Class NVARCHAR(10),
	Consumption DECIMAL(14, 2)
)

CREATE TABLE Vehicles(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	ModelId INT NOT NULL,
	OfficeId INT NOT NULL,
	Mileage INT

	CONSTRAINT FK_Model_Vehicles FOREIGN KEY (ModelId)
	REFERENCES Models(Id),
	CONSTRAINT FK_Office_Vehicle FOREIGN KEY (OfficeId)
	REFERENCES Offices(Id)
)

CREATE TABLE Orders(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	ClientId INT NOT NULL,
	TownId INT NOT NULL,
	VehicleId INT NOT NULL,
	CollectionDate DATETIME NOT NULL,
	CollectionOfficeId INT NOT NULL,
	ReturnDate DATETIME,
	ReturnOfficeId INT,
	Bill DECIMAL(14, 2),
	TotalMileage INT

	CONSTRAINT FK_Client_Orders FOREIGN KEY (ClientId)
	REFERENCES Clients(Id),
	CONSTRAINT FK_Town_Orders FOREIGN KEY (TownId)
	REFERENCES Towns(Id),
	CONSTRAINT FK_Vehicle_Orders FOREIGN KEY (VehicleId)
	REFERENCES Vehicles(Id),
	CONSTRAINT FK_CollectionOffice_Orders FOREIGN KEY (CollectionOfficeId)
	REFERENCES Offices(Id),
	CONSTRAINT FK_ReturnOffice_Orders FOREIGN KEY (ReturnOfficeId)
	REFERENCES Offices(Id)
)


--Problem 2

INSERT INTO Models
VALUES
		('Chevrolet', 'Astro', '2005-07-27 00:00:00.000', 4, 'Economy', 12.60),
		('Toyota', 'Solara', '2009-10-15 00:00:00.000', 7, 'Family', 13.80),
		('Volvo', 'S40', '2010-10-12 00:00:00.000', 3, 'Average', 11.30),
		('Suzuki', 'Swift', '2000-02-03 00:00:00.000', 7, 'Economy', 16.20)

INSERT INTO Orders
VALUES
		(17, 2, 52, '2017-08-08', 30, '2017-09-04', 42, 2360.00, 7434),
		(78, 17, 50, '2017-04-22', 10, '2017-05-09', 12, 2326.00, 7326),
		(27, 13, 28, '2017-04-25', 21, '2017-05-09', 34, 597.00, 1880)


--Problem 3

UPDATE Models
SET Class = 'Luxury'
WHERE Consumption > 20

--Problem 4

DELETE FROM Orders
WHERE ReturnDate IS NULL

--Problem 5

SELECT m.Manufacturer, m.Model
	FROM Models m
	ORDER BY m.Manufacturer, m.Id DESC

--Problem 6

SELECT c.FirstName, c.LastName
		FROM Clients c
		WHERE YEAR(c.BirthDate) >= 1977 AND YEAR(c.BirthDate) <= 1994
		ORDER BY c.FirstName, c.LastName, c.Id 

--Problem 7

SELECT t.Name AS 'TownName', o.Name AS 'OfficeName', o.ParkingPlaces
	FROM Offices o
	JOIN Towns t ON o.TownId = t.Id
	WHERE o.ParkingPlaces > 25
	ORDER BY t.Name, o.Id
	
--Problem 8

SELECT m.Model, m.Seats, v.Mileage
	FROM Vehicles v
	JOIN Models m ON v.ModelId = m.Id
	WHERE v.Id != ALL(SELECT o.VehicleId FROM Orders o WHERE o.ReturnDate IS NULL) 
	ORDER BY v.Mileage, m.Seats DESC, v.ModelId

--Problem 9

SELECT t.Name AS TownName, e.NumOffices AS OfficesNumber
		FROM(
				SELECT COUNT(o.TownId) AS NumOffices, o.TownId
					FROM Towns t
					JOIN Offices o ON t.Id = o.TownId
					GROUP BY o.TownId ) AS e
		JOIN Towns t ON e.TownId = t.Id
		ORDER BY e.NumOffices DESC, t.Name


--Problem 10

SELECT m.Manufacturer, 
	   m.Model, 
	   CASE 
			WHEN e.CountModels IS NULL THEN 0
			ELSE e.CountModels
	   END AS TimesOrdered
	FROM(
			SELECT COUNT(v.ModelId) AS CountModels, v.ModelId
				FROM Orders o
				JOIN Vehicles v ON o.VehicleId = v.Id
				GROUP BY v.ModelId) AS e
	RIGHT JOIN Models m ON e.ModelId = m.Id
	ORDER BY e.CountModels DESC, m.Manufacturer DESC, m.Model

--Problem 11

SELECT e.Names, e.Class
	FROM(
			SELECT c.FirstName + ' ' + c.LastName AS Names, m.Class, RANK() OVER(PARTITION BY c.FirstName + ' ' + c.LastName ORDER BY COUNT(m.Class) DESC) AS Rank
				FROM Orders o 
				JOIN Clients c ON o.ClientId = c.Id
				JOIN Vehicles v ON o.VehicleId = v.Id
				JOIN Models m ON v.ModelId = m.Id
				GROUP BY c.FirstName + ' ' + c.LastName, m.Class) AS e
	WHERE e.Rank = 1
	ORDER BY e.Names, e.Class

--Problem 12

SELECT e.AgeGroup, SUM(e.Bill) AS Revenue, AVG(e.TotalMileage) AS AverageMileage
	FROM(
			SELECT CASE
						WHEN YEAR(c.BirthDate) >= 1970 AND YEAR(c.BirthDate) <= 1979 THEN '70''s'
						WHEN YEAR(c.BirthDate) >= 1980 AND YEAR(c.BirthDate) <= 1989 THEN '80''s'
						WHEN YEAR(c.BirthDate) >= 1990 AND YEAR(c.BirthDate) <= 1999 THEN '90''s'
						ELSE 'Others'
					END AS AgeGroup,
					o.Bill,
					o.TotalMileage
				FROM Clients c
				JOIN Orders o ON c.Id = o.ClientId) AS e
	GROUP BY e.AgeGroup


--Problem 13

SELECT TOP 3 e.Manufacturer, e.AverageConsumption
	FROM(
			SELECT SUM(e.CountVehicleId) AS MostOrdered, m.Manufacturer, AVG(m.Consumption) AS AverageConsumption
				FROM(
						SELECT COUNT(o.VehicleId) AS CountVehicleId, o.VehicleId
							FROM Orders o 
							GROUP BY o.VehicleId) AS e
				JOIN Vehicles v ON e.VehicleId = v.Id
				JOIN Models m ON v.ModelId = m.Id
				GROUP BY m.Model, m.Manufacturer) AS e
	WHERE e.AverageConsumption >= 5 AND e.AverageConsumption <= 15
	ORDER BY e.MostOrdered DESC, e.Manufacturer, e.AverageConsumption

--Problem 14

SELECT e.[Category Name], e.Email, e.Bill, e.Town
	FROM(
			SELECT c.FirstName + ' ' + c.LastName AS 'Category Name', c.Email, e.Bill, e.Town, ROW_NUMBER() OVER(PARTITION BY e.Town ORDER BY e.Bill DESC) AS Row
				FROM(
						SELECT c.Id, SUM(o.Bill) AS Bill, t.Name AS Town
							FROM Orders o
							JOIN Clients c ON o.ClientId = c.Id
							JOIN Towns t ON o.TownId = t.Id
							WHERE o.CollectionDate > c.CardValidity
							GROUP BY c.Id, t.Name) AS e
				JOIN Clients c ON e.Id = c.Id
				WHERE e.Bill IS NOT NULL) AS e
	WHERE e.Row = 1 OR e.Row = 2
	ORDER BY e.Town, e.Bill

--Problem 15

SELECT t.Name AS TownName,
		(SUM(e.M)* 100) / (ISNULL(SUM(e.M), 0) + ISNULL(SUM(e.F), 0)) AS MalePercent,
		(SUM(e.F)* 100) / (ISNULL(SUM(e.M), 0) + ISNULL(SUM(e.F), 0)) AS FemalePercent
	FROM(
			SELECT o.TownId, 
					CASE WHEN c.Gender = 'M' THEN COUNT(o.Id) ELSE NULL END AS M,
					CASE WHEN c.Gender = 'F' THEN COUNT(o.Id) ELSE NULL END AS F
				FROM Orders o
				JOIN Clients c ON o.ClientId = c.Id
				GROUP BY c.Gender, o.TownId) AS e
	JOIN Towns t ON e.TownId = t.Id
	GROUP BY t.Name

GO

--Problem 16

SELECT CONCAT(m.Manufacturer, ' - ', m.Model),
		CASE
			WHEN e.CollectionOfficeId IS NULL THEN 'home'
			WHEN e.ReturnOfficeId IS NULL AND e.CollectionOfficeId IS NOT NULL THEN 'on a rent'
			WHEN e.ReturnOfficeId <> e.OfficeId THEN CONCAT(t.Name, ' - ', o.Name)
		END
	FROM(
			SELECT DENSE_RANK() OVER(PARTITION BY v.Id ORDER BY o.CollectionDate DESC) AS Rank,
					o.ReturnOfficeId, v.OfficeId, v.ModelId, o.CollectionOfficeId, v.Id
				FROM Orders o
				RIGHT JOIN Vehicles v ON o.VehicleId = v.Id) AS e
	JOIN Models m ON e.ModelId = m.Id
	LEFT JOIN Offices o ON e.ReturnOfficeId = o.Id
	LEFT JOIN Towns t ON o.TownId = t.Id
	WHERE e.Rank = 1
	ORDER BY CONCAT(m.Manufacturer, ' - ', m.Model), e.Id



select * from Models
select * from Clients
select * from Vehicles order by officeid DESC
select * from Orders
select * from Offices
SELECT * FROM Towns
go
--Problem 17 

CREATE FUNCTION udf_CheckForVehicle(@townName NVARCHAR(50), @seatsNumber INT)
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE @haveOfficeName NVARCHAR(50) = (SELECT TOP 1 o.Name AS OfficeName
											FROM Vehicles v
											JOIN Offices o ON v.OfficeId = o.Id
											JOIN Towns t ON o.TownId = t.Id
											JOIN Models m ON v.ModelId = m.Id
											WHERE t.Name = @townName AND m.Seats = @seatsNumber
											ORDER BY o.Name)

	DECLARE @result NVARCHAR(50)

	IF(@haveOfficeName IS NOT NULL)
	BEGIN
		DECLARE @model NVARCHAR(50) = (SELECT TOP 1 m.Model
											FROM Vehicles v
											JOIN Offices o ON v.OfficeId = o.Id
											JOIN Towns t ON o.TownId = t.Id
											JOIN Models m ON v.ModelId = m.Id
											WHERE t.Name = @townName AND m.Seats = @seatsNumber
											ORDER BY o.Name)
		SET @result = @haveOfficeName + ' - ' + @model
	END
	ELSE 
	BEGIN 
		SET @result = 'NO SUCH VEHICLE FOUND'
	END

	RETURN @result
END

GO

--Problem 18

CREATE PROC usp_MoveVehicle(@vehicleId INT, @officeId INT)
AS
BEGIN 
BEGIN TRANSACTION
	UPDATE Vehicles 
	SET OfficeId = @officeId WHERE Id = @vehicleId
	DECLARE @countInOfficeCars INT = (SELECT COUNT(o.Id) AS CarsInOffice
											FROM Vehicles v
											JOIN Offices o ON v.OfficeId = o.Id
											WHERE o.Id = @officeId)
	DECLARE @parkSpacesInOffice INT = (SELECT ParkingPlaces FROM Offices WHERE Id = @officeId)

	IF(@countInOfficeCars >= @parkSpacesInOffice)
	BEGIN 
		ROLLBACK
		RAISERROR('Not enough room in this office!', 16, 1)
		RETURN
	END

	COMMIT
END

GO

--Problem 19

CREATE TRIGGER tr_AddMileage ON Orders
FOR UPDATE
AS
BEGIN 
	DECLARE @haveValueInTotalMileage INT = (SELECT TotalMileage FROM deleted)
	DECLARE @mileageToAdd INT = (SELECT TotalMileage FROM inserted)
	DECLARE @orderId INT = (SELECT Id FROM inserted)

	IF(@haveValueInTotalMileage IS NOT NULL)
	BEGIN 
		ROLLBACK
		RETURN
	END
	ELSE
	BEGIN
		UPDATE Vehicles
		SET Mileage += @mileageToAdd
		WHERE Id = (SELECT VehicleId FROM Orders WHERE Id = @orderId)
	END
END

GO

