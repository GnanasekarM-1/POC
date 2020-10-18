/* Security Scanned */
public  with sharing class WORD_CreateWOReqRecLines 
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
    
    String worrlId = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('id'));
    public String NewRecordTypeName = 'Request/Receipt';
    
    
    SVMXC.COMM_Utils utilities = new SVMXC.COMM_Utils();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags(); 
    // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('WORD005'); 
    public Map<String, String> AllSubModuleSettings;
    String Setng_usePriceFromPriceBook ;
    String Setng_WORRPriceBook ;
    String helpURL;
    
    //Variable Declarations
    String WDetailsSobjectType = 'SVMXC__Service_Order_Line__c';
    
    //Price book Instance
    Pricebook2 priceBook = new Pricebook2();
    
    //Vaidate Setting
    public void ValidateAllSettings()
    {
        
        if (AllSubModuleSettings.size()==0)
            AddToErrorsList(getTAG009()); //Settings not available for the SubModule: Create Request/Receipt Lines
        
        Setng_usePriceFromPriceBook = AllSubModuleSettings.get('SET007');
        if (Setng_usePriceFromPriceBook==null)
            AddToErrorsList(getTAG009()); //Setting not available for the flag usePriceFromPriceBook
        
        if ((Setng_usePriceFromPriceBook!=null)&& (Setng_usePriceFromPriceBook.toUpperCase() =='TRUE'))
        {   
            if (NewRecordTypeName =='Request/Receipt')
            {
                Setng_WORRPriceBook = AllSubModuleSettings.get('SET008');      
                if (Setng_WORRPriceBook ==null)
                    AddToErrorsList(getTAG009()); //Setting not available for Request Receipt PriceBook 
                else  
                {
                    priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(Setng_WORRPriceBook);        
                    if(priceBook==null)
                        AddToErrorsList(getTAG036());//PriceBook not found
                }
            }
        }
    }
    //Global variables with get & set methods  
    Boolean CheckAllLines=false;    
    public Boolean getCheckAllLines() {return CheckAllLines;  }
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
    
    public String gethelpURL(){return helpURL;    }    
    
    RecordType TargetRecType;
    public String getTargetRecType()
    {
        if (TargetRecType!=null) return TargetRecType.Name; 
        else return null;
    }
    
    SVMXC__Service_Order__c SourceWOL = new SVMXC__Service_Order__c(); 
    public SVMXC__Service_Order__c getSourceWOL(){ return SourceWOL; }
    
    public SVMXC__Service_Order__c getSourceRRData()
    { 
        SVMXC__Service_Order__c WORR = new SVMXC__Service_Order__c();
        
        String fieldNames;
        String SOQLHeader;          
        try
        {
            Schema.DescribeSObjectResult dsoResult = SVMXC__Service_Order__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
            
            //build a list of all fieldnames for the object
            List<String> fieldList = utilities.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utilities.SVMX_getFieldNamesFromList(fieldList);            
            
            SOQLHeader = 'SELECT '+fieldNames+' FROM SVMXC__Service_Order__c where Id =\''+worrlId+'\'';        
            WORR = Database.query(SOQLHeader);     
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));}
        return WORR; 
    }
    
    //List to store the existing lines of WO Request Receipt Record Type
    List<SVMXC__Service_Order_Line__c> ExistingWORRLines = new List<SVMXC__Service_Order_Line__c> ();
    
    //New objects (with get & set methods) to manage lines during user interaction
    List<SVMXC__Service_Order_Line__c> TempWORRDetailArray = new List<SVMXC__Service_Order_Line__c> ();
    
    public List<SVMXC__Service_Order_Line__c> getNewWORRLine() {return TempWORRDetailArray; }
    
    public void setNewWORRLine(List<SVMXC__Service_Order_Line__c> objArray) 
    {
        for(SVMXC__Service_Order_Line__c objRec :objArray)
        {
            TempWORRDetailArray.add(objRec);
        }
    } 
    
    //Global Variables (with get & set methods) to manage display of Warnings and Errors
    public void setshowWarnings(Boolean sw){showWarnings=sw;}
    public Boolean DisplayBlockLevelMessage = false;
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }
    
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
    
    //Method to Display Errors/Warnings
    public void DisplayErrorsNWarnings()
    {
        if( ErrorMessages.size()>0)
        {
            ValidRecords = false;  
            DisplayBlockLevelMessage = false; 
            for (String msg : ErrorMessages)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG007(),msg)) ;  
            }
        }   
        else if( WarningMessages.size()>0)
        {
            for (String msg : WarningMessages)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning,getTAG007(),msg)) ;   
            }
        }   
    }
    
    //Constructor:
    //1. Validates the url parameters : Source Record Id and Target Record Type
    //2. Validates all the Settings
    //3. Populates the existing lines into TempWORRDetailArray
    //4. Retrieves the Record Type for Target Object
    public WORD_CreateWOReqRecLines(ApexPages.StandardController controller)
    {
        AllSubModuleSettings= settings.SVMX_getSettingList('WORD005'); //SubModule: Create Parts Order Lines
        
        if (worrlId ==null)
            AddToErrorsList(getTAG008());       //Source Object Record Id not found
        if (NewRecordTypeName ==null)
            AddToErrorsList(getTAG024());       //Target Record Type not available
        
        ValidateAllSettings();  
        
        DisplayErrorsNWarnings();
        SourceWOL = getSourceRRData();
        
        if (ValidRecords == true)   
        {
            TargetRecType   = getRecordType(NewRecordTypeName,'SVMXC__Service_Order_Line__c');
            ExistingWORRLines = getExistingLines();
            //Automatically add an empty line by default if there are no existing records             
            if(ExistingWORRLines.size() == 0)
            {
                AddRequestReceiptLine();
            }
            for (SVMXC__Service_Order_Line__c line :  ExistingWORRLines)
            {
                line.SVMXC__Select__c = false;
                TempWORRDetailArray .add(line);   
            }
            
        }  
    }
    
    //Method to return the existing lines from Source WO
    public List<SVMXC__Service_Order_Line__c> getExistingLines()
    {
        List<SVMXC__Service_Order_Line__c> RRLines;
        List<SVMXC__Service_Order_Line__c> RRLineRecords = new List<SVMXC__Service_Order_Line__c>();
        
        String fieldNames;
        String SOQLDetail;          
        try
        {
            Schema.DescribeSObjectResult dsoResult = SVMXC__Service_Order_Line__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__Service_Order_Line__c.fields.getMap();
            
            //build a list of all fieldnames for the object
            List<String> fieldList = utilities.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utilities.SVMX_getFieldNamesFromList(fieldList);            
            system.debug('fieldNames' + fieldNames);
            fieldNames +=' , SVMXC__Product__r.Name, SVMXC__Product__r.ProductCode, SVMXC__Serial_Number__r.Name, SVMXC__Received_Location__r.Name,SVMXC__Requested_Location__r.Name, SVMXC__Service_Order__r.SVMXC__Company__r.Name,  SVMXC__Service_Order__r.SVMXC__Order_Status__c, SVMXC__Product__r.Description, SVMXC__Product__r.Family , SVMXC__Product__r.SVMXC__Product_Line__c ';            
            system.debug('fieldNames1' + fieldNames);
            SOQLDetail = ' SELECT '+fieldNames+' FROM SVMXC__Service_Order_Line__c where RecordTypeId=\''+TargetRecType.Id+'\' and SVMXC__Service_Order__c =\''+worrlId+'\'';
            RRLines = Database.query(SOQLDetail);     
            for ( SVMXC__Service_Order_Line__c RRLine : RRLines)
            {
                RRLineRecords.add(RRLine);
            }                
        }catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));}
        return RRLineRecords;   
        
    }
    //Method used to display/hide pageBlock Table column headings depending upon the number of lines available  
    public Boolean getDisplayTableColumns() 
    {       
        if (TempWORRDetailArray.size()==0)
        {
            CheckAllLines=false;   
            return false;
        }
        else
            return true;        
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
            for (SVMXC__Service_Order_Line__c PreEditLine : ExistingWORRLines)
            {
                Boolean OldLineExist = false;
                for (SVMXC__Service_Order_Line__c PostEditLine : TempWORRDetailArray)
                {
                    if (PreEditLine.Id == PostEditLine.Id) 
                    {
                        OldLineExist = true;                            
                        break;                              
                    }
                }                   
                if(OldLineExist !=true)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Service_Order_Line__c' ) ) {
                        //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete PreEditLine;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                }
            }           
            //upsert TempWORRDetailArray;
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempWORRDetailArray, COMM_SecurityUtils.Access.Upsertable ) ) {
                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                upsert TempWORRDetailArray;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;
            }
            PageReference rrPage = new PageReference('/' + worrlId);
            rrPage.setRedirect(true);
            return rrPage;
        }
        return null;     
    }
    
    //Method to update line
    public PageReference UpdatePrice()
    { 
        for (SVMXC__Service_Order_Line__c line :TempWORRDetailArray)
        {
            if ((line.SVMXC__Product__c!=null) && (line.SVMXC__Use_Price_From_Pricebook__c == true))
            {
                PricebookEntry pbe = new PricebookEntry();
                if(Userinfo.isMultiCurrencyOrganization())
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, string.valueOf(SourceWOL.get('CurrencyIsoCode')), line.SVMXC__Product__c);                                                        
                else
                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, null, line.SVMXC__Product__c);
                
                if (pbe !=null)
                    line.Estimated_Price2__c =pbe.UnitPrice;                             
            }
            
            
        }           
        return null;
    }
    
    public PageReference AddRequestReceiptLine()
    {       
        SVMXC__Service_Order_Line__c newListLine = new SVMXC__Service_Order_Line__c(); 
        if(worrlId != null)
            newListLine.SVMXC__Service_Order__c = worrlId; 
        if(TargetRecType.Id != null)
            newListLine.RecordTypeId = TargetRecType.Id;
        if (Setng_usePriceFromPriceBook.toUpperCase() =='TRUE')
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  true;                
        else
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  false;
        TempWORRDetailArray.add(newListLine);         
        return null;
    }
    
    //Method to remove lines
    public PageReference RmvRequestReceiptLine()
    {  
        
        List<Integer> selectedLines = new List<Integer>();
        Integer i;      
        for (i=0;i<TempWORRDetailArray.size();i++)
        {
            if (TempWORRDetailArray.get(i).SVMXC__Select__c==true)
            {
                selectedLines.add(i);
            }
        }
        if (selectedLines.size()<= 0)
        {
            DisplayBlockLevelMessage = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),getTAG026()));
            return null;    
        }
        selectedLines.sort();          
        for (i=selectedLines.size()-1;i>=0;i--)
        {
            TempWORRDetailArray.remove(selectedLines.get(i));
        }
        return null;
        
        
    }  
    
    //Methods for Validations
    public Boolean isValidData()
    {
        ValidRecords = true; 
        Boolean validLineQuantity= true;
        ErrorMessages.clear();          
        
        validLineQuantity = isValidLineQuantity();          
        
        if(ValidLineQuantity==false)
        {                           
            //ErrorMessages.add(getTAG020()); 
            ValidRecords = false;                                           
        }
        
        /*******************************************
Sample Code to add Warnings to Warnings List
--------------------------------------------
if (WarningDisplayed==false)
WarningMessages.add(getTAG020());  
*******************************************/     
        DisplayErrorsNWarnings();
        return ValidRecords;    
    }   
    
    public Boolean isValidLineQuantity()
    {
        Boolean isValidLine =true;
        for(SVMXC__Service_Order_Line__c ListObj :TempWORRDetailArray)
        {      
            if(ListObj.SVMXC__Product__c==null)
            {
                ListObj.SVMXC__Product__c.addError(getTAG035());
                isValidLine=false;
                //break;
            }
            if( (ListObj.Requested_Quantity2__c == null || ListObj.Requested_Quantity2__c <0))// && ListObj.SVMXC__Select__c==true)
            {  
                ListObj.Requested_Quantity2__c.addError(getTAG034());                                         
                isValidLine =false;                      
                //break;
            }
            /* if(ListObj.SVMXC__Date_Required__c==null)
{
ListObj.SVMXC__Date_Required__c.addError(getTAG020());
isValidLine=false;
break;
}*/
        }
        return isValidLine;
    }
    //Method to get RecordType
    public RecordType getRecordType(String Name,String SobjectType)
    {
        RecordType rType;
        String SOQL  = 'SELECT Id,Name  FROM RecordType  where SobjectType  =\''+SobjectType+'\' AND Name=\''+Name+'\' ';        
        try
        {
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            rType = Database.query(SOQL);
        }catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG007(),e.getMessage()));}   
        return rType;
    }
    
    //Method for Cancel
    public PageReference Cancel() 
    {
        PageReference worrPage = new PageReference('/' + worrlId);
        worrPage.setRedirect(true);
        return worrPage;             
    }
    
    //Metods for Tags
    
    public String getTAG004(){ return system.label.WORD005_TAG004;} //Continue 
    public String getTAG005(){ return system.label.WORD005_TAG005;} //Cancel  
    public String getTAG007(){ return system.label.WORD005_TAG007;} //Error:
    public String getTAG008(){ return system.label.WORD005_TAG008;} //No valid source record was not provided to create work order lines
    public String getTAG009(){ return system.label.WORD005_TAG009;} //An error occurred when trying to obtain configuration settings for this screen. Please contact your ServiceMax administrator immediately.
    public String getTAG017(){ return system.label.WORD005_TAG017;} //Delete Lines
    public String getTAG018(){ return system.label.WORD005_TAG018;} //Save
    public String getTAG024(){ return system.label.WORD005_TAG024;} //An error occurred when processing record types. Please contact your ServiceMax administrator immediately
    public String getTAG026(){ return system.label.WORD005_TAG026;} //Please select one or more records from the list first.
    //public String getTAG028(){ return system.label.WORD005_TAG028')?svmxTagList.get('TAG028') : '';} //Use Pricebook
    //public String getTAG029(){ return system.label.WORD005_TAG029')?svmxTagList.get('TAG029') : '';} //Unit Price
    public String getTAG030(){ return system.label.WORD005_TAG030;} //Create Request/Receipt lines for Work Order:
    public String getTAG031(){ return system.label.WORD005_TAG031;} //Help for Work Order Lines
    public String getTAG032(){ return system.label.WORD005_TAG032;} //Add Line 
    // public String getTAG016(){ return system.label.WORD005_TAG016')?svmxTagList.get('TAG016') : '';} //Get Price 
    public String getTAG033(){ return system.label.WORD005_TAG033;} //Create Request/Receipt Lines
    public String getTAG034(){ return system.label.WORD005_TAG034;} //Invalid Line Quantity   
    public String getTAG035(){ return system.label.WORD005_TAG035;} //Please enter a valid product
    public String getTAG036(){ return system.label.WORD005_TAG036;} //The price book configured for Work Order Request lines was not found. Please make sure the price book name is valid in ServiceMax setup          
    public String getTAG039(){ return system.label.WORD005_TAG039;} //The price book configured for Work Order Request lines was not found. Please make sure the price book name is valid in ServiceMax setup          
    public String getHLPURL(){ return system.label.WORD005_HLPURL;} 
}