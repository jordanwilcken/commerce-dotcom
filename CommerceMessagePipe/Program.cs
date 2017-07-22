using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using WebSocketSharp.Server;

namespace CommerceMessagePipe
{
    class Program
    {
        static void Main(string[] args)
        {
            int port = -1;
            try
            {
                port = int.Parse(Regex.Match(args[0], @"\d+").Value);
            }
            catch
            {
                Console.WriteLine("You forgot to specify a port for the message pipe to run on.");
                Console.WriteLine("Press any key to exit.");
                Console.ReadKey();
                return;
            }

            WebSocketServer server;
            try
            {
                server = new WebSocketServer(port, secure: false);
                server.Start();
                Console.WriteLine($"Websocket server is running on port {port}.");
                ExplainHowToQuit();
            }
            catch
            {
                Console.WriteLine("Could not start the websocket server.");
                Console.WriteLine("Press any key to exit.");
                Console.ReadKey();
                return;
            }

            using (IConnection rabbitConnection = MakeRabbitConnection())
            using (IModel rabbitChannel = rabbitConnection.CreateModel())
            {
                var errors = StartPipingMessages(rabbitChannel, server);
                foreach (string error in errors)
                {
                    Console.WriteLine(error);
                }
                ListenForQuitCommand();
            }

            server.Stop();
        }

        private static string[] StartPipingMessages(IModel rabbitChannel, WebSocketServer websocketServer)
        {
            var errors = new List<string>();

            var consumerResult = MakeMessageConsumer("order_processing", rabbitChannel);
            consumerResult.IfSuccess(() => AttachSocketServiceToMessageConsumer(consumerResult.Value, "/processing", websocketServer));
            consumerResult.IfFailure(() => errors.Add(consumerResult.Error));

            consumerResult = MakeMessageConsumer("shipping", rabbitChannel);
            consumerResult.IfSuccess(() => AttachSocketServiceToMessageConsumer(consumerResult.Value, "/shipping", websocketServer));
            consumerResult.IfFailure(() => errors.Add(consumerResult.Error));

            return errors.ToArray();
        }

        private static void AttachSocketServiceToMessageConsumer(EventingBasicConsumer processingMessageConsumer, string path, WebSocketServer websocketServer)
        {
            Action<SensibleSocketService> configureEvents =
                processingSocket =>
                    ConfigureEvents(processingMessageConsumer, processingSocket);

            websocketServer.AddWebSocketService(path, configureEvents);
        }

        private static void ConfigureEvents(EventingBasicConsumer processingMessageConsumer, SensibleSocketService orderProcessingSocket)
        {
            EventHandler<BasicDeliverEventArgs> onReceived =
                (sender, eventArgs) =>
                    orderProcessingSocket.SendData(Encoding.UTF8.GetString(eventArgs.Body));

            processingMessageConsumer.Received += onReceived;
            orderProcessingSocket.Closed +=
                () => processingMessageConsumer.Received -= onReceived;
        }

        private static Result<EventingBasicConsumer> MakeMessageConsumer(string queueName, IModel rabbitChannel)
        {
            var result = Result<EventingBasicConsumer>.Fail($"Could not make a consumer for the {queueName} queue. Probably because the queue doesn't exist.");
            var consumer = new EventingBasicConsumer(rabbitChannel);

            try
            {
                rabbitChannel.BasicConsume(queue: queueName, noAck: false, consumer: consumer);
                result = Result<EventingBasicConsumer>.OK(consumer);
            }
            catch
            {
            }

            return result;
        }

        private static IConnection MakeRabbitConnection()
        {
            var factory = new ConnectionFactory() { HostName = "localhost" };
            return factory.CreateConnection();
        }

        private static void ExplainHowToQuit()
        {
            Console.WriteLine(@"type ""quit"" to quit this program.");
        }

        private static void ListenForQuitCommand()
        {
            while (Console.ReadLine() != "quit")
            {
                ExplainHowToQuit();
            }
        }
    }
}
