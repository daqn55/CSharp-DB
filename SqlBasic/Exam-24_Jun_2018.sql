create table Cities(
	Id int identity primary key not null,
	Name nvarchar(20) not null,
	CountryCode varchar(2) not null
)

create table Hotels(
	Id int identity primary key not null,
	Name nvarchar(30) not null,
	CityId int not null,
	EmployeeCount int not null,
	BaseRate decimal(15, 2)

	constraint FK_Hotels_City foreign key(CityId)
	references Cities(Id)
)

create table Rooms(
	Id int identity primary key not null,
	Price decimal(15, 2) not null,
	Type nvarchar(20) not null,
	Beds int not null,
	HotelId int not null,

	constraint FK_Rooms_Hotel foreign key(HotelId)
	references Hotels(Id)
)

create table Trips(
	Id int identity primary key not null,
	RoomId int not null,
	BookDate DATE not null,
	ArrivalDate date not null,
	ReturnDate date not null,
	CancelDate date,

	constraint CHK_Trips_Book check(BookDate < ArrivalDate),
	constraint CHK_Trips_Arrival check(ArrivalDate < ReturnDate),
	constraint FK_Trips_Room foreign key(RoomId)
	references Rooms(Id)
)

create table Accounts(
	Id int identity primary key not null,
	FirstName nvarchar(50) not null,
	MiddleName nvarchar(20),
	LastName nvarchar(50) not null,
	CityId int not null,
	BirthDate date not null,
	Email varchar(100) not null unique,

	constraint FK_Accounts_City foreign key(CityId)
	references Cities(Id)
)

create table AccountsTrips(
	AccountId int not null,
	TripId int not null,
	Luggage int not null check(Luggage >= 0)

	constraint PK_Account_Trip primary key(AccountId, TripId)
	constraint FK_AccountsTrips_Account foreign key(AccountId)
	references Accounts(Id),
	constraint FK_AccountsTrips_Trip foreign key(TripId)
	references Trips(Id)
)



--Problem 2

