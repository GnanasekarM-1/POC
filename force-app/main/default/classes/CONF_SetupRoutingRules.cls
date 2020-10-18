public with sharing class CONF_SetupRoutingRules 
{
    /*********************** Global variables with getter setter ***********************/
    public integer IntIndex;
    public integer getIntIndex(){return this.IntIndex;}
    public void setIntIndex(integer index){this.IntIndex = index;}
    public string StrRoutID='';
    public String StrProcessRuleID;
    public string StrDelIndex { get; set; }
    public integer IntVal;
    public string StrObjectName = '';
    public String StrAdvanceExp = '';
    public string StrMode = '';
    public List<RecordType> LstProcessRType = new List<RecordType>(); 
    public List<RecordType> LstConfigRType = new List<RecordType>(); 
    public String StrSVMXRuleId = '';  
    public String StrConfigExpId = ''; 
    public String StrConfigStopId = ''; 
    public boolean IsHdrMsg = false;
    public boolean getIsHdrMsg(){return this.IsHdrMsg = IsHdrMsg;}
    public void setIsHdrMsg(boolean b){IsHdrMsg = b;}
    public boolean IsdisableValue = false;
    public boolean getIsdisableValue(){return this.IsdisableValue;}
    public void setIsdisableValue(boolean b){this.IsdisableValue = b;}
    public boolean IsRender = false;
    public boolean getIsRender(){return this.IsRender;}
    public void setIsRender(boolean IsIsRender){this.IsRender = IsIsRender;}
    public boolean IsExpMsg = false;
    public boolean getIsExpMsg(){return this.IsExpMsg = IsExpMsg;}
    public void setIsExpMsg(boolean IsDisplay){this.IsExpMsg = IsDisplay;}
    public integer getLocLstSize(){return LocConfigLst.size();}
    public List<SelectOption> LstTempObjFlds = new List<SelectOption>();
    
    public List<SelectOption> slctLstLocs = new List<SelectOption>();
    public List<SelectOption> getslctLstLocs(){ return slctLstLocs;}

    public Map<String, Schema.SObjectField> Mapfields = new Map<String, Schema.SObjectField>(); 
    public Map<String, Schema.SObjectField> MapNamefields = new Map<String, Schema.SObjectField>();
    public Map<String, Schema.SObjectType> MapAllobj = new Map<String, Schema.SObjectType>();
    public Map<String, Schema.SObjectType> MapAllobjName = Schema.getGlobalDescribe();
    public Map<String,Integer> MapRuleName = new Map<String,Integer>();
    public LIST<SVMXC__ServiceMax_Processes__c> LstProcessRules = new LIST<SVMXC__ServiceMax_Processes__c>();
    public LIST<SVMXC__ServiceMax_Processes__c> LstSVMXRoutRules = new LIST<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getLstSVMXRoutRules(){return LstSVMXRoutRules;}
    public void setLstSVMXRoutRules(List<SVMXC__ServiceMax_Processes__c> processObj){LstSVMXRoutRules = processObj;}
    public SVMXC__ServiceMax_Processes__c RoutRule = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getRoutRule(){return RoutRule;}
    public void setRoutRule(SVMXC__ServiceMax_Processes__c processObj){RoutRule = processObj;}
    public List<SelectOption> OperatorsSelectLst = new List<SelectOption>();
    public List<SelectOption> getOperatorsSelectLst(){ return OperatorsSelectLst;}
    public List<SelectOption> ObjectLst = new  List<SelectOption>();
    public List<SelectOption> getObjectLst(){return ObjectLst;}
    public integer getLstCriWrapSize(){return LstCriWrap.size();}
    public List<ConfigExpWrapper> LstCriWrap = new List<ConfigExpWrapper>();
    public List<ConfigExpWrapper> getLstCriWrap(){ return this.LstCriWrap;}
    public void setLstCriWrap(List<ConfigExpWrapper> value){ this.LstCriWrap = value; }
    
    public List<SVMXC__ServiceMax_Config_Data__c> LocConfigLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getLocConfigLst(){return LocConfigLst;}
    public void setLocConfigLst(List<SVMXC__ServiceMax_Config_Data__c> ConfigObj){LocConfigLst = ConfigObj;}
    public List<SVMXC__ServiceMax_Config_Data__c> LstConfigExp = new List<SVMXC__ServiceMax_Config_Data__c>();

    public boolean getRuleLstSize()
    {
        if(LstSVMXRoutRules.size() == 0)
            return true;
        else
            return false;
    }
    public SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
    public SVMXC.SFM_validateExpression ValidateExp = new SVMXC.SFM_validateExpression();
    
    /*********************** Constructor ***********************/
    public CONF_SetupRoutingRules()
    {
        Onload();
        RoutRule = new SVMXC__ServiceMax_Processes__c(RecordTypeId = StrSVMXRuleId);
        StrMode = System.currentPageReference().getParameters().get('SVMX_Mode');
        List<SVMXC__Site__c> lstLocs = new List<SVMXC__Site__c>();
        lstLocs = [Select Id, Name from SVMXC__Site__c where RecordType.Name = 'Depot' ORDER BY Name];
        slctLstLocs = new List<SelectOption>();
        for(SVMXC__Site__c LocationRec: lstLocs)
        {
            slctLstLocs.add(new SelectOption(LocationRec.Id, LocationRec.Name));
        } 
        if(ApexPages.currentPage().getParameters().get('SVMX_RecordID') != null)
        {
            StrRoutID = ApexPages.currentPage().getParameters().get('SVMX_RecordID');
            if(StrRoutID != null && StrRoutID.length() > 0)
                LstSVMXRoutRules = [select SVMXC__Select__c, SVMXC__Sequence__c,SVMXC__ProcessID__c,SVMXC__APL_Route_Rule_Type__c , SVMXC__Active__c, LastModifiedDate , LastModifiedBy.LastModifiedDate, SVMXC__Name__C,SVMXC__Advance_Expression__c , SVMXC__Description__c, SVMXC__IsStandard__c, RecordTypeId from  SVMXC__ServiceMax_Processes__c where  id=:StrRoutID  And SVMXC__Record_Type_Name__c ='SVMX Rule' And SVMXC__Rule_Type__c = 'Routing Rule']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          
            if(LstSVMXRoutRules != null && LstSVMXRoutRules.size() > 0)
            {
                IsRender = true;
                IsdisableValue = true;
                RoutRule = LstSVMXRoutRules[0];
                StrProcessRuleID=RoutRule.id;
                RoutTypeAction();
                String StrExpQuery = '';
                String StrLocQuery = '';
                
                /**************** Get the list of config data ( Expression ) in edit mode **********************/
                LstConfigExp.clear();
                LstConfigExp = [Select SVMXC__Location__c, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name2__c,  SVMXC__Field_Name__c,  SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c s where SVMXC__Dispatch_Process__r.Id =: StrProcessRuleID  and SVMXC__Dispatch_Process__r.SVMXC__Rule_Type__c = 'Routing Rule' and  RecordTypeId =: StrConfigExpId and SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP' ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                /****************** Populate expression data into the list of Wrapper **************************/
                if(LstConfigExp != null && LstConfigExp.size() > 0)
                {
                    ConfigExpWrapper CriWrap;
                    LstCriWrap.clear();
                    for(SVMXC__ServiceMax_Config_Data__c Temp : LstConfigExp)
                    {
                        CriWrap = new ConfigExpWrapper();
                        CriWrap.SelObj = Temp.SVMXC__Object_Name2__c;
                        if(CriWrap.SelObj != null)
                            CriWrap.ObjFlds = getAllFields(CriWrap.SelObj);
                        CriWrap.Sequence = integer.valueof(Temp.SVMXC__Sequence__c);
                        CriWrap.SelFld = Temp.SVMXC__Field_Name__c;
                        CriWrap.Operator = Temp.SVMXC__Operator__c;
                        CriWrap.Oprand = Temp.SVMXC__Operand__c;
                        CriWrap.SelObj = Temp.SVMXC__Object_Name2__c;
                        LstCriWrap.add(CriWrap) ;
                    }
                } 
                
                /**************** Get the list of config data (Location) for Edit mode **********************/
                LocConfigLst.clear();
                LocConfigLst = [Select SVMXC__Location__c, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c s where SVMXC__Dispatch_Process__r.Id =: StrProcessRuleID and SVMXC__Dispatch_Process__r.SVMXC__Rule_Type__c = 'Routing Rule' and  RecordTypeId=: StrConfigStopId ORDER BY SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            }
        }
        else
        {
            LocConfigLst.clear();
            LstCriWrap.clear();
            LocConfigLst.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = 1));
            LstTempObjFlds.add(new SelectOption('SVMX.NONE',getTAG026()));
            LstCriWrap.add(new ConfigExpWrapper(Integer.valueOf( LstCriWrap.size() + 1 ),'','',LstTempObjFlds,'',''));
        }
    }
    
    /************ Onload Method *******************/
    public void Onload()
    {
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
        
        for(Schema.SObjectType s : MapAllobjName.values())
        {
            Schema.DescribeSObjectResult objDesc = s.getDescribe();
            MapAllobj.put(objDesc.getName(),s);
        }
        LstProcessRules =  [select  SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Name__C from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='SVMX Rule' And SVMXC__Rule_Type__c = 'Routing Rule']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        MapRuleName.clear();
        for(integer j=0;j<LstProcessRules.size();j++)
        {
            if(LstProcessRules[j].SVMXC__Name__C!=null)                            
                MapRuleName.put(LstProcessRules[j].SVMXC__Name__C,j);     
        }
        
        RecordType rtSVMXRule = [Select Id, Name from RecordType WHERE SObjectType='SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType rtExpressions = [Select Id, Name from RecordType WHERE SObjectType='SVMXC__ServiceMax_Config_Data__c' AND Name = 'Expressions' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType rtRouteStop = [Select Id, Name from RecordType WHERE SObjectType='SVMXC__ServiceMax_Config_Data__c' AND Name = 'Route Stops' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(rtSVMXRule != null)
            StrSVMXRuleId = rtSVMXRule.id;
        if(rtExpressions != null)
            StrConfigExpId = rtExpressions.id;
        if(rtRouteStop != null)
            StrConfigStopId = rtRouteStop.id;
    }
    
    /************ Method to add new Route Location *******************/
    public void AddLocRow()
    {
        try
        {
            IsHdrMsg = false;
            LocConfigLst.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = Integer.valueOf(LocConfigLst.size() + 1)));
        }
        catch(Exception ex)
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    /************ Method to Delete Route Location *******************/
    public List<SVMXC__ServiceMax_Config_Data__c> deleteStopsLst=new List<SVMXC__ServiceMax_Config_Data__c>();
    public void DelLocRow()
    {
        if(StrDelIndex.length() > 0)
        {
            IntVal = integer.valueOf(StrDelIndex);
            if(LocConfigLst[IntVal - 1].Id != null)
                deleteStopsLst.add(LocConfigLst[IntVal - 1]);
            LocConfigLst.remove(IntVal - 1);
            for( integer i = IntVal; i <= LocConfigLst.size(); i++ )
                LocConfigLst[i-1].SVMXC__Sequence__c = i;
        }
    }
 
    /************ Method to add new expression *******************/
    public void ADDCriRow()
    {
        try
        {
            LstTempObjFlds.clear();
            IsExpMsg = false;
            LstTempObjFlds.add(new SelectOption('SVMX.NONE',getTAG026()));
            if( LstCriWrap != null && LstCriWrap.size() > 0 )
                LstCriWrap.add(new ConfigExpWrapper(Integer.valueOf( LstCriWrap.size() + 1 ),'','',LstTempObjFlds,'',''));
            else
                LstCriWrap.add(new ConfigExpWrapper(1,'','',LstTempObjFlds,'',''));
        }
        catch(exception ex) 
        {
            IsExpMsg = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        } 
    }
    
    /************************* Method to delete Expression ***************************************/
    public void DelCriRow()
    { 
        if(StrDelIndex.length() > 0)
        {
            IntVal = integer.valueOf(StrDelIndex);
            LstCriWrap.remove(IntVal - 1);
            for( integer i = IntVal; i <= LstCriWrap.size(); i++ )
                LstCriWrap[i-1].Sequence = i;
        }
    }
    
    /*********************** BackToSetupHome ***********************/
    public PageReference BackToSetupHome() 
    {
        PageReference pRef = new PageReference('/apex/CONF_SetupHome');  
        return pRef;
    }
    
    /*********************** Method to get all fields of selected object ***********************/
    public pagereference RoutTypeAction()
    {
        String RouteType = RoutRule.SVMXC__APL_Route_Rule_Type__c;
        if(RouteType == null || RouteType == '' ||RouteType == 'SVMX.NONE' || RouteType ==getTAG026())
        {
            IsRender = false;
            ObjectLst.clear();
            return null;
        }
        IsRender = true;
        IsdisableValue = true;
        ObjectLst.clear();
        ObjectLst.add(new SelectOption('SVMX.NONE',getTAG026()));
        ObjectLst.add(new SelectOption('Account', Account.SObjectType.getDescribe().getLabel()));
        if(RouteType.equalsIgnoreCase('Inbound'))
        {
            ObjectLst.add(new SelectOption('Case', Case.SObjectType.getDescribe().getLabel()));
            ObjectLst.add(new SelectOption('SVMXC__Case_Line__c', SVMXC__Case_Line__c.SObjectType.getDescribe().getLabel()));
        }
        ObjectLst.add(new SelectOption('Product2', Product2.SObjectType.getDescribe().getLabel()));
        if(RouteType.equalsIgnoreCase('Outbound'))
            ObjectLst.add(new SelectOption('SVMXC__Site__c', SVMXC__Site__c.SObjectType.getDescribe().getLabel()));
        
        return null;
    }
    
    /*********************** Method to get all fields of selected object ***********************/
    public pagereference ObjectFields()
    {
        if(IntIndex != 0)
        {
            IntVal = integer.valueOf(IntIndex);
            IntVal = IntVal-1;
            string ObjName = LstCriWrap[IntVal].SelObj;
            if(LstCriWrap[IntVal].ObjFlds != null )
                LstCriWrap[IntVal].ObjFlds.clear();
            if(LstCriWrap[IntVal].SelObj != null && LstCriWrap[IntVal].SelObj != getTAG026() && LstCriWrap[IntVal].SelObj != 'SVMX.NONE')
                LstCriWrap[IntVal].ObjFlds = getAllFields(ObjName);
            else if(LstCriWrap[IntVal].SelObj != getTAG026() || LstCriWrap[IntVal].SelObj != 'SVMX.NONE')
                LstCriWrap[IntVal].ObjFlds.add(new SelectOption('SVMX.NONE',getTAG026()));
        } 
        return null;
    }
    
    /************ Method to retrieve all fields of given object ***************/
    public List<SelectOption> getAllFields(string ObjName)
    {
        List<SelectOption> TempObjFields = new  List<SelectOption>();
        TempObjFields.add(new SelectOption('SVMX.NONE',getTAG026()));
        if( ObjName != null && ObjName.length() > 0 && ObjName != getTAG026() && ObjName != 'SVMX.NONE')
        {
            SFM_WrapperDef.SFM_Request SFMReq = new SFM_WrapperDef.SFM_Request();
            List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
            lstStringMap.add(new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE', 'EXPRESSION'));
            lstStringMap.add(new SFM_WrapperDef.SFM_StringMap('OBJECTNAME', ObjName));
            SFMReq.stringMap = lstStringMap;
            SFM_GetObjectFieldList ObjToGetFields = new SFM_GetObjectFieldList();
            SFM_WrapperDef.SFM_Response_ObjectFields responseObjFields = ObjToGetFields.getObjectFieldList(SFMReq);
            List<SFM_WrapperDef.fieldProperties> fieldProp = new List<SFM_WrapperDef.fieldProperties>();
            if(responseObjFields.response.success)
                fieldProp = responseObjFields.fields;
            for(SFM_WrapperDef.fieldProperties fp : fieldProp)
                TempObjFields.add(new SelectOption(fp.key, fp.value));
            List<SelectOption> resultList = new List<SelectOption>();
            TempObjFields = sortingSelectOption(TempObjFields);    
        }
        return TempObjFields;
    }
   
    /************** Method to sort the list of SelectOption **********************/
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
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    } 
   
   /*********************** Method for Validation ***********************/
    public Boolean IsValidProcess=true; 
    public Boolean IsValidProcess()
    {
        IsValidProcess=true; 
        if(RoutRule.SVMXC__Name__c == null)
        {
            IsValidProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG025() ));
        }
        
        if(RoutRule.SVMXC__APL_Route_Rule_Type__c == null || RoutRule.SVMXC__APL_Route_Rule_Type__c == getTAG026() || RoutRule.SVMXC__APL_Route_Rule_Type__c == 'SVMX.NONE')
        {
            IsValidProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG023() ));
        }
        
        if(LocConfigLst.size() < 1)
        {
            IsValidProcess=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG022()));
        }
        else if(LocConfigLst.size() > 0)
        {
            for(Integer i=0; i < LocConfigLst.size(); i++)
            {
                if(LocConfigLst[i].SVMXC__Location__c != null)
                    break;
                else
                {
                    IsValidProcess=false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021()));
                }
            }
        }
        return IsValidProcess;
    }
    
    /**************** Method to validate Advanced expression ******************/
    public Boolean IsValidExp()
    {
        boolean IsValidExp = true;
        SVMXC__ServiceMax_Config_Data__c TempConfigDataExp;
        List<SVMXC__ServiceMax_Config_Data__c> lstExpressions = new List<SVMXC__ServiceMax_Config_Data__c>();
        StrObjectName = 'SVMXC__Service_Order__c';
        StrAdvanceExp = RoutRule.SVMXC__Advance_Expression__c;
        SVMXC__ServiceMax_Config_Data__c TempExp;
        
        //Config Data for validate expression
        List<SVMXC__ServiceMax_Config_Data__c> ConfigLstForLoc = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigLstForAcc = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigLstForProd = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigLstForCase = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigLstForCaseLine = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        //Process Data for validate expression
        SVMXC__ServiceMax_Processes__c ProcessObjForLoc = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Site__c');
        SVMXC__ServiceMax_Processes__c ProcessObjForAcc = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'Account');
        SVMXC__ServiceMax_Processes__c ProcessObjForProd = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'Product2');
        SVMXC__ServiceMax_Processes__c ProcessObjForCase = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'Case');
        SVMXC__ServiceMax_Processes__c ProcessObjForCaseLine = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__Case_Line__c');

        for(integer i=0; i<LstCriWrap.size();i++)
        {
            TempExp = new SVMXC__ServiceMax_Config_Data__c();
            TempExp.SVMXC__Field_Name__c = 'SVMXC__City__c';
            TempExp.SVMXC__Operator__c = 'eq';
            TempExp.SVMXC__Operand__c = 'Bangalore';
            lstExpressions.add(TempExp);
            
            TempConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();
            TempConfigDataExp.SVMXC__Sequence__c = LstCriWrap[i].Sequence;
            TempConfigDataExp.SVMXC__Field_Name__c = LstCriWrap[i].SelFld;
            TempConfigDataExp.SVMXC__Operator__c = LstCriWrap[i].Operator;
            TempConfigDataExp.SVMXC__Operand__c = LstCriWrap[i].Oprand;
            TempConfigDataExp.SVMXC__Object_Name2__c = LstCriWrap[i].SelObj;
            TempConfigDataExp.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
            TempConfigDataExp.RecordTypeId = StrConfigExpId;
            
            if(LstCriWrap[i].SelObj == 'SVMXC__Site__c')
                ConfigLstForLoc.add(TempConfigDataExp);
            else if(LstCriWrap[i].SelObj == 'Account')
                ConfigLstForAcc.add(TempConfigDataExp);
            else if(LstCriWrap[i].SelObj == 'Product2')
                ConfigLstForProd.add(TempConfigDataExp);
            else if(LstCriWrap[i].SelObj == 'Case')
                ConfigLstForCase.add(TempConfigDataExp);
            else if(LstCriWrap[i].SelObj == 'SVMXC__Case_Line__c')
                ConfigLstForCaseline.add(TempConfigDataExp);
        }
        
        boolean IsValidLocLst = true;
        boolean IsValidAccLst = true;
        boolean IsValidProdLst = true;
        boolean IsValidCaseLst = true;
        boolean IsValidCaseLineLst = true;
        if(ConfigLstForLoc != null && ConfigLstForLoc.size() >0)
            IsValidLocLst = submitExp(ProcessObjForLoc,ConfigLstForLoc);
        if(ConfigLstForAcc != null && ConfigLstForAcc.size() >0)
            IsValidAccLst = submitExp(ProcessObjForAcc,ConfigLstForAcc);
        if(ConfigLstForProd != null && ConfigLstForProd.size() >0)
            IsValidProdLst = submitExp(ProcessObjForProd,ConfigLstForProd);
        
        if(ConfigLstForCase != null && ConfigLstForCase.size() >0)
            IsValidCaseLst = submitExp(ProcessObjForCase,ConfigLstForCase);
        if(ConfigLstForCaseline != null && ConfigLstForCaseline.size() >0)
            IsValidCaseLineLst = submitExp(ProcessObjForCaseLine,ConfigLstForCaseline);
        
        system.debug(' IsValidLocLst: '+ IsValidLocLst +', IsValidAccLst'+IsValidAccLst +', IsValidProdLst'+ IsValidProdLst);
        system.debug(' IsValidCaseLst: '+ IsValidCaseLst +', IsValidCaseLineLst' + IsValidCaseLineLst);
        
        if(StrObjectName != null && StrAdvanceExp != null)
            IsValidExp = ValidateAdvancedExp(StrObjectName,StrAdvanceExp ,lstExpressions);
        if(IsValidExp && IsValidLocLst && IsValidAccLst && IsValidProdLst && IsValidCaseLst && IsValidCaseLineLst)
            return true;
        else
        {
            IsHdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG020()));
            return false;
        }
    }
    
    /************ Quick save Method *******************/
    public boolean IsQuickSaveCall = false;
    public boolean IsError = false;
    public PageReference QuickSaveRules() 
    {
        IsError = false;
        IsQuickSaveCall = true;
        SaveCloseRules(); 
        IsQuickSaveCall = false;
        IsHdrMsg = true;
        if(!IsError)
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG019()));
        return null;
    }
    
    /************ save Method *******************/
    public PageReference SaveCloseRules() 
    {
        string StrRuleID ='';
        Savepoint sp;       
        sp=Database.setSavepoint();
        IsHdrMsg = false;
        IsError = false;
        PageReference pRef = new PageReference('/apex/CONF_ManageRoutingRules');   
        List<SVMXC__ServiceMax_Processes__c> RuleLst = new List<SVMXC__ServiceMax_Processes__c>();
        if(IsValidProcess() && IsValidExp())
        {
            try
            {
                if(deleteStopsLst != null && deleteStopsLst.size() > 0)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXDEV__ServiceMax_Config_Data__c' ) ) {
                        
                        delete deleteStopsLst; //SDL-SVMX-DELETE-FLS-ENFORCED
                        deleteStopsLst.clear();
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        Database.rollback(sp);
                        IsHdrMsg = true;
                        IsError = true;
                    }
                }
                RuleLst =  [select  SVMXC__Sequence__c  from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='SVMX Rule' And SVMXC__Rule_Type__c = 'Routing Rule']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(StrMode != null && StrMode == 'Clone' && StrRoutID != null && StrRoutID.length() > 0 )
                {
                    SVMXC__ServiceMax_Processes__c CloneProcess = new SVMXC__ServiceMax_Processes__c();
                    CloneProcess.SVMXC__Name__c = RoutRule.SVMXC__Name__c;
                    if(CloneProcess.SVMXC__Sequence__c == null)
                        CloneProcess.SVMXC__Sequence__c = RuleLst.size()+1;
                    CloneProcess.SVMXC__Description__c = RoutRule.SVMXC__Description__c;
                    CloneProcess.SVMXC__APL_Route_Rule_Type__c = RoutRule.SVMXC__APL_Route_Rule_Type__c;
                    CloneProcess.SVMXC__Advance_Expression__c = RoutRule.SVMXC__Advance_Expression__c;
                    CloneProcess.SVMXC__Active__c = RoutRule.SVMXC__Active__c;
                    CloneProcess.SVMXC__Rule_Type__c = 'Routing Rule';
                    CloneProcess.RecordTypeId = StrSVMXRuleId;
                    //upsert CloneProcess;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( CloneProcess, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert CloneProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        Database.rollback(sp);
                        IsHdrMsg = true;
                        IsError = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    StrRuleID = CloneProcess.Id;
                    RoutRule = new SVMXC__ServiceMax_Processes__c();
                    RoutRule = CloneProcess;
                    if(LocConfigLst != null && LocConfigLst.size() > 0)
                    {
                        list<SVMXC__ServiceMax_Config_Data__c> CloneConfigdataLst = new list<SVMXC__ServiceMax_Config_Data__c>();
                        SVMXC__ServiceMax_Config_Data__c CloneConfigdata;
                        for(integer i=0; i < LocConfigLst.size();i++)
                        {
                            CloneConfigdata = new SVMXC__ServiceMax_Config_Data__c();
                            CloneConfigdata.SVMXC__Sequence__c = LocConfigLst[i].SVMXC__Sequence__c;
                            CloneConfigdata.SVMXC__Location__c = LocConfigLst[i].SVMXC__Location__c;
                            CloneConfigdata.SVMXC__Dispatch_Process__c = StrRuleID;
                            CloneConfigdata.RecordTypeId = StrConfigStopId;
                            CloneConfigdataLst.add(CloneConfigdata);
                        } 
                        LocConfigLst.clear();
                        LocConfigLst.addAll(CloneConfigdataLst);
                        //upsert LocConfigLst;
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( LocConfigLst, COMM_SecurityUtils.Access.Upsertable ) ) {
                            upsert LocConfigLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } else {
                            Database.rollback(sp);
                            IsHdrMsg = true;
                            IsError = true;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                            return null;
                        }
                        StrMode = 'Edit';
                    } 
                }
                else
                {
                    if(RoutRule.SVMXC__Sequence__c == null)
                        RoutRule.SVMXC__Sequence__c = RuleLst.size()+1;
                    RoutRule.RecordTypeId = StrSVMXRuleId;
                    RoutRule.SVMXC__Rule_Type__c = 'Routing Rule';
                    //upsert RoutRule;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( RoutRule, COMM_SecurityUtils.Access.Upsertable ) ) {
                        upsert RoutRule; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        Database.rollback(sp);
                        IsHdrMsg = true;
                        IsError = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    LstProcessRules.add(RoutRule);
                    StrRuleID = RoutRule.Id;
                    if(LocConfigLst != null && LocConfigLst.size() > 0)
                    {
                        for(integer i=0; i < LocConfigLst.size();i++)
                        {
                           LocConfigLst[i].SVMXC__Dispatch_Process__c = RoutRule.Id;
                           LocConfigLst[i].RecordTypeId = StrConfigStopId;
                        } 
                        //upsert LocConfigLst;
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( LocConfigLst, COMM_SecurityUtils.Access.Upsertable ) ) {
                            upsert LocConfigLst; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } else {
                            Database.rollback(sp);
                            IsHdrMsg = true;
                            IsError = true;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                            return null;
                        }
                    }
                }
                /******************* Code for config data expresssion ********************************/
                SVMXC__ServiceMax_Config_Data__c ConfigDataExp;
                string StrExp = null;
                if((LstCriWrap != null && LstCriWrap.size() > 0) || StrMode != 'New' )
                {
                    LstConfigExp = [Select SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__RecordType_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name2__c,  SVMXC__Field_Name__c,  SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__r.Id =: StrRuleID  and SVMXC__Dispatch_Process__r.SVMXC__Rule_Type__c = 'Routing Rule' and  RecordTypeId =: StrConfigExpId and SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP' ORDER By SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    if(LstConfigExp != null && LstConfigExp.size() >0)
                        delete LstConfigExp; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    List<SVMXC__ServiceMax_Config_Data__c> ConfExpLst1 = new List<SVMXC__ServiceMax_Config_Data__c>();
                    if(LstCriWrap != null && LstCriWrap.size() >0)
                    {
                        for(integer i=0; i<LstCriWrap.size();i++)
                        {
                            ConfigDataExp = new SVMXC__ServiceMax_Config_Data__c();
                            if(LstCriWrap[i].SelObj != 'SVMX.NONE' && LstCriWrap[i].SelFld != 'SVMX.NONE' && LstCriWrap[i].Operator != 'SVMX.NONE')
                            {
                                ConfigDataExp.SVMXC__Sequence__c = LstCriWrap[i].Sequence;
                                ConfigDataExp.SVMXC__Field_Name__c = LstCriWrap[i].SelFld;
                                ConfigDataExp.SVMXC__Operator__c = LstCriWrap[i].Operator;
                                ConfigDataExp.SVMXC__Operand__c = LstCriWrap[i].Oprand;
                                ConfigDataExp.SVMXC__Object_Name2__c = LstCriWrap[i].SelObj;
                                ConfigDataExp.SVMXC__Dispatch_Process__c = RoutRule.Id;
                                ConfigDataExp.SVMXC__Expression_Type__c = 'ROUTE_RULE_EXP';
                                ConfigDataExp.RecordTypeId = StrConfigExpId;
                                ConfExpLst1.add(ConfigDataExp);
                            }
                        }
                        if(ConfExpLst1 != null && ConfExpLst1.size() > 0)
                        {
                            APL_Utils UtilsObj = new APL_Utils();
                            upsert UtilsObj.PopulateInfoForReferenceFields( ConfExpLst1);
                            
                            List<SVMXC__Site__c> lstLocs = new List<SVMXC__Site__c>();
                            lstLocs = [Select Id, Name from SVMXC__Site__c where RecordType.Name = 'Depot' ORDER BY Name];
                            slctLstLocs = new List<SelectOption>();
                            for(SVMXC__Site__c LocationRec: lstLocs)
                            {
                                slctLstLocs.add(new SelectOption(LocationRec.Id, LocationRec.Name));
                            }
                            pRef.setRedirect(true);
                        }
                    }
                }
            }
            catch(exception ex)
            {
                Database.rollback(sp);
                IsHdrMsg = true;
                IsError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                return null;
            }
        }
        else
        {
            IsHdrMsg = true;
            IsError = true;
            return null;
        }
        if(IsQuickSaveCall == true)
            return null;
        else
            return pRef;
    }
    
    public PageReference CancelRules()  
    {
        PageReference pRef = new PageReference('/apex/CONF_ManageRoutingRules');  
        pRef.setRedirect(true);
        return pRef;
    }
    
    /*************************** SaveExpression *********************************/
    public boolean submitExp(SVMXC__ServiceMax_Processes__c ProcessObj, List<SVMXC__ServiceMax_Config_Data__c> ExpConfigDataLst)
    {
        SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ProcessObj,ExpConfigDataLst);
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
        LstSFM_Exp.add(oSFM_Exp);
        SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
        Save_Response = ValidateExp.SFM_validateExpression(oRequest);
        system.debug('SFMTEST1'+Save_Response);
        if( Save_Response.success != null && Boolean.valueOf(Save_Response.success))
            return true;
        else
            return false;
    }
    /*************************** SaveExpression *********************************/
    
    
    /**************************** Validate Advanced Expression **************************************/
    public boolean ValidateAdvancedExp( string StrObjectName, String StrAdvanceExp, List<SVMXC__ServiceMax_Config_Data__c> lstExpressions)
    {   
        String AdvanceOption = '';
        AdvanceOption = StrAdvanceExp;
        string strCriteria = '';
        strCriteria = AdvanceOption.toUpperCase();
        strCriteria = string.escapeSingleQuotes(strCriteria);
        if (!(lstExpressions.size() > 0))
            return true;
        for(integer i=0; i < (lstExpressions.size()+5); i++)
        {
            strCriteria = strCriteria.replace(string.valueOf(i),' ~'+i+'~ ');
        }
        
        for(integer i=0;i<lstExpressions.size();i++)
        {
            if (lstExpressions[i].SVMXC__Field_Name__c <> '' || lstExpressions[i].SVMXC__Operator__c <> '')
            {
                string s = ValidateExp.buildWhereClause(false, lstExpressions[i]);
                if (s <> null && s.length() > 0)
                    strCriteria = strCriteria.replace('~'+(i+1)+'~', s);
                else
                    break;
            }
        }
        string strCriteria2;
        Boolean IsCriteriaError = false;
        try
        {
            if (strCriteria  <> null && strCriteria.length() > 0)
            {
                IsCriteriaError = true;
                strCriteria2 = strCriteria.replace('SVMX.CURRENTUSER',  UserInfo.getUserId() );
                strCriteria2 = strCriteria2.replace('SVMX.OWNER',  UserInfo.getUserId() );
                strCriteria2 = strCriteria2.replace('SVMX.Now', 'TODAY');
                strCriteria2 = strCriteria2.replace('SVMX.NOW', 'TODAY');
                list<sObject> lstTemp = database.query('select id from '+ StrObjectName +' where ' + strCriteria2 + ' limit 0');
            }
        }
        catch(Exception ex)
        {
            system.debug('ErrorTest'+ex.getMessage());
            return false;
        }
        system.debug('FinalResult'+strCriteria);
        return true;
    }
    /**************************** Validate Advanced Expression end**************************************/
    
    /********************** Expresion Wrapper **********************************/
    public class ConfigExpWrapper
    {
        /********* All getter setter of wrapper class ***********/
        public Integer Sequence;
        public Integer getSequence(){return Sequence;}
        public void setSequence(Integer i){this.Sequence = i;}
        
        public string SelObj = '';
        public string getSelObj() { return SelObj;}
        public void setSelObj(string strObj){this.SelObj = strObj;}
        
        public string SelFld = '';
        public string getSelFld() { return SelFld;}
        public void setSelFld(string strFld){this.SelFld = strFld;}
        
        public List<SelectOption> ObjFlds = new List<SelectOption>();
        public List<SelectOption> getObjFlds(){return ObjFlds;}
        public void setObjFlds(List<SelectOption> SelOpt){this.ObjFlds = SelOpt;}
        
        public string Operator = '';
        public string getOperator(){return Operator;}
        public void setOperator(string Operator){this.Operator = Operator;}
        
        public string Oprand = '';
        public string getOprand() { return Oprand;}
        public void setOprand(string strOp){this.Oprand = strOp;}
                        
        /*********** Constructor ******************/
        public ConfigExpWrapper()
        {}
        public ConfigExpWrapper(Integer iSeq, string SelObj, string SelFld, List<SelectOption> ObjFlds, string Operator, string Oprand )
        {
            this.Sequence = iSeq;
            this.SelObj = SelObj;
            this.SelFld = SelFld;
            this.ObjFlds = ObjFlds;
            this.Operator = Operator;
            this.Oprand = Oprand;
        }
    }
    
    /***********************Tags methods ***********************/
    public String getTAG001(){return System.Label.CONF022_TAG022;}  // 'Setup Routing Rules'
    public String getTAG002(){return System.Label.CONF022_TAG023;}  // 'Quick Save'
    public String getTAG003(){return System.Label.CONF022_TAG024;}  // 'Save and Close'
    public String getTAG004(){return System.Label.CONF022_TAG025;}  // 'Cancel'
    public String getTAG005(){return System.Label.CONF022_TAG026;}  // 'Rule Type'
    public String getTAG006(){return System.Label.CONF022_TAG027;}  // 'Route Stops'
    public String getTAG007(){return System.Label.CONF022_TAG028;}  // 'General Information'
    public String getTAG008(){return System.Label.CONF022_TAG029;}  // 'Rule Title'  .........................................
    public String getTAG009(){return System.Label.CONF022_TAG009;}  // 'Processing...'
    public String getTAG010(){return System.Label.CONF022_TAG030;}  // 'Description'
    public String getTAG011(){return System.Label.CONF022_TAG031;}  // 'Stops' 
    public String getTAG012(){return System.Label.CONF022_TAG032;}  // 'Location'
    public String getTAG013(){return System.Label.CONF022_TAG033;}  // 'Use the expression-builder below to indicate when this route should be considered'
    public String getTAG014(){return System.Label.CONF022_TAG034;}  // 'Object'
    public String getTAG015(){return System.Label.CONF022_TAG035;}  // 'Field Name'
    public String getTAG016(){return System.Label.CONF022_TAG036;}  // 'Operator'
    public String getTAG017(){return System.Label.CONF022_TAG037;}  // 'Value'
    public String getTAG018(){return System.Label.CONF022_TAG038;}  // 'Advanced Expression.'
    public String getTAG019(){return System.Label.CONF022_TAG039;}  // 'Rule saved.'
    public String getTAG020(){return System.Label.CONF022_TAG040;}  // 'Invalid expression.'
    public String getTAG021(){return System.Label.CONF022_TAG041;}  // 'Please choose a location.'
    public String getTAG022(){return System.Label.CONF022_TAG042;}  // 'A route must have at least one location.'
    public String getTAG023(){return System.Label.CONF022_TAG043;}  // 'Please select rule type.'
    public String getTAG024(){return System.Label.CONF022_TAG044;}  // 'Duplicate Rule name.'
    public String getTAG025(){return System.Label.CONF022_TAG045;}  // 'Please enter a valid rule name.'
    public String getTAG026(){return System.Label.CONF022_TAG046;}  //'--None--'
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
    public String getTAG040(){return System.Label.CONF022_TAG047;}  // 'Active'
    //public String getTAG041(){return System.Label.CONF022_TAG048;}  // 'Account'
    //public String getTAG042(){return System.Label.CONF022_TAG049;}  // 'Product'
    //public String getTAG043(){return System.Label.CONF022_TAG050;}  // 'Location'
    public String getTAG044(){return System.Label.COMM002_TAG033;}  // 'Add'
    public String getTAG045(){return System.Label.COMM002_TAG032;}  // 'Delete'
    public string getHLPURL() {return system.label.CONF022_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
}