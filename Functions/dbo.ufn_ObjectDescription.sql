SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ufn_ObjectDescription](@ObjectName VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
    RETURN CASE @ObjectName
		WHEN 'SQL_SCALAR_FUNCTION' THEN 'Scalar Function'
		WHEN 'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 'Table Function'
		WHEN 'SQL_STORED_PROCEDURE' THEN 'Stored Procedure'
		WHEN 'CLR_STORED_PROCEDURE' THEN 'CLR Stored Procedure'
		WHEN 'SYNONYM' THEN 'Synonym'
		WHEN 'SQL_TABLE_VALUED_FUNCTION' THEN 'Table Function'
		WHEN 'VIEW' THEN 'View'
		WHEN 'USER_TABLE' THEN 'Table'
		ELSE @ObjectName
	END
END


GO
