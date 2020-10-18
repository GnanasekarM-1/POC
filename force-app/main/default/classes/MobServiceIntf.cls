@RestResource(urlMapping='/svmx/MobServiceIntf/*')
global class MobServiceIntf
{   
    @HttpPost
    global static void doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        MobServiceImpl impl = new MobServiceImpl(req, res);
        impl.invokePost();
    }
}