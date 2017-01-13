SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW	[dbo].[vw_CurrencyConversionProject_ReportDataObjects_KeywordSearch]
as

WITH cteObjects AS (
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'CRRD' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%CRRD%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'CRR' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%CRR%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'FAP' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%FAP%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'FCST' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%FCST%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'UPRC' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%UPRC%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'AEXP' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%AEXP%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'AOPN' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%AOPN%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'LPRC' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%LPRC%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'UNCS' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%UNCS%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'ECST' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%ECST%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'FPRC' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%FPRC%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'FUP' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%FUP%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'FEA' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%FEA%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'FUC' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%FUC%'
	UNION ALL
	SELECT DISTINCT DatabaseName, SchemaName ,Type , ObjectName, 'FEC' AS Keyword FROM DDLEvents WHERE EventDDL LIKE '%FEC%'
)

SELECT 
	*
FROM
	cteObjects

GO
