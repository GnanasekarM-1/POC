/**
 * This class is used for invoking various webservices hosted on Analytics stack. 
 * It authenticates the configured user in custom-setting using oauth server before firing the request. 
 * 
 * @author - Praveen.R
 **/
global class AnalyticsRestServices {
    
    class AuthToken {        
        private String access_token;
        private String token_type;
        private String scope;
        private String expires_in;
        private String refresh_token;
    }
    

    class SkillSetData {
        private String skillName;
        private String skillLevel;
        private String isSkillMandatory;
    }
    
    class TechnicianData {
        private String Name;
        private List<SkillSetData> skillSet;
    }
    
    class ResponseBody {
        String message;
        String value;
        String workorderId;
    }
       
    /**
     * Invoked to compute the MTTS value for the passed in work-order and technician information on Analytics stack.
     * Accepts workorderId and technicianId as input for building the data as json. 
     */
    //@Future(callout=true)
    @TestVisible WebService static Integer predictMTTS(String workorderId, String technicianId) {
    
        System.debug(LoggingLevel.Debug, 'AnalyticsRestServices.predictMTTS.Begin()');
        
        System.debug(LoggingLevel.Debug, 'workorderId - ' + workorderId);
        System.debug(LoggingLevel.Debug, 'technicianId - ' + technicianId);
        
        Integer predictedValue = 0;
            
        List<SVMXC__ANA_OAuth_Settings__c> settings = SVMXC__ANA_OAuth_Settings__c.getall().values();       
        System.debug(LoggingLevel.Debug, 'Loaded settings count - ' + settings.size());        
        if(settings.isEmpty()) {
            return 0;
        }                
        String clientId = settings[0].SVMXC__client_id__c;
        String oAuthURL = settings[0].SVMXC__OAuth_URL__c;
        String clientSecret = settings[0].SVMXC__client_secret__c;
        String username = settings[0].SVMXC__username__c;
        String password = settings[0].SVMXC__password__c;
        String anaWebappURL = settings[0].SVMXC__ANA_URL__c;
    
        
        AuthToken authTokenValue = getOAuthToken(clientId, clientSecret, username, password, oAuthURL);
        if(authTokenValue == null) {
            System.debug(LoggingLevel.INFO, 'Auth Token is empty hence setting the predicted value as zero');
            return 0;
        }
        
        try {
            //Load the required fields from work-order object
            //Load the Technician and relevant skill information
            
            //Changes for security scan.
            List<String> queryFields = new List<String> {'Name'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Group_Members__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
                
            SVMXC__Service_Group_Members__c technicianRecord = 
                [Select Name from SVMXC__Service_Group_Members__c where Id=:technicianId];
            

            //Changes for security scan.
            queryFields = new List<String> {'Name','SVMXC__Product__r.Name','SVMXC__Product__c','SVMXC__Top_Level__c','SVMXC__Top_Level__r.Name','SVMXC__Component__c','SVMXC__Component__r.Name','SVMXC__Group_Member__c',' SVMXC__Group_Member__r.Name','SVMXC__Order_Type__c','SVMXC__Skill_Set__c','SVMXC__Priority__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            
            //Parse the work-order information.
            SVMXC__Service_Order__c workOrder = 
                                            [Select Name, SVMXC__Product__r.Name, SVMXC__Product__c, 
                                             SVMXC__Top_Level__c,SVMXC__Top_Level__r.Name,
                                             SVMXC__Component__c, SVMXC__Component__r.Name,
                                             SVMXC__Group_Member__c, SVMXC__Group_Member__r.Name,
                                             SVMXC__Order_Type__c, SVMXC__Skill_Set__c,
                                             SVMXC__Priority__c from SVMXC__Service_Order__c 
                                             where Id=:workorderId];

            Map<String, Object> workOrderMap = new Map<String, Object>();
            workOrderMap.put('Name', workOrder.Name);
            workOrderMap.put('SVMXC__Product__r.Name', workOrder.SVMXC__Product__r.Name);
            workOrderMap.put('SVMXC__Top_Level__r.Name', workOrder.SVMXC__Top_Level__r.Name);
            workOrderMap.put('SVMXC__Component__r.Name', workOrder.SVMXC__Component__r.Name);
            workOrderMap.put('SVMXC__Order_Type__c', workOrder.SVMXC__Order_Type__c);
            workOrderMap.put('SVMXC__Priority__c', workOrder.SVMXC__Priority__c);       
                    
        
            //Populate the technician Information
            Map<String, Object> technicianMap = new Map<String, Object>();
            technicianMap.put('Name', technicianRecord.Name);
        
            //Changes for security scan.
            queryFields = new List<String> {'SVMXC__Skill__c','SVMXC__Skill__r.Name','SVMXC__Skill_Level__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Group_Skills__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            //Populate the technician skillset information
            Map<String, String> technicianSkillsMap = new Map<String, String>();
            for(SVMXC__Service_Group_Skills__c expertValue: [Select SVMXC__Skill__c, SVMXC__Skill__r.Name, SVMXC__Skill_Level__c
                                                                        from SVMXC__Service_Group_Skills__c where
                                                                        SVMXC__Group_Member__c=:technicianId]) {
                technicianSkillsMap.put(expertValue.SVMXC__Skill__r.Name, expertValue.SVMXC__Skill_Level__c.format());
            }   
            technicianMap.put('skillSet', technicianSkillsMap);
            workOrderMap.put('technician', technicianMap);

            String data = JSON.serialize(workOrderMap);
            System.debug(LoggingLevel.DEBUG, 'Work-order data - ' + data);
            //Transfer the json data to ANA Webservice for prediction
            try {
                HTTPResponse response = invokeRestService(data, authTokenValue.access_token, anaWebappURL + '/core/v1/predictMTTS','POST', 'application/json' );
                System.debug(LoggingLevel.DEBUG,'Response - ' + response);
            } catch(Exception ex){
                System.debug(LoggingLevel.ERROR, ex.getMessage());
            }
            
            try {
                System.debug(LoggingLevel.DEBUG, 'Get the predicted value');
                ResponseBody body = getPredictedValue(String.valueOf(workOrder.Name), authTokenValue.access_token, anaWebappURL);
                System.debug(LoggingLevel.DEBUG, 'Response Body - ' + body);
                predictedValue = Integer.valueOf(body.value);
            } catch(Exception ex){
                System.debug(LoggingLevel.ERROR, ex.getMessage());
            }
            
            workOrder.SVMXC__Service_Duration__c = predictedValue;
            
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(workOrder, COMM_SecurityUtils.Access.Updateable)){
                update workOrder;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
       } catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
       }
        
       System.debug(LoggingLevel.Debug, 'AnalyticsRestServices.predictMTTS.End()');
       return predictedValue;
    }

    /**
     * Invokes the HTTP Request to get the predicted value.
     **/
    private static ResponseBody getPredictedValue(String data, String access_token, String anaWebappURL) {
        System.debug(LoggingLevel.DEBUG, 'AnalyticsRestServices.getPredictedValue - Begin()');
        //Integer predictedValue = 0;
        
        //wiat for 3 seconds and fire the request. Re-try it for 3 times on failure.
        Integer retryCount = 0;
        ResponseBody jsonBody = null;
        while(retryCount++ < 3) {
            System.debug(LoggingLevel.INFO,'Waiting for three seconds before firing the request');
            
            Long startTime = System.now().getTime(); 
            Integer delayInMilliseconds = 3000; // three seconds
            while (System.now().getTime() - startTime < delayInMilliseconds) {
                //Wait for three seconds.
            }
            System.debug(LoggingLevel.DEBUG, 'Request Count - ' + retryCount);
    
            System.debug(LoggingLevel.INFO,'Firing the get service');
            
            HttpRequest httpRequest = new HttpRequest();
                httpRequest.setEndpoint(anaWebappURL + '/core/v1/getPredictedValue/'+ data +'/MTTS' );
                httpRequest.setMethod('GET');
    
                httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                httpRequest.setHeader('access_token', access_token);
                
                Http http = new Http();
                HTTPResponse response = new HTTPResponse();
                
                System.debug(LoggingLevel.Debug, 'Sending the request');
                System.debug(LoggingLevel.Debug,'httpRequest - '+httpRequest);
                
                if( !Test.isRunningTest() ) {
                    response = http.send(httpRequest);    
                }
                System.debug(LoggingLevel.DEBUG,'response - '+response.getBody());
            
            /*
            HTTPResponse response = invokeRestService(
                data, access_token, anaWebappURL + '/core/v1/getPredictedValue/'+ data +'/MTTS', 'GET', 'application/x-www-form-urlencoded');
            */
            
            String body = response.getBody();
            System.debug(LoggingLevel.DEBUG,'Body -' + body);
            
            
            jsonBody = (ResponseBody)JSON.deserialize(body, ResponseBody.class);
            System.debug(LoggingLevel.DEBUG,'JSON - '+jsonBody);
            
            String value = jsonBody.value;
            System.debug(LoggingLevel.DEBUG,'Predicted Value - ' + value);
            if(value != 'null') {
                break;
            }
        }
        System.debug(LoggingLevel.Debug, 'AnalyticsRestServices.getPredictedValue - End()');
        return jsonBody;
    }
    
    
    /**
     * Computes the repair time for the passed in workorder and sends this information to Ana-Stack.
     **/
    @Future(callout=true)
    @TestVisible public static void pushMTTRValue(String workorderId) {
        System.debug(LoggingLevel.Debug,'AnalyticsRestServices.pushMTTRValue.Begin()');
        System.debug(LoggingLevel.Debug, 'workorderId - '+workorderId);
        List<SVMXC__ANA_OAuth_Settings__c> settings = SVMXC__ANA_OAuth_Settings__c.getall().values();       
        System.debug(LoggingLevel.Debug, 'Loaded settings count - ' + settings.size());        
        if(settings.isEmpty()) {
            return;
        }                
        String clientId = settings[0].SVMXC__client_id__c;
        String oAuthURL = settings[0].SVMXC__OAuth_URL__c;
        String clientSecret = settings[0].SVMXC__client_secret__c;
        String username = settings[0].SVMXC__username__c;
        String password = settings[0].SVMXC__password__c;
        String anaWebappURL = settings[0].SVMXC__ANA_URL__c;
    
        
        AuthToken authTokenValue = getOAuthToken(clientId, clientSecret, username, password, oAuthURL);
        if(authTokenValue == null) {
            return;
        }
        try {
            //Get the Business hours from the org settings.
            BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
            String bussinessHoursId = defaultBH.Id;
            
            //Get the list of work-order details list of type labour
            Integer laborTime = 0;
            
            //Changes for security scan.
            List<String> queryFields = new List<String> {'SVMXC__Actual_Quantity2__c','SVMXC__Start_Date_and_Time__c','SVMXC__End_Date_and_Time__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Order_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            
            for(SVMXC__Service_Order_Line__c orderLine : 
                [select SVMXC__Actual_Quantity2__c, SVMXC__Start_Date_and_Time__c, SVMXC__End_Date_and_Time__c 
                 from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c=:workorderId and SVMXC__Line_Type__c = 'Labor']) {
                     
                     if(orderLine.SVMXC__Actual_Quantity2__c != null) {
                        laborTime += (Integer)(orderLine.SVMXC__Actual_Quantity2__c * 60);
                     } else {
                         
                        Datetime startDateAndTime = orderLine.SVMXC__Start_Date_and_Time__c;
                        Datetime endDateAndTime = orderLine.SVMXC__End_Date_and_Time__c;
                        if(startDateAndTime != null && endDateAndTime != null && bussinessHoursId != null){
                            Long milliSec = BusinessHours.diff(bussinessHoursId, startDateAndTime,endDateAndTime);
                            Long duration = (milliSec/1000/60);
                            laborTime += (Integer) duration;
                            System.debug(LoggingLevel.DEBUG, 'startDateAndTime: ' + startDateAndTime + '; endDateAndTime: ' + endDateAndTime + '; duration: ' + duration );
                        }                     
                     }
                 }
            System.debug('Repair time - ' + laborTime);
            
            //Create a json data object and fire the request.
            Map<String, String> dataMap = new Map<String, String>();
            dataMap.put('workorderId', workorderId);
            dataMap.put('repairTime', laborTime.format());
            
            String data = JSON.serialize(dataMap);
            invokeRestService(data, authTokenValue.access_token, anaWebappURL + '/core/v1/predictMTTS', 'POST', 'application/json'); //TODO - Replace this with the actual service.
        } Catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }   
        System.debug(LoggingLevel.Debug,'AnalyticsRestServices.pushMTTRValue.End()');
    }

    /**
     * Invoked HTTP Rest service using the passed in data, access_token and url.
     **/
    private static HTTPResponse invokeRestService(String data, String access_token, String url, String requestType, String contentType) {
        System.debug(LoggingLevel.DEBUG, 'Data to be transferred - ' + data);
        System.debug(LoggingLevel.DEBUG, 'access_token - ' + access_token);
        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(url);
        httpRequest.setMethod(requestType);//'POST');
        httpRequest.setBody(data);
        httpRequest.setHeader('access_token',access_token);
        httpRequest.setHeader('Content-Type',contentType); // 'application/json');
        
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();
        
        System.debug(LoggingLevel.Debug, 'Sending the request');
        System.debug(LoggingLevel.Debug,'httpRequest - '+httpRequest);
        
        if( !Test.isRunningTest() ) {
            response = http.send(httpRequest);    
        }
        System.debug(LoggingLevel.Debug, 'Response - ' + response); 
        return response;
    }
    
    /**
     * Generate the authorization token using the configuration.
     **/
    private static AuthToken getOAuthToken(String clientId, String clientSecret, String username, String password, String oAuthURL) {
        AuthToken authTokenValue = null; 
        
        try{

            /*String clientId = 'anatestclient';
            String oAuthURL = 'https://uaa.servicemax-api.com/uaa';
            String clientSecret = 'anatestclient_secret';
            String username = 'anauser';
            String password = 'AnaSuperUserUaaPwd123';
            String anaWebappURL =  'https://localhost:8080/ANAWebapp';
            */

            String myBase64String = EncodingUtil.base64Encode(Blob.valueof(clientId+':'+clientSecret));
            System.debug(LoggingLevel.Debug, 'Base64 clientId and Client-Secret ' + myBase64String);
            
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(oAuthURL + '/oauth/token' );
            httpRequest.setMethod('POST');

            httpRequest.setBody('username=' + username + '&password=' + password + '&grant_type=password' );
            httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpRequest.setHeader('Authorization','Basic '+myBase64String);
            
            Http http = new Http();
            HTTPResponse response = new HTTPResponse();
            
            System.debug(LoggingLevel.Debug, 'Sending the request');
            System.debug(LoggingLevel.Debug,'httpRequest - '+httpRequest);
            
            if( !Test.isRunningTest() ) {
                response = http.send(httpRequest);    
            }
            System.debug(LoggingLevel.Debug, 'Response - ' + response);
            System.debug(LoggingLevel.Debug, 'Response.getBody() - ' + response.getBody());
            
                       
            if(!Test.isRunningTest()) {
                authTokenValue = (AuthToken) JSON.deserialize(response.getBody(), AuthToken.class);
            }
        } catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
       }
        return authTokenValue;
    }
}