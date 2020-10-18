@RestResource(urlMapping='/svmx/SyncGatewayIntf/*')
global class SGAT_SyncGatewayIntf
{
    @HttpPost
    global static void doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        SGAT_SyncGatewayImpl impl = new SGAT_SyncGatewayImpl(req, res);
        impl.invokePost();
    }
    
    @HttpGet
    global static void doGet()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        SGAT_SyncGatewayImpl impl = new SGAT_SyncGatewayImpl(req, res);
        impl.invokeGet();
    }
}