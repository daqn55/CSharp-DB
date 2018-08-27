--Problem 1

CREATE TABLE Passports(
	PassportID INT UNIQUE NOT NULL,
	PassportNumber NVARCHAR(50) NOT NULL

	CONSTRAINT PK_Passports_PassportID PRIMARY KEY (PassportID)
)

INSERT INTO Passports (PassportID, PassportNumber)
VALUES 
	(101, 'N34FG21B'),
	(102, 'K65LO4R7'),
	(103, 'ZE657QP2')


CREATE TABLE Persons(
	PersonID INT IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	Salary DECIMAL(15,2) NOT NULL,
	PassportID INT UNIQUE NOT NULL

	CONSTRAINT FK_Persons_PassportID FOREIGN KEY (PassportID)
	REFERENCES Passports(PassportID)
)

ALTER TABLE Persons
ADD CONSTRAINT PK_Persons_PersonID PRIMARY KEY (PersonID)

INSERT INTO Persons
VALUES
	('Roberto', 43300.00, 102),
	('Tom', 56100.00, 103),
	('Yana', 60200.00, 101)

--Problem 2

CREATE TABLE Manufacturers(
	ManufacturerID INT IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	EstablishedOn DATE NOT NULL

	CONSTRAINT PK_Manufacturers_ManufacturerID PRIMARY KEY (ManufacturerID)
)

INSERT INTO Manufacturers
VALUES
	('BMW', '07/03/1916'),
	('Tesla', '01/01/2003'),
	('Lada', '01/05/1966')

CREATE TABLE Models(
	ModelID INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	ManufacturerID INT NOT NULL

	CONSTRAINT FK_Models_ManufacturerID FOREIGN KEY (ManufacturerID)
	REFERENCES Manufacturers(ManufacturerID)
)

INSERT INTO Models
VALUES
	(101, 'X1', 1),
	(102, 'i6', 1),
	(103, 'Model S', 2),
	(104, 'Model X', 2),
	(105, 'Model 3', 2),
	(106, 'Nova', 3)

--Problem 3

CREATE TABLE Students(
	StudentID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

INSERT INTO Students
VALUES 
	('Mila'),
	('Mila'),
	('Ron')

CREATE TABLE Exams(
	ExamID INT IDENTITY(101, 1) PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL
)

INSERT INTO Exams
VALUES
	('SpringMVC'),
	('Neo4j'),
	('Oracle 11g')

CREATE TABLE StudentsExams(
	StudentID INT NOT NULL,
	ExamID INT NOT NULL

	CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentID, ExamID)
	
	CONSTRAINT FK_PK_StudentsExams_StudentID FOREIGN KEY(StudentID)
	REFERENCES Students(StudentID),

	CONSTRAINT FK_PK_StudentsExams_ExamID FOREIGN KEY(ExamID)
	REFERENCES Exams(ExamID)
)

INSERT INTO StudentsExams
VALUES
	(1, 101),
	(1, 102),
	(2, 101),
	(3, 103),
	(2, 102),
	(2, 103)

--Problem 4

CREATE TABLE Teachers(
	TeacherID INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	ManagerID INT

	CONSTRAINT FK_ManagerID_TeacherID FOREIGN KEY(ManagerID)
	REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers(TeacherID, Name)
VALUES
	(101, 'John')

INSERT INTO Teachers
VALUES
	(102, 'Maya', 106),
	(103, 'Silvia', 106),
	(104, 'Ted', 105),
	(105, 'Mark', 101),
	(106, 'Greta', 101)

--Problem 5

CREATE DATABASE OnlineStore

CREATE TABLE Cities(
	CityID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Customers(
	CustomerID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	Birthday DATE NOT NULL,
	CityID INT NOT NULL

	CONSTRAINT FK_Customers_CityID FOREIGN KEY (CityID)
	REFERENCES Cities(CityID)
)

CREATE TABLE Orders(
	OrderID INT IDENTITY PRIMARY KEY NOT NULL,
	CustomerID INT NOT NULL

	CONSTRAINT FK_CustomerID FOREIGN KEY(CustomerID)
	REFERENCES Customers(CustomerID)
)

CREATE TABLE ItemTypes(
	ItemTypeID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Items(
	ItemID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	ItemTypeID INT NOT NULL

	CONSTRAINT FK_ItemTypes_ItemTypeID FOREIGN KEY(ItemTypeID)
	REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems(
	OrderID INT NOT NULL,
	ItemID INT NOT NULL

	CONSTRAINT PK_OrderID_ItemID PRIMARY KEY(OrderID, ItemID)

	CONSTRAINT FK_Orders_OrderID FOREIGN KEY(OrderID)
	REFERENCES Orders(OrderID),

	CONSTRAINT FK_Items_ItemID FOREIGN KEY(ItemID)
	REFERENCES Items(ItemID)
)

--Problem 6

CREATE DATABASE University

CREATE TABLE Majors(
	MajorID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Students(
	StudentID INT IDENTITY PRIMARY KEY NOT NULL,
	StudentNumber INT NOT NULL,
	StudentName VARCHAR(50) NOT NULL,
	MajorID INT NOT NULL

	CONSTRAINT FK_MajorID FOREIGN KEY (MajorID)
	REFERENCES Majors(MajorID)
)

CREATE TABLE Payments(
	PaymentID INT IDENTITY PRIMARY KEY NOT NULL,
	PaymentDate DATE NOT NULL,
	PaymentAmount DECIMAL(15, 2) NOT NULL,
	StudentID INT NOT NULL

	CONSTRAINT FK_StudentID FOREIGN KEY (StudentID)
	REFERENCES Students(StudentID)
)

CREATE TABLE Subjects(
	SubjectID INT IDENTITY PRIMARY KEY NOT NULL,
	SubjectName VARCHAR(50) NOT NULL
)

CREATE TABLE Agenda(
	StudentID INT NOT NULL,
	SubjectID INT NOT NULL

	CONSTRAINT PK_StudentID_SubjectID PRIMARY KEY(StudentID, SubjectID)
	
	CONSTRAINT FK_Students_StudentID FOREIGN KEY (StudentID)
	REFERENCES Students(StudentID),

	CONSTRAINT FK_SubjectID FOREIGN KEY (SubjectID)
	REFERENCES Subjects(SubjectID)
)

--Problem 9

SELECT 'Rila' AS MountainRange, PeakName, Elevation
FROM Peaks
WHERE MountainId = 17
ORDER BY Elevation DESC
