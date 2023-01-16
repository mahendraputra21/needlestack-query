CREATE OR ALTER PROCEDURE needlestack.SP_ExportDataApplicants
AS
BEGIN TRY
    BEGIN TRAN

        DECLARE @ApplicantDataSourceRow V_ApplicantDataSource READONLY
        DECLARE @ApplicantId INT
        DECLARE @SourceType NVARCHAR(2)
        DECLARE @TemplateTypeId INT
        DECLARE @FileId INT
        DECLARE @folder_path VARCHAR(100)
        DECLARE @FileName NVARCHAR(200)
        DECLARE @FileExtension NVARCHAR(10)
        DECLARE @fPath NVARCHAR(MAX)
        DECLARE @FileContent VARBINARY(MAX)

        DECLARE exportDataApplicantsCursor CURSOR FOR
        SELECT
            ApplicantId,
            SourceType,
            TemplateTypeId,
            FolderPath,
            FileId,
            FileName,
            FileExtension,
            FileContent
        FROM needlestack.V_ApplicantDataSource

        OPEN exportDataApplicantsCursor

        FETCH NEXT FROM exportDataApplicantsCursor INTO 
            @ApplicantId, 
            @SourceType, 
            @TemplateTypeId, 
            @folder_path, 
            @FileId, 
            @FileName, 
            @FileExtension, 
            @FileContent

        WHILE @@FETCH_STATUS = 0
        BEGIN
                --CREATE Applicant folder structure
                EXEC master..Xp_create_subdir @folder_path
                PRINT 'Folder Generated at - '+ @folder_path

                --Extracting CV and templates Applicants
                SET @fPath = COALESCE(@folder_path, '') + COALESCE(@FileName, '') + COALESCE(@FileExtension, '')

                DECLARE @init INT
                EXEC sp_OACreate 'ADODB.Stream', @init OUTPUT
                EXEC sp_OASetProperty @init, 'Type', 1
                EXEC sp_OAMethod @init, 'Open'
                EXEC sp_OAMethod @init, 'Write', NULL, @FileContent
                EXEC sp_OAMethod @init, 'SaveToFile', NULL, @fPath, 2
                EXEC sp_OAMethod @init, 'Close'
                EXEC sp_OADestroy @init

                print 'Document Generated at - '+  @fPath

                --INSERT to Table Export Applicant Log
                DECLARE @insertedData TABLE (
                    LogId INT , 
                    LogDate DATETIME, 
                    TemplateTypeId INT, 
                    ApplicantId INT, 
                    SourceType NVARCHAR(2), 
                    FileId INT, 
                    FolderPath VARCHAR(100), 
                    FileName NVARCHAR(200), 
                    FileExtension NVARCHAR(10)
                )

                INSERT INTO needlestack.Export_Applicant_Data_Logs (
                    LogDate, 
                    TemplateTypeId ,
                    ApplicantId, 
                    SourceType, 
                    FileId, 
                    FolderPath, 
                    [FileName], 
                    FileExtension
                )
                OUTPUT inserted.* INTO @insertedData
                
                SELECT 
                    GETDATE(), 
                    @TemplateTypeId ,
                    @ApplicantId, 
                    @SourceType ,
                    @FileId, 
                    @folder_path, 
                    @FileName, 
                    @FileExtension

                FETCH NEXT FROM exportDataApplicantsCursor INTO 
                    @ApplicantId, 
                    @SourceType, 
                    @TemplateTypeId, 
                    @folder_path, 
                    @FileId, 
                    @FileName, 
                    @FileExtension, 
                    @FileContent
        END

        CLOSE exportDataApplicantsCursor

        DEALLOCATE exportDataApplicantsCursor

    COMMIT TRAN
END TRY

BEGIN CATCH

    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
    DECLARE @LogDateTime DATETIME = GETDATE()
    DECLARE @LogType NVARCHAR(15) = 'SP_ExportDataApplicants'

    IF @@TRANCOUNT > 0
        ROLLBACK TRAN

    --INSERT to Table Export Error Log
    INSERT INTO needlestack.Export_Error_Logs (LogType, LogDate, ErrorMessage) 
    VALUES (@LogType, @LogDateTime, @ErrorMessage)

    RAISERROR('Error occurred during transaction', 16, 1)

END CATCH