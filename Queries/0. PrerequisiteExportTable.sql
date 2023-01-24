-------------------------------------------------------------------------
---- QUERY PREREQUISITE 
---- TemplateTypes, Export_Error_Logs , Export_Applicant_Data_Logs 
---- Export_Client_Data_Logs
-------------------------------------------------------------------------

 BEGIN TRY
    BEGIN TRAN

		   IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Needlestack')
			 BEGIN
				EXEC sp_executesql N'CREATE SCHEMA Needlestack'
			 END

			 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TemplateTypes' AND schema_id = SCHEMA_ID('Needlestack'))
			 BEGIN
				CREATE TABLE Needlestack.TemplateTypes (
				    TemplateTypeId INT PRIMARY KEY NOT NULL,
				    TemplateTypeName NVARCHAR(300) NOT NULL,
				    AbbreviatedText NVARCHAR(100) NULL
				)

				INSERT INTO Needlestack.TemplateTypes (TemplateTypeId, TemplateTypeName, AbbreviatedText) 
				VALUES 
				(3, 'Standard Templates', 'Standard'),
				(15, 'Job Description Templates', 'JD'),
				(20, 'TOB Clients Templates', 'TOB'),
				(21, 'Fax', 'FAX'),
				(22, 'CV Templates', 'CV'),
				(23, 'Reference Templates', 'Reference'),
				(24, 'AWR Templates', 'AWR'),
				(25, 'Placement Documentation', 'Placements'),
				(26, 'Notebook Templates', 'Notebook'),
				(27, 'Identity Documents', 'Identity'),
				(28, 'Banking Details', 'Banking'),
				(29, 'Accounts Confirmation', 'Accounts'),
				(30, 'Personal Details Form', 'Personal'),
				(31, 'Screening Background Check', 'Screening'),
				(32, 'Visit Report', 'Visit'),
				(33, 'Worker Assignment Schedules', 'Schedule'),
				(34, 'Imported Document', 'Imported'),
				(35, 'Quote Template', 'Quote'),
				(36, 'Passport', 'Passport'),
				(39, 'Visa', 'Visa'),
				(40, 'ID Card', 'ID Card'),
				(41, 'Settled Status', 'Settled'),
				(42, 'Pre-Settled Status', 'Pre-Settled'),
				(43, 'Contract for Services', 'Contract'),
				(44, 'FMCG - APPLIED SETTLED STATUS', NULL),
				(45, 'FMCG - N I PROOF', NULL),
				(46, 'FMCG - KID DOCUMENT', NULL),
				(47, 'FMCG - APPLICATION FORM', NULL),
				(49, 'FMCG - GREENVALE WAS', NULL),
				(55, 'FMCG - BIRTH CERTIFICATE', NULL),
				(56, 'FMCG - CHAMPION', NULL),
				(59, 'FMCG - EMAIL', NULL),
				(60, 'FMCG - SICK NOTE', NULL),
				(61, 'FMCG - INDUCTION', NULL),
				(64, 'GDPR', 'GDPR'),
				(65, 'REUSE - Marriage Certificate', 'Reuse'),
				(68, 'Client Forms - External', 'Client_External'),
				(69, 'REUSE - Worker Assignment Schedule Email', 'Reuse_WAS'),
				(73, 'Contracts', 'Contracts'),
				(78, 'Applicant Forms/Documentation', 'Form'),
				(83, 'DocuSign Signed Document', 'Signed'),
				(84, 'Payroll New Starters', 'Payroll'),
				(85, 'Client Forms - Internal', 'Client_Internal'),
				(86, 'Client Perm Placement Confirmation', 'Client_Perm_Conf')
			 END

			IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Export_Error_Logs' AND schema_id = SCHEMA_ID('Needlestack'))
			 BEGIN
				CREATE TABLE Needlestack.Export_Error_Logs (
				    LogId INT IDENTITY(1,1) PRIMARY KEY,
				    LogType NVARCHAR(200) NOT NULL,
				    LogDate DATETIME NOT NULL,
				    ErrorMessage TEXT NOT NULL
				)
			 END

			 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Export_Applicant_Data_Logs' AND schema_id = SCHEMA_ID('Needlestack'))
			 BEGIN
			    CREATE TABLE Needlestack.Export_Applicant_Data_Logs (
				   LogId INT IDENTITY(1,1) PRIMARY KEY,   
				   LogDate DATETIME NOT NULL,
				   TemplateTypeId INT NULL DEFAULT (0),
				   ApplicantId INT NOT NULL,
				   SourceType NVARCHAR(2) NOT NULL,
				   FileId INT NOT NULL,
				   FolderPath TEXT NOT NULL,
				   [FileName] TEXT NOT NULL,
				   FileExtension NVARCHAR(30) NULL
				)
			 END

			 IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Export_Client_Data_Logs' AND schema_id = SCHEMA_ID('Needlestack'))
			 BEGIN
				CREATE TABLE Needlestack.Export_Client_Data_Logs (
				   LogId INT IDENTITY(1,1) PRIMARY KEY,
				   LogDate DATETIME NOT NULL,
				   TemplateTypeId INT NULL DEFAULT (0),
				   ClientId INT NOT NULL,
				   FileId INT NOT NULL,
				   FolderPath TEXT NOT NULL,
				   [FileName] TEXT NOT NULL,
				   FileExtension NVARCHAR(30) NULL
				)
			 END

    COMMIT TRAN
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
    DECLARE @LogDateTime DATETIME = GETDATE()
    DECLARE @LogType NVARCHAR(15) = 'InitTable'
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN

     --INSERT to Table Log
    INSERT INTO Needlestack.Export_Error_Logs (LogType, LogDate, ErrorMessage) 
    VALUES (@LogType, @LogDateTime, @ErrorMessage)

    RAISERROR('Error occurred during transaction', 16, 1)
END CATCH


	  


