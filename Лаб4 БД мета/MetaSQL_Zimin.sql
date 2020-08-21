--№1. Создание спец. таблицы.
CREATE TABLE spec 
(
	id int,
	tableName nvarchar(50),
	columnName nvarchar(50),
	curMax int
);

--№2. Добавление в спец. таблицу записи
 INSERT INTO spec (id, tableName, columnName, curMax)
 VALUES (1, 'spec', 'id', 1)

--№3. Создание хранимой процедуры (ХП)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE IncValue
	@tableName nvarchar(50),
	@columnName nvarchar(50),
	@nextIntNum int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @tableId int

	--SELECT @tableId = _table.object_id
	--FROM sys.columns  _column
	--		JOIN 
	--	 sys.tables _table ON _table.object_id = _column.object_id 
	--		JOIN 
	--	 sys.types _type   ON _column.system_type_id = _type.user_type_id
	--WHERE _table.name = @tableName AND 
	--	  _column.name = @columnName AND 
	--	  _type.name = 'int' 

	if NOT EXISTS (select * from INFORMATION_SCHEMA.COLUMNS where @tableName = TABLE_NAME AND @columnName = COLUMN_NAME AND DATA_TYPE = 'int')
	BEGIN
		RAISERROR('Недопустимое имя или тип столбца или имя таблицы', 16, 1)
		return -1
	END	

	DECLARE @specId int 
	SELECT @specId = id 
	FROM spec 
	WHERE tableName = @tableName AND columnName = @columnName

	IF (@specId IS NULL)
		BEGIN
			DECLARE @query nvarchar(max)
			SET @query = 'SELECT @maxValue = ( max (' + QUOTENAME(@columnName) + ') + 1 ) 
						  FROM ' + QUOTENAME(@tableName)
			EXECUTE sp_executesql @query, N'@maxValue INT OUTPUT', @maxValue = @nextIntNum OUTPUT
		
			IF (@nextIntNum IS NULL) SET @nextIntNum = 1

			DECLARE @nextId int
			EXECUTE IncValue 'spec', 'id', @nextId OUT

			INSERT INTO spec (id, tableName, columnName, curMax) 
			VALUES (@nextId, @tableName, @columnName, @nextIntNum)

			DECLARE @cntTriggers int  
			SELECT @cntTriggers = COUNT(*) + 1
			FROM sys.triggers _triggers
			WHERE _triggers.type = 'TR' AND _triggers.parent_id = OBJECT_ID(@tableName)
			
			DECLARE @nameTrigger nvarchar(100) = @tableName + '_'  + @columnName  + '_' + CAST(@cntTriggers AS nvarchar(10)) 

			IF EXISTS (SELECT * FROM sys.objects WHERE name = @nameTrigger)
				SET @nameTrigger += CAST(NEWID() AS nvarchar(36))

			DECLARE @trigger nvarchar(MAX) = '
				CREATE TRIGGER ' + QUOTENAME(@nameTrigger) +  ' ON ' + QUOTENAME(@tableName) + '
				AFTER INSERT, UPDATE AS 
				BEGIN
					DECLARE @maxIns int
					SELECT @maxIns = MAX(inserted.' + QUOTENAME(@columnName) + ') FROM inserted

					UPDATE spec SET curMax = @maxIns WHERE id = ' + CAST(@nextId AS nvarchar(50)) + ' AND @maxIns > curMax
				END'
			EXEC(@trigger)
		END
	ELSE
		UPDATE spec SET curMax += 1, @nextIntNum = (curMax + 1) WHERE id = @specId
END
GO

-- Создадим  таблицу с именем, с которым в последствии должен создаться триггер
CREATE TABLE test_num_1 
(
	num1 nvarchar(50)
);

-- №4. Создатим таблицу test 
CREATE TABLE test
(
	num int
);

-- №5. Вызовем ХП (должен создаться триггер)
DECLARE @nextID int
EXECUTE IncValue 'test', 'num', @nextID OUTPUT

-- №6. Вставим одно значение в таблицу test 
INSERT INTO test VALUES (5)

-- №7. Выведем таблицу spec
SELECT *
FROM spec

-- №8. Вставим  значение в таблицу test 
INSERT INTO test VALUES (15), (4)

-- №9. Выведем таблицу test
SELECT *
FROM test

-- №10. Обновим значение в столбце с 15 на 18
UPDATE test SET num = 18 
WHERE num = 15

-- №11. Вызовем ХП должно вернуться 19
EXECUTE IncValue 'test', 'num', @nextID OUTPUT
SELECT @nextID

-- №12. Создадим таблицу test1 с 2-мя параметрами 
CREATE TABLE test1
(
	num1 int,
	num2 int
);

-- №13. Вызовем ХП (должны сгенерироваться триггеры)
EXECUTE IncValue 'test1', 'num1', @nextID OUTPUT
EXECUTE IncValue 'test1', 'num2', @nextID OUTPUT


-- №14. Вставим в test1 в столбец num1 значение 8, сторой столбец пока пустой
INSERT INTO test1(num1) VALUES (8)

-- №15. Вызовем ХП должно вернуться 9
EXECUTE IncValue 'test1', 'num1', @nextID OUTPUT
SELECT @nextID

-- №16. Вызовем ХП должно вернуться 2
EXECUTE IncValue 'test1', 'num2', @nextID OUTPUT
SELECT @nextID

-- №17. Вставим  значение в таблицу test1 в оба поля
INSERT INTO test1(num1, num2) VALUES (22,33)

-- №18. Выведем таблицу spec
SELECT *
FROM spec

-- №19 обнавление несколькх элементов
UPDATE test1 SET num1 += 5, num2 += 44 --WHERE num1 = 22 AND num2 = 33 

-- №20. Выведем таблицу spec
SELECT *
FROM spec

-- №21. Вызов ХП. Столбец не типа int
EXECUTE IncValue 'test_num_1', 'num1', @nextID OUTPUT

-- №22. Вызов ХП. Столбец не сущестует
EXECUTE IncValue 'test_num_1', 'num', @nextID OUTPUT


-- №23. Вызов ХП. Таблица и столбец не существуют
EXECUTE IncValue 'Не_существующая', 'Не_существующий', @nextID OUTPUT

-- №24. Проверка QUOTENAME. Создадим таблицу в которой присутствуют 
CREATE TABLE ['[drop table spec; !@#$%^&^&*()_?><--/**/''] 
(
	[lk;123@*/#$%^&] int
)
EXECUTE IncValue ['[drop table spec; !@#$%^&^&*()_?><--/**/''] , [lk;123@*/#$%^&], @nextID OUTPUT
select @nextID

-- №25. Выводим информацию о созданных триггерах 
SELECT * FROM sys.triggers


-- №26. Удаление ХП
DROP PROCEDURE IncValue
GO

-- №27. Удаление таблиц
DROP TABLE spec
GO

DROP TABLE test
GO

DROP TABLE test1
GO

DROP TABLE test_num_1 
GO

DROP TABLE ['[drop table spec; !@#$%^&^&*()_?><--/**/'']
GO