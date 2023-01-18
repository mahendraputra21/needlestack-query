----------------------------------------------------------------------------
---- Query Missing Candidate CV + templates
---- conditional : FileExtension & CV/Doc Is NOT NULL
----------------------------------------------------------------------------
SELECT 
a.ApplicantId,
a.FolderPath,
a.FileName,
a.FileExtension,
b.ApplicantId
FROM Needlestack.V_ApplicantDataSource a
LEFT JOIN Needlestack.ApplicantTarget b ON a.ApplicantId = b.ApplicantId
INNER JOIN dbo.CVContents cv ON cv.CVId = a.FileId
WHERE b.ApplicantId IS NULL
AND a.SourceType='CV'
AND a.FileExtension IS NOT NULL
AND cv.CV IS NOT NULL

UNION ALL

SELECT 
a.ApplicantId,
a.FolderPath,
a.FileName,
a.FileExtension,
b.ApplicantId
FROM Needlestack.V_ApplicantDataSource a
LEFT JOIN Needlestack.ApplicantTarget b ON a.ApplicantId = b.ApplicantId
INNER JOIN dbo.TemplateDocument t ON t.TemplateId = a.FileId
WHERE b.ApplicantId IS NULL
AND a.SourceType='T'
AND a.FileExtension IS NOT NULL
AND t.Document IS NOT NULL