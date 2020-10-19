Global with sharing class WSCH_FieldMatchRuleEngine {
    
    public map<Id, SVMXC__ServiceMax_Processes__c> mapFieldMatchRuleProcess = new map<Id, SVMXC__ServiceMax_Processes__c>();
    public map<Id, SVMXC__ServiceMax_Config_Data__c> mapFieldMatchRuleExpression = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
    public map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapRuleEntryCriteria = new map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
    public map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapRuleMatchFields = new map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
    
    public map<String, List<SVMXC__ServiceMax_Processes__c>> mapTargetRuleProcess = new map<String, List<SVMXC__ServiceMax_Processes__c>>();
    public map<String, List<SObject>> mapLookupObjData = new map<String, List<SObject>>();
    public Set<Id> objMapIds = new Set<Id>();
    public map<Id, SVMXC__ServiceMax_Config_Data__c> mapObjectMapConfig = new map<Id, SVMXC__ServiceMax_Config_Data__c>();
    public map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapFieldAssignments = new map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
    
    public COMM_SVMXC_Utils4 oUtils = new COMM_SVMXC_Utils4();
    
    public SVMXC.SFM_validateExpression ValidateExp = new SVMXC.SFM_validateExpression();
    public SVMXC.SFM_WrapperDef.SFM_Response Save_Response = new SVMXC.SFM_WrapperDef.SFM_Response();  
    
    public static String sourceName;
    
    global WSCH_FieldMatchRuleEngine(){
        
    }
    
    public void initialiseFieldMatchingRules()
    {
    try{
            WSCH_AuditLogger.debug('Start of Field Match Rule Section: No of Queries used in this transaction so far: ' + Limits.getQueries());
            WSCH_AuditLogger.debug('Start of Field Match Rule Section: Heap size used in this transaction so far: ' + getHeapSizeInMB()+' KB');
            //get all the svmx rule based on the rule type 'Field Match Rule'.
            mapFieldMatchRuleProcess = WSCH_CommonUtils.fetchRules(WSCH_Constants.STR_RULE_TYPE, WSCH_FieldMatchRuleEngine.sourceName);
            WSCH_AuditLogger.debug('mapFieldMatchRuleProcess size : '+mapFieldMatchRuleProcess.size());
            
            //shifted this below code from WSCH_TriggerHandler as part of Defect 042837
            String strConfigLimit = WSCH_CommonUtils.getSettingValue('GLOB001','GBL026');
            if(strConfigLimit == null || Integer.valueOf(strConfigLimit) <= 0) {
                strConfigLimit = '1000';
            }
            
            if(mapFieldMatchRuleProcess.size() > 0) {
                //Aggregate by target objects
                WSCH_AuditLogger.debug('Limit value from config setting for quering lookup object : strConfigLimit ' + strConfigLimit);
                for(SVMXC__ServiceMax_Processes__c oPro: mapFieldMatchRuleProcess.values()){
                    if(oPro.SVMXC__Target_Object_Name__c != null){
                        if(!mapTargetRuleProcess.ContainsKey(oPro.SVMXC__Target_Object_Name__c)){
                            mapTargetRuleProcess.put(oPro.SVMXC__Target_Object_Name__c, new List<SVMXC__ServiceMax_Processes__c>());
                            
                            //fetch all the records from this target object for matching
                            mapLookupObjData.put(oPro.SVMXC__Target_Object_Name__c, new List<SObject>());
                            List<SObject> lookupObjects = new List<SObject>();
                            String queryFlds = getQueryFields(oPro.SVMXC__Target_Object_Name__c);
                            WSCH_AuditLogger.debug('Start Fetch '+oPro.SVMXC__Target_Object_Name__c+' data: Heap size used in this transaction so far: ' + getHeapSizeInMB()+' KB');
                            WSCH_AuditLogger.debug('Mapping Object '+oPro.SVMXC__Target_Object_Name__c+' Order by field '+oPro.SVMXC__Field_Name__c);
                            if(oPro.SVMXC__Field_Name__c != null && oPro.SVMXC__Field_Name__c !='' && oPro.SVMXC__Field_Name__c != 'SVMX.None'){
                                lookupObjects = database.query('Select '+ queryFlds + ' From ' +oPro.SVMXC__Target_Object_Name__c +' order by '+oPro.SVMXC__Field_Name__c+' limit '+strConfigLimit);  
                            }else{
                                lookupObjects = database.query('Select '+ queryFlds + ' From ' +oPro.SVMXC__Target_Object_Name__c +' limit '+strConfigLimit);
                            }
                            
                            mapLookupObjData.get(oPro.SVMXC__Target_Object_Name__c).addAll(lookupObjects);
                        }
                        mapTargetRuleProcess.get(oPro.SVMXC__Target_Object_Name__c).add(oPro);
                    }
                    //fetch all the Object Mapping SFID
                    objMapIds.add(oPro.SVMXC__Process__c);
                }
                WSCH_AuditLogger.debug('Aggregate by target objects::mapTargetRuleProcess size : '+mapTargetRuleProcess.size());
                WSCH_AuditLogger.debug('Lookup Object Data size : '+mapLookupObjData.size());
                WSCH_AuditLogger.debug('Mapping Process Ids : '+objMapIds);
                
                
                // Get the expression rows for all the rules identified above.
                mapFieldMatchRuleExpression.putAll([SELECT Id, RecordType.Name, SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Display_Value__c, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c,SVMXC__Preference_2__c,SVMXC__Preference_3__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN :mapFieldMatchRuleProcess.KeySet() order by SVMXC__Sequence__c]);
                WSCH_AuditLogger.debug('Get the expression rows for all the rules::mapFieldMatchRuleExpression size : '+mapFieldMatchRuleExpression.size());
                WSCH_AuditLogger.debug('Get the expression rows for all the rules: Heap size used in this transaction so far: ' + getHeapSizeInMB()+' KB');
                // Get the field map rows for all the object map identified above.
                
                mapObjectMapConfig.putAll([SELECT Id, RecordType.Name, SVMXC__MapID__c, SVMXC__Configuration_Type__c, SVMXC__Display_Type__c, SVMXC__Parameter_Type__c, SVMXC__Parameter_Value__c, SVMXC__Display_Value__c, SVMXC__Source_Field_Name__c, SVMXC__Target_Field_Name__c,SVMXC__Preference_2__c,SVMXC__Preference_3__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name='Field Mapping' AND SVMXC__MapID__c IN :objMapIds]);
                WSCH_AuditLogger.debug('Get the mapping config for all MapID: Heap size used in this transaction so far: ' + getHeapSizeInMB()+' KB');
                for(SVMXC__ServiceMax_Config_Data__c oExp: mapFieldMatchRuleExpression.values())
                {
                    //entry criteria
                    if(oExp.SVMXC__Expression_Type__c == 'Field Match Expression') {
                        if(!mapRuleEntryCriteria.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                            mapRuleEntryCriteria.put(oExp.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                        mapRuleEntryCriteria.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                    }
                
                    //create map for field matching details
                    if(oExp.SVMXC__Expression_Type__c == 'Field Match Lookup') {
                        if(!mapRuleMatchFields.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                            mapRuleMatchFields.put(oExp.SVMXC__Expression_Rule__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                        mapRuleMatchFields.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                    }
                    
                }
                
                for(SVMXC__ServiceMax_Config_Data__c fieldMapObj : mapObjectMapConfig.values())
                {
                    //create map for field assignments details
                    if(fieldMapObj.SVMXC__Configuration_Type__c == 'Field Mapping') {
                        if(!mapFieldAssignments.ContainsKey(fieldMapObj.SVMXC__MapID__c)) {
                            mapFieldAssignments.put(fieldMapObj.SVMXC__MapID__c, new List<SVMXC__ServiceMax_Config_Data__c>());
                        }
                        mapFieldAssignments.get(fieldMapObj.SVMXC__MapID__c).add(fieldMapObj);
                    }           
                }
                WSCH_AuditLogger.debug('mapFieldAssignments size : '+mapFieldAssignments.size());
                WSCH_AuditLogger.debug('End of Constructor : Heap size used in this transaction so far: ' + getHeapSizeInMB()+' KB');
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_FieldMatchRuleEngine :: initialiseFieldMatchingRules() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());          
        }
    }
    
    global void processFieldMatchingRules(List<SObject> SObjects){
        try{
            if(SObjects == null) {
                WSCH_AuditLogger.debug('Parameter list is null');
                return;
            }
            
            WSCH_FieldMatchRuleEngine.sourceName = String.valueOf(SObjects.getSObjectType());
            //WSCH_AuditLogger.debug('Inside processFieldMatchingRules(), WSCH_FieldMatchRuleEngine.sourceName - ' + WSCH_FieldMatchRuleEngine.sourceName);
            initialiseFieldMatchingRules();
            for(SObject sObj : SObjects){
                WSCH_AuditLogger.debug('Start of Processing Rule for workorder wise: No of Queries used in this transaction so far: ' + Limits.getQueries());
                WSCH_AuditLogger.debug('Start of Processing Rule for workorder wise : Heap size used in this transaction so far: ' + getHeapSizeInMB()+' KB');
                //loop through target object maps
                for(String targetObject :mapTargetRuleProcess.keyset()){
                    WSCH_AuditLogger.debug('targetObject : ' + targetObject);
                    List<SVMXC__ServiceMax_Processes__c> lstProcess = mapTargetRuleProcess.get(targetObject);
                    WSCH_AuditLogger.debug('No of Rules : ' + lstProcess.size());
                    
                    //To implement a custom sort order for SVMXC__ServiceMax_Processes__c in lists by Sequence
                    List<processDataWrapper> processDatawrappers = new List<processDataWrapper>();
                    for(SVMXC__ServiceMax_Processes__c processData : lstProcess){
                        processDatawrappers.add(new processDataWrapper(processData));
                    }
                    processDatawrappers.sort();
                    lstProcess.clear();
                    
                    for(processDataWrapper processWrapper : processDatawrappers){
                        lstProcess.add(processWrapper.processData);
                    }                       
                    //loop through each target object rules
                    for(SVMXC__ServiceMax_Processes__c processObj : lstProcess ){
                        WSCH_AuditLogger.debug('Start Rule :' + processObj.SVMXC__Name__c);
                        String strSourceObj = processObj.SVMXC__Source_Object_Name__c;
                        String strTargetObj = processObj.SVMXC__Target_Object_Name__c;
                        WSCH_AuditLogger.debug('Source : '+strSourceObj+'- Target :'+strTargetObj); 
                        
                        //WSCH_AuditLogger.debug('Inside Processes for loop - processObj' + processObj);                
                        
                        //1. To validate the entry criteria
                        List<SVMXC__ServiceMax_Config_Data__c> entryCriteriaExpressions = mapRuleEntryCriteria.get(processObj.Id);
                        //WSCH_AuditLogger.debug('Entry Criteria : '+entryCriteriaExpressions);
                        if(entryCriteriaExpressions == null){
                            continue;
                        }
                        if(!oUtils.SVMX_ExpressionParsing(sObj, entryCriteriaExpressions, processObj.SVMXC__Advance_Expression__c,true)){
                            continue;
                        }
                        WSCH_AuditLogger.debug('ruleId : ' + processObj.Id);
                        
                        List<SVMXC__ServiceMax_Config_Data__c> matchingExpressions = mapRuleMatchFields.get(processObj.Id);
                        if(matchingExpressions == null){
                            continue;
                        }
    
                        //To implement a custom sort order for SVMXC__ServiceMax_Config_Data__c in lists by Sequence
                        List<configDataWrapper> cfgDatawrappers = new List<configDataWrapper>();
                        for(SVMXC__ServiceMax_Config_Data__c cfgData : matchingExpressions){
                            cfgDatawrappers.add(new configDataWrapper(cfgData));
                        }
                        cfgDatawrappers.sort();
                        matchingExpressions.clear();
                        
                        for(configDataWrapper cfgWrapper : cfgDatawrappers){
                            matchingExpressions.add(cfgWrapper.cfgData);
                        }   
                        
                        String strAdvExp = processObj.SVMXC__Primary_Consolidation_Rule__c;
                        WSCH_AuditLogger.debug('Advance Exp for Matching : '+strAdvExp);
                        
                        //2. To validate matching expressions
                        String sourceRecId;
                        SObject lookupObject;
                        for(SObject lookupObj :mapLookupObjData.get(targetObject)){
                            if(processMatchingExpressions(matchingExpressions,sObj,lookupObj,strAdvExp)){
                                lookupObject = lookupObj;
                                sourceRecId=String.valueOf(lookupObj.get('Id'));
                                break;
                            }
                        }
                        
                        //3. To assign score and weight 
                        
                        //If matching found then start assignment process
                          if(sourceRecId != null){
                            String lookupObject_Source_Field_Name = '';
                            for(SVMXC__ServiceMax_Config_Data__c cfgData : mapFieldAssignments.get(processObj.SVMXC__Process__c)){

                                WSCH_AuditLogger.debug('Parameter Type - ' + cfgData.SVMXC__Parameter_Type__c);
                                if(cfgData.SVMXC__Parameter_Type__c =='Field Value'){
                                    /*Check for Additional Mapping*/
                                    lookupObject_Source_Field_Name = getAdditionalMap(lookupObject, cfgData);
                                     WSCH_AuditLogger.debug('Assignments ::Parameter Type - Field Name: '+lookupObject_Source_Field_Name);
                                    if(String.isNotBlank(lookupObject_Source_Field_Name)){
                                        WSCH_AuditLogger.debug('Value is : ' +lookupObject.get(lookupObject_Source_Field_Name));
                                        sObj.put(cfgData.SVMXC__Target_Field_Name__c,lookupObject.get(lookupObject_Source_Field_Name));
                                    }
                                }
                                else if(cfgData.SVMXC__Parameter_Type__c =='Constant' || cfgData.SVMXC__Parameter_Type__c =='Value'){
                                    WSCH_AuditLogger.debug('Parameter Type - ' + cfgData.SVMXC__Parameter_Type__c + '  Assignments ::SVMXC__Display_Value__c - ' + cfgData.id +' ' + cfgData.SVMXC__Display_Value__c);
                                    sObj = mapLiteral(sObj, cfgData);
                                }
                                /*else if(cfgData.SVMXC__Parameter_Type__c =='Value'){
                                    WSCH_AuditLogger.debug('Assignments :: Parameter Type - Value: ' +cfgData.SVMXC__Display_Value__c);
                                    if(cfgData.SVMXC__Display_Value__c != 'true'){
                                        sObj.put(cfgData.SVMXC__Target_Field_Name__c,cfgData.SVMXC__Display_Value__c);  
                                    }else {
                                        boolean isRuleExecuted=true;
                                        sObj.put(cfgData.SVMXC__Target_Field_Name__c,isRuleExecuted);
                                    }
                                    
                                }*/
                                /*TO DO - Handle SERVICEMAX SETTING Type Mapping */
                            }
                        }
                    }
                }
                WSCH_AuditLogger.debug('End of Processing Rule for workorder wise:: No of Queries used in this transaction so far: ' + Limits.getQueries());
                WSCH_AuditLogger.debug('End of Processing Rule for workorder wise : Heap size used in this transaction so far: ' + getHeapSizeInMB()+' KB');    
            }
        WSCH_AuditLogger.debug('End of Field Match Rule Section: No of Queries used in this transaction so far: ' + Limits.getQueries());
        WSCH_AuditLogger.debug('End of Field Match Rule Section : Heap size used in this transaction so far: ' + getHeapSizeInMB()+' KB');
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_FieldMatchRuleEngine :: processFieldMatchingRules() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());          
        }
    }
    
    public Boolean processMatchingExpressions(List<SVMXC__ServiceMax_Config_Data__c> matchExpressions,SObject srcObject,SObject lookupObject,String strMatchAdvExp){
        //appending operand field for build where clause for query 
        boolean isMatch=false, isOperandNotEmpty=true;
        try{
            for(SVMXC__ServiceMax_Config_Data__c expression : matchExpressions){
                expression.SVMXC__Operand__c = expression.SVMXC__Display_Value__c;
                if(expression.SVMXC__Target_Field_Name__c != NULL && srcObject.get(expression.SVMXC__Target_Field_Name__c) != NULL)
                {
                    expression.SVMXC__Operand__c = String.valueOf(srcObject.get(expression.SVMXC__Target_Field_Name__c));
                }
                if(expression.SVMXC__Operand__c != null){
                    isOperandNotEmpty=false;
                }
            }
            //expression parsing
            if(!isOperandNotEmpty){
                isMatch = oUtils.SVMX_ExpressionParsing(lookupObject, matchExpressions, strMatchAdvExp,true);
                WSCH_AuditLogger.debug('Matching is : '+isMatch);
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_FieldMatchRuleEngine :: processMatchingExpressions() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());          
        }
        return isMatch;     
    }   
    
    public string getQueryFields(String objName){
        String strFlds = '';
        try {
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> mapOfFields = gd.get(objName).getDescribe().fields.getMap();
            List<String> lstOfKeys = new List<String>(mapOfFields.keySet());
            lstOfKeys.sort();
            for(String key : lstOfKeys)  
            {  
                Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();  
                if(fieldResult.isAccessible() && String.ValueOf(fieldResult.getType()) != 'TEXTAREA')  
                {  
                    if(strFlds.length() > 0)
                        strFlds += ',';
                    strFlds += fieldResult.getName();
                }  
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_FieldMatchRuleEngine :: getQueryFields() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return strFlds;
    }
        
    public class configDataWrapper implements Comparable {

        public SVMXC__ServiceMax_Config_Data__c cfgData = new SVMXC__ServiceMax_Config_Data__c();
        
        // Constructor
        public configDataWrapper(SVMXC__ServiceMax_Config_Data__c cfgRecord) {
            cfgData = cfgRecord;
        }
        
        // Compare ConfigData based on the SVMXC__Sequence__c.
        public Integer compareTo(Object compareTo) {
            // Cast argument to MemberWrapper
            configDataWrapper compareTocfgData = (configDataWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (cfgData.SVMXC__Sequence__c > compareTocfgData.cfgData.SVMXC__Sequence__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (cfgData.SVMXC__Sequence__c < compareTocfgData.cfgData.SVMXC__Sequence__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    public class processDataWrapper implements Comparable {

        public SVMXC__ServiceMax_Processes__c processData = new SVMXC__ServiceMax_Processes__c();
        
        // Constructor
        public processDataWrapper(SVMXC__ServiceMax_Processes__c processRecord) {
            processData = processRecord;
        }
        
        // Compare ConfigData based on the SVMXC__Sequence__c.
        public Integer compareTo(Object compareTo) {
            // Cast argument to MemberWrapper
            processDataWrapper compareToProcessData = (processDataWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (processData.SVMXC__Sequence__c > compareToProcessData.processData.SVMXC__Sequence__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (processData.SVMXC__Sequence__c < compareToProcessData.processData.SVMXC__Sequence__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    public double getHeapSizeInMB(){
        Double heapSize=0.0;
        heapSize = Double.valueOf(Limits.getHeapSize()/1024);
        return heapSize;
    }
    
    public sObject mapLiteral(sObject sObjRec, SVMXC__ServiceMax_Config_Data__c sfmMap)
    {
        try{
        WSCH_AuditLogger.debug('WSCH_FieldMatchRuleEngine :: mapLiteral() : sfmMap.id - ' + sfmMap.id + ' sObjRec - ' + sObjRec.id);                            
        WSCH_AuditLogger.debug('sfmMap.SVMXC__Display_Value__c ' + sfmMap.SVMXC__Display_Value__c);
        WSCH_AuditLogger.debug('sfmMap.SVMXC__Target_Field_Name__c ' + sfmMap.SVMXC__Target_Field_Name__c);

        Sobject objCurrentRecHeader = null;
        //Describe the field to check different attributes of fields..
        SObjectType soType = sObjRec.getsObjectType();
        Schema.DescribeSObjectResult dsor = soType.getDescribe();
        Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
        String sfmMap_tgt_fld_name = sfmMap.SVMXC__Target_Field_Name__c;
        /*TRIM the field name to remove the NAMESPACE*/
        //below code has been commented to fix the defect 042837. If the matching object criteria fields in the data lookup rules
        //have namespace, data lookup rule fails because of the below code. As this code is trimming the namespace and this field
        // without namespace does not match with any of the fields in Sobject describe.
        /*if(sfmMap.SVMXC__Target_Field_Name__c.countMatches('__')>1){
            sfmMap_tgt_fld_name = sfmMap.SVMXC__Target_Field_Name__c.split('__',2)[1];
        }*/
        Schema.DescribeFieldResult f = objectFields.get(sfmMap_tgt_fld_name).getDescribe();
        //Check for the ServiceMax Constants..
        if(sfmMap.SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORD.')){
            list<String> lstString = new list<String>();
            lstString = sfmMap.SVMXC__Display_Value__c.split('SVMX.CURRENTRECORD.');
            if(lstString.size() > 0)
                sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,sObjRec.get(lstString[1]));
        }
        else if(sfmMap.SVMXC__Display_Value__c.contains('SVMX.CURRENTRECORDHEADER.')){
            list<String> lstString = new list<String>();
            lstString = sfmMap.SVMXC__Display_Value__c.split('SVMX.CURRENTRECORDHEADER.');
            if(lstString.size() > 0  && objCurrentRecHeader != null)
                sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,objCurrentRecHeader.get(lstString[1]));
        }
        else if(sfmMap.SVMXC__Display_Value__c.contains('SVMX.CURRENTUSERID')){
            sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,userinfo.getUserId());
        }
        else if(sfmMap.SVMXC__Display_Value__c.contains('SVMX.USERTRUNK')){
            SVMXC.SVMX_Constant_Utils constantUtils = new SVMXC.SVMX_Constant_Utils();
            sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,constantUtils.getSVMXUserTrunkId());
        }
        else{
            if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isUpdateable()){//if Field Type is Double,persent,currency 
                if(double.valueOf(sfmMap.SVMXC__Display_Value__c) != null ){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,double.valueOf(sfmMap.SVMXC__Display_Value__c));
                }   
            }
            else if(f.getType() == schema.Displaytype.Integer && f.isUpdateable()){//if field type is Integer
                if(Integer.valueof(sfmMap.SVMXC__Display_Value__c)!= null){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,Integer.valueof(sfmMap.SVMXC__Display_Value__c));
                }   
            }
            else if(f.getType() == schema.Displaytype.Boolean && f.isUpdateable()){//if field type is Boolean
                if(Boolean.valueof(sfmMap.SVMXC__Display_Value__c)!= null){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,Boolean.valueof(sfmMap.SVMXC__Display_Value__c));
                }   
            }
            else if(f.getType() == schema.Displaytype.DateTime && f.isUpdateable()){//if field type is DateTime
                if(sfmMap.SVMXC__Display_Value__c.touppercase() == 'TODAY'){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));//date.valueof(string.valueof(system.today()))
                }                                    
                else if(sfmMap.SVMXC__Display_Value__c.touppercase() == 'YESTERDAY'){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));//date.valueof(string.valueof(system.today()-1))
                }       
                else if(sfmMap.SVMXC__Display_Value__c.touppercase() == 'TOMORROW'){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));//date.valueof(string.valueof(system.today()+1))
                }
                else if(sfmMap.SVMXC__Display_Value__c.touppercase() == 'NOW'){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,system.now());
                }
                else{           
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,DateTime.valueof(sfmMap.SVMXC__Display_Value__c));
                }
                        
            }
            else if(f.getType() == schema.Displaytype.Date && f.isUpdateable()){//if field type is Date
                if(sfmMap.SVMXC__Display_Value__c.touppercase() == 'TODAY'){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,system.today());
                }   
                else if(sfmMap.SVMXC__Display_Value__c.touppercase() == 'YESTERDAY'){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,system.today() - 1);
                }       
                else if(sfmMap.SVMXC__Display_Value__c.touppercase() == 'TOMORROW'){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,system.today() + 1);
                }
                else{           
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,Date.valueof(sfmMap.SVMXC__Display_Value__c));
                }
            }
            else if(f.getType() == schema.Displaytype.MultiPicklist && f.isUpdateable()){//if field type is MultiPicklist
                if(String.valueof(sfmMap.SVMXC__Display_Value__c) != null){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,String.valueof(sfmMap.SVMXC__Display_Value__c));
                }
            }
            else{//else field type is REFERENCE,String 
                if((String)sfmMap.SVMXC__Display_Value__c != null && f.isUpdateable()){
                    sObjRec.put(sfmMap.SVMXC__Target_Field_Name__c,(String)sfmMap.SVMXC__Display_Value__c);
                }
            }
        }
            }catch(Exception ex){
            String exceptionMsg = 'WSCH_FieldMatchRuleEngine :: MapLiteral() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }
        return sObjRec;
    }
    /*Method to check for Additional Mapping*/
    public String getAdditionalMap(SObject lkpObj, SVMXC__ServiceMax_Config_Data__c confObj){
        
        String fieldToMap = '';
        try{
            if(confObj.SVMXC__Source_Field_Name__c != null && lkpObj.get(confObj.SVMXC__Source_Field_Name__c) != null)
            {   
                fieldToMap = confObj.SVMXC__Source_Field_Name__c;
            }    
            else if(confObj.SVMXC__Source_Field_Name__c != null && confObj.SVMXC__Preference_2__c != null && lkpObj.get(confObj.SVMXC__Source_Field_Name__c) == null && lkpObj.get(confObj.SVMXC__Preference_2__c) != null)
            {
                fieldToMap = confObj.SVMXC__Preference_2__c;
            }    
            else if(confObj.SVMXC__Source_Field_Name__c != null && lkpObj.get(confObj.SVMXC__Source_Field_Name__c) == null && confObj.SVMXC__Preference_2__c != null && lkpObj.get(confObj.SVMXC__Preference_2__c) == null && confObj.SVMXC__Preference_3__c != null && lkpObj.get(confObj.SVMXC__Preference_3__c) != null)
            {
                fieldToMap = confObj.SVMXC__Preference_3__c;
            }
        }catch(Exception ex){
            String exceptionMsg = 'WSCH_FieldMatchRuleEngine :: getAdditionalMap() :: ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return fieldToMap;
    }
}