using Nancy;

namespace commerce_dotcom.nancy_modules
{
    public class RootModule : NancyModule
    {
        public RootModule()
        {
            Get["/"] = _ => Response.AsRedirect("content/index.html");
        }
    }
}
