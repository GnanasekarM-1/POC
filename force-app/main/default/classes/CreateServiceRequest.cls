global class CreateServiceRequest extends IOTImplInterface {
    override public Object execute(IoTRequest.ServiceRequestAlert request) { 
        System.debug('Request reached: ' + request);
        if(request != null && request.Event != null && request.Asset != null){
            SVMXC__Service_Request__c newServiceRequest = new SVMXC__Service_Request__c();
            newServiceRequest.SVMXC__Subject__c= request.Event.Subject;
            
            newServiceRequest.SVMXC__Problem_Description__c = request.Event.Subject != null && request.Event.Subject.length() > 0
                                                                                         ? request.Event.Subject + ' '  : '';
            newServiceRequest.SVMXC__Problem_Description__c += request.Event.Description != null && request.Event.Description.length() > 0
                                                                                         ? request.Event.Description  + ' ' : '';
            newServiceRequest.SVMXC__Problem_Description__c += request.Event.AlertType != null && request.Event.AlertType.length() > 0
                                                                                         ? request.Event.AlertType + ' '  : '';
            newServiceRequest.SVMXC__Problem_Description__c += request.Event.Property != null && request.Event.Property.length() > 0
                                                                                         ? request.Event.Property + ' '  : '';
            newServiceRequest.SVMXC__Problem_Description__c += request.Event.EventTime != null && request.Event.EventTime.length() > 0
                                                                                         ? request.Event.EventTime + ' '  : '';
            newServiceRequest.SVMXC__Problem_Description__c += request.Asset.ThingName != null && request.Asset.ThingName.length() > 0
                                                                                         ? request.Asset.ThingName + ' '  : ''; 
            if(request.Event.Priority == '1'){
                newServiceRequest.SVMXC__Priority__c = 'Low';
            }
            else if(request.Event.Priority == '2'){
                newServiceRequest.SVMXC__Priority__c = 'Medium';
            }
            else if(request.Event.Priority == '3'){
                newServiceRequest.SVMXC__Priority__c = 'High';
            }
            
            String insalledProduct = IPLookup_IoT();
            if(insalledProduct != null && insalledProduct.length() > 0){
                List<SVMXC__Installed_Product__c> lstIBs = [select id, SVMXC__Company__c, SVMXC__Contact__c, SVMXC__Site__c, SVMXC__Product__c 
                                    from SVMXC__Installed_Product__c where Id =: insalledProduct];
                if(lstIBs != null && lstIBs.size() > 0){
                    newServiceRequest.SVMXC__Product__c = lstIBs[0].SVMXC__Product__c;
                    newServiceRequest.SVMXC__Serial_Number__c = lstIBs[0].Id;
                    newServiceRequest.SVMXC__Contact__c = lstIBs[0].SVMXC__Contact__c;
                    newServiceRequest.SVMXC__Account__c = lstIBs[0].SVMXC__Company__c;
                }
            }
            
            try{
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newServiceRequest, COMM_SecurityUtils.Access.Createable ) ) {
                    insert newServiceRequest; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    updateTarget(ERROR_STATUS, '', System.Label.COMM001_TAG142, false);
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                updateTarget(COMPLETED_STATUS, newServiceRequest.id, '', false);
                return newServiceRequest.id;
            }
            catch(Exception ex){
                updateTarget(ERROR_STATUS, '', ex.getMessage(), false);
                return new ErrorMessage('','', ex.getMessage());            }
        }
        else{
            updateTarget(ERROR_STATUS, '', 'request cannot be null', false);
            return new ErrorMessage('','', 'request cannot be null');
        }
        //return null;
    }
        

}