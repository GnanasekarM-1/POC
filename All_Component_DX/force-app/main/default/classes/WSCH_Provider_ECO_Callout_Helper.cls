public class WSCH_Provider_ECO_Callout_Helper {
    
    //public static final String ECO_ENDPOINT_URL = 'https://optimax-test.servicemax.com:8343/optimax/eco';
    public static String[] strEndPoint = WSCH_CommonUtils.getSettingValue('GLOB001','GBL010').split('/optimization');
    public static final String ECO_ENDPOINT_URL = strEndPoint[0]+'/eco';
    public static final String ECO_SCHEDULING_SERVICE_PATH = '/v1/schedule-services';
    public static final String ECO_ASSIGNMENTENTITY_SERVICE_PATH = '/v1/assignmententity-services';
    public static final String ECO_JOB_SERVICE_PATH = '/v1/job-services';
    public static final String ECO_INTI_JOB_METHOD = '/initJob/';
    public static final String ECO_MANAGE_WO_METHOD = '/manageWorkOrders/';
    public static final String ECO_MANAGE_TECH_METHOD = '/manageResources/';
    public static final String ECO_MANAGE_EVENT_METHOD = '/manageEvents/';
    public static final String ECO_MANAGE_SCHD_RESULTS_METHOD = '/getSchedulingResult/';
    public static final String ECO_RESUME_JOB_METHOD = '/resumeECOptimization/';
    public static final String ECO_GET_APPOINTMENT_OFFERS_METHOD = '/getAppointmentOffers/';
    public static final String ECO_BOOK_APPOINTMENT_METHOD = '/bookAppointment/';
    public static final String ECO_SUSPEND_JOB_METHOD = '/pauseECOptimization/';    
    public static final String ECO_SCHEDULING_SERVICE_PATH_WITHOUT_VERSION = '/schedule-services';        
    public static final String ECO_VERSION_2 = '/v2';      
    public static final String ECO_SCHEDULING_SERVICE_PATH_VERSION_2 = ECO_VERSION_2 + ECO_SCHEDULING_SERVICE_PATH_WITHOUT_VERSION; 
    public static final String OPTIMAXSERVICE_ENDPOINT_URL = strEndPoint[0]+'/optimaxService';
    public static final String DELETE_SCHEDULEJOB_PATH = '/v1/deleteScheduleJob';
 
     //FOR LTP
    public static final String LTP_SERVICE_PATH = '/v1/executeJob';
       
    public static WSCH_Provider_ECO_Stubs.Response_WP callOut(String requestJson, String serviceName, String methodName){
        String calloutEndpoint = ECO_ENDPOINT_URL + serviceName + methodName;
        return callOut(requestJson,calloutEndpoint);
    }
    
    public static WSCH_Provider_ECO_Stubs.Response_WP callOut(String requestJson, String calloutEndpoint){
        WSCH_Provider_ECO_Stubs.Response_WP response_x = new WSCH_Provider_ECO_Stubs.Response_WP();        
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::callOut():Callout EndPoint..'+calloutEndpoint);
            request.setEndpoint(calloutEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setTimeout(120000);
            // Set the body as a JSON object
            //String requestJson=JSON.serialize(request_x);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::callOut():request in Json..' +requestJson);
            request.setBody(requestJson);
            HttpResponse response = http.send(request);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::callOut():response in Json..'+response);
            // Parse the JSON response
            if (response.getStatusCode() != 200 && response.getStatusCode() != 202) {
                WSCH_AuditLogger.debug('Exception:-WSCH_Provider_ECO_Callout_Helper::callOut(): The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                response_x.status = String.valueOf(response.getStatusCode());
                response_x.message = response.getStatus();
            } else {
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_Service::callOut(): response - '+response.getBody());
                response_x.status = String.valueOf(response.getStatusCode());
                response_x.message = response.getStatus();
                
            }           
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception occured::WSCH_Provider_ECO_Callout_Helper::callOut(): - '+e.getMessage());
        }   
       //  finally{
       //     //save the request json to capture performance metrics 
      //      WSCH_AuditLogger.debug('Saving the request into a diff log to capture metrics');
       //     if(WSCH_AuditLogger.isLinxMetricLogEnabled) {
       //         WSCH_AuditLogger.saveECORequestJson(requestJson);
       //     }
       // }          
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::callOut():response_x..'+response_x);
        return response_x;
    }
    
    public static WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP apptOfferCallOut(String requestJson, String serviceName, String methodName){
        WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP apptOfferResponse = new WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP();
        String calloutEndpoint = ECO_ENDPOINT_URL + serviceName + methodName;
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::apptOfferCallOut():Callout EndPoint..'+calloutEndpoint);
            request.setEndpoint(calloutEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setTimeout(120000);
            // Set the body as a JSON object
            //String requestJson=JSON.serialize(request_x);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::apptOfferCallOut():request in Json..'+'('+methodName+')'+requestJson);
            request.setBody(requestJson);
            HttpResponse response = http.send(request);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::apptOfferCallOut():response in Json..'+response);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                WSCH_AuditLogger.debug('Exception:-WSCH_Provider_ECO_Callout_Helper::apptOfferCallOut(): The status code returned was not expected: ' +
                    response.getStatusCode() + ' ' + response.getStatus());
            } else {
                String jsonResponse = response.getBody();
                //String jsonResponse = '{"dispatchProcessId": "DP4","territoryId": "Territory4","orgId": "O2","workOrderId": "WO-00008580","appointmentOffers":[{"startDateTime": "2018-04-02 15:41","endDateTime": "2018-04-02 17:41","slotType": null},{"startDateTime": "2018-04-02 17:59","endDateTime": "2018-04-02 19:59","slotCost": 0,"slotType": null},{"startDateTime": "2018-04-03 15:41","endDateTime": "2018-04-03 17:41","slotCost": 0,"slotType": null}],"errorMessage": null}';
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_Service::apptOfferCallOut(): response - '+jsonResponse);
                apptOfferResponse = (WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP)JSON.deserialize(jsonResponse, WSCH_Provider_ECO_Stubs.AppointmentOfferResponse_WP.class);               
            } 
            
            apptOfferResponse.responseWP = new WSCH_Provider_ECO_Stubs.Response_WP();
            apptOfferResponse.responseWP.status  = String.valueOf(response.getStatusCode());
            apptOfferResponse.responseWP.message  = response.getStatus();          
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception occured::WSCH_Provider_ECO_Callout_Helper::apptOfferCallOut(): - '+e.getMessage());
        }           
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::apptOfferCallOut():apptOfferResponse..'+apptOfferResponse);
        return apptOfferResponse;
    }
    
    public static WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP bookApptCallOut(String requestJson, String serviceName, String methodName){
        WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP bookApptResponse = new WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP();
        WSCH_Provider_ECO_Stubs.Response_WP response_x = new WSCH_Provider_ECO_Stubs.Response_WP();
        String calloutEndpoint = ECO_ENDPOINT_URL + serviceName + methodName;
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::callOut():Callout EndPoint..'+calloutEndpoint);
            request.setEndpoint(calloutEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setTimeout(120000);
            // Set the body as a JSON object
            //String requestJson=JSON.serialize(request_x);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::callOut():request in Json..'+'('+methodName+')'+requestJson);
            request.setBody(requestJson);
            HttpResponse response = http.send(request);
            WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::callOut():response in Json..'+response);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                WSCH_AuditLogger.debug('Exception:-WSCH_Provider_ECO_Callout_Helper::callOut(): The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                response_x.status = String.valueOf(response.getStatusCode());
                response_x.message = response.getStatus();
            } else {
                WSCH_AuditLogger.debug('WSCH_Provider_ECO_Service::callOut(): response - '+response.getBody());
                String jsonResponse = response.getBody();
                bookApptResponse = (WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP)JSON.deserialize(jsonResponse, WSCH_Provider_ECO_Stubs.BookAppointmentResponse_WP.class);
                bookApptResponse.responseWP = new WSCH_Provider_ECO_Stubs.Response_WP();
                bookApptResponse.responseWP.status  = String.valueOf(response.getStatusCode());
                bookApptResponse.responseWP.message  = response.getStatus();
                //response_x.status = String.valueOf(response.getStatusCode());
                //response_x.message = response.getStatus();
            }           
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception occured::WSCH_Provider_ECO_Callout_Helper::callOut(): - '+e.getMessage());
        }           
        WSCH_AuditLogger.debug('WSCH_Provider_ECO_Callout_Helper::callOut():response_x..'+bookApptResponse);
        return bookApptResponse;
    }
}