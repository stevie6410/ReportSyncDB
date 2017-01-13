SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************
--Description:					Gets the list of temperoary objects in a database passed
--Dependencies:					tbl_AuditResults_TempTables: Stores the list of temperoraty objects and repopulates itself
								when the report is run.  
								fn_trace_gettable: to get the login name of the person who last used the object
--SSRS report ref				Report Server Admin/Audit Reports/DependentObjects - Linked procedure accessed through passing the object name by clicking on object Name
--Parameters:													                
--Sample Execution:			
	
SELECT	* from dbo.tfn_ListTempObjectsAndLastUser('ReportData') 
GO							
****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		06 jan	2017		 	stuty(Bulbul)			Initial Creation
*****************************************************************************************************************/
CREATE FUNCTION [dbo].[tfn_ListTempObjectsAndLastUser] 
(	@DataBaseName nvarchar(50)
	-- Add the parameters for the function here
)

RETURNS @RESULTS TABLE 
(
typedesc  nvarchar(100) 
,schemanames nvarchar(50)
,ObjectName nvarchar(100)
,objectid bigint
,ID bigint
,LoginName nvarchar(100)
)

BEGIN
-- Add the SELECT statement with parameter references here
declare @curr_tracefilename varchar(500);
declare @base_tracefilename varchar(500);
declare @indx int ;
select @curr_tracefilename = path from sys.traces where is_default = 1 ;
set @curr_tracefilename = reverse(@curr_tracefilename)
select @indx = PATINDEX('%\%', @curr_tracefilename)
set @curr_tracefilename = reverse(@curr_tracefilename)
set @base_tracefilename = LEFT( @curr_tracefilename,len(@curr_tracefilename) - @indx) + '\log.trc';

INSERT INTO @RESULTS 
SELECT  at.[typedesc] as 'typedesc'
      ,Rtrim(Ltrim(at.[schemanames])) as 'schemanames'
      ,at.[ObjectName] as  'ObjectName'
      ,at.[objectid] as 'objectid'
      ,at.[ID] as 'ID'
		, t.LoginName as 'LoginName' 
FROM [AuditDB].[dbo].[tbl_AuditResults_TempTables] at
 left join
( 
Select max(StartTime) as 'starttime', LoginName, ObjectID   from fn_trace_gettable(@base_tracefilename, default) group by LoginName, ObjectID
) t on  t.ObjectID = at.ObjectID 
where Rtrim(Ltrim(at.[schemanames])) =  @DataBaseName
order by at.typedesc

RETURN 
END
GO
