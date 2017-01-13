SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************
--Description:					Gets the dependent  objects  by passing the object name and databasename
--Dependencies:				    tbl_DependentObjects


****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		05 Dec	2017		 	stuti(Bulbul)			Initial Creation
*****************************************************************************************************************/
--Select * from tfn_GetDependentObjects('ReportData', 'ufn_GetCost_05_PartNumber_2500001')
CREATE FUNCTION [dbo].[tfn_GetDependentObjects]
(	
	-- Add the parameters for the function here
	@dataBaseName as nvarchar(50),
	@objectName as nvarchar(max)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
-- Search forward 	
	SELECT 
	referencedObjName as 'DependentObjects'
	,referencedID as 'DepenndentObjectID'
	,referencedSchema as 'Schema'
	,refrencedObjTyp   as 'DependentObjectType'
	from tbl_DependentObjects 
	where referencedDB = @databaseName
	and referencingObjName = @objectName
	UNION ALL
--Search |Backward
	SELECT  
	referencingObjName as 'DependentObjects'
	,referencingID as 'DepenndentObjectID'
	,referencedSchema as 'Schema'
	,objType   as 'DependentObjectType'
	from tbl_DependentObjects 
	where referencedDB = @databaseName
	and  referencedObjName = @objectName
	
)

GO
