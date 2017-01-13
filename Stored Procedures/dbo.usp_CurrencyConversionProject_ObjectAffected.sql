SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_CurrencyConversionProject_ObjectAffected]
AS


DECLARE @ObjectReports AS TABLE(
	[ObjectDB] [nvarchar](255) NULL,
	[ObjectSchema] [nvarchar](255) NULL,
	[ObjectType] [nvarchar](100) NULL,
	[ObjectName] [nvarchar](255) NULL,
	[CurrencyFieldMatch] [varchar](4) NOT NULL,
	[ReportName] [nvarchar](425) NULL,
	[ReportPath] [nvarchar](455) NULL,
	[ReportCommandType] [nvarchar](1024) NULL,
	[ReportCommandText] [nvarchar](max) NULL
)

INSERT INTO
	@ObjectReports
SELECT
	O.DatabaseName AS ObjectDB
   ,O.SchemaName AS ObjectSchema
   ,O.Type AS ObjectType
   ,O.ObjectName AS ObjectName
   ,O.Keyword AS CurrencyFieldMatch
   ,SSRS.Name AS ReportName
   ,SSRS.Path AS ReportPath
   ,SSRS.CommandType AS ReportCommandType
   ,SSRS.CommandText AS ReportCommandText
FROM
	AuditDB.dbo.tbl_CC_Objects AS O
LEFT OUTER JOIN
	ReportServer.dbo.tbl_SSRS_CommandText_Details AS SSRS ON (SSRS.CommandText COLLATE DATABASE_DEFAULT LIKE ('%' + O.ObjectName + '%'))

SELECT DISTINCT
    ObjectReport.ObjectName AS Name
   ,ObjectReport.ObjectSchema AS Path
   ,ObjectReport.ObjectType AS Type
   ,(SELECT DISTINCT COALESCE(ObjR.CurrencyFieldMatch+', ', '') 
	 FROM @ObjectReports AS ObjR
     WHERE ReportName IS NULL AND ObjR.ObjectName = ObjectReport.ObjectName
	 FOR XML PATH('')) AS CurrencyField
FROM
	@ObjectReports AS ObjectReport
WHERE
	ReportName IS NULL

UNION ALL

SELECT DISTINCT
    ObjectReport.ReportName AS Name
   ,ObjectReport.ReportPath AS Path
   ,'SSRS Report' AS Type
   ,(SELECT DISTINCT COALESCE(ObjR.CurrencyFieldMatch+', ', '') 
	 FROM @ObjectReports AS ObjR
     WHERE ReportName IS NOT NULL AND ObjR.ReportName = ObjectReport.ReportName
	 FOR XML PATH('')) AS CurrencyField
FROM
	@ObjectReports AS ObjectReport
WHERE
	ObjectReport.ReportName IS NOT NULL

				    	
GO
