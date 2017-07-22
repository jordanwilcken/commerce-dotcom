using RabbitMQ.Client;
using System;

namespace commerce_dotcom.models
{
    public class RabbitChannel : IPublishToProcessingQueue, IDisposable
    {
        public const string ProcessingQueueName = "order_processing";
        public const string ShippingQueueName = "shipping";

        private IModel BackingChannel { get; }
        private IBasicProperties ChannelProperties { get; set; }

        public RabbitChannel(IModel rabbitChannel)
        {
            BackingChannel = rabbitChannel;
            Configure =
                () =>
                    {
                        DeclareQueues();
                        ChannelProperties = BackingChannel.CreateBasicProperties();
                        ChannelProperties.Persistent = true;
                        Configure = () => { };
                    };
        }

        public void DeclareQueues()
        {
            BackingChannel.QueueDeclare(
                queue: ProcessingQueueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null);

            BackingChannel.QueueDeclare(
                queue: ShippingQueueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null);
        }

        public void BasicPublish(string routingKey, byte[] messageBody)
        {
            BackingChannel.BasicPublish(
                exchange: "",
                routingKey: routingKey,
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
