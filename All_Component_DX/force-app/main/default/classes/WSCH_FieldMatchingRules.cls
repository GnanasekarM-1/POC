/**
        @Name: WSCH_FieldMatchingRules
        @Author: Zubair
        @Description: This is a Controller class for the Work Order field matching rules page, WSCH_FieldMatchingRules
 **/

public with sharing class WSCH_FieldMatchingRules {
    
    public string strProcessName{get;set;}
    public string strDescription{get;set;}
    
    public boolean isRenderNew{get;set;}
    public boolean isRenderEdit{get;set;}
    public boolean isRenderSave{get;set;}
    public boolean isRenderDelete{get;set;}
    public boolean isRendercancel{get;set;}
    public boolean isRenderSourceObj1{get;set;}
    public boolean isRenderSourceObj2{get;set;}
    public boolean isDisableSelect{get;set;}
    public boolean isActive{get;set;}
    public boolean isRenderExp{get;set;}
    //public boolean isRenderOrderByField{get;set;}
    public boolean isDisableOrderByField{get; set;}
    
    public integer selIndex = 0;
    
    public boolean isUpAction = false;
    public boolean isDownAction = false;
    public boolean isTopAction = false;
    public boolean isBottomAction = false;
    
    public boolean isNewRule = false;
    public boolean getisNewRule(){ return isNewRule; }
    public void setisNewRule(boolean b){ this.isNewRule = b; }
    
    public String stringSelectObj1{get;set;}
    public String stringSelectObj2{get;set;}
    public String strSelectedOrderByField{get;set;}
    
    public boolean IsValidExp = false;
    public boolean IsValidProcess = true;
    
    public string ExpHdr_Rtype_Id;
    public string ExpDtl_Rtype_Id;
    
    public SVMXC.SFM_WrapperDef.SFM_Response Save_Response = new SVMXC.SFM_WrapperDef.SFM_Response();
    public SVMXC.SFM_validateExpression ValidateExp = new SVMXC.SFM_validateExpression();
    
    public SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    public CONF_ManageActions manageAction = new CONF_ManageActions();
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    public String strSourceObjLabel {get; set;}
    public String strTargetObjLabel {get; set;}
    
    public String StrDelIndex1 {get; set;}
    public String StrDelIndex2 {get; set;}
    public String StrDelIndex3 {get; set;}
    
    public string StrSelectedIndex {get; set;}
    
    public string strAdvanceExp1{get;set;}
    public string strAdvanceExp2{get;set;}
    
    /*
        BAC-3620 Fix
        Existing wrapper class is used to split the selectoption accross multiple variables
    */
    public CONF_ManageActions.ObjectListWrapper object1Optns{get;set;}
    
    //public CONF_ManageActions.ObjectListWrapper getObject1Optns(){return object1Optns;}
    //public void setObject1Optns(CONF_ManageActions.ObjectListWrapper e){object1Optns = e;}
    
    /* Duplicate list not required
    public List<selectOption> object2Optns = new List<selectOption>();
    public List<selectOption> getObject2Optns(){return object2Optns;}
    public void setObject2Optns(List<selectOption> e){object2Optns = e;}*/
    
    public List<selectOption> orderByFieldsLst = new List<selectOption>();
    public List<selectOption> getorderByFieldsLst(){return orderByFieldsLst;}
    public void setorderByFieldsLst(List<selectOption> e){orderByFieldsLst = e;}
    
    public List<SVMXC__ServiceMax_Processes__c> lstFieldMapProcesses = new List<SVMXC__ServiceMax_Processes__c>();
    
    public List<SelectOption> lstOfFieldMaps = new List<SelectOption>();
    public List<SelectOption> getlstOfFieldMaps(){return this.lstOfFieldMaps;}
    
    public String strSelectedMap { get; set; }
    
    public String strMapId { get; set; }
    
    public boolean isEnterprise;
    
    public boolean isRenderRuleSeq = true;
    public boolean getisRenderRuleSeq(){ return isRenderRuleSeq; }
    public void setisRenderRuleSeq(boolean b){ this.isRenderRuleSeq = b; }
    
    public boolean displaySeqPopup = false;
    public boolean getdisplaySeqPopup(){ return displaySeqPopup; }
    
    public string[] strFieldMatchRuleIdRearrange = new String[]{};
    
    public Map<String,String> Map_ObjName_Label = new Map<String,String>();
    public Map<String,String> getMap_ObjName_Label(){return Map_ObjName_Label;}
    
    //objEligibilityCriteria equivalent
    public SVMXC__ServiceMax_Processes__c processObjFieldMatchRule = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getprocessObjFieldMatchRule(){return this.processObjFieldMatchRule;}
    public void setprocessObjFieldMatchRule(SVMXC__ServiceMax_Processes__c proces){this.processObjFieldMatchRule = proces;}
    
    public SVMXC__ServiceMax_Processes__c processObjFieldMatchRuleEdit;
    
    public  List<SVMXC__ServiceMax_Processes__c>  lstWOFieldMatchingRules = new  List<SVMXC__ServiceMax_Processes__c> ();
    public List<SVMXC__ServiceMax_Processes__c> getlstWOFieldMatchingRules(){return this.lstWOFieldMatchingRules;}
    
    public List<SVMXC__ServiceMax_Processes__c> lstTempWOFieldMatchingRules  = new List<SVMXC__ServiceMax_Processes__c>();
    
    /*  Config object list for Section 1 in UI  */
    
    public List<SVMXC__ServiceMax_Config_Data__c> lsteligibilityMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlsteligibilityMatchConfig(){return lsteligibilityMatchConfig;}
    public void setlsteligibilityMatchConfig(List<SVMXC__ServiceMax_Config_Data__c> ConfigObj){lsteligibilityMatchConfig = ConfigObj;}
    
    public List<SVMXC__ServiceMax_Config_Data__c> lsteligMatchConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    /*  Config object list for Section 2 in UI  */
    
    //public List<SVMXC__ServiceMax_Config_Data__c> lstTargetSourceMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
    //public List<SVMXC__ServiceMax_Config_Data__c> getlstTargetSourceMatchConfig(){return lstTargetSourceMatchConfig;}
    //public void setlstTargetSourceMatchConfig(List<SVMXC__ServiceMax_Config_Data__c> ConfigObj){lstTargetSourceMatchConfig = ConfigObj;}
        
    //public List<SVMXC__ServiceMax_Config_Data__c> lstTargetSourceMatchConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    /*  Config object list for Section 3 in UI  */
    
    //public List<SVMXC__ServiceMax_Config_Data__c> lstTargetSourceAssignConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
    //public List<SVMXC__ServiceMax_Config_Data__c> getlstTargetSourceAssignConfig(){return lstTargetSourceAssignConfig;}
    //public void setlstTargetSourceAssignConfig(List<SVMXC__ServiceMax_Config_Data__c> ConfigObj){lstTargetSourceAssignConfig = ConfigObj;}
    
    //public List<SVMXC__ServiceMax_Config_Data__c> lstTargetSourceAssignConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    public List<selectoption> lstWOfield=new List<selectoption>();
    public List<selectoption> getlstWOfield() {return this.lstWOfield;}
    
    public List<selectoption> lstSourceObjField=new List<selectoption>();
    public List<selectoption> getlstSourceObjField() {return this.lstSourceObjField;}
    
    public List<selectoption> lstTargetObjField=new List<selectoption>();
    public List<selectoption> getlstTargetObjField() {return this.lstTargetObjField;}
    
    public List<SelectOption> lstOperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getlstOperatorSelectLst(){return lstOperatorSelectLst;}
    
    public List<SelectOption> Seqoptions = new List<SelectOption>();
    
    public integer getlsteligMatchSize(){return lsteligibilityMatchConfig.size();}
    
    //public Integer getlstTargetSourceMatchSize() { return lstTargetSourceMatchConfig.size(); }
    
    //public Integer getlstTargetSourceAssignSize() { return lstTargetSourceAssignConfig.size(); }
    
    public List<TargetSourceMatchConfigWrapper> LstTargetSourceMatchWrap = new List<TargetSourceMatchConfigWrapper>();
    public List<TargetSourceMatchConfigWrapper> getLstTargetSourceMatchWrap(){ return this.LstTargetSourceMatchWrap;}
    public void setLstTargetSourceMatchWrap(List<TargetSourceMatchConfigWrapper> value){ this.LstTargetSourceMatchWrap = value; }
    
    public Integer getLstTargetSourceMatchWrapSize(){return LstTargetSourceMatchWrap.size();}
    
    public List<SVMXC__ServiceMax_Config_Data__c> LstTargetSrcMatchWrapConfObjToDel = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    public WSCH_FieldMatchingRules() {
        setDefaultValues();
        populateSObjects();
        //populateFieldMapping();
    }
    
    public map<string, boolean> lstStdObjAccToLicense = new map<string, boolean>();
    public COMM_Utils comUtil = new COMM_Utils();
    
    public void setDefaultValues() {
        
        lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();
        
        WSCH_AuditLogger.debug('Inside setDefaultValues()');
        isDisableSelect = false;
        isRenderExp=false;
        isRenderNew =true;
        isRenderEdit=true;
        isRenderSave=false;
        isRenderDelete=true;
        isRendercancel=false;
        isactive = true;
        
        isNewRule = false;
        
        isRenderSourceObj1 = true;
        isRenderSourceObj2 = true;
        //isRenderOrderByField = true;
        isDisableOrderByField = true;
        
        displaySeqPopup = false;
        //isRenderRuleSeq = true;       //commented to disable 'rule sequence' button when there is only one rule
        
        strProcessName = null;
        strDescription = null;
        strAdvanceExp1 = null;
        strAdvanceExp2 = null;
        
        lstWOFieldMatchingRules.clear();
        lsteligibilityMatchConfig.clear();
        LstTargetSrcMatchWrapConfObjToDel.clear();
        //lstTargetSourceAssignConfig.clear();
        //lstOfFieldMaps.clear();
        strSelectedMap = getTAG034();
        strSelectedOrderByField = getTAG034();
        WSCH_AuditLogger.debug('Inside setDefaultValues, before if() strSelectedOrderByField - ' + strSelectedOrderByField);
        
        if(orderByFieldsLst != null && orderByFieldsLst.size() == 0) {
            orderByFieldsLst.add(new SelectOption('SVMX.None', getTAG034()));
        }
        
        retrieveRecordTypes();
        retrieveWOFieldMatchRules();
        
        if(lstWOFieldMatchingRules!= null && lstWOFieldMatchingRules.size()== 0)
        {
            isRenderEdit = false;           
            isRenderDelete = false;
            isRenderRuleSeq = false;     
        }
        
        if(lstWOFieldMatchingRules!= null && lstWOFieldMatchingRules.size() > 1)
        {
            isRenderRuleSeq = true;
        } else {
            isRenderRuleSeq = false;
        }
        
        if((lstWOFieldMatchingRules != null && lstWOFieldMatchingRules.size() > 0) && 
                (lstWOFieldMatchingRules[0].SVMXC__Field_Name__c != null && (lstWOFieldMatchingRules[0].SVMXC__Field_Name__c != getTAG034() 
                    && lstWOFieldMatchingRules[0].SVMXC__Field_Name__c != 'SVMX.NONE' && lstWOFieldMatchingRules[0].SVMXC__Field_Name__c != 'SVMX.None'))) {
                
                strSelectedOrderByField = lstWOFieldMatchingRules[0].SVMXC__Field_Name__c;
                WSCH_AuditLogger.debug('Inside setDefautValues(), if(), strSelectedOrderByField - ' + strSelectedOrderByField);
        } else {
            strSelectedOrderByField = getTAG034();
        }
        
        WSCH_AuditLogger.debug('Inside setDefaultValues, after if() strSelectedOrderByField - ' + strSelectedOrderByField);
        //WSCH_AuditLogger.finish();
    }
    
    /*public void populateSObjects() {
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        System.debug('global describe - ' + gd);
        List<Schema.SObjectType> lstOfAllObjects = new List<Schema.SObjectType>();
        
        object1Optns.clear();
        object1Optns.add(new SelectOption('SVMX.None', getTAG034()));
        
        object2Optns.clear();
        object2Optns.add(new SelectOption('SVMX.None', getTAG034()));
        
        for(String key : gd.keySet()) {
            Schema.SObjectType objT = gd.get(key);
            String currentObjName = objT.getDescribe().getName();
            
            if(!((CurrentObjName.toUpperCase()).Contains('__SHARE')) && !((CurrentObjName.toUpperCase()).Contains('__FEED')) && 
            !((CurrentObjName.toUpperCase()).Contains('__HISTORY')) && !((CurrentObjName.toUpperCase()).Contains('__TAG')) && 
            objT.getDescribe().isAccessible()) {
                Map_ObjName_Label.put(CurrentObjName,objT.getDescribe().getLabel());
            }
                
            System.debug('SObject type objT - ' + objT);
            System.debug('currentObjName - ' + currentObjName);
        }
        
        List<String> lstOfKeys = new List<String>(Map_ObjName_Label.keySet());
        lstOfKeys.sort();
        
        for(String key : lstOfKeys) {
            object1Optns.add(new SelectOption(key, Map_ObjName_Label.get(key)));
            object2Optns.add(new SelectOption(key, Map_ObjName_Label.get(key)));
        }
    }*/
    
    /*
        Render variable set to true only if next set of collection items are available 
    */
    public Boolean getIsSecondListHasItem(){
        Integer sizeOfList = Map_ObjName_Label.size();
        if(sizeOfList > 0)
            return true;
        else
            return false;
    }
        
    public void populateSObjects() {
        WSCH_AuditLogger.debug('Inside populateSObjects()');
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        WSCH_AuditLogger.debug('global describe - ' + gd);
        
        //object1Optns.clear();
        /*
            Templist to hold the options for sorting
        */
        List<SelectOption> tempList = new List<SelectOption>();
        tempList.add(new SelectOption('SVMX.None', getTAG034()));
        
        /*object2Optns.clear();
        object2Optns.add(new SelectOption('SVMX.None', getTAG034()));*/
        
        Map_ObjName_Label = utils.getSFDCSVMXInternalObjects();
        
        List<String> lstOfKeys = new List<String>(Map_ObjName_Label.keySet());
        lstOfKeys.sort();
        
        for(String key : lstOfKeys) {
            WSCH_AuditLogger.debug('Inside populateSObjects()');
            
            if(key != 'SVMXC__Code_Snippet_Manifest__c' && key != 'SVMXC__Code_Snippet__c' && 
                key != 'SVMXC__Sync_Request__c' && key != 'SVMXC__Sync_Request_Records__c') {
                    
                WSCH_AuditLogger.debug('key - ' + key + ' Map_ObjName_Label.get(key) - ' + Map_ObjName_Label.get(key));
                tempList.add(new SelectOption(key, Map_ObjName_Label.get(key)));
                //object1Optns.add(new SelectOption(key, Map_ObjName_Label.get(key)));
                //object2Optns.add(new SelectOption(key, Map_ObjName_Label.get(key)));
            }
        }
        
        object1Optns = new CONF_ManageActions.ObjectListWrapper();
        object1Optns.collectionList = manageAction.sortingSelectOption(tempList);
        //object2Optns = manageAction.sortingSelectOption(object2Optns);
        
        //WSCH_AuditLogger.finish();
    }
    
    /* This method populates the picklist with fields based on the SourceObject selection */
    public void populateWorkOrderFields() {
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        //System.debug('stringSelectObj - ' + stringSelectObj1);
        //Map<String, Schema.SObjectField> mapOfFields = gd.get(stringSelectObj1).getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> mapOfFields = SVMXC__Service_order__c.SObjectType.getDescribe().fields.getMap();
        WSCH_AuditLogger.debug('inside populateWorkOrderFields() ');
        lstWOfield.clear();
        lstWOfield.add(new SelectOption('SVMX.None', getTAG034()));
        
        List<String> lstOfKeys = new List<String>(mapOfFields.keySet());
        lstOfKeys.sort();
        
        for(String key : lstOfKeys)  
        {  
            Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();  
            if(fieldResult.isAccessible())  
            {  
                WSCH_AuditLogger.debug('inside for()-if(), key - ' + key);
                //lstWOfield.add(new SelectOption(key, fieldResult.getLabel()));
                if(fieldResult.getType() == Schema.DisplayType.Reference)
                {
                    if(!comUtil.SVMX_isObjectCustom(String.valueof(fieldResult.getReferenceTo()[0])))
                    {
                        if(!lstStdObjAccToLicense.containsKey(String.valueof(fieldResult.getReferenceTo()[0])))
                        {
                            continue;
                        }
                    }
                }
                lstWOfield.add(new SelectOption(fieldResult.getName(), fieldResult.getLabel()));
            }  
        }
        lstWOfield = sortingSelectOption(lstWOfield);
        //WSCH_AuditLogger.finish();
    }
    
    /* This method populates the picklist with fields based on the SourceObject selection */
    public void populateSourceObjFields() {
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        WSCH_AuditLogger.debug('inside populateSourceObjFields(), stringSelectObj1 - ' + stringSelectObj1);
        Map<String, Schema.SObjectField> mapOfFields = gd.get(stringSelectObj1).getDescribe().fields.getMap();
        
        lstSourceObjField.clear();
        lstSourceObjField.add(new SelectOption('SVMX.None', getTAG034()));
        
        List<String> lstOfKeys = new List<String>(mapOfFields.keySet());
        lstOfKeys.sort();
        
        for(String key : lstOfKeys)  
        {  
            Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();  
            if(fieldResult.isAccessible())  
            {  
                WSCH_AuditLogger.debug('inside for()-if(), key - ' + key);
                //lstSourceObjField.add(new SelectOption(key, fieldResult.getLabel()));
                if(fieldResult.getType() == Schema.DisplayType.Reference)
                {
                    if(!comUtil.SVMX_isObjectCustom(String.valueof(fieldResult.getReferenceTo()[0])))
                    {
                        if(!lstStdObjAccToLicense.containsKey(String.valueof(fieldResult.getReferenceTo()[0])))
                        {
                            continue;
                        }
                    }
                }
                lstSourceObjField.add(new SelectOption(fieldResult.getName(), fieldResult.getLabel()));
            }  
        }
        lstSourceObjField = sortingSelectOption(lstSourceObjField);
        //WSCH_AuditLogger.finish();
    }
    
    /* This method populates the picklist with fields based on the TargetObject selection */
    public void populateTargetObjFields() {
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        WSCH_AuditLogger.debug('inside populateTargetObjFields(), stringSelectObj2 - ' + stringSelectObj2);
        Map<String, Schema.SObjectField> mapOfFields = gd.get(stringSelectObj2).getDescribe().fields.getMap();
        
        lstTargetObjField.clear();
        lstTargetObjField.add(new SelectOption('SVMX.None', getTAG034()));
        
        orderByFieldsLst.clear();
        orderByFieldsLst.add(new SelectOption('SVMX.None', getTAG034()));
        
        List<String> lstOfKeys = new List<String>(mapOfFields.keySet());
        lstOfKeys.sort();
        
        for(String key : lstOfKeys)  
        {  
            Schema.DescribeFieldResult fieldResult = mapOfFields.get(key).getDescribe();  
            if(fieldResult.isAccessible())  
            {  
                WSCH_AuditLogger.debug('inside for()-if(), key - ' + key);
                //lstTargetObjField.add(new SelectOption(key, fieldResult.getLabel()));
                if(fieldResult.getType() == Schema.DisplayType.Reference)
                {
                    if(!comUtil.SVMX_isObjectCustom(String.valueof(fieldResult.getReferenceTo()[0])))
                    {
                        if(!lstStdObjAccToLicense.containsKey(String.valueof(fieldResult.getReferenceTo()[0])))
                        {
                            continue;
                        }
                    }
                }
                lstTargetObjField.add(new SelectOption(fieldResult.getName(), fieldResult.getLabel()));
                orderByFieldsLst.add(new SelectOption(fieldResult.getName(), fieldResult.getLabel()));
            }  
        }
        
        lstTargetObjField = sortingSelectOption(lstTargetObjField); 
        orderByFieldsLst = sortingSelectOption(orderByFieldsLst);
        //WSCH_AuditLogger.finish();
    }
    
    public void populateFieldMapping() {
        
        WSCH_AuditLogger.debug('Inside populateFieldMapping()');
        
        if((stringSelectObj1 != null && stringSelectObj2 != null) && (!stringSelectObj1.equalsIgnoreCase('--None--') && !stringSelectObj1.equalsIgnoreCase('SVMX.None')) && 
                (!stringSelectObj2.equalsIgnoreCase('--None--') && !stringSelectObj2.equalsIgnoreCase('SVMX.None'))) {
                    
            WSCH_AuditLogger.debug(' Inside populateFieldMapping, stringSelectObj1 ' + stringSelectObj1 + ' stringSelectObj2 ' + stringSelectObj2);
            
            lstFieldMapProcesses = [select id,SVMXC__MapID__c, RecordType.Name, Name,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Name__c,SVMXC__Active__c, SVMXC__Process1__c From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'object mapping' and SVMXC__Source_Object_Name__c =: stringSelectObj2 and SVMXC__Target_Object_Name__c =: stringSelectObj1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            WSCH_AuditLogger.debug('lstFieldMapProcesses - ' + lstFieldMapProcesses);
            lstOfFieldMaps.clear();
            lstOfFieldMaps.add(new SelectOption('SVMX.None', getTAG034()));
            
            if(lstFieldMapProcesses != null && lstFieldMapProcesses.size() > 0) {
                for(Integer i = 0;i<lstFieldMapProcesses.size();i++) {
                    if(lstFieldMapProcesses[i].SVMXC__Source_Object_Name__c == stringSelectObj2 && 
                            lstFieldMapProcesses[i].SVMXC__Target_Object_Name__c == stringSelectObj1) {
                        lstOfFieldMaps.add(new selectOption(lstFieldMapProcesses[i].id,lstFieldMapProcesses[i].SVMXC__Name__c));
                    }     
                }
                WSCH_AuditLogger.debug('lstOfFieldMaps - ' + lstOfFieldMaps);
            }
        }
        //WSCH_AuditLogger.finish();
    }
    
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList)
        {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys)
           resultList.addAll(tempLst.get(key)); 
        
        return resultList;
    }
    
    public void populateOperators() {
        WSCH_AuditLogger.debug('inside populateOperators()');
        lstOperatorSelectLst.clear();
        lstOperatorSelectLst.add(new SelectOption('SVMX.NONE', getTAG034()));
        lstOperatorSelectLst.add(new SelectOption('eq', getTAG020()));
        lstOperatorSelectLst.add(new SelectOption('ne', getTAG021()));
        lstOperatorSelectLst.add(new SelectOption('gt', getTAG022()));
        lstOperatorSelectLst.add(new SelectOption('ge', getTAG023()));
        lstOperatorSelectLst.add(new SelectOption('lt', getTAG024()));
        lstOperatorSelectLst.add(new SelectOption('le', getTAG025()));
        lstOperatorSelectLst.add(new SelectOption('starts', getTAG026()));
        lstOperatorSelectLst.add(new SelectOption('contains', getTAG027()));
        lstOperatorSelectLst.add(new SelectOption('notcontain', getTAG028()));
        lstOperatorSelectLst.add(new SelectOption('in', getTAG029()));
        lstOperatorSelectLst.add(new SelectOption('notin', getTAG030()));
        lstOperatorSelectLst.add(new SelectOption('isnull', getTAG031()));
        lstOperatorSelectLst.add(new SelectOption('isnotnull', getTAG032()));
    }
    
    public String getLabelFromObjName(String strSourceObj) {
        
        String strObjLabel;
        Schema.DescribeSObjectResult objectRes = Schema.getGlobalDescribe().get(strSourceObj).getDescribe();
        strObjLabel = objectRes.getLabel();
        
        return strObjLabel;
    }
    
    /*public String getFieldLabelFromApiName(String strSourceObj, String strFieldApiName) {
        
        String strFieldLabelName;
        Map<String, Schema.SObjectField> mapOfFields = Schema.getGlobalDescribe().get(strSourceObj).getDescribe().fields.getMap();
        for (String fieldKey : mapOfFields.keySet()) 
        {
            Schema.SObjectField fsObj = mapOfFields.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.getName() == strFieldApiName)
            {
                strFieldLabelName = f.getLabel();
            }
        }
        return strFieldLabelName;
    }
    
    public String getFieldLocalNameFromApiName(String strSourceObj, String strFieldApiName) {
        
        String strFieldLocalName;
        Map<String, Schema.SObjectField> mapOfFields = Schema.getGlobalDescribe().get(strSourceObj).getDescribe().fields.getMap();
        for (String fieldKey : mapOfFields.keySet()) 
        {
            Schema.SObjectField fsObj = mapOfFields.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.getName() == strFieldApiName)
            {
                strFieldLocalName = f.getLocalName();
            }
        }
        return strFieldLocalName;
    }*/
    
    //------------------------------------- Method to retrieve All the Record Types --------------------------------
    public void retrieveRecordTypes()
    {
        List<string> lstRCNames = new List<string>();
        lstRCNames.add('SVMX Rule');
        lstRCNames.add('Expressions');
        List<string> lstObjs = new List<string>();
        lstObjs.add('SVMXC__ServiceMax_Processes__c');
        lstObjs.add('SVMXC__ServiceMax_Config_Data__c');
        
        for(RecordType RC: [select id, Name, SobjectType from RecordType where Name IN: lstRCNames and SobjectType IN: lstObjs])
        {
            if(RC.Name == 'SVMX Rule' && RC.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                ExpHdr_Rtype_Id = RC.Id;
            if(RC.Name == 'Expressions' && RC.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                ExpDtl_Rtype_Id = RC.Id;
        }        
    }
    
    /* Method to retrive all existing Field Matching Rules based on the Source and Target objected selected */
    public void retrieveWOFieldMatchRules()
    {
        lstWOFieldMatchingRules.clear();
        lstWOFieldMatchingRules = [select id, RecordTypeId, SVMXC__Name__c, SVMXC__MapID__c, SVMXC__Process__c, SVMXC__Process1__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Active__c,SVMXC__Select__c ,SVMXC__Sequence__c,  SVMXC__Advance_Expression__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Field_Name__c, SVMXC__Primary_Consolidation_Rule__c from SVMXC__ServiceMax_Processes__c where  RecordTypeId =: ExpHdr_Rtype_Id And SVMXC__Rule_Type__c = 'Field Match Rule' And SVMXC__Source_Object_Name__c =: stringSelectObj1 And SVMXC__Target_Object_Name__c =: stringSelectObj2 order by SVMXC__Sequence__c];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    
    public void onSelectObject1() {
        WSCH_AuditLogger.debug('Inside onSelectObject1() - stringSelectObj1 - ' + stringSelectObj1);
        this.onSelectObject2();
        WSCH_AuditLogger.finish();
    }
    
    public void onSelectObject2() {
        WSCH_AuditLogger.debug('Inside onSelectObject2() - stringSelectObj1 - ' + stringSelectObj1);
        WSCH_AuditLogger.debug('Inside onSelectObject2() - stringSelectObj2 - ' + stringSelectObj2);
        this.setDefaultValues();
        if((stringSelectObj1 != null && stringSelectObj2 != null) && (!stringSelectObj1.equalsIgnoreCase('--None--') && !stringSelectObj1.equalsIgnoreCase('SVMX.None')) && 
                (!stringSelectObj2.equalsIgnoreCase('--None--') && !stringSelectObj2.equalsIgnoreCase('SVMX.None'))) {
                    
            //this.setDefaultValues();
            LstTargetSourceMatchWrap.clear();
            if(isNewRule) {
                isRenderExp = true;
            } else {
                isRenderExp = false;
            }
            
            populateFieldMapping();
            populateWorkOrderFields();
            populateSourceObjFields();
            populateTargetObjFields();
            populateOperators();
            
            WSCH_AuditLogger.debug('lstWOFieldMatchingRules - ' + lstWOFieldMatchingRules);
            if((lstWOFieldMatchingRules != null && lstWOFieldMatchingRules.size() > 0) && 
                (lstWOFieldMatchingRules[0].SVMXC__Field_Name__c != null && (lstWOFieldMatchingRules[0].SVMXC__Field_Name__c != getTAG034() 
                    && lstWOFieldMatchingRules[0].SVMXC__Field_Name__c != 'SVMX.NONE' && lstWOFieldMatchingRules[0].SVMXC__Field_Name__c != 'SVMX.None'))) {
                
                strSelectedOrderByField = lstWOFieldMatchingRules[0].SVMXC__Field_Name__c;
            }
            
            strSourceObjLabel = getLabelFromObjName(stringSelectObj1);
            strTargetObjLabel = getLabelFromObjName(stringSelectObj2);
            
        } else {
            isRenderExp = false;
        }
        WSCH_AuditLogger.finish();
    }
    
    public void onSelectOrderByField() {
        
    }
    
    //------------------------------------ Visibility control on VF page --------------------------
    public void RerenderTextOrPicklist()
    {
        TargetSourceMatchConfigWrapper cnfwrp;
        if(LstTargetSourceMatchWrap != null && LstTargetSourceMatchWrap.isEmpty()!= true && integer.valueOf(StrSelectedIndex) - 1 >= 0)
        {
            cnfwrp = LstTargetSourceMatchWrap.get(integer.valueOf(StrSelectedIndex) - 1);
        
            if(cnfwrp.IsRenderpicklist == true) {
                cnfwrp.IsRenderpicklist = false;
            } else {
                cnfwrp.IsRenderpicklist = true;
                populateSourceObjFields();
                cnfwrp.lstSourceObjField = lstSourceObjField;
            }
                
            cnfwrp.targetSourceMatchConfig.SVMXC__Target_Field_Name__c = null;
            cnfwrp.targetSourceMatchConfig.SVMXC__Display_Value__c = null;
            
            LstTargetSourceMatchWrap.set(integer.valueOf(StrSelectedIndex) - 1, cnfwrp);
            //IntIndex =integer.valueOf(StrSelectedIndex);
            //onchangeTechField();
        }
    }
    
    public PageReference SVMX_GoSetupHome(){
      //String url = '/apex/SVMXC__CONF_SetupHome';
      //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }      
      PageReference HomePage = new PageReference(url);
      HomePage.setRedirect(true);
      return HomePage; 
    }
    
    //---------------------------- Methods to add row to Expression  ------------------------------------------
    public void HdrADDRow1()
    {
        WSCH_AuditLogger.debug('Inside HdrADDRow1()');
        try {
            lsteligibilityMatchConfig.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(lsteligibilityMatchConfig.size() + 1)));   
        WSCH_AuditLogger.debug('lsteligibilityMatchConfig val'+lsteligibilityMatchConfig);            
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_FieldMatchingRules::HdrADDRow1(): ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        //WSCH_AuditLogger.finish();
    }
    
    //---------------------------- Methods to delete a row from Expression  ------------------------------------------    
    public void HdrDeleteRow1()
    {
        WSCH_AuditLogger.debug('Inside HdrDeleteRow1()');
        integer IntVal;
        IntVal = integer.valueOf(StrDelIndex1);  
        WSCH_AuditLogger.debug('IntVal val'+IntVal);      
        if(lsteligibilityMatchConfig.get(IntVal - 1).id != null) {
            lsteligMatchConfigDel.add(lsteligibilityMatchConfig.get(IntVal - 1));
        }
        lsteligibilityMatchConfig.remove(IntVal - 1); 
        if(IntVal <= lsteligibilityMatchConfig.size()) {       
            for(integer i = IntVal; i <= lsteligibilityMatchConfig.size(); i++ )
                lsteligibilityMatchConfig[i-1].SVMXC__Sequence__c = i;        
        }    
       WSCH_AuditLogger.debug('lsteligibilityMatchConfig val'+lsteligibilityMatchConfig);
       //WSCH_AuditLogger.finish();            
    }
    
    //---------------------------- Methods to add row to Expression  ------------------------------------------
    /*public void HdrADDRow2()
    {
        try {
            lstTargetSourceMatchConfig.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(lstTargetSourceMatchConfig.size() + 1)));   
            System.debug('lsteligibilityMatchConfig val'+lstTargetSourceMatchConfig);            
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }*/
    
    public void HdrADDRow2() {
        
        WSCH_AuditLogger.debug('Inside HdrADDRow2()');
        try {
            //lstTargetObjField.clear();
            //lstTargetObjField.add(new SelectOption(getTAG034(), getTAG034()));
            
            //lstSourceObjField.clear();
            //lstSourceObjField.add(new SelectOption(getTAG034(), getTAG034()));
            
            WSCH_AuditLogger.debug(' Before if() LstTargetSourceMatchWrap.size() -- ' + LstTargetSourceMatchWrap.size());
           if(LstTargetSourceMatchWrap.isEmpty()) {
                WSCH_AuditLogger.debug(' Inside if() LstCriWrap.size() -- ' + LstTargetSourceMatchWrap.size());
                LstTargetSourceMatchWrap.add(new TargetSourceMatchConfigWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = 1),lstTargetObjField, lstSourceObjField, true, 1) ); 
           } else {
                LstTargetSourceMatchWrap.add(new TargetSourceMatchConfigWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(LstTargetSourceMatchWrap.size() + 1)), lstTargetObjField, lstSourceObjField, true, Integer.valueOf(LstTargetSourceMatchWrap.size() + 1)));
           }
        } catch(Exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_FieldMatchingRules::HdrADDRow2(): ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        //WSCH_AuditLogger.finish(); 
    }
    
    //---------------------------- Methods to delete a row from Expression  ------------------------------------------    
    /*public void HdrDeleteRow2()
    {
        integer IntVal;
        IntVal = integer.valueOf(StrDelIndex2);  
        System.debug('IntVal val'+IntVal);      
        if(lstTargetSourceMatchConfig.get(IntVal - 1).id != null) {
            lstTargetSourceMatchConfigDel.add(lstTargetSourceMatchConfig.get(IntVal - 1));
        }
        lstTargetSourceMatchConfig.remove(IntVal - 1); 
        if(IntVal <= lstTargetSourceMatchConfig.size()) {       
            for(integer i = IntVal; i <= lstTargetSourceMatchConfig.size(); i++ )
                lstTargetSourceMatchConfig[i-1].SVMXC__Sequence__c = i;        
        }    
       System.debug('lsteligibilityMatchConfig val'+lstTargetSourceMatchConfig);            
    }*/
    
    public void HdrDeleteRow2()
    {
        WSCH_AuditLogger.debug('Inside HdrDeleteRow2()');
        integer IntVal;           
        IntVal = integer.valueOf(StrDelIndex2);
        WSCH_AuditLogger.debug('Inside HdrDeleteRow2, IntVal val'+IntVal);
        if(IntVal <= LstTargetSourceMatchWrap.size())
        {
            WSCH_AuditLogger.debug('Inside HdrDeleteRow2 if(), LstTargetSourceMatchWrap.size() - ' + LstTargetSourceMatchWrap.size());
            for(integer i=IntVal;i< LstTargetSourceMatchWrap.size();i++)
            {
                TargetSourceMatchConfigWrapper cnfwrp = LstTargetSourceMatchWrap.get(i);
                //cnfwrp.objConf.SVMXC__Sequence__c = cnfwrp.objConf.SVMXC__Sequence__c-1;
                //cnfwrp.targetSourceMatchConfig.SVMXC__Sequence__c = cnfwrp.Sequence - 1;
                cnfwrp.targetSourceMatchConfig.SVMXC__Sequence__c = cnfwrp.targetSourceMatchConfig.SVMXC__Sequence__c - 1;
                LstTargetSourceMatchWrap.set(i,cnfwrp);
            }
        }
        if(LstTargetSourceMatchWrap != null && LstTargetSourceMatchWrap.size() > 0)
        {   
            SVMXC__ServiceMax_Config_Data__c cnfobj1 = new SVMXC__ServiceMax_Config_Data__c();              
            cnfobj1 = LstTargetSourceMatchWrap.get(IntVal-1).targetSourceMatchConfig;              
            LstTargetSourceMatchWrap.remove(IntVal-1);
            
            if(cnfobj1.id!=null)
                LstTargetSrcMatchWrapConfObjToDel.add(cnfobj1);
            
        }
        if(IntVal <= LstTargetSourceMatchWrap.size())    
        {       
            for(integer i = IntVal; i <= LstTargetSourceMatchWrap.size(); i++ )
                //LstCriWrap[i-1].objConf.SVMXC__Sequence__c = i;
                //LstTargetSourceMatchWrap[i-1].Sequence = i;
                LstTargetSourceMatchWrap[i-1].targetSourceMatchConfig.SVMXC__Sequence__c = i;
        } 
        WSCH_AuditLogger.debug('LstTargetSourceMatchWrap val'+LstTargetSourceMatchWrap);   
        //WSCH_AuditLogger.finish();          
    }
    //---------------------------- Methods to add row to Expression  ------------------------------------------
    /*public void HdrADDRow3()
    {
        try {
            lstTargetSourceAssignConfig.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(lstTargetSourceAssignConfig.size() + 1)));   
            System.debug('lsteligibilityMatchConfig val'+lstTargetSourceAssignConfig);            
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }/
    
    //---------------------------- Methods to delete a row from Expression  ------------------------------------------    
    /*public void HdrDeleteRow3()
    {
        integer IntVal;
        IntVal = integer.valueOf(StrDelIndex3);  
        System.debug('IntVal val'+IntVal);      
        if(lstTargetSourceAssignConfig.get(IntVal - 1).id != null) {
            lstTargetSourceAssignConfigDel.add(lstTargetSourceAssignConfig.get(IntVal - 1));
        }
        lstTargetSourceAssignConfig.remove(IntVal - 1); 
        if(IntVal <= lstTargetSourceAssignConfig.size()) {       
            for(integer i = IntVal; i <= lstTargetSourceAssignConfig.size(); i++ )
                lstTargetSourceAssignConfig[i-1].SVMXC__Sequence__c = i;        
        }    
       System.debug('lsteligibilityMatchConfig val'+lstTargetSourceAssignConfig);            
    }*/
    
    public string[] getstrFieldMatchRuleIdRearrange()
    {
        return strFieldMatchRuleIdRearrange;
    }
       
    public void setstrFieldMatchRuleIdRearrange(string[] o)
    {
        this.strFieldMatchRuleIdRearrange=o;
    }
    
    public List<SelectOption> getSeqoptions() {
        
        Seqoptions = new List<SelectOption>();            
        if (lstTempWOFieldMatchingRules.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:lstTempWOFieldMatchingRules)
            {                               
                if (s.SVMXC__Name__c != null)
                Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        }        
        return Seqoptions;
    }
    
    public void newWOFieldMatchingRules() {
        
        isDisableSelect = true;
        
        /* While creating New Rule, enable the other sections in UI only if the Source and Target objects are selected */
        if((stringSelectObj1 != null && stringSelectObj2 != null) && (!stringSelectObj1.equalsIgnoreCase('--None--') && !stringSelectObj1.equalsIgnoreCase('SVMX.None')) && 
                (!stringSelectObj2.equalsIgnoreCase('--None--') && !stringSelectObj2.equalsIgnoreCase('SVMX.None'))) {
            isRenderExp = true;
            
            isRenderSave = true;
            isRenderNew = false;
            isNewRule = true;
            isRendercancel = true;
            isDisableOrderByField = false;
            
            //below logic creates a new row in UI to create a new Field Match Rule only if Target and Source object is selected
            processObjFieldMatchRule = new SVMXC__ServiceMax_Processes__c();
            processObjFieldMatchRule.SVMXC__Select__c = true;     
            processObjFieldMatchRule.SVMXC__Active__c = true;     
            lstWOFieldMatchingRules.add(processObjFieldMatchRule);
        } else {
            isRenderExp = false;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG068()));
        }
        
        //isRenderNew = false;
        isRenderEdit = false;
        //isRenderSave = true;
        isRenderDelete = false;
        //isRendercancel = true;
        isRenderRuleSeq = false;
        isactive = true;
        isRenderSourceObj1 = true;
        isRenderSourceObj1 = true;
        //isNewRule = true;
        
        //lstTargetSourceAssignConfig.clear();
        LstTargetSourceMatchWrap.clear();
        //lstOfFieldMaps.clear();
        lsteligibilityMatchConfig.clear();
        lsteligMatchConfigDel.clear();
        
        /*processObjFieldMatchRule = new SVMXC__ServiceMax_Processes__c();
        processObjFieldMatchRule.SVMXC__Select__c = true;     
        processObjFieldMatchRule.SVMXC__Active__c = true;     
        lstWOFieldMatchingRules.add(processObjFieldMatchRule);*/
    }
    
    public void saveRule() {
        
        WSCH_AuditLogger.debug('Inside saveRule()'); 
        
        IsValidExp = true;
        
        try {
            
            processObjFieldMatchRule = new SVMXC__ServiceMax_Processes__c();
            String strParentcriteria = '';
            //String strChildcriteria = '';
            
            if(isNewRule) {           
                processObjFieldMatchRule.SVMXC__Sequence__c = (lstWOFieldMatchingRules.size());
            }
            if(!isNewRule)
            {           
                processObjFieldMatchRule = processObjFieldMatchRuleEdit;
            }
            
            this.validation();
            
            if(IsValidProcess) {
                WSCH_AuditLogger.debug('inside if(IsValidProcess)');
                WSCH_AuditLogger.debug('lsteligibilityMatchConfig val'+lsteligibilityMatchConfig);
                if(lsteligibilityMatchConfig != null && lsteligibilityMatchConfig.size() >0)
                {
                    List<SVMXC__ServiceMax_Config_Data__c> lsteligibilityMatchConfigtemp = new List<SVMXC__ServiceMax_Config_Data__c>();
                    List<SVMXC__ServiceMax_Config_Data__c> lsteligibilityMatchConfigtempDel = new List<SVMXC__ServiceMax_Config_Data__c>();
                    for(SVMXC__ServiceMax_Config_Data__c objconfdata : lsteligibilityMatchConfig)
                    {
                        if(objconfdata.SVMXC__Operator__c != null && objconfdata.SVMXC__Operator__c != getTAG038() && objconfdata.SVMXC__Operator__c != 'SVMX.NONE'&& objconfdata.SVMXC__Field_Name__c != getTAG038())
                            lsteligibilityMatchConfigtemp.add(objconfdata);
                        else if(objconfdata.id != null)
                            lsteligibilityMatchConfigtempDel.add(objconfdata);
                            
                    }
                   
                    lsteligibilityMatchConfig.clear();
                    lsteligibilityMatchConfig.addall(lsteligibilityMatchConfigtemp);
                    if(!lsteligibilityMatchConfigtempDel.isempty()) {
                        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){     //SDL-SVMX-DELETE-FLS-ENFORCED
                            delete lsteligibilityMatchConfigtempDel;
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.COMM001_TAG142));
                            return;
                        }
                    }
                }
                
                if(lsteligibilityMatchConfig != null && lsteligibilityMatchConfig.size() >0)
                {   
                    List<SVMXC__ServiceMax_Config_Data__c> lsteligibilityMatchConfigtemp = new List<SVMXC__ServiceMax_Config_Data__c>();                  
                    integer seq =1;                   
                    for(SVMXC__ServiceMax_Config_Data__c Cnfig :lsteligibilityMatchConfig)
                    {
                        Cnfig.SVMXC__Sequence__c = seq;
                        seq = seq + 1;
                        lsteligibilityMatchConfigtemp.add(Cnfig);
                        
                    }
                    lsteligibilityMatchConfig.clear();
                    if(!lsteligibilityMatchConfigtemp.isempty()) {
                        lsteligibilityMatchConfig.addall(lsteligibilityMatchConfigtemp);
                    }
                    
                    WSCH_AuditLogger.debug('Inside save(), strAdvanceExp1 - ' + strAdvanceExp1);
                    //validating the advanced expression 1: entry criteria
                    boolean isExp1Val = false;
                    if(strAdvanceExp1 != null) {
                        //isExp1Val = submitExp(processObjFieldMatchRule,lsteligibilityMatchConfig,strAdvanceExp1);
                        isExp1Val = submitExp2(processObjFieldMatchRule,lsteligibilityMatchConfig,strAdvanceExp1,stringSelectObj1);
                    }
                    
                    WSCH_AuditLogger.debug('Inside save(), isExp1Val - ' + isExp1Val);
                    
                    /*if(strAdvanceExp1 != null && !isExp1Val)
                    {
                        isRenderExp = true;
                        IsValidExp = false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG052() + ':' + getTAG058()));
                    }*/
                    
                    //strParentcriteria = ValidateExp.getCriteria('SVMXC__Service_Order__c', strAdvanceExp1, lsteligibilityMatchConfig );
                    strParentcriteria = ValidateExp.getCriteria(stringSelectObj1, strAdvanceExp1, lsteligibilityMatchConfig );
                    WSCH_AuditLogger.debug(' Inside save(), strParentcriteria - ' + strParentcriteria);
                    
                    //comment this. Only for testing
                    //strParentcriteria = 'SVMXC__Priority__c=\'High\'';
                   
                    if((strAdvanceExp1 != null && !isExp1Val) || strParentcriteria == 'ERROR')
                    {
                        isRenderExp = true;
                        IsValidExp = false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG052() + ':' + getTAG058()));
                    }
               }
               
               //below code is for validating the Advanced expression 2
               WSCH_AuditLogger.debug('LstTargetSourceMatchWrap - ' + LstTargetSourceMatchWrap);
               List<SVMXC__ServiceMax_Config_Data__c> lstOfTargetSourceMatchConf = new List<SVMXC__ServiceMax_Config_Data__c>();
               if(LstTargetSourceMatchWrap != null && LstTargetSourceMatchWrap.size() >0) {
                   for(TargetSourceMatchConfigWrapper wrapObj : LstTargetSourceMatchWrap) 
                   {
                       SVMXC__ServiceMax_Config_Data__c ConfigDataTargetSourceMatch = new SVMXC__ServiceMax_Config_Data__c(); 
                       WSCH_AuditLogger.debug('wrapObj.targetSourceMatchConfig - ' + wrapObj.targetSourceMatchConfig);                   
                       ConfigDataTargetSourceMatch.SVMXC__Field_Name__c = 'Name';
                       ConfigDataTargetSourceMatch.SVMXC__Display_Type__c = 'String';
                       WSCH_AuditLogger.debug('ConfigDataTargetSourceMatch.SVMXC__Display_Value__c - ' + ConfigDataTargetSourceMatch.SVMXC__Display_Value__c);
                       WSCH_AuditLogger.debug('ConfigDataTargetSourceMatch.SVMXC__Field_Name__c - ' + ConfigDataTargetSourceMatch.SVMXC__Field_Name__c);
                        
                       ConfigDataTargetSourceMatch.SVMXC__Operator__c='eq';
                       ConfigDataTargetSourceMatch.SVMXC__Operand__c = '123';
                       lstOfTargetSourceMatchConf.add(ConfigDataTargetSourceMatch);                         
                   }
                    WSCH_AuditLogger.debug('Inside save(), strAdvanceExp2 - ' + strAdvanceExp2);
                    WSCH_AuditLogger.debug('Inside save(), stringSelectObj2 - ' + stringSelectObj2);
                    //validating the advanced expression 2: TargetSourceMatch section
                    boolean isExp2Val = false;
                    String strParentCriteria2;
                    if(strAdvanceExp2 != null) {
                        isExp2Val = submitExp2(processObjFieldMatchRule,lstOfTargetSourceMatchConf,strAdvanceExp2, 'SVMXC__Service_Order__c');
                        //isExp2Val = submitExp2(processObjFieldMatchRule,lstOfTargetSourceMatchConf,strAdvanceExp2, stringSelectObj2);
                        //isExp2Val = submitExp(processObjFieldMatchRule,lstOfTargetSourceMatchConf,strAdvanceExp2);
                        //strParentCriteria2 = ValidateExp.getCriteria(stringSelectObj2, strAdvanceExp2, lstOfTargetSourceMatchConf );
                    }
                
                    WSCH_AuditLogger.debug('Inside save(), isExp2Val - ' + isExp2Val);
                    
                    if(strAdvanceExp2 != null && !isExp2Val)
                    //if(strParentcriteria2 == 'ERROR')
                    {
                        isRenderExp = true;
                        IsValidExp = false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG052() + ':' + getTAG059()));
                    }
                }
               
               boolean isSection3Empty = false, isSection2Empty = false;
               if(IsValidExp) {
                    WSCH_AuditLogger.debug('Inside if(IsValidExp())');
                    /* Setting the data for Process Object  */
                    processObjFieldMatchRule.SVMXC__Name__c = strProcessName;
                    processObjFieldMatchRule.SVMXC__Description__c = strDescription;
                    WSCH_AuditLogger.debug('isactive val'+isactive);
                    if(isNewRule) {
                        processObjFieldMatchRule.SVMXC__Active__c = isactive;
                    }
                    processObjFieldMatchRule.SVMXC__Advance_Expression__c = strAdvanceExp1;
                    processObjFieldMatchRule.SVMXC__Primary_Consolidation_Rule__c = strAdvanceExp2;
                    processObjFieldMatchRule.SVMXC__Rule_Type__c = 'Field Match Rule';
                    processObjFieldMatchRule.SVMXC__Source_Object_Name__c = stringSelectObj1; //'SVMXC__Service_Order__c';
                    processObjFieldMatchRule.SVMXC__Target_Object_Name__c = stringSelectObj2;
                    processObjFieldMatchRule.SVMXC__Parent_Object_Criteria__c = strParentcriteria;        //SVMXC__Purpose_of_Visit__c='Repair' 
                    processObjFieldMatchRule.RecordTypeId = ExpHdr_Rtype_Id; 
                    processObjFieldMatchRule.SVMXC__Select__c = false;
                    WSCH_AuditLogger.debug(' Inside save(), strSelectedOrderByField - ' + strSelectedOrderByField);
                    //if(strSelectedOrderByField != getTAG034() && strSelectedOrderByField != 'SVMX.NONE' && strSelectedOrderByField != 'SVMX.None') {
                        processObjFieldMatchRule.SVMXC__Field_Name__c = strSelectedOrderByField;        //selected order by field name
                    //}
                    
                    //iterate the list of object mapping processes and fetch the corresponding SF id, process ID and save it on Process obj
                    WSCH_AuditLogger.debug('Before iterating lstFieldMapProcesses - ' + strSelectedMap);
                    if(lstFieldMapProcesses != null && lstFieldMapProcesses.size() > 0) {
                        for(Integer i=0; i<lstFieldMapProcesses.size(); i++) {
                            
                            if(lstFieldMapProcesses[i].Id != null && 
                                String.valueOf(lstFieldMapProcesses[i].Id).equalsIgnoreCase(strSelectedMap)) {
                                    processObjFieldMatchRule.SVMXC__Process__c = lstFieldMapProcesses[i].Id;
                                    processObjFieldMatchRule.SVMXC__ProcessID__c = String.valueOf(lstFieldMapProcesses[i].Id);
                                    processObjFieldMatchRule.SVMXC__MapID__c = lstFieldMapProcesses[i].SVMXC__MapID__c;
                            } else if(strSelectedMap.equalsIgnoreCase(getTAG034()) || strSelectedMap.equalsIgnoreCase('SVMX.None') ) {
                                //processObjFieldMatchRule.SVMXC__MapID__c = strSelectedMap;
                                isSection3Empty = true;
                            }
                        }
                    }
                    
                    //validating mandatory sections
                    if(LstTargetSourceMatchWrap == null || (LstTargetSourceMatchWrap != null && LstTargetSourceMatchWrap.size() == 0)) {
                        isSection2Empty = true;
                    }
                    
                    if(LstTargetSourceMatchWrap != null && LstTargetSourceMatchWrap.size() > 0) {
                        for(TargetSourceMatchConfigWrapper wrapObj : LstTargetSourceMatchWrap) {
                            SVMXC__ServiceMax_Config_Data__c ConfigDataTargetSourceMatch = new SVMXC__ServiceMax_Config_Data__c();                    
                            ConfigDataTargetSourceMatch = wrapObj.targetSourceMatchConfig;
                            
                            if(ConfigDataTargetSourceMatch != null && (ConfigDataTargetSourceMatch.SVMXC__Field_Name__c == getTAG034() || ConfigDataTargetSourceMatch.SVMXC__Field_Name__c == 'SVMX.NONE') ||
                                    (ConfigDataTargetSourceMatch.SVMXC__Target_Field_Name__c == getTAG034() || ConfigDataTargetSourceMatch.SVMXC__Target_Field_Name__c == 'SVMX.NONE') ||
                                        ConfigDataTargetSourceMatch.SVMXC__Display_Value__c == '')
                            {
                               isSection2Empty = true;      
                            }
                        }
                    }
                    
                    if(isSection2Empty && isSection3Empty) {
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG069() + ' : ' + getTAG059()));
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG069() + ' : ' + getTAG061()));
                        isRenderExp = true;
                        return;
                    } else if(isSection2Empty) {
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG069() + ' : ' + getTAG059()));
                        isRenderExp = true;
                        return;
                    } else if(isSection3Empty) {
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG069() + ' : ' + getTAG061()));
                        isRenderExp = true;
                        return;
                    }
                    
                    WSCH_AuditLogger.debug('Before upsert processObjFieldMatchRule - ' + processObjFieldMatchRule);
                    /* Saving the process object */
                    //upsert processObjFieldMatchRule;
                    
                    if(processObjFieldMatchRule != null) {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( processObjFieldMatchRule, COMM_SecurityUtils.Access.Upsertable) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            upsert processObjFieldMatchRule; 
                        }else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));
                            return;
                        }
                    }
                    
                    retrieveWOFieldMatchRules();        //bugbash
                    
                    WSCH_AuditLogger.debug('strSelectedOrderByField - ' + strSelectedOrderByField);
                    /*  Iterate all the FieldMatchRule process objects and update the order_by_field to SVMXC__Field_Name__c
                     for all the FieldMatchRule process objects matching this source and target object combination  */
                    if(lstWOFieldMatchingRules != null && lstWOFieldMatchingRules.size() > 0) {
                        for(Integer i=0; i<lstWOFieldMatchingRules.size(); i++) {
                            //if(lstWOFieldMatchingRules[i].SVMXC__Field_Name__c != getTAG034() && lstWOFieldMatchingRules[i].SVMXC__Field_Name__c != 'SVMX.NONE'
                                    //&& lstWOFieldMatchingRules[i].SVMXC__Field_Name__c != 'SVMX.None') {
                                lstWOFieldMatchingRules[i].SVMXC__Field_Name__c = strSelectedOrderByField;
                            //}
                        }
                    }
                    
                    WSCH_AuditLogger.debug('Before upsert lstWOFieldMatchingRules - ' + lstWOFieldMatchingRules);
                    /* Saving the updated lstWOFieldMatchingRule. Each object in this list is updated with the order_by_field name */
                    //upsert lstWOFieldMatchingRules;
                    if(lstWOFieldMatchingRules != null && lstWOFieldMatchingRules.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWOFieldMatchingRules, COMM_SecurityUtils.Access.Upsertable) ) {  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            upsert lstWOFieldMatchingRules; 
                        }else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));
                            return;
                        }
                    }                   
                    
                    /* obj1fieldMap contains the fields of TargetObject  */
                    Map<String,Schema.SObjectField> obj1fieldMap = new Map<String,Schema.SObjectField>();                        
                    //objfieldMap = SVMXC__Service_Order__c.SObjectType.getDescribe().fields.getMap();
                    obj1fieldMap = Schema.getGlobalDescribe().get(stringSelectObj1).getDescribe().fields.getMap();
                    
                    /* obj2fieldMap contains the fields of MappedObject  */
                    Map<String,Schema.SObjectField> obj2fieldMap = new Map<String,Schema.SObjectField>();                        
                    //objfieldMap = SVMXC__Service_Order__c.SObjectType.getDescribe().fields.getMap();
                    obj2fieldMap = Schema.getGlobalDescribe().get(stringSelectObj2).getDescribe().fields.getMap();
                    
                    WSCH_AuditLogger.debug('lsteligibilityMatchConfig val'+lsteligibilityMatchConfig); 
                    integer seqval = 1;
                    
                    WSCH_AuditLogger.debug('Before starting to save config object for entry criteria');
                    /* Setting the data for Config Object for each entry criteria - corresponding to Section 1 in UI */
                    for(SVMXC__ServiceMax_Config_Data__c confobj: lsteligibilityMatchConfig) {
                        
                        confobj.SVMXC__Expression_Type__c = 'Field Match Expression';
                        confobj.RecordTypeId = ExpDtl_Rtype_Id;
                        confobj.SVMXC__Sequence__c = seqval;  
                        seqval = seqval+1;
                        confobj.SVMXC__Expression_Rule__c = processObjFieldMatchRule.id;
                        
                        /* Below logic is used to get the SVMXC__Field_Name__c and display_type */
                        for (String fieldKey : obj1fieldMap.keySet()) 
                        {
                            Schema.SObjectField fsObj = obj1fieldMap.get(fieldKey);
                            Schema.DescribeFieldResult f = fsObj.getDescribe();
                            //WSCH_AuditLogger.debug('confobj.SVMXC__Field_Name__c - ' + confobj.SVMXC__Field_Name__c);
                            //use getLocalName() below instead of getName().getLocalName() does not contain namespace
                            if(f.getName() == confobj.SVMXC__Field_Name__c)
                            {
                                confobj.SVMXC__Display_Type__c = f.getType().name();
                                confobj.SVMXC__Field_Name__c = f.getName();
                            }
                        }
                    }
                    
                    WSCH_AuditLogger.debug('Before saving TargetSourceMatch config objects');
                    WSCH_AuditLogger.debug('LstTargetSourceMatchWrap contents - ' + LstTargetSourceMatchWrap);
                    /* Setting the data for Config Object for each Target and Source match - corresponding to Section 2 in UI */
                    if(LstTargetSourceMatchWrap != null && LstTargetSourceMatchWrap.size() >0) {
                        seqval = 1;
                        for(TargetSourceMatchConfigWrapper wrapObj : LstTargetSourceMatchWrap) {
                            SVMXC__ServiceMax_Config_Data__c ConfigDataTargetSourceMatch = new SVMXC__ServiceMax_Config_Data__c();                    
                            ConfigDataTargetSourceMatch = wrapObj.targetSourceMatchConfig;
                            
                            if(ConfigDataTargetSourceMatch != null && (ConfigDataTargetSourceMatch.SVMXC__Field_Name__c != getTAG034() && ConfigDataTargetSourceMatch.SVMXC__Field_Name__c != 'SVMX.NONE') &&
                                    (ConfigDataTargetSourceMatch.SVMXC__Target_Field_Name__c != getTAG034() && ConfigDataTargetSourceMatch.SVMXC__Target_Field_Name__c != 'SVMX.NONE'))
                            {
                                ConfigDataTargetSourceMatch.SVMXC__Expression_Type__c = 'Field Match Lookup';
                                ConfigDataTargetSourceMatch.RecordTypeId = ExpDtl_Rtype_Id;
                                ConfigDataTargetSourceMatch.SVMXC__Expression_Rule__c = processObjFieldMatchRule.id;
                                ConfigDataTargetSourceMatch.SVMXC__Sequence__c = seqval;  
                                seqval = seqval+1;
                                
                                /* Below logic is used to get the SVMXC__Target_Field_Name__c and display_type */
                                for (String fieldKey : obj1fieldMap.keySet()) 
                                {
                                    Schema.SObjectField fsObj = obj1fieldMap.get(fieldKey);
                                    Schema.DescribeFieldResult f = fsObj.getDescribe();
                                    //WSCH_AuditLogger.debug('ConfigDataTargetSourceMatch.SVMXC__Target_Field_Name__c - ' + ConfigDataTargetSourceMatch.SVMXC__Target_Field_Name__c);
                                    //use getLocalName() below instead of getName().getLocalName() does not contain namespace
                                    if(f.getName() == ConfigDataTargetSourceMatch.SVMXC__Target_Field_Name__c)
                                    {
                                        ConfigDataTargetSourceMatch.SVMXC__Target_Field_Name__c = f.getName();
                                    }
                                }
                                /* Below logic is used to get the SVMXC__Field_Name__c */
                                for (String fieldKey : obj2fieldMap.keySet()) 
                                {
                                    Schema.SObjectField fsObj = obj2fieldMap.get(fieldKey);
                                    Schema.DescribeFieldResult f = fsObj.getDescribe();
                                    //WSCH_AuditLogger.debug('ConfigDataTargetSourceMatch.SVMXC__Field_Name__c - ' + ConfigDataTargetSourceMatch.SVMXC__Field_Name__c);
                                    //use getLocalName() below instead of getName().getLocalName() does not contain namespace
                                    if(f.getName() == ConfigDataTargetSourceMatch.SVMXC__Field_Name__c)
                                    {
                                        ConfigDataTargetSourceMatch.SVMXC__Display_Type__c = f.getType().name();
                                        ConfigDataTargetSourceMatch.SVMXC__Field_Name__c = f.getName();
                                    }
                                }
                            }
                            WSCH_AuditLogger.debug('Before upsert ConfigDataTargetSourceMatch' + ConfigDataTargetSourceMatch);
                            //upsert ConfigDataTargetSourceMatch;
                            if(ConfigDataTargetSourceMatch != null) {
                                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( ConfigDataTargetSourceMatch, COMM_SecurityUtils.Access.Upsertable) ) {  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                    upsert ConfigDataTargetSourceMatch; 
                                }else {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));
                                    return;
                                }
                            }
                        }
                    }
                    
                    /* Setting the data for Config Object for each Target and Source assignment - corresponding to Section 3 in UI */
                    /*seqval = 1;
                    for(SVMXC__ServiceMax_Config_Data__c confobj: lstTargetSourceAssignConfig) {
                        
                        confobj.SVMXC__Expression_Type__c = 'Field Match Assignments';
                        confobj.RecordTypeId = ExpDtl_Rtype_Id;
                        confobj.SVMXC__Sequence__c = seqval;  
                        seqval = seqval+1;
                        confobj.SVMXC__Expression_Rule__c = processObjFieldMatchRule.id;
                        
                      //   Below logic is used to get the SVMXC__Target_Field_Name__c and display_type 
                        for (String fieldKey : obj1fieldMap.keySet()) 
                        {
                            Schema.SObjectField fsObj = obj1fieldMap.get(fieldKey);
                            Schema.DescribeFieldResult f = fsObj.getDescribe();
                            system.debug('confobj.SVMXC__Target_Field_Name__c - ' + confobj.SVMXC__Target_Field_Name__c);
                            //use getLocalName() below instead of getName().getLocalName() does not contain namespace
                            if(f.getName() == confobj.SVMXC__Target_Field_Name__c)
                            {
                                //confobj.SVMXC__Display_Type__c = f.getType().name();
                                confobj.SVMXC__Target_Field_Name__c = f.getName();
                            }
                        }
                        
                       //  Below logic is used to get the SVMXC__Source_Field_Name__c and display_type 
                        for (String fieldKey : obj2fieldMap.keySet()) 
                        {
                            Schema.SObjectField fsObj = obj2fieldMap.get(fieldKey);
                            Schema.DescribeFieldResult f = fsObj.getDescribe();
                            system.debug('confobj.SVMXC__Field_Name__c - ' + confobj.SVMXC__Field_Name__c);
                            //use getLocalName() below instead of getName().getLocalName() does not contain namespace
                            if(f.getName() == confobj.SVMXC__Field_Name__c)
                            {
                                //confobj.SVMXC__Display_Type__c = f.getType().name();
                                confobj.SVMXC__Field_Name__c = f.getName();
                            }
                        }
                    }*/
                    WSCH_AuditLogger.debug('Inside save() LstTargetSrcMatchWrapConfObjToDel val : '+LstTargetSrcMatchWrapConfObjToDel);
                    
                    if(!lsteligMatchConfigDel.isempty()) {
                        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){     //SDL-SVMX-DELETE-FLS-ENFORCED
                            delete lsteligMatchConfigDel;
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.COMM001_TAG142));
                            return;
                        }
                    }
                        
                    if(lsteligibilityMatchConfig!= null && lsteligibilityMatchConfig.size()>0) {
                        //upsert lsteligibilityMatchConfig;
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lsteligibilityMatchConfig, COMM_SecurityUtils.Access.Upsertable) ) {        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            upsert lsteligibilityMatchConfig; 
                        }else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));
                            return;
                        }
                    }
                        
                    if(!LstTargetSrcMatchWrapConfObjToDel.isempty()) {      //SDL-SVMX-DELETE-FLS-ENFORCED
                        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                            delete LstTargetSrcMatchWrapConfObjToDel;
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.COMM001_TAG142));
                            return;
                        }
                    }
                    //if(lstTargetSourceAssignConfig!= null && lstTargetSourceAssignConfig.size()>0)
                      //  upsert lstTargetSourceAssignConfig;
                    
                    //retrieveWOFieldMatchRules();  // bugbash
                    
                    for(SVMXC__ServiceMax_Processes__c objEligCrit: lstWOFieldMatchingRules) {
                        if(objEligCrit.SVMXC__Select__c == true)           
                            objEligCrit.SVMXC__Select__c = false;           
                    }
                    WSCH_AuditLogger.debug('Before calling setDefaultValues() inside save()');
                    //WSCH_AuditLogger.finish();
                    setDefaultValues();
                    
               } else {
                    WSCH_AuditLogger.debug('Inside else, if not Valid expression ');
                    isRenderExp = true; 
                    //Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG052()));
                    //WSCH_AuditLogger.finish();
                }
                
            } else { 
                WSCH_AuditLogger.debug('Inside else, if not Valid process');
                isRenderExp = true;
                //WSCH_AuditLogger.finish();
            }
            
        } catch(exception ex) {
            WSCH_AuditLogger.error('Exception caught:WSCH_FieldMatchingRules::saveRule(): ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG048()));
        }
        WSCH_AuditLogger.finish();
    }
    
    //------------------------------------------- Method to Edit Field Matching Rules ----------------------
    public void editRule()
    {
        WSCH_AuditLogger.debug('Inside editRule()');
        isDisableSelect = true;
        isRenderExp = true;
        isRenderNew =false;
        isRenderEdit = false;
        isRenderSave = true;
        isRenderDelete = false;
        isRendercancel = true;
        isNewRule = false;
        isRenderRuleSeq = false;
        isDisableOrderByField = false;
        Integer selectedCount = 0;       
        lsteligMatchConfigDel.clear();
        //lstTargetSourceAssignConfig.clear();
        LstTargetSourceMatchWrap.clear();
        lstOperatorSelectLst.clear();
        lstOfFieldMaps.clear();
        WSCH_AuditLogger.debug('inside editRule(), before populateOperators() call');
        populateOperators();
        populateFieldMapping();
        
        processObjFieldMatchRuleEdit = new SVMXC__ServiceMax_Processes__c();
        for(SVMXC__ServiceMax_Processes__c objEligCrit: lstWOFieldMatchingRules)
        {
            if(objEligCrit.SVMXC__Select__c == true)
            {
                selectedCount += 1;
                strProcessName = objEligCrit.SVMXC__Name__c;
                strDescription = objEligCrit.SVMXC__Description__c;
                isactive = objEligCrit.SVMXC__Active__c;
                strAdvanceExp1 = objEligCrit.SVMXC__Advance_Expression__c  ;
                strAdvanceExp2 = objEligCrit.SVMXC__Primary_Consolidation_Rule__c ;
                
                WSCH_AuditLogger.debug('objEligCrit.SVMXC__MapID__c - ' + objEligCrit.SVMXC__MapID__c);
                if(objEligCrit.SVMXC__MapID__c != 'SVMX.None' && objEligCrit.SVMXC__MapID__c != 'SVMX.NONE') {
                    strSelectedMap = String.valueOf(objEligCrit.SVMXC__ProcessID__c);
                } else {
                    strSelectedMap = getTAG034();
                }
                processObjFieldMatchRuleEdit = objEligCrit;
            }
        }
        
        if( selectedCount == 1 )
        {
            /* populate the first section, WO eligibility by retrieving the config object for rule type = 'Field Match Expression'  */
            lsteligibilityMatchConfig.clear();
            lsteligibilityMatchConfig = [Select Id,SVMXC__Sequence__c,SVMXC__Field_Name__c,SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Object_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Lookup_Field_API_Name__c,SVMXC__Expression_Type__c,SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: processObjFieldMatchRuleEdit.id and SVMXC__Expression_Type__c = 'Field Match Expression' order by SVMXC__Sequence__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            List<SVMXC__ServiceMax_Config_Data__c >lstTargetSourceMatchConfig = [Select Id,SVMXC__Sequence__c,SVMXC__Field_Name__c,SVMXC__Source_Field_Name__c,SVMXC__Target_Field_Name__c,SVMXC__Display_Value__c,SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Object_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Lookup_Field_API_Name__c,SVMXC__Expression_Type__c,SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: processObjFieldMatchRuleEdit.id and SVMXC__Expression_Type__c = 'Field Match Lookup' order by SVMXC__Sequence__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            /*  Populate the second section, TargetSourceMatchConfig data into the list of Wrapper  */
            if(lstTargetSourceMatchConfig != null && lstTargetSourceMatchConfig.size() > 0) {
                
                WSCH_AuditLogger.debug('Inside editRule(), lstTargetSourceMatchConfig ' + lstTargetSourceMatchConfig);
                TargetSourceMatchConfigWrapper wrapObj;
                for(SVMXC__ServiceMax_Config_Data__c tempTargetSourceMatchConf : lstTargetSourceMatchConfig)
                {
                    wrapObj =  new TargetSourceMatchConfigWrapper();
                    wrapObj.targetSourceMatchConfig = tempTargetSourceMatchConf;
                    wrapObj.lstTargetObjField = lstTargetObjField;
                    
                    if(tempTargetSourceMatchConf.SVMXC__Target_Field_Name__c != '' && tempTargetSourceMatchConf.SVMXC__Target_Field_Name__c !=null && tempTargetSourceMatchConf.SVMXC__Target_Field_Name__c != getTAG034()) {
                        wrapObj.IsRenderpicklist = true;
                    } else if (tempTargetSourceMatchConf.SVMXC__Display_Value__c != '' && tempTargetSourceMatchConf.SVMXC__Display_Value__c !=null ) {
                        wrapObj.IsRenderpicklist = false;
                    } else {
                        wrapObj.IsRenderpicklist = true;
                    }
                    
                    if(wrapObj.IsRenderpicklist )
                    {
                        wrapObj.lstSourceObjField = lstSourceObjField;
                    }
                    LstTargetSourceMatchWrap.add(wrapObj);
                }
            }
            
            /* populate the third section, TargetSourceAssignConfig data by retrieving the config object for rule type = 'Field Match Assignments'  */
            //lstTargetSourceAssignConfig = [Select Id,SVMXC__Sequence__c,SVMXC__Field_Name__c,SVMXC__Source_Field_Name__c,SVMXC__Target_Field_Name__c,SVMXC__Display_Value__c,SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Object_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Lookup_Field_API_Name__c,SVMXC__Expression_Type__c,SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: processObjFieldMatchRuleEdit.id and SVMXC__Expression_Type__c = 'Field Match Assignments' order by SVMXC__Sequence__c];
            
        } else if( selectedCount == 0 ) {
            WSCH_AuditLogger.debug('selectedCount ==0 ');
            setDefaultValues();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG037(),''));
        } else {
            
            setDefaultValues();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG038(),''));
        }
        //WSCH_AuditLogger.finish();
    }
    
    //------------------------------------------- Method to Validate Eligibility Matching Rules ----------------------
    public void validation()
    {
        WSCH_AuditLogger.debug('Inside validation()');
        integer count = 0;
        IsValidProcess=true; 
        if(strProcessName == null || strProcessName == '')
        {
            IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG041(),''));
            WSCH_AuditLogger.debug('Process name is null ' + getTAG041());
        }  
        if( strProcessName.length() < 8 )   
        {
             IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG051(),''));
            WSCH_AuditLogger.debug('Process length is < 8 ' + getTAG051());
        }       
       
        for(SVMXC__ServiceMax_Processes__c objEligCrit: lstWOFieldMatchingRules)
        {
            if(objEligCrit.SVMXC__Select__c == true)
            {
                objEligCrit.SVMXC__Name__c = strProcessName;
            }
            if(strProcessName == objEligCrit.SVMXC__Name__c)
                count = count+1; 
        } 
        /* if(!isNewRule && count == 1)
        {
                IsValidProcess = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG043(),''));
        }*/
         if(count > 1)
        {
                IsValidProcess = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG043(),''));
                WSCH_AuditLogger.debug('process count is > 1 ' + getTAG043());
        } 
        
      
        if(lsteligibilityMatchConfig != null && lsteligibilityMatchConfig.size() > 0)
        {
            for(Integer i=0; i < lsteligibilityMatchConfig.size(); i++)
            {
                if((lsteligibilityMatchConfig[i].Operator__c != getTAG034() &&  (lsteligibilityMatchConfig[i].Operator__c != 'SVMX.NONE' && lsteligibilityMatchConfig[i].Operator__c != 'SVMX.None')) && lsteligibilityMatchConfig[i].SVMXC__Field_Name__c == getTAG034())
                {
                    IsValidProcess=false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG042()));
                }
            }
        }
        
        if(LstTargetSourceMatchWrap != null && LstTargetSourceMatchWrap.size() > 0) {
            for(Integer i=0; i < LstTargetSourceMatchWrap.size(); i++) {
                TargetSourceMatchConfigWrapper confWrapObj = LstTargetSourceMatchWrap[i];
                SVMXC__ServiceMax_Config_Data__c confDataObj = confWrapObj.targetSourceMatchConfig;
                
                if((confDataObj.Field_Name__c == getTAG034() && confDataObj.Field_Name__c == 'SVMX.NONE' && confDataObj.Field_Name__c == 'SVMX.None') || 
                    (confDataObj.Operator__c == getTAG034() && confDataObj.Operator__c == 'SVMX.NONE' && confDataObj.Operator__c == 'SVMX.None') || 
                        (confDataObj.Target_Field_Name__c == getTAG034() && confDataObj.Target_Field_Name__c == 'SVMX.NONE' && confDataObj.Target_Field_Name__c == 'SVMX.None')) {
                        IsValidProcess=false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG042()));
                }
            }
        }
       
        /*if(lstTargetSourceAssignConfig != null && lstTargetSourceAssignConfig.size() > 0)
        {
            for(Integer i=0; i < lstTargetSourceAssignConfig.size(); i++)
            {
                if((lstTargetSourceAssignConfig[i].Field_Name__c == getTAG034() || lstTargetSourceAssignConfig[i].Field_Name__c == 'SVMX.NONE' || lstTargetSourceAssignConfig[i].Target_Field_Name__c == getTAG034() || lstTargetSourceAssignConfig[i].Target_Field_Name__c == 'SVMX.NONE'))
                {
                    IsValidProcess=false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG042()));
                }
            }
        }*/
        //WSCH_AuditLogger.finish();
    }
    
    public boolean submitExp(SVMXC__ServiceMax_Processes__c ProcessObj, List<SVMXC__ServiceMax_Config_Data__c> ExpConfigDataLst, string AdvExp)
    {   
        WSCH_AuditLogger.debug('Inside submitExp()');
        SVMXC.SFM_WrapperDef.SFM_Expression oSFM_Exp = new SVMXC.SFM_WrapperDef.SFM_Expression(ProcessObj,ExpConfigDataLst);
        oSFM_Exp.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpHdr_Rtype_Id, SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c',SVMXC__Advance_Expression__c=AdvExp);
        List<SVMXC.SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SVMXC.SFM_WrapperDef.SFM_Expression>();
        LstSFM_Exp.add(oSFM_Exp);
        SVMXC.SFM_WrapperDef.SFM_Request_Expression oRequest = new SVMXC.SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
        Save_Response = ValidateExp.SFM_validateExpression(oRequest);        
        if( Save_Response.success != null && Boolean.valueOf(Save_Response.success))
            return true;       
        else       
            return false;
    }
    
    public boolean submitExp2(SVMXC__ServiceMax_Processes__c ProcessObj, List<SVMXC__ServiceMax_Config_Data__c> ExpConfigDataLst, string AdvExp, string strObj)
    {   
        WSCH_AuditLogger.debug('Inside submitExp2()');
        //WSCH_AuditLogger.debug('strTargetObj - ' + strTargetObj);
        WSCH_AuditLogger.debug('strObj - ' + strObj);
        SVMXC.SFM_WrapperDef.SFM_Expression oSFM_Exp = new SVMXC.SFM_WrapperDef.SFM_Expression(ProcessObj,ExpConfigDataLst);
        oSFM_Exp.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpHdr_Rtype_Id, SVMXC__Source_Object_Name__c = strObj, SVMXC__Advance_Expression__c = AdvExp);
        List<SVMXC.SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SVMXC.SFM_WrapperDef.SFM_Expression>();
        LstSFM_Exp.add(oSFM_Exp);
        SVMXC.SFM_WrapperDef.SFM_Request_Expression oRequest = new SVMXC.SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
        Save_Response = ValidateExp.SFM_validateExpression(oRequest);        
        if( Save_Response.success != null && Boolean.valueOf(Save_Response.success))
            return true;       
        else       
            return false;
    }
    
    //------------------------------------------- Method to Delete Eligibility Matching Rules ----------------------
    public void deleteRule()
    {
        WSCH_AuditLogger.debug('Inside deleteRule()');
        SVMXC__ServiceMax_Processes__c objWOFieldMatchRulesDel = new SVMXC__ServiceMax_Processes__c();
        isRenderExp = false;
        isRenderNew = true;
        isRenderEdit = true;
        isRenderSave = false;
        isRenderDelete = true;
        isRendercancel = false;
        list<SVMXC__ServiceMax_Config_Data__c> lstconfig = new list<SVMXC__ServiceMax_Config_Data__c>();
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c objEligCrit: lstWOFieldMatchingRules)
        {
            if(objEligCrit.Select__c == true)
            {
                selectedCount += 1;
              
                objWOFieldMatchRulesDel = objEligCrit;
            }
        }
        if( selectedCount == 1 )
        {
            lstconfig = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objWOFieldMatchRulesDel.id];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //delete lstconfig;
            // -CRUD
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {    //SDL-SVMX-DELETE-FLS-ENFORCED
                delete lstconfig;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }            
            //delete objWOFieldMatchRulesDel;
            // -CRUD
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {      //SDL-SVMX-DELETE-FLS-ENFORCED
                delete objWOFieldMatchRulesDel;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            retrieveWOFieldMatchRules();
            strProcessName = null;
            strDescription = null;
            isactive = false;
            strAdvanceExp1 = null  ;
            //strAdvanceExp2 = null ;
          
        }
        else if( selectedCount == 0 ) 
        {   
            isRenderNew = true;
            isRenderEdit = true;
            isRenderSave = false;
            isRenderDelete = true;
            isRendercancel = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG037(),''));   
        }
        else
        {
            setDefaultValues();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG038(),''));
          
        }
       setDefaultValues();
    }
    
    //-------------------------------------- Method to save rearrnged Eligibility Rule ----------------------------
    public void SVMX_SaveSequence() {
        
        list<SVMXC__ServiceMax_Processes__c> lsttemp = new list<SVMXC__ServiceMax_Processes__c>();
        double t;
      
        for(integer i =0 ;i<lstTempWOFieldMatchingRules.size();i++)
        {
            lstTempWOFieldMatchingRules[i].SVMXC__Sequence__c = i + 1;
        }
        if(lstTempWOFieldMatchingRules != null && lstTempWOFieldMatchingRules.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(lstTempWOFieldMatchingRules, COMM_SecurityUtils.Access.Updateable, true))      //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        WSCH_AuditLogger.debug(System.label.COMM001_TAG142);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                        update lstTempWOFieldMatchingRules; 
                    }
                }
        setDefaultValues();
    }
    
    //----------------------------- Method to Cancelthe changes made to Eligibility Matching Rules ----------------------
    public void cancelRule() {
        
        for(SVMXC__ServiceMax_Processes__c objEligCrit: lstWOFieldMatchingRules)
        {
            if(objEligCrit.SVMXC__Select__c == true)           
                objEligCrit.SVMXC__Select__c = false;           
        }
        setDefaultValues();
    }
    
    //---------------------------------------------Rule Sequence------------------------------------ 
    public void SVMX_OrderSequence()
    {
        isRenderNew =false;
        isRenderEdit=false;
        isRenderSave=false;
        isRenderDelete=false;
        isRendercancel=false;
        retrieveWOFieldMatchRules();
        boolean DisableParntLst = true;
        lstTempWOFieldMatchingRules.clear();
        lstTempWOFieldMatchingRules.addAll(lstWOFieldMatchingRules);
        for(integer i=0;i<lstWOFieldMatchingRules.size();i++)
        {
            if(lstWOFieldMatchingRules[i].SVMXC__Select__c)           
                DisableParntLst = true;
           
        }
        if(DisableParntLst)
        {
            displaySeqPopup = true;           
            isRenderRuleSeq = false;
        }       
    }
    
    //------------------------------- Method to move Eligibility Rule up by one position -----------------------
    public void UP() {
        
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstTempWOFieldMatchingRules.size();j++)
        {
            for(integer i=0;i<strFieldMatchRuleIdRearrange.size();i++)
            {
                if(strFieldMatchRuleIdRearrange[i]==lstTempWOFieldMatchingRules[0].Id)
                {
                    lstTempWOFieldMatchingRules[j] = lstTempWOFieldMatchingRules[j];
                        //break;
                }
                else if(strFieldMatchRuleIdRearrange[i]==lstTempWOFieldMatchingRules[j].Id)
                {
                    temp = lstTempWOFieldMatchingRules[j]; 
                    lstTempWOFieldMatchingRules[j] = lstTempWOFieldMatchingRules[j-1];
                    lstTempWOFieldMatchingRules[j-1]=temp;                    
                    selIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    lstTempWOFieldMatchingRules[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    lstTempWOFieldMatchingRules[selIndex].SVMXC__Sequence__c = selIndex;
                }
            }
        }
    }
    
    //------------------------------- Method to move Eligibility Rule down by one position -----------------------
    public void Down() {
        
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=lstTempWOFieldMatchingRules.size()-1;j>=0;j--)
        {
            for(integer i=0;i<strFieldMatchRuleIdRearrange.size();i++)
            {
                if(strFieldMatchRuleIdRearrange[i]==lstTempWOFieldMatchingRules[lstTempWOFieldMatchingRules.size()-1].Id)
                {
                    lstTempWOFieldMatchingRules[j] = lstTempWOFieldMatchingRules[j];
                   // break;
                }
                else if(strFieldMatchRuleIdRearrange[i]==lstTempWOFieldMatchingRules[j].Id)
                {
                            temp = lstTempWOFieldMatchingRules[j]; 
                            lstTempWOFieldMatchingRules[j] = lstTempWOFieldMatchingRules[j+1];
                            lstTempWOFieldMatchingRules[j+1]=temp;                    
                            selIndex = j;
                            isUpAction = false;
                            isDownAction=true;
                            isTopAction=false;
                            isBottomAction=false;
                            lstTempWOFieldMatchingRules[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                            lstTempWOFieldMatchingRules[selIndex].SVMXC__Sequence__c = selIndex;
                }  
            }
        }
    }
    
    //------------------------------- Method to move Eligibility Rule to the top -----------------------
    public void Top() {
        
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=lstTempWOFieldMatchingRules.size()-1;j>0;j--)
        {
            for(integer i = strFieldMatchRuleIdRearrange.size()-1;i>=0;i--){
                if(strFieldMatchRuleIdRearrange[i] == lstTempWOFieldMatchingRules[j].Id)
                {
                    selIndex = j;
                    isUpAction = false;
                    isDownAction=false;
                    isTopAction=true;
                    isBottomAction=false;
                    shuffle(selIndex, true);                   
                }
            }
        } 
    }
    
    //------------------------------- Method to move Eligibility Rule to bottom -----------------------
    public void Bottom() {
        
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstTempWOFieldMatchingRules.size()-1;j++){
            for(integer i=0;i<strFieldMatchRuleIdRearrange.size();i++){
                if(strFieldMatchRuleIdRearrange[i] == lstTempWOFieldMatchingRules[j].Id){
                    selIndex = j;
                    isUpAction = false;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=true;                    
                    shuffle(selIndex, false); 
                }
            }
        }
    }
    
    public void shuffle(integer selIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop)
        {
            temp = lstTempWOFieldMatchingRules[selIndex];
            for(integer j=selIndex;j>0;j--)
            {
                lstTempWOFieldMatchingRules[j] = lstTempWOFieldMatchingRules[j-1];
            }
            lstTempWOFieldMatchingRules[0] = temp;
        }
        else 
        {
            temp = lstTempWOFieldMatchingRules[selIndex];
            for(integer j=selIndex;j<lstTempWOFieldMatchingRules.size()-1;j++)
            {
                lstTempWOFieldMatchingRules[j] = lstTempWOFieldMatchingRules[j+1];
            }
            lstTempWOFieldMatchingRules[lstTempWOFieldMatchingRules.size()-1] = temp;
        }
    }
    
    public string getHLPURL() {return system.label.COMM003_HLPURL;} 
    public string getTAG001(){return system.label.WORD020_TAG001;}//'In this screen, you can create rules that dictate how to find eligible technicians for a Work Order.'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} // 'Help'
    public string getTAG002() {return system.label.COMM001_TAG107;} // 'New Rule'
    public string getTAG003() {return system.label.COMM001_TAG108;}  // 'Edit Rule'
    public string getTAG004() {return system.label.COMM001_TAG109;}//'Delete Rule'
    public string getTAG005() {return  system.label.COMM001_TAG039;}  // 'Save '
    public string getTAG006() {return system.label.COMM001_TAG040;}  // 'Cancel'
    public string getTAG007() {return system.label.COMM001_TAG041;}  // 'Processing'
    public string getTAG008() {return system.label.COMM001_TAG044;}  // 'Select'
    public string getTAG009() {return system.label.COMM001_TAG115;}  // 'Rule Name'
    public string getTAG010() {return system.label.COMM001_TAG017;}  //'Description'
    public string getTAG011() {return system.label.COMM001_TAG016;} // 'Active'
    public string getTAG012() {return system.label.WORD020_TAG003;} // Work Order criteria for this Technician Eligibility Rule
    public string getTAG013() {return system.label.COMM001_TAG115;} 
    public string getTAG014() {return system.label.COMM001_TAG017;} 
    public string getTAG015() {return system.label.WORD020_TAG009;}//'Work Order Field / Value' 
    public string getTAG016() {return system.label.WORD020_TAG004;} //'Work Order Field'
    public string getTAG017() {return system.label.COMM002_TAG028;} //'Operator'
    public string getTAG018() {return system.label.COMM002_TAG029;} //'Value'
    public string getTAG019() {return system.label.COMM002_TAG024;} //'Advanced Expression'
    public String getTAG020() {return system.label.COMM002_TAG006;}//Equals
    public String getTAG021() {return system.label.COMM002_TAG007;}//Not Equal
    public String getTAG022() {return system.label.COMM002_TAG008;}//Greater Than
    public String getTAG023() {return system.label.COMM002_TAG009;}//Greater or Equal To
    public String getTAG024() {return system.label.COMM002_TAG010;}//Less Than
    public String getTAG025() {return system.label.COMM002_TAG011;}//Less or Equal To
    public String getTAG026() {return system.label.COMM002_TAG012;}//Starts With
    public String getTAG027() {return system.label.COMM002_TAG013;}//Contains
    public String getTAG028() {return system.label.COMM002_TAG014;}//Does Not Contain
    public String getTAG029() {return system.label.COMM002_TAG015;}//Includes
    public String getTAG030() {return system.label.COMM002_TAG016;}//Excludes
    public String getTAG031() {return system.label.COMM002_TAG022;}//Is Null
    public String getTAG032() {return system.label.COMM002_TAG023;}//Is Not Null
    public String getTAG033() {return system.label.WORD020_TAG005;}//Map the technician attributes that must be considered for this rule
    public String getTAG034() {return system.label.COMM002_TAG005;}//--None--
    public String getTAG035() {return system.label.COMM001_TAG036;}//'Add'
    public String getTAG036() {return system.label.COMM001_TAG049;}//'Delete'
    public String getTAG037() {return system.label.COMM001_TAG111;}//'Please select a Rule to perform this operation'
    public String getTAG038() {return system.label.COMM001_TAG112;}//'Please select only one Rule to perform this operation'
    public String getTAG039() {return system.label.COMM001_TAG113;}//'Please enter a valid rule name.'
    public String getTAG040() {return system.label.COMM002_TAG004;}//'Invalid Expression'
    public String getTAG041() {return system.label.COMM001_TAG113;}//'Please enter a valid rule name'
    public String getTAG042() {return system.label.COMM002_TAG004;}//Invalid Expression
    public String getTAG043() {return system.label.WORD020_TAG007;}//'Duplicate Technician Eligibility Rule'
    public String getTAG044() {return system.label.WORD020_TAG008;}//'Sequence of Technician Eligibility Rules'
    public String getTAG045() {return system.label.COMM001_TAG110;}//'Rule Sequence'
    public String getTAG046() {return system.label.COMM001_TAG046;}//Back To Setup Home
    public String getTAG047() {return system.label.WORD020_TAG006;}//'Technician'
    public String getTAG048() {return system.label.COMM001_TAG077;}//'An unexpected error occurred. Please contact your ServiceMax Administrator.'        
    public String getTAG049() {return system.label.COMM001_TAG057;} //'Are you sure?'
    public string getTAG050() {return system.label.COMM001_TAG041;}
    public string getTAG051() {return system.label.COMM001_TAG114;}//'Rule name should be at least 8 characters long'
    public string getTAG052() {return system.label.COMM002_TAG004;}//'Invalid Expression'
    
    //custom labels specific to Field Match Rules
    public string getTAG053() { return system.label.COMM003_TAG001; } //In this screen, you can create rules that match any fields of any two objects and apply the specified field map.
    public string getTAG054() { return system.label.COMM003_TAG002; } //Select the objects to be matched
    public string getTAG055() { return system.label.COMM003_TAG003; } //Target Object
    public string getTAG056() { return system.label.COMM003_TAG004; } //Matched Object
    public string getTAG057() { return system.label.COMM003_TAG005; } //Sort Field in Matched Object
    public string getTAG058() { return system.label.COMM003_TAG006; } //Target object criteria for this object match rule
    public string getTAG059() { return system.label.COMM003_TAG007; } //Criteria to match Matched Object fields to Target Object fields
    public string getTAG060() { return system.label.COMM003_TAG008; } //I want to enter a specific value for this field
    public string getTAG061() { return system.label.COMM003_TAG009; } //Matched Object to Target Object Map
    public string getTAG062() { return system.label.COMM003_TAG010; } //Field Map
    public string getTAG063() { return system.label.COMM003_TAG011; } //Data Lookup Rules
    public string getTAG064() { return system.label.COMM003_TAG012; } //Setup Data Lookup Rules
    public string getTAG065() { return system.label.COMM003_TAG013; } //This feature enables your organization to define the matching criteria between the fields of any two objects and to configure the field map to be applied from the Matched record to the Target record. This is useful when you need to set one or more fields in a qualified Target Object record, to field values from a Matched Object record.
    public string getTAG066() { return system.label.COMM003_TAG014; } //I want to select a Target Object field from the list
    public string getTAG067() { return system.label.COMM003_TAG015; } //Field
    public string getTAG068() { return system.label.COMM003_TAG016; } //Please select both the Target Object and Matched Object to perform this operation
    public string getTAG069() { return system.label.COMM003_TAG017; } //Mandatory Section
    
    public class TargetSourceMatchConfigWrapper {
        
        public SVMXC__ServiceMax_Config_Data__c targetSourceMatchConfig = new SVMXC__ServiceMax_Config_Data__c();
        public SVMXC__ServiceMax_Config_Data__c gettargetSourceMatchConfig(){return this.targetSourceMatchConfig;}
        public void settargetSourceMatchConfig(SVMXC__ServiceMax_Config_Data__c proces){this.targetSourceMatchConfig = proces;}  
        
        public boolean IsRenderpicklist;
        public boolean getIsRenderpicklist(){return IsRenderpicklist;}
        public void setIsRenderpicklist(boolean i){this.IsRenderpicklist = i;}
        
        public Integer Sequence;
        public Integer getSequence(){return Sequence;}
        public void setSequence(Integer i){this.Sequence = i;}
        
        public List<selectoption> lstTargetObjField = new List<selectoption>();
        public List<selectoption> getlstTargetObjField() {return this.lstTargetObjField;}
        public void setlstTargetObjField(List<SelectOption> lstTargetObjField){this.lstTargetObjField = lstTargetObjField;}
        
        public List<selectoption> lstSourceObjField = new List<selectoption>();
        public List<selectoption> getlstSourceObjField() {return this.lstSourceObjField;}
        public void setlstSourceObjField(List<SelectOption> lstSourceObjField){this.lstSourceObjField = lstSourceObjField;}
        
        public TargetSourceMatchConfigWrapper()
        {
            IsRenderpicklist = false;
        }
        
        public TargetSourceMatchConfigWrapper(SVMXC__ServiceMax_Config_Data__c targetSourceMatchConfig, List<selectoption> lstTargetObjField, List<selectoption> lstSourceObjField, boolean isPicklist, Integer iSeq)
        {
            this.targetSourceMatchConfig = targetSourceMatchConfig;
            //lstWOforTechSel = lstObjFlds;   
            this.IsRenderpicklist = isPicklist;
            this.Sequence = iSeq;
            this.lstSourceObjField =  lstSourceObjField;
            this.lstTargetObjField = lstTargetObjField;
            //this.lstSourceObjField.add(new SelectOption('Default', 'Default')); 
        }
    }

}