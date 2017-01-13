SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usb.trialObjectExecStats]
	
-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from  interfering with SELECT statements.
	SET NOCOUNT ON;
 ---SQL Server from time to time will remove execution plans from memory, if the cached plan is not being actively used.
 --- Therefore the statistics stored for a particular SP maybe for an accumulation of stats since SQL Server started, if the SP has only be compiled once.-
 -- Or, it may only have statistics for the last few minutes if the SP had recently been compiled.
DECLARE @name NVARCHAR(50)
DECLARE @db_name1 NVARCHAR(50)
DECLARE @sql NVARCHAR(MAX)
DECLARE @sql1 NVARCHAR(MAX)
declare @curr_tracefilename varchar(500);
declare @base_tracefilename varchar(500);
declare @indx int ;
select @curr_tracefilename = path from sys.traces where is_default = 1 ;
set @curr_tracefilename = reverse(@curr_tracefilename)
select @indx = PATINDEX('%\%', @curr_tracefilename)
set @curr_tracefilename = reverse(@curr_tracefilename)
set @base_tracefilename = LEFT( @curr_tracefilename,len(@curr_tracefilename) - @indx) + '\log.trc';
select @base_tracefilename
SET @db_name1 ='@name' 
select * from fn_trace_gettable( @base_tracefilename , default)
select * from sys.traces
DECLARE db_cursor CURSOR FOR  SELECT name FROM MASTER.dbo.sysdatabases WHERE name NOT IN ('master','model','msdb','tempdb','ReportServer','ReportServerTempDB') 
--truncate table  tbl_ObjectUsageReport;

CREATE TABLE #TempTbl 
( 
obj_Name varchar(max)
,obj_Type varchar(max)
,sql_Statement varchar(max)
,exec_count varchar(max)
,date_LastExecution date
,lastLoginName varchar(max)
,objectid bigint
,dataBaseName varchar(max)
)-- selects the database name

OPEN db_cursor 
--DECLARE @Results TABLE(typedesc nvarchar(max) ,schemanames  nvarchar(max)  , tableNames  nvarchar(max) )
FETCH NEXT FROM db_cursor INTO @name
While @@FETCH_STATUS = 0
BEGIN

truncate table  #TempTbl

--SELECT	'Return Value' = @return_value
--GO
--  update  tbl_ObjectUsageReport  set exec_count = exec_count + co.execCount,date_LastExecution = co.execTime,lastLoginName = co.loginname FROM  
-- (SELECT distinct s3.name AS ObjName,  
-- (SUBSTRING(TEXT,(s1.statement_start_offset+2)/2,(CASE WHEN s1.statement_end_offset = -1
--  THEN LEN(CONVERT(NVARCHAR(MAX),TEXT))*2   ELSE s1.statement_end_offset END - s1.statement_start_offset) /2)) AS SQLStatement
-- ,max(s1.last_execution_time),
--  max(s1.execution_count)AS execCount,
--  max(s1.last_execution_time) as execTime,
--  T.LoginName as loginname,
--  T.ObjectID
-- ,'ReportData' FROM ReportData.sys.dm_exec_query_stats s1  
--  CROSS apply ReportData.sys.dm_exec_sql_text(s1.sql_handle) AS s2  
--  inner JOIN ReportData.sys.objects s3 ON ( s2.objectid = s3.OBJECT_ID)   
-- LEFT JOIN   ( Select max(StartTime) as 'StartTime', LoginName, ObjectID
-- from fn_trace_gettable('D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Log\log.trc', default)
-- group by LoginName, ObjectID  ) t on  s3.OBJECT_ID = t.ObjectID)  group by T.ObjectID,s3.name,T.LoginName,s3.TYPE,(SUBSTRING(TEXT,(s1.statement_start_offset+2)/2,  (CASE WHEN s1.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),TEXT))*2 
--ELSE s1.statement_end_offset END - s1.statement_start_offset) /2)) co  where sql_Statement = co.SQLStatement and  obj_Name =co.s3.ObjName 

