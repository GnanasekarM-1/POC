/* Security Scanned */
public with sharing class WORD_SetupEventSubjectRules 
{
    //Global variables declerations..
    public Boolean HdrMsg = false;
    public Boolean WOMsg = false;
    public Boolean DisbaleChkBox = false;
    public Boolean DisbaleActiveChkBox = false;
    public Boolean CheckAllRules=false;
    public Boolean DisbleNewBttn = false;
    public Boolean DisbleEdtBttn = false;
    public Boolean DisbleDelBttn = false;
    public Boolean DisbleSaveBttn = true;
    public Boolean DisableCancelBttn = true;
    public Boolean DisbleRuleSeqBttn = false;
    String RuleId;
    public string SelectedIndex;
    public Boolean disableValue = false;
    public Boolean ShowExp = false;
    public String RuleRecordTypeId;
    public String ExpressionRTypeId;
    public String FieldMapRTypeId;
    public Integer MaxSequence = 0;
    public List<RecordType> RecordTypes = new List<RecordType>();
    public List<SVMXC__ServiceMax_Processes__c> RuleList = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> TempRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> RuleExpression = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> WOFldLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>();
    public Map<String,SObjectType> allObjs = new Map<String,SObjectType>();
    public Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>(); 
    public Map <string, Map<String,Schema.SObjectField>> mMapFieldList = new Map<string, Map<String,Schema.SObjectField>> ();
    public Map<String,string> AvaliableWOfieldMap = new Map<String,string>();
    public Map<String,string> WOfieldMap = new Map<String,string>();
    public transient List<AggregateResult> Aggresult = new List<AggregateResult>();
    public boolean IsEnterpriseLicense = false;
    public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    // public SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('');
    
    /*public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('WORD016');*/ //commented by amar on 31/05/10(coz no setting for this submodule)
    
    public COMM_SVMXC_Search_Expressions CriExpressions = new COMM_SVMXC_Search_Expressions(2);
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    //Constructor
    public WORD_SetupEventSubjectRules()
    {
         //Added by amar on 19/Aug/10 Due to OEM Exercises
        IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
        if(!IsEnterpriseLicense)
        {
             PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
        }
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordTypes = Database.query('Select r.Name, r.Id From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\' OR SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'SVMX Rule')
            {
              RuleRecordTypeId = r.id;
            }
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
            if(r.Name == 'Field Mapping')
            {
                FieldMapRTypeId = r.id;
            } 
        }
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RuleList = Database.query('Select s.SVMXC__Select__c, s.SVMXC__Name__c,  s.SVMXC__Description__c, s.SVMXC__Advance_Expression__c,  s.RecordTypeId, s.Name, s.Id From SVMXC__ServiceMax_Processes__c s where RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Event Subject Rule\' order by SVMXC__Sequence__c');
        if(RuleList.size() <= 1)
            DisbleRuleSeqBttn = true;
        if(RuleList.size() == 0)
            DisbleEdtBttn = true;   
        if(RuleList.size() == 0)
            DisbleDelBttn = true;   
        gd = Schema.getGlobalDescribe(); 
        for(Schema.SObjectType lON : gd.values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            if(D.getName() == 'SVMXC__Service_Order__c')
            allObjs.put(D.getName(), lON);
        }
    gd.clear(); //Added for 43301 fix
        AvaliableWOfieldMap.clear();
        CriExpressions = new COMM_SVMXC_Search_Expressions(2,true,true,true,false,true,'','');
        CriExpressions.DefaultField = getTAG019();
        CriExpressions.DefaultOperator = getTAG019();
        CriExpressions.DefaultListValue = getTAG019();
        CriExpressions.ExpressionType = 'CRITERIA';
        ClearSelOptList(Hdrfldlist);
        RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CriExpressions.mapFieldDispType, CriExpressions.FieldApiLable);
        CriExpressions.FieldsList = Hdrfldlist;
        CriExpressions.objfieldMap = mMapFieldList.get('SVMXC__Service_Order__c');
        AvaliableWOfieldMap = CriExpressions.FieldApiLable.clone();
    }
    //Getter & Setter Methods..
    public COMM_SVMXC_Search_Expressions getCriExpressions() {return CriExpressions;}
    public void ClearSelOptList(List<SelectOption> lst){lst.clear();}
    public List<selectoption> Hdrfldlist = new List<selectoption>(); //list of fields values
    public List<selectoption> getHdrFldlist() {return sortingSelectOption(Hdrfldlist, true);}
    
    public Boolean getHdrMsg(){return HdrMsg;}
    public Boolean getWOMsg(){return WOMsg;}
    
    public boolean getDisbaleChkBox(){return DisbaleChkBox;} 
    public void setDisbaleChkBox(boolean b){ this.DisbaleChkBox = b; }
    
    public boolean getDisbaleActiveChkBox(){ return DisbaleActiveChkBox; }
    public void setDisbaleActiveChkBox(boolean b){ this.DisbaleActiveChkBox = b; }
    
    public Boolean getCheckAllRules() {return CheckAllRules;  }
    public void setCheckAllRules(Boolean chkAll){CheckAllRules=chkAll;} 
    
    public List<SVMXC__ServiceMax_Processes__c> getRuleList(){return RuleList;}
    public void setRuleList(List<SVMXC__ServiceMax_Processes__c> R){RuleList = R;}
    
    public boolean getDisbleNewBttn(){return DisbleNewBttn;}
    public void setDisbleNewBttn(boolean b){ this.DisbleNewBttn = b; }
    public boolean getDisbleEdtBttn(){return DisbleEdtBttn;}
    public void setDisbleEdtBttn(boolean b){ this.DisbleEdtBttn = b; }
    public boolean getDisbleDelBttn() {return DisbleDelBttn;}
    public void setDisbleDelBttn(boolean b){ this.DisbleDelBttn = b; }
    public boolean getDisbleSaveBttn(){ return DisbleSaveBttn; }
    public void setDisbleSaveBttn(boolean b){ this.DisbleSaveBttn = b; }
    public boolean getDisbleRuleSeqBttn(){return DisbleRuleSeqBttn; }
    public void setDisbleRuleSeqBttn(boolean b){ this.DisbleRuleSeqBttn = b; }
    public boolean getDisableCancelBttn(){ return DisableCancelBttn; }
    public void setDisableCancelBttn(boolean b){ this.DisableCancelBttn = b; }
    public string getSelectedIndex (){return this.SelectedIndex;}
    public void setSelectedIndex (string str){this.SelectedIndex = str;}
    public Boolean getShowExp(){return ShowExp;}
    public Boolean getDisableValue(){return disableValue;}
    public void HdrADDRow(){ CriExpressions.addCriteriaExpression(1);}
    public void HdrDeleteRow(){ CriExpressions.removeCriteriaExpression(integer.valueOf(SelectedIndex));}
    
    //Validation Rule..
    public Boolean SVMX_ValidRule = true;
    public Boolean SVMX_ValidRule()
    {
        List<Integer> selectedLines = new List<Integer>();
        for(Integer i = 0; i < RuleList.size(); i++)
        {
            if(RuleList[i].SVMXC__Select__c == true)
            {
                selectedLines.add(i);
            }   
        }
        if(selectedLines.size() == 0)
        {
            SVMX_ValidRule = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021()));
        }
        if(selectedLines.size() > 1)
        {
            for(Integer j = 0; j < RuleList.size(); j++)
            {
                RuleList[j].SVMXC__Select__c = False;
            }
            SVMX_ValidRule = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG022()));
        }
        return SVMX_ValidRule;
    }
    
    //Buttons Methods..
    public pagereference SVMX_NewRule()
    {
        WOfilds.clear();
        WOfieldMap.clear();
        for(Integer i = 0; i < RuleList.size(); i++)
        {
            if(RuleList[i].SVMXC__Select__c == true)
            {
                RuleList[i].SVMXC__Select__c = false;
            }   
        }
        SVMXC__ServiceMax_Processes__c newRule = new SVMXC__ServiceMax_Processes__c(SVMXC__Select__c = true);
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Aggresult = [select max(SVMXC__Sequence__c) from SVMXC__ServiceMax_Processes__c s where RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c ='Event Subject Rule'];
        if(Aggresult.size() > 0)
        {
            for (AggregateResult ar : Aggresult) 
            {
                String s;
                object Obj = ar.get('expr0');
                if(Obj != null)
                    s = string.valueOf(Obj);
                if(s != null && s.length() > 0)
                {
                    s = s.replace('.','_');
                    List<String> s1 = new List<String>(); 
                    s1  = s.split('_',2);
                    s = s1[0];
                    MaxSequence = integer.valueOf(s);
                }   
            }
            if(newRule.id == null && MaxSequence != null)
            {
                newRule.SVMXC__Sequence__c = MaxSequence + 1;
            }
        }     
        RuleList.add(newRule);
        AvaliableWOfieldMap.clear();
        CriExpressions = new COMM_SVMXC_Search_Expressions(2,true,true,true,false,true,'','');
        CriExpressions.DefaultField = getTAG019();
        CriExpressions.DefaultOperator = getTAG019();
        CriExpressions.DefaultListValue = getTAG019();
        CriExpressions.ExpressionType = 'CRITERIA';
        ClearSelOptList(Hdrfldlist);
        RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CriExpressions.mapFieldDispType, CriExpressions.FieldApiLable);
        CriExpressions.FieldsList = Hdrfldlist;
        CriExpressions.objfieldMap = mMapFieldList.get('SVMXC__Service_Order__c');
        AvaliableWOfieldMap = CriExpressions.FieldApiLable.clone();
        DisbleNewBttn = true;
        DisbleEdtBttn = true;
        DisbleSaveBttn = false;
        DisableCancelBttn = false;
        DisbleDelBttn = true;
        DisbleRuleSeqBttn = true;
        DisbaleChkBox=true;
        ShowExp = true;
        return null;
    }
    public pagereference SVMX_EditRule()
    {
        HdrMsg = false;
        String SelectedRuleId = '';
        String AdvanceOption;
        WOFldLst.clear();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(SVMX_ValidRule() == true)
        {
            for(SVMXC__ServiceMax_Processes__c rule : RuleList)
            {
                if(rule.SVMXC__Select__c == true)
                {
                     RuleId=rule.id;
                    SelectedRuleId = rule.id;
                    if(rule.SVMXC__Advance_Expression__c != null)
                        AdvanceOption = rule.SVMXC__Advance_Expression__c;
                }   
            }
            RuleExpression.clear();
            CriExpressions.lstExpressions.clear();
            if(SelectedRuleId != null && SelectedRuleId.length() > 0)
            {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                RuleExpression = Database.Query('Select s.SVMXC__Sequence__c, s.SVMXC__Operator__c, s.SVMXC__Operand__c, s.SVMXC__Object_Name__c, s.SVMXC__Lookup_Field_API_Name__c, s.SVMXC__Field_Name__c, s.SVMXC__FKey_Name_Field__c, s.Name, s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c = \''+SelectedRuleId+'\' and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Event_Subject_Rule\'');
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                WOFldLst = Database.Query('Select s.SVMXC__Target_Field_Name__c, s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c = \''+SelectedRuleId+'\' and RecordTypeId = \''+FieldMapRTypeId+'\'order by SVMXC__Sequence__c');
            }
            if(RuleExpression.size() == 0 )
            {
                AvaliableWOfieldMap.clear();
                CriExpressions = new COMM_SVMXC_Search_Expressions(2,true,true,true,false,true,'','');
                CriExpressions.DefaultField = getTAG019();
                CriExpressions.DefaultOperator = getTAG019();
                CriExpressions.DefaultListValue = getTAG019();
                CriExpressions.ExpressionType = 'CRITERIA';
                ClearSelOptList(Hdrfldlist);
                RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CriExpressions.mapFieldDispType, CriExpressions.FieldApiLable);
                CriExpressions.FieldsList = Hdrfldlist;
                CriExpressions.objfieldMap = mMapFieldList.get('SVMXC__Service_Order__c');
                AvaliableWOfieldMap = CriExpressions.FieldApiLable.clone();
            }
            if(RuleExpression != null && RuleExpression.size() > 0)
            {
                AvaliableWOfieldMap.clear();
                CriExpressions = new COMM_SVMXC_Search_Expressions(2,true,true,true,false,true,'','');
                RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CriExpressions.mapFieldDispType, CriExpressions.FieldApiLable);
                CriExpressions.FieldsList = Hdrfldlist;
                CriExpressions.objfieldMap = mMapFieldList.get('SVMXC__Service_Order__c');
                CriExpressions.DefaultField = getTAG019();
                CriExpressions.DefaultOperator = getTAG019();
                CriExpressions.DefaultListValue = getTAG019();
                CriExpressions.ExpressionType = 'CRITERIA';
                AvaliableWOfieldMap = CriExpressions.FieldApiLable.clone();
                for(SVMXC__ServiceMax_Config_Data__c exp : RuleExpression)
                {
                  CriExpressions.setExpressions(exp);
                }
            }
            if(WOFldLst.size() > 0)
            {
                WOfieldMap.clear();
                for(Integer i = 0; i<WOFldLst.size();i++)
                {
                    WOfieldMap.put(WOFldLst[i].SVMXC__Target_Field_Name__c,AvaliableWOfieldMap.get(WOFldLst[i].SVMXC__Target_Field_Name__c));
                    //List_Sequence.put(WOFldLst[i].SVMXC__Target_Field_Name__c,WOFldLst[i].SVMXC__Sequence__c.intValue());
                    AvaliableWOfieldMap.remove(WOFldLst[i].SVMXC__Target_Field_Name__c);
                }
            }
            WOfilds.clear();
            for(Integer i = 0; i<WOFldLst.size();i++)
            {
                WOfilds.add(new SelectOption(WOFldLst[i].SVMXC__Target_Field_Name__c,WOfieldMap.get(WOFldLst[i].SVMXC__Target_Field_Name__c)));
            }
            for(String s : AvaliableWOfieldMap.keyset())
            {
                AvaliWOfilds.add(new SelectOption(s,AvaliableWOfieldMap.get(s)));
            }
            sortingSelectOption(AvaliWOfilds,true);
            CriExpressions.AdvanceOption = AdvanceOption;
            DisbleNewBttn = true;
            DisbleEdtBttn = true;
            DisbleSaveBttn = false;
            DisableCancelBttn = false;
            DisbleDelBttn = true;
            DisbleRuleSeqBttn = true;
            DisbaleChkBox = true;
            ShowExp = true;  
        }
        else
        {
            HdrMsg = true;
        }
        return null;
    }
        public string RuleName;
        boolean ValidateRuleName;
        public boolean SVMX_ValidateRuleName(SVMXC__ServiceMax_Processes__c Rule)
        {
            ValidateRuleName = true;
            RuleName = Rule.SVMXC__Name__c;
            if(RuleName == null)
            {
                HdrMsg = true;
                ValidateRuleName = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG027()));      
            }
            else
            {
                if(RuleName.length() < 8)
                {
                    HdrMsg = true;
                    ValidateRuleName = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG029()));      
                }
            }
            return ValidateRuleName;
        }
    public pagereference SVMX_SaveRule()
    {
        Savepoint sp = Database.setSavePoint();
        HdrMsg = false;
        SVMXC__ServiceMax_Processes__c Rule = new SVMXC__ServiceMax_Processes__c(); 
        List<SVMXC__ServiceMax_Config_Data__c> WOFldList = new List<SVMXC__ServiceMax_Config_Data__c>();
        string CriExpressionsErr = CriExpressions.getCriteria('SVMXC__Service_Order__c');
        boolean IsValidate = true;
        for(integer i=0;i<RuleList.size();i++)
        { 
            if(RuleList[i].SVMXC__Select__c)
            {         
                Rule.SVMXC__Name__c = RuleList[i].SVMXC__Name__c;
            }
        }
        IsValidate = SVMX_ValidateRuleName(Rule);
        if(IsValidate == false)
        {
            for(integer i=0;i<RuleList.size();i++)
            {
                if(RuleList[i].id == null)
                {
                    RuleList[i].SVMXC__Select__c = true;
                }
                if(RuleId == RuleList[i].id)
                {
                    RuleList[i].SVMXC__Select__c = true;
                }
            }  
            return null;  
        }
        if(CriExpressionsErr != 'ERROR')
        {
            for(SVMXC__ServiceMax_Processes__c R : RuleList)
            {
                if(R.SVMXC__Select__c == true)
                {
                    R.RecordTypeId = RuleRecordTypeId;
                    R.SVMXC__Rule_Type__c = 'Event Subject Rule';
                    R.SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption;
                    Rule = R;
                }   
            }
            Rule.SVMXC__Select__c = false;
            //CRUD
            if (!securityUtils.verifyFieldAccess(Rule, COMM_SecurityUtils.Access.Upsertable))
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                            upsert Rule;
                        }
            //upsert Rule;
            map<string, string> mapPropertiesRule = new map<string, string>(); 
            mapPropertiesRule.put('RecordTypeID', ExpressionRTypeId);
            mapPropertiesRule.put('SVMXC__Expression_Type__c','DISP_Event_Subject_Rule');
            mapPropertiesRule.put('SVMXC__Expression_Rule__c', Rule.Id);
            CriExpressions.getExpressions(mapPropertiesRule);
            List<SVMXC__ServiceMax_Config_Data__c> DelConfd = new List<SVMXC__ServiceMax_Config_Data__c>();
            DelConfd = Database.Query('Select s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c = \''+Rule.id+'\' and RecordTypeId = \''+FieldMapRTypeId+'\'');
            if(WOfilds.size() > 0)
            {
                for(Integer i = 0; i < WOfilds.size();i++ )
                {
                    SVMXC__ServiceMax_Config_Data__c confd = new SVMXC__ServiceMax_Config_Data__c();
                    
                    confd.SVMXC__Expression_Rule__c = Rule.id;
                    confd.RecordTypeId = FieldMapRTypeId;
                    confd.SVMXC__Target_Field_Name__c = WOfilds[i].getValue();
                    confd.SVMXC__Sequence__c = i;
                    WOFldList.add(confd);
                }
            }
            boolean isValidExpression;
            Rule.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
            SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(Rule,CriExpressions.Expressions);
            List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
            LstSFM_Exp.add(oSFM_Exp);
            SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
            SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
            SFM_ValidateExpression ValidateExp = new SFM_ValidateExpression();
            Save_Response = ValidateExp.SFM_validateExpression(oRequest);
            String strErrorMsg = Save_Response.message;

            if( Save_Response.success != null && Boolean.valueOf(Save_Response.success)) {
                isValidExpression = true;
            }
            else {
                isValidExpression = false;
            }
            system.debug(logginglevel.WARN,'***isValidExpression***'+isValidExpression);
            system.debug(logginglevel.WARN,'***strErrorMsg***'+strErrorMsg);
            if(!isValidExpression) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,strErrorMsg));
                HdrMsg = true;
                return null;
            }
            if(DelConfd.size() > 0)
            {
                //CRUD
                if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Config_Data__c'))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                        //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete DelConfd;    
                    }
                //delete DelConfd;
            }
            if(WOFldList.size() > 0 )
            {   
                //CRUD
                if (!securityUtils.verifyFieldAccess(WOFldList, COMM_SecurityUtils.Access.Upsertable))
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                            upsert WOFldList;
                        }
                //upsert WOFldList;
            }    
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG023()));
            DisbleNewBttn = false;
            DisbleEdtBttn = false;
            DisbleSaveBttn = true;
            DisableCancelBttn = true;
            DisbleDelBttn = false;
            DisbaleChkBox = false;
            ShowExp = false;
            Pagereference pageref = new Pagereference('/apex/SVMXC__WORD_SetupEventSubjectRules');
            pageref.setRedirect(true);
            return pageref;
        }
        if(CriExpressionsErr == 'ERROR')
        {
          HdrMsg = true;
        }   
       return null;  
         
    }
    public pagereference SVMX_DeleteRule()
    {
        HdrMsg = false;
        Boolean Deleted = false;
        List<Integer> selectedLines = new List<Integer>();
        List<Integer> DeletedLines = new List<Integer>();
        for(Integer i = 0; i < RuleList.size(); i++)
        {
            if(RuleList[i].SVMXC__Select__c == true)
            {
                selectedLines.add(i);
            }   
        }
        if(selectedLines.size() == 0)
        {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021()));
        }
        String SelectedRuleId = '';
        List<SVMXC__ServiceMax_Processes__c> DeleteRule = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> WOFldRecs = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        for(Integer i=0; i<RuleList.size();i++)
        {
            if(RuleList[i].SVMXC__Select__c == true)
            {
                SelectedRuleId = RuleList[i].id;
                DeletedLines.add(i);
                if(RuleList[i].id != null)
                    DeleteRule.add(RuleList[i]);
                
            }
        }
        if(SelectedRuleId != null && SelectedRuleId.length() > 0)
        {
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            ConfigData = Database.Query('Select s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c = \''+SelectedRuleId+'\' and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Event_Subject_Rule\'');
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            WOFldRecs  = Database.Query('Select s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c = \''+SelectedRuleId+'\' and RecordTypeId = \''+FieldMapRTypeId+'\'order by SVMXC__Sequence__c');
        }
        if(DeleteRule.size() > 0 )
        {
            //CRUD
            if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Processes__c'))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                        //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete DeleteRule;  
                    }
            //delete DeleteRule;
            Deleted = true;
            for(Integer i = DeletedLines.size()-1;i>=0;i--)
            {
                RuleList.remove(DeletedLines.get(i));
            }
        }
        if(ConfigData.size() > 0)
        {
            //CRUD
            if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Config_Data__c'))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                        //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete ConfigData;  
                    }
            //delete ConfigData;
            Deleted = true;
        }
        if(WOFldRecs.size() > 0)
        {
            //CRUD
            if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Config_Data__c'))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                        //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete WOFldRecs;   
                    }
            //delete WOFldRecs;
            Deleted = true;
        }
        if(Deleted)
        {
            HdrMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG025()));
        }
        if(RuleList.size() == 0)
        {
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
        }
        if(RuleList.size() < 2)
        {
            DisbleRuleSeqBttn = true;
        }
        return null;
    }
    public pagereference SVMX_Cancel()
    {
        pagereference newpage = new pagereference('/apex/WORD_SetupEventSubjectRules');
        newpage.setRedirect(true);
        return newpage;
    }
    public pagereference SVMX_GoSetupHome()
    {
         //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        pagereference newpage = new pagereference(url);
        newpage.setRedirect(true);
        return newpage;
    } 
    /****************************** Methods for WOList part ************************************/
    public List<SelectOption> AvaliWOfilds = new List<SelectOption>();
    public List<String> AvaliSelWOfilds = new List<String>();
    
    public List<SelectOption> getAvaliWOfilds()
    {
        AvaliWOfilds.clear();
        for(String s : AvaliableWOfieldMap.keySet())
        {
            if(AvaliableWOfieldMap.containsKey(s) && AvaliableWOfieldMap.get(s) != null)
                AvaliWOfilds.add(new SelectOption(s,AvaliableWOfieldMap.get(s)));
        }
        return sortingSelectOption(AvaliWOfilds,true);
        //return AvaliWOfilds;
    }
    public List<String> getAvaliSelWOfilds(){return AvaliSelWOfilds;}
    public void setAvaliSelWOfilds(List<String> s){AvaliSelWOfilds = s;}
    
    
    public List<SelectOption> WOfilds = new List<SelectOption>();
    public List<String> SelWOfilds = new List<String>();
    
    public List<SelectOption> getWOfilds()
    {
        /*WOfilds.clear();
        for(String s: WOfieldMap.keySet())
        {
            if(WOfieldMap.containsKey(s) && WOfieldMap.get(s) != null)
                WOfilds.add(new SelectOption(s,WOfieldMap.get(s)));
        }
        //return sortingSelectOption(WOfilds,true);*/
        return WOfilds;
    }
    public List<String> getSelWOfilds(){return SelWOfilds;}
    public void setSelWOfilds(List<String> s){SelWOfilds = s;}
    
    public pagereference OnAddFields()
    {
        if(AvaliSelWOfilds.size() == 0)
        {
            WOMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG020()));
        }
        if(AvaliSelWOfilds.size() > 0)
        {
            for(integer i = 0; i < AvaliSelWOfilds.size();i++)
            {
                if(WOfieldMap.containsKey(AvaliSelWOfilds[i]) == false)
                {
                    WOfieldMap.put(AvaliSelWOfilds[i],AvaliableWOfieldMap.get(AvaliSelWOfilds[i]));
                    WOfilds.add(new SelectOption(AvaliSelWOfilds[i],AvaliableWOfieldMap.get(AvaliSelWOfilds[i])));
                    //if(List_Sequence.containskey(AvaliSelWOfilds[i]) == false)
                        //List_Sequence.put(AvaliSelWOfilds[i],i);
                    if(AvaliableWOfieldMap.containskey(AvaliSelWOfilds[i]))
                        AvaliableWOfieldMap.remove(AvaliSelWOfilds[i]);
                }
            }
        }
        return null;
    }
    public pagereference OnRemoveFields()
    {
        List<Integer> selectedLines = new List<Integer>();
        if(SelWOfilds.size() == 0)
        {
            WOMsg = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG020()));
        }
        if(SelWOfilds.size() > 0)
        {
            for(Integer i = 0; i<SelWOfilds.size(); i++)
            {
                if(AvaliableWOfieldMap.containskey(SelWOfilds[i]) == false)
                {
                    AvaliableWOfieldMap.put(SelWOfilds[i], WOfieldMap.get(SelWOfilds[i]));
                    //AvaliWOfilds.add(new SelectOption(SelWOfilds[i],WOfieldMap.get(SelWOfilds[i])));
                    //selectedLines.add(i);
                    if(WOfieldMap.containskey(SelWOfilds[i]))
                        WOfieldMap.remove(SelWOfilds[i]);
                    //if(List_Sequence.containskey(SelWOfilds[i]))
                        //List_Sequence.remove(SelWOfilds[i]);
                }   
            }
            WOfilds.clear();
            for(String s: WOfieldMap.keyset())
            {
                WOfilds.add(new SelectOption(s,WOfieldMap.get(s)));
            }
        }
        return null;
    }
    /****************************** Rule Sequence Popup ************************************/
    public List<SelectOption> Seqoptions = new List<SelectOption>();
    public Map<string,Integer> MyMap = new Map<string,Integer>();
    public string[] items = new String[]{};
    public integer selIndex = 0;
    public boolean isUpAction = false;
    public boolean isDownAction = false;
    public boolean isTopAction = false;
    public boolean isBottomAction = false;
    public boolean displaySeqPopup = false;
    public boolean getdisplaySeqPopup(){return displaySeqPopup;}
    /* public void SVMX_RuleSequence()
    {
        TempRuleLst.clear();
        TempRuleLst = Database.Query('Select s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__Name__c,  s.SVMXC__Description__c, s.SVMXC__Advance_Expression__c,  s.RecordTypeId, s.Name, s.Id From SVMXC__ServiceMax_Processes__c s where RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Event Subject Rule\'order by SVMXC__Sequence__c');
        displaySeqPopup = true;
        DisbleNewBttn = true;
        DisbleEdtBttn = true;
        DisbleDelBttn = true;
        DisbleRuleSeqBttn = true;
    }
    public List<SelectOption> getSeqoptions()
    {
        Seqoptions = new List<SelectOption>();  
        if(TempRuleLst.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:TempRuleLst)
            {        
                if(s.SVMXC__Name__c != null)
                    Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        } 
        return Seqoptions;
    }
    public string[] getitems(){return items;}
    public void setitems(string[] o){this.items=o;}
    public void shuffle(integer selIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop)
        {
            temp = TempRuleLst[selIndex];
            for(integer j=selIndex;j>0;j--)
            {
                TempRuleLst[j] = TempRuleLst[j-1];
            }
            TempRuleLst[0] = temp;
        }
        else 
        {
            temp = TempRuleLst[selIndex];
            for(integer j=selIndex;j<TempRuleLst.size()-1;j++)
            {
                TempRuleLst[j] = TempRuleLst[j+1];
            }
            TempRuleLst[TempRuleLst.size()-1] = temp;
        }
    } 
    public void UP()
    { 
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempRuleLst.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==TempRuleLst[0].Id)
                {
                    TempRuleLst[j] = TempRuleLst[j];
                    break;
                }
                else if(items[i]==TempRuleLst[j].Id)
                {
                    temp = TempRuleLst[j]; 
                    TempRuleLst[j] = TempRuleLst[j-1];
                    TempRuleLst[j-1]=temp;   
                    selIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    TempRuleLst[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    TempRuleLst[selIndex].SVMXC__Sequence__c = selIndex;
                }
            }
        }
    }
    public void Down()
    { 
        SVMXC__ServiceMax_Processes__c temp;
        for(integer i=0;i<items.size();i++)
        {
            MyMap.Put(items[i],i);
        }
        for(integer i=0;i<items.size();i++)
        {
            for(integer k=0;k<TempRuleLst.size()-1;k++)
            {
                if(items[i]==TempRuleLst[k].Id)
                {
                    temp = TempRuleLst[k];
                    TempRuleLst[k] = TempRuleLst[k+1];
                    TempRuleLst[k+1]=temp;
                    selIndex = k;
                    isUpAction = false;
                    isDownAction=true;
                    isTopAction=false;
                    isBottomAction=false;
                    TempRuleLst[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                    TempRuleLst[selIndex].SVMXC__Sequence__c = selIndex;
                    break;    
                }
            }
        } 
    }
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempRuleLst.size()-1;j>0;j--)
        {
            for(integer i=items.size()-1;i>=0;i--)
            {
                if(items[i] == TempRuleLst[j].Id)
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
    public void Bottom()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempRuleLst.size()-1;j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i] == TempRuleLst[j].Id)
                {
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
    public pagereference SVMX_SaveSequence()
    {
        SVMXC__ServiceMax_Processes__c temp;
        double t;
        if(isUpAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            update TempRuleLst;
        }
        else if(isDownAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            update TempRuleLst;
        }
        else if(isTopAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            update TempRuleLst;
        }
        else if(isBottomAction)
        {
            for(integer i=0;i<TempRuleLst.size();i++)
            {
                TempRuleLst[i].SVMXC__Sequence__c=i+1;
            }
            update TempRuleLst;
        }
        RuleList.clear();
        RuleList.addAll(TempRuleLst);
        displaySeqPopup = false;
        DisbleNewBttn = false;
        DisbleEdtBttn = false;
        DisbleDelBttn = false;
        DisbleRuleSeqBttn = false;
        return null;  
    }
    public pagereference SVMX_PopupCancel()
    {
        displaySeqPopup = false;
        DisbleNewBttn = false;
        DisbleEdtBttn = false;
        DisbleDelBttn = false;
        DisbleRuleSeqBttn = false;
        return null;
    } */
     public void SVMX_RuleSequence()
    {
        TempRuleLst.clear();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        TempRuleLst = Database.Query('Select s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__Name__c,  s.SVMXC__Description__c, s.SVMXC__Advance_Expression__c,  s.RecordTypeId, s.Name, s.Id From SVMXC__ServiceMax_Processes__c s where RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Event Subject Rule\'order by SVMXC__Sequence__c');
        displaySeqPopup = true;
        DisbleNewBttn = true;
        DisbleEdtBttn = true;
        DisbleDelBttn = true;
        DisbleRuleSeqBttn = true;
    }
    
    public void SVMX_OrderSequence()
    {
        displaySeqPopup = true;
        DisbleNewBttn = true;
        DisbleEdtBttn = true;
        DisbleDelBttn = true;
        DisbleRuleSeqBttn = true;
        TempRuleLst.clear();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        TempRuleLst = Database.Query('Select s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__Name__c,  s.SVMXC__Description__c, s.SVMXC__Advance_Expression__c,  s.RecordTypeId, s.Name, s.Id From SVMXC__ServiceMax_Processes__c s where RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Event Subject Rule\'order by SVMXC__Sequence__c');
        
    }
    public List<SelectOption> getSeqoptions()
    {
        Seqoptions = new List<SelectOption>();  
        if(TempRuleLst.Size() >0)
        {
            for(SVMXC__ServiceMax_Processes__c s:TempRuleLst)
            {        
                if(s.SVMXC__Name__c != null)
                    Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        } 
        return Seqoptions;
    }
    public string[] getitems(){return items;}
    public void setitems(string[] o){this.items=o;}
    public void shuffle(integer selIndex, boolean isTop )
    {
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop)
        {
            temp = TempRuleLst[selIndex];
            for(integer j=selIndex;j>0;j--)
            {
                TempRuleLst[j] = TempRuleLst[j-1];
            }
            TempRuleLst[0] = temp;
        }
        else 
        {
            temp = TempRuleLst[selIndex];
            for(integer j=selIndex;j<TempRuleLst.size()-1;j++)
            {
                TempRuleLst[j] = TempRuleLst[j+1];
            }
            TempRuleLst[TempRuleLst.size()-1] = temp;
        }
    } 
    //------------------------------- Method to move Rule up by one position -----------------------    
    public void UP()
    {    
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempRuleLst.size();j++)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==TempRuleLst[0].Id)
                {
                    TempRuleLst[j] = TempRuleLst[j];
                        //break;
                }
                else if(items[i]==TempRuleLst[j].Id)
                {
                    temp = TempRuleLst[j]; 
                    TempRuleLst[j] = TempRuleLst[j-1];
                    TempRuleLst[j-1]=temp;                    
                    selIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    TempRuleLst[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    TempRuleLst[selIndex].SVMXC__Sequence__c = selIndex;
                }
            }
        }
       
    }
     //------------------------------- Method to move Rule down by one position -----------------------
    public void Down()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempRuleLst.size()-1;j>=0;j--)
        {
            for(integer i=0;i<items.size();i++)
            {
                if(items[i]==TempRuleLst[TempRuleLst.size()-1].Id)
                {
                    TempRuleLst[j] = TempRuleLst[j];
                   // break;
                }
                else if(items[i]==TempRuleLst[j].Id)
                {
                            temp = TempRuleLst[j]; 
                            TempRuleLst[j] = TempRuleLst[j+1];
                            TempRuleLst[j+1]=temp;                    
                            selIndex = j;
                            isUpAction = false;
                            isDownAction=true;
                            isTopAction=false;
                            isBottomAction=false;
                            TempRuleLst[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                            TempRuleLst[selIndex].SVMXC__Sequence__c = selIndex;
                }  
            }
        }
    }
    //------------------------------- Method to move Rule to the top -----------------------
    public void Top()
    {
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempRuleLst.size()-1;j>0;j--)
        {
            for(integer i = items.size()-1;i>=0;i--){
                if(items[i] == TempRuleLst[j].Id)
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
    //------------------------------- Method to move Rule to bottom -----------------------
    public void Bottom(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempRuleLst.size()-1;j++){
            for(integer i=0;i<items.size();i++){
                if(items[i] == TempRuleLst[j].Id){
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
    //-------------------------------------- Method to save rearrnged Rule ----------------------------
    public void SVMX_SaveSequence()
    {
        list<SVMXC__ServiceMax_Processes__c> lsttemp = new list<SVMXC__ServiceMax_Processes__c>();
        double t;
      
        for(integer i =0 ;i<TempRuleLst.size();i++)
        {
            TempRuleLst[i].SVMXC__Sequence__c=i;
        }
        //CRUD
        if(TempRuleLst != null && TempRuleLst.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(TempRuleLst, COMM_SecurityUtils.Access.Updateable))
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                            update TempRuleLst;
                        }
                }
        //update TempRuleLst;
        RuleList.clear();
        RuleList.addAll(TempRuleLst);
        displaySeqPopup = false;
        DisbleNewBttn = false;
        DisbleEdtBttn = false;
        DisbleDelBttn = false;
        DisbleRuleSeqBttn = false;
       // return null;
        
    }
    public pagereference SVMX_PopupCancel()
    {
        displaySeqPopup = false;
        DisbleNewBttn = false;
        DisbleEdtBttn = false;
        DisbleDelBttn = false;
        DisbleRuleSeqBttn = false;
        return null;
    }
    /****************************** Sequence for WO fields ************************************/
    public Map<string,Integer> WOFldMyMap = new Map<string,Integer>();
    public List<SelectOption> TempWOfilds = new List<SelectOption>(); 
    public integer WOFldselIndex = 0;
    public void WOFldshuffle(integer selIndex, boolean isTop )
    {
        SelectOption temp;
        if(isTop)
        {
            temp = TempWOfilds[selIndex];
            for(integer j=selIndex;j>0;j--)
            {
                TempWOfilds[j] = TempWOfilds[j-1];
            }
            TempWOfilds[0] = temp;
        }
        else 
        {
            temp = TempWOfilds[selIndex];
            for(integer j=selIndex;j<TempWOfilds.size()-1;j++)
            {
                TempWOfilds[j] = TempWOfilds[j+1];
            }
            TempWOfilds[TempWOfilds.size()-1] = temp;
        }
        WOfilds.clear();
        WOfilds.addAll(TempWOfilds); 
    } 
    public void WOFldUP()
    { 
        TempWOfilds.clear();
        TempWOfilds.addAll(WOfilds);
        SelectOption temp;
        for(integer j=0;j<TempWOfilds.size();j++)
        {
            for(integer i=0;i<SelWOfilds.size();i++)
            {
                if(SelWOfilds[i]==TempWOfilds[0].getvalue())
                {
                    TempWOfilds[j] = TempWOfilds[j];
                    break;
                }
                else if(SelWOfilds[i]==TempWOfilds[j].getvalue())
                {
                    temp = TempWOfilds[j]; 
                    TempWOfilds[j] = TempWOfilds[j-1];
                    TempWOfilds[j-1]=temp;   
                    //WOFldselIndex = j;
                    //TempWOfilds[WOFldselIndex-1] = WOFldselIndex-1;
                }
            }
        }
        WOfilds.clear();
        WOfilds.addAll(TempWOfilds);
    }
    public void WOFldDown()
    { 
        TempWOfilds.clear();
        TempWOfilds.addAll(WOfilds);
        SelectOption temp;
        for(integer i=0;i<SelWOfilds.size();i++)
        {
            WOFldMyMap.Put(SelWOfilds[i],i);
        }
        for(integer i=0;i<SelWOfilds.size();i++)
        {
            for(integer k=0;k<TempWOfilds.size()-1;k++)
            {
                if(SelWOfilds[i]==TempWOfilds[k].getvalue())
                {
                    temp = TempWOfilds[k];
                    TempWOfilds[k] = TempWOfilds[k+1];
                    TempWOfilds[k+1]=temp;
                    //WOFldselIndex = k;
                    //TempWOfilds[WOFldselIndex+1] = WOFldselIndex+1;
                    //TempWOfilds[WOFldselIndex] = WOFldselIndex;
                    break;    
                }
            }
        }
        WOfilds.clear();
        WOfilds.addAll(TempWOfilds); 
    }
    public void WOFldTop()
    {
        TempWOfilds.clear();
        TempWOfilds.addAll(WOfilds);
        SelectOption temp;
        for(integer j=TempWOfilds.size()-1;j>0;j--)
        {
            for(integer i=SelWOfilds.size()-1;i>=0;i--)
            {
                if(SelWOfilds[i] == TempWOfilds[j].getvalue())
                {
                    WOFldselIndex = j;
                    WOFldshuffle(WOFldselIndex, true);   
                }   
            }
        } 
    }
    public void WOFldBottom()
    {
        TempWOfilds.clear();
        TempWOfilds.addAll(WOfilds);
        SelectOption temp;
        for(integer j=0;j<TempWOfilds.size()-1;j++)
        {
            for(integer i=0;i<SelWOfilds.size();i++)
            {
                if(SelWOfilds[i] == TempWOfilds[j].getvalue())
                {
                    WOFldselIndex = j;
                    WOFldshuffle(WOFldselIndex, false); 
                }
            }
        } 
    }
    /****************************** Translations ************************************/
        public String getTAG001() {return System.Label.WORD016_TAG001;}
        public String getTAG002() {return System.Label.WORD016_TAG002;}
        public String getTAG003() {return System.Label.WORD016_TAG003;}
        public String getTAG004() {return System.Label.WORD016_TAG004;}
        public String getTAG005() {return System.Label.WORD016_TAG005;}
        public String getTAG006() {return System.Label.WORD016_TAG006;}
        public String getTAG007() {return System.Label.WORD016_TAG007;}
        public String getTAG008() {return System.Label.WORD016_TAG008;}
        public String getTAG009() {return System.Label.WORD016_TAG009;}
        public String getTAG010() {return System.Label.WORD016_TAG010;}
        public String getTAG011() {return System.Label.WORD016_TAG011;}
        public String getTAG012() {return System.Label.WORD016_TAG012;}
        public String getTAG013() {return System.Label.WORD016_TAG013;}
        public String getTAG014() {return System.Label.WORD016_TAG014;}
        public String getTAG015() {return System.Label.WORD016_TAG015;}
        public String getTAG016() {return System.Label.WORD016_TAG016;}
        public String getTAG017() {return System.Label.WORD016_TAG017;}
        public String getTAG018() {return System.Label.WORD016_TAG018;}        
        public String getTAG019() {return System.Label.WORD016_TAG019;}
        public String getTAG020() {return System.Label.WORD016_TAG020;}        
        public String getTAG021() {return System.Label.WORD016_TAG021;}
        public String getTAG022() {return System.Label.WORD016_TAG022;}        
        public String getTAG023() {return System.Label.WORD016_TAG023;}
        public String getTAG024() {return System.Label.WORD016_TAG024;}        
        public String getTAG025() {return System.Label.WORD016_TAG025;}
        public String getTAG026() {return System.Label.WORD016_TAG026;}
        public String getTAG027() {return System.Label.WORD016_TAG027;}
        public String getTAG029() {return System.Label.WORD016_TAG029;}
        public String getHLPURL() {return System.Label.WORD016_HLPURL;}
    
     /*******************************************************Utility Methods**********************************************/
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2)  //,list<sobject> ObjList
    {
        RetriveField(ObjName, lst, m, m2, null);
    }
    public void RetriveField2(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT)  //,list<sobject> ObjList
    {
        if(!mMapFieldList.containsKey(ObjName))
        {
            Schema.SObjectType objT = allObjs.get(objName) ;
            if(objT != null)
            {
                objfieldMap = objT.getDescribe().fields.getMap();
                mMapFieldList.put(ObjName, objfieldMap);
            }   
        }
        else
            objfieldMap = mMapFieldList.get(objName);
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(DT != null && DT == f.getType())
            {
                Schema.SObjectType sobjRefTo = f.getReferenceTo()[0];
                Schema.DescribeSObjectResult dsobjresRefTo = sobjRefTo.getDescribe();
                lst.add(new SelectOption(dsobjresRefTo.getName() + '~' + f.getName(),dsobjresRefTo.getLabel() + '.' + f.getLabel()));
            }
            
            if(m != null)
                m.put(f.getName(), f.getType());
            if(m2 != null)
                m2.put(f.getName(),f.getLabel());   
        }
        sortingSelectOption(lst, true);
    }   
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT)  //,list<sobject> ObjList
    {
        if(!mMapFieldList.containsKey(ObjName))
        {
                
            Schema.SObjectType objT = allObjs.get(objName); 
            if(objT != null)
            {
                objfieldMap = objT.getDescribe().fields.getMap();
                mMapFieldList.put(ObjName, objfieldMap);
            }   
        }
        else
            objfieldMap = mMapFieldList.get(objName);
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.getType() == schema.Displaytype.REFERENCE)  
            {
                if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                {
                    if(DT != null && DT == f.getType())
                        lst.add(new SelectOption(f.getName(),f.getLabel()));
                    if(DT == null)
                        lst.add(new SelectOption(f.getName(),f.getLabel()));
                    if(m != null)
                        m.put(f.getName(), f.getType());
                    if(m2 != null)
                        m2.put(f.getName(),f.getLabel());   
                }
                if(utils.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])) == false)
                {
                    if((PermitedStndObjMap.containsKey(String.valueof(f.getReferenceTo()[0])) || IsEnterpriseLicense))
                    {
                        if(DT != null && DT == f.getType())
                            lst.add(new SelectOption(f.getName(),f.getLabel()));
                        if(DT == null)
                            lst.add(new SelectOption(f.getName(),f.getLabel()));
                        if(m != null)
                            m.put(f.getName(), f.getType());
                        if(m2 != null)
                            m2.put(f.getName(),f.getLabel()); 
                    }
                }       
            }
            if(f.getType() != schema.Displaytype.REFERENCE)
            {
                if(DT != null && DT == f.getType())
                    lst.add(new SelectOption(f.getName(),f.getLabel()));
                if(DT == null)
                    lst.add(new SelectOption(f.getName(),f.getLabel()));
                if(m != null)
                    m.put(f.getName(), f.getType());
                if(m2 != null)
                    m2.put(f.getName(),f.getLabel()); 
            }
              
        }
        sortingSelectOption(lst, true);
    }     
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT, string LCObjName)  //,list<sobject> ObjList
    {
        if(!mMapFieldList.containsKey(ObjName))
        {
            Schema.SObjectType objT = allObjs.get(objName) ;
            if(objT != null)
            {
                objfieldMap = objT.getDescribe().fields.getMap();
                mMapFieldList.put(ObjName, objfieldMap);
            }   
        }
        else
            objfieldMap = mMapFieldList.get(objName);
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(schema.Displaytype.REFERENCE == f.getType() && string.valueOf(f.getReferenceTo()[0]) == LCObjName)
                lst.add(new SelectOption(f.getName(),f.getLabel()));
            if(m != null)
                m.put(f.getName(), f.getType());
            if(m2 != null)
                m2.put(f.getName(),f.getLabel());   
        }
        sortingSelectOption(lst, true);
    }
    
    public List<SelectOption> sortingSelectOption(List<SelectOption> so, boolean bSortByLabel)
    {
        try
        {
            map<string, selectOption> mapTemp = new map<string, SelectOption>();
            if(bSortByLabel)
            {
                 for(selectOption o :so)
                 {  
                    mapTemp.put(o.getLabel()+'-'+o.getValue(), o);
                 }
            }
            else
            {
                 for(selectOption o :so)
                 {
                     mapTemp.put(o.getValue()+'-'+o.getLabel(), o);
                 }
            }
            list<string> lstTemp = new list<string>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            so.clear();
            for(string str: lstTemp)
            {       
                so.add(mapTemp.get(str));
            }
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
        return so;
    }
}