SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************
--Description:					Audit report for all dependent objects to each other
--Dependencies:					sys.objects - Description of all objects for given database
								sys.sql_expression_dependencies - All the dependent objects for given object ID 
							Calls linked reports : DependentRefrencedObjects and Dependent Reports
							
--SSRS report ref				Report Server Admin/Audit Reports/Dependent Objects
--Parameters:													                
--Sample Execution:			
DECLARE	@return_value int
EXEC	@return_value = [dbo].[usp_FindDependentObjects]
		@datbaseName = N'ReportData'
	
SELECT	'Return Value' = @return_value
GO							
****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		12 Dec	2016		 	stuty(bulbul)			Initial Creation
*****************************************************************************************************************/
CREATE PROCEDURE [dbo].[usp_FindDependentObjects]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @sql nvarchar(max)
	DECLARE @name NVARCHAR(50)
	--DECLARE @db_name1 NVARCHAR(50)
	--declare @databaseName  nvarchar(100)
		--SET @databaseName = 'ReportData'
    -- Insert statements for procedure here
truncate table dbo.tbl_DependentObjects
DECLARE db_cursor CURSOR FOR  SELECT name FROM MASTER.dbo.sysdatabases WHERE name NOT IN ('master','model','msdb','tempdb','SelfVerification' ,'ReportServer', 'ReportServerTempDB') 
-- selects the database name
OPEN db_cursor 
--DECLARE @Results TABLE(typedesc nvarchar(max) ,schemanames  nvarchar(max)  , tableNames  nvarchar(max) )
FETCH NEXT FROM db_cursor INTO @name  

While @@FETCH_STATUS = 0
BEGIN

set @sql = 'insert into dbo.tbl_DependentObjects(referencingID,referencingObjName,objType, referencedDB,referencedSchema,referencedObjName,referencedID,refrencedObjTyp) SELECT  referencing_id as [ReferencingID] , s.name as  [ReferencingObjectName], s.type_desc as [ObjectType],'''+  @name + 
 ''' as [ReferencedDataBase], referenced_schema_name as [ReferencedSchema],  referenced_entity_name AS [ReferencedObjectName], referenced_id as [ReferencedID] , so.type_desc as [RefObjectType] FROM ' +  @name +'.sys.sql_expression_dependencies d inner join ' + @name + '.sys.objects s on (d.referencing_id = s.object_id)
 inner join ' + @name + '.sys.objects so on (d.referenced_id = so.object_id)
  order by s.type'
--select @sql
 EXECUTE(@sql)
 FETCH NEXT FROM db_cursor INTO @name
END	
Close db_cursor
DEALLOCATE  db_cursor
 select distinct a.* from (select  referencingID,referencingObjName,objType, referencedDB,referencedSchema,referencedObjName,referencedID,refrencedObjTyp,DE.LoginName as [ReferencingObjOwner],DEve.loginName as [ReferencedObjOwner]      from dbo.tbl_DependentObjects DO
left join  (select distinct loginName,ObjectName  from  dbo.DDLEvents)  DE on  (Rtrim(Ltrim(referencingObjName)) = DE.ObjectName)
left join  (select distinct loginName,ObjectName  from  dbo.DDLEvents)  DEve on  (Rtrim(Ltrim(referencedObjName)) =  DEve.ObjectName)) a 

--use ReportData
--select * from ReportData.sys.sql_expression_dependencies where referencing_id = 913490383
--select * from ReportData.sys.objects 


END
GO
