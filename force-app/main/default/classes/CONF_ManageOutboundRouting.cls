public with sharing class CONF_ManageOutboundRouting 
{
    public SVMXC__ServiceMax_Processes__c outboundProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getoutboundProcess(){return this.outboundProcess;}
    public void setoutboundProcess(SVMXC__ServiceMax_Processes__c o){this.outboundProcess = o;}
    public List<SVMXC__ServiceMax_Processes__c> outboundProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getoutboundProcessLst(){return this.outboundProcessLst;}
    public void setoutboundProcessLst(List<SVMXC__ServiceMax_Processes__c> o){this.outboundProcessLst = o;}
    public List<SVMXC__Site__c> lstLocations = new List<SVMXC__Site__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> retrievedRuleDetailLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> ruleExpDetailLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getruleExpDetailLst(){return ruleExpDetailLst;}
    public void setruleExpDetailLst(List<SVMXC__ServiceMax_Config_Data__c> o){this.ruleExpDetailLst = o;}
    public Map<String,Schema.Displaytype> fieldNameToDisplayType = new Map<String,Schema.Displaytype>();
    public Map<String,Schema.SObjectType>  mapFieldApiObjName = new Map<String,Schema.SObjectType>();
    public Map<String,String>  mapFieldRelName = new Map<String,String>();
    
    APL_Utils APLUtilObj = new APL_Utils();
    
    //public string selectedDepot{get;set;}
    public string selectedHub{get;set;}
    public string ruleName{get;set;}
    public string ruleDesc{get;set;}
    public string ruleAdvExp{get;set;}
    public string delIndex{get;set;}
     public boolean hideNewEditDelBtn{get;set;}
    public string selectedCriteriaWOExp{get;set;}
    public boolean isActive{get;set;}
    public boolean renderWOExprBlock{get;set;}
    public boolean renderPOExprBlock{get;set;}
    //public boolean renderEditDelete{get;set;}
    public boolean renderRuleDetails{get;set;}
    public boolean renderAboveSection{get;set;}
    public boolean DisableEditLnkWOExp{get;set;}
    public boolean disabled{get;set;}
    public boolean disableHub{get;set;}
    public boolean isCreateNewWOExp;
    public boolean validate;
    public string recordId;
    public string retURL;
    public string retBtnTxt;
    public string mode;
    public Set<ID> lstLocId = new Set<ID>();
    
    /* public List<SelectOption> lstDepots = new List<SelectOption>();
    public List<SelectOption> getlstDepots() {return this.lstDepots;}
    public void setlstDepots(List<SelectOption> lst) {this.lstDepots = lst;} */
    
    public List<SelectOption> lstHubs = new List<SelectOption>();
    public List<SelectOption> getlstHubs() {return this.lstHubs;}
    public void setlstHubs(List<SelectOption> lst) {this.lstHubs = lst;}
    
    public List<SelectOption> OperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getOperatorSelectLst(){return OperatorSelectLst;}
    public List<selectoption> WOfldlist=new List<selectoption>();
    public List<selectoption> getWOfldlist() {return this.WOfldlist;}
    public List<selectoption> POfldlist=new List<selectoption>();
    public List<selectoption> getPOfldlist() {return this.POfldlist;}
    public List<selectoption> POLineFieldLst=new List<selectoption>();
    public List<selectoption> getPOLineFieldLst() {return this.POLineFieldLst;}
    
    
    public List<SelectOption> ObjectSelectLst = new List<SelectOption>();
    public List<SelectOption> getObjectSelectLst(){return ObjectSelectLst;}
    public void setObjectSelectLst(List<SelectOption> lst) {this.ObjectSelectLst = lst;}
    
    public List<SelectOption> lstCriteriaWOExp = new List<SelectOption>();
    public List<SelectOption> getlstCriteriaWOExp(){return this.lstCriteriaWOExp;} 
    public void setlstCriteriaWOExp(List<SelectOption> lstField){this.lstCriteriaWOExp = lstField;}
    
    RecordType ExpressionHeader_Rtype;
    RecordType ExpressionsDetail_Rtype;
    RecordType Outbound_Rtype;
    
    public Integer DetailSize = 0;
    public Integer WOExpDetailSize = 0;
    public Integer getWOExpDetailSize(){ return WOExpDetailSize;}
    public Integer ruleExpDetailLstSize = 0;
    public Integer getruleExpDetailLstSize(){ return ruleExpDetailLstSize;}
    
    public SFM_WrapperDef.SFM_Response_Expression responseExpWO = new SFM_WrapperDef.SFM_Response_Expression();
    
    public SFM_WrapperDef.SFM_Expression Exp = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExp(){return this.Exp;}
    public void setExp(SFM_WrapperDef.SFM_Expression Exp){this.Exp = Exp;}
    public SFM_WrapperDef.SFM_Expression ExpWO = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpWO(){return this.ExpWO;}
    public void setExpWO(SFM_WrapperDef.SFM_Expression sfmExp){this.ExpWO = sfmExp;}
    
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRecWOExp = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRecPOExp = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    
    public String savedExpressionResultId;
    public String getsavedExpressionResultId() { return savedExpressionResultId;}
    public void setsavedExpressionResultId(String val){this.savedExpressionResultId = val;}
    
    public transient Schema.DescribeSObjectResult objDesc;
    public transient Schema.DescribeSObjectResult objDesc1;
    
    public string ObjPOName;
    public string getObjPOName(){return ObjPOName;}
    public string ObjPOLineName;
    public string getObjPOLineName(){return ObjPOLineName;}
    
    //------------------------------------------------Constructor/OnLoad------------------------------------------------------------------
    public CONF_ManageOutboundRouting()
    {
        hideNewEditDelBtn = false;
        recordId = System.currentPageReference().getParameters().get('SVMX_RecordId');
        retURL = System.currentPageReference().getParameters().get('SVMX_RetURL');
        
        if(retURL == null || retURL.contains('CONF_SetupHome'))
            retBtnTxt = system.label.CONF026_TAG040;
        else
            retBtnTxt = system.label.CONF026_TAG038;
            
        system.debug('Loc Id: ' + recordId + 'Return URL: ' + retURL);
        
        objDesc = SVMXC__RMA_Shipment_Order__c.sObjectType.getDescribe();
        objDesc1 = SVMXC__RMA_Shipment_Line__c.sObjectType.getDescribe();
        
        setDefaultValues();
        retrieveRecordTypes();
        preparingPicklists();
        queryingData();
        
        if(recordId != null)
        {
            hideNewEditDelBtn = true;
            if(outboundProcessLst != null && outboundProcessLst.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c tempProcess : outboundProcessLst)
                {
                    if(tempProcess.SVMXC__Location__r.Id == recordId)
                    {
                        outboundProcess = tempProcess;
                        break;
                    }
                }
                renderAboveSection = false;
                system.debug('outboundProcess found is: ' + outboundProcess);
                if(outboundProcess != null && outboundProcess.SVMXC__Location__r.Id != null)
                {
                    mode = 'edit';
                    disableHub = true;
                    //renderAboveSection = false;
                    //selectedDepot = outboundProcess.Id;
                    renderRuleDetails = true;
                    if(outboundProcess.SVMXC__IsStandard__c == true)
                        disabled = true;
                    fillingProcessData(outboundProcess);
                    
                    retrievedRuleDetailLst.clear();
                    retrievedRuleDetailLst = [select id, SVMXC__Sequence__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c from SVMXC__ServiceMax_Config_Data__c where recordTypeId =: ExpressionsDetail_Rtype.Id and SVMXC__Expression_Rule__c =: outboundProcess.Id and SVMXC__Expression_Type__c = 'EXP_Named']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    ruleExpDetailLst.clear();
                    ruleExpDetailLst.addAll(retrievedRuleDetailLst);
                    Map_SequenceNumRecPOExp.clear();
                    for(SVMXC__ServiceMax_Config_Data__c confData : ruleExpDetailLst)
                        Map_SequenceNumRecPOExp.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                    
                    if(ruleExpDetailLst == null || ruleExpDetailLst.size() == 0)
                        ADDRowRuleDetailLst();
                    ruleExpDetailLstSize = ruleExpDetailLst.size();
                }
                else
                {
                    disableHub = true;
                    newRule();
                }
            }
            else
            {
                disableHub = true;
                newRule();
            }
        }
        //if(selectedDepot != getTAG026())
            //renderEditDelete = true;
    }
    
    public void queryingData()
    {
        outboundProcessLst.clear();
        outboundProcessLst = [select id, SVMXC__Name__c, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__Process__c, SVMXC__Rule_Type__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name,  SVMXC__Location__r.Id, SVMXC__Active__c, SVMXC__Node_Parent__c, LastModifiedDate, LastModifiedBy.Name, SVMXC__Submodule__c, SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Outbound Route Calculation' and SVMXC__Rule_Type__c ='Outbound Route Calculation' order by SVMXC__Location__r.Name]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('All OutBound Process:'+outboundProcessLst);
        /* lstDepots.clear();
        lstDepots.add(new SelectOption(getTAG026(),getTAG026())); */
        
        if(outboundProcessLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : outboundProcessLst)
            {
                //lstDepots.add(new SelectOption(pro.Id, pro.SVMXC__Location__r.Name));
                lstLocId.add(pro.SVMXC__Location__r.Id);
            }
        }
        
        lstLocations = [select Id, Name from SVMXC__Site__c where RecordType.Name ='Depot' order by Name];
        fillingLocPickList();
    }
        
    //-------------------------------- Method to set Default Values for different Variables ------------------------------------
    public void setDefaultValues()
    {
        //selectedDepot = getTAG026();
        //renderEditDelete = false;
        renderRuleDetails = false;
        DisableEditLnkWOExp = true;
        renderWOExprBlock = false;
        disabled = false;
        renderAboveSection = true;
        disableHub = true;
        isCreateNewWOExp = false;
        ObjPOName = objDesc.getName();
        ObjPOLineName = objDesc1.getName();
    }
    
    //---------------------------------------- Method to retrieve All the Record Types -----------------------------------------
    public void retrieveRecordTypes()
    {
        ExpressionHeader_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ExpressionsDetail_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Outbound_Rtype = [select Id from RecordType where Name='Outbound Route Calculation'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    
    //--- method for getting fields  -- without isFilter fields
    public List<SelectOption> getAllFields(string ObjName)
    {
        List<SelectOption> TempObjFields = new  List<SelectOption>();
        Map<String, Schema.SObjectType> allobjmap = new Map<String, Schema.SObjectType>();
        Map<String, Schema.SObjectField> LfieldsMap = new Map<String, Schema.SObjectField>(); 
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : allObjs.values())
        {
            allobjmap.put(s.getDescribe().getName(),s);
        }
        TempObjFields.add(new SelectOption(getTAG026(),getTAG026()));
        if(ObjName != null && ObjName.length() > 0 && ObjName != '--None--' && ObjName != 'SVMX.NONE')
        {
            Schema.DescribeSObjectResult objDesc = allobjmap.get(ObjName).getDescribe(); 
            LfieldsMap = objDesc.fields.getMap();
            for(String s : LfieldsMap.keyset())
            {
                if(LfieldsMap.get(s).getDescribe().isFilterable())
                {
                    TempObjFields.add(new SelectOption(LfieldsMap.get(s).getDescribe().getName(),LfieldsMap.get(s).getDescribe().getLabel()));
                }
            }
            TempObjFields = sortingSelectOption(TempObjFields);
        }
        return TempObjFields;
    }
    
    //------------------------------------- Method to sort the Options of the PickList --------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }
    
    
    //---------------------------------------- Method to prepare all the PickList -----------------------------------------
    public void preparingPicklists()
    {
        WOfldlist.clear();
        WOfldlist = getAllFields('SVMXC__Service_Order__c');

        POfldlist.clear();
        POfldlist = getAllFields('SVMXC__RMA_Shipment_Order__c');
        
        POLineFieldLst.clear();
        POLineFieldLst = getAllFields('SVMXC__RMA_Shipment_Line__c');
        
        OperatorSelectLst.clear();
        OperatorSelectLst.add(new SelectOption('SVMX.NONE', getTAG026()));
        OperatorSelectLst.add(new SelectOption('eq', getTAG027()));
        OperatorSelectLst.add(new SelectOption('ne', getTAG028()));
        OperatorSelectLst.add(new SelectOption('gt', getTAG029()));
        OperatorSelectLst.add(new SelectOption('ge', getTAG030()));
        OperatorSelectLst.add(new SelectOption('lt', getTAG031()));
        OperatorSelectLst.add(new SelectOption('le', getTAG032()));
        OperatorSelectLst.add(new SelectOption('starts', getTAG033()));
        OperatorSelectLst.add(new SelectOption('contains', getTAG034()));
        OperatorSelectLst.add(new SelectOption('notcontain', getTAG035()));
        OperatorSelectLst.add(new SelectOption('in', getTAG036()));
        OperatorSelectLst.add(new SelectOption('notin', getTAG037()));
        OperatorSelectLst.add(new SelectOption('isnull', getTAG038()));
        OperatorSelectLst.add(new SelectOption('isnotnull', getTAG039()));
        
        ObjectSelectLst.clear();
        ObjectSelectLst.add(new SelectOption(objDesc.getName(), objDesc.getLabel()));
        ObjectSelectLst.add(new SelectOption(objDesc1.getName(), objDesc1.getLabel()));
        
        buildingExpLists();
    }
    
    //------------------------------------------ Filling Process Data -----------------------------------------------------
    public void fillingProcessData(SVMXC__ServiceMax_Processes__c process)
    {
        ruleName = process.SVMXC__Name__c;
        ruleDesc = process.SVMXC__Description__c;
        isActive = process.SVMXC__Active__c;
        ruleAdvExp = process.SVMXC__Advance_Expression__c;
        selectedHub = process.SVMXC__Location__r.Id;
        
        if(outboundProcess.SVMXC__Node_Parent__c != null)
        {
            responseExpWO = retrieveExpDetails(outboundProcess.SVMXC__Node_Parent__c);
            if(responseExpWO.expressions.size() > 0)
            {
                ExpWO = responseExpWO.expressions[0];
                selectedCriteriaWOExp = ExpWO.namedExpression.Id;
                Map_SequenceNumRecWOExp.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpWO.expressionDetails)
                {
                    Map_SequenceNumRecWOExp.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
                DisableEditLnkWOExp = false;
            }
        }
    }
    
    public void fillingLocPickList()
    {
        lstHubs.clear();
        lstHubs.add(new SelectOption(getTAG026(),getTAG026()));
        
        if(lstLocations.size() > 0)
        {
            for(SVMXC__Site__c loc : lstLocations)
            {
                lstHubs.add(new SelectOption(loc.Id, loc.Name));
            }
        }
    }
        
    //------------------------------------------ Building Expressions List -----------------------------------------------------
    public void buildingExpLists()
    {
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__Service_Order__c');
        lstStringMap.add(stringMap1);
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
        
        lstCriteriaWOExp.clear();
        lstCriteriaWOExp.add(new SelectOption(getTAG026(), getTAG026()));
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            lstCriteriaWOExp.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
    }
    
    public void editRule()
    {
        mode = 'edit';
        //renderEditDelete = true;
        DisableEditLnkWOExp = true;
        renderWOExprBlock = false;
        renderRuleDetails = true;
        disableHub = true;
        lstLocations = [select Id, Name from SVMXC__Site__c where RecordType.Name ='Depot' order by Name];
        fillingLocPickList();
        integer count = 0;
        for(SVMXC__ServiceMax_Processes__c tempPro : outboundProcessLst)
        {
            if(tempPro.SVMXC__Select__c == true)
            {
                count++;
                outboundProcess = tempPro;
            }
        }
        if(count > 1 || count == 0)
        {
            //renderEditDelete = false;
            renderRuleDetails = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTag052()));
            return;
        }
        /* outboundProcess = [select id, SVMXC__Name__c, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__Process__c, SVMXC__Rule_Type__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Location__r.Id, SVMXC__Active__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where SVMXC__Select__c = true]; */
        
        if(outboundProcess != null)
        {
            system.debug('Test001'+outboundProcess+'::'+retrievedRuleDetailLst);
            retrievedRuleDetailLst.clear();
            retrievedRuleDetailLst = [select id, SVMXC__Sequence__c, SVMXC__Object_Name2__c, SVMXC__Object_Name__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c from SVMXC__ServiceMax_Config_Data__c where recordTypeId =: ExpressionsDetail_Rtype.Id and SVMXC__Expression_Rule__c =: outboundProcess.Id and SVMXC__Expression_Type__c = 'EXP_Named']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('Test001'+retrievedRuleDetailLst);
            ruleExpDetailLst.clear();
            ruleExpDetailLst.addAll(retrievedRuleDetailLst);
            system.debug('Test001'+ruleExpDetailLst);
            Map_SequenceNumRecPOExp.clear();
            for(SVMXC__ServiceMax_Config_Data__c confData : ruleExpDetailLst)
                Map_SequenceNumRecPOExp.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
            
            if(ruleExpDetailLst.size() == 0)
                ADDRowRuleDetailLst();
            ruleExpDetailLstSize = ruleExpDetailLst.size();
        }
        fillingProcessData(outboundProcess);
    }
    
    public void deleteRule()
    {
        integer count=0;
        for(SVMXC__ServiceMax_Processes__c tempPro : outboundProcessLst)
        {
            if(tempPro.SVMXC__Select__c == true)
            {
                count++;
                outboundProcess = tempPro;
            }
        }
        if(count > 1 || count == 0)
        {
            //renderEditDelete = false;
            renderRuleDetails = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTag052()));
            return;
        }
        if(outboundProcess.SVMXC__IsStandard__c == true)
        {
            renderRuleDetails = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTag054()));
            return;
        }
        /* outboundProcess = [select id, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Process__c, SVMXC__Rule_Type__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Location__r.Id, SVMXC__Active__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where Id =: selectedDepot]; */
        
        retrievedRuleDetailLst.clear();
        retrievedRuleDetailLst = [select id, SVMXC__Sequence__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c from SVMXC__ServiceMax_Config_Data__c where recordTypeId =: ExpressionsDetail_Rtype.Id and SVMXC__Expression_Rule__c =: outboundProcess.Id and SVMXC__Expression_Type__c = 'EXP_Named' AND SVMXC__Expression_Rule__c != null]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(retrievedRuleDetailLst != null && retrievedRuleDetailLst.size() > 0){
            //delete retrievedRuleDetailLst;
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                delete retrievedRuleDetailLst; //SDL-SVMX-DELETE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        retrievedRuleDetailLst.clear();
        
        if(outboundProcess != null)
        {
            //selectedDepot = getTAG026();
            //renderEditDelete = false;
            renderRuleDetails = false;
            //delete outboundProcess;
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                delete outboundProcess; //SDL-SVMX-DELETE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG045(),''));
        }
        
        queryingData();
    }
    
    public void newRule()
    {
        mode = 'new';
        if(outboundProcessLst.size() > 0)
            lstLocations = [select Id, Name from SVMXC__Site__c where RecordType.Name ='Depot' and Id NOT IN: lstLocId order by Name];
        else
            lstLocations = [select Id, Name from SVMXC__Site__c where RecordType.Name ='Depot' order by Name];
        
        fillingLocPickList();
        selectedHub = getTAG026();
        disableHub = false;
        if(recordId != null)
        {
            selectedHub = recordId;
            disableHub = true;
        }
        outboundProcess = new SVMXC__ServiceMax_Processes__c();
        retrievedRuleDetailLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        renderRuleDetails = true;
        ruleName = '';
        ruleDesc = '';
        ruleAdvExp = '';
        ruleExpDetailLst.clear();
        Map_SequenceNumRecPOExp.clear();
        ADDRowRuleDetailLst();
        ruleExpDetailLstSize = ruleExpDetailLst.size();
        selectedCriteriaWOExp = getTAG026();
        isActive = true;
        //selectedDepot = getTAG026();
        //renderEditDelete = false;
        DisableEditLnkWOExp = true;
        isCreateNewWOExp = false;
        renderWOExprBlock = false;
    }
    
    public void quickSave()
    {
        save();
        if(Validate != false)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG024(),''));
            //selectedDepot = outboundProcess.Id;
            //renderEditDelete = true;
            disableHub = true;
        }
    }
    
    /* public pageReference saveClose()
    {
        save();
        if(Validate != false)
        {
            if(retURL == null)
            {
                pageReference pageref1 = Page.CONF_SetupHome ;
                return pageref1;
            }
            else
            {
                PageReference pageref1 = new PageReference(retURL);
                pageref1.setredirect(true);
                return pageref1;
            }
        }
        return null;
    } */
    
    public PageReference cancel()
    {
        if(retURL == null)
        {
            //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
            String url='';
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url ='/apex/SVMXC__CONF_SetupHome';
            }
            pageReference pageref1 = new PageReference(url);
            return pageref1;
        }
        else
        {
            //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
            String url='';
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url =retURL;
            }
            PageReference pageref1 = new PageReference(url);
            pageref1.setredirect(true);
            return pageref1;
        }
    }
    
    public void cancelToProcess()
    {
        renderRuleDetails = false;
    }
    
    List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
    public void save()
    {
        validate = true;
        //Neeraj(Marcj-15th): Commented the code from here and shift it below, after insert process data.
        /* lstConfigdataToSave.clear();
        if(ruleExpDetailLst != null && ruleExpDetailLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c confdata : ruleExpDetailLst)
            {
                if(confdata.SVMXC__Field_Name__c != getTAG026() && confdata.SVMXC__Operator__c != 'SVMX.NONE')
                {
                    SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
                    configData1 = fillingConfigData(confdata);
                    lstConfigdataToSave.add(configData1);
                }
            }
        } */
        
        validation();
        if(Validate != false)
            saveExps();
        
        if(Validate != false)
        {
            buildingExpLists();
            if(isCreateNewWOExp == true)
                selectedCriteriaWOExp = ExpWO.namedExpression.Id;
            
            outboundProcess.SVMXC__Name__c = ruleName;
            outboundProcess.SVMXC__Description__c = ruleDesc;
            outboundProcess.SVMXC__Active__c = isActive;
            outboundProcess.SVMXC__Location__c = selectedHub;
            outboundProcess.SVMXC__Advance_Expression__c = ruleAdvExp;
            outboundProcess.recordTypeId =Outbound_Rtype.Id;
            outboundProcess.SVMXC__Rule_Type__c ='Outbound Route Calculation';
            if(selectedCriteriaWOExp != getTAG026())
                outboundProcess.SVMXC__Node_Parent__c = selectedCriteriaWOExp;
            else
                outboundProcess.SVMXC__Node_Parent__c = null;
            
            //upsert outboundProcess;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(outboundProcess, COMM_SecurityUtils.Access.Upsertable)){
                upsert outboundProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
            
            if(retrievedRuleDetailLst != null && retrievedRuleDetailLst.size() > 0){
                //delete retrievedRuleDetailLst;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete retrievedRuleDetailLst; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
            retrievedRuleDetailLst.clear();
            
            //Neeraj: Copied the above commented code.
            lstConfigdataToSave.clear();
            list<SVMXC__ServiceMax_Config_Data__c> LstConfigDataToDelete = new list<SVMXC__ServiceMax_Config_Data__c>();
            LstConfigDataToDelete = [select id, SVMXC__Sequence__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c from SVMXC__ServiceMax_Config_Data__c where recordTypeId =: ExpressionsDetail_Rtype.Id and SVMXC__Expression_Rule__c =: outboundProcess.Id and SVMXC__Expression_Type__c = 'EXP_Named']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(LstConfigDataToDelete != null && LstConfigDataToDelete.size() > 0){
                //delete LstConfigDataToDelete;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete LstConfigDataToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
                
            LstConfigDataToDelete.clear();
            if(ruleExpDetailLst != null && ruleExpDetailLst.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c confdata : ruleExpDetailLst)
                {
                    if(confdata.SVMXC__Field_Name__c != getTAG026() && confdata.SVMXC__Operator__c != 'SVMX.NONE')
                    {
                        SVMXC__ServiceMax_Config_Data__c configData1 = new SVMXC__ServiceMax_Config_Data__c();
                        configData1 = fillingConfigData(confdata);
                        lstConfigdataToSave.add(configData1);
                    }
                }
            }
            if(lstConfigdataToSave != null && lstConfigdataToSave.size() > 0){
                //upsert lstConfigdataToSave;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfigdataToSave, COMM_SecurityUtils.Access.Upsertable)){
                    upsert lstConfigdataToSave; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }   
            Map<String,String> mapObjName_RelationShipName = new Map<String,String>();
            mapObjName_RelationShipName.put('SVMXC__RMA_Shipment_Order__c', 'SVMXC__RMA_Shipment_Order__r');
            
            outboundProcess.SVMXC__Select__c = false;
            system.debug('List of data sent: ' + lstConfigdataToSave + ' and the size is: ' + lstConfigdataToSave.size());
            outboundProcess.SVMXC__Parent_Object_Criteria__c = APLUtilObj.BuildWhereClause_MasterDetailObjects('SVMXC__RMA_Shipment_Line__c', mapObjName_RelationShipName, ruleAdvExp, lstConfigdataToSave, fieldNameToDisplayType, mapFieldApiObjName, mapFieldRelName);
            system.debug('Parent Criteria Saved: ' + outboundProcess.SVMXC__Parent_Object_Criteria__c);
            update outboundProcess; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            mode = 'edit';
        }
        queryingData();
    }
    
    public SVMXC__ServiceMax_Config_Data__c fillingConfigData(SVMXC__ServiceMax_Config_Data__c confdata)
    {
        SVMXC__ServiceMax_Config_Data__c newConfigData = new SVMXC__ServiceMax_Config_Data__c();
        newConfigData.RecordTypeId = ExpressionsDetail_Rtype.Id;
        newConfigData.SVMXC__Sequence__c = confdata.SVMXC__Sequence__c;
        newConfigData.SVMXC__Object_Name2__c = confdata.SVMXC__Object_Name2__c;
        newConfigData.SVMXC__Field_Name__c = confdata.SVMXC__Field_Name__c;
        newConfigData.SVMXC__Operator__c = confdata.SVMXC__Operator__c;
        newConfigData.SVMXC__Operand__c = confdata.SVMXC__Operand__c;
        newConfigData.SVMXC__Expression_Rule__c = outboundProcess.Id;
        newConfigData.SVMXC__Expression_Type__c = 'EXP_Named';
        
        string ObjName = confdata.SVMXC__Object_Name2__c;
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        if(ObjName == 'SVMXC__RMA_Shipment_Order__c')
            objfieldMap = SVMXC__RMA_Shipment_Order__c.SObjectType.getDescribe().fields.getMap();
        else if(ObjName == 'SVMXC__RMA_Shipment_Line__c')
            objfieldMap = SVMXC__RMA_Shipment_Line__c.SObjectType.getDescribe().fields.getMap();
        
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.getName() == newConfigData.SVMXC__Field_Name__c)
            {
                newConfigData.SVMXC__Display_Type__c = f.getType().name();
                fieldNameToDisplayType.put(newConfigData.SVMXC__Field_Name__c, f.getType());
                if(f.getType().name().ToUpperCase() == 'REFERENCE') 
                {
                    mapFieldApiObjName.put(f.getName(),f.getReferenceTo()[0]);
                    mapFieldRelName.put(f.getName(),f.getRelationshipName());
                    newConfigData.SVMXC__Field_Relationship_Name__c = f.getRelationshipName();
                    List<Schema.sObjectType> schema1 = new List<Schema.sObjectType>();
                    schema1 = f.getReferenceTo();
                    newConfigData.SVMXC__Object_Name__c = string.valueOf(schema1[0]);
                    if(schema1[0] == Account.SObjectType)
                         newConfigData.SVMXC__FKey_Name_Field__c = 'Name';
                    else
                    {
                        Map<String,Schema.SObjectField> R = schema1[0].getDescribe().fields.getMap();
                        for(String fieldKey1 : R.keySet())
                        {
                            Schema.SObjectField fsObj1 = R.get(fieldKey1);
                            Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                            if(f1.isNameField())
                                newConfigData.SVMXC__FKey_Name_Field__c = f1.getName();
                        }
                    }
                }
            }
        }
        return newConfigData;
    }
    
    public void validation()
    {
        if(ruleName == null || ruleName == '')
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG043(),''));
        }
        if(selectedHub == null || selectedHub == getTAG026())
        {
            Validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG044(),''));
        }
        if(lstConfigdataToSave != null && lstConfigdataToSave.size() > 0)
        { 
            if(!(APLUtilObj.validateExpression_DiffObjects(ruleAdvExp, lstConfigdataToSave)))
            {
                Validate = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG047(),''));
            }
        }
        if( mode == 'new')
        {
            List<SVMXC__ServiceMax_Processes__c> processLst = [select id, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Process__c, SVMXC__Rule_Type__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name,  SVMXC__Location__r.Id, SVMXC__Active__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Outbound Route Calculation' and SVMXC__Rule_Type__c ='Outbound Route Calculation' and SVMXC__Name__c =: ruleName]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(processLst.size() > 0)
            {
                Validate = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG046(),''));
            }
        }
        else
        {
            List<SVMXC__ServiceMax_Processes__c> processLst = [select id, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Process__c, SVMXC__Rule_Type__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name,  SVMXC__Location__r.Id, SVMXC__Active__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Outbound Route Calculation' and SVMXC__Rule_Type__c ='Outbound Route Calculation' and SVMXC__Name__c =: ruleName and id !=: outboundProcess.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(processLst.size() > 0)
            {
                Validate = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG046(),''));
            }
        }
    }
    
    //------------------------------------------- Method To Save All the four Expressions ------------------------------------------- 
    public void saveExps()
    {
        if(ExpWO != null && ExpWO.namedExpression.SVMXC__IsStandard__c != true && (selectedCriteriaWOExp != getTAG026() || isCreateNewWOExp == true))
        {
            for(integer i=0; i < ExpWO.expressionDetails.size() ; i++)
                ExpWO.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
            ExpWO.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(ExpWO.expressionDetails);
            Exp = ExpWO;
            DetailSize = WOExpDetailSize;
            submitExp();
        }
    }
    
     //------------------------------------------------Method to save One Expression----------------------------------------------------------------------
    public void submitExp()
    {
        if(Exp.namedExpression != null && Exp.namedExpression.SVMXC__Name__c != null && (Exp.namedExpression.SVMXC__Name__c).length() > 0 &&  Exp.namedExpression.SVMXC__ProcessID__c != null && (Exp.namedExpression.SVMXC__ProcessID__c).length() > 0 )
        {
            SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
            try
            {
                Exp.namedExpression.SVMXC__SettingId__c = Exp.namedExpression.SVMXC__ProcessID__c;
                List<SVMXC__ServiceMax_Config_Data__c> ExpressionDetails2Save = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :Exp.expressionDetails)
                {
                    if( (expressiondtlRec.SVMXC__Operator__c == null || expressiondtlRec.SVMXC__Operator__c == 'SVMX.NONE') && (expressiondtlRec.SVMXC__Operand__c == null || expressiondtlRec.SVMXC__Operand__c == '') && expressiondtlRec.SVMXC__Field_Name__c == 'None' )
                        continue;
                    else
                        ExpressionDetails2Save.add(expressiondtlRec);
                }
                Exp.expressionDetails.clear();
                if(ExpressionDetails2Save.size()>0)
                    Exp.expressionDetails.addAll(ExpressionDetails2Save);
                DetailSize = Math.Round(Exp.expressionDetails.size());
                
                if(DetailSize >0)
                {
                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(Exp.namedExpression,Exp.expressionDetails);
                    List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                    LstSFM_Exp.add(oSFM_Exp);
                    SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                    SVMXC.SFM_saveExpression saveExp = new SVMXC.SFM_saveExpression();
                    Save_Response = saveExp.SFM_saveExpression(oRequest);
                    
                    if( Save_Response != null && Save_Response.success != null)
                    {
                        if(Boolean.valueOf(Save_Response.success))
                        {
                            if( Save_Response.resultIds != null && Save_Response.resultIds.size() > 0 )
                            {
                                savedExpressionResultId = Save_Response.resultIds[0];
                                setsavedExpressionResultId(Save_Response.resultIds[0]);
                            }
                        }
                        else
                        {
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + Save_Response.message ));
                            validate = false;
                        }
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG025()));
                        validate = false;
                    }
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG040()));
                    validate = false;
                }   
            }
            catch(Exception ex)
            {
                if( Save_Response != null && Save_Response.message != null && Save_Response.success == false )
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''+Save_Response.message + ': ' + ex.getmessage()));
                    validate = false;
                }
            }
        }
        else
        {
            if( Exp.namedExpression == null || Exp.namedExpression.SVMXC__Name__c == null || Exp.namedExpression.SVMXC__Name__c == '' || (Exp.namedExpression.SVMXC__Name__c).length() == 0 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG041()));
                validate = false;
            }
            if( Exp.namedExpression == null || Exp.namedExpression.SVMXC__ProcessID__c == null || Exp.namedExpression.SVMXC__ProcessID__c == '' || (Exp.namedExpression.SVMXC__ProcessID__c).length() == 0 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG042()));
                validate = false;
            }
        }
    }
    
    /* public void onChngDepot()
    {
        if(selectedDepot != getTAG026())
            //renderEditDelete = true;
        else
            //renderEditDelete = false;
        renderRuleDetails = false;
        
        if(selectedDepot != getTAG026())
            editRule();
    } */
    
    public void onChngObj()
    {
    }
    
    //----------------------------------------- Method to retrieve Expression Details ---------------------------------------------
    public SFM_WrapperDef.SFM_Response_Expression retrieveExpDetails(string expId)
    {
        SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
        SFM_WrapperDef.SFM_StringMap stringMap3 = new SFM_WrapperDef.SFM_StringMap('EXPRESSIONID',expId);
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(stringMap3);
        SFM_WrapperDef.SFM_Request request2 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        responseExp = namedExpLst.SFM_getNamedExpressionList(request2);
        
        return responseExp;
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Work Order --------------------------------
    public void onChngWOExp()
    {
        isCreateNewWOExp = false;
        renderWOExprBlock = false;
        if(selectedCriteriaWOExp != getTAG026())
        {
            DisableEditLnkWOExp = false;
            responseExpWO = retrieveExpDetails(selectedCriteriaWOExp);
            if(responseExpWO.expressions.size() > 0)
            {
                ExpWO = responseExpWO.expressions[0];
                WOExpDetailSize = ExpWO.expressionDetails.size();
                Map_SequenceNumRecWOExp.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : ExpWO.expressionDetails)
                {
                    Map_SequenceNumRecWOExp.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            DisableEditLnkWOExp = true;
    }
    
    //----------------------------------------- View/Edit of Work Order Criteria ---------------------------------------------
    public void EditCriteriaWOExp()
    {
        renderWOExprBlock = true;
    }
    
    //----------------------------------------- New of Work Order Criteria ---------------------------------------------
    public void NewCriteriaWOExp()
    {
        isCreateNewWOExp = true;
        selectedCriteriaWOExp = getTAG026();
        DisableEditLnkWOExp = true;
        renderWOExprBlock = true;
        ExpWO = new SFM_WrapperDef.SFM_Expression();
        ExpWO.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ExpressionHeader_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c');
        ExpWO.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(ExpWO.expressionDetails != null)
            WOExpDetailSize = ExpWO.expressionDetails.size();
        else
            WOExpDetailSize = 0;
        Exp = ExpWO;
        DetailSize = WOExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecWOExp.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecWOExp);
        HdrADDRow();
        WOExpDetailSize = DetailSize;
        Map_SequenceNumRecWOExp.clear();
        Map_SequenceNumRecWOExp.putAll(Map_SequenceNumRec);
    }
    
    //----------------------------------------- Delete Row in the Parent Pick ---------------------------------------------
    public PageReference HdrDeleteRowWOExp()
    {
        Exp = ExpWO;
        DetailSize = WOExpDetailSize;
        Map_SequenceNumRec.clear();
        Map_SequenceNumRec.putAll(Map_SequenceNumRecWOExp);
        HdrDeleteRow();
        Map_SequenceNumRecWOExp.clear();
        Map_SequenceNumRecWOExp.putAll(Map_SequenceNumRec);
        WOExpDetailSize = DetailSize;
        ExpWO = Exp;
        return null;
    }
    
     //----------------------------------------- Add Row in the Parent Pick ---------------------------------------------
    public PageReference HdrADDRowWOExp()
    {
        Exp = ExpWO;
        DetailSize = WOExpDetailSize;
        Map_SequenceNumRec.clear();
        if(Map_SequenceNumRecWOExp.size() > 0)
            Map_SequenceNumRec.putAll(Map_SequenceNumRecWOExp);
        HdrADDRow();
        WOExpDetailSize = DetailSize;
        Map_SequenceNumRecWOExp.clear();
        Map_SequenceNumRecWOExp.putAll(Map_SequenceNumRec);
        ExpWO = Exp;
        return null;
    }
    
    //--------------------------------------Methods to add row of Expression details-------------------------------------------------------
    public void HdrADDRow()
    {
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsDetail_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( Exp.expressionDetails.size() + 1 ) );
            Map_SequenceNumRec.put( Math.Round(Integer.valueOf( Exp.expressionDetails.size() + 1 )), NewExpDetailRec );
            Exp.expressionDetails.add( NewExpDetailRec );
            if(Exp.expressionDetails != null)
                DetailSize = Exp.expressionDetails.size();
            else
                DetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
     //--------------------------------------Methods to delete row of Expression details-------------------------------------------------------
    public void HdrDeleteRow()
    {
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < Exp.expressionDetails.size(); i++ )
            {
                if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(delIndex) )
                    TempMap_SequenceNumRec.put( i + 1 - SeqNumToSubtract, Exp.expressionDetails[i] );
                else if ( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(delIndex)) )  
                    SeqNumToSubtract = 1;
            }
            Map_SequenceNumRec.clear();
            if( TempMap_SequenceNumRec != null )
                Map_SequenceNumRec.putAll(TempMap_SequenceNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SequenceNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SequenceNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SequenceNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            Exp.expressionDetails.clear();
            Exp.expressionDetails.addAll(Temp_ExpDetailsLst);
            if(Exp.expressionDetails != null)
                DetailSize = Exp.expressionDetails.size();
            else
                DetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //-----------------------------------------------Method to validate string --------------------------------------------------------
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
    
    //--------------------------------------------- Method to display exceptions ------------------------------------------------------
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, ''));
    }
    
    //--------------------------------------Methods to add row of Source Update-------------------------------------------------------
    public void ADDRowRuleDetailLst()
    {
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = ExpressionsDetail_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( ruleExpDetailLst.size() + 1 ) );
            Map_SequenceNumRecPOExp.put( Math.Round(Integer.valueOf( ruleExpDetailLst.size() + 1 )), NewExpDetailRec );
            ruleExpDetailLst.add( NewExpDetailRec );
            ruleExpDetailLstSize = ruleExpDetailLst.size();
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //--------------------------------------Methods to delete row of Source Update-------------------------------------------------------
    public void DeleteRowRuleDetailLst()
    {
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRecPOExp = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            system.debug('List: ' + ruleExpDetailLst + ' delete Index: ' + delIndex + ' Map of Seq to Exp: ' + Map_SequenceNumRecPOExp);
            
            for( integer i=0; i < ruleExpDetailLst.size(); i++ )
            {
                if( Map_SequenceNumRecPOExp != null && Map_SequenceNumRecPOExp.get(i + 1) != null && (i + 1) != integer.valueOf(delIndex) )
                    TempMap_SequenceNumRecPOExp.put( i + 1 - SeqNumToSubtract, ruleExpDetailLst[i] );
                else if ( Map_SequenceNumRecPOExp != null && Map_SequenceNumRecPOExp.get(i + 1) != null && ( (i + 1) == integer.valueOf(delIndex)) )  
                    SeqNumToSubtract = 1;
            }
            
            system.debug('Temp Map of Seq to Exp: ' + TempMap_SequenceNumRecPOExp);
            
            Map_SequenceNumRecPOExp.clear();
            if( TempMap_SequenceNumRecPOExp != null )
                Map_SequenceNumRecPOExp.putAll(TempMap_SequenceNumRecPOExp);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SequenceNumRecPOExp.keyset())
            {
                SequenceCounter++;
                if( Map_SequenceNumRecPOExp.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SequenceNumRecPOExp.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            
            system.debug('Temp List of Exp: ' + Temp_ExpDetailsLst);
            
            ruleExpDetailLst.clear();
            ruleExpDetailLst.addAll(Temp_ExpDetailsLst);
            ruleExpDetailLstSize = ruleExpDetailLst.size();
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public String getTag001(){ return System.label.CONF026_TAG001;} // 'Configure Outbound Routing'
    public String getTag002(){ return System.label.CONF026_TAG002;} //'Save'
    public String getTag004(){ return System.label.CONF026_TAG004;} //'Cancel'
    public String getTag005(){ return System.label.CONF026_TAG007;} //'Depot'
    public String getTag006(){ return System.label.CONF026_TAG006;} //'Outbound-Route Calculation Rule details'
    public String getTag007(){ return System.label.CONF026_TAG003;} //'Object'
    public String getTag009(){ return System.label.CONF026_TAG008;} //'Rule Name'
    public String getTag010(){ return System.label.CONF026_TAG009;} //'Rule Description'
    public String getTag011(){ return System.label.CONF026_TAG010;} //'Active'
    public String getTag012(){ return System.label.CONF026_TAG011;} //'Using the expression-builder below, indicate how Work Order qualify for Outbound Route Calculation'
    public String getTag013(){ return System.label.CONF026_TAG012;} //'Field'
    public String getTag014(){ return System.label.CONF026_TAG013;} //'Operator'
    public String getTag015(){ return System.label.CONF026_TAG014;} //'Value'
    public String getTag016(){ return System.label.CONF026_TAG015;} //'Advanced Expression'
    public String getTag017(){ return System.label.CONF026_TAG016;} //'Using the expression-builder below, indicate how Supplier Returns (Reverse RMA) qualify for Outbound Route Calculation'
    public String getTag018(){ return System.label.CONF026_TAG017;} //'Processing...'
    public String getTag019(){ return System.label.CONF026_TAG018;} //'Select Criteria:'
    public String getTag020(){ return System.label.CONF026_TAG019;} //'View/Edit'
    public String getTag021(){ return System.label.CONF026_TAG020;} //'Create New Criteria'
    public String getTag022(){ return System.label.CONF026_TAG021;} //'Expression Name'
    public String getTag023(){ return System.label.CONF026_TAG022;} //'Expression ID'
    public String getTag024(){ return System.label.CONF026_TAG023;} //'Process Saved'
    public String getTAG025() {return System.label.CONF026_TAG005;}//'Internal error occured, please try later.'
    public String getTag026(){ return System.label.CONF026_TAG025;} //'--None--'
    public String getTAG027() {return system.label.COMM002_TAG006;}//'Equals'
    public String getTAG028() {return system.label.COMM002_TAG007;}//'Not Equal'
    public String getTAG029() {return system.label.COMM002_TAG008;}//'Greater Than'
    public String getTAG030() {return system.label.COMM002_TAG009;}//'Greater or Equal To'
    public String getTAG031() {return system.label.COMM002_TAG010;}//'Less Than'
    public String getTAG032() {return system.label.COMM002_TAG011;}//'Less or Equal To'
    public String getTAG033() {return system.label.COMM002_TAG012;}//'Starts With'
    public String getTAG034() {return system.label.COMM002_TAG013;}//'Contains'
    public String getTAG035() {return system.label.COMM002_TAG014;}//'Does Not Contain'
    public String getTAG036() {return system.label.COMM002_TAG015;}//'Includes'
    public String getTAG037() {return system.label.COMM002_TAG016;}//'Excludes'
    public String getTAG038() {return system.label.COMM002_TAG022;}//'Is Null'
    public String getTAG039() {return system.label.COMM002_TAG023;}//'Is Not Null'
    public String getTAG040() {return system.label.CONF026_TAG026;}//'Please add some criteria also.'
    public String getTAG041() {return system.label.CONF026_TAG027;}//'Please enter a valid Expression Name.'
    public String getTAG042() {return system.label.CONF026_TAG028;}//'Expression Id should be atleast 8 characters long.'
    public String getTAG043() {return system.label.CONF026_TAG029;}//'Rule Name can not be left empty.'
    public String getTAG044() {return system.label.CONF026_TAG030;}//'Please select a Hub.'
    public String getTAG045() {return system.label.CONF026_TAG031;}//'Process deleted successfully.'
    public String getTAG046() {return system.label.CONF026_TAG032;}//'Please enter unique rule name.'
    public String getTAG047() {return system.label.CONF026_TAG042;}//'Invalid Expression for the RMA to Qualify'  
    public String getTag048(){ return system.label.CONF026_TAG033;} //'New'
    public String getTag049(){ return system.label.CONF026_TAG034;} //'Delete'
    //public String getTag050(){ return system.label.CONF026_TAG035;} //'Last Modified Date'
    public String getTag050(){ return System.Label.CONF030_TAG013;} //'Last Modified By'
    public String getTag051(){ return system.label.CONF026_TAG036;} //'Select'
    public String getTag052(){ return system.label.CONF026_TAG037;} //'Please select only one process to perform this operation'
    public String getTag053(){ return retBtnTxt;} //'Back'
    //Neeraj(May-2nd-2012): I commented this tag because we are not supporting standard Outbound Routing Rules.
    //public String getTag054(){ return system.label.CONF026_TAG039;} //'Standard Process cannot be deleted'
    public String getTag054(){ return '';}
    public String getTag055(){ return system.label.CONF026_TAG041;} //Are you sure ?
    public String getTAG056() {return system.label.COMM002_TAG032;}//'Add Row'
    public String getTAG057() {return system.label.COMM002_TAG033;}//'Delete Row'
    public string getHLPURL() {return system.label.CONF026_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
}