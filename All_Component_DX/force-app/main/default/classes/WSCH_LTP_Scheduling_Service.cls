@RestResource(urlMapping='/scheduling/batch/results')
global with sharing class WSCH_LTP_Scheduling_Service {

    public static final String NO_OP_ERROR_MESSAGE = 'Empty or Invalid operation type';

    public class SVMXException extends Exception{}
    SVMXC.COMM_Utils_ManageSettings clsCommSettings = new SVMXC.COMM_Utils_ManageSettings();

    
    @HttpPost
    global static WSCH_LTP_Scheduling_Stubs.Response_WP doPost() {
        WSCH_LTP_Scheduling_Stubs.Response_WP response = new WSCH_LTP_Scheduling_Stubs.Response_WP();
        RestRequest request = RestContext.request;
        Blob data = request.requestBody;
        String SchedulingOutputReq = data.toString();
        try {
            WSCH_AuditLogger.debug('WSCH_LTP_Scheduling_Service::doPost::Json Request: ' + SchedulingOutputReq);
            WSCH_LTP_Scheduling_Stubs.SchedulingOutputRequest_WP req = (WSCH_LTP_Scheduling_Stubs.SchedulingOutputRequest_WP)JSON.deserialize(SchedulingOutputReq, WSCH_LTP_Scheduling_Stubs.SchedulingOutputRequest_WP.class);
            response = doProcessResults(req);
        } catch(Exception ex){
            WSCH_AuditLogger.error('WSCH_LTP_Scheduling_Service::doPost():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());         
        } finally{
            WSCH_AuditLogger.finish();
        }
        return response;
    }
    
    public static WSCH_LTP_Scheduling_Stubs.Response_WP doProcessResults(WSCH_LTP_Scheduling_Stubs.SchedulingOutputRequest_WP req) {
        WSCH_LTP_Scheduling_Stubs.Response_WP resp = new WSCH_LTP_Scheduling_Stubs.Response_WP();
        Boolean result = false;
        
        if(req.exceptionMsgCode != null){
            WSCH_AuditLogger.debug('WSCH_LTP_Initiate_Service::doProcessResults::exception message.: ' + req.exceptionMsg);
        }
        if(req.routes != null && req.routes.size() > 0){
            result = WSCH_LTP_SchedulingService_Handler.processRoutes(req.routes); 
            resp.status = 'Success';
            resp.message = 'Route processing completed.';           
        }
        
        if(req.schedulingJobStatistics != null ){
            result = WSCH_LTP_SchedulingService_Handler.processStatistics(req.schedulingJobStatistics, req.jobInstanceGuid);
            resp.status = 'Success';
            resp.message = 'Statistics processing completed.';          
        }
        if(req.unassignedSchedulingElements != null && req.unassignedSchedulingElements.size() > 0){
            result = WSCH_LTP_SchedulingService_Handler.processUnAssignedElements(req.unassignedSchedulingElements);    
            resp.status = 'Success';
            resp.message = 'UnAssigned Scheduling Elements processing completed.';             
        }
        
        if(req.badSchedulingElements != null && req.badSchedulingElements.size() > 0){
            result = WSCH_LTP_SchedulingService_Handler.processBadElements(req.badSchedulingElements);  
            resp.status = 'Success';
            resp.message = 'Bad Scheduling Elements processing completed.';             
        }
        
        /*if(req.resolvedSchedulingElements != null && req.resolvedSchedulingElements.size() > 0 ){
            //result = WSCH_LTP_SchedulingService_Handler.processBadElements(req.resolvedSchedulingElements);    
        }*/
        
        return resp;
    }    
        
}