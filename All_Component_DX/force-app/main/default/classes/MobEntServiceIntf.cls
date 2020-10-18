@RestResource(urlMapping='/svmx/MobEntServiceIntf/*')
global class MobEntServiceIntf
{   
    @HttpPost
    global static void doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        MobEntServiceImpl impl = new MobEntServiceImpl(req, res);
        impl.invokePost();
    }
}