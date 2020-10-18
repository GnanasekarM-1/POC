public with sharing class CONF_SetupSearchConfiguration
{
    //public string strSearchId = null;
     //Wrapper to hold list of objects 2000 and display it in the Dropdown on the VF page. It is added as part of defect 037558 fix
        public class ObjectListWrapper{
        public List<SelectOption> selectList=new List<SelectOption>();
        private final Integer SUB_LIST_SIZE=1000;
        
        //Returns total numbers of items.
        public Integer getSize(){
            return selectList.size();
        }
        //Add SelectOption.
        public void add(SelectOption so){
            selectList.add(so);
        }
        //Gets SelectOption at given index.
        public SelectOption get(Integer index){
            if(index>-1 && index<getSize()){
                return selectList.get(index);
            }else{
                return null;
            }    
        }
        public List<SelectOption> getSelectList(){
            return selectList;
        }
        //Gets Select Options for the given start and end index both are inclusive.
        public List<SelectOption> getSubList(Integer startIndex,Integer endIndex){
            List<SelectOption> subList=new List<SelectOption>();
            if(startIndex>-1 && startIndex<selectList.size()&& endIndex>-1 && endIndex<selectList.size()&&startIndex<=endIndex){
                for(Integer i=startIndex;i<=endIndex;i++){
                    subList.add(get(i));
                }
            }
            return subList;
        }
        //Gets Nth sub list by dividing the main list in sublists of SUB_LIST_SIZE(1000 elements).
        public List<SelectOption>getNthSubList(Integer index){
            Integer subListCount=(Integer)(selectList.size()/SUB_LIST_SIZE);
            if(Math.mod(selectList.size(),SUB_LIST_SIZE)>0) subListCount++;
            if(index>=0 && index<=subListCount){
                Integer startIndex=index*SUB_LIST_SIZE;
                Integer endIndex=index*SUB_LIST_SIZE+(SUB_LIST_SIZE-1);
                if(endIndex>=selectList.size())endIndex=selectList.size()-1;
                    return getSubList(startIndex,endIndex);
            }else{
                return new List<SelectOption>();
            }
        }
        //Gets sublist for given index.
        public List<SelectOption>get0(){
            return getNthSubList(0);
        }
        public List<SelectOption>get1(){
            return getNthSubList(1);
        }
    }
    public ObjectListWrapper listOfObjects{
        get{
            if(listOfObjects==null){
                  listOfObjects=new ObjectListWrapper();
                  for(Integer i=0;i<LstObjects.size();i++){
                        listOfObjects.add(LstObjects[i]);
                  }
            }
            return listOfObjects;
        }
        set;
    }
    public Boolean getIsSecondListHasItem(){
        Integer sizeOfList = listOfObjects.get1().size();
        if(sizeOfList > 0)
            return true;
        else
            return false;
    }
    public string strObjectName = null;
    public List<String> lstSearchobjIds = new List<String>();
    public string getstrObjectName(){return this.strObjectName;}
    public boolean IsFldSeq = false; 
    public boolean getIsFldSeq(){return this.IsFldSeq;}
    public boolean IsNewBtnDisabled = false; 
    public boolean getIsNewBtnDisabled(){return this.IsNewBtnDisabled;}
    public boolean IsRender = false; 
    public boolean getIsRender(){return this.IsRender;}
    public string strSVMXMode = null;
    public string strSVMXMode1 = null;
    public boolean getIsSeqEnabale()
    {
        if(WrapLstSearchObj != null && WrapLstSearchObj.size() > 1)
            return false;
        return true;
    }
    public boolean IsViewMode = false;
    public boolean getIsViewMode()
    {
        if(strSVMXMode == 'View')
            IsViewMode = true;
        return this.IsViewMode;
    }
    public boolean IsEditMode = false;
    public boolean getIsEditMode(){return this.IsEditMode;}
    public boolean IsObjDisable = true; 
    public boolean getIsObjDisable(){return IsObjDisable;}
    public boolean IsAddBtnEnabled = false; 
    public boolean getIsAddBtnEnabled(){return this.IsAddBtnEnabled;}
    public boolean IsEditBtnEnabled = true; 
    public boolean getIsEditBtnEnabled()
    {
        try
        {
            if(objSearchProcess.Id != null)
                IsEditBtnEnabled = false;
            else
                IsEditBtnEnabled = true;
        }
        catch(exception ex){IsEditBtnEnabled = false;}
        return IsEditBtnEnabled;
    }
    public boolean IsSaveBtnEnabled = true; 
    public boolean getIsSaveBtnEnabled(){return this.IsSaveBtnEnabled;}
    public boolean IsDelBtnEnabled = true; 
    public boolean getIsDelBtnEnabled()
    {
        try
        {
            if(WrapLstSearchObj.size() > 0)
                IsDelBtnEnabled = false;
            else
                IsDelBtnEnabled = true;
        }
        catch(exception ex){IsDelBtnEnabled = false;}
        return IsDelBtnEnabled;
    }
    public String selectedTab = 'generalinfo';
    public String getselectedTab(){return selectedTab;}
    public void setselectedTab(String seltab){this.selectedTab = seltab;}
    public pageReference gotoGeneralInfoTab()
    {
        selectedTab = 'generalinfo';
        return null;
    }
    public pageReference gotoManageSearchObjectsTab()
    {
        selectedTab = 'ManageSearchObjects';
        return null;
    }
    public string StrDelIndex { get; set; }
    public string strAdvancedExp { get; set; }
    public integer intIndex;
    //public integer IntVal;
    public integer getintIndex(){return this.intIndex;}
    public void setintIndex(integer index){this.intIndex = index;}
    public boolean isEnterprise;
    //public List<RecordType> ProcessRType = new List<RecordType>(); 
    //public List<RecordType> ConfigRType = new List<RecordType>(); 
    public String ConfigExpRTypeId = '';
    public String ProcessRTypeId = '';
    //public Map<String, Schema.SObjectType> allobjmap = new Map<String, Schema.SObjectType>();
    //public Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
    //public Map<String, Schema.SObjectField> LfieldsMap = new Map<String, Schema.SObjectField>(); 
    //public Map<String, Schema.SObjectField> fieldsMap = new Map<String, Schema.SObjectField>();
    //public Map<String, Schema.SObjectField> ObjNamefieldsMap = new Map<String, Schema.SObjectField>();
    public CONF_ManageActions ManageAction = new CONF_ManageActions();
    public List<SelectOption> LstObjects = new  List<SelectOption>();
    public List<SelectOption> getLstObjects(){return LstObjects;}
    public List<SelectOption> lstRelatedObj = new  List<SelectOption>();
    public List<SelectOption> getlstRelatedObj(){return lstRelatedObj;}
    public List<SelectOption> OperatorsSelectLst = new List<SelectOption>();
    public List<SelectOption> getOperatorsSelectLst(){ return OperatorsSelectLst;}
    public List<SVMXC__ServiceMax_Processes__c> lstSearchProcess = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> lstSearchObj = new List<SVMXC__ServiceMax_Processes__c>();
    public SVMXC__ServiceMax_Processes__c objSearchProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getobjSearchProcess(){return this.objSearchProcess;}
    public void setobjSearchProcess(SVMXC__ServiceMax_Processes__c ProcessObj){this.objSearchProcess = ProcessObj;}
    //public List<SVMXC__ServiceMax_Config_Data__c> lstConfigFlds;
    //public List<SVMXC__ServiceMax_Config_Data__c> lstConfigCritera = new List<SVMXC__ServiceMax_Config_Data__c>();
    //public List<SVMXC__ServiceMax_Config_Data__c> lstConfigSearchFlds;
    //public List<SVMXC__ServiceMax_Config_Data__c> lstConfigFltrflds;
    public List<ProcessDataWrapper> WrapLstSearchObj = new List<ProcessDataWrapper>();
    public List<ProcessDataWrapper> getWrapLstSearchObj(){ return this.WrapLstSearchObj;}
    public void setWrapLstSearchObj(List<ProcessDataWrapper> value){ this.WrapLstSearchObj = value; }
    public List<ConfigDataWrapper> WrapLstResultFields = new List<ConfigDataWrapper>();
    public List<ConfigDataWrapper> getWrapLstResultFields(){ return this.WrapLstResultFields;}
    public void setWrapLstResultFields(List<ConfigDataWrapper> value){ this.WrapLstResultFields = value; }
    public List<ConfigDataWrapper> WrapLstFilterFields = new List<ConfigDataWrapper>();
    public List<ConfigDataWrapper> getWrapLstFilterFields(){ return this.WrapLstFilterFields;}
    public void setWrapLstFilterFields(List<ConfigDataWrapper> value){ this.WrapLstFilterFields = value; }
    public List<ConfigDataWrapper> WrapLstCri = new List<ConfigDataWrapper>();
    public List<ConfigDataWrapper> getWrapLstCri(){ return this.WrapLstCri;}
    public void setWrapLstCri(List<ConfigDataWrapper> value){ this.WrapLstCri = value; }
    //public map<Id, SVMXC__ServiceMax_Processes__c> IdProcessObjMap;
    public integer getSearchObjSize(){return WrapLstSearchObj.size();}
    public integer getRsltFldsSize(){return WrapLstResultFields.size();}
    public integer getFlteFldsSize(){return WrapLstFilterFields.size();}
    public integer getCritExpSize(){return WrapLstCri.size();}
    //public APL_Utils UtilObj = new APL_Utils();
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    
    // variables declared for order by fields
    public List<ConfigDataWrapper> WrapLstOrderFields = new List<ConfigDataWrapper>();
    public List<ConfigDataWrapper> getWrapLstOrderFields(){ return this.WrapLstOrderFields;}
    public void setWrapLstOrderFields(List<ConfigDataWrapper> value){ this.WrapLstOrderFields = value; }
    //public List<SVMXC__ServiceMax_Config_Data__c> lstConfigOrderflds;
    public integer getOrderFldsSize(){return WrapLstOrderFields.size();}
    public List<SelectOption> slctOptnOrderByField = new List<SelectOption>();
    public List<SelectOption> getSlctOptnOrderByField() {return slctOptnOrderByField;}
    public void setSlctOptnOrderByField(List<SelectOption> lstOptn){slctOptnOrderByField = lstOptn;}
    
    /*************** Constructor **********************/
    public CONF_SetupSearchConfiguration()
    {
        onLoad();
        
    //ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        List<RecordType> ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ProcessRTypeId = ProcessRType[0].id;
    //ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        List<RecordType> ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ConfigExpRTypeId = ConfigRType[0].id;
        if(ApexPages.currentPage().getParameters().get('SVMX_RecordID') != null)
        {
      //strSearchId = ApexPages.currentPage().getParameters().get('SVMX_RecordID');
            string strSearchId = ApexPages.currentPage().getParameters().get('SVMX_RecordID');
            strSVMXMode = System.currentPageReference().getParameters().get('SVMX_Mode');
            
            if(strSVMXMode != NULL && strSVMXMode.toUpperCase() == 'CLONE')
                strSVMXMode1 = 'CLONE';
                
            if(strSearchId != null && strSearchId.length() > 0)
            {
                lstSearchProcess = [select SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Sequence__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Named Search' and id =: strSearchId AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstSearchProcess != null && lstSearchProcess.size() > 0)
                {
                    objSearchProcess = lstSearchProcess[0];
                    lstSearchObj = [select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Target_Object_Name__c, SVMXC__ProcessID__c,SVMXC__Advance_Expression__c, SVMXC__Name_Field__c, SVMXC__Module__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Module__c =: lstSearchProcess[0].Id AND RecordTypeId =: ProcessRTypeId AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    /* IdProcessObjMap = new  map<Id, SVMXC__ServiceMax_Processes__c>();
                    for(SVMXC__ServiceMax_Processes__c tempObj : lstSearchObj)
                    {
                        IdProcessObjMap.put(tempObj.Id, tempObj);
                    } */
                    ProcessDataWrapper TempWrap;
                    if(lstSearchObj != null && lstSearchObj.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Processes__c tempProcess : lstSearchObj)
                        {
                            TempWrap = new ProcessDataWrapper();
                            TempWrap.objProcessData = tempProcess;
                            lstSearchobjIds.add(String.escapeSingleQuotes(String.valueOf(tempProcess.Id))); 
                            WrapLstSearchObj.add(TempWrap);
                        }
                    }
                }
            }
        }
    }
    Map<String,Boolean> permitdStdObjMap = new Map<String,Boolean>();
    public void onLoad()
    {
        isEnterprise = utils.SVMX_isEnterpriseLicense();
        if(!isEnterprise) permitdStdObjMap = utils.SVMX_getPermittedStandardObjectList();
        LstObjects.add(new SelectOption('SVMX.NONE',getTAG026()));
        Map<String,String> SFDCSVMXInternalObjectsMap = new Map<String,String>();
        SFDCSVMXInternalObjectsMap = utils.getSFDCSVMXInternalObjects();
        for(String s : SFDCSVMXInternalObjectsMap.keyset())
        {
            LstObjects.add(new SelectOption(s,SFDCSVMXInternalObjectsMap.get(s)));
        }    
        
        //---------added by Manish for Enabling Event, Task and Servicemax Events object in SFM search
        List<SVMXC__ServiceMax_Property_Elements__c> lstSFMSearchAllowedObject = [Select Name, SVMXC__Element_Type__c,SVMXC__Element_Value__c, SVMXC__Property_Key__c from SVMXC__ServiceMax_Property_Elements__c where SVMXC__Property_Key__c = 'SFM SEARCH ALLOWED' ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Property_Elements__c obj : lstSFMSearchAllowedObject)
            LstObjects.add(new SelectOption(obj.SVMXC__Element_Value__c, obj.SVMXC__Element_Type__c));
        //----------
        
        LstObjects = ManageAction.sortingSelectOption(LstObjects);
    /*
    Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        for(Schema.SObjectType s : allObjs.values())
        {
            Schema.DescribeSObjectResult objDesc = s.getDescribe();
            allobjmap.put(objDesc.getName(),s);
        }
    *///Comment by manish
        OperatorsSelectLst.clear();
        OperatorsSelectLst.add(new SelectOption('SVMX.NONE',getTAG026()));
        OperatorsSelectLst.add(new SelectOption('eq', getTAG027()));
        OperatorsSelectLst.add(new SelectOption('ne', getTAG028()));
        OperatorsSelectLst.add(new SelectOption('gt', getTAG029()));
        OperatorsSelectLst.add(new SelectOption('ge', getTAG030()));
        OperatorsSelectLst.add(new SelectOption('lt', getTAG031()));
        OperatorsSelectLst.add(new SelectOption('le', getTAG032()));
        OperatorsSelectLst.add(new SelectOption('starts', getTAG033()));
        OperatorsSelectLst.add(new SelectOption('contains', getTAG034()));
        OperatorsSelectLst.add(new SelectOption('notcontain', getTAG035()));
        OperatorsSelectLst.add(new SelectOption('in', getTAG036()));
        OperatorsSelectLst.add(new SelectOption('notin', getTAG037()));
        OperatorsSelectLst.add(new SelectOption('isnull', getTAG038()));
        OperatorsSelectLst.add(new SelectOption('isnotnull', getTAG039()));
        
        //  pick list for order by fields 
        slctOptnOrderByField.clear();
        Schema.DescribeFieldResult FildRslt = SVMXC__ServiceMax_Config_Data__c.SVMXC__Sort_Order__c.getDescribe();
        for(Schema.PicklistEntry pckLstEnty : FildRslt.getPicklistValues())
        {
            slctOptnOrderByField.add(new SelectOption(pckLstEnty.getValue(), pckLstEnty.getLabel()));
        }
    }
   
    /******************************* Querying the the lsit of Ref. objects based on the Selected Object*****************************/
    public string strObjPluralName = null;
    public string strObjNameFld = null;
    public pagereference SelectObjectAction()
    {
        strObjectName = null;
        if(IntIndex != 0)
            strObjectName = WrapLstSearchObj[integer.valueOf(IntIndex) - 1].objProcessData.SVMXC__Target_Object_Name__c;
        
        lstRelatedObj.clear();
        lstRelatedObj.add(new SelectOption('SVMX.NONE',getTAG026()));
        
        if(strObjectName != null && strObjectName != '--None--' && strObjectName != getTAG026() && strObjectName != 'SVMX.NONE')     
        {
            Objlst(strObjectName);      
            lstRelatedObj = ManageAction.sortingSelectOption(lstRelatedObj);
            WrapLstSearchObj[integer.valueOf(IntIndex) - 1].objProcessData.SVMXC__Name__c = strObjPluralName;
            WrapLstSearchObj[integer.valueOf(IntIndex) - 1].objProcessData.SVMXC__Name_Field__c = strObjNameFld;
            IsRender = true;
            IsSaveBtnEnabled = false;
            system.debug('List WrapLstCri:'+WrapLstCri +'List WrapLstResultFields:'+WrapLstResultFields +'List WrapLstFilterFields:'+WrapLstFilterFields);
            try
            {
                if(WrapLstCri == null || WrapLstCri.size() == 0)
                    AddSearchCri();
                if(WrapLstResultFields == null || WrapLstResultFields.size() == 0)
                {
                    List<SelectOption> TempObjFields = new  List<SelectOption>();
                    TempObjFields.add(new SelectOption('SVMX.NONE',getTAG026()));
                    TempObjFields = getAllFields(strObjectName);
                    WrapLstResultFields.add(new ConfigDataWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(1), SVMXC__Display_Value__c = 'Main Object',SVMXC__Object_Name2__c = strObjectName, SVMXC__Field_Name__c = strObjNameFld), TempObjFields));
                }
                if(WrapLstFilterFields == null || WrapLstFilterFields.size() == 0)
                {
                    List<SelectOption> TempObjFields = new  List<SelectOption>();
                    TempObjFields.add(new SelectOption('SVMX.NONE',getTAG026()));
                    TempObjFields = getFilterableObjFields(strObjectName);
                    WrapLstFilterFields.add(new ConfigDataWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(1), SVMXC__Display_Value__c = 'Main Object',SVMXC__Object_Name2__c = strObjectName, SVMXC__Field_Name__c = strObjNameFld), TempObjFields ));
                }
            }
            catch(exception ex){}
        }
        else
        {
            IsRender = false;
        }
        return null;
    }
    map<string, string> ObjName_NameFldMap = new map<string, string>();
    public void Objlst(string strObjectName)
    {    
        lstRelatedObj.clear();
        lstRelatedObj.add(new SelectOption('SVMX.NONE',getTAG026()));
    if(strObjectName != null && strObjectName != '--None--' && strObjectName != getTAG026() && strObjectName != 'SVMX.NONE')     
        {
      Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
      Map<String, Schema.SObjectType> allobjmap = new Map<String, Schema.SObjectType>();
      for(Schema.SObjectType s : allObjs.values())
      {
        Schema.DescribeSObjectResult objDesc = s.getDescribe();
        allobjmap.put(objDesc.getName(),s);  
      }
            Schema.DescribeSObjectResult objDesc = allobjmap.get(strObjectName).getDescribe(); 
            strObjPluralName = objDesc.getLabelPlural();
            system.debug('Plural Name: '+objDesc.getLabelPlural());
            lstRelatedObj.add(new SelectOption(strObjectName,allobjmap.get(strObjectName).getDescribe().getLabel()));
      //LfieldsMap = new Map<String, Schema.SObjectField>(); 
      Map<String, Schema.SObjectField> LfieldsMap = new Map<String, Schema.SObjectField>(); 
            LfieldsMap = objDesc.fields.getMap();
            Schema.DescribeFieldResult DesResult ;
            Boolean isNameFieldAdded = false;
            if(allobjmap.get(strObjectName) == Account.SObjectType)
            {
                if(!ObjName_NameFldMap.containsKey(strObjectName))
                    ObjName_NameFldMap.put(strObjectName,'Name');
                isNameFieldAdded = true;
            }
            for(String s : LfieldsMap.keyset())
            {
                String APIName = LfieldsMap.get(s).getDescribe().getName();
        //fieldsMap = new Map<String, Schema.SObjectField>();
        Map<String, Schema.SObjectField> fieldsMap = new Map<String, Schema.SObjectField>();
                fieldsMap.put(APIName,LfieldsMap.get(s));
                DesResult = fieldsMap.get(APIName).getDescribe();
                isNameFieldAdded = false;
                if(allobjmap.get(strObjectName) == Account.SObjectType)
                {
                    strObjNameFld = 'Name';
                    if(!ObjName_NameFldMap.containsKey(strObjectName))
                        ObjName_NameFldMap.put(strObjectName,'Name');
                    isNameFieldAdded = true;
                }
                if(!isNameFieldAdded && DesResult.isNameField())
                {
                    strObjNameFld = DesResult.getName();
                    if(!ObjName_NameFldMap.containsKey(strObjectName))
                        ObjName_NameFldMap.put(strObjectName,DesResult.getName());
                    isNameFieldAdded = true;
                }
                if(DesResult.getType() == Schema.DisplayType.REFERENCE ) 
                {   
                    if((!DesResult.isNamePointing()) || DesResult.getName().equals('OwnerId'))//added by Manish for skipping whoID and WhatId field
                    {
                        if(!DesResult.getName().equals('RecurrenceActivityId'))//added by Manish for skipping RecurrenceActivityId field
                        {
                            List <Schema.sObjectType> Ref = DesResult.getReferenceTo();
                            //if(Ref != NULL && Ref.size() > 0 && strObjectName != string.valueOf(Ref[0]))
                            if(Ref != NULL && Ref.size() > 0)
                            {
                                if(utils.SVMX_isObjectCustom(String.valueof(Ref[0])))
                                {
                                    string str = allobjmap.get(strObjectName).getDescribe().getLabel()+' ' + '-' +' ' +DesResult.getLabel();
                                    lstRelatedObj.add(new SelectOption(string.valueOf(Ref[0]+'~'+DesResult.getRelationshipName()),str));
                                }
                                else if(utils.SVMX_isObjectCustom(String.valueof(Ref[0])) == false)
                                {
                                    if((permitdStdObjMap.containsKey(String.valueof(Ref[0])) || isEnterprise))
                                    {
                                        string str = allobjmap.get(strObjectName).getDescribe().getLabel()+' ' + '-' +' ' +DesResult.getLabel();
                                        lstRelatedObj.add(new SelectOption(string.valueOf(Ref[0]+'~'+DesResult.getRelationshipName()),str));
                                    }
                                }
                            }
                        }
                    }
                }
            }           
            lstRelatedObj = ManageAction.sortingSelectOption(lstRelatedObj);
        }
    }
   
    public pagereference ObjectFields2()
    {
        if(IntIndex != 0)
        {
            if(WrapLstResultFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Object_Name2__c == strObjectName)
                WrapLstResultFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Display_Value__c = 'Main Object';
            else
                WrapLstResultFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Display_Value__c = 'Related Object';  
            string ObjName = WrapLstResultFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Object_Name2__c;
            if(ObjName.contains('~'))
                ObjName = ObjName.split('~')[0];
            if(ObjName != null && ObjName != '--None--' && ObjName != getTAG026() && ObjName != 'SVMX.NONE')
                WrapLstResultFields[integer.valueOf(IntIndex) - 1].ObjFlds = getAllFields(ObjName);
        }
        return null;
    }
    public pagereference ObjectFields3()
    {
        if(IntIndex != 0)
        {
            if(WrapLstFilterFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Object_Name2__c == strObjectName)
                WrapLstFilterFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Display_Value__c = 'Main Object';
            else
                WrapLstFilterFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Display_Value__c = 'Related Object';  
            string ObjName = WrapLstFilterFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Object_Name2__c;
            if(ObjName.contains('~'))
                ObjName = ObjName.split('~')[0];
            if(ObjName != null && ObjName != '--None--' && ObjName != getTAG026() && ObjName != 'SVMX.NONE')     
                WrapLstFilterFields[integer.valueOf(IntIndex) - 1].ObjFlds = getFilterableObjFields(ObjName);
        }
        return null;
    }
    
    public pagereference ObjectFields4()
    {
        if(IntIndex != 0)
        {
            if(WrapLstOrderFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Object_Name2__c == strObjectName)
                WrapLstOrderFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Display_Value__c = 'Main Object';
            else
                WrapLstOrderFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Display_Value__c = 'Related Object';  
            string ObjName = WrapLstOrderFields[integer.valueOf(IntIndex) - 1].objConfigData.SVMXC__Object_Name2__c;
            if(ObjName.contains('~'))
                ObjName = ObjName.split('~')[0];
            if(ObjName != null && ObjName != '--None--' && ObjName != getTAG026() && ObjName != 'SVMX.NONE')     
                WrapLstOrderFields[integer.valueOf(IntIndex) - 1].ObjFlds = getFilterableObjFields(ObjName);
        }
        return null;
    }
    
    
    //Method to retriev fields for result fields
    public List<SelectOption> getAllFields(string ObjName)
    {
        List<SelectOption> TempObjFields = new  List<SelectOption>();
        TempObjFields.add(new SelectOption('SVMX.NONE',getTAG026()));
        try
        {
            if(ObjName != null && ObjName.length() > 0 && ObjName != '--None--' && ObjName != 'SVMX.NONE')
            {
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectType> allobjmap = new Map<String, Schema.SObjectType>();
        for(Schema.SObjectType s : allObjs.values())
        {
          Schema.DescribeSObjectResult objDesc = s.getDescribe();
          allobjmap.put(objDesc.getName(),s);  
        }
                system.debug(LoggingLevel.WARN, 'Object Name: ' + allobjmap);
                Schema.DescribeSObjectResult objDesc = allobjmap.get(ObjName).getDescribe(); 
        //LfieldsMap = new Map<String, Schema.SObjectField>(); 
        Map<String, Schema.SObjectField> LfieldsMap = new Map<String, Schema.SObjectField>(); 
                LfieldsMap = objDesc.fields.getMap();
                Schema.DescribeFieldResult DesResult ;
                for(String s : LfieldsMap.keyset())
                {
                    String APIName = LfieldsMap.get(s).getDescribe().getName();
          //ObjNamefieldsMap = new Map<String, Schema.SObjectField>();
          Map<String, Schema.SObjectField> ObjNamefieldsMap = new Map<String, Schema.SObjectField>();
                    ObjNamefieldsMap.put(APIName,LfieldsMap.get(s));
                    DesResult = ObjNamefieldsMap.get(APIName).getDescribe();
                    boolean isNameFieldAdded = false;
                    if(allobjmap.get(strObjectName) == Account.SObjectType)
                    {
                        if(!ObjName_NameFldMap.containsKey(strObjectName))
                            ObjName_NameFldMap.put(strObjectName,'Name');
                        isNameFieldAdded = true;
                    }
                    if(!isNameFieldAdded && DesResult.isNameField())
                    {
                        if(!ObjName_NameFldMap.containsKey(ObjName))
                            ObjName_NameFldMap.put(ObjName,DesResult.getName());
                        isNameFieldAdded = true;
                    }
                    if(DesResult.getType() == Schema.DisplayType.REFERENCE ) 
                    {
                        if((!DesResult.isNamePointing()) || DesResult.getName().equals('OwnerId'))//added by Manish for skipping whoID and WhatId field
                        {
                            if(!DesResult.getName().equals('RecurrenceActivityId'))//added by Manish for skipping RecurrenceActivityId field
                            {
                                List <Schema.sObjectType> Ref = DesResult.getReferenceTo();
                                if(Ref != NULL && Ref.size() > 0 )
                                {
                                    if(utils.SVMX_isObjectCustom(String.valueof(Ref[0])))
                                    {
                                        TempObjFields.add(new SelectOption(APIName,LfieldsMap.get(s).getDescribe().getLabel()));
                                    }
                                    else if(utils.SVMX_isObjectCustom(String.valueof(Ref[0])) == false)
                                    {
                                        if((permitdStdObjMap.containsKey(String.valueof(Ref[0])) || isEnterprise))
                                            TempObjFields.add(new SelectOption(APIName,LfieldsMap.get(s).getDescribe().getLabel()));
                                    }
                                }
                            }
                        }
                    }
                    else{
                        if((ObjName.equals('SVMXC__SVMX_Event__c') && (APIName.equals('SVMXC__WhatId__c') || (APIName.equals('SVMXC__WhoId__c')))) == false)//added by Manish for skipping WhoId and WhatId field in servicemax event object.
                            TempObjFields.add(new SelectOption(APIName,LfieldsMap.get(s).getDescribe().getLabel()));
                    }
                }               
                TempObjFields = ManageAction.sortingSelectOption(TempObjFields);
            }
        }   
        catch(exception ex)     
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return TempObjFields;
    }
    
    //Method to retriev fields for search and pre filter fields
    public List<SelectOption> getFilterableObjFields(string ObjName)
    {    
        List<SelectOption> TempObjFields = new  List<SelectOption>();
        TempObjFields.add(new SelectOption('SVMX.NONE',getTAG026()));
        try
        {
            if(ObjName != null && ObjName.length() > 0 && ObjName != '--None--' && ObjName != 'SVMX.NONE')
            {
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectType> allobjmap = new Map<String, Schema.SObjectType>();
        for(Schema.SObjectType s : allObjs.values())
        {
          Schema.DescribeSObjectResult objDesc = s.getDescribe();
          allobjmap.put(objDesc.getName(),s);  
        }
                Schema.DescribeSObjectResult objDesc = allobjmap.get(ObjName).getDescribe(); 
        //LfieldsMap = new Map<String, Schema.SObjectField>(); 
        Map<String, Schema.SObjectField> LfieldsMap = new Map<String, Schema.SObjectField>(); 
                LfieldsMap = objDesc.fields.getMap();
                Schema.DescribeFieldResult DesResult ;
                for(String s : LfieldsMap.keyset())
                {
                    if(LfieldsMap.get(s).getDescribe().isFilterable())
                    {
                        String APIName = LfieldsMap.get(s).getDescribe().getName();
            //ObjNamefieldsMap = new Map<String, Schema.SObjectField>();
            Map<String, Schema.SObjectField> ObjNamefieldsMap = new Map<String, Schema.SObjectField>();
                        ObjNamefieldsMap.put(APIName,LfieldsMap.get(s));
                        DesResult = ObjNamefieldsMap.get(APIName).getDescribe();
                        boolean isNameFieldAdded = false;
                        if(allobjmap.get(strObjectName) == Account.SObjectType)
                        {
                            if(!ObjName_NameFldMap.containsKey(strObjectName))
                                ObjName_NameFldMap.put(strObjectName,'Name');
                            isNameFieldAdded = true;
                        }
                        if(!isNameFieldAdded && DesResult.isNameField())
                        {
                            if(!ObjName_NameFldMap.containsKey(ObjName))
                                ObjName_NameFldMap.put(ObjName,DesResult.getName());
                            isNameFieldAdded = true;
                        }
                        if(DesResult.getType() == Schema.DisplayType.REFERENCE ) 
                        {
                            if((!DesResult.isNamePointing()) || DesResult.getName().equals('OwnerId'))//added by Manish for skipping whoID and WhatId field
                            {
                                if(!DesResult.getName().equals('RecurrenceActivityId'))//added by Manish for skipping RecurrenceActivityId field
                                {
                                    List <Schema.sObjectType> Ref = DesResult.getReferenceTo();
                                    if(Ref != NULL && Ref.size() > 0 )
                                    {
                                        if(utils.SVMX_isObjectCustom(String.valueof(Ref[0])))
                                        {
                                            TempObjFields.add(new SelectOption(APIName,LfieldsMap.get(s).getDescribe().getLabel()));
                                        }
                                        else if(utils.SVMX_isObjectCustom(String.valueof(Ref[0])) == false)
                                        {
                                            if((permitdStdObjMap.containsKey(String.valueof(Ref[0])) || isEnterprise))
                                                TempObjFields.add(new SelectOption(APIName,LfieldsMap.get(s).getDescribe().getLabel()));
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            if((ObjName.equals('SVMXC__SVMX_Event__c') && (APIName.equals('SVMXC__WhatId__c') || (APIName.equals('SVMXC__WhoId__c')))) == false)//added by Manish for skipping WhoId and WhatId field in servicemax event object.
                                TempObjFields.add(new SelectOption(APIName,LfieldsMap.get(s).getDescribe().getLabel()));
                        }
                    }
                }        
                TempObjFields = ManageAction.sortingSelectOption(TempObjFields);
            }   
        }
        catch(exception ex)     
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return TempObjFields;
    }
    
    /************************** Edit method **********************/
    public void EditObjLst()
    {
        IsFldSeq = false;
        List<integer> selectindex = new List<integer>();
        for(integer i=0; i<WrapLstSearchObj.size(); i++)
        { 
            if(WrapLstSearchObj[i].objProcessData.SVMXC__Select__c == true)
                selectindex.add(i);
        }
        if(selectindex.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error, getTAG045()));
        }
        else if(selectindex.size() > 1)
        {
            for(integer i=0;i<WrapLstSearchObj.size();i++)
            { 
                if(WrapLstSearchObj[i].objProcessData.SVMXC__Select__c == true)
                    WrapLstSearchObj[i].objProcessData.SVMXC__Select__c = false;
            }        
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG050()) );
        }
        else if(WrapLstSearchObj[selectindex[0]].objProcessData.SVMXC__Target_Object_Name__c == null || WrapLstSearchObj[selectindex[0]].objProcessData.SVMXC__Target_Object_Name__c == 'SVMX.NONE' || WrapLstSearchObj[selectindex[0]].objProcessData.SVMXC__Target_Object_Name__c == '--NONE--')
        {
             ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG045()) );
        }
        else 
        {
            IsRender = true;
            IsAddBtnEnabled = true;
            strObjectName = null;
      //IntVal = selectindex[0];
            integer IntVal = selectindex[0];
            strAdvancedExp = WrapLstSearchObj[IntVal].objProcessData.SVMXC__Advance_Expression__c;
            if(WrapLstSearchObj[IntVal].objProcessData.SVMXC__Select__c == true && WrapLstSearchObj[IntVal].objProcessData.SVMXC__Target_Object_Name__c != null)
            {
                Objlst(WrapLstSearchObj[IntVal].objProcessData.SVMXC__Target_Object_Name__c);
                strObjectName = WrapLstSearchObj[IntVal].objProcessData.SVMXC__Target_Object_Name__c;
                WrapLstSearchObj[IntVal].objProcessData.SVMXC__Select__c = true;
            }
            /**************** Get the list of Criteria (Config List) **********************/
            boolean IsAddId = false;
            for(string strId : lstSearchobjIds)
            {
                if(strId == string.valueOf(WrapLstSearchObj[IntVal].objProcessData.Id))
                {
                    IsAddId = true;
                    break;
                }
            }
            if(!IsAddId)
                lstSearchobjIds.add(String.escapeSingleQuotes(String.valueOf(WrapLstSearchObj[IntVal].objProcessData.Id))); 
            //lstConfigCritera.clear();
      List<SVMXC__ServiceMax_Config_Data__c> lstConfigCritera = new List<SVMXC__ServiceMax_Config_Data__c>();
            string strsearchCrit = ''; 
            strsearchCrit = 'Select SVMXC__Display_Value__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Is_Name_Field__c,SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Operator__c,SVMXC__Expression_Type__c, SVMXC__Operand__c, SVMXC__Object_Name__c,SVMXC__Object_Name2__c,  SVMXC__Field_Name__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c IN: lstSearchobjIds AND RecordTypeId=\''+String.escapeSingleQuotes(ConfigExpRTypeId)+'\' AND SVMXC__Expression_Type__c = \'SRCH_Object_Prefilter_Criteria\'';
            strsearchCrit += ' ORDER By SVMXC__Sequence__c ';
            lstConfigCritera = Database.Query(strsearchCrit); 
            ConfigDataWrapper ConfigTempWrap;
            if(lstConfigCritera != null && lstConfigCritera.size() > 0)
            {
                if(WrapLstCri != null)
                    WrapLstCri.clear();
                for(SVMXC__ServiceMax_Config_Data__c tempConfigData : lstConfigCritera)
                {
                    if(tempConfigData.SVMXC__Expression_Rule__c == WrapLstSearchObj[IntVal].objProcessData.Id )
                    {
                        strAdvancedExp = WrapLstSearchObj[IntVal].objProcessData.SVMXC__Advance_Expression__c;
                        ConfigTempWrap = new ConfigDataWrapper();
                        ConfigTempWrap.objConfigData = tempConfigData;
                        ConfigTempWrap.ObjFlds = getFilterableObjFields(tempConfigData.SVMXC__Object_Name2__c);
                        WrapLstCri.add(ConfigTempWrap);
                    }
                }
            }
            
            /**************** Get the list of Fields to be Filtered and displayed (Config List) **************************/
      //lstConfigFlds = new List<SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigFlds = new List<SVMXC__ServiceMax_Config_Data__c>();
            //lstConfigSearchFlds = new List<SVMXC__ServiceMax_Config_Data__c>();
            //lstConfigFltrflds = new List<SVMXC__ServiceMax_Config_Data__c>();
            //lstConfigOrderflds =  new List<SVMXC__ServiceMax_Config_Data__c>();
            string strSearchFeilds = ''; 
            strSearchFeilds = 'Select SVMXC__Display_Value__c,SVMXC__Is_Name_Field__c,SVMXC__Lookup_Field_API_Name__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Operator__c,SVMXC__Expression_Type__c, SVMXC__Operand__c, SVMXC__Object_Name__c,SVMXC__Object_Name2__c,  SVMXC__Field_Name__c, SVMXC__Description__c, SVMXC__Sort_Order__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c IN: lstSearchobjIds and RecordTypeId=\''+String.escapeSingleQuotes(ConfigExpRTypeId)+'\' AND (SVMXC__Search_Object_Field_Type__c = \'Search\' OR SVMXC__Search_Object_Field_Type__c = \'Result\' OR SVMXC__Search_Object_Field_Type__c = \'OrderBy\') AND SVMXC__Expression_Type__c = \'SRCH_Object_Fields\'';
            strSearchFeilds += ' ORDER By SVMXC__Sequence__c ';
            lstConfigFlds = Database.Query(strSearchFeilds); 
            
            if(lstConfigFlds != null && lstConfigFlds.size() > 0)
            {
                if(WrapLstResultFields != null)
                    WrapLstResultFields.clear();
                if(WrapLstFilterFields != null)
                    WrapLstFilterFields.clear();
                if(WrapLstOrderFields != null)
                    WrapLstOrderFields.clear();
                for(SVMXC__ServiceMax_Config_Data__c tempConfigData : lstConfigFlds)
                {
                    if(tempConfigData.SVMXC__Expression_Rule__c == WrapLstSearchObj[IntVal].objProcessData.Id )
                    {
                        ConfigTempWrap = new ConfigDataWrapper();
                        ConfigTempWrap.objConfigData = tempConfigData;
                        string strObjectName = tempConfigData.SVMXC__Object_Name2__c;
                        system.debug(LoggingLevel.WARN, 'Object Name: ' + strObjectName);
                        
                        if(tempConfigData.SVMXC__Search_Object_Field_Type__c == 'Result')
                            ConfigTempWrap.ObjFlds = getAllFields(tempConfigData.SVMXC__Object_Name2__c);
                        else if(tempConfigData.SVMXC__Search_Object_Field_Type__c == 'Search' || tempConfigData.SVMXC__Search_Object_Field_Type__c == 'OrderBy' )
                            ConfigTempWrap.ObjFlds = getFilterableObjFields(tempConfigData.SVMXC__Object_Name2__c);
                        
                        if(tempConfigData.SVMXC__Lookup_Field_API_Name__c != null)
                            strObjectName = strObjectName+'~'+tempConfigData.SVMXC__Lookup_Field_API_Name__c;
                        
                        ConfigTempWrap.objConfigData.SVMXC__Object_Name2__c = strObjectName;
                        if(tempConfigData.SVMXC__Search_Object_Field_Type__c == 'Result')
                        {
                            WrapLstResultFields.add(ConfigTempWrap);
                            //lstConfigSearchFlds.add(tempConfigData);
                        }
                        else if(tempConfigData.SVMXC__Search_Object_Field_Type__c == 'Search')
                        {
                            WrapLstFilterFields.add(ConfigTempWrap);
                            //lstConfigFltrflds.add(tempConfigData);
                        }
                        else if(tempConfigData.SVMXC__Search_Object_Field_Type__c == 'OrderBy')
                        {
                            WrapLstOrderFields.add(ConfigTempWrap);
                            //lstConfigOrderflds.add(tempConfigData);
                        }
                    }
                }
            }
        }
    }
    
    /************************** cancel method **********************/
    public pageReference cancel()
    {
        PageReference pageref1= new PageReference('/apex/CONF_ManageSearchConfiguration');
        pageRef1.setRedirect(true);
        return pageref1;        
    }
    
    /************************** QuickSave method **********************/
    public boolean IsSaveCall = false;
    public pageReference Quicksave()
    {
        IsSaveCall = true;
        save();
        if(!IsSaveCall)
        {
            IsNewBtnDisabled = true;
            return null;
        }
        if(objSearchProcess.Id != null)
        {
            List<SVMXC__ServiceMax_Processes__c> tempSrchObjLst = new List<SVMXC__ServiceMax_Processes__c>();
            for(ProcessDataWrapper TempWrap: WrapLstSearchObj)
            {
                SVMXC__ServiceMax_Processes__c SearchObj = new SVMXC__ServiceMax_Processes__c();
                SearchObj = TempWrap.objProcessData;
                tempSrchObjLst.add(SearchObj);
            }

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)tempSrchObjLst, COMM_SecurityUtils.Access.Upsertable)){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
            }

            upsert tempSrchObjLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED

            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG051()));
        }
        IsNewBtnDisabled = false;
        //BAC-4012 : To support transalation for SFM Search
        if(objSearchProcess.Id != null)
        {
           CONF_ManageTranslations conf_manageTranslations = new CONF_ManageTranslations();
           conf_manageTranslations.generateMasterTag(objSearchProcess.Id);
        }
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG051()));
        PageReference pageref1= null;
        return pageref1;        
    }
    
    /************************** Save and Close method **********************/
    public pageReference SaveNClose()
    {
        PageReference pageref1 = null;
        IsSaveCall = true;
        save();
        if(!IsSaveCall)
        {
            IsNewBtnDisabled = true;
            return null;
        }
        if(objSearchProcess.Id != null)
        {
            List<SVMXC__ServiceMax_Processes__c> tempSrchObjLst = new List<SVMXC__ServiceMax_Processes__c>();
            for(ProcessDataWrapper TempWrap: WrapLstSearchObj)
            {
                SVMXC__ServiceMax_Processes__c SearchObj = new SVMXC__ServiceMax_Processes__c();
                SearchObj = TempWrap.objProcessData;
                tempSrchObjLst.add(SearchObj);
            }

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)tempSrchObjLst, COMM_SecurityUtils.Access.Upsertable)){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
            }

            upsert tempSrchObjLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        }
        if(IsSaveCall)
        {
            //BAC-4012 : To support transalation for SFM Search
            if(objSearchProcess.Id != null)
            {
               CONF_ManageTranslations conf_manageTranslations = new CONF_ManageTranslations();
               conf_manageTranslations.generateMasterTag(objSearchProcess.Id);
            }
            
            pageref1 = new PageReference('/apex/CONF_ManageSearchConfiguration');
            pageRef1.setRedirect(true);
        }
        return pageref1;        
    }
    
    /************************** Search Object cancel method **********************/
    public pageReference ObjCancel()
    {
        IsRender = false;
        IsEditMode = false;
        IsNewBtnDisabled = false;
        if(objSearchProcess.Id != null)
        {
            lstSearchObj = [select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Target_Object_Name__c, SVMXC__ProcessID__c, SVMXC__Module__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Name__C, SVMXC__Name_Field__c, SVMXC__Advance_Expression__c, SVMXC__Description__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Module__c =: objSearchProcess.Id AND RecordTypeId =: ProcessRTypeId AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(WrapLstSearchObj != null && WrapLstSearchObj.size() > 0)
                WrapLstSearchObj.clear();
            ProcessDataWrapper TempWrap;
            for(SVMXC__ServiceMax_Processes__c SearchObj: lstSearchObj)
            {
                TempWrap = new ProcessDataWrapper();
                TempWrap.objProcessData = SearchObj;
                WrapLstSearchObj.add(TempWrap);
            }
            IsAddBtnEnabled = false;
        }
        else
        {
            if(WrapLstSearchObj != null && WrapLstSearchObj.size() > 0)
            {
                for(ProcessDataWrapper TempWrap: WrapLstSearchObj)
                {
                    if(TempWrap.objProcessData.SVMXC__Select__c)
                        TempWrap.objProcessData.SVMXC__Target_Object_Name__c = getTag026();
                }
            }
            if(WrapLstCri != null && WrapLstCri.size() > 0)
                WrapLstCri.clear();
            if(WrapLstResultFields != null && WrapLstResultFields.size() > 0)
                WrapLstResultFields.clear();
            if(WrapLstFilterFields != null && WrapLstFilterFields.size() > 0)
                WrapLstFilterFields.clear();
        }
        
        return null;        
    }
    
    /************************** validation method **********************/
    //public boolean IsValidProcess;
    public string strwhereClause = null;
    public boolean IsValidate()
    {
    //IsValidProcess = true;
        boolean IsValidProcess = true;
        if(objSearchProcess.SVMXC__Name__c == null)
        {
            IsValidProcess=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG048()));
        }
        if(objSearchProcess.SVMXC__ProcessID__c == null)
        {
            IsValidProcess=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG049()));
        }
        /*********** validation for unique process ***********/
        List<SVMXC__ServiceMax_Processes__c> lstProcessRecs_UniquenessCheck = new List<SVMXC__ServiceMax_Processes__c>();
        String tempProcessId = objSearchProcess.SVMXC__ProcessID__c;
        lstProcessRecs_UniquenessCheck = [Select Id from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = :tempProcessId AND RecordTypeId =: ProcessRTypeId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstProcessRecs_UniquenessCheck != null && lstProcessRecs_UniquenessCheck.size() > 0)
        {
            if(strSVMXMode == 'Clone')
            {
                IsValidProcess = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG053()));
            }
            else if((objSearchProcess.get('Id') == null) || (lstProcessRecs_UniquenessCheck[0].Id  != objSearchProcess.get('Id')))
            {
                IsValidProcess = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG053()));
            }
        }
        string strSearchObjName = null;
        for(ProcessDataWrapper Wraptemp : WrapLstSearchObj)
        {
            if(Wraptemp.objProcessData.SVMXC__Select__c == true)
            {
                strSearchObjName = Wraptemp.objProcessData.SVMXC__Target_Object_Name__c;
                if(Wraptemp.objProcessData.SVMXC__Target_Object_Name__c == null || Wraptemp.objProcessData.SVMXC__Target_Object_Name__c == 'SVMX.NONE')
                {
                    IsValidProcess=false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG047()));
                }
                else if(Wraptemp.objProcessData.SVMXC__Name__C == null || Wraptemp.objProcessData.SVMXC__Name__C == '')
                {
                    IsValidProcess=false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG055()));
                }
            }
            if(Wraptemp.objProcessData.SVMXC__Name__C == null || Wraptemp.objProcessData.SVMXC__Name__C == '')
            {
                IsValidProcess=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG055()));
            }
        }
        List<SVMXC__ServiceMax_Config_Data__c> lstExpression = new List<SVMXC__ServiceMax_Config_Data__c>();
        for(ConfigDataWrapper TempCritField :WrapLstCri)
            if(TempCritField.objConfigData.SVMXC__Field_Name__c != null && TempCritField.objConfigData.SVMXC__Field_Name__c != 'SVMX.NONE' &&  TempCritField.objConfigData.SVMXC__Operator__c != null && TempCritField.objConfigData.SVMXC__Operator__c != 'SVMX.NONE')
                lstExpression.add(TempCritField.objConfigData);
        
        SVMXC__ServiceMax_Processes__c ProcessObj = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = strSearchObjName, SVMXC__Advance_Expression__c = strAdvancedExp);
        if(lstExpression != null && lstExpression.size() > 0 &&  strSearchObjName != null)
        {
            SFM_ValidateExpression validExpObj = new SFM_ValidateExpression();
            SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ProcessObj,lstExpression);
            List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
            LstSFM_Exp.add(oSFM_Exp);
            SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
            SFM_WrapperDef.SFM_Response Save_Response = validExpObj.SFM_validateExpression(oRequest);
            system.debug('Validation Response:'+Save_Response);
           
            if( Save_Response.success != null && Boolean.valueOf(Save_Response.success))
                strwhereClause = Save_Response.message;
            else
            {
                IsValidProcess=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG054()));
            }
            
        }
        return IsValidProcess;
    }
    

    /************************** Save method **********************/
    boolean IsClonedProcess = false;
    public pageReference save()
    {
        try
        {
            if(IsValidate())
            {
                if(lstdeleteRsltFields != null && lstdeleteRsltFields.size() > 0)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                        
                        delete lstdeleteRsltFields; //SDL-SVMX-DELETE-FLS-ENFORCED
                        lstdeleteRsltFields.clear();
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                }
                
                if(lstdeleteFilterFields != null && lstdeleteFilterFields.size() > 0)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                        
                        delete lstdeleteFilterFields; //SDL-SVMX-DELETE-FLS-ENFORCED
                        lstdeleteFilterFields.clear();
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                }
                // delete list of order by fields
                if(lstdeleteOrderFields != null && lstdeleteOrderFields.size() > 0)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                        
                        delete lstdeleteOrderFields; //SDL-SVMX-DELETE-FLS-ENFORCED
                        lstdeleteOrderFields.clear();
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                }
                if(lstdeleteCriExp != null && lstdeleteCriExp.size() > 0)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                        
                        delete lstdeleteCriExp; //SDL-SVMX-DELETE-FLS-ENFORCED
                        lstdeleteCriExp.clear();
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }                    
                }
                
                
                /******************* Code to save Search Process ********************************/
                string strSearchProcessId = null;
                string strSearchObjId = null;
                string strSearchObjName = null;
                objSearchProcess.RecordTypeId = ProcessRTypeId;
                objSearchProcess.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
                objSearchProcess.SVMXC__IsStandard__c = false;
                SVMXC__ServiceMax_Processes__c CloneProcess;
        APL_Utils UtilObj = new APL_Utils();
                if(strSVMXMode == 'Clone' && !IsClonedProcess)
                {
                    IsClonedProcess = true;
                    CloneProcess = new SVMXC__ServiceMax_Processes__c();
                    CloneProcess.RecordTypeId = ProcessRTypeId;
                    CloneProcess.SVMXC__IsStandard__c = false;
                    CloneProcess.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
                    CloneProcess.SVMXC__Description__c = objSearchProcess.SVMXC__Description__c;
                    CloneProcess.SVMXC__ProcessID__c = objSearchProcess.SVMXC__ProcessID__c;
                    CloneProcess.SVMXC__Name__C = objSearchProcess.SVMXC__Name__C;
                    
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(CloneProcess, COMM_SecurityUtils.Access.Createable)){
                        insert CloneProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }
                    strSearchProcessId = CloneProcess.Id;
                    objSearchProcess = CloneProcess;
                }
                else
                {
                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((sObject)objSearchProcess, COMM_SecurityUtils.Access.Upsertable)){
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    }

                    upsert objSearchProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    strSearchProcessId = objSearchProcess.Id;
                }
                
                if(WrapLstSearchObj != null && WrapLstSearchObj.size() > 0)
                {
                    SVMXC__ServiceMax_Processes__c CloneProcessObj;
                    for(integer i=0; i < WrapLstSearchObj.size();i++)
                    {
                        strSearchObjId = null;
                        if(WrapLstSearchObj[i].objProcessData.SVMXC__Select__c == true)
                        {
                            if(strSVMXMode == 'Clone')
                            {
                                CloneProcessObj = new SVMXC__ServiceMax_Processes__c();
                                CloneProcessObj.SVMXC__Module__c = strSearchProcessId;
                                CloneProcessObj.RecordTypeId = ProcessRTypeId;
                                CloneProcessObj.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
                                CloneProcessObj.SVMXC__Select__c = false;
                                CloneProcessObj.SVMXC__Target_Object_Name__c = WrapLstSearchObj[i].objProcessData.SVMXC__Target_Object_Name__c;
                                CloneProcessObj.SVMXC__Sequence__c = WrapLstSearchObj[i].objProcessData.SVMXC__Sequence__c;
                                CloneProcessObj.SVMXC__Name__C = WrapLstSearchObj[i].objProcessData.SVMXC__Name__C;
                                CloneProcessObj.SVMXC__Description__c = WrapLstSearchObj[i].objProcessData.SVMXC__Description__c;
                                CloneProcessObj.SVMXC__Name_Field__c = WrapLstSearchObj[i].objProcessData.SVMXC__Name_Field__c;
                                CloneProcessObj.SVMXC__Parent_Object_Criteria__c = WrapLstSearchObj[i].objProcessData.SVMXC__Parent_Object_Criteria__c;
                                CloneProcessObj.SVMXC__ProcessID__c = WrapLstSearchObj[i].objProcessData.SVMXC__ProcessID__c; //Added SVMXC__ProcessID__c field to support ServiceMax Translation.
                                
                                if(strwhereClause != NULL && strwhereClause.length() > 0 && strwhereClause.toUpperCase() != 'ERROR')
                                    CloneProcessObj.SVMXC__Parent_Object_Criteria__c = strwhereClause;
                                if(strAdvancedExp != NULL && strAdvancedExp.length() > 0)
                                    CloneProcessObj.SVMXC__Advance_Expression__c = strAdvancedExp;
                                
                                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(CloneProcessObj, COMM_SecurityUtils.Access.Createable)){
                                    insert CloneProcessObj; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                }
                                else{
                                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                                    return null;
                                }
                               
                                WrapLstSearchObj[i].objProcessData = CloneProcessObj;
                                strSearchObjId = CloneProcessObj.Id;
                                strSearchObjName = string.valueOf(CloneProcessObj.SVMXC__Target_Object_Name__c);
                            }
                            else if(strSVMXMode != 'Clone')
                            {
                                WrapLstSearchObj[i].objProcessData.SVMXC__Module__c = strSearchProcessId;
                                WrapLstSearchObj[i].objProcessData.RecordTypeId = ProcessRTypeId;
                                WrapLstSearchObj[i].objProcessData.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
                                WrapLstSearchObj[i].objProcessData.SVMXC__Select__c = false;
                                
                                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((sObject)WrapLstSearchObj[i].objProcessData, COMM_SecurityUtils.Access.Upsertable)){
                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                }

                                upsert WrapLstSearchObj[i].objProcessData;

                                strSearchObjId = WrapLstSearchObj[i].objProcessData.Id;
                                strSearchObjName = string.valueOf(WrapLstSearchObj[i].objProcessData.SVMXC__Target_Object_Name__c);
                            }
                            
                            system.debug('Searchable object: '+WrapLstSearchObj[i]);
                            
                            List<SVMXC__ServiceMax_Config_Data__c> lstRsltFields;
                            if(WrapLstResultFields != null && WrapLstResultFields.size() > 0)
                            {
                                lstRsltFields = new List<SVMXC__ServiceMax_Config_Data__c>();
                                //BAC-3979 : Indexing issue with --None-- field selection
                                Integer resultFieldSequence = 1;
                                for(ConfigDataWrapper TempRsltField :WrapLstResultFields)
                                {
                                    System.debug('TempRsltField ---'+TempRsltField);
                                    string strObjectName = TempRsltField.objConfigData.SVMXC__Object_Name2__c ;
                                    if(strObjectName.contains('~'))
                                    {
                                        TempRsltField.objConfigData.SVMXC__Lookup_Field_API_Name__c = strObjectName.split('~')[1];
                                        strObjectName = strObjectName.split('~')[0];
                                    }
                                    else
                                        TempRsltField.objConfigData.SVMXC__Lookup_Field_API_Name__c = null;
                                    TempRsltField.objConfigData.SVMXC__Object_Name2__c = strObjectName;
                                    if(ObjName_NameFldMap.containsKey(TempRsltField.objConfigData.SVMXC__Object_Name2__c) && (ObjName_NameFldMap.get(TempRsltField.objConfigData.SVMXC__Object_Name2__c) == TempRsltField.objConfigData.SVMXC__Field_Name__c))
                                    {
                                        TempRsltField.objConfigData.SVMXC__Is_Name_Field__c = true;
                                    }
                                    TempRsltField.objConfigData.SVMXC__Expression_Rule__c = strSearchObjId;
                                    TempRsltField.objConfigData.RecordTypeId = ConfigExpRTypeId;
                                    TempRsltField.objConfigData.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
                                    TempRsltField.objConfigData.SVMXC__Search_Object_Field_Type__c = 'Result';
                                    //Reset some fields
                                    TempRsltField.objConfigData.SVMXC__Object_Name__c = '';
                                    TempRsltField.objConfigData.SVMXC__Field_Relationship_Name__c = '';
                                    TempRsltField.objConfigData.SVMXC__FKey_Name_Field__c = '';
                                    if(TempRsltField.objConfigData.SVMXC__Object_Name2__c != null && TempRsltField.objConfigData.SVMXC__Object_Name2__c != 'SVMX.NONE' && TempRsltField.objConfigData.SVMXC__Field_Name__c != null && TempRsltField.objConfigData.SVMXC__Field_Name__c != 'SVMX.NONE'){
                                        TempRsltField.objConfigData.SVMXC__Sequence__c = resultFieldSequence;//BAC-3979 : Indexing issue with --None-- field selection
                                        lstRsltFields.add(TempRsltField.objConfigData);
                                        resultFieldSequence++;
                                    }
                                }
                                if(lstRsltFields != null && lstRsltFields.size() > 0 && strSVMXMode != 'Clone')
                                {   
                                    List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(lstRsltFields);
                                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Upsertable)){
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                    }
                                    upsert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                }
                                else if(lstRsltFields != null && lstRsltFields.size() > 0 && strSVMXMode == 'Clone')
                                {
                                    List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(lstRsltFields.deepClone(false,false,false));
                                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Createable)){
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                    }
                                    insert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                }
                            }
                            // Start saving config data about order by fields
                            List<SVMXC__ServiceMax_Config_Data__c> lstOrderFields;
                            if(WrapLstOrderFields != null && WrapLstOrderFields.size() > 0)
                            {
                                //BAC-3979 : Indexing issue with --None-- field selection
                                Integer orderFieldSequence = 1;
                                lstOrderFields = new List<SVMXC__ServiceMax_Config_Data__c>();
                                system.debug('WrapLstOrderFields'+WrapLstOrderFields);
                                for(ConfigDataWrapper TempSearchField :WrapLstOrderFields)
                                {
                                    TempSearchField.objConfigData.SVMXC__Expression_Rule__c = strSearchObjId;
                                    TempSearchField.objConfigData.RecordTypeId = ConfigExpRTypeId;
                                    TempSearchField.objConfigData.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
                                    TempSearchField.objConfigData.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
                                    string strObjectName = TempSearchField.objConfigData.SVMXC__Object_Name2__c ;
                                    //Reset some fields
                                    TempSearchField.objConfigData.SVMXC__Object_Name__c = '';
                                    TempSearchField.objConfigData.SVMXC__Field_Relationship_Name__c = '';
                                    TempSearchField.objConfigData.SVMXC__FKey_Name_Field__c = '';
                                    if(strObjectName.contains('~'))
                                    {
                                        TempSearchField.objConfigData.SVMXC__Lookup_Field_API_Name__c = strObjectName.split('~')[1];
                                        strObjectName = strObjectName.split('~')[0];
                                    }
                                    else
                                        TempSearchField.objConfigData.SVMXC__Lookup_Field_API_Name__c = null;
                                    TempSearchField.objConfigData.SVMXC__Object_Name2__c = strObjectName;
                                    if(TempSearchField.objConfigData.SVMXC__Object_Name2__c != null && TempSearchField.objConfigData.SVMXC__Object_Name2__c != 'SVMX.NONE' && TempSearchField.objConfigData.SVMXC__Field_Name__c != null && TempSearchField.objConfigData.SVMXC__Field_Name__c != 'SVMX.NONE'){
                                        TempSearchField.objConfigData.SVMXC__Sequence__c = orderFieldSequence; //BAC-3979 : Indexing issue with --None-- field selection
                                        lstOrderFields.add(TempSearchField.objConfigData);
                                        orderFieldSequence++;
                                    }
                                }
                                if(lstOrderFields != null && lstOrderFields.size() > 0 && strSVMXMode != 'Clone')
                                {
                                    List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(lstOrderFields);
                                    
                                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Upsertable)){
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                    }
                                    upsert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                }
                                else if(lstOrderFields != null && lstOrderFields.size() > 0 && strSVMXMode == 'Clone')
                                {
                                    List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(lstOrderFields.deepClone(false,false,false));
                                    
                                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Createable)){
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                    }
                                    insert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                }
                            }
                            // End saving config data about order by fields
                            
                            List<SVMXC__ServiceMax_Config_Data__c> lstFilterFields;
                            if(WrapLstFilterFields != null && WrapLstFilterFields.size() > 0)
                            {
                                //BAC-3979 : Indexing issue with --None-- field selection
                                Integer searchFieldSequence = 1;
                                lstFilterFields = new List<SVMXC__ServiceMax_Config_Data__c>();
                                system.debug('WrapLstFilterFields'+WrapLstFilterFields);
                                for(ConfigDataWrapper TempSearchField :WrapLstFilterFields)
                                {
                                    TempSearchField.objConfigData.SVMXC__Expression_Rule__c = strSearchObjId;
                                    TempSearchField.objConfigData.RecordTypeId = ConfigExpRTypeId;
                                    TempSearchField.objConfigData.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
                                    TempSearchField.objConfigData.SVMXC__Search_Object_Field_Type__c = 'Search';
                                    string strObjectName = TempSearchField.objConfigData.SVMXC__Object_Name2__c ;
                                    //Reset some fields
                                    TempSearchField.objConfigData.SVMXC__Object_Name__c = '';
                                    TempSearchField.objConfigData.SVMXC__Field_Relationship_Name__c = '';
                                    TempSearchField.objConfigData.SVMXC__FKey_Name_Field__c = '';
                                    if(strObjectName.contains('~'))
                                    {
                                        TempSearchField.objConfigData.SVMXC__Lookup_Field_API_Name__c = strObjectName.split('~')[1];
                                        strObjectName = strObjectName.split('~')[0];
                                    }
                                    else
                                        TempSearchField.objConfigData.SVMXC__Lookup_Field_API_Name__c = null;
                                    TempSearchField.objConfigData.SVMXC__Object_Name2__c = strObjectName;
                                    if(TempSearchField.objConfigData.SVMXC__Object_Name2__c != null && TempSearchField.objConfigData.SVMXC__Object_Name2__c != 'SVMX.NONE' && TempSearchField.objConfigData.SVMXC__Field_Name__c != null && TempSearchField.objConfigData.SVMXC__Field_Name__c != 'SVMX.NONE'){
                                        TempSearchField.objConfigData.SVMXC__Sequence__c = searchFieldSequence; //BAC-3979 : Indexing issue with --None-- field selection
                                        lstFilterFields.add(TempSearchField.objConfigData);
                                        searchFieldSequence++;
                                    }
                                }
                                if(lstFilterFields != null && lstFilterFields.size() > 0 && strSVMXMode != 'Clone')
                                {
                                    List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(lstFilterFields);
                                    
                                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Upsertable)){
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                    }
                                    upsert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                }
                                else if(lstFilterFields != null && lstFilterFields.size() > 0 && strSVMXMode == 'Clone')
                                {
                                    List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(lstFilterFields.deepClone(false,false,false));
                                    
                                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Createable)){
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                    }
                                    insert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                }
                            }
                            List<SVMXC__ServiceMax_Config_Data__c> lstSearchCrit;
                            if(WrapLstCri != null && WrapLstCri.size() > 0)
                            {
                                lstSearchCrit = new List<SVMXC__ServiceMax_Config_Data__c>();
                                for(ConfigDataWrapper TempCritField :WrapLstCri)
                                {
                                    TempCritField.objConfigData.SVMXC__Expression_Rule__c = strSearchObjId; 
                                    TempCritField.objConfigData.SVMXC__Object_Name2__c = strSearchObjName;
                                    TempCritField.objConfigData.RecordTypeId = ConfigExpRTypeId;
                                    TempCritField.objConfigData.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
                                    //Reset some fields
                                    TempCritField.objConfigData.SVMXC__Object_Name__c = '';
                                    TempCritField.objConfigData.SVMXC__Field_Relationship_Name__c = '';
                                    TempCritField.objConfigData.SVMXC__FKey_Name_Field__c = '';
                                    if(TempCritField.objConfigData.SVMXC__Field_Name__c != null && TempCritField.objConfigData.SVMXC__Field_Name__c != 'SVMX.NONE' &&  TempCritField.objConfigData.SVMXC__Operator__c != null && TempCritField.objConfigData.SVMXC__Operator__c != 'SVMX.NONE')
                                        lstSearchCrit.add(TempCritField.objConfigData);
                                } 
                                if(lstSearchCrit != null && lstSearchCrit.size() > 0 && strSVMXMode != 'Clone')
                                {
                                    lstSearchCrit = UtilObj.PopulateInfoForReferenceFields(lstSearchCrit);
                                    try
                                    {
                                        WrapLstSearchObj[i].objProcessData.SVMXC__Parent_Object_Criteria__c = '';
                                        WrapLstSearchObj[i].objProcessData.SVMXC__Advance_Expression__c = '';
                                        
                                        if(strwhereClause != NULL && strwhereClause.length() > 0 && strwhereClause.toUpperCase() != 'ERROR')
                                        {
                                            WrapLstSearchObj[i].objProcessData.SVMXC__Parent_Object_Criteria__c = strwhereClause;
                                            if(strAdvancedExp != NULL && strAdvancedExp.length() > 0)
                                                WrapLstSearchObj[i].objProcessData.SVMXC__Advance_Expression__c = strAdvancedExp;
                                        }
                                        else
                                        {
                                            WrapLstSearchObj[i].objProcessData.SVMXC__Parent_Object_Criteria__c = '';
                                            WrapLstSearchObj[i].objProcessData.SVMXC__Advance_Expression__c = '';
                                        }


                                        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((sObject)WrapLstSearchObj[i].objProcessData, COMM_SecurityUtils.Access.Upsertable)){
                                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                        }

                                        upsert WrapLstSearchObj[i].objProcessData;
                                    }
                                    catch(exception ex)     
                                    {
                                        system.debug('ERROR:'+ex.getMessage());
                                    }

                                    List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(lstSearchCrit);
                                    
                                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Upsertable)){
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                    }                                    
                                    upsert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                }
                                else if(lstSearchCrit != null && lstSearchCrit.size() > 0 && strSVMXMode == 'Clone')
                                {

                                    List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(lstSearchCrit.deepClone(false,false,false));
                                    
                                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Createable)){
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                    }   
                                    insert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                }
                            }
                            else
                            {
                                WrapLstSearchObj[i].objProcessData.SVMXC__Parent_Object_Criteria__c = '';
                                WrapLstSearchObj[i].objProcessData.SVMXC__Advance_Expression__c = '';

                                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((sObject)WrapLstSearchObj[i].objProcessData, COMM_SecurityUtils.Access.Upsertable)){
                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                }                                
                                upsert WrapLstSearchObj[i].objProcessData; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            }
                        }
                        else if(strSVMXMode == 'Clone')
                        {
                            List<SVMXC__ServiceMax_Config_Data__c> TemplstSearchCrit = new List<SVMXC__ServiceMax_Config_Data__c>();
                            List<SVMXC__ServiceMax_Config_Data__c> lstSearchCrit = new List<SVMXC__ServiceMax_Config_Data__c>();
                            TemplstSearchCrit = [Select SVMXC__Display_Value__c,SVMXC__Is_Name_Field__c,SVMXC__Lookup_Field_API_Name__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c,SVMXC__Select__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c,SVMXC__Expression_Type__c,SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: WrapLstSearchObj[i].objProcessData.Id AND RecordTypeId =: ConfigExpRTypeId AND SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria']; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            lstSearchCrit = TemplstSearchCrit.deepClone(false,false,false);
                            TemplstSearchCrit.clear();
                            
                            List<SVMXC__ServiceMax_Config_Data__c> TemplstSearchFlds = new List<SVMXC__ServiceMax_Config_Data__c>();
                            List<SVMXC__ServiceMax_Config_Data__c> lstSearchFlds = new List<SVMXC__ServiceMax_Config_Data__c>();
                            //Added SVMXC__Search_Object_Field_Type__c = 'OrderBy' in where condtion to fix the defect 043152 
                            TemplstSearchFlds = [Select SVMXC__Display_Value__c,SVMXC__Lookup_Field_API_Name__c,SVMXC__Search_Object_Field_Type__c,SVMXC__Expression_Rule__c, SVMXC__Sequence__c,SVMXC__Select__c,SVMXC__Is_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Object_Name__c,SVMXC__Object_Name2__c,SVMXC__Field_Name__c, SVMXC__Description__c,SVMXC__Active__c,RecordTypeId From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: WrapLstSearchObj[i].objProcessData.Id AND RecordTypeId =: ConfigExpRTypeId AND (SVMXC__Search_Object_Field_Type__c = 'Search' OR SVMXC__Search_Object_Field_Type__c = 'Result' OR SVMXC__Search_Object_Field_Type__c = 'OrderBy') AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields']; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            lstSearchFlds = TemplstSearchFlds.deepClone(false,false,false);
                            system.debug('Target Object Name:'+TemplstSearchFlds);
                            TemplstSearchFlds.clear();
                            
                            CloneProcessObj = new SVMXC__ServiceMax_Processes__c();
                            CloneProcessObj.SVMXC__Module__c = strSearchProcessId;
                            CloneProcessObj.RecordTypeId = ProcessRTypeId;
                            CloneProcessObj.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
                            CloneProcessObj.SVMXC__Select__c = false;
                            CloneProcessObj.SVMXC__Target_Object_Name__c = WrapLstSearchObj[i].objProcessData.SVMXC__Target_Object_Name__c;
                            CloneProcessObj.SVMXC__Sequence__c = WrapLstSearchObj[i].objProcessData.SVMXC__Sequence__c;
                            CloneProcessObj.SVMXC__Name__C = WrapLstSearchObj[i].objProcessData.SVMXC__Name__C;
                            CloneProcessObj.SVMXC__Description__c = WrapLstSearchObj[i].objProcessData.SVMXC__Description__c;
                            CloneProcessObj.SVMXC__Name_Field__c = WrapLstSearchObj[i].objProcessData.SVMXC__Name_Field__c;
                            CloneProcessObj.SVMXC__Parent_Object_Criteria__c = WrapLstSearchObj[i].objProcessData.SVMXC__Parent_Object_Criteria__c;
                            CloneProcessObj.SVMXC__Advance_Expression__c = WrapLstSearchObj[i].objProcessData.SVMXC__Advance_Expression__c;
                            CloneProcessObj.SVMXC__ProcessID__c = WrapLstSearchObj[i].objProcessData.SVMXC__ProcessID__c; //Added SVMXC__ProcessID__c field to support ServiceMax Translation. 
                            
                            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((sObject)CloneProcessObj, COMM_SecurityUtils.Access.Createable)){
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                            } 

                            insert CloneProcessObj; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            
                            WrapLstSearchObj[i].objProcessData = CloneProcessObj;
                            for(SVMXC__ServiceMax_Config_Data__c TempObj : lstSearchCrit)
                            {
                                TempObj.SVMXC__Expression_Rule__c = CloneProcessObj.Id;
                                TemplstSearchCrit.add(TempObj);
                            }
                            for(SVMXC__ServiceMax_Config_Data__c TempObj : lstSearchFlds)
                            {
                                TempObj.SVMXC__Expression_Rule__c = CloneProcessObj.Id;
                                TemplstSearchFlds.add(TempObj);
                            }
                            if(TemplstSearchCrit != null && TemplstSearchCrit.size() > 0)
                            {

                                List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(TemplstSearchCrit);
                                
                                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Createable)){
                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                }  
                                insert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            }
                            if(TemplstSearchFlds != null && TemplstSearchFlds.size() > 0)
                            {
                                List<SVMXC__ServiceMax_Config_Data__c> configRecordList = UtilObj.PopulateInfoForReferenceFields(TemplstSearchFlds);
                                
                                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess((List<sObject>)configRecordList, COMM_SecurityUtils.Access.Createable)){
                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                                }                                 
                                insert configRecordList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            }
                        }
                    }
                }
                IsEditMode = false;
                IsSaveCall = true;
                strSVMXMode = 'Edit';
                IsRender = false;
                IsAddBtnEnabled = false;
                IsEditBtnEnabled = false;
                IsNewBtnDisabled = false;
        /** Update Process Id field for Searchable Objects (in SFM Search) and Wizard Steps ( in SFM Wizards) to support translation.
        This will update only once if Process Id field is null or not updated, for Searchable Objects (SFM Search) and Wizard Steps (SFM Wizards). **/
        new I18N_TranslationDelivery().I18N_WizardStepsSearchObjsProcessIdUpdateRule();
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG051()));
            }
            else
            {
                IsSaveCall = false;
                IsNewBtnDisabled = true;
            }
        }
        catch(exception ex)     
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return null;
    }
    
    /************ Add and delete Method for Search Object *******************/
    public void AddSearchObj()
    {
        try
        {
            IsEditMode = true;
            strAdvancedExp = '';
            IsFldSeq = false;
            IsAddBtnEnabled = true;
            IsNewBtnDisabled = true;
            if(WrapLstResultFields != null && WrapLstResultFields.size() > 0)
            {
                WrapLstResultFields.clear();
            } 
            if(WrapLstCri != null && WrapLstCri.size() > 0)
            {
                WrapLstCri.clear();
            }
            if(WrapLstFilterFields != null && WrapLstFilterFields.size() > 0)
            {
                WrapLstFilterFields.clear();
            }
            if(WrapLstSearchObj != null && WrapLstSearchObj.size() > 0)
            {
                for(ProcessDataWrapper WrapObj : WrapLstSearchObj)
                    WrapObj.objProcessData.SVMXC__Select__c = false;
            }
            WrapLstSearchObj.add(new ProcessDataWrapper(new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c = Integer.valueOf(WrapLstSearchObj.size() + 1), SVMXC__Select__c = true), null));
        }
        catch(Exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));} 
    }
    
    
    public void DelSearchObj()
    {
        IsNewBtnDisabled = false;
        IsEditMode = false;
        List<integer> selectindex = new List<integer>();
        for(integer i=0; i<WrapLstSearchObj.size(); i++)
        { 
            if(WrapLstSearchObj[i].objProcessData.SVMXC__Select__c == true)
                selectindex.add(integer.ValueOf(WrapLstSearchObj[i].objProcessData.SVMXC__Sequence__c));
        }
        if(selectindex.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG045()));
        }
        else if(selectindex.size() > 1)
        {
            for(integer i=0;i<WrapLstSearchObj.size();i++)
            { 
                if(WrapLstSearchObj[i].objProcessData.SVMXC__Select__c == true)
                    WrapLstSearchObj[i].objProcessData.SVMXC__Select__c = false;
            }        
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG050()) );
        }
        else
        {
            try
            {
        //IntVal = selectindex[0];
                integer IntVal = selectindex[0];
                string strSearchObjId = null; 
                if(WrapLstSearchObj[IntVal - 1].objProcessData.Id != null && strSVMXMode1 != 'CLONE')
                {
                    string strCrit = ''; 
                    strSearchObjId = WrapLstSearchObj[IntVal - 1].objProcessData.Id;
                    
                    List<SVMXC__ServiceMax_Config_Data__c> lstdeleteCrit = new List<SVMXC__ServiceMax_Config_Data__c>();
                    strCrit = 'Select SVMXC__Display_Value__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Operator__c,SVMXC__Is_Name_Field__c, SVMXC__Operand__c,SVMXC__Object_Name__c, SVMXC__Object_Name2__c,  SVMXC__Field_Name__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: strSearchObjId and RecordTypeId=\''+String.escapeSingleQuotes(ConfigExpRTypeId)+'\' AND SVMXC__Expression_Type__c = \'SRCH_Object_Prefilter_Criteria\'';
                    lstdeleteCrit = Database.Query(strCrit); 
                    if(lstdeleteCrit != null && lstdeleteCrit.size() > 0)
                    {
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                            
                            delete lstdeleteCrit; //SDL-SVMX-DELETE-FLS-ENFORCED
                            lstdeleteCrit.clear();
                        } else {
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                            return;
                        }
                    }
          //lstConfigFlds = new List<SVMXC__ServiceMax_Config_Data__c>();
                    List<SVMXC__ServiceMax_Config_Data__c> lstConfigFlds = new List<SVMXC__ServiceMax_Config_Data__c>();
                    string strFields = ''; 
                    strFields = 'Select SVMXC__Display_Value__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Operator__c,SVMXC__Is_Name_Field__c, SVMXC__Operand__c,SVMXC__Object_Name__c, SVMXC__Object_Name2__c,  SVMXC__Field_Name__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: strSearchObjId and RecordTypeId=\''+ConfigExpRTypeId+'\' AND (SVMXC__Search_Object_Field_Type__c = \'Search\' OR SVMXC__Search_Object_Field_Type__c = \'Result\' OR SVMXC__Search_Object_Field_Type__c = \'OrderBy\') AND SVMXC__Expression_Type__c = \'SRCH_Object_Fields\'';
                    lstConfigFlds = Database.Query(strFields); 
                    if(lstConfigFlds != null && lstConfigFlds.size() > 0)
                    {
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                            
                            delete lstConfigFlds; //SDL-SVMX-DELETE-FLS-ENFORCED
                            lstConfigFlds.clear();
                        } else {
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                            return;
                        }
                    }
                    delete WrapLstSearchObj[IntVal - 1].objProcessData;
                    WrapLstSearchObj.remove(IntVal - 1);
                    List<SVMXC__ServiceMax_Processes__c> TempObjLst = new List<SVMXC__ServiceMax_Processes__c>();
                    for( integer i = IntVal; i <= WrapLstSearchObj.size(); i++ )
                    {
                        WrapLstSearchObj[i-1].objProcessData.SVMXC__Sequence__c = i;
                        TempObjLst.add(WrapLstSearchObj[i-1].objProcessData);
                    }
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempObjLst, COMM_SecurityUtils.Access.Updateable)){
                        update TempObjLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return;
                    }
                    
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG052()));
                }
                else
                {
                    WrapLstSearchObj.remove(IntVal - 1);
                    for( integer i = IntVal; i <= WrapLstSearchObj.size(); i++ )
                        WrapLstSearchObj[i-1].objProcessData.SVMXC__Sequence__c = i;
                }
                IsRender = false;
                IsAddBtnEnabled = false;
            }
            catch(Exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));} 
        }
    }
    
   
    /************ Add and delete Method for Result Fields  *******************/
    public void AddResultFields()
    {
        try
        {
            List<SelectOption> TempObjFields = new  List<SelectOption>();
            TempObjFields.add(new SelectOption('SVMX.NONE',getTAG026()));
            WrapLstResultFields.add(new ConfigDataWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(WrapLstResultFields.size() + 1)), TempObjFields ));
        }
        catch(Exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));} 
    }
    
    public List<SVMXC__ServiceMax_Config_Data__c> lstdeleteRsltFields = new List<SVMXC__ServiceMax_Config_Data__c>();
    public void DelResultFields()
    {
        if(StrDelIndex.length() > 0)
        {
      //IntVal = integer.valueOf(StrDelIndex);
            integer IntVal = integer.valueOf(StrDelIndex);
            if(WrapLstResultFields[IntVal - 1].objConfigData.Id != null)
                lstdeleteRsltFields.add(WrapLstResultFields[IntVal - 1].objConfigData);
            WrapLstResultFields.remove(IntVal - 1);
            for( integer i = IntVal; i <= WrapLstResultFields.size(); i++ )
                WrapLstResultFields[i-1].objConfigData.SVMXC__Sequence__c = i;
        }
    }
    
    /************ Add and delete Method for Filter Fields *******************/
    public void AddFilterFields()
    {
        try
        {
            List<SelectOption> TempObjFields = new  List<SelectOption>();
            TempObjFields.add(new SelectOption('SVMX.NONE',getTAG026()));
            WrapLstFilterFields.add(new ConfigDataWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(WrapLstFilterFields.size() + 1)), TempObjFields));
        }
        catch(Exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));} 
    }

    public List<SVMXC__ServiceMax_Config_Data__c> lstdeleteFilterFields = new List<SVMXC__ServiceMax_Config_Data__c>();
    public void DelFilterFields()
    {
        if(StrDelIndex.length() > 0)
        {
      //IntVal = integer.valueOf(StrDelIndex);
            integer IntVal = integer.valueOf(StrDelIndex);
            if(WrapLstFilterFields[IntVal - 1].objConfigData.Id != null)
                lstdeleteFilterFields.add(WrapLstFilterFields[IntVal - 1].objConfigData);
            WrapLstFilterFields.remove(IntVal - 1);
            for( integer i = IntVal; i <= WrapLstFilterFields.size(); i++ )
                WrapLstFilterFields[i-1].objConfigData.SVMXC__Sequence__c = i;
        }
    }
    
    /************ Add and delete Method for order Fields *******************/
    public void AddOrderFields()
    {
        try
        {
            List<SelectOption> TempObjFields = new  List<SelectOption>();
            TempObjFields.add(new SelectOption('SVMX.NONE',getTAG026()));
            WrapLstOrderFields.add(new ConfigDataWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(WrapLstOrderFields.size() + 1)), TempObjFields));
        }
        catch(Exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));} 
    }
    
    public List<SVMXC__ServiceMax_Config_Data__c> lstdeleteOrderFields = new List<SVMXC__ServiceMax_Config_Data__c>();
    public void DelOrderFields()
    {
        if(StrDelIndex.length() > 0)
        {
      //IntVal = integer.valueOf(StrDelIndex);
            integer IntVal = integer.valueOf(StrDelIndex);
            if(WrapLstOrderFields[IntVal - 1].objConfigData.Id != null)
                lstdeleteOrderFields.add(WrapLstOrderFields[IntVal - 1].objConfigData);
            WrapLstOrderFields.remove(IntVal - 1);
            for( integer i = IntVal; i <= WrapLstOrderFields.size(); i++ )
                WrapLstOrderFields[i-1].objConfigData.SVMXC__Sequence__c = i;
        }
    }
    
    /************ Add and delete Method for Search Cri *******************/
    public void AddSearchCri()
    {
        try
        {
            string strObjectName = null;
            for(ProcessDataWrapper tempObj: WrapLstSearchObj)
            {
                if(tempObj.objProcessData.SVMXC__Select__c)
                    strObjectName = tempObj.objProcessData.SVMXC__Target_Object_Name__c;
            }
            List<SelectOption> TempObjFields = new  List<SelectOption>();
            TempObjFields.add(new SelectOption('SVMX.NONE',getTAG026()));
            if(strObjectName != null)
                TempObjFields = getFilterableObjFields(strObjectName);
            WrapLstCri.add(new ConfigDataWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(WrapLstCri.size() + 1)), TempObjFields));
        }
        catch(Exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));} 
    }
    
    public List<SVMXC__ServiceMax_Config_Data__c> lstdeleteCriExp = new List<SVMXC__ServiceMax_Config_Data__c>();
    public void DelSearchCri()
    {
        if(StrDelIndex.length() > 0)
        {
      //IntVal = integer.valueOf(StrDelIndex);
            integer IntVal = integer.valueOf(StrDelIndex);
            if(WrapLstCri[IntVal - 1].objConfigData.Id != null)
                lstdeleteCriExp.add(WrapLstCri[IntVal - 1].objConfigData);
            WrapLstCri.remove(IntVal - 1);
            for( integer i = IntVal; i <= WrapLstCri.size(); i++ )
                WrapLstCri[i-1].objConfigData.SVMXC__Sequence__c = i;
        }
    }
    
    /********************** Wrapper For Search Object Process Data **********************************/
    public class ProcessDataWrapper
    {
        /********* All getter setter of wrapper class ***********/
        public SVMXC__ServiceMax_Processes__c objProcessData;
        public SVMXC__ServiceMax_Processes__c getobjProcessData(){return this.objProcessData;}
        public void setobjProcessData(SVMXC__ServiceMax_Processes__c obj){this.objProcessData = obj;}
        
        public List<SelectOption> LstAutoLaunch = new List<SelectOption>();
        public List<SelectOption> getLstAutoLaunch(){return LstAutoLaunch;}
        public void setLstAutoLaunch(List<SelectOption> SelOpt){this.LstAutoLaunch = SelOpt;}
        
        /*********** Constructor ******************/
        public ProcessDataWrapper() {}
        public ProcessDataWrapper(SVMXC__ServiceMax_Processes__c objProcessData, List<SelectOption> LstAutoLaunch )
        {
            this.objProcessData = objProcessData;
            this.LstAutoLaunch = LstAutoLaunch;
        }
    }
    
    /********************** Search Wrapper For Config Data **********************************/
    public class ConfigDataWrapper
    {
        /********* All getter setter of wrapper class ***********/
        public SVMXC__ServiceMax_Config_Data__c objConfigData;
        public SVMXC__ServiceMax_Config_Data__c getobjConfigData(){return this.objConfigData;}
        public void setobjConfigData(SVMXC__ServiceMax_Config_Data__c obj){this.objConfigData = obj;}
        
        public List<SelectOption> ObjFlds = new List<SelectOption>();
        public List<SelectOption> getObjFlds(){return ObjFlds;}
        public void setObjFlds(List<SelectOption> SelOpt){this.ObjFlds = SelOpt;}
        // select option of order by fields
        //public List<SelectOption> OrderFlds = new List<SelectOption>();
        //public List<SelectOption> getOrderFlds(){return OrderFlds;}
        //public void setOrderFlds(List<SelectOption> SelOpt){this.OrderFlds = SelOpt;}
        
        /*********** Constructor ******************/
        public ConfigDataWrapper() {}
        public ConfigDataWrapper(SVMXC__ServiceMax_Config_Data__c objConfigData, List<SelectOption> ObjFlds)
        {
            this.objConfigData = objConfigData;
            this.ObjFlds = ObjFlds;
            //if(ordrFild != null)
                //this.OrderFlds = ordrFild;
        }
    }
    
    
    /******************************************* Rule Sequence ********************************************************/
    public List<SVMXC__ServiceMax_Processes__c> lstSearchObjSeq = new List<SVMXC__ServiceMax_Processes__c>();
    //public List<SelectOption> ObjSeqoptions = new List<SelectOption>();
    //public List<SelectOption> DisplayFldsSeqoptions = new List<SelectOption>();
    //public Map<string,Integer> StrIntMap = new Map<string,Integer>();
    public string[] items = new String[]{};
    public string[] getitems(){return items;}
    public void setitems(string[] o){this.items=o;}
    public boolean displaySeqPopup = false;
    public boolean displaySeqPopup1 = false;
    public boolean getdisplaySeqPopup1(){return displaySeqPopup1;}
    //public integer IntSelIndex = 0;
    public boolean IsUpAction = false;
    public boolean IsDownAction = false;
    public boolean IsTopAction = false;
    public boolean IsBottomAction = false;
    public boolean getdisplaySeqPopup(){return displaySeqPopup;}
    
    
    /**************** Rule Sequence Method ************************/
    public void SVMX_RuleSequence()
    {
        //Jaysukh:Added below condition for BAC-3001
        if(strSVMXMode.equalsignorecase('Clone'))
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG058()));
        }
        else{
        lstSearchObjSeq.clear();
        //BAC-5347
        lstSearchObjSeq = [select SVMXC__Sequence__c,SVMXC__Select__c,SVMXC__Parent_Object_Criteria__c, SVMXC__Target_Object_Name__c, SVMXC__Module__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Name__C, SVMXC__Description__c,SVMXC__Advance_Expression__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Module__c =: objSearchProcess.id AND RecordTypeId =: ProcessRTypeId AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        displaySeqPopup1 = true;
        }    
    }   
    
    /**************** Method to display Rule list for sequence changes ************************/
    public List<SelectOption> getObjSeqoptions()
    {
        List<SelectOption> ObjSeqoptions = new List<SelectOption>();
    //ObjSeqoptions = new List<SelectOption>();
        if (lstSearchObjSeq.Size() >0)
        {
      //Jaysukh commented below code as part of story BAC-3381
     /* Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
      Map<String, Schema.SObjectType> allobjmap = new Map<String, Schema.SObjectType>();
      for(Schema.SObjectType s : allObjs.values())
      {
        Schema.DescribeSObjectResult objDesc = s.getDescribe();
        allobjmap.put(objDesc.getName(),s);  
      } */
            for(SVMXC__ServiceMax_Processes__c s : lstSearchObjSeq)
            {                
                if (s.SVMXC__Target_Object_Name__c != null && s.SVMXC__Name__c!=null)
                {
               // ObjSeqoptions.add(new SelectOption(s.Id, allobjmap.get(string.valueOf(s.SVMXC__Target_Object_Name__c)).getDescribe().getLabel()));
               //Jaysukh : Added below code BAC-3381
                  ObjSeqoptions.add(new SelectOption(s.id,string.valueOf(s.SVMXC__Name__c)));
                }   
              }
        }
        return ObjSeqoptions; 
    }
    
    /**************** shuffle Method ************************/
    public void shuffle(integer IntSelIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop)
        {
          temp = lstSearchObjSeq[IntSelIndex];
          for(integer j=IntSelIndex;j>0;j--)
          {
            lstSearchObjSeq[j] = lstSearchObjSeq[j-1];
          }
          lstSearchObjSeq[0] = temp;
        }
        else 
        {
          temp = lstSearchObjSeq[IntSelIndex];
          for(integer j=IntSelIndex;j<lstSearchObjSeq.size()-1;j++)
          {
            lstSearchObjSeq[j] = lstSearchObjSeq[j+1];
          }
          lstSearchObjSeq[lstSearchObjSeq.size()-1] = temp;
        }
    }  
    public void UP()
    { 
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstSearchObjSeq.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==lstSearchObjSeq[0].Id)
                {
                    lstSearchObjSeq[j] = lstSearchObjSeq[j];
                    break;
                }
                else if(items[i]==lstSearchObjSeq[j].Id)
                {
                    temp = lstSearchObjSeq[j]; 
                    lstSearchObjSeq[j] = lstSearchObjSeq[j-1];
                    lstSearchObjSeq[j-1]=temp;     
          //IntSelIndex = j;
                    integer IntSelIndex = j;
                    IsUpAction = true;
                    IsDownAction=false;
                    IsTopAction=false;
                    IsBottomAction=false;
                    lstSearchObjSeq[IntSelIndex-1].SVMXC__Sequence__c=IntSelIndex-1;
                    lstSearchObjSeq[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
                }
            }
        }
    }
    public void Down()
    {  
        SVMXC__ServiceMax_Processes__c temp;
        for(integer i=0;i<items.size();i++)
        {
          //StrIntMap.Put(items[i],i);
        }
        for(integer i=0;i<items.size();i++)
        {
            for(integer k=0;k<lstSearchObjSeq.size()-1;k++)
            {
                if(items[i]==lstSearchObjSeq[k].Id)
                {
                    temp = lstSearchObjSeq[k];
                    lstSearchObjSeq[k] = lstSearchObjSeq[k+1];
                    lstSearchObjSeq[k+1]=temp;
          //IntSelIndex = k;
                    integer IntSelIndex = k;
                    IsUpAction = false;
                    IsDownAction=true;
                    IsTopAction=false;
                    IsBottomAction=false;
                    lstSearchObjSeq[IntSelIndex+1].SVMXC__Sequence__c=IntSelIndex+1;
                    lstSearchObjSeq[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
                    break;       
                }
            }
        } 
    }
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=lstSearchObjSeq.size()-1;j>0;j--)
        {
            for(integer i=items.size()-1;i>=0;i--)
            {
                if(items[i] == lstSearchObjSeq[j].Id)
                {
          //IntSelIndex = j;
                    integer IntSelIndex = j;
                    IsUpAction = false;
                    IsDownAction=false;
                    IsTopAction=true;
                    IsBottomAction=false;
                    shuffle(IntSelIndex, true);     
                }
            }
        }  
    }
    public void Bottom()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstSearchObjSeq.size()-1;j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i] == lstSearchObjSeq[j].Id)
                {
          //IntSelIndex = j;
                    integer IntSelIndex = j;
                    IsUpAction = false;
                    IsDownAction=false;
                    IsTopAction=false;
                    IsBottomAction=true;     
                    shuffle(IntSelIndex, false); 
                }
            }
        }  
    }
    
    /**************** Method to save Rule Sequences************************/
    public pagereference SVMX_SaveSequence()
    {
        SVMXC__ServiceMax_Processes__c temp;
        double t;
        if(IsUpAction)
        {
            for(integer i=0;i<lstSearchObjSeq.size();i++)
            {
                lstSearchObjSeq[i].SVMXC__Sequence__c=i+1;
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSearchObjSeq, COMM_SecurityUtils.Access.Updateable)){
                update lstSearchObjSeq; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;
            }
        }
        else if(IsDownAction)
        {
            for(integer i=0;i<lstSearchObjSeq.size();i++)
            {
                lstSearchObjSeq[i].SVMXC__Sequence__c=i+1;
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSearchObjSeq, COMM_SecurityUtils.Access.Updateable)){
                update lstSearchObjSeq; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;
            }
        }
        else if(IsTopAction)
        {
            for(integer i=0;i<lstSearchObjSeq.size();i++)
            {
                lstSearchObjSeq[i].SVMXC__Sequence__c=i+1;
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSearchObjSeq, COMM_SecurityUtils.Access.Updateable)){
                update lstSearchObjSeq; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;  
            }
        }
        else if(IsBottomAction)
        {
            for(integer i=0;i<lstSearchObjSeq.size();i++)
            {
                lstSearchObjSeq[i].SVMXC__Sequence__c=i+1;
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSearchObjSeq, COMM_SecurityUtils.Access.Updateable)){
                update lstSearchObjSeq; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;  
            }
        }
        //BAC-5347 : Replaced lstSearchProcess[0].Id  with objSearchProcess.Id 
        lstSearchObjSeq = [select SVMXC__Select__c, SVMXC__Sequence__c, SVMXC__Target_Object_Name__c, SVMXC__ProcessID__c, SVMXC__Module__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Name__C, SVMXC__Parent_Object_Criteria__c, SVMXC__Advance_Expression__c, SVMXC__Description__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c  where SVMXC__Module__c =: objSearchProcess.id AND RecordTypeId =: ProcessRTypeId AND SVMXC__Rule_Type__c = 'SRCH_OBJECT' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        ProcessDataWrapper TempWrap;
        WrapLstSearchObj.clear();
        if(lstSearchObj != null && lstSearchObj.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c tempProcess : lstSearchObjSeq)
            {
                TempWrap = new ProcessDataWrapper();
                TempWrap.objProcessData = tempProcess;
                WrapLstSearchObj.add(TempWrap);
            }
        }
        displaySeqPopup1 = false;
        return null;  
    }
    
    
    /*****************************************************************************************************
                                Rule Sequence for config data
    *****************************************************************************************************/
    public List<SVMXC__ServiceMax_Config_Data__c> DisplayFldsSeqLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public string strFirstId = null;
    /**************** Rule Sequence Method ************************/
    string SearchobjId = null;
    public void DisplayFldsSequence()
    {
        IsFldSeq = true;
        list<integer> selectindex = new list<integer>(); 
        for(integer i=0; i<WrapLstSearchObj.size(); i++)
        { 
            if(WrapLstSearchObj[i].objProcessData.SVMXC__Select__c == true)
            {
                selectindex.add(i);
                SearchobjId = WrapLstSearchObj[i].objProcessData.id;
            }
        }
        if(selectindex.size() == 0)
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG047()));
        else if(selectindex.size() > 1)
        {
            for(integer i=0;i<WrapLstSearchObj.size();i++)
            { 
                if(WrapLstSearchObj[i].objProcessData.SVMXC__Select__c == true)
                    WrapLstSearchObj[i].objProcessData.SVMXC__Select__c = false;
            }        
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.Error,getTAG047()) );
        }
        else if(SearchobjId != null)
        {
            DisplayFldsSeqLst.clear();
            DisplayFldsSeqLst = [Select  SVMXC__Search_Object_Field_Type__c, SVMXC__Is_Name_Field__c,SVMXC__Display_Value__c,SVMXC__Object_Name2__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Expression_Type__c, SVMXC__Field_Name__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: SearchobjId and RecordTypeId =: ConfigExpRTypeId AND SVMXC__Search_Object_Field_Type__c = 'Result' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER By SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
      
            if(DisplayFldsSeqLst != NULL && DisplayFldsSeqLst.size() > 0)
            {
                if(DisplayFldsSeqLst[0].SVMXC__Sequence__c == 1)
                    strFirstId = DisplayFldsSeqLst[0].Id;
                else
                {
                    for(SVMXC__ServiceMax_Config_Data__c TempConfigObj : DisplayFldsSeqLst)
                        if(TempConfigObj.SVMXC__Sequence__c == 1)
                            strFirstId = TempConfigObj.Id;
                }
                displaySeqPopup = true;
            }       
        }   
    }
    /**************** Method to display Rule list for sequence changes ************************/
    public List<SelectOption> getDisplayFldsSeqoptions()
    { 
    List<SelectOption> DisplayFldsSeqoptions = new List<SelectOption>();
        //DisplayFldsSeqoptions = new List<SelectOption>();   
        if (DisplayFldsSeqLst.Size() >0)
        {
            List<SelectOption> TempSelOpt = new List<SelectOption>();
            for(SVMXC__ServiceMax_Config_Data__c s : DisplayFldsSeqLst)
            {                
                if (s.SVMXC__Field_Name__c != null)
                {
                    TempSelOpt = getAllFields(s.SVMXC__Object_Name2__c);
                    for(SelectOption SO : TempSelOpt)
                    {
                        if(SO.getValue() == string.valueOf(s.SVMXC__Field_Name__c))
                            DisplayFldsSeqoptions.add(new SelectOption(s.Id, string.valueOf(SO.getLabel())));
                    }
                }
            }
        }  
        return DisplayFldsSeqoptions; 
    }
    
    /**************** shuffle Method ************************/
    public void DisplayFldshuffle(integer IntSelIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Config_Data__c temp;
        if(isTop)
        {
          temp = DisplayFldsSeqLst[IntSelIndex];
          for(integer j=IntSelIndex;j>0;j--)
          {
            DisplayFldsSeqLst[j] = DisplayFldsSeqLst[j-1];
          }
          DisplayFldsSeqLst[0] = temp;
        }
        else 
        {
          temp = DisplayFldsSeqLst[IntSelIndex];
          for(integer j=IntSelIndex;j<DisplayFldsSeqLst.size()-1;j++)
          {
            DisplayFldsSeqLst[j] = DisplayFldsSeqLst[j+1];
          }
          DisplayFldsSeqLst[DisplayFldsSeqLst.size()-1] = temp;
        }
    }  
    public void DisplayFldUP()
    { 
        SVMXC__ServiceMax_Config_Data__c temp;
        for(integer j=0;j<DisplayFldsSeqLst.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==DisplayFldsSeqLst[0].Id)
                {
                    DisplayFldsSeqLst[j] = DisplayFldsSeqLst[j];
                    break;
                }
                else if(items[i]==DisplayFldsSeqLst[j].Id)
                {
                    temp = DisplayFldsSeqLst[j]; 
                    DisplayFldsSeqLst[j] = DisplayFldsSeqLst[j-1];
                    DisplayFldsSeqLst[j-1]=temp;     
          //IntSelIndex = j;
                    integer IntSelIndex = j;
                    IsUpAction = true;
                    IsDownAction=false;
                    IsTopAction=false;
                    IsBottomAction=false;
                    DisplayFldsSeqLst[IntSelIndex-1].SVMXC__Sequence__c=IntSelIndex-1;
                    DisplayFldsSeqLst[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
                }
            }
        }
    }
    public void DisplayFldDown()
    {  
        SVMXC__ServiceMax_Config_Data__c temp;
        for(integer i=0;i<items.size();i++)
        {
          //StrIntMap.Put(items[i],i);
        }
        for(integer i=0;i<items.size();i++)
        {
            for(integer k=0;k<DisplayFldsSeqLst.size()-1;k++)
            {
                if(items[i]==DisplayFldsSeqLst[k].Id)
                {
                    temp = DisplayFldsSeqLst[k];
                    DisplayFldsSeqLst[k] = DisplayFldsSeqLst[k+1];
                    DisplayFldsSeqLst[k+1]=temp;
          //IntSelIndex = k;
                    integer IntSelIndex = k;
                    IsUpAction = false;
                    IsDownAction=true;
                    IsTopAction=false;
                    IsBottomAction=false;
                    DisplayFldsSeqLst[IntSelIndex+1].SVMXC__Sequence__c=IntSelIndex+1;
                    DisplayFldsSeqLst[IntSelIndex].SVMXC__Sequence__c = IntSelIndex;
                    break;       
                }
            }
        } 
    }
    public void DisplayFldTop()
    {
        SVMXC__ServiceMax_Config_Data__c temp;
        for(integer j=DisplayFldsSeqLst.size()-1;j>0;j--)
        {
            for(integer i=items.size()-1;i>=0;i--)
            {
                if(items[i] == DisplayFldsSeqLst[j].Id)
                {
          //IntSelIndex = j;
                    integer IntSelIndex = j;
                    IsUpAction = false;
                    IsDownAction=false;
                    IsTopAction=true;
                    IsBottomAction=false;
                    DisplayFldshuffle(IntSelIndex, true);     
                }
            }
        }  
    }
    public void DisplayFldBottom()
    {
        SVMXC__ServiceMax_Config_Data__c temp;
        for(integer j=0;j<DisplayFldsSeqLst.size()-1;j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i] == DisplayFldsSeqLst[j].Id)
                {
          //IntSelIndex = j;
                    integer IntSelIndex = j;
                    IsUpAction = false;
                    IsDownAction=false;
                    IsTopAction=false;
                    IsBottomAction=true;     
                    DisplayFldshuffle(IntSelIndex, false); 
                }
            }
        }  
    }
    
    /**************** Method to save Rule Sequences************************/
    public pagereference DisplayFldSaveSequence()
    {
        SVMXC__ServiceMax_Config_Data__c temp;
        double t;
        if(IsUpAction)
        {
            for(integer i=0;i<DisplayFldsSeqLst.size();i++)
            {
                DisplayFldsSeqLst[i].SVMXC__Sequence__c=i+1;
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(DisplayFldsSeqLst, COMM_SecurityUtils.Access.Updateable)){
                update DisplayFldsSeqLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;  
            }
        }
        else if(IsDownAction)
        {
            for(integer i=0;i<DisplayFldsSeqLst.size();i++)
            {
                DisplayFldsSeqLst[i].SVMXC__Sequence__c=i+1;
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(DisplayFldsSeqLst, COMM_SecurityUtils.Access.Updateable)){
                update DisplayFldsSeqLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;  
            }
        }
        else if(IsTopAction)
        {
            for(integer i=0;i<DisplayFldsSeqLst.size();i++)
            {
                DisplayFldsSeqLst[i].SVMXC__Sequence__c=i+1;
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(DisplayFldsSeqLst, COMM_SecurityUtils.Access.Updateable)){
                update DisplayFldsSeqLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;  
            }
        }
        else if(IsBottomAction)
        {
            for(integer i=0;i<DisplayFldsSeqLst.size();i++)
            {
                DisplayFldsSeqLst[i].SVMXC__Sequence__c=i+1;
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(DisplayFldsSeqLst, COMM_SecurityUtils.Access.Updateable)){
                update DisplayFldsSeqLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                return null;  
            }
        }
        
        if(SearchobjId != null)
            DisplayFldsSeqLst = [Select SVMXC__Object_Name2__c, SVMXC__Display_Value__c,SVMXC__Lookup_Field_API_Name__c, SVMXC__Is_Name_Field__c,SVMXC__Search_Object_Field_Type__c, SVMXC__Expression_Rule__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Expression_Type__c, SVMXC__Field_Name__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c =: SearchobjId and RecordTypeId =: ConfigExpRTypeId AND SVMXC__Search_Object_Field_Type__c = 'Result' AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields' ORDER By SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        ConfigDataWrapper TempWrap;
        WrapLstResultFields.clear();
        if(lstSearchObj != null && lstSearchObj.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c tempProcess : DisplayFldsSeqLst)
            {
                TempWrap = new ConfigDataWrapper();
                TempWrap.objConfigData = tempProcess;
                if(tempProcess.SVMXC__Object_Name2__c != null && tempProcess.SVMXC__Object_Name2__c != '')
                    TempWrap.ObjFlds = getAllFields(tempProcess.SVMXC__Object_Name2__c);
                string strObjectName = tempProcess.SVMXC__Object_Name2__c;
                if(tempProcess.SVMXC__Lookup_Field_API_Name__c != null)
                {
                    strObjectName = strObjectName+'~'+tempProcess.SVMXC__Lookup_Field_API_Name__c;
                }
                TempWrap.objConfigData.SVMXC__Object_Name2__c = strObjectName;
               
                WrapLstResultFields.add(TempWrap);
            }
        }
        displaySeqPopup = false;
        return null;  
    }
    /***************************************************************************************************************************************/
    
    public pagereference SVMX_PopupCancel()
    {
        displaySeqPopup = false;
        displaySeqPopup1 = false;
        return null;
    }
    
    /***********************Tags methods ***********************/
    public string getHLPURL() {return system.label.CONF031_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    
    public String getTAG001(){return system.label.CONF031_TAG008;}  //'Configure Search' 
    public String getTAG002(){return system.label.COMM001_TAG041;}  //'Processing...'
    public String getTAG003(){return system.label.COMM001_TAG053;}  // 'Quick Save'
    public String getTAG004(){return system.label.COMM001_TAG054;}  //'Save & Close' 
    public String getTAG005(){return system.label.COMM001_TAG040;}  // 'Cancel'
    public String getTAG006(){return system.label.CONF031_TAG009;}  //'General Info'
    public String getTAG007(){return system.label.CONF031_TAG003;}  // 'Search Title'
    public String getTAG008(){return system.label.CONF031_TAG002;}  // 'Search Id'
    public String getTAG009(){return system.label.COMM001_TAG017;}  //'Description'
    public String getTAG010(){return system.label.CONF031_TAG026;}  // 'Object Display Sequence'
    public String getTAG011(){return system.label.CONF031_TAG010;}  //  'Search Configuration'
    public String getTAG012(){return system.label.CONF031_TAG011;}  //'Include one or more objects to be included in the scope of this search'
    public String getTAG013(){return system.label.COMM001_TAG047;}  // 'New'
    public String getTAG014(){return system.label.COMM001_TAG048;}  // 'Edit'
    public String getTAG015(){return system.label.COMM001_TAG039;}  //'Save'
    public String getTAG016(){return system.label.COMM001_TAG049;}  // 'Delete'
    public String getTAG017(){return system.label.COMM001_TAG040;}  // 'Cancel'
    public String getTAG018(){return system.label.COMM001_TAG044;}  // 'Select'
    public String getTAG019(){return system.label.CONF031_TAG012;}  // 'Search Object'
    public String getTAG020(){return system.label.CONF031_TAG013;}  // 'Result Section Title'
    public String getTAG021(){return system.label.COMM001_TAG043;}  // 'View'
    public String getTAG022(){return '';}                           // 'Auto Launch';
    public String getTAG023(){return system.label.CONF031_TAG015;}  // 'Optional: Using the expression builder below, define a filter criteria to always apply on this object\'s records'
    public String getTAG024(){return '';}  // 'Object Type'
    public String getTAG025(){return system.label.COMM002_TAG027;}  // 'Field'
    public String getTAG026(){return System.Label.COMM002_TAG005;}  //'--None--'
    public String getTAG027(){return System.Label.COMM002_TAG006;}  // 'Equals'
    public String getTAG028(){return System.Label.COMM002_TAG007;}  // 'Not Equal'
    public String getTAG029(){return System.Label.COMM002_TAG008;}  // 'Greater Than'
    public String getTAG030(){return System.Label.COMM002_TAG009;}  // 'Greater or Equal To'
    public String getTAG031(){return System.Label.COMM002_TAG010;}  // 'Less Than'
    public String getTAG032(){return System.Label.COMM002_TAG011;}  // 'Less or Equal To'
    public String getTAG033(){return System.Label.COMM002_TAG012;}  // 'Starts With'
    public String getTAG034(){return System.Label.COMM002_TAG013;}  // 'Contains'
    public String getTAG035(){return System.Label.COMM002_TAG014;}  // 'Does Not Contain'
    public String getTAG036(){return System.Label.COMM002_TAG015;}  // 'Includes'
    public String getTAG037(){return System.Label.COMM002_TAG016;}  // 'Excludes'
    public String getTAG038(){return System.Label.COMM002_TAG022;}  // 'Is Null'
    public String getTAG039(){return System.Label.COMM002_TAG023;}  // 'Is Not Null'
    public String getTAG040(){return system.label.COMM002_TAG028;}  // 'Operator'
    public String getTAG041(){return system.label.COMM002_TAG029;}  // 'Value'
    public String getTAG042(){return system.label.CONF031_TAG016;}  // 'Choose one or more fields to be displayed in the search result'
    public String getTAG043(){return system.label.CONF031_TAG017;}  // 'Choose one or more fields on which search is applied'
    public String getTAG044(){return system.label.CONF031_TAG027;}  // 'Field Display Sequence'
    public String getTAG045(){return system.label.COMM001_TAG050;}  // 'Please select at least one process.'
    public String getTAG046(){return system.label.COMM001_TAG057;}  // 'Are you sure?'
    public String getTAG047(){return system.label.CONF031_TAG018;}  // 'Please select an object first.'
    public String getTAG048(){return system.label.CONF031_TAG019;}  // 'Please enter a valid name for this Search Configuration'
    public String getTAG049(){return system.label.CONF031_TAG020;}  // 'Please enter a valid ID for this Search Configuration'
    public String getTAG050(){return system.label.COMM001_TAG051;}  // 'Please select only one process'
    public String getTAG051(){return system.label.COMM001_TAG058;}  //'Record(s) Saved'
    public String getTAG052(){return system.label.COMM001_TAG052;}  //'Record(s) Deleted'
    public String getTAG053(){return system.label.CONF031_TAG021;}  //Please enter unique process Id
    public String getTAG054(){return system.label.COMM002_TAG004;}  //Invalid Expression
    public String getTAG055(){return system.label.COMM001_TAG059;}  //Please enter values for all the mandatory fields
    public String getTAG056(){return system.label.CONF031_TAG028;}  //Choose fields on which sorting should be applied';
    public String getTAG057(){return system.label.CONF031_TAG029;}  //Search Order
    //Jaysukh:Added below method and label for BAC-3001
    public String getTAG058(){return system.label.CONF031_TAG031;}  //Please save the process first
}