public  with sharing class SXFR_CreateSTLines 
{
    //-------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    //---------------------------------
    public SXFR_CreateSTLines(ApexPages.StandardController controller) {
        if (sxfrID ==null)        AddToErrorsList(getTag013());       //Source Object Record Id not found
        
        AllSubModuleSettings= settings.SVMX_getSettingList('SXFR002');        
        ValidateAllSettings();  
        
        DisplayErrorsNWarnings();
        SourceSXFR = getSourceSXFRData();
        
        if (ValidRecords == true)   
        {
            ExistingSXFRLines = getExistingLines();
            //Automatically add an empty line by default if there are no existing records             
            if(ExistingSXFRLines.size() == 0)
            {
                AddSXFRLine();
            }
            for (SVMXC__Stock_Transfer_Line__c line :  ExistingSXFRLines)
            {
                line.SVMXC__Select__c = false;
                TempSXFRDetailArray .add(line);   
            }
        }    
        
    }
    String sxfrID =  String.escapeSingleQuotes(System.currentPageReference().getParameters().get('Id'));
    
    
    SVMXC.COMM_Utils utilities = new SVMXC.COMM_Utils();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> AllSubModuleSettings ;
    String Setng_usePriceFromPriceBook;
    String Setng_StockTransferPriceBook;
    
    
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags(); 
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('SXFR002');
    
    Pricebook2 priceBook = new Pricebook2();
    
    public void ValidateAllSettings()
    {
        //Validte the settings
        
        if (AllSubModuleSettings.size()==0)            AddToErrorsList(getTag016()); 
        
        Setng_usePriceFromPriceBook =AllSubModuleSettings.get('SET002');
        if (Setng_usePriceFromPriceBook==null)           AddToErrorsList(getTag016()); //Setting not available for the flag usePriceFromPriceBook
        
        
        Setng_StockTransferPriceBook = AllSubModuleSettings.get('SET003');        
        if (Setng_StockTransferPriceBook ==null)            AddToErrorsList(getTAG016()); //Setting not available for Parts Request PriceBook 
        else  {
            priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(Setng_StockTransferPriceBook);        
            if(priceBook==null)
                AddToErrorsList(getTag019());//PriceBook not found
        }
    }
    
    
    Boolean CheckAllLines=false;    
    public Boolean getCheckAllLines() {return CheckAllLines;  }
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
    
    
    //Objects& method to populate the source object data with get method        
    SVMXC__Stock_Transfer__c SourceSXFR = new SVMXC__Stock_Transfer__c(); 
    public SVMXC__Stock_Transfer__c getSourceSXFR(){ return SourceSXFR; }
    
    public SVMXC__Stock_Transfer__c getSourceSXFRData()
    { 
        SVMXC__Stock_Transfer__c SXFR = new SVMXC__Stock_Transfer__c();
        
        String fieldNames;
        String SOQLHeader;          
        try
        {
            Schema.DescribeSObjectResult dsoResult = SVMXC__Stock_Transfer__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Stock_Transfer__c.fields.getMap();
            
            //build a list of all fieldnames for the object
            List<String> fieldList = utilities.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utilities.SVMX_getFieldNamesFromList(fieldList);            
            
            SOQLHeader = '  SELECT '+fieldNames+' FROM SVMXC__Stock_Transfer__c where Id =\''+sxfrID+'\'  ';        
            SXFR = Database.query(SOQLHeader);     
            
            
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag021(),e.getMessage()));}
        return SXFR; 
    }
    
    
    //List to store the existing lines of Stock Transfer
    
    List<SVMXC__Stock_Transfer_Line__c> ExistingSXFRLines= new List<SVMXC__Stock_Transfer_Line__c> ();
    
    List<SVMXC__Stock_Transfer_Line__c> TempSXFRDetailArray = new List<SVMXC__Stock_Transfer_Line__c> (); 
    
    public List<SVMXC__Stock_Transfer_Line__c> getNewSXFRLine() {return TempSXFRDetailArray; }    
    public void setNewSXFRLine(List<SVMXC__Stock_Transfer_Line__c> objArray) {TempSXFRDetailArray = objArray;}
    
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
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag021(),msg)) ;  
            }
        }   
        else if( WarningMessages.size()>0)
        {
            for (String msg : WarningMessages)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning,getTag021(),msg)) ;   
            }
        }   
    }
    
    
    
    
    //Method to return the existing lines from Source Parts Request
    public List<SVMXC__Stock_Transfer_Line__c> getExistingLines()
    {
        List<SVMXC__Stock_Transfer_Line__c> SXFRLines;
        List<SVMXC__Stock_Transfer_Line__c> SXFRLineRecords = new List<SVMXC__Stock_Transfer_Line__c>();
        
        String fieldNames;
        String SOQLDetail;          
        try
        {
            Schema.DescribeSObjectResult dsoResult = SVMXC__Stock_Transfer_Line__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Stock_Transfer_Line__c.fields.getMap();
            
            //build a list of all fieldnames for the object
            List<String> fieldList = utilities.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utilities.SVMX_getFieldNamesFromList(fieldList);            
            
            fieldNames +=' , SVMXC__Product__r.Name, SVMXC__Product__r.ProductCode';            
            
            SOQLDetail = '  SELECT '+fieldNames+' FROM SVMXC__Stock_Transfer_Line__c where SVMXC__Stock_Transfer__c =\''+sxfrID+'\'  ';        
            SXFRLines = Database.query(SOQLDetail);     
            
            for ( SVMXC__Stock_Transfer_Line__c SXFRLine : SXFRLines)
            {
                SXFRLineRecords.add(SXFRLine);
            }                
        }catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021(),e.getMessage()));}
        return SXFRLineRecords;   
    } 
    
    //Method used to display/hide pageBlock Table column headings depending upon the number of lines available    
    public Boolean getDisplayTableColumns() 
    {       
        if (TempSXFRDetailArray.size()==0)
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
            ValidRecords = false;                                           
        }
        
        DisplayErrorsNWarnings();
        return ValidRecords;    
    }        
    //Method to validtae Quantity
    public Boolean isvalidLine()
    {
        Boolean isValid =true;
        for(SVMXC__Stock_Transfer_Line__c ListObj :TempSXFRDetailArray)
        {      
            if(ListObj.SVMXC__Product__c==null)
            {
                ListObj.SVMXC__Product__c.addError(getTAG018());
                isValid=false;
                
            }
            if( (ListObj.SVMXC__Quantity_Transferred2__c == null || ListObj.SVMXC__Quantity_Transferred2__c <0))
            {  
                ListObj.SVMXC__Quantity_Transferred2__c.addError(getTAG014());                                         
                isValid =false;                      
                
            }
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
            try
            {   
                for (SVMXC__Stock_Transfer_Line__c  PreEditLine : ExistingSXFRLines)
                {
                    Boolean OldLineExist = false;
                    
                    for (SVMXC__Stock_Transfer_Line__c PostEditLine : TempSXFRDetailArray)
                    {
                        if (PreEditLine.Id == PostEditLine.Id) 
                        {
                            OldLineExist = true;                            
                            break;                              
                        }
                    }               
                    if(OldLineExist !=true)
                    {
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Stock_Transfer_Line__c' ) ) {
                            
                            delete PreEditLine; //SDL-SVMX-DELETE-FLS-ENFORCED
                        } else {
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                            return null;
                        }
                        
                    }
                }
                //upsert TempSXFRDetailArray;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempSXFRDetailArray, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert TempSXFRDetailArray; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                
                PageReference sxfrPage = new PageReference('/' + sxfrID);
                sxfrPage.setRedirect(true);
                return sxfrPage; 
            }catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag021(),e.getMessage()));}
        }
        return null;
    }
    
    public PageReference Cancel() 
    {
        PageReference sxfrPage = new PageReference('/' + sxfrID);
        sxfrPage.setRedirect(true);
        return sxfrPage;             
    }
    
    public PageReference GettPrice()
    {
        
        for(SVMXC__Stock_Transfer_Line__c line:TempSXFRDetailArray)
        {
            if((line.SVMXC__Product__c !=null)&&(line.SVMXC__Use_Price_From_Pricebook__c ==true))
            {
                PricebookEntry pbe = new PricebookEntry();
                if(Userinfo.isMultiCurrencyOrganization())
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook,  string.valueOf(SourceSXFR.get('CurrencyIsoCode')), line.SVMXC__Product__c);
                else
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, null, line.SVMXC__Product__c);                                                                        
                if (pbe !=null)
                    line.Unit_Price2__c = pbe.UnitPrice;
            }
        }
        return null;
    }
    
    //Method to get IB/Product    
    public Id SVMX_getProductIdFromIB(Id IBId)
    {     
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        try
        {
            IB = [Select SVMXC__Product__c From SVMXC__Installed_Product__c where Id = :IBId];
            return IB.SVMXC__Product__c;
        } catch (Exception e){ 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021(),e.getMessage()));
            return null;}   
        
    }    
    
    //Method to add Lines
    public PageReference AddSXFRLine()
    {       
        SVMXC__Stock_Transfer_Line__c newListLine    =   new SVMXC__Stock_Transfer_Line__c(); 
        newListLine.SVMXC__Stock_Transfer__c   =   sxfrID; 
        if (Setng_usePriceFromPriceBook.toUpperCase() =='TRUE')
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  true;                
        else
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  false;
        TempSXFRDetailArray.add(newListLine);         
        return null;
    }
    
    //Method to Remove lines 
    public PageReference RemoveSXFRLine()
    {  
        
        List<Integer> selectedLines = new List<Integer>();
        Integer i;      
        for (i=0;i<TempSXFRDetailArray.size();i++)
        {
            if (TempSXFRDetailArray.get(i).SVMXC__Select__c==true)
            {
                selectedLines.add(i);
            }
        }
        if (selectedLines.size()<= 0)
        {
            DisplayBlockLevelMessage = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG021(),getTAG015()));            
            return null;    
        }
        selectedLines.sort();          
        for (i=selectedLines.size()-1;i>=0;i--)
        {
            TempSXFRDetailArray.remove(selectedLines.get(i));
        }
        return null;
    }  
    
    //Object to retrieve Settings and Translation Tag Values
    public String getTAG001(){ return system.label.SXFR002_TAG001;}
    public String getTAG002(){ return system.label.SXFR002_TAG002;}
    public String getTAG003(){ return system.label.SXFR002_TAG003;}
    public String getTAG004(){ return system.label.SXFR002_TAG004;}
    public String getTAG005(){ return system.label.SXFR002_TAG005;}
    public String getTAG006(){ return system.label.SXFR002_TAG006;}
    public String getTAG007(){ return system.label.SXFR002_TAG007;}
    public String getTAG008(){ return system.label.SXFR002_TAG008;}
    public String getTAG009(){ return system.label.SXFR002_TAG009;}
    public String getTAG011(){ return system.label.SXFR002_TAG011;}
    public String getTAG012(){ return system.label.SXFR002_TAG012;}
    public String getTAG013(){ return system.label.SXFR002_TAG013;}
    public String getTAG014(){ return system.label.SXFR002_TAG014;}
    public String getTAG015(){ return system.label.SXFR002_TAG015;}
    public String getTAG016(){ return system.label.SXFR002_TAG016;}
    public String getTAG018(){ return system.label.SXFR002_TAG018;}
    public String getTAG019(){ return system.label.SXFR002_TAG019;}
    public String getHLPURL() {return system.label.SXFR002_HLPURL;}
    public String getTAG021(){ return system.label.SXFR002_TAG021;} //Error in Create Stock Transfer Lines
    public String getTAG022(){ return system.label.SXFR002_TAG022;} //Processing...
    
    
}