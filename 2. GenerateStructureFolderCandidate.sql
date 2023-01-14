-------------------------------------------------------------------------
---- QUERY FOR GENERATE CANDIDATE STRUCTURE FOLDER
---- BASED ON CV AND TEMPLATES
 -------------------------------------------------------------------------
DECLARE @folder VARCHAR(100) = 'E:\ExportFiles\Candidate\'
DECLARE @folder_path VARCHAR(100)
DECLARE @i BIGINT
DECLARE @ApplicantId INT
DECLARE @FileId INT
DECLARE @FileName NVARCHAR(200)

IF OBJECT_ID('tempdb..#TEMP_LIST_APPLICANT', 'U') IS NOT NULL
    DROP TABLE #TEMP_LIST_APPLICANT

BEGIN TRY
    BEGIN TRAN
		  --GET LIST APPLICANTID FROM TABLE CV AND Templates
		  SELECT 
		  DISTINCT
		  Row_number()
		  OVER(
		  ORDER BY APPLICANTID) AS Id,
		  APPLICANTID
		  INTO #temp_list_applicant
		  FROM (
				SELECT DISTINCT 
					   a.applicantid AS APPLICANTID
				FROM   dbo.cv (nolock) a
					   INNER JOIN dbo.cvcontents (nolock) b
							 ON a.cvid = b.cvid

				UNION ALL

				SELECT DISTINCT 
					   a.ObjectId AS APPLICANTID
				FROM Templates(nolock) a
					   INNER JOIN TemplateDocument (nolock) b
							 ON a.TemplateId = B.TemplateId
					   WHERE a.OBJECTID IS NOT NULL
		  ) X


		  SELECT @i = Count(1)
		  FROM   #temp_list_applicant

		  WHILE @i >= 1
			 BEGIN
				
				SELECT
					@folder_path = @folder + Cast(applicantid AS NVARCHAR(5)),
					@ApplicantId = applicantid,
					@FileId=0,
					@FileName =''
				FROM   #temp_list_applicant
				WHERE  id = @i

				
				--CREATE Applicant folder structure
				EXEC master..Xp_create_subdir @folder_path
				PRINT 'Folder Generated at - '+ @folder_path + @FileName

				--INSERT to Table Export Applicant Log
				INSERT INTO Needlestack.Export_Applicant_Data_Logs (LogDate, ApplicantId, FileId, FolderPath, [FileName])
				VALUES (GETDATE(), @ApplicantId, @FileId, @folder_path, @FileName)

				SET @i -= 1

			 END 	    
    COMMIT TRAN
END TRY
BEGIN CATCH

    DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
    DECLARE @LogDateTime DATETIME = GETDATE()
    DECLARE @LogType NVARCHAR(15) = 'ExportCandidate'

    IF @@TRANCOUNT > 0
        ROLLBACK TRAN

    --INSERT to Table Export Error Log
    INSERT INTO Needlestack.Export_Error_Logs (LogType, LogDate, ErrorMessage) 
    VALUES (@LogType, @LogDateTime, @ErrorMessage)

    RAISERROR('Error occurred during transaction', 16, 1)

END CATCH

