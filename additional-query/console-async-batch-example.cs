using System;
using System.Data.SqlClient;
using System.Threading.Tasks;

class Program
{
    static async Task Main()
    {
        // Connection string
        var connectionString = "Server=yourserver;Database=yourdatabase;User Id=yourusername;Password=yourpassword;";

        // Create a new connection
        using (var connection = new SqlConnection(connectionString))
        {
            // Open the connection
            await connection.OpenAsync();

            // Create a new command
            using (var command = new SqlCommand("needlestack.SP_ExportDataApplicants", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            })
            {
                // Define the batch size
                int batchSize = 100;

                // Define the starting parameter values
                int startId = 1;
                int endId = startId + batchSize;

                // Execute the command in a loop
                while (true)
                {
                    // Add the parameters to the command
                    command.Parameters.Clear();
                    command.Parameters.AddWithValue("@startId", startId);
                    command.Parameters.AddWithValue("@endId", endId);

                    // Execute the command asynchronously
                    await command.ExecuteNonQueryAsync();

                    // Update the parameter values for the next batch
                    startId = endId;
                    endId = startId + batchSize;

                    // Exit the loop if no more rows are left
                    if (endId > total_rows)break;
                }
            }
        }
    }
}