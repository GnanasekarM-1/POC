global class CreateCase extends IOTImplInterface {
    override public Object execute(IoTRequest.ServiceRequestAlert request) { 
        System.debug('Request reached: ' + request);
        if(request != null && request.Event != null && request.Asset != null){
            Case newCase = new Case();
            newCase.Subject = request.Event.Subject;
            
            newCase.Description = request.Event.Subject != null && request.Event.Subject.length() > 0
                                                                                         ? request.Event.Subject + ' '  : '';
            newCase.Description += request.Event.Description != null && request.Event.Description.length() > 0
                                                                                         ? request.Event.Description  + ' ' : '';
            newCase.Description += request.Event.AlertType != null && request.Event.AlertType.length() > 0
                                                                                         ? request.Event.AlertType + ' '  : '';
            newCase.Description += request.Event.Property != null && request.Event.Property.length() > 0
                                                                                         ? request.Event.Property + ' '  : '';
            newCase.Description += request.Event.EventTime != null && request.Event.EventTime.length() > 0
                                                                                         ? request.Event.EventTime + ' '  : '';
            newCase.Description += request.Asset.ThingName != null && request.Asset.ThingName.length() > 0
                                                                                         ? request.Asset.ThingName + ' '  : ''; 
            if(request.Event.Priority == '1'){
                newCase.Priority = 'Low';
            }
            else if(request.Event.Priority == '2'){
                newCase.Priority = 'Medium';
            }
            else if(request.Event.Priority == '3'){
                newCase.Priority = 'High';
            }
            
            String insalledProduct = IPLookup_IoT();
            if(insalledProduct != null && insalledProduct.length() > 0){
                List<SVMXC__Installed_Product__c> lstIBs = [select id, SVMXC__Company__c, SVMXC__Contact__c, SVMXC__Site__c, SVMXC__Product__c 
                                    from SVMXC__Installed_Product__c where Id =: insalledProduct];
                if(lstIBs != null && lstIBs.size() > 0){
                    newCase.SVMXC__Product__c = lstIBs[0].SVMXC__Product__c;
                    newCase.SVMXC__Component__c = lstIBs[0].Id;
                    newCase.ContactId = lstIBs[0].SVMXC__Contact__c;
                    newCase.AccountId = lstIBs[0].SVMXC__Company__c;
                    newCase.SVMXC__Site__c = lstIBs[0].SVMXC__Site__c;
                }
            }
            
            try{
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newCase, COMM_SecurityUtils.Access.Createable ) ) {
                    insert newCase; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    updateTarget(ERROR_STATUS, '', System.Label.COMM001_TAG142, false);
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                updateTarget(COMPLETED_STATUS, newCase.id, '', false);
                return newCase.id;
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