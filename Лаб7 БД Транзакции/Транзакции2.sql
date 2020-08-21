
--категория I (изолированность)
BEGIN TRAN 
	--INSERT INTO Команда(idКоманды, Название_команды, Страна) VALUES (2000, 'кк','Польша')
	UPDATE Команда SET Название_команды = 'Л' WHERE Название_команды = 'Йоу'
	SELECT *, GETDATE() FROM Команда
COMMIT TRAN
GO

----------------------------2 и 3 части:
--Грязное чтение**
--(2часть) 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--(3часть) SET TRANSACTION ISOLATION LEVEL READ COMMITED
BEGIN TRAN
SELECT * FROM Команда
SELECT * FROM Спортсмен
COMMIT TRAN;

--Неповторяющееся чтение
SELECT * FROM Тренер
BEGIN TRAN
	BEGIN TRY
		UPDATE Тренер SET [Стаж(лет)] = 6 WHERE [Стаж(лет)]=5
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage1 NVARCHAR(200), @errorSeverity1 INT
		SELECT @errorMessage1 = ERROR_MESSAGE(), @errorSeverity1 = ERROR_SEVERITY()
		RAISERROR (@errorMessage1, @errorSeverity1, 1)
	END CATCH
SELECT * FROM Тренер

--Фантомная вставка
SELECT * FROM Трасса
BEGIN TRAN
	BEGIN TRY
		UPDATE Трасса SET Длина_трассы = 19 WHERE Название_трассы = 'Урал'
		INSERT INTO Трасса (Название_трассы, Расположение_трассы, Длина_трассы, Средний_уклон) 
					VALUES ('Пропасть', 'Северный полюс', 50, 70)
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(200), @errorSeverity INT
		SELECT @errorMessage = ERROR_MESSAGE(), @errorSeverity = ERROR_SEVERITY()
		RAISERROR (@errorMessage, @errorSeverity, 1)
	END CATCH
SELECT * FROM Трасса

--Потерянное обновление
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRAN
	BEGIN TRY
		SELECT * FROM Тренер
		UPDATE Тренер SET [Стаж(лет)]  = [Стаж(лет)]  + 1 WHERE ФИО = 'МИВ'
		--INSERT INTO Тренер (ФИО, Страна, [стаж(лет)]) 
					--VALUES ('CDE', 'China', 5)
	COMMIT TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage4 NVARCHAR(200), @errorSeverity4 INT
		SELECT @errorMessage4 = ERROR_MESSAGE(), @errorSeverity4 = ERROR_SEVERITY()
		RAISERROR (@errorMessage4, @errorSeverity4, 1)
	END CATCH
SELECT * FROM Тренер