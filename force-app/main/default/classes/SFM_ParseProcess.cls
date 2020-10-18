/* Security Scanned */
public with sharing class SFM_ParseProcess 
{
    //Variable Decleration..
    public map<String,map<String,Sobject>> mapAliasNameSourceRecIdTargetObject = new map<String,map<String,Sobject>>();
    public map<String,map<String, Schema.SObjectField>> mapAllFieldDescribe = new map<String,map<String, Schema.SObjectField>>();
    public List<String> mappedFieldsForHeader = new List<String>(); //Added as part of Story BAC-3257
    public Map<Id, Set<String>> mapFieldMapIdListOfFields = new Map<Id, Set<String>>(); //Added for the defect fix BAC-3884
    public Map<String,Set<String>> mapObjectNameWithDVFields = new Map<String,Set<String>>(); //Added for the story BAC-3885
    public Map<String,Set<String>> mapObjectNameFieldListSet = new Map<String,Set<String>>(); //Added for defect fix BAC-4032
    public Map<String, Set<String>> mapObjectNameVsListOfFields = new Map<String, Set<String>>(); //Added for the story BAC-4264
    public static map<String,String> mapSortingFields = new map<String,String>();//Moved this map outside by Nidhi as part of BAC-4680
    public Map<String,Set<String>> mapObjectNameFieldListForFormFill = new Map<String,Set<String>>();
    public Map<String,set<String>> mapObjectAPINameWithFields = new Map<String,set<String>>();
    public static Boolean isBackgroundExecution = false; //newChangeOptiBGSFM

    public map<String,SVMXC.SFM_WrapperDef.FieldSetWithSorting> mapAliasNameFieldSetWrapper =  new map<String,SVMXC.SFM_WrapperDef.FieldSetWithSorting>();

    public map<String,SVMXC.SFM_WrapperDef.FieldSetWithSorting> mapAliasNameFieldSetWrapperForFormfill =  new map<String,SVMXC.SFM_WrapperDef.FieldSetWithSorting>(); //Added for defect fix BAC-4032

    //Constructor..
    public SFM_parseProcess(){} 
    //Method.. 
    public map<String,List<Sobject>> getSFM_ParseProcess(String strProcessId,String strRecordId,map<String, Schema.SObjectType> mapAllObjectDescribe,Sobject objTargetHeaderSobject)
    {
        return getSFM_ParseProcess1(strProcessId,strRecordId,mapAllObjectDescribe,objTargetHeaderSobject,null,null);
    }
    public map<String,List<Sobject>> getSFM_ParseProcess1(String strProcessId,String strRecordId,map<String, Schema.SObjectType> mapAllObjectDescribe,Sobject objTargetHeaderSobject,SVMXC__ServiceMax_Processes__c objSFMProcessParam, list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObjectParam)
    {
        return getSFM_ParseProcess2(strProcessId,strRecordId,mapAllObjectDescribe,objTargetHeaderSobject,objSFMProcessParam,lstProcessNodeObjectParam,null);
    }
    
    //Method with less queries 
    public map<String,List<Sobject>> getSFM_ParseProcess2(String strProcessId,String strRecordId,map<String, Schema.SObjectType> mapAllObjectDescribe,Sobject objTargetHeaderSobject,SVMXC__ServiceMax_Processes__c objSFMProcessParam, list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObjectParam,list<SVMXC.SFM_WrapperDef.SFM_StringMap> lstSFMStringMap)
    {
        
        SVMXC.SFM_buildSobject BuildSobject = new SVMXC.SFM_buildSobject(); 
        SVMXC.SFM_applyMapping Applymapping = new SVMXC.SFM_applyMapping(); 
        SVMXC.SFM_parseExpression ExpParssig = new SVMXC.SFM_parseExpression(); 
        map<String,map<String,Sobject>> mapTemp = new map<String,map<String,Sobject>>();
        map<String,List<Sobject>> mapOutput = new map<String,List<Sobject>>();
        map<String,List<Sobject>> mapHeaderRecord = new map<String,List<Sobject>>();
        map<String,List<Sobject>> mapDetailRecord = new map<String,List<Sobject>>();
        map<String,SVMXC__ServiceMax_Processes__c> mapAliasNameChildNode = new map<String,SVMXC__ServiceMax_Processes__c>();
        map<String,String> mapAliasNameParentColumnName = new map<String,String>();
        list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c objSFMProcess = new SVMXC__ServiceMax_Processes__c();
        String strHeaderTargetObject = '';
        String strHeaderSourceObject = '';
        String strHeaderMapId = '';
        String strHeaderExpressionId = '';
        String strHeaderExpressionObjectName = '';
        String strHeaderExpressionWhereClause = '';
        String strHeaderValueMapId = '';
        String strHeaderMappingSourceObjectName = '';
        String strHeaderMappingTargetObjectName = '';
        String strQueryField = '';
        set<String> setMappingIds = new set<String>();
        map<Id,list<SVMXC__ServiceMax_Config_Data__c>> mapMappingIdFieldMappingList = new  map<Id,list<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id,set<String>> mapMappingIdSourceFields = new  map<Id,set<String>>();
        map<Id,String> mapMappingIdSourceObjectName = new  map<Id,String>();
        map<Id,String> mapMappingIdTargetObjectName = new  map<Id,String>();
        mapSortingFields = new map<String,String>();
        Boolean isQuickSave = false;
        //Boolean isBackgroundExecution = false; // #newChangeOptiBGSFM
        String strHeaderFieldValue = 'HEADER_FIELD_VALUE';
        system.debug(LoggingLevel.WARN,'strProcessId : '+strProcessId );
        system.debug(LoggingLevel.WARN,'lstSFMStringMap : '+lstSFMStringMap );
        
        if(lstSFMStringMap != null && lstSFMStringMap.size() > 0){
            for(Integer i = 0;i<lstSFMStringMap.size();i++){
                if(lstSFMStringMap[i].key != null && lstSFMStringMap[i].value != null){
                    if(lstSFMStringMap[i].key.toUpperCase() == 'ACTIONTYPE' && lstSFMStringMap[i].value.toUpperCase() == 'QUICKSAVE')
                        isQuickSave = true;
                    else if(lstSFMStringMap[i].key.toUpperCase() == 'SVMX_EXECUTION_MODE' && lstSFMStringMap[i].value.toUpperCase() == 'SVMXAUTO')
                        isBackgroundExecution = true;
                    //Commented for the defect 026360 fix
                    //else if(lstSFMStringMap[i].key.toUpperCase() == 'SVMX_Execution_Mode' && lstSFMStringMap[i].value.toUpperCase() == 'SVMXAUTO')
                    /*Moving this code to SFM_TDM_Delivery class.
                    else if(lstSFMStringMap[i].key.toUpperCase() == 'SVMX_EXECUTION_MODE' && lstSFMStringMap[i].value.toUpperCase() == 'SVMXAUTO')
                        isBackgroundExecution = true;   
                     SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(); //#newChangeOptiBGSFM
                     */
                }
            }
        } 
        system.debug(LoggingLevel.WARN,'isBackgroundExecution : '+isBackgroundExecution );
        system.debug(LoggingLevel.WARN,'isQuickSave : '+isQuickSave );        
        if(objSFMProcessParam == null)
        {
            if(SFM_ScheduledSFM_Utils.processId != null && SFM_ScheduledSFM_Utils.processId == strProcessId && SFM_ScheduledSFM_Utils.SFMProcess != null && SFM_ScheduledSFM_Utils.SFMProcess.id != null){
                objSFMProcess = SFM_ScheduledSFM_Utils.SFMProcess;
            } 
            //Added condition to get already queried data for the story BAC-4410
            else if(SFM_GetData.targetManagerProcess != null && SFM_GetData.targetManagerProcess.id != null){
                objSFMProcess = SFM_GetData.targetManagerProcess;
            }
            else if(strProcessId != null && strProcessId.length() > 0){
                //Commented below line and added new one to avoid querying not used fields for the story BAC-4410
                //objSFMProcess = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c, SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C, SVMXC__Installation_Key__c,SVMXC__Final_Exception_Process__c,SVMXC__End_Date__c, SVMXC__Email_On_Success__c,SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c,SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and (Id =: strProcessId OR SVMXC__ProcessID__c =: strProcessId)];
                
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                objSFMProcess = [SELECT Id, SVMXC__Page_Layout__c, SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Target Manager' and (Id =: strProcessId OR SVMXC__ProcessID__c =: strProcessId)];
            }
        }
        else
        {
            objSFMProcess = objSFMProcessParam;
        }
        if(lstProcessNodeObjectParam == null)
        {
            if(SFM_ScheduledSFM_Utils.processId != null && SFM_ScheduledSFM_Utils.processId == strProcessId && SFM_ScheduledSFM_Utils.processNodeList != null && SFM_ScheduledSFM_Utils.processNodeList.size() > 0){
                lstProcessNodeObject = SFM_ScheduledSFM_Utils.processNodeList;
            }
            //Added condition to get already queried data for the story BAC-4410
            else if(SFM_GetData.processNodeObjectsList != null && SFM_GetData.processNodeObjectsList.size() > 0){
                lstProcessNodeObject = SFM_GetData.processNodeObjectsList;
            }
            else if(objSFMProcess != null && objSFMProcess.id != null){
                //Commented below line and added new one to avoid querying not used fields for the story BAC-4410
                //lstProcessNodeObject = [Select SVMXC__Parent_Object__r.SVMXC__Type__c, SVMXC__Parent_Object__r.SVMXC__Parent_Column_Name__c, SVMXC__Default_Value__c, SVMXC__Values__c, SVMXC__Module__r.SVMXC__Source_Object_Name__c, SVMXC__Module__r.SVMXC__Target_Object_Name__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, Name,SVMXC__ProcessID__c,SVMXC__Page_Layout__c,SVMXC__Parent_Column_Name__c,SVMXC__Final_Exception_Process__c,SVMXC__Type__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Node_Source_Object_API__c,SVMXC__Target_Object_label__c,SVMXC__IsStandard__c,SVMXC__IsStandalone__c  From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: objSFMProcess.id and RecordType.Name  = 'Process Node Objects'];    

                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstProcessNodeObject = [SELECT Id, SVMXC__Parent_Object__r.SVMXC__Type__c, SVMXC__Parent_Object__r.SVMXC__Parent_Column_Name__c, SVMXC__Values__c, SVMXC__Module__r.SVMXC__Source_Object_Name__c, SVMXC__Module__r.SVMXC__Target_Object_Name__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, SVMXC__Page_Layout__c, SVMXC__Parent_Column_Name__c, SVMXC__Final_Exception_Process__c, SVMXC__Type__c, SVMXC__Source_Object_Name__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Node_Source_Object_API__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process__c =: objSFMProcess.id AND RecordType.Name  = 'Process Node Objects'];
            }
                
        }
        else
        {
            lstProcessNodeObject = lstProcessNodeObjectParam;
        }   
        system.debug(LoggingLevel.WARN,'Query issued'+Limits.getQueries());
        system.debug(LoggingLevel.WARN,'objSFMProcess'+objSFMProcess);
        system.debug(LoggingLevel.WARN,'lstProcessNodeObject'+lstProcessNodeObject);
       
        Boolean isHeaderObjectWO = false; //Added for the story BAC-4454
        Boolean isChildObjectWD = false; //Added for the story BAC-4454
        
        if(lstProcessNodeObject.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c PND : lstProcessNodeObject)
            {
                if(PND.SVMXC__Type__c.touppercase() == 'TARGET')
                {
                     if(PND.SVMXC__Node_Source_Object_API__c != null)
                        strHeaderSourceObject = PND.SVMXC__Node_Source_Object_API__c;
                     if(PND.SVMXC__Source_Object_Name__c != null){   
                        strHeaderTargetObject = PND.SVMXC__Source_Object_Name__c;
                        //-----Start-----Added for the story BAC-4454
                        if(strHeaderTargetObject.equalsIgnoreCase('SVMXC__Service_Order__c')){
                            isHeaderObjectWO = true;
                        }
                        //-----End-------Added for the story BAC-4454
                     }
                     if(PND.SVMXC__Submodule__c != null)
                     {
                        strHeaderExpressionId = PND.SVMXC__Submodule__c;
                        strHeaderExpressionObjectName = PND.SVMXC__Submodule__r.SVMXC__Source_Object_Name__c;
                        strHeaderExpressionWhereClause = PND.SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c;
                     }   
                     if(PND.SVMXC__Module__c != null)
                     {
                        setMappingIds.add(PND.SVMXC__Module__c);
                        strHeaderMapId = PND.SVMXC__Module__c;
                        strHeaderMappingSourceObjectName = PND.SVMXC__Module__r.SVMXC__Source_Object_Name__c;
                        strHeaderMappingTargetObjectName = PND.SVMXC__Module__r.SVMXC__Target_Object_Name__c;
                     }     
                     if(PND.SVMXC__Final_Exception_Process__c != null)
                        strHeaderValueMapId = PND.SVMXC__Final_Exception_Process__c;
                     if(PND.SVMXC__Values__c != null){
                        SVMXC.SFM_WrapperDef.FieldSetWithSorting fieldsetwithsorting = 
                        (SVMXC.SFM_WrapperDef.FieldSetWithSorting) deserializeRequestTo(PND.SVMXC__Values__c, SVMXC.SFM_WrapperDef.FieldSetWithSorting.class);
                        if(fieldsetwithsorting.lstFieldSetAPIName != null && fieldsetwithsorting.lstFieldSetAPIName.size() > 0){
                            fieldsetwithsorting.strObjectName = strHeaderTargetObject;
                            fieldsetwithsorting.fieldMapId = PND.SVMXC__Module__c;
                            fieldsetwithsorting.valueMapId = PND.SVMXC__Final_Exception_Process__c;
                            fieldsetwithsorting.pageLayoutId = objSFMProcess.SVMXC__Page_Layout__c;
                            mapAliasNameFieldSetWrapper.put(strHeaderTargetObject,fieldsetwithsorting);
                        }   
                    }
                    else if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Added for code optimization BAC-2993 //Check added as part of story BAC-3256
                        String strProcessType = objSFMProcess.SVMXC__Purpose__c.touppercase();
                        if(strProcessType == 'SOURCE TO TARGET CHILD' || strProcessType == 'STANDALONE EDIT' || strProcessType == 'SOURCE TO TARGET ALL' || strProcessType == 'STANDALONE CREATE'){
                            SVMXC.SFM_WrapperDef.FieldSetWithSorting fieldsetwithsorting = new SVMXC.SFM_WrapperDef.FieldSetWithSorting();
                            fieldsetwithsorting.lstFieldSetAPIName = new List<String>();
                            fieldsetwithsorting.strObjectName = strHeaderTargetObject;
                            fieldsetwithsorting.fieldMapId = PND.SVMXC__Module__c;
                            fieldsetwithsorting.valueMapId = PND.SVMXC__Final_Exception_Process__c;
                            fieldsetwithsorting.pageLayoutId = objSFMProcess.SVMXC__Page_Layout__c;
                            mapAliasNameFieldSetWrapper.put(strHeaderTargetObject,fieldsetwithsorting);
                        }
                    }

                    //---Start--Added for defect fix BAC-4032
                    SVMXC.SFM_WrapperDef.FieldSetWithSorting objFieldsetwithsorting = new SVMXC.SFM_WrapperDef.FieldSetWithSorting();
                    objFieldsetwithsorting.lstFieldSetAPIName = new List<String>();
                    objFieldsetwithsorting.strObjectName = strHeaderTargetObject;
                    objFieldsetwithsorting.pageLayoutId = objSFMProcess.SVMXC__Page_Layout__c;
                    mapAliasNameFieldSetWrapperForFormfill.put(strHeaderTargetObject,objFieldsetwithsorting);
                    //---End--Added for defect fix BAC-4032
                }
                else if(PND.SVMXC__Type__c.touppercase() == 'TARGETCHILD')
                {
                    //-----Start-----Added for the story BAC-4454
                    if(!isChildObjectWD && !String.isBlank(PND.SVMXC__Source_Object_Name__c) && PND.SVMXC__Source_Object_Name__c.equalsIgnoreCase('SVMXC__Service_Order_Line__c')){
                        isChildObjectWD = true;
                    }
                    //-----End-------Added for the story BAC-4454
                    if(PND.SVMXC__Page_Layout__c != null)
                        mapAliasNameChildNode.put(String.valueof(PND.SVMXC__Page_Layout__c).substring(0,15),PND);
                    if(PND.SVMXC__Module__c != null)
                    {
                        setMappingIds.add(PND.SVMXC__Module__c);
                        mapMappingIdSourceObjectName.put(String.valueof(PND.SVMXC__Module__c),PND.SVMXC__Module__r.SVMXC__Source_Object_Name__c); 
                        mapMappingIdTargetObjectName.put(String.valueof(PND.SVMXC__Module__c),PND.SVMXC__Module__r.SVMXC__Target_Object_Name__c);
                    }
                    if(PND.SVMXC__Values__c != null){
                        SVMXC.SFM_WrapperDef.FieldSetWithSorting fieldsetwithsorting = 
                        (SVMXC.SFM_WrapperDef.FieldSetWithSorting) deserializeRequestTo(PND.SVMXC__Values__c, SVMXC.SFM_WrapperDef.FieldSetWithSorting.class);
                        if(fieldsetwithsorting.lstFieldSetAPIName != null && fieldsetwithsorting.lstFieldSetAPIName.size() > 0){
                            fieldsetwithsorting.strObjectName = PND.SVMXC__Source_Object_Name__c;
                            fieldsetwithsorting.fieldMapId = PND.SVMXC__Module__c;
                            fieldsetwithsorting.valueMapId = PND.SVMXC__Final_Exception_Process__c;
                            fieldsetwithsorting.pageLayoutId = PND.SVMXC__Page_Layout__c;
                            mapAliasNameFieldSetWrapper.put(PND.SVMXC__Page_Layout__c,fieldsetwithsorting);
                        } 
                        //Added for the defect BAC-3275 fix
                        else if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Check added as part of story BAC-3256
                            String strProcessType = objSFMProcess.SVMXC__Purpose__c.touppercase();
                            //Added one more condition (strProcessType == 'SOURCE TO TARGET CHILD') for fixing defect BAC-3404
                            if(strProcessType == 'SOURCE TO TARGET CHILD' || strProcessType == 'STANDALONE EDIT' || strProcessType == 'SOURCE TO TARGET ALL'  || strProcessType == 'STANDALONE CREATE'){
                                    //This is commented as part of defect BAC-3393 fix
                                //fieldsetwithsorting = new SVMXC.SFM_WrapperDef.FieldSetWithSorting();
                                fieldsetwithsorting.lstFieldSetAPIName = new List<String>();
                                fieldsetwithsorting.strObjectName = PND.SVMXC__Source_Object_Name__c;
                                fieldsetwithsorting.fieldMapId = PND.SVMXC__Module__c;
                                fieldsetwithsorting.valueMapId = PND.SVMXC__Final_Exception_Process__c;
                                fieldsetwithsorting.pageLayoutId = PND.SVMXC__Page_Layout__c;
                                mapAliasNameFieldSetWrapper.put(PND.SVMXC__Page_Layout__c,fieldsetwithsorting);
                            }
                        }  
                        if(fieldsetwithsorting.lstSortingRec != null && fieldsetwithsorting.lstSortingRec.size() > 0){
                            String strSortingClause = '';
                            for(Integer i = 0;i<fieldsetwithsorting.lstSortingRec.size();i++){
                                if(strSortingClause != ''){
                                    strSortingClause +=', '+fieldsetwithsorting.lstSortingRec[i].queryField +' '+ fieldsetwithsorting.lstSortingRec[i].sortingOrder;
                                }else{
                                    strSortingClause += fieldsetwithsorting.lstSortingRec[i].queryField +' '+ fieldsetwithsorting.lstSortingRec[i].sortingOrder;
                                }
                            }
                            mapSortingFields.put(String.valueof(PND.SVMXC__Page_Layout__c).substring(0,15),strSortingClause);
                        }
                    }
                    else if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Added for code optimization BAC-2993 //Check added as part of story BAC-3256
                        String strProcessType = objSFMProcess.SVMXC__Purpose__c.touppercase();
                        //Added one more condition (strProcessType == 'SOURCE TO TARGET CHILD') for fixing defect BAC-3404
                        if(strProcessType == 'SOURCE TO TARGET CHILD' || strProcessType == 'STANDALONE EDIT' || strProcessType == 'SOURCE TO TARGET ALL' || strProcessType == 'STANDALONE CREATE'){
                            SVMXC.SFM_WrapperDef.FieldSetWithSorting fieldsetwithsorting = new SVMXC.SFM_WrapperDef.FieldSetWithSorting();
                            fieldsetwithsorting.lstFieldSetAPIName = new List<String>();
                            fieldsetwithsorting.strObjectName = PND.SVMXC__Source_Object_Name__c;
                            fieldsetwithsorting.fieldMapId = PND.SVMXC__Module__c;
                            fieldsetwithsorting.valueMapId = PND.SVMXC__Final_Exception_Process__c;
                            fieldsetwithsorting.pageLayoutId = PND.SVMXC__Page_Layout__c;
                            mapAliasNameFieldSetWrapper.put(PND.SVMXC__Page_Layout__c,fieldsetwithsorting);
                        }
                    }

                    //---Start--Added for defect fix BAC-4032
                    SVMXC.SFM_WrapperDef.FieldSetWithSorting objFieldsetwithsorting = new SVMXC.SFM_WrapperDef.FieldSetWithSorting();
                    objFieldsetwithsorting.lstFieldSetAPIName = new List<String>();
                    objFieldsetwithsorting.strObjectName = PND.SVMXC__Source_Object_Name__c;
                    objFieldsetwithsorting.pageLayoutId = PND.SVMXC__Page_Layout__c;
                    mapAliasNameFieldSetWrapperForFormfill.put(PND.SVMXC__Page_Layout__c,objFieldsetwithsorting);
                    //---End--Added for defect fix BAC-4032

                    if(PND.SVMXC__Parent_Object__c != null && PND.SVMXC__Parent_Object__r.SVMXC__Type__c != null && PND.SVMXC__Parent_Object__r.SVMXC__Type__c.touppercase() == 'SOURCECHILD'){
                        if(PND.SVMXC__Page_Layout__c != null && PND.SVMXC__Parent_Object__r.SVMXC__Parent_Column_Name__c != null){
                            String strAliasId = String.valueof(PND.SVMXC__Page_Layout__c).substring(0,15);
                            if(! mapAliasNameParentColumnName.containskey(strAliasId))
                                mapAliasNameParentColumnName.put(strAliasId,PND.SVMXC__Parent_Object__r.SVMXC__Parent_Column_Name__c);
                        }
                    }
                }
            }
        }
        system.debug(LoggingLevel.WARN,'isHeaderObjectWO: '+isHeaderObjectWO);
        system.debug(LoggingLevel.WARN,'isChildObjectWD: '+isChildObjectWD);
        system.debug(LoggingLevel.WARN,'mapSortingFields: '+mapSortingFields.size()+' '+mapSortingFields);
        system.debug(LoggingLevel.WARN,'strHeaderSourceObject: '+strHeaderSourceObject+' strHeaderTargetObject: '+strHeaderTargetObject+' strHeaderExpressionId: '+strHeaderExpressionId+' strHeaderMapId: '+strHeaderMapId); 
        system.debug(LoggingLevel.WARN,'mapAliasNameChildNode: '+mapAliasNameChildNode.size()+' '+mapAliasNameChildNode);
        system.debug(LoggingLevel.WARN,'mapAliasNameParentColumnName: '+mapAliasNameParentColumnName.size()+' '+mapAliasNameParentColumnName);
        system.debug(LoggingLevel.WARN,'mapMappingIdSourceObjectName: '+mapMappingIdSourceObjectName);
        system.debug(LoggingLevel.WARN,'mapMappingIdTargetObjectName: '+mapMappingIdTargetObjectName);
        system.debug(LoggingLevel.WARN,'mapAliasNameFieldSetWrapper: '+mapAliasNameFieldSetWrapper);
        system.debug(LoggingLevel.WARN,'mapAliasNameFieldSetWrapperForFormfill: '+mapAliasNameFieldSetWrapperForFormfill);
        
        //---Start--Added for defect fix BAC-4032
        Map<String,Set<String>> mapObjectAPINameWithFieldsForFormFill = new Map<String,Set<String>>();
        if(mapAliasNameFieldSetWrapperForFormfill.size() > 0 && !SFMDeliveryServiceImpl.isQueryOptimizerEnabled && mapAliasNameFieldSetWrapper.size() == 0){
            SVMXC.SFM_FieldSetUtils fieldSetUtils = new SVMXC.SFM_FieldSetUtils();
            mapObjectAPINameWithFieldsForFormFill = fieldSetUtils.SFM_buildFieldListFromFieldSet(mapAliasNameFieldSetWrapperForFormfill, mapAllObjectDescribe);
            mapFieldMapIdListOfFields = fieldSetUtils.mapFieldMapIdListOfFields; 
            mapObjectNameFieldListForFormFill = fieldSetUtils.mapObjectNameFieldListForFormFill;
            mapObjectNameFieldListSet = mapObjectAPINameWithFieldsForFormFill;
            System.debug(LoggingLevel.WARN,'mapObjectNameFieldListForFormFill: '+mapObjectNameFieldListForFormFill);
            System.debug(LoggingLevel.WARN,'mapObjectAPINameWithFieldsForFormFill: '+mapObjectAPINameWithFieldsForFormFill);
            System.debug(LoggingLevel.WARN,'mapObjectNameFieldListSet: '+mapObjectNameFieldListSet);
        }
        System.debug(LoggingLevel.WARN,'mapFieldMapIdListOfFields_MK: '+mapFieldMapIdListOfFields);
        //---End--Added for defect fix BAC-4032

        //map<String,set<String>> mapObjectAPINameWithFields = new map<String,set<String>>();
        if(mapAliasNameFieldSetWrapper.size() > 0){
            SVMXC.SFM_FieldSetUtils fieldSetUtils = new SVMXC.SFM_FieldSetUtils();
            mapObjectAPINameWithFields = fieldSetUtils.SFM_buildFieldListFromFieldSet(mapAliasNameFieldSetWrapper,mapAllObjectDescribe);
            mapFieldMapIdListOfFields = fieldSetUtils.mapFieldMapIdListOfFields; //Added for the defect fix BAC-3884
            mapObjectNameFieldListSet = fieldSetUtils.mapObjectNameFieldListSet; //Added for defect fix BAC-4032
            mapObjectNameFieldListForFormFill = fieldSetUtils.mapObjectNameFieldListForFormFill;
            System.debug(LoggingLevel.WARN,'mapObjectNameFieldListForFormFill: '+mapObjectNameFieldListForFormFill);
            System.debug(LoggingLevel.WARN,'mapObjectNameFieldListSet: '+mapObjectNameFieldListSet);
        }
        system.debug(LoggingLevel.WARN,'mapObjectAPINameWithFields: '+mapObjectAPINameWithFields);

        //---Start------Added for the story BAC-3272 for literals
        //Added setting value check for the story BAC-3577 to control the behaviour of BAC-3272
        if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled && mapObjectAPINameWithFields != null && mapObjectAPINameWithFields.containsKey(strHeaderFieldValue) && mapObjectAPINameWithFields.containsKey(strHeaderTargetObject)){
            mapObjectAPINameWithFields.get(strHeaderTargetObject).addAll(mapObjectAPINameWithFields.get(strHeaderFieldValue));
            mapObjectAPINameWithFields.remove(strHeaderFieldValue);
        }
        System.debug(LoggingLevel.WARN, 'After adding mapping literal mapObjectAPINameWithFields: '+mapObjectAPINameWithFields);
        //---End------Added for the story BAC-3272 for literals
        
        //---Start------Added for the story BAC-3272 for fetching fields used in Data validation rule cofigured in SFM
        
        //public Map<String,Set<String>> mapObjectNameWithDVFields = new Map<String,Set<String>>(); //Commented for the story BAC-3885
        //----Start-------Added for the story BAC-3885
        if(!isBackgroundExecution && objSFMProcess != null && objSFMProcess.id != null){
            //Calling method to get fields used in DV rule and Formula
            mapObjectNameWithDVFields = getFieldsUsedInDVAndFormula(objSFMProcess.id);
        }
        //----End---------Added for the story BAC-3885

        //Added setting value check for the story BAC-3577 to control the behaviour of BAC-3272
        if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled && objSFMProcess != null && objSFMProcess.id != null){

            //Calling method to get fields used in DV rule
            //mapObjectNameWithDVFields = getFieldsUsedInDV(objSFMProcess.id); //Commented for the story BAC-3885

            //merging list of fields of every object configured in SFM in the map mapObjectAPINameWithFields
            if(mapObjectNameWithDVFields != null && mapObjectNameWithDVFields.size() > 0 && mapObjectAPINameWithFields != null && mapObjectAPINameWithFields.size() > 0){
                for(String objectName: mapObjectNameWithDVFields.keyset()){
                    if(mapObjectAPINameWithFields.containsKey(objectName))
                        mapObjectAPINameWithFields.get(objectName).addAll(mapObjectNameWithDVFields.get(objectName));
                }
            }
        }
        System.debug(LoggingLevel.WARN, 'mapObjectNameWithDVFields: '+mapObjectNameWithDVFields);
        System.debug(LoggingLevel.WARN, 'After addition DV fields mapObjectAPINameWithFields: '+mapObjectAPINameWithFields);
        //---End------Added for the story BAC-3272 for fetching fields used in Data validation rule cofigured in SFM
        
        //-------Start--------Added for the story BAC-4454
        if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled && isHeaderObjectWO && isChildObjectWD){
            Boolean isStandardGetPriceConfigured = false;
            isStandardGetPriceConfigured = getPriceConfiguredStatus(objSFMProcess.SVMXC__Page_Layout__c);
            System.debug(LoggingLevel.WARN, 'isStandardGetPriceConfigured: '+isStandardGetPriceConfigured);
            
            if(isStandardGetPriceConfigured){
                Map<String, Set<String>> mapObjectNameFieldsName = fetchGetPriceFields();
                System.debug(LoggingLevel.WARN, 'mapObjectNameFieldsName: '+mapObjectNameFieldsName);
                
                if(mapObjectAPINameWithFields != null && mapObjectNameFieldsName != null){
                    for(String strObjectName: mapObjectNameFieldsName.keyset()){
                        if(!mapObjectAPINameWithFields.containsKey(strObjectName)){
                            mapObjectAPINameWithFields.put(strObjectName, new Set<String>());
                        }
                        mapObjectAPINameWithFields.get(strObjectName).addAll(mapObjectNameFieldsName.get(strObjectName));
                    }
                }
            }
        }
        System.debug(LoggingLevel.WARN, 'After addition GetPrice fields mapObjectAPINameWithFields: '+mapObjectAPINameWithFields);
        //-------End----------Added for the story BAC-4454
        
        // Get all field mapping records
        if(setMappingIds.size() > 0)
        {
            list<SVMXC__ServiceMax_Config_Data__c> lstFieldMapping = new list<SVMXC__ServiceMax_Config_Data__c>();
            if(Userinfo.isMultiCurrencyOrganization())
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstFieldMapping = [Select SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c,SVMXC__Active__c, RecordTypeId, Name, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c IN : setMappingIds];
            else
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstFieldMapping = [Select  SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_3__c, SVMXC__Preference_2__c, SVMXC__MapID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c,SVMXC__Active__c, RecordTypeId, Name, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__MapID__c IN : setMappingIds and SVMXC__Target_Field_Name__c != 'CurrencyIsoCode'];
            if(lstFieldMapping.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c fldMap: lstFieldMapping )
                {
                    
                    set<String> setFields = new set<String>();
                    if(mapMappingIdFieldMappingList.containskey(String.valueOf(fldMap.SVMXC__MapID__c)))
                        mapMappingIdFieldMappingList.get(String.valueOf(fldMap.SVMXC__MapID__c)).add(fldMap);
                    else
                    {
                        mapMappingIdFieldMappingList.put(String.valueOf(fldMap.SVMXC__MapID__c), new list<SVMXC__ServiceMax_Config_Data__c>());
                        mapMappingIdFieldMappingList.get(String.valueOf(fldMap.SVMXC__MapID__c)).add(fldMap);
                    }
                    if(fldMap.SVMXC__Source_Field_Name__c != null)
                        setFields.add(fldMap.SVMXC__Source_Field_Name__c.touppercase());
                    if(fldMap.SVMXC__Preference_2__c != null)
                        setFields.add(fldMap.SVMXC__Preference_2__c.touppercase());
                    if(fldMap.SVMXC__Preference_3__c != null)
                        setFields.add(fldMap.SVMXC__Preference_3__c.touppercase());     
                    if(mapMappingIdSourceFields.containskey(fldMap.SVMXC__MapID__c)){
                        mapMappingIdSourceFields.get(fldMap.SVMXC__MapID__c).addall(setFields);
                    }
                    else{
                        mapMappingIdSourceFields.put(fldMap.SVMXC__MapID__c, new set<String>());
                        mapMappingIdSourceFields.get(fldMap.SVMXC__MapID__c).addall(setFields);
                    }
                }
            }       
        }
        system.debug(LoggingLevel.WARN,'mapMappingIdFieldMappingList: '+mapMappingIdFieldMappingList.size()+' : '+mapMappingIdFieldMappingList);
        //1. STANDALONE CREATE 
        
        if(objSFMProcess.SVMXC__Purpose__c.touppercase() == 'STANDALONE CREATE')
        {
            //Create Target Header from Source Object
            list<Sobject> lstTargetHeaderRecord = new list<Sobject>();
            if(strHeaderTargetObject != null && strHeaderTargetObject.length() > 0)
                lstTargetHeaderRecord =  BuildSobject.getSFM_BuildSobject(null,strHeaderTargetObject,null,null);
            
            //Apply mapping if applicable
            if(lstTargetHeaderRecord.size() > 0 && String.isNotBlank(strHeaderValueMapId)) //#optiChange
                lstTargetHeaderRecord = Applymapping.getValueMapping1(lstTargetHeaderRecord,strHeaderValueMapId,mapAllObjectDescribe,objSFMProcess.SVMXC__Purpose__c);
            if(lstTargetHeaderRecord.size() > 0)
                mapHeaderRecord.put(strHeaderTargetObject,lstTargetHeaderRecord);
            
            //Create the Target Childs.. 
            //if(mapAliasNameChildNode.size() > 0) //#optiChange
           // {                                     //#optiChange
                for(String s : mapAliasNameChildNode.keyset())
                {
                    list<Sobject> lstTargetChildRecord = new list<Sobject>();
                    if(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c != null)
                        lstTargetChildRecord =  BuildSobject.getSFM_BuildSobject(null,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,null,null);
                    //Apply mapping if applicable
                    if(lstTargetChildRecord.size() > 0 && mapAliasNameChildNode.get(s).SVMXC__Final_Exception_Process__c != null)
                        lstTargetChildRecord = Applymapping.getValueMapping1(lstTargetChildRecord,mapAliasNameChildNode.get(s).SVMXC__Final_Exception_Process__c,mapAllObjectDescribe,objSFMProcess.SVMXC__Purpose__c,lstTargetHeaderRecord[0]);
                    if(lstTargetChildRecord.size() > 0)
                        mapDetailRecord.put(s,lstTargetChildRecord);
                    system.debug(LoggingLevel.WARN,'mapDetailRecord'+mapDetailRecord.size()+mapDetailRecord);
                }
            //} // #optiChange
        }
        
        // 2. VIEW Process ===> Mapping is not applicable, Expression is applicable.. 
        
        else if(objSFMProcess.SVMXC__Purpose__c.touppercase() == 'VIEW RECORD')
        {
            //Get Target Header 
            if(strHeaderTargetObject != null && strHeaderTargetObject.length() > 0)
            {
                list<Sobject> lstTargetHeaderRecord = new list<Sobject>();
                String strQueryFields = '';
                //lstTargetHeaderRecord =  BuildSobject.getSFM_BuildSobject(strRecordId,strHeaderTargetObject,null,null);
                if(mapObjectAPINameWithFields.containskey(strHeaderTargetObject)){
                    strQueryFields = BuildSobject.buildQueryStringFromSet(mapObjectAPINameWithFields.get(strHeaderTargetObject));
                    lstTargetHeaderRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,strHeaderTargetObject,null,null,mapObjectAPINameWithFields.get(strHeaderTargetObject),null);
                }
                else{
                    lstTargetHeaderRecord = BuildSobject.getSFM_BuildSobject(strRecordId,strHeaderTargetObject,null,null);
                }
                system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                //Expression Qualification...
                if(strHeaderExpressionObjectName != null && strHeaderExpressionObjectName.length() > 0 && strHeaderExpressionWhereClause != null && strHeaderExpressionWhereClause.length() > 0 && lstTargetHeaderRecord.size() > 0) 
                {
                    if(strQueryFields != '')
                        lstTargetHeaderRecord = ExpParssig.SFM_ParseExpression1(lstTargetHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause,strQueryFields);
                    else
                        lstTargetHeaderRecord = ExpParssig.SFM_ParseExpression1(lstTargetHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause);   
                    system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                }   
                if(lstTargetHeaderRecord.size() > 0)
                    mapHeaderRecord.put(strHeaderTargetObject,lstTargetHeaderRecord);
            } 
            //Get Target Child
            if(mapAliasNameChildNode.size() > 0)
            {
                for(String s : mapAliasNameChildNode.keyset())
                {
                    list<Sobject> lstTargetChildRecord = new list<Sobject>();
                    String strQueryFields = '';
                    if(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c != null){
                        //lstTargetChildRecord = BuildSobject.getSFM_BuildSobject(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null);
                        if(mapObjectAPINameWithFields.containskey(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c)){
                            strQueryFields =  BuildSobject.buildQueryStringFromSet(mapObjectAPINameWithFields.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c));
                            if(mapSortingFields.containskey(s)){
                                lstTargetChildRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null,mapObjectAPINameWithFields.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c),mapSortingFields.get(s));
                            }else{
                                lstTargetChildRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null,mapObjectAPINameWithFields.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c),null);
                            }   
                        }else{
                            if(mapSortingFields.containskey(s)){
                                lstTargetChildRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null,null,mapSortingFields.get(s));
                            }else{
                                lstTargetChildRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null,null,null);
                            }
                        }   
                    }    
                    system.debug(LoggingLevel.WARN,'lstTargetChildRecord'+lstTargetChildRecord);
                    if(lstTargetChildRecord.size() > 0 && mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null)
                    {
                        if(strQueryFields != ''){
                            if(mapSortingFields.containskey(s)){
                                lstTargetChildRecord = ExpParssig.SFM_ParseExpression1(lstTargetChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryFields,mapSortingFields.get(s));
                            }
                            else{
                                lstTargetChildRecord = ExpParssig.SFM_ParseExpression1(lstTargetChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryFields);
                            }   
                        }   
                        else{
                            if(mapSortingFields.containskey(s)){
                                lstTargetChildRecord = ExpParssig.SFM_ParseExpression1(lstTargetChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,null,mapSortingFields.get(s));
                            }
                            else{
                                lstTargetChildRecord = ExpParssig.SFM_ParseExpression1(lstTargetChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c);
                            }   
                        }          
                       system.debug(LoggingLevel.WARN,'lstTargetChildRecord'+lstTargetChildRecord);
                    }
                    if(lstTargetChildRecord.size() > 0)
                        mapDetailRecord.put(s,lstTargetChildRecord);
                    system.debug(LoggingLevel.WARN,'mapDetailRecord'+mapDetailRecord.size()+mapDetailRecord); 
                }
            }
        }
        //3. STANDALONE EDIT ===> Expression is applicable, ValueMap is applicable for Header only,
                                  
        else if (objSFMProcess.SVMXC__Purpose__c.touppercase() == 'STANDALONE EDIT')
        {
            //Get Target Header ..
            system.debug(LoggingLevel.WARN,'Entered in Standalone Edit');
            if(strHeaderTargetObject != null && strHeaderTargetObject.length() > 0)
            {
                list<Sobject> lstTargetHeaderRecord = new list<Sobject>();
                String strQueryFields = '';
                //lstTargetHeaderRecord =  BuildSobject.getSFM_BuildSobject(strRecordId,strHeaderTargetObject,null,null);
                if(mapObjectAPINameWithFields.containskey(strHeaderTargetObject)){
                    BuildSobject.calledFromWhere = 'SFM_ParseProcess'; //Added for the story BAC-4264
                    BuildSobject.isQueryRecordTypeId = true; //Added for the story BAC-5372
                    strQueryFields = BuildSobject.buildQueryStringFromSet(mapObjectAPINameWithFields.get(strHeaderTargetObject));
                    lstTargetHeaderRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,strHeaderTargetObject,null,null,mapObjectAPINameWithFields.get(strHeaderTargetObject),null);
                    BuildSobject.calledFromWhere = null; //Added for the story BAC-4264
                    BuildSobject.isQueryRecordTypeId = false; //Added for the story BAC-5372
                }
                else{
                    BuildSobject.calledFromWhere = 'SFM_ParseProcess'; //Added for the story BAC-4264
                    lstTargetHeaderRecord = BuildSobject.getSFM_BuildSobject(strRecordId,strHeaderTargetObject,null,null);
                    BuildSobject.calledFromWhere = null; //Added for the story BAC-4264
                }
                System.debug('mapObjectNameVsListOfFields: '+BuildSobject.mapObjectNameVsListOfFields); //Added for the story BAC-4264
                system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                //Expression Qualification...
                
                
                //Added isBackgroundExecution to avoid qualification check in interactive SFM as it is already done on load of page
                if(isBackgroundExecution && !isQuickSave && strHeaderExpressionObjectName != null && strHeaderExpressionObjectName.length() > 0 && strHeaderExpressionWhereClause != null && strHeaderExpressionWhereClause.length() > 0 && lstTargetHeaderRecord.size() > 0) 
                {
                    if(strQueryFields != '')
                        lstTargetHeaderRecord = ExpParssig.SFM_ParseExpression1(lstTargetHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause,strQueryFields);
                    else
                        lstTargetHeaderRecord = ExpParssig.SFM_ParseExpression1(lstTargetHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause);   
                    system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                }
                //Apply value mapping if applicable (Started Supporting Spring 12 SP2 onwords)
                if(!isQuickSave && lstTargetHeaderRecord.size() > 0 && String.isNotBlank(strHeaderValueMapId)){ //#optiChange
                    lstTargetHeaderRecord = Applymapping.getValueMapping1(lstTargetHeaderRecord,strHeaderValueMapId,mapAllObjectDescribe,objSFMProcess.SVMXC__Purpose__c);
                    mappedFieldsForHeader = Applymapping.mappedFieldsForHeader; //Added as part of Story BAC-3257
                    System.debug(LoggingLevel.WARN,'mappedFieldsForHeader: '+mappedFieldsForHeader);
                }
                
                system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                if(lstTargetHeaderRecord.size() > 0)
                    mapHeaderRecord.put(strHeaderTargetObject,lstTargetHeaderRecord);
            }
            //get Target Childs..
            //if(mapAliasNameChildNode.size() > 0) //#optiChange
            //{                                     //#optiChange
                Map<String, String> mapObjectNameAndNameField = new Map<String, String>();
                for(String s : mapAliasNameChildNode.keyset())
                {
                    system.debug(LoggingLevel.WARN,'ProNodeObject'+mapAliasNameChildNode.get(s));
                    list<Sobject> lstTargetChildRecord = new list<Sobject>();
                    String strQueryFields = '';
                    if(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c != null){
                        
                        if(SFMDeliveryServiceImpl.detailRecBatchSize != null && SFMDeliveryServiceImpl.detailRecBatchSize > 0){
                            if(mapObjectNameAndNameField.containsKey(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c)){
                                String nameField = mapObjectNameAndNameField.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c);
                                BuildSobject.nameField = nameField;
                                ExpParssig.nameField = nameField;
                            }
                            else{
                                //Added by Nidhi as part of LAzy Loading BAC-4680
                                //This is to get the name field for each tab and apply default sort with name field if no sortung is applied by user
                                String nameField = '';
                                /* #optiChange if(mapAllObjectDescribe.containskey(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c)){
                                    map<String, Schema.SObjectField> FieldMap = new map<String, Schema.SObjectField>();
                                    FieldMap = mapAllObjectDescribe.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c).getDescribe().fields.getMap();*/
                                    map<String, Schema.SObjectField> FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c);
                                    if(FieldMap != NULL && !FieldMap.isEmpty())
                                    {
                                        for(String item : FieldMap.keyset())
                                        {
                                            Schema.DescribeFieldResult dfr = FieldMap.get(item).getDescribe();
                                            if(dfr.isNameField()){
                                                nameField = dfr.getName();
                                                break;
                                            }
                                        }
                                    }
                                //}
                                if(String.isBlank(nameField)){
                                    nameField = 'Id';
                                }
                                mapObjectNameAndNameField.put(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c, nameField);
                                BuildSobject.nameField = nameField;
                                ExpParssig.nameField = nameField;
                            }
                        }
                        
                        //------Start----Added for optimization
                        String strSortingClause = '';
                        String strWhereClause = '';
                        String strParentColumnName = '';
                        String strObjectName = '';
                        
                        if(mapObjectAPINameWithFields.containskey(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c)){
                            strQueryFields = BuildSobject.buildQueryStringFromSet(mapObjectAPINameWithFields.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c));
                        }
                        
                        if(mapSortingFields.containskey(s)){
                            strSortingClause = mapSortingFields.get(s);
                        }
                        
                        if(mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null){
                            strWhereClause = mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c;
                        }
                        
                        if(mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c != null){
                            strParentColumnName = mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c;
                        }
                        
                        if(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c != null){
                            strObjectName = mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c;
                        }
                        
                        ExpParssig.calledFromWhere = 'SFM_ParseProcess';
                        ExpParssig.isQueryRecordTypeId = true; //Added for the story BAC-5372
                        lstTargetChildRecord = ExpParssig.SFM_GetRecordsAfterApplyingCriteria1(strRecordId, strObjectName, strParentColumnName, strWhereClause, strQueryFields, strSortingClause, true);
                        ExpParssig.calledFromWhere = null;
                        ExpParssig.isQueryRecordTypeId = false; //Added for the story BAC-5372
                        
                        System.debug('After querying child mapObjectNameVsListOfFields: '+ExpParssig.mapObjectNameVsListOfFields); //Added for the story BAC-4264
                        //------End----Added for optimization
                        
                        /*Commented for optimization
                        //Added by Nidhi as part of LAzy Loading BAC-4680 Ends Here
                        //lstTargetChildRecord = BuildSobject.getSFM_BuildSobject(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null);
                        if(mapObjectAPINameWithFields.containskey(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c)){
                            strQueryFields = BuildSobject.buildQueryStringFromSet(mapObjectAPINameWithFields.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c));
                            //system.debug('blaaaa'+mapObjectAPINameWithFields.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c));
                            if(mapSortingFields.containskey(s)){
                                BuildSobject.calledFromWhere = 'SFM_ParseProcess'; //Added for the story BAC-4264
                                BuildSobject.isDetailRecordQuery = true;//Added by Nidhi as part of Lazy Loading BAC-4680
                                if(mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c == null){
                                    BuildSobject.isSubmoduleEmpty = true;
                                }
                                lstTargetChildRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null,mapObjectAPINameWithFields.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c),mapSortingFields.get(s));
                                BuildSobject.calledFromWhere = null; //Added for the story BAC-4264
                                BuildSobject.isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                                BuildSobject.isSubmoduleEmpty = false;
                            }else{
                                BuildSobject.calledFromWhere = 'SFM_ParseProcess'; //Added for the story BAC-4264
                                BuildSobject.isDetailRecordQuery = true;//Added by Nidhi as part of Lazy Loading BAC-4680
                                if(mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c == null){
                                    BuildSobject.isSubmoduleEmpty = true;
                                }
                                lstTargetChildRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null,mapObjectAPINameWithFields.get(mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c),null);
                                BuildSobject.calledFromWhere = null; //Added for the story BAC-4264
                                BuildSobject.isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                                BuildSobject.isSubmoduleEmpty = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                            }   
                        }else{
                            if(mapSortingFields.containskey(s)){
                                BuildSobject.calledFromWhere = 'SFM_ParseProcess'; //Added for the story BAC-4264
                                BuildSobject.isDetailRecordQuery = true;//Added by Nidhi as part of Lazy Loading BAC-4680
                                if(mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c == null){
                                    BuildSobject.isSubmoduleEmpty = true;
                                }
                                lstTargetChildRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null,null,mapSortingFields.get(s));
                                BuildSobject.calledFromWhere = null; //Added for the story BAC-4264
                                BuildSobject.isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                                BuildSobject.isSubmoduleEmpty = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                            }else{
                                BuildSobject.calledFromWhere = 'SFM_ParseProcess'; //Added for the story BAC-4264
                                BuildSobject.isDetailRecordQuery = true;//Added by Nidhi as part of Lazy Loading BAC-4680
                                if(mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c == null){
                                    BuildSobject.isSubmoduleEmpty = true;
                                }
                                lstTargetChildRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c,null,null,null);
                                BuildSobject.calledFromWhere = null; //Added for the story BAC-4264
                                BuildSobject.isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                                BuildSobject.isSubmoduleEmpty = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                            }
                        }
                        */
                    }
                    System.debug('After querying child mapObjectNameVsListOfFields: '+BuildSobject.mapObjectNameVsListOfFields); //Added for the story BAC-4264
                    SFM_GetData.mapDetailTabIdFieldList.put(s,strQueryFields);
                    
                    //Added by Nidhi as part of lazy loading BAC-4680, to capture the where clause for jsrgetpagedatav2.
                    String finalWhereClause = mapAliasNameChildNode.get(s).SVMXC__Parent_Column_Name__c+'=\''+strRecordId+'\'';
                    if(mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null){
                        finalWhereClause = finalWhereClause + ' And (' + mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c +')';
                    }
                    SFM_GetData.mapAliasNameWhereClause.put(s,finalWhereClause);
                    //Added by Nidhi Ends here
                    system.debug(LoggingLevel.WARN,'lstTargetChildRecord'+lstTargetChildRecord);
                    /*Commented for optimization
                    //Expression Qualification..
                    if(lstTargetChildRecord.size() > 0 && mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null){
                        if(strQueryFields != ''){
                            if(mapSortingFields.containskey(s)){
                                    //This is commented and called correct method as part of defect BAC-3393 fix - wrong overloaded method called here
                                //lstTargetChildRecord = ExpParssig.SFM_ParseExpression1(lstTargetChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,mapSortingFields.get(s));
                                ExpParssig.isDetailRecordQuery = true;//Added by Nidhi as part of Lazy Loading BAC-4680
                                lstTargetChildRecord = ExpParssig.SFM_ParseExpression1(lstTargetChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryFields,mapSortingFields.get(s));
                                ExpParssig.isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                            }
                            else{
                                ExpParssig.isDetailRecordQuery = true;//Added by Nidhi as part of Lazy Loading BAC-4680
                                lstTargetChildRecord = ExpParssig.SFM_ParseExpression1(lstTargetChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryFields); 
                                ExpParssig.isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                            }
                        }   
                        else{
                            
                            if(mapSortingFields.containskey(s)){
                                ExpParssig.isDetailRecordQuery = true;//Added by Nidhi as part of Lazy Loading BAC-4680
                                lstTargetChildRecord = ExpParssig.SFM_ParseExpression1(lstTargetChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,null,mapSortingFields.get(s));
                                ExpParssig.isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                            }
                            else{
                                ExpParssig.isDetailRecordQuery = true;//Added by Nidhi as part of Lazy Loading BAC-4680
                                lstTargetChildRecord = ExpParssig.SFM_ParseExpression1(lstTargetChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c);
                                ExpParssig.isDetailRecordQuery = false;//Added by Nidhi as part of Lazy Loading BAC-4680
                            }   
                        }          
                        system.debug(LoggingLevel.WARN,'lstTargetChildRecord'+lstTargetChildRecord);
                    }
                    
                    */
                    if(lstTargetChildRecord.size() > 0)
                        mapDetailRecord.put(s,lstTargetChildRecord);
                    system.debug(LoggingLevel.WARN,'mapDetailRecord'+mapDetailRecord.size()+mapDetailRecord); 
                }
            //}
            mapObjectNameVsListOfFields = BuildSobject.mapObjectNameVsListOfFields; //Added for the story BAC-4264
            if(ExpParssig.mapObjectNameVsListOfFields.size() > 0){
                mapObjectNameVsListOfFields.putAll(ExpParssig.mapObjectNameVsListOfFields);
            }
        }
        // 4. SOURCE TO TARGET ALL
        else if(objSFMProcess.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL')
        {
            
            //First Get Source Header Record
            list<SObject> lstSourceHeaderRecord = new list<SObject>();
            list<Sobject> lstTargetHeaderRecord = new list<Sobject>();
            
            //------Start------This is commented for code optimization BAC-2993----//
            /*if(strHeaderSourceObject != null && strHeaderSourceObject.length() > 0){
                if(strHeaderMapId != null && strHeaderMapId.length() > 0 && mapMappingIdSourceFields.containskey(strHeaderMapId)){
                    strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(strHeaderMapId));
                    lstSourceHeaderRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,strHeaderSourceObject,null,strQueryField);
                }
                else{
                    strQueryField = 'Id';
                    lstSourceHeaderRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,strHeaderSourceObject,null,strQueryField);
                }
            }
            //lstSourceHeaderRecord = BuildSobject.getSFM_BuildSobject(strRecordId,strHeaderSourceObject,null,null);       
            system.debug(LoggingLevel.WARN,'Query issued'+Limits.getQueries());
            system.debug(LoggingLevel.WARN,'lstSourceHeaderRecord'+lstSourceHeaderRecord);
            //Qualify Source Record first..
            if(strHeaderExpressionObjectName != null && strHeaderExpressionObjectName.length() > 0 && strHeaderExpressionWhereClause != null && strHeaderExpressionWhereClause.length() > 0 && lstSourceHeaderRecord.size() > 0) 
            {
                lstSourceHeaderRecord = ExpParssig.SFM_ParseExpression1(lstSourceHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause,strQueryField);
                system.debug(LoggingLevel.WARN,'lstSourceHeaderRecord'+lstSourceHeaderRecord);
            }*/
            //------End------This is commented for code optimization BAC-2993----//

            //------Start------Added for code optimization BAC-2993----//
            if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Check added as part of story BAC-3256
                    if(String.isNotBlank(strHeaderSourceObject)){  //#optiChange
                    if(String.isNotBlank(strHeaderMapId) && mapMappingIdSourceFields.containskey(strHeaderMapId)){ //#optiChange
                        strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(strHeaderMapId));
                        lstSourceHeaderRecord = ExpParssig.SFM_GetRecordsAfterApplyingCriteria(strRecordId, strHeaderSourceObject, null, strHeaderExpressionWhereClause, strQueryField, null);
                    }
                    else{
                        strQueryField = 'Id';
                        lstSourceHeaderRecord = ExpParssig.SFM_GetRecordsAfterApplyingCriteria(strRecordId, strHeaderSourceObject, null, strHeaderExpressionWhereClause, strQueryField, null);
                    }
                }
                System.debug(LoggingLevel.WARN,'Query issued: '+Limits.getQueries());
                System.debug(LoggingLevel.WARN,'lstSourceHeaderRecord: '+lstSourceHeaderRecord);
            }
            else{
                    //if(strHeaderSourceObject != null && strHeaderSourceObject.length() > 0){ //#optiChange
                    if(String.isNotBlank(strHeaderSourceObject)){
                   // if(strHeaderMapId != null && strHeaderMapId.length() > 0 && mapMappingIdSourceFields.containskey(strHeaderMapId)){ //#optiChange
                    if(String.isNotBlank(strHeaderMapId) && mapMappingIdSourceFields.containskey(strHeaderMapId)){
                        strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(strHeaderMapId));
                        lstSourceHeaderRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,strHeaderSourceObject,null,strQueryField);
                    }
                    else{
                        strQueryField = 'Id';
                        lstSourceHeaderRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,strHeaderSourceObject,null,strQueryField);
                    }
                }
                //lstSourceHeaderRecord = BuildSobject.getSFM_BuildSobject(strRecordId,strHeaderSourceObject,null,null);       
                system.debug(LoggingLevel.WARN,'Query issued'+Limits.getQueries());
                system.debug(LoggingLevel.WARN,'lstSourceHeaderRecord'+lstSourceHeaderRecord);
                //Qualify Source Record first..
                if(strHeaderExpressionObjectName != null && strHeaderExpressionObjectName.length() > 0 && strHeaderExpressionWhereClause != null && strHeaderExpressionWhereClause.length() > 0 && lstSourceHeaderRecord.size() > 0) 
                {
                    lstSourceHeaderRecord = ExpParssig.SFM_ParseExpression1(lstSourceHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause,strQueryField);
                    system.debug(LoggingLevel.WARN,'lstSourceHeaderRecord'+lstSourceHeaderRecord);
                }
            }
            //------End-------Added for code optimization BAC-2993----//

            if(lstSourceHeaderRecord.size() > 0)
            {
                //if Target header sobject is passed then don't create it from source Header Sobject. Target is already created. (e.g.  This is multi source process and it's target is already create from first source)
                if(objTargetHeaderSobject != null)
                {
                    lstTargetHeaderRecord.add(objTargetHeaderSobject);
                }
                else //If Target header Sobject is not passed then create new Target Header Sobject.
                {
                    if(strHeaderTargetObject != null && strHeaderTargetObject.length() > 0)
                        lstTargetHeaderRecord = BuildSobject.getSFM_BuildSobject(null,strHeaderTargetObject,null,null);
                }       
                system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord: '+lstTargetHeaderRecord);

                //--------Start---------Added for fixing defect BAC-3299----------////Check added as part of story BAC-3256
                if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled && mapObjectAPINameWithFields != null && mapObjectAPINameWithFields.size() > 0 && mapObjectAPINameWithFields.containsKey(strHeaderTargetObject) && lstTargetHeaderRecord != null && lstTargetHeaderRecord.size() > 0){
                    Set<String> setTargetFields = mapObjectAPINameWithFields.get(strHeaderTargetObject);
                    Map<String,Schema.SObjectField> mapTargetFieldDesc = COMM_Utils_DescribeCall.getObjectFieldDetails(strHeaderTargetObject); //Added for the defect fix 047517
                    for(String strField: setTargetFields){
                        if(mapTargetFieldDesc.containsKey(strField)){
                            Schema.DescribeFieldResult fieldDescribe = mapTargetFieldDesc.get(strField).getDescribe();
                            if(fieldDescribe.isCreateable()){
                                lstTargetHeaderRecord[0].put(strField, null);
                            }
                        }
                    }
                    System.debug(LoggingLevel.WARN,'lstTargetHeaderRecord after fieldset: '+lstTargetHeaderRecord);
                }
                //--------End-----------Added for fixing defect BAC-3299----------//

                //Apply Mapping 
                if(lstTargetHeaderRecord.size() > 0 && strHeaderMapId != null && strHeaderMapId.length() > 0 && strHeaderMappingSourceObjectName != null && strHeaderMappingSourceObjectName.length() > 0 && strHeaderMappingTargetObjectName != null && strHeaderMappingTargetObjectName.length() > 0){ 
                    //Applymapping.applyMappingForHeader(lstTargetHeaderRecord,strHeaderMapId,strRecordId,true,mapAllObjectDescribe,strHeaderMappingSourceObjectName,strHeaderMappingTargetObjectName);
                    lstTargetHeaderRecord = Applymapping.applyMappingForHeader(lstTargetHeaderRecord,strHeaderMapId,strRecordId,true,mapAllObjectDescribe,strHeaderMappingSourceObjectName,strHeaderMappingTargetObjectName,lstSourceHeaderRecord[0]);
                }
                system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                if(lstTargetHeaderRecord.size() > 0)
                {
                    map<String,Sobject> mapSourceRecordIdTargetRecord = new map<String,Sobject>();
                    mapSourceRecordIdTargetRecord.put(strRecordId,lstTargetHeaderRecord[0]);
                    mapTemp.put(strHeaderTargetObject,mapSourceRecordIdTargetRecord);
                }
                system.debug(LoggingLevel.WARN,'Query issued'+Limits.getQueries());
            }
               
            //Now Process Target Details 
            if(mapAliasNameChildNode.size() > 0)
            {
                for(String s : mapAliasNameChildNode.keyset())
                {
                    system.debug(LoggingLevel.WARN,'Query issued'+Limits.getQueries());
                    list<Sobject> lstSourceChildRecord = new list<Sobject>(); 
                    list<Sobject> lstTargetChildRecord = new list<Sobject>();
                   
                    //------Start------This is commented for code optimization BAC-2993----//
                    /*
                    //Get the Sorce Child Records for Qualification 
                    if(mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null )//
                    {
                        String strSourceParentColumnName = 'Id';
                        if(mapAliasNameParentColumnName.containskey(s))
                            strSourceParentColumnName = mapAliasNameParentColumnName.get(s);
                        system.debug('strSourceParentColumnName'+strSourceParentColumnName);
                        //lstSourceChildRecord = BuildSobject.getSFM_BuildSobject(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,null);
                        if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null && mapMappingIdSourceFields.containskey(mapAliasNameChildNode.get(s).SVMXC__Module__c)){
                            strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(mapAliasNameChildNode.get(s).SVMXC__Module__c));
                        }
                        else{
                            strQueryField = 'Id';
                        }
                        if(mapSortingFields.containskey(s)){
                            lstSourceChildRecord = BuildSobject.SFM_buildSourceRecordsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,strQueryField,mapSortingFields.get(s));
                        }
                        else{
                            lstSourceChildRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,strQueryField);
                        }   
                        system.debug(LoggingLevel.WARN,'Query issued'+Limits.getQueries());
                    }   
                    system.debug(LoggingLevel.WARN,'lstSourceChildRecord'+lstSourceChildRecord);
                    
                    //Qualify Source Child Records.   
                    if(lstSourceChildRecord.size() > 0 && mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null)
                    {
                        if(mapSortingFields.containskey(s)){
                            lstSourceChildRecord = ExpParssig.SFM_ParseExpression1(lstSourceChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryField,mapSortingFields.get(s));
                        }
                        else{
                            lstSourceChildRecord = ExpParssig.SFM_ParseExpression1(lstSourceChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryField);
                        }      
                        system.debug(LoggingLevel.WARN,'lstSourceChildRecord'+lstSourceChildRecord);
                    }*/
                    //------End------This is commented for code optimization BAC-2993----//

                    //------Start------Added for code optimization BAC-2993----//
                    if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Check added as part of story BAC-3256
                            if(mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null )//
                        {
                            String strSortingClause = '';
                            String strWhereClause = '';
                            String strSourceParentColumnName = 'Id';
    
                            if(mapAliasNameParentColumnName.containskey(s))
                                strSourceParentColumnName = mapAliasNameParentColumnName.get(s);
    
                            if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null && mapMappingIdSourceFields.containskey(mapAliasNameChildNode.get(s).SVMXC__Module__c)){
                                strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(mapAliasNameChildNode.get(s).SVMXC__Module__c));
                            }
                            else{
                                strQueryField = 'Id';
                            }
                            
                            if(mapSortingFields.containskey(s)){
                                strSortingClause = mapSortingFields.get(s);
                            }
                            if(mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null){
                                strWhereClause = mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c;
                            }
                            //Added this if condition for the story BAC-4665
                            if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null){
                                lstSourceChildRecord = ExpParssig.SFM_GetRecordsAfterApplyingCriteria(strRecordId, mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c, strSourceParentColumnName, strWhereClause, strQueryField, strSortingClause);
                            }
    
                            System.debug(LoggingLevel.WARN,'Query issued'+Limits.getQueries());
                        }   
                        System.debug(LoggingLevel.WARN,'lstSourceChildRecord'+lstSourceChildRecord);
                    }
                    else{
                            //Get the Sorce Child Records for Qualification 
                        if(mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null )//
                        {
                            String strSourceParentColumnName = 'Id';
                            if(mapAliasNameParentColumnName.containskey(s))
                                strSourceParentColumnName = mapAliasNameParentColumnName.get(s);
                            system.debug('strSourceParentColumnName'+strSourceParentColumnName);
                            //lstSourceChildRecord = BuildSobject.getSFM_BuildSobject(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,null);
                            if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null && mapMappingIdSourceFields.containskey(mapAliasNameChildNode.get(s).SVMXC__Module__c)){
                                strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(mapAliasNameChildNode.get(s).SVMXC__Module__c));
                            }
                            else{
                                strQueryField = 'Id';
                            }
                            //Added this if condition for the story BAC-4665
                            if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null){
                                if(mapSortingFields.containskey(s)){
                                    lstSourceChildRecord = BuildSobject.SFM_buildSourceRecordsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,strQueryField,mapSortingFields.get(s));
                                }
                                else{
                                    lstSourceChildRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,strQueryField);
                                } 
                            }
                            system.debug(LoggingLevel.WARN,'Query issued'+Limits.getQueries());
                        }   
                        system.debug(LoggingLevel.WARN,'lstSourceChildRecord'+lstSourceChildRecord);
                        
                        //Qualify Source Child Records.   
                        if(lstSourceChildRecord.size() > 0 && mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null)
                        {
                            if(mapSortingFields.containskey(s)){
                                lstSourceChildRecord = ExpParssig.SFM_ParseExpression1(lstSourceChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryField,mapSortingFields.get(s));
                            }
                            else{
                                lstSourceChildRecord = ExpParssig.SFM_ParseExpression1(lstSourceChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryField);
                            }      
                            system.debug(LoggingLevel.WARN,'lstSourceChildRecord'+lstSourceChildRecord);
                        }
                    }
                    //------End------Added for code optimization BAC-2993----//

                    //For the number qualified source record create number of target records
                    if(lstSourceChildRecord.size() > 0 )
                    {
                        lstTargetChildRecord = BuildSobject.getSFM_BuildSobject(null,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,null,lstSourceChildRecord.size());
                        system.debug(LoggingLevel.WARN,'lstTargetChildRecord'+lstTargetChildRecord);
                    } 
                    //From Source and Target Create map of Source Record Id Target Record.
                    if(lstTargetChildRecord.size() > 0 && lstSourceChildRecord.size() > 0) 
                    {
                        map<String,Sobject> mapSourceRecordIdTargetRecord = new map<String,Sobject>();
                        for(Integer i = 0;i< lstSourceChildRecord.size();i++)
                        {
                            if(lstSourceChildRecord[i].get('Id') != null)
                                mapSourceRecordIdTargetRecord.put(String.valueof(lstSourceChildRecord[i].get('Id')),lstTargetChildRecord[i]);
                        }
                        system.debug(LoggingLevel.WARN,'mapSourceRecordIdTargetRecord'+mapSourceRecordIdTargetRecord);
                        //Apply mapping..
                        if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null)
                        {
                            String strMappingId = String.valueOf(mapAliasNameChildNode.get(s).SVMXC__Module__c);
                            if(mapMappingIdSourceObjectName.containskey(strMappingId) && mapMappingIdTargetObjectName.containskey(strMappingId) && mapMappingIdFieldMappingList.containskey(strMappingId) && lstTargetHeaderRecord.size() > 0)
                                mapSourceRecordIdTargetRecord = Applymapping.applyMappingForDetail(String.valueof(mapAliasNameChildNode.get(s).SVMXC__Module__c),mapSourceRecordIdTargetRecord,false,mapAllObjectDescribe,mapMappingIdSourceObjectName.get(strMappingId),mapMappingIdTargetObjectName.get(strMappingId),mapMappingIdFieldMappingList.get(strMappingId),lstTargetHeaderRecord[0]);
                            system.debug(LoggingLevel.WARN,'mapSourceRecordIdTargetRecord'+mapSourceRecordIdTargetRecord);
                            mapTemp.put(s,mapSourceRecordIdTargetRecord);
                        }
                        else
                        {
                            mapTemp.put(s,mapSourceRecordIdTargetRecord);
                        }   
                            
                    }
                    system.debug(LoggingLevel.WARN,'mapTemp'+mapTemp.size()+mapTemp);
                }
            }
        }
        // 5. SOURCE TO TARGET CHILD..
        else if(objSFMProcess.SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD')
        {
            system.debug(LoggingLevel.WARN,'Enter in SOURCE TO TARGET CHILD Process mode');
            
            //In this process we need to create only target child records from source child records. So Header Record is already available 
            list<Sobject> lstTargetHeaderRecord = new list<Sobject>();
            if(strHeaderTargetObject != null && strHeaderTargetObject.length() > 0)
            {
                String strQueryFields = '';
                //------Start------This is commented for code optimization BAC-2993----//
                /*
                //lstTargetHeaderRecord =  BuildSobject.getSFM_BuildSobject(strRecordId,strHeaderTargetObject,null,null);
                if(mapObjectAPINameWithFields.containskey(strHeaderTargetObject)){
                    strQueryFields = BuildSobject.buildQueryStringFromSet(mapObjectAPINameWithFields.get(strHeaderTargetObject));
                    lstTargetHeaderRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,strHeaderTargetObject,null,null,mapObjectAPINameWithFields.get(strHeaderTargetObject),null);
                }
                else{
                    lstTargetHeaderRecord = BuildSobject.getSFM_BuildSobject(strRecordId,strHeaderTargetObject,null,null);
                }
                system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                //Expression Qualification...
                if(strHeaderExpressionObjectName != null && strHeaderExpressionObjectName.length() > 0 && strHeaderExpressionWhereClause != null && strHeaderExpressionWhereClause.length() > 0 && lstTargetHeaderRecord.size() > 0) 
                {
                    if(strQueryFields != '')
                        lstTargetHeaderRecord = ExpParssig.SFM_ParseExpression1(lstTargetHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause,strQueryFields);
                    else
                        lstTargetHeaderRecord = ExpParssig.SFM_ParseExpression1(lstTargetHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause);   
                    system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                }*/
                //------End------This is commented for code optimization BAC-2993----//

                //------Start------Added for code optimization BAC-2993----//
                if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Check added as part of story BAC-3256
                        if(mapObjectAPINameWithFields.containskey(strHeaderTargetObject)){
                        strQueryFields = BuildSobject.buildQueryStringFromSet(mapObjectAPINameWithFields.get(strHeaderTargetObject));
                    }
                    ExpParssig.calledFromWhere = 'SFM_ParseProcess'; //Added for the story BAC-4264
                    ExpParssig.isQueryRecordTypeId = true; //Added for the story BAC-5372
                    lstTargetHeaderRecord = ExpParssig.SFM_GetRecordsAfterApplyingCriteria(strRecordId, strHeaderTargetObject, null, strHeaderExpressionWhereClause, strQueryFields, null);
                    ExpParssig.calledFromWhere = null; //Added for the story BAC-4264
                    ExpParssig.isQueryRecordTypeId = false; //Added for the story BAC-5372
                    mapObjectNameVsListOfFields = ExpParssig.mapObjectNameVsListOfFields; //Added for the story BAC-4264
                    System.debug('mapObjectNameVsListOfFields: '+ExpParssig.mapObjectNameVsListOfFields); //Added for the story BAC-4264
                    System.debug(LoggingLevel.WARN,'lstTargetHeaderRecord: '+lstTargetHeaderRecord);
                }
                else{
                    if(mapObjectAPINameWithFields.containskey(strHeaderTargetObject)){
                        strQueryFields = BuildSobject.buildQueryStringFromSet(mapObjectAPINameWithFields.get(strHeaderTargetObject));
                        BuildSobject.calledFromWhere = 'SFM_ParseProcess'; //Added for the story BAC-4264
                        BuildSobject.isQueryRecordTypeId = true; //Added for the story BAC-5372
                        lstTargetHeaderRecord = BuildSobject.SFM_buildTargetSobjectFromInputFieldsWithSorting(strRecordId,strHeaderTargetObject,null,null,mapObjectAPINameWithFields.get(strHeaderTargetObject),null);
                        BuildSobject.calledFromWhere = null; //Added for the story BAC-4264
                        BuildSobject.isQueryRecordTypeId = false; //Added for the story BAC-5372
                    }
                    else{
                        BuildSobject.calledFromWhere = 'SFM_ParseProcess'; //Added for the story BAC-4264
                        lstTargetHeaderRecord = BuildSobject.getSFM_BuildSobject(strRecordId,strHeaderTargetObject,null,null);
                        BuildSobject.calledFromWhere = null; //Added for the story BAC-4264
                    }
                    mapObjectNameVsListOfFields = BuildSobject.mapObjectNameVsListOfFields; //Added for the story BAC-4264
                    System.debug('mapObjectNameVsListOfFields: '+BuildSobject.mapObjectNameVsListOfFields); //Added for the story BAC-4264
                    system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                    //Expression Qualification...
                    if(strHeaderExpressionObjectName != null && strHeaderExpressionObjectName.length() > 0 && strHeaderExpressionWhereClause != null && strHeaderExpressionWhereClause.length() > 0 && lstTargetHeaderRecord.size() > 0) 
                    {
                        if(strQueryFields != ''){
                            ExpParssig.isQueryRecordTypeId = true; //Added for the story BAC-5372
                            lstTargetHeaderRecord = ExpParssig.SFM_ParseExpression1(lstTargetHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause,strQueryFields);
                            ExpParssig.isQueryRecordTypeId = false; //Added for the story BAC-5372
                        }
                        else
                            lstTargetHeaderRecord = ExpParssig.SFM_ParseExpression1(lstTargetHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause);   
                        system.debug(LoggingLevel.WARN,'lstTargetHeaderRecord'+lstTargetHeaderRecord);
                    }
                }
                //------End------Added for code optimization BAC-2993----//

                if(lstTargetHeaderRecord.size() > 0 )
                {
                    map<String,Sobject> mapSourceRecordIdTargetRecord = new map<String,Sobject>();
                    mapSourceRecordIdTargetRecord.put('NOSOURCEID',lstTargetHeaderRecord[0]);
                    mapTemp.put(strHeaderTargetObject,mapSourceRecordIdTargetRecord);
                }   
            }
            for(String s : mapAliasNameChildNode.keyset())
            {
                //Commented this line and removed one condition to fixing defect BAC-4014
                //if(strHeaderSourceObject != null && strHeaderSourceObject.length() > 0 && mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null && strHeaderSourceObject.toUpperCase() != mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c.touppercase())
                if(strHeaderSourceObject != null && strHeaderSourceObject.length() > 0 && mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null)
                {
                    list<Sobject> lstSourceChildRecord = new list<Sobject>(); 
                    list<Sobject> lstTargetChildRecord = new list<Sobject>();

                    //------Start------This is commented for code optimization BAC-2993----//
                    //get the Sorce object Records to calculate how many target to be created
                    /*if(mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null && mapAliasNameParentColumnName.containskey(s))
                    {
                        String strSourceParentColumnName = mapAliasNameParentColumnName.get(s);
                        //lstSourceChildRecord = BuildSobject.getSFM_BuildSobject(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,null);
                        if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null && mapMappingIdSourceFields.containskey(mapAliasNameChildNode.get(s).SVMXC__Module__c)){
                            strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(mapAliasNameChildNode.get(s).SVMXC__Module__c));
                        }else{
                            strQueryField = 'Id';
                        }
                        if(mapSortingFields.containskey(s)){
                            lstSourceChildRecord = BuildSobject.SFM_buildSourceRecordsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,strQueryField,mapSortingFields.get(s));
                        }else{
                            lstSourceChildRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,strQueryField);
                        }
                    }
                    system.debug(LoggingLevel.WARN,'strQueryField'+strQueryField);
                    system.debug(LoggingLevel.WARN,'lstSourceChildRecord'+lstSourceChildRecord.size()+lstSourceChildRecord);
                    if(lstSourceChildRecord.size() > 0 )
                        lstTargetChildRecord = BuildSobject.getSFM_BuildSobject(null,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,null,lstSourceChildRecord.size());
                    system.debug(LoggingLevel.WARN,'lstTargetChildRecord'+lstTargetChildRecord.size()+lstTargetChildRecord);
                    //Expression Qualification...   
                    if(lstSourceChildRecord.size() > 0 && mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null)
                    {
                        if(mapSortingFields.containskey(s)){
                            lstSourceChildRecord = ExpParssig.SFM_ParseExpression1(lstSourceChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryField,mapSortingFields.get(s));
                        }
                        else{
                            lstSourceChildRecord = ExpParssig.SFM_ParseExpression1(lstSourceChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryField);
                        }    
                        system.debug(LoggingLevel.WARN,'lstSourceChildRecord'+lstSourceChildRecord);
                    }*/
                    //------End------This is commented for code optimization BAC-2993----//

                    //------Start------Added for code optimization BAC-2993----//
                    if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Check added as part of story BAC-3256
                        String strSourceParentColumnName = '';
                        String strSourceObjectName = '';
                        String strSortingClause = '';
                        String strWhereClause = '';
    
                        //if(mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null && mapAliasNameParentColumnName.containskey(s)){ //Commented this line and added below additional condition line to fixing defect BAC-4014
                        if(mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null && (mapAliasNameParentColumnName.containskey(s) || strHeaderSourceObject.toUpperCase() == mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c.touppercase())){
                            //strSourceParentColumnName = mapAliasNameParentColumnName.get(s); //Commented this line and added below line to fixing defect BAC-4014
                            strSourceParentColumnName = mapAliasNameParentColumnName.containskey(s) ? mapAliasNameParentColumnName.get(s) : null;
                            if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null && mapMappingIdSourceFields.containskey(mapAliasNameChildNode.get(s).SVMXC__Module__c)){
                                strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(mapAliasNameChildNode.get(s).SVMXC__Module__c));
                            }else{
                                strQueryField = 'Id';
                            }
                            if(mapSortingFields.containskey(s)){
                                strSortingClause = mapSortingFields.get(s);
                            }
                            strSourceObjectName = mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c;
                        }
                        
                        //Expression Qualification...   
                        if(mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null){
                            strWhereClause = mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c;
                        }
    
                        //Added this if condition for the story BAC-4665
                        if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null) {
                            lstSourceChildRecord = ExpParssig.SFM_GetRecordsAfterApplyingCriteria(strRecordId, strSourceObjectName, strSourceParentColumnName, strWhereClause, strQueryField, strSortingClause);
                            System.debug(LoggingLevel.WARN,'lstSourceChildRecord: '+lstSourceChildRecord);  
                        }
    
                        if(lstSourceChildRecord.size() > 0)
                            lstTargetChildRecord = BuildSobject.getSFM_BuildSobject(null,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,null,lstSourceChildRecord.size());
                        System.debug(LoggingLevel.WARN,'lstTargetChildRecord'+lstTargetChildRecord.size()+lstTargetChildRecord);
                    }
                    else{
                        //get the Sorce object Records to calculate how many target to be created
                        //if(mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null && mapAliasNameParentColumnName.containskey(s) ) //Commented this line and added below additional condition line to fixing defect BAC-4014
                        if(mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c != null && (mapAliasNameParentColumnName.containskey(s) || strHeaderSourceObject.toUpperCase() == mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c.touppercase()))
                        {
                            //Commented this line and added below line to fixing defect BAC-4014
                            //String strSourceParentColumnName = mapAliasNameParentColumnName.get(s);
                            String strSourceParentColumnName = mapAliasNameParentColumnName.containskey(s) ? mapAliasNameParentColumnName.get(s) : null;
                            //lstSourceChildRecord = BuildSobject.getSFM_BuildSobject(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,null);
                            if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null && mapMappingIdSourceFields.containskey(mapAliasNameChildNode.get(s).SVMXC__Module__c)){
                                strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(mapAliasNameChildNode.get(s).SVMXC__Module__c));
                            }else{
                                strQueryField = 'Id';
                            }
                            //Added this if condition for the story BAC-4665
                            if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null){
                                if(mapSortingFields.containskey(s)){
                                    lstSourceChildRecord = BuildSobject.SFM_buildSourceRecordsWithSorting(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,strQueryField,mapSortingFields.get(s));
                                }else{
                                    lstSourceChildRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,mapAliasNameChildNode.get(s).SVMXC__Node_Source_Object_API__c,strSourceParentColumnName,strQueryField);
                                }
                            }
                        }
                        system.debug(LoggingLevel.WARN,'strQueryField'+strQueryField);
                        system.debug(LoggingLevel.WARN,'lstSourceChildRecord'+lstSourceChildRecord.size()+lstSourceChildRecord);
                        if(lstSourceChildRecord.size() > 0 )
                            lstTargetChildRecord = BuildSobject.getSFM_BuildSobject(null,mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c,null,lstSourceChildRecord.size());
                        system.debug(LoggingLevel.WARN,'lstTargetChildRecord'+lstTargetChildRecord.size()+lstTargetChildRecord);
                        //Expression Qualification...   
                        if(lstSourceChildRecord.size() > 0 && mapAliasNameChildNode.get(s).SVMXC__Submodule__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null && mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c != null)
                        {
                            if(mapSortingFields.containskey(s)){
                                lstSourceChildRecord = ExpParssig.SFM_ParseExpression1(lstSourceChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryField,mapSortingFields.get(s));
                            }
                            else{
                                lstSourceChildRecord = ExpParssig.SFM_ParseExpression1(lstSourceChildRecord,null,mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, mapAliasNameChildNode.get(s).SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,strQueryField);
                            }    
                            system.debug(LoggingLevel.WARN,'lstSourceChildRecord'+lstSourceChildRecord);
                        }
                    }
                    //------End------Added for code optimization BAC-2993----//

                    //From Qualified Source Records Create Target Record..
                    if(lstTargetChildRecord.size() > 0 && lstSourceChildRecord.size() > 0) 
                    {
                        map<String,Sobject> mapSourceRecordIdTargetRecord = new map<String,Sobject>();
                        for(Integer i = 0;i< lstSourceChildRecord.size();i++)
                        {
                            if(lstSourceChildRecord[i].get('Id') != null)
                                mapSourceRecordIdTargetRecord.put(String.valueof(lstSourceChildRecord[i].get('Id')),lstTargetChildRecord[i]);
                        }
                        //Apply mapping..
                        if(mapAliasNameChildNode.get(s).SVMXC__Module__c != null)
                        {
                            String strMappingId = String.valueOf(mapAliasNameChildNode.get(s).SVMXC__Module__c);
                            if(mapMappingIdSourceObjectName.containskey(strMappingId) && mapMappingIdTargetObjectName.containskey(strMappingId) && mapMappingIdFieldMappingList.containskey(strMappingId))
                                mapSourceRecordIdTargetRecord = Applymapping.applyMappingForDetail(String.valueof(mapAliasNameChildNode.get(s).SVMXC__Module__c),mapSourceRecordIdTargetRecord,false,mapAllObjectDescribe,mapMappingIdSourceObjectName.get(strMappingId),mapMappingIdTargetObjectName.get(strMappingId),mapMappingIdFieldMappingList.get(strMappingId),lstTargetHeaderRecord[0]);
                            system.debug(LoggingLevel.WARN,'mapSourceRecordIdTargetRecord'+mapSourceRecordIdTargetRecord);
                            mapTemp.put(s,mapSourceRecordIdTargetRecord);
                        }
                        else
                        {
                            mapTemp.put(s,mapSourceRecordIdTargetRecord);
                        }   
                            
                    }
                }
            }    
        }
        else if(objSFMProcess.SVMXC__Purpose__c.touppercase() == 'CHECKLIST'){
            if(lstSFMStringMap != null && lstSFMStringMap.size() > 0){
                String ckProcessId ;
                String ckRecordId;
                String ckTargetId;
                 list<Decimal> lstChkTargetGroupid = new list<Decimal>();  
                      
                for(SVMXC.SFM_WrapperDef.SFM_StringMap stringMapItr: lstSFMStringMap){
                    if(stringMapItr.key.touppercase() == 'PROCESSID')
                        ckProcessId = stringMapItr.value;
                    else if(stringMapItr.key.touppercase() == 'RECORDID')
                        ckRecordId = stringMapItr.value;
                    else if(stringMapItr.key.touppercase() == 'TARGETID')
                        ckTargetId = stringMapItr.value;
                }
                List<SVMXC__Checklist__c> lstChecklist = new List<SVMXC__Checklist__c>();
                
                /*commented for the defect 023796 fix
                if(ckTargetId != null)
                    lstChecklist = [SELECT Id, SVMXC__ChecklistJSON__c, SVMXC__ChecklistMetaJSON__c, SVMXC__Completed_By__c, SVMXC__Completed_On__c, SVMXC__Status__c, SVMXC__What_Id__c, SVMXC__ChecklistProcessID__c FROM SVMXC__Checklist__c WHERE Id = : ckTargetId];  
                */

                //Apurva
                
                list<SVMXC__Checklist__c> lstChk= new list<SVMXC__Checklist__c>([SELECT SVMXC__SM_Checklist_Group_Id__c FROM SVMXC__Checklist__c WHERE Id =: ckTargetId]);
                
                
                for(SVMXC__Checklist__c obj:lstChk)
                {
                    if(obj.SVMXC__SM_Checklist_Group_Id__c != null )
                    {
                        lstChkTargetGroupid.add(obj.SVMXC__SM_Checklist_Group_Id__c);
                    }
                }

            system.debug(LoggingLevel.WARN,'lstChkTargetGroupid:'+lstChkTargetGroupid.size()+' : '+lstChkTargetGroupid);
                //Added for the defect 023796 fix
                
                    String strQuery = '';
                    Map<String, Schema.SobjectField> mapFieldMap = new Map<String, Schema.SobjectField>();
                    List<String> lstFields = new List<String>();
                    //COMM_Utils objCommUtils = new COMM_Utils();
                    COMM_Utils_V2 objCommUtils = new COMM_Utils_V2();
                    String strSOQLFields = '';

                    mapFieldMap = Schema.SObjectType.SVMXC__Checklist__c.fields.getMap();
                    lstFields = objCommUtils.SVMX_getFieldList(mapFieldMap, true); //Changed to true for fixing ownerId issue BAC-4482
                    strSOQLFields = objCommUtils.SVMX_getFieldNamesFromList(lstFields);
                    if(strSOQLFields.length() > 0)
                    {
                        if(ckTargetId != null && lstChkTargetGroupid != null && lstChkTargetGroupid.size()>0)
                        {
                            
                                strQuery = 'SELECT '+ strSOQLFields + ' FROM SVMXC__Checklist__c WHERE SVMXC__SM_Checklist_Group_Id__c in: lstChkTargetGroupid';
                                lstChecklist = Database.query(strQuery);
                            
                        }
                        else
                        {
                            strQuery = 'SELECT '+ strSOQLFields + ' FROM SVMXC__Checklist__c WHERE Id =: ckTargetId';
                            lstChecklist = Database.query(strQuery);
                        }
                    }

                //List<SVMXC__Checklist__c> lstChecklist = [SELECT Id, SVMXC__ChecklistJSON__c, SVMXC__ChecklistMetaJSON__c, SVMXC__Completed_By__c, SVMXC__Completed_On__c, SVMXC__Status__c, SVMXC__Unique_Key__c, SVMXC__What_Id__c, SVMXC__ChecklistProcessID__c FROM SVMXC__Checklist__c WHERE SVMXC__What_Id__c =: strRecordId AND SVMXC__ChecklistProcessID__c =: strProcessId Limit 1];
                
                /*if(!lstChecklist.isEmpty()){
                    mapOutput.put(lstChecklist[0].id, lstChecklist);
                    mapHeaderRecord.put(strHeaderTargetObject,lstChecklist);
                }else{
                    lstChecklist.add(new SVMXC__Checklist__c());
                  // mapOutput.put(lstChecklist[0].id, lstChecklist);
                    mapHeaderRecord.put(strHeaderTargetObject,lstChecklist);                    
                }*/
                
                //Added for the field mapping defect for checklist process
                //First Get Source Header Record
                list<SObject> lstSourceHeaderRecord = new list<SObject>();
                list<Sobject> lstTargetHeaderRecord = new list<Sobject>();
                if(strHeaderSourceObject != null && strHeaderSourceObject.length() > 0){
                    if(strHeaderMapId != null && strHeaderMapId.length() > 0 && mapMappingIdSourceFields.containskey(strHeaderMapId)){
                        strQueryField = BuildSobject.buildQueryStringFromSet(mapMappingIdSourceFields.get(strHeaderMapId));
                        lstSourceHeaderRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,strHeaderSourceObject,null,strQueryField);
                    }
                    else{
                        strQueryField = 'Id';
                        lstSourceHeaderRecord = BuildSobject.SFM_buildSourceRecords(strRecordId,strHeaderSourceObject,null,strQueryField);
                    }
                }
                System.debug(LoggingLevel.WARN,'Query issued'+Limits.getQueries());
                System.debug(LoggingLevel.WARN,'lstSourceHeaderRecord'+lstSourceHeaderRecord);
                
                //Qualify Source Record first..
                if(strHeaderExpressionObjectName != null && strHeaderExpressionObjectName.length() > 0 && strHeaderExpressionWhereClause != null && strHeaderExpressionWhereClause.length() > 0 && lstSourceHeaderRecord.size() > 0) 
                {
                    lstSourceHeaderRecord = ExpParssig.SFM_ParseExpression1(lstSourceHeaderRecord,null,strHeaderExpressionObjectName,strHeaderExpressionWhereClause,strQueryField);
                    System.debug(LoggingLevel.WARN,'lstSourceHeaderRecord'+lstSourceHeaderRecord);
                }
                if(lstSourceHeaderRecord.size() > 0){
                    lstTargetHeaderRecord = new list<Sobject>();
                    if(lstChecklist != null && lstChecklist.size() > 0){
                        for(SVMXC__Checklist__c obj : lstChecklist){
                            lstTargetHeaderRecord.add((Sobject)obj);
                        }
                        System.debug(LoggingLevel.WARN,'lstTargetHeaderRecord: '+lstTargetHeaderRecord.size()+lstTargetHeaderRecord);
                    }
                    else if(strHeaderTargetObject != null && strHeaderTargetObject.length() > 0){ //If Target header Sobject is not passed then create new Target Header Sobject.
                            lstTargetHeaderRecord = BuildSobject.getSFM_BuildSobject(null,strHeaderTargetObject,null,null);
                            System.debug(LoggingLevel.WARN,'lstTargetHeaderRecord: '+lstTargetHeaderRecord.size()+lstTargetHeaderRecord);
                    }
                    //Apply Mapping 
                    if(lstTargetHeaderRecord.size() > 0 && strHeaderMapId != null && strHeaderMapId.length() > 0 && strHeaderMappingSourceObjectName != null && strHeaderMappingSourceObjectName.length() > 0 && strHeaderMappingTargetObjectName != null && strHeaderMappingTargetObjectName.length() > 0){
                        lstTargetHeaderRecord = Applymapping.applyMappingForHeader(lstTargetHeaderRecord,strHeaderMapId,strRecordId,true,mapAllObjectDescribe,strHeaderMappingSourceObjectName,strHeaderMappingTargetObjectName,lstSourceHeaderRecord[0]);
                    }
                    System.debug(LoggingLevel.WARN,'lstTargetHeaderRecord: '+lstTargetHeaderRecord.size()+lstTargetHeaderRecord);
                    System.debug(LoggingLevel.WARN,'strHeaderTargetObject: '+strHeaderTargetObject);
                    List<SVMXC__Checklist__c> templstChecklist = new List<SVMXC__Checklist__c>();
                        if(lstTargetHeaderRecord != null && lstTargetHeaderRecord.size() > 0){
                        for(Sobject obj: lstTargetHeaderRecord){
                        SVMXC__Checklist__c TempObj = (SVMXC__Checklist__c)obj;
                        lstChecklist.clear();
                        lstChecklist.add(TempObj);
                        mapOutput.put(obj.id, lstChecklist);
                        templstChecklist.add(TempObj);
                        
                        //mapHeaderRecord.put(strHeaderTargetObject,lstChecklist);
                    }
                    
                    system.debug(LoggingLevel.WARN,'mapOutput ++ 1: '+mapOutput.size()+mapOutput);
                    
                    
                    system.debug(LoggingLevel.WARN,'lstChecklist ++ 1: '+lstChecklist.size()+lstChecklist);
                    
                    system.debug(LoggingLevel.WARN,'templstChecklist ++ 1: '+templstChecklist.size()+templstChecklist);
                    
                    mapHeaderRecord.put(strHeaderTargetObject,templstChecklist);
                    system.debug(LoggingLevel.WARN,'mapHeaderRecord ++ 1: '+mapHeaderRecord.size()+mapHeaderRecord);
                    system.debug(LoggingLevel.WARN,'mapHeaderRecord ++ 1 val: '+mapHeaderRecord.Values().size()+mapHeaderRecord.Values());
                    }
                }               
            }
        }
        system.debug(LoggingLevel.WARN,'mapTemp'+mapTemp);
        //Convert datatime field values to usertime zone if is not background
        if(mapTemp.size() > 0)
        {
            System.debug('isBackgroundExecution: '+isBackgroundExecution);
            System.debug('SFM_GetData.isDateTimeConversionRequired: '+SFM_GetData.isDateTimeConversionRequired);
            if(!isBackgroundExecution && SFM_GetData.isDateTimeConversionRequired){
                for(String str : mapTemp.keyset())
                {
                    String ObjName = '';
                    map<String,Sobject> mapSobject = new map<String,Sobject>();
                    mapSobject = mapTemp.get(str);
                    if(str == strHeaderTargetObject)
                    {
                        ObjName = str;
                    }
                    else if(mapAliasNameChildNode.containskey(str))
                    {
                        ObjName = mapAliasNameChildNode.get(str).SVMXC__Source_Object_Name__c;
                    }   
                    //if(ObjName != null & ObjName.length() > 0 && mapAllObjectDescribe.containskey(ObjName) && mapAllFieldDescribe.containskey(ObjName) == false) #optiChange
                    map<String, Schema.SObjectField> FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(ObjName);
                    if(FieldMap != NULL && !FieldMap.isEmpty() && !mapAllFieldDescribe.containsKey(ObjName))
                    {
                        map<String, Schema.SObjectField> TempFieldMap = new map<String, Schema.SObjectField>();
                        //FieldMap = mapAllObjectDescribe.get(ObjName).getDescribe().fields.getMap(); #optiChange
                        //if(FieldMap != NULL && !FieldMap.isEmpty())
                        //{
                            for(String s1 : FieldMap.keyset())
                            {
                                TempFieldMap.put(FieldMap.get(s1).getDescribe().getName(),FieldMap.get(s1));
                            }
                            if(TempFieldMap.size() > 0)
                                mapAllFieldDescribe.put(ObjName,TempFieldMap);
                       // }
                    }   
                    //if(mapAllObjectDescribe.containskey(ObjName) && mapAllFieldDescribe.containskey(ObjName)) #optiChange
                    if(FieldMap != NULL && !FieldMap.isEmpty() && mapAllFieldDescribe.containskey(ObjName))//#optiChange
                    {
                        map<String, Schema.SObjectField> DtlFieldMap = new map<String, Schema.SObjectField>();
                        map<String,Sobject> mapDetailObject = new map<String,Sobject>(); 
                        DtlFieldMap = mapAllFieldDescribe.get(ObjName);
                        set<String> setFields = new set<String>();
                        if(mapObjectAPINameWithFields.containskey(ObjName))
                            setFields = mapObjectAPINameWithFields.get(ObjName);
                        if(setFields.size() > 0 && mapSobject.size() > 0){
                            for(String s1 : mapSobject.keyset()){
                                Sobject sobj = mapSobject.get(s1);
                                for(String s2 : setFields){
                                    if(DtlFieldMap.containskey(s2) && setFields.contains(s2) && sobj.get(s2) != null){
                                        Schema.DescribeFieldResult f = DtlFieldMap.get(s2).getDescribe();
                                        // if(f.isAccessible() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)//&& f.isCreateable() && f.isUpdateable()//&& f.isCreateable()
                                        //Commented above line and added below line for fixing issue 047570
                                        if(!f.isCalculated() && f.isCustom() && f.getType() == schema.Displaytype.DateTime)
                                        {
                                            system.debug(LoggingLevel.WARN,'Detail field: '+s2+'Value: '+sobj.get(s2));
                                            String dat2 = (datetime.valueof(sobj.get(s2))).format('yyyy-MM-dd HH:mm:ss');
                                            system.debug(LoggingLevel.WARN,s2+': '+dat2); 
                                            sobj.put(s2,datetime.valueofgmt(dat2));
                                        }
                                    }        
                                }
                                mapDetailObject.put(s1,sobj);
                            }
                        }
                        else if(DtlFieldMap.size() > 0 && mapSobject.size() > 0)
                        {
                            for(String s1 : mapSobject.keyset())
                            {
                                Sobject sobj = mapSobject.get(s1);
                                for(String s2 : DtlFieldMap.keyset())
                                {
                                    Schema.DescribeFieldResult f = DtlFieldMap.get(s2).getDescribe();
                                    // if(f.isAccessible() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)//&& f.isCreateable() && f.isUpdateable()//&& f.isCreateable()
                                    //Commented above line and added below line for fixing issue 047570
                                    if(sobj.get(s2) != null && !f.isCalculated() && f.isCustom() && f.getType() == schema.Displaytype.DateTime)
                                    {
                                        system.debug(LoggingLevel.WARN,'Detail field: '+s2+'Value: '+sobj.get(s2));
                                        String dat2 = (datetime.valueof(sobj.get(s2))).format('yyyy-MM-dd HH:mm:ss');
                                        system.debug(LoggingLevel.WARN,s2+': '+dat2); 
                                        sobj.put(s2,datetime.valueofgmt(dat2));
                                    }
                                }
                                mapDetailObject.put(s1,sobj);
                            }
                        }
                        mapAliasNameSourceRecIdTargetObject.put(str,mapDetailObject);
                    }
                }        
            }
            else{
                mapAliasNameSourceRecIdTargetObject = mapTemp;
            }
        }
        system.debug(LoggingLevel.WARN,'mapAliasNameSourceRecIdTargetObject'+mapAliasNameSourceRecIdTargetObject);
        system.debug(LoggingLevel.WARN,'mapHeaderRecord'+mapHeaderRecord);
        
        //Convert datatime field values of header to usertime zone if is not background
        if(mapHeaderRecord.size() > 0 && strHeaderTargetObject != null && strHeaderTargetObject.length() > 0)
        {
            list<Sobject> lstHeaderSobject = new list<Sobject>();
            map<String, Schema.SObjectField> mapHeaderFields = new map<String, Schema.SObjectField>();
            //get the Header Sobject from header map
            if(mapHeaderRecord.containskey(strHeaderTargetObject))
                lstHeaderSobject = mapHeaderRecord.get(strHeaderTargetObject);
            system.debug(LoggingLevel.WARN,'lstHeaderSobject: '+lstHeaderSobject);
            
            System.debug('isBackgroundExecution: '+isBackgroundExecution);
            System.debug('SFM_GetData.isDateTimeConversionRequired: '+SFM_GetData.isDateTimeConversionRequired);
            if(!isBackgroundExecution && SFM_GetData.isDateTimeConversionRequired){
                //if the mapAllFieldDescribe is not having the data then Do the Header object field describe an put in the mapAllFieldDescribe
               // if(mapAllObjectDescribe.containskey(strHeaderTargetObject) && mapAllFieldDescribe.containskey(strHeaderTargetObject) == false){ #optiChange
               Map<String, Schema.SObjectField> FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(strHeaderTargetObject);
                if(FieldMap != NULL && !FieldMap.isEmpty() && !mapAllFieldDescribe.containskey(strHeaderTargetObject)){
                    map<String, Schema.SObjectField> TempFieldMap = new map<String, Schema.SObjectField>();
                    //FieldMap = mapAllObjectDescribe.get(strHeaderTargetObject).getDescribe().fields.getMap(); #optiChange
                        for(String s : FieldMap.keyset()){
                            TempFieldMap.put(FieldMap.get(s).getDescribe().getName(),FieldMap.get(s));
                        }
                        mapAllFieldDescribe.put(strHeaderTargetObject,TempFieldMap);
                }    
                if(mapAllFieldDescribe.containskey(strHeaderTargetObject))
                {
                    mapHeaderFields = mapAllFieldDescribe.get(strHeaderTargetObject);
                    set<String> setFields = new set<String>();
                    //If Field Set is defined then get fields from field set and convert DateTime fields in to user time zone.
                    if(mapObjectAPINameWithFields.containskey(strHeaderTargetObject))
                        setFields = mapObjectAPINameWithFields.get(strHeaderTargetObject);
                    if(lstHeaderSobject.size() > 0 && mapHeaderFields.size() > 0)
                    {
                        for(integer i=0;i<lstHeaderSobject.size();i++)
                        {
                            if(setFields.size() > 0){
                                for(String s : setFields){
                                    if(mapHeaderFields.containskey(s) && lstHeaderSobject[i].get(s) != null){
                                        Schema.DescribeFieldResult f = mapHeaderFields.get(s).getDescribe();
                                        //if(f.isAccessible() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime) { //&& f.isCreateable()
                                        if(!f.isCalculated() && f.isCustom() && f.getType() == schema.Displaytype.DateTime) { //&& f.isCreateable()
                                            system.debug(LoggingLevel.WARN,'Header Field: '+s+'Value: '+lstHeaderSobject[i].get(s));
                                            String dat = (datetime.valueof(lstHeaderSobject[i].get(s))).format('yyyy-MM-dd HH:mm:ss');
                                            system.debug(s+': '+dat); 
                                            lstHeaderSobject[i].put(s,Datetime.valueofgmt(dat));
                                        }
                                    }       
                                } 
                            }
                            else{
                                for(String s : mapHeaderFields.keyset()){
                                    Schema.DescribeFieldResult f = mapHeaderFields.get(s).getDescribe();
                                    //if(f.isAccessible() && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime){//// f.isCreateable() &&
                                    if(lstHeaderSobject[i].get(s) != null && !f.isCalculated() && f.isCustom() && f.getType() == schema.Displaytype.DateTime){//// f.isCreateable() &&
                                        system.debug(LoggingLevel.WARN,'Header Field: '+s+'Value: '+lstHeaderSobject[i].get(s));
                                        String dat = (datetime.valueof(lstHeaderSobject[i].get(s))).format('yyyy-MM-dd HH:mm:ss');
                                        system.debug(s+': '+dat);
                                        lstHeaderSobject[i].put(s,Datetime.valueofgmt(dat));
                                    }
                                } 
                            }
                        }
                        system.debug(LoggingLevel.WARN,'lstHeaderSobject ++ 2: '+lstHeaderSobject.size()+lstHeaderSobject);
                        mapOutput.put(strHeaderTargetObject,lstHeaderSobject); 
                        system.debug(LoggingLevel.WARN,'mapOutput ++ 2: '+mapOutput.size()+mapOutput);
                    }   
                }
            }
            else{
                mapOutput.put(strHeaderTargetObject,lstHeaderSobject);
                system.debug(LoggingLevel.WARN,'mapOutput ++ 3: '+mapOutput.size()+mapOutput);
            }   
        }
            
            
        //Convert DateTime Fields of Detail Object to Usertime Zone only if not background execution..
        if(mapDetailRecord.size() > 0 && mapAliasNameChildNode.size() > 0)
        {
            for(String s :mapDetailRecord.keyset())
            {
                list<Sobject> DtlSObject = new list<Sobject>();
                String ObjName = '';
                DtlSObject = mapDetailRecord.get(s);
                system.debug(LoggingLevel.WARN,'DtlSObject'+DtlSObject);
                
                System.debug('isBackgroundExecution: '+isBackgroundExecution);
                System.debug('SFM_GetData.isDateTimeConversionRequired: '+SFM_GetData.isDateTimeConversionRequired);
                if(!isBackgroundExecution && SFM_GetData.isDateTimeConversionRequired){
                    if(mapAliasNameChildNode.containskey(s))
                        ObjName = mapAliasNameChildNode.get(s).SVMXC__Source_Object_Name__c;
                    //if(ObjName != null & ObjName.length() > 0 && mapAllObjectDescribe.containskey(ObjName) && mapAllFieldDescribe.containskey(ObjName) == false) #optiChange
                    map<String, Schema.SObjectField> FieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(ObjName);
                    if(FieldMap != NULL && !FieldMap.isEmpty() && !mapAllFieldDescribe.containskey(ObjName)) // #optiChange
                    {
                        map<String, Schema.SObjectField> TempFieldMap = new map<String, Schema.SObjectField>();
                        //if(FieldMap != NULL && !FieldMap.isEmpty())
                       // {
                            for(String s1 : FieldMap.keyset())
                            {
                                TempFieldMap.put(FieldMap.get(s1).getDescribe().getName(),FieldMap.get(s1));
                            }
                            if(TempFieldMap.size() > 0)
                                mapAllFieldDescribe.put(ObjName,TempFieldMap);
                        //}
                    }
                   // if(mapAllObjectDescribe.containskey(ObjName) && mapAllFieldDescribe.containskey(ObjName)) #optiChange
                    if(FieldMap != NULL && mapAllFieldDescribe.containskey(ObjName)) // #optiChange
                    {
                        map<String, Schema.SObjectField> DtlFieldMap = new map<String, Schema.SObjectField>();
                        DtlFieldMap = mapAllFieldDescribe.get(ObjName);
                       //If Field Set is defined then get fields from field set and convert DateTime fields in to user time zone.
                        set<String> setFields = new set<String>();
                        if(mapObjectAPINameWithFields.containskey(ObjName))
                            setFields = mapObjectAPINameWithFields.get(ObjName);
                        if(DtlFieldMap.size() > 0 && DtlSObject.size() > 0)
                        {
                            if(setFields.size() > 0){
                                for(Integer i = 0;i<DtlSObject.size();i++)
                                {
                                    for(String s2 : setFields)
                                    {
                                        if(DtlFieldMap.containskey(s2) && DtlSObject[i].get(s2) != null){
                                            Schema.DescribeFieldResult f = DtlFieldMap.get(s2).getDescribe();
                                            //if(f.isAccessible()  && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)//&& f.isCreateable() && f.isUpdateable()//&& f.isCreateable()
                                            if(!f.isCalculated() && f.isCustom() && f.getType() == schema.Displaytype.DateTime)//&& f.isCreateable() && f.isUpdateable()//&& f.isCreateable()
                                            {
                                                system.debug(LoggingLevel.WARN,'Detail field: '+s2+'Value: '+DtlSObject[i].get(s2));
                                                String dat2 = (datetime.valueof(DtlSObject[i].get(s2))).format('yyyy-MM-dd HH:mm:ss');
                                                system.debug(LoggingLevel.WARN,s2+': '+dat2); 
                                                DtlSObject[i].put(s2,datetime.valueofgmt(dat2));
                                            }
                                        }        
                                    }
                                }
                            }
                            else{
                                for(Integer i = 0;i<DtlSObject.size();i++)
                                {
                                    for(String s2 : DtlFieldMap.keyset())
                                    {
                                        Schema.DescribeFieldResult f = DtlFieldMap.get(s2).getDescribe();
                                        //if(f.isAccessible()  && f.isUpdateable() && f.getType() == schema.Displaytype.DateTime)//&& f.isCreateable() && f.isUpdateable()//&& f.isCreateable()
                                        if(DtlSObject[i].get(s2) != null && !f.isCalculated() && f.isCustom() && f.getType() == schema.Displaytype.DateTime)//&& f.isCreateable() && f.isUpdateable()//&& f.isCreateable()
                                        {
                                            system.debug(LoggingLevel.WARN,'Detail field: '+s2+'Value: '+DtlSObject[i].get(s2));
                                            String dat2 = (datetime.valueof(DtlSObject[i].get(s2))).format('yyyy-MM-dd HH:mm:ss');
                                            system.debug(LoggingLevel.WARN,s2+': '+dat2); 
                                            DtlSObject[i].put(s2,datetime.valueofgmt(dat2));
                                        }
                                    }
                                }
                            }        
                        }
                    }
                }
                mapOutput.put(s,DtlSObject);  
                system.debug(LoggingLevel.WARN,'mapOutput ++ 4: '+mapOutput.size()+mapOutput);
                
            }
        }
        system.debug(LoggingLevel.WARN,'mapOutput'+mapOutput.size()+mapOutput);
        return mapOutput;
    }
    static Object deserializeRequestTo(String requestStr, System.Type apexType){
        
        if(requestStr != null && requestStr != ''){
            return JSON.deserialize(requestStr, apexType);
        }
        return null;
    }
    
    //Added for the story BAC-3272 for fetching fields used in Data Validation rule and Formula
    Map<String, Set<String>> getFieldsUsedInDVAndFormula(String strProcessID){
        Map<String, Set<String>> mapObjectNameFieldSet = new Map<String, Set<String>>();

        //Checking accessibility of fields
        List<String> queryFields = new List<String> {'SVMXC__Process3__c', 'SVMXC__Process1__c'};
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        //querying junction records of DV rules
        //SDL-SVMX-READ-FLS-ENFORCED
        List<SVMXC__ServiceMax_Processes__c> lstProcessBR = [SELECT SVMXC__Process3__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process1__c =: strProcessID and RecordType.Name  = 'Process Business Rule'];
        if(lstProcessBR.size() > 0){
            Set<String> setDVId = new Set<String>();
            for(SVMXC__ServiceMax_Processes__c objProcess: lstProcessBR){
                if(objProcess.SVMXC__Process3__c != null){
                    setDVId.add(objProcess.SVMXC__Process3__c);
                }
            }
            
            //Checking accessibility of fields
            queryFields = new List<String> {'SVMXC__Field_Name__c', 'SVMXC__Operand__c', 'SVMXC__Parameter_Type__c', 'SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c', 'SVMXC__Expression_Rule__c', 'SVMXC__SM_Related_Info__c'};
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            //querying config data records for every DV rule configured in SFM
            //SDL-SVMX-READ-FLS-ENFORCED
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigRules = [SELECT SVMXC__Field_Name__c, SVMXC__Operand__c, SVMXC__Parameter_Type__c, SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c, SVMXC__Expression_Rule__c, SVMXC__SM_Related_Info__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c IN: setDVId];

            //Traversing through all config records and creating map of object and list of corresponding fields used in DV
            for(SVMXC__ServiceMax_Config_Data__c objConfigData: lstConfigRules){
                String objName = objConfigData.SVMXC__Expression_Rule__r.SVMXC__Source_Object_Name__c;
                if(!mapObjectNameFieldSet.containsKey(objName)){
                    mapObjectNameFieldSet.put(objName, new Set<String>());
                }
                mapObjectNameFieldSet.get(objName).add(objConfigData.SVMXC__Field_Name__c);
                if(objConfigData.SVMXC__Parameter_Type__c != null && objConfigData.SVMXC__Parameter_Type__c.equalsIgnoreCase('Field Value')){
                    mapObjectNameFieldSet.get(objName).add(objConfigData.SVMXC__Operand__c);
                }
                
                //Added for the story BAC-5787
                System.debug('objConfigData.SVMXDEV__SM_Related_Info__c - '+objConfigData.SVMXC__SM_Related_Info__c);
                if(objConfigData.SVMXC__SM_Related_Info__c != null){
                    List<SVMXC.SFM_WrapperDef.FormulaObjectField> objectFieldData = (List<SVMXC.SFM_WrapperDef.FormulaObjectField>) JSON.deserialize(objConfigData.SVMXC__SM_Related_Info__c, List<SVMXC.SFM_WrapperDef.FormulaObjectField>.class);
                    for(SVMXC.SFM_WrapperDef.FormulaObjectField data : objectFieldData){
                        system.debug('OBJ - '+data.OBJ);
                        if(String.isNotBlank(data.OBJ)){
                            if(!mapObjectNameFieldSet.containsKey(data.OBJ)){
                                mapObjectNameFieldSet.put(data.OBJ, new Set<String>());
                            }
                            for(SVMXC.SFM_WrapperDef.FLDS field : data.FLDS){
                                system.debug('FLDS - '+field.name);
                                if(String.isNotBlank(field.name)){
                                    mapObjectNameFieldSet.get(data.OBJ).add(field.name);
                                }
                            }
                        }
                    }
                }
            }
        }
        return mapObjectNameFieldSet;
    }
    
    //Added for the story BAC-4454
    Boolean getPriceConfiguredStatus(String strPageLayoutId){
        //Query for button event
        Map<ID, SVMXC__Page_Layout_Detail__c> mapPageLayoutDetail = new Map<ID, SVMXC__Page_Layout_Detail__c>([SELECT Id FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c =: strPageLayoutId AND SVMXC__Detail_Type__c = 'Button' AND SVMXC__Show_In_Web__c = true]); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        //Query for page event
        List<String> lstEventType = new List<String>{'On Load', 'Before Save/Update', 'Button Click'};
        List<SVMXC__SFM_Event__c> lstPageEvent = [SELECT SVMXC__Code_Snippet__c, SVMXC__Code_Snippet__r.SVMXC__SnippetId__c, SVMXC__Code_Snippet__r.SVMXC__IsStandard__c FROM SVMXC__SFM_Event__c WHERE (SVMXC__Page_Layout__c =: strPageLayoutId OR SVMXC__Page_Layout_Detail__c IN: mapPageLayoutDetail.keyset()) AND SVMXC__Event_Call_Type__c = 'JAVASCRIPT' AND SVMXC__Event_Type__c IN: lstEventType AND SVMXC__Code_Snippet__c != null]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__SFM_Event__c objEvent: lstPageEvent){
            if(!String.isBlank(objEvent.SVMXC__Code_Snippet__r.SVMXC__SnippetId__c) && objEvent.SVMXC__Code_Snippet__r.SVMXC__SnippetId__c.equalsIgnoreCase('Code001') && objEvent.SVMXC__Code_Snippet__r.SVMXC__IsStandard__c){
                return true;
            }
        }
        return false;
    }
    
    //Added for the story BAC-4454
    Map<String, Set<String>> fetchGetPriceFields(){
        Map<String, Set<String>> mapResult = new Map<String, Set<String>>();
        List<SVMXC__GetPrice_Fields__c> lstGetPriceCustomSetting = SVMXC__GetPrice_Fields__c.getAll().values();
        for(SVMXC__GetPrice_Fields__c objSetting: lstGetPriceCustomSetting){
            if(!mapResult.containsKey(objSetting.SVMXC__Object_API_Name__c)){
                mapResult.put(objSetting.SVMXC__Object_API_Name__c, new Set<String>());
            }
            mapResult.get(objSetting.SVMXC__Object_API_Name__c).addAll(objSetting.SVMXC__Field_API_Name_List__c.split(','));
        }
        return mapResult;
    }
}