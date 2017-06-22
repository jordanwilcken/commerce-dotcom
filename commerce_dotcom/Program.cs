using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;

using commerce_dotcom.models;
using System.Diagnostics;

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
