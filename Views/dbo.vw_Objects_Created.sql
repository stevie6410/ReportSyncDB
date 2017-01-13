SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--SELECT * FROM vw_Objects_Dropped

CREATE VIEW [dbo].[vw_Objects_Created]
AS

WITH [Events] AS
(
    SELECT
        EventDate,
		EventType,
        DatabaseName,
        SchemaName,
        ObjectName,
        EventDDL,
		LoginName,
        rnLatest = ROW_NUMBER() OVER 
        (
            PARTITION BY DatabaseName, SchemaName, ObjectName
            ORDER BY     EventDate DESC
        ),
        rnEarliest = ROW_NUMBER() OVER
        (
            PARTITION BY DatabaseName, SchemaName, ObjectName
            ORDER BY     EventDate
        ),
		rnLoginName = ROW_NUMBER() OVER
		(
			PARTITION BY DatabaseName, SchemaName, ObjectName
			ORDER BY EventDate
		)
    FROM
        AuditDB.dbo.DDLEvents
)

SELECT
    Original.DatabaseName,
    Original.SchemaName,
    Original.ObjectName,
	NewestEventType = COALESCE(Newest.EventType, Original.EventType),
	Original.EventDate AS CreatedOn,
	Original.LoginName AS CreatedBy,
    LastModified = COALESCE(Newest.EventDate, Original.EventDate),
	LastModifiedBy = COALESCE(Newest.LoginName, Original.LoginName)
FROM
    [Events] AS Original
LEFT OUTER JOIN
    [Events] AS Newest
    ON  Original.DatabaseName = Newest.DatabaseName
    AND Original.SchemaName   = Newest.SchemaName
    AND Original.ObjectName   = Newest.ObjectName
    AND Newest.rnEarliest = Original.rnLatest
    AND Newest.rnLatest = Original.rnEarliest
    AND Newest.rnEarliest > 1
WHERE
		Original.rnEarliest = 1
	AND COALESCE(Newest.EventType, Original.EventType) LIKE 'CREATE_%'
GO
