SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************
--Description:					Audit report for all dependent objects/depends which depends on passed objectID as parameter
--Dependencies:					sys.objects - Description of all objects for given database
								sys.sql_expression_dependencies - All the dependent objects for given object ID 
							
							
--SSRS report ref				Report Server Admin/Audit Reports/Dependent Objects -- for linked report
--Parameters:													                
--Sample Execution:			
DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_FindDependentObjectBy_ObjectId]
		@objID = N'254784',
		@databaseName = N'ReportData'

SELECT	'Return Value' = @return_value

GO
						
****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		12 Dec	2016		 	stuti(Bulbul)			Initial Creation
*****************************************************************************************************************/
CREATE PROCEDURE [dbo].[usp_FindDependentObjectBy_ObjectId]
	-- Add the parameters for the stored procedure here
    	(@objID as nvarchar(50), @databaseName as nvarchar(50))
AS
BEGIN
	declare @Sql as nvarchar(max)
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
set @sql = 'Select distinct referencing_id, s.name as [objName] , '''+  @databaseName  + ''' from  ' + @databaseName +
 '.sys.sql_expression_dependencies d inner join ' + @databaseName + '.sys.objects s  on (d.referencing_id = s.object_id) where  referenced_id = ''' +  @objID + '''' 
  exec(@sql)
 -- select  @sql  -- Insert statements for procedure here
 --select * from ReportData.sys.sql_expression_dependencies
	END
GO
