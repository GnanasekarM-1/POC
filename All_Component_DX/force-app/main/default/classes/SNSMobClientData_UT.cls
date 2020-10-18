@isTest
public class SNSMobClientData_UT 
{   
    static testMethod void loginSNSDetails()
    {

        RestRequest newRequest = new RestRequest();
        newRequest.requestURI='services/apexrest/SVMXC/svmx/SNSMobClientData';
        newRequest.httpMethod = 'POST';  
        String body ='{"groupId":"00DJ0000003LMuBMAW","eventType":"PULSE","userId":"'+Userinfo.getUserId()+'","profileId":"005J0000005twhOIAQ","value":"3EA57177-3871-4160-8300-3253F7947CA7","eventName":"LOGGEDIN","clientInfo":[{"clientType":"iPad","clientInfo":["iosversion:9.3.4","appversion:16.49.011","deviceversion:iPad3,6","appname:SVMX_iPad","userid:005J0000005twhOIAQ","clientudid:143F3096-D33B-422B-98BF-4F3A2DA28BEB","syncstarttime:2016-08-10 09:09:44"]}],"valueMap":[{"key":"Fields","value":"","valueMap":[{"key":"SVMXC__Latitude__c","value":"12.9721"},{"key":"SVMXC__Longitude__c","value":"77.6187"}]}],"values":[]}';
        INTF_WebServicesDef.INTF_SFMRequest requestIn = (INTF_WebServicesDef.INTF_SFMRequest)JSON.deserialize(body,INTF_WebServicesDef.INTF_SFMRequest.class);   
        newRequest.RequestBody=(Blob.valueOf(JSON.serialize(requestIn)));
        RestContext.Request = newRequest;
        INTF_WebServicesDef.INTF_SFMResponse newResponse = SNSMobClientData.insertClientDetails(requestIn);

        newRequest = new RestRequest();
        newRequest.requestURI='services/apexrest/SVMXC/svmx/SNSMobClientData';
        newRequest.httpMethod = 'POST';          
        body ='{"groupId":"00DJ0000003LMuBMAW","eventType":"PULSE","userId":"'+Userinfo.getUserId()+'","profileId":"005J0000005twhOIAQ","value":"3EA57177-3871-4160-8300-3253F7947CA7","eventName":"LOGGEDOUT","clientInfo":[{"clientType":"iPad","clientInfo":["iosversion:9.3.4","appversion:16.49.011","deviceversion:iPad3,6","appname:SVMX_iPad","userid:005J0000005twhOIAQ","clientudid:143F3096-D33B-422B-98BF-4F3A2DA28BEB","syncstarttime:2016-08-10 09:09:44"]}],"valueMap":[{"key":"Fields","value":"","valueMap":[{"key":"SVMXC__Latitude__c","value":"12.9721"},{"key":"SVMXC__Longitude__c","value":"77.6187"}]}],"values":[]}';        
        requestIn = (INTF_WebServicesDef.INTF_SFMRequest)JSON.deserialize(body,INTF_WebServicesDef.INTF_SFMRequest.class);   
        newRequest.RequestBody=(Blob.valueOf(JSON.serialize(requestIn)));
        RestContext.Request = newRequest;
        newResponse = SNSMobClientData.insertClientDetails(requestIn);        
        
    }
    static testMethod void updateLoginSNSDetails()
    {
        SVMXC__SM_SNS_Detail__c newDetail = new SVMXC__SM_SNS_Detail__c();
        newDetail.SVMXC__SM_User__c=Userinfo.getUserId();
        newDetail.SVMXC__SM_TargetArn__c='3EA57177-3871-4160-8300-3253F7947CA7';
        insert newDetail;
        RestRequest newRequest = new RestRequest();
        newRequest.requestURI='services/apexrest/SVMXC/svmx/SNSMobClientData';
        newRequest.httpMethod = 'POST';  
        String body ='{"groupId":"00DJ0000003LMuBMAW","eventType":"PULSE","userId":"'+Userinfo.getUserId()+'","profileId":"005J0000005twhOIAQ","value":"3EA57177-3871-4160-8300-3253F7947CA7","eventName":"LOGGEDIN","clientInfo":[{"clientType":"iPad","clientInfo":["iosversion:9.3.4","appversion:16.49.011","deviceversion:iPad3,6","appname:SVMX_iPad","userid:005J0000005twhOIAQ","clientudid:143F3096-D33B-422B-98BF-4F3A2DA28BEB","syncstarttime:2016-08-10 09:09:44"]}],"valueMap":[{"key":"Fields","value":"","valueMap":[{"key":"SVMXC__Latitude__c","value":"12.9721"},{"key":"SVMXC__Longitude__c","value":"77.6187"}]}],"values":[]}';
        INTF_WebServicesDef.INTF_SFMRequest requestIn = (INTF_WebServicesDef.INTF_SFMRequest)JSON.deserialize(body,INTF_WebServicesDef.INTF_SFMRequest.class);   
        newRequest.RequestBody=(Blob.valueOf(JSON.serialize(requestIn)));
        RestContext.Request = newRequest;
        INTF_WebServicesDef.INTF_SFMResponse newResponse = SNSMobClientData.insertClientDetails(requestIn);
    }    
    static testMethod void loggoutSNSDetails()
    {

        RestRequest newRequest = new RestRequest();
        newRequest.requestURI='services/apexrest/SVMXC/svmx/SNSMobClientData';
        newRequest.httpMethod = 'POST';  
        String body ='{"groupId":"00DJ0000003LMuBMAW","eventType":"PULSE","userId":"'+Userinfo.getUserId()+'","profileId":"005J0000005twhOIAQ","value":"3EA57177-3871-4160-8300-3253F7947CA7","eventName":"LOGGEDOUT","clientInfo":[{"clientType":"iPad","clientInfo":["iosversion:9.3.4","appversion:16.49.011","deviceversion:iPad3,6","appname:SVMX_iPad","userid:005J0000005twhOIAQ","clientudid:143F3096-D33B-422B-98BF-4F3A2DA28BEB","syncstarttime:2016-08-10 09:09:44"]}],"valueMap":[{"key":"Fields","value":"","valueMap":[{"key":"SVMXC__Latitude__c","value":"12.9721"},{"key":"SVMXC__Longitude__c","value":"77.6187"}]}],"values":[]}';
        INTF_WebServicesDef.INTF_SFMRequest requestIn = (INTF_WebServicesDef.INTF_SFMRequest)JSON.deserialize(body,INTF_WebServicesDef.INTF_SFMRequest.class);   
        newRequest.RequestBody=(Blob.valueOf(JSON.serialize(requestIn)));
        RestContext.Request = newRequest;
        INTF_WebServicesDef.INTF_SFMResponse newResponse = SNSMobClientData.insertClientDetails(requestIn);
    }
    static testMethod void getSNSDetails()
    {

        RestRequest newRequest = new RestRequest();
        newRequest.requestURI='services/apexrest/SVMXC/svmx/SNSMobClientData';
        newRequest.httpMethod = 'POST';  
        String body ='{"groupId":"00DJ0000003LMuBMAW","eventType":"PULSE","userId":"'+Userinfo.getUserId()+'","profileId":"005J0000005twhOIAQ","value":"3EA57177-3871-4160-8300-3253F7947CA7","eventName":"GETPULSECONFIG","clientInfo":[{"clientType":"iPad","clientInfo":["iosversion:9.3.4","appversion:16.49.011","deviceversion:iPad3,6","appname:SVMX_iPad","userid:005J0000005twhOIAQ","clientudid:143F3096-D33B-422B-98BF-4F3A2DA28BEB","syncstarttime:2016-08-10 09:09:44"]}],"valueMap":[{"key":"Fields","value":"","valueMap":[{"key":"SVMXC__Latitude__c","value":"12.9721"},{"key":"SVMXC__Longitude__c","value":"77.6187"}]}],"values":[]}';
        INTF_WebServicesDef.INTF_SFMRequest requestIn = (INTF_WebServicesDef.INTF_SFMRequest)JSON.deserialize(body,INTF_WebServicesDef.INTF_SFMRequest.class);   
        newRequest.RequestBody=(Blob.valueOf(JSON.serialize(requestIn)));
        RestContext.Request = newRequest;
        INTF_WebServicesDef.INTF_SFMResponse newResponse = SNSMobClientData.insertClientDetails(requestIn);
    }    
    static testMethod void exceptionSNSDetails()
    {
        try
        {
            INTF_WebServicesDef.INTF_SFMRequest newRequest;
            INTF_WebServicesDef.INTF_SFMResponse newResponse = SNSMobClientData.insertClientDetails(newRequest);
        }
        catch(Exception ExceptionalHandling)
        {
            
        }
    }        
}