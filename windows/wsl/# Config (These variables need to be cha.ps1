# Config (These variables need to be change)
#-----------
$fetchDBname = "PhoniroCareVasteras" # Change DB name
$putDBname = "PhoniroCareVasteras"
$FilePath = "H:\$fetchDBname\" # Change to a suitable drive to store temp file 
$DBView="Sammanställning" # Change which view that wil lbe extracted

# Create file for actual month
#---------------------------------
if(!(Test-Path -path $FilePath))  
{  
  New-Item -ItemType directory -Path $FilePath
}

$Year = Get-Date -Format "yyyy"
$Month = Get-Date -Format "MM"
$Month=$Month-0

$FileName = $DBView+"-"+$Year+"-"+$Month+".csv"
$FileLatest = $FilePath+$FileName
$Parameters = "YEAR=$Year","MONTH=$Month"


# SQL command to gather data
#------------------------------
$SQLfetch = "
declare @Today datetime = cast(getdate() as date)

/* Brukare med aktiv best�llning */
if object_id(N'tempdb..#ActiveClientAssociation') is not null
begin
	drop table #ActiveClientAssociation
end
create table #ActiveClientAssociation (Client_id int, Organization_id int)
insert #ActiveClientAssociation (Client_id, Organization_id)
select distinct t0.Client_id, t0.Organization_id
from V1ClientAssociation as t0
where t0.StartDate <= @Today and (t0.EndDate is null or t0.EndDate >= @Today)

/* Sammanst�llning */
/* Vanliga l�s */
select
(
	select count(*)
	from V1Lock as t0
		inner join V1LockCategory as t1 on t0.LockCategory_id = t1.Id
	where t0.LockType = 0 and t1.Usage = 0 and t0.Active = 1
		and exists
		(
			select 1
			from V1ClientLock as s0
				inner join #ActiveClientAssociation as s1 on s0.Client_id = s1.Client_id
			where t0.Id = s0.Lock_id
		)
) as ClientLocksConnected
, (
	select count(*)
	from V1Lock as t0
		inner join V1LockCategory as t1 on t0.LockCategory_id = t1.Id
	where t0.LockType = 0 and t1.Usage = 0 and t0.Active = 1
) as ClientLocksActive

/* Portl�s */
, (
	select count(*)
	from V1Lock as t0
		inner join V1LockCategory as t1 on t0.LockCategory_id = t1.Id
	where t0.LockType = 1 and t1.Usage = 0 and t0.Active = 1
		and exists
		(
			select 1
			from V1ClientLocation as s0
				inner join #ActiveClientAssociation as s1 on s0.Client_id = s1.Client_id
			where t0.Location_id = s0.Location_id
		)
) as LocationLocksConnected
, (
	select count(*)
	from V1Lock as t0
		inner join V1LockCategory as t1 on t0.LockCategory_id = t1.Id
	where t0.LockType = 1 and t1.Usage = 0 and t0.Active = 1
) as LocationLocksActive

/* Nyckelg�mmor */
, (
	select count(*)
	from V1Lock as t0
		inner join V1LockCategory as t1 on t0.LockCategory_id = t1.Id
	where t1.Usage = 2 and t0.Active = 1
		and
		(
			exists
			(
				select 1
				from V1ClientLock as s0
					inner join #ActiveClientAssociation as s1 on s0.Client_id = s1.Client_id
				where t0.Id = s0.Lock_id
			)
			or
			exists
			(
				select 1
				from V1ClientLocation as s0
					inner join #ActiveClientAssociation as s1 on s0.Client_id = s1.Client_id
				where t0.Location_id = s0.Location_id
			)
		)
) as KeySafesConnected
, (
	select count(*)
	from V1Lock as t0
		inner join V1LockCategory as t1 on t0.LockCategory_id = t1.Id
	where t1.Usage = 2 and t0.Active = 1
) as KeySafesActive
"

Invoke-Sqlcmd -Database $fetchDBname -Query $SQLfetch -Variable $Parameters | Export-Csv -Path $FileLatest -Encoding UTF8 -Delimiter ';' -NoTypeInformation -Force

# SQL command to insert data
#------------------------------
$ContentLength = Get-Item -Path $FileLatest | Select -ExpandProperty Length
$SQLimport = "
DECLARE @FileContent varbinary(max)
SET @FileContent = (SELECT * FROM OPENROWSET (BULK '$FileLatest', SINGLE_BLOB) [Content]);
INSERT INTO [File] ([Name], [Description], [UploadedAt], [Content], [ContentType], [ContentLength])
VALUES ('$FileName', '$Year-$Month', GETDATE(), @FileContent, 'application/vnd.ms-excel', $ContentLength)
"

Invoke-Sqlcmd -Database $putDBname -Query $SQLimport 

# Cleanup
#------------------------------
Remove-Item $FileLatest