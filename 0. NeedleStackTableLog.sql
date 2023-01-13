-------------------------------------------------------------------------
---- QUERY PREREQUISITE FOR LOG & RESULT
 -------------------------------------------------------------------------
BEGIN TRAN

	   IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'NeedleStack')
	   BEGIN
		  EXEC sp_executesql N'CREATE SCHEMA NeedleStack'
	   END
	   GO

	   CREATE TABLE NeedleStack.Migration_Log (
		  Id INT IDENTITY(1,1) PRIMARY KEY,
		  LogType NVARCHAR(15) NOT NULL,
		  LogDateTime DATETIME NOT NULL,
		  ErrorMessage TEXT NULL
	   )
	   GO

	   CREATE TABLE NeedleStack.Migration_Log_Candidate (
		 Id INT IDENTITY(1,1) PRIMARY KEY,   
		 LogDateTime DATETIME NOT NULL,
		 ObjectId INT NULL,
		 CandidateFolderPath TEXT NULL,
		 CandidateFilePath TEXT NULL,
	   )
	   GO

	   CREATE TABLE NeedleStack.Migration_Log_Client (
		 Id INT IDENTITY(1,1) PRIMARY KEY,
		 LogDateTime DATETIME NOT NULL,
		 ClientId INT NULL,
		 ClientFolderPath TEXT NULL,
		 ClientFilePath TEXT NULL,
	   )


ROLLBACK TRAN
