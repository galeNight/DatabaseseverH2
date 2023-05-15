-- requirements to donwload SSMS
-- windows 10 version 1607(10.014393 of later or windows 11 
-- 1.8 GHz or faster x86 (Intel, AMD) processor. Dual-core or better recommended
--2 GB of RAM; 4 GB of RAM recommended (2.5 GB minimum if running on a virtual machine)
--Hard disk space: Minimum of 2 GB up to 10 GB of available space

--my pc requirements are 
--Intel(R) Core(TM) i5-8265U CPU @ 1.60GHz   1.80 GHz
--8,00 GB (7,81 GB kan bruges)
-- 64-bit operativsystem, x64-baseret processor
-- windows 10 enterprise version 22H2 and opertinsystem build 19045.2965


use master
go
if DB_ID('PatientDatabase') is not null -- alter database og setter med en user så den kan rolle tilbage og droppe databasen
	begin
	alter database PatientDatabase set single_user with rollback immediate 
	drop database PatientDatabase
	end
create database PatientDatabase -- laver database
go
use PatientDatabase -- bruger database

drop table if exists Doctores -- sletter tables
drop table if exists Patient
drop table if exists Departments
drop table if exists WherePatiensis

create table Doctores( -- table med navn
Id int identity(1,1)primary key,
FirstName nvarchar(255),
LastName nvarchar(255)
)
create table Patient( -- table med navn og referance
Id int identity(1,1)primary key,
FristName nvarchar(255),
LastName nvarchar(255),
PatientTlfNr Nvarchar(255),
)
create table Departments( -- table med arbejdsafdelings navn
Id int identity(1,1)primary key,
DepartmentsName nvarchar(255),
DoctorId int
foreign key (DoctorId) references Doctores(Id)
)
create table WherePatiensis( -- table hvor patinterne er og med referancer 
Id int identity(1,1) primary key,
PatientId int,
DepartmentId int,
foreign key(PatientId) references Patient(Id),
foreign key (DepartmentId) references Departments(Id)
)


insert into Patient(FristName,LastName,PatientTlfNr)values('tets','Testes',99999999)--data
insert into Departments(DepartmentsName,DoctorId)values('testtesttest',1)
insert into Doctores(FirstName,LastName)values('Doctor','test')
insert into WherePatiensis(PatientId,DepartmentId)values(1,2) -- set 2 til 1 hvis department id er 1 og omvent til 2 hvis id er 2

select * from Doctores -- viser data der ligger i table
select * from Patient
select * from Departments


go --opret bruger på severen
create login Ole with password = 'test', check_policy = off
create login Niels with password = 'test', check_policy = off 
go

alter server role [sysadmin] add member Niels --tildel role på severen

use PatientDatabase;

create user ole for login Ole; -- laver en user på databasen
alter role db_datareader -- tildeler role til user på databasen
add member ole
create user niels for Login Niels; 
alter role db_owner
add member niels


--backup database PatientDatabase -- laver en backup
--to disk = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\PatientDatabase.bak'; -- sti til backupsted

EXEC sp_configure 'backup compression default', 1;
RECONFIGURE;

EXEC sp_configure 'remote admin connections', 1;
RECONFIGURE;

--EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'TcpEnabled'; -- er mening at den skal vise om Tcp er 1 for at være tænt men virker ikke


use PatientDatabase
select name,physical_name as filelocation, type_desc as filetype
from sys.master_files
where database_id =DB_ID('PatientDatabase')

use PatientDatabase
exec sp_helprotect @username=Ole
exec sp_helprotect @username=Niels

use msdb -- create job
go
exec dbo.sp_add_job
@job_name = N'Check db size';
go

exec sp_add_jobstep
@job_name = N'Check db size',
@step_name = N'execute read db size',
@subsystem = N'TSQL',
@command = N'exec sp_Niels',
@retry_attempts = 5 ,
@retry_interval = 5;
go
exec dbo.sp_add_schedule
@schedule_name = N'Rundaly',
@freq_type = 4,
@freq_interval = 1,
@active_start_time = 033000;
go
exec dbo.sp_add_jobserver 
@job_name = N'Check db size';
go


use PatientDatabase

select --viser patient navn hvilken doctor patienten har og hvad doctorens specialiserre sig i via department
	CONCAT(left(P.FristName,1),'. ',P.LastName) as 'Patients',
	CONCAT(D.FirstName,' ',D.Lastname) as 'Doctores',
	DM.DepartmentsName as 'Departments'
from 
	Patient P
	join WherePatiensis Wp on P.Id = Wp.PatientId
	join Departments DM on Wp.DepartmentId = DM.Id
	join Doctores D on DM.DoctorId = D.Id

select -- viser patinternes navn og hvor mange doctor de har
	CONCAT(left(P.FristName,1),'. ',P.LastName) as 'Patient',
	count(distinct DM.DoctorId) as 'Amount of Doctor'
from Patient P
join WherePatiensis Wp on p.Id = Wp.PatientId
join Departments DM on Wp.DepartmentId = DM.Id
group by
p.Id,p.FristName,p.LastName;


select -- viser doctorens navne og hvor mange patienter de har
	CONCAT(D.FirstName,'',D.LastName) as 'Doctor',
	COUNT(distinct Wp.PatientId) as 'Amount of Patients'
from Doctores D
join Departments DM on D.Id = DM.DoctorId
join WherePatiensis Wp on DM.Id = Wp.DepartmentId
group by D.Id,D.FirstName,D.LastName

alter table Patient
add Age int;

update Patient
set Age = FLOOR(rand() * 18 + 1)

select AVG(Age) as 'AverageAge'
from Patient

select * from Patient