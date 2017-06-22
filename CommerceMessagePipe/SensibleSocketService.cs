using System;
using WebSocketSharp;
using WebSocketSharp.Server;

namespace CommerceMessagePipe
{
    public class SensibleSocketService : WebSocketBehavior
    {
        public void SendData(string data)
        {
            base.Send(data);
        }

        protected override void OnClose(CloseEventArgs e)
        {
            base.OnClose(e);
            Closed.Invoke();
        }

        public event Action Closed; 
    }
}