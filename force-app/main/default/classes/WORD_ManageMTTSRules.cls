public with sharing class WORD_ManageMTTSRules {
         
    /****************************** Code Block Starts ************************************/
    
    // public SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD012');
    
    //public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    //public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('WORD012');
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();

     
    /****************************** Translations ************************************/
    public String getTAG001() {return System.Label.WORD012_TAG001;}
    public String getTAG002() {return System.Label.WORD012_TAG002;}
    public String getTAG003() {return System.Label.WORD012_TAG003;}
    public String getTAG004() {return System.Label.WORD012_TAG004;}
    public String getTAG005() {return System.Label.WORD012_TAG005;}
    public String getTAG006() {return System.Label.WORD012_TAG006;}
    public String getTAG007() {return System.Label.WORD012_TAG007;}
    public String getTAG008() {return System.Label.WORD012_TAG008;}
    public String getTAG009() {return System.Label.WORD012_TAG009;}
    public String getTAG010() {return System.Label.WORD012_TAG010;}
    public String getTAG011() {return System.Label.WORD012_TAG011;}
    public String getTAG012() {return System.Label.WORD012_TAG012;}
    public String getTAG013() {return System.Label.WORD012_TAG013;}
    public String getTAG014() {return System.Label.WORD012_TAG014;}
    public String getTAG015() {return System.Label.WORD012_TAG015;}
    public String getTAG016() {return System.Label.WORD012_TAG016;}
    public String getTAG017() {return System.Label.WORD012_TAG017;}
    public String getTAG018() {return System.Label.WORD012_TAG018;}
    public String getTAG019() {return System.Label.WORD012_TAG019;}
    public String getTAG020() {return System.Label.WORD012_TAG020;}
    public String getTAG021() {return System.Label.WORD012_TAG021;}
    public String getTAG022() {return System.Label.WORD012_TAG022;}  
    public String getTAG023() {return System.Label.WORD012_TAG023;}  
    public String getTAG024() {return System.Label.WORD012_TAG024;}  
    public String getTAG025() {return System.Label.WORD012_TAG025;}  
    public String getTAG026() {return System.Label.WORD012_TAG026;}
    public String getTAG027() {return System.Label.WORD012_TAG027;}
    public String getTAG028() {return System.Label.WORD012_TAG028;}
    public String getTAG029() {return System.Label.WORD012_TAG029;}
    public String getTAG030() {return System.Label.WORD012_TAG030;}
    // public String getTAG031() {return System.Label.WORD012_TAG031;}
    public String getHLPURL() {return System.Label.WORD012_HLPURL;}
    /****************************** Variable Declaration ************************************/
    
    public List<SVMXC__ServiceMax_Processes__c> MTTSRuleList = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> TempMTTSRuleList = new List<SVMXC__ServiceMax_Processes__c>();
    list<SVMXC__ServiceMax_Config_Data__c> Cnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
    List<Id> PartsRuleIds = new List<Id>();
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
    string ruleId;
    
    map<string, string> mapCriExpressionsProperties = new map<string, string>();
    transient public map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map<string, Map<String,Schema.SObjectField>> ();
    transient public Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
    public COMM_SVMXC_Search_Expressions CriExpressions = new COMM_SVMXC_Search_Expressions(2); 
    public SVMXC__ServiceMax_Processes__c MTTSRuleProcess = new SVMXC__ServiceMax_Processes__c();
    public boolean IsEnterpriseLicense = false;
    public Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
    SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    
    public COMM_SVMXC_Search_Expressions getCriExpressions() {return CriExpressions;}
    public SVMXC__ServiceMax_Processes__c getMTTSRuleProcess() {return this.MTTSRuleProcess;}
    public void setMTTSRuleProcess(SVMXC__ServiceMax_Processes__c prs){this.MTTSRuleProcess=prs;}
    
    /****************************** Constructor Defined ************************************/
    
    public WORD_ManageMTTSRules(){
         //Added by amar on 19/Aug/10 Due to OEM Exercises
        IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
        if(!IsEnterpriseLicense)
        {
             PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
        }
        system.debug('allobjs'+allobjs);
        //allobjs.putAll(allobjs2); commenting the line to add only workorder object field to reduce heap size
        // allobjs.put('service_order__c',allobjs2); 
        // Replacing the fully qualified name of the object. 
        allobjs.put('SVMXC__Service_Order__c',allobjs2);
                
        Rtype = [select Id from RecordType where Name=:'SVMX Rule']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        MTTSRuleList=[select Id,Name,MTTS_Minutes__c,SVMXC__Sequence__c,SVMXC__Advance_Expression__c,SVMXC__Description__c,SVMXC__Name__c,SVMXC__Select__c from SVMXC__ServiceMax_Processes__c where RecordType.Name='SVMX Rule' and SVMXC__Rule_Type__c='MTTS' order by SVMXC__Sequence__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__ServiceMax_Processes__c PR: MTTSRuleList){
            PartsRuleIds.add(PR.Id);
            //RuleNameMap.put(PR.SVMXC__Name__c, PR.Id);
        }
        if(MTTSRuleList.size()<=1){
            DisbleRuleSeqBttn = true;
        }
        
        DisableCancelBttn = true;       
        DisbleSaveBttn = true; 
        if(MTTSRuleList.size()==0){
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
        }   
        CriExpressions.DefaultField = getTAG021();
        CriExpressions.DefaultOperator = getTAG021();
        CriExpressions.DefaultListValue = getTAG021();
        CriExpressions.ExpressionType = 'CRITERIA'; 
        
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
            
    }
    
    /****************************** Getter/Setter Functioanlity ************************************/
    
    public boolean getDisbaleChkBox(){ return DisbaleChkBox; }
    public void setDisbaleChkBox(boolean b){ this.DisbaleChkBox = b; }
    
    public boolean getshowRule(){ return showRule; }
    public void setshowRule(boolean b){ this.showRule = b; }
    
    public boolean getDelPRCountRec(){ return DelPRCountRec; }
    public void setDelPRCountRec(boolean b){ this.DelPRCountRec = b; }
    
    public boolean getIsRuleBlock(){ return IsRuleBlock; }
    public void setIsRuleBlock(boolean b){ this.IsRuleBlock = b; }
    
    public boolean getIsPartsBlock(){ return IsPartsBlock; }
    public void setIsPartsBlock(boolean b){ this.IsPartsBlock = b; }
    
    Boolean CheckAllRules=false;
    public Boolean getCheckAllRules() {return CheckAllRules;  }
    public void setCheckAllRules(Boolean chkAll){CheckAllRules=chkAll;} 
    public void uncheckCheckbox(){
        CheckAllRules=false; 
    } 
    public Boolean getdisplaySeqPopup(){ return displaySeqPopup; }  
    public boolean getDisbleRuleSeqBttn(){ return DisbleRuleSeqBttn; }
    public void setDisbleRuleSeqBttn(boolean b){ this.DisbleRuleSeqBttn = b; }
    
    public boolean getDisbleNewBttn(){ return DisbleNewBttn; }
    public void setDisbleNewBttn(boolean b){ this.DisbleNewBttn = b; }
    public boolean getDisbleEdtBttn(){ return DisbleEdtBttn; }
    public void setDisbleEdtBttn(boolean b){ this.DisbleEdtBttn = b; }
    public boolean getDisbleDelBttn(){ return DisbleDelBttn; }
    public void setDisbleDelBttn(boolean b){ this.DisbleDelBttn = b; }
    public boolean getDisbleSaveBttn(){ return DisbleSaveBttn; }
    public void setDisbleSaveBttn(boolean b){ this.DisbleSaveBttn = b; }
    public boolean getDisbaleActiveChkBox(){ return DisbaleActiveChkBox; }
    public void setDisbaleActiveChkBox(boolean b){ this.DisbaleActiveChkBox = b; }
    
    public boolean getDisableCancelBttn(){ return DisableCancelBttn; }
    public void setDisableCancelBttn(boolean b){ this.DisableCancelBttn = b; }
    
    /*********************************** Functionality for Rule(Process) Starts ********************************************/
    
    public List<SVMXC__ServiceMax_Processes__c> getMTTSRuleList(){
        return MTTSRuleList;
    }
    
    public void SVMX_AddNewMTTSRule(){
        DisbaleChkBox=true;
        DisbaleActiveChkBox = true;
        showRule = true;        
        for(integer i=0;i<MTTSRuleList.size();i++){
            MTTSRuleList[i].SVMXC__Select__c=false;             
        }
        MTTSRuleProcess = new SVMXC__ServiceMax_Processes__c(); 
        MTTSRuleProcess.SVMXC__Select__c=true;
        MTTSRuleList.add(MTTSRuleProcess);
        DisbleNewBttn = true;
        DisbleEdtBttn = true;
        DisbleDelBttn = true;
        showRule = true;
        DisbleSaveBttn = false;
        DisbleRuleSeqBttn = true;
        DisableCancelBttn = false;
        uncheckCheckbox();
        
    }   
    
    public void SVMX_EdtMTTSRule(){
        system.debug('entered edit');       
        EdtCountRec=0;      
        IsRuleBlock=true;
        IsConfigQuery = false;
        list<id> Idlst = new list<id>();         
        for(integer i=0;i<MTTSRuleList.size();i++){
            if(MTTSRuleList[i].SVMXC__Select__c){
                ruleId=MTTSRuleList[i].Id;              
                showRule = true;
                EdtCountRec = EdtCountRec + 1;
                if(EdtCountRec==1){ 
                    DisbleSaveBttn = false;             
                    MTTSRuleProcess.SVMXC__Name__c = MTTSRuleList[i].SVMXC__Name__c;
                    MTTSRuleProcess.SVMXC__Description__c= MTTSRuleList[i].SVMXC__Description__c;
                    MTTSRuleProcess.MTTS_Minutes__c = MTTSRuleList[i].MTTS_Minutes__c;
                    MTTSRuleProcess.SVMXC__Advance_Expression__c = MTTSRuleList[i].SVMXC__Advance_Expression__c;
                    CriExpressions.AdvanceOption = MTTSRuleProcess.SVMXC__Advance_Expression__c;
                    IsConfigQuery = true;
                    Idlst.add(MTTSRuleList[i].Id);       
                }
            }
        }
        if(IsConfigQuery){                          
            Cnfiglst.clear();
            Cnfiglst = database.query('Select SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:Idlst');
            if(Cnfiglst.size()>0){
                CriExpressions.lstExpressions.clear();
                for(SVMXC__ServiceMax_Config_Data__c Cnfig :Cnfiglst){
                    CriExpressions.setExpressions(Cnfig);
                }               
            }
            DisbaleChkBox=true;
            DisbaleActiveChkBox = true;
            DisbleNewBttn = true;
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
            DisbleRuleSeqBttn = true;
            DisableCancelBttn = false;          
        }
        if(EdtCountRec==0){
            showRule = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG018()));
        }
        if(EdtCountRec>1){
            for(integer j=0;j<MTTSRuleList.size();j++){
            MTTSRuleList[j].SVMXC__Select__c=false;}
            showRule = false;   
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG019()));           
        }           
    }
        public string RuleName;
        boolean ValidateRuleName;
      
        public boolean SVMX_ValidateRuleName(SVMXC__ServiceMax_Processes__c MTTSRuleProcess)
        {
            ValidateRuleName = true;
            RuleName = MTTSRuleProcess.SVMXC__Name__c;
            if(RuleName  == null)
            {
               
                ValidateRuleName=false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG016()));     
            }
            else
            {
                if(RuleName.length() < 8)
                {
                   
                    ValidateRuleName=false;
                     ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG030()));      
              
                }
            }
            return ValidateRuleName;
        }   
    
    public pageReference SVMX_SaveProcessRulewithChild(){
        system.debug('Entered Save');
        IsRuleBlock = true;             
        RecordType recType = [select id from RecordType where Name=:'Expressions']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        boolean IsNull=false;
        boolean SavRec = true;
        boolean IsError = true;
        RuleNameMap.clear();
        String url;
        pageReference p;
        MTTSRuleProcess.RecordTypeId=Rtype.Id;
        MTTSRuleProcess.SVMXC__Rule_Type__c='MTTS';     
        boolean IsValidate;
        for(integer i=0;i<MTTSRuleList.size();i++)
        {
            if(MTTSRuleList[i].SVMXC__Select__c)
            {         
                MTTSRuleProcess.SVMXC__Name__c = MTTSRuleList[i].SVMXC__Name__c;
            }
        }
        IsValidate=SVMX_ValidateRuleName(MTTSRuleProcess);
        if(IsValidate==false)
        {
            for(integer i=0;i<MTTSRuleList.size();i++)
            {
                if(MTTSRuleList[i].id==null)
                {
                    MTTSRuleList[i].SVMXC__Select__c= true;
                }
                if(RuleId==MTTSRuleList[i].id)
                {
                    MTTSRuleList[i].SVMXC__Select__c= true;
                }
            }  
            return null;  
        }      
        for(integer j=0;j<MTTSRuleList.size();j++){
            
            if(MTTSRuleList[j].SVMXC__Name__c!=null){                               
                RuleNameMap.put(MTTSRuleList[j].SVMXC__Name__c,j);      
            }
        }
        if(!IsNull && RuleNameMap.size()>0 && MTTSRuleList.size()>0){
            if(RuleNameMap.size()!=MTTSRuleList.size()){
                SavRec = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG017()));
            }
            else{
                if(SavRec){
                    try{
                    for(integer i=0;i<MTTSRuleList.size();i++){
                        if(MTTSRuleList[i].id==null){
                            if(MTTSRuleProcess.SVMXC__MTTS_Minutes__c==null || MTTSRuleProcess.SVMXC__MTTS_Minutes__c==0){                      
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG020()));   
                            }                           
                            else
                            {
                                string headerCriteria = CriExpressions.getCriteria('SVMXC__Service_Order__c');
                                if(headerCriteria != 'ERROR')
                                {
                                    MTTSRuleProcess.SVMXC__Name__c = MTTSRuleList[i].SVMXC__Name__c;
                                    MTTSRuleProcess.SVMXC__Description__c= MTTSRuleList[i].SVMXC__Description__c;
                                    MTTSRuleProcess.SVMXC__Select__c= false;
                                    MTTSRuleProcess.SVMXC__Sequence__c=i;
                                    MTTSRuleProcess.SVMXC__Parent_Object_Criteria__c = headerCriteria;
                                    MTTSRuleProcess.SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption;
                                    //CRUD
                                    if (!securityUtils.verifyFieldAccess(MTTSRuleProcess, COMM_SecurityUtils.Access.Createable))        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                    {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                                    }           
                                    else
                                    {
                                        insert MTTSRuleProcess;
                                    }
                                        //insert MTTSRuleProcess;
                                        mapCriExpressionsProperties.put('RecordTypeID',recType.Id);
                                        mapCriExpressionsProperties.put('SVMXC__Expression_Type__c', 'WORD_MTTS');
                                        mapCriExpressionsProperties.put('SVMXC__Expression_Rule__c', MTTSRuleProcess.Id);
                                        CriExpressions.getExpressions(mapCriExpressionsProperties);
                                        DisbaleChkBox=false;
                                        DisbaleActiveChkBox= false;                         
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG022())); 
                                        showRule = false;
                                        DisbleNewBttn = false;
                                        DisbleEdtBttn = false;
                                        DisbleDelBttn = false;
                                        DisbleRuleSeqBttn = false;
                                        IsError = false;
                                        url = '/apex/SVMXC__WORD_ManageMTTSRules';
                                   
                                }
                            }   
                        }
                        else if(MTTSRuleList[i].id!=null){  
                            if(MTTSRuleList[i].SVMXC__Select__c){
                                if(MTTSRuleProcess.SVMXC__MTTS_Minutes__c==null || MTTSRuleProcess.SVMXC__MTTS_Minutes__c==0){                      
                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG020()));   
                                }
                                else
                                {
                                    string headerCriteria = CriExpressions.getCriteria('SVMXC__Service_Order__c');
                                    if(headerCriteria != 'ERROR')
                                    {
                                        MTTSRuleList[i].SVMXC__Select__c= false;
                                        MTTSRuleList[i].SVMXC__Sequence__c=i;
                                        MTTSRuleList[i].SVMXC__MTTS_Minutes__c = MTTSRuleProcess.SVMXC__MTTS_Minutes__c;
                                        MTTSRuleList[i].SVMXC__Parent_Object_Criteria__c = headerCriteria;
                                        MTTSRuleList[i].SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption; 
                                        
                                            //CRUD
                                        if(MTTSRuleList != null && MTTSRuleList.size() > 0) 
                                            {
                                                if (!securityUtils.verifyFieldAccess(MTTSRuleList, COMM_SecurityUtils.Access.Updateable))   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                                    {
                                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                                                    }           
                                                else
                                                    {
                                                        update MTTSRuleList;
                                                    }
                                            }
                                            //update MTTSRuleList;
                                            mapCriExpressionsProperties.put('RecordTypeID',recType.Id);
                                            mapCriExpressionsProperties.put('SVMXC__Expression_Type__c', 'WORD_MTTS');
                                            mapCriExpressionsProperties.put('SVMXC__Expression_Rule__c', MTTSRuleList[i].Id);
                                            CriExpressions.getExpressions(mapCriExpressionsProperties);
                                            DisbaleChkBox=false;
                                            DisbaleActiveChkBox= false;                         
                                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG022())); 
                                            showRule = false;
                                            DisbleNewBttn = false;
                                            DisbleEdtBttn = false;
                                            DisbleDelBttn = false;
                                            DisbleRuleSeqBttn = false;
                                            IsError = false;
                                            url = '/apex/SVMXC__WORD_ManageMTTSRules';
                                     
                                     }
                                }       
                            }
                        }   
                    }
                    }
                    catch(exception ex){
                    for(integer i=0;i<MTTSRuleList.size();i++){
                        
                        if(MTTSRuleList[i].id==null)
                        {
                           MTTSRuleList[i].SVMXC__Select__c= true;
                        }
                        if(ruleId==MTTSRuleList[i].id)
                        {
                             MTTSRuleList[i].SVMXC__Select__c= true;
                        }
                        }
                       IsError = true;
        
                    }
                    
                }   
            }
        }
        if(IsError){
            
            p=null;
        }
        else{           
            IsError = false;
            p=new pageReference(url);
            p.setRedirect(true);}           
        return p;       
    }
    
    public PageReference SVMX_DelMTTSRule(){        
        List<SVMXC__ServiceMax_Processes__c> PartsRuleIDs = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> TempPartsRuleIDs = new List<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> TempCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
        IsRuleBlock = true;
        list<id> DelIdLst = new list<id>();
        IsPartsBlock = false;
        for(integer i=0;i<MTTSRuleList.size();i++){
            if(MTTSRuleList[i].SVMXC__Select__c){
                DelPRCountRec=true;
                DelIdLst.add(MTTSRuleList[i].Id);
                if(MTTSRuleList[i].Id!=NULL)
                PartsRuleIDs.add(MTTSRuleList[i]);          
            }
            else
                TempPartsRuleIDs.add(MTTSRuleList[i]);  
        }
        if(!DelPRCountRec){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011()));
        }
        else{           
            TempCnfiglst = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:PartsRuleIDs];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //CRUD
            if(TempCnfiglst != null && TempCnfiglst.size() > 0)
                {
                    
                    if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Config_Data__c'))       //SDL-SVMX-DELETE-FLS-ENFORCED
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                    delete TempCnfiglst;    
                    }
                }
            //delete TempCnfiglst;
            //CRUD
            if(PartsRuleIDs != null && PartsRuleIDs.size() > 0)
                {
                    
                    if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Processes__c'))     //SDL-SVMX-DELETE-FLS-ENFORCED
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                    delete PartsRuleIDs;    
                    }
                }
            //delete PartsRuleIDs;            
            Cnfiglst.clear();
            MTTSRuleList.clear();
            MTTSRuleList = TempPartsRuleIDs;
            if(MTTSRuleList.size()<=0){
                showRule = false;
                DisbleEdtBttn = true;
                DisbleDelBttn = true;
                DisableCancelBttn = true;
                DisbleRuleSeqBttn = true;   
            }
        }       
        DelPRCountRec = false;
        DisbleNewBttn = false;      
        uncheckCheckbox();
        return null; 
    }
    
    public PageReference SVMX_Cancel(){
        String url = '/apex/SVMXC__WORD_ManageMTTSRules';
        pageReference p=new pageReference(url);
        for(integer j=0;j<MTTSRuleList.size();j++){
            MTTSRuleList[j].SVMXC__Select__c=false;
            if(MTTSRuleList[j].Id==null){
                MTTSRuleList.remove(j);
            }
        }
        showRule = false;
        DisbaleChkBox=false;
        DisbaleActiveChkBox= false;
        DisbleNewBttn = false;
        DisbleEdtBttn = false;
        DisbleDelBttn = false;
        p.setRedirect(true);
        return p;
    }
    
    public PageReference SVMX_GoSetupHome(){
      //String url = '/apex/SVMXC__CONF_SetupHome';
      SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
      Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('WORD012');
      //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
       //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        if(svmxSettingList.containsKey('SET001') == true){
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url =svmxSettingList.get('SET001');
            }
        }
        //Changes done by Nidhi ends here
      PageReference HomePage = new PageReference(url);
      HomePage.setRedirect(true);
      return HomePage; 
    }   
    
    /*************************** Functionality for Rule(Process) Ends ***************************/
    
    /*************************** Functionality for Rule Sequence Starts ***************************/
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
        TempMTTSRuleList.addAll(MTTSRuleList);
        for(integer i=0;i<MTTSRuleList.size();i++){
            if(MTTSRuleList[i].SVMXC__Select__c){
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
        if (TempMTTSRuleList.Size() >0){
            for(SVMXC__ServiceMax_Processes__c s:TempMTTSRuleList){                             
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
            temp = TempMTTSRuleList[selIndex];
            for(integer j=selIndex;j>0;j--){
                TempMTTSRuleList[j] = TempMTTSRuleList[j-1];
            }
            TempMTTSRuleList[0] = temp;
        }
        else {
            temp = TempMTTSRuleList[selIndex];
            for(integer j=selIndex;j<TempMTTSRuleList.size()-1;j++){
                TempMTTSRuleList[j] = TempMTTSRuleList[j+1];
            }
            TempMTTSRuleList[TempMTTSRuleList.size()-1] = temp;
        }
    }   
    public void UP(){    
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempMTTSRuleList.size();j++){
            for(integer i=0;i<items.size();i++){
                if(items[i]==TempMTTSRuleList[0].Id){
                    TempMTTSRuleList[j] = TempMTTSRuleList[j];
                        break;
                }
                else if(items[i]==TempMTTSRuleList[j].Id){
                    temp = TempMTTSRuleList[j]; 
                    TempMTTSRuleList[j] = TempMTTSRuleList[j-1];
                    TempMTTSRuleList[j-1]=temp;                    
                    selIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    TempMTTSRuleList[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    TempMTTSRuleList[selIndex].SVMXC__Sequence__c = selIndex;
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
            for(integer k=0;k<TempMTTSRuleList.size()-1;k++){
                if(items[i]==TempMTTSRuleList[k].Id){
                    temp = TempMTTSRuleList[k];
                    TempMTTSRuleList[k] = TempMTTSRuleList[k+1];
                    TempMTTSRuleList[k+1]=temp;
                    selIndex = k;
                    isUpAction = false;
                    isDownAction=true;
                    isTopAction=false;
                    isBottomAction=false;
                    TempMTTSRuleList[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                    TempMTTSRuleList[selIndex].SVMXC__Sequence__c = selIndex;
                    break;                         
                }
            }
        }   
    }
    public void Top(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempMTTSRuleList.size()-1;j>0;j--){
            for(integer i=items.size()-1;i>=0;i--){
                if(items[i] == TempMTTSRuleList[j].Id){
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
        for(integer j=0;j<TempMTTSRuleList.size()-1;j++){
            for(integer i=0;i<items.size();i++){
                if(items[i] == TempMTTSRuleList[j].Id){
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
            //CRUD
            if(TempMTTSRuleList != null && TempMTTSRuleList.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(TempMTTSRuleList, COMM_SecurityUtils.Access.Updateable))       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update TempMTTSRuleList;
                        }
                }
            //update TempMTTSRuleList;
        }
        else if(isDownAction){
            //CRUD
            if(TempMTTSRuleList != null && TempMTTSRuleList.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(TempMTTSRuleList, COMM_SecurityUtils.Access.Updateable))       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update TempMTTSRuleList;
                        }
                }
            //update TempMTTSRuleList;
        }
        else if(isTopAction){
            for(integer i=0;i<TempMTTSRuleList.size();i++){
                TempMTTSRuleList[i].SVMXC__Sequence__c=i;
            }
            //CRUD
            if(TempMTTSRuleList != null && TempMTTSRuleList.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(TempMTTSRuleList, COMM_SecurityUtils.Access.Updateable))       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update TempMTTSRuleList;
                        }
                }
            //update TempMTTSRuleList;
        }
        else if(isBottomAction){
            for(integer i=0;i<TempMTTSRuleList.size();i++){
                TempMTTSRuleList[i].SVMXC__Sequence__c=i;
            }
            //CRUD
            if(TempMTTSRuleList != null && TempMTTSRuleList.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(TempMTTSRuleList, COMM_SecurityUtils.Access.Updateable))       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update TempMTTSRuleList;
                        }
                }
            //update TempMTTSRuleList;
        }
        return SVMX_Cancel();
    }
    /*************************** Functionality for Rule Sequence Ends ***************************/
        
    /*************************** Functionality for Expression(Config Data) Starts ***************************/
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
       m.put('', new SelectOption('',getTAG021()));
    }         
 
    public List<selectoption> Hdrfldlist = new List<selectoption>();  //list of fields values
    public List<selectoption> getHdrFldlist() {return sortingSelectOption(Hdrfldlist, true);}
     
    public void ClearSelOptList(List<SelectOption> lst){
        lst.clear();
        lst.add(new SelectOption('SVMX.NONE',getTAG021()));
    }

    public PageReference OnHdrObjSelect(){
        ClearSelOptList(Hdrfldlist);
        //RetriveField('service_order__c', Hdrfldlist, CriExpressions.mapFieldDispType, CriExpressions.FieldApiLable);
        // replacing custom object name with qualified namespace.
        RetriveField('SVMXC__Service_Order__c', Hdrfldlist, CriExpressions.mapFieldDispType, CriExpressions.FieldApiLable);
        CriExpressions.FieldsList = Hdrfldlist;        
        //CriExpressions.objfieldMap = mMapFieldList.get('service_order__c');
          // replacing custom object name with qualified namespace.
        CriExpressions.objfieldMap = mMapFieldList.get('SVMXC__Service_Order__c');       
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

/*     COMM_SVMXC_Search_Expressions ExpressionsTemp;
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
       // CriExpressions.objfieldMap = mMapFieldList.get('service_order__c'); 
       // Replacing custom object name with fully qualified namespace.
       CriExpressions.objfieldMap = mMapFieldList.get('SVMXC__Service_Order__c');
        CriExpressions.OnChangeField(integer.valueOf(SelectedIndex), true);
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
    
    */
    transient COMM_SVMXC_SearchRecords SR = new COMM_SVMXC_SearchRecords();
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
    // Defect #030860 - commenting below line and retrieving only workorder object for describe which reduce heapsize
     //public Schema.SObjectType allobjs2 = Schema.getGlobalDescribe().get('service_order__c'); 
    // Replacing fully qualified custom object name
    public Schema.SObjectType allobjs2 = Schema.getGlobalDescribe().get('SVMXC__Service_Order__c');  
    
    
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