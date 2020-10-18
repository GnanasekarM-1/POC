/* Security Scanned */
public class IOTServiceImpl extends IOTServiceBase{
    public IOTServiceImpl(RestRequest req, RestResponse res){
        super(req, res);
    }
    
    public IOTServiceImpl(){  
       /**
        * The empty constructor is introduced so that the service methods can be consumed from VF page.
        */
    }
    
    /*All request methods goes here*/
    override public Object createSR() {    
        AlertHandlerRequest req = (AlertHandlerRequest) deserializeRequestTo(AlertHandlerRequest.class);
        return createSR(req);
    }
    
    private Object createSR(AlertHandlerRequest request){
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.ThingId__c = request.thingId ;
        //workOrder.External_Id__c = request.externalId;
        
        if(request.alert != null){
            
            workOrder.SVMXC__Problem_Description__c = '';
            
            if(request.thingName != null){
                workOrder.SVMXC__Problem_Description__c += 'thingName : ' + request.thingName + '\n'; 
            }

            if(request.asset.serialNumber != null){
                workOrder.SVMXC__Problem_Description__c += 'serialNumber : ' + request.asset.serialNumber + '\n'; 
            }

            if(request.asset.modelNumber != null){
                workOrder.SVMXC__Problem_Description__c += 'modelNumber : ' + request.asset.modelNumber + '\n'; 
            }

            if(request.alert.name != null){
                workOrder.SVMXC__Problem_Description__c += 'name : ' + request.alert.name + '\n'; 
            }
            if(request.alert.priority != null){
                workOrder.SVMXC__Problem_Description__c += 'priority : ' + request.alert.priority + '\n'; 
            }
            if(request.alert.message != null){
                workOrder.SVMXC__Problem_Description__c += 'message : ' + request.alert.message + '\n';
            }
            if(request.alert.description != null){
                workOrder.SVMXC__Violation_Message__c = request.alert.description;    
            }
            if(request.alert.type != null){
                workOrder.SVMXC__Problem_Description__c += 'type : ' + request.alert.type + '\n'; 
            }
            if(request.alert.sourceProperty != null){
                workOrder.SVMXC__Problem_Description__c += 'sourceProperty : ' + request.alert.sourceProperty + '\n'; 
            }
            if(request.alert.alertTime != null){
                workOrder.SVMXC__Problem_Description__c += 'alertTime : ' + request.alert.alertTime + '\n';   
            }
            if(request.alert.eventProperties != null && request.alert.eventProperties.size() > 0){
                for(integer i=0; i<request.alert.eventProperties.size() ; i++){
                    workOrder.SVMXC__Problem_Description__c += request.alert.eventProperties[i].name + ' : ' + request.alert.eventProperties[i].value + '\n';
                }
            }
        }
        //workOrder.SVMXC__Problem_Description__c = request.alert != null ? request.alert.description : '';
        
        if(request.alert != null && request.alert.alertTime != null){
            workOrder.SVMXC__Preferred_Start_Time__c = Datetime.valueOfGMT(request.alert.alertTime);
        }
        
        string prodName = '', installedProdName = '';
        prodName = request.thingName;
        if(request.asset != null){
            installedProdName  = request.asset.serialNumber;
            //workOrder.SVMXC__Violation_Message__c  = request.alert.message;
        }
        
        /*if(prodName != null){
            List<Product2> lstProd = [select id from Product2 where Name =: prodName];
            if(lstProd != null && lstProd.size() > 0){
                workOrder.SVMXC__Product__c = lstProd[0].Id;
            }
        }*/
        
        if(installedProdName != null){
            List<SVMXC__Installed_Product__c> lstIBs = [select id, SVMXC__Company__c, SVMXC__Contact__c, SVMXC__Site__c, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Serial_Lot_Number__c =: installedProdName];
            if(lstIBs != null && lstIBs.size() > 0){
                workOrder.SVMXC__Product__c = lstIBs[0].SVMXC__Product__c;
                workOrder.SVMXC__Component__c = lstIBs[0].Id;
                workOrder.SVMXC__Site__c = lstIBs[0].SVMXC__Site__c;
                workOrder.SVMXC__Contact__c = lstIBs[0].SVMXC__Contact__c;
                workOrder.SVMXC__Company__c = lstIBs[0].SVMXC__Company__c;
            }
        }
        
        //insert workOrder;
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(workOrder, COMM_SecurityUtils.Access.Createable))
        {
            insert workOrder; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
        }
        else
        {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        return request;
    }
    
