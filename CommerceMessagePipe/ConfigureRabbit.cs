using RabbitMQ.Client;

namespace CommerceMessagePipe
{
  public class ConfigureRabbit
  {
    public static void Configure(IModel rabbitChannel)
    {
      rabbitChannel.QueueDeclare(queue: "order_processing",
                                 durable: true,
                                 exclusive: false,
                                 autoDelete: false,
                                 arguments: null);

      rabbitChannel.QueueDeclare(queue: "shipping",
                                 durable: true,
                                 exclusive: false,
                                 autoDelete: false,
                                 arguments: null);

      rabbitChannel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);
    }
  }
}
