public with Sharing class IPRD_ManageCounters {
    
    /****************************** Code Block Starts ************************************/
     
    //public COMM_Utils_ManageTags commUtil = new COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('IPRD005');
    
     
    /****************************** Translations ************************************/
    
    public String getTAG001() {return System.Label.IPRD005_TAG001;}
    public String getTAG002() {return System.Label.IPRD005_TAG002;}
    public String getTAG003() {return System.Label.IPRD005_TAG003;}
    public String getTAG004() {return System.Label.IPRD005_TAG004;}
    public String getTAG005() {return System.Label.IPRD005_TAG005;}
    public String getTAG006() {return System.Label.IPRD005_TAG006;} 
    public String getTAG007() {return System.Label.IPRD005_TAG007;}
    public String getTAG008() {return System.Label.IPRD005_TAG008;}
    public String getTAG009() {return System.Label.IPRD005_TAG009;}
    public String getTAG010() {return System.Label.IPRD005_TAG010;}
    public String getTAG011() {return System.Label.IPRD005_TAG011;}
    public String getTAG012() {return System.Label.IPRD005_TAG012;}
    public String getTAG013() {return System.Label.IPRD005_TAG013;}
    public String getTAG014() {return System.Label.IPRD005_TAG014;}
    public String getTAG015() {return System.Label.IPRD005_TAG015;}
    public String getTAG016() {return System.Label.IPRD005_TAG016;}
    public String getTAG017() {return System.Label.IPRD005_TAG017;}
    public String getTAG018() {return System.Label.IPRD005_TAG018;}
    public String getTAG019() {return System.Label.IPRD005_TAG019;} 
    public String getTAG020() {return System.Label.IPRD005_TAG020;}
    public String getTAG021() {return System.Label.IPRD005_TAG021;}  
    public String getTAG022() {return System.Label.IPRD005_TAG022;}  
    public String getTAG023() {return System.Label.IPRD005_TAG023;}
    public String getTAG024() {return System.Label.IPRD005_TAG024;}
    public String getTAG025() {return System.Label.IPRD005_TAG025;}
    public String getTAG026() {return System.Label.IPRD005_TAG026;}
    public String getTAG027() {return System.Label.IPRD005_TAG027;}
    public String getTAG028() {return System.Label.IPRD005_TAG028;}
    public String getTAG029() {return System.Label.IPRD005_TAG029;}
    public String getTAG030() {return System.Label.IPRD005_TAG030;}
    public String getTAG031() {return System.Label.IPRD005_TAG031;}
    public String getTAG032() {return System.Label.IPRD005_TAG032;}
    public String getTAG033() {return System.Label.IPRD005_TAG033;}
    public String getTAG034() {return System.Label.IPRD005_TAG034;}
    public String getTAG035() {return System.Label.IPRD005_TAG035;} 
    public String getTAG036() {return System.Label.IPRD005_TAG036;}
    public String getTAG037() {return System.Label.IPRD005_TAG037;}
    public String getTAG038() {return System.Label.IPRD005_TAG038;}
    public String getTAG039() {return System.Label.IPRD005_TAG039;}
    public String getTAG040() {return System.Label.IPRD005_TAG040;}  
    public String getTAG041() {return System.Label.IPRD005_TAG041;}  
    public String getTAG042() {return System.Label.IPRD005_TAG042;} 
    public String getTAG043() {return System.Label.IPRD005_TAG043;}
    public String getTAG044() {return System.Label.IPRD005_TAG044;}
    public String getTAG045() {return System.Label.IPRD005_TAG045;}
    public String getTAG046() {return System.Label.IPRD005_TAG046;}
    public String getTAG047() {return System.Label.IPRD005_TAG047;}
    //public String getTAG048() {return System.Label.IPRD005_TAG048;}
    public String getTAG048() {return System.Label.COMM001_TAG119;}//'Yes';
    public String getTAG049() {return System.Label.COMM001_TAG120;}//'No';
    public String getTAG050() {return System.Label.IPRD005_TAG048;}//'Counter Name change will be applied to new counter readings on the applicable installed products. The old name will be retained on existing readings. Are you sure to continue?'
        
    public String getHLPURL() {return System.Label.IPRD005_HLPURL;}
    
    /****************************** Variable Declaration ************************************/
    
    public List<SVMXC__ServiceMax_Processes__c> CounterRuleList = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> TempCounterRuleList = new List<SVMXC__ServiceMax_Processes__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> Cnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
    List<Id> CounterRuleIds = new List<Id>();
    public Map<String,Integer> RuleNameMap = new Map<String,Integer>();
    RecordType Rtype = new RecordType();
    integer EdtCountRec=0;
    boolean showRule = false;
    boolean DelPRCountRec = false;  
    boolean IsRuleBlock = false;
    boolean IsPartsBlock = false;   
    boolean DisbleNewBttn = false;
    boolean DisbleEdtBttn = false;
    boolean DisbleDelBttn = false;
    boolean DisbleSaveBttn = false;     
    boolean DisbaleChkBox = false;
    boolean IsConfigQuery = false;      
    boolean DisbaleActiveChkBox = false;
    boolean displaySeqPopup = false;
    boolean DisbleRuleSeqBttn = false;
    boolean DisableCancelBttn = false;
    boolean CanNameChange = true;
    boolean DisplayNameChangeWarnBtn = false;
    string RuleId;


    public Map<String, Schema.SObjectType> allobjects =new Map<String, Schema.SObjectType>();
    
    map<string, string> mapCriExpressionsProperties = new map<string, string>();
    public map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map<string, Map<String,Schema.SObjectField>> ();
    public Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
    public COMM_SVMXC_Search_Expressions CriExpressions = new COMM_SVMXC_Search_Expressions(2);
    public SVMXC__ServiceMax_Processes__c CounterRuleProcess = new SVMXC__ServiceMax_Processes__c();
    public boolean IsEnterpriseLicense = false;
    public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    
    public COMM_SVMXC_Search_Expressions getCriExpressions() {return CriExpressions;}
    public SVMXC__ServiceMax_Processes__c getCounterRuleProcess() {return this.CounterRuleProcess;}
    public void setCounterRuleProcess(SVMXC__ServiceMax_Processes__c prs){this.CounterRuleProcess=prs;}
    
    SVMXC__Counter_Details__c CounterRec = new SVMXC__Counter_Details__c();
    public List<SVMXC__Counter_Details__c> CounterRecList = new List<SVMXC__Counter_Details__c>();
    public map<Id, String> mapIDVsCountrName = new map<Id, String>();
    
    /****************************** Constructor Defined ************************************/
    
    public IPRD_ManageCounters(){
         //Added by amar on 19/Aug/10 Due to OEM Exercises
        IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
        if(!IsEnterpriseLicense)
        {
             PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
        }
        allobjs.putAll(allobjs2);
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Rtype = [select Id from RecordType where Name=:'SVMX Rule' and SobjectType='SVMXC__ServiceMax_Processes__c']; 
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        CounterRuleList=[select Id,Name,SVMXC__Sequence__c,SVMXC__Advance_Expression__c,SVMXC__Description__c,SVMXC__Name__c,SVMXC__Select__c from SVMXC__ServiceMax_Processes__c where RecordType.Name='SVMX Rule' and SVMXC__Rule_Type__c='Counters' order by SVMXC__Sequence__c];
        if(CounterRuleList.size()<=1){
            DisbleRuleSeqBttn = true;
        }
        if(CounterRuleList.size()==0){
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
            for(SVMXC__ServiceMax_Processes__c PR: CounterRuleList){            
                CounterRuleIds.add(PR.Id);          
            }
        }
        
                
        DisbleSaveBttn = true; 
        DisableCancelBttn = true;   
        CriExpressions.DefaultField = getTAG020();
        CriExpressions.DefaultOperator = getTAG020();
        CriExpressions.DefaultListValue = getTAG020();
        CriExpressions.ExpressionType = 'CRITERIA'; 
        //CriExpressions.ExpressionName = 'Counter Rule Criteria';
        for(Schema.SObjectType lON : allObjs.values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            if(D.isAccessible() == true && D.isCreateable() == true && D.isCustom() == true)
            {
                HdrObjApiLable.put(D.getName(),D.getLabel());
                HeaderObjApiLocalName.put(D.getName(),D.getLocalName()); 
                mapHdrObjOpt.put(D.getName(), new SelectOption(D.getName(),D.getLabel()));
            }
        }
        Map<String, Schema.SObjectType> tempallObjs = Schema.getGlobalDescribe();
        for(Schema.SObjectType lON : tempallObjs.values())
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
                allobjects.put(D.getName(), lON);
        }
        /*if(allobjects.containsKey('SVMXC__Service_Template_Products__c'))
            system.debug('true');
        else
            system.debug('false');  */
    }
    
    /****************************** Getter/Setter Functioanlity ************************************/
    
    public boolean getDisbaleChkBox(){ return DisbaleChkBox; }
    public void setDisbaleChkBox(boolean b){ this.DisbaleChkBox = b; }
    
    public boolean getshowRule(){ return showRule; }
    public void setshowRule(boolean b){ this.showRule = b; }
    
    public boolean getDelPRCountRec(){ return DelPRCountRec; }
    public void setDelPRCountRec(boolean b){ this.DelPRCountRec = b; }
    
    public boolean getDisplayNameChangeWarnBtn(){ return DisplayNameChangeWarnBtn; }
    public void setDisplayNameChangeWarnBtn(boolean b){ this.DisplayNameChangeWarnBtn = b; }
    
    public boolean getIsRuleBlock(){ return IsRuleBlock; }
    public void setIsRuleBlock(boolean b){ this.IsRuleBlock = b; }
    
    public boolean getIsPartsBlock(){ return IsPartsBlock; }
    public void setIsPartsBlock(boolean b){ this.IsPartsBlock = b; }
    
     
    public boolean getDisbaleActiveChkBox(){ return DisbaleActiveChkBox; }
    public void setDisbaleActiveChkBox(boolean b){ this.DisbaleActiveChkBox = b; }
    
    public boolean getDisbleNewBttn(){ return DisbleNewBttn; }
    public void setDisbleNewBttn(boolean b){ this.DisbleNewBttn = b; }
    public boolean getDisbleEdtBttn(){ return DisbleEdtBttn; }
    public void setDisbleEdtBttn(boolean b){ this.DisbleEdtBttn = b; }
    public boolean getDisbleDelBttn(){ return DisbleDelBttn; }
    public void setDisbleDelBttn(boolean b){ this.DisbleDelBttn = b; }
    public boolean getDisbleSaveBttn(){ return DisbleSaveBttn; }
    public void setDisbleSaveBttn(boolean b){ this.DisbleSaveBttn = b; }
    
    Boolean CheckAllRules=false; 
    Boolean CheckAllCounters=false;
    
    public Boolean getCheckAllRules() {return CheckAllRules;  }
    public Boolean getCheckAllCounters() {return CheckAllCounters;  }

    public void setCheckAllRules(Boolean chkAll){CheckAllRules=chkAll;}
    public void setCheckAllCounters(Boolean chkAll){CheckAllCounters=chkAll;}
    
    public void uncheckCheckbox(){
        CheckAllRules=false; 
        CheckAllCounters=false;        
    } 
    public boolean getDisbleRuleSeqBttn(){ return DisbleRuleSeqBttn; }
    public void setDisbleRuleSeqBttn(boolean b){ this.DisbleRuleSeqBttn = b; }
    public Boolean getdisplaySeqPopup(){ return displaySeqPopup; }  
    
    public boolean getDisableCancelBttn(){ return DisableCancelBttn; }
    public void setDisableCancelBttn(boolean b){ this.DisableCancelBttn = b; }

    /*********************************** Functionality for Rule(Process) Starts ********************************************/
    
    public List<SVMXC__ServiceMax_Processes__c> getCounterRuleList(){
        return CounterRuleList;
    }
    
    public void SVMX_AddNewCounterRule(){
        uncheckCheckbox();
        DisbaleChkBox=true;
        DisbaleActiveChkBox = true;
        DisbleNewBttn = true;
        DisbleEdtBttn = true;
        DisbleDelBttn = true;
        showRule = true;
        DisbleSaveBttn = false; 
        DisbleRuleSeqBttn = true;   
        DisableCancelBttn = false;
        for(integer i=0;i<CounterRuleList.size();i++){
            CounterRuleList[i].SVMXC__Select__c=false;              
        }
        CounterRuleProcess = new SVMXC__ServiceMax_Processes__c();  
        CounterRuleProcess.SVMXC__Select__c=true;
        CounterRuleList.add(CounterRuleProcess);        
        showRule = true;
        CounterRec = new SVMXC__Counter_Details__c();
        CounterRecList.add(CounterRec);
    }   
    
    public void SVMX_EdtCounterRule(){      
        string recTyp = 'Definition';       
        EdtCountRec=0;
        IsRuleBlock=true;
        IsConfigQuery = false;
        list<id> Idlst = new list<id>();         
        for(integer i=0;i<CounterRuleList.size();i++){
            if(CounterRuleList[i].SVMXC__Select__c){                
                showRule = true;
                EdtCountRec = EdtCountRec + 1;
                if(EdtCountRec==1){
                    DisbleSaveBttn = false;                 
                    CounterRuleProcess.SVMXC__Name__c = CounterRuleList[i].SVMXC__Name__c;
                    CounterRuleProcess.SVMXC__Description__c= CounterRuleList[i].SVMXC__Description__c;                 
                    CounterRuleProcess.SVMXC__Advance_Expression__c = CounterRuleList[i].SVMXC__Advance_Expression__c;
                    CriExpressions.AdvanceOption = CounterRuleProcess.SVMXC__Advance_Expression__c;
                    IsConfigQuery = true;
                    Idlst.add(CounterRuleList[i].Id);        
                }
            }
        }
        if(IsConfigQuery){                          
            DisbleNewBttn = true;
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
            DisbleRuleSeqBttn = true;
            DisbaleChkBox=true;
            DisbaleActiveChkBox = true;
            DisableCancelBttn = false;
            Cnfiglst.clear();
            Cnfiglst = database.query('Select SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:Idlst');
            CounterRecList=database.Query('Select Id,Counter_Name__c,Counter_Type__c,Grows_Reduces_By__c,Min_Value__c,Max_Value__c,Active__c,Select__c from SVMXC__Counter_Details__c where SVMXC__Counter_Rule__c IN:Idlst and RecordType.Name=:recTyp order by Counter_Name__c');
            system.debug('asdfasdfsss3'+CounterRecList);
            
            mapIDVsCountrName.clear();
            if(CounterRecList != null)
            {
                for(SVMXC__Counter_Details__c objCountrDetail : CounterRecList)
                {
                    if(objCountrDetail.Counter_Name__c != null)
                        mapIDVsCountrName.put(objCountrDetail.Id, objCountrDetail.Counter_Name__c);
                }
            }
                
            if(Cnfiglst.size()>0){
                CriExpressions.lstExpressions.clear();
                for(SVMXC__ServiceMax_Config_Data__c Cnfig :Cnfiglst){
                    CriExpressions.setExpressions(Cnfig);
                }
            }           
        }
        if(EdtCountRec==0){
            showRule = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG018()));
        }
        if(EdtCountRec>1){
            for(integer j=0;j<CounterRuleList.size();j++){
            CounterRuleList[j].SVMXC__Select__c=false;}
            showRule = false;   
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG019()));
        
        }
        
    }
    
    Map<string,integer> CountrMap = new Map<string,integer>();
       public string RuleName;
        boolean ValidateRuleName;
        public boolean SVMX_ValidateRuleName(SVMXC__ServiceMax_Processes__c EntitlementRuleProcess)
        {
            ValidateRuleName = true;
            RuleName = EntitlementRuleProcess.SVMXC__Name__c;
            if(RuleName == null)
            {
               
                ValidateRuleName = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG016()));      
            }
            else
            {
                if(RuleName.length() < 8)
                {
                    
                    ValidateRuleName = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG047()));      
                }
            }
            return ValidateRuleName;
        }
    public void ChangeNameYes()
    {
        CanNameChange = false;
        DisplayNameChangeWarnBtn = false;
        SVMX_SaveProcessRulewithChild();
    }
    
    public void ChangeNameNo()
    {
        if(mapIDVsCountrName != null)
        {
            for(SVMXC__Counter_Details__c objCountrDetail : CounterRecList)
            {
                if(objCountrDetail.Id != null && mapIDVsCountrName.containsKey(objCountrDetail.Id))
                {
                    objCountrDetail.Counter_Name__c = mapIDVsCountrName.get(objCountrDetail.Id);
                }
            }
        }
        CanNameChange = true;
        DisplayNameChangeWarnBtn = false;
    }
    
    public pageReference SVMX_SaveProcessRulewithChild(){
        IsRuleBlock = true;             
        RecordType recType = [select id from RecordType where Name=:'Expressions' and SobjectType=:'SVMXC__ServiceMax_Config_Data__c']; 
        RecordType CrecType = [select id from RecordType where Name=:'Definition' and SobjectType=:'SVMXC__Counter_Details__c'];        
        pageReference p;
        string url;
        boolean IsRuleNull=false;
        boolean IsCountNull = false;        
        boolean SavRec = true;
        boolean SavAllRec = true;
        IsPartsBlock = false;
        boolean IsError = true;
        CounterRuleProcess.RecordTypeId=Rtype.Id;
        CounterRuleProcess.SVMXC__Rule_Type__c='Counters';      
        CountrMap.clear();  
        RuleNameMap.clear();    
        boolean IsValidate = true;
        for(integer i=0;i<CounterRuleList.size();i++)
        { 
            if(CounterRuleList[i].SVMXC__Select__c)
            {         
                CounterRuleProcess.SVMXC__Name__c = CounterRuleList[i].SVMXC__Name__c;
            }
        }
        IsValidate=SVMX_ValidateRuleName(CounterRuleProcess);
        if(IsValidate==false)
        {
            for(integer i=0;i<CounterRuleList.size();i++)
            {
                if(CounterRuleList[i].id==null)
                {
                    CounterRuleList[i].SVMXC__Select__c= true;
                }
                if(RuleId==CounterRuleList[i].id)
                {
                    CounterRuleList[i].SVMXC__Select__c= true;
                }
            }  
            return null;  
        }
        for(integer i=0;i<CounterRuleList.size();i++){                          
            
            if(CounterRuleList[i].SVMXC__Name__c!=null){
                //SavRec = false;
                RuleNameMap.put(CounterRuleList[i].SVMXC__Name__c,i);
            }       
        }
        system.debug('asdfasdfsss3'+CounterRecList);
        if(!IsRuleNull && RuleNameMap.size()>0 && CounterRuleList.size()>0){
            if(RuleNameMap.size()!=CounterRuleList.size()){
                SavRec = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG017()));
            }
            else{
                
                if(SavRec){
                    for(integer i=0;i<CounterRuleList.size();i++){
                        system.debug('asdfasdfsss1'+CounterRuleList[i].id);
                        if(CounterRuleList[i].id==null){
                            CounterRuleProcess.SVMXC__Name__c = CounterRuleList[i].SVMXC__Name__c;
                            CounterRuleProcess.SVMXC__Description__c= CounterRuleList[i].SVMXC__Description__c;                     
                            string headerCriteria = CriExpressions.getCriteria('Product2');
                            system.debug('asdfasdfsss2'+headerCriteria);
                            if(headerCriteria != 'ERROR'){
                                CounterRuleProcess.SVMXC__Parent_Object_Criteria__c = headerCriteria;
                                CounterRuleProcess.SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption; 
                            system.debug('asdfasdfsss3'+CounterRecList);
                                for(integer c=0;c<CounterRecList.size();c++){
                                    system.debug('asdfasdfsss4'+CounterRecList[c].Counter_Name__c);
                                    if(CounterRecList[c].Counter_Name__c==null){                
                                        SavAllRec = false;
                                        IsCountNull = true;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG033()));                           
                                    }
                                    if(CounterRecList[c].Counter_Type__c=='' || CounterRecList[c].Counter_Type__c==null ){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG035()));
                                    }
                                    else if(CounterRecList[c].Min_Value__c==null || CounterRecList[c].Max_Value__c==null){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG037()));
                                    }   
                                    else if(CounterRecList[c].Grows_Reduces_By__c> CounterRecList[c].Max_Value__c){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, getTAG036()));
                                    }                           
                                    else if(CounterRecList[c].Min_Value__c>CounterRecList[c].Max_Value__c){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG038()));
                                    }
                                    if(CounterRecList[c].Counter_Name__c!=null){
                                        //SavAllRec = false;
                                        CountrMap.put(CounterRecList[c].Counter_Name__c,i);
                                    }
                                }
                                if(!IsCountNull && CountrMap.size()>0 && CounterRecList.size()>0){
                                    if(CountrMap.size()!=CounterRecList.size()){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG034()));   
                                    }
                                    else{
                                        if(SavAllRec){
                                            CounterRuleProcess.SVMXC__Select__c= false;
                                            CounterRuleProcess.SVMXC__Sequence__c=i;
                                            //insert CounterRuleProcess;
                      if( COMM_SecurityUtils.getInstance().verifyFieldAccess( CounterRuleProcess, COMM_SecurityUtils.Access.Createable ) ) {
                          //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert CounterRuleProcess;
                      } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                      }
                      
                                            for(integer c=0;c<CounterRecList.size();c++){
                                                    CounterRecList[c].RecordTypeId = CrecType.Id;
                                                    CounterRecList[c].SVMXC__Counter_Rule__c = CounterRuleProcess.Id;
                                                }
                                            //upsert CounterRecList;
                      if( COMM_SecurityUtils.getInstance().verifyFieldAccess( CounterRecList, COMM_SecurityUtils.Access.Upsertable ) ) {
                          //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert CounterRecList;
                      } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                      }
                      
                                            mapCriExpressionsProperties.put('RecordTypeID',recType.Id);
                                            mapCriExpressionsProperties.put('SVMXC__Expression_Type__c', 'IPRD_Counters');
                                            mapCriExpressionsProperties.put('SVMXC__Expression_Rule__c', CounterRuleProcess.Id);
                                            CriExpressions.getExpressions(mapCriExpressionsProperties);
                                            DisbaleChkBox=false;
                                            DisbaleActiveChkBox= false;                             
                                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG021())); 
                                            showRule = false;
                                            DisbleNewBttn = false;
                                            DisbleEdtBttn = false;
                                            DisbleDelBttn = false;
                                            DisbleRuleSeqBttn = false;
                                            IsError = false;
                                            url = '/apex/IPRD_ManageCounters';
                                        }
                                    }
                                }
                            }                                                                           
                        }                       
                        else if(CounterRuleList[i].id!=null){
                            if(CounterRuleList[i].SVMXC__Select__c){
                                boolean isNameChanged = false;
                                for(integer c=0;c<CounterRecList.size();c++){
                                    if(CounterRecList[c].Counter_Name__c==null){                
                                        SavAllRec = false;
                                        IsCountNull = true;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG033()));                           
                                    }
                                    else if(CounterRecList[c].Counter_Type__c=='' || CounterRecList[c].Counter_Type__c==null ){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG035()));
                                    }
                                    else if(CounterRecList[c].Min_Value__c==null || CounterRecList[c].Max_Value__c==null){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG037()));
                                    }   
                                    else if(CounterRecList[c].Grows_Reduces_By__c> CounterRecList[c].Max_Value__c){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, getTAG036()));
                                    }                           
                                    else if(CounterRecList[c].Min_Value__c>CounterRecList[c].Max_Value__c){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG038()));
                                    }
                                    if(CounterRecList[c].Counter_Name__c!=null){
                                        //SavAllRec = false;
                                        CountrMap.put(CounterRecList[c].Counter_Name__c,i);
                                    }
                                    if(CanNameChange)
                                    {
                                        if(CounterRecList[c].Id != null && CounterRecList[c].Counter_Name__c !=null && CounterRecList[c].Counter_Name__c != '' && mapIDVsCountrName.containsKey(CounterRecList[c].Id))
                                        {
                                            System.debug('Previous Name is : '+mapIDVsCountrName.get(CounterRecList[c].Id)+' and New Name is '+CounterRecList[c].Counter_Name__c);
                                            if(mapIDVsCountrName.get(CounterRecList[c].Id) != CounterRecList[c].Counter_Name__c) 
                                                isNameChanged = true;
                                        }
                                    }
                                }
                                System.debug('value of SavAllRec is : '+SavAllRec+' and value of isNameChanged '+isNameChanged);
                                if(!IsCountNull && CountrMap.size()>0 && CounterRecList.size()>0){
                                    if(CountrMap.size()!=CounterRecList.size()){
                                        SavAllRec = false;
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG034()));   
                                    }
                                    else
                                    {
                                        if(SavAllRec)
                                        {
                                            if(isNameChanged)
                                            {
                                                DisplayNameChangeWarnBtn = true;
                                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.WARNING, getTAG050()));  
                                            }
                                            else
                                            {
                                                string headerCriteria = CriExpressions.getCriteria('Product2');
                                                if(headerCriteria != 'ERROR'){
                                                    CounterRuleList[i].SVMXC__Parent_Object_Criteria__c = headerCriteria;
                                                    CounterRuleList[i].SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption; 
                                                
                                                    CounterRuleList[i].SVMXC__Select__c= false;
                                                    CounterRuleList[i].SVMXC__Sequence__c=i;
                                                    
                          //update CounterRuleList;
                          if(COMM_SecurityUtils.getInstance().verifyFieldAccess(CounterRuleList, COMM_SecurityUtils.Access.Updateable)){
                              //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            update CounterRuleList;
                          }
                          else{
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                          }
                          
                                                    for(integer c=0;c<CounterRecList.size();c++){
                                                        CounterRecList[c].RecordTypeId = CrecType.Id;
                                                        CounterRecList[c].SVMXC__Counter_Rule__c = CounterRuleList[i].Id;
                                                    }
                                                    //upsert CounterRecList;                                          
                          if( COMM_SecurityUtils.getInstance().verifyFieldAccess( CounterRecList, COMM_SecurityUtils.Access.Upsertable ) ) {
                              //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            upsert CounterRecList;
                          } else {
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                            return null;
                          }
                          
                                                    mapCriExpressionsProperties.put('RecordTypeID',recType.Id);
                                                    mapCriExpressionsProperties.put('SVMXC__Expression_Type__c', 'IPRD_Counters');
                                                    mapCriExpressionsProperties.put('SVMXC__Expression_Rule__c', CounterRuleList[i].Id);
                                                    CriExpressions.getExpressions(mapCriExpressionsProperties);
                                                    DisbaleChkBox=false;
                                                    DisbaleActiveChkBox= false;                             
                                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG021())); 
                                                    showRule = false;
                                                    DisbleNewBttn = false;
                                                    DisbleEdtBttn = false;
                                                    DisbleDelBttn = false;
                                                    DisbleRuleSeqBttn = false;
                                                    IsError = false;
                                                    CanNameChange = true;
                                                    url = '/apex/IPRD_ManageCounters';
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if(IsError){
            p=null;}    
        else{           
            p=new pageReference(url);
            p.setRedirect(true);}           
        return p;                       
    }
        
    public PageReference SVMX_DelCounterRule(){     
        List<SVMXC__ServiceMax_Processes__c> CounterRuleIds = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> TempCounterRuleIds = new List<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> TempCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
        
        List<SVMXC__Counter_Details__c>CounterDef = new List<SVMXC__Counter_Details__c>();
        List<SVMXC__Counter_Details__c> CounterCvrgRead = new List<SVMXC__Counter_Details__c>();
        //To delete the Roll ups whenever the Counter Definitions are deleted
        List<SVMXC__Counter_Rollup__c> counterRollupDeleteList = new List<SVMXC__Counter_Rollup__c>();
        List<sObject> PMCvrage ;
        IsRuleBlock = true;
        list<id> DelIdLst = new list<id>();
        list<id> CountIdLst = new list<id>();
        IsPartsBlock = false;
        boolean DelRec=true;
        string PMString;
        for(integer i=0;i<CounterRuleList.size();i++){
            if(CounterRuleList[i].SVMXC__Select__c){
                DelPRCountRec=true;             
                if(CounterRuleList[i].Id!=NULL){
                    DelIdLst.add(CounterRuleList[i].Id);
                    CounterRuleIds.add(CounterRuleList[i]);}            
            }
            else
                TempCounterRuleIds.add(CounterRuleList[i]); 
        }
        if(!DelPRCountRec){
            DelRec=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011()));
        }       
        if(DelRec){
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            TempCnfiglst = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:CounterRuleIds];
            CounterDef = [Select Id from SVMXC__Counter_Details__c where SVMXC__Counter_Rule__c IN:CounterRuleIds and RecordType.Name=:'Definition'];
            if(CounterDef.size()>0){
                for(SVMXC__Counter_Details__c c:CounterDef){
                    CountIdLst.add(c.Id);
                }
                CounterCvrgRead = [Select Id from SVMXC__Counter_Details__c where SVMXC__Counter_Definition__c IN:CountIdLst and (RecordType.Name=:'Coverage' or RecordType.Name=:'Reading')];
                counterRollupDeleteList = [SELECT Id FROM SVMXC__Counter_Rollup__c WHERE SVMXC__Counter_Definition__c IN : CountIdLst];
                /*if(allobjects.containsKey('SVMXP__PM_Coverage__c')){ 
                    PMString = 'Select Id from SVMXP__PM_Coverage__c where SVMXP__Counter_Definition__c IN:CountIdLst';
                    PMCvrage = dataBase.query(PMString);
                    if(PMCvrage.size()>0){
                        delete PMCvrage;
                    }
                }*/
            }
            
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Counter_Details__c' ) ) {
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete CounterCvrgRead;
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete CounterDef;
            } else {
                DelRec=false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));                
                return null;
            }
            
            if(!counterRollupDeleteList.isEmpty()) {
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Counter_Rollup__c' ) ) {
                        //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete counterRollupDeleteList;
                } else {
                    DelRec=false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));                
                    return null;
                }
            }
               
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                delete TempCnfiglst;
            } else {
                DelRec=false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));                
                return null;
            }
            
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                delete CounterRuleIds;
            } else {
                DelRec=false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));                
                return null;
            }
                      
            Cnfiglst.clear();
            CounterRuleList.clear();
            CounterRuleList = TempCounterRuleIds;
            if(CounterRuleList.size()<=1){
                DisbleRuleSeqBttn = true;
            }
            else
            DisbleRuleSeqBttn = false;
            
            if(CounterRuleList.size()<=0){
                showRule = false;
                DisbleEdtBttn = true;
                DisbleDelBttn = true;
                DisableCancelBttn = true;
            }
            else{
                DisbleNewBttn = false;
                DisbleEdtBttn = false;
            }           
        }       
        DelPRCountRec = false;      
        uncheckCheckbox();
        return null;
    }
    
    public PageReference SVMX_Cancel(){
        String url = '/apex/SVMXC__IPRD_ManageCounters';
        pageReference p=new pageReference(url);
        for(integer j=0;j<CounterRuleList.size();j++){
            CounterRuleList[j].SVMXC__Select__c=false;
            if(CounterRuleList[j].Id==null){
                CounterRuleList.remove(j);
            }
        }
        showRule = false;
        DisbaleChkBox=false;
        DisbaleActiveChkBox= false;
        DisbleNewBttn = false;
        DisbleEdtBttn = false;
        p.setRedirect(true);
        return p;
    }
    
    public PageReference SVMX_GoSetupHome(){
       //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
       //String url = '/apex/SVMXC__CONF_SetupHome';
       String url='';
       if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
       }else{
            url ='/apex/SVMXC__CONF_SetupHome';
       }
       //Changes done by Nidhi ends here
       //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
      PageReference HomePage = new PageReference(url);
      HomePage.setRedirect(true);
      return HomePage; 
    }   
    
    /*********************************** Functionality for Rule(Process) Ends ********************************************/
    
    /*********************************** Functionality for Order Sequence Starts ********************************************/
    
    public List<SelectOption> Seqoptions = new List<SelectOption>();
    public Map<string,Integer> MyMap = new  Map<string,Integer>();
    public string[] items = new String[]{};
    public integer selIndex = 0;
    public boolean isUpAction = false;
    public boolean isDownAction = false;
    public boolean isTopAction = false;
    public boolean isBottomAction = false;
    
    public void SVMX_OrderSequence(){
        
        boolean DisableParntLst = true;
        TempCounterRuleList.addAll(CounterRuleList);
        for(integer i=0;i<CounterRuleList.size();i++){
            if(CounterRuleList[i].SVMXC__Select__c){
                DisableParntLst = true;
            }
        }
        if(DisableParntLst){
            displaySeqPopup = true;
            DisbaleChkBox=true;
            DisbaleActiveChkBox = true;
            DisbleNewBttn = true;
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
            DisbleRuleSeqBttn = true;
        }
    }
    
    public List<SelectOption> getSeqoptions(){    
        Seqoptions = new List<SelectOption>();            
        if (TempCounterRuleList.Size() >0){
            for(SVMXC__ServiceMax_Processes__c s:TempCounterRuleList){                              
                if (s.SVMXC__Name__c != null)
                Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        }        
        return Seqoptions; 
    }
    public string[] getitems(){
        return items;
    }    
    public void setitems(string[] o){
        this.items=o;
    }
    
    public void shuffle(integer selIndex, boolean isTop ){
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop){
            temp = TempCounterRuleList[selIndex];
            for(integer j=selIndex;j>0;j--){
                TempCounterRuleList[j] = TempCounterRuleList[j-1];
            }
            TempCounterRuleList[0] = temp;
        }
        else {
            temp = TempCounterRuleList[selIndex];
            for(integer j=selIndex;j<TempCounterRuleList.size()-1;j++){
                TempCounterRuleList[j] = TempCounterRuleList[j+1];
            }
            TempCounterRuleList[TempCounterRuleList.size()-1] = temp;
        }
    }   
    public void UP(){    
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempCounterRuleList.size();j++){
            for(integer i=0;i<items.size();i++){
                if(items[i]==TempCounterRuleList[0].Id){
                    TempCounterRuleList[j] = TempCounterRuleList[j];
                        break;
                }
                else if(items[i]==TempCounterRuleList[j].Id){
                    temp = TempCounterRuleList[j]; 
                    TempCounterRuleList[j] = TempCounterRuleList[j-1];
                    TempCounterRuleList[j-1]=temp;                    
                    selIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    TempCounterRuleList[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    TempCounterRuleList[selIndex].SVMXC__Sequence__c = selIndex;
                }
            }
        }
    }
    public void Down(){        
        SVMXC__ServiceMax_Processes__c temp;
        for(integer i=0;i<items.size();i++){
            MyMap.Put(items[i],i);
        }
        for(integer i=0;i<items.size();i++){
            for(integer k=0;k<TempCounterRuleList.size()-1;k++){
                if(items[i]==TempCounterRuleList[k].Id){
                    temp = TempCounterRuleList[k];
                    TempCounterRuleList[k] = TempCounterRuleList[k+1];
                    TempCounterRuleList[k+1]=temp;
                    selIndex = k;
                    isUpAction = false;
                    isDownAction=true;
                    isTopAction=false;
                    isBottomAction=false;
                    TempCounterRuleList[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                    TempCounterRuleList[selIndex].SVMXC__Sequence__c = selIndex;
                    break;                         
                }
            }
        }   
    }
    public void Top(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempCounterRuleList.size()-1;j>0;j--){
            for(integer i=items.size()-1;i>=0;i--){
                if(items[i] == TempCounterRuleList[j].Id){
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
    
    public void Bottom(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempCounterRuleList.size()-1;j++){
            for(integer i=0;i<items.size();i++){
                if(items[i] == TempCounterRuleList[j].Id){
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
    
    public pagereference SVMX_SaveSequence(){
        SVMXC__ServiceMax_Processes__c temp;
        double t;
        if(isUpAction){
            //update TempCounterRuleList;
      if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempCounterRuleList, COMM_SecurityUtils.Access.Updateable)){
          //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        update TempCounterRuleList;
      }
      else{
        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
      }
        }
        else if(isDownAction){
            //update TempCounterRuleList;
      if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempCounterRuleList, COMM_SecurityUtils.Access.Updateable)){
          //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        update TempCounterRuleList;
      }
      else{
        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
      }
        }
        else if(isTopAction){
            for(integer i=0;i<TempCounterRuleList.size();i++){
                TempCounterRuleList[i].SVMXC__Sequence__c=i;
            }
            //update TempCounterRuleList;
      if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempCounterRuleList, COMM_SecurityUtils.Access.Updateable)){
          //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        update TempCounterRuleList;
      }
      else{
        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
      }
        }
        else if(isBottomAction){
            for(integer i=0;i<TempCounterRuleList.size();i++){
                TempCounterRuleList[i].SVMXC__Sequence__c=i;
            }
            //update TempCounterRuleList;
      if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempCounterRuleList, COMM_SecurityUtils.Access.Updateable)){
          //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        update TempCounterRuleList;
      }
      else{
        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
      }
        }
        return SVMX_Cancel();
    }
    /*********************************** Functionality for Order Sequence Ends ********************************************/
    
    
    /*****************************Functionality for Counter Details Starts *****************************/
    
    
    
    public void SVMX_AddnewCounter(){
        CounterRec = new SVMXC__Counter_Details__c();
        CounterRecList.add(CounterRec);
    }
    public List<SVMXC__Counter_Details__c> getCounterRecList(){
        return CounterRecList;
    }   
    
    boolean DelPrdCount = false;
    public boolean getDelPrdCount(){ return DelPrdCount; }
    public void setDelPrdCount(boolean b){ this.DelPrdCount = b; }
    
    public PageReference SVMX_DelCounterRec(){      
        List<SVMXC__Counter_Details__c> CounterRecIDs = new List<SVMXC__Counter_Details__c>();
        List<SVMXC__Counter_Details__c> TempCounterRecIDs = new List<SVMXC__Counter_Details__c>();
        List<SVMXC__Counter_Details__c> CounterCvrgRead = new List<SVMXC__Counter_Details__c>();
        List<sObject> PMCvrage ;
        string PMString;
        List<Id> Ids = new List<Id>();
        Map<integer,string> CountMap = new Map<integer,string>();
        boolean DelRec=true;
        IsRuleBlock = false;
        IsPartsBlock = true;        
        for(integer i=0;i<CounterRecList.size();i++){
            if(CounterRecList[i].SVMXC__Select__c){
                DelPrdCount=true;
                CountMap.put(i,'');
                if(CounterRecList[i].Id!=NULL){
                Ids.add(CounterRecList[i].Id);
                CounterRecIDs.add(CounterRecList[i]);}                      
            }
            else
                TempCounterRecIDs.add(CounterRecList[i]);   
        }
        
        if(!DelPrdCount){
            DelRec = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG030()));
        }
        if(CountMap.size()==CounterRecList.size()){
            DelRec=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG031()));
        }
        if(Ids.size()>0){
            CounterCvrgRead = [Select Id from SVMXC__Counter_Details__c where SVMXC__Counter_Definition__c IN:Ids and (RecordType.Name=:'Coverage' or RecordType.Name=:'Reading')];
                /*if(allobjects.containsKey('SVMXP__PM_Coverage__c')){
                    PMString = 'Select Id from SVMXP__PM_Coverage__c where SVMXP__Counter_Definition__c IN:Ids';
                    PMCvrage = dataBase.query(PMString);
                }*/
            
            //if(CounterCvrgRead.size()>0 || PMCvrage.size()>0){
            if(CounterCvrgRead.size()>0){
                DelRec = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG032()));
            }
        }
        if(DelRec){
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Counter_Details__c' ) ) {
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete CounterRecIDs;
                CounterRecList.clear();
              CounterRecList = TempCounterRecIDs;
            } else {
                DelRec = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));                
            }
        }       
        DelPrdCount = false;
        return null;
    }
    /*****************************Functionality for Counter Details Ends *****************************/
    
    /****************************** Functionality for Expression(Config Data) Starts ************************************/
    //Code Added for Search Expression************
    
    public Map<String, SelectOption>  mapHdrObjOpt = new Map<String, SelectOption>();
    public Map<String, SelectOption>  mapLineObjOpt = new Map<String, SelectOption>();
    public List<SelectOption> lstLineObjOpt = new List<SelectOption>(); //list of line object values
    public Map<String,String>  HeaderObjApiLocalName = new Map<String,String>();
    public Map<String,String>  HdrObjApiLable = new Map<String,String>();
    public SVMXC__ServiceMax_Processes__c objSVMXPro;
    public SVMXC__ServiceMax_Processes__c getobjSVMXPro() {return this.objSVMXPro;}
    public void setobjSVMXPro(SVMXC__ServiceMax_Processes__c sP){this.objSVMXPro = sP;}
   
    public List<SelectOption> getlstHdrObjOpt() { return sortingSelectOption(mapHdrObjOpt.values(), true);}
    public List<SelectOption> getlstLineObjOpt() {return sortingSelectOption(mapLineObjOpt.values(), true);}
 
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
    public void ClearSelOptMap ( map<string,SelectOption> m){
        m.clear();
        m.put('', new SelectOption('',getTAG020()));
    }         
 
    public List<selectoption> Hdrfldlist = new List<selectoption>();  //list of fields values
    public List<selectoption> getHdrFldlist() {return sortingSelectOption(Hdrfldlist, true);}
     
    public void ClearSelOptList(List<SelectOption> lst){
        lst.clear();
        lst.add(new SelectOption('SVMX.NONE',getTAG020()));
    }

    public PageReference OnHdrObjSelect(){
        ClearSelOptList(Hdrfldlist);
        RetriveField('product2', Hdrfldlist, CriExpressions.mapFieldDispType, CriExpressions.FieldApiLable);
        CriExpressions.FieldsList = Hdrfldlist;        
        CriExpressions.objfieldMap = mMapFieldList.get('product2');       
        system.debug('mMapFieldList' + mMapFieldList);
        system.debug('CriExpressions.FieldsList' + CriExpressions.FieldsList);
        return null;
    }


    public List<SelectOption> sortingSelectOption(List<SelectOption> so, boolean bSortByLabel){
        map<string, selectOption> mapTemp = new map<string, SelectOption>();
        if(bSortByLabel){
            for(selectOption o :so){
                mapTemp.put(o.getLabel()+'-'+o.getValue(), o);
            }
        }
        else{
            for(selectOption o :so){
                mapTemp.put(o.getValue()+'-'+o.getLabel(), o);
            }
        }
        list<string> lstTemp = new list<string>();
        lstTemp.addAll(mapTemp.KeySet());
        lstTemp.sort();
        so.clear();
        for(string str: lstTemp){
            so.add(mapTemp.get(str));
        }
        return so;
    }