INSERT INTO Accounts
VALUES
	('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
	('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
	('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
	('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

insert into Trips
values
	(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
	(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
	(103, '2013-07-17', '2013-07-23', '2013-07-24', null),
	(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
	(109, '2017-08-07', '2017-08-28', '2017-08-29', null)


--Problem 3

update Rooms
set Price *= 1.14 where HotelId IN(5, 7, 9)

--Problem 4

delete from AccountsTrips
where AccountId = 47

--Problem 5

select c.Id, c.Name
	from Cities c
	where c.CountryCode = 'BG'
	order by c.Name

--Problem 6

select 
	case 
		when a.MiddleName is null then concat(a.FirstName, ' ', a.LastName) 
		else concat(a.FirstName, ' ', a.MiddleName, ' ', a.LastName) 
	end as 'Full Name',
	year(a.BirthDate) as BirthYear
	from Accounts a
	where year(a.BirthDate) > 1991
	order by year(a.BirthDate) desc, a.FirstName

--Problem 7

select a.FirstName, a.LastName, convert(varchar, a.BirthDate, 110) as BirthDate, c.Name as Hometown, a.Email
	from Accounts a
	join Cities c ON a.CityId = c.Id
	where left(a.Email, 1) = 'e'
	order by c.Name desc

--Problem 8

select c.Name, count(h.Id) as Hotels
	from Cities c
	left join Hotels h on c.Id = h.CityId
	group by c.Name
	order by count(h.Id) desc, c.name

--Problem 9

select r.Id, r.Price, h.Name as Hotel, c.Name as City
	from Rooms r
	join Hotels h on r.HotelId = h.Id
	join Cities c on h.CityId =  c.Id
	where r.Type = 'First Class'
	order by r.Price desc, r.Id

--Problem 10 

select a.Id as AccountId, concat(a.FirstName,' ', a.LastName) as FullName, max(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) as LongestTrip, min(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) as ShortestTrip
	from AccountsTrips att
	join Trips t on att.TripId = t.Id
	join Accounts a on att.AccountId = a.Id
	where a.MiddleName is null and t.CancelDate is null
	group by a.Id, concat(a.FirstName,' ', a.LastName)
	order by max(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) desc, a.Id

--Problem 11

select top 5 e.Id, c.Name as City, c.CountryCode as Country, e.Accounts
	from(
			select c.Id, count(a.id) as Accounts
				from Accounts a
				join Cities c on a.CityId = c.Id
				group by c.Id) as e
	join Cities c on e.Id = c.Id
	order by e.Accounts desc

--Problem 12

select e.accountId as Id, a.Email, c.Name as City, e.Trips
	from(
			select a.Id as accountId, c.Id as cityId, count(t.Id) as Trips
				from AccountsTrips att
				join Accounts a on att.AccountId = a.Id
				join Trips t on att.TripId = t.Id
				join Cities c on a.CityId = c.Id
				join Rooms r on t.RoomId = r.Id
				join Hotels h on r.HotelId = h.Id
				join Cities hc on h.CityId = hc.Id
				where c.Name = hc.Name
				group by a.Id, c.Id) as e
	join Cities c on e.cityId = c.Id
	join Accounts a on e.accountId = a.Id
	order by e.Trips desc, e.accountId

--Problem 13

select top 10 c.Id as cityId, c.Name, sum(h.BaseRate + r.Price) as 'Total Revenue', count(t.Id) as Trips
	from Trips t
	join Rooms r on t.RoomId = r.Id
	join Hotels h on r.HotelId = h.Id
	join Cities c on h.CityId = c.Id
	where year(t.BookDate) = 2016 
	group by c.Id, c.Name
	order by sum(h.BaseRate + r.Price) desc, count(t.Id) desc

--Problem 14

select t.Id, h.Name as HotelName, r.Type,
		case 
			when t.CancelDate is not null  then 0
			else (h.BaseRate + r.Price)
		end as Revenue
	from Trips t
	join Rooms r on t.RoomId = r.Id
	join Hotels h on r.HotelId = h.Id
	order by r.Type, t.Id

	select * from Trips

--Problem 15

select e.AccountId, a.Email, e.CountryCode, e.Trips
	from(
			select a.Id as AccountId, c.CountryCode, count(t.Id) as Trips, row_number() over(partition by c.CountryCode order by count(t.Id) desc) as rank
				from AccountsTrips att
				join Accounts a on att.AccountId = a.Id
				join Trips t on att.TripId = t.Id
				join Rooms r on t.RoomId = r.Id
				join Hotels h on r.HotelId = h.Id
				join Cities c on h.CityId = c.Id
				group by c.CountryCode, a.Id) as e
	join Accounts a on e.AccountId = a.Id
	where e.rank = 1
	order by e.Trips desc, e.AccountId

--Problem 16

select att.TripId, sum(att.Luggage) as Luggage,
		case 
			when sum(att.Luggage) > 5 then concat('$', (sum(att.Luggage) * 5))
			else '$0'
		end as Fee
	from AccountsTrips att
	where att.Luggage > 0
	group by att.TripId
	order by sum(att.Luggage) desc

--Problem 17

select t.Id, 
	case
		when a.MiddleName is null then CONCAT(a.FirstName, ' ', a.LastName)
		else CONCAT(a.FirstName, ' ', a.MiddleName, ' ', a.LastName)
	end as FullName,

	ac.Name as [From], c.Name as [To],

	case
		when t.CancelDate Is not null then 'Canceled'
		else concat(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' ', 'days')
	end as Duration

		from AccountsTrips att
		join Accounts a on att.AccountId = a.Id
		join Cities ac on a.CityId = ac.Id
		join Trips t on att.TripId = t.Id
		join Rooms r on t.RoomId = r.Id
		join Hotels h on r.HotelId = h.Id
		join Cities c on h.CityId = c.Id
		order by CONCAT(a.FirstName, ' ', a.MiddleName, ' ', a.LastName), t.Id

go

--Problem 18

create function udf_GetAvailableRoom(@HotelId int, @Date date, @People int)
returns varchar(100)
as
begin
	declare @hotelBaseRate decimal(15, 2) = (select h.BaseRate from Hotels h where h.Id = @HotelId)
	declare @roomPrice decimal(15, 2) = (select top 1 r.Price
											from Trips t
											join Rooms r on t.RoomId = r.Id 
											where r.HotelId = @HotelId and r.Beds >= @People
												and (t.ArrivalDate > @Date or t.ReturnDate < @Date)
											order by r.Price desc)
	declare @roomId int = (select top 1 r.Id
											from Trips t
											join Rooms r on t.RoomId = r.Id 
											where r.HotelId = @HotelId and r.Beds >= @People
												and (t.ArrivalDate > @Date or t.ReturnDate < @Date)
											order by r.Price desc)
	declare @roomType varchar(50) = (select top 1 r.Type
											from Trips t
											join Rooms r on t.RoomId = r.Id 
											where r.HotelId = @HotelId and r.Beds >= @People
												and (t.ArrivalDate > @Date or t.ReturnDate < @Date)
											order by r.Price desc)
	declare @beds int = (select top 1 r.Beds
											from Trips t
											join Rooms r on t.RoomId = r.Id 
											where r.HotelId = @HotelId and r.Beds >= @People
												and (t.ArrivalDate > @Date or t.ReturnDate < @Date)
											order by r.Price desc)

	declare @totalPrice decimal(15, 2) = (@hotelBaseRate + @roomPrice) * @People

	declare @result varchar(100)

	declare @checkRoomIsTaken int = (select top 1 r.Id
											from Trips t
											join Rooms r on t.RoomId = r.Id 
											where r.HotelId = @HotelId and r.Beds >= @People
												and (t.ArrivalDate < @Date and t.ReturnDate > @Date)
											order by r.Price desc)

	if(@checkRoomIsTaken is not null)
	begin
		set @result = 'No rooms available'
	end
	else
	begin
		set @result = concat('Room ', @roomId, ': ', @roomType, ' (', @beds, ' beds) - $', @totalPrice)
	end

	return @result
end
go

--Problem 19

create proc usp_SwitchRoom(@TripId int, @TargetRoomId int)
as
begin
	declare @targetRoomHotel int = (select h.Id	from Rooms r join Hotels h on r.HotelId = h.Id where r.Id = @TargetRoomId)
	declare @currentRoom int = (select h.Id from Trips t join Rooms r on t.RoomId = r.Id join Hotels h on r.HotelId = h.Id where t.Id = @TripId)

	declare @neededBeds int = (select count(att.TripId)	from AccountsTrips att join Trips t on att.AccountId = t.Id	where att.TripId = @TripId group by att.TripId)
	declare @targetRoomBeds int = (select r.Beds from Rooms r join Hotels h on r.HotelId = h.Id where r.Id = @TargetRoomId)

	if(@targetRoomHotel <> @currentRoom)
	begin
		raiserror('Target room is in another hotel!', 16, 1)
		rollback
		return
	end
	else if(@targetRoomBeds < @neededBeds)
	begin 
		raiserror('Not enough beds in target room!', 16, 1)
		rollback
		return
	end
	else
	begin
		update Trips
		set RoomId = @TargetRoomId
		where Id = @TripId
	end
end

EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10
EXEC usp_SwitchRoom 10, 7
EXEC usp_SwitchRoom 10, 8
go
--Problem 20

create trigger TR_tripDelete on Trips instead of delete
as
begin
	update Trips
	set CancelDate = getdate()
	where Id IN(select id from deleted) and CancelDate is null
end

DELETE FROM Trips
WHERE Id IN (48, 49, 50)

go


select * from Cities
SELECT * from Accounts
select * from Rooms where HotelId =112
select * from AccountsTrips where TripId = 10
select * from Hotels where id = 112
select * from Trips where roomid = 211
