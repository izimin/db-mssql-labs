--CREATE DATABASE _lab
--GO
--USE _lab
--GO
------------------------------------------------------------�������-------------------------------------------------------------------------------------------
-- �������� ������� ���� 
CREATE TABLE [Books]
(
	id_book int				  NOT NULL,
	Author	nvarchar(50)	  NOT NULL,
	Name	nvarchar(50)	  NOT NULL, 
)
GO
-- �������� ������� ��������� 
CREATE TABLE Readers
(
	id_reader int				NOT NULL,
	FIO		  nvarchar(50)		NOT NULL,
	[Address] nvarchar(50)		NOT NULL,
) 
GO

CREATE PROCEDURE TwinTables
AS
BEGIN
		-- ��� ������� �������
		DECLARE @nameCurTable nvarchar(50) = ''
		-- ����� � ��� ���������� ���������� ������� (�������� ������/�����/���������)
		, @query nvarchar(MAX) = ''
		-- ������ ��� ������� �� ��������
		, @cursorForTable  CURSOR 

		-- � ������� ����� ����� ���� ������ �� ������� �� (STATIC �������� ������� ����� ������ ��� �������, ��������� ������� ������ �� ����� ������)
		SET @cursorForTable =  CURSOR STATIC FOR SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
		OPEN @cursorForTable
		-- ����� �������� ������ ������� 
		FETCH NEXT FROM @cursorForTable INTO @nameCurTable
		-- ���� ��� �� � ������� ����
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- ������� � ���������� ��� ��� ����� ������� 
			DECLARE @nameNewTable nvarchar(50) = 'twin'+@nameCurTable
			-- ���������� ��� ������������ ��������
			, @columnsStr nvarchar(MAX)  = ''
			, @columName nvarchar(50)
			-- ������ ��� ������� �� �������� ������� �������
			, @cursorForColumns CURSOR

			-- �������� ��� �� �������� �������� � ����� ������ ����� ��������� (���� �� � ��� ���������, �� ����)
			IF EXISTS (SELECT * FROM sys.objects WHERE name = @nameNewTable)
				SET @nameCurTable += CAST(NEWID() AS nvarchar(36))

			SET @cursorForColumns =  CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME  = @nameCurTable 
			OPEN @cursorForColumns
			FETCH NEXT FROM @cursorForColumns INTO @columName
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- ���������� ��������� �������
				SET @columnsStr += '[' +@columName + '], '
				FETCH NEXT FROM @cursorForColumns INTO @columName
			END
			CLOSE @cursorForColumns

			-- ������ ����� ������� �������
			SET @query = 'SELECT * INTO [' + @nameNewTable + '] FROM [' + @nameCurTable +']'
			EXEC sp_executesql @query

			-- ��������� ������� ������������, �������� ���������
			SET @query = 'ALTER TABLE [' + @nameNewTable + '] ADD [user] nvarchar(50) NOT NULL CONSTRAINT [DF_'+@nameNewTable+'_USER]  DEFAULT (SUSER_NAME())'
			EXEC sp_executesql @query
			-- ��������� ������� ���� ���������
			SET @query = 'ALTER TABLE [' + @nameNewTable + '] ADD [date] datetime NOT NULL CONSTRAINT [DF_'+@nameNewTable+'_DATE]  DEFAULT (getdate())'
			EXEC sp_executesql @query
			-- ��������� ������� ���� �����������
			SET @query = 'ALTER TABLE [' + @nameNewTable + '] ADD [type] nvarchar(50) NOT NULL '
			EXEC sp_executesql @query
			
			-- ������� ��� �������
			SET @query = 'CREATE TRIGGER INSERTtrig'+ @nameNewTable +' ON '+ QUOTENAME(@nameCurTable) +'
			AFTER INSERT
			AS
			BEGIN 
				INSERT INTO ['+@nameNewTable+']('+@columnsStr + 'type) SELECT '+@columnsStr + char(39)+'INSERT'+char(39)+' FROM inserted 
			END'
			EXEC sp_executesql @query

			-- ������� ��� ����������
			SET @query = 'CREATE TRIGGER UPDATEtrig'+ @nameNewTable +' ON '+ QUOTENAME(@nameCurTable) +'
			AFTER UPDATE
			AS
			BEGIN 
				INSERT INTO ['+@nameNewTable+']('+@columnsStr + 'type) SELECT '+@columnsStr + char(39)+'UPDATE'+char(39)+' FROM inserted 
			END'
			EXEC sp_executesql @query

			-- ������� ��� ��������
			SET @query = 'CREATE TRIGGER [DELETEtrig'+ @nameNewTable +'] ON '+ QUOTENAME(@nameCurTable) +'
			AFTER DELETE
			AS
			BEGIN 
				INSERT INTO ['+@nameNewTable+']('+@columnsStr + 'type) SELECT '+@columnsStr + char(39)+'DELETE'+char(39)+' FROM deleted
			END'
			EXEC sp_executesql @query

			FETCH NEXT FROM @cursorForTable INTO @nameCurTable
		END
		CLOSE @cursorForTable
END
GO 

EXEC TwinTables
GO

-- �����
CREATE PROCEDURE SHOW 
AS
BEGIN
    SELECT * FROM Books
	SELECT * FROM Readers
	SELECT * FROM twinBooks
	SELECT * FROM twinReaders
END
GO

-- ������� ������ ��������
INSERT INTO Books(id_book, Author, name) VALUES (1, 'ss', 'r')

-- ������� ���������� ��������
INSERT INTO Readers(id_reader, FIO, Address) VALUES (1,'ss', 'r'), (2,'ssw', 'rw')

EXECUTE ('SHOW')

-- ���������� ������ ��������
UPDATE Books SET name = 'rr'

-- ���������� ���������� 
UPDATE Readers SET FIO += 'p'

EXECUTE ('SHOW')

-- �������� ������
DELETE FROM Books WHERE id_book = 1

-- �������� ����������
DELETE FROM Readers

EXECUTE ('SHOW')


DROP TABLE Books
DROP TABLE Readers
DROP TABLE twinBooks
DROP TABLE twinReaders
DROP PROCEDURE TwinTables
DROP PROCEDURE SHOW
