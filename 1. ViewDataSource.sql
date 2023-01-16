-------------------------------------------------------------------------
---- QUERY VIEW DATA SOURCE 
---- APPLICANT AND CLIENT
-------------------------------------------------------------------------

CREATE OR ALTER VIEW needlestack.V_ApplicantDataSource
AS
	
	SELECT 
	Id = ROW_NUMBER() OVER( ORDER BY ApplicantId ASC ),
	ApplicantId,
	SourceType,
	FileId,
	FolderPath,
	TemplateTypeId,
	[FileName],
	FileExtension,
	FileContent
	FROM 
	(
		SELECT  
				ApplicantId = a.ApplicantId,
				SourceType = 'CV',
				FileId = a.CVId,
				FolderPath= 'D:\ExportFiles\Candidate\' + Cast(a.ApplicantId AS NVARCHAR(10)),
				TemplateTypeId = NULL,
				[FileName] = CASE WHEN a.Publish='Y' THEN 'CV' +' '+ p.PersonName + ' ' + p.Surname + ' (Formated)'
							ELSE 
								'CV' +''+ 
								Cast(a.CVId AS NVARCHAR(10)) +' '+  -- to prevent same file name 
								+ p.PersonName + ' ' + p.Surname 
										
							END,
				b.FileExtension,
				FileContent = b.CV
		FROM   dbo.cv a
				INNER JOIN dbo.cvcontents b
						ON a.cvid = b.cvid
				INNER JOIN dbo.Person p
						ON p.PersonID = a.ApplicantId
					  

	UNION ALL

		SELECT DISTINCT 
				ApplicantId = a.ObjectId,
				SourceType = 'T',
				FileId = a.TemplateID,
				FolderPath = 'D:\ExportFiles\Candidate\' + CAST(a.ObjectId AS NVARCHAR(10)),
				TemplateTypeId = a.TemplateTypeId,
				[FileName] = ISNULL(tt.AbbreviatedText, ' ') + ' ' + 
							p.PersonName + ' ' + p.Surname + ' ' + 
							LEFT(a.TemplateName, LEN(a.TemplateName) - LEN(REVERSE(LEFT(REVERSE(a.TemplateName), CHARINDEX('.', REVERSE(a.TemplateName)))))),
				FileExtension = b.FileExtension,
				FileContent = b.Document
		FROM dbo.Templates a
				INNER JOIN dbo.TemplateDocument b
						ON a.TemplateId = B.TemplateId
				INNER JOIN Needlestack.TemplateTypes tt
						ON tt.TemplateTypeId = a.TemplateTypeId
				INNER JOIN dbo.Person p
						ON p.PersonID = a.ObjectId
				WHERE a.OBJECTID IS NOT NULL
	) X			