/*
    COMM_SVMXC_Search_Expressions ExpressionsTemp;
    public string SelectedLabel;
    public string SelectedID;
    public Boolean isSearch = false;
    public Boolean isDateSearch = false;
    COMM_SVMXC_SearchRecords SR = new COMM_SVMXC_SearchRecords();    
    
    public string getSelectedID() {return this.SelectedID;}
    public void setSelectedID(string str) {this.SelectedID = str;}
   
    public string getSelectedLabel() {return this.SelectedLabel;}
    public void setSelectedLabel(string str) {this.SelectedLabel = str;} 
    
    public COMM_SVMXC_SearchRecords getSR (){return this.SR;}
    public boolean getisDateSearch(){return this.isDateSearch;}
    public boolean getisSearch(){return this.isSearch;}
    
    public void HdrFind(){
        find(CriExpressions);
        isSearch = true;
    }
    
    public void HdrFindDate(){
        find(CriExpressions);
        isDateSearch = true;
    }
    
    public void Do_Search(){ SR.Do_Search();}    
    public void Do_CancelSearch(){ isDateSearch = false; isSearch = false;} 
    
    public void Do_Select(){
        string s = SR.getDate();
        if(s != null ){
            ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = s; 
            isDateSearch = false;
        }
    }
    public void OnselectRecord(){
        ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = SelectedLabel;
        ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].OperandID = SelectedID;
        isSearch = false;
    }
    
    public void find(COMM_SVMXC_Search_Expressions Expressions){
        ExpressionsTemp = Expressions;
        SR = new  COMM_SVMXC_SearchRecords(Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].ObjectName, Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand, Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].ObjectNameField, Expressions.ExpressionType );
    }
    
    public void OnHdrEntryCriFieldSelect(){ 
        CriExpressions.objfieldMap = mMapFieldList.get('product2'); 
        CriExpressions.OnChangeField(integer.valueOf(SelectedIndex), true);
    }
    */
    COMM_SVMXC_SearchRecords SR = new COMM_SVMXC_SearchRecords();
        public COMM_SVMXC_SearchRecords getSR (){return this.SR;}
    public void HdrFind()
    {
        try
        {
            find(CriExpressions);
            isSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void HdrFindDate()
    {
        try
        {
            find(CriExpressions);
            isDateSearch = true;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public void Do_Search(){ try{SR.Do_Search();}catch(exception ex){AddException(ex.getMessage());}}
    public void Do_Select()
    {
        try
        {
            string s = SR.getDate();
            if(s != null )
            {
                ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = s; 
                isDateSearch = false;
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    } 
    COMM_SVMXC_Search_Expressions ExpressionsTemp;
    public void Do_CancelSearch(){ isDateSearch = false; isSearch = false;} 
    public string SelectedID;
        public string getSelectedID() {return this.SelectedID;}
        public void setSelectedID(string str) {this.SelectedID = str;}
    public string SelectedLabel;
        public string getSelectedLabel() {return this.SelectedLabel;}
        public void setSelectedLabel(string str) {this.SelectedLabel = str;}        
        
    public Boolean isSearch = false;
        public boolean getisSearch(){return this.isSearch;}
     public Boolean isDateSearch = false;
        public boolean getisDateSearch(){return this.isDateSearch;}
    public void OnselectRecord()
    {
        try
        {
            string selectedID = SR.getselectedId();
            if(selectedID != null && selectedID.length() > 0)
            {
                ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = SR.getselectedLabel();
                //ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].OperandID = SR.getSelectedID();
                isSearch = false;
            }
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void OnselectCurrentUser()
    {
        try
        {
            ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = 'Current User';
            //ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].OperandID = 'SVMX.CurrentUser';
            isSearch = false;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void OnselectRecordOwner()
    {
        try
        {
            ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand = 'Record Owner';
            //ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].OperandID = 'SVMX.Owner';
            isSearch = false;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void OnHdrEntryCriFieldSelect()
    {
        try
        {
            CriExpressions.objfieldMap = mMapFieldList.get('product2'); 
            CriExpressions.OnChangeField(integer.valueOf(SelectedIndex), true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public void find(COMM_SVMXC_Search_Expressions Expressions)
    {
        try
        {
            ExpressionsTemp = Expressions;
            SR = new  COMM_SVMXC_SearchRecords(Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].ObjectName, Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand, Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].ObjectNameField, Expressions.ExpressionType );
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public Map<String, Schema.SObjectType> allobjs =new Map<String, Schema.SObjectType>();
        public Map<String, Schema.SObjectType> allobjs2 =  Schema.getGlobalDescribe();
    public List<string> st = new list<string>();
    Boolean disableValue =false;
    
    public Boolean getDisableValue(){
        return disableValue;
    } 
    public string SelectedIndex;
    public string getSelectedIndex (){return this.SelectedIndex;}
    public void setSelectedIndex (string str){this.SelectedIndex = str;}
    
    public void HdrADDRow(){ CriExpressions.addCriteriaExpression(1);}
    public void HdrDeleteRow(){ CriExpressions.removeCriteriaExpression(integer.valueOf(SelectedIndex));}
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''));
    }
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    } 
    /****************************** Functionality for Expression(Config Data) Starts ************************************/
    
    /****************************** Code Block Ends ************************************/   
    
}