CREATE TABLE [dbo].[DDLEvents]
(
[EventDate] [datetime] NOT NULL CONSTRAINT [DF__DDLEvents__Event__7E6CC920] DEFAULT (getdate()),
[EventType] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDDL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventXML] [xml] NULL,
[DatabaseName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchemaName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjectName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HostName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPAddress] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GUID] [uniqueidentifier] NULL,
[Id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[DDLEvents] ADD CONSTRAINT [PK_DDLEvents] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
