using System.Diagnostics;

namespace commerce_dotcom.models
{
    public class DiagnosticsProcess : IProcess
    {
        public DiagnosticsProcess(Process process)
        {
            TheProcess = process;
        }

        public void Stop()
        {
            TheProcess.Kill();
        }

        private Process TheProcess { get; }
    }
}