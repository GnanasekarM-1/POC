@RestResource(urlMapping='/svmx/rest/SFMDesigner2ServiceIntf/*')
global class SFMDesigner2ServiceIntf {

    @HttpGet
    global static void doGet() {

        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            SFMDesigner2ServiceImpl impl = new SFMDesigner2ServiceImpl(req, res);
            impl.invokePost();

        }catch(Exception ex){
            throw ex;
        }
    }

    @HttpPost
    global static void doPost() {

        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            SFMDesigner2ServiceImpl impl = new SFMDesigner2ServiceImpl(req, res);
            impl.invokePost();

        }catch(Exception ex){
            throw ex;
        }
    }
}