@RestResource(urlMapping='/scheduling/batch/stage/*')
global with sharing class WSCH_LTP_Stage_Service { 
    public static final String NO_OP_ERROR_MESSAGE = 'Empty or Invalid operation type';
    public class SVMXException extends Exception{}
    SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();
 
    @HttpPost
    global static WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP doPost() {
        RestRequest request = RestContext.request;
        String elementType = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        WSCH_AuditLogger.debug('WSCH_LTP_Stage_Service::doPost::elementType: ' + elementType);
        Blob data = request.requestBody;
        String inputReq = data.toString();
        WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP res = new WSCH_LTP_Scheduling_Stubs.SchedulingInputResponse_WP();
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        //boolean isUpdateReq = false;
        try {
            WSCH_AuditLogger.debug('WSCH_LTP_Stage_Service::doPost::Json Request: ' + inputReq);
            WSCH_LTP_Scheduling_Stubs.SchedulingInputRequest_WP req = (WSCH_LTP_Scheduling_Stubs.SchedulingInputRequest_WP)JSON.deserialize(inputReq, WSCH_LTP_Scheduling_Stubs.SchedulingInputRequest_WP.class);
            objSVMXJob = [Select Id, SVMXC__Status__c, SVMXC__Age__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__SVMX_Process__c,
                        SVMXC__Territory__c, SVMXC__OptiMax_Message__c,SVMXC__Type__c from SVMXC__SVMX_Jobs__c where Id = :req.jobInstanceGuid]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WSCH_AuditLogger.debug('WSCH_LTP_Stage_Service::doPost::objSVMXJob:'+objSVMXJob);
            //update job records once when staging starts
            /*if(objSVMXJob.SVMXC__OptiMax_Message__c.equalsIgnoreCase('Initiated')){
                objSVMXJob.SVMXC__OptiMax_Message__c='Staging';
                isUpdateReq = true;
            }*/
            WSCH_AuditLogger.debug('WSCH_LTP_Stage_Service::doPost::afer parsing Json: ' + req.Ids);
            if('workOrder'.equalsIgnoreCase(elementType)){
                res = WSCH_LTP_StageService_Handler.doPrepareWorkOrderWP(req.Ids, objSVMXJob);
            }else if('resource'.equalsIgnoreCase(elementType)){
                res = WSCH_LTP_StageService_Handler.doPrepareTechnicianWP(req.Ids, objSVMXJob);
            }else if('event'.equalsIgnoreCase(elementType)){
                res = WSCH_LTP_StageService_Handler.doPrepareTechnicianEventWP(req.Ids, objSVMXJob);
            }
            WSCH_AuditLogger.debug('WSCH_LTP_Stage_Service::doPost::response: ' + res);
            //if(isUpdateReq)
                //update objSVMXJob;
                
            WSCH_AuditLogger.finish();  
        } catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_LTP_Stage_Service::doPost():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());  
            WSCH_AuditLogger.finish(); 
        } finally{
            WSCH_AuditLogger.finish();
        }
        return res;
    } 
}