global class CreateWorkOrder extends IOTImplInterface {
    override public Object execute(IoTRequest.ServiceRequestAlert request) { 
        System.debug('Request reached: ' + request);
        if(request != null && request.Event != null && request.Asset != null){
            SVMXC__Service_Order__c newWorkOrder = new SVMXC__Service_Order__c();
            
            newWorkOrder.SVMXC__Special_Instructions__c = request.Event.Subject != null && request.Event.Subject.length() > 0
                                                                                         ? request.Event.Subject : '';
            newWorkOrder.SVMXC__Problem_Description__c = request.Event.Subject != null && request.Event.Subject.length() > 0
                                                                                         ? request.Event.Subject + ' '  : '';
            newWorkOrder.SVMXC__Problem_Description__c += request.Event.Description != null && request.Event.Description.length() > 0
                                                                                         ? request.Event.Description  + ' ' : '';
            newWorkOrder.SVMXC__Problem_Description__c += request.Event.AlertType != null && request.Event.AlertType.length() > 0
                                                                                         ? request.Event.AlertType + ' '  : '';
            newWorkOrder.SVMXC__Problem_Description__c += request.Event.Property != null && request.Event.Property.length() > 0
                                                                                         ? request.Event.Property + ' '  : '';
            newWorkOrder.SVMXC__Problem_Description__c += request.Event.EventTime != null && request.Event.EventTime.length() > 0
                                                                                         ? request.Event.EventTime + ' '  : '';
            newWorkOrder.SVMXC__Problem_Description__c += request.Asset.ThingName != null && request.Asset.ThingName.length() > 0
                                                                                         ? request.Asset.ThingName + ' '  : ''; 
            if(request.Event.Priority == '1'){
                newWorkOrder.SVMXC__Priority__c = 'Low';
            }
            else if(request.Event.Priority == '2'){
                newWorkOrder.SVMXC__Priority__c = 'Medium';
            }
            else if(request.Event.Priority == '3'){
                newWorkOrder.SVMXC__Priority__c = 'High';
            }
            
            String insalledProduct = IPLookup_IoT();
            if(insalledProduct != null && insalledProduct.length() > 0){
                List<SVMXC__Installed_Product__c> lstIBs = [select id, SVMXC__Company__c, SVMXC__Contact__c, SVMXC__Site__c, SVMXC__Product__c 
                                    from SVMXC__Installed_Product__c where Id =: insalledProduct];
                if(lstIBs != null && lstIBs.size() > 0){
                    newWorkOrder.SVMXC__Product__c = lstIBs[0].SVMXC__Product__c;
                    newWorkOrder.SVMXC__Component__c = lstIBs[0].Id;
                    newWorkOrder.SVMXC__Site__c = lstIBs[0].SVMXC__Site__c;
                    newWorkOrder.SVMXC__Contact__c = lstIBs[0].SVMXC__Contact__c;
                    newWorkOrder.SVMXC__Company__c = lstIBs[0].SVMXC__Company__c;
                }
            }
            try{
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( newWorkOrder, COMM_SecurityUtils.Access.Createable ) ) {
                    insert newWorkOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    updateTarget(ERROR_STATUS, '', System.Label.COMM001_TAG142, false);
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                updateTarget(COMPLETED_STATUS, newWorkOrder.id, '', false);
                return newWorkOrder.id;
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