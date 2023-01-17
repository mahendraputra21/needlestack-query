using System.Data.SqlClient;

class Program
{

    private static async Task<byte[]> GetFileContentCV(int fileId, SqlConnection connection, SqlTransaction transaction)
    {
        byte[]? fileContent = null;
        using (var command = new SqlCommand("SELECT CV FROM dbo.CVContents WHERE CVId = @fileId", connection, transaction))
        {
            command.Parameters.AddWithValue("@fileId", fileId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    fileContent = (byte[])reader.GetValue(0);
                }
            }
        }
        return fileContent;
    }


    private static async Task<byte[]> GetFileContentTemplates(int fileId, SqlConnection connection, SqlTransaction transaction)
    {
        byte[]? fileContent = null;
        using (var command = new SqlCommand("SELECT Document FROM dbo.TemplateDocument WHERE TemplateId = @fileId", connection, transaction))
        {
            command.Parameters.AddWithValue("@fileId", fileId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    fileContent = (byte[])reader.GetValue(0);
                }
            }
        }

        return fileContent;
    }

    static async Task Main(string[] args)
    {
        var connectionString = "Server=.;Database=McArthur_RDBProNet;User Id=sa;Password=geekseat!;MultipleActiveResultSets=true;";
        using (var connection = new SqlConnection(connectionString))
        {
            await connection.OpenAsync();
            using (var transaction = connection.BeginTransaction())
            {
                try
                {
                    Console.WriteLine("Starting Export Data Applicants....");

                    Console.WriteLine("Processing Please wait....");

                    using (var command = new SqlCommand("Needlestack.SP_GetDataApplicants", connection, transaction))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            
                            while (await reader.ReadAsync())
                            {
                                var applicantId = reader.GetInt32(0);
                                var sourceType = reader.GetString(1);
                                var templateTypeId = reader.IsDBNull(2) ? 0 : reader.GetInt32(2);
                                var folderPath = reader?.GetString(3);
                                var fileId = reader?.GetInt32(4);
                                var fileName = reader?.GetString(5);
                                var fileExtension = reader?.GetString(6);
                                var fileContent = reader.GetString(1) == "CV" ? await GetFileContentCV((int)fileId, connection, transaction) : await GetFileContentTemplates((int)fileId, connection, transaction);

                                // Create folder if it does not exist
                                Directory.CreateDirectory(folderPath);

                                Console.WriteLine("Folder Generated at - " + folderPath);

                                // Construct file path
                                var filePath = Path.Combine(folderPath + "\\", fileName + fileExtension);

                                // Write file to disk
                                using (var fileStream = new FileStream(filePath, FileMode.Create))
                                using (var memoryStream = new MemoryStream(fileContent))
                                {
                                    await memoryStream.CopyToAsync(fileStream);
                                }

                                Console.WriteLine("Document Generated at - " + filePath);

                                //reader.Close();

                                // Log export in the database
                                using (var logCommand = new SqlCommand("INSERT INTO needlestack.Export_Applicant_Data_Logs (LogDate, TemplateTypeId, ApplicantId, SourceType, FileId, FolderPath, [FileName], FileExtension) VALUES (GETDATE(), @templateTypeId, @applicantId, @sourceType, @fileId, @folderPath, @fileName, @fileExtension)", connection, transaction))
                                {
                                    logCommand.Parameters.AddWithValue("@templateTypeId", templateTypeId);
                                    logCommand.Parameters.AddWithValue("@applicantId", applicantId);
                                    logCommand.Parameters.AddWithValue("@sourceType", sourceType);
                                    logCommand.Parameters.AddWithValue("@fileId", fileId);
                                    logCommand.Parameters.AddWithValue("@folderPath", folderPath);
                                    logCommand.Parameters.AddWithValue("@fileName", fileName);
                                    logCommand.Parameters.AddWithValue("@fileExtension", fileExtension);
                                    await logCommand.ExecuteNonQueryAsync();
                                }

                            }
                        }   
                    }
                    transaction.Commit();

                    Console.WriteLine("Done Export Data Applicants....!");
                }
                catch (Exception ex)
                {
                    Console.WriteLine("An error occurred: " + ex.Message);
                    transaction.Rollback();
                    throw;
                }
            }
        }

    }
}
