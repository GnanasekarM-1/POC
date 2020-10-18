/* Security Scanned */
public with sharing class WORD_SetupEventHoverRules 
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
    public string RuleId;
    public string SelectedIndex;
    public Boolean disableValue = false;
    public Boolean ShowExp = false;
    public String RuleRecordTypeId;
    public String ExpressionRTypeId;
    public String FieldMapRTypeId;
    public Integer MaxSequence = 0;
    //public List<RecordType> RecordTypes = new List<RecordType>();
    public List<SVMXC__ServiceMax_Processes__c> RuleList = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> TempRuleLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> RuleExpression = new List<SVMXC__ServiceMax_Config_Data__c>();
    //public List<SVMXC__ServiceMax_Config_Data__c> WOFldLst = new List<SVMXC__ServiceMax_Config_Data__c>();
    //public Map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>();
    //public Map<String,SObjectType> allObjs = new Map<String,SObjectType>();
    //public Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>(); 
    Map <string, Map<String,Schema.SObjectField>> mMapFieldList = new Map<string, Map<String,Schema.SObjectField>> ();
    public Map<String,string> AvaliableWOfieldMap = new Map<String,string>();
    public Map<String,string> WOfieldMap = new Map<String,string>();
    public transient List<AggregateResult> Aggresult = new List<AggregateResult>();
    //public boolean IsEnterpriseLicense = false;
    //public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    // public SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD017');
    
    /*public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('');*/
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    
    public COMM_SVMXC_Search_Expressions CriExpressions = new COMM_SVMXC_Search_Expressions(2);
    
    //Constructor
    public WORD_SetupEventHoverRules()
    {
         /*//Added by amar on 19/Aug/10 Due to OEM Exercises

        IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
        if(!IsEnterpriseLicense)
        {
             PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
        } */
        List<RecordType> RecordTypes = new List<RecordType>();
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
        RuleList = Database.query('Select s.SVMXC__Select__c, s.SVMXC__Name__c,  s.SVMXC__Description__c, s.SVMXC__Advance_Expression__c,  s.RecordTypeId, s.Name, s.Id From SVMXC__ServiceMax_Processes__c s where RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c =\'Event Hover Rule\' order by SVMXC__Sequence__c');
        if(RuleList.size() <= 1)
            DisbleRuleSeqBttn = true;
        if(RuleList.size() == 0)
            DisbleEdtBttn = true;   
        if(RuleList.size() == 0)
            DisbleDelBttn = true;   
       /* gd = Schema.getGlobalDescribe(); 
        for(Schema.SObjectType lON : gd.values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            allObjs.put(D.getName(), lON);
        } */

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
    public List<SVMXC__ServiceMax_Config_Data__c> listExpToDel = new List<SVMXC__ServiceMax_Config_Data__c>();
    public void HdrDeleteRow(){ 
        CriExpressions.removeCriteriaExpression(integer.valueOf(SelectedIndex));
        system.debug('***SelectedIndex*** '+SelectedIndex);
        system.debug('***CriExpressions Expressions*** '+CriExpressions.Expressions);
        if(!CriExpressions.Expressions.isEmpty() && CriExpressions.Expressions.size() > 0) {
            listExpToDel.add(CriExpressions.Expressions[integer.valueOf(SelectedIndex) - 1]);
            CriExpressions.Expressions.remove(integer.valueOf(SelectedIndex) - 1);
        }
        
    }
    
    //Validation Rule..
    public Boolean SVMX_ValidRule = true;
    public Boolean SVMX_ValidRule()
    {
        List<Integer> selectedLines = new List<Integer>();
        SVMX_ValidRule = true;
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
    public boolean isNewRule;
    public pagereference SVMX_NewRule()
    {
        isNewRule = true;
        WOfilds.clear();
        WOfieldMap.clear();
        for(Integer i = 0; i < RuleList.size(); i++)
        {
            if(RuleList[i].SVMXC__Select__c == true)
            {
                RuleList[i].SVMXC__Select__c = false;
            }   
        }
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        SVMXC__ServiceMax_Processes__c newRule = new SVMXC__ServiceMax_Processes__c(SVMXC__Select__c = true);
        Aggresult = [select MAX(SVMXC__Sequence__c) from SVMXC__ServiceMax_Processes__c s where RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c ='Event Hover Rule'];
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
        isNewRule = false;
        HdrMsg = false;
        String SelectedRuleId = '';
        String AdvanceOption;
        //WOFldLst.clear();
        List<SVMXC__ServiceMax_Config_Data__c> WOFldLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        system.debug('ShowExp' + SVMX_ValidRule());
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
           //RuleExpression.clear();
           //List<SVMXC__ServiceMax_Config_Data__c> RuleExpression = new List<SVMXC__ServiceMax_Config_Data__c>();
            CriExpressions.lstExpressions.clear();
            if(SelectedRuleId != null && SelectedRuleId.length() > 0)
            {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                RuleExpression = Database.Query('Select s.SVMXC__Sequence__c, s.SVMXC__Operator__c, s.SVMXC__Operand__c, s.SVMXC__Object_Name__c, s.SVMXC__Lookup_Field_API_Name__c, s.SVMXC__Field_Name__c, s.SVMXC__FKey_Name_Field__c, s.Name, s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c = \''+SelectedRuleId+'\' and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Event_Hover_Rule\'');
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                WOFldLst = Database.Query('Select s.SVMXC__Target_Field_Name__c, s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c = \''+SelectedRuleId+'\' and RecordTypeId = \''+FieldMapRTypeId+'\'order by SVMXC__Sequence__c');
            }
            system.debug('WOfieldslist'+WOFldLst.size());
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
            system.debug('ShowExp1' +ShowExp);
            system.debug('showWOfilds' +WOfilds);
        }
        else
        {
            HdrMsg = true;
        }
        return null;
    }
    Map<String,Integer> RuleNameMap = new Map<String,Integer>();
    public string RuleName;
    boolean ValidateRuleName;
    public boolean SVMX_ValidateRuleName(SVMXC__ServiceMax_Processes__c Rule)
    {
        ValidateRuleName=true;
        RuleName=Rule.SVMXC__Name__c;
        if(RuleName == null)
        {
            HdrMsg=true;
            ValidateRuleName=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG027()));  
        }
        else
        {
            if(RuleName.length()<8)
            {
                HdrMsg=true; 
                ValidateRuleName=false;
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
        boolean IsNull=false;
        boolean SavRec = true;
        RuleNameMap.clear();
         for(SVMXC__ServiceMax_Processes__c R : RuleList)
        {
            if(R.SVMXC__Select__c == true)
            {
                Rule.SVMXC__Name__c = R.SVMXC__Name__c;
            }  
        }
        boolean IsValid=SVMX_ValidateRuleName(Rule);
        if(IsValid==false)
        {
            for(integer i=0;i<RuleList.size();i++)
            {
                if(RuleList[i].id==null)
                {
                    RuleList[i].SVMXC__Select__c= true;
                }
                if(RuleId==RuleList[i].id)
                {
                    RuleList[i].SVMXC__Select__c= true;
                }
            }  
            return null;   
        }
        
        if(CriExpressionsErr != 'ERROR')
        {
            for(integer j=0;j<RuleList.size();j++){
                
                if(RuleList[j].SVMXC__Name__c!=null){                               
                    RuleNameMap.put(RuleList[j].SVMXC__Name__c,j);      
                }
            }
            if(!IsNull && RuleNameMap.size()>0 && RuleList.size()>0){
                if(RuleNameMap.size()!=RuleList.size()){
                    SavRec = false;
                    HdrMsg = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG028()));
                }
                else{
                    if(SavRec){ 
                        for(SVMXC__ServiceMax_Processes__c R : RuleList)
                        {
                            if(R.SVMXC__Select__c == true)
                            {
                                if(!isNewRule) {
                                    R.RecordTypeId = RuleRecordTypeId;
                                    R.SVMXC__Rule_Type__c = 'Event Hover Rule';
                                    R.SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption;
                                    Rule = R;
                                } else {
                                    Rule.RecordTypeId = RuleRecordTypeId;
                                    Rule.SVMXC__Rule_Type__c = 'Event Hover Rule';
                                    Rule.SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption;
                                    Rule.SVMXC__Description__c = R.SVMXC__Description__c;
                                }
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
                        mapPropertiesRule.put('SVMXC__Expression_Type__c','DISP_Event_Hover_Rule');
                        mapPropertiesRule.put('SVMXC__Expression_Rule__c', Rule.Id);
                        CriExpressions.getExpressions(mapPropertiesRule);
                        List<SVMXC__ServiceMax_Config_Data__c> DelConfd = new List<SVMXC__ServiceMax_Config_Data__c>();
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
                        if(!isValidExpression) {
                            for(SVMXC__ServiceMax_Processes__c R : RuleList) {
                                if(Rule.Id == R.id)
                                {
                                    R.SVMXC__Select__c = true;
                                }
                            }
                            Database.rollback(sp);
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,strErrorMsg));
                            CriExpressions.Expressions = CriExpressions.Expressions.deepClone(false,true,true);
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
                        if(!listExpToDel.isEmpty() && listExpToDel.size() > 0) {
                            try{
                                    if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                                        //SDL-SVMX-DELETE-FLS-ENFORCED
                                        delete listExpToDel;
                                    }
                            } catch(Exception ex) {
                                    system.debug('***Exception***'+ex.getMessage());
                            }
                        }
                        if(!RuleExpression.isEmpty() && RuleExpression.size() > 0) {
                            if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                                //SDL-SVMX-DELETE-FLS-ENFORCED
                                    delete RuleExpression;
                            }
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
                        Pagereference pageref = new Pagereference('/apex/SVMXC__WORD_SetupEventHoverRules');
                        pageref.setRedirect(true);
                        return pageref;
                    }
                }
            }    
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
            ConfigData = Database.Query('Select s.Id From SVMXC__ServiceMax_Config_Data__c s where s.SVMXC__Expression_Rule__c = \''+SelectedRuleId+'\' and RecordTypeId = \''+ExpressionRTypeId+'\'and SVMXC__Expression_Type__c =\'DISP_Event_Hover_Rule\'');
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
        pagereference newpage = new pagereference('/apex/WORD_SetupEventHoverRules');
        newpage.setRedirect(true);
        return newpage;
    }
    public pagereference SVMX_GoSetupHome()
    {
        pagereference newpage = new pagereference('/apex/SVMXC__CONF_SetupHome');
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
    public void SVMX_RuleSequence()
    {
        TempRuleLst.clear();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        TempRuleLst = Database.Query('Select s.SVMXC__Sequence__c, s.SVMXC__Select__c, s.SVMXC__Name__c,  s.SVMXC__Description__c, s.SVMXC__Advance_Expression__c,  s.RecordTypeId, s.Name, s.Id From SVMXC__ServiceMax_Processes__c s where RecordTypeId = \''+RuleRecordTypeId+'\'and SVMXC__Rule_Type__c =\'Event Hover Rule\'order by SVMXC__Sequence__c');
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
    public String getTAG001() {return System.Label.WORD017_TAG001;}//Setup Event Hover Rules
    public String getTAG002() {return System.Label.WORD017_TAG002;}//New Rule
    public String getTAG003() {return System.Label.WORD017_TAG003;}//Edit Rule
    public String getTAG004() {return System.Label.WORD017_TAG004;}//Delete Rule
    public String getTAG005() {return System.Label.WORD017_TAG005;}//Save
    public String getTAG006() {return System.Label.WORD017_TAG006;}//Cancel
    public String getTAG007() {return System.Label.WORD017_TAG007;}//Rule Sequence
    public String getTAG008() {return System.Label.WORD017_TAG008;}//Back To SetupHome
    public String getTAG009() {return System.Label.WORD017_TAG009;}//Processing...
    public String getTAG010() {return System.Label.WORD017_TAG010;}//In this screen, you can create one or more Event Hover Rule for a WorkOrder.
    public String getTAG011() {return System.Label.WORD017_TAG011;}//Rule Name
    public String getTAG012() {return System.Label.WORD017_TAG012;}///Description
    public String getTAG013() {return System.Label.WORD017_TAG013;}//No Records To Display
    public String getTAG014() {return System.Label.WORD017_TAG014;}//Are you sure
    public String getTAG015() {return System.Label.WORD017_TAG015;}//Work Order Field
    public String getTAG016() {return System.Label.WORD017_TAG016;}//Operator
    public String getTAG017() {return System.Label.WORD017_TAG017;}//Value
    public String getTAG018() {return System.Label.WORD017_TAG018;}//Advanced Expression
    public String getTAG019() {return System.Label.WORD017_TAG019;}//--None--
    public String getTAG020() {return System.Label.WORD017_TAG020;}//Please select atleast one workorder field to move
    public String getTAG021() {return System.Label.WORD017_TAG021;}//Please select atleast on rule to edit
    public String getTAG022() {return System.Label.WORD017_TAG022;}//Please select only one rule to edit
    public String getTAG023() {return System.Label.WORD017_TAG023;}//Record saved succesfully    
    public String getTAG024() {return System.Label.WORD017_TAG024;}//Sequence of Event Hover Rule    
    public String getTAG025() {return System.Label.WORD017_TAG025;}//Record(s) Deleted   
    public String getTAG026() {return System.Label.WORD017_TAG026;}//Sequence
    public String getTAG027() {return System.Label.WORD017_TAG027;} //Sequence
    public String getTAG028() {return System.Label.WORD017_TAG028;}  //Sequence
    public String getTAG029() {return System.Label.WORD017_TAG029;}  //Sequence
    public String getHLPURL() {return System.Label.WORD017_HLPURL;}
    
     /*******************************************************Utility Methods**********************************************/
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2)  //,list<sobject> ObjList
    {
        RetriveField(ObjName, lst, m, m2, null);
    }
    public void RetriveField2(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT)  //,list<sobject> ObjList
    {
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>(); 
        Map<String,SObjectType> allObjs = new Map<String,SObjectType>();
        for(Schema.SObjectType lON : Schema.getGlobalDescribe().values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            allObjs.put(D.getName(), lON);
        }
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
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>(); 
        Map<String,SObjectType> allObjs = new Map<String,SObjectType>();
        for(Schema.SObjectType lON : Schema.getGlobalDescribe().values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            allObjs.put(D.getName(), lON);
        }
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
                    Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
                    //Added by amar on 19/Aug/10 Due to OEM Exercises
                    boolean IsEnterpriseLicense = false;
                    IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
                    if(!IsEnterpriseLicense)
                    {
                         PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
                    }
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
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>(); 
        Map<String,SObjectType> allObjs = new Map<String,SObjectType>();
        for(Schema.SObjectType lON : Schema.getGlobalDescribe().values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            allObjs.put(D.getName(), lON);
        }
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