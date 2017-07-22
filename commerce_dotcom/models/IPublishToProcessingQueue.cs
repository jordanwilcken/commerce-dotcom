namespace commerce_dotcom.models
{
    public interface IPublishToProcessingQueue
    {
        void BasicPublish(string routingKey, byte[] messageBody);
    }
}
