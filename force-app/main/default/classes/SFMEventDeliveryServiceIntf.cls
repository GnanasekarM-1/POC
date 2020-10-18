/**
 * SFM Event Delivery service interface
 *
 * @author      Eric Ingram
 * @date        02.22.2013 
 */
@RestResource(urlMapping='/svmx/rest/SFMEventDeliveryServiceIntf/*')
global class SFMEventDeliveryServiceIntf {
    
    @HttpPost
    global static void doPost() {
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            SFMEventDeliveryServiceImpl impl = new SFMEventDeliveryServiceImpl(req, res);
            impl.invokePost();
        }catch(Exception ex){
            throw ex;
        } 
    }
}