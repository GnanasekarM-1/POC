global with sharing class IOTMashupExtension {

    
    public IOTMashupExtension(ApexPages.StandardController stdController) {
       
    }
    
    @RemoteAction
    global static Object JsrGetThingInfoFromWorkOrder(String requestStr){
        IOTMashupExtension.GetThingInfoRequest gtr = (IOTMashupExtension.GetThingInfoRequest)
                    JSON.deserialize(requestStr, IOTMashupExtension.GetThingInfoRequest.class);
        
        List<SVMXC__Service_Order__c> sRequests = [select SVMXC__Violation_Message__c, SVMXC__Problem_Description__c, SVMXC__Product__c from SVMXC__Service_Order__c where Id =: gtr.recordId];//, Diagnostic_Session__c, ThingId__c
        
        system.debug('=Queried Data=: ' + sRequests);
        
        IOTMashupExtension.GetThingInfoResponse resp = new
                IOTMashupExtension.GetThingInfoResponse();
        
        if(sRequests != null && sRequests.size() > 0){
            /*if(sRequests[0].Diagnostic_Session__c != null)
                resp.diagnosticSessionId = sRequests[0].Diagnostic_Session__c;*/
            if(sRequests[0].SVMXC__Product__c != null){
                List<Product2> prod= [select Name from Product2 where Id =: sRequests[0].SVMXC__Product__c];
                if(prod != null && prod.size() > 0)
                    resp.thingName = prod[0].Name;
                }
            
            if(sRequests[0].SVMXC__Violation_Message__c != null){
                if(sRequests[0].SVMXC__Violation_Message__c.contains('alertTime')){
                    List<string> lstStr = sRequests[0].SVMXC__Violation_Message__c.split('alertTime : ');
                    if(lstStr != null && lstStr.size() > 0){
                        List<string> lstNextStr = lstStr[1].split('\n');
                        resp.alertDate = lstNextStr[0];
                    }
                    
                }
                if(sRequests[0].SVMXC__Violation_Message__c.contains('sourceProperty')){
                    List<string> lstStr = sRequests[0].SVMXC__Violation_Message__c.split('sourceProperty : ');
                    if(lstStr != null && lstStr.size() > 0){
                        List<string> lstNextStr = lstStr[1].split('\n');
                        resp.alertProperty = lstNextStr[0];
                    }
                }
                if(sRequests[0].SVMXC__Violation_Message__c.contains('name')){
                    List<string> lstStr = sRequests[0].SVMXC__Violation_Message__c.split('name : ');
                    if(lstStr != null && lstStr.size() > 0){
                        List<string> lstNextStr = lstStr[1].split('\n');
                        resp.alertName = lstNextStr[0];
                    }
                }
            }
            //resp.alertDate = string.valueOf(sRequests[0].CreatedDate);
            
        }else{
            resp.thingId = '';
            resp.diagnosticSessionId = '';
            resp.thingName = '';
        }
        
        return JSON.serialize(resp);
    }
    
    @RemoteAction
    global static Object JsrGetThingInfoFromCase(String requestStr){
        IOTMashupExtension.GetThingInfoRequest gtr = (IOTMashupExtension.GetThingInfoRequest)
                    JSON.deserialize(requestStr, IOTMashupExtension.GetThingInfoRequest.class);
        
        List<Case> sRequests = [select Description, Subject, SVMXC__Product__c from Case where Id =: gtr.recordId];
        
        system.debug('=Queried Data=: ' + sRequests);
        
        IOTMashupExtension.GetThingInfoResponse resp = new
                IOTMashupExtension.GetThingInfoResponse();
        
        if(sRequests != null && sRequests.size() > 0){
            if(sRequests[0].SVMXC__Product__c != null){
                List<Product2> prod= [select Name from Product2 where Id =: sRequests[0].SVMXC__Product__c];
                if(prod != null && prod.size() > 0)
                    resp.thingName = prod[0].Name;
                }
                
            if(sRequests[0].Description != null){
                if(sRequests[0].Description.contains('alertTime')){
                    List<string> lstStr = sRequests[0].Description.split('alertTime : ');
                    if(lstStr != null && lstStr.size() > 0){
                        List<string> lstNextStr = lstStr[1].split('\n');
                        resp.alertDate = lstNextStr[0];
                    }
                    
                }
                if(sRequests[0].Description.contains('sourceProperty')){
                    List<string> lstStr = sRequests[0].Description.split('sourceProperty : ');
                    if(lstStr != null && lstStr.size() > 0){
                        List<string> lstNextStr = lstStr[1].split('\n');
                        resp.alertProperty = lstNextStr[0];
                    }
                }
                if(sRequests[0].Description.contains('name')){
                    List<string> lstStr = sRequests[0].Description.split('name : ');
                    if(lstStr != null && lstStr.size() > 0){
                        List<string> lstNextStr = lstStr[1].split('\n');
                        resp.alertName = lstNextStr[0];
                    }
                }
            }
            
            //resp.alertDate = string.valueOf(sRequests[0].CreatedDate);
        }else{
            resp.thingId = '';
            resp.diagnosticSessionId = '';
            resp.thingName = '';
        }
        
        return JSON.serialize(resp);
    }
    
    public class GetThingInfoRequest{
        public String recordId;
    }
    
    public class GetThingInfoResponse{
        public String thingId;
        public String diagnosticSessionId;
        public String thingName;
        public String alertDate;
        public String alertProperty;
        public String alertName;
    }
}