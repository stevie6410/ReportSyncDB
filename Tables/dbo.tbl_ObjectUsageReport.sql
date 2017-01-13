CREATE TABLE [dbo].[tbl_ObjectUsageReport]
(
[obj_Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [bigint] NOT NULL IDENTITY(1, 1),
[obj_Type] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sql_Statement] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exec_Count] [int] NULL,
[date_LastExecution] [datetime2] NOT NULL,
[dataBaseName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastLoginName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[objectid] [bigint] NULL,
[operations] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creationdate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_ObjectUsageReport] ADD CONSTRAINT [PK_tbl_ObjectUsageReport] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
