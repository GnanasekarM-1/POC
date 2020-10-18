/*****************************************************************************
 *                       Copyright (C) 2017 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * This is the engine class to handle dynamic field mapping event from external system, 
 * All field mapping configurations should be configured in IoT-setup page and same data used here to 
 *resolve the mapping.
 *
 *
 */
/* Security Scanned */
global class COMM_IoTRestApiEngine extends IOTImplInterface {
    

     /**
     * This is override method from Super class IOTImplInterface to execute the event request.
     * 
     * @param request , request JSON from endpoint url.
     * @param eventName, Event name called from external system.
     * @return AbstractResponse instance, with execution result.
     */
    private static Map<String,Schema.sObjecttype> globalObjectMap = Schema.getGlobalDescribe();//Added for 047662
    override public Object execute(IoTRequest.ServiceRequestAlert request, String eventName) { 
        System.debug('Request reached COMM_IoTRestApiEngine: ' + request);
                AbstractResponse response = new AbstractResponse();
        if(request != null && request.CustomEvent != null ){
                
                        List<String> queryFields = new List<String>{'SVMXC__SM_Description__c','SVMXC__SM_Event_Name__c','SVMXC__SM_JSON_Payload__c'};
                             if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SM_IoT_Field_Mapping__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                             }
                        List<SVMXC__SM_IoT_Field_Mapping__c> iotFieldMapList = [Select Id,SVMXC__SM_Description__c,SVMXC__SM_Event_Name__c,SVMXC__SM_JSON_Payload__c FROM SVMXC__SM_IoT_Field_Mapping__c where SVMXC__SM_Event_Name__c =:eventName]; //SDL-SVMX-READ-FLS-ENFORCED
                        if(iotFieldMapList.size() > 0){
                            SVMXC__SM_IoT_Field_Mapping__c iotFieldMap = new SVMXC__SM_IoT_Field_Mapping__c();
                            iotFieldMap = iotFieldMapList[0];
                            String payload = iotFieldMap.SVMXC__SM_JSON_Payload__c;
                            FieldMap fMap = (FieldMap)JSON.deserialize(payload , FieldMap.class);
                            response = executeFieldMapping(fMap, eventName,request);
                        }else{
                            response.message = System.Label.IOT001_TAG039;
                            response.status = false;
                        }
                

               
        }else{
            response.message = System.Label.IOT001_TAG037;
            response.status = false;
        }
        return response;
        
    }


    /**
     * This method process the given mapping fields with keys provided in end point url.
     * And does DML operation.
     * @param fMap, FieldMap instance with all mapping field for selected event.
     * @param request, JSON request from end point url.
     * @return AbstractResponse instance, with execution result.
     */
