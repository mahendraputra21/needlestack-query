using ConsoleAppBase;
using System.Diagnostics;

class Program
{
    static void Main(string[] args)
    {
        if (args is null)
        {
            throw new ArgumentNullException(nameof(args));
        }

        Console.WriteLine("Welcome to Needlestack Data CV/Stored Document Extraction...");

        while (true)
        {
            Console.WriteLine("1. Export File Applicants");
            Console.WriteLine("2. Export File Clients");
            Console.WriteLine("3. Exit");

            Console.Write("choose your choice: ");
            var input = Console.ReadLine();

            if (input == "1")
            {
                // Run the Applicant Console App
                Console.WriteLine("Run Export File Applicants...");
                Process.Start(Constants.APPLICANT_PATH, input);
            }
            else if (input == "2")
            {
                // Code to run the Client Console App
                Console.WriteLine("Run Export File Clients...");
                Process.Start(Constants.APPLICANT_PATH, input);
            }
            else if (input == "3")
            {
                // Exit the program
                break;
            }
            else
            {
                Console.WriteLine("Invalid input. Please enter a valid option.");
            }
        }
    }
}