--SET @SQL1 = 'update  tbl_ObjectUsageReport  set exec_count = exec_count + co.execCount , date_LastExecution = co.execTime,lastLoginName = co.loginname FROM 
-- (SELECT distinct s3.name AS ObjName, 
-- (SUBSTRING(TEXT,(s1.statement_start_offset+2)/2,  (CASE WHEN s1.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),TEXT))*2 
--ELSE s1.statement_end_offset END - s1.statement_start_offset) /2)) AS SQLStatement
--, max(s1.last_execution_time)
--  ,max(s1.execution_count)AS execCount, max(s1.last_execution_time) as execTime,T.LoginName as loginname,''' + @name +  ''' FROM ' + @name + '.sys.dm_exec_query_stats s1
--CROSS apply ' + @name + '.sys.dm_exec_sql_text(s1.sql_handle) AS s2
--inner JOIN '+ @name + '.sys.objects s3 ON ( s2.objectid = s3.OBJECT_ID) 
--LEFT JOIN 
--(
--Select max(StartTime) as ''StartTime'', LoginName   from fn_trace_gettable(''' + @base_tracefilename + ''', default) group by LoginName, ObjectID
--) t on  s3.OBJECT_ID = t.ObjectID ) CO
--where sql_Statement = co.SQLStatement and  obj_Name =co.s3.ObjName'

SET @SQL = 'INSERT INTO #TempTbl(obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName, objectid,dataBaseName)  SELECT distinct  s3.name AS [Obj Name]
, s3.TYPE AS [Obj Type], (SUBSTRING(TEXT,(s1.statement_start_offset+2)/2,  (CASE WHEN s1.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),TEXT))*2 
ELSE s1.statement_end_offset END - s1.statement_start_offset) /2)) AS [SQL Statement]
, max(s1.execution_count)
, max(s1.last_execution_time)
,T.LoginName
,T.ObjectID
,''' + @name +
 ''' FROM ' + @name + '.sys.dm_exec_query_stats s1
CROSS apply ' + @name + '.sys.dm_exec_sql_text(s1.sql_handle) AS s2
inner JOIN '+ @name + '.sys.objects s3 ON ( s2.objectid = s3.OBJECT_ID) 
LEFT JOIN 
(
Select max(StartTime) as ''StartTime'', LoginName, ObjectID   from fn_trace_gettable(''' + @base_tracefilename + ''', default) group by LoginName, ObjectID
) t on  s3.OBJECT_ID = t.ObjectID 
where T.ObjectID <> 165575628   and s2.dbid = DB_ID(''' +  @name + ''')  group by T.ObjectID,s3.name,T.LoginName,s3.TYPE,(SUBSTRING(TEXT,(s1.statement_start_offset+2)/2,  (CASE WHEN s1.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),TEXT))*2 
ELSE s1.statement_end_offset END - s1.statement_start_offset) /2)) order by s3.name' 
Exec(@SQL)

--insert into  #TempTbl(obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName, objectid,dataBaseName) 
--select so.name as obj_Name,so.type_desc as obj_Type, null, mt.execcount as exec_count, mt.execdate as date_LastExecution ,null, mt.object_id as objectid ,'ReportData' 
--From  (select object_id , max(execcount)  as execcount,  max(execdate) as execdate from  (select object_id as object_id, max(user_seeks) as useek, max(user_scans) as uscan,
--max(user_lookups) as ulook, max(last_user_seek) as luseek,   max(last_user_scan) as luscan, max(last_user_lookup) as lulook, max(last_user_update) as luupdate
--from ReportData.sys.dm_db_index_usage_stats  group by object_id)  dt  unpivot(execcount for counts in  (useek,uscan,ulook) ) as scan  
--unpivot (execdate for dates in (luseek,luscan, lulook, luupdate )) as dates  group by object_id) mt 
--inner join  ReportData.sys.objects so on (so.object_id = mt.object_id ) WHERE mt.object_id not in (select tt.objectid from #TempTbl tt) 
--select * from #TempTbl
BEGIN TRY  
	begin tran;
	update tbl_ObjectUsageReport set exec_count = tbl_ObjectUsageReport.exec_Count + tt.exec_Count, tbl_ObjectUsageReport.date_LastExecution = tt.date_LastExecution,tbl_ObjectUsageReport.lastLoginName = tt.lastLoginName FROM (select * from #TempTbl) tt where tbl_ObjectUsageReport.sql_Statement = tt.SQL_Statement and  tbl_ObjectUsageReport.obj_Name =tt.Obj_Name and tbl_ObjectUsageReport.dataBaseName = tt.dataBaseName 
	SELECT @@rowcount
	if   (@@rowcount = 0)
	begin
	INSERT INTO tbl_ObjectUsageReport(obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName, objectid,dataBaseName)  SELECT obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName, objectid,dataBaseName from  #TempTbl
	END   
	commit tran;
   -- Execute e;rror retrieval routine.  
END TRY
BEGIN CATCH  
	Select  ERROR_MESSAGE();
END CATCH   

FETCH NEXT FROM db_cursor INTO @name
END	
Close db_cursor
DEALLOCATE  db_cursor
END
GO
