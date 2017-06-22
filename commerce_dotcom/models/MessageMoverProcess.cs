using System;

namespace commerce_dotcom.models
{
    public class MessageMoverProcess
    {
        public MessageMoverProcess(Func<IProcess> startProcess)
        {
            StartProcess = startProcess;
        }

        //Contract:
        //Calls StartProcess
        //Returns empty string array when everything works
        public string[] Start()
        {
            var errors = new string[0];
            try
            {
                DiagnosticsProcess = StartProcess();
            }
            catch
            {
                errors = new string[] { "Failed to start" };
            }

            return errors;
        }

        //Contract:
        //Calls Stop on the IProcess returned by StartProcess
        //Returns empty string array when everything works
        public string[] End()
        {
            var errors = new string[0];
            try
            {
                DiagnosticsProcess.End();
            }
            catch
            {
                errors = new string[] { "Failed to stop" };
            }

            return errors;
        }

        private Func<IProcess> StartProcess { get; }
        private IProcess DiagnosticsProcess { get; set; }
    }
}