using commerce_dotcom.models;
using Nancy;
using Nancy.Bootstrapper;
using Nancy.TinyIoc;
using RabbitMQ.Client;

namespace commerce_dotcom
{
    public class CommerceBootstrapper : DefaultNancyBootstrapper
    {
        protected override void ConfigureApplicationContainer(TinyIoCContainer container)
        {
            // We don't call "base" here to prevent auto-discovery of
            // types/dependencies

            var connection = new ConnectionFactory { HostName = "localhost" }
              .CreateConnection();
            var rabbitChannel = new RabbitChannel(connection.CreateModel());
            rabbitChannel.DeclareProcessingQueue();
            rabbitChannel.Configure();

            container.Register(connection);
            container.Register<IPublishToProcessingQueue>(rabbitChannel);
        }

        protected override void ConfigureRequestContainer(TinyIoCContainer container, NancyContext context)
        {
            base.ConfigureRequestContainer(container, context);
        }

        protected override void ApplicationStartup(TinyIoCContainer container, IPipelines pipelines)
        {
            base.ApplicationStartup(container, pipelines);
            Nancy.Json.JsonSettings.MaxJsonLength = int.MaxValue;
        }

    }
}