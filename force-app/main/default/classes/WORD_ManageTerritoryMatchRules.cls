public  with sharing  class WORD_ManageTerritoryMatchRules {
        
    /****************************** Code Block Starts ************************************/
    
    transient SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD013');
    
    //transient SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    /****************************** Translations ************************************/
    public String getHLPURL() {return system.label.WORD013_HLPURL;}
    public String getTAG001() {return system.label.WORD013_TAG001 ;}// 'In this screen, you can create rules that dictate how primary territory is calculated on a work order.
    public String getTAG002() {return system.label.WORD013_TAG002 ;}// 'New Rule
    public String getTAG003() {return system.label.WORD013_TAG003 ;}// 'Edit Rule
    public String getTAG004() {return system.label.WORD013_TAG004 ;}// 'Delete Rule
    public String getTAG005() {return system.label.WORD013_TAG005 ;}// 'Save
    public String getTAG006() {return system.label.WORD013_TAG006 ;}// 'Cancel
    public String getTAG007() {return system.label.WORD013_TAG007 ;}// 'Rule Sequence
    public String getTAG008() {return system.label.WORD013_TAG008 ;}// 'Back To Setup Home
    public String getTAG009() {return system.label.WORD013_TAG009 ;}// 'Processing...
    public String getTAG010() {return system.label.WORD013_TAG010 ;}// 'Are you sure to proceed?
    public String getTAG011() {return system.label.WORD013_TAG011 ;}// 'Servicemax Territory Rule Help
    public String getTAG012() {return system.label.WORD013_TAG012 ;}// 'Rule Name
    public String getTAG013() {return system.label.WORD013_TAG013 ;}// 'Description
    public String getTAG014() {return system.label.WORD013_TAG014 ;}// 'Advanced Expression
    public String getTAG015() {return system.label.WORD013_TAG015 ;}// 'Select the territory attributes that must be considered for this rule
    public String getTAG016() {return system.label.WORD013_TAG016 ;}// 'Please enter a valid rule name
    public String getTAG017() {return system.label.WORD013_TAG017 ;}// 'Duplicate Territory Match Rule name
    public String getTAG018() {return system.label.WORD013_TAG018 ;}// 'Please map atleast one attribute to a work order field
    public String getTAG019() {return system.label.WORD013_TAG019 ;}// 'Please select a rule to edit
    public String getTAG020() {return system.label.WORD013_TAG020 ;}// 'Please select one rule record to edit
    public String getTAG021() {return system.label.WORD013_TAG021 ;}// '--None--
    public String getTAG022() {return system.label.WORD013_TAG022 ;}// 'Please select a record to delete
    public String getTAG023() {return system.label.WORD013_TAG023 ;}// 'Available Attributes
    public String getTAG024() {return system.label.WORD013_TAG024 ;}// 'Work Order Fields to Use    public String getTAG025() {return system.label.WORD013_TAG025' )?svmxTagList.get(WORD013_TAG025') : 'Field Name
    public String getTAG025() {return system.label.WORD013_TAG025 ;}// 'Work Order Field
    public String getTAG026() {return system.label.WORD013_TAG026 ;}// 'Operator
    public String getTAG027() {return system.label.WORD013_TAG027 ;}// 'Value
    public String getTAG028() {return system.label.WORD013_TAG028 ;}// 'Sequence of Territory Rules
    public String getTAG029() {return system.label.WORD013_TAG029 ;}// 'Submit
    public String getTAG030() {return system.label.WORD013_TAG030 ;}// 'Cancel
    public String getTAG031() {return system.label.WORD013_TAG031 ;}// 
    //public String getTAG032() {return system.label.WORD013_TAG032 ;}// 'Record Owner
    /****************************** Variable Declaration ************************************/
    
    public List<SVMXC__ServiceMax_Processes__c> TrtryRuleList = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> TempTrtryRuleList = new List<SVMXC__ServiceMax_Processes__c>();
    //list<SVMXC__ServiceMax_Config_Data__c> Cnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
     //list<SVMXC__ServiceMax_Config_Data__c> FieldMapCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
    
    public List<selectoption> WOFieldsList = new List<selectoption>();
    //public List<selectoption> TypeList = new List<selectoption>();
    transient List<Id> TrtryRuleIds = new List<Id>();
    public Map<String,Integer> RuleNameMap = new Map<String,Integer>();
    //public Map<String,string> FieldMappingMap = new Map<String,string>();
    //RecordType Rtype = new RecordType();    
    integer EdtCountRec=0;
    boolean showRule = false;
    
    boolean DelPRCountRec = false;  
    boolean IsRuleBlock = false;
    boolean IsPartsBlock = false;   
    boolean DisbleNewBttn = false;
    boolean DisbleEdtBttn = false;
    boolean DisbleDelBttn = false;
    boolean DisbleSaveBttn = false;
    boolean DisbleRuleSeqBttn = false;  
    boolean DisbaleChkBox = false;
    boolean DisbaleActiveChkBox = false;
    boolean IsConfigQuery = false;      
    boolean displaySeqPopup = false;
    boolean DisableCancelBttn = false;
    string RuleId;
    string ruleObjName;
    string WOItem;
     map<string, string> mapCriExpressionsProperties = new map<string, string>();
    transient map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map<string, Map<String,Schema.SObjectField>> ();
    transient Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
    public COMM_SVMXC_Search_Expressions CriExpressions = new COMM_SVMXC_Search_Expressions(2); 
    public SVMXC__ServiceMax_Processes__c TrtryRuleProcess = new SVMXC__ServiceMax_Processes__c();
    public boolean IsEnterpriseLicense = false;
    transient Map<String,Boolean> PermitedStndObjMap = new Map<String,Boolean>();
    transient SVMXC.COMM_Utils Utils = new SVMXC.COMM_Utils();
    
    public COMM_SVMXC_Search_Expressions getCriExpressions() {return CriExpressions;}
    public SVMXC__ServiceMax_Processes__c getTrtryRuleProcess() {return this.TrtryRuleProcess;}
    public void setTrtryRuleProcess(SVMXC__ServiceMax_Processes__c prs){this.TrtryRuleProcess=prs;}
    public List<TrtryAttWrpper> TrtryAttWrpList = new List<TrtryAttWrpper>();
   
    /*********************************** Functionality for Territory Attributes Wrapper Starts ********************************************/
    public class TrtryAttWrpper {
        List<selectoption> WOFields = new List<selectoption>();
        SVMXC__ServiceMax_Config_Data__c Mapping = new SVMXC__ServiceMax_Config_Data__c ();
        //schema.Picklistentry picklistval;
        string picklistval;
        string WOItm;
        /*public TrtryAttWrpper(string p,List<selectoption> FieldLst, string Item){
            WOFields = FieldLst;
            picklistval = p;
            WOItm = Item;               
        }*/
        public TrtryAttWrpper(SVMXC__ServiceMax_Config_Data__c s,List<selectoption> FieldLst){
            WOFields = FieldLst;
            Mapping =   s;                  
        }
        
        public SVMXC__ServiceMax_Config_Data__c getMapping(){
            return Mapping;
        }
        public List<selectoption> getWOFields(){
            return WOFields;
        }
        public string getWOItm(){
            return WOItm;
        }
        public void setWOItm(string v){
            this.WOItm = v;
        }
        public string getpicklistval(){
            return picklistval;
        }
    }
    /*********************************** Functionality for Territory Attributes Wrapper Ends ********************************************/
    
    /****************************** Constructor Defined ************************************/
    
    public WORD_ManageTerritoryMatchRules(){        
         //Added by amar on 19/Aug/10 Due to OEM Exercises
        IsEnterpriseLicense = utils.SVMX_isEnterpriseLicense();
        if(!IsEnterpriseLicense)
        {
             PermitedStndObjMap = utils.SVMX_getPermittedStandardObjectList();
        }
        Onload();
       
    }
    
    private void Onload()
    {
        //allobjs.clear();
        Map<String, Schema.SObjectType> allobjs = new Map<String, Schema.SObjectType>();
        allobjs = Schema.getGlobalDescribe();
        allobjs = Schema.getGlobalDescribe();
        //system.debug('allobjs'+allobjs);
        if(allobjs.containsKey('SVMXC__service_order__c'))
            ruleObjName = 'SVMXC__service_order__c';
        else
            ruleObjName = 'service_order__c';
        allobjs.clear();
        //Rtype = [select Id from RecordType where Name=:'SVMX Rule'];
        //recType = [select id from RecordType where Name=:'Expressions']; 
        TrtryRuleList.clear();
        TrtryRuleList=[select Id,Name,SVMXC__Advance_Expression__c,SVMXC__Description__c,SVMXC__Sequence__c,SVMXC__Name__c,SVMXC__Select__c from SVMXC__ServiceMax_Processes__c where RecordType.Name='SVMX Rule' and SVMXC__Rule_Type__c='Work Order Territory' order by SVMXC__Sequence__c];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(TrtryRuleList.size()<=1){
            DisbleRuleSeqBttn = true;
        }
        if(TrtryRuleList.size()==0){
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
        }   
        DisableCancelBttn = true;
        for(SVMXC__ServiceMax_Processes__c PR: TrtryRuleList){
            TrtryRuleIds.add(PR.Id);            
        }
        DisbleSaveBttn = true; 
        CriExpressions = new COMM_SVMXC_Search_Expressions(2); 
        CriExpressions.DefaultField = getTAG021();
        CriExpressions.DefaultOperator = getTAG021();
        CriExpressions.DefaultListValue = getTAG021();
        CriExpressions.ExpressionType = 'CRITERIA';
        
        /*for(Schema.SObjectType lON : allObjs.values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            if(D.isAccessible() == true && D.isCreateable() == true && D.isCustom() == true){
                //HdrObjApiLable.put(D.getName(),D.getLabel());
                //HeaderObjApiLocalName.put(D.getName(),D.getLocalName());
                mapHdrObjOpt.put(D.getName(), new SelectOption(D.getName(),D.getLabel()));
            }
        } 
        list<schema.Picklistentry> TrtryAttrbt = new list<schema.Picklistentry>(); 
        Map<String, Schema.SObjectField> TrtryMap = Schema.SObjectType.SVMXC__Territory_Coverage__c.fields.getMap();
        if(TrtryMap.containskey('SVMXC__type__c') && TrtryMap.get('SVMXC__type__c') != null)//added by amar on 31/05/10
            TrtryAttrbt = TrtryMap.get('SVMXC__type__c').getDescribe().getPicklistValues();
        else if(TrtryMap.containskey('Type__c') && TrtryMap.get('Type__c') != null)//added by amar on 31/05/10
            TrtryAttrbt = TrtryMap.get('Type__c').getDescribe().getPicklistValues();
        
        TrtryMap.clear(); */
        /*TypeList.clear();
        
        for(schema.Picklistentry p:TrtryAttrbt){            
            TypeList.add(new SelectOption(p.getValue(),p.getLabel()));
        } */  
       // TrtryAttrbt.clear();
    }
    /****************************** Getter/Setter Functioanlity ************************************/
    
    public boolean getDisbaleChkBox(){ return DisbaleChkBox; }
    public void setDisbaleChkBox(boolean b){ this.DisbaleChkBox = b; }
    public boolean getDisbaleActiveChkBox(){ return DisbaleActiveChkBox; }
    public void setDisbaleActiveChkBox(boolean b){ this.DisbaleActiveChkBox = b; }
    
    public boolean getshowRule(){ return showRule; }
    public void setshowRule(boolean b){ this.showRule = b; }
    
    public boolean getDisbleNewBttn(){ return DisbleNewBttn; }
    public void setDisbleNewBttn(boolean b){ this.DisbleNewBttn = b; }
    public boolean getDisbleEdtBttn(){ return DisbleEdtBttn; }
    public void setDisbleEdtBttn(boolean b){ this.DisbleEdtBttn = b; }
    public boolean getDisbleDelBttn(){ return DisbleDelBttn; }
    public void setDisbleDelBttn(boolean b){ this.DisbleDelBttn = b; }
    public boolean getDisbleRuleSeqBttn(){ return DisbleRuleSeqBttn; }
    public boolean getDisbleSaveBttn(){ return DisbleSaveBttn; }
    public void setDisbleSaveBttn(boolean b){ this.DisbleSaveBttn = b; }
    public void setDisbleRuleSeqBttn(boolean b){ this.DisbleRuleSeqBttn = b; }
    public boolean getIsRuleBlock(){ return IsRuleBlock; }
    public void setIsRuleBlock(boolean b){ this.IsRuleBlock = b; }
    public Boolean getdisplaySeqPopup(){ return displaySeqPopup; }  
    Boolean CheckAllRules=false;
    public Boolean getCheckAllRules() {return CheckAllRules;  }
    public void setCheckAllRules(Boolean chkAll){CheckAllRules=chkAll;} 
    public void uncheckCheckbox(){CheckAllRules=false;}
    
    public boolean getDisableCancelBttn(){ return DisableCancelBttn; }
    public void setDisableCancelBttn(boolean b){ this.DisableCancelBttn = b; } 
    
    /*********************************** Functionality for Rule(Process) Starts ********************************************/
    
    public List<SVMXC__ServiceMax_Processes__c> getTrtryRuleList(){
        return TrtryRuleList;
    }   
    public string getWOItem(){
        return WOItem;
    }
    public void setWOItem(string v){
        this.WOItem = v;
    }
            
    public void SVMX_AddNewTrtryRule(){
        uncheckCheckbox();
        DisbaleChkBox=true;
        DisbaleActiveChkBox = true;
        showRule = true;        
        RecordType RecMapping = [select Id from RecordType where Name=:'Field Mapping'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(integer i=0;i<TrtryRuleList.size();i++){
            TrtryRuleList[i].SVMXC__Select__c=false;                
        }
        TrtryRuleProcess = new SVMXC__ServiceMax_Processes__c();    
        TrtryRuleProcess.SVMXC__Select__c=true;     
        List<selectoption> TypeList = new List<selectoption>();
        list<schema.Picklistentry> TrtryAttrbt = new list<schema.Picklistentry>(); 
        Map<String, Schema.SObjectField> TrtryMap = Schema.SObjectType.SVMXC__Territory_Coverage__c.fields.getMap();
        if(TrtryMap.containskey('SVMXC__type__c') && TrtryMap.get('SVMXC__type__c') != null)//added by amar on 31/05/10
            TrtryAttrbt = TrtryMap.get('SVMXC__type__c').getDescribe().getPicklistValues();
        else if(TrtryMap.containskey('Type__c') && TrtryMap.get('Type__c') != null)//added by amar on 31/05/10
            TrtryAttrbt = TrtryMap.get('Type__c').getDescribe().getPicklistValues();
        
        system.debug('TrtryMap: '+TrtryMap);
        TrtryMap.clear();
        for(schema.Picklistentry p:TrtryAttrbt){            
            TypeList.add(new SelectOption(p.getValue(),p.getLabel()));
        } 
        for(integer i=0;i<TypeList.size();i++){
            SVMXC__ServiceMax_Config_Data__c s = new SVMXC__ServiceMax_Config_Data__c();
            s.SVMXC__Source_Field_Name__c = TypeList.get(i).getLabel();
            s.RecordTypeId = RecMapping.Id;
            TrtryAttWrpper t = new  TrtryAttWrpper(s,WOFieldsList);
            TrtryAttWrpList.add( t);
            
        } 
         
        TrtryRuleList.add(TrtryRuleProcess);
        DisbleNewBttn = true;
        DisbleEdtBttn = true;
        DisbleDelBttn = true;
        DisbleSaveBttn = false; 
        DisbleRuleSeqBttn = true;
        DisableCancelBttn = false;
        showRule = true;        
    }
    public list<TrtryAttWrpper> getTrtryAttWrpList(){
        return TrtryAttWrpList;
    }
        
    public void SVMX_EdtTrtryRule(){
        RecordType RecMapping = [select Id from RecordType where Name=:'Field Mapping'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        EdtCountRec=0;      
        IsRuleBlock=true;
        IsConfigQuery = false;
        list<id> Idlst = new list<id>();         
        for(integer i=0;i<TrtryRuleList.size();i++){
            if(TrtryRuleList[i].SVMXC__Select__c){              
                showRule = true;
                EdtCountRec = EdtCountRec + 1;
                if(EdtCountRec==1){ 
                    DisbleSaveBttn = false;                 
                    TrtryRuleProcess.SVMXC__Name__c = TrtryRuleList[i].SVMXC__Name__c;
                    TrtryRuleProcess.SVMXC__Description__c= TrtryRuleList[i].SVMXC__Description__c;                 
                    TrtryRuleProcess.SVMXC__Advance_Expression__c = TrtryRuleList[i].SVMXC__Advance_Expression__c;
                    CriExpressions.AdvanceOption = TrtryRuleProcess.SVMXC__Advance_Expression__c;
                    IsConfigQuery = true;
                    Idlst.add(TrtryRuleList[i].Id);      
                }
            }
        }
        if(IsConfigQuery){                          
            DisbaleChkBox=true; 
            DisbaleActiveChkBox=true;           
            DisbleNewBttn = true;
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
            DisbleRuleSeqBttn = true;
            DisableCancelBttn = false;
            list<SVMXC__ServiceMax_Config_Data__c> Cnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
           // Cnfiglst.clear();
            Cnfiglst = [Select SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:Idlst and RecordType.Name=:'Expressions'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            list<SVMXC__ServiceMax_Config_Data__c> FieldMapCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
            FieldMapCnfiglst = [Select Id,SVMXC__Source_Field_Name__c,SVMXC__Target_Field_Name__c,SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:Idlst and RecordType.Name=:'Field Mapping']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('FieldMapCnfiglst '+ FieldMapCnfiglst);
           
            if(Cnfiglst.size()>0){
                CriExpressions.lstExpressions.clear();
                for(SVMXC__ServiceMax_Config_Data__c Cnfig :Cnfiglst){
                    CriExpressions.setExpressions(Cnfig);
                }
            }
            Map<String,string> FieldMappingMap = new Map<String,string>();
            if(FieldMapCnfiglst.size()>0){
                for(SVMXC__ServiceMax_Config_Data__c Cnfig :FieldMapCnfiglst){
                    FieldMappingMap.put(Cnfig.Id,Cnfig.SVMXC__Source_Field_Name__c);
                }           
            }       
            TrtryAttWrpList.clear();
            system.debug('TrtryAttWrpList '+ TrtryAttWrpList);
            TrtryAttWrpper t;     
            List<selectoption> TypeList = new List<selectoption>();
            list<schema.Picklistentry> TrtryAttrbt = new list<schema.Picklistentry>(); 
            Map<String, Schema.SObjectField> TrtryMap = Schema.SObjectType.SVMXC__Territory_Coverage__c.fields.getMap();
            if(TrtryMap.containskey('SVMXC__type__c') && TrtryMap.get('SVMXC__type__c') != null)//added by amar on 31/05/10
            {
                TrtryAttrbt = TrtryMap.get('SVMXC__type__c').getDescribe().getPicklistValues();
                system.debug('In if');
            }
            else if(TrtryMap.containskey('Type__c') && TrtryMap.get('Type__c') != null)//added by amar on 31/05/10
            {
                TrtryAttrbt = TrtryMap.get('Type__c').getDescribe().getPicklistValues();
                system.debug('In elseif');
            }
             system.debug('TrtryMap: '+TrtryMap);
             system.debug('TrtryAttWrpList: '+TrtryAttWrpList);
            TrtryMap.clear();
        for(schema.Picklistentry p:TrtryAttrbt){            
            TypeList.add(new SelectOption(p.getValue(),p.getLabel()));
        }
           
            for(integer k=0;k<TypeList.size();k++){
                integer foundRecI;
                for(integer j=0;j<FieldMapCnfiglst.size();j++){                                                     
                    if(TypeList.get(k).getValue()==FieldMappingMap.get(FieldMapCnfiglst[j].id))
                        foundRecI = j;
                }
                if(foundRecI != null){                      
                    t = new TrtryAttWrpper(FieldMapCnfiglst[foundRecI],WOFieldsList);
                    t.WOItm = FieldMapCnfiglst[foundRecI].SVMXC__Target_Field_Name__c; 
                    TrtryAttWrpList.add(t);                 
                }                                               
                else{
                    SVMXC__ServiceMax_Config_Data__c s = new SVMXC__ServiceMax_Config_Data__c();
                    s.SVMXC__Source_Field_Name__c = TypeList.get(k).getValue();                     
                    s.RecordTypeId = RecMapping.Id;
                    t = new  TrtryAttWrpper(s,WOFieldsList);
                    TrtryAttWrpList.add(t);                 
                }                   
            }
           system.debug('Cnfiglst '+ Cnfiglst);
            system.debug('CriExpressions '+ CriExpressions);
            system.debug('TrtryAttWrpList '+ TrtryAttWrpList);
            system.debug('FieldMappingMap '+ FieldMappingMap);
            system.debug('TypeList '+ TypeList);                          
        }
         
        if(EdtCountRec==0){
            showRule = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG019()));
        }
        if(EdtCountRec>1){
            for(integer j=0;j<TrtryRuleList.size();j++){
            TrtryRuleList[j].SVMXC__Select__c=false;}
            showRule = false;   
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG020()));           
        }
    }
    boolean TrtryAttrbError = false;
    public boolean getTrtryAttrbError(){ return TrtryAttrbError; }
    public void setTrtryAttrbError(boolean b){ this.TrtryAttrbError = b; }
        public string RuleName;
        boolean ValidateRuleName;
        public boolean SVMX_ValidateRuleName(SVMXC__ServiceMax_Processes__c TrtryRuleProcess)
        {
            ValidateRuleName=true;
            RuleName = TrtryRuleProcess.SVMXC__Name__c;
            if(RuleName == null)
            {
                
                ValidateRuleName = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG016()));       
            }
            else
            { 
                if(RuleName.length() < 8)
                {
                    
                    ValidateRuleName=false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG031()));      
                }
            }
            return ValidateRuleName;
        }
    public pageReference SVMX_SaveProcessRulewithChild(){
        IsRuleBlock = true;             
        RecordType recType = [select id from RecordType where Name=:'Expressions']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        boolean IsNull=false;
        boolean SavRec = true;
        boolean IsError = true;
        RuleNameMap.clear();
        String url;
        integer Count = 0;
        TrtryAttrbError = false;
        pageReference p;
        RecordType Rtype = new RecordType();    
        Rtype = [select Id from RecordType where Name=:'SVMX Rule'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        TrtryRuleProcess.RecordTypeId=Rtype.Id;
        TrtryRuleProcess.SVMXC__Rule_Type__c='Work Order Territory';    
        boolean IsValidate;
        if(TrtryRuleList.size() > 0)
        {
        for(integer i=0;i<TrtryRuleList.size();i++)
        { 
            if(TrtryRuleList[i].SVMXC__Select__c)
            {         
                TrtryRuleProcess.SVMXC__Name__c = TrtryRuleList[i].SVMXC__Name__c;
            }
        }
          IsValidate=SVMX_ValidateRuleName(TrtryRuleProcess);
        }
        if(IsValidate == false)
        {
            for(integer i=0;i<TrtryRuleList.size();i++)
            {
                if(TrtryRuleList[i].id==null)
                {
                    TrtryRuleList[i].SVMXC__Select__c= true;
                }
                if(RuleId==TrtryRuleList[i].id)
                {
                    TrtryRuleList[i].SVMXC__Select__c= true;
                }
            }  
            return null;  
        }   
        for(integer j=0;j<TrtryRuleList.size();j++){
            
            if(TrtryRuleList[j].SVMXC__Name__c!=null){                              
                RuleNameMap.put(TrtryRuleList[j].SVMXC__Name__c,j);     
            }
        }
        if(!IsNull && RuleNameMap.size()>0 && TrtryRuleList.size()>0){
            if(RuleNameMap.size()!=TrtryRuleList.size()){
                SavRec = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG017()));
            }
            else{
                if(SavRec){
                    if(TrtryAttWrpList.size()>0){
                        for(integer j=0;j<TrtryAttWrpList.size();j++){
                            if(TrtryAttWrpList[j].WOItm=='SVMX.NONE'){
                                Count = Count + 1;
                            }
                        }
                        if(Count==TrtryAttWrpList.size()){
                            TrtryAttrbError = true;
                        }
                    }                   
                    for(integer i=0;i<TrtryRuleList.size();i++){
                        if(TrtryRuleList[i].id==null)
                        {                          
                            string headerCriteria = CriExpressions.getCriteria('SVMXC__Service_Order__c');
                            if(headerCriteria != 'ERROR')
                            {
                                if(TrtryAttrbError){
                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG018()));
                                }
                                else{
                                    TrtryRuleProcess.SVMXC__Name__c = TrtryRuleList[i].SVMXC__Name__c;
                                    TrtryRuleProcess.SVMXC__Description__c= TrtryRuleList[i].SVMXC__Description__c;
                                    TrtryRuleProcess.SVMXC__Select__c= false;
                                    TrtryRuleProcess.SVMXC__Sequence__c=i;                                  
                                    TrtryRuleProcess.SVMXC__Parent_Object_Criteria__c = headerCriteria;
                                    TrtryRuleProcess.SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption;
                                    //CRUD
                                    if (!securityUtils.verifyFieldAccess(TrtryRuleProcess, COMM_SecurityUtils.Access.Createable))   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                        {
                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                                        }           
                                    else
                                        {
                                            insert TrtryRuleProcess;
                                        }
                                    //insert TrtryRuleProcess;
                                    //FieldMapCnfiglst.clear();
                                    list<SVMXC__ServiceMax_Config_Data__c> FieldMapCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
                                    for(integer j=0;j<TrtryAttWrpList.size();j++){
                                        if(TrtryAttWrpList[j].WOItm=='SVMX.NONE'){
                                            TrtryAttWrpList[j].Mapping.SVMXC__Target_Field_Name__c = '';
                                        }
                                        else{
                                            TrtryAttWrpList[j].Mapping.SVMXC__Target_Field_Name__c = TrtryAttWrpList[j].WOItm;
                                        }
                                        TrtryAttWrpList[j].Mapping.SVMXC__Expression_Rule__c = TrtryRuleProcess.Id;
                                        FieldMapCnfiglst.add(TrtryAttWrpList[j].Mapping);                                       
                                    }
                                    insert FieldMapCnfiglst;        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                    mapCriExpressionsProperties.put('RecordTypeID',recType.Id);
                                    mapCriExpressionsProperties.put('SVMXC__Expression_Type__c', 'WORD_Territory');
                                    mapCriExpressionsProperties.put('SVMXC__Expression_Rule__c', TrtryRuleProcess.Id);
                                    CriExpressions.getExpressions(mapCriExpressionsProperties);
                                    DisbaleChkBox=false;
                                    DisbaleActiveChkBox= false;
                                    showRule = false;
                                    DisbleNewBttn = false;
                                    DisbleEdtBttn = false;
                                    DisbleDelBttn = false;
                                    DisbleRuleSeqBttn = false;
                                    IsError = false;
                                    url = '/apex/SVMXC__WORD_ManageTerritoryMatchRules';
                                }
                            }   
                        }
                        else if(TrtryRuleList[i].id!=null){ 
                            if(TrtryRuleList[i].SVMXC__Select__c)
                            {                              
                                string headerCriteria = CriExpressions.getCriteria('SVMXC__Service_Order__c');
                                if(headerCriteria != 'ERROR')
                                {
                                    if(TrtryAttrbError){
                                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG018()));
                                    }
                                    else{                                       
                                        TrtryRuleList[i].SVMXC__Select__c= false;
                                        TrtryRuleList[i].SVMXC__Sequence__c=i;
                                        TrtryRuleList[i].SVMXC__Parent_Object_Criteria__c = headerCriteria;
                                        TrtryRuleList[i].SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption;
                                        //CRUD
                                        if(TrtryRuleList != null && TrtryRuleList.size() > 0) 
                                        {
                                            if (!securityUtils.verifyFieldAccess(TrtryRuleList, COMM_SecurityUtils.Access.Updateable))  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                            {
                                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                                            }           
                                            else
                                            {
                                                update TrtryRuleList;
                                            }
                                        }
                                        //update TrtryRuleList;
                                        list<SVMXC__ServiceMax_Config_Data__c> FieldMapCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
                                        //FieldMapCnfiglst.clear();
                                        for(integer j=0;j<TrtryAttWrpList.size();j++){
                                            if(TrtryAttWrpList[j].WOItm=='SVMX.NONE'){
                                                TrtryAttWrpList[j].Mapping.SVMXC__Target_Field_Name__c = '';
                                            }
                                            else{
                                                TrtryAttWrpList[j].Mapping.SVMXC__Target_Field_Name__c = TrtryAttWrpList[j].WOItm;
                                            }
                                            TrtryAttWrpList[j].Mapping.SVMXC__Expression_Rule__c = TrtryRuleList[i].Id;
                                            FieldMapCnfiglst.add(TrtryAttWrpList[j].Mapping);                                                                               
                                        }
                                        upsert FieldMapCnfiglst;        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA                        
                                        mapCriExpressionsProperties.put('RecordTypeID',recType.Id);
                                        mapCriExpressionsProperties.put('SVMXC__Expression_Type__c', 'WORD_Territory');
                                        mapCriExpressionsProperties.put('SVMXC__Expression_Rule__c', TrtryRuleList[i].Id);
                                        CriExpressions.getExpressions(mapCriExpressionsProperties);
                                        DisbaleChkBox=false;
                                        DisbaleActiveChkBox = false;
                                        showRule = false;
                                        DisbleNewBttn = false;
                                        DisbleEdtBttn = false;
                                        DisbleDelBttn = false;
                                        DisbleRuleSeqBttn = false;
                                        IsError = false;
                                        url = '/apex/SVMXC__WORD_ManageTerritoryMatchRules';
                                    }
                                }                                       
                            }
                        }   
                    }
                }   
            }
        }
        if(IsError){
            p=null; }   
        else{
            p=new pageReference(url);
            p.setRedirect(true);            
        }           
        return p;       
    }
    
    public boolean getDelPRCountRec(){ return DelPRCountRec; }
    public void setDelPRCountRec(boolean b){ this.DelPRCountRec = b; }
    
    public PageReference SVMX_DelTrTryRule(){       
        List<SVMXC__ServiceMax_Processes__c> TrtryRuleIDs = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> TempTrtryRuleIDs = new List<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> TrtryCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
        list<SVMXC__ServiceMax_Config_Data__c> MappingCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
        IsRuleBlock = true;
        list<id> DelIdLst = new list<id>();
        IsPartsBlock = false;
        for(integer i=0;i<TrtryRuleList.size();i++){
            if(TrtryRuleList[i].SVMXC__Select__c){
                DelPRCountRec=true;
                DelIdLst.add(TrtryRuleList[i].Id);
                if(TrtryRuleList[i].Id!=NULL)
                TrtryRuleIDs.add(TrtryRuleList[i]);         
            }
            else
                TempTrtryRuleIDs.add(TrtryRuleList[i]); 
        }
        if(!DelPRCountRec){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG022()));
        }
        else{           
            TrtryCnfiglst= [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:TrtryRuleIDs and SVMXC__Expression_Type__c='WORD_Territory'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            MappingCnfiglst = [Select Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:TrtryRuleIDs and RecordType.Name='Field Mapping'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //CRUD
            if(TrtryCnfiglst != null && TrtryCnfiglst.size() > 0)
                {
                    
                    if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Config_Data__c'))   //SDL-SVMX-DELETE-FLS-ENFORCED
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                    delete TrtryCnfiglst;   
                    }
                }
            //delete TrtryCnfiglst;
            //CRUD
            if(TrtryRuleIDs != null && TrtryRuleIDs.size() > 0)
                {
                    
                    if (!securityUtils.isDeletableObject('SVMXC__ServiceMax_Processes__c')) //SDL-SVMX-DELETE-FLS-ENFORCED
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                    else
                    {
                    delete TrtryRuleIDs;    
                    }
                }
            //delete TrtryRuleIDs;            
            //Cnfiglst.clear();
            TrtryRuleList.clear();
            TrtryRuleList = TempTrtryRuleIDs;
            if(TrtryRuleList.size()<=0){
                showRule = false;
                DisbleEdtBttn = true;
                DisbleDelBttn = true;
                DisableCancelBttn = false;
            }
        }       
        DelPRCountRec = false;
        DisbleNewBttn = false;      
        DisbleSaveBttn = true; 
        DisbleRuleSeqBttn = false;
        uncheckCheckbox();
        if(TrtryRuleList.size()<=1){
            DisbleRuleSeqBttn = true;                       
        }
        return null;
    }
    
    
    public PageReference SVMX_Cancel(){
        String url = '/apex/SVMXC__WORD_ManageTerritoryMatchRules';
        pageReference p=new pageReference(url);
        for(integer j=0;j<TrtryRuleList.size();j++){
            TrtryRuleList[j].SVMXC__Select__c=false;
            if(TrtryRuleList[j].Id==null){
                TrtryRuleList.remove(j);
            }
        }
        showRule = false;
        DisbaleChkBox=false;
        DisbaleActiveChkBox = false;
        DisbleNewBttn = false;
        DisbleEdtBttn = false;
        DisbleDelBttn = false;
        DisbleRuleSeqBttn = false;
        p.setRedirect(true);
        return p;
    }
    
    public PageReference SVMX_GoSetupHome(){
      //String url = '/apex/SVMXC__CONF_SetupHome';
      SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
      Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('WORD013'); 
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
        TempTrtryRuleList.addAll(TrtryRuleList);
        for(integer i=0;i<TrtryRuleList.size();i++){
            if(TrtryRuleList[i].SVMXC__Select__c){
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
        if (TempTrtryRuleList.Size() >0){
            for(SVMXC__ServiceMax_Processes__c s:TempTrtryRuleList){                                
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
            temp = TempTrtryRuleList[selIndex];
            for(integer j=selIndex;j>0;j--){
                TempTrtryRuleList[j] = TempTrtryRuleList[j-1];
            }
            TempTrtryRuleList[0] = temp;
        }
        else {
            temp = TempTrtryRuleList[selIndex];
            for(integer j=selIndex;j<TempTrtryRuleList.size()-1;j++){
                TempTrtryRuleList[j] = TempTrtryRuleList[j+1];
            }
            TempTrtryRuleList[TempTrtryRuleList.size()-1] = temp;
        }
    }   
    public void UP(){    
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempTrtryRuleList.size();j++){
            for(integer i=0;i<items.size();i++){
                if(items[i]==TempTrtryRuleList[0].Id){
                    TempTrtryRuleList[j] = TempTrtryRuleList[j];
                        break;
                }
                else if(items[i]==TempTrtryRuleList[j].Id){
                    temp = TempTrtryRuleList[j]; 
                    TempTrtryRuleList[j] = TempTrtryRuleList[j-1];
                    TempTrtryRuleList[j-1]=temp;                    
                    selIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    TempTrtryRuleList[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    TempTrtryRuleList[selIndex].SVMXC__Sequence__c = selIndex;
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
            for(integer k=0;k<TempTrtryRuleList.size()-1;k++){
                if(items[i]==TempTrtryRuleList[k].Id){
                    temp = TempTrtryRuleList[k];
                    TempTrtryRuleList[k] = TempTrtryRuleList[k+1];
                    TempTrtryRuleList[k+1]=temp;
                    selIndex = k;
                    isUpAction = false;
                    isDownAction=true;
                    isTopAction=false;
                    isBottomAction=false;
                    TempTrtryRuleList[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                    TempTrtryRuleList[selIndex].SVMXC__Sequence__c = selIndex;
                    break;                         
                }
            }
        }   
    }
    public void Top(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempTrtryRuleList.size()-1;j>0;j--){
            for(integer i=items.size()-1;i>=0;i--){
                if(items[i] == TempTrtryRuleList[j].Id){
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
        for(integer j=0;j<TempTrtryRuleList.size()-1;j++){
            for(integer i=0;i<items.size();i++){
                if(items[i] == TempTrtryRuleList[j].Id){
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
            update TempTrtryRuleList;       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(isDownAction){
            update TempTrtryRuleList;       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(isTopAction){
            for(integer i=0;i<TempTrtryRuleList.size();i++){
                TempTrtryRuleList[i].SVMXC__Sequence__c=i;
            }
            //CRUD
            if(TempTrtryRuleList != null && TempTrtryRuleList.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(TempTrtryRuleList, COMM_SecurityUtils.Access.Updateable))  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update TempTrtryRuleList;
                        }
                }
            //update TempTrtryRuleList;
        }
        else if(isBottomAction){
            for(integer i=0;i<TempTrtryRuleList.size();i++){
                TempTrtryRuleList[i].SVMXC__Sequence__c=i;
            }
            //CRUD
            if(TempTrtryRuleList != null && TempTrtryRuleList.size() > 0) 
                {
                    if (!securityUtils.verifyFieldAccess(TempTrtryRuleList, COMM_SecurityUtils.Access.Updateable))  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update TempTrtryRuleList;
                        }
                }
            //update TempTrtryRuleList;
        }
        return SVMX_Cancel();
    }
    /*********************************** Functionality for Order Sequence Ends ********************************************/
    
            
    /****************************** Functionality for Expression(Config Data) Starts ************************************/
    
    //public Map<String, SelectOption>  mapHdrObjOpt = new Map<String, SelectOption>();
    //public Map<String, SelectOption>  mapLineObjOpt = new Map<String, SelectOption>();
    //public List<SelectOption> lstLineObjOpt = new List<SelectOption>(); //list of line object values
    public Map<String,String>  HeaderObjApiLocalName = new Map<String,String>();
    public Map<String,String>  HdrObjApiLable = new Map<String,String>();
    public SVMXC__ServiceMax_Processes__c objSVMXPro;
    public SVMXC__ServiceMax_Processes__c getobjSVMXPro() {return this.objSVMXPro;}
    public void setobjSVMXPro(SVMXC__ServiceMax_Processes__c sP){this.objSVMXPro = sP;}
    
    public List<SelectOption> getlstHdrObjOpt() { return sortingSelectOption(RetrieveHdrObjOpt(), true);}
    public List<SelectOption> RetrieveHdrObjOpt()
    {   
        Map<String, SelectOption>  mapHdrObjOpt = new Map<String, SelectOption>();
        Map<String, Schema.SObjectType> allobjs = new Map<String, Schema.SObjectType>();
        allobjs = Schema.getGlobalDescribe();
        for(Schema.SObjectType lON : allObjs.values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            if(D.isAccessible() == true && D.isCreateable() == true && D.isCustom() == true){
                //HdrObjApiLable.put(D.getName(),D.getLabel());
                //HeaderObjApiLocalName.put(D.getName(),D.getLocalName());
                mapHdrObjOpt.put(D.getName(), new SelectOption(D.getName(),D.getLabel()));
            }
        }
        return mapHdrObjOpt.values();
    }
    //public List<SelectOption> getlstLineObjOpt() {return sortingSelectOption(mapLineObjOpt.values(), true);}
 
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2){ //,list<sobject> ObjList
        RetriveField(ObjName, lst, m, m2, null);
    }
    
    public void RetriveField2(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT){  //,list<sobject> ObjList
        Map<String, Schema.SObjectType> allobjs = new Map<String, Schema.SObjectType>();
        allobjs = Schema.getGlobalDescribe();
        if(!mMapFieldList.containsKey(ObjName)){
            Schema.SObjectType objT = allObjs.get(objName);
            if(objT != null){
                objfieldMap = objT.getDescribe().fields.getMap();
                mMapFieldList.put(ObjName, objfieldMap);
            }
        }
        else
            objfieldMap = mMapFieldList.get(objName);
        for (String fieldKey : objfieldMap.keySet()){
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(DT != null && DT == f.getType()){
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
        Map<String, Schema.SObjectType> allobjs = new Map<String, Schema.SObjectType>();
        allobjs = Schema.getGlobalDescribe();
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
    
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT, string LCObjName){  //,list<sobject> ObjList
        Map<String, Schema.SObjectType> allobjs = new Map<String, Schema.SObjectType>();
        allobjs = Schema.getGlobalDescribe();
        if(!mMapFieldList.containsKey(ObjName)){
            Schema.SObjectType objT = allObjs.get(objName);
            if(objT != null){
                objfieldMap = objT.getDescribe().fields.getMap();
                mMapFieldList.put(ObjName, objfieldMap);
            }
        }
        else
            objfieldMap = mMapFieldList.get(objName);
        for (String fieldKey : objfieldMap.keySet()){
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
        RetriveField(ruleObjName, Hdrfldlist, CriExpressions.mapFieldDispType, CriExpressions.FieldApiLable);
        CriExpressions.FieldsList = Hdrfldlist;
        CriExpressions.objfieldMap = mMapFieldList.get(ruleObjName);
        system.debug('mMapFieldList' + mMapFieldList);
        system.debug('CriExpressions.FieldsList' + CriExpressions.FieldsList);
        WOFieldsList =  CriExpressions.FieldsList;
        system.debug('WOFieldsList  ' + WOFieldsList);      
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

    COMM_SVMXC_Search_Expressions ExpressionsTemp;
    public string SelectedLabel;
    public string SelectedID;
    public Boolean isSearch = false;
    public Boolean isDateSearch = false;
    transient COMM_SVMXC_SearchRecords SR = new COMM_SVMXC_SearchRecords();    
    
    public string getSelectedID() {return this.SelectedID;}
    public void setSelectedID(string str) {this.SelectedID = str;}
   
    public string getSelectedLabel() {return this.SelectedLabel;}
    public void setSelectedLabel(string str) {this.SelectedLabel = str;} 
    
    //public COMM_SVMXC_SearchRecords getSR (){return this.SR;}
    public boolean getisDateSearch(){return this.isDateSearch;}
    public boolean getisSearch(){return this.isSearch;}
    
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
        //ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].OperandID = SelectedID;
        isSearch = false;
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
    public void find(COMM_SVMXC_Search_Expressions Expressions){
        ExpressionsTemp = Expressions;
        SR = new  COMM_SVMXC_SearchRecords(Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].ObjectName, Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].Operand, Expressions.lstExpressions[integer.valueOf(SelectedIndex)-1].ObjectNameField, Expressions.ExpressionType );
    }
    
    
    public void OnHdrEntryCriFieldSelect(){ 
        CriExpressions.objfieldMap = mMapFieldList.get(ruleObjName); 
        CriExpressions.OnChangeField(integer.valueOf(SelectedIndex), true);
    }
    //Map<String, Schema.SObjectType> allobjs =new Map<String, Schema.SObjectType>();
    //Map<String, Schema.SObjectType> allobjs2 =  Schema.getGlobalDescribe();
    //Map<String, Schema.SObjectField> TrtryMap = Schema.SObjectType.SVMXC__Territory_Coverage__c.fields.getMap();
   
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

    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }    
    /****************************** Functionality for Expression(Config Data) Ends ************************************/
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''));
    }    
    /****************************** Code Block Ends ************************************/
}