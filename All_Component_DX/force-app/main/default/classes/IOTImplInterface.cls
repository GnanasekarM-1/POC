/**
* This class is interface for all the custom implementations
**/
/* Security Scanned */
global with sharing virtual class IOTImplInterface {
    private IoTRequest.ServiceRequestAlert request;
   
    /**
     * Reference to the Id attribute of the event object.
     **/
    private Id eventId;
    
    /**
     * Holds the completed status as constant
     **/
    public static String COMPLETED_STATUS = 'COMPLETED';
    
    /**
     * Holds the error status as constant
     **/
    public static String ERROR_STATUS = 'ERROR';
    
    /*
    * This method should override by the inherited class
    */
    global virtual Object execute(IoTRequest.ServiceRequestAlert request){
        return null;
    }
    
    /*
    * 
    */
    global virtual Object execute(IoTRequest.ServiceRequestAlert request, String eventName){
        return null;
    }

    public void setRequest(IoTRequest.ServiceRequestAlert request){
        this.request = request;
    }
    
    global class ErrorMessage{
        public String ErrorCode;
        public String Message;
        public String ExceptionMessage;
        
        global ErrorMessage(String error, String message){
            this.ErrorCode = error;
            this.Message = message;
        }

        global ErrorMessage(String error, String message, String eMessage){
            this.ErrorCode = error;
            this.Message = message;
            this.ExceptionMessage = eMessage;
        }
    }
    
    global virtual string IPLookup_IoT(){
        map<String,String> externalRequest = new map<String,String>();
        String value = '';
        String ibField = '';
        list<SVMXC__Installed_Product__c> ibRecords = new list<SVMXC__Installed_Product__c>();
        if(this.request != null && this.request.Others != null){
            externalRequest = this.request.Others;
        }
        else{
            return 'Request should not empty';
        }
        //Query Configuration 
        String config = [select SVMXC__Contents__c from SVMXC__IOTConfiguration__c where SVMXC__Type__c = 'CompositeKey'].SVMXC__Contents__c; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        IOTSetupImpl.CompositeKey configuration = (IOTSetupImpl.CompositeKey)JSON.deserialize(config, IOTSetupImpl.CompositeKey.class);
        system.debug(configuration);
        List<IOTSetupImpl.Keys> ibFields = configuration.ibFields;
        if(ibFields  != null && ibFields.size() > 0) {
            ibField = ibFields[0].name;
            system.debug(ibField);
            List<IOTSetupImpl.Keys> externalFields = configuration.externalFields;
            set<String> externalFieldList = new set<String>();
            for(IOTSetupImpl.Keys key : externalFields){
                externalFieldList.add(key.name);
            }
            
            for(String key : externalRequest.keyset()){
                
                if(externalFieldList.contains(key)){
                    value += externalRequest.get(key);
                }
            }
            
            if(ibField.length() > 0 && value.length() > 0){
                String keyFieldType = getFieldType(ibField);
                String query = 'Select Id from SVMXC__Installed_Product__c where '+ ibField + ' =: value limit 1';
                Double doubleInNumber = 0.0;
                if(keyFieldType == 'Double'){
                    doubleInNumber = Double.valueof(value.trim());
                    system.debug('Double' + doubleInNumber);
                    query = 'Select Id from SVMXC__Installed_Product__c where '+ ibField + ' =: doubleInNumber limit 1';
                }else if(keyFieldType == 'Reference'){
                    ibField = ibField.replace('__c', '__r.Name');
                    query = 'Select Id from SVMXC__Installed_Product__c where '+ ibField + ' =: value limit 1';
                }

                System.debug('ib lookup query '+query);
                try{
                    ibRecords = database.query(query);
                    return ibRecords[0].id;
                }
                catch(exception ex){
                    return ex.getMessage();
                }
            }
        }
        return null;
    }

    String getFieldType(String fieldName){
        Schema.SObjectType t = Schema.getGlobalDescribe().get('SVMXC__Installed_Product__c');
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        String dataType;
        if (f.getType() == Schema.DisplayType.String){
            dataType = 'String';
        } else if(f.getType() == Schema.DisplayType.Double){
            dataType = 'Double';
        }else if(f.getType() == Schema.DisplayType.Reference){
            dataType = 'Reference';
        } else {
            dataType = 'Other';
        }
        return dataType;
    }
    /**
     * Sets the reference to the Id attribute of the event object.
     **/
    public void setEventId(Id value) {
        eventId = value;
    }
    
    /**
     * Update the event object after task is accomplished.
     */
    public void updateTarget(String status, String target, String errorMessage, Boolean notifySource) {
        System.debug( LoggingLevel.DEBUG, 'IOTImplInterface.updateTarget() - enter' );
        System.debug( LoggingLevel.DEBUG, 'Updating the event for the record - ' + eventId);
        if(eventId != null) {
            SVMXC__SM_IOT_Event__c event = [select Id from SVMXC__SM_IOT_Event__c where Id = :eventId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(event != null) {
                event.SVMXC__SM_Status__c = status;
                event.SVMXC__SM_Target_Record__c = target;
                event.SVMXC__SM_Error_Message__c = errorMessage;
                event.SVMXC__SM_Notify_Alert_Source__c = notifySource;
                event.SVMXC__SM_End_DateTime__c = system.now();
                
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(event, COMM_SecurityUtils.Access.Updateable)){
                    update event; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
            }   
        }
        System.debug( LoggingLevel.DEBUG, 'IOTImplInterface.updateTarget() - exit' );
    }
}