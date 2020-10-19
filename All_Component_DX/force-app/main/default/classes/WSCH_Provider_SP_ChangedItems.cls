/**
    Will contains Push notification implementation methods using REST Webservice.
**/
@RestResource(urlMapping='/scheduling/sp/changeditems')
//Global class WSCH_Provider_SP_ChangedItems {
Global with sharing class WSCH_Provider_SP_ChangedItems {

    /*
        Process Push notification does the following.

        1. Retrive job name and check if its available in service max. if No return
        2. Process booking details received from push notification and update the scheduling details in Work order.
        3. Create the corresponding work order events.
    */

    @HttpPost
    global static Integer doPost() {
        Long startTime = Datetime.now().getTime();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Blob data = req.requestBody;
        String changeReq = data.toString();
        Integer response = 0;
        try{
            //Check if Push notification is enabled or not if not enabled skip processing push notifications.
            if('True' == WSCH_CommonUtils.getSettingValue('DCON004','SET010')){         
                if(changeReq != null) {
                    response = doProcessRestRequest(changeReq);
                    WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems :: doPost() :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
                    WSCH_AuditLogger.setApexCPUTime((Integer) (Datetime.now().getTime() - startTime));
                    //WSCH_Provider_SP_ChangedItems.saveToAuditLogger('WSCH_Provider_SP_ChangedItems :: doPost() :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime), (double)(Datetime.now().getTime() - startTime));
                    //system.debug(LoggingLevel.error, 'WSCH_Provider_SP_ChangedItems :: doPost() :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
                }
            }
            //WSCH_Provider_SP_ChangedItems.testFunction();
            //WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems :: doPost() :: Response Time (In Milli Seconds) :: '+ (Datetime.now().getTime() - startTime));
            
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems::doPost():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
        }finally{
            WSCH_AuditLogger.finish();
        }
        return response;
    }
    
    /*public static void testFunction() {
        WSCH_AuditLogger.debug('Inside testFunction() start');
        List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
        for(Integer i=0;i<1000;i++) {
            SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
            wo.SVMXC__Street__c = 'street1';
            
            lstWO.add(wo);
        }
        Database.insert(lstWO);
        WSCH_AuditLogger.debug('Inside testFunction() end');    
    }*/
    
    /*public static void saveToAuditLogger(String logMsg, double cpuTime) {
        
        SVMXC__SVMX_Job_Logs__c svmxLogs = new SVMXC__SVMX_Job_Logs__c();
        svmxLogs.SVMXC__Message__c = logMsg;
        svmxLogs.SVMXC__Log_Timestamp__c = DateTime.now();
        svmxLogs.SVMXC__Type__c='ServicePower';
        svmxLogs.SVMXC__Apex_CPU_Time__c = cpuTime;
        insert svmxLogs;
    }*/

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
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems::doProcessRestRequest():: JSON Request :'+request);
            system.debug(LoggingLevel.ERROR, 'WSCH_Provider_SP_ChangedItems::doProcessRestRequest():: JSON Request :'+request);
            WSCH_Provider_SP_Push_Stubs.PushRequest req = (WSCH_Provider_SP_Push_Stubs.PushRequest)JSON.deserialize(request, WSCH_Provider_SP_Push_Stubs.PushRequest.class);            
            WSCH_AuditLogger.debug('WSCH_Provider_SP_ChangedItems::doProcessRestRequest():: After parsing to Stubs:'+req);
            if(req.workItems != null && req.workItems.size() > 0){
                WSCH_Provider_SP_Push_Stubs.WorkItem workItem =req.workItems[0];
                if(workItem.booking != null){
                    //insert json request into Optimizer transaction object
                    SVMXC__SVMX_Optimizer__c optimizerObj = new SVMXC__SVMX_Optimizer__c();
                    optimizerObj.SVMXC__WhatType__c = 'PUSH_REQUEST_JSON';
                    optimizerObj.SVMXC__Optimizer_Error_Text__c = request;
                    //insert optimizerObj;
                    result = WSCH_Provider_SP_ChangedItems_Helper.doProcessRequest(optimizerObj, req);
                    //if push notification processing fails, set the response code to -1
                    if(!result) {
                        response = -1;
                    }
                }else{
                    //this notifications comes due to job de allocation.
                    //So need to remove the event for the work order and update status and token in WO same as force book.
                    WSCH_Provider_SP_ChangedItems_Helper.deAllocateJobs(req);
                }           
            }    
        }catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_Provider_SP_ChangedItems::doProcessRestRequest():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());           
            response = -1;
        }
        return response;
    }
}