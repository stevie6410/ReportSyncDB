SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetObjects]
AS

WITH cteObjectChanges AS (
SELECT
	EventDate
   ,EventType
   ,DatabaseName
   ,SchemaName
   ,Type AS ObjectType
   ,ObjectName
   ,HostName
   ,LoginName
   ,Id
   ,ROW_NUMBER() OVER (PARTITION BY SchemaName, ObjectName ORDER BY EventDate DESC) AS RowNum
FROM
	AuditDB.dbo.DDLEvents
)

--SELECT * FROM cteObjectChanges WHERE cteObjectChanges.ObjectName = 'ufn_GetRDYDate_PartNumber_Branch'

SELECT
	*
FROM
	cteObjectChanges
WHERE
	cteObjectChanges.RowNum = 1
GO
