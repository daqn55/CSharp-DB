--Problem 1
CREATE DATABASE Minions

--Problem 2
CREATE TABLE Minions(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	Age NVARCHAR(50)
)
CREATE TABLE Towns(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

--Problem 3
ALTER TABLE Minions
ADD TownId INT NOT NULL
FOREIGN KEY(TownId) REFERENCES Towns(Id)

SELECT * FROM Towns
SELECT * FROM Minions

--Problem 4
INSERT INTO Towns(Id, Name)
VALUES(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO Minions(Id, Name, Age, TownId)
VALUES(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3)

INSERT INTO Minions(Id, Name, TownId)
VALUES(3, 'Steward', 2)

--Problem 5
TRUNCATE TABLE Minions

--Problem 6
DROP TABLE Minions
DROP TABLE Towns

--Problem 7
CREATE TABLE People(
	Id INT IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(2048),
	Height DECIMAL(15, 2),
	[Weight] DECIMAL(15, 2),
	Gender VARCHAR(1) NOT NULL CHECK(Gender IN ('m', 'f')),
	BirthDate DATE NOT NULL,
	Biography VARCHAR(MAX)
	PRIMARY KEY(Id)
)

INSERT INTO People(Name, Height, Weight, Gender, BirthDate)
VALUES('Daqn', 184.51, 80.5, 'm', '1991-11-04'),
('Vanq', 164.7, 80.5, 'm', '1961-12-24'),
('Pesho', 164.21, 100.5, 'm', '1981-01-05'),
('Gosho', 200.2, 60.5, 'm', '1999-10-14'),
('Mihaela', 158.15, 40.5, 'm', '1995-05-25')

SELECT * FROM People

--Problem 8
CREATE TABLE Users(
	Id INT IDENTITY,
	Username VARCHAR(30) NOT NULL UNIQUE,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(900),
	LastLoginTime DATETIME2,
	IsDeleted BIT
	PRIMARY KEY(Id)
)

INSERT INTO Users(Username, Password, LastLoginTime, IsDeleted)
VALUES('Didko', '1234', '2018-01-20', 'true'),
('Ivan', '1234', '2018-05-01', 'false'),
('Pesho', '123443', '2018-08-02', 'false'),
('Gosho', '123467', '2018-03-21', 'false'),
('Ani', '1234567', '2018-04-26', 'true')

SELECT * FROM Users

ALTER TABLE Users
ADD PRIMARY KEY(Id)

--Problem 9
ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC070FE874A2

ALTER TABLE Users
ADD CONSTRAINT PK_User PRIMARY KEY(Id, Username)

--Probem 10
ALTER TABLE Users WITH NOCHECK
ADD CONSTRAINT CHK_Password CHECK (DATALENGTH([Password]) >= 5)

--Problem 11
ALTER TABLE Users
ADD CONSTRAINT DF_LastLogin DEFAULT GETDATE() FOR LastLoginTime

INSERT INTO Users(Username, Password)
VALUES('haho', '12345')

--Problem 12
ALTER TABLE Users
DROP CONSTRAINT PK_User

ALTER TABLE Users
ADD CONSTRAINT PK_ID PRIMARY KEY (Id)

ALTER TABLE Users WITH NOCHECK
ADD CONSTRAINT CHK_Username CHECK (DATALENGTH(Username) >= 3)

--Problem 13
CREATE DATABASE Movies

CREATE TABLE Directors(
	Id INT IDENTITY,
	DirectorName NVARCHAR(50),
	Notes NVARCHAR(MAX)
	PRIMARY KEY(Id)
)

CREATE TABLE Genres(
	Id INT IDENTITY,
	GenreName NVARCHAR(50),
	Notes NVARCHAR(MAX)
	PRIMARY KEY(Id)
)

CREATE TABLE Categories(
	Id INT IDENTITY,
	CategoryName NVARCHAR(50),
	Notes NVARCHAR(MAX)
	PRIMARY KEY(Id)
)


CREATE TABLE Movies(
	Id INT IDENTITY PRIMARY KEY,
	Title NVARCHAR(100) NOT NULL,
	DirectorId INT NOT NULL,
	CopyrightYear DATETIME2 NOT NULL,
	Lenght DECIMAL(15, 2) NOT NULL,
	GenreId INT NOT NULL,
	CategoryId INT NOT NULL,
	Rating INT,
	Notes NVARCHAR(MAX),
	CONSTRAINT FK_DirectorsID FOREIGN KEY(DirectorId)
	REFERENCES Directors(Id),
	CONSTRAINT FK_GenresID FOREIGN KEY(GenreId)
	REFERENCES Genres(Id),
	CONSTRAINT FK_CategotiesID FOREIGN KEY(CategoryId)
	REFERENCES Categories(Id)
)

INSERT INTO Directors(DirectorName)
VALUES ('Daqn'),
('Tosho'),
('Pesho'),
('Kremena'),
('Ani')

INSERT INTO Genres(GenreName)
VALUES ('Action'),
('Comedy'),
('Horor'),
('Drama'),
('Adventure')

INSERT INTO Categories(CategoryName)
VALUES ('Kids'),
('Adults'),
('DVD'),
('XVID'),
('Anime')

INSERT INTO Movies(Title, DirectorId, CopyrightYear, Lenght, GenreId, CategoryId, Rating)
VALUES('DoRoDo', 1, GETDATE(), 1.5, 2, 1, 10),
('Ivanushka', 1, '2010-11-25', 2.5, 4, 3, 5),
('DoRoDo', 1, '2010-11-25', 1.5, 3, 2, 10),
('DoRoDo', 1, '2010-11-25', 1.5, 1, 4, 10),
('DoRoDo', 1, '2010-11-25', 1.5, 2, 5, 10)


SELECT * FROM Categories
SELECT * FROM Directors
SELECT * FROM Movies

--Problem 14

CREATE DATABASE CarRental

CREATE TABLE Categories(
	Id INT IDENTITY PRIMARY KEY,
	CategoryName VARCHAR(50) NOT NULL,
	DaityRate DECIMAL(15, 2),
	WeeklyRate DECIMAL(15, 2),
	MonthlyRate DECIMAL(15, 2),
	WeekendRate DECIMAL(15, 2)
)

CREATE TABLE Cars(
	Id INT IDENTITY PRIMARY KEY,
	PlateNumber VARCHAR(10) NOT NULL,
	Manufacturer NVARCHAR(50) NOT NULL,
	Model NVARCHAR(50) NOT NULL,
	CarYear DATE NOT NULL,
	CategoryId INT NOT NULL,
	Doors INT NOT NULL,
	Picture VARBINARY(2048),
	Condition NVARCHAR(50),
	Available BIT NOT NULL,
	CONSTRAINT FK_CategoryId FOREIGN KEY (CategoryId)
	REFERENCES Categories(Id)
)

CREATE TABLE Employees(
	Id INT IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(100) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Customers(
	Id INT IDENTITY PRIMARY KEY,
	DriverLicenceNumber INT NOT NULL,
	FullName NVARCHAR(100) NOT NULL,
	Address NVARCHAR(200) NOT NULL,
	City NVARCHAR(50) NOT NULL,
	ZIPCode VARCHAR(20) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE RentalOrders(
	Id INT IDENTITY PRIMARY KEY,
	EmployeeId INT NOT NULL,
	CustomerId INT NOT NULL,
	CarId INT NOT NULL,
	TankLevel DECIMAL(15, 2) NOT NULL,
	KilometrageStart DECIMAL (15, 2) NOT NULL,
	KilometrageEnd DECIMAL(15, 2) NOT NULL,
	TotalKilometrage DECIMAL(15, 2) NOT NULL,
	StartDate DATETIME2 NOT NULL,
	EndDate DATETIME2 NOT NULL,
	TotalDays INT NOT NULL,
	RateApplied DECIMAL(15, 2),
	TaxRate DECIMAL(15, 2) NOT NULL,
	OrderStatus NVARCHAR(20) NOT NULL,
	Notes NVARCHAR(MAX)
	CONSTRAINT PK_EmployeeId FOREIGN KEY(EmployeeId)
	REFERENCES Employees(Id),
	CONSTRAINT PK_CustomerId FOREIGN KEY(CustomerId)
	REFERENCES Customers(Id),
	CONSTRAINT PK_CarId FOREIGN KEY(CarId)
	REFERENCES Cars(Id)
)

INSERT INTO Categories(CategoryName)
VALUES('Fast Car'),
('Vans'),
('Truck')

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Available)
VALUES('CB1234BG', 'SBTOT', 'Ford', '1992-09-23', 2, 4, 'true'),
('CB1222BG', 'SBTOT', 'Alfa', '1992-09-23', 1, 4, 'true'),
('CB1254BG', 'SBTOT', 'Fiat', '1992-09-23', 3, 4, 'true')

INSERT INTO Employees(FirstName, LastName, Title)
VALUES('Daqn', 'Ivanov', 'Mr.'),
('Ani', 'Cankova', 'Miss'),
('Ceco', 'Ivanov', 'Mr.')

INSERT INTO Customers(DriverLicenceNumber, FullName, Address, City, ZIPCode)
VALUES(12345, 'Ivanka Ivanova', 'Nadejda bl.123', 'Sofia', 1234),
(25649, 'Drisuk Georgiev', 'Lulin bl.540', 'Sofia', 1520),
(98564, 'Pesho Lainoto', 'Iztok bl.1', 'Sofia', 1001)

INSERT INTO RentalOrders(EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, TotalKilometrage, StartDate, EndDate, TaxRate, OrderStatus, TotalDays)
VALUES(1, 2, 3, 50.4, 12345, 12567, 14545, '2018-01-01', '2018-01-05', 123.5, 'Taken', 4),
(2, 1, 3, 50.4, 12345, 12567, 14545, '2018-01-01', '2018-01-05', 123.5, 'Taken', 4),
(3, 3, 1, 50.4, 12345, 12567, 14545, '2018-01-01', '2018-01-05', 123.5, 'Taken', 4)

--Problem 15

CREATE DATABASE Hotel

CREATE TABLE Employees(
	Id INT IDENTITY PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Title VARCHAR(10) NOT NULL,
	Notes NVARCHAR(200)
)

CREATE TABLE Customers(
	AccountNumber INT IDENTITY PRIMARY KEY, 
	FirstName VARCHAR(50) NOT NULL, 
	LastName VARCHAR(50) NOT NULL, 
	PhoneNumber INT NOT NULL, 
	EmergencyName NVARCHAR(50), 
	EmergencyNumber INT, 
	Notes NVARCHAR(200)
)

CREATE TABLE RoomStatus(
	RoomStatus VARCHAR(20) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(200)
)

CREATE TABLE RoomTypes(
	RoomType VARCHAR(50) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(200)
)

CREATE TABLE BedTypes(
	BedType VARCHAR(50) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(200)
)

CREATE TABLE Rooms(
	RoomNumber INT PRIMARY KEY NOT NULL,
	RoomType VARCHAR(50) NOT NULL,
	BedType VARCHAR(50) NOT NULL,
	Rate INT,
	RoomStatus VARCHAR(20) NOT NULL,
	Notes NVARCHAR(200),
	CONSTRAINT FK_RoomType FOREIGN KEY(RoomType)
	REFERENCES RoomTypes(RoomType),
	CONSTRAINT FK_BedType FOREIGN KEY(BedType)
	REFERENCES BedTypes(BedType),
	CONSTRAINT FK_RoomStatus FOREIGN KEY(RoomStatus)
	REFERENCES RoomStatus(RoomStatus)
)

CREATE TABLE Payments(
	Id INT IDENTITY PRIMARY KEY,
	EmployeeId INT NOT NULL,
	PaymentDate DATETIME2 NOT NULL,
	AccountNumber INT NOT NULL,
	FirstDateOccupied DATETIME2 NOT NULL, 
	LastDateOccupied DATETIME2 NOT NULL, 
	TotalDays INT NOT NULL, 
	AmountCharged DECIMAL(15, 2) NOT NULL, 
	TaxRate DECIMAL(15, 2) NOT NULL, 
	TaxAmount DECIMAL(15, 2) NOT NULL, 
	PaymentTotal DECIMAL(15, 2) NOT NULL, 
	Notes NVARCHAR(200),
	CONSTRAINT FK_EmployeeId FOREIGN KEY(EmployeeId)
	REFERENCES Employees (Id),
	CONSTRAINT FK_AccountNumber FOREIGN KEY(AccountNumber)
	REFERENCES Customers(AccountNumber)
)

CREATE TABLE Occupancies(
	Id INT IDENTITY PRIMARY KEY,
	EmployeeId INT NOT NULL, 
	DateOccupied DATETIME2 NOT NULL, 
	AccountNumber INT NOT NULL, 
	RoomNumber INT NOT NULL, 
	RateApplied INT, 
	PhoneCharge DECIMAL(15, 2), 
	Notes NVARCHAR(200),
	CONSTRAINT FK_EmployeeIdOccup FOREIGN KEY(EmployeeId)
	REFERENCES Employees (Id),
	CONSTRAINT FK_AccountNumberOccup FOREIGN KEY(AccountNumber)
	REFERENCES Customers(AccountNumber),
	CONSTRAINT FK_RoomNumber FOREIGN KEY(RoomNumber)
	REFERENCES Rooms(RoomNumber)
)

INSERT INTO Employees(FirstName, LastName, Title)
VALUES('Pesho', 'Ivanov', 'Mr.'),
('Gosho', 'Ivanov', 'Mr.'),
('Tosho', 'Ivanov', 'Mr.')

INSERT INTO Customers(FirstName, LastName, PhoneNumber)
VALUES('Tetka', 'Shirokova', 35924421),
('Tetka', 'Shirokova', 35924421),
('Tetka', 'Shirokova', 35924421)

INSERT INTO RoomStatus(RoomStatus)
VALUES('Free'),
('Taken'),
('NotFree')

INSERT INTO RoomTypes(RoomType)
VALUES('Apartament'),
('Studio'),
('Mesonet')

INSERT INTO BedTypes(BedType)
VALUES('Three Beds'),
('Double bed'),
('One bed')

INSERT INTO Rooms(RoomNumber, RoomType, BedType, RoomStatus)
VALUES(100, 'Mesonet', 'One bed', 'Free'),
(101, 'Apartament', 'Double bed', 'NotFree'),
(102, 'Studio', 'One bed', 'Taken')

INSERT INTO Payments(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, TotalDays, AmountCharged, TaxRate, TaxAmount, PaymentTotal)
VALUES (1, '2018-01-01', 1, '2018-01-01', '2018-01-10', 9, 159.50, 12, 20, 200),
(2, '2018-01-01', 1, '2018-01-01', '2018-01-10', 9, 159.50, 12, 20, 200),
(3, '2018-01-01', 1, '2018-01-01', '2018-01-10', 9, 159.50, 12, 20, 200)

INSERT INTO Occupancies(EmployeeId, DateOccupied, AccountNumber, RoomNumber)
VALUES(1, '2018-01-10', 1, 100),
(2, '2018-01-10', 2, 100),
(1, '2018-01-10', 3, 100)


--Problem 16

CREATE DATABASE SoftUni

CREATE TABLE Towns(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses(
	Id INT IDENTITY PRIMARY KEY,
	AddressText NVARCHAR(200) NOT NULL,
	TownId INT NOT NULL
	CONSTRAINT FK_TownId FOREIGN KEY(TownId)
	REFERENCES Towns(Id)
)

CREATE TABLE Departments(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT IDENTITY PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	MiddleName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	JobTitle VARCHAR(50) NOT NULL,
	DepartmentId INT NOT NULL,
	HireDate DATETIME2 NOT NULL,
	Salary DECIMAL(15, 2) NOT NULL,
	AddressId INT,
	CONSTRAINT FK_DepartmentId FOREIGN KEY(DepartmentId)
	REFERENCES Departments(Id),
	CONSTRAINT FK_AddressId FOREIGN KEY(AddressId)
	REFERENCES Addresses(Id)
)

--Problem 17

DROP DATABASE SoftUni

--Problem 18

INSERT INTO Towns(Name)
VALUES('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT INTO Departments(Name)
VALUES('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary)
VALUES('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '20130201', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '20040302', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '20160828', 525.25),
('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '20071209', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, '20160828', 599.88)

--Problem 19

SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees

--Problem 20

SELECT * FROM Towns
ORDER BY [Name] ASC

SELECT * FROM Departments
ORDER BY [Name] ASC

SELECT * FROM Employees
ORDER BY Salary DESC

--Problem 21

SELECT [Name] FROM Towns
ORDER BY [Name] ASC

SELECT [Name] FROM Departments
ORDER BY [Name] ASC

SELECT FirstName, LastName, JobTitle, Salary
FROM Employees
ORDER BY Salary DESC

--Problem 22

UPDATE Employees
SET Salary = Salary * 1.1

SELECT Salary FROM Employees

--Problem 23

UPDATE Payments
SET TaxRate = TaxRate * 0.97

SELECT TaxRate FROM Payments

--Problem 24

TRUNCATE TABLE Occupancies