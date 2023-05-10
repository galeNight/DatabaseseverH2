use master
go
if DB_ID('PatientDatabase') is not null
	begin
	--alter database PatientDatabase set single_user with rollback immediate
	drop database PatientDatabase
	end
create database PatientDatabase
go
use PatientDatabase

create table Doctores(
Id int identity(1,1)primary key,
FirstName nvarchar(255),
LastName nvarchar(255)
)
create table Patient(
Id int identity(1,1)primary key,
FristName nvarchar(255),
LastName nvarchar(255),
PatientTlfNr Nvarchar(255),
DoctoreId int
foreign key (DoctoreId) references Doctores(Id)
)
create table Departments(
Id int identity(1,1)primary key,
DepartmentsName nvarchar(255),
)
create table WherePatiensis(
Id int identity(1,1) primary key,
PatientId int,
DepartmentId int
foreign key(PatientId) references Patient(Id),
foreign key (DepartmentId) references Departments(Id)
)


insert into Patient(FristName,LastName,PatientTlfNr)values('tets','Testes',99999999)
insert into Departments(DepartmentsName)values('testtesttest')
insert into Doctores(FirstName,LastName)values('Doctor','test')

select*from Patient
select*from Doctores
select*from Departments

--opret bruger
go
create login [test] with password = 'test', check_policy = off
go

--tildel severrolle
alter server role [sysadmin] add member[test]