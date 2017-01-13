SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--SELECT * FROM vw_Objects WHERE Live = 0

CREATE VIEW [dbo].[vw_Objects]
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
		Id,
		GUID,
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
	Original.Id,
	Original.GUID,
    Original.DatabaseName,
    Original.SchemaName,
    Original.ObjectName,
	LastEventType = COALESCE(Newest.EventType, Original.EventType),
	Original.EventDate AS CreatedOn,
	Original.LoginName AS CreatedBy,
    LastModified = COALESCE(Newest.EventDate, Original.EventDate),
	LastModifiedBy = COALESCE(Newest.LoginName, Original.LoginName),
	CASE WHEN Newest.EventType LIKE 'DROP_%' THEN 0 ELSE 1 END AS Live
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

GO
