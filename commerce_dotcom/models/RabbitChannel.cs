using RabbitMQ.Client;
using System;

namespace commerce_dotcom.models
{
    public class RabbitChannel : IPublishToProcessingQueue, IDisposable
    {
        public const string ProcessingQueueName = "order_processing";

        private IModel BackingChannel { get; }
        private IBasicProperties ChannelProperties { get; set; }

        public RabbitChannel(IModel rabbitChannel)
        {
            BackingChannel = rabbitChannel;
            Configure =
                () =>
                    {
                        ChannelProperties = BackingChannel.CreateBasicProperties();
                        ChannelProperties.Persistent = true;
                        Configure = () => { };
                    };
        }

        public void DeclareProcessingQueue()
        {
            BackingChannel.QueueDeclare(
                queue: ProcessingQueueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null);
        }

        public void BasicPublish(byte[] messageBody)
        {
            BackingChannel.BasicPublish(
                exchange: "",
                routingKey: ProcessingQueueName,
                basicProperties: ChannelProperties,
                body: messageBody);
        }

        public void Dispose()
        {
            BackingChannel.Dispose();
        }

        public Action Configure { get; private set; }
    }
}
