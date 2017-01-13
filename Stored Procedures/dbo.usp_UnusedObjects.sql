SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************
--Description:					Audit report for all unused object which are not in recent index usage stats
--Dependencies:					sys.all_objects - Description of all objects for given database
								tbl_ObjectUsageReport: gives the usage and execution count of the objects
								
							 ReportData.sys.dm_exec_cached_plans : To check if object exists in current cache plans
							 ReportData.sys.dm_exec_sql_text(cp.plan_handle)
--SSRS report ref				Report Server Admin/Audit Reports/UnUsedObjects
--Parameters:													                
--Sample Execution:			
DECLARE	@return_value int
EXEC	@return_value = [dbo].[usp_UnusedObjects]
		@datbaseName = N'ReportData'
SELECT	'Return Value' = @return_value
GO							
****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		09 Dec	2016		 	Stuty (Bulbul)			Initial Creation
*****************************************************************************************************************/
CREATE PROCEDURE [dbo].[usp_UnusedObjects]
	-- Add the parameters for the stored procedure here
	(@datbaseName as nvarchar(100)
	,@notusedMonths as char)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @qyery as nvarchar(max)
	--set  @qyerytable = @datbaseName + '.sys.all_objects'
    -- Insert statements for procedure here
	-- use reportdata
	set @qyery = ' SELECT   DISTINCT     
       ao.[name] [ObjName],
	   ao.[type] [ObjectType],
       ao.[type_desc] [Typedesc],
       ao.[create_date] [Created],
       ao.[modify_date] [LastModified],
	   our.[date_LastExecution] [LastExecutionDate],
	   ao.OBJECT_ID
    FROM ' +
        @datbaseName + '.sys.all_objects   ao 
		left join tbl_ObjectUsageReport our on (our.objectid = ao.OBJECT_ID)
	     WHERE 
		ao.OBJECT_ID NOT IN (
SELECT OBJECT_ID from (select OBJECT_ID , max(execdate) as execdate from
(select object_id as object_id,  max(last_user_seek) as luseek, max(last_user_scan) as luscan, max(last_user_lookup) as lulook, 
    max(last_user_update) as luupdate from ReportData.sys.dm_db_index_usage_stats  group by object_id)  dt  
	 unpivot (execdate for dates in (luseek,luscan, lulook, luupdate )) as dates  group by object_id) mt 
              WHERE mt.execdate > DATEADD(month, -'+@notusedMonths +', GETDATE())
      
			  union 
			  select distinct t.objectid as [OBJECT_ID] from ReportData.sys.dm_exec_cached_plans  cp CROSS APPLY ' +@datbaseName + '.sys.dm_exec_sql_text(cp.plan_handle) t where t.objectid is not null
    	 union 
		 select objectid as  [OBJECT_ID] from tbl_ObjectUsageReport where date_LastExecution > DATEADD(month, -'+@notusedMonths+', GETDATE())
		    )
		
		 and  ao.[modify_date] < DATEADD(month, -'+@notusedMonths+', GETDATE())
		  and  (ao.[name] not like ''sys%'' and 
			ao.[name] not like ''service%'' and ao.[name] not like ''xml%'' and ao.[name] not like ''sp_%'' and  ao.[name] not like ''server_%'' and  ao.[name] not like ''resource_%''  and  ao.[name] not like ''trace_%'' and  ao.[name] not like ''database_%'' and  ao.[name] not like ''xp_%'' and  ao.[name] not like ''fulltext%'' and  ao.[name] not like ''queue%''  and ao.[name] not like ''dm_%'') and ao.[type] <> ''SN'' 
	    ORDER BY
        ao.[modify_date] DESC'
	--	SELECT @qyery
	--select * from  ReportData.sys.dm_db_index_usage_stats where OBJECT_ID = '1646733019'
	--select *  from sys.all_objects
	--select * from sys.schemas
	 --ao.OBJECT_ID NOT IN (
        --      SELECT OBJECT_ID
        --      FROM ' +@datbaseName + '.sys.dm_db_index_usage_stats
    	   -- )
  -- select @qyery
--SELECT * FROM ReportData.sys.dm_exec_cached_plans 


--  SELECT OBJECT_ID  FROM ' +@datbaseName + '.sys.dm_db_index_usage_stats 
					       
--   (   SELECT OBJECT_ID from (select object_id , max(execdate) as execdate from 

--(select object_id as object_id,  max(last_user_seek) as luseek, max(last_user_scan) as luscan, max(last_user_lookup) as lulook, 
--     max(last_user_update) as luupdate from ReportData.sys.dm_db_index_usage_stats  group by object_id)  dt  
--	 unpivot (execdate for dates in (luseek,luscan, lulook, luupdate )) as dates  group by object_id) mt 
--	              WHERE mt.execdate < DATEADD(month, -6, GETDATE())
EXECUTE(@qyery)
END
GO
