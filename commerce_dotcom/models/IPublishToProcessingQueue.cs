namespace commerce_dotcom.models
{
    public interface IPublishToProcessingQueue
    {
        void BasicPublish(byte[] messageBody);
    }
}
