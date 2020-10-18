/* Security Scanned */
public with sharing class SFM_GetObjectMapping {
    //Method to return exemptions
    public class SVMXException extends Exception {}
    public SVMX_Debug  log = new SVMX_Debug();
    public set<String> targetRefernceFields = new set<String>();
    SVMXC.COMM_Utils comutils=new SVMXC.COMM_Utils();
    
    Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    
    //==================================Smart_Object==================================//
    Map<String, SmartObject.DescribeSmartObjectResult> allSmartObjects = new Map<String, SmartObject.DescribeSmartObjectResult>();
    Boolean isSourceObjectSmartObject = false;
    Boolean isTargetObjectSmartObject = false;
    //================================================================================//
    
    SFM_Utils utils = new SFM_Utils();
    Map<String, SVMXC__ServiceMax_Config_Data__c> defaultFieldMapping = new Map<String, SVMXC__ServiceMax_Config_Data__c>();
    public SFM_getObjectMapping(){
        allObjs = Schema.getGlobalDescribe(); 
        allSmartObjects = SmartObject.getGlobalDescribe();//added for Smart_Object
    }
    
    public SFM_WrapperDef.SFM_Response_ObjectMapLIst SFM_getAllObjectMap(SFM_WrapperDef.SFM_Request prequest){
        system.debug('prequest'+prequest);
        SFM_WrapperDef.SFM_Response_ObjectMapLIst response = new SFM_WrapperDef.SFM_Response_ObjectMapLIst();
        List<SFM_WrapperDef.SFM_StringMap> result = new List<SFM_WrapperDef.SFM_StringMap>();
        list<SVMXC__ServiceMax_Processes__c >   LstObjectMap = new list<SVMXC__ServiceMax_Processes__c >();
        //Getting the source and target objects from request
        Map<String,String> request = new Map<String,String>();
        request = utils.getStringMap(prequest.stringMap);
        String sourceObjectName = request.get('SOURCE');
        String targetObjectName = request.get('TARGET');
        log.login('SFM_getObjectMapping', 'SFM_getAllObjectMap');
        log.setlog('DEBUG', 'Source Object:'+sourceObjectName+',Target Object:'+targetObjectName);
        if(sourceObjectName != NULL && targetObjectName!=NULL)
            
        LstObjectMap = [Select SVMXC__Name__c, SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, Name, Id,SVMXC__IsStandard__c  From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Object Mapping' AND SVMXC__Source_Object_Name__c=:sourceObjectName AND SVMXC__Target_Object_Name__c=:targetObjectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA // AND SVMXC__Source_Object_Name__c=:sourceObjectName AND SVMXC__Target_Object_Name__c=:targetObjectName
        else if(sourceObjectName != NULL)
            
        LstObjectMap = [Select SVMXC__Name__c, SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, Name, Id,SVMXC__IsStandard__c  From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Object Mapping' AND SVMXC__Source_Object_Name__c=:sourceObjectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA // AND SVMXC__Source_Object_Name__c=:sourceObjectName AND SVMXC__Target_Object_Name__c=:targetObjectName
        else if(targetObjectName != NULL)
            
        LstObjectMap = [Select SVMXC__Name__c, SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, Name, Id,SVMXC__IsStandard__c  From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Object Mapping' AND SVMXC__Source_Object_Name__c=NULL AND SVMXC__Target_Object_Name__c=:targetObjectName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA // AND SVMXC__Source_Object_Name__c=:sourceObjectName AND SVMXC__Target_Object_Name__c=:targetObjectName
        SFM_WrapperDef.SFM_Response resp = new SFM_WrapperDef.SFM_Response(); 
        resp.success = true;
        resp.logMsg = log.getlog();
        response.objectMapping = LstObjectMap;
        response.response = resp;
        return response;
    }
    public SFM_WrapperDef.SFM_Response_ObjectMap getDefaultFieldmapping(SFM_WrapperDef.SFM_Request prequest){
        system.debug('prequest'+prequest);
        List<SFM_WrapperDef.SFM_ObjectMap> resObjects = new List<SFM_WrapperDef.SFM_ObjectMap>();
        SFM_WrapperDef.SFM_ObjectMap objects = new SFM_WrapperDef.SFM_ObjectMap();
        Map<String,String> request = new Map<String,String>();
        request = utils.getStringMap(prequest.stringMap);
        List<String> sourceFieldProperty = new List<String>();
        List<String> targetFieldProperty = new List<String>();
        set<String> blacklistedObjects = new set<String>();
        set<String> whitelistedObjects = new set<String>();
        String sourceObject = request.get('SOURCE');
        String targetObject = request.get('TARGET');
        log.login('SFM_getObjectMapping', 'getDefaultFieldmapping');
        log.setlog('DEBUG', 'Source Object:'+sourceObject+',Target Object:'+targetObject);
        
        //Setting up source entry criteria, source fields has to meet all the criteria to get listed
        //sourceFieldProperty.add('isFilterable');//commented because it was not returning fields of textarea
        sourceFieldProperty.add('isAccessible');
        //sourceFieldProperty.add('isCalculated');
        //Setting up target entry criteria, target fields has to meet all the criteria to get listed
        targetFieldProperty = utils.excludeTargetFieldsProperties;
        blacklistedObjects = utils.excludeTargetFieldsBlackList;
        Map<String,Boolean> whitelist = new Map<String,Boolean>();
        whitelist=comutils.SVMX_getPermittedStandardObjectList();
        for(String whitefield: whitelist.keySet())
        {
            whitelistedObjects.add(whitefield);
        }
        ////system.debug('entered0'+sourceObject +':'+targetObject);
        //When creating a new object mapping for given source and target objects
        if(sourceObject!=NULL && targetObject!=NULL){
            //==================================Smart_Object==================================//
            if(allSmartObjects.size()>0 && allSmartObjects.containsKey(sourceObject))
                isSourceObjectSmartObject = true;
            if(allSmartObjects.size()>0 && allSmartObjects.containsKey(targetObject))
                isTargetObjectSmartObject = true;
            //================================================================================//
            
            SVMXC__ServiceMax_Processes__c headerDef = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c=sourceObject, SVMXC__Target_Object_Name__c=targetObject);
            objects = getDefaultFieldmapping(sourceObject, sourceFieldProperty, targetObject, targetFieldProperty, blacklistedObjects, whitelistedObjects, prequest, utils);
            ////system.debug('objects'+objects);
            objects.objectMap = headerDef;
        }
        else if(targetObject!=NULL){
            //==================================Smart_Object==================================//
            if(allSmartObjects.size()>0 && allSmartObjects.containsKey(targetObject))
                isTargetObjectSmartObject = true;
            //================================================================================//
            
            SVMXC__ServiceMax_Processes__c headerDef = new SVMXC__ServiceMax_Processes__c(SVMXC__Target_Object_Name__c=targetObject);
            objects = getDefaultFieldmapping(null, null, targetObject, targetFieldProperty, blacklistedObjects, whitelistedObjects, prequest, utils);
            objects.objectMap = headerDef;
        }
        //If user selects a mapping
        else if(request.get('OBJECTMAPNAME')!=NULL || request.get('RECORDID')!=NULL){
            List<SFM_WrapperDef.SFM_FieldMapping> fieldMapping = new List<SFM_WrapperDef.SFM_FieldMapping>();
            list<string> LstObjectMapId = new list<string>();
            list<SVMXC__ServiceMax_Processes__c>    LstObjectMap = new list<SVMXC__ServiceMax_Processes__c>();
            if(request.get('OBJECTMAPNAME')!=NULL)
                
                LstObjectMap = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, Name, Id,SVMXC__Name__c,SVMXC__IsStandard__c  From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Object Mapping' AND SVMXC__MapID__c = :request.get('OBJECTMAPNAME')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            else if(request.get('RECORDID')!=NULL)
                
                LstObjectMap = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, Name, Id,SVMXC__Name__c,SVMXC__IsStandard__c  From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Object Mapping' AND Id = :request.get('RECORDID')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug(LoggingLevel.WARN, 'LstObjectMap'+LstObjectMap.size());
            if(LstObjectMap.size()>0)
            {
                
                DCON_Utils dcUtils = new DCON_Utils();
                String sourceObjectName = LstObjectMap[0].SVMXC__Source_Object_Name__c;
                String targetObjectName = LstObjectMap[0].SVMXC__Target_Object_Name__c;
                
                //==================================Smart_Object==================================//
                if(sourceObjectName != null && allSmartObjects.size()>0 && allSmartObjects.containsKey(sourceObjectName))
                    isSourceObjectSmartObject = true;
                if(targetObjectName != null && allSmartObjects.size()>0 && allSmartObjects.containsKey(targetObjectName))
                    isTargetObjectSmartObject = true;
                //================================================================================//
                
                list<SVMXC__ServiceMax_Config_Data__c> LstField = new list<SVMXC__ServiceMax_Config_Data__c>();
                LstField = [Select SVMXC__Internal_Value__c, SVMXC__Display_Value__c,   SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, Name, Id, SVMXC__Preference_2__c, SVMXC__Preference_3__c, SVMXC__Object_Name2__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c = :LstObjectMap[0].Id and Recordtype.Name='Field Mapping']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(!isTargetObjectSmartObject){ //Smart_Object
                    //Get the original API name of the object
                    Map<String, String> originalAPI = new Map<String, String>();
                    set<String> givenObject = new set<String>();
                    givenObject.add(targetObjectName);
                    originalAPI = utils.getOriginalAPIName(givenObject, allObjs);
                    
                    //Getting the label for all lookup id's
                    Map<String, SObjectField> mapTargetObjFieldMap = allObjs.get(originalAPI.get(targetObjectName)).getDescribe().fields.getMap();
                    DCON_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(mapTargetObjFieldMap, TRUE);
                    if(reference_M.objectNameField_M!= NULL && reference_M.objectNameField_M.size() > 0)
                    {
                        Map<String, String> setObject = reference_M.objectNameField_M;
                        Map<String, String> mapIdVsLabels = new Map<String, String>();
                        set<String> setIds = new set<String>();
                        for(SVMXC__ServiceMax_Config_Data__c fieldMap: LstField){
                            if(fieldMap.SVMXC__Internal_Value__c != NULL)
                                setIds.add(fieldMap.SVMXC__Internal_Value__c);
                        }
                        if(setIds.size() > 0)
                        {
                            mapIdVsLabels = utils.getReferenceLabels(setObject, setIds);
                            if(mapIdVsLabels.size() > 0)
                            for(SVMXC__ServiceMax_Config_Data__c fieldMap: LstField)
                            {
                                if(mapIdVsLabels.get(fieldMap.SVMXC__Internal_Value__c) != NULL)
                                fieldMap.SVMXC__Display_Value__c = mapIdVsLabels.get(fieldMap.SVMXC__Internal_Value__c);
                            }
                        }
                    }
                }
                System.debug(LoggingLevel.WARN, 'LstField11 : '+LstField);
                for(SVMXC__ServiceMax_Config_Data__c fieldMap: LstField){
                    if(fieldMap.SVMXC__Target_Field_Name__c!=NULL)
                    defaultFieldMapping.put(fieldMap.SVMXC__Target_Field_Name__c, fieldMap);
                }
                
                objects = getDefaultFieldmapping(sourceObjectName, sourceFieldProperty, targetObjectName, targetFieldProperty, blacklistedObjects, whitelistedObjects, prequest, utils);
                objects.objectMap = LstObjectMap[0];
            }
            else{
                //throw new SVMXException('No mapping details available for the given map.');
                throw new SVMXException(system.label.SFM001_TAG171);
            }
        }
        resObjects.add(objects);
        SFM_WrapperDef.SFM_Response_ObjectMap resp = new SFM_WrapperDef.SFM_Response_ObjectMap(resObjects);
        resp.response.success = true;
        resp.response.logMsg=log.getlog();
        return resp;
    }
    
    public SFM_WrapperDef.SFM_ObjectMap getDefaultFieldmapping(String sourceObjectName, List<String> sourceFieldProperty, String targetObjectName, List<String> targetFieldProperty, set<String> blacklistedObjects, set<String> whitelistedObjects, SFM_WrapperDef.SFM_Request prequest, SFM_Utils utils){
        ///Addde by Amar
        map<String,String> requestMap = new map<String,String>();
        requestMap = utils.getStringMap(prequest.stringMap);
        Boolean isPicklistDescribe = false;
        String strPicklistDesc = '';
        if(requestMap.containskey('DOPICKLISTDESCRIBE')){
            strPicklistDesc = requestMap.get('DOPICKLISTDESCRIBE');
            if(strPicklistDesc == 'TRUE'){
                isPicklistDescribe = true;
            }
        }

        //-------Added for fixing defect 043150-------Start----------//
        Integer batchSeq = 0;
        Integer strTotalBatchSize = 0;
        if(requestMap.containskey('BATCHSEQUENCE') && requestMap.get('BATCHSEQUENCE') != null){
            batchSeq = Integer.valueOf(requestMap.get('BATCHSEQUENCE'));
        }

        //Fetching setting value
        COMM_Utils_ManageSettings objSetting = new COMM_Utils_ManageSettings();
        String settingValue = objSetting.SVMX_getGlobalSettingList('SFM001_SET005');
        Integer batchSize;
        if(!String.isBlank(settingValue)){
            batchSize = Integer.valueOf(settingValue);
        }
        else{
            batchSeq = 0;
        }
        System.debug('batchSeq: '+batchSeq);
        System.debug('batchSize: '+batchSize);
        //-------Added for fixing defect 043150-------End------------//

        ////system.debug('entered1.1');
        //Declarations
        Map<String, Schema.SObjectField> sourceFieldMap = new Map<String, Schema.SObjectField>(); //BAC-4094
        Map<String, Schema.SObjectField> targetFieldMap = new Map<String, Schema.SObjectField>(); //BAC-4094
        //Map<String, Schema.SObjectField> sourceFieldMap; //commented for BAC-4094
        //Map<String, Schema.SObjectField> targetFieldMap; //commented for BAC-4094
        Map<string,string> sourceFieldNames = new Map<string,string>();
        Map<String, Schema.DescribeFieldResult> sourceFieldDescMap = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.DescribeFieldResult> targetFieldDescMap = new Map<String, Schema.DescribeFieldResult>();
        Map<string,string> targetFieldNames = new Map<string,string>();
        
        //==================================Smart_Object==================================//
        Map<String, SmartObject.SmartObjectField> sourceFieldMapSmart;
        Map<String, SmartObject.SmartObjectField> targetFieldMapSmart;
        Map<string,string> sourceFieldNamesSmart = new Map<string,string>();
        Map<String, SmartObject.DescribeSmartFieldResult> sourceFieldDescMapSmart = new Map<String, SmartObject.DescribeSmartFieldResult>();
        Map<String, SmartObject.DescribeSmartFieldResult> targetFieldDescMapSmart = new Map<String, SmartObject.DescribeSmartFieldResult>();
        Map<string,string> targetFieldNamesSmart = new Map<string,string>();
        //================================================================================//
        
        boolean gettingFromMap = false;
        if(defaultFieldMapping.size()>0){
            gettingFromMap = true;
        }
        String strLogger = '';
        
        //Source & target object got from request and their real api names
        String srcObjname=sourceObjectName;
        String MaintargetObjectName=targetObjectName;

        Map<String, String> originalAPI = new Map<String, String>();
        set<String> givenObject = new set<String>();
        if(!isSourceObjectSmartObject)
            givenObject.add(sourceObjectName);
        if(!isTargetObjectSmartObject)
            givenObject.add(targetObjectName);
        if(givenObject.size()>0)
            originalAPI = utils.getOriginalAPIName(givenObject, allObjs);
        
        //Api Names
        if(!isSourceObjectSmartObject)
            sourceObjectName = originalAPI.get(sourceObjectName);           
        if(!isTargetObjectSmartObject)
            targetObjectName = originalAPI.get(targetObjectName);
        
        //Describe of source
        schema.DescribeSObjectResult sourceObject;
        SmartObject.DescribeSmartObjectResult sourceSmartObject;
        if(isSourceObjectSmartObject){
            if(sourceObjectName!=NULL)
                sourceSmartObject = allSmartObjects.get(sourceObjectName);
        }
        else{
            if(sourceObjectName!=NULL)
                sourceObject = allObjs.get(sourceObjectName).getDescribe();
        }
        
        //Describe of Target
        Schema.DescribeSObjectResult targetObject;
        SmartObject.DescribeSmartObjectResult targetSmartObject;
        if(isTargetObjectSmartObject){
            if(targetObjectName!=NULL)
                targetSmartObject = allSmartObjects.get(targetObjectName);
        }
        else{
            if(targetObjectName!=NULL)
                targetObject = allObjs.get(targetObjectName).getDescribe();
        }
        
        //Field Map of Source and Target Object
        if(isSourceObjectSmartObject && sourceObjectName != NULL){
            sourceFieldMapSmart = sourceSmartObject.getFieldMap();
        }
        else{
            if(sourceObjectName != NULL && (sourceObject.isAccessible() == true && sourceObject.isCreateable() == true)){
                sourceFieldMap = sourceObject.fields.getMap();
                
                //-----Start------Added for the task BAC-4401 and defect 043715
              COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
              sourceFieldMap = objCOMM_UtilV2.removeDuplicateFields(sourceFieldMap);
              //-----End--------Added for the task BAC-4401 and defect 043715
            }
        }
        
        if(isTargetObjectSmartObject && targetObjectName != NULL){
            targetFieldMapSmart = targetSmartObject.getFieldMap();
        }
        else{
            if(targetObjectName != NULL && (targetObject.isAccessible() == true && targetObject.isCreateable() == true)){
                targetFieldMap = targetObject.fields.getMap();
                
                //-----Start------Added for the task BAC-4401 and defect 043715
              COMM_Utils_V2 objCOMM_UtilV2 = new COMM_Utils_V2();
              targetFieldMap = objCOMM_UtilV2.removeDuplicateFields(targetFieldMap);
              //-----End--------Added for the task BAC-4401 and defect 043715
            }
        }
        
        //Populate Map of Source <Field Name, Field Describe> and Target <Field Name, Field Describe>
        if(isSourceObjectSmartObject){
            if(sourceObjectName != NULL){
                for(String fieldAPI: sourceFieldMapSmart.keySet())
                {
                    SmartObject.SmartObjectField sourceField = sourceFieldMapSmart.get(fieldAPI); 
                    SmartObject.DescribeSmartFieldResult sourceFieldDesc = sourceField.getDescribe();
                    sourceFieldDescMapSmart.put(fieldAPI, sourceFieldDesc);
                    sourceFieldNamesSmart.put(fieldAPI,sourceFieldDesc.getLabel());
                }
            }
        }
        else{
            if(sourceObjectName != NULL){
                for(String fieldAPI: sourceFieldMap.keySet())
                {
                    //if(fieldAPI != 'CurrencyIsoCode') Commented for the defect 024301 fix- Enabling CurrencyIsoCode field in mapping
                    //{
                        Schema.SObjectField sourceField = sourceFieldMap.get(fieldAPI); 
                        Schema.DescribeFieldResult sourceFieldDesc = sourceField.getDescribe();
                        if(utils.checkFieldAccessPermission(sourceFieldDesc, sourceFieldProperty))
                        {
                            sourceFieldDescMap.put(fieldAPI, sourceFieldDesc);
                            sourceFieldNames.put(fieldAPI,sourceFieldDesc.getLabel());
                        }
                    //}
                }
            }
        }
        if(isTargetObjectSmartObject){
            if(targetObjectName != NULL){
                for(String fieldAPI: targetFieldMapSmart.keySet())
                {
                    SmartObject.SmartObjectField targetField = targetFieldMapSmart.get(fieldAPI); 
                    SmartObject.DescribeSmartFieldResult targetFieldDesc = targetField.getDescribe();
                    targetFieldDescMapSmart.put(fieldAPI, targetFieldDesc);
                    targetFieldNamesSmart.put(fieldAPI,targetFieldDesc.getLabel());
                }
            }
        }
        else{
            if(targetObjectName != NULL){
                //-------Added for fixing defect 043150-------Start----------//
                Integer startNumber = 0;
                Integer endNumber = targetFieldMap.size();
                if(batchSeq > 0 && batchSize != null && batchSize > 0){
                    Integer intRecordListSize = batchSize;
                    strTotalBatchSize = (targetFieldMap.size()) / intRecordListSize;
                    if(math.mod(targetFieldMap.size(), intRecordListSize) != 0){
                        strTotalBatchSize++;
                    }
                    System.debug('strTotalBatchSize: '+strTotalBatchSize);

                    startNumber = (batchSeq - 1) * intRecordListSize;
                    endNumber = (endNumber < (startNumber + intRecordListSize)) ? endNumber : (startNumber + intRecordListSize);
                }
                System.debug('startNumber: '+startNumber);
                System.debug('endNumber: '+endNumber);
                //-------Added for fixing defect 043150-------End------------//

                Integer counter = 0;
                for(String fieldAPI: targetFieldMap.keySet())
                {
                    //if(fieldAPI != 'CurrencyIsoCode') Commented for the defect 024301 fix- Enabling CurrencyIsoCode field in mapping
                    //{
                    if(counter >= startNumber && counter < endNumber){ //Condition added for fixing defect 043150
                        Schema.SObjectField targetField = targetFieldMap.get(fieldAPI); 
                        Schema.DescribeFieldResult targetFieldDesc = targetField.getDescribe();
                        if(utils.checkFieldAccessPermission(targetFieldDesc, targetFieldProperty))
                        {
                            targetFieldDescMap.put(fieldAPI, targetFieldDesc);
                            targetFieldNames.put(fieldAPI,targetFieldDesc.getLabel());
                        }
                    }
                    counter++; //Added for fixing defect 043150
                    //}
                }
            }
        }
        //if(!isTargetObjectSmartObject) //Commented for the defect 043150 fix 
        if(!isTargetObjectSmartObject && (batchSeq == 0 || (batchSeq == strTotalBatchSize))) //Added for the defect 043150 fix 
            targetFieldDescMap.put('Id',targetFieldMap.get('Id').getdescribe());
            
        System.debug(LoggingLevel.WARN, 'targetFieldDescMapSmart11 : '+targetFieldDescMapSmart);
        System.debug(LoggingLevel.WARN, 'targetFieldNamesSmart11 : '+targetFieldNamesSmart);
        System.debug(LoggingLevel.WARN, 'targetFieldDescMap11 : '+targetFieldDescMap);
        System.debug(LoggingLevel.WARN, 'targetFieldNames11 : '+targetFieldNames);
        
        //Build the Map <Type,List<FieldName String Map(sourecFieldAPI)>> , Map <Type, Map<FieldApiName, Fld Describe>>
        Map<String, Map<String, Schema.DescribeFieldResult>> MapType_MapApiNameFldDescribe_source = new Map<String, Map<String, Schema.DescribeFieldResult>>();
        Map<String, List<SFM_WrapperDef.SFM_StringMap>> MapTypeListSrcFlds_Source = new Map<String, List<SFM_WrapperDef.SFM_StringMap>>();
        List<SFM_WrapperDef.SFM_StringMap> AllReferenceFields_Source = new List<SFM_WrapperDef.SFM_StringMap>();
        Map<Integer,List<SFM_WrapperDef.SFM_StringMap>> MapDouble_FldLst = new Map<Integer,List<SFM_WrapperDef.SFM_StringMap>>();
        Map<Integer,List<SFM_WrapperDef.SFM_StringMap>> MapInteger_FldLst = new Map<Integer,List<SFM_WrapperDef.SFM_StringMap>>();
        Map<Integer,List<SFM_WrapperDef.SFM_StringMap>> MapCurrency_FldLst = new Map<Integer,List<SFM_WrapperDef.SFM_StringMap>>();
        Map<Integer,List<SFM_WrapperDef.SFM_StringMap>> MapPercent_FldLst = new Map<Integer,List<SFM_WrapperDef.SFM_StringMap>>();
        Map<Integer,List<SFM_WrapperDef.SFM_StringMap>> MapNew_Double_FldLst = new Map<Integer,List<SFM_WrapperDef.SFM_StringMap>>();
        Map<Integer,List<SFM_WrapperDef.SFM_StringMap>> MapNew_Integer_FldLst = new Map<Integer,List<SFM_WrapperDef.SFM_StringMap>>();
        Map<Integer,List<SFM_WrapperDef.SFM_StringMap>> MapNew_Currency_FldLst = new Map<Integer,List<SFM_WrapperDef.SFM_StringMap>>();
        Map<Integer,List<SFM_WrapperDef.SFM_StringMap>> MapNew_PERCENT_FldLst = new Map<Integer,List<SFM_WrapperDef.SFM_StringMap>>();
        Set<Integer> SetTarget_Double_FldLst = new Set<Integer>();
        Set<Integer> SetTarget_Integer_FldLst = new Set<Integer>();
        Set<Integer> SetTarget_Currency_FldLst = new Set<Integer>();
        Set<Integer> SetTarget_Percent_FldLst = new Set<Integer>();

        for(String sourecFieldAPI: sourceFieldDescMap.keySet())
        {
            String fldType;
            Map<String, Schema.DescribeFieldResult> MapApiNameFldDescribe = new Map<String, Schema.DescribeFieldResult>();
            List<SFM_WrapperDef.SFM_StringMap> TempFldsLst = new List<SFM_WrapperDef.SFM_StringMap>();
            if(String.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getType()).equalsIgnoreCase('REFERENCE'))
                fldType = 'Reference_' + sourceFieldDescMap.get(sourecFieldAPI).getReferenceTo()[0].getDescribe().getName();
            else if((String.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getType())).equalsIgnoreCase('TEXTAREA') && sourceFieldDescMap.get(sourecFieldAPI).isHtmlFormatted())
                fldType = String.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getType()) + '_HTML';
            else
                fldType = String.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getType());
            if(MapType_MapApiNameFldDescribe_source.containsKey(fldType) && MapTypeListSrcFlds_Source.containsKey(fldType))
            {
                MapApiNameFldDescribe.putAll(MapType_MapApiNameFldDescribe_source.get(fldType));
                TempFldsLst.addAll(MapTypeListSrcFlds_Source.get(fldType));
            }
            Schema.DescribeFieldResult SourceFieldDesc = sourceFieldDescMap.get(sourecFieldAPI);
            String fieldAPI = SourceFieldDesc.getName();
            String UpdatedSourceFieldName;// = fieldAPI;//sourecFieldAPI;//we update this field as in case of reference we make it id when field is lookup to srcobject
            MapApiNameFldDescribe.put(fieldAPI, sourceFieldDescMap.get(fieldAPI));//MapApiNameFldDescribe.put(sourecFieldAPI, sourceFieldDescMap.get(sourecFieldAPI));
            //String fieldAPI = SourceFieldDesc.getName();
            if(fldType.startswith('Reference_'))
            {
                AllReferenceFields_Source.add(new SFM_WrapperDef.SFM_StringMap(fieldAPI,null)); //Add all reference field to a set, it is later put in String type fields
            }
            TempFldsLst.add(new SFM_WrapperDef.SFM_StringMap(fieldAPI,null));
            MapType_MapApiNameFldDescribe_source.put(fldType,MapApiNameFldDescribe);
            MapTypeListSrcFlds_Source.put(fldType,TempFldsLst);
            //length logic is put here
            if(fldType.equalsIgnoreCase('INTEGER') || fldType.equalsIgnoreCase('DOUBLE') || fldType.equalsIgnoreCase('CURRENCY') )
            {
                List<SFM_WrapperDef.SFM_StringMap> tempListOfFields = new List<SFM_WrapperDef.SFM_StringMap>();
                if(MapDouble_FldLst.containskey(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength())))
                    tempListOfFields.addAll(MapDouble_FldLst.get(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength())));
                tempListOfFields.add(new SFM_WrapperDef.SFM_StringMap(fieldAPI,null));
                MapDouble_FldLst.put(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength()), tempListOfFields);
                if(fldType.equalsIgnoreCase('INTEGER') || fldType.equalsIgnoreCase('CURRENCY') || fldType.equalsIgnoreCase('PERCENT'))
                {
                    List<SFM_WrapperDef.SFM_StringMap> tempListOfFieldsINT = new List<SFM_WrapperDef.SFM_StringMap>();
                    if(MapInteger_FldLst.containskey(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength())))
                        tempListOfFieldsINT.addAll(MapInteger_FldLst.get(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength())));
                    tempListOfFieldsINT.add(new SFM_WrapperDef.SFM_StringMap(fieldAPI,null));
                    MapInteger_FldLst.put(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength()), tempListOfFieldsINT);

                    //currency logic
                    if(!fldType.equalsIgnoreCase('PERCENT'))
                    {
                        List<SFM_WrapperDef.SFM_StringMap> tempListOfFieldsCURR = new List<SFM_WrapperDef.SFM_StringMap>();
                        if(MapCurrency_FldLst.containskey(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength())))
                            tempListOfFieldsCURR.addAll(MapCurrency_FldLst.get(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength())));
                        tempListOfFieldsCURR.add(new SFM_WrapperDef.SFM_StringMap(fieldAPI,null));
                        MapCurrency_FldLst.put(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength()), tempListOfFieldsCURR);
                    }//percent logic
                    else if(!fldType.equalsIgnoreCase('CURRENCY'))
                    {
                        List<SFM_WrapperDef.SFM_StringMap> tempListOfFieldsPercnt = new List<SFM_WrapperDef.SFM_StringMap>();
                        if(MapPercent_FldLst.containskey(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength())))
                            tempListOfFieldsPercnt.addAll(MapPercent_FldLst.get(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength())));
                        tempListOfFieldsPercnt.add(new SFM_WrapperDef.SFM_StringMap(fieldAPI,null));
                        MapPercent_FldLst.put(Integer.valueOf(sourceFieldDescMap.get(sourecFieldAPI).getlength()), tempListOfFieldsPercnt);
                    }
                }
            }
            //////system.debug('entered1.0'+ sourecFieldAPI + ':'+fldType);
            
        }
        
        //==================================Smart_Object==================================//
        Map<String, Map<String, SmartObject.DescribeSmartFieldResult>> MapType_MapApiNameFldDescribe_sourceSmart = new Map<String, Map<String, SmartObject.DescribeSmartFieldResult>>();
        System.debug(LoggingLevel.WARN, 'sourceFieldDescMapSmart11 : '+sourceFieldDescMapSmart);
        for(String sourecFieldAPI: sourceFieldDescMapSmart.keySet())
        {
            String fldType;
            Map<String, SmartObject.DescribeSmartFieldResult> MapApiNameFldDescribe = new Map<String, SmartObject.DescribeSmartFieldResult>();
            List<SFM_WrapperDef.SFM_StringMap> TempFldsLst = new List<SFM_WrapperDef.SFM_StringMap>();
            fldType = String.valueOf(sourceFieldDescMapSmart.get(sourecFieldAPI).getType());
            if(MapType_MapApiNameFldDescribe_sourceSmart.containsKey(fldType) && MapTypeListSrcFlds_Source.containsKey(fldType))
            {
                MapApiNameFldDescribe.putAll(MapType_MapApiNameFldDescribe_sourceSmart.get(fldType));
                TempFldsLst.addAll(MapTypeListSrcFlds_Source.get(fldType));
            }
            SmartObject.DescribeSmartFieldResult SourceFieldDesc = sourceFieldDescMapSmart.get(sourecFieldAPI);
            String fieldAPI = SourceFieldDesc.getName();
            MapApiNameFldDescribe.put(fieldAPI, sourceFieldDescMapSmart.get(fieldAPI));
            TempFldsLst.add(new SFM_WrapperDef.SFM_StringMap(fieldAPI,null));
            MapType_MapApiNameFldDescribe_sourceSmart.put(fldType,MapApiNameFldDescribe);
            MapTypeListSrcFlds_Source.put(fldType,TempFldsLst);
            
            //length logic is put here
            if(fldType.contains('INTEGER') || fldType.contains('DOUBLE'))
            {
                List<SFM_WrapperDef.SFM_StringMap> tempListOfFields = new List<SFM_WrapperDef.SFM_StringMap>();
                if(MapDouble_FldLst.containskey(Integer.valueOf(sourceFieldDescMapSmart.get(sourecFieldAPI).getlength())))
                    tempListOfFields.addAll(MapDouble_FldLst.get(Integer.valueOf(sourceFieldDescMapSmart.get(sourecFieldAPI).getlength())));
                tempListOfFields.add(new SFM_WrapperDef.SFM_StringMap(fieldAPI,null));
                MapDouble_FldLst.put(Integer.valueOf(sourceFieldDescMapSmart.get(sourecFieldAPI).getlength()), tempListOfFields);
                if(fldType.contains('INTEGER'))
                {
                    List<SFM_WrapperDef.SFM_StringMap> tempListOfFieldsINT = new List<SFM_WrapperDef.SFM_StringMap>();
                    if(MapInteger_FldLst.containskey(Integer.valueOf(sourceFieldDescMapSmart.get(sourecFieldAPI).getlength())))
                        tempListOfFieldsINT.addAll(MapInteger_FldLst.get(Integer.valueOf(sourceFieldDescMapSmart.get(sourecFieldAPI).getlength())));
                    tempListOfFieldsINT.add(new SFM_WrapperDef.SFM_StringMap(fieldAPI,null));
                    MapInteger_FldLst.put(Integer.valueOf(sourceFieldDescMapSmart.get(sourecFieldAPI).getlength()), tempListOfFieldsINT);
                }
            }
        }
        System.debug(LoggingLevel.WARN, 'MapTypeListSrcFlds_Source11 : '+MapTypeListSrcFlds_Source);
        System.debug(LoggingLevel.WARN, 'MapDouble_FldLst11 : '+MapDouble_FldLst);
        System.debug(LoggingLevel.WARN, 'MapInteger_FldLst11 : '+MapInteger_FldLst);
        //================================================================================//

        //map of constant type and its related value
        Map<String, List<SFM_WrapperDef.SFM_StringMap>> MapType_ListOfConstants = new Map<String, List<SFM_WrapperDef.SFM_StringMap>>();
        //build the constatnts here
        SVMX_Constants constant = new SVMX_Constants();
        String orgConstant = 'SVMXCONSTANT';
        List<SFM_WrapperDef.SFM_StringMap> options;
        
        //Boolean - Constant
        options = new List<SFM_WrapperDef.SFM_StringMap>();
        options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,'True'));
        options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,'False'));
       
        MapType_ListOfConstants.put('BOOLEAN',options);
       
        
        //DATE - Constant
        options = new List<SFM_WrapperDef.SFM_StringMap>();
        Map<String, String> dateValues = new Map<String, String>();
        dateValues = constant.getDateOptions();
        for(String dateValue: dateValues.keySet()){
            options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,dateValues.get(dateValue)));
        }
        
        MapType_ListOfConstants.put('DATE',options);
        //Added for BAC-4676
        //NUMBER - Constant
        options = new List<SFM_WrapperDef.SFM_StringMap>();
        Map<String, String> geoLocationValues = new Map<String, String>();
        geoLocationValues = constant.geolocationOptions();
        for(String geoValue: geoLocationValues.keySet()){
            options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,geoLocationValues.get(geoValue)));
        }
        
        MapType_ListOfConstants.put('DOUBLE',options);
        //End Added for BAC-4676
        //DATETIME - Constant
        options = new List<SFM_WrapperDef.SFM_StringMap>();
        Map<String, String> dateTimeValues = new Map<String, String>();
        dateTimeValues = constant.getDateTimeOptions();
        for(String dateValue:dateTimeValues.keySet()){
            options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,dateTimeValues.get(dateValue)));
        }
        
        MapType_ListOfConstants.put('DATETIME',options);
        
        //User Constants
         options = new List<SFM_WrapperDef.SFM_StringMap>();
        Map<String, String> mapUserConst = new Map<String, String>();
        mapUserConst = constant.getUserOptions();
        for(String SVMXconst:dateTimeValues.keySet()){
            options.add(new SFM_WrapperDef.SFM_StringMap(orgConstant,mapUserConst.get(SVMXconst)));
        }
        MapType_ListOfConstants.put('USER',options);
        System.debug(LoggingLevel.WARN, 'MapType_ListOfConstants11 : '+MapType_ListOfConstants);
        
        
        ////system.debug('entered1.4'+MapType_ListOfConstants);
        //target map<type, Map<apiname,describefieldResult>>
        Map<String, Map<String, Schema.DescribeFieldResult>> MapType_MapApiNameFldDescribe_Target = new Map<String, Map<String, Schema.DescribeFieldResult>>();
        Map<String,List<SFM_WrapperDef.SFM_StringMap>> MapTypeListTargetFlds_Target = new Map<String,List<SFM_WrapperDef.SFM_StringMap>>();
        
        List<RecordType> recTypes = [SELECT Id, Name, SobjectType  FROM RecordType where SobjectType = :MaintargetObjectName and isActive = true]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(String TargetFieldAPI: targetFieldDescMap.keySet())
        {
            String fldType;
            Map<String, Schema.DescribeFieldResult> MapApiNameFldDescribe = new Map<String, Schema.DescribeFieldResult>();
            List<SFM_WrapperDef.SFM_StringMap> TempFldsLst = new List<SFM_WrapperDef.SFM_StringMap>();
            if(String.valueOf(targetFieldDescMap.get(TargetFieldAPI).getType()).equalsIgnoreCase('REFERENCE'))
                fldType = 'Reference_' + targetFieldDescMap.get(TargetFieldAPI).getReferenceTo()[0].getDescribe().getName();
            else if((String.valueOf(targetFieldDescMap.get(TargetFieldAPI).getType())).equalsIgnoreCase('TEXTAREA') && targetFieldDescMap.get(TargetFieldAPI).isHtmlFormatted())
                fldType = String.valueOf(targetFieldDescMap.get(TargetFieldAPI).getType()) + '_HTML';
            else
                fldType = String.valueOf(targetFieldDescMap.get(TargetFieldAPI).getType());
            
            if(fldType.equalsIgnoreCase('INTEGER') || fldType.equalsIgnoreCase('DOUBLE') || fldType.equalsIgnoreCase('CURRENCY') || fldType.equalsIgnoreCase('PERCENT'))
            {
                SetTarget_Double_FldLst.add(Integer.valueOf(targetFieldDescMap.get(TargetFieldAPI).getlength()));
                if(fldType.equalsIgnoreCase('INTEGER') || fldType.equalsIgnoreCase('CURRENCY') || fldType.equalsIgnoreCase('PERCENT'))
                {
                    //integer
                    SetTarget_Integer_FldLst.add(Integer.valueOf(targetFieldDescMap.get(TargetFieldAPI).getlength()));//todo
                    //currency
                    if(!fldType.equalsIgnoreCase('PERCENT'))
                        SetTarget_Currency_FldLst.add(Integer.valueOf(targetFieldDescMap.get(TargetFieldAPI).getlength()));//todo
                    //percent
                    if(!fldType.equalsIgnoreCase('CURRENCY'))
                        SetTarget_Percent_FldLst.add(Integer.valueOf(targetFieldDescMap.get(TargetFieldAPI).getlength()));
                    
                }
            }
            if(String.valueOf(targetFieldDescMap.get(TargetFieldAPI).getType()).equalsIgnoreCase('PICKLIST'))
            {
                if(isPicklistDescribe){
                    String ModifiedfldType = 'Picklist_' + TargetFieldAPI;
                    List<SFM_WrapperDef.SFM_StringMap> PicklistOptions = new List<SFM_WrapperDef.SFM_StringMap>();
                    for(Schema.PicklistEntry entry: targetFieldDescMap.get(TargetFieldAPI).getPicklistValues())
                    {
                        PicklistOptions.add(new SFM_WrapperDef.SFM_StringMap('SVMXCONSTANT',entry.getValue()+'~'+entry.getLabel()));//+'~'+entry.getLabel()
                    }
                    MapType_ListOfConstants.put(ModifiedfldType,PicklistOptions);
                }        
            }
            else if( fldType == 'Reference_RecordType' )
            {
                List<SFM_WrapperDef.SFM_StringMap> RecordTypeValues = new List<SFM_WrapperDef.SFM_StringMap>();
                
                for(RecordType rec: recTypes)
                {
                    RecordTypeValues.add(new SFM_WrapperDef.SFM_StringMap('SVMXCONSTANT',rec.Name));
                }
                MapType_ListOfConstants.put(fldType,RecordTypeValues);
                ////system.debug('enteredrecordtype:'+fldType + ':'+RecordTypeValues);
            }
            if(MapType_MapApiNameFldDescribe_Target.containsKey(fldType) && MapTypeListTargetFlds_Target.containsKey(fldType))
            {
                MapApiNameFldDescribe.putAll(MapType_MapApiNameFldDescribe_Target.get(fldType));
                TempFldsLst.addAll(MapTypeListTargetFlds_Target.get(fldType));
            }
            MapApiNameFldDescribe.put(TargetFieldAPI, targetFieldDescMap.get(TargetFieldAPI));
            String UpdatedTargetFieldName = TargetFieldAPI;//we update this field as in case of reference we make it id when field is lookup to srcobject
            TempFldsLst.add(new SFM_WrapperDef.SFM_StringMap(TargetFieldAPI,null));
            MapType_MapApiNameFldDescribe_Target.put(fldType,MapApiNameFldDescribe);
            MapTypeListTargetFlds_Target.put(fldType,TempFldsLst);
        }
        
        //==================================Smart_Object==================================//
        Map<String, Map<String, SmartObject.DescribeSmartFieldResult>> MapType_MapApiNameFldDescribe_TargetSmart = new Map<String, Map<String, SmartObject.DescribeSmartFieldResult>>();
        for(String TargetFieldAPI: targetFieldDescMapSmart.keySet())
        {
            String fldType;
            Map<String, SmartObject.DescribeSmartFieldResult> MapApiNameFldDescribe = new Map<String, SmartObject.DescribeSmartFieldResult>();
            List<SFM_WrapperDef.SFM_StringMap> TempFldsLst = new List<SFM_WrapperDef.SFM_StringMap>();
            fldType = String.valueOf(targetFieldDescMapSmart.get(TargetFieldAPI).getType());
            
            if(fldType.contains('INTEGER') || fldType.contains('DOUBLE'))
            {
                SetTarget_Double_FldLst.add(Integer.valueOf(targetFieldDescMapSmart.get(TargetFieldAPI).getlength()));
                if(fldType.contains('INTEGER'))
                    SetTarget_Integer_FldLst.add(Integer.valueOf(targetFieldDescMapSmart.get(TargetFieldAPI).getlength()));//for integer
            }
            if(MapType_MapApiNameFldDescribe_TargetSmart.containsKey(fldType) && MapTypeListTargetFlds_Target.containsKey(fldType))
            {
                MapApiNameFldDescribe.putAll(MapType_MapApiNameFldDescribe_TargetSmart.get(fldType));
                TempFldsLst.addAll(MapTypeListTargetFlds_Target.get(fldType));
            }
            MapApiNameFldDescribe.put(TargetFieldAPI, targetFieldDescMapSmart.get(TargetFieldAPI));
            TempFldsLst.add(new SFM_WrapperDef.SFM_StringMap(TargetFieldAPI,null));
            MapType_MapApiNameFldDescribe_TargetSmart.put(fldType,MapApiNameFldDescribe);
            MapTypeListTargetFlds_Target.put(fldType,TempFldsLst);
        }
        //================================================================================//        
        
        if(MapTypeListTargetFlds_Target.containskey('Reference_'+sourceObjectName) || MapTypeListTargetFlds_Target.containskey('Reference_'+srcObjname))
        {
        ////system.debug('entered0001'+ MapTypeListTargetFlds_Target.containskey('Reference_'+sourceObjectName));
        ////system.debug('entered0002'+ MapTypeListTargetFlds_Target.containskey('Reference_'+srcObjname));
            if(MapTypeListSrcFlds_Source.containskey('Reference_'+sourceObjectName))
            {
                ////system.debug('entered0003'+ MapTypeListSrcFlds_Source.get('Reference_'+sourceObjectName));
                List<SFM_WrapperDef.SFM_StringMap> TempList = new List<SFM_WrapperDef.SFM_StringMap>();
                TempList.add(new SFM_WrapperDef.SFM_StringMap('Id',null));
                if(MapTypeListSrcFlds_Source.get('Reference_'+sourceObjectName) == null)
                    MapTypeListSrcFlds_Source.put('Reference_'+sourceObjectName,TempList);
                else
                    (MapTypeListSrcFlds_Source.get('Reference_'+sourceObjectName)).add(new SFM_WrapperDef.SFM_StringMap('Id',null));
                (MapType_MapApiNameFldDescribe_source.get('Reference_'+sourceObjectName)).put('Id',sourceFieldMap.get('Id').getDescribe());
            }
            else if(MapTypeListSrcFlds_Source.containskey('Reference_'+srcObjname))
            {
                ////system.debug('entered0004'+ MapTypeListSrcFlds_Source.get('Reference_'+srcObjname));
                List<SFM_WrapperDef.SFM_StringMap> TempList = new List<SFM_WrapperDef.SFM_StringMap>();
                TempList.add(new SFM_WrapperDef.SFM_StringMap('Id',null));
                if(MapTypeListSrcFlds_Source.get('Reference_'+srcObjname) ==null)
                    MapTypeListSrcFlds_Source.put('Reference_'+srcObjname,TempList);
                else
                    (MapTypeListSrcFlds_Source.get('Reference_'+srcObjname)).add(new SFM_WrapperDef.SFM_StringMap('Id',null));
                (MapType_MapApiNameFldDescribe_source.get('Reference_'+srcObjname)).put('Id',sourceFieldMap.get('Id').getDescribe());
            }
            else
            {
                List<SFM_WrapperDef.SFM_StringMap> TempList = new List<SFM_WrapperDef.SFM_StringMap>();
                TempList.add(new SFM_WrapperDef.SFM_StringMap('Id',null));
                MapTypeListSrcFlds_Source.put('Reference_'+srcObjname,TempList);
                Map<String, Schema.DescribeFieldResult> TempMapFld_FldDescribe = new Map<String, Schema.DescribeFieldResult>();
                TempMapFld_FldDescribe.put('Id',sourceFieldMap.get('Id').getDescribe());
                MapType_MapApiNameFldDescribe_source.put('Reference_'+srcObjname,TempMapFld_FldDescribe);
            }
        }
        //Double
        for(Integer LengthVal1:SetTarget_Double_FldLst)
        {
            for(Integer LengthVal2:MapDouble_FldLst.keyset())
            {
                if(LengthVal2 < LengthVal1)
                {
                    List<SFM_WrapperDef.SFM_StringMap> TempListFieldsCorrespondingLength = new List<SFM_WrapperDef.SFM_StringMap>();
                    if(MapNew_Double_FldLst.containskey(LengthVal1))
                        TempListFieldsCorrespondingLength.addAll(MapNew_Double_FldLst.get(LengthVal1));
                    TempListFieldsCorrespondingLength.addAll(MapDouble_FldLst.get(LengthVal2));
                    MapNew_Double_FldLst.put(LengthVal1,TempListFieldsCorrespondingLength);
                }
            }
        }
        //Integer
        for(Integer LengthVal1:SetTarget_Integer_FldLst)
        {
            for(Integer LengthVal2:MapInteger_FldLst.keyset())
            {
                if(LengthVal2 < LengthVal1)
                {
                    List<SFM_WrapperDef.SFM_StringMap> TempListFieldsCorrespondingLength = new List<SFM_WrapperDef.SFM_StringMap>();
                    if(MapNew_Integer_FldLst.containskey(LengthVal1))
                        TempListFieldsCorrespondingLength.addAll(MapNew_Integer_FldLst.get(LengthVal1));
                    TempListFieldsCorrespondingLength.addAll(MapInteger_FldLst.get(LengthVal2));
                    MapNew_Integer_FldLst.put(LengthVal1,TempListFieldsCorrespondingLength);
                }
            }
        }
        //Currency
        for(Integer LengthVal1:SetTarget_Currency_FldLst)
        {
            for(Integer LengthVal2:MapCurrency_FldLst.keyset())
            {
                if(LengthVal2 < LengthVal1)
                {
                    List<SFM_WrapperDef.SFM_StringMap> TempListFieldsCorrespondingLength = new List<SFM_WrapperDef.SFM_StringMap>();
                    if(MapNew_Currency_FldLst.containskey(LengthVal1))
                        TempListFieldsCorrespondingLength.addAll(MapNew_Currency_FldLst.get(LengthVal1));
                    TempListFieldsCorrespondingLength.addAll(MapCurrency_FldLst.get(LengthVal2));
                    MapNew_Currency_FldLst.put(LengthVal1,TempListFieldsCorrespondingLength);
                }
            }
        }
        //Percent
        for(Integer LengthVal1:SetTarget_Percent_FldLst)
        {
            for(Integer LengthVal2:MapPercent_FldLst.keyset())
            {
                if(LengthVal2 < LengthVal1)
                {
                    List<SFM_WrapperDef.SFM_StringMap> TempListFieldsCorrespondingLength = new List<SFM_WrapperDef.SFM_StringMap>();
                    if(MapNew_PERCENT_FldLst.containskey(LengthVal1))
                        TempListFieldsCorrespondingLength.addAll(MapNew_PERCENT_FldLst.get(LengthVal1));
                    TempListFieldsCorrespondingLength.addAll(MapPercent_FldLst.get(LengthVal2));
                    MapNew_PERCENT_FldLst.put(LengthVal1,TempListFieldsCorrespondingLength);
                }
            }
        }

        //new addition to get corresponding other datatypes into respective fields.
        //New Type Map
        Map<String,List<SFM_WrapperDef.SFM_StringMap>> New_MapTypeListTargetFlds_Source = new Map<String,List<SFM_WrapperDef.SFM_StringMap>>();
        List<SFM_WrapperDef.SFM_StringMap> TempStrngMap_Integer_Schema = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> TempStrngMap_Double_Schema = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> TempStrngMap_Currency_Schema = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> TempStrngMap_Date_Schema = new List<SFM_WrapperDef.SFM_StringMap>();//Done
        List<SFM_WrapperDef.SFM_StringMap> TempStrngMap_String_Schema = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> TempStrngMap_HTMLTextArea_Schema = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> TempStrngMap_TextArea_Schema = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> TempStrngMap_Percent_Schema = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringMap> TempStrngMap_Email_Schema = new List<SFM_WrapperDef.SFM_StringMap>();
        
        //target can be integer, Src = Schema.DisplayType.CURRENCY
        //=========================Smart_Object==============================//

        if(MapTypeListSrcFlds_Source.get('INTEGER') != null) 
            TempStrngMap_Integer_Schema.addAll(MapTypeListSrcFlds_Source.get('INTEGER'));
        if(MapTypeListSrcFlds_Source.get('CURRENCY') != null)
            TempStrngMap_Integer_Schema.addAll(MapTypeListSrcFlds_Source.get('CURRENCY'));
        //Put result in new map
        New_MapTypeListTargetFlds_Source.put('INTEGER',TempStrngMap_Integer_Schema);


        //target can be currency, src= integer, currency

        if(MapTypeListSrcFlds_Source.get('CURRENCY') != null)
            TempStrngMap_Currency_Schema.addAll(MapTypeListSrcFlds_Source.get('CURRENCY'));
        if(MapTypeListSrcFlds_Source.get('INTEGER') != null)
            TempStrngMap_Currency_Schema.addAll(MapTypeListSrcFlds_Source.get('INTEGER'));
        New_MapTypeListTargetFlds_Source.put('CURRENCY',TempStrngMap_Currency_Schema);

        
        //target can be double,Src = Schema.DisplayType.CURRENCY
        //=========================Smart_Object==============================//

        if(MapTypeListSrcFlds_Source.get('INTEGER') != null)
            TempStrngMap_Double_Schema.addAll(MapTypeListSrcFlds_Source.get('INTEGER'));
        if(MapTypeListSrcFlds_Source.get('DOUBLE') != null)
            TempStrngMap_Double_Schema.addAll(MapTypeListSrcFlds_Source.get('DOUBLE'));
        if(MapTypeListSrcFlds_Source.get('CURRENCY') != null)
            TempStrngMap_Double_Schema.addAll(MapTypeListSrcFlds_Source.get('CURRENCY'));
        //Put result in new map
        New_MapTypeListTargetFlds_Source.put('DOUBLE',TempStrngMap_Double_Schema);

        
        //target can be date, src = datetime
        //=========================Smart_Object==============================//

        if(MapTypeListSrcFlds_Source.get('DATE') != null)
            TempStrngMap_Date_Schema.addAll(MapTypeListSrcFlds_Source.get('DATE'));
        if(MapTypeListSrcFlds_Source.get('DATETIME') != null)
            TempStrngMap_Date_Schema.addAll(MapTypeListSrcFlds_Source.get('DATETIME'));
        //Put result in new map
        New_MapTypeListTargetFlds_Source.put('DATE',TempStrngMap_Date_Schema);

        
        //target can be String, src = Schema.DisplayType.Picklist,Schema.DisplayType.URL, Schema.DisplayType.Email, Schema.DisplayType.Reference, Schema.DisplayType.Phone
        if(MapTypeListSrcFlds_Source.get('STRING') != null)
            TempStrngMap_String_Schema.addAll(MapTypeListSrcFlds_Source.get('STRING'));
        
        if(MapTypeListSrcFlds_Source.get('PICKLIST') != null)
            TempStrngMap_String_Schema.addAll(MapTypeListSrcFlds_Source.get('PICKLIST'));
        if(MapTypeListSrcFlds_Source.get('URL') != null)
            TempStrngMap_String_Schema.addAll(MapTypeListSrcFlds_Source.get('URL'));
        if(MapTypeListSrcFlds_Source.get('EMAIL') != null)
            TempStrngMap_String_Schema.addAll(MapTypeListSrcFlds_Source.get('EMAIL'));
        if(AllReferenceFields_Source != null)
            TempStrngMap_String_Schema.addAll(AllReferenceFields_Source);
        if(MapTypeListSrcFlds_Source.get('PHONE') != null)
            TempStrngMap_String_Schema.addAll(MapTypeListSrcFlds_Source.get('PHONE'));
        
        //Put result in new map
        New_MapTypeListTargetFlds_Source.put('STRING',TempStrngMap_String_Schema);
        
        
        //target can be Schema.DisplayType.TextArea_HTML, src = Schema.DisplayType.TextArea, Schema.DisplayType.TextArea_HTML, check for html fields....
        if(MapTypeListSrcFlds_Source.get('TEXTAREA') != null)
            TempStrngMap_HTMLTextArea_Schema.addAll(MapTypeListSrcFlds_Source.get('TEXTAREA'));
        if(MapTypeListSrcFlds_Source.get('TEXTAREA_HTML') !=null)
            TempStrngMap_HTMLTextArea_Schema.addAll(MapTypeListSrcFlds_Source.get('TEXTAREA_HTML'));
        //Put result in new map
        New_MapTypeListTargetFlds_Source.put('TEXTAREA_HTML',TempStrngMap_HTMLTextArea_Schema);
        
        //target can be Schema.DisplayType.TextArea, src = Schema.DisplayType.String, Schema.DisplayType.Picklist, Schema.DisplayType.URL, Schema.DisplayType.Email, Schema.DisplayType.Reference, Schema.DisplayType.Phone
        if(MapTypeListSrcFlds_Source.get('TEXTAREA') != null)
            TempStrngMap_TextArea_Schema.addAll(MapTypeListSrcFlds_Source.get('TEXTAREA'));
        if(MapTypeListSrcFlds_Source.get('STRING') != null)
            TempStrngMap_TextArea_Schema.addAll(MapTypeListSrcFlds_Source.get('STRING'));
        if(MapTypeListSrcFlds_Source.get('PICKLIST') != null )
            TempStrngMap_TextArea_Schema.addAll(MapTypeListSrcFlds_Source.get('PICKLIST'));
        if(MapTypeListSrcFlds_Source.get('URL') != null)
            TempStrngMap_TextArea_Schema.addAll(MapTypeListSrcFlds_Source.get('URL'));
        if(MapTypeListSrcFlds_Source.get('EMAIL') != null)
            TempStrngMap_TextArea_Schema.addAll(MapTypeListSrcFlds_Source.get('EMAIL'));
        if(AllReferenceFields_Source != null) //All Reference fields addition
            TempStrngMap_TextArea_Schema.addAll(AllReferenceFields_Source);
        if(MapTypeListSrcFlds_Source.get('PHONE') != null)
            TempStrngMap_TextArea_Schema.addAll(MapTypeListSrcFlds_Source.get('PHONE'));
        //Put result in new map
        New_MapTypeListTargetFlds_Source.put('TEXTAREA',TempStrngMap_TextArea_Schema);

        //target is Percent, Source = percent, integer,double
        if(MapTypeListSrcFlds_Source.get('INTEGER') != null)
            TempStrngMap_Percent_Schema.addAll(MapTypeListSrcFlds_Source.get('INTEGER'));
        if(MapTypeListSrcFlds_Source.get('DOUBLE') != null)
            TempStrngMap_Percent_Schema.addAll(MapTypeListSrcFlds_Source.get('DOUBLE'));
        if(MapTypeListSrcFlds_Source.get('CURRENCY') != null)
            TempStrngMap_Percent_Schema.addAll(MapTypeListSrcFlds_Source.get('CURRENCY'));
        New_MapTypeListTargetFlds_Source.put('EMAIL',TempStrngMap_Percent_Schema);

        //target = email, src =email, string, url
        if(MapTypeListSrcFlds_Source.get('EMAIL') != null)
            TempStrngMap_Email_Schema.addAll(MapTypeListSrcFlds_Source.get('EMAIL'));
        if(MapTypeListSrcFlds_Source.get('STRING') != null)
            TempStrngMap_Email_Schema.addAll(MapTypeListSrcFlds_Source.get('STRING'));
        if(MapTypeListSrcFlds_Source.get('URL') != null)
            TempStrngMap_Email_Schema.addAll(MapTypeListSrcFlds_Source.get('URL'));

        //Put result in new map
        New_MapTypeListTargetFlds_Source.put('EMAIL',TempStrngMap_Email_Schema);
        
        ////system.debug('entered1.5'+MapTypeListTargetFlds_Target.keyset());
        ////system.debug('entered1.6'+MapTypeListTargetFlds_Target);
        
        
        //Build Response
        SFM_WrapperDef.SFM_ObjectMap response = new SFM_WrapperDef.SFM_ObjectMap();
        //Member of response 
        List<SFM_WrapperDef.SFM_FieldMapping> fieldMapping = new List<SFM_WrapperDef.SFM_FieldMapping>();
        
        for(String FieldType: MapType_MapApiNameFldDescribe_Target.keyset())
        {
            String strNewFieldType = '';
            if(!FieldType.startsWith('Reference_') && !FieldType.endsWith('_HTML'))
                strNewFieldType = FieldType;
                
            if(MapTypeListSrcFlds_Source.containsKey(FieldType) || MapTypeListSrcFlds_Source.containsKey(strNewFieldType))
            {
                for(String fieldAPIName: MapType_MapApiNameFldDescribe_Target.get(FieldType).keyset())
                {
                    SVMXC__ServiceMax_Config_Data__c Src_Trgt_FieldRec = new SVMXC__ServiceMax_Config_Data__c();
                    //Getting from map/Database logic needs to be added here
                    Schema.DescribeFieldResult targetFieldDesc = targetFieldDescMap.get(fieldAPIName);
                    ////system.debug('NameError0'+targetFieldDesc);
                    ////system.debug('NameError1'+fieldAPIName);
                    ////system.debug('NameError2'+MapType_MapApiNameFldDescribe_Target.get(FieldType));
                    String fieldAPI = targetFieldDesc.getName();
                    Src_Trgt_FieldRec.SVMXC__Target_Field_Name__c = fieldAPI;//fieldAPIName;//target field name
                    
                    //Add more entities depending on type
                    List<SFM_WrapperDef.SFM_StringMap> expectedTargets;// = MapTypeListSrcFlds_Source.get(FieldType);
                    if((FieldType == 'DATE' || FieldType == 'STRING' || FieldType == 'TEXTAREA' || FieldType == 'TEXTAREA_HTML' || FieldType == 'EMAIL') && New_MapTypeListTargetFlds_Source.get(FieldType) != null)
                        expectedTargets = New_MapTypeListTargetFlds_Source.get(FieldType);//TargetFieldType_List of source fields
                    else if((FieldType == 'DATE' || FieldType == 'STRING' || FieldType == 'TEXTAREA' || FieldType == 'TEXTAREA_HTML' || FieldType == 'EMAIL') && New_MapTypeListTargetFlds_Source.get(strNewFieldType) != null)
                        expectedTargets = New_MapTypeListTargetFlds_Source.get(strNewFieldType);//TargetFieldType_List of source fields
                    else if(FieldType == 'DOUBLE' && MapNew_Double_FldLst.get(targetFieldDesc.getlength()) != null)
                        expectedTargets = MapNew_Double_FldLst.get(targetFieldDesc.getlength());
                    else if((FieldType == 'INTEGER') && MapNew_Integer_FldLst.get(targetFieldDesc.getlength()) != null)
                        expectedTargets = MapNew_Integer_FldLst.get(targetFieldDesc.getlength());
                    else if((FieldType == 'CURRENCY') && MapNew_Integer_FldLst.get(targetFieldDesc.getlength()) != null)
                        expectedTargets = MapNew_Currency_FldLst.get(targetFieldDesc.getlength());
                    else if((FieldType == 'PERCENT') && MapNew_Integer_FldLst.get(targetFieldDesc.getlength()) != null)
                        expectedTargets = MapNew_PERCENT_FldLst.get(targetFieldDesc.getlength());
                    else{
                        if(MapTypeListSrcFlds_Source.containsKey(FieldType))
                            expectedTargets = MapTypeListSrcFlds_Source.get(FieldType);
                        else if(MapTypeListSrcFlds_Source.containsKey(strNewFieldType))
                            expectedTargets = MapTypeListSrcFlds_Source.get(strNewFieldType);
                    }

                    List<SFM_WrapperDef.SFM_StringMap> expectedConstants;
                    if(FieldType.equalsIgnoreCase('PICKLIST'))
                    {
                        String ModifiedFldType = 'Picklist_' + fieldAPIName;
                        expectedConstants = MapType_ListOfConstants.get(ModifiedFldType);
                    }
                    else
                        expectedConstants = MapType_ListOfConstants.get(FieldType);
                    ////system.debug('enteredgetfrommap1'+gettingFromMap);
                    if(gettingFromMap)
                    {
                        if(defaultFieldMapping.containsKey(fieldAPI))
                            Src_Trgt_FieldRec = defaultFieldMapping.get(fieldAPI);
                        else if(defaultFieldMapping.containsKey(fieldAPIName))
                            Src_Trgt_FieldRec = defaultFieldMapping.get(fieldAPIName);
                    }
                    else//if(!gettingFromMap)
                    {
                        String suggestedFields;
                        if(sourceFieldDescMap != null && sourceFieldDescMap.containskey(fieldAPIName))
                        {
                            suggestedFields = fieldAPI;
                            ////system.debug('enteredgetfrommap2'+fieldAPI);
                        }
                        if(suggestedFields!=NULL)
                            Src_Trgt_FieldRec.SVMXC__Source_Field_Name__c = suggestedFields;
                        ////system.debug('enteredgetfrommap3'+Src_Trgt_FieldRec.SVMXC__Source_Field_Name__c);
                    }
                    SFM_WrapperDef.SFM_FieldMapping fldmap = new SFM_WrapperDef.SFM_FieldMapping(Src_Trgt_FieldRec, expectedTargets);
                    fieldMapping.add(fldmap);
                    fldmap.sourceFieldsConstant = expectedConstants;
                }
            }
            else
            {
                for(String fieldAPIName:MapType_MapApiNameFldDescribe_Target.get(FieldType).keyset())
                {
                    SVMXC__ServiceMax_Config_Data__c Src_Trgt_FieldRec = new SVMXC__ServiceMax_Config_Data__c();
                    //Getting from map/Databse logic needs to be added here
                    Schema.DescribeFieldResult targetFieldDesc = targetFieldDescMap.get(fieldAPIName);
                    String fieldAPI = targetFieldDesc.getName();
                    Src_Trgt_FieldRec.SVMXC__Target_Field_Name__c = fieldAPI;//fieldAPIName;//target field name
                    //To check source field data or its related constants, we do the following
                    if(gettingFromMap)//If yes populate config data record from database
                    {
                        if(defaultFieldMapping.containsKey(fieldAPI))
                            Src_Trgt_FieldRec = defaultFieldMapping.get(fieldAPI);
                        else if(defaultFieldMapping.containsKey(fieldAPIName))
                            Src_Trgt_FieldRec = defaultFieldMapping.get(fieldAPIName);
                    }
                    List<SFM_WrapperDef.SFM_StringMap> expectedConstants;
                    if(FieldType.equalsIgnoreCase('PICKLIST'))
                    {
                        String ModifiedFldType = 'Picklist_' + fieldAPIName;
                        expectedConstants = MapType_ListOfConstants.get(ModifiedFldType);
                    }
                    else
                        expectedConstants = MapType_ListOfConstants.get(FieldType);
                    SFM_WrapperDef.SFM_FieldMapping fldmap = new SFM_WrapperDef.SFM_FieldMapping(Src_Trgt_FieldRec, null);
                    fieldMapping.add(fldmap);
                    fldmap.sourceFieldsConstant = expectedConstants;
                }
            }
            
        }
        ////system.debug('entered1.7'+fieldMapping);
        
        //======================================Smart_Object=========================================//
        System.debug(LoggingLevel.WARN, 'MapTypeListSrcFlds_Source11 : '+MapTypeListSrcFlds_Source);
        System.debug(LoggingLevel.WARN, 'MapType_MapApiNameFldDescribe_TargetSmart11 : '+MapType_MapApiNameFldDescribe_TargetSmart);
        for(String FieldType: MapType_MapApiNameFldDescribe_TargetSmart.keyset())
        {
            if(MapTypeListSrcFlds_Source.containsKey(FieldType))
            {
                for(String fieldAPIName: MapType_MapApiNameFldDescribe_TargetSmart.get(FieldType).keyset())
                {
                    SVMXC__ServiceMax_Config_Data__c Src_Trgt_FieldRec = new SVMXC__ServiceMax_Config_Data__c();
                    SmartObject.DescribeSmartFieldResult targetFieldDesc = targetFieldDescMapSmart.get(fieldAPIName);
                    String fieldAPI = targetFieldDesc.getName();
                    Src_Trgt_FieldRec.SVMXC__Target_Field_Name__c = fieldAPI;
                    
                    //Adding more entities depending on type
                    List<SFM_WrapperDef.SFM_StringMap> expectedTargets;
                    if((FieldType == 'DATE' || FieldType == 'STRING') && New_MapTypeListTargetFlds_Source.get(FieldType) != null)
                        expectedTargets = New_MapTypeListTargetFlds_Source.get(FieldType);//TargetFieldType_List of source fields
                    else if((FieldType == 'DATE' || FieldType == 'STRING') && New_MapTypeListTargetFlds_Source.get(FieldType) != null)
                        expectedTargets = New_MapTypeListTargetFlds_Source.get(FieldType);
                    else if(FieldType == 'DOUBLE' && MapNew_Double_FldLst.get(Integer.valueOf(targetFieldDesc.getlength())) != null)
                        expectedTargets = MapNew_Double_FldLst.get(Integer.valueOf(targetFieldDesc.getlength()));
                    else if((FieldType == 'INTEGER') && MapNew_Integer_FldLst.get(Integer.valueOf(targetFieldDesc.getlength())) != null)
                        expectedTargets = MapNew_Integer_FldLst.get(Integer.valueOf(targetFieldDesc.getlength()));
                    else{
                        if(MapTypeListSrcFlds_Source.containsKey(FieldType))
                            expectedTargets = MapTypeListSrcFlds_Source.get(FieldType);
                        else if(MapTypeListSrcFlds_Source.containsKey(FieldType))
                            expectedTargets = MapTypeListSrcFlds_Source.get(FieldType);
                    }

                    List<SFM_WrapperDef.SFM_StringMap> expectedConstants;
                    expectedConstants = MapType_ListOfConstants.get(FieldType);
                    if(gettingFromMap){
                        if(defaultFieldMapping.containsKey(fieldAPI))
                            Src_Trgt_FieldRec = defaultFieldMapping.get(fieldAPI);
                        else if(defaultFieldMapping.containsKey(fieldAPIName))
                            Src_Trgt_FieldRec = defaultFieldMapping.get(fieldAPIName);
                    }
                    else{
                        String suggestedFields;
                        if(sourceFieldDescMapSmart != null && sourceFieldDescMapSmart.containskey(fieldAPIName))
                            suggestedFields = fieldAPI;
                        if(suggestedFields!=NULL)
                            Src_Trgt_FieldRec.SVMXC__Source_Field_Name__c = suggestedFields;
                    }
                    SFM_WrapperDef.SFM_FieldMapping fldmap = new SFM_WrapperDef.SFM_FieldMapping(Src_Trgt_FieldRec, expectedTargets);
                    fieldMapping.add(fldmap);
                    fldmap.sourceFieldsConstant = expectedConstants;
                }
            }
            else
            {
                for(String fieldAPIName:MapType_MapApiNameFldDescribe_TargetSmart.get(FieldType).keyset())
                {
                    SVMXC__ServiceMax_Config_Data__c Src_Trgt_FieldRec = new SVMXC__ServiceMax_Config_Data__c();
                    SmartObject.DescribeSmartFieldResult targetFieldDesc = targetFieldDescMapSmart.get(fieldAPIName);
                    String fieldAPI = targetFieldDesc.getName();
                    Src_Trgt_FieldRec.SVMXC__Target_Field_Name__c = fieldAPI;
                    
                    if(gettingFromMap)//If yes populate config data record from database
                    {
                        if(defaultFieldMapping.containsKey(fieldAPI))
                            Src_Trgt_FieldRec = defaultFieldMapping.get(fieldAPI);
                        else if(defaultFieldMapping.containsKey(fieldAPIName))
                            Src_Trgt_FieldRec = defaultFieldMapping.get(fieldAPIName);
                    }
                    List<SFM_WrapperDef.SFM_StringMap> expectedConstants;
                    expectedConstants = MapType_ListOfConstants.get(FieldType);
                    SFM_WrapperDef.SFM_FieldMapping fldmap = new SFM_WrapperDef.SFM_FieldMapping(Src_Trgt_FieldRec, null);
                    fieldMapping.add(fldmap);
                    fldmap.sourceFieldsConstant = expectedConstants;
                }
            }
        }
        //============================================================================================//
        response.fields = fieldMapping;

        //Added for fixing defect 043150 
        if(batchSeq > 0){
            response.fieldsToNull = String.valueOf(strTotalBatchSize);  
        }
        else if(batchSeq == 0){
            response.fieldsToNull = String.valueOf(1);
        }
        
        return response;
    }
    
    /*
    Identifies the appropriate match using pattern match algorithm
    */
    public String selectAppropriateMatch(String targetFieldAPI, List<SFM_WrapperDef.SFM_StringMap> expectedSources){
        /*
        //If type = reference and referenceTo matches, and source has only one such reference field
        if(targetRefernceFields.contains(targetFieldAPI)){
            if(expectedSources.size()==1)
            return expectedSources[0].key;
        }*/
        Pattern reqPattern = Pattern.compile('^(.*)((?i)('+targetFieldAPI+'))$');
        Matcher reqMatcher;
        if(expectedSources!=NULL){
            for(SFM_WrapperDef.SFM_StringMap target: expectedSources){
                reqMatcher = reqPattern.matcher(target.key);
                if(reqMatcher.matches()){
                    return target.key;
                    break;
                }
            }
        }
        return null;
    }
    
    // Get only the object mapping details, without any intelligence on top it
    public SFM_WrapperDef.SFM_Response_ObjectMap getOnlyObjectMapping(SFM_WrapperDef.SFM_Request prequest)
    {
        SFM_WrapperDef.SFM_Response_ObjectMap resp;
        Map<String,String> request = new Map<String,String>();
        ////system.debug('entered1'+prequest);
        ////system.debug('entered2'+prequest.stringMap);
        request = utils.getStringMap(prequest.stringMap);
        Boolean isNoReferenceField = false;
        if(request.get('NOREFERENCEFIELD') == 'TRUE')
        {
            isNoReferenceField = true;
        }
        
        List<SVMXC__ServiceMax_Processes__c> LstObjectMap = [Select SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c, SVMXC__MapID__c, SVMXC__Description__c, Name, Id,SVMXC__Name__c,SVMXC__IsStandard__c  From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Object Mapping' AND Id = :request.get('RECORDID')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        SFM_WrapperDef.SFM_ObjectMap wrpObjMap = new SFM_WrapperDef.SFM_ObjectMap();

        if(LstObjectMap.size()>0)
        {
            // Building source object field describe
            DCON_Utils dcUtils = new DCON_Utils();
            
            //Getting the label for all lookup id's
            Map<String, SObjectField> mapTargetObjFieldMap;
            set<String> referenceFields = new set<String>();
            if(isNoReferenceField == true)
            {
                String targetObjectName = LstObjectMap[0].SVMXC__Target_Object_Name__c;
                //Get the original API name of the object
                Map<String, String> originalAPI = new Map<String, String>();
                set<String> givenObject = new set<String>();
                givenObject.add(targetObjectName);
                originalAPI = utils.getOriginalAPIName(givenObject, allObjs);
                mapTargetObjFieldMap = allObjs.get(originalAPI.get(targetObjectName)).getDescribe().fields.getMap();
                for(String fieldAPI: mapTargetObjFieldMap.keySet())
                {
                    Schema.SObjectField targetField = mapTargetObjFieldMap.get(fieldAPI); 
                    Schema.DescribeFieldResult targetFieldDesc = targetField.getDescribe();
                    if(targetFieldDesc.getType() == Schema.DisplayType.Reference)
                    {
                        referenceFields.add(targetFieldDesc.getName());
                    }
                }
            }
            
            list<SVMXC__ServiceMax_Config_Data__c> LstField = [Select SVMXC__Configuration_Type__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c,   SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, Name, Id, SVMXC__Preference_2__c, SVMXC__Preference_3__c, SVMXC__Object_Name2__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c = :LstObjectMap[0].Id and Recordtype.Name='Field Mapping']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            List<SFM_WrapperDef.SFM_FieldMapping> fields = new List<SFM_WrapperDef.SFM_FieldMapping>();
            List<SFM_WrapperDef.SFM_ObjectMap> objects = new List<SFM_WrapperDef.SFM_ObjectMap>();
            for(SVMXC__ServiceMax_Config_Data__c fieldMapping: LstField)
            {
                if(isNoReferenceField == true && fieldMapping.SVMXC__Target_Field_Name__c != NULL)
                {
                    // Donot add reference fields for migration if it has record id associated with it
                    if(fieldMapping.SVMXC__Source_Field_Name__c != NULL && referenceFields.contains(fieldMapping.SVMXC__Target_Field_Name__c))
                        fields.add(new SFM_WrapperDef.SFM_FieldMapping(fieldMapping, null));
                    else if(!referenceFields.contains(fieldMapping.SVMXC__Target_Field_Name__c))
                        fields.add(new SFM_WrapperDef.SFM_FieldMapping(fieldMapping, null));
                    else if(fieldMapping.SVMXC__Configuration_Type__c == 'Value Mapping')
                    {
                        if(fieldMapping.SVMXC__Display_Value__c != NULL && fieldMapping.SVMXC__Internal_Value__c != NULL)
                        {
                            // We are setting up internal and display value if it is of reference type
                        }
                        else
                            fields.add(new SFM_WrapperDef.SFM_FieldMapping(fieldMapping, null));
                    }
                }
                else
                    fields.add(new SFM_WrapperDef.SFM_FieldMapping(fieldMapping, null));
            }
            wrpObjMap.objectMap = LstObjectMap[0];
            wrpObjMap.fields =fields;
            objects.add(wrpObjMap);
            resp = new SFM_WrapperDef.SFM_Response_ObjectMap(objects);
            resp.response.success = true;
        }
        return resp;
    }
}