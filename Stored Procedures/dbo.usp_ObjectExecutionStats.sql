SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************
--Description:					Audit report finding how many times the object has been used till now and when was it last used and by whom
SQL job agent runs this procedure every day at 11 P.M 
--Dependencies:					MASTER.dbo.sysdatabases - Description of all objects for given database
							   --sys.dm_exec_query_stats - ToGet the query statistics
							   --sys.dm_exec_sql_text(s1.sql_handle) - to find the sql statement run for th object 
							   --sys.objects - Get the descriptive name of objects 
			     				--fn_trace_gettable(@base_tracefilename) - this file keeps the object execution trace used according to cache policy 
						Physical Table to insert/Update Data: tbl_ObjectUsageReport
--SSRS report ref				Report Server Admin/Audit Reports/ObjectUsageReport -- for linked report
--Parameters:													                
--Sample Execution:			
DECLARE	@return_value int
EXEC	@return_value = [dbo].[usp_ObjectExecutionStats]
SELECT	'Return Value' = @return_value
GO							
****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		14 Dec	2016		 	Stuty(Bulbul)			Initial Creation
*****************************************************************************************************************/
CREATE PROCEDURE [dbo].[usp_ObjectExecutionStats]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
-- needs to use database name and scan through all individual databases 
-- login name corrosponding to the objects 
 ---SQL Server from time to time will remove execution plans from memory, if the cached plan is not being actively used.
 --- Therefore the statistics stored for a particular SP maybe for an accumulation of stats since SQL Server started, if the SP has only be compiled once.-
-- Or, it may only have statistics for the last few minutes if the SP had recently been compiled.
DECLARE @name NVARCHAR(50)
DECLARE @db_name1 NVARCHAR(50)
DECLARE @sql NVARCHAR(MAX)
DECLARE @sql1 NVARCHAR(MAX)
DECLARE @sql2 NVARCHAR(MAX)
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
DECLARE db_cursor CURSOR FOR  SELECT name FROM MASTER.dbo.sysdatabases WHERE name NOT IN ('master','model','msdb','tempdb','ReportServer','ReportServerTempDB','CTSI_Staging','tempCTSI_R','tempCTSI_S','tempCTSI_M') 
--truncate table  tbl_ObjectUsageReport;

CREATE TABLE #TempTbl 
( 
obj_Name varchar(max)
,obj_Type varchar(max)
,sql_Statement varchar(max)
,exec_count varchar(max)
,date_LastExecution dateTIME 
,lastLoginName varchar(max)
,objectid bigint
,dataBaseName varchar(max)
--,operations varchar(max)
--reationdate datetime
)-- selects the database name

OPEN db_cursor 
--DECLARE @Results TABLE(typedesc nvarchar(max) ,schemanames  nvarchar(max)  , tableNames  nvarchar(max) )
FETCH NEXT FROM db_cursor INTO @name
While @@FETCH_STATUS = 0
BEGIN

--truncate table  #TempTbl
--select  @name
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
--select @SQL

--SET @SQL = 'INSERT INTO #TempTbl(obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName, objectid,dataBaseName)  SELECT distinct  s3.name AS [Obj Name]
--, s3.TYPE AS [Obj Type], (SUBSTRING(TEXT,(s1.statement_start_offset+2)/2,  (CASE WHEN s1.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),TEXT))*2 
--ELSE s1.statement_end_offset END - s1.statement_start_offset) /2)) AS [SQL Statement]
--, s1.execution_count
--, max(s1.last_execution_time)
--,T.LoginName
--,T.ObjectID
--,''' + @name +
-- ''' FROM ' + @name + '.sys.dm_exec_query_stats s1
--CROSS apply ' + @name + '.sys.dm_exec_sql_text(s1.sql_handle) AS s2
--inner JOIN '+ @name + '.sys.objects s3 ON ( s2.objectid = s3.OBJECT_ID) 
--LEFT JOIN 
--(
--Select max(StartTime) as ''StartTime'', LoginName, ObjectID   from fn_trace_gettable(''' + @base_tracefilename + ''', default) group by LoginName, ObjectID
--) t on  s3.OBJECT_ID = t.ObjectID 
--where T.ObjectID <> 165575628   and s2.dbid = DB_ID(''' +  @name + ''')  group by T.ObjectID,s1.execution_count,s3.name,T.LoginName,s3.TYPE,(SUBSTRING(TEXT,(s1.statement_start_offset+2)/2,  (CASE WHEN s1.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),TEXT))*2 
--ELSE s1.statement_end_offset END - s1.statement_start_offset) /2)) order by s3.name' 
--select @SQL
Exec(@SQL)

