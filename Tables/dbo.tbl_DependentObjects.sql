CREATE TABLE [dbo].[tbl_DependentObjects]
(
[referencingID] [bigint] NOT NULL,
[referencingObjName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[objType] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[referencedDB] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referencedSchema] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referencedObjName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[referencedID] [bigint] NULL,
[id] [bigint] NOT NULL IDENTITY(1, 1),
[comment] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[refrencedObjTyp] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
