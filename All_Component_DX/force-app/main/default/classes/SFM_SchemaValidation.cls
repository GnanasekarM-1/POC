/* Security Scanned */
public with sharing class SFM_SchemaValidation {
    
    private Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    public SVMX_Debug  log = new SVMX_Debug();
    private SFM_Utils utils = new SFM_Utils();
    
    public SFM_SchemaValidation()
    {
        allObjs = Schema.getGlobalDescribe(); 
    }
    
    // Pass the expression, mapping, etc related to process and get done with schema validated
    public SFM_WrapperDef.SFM_Response doValidation(SFM_WrapperDef.SFM_Request_IntegrityCheck request)
    {
        SFM_WrapperDef.SFM_Response result = new SFM_WrapperDef.SFM_Response();
        SFM_GetObjectFieldList clsObjectFields = new SFM_GetObjectFieldList();
        Boolean isSucess = TRUE;
        
        //log.login('SFM_SchemaValidation', 'doValidation\n');
        List<String> lstFailedFor = new List<String>();
        if(request.objects != null)
        {
            for(SFM_WrapperDef.SFM_Request_ObjectFields objData: request.objects)
            {
                if(objData.fields != null)
                {
                    SFM_WrapperDef.SFM_Response_ObjectFields response = new SFM_WrapperDef.SFM_Response_ObjectFields();
                    Map<String,Schema.DescribeFieldResult> mapAvailableFieldProperty = new Map<String,Schema.DescribeFieldResult>();
                    Map<String,Schema.SObjectField> fieldMapping = new Map<String,Schema.SObjectField>();
                    set<String> fieldPropertyError = new set<String>();
                    set<String> fieldAvailabilityError = new set<String>();
                    // Building target org field properties
                    if(utils.getOriginalAPIName(objData.objectAPI, allObjs) != NULL)
                        objData.objectAPI = utils.getOriginalAPIName(objData.objectAPI, allObjs);
                    try
                    {
                    Schema.SObjectType selectedObject = allObjs.get(objData.objectAPI);
                    fieldMapping = selectedObject.getDescribe().fields.getMap();
                    }
                    catch(exception ex)
                    {
                        isSucess = FALSE;
                        lstFailedFor.add(objData.objectAPI);
                        log.setlog('DEBUG', system.label.CONF019_TAG088 + ' ' + objData.objectAPI);
                        break;
                    }
                    for(Schema.SObjectField fieldMap: fieldMapping.values())
                    {
                        //Describe the field to get all properties
                        Schema.DescribeFieldResult field = fieldMap.getDescribe();
                        mapAvailableFieldProperty.put(field.getName().toUpperCase(), field);
                    }
                    // For each source fields validate whether target fields are available
                    for(SFM_WrapperDef.SFM_Request_FieldProperties sourceFields: objData.fields)
                    {
                        if(mapAvailableFieldProperty.containsKey((sourceFields.fieldAPI).toUpperCase()))
                        {
                            if(sourceFields.fieldType != null)
                            {
                                Schema.DescribeFieldResult field = mapAvailableFieldProperty.get((sourceFields.fieldAPI).toUpperCase());
                                // If field available in target org check for field type property
                                if(sourceFields.fieldType.toUpperCase() == String.valueof(field.getType()).toUpperCase())
                                {
                                    // If field is reference check for its related object and also check whether both are master detail / lookup
                                    if(sourceFields.fieldType.toUpperCase() == 'REFERENCE')
                                    {
                                        String strReference = '';
                                        for(Schema.sObjectType targetFiedlRef: field.getReferenceTo())
                                        {
                                            if(strReference != '')
                                                strReference += ',';
                                            strReference += targetFiedlRef.getDescribe().getName().toUpperCase();
                                        }
                                        system.debug('TEST LOG: ' + sourceFields.referenceTo.toUpperCase() + strReference);
                                        /*
                                        for(Schema.ChildRelationship fieldRelationShip: field.getChildRelationships())
                                        {
                                            Schema.sObjectType targetFiedlRef = fieldRelationShip.getChildSObject();
                                            if(sourceFields.referenceTo.toUpperCase() == targetFiedlRef.getDescribe().getName().toUpperCase())
                                            {
                                                if(sourceFields.isCascadeDelete == targetFiedlRef.getDescribe().getChildRelationships())
                                                {
                                                    isValid = true;
                                                    break;
                                                }
                                            }
                                        }*/
                                        if(sourceFields.referenceTo.toUpperCase() != strReference)
                                        {
                                            isSucess = FALSE;
                                            lstFailedFor.add(objData.relatedTo + '_' + objData.relatedReference);
                                            fieldPropertyError.add(sourceFields.fieldAPI);
                                        }
                                    }
                                    // Check for length porperty if field type
                                    else if(sourceFields.fieldLength == field.getLength())
                                    {
                                        // Field length is equal
                                    }
                                    else
                                    {
                                        isSucess = FALSE;
                                        lstFailedFor.add(objData.relatedTo + '_' + objData.relatedReference);
                                        fieldPropertyError.add(sourceFields.fieldAPI);
                                    }
                                }
                                else
                                {
                                    isSucess = FALSE;
                                    lstFailedFor.add(objData.relatedTo + '_' + objData.relatedReference);
                                    fieldPropertyError.add(sourceFields.fieldAPI);
                                }
                            }
                            else
                            {
                                isSucess = FALSE;
                                lstFailedFor.add(objData.relatedTo + '_' + objData.relatedReference);
                                fieldAvailabilityError.add(sourceFields.fieldAPI);
                            }
                        }
                        else
                        {
                            isSucess = FALSE;
                            lstFailedFor.add(objData.relatedTo + '_' + objData.relatedReference);
                            fieldAvailabilityError.add(sourceFields.fieldAPI);
                        }
                    }
                    
                    if(fieldPropertyError != NULL && fieldPropertyError.size() > 0)
                    {
                        String strError = system.label.CONF019_TAG091 + objData.objectAPI + system.label.CONF019_TAG089 + ' ';
                        for(String field: fieldPropertyError)
                            strError += field + ', ';
                        log.setlog('ERROR', strError);
                    }
                    if(fieldAvailabilityError != NULL && fieldAvailabilityError.size() > 0)
                    {
                        String strError = system.label.CONF019_TAG091 + objData.objectAPI + system.label.CONF019_TAG090 + ' ';
                        for(String field: fieldAvailabilityError)
                            strError += field + ', ';
                        log.setlog('ERROR', strError);
                    }
                }
                else
                {
                    // No field mapping is avaialble on source to check
                }
            }
        }
        //log.logout();           
        // Setup result wrapper
        
        if(isSucess)
        log.setlog('FINE', system.label.CONF019_TAG092);
        
        result.resultIds.add(request.processId);
        result.logMsg = log.getlog();
        result.success = isSucess;
        return result;
    }
    
    // Called by source org to get all source update details
    public SFM_WrapperDef.SFM_Request_IntegrityCheck getAllSourceUpdates(SFM_WrapperDef.SFM_Request prequest)
    {
        SFM_WrapperDef.SFM_Request_IntegrityCheck response = new SFM_WrapperDef.SFM_Request_IntegrityCheck();
        Map<String,String> request = new Map<String,String>();
        request = utils.getStringMap(prequest.stringMap);
        
        if(request.get('PROCESSID') != NULL)
        {
            response.processId = request.get('PROCESSID');
            Map<Id, SVMXC__ServiceMax_Processes__c> mapTargetObject = new Map<Id, SVMXC__ServiceMax_Processes__c>();
            List<SFM_WrapperDef.SFM_Request_ObjectFields> objects = new List<SFM_WrapperDef.SFM_Request_ObjectFields>();
                
            Set<Id> setTargetProcessNodeObject = new set<Id>();
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            list<SVMXC__ServiceMax_Config_Data__c> lstSourceUpdate = [Select SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c,   SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, Name, Id, SVMXC__Preference_2__c, SVMXC__Preference_3__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c = :request.get('PROCESSID') and Recordtype.Name='Field Mapping'];
            if(lstSourceUpdate.size() >0)
            {
                system.debug('TEST LOG' + lstSourceUpdate);
                for(SVMXC__ServiceMax_Config_Data__c sourceUpdate: lstSourceUpdate)
                {
                    setTargetProcessNodeObject.add(sourceUpdate.SVMXC__Setting_ID__c);
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                mapTargetObject.putAll([Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__Node_Source_Object_API__c  From SVMXC__ServiceMax_Processes__c where Id IN :setTargetProcessNodeObject]);
                
                Map<String, List<SFM_WrapperDef.SFM_Request_FieldProperties>> mapObjectField = new Map<String, List<SFM_WrapperDef.SFM_Request_FieldProperties>>();
                for(SVMXC__ServiceMax_Config_Data__c sourceUpdate: lstSourceUpdate)
                {
                    if(mapTargetObject.containsKey(sourceUpdate.SVMXC__Setting_ID__c) && mapTargetObject.get(sourceUpdate.SVMXC__Setting_ID__c) != NULL)
                    {
                        // Source object and its field prperty
                        SFM_WrapperDef.SFM_Request_FieldProperties sourceField = new SFM_WrapperDef.SFM_Request_FieldProperties();
                        sourceField.fieldAPI = sourceUpdate.SVMXC__Source_Field_Name__c;
                        
                        String ObjectName = mapTargetObject.get(sourceUpdate.SVMXC__Setting_ID__c).SVMXC__Node_Source_Object_API__c;
                        
                        if(mapObjectField.containsKey(ObjectName) && mapObjectField.get(ObjectName) != null)
                        {
                            mapObjectField.get(ObjectName).add(sourceField);
                        }
                        else
                        {
                            mapObjectField.put(ObjectName, (new List<SFM_WrapperDef.SFM_Request_FieldProperties>()));
                            mapObjectField.get(ObjectName).add(sourceField);
                        }
                        
                        // If target field available add target object and fields
                        if(sourceUpdate.SVMXC__Target_Field_Name__c != NULL)
                        {
                            SFM_WrapperDef.SFM_Request_FieldProperties targetField = new SFM_WrapperDef.SFM_Request_FieldProperties();
                            ObjectName = mapTargetObject.get(sourceUpdate.SVMXC__Setting_ID__c).SVMXC__Source_Object_Name__c;
                            targetField.fieldAPI = sourceUpdate.SVMXC__Target_Field_Name__c;
                            if(mapObjectField.containsKey(ObjectName) && mapObjectField.get(ObjectName) != null)
                            {
                                mapObjectField.get(ObjectName).add(targetField);
                            }
                            else
                            {
                                mapObjectField.put(ObjectName, (new List<SFM_WrapperDef.SFM_Request_FieldProperties>()));
                                mapObjectField.get(ObjectName).add(targetField);
                            }
                        }
                    }
                }
                
                // Populate the response
                for(String objectName: mapObjectField.keySet())
                {
                    SFM_WrapperDef.SFM_Request_ObjectFields objectDetails = new SFM_WrapperDef.SFM_Request_ObjectFields();
                    objectDetails.objectAPI = objectName;
                    if(mapObjectField.get(objectName) != NULL && mapObjectField.get(objectName).size() > 0)
                    {
                        objectDetails.fields = mapObjectField.get(objectName);
                        objects.add(objectDetails);
                    }
                }
                response.objects = objects;
            }
        }
        
        return response;
    }
    
    // Called by source org to get all source update details
    public List<SFM_WrapperDef.SFM_Response_NamedSearchInfo> getAllNamedSearchInfo(SFM_WrapperDef.SFM_Request request)
    {
        List<SFM_WrapperDef.SFM_Response_NamedSearchInfo> response = new List<SFM_WrapperDef.SFM_Response_NamedSearchInfo>();
        for(SFM_WrapperDef.SFM_StringMap req: request.stringMap)
        {
            if(req.key == 'RECORDID')
            {
                SFM_WrapperDef.SFM_Request namedSearch = new SFM_WrapperDef.SFM_Request();
                namedSearch.stringMap.add(req);
                SVMXC.SFM_getNamedSearchInfo getnamedsearch = new SVMXC.SFM_getNamedSearchInfo();
                response.add(getnamedsearch.getNamedSearchInfo(namedSearch));
            }
        }
        return response;
    }
}