private AbstractResponse executeFieldMapping(FieldMap fMap, String eventName, IoTRequest.ServiceRequestAlert request){
            AbstractResponse response = new AbstractResponse();
            response.message = System.Label.IOT001_TAG040;
             response.status = true;
            Map<String,String> requestFiledMap = request.CustomEvent;
            Map<String,Field> identifierMap = getRecordIdentifier(fMap);
            RecordResponse recResponse = new RecordResponse();
            recResponse = getRecordDetails(requestFiledMap,identifierMap,fMap.objName);
            response.message = recResponse.message;
            response.status = recResponse.status;
            if(recResponse.status){
                Set<String> requestKeys = request.CustomEvent.keySet();
                ValidateFieldResponse vFieldResponse =  processEventFieldMap(requestKeys,fMap);
                if(vFieldResponse.status){
                        Map<String,List<Field>> eventFieldMap = vFieldResponse.eventFieldMap;
                        Set<String> objectFieldKeySet = eventFieldMap.keySet();
                        String objectName = fMap.objName;

                //Map<String,Schema.sObjecttype> globalObjectMap = Schema.getGlobalDescribe(); //Commented for 047662
                            sobject newObject = globalObjectMap.get(objectName).newSObject();
                for(String fieldKey : objectFieldKeySet){
                                if(!response.status) break;
                            List<Field> eFieldList = eventFieldMap.get(fieldKey);
                            for(Field eField: eFieldList){
                                String fType = eField.fldType;
                                String fValue = requestFiledMap.get(fieldKey);
                                if(fType.equals('text') || fType.equals('URL')  || fType.equals('TEXTAREA') || fType.equals('STRING') || fType.equals('PHONE') ){
                                        Boolean isValid = validateFieldLength(objectName,eField.fldApi,fValue);
                                        if(!isValid){
                                            response.message = System.Label.IOT001_TAG042 +eField.fldApi +' length';
                                            response.status = false;
                                            break;
                                        }
                                        if(!eField.fldApi.equals('Name'))newObject.put(eField.fldApi, fValue);
                                    }else if(fType.equals('DATETIME')){
                                        if(String.isBlank(fValue)){
                                            newObject.put(eField.fldApi, null);
                                            }else{
                                                Datetime dtTime = validateDateTime(fValue);
                                                if(dtTime != null){
                                                     newObject.put(eField.fldApi, dtTime);
                                                    }else {
                                                        response.message = System.Label.IOT001_TAG044 + eField.fldApi;
                                                        response.status = false;
                                                        break;
                                                    }
                                            }
                                        

                                    }else if(fType.equals('DATE')){
                                        if(String.isBlank(fValue)){
                                            newObject.put(eField.fldApi, null);
                                            }else{
                                                Datetime dtTime = validateDateTime(fValue);
                                                if(dtTime != null){
                                                     newObject.put(eField.fldApi, dtTime.date());
                                                    }else {
                                                      response.message = System.Label.IOT001_TAG044 + eField.fldApi;
                                                     response.status = false;
                                                     break;
                                                    }
                                            }
                                        
                                        
                                    }else if(fType.equals('BOOLEAN') && String.isNotBlank(fValue)){
                                        String bString = 'false';
                                        if(fValue.equalsIgnoreCase('true') || fValue.equalsIgnoreCase('yes') || fValue.equalsIgnoreCase('1') ) bString = 'true';
                                        Boolean bValue = Boolean.valueOf(bString);
                                        newObject.put(eField.fldApi, bValue);
                                    }else if(fType.equals('PICKLIST') || fType.equals('MULTIPICKLIST')){
                                        newObject.put(eField.fldApi, fValue);

                                    }else if(fType.equals('REFERENCE')){

                                        RefRecordResponse refRecordResponse = new RefRecordResponse();

                                        if(String.isEmpty(fValue)){
                                            newObject.put(eField.fldApi, fValue);
                                            }else{
                                                 refRecordResponse = getRefRecordId(eField,fValue);

                                                if(refRecordResponse.isValidFld && !refRecordResponse.isEmptyFld){
                                              
                                              newObject.put(eField.fldApi, refRecordResponse.refRecordId);

                                            }else if(!refRecordResponse.isValidFld){
                                                response.message = refRecordResponse.message;
                                                response.status = false;
                                                break;
                                            }else if(refRecordResponse.isEmptyFld){
                                                response.message = refRecordResponse.message;
                                                response.status = false;
                                                break;
                                            }

                                                } 

                                    }else if(fType.equals('DOUBLE') || fType.equals('NUMBER') || fType.equals('CURRENCY')|| fType.equals('PERCENT')){
                                        if(String.isBlank(fValue)){
                                            newObject.put(eField.fldApi, null);
                                            }else{
                                                Boolean isValidNum = isNumeric(fValue);
                                                if(!isValidNum){
                                                response.message = System.Label.IOT001_TAG043;
                                                response.status = false;
                                                break;
                                                }
                                                Decimal intValue = Decimal.ValueOf(fValue);
                                                newObject.put(eField.fldApi, intValue);
                                            } 
                                        
                                    }else if(fType.equals('EMAIL')){
                                        Boolean isValidEmail = validateEmail(fValue);
                                        if(!isValidEmail){
                                            response.message = System.Label.IOT001_TAG045;
                                            response.status = false;
                                            break;
                                        }
                                        newObject.put(eField.fldApi, fValue);
                                    }
                            }
                        }
                        try{

                                         if(response.status){

                                            Boolean isIB_Lookup = shouldConsiderIB_LookUpConfiguration(fMap,requestKeys);
                                            if(isIB_Lookup){
                                                String ibiD = getInstalledProductID();
                                                 Map<String , Field> ibLookupMap = getAllIBlookupFields(fMap);
                                                 Set<String>  ibLookupKeySet = ibLookupMap.keySet();
                                                 for(String ibKey : ibLookupKeySet){
                                                    Field fld = ibLookupMap.get(ibKey);
                                                    if(String.isNotEmpty(ibiD)) newObject.put(fld.fldApi, ibiD);
                                                 }
                                            }


                                            if(String.isNotBlank(recResponse.recordId)){
                                                newObject.Id = recResponse.recordId;
                                                } else {
                                                   newObject.Id = null; 
                                                }
                                            
                                            System.debug(' newObject  '+newObject);
                                            System.debug('COMM_SecurityUtils.getInstance().verifyFieldAccess(newObject, COMM_SecurityUtils.Access.Upsertable) '+COMM_SecurityUtils.getInstance().verifyFieldAccess(newObject, COMM_SecurityUtils.Access.Upsertable));
                                            
                                            if(!COMM_SecurityUtils.getInstance().isCreateable(objectName)){
                                            //#ANA-152 - Update the event object with the information.
                                                updateTarget(ERROR_STATUS, '', System.Label.COMM001_TAG142, false);
                                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );

                                            }
                                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(newObject, COMM_SecurityUtils.Access.Upsertable)){
                                                upsert newObject; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                                            }
                                            else{
                                                //#ANA-152 - Update the event object with the information.
                                                updateTarget(ERROR_STATUS, '', System.Label.COMM001_TAG142, false);
                                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                                            }
                                    response.status = true;
                                    response.message =  getResponseMessage(objectName,newObject.Id);
                                    //#ANA-152 - Update the event object with the information.
                                    updateTarget(COMPLETED_STATUS, newObject.Id, '', false);
                                    }

                            }catch(DmlException e) {
                                    System.debug('The following exception has occurred: ' + e.getMessage());
                                    response.status = false;
                                    response.message = e.getMessage();
                            }catch(Exception ex){
                                System.debug('The following exception has occurred: ' + ex.getMessage());
                                    response.status = false;
                                    response.message = ex.getMessage();
                            }

                       
                    }else{
                            response.status = false;
                            response.message = vFieldResponse.message;
                            //#ANA-152 - Update the event object with the information.
                             updateTarget(ERROR_STATUS, '', vFieldResponse.message, false);
                    }
                
            }

                return response;
    }

    private String getResponseMessage(String objectName, String recordId){
       String message  = '';
       if(objectName.equals('Case')){
        message = getResponseMessageStandardObject(objectName, recordId);
        }else{
        String recordName = '';
        List<String>  idList = new List<String>();
        idList.add(recordId);
        List<sObject> records = Database.query('Select Id,  Name From ' + objectName + ' Where Id in :idList');
        if(records.size() > 0) recordName = String.valueOf(records[0].get('name')) ;
         message = System.Label.IOT001_TAG026 + recordId  + ', ' + System.Label.IOT001_TAG036 + recordName;
        } 
        return message;
    }
