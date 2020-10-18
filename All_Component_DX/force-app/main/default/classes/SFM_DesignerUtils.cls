public with sharing class SFM_DesignerUtils{

    public class ServicemaxNestedException extends Exception {
    }
    
    public static final String APPLICATION_TYPE = 'SFM Designer';
    public static final String PROCESSTYPE_INVENTORY = 'Inventory Process';
    public static final String SFM_TRANSACTION_MANAGER  = 'SFM001';
    public static final String COMMON_GLOBAL_SETTINGS   = 'GLOB001';
    public static final String USAGE_TRACKING_SETTINGS  = 'COMM004';
    public static final String SETTING_USAGE_TRACKING_ALLOW     = 'SET001';
    public static final String SETTING_MAX_SORT_FIELDS          = 'SET003';
    public static final String ENABLE_CHECKLIST_CAPABILITIES    = 'GBL029';
    public static final String ENABLE_SALESFORCE_FILES          = 'GBL037';
    public static final String ENABLE_API_CONFIGURATION         = 'SET004';
    public static final List<String> SFM_SETTINGS = new List<String> {
        SETTING_MAX_SORT_FIELDS, ENABLE_API_CONFIGURATION
    };
    public static final List<String> GBL_SETTINGS = new List<String> {
        ENABLE_CHECKLIST_CAPABILITIES,
        ENABLE_SALESFORCE_FILES
    };
    /*
        Supported Entity Types
    */
    public Static final String entity_sfm = 'SFM';
    public Static final String entity_opdoc = 'OPDOC';
    public Static final String entity_checklist = 'CHECKLIST';
    public Static final String entity_expression = 'EXPRESSION';
    public Static final String entity_businessrule = 'BUSINESS_RULE'; //DVR
    public Static final String entity_checklistCriteria = 'OPDOC_CHECKLIST_CRITERIA'; //Checklist Expression
    public Static final String entity_mapping = 'MAPPING';
    public Static final String entity_formula = 'FORMULA';
    public Static final String entity_layout = 'PAGELAYOUT';
    public Static final String entity_template = 'OPDOC_TEMPLATE';
    public Static final String entity_lkpConfig = 'LOOKUPCONFIG';
    public Static final String entity_sectionEntryCriteria = 'SECTION_ENTRY_CRITERIA';
    public Static final String entity_question = 'QUESTION';
    public Static final String entity_responseSet = 'RESPONSE_SET';
    public Static final String entity_sectionCriteria = 'Checklist_Section_Criteria';
    public Static final Set<String> supportedLiterals = new Set<String>{'TODAY','TOMORROW','YESTERDAY','NOW'};
    // comment below as part of dynamic values
    /* public Static final Map<String, Set<String>> entityMacrosMap = new Map<String, Set<String>> {
        entity_formula => new Set<String> {'ADD','ADDTODATE','AND','AVGOF','DATE','DATEDIFF','DATETIMEVALUE','DATEVALUE','DAY','DIVIDE',
                                            'EQUAL','GREATERTHAN','GREATERTHANEQUAL','IF','LESSTHAN','LESSTHANEQUAL','MAXOF','MINOF','MONTH',
                                            'MULTIPLY','NOT','NOTEQUAL','NOW','OR','SUBTRACT','SUMOF','TODAY','YEAR'},
        entity_opdoc => new Set<String> {'ADD','ADDRESS','BOOL','CHECKLIST','FORMAT','IF','IMAGE','INT','ISNULL','LNUMBER','LOGO','NOW','ROUND',
                                          'SIGNATURE','SNUMBER','SUMOF','TODAY','TOMORROW','TOUPPER','USERNAME','WORD_BREAK','YESTERDAY'}
    }; */

    /*
        To Do: To be seeded from auto configurator. 
    */
    /* public Static final Map<String, SVMXC__Function_Definition__c> functionsMap = new Map<String, SVMXC__Function_Definition__c>{
        'AND'               => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'AND', SVMXC__Type__c = 'Conditional', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'OR'                => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'OR', SVMXC__Type__c = 'Conditional', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'NOT'               => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'NOT', SVMXC__Type__c = 'Conditional', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'DATE'              => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'DATE', SVMXC__Type__c = 'Date', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'DATEVALUE'         => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'DATEVALUE', SVMXC__Type__c = 'Date', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'DATETIMEVALUE'     => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'DATETIMEVALUE', SVMXC__Type__c = 'Date', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'DATEDIFF'          => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'DATEDIFF', SVMXC__Type__c = 'Date', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'DAY'               => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'DAY', SVMXC__Type__c = 'Date', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'MONTH'             => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'MONTH', SVMXC__Type__c = 'Date', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'YEAR'              => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'YEAR', SVMXC__Type__c = 'Date', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'EQUAL'             => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'EQUAL', SVMXC__Type__c = 'Logical', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'NOTEQUAL'          => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'NOTEQUAL', SVMXC__Type__c = 'Logical', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'LESSTHAN'          => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'LESSTHAN', SVMXC__Type__c = 'Logical', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'LESSTHANEQUAL'     => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'LESSTHANEQUAL', SVMXC__Type__c = 'Logical', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'GREATERTHAN'       => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'GREATERTHAN', SVMXC__Type__c = 'Logical', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'GREATERTHANEQUAL'  => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'GREATERTHANEQUAL', SVMXC__Type__c = 'Logical', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'SUBTRACT'          => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'SUBTRACT', SVMXC__Type__c = 'Math', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'MULTIPLY'          => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'MULTIPLY', SVMXC__Type__c = 'Math', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'DIVIDE'            => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'DIVIDE', SVMXC__Type__c = 'Math', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'AVGOF'             => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'AVGOF', SVMXC__Type__c = 'Rollups', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'MINOF'             => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'MINOF', SVMXC__Type__c = 'Rollups', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true),
        'MAXOF'             => new SVMXC__Function_Definition__c (SVMXC__Macro_Name__c = 'MAXOF', SVMXC__Type__c = 'Rollups', SVMXC__IsActive__c = true, SVMXC__IsStandard__c = true)
    };
    */

    
    /**
     * This method is used to generate unique id for given construct key. The length of the 
     * unique id will be 45 plus the length of the construct key.
     * 
     * @param constructKey String construct key using which the unique id to be generated.
     * @return Returns uniqueId if success, Otherwise, returns null.
     */
    public static String generateUniqueId( String constructKey ) {
        
        System.debug( System.LoggingLevel.DEBUG, 'generateUniqueId() - enter; constructKey=' + constructKey );
        
        String uniqueId = null;
        try {
            
            /* 
             * Checking for valid construct key string. The unique key will not 
             * be generated if the construct key is null or empty.
             */
            if( constructKey != null && constructKey.trim().length() != 0 ) {
            
                /*
                 * Unique ID will be generated with the combination of construct key, 
                 * current datetime(in long) and newly generated AES key.
                 */
                Blob blob128 = Crypto.GenerateAESKey(128);
                uniqueId = constructKey + String.valueOf(System.Datetime.now().getTime()) + EncodingUtil.ConvertTohex(blob128);
            } else {
                System.debug( System.LoggingLevel.ERROR, 'generateUniqueId() : Invalid construct key' );
            }
        }
        catch(Exception e) {
            System.debug( System.LoggingLevel.ERROR, 'generateUniqueId() : Failed to generate uniqueID; ' + e.getMessage() );
        }
        finally {
            System.debug( System.LoggingLevel.DEBUG, 'generateUniqueId() - exit; uniqueId=' + uniqueId );
        }
        
        return uniqueId;
    }

    public Static Map<String, String> customLabelTranslations {
        get{
            if(customLabelTranslations == null){
                customLabelTranslations = new Map<String, String>();
                customLabelTranslations.put('message1', 'Invalid Request');
            }
            return customLabelTranslations;
        }
        set;
    }

    public Static Map<String, Id> recordTypeIdMap {
        get{
            if(recordTypeIdMap == null){
                
                recordTypeIdMap = new Map<String, Id>();
                
                /*for(Schema.DescribeSObjectResult desRes : sobjectsFieldsDescribe(new List<String>{'SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c'})){
                    for(Schema.RecordTypeInfo rt : desRes.getRecordTypeInfos()){
                        if(rt.isActive()){
                            recordTypeIdMap.put(rt.getName(), rt.getRecordTypeId());
                        }
                    }
                }*/

                for(RecordType rec : [SELECT Id, Name FROM RecordType WHERE SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c') AND isActive = true]){
                    recordTypeIdMap.put(rec.Name, rec.Id);                          
                }       
            }

            return recordTypeIdMap;
        }
        set;
    }

    public Static Set<String> allowedStandardObjects {
        get{
            if(allowedStandardObjects ==null){
                allowedStandardObjects = new Set<String>();   
                String licenseType = SVMXC__ServiceMax_Properties__c.getValues('PROP001').SVMXC__Value__c;

                /*
                    CRUD, FLS checks not required for custom setting objects.
                */
                for(SVMXC__ServiceMax_Property_Elements__c propertyElementRec :  [SELECT SVMXC__Element_Value__c FROM SVMXC__ServiceMax_Property_Elements__c WHERE SVMXC__Property_Key__c =: licenseType]){
                    allowedStandardObjects.add(propertyElementRec.SVMXC__Element_Value__c);
                }         
            }

            return allowedStandardObjects;
        }

        set;
    }

    public Static List<SFM_WrapperDef2.SobjectInfo> getPermittedObjects(List<String> sObjectsList){

        List<SFM_WrapperDef2.SobjectInfo> sObjectInfoList = new List<SFM_WrapperDef2.SobjectInfo>();
        Set<String> sObjectKeys;
        
        /*
            CRUD, FLS checks not required for custom setting objects.
        */


        Map<String, Schema.SObjectType> sObjectGlobalDescribe = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
        
        if(sObjectsList == null){
            sObjectKeys = sObjectGlobalDescribe.keySet();
        }else if(!sObjectsList.isEmpty()){
            sObjectKeys = new Set<String>(sObjectsList);
        }

        if(sObjectKeys != null){
            Set<String> blockedSrcList_Standard = new Set<String>();
            for(SVMXC__ServiceMax_Property_Elements__c elementRecord : [SELECT SVMXC__Element_Value__c From SVMXC__ServiceMax_Property_Elements__c WHERE 
                    SVMXC__Property_Key__c = 'BLOCKED SOURCE HEADER' AND (NOT SVMXC__Element_Value__c LIKE '%\_\_c')]){
                blockedSrcList_Standard.add(elementRecord.SVMXC__Element_Value__c);
            }

            for(String sObj : sObjectKeys){
                
                DescribeSObjectResult sobjResult = sObjectGlobalDescribe.get(sObj).getDescribe();
                
                if(sobjResult.isAccessible() && sobjResult.isUpdateable () && sobjResult.isQueryable()){
                    
                    if(sobjResult.isCustom()){
                        SFM_WrapperDef2.SobjectInfo sobjWrapper = new SFM_WrapperDef2.SobjectInfo(sobjResult.getName(), sobjResult.getLabel());
                        sobjWrapper.fieldsCount = sobjResult.fields.getMap().size();
                        sobjWrapper.custom = sobjResult.isCustom();
                        sObjectInfoList.add(sobjWrapper);
                    }else if(allowedStandardObjects.contains(sobjResult.getName()) && !blockedSrcList_Standard.contains(sobjResult.getName())){    
                        SFM_WrapperDef2.SobjectInfo sobjWrapper = new SFM_WrapperDef2.SobjectInfo(sobjResult.getName(), sobjResult.getLabel());
                        sobjWrapper.fieldsCount = sobjResult.fields.getMap().size();
                        sobjWrapper.custom = sobjResult.isCustom();
                        sObjectInfoList.add(sobjWrapper);
                    }
                }
            }
        }

        return sObjectInfoList;
    }



    public Static List<SFM_WrapperDef2.SmaxPropertyElement> getServicemaxPropertyElements(){
        Set<String> licenseTypes = new Set<String>{'Titanium', 'Titanium Pro', 'Enterprise'};
        List<SVMXC__ServiceMax_Property_Elements__c> propertyElementsList = SVMXC__ServiceMax_Property_Elements__c.getall().values();
        List<SFM_WrapperDef2.SmaxPropertyElement> propertyElementsWrapperList = new List<SFM_WrapperDef2.SmaxPropertyElement>();
        Map<String, Set<String>> propertyElementsMap;

        if(propertyElementsList != null){
            propertyElementsMap = new Map<String, Set<String>>();

            for(SVMXC__ServiceMax_Property_Elements__c propertyElementRec : propertyElementsList){
                
                if(propertyElementRec.SVMXC__Property_Key__c != null && !licenseTypes.contains(propertyElementRec.SVMXC__Property_Key__c)){
                    
                    Set<String> tempSet = new  Set<String>();
                    if(propertyElementsMap.containsKey(propertyElementRec.SVMXC__Property_Key__c)){

                        tempSet = propertyElementsMap.get(propertyElementRec.SVMXC__Property_Key__c);
                    }
                    
                    tempSet.add(propertyElementRec.SVMXC__Element_Value__c);
                    propertyElementsMap.put(propertyElementRec.SVMXC__Property_Key__c, tempSet);
                }

            }
        }

        if(propertyElementsMap != null){
            for(String propertyKey : propertyElementsMap.keySet()){
                SFM_WrapperDef2.SmaxPropertyElement propertyElementWrapper = new SFM_WrapperDef2.SmaxPropertyElement();
                propertyElementWrapper.propertyKey = propertyKey;
                propertyElementWrapper.propertyValues = new List<String>(propertyElementsMap.get(propertyKey));
                propertyElementsWrapperList.add(propertyElementWrapper);
            }
        }
        
        return propertyElementsWrapperList;
    }

    /*
        To Do : This method can be refactored for platform caching.
    */
    public Static List<Schema.DescribeSobjectResult> sobjectsFieldsDescribe(List<String> sObjectTypes){
        
        return Schema.describeSObjects(sObjectTypes);

    }

    public Static Map<String, List<SFM_WrapperDef2.FieldProperties>> getsObjectFields(List<String> sObjectTypes, String entityType){
        List<Schema.DescribeSObjectResult> sObjectResults = sobjectsFieldsDescribe(sObjectTypes);
        Map<String, List<SFM_WrapperDef2.FieldProperties>> fieldDescribeUtilMap = new Map<String, List<SFM_WrapperDef2.FieldProperties>>();


        for(Schema.DescribeSobjectResult res : sObjectResults){
            
            Map<String, Schema.SObjectField> sObjectFields = res.fields.getMap();
            Map<String, SFM_WrapperDef2.FieldProperties> fieldPropertyMap = new Map<String, SFM_WrapperDef2.FieldProperties>();
            for(Schema.SObjectField fld : sObjectFields.values()){
                Schema.DescribeFieldResult fldDescribe = fld.getDescribe();

                if(entityType == null){
                    if(fldDescribe.isAccessible()){
                        String localName = fldDescribe.getLocalName();
                        SFM_WrapperDef2.FieldProperties fieldProp = getFieldAttributes(fldDescribe);
                        if(fieldPropertyMap.containsKey(localName)){
                            if(fldDescribe.getName().indexOf('SVMXC__') != -1){
                                fieldPropertyMap.put(localName, fieldProp);
                            }
                            continue;
                        }
                        fieldPropertyMap.put(localName, fieldProp);
                    }
                }
            }

            if(entityType == null){
                fieldDescribeUtilMap.put(res.getName(), fieldPropertyMap.values());
            }
        }

        return fieldDescribeUtilMap;

    }
    
    /**
     * This utility method is used to retrieve list of all child relationship 
     * object for given sObject type.
     */
    public static List<SFM_WrapperDef2.SobjectInfo> getChildRelationship( final List<String> sObjectTypes ) {
        
        System.debug( System.LoggingLevel.DEBUG, 'getChildRelationship() - enter; sObjectType=' + sObjectTypes );
        
        List<SFM_WrapperDef2.SobjectInfo> relationshipSObjectInfoSet = new List<SFM_WrapperDef2.SobjectInfo>();
        try {
            // Validate sObjectType for valid string.
            if ( sObjectTypes != null && sObjectTypes.size() > 0 ) {
                
                // Describe sObjectType to get the child relationship information.
                List<Schema.DescribeSobjectResult> describeSobjectResultList = Schema.describeSObjects( sObjectTypes );
                if( describeSobjectResultList != null && !describeSobjectResultList.isEmpty() ) {
                    
                    // loop through all the child relationship to retrieve chid object api names.
                    for( Schema.DescribeSobjectResult describeSobjectResult : describeSobjectResultList ) {
                        
                        SFM_WrapperDef2.SobjectInfo sObjectInfo = new SFM_WrapperDef2.SobjectInfo(  describeSobjectResult.getName(), describeSobjectResult.getLabel() );                                
                        for(Schema.ChildRelationship childRelationship : describeSobjectResult.getChildRelationships()) {
            
                            if( childRelationship.getChildSObject() != null ) {
                                Schema.DescribeSObjectResult childDescribeSObjectResult = childRelationship.getChildSObject().getDescribe();
                                Schema.DescribeFieldResult lookupFldDescribe = childRelationship.getField().getDescribe(); 

                                if(childDescribeSObjectResult.isAccessible() && childDescribeSObjectResult.isUpdateable () && childDescribeSObjectResult.isQueryable()){
                                    
                                    if(childDescribeSObjectResult.isCustom()){
                                        sObjectInfo.childReferences.add(new SFM_WrapperDef2.SobjectInfo(childDescribeSObjectResult.getName(), childDescribeSObjectResult.getLabel()  + ' (' + lookupFldDescribe.getLabel() + ')', String.valueOf(childRelationship.getField()),
                                                                                                        lookupFldDescribe.isCustom()));
                                    }else if(allowedStandardObjects.contains(childDescribeSObjectResult.getName())){
                                        sObjectInfo.childReferences.add(new SFM_WrapperDef2.SobjectInfo(childDescribeSObjectResult.getName(), childDescribeSObjectResult.getLabel()  + ' (' + lookupFldDescribe.getLabel() + ')', String.valueOf(childRelationship.getField()),
                                                                                                        lookupFldDescribe.isCustom()));
                                    }
                                }
                            }
                        }
                        
                        relationshipSObjectInfoSet.add( sObjectInfo );
                    }
                    
                } else {
                    System.debug( System.LoggingLevel.ERROR, 'Failed to retrieve describe Sobject result;' );
                }
            } else {
                System.debug( System.LoggingLevel.ERROR, 'Invalid sObject type;' );
            }
        }
        catch( Exception e ) {
            System.debug( System.LoggingLevel.ERROR, e.getMessage() );
        }
        finally {
            System.debug( System.LoggingLevel.DEBUG, 'getChildRelationship() - exit');
        }
        return relationshipSObjectInfoSet;
    }

    public Static SFM_WrapperDef2.FieldProperties getFieldAttributes(Schema.DescribeFieldResult fldDescribe){
        SFM_WrapperDef2.FieldProperties fieldProps = new SFM_WrapperDef2.FieldProperties();
        fieldProps.length = fldDescribe.getLength();
        fieldProps.calculated = fldDescribe.isCalculated();
        fieldProps.custom = fldDescribe.isCustom();
        fieldProps.filterable = fldDescribe.isFilterable();
        fieldProps.idLookup = fldDescribe.isIdLookup();
        fieldProps.label = fldDescribe.getLabel();
        fieldProps.dataType = String.valueOf(fldDescribe.getType());
        fieldProps.unique = fldDescribe.isUnique();
        fieldProps.nillable = fldDescribe.isNillable();
        fieldProps.nameField = fldDescribe.isNameField();
        fieldProps.name = fldDescribe.getName();
        fieldProps.autoNumber = fldDescribe.isAutoNumber();
        fieldProps.precision = fldDescribe.getPrecision();
        fieldProps.scale = fldDescribe.getScale();
        fieldProps.createable = fldDescribe.isCreateable();
        fieldProps.updateable = fldDescribe.isUpdateable();
        fieldProps.htmlFormatted = fldDescribe.isHtmlFormatted();

        if(fldDescribe.getType() == Schema.Displaytype.PICKLIST || fldDescribe.getType() == Schema.Displaytype.MULTIPICKLIST)
            fieldProps.picklistValues = picklistValuesInString(fldDescribe.getPicklistValues());
        if(fldDescribe.getType() == Schema.Displaytype.REFERENCE){
            /*
                As of now only User is supported for owner field. Need to be enhanced to support Group/Queue SFMDZ-1037
            */
            fieldProps.referenceTo = fieldProps.name.equalsIgnoreCase('OWNERID')? 'User' : String.valueOf(fldDescribe.getReferenceTo()[0]);
            fieldProps.relationshipName = fldDescribe.getRelationshipName();
            List<Schema.DescribeSObjectResult> sObjectResults = sobjectsFieldsDescribe(new List<String>{fieldProps.referenceTo});
            Map<String, Schema.SObjectField> fieldResultMap = sObjectResults[0].fields.getMap();

            for(String fld : fieldResultMap.keySet()){
                Schema.DescribeFieldResult refFldDescribe = fieldResultMap.get(fld).getDescribe();

                if(refFldDescribe.isNameField()){
                    fieldProps.referenceNameField = refFldDescribe.getName();
                    break;
                }
            }
        }
        
        return fieldProps;
    }

    Static Object picklistValuesInString(List<Schema.PickListEntry> picklistEntries){
        
        List<PicklistEntry> pickListEntriesWrapperList = new List<PicklistEntry>();

        for(Schema.PickListEntry pickListEntry : picklistEntries){
            if(pickListEntry.isActive()){
                pickListEntriesWrapperList.add(new PicklistEntry(pickListEntry.getValue(), pickListEntry.getLabel()));
            }
        }

        return pickListEntriesWrapperList;
    }


    public Static List<sObject> fetchLookupValues(List<String> objectAPINames, String searchStr){
        List<Schema.DescribeSObjectResult> sObjectResults = sobjectsFieldsDescribe(objectAPINames);
        String objNameField = 'Name';
        List<sObject> sObjectList = new List<sObject>();


        if(sObjectResults.size() == 2){
            Map<String, Schema.SObjectField> fieldResultMap = sObjectResults[1].fields.getMap();
            String sobject_Type =  sObjectResults[1].getName();

            for(String fld : fieldResultMap.keySet()){
                Schema.DescribeFieldResult fldDescribe = fieldResultMap.get(fld).getDescribe();

                if(fldDescribe.isNameField()){
                    objNameField = fldDescribe.getName();
                    break;
                }
            }

            String queryStr = 'SELECT Id, ' + objNameField + ' FROM '+ sobject_Type ;
            String whereClause = '';
            String lookupObject = objectAPINames[0];

            if(sobject_Type.equalsIgnoreCase('RecordType')){
                whereClause += ' WHERE SobjectType =: lookupObject';
            }

            if(searchStr != null && searchStr != ''){
               
               if(whereClause != ''){
                    whereClause += ' AND ' + objNameField + ' LIKE \'%' +  searchStr + '%\'';           
               }else{
                    whereClause += ' WHERE ' + objNameField + ' LIKE \'%' +  searchStr + '%\''; 
               }
            }

            try{
                
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(sobject_Type, new List<String>{'Id', objNameField}, COMM_SecurityUtils.Access.Accessible)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }

                System.debug(loggingLevel.Info, 'Query String ' + queryStr + whereClause);
                sObjectList = database.query(queryStr + whereClause + ' LIMIT 400');
            
            }catch(Exception ex){
                throw ex;
            }
        }

        return sObjectList;
    }

    public Static void manageSVMXTags(List<String> tagsList, Id entityId){

        /*
         * Below checks to ensure user must have Read, Create and Delete permissions on Tag Defintion 
         * and Tag Element objects to manage Servicemax Tags
         */

        if(!COMM_SecurityUtils.getInstance().isCreateable('SVMXC__SM_Tag_Definition__c') && !COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_Tag_Definition__c', new List<String>{'Id','Name'}, COMM_SecurityUtils.Access.Createable)
            && !COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Tag_Definition__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isCreateable('SVMXC__SM_Tag_Element__c') && !COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_Tag_Element__c', new List<String>{'Id','SVMXC__SM_Tag_Definition__r','SVMXC__SM_Target_Object__c'}, COMM_SecurityUtils.Access.Createable)
            && !COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Tag_Element__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }       
        
        try{
            //Converting to Set to remove duplicate tags
            if(tagsList == null){
                tagsList = new List<String>();
            }
            Set<String> tagsSet = new Set<String>(tagsList);
            Map<String, SVMXC__SM_Tag_Element__c> tagsToDeleteMap = new Map<String, SVMXC__SM_Tag_Element__c>();
            List<SVMXC__SM_Tag_Element__c> tagsToInsert; 

            for(SVMXC__SM_Tag_Element__c tagElement : [SELECT Id, SVMXC__SM_Tag_Definition__r.Name FROM SVMXC__SM_Tag_Element__c WHERE SVMXC__SM_Target_Object__c =: entityId]){

                if(!tagsSet.contains(tagElement.SVMXC__SM_Tag_Definition__r.Name)){ 
                    tagsToDeleteMap.put(tagElement.SVMXC__SM_Tag_Definition__r.Name, tagElement); //Tags to be deleted
                }else{
                    tagsSet.remove(tagElement.SVMXC__SM_Tag_Definition__r.Name); //Remove tags which are already created
                }
            }

            if(!tagsSet.isEmpty()){
                tagsToInsert = new List<SVMXC__SM_Tag_Element__c>();
                
                for(SVMXC__SM_Tag_Definition__c tagDef : [SELECT Id, Name FROM SVMXC__SM_Tag_Definition__c WHERE Name IN : tagsSet]){
                    tagsSet.remove(tagDef.Name);
                    tagsToInsert.add(new SVMXC__SM_Tag_Element__c(SVMXC__SM_Tag_Definition__c = tagDef.Id, SVMXC__SM_Target_Object__c = entityId));
                }
            }

            if(!tagsSet.isEmpty()){
                List<SVMXC__SM_Tag_Definition__c> tagDefList = new List<SVMXC__SM_Tag_Definition__c>();
                
                for(String tagName : tagsSet){
                    SVMXC__SM_Tag_Definition__c tagDef = new SVMXC__SM_Tag_Definition__c(Name = tagName);
                    tagDefList.add(tagDef);
                }

                insert tagDefList;

                if(tagsToInsert == null){
                    tagsToInsert = new List<SVMXC__SM_Tag_Element__c>();
                }
                
                for(SVMXC__SM_Tag_Definition__c tagDef : tagDefList){
                    tagsToInsert.add(new SVMXC__SM_Tag_Element__c(SVMXC__SM_Tag_Definition__c = tagDef.Id, SVMXC__SM_Target_Object__c = entityId));
                }
            }

            if(tagsToInsert != null && !tagsToInsert.isEmpty()){
                insert tagsToInsert;
            }

            if(!tagsToDeleteMap.isEmpty()){
                delete tagsToDeleteMap.values();

                List<SVMXC__SM_Tag_Definition__c> tagDefnDelList = new List<SVMXC__SM_Tag_Definition__c>();

                for(SVMXC__SM_Tag_Definition__c tagDefnRec : [SELECT Id, (SELECT Id from SVMXC__SM_Tag_Elements__r) from SVMXC__SM_Tag_Definition__c WHERE Name IN : tagsToDeleteMap.keySet()]){
                    Integer count = 0;
                    for (SVMXC__SM_Tag_Element__c obj : tagDefnRec.SVMXC__SM_Tag_Elements__r) {
                        count++;
                    }
                    
                    if(count == 0){
                        tagDefnDelList.add(tagDefnRec);
                    }
                }

                if(!tagDefnDelList.isEmpty()){
                    delete tagDefnDelList;
                }
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception occurred while inserting Servicemax Tags :' + ex.getMessage() + ' /n ' + ex.getStackTraceString());
            throw ex;
        }
    }

    public Static Map<String, List<String>> getSVMXTags(List<Id> entityIds){
        Map<String, List<String>> associatedTagsMap = new Map<String, List<String>>();
        
        if(!entityIds.isEmpty()){
            
            for(SVMXC__SM_Tag_Element__c tagElement : [SELECT Id, SVMXC__SM_Target_Object__c, SVMXC__SM_Tag_Definition__r.Name FROM SVMXC__SM_Tag_Element__c WHERE SVMXC__SM_Target_Object__c IN: entityIds ORDER BY SVMXC__SM_Tag_Definition__r.Name]){

                if(tagElement.SVMXC__SM_Target_Object__c != null){ 
                    List<String> tempList = new List<String>();
                    if(associatedTagsMap.containsKey(tagElement.SVMXC__SM_Target_Object__c)){
                        tempList = associatedTagsMap.get(tagElement.SVMXC__SM_Target_Object__c);
                    }
                    tempList.add(tagElement.SVMXC__SM_Tag_Definition__r.Name);
                    associatedTagsMap.put(tagElement.SVMXC__SM_Target_Object__c, tempList);
                }
            }
        }

        return associatedTagsMap;
    }


    public Static Map<String, Map<String, DataTypeAttributesWrapper>> getDataTypeOperatorsMap(){
     
        /*
            Operators
        */
        PickListEntry op_eq = new PickListEntry('eq', System.Label.SFM001_TAG187);
        PickListEntry op_ne = new PickListEntry('ne', System.Label.SFM001_TAG188);
        PickListEntry op_gt = new PickListEntry('gt', System.Label.SFM001_TAG189);
        PickListEntry op_ge = new PickListEntry('ge', System.Label.SFM001_TAG190);
        PickListEntry op_lt = new PickListEntry('lt', System.Label.SFM001_TAG191);
        PickListEntry op_le = new PickListEntry('le', System.Label.SFM001_TAG192);
        PickListEntry op_starts = new PickListEntry('starts', System.Label.SFM001_TAG193);
        PickListEntry op_contains = new PickListEntry('contains', System.Label.SFM001_TAG194);
        PickListEntry op_notcontain = new PickListEntry('notcontain', System.Label.SFM001_TAG195);
        PickListEntry op_in = new PickListEntry('in', System.Label.SFM001_TAG196);
        PickListEntry op_notin = new PickListEntry('notin', System.Label.SFM001_TAG197);
        PickListEntry op_isnull = new PickListEntry('isnull', System.Label.COMM002_TAG022);
        PickListEntry op_isnotnull = new PickListEntry('isnotnull', System.Label.COMM002_TAG023);

        /*
            Literals
        */
        PickListEntry lit_today = new PickListEntry('today', System.label.COMM001_TAG018);
        PickListEntry lit_tomorrow = new PickListEntry('tomorrow', System.label.COMM001_TAG019);
        PickListEntry lit_yesterday = new PickListEntry('yesterday', System.label.COMM001_TAG020);
        PickListEntry lit_now = new PickListEntry('now', System.label.COMM001_TAG021);
        PicklistEntry lit_currentuser = new PickListEntry('currentuser', System.label.COMM001_TAG022);
        PicklistEntry lit_recordowner = new PickListEntry('recordowner', System.label.COMM001_TAG023);
        PicklistEntry lit_geolatitude = new PickListEntry('SVMX.GEOLOCATION.COORDS.LATITUDE', System.label.SFM001_TAG735);
        PicklistEntry lit_geolongitude = new PickListEntry('SVMX.GEOLOCATION.COORDS.LONGITUDE', System.label.SFM001_TAG736);
        PicklistEntry lit_geoaccuracy = new PickListEntry('SVMX.GEOLOCATION.COORDS.ACCURACY', System.label.SFM001_TAG737);


        Map<String, DataTypeAttributesWrapper> sfdcDataTypeOperatorsMap = new Map<String, DataTypeAttributesWrapper>{
            'ID' => new DataTypeAttributesWrapper(new List<PicklistEntry>{op_eq, op_ne, op_isnull, op_isnotnull}, null),
            'REFERENCE' => new DataTypeAttributesWrapper(new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_starts, op_contains, op_notcontain, op_isnull, op_isnotnull}, null),
            'STRING' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_starts, op_contains, op_notcontain, op_isnull, op_isnotnull}, null),
            'BOOLEAN' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne}, null),
            'DOUBLE' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, new List<PicklistEntry>{lit_geolatitude, lit_geolongitude, lit_geoaccuracy}),
            'INTEGER' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, null),
            'PERCENT' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, null),
            'CURRENCY' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, null),
            'DATETIME' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, new List<PicklistEntry>{lit_today, lit_tomorrow, lit_yesterday, lit_now}),
            'DATE' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, new List<PicklistEntry>{lit_today, lit_tomorrow, lit_yesterday}),
            'TIME' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, null),
            'MULTIPICKLIST' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_isnull, op_isnotnull, op_in, op_notin}, null),
            'PICKLIST' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_starts, op_contains, op_notcontain, op_isnull, op_isnotnull}, null),
            'TEXTAREA' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_starts, op_contains, op_notcontain, op_isnull, op_isnotnull}, null),
            'LONGTEXTAREA' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_isnull, op_isnotnull}, null),
            'EMAIL' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_starts, op_contains, op_notcontain, op_isnull, op_isnotnull}, null),
            'PHONE' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, null),
            'URL' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_starts, op_contains, op_notcontain, op_isnull, op_isnotnull}, null),
            'COMBOBOX' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_starts, op_contains, op_notcontain, op_isnull, op_isnotnull}, null)
        };

        Map<String, DataTypeAttributesWrapper> checklistDataTypeOperatorsMap = new Map<String, DataTypeAttributesWrapper>{
            'TEXT' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_contains, op_notcontain, op_isnull, op_isnotnull}, null),
            'NUMBER' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, null),
            'DATETIME' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, new List<PicklistEntry>{lit_today, lit_tomorrow, lit_yesterday, lit_now}),
            'DATE' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_gt, op_ge, op_lt, op_le, op_isnull, op_isnotnull}, new List<PicklistEntry>{lit_today, lit_tomorrow, lit_yesterday}),
            'PICKLIST' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_isnull, op_isnotnull}, null),
            'RADIOBUTTON' => new DataTypeAttributesWrapper( new List<PicklistEntry>{op_eq, op_ne, op_isnull, op_isnotnull}, null)
        };
        Map<String, Map<String, DataTypeAttributesWrapper>> entityOperatorsMap = new Map<String, Map<String, DataTypeAttributesWrapper>>{
            'SFDC' => sfdcDataTypeOperatorsMap,
            'SMAX' => checklistDataTypeOperatorsMap
        };
        return entityOperatorsMap;
    }


    public Static boolean isEntityNameAlreadyUsed(String entityName, String entityType, String excludeId){
        entityName = entityName.trim();

        String queryStr = 'SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Name__c =: entityName ';

        if(entityType == entity_sfm){

            queryStr += ' AND RecordType.Name = \'Target Manager\' AND SVMXC__Purpose__c NOT IN ( \'CHECKLIST\', \'OUTPUT DOCUMENT\')';
        }else if(entityType == entity_checklist){
            queryStr += ' AND RecordType.Name = \'Target Manager\' AND SVMXC__Purpose__c = \'CHECKLIST\'';
        }else if(entityType == entity_opdoc){
            queryStr += ' AND RecordType.Name = \'Target Manager\' AND SVMXC__Purpose__c = \'OUTPUT DOCUMENT\'';
        }else if(entityType == entity_expression){

            queryStr += ' AND RecordType.Name = \'SVMX Rule\'';
        }else if(entityType == entity_businessrule){
            
            queryStr += ' AND RecordType.Name = \'Business Rule\' AND SVMXC__Rule_Type__c = NULL';
        }else if(entityType == entity_sectionEntryCriteria){
            queryStr += ' AND Recordtype.Name = \'Business Rule\' AND SVMXC__Rule_Type__c = \'Checklist_Section_Entry_Criteria\'';
        }else if(entityType == entity_formula){
            
            queryStr += ' AND RecordType.Name = \'Business Rule\' AND SVMXC__Rule_Type__c = \'Field Update Rule\'';
        }else if(entityType == entity_mapping){
            
            queryStr += ' AND RecordType.Name = \'Object Mapping\'';
        }else if(entityType == entity_lkpConfig){

            queryStr += ' AND RecordType.Name = \'Named Search\' AND SVMXC__Rule_Type__c = \'SRCH_LOOKUP_CONFIG\'';
        }else if(entityType == entity_layout){

            queryStr = 'SELECT Id FROM SVMXC__Page_Layout__c WHERE SVMXC__Name__c =: entityName AND SVMXC__Type__c = \'Header\'';
        }else if(entityType == entity_template){

            queryStr = 'SELECT Id FROM SVMXC__Doc_Template__c WHERE SVMXC__Name__c =: entityName';
        }else {
            return false;
        }

        if(excludeId != null){
            queryStr += ' AND Id !=: excludeId'; 
        }

        try{
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Name__c', 'RecordType.Name', 'SVMXC__Rule_Type__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Page_Layout__c', new List<String>{'Id', 'SVMXC__Name__c', 'SVMXC__Type__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Doc_Template__c', new List<String>{'Id', 'SVMXC__Name__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            System.debug(loggingLevel.info, ' Query String to Execute : ' + queryStr + ' excludeId : ' + excludeId);
            List<sObject> sObjectList = Database.query(queryStr);
            if(!sObjectList.isEmpty()){
                return true;
            }
        }catch(Exception ex){
            throw ex;
        }              

        return false;
    }

    public Static List<SFM_WrapperDef.FieldsetDefinition> getFieldSetDefition(List<String> sObjectsAPIs){
        
        List<SFM_WrapperDef.FieldsetDefinition> fsDefnList;
        
        if(sObjectsAPIs != null && !sObjectsAPIs.isEmpty()){
            
            fsDefnList = new List<SFM_WrapperDef.FieldsetDefinition>();
            for(Schema.DescribeSobjectResult sObjDescribeResult : sobjectsFieldsDescribe(sObjectsAPIs)){
                
                List<SFM_WrapperDef.FieldSetInfo> fsInfoList = new List<SFM_WrapperDef.FieldSetInfo>();
                Map<String, Schema.FieldSet> fsMap = sObjDescribeResult.fieldSets.getMap();
                
                for(String fsKey : fsMap.keySet()){
                    SFM_WrapperDef.FieldSetInfo fsInfo = new SFM_WrapperDef.FieldSetInfo(fsMap.get(fsKey).getName(), fsMap.get(fsKey).getLabel());
                    fsInfo.fieldSetDescription = fsMap.get(fsKey).getDescription();
                    fsInfoList.add(fsInfo);
                }

                SFM_WrapperDef.FieldsetDefinition flsDefn = new SFM_WrapperDef.FieldsetDefinition(sObjDescribeResult.getName(), fsInfoList);
                fsDefnList.add(flsDefn);

            }

        }

        return fsDefnList;
    }   

    /**
     * This method is used to retrieve all the configured code snippets in the org 
     * 
     * @return List of code snippets wrapped with the details like Name, Code snippet Id, Created and Modified user info.
     * 
     */
    public Static List<SFM_WrapperDef2.SFM2_EntityDetail> getCodeSnippets(){
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Code_Snippet__c', new List<String>{'Id', 'SVMXC__IsStandard__c', 'SVMXC__SnippetId__c', 'SVMXC__Name__c', 'CreatedBy.Name', 'LastModifiedBy.Name', 'LastModifiedDate', 'CreatedDate'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }  

        List<SFM_WrapperDef2.SFM2_EntityDetail> codeSnippetWrapperList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
        for(SVMXC__Code_Snippet__c codeSnippetRecord : [SELECT Id, SVMXC__IsStandard__c, SVMXC__SnippetId__c, SVMXC__Name__c, CreatedBy.Name, LastModifiedBy.Name, LastModifiedDate, CreatedDate FROM SVMXC__Code_Snippet__c WHERE SVMXC__Name__c != NULL ORDER BY SVMXC__SnippetId__c]){

            SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
            entityDetail.entityId = codeSnippetRecord.Id;
            entityDetail.isStandard = codeSnippetRecord.SVMXC__IsStandard__c;
            entityDetail.entityName = codeSnippetRecord.SVMXC__SnippetId__c + ': ' + codeSnippetRecord.SVMXC__Name__c;
            entityDetail.lastModifiedDate = String.valueOfGmt(codeSnippetRecord.LastModifiedDate);
            entityDetail.createdDate = String.valueOfGmt(codeSnippetRecord.CreatedDate);
            entityDetail.createdBy = codeSnippetRecord.CreatedBy.Name;
            entityDetail.lastModifiedBy = codeSnippetRecord.LastModifiedBy.Name;
            codeSnippetWrapperList.add(entityDetail);
        }

        return codeSnippetWrapperList;
    }

    /**
     * This method is used to retrieve custom actions for the given object 
     * 
     * @return List of custom actions wrapped with the details like Name, Custom Action Id, Created and Modified user info.
     * 
     */
    public Static Map<String, List<SFM_WrapperDef2.SFM2_EntityDetail>> getCustomActions( final List<String> sObjectTypes ){
        
        System.debug( System.LoggingLevel.DEBUG, 'getCustomActions() - enter; sObjectType=' + sObjectTypes );
        Map<String, List<SFM_WrapperDef2.SFM2_EntityDetail>> customActionsWrapperMap;
        try {
            // Validate sObjectType for valid string.
            if ( sObjectTypes != null && sObjectTypes.size() > 0 ) {
                
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Name__c', 'SVMXC__Source_Object_Name__c', 'CreatedBy.Name', 'LastModifiedBy.Name', 'LastModifiedDate', 'CreatedDate', 'RecordType.Name'}, COMM_SecurityUtils.Access.Accessible)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }

                customActionsWrapperMap = new Map<String, List<SFM_WrapperDef2.SFM2_EntityDetail>> ();
                for(SVMXC__ServiceMax_Processes__c customActionRecord : [SELECT Id, SVMXC__Name__c, SVMXC__Source_Object_Name__c, CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'SF Action' AND SVMXC__Source_Object_Name__c IN: sObjectTypes 
                                                                           ORDER BY SVMXC__Name__c ASC]){
                    List<SFM_WrapperDef2.SFM2_EntityDetail> tempList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                    if(customActionsWrapperMap.containsKey(customActionRecord.SVMXC__Source_Object_Name__c)){
                        tempList = customActionsWrapperMap.get(customActionRecord.SVMXC__Source_Object_Name__c);
                    }

                    SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
                    entityDetail.entityId = customActionRecord.Id;
                    entityDetail.entityName = customActionRecord.SVMXC__Name__c;
                    entityDetail.lastModifiedDate = String.valueOfGmt(customActionRecord.LastModifiedDate);
                    entityDetail.createdDate = String.valueOfGmt(customActionRecord.CreatedDate);
                    entityDetail.createdBy = customActionRecord.CreatedBy.Name;
                    entityDetail.lastModifiedBy = customActionRecord.LastModifiedBy.Name;
                    tempList.add(entityDetail);

                    customActionsWrapperMap.put(customActionRecord.SVMXC__Source_Object_Name__c, tempList);
                }

            }
        }catch( Exception e ) {
            System.debug( System.LoggingLevel.ERROR, e.getMessage() );
        }finally {
            System.debug( System.LoggingLevel.DEBUG, 'getCustomActions() - exit');
        }

        return customActionsWrapperMap;
    }

    public Static List<SFM_WrapperDef2.SFM2_Function> getSFMFunctions(String entityType){
        entityType = entityType != null ? entityType: entity_formula;
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Function_Definition__c', new List<String>{'Id', 'SVMXC__IsStandard__c', 'SVMXC__IsActive__c', 'SVMXC__Description__c', 'SVMXC__Example__c', 'SVMXC__Syntax__c',
                'SVMXC__Type__c', 'SVMXC__Macro_Id__c', 'SVMXC__Macro_Name__c', 'CreatedBy.Name', 'LastModifiedBy.Name', 'LastModifiedDate', 'CreatedDate'}, COMM_SecurityUtils.Access.Accessible)){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }  

        /* Set<String> supportedMacrosSet = new Set<String>();
        if(entityMacrosMap.containsKey(entityType)){
            supportedMacrosSet = entityMacrosMap.get(entityType);
        } */

        List<SFM_WrapperDef2.SFM2_Function> smaxFunctionsList = new List<SFM_WrapperDef2.SFM2_Function>();
        List<SVMXC__Function_Definition__c> functionsList = [SELECT Id, SVMXC__IsStandard__c, SVMXC__SM_Entity_Type__c, SVMXC__IsActive__c, SVMXC__Description__c, SVMXC__Example__c, SVMXC__Syntax__c, toLabel(SVMXC__Type__c), SVMXC__Macro_Id__c, SVMXC__Macro_Name__c, CreatedBy.Name,
                                                                LastModifiedBy.Name, LastModifiedDate, CreatedDate FROM SVMXC__Function_Definition__c WHERE SVMXC__IsActive__c = true AND SVMXC__SM_Entity_Type__c INCLUDES (:entityType) ORDER BY SVMXC__IsStandard__c DESC];

        // functionsList.addAll(functionsMap.values());
        if(entityType.equalsIgnoreCase(entity_opdoc)){
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('Document', new List<String>{'Id', 'Name', 'Description', 'DeveloperName', 'ContentType', 'Keywords'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            for(Document docRecord : [SELECT Id, Name, Description, DeveloperName FROM Document WHERE (ContentType = 'Image/png' OR  ContentType = 'Image/jpeg' OR ContentType = 'Image/gif')
                                      AND Keywords LIKE '%SFM_Output_Document%']){
                SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
                entityDetail.entityId = docRecord.Id;
                entityDetail.isStandard = false;
                entityDetail.entityName = docRecord.Name;
                entityDetail.entityDescription = docRecord.Description;
                entityDetail.entityStatus = 'true';
                SFM_WrapperDef2.SFM2_Function functionDetail = new SFM_WrapperDef2.SFM2_Function();
                functionDetail.functionId = docRecord.DeveloperName;
                functionDetail.syntax = '$F.IMAGE(\'LogoName\')';
                functionDetail.macroType = 'IMAGE';
                functionDetail.macroName = docRecord.Name;
                smaxFunctionsList.add(functionDetail);
            }
        }
        for(SVMXC__Function_Definition__c functionRecord : functionsList){

            if(functionRecord.SVMXC__Macro_Name__c != null /* && supportedMacrosSet.contains(functionRecord.SVMXC__Macro_Name__c)*/ ){
                SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
                entityDetail.entityId = functionRecord.Id;
                entityDetail.isStandard = functionRecord.SVMXC__IsStandard__c;
                entityDetail.entityName = functionRecord.SVMXC__Macro_Name__c;
                entityDetail.entityDescription = functionRecord.SVMXC__Description__c;
                entityDetail.entityStatus = String.valueOf(functionRecord.SVMXC__IsActive__c);
                /*entityDetail.lastModifiedDate = String.valueOfGmt(functionRecord.LastModifiedDate);
                entityDetail.createdDate = String.valueOfGmt(functionRecord.CreatedDate);
                entityDetail.createdBy = functionRecord.CreatedBy.Name;
                entityDetail.lastModifiedBy = functionRecord.LastModifiedBy.Name;*/
                
                SFM_WrapperDef2.SFM2_Function functionDetail = new SFM_WrapperDef2.SFM2_Function();
                functionDetail.functionId = functionRecord.SVMXC__Macro_Id__c;
                functionDetail.syntax = functionRecord.SVMXC__Syntax__c;
                functionDetail.example = functionRecord.SVMXC__Example__c;
                functionDetail.macroType = functionRecord.SVMXC__Type__c;
                functionDetail.macroName = functionRecord.SVMXC__Macro_Name__c;                                              
                smaxFunctionsList.add(functionDetail);
            }
        }

        return smaxFunctionsList;
    }   

    class DataTypeAttributesWrapper{
        public List<PickListEntry> operators;
        public List<PickListEntry> literals;
        public DataTypeAttributesWrapper(List<PickListEntry> operators, List<PickListEntry> literals){
            this.operators = operators;
            this.literals = literals;
        }
    } 

    class PicklistEntry{
        public String value;
        public String label;
        public PicklistEntry(String value, string label){
            this.value = value;
            this.label = label;
        }
    }    
}