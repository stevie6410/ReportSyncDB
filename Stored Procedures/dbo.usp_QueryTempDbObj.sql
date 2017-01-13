SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************
--Description:					Audit report for all temp,test, bkp  objects through out all the data bases
--Dependencies:					-MASTER.dbo.sysdatabases - Description of all objects for given database
								-Physical table to insert the data is tbl_AuditResults_TempTables
								- fn_trace_gettable(@base_tracefilename, default) - to get the login name of the person who last used the object
--SSRS report ref				Report Server Admin/Audit Reports/TemperoryObjects
--Parameters:													                
--Sample Execution:			

DECLARE	@return_value int
EXEC	@return_value = [dbo].[usp_QueryTempDbObj]
SELECT	'Return Value' = @return_value
GO
						
****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		09 Dec	2016		 	Bulbul			Initial Creation
*****************************************************************************************************************/
CREATE PROCEDURE [dbo].[usp_QueryTempDbObj]
	-- Add the parameters for the stored procedure here
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--select * from syscomments
    -- Insert statements for procedure here
DECLARE @SearchString NVARCHAR(255)
DECLARE @name NVARCHAR(50)
DECLARE @db_name1 NVARCHAR(50)
DECLARE @sql NVARCHAR(MAX)


declare @curr_tracefilename varchar(500);
declare @base_tracefilename varchar(500);
declare @indx int ;
select @curr_tracefilename = path from sys.traces where is_default = 1 ;
set @curr_tracefilename = reverse(@curr_tracefilename)
select @indx = PATINDEX('%\%', @curr_tracefilename)
set @curr_tracefilename = reverse(@curr_tracefilename)
set @base_tracefilename = LEFT( @curr_tracefilename,len(@curr_tracefilename) - @indx) + '\log.trc';
--select @base_tracefilename

SET @db_name1 ='@name' 
SET @SearchString = --'test' 
					--'temp' 
					'bkp'
truncate table tbl_AuditResults_TempTables
DECLARE db_cursor CURSOR FOR  SELECT name FROM MASTER.dbo.sysdatabases WHERE name NOT IN ('master','model','msdb','tempdb','SelfVerification' ,'ReportServer', 'ReportServerTempDB') 

-- selects the database name
OPEN db_cursor 
--DECLARE @Results TABLE(typedesc nvarchar(max) ,schemanames  nvarchar(max)  , tableNames  nvarchar(max) )
FETCH NEXT FROM db_cursor INTO @name  

While @@FETCH_STATUS = 0
BEGIN
 SET @db_name1 =@name + '.sys.objects' 
--SET @SQL = 'INSERT INTO tbl_AuditResults_TempTables(typedesc, tableNames,schemanames) SELECT type_desc, name,'' ' + @name  + ''' as SchemaName from ' + @db_name1  + ' where name like ''%test%''  or name like ''%tmp%'' or name like ''%bkp%''  or name like ''%temp%'' or name like ''%Backup%'''
  --SELECT @sql = 'SELECT  name, type_desc FROM'+' '+ @db_name1 + ' a'
  --SELECT @sql = @sql+' WHERE a.name like' + ' %' + @SearchString+ '%' + '	ORDER BY b.name'
  SET @SQL = 'INSERT INTO tbl_AuditResults_TempTables(typedesc,ObjectName, schemanames,objectid) SELECT type_desc, name,'' ' + @name  + ''' as SchemaName, object_id from ' + @db_name1  + ' where (name like ''%test%''  or name like ''%tmp%'' or name like ''%bkp%''  or name like ''%temp%'' or name like ''%Backup%'') and(name  not like ''%Template%'' and name  not like ''%SystemPolicy%'' and  name  not like ''%GETMPF%''  and  name  not like ''%GETMPF%'' and  name  not like ''%ESTIMATESTATISTIC%'')  '
--  

--INSERT INTO #Results(typedesc,schemanames, tableNames)
EXECUTE( @SQL);
--select @SQL
FETCH NEXT FROM db_cursor INTO @name
END	
Close db_cursor
DEALLOCATE db_cursor

select   at.typedesc as 'typedesc', at.schemanames as 'schemanames', at.ObjectName as 'ObjectName' , at.objectid as 'objectid' , t.LoginName as 'LoginName'  from  tbl_AuditResults_TempTables at left join
(
Select max(StartTime) as 'starttime', LoginName, ObjectID   from fn_trace_gettable(@base_tracefilename, default) group by LoginName, ObjectID
) t on  t.ObjectID = at.ObjectID order by at.typedesc
 --fn_trace_gettable(@base_tracefilename, default ) tt  on(at.objectid = tt.ObjectID) 

--Where (tt.StartTime = (Select max(StartTime)  from fn_trace_gettable(@base_tracefilename, default) t where t.ObjectID = tt.ObjectID ))    
--declare @curr_tracefilename varchar(500);
--declare @base_tracefilename varchar(500);
--declare @indx int ;

--select @curr_tracefilename = path from sys.traces where is_default = 1 ;
--set @curr_tracefilename = reverse(@curr_tracefilename)
--select @indx = PATINDEX('%\%', @curr_tracefilename)
--set @curr_tracefilename = reverse(@curr_tracefilename)
--set @base_tracefilename = LEFT( @curr_tracefilename,len(@curr_tracefilename) - @indx) + '\log.trc';
--select @base_tracefilename
--select
--ObjectName
--, CASE EventClass WHEN 46 THEN 'CREATE' WHEN 47 THEN 'DROP' WHEN 164 THEN 'ALTER' END DDLOperation
--, ObjectID
--, DatabaseName
--, StartTime
--, EventClass
--, EventSubClass
--, ObjectType
--, ServerName
--, LoginName
--, NTUserName
--, ApplicationName
--FROM ::fn_trace_gettable( @base_tracefilename, default )
--where EventClass in (46,47,164) and EventSubclass = 0 and DatabaseID = db_id()
--order by objectname,starttime desc

END
GO
