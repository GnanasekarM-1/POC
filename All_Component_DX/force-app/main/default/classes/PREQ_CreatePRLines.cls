/* Security Scanned */
public  with sharing class PREQ_CreatePRLines 
{
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
    
    public PREQ_CreatePRLines(ApexPages.StandardController controller) {
        if (prID ==null)     AddToErrorsList(getTAG013());//Source Object Record Id not found
        
        AllSubModuleSettings= settings.SVMX_getSettingList('PREQ002');        
        ValidateAllSettings();  
        
        DisplayErrorsNWarnings();
        SourcePR = getSourcePRData();
        
        if (ValidRecords == true)   
        {
            ExistingPRLines = getExistingLines();
            //Automatically add an empty line by default if there are no existing records             
            if(ExistingPRLines.size() == 0)
            {
                AddPartsRequestLine();
            }
            for (SVMXC__Parts_Request_Line__c line :  ExistingPRLines)
            {
                line.SVMXC__Select__c = false;
                TempPRDetailArray .add(line);   
            }
        }
    }
    
    
    
    
    
    
    String prID = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('id'));
    
    
    SVMXC.COMM_Utils utilities = new SVMXC.COMM_Utils();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> AllSubModuleSettings;
    
    String Setng_usePriceFromPriceBook ;
    String Setng_PartsRequestPriceBook ;
    String helpURL;
    
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags(); 
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('PREQ002');
    
    Pricebook2 priceBook = new Pricebook2();
    
    public void ValidateAllSettings()
    {   
        //Validte the settings    
        Setng_usePriceFromPriceBook =AllSubModuleSettings.get('SET002');
        if (Setng_usePriceFromPriceBook==null)           AddToErrorsList(getTag016()); //Setting not available for the flag usePriceFromPriceBook
        
        
        Setng_PartsRequestPriceBook = AllSubModuleSettings.get('SET003');
        
        if (Setng_PartsRequestPriceBook == null)            AddToErrorsList(getTag016()); //Setting not available for Parts Request PriceBook 
        else {
            priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(Setng_PartsRequestPriceBook);
            if(priceBook==null)
                AddToErrorsList(getTag018());//PriceBook not found
        }
    }
    
    Boolean CheckAllLines=false;    
    public Boolean getCheckAllLines() {return CheckAllLines;  }
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
    
    
    
    //Objects & method to populate the source object data with get method        
    SVMXC__Parts_Request__c SourcePR = new SVMXC__Parts_Request__c(); 
    public SVMXC__Parts_Request__c getSourcePR(){ return SourcePR; }
    
    public SVMXC__Parts_Request__c getSourcePRData()
    { 
        SVMXC__Parts_Request__c PR = new SVMXC__Parts_Request__c();
        
        String fieldNames;
        String SOQLHeader;          
        try
        {
            Schema.DescribeSObjectResult dsoResult = SVMXC__Parts_Request__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Parts_Request__c.fields.getMap();
            
            //build a list of all fieldnames for the object
            List<String> fieldList = utilities.SVMX_getFieldList(fieldMap,true); 
            
            /**********Duplicate check*********************/
            SVMXC.COMM_Utils_V2 commutils = new SVMXC.COMM_Utils_V2();
            fieldList = commutils.checkDuplicateFields(fieldList,'SVMXC__Parts_Request__c');
            /***********************************************/         
            fieldNames = utilities.SVMX_getFieldNamesFromList(fieldList);            
            
            SOQLHeader = 'SELECT '+fieldNames+' FROM SVMXC__Parts_Request__c where Id =\''+prID+'\'';        
            PR = Database.query(SOQLHeader);     
            
            
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021() ,e.getMessage()));}
        return PR; 
    }
    
    //List to store the existing lines of Parts Request
    
    List<SVMXC__Parts_Request_Line__c> ExistingPRLines= new List<SVMXC__Parts_Request_Line__c> ();
    
    List<SVMXC__Parts_Request_Line__c> TempPRDetailArray = new List<SVMXC__Parts_Request_Line__c> (); 
    
    public List<SVMXC__Parts_Request_Line__c> getNewPRLine() {return TempPRDetailArray; }
    public void setNewPRLine(List<SVMXC__Parts_Request_Line__c> objArray) {TempPRDetailArray = objArray;}
    
    
    //Global Variables (with get & set methods) to manage display of Warnings and Errors
    List<String> ErrorMessages = new  List<String> ();
    List<String> WarningMessages = new  List<String> (); 
    Boolean ValidRecords = true;
    Boolean WarningDisplayed=false; 
    
    Boolean showWarnings=false; 
    public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
    public List<String> getErrorsList() {    return ErrorMessages; }  
    
    public void AddToWarningsList(String msg) { WarningMessages.add(msg);}
    public List<String> getWarningsList() { return WarningMessages; }                     
    
    public Boolean getshowWarnings() 
    {
        if(ErrorMessages.size()==0 && WarningMessages.size()>0)
            showWarnings=true;
        else
            showWarnings=false;
        return showWarnings;  
    }
    
    public void setshowWarnings(Boolean sw){showWarnings=sw;}
    public Boolean DisplayBlockLevelMessage = false;
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }
    
    //Method to Display Errors/Warnings
    public void DisplayErrorsNWarnings()
    {
        if( ErrorMessages.size()>0)
        {
            ValidRecords = false;  
            DisplayBlockLevelMessage = false; 
            for (String msg : ErrorMessages)
            {
                //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag021(),msg));
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,msg));
            }
        }   
        else if( WarningMessages.size()>0)
        {
            for (String msg : WarningMessages)
            {
                //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning,getTag021(),msg));
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning,msg));
            }
        }   
    }
    
    
    
    //Method to return the existing lines from Source Parts Request
    public List<SVMXC__Parts_Request_Line__c> getExistingLines(){
        List<SVMXC__Parts_Request_Line__c> PRLines;
        List<SVMXC__Parts_Request_Line__c> PRLineRecords = new List<SVMXC__Parts_Request_Line__c>();
        
        String fieldNames;
        String SOQLDetail;          
        try
        {
            Schema.DescribeSObjectResult dsoResult = SVMXC__Parts_Request_Line__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Parts_Request_Line__c.fields.getMap();
            
            //build a list of all fieldnames for the object
            List<String> fieldList = utilities.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utilities.SVMX_getFieldNamesFromList(fieldList);            
            
            fieldNames +=' , SVMXC__Product__r.Name, SVMXC__Product__r.ProductCode';            
            
            SOQLDetail = '  SELECT '+fieldNames+' FROM SVMXC__Parts_Request_Line__c where SVMXC__Parts_Request__c =\''+prID+'\'  ';        
            PRLines = Database.query(SOQLDetail);     
            
            for ( SVMXC__Parts_Request_Line__c PRLine : PRLines)
            {
                PRLineRecords.add(PRLine);
            }                
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag021(),e.getMessage()));}
        return PRLineRecords;   
        
    }
    
    //Method used to display/hide pageBlock Table column headings depending upon the number of lines available    
    public Boolean getDisplayTableColumns() 
    {       
        if (TempPRDetailArray.size()==0)
        {
            CheckAllLines=false;   
            return false;
        }
        else
            return true;        
    } 
    //Methods for Validations
    
    public Boolean isValidData()
    {
        ValidRecords = true; 
        Boolean validLine= true;
        ErrorMessages.clear();          
        
        validLine = isvalidLine();          
        
        if(validLine==false)
        {                           
            //ErrorMessages.add(getTag014()); 
            ValidRecords = false;                                           
        }
        
        DisplayErrorsNWarnings();
        return ValidRecords;    
    }        
    public Boolean isvalidLine()
    {
        Boolean isValid=true;
        for(SVMXC__Parts_Request_Line__c ListObj :TempPRDetailArray)
        {      
            if(ListObj.SVMXC__Product__c==null)
            {
                ListObj.SVMXC__Product__c.addError(getTAG020());//Please Enter Product
                isValid=false;
                //break;
            }
            if( (ListObj.SVMXC__Quantity_Required2__c == null || ListObj.SVMXC__Quantity_Required2__c <0))// && ListObj.SVMXC__Select__c==true)
            {  
                ListObj.SVMXC__Quantity_Required2__c.addError(getTag014());                                         
                
                isValid =false;                      
                //break;
            }
            //Make the 'Date Required' optional on the VF page
            /* if(ListObj.SVMXC__Date_Required__c==null)
{
ListObj.SVMXC__Date_Required__c.addError(getTAG019());
isValid=false;
// break;
}*/
        }
        return isValid;
    }
    
    
    //Methods for commandButtons
    public PageReference ClearWarnings()
    {
        
        WarningDisplayed=true;
        WarningMessages.clear();
        return UpdateLines();
    }
    
    public PageReference UpdateLines() 
    {
        if(isValidData()==true && getshowWarnings()==false)
        {
            try{
                for (SVMXC__Parts_Request_Line__c PreEditLine : ExistingPRLines)
                {
                    Boolean OldLineExist = false;
                    
                    for (SVMXC__Parts_Request_Line__c PostEditLine : TempPRDetailArray)
                    {
                        if (PreEditLine.Id == PostEditLine.Id) {OldLineExist = true;break;}
                    }               
                    if(OldLineExist !=true) {
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Parts_Request_Line__c' ) ) {
                            //SDL-SVMX-DELETE-FLS-ENFORCED
                            delete PreEditLine;                     
                        } else {
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                            return null;
                        }
                    }
                }
                //upsert TempPRDetailArray;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempPRDetailArray, COMM_SecurityUtils.Access.Upsertable ) ) {
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    upsert TempPRDetailArray;
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                PageReference prPage = new PageReference('/' + prID);
                prPage.setRedirect(true);
                return prPage; 
            } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag021(),e.getMessage()));}             
        }
        
        return null;    
    }
    
    public PageReference Cancel() 
    {
        PageReference prPage = new PageReference('/' + prID);
        prPage.setRedirect(true);
        return prPage;             
    }
    
    public PageReference GettPrice()
    {
        
        for(SVMXC__Parts_Request_Line__c line:TempPRDetailArray)
        {
            if((line.SVMXC__Product__c !=null)&&(line.SVMXC__Use_Price_From_Pricebook__c ==true))
            {
                PricebookEntry pbe = new PricebookEntry();
                if(Userinfo.isMultiCurrencyOrganization())
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook,  string.valueOf(SourcePR.get('CurrencyIsoCode')), line.SVMXC__Product__c);
                else
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, null , line.SVMXC__Product__c);                                                        
                if (pbe !=null)
                    line.Unit_Price2__c = pbe.UnitPrice;
            }
            
        }
        return null;
    }
    
    public Id SVMX_getProductIdFromIB(Id IBId)
    {     
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        try
        {
            IB = [Select SVMXC__Product__c From SVMXC__Installed_Product__c where Id = :IBId];
            return IB.SVMXC__Product__c;
        } catch (Exception e){ 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag021(),e.getMessage()));
            return null;}   
        
    }    
    
    
    public PageReference AddPartsRequestLine()
    {       
        SVMXC__Parts_Request_Line__c newListLine    =   new SVMXC__Parts_Request_Line__c(); 
        newListLine.SVMXC__Parts_Request__c   =   prID; 
        if (Setng_usePriceFromPriceBook.toUpperCase() =='TRUE')
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  true;                
        else
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  false;
        TempPRDetailArray.add(newListLine);         
        return null;
    }
    
    public PageReference RemovePartsRequestLine()
    {  
        
        List<Integer> selectedLines = new List<Integer>();
        Integer i;      
        for (i=0;i<TempPRDetailArray.size();i++)
        {
            if (TempPRDetailArray.get(i).SVMXC__Select__c==true)
            {
                selectedLines.add(i);
            }
        }
        if (selectedLines.size()<= 0)
        {
            DisplayBlockLevelMessage = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG015()));            
            return null;    
        }
        selectedLines.sort();          
        for (i=selectedLines.size()-1;i>=0;i--)
        {
            
            TempPRDetailArray.remove(selectedLines.get(i));
            
        }
        return null;
    }  
    
    //Object to retrieve Settings and Translation Tag Values
    public String getTAG001(){ return system.label.PREQ002_TAG001;}
    public String getTAG002(){ return system.label.PREQ002_TAG002;}
    public String getTAG003(){ return system.label.PREQ002_TAG003;}
    public String getTAG004(){ return system.label.PREQ002_TAG004;}
    public String getTAG005(){ return system.label.PREQ002_TAG005;}
    public String getTAG006(){ return system.label.PREQ002_TAG006;}
    public String getTAG007(){ return system.label.PREQ002_TAG007;}
    public String getTAG008(){ return system.label.PREQ002_TAG008;}
    public String getTAG009(){ return system.label.PREQ002_TAG009;}
    public String getTAG011(){ return system.label.PREQ002_TAG011;}
    public String getTAG012(){ return system.label.PREQ002_TAG012;}
    public String getTAG013(){ return system.label.PREQ002_TAG013;}
    public String getTAG014(){ return system.label.PREQ002_TAG014;}
    public String getTAG015(){ return system.label.PREQ002_TAG015;}
    public String getTAG016(){ return system.label.PREQ002_TAG016;}
    public String getTAG018(){ return system.label.PREQ002_TAG018;}
    public String getTAG019(){ return system.label.PREQ002_TAG019;} 
    public String getTAG020(){ return system.label.PREQ002_TAG020;} 
    public String getHLPURL() {return system.label.PREQ002_HLPURL;}
    
    public String getTAG021(){ return system.label.PREQ002_TAG021;} //Error in Create Parts Request Lines
    public String getTAG022(){ return system.label.PREQ002_TAG022;} //Processing...
    
    
    
}