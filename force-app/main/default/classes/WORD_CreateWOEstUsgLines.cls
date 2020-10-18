/* Security Scanned */
public  with sharing class WORD_CreateWOEstUsgLines{
    
    
    //=========================================== URL Paramet   // ------------------------NPS Related changes  ---------
    public string getUserLocaleKey()
    {
        return UserInfo.getLanguage();
    }
    public string getUserID()
    {
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID()
    {
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    
    // -------------------------------ers ==============================================//
    String workorderId = System.currentPageReference().getParameters().get('id');
    String TarRecType = System.currentPageReference().getParameters().get('TargetRecordType');
    
    
    //============================================== Global variables =========================================//
    Boolean CheckAllLines=false;
    String WorkDetails = 'SVMXC__Service_Order_Line__c';
    Boolean ShowValidData = true;
    
    List<SelectOption> rTypeNames = new List<SelectOption>();
    
    String Usage = 'Usage/Consumption';
    Id UsgRecType = getUsgRecordTypes().Id;
    
    String Est = 'Estimate';
    Id EstRecType = getEstRecordTypes().Id;
    
    
    
    //================= Global Variables (with get & set methods) to manage display of Errors ===============//
    List<String> ErrorMessages = new  List<String> ();
    Boolean ValidRecords = true;
    
    public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
    public List<String> getErrorsList() {    return ErrorMessages; }  
    
    public Boolean DisplayBlockLevelMessage = false;
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }
    
    Pricebook2 priceBookUsg = new Pricebook2();
    Pricebook2 priceBookEst = new Pricebook2();
    
    
    
    
    //================================= Common Utility setting declaration =================================//
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    
    
    //Create instance of UTIL Class
    // SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    
    //public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> ();
    
    
    
    //====================================== List to store new lines =======================================//
    
    //====== Usage Part lines ====// 
    List<SVMXC__Service_Order_Line__c> UsagePartsLineArray = new List<SVMXC__Service_Order_Line__c> ();
    List<SVMXC__Service_Order_Line__c> TempUsagePartsLineArray = new List<SVMXC__Service_Order_Line__c> ();
    public List<SVMXC__Service_Order_Line__c> getNewWORDPartLine() {return TempUsagePartsLineArray; }
    public void setNewWORDPartLine(List<SVMXC__Service_Order_Line__c> objArray1) {TempUsagePartsLineArray = objArray1;} 
    
    
    //====== Usage Labor lines ====//
    List<SVMXC__Service_Order_Line__c> UsageLaborLineArray = new List<SVMXC__Service_Order_Line__c> ();
    List<SVMXC__Service_Order_Line__c> TempUsageLaborLineArray = new List<SVMXC__Service_Order_Line__c> ();
    public List<SVMXC__Service_Order_Line__c> getNewWORDLaborLine() {return TempUsageLaborLineArray; }
    public void setNewWORDLaborLine(List<SVMXC__Service_Order_Line__c> objArray2) {TempUsageLaborLineArray = objArray2;}
    
    
    //===== Usage Expenses lines ====// 
    List<SVMXC__Service_Order_Line__c> UsageExpLineArray = new List<SVMXC__Service_Order_Line__c> ();
    List<SVMXC__Service_Order_Line__c> TempUsageExpLineArray = new List<SVMXC__Service_Order_Line__c> ();
    public List<SVMXC__Service_Order_Line__c> getNewWORDExpLine() {return TempUsageExpLineArray; }
    public void setNewWORDExpLine(List<SVMXC__Service_Order_Line__c> objArray3) {TempUsageExpLineArray = objArray3;}
    
    
    //=====  Estimate Part lines  ====//
    List<SVMXC__Service_Order_Line__c> EstimateLineArray = new List<SVMXC__Service_Order_Line__c> ();
    List<SVMXC__Service_Order_Line__c> TempEstimateLineArray = new List<SVMXC__Service_Order_Line__c> ();
    public List<SVMXC__Service_Order_Line__c> getNewWORDEstLine() {return TempEstimateLineArray;}
    public void setNewWORDEstLine(List<SVMXC__Service_Order_Line__c> objArray4) {TempEstimateLineArray = objArray4;}
    
    
    //=====  Estimate Labor lines  ====//
    List<SVMXC__Service_Order_Line__c> EstimateLabLineArray = new List<SVMXC__Service_Order_Line__c> ();
    List<SVMXC__Service_Order_Line__c> TempEstimateLabLineArray = new List<SVMXC__Service_Order_Line__c> ();
    public List<SVMXC__Service_Order_Line__c> getNewWORDEstLabLine() {return TempEstimateLabLineArray;}
    public void setNewWORDEstLabLine(List<SVMXC__Service_Order_Line__c> objArray5) {TempEstimateLabLineArray = objArray5;}
    
    
    //=====  Estimate Expenses lines  ====//
    List<SVMXC__Service_Order_Line__c> EstimateExpLineArray = new List<SVMXC__Service_Order_Line__c> ();
    List<SVMXC__Service_Order_Line__c> TempEstimateExpLineArray = new List<SVMXC__Service_Order_Line__c> ();
    public List<SVMXC__Service_Order_Line__c> getNewWORDEstExpLine() {return TempEstimateExpLineArray;}
    public void setNewWORDEstExpLine(List<SVMXC__Service_Order_Line__c> objArray6) {TempEstimateExpLineArray = objArray6;}
    
    
    //======================================== Setting Definition =========================================//
    public Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('WORD005');
    String UsageSetng_usePriceFromPriceBook = AllSubModuleSettings.get('SET003'); //setting for UsePriceFromPricebook flag
    String Setng_UsagePriceBook = AllSubModuleSettings.get('SET004'); //setting to get Work Order line pricebook
    String EstSetng_usePriceFromPriceBook = AllSubModuleSettings.get('SET005'); //setting for UsePriceFromPricebook flag
    String Setng_EstPriceBook = AllSubModuleSettings.get('SET006'); //setting to get Work Order line pricebook
    String setng_DefaultConsumptionLoc=AllSubModuleSettings.get('SET014');
    String setng_BillingValue='';
    String setng_Entitle='';
    
    
    
    //====================================== Getter & Setter methods ==========================================//
    public Boolean getCheckAllLines(){return CheckAllLines;}
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
    
    public Boolean getShowValidData(){ return ShowValidData;} 
    public void setShowValidData(Boolean svd) {ShowValidData=svd;}
    
    RecordType TargetRecType;
    public String getTargetRecType(){
        if (TargetRecType!=null) return TargetRecType.Name; 
        else return null;
    }
    
    
    //============================== Method to Display Errors/Warnings ======================================// 
    public void DisplayErrorsNWarnings(){
        
        if( ErrorMessages.size()>0)
        {
            ValidRecords = false;  
            DisplayBlockLevelMessage = false; 
            for (String msg : ErrorMessages)
            {
                //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG007(),msg)) ;  
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,msg)) ;
            }
        }   
    }
    
    
    //================================================ Constructor ============================================//
    public String defActType;
    public String defExpType;
    public Boolean Isbillableval=false;
    public WORD_CreateWOEstUsgLines(ApexPages.StandardController controller)
    {
        
        System.debug('AllSubModuleSettings'+AllSubModuleSettings);
        if(AllSubModuleSettings.containskey('SET015'))
            setng_BillingValue = AllSubModuleSettings.get('SET015');
        if(AllSubModuleSettings.containskey('SET016'))
            setng_Entitle = AllSubModuleSettings.get('SET016');
        WOHeader = new SVMXC__Service_Order__c(); 
        WOHeader = getWOrderHeader();
        if (workorderId == null)
        {
            ShowValidData = false;
            AddToErrorsList(getTAG008());       //Source Object Work Order Id not found
        }
        
        if (TarRecType == null)
        {
            ShowValidData = false;
            AddToErrorsList(getTAG024());       //Source Object Target Record Type Name not found
        }
        
        
        
        /*system.debug('yyyyyyyy'+WOHeader.SVMXC__Billing_Type__c);
if((WOHeader.SVMXC__Billing_Type__c=='Warranty')||(WOHeader.SVMXC__Billing_Type__c=='Contract'))
{
Isbillableval=false;  
}
else
Isbillableval=true;*/
        System.debug('***setng_BillingValue'+setng_BillingValue);
        if(setng_BillingValue != null && setng_BillingValue.length() > 0 && setng_BillingValue.touppercase() == 'TRUE'){
            Isbillableval=true;
        }
        else if(setng_BillingValue != null && setng_BillingValue.length() > 0 && setng_BillingValue.touppercase() == 'FALSE'){
            Isbillableval=false; 
        }
        else if(setng_BillingValue != null && setng_BillingValue.length() > 0 && setng_BillingValue.touppercase() == 'ENTITLEMENT' && setng_Entitle != null && setng_Entitle.length() > 0){
            List<String> billList= setng_Entitle.split(',');
            System.debug('*****billList'+billList);
            for(String bill:billList){
                // Added by bala: WOHeader.SVMXC__Billing_Type__c check was not there earlier
                if(WOHeader.SVMXC__Billing_Type__c != null && bill.touppercase() == WOHeader.SVMXC__Billing_Type__c.touppercase()){
                    System.debug('*****bill'+bill);
                    Isbillableval=true;
                } 
                else
                    Isbillableval=false; 
            }
        }
        
        getNewEstUsageLine();
        TargetRecType = getRecordType(TarRecType,'SVMXC__Service_Order_Line__c');
        
        defActType = utils.SVMX_getDefaultPicklistValue('SVMXC__Service_Order_Line__c', 'SVMXC__Activity_Type__c');
        defExpType = utils.SVMX_getDefaultPicklistValue('SVMXC__Service_Order_Line__c', 'SVMXC__Expense_Type__c');
        
        for (SVMXC__Service_Order_Line__c line1 :  UsagePartsLineArray)
        {
            line1.SVMXC__Select__c = false;
            TempUsagePartsLineArray.add(line1);   
        }
        
        for (SVMXC__Service_Order_Line__c line2 :  UsageLaborLineArray)
        {
            line2.SVMXC__Select__c = false;
            if(line2.SVMXC__Activity_Type__c == null) line2.SVMXC__Activity_Type__c = defActType;
            TempUsageLaborLineArray.add(line2);   
        }
        
        for (SVMXC__Service_Order_Line__c line3 :  UsageExpLineArray)
        {
            line3.SVMXC__Select__c = false;
            if(line3.SVMXC__Expense_Type__c == null) line3.SVMXC__Expense_Type__c = defExpType ;
            TempUsageExpLineArray.add(line3);   
        }
        
        for (SVMXC__Service_Order_Line__c line4 :  EstimateLineArray)
        {
            line4.SVMXC__Select__c = false;
            TempEstimateLineArray.add(line4);   
        }
        
        for (SVMXC__Service_Order_Line__c line5 :  EstimateLabLineArray)
        {
            line5.SVMXC__Select__c = false;
            if(line5.SVMXC__Activity_Type__c == null) line5.SVMXC__Activity_Type__c = defActType;
            TempEstimateLabLineArray.add(line5);   
        }
        
        for (SVMXC__Service_Order_Line__c line6 :  EstimateExpLineArray)
        {
            line6.SVMXC__Select__c = false;
            if(line6.SVMXC__Expense_Type__c == null) line6.SVMXC__Expense_Type__c = defExpType ;
            TempEstimateExpLineArray.add(line6);   
        }
        
        ValidateAllSettings();   
        DisplayErrorsNWarnings();
        
    }
    
    //===================================== Validation for all Settings ===================================//
    public void ValidateAllSettings(){
        
        if (UsageSetng_usePriceFromPriceBook == null)
        {
            ShowValidData = false;
            AddToErrorsList(getTAG009()); //Setting not available for the flag Usage usePriceFromPriceBook
        }
        
        if ((UsageSetng_usePriceFromPriceBook!=null)&& (UsageSetng_usePriceFromPriceBook.toUpperCase() !='FALSE'))
        {   
            if (Setng_UsagePriceBook == null)
            {
                ShowValidData = false;
                AddToErrorsList(getTAG009());  //Setting not available for Work Detail Usage PriceBook
            }   
            else
            {
                priceBookUsg = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(Setng_UsagePriceBook);       
                if(priceBookUsg == null)
                {
                    ShowValidData = false;
                    AddToErrorsList(getTAG025());    //PriceBook not found for Work Detail Usage Record type
                }
            }
        } 
        
        if (EstSetng_usePriceFromPriceBook == null)
        {
            ShowValidData = false;
            AddToErrorsList(getTAG009()); //Setting not available for the flag Estimate usePriceFromPriceBook
        } 
        
        if ((EstSetng_usePriceFromPriceBook!=null)&& (EstSetng_usePriceFromPriceBook.toUpperCase() !='FALSE'))
        {   
            if (Setng_EstPriceBook == null)
            {
                ShowValidData = false;
                AddToErrorsList(getTAG009());  //Setting not available for Work Detail Estimate PriceBook
            }   
            else
            {
                priceBookEst = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(Setng_EstPriceBook);       
                if(priceBookEst == null)
                {
                    ShowValidData = false;
                    AddToErrorsList(getTAG037());    //PriceBook not found for Work Detail Estimate Record type
                }
            }
        } 
        
    }
    
    
    //========================================== Method to get RecordType =====================================//
    public RecordType getRecordType(String Name,String SobjectType)
    {
        RecordType rType;
        String SOQL  = 'SELECT Id,Name  FROM RecordType  where SobjectType  =\''+SobjectType+'\' AND Name=\''+Name+'\' ';        
        try{
            
            rType = Database.query(SOQL); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
        } catch (Exception e){ 
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
            return null;}  
        
        return rType;
    }
    
    
    
    //========================================== Retriving Source Object Record ===============================//
    SVMXC__Service_Order__c WOHeader;
    public SVMXC__Service_Order__c getWOrderHeader() {
        
        try{
            
            String SOQLDetail;
            if(Userinfo.isMultiCurrencyOrganization())                
                SOQLDetail = ' SELECT Id, Name, CurrencyIsoCode,SVMXC__Billing_Type__c From SVMXC__Service_Order__c where Id=\''+workorderId+'\'';
            else
                SOQLDetail = ' SELECT Id, Name, SVMXC__Billing_Type__c From SVMXC__Service_Order__c where Id=\''+workorderId+'\'';
            
            WOHeader= Database.query(SOQLDetail);
        } catch (Exception e){ 
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
            return null;}
        
        return WOHeader;
    }
    
    //========================== Method to retrive Usage/Consumption Record Type ==========================//
    public RecordType getUsgRecordTypes(){
        
        RecordType erUTypes;
        
        try{
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+WorkDetails+'\' and Name=\''+Usage+'\' ';
            
            erUTypes = Database.query(SOQL); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
        } catch (Exception e){ 
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
            return null;}
        
        return erUTypes;
    }
    
    //========================== Method to retrive Usage/Consumption Record Type ==========================//
    public RecordType getEstRecordTypes(){
        
        RecordType erETypes;
        
        try{
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+WorkDetails+'\' and Name=\''+Est+'\' ';
            
            erETypes = Database.query(SOQL); //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
        } catch (Exception e){ 
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
            return null;}
        
        return erETypes;
    }
    
    
    List<SVMXC__Service_Order_Line__c> UsgLineDetail;
    
    public void getNewEstUsageLine(){
        
        try{
            String fieldNames;
            String SOQLDetail;
            
            Schema.DescribeSObjectResult dsoResult = SVMXC__Service_Order_Line__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Order_Line__c.fields.getMap();
            
            //build a list of all fieldnames for the object
            List<String> fieldList = utils.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utils.SVMX_getFieldNamesFromList(fieldList);
            
            SOQLDetail = ' SELECT '+fieldNames+' FROM SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c=\''+workorderId+'\'';        
            
            UsgLineDetail = Database.query(SOQLDetail);     
            
            for ( SVMXC__Service_Order_Line__c UsgLines : UsgLineDetail) 
            {
                system.debug('entered first');
                if(UsgLines.SVMXC__Line_Type__c=='Parts' && UsgLines.RecordTypeId == UsgRecType)
                {
                    UsgLines.SVMXC__Select__c = false;
                    
                    UsagePartsLineArray.add(UsgLines);
                }  
                
                if(UsgLines.SVMXC__Line_Type__c=='Labor' && UsgLines.RecordTypeId == UsgRecType)
                {
                    system.debug('entered sec');
                    UsgLines.SVMXC__Select__c = false;
                    UsageLaborLineArray.add(UsgLines);
                }  
                
                if(UsgLines.SVMXC__Line_Type__c=='Expenses' && UsgLines.RecordTypeId == UsgRecType)
                {
                    system.debug('entered third');
                    UsgLines.SVMXC__Select__c = false;
                    UsageExpLineArray.add(UsgLines);
                } 
                
                if(UsgLines.SVMXC__Line_Type__c=='Parts' && UsgLines.RecordTypeId == EstRecType)
                {
                    system.debug('entered fourth');
                    UsgLines.SVMXC__Select__c = false;
                    EstimateLineArray.add(UsgLines);
                } 
                
                if(UsgLines.SVMXC__Line_Type__c=='Labor' && UsgLines.RecordTypeId == EstRecType)
                {
                    UsgLines.SVMXC__Select__c = false;
                    EstimateLabLineArray.add(UsgLines);
                } 
                
                if(UsgLines.SVMXC__Line_Type__c=='Expenses' && UsgLines.RecordTypeId == EstRecType)
                {
                    UsgLines.SVMXC__Select__c = false;
                    EstimateExpLineArray.add(UsgLines);
                } 
                
            }
            
        } catch (Exception e){ 
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));}
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));}
        
    }
    
    
    
    //========================== Method to retrive Received Location from Work Detail =======================//
    public SVMXC__Service_Order_Line__c getSVMX_WorkDetails() {
        
        SVMXC__Service_Order_Line__c SVMX_WorkDetails = new SVMXC__Service_Order_Line__c(); 
        
        String SOQLDetail = ' SELECT Id, Name, Received_Location__c From SVMXC__Service_Order_Line__c LIMIT 1';
        
        SVMX_WorkDetails = Database.query(SOQLDetail); 
        return SVMX_WorkDetails;           
    } 
    
    //============== Method executes on click of Save Button in usage/Consumption rec type =================//
    public PageReference SaveUsageLines() {
        
        if(isValidData()==true)
        {
            for (SVMXC__Service_Order_Line__c PreEditLine1 : UsagePartsLineArray)
            {
                
                Boolean OldLineExist = false;
                for (SVMXC__Service_Order_Line__c PostEditLine1 : TempUsagePartsLineArray)
                {
                    if (PreEditLine1.Id == PostEditLine1.Id) 
                    {
                        OldLineExist = true;                            
                        break;                              
                    }
                }                   
                if(OldLineExist !=true)
                {               
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Order_Line__c' ) ) {
                        
                        delete PreEditLine1; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }         
                }
            }
            system.debug('B4 Update ' + TempUsagePartsLineArray);
             if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempUsagePartsLineArray, COMM_SecurityUtils.Access.Upsertable)){
                 
                    upsert  TempUsagePartsLineArray; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
            
            system.debug('After Update ' + TempUsagePartsLineArray);
            for (SVMXC__Service_Order_Line__c PreEditLine2 : UsageLaborLineArray)
            {
                Boolean OldLineExist = false;
                for (SVMXC__Service_Order_Line__c PostEditLine2 : TempUsageLaborLineArray)
                {
                    if (PreEditLine2.Id == PostEditLine2.Id) 
                    {
                        OldLineExist = true;                            
                        break;                              
                    }
                }                   
                if(OldLineExist !=true)
                {               
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Order_Line__c' ) ) {
                        
                        delete PreEditLine2; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }         
                }
                
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempUsageLaborLineArray, COMM_SecurityUtils.Access.Upsertable)){
                
                upsert  TempUsageLaborLineArray; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }           
            for (SVMXC__Service_Order_Line__c PreEditLine3 : UsageExpLineArray)
            {
                Boolean OldLineExist = false;
                for (SVMXC__Service_Order_Line__c PostEditLine3 : TempUsageExpLineArray)
                {
                    if (PreEditLine3.Id == PostEditLine3.Id) 
                    {
                        OldLineExist = true;                            
                        break;                              
                    }
                }                   
                if(OldLineExist !=true)
                {               
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Order_Line__c' ) ) {
                        
                        delete PreEditLine3; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }         
                }
                
            }    
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempUsageExpLineArray, COMM_SecurityUtils.Access.Upsertable)){
                
                upsert  TempUsageExpLineArray; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            
            PageReference newSQPage = new PageReference('/' + workorderId);
            return newSQPage;
        }
        else
        {
            displayErrors();
        }
        return null;
    }
    
    public void displayErrors(){
        
        for(SVMXC__Service_Order_Line__c line1 :TempUsagePartsLineArray)
        {      
            if(line1.SVMXC__Actual_Quantity2__c == null)
            {  
                line1.SVMXC__Actual_Quantity2__c.addError(getTAG027());    
            }
        }
        
        for(SVMXC__Service_Order_Line__c line2 :TempUsageLaborLineArray)
        {      
            if(line2.SVMXC__Activity_Type__c == null && line2.SVMXC__Start_Date_and_Time__c == null && line2.SVMXC__End_Date_and_Time__c == null && line2.SVMXC__Estimated_Quantity2__c == null && line2.SVMXC__Estimated_Price2__c == null && line2.SVMXC__Discount__c == null && line2.SVMXC__Work_Description__c == null)
            {                       
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG041()));
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG041()));
            }
        }
        for(SVMXC__Service_Order_Line__c line3 :TempUsageExpLineArray)
        {
            if(line3.SVMXC__Expense_Type__c == null && line3.SVMXC__Estimated_Quantity2__c == null && line3.SVMXC__Estimated_Price2__c == null && line3.SVMXC__Discount__c == null && line3.SVMXC__Work_Description__c == null)
            { 
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG042()));                      
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG042()));
            }
        }
        
    }
    
    //====================== Method executes on click of Save Button in Estimate rec type ====================//
    public PageReference SaveEstLines() {
        
        if(isValidDataEst()==true)
        {
            system.debug('SaveEstLines');
            for (SVMXC__Service_Order_Line__c PreEditLine4 : EstimateLineArray)
            {
                Boolean OldLineExist = false;
                for (SVMXC__Service_Order_Line__c PostEditLine4 : TempEstimateLineArray)
                {
                    if (PreEditLine4.Id == PostEditLine4.Id) 
                    {
                        OldLineExist = true;                            
                        break;                              
                    }
                }                   
                if(OldLineExist !=true)
                {               
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Order_Line__c' ) ) {
                       
                        delete PreEditLine4;  //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }         
                }
                
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempEstimateLineArray, COMM_SecurityUtils.Access.Upsertable)){
                
                upsert  TempEstimateLineArray; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }           
            
            
            
            for (SVMXC__Service_Order_Line__c PreEditLine5 : EstimateLabLineArray)
            {
                Boolean OldLineExist = false;
                for (SVMXC__Service_Order_Line__c PostEditLine5 : TempEstimateLabLineArray)
                {
                    if (PreEditLine5.Id == PostEditLine5.Id) 
                    {
                        OldLineExist = true;                            
                        break;                              
                    }
                }                   
                if(OldLineExist !=true)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Order_Line__c' ) ) {
                        
                        delete PreEditLine5; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempEstimateLabLineArray, COMM_SecurityUtils.Access.Upsertable)){
                
                upsert  TempEstimateLabLineArray; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }               
            
            
            
            for (SVMXC__Service_Order_Line__c PreEditLine6 : EstimateExpLineArray)
            {
                Boolean OldLineExist = false;
                for (SVMXC__Service_Order_Line__c PostEditLine6 : TempEstimateExpLineArray)
                {
                    if (PreEditLine6.Id == PostEditLine6.Id) 
                    {
                        OldLineExist = true;                            
                        break;                              
                    }
                }                   
                if(OldLineExist !=true)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Order_Line__c' ) ) {
                        
                        delete PreEditLine6; //SDL-SVMX-DELETE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                }
                
            }
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TempEstimateExpLineArray, COMM_SecurityUtils.Access.Upsertable)){
                
                upsert  TempEstimateExpLineArray; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            
            PageReference newSQPage = new PageReference('/' + workorderId);
            return newSQPage;
        }
        else
        {
            displayErrorsEst();
        }
        return null;
    }
    
    public void displayErrorsEst(){
        
        for(SVMXC__Service_Order_Line__c line4 :TempEstimateLineArray)
        {      
            if(line4.SVMXC__Product__c == null && line4.SVMXC__Estimated_Quantity2__c == null && line4.SVMXC__Estimated_Price2__c == null && line4.SVMXC__Discount__c == null && line4.SVMXC__Work_Description__c == null)
            {                       
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG040())); 
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG040()));
            }
        }
        
        
        for(SVMXC__Service_Order_Line__c line5 :TempEstimateLabLineArray)
        {      
            if(line5.SVMXC__Activity_Type__c == null && line5.SVMXC__Start_Date_and_Time__c == null && line5.SVMXC__End_Date_and_Time__c == null && line5.SVMXC__Estimated_Quantity2__c == null && line5.SVMXC__Estimated_Price2__c == null && line5.SVMXC__Discount__c == null && line5.SVMXC__Work_Description__c == null)
            {                       
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG041())); 
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG041()));
            }
        }
        for(SVMXC__Service_Order_Line__c line6 :TempEstimateExpLineArray)
        {
            if(line6.SVMXC__Expense_Type__c == null && line6.SVMXC__Estimated_Quantity2__c == null && line6.SVMXC__Estimated_Price2__c == null && line6.SVMXC__Discount__c == null && line6.SVMXC__Work_Description__c == null)
            { 
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG042()));
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG042()));
            }
        }
        
    }
    
    //==================== Method executes on click of Add Part Lines Button (Usage) ========================//
    public PageReference AddPartsLine(){
        
        List<SVMXC__Service_Group_Members__c> Technician = new List<SVMXC__Service_Group_Members__c>();
        system.debug('SettingVal'+setng_DefaultConsumptionLoc.toUpperCase());
        if (setng_DefaultConsumptionLoc.toUpperCase() =='TRUE')
        {
            String SOQLDetail='Select s.SVMXC__Salesforce_User__c, s.SVMXC__Inventory_Location__c From SVMXC__Service_Group_Members__c s where s.SVMXC__Salesforce_User__c=\''+UserInfo.getUserId()+'\' Limit 1';
            Technician= Database.query(SOQLDetail); 
        }
        
        SVMXC__Service_Order_Line__c newpartline = new SVMXC__Service_Order_Line__c(); 
        if(Userinfo.isMultiCurrencyOrganization()) //added 2 lines below by hh for defect closure #1630 on 12/01/2011
            newpartline.put('CurrencyIsoCode',WOHeader.get('CurrencyIsoCode'));
        
        if (UsageSetng_usePriceFromPriceBook.toUpperCase() =='TRUE')
            newpartline.SVMXC__Use_Price_From_Pricebook__c=  true;                
        else
            newpartline.SVMXC__Use_Price_From_Pricebook__c=  false;    
        
        newpartline.SVMXC__Is_Billable__c = Isbillableval;
        newpartline.SVMXC__Service_Order__c = workorderId; 
        newpartline.SVMXC__Line_Type__c = 'Parts';
        newpartline.RecordTypeId = UsgRecType;
        system.debug('TechSize'+Technician.size());
        system.debug('TechSize1'+newpartline.SVMXC__Consumed_From_Location__c);
        if (Technician.size() >0 && newpartline.SVMXC__Consumed_From_Location__c == null)
        {
            newpartline.SVMXC__Consumed_From_Location__c=Technician[0].SVMXC__Inventory_Location__c;
        }
        TempUsagePartsLineArray.add(newpartline);         
        return null;
        
    }    
    
    //===================== Method executes on click of Add Labor Lines Button (Usage) ======================//
    public PageReference AddLaborLine(){    
        
        SVMXC__Service_Order_Line__c newlaborline = new SVMXC__Service_Order_Line__c();
        
        if(Userinfo.isMultiCurrencyOrganization()) //added 2 lines below by hh for defect closure #1630 on 12/01/2011
            newlaborline.put('CurrencyIsoCode',WOHeader.get('CurrencyIsoCode'));
        
        newlaborline.SVMXC__Service_Order__c = workorderId; 
        newlaborline.SVMXC__Line_Type__c = 'Labor';
        newlaborline.SVMXC__Is_Billable__c = Isbillableval;
        newlaborline.RecordTypeId = UsgRecType;
        newlaborline.SVMXC__Activity_Type__c = defActType;
        
        TempUsageLaborLineArray.add(newlaborline);         
        return null;
        
    }    
    
    //==================== Method executes on click of Add Expenses Lines Button (Usage) ====================//
    public PageReference AddExpLine(){    
        
        SVMXC__Service_Order_Line__c newexpline = new SVMXC__Service_Order_Line__c(); 
        
        if(Userinfo.isMultiCurrencyOrganization()) //added 2 lines below by hh for defect closure #1630 on 12/01/2011
            newexpline.put('CurrencyIsoCode',WOHeader.get('CurrencyIsoCode'));
        
        newexpline.SVMXC__Service_Order__c = workorderId;
        newexpline.SVMXC__Line_Type__c = 'Expenses';
        newexpline.SVMXC__Is_Billable__c = Isbillableval;
        newexpline.RecordTypeId = UsgRecType;
        newexpline.SVMXC__Expense_Type__c = defExpType;
        TempUsageExpLineArray.add(newexpline);         
        return null;
        
    } 
    
    
    //================ Method executes on click of Add Lines Button on Estimate Record Type =================//
    public PageReference AddEstimateLine(){    
        
        SVMXC__Service_Order_Line__c newestline = new SVMXC__Service_Order_Line__c();
        
        if (EstSetng_usePriceFromPriceBook.toUpperCase() =='TRUE')
            newestline.SVMXC__Use_Price_From_Pricebook__c = true;                
        else
            newestline.SVMXC__Use_Price_From_Pricebook__c = false;   
        
        if(Userinfo.isMultiCurrencyOrganization()) //added 2 lines below by hh for defect closure #1630 on 12/01/2011
            newestline.put('CurrencyIsoCode',WOHeader.get('CurrencyIsoCode'));
        
        newestline.RecordTypeId = EstRecType;
        newestline.SVMXC__Line_Type__c = 'Parts';
        newestline.SVMXC__Service_Order__c = workorderId; 
        
        TempEstimateLineArray.add(newestline);         
        return null;
        
    } 
    
    
    //============== Method executes on click of Add Labor Lines Button on Estimate Record Type ==============//
    public PageReference AddEstimateLabLine(){    
        
        SVMXC__Service_Order_Line__c newestlabline = new SVMXC__Service_Order_Line__c();
        
        if(Userinfo.isMultiCurrencyOrganization()) //added 2 lines below by hh for defect closure #1630 on 12/01/2011
            newestlabline.put('CurrencyIsoCode',WOHeader.get('CurrencyIsoCode'));
        
        newestlabline.SVMXC__Service_Order__c = workorderId;
        newestlabline.SVMXC__Line_Type__c = 'Labor';
        newestlabline.RecordTypeId = EstRecType;
        newestlabline.SVMXC__Activity_Type__c = defActType;
        TempEstimateLabLineArray.add(newestlabline);         
        return null;
        
    } 
    
    //============ Method executes on click of Add Expenses Lines Button on Estimate Record Type ============//
    public PageReference AddEstimateExpLine(){    
        
        SVMXC__Service_Order_Line__c newestexpline = new SVMXC__Service_Order_Line__c();
        
        if(Userinfo.isMultiCurrencyOrganization()) //added 2 lines below by hh for defect closure #1630 on 12/01/2011
            newestexpline.put('CurrencyIsoCode',WOHeader.get('CurrencyIsoCode'));
        
        newestexpline.SVMXC__Service_Order__c = workorderId;
        newestexpline.SVMXC__Line_Type__c = 'Expenses';
        newestexpline.RecordTypeId = EstRecType;
        newestexpline.SVMXC__Expense_Type__c = defExpType;
        TempEstimateExpLineArray.add(newestexpline);         
        return null;
        
    } 
    
    //========================== Method executes on click of Usage delete button ============================//
    public PageReference DeleteLine(){    
        
        List<Integer> selectedPLines = new List<Integer>();
        List<Integer> selectedLLines = new List<Integer>();
        List<Integer> selectedELines = new List<Integer>();
        Integer i,j,k,count=0; 
        
        for (i=0;i<TempUsagePartsLineArray.size();i++)
        {
            if (TempUsagePartsLineArray.get(i).SVMXC__Select__c==true)
            {
                selectedPLines.add(i);
                count=count+1;
            }
        }
        selectedPLines.sort();          
        
        for (j=0;j<TempUsageLaborLineArray.size();j++)
        {
            if (TempUsageLaborLineArray.get(j).SVMXC__Select__c==true)
            {
                selectedLLines.add(j);
                count=count+1;
            }
        }
        selectedLLines.sort();          
        
        for (k=0;k<TempUsageExpLineArray.size();k++)
        {
            if (TempUsageExpLineArray.get(k).SVMXC__Select__c==true)
            {
                selectedELines.add(k);
                count=count+1;
            }
        }
        selectedELines.sort();          
        
        
        if(count == 0)
        {
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG026()));
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG026()));
        }
        else
        {
            for (i=selectedPLines.size()-1;i>=0;i--)
            {
                TempUsagePartsLineArray.remove(selectedPLines.get(i));
            }
            
            for (j=selectedLLines.size()-1;j>=0;j--)
            {
                TempUsageLaborLineArray.remove(selectedLLines.get(j));
            }
            
            for (k=selectedELines.size()-1;k>=0;k--)
            {
                TempUsageExpLineArray.remove(selectedELines.get(k));
            }
            
        }
        
        return null;
    }
    
    
    //========================== Method executes on click of Estimate delete button ==========================//
    public PageReference DeleteEstLine(){    
        
        List<Integer> selectedPLines = new List<Integer>();
        List<Integer> selectedLLines = new List<Integer>();
        List<Integer> selectedELines = new List<Integer>();
        Integer i,j,k,count=0; 
        
        for (i=0;i<TempEstimateLineArray.size();i++)
        {
            if (TempEstimateLineArray.get(i).SVMXC__Select__c==true)
            {
                selectedPLines.add(i);
                count=count+1;
            }
        }
        selectedPLines.sort();          
        
        for (j=0;j<TempEstimateLabLineArray.size();j++)
        {
            if (TempEstimateLabLineArray.get(j).SVMXC__Select__c==true)
            {
                selectedLLines.add(j);
                count=count+1;
            }
        }
        selectedLLines.sort();          
        
        for (k=0;k<TempEstimateExpLineArray.size();k++)
        {
            if (TempEstimateExpLineArray.get(k).SVMXC__Select__c==true)
            {
                selectedELines.add(k);
                count=count+1;
            }
        }
        selectedELines.sort();          
        
        
        if(count==0)
        {
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG026()));
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG026()));
        }
        else
        {
            for (i=selectedPLines.size()-1;i>=0;i--)
            {
                TempEstimateLineArray.remove(selectedPLines.get(i));
            }
            
            for (j=selectedLLines.size()-1;j>=0;j--)
            {
                TempEstimateLabLineArray.remove(selectedLLines.get(j));
            }
            
            for (k=selectedELines.size()-1;k>=0;k--)
            {
                TempEstimateExpLineArray.remove(selectedELines.get(k));
            }
        }
        
        return null;
    }
    
    
    //=============================== Method executes on click of Cancel button ==============================//
    public PageReference Cancel() {
        PageReference scPage = new PageReference('/' + workorderId);
        scPage.setRedirect(true);
        return scPage;   
    }
    
    //================= Method used to display/hide Labor pageBlock Table column headings ===================//
    public Boolean getDisplayLaborColumns() {    
        
        if (TempUsageLaborLineArray.size()==0)
            return false;
        else
            return true;        
    } 
    
    //================ Method used to display/hide Expenses pageBlock Table column headings ================//
    public Boolean getDisplayExpColumns() { 
        
        if (TempUsageExpLineArray.size()==0)
            return false; 
        else
            return true;        
    } 
    
    //=========== Method used to display/hide Estimate Labor pageBlock Table column headings ===============//
    public Boolean getDisplayEstLaborColumns() {    
        
        if (TempEstimateLabLineArray.size()==0)
            return false;
        else
            return true;        
    } 
    
    //========== Method used to display/hide Estimate Expenses pageBlock Table column headings =============//
    public Boolean getDisplayEstExpColumns() { 
        
        if (TempEstimateExpLineArray.size()==0)
            return false; 
        else
            return true;        
    } 
    
    
    //=============================== Method executes on click of Get Price button =========================//
    //updates unit price if product is present
    //updates product if serial number is present
    
    public PageReference UpdateLineRecord(){  
        
        for (SVMXC__Service_Order_Line__c line : TempUsagePartsLineArray)
        {
            if ((line.SVMXC__Product__c == null)&&(line.SVMXC__Serial_Number__c!=null))
                line.SVMXC__Product__c = SVMX_getProductIdFromIB(line.SVMXC__Serial_Number__c);
            
            if ((line.SVMXC__Product__c !=null)&&(line.SVMXC__Use_Price_From_Pricebook__c ==true))
            {
                PricebookEntry pbe = new PricebookEntry();
                if(Userinfo.isMultiCurrencyOrganization())                    
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBookUsg, string.valueOf(WOHeader.get('CurrencyIsoCode')), line.SVMXC__Product__c);
                else
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBookUsg, null, line.SVMXC__Product__c);                                                                            
                system.debug('asdf'+pbe);
                if (pbe !=null)
                {
                    line.SVMXC__Actual_Price2__c =pbe.UnitPrice;
                    if(Userinfo.isMultiCurrencyOrganization() && line.get('CurrencyIsoCode') != null ) //added 2 lines below by hh for defect closure #1630 on 12/01/2011
                        line.put('CurrencyIsoCode',WOHeader.get('CurrencyIsoCode'));
                } 
                //system.debug('asdf Price '+pbe.UnitPrice);                                   
            }
            
        }           
        return null;
    }
    
    public PageReference UpdateEstLineRecord(){  
        
        for (SVMXC__Service_Order_Line__c line : TempEstimateLineArray)
        {
            if ((line.SVMXC__Product__c == null)&&(line.SVMXC__Serial_Number__c!=null))
                line.SVMXC__Product__c = SVMX_getProductIdFromIB(line.SVMXC__Serial_Number__c);
            
            if ((line.SVMXC__Product__c !=null)&&(line.SVMXC__Use_Price_From_Pricebook__c ==true))
            {
                PricebookEntry pbe = new PricebookEntry();
                if(Userinfo.isMultiCurrencyOrganization())  
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBookEst, string.valueOf(WOHeader.get('CurrencyIsoCode')), line.SVMXC__Product__c);
                else
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBookEst, null, line.SVMXC__Product__c);                                                                 
                if (pbe !=null)
                    line.SVMXC__Estimated_Price2__c =pbe.UnitPrice;
                if(Userinfo.isMultiCurrencyOrganization() && line.get('CurrencyIsoCode') != null ) //added 2 lines below by hh for defect closure #1630 on 12/01/2011
                    line.put('CurrencyIsoCode',WOHeader.get('CurrencyIsoCode'));                             
            }
        }           
        return null;
    }
    
    public Id SVMX_getProductIdFromIB(Id IBId){     
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        try{
            IB = [Select SVMXC__Product__c From SVMXC__Installed_Product__c where Id = :IBId];
            return IB.SVMXC__Product__c;
            
        } catch (Exception e){ 
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
            return null;}
        
        return null;
    }  
    
    
    //======================================== Methods for Validations =======================================//
    
    public Boolean isValidData()
    {
        ValidRecords = true; 
        Boolean validLineQuantity= true;
        ErrorMessages.clear();          
        
        validLineQuantity = isValidUsageLines();          
        
        if(ValidLineQuantity==false)
        {                           
            ValidRecords = false;                                           
        }
        
        DisplayErrorsNWarnings();
        return ValidRecords;    
    }
    
    public Boolean isValidDataEst()
    {
        ValidRecords = true; 
        Boolean validLineQuantity= true;
        ErrorMessages.clear();          
        
        validLineQuantity = isValidEstLines();          
        
        if(ValidLineQuantity==false)
        {                           
            ValidRecords = false;                                           
        }
        
        DisplayErrorsNWarnings();
        return ValidRecords;    
    }
    
    
    public Boolean isValidUsageLines()
    {
        Boolean isValidLine = true;
        for(SVMXC__Service_Order_Line__c line1 :TempUsagePartsLineArray)
        {      
            if(line1.SVMXC__Actual_Quantity2__c == null)
            {  
                isValidLine =false;    
            }
        }
        
        for(SVMXC__Service_Order_Line__c line2 :TempUsageLaborLineArray)
        {      
            if(line2.SVMXC__Activity_Type__c == null && line2.SVMXC__Start_Date_and_Time__c == null && line2.SVMXC__End_Date_and_Time__c == null && line2.SVMXC__Estimated_Quantity2__c == null && line2.SVMXC__Estimated_Price2__c == null && line2.SVMXC__Discount__c == null && line2.SVMXC__Work_Description__c == null)
            {                       
                isValidLine =false;    
            }
        }
        
        for(SVMXC__Service_Order_Line__c line3 :TempUsageExpLineArray)
        {      
            if(line3.SVMXC__Expense_Type__c == null && line3.SVMXC__Estimated_Quantity2__c == null && line3.SVMXC__Estimated_Price2__c == null && line3.SVMXC__Discount__c == null && line3.SVMXC__Work_Description__c == null)
            {                       
                isValidLine =false;    
            }
        }
        
        return isValidLine;
    }
    
    public Boolean isValidEstLines()
    {
        Boolean isValidLine = true;
        
        for(SVMXC__Service_Order_Line__c line4 :TempEstimateLineArray)
        {      
            if(line4.SVMXC__Product__c == null && line4.SVMXC__Estimated_Quantity2__c == null && line4.SVMXC__Estimated_Price2__c == null && line4.SVMXC__Discount__c == null && line4.SVMXC__Work_Description__c == null)
            {                       
                isValidLine =false;    
            }
        }
        
        for(SVMXC__Service_Order_Line__c line5 :TempEstimateLabLineArray)
        {      
            if(line5.SVMXC__Activity_Type__c == null && line5.SVMXC__Start_Date_and_Time__c == null && line5.SVMXC__End_Date_and_Time__c == null && line5.SVMXC__Estimated_Quantity2__c == null && line5.SVMXC__Estimated_Price2__c == null && line5.SVMXC__Discount__c == null && line5.SVMXC__Work_Description__c == null)
            {                       
                isValidLine =false;    
            }
            //  if(line5.SVMXC__Estimated_Price2__c == null)
            //      {                       
            //          isValidLine =false;    
            //      }
        }
        
        for(SVMXC__Service_Order_Line__c line6 :TempEstimateExpLineArray)
        {      
            if(line6.SVMXC__Expense_Type__c == null && line6.SVMXC__Estimated_Quantity2__c == null && line6.SVMXC__Estimated_Price2__c == null && line6.SVMXC__Discount__c == null && line6.SVMXC__Work_Description__c == null)
            {                       
                isValidLine =false;    
            }
            // if(line6.SVMXC__Estimated_Price2__c == null)
            //     {                       
            //         isValidLine =false;    
            //     }
        }
        
        
        return isValidLine;
    }
    
    
    //=========================================== Translation ===============================================//
    
    // Call a Method in UTIL class to return Tags, Send SubModule ID for getting TAGS
    // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD005');
    
    // Ddefine getter method for each tag you have in VF page
    
    public String getTAG005(){ return System.Label.WORD005_TAG005;} //Cancel
    public String getTAG007(){ return System.Label.WORD005_TAG007;} //Error:
    public String getTAG008(){ return System.Label.WORD005_TAG008;} //No valid source record was not provided to create work order lines  
    public String getTAG009(){ return System.Label.WORD005_TAG009;} //An error occurred when trying to obtain configuration settings for this screen. Please contact your ServiceMax administrator immediately. 
    public String getTAG010(){ return System.Label.WORD005_TAG010;} //Create Usage Lines
    public String getTAG011(){ return System.Label.WORD005_TAG011;} //Create Usage Lines for Work Order
    public String getTAG012(){ return System.Label.WORD005_TAG012;} //Create Usage Lines Help
    public String getTAG013(){ return System.Label.WORD005_TAG013;} //Add Part Line
    public String getTAG014(){ return System.Label.WORD005_TAG014;} //Add Labor Line
    public String getTAG015(){ return System.Label.WORD005_TAG015;} //Add Expenses Line
    public String getTAG016(){ return System.Label.WORD005_TAG016;} //Get Price
    public String getTAG017(){ return System.Label.WORD005_TAG017;} //Delete Lines
    public String getTAG018(){ return System.Label.WORD005_TAG018;} //Save
    public String getTAG019(){ return System.Label.WORD005_TAG019;} //Part Lines
    public String getTAG020(){ return System.Label.WORD005_TAG020;} //Labor Lines
    public String getTAG021(){ return System.Label.WORD005_TAG021;} //Expense Lines
    public String getTAG022(){ return System.Label.WORD005_TAG022;} //Create Estimate Lines for Work Order
    public String getTAG023(){ return System.Label.WORD005_TAG023;} //Create Estimate Lines Help
    public String getTAG024(){ return System.Label.WORD005_TAG024;} //An error occurred when processing record types. Please contact your ServiceMax administrator immediately
    public String getTAG025(){ return System.Label.WORD005_TAG025;} //The price book configured for Work Order Usage lines was not found. Please make sure the price book name is valid in ServiceMax setup
    public String getTAG026(){ return System.Label.WORD005_TAG026;} //Please select one or more records from the list first.
    public String getTAG027(){ return System.Label.WORD005_TAG027;} //Please enter line quantity
    public String getTAG028(){ return System.Label.WORD005_TAG028;} //Use Pricebook
    public String getTAG029(){ return System.Label.WORD005_TAG029;} //Unit Price
    public String getTAG037(){ return System.Label.WORD005_TAG037;} //The price book configured for Work Order Estimate lines was not found. Please make sure the price book name is valid in ServiceMax setup
    public String getTAG039(){ return System.Label.WORD005_TAG039;} //Processing...
    public String getTAG040(){ return System.Label.WORD005_TAG040;} //Please enter valid Part line
    public String getTAG041(){ return System.Label.WORD005_TAG041;} //Please enter valid Labor line
    public String getTAG042(){ return System.Label.WORD005_TAG042;} //Please enter valid Expenses line
    public String getHLPURL(){ return System.Label.WORD005_HLPURL;}
    
}