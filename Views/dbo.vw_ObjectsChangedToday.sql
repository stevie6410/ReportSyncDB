SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_ObjectsChangedToday]
AS
SELECT TOP 100000 * FROM vw_Objects WHERE LastModified >= CAST(GETDATE() AS DATE) ORDER BY LastModified
GO
