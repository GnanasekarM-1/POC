/* Security Scanned */
public with sharing class IOTSetupImpl {
    
    public Object getSetupMetadata(){         
       List<String> objectsfrdesc = new List<String>();
       objectsfrdesc.add('SVMXC__Installed_Product__c');
       GetSetupMetadataResponse metadataResponse = new GetSetupMetadataResponse();
       metadataResponse.setTranslations(getTranslations());
       
       metadataResponse.setSForceObjectDescribes(getObjectDescribes(objectsfrdesc));
       metadataResponse.setEvents(getEvents());
       metadataResponse.setCompositekey(getCompositeKey());
       metadataResponse.setEventObjects(getObjectListForEvent());
       return metadataResponse;    
    }

    public Object save(String request){
        System.debug(LoggingLevel.Info, 'request : ' + request);
        IOTSetupImpl.IoTConfigurations configuration = 
                            (IOTSetupImpl.IoTConfigurations)JSON.deserialize(request, IOTSetupImpl.IoTConfigurations.class);
        deleteEvents(configuration.deletedEvents);                    
        saveEvents(configuration.events);
        System.debug(configuration.compositeKey);
        saveCompositeKey(configuration.compositeKey);
        if(configuration.objectMapEvents != null)saveFieldMapping(configuration.objectMapEvents);
        deleteIoTFieldMapIds(configuration.deletedObjectMap);
        return getSetupMetadata();
    }
    public void saveFieldMapping(List<IoTMapToObjectEvent> objectMapEvents){
        List<SVMXC__SM_IoT_Field_Mapping__c> allMaps = new List<SVMXC__SM_IoT_Field_Mapping__c>();
        for(IoTMapToObjectEvent mapEvent:objectMapEvents){
            SVMXC__SM_IoT_Field_Mapping__c iotFiledMap = new SVMXC__SM_IoT_Field_Mapping__c();
            if(String.isNotEmpty(mapEvent.sfdc)){
                iotFiledMap.SVMXC__SM_Event_Name__c = mapEvent.eventName;
                iotFiledMap.Id = mapEvent.sfdc;
            }
            iotFiledMap.SVMXC__SM_Event_Name__c = mapEvent.eventName;
            iotFiledMap.SVMXC__SM_IoT_Event_Id__c = mapEvent.eventName;
            iotFiledMap.SVMXC__SM_Description__c = mapEvent.eventDescription;
            iotFiledMap.SVMXC__SM_JSON_Payload__c = mapEvent.payload;
            allMaps.add(iotFiledMap);
        }

       upsert allMaps; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
    }
    public Object saveFieldMapping1(String str){
       return '';
        
    }
    /*public Object describeObject(String request){
        SForceObject reqObject = (SForceObject)JSON.deserialize(request, SForceObject.class);
        List<String> objectsfrdesc = new List<String>();
        objectsfrdesc.add(reqObject.objectAPIName);
        GetObjectDescribeResponse objectDescribeResponse = new GetObjectDescribeResponse();
        objectDescribeResponse.setSForceObjectDescribes(getObjectDescribes(objectsfrdesc));
        return objectDescribeResponse; 
    }*/

    public Object describeObject(String request){
        SForceObjects reqObjects = (SForceObjects)JSON.deserialize(request, SForceObjects.class);
        List<String> objectsfrdesc = new List<String>();
        List<SForceObject> allbjects = new List<SForceObject>();
        allbjects = reqObjects.allObjects;
        for(SForceObject sObj : allbjects){
            objectsfrdesc.add(sObj.objectAPIName);
        }

        
        GetObjectDescribeResponse objectDescribeResponse = new GetObjectDescribeResponse();
        objectDescribeResponse.setSForceObjectDescribes(getObjectDescribes(objectsfrdesc));
        return objectDescribeResponse; 
    }

    /* supporting methods goes here */
    
    private void deleteEvents(List<String> deletedEvents){
        System.debug('Deleted Events: ' + deletedEvents);
        List<SVMXC__IOTConfiguration__c> del = [Select Id from SVMXC__IOTConfiguration__c where Id in: deletedEvents]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        delete del; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    private void deleteIoTFieldMapIds(List<String> deletedEventMapIds){
        System.debug('deleted Iot field Event MapIds: ' + deletedEventMapIds);
        List<SVMXC__SM_IoT_Field_Mapping__c> del = [Select Id from SVMXC__SM_IoT_Field_Mapping__c where Id in: deletedEventMapIds]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        delete del; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    private List<SForceObject> getObjectDescribes(List<String> objectNames) {
        
        List<SForceObject> objectDescribeInfos = new List<SForceObject>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(objectNames);
        for(Schema.DescribeSobjectResult res : results){
            SForceObject objectDescribeInfo = new SForceObject();
            objectDescribeInfo.objectLabel = res.getLabel();
            objectDescribeInfo.objectAPIName = res.getName();
            objectDescribeInfo.fields = getFields(res);
            objectDescribeInfos.add(objectDescribeInfo);
        }       
        return objectDescribeInfos;
    }
    
    private List<SForceField> getFields(Schema.DescribeSobjectResult objectDescribeRes) {
        
        List<SForceField> allFieldsInfo = new List<SForceField>();
        SForceField field = null;
        Map<String, Schema.SObjectField> objectFields = objectDescribeRes.fields.getMap();
        for (String fieldName : objectFields.keySet()) {
            field = new SForceField();
            Schema.DescribeFieldResult dfr = objectFields.get(fieldName).getDescribe();
            field.fieldAPIName = dfr.getName();
            field.fieldLabel = dfr.getLabel();
            field.type = dfr.getType() + '';
            if(field.type == 'REFERENCE'){              
                field.referenceTo = dfr.getReferenceTo()[0] + '';
            }
            field.relationshipName = dfr.getRelationshipName();
            field.nameField = dfr.nameField;
            field.isExternalId = dfr.isExternalId();
            if(dfr.isAutoNumber() && field.type  == 'STRING') {
                field.type = 'AUTONUMBER';
            }
            allFieldsInfo.add(field);
        }    
        return allFieldsInfo;
    }

    private void saveEvents(List<IoTEvent> iotEvents){
        List<SVMXC__IOTConfiguration__c> configuration = new List<SVMXC__IOTConfiguration__c>();
        Map<String, IoTEvent> existingConfiguration = new Map<String, IoTEvent>();

        for(IoTEvent iotEvent: iotEvents){
            if(iotEvent.eventId == null){
                SVMXC__IOTConfiguration__c curr = new SVMXC__IOTConfiguration__c();
                curr.SVMXC__Name__c = iotEvent.eventName;
                curr.SVMXC__Contents__c = JSON.serialize(iotEvent);
                curr.SVMXC__Type__c = 'Event';
                configuration.add(curr);
            }else{
                existingConfiguration.put(iotEvent.eventId, iotEvent);
            }
        }

        if(existingConfiguration.keySet().size() > 0)
            configuration.addAll(updateExistingEvents(existingConfiguration));
        
        upsert configuration; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

    }

    private void saveCompositeKey(CompositeKey compKey){
        List<SVMXC__IOTConfiguration__c> existConfSF = [Select Id from SVMXC__IOTConfiguration__c where SVMXC__Type__c = 'CompositeKey']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        SVMXC__IOTConfiguration__c curr = null;
        if(existConfSF.size() > 0){
            curr = existConfSF[0];
        }else{
            curr = new SVMXC__IOTConfiguration__c();
        }
        
        curr.SVMXC__Contents__c = JSON.serialize(compKey);
        curr.SVMXC__Type__c = 'CompositeKey';
        upsert curr; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }

    private List<SVMXC__IOTConfiguration__c> updateExistingEvents(Map<String, IoTEvent> existingEvents){
        //get existing confiugration
        List<SVMXC__IOTConfiguration__c> existConfSF = [Select SVMXC__Name__c, SVMXC__Contents__c, SVMXC__Type__c from SVMXC__IOTConfiguration__c where Id in: existingEvents.keySet()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__IOTConfiguration__c curr : existConfSF){
            IoTEvent iotEvent = existingEvents.get(curr.Id);
            curr.SVMXC__Name__c = iotEvent.eventName;
            curr.SVMXC__Contents__c = JSON.serialize(iotEvent);
            curr.SVMXC__Type__c = 'Event';
        }
        return existConfSF;

    }

    private List<IoTEvent> getEvents(){
        List<SVMXC__IOTConfiguration__c> allEvents = [select Id, SVMXC__Name__c, SVMXC__Contents__c from SVMXC__IOTConfiguration__c where SVMXC__Type__c = 'Event'];
        List<IoTEvent> iotEvents = new List<IoTEvent>();

        for(SVMXC__IOTConfiguration__c currEvnt : allEvents){

            IoTEvent evnt = (IOTSetupImpl.IoTEvent)JSON.deserialize(currEvnt.SVMXC__Contents__c, IOTSetupImpl.IoTEvent.class);
            evnt.eventId = currEvnt.Id;
            iotEvents.add(evnt);
        }
        return iotEvents;

    }

    private CompositeKey getCompositeKey(){
        List<SVMXC__IOTConfiguration__c> compositeKey = [select Id, SVMXC__Name__c, SVMXC__Contents__c from SVMXC__IOTConfiguration__c where SVMXC__Type__c = 'CompositeKey'];
        CompositeKey compKey = new CompositeKey();
        
        if(compositeKey.size() > 0){

            compKey = (IOTSetupImpl.CompositeKey)JSON.deserialize(compositeKey[0].SVMXC__Contents__c, IOTSetupImpl.CompositeKey.class);
        }
        return compKey;

    }
    
    private List<IoTEventObject> getObjectListForEvent(){
        
        COMM_Utils objComm_Utils = new COMM_Utils();
        Boolean isCaseObjAvailable = objComm_Utils.SVMX_isObjectLicensed('Case');
        System.debug('isCaseObjAvailable '+isCaseObjAvailable);
        List<IoTEventObject> objectList = new List<IoTEventObject>();
        List<SVMXC__ServiceMax_Property_Elements__c> SFDCSVMX_InternalObjectList = [Select Name, SVMXC__Element_Type__c,SVMXC__Element_Value__c,     SVMXC__Property_Key__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c = 'IOT_EVENT_ALLOWDED_OBJECT' ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(SFDCSVMX_InternalObjectList.Size() < 4){
            delete SFDCSVMX_InternalObjectList; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            SFDCSVMX_InternalObjectList = addObjectsToServicePropertyElements(isCaseObjAvailable);
        }
        for(SVMXC__ServiceMax_Property_Elements__c element : SFDCSVMX_InternalObjectList){
            IoTEventObject eventObject = new IoTEventObject();
            eventObject.objectLabel =  element.SVMXC__Element_Type__c;
            eventObject.objectName =  element.SVMXC__Element_Value__c;
            if(!isCaseObjAvailable && element.SVMXC__Element_Value__c.equals('Case')) continue;
            objectList.add(eventObject);
        }
        return objectList;
    }

    private List<SVMXC__ServiceMax_Property_Elements__c> addObjectsToServicePropertyElements(Boolean isCaseObjAvailable){
        List<SVMXC__ServiceMax_Property_Elements__c> svmxPeopertyElementList = new List<SVMXC__ServiceMax_Property_Elements__c>();

        
         SVMXC__ServiceMax_Property_Elements__c svmxCasePeopertyElement = new SVMXC__ServiceMax_Property_Elements__c();
        svmxCasePeopertyElement.Name = 'IOTEVENTOBJECT001';
        svmxCasePeopertyElement.SVMXC__Element_Type__c = 'Case';
        svmxCasePeopertyElement.SVMXC__Element_Value__c = 'Case';
        svmxCasePeopertyElement.SVMXC__Property_Key__c = 'IOT_EVENT_ALLOWDED_OBJECT';

         SVMXC__ServiceMax_Property_Elements__c svmxIbPeopertyElement = new SVMXC__ServiceMax_Property_Elements__c();
        svmxIbPeopertyElement.Name = 'IOTEVENTOBJECT002';
        svmxIbPeopertyElement.SVMXC__Element_Type__c = 'Installed Product';
        svmxIbPeopertyElement.SVMXC__Element_Value__c = 'SVMXC__Installed_Product__c';
        svmxIbPeopertyElement.SVMXC__Property_Key__c = 'IOT_EVENT_ALLOWDED_OBJECT';
         
         SVMXC__ServiceMax_Property_Elements__c svmxWOPeopertyElement = new SVMXC__ServiceMax_Property_Elements__c();
        svmxWOPeopertyElement.Name = 'IOTEVENTOBJECT003';
        svmxWOPeopertyElement.SVMXC__Element_Type__c = 'Work Order';
        svmxWOPeopertyElement.SVMXC__Element_Value__c = 'SVMXC__Service_Order__c';
        svmxWOPeopertyElement.SVMXC__Property_Key__c = 'IOT_EVENT_ALLOWDED_OBJECT';
         
         SVMXC__ServiceMax_Property_Elements__c svmxSRPeopertyElement = new SVMXC__ServiceMax_Property_Elements__c();
        svmxSRPeopertyElement.Name = 'IOTEVENTOBJECT004';
        svmxSRPeopertyElement.SVMXC__Element_Type__c = 'Service Request';
        svmxSRPeopertyElement.SVMXC__Element_Value__c = 'SVMXC__Service_Request__c';
        svmxSRPeopertyElement.SVMXC__Property_Key__c = 'IOT_EVENT_ALLOWDED_OBJECT';

        svmxPeopertyElementList.add(svmxCasePeopertyElement);
        svmxPeopertyElementList.add(svmxIbPeopertyElement);
        svmxPeopertyElementList.add(svmxWOPeopertyElement);
        svmxPeopertyElementList.add(svmxSRPeopertyElement);
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( svmxPeopertyElementList, COMM_SecurityUtils.Access.Createable ) ) {
                    insert svmxPeopertyElementList; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
        return svmxPeopertyElementList;
    }

    /*
        Translations goes here
    */
    
    public List<Translation> getTranslations() {
        List<Translation> translations = new List<Translation>();
        translations.add(new Translation('NONE', system.Label.COMM002_TAG005));//'--None--'
        translations.add(new Translation('SAVE_SUCCESS', system.Label.COMM001_TAG058));//'Record(s) saved successfully'
        translations.add(new Translation('SAVE', system.Label.COMM001_TAG039));//'Save'
        translations.add(new Translation('CANCEL', system.Label.COMM001_TAG040));//'Cancel'
        translations.add(new Translation('BACK_TO_SETUP_HOME', system.Label.COMM001_TAG046));//'Back To Setup Home'
        translations.add(new Translation('SELECT_SEARCH', system.Label.PRODIQ001_TAG086));
        translations.add(new Translation('EVENT_NAME', system.Label.PRODIQ001_TAG198));
        translations.add(new Translation('CLASS_NAME', system.Label.PRODIQ001_TAG199));
        translations.add(new Translation('IOT_EVENTS', system.Label.PRODIQ001_TAG200));
        translations.add(new Translation('IOT_SETUP', system.Label.PRODIQ001_TAG206));
        translations.add(new Translation('EXTERNAL_FLD_NAME', system.Label.PRODIQ001_TAG201));
        translations.add(new Translation('IB_FLD_NAME', system.Label.PRODIQ001_TAG202));
        translations.add(new Translation('COMP_INFO', system.Label.PRODIQ001_TAG203));
        translations.add(new Translation('EXT_KEY', system.Label.PRODIQ001_TAG204));
        translations.add(new Translation('COMP_KEY', system.Label.PRODIQ001_TAG205));
        translations.add(new Translation('ADD', system.Label.PRODIQ001_TAG185));
        translations.add(new Translation('INFO', system.Label.PRODIQ001_TAG056));
        translations.add(new Translation('DELETE', system.Label.PRODIQ001_TAG101));
        translations.add(new Translation('OK', system.Label.PRODIQ001_TAG112));
        translations.add(new Translation('MAP_EVENT', system.Label.IOT001_TAG011));
        translations.add(new Translation('EVENT_TEMPLATE', system.Label.IOT001_TAG012));
        translations.add(new Translation('EVENT_NAME', system.Label.IOT001_TAG013));
        translations.add(new Translation('EVENT_DESCRIPTION', system.Label.IOT001_TAG014));
        translations.add(new Translation('SELECT_OBJECT', system.Label.IOT001_TAG015));
        translations.add(new Translation('SELECT_IB_LOOKUP', system.Label.IOT001_TAG016));
        translations.add(new Translation('FILED_NAME', system.Label.IOT001_TAG017));
        translations.add(new Translation('FIELD_KEY', system.Label.IOT001_TAG018));
        translations.add(new Translation('MAP_TO_APEX', system.Label.IOT001_TAG019));
        translations.add(new Translation('MAP_TO_OBJECT', system.Label.IOT001_TAG020));
        translations.add(new Translation('OBJECT', system.Label.IOT001_TAG021));
        translations.add(new Translation('APPLY', system.Label.PRODIQ001_TAG176));
        translations.add(new Translation('SELECT', system.Label.PRODIQ001_TAG173));
        translations.add(new Translation('MESSAGE_INFO', system.Label.PRODIQ001_TAG056));//'Info'
        translations.add(new Translation('MESSAGE_SUCCESS', system.Label.COMM001_TAG096));//'Success'
        translations.add(new Translation('MESSAGE_ERROR', system.Label.PRODIQ001_TAG057));//'Error'
        translations.add(new Translation('MESSAGE_CONFIRM', system.Label.PRODIQ001_TAG058));//'Confirm'
        translations.add(new Translation('EMPTY_KEY', system.Label.IOT001_TAG022));
        translations.add(new Translation('EMPTY_FIELD', system.Label.IOT001_TAG023));
        translations.add(new Translation('DUPLICATE_KEY', system.Label.IOT001_TAG024));
        translations.add(new Translation('DUPLICATE_FIELD', system.Label.IOT001_TAG025));
        translations.add(new Translation('CREATE_EVENT', system.Label.IOT001_TAG011));
        translations.add(new Translation('SELECT_FIELD_MAP', system.Label.IOT001_TAG027));
        translations.add(new Translation('EMPTY_EVENT_NAME', system.Label.IOT001_TAG028));
        translations.add(new Translation('DUPLICATE_EVENT_NAMES', system.Label.IOT001_TAG029));
        translations.add(new Translation('LOOKUP_FIELD_ID', system.Label.IOT001_TAG030));
        translations.add(new Translation('NA', system.Label.IOT001_TAG031));
        translations.add(new Translation('EMPTY_LOOKUP_ID', system.Label.IOT001_TAG032));
        return translations; 
    }
    
    /* 
        all the request and response declarations goes here
    */            
    public virtual class AbstractResponse{
        
        public Boolean status = true;
        public String message = '';
        public AbstractResponse(){
            
        }       
    }
    
    public class GetSetupMetadataResponse extends AbstractResponse{
        
        public List<SForceObject> sforceObjectDescribes;
        public List<Translation> translations;
        public List<IoTEvent> events;
        public CompositeKey compositeKey;
        public List<IoTEventObject> eventObjects;
        public GetSetupMetadataResponse(){
            
        }

        public void setSForceObjectDescribes(List<SForceObject> sforceObjectDescribes) {
            this.sforceObjectDescribes = sforceObjectDescribes;
        }
        
        public void setTranslations(List<Translation> translations) {
            this.translations = translations;
        }

        public void setEvents(List<IoTEvent> events){
            this.events = events;
        }

        public void setCompositeKey(CompositeKey compositeKey){
            this.compositeKey = compositeKey;
        }
        public void setEventObjects(List<IoTEventObject> eventObjects){
            this.eventObjects = eventObjects;
        }
        
    }
    public class GetObjectDescribeResponse extends AbstractResponse{
        
        public List<SForceObject> sforceObjectDescribes;
        
        
        public GetObjectDescribeResponse(){
            
        }

        public void setSForceObjectDescribes(List<SForceObject> sforceObjectDescribes) {
            this.sforceObjectDescribes = sforceObjectDescribes;
        }
        
       
        
    }
    public class SForceObjects{
        List<SForceObject> allObjects;
    }
    public class SForceObject {
        public String objectLabel;
        public String objectAPIName;
        public List<SForceField> fields;
    }
    
    public class SForceField {
        public String fieldLabel;
        public String fieldAPIName;
        public String type;
        public String referenceTo;
        public String relationshipName;
        public boolean nameField;
        public boolean isExternalId;     
    }
    
    public class Translation {
        public String Key;
        public String Text;
        
        public Translation(String k, String t){
            this.Key = k;
            this.Text = t;
        }
    }
     
    public class IoTConfigurations{
        public List<IoTEvent> events;
        public List<String> deletedEvents;
        public List<IoTMapToObjectEvent> objectMapEvents;
        public List<String> deletedObjectMap;
        public CompositeKey compositeKey;
    }

    public class CompositeKey{
        public List<Keys> ibFields;
        public List<Keys> externalFields;
    }

    public class Keys{
        public Integer sequence;
        public String name;
    }

    public class IoTEvent{
        public String eventId;
        public String eventName;
        public String className;
        public IoTEvent(String eventId, String eventName, String className){
            this.eventId = eventId;
            this.eventName = eventName;
            this.className = className;
        }
    }
   public class IoTMapToObjectEvent{
        public String eventId;
        public String sfdc;
        public String eventName;
        public String eventDescription;
        public String payload;
        public IoTMapToObjectEvent(String sfdc, String eventName, String eventDescription, String payload){
            this.sfdc = sfdc;
            this.eventName = eventName;
            this.eventDescription = eventDescription;
            this.payload = payload;
        }
    }

    public class IoTEventObject{
        public String objectLabel;
        public String objectName;
    }

    
    
}