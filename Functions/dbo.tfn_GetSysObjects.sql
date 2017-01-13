SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************
--Description:					Gets the dependent report and query on the object  by passing the object name 
--Dependencies:				    reportdata.sys.all_objects

-- select * from dbo.tfn_GetSysObjects()
****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		05 Dec	2017		 	stuti(Bulbul)			Initial Creation
*****************************************************************************************************************/
CREATE FUNCTION [dbo].[tfn_GetSysObjects]
(	
	-- Add the parameters for the function here

)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select distinct type,type_desc from reportdata.sys.all_objects
)
GO
