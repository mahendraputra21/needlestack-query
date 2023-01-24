using ApplicantExportConsoleApp.Class;
using ApplicantExportConsoleApp.Constants;
using ApplicantExportConsoleApp.Helpers;
using Newtonsoft.Json;
using System.Data.SqlClient;

public class Program
{
    public static void Main(string[] args)
    {
        var parameter = args[0];
        var appSettings = JsonConvert.DeserializeObject<AppSettings>(File.ReadAllText(Constants.APP_SETTINGS));
        var connectionString = appSettings?.ConnectionString;

        using (var connection = new SqlConnection(connectionString))
        {
            connection.Open();
            using (var transaction = connection.BeginTransaction())
            {
                try
                {
                    Console.WriteLine("Starting Export Data Applicants....");

                    Console.WriteLine("Processing Please wait....");

                    var spParam = parameter == Constants.APPLICANT_PROCESS ? Constants.SP_GET_DATA_APPLICANTS : Constants.SP_GET_DATA_CLIENTS;

                    if (parameter == Constants.APPLICANT_PROCESS || parameter == Constants.CLIENT_PROCESS)
                        ExtractingDataApplicantClient(connection, transaction, spParam);
                    else
                        Console.WriteLine("Error processing.....!");

                    transaction.Commit();

                    Console.WriteLine("Done Export Data....!");

                    Console.ReadKey();
                }
                catch (Exception ex)
                {
                    //SET Log Error Export
                    var logTypeParam = parameter == Constants.APPLICANT_PROCESS ? Constants.LOG_TYPE_APP: Constants.LOG_TYPE_CLNT;
                    ExportHelper.SetExportErrorLog(connection, transaction, logTypeParam, DateTime.Now, ex.Message);
                    Console.WriteLine("An error occurred: " + ex.Message);
                    transaction.Rollback();
                }
            }
        }

    }

    #region Private Method
    private static void ExtractingDataApplicantClient(SqlConnection connection, SqlTransaction transaction, string spParam)
    {
        using (var command = new SqlCommand(spParam, connection, transaction))
        {
            command.CommandType = System.Data.CommandType.StoredProcedure;
            ExportHelper.ProcessExtractingData(connection, transaction, command);
        }
    }
    #endregion

}
