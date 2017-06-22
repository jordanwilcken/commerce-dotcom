using commerce_dotcom.models;
using Microsoft.AspNetCore.Hosting;
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;

namespace commerce_dotcom
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var host = new WebHostBuilder()
                .UseKestrel()
                .UseContentRoot(Directory.GetCurrentDirectory())
                .UseIISIntegration()
                .UseStartup<Startup>()
                .UseApplicationInsights()
                .Build();

            var messageMoverProcess = MakeMessageMoverProcess();
            var errors = messageMoverProcess.Start();
            if (errors.Any())
                Console.Error.WriteLine("Could not start the message mover process.");

            host.Run();

            messageMoverProcess.End();
        }

        private static MessageMoverProcess MakeMessageMoverProcess() =>
            new MessageMoverProcess(
                () =>
                    new DiagnosticsProcess(
                        Process.Start(
                            new ProcessStartInfo(
                                @"..\CommerceMessagePipe\bin\debug\CommerceMessagePipe.exe",
                                "socketPort=7777"))));
    }
}
