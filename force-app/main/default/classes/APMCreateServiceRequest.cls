global class APMCreateServiceRequest extends SVMXC.IOTImplInterface {
    override public Object execute(SVMXC.IoTRequest.ServiceRequestAlert request) { 
        System.debug('Request reached: ' + request);
        if(request != null && request.Event != null && request.Asset != null){
            SVMXC__Service_Request__c newServiceRequest = new SVMXC__Service_Request__c();
            
            //From the IoT event object
            newServiceRequest.SVMXC__Subject__c = request.Event.Subject != null && request.Event.Subject.length() > 0
            ? request.Event.Subject : '';
            newServiceRequest.SVMXC__Problem_Description__c = request.Event.Description != null && request.Event.Description.length() > 0
            ? request.Event.Description : ''; 
            newServiceRequest.SVMXC__Priority__c = request.Event.Priority != null && request.Event.Priority.length() > 0
            ? request.Event.Priority : '';
            newServiceRequest.SVMXC__Type__c = request.Event.AlertType != null && request.Event.AlertType.length() > 0
            ? request.Event.AlertType : '';
            
            //From the Others map object
            map<String, String> others = new Map<String, String>();
            others = request.Others;
            System.debug('List of Others: ' + others);
            newServiceRequest.SVMXC__Status__c = others.get('Status') != null && others.get('Status').length() > 0 ? others.get('Status') : '';
            String preferedStartTime = others.get('PreferredStartTime') != null && others.get('PreferredStartTime').length() > 0 ? others.get('PreferredStartTime') : '';
                Datetime dtTime = validateDateTime(preferedStartTime);
                if(dtTime != null){
                    newServiceRequest.SVMXC__Preferred_Start_Time__c = dtTime;                    
                }
                
                
            newServiceRequest.SVMXC__Service_Request_Source__c = others.get('ServiceRequestSource') != null && others.get('ServiceRequestSource').length() > 0 ? others.get('ServiceRequestSource') : '';

            String installedProduct = IPLookup_IoT();    
            System.debug('Installed product:' + installedProduct);
            if(installedProduct != null && installedProduct.length() > 0){
                List<SVMXC__Installed_Product__c> lstIBs = [select id, SVMXC__Company__c, SVMXC__Contact__c, SVMXC__Product__c, SVMXC__Site__c from SVMXC__Installed_Product__c where Id =: installedProduct];
                if(lstIBs != null && lstIBs.size() > 0){
                    newServiceRequest.SVMXC__Product__c = lstIBs[0].SVMXC__Product__c;
                    newServiceRequest.SVMXC__Serial_Number__c = lstIBs[0].Id;
                    newServiceRequest.SVMXC__Contact__c = lstIBs[0].SVMXC__Contact__c;
                    newServiceRequest.SVMXC__Account__c = lstIBs[0].SVMXC__Company__c;
                    newServiceRequest.SVMXC__Priority__c = request.Event.Priority;
                }
            }
            try{
                //Add the service request name to the response by running the select Name query
                String serviceRequestName = null; 
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newServiceRequest, COMM_SecurityUtils.Access.Createable ) ) {
                    insert newServiceRequest; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    //#ANA-152 - Update the event object with the information.
                    updateTarget(ERROR_STATUS, '', System.Label.COMM001_TAG142, false);
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                updateTarget(COMPLETED_STATUS, newServiceRequest.id, '', false);
                List<SVMXC__Service_Request__c> lstSRs = [select Name from SVMXC__Service_Request__c where Id =: newServiceRequest.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstSRs != null && lstSRs.size() > 0){
                    serviceRequestName = lstSRs[0].Name;
                }
                if(serviceRequestName != null){
                    return serviceRequestName + ':' + newServiceRequest.id;
                }
                else{
                    return newServiceRequest.id;
                }
            }
            catch(Exception err){
                updateTarget(ERROR_STATUS, '', err.getMessage(), false);
                return new ErrorMessage('ERR02','Exception', err.getMessage());
            }
        }
        else{
            updateTarget(ERROR_STATUS, '', 'request cannot be null', false);
         return new ErrorMessage('ERR01','', System.Label.IOT001_TAG035);
     }
 }
 public static Datetime validateDateTime(String dateTimeString){
        //The date and time should be provided in ISO 8601 format: YYYY-MM-DDThh:mm:ss+hh:mm.
        //string str = '"2013-01-30T07:38:44.268Z"';
        

        Datetime returnDateTime;
        Boolean returnValue;
            try{
                returnDateTime = (DateTime)JSON.deserialize('"'+dateTimeString+'"',DateTime.class);
                returnValue = TRUE; 
            } catch (Exception e) {
                returnValue = FALSE;
            }
        return returnDateTime;
    }
}