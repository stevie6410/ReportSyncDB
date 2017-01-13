SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--SELECT * FROM dbo.vw_Metrics_DDLEvents AS vmde

CREATE VIEW [dbo].[vw_Metrics_DDLEvents]
AS

  SELECT
		CAST(Events.EventDate AS DATE) AS EventDate
	   ,Events.EventDate AS EventDateTime
	   ,Events.EventType
	   ,dbo.ufn_EventDescription(Events.EventType) AS EventDesc
	   ,Events.DatabaseName
	   ,Events.SchemaName
	   ,Events.Type
	   ,dbo.ufn_ObjectDescription(Events.Type) AS TypeDesc
	   ,Events.ObjectName
	   ,Events.HostName
	   ,Events.IPAddress
	   ,Events.ProgramName
	   ,Events.LoginName
	FROM
		AuditDB.dbo.DDLEvents AS Events
GO
