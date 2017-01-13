SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************
--Description:					Gets the dependent report and query on the object  by passing the object name 
--Dependencies:					[ReportServer].[dbo].[tbl_SSRS_CommandText_Details] - populates itself through running job agent every day. Data extracted directly. 
								
--SSRS report ref				Report Server Admin/Audit Reports/DependentObjects - Linked procedure accessed through passing the object name by clicking on object Name
--Parameters:													                
--Sample Execution:			
select * from 	dbo.tfn_ObjectDependentReports('')				
****************************************************************************************************
** Change History
****************************************************************************************************
** SR   Date					Author				Description	
** --   --------				-------				------------------------------------
*		12 Dec	2016		 	stuty(Bulbul)			Initial Creation
*****************************************************************************************************************/
CREATE FUNCTION [dbo].[tfn_ObjectDependentReports]
(	
	-- Add the parameters for the function here
	@ObjectName as nvarchar(max)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	

	Select distinct scd.Name as ReportName, scd.[Path] as ReportPathLocation, scd.CommandText as CommandText, scd.CommandType as CommandType, scd.TypeDescription as TypeDescription, sd.CreatedBy  as [CreatedBy],scd.ItemID as [ReportID], sd.SubscriptionOwner as [SubscriptionOwner],sd.Too  as [user] from [ReportServer].[dbo].[tbl_SSRS_CommandText_Details] scd
	left join (select distinct vs.too, vr.createdBy,vs.SubscriptionOwner , vr.ReportID     FROM [ReportServer].[dbo].[vw_SubscriptionDetails] vs right join  [ReportServer].[dbo].[vw_Reports] vr on vr.Path = vs.ReportPath ) sd  on (sd.ReportID  = scd.ItemID) 
	
	
	-- [ReportServer].[dbo].[vw_Reports] vr on (vr.ReportID  =scd.ItemID)
	--left join [ReportServer].[dbo].[vw_SubscriptionDetails]  vsd on (vsd.ReportPath =scd.Path )
	where  CommandText like '%' + @ObjectName  + '%'

)
GO
