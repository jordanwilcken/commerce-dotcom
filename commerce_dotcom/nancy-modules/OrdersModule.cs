using commerce_dotcom.models;
using Nancy;
using Nancy.Extensions;
using System.Text;

namespace commerce_dotcom.nancy_modules
{
    public class OrdersModule : NancyModule
  {
    public OrdersModule(IPublishToProcessingQueue processingPublisher)
    {
      Post["orders"] = _ => {
        processingPublisher.BasicPublish(
          RabbitChannel.ProcessingQueueName,
          Encoding.UTF8.GetBytes(Request.Body.AsString()));

        return Response.AsJson(new { message = "success" });
      };

      Post["shipped-orders"] = _ => {
        processingPublisher.BasicPublish(
          RabbitChannel.ShippingQueueName,
          Encoding.UTF8.GetBytes(Request.Body.AsString()));

        return Response.AsJson(new { message = "success" });
      };
    }
      
  }
}
