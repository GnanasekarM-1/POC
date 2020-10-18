public with sharing class EVER_SetupAutoEntRules {
    
    
    public List<SVMXC__ServiceMax_Processes__c> processobjs;
    public COMM_SVMXC_Search_Expressions CriExpressions = new COMM_SVMXC_Search_Expressions(2);    
    public map <string, Map<String,Schema.SObjectField>> mMapFieldList = new map<string, Map<String,Schema.SObjectField>> ();
    map<string, string> mapCriExpressionsProperties = new map<string, string>();    
    //public List<SVMXC__ServiceMax_Processes__c> EntitlementRuleList = new List<SVMXC__ServiceMax_Processes__c>(); //Commented for the defect 041420 fix for view state issue
    public SVMXC__ServiceMax_Processes__c EntitlementRuleProcess = new SVMXC__ServiceMax_Processes__c();
    public List<SVMXC__ServiceMax_Processes__c> TempEntitlementRuleList = new List<SVMXC__ServiceMax_Processes__c>();
    /*Commented for the defect 041420 fix for view state issue
    public list<SVMXC__ServiceMax_Config_Data__c> Cnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String,Integer> RuleNameMap = new Map<String,Integer>();
    public Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
    public Map<String, Schema.SObjectType> allobjs2 =new Map<String, Schema.SObjectType>();
    public Map<String, Schema.SObjectType> allobjs =  Schema.getGlobalDescribe();
    */
    
    //public SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('EVER003');
    
    /*Commented for the defect 041420 fix for view state issue as these variables are not used anywhere
    public Map<String,String>  HeaderObjApiLocalName = new Map<String,String>();
    public Map<String,String>  HdrObjApiLable = new Map<String,String>();
    public Map<String, SelectOption>  mapHdrObjOpt = new Map<String, SelectOption>();
    */
    public string[] items = new String[]{};
        string RuleId;
    public List<SelectOption> Seqoptions = new List<SelectOption>();
    
    /*Commented for the defect 041420 fix for view state issue
    public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('EVER003');
    */
    
    public string delIndex;
    integer EdtCountRec=0;
    RecordType Rtype = new RecordType();
    
    public EVER_SetupAutoEntRules()
    {
        processobjs=[Select s.SVMXC__Pick_First_Match__c,s.SVMXC__Allow_Override__c, s.SVMXC__Sequence__c,s.SVMXC__Advance_Expression__c,s.SVMXC__Entitlement_Scope__c,s.SVMXC__Entitlement_By__c,s.SVMXC__Counter_Vs_Dates_Rule__c ,s.SVMXC__Match_Contact__c, s.SVMXC__Match_Location__c, s.SVMXC__Target_URL__c, s.SVMXC__Match_Account__c, s.SVMXC__Include_Top_Level__c, s.SVMXC__Include_Product__c, s.SVMXC__Include_Parent__c ,s.SVMXC__Select__c, s.SVMXC__Rule_Type__c, s.SVMXC__Name__c, s.SVMXC__Description__c, s.Name, s.Id From SVMXC__ServiceMax_Processes__c s where   s.SVMXC__Rule_Type__c='Auto Entitlement' and RecordType.Name='SVMX Rule' order by s.SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        System.debug('all process objects '+processobjs);
        Rtype = [select Id from RecordType where Name=:'SVMX Rule']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        /* system.debug('allobjs'+allobjs);
allobjs.putAll(allobjs2);*/
        if(processobjs.size()>0)
        {
            for(SVMXC__ServiceMax_Processes__c pobj:processobjs){
                if(pobj.SVMXC__Select__c == true){
                    pobj.SVMXC__Select__c =false;
                    
                }
            }
        }
        System.debug('all process objects Two '+processobjs);
        ClearSelOptList(Hdrfldlist);
        displaySeqPopup  =  false;
        IsConfigQuery =false;
        rulePirority = false;
        disbleSaveBttn = true;
        disbleCancelBttn = true;
        pickPageSection =false;
        pickPageSectionFour =true;
        IncludeProductDiplay = true;
        MatchedAccountDiplay = true;
        MatchContactDiplay = true;
        EnableLineLevelSLADiplay = true;
        
        isPrefrenceDisplay = false;
        List<SelectOption> so=getEntitlement_Scope();
        if(so[0].getValue() == 'Warranties'){
            PickFirstMatch =getTAG036(); 
            IncludeProductDiplay = false;
            MatchedAccountDiplay = false;
            MatchContactDiplay = false; 
            EnableLineLevelSLADiplay = false;
        }
        if(so[0].getValue() == 'Service Contracts'){
            PickFirstMatch =getTAG037();
        }
        
        if(processobjs == null || processobjs.size()==0){
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
            DisbleRuleSeqBttn = true;
        }
        if(processobjs == null || processobjs.size()==1){
            DisbleRuleSeqBttn = true;
        }
        
        CriExpressions.DefaultField = getTAG025();
        CriExpressions.DefaultOperator = getTAG025();
        CriExpressions.DefaultListValue = getTAG025();
        CriExpressions.ExpressionType = 'CRITERIA';
        
        /*Commented for the defect 041420 fix for view state issue as this code is of no use
        for(Schema.SObjectType lON : allObjs.values()) //Loop List of all Objects and describe each
        {
            Schema.DescribeSObjectResult D = lON.getDescribe();
            if(D.isAccessible() == true && D.isCreateable() == true && D.isCustom() == true)
            {
                HdrObjApiLable.put(D.getName(),D.getLabel());
                HeaderObjApiLocalName.put(D.getName(),D.getLocalName()); 
                mapHdrObjOpt.put(D.getName(), new SelectOption(D.getName(),D.getLabel()));
            }
        }*/
    }
    
    public List<SVMXC__ServiceMax_Processes__c> getProcessesRecords(){
        if(processobjs.size()==0){
            //DisbaleNoRecords =true;
            DisbaleRulePageTable = false;     
        }
        
        return processobjs;
    }
    
    public void SVMX_newButton(){
        
        System.debug('all process objects new button '+processobjs);  
        DisbleNewBttn = true;
        DisbleRuleSeqBttn = true;
        DisbleEdtBttn = true;
        DisbleDelBttn = true;
        CheckAllRules = false;
        DisbaleRulePageTable = true;
        disbleCancelBttn = false;
        showRule = true;
        DisbaleChkBox = true;
        disbleSaveBttn = false;
        DChkBox = true;
        strPreference = 'Location';
        for(integer i=0;i<processobjs.size();i++){
            processobjs[i].SVMXC__Select__c=false;              
        }
        EntitlementRuleProcess= new SVMXC__ServiceMax_Processes__c(SVMXC__Select__c=true);
        processobjs.add(EntitlementRuleProcess);
        showRule = true;
        System.debug('all process objects end of new button '+processobjs);  
        
        
        
    }
    public pageReference SVMX_editButton(){
        
        
        
        if(processobjs !=null && processobjs.size() >0)
        {
            DisbleNewBttn = true;
            DisbleEdtBttn = true;
            DisbleDelBttn = true;
            DisbaleChkBox = true;
            DisbleRuleSeqBttn = true;
            disbleSaveBttn = false;
            disbleCancelBttn = false;
            showRule = true;
            DChkBox = true;
            EdtCountRec = 0;
            IsConfigQuery =false;
            list<id> Idlst = new list<id>();
            System.debug('hari'+processobjs);
            for(integer i=0;i<processobjs.size();i++){
                if(processobjs[i].SVMXC__Select__c){                
                    showRule = true;
                    EdtCountRec=EdtCountRec+1;
                    EntitlementRuleProcess.SVMXC__Name__c = processobjs[i].SVMXC__Name__c;
                    EntitlementRuleProcess.SVMXC__Description__c= processobjs[i].SVMXC__Description__c;                 
                    EntitlementRuleProcess.SVMXC__Advance_Expression__c = processobjs[i].SVMXC__Advance_Expression__c;
                    if(processobjs[i].SVMXC__Match_Account__c )
                        MatchedAccount = 'Yes' ;
                    else
                        MatchedAccount = 'No' ;
                    
                    if(processobjs[i].SVMXC__Include_Parent__c )
                        IncludeParentProduct = 'Yes' ;
                    else
                        IncludeParentProduct = 'No' ;
                    
                    if(processobjs[i].SVMXC__Match_Contact__c )
                        MatchContact = 'Yes' ;
                    else
                        MatchContact = 'No' ;
                    
                    system.debug('processobjs[i].SVMXC__Allow_Override__c' + processobjs[i].SVMXC__Allow_Override__c);
                    if(processobjs[i].SVMXC__Allow_Override__c){
                        EnableLineLevelSLA = 'Yes' ;    
                    }
                    else
                        EnableLineLevelSLA = 'No' ;
                    
                    //Enhancement: Added to support Match Location in Auto Entitlement
                    if(processobjs[i].SVMXC__Match_Location__c )
                    {
                        strMatchedLoc = 'Yes';
                        if(processobjs[i].SVMXC__Target_URL__c != null )
                            strPreference = processobjs[i].SVMXC__Target_URL__c;
                        isPrefrenceDisplay = true;
                    }
                    else
                        strMatchedLoc = 'No';
                    
                    
                    
                    if(processobjs[i].SVMXC__Include_Top_Level__c )
                        IncludeTopLevelProduct = 'Yes' ;
                    else
                        IncludeTopLevelProduct = 'No' ;
                    
                    if(processobjs[i].SVMXC__Include_Product__c )
                        IncludeProduct = 'Yes' ;
                    else
                        IncludeProduct = 'No' ;
                    
                    EntitlementScope = processobjs[i].SVMXC__Entitlement_Scope__c ;
                    if(EntitlementScope !='Warranties' )
                    {
                        IncludeProductDiplay = true;
                        MatchedAccountDiplay = true;
                        MatchContactDiplay = true; 
                        EnableLineLevelSLADiplay = true;
                    }
                    if(EntitlementScope == 'Both')
                    {                             
                        pickPageSectionThree = true;
                        pickPageSectionFour = false; 
                        PickFirstMatch = processobjs[i].SVMXC__Pick_First_Match__c;                                                             
                    }
                    else{
                        if(processobjs[i].SVMXC__Pick_First_Match__c =='Service Contract')
                            PickFirstMatch = getTAG037();
                        if(processobjs[i].SVMXC__Pick_First_Match__c =='Warranty')
                            PickFirstMatch = getTAG036();
                        
                    }
                    
                    /*
else if(EntitlementScope == 'Service Contracts'){
pickPageSectionThree = true;
pickPageSectionFour = false;

}*/
                    EntitlementBy = processobjs[i].SVMXC__Entitlement_By__c ;
                    if(EntitlementBy =='Both' ){
                        pickPageSectionTwo = true;
                        
                    }                            
                    
                    CounterVsDates = processobjs[i].SVMXC__Counter_Vs_Dates_Rule__c ;                           
                    
                    System.debug('edit mode value'+PickFirstMatch);
                    
                    CriExpressions.AdvanceOption = EntitlementRuleProcess.SVMXC__Advance_Expression__c;
                    IsConfigQuery = true;
                    Idlst.add(processobjs[i].Id);        
                    
                }
            }
            if(EdtCountRec==0){
                showRule = false;
                IsRuleBlock = true;
                DisbleNewBttn = false;
                DisbleEdtBttn = false;
                DisbleDelBttn = false;
                DisbaleChkBox = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG026()));
            }
            if(EdtCountRec > 1){
                for(integer j=0;j<processobjs.size();j++){
                    processobjs[j].SVMXC__Select__c=false;}
                showRule = false;
                IsRuleBlock = true;
                DisbleNewBttn = false;
                DisbleEdtBttn = false;
                DisbleDelBttn = false;
                DisbaleChkBox = false;
                CheckAllRules = false;  
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG027()));
            }
            
            if(IsConfigQuery && EdtCountRec == 1 ){                          
                //Cnfiglst.clear(); //Commented for the defect 041420 fix for view state issue
                list<SVMXC__ServiceMax_Config_Data__c> Cnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();  
                Cnfiglst = database.query('Select SVMXC__Sequence__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, RecordTypeId From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:Idlst');
                if(Cnfiglst.size()>0){
                    CriExpressions.lstExpressions.clear();
                    for(SVMXC__ServiceMax_Config_Data__c Cnfig :Cnfiglst){
                        CriExpressions.setExpressions(Cnfig);
                    }
                }           
            }
        }
        
        
        
        return null;
    }
    public pageReference SVMX_delButton(){
        //ERuleToDelete.clear();
        //TempCnfiglst.clear();
        set<Id> ERuleIdSet = new set<Id>();
        Integer count=0;
        Boolean refreshpage;
        List<Integer> inCount = new  List<Integer>();
        List<SVMXC__ServiceMax_Processes__c> ERuleToDelete= new List<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> TempCnfiglst = new list<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Processes__c> tempProcessobj= new List<SVMXC__ServiceMax_Processes__c>();
        System.debug('asdf'+processobjs.size());
        if(processobjs.size()>0 )//&& processobjs!=null
        {
            
            for(integer i=0;i<processobjs.size();i++){
                if(processobjs[i].SVMXC__Select__c ){
                    
                    if(processobjs[i].Id != null){
                        System.debug('pobj'+processobjs[i]);
                        System.debug('count'+count);
                        count =count+1;
                        processobjs[i].SVMXC__Select__c =false;
                        ERuleIdSet.add(processobjs[i].Id);                                              
                        ERuleToDelete.add(processobjs[i]);
                        
                    }       
                    
                }
                else tempProcessobj.add(processobjs[i]);
                
            }
        }
        
        
        if(count == 0){
            refreshpage =false;
            IsRuleBlock = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG039()));
        }
        
        if(count !=0){
            if(ERuleIdSet !=null && ERuleIdSet.size()!=0){
                TempCnfiglst = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c IN:ERuleIdSet]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(TempCnfiglst!=null && TempCnfiglst.size()!=0 )
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                        
                        delete TempCnfiglst; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        refreshpage =false;
                        IsRuleBlock = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                }
                
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                    
                    delete ERuleToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                    refreshpage =false;
                    IsRuleBlock = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
                
                refreshpage = true;
                
                //ERuleToDelete.clear();
            }
            DisbleNewBttn = false;
            DisbleEdtBttn = false;
            CheckAllRules = false;
        }
        if(tempProcessobj.size()>0 && tempProcessobj!=null){
            processobjs = tempProcessobj;
        }
        if(refreshpage){
            String url = '/apex/EVER_SetupAutoEntRules';
            pageReference p=new pageReference(url);
            p.setRedirect(true);
            return p;
        }
        else return null;
        
        
        
    }
    public string RuleName;
    boolean ValidateRuleName;
    
    public boolean SVMX_ValidateRuleName(SVMXC__ServiceMax_Processes__c EntitlementRuleProcess)
    {
        ValidateRuleName = true;
        RuleName = EntitlementRuleProcess.SVMXC__Name__c;
        if(RuleName == null)
        {
            
            ValidateRuleName = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG028()));      
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
    public pageReference SVMX_saveButton()
    {
        System.debug('all process objects Save button '+processobjs);
        IsRuleBlock = true;
        Boolean SavRec = true;
        boolean IsError = true;  
        String url;
        pageReference p;
        RecordType recType = [select id from RecordType where Name=:'Expressions']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        System.debug('asdf'+EntitlementRuleProcess);
        System.debug('asdf'+Rtype.Id);
        boolean IsRuleNull=false;
        EntitlementRuleProcess.RecordTypeId=Rtype.Id;
        EntitlementRuleProcess.SVMXC__Rule_Type__c='Auto Entitlement'; 
        //RuleNameMap.clear(); //Commented for the defect 041420 fix for view state issue
        Map<String,Integer> RuleNameMap = new Map<String,Integer>();
        boolean IsValidate;
        for(integer i=0;i<processobjs.size();i++)
        { 
            if(processobjs[i].SVMXC__Select__c)
            {         
                EntitlementRuleProcess.SVMXC__Name__c = processobjs[i].SVMXC__Name__c;
            }
        }
        IsValidate=SVMX_ValidateRuleName(EntitlementRuleProcess);
        if(IsValidate==false)
        {
            for(integer i=0;i<processobjs.size();i++)
            {
                if(processobjs[i].id==null)
                {
                    processobjs[i].SVMXC__Select__c= true;
                }
                if(RuleId==processobjs[i].id)
                {
                    processobjs[i].SVMXC__Select__c= true;
                }
            }  
            return null;  
        }
        for(integer i=0;i<processobjs.size();i++)
        {                                                   
            
            if(processobjs[i].SVMXC__Name__c!=null)
            {
                //SavRec = false;
                RuleNameMap.put(processobjs[i].SVMXC__Name__c,i);
            }               
        }
        if( !IsRuleNull && RuleNameMap.size()>0 && processobjs.size()>0)
        {
            if(RuleNameMap.size()!=processobjs.size())
            {
                SavRec = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG035()));   
            }
            else
            {
                if(SavRec)
                {
                    System.debug('inside if condition');                
                    for(integer j=0;j<processobjs.size();j++)
                    {
                        if(processobjs[j].SVMXC__Select__c)
                        {                                                            
                            System.debug('process obj'+processobjs[j]);
                            if(processobjs[j].id==null)
                            {
                                EntitlementRuleProcess.SVMXC__Sequence__c=j;
                                EntitlementRuleProcess.SVMXC__Name__c = processobjs[j].SVMXC__Name__c;
                                EntitlementRuleProcess.SVMXC__Description__c = processobjs[j].SVMXC__Description__c;
                                if(MatchedAccount == 'Yes')
                                    EntitlementRuleProcess.SVMXC__Match_Account__c = true;
                                if(MatchedAccount == 'No')
                                    EntitlementRuleProcess.SVMXC__Match_Account__c = false;
                                if(IncludeParentProduct == 'Yes')
                                    EntitlementRuleProcess.SVMXC__Include_Parent__c = true;
                                if(IncludeParentProduct == 'No')
                                    EntitlementRuleProcess.SVMXC__Include_Parent__c = false;
                                if(MatchContact == 'Yes')
                                    EntitlementRuleProcess.SVMXC__Match_Contact__c = true;
                                if(MatchContact == 'No')
                                    EntitlementRuleProcess.SVMXC__Match_Contact__c = false;
                                if(EnableLineLevelSLA == 'Yes')
                                    EntitlementRuleProcess.SVMXC__Allow_Override__c = true;
                                if(EnableLineLevelSLA == 'No')
                                    EntitlementRuleProcess.SVMXC__Allow_Override__c = false;
                                
                                //Enhancement: Added to support Match Location in Auto Entitlement
                                if(strMatchedLoc == 'Yes')
                                {
                                    EntitlementRuleProcess.SVMXC__Match_Location__c = true;
                                    EntitlementRuleProcess.SVMXC__Target_URL__c = strPreference;
                                }
                                else if(strMatchedLoc == 'No')
                                {
                                    EntitlementRuleProcess.SVMXC__Match_Location__c = false;
                                    EntitlementRuleProcess.SVMXC__Target_URL__c = '';
                                }   
                                
                                if(IncludeTopLevelProduct == 'Yes')
                                    EntitlementRuleProcess.SVMXC__Include_Top_Level__c = true;
                                if(IncludeTopLevelProduct == 'No')
                                    EntitlementRuleProcess.SVMXC__Include_Top_Level__c = false;
                                if(IncludeProduct == 'Yes')
                                    EntitlementRuleProcess.SVMXC__Include_Product__c = true;
                                if(IncludeProduct == 'No')
                                    EntitlementRuleProcess.SVMXC__Include_Product__c = false;
                                EntitlementRuleProcess.SVMXC__Entitlement_Scope__c = EntitlementScope;
                                EntitlementRuleProcess.SVMXC__Entitlement_By__c = EntitlementBy;
                                EntitlementRuleProcess.SVMXC__Counter_Vs_Dates_Rule__c = CounterVsDates;  
                                if(PickFirstMatch == getTAG036())
                                    EntitlementRuleProcess.SVMXC__Pick_First_Match__c = 'Warranty';
                                if(PickFirstMatch == getTAG037())
                                    EntitlementRuleProcess.SVMXC__Pick_First_Match__c = 'Service Contract'; 
                                if(EntitlementScope == 'Both')
                                    EntitlementRuleProcess.SVMXC__Pick_First_Match__c = PickFirstMatch;
                                else
                                {
                                    if(PickFirstMatch == getTAG036())
                                    {
                                        EntitlementRuleProcess.SVMXC__Pick_First_Match__c = 'Warranty';
                                        EntitlementRuleProcess.SVMXC__Include_Product__c = false;
                                        EntitlementRuleProcess.SVMXC__Match_Account__c = false;
                                        EntitlementRuleProcess.SVMXC__Match_Contact__c = false;
                                        //Enhancement: Added to support Match Location in Auto Entitlement
                                        EntitlementRuleProcess.SVMXC__Match_Location__c = false;
                                        EntitlementRuleProcess.SVMXC__Target_URL__c = '';
                                        
                                    }
                                    if(PickFirstMatch == getTAG037())
                                        processobjs[j].SVMXC__Pick_First_Match__c = 'Service Contract';
                                } 
                                string headerCriteria = CriExpressions.getCriteria('Case');
                                if(headerCriteria != 'ERROR')
                                {
                                    EntitlementRuleProcess.SVMXC__Select__c= false; 
                                    EntitlementRuleProcess.SVMXC__Parent_Object_Criteria__c = headerCriteria;
                                    EntitlementRuleProcess.SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption;
                                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(EntitlementRuleProcess, COMM_SecurityUtils.Access.Createable)){
                                        insert EntitlementRuleProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                    }
                                    else{
                                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                                        return null;
                                    }
                                    
                                    mapCriExpressionsProperties.put('RecordTypeID',recType.Id);
                                    mapCriExpressionsProperties.put('SVMXC__Expression_Type__c', 'CASE_Auto_Entitlement');
                                    mapCriExpressionsProperties.put('SVMXC__Expression_Rule__c', EntitlementRuleProcess.Id);
                                    CriExpressions.getExpressions(mapCriExpressionsProperties);
                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG029()));
                                    showRule = false;
                                    DisbleNewBttn = false;
                                    DisbleEdtBttn = false;
                                    DisbleDelBttn = false;
                                    DisbaleChkBox=false;
                                    disbleSaveBttn = true;
                                    disbleCancelBttn = true;
                                    IsError = false;
                                    url = '/apex/EVER_SetupAutoEntRules';
                                }
                            }
                            else if(processobjs[j].id !=null) 
                            {
                                System.debug('process with id'+PickFirstMatch);
                                string headerCriteria = CriExpressions.getCriteria('Case');
                                processobjs[j].SVMXC__Sequence__c=j;
                                if(MatchedAccount == 'Yes')
                                    processobjs[j].SVMXC__Match_Account__c = true;
                                if(MatchedAccount == 'No')
                                    processobjs[j].SVMXC__Match_Account__c = false;
                                if(IncludeParentProduct == 'Yes')
                                    processobjs[j].SVMXC__Include_Parent__c = true;
                                if(IncludeParentProduct == 'No')
                                    processobjs[j].SVMXC__Include_Parent__c = false;
                                if(MatchContact == 'Yes')
                                    processobjs[j].SVMXC__Match_Contact__c = true;
                                if(MatchContact == 'No')
                                    processobjs[j].SVMXC__Match_Contact__c = false;
                                if(EnableLineLevelSLA == 'Yes')
                                    processobjs[j].SVMXC__Allow_Override__c = true;
                                if(EnableLineLevelSLA == 'No')
                                    processobjs[j].SVMXC__Allow_Override__c = false;
                                
                                //Enhancement: Added to support Match Location in Auto Entitlement
                                if(strMatchedLoc == 'Yes')
                                {
                                    processobjs[j].SVMXC__Match_Location__c = true;
                                    processobjs[j].SVMXC__Target_URL__c = strPreference;
                                }
                                else if(strMatchedLoc == 'No')
                                {
                                    processobjs[j].SVMXC__Match_Location__c = false;
                                    processobjs[j].SVMXC__Target_URL__c = '';
                                }
                                if(IncludeTopLevelProduct == 'Yes')
                                    processobjs[j].SVMXC__Include_Top_Level__c = true;
                                if(IncludeTopLevelProduct == 'No')
                                    processobjs[j].SVMXC__Include_Top_Level__c = false;
                                if(IncludeProduct == 'Yes')
                                    processobjs[j].SVMXC__Include_Product__c = true;
                                if(IncludeProduct == 'No')
                                    processobjs[j].SVMXC__Include_Product__c = false;
                                processobjs[j].SVMXC__Entitlement_Scope__c = EntitlementScope;
                                processobjs[j].SVMXC__Entitlement_By__c = EntitlementBy;
                                if(EntitlementBy =='Both')
                                    processobjs[j].SVMXC__Counter_Vs_Dates_Rule__c = CounterVsDates; 
                                else
                                    processobjs[j].SVMXC__Counter_Vs_Dates_Rule__c = null;
                                if(EntitlementScope == 'Both')
                                    processobjs[j].SVMXC__Pick_First_Match__c = PickFirstMatch;
                                else
                                {
                                    if(PickFirstMatch == getTAG036())
                                    {
                                        processobjs[j].SVMXC__Pick_First_Match__c = 'Warranty';
                                        processobjs[j].SVMXC__Include_Product__c = false;
                                        processobjs[j].SVMXC__Match_Account__c = false;
                                        processobjs[j].SVMXC__Match_Contact__c = false;
                                        //Enhancement: Added to support Match Location in Auto Entitlement
                                        processobjs[j].SVMXC__Match_Location__c = false;
                                        processobjs[j].SVMXC__Target_URL__c = '';
                                    }
                                    if(PickFirstMatch == getTAG037())
                                        processobjs[j].SVMXC__Pick_First_Match__c = 'Service Contract';
                                }
                                if(headerCriteria != 'ERROR')
                                {
                                    processobjs[j].SVMXC__Select__c= false;
                                    processobjs[j].SVMXC__Parent_Object_Criteria__c = headerCriteria;
                                    processobjs[j].SVMXC__Advance_Expression__c = CriExpressions.AdvanceOption;
                                    update processobjs[j];  
                                    mapCriExpressionsProperties.put('RecordTypeID',recType.Id);
                                    mapCriExpressionsProperties.put('SVMXC__Expression_Type__c', 'CASE_Auto_Entitlement');
                                    mapCriExpressionsProperties.put('SVMXC__Expression_Rule__c', processobjs[j].Id);
                                    CriExpressions.getExpressions(mapCriExpressionsProperties);
                                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG029()));
                                    showRule = false;
                                    DisbleNewBttn = false;
                                    DisbleEdtBttn = false;
                                    DisbleDelBttn = false;
                                    DisbaleChkBox=false;
                                    disbleSaveBttn = true;
                                    disbleCancelBttn = true;
                                    IsError = false;
                                    url = '/apex/EVER_SetupAutoEntRules';
                                }
                            }
                        }
                    }
                }
            }
        }
        if(IsError)
        {
            p=null; 
        }       
        else
        {                   
            p=new pageReference(url);
            p.setRedirect(true);
        }                   
        return  p;
    }
    public pageReference SVMX_cancelButton(){
        String url = '';
        /*
if(svmxSettingList.containsKey('SET001') == true)
url =svmxSettingList.get('SET001');
else
*/
        url = '/apex/EVER_SetupAutoEntRules';
        
        pageReference p=new pageReference(url);
        for(integer j=0;j<processobjs.size();j++){
            processobjs[j].SVMXC__Select__c=false;
            if(processobjs[j].Id==null){
                processobjs.remove(j);
            }
        }
        showRule = false;
        DisbaleChkBox=false;
        DisbleNewBttn = false;
        DisbleEdtBttn = false;
        p.setRedirect(true);
        return p;
    }
    public pageReference SVMX_backToSetupHome(){
        String url = '';
        
        //Added for the defect 041420 fix for view state issue
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('EVER003');
        
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u')
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        else if(svmxSettingList.containsKey('SET001') == true)
            url = svmxSettingList.get('SET001');          
        else        
            url ='/apex/SVMXC__CONF_SetupHome';
        
        PageReference HomePage = new PageReference(url);
        HomePage.setRedirect(true);
        return HomePage; 
    }
    // Properties
    public Boolean showRule { get; set; }
    public Boolean disableValue { get; set; }
    public String SelectedIndex { get; set;}
    public Boolean disbleNewBttn { get; set; }  
    public Boolean disbleEdtBttn { get; set; }  
    public Boolean disbleDelBttn { get; set; }
    public Boolean disbleSaveBttn { get; set; }
    public Boolean DisbleRuleSeqBttn { get; set; }
    public Boolean disbleCancelBttn { get; set; }
    public Boolean DisbaleChkBox {get; set; }
    public Boolean DisbaleRulePageTable {get; set; }
    public Boolean DisbaleNoRecords {get; set; }
    public Boolean displaySeqPopup {get; set; }
    
    public Boolean CheckAllRules {get; set; }
    public String MatchedAccount {get; set; }
    
    //Enhancement: Added MatchedLocation Variable to support Match Location in Auto Entitlement
    public String strMatchedLoc{get; set; }
    
    // for asking precedence
    public String strPreference {get; set; }
    
    public String IncludeTopLevelProduct {get; set; }
    public String IncludeParentProduct {get; set; }
    public String MatchContact {get; set; }
    public String EnableLineLevelSLA {get; set; }
    public String IncludeProduct {get; set; }
    public Boolean IsRuleBlock {get; set; }
    public Boolean IsConfigQuery {get; set; }
    public String EntitlementScope {get; set; }
    public String EntitlementBy {get; set; }
    public String CounterVsDates {get; set; }
    public String CheckValue {get; set; }
    public String optionsValue{get; set; }
    public String PickFirstMatch{get; set; }
    public String RankingRuleOne{get; set; }
    public String RankingRuleTwo{get; set; }
    public String RankingRuleThree{get; set; }
    public String RankingRuleFour{get; set; }
    public Boolean rulePirority {get; set; }
    public Boolean DChkBox{get; set; }
    public Boolean pickPageSection{get; set; }
    public Boolean pickPageSectionTwo{get; set; }
    public Boolean pickPageSectionThree{get; set; }
    public Boolean pickPageSectionFour{get; set; }
    public Boolean IncludeProductDiplay{get; set; }
    public Boolean MatchedAccountDiplay{get; set; }
    public Boolean MatchContactDiplay{get; set; }
    public Boolean EnableLineLevelSLADiplay{get; set; }
    public Boolean isPrefrenceDisplay{get; set; }
    public string SelectedID;
    public string SelectedLabel;
    public string getSelectedID() {return this.SelectedID;}
    public void setSelectedID(string str) {this.SelectedID = str;}
    public string getSelectedLabel() {return this.SelectedLabel;}
    public void setSelectedLabel(string str) {this.SelectedLabel = str;} 
    public COMM_SVMXC_Search_Expressions getCriExpressions() {return CriExpressions;}
    
    public void HdrADDRow(){ CriExpressions.addCriteriaExpression(1);}
    public void HdrDeleteRow(){ CriExpressions.removeCriteriaExpression(integer.valueOf(SelectedIndex));}
    
    public string getdelIndex (){return this.delIndex;}
    public void setdelIndex (string str){this.delIndex = str;}
    public string[] getitems(){
        return items;
    }    
    public void setitems(string[] o){
        this.items=o;
    }
    
    public void pickmatchAction()
    {
        IncludeProductDiplay = true;
        MatchedAccountDiplay = true;
        MatchContactDiplay = true;
        EnableLineLevelSLADiplay = true;
        if(strMatchedLoc == 'Yes')
            isPrefrenceDisplay = true;
        else
            isPrefrenceDisplay = false;
        if(EntitlementScope == 'Both')
        {
            pickPageSectionThree =true;
            pickPageSectionFour =false;
            
        }
        else if(EntitlementScope == 'Warranties')
        {
            pickPageSectionFour =true;
            pickPageSectionThree  = false;
            PickFirstMatch = getTAG036();
            IncludeProductDiplay = false;
            MatchedAccountDiplay = false;
            MatchContactDiplay = false;
            isPrefrenceDisplay = false;
            EnableLineLevelSLADiplay = false;
        }
        else if(EntitlementScope =='Service Contracts')
        {
            pickPageSectionFour =true;
            pickPageSectionThree  = false;
            PickFirstMatch = getTAG037();
        }
        
    }
    
    public void LocMatchAction()
    {
        if(strMatchedLoc == 'Yes')
            isPrefrenceDisplay = true;
        else
            isPrefrenceDisplay = false;
    }
    
    
    public void pickmatchActionTwo()
    {
        if(EntitlementBy == 'Both'){
            pickPageSectionTwo = true;
        }
        else
            pickPageSectionTwo = false;
        
    }
    
    //picklist values
    public List<SelectOption> getEntitlement_Scope() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult F = SVMXC__ServiceMax_Processes__c.SVMXC__Entitlement_Scope__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        for(integer loopIndex=0;loopIndex < p.size();loopIndex++)
        {
            options.add(new SelectOption(P[loopIndex].getValue(),P[loopIndex].getLabel()));
            
        }   
        return options;
        
    }
    public List<SelectOption> getEntitlement_By() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = SVMXC__ServiceMax_Processes__c.SVMXC__Entitlement_By__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        for(integer loopIndex=0;loopIndex < p.size();loopIndex++)
        {
            options.add(new SelectOption(P[loopIndex].getValue(),P[loopIndex].getLabel()));
        }
        
        return options;
        
    }
    public List<SelectOption> getCounter_Vs_Dates() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = SVMXC__ServiceMax_Processes__c.SVMXC__Counter_Vs_Dates_Rule__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        for(integer loopIndex=0;loopIndex < p.size();loopIndex++)
        {
            options.add(new SelectOption(P[loopIndex].getValue(),P[loopIndex].getLabel()));
        }
        
        return options;
        
    }
    public List<SelectOption> getPick_First_Match() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = SVMXC__ServiceMax_Processes__c.SVMXC__Pick_First_Match__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        for(integer loopIndex=0;loopIndex < p.size();loopIndex++)
        {
            if(P[loopIndex].getValue() == 'Warranty')
                options.add(new SelectOption(P[loopIndex].getValue(),getTAG036()));
            if(P[loopIndex].getValue() == 'Service Contract')
                options.add(new SelectOption(P[loopIndex].getValue(),getTAG037()));     
            //if(P[loopIndex].getValue() == 'Service Contract')
            //options.add(new SelectOption(P[loopIndex].getValue(),'Pick the Ranking Rule'));               
            
        }
        return options;
        
    }
    
    public List<SelectOption> getYesOrNo(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(getTAG041(),getTAG041()));
        options.add(new SelectOption(getTAG040(),getTAG040()));
        return options;
    }
    
    
    public List<SelectOption> getSeqoptionsPrefrens(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Location',getTAG050()));
        options.add(new SelectOption('Installed Product',getTAG051()));
        return options;
        
    }
    
    public Map<string,Integer> MyMap = new  Map<string,Integer>();
    public integer selIndex = 0;
    public boolean isUpAction = false;
    public boolean isDownAction = false;
    public boolean isTopAction = false;
    public boolean isBottomAction = false;
    public void SVMX_OrderSequence(){
        
        
        TempEntitlementRuleList.addAll(processobjs);
        DisbleNewBttn = true;
        displaySeqPopup = true;
        DisbleRuleSeqBttn = true;
        DisbleEdtBttn = true;
        disbleDelBttn = true;
        disbleSaveBttn = true;
        disbleCancelBttn = false;
    }
    public List<SelectOption> getSeqoptions(){    
        Seqoptions = new List<SelectOption>();            
        if (TempEntitlementRuleList.Size() >0){
            for(SVMXC__ServiceMax_Processes__c s:TempEntitlementRuleList){                                                          
                if (s.SVMXC__Name__c != null)
                    Seqoptions.add(new SelectOption(s.Id,s.SVMXC__Name__c));
            }
        }        
        return Seqoptions; 
    }
    public void shuffle(integer selIndex, boolean isTop ){
        SVMXC__ServiceMax_Processes__c temp;
        if(isTop){
            temp = TempEntitlementRuleList[selIndex];
            for(integer j=selIndex;j>0;j--){
                TempEntitlementRuleList[j] = TempEntitlementRuleList[j-1];
            }
            TempEntitlementRuleList[0] = temp;
        }
        else {
            temp = TempEntitlementRuleList[selIndex];
            for(integer j=selIndex;j<TempEntitlementRuleList.size()-1;j++){
                TempEntitlementRuleList[j] = TempEntitlementRuleList[j+1];
            }
            TempEntitlementRuleList[TempEntitlementRuleList.size()-1] = temp;
        }
    }
    
    public void Top(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempEntitlementRuleList.size()-1;j>0;j--){
            for(integer i=items.size()-1;i>=0;i--){
                if(items[i] == TempEntitlementRuleList[j].Id){
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
    public void UP(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempEntitlementRuleList.size();j++){
            for(integer i=0;i<items.size();i++){
                if(items[i]==TempEntitlementRuleList[0].Id){
                    TempEntitlementRuleList[j] = TempEntitlementRuleList[j];
                    // break;
                }
                else if(items[i]==TempEntitlementRuleList[j].Id){
                    temp = TempEntitlementRuleList[j]; 
                    TempEntitlementRuleList[j] = TempEntitlementRuleList[j-1];
                    TempEntitlementRuleList[j-1]=temp;                    
                    selIndex = j;
                    isUpAction = true;
                    isDownAction=false;
                    isTopAction=false;
                    isBottomAction=false;
                    TempEntitlementRuleList[selIndex-1].SVMXC__Sequence__c=selIndex-1;
                    TempEntitlementRuleList[selIndex].SVMXC__Sequence__c = selIndex;
                }
            }
        }
        
    }
    public void Down(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=TempEntitlementRuleList.size()-1;j>=0;j--){
            for(integer i=0;i<items.size();i++){
                if(items[i]==TempEntitlementRuleList[TempEntitlementRuleList.size()-1].Id){
                    TempEntitlementRuleList[j] = TempEntitlementRuleList[j];
                    // break;
                }
                else if(items[i]==TempEntitlementRuleList[j].Id){
                    temp = TempEntitlementRuleList[j]; 
                    TempEntitlementRuleList[j] = TempEntitlementRuleList[j+1];
                    TempEntitlementRuleList[j+1]=temp;                    
                    selIndex = j;
                    isUpAction = false;
                    isDownAction=true;
                    isTopAction=false;
                    isBottomAction=false;
                    TempEntitlementRuleList[selIndex+1].SVMXC__Sequence__c=selIndex+1;
                    TempEntitlementRuleList[selIndex].SVMXC__Sequence__c = selIndex;
                }
                
            }
            
        }
        
        
    }
    public void Bottom(){
        SVMXC__ServiceMax_Processes__c temp;
        for(integer j=0;j<TempEntitlementRuleList.size()-1;j++){
            for(integer i=0;i<items.size();i++){
                if(items[i] == TempEntitlementRuleList[j].Id){
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
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempEntitlementRuleList, COMM_SecurityUtils.Access.Updateable ) ) {
            if(isUpAction){
                update TempEntitlementRuleList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else if(isDownAction){
                update TempEntitlementRuleList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else if(isTopAction){
                for(integer i=0;i<TempEntitlementRuleList.size();i++){
                    TempEntitlementRuleList[i].SVMXC__Sequence__c=i;
                }
                update TempEntitlementRuleList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else if(isBottomAction){
                for(integer i=0;i<TempEntitlementRuleList.size();i++){
                    TempEntitlementRuleList[i].SVMXC__Sequence__c=i;
                }
                update TempEntitlementRuleList; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
        } else {
            if( isUpAction || isDownAction || isTopAction || isBottomAction ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );    
            }
        }        
        
        String url = '/apex/EVER_SetupAutoEntRules';
        pageReference p=new pageReference(url);
        p.setRedirect(true);
        return p;
        
    }
    
    //Tags section
    
    public String getTAG001(){ return System.Label.EVER003_TAG001;}  //'New'
    public String getTAG002(){ return System.Label.EVER003_TAG002;}  //Edit
    public String getTAG003(){ return System.Label.EVER003_TAG003;}  //Delete
    public String getTAG004(){ return System.Label.EVER003_TAG004;}  //Save
    public String getTAG005(){ return System.Label.EVER003_TAG005;}  //Cancel
    public String getTAG006(){ return System.Label.EVER003_TAG006;}  //Back To Setup Home 
    public String getTAG007(){ return System.Label.EVER003_TAG007;}  //in this Screen, you can create one or more advanced formulas based on Case information to configure the automatic entitlement of Cases.
    public String getTAG008(){ return System.Label.EVER003_TAG008;}  //processing.......
    public String getTAG009(){ return System.Label.EVER003_TAG009;}  //Name
    public String getTAG010(){ return System.Label.EVER003_TAG010;}  //Description
    public String getTAG011(){ return System.Label.EVER003_TAG011;}  //Field Name
    public String getTAG012(){ return System.Label.EVER003_TAG012;}  //Operator
    public String getTAG013(){ return System.Label.EVER003_TAG013;}//Value
    public String getTAG014(){ return System.Label.EVER003_TAG014;}//Specify the entitlement settings to be used when a Case matches the above criteria 
    public String getTAG015(){ return System.Label.EVER003_TAG015;}//Match Account
    public String getTAG016(){ return System.Label.EVER003_TAG016;}//Include Parent Product
    public String getTAG017(){ return System.Label.EVER003_TAG017;}//Match Contact
    public String getTAG018(){ return System.Label.EVER003_TAG018;}//Include Top-Level Product
    public String getTAG019(){ return System.Label.EVER003_TAG019;}//Include Product
    public String getTAG020(){ return System.Label.EVER003_TAG020;}//Select Wheather auto-entitlement should consider only warranties or service contract or both
    public String getTAG021(){ return System.Label.EVER003_TAG021;}//Indicate if warranties and service contracts should be searched using counters or  validity dates or both
    public String getTAG022(){ return System.Label.EVER003_TAG022;}//If you selected Both for the above questions, select your preference for processing counters and validity dates
    public String getTAG023(){ return System.Label.EVER003_TAG023;}//If multiple warranties and/or Service Contract are found,indicate below how Auto-entitlement should identify the most suitable match
    public String getTAG024(){ return System.Label.EVER003_TAG024;}//Advance Expression
    public String getTAG025(){ return System.Label.EVER003_TAG025;}//--None--
    public String getTAG026(){ return System.Label.EVER003_TAG026;}//Please select a Auto-Entitlemen to edit
    public String getTAG027(){ return System.Label.EVER003_TAG027;}//Please select only one Auto-Entitlemen to edit
    public String getTAG028(){ return System.Label.EVER003_TAG028;}//Please enter a valid Entitlement Rule name
    public String getTAG029(){ return System.Label.EVER003_TAG029;}//Record saved Succesfully
    //public String getTAG030(){ return System.Label.EVER003_TAG030;}//Most suitable match for Auto-entitlement
    //public String getTAG031(){ return System.Label.EVER003_TAG031;}//Select Option 1 for ranking
    //public String getTAG032(){ return System.Label.EVER003_TAG032;}//Select Option 2 for ranking
    //public String getTAG033(){ return System.Label.EVER003_TAG033;}//Select Option 3 for ranking
    //public String getTAG034(){ return System.Label.EVER003_TAG034;}//Select Option 4 for ranking
    public String getTAG035(){ return System.Label.EVER003_TAG035;}//Duplicate Auto-Entitlement Rule name
    public String getTAG036(){ return System.Label.EVER003_TAG036;}//Pick The First Warranty
    public String getTAG037(){ return System.Label.EVER003_TAG037;}//Pick the First Service Contract
    public String getTAG038(){ return System.Label.EVER003_TAG038;}//Select
    public String getTAG039(){ return System.Label.EVER003_TAG039;}//Please select a record to delete
    public String getTAG040(){ return System.Label.EVER003_TAG040;}//Yes
    public String getTAG041(){ return System.Label.EVER003_TAG041;}//Yes
    public string getHLPURL(){ return System.Label.EVER003_HLPURL;}
    public String getTAG042(){ return System.Label.EVER003_TAG042;}
    public String getTAG043() {return System.Label.EVER003_TAG043;}
    public String getTAG044() {return System.Label.EVER003_TAG044;}
    public String getTAG045() {return System.Label.EVER003_TAG045;}
    public String getTAG046() {return System.Label.EVER003_TAG046;}//Rule Sequence
    public String getTAG047() {return System.Label.EVER003_TAG047;}
    public String getTAG048() {return System.Label.EVER003_TAG048;} //'Should the Location on the Case/IB be matched with the Location entitled in the Service Contract?';}//System.Label.EVER003_TAG048
    
    public String getTAG049() {return 'Precedence ';}//System.Label.EVER006_TAG007
    public String getTAG050() {return 'Location';}
    public String getTAG051() {return 'Installed Product';}
    public String getTAG052(){ return System.Label.EVER003_TAG051;}
    
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2)  //,list<sobject> ObjList
    {
        RetriveField(ObjName, lst, m, m2, null);
    }
    public void RetriveField2(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT)  //,list<sobject> ObjList
    {
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>(); //Added for the defect 041420 fix for view state issue
        if(!mMapFieldList.containsKey(ObjName))
        {
            Map<String, Schema.SObjectType> allobjs =  Schema.getGlobalDescribe();
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
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>(); //Added for the defect 041420 fix for view state issue
        if(!mMapFieldList.containsKey(ObjName))
        {
            Map<String, Schema.SObjectType> allobjs =  Schema.getGlobalDescribe();
            Schema.SObjectType objT = allObjs.get(objName); 
            system.debug('asdf'+allObjs);
            system.debug('asdf'+objName);
            system.debug('asdf'+objT);           
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
                lst.add(new SelectOption(f.getName(),f.getLabel()));
            if(DT == null)
                lst.add(new SelectOption(f.getName(),f.getLabel()));
            
            if(m != null)
                m.put(f.getName(), f.getType());
            if(m2 != null)
                m2.put(f.getName(),f.getLabel());   
        }
        sortingSelectOption(lst, true);
    }     
    public void RetriveField(String ObjName, List<selectOption> lst, Map<String,Schema.Displaytype> m, Map<String,String> m2, Schema.Displaytype DT, string LCObjName)  //,list<sobject> ObjList
    {
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>(); //Added for the defect 041420 fix for view state issue
        if(!mMapFieldList.containsKey(ObjName))
        {
            Map<String, Schema.SObjectType> allobjs =  Schema.getGlobalDescribe();
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
    
    public void Do_CancelSearch(){ isDateSearch = false; isSearch = false;} 
    
    
    
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
            // ExpressionsTemp.lstExpressions[integer.valueOf(SelectedIndex)-1].OperandID = 'SVMX.CurrentUser';
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
            CriExpressions.objfieldMap = mMapFieldList.get('Case'); 
            CriExpressions.OnChangeField(integer.valueOf(SelectedIndex), true);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    public PageReference OnHdrObjSelect(){
        ClearSelOptList(Hdrfldlist);
        RetriveField('Case', Hdrfldlist, CriExpressions.mapFieldDispType, CriExpressions.FieldApiLable);
        CriExpressions.FieldsList = Hdrfldlist;        
        CriExpressions.objfieldMap = mMapFieldList.get('Case');       
        system.debug('mMapFieldList' + mMapFieldList);
        system.debug('CriExpressions.FieldsList' + CriExpressions.FieldsList);
        return null;
    }
    
    
    //------------------------------Sorting fuctoin --------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> so, boolean bSortByLabel)
    {
        try
        {
            map<string, selectOption> mapTemp = new map<string, SelectOption>();
            if(bSortByLabel)
            {   for(selectOption o :so){    mapTemp.put(o.getLabel()+'-'+o.getValue(), o);}}
            else
            {   for(selectOption o :so){ mapTemp.put(o.getValue()+'-'+o.getLabel(), o);}}
            list<string> lstTemp = new list<string>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            so.clear();
            for(string str: lstTemp)
            {   so.add(mapTemp.get(str));}
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
        return so;
    }
    
    COMM_SVMXC_Search_Expressions ExpressionsTemp;
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
    public List<selectoption> Hdrfldlist = new List<selectoption>();  //list of fields values
    public List<selectoption> getHdrFldlist() {return sortingSelectOption(Hdrfldlist, true);}
    public void ClearSelOptList(List<SelectOption> lst){
        lst.clear();
        lst.add(new SelectOption('',getTAG025()));
    }
    public void ClearSelOptMap ( map<string,SelectOption> m){
        m.clear();
        m.put('', new SelectOption('',getTAG025()));
    }
    
}