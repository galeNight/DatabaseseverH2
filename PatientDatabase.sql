use master
go
if DB_ID('PatientDatabase') is not null
	begin
	--alter database PatientDatabase set single_user with rollback immediate
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
DoctoreId int
foreign key (DoctoreId) references Doctores(Id)
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
DepartmentId int
foreign key(PatientId) references Patient(Id),
foreign key (DepartmentId) references Departments(Id)
)


insert into Patient(FristName,LastName,PatientTlfNr)values('tets','Testes',99999999)--data
insert into Departments(DepartmentsName)values('testtesttest')
insert into Doctores(FirstName,LastName)values('Doctor','test')

select * from Doctores -- viser data der ligger i table
select * from Patient
select * from Departments


go
create login Ole with password = 'test', check_policy = off
create login Niels with password = 'test', check_policy = off --opret bruger sever
go

alter server role [sysadmin] add member Niels --tildel severrolle

use PatientDatabase;

create user ole for login Ole;
alter role db_datareader
add member ole
create user niels for Login Niels; -- laver en user 
alter role db_owner
add member niels

--backup database PatientDatabase -- laver en backup
--to disk = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\PatientDatabase.bak'; -- sti til backupsted

EXEC sp_configure 'backup compression default', 1;
RECONFIGURE;

EXEC sp_configure 'remote admin connections', 1;
RECONFIGURE;

--EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'TcpEnabled';


use PatientDatabase
select name,physical_name as filelocation, type_desc as filetype
from sys.master_files
where database_id =DB_ID('PatientDatabase')

use PatientDatabase
exec sp_helprotect @username=Ole
exec sp_helprotect @username=Niels

use msdb
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