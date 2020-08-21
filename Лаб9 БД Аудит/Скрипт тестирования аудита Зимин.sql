--CREATE DATABASE _lab
--GO
--USE _lab
--GO
------------------------------------------------------------ТАБЛИЦЫ-------------------------------------------------------------------------------------------
-- Создание таблицы книг 
CREATE TABLE [Books]
(
	id_book int				  NOT NULL,
	Author	nvarchar(50)	  NOT NULL,
	Name	nvarchar(50)	  NOT NULL, 
)
GO
-- Создание таблицы читателей 
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
		-- Имя текущей таблицы
		DECLARE @nameCurTable nvarchar(50) = ''
		-- Будем в эту переменную складывать запросы (создание таблиц/полей/триггеров)
		, @query nvarchar(MAX) = ''
		-- Курсор для прохода по таблицам
		, @cursorForTable  CURSOR 

		-- В корсоре будут имена всех таблиц из текущей БД (STATIC помогает создать копию данных для курсора, изменение базовых таблиц не будет влиять)
		SET @cursorForTable =  CURSOR STATIC FOR SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
		OPEN @cursorForTable
		-- Берем название первой таблицы 
		FETCH NEXT FROM @cursorForTable INTO @nameCurTable
		-- Пока что то в курсоре есть
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Запишем в переменную имя для новой таблицы 
			DECLARE @nameNewTable nvarchar(50) = 'twin'+@nameCurTable
			-- Переменная для перечисления столбцов
			, @columnsStr nvarchar(MAX)  = ''
			, @columName nvarchar(50)
			-- Курсор для прохода по столбцам текущей таблицы
			, @cursorForColumns CURSOR

			-- Проверим нет ли случайно объектов с таким именем среди имеющихся (Надо бы и для триггеров, но лень)
			IF EXISTS (SELECT * FROM sys.objects WHERE name = @nameNewTable)
				SET @nameCurTable += CAST(NEWID() AS nvarchar(36))

			SET @cursorForColumns =  CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME  = @nameCurTable 
			OPEN @cursorForColumns
			FETCH NEXT FROM @cursorForColumns INTO @columName
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- Поочередно добавляем столбцы
				SET @columnsStr += '[' +@columName + '], '
				FETCH NEXT FROM @cursorForColumns INTO @columName
			END
			CLOSE @cursorForColumns

			-- Создаём копию текущей таблицы
			SET @query = 'SELECT * INTO [' + @nameNewTable + '] FROM [' + @nameCurTable +']'
			EXEC sp_executesql @query

			-- Добавляем столбец пользователя, внесшего изменения
			SET @query = 'ALTER TABLE [' + @nameNewTable + '] ADD [user] nvarchar(50) NOT NULL CONSTRAINT [DF_'+@nameNewTable+'_USER]  DEFAULT (SUSER_NAME())'
			EXEC sp_executesql @query
			-- Добавляем столбец даты изменения
			SET @query = 'ALTER TABLE [' + @nameNewTable + '] ADD [date] datetime NOT NULL CONSTRAINT [DF_'+@nameNewTable+'_DATE]  DEFAULT (getdate())'
			EXEC sp_executesql @query
			-- Добавляем столбец типа модификации
			SET @query = 'ALTER TABLE [' + @nameNewTable + '] ADD [type] nvarchar(50) NOT NULL '
			EXEC sp_executesql @query
			
			-- Триггер для вставки
			SET @query = 'CREATE TRIGGER INSERTtrig'+ @nameNewTable +' ON '+ QUOTENAME(@nameCurTable) +'
			AFTER INSERT
			AS
			BEGIN 
				INSERT INTO ['+@nameNewTable+']('+@columnsStr + 'type) SELECT '+@columnsStr + char(39)+'INSERT'+char(39)+' FROM inserted 
			END'
			EXEC sp_executesql @query

			-- Триггер для обнавления
			SET @query = 'CREATE TRIGGER UPDATEtrig'+ @nameNewTable +' ON '+ QUOTENAME(@nameCurTable) +'
			AFTER UPDATE
			AS
			BEGIN 
				INSERT INTO ['+@nameNewTable+']('+@columnsStr + 'type) SELECT '+@columnsStr + char(39)+'UPDATE'+char(39)+' FROM inserted 
			END'
			EXEC sp_executesql @query

			-- Триггер для удаления
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

-- Тесты
CREATE PROCEDURE SHOW 
AS
BEGIN
    SELECT * FROM Books
	SELECT * FROM Readers
	SELECT * FROM twinBooks
	SELECT * FROM twinReaders
END
GO

-- Вставка одного значения
INSERT INTO Books(id_book, Author, name) VALUES (1, 'ss', 'r')

-- Вставка нескольких значений
INSERT INTO Readers(id_reader, FIO, Address) VALUES (1,'ss', 'r'), (2,'ssw', 'rw')

EXECUTE ('SHOW')

-- Обновление одного значения
UPDATE Books SET name = 'rr'

-- Обновление нескольких 
UPDATE Readers SET FIO += 'p'

EXECUTE ('SHOW')

-- Удаление одного
DELETE FROM Books WHERE id_book = 1

-- Удаление нескольких
DELETE FROM Readers

EXECUTE ('SHOW')


DROP TABLE Books
DROP TABLE Readers
DROP TABLE twinBooks
DROP TABLE twinReaders
DROP PROCEDURE TwinTables
DROP PROCEDURE SHOW