set @SQL1 = 'insert into  #TempTbl(obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName, objectid,dataBaseName)
select so.name as obj_Name,so.type_desc as obj_Type, ''NO SQL AVAILABLE - DATA FROM INDEX USAGE STATS'',
mt.execcount as exec_count, mt.execdate as date_LastExecution ,''NA'', mt.object_id as objectid ,''' + @name + '''
From 
(select object_id , max(execcount)  as execcount,  max(execdate) as execdate from
(select object_id as object_id, max(user_seeks) as useek, max(user_scans) as uscan, max(user_lookups) as ulook, max(last_user_seek) as luseek, 
max(last_user_scan) as luscan, max(last_user_lookup) as lulook, max(last_user_update) as luupdate from '  + @name + '.sys.dm_db_index_usage_stats  group by object_id)  dt
unpivot(execcount for counts in  (useek,uscan,ulook) ) as scan
unpivot (execdate for dates in (luseek,luscan, lulook, luupdate )) as dates
where object_id not in (select tt.objectid from #TempTbl tt)
group by object_id) mt
inner join  '+ @name + '.sys.objects so on (so.object_id = mt.object_id )  '

--set @SQL1 = 'insert into  #TempTbl(obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName, objectid,dataBaseName)

--select so.name as obj_Name,so.type_desc as obj_Type, ''NO SQL AVAILABLE - DATA FROM INDEX USAGE STATS'',
--mt.execcount as exec_count, mt.execdate as date_LastExecution ,''NA'', mt.object_id as objectid ,''' + @name + '''
--From
--(select object_id , execcount  as execcount,  max(execdate) as execdate from

--(select object_id as object_id, max(execcount), max(last_user_seek) as luseek, 
--max(last_user_scan) as luscan, max(last_user_lookup) as lulook, max(last_user_update) as luupdate from '  + @name + '.sys.dm_db_index_usage_stats 

--unpivot(execcount for counts in  (useek,uscan,ulook) ) as scan
--group by object_id)  dt

--unpivot (execdate for dates in (luseek,luscan, lulook, luupdate )) as dates
--group by object_id) mt

--inner join  '+ @name + '.sys.objects so on (so.object_id = mt.object_id ) WHERE mt.object_id not in (select tt.objectid from #TempTbl tt) '

--select @SQL1

Exec(@SQL1)

-- assuming that cache plan keeps a day data
SET @SQL2 =  'insert into  #TempTbl(obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName, objectid,dataBaseName)
SELECT   name AS obj_Name , cp.objtype AS obj_Type, ''CACHEPLANS--''+ ct.text as sql_Statement, cp.usecounts AS execcount,isnull(sp.last_execution_time, GetDate()), ''NA'', ct.objectid, ''' + @name + '''
	
	FROM '+ @name + '.sys.dm_exec_cached_plans cp
	OUTER APPLY '+ @name + '.sys.dm_exec_sql_text(plan_handle) AS ct
	inner JOIN '+ @name + '.sys.objects s3 ON ( ct.objectid = s3.OBJECT_ID)
	left JOIN '+ @name + '.sys.dm_exec_procedure_stats sp ON ( sp.object_id = ct.objectid)
	where   ct.objectid not in (select tt.objectid from #TempTbl tt) and db_name(ct.dbid) = ''' + @name + ''''
	
Exec(@SQL2)
FETCH NEXT FROM db_cursor INTO @name
END	
Close db_cursor
DEALLOCATE  db_cursor
------select @SQL1

BEGIN TRY  
BEGIN TRAN TranA
MERGE INTO tbl_ObjectUsageReport AS TU 
USING (SELECT obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution,lastLoginName,objectid,dataBaseName  FROM #TempTbl) TT
-- Check the last execution to confirm if the t count is to be 
ON ((TU.sql_Statement = TT.SQL_Statement) and  (TU.obj_Name =TT.Obj_Name) and (TU.dataBaseName = TT.dataBaseName))
WHEN MATCHED  AND ((TU.date_LastExecution < TT.date_LastExecution))THEN
UPDATE
SET TU.exec_count = TU.exec_Count +(tt.exec_Count - TU.exec_Count),
TU.date_LastExecution = tt.date_LastExecution,
TU.lastLoginName = tt.lastLoginName,
TU.operations = 'update'
WHEN NOT MATCHED BY TARGET  then --objectid not in (select distinct objectid from #TempTbl) THEN 
INSERT(obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName,objectid,dataBaseName,operations,creationdate ) VALUES
(TT.obj_Name,TT.obj_Type,TT.sql_Statement,TT.exec_count,TT.date_LastExecution,TT.lastLoginName, TT.objectid,TT.dataBaseName,'insert', getdate());

commit tran TranA;
END TRY
BEGIN CATCH  
	PRINT ERROR_MESSAGE();
END CATCH;

--IF XACT_STATE() =0
--BEGIN
--COMMIT TRAN TranA
--END
--ELSE
--BEGIN
--ROLLBACK TRAN TranA
--END
--select * from #TempTbl
--select * from ReportData.sys.dm_exec_query_stats
--SELECT obj_Name,obj_Type,sql_Statement,exec_count,date_LastExecution, lastLoginName, objectid,dataBaseName , 'insert', getdate() as creationdate  from  #TempTbl

 
END
GO