    override public Object createCase() {    
        AlertHandlerRequest req = (AlertHandlerRequest) deserializeRequestTo(AlertHandlerRequest.class);
        return createCase(req);
    }
    
    private Object createCase(AlertHandlerRequest request){
        Case svmxcase = new Case();
        //svmxcase.Description = request.alert != null ? request.alert.description : '';
        
        string prodName = '', installedProdName = '';
        prodName = request.thingName;
        if(request.asset != null){
            installedProdName  = request.asset.serialNumber;
            //svmxcase.Comments__c  = request.alert.message;
        }
        
        if(request.alert != null){
            
            svmxcase.Description = '';

            if(request.thingName != null){
                svmxcase.Description += 'thingName : ' + request.thingName + '\n'; 
            }

            if(request.asset.serialNumber != null){
                svmxcase.Description += 'serialNumber : ' + request.asset.serialNumber + '\n'; 
            }

            if(request.asset.modelNumber != null){
                svmxcase.Description += 'modelNumber : ' + request.asset.modelNumber + '\n'; 
            }
            
            if(request.alert.name != null){
                svmxcase.Description += 'name : ' + request.alert.name + '\n';  
            }
            if(request.alert.priority != null){
                svmxcase.Description += 'priority : ' + request.alert.priority + '\n';  
            }
            if(request.alert.message != null){
                svmxcase.Description += 'message : ' + request.alert.message + '\n';
            }
            if(request.alert.description != null){
                svmxcase.Subject = request.alert.description;   
            }
            if(request.alert.type != null){
                svmxcase.Description += 'type : ' + request.alert.type + '\n';  
            }
            if(request.alert.sourceProperty != null){
                svmxcase.Description += 'sourceProperty : ' + request.alert.sourceProperty + '\n';  
            }
            if(request.alert.alertTime != null){
                svmxcase.Description += 'alertTime : ' + request.alert.alertTime + '\n';    
            }
            if(request.alert.eventProperties != null && request.alert.eventProperties.size() > 0){
                for(integer i=0; i<request.alert.eventProperties.size() ; i++){
                    svmxcase.Description += request.alert.eventProperties[i].name + ' : ' + request.alert.eventProperties[i].value + '\n';
                }
            }
        }
        
        /*if(prodName != null){
            List<Product2> lstProd = [select id from Product2 where Name =: prodName];
            if(lstProd != null && lstProd.size() > 0){
                svmxcase.SVMXC__Product__c = lstProd[0].Id;
            }
        }*/
        
        if(installedProdName != null){
            List<SVMXC__Installed_Product__c> lstIBs = [select id, SVMXC__Product__c, SVMXC__Company__c, SVMXC__Contact__c, SVMXC__Site__c from SVMXC__Installed_Product__c where SVMXC__Serial_Lot_Number__c =: installedProdName];
            if(lstIBs != null && lstIBs.size() > 0){
                svmxcase.SVMXC__Product__c = lstIBs[0].SVMXC__Product__c;
                svmxcase.SVMXC__Component__c = lstIBs[0].Id;
                svmxcase.ContactId = lstIBs[0].SVMXC__Contact__c;
                svmxcase.AccountId = lstIBs[0].SVMXC__Company__c;
                svmxcase.SVMXC__Site__c = lstIBs[0].SVMXC__Site__c;
            }
        }
        
        //insert svmxcase;
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(svmxcase, COMM_SecurityUtils.Access.Createable))
        {
            insert svmxcase; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
        }
        else
        {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        return request;
    }
    