private String getResponseMessageStandardObject(String objectName, String recordId){
         String message = System.Label.IOT001_TAG026 + recordId ;
        return message;
}
 private Boolean shouldConsiderIB_LookUpConfiguration(FieldMap fMap, Set<String> requestKeySet){
    Map<String , Field> ibLookupMap = getAllIBlookupFields(fMap);
    Set<String>  ibLookupKeySet = ibLookupMap.keySet();
    Boolean isContain = false;
    for(String ibLookupKey : ibLookupKeySet){
        isContain = requestKeySet.Contains(ibLookupKey);
        if(isContain) break;
    }
   return !isContain;
 }   
 private Map<String , Field> getAllIBlookupFields(FieldMap fMap){
    Map<String , Field> ibLookupMap = new Map<String , Field>();
     
     for(Field fld : fMap.fld){
        if(String.isNotEmpty(fld.refObj) && fld.refObj.equals('SVMXC__Installed_Product__c')){
            ibLookupMap.put(fld.fldKey, fld);
        }
     }
     return ibLookupMap;
 }

private RecordResponse getRecordDetails(Map<String,String> requestFldMap , Map<String,Field> identifierMap , String objectName){
            
            Set<String> allKeys = requestFldMap.keySet();
            Map<String,String> requestFiledMap  = new Map<String,String>();
            for(String iKey: allKeys){
                requestFiledMap.put(iKey.toLowerCase(), requestFldMap.get(iKey));
            }
            RecordResponse response = new RecordResponse();
            response = getRecordDetailsForID( requestFiledMap , identifierMap ,  objectName);
            if(response.isValid && String.isEmpty(response.recordId)){
                response = getRecordDetailsName( requestFiledMap , identifierMap ,  objectName);
                if(response.isValid && String.isEmpty(response.recordId)){
                    response = getRecordDetailsExternalIDs( requestFiledMap , identifierMap ,  objectName);

                }
            } 
            return response;
}
private RecordResponse getRecordDetailsForID(Map<String,String> requestFiledMap , Map<String,Field> identifierMap , String objectName){
            RecordResponse response = new RecordResponse();
            response.message = 'getRecordDetailsForID';
            response.isValid = true;
            response.status = true;
            response.recordId = '';
              Field fld = identifierMap.get('Id');
              if(fld != null ){
                String fldKey = fld.fldKey;
                String value = requestFiledMap.get(fldKey.toLowerCase());
                if(String.isNotEmpty(value)){
                    String recordId = getRecordId(objectName ,value, fld.fldApi);
                        if(String.isNotEmpty(recordId)){
                            response.recordId = recordId;
                            }else{
                             response.isValid = false;
                             response.status = false;
                             response.message =  System.Label.IOT001_TAG033;
                            }
                    }
              }
             return response;
}
private RecordResponse getRecordDetailsName(Map<String,String> requestFiledMap , Map<String,Field> identifierMap , String objectName){
            RecordResponse response = new RecordResponse();
            response.message = 'getRecordDetailsName';
            response.isValid = true;
            response.status = true;
            response.recordId = '';
              Field fld = identifierMap.get('Name');
              if(fld != null ){
                String fldKey = fld.fldKey;
                String value = requestFiledMap.get(fldKey.toLowerCase());
                if(String.isNotEmpty(value)){
                    String recordId = getRecordId(objectName ,value, fld.fldApi);
                        if(String.isNotEmpty(recordId)){
                            response.recordId = recordId;
                            }else{
                             response.isValid = false;
                             response.status = false;
                             response.message = System.Label.IOT001_TAG033 ;
                            }
                    }
              }
             return response;
}
private RecordResponse getRecordDetailsExternalIDs(Map<String,String> requestFiledMap , Map<String,Field> identifierMap , String objectName){
            Field idfld = identifierMap.get('Id');
            Field namefld = identifierMap.get('Name');
            if(idfld != null) identifierMap.remove('Id');
            if(namefld != null) identifierMap.remove('Name');
            
            RecordResponse response = new RecordResponse();
            response.message = 'getRecordDetailsExternalIDs';
            response.isValid = true;
            response.status = true;
            response.recordId = '';
            
            Set<String> mapKeys = identifierMap.keySet();
            for(String key : mapKeys){
                Field fld = identifierMap.get(key);
              if(fld != null ){
                String fldKey = fld.fldKey;
                String value = requestFiledMap.get(fldKey.toLowerCase());
                if(String.isNotEmpty(value)){
                    Boolean isValidFld = validateObjectField(objectName,fld.fldApi);
                    if(!isValidFld){
                            response.status = false;
                            response.message = fld.fldApi +'  '+System.Label.IOT001_TAG034;
                            break;
                        }
                        String recordId = getRecordId(objectName ,value, fld.fldApi);
                        if(String.isNotEmpty(recordId)){
                            response.recordId = recordId;
                            response.status = true;
                        }else{
                            response.status = false;
                            response.message = System.Label.IOT001_TAG033;
                        }
                        
                        break;
                    }
              }
            }            
             return response;
}
private Map<String,Field> getRecordIdentifier(FieldMap fMap){
    Map<String,Field> identifierMap = new Map<String,Field>();
    if(fMap != null){
        List<Field> flds = fMap.fld;
    Integer externalIdCounter = 1;
    for(Field fld:flds){
        if(fld.fldApi.equals('Id') || fld.fldApi.equals('Name')){
            identifierMap.put(fld.fldApi, fld);
        }else if(fld.isExternalId){
            identifierMap.put('externalId'+String.valueOf(externalIdCounter), fld);
            externalIdCounter ++;
        }

        }
    }
    
    return identifierMap;
}

     



    /**
     * This method, create the Map instance for keys and field_api name.
     * Also validate the fields in object. if invalid fields are configured then ignore it.
     * @param requestKeys , all keys from request end point.
     * @param fMap, FieldMap instance with all mapping field for selected event.
     * @return ValidateFieldResponse.
     */

     private ValidateFieldResponse processEventFieldMap(Set<String> requestKeys, FieldMap fMap){
        ValidateFieldResponse validateFieldResponse = new ValidateFieldResponse();
        validateFieldResponse.status = true;
        Map<String,List<Field>> eventFieldMap = new  Map<String,List<Field>>();
        List<Field> fieldList = fMap.fld;
        for(String key:requestKeys){
            if(!validateFieldResponse.status) break;
            List<Field> eFieldList = new List<Field>();
            for(Field eField : fieldList){
                Boolean isValidField = validateObjectField(fMap.objName,eField.fldApi);
                if(eField.fldKey.equalsignorecase(key) && isValidField){
                    validateFieldResponse.status = true;
                    eFieldList.add(eField);

               } else if(eField.fldKey.equalsignorecase(key) && !isValidField){
                    validateFieldResponse.status = false;
                    validateFieldResponse.message = eField.fldApi + ' - '+ System.Label.IOT001_TAG034;
                    break;
                }
            }
            eventFieldMap.put(key, eFieldList);
         }
         validateFieldResponse.eventFieldMap = eventFieldMap;
         return validateFieldResponse;
    }

    /**
     * This method validate field name in given object.
     * @param objectName 
     * @param fieldName
     * @return isValid, returns true for valid fields, Else false.
     */

     private Boolean validateObjectField(String objectName, String fieldName){
        
        Boolean isValid = true;
        //SObjectType objType = Schema.getGlobalDescribe().get(objectName); //Commented for 047662
        SObjectType objType = globalObjectMap.get(objectName); //Added for 047662
        Set<String> objectFieldSet = objType.getDescribe().fields.getMap().keySet();
        if(!objectFieldSet.contains(fieldName.toLowerCase())){
            isValid = false;
        }
        return isValid;
    }

    
    /**
     * This method IB SFDC id which is configured in IOT-lookup page.
     * @return installedProductIds
     */
     
     private String getInstalledProductID(){
        Object installedProductIds = super.IPLookup_IoT();
        if(installedProductIds instanceof Id){
            return String.valueOf(installedProductIds);
        }
        return null;
    }  

   
    /**
     * This returns the SFDC id for given object.
     * @param objectName .
     * @param fValue.
     * @param fName.
     * @return recordId.
     */

    private String getRecordId(String objectName, String fValue, String fName){
        String recordId = '';
        String fldType = getFieldType(objectName, fName);
        String queryString = '';
        if(fldType.equals('String')){
            queryString = 'SELECT Id FROM '+objectName+ ' WHERE '+fName+ ' = :fValue';
            }else if(fldType.equals('Integer')){
               Boolean isValidNum = isNumeric(fValue);
                if(!isValidNum){
                    return '';
                }
               queryString = 'SELECT Id FROM '+objectName+ ' WHERE '+fName+ ' = '+Decimal.valueOf(fValue);
            }
        List<sObject> records = Database.query(queryString);
        if(records.size() > 0) recordId = records[0].Id;
        return recordId;
    }

    private RefRecordResponse getRefRecordId(Field fld, String fValue){
        RefRecordResponse refRecordResponse = new RefRecordResponse();
        refRecordResponse.isValidFld = true;
        refRecordResponse.isEmptyFld = false;
        refRecordResponse.message = '';

        String refObject = fld.refObj;
        String refFld = fld.refFld;
        Boolean isValid = validateObjectField(refObject, refFld);
        if(!isValid){
            refRecordResponse.isValidFld = false;
            refRecordResponse.message = refFld +'  '+System.Label.IOT001_TAG034 +'  '+refObject;
        }else{
            String recordId = getRecordId(refObject,fValue,refFld);
            if(String.isNotBlank(recordId)){
                refRecordResponse.isValidFld = true;
                refRecordResponse.isEmptyFld = false;
                refRecordResponse.refRecordId = recordId;
            }else{
                refRecordResponse.isValidFld = true;
                refRecordResponse.isEmptyFld = true;
                refRecordResponse.refRecordId = '';
                refRecordResponse.message = System.Label.IOT001_TAG010;
            }
        }
        return refRecordResponse;
    }
    /* utils */
