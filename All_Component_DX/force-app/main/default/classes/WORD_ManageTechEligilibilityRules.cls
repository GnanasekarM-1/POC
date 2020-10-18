public with sharing class WORD_ManageTechEligilibilityRules
{
     /** Start - NPS Related code **/
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    /** End - NPS Related code **/
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    //--------------------------------- Variables and Getter-Setter Methods -----------------------------------
    public string strProcessName{get;set;}
    public string strDescription{get;set;}
    public string strAdvanceExp1{get;set;}
    public string strAdvanceExp2{get;set;} 
    public string StrDelIndex1 {get; set;}
    public string StrDelIndex2 {get; set;}      
    public string StrSelectedIndex {get; set;}   
    public boolean isRenderExp{get;set;}
    public boolean isRenderNew{get;set;}
    public boolean isRenderEdit{get;set;}
    public boolean isRenderSave{get;set;}
    public boolean isRenderDelete{get;set;}
    public boolean isRendercancel{get;set;} 
    public boolean isNewRule{get;set;}  
    public boolean isDisableSelect{get;set;} 
    public boolean isActive{get;set;}   
    public boolean IsValidProcess = true;
    public Integer selectedCount = 0;   
    public string ExpHdr_Rtype_Id;   
    public string ExpDtl_Rtype_Id;
    public SVMXC__ServiceMax_Processes__c objEligibilityCriteria = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getobjEligibilityCriteria(){return this.objEligibilityCriteria;}
    public void setobjEligibilityCriteria(SVMXC__ServiceMax_Processes__c proces){this.objEligibilityCriteria = proces;}   
    public SVMXC__ServiceMax_Processes__c objEligibilityCriteriaEdit ;    
    public  List<SVMXC__ServiceMax_Processes__c>  lstEligibilityMatchingRules = new  List<SVMXC__ServiceMax_Processes__c> ();
    public List<SVMXC__ServiceMax_Processes__c> getlstEligibilityMatchingRules(){return this.lstEligibilityMatchingRules;}    
    public List<SVMXC__ServiceMax_Processes__c> lstTempEligibilityCriteria  = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lsteligibilityMatchConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlsteligibilityMatchConfig(){return lsteligibilityMatchConfig;}
    public void setlsteligibilityMatchConfig(List<SVMXC__ServiceMax_Config_Data__c> ConfigObj){lsteligibilityMatchConfig = ConfigObj;} 
    public List<SVMXC__ServiceMax_Config_Data__c> lsteligMatchConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>(); 
    public List<SVMXC__ServiceMax_Config_Data__c> lstMatchWOtoTechConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstMatchWOtoTechConfig(){return lstMatchWOtoTechConfig;}
    public void setlstMatchWOtoTechConfig(List<SVMXC__ServiceMax_Config_Data__c> ConfigObj){lstMatchWOtoTechConfig = ConfigObj;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstWOtoTechConfigDel = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<selectoption> lstWOfield=new List<selectoption>();
    public List<selectoption> getlstWOfield() {return this.lstWOfield;}
    public List<selectoption> lstWOforTechSelected = new List<selectoption>();
    public List<selectoption> getlstWOforTechSelected() {return this.lstWOforTechSelected;}
    public List<selectoption> lstTechfield=new List<selectoption>();
    public List<selectoption> getlstTechfield() {return this.lstTechfield;}
    public List<SelectOption> lstOperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getlstOperatorSelectLst(){return lstOperatorSelectLst;}     
    public List<SelectOption> lstOperatorSelectLst1 = new List<SelectOption>();
    public List<SelectOption> getlstOperatorSelectLst1(){return lstOperatorSelectLst1;}     
    public boolean displaySeqPopup = false;
    public boolean getdisplaySeqPopup(){ return displaySeqPopup; } 
    public boolean isRenderRuleSeq = true;  
    public boolean getisRenderRuleSeq(){ return isRenderRuleSeq; }
    public void setisRenderRuleSeq(boolean b){ this.isRenderRuleSeq = b; }
    public string[] strEligibilityidRearrange = new String[]{};
    public SVMXC.SFM_WrapperDef.SFM_Response Save_Response = new SVMXC.SFM_WrapperDef.SFM_Response();   
    public  SVMXC.SFM_validateExpression ValidateExp = new SVMXC.SFM_validateExpression();    
    public integer getlsteligMatchSize(){return lsteligibilityMatchConfig.size();}
    public integer getlstMatchWOtoTech(){return lstMatchWOtoTechConfig.size();}
    public List<SelectOption> Seqoptions = new List<SelectOption>();  
    public string[] items = new String[]{};
    public integer selIndex = 0;
    public boolean isUpAction = false;
    public boolean isDownAction = false;
    public boolean isTopAction = false;
    public boolean isBottomAction = false;
    public boolean IsValidExp = false;
    public List<ConfigExpWrapper> LstCriWrap = new List<ConfigExpWrapper>();
    public List<ConfigExpWrapper> getLstCriWrap(){ return this.LstCriWrap;}
    public void setLstCriWrap(List<ConfigExpWrapper> value){ this.LstCriWrap = value; }
    public static map<string, List<SelectOption>> mapTechtoWO = new map<string, List<SelectOption>>(); 
    public integer IntIndex;
    public integer getIntIndex(){return this.IntIndex;}
    public void setIntIndex(integer index){this.IntIndex = index;}
    public string strselTechField;
    public string getstrselTechField(){return this.strselTechField;}
    public void setstrselTechField(string str){this.strselTechField = str;}
    public integer getLstCriWrapSize(){return LstCriWrap.size();}
    
    public map<string, boolean> lstStdObjAccToLicense = new map<string, boolean>();
        
    //----------------------------------------- Constructor -------------------------------------------
    Public WORD_ManageTechEligilibilityRules()
    {   
        setDefaultValues(); 
    }   
    //-------------------------------- Method to set Default Values for Variables ----------------------------
    public void setDefaultValues()
    {   
        isDisableSelect = false;
        isRenderExp=false;
        isRenderNew =true;
        isRenderEdit=true;
        isRenderSave=false;
        isRenderDelete=true;
        isRendercancel=false;
        strProcessName = null;
        strDescription = null;
        isactive = true;
        strAdvanceExp1 = null  ;
        strAdvanceExp2=null ;
        isRenderExp=false;
        displaySeqPopup = false;
        isRenderRuleSeq = true;     
        lstEligibilityMatchingRules.clear();
        lstMatchWOtoTechConfig.clear();
        lsteligibilityMatchConfig.clear();        
        preparingPicklists();
        if(lstEligibilityMatchingRules!= null && lstEligibilityMatchingRules.size()== 0)
        {
            isRenderEdit = false;           
            isRenderDelete = false;
            isRenderRuleSeq = false;     
        }
        
    }
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
    //-------------------------------------------- Method to retrive all existing Eligibility Matching Rules --------------
    public void retrieveEligibilityMatchingRules()
    {
        lstEligibilityMatchingRules.clear();
        lstEligibilityMatchingRules = [select id, SVMXC__Name__c,  SVMXC__Description__c, SVMXC__Active__c,SVMXC__Select__c ,SVMXC__Sequence__c,  SVMXC__Advance_Expression__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Source_Object_Name__c, SVMXC__Primary_Consolidation_Rule__c from SVMXC__ServiceMax_Processes__c where  RecordTypeId =: ExpHdr_Rtype_Id And SVMXC__Rule_Type__c = 'Tech Eligibility' order by SVMXC__Sequence__c];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    //------------------------------------------- Method to populate picklists ------------------------------
    public void preparingPicklists()
    {
        COMM_Utils comUtil = new COMM_Utils();
        lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();
        
        retrieveRecordTypes();   
        retrieveEligibilityMatchingRules();
        if(lstEligibilityMatchingRules.size()<=1){
            isRenderRuleSeq = false;
        }
        lstWOfield.clear();
        lstWOfield.add(new SelectOption(getTAG034(),getTAG034()));  
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        objfieldMap = SVMXC__Service_order__c.SObjectType.getDescribe().fields.getMap();                        
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.isFilterable() && f.getType().name() != 'MULTIPICKLIST')
            {
                if(f.getType() == Schema.DisplayType.Reference)
                {
                    if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                    {
                        if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                        {
                            continue;
                        }
                    }
                }
                lstWOfield.add(new SelectOption(f.getName(),f.getLabel()));
            }         
        }
        objfieldMap.clear(); 
        lstWOfield = sortingSelectOption(lstWOfield); 
        lstTechfield.clear();        
        lstTechfield.add(new SelectOption(getTAG034(),getTAG034()));        
       
        objfieldMap = SVMXC__Service_Group_Members__c.SObjectType.getDescribe().fields.getMap();                        
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.isFilterable())
                lstTechfield.add(new SelectOption(f.getName(),f.getLabel()));
        }
        lstTechfield = sortingSelectOption(lstTechfield);       
        objfieldMap.clear(); 
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
        lstOperatorSelectLst1.clear();  
        lstOperatorSelectLst1.add(new SelectOption('SVMX.NONE', getTAG034()));
        lstOperatorSelectLst1.add(new SelectOption('eq', getTAG020()));
        lstOperatorSelectLst1.add(new SelectOption('ne', getTAG021()));        
        lstOperatorSelectLst1.add(new SelectOption('starts', getTAG026()));
        lstOperatorSelectLst1.add(new SelectOption('contains', getTAG027()));
        lstOperatorSelectLst1.add(new SelectOption('notcontain', getTAG028()));
        lstOperatorSelectLst1.add(new SelectOption('in', getTAG029()));
        lstOperatorSelectLst1.add(new SelectOption('notin', getTAG030()));
        lstOperatorSelectLst1.add(new SelectOption('isnull', getTAG031()));
        lstOperatorSelectLst1.add(new SelectOption('isnotnull', getTAG032())); 
    
    }
    //------------------------------------- Method to sort the Options of the PickList -------------------------------------
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
    //------------------------------------ Visibility control on VF page --------------------------
    public void RerenderTextOrPicklist()
    {
        ConfigExpWrapper cnfwrp;
        if(LstCriWrap != null && LstCriWrap.isEmpty()!= true && integer.valueOf(StrSelectedIndex) - 1 >= 0)
        {
            cnfwrp = LstCriWrap.get(integer.valueOf(StrSelectedIndex) - 1);
        
            if(cnfwrp.IsRenderpicklist == true)
                cnfwrp.IsRenderpicklist = false;
            else
                cnfwrp.IsRenderpicklist = true;
            cnfwrp.objConf.SVMXC__Target_Field_Name__c = null;
            cnfwrp.objConf.SVMXC__Display_Value__c = null;
            LstCriWrap.set(integer.valueOf(StrSelectedIndex) - 1, cnfwrp);
            IntIndex =integer.valueOf(StrSelectedIndex);
            onchangeTechField();
        }
    }
    //------------------------------------------- Method to create new Eligibility Matching Rules ----------------------
   
    public void newEligibilityCriteria()
    {
        isDisableSelect = true;
        isRenderExp = true;
        isRenderNew = false;
        isRenderEdit = false;
        isRenderSave = true;
        isRenderDelete = false;
        isRendercancel = true;
        isNewRule = true;
        isRenderRuleSeq = false;
        isactive = true;        
        lstMatchWOtoTechConfig.clear();
        lsteligibilityMatchConfig.clear();
        LstCriWrap.clear();
        lsteligMatchConfigDel.clear();  
        objEligibilityCriteria = new SVMXC__ServiceMax_Processes__c();
        objEligibilityCriteria.SVMXC__Select__c = true;     
        objEligibilityCriteria.SVMXC__Active__c = true;     
        lstEligibilityMatchingRules.add(objEligibilityCriteria);
        HdrADDRow1();
        HdrADDRow1();
        HdrADDRow2();      
        HdrADDRow2();      
        
    }
    //------------------------------------------- Method to Edit Eligibility Matching Rules ----------------------
    public  void editEligibilityCriteria()
    {
        isDisableSelect = true;
        isRenderExp = true;
        isRenderNew =false;
        isRenderEdit = false;
        isRenderSave = true;
        isRenderDelete = false;
        isRendercancel = true;
        isNewRule = false;
        isRenderRuleSeq = false;
        selectedCount = 0;       
        lsteligMatchConfigDel.clear();
        lstMatchWOtoTechConfig.clear();
        LstCriWrap.clear();
        map<String, SObjectField> mapWOfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        map<String, SObjectField> mapTechfieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();
        List<SelectOption> lstWOfrTec= new List<SelectOption>();
         Map<Schema.Displaytype,list<SelectOption>> mapWOFldTypeFldSelOptLst = new Map<Schema.Displaytype,list<SelectOption>>();
         COMM_Utils comUtil = new COMM_Utils();
        for(Schema.SObjectField fieldMap1: mapWOfieldMap.values())
        {
            //Describe the field to get all properties
            list<SelectOption> lstWofl = new list<SelectOption>();
            Schema.DescribeFieldResult fieldDescribe1 = fieldMap1.getDescribe();
           
            if(fieldDescribe1.getType() == Schema.DisplayType.Reference)
            {
                if(!comUtil.SVMX_isObjectCustom(String.valueof(fieldDescribe1.getReferenceTo()[0])))
                {
                    if(!lstStdObjAccToLicense.containsKey(String.valueof(fieldDescribe1.getReferenceTo()[0])))
                    {
                        continue;
                    }
                }
            }
            
           if(mapWOFldTypeFldSelOptLst.containskey(fieldDescribe1.getType()))
           {
           lstWofl = mapWOFldTypeFldSelOptLst.get(fieldDescribe1.getType());
           lstWofl.add(new SelectOption(fieldDescribe1.getName(), fieldDescribe1.getLabel()));
           mapWOFldTypeFldSelOptLst.put(fieldDescribe1.getType(),lstWofl);
           }
           
           else 
           {
           lstWofl.add(new SelectOption(fieldDescribe1.getName(), fieldDescribe1.getLabel()));
           mapWOFldTypeFldSelOptLst.put(fieldDescribe1.getType(),lstWofl);
           }
        }
        
        Map<string,Schema.Displaytype> mapTechFldNameFldType = new Map<string,Schema.Displaytype>();
        for(Schema.SObjectField fieldMap1: mapTechfieldMap.values())
        {
            //Describe the field to get all properties
            
            list<SelectOption> lstWofl = new list<SelectOption>();
            Schema.DescribeFieldResult fieldDescribe1 = fieldMap1.getDescribe();
            
            mapTechFldNameFldType.put(fieldDescribe1.getName(),fieldDescribe1.getType());
           
           
        }
        
        objEligibilityCriteriaEdit = new SVMXC__ServiceMax_Processes__c();
        for(SVMXC__ServiceMax_Processes__c objEligCrit: lstEligibilityMatchingRules)
        {
            if(objEligCrit.SVMXC__Select__c == true)
            {
                selectedCount += 1;
                strProcessName = objEligCrit.SVMXC__Name__c;
                strDescription = objEligCrit.SVMXC__Description__c;
                isactive = objEligCrit.SVMXC__Active__c;
                strAdvanceExp1 = objEligCrit.SVMXC__Advance_Expression__c  ;
                strAdvanceExp2 = objEligCrit.SVMXC__Primary_Consolidation_Rule__c ;
                objEligibilityCriteriaEdit = objEligCrit;
                
            }
            
        }
        if( selectedCount == 1 )
        {
            lsteligibilityMatchConfig.clear();
            lsteligibilityMatchConfig = [Select Id,SVMXC__Sequence__c,SVMXC__Field_Name__c,SVMXC__Operator__c,SVMXC__Operand__c,SVMXC__Object_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Lookup_Field_API_Name__c,SVMXC__Expression_Type__c,SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objEligibilityCriteriaEdit.id and SVMXC__Expression_Type__c = 'Tech_Eligibility' order by SVMXC__Sequence__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
           
            lstMatchWOtoTechConfig  = [Select Id,SVMXC__Sequence__c,SVMXC__Field_Name__c, SVMXC__Operator__c,SVMXC__Target_Field_Name__c,SVMXC__Display_Value__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objEligibilityCriteriaEdit.id and SVMXC__Expression_Type__c = 'Tech_Match'  order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            
           
          //--------------------- Populate expression data into the list of Wrapper ----------------------------------
                if(lstMatchWOtoTechConfig != null && lstMatchWOtoTechConfig.size() > 0)
                {
                    
                    ConfigExpWrapper CriWrap;
                    
                    for(SVMXC__ServiceMax_Config_Data__c Temp : lstMatchWOtoTechConfig)
                    {
                        CriWrap = new ConfigExpWrapper();
                        CriWrap.objConf = Temp;
                        
                        if(Temp.SVMXC__Target_Field_Name__c != '' && Temp.SVMXC__Target_Field_Name__c !=null && Temp.SVMXC__Target_Field_Name__c != getTAG034())
                            CriWrap.IsRenderpicklist = true;
                        else if (Temp.SVMXC__Display_Value__c != '' && Temp.SVMXC__Display_Value__c !=null )
                            CriWrap.IsRenderpicklist = false;
                        else 
                            CriWrap.IsRenderpicklist = true;
                        if(CriWrap.IsRenderpicklist )
                        {
                            if(mapWOFldTypeFldSelOptLst.containskey(mapTechFldNameFldType.get(Temp.SVMXC__Field_Name__c)))
                            CriWrap.lstWOforTechSel = mapWOFldTypeFldSelOptLst.get(mapTechFldNameFldType.get(Temp.SVMXC__Field_Name__c));
                           CriWrap.lstWOforTechSel.add(new SelectOption(getTAG034(), getTAG034())); 
                           
                            CriWrap.lstWOforTechSel = sortingSelectOption(CriWrap.lstWOforTechSel);
                        }
                        LstCriWrap.add(CriWrap) ;
                    }
                    
                } 
           
        }
        else if( selectedCount == 0 )
        {
            setDefaultValues();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG037(),''));
          
           
        }    
        else
        {
            setDefaultValues();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG038(),''));
          
        }
    }  
   //------------------------------------------- Method to Delete Eligibility Matching Rules ----------------------
    public void deleteEligibilityCriteria()
    {
        SVMXC__ServiceMax_Processes__c objEligibilityCriteriaDel = new SVMXC__ServiceMax_Processes__c();
        isRenderExp = false;
        isRenderNew = true;
        isRenderEdit = true;
        isRenderSave = false;
        isRenderDelete = true;
        isRendercancel = false;
        list<SVMXC__ServiceMax_Config_Data__c> lstconfig = new list<SVMXC__ServiceMax_Config_Data__c>();
        selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c objEligCrit: lstEligibilityMatchingRules)
        {
            if(objEligCrit.Select__c == true)
            {
                selectedCount += 1;
              
                objEligibilityCriteriaDel = objEligCrit;
            }
        }
        if( selectedCount == 1 )
        {
            lstconfig = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: objEligibilityCriteriaDel.id];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //CRUD
            if(lstconfig != null && lstconfig.size() > 0)
                {
                    
                    if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Config_Data__c'))       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                    delete lstconfig;   
                    }
                }
            //delete lstconfig; 
            //CRUD
            if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Config_Data__c'))       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                    delete objEligibilityCriteriaDel;   
                    }
                    
            //delete objEligibilityCriteriaDel;
            retrieveEligibilityMatchingRules();
            strProcessName = null;
            strDescription = null;
            isactive = false;
            strAdvanceExp1 = null  ;
            strAdvanceExp2 = null ;
          
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
    //----------------------------- Method to Cancelthe changes made to Eligibility Matching Rules ----------------------
    public void cancelEligibilityCriteria()
    {
        for(SVMXC__ServiceMax_Processes__c objEligCrit: lstEligibilityMatchingRules)
        {
            if(objEligCrit.SVMXC__Select__c == true)           
                objEligCrit.SVMXC__Select__c = false;           
        }
        setDefaultValues();
    }
    //------------------------------------------- Method to Save Eligibility Matching Rules ----------------------
    public void saveEligibilityCriteria()
    {
        IsValidExp = true;
       try
        {
            objEligibilityCriteria = new SVMXC__ServiceMax_Processes__c();
            String strParentcriteria = '';
            //retrieveEligibilityMatchingRules();
            if(isNewRule)           
                objEligibilityCriteria.SVMXC__Sequence__c = (lstEligibilityMatchingRules.size());
            if(!isNewRule)
            {           
                objEligibilityCriteria = objEligibilityCriteriaEdit;
                
            }
            validation();

            
            if(IsValidProcess)
            { 
                System.debug('lsteligibilityMatchConfig val'+lsteligibilityMatchConfig);
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
                    if(!lsteligibilityMatchConfigtempDel.isempty())
                    delete lsteligibilityMatchConfigtempDel;        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
                    if(!lsteligibilityMatchConfigtemp.isempty())
                        lsteligibilityMatchConfig.addall(lsteligibilityMatchConfigtemp);
                    
                    boolean isExpVal;
                    isExpVal = submitExp(objEligibilityCriteria,lsteligibilityMatchConfig,strAdvanceExp1);
                     
                    if(!isExpVal)
                    {
                        isRenderExp = true;
                        IsValidExp = false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG052()));
                    }
                    
                    strParentcriteria = ValidateExp.getCriteria('SVMXC__Service_Order__c', strAdvanceExp1, lsteligibilityMatchConfig );
                   
                    if(strParentcriteria == 'ERROR')
                    {
                        isRenderExp = true;
                        IsValidExp = false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG052()));
                    }                   
               } 
               System.debug('isactive val'+isactive);
                if(IsValidExp)
                {              
                    //if(lsteligibilityMatchConfig != null && lsteligibilityMatchConfig.size() >0)
                   // submitExp(objEligibilityCriteria,lsteligibilityMatchConfig);
                                  
                    objEligibilityCriteria.SVMXC__Name__c = strProcessName;
                    objEligibilityCriteria.SVMXC__Description__c = strDescription;
                    System.debug('isactive val'+isactive);
                    if(isNewRule)
                    objEligibilityCriteria.SVMXC__Active__c = isactive;
                    System.debug('objEligibilityCriteria.SVMXC__Active__c val'+objEligibilityCriteria.SVMXC__Active__c);
                    objEligibilityCriteria.SVMXC__Advance_Expression__c = strAdvanceExp1;
                    objEligibilityCriteria.SVMXC__Primary_Consolidation_Rule__c = strAdvanceExp2;
                    objEligibilityCriteria.SVMXC__Rule_Type__c = 'Tech Eligibility';
                    objEligibilityCriteria.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c'; 
                    objEligibilityCriteria.SVMXC__Parent_Object_Criteria__c = strParentcriteria;          
                    objEligibilityCriteria.RecordTypeId = ExpHdr_Rtype_Id; 
                    objEligibilityCriteria.SVMXC__Select__c = false;
                    //CRUD
                    if (!securityUtils.verifyFieldAccess(objEligibilityCriteria, COMM_SecurityUtils.Access.Upsertable))     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            upsert objEligibilityCriteria;
                        }           
                    //upsert objEligibilityCriteria; 
                    Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();                        
                   
                    objfieldMap = SVMXC__Service_Order__c.SObjectType.getDescribe().fields.getMap();  
                    System.debug('lsteligibilityMatchConfig val'+lsteligibilityMatchConfig); 
                    integer seqval = 1;                 
                    for(SVMXC__ServiceMax_Config_Data__c confobj: lsteligibilityMatchConfig)
                    {
                        
                        confobj.SVMXC__Expression_Type__c = 'Tech_Eligibility';
                        confobj.RecordTypeId = ExpDtl_Rtype_Id;
                        confobj.SVMXC__Sequence__c = seqval;  
                        seqval = seqval+1;
                        confobj.SVMXC__Expression_Rule__c = objEligibilityCriteria.id;
                        for (String fieldKey : objfieldMap.keySet()) 
                        {
                            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                            Schema.DescribeFieldResult f = fsObj.getDescribe();
                            if(f.getName() == confobj.SVMXC__Field_Name__c)
                            {
                                confobj.SVMXC__Display_Type__c = f.getType().name();
                            }
                        }
                    }
                    lstMatchWOtoTechConfig.clear();
                     objfieldMap.clear();               
                    objfieldMap = SVMXC__Service_Group_Members__c.SObjectType.getDescribe().fields.getMap();  
                    System.debug('LstCriWrap val'+LstCriWrap);
                    if(LstCriWrap != null && LstCriWrap.size() >0)
                    {
                        seqval = 1;
                        for(ConfigExpWrapper wrapObj :LstCriWrap)
                        {
                            SVMXC__ServiceMax_Config_Data__c ConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();                    
                            ConfigDataExp = wrapObj.objConf;   
                            System.debug('ConfigDataExp val'+ConfigDataExp);
                            if(ConfigDataExp.SVMXC__Operator__c != getTAG034() && ConfigDataExp.SVMXC__Operator__c != 'SVMX.NONE' && ConfigDataExp.SVMXC__Field_Name__c != getTAG034() && ConfigDataExp.SVMXC__Field_Name__c != 'SVMX.NONE')
                            {
                                
                                ConfigDataExp.SVMXC__Expression_Type__c = 'Tech_Match';
                                ConfigDataExp.RecordTypeId = ExpDtl_Rtype_Id;
                                ConfigDataExp.SVMXC__Expression_Rule__c = objEligibilityCriteria.id;
                                ConfigDataExp.SVMXC__Sequence__c = seqval;  
                                seqval = seqval+1;  
                                if(ConfigDataExp.SVMXC__Target_Field_Name__c == getTAG034())
                                    ConfigDataExp.SVMXC__Target_Field_Name__c = null;
                                for (String fieldKey : objfieldMap.keySet()) 
                                {
                                    Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
                                    Schema.DescribeFieldResult f = fsObj.getDescribe();
                                    if(f.getName() == ConfigDataExp.SVMXC__Field_Name__c)
                                    {
                                        ConfigDataExp.SVMXC__Display_Type__c = f.getType().name();
                                    }
                                }
                                lstMatchWOtoTechConfig.add(ConfigDataExp);
                            }                           
                        }
                        
                    }
                    System.debug('lsteligMatchConfigDel val'+lsteligMatchConfigDel);
                    System.debug('lsteligibilityMatchConfig val'+lsteligibilityMatchConfig);
                    System.debug('lstWOtoTechConfigDel val'+lstWOtoTechConfigDel);
                    System.debug('lstMatchWOtoTechConfig val'+lstMatchWOtoTechConfig);
                    if(!lsteligMatchConfigDel.isempty())
                        delete lsteligMatchConfigDel;       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lsteligibilityMatchConfig!= null && lsteligibilityMatchConfig.size()>0)
                        upsert lsteligibilityMatchConfig;  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA 
                    if(!lstWOtoTechConfigDel.isempty()) 
                        delete lstWOtoTechConfigDel;        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lstMatchWOtoTechConfig!= null && lstMatchWOtoTechConfig.size()>0)                    
                        upsert lstMatchWOtoTechConfig;      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        retrieveEligibilityMatchingRules();
                    for(SVMXC__ServiceMax_Processes__c objEligCrit: lstEligibilityMatchingRules)
                    {
                        if(objEligCrit.SVMXC__Select__c == true)           
                            objEligCrit.SVMXC__Select__c = false;           
                    }
                    
                    setDefaultValues();
                }
                else
                {
                    isRenderExp = true; 
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG052()));
                }
            
            }       
            else    
                isRenderExp = true;             
                
           
        }
        catch(exception ex)
        {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG048()));
        }
    }
    //------------------------------------------- Method to Validate Eligibility Matching Rules ----------------------
    public void validation()
    {
        integer count = 0;
        IsValidProcess=true; 
        if(strProcessName == null || strProcessName == '')
        {
            IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG041(),''));
        }  
        if( strProcessName.length() < 8 )   
        {
             IsValidProcess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG051(),''));
        }       
       
        for(SVMXC__ServiceMax_Processes__c objEligCrit: lstEligibilityMatchingRules)
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
        } 
        
      
        if(lsteligibilityMatchConfig != null && lsteligibilityMatchConfig.size() > 0)
        {
            for(Integer i=0; i < lsteligibilityMatchConfig.size(); i++)
            {
                if((lsteligibilityMatchConfig[i].Operator__c != getTAG034() &&  lsteligibilityMatchConfig[i].Operator__c != 'SVMX.NONE') && lsteligibilityMatchConfig[i].SVMXC__Field_Name__c == getTAG034())
                {
                    IsValidProcess=false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG042()));
                }
            }
        }
       
        if(lstMatchWOtoTechConfig != null && lstMatchWOtoTechConfig.size() > 0)
        {
            for(Integer i=0; i < lstMatchWOtoTechConfig.size(); i++)
            {
                
                if((lstMatchWOtoTechConfig[i].SVMXC__Target_Field_Name__c != getTAG034() && lstMatchWOtoTechConfig[i].SVMXC__Target_Field_Name__c != 'SVMX.NONE' && lstMatchWOtoTechConfig[i].SVMXC__Operator__c != getTAG034()|| lstMatchWOtoTechConfig[i].SVMXC__Operator__c != 'SVMX.NONE') && lstMatchWOtoTechConfig[i].SVMXC__Field_Name__c == getTAG034())
                {
                    IsValidProcess=false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG042()));
                }
            }
        }
       
    }   
    //---------------------------- Methods to add row to Expression  ------------------------------------------
   
    public void HdrADDRow1()
    {
        try
        {
          
            lsteligibilityMatchConfig.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(lsteligibilityMatchConfig.size() + 1)));   
        System.debug('lsteligibilityMatchConfig val'+lsteligibilityMatchConfig);            
        }
        
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
        
    }
    
    //---------------------------- Methods to delete a row from Expression  ------------------------------------------    
    public void HdrDeleteRow1()
    {
        integer IntVal;
        IntVal = integer.valueOf(StrDelIndex1);  
        System.debug('IntVal val'+IntVal);      
        if(lsteligibilityMatchConfig.get(IntVal - 1).id != null)
            lsteligMatchConfigDel.add(lsteligibilityMatchConfig.get(IntVal - 1));
        lsteligibilityMatchConfig.remove(IntVal - 1); 
        if(IntVal <= lsteligibilityMatchConfig.size())    
        {       
            for(integer i = IntVal; i <= lsteligibilityMatchConfig.size(); i++ )
                lsteligibilityMatchConfig[i-1].SVMXC__Sequence__c = i;        
        }    
       System.debug('lsteligibilityMatchConfig val'+lsteligibilityMatchConfig);            
  
    }
    //---------------------------------- Method to populate WO picklist based on Technician field Selected -----------------
    public void onchangeTechField()
    {
        COMM_Utils comUtil = new COMM_Utils();
        map<String, SObjectField> mapWOfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        map<String, SObjectField> mapTechfieldMap = Schema.SObjectType.SVMXC__Service_Group_Members__c.fields.getMap();
        List<SelectOption> lstWOfrTec= new List<SelectOption>();
        Map<Schema.Displaytype,list<SelectOption>> mapWOFldTypeFldSelOptLst = new Map<Schema.Displaytype,list<SelectOption>>();
        for(Schema.SObjectField fieldMap1: mapWOfieldMap.values())
        {
            //Describe the field to get all properties
            list<SelectOption> lstWofl = new list<SelectOption>();
            Schema.DescribeFieldResult fieldDescribe1 = fieldMap1.getDescribe();
           
            if(fieldDescribe1.getType() == Schema.DisplayType.Reference)
            {
                if(!comUtil.SVMX_isObjectCustom(String.valueof(fieldDescribe1.getReferenceTo()[0])))
                {
                    if(!lstStdObjAccToLicense.containsKey(String.valueof(fieldDescribe1.getReferenceTo()[0])))
                    {
                        continue;
                    }
                }
            }
                
            if(mapWOFldTypeFldSelOptLst.containskey(fieldDescribe1.getType()))
           {
           lstWofl = mapWOFldTypeFldSelOptLst.get(fieldDescribe1.getType());
           lstWofl.add(new SelectOption(fieldDescribe1.getName(), fieldDescribe1.getLabel()));
           mapWOFldTypeFldSelOptLst.put(fieldDescribe1.getType(),lstWofl);
           }
           
           else 
           {
           lstWofl.add(new SelectOption(fieldDescribe1.getName(), fieldDescribe1.getLabel()));
           mapWOFldTypeFldSelOptLst.put(fieldDescribe1.getType(),lstWofl);
           }
        }
       
        Map<string,Schema.Displaytype> mapTechFldNameFldType = new Map<string,Schema.Displaytype>();
        for(Schema.SObjectField fieldMap1: mapTechfieldMap.values())
        {
            //Describe the field to get all properties            
            list<SelectOption> lstWofl = new list<SelectOption>();
            Schema.DescribeFieldResult fieldDescribe1 = fieldMap1.getDescribe();            
            mapTechFldNameFldType.put(fieldDescribe1.getName(),fieldDescribe1.getType());   
           
        }
        
        integer IntVal = integer.valueOf(IntIndex);
       
        SVMXC__ServiceMax_Config_Data__c confobj = new SVMXC__ServiceMax_Config_Data__c();          
        ConfigExpWrapper cnfwrp = LstCriWrap.get(IntVal-1);        
        
        
        lstWOforTechSelected = new List<selectoption>();
        string str =cnfwrp.objConf.SVMXC__Field_Name__c;
        
         
        if(mapWOFldTypeFldSelOptLst.containskey(mapTechFldNameFldType.get(cnfwrp.objConf.SVMXC__Field_Name__c)))
        lstWOforTechSelected = mapWOFldTypeFldSelOptLst.get(mapTechFldNameFldType.get(cnfwrp.objConf.SVMXC__Field_Name__c));
       lstWOforTechSelected.add(new SelectOption(getTAG034(), getTAG034())); 
       
       
        lstWOforTechSelected = sortingSelectOption(lstWOforTechSelected);
        cnfwrp.lstWOforTechSel = lstWOforTechSelected;
        LstCriWrap.set(IntVal-1,cnfwrp);
        
    }
    //---------------------------- Methods to add row to Expression  ------------------------------------------     
    public void HdrADDRow2()
    {
        try
        {
            list<SelectOption> lstWO = new list<SelectOption>();
            lstWO.add(new SelectOption(getTAG034(), getTAG034()));
          
           if(LstCriWrap.isEmpty())        
                LstCriWrap.add(new ConfigExpWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = 1),lstWO, true) ); 
            else
                LstCriWrap.add(new ConfigExpWrapper(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(LstCriWrap.size() + 1)),lstWO, true));         
        }
        
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
       
    }
    
    //---------------------------- Methods to delete a row from Expression  ------------------------------------------
    public void HdrDeleteRow2()
    {
       
        integer IntVal;           
        IntVal = integer.valueOf(StrDelIndex2); 
        System.debug('IntVal val'+IntVal);
        if(IntVal <= LstCriWrap.size())
        {
            for(integer i=IntVal;i< LstCriWrap.size();i++)
            {
                ConfigExpWrapper cnfwrp = LstCriWrap.get(i);
                cnfwrp.objConf.SVMXC__Sequence__c = cnfwrp.objConf.SVMXC__Sequence__c-1;
                 LstCriWrap.set(i,cnfwrp);
            }
        }
            if(LstCriWrap != null && LstCriWrap.size() > 0)
            {   
                SVMXC__ServiceMax_Config_Data__c cnfobj1 = new SVMXC__ServiceMax_Config_Data__c();              
                cnfobj1 = LstCriWrap.get(IntVal-1).objConf;              
                LstCriWrap.remove(IntVal-1);
                
                if(cnfobj1.id!=null)
                    lstWOtoTechConfigDel.add(cnfobj1);
                
            }
            if(IntVal <= LstCriWrap.size())    
            {       
                for(integer i = IntVal; i <= LstCriWrap.size(); i++ )
                    LstCriWrap[i-1].objConf.SVMXC__Sequence__c = i;        
            } 
           System.debug('LstCriWrap val'+LstCriWrap);
           System.debug('lstWOtoTechConfigDel val'+lstWOtoTechConfigDel);
    }
    
    public boolean submitExp(SVMXC__ServiceMax_Processes__c ProcessObj, List<SVMXC__ServiceMax_Config_Data__c> ExpConfigDataLst, string AdvExp)
    {          
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
    
      
       
    //-----------------------------------------------Method to validate string ----------------------------------------------
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
    
    //---------------------------------------------Rule Sequence------------------------------------ 
    
    public void SVMX_OrderSequence()
    {
        isRenderNew =false;
        isRenderEdit=false;
        isRenderSave=false;
        isRenderDelete=false;
        isRendercancel=false;
        retrieveEligibilityMatchingRules();
        boolean DisableParntLst = true;
        lstTempEligibilityCriteria.clear();
        lstTempEligibilityCriteria.addAll(lstEligibilityMatchingRules);
        for(integer i=0;i<lstEligibilityMatchingRules.size();i++)
        {
            if(lstEligibilityMatchingRules[i].SVMXC__Select__c)           
                DisableParntLst = true;
           
        }
        if(DisableParntLst)
        {
            displaySeqPopup = true;           
            isRenderRuleSeq = false;
        }       
    }
    
   public List<SelectOption> getSeqoptions()
    {    
        Seqoptions = new List<SelectOption>();            
        if (lstTempEligibilityCriteria.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:lstTempEligibilityCriteria)
            {                               
                if (s.SVMXC__Name__c != null)
                Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        }        
        return Seqoptions; 
    }
    public string[] getstrEligibilityidRearrange()
    {
        return strEligibilityidRearrange;
    }    
    public void setstrEligibilityidRearrange(string[] o)
    {
        this.strEligibilityidRearrange=o;
    }
    
    public void shuffle(integer selIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop)
        {
            temp = lstTempEligibilityCriteria[selIndex];
            for(integer j=selIndex;j>0;j--)
            {
                lstTempEligibilityCriteria[j] = lstTempEligibilityCriteria[j-1];
            }
            lstTempEligibilityCriteria[0] = temp;
        }
        else 
        {
            temp = lstTempEligibilityCriteria[selIndex];
            for(integer j=selIndex;j<lstTempEligibilityCriteria.size()-1;j++)
            {
                lstTempEligibilityCriteria[j] = lstTempEligibilityCriteria[j+1];
            }
            lstTempEligibilityCriteria[lstTempEligibilityCriteria.size()-1] = temp;
        }
    }   
    //------------------------------- Method to move Eligibility Rule up by one position -----------------------    
    public void UP()
    {    
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstTempEligibilityCriteria.size();j++)
        {
            for(integer i=0;i<strEligibilityidRearrange.size();i++)
            {
                if(strEligibilityidRearrange[i]==lstTempEligibilityCriteria[0].Id)
                {
                    lstTempEligibilityCriteria[j] = lstTempEligibilityCriteria[j];
                        //break;
                }
                else if(strEligibilityidRearrange[i]==lstTempEligibilityCriteria[j].Id)
                {
                    temp = lstTempEligibilityCriteria[j]; 
                    lstTempEligibilityCriteria[j] = lstTempEligibilityCriteria[j-1];
                    lstTempEligibilityCriteria[j-1]=temp;                    
                    selIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    lstTempEligibilityCriteria[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    lstTempEligibilityCriteria[selIndex].SVMXC__Sequence__c = selIndex;
                }
            }
        }
       
    }
    //------------------------------- Method to move Eligibility Rule down by one position -----------------------
    public void Down()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=lstTempEligibilityCriteria.size()-1;j>=0;j--)
        {
            for(integer i=0;i<strEligibilityidRearrange.size();i++)
            {
                if(strEligibilityidRearrange[i]==lstTempEligibilityCriteria[lstTempEligibilityCriteria.size()-1].Id)
                {
                    lstTempEligibilityCriteria[j] = lstTempEligibilityCriteria[j];
                   // break;
                }
                else if(strEligibilityidRearrange[i]==lstTempEligibilityCriteria[j].Id)
                {
                            temp = lstTempEligibilityCriteria[j]; 
                            lstTempEligibilityCriteria[j] = lstTempEligibilityCriteria[j+1];
                            lstTempEligibilityCriteria[j+1]=temp;                    
                            selIndex = j;
                            isUpAction = false;
                            isDownAction=true;
                            isTopAction=false;
                            isBottomAction=false;
                            lstTempEligibilityCriteria[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                            lstTempEligibilityCriteria[selIndex].SVMXC__Sequence__c = selIndex;
                }  
            }
        }
    }
    //------------------------------- Method to move Eligibility Rule to the top -----------------------
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=lstTempEligibilityCriteria.size()-1;j>0;j--)
        {
            for(integer i = strEligibilityidRearrange.size()-1;i>=0;i--){
                if(strEligibilityidRearrange[i] == lstTempEligibilityCriteria[j].Id)
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
    public void Bottom(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<lstTempEligibilityCriteria.size()-1;j++){
            for(integer i=0;i<strEligibilityidRearrange.size();i++){
                if(strEligibilityidRearrange[i] == lstTempEligibilityCriteria[j].Id){
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
    //-------------------------------------- Method to save rearrnged Eligibility Rule ----------------------------
    public void SVMX_SaveSequence()
    {
        list<SVMXC__ServiceMax_Processes__c> lsttemp = new list<SVMXC__ServiceMax_Processes__c>();
        double t;
      
        for(integer i =0 ;i<lstTempEligibilityCriteria.size();i++)
        {
            lstTempEligibilityCriteria[i].SVMXC__Sequence__c=i;
        }
        //CRUD
        if(lstTempEligibilityCriteria != null && lstTempEligibilityCriteria.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(lstTempEligibilityCriteria, COMM_SecurityUtils.Access.Updateable))     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update lstTempEligibilityCriteria;
                        }
                }
        //update lstTempEligibilityCriteria;
        setDefaultValues();
        
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
    //------------------------------------------  Wrapper  Class ------------------------------------------------
    public class ConfigExpWrapper
    {
        public SVMXC__ServiceMax_Config_Data__c objConf = new SVMXC__ServiceMax_Config_Data__c();
        public SVMXC__ServiceMax_Config_Data__c getobjConf(){return this.objConf;}
        public void setobjConf(SVMXC__ServiceMax_Config_Data__c proces){this.objConf = proces;}  
        
        public List<SelectOption> lstWOforTechSel = new List<SelectOption>();
        public List<SelectOption> getlstWOforTechSel(){return lstWOforTechSel;}
        public void setlstWOforTechSel(List<SelectOption> SelOpt){this.lstWOforTechSel = SelOpt;}
        
        public boolean IsRenderpicklist;
        public boolean getIsRenderpicklist(){return IsRenderpicklist;}
        public void setIsRenderpicklist(boolean i){this.IsRenderpicklist = i;}
        
        //--------------------------- Wrapper Class  Constructor -------------------------
        public ConfigExpWrapper()
        {
            IsRenderpicklist = false;
        }
        public ConfigExpWrapper(SVMXC__ServiceMax_Config_Data__c objCnf, List<SelectOption> lstObjFlds , boolean isPicklist)
        {
            objConf = objCnf;
            lstWOforTechSel = lstObjFlds;   
            IsRenderpicklist = isPicklist;          
        }
    }
     public void editEntryCriteria(){}
      //------------------------------------- Getter methods for the custom labels ----------------------------------
        
        public string getHLPURL() {return 'http://userdocs.servicemax.com';} 
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
        public String getTAG034() {return system.label.COMM002_TAG005;}//None
        public String getTAG035() {return system.label.COMM001_TAG036;}//'Add'
        public String getTAG036() {return system.label.COMM001_TAG049;}//'Delete'
        public String getTAG037() {return system.label.COMM001_TAG111;}//'Please select a Rule to perform this operation'
        public String getTAG038() {return system.label.COMM001_TAG112;}//'Please select only one Rule to perform this operation'
        public String getTAG039() {return system.label.COMM001_TAG113;}//'Please enter a valid rule name.'
        public String getTAG040() {return system.label.COMM002_TAG004;}//'Invalid Expression'
        public String getTAG041() {return system.label.COMM001_TAG113;}//'Please enter a valid rule name'
        public String getTAG042() {return system.label.COMM002_TAG004;}
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
     }