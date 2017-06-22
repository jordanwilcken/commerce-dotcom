using commerce_dotcom.models;
using Nancy;
using Nancy.Extensions;
using System;
using System.Text;

namespace commerce_dotcom.nancy_modules
{
  public class OrdersModule : NancyModule
  {
    public OrdersModule(IPublishToProcessingQueue publisher)
    {
      Post["orders"] = _ => {
        publisher.BasicPublish(Encoding.UTF8.GetBytes(Request.Body.AsString()));
        return Response.AsJson(new { message = "success" });
      };
    }
      
  }
}
