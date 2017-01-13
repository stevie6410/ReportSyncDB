SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************
--Description:					Gets the name of all database
--Dependencies:				    MASTER.dbo.sysdatabases
-- select * from dbo.tfn_GetAllDataBaseNames()
****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		06 Dec	2017		 	stuti(Bulbul)			Initial Creation
*****************************************************************************************************************/
CREATE FUNCTION [dbo].[tfn_GetAllDataBaseNames]
(	
	-- Add the parameters for the function here
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
		SELECT distinct Rtrim(ltrim(name)) as 'name',dbid FROM MASTER.dbo.sysdatabases WHERE name NOT IN ('master','model','msdb','tempdb','ReportServer','ReportServerTempDB','CTSI_Staging','tempCTSI_R','tempCTSI_S','tempCTSI_M') 

)
GO