    /*override public Object alertHandler(){
        IoTRequest.AlertHandlerRequest request = (IOTRequest.AlertHandlerRequest) deserializeRequestTo(IOTRequest.AlertHandlerRequest.class);
        Type t = Type.forName('IoTCustomImplementation');
        IoTInterface objIntf = (IOTInterface)t.newInstance();
        objIntf.execute(request);
        return request;
    }*/
    
    override public Object alertHandler(){
        AlertHandlerRequest request = (AlertHandlerRequest) deserializeRequestTo(AlertHandlerRequest.class);
        SVMXC__Service_Request__c sr = new SVMXC__Service_Request__c();
        
        if(request.alert != null){
            
            sr.SVMXC__Problem_Description__c = '';

            if(request.thingName != null){
                sr.SVMXC__Problem_Description__c += 'thingName : ' + request.thingName + '\n'; 
            }

            if(request.asset.serialNumber != null){
                sr.SVMXC__Problem_Description__c += 'serialNumber : ' + request.asset.serialNumber + '\n'; 
            }

            if(request.asset.modelNumber != null){
                sr.SVMXC__Problem_Description__c += 'modelNumber : ' + request.asset.modelNumber + '\n'; 
            }
            
            if(request.alert.name != null){
                sr.SVMXC__Problem_Description__c += 'name : ' + request.alert.name + '\n'; 
            }
            if(request.alert.priority != null){
                sr.SVMXC__Problem_Description__c += 'priority : ' + request.alert.priority + '\n'; 
            }
            if(request.alert.message != null){
                sr.SVMXC__Problem_Description__c += 'message : ' + request.alert.message + '\n';
            }
            if(request.alert.description != null){
                sr.SVMXC__Subject__c = request.alert.description;    
            }
            if(request.alert.type != null){
                sr.SVMXC__Problem_Description__c += 'type : ' + request.alert.type + '\n'; 
            }
            if(request.alert.sourceProperty != null){
                sr.SVMXC__Problem_Description__c += 'sourceProperty : ' + request.alert.sourceProperty + '\n'; 
            }
            if(request.alert.alertTime != null){
                sr.SVMXC__Problem_Description__c += 'alertTime : ' + request.alert.alertTime + '\n';   
            }
            if(request.alert.eventProperties != null && request.alert.eventProperties.size() > 0){
                for(integer i=0; i<request.alert.eventProperties.size() ; i++){
                    sr.SVMXC__Problem_Description__c += request.alert.eventProperties[i].name + ' : ' + request.alert.eventProperties[i].value + '\n';
                }
            }
        }
        
        if(request.alert != null && request.alert.alertTime != null){
            sr.SVMXC__Preferred_Start_Time__c = Datetime.valueOfGMT(request.alert.alertTime);
        }
        
        string prodName = '', installedProdName = '';
        prodName = request.thingName;
        if(request.asset != null){
            installedProdName  = request.asset.serialNumber;
        }
        
        /*if(prodName != null){
            List<Product2> lstProd = [select id from Product2 where Name =: prodName];
            if(lstProd != null && lstProd.size() > 0){
                sr.SVMXC__Product__c = lstProd[0].Id;
            }
        }*/
        
        if(installedProdName != null){
            List<SVMXC__Installed_Product__c> lstIBs = [select id, SVMXC__Company__c, SVMXC__Contact__c, SVMXC__Site__c, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Serial_Lot_Number__c =: installedProdName];
            if(lstIBs != null && lstIBs.size() > 0){
                sr.SVMXC__Product__c = lstIBs[0].SVMXC__Product__c;
                sr.SVMXC__Serial_Number__c = lstIBs[0].Id;
                sr.SVMXC__Contact__c = lstIBs[0].SVMXC__Contact__c;
                sr.SVMXC__Account__c = lstIBs[0].SVMXC__Company__c;
            }
        }
        
        //insert sr;
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(sr, COMM_SecurityUtils.Access.Createable))
        {
            insert sr; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
        }
        else
        {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        return request;

        /*if(req.eventName != null && req.eventName.toLowerCase() == 'createsr'){
            createSR(req);          
        }else if(req.eventName != null && req.eventName.toLowerCase() == 'createcase'){
            createCase(req);
        }else if(req.alert != null && req.alert.priority == 1){
            createSR(req);
        }else if(req.alert != null && req.alert.priority >= 2){
            createCase(req);
        }*/
    }
    //version 2.0 generic implementation
    override public Object iotGenericHandler(String eventName){
        IoTRequest.ServiceRequestAlert req = (IoTRequest.ServiceRequestAlert) deserializeRequestTo(IoTRequest.ServiceRequestAlert.class);
        return iotGenericHandler(req, eventName);
    }

