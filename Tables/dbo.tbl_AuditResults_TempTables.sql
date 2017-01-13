CREATE TABLE [dbo].[tbl_AuditResults_TempTables]
(
[typedesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schemanames] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjectName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[objectid] [int] NULL,
[ID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_AuditResults_TempTables] ADD CONSTRAINT [PK_tbl_AuditResults_TempTables] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
