/**
    Will contains Push notification implementation methods using REST Webservice for Optimax ECO.
**/
@RestResource(urlMapping='/scheduling/eco/changeditems')
Global with sharing class WSCH_Provider_ECO_ChangedItems {
    
    /*
        Process Push notification does the following.

        1. Retrive job name and check if its available in service max. if No return
        2. Process booking details received from push notification and update the scheduling details in Work order.
        3. Create the corresponding work order events.
    */

    @HttpPost
    global static Integer doPost() {
        Long startTime = Datetime.now().getTime();
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        Blob data = request.requestBody;
        String changeReq = data.toString();
        Integer response = 0;
        try{
            //Check if Push notification is enabled or not if not enabled skip processing push notifications.
            if('True' == WSCH_CommonUtils.getSettingValue('DCON004','SET010')){         
                if(changeReq != null) {
                    response = doProcessRestRequest(changeReq);
                    WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems :: doPost() :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
                    WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
                }           
            }
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_ECO_ChangedItems::doPost():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
        }finally{
            WSCH_AuditLogger.finish();
        }
        return response;
    }
    
    /*  - insert json request into Optimizer transaction object
        - Optimizer Status "PUSH_REQUEST", Optimizer Error Text = json request
        - parsing JSON request into Push stubs      
        - send the stubs and optimizer transaction id into Helper class to process the stubs.*/
    
    public static Integer doProcessRestRequest(String request){
        Integer response = 0;
        Boolean result = false;
        try{
            //parsing JSON request into Push stubs
            request = request.replace('"end"','"end_x"');
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems::doProcessRestRequest():: JSON Request :'+request);
            WSCH_Provider_ECO_Push_Stubs.PushRequest req = (WSCH_Provider_ECO_Push_Stubs.PushRequest)JSON.deserialize(request, WSCH_Provider_ECO_Push_Stubs.PushRequest.class);            
            //WSCH_AuditLogger.debug('WSCH_Provider_ECO_ChangedItems::doProcessRestRequest():: After parsing to Stubs:'+req);
            
            //WSCH_AuditLogger.rca('The Scheduling Status of the push request is '+req.state); 
              
            if(req.workItems != null && req.workItems.size() > 0){
                result = WSCH_Provider_ECO_ChangedItems_Helper.doProcessRequest(req);  
            }
            
            if(!result) {
                response = -1;
            }   
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_ECO_ChangedItems::doProcessRestRequest():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            response = -1;     
        }
        return response;
    }
}