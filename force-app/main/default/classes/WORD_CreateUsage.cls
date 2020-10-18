/* Security Scanned */
public  with sharing class WORD_CreateUsage{
    // ------------------------NPS Related changes  ---------
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

    // -------------------------------
    



    //========================================= URL Parameters =============================================//
    String WOId = System.currentPageReference().getParameters().get('id'); 


    //========================================= Global Declarations ========================================//
    Boolean CheckAllLines=false;
    String WDetailsSobjectType = 'SVMXC__Service_Order_Line__c';
    String Est = 'Estimate';
    Id EstRecType = getEstRecordTypes().Id;
    String Usage = 'Usage/Consumption';
    Id UsgRecType = getUsgRecordTypes().Id;
    Boolean ShowValidData = true;
    SVMXC__Service_Order__c WOHeader; 
    

    //================= Global Variables (with get & set methods) to manage display of Errors ===============//
    List<String> ErrorMessages = new  List<String> ();
    Boolean ValidRecords = true;
  
    public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
    public List<String> getErrorsList() {    return ErrorMessages; }  

    public Boolean DisplayBlockLevelMessage = false;
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }

    Pricebook2 priceBook = new Pricebook2();

    
    //================================= Common Utility setting declaration =================================//
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    
    
    //Create instance of UTIL Class
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();

    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> ();


    //====================================== List to store new lines =======================================//
    //====== Part lines ====// 
    List<SVMXC__Service_Order_Line__c> PartsLineDetailArray = new List<SVMXC__Service_Order_Line__c> ();

    public List<SVMXC__Service_Order_Line__c> getNewWORDPartLine() {return PartsLineDetailArray; }
    public void setNewWORDPartLine(List<SVMXC__Service_Order_Line__c> objArray1) {PartsLineDetailArray = objArray1;}


    //======  Labor lines ====//
    List<SVMXC__Service_Order_Line__c> LaborLineDetailArray = new List<SVMXC__Service_Order_Line__c> ();

    public List<SVMXC__Service_Order_Line__c> getNewWORDLaborLine() {return LaborLineDetailArray; }
    public void setNewWORDLaborLine(List<SVMXC__Service_Order_Line__c> objArray2) {LaborLineDetailArray = objArray2;}


     //=====  Expenses lines ====// 
    List<SVMXC__Service_Order_Line__c> ExpLineDetailArray = new List<SVMXC__Service_Order_Line__c> ();

    public List<SVMXC__Service_Order_Line__c> getNewWORDExpLine() {return ExpLineDetailArray; }
    public void setNewWORDExpLine(List<SVMXC__Service_Order_Line__c> objArray3) {ExpLineDetailArray = objArray3;}


  
    //======================================== Setting Definition =========================================//
    public Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('WORD005');
    String UsageFldMapSetng = AllSubModuleSettings.get('SET012'); //Setting for Estimate to Usage field mapping
    String Setng_usePriceFromPriceBook = AllSubModuleSettings.get('SET003'); //setting for pricebook flag
    String Setng_UsagePriceBook = AllSubModuleSettings.get('SET004'); //setting to get usage pricebook
    String setng_DefaultConsumptionLoc=AllSubModuleSettings.get('SET014');


    //======================================= Getter & Setter =============================================//
    public Boolean getCheckAllLines(){return CheckAllLines;}
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}

    public Boolean getShowValidData(){ return ShowValidData;} 
    public void setShowValidData(Boolean svd) {ShowValidData=svd;}
    public Boolean btnisdisabled = false; 
    public Boolean getbtnisdisabled(){return btnisdisabled;} 
    
  


    //============================== Method to Display Errors/Warnings ======================================// 
    public void DisplayErrorsNWarnings(){
       
        if( ErrorMessages.size()>0)
            {
                ValidRecords = false;  
                DisplayBlockLevelMessage = false; 
                for (String msg : ErrorMessages)
                    {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG007(),msg)) ;  
                    }
            }   
    }


    //======================================= Constructor =================================================//
     public String defActType;
    public String defExpType;
    public WORD_CreateUsage(ApexPages.StandardController controller)
    {
        WOHeader = new SVMXC__Service_Order__c(); 
        WOHeader = getWOrderHeader(WOID);

        if (WOId == null)
        {
            ShowValidData = false;
            AddToErrorsList(getTAG008());       //Source Object Work Order Id not found
        }
        defActType = utils.SVMX_getDefaultPicklistValue('SVMXC__Service_Order_Line__c', 'SVMXC__Activity_Type__c');
        defExpType = utils.SVMX_getDefaultPicklistValue('SVMXC__Service_Order_Line__c', 'SVMXC__Expense_Type__c');
     
        ValidateAllSettings();   
        DisplayErrorsNWarnings();
        getWOEstimateLine(); 
    }
 

    //===================================== Validation for all Settings ===================================//
     public void ValidateAllSettings(){
         
         //if(UsageFldMapSetng.size()==0 || UsageFldMapSetng == null)
         if(UsageFldMapSetng == null)
         {
            ShowValidData = false;
            AddToErrorsList(getTAG009()); //Settings not available for the SubModule: Create Usage          
         }
 
         if (Setng_usePriceFromPriceBook == null)
            AddToErrorsList(getTAG009());  //Setting not available for the flag usePriceFromPriceBook
            
         if ((Setng_usePriceFromPriceBook!=null)&& (Setng_usePriceFromPriceBook.toUpperCase() !='FALSE'))
         {   
            if (Setng_UsagePriceBook == null)
                AddToErrorsList(getTAG009());  //Setting not available for Work Detail Usage/Consumption PriceBook           
            else
                {
                    priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(Setng_UsagePriceBook);       
                    if(priceBook == null) 
                    AddToErrorsList(getTAG025());    //PriceBook not found for Work Detail Usage/Consumption
                }
         } 
    }

    
    //============================== Method to retrive header (Work Order) object =============================//
    public SVMXC__Service_Order__c getWORDHeader() {return WOHeader; } 

    public SVMXC__Service_Order__c getWOrderHeader(String WOID) {
    try{
        String SOQLDetail;
        if(Userinfo.isMultiCurrencyOrganization())
            {
                SOQLDetail = ' SELECT Id, Name, CurrencyIsoCode From SVMXC__Service_Order__c where Id=\''+WOID+'\'';
                WOHeader = Database.query(SOQLDetail);
            }
        } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007() ,e.getMessage()));}

        return WOHeader;
    }


    //=============================== Method to retrive Estimate Record Type ==============================//
    public RecordType getEstRecordTypes(){
        
        RecordType erTypes;

        try{
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+WDetailsSobjectType+'\' and Name=\''+Est+'\' ';
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            erTypes = Database.query(SOQL);
            
           } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007() ,e.getMessage()));}
        return erTypes;
    }


    //========================== Method to retrive Usage/Consumption Record Type ==========================//
    public RecordType getUsgRecordTypes(){
        
        RecordType erUTypes;

        try{
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+WDetailsSobjectType+'\' and Name=\''+Usage+'\' ';
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            erUTypes = Database.query(SOQL);
            
           } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007() ,e.getMessage()));}
        return erUTypes;
    }


    //========================== Method to retrive Received Location from Work Detail =======================//
    public SVMXC__Service_Order_Line__c getSVMX_WorkDetails() {
    
        SVMXC__Service_Order_Line__c SVMX_WorkDetails = new SVMXC__Service_Order_Line__c(); 

        String SOQLDetail = ' SELECT Id, Name, Received_Location__c From SVMXC__Service_Order_Line__c LIMIT 1';

        SVMX_WorkDetails = Database.query(SOQLDetail); 
        return SVMX_WorkDetails;           
    } 


    
    //============================= Method to retrive Work Detail Estimate Lines ===========================//
    
    public void getWOEstimateLine() {

            List<SVMXC__Service_Order_Line__c> EstimateLineDetail;

        try{
            String fieldNames;
            String SOQLDetail;
    
            Schema.DescribeSObjectResult dsoResult = SVMXC__Service_Order_Line__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Order_Line__c.fields.getMap();
    
            //build a list of all fieldnames for the object
            List<String> fieldList = utils.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utils.SVMX_getFieldNamesFromList(fieldList);            
            
            SOQLDetail = ' SELECT '+fieldNames+' FROM SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c=\''+WOId+'\' and RecordTypeId=\''+EstRecType+'\' ';        
    
            EstimateLineDetail = Database.query(SOQLDetail); 

            fieldMapSetting = settings.SVMX_getFieldMapping(UsageFldMapSetng);
        
            for ( SVMXC__Service_Order_Line__c EstPLines : EstimateLineDetail)
                
                {
                 SVMXC__Service_Order_Line__c newLLine = new SVMXC__Service_Order_Line__c();
                 newLLine.SVMXC__Service_Order__c = WOId;
                 newLLine.RecordTypeId = UsgRecType;
            
                for(SVMXC__ServiceMax_Config_Data__c LinePfld:fieldMapSetting)

                    {
                     String targetLineFieldName = LinePfld.SVMXC__Target_Field_Name__c;
                     String sourceLineFieldName = LinePfld.SVMXC__Source_Field_Name__c;

                     //Schema.DescribeFieldResult souLineFldVal = EstPLines.get(sourceLineFieldName);
                     Object souLineFldVal = EstPLines.get(sourceLineFieldName);
                    
                     if(souLineFldVal != null)
                        {
                            newLLine.put(targetLineFieldName, souLineFldVal);
                            newLLine.SVMXC__Is_Billable__c = true;
                        }  
                    } 

                    
                if(EstPLines.SVMXC__Line_Type__c=='Parts') 
                      {
                        
                        PartsLineDetailArray.add(newLLine);
                      }  

                if(EstPLines.SVMXC__Line_Type__c=='Labor')
                      {
                          if(newLLine.SVMXC__Activity_Type__c == null) newLLine.SVMXC__Activity_Type__c = defActType ;
                          LaborLineDetailArray.add(newLLine);
                      
                      }  

                if(EstPLines.SVMXC__Line_Type__c=='Expenses')
                      {
                       if(newLLine.SVMXC__Expense_Type__c == null) newLLine.SVMXC__Expense_Type__c = defExpType;
                      
                      ExpLineDetailArray.add(newLLine);
                      }  
                }      

            } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007() ,e.getMessage()));}  
    }  
    

    //================================ Method executes on click of Save Button ==============================//
    public PageReference newTargetObj() {        
        list<SVMXC__Service_Order_Line__c> LstSavePartsLine = new list<SVMXC__Service_Order_Line__c>();
        list<SVMXC__Service_Order_Line__c> LstSaveLaborLine = new list<SVMXC__Service_Order_Line__c>();
        list<SVMXC__Service_Order_Line__c> LstSaveExpLine = new list<SVMXC__Service_Order_Line__c>();       
        if(isValidData()==true)
        {
            for(SVMXC__Service_Order_Line__c line :PartsLineDetailArray)
            {
                line.SVMXC__Line_Type__c='Parts';
                line.RecordTypeId = UsgRecType;
                List<SVMXC__Service_Group_Members__c> Technician = new List<SVMXC__Service_Group_Members__c>();
                if (setng_DefaultConsumptionLoc.toUpperCase() =='TRUE')
                 {
                      String SOQLDetailx='Select s.SVMXC__Salesforce_User__c, s.SVMXC__Inventory_Location__c From SVMXC__Service_Group_Members__c s where s.SVMXC__Salesforce_User__c=\''+UserInfo.getUserId()+'\' Limit 1';
                      Technician= Database.query(SOQLDetailx); 
                  }
                  if (Technician.size() >0 && line.SVMXC__Consumed_From_Location__c == null)
                    {
                       line.SVMXC__Consumed_From_Location__c=Technician[0].SVMXC__Inventory_Location__c;
                    }
                LstSavePartsLine.add(line);             
            }
            for(SVMXC__Service_Order_Line__c line :LaborLineDetailArray)
            {
                line.SVMXC__Line_Type__c='Labor';
                line.RecordTypeId = UsgRecType;
                LstSaveLaborLine.add(line);             
            }
            for(SVMXC__Service_Order_Line__c line :ExpLineDetailArray)
            {
                line.SVMXC__Line_Type__c='Expenses';
                line.RecordTypeId = UsgRecType;
                LstSaveExpLine.add(line);               
            }
            
            if(LstSavePartsLine.size()>0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(LstSavePartsLine, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                     upsert LstSavePartsLine;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
            }
               
            if(LstSaveLaborLine.size()>0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(LstSaveLaborLine, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                     upsert LstSaveLaborLine;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
            }
               
            if(LstSaveExpLine.size()>0){
                 if(COMM_SecurityUtils.getInstance().verifyFieldAccess(LstSaveExpLine, COMM_SecurityUtils.Access.Upsertable)){
                     //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    upsert LstSaveExpLine;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
            }
                
                
            PageReference newSQPage = new PageReference('/' + WOId);
            return newSQPage;
        }
        else
        {
            displayErrors();
        }
        return null;
    }

    public void displayErrors(){
        
        for(SVMXC__Service_Order_Line__c line1 :PartsLineDetailArray)
            {      
                if(line1.SVMXC__Product__c == null && line1.SVMXC__Serial_Number__c == null && line1.Actual_Quantity2__c == null && line1.Actual_Price2__c == null && line1.Discount__c == null && line1.Work_Description__c == null)
                    {                       
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG040()));
                    }
            }

        for(SVMXC__Service_Order_Line__c line2 :LaborLineDetailArray)
            {      
                if(line2.Activity_Type__c == null && line2.Start_Date_and_Time__c == null && line2.End_Date_and_Time__c == null && line2.Actual_Quantity2__c == null && line2.Actual_Price2__c == null && line2.Discount__c == null && line2.Work_Description__c == null)
                    {                       
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG041()));
                    }
            }

        for(SVMXC__Service_Order_Line__c line3 :ExpLineDetailArray)
            {      
                if(line3.Expense_Type__c == null && line3.Actual_Quantity2__c == null && line3.Actual_Price2__c == null && line3.Discount__c == null && line3.Work_Description__c == null)
                    {                       
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG042()));
                    }
            }
    }

    //========================================= Method for Validations =======================================//
    public Boolean isValidData()
    {
        ValidRecords = true; 
        Boolean validLine= true;
        ErrorMessages.clear();          

        validLine = isValidUsageLines();          
           
        if(ValidLine==false)
            {                           
                ValidRecords = false;                                           
            }

        DisplayErrorsNWarnings();
        return ValidRecords;    
    }

     public Boolean isValidUsageLines()
    {
       Boolean isValidLine = true;

       for(SVMXC__Service_Order_Line__c line1 :PartsLineDetailArray)
            {      
                if(line1.SVMXC__Product__c == null && line1.SVMXC__Serial_Number__c == null && line1.Actual_Quantity2__c == null && line1.Actual_Price2__c == null && line1.Discount__c == null && line1.Work_Description__c == null)
                    {                       
                        isValidLine =false; 
                    }
            }

       for(SVMXC__Service_Order_Line__c line2 :LaborLineDetailArray)
            {      
                if(line2.Activity_Type__c == null && line2.Start_Date_and_Time__c == null && line2.End_Date_and_Time__c == null && line2.Actual_Quantity2__c == null && line2.Actual_Price2__c == null && line2.Discount__c == null && line2.Work_Description__c == null)
                    {                       
                        isValidLine =false; 
                    }
            }

        for(SVMXC__Service_Order_Line__c line3 :ExpLineDetailArray)
            {      
                if(line3.Expense_Type__c == null && line3.Actual_Quantity2__c == null && line3.Actual_Price2__c == null && line3.Discount__c == null && line3.Work_Description__c == null)
                    {                       
                        isValidLine =false;
                    }
            }

        return isValidLine;
    }

    //============================= Method executes on click of delete button ===============================//
     public PageReference DeleteLine(){    
       
        List<Integer> selectedPLines = new List<Integer>();
        List<Integer> selectedLLines = new List<Integer>();
        List<Integer> selectedELines = new List<Integer>();
        Integer i,j,k,count=0; 

        for (i=0;i<PartsLineDetailArray.size();i++)
            {
            if (PartsLineDetailArray.get(i).SVMXC__Select__c==true)
                {
                    selectedPLines.add(i);
                    count=count+1;
                }
            }
        selectedPLines.sort();          
       
        for (j=0;j<LaborLineDetailArray.size();j++)
            {
            if (LaborLineDetailArray.get(j).SVMXC__Select__c==true)
                {
                    selectedLLines.add(j);
                    count=count+1;
                }
            }
        selectedLLines.sort();          
        
        for (k=0;k<ExpLineDetailArray.size();k++)
            {
            if (ExpLineDetailArray.get(k).SVMXC__Select__c==true)
                {
                    selectedELines.add(k);
                    count=count+1;
                }
            }
        selectedELines.sort();          
      

        if(count==0)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG026()));
        }
        else
        {
            for (i=selectedPLines.size()-1;i>=0;i--)
                {PartsLineDetailArray.remove(selectedPLines.get(i));}

            for (j=selectedLLines.size()-1;j>=0;j--)
                {LaborLineDetailArray.remove(selectedLLines.get(j));}

            for (k=selectedELines.size()-1;k>=0;k--)
                {ExpLineDetailArray.remove(selectedELines.get(k));}
        }
        
        return null;
    }

    
    //========================== Method executes on click of Add Part Lines Button ==========================//
     public PageReference AddPartsLine(){    
     
        SVMXC__Service_Order_Line__c newpartline = new SVMXC__Service_Order_Line__c();

        if (Setng_usePriceFromPriceBook.toUpperCase() =='TRUE')
            newpartline.SVMXC__Use_Price_From_Pricebook__c=  true;                
        else
            newpartline.SVMXC__Use_Price_From_Pricebook__c=  false;    
        
        newpartline.SVMXC__Is_Billable__c = true;
        newpartline.SVMXC__Service_Order__c = WOId; 
        newpartline.SVMXC__Line_Type__c = 'Parts';
        newpartline.RecordTypeId = EstRecType;

        PartsLineDetailArray.add(newpartline);         
        return null;

        }    

    //========================== Method executes on click of Add Labor Lines Button ==========================//
     public PageReference AddLaborLine(){    
     
        SVMXC__Service_Order_Line__c newlaborline = new SVMXC__Service_Order_Line__c();

        newlaborline.SVMXC__Service_Order__c = WOId; 
        newlaborline.SVMXC__Line_Type__c = 'Labor';
        newlaborline.SVMXC__Is_Billable__c = true;
        newlaborline.RecordTypeId = EstRecType;
        newlaborline.SVMXC__Activity_Type__c =defActType;
        LaborLineDetailArray.add(newlaborline);         
        return null;

        } 
    
    //========================= Method executes on click of Add Expenses Lines Button ========================//
     public PageReference AddExpLine(){    
     
        SVMXC__Service_Order_Line__c newexpline = new SVMXC__Service_Order_Line__c();

        newexpline.SVMXC__Service_Order__c = WOId;
        newexpline.SVMXC__Line_Type__c = 'Expenses';
        newexpline.SVMXC__Is_Billable__c = true;
        newexpline.RecordTypeId = EstRecType;
        newexpline.SVMXC__Expense_Type__c = defExpType;

        ExpLineDetailArray.add(newexpline);         
        return null;

        } 


     //============================= Method executes on click of Cancel Button =============================//
     public PageReference Cancel() {

        PageReference scPage = new PageReference('/' + WOId);
        scPage.setRedirect(true);
        return scPage;   
    }


    //================= Method used to display/hide Labor pageBlock Table column headings ===================//
     public Boolean getDisplayLaborColumns() {    
     
        if (LaborLineDetailArray.size()==0)
            return false;
        else
            return true;        
    } 


    //================ Method used to display/hide Expenses pageBlock Table column headings ================//
    public Boolean getDisplayExpColumns() { 
    
        if (ExpLineDetailArray.size()==0)
            return false; 
        else
            return true;        
    } 


    //=============================== Method executes on click of Get Price button =========================//
    //updates unit price if product is present
    //updates product if serial number is present

    public PageReference UpdateLineRecord(){        
        
        for (SVMXC__Service_Order_Line__c line : PartsLineDetailArray)
        {
            if ((line.Product__c == null)&&(line.Serial_Number__c!=null))
                line.Product__c = SVMX_getProductIdFromIB(line.Serial_Number__c);
            
            if ((line.Product__c !=null)&&(line.SVMXC__Use_Price_From_Pricebook__c ==true))
            {
                PricebookEntry pbe = new PricebookEntry();
                if(Userinfo.isMultiCurrencyOrganization())                    
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, string.valueOf(WOHeader.get('CurrencyIsoCode')), line.Product__c);
                else
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, null, line.Product__c);
                
                if (pbe !=null)
                    line.SVMXC__Actual_Price2__c =pbe.UnitPrice;                                
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
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));
            return null;}  
    }    


    //=========================================== Translation ===============================================//

     // Call a Method in UTIL class to return Tags, Send SubModule ID for getting TAGS
       //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD005'); 

     // Ddefine getter method for each tag you have in VF page
    public String getTAG005(){ return system.label.WORD005_TAG005;} //Cancel
    public String getTAG007(){ return system.label.WORD005_TAG007;} //Error:
    public String getTAG008(){ return system.label.WORD005_TAG008;} //No valid source record was not provided to create work order lines
    public String getTAG009(){ return system.label.WORD005_TAG009;} //Settings not available for the SubModule: Create Work Order Lines
    public String getTAG011(){ return system.label.WORD005_TAG011;} //Create Usage Lines for Work Order
    public String getTAG012(){ return system.label.WORD005_TAG012;} //Create Usage Lines Help
    public String getTAG013(){ return system.label.WORD005_TAG013;} //Add Parts Line
    public String getTAG014(){ return system.label.WORD005_TAG014;} //Add Labor Line
    public String getTAG015(){ return system.label.WORD005_TAG015;} //Add Expenses Line
    public String getTAG016(){ return system.label.WORD005_TAG016;} //Get Price
    public String getTAG017(){ return system.label.WORD005_TAG017;} //Delete Lines
    public String getTAG018(){ return system.label.WORD005_TAG018;} //Save
    public String getTAG019(){ return system.label.WORD005_TAG019;} //Part Lines 
    public String getTAG020(){ return system.label.WORD005_TAG020;} //Labor Lines
    public String getTAG021(){ return system.label.WORD005_TAG021;} //Expense Lines
    public String getTAG025(){ return system.label.WORD005_TAG025;} //The price book configured for Work Order Usage lines was not found. Please make sure the price book name is valid in ServiceMax setup
    public String getTAG026(){ return system.label.WORD005_TAG026;} //Please select one or more records from the list first.
    public String getTAG028(){ return system.label.WORD005_TAG028;} //Use Pricebook
    public String getTAG029(){ return system.label.WORD005_TAG029;} //Unit Price
    public String getTAG038(){ return system.label.WORD005_TAG038;} //Create Usage From Estimates
    public String getTAG039(){ return system.label.WORD005_TAG039;} //Processing... 
    public String getTAG040(){ return system.label.WORD005_TAG040;} //Please enter valid Part line
    public String getTAG041(){ return system.label.WORD005_TAG041;} //Please enter valid Labor line
    public String getTAG042(){ return system.label.WORD005_TAG042;} //Please enter valid Expenses line
    public String getHLPURL(){ return system.label.WORD005_HLPURL;}
}