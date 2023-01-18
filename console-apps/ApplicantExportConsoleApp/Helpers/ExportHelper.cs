using System.Data.SqlClient;
using System.Text.RegularExpressions;

namespace ApplicantExportConsoleApp.Helpers
{
    public class ExportHelper
    {
        public static byte[] GetFileContentCV(int fileId, SqlConnection connection, SqlTransaction transaction)
        {
            byte[]? fileContent = null;
            using (var command = new SqlCommand("SELECT CV FROM dbo.CVContents WHERE CVId = @fileId AND CV IS NOT NULL", connection, transaction))
            {
                command.Parameters.AddWithValue("@fileId", fileId);
                using (var reader = command.ExecuteReader())
                {
                    if (reader.Read())
                        fileContent = !reader.IsDBNull(0) ? (byte[])reader.GetValue(0) : null;
                    else
                        fileContent = null;
                }
            }
            return fileContent;
        }
        public static byte[] GetFileContentTemplates(int fileId, SqlConnection connection, SqlTransaction transaction)
        {
            byte[]? fileContent = null;
            using (var command = new SqlCommand("SELECT Document FROM dbo.TemplateDocument WHERE TemplateId = @fileId AND Document IS NOT NULL", connection, transaction))
            {
                command.Parameters.AddWithValue("@fileId", fileId);
                using (var reader = command.ExecuteReader())
                {
                    if (reader.Read())
                         fileContent = !reader.IsDBNull(0) ? (byte[])reader.GetValue(0) : null;
                    else
                        fileContent = null;
                }
            }

            return fileContent;
        }
        public static void SetExportApplicantLog(SqlConnection connection, SqlTransaction transaction, int? applicantId, string? sourceType, int templateTypeId, string? folderPath, int? fileId, string? fileName, string? fileExtension)
        {
            using (var logCommand = new SqlCommand("INSERT INTO needlestack.Export_Applicant_Data_Logs " +
                "(LogDate, TemplateTypeId, ApplicantId, SourceType, FileId, FolderPath, [FileName], FileExtension) " +
                "VALUES (GETDATE(), @templateTypeId, @applicantId, @sourceType, @fileId, @folderPath, @fileName, @fileExtension)", connection, transaction))
            {
                logCommand.Parameters.AddWithValue("@templateTypeId", templateTypeId);
                logCommand.Parameters.AddWithValue("@applicantId", applicantId);
                logCommand.Parameters.AddWithValue("@sourceType", sourceType);
                logCommand.Parameters.AddWithValue("@fileId", fileId);
                logCommand.Parameters.AddWithValue("@folderPath", folderPath);
                logCommand.Parameters.AddWithValue("@fileName", fileName);
                logCommand.Parameters.AddWithValue("@fileExtension", fileExtension);
                logCommand.ExecuteNonQuery();
            }
        }
        public static void SetExportErrorLog(SqlConnection connection, SqlTransaction transaction, string logType, DateTime logDate, string errorMessage) 
        {
            using (var logCommand = new SqlCommand("INSERT INTO Needlestack.Export_Error_Logs " +
                "([LogType],[LogDate],[ErrorMessage]) " +
                "VALUES (@logType, @logDate, @errorMessage)", connection, transaction))
            {
                logCommand.Parameters.AddWithValue("@logType", logType);
                logCommand.Parameters.AddWithValue("@logDate", logDate);
                logCommand.Parameters.AddWithValue("@errorMessage", errorMessage);
                logCommand.ExecuteNonQuery();
            }
        }
        public static void ProcessExtractingDataApplicants(SqlConnection connection, SqlTransaction transaction, SqlCommand command)
        {
            using (var reader = command.ExecuteReader())
            {
                while (reader.Read())
                {
                    var applicantId = reader?.GetInt32(0);
                    var sourceType = reader?.GetString(1);
                    var templateTypeId = reader.IsDBNull(2) ? 0 : reader.GetInt32(2);
                    var folderPath = reader?.GetString(3);
                    var fileId = reader?.GetInt32(4);
                    var fileName = reader?.GetString(5);
                    var fileExtension = reader?.GetString(6);
                    var fileContent = reader?.GetString(1) == "CV" ? ExportHelper.GetFileContentCV((int)fileId, connection, transaction)
                        : ExportHelper.GetFileContentTemplates((int)fileId, connection, transaction);

                    // Create folder if it does not exist
                    Directory.CreateDirectory(folderPath);

                    Console.WriteLine("File ID - " + fileId.ToString());
                    Console.WriteLine("Folder Generated at - " + folderPath);

                    // Construct file path
                    var filePath = Path.Combine(folderPath + "\\", Regex.Replace(fileName, "[\\/:*?\"<>|]", "") + fileExtension);

                    // Write file to disk
                    using (var fileStream = new FileStream(filePath, FileMode.Create))

                        if (fileContent != null)
                        {
                            using (var memoryStream = new MemoryStream(fileContent))
                            {
                                memoryStream.CopyTo(fileStream);
                            }
                        }

                    Console.WriteLine("Document Generated at - " + filePath);

                    //reader.Close();

                    // Log export in the database
                    ExportHelper.SetExportApplicantLog(connection, transaction, applicantId, sourceType,
                        templateTypeId, folderPath, fileId, fileName, fileExtension);

                }
            }
        }


    }
}