    private Object iotGenericHandler(IoTRequest.ServiceRequestAlert request, String eventName){
        
        String className = getClassName(eventName);
        IOTImplInterface objIntf = null;
        if(className == null || className.length() == 0){
            return new ErrorMessage('EVENT_NOT_FOUND', 'The event mapped is not found', 'The event mapped is not found');

        }
        try{
            System.debug('Classname that is mapped to: ' + className);
            Type t = Type.forName(className);
            objIntf = (IOTImplInterface)t.newInstance();
        }catch(Exception ex){
            return new ErrorMessage('CLASS_NOT_FOUND', 'The class mapped is not found', 'The class mapped is not found');
        }
        
        //Create an entry into the Event object.
        Id eventId = insertEvent(request, eventName);
        objIntf.setEventId(eventId); 
        
        objIntf.setRequest(request);
        if(className.equals('COMM_IoTRestApiEngine')) return objIntf.execute(request, eventName);
        return objIntf.execute(request);
    }

    /**
     * Creates an entry into the IOT Event object when the data is sent from the device.
     **/
    private Id insertEvent(IoTRequest.ServiceRequestAlert request, String eventName) {
        System.debug( LoggingLevel.DEBUG, 'IOTServiceImpl.insertEvent() - enter' );
        System.debug( LoggingLevel.DEBUG, 'Creating an entry in the event log for - ' + eventName);
        
        SVMXC__SM_IOT_Event__c event = new SVMXC__SM_IOT_Event__c();
        event.SVMXC__SM_Alert_Event__c = eventName;
        event.SVMXC__SM_Start_DateTime__c = System.now();
        event.SVMXC__SM_Alert_Payload__c = String.valueOf(request);
        event.SVMXC__SM_Status__c = 'INITIATED';
        event.SVMXC__SM_Alert_Source__c = 'ThingWorx';        
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(event, COMM_SecurityUtils.Access.Createable)){
                    insert event; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
        System.debug( LoggingLevel.DEBUG, 'IOTServiceImpl.insertEvent() - end' );
        return event.Id;
    }
    
    private String getClassName(String eventName){
        String className = '';
        List<SVMXC__IOTConfiguration__c> iotClsInfo = [Select SVMXC__Contents__c, SVMXC__Name__c from SVMXC__IOTConfiguration__c where SVMXC__Name__c =: eventName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(iotClsInfo != null && iotClsInfo.Size() > 0){
            IOTSetupImpl.IoTEvent evnt = (IOTSetupImpl.IoTEvent)JSON.deserialize(iotClsInfo[0].SVMXC__Contents__c, IOTSetupImpl.IoTEvent.class);
            className = evnt.className;
        }
        return className;
    }
    
    private class AlertHandlerRequest{
        String eventName;
        String thingId;
        String thingName;
        String externalId;
        Asset asset;
        Alert alert;
        List<AlertMap> eventProperties;
    }
    
    private class Asset{
        String modelNumber;
        String serialNumber;
        List<AlertMap> eventProperties;
    }
    
    private class Alert{
        String name;
        Integer priority;
        String message;
        String description;
        String type;
        String alertTime;  
        String sourceProperty;
        List<AlertMap> eventProperties;
    }
    
    private class AlertMap{
        String name;
        String value;
        
        public AlertMap(String name, String value){
            this.name = name;
            this.value = value;
        }
    }
}