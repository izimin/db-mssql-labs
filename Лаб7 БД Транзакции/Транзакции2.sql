
--��������� I (���������������)
BEGIN TRAN 
	--INSERT INTO �������(id�������, ��������_�������, ������) VALUES (2000, '��','������')
	UPDATE ������� SET ��������_������� = '�' WHERE ��������_������� = '���'
	SELECT *, GETDATE() FROM �������
COMMIT TRAN
GO

----------------------------2 � 3 �����:
--������� ������**
--(2�����) 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--(3�����) SET TRANSACTION ISOLATION LEVEL READ COMMITED
BEGIN TRAN
SELECT * FROM �������
SELECT * FROM ���������
COMMIT TRAN;

--��������������� ������
SELECT * FROM ������
BEGIN TRAN
	BEGIN TRY
		UPDATE ������ SET [����(���)] = 6 WHERE [����(���)]=5
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage1 NVARCHAR(200), @errorSeverity1 INT
		SELECT @errorMessage1 = ERROR_MESSAGE(), @errorSeverity1 = ERROR_SEVERITY()
		RAISERROR (@errorMessage1, @errorSeverity1, 1)
	END CATCH
SELECT * FROM ������

--��������� �������
SELECT * FROM ������
BEGIN TRAN
	BEGIN TRY
		UPDATE ������ SET �����_������ = 19 WHERE ��������_������ = '����'
		INSERT INTO ������ (��������_������, ������������_������, �����_������, �������_�����) 
					VALUES ('��������', '�������� �����', 50, 70)
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(200), @errorSeverity INT
		SELECT @errorMessage = ERROR_MESSAGE(), @errorSeverity = ERROR_SEVERITY()
		RAISERROR (@errorMessage, @errorSeverity, 1)
	END CATCH
SELECT * FROM ������

--���������� ����������
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRAN
	BEGIN TRY
		SELECT * FROM ������
		UPDATE ������ SET [����(���)]  = [����(���)]  + 1 WHERE ��� = '���'
		--INSERT INTO ������ (���, ������, [����(���)]) 
					--VALUES ('CDE', 'China', 5)
	COMMIT TRAN;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage4 NVARCHAR(200), @errorSeverity4 INT
		SELECT @errorMessage4 = ERROR_MESSAGE(), @errorSeverity4 = ERROR_SEVERITY()
		RAISERROR (@errorMessage4, @errorSeverity4, 1)
	END CATCH
SELECT * FROM ������