public static String getFieldType(String objectName, String fieldName){
        String fldType = 'String';
        //Schema.SObjectType obj = Schema.getGlobalDescribe().get(objectName); //Commented for 047662
        Schema.SObjectType obj = globalObjectMap.get(objectName); //Added for for 047662
        Schema.DescribeSObjectResult describe = obj.getDescribe();
        Schema.DescribeFieldResult fld = describe.fields.getMap().get(fieldName).getDescribe();
        if (fld.getType() == Schema.DisplayType.Integer || fld.getType() == Schema.DisplayType.Double){
            fldType = 'Integer';
        }
        return fldType;
}
    public static Boolean validateEmail(String email) {
            if(String.isBlank(email)) return true;
            Boolean res = true;
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(email);
            if (!MyMatcher.matches())
             res = false;
             
            return res;
        }
   public static Boolean isNumeric(String str){
            Boolean returnValue;
            try{
                Decimal.valueOf(str);
                returnValue = TRUE; 
            } catch (Exception e) {
                returnValue = FALSE;
            }
            return returnValue;
        }
    public static Boolean validateFieldLength(String objName, String fName, String fValue){
            Boolean returnValue = true;
            List<String> objList = new List<String>();
            objList.add(objName);
            List<Schema.DescribeSobjectResult> objDec = Schema.describeSObjects(objList);
             Map<String, Schema.SObjectField> objectFields = objDec[0].fields.getMap();
            Schema.DescribeFieldResult descField = objectFields.get(fName).getDescribe();
            Integer len = descField.getLength();
            System.debug('f length ' + len);
            if(String.isEmpty(fValue)){
                    returnValue = true;
                }else if(fValue.length() > len){
                    returnValue = false;
                } 
           return returnValue;
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
    

    private class FieldMap{
        public String objName;
        public String objLbl;
        public List<Field> fld;

        public FieldMap(){

        }
    }
    private class Field{
        public String fldKey;
        public String fldApi;
        public String fldType;
        public String fldLabel;
        public String refObj;
        public String refFld;
        public String refLabel;
        public Boolean isExternalId;

        public Field(){

        }

    }

   
    public virtual class AbstractResponse{
        
        public Boolean status = true;
        public String message = '';
        public AbstractResponse(){
            
        }       
    }
    public class ValidateFieldResponse extends AbstractResponse{
        public Map<String,List<Field>> eventFieldMap;
        public ValidateFieldResponse (){

        }
    }

     private virtual class RefRecordResponse{
        
        public Boolean isValidFld = true;
        public Boolean isEmptyFld = false;       
        public String refRecordId = '';
        public String message = '';
        public RefRecordResponse(){
            
        }       
    }
  
  private virtual class RecordResponse{
        
        public Boolean isValid = true;
        public Boolean isNew = false;
        public Boolean status = false;
        public String  recordId = '';
        public String message = '';
        public RecordResponse(){
            
        }       
    }

}