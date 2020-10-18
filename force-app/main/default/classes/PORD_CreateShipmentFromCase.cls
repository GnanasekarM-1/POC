/*******************************************************************************************************************
ServiceMax Controller Class for the VF Page PORD_CreateShipmentFromCase:
-----------------------------------------------------------------------
1. Manages creation of Shipment Parts Order Object with lines
Module      :   PORD
SubModule   :   PORD002

Release Notes: GM 20Jan10: Add logic to populate Site__c reference when populating address from IB
*******************************************************************************************************************/
/* Security Scanned */
public  with sharing class PORD_CreateShipmentFromCase
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
    
/*******************************************************************************************************************
URL Parameters  
*******************************************************************************************************************/
  String caseID = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('cid'));

  // Variable to hold Defualt Pick List Value
    public String defSouCountry;
    public String defDesCountry;
/*******************************************************************************************************************
List to store new lines and the lines which are captured from Source object
*******************************************************************************************************************/
  List<SVMXC__RMA_Shipment_Line__c> TempRMASHPDetailArray = new List<SVMXC__RMA_Shipment_Line__c> ();     
  public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> ();


/*******************************************************************************************************************
Variables to store records based on setting values
*******************************************************************************************************************/

  SVMXC__Site__c Location = new SVMXC__Site__c();
  Pricebook2 priceBook = new Pricebook2();

  public String SelectedAddressType;
  public String selectedRecordType;  
  public String selectedLineRecordType;
  
  public String getSelectedAddressType(){ return SelectedAddressType;}
  public void setSelectedAddressType(String val){SelectedAddressType = val;}
  
  // Variables to retrieve the Pick list values for Address Type
  Map<String, SVMXC__ServiceMax_Processes__c> SetDefAddTypeRec;
  String AddTypeValues ;
  List<String> AddTypeArray = new List<String> ();
        
    public List<SelectOption> getAddressTypes() 
    {
        List<SelectOption> options = new List<SelectOption>();      
        for(String  opt :AddTypeArray ){ options.add(new SelectOption(opt,opt)); }     
        return options;
    }
    
    /*
       Setter and Getter for Shipment Header RecordType.
       Changed on 06/17/2009
       Changed By Prashant Singh
   */   
    public String getSelectedRecordType(){
        return selectedRecordType;   
    }
    public void setSelectedRecordType(String rType){selectedRecordType=rType;    }    
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> options = new List<SelectOption>(); 
        String pListRT = AllSubModuleSettings.get('SET018');
        List<String> recordTypeList=new List<String>();
        recordTypeList=pListRT.split(',');      
        for(String  option :recordTypeList){ options.add(new SelectOption(option,option));}     
        return options;
    }
    
    /*
       Setter and Getter for RMA Line RecordType.
       Changed on 06/17/2009
       Changed By Prashant Singh
   */   
    public String getselectedLineRecordType(){
       // system.debug('selectedLineRecordType:'+selectedLineRecordType);
        return selectedLineRecordType;   
    }
    public void setselectedLineRecordType(String rType){selectedLineRecordType=rType;  }    
    public List<SelectOption> getLineRecordTypes(){
        List<SelectOption> options = new List<SelectOption>(); 
        String pListRT = AllSubModuleSettings.get('SET020');
       // system.debug('pListRT:'+pListRT);
        if(pListRT!=null || pListRT!=''){
            List<String> recordTypeList=new List<String>();
            recordTypeList=pListRT.split(',');      
            for(String  option :recordTypeList){ options.add(new SelectOption(option,option));}     
        }        
        return options;
    }
    
  RecordType TargetLineRecordType = new RecordType ();   
/*******************************************************************************************************************
New objects which are to be created on submission of the VF Page
*******************************************************************************************************************/

  SVMXC__RMA_Shipment_Order__c NewRMASHPHeader = new SVMXC__RMA_Shipment_Order__c(); 

  
  public SVMXC__RMA_Shipment_Order__c getNewRMAShpipmentHeader() {return NewRMASHPHeader; } 
  public void setNewRMAShpipmentHeader(SVMXC__RMA_Shipment_Order__c obj) {NewRMASHPHeader = obj; } 
  
  public List<SVMXC__RMA_Shipment_Line__c> getNewRMAShpipmentLines() {return TempRMASHPDetailArray; }
  public void setNewRMAShpipmentLines(List<SVMXC__RMA_Shipment_Line__c> objArray) {TempRMASHPDetailArray = objArray; }
  
    

/*******************************************************************************************************************
Source Object with get method
*******************************************************************************************************************/
  public Case CaseHeader ; 
  public Case getCaseHeader(){  return CaseHeader;    }

/*******************************************************************************************************************
Variables to store FieldNames for various Objects
*******************************************************************************************************************/
  String CaseFieldNames; 
  String LocationFieldNames; 
  
/*******************************************************************************************************************
Global variables for Settings & Translation
*******************************************************************************************************************/
  SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
  SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
  SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags(); 
  //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('PORD002'); 

  public Map<String, String> AllSubModuleSettings = settings.SVMX_getSettingList('PORD002'); 
  String Setng_ShpFromCaseMapId;  //Returns MapId for Create Shipment from Case SET001
  
  String Setng_DefaultAddressType;//Setting for Default Address Type values SET004
  String Setng_DefaultFromLocation ;//  Setting for Default From Location 'SET005'
  String Setng_ActionOnNoLine ;                         //SET006  
  String Setng_ActionOnBlankFromAddress ;   //SET007
  String Setng_ActionOnBlankToAddress  ;    //SET008


  String Setng_usePriceFromPriceBook ;      //SET010
  String Setng_ShipmentPriceBook ;          //SET011
  String Setng_HeaderRecTypeName;           //SET014
  String Setng_LineRecTypeName;             //SET015
  
/*******************************************************************************************************************
Method to validate the availability of all the Settings
*******************************************************************************************************************/
  
    public void ValidateAllSettings(){      
        for(String str: AllSubModuleSettings.keySet()){
            system.debug('SETTING VALES:'+str+':'+AllSubModuleSettings.get(str));
        }
        if (AllSubModuleSettings.size()==0) 
            AddToErrorsList(getTag025());           //Settings not available for the SubModule: Create Parts Order Lines

//SET001
        Setng_ShpFromCaseMapId =AllSubModuleSettings.get('SET001'); //Returns MapId for Create Shipment from Case
        system.debug('Setng_ShpFromCaseMapId'+Setng_ShpFromCaseMapId); 
        if (Setng_ShpFromCaseMapId ==null) 
            AddToErrorsList(getTag025());           //Setting not available for MapId to Create Shipment from Case
       
//SET004               
        Setng_DefaultAddressType= AllSubModuleSettings.get('SET004'); 
         system.debug('Setng_DefaultAddressType'+Setng_DefaultAddressType); //Setting for Default Address Type values
        if (Setng_DefaultAddressType ==null) 
            AddToErrorsList(getTag025());           //Setting not available for Default Address Type values
        else
            {   // Populating the array for Picklist values
                SetDefAddTypeRec= settings.SVMX_getSettingDef('PORD002', 'SET004');
                AddTypeValues = SetDefAddTypeRec.get('SET004').SVMXC__VALUES__C;
                AddTypeValues = AddTypeValues.replace('~|~','~');       
                AddTypeArray = AddTypeValues.split('~');                        
            }

//SET005     
        Setng_DefaultFromLocation =AllSubModuleSettings.get('SET005'); 
        system.debug('Setng_DefaultFromLocation'+Setng_DefaultFromLocation);  
            // This is not an error. HS 06/13/2009 8:06AM IST
        // if (Setng_DefaultFromLocation ==null) { 
            //AddToErrorsList(getTag025());           //Setting not available for Default From Location
         // }
           
//SET006
        Setng_ActionOnNoLine           = AllSubModuleSettings.get('SET006'); 
        system.debug('Setng_ActionOnNoLine'+Setng_ActionOnNoLine);   
        if (Setng_ActionOnNoLine ==null) 
            AddToErrorsList(getTag025()); //Setting not available for Action On No Line
        

//SET007
        Setng_ActionOnBlankFromAddress = AllSubModuleSettings.get('SET007');  
        system.debug('Setng_ActionOnBlankFromAddress'+Setng_ActionOnBlankFromAddress); 
        if (Setng_ActionOnBlankFromAddress ==null) 
            AddToErrorsList(getTag025());           //Setting not available for Action On Blank From Address
//SET008     
        Setng_ActionOnBlankToAddress   = AllSubModuleSettings.get('SET008');  
        system.debug('Setng_ActionOnBlankToAddress'+Setng_ActionOnBlankToAddress); 
        if (Setng_ActionOnBlankToAddress ==null) 
            AddToErrorsList(getTag025());           //Setting not available for Action On Blank To Address


//SET010            
        Setng_usePriceFromPriceBook =AllSubModuleSettings.get('SET010');
        system.debug('Setng_usePriceFromPriceBook'+Setng_usePriceFromPriceBook);
        if (Setng_usePriceFromPriceBook==null)
            AddToErrorsList(getTag025());           //Setting not available for the flag usePriceFromPriceBook
            
        //if ((Setng_usePriceFromPriceBook!=null)&& (Setng_usePriceFromPriceBook.toUpperCase() !='FALSE'))
       // {   
            Setng_ShipmentPriceBook =  AllSubModuleSettings.get('SET011'); 
            system.debug('Setng_ShipmentPriceBook'+Setng_ShipmentPriceBook);     
            if (Setng_ShipmentPriceBook ==null)
                AddToErrorsList(getTag025()); //Setting not available for Shipment PriceBook            
            else  
                {
                priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(Setng_ShipmentPriceBook);        
                if(priceBook==null) 
                    AddToErrorsList(getTag030());//PriceBook not found           
                }
        //}       

//SET014
        Setng_HeaderRecTypeName = AllSubModuleSettings.get('SET014');
         system.debug('Setng_HeaderRecTypeName'+Setng_HeaderRecTypeName);   
        if (Setng_HeaderRecTypeName ==null) 
            AddToErrorsList(getTag025()); //Setting not available for :Header Record Type
            
//SET015
        Setng_LineRecTypeName = AllSubModuleSettings.get('SET015');  
        system.debug('Setng_LineRecTypeName'+Setng_LineRecTypeName);   
        if (Setng_LineRecTypeName ==null) 
            AddToErrorsList(getTag025()); //Setting not available for :Line Record Type
//SET019
        selectedRecordType=AllSubModuleSettings.get('SET019');

//SET021
        selectedLineRecordType=AllSubModuleSettings.get('SET021');                          
}


/*******************************************************************************************************************
Global variables with get & set methods
*******************************************************************************************************************/
  Boolean ValidRecords = true;
  
    
  Boolean DisableSourceAddress=true;    
  public Boolean getDisableSourceAddress() {return DisableSourceAddress;  }
  public void setDisableSourceAddress(Boolean val){DisableSourceAddress=val;} 
   
  Boolean CheckAllLines=false;    
  public Boolean getCheckAllLines() {return CheckAllLines;  }
  public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
  String DefaultLocation;
  
  
  Boolean showWarnings=false;    
  public Boolean getshowWarnings() {
            if(ErrorMessages.size()==0 && WarningMessages.size()>0)
                showWarnings=true;
            else
                showWarnings=false;
            return showWarnings;  
            }
  public void setshowWarnings(Boolean sw){showWarnings=sw;}
 
 List<String> ErrorMessages = new  List<String> ();
  public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
  public List<String> getErrorsList() {    return ErrorMessages; }  

 List<String> WarningMessages = new  List<String> ();           
  public void AddToWarningsList(String msg) { WarningMessages.add(msg);}
  public List<String> getWarningsList() { return WarningMessages; }                     
    
 Boolean WarningDisplayed=false;
 Boolean DisplayBlockLevelMessage = false;
  public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }

 Boolean DisplayForm = true;
  public Boolean getDisplayForm(){ return DisplayForm; }
  public void setDisplayForm(Boolean  val){ DisplayForm = val; }

/*******************************************************************************************************************
Method to Display Errors/Warnings
*******************************************************************************************************************/
 public void DisplayErrorsNWarnings(){
        if( ErrorMessages.size()>0)
            {
                system.debug('LOG MESSAGE:'+ErrorMessages);
                ValidRecords = false;  
                DisplayBlockLevelMessage = false; 
                for (String msg : ErrorMessages)
                    {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,msg,'')) ;  
                    }
            }   
        else if( WarningMessages.size()>0 &&(ValidRecords !=false))
                    {
                        for (String msg : WarningMessages)
                            {
                            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning,msg,' ')) ;   
                            }
                    }   
    }
/*******************************************************************************************************************
Constructor 
1. Validates the url parameters : Source Record Id  
2. Validates all the Settings
3. Populates Data for Source and Target Objects
4. Sets Default Address Type values
5. Sets Default From Location

*******************************************************************************************************************/    
 
  public PORD_CreateShipmentFromCase()
    {
    if (caseID ==null){AddToErrorsList(getTag036());}       //Source Object Record Id not found

    ////AllSubModuleSettings = settings.SVMX_getSettingList('PORD002'); //SubModule: Create Parts Order (Shipment)
    ValidateAllSettings(); 
       
    DisplayErrorsNWarnings();
          
    defSouCountry  = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Order__c', 'SVMXC__Source_Country__c');
     
    defDesCountry = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Order__c', 'SVMXC__Destination_Country__c');
   
    if (ValidRecords == true)   
        {
        
        CaseHeader = new Case(); 

        TargetLineRecordType = getRecordType(selectedLineRecordType,'SVMXC__RMA_Shipment_Line__c');
        
        PopulateFieldNames();       
        PopulateSourceNTargetObject();
        
        setSelectedAddressType(Setng_DefaultAddressType);//Setting for Default Address Type values
         if(NewRMASHPHeader.SVMXC__Source_Country__c == null ) NewRMASHPHeader.SVMXC__Source_Country__c = defSouCountry;
         if( NewRMASHPHeader.SVMXC__Destination_Country__c == null) NewRMASHPHeader.SVMXC__Destination_Country__c = defDesCountry;
                    
        if (Setng_DefaultFromLocation != null)
            {
            DefaultLocation =Setng_DefaultFromLocation; //Setting for Default From Location. Returns ID for Location
            Location = getLocationFromId (DefaultLocation); 
            if(Location !=null)
                NewRMASHPHeader.SVMXC__Source_Location__c=Location.Id ;
            }
         NewRMASHPHeader.OwnerId = UserInfo.getUserId();
        //PageReference pagerefAddress = setAddress();
        setAddress();
        //PageReference pagerefSourceAddress = setAddressForSourceLoc();        
        setAddressForSourceLoc();        
        
        }
    else
        setDisplayForm(false);
   }


/*******************************************************************************************************************
Methods to Populate Field Names for various objects [Method to optimize the usage of getDescribe() function]
*******************************************************************************************************************/
    public void PopulateFieldNames() { 
//     CaseFieldNames; 
//     LocationFieldNames; 

        try{
//Populating Case Field Names                   
            //Schema.DescribeSObjectResult souObjCase = Case.sObjectType.getDescribe();
            //Map<String, SObjectField> souObjCasefieldMap = Schema.SObjectType.Case.fields.getMap();

            //build a list of all fieldnames for the object
            //List<String> souObjCaseFieldList = utils.SVMX_getFieldList(souObjCasefieldMap,true);             
            //CaseFieldNames = utils.SVMX_getFieldNamesFromList(souObjCaseFieldList);
            
            
//Populating Location Field Names

           Schema.DescribeSObjectResult dsoResultLoc = SVMXC__Site__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMapLoc = Schema.SObjectType.SVMXC__Site__c.fields.getMap();
            //build a list of all fieldnames for the object
            List<String> fieldListLoc = utils.SVMX_getFieldList(fieldMapLoc,true);      
            LocationFieldNames = utils.SVMX_getFieldNamesFromList(fieldListLoc);            
            
            
            
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));}            
            

    }  
/*******************************************************************************************************************
Methods to Populate Source Object Data into Target Object
*******************************************************************************************************************/
       
  public void PopulateSourceNTargetObject() {
     
        fieldMapSetting = settings.SVMX_getFieldMapping( Setng_ShpFromCaseMapId);    
        Boolean containsCurrField = false;
        Boolean CopyField = true;
        CaseFieldNames = '';
        
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
            {
            CopyField = true;
                    // CurrencyIsoCode must be copied from source to target only if multi-currency is enabled
                    // for the organization
            if (fld.SVMXC__Source_Field_Name__c.equalsIgnoreCase('CurrencyIsoCode'))
                {
                    containsCurrField = true;
                    if (userinfo.isMultiCurrencyOrganization()) 
                    { 
                        CopyField = true;
                    }
                    else
                    {
                      CopyField = false; 
                    }
                }
            if (fld.SVMXC__Source_Field_Name__c != null && CopyField == true)
                {
                CaseFieldNames += fld.SVMXC__Source_Field_Name__c + ', ';
                }
             }
             
            CaseFieldNames +='  Contact.OtherStreet '; 
            CaseFieldNames +=' ,Contact.OtherState ';  
            CaseFieldNames +=' ,Contact.OtherPostalCode '; 
            CaseFieldNames +=' ,Contact.OtherCountry '; 
            CaseFieldNames +=' ,Contact.OtherCity '; 
            CaseFieldNames +=' ,Contact.MailingStreet '; 
            CaseFieldNames +=' ,Contact.MailingState '; 
            CaseFieldNames +=' ,Contact.MailingPostalCode '; 
            CaseFieldNames +=' ,Contact.MailingCountry '; 
            CaseFieldNames +=' ,Contact.MailingCity ';  
            
            CaseFieldNames +=' ,  Account.ShippingStreet  '; 
            CaseFieldNames +=' ,Account.ShippingState '; 
            CaseFieldNames +=' ,Account.ShippingPostalCode '; 
            CaseFieldNames +=' ,Account.ShippingCountry '; 
            CaseFieldNames +=' ,Account.ShippingCity '; 
            
            CaseFieldNames +=' ,Account.BillingStreet '; 
            CaseFieldNames +=' ,Account.BillingState '; 
            CaseFieldNames +=' ,Account.BillingPostalCode '; 
            CaseFieldNames +=' ,Account.BillingCountry '; 
            CaseFieldNames +=' ,Account.BillingCity  '; 
            
            CaseFieldNames +=' ,SVMXC__Component__r.SVMXC__Zip__c '; 
            CaseFieldNames +=' ,SVMXC__Component__r.SVMXC__Street__c '; 
            CaseFieldNames +=' ,SVMXC__Component__r.SVMXC__State__c '; 
            CaseFieldNames +=' ,SVMXC__Component__r.SVMXC__Country__c '; 
            CaseFieldNames +=' ,SVMXC__Component__r.SVMXC__City__c  '; 
            CaseFieldNames +=' ,SVMXC__Component__r.SVMXC__Site__c  '; 
            
            CaseFieldNames +=' ,Account.Name '; 
                        
                // If multi-currency is enabled in an org but CurrencyIsoCode is not specified
                // in the field map, we must mandatorily copy the field from source to target
            if (containsCurrField == false && userinfo.isMultiCurrencyOrganization())  
                CaseFieldNames+= ' , CurrencyIsoCode ';

        String SOQLHeader;
        try{        
           
            SOQLHeader = '  SELECT '+CaseFieldNames+' FROM Case where Id=\''+caseID+'\''; 
            CaseHeader = Database.query(SOQLHeader);
            
            //Populate fields and corresponding values using fieldMap 
                
             for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
             {
                 String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                 String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
               
                 Object souFldVal = CaseHeader.get(sourceFieldName);                 
                 if(souFldVal != null)
                 {
                    NewRMASHPHeader.put(targetFieldName, souFldVal);
                 }  
             }
                
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));}

    }
    
/*******************************************************************************************************************
Methods to retrieve Location Record
*******************************************************************************************************************/
     
    public SVMXC__Site__c getLocationFromId(String locId) {         
            String SOQLHeader;
            SVMXC__Site__c  LocRecord = new SVMXC__Site__c();
            try{
                
                SOQLHeader = '  SELECT '+LocationFieldNames+' FROM SVMXC__Site__c where Id=\''+locId+'\''; 
                LocRecord= Database.query(SOQLHeader);
                if(LocRecord != null) 
                    return LocRecord;  
            } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));}
            
          return null;            
    }  
  
  
/*******************************************************************************************************************
Method used to display/hide pageBlock Table column headings     
*******************************************************************************************************************/   
    public Boolean getDisplayTableColumns() {       
        if (TempRMASHPDetailArray.size()==0)
            {
            CheckAllLines = false;
            return false;
            }
        else
            return true;        
    }      
/*******************************************************************************************************************
Methods for commandButtons
*******************************************************************************************************************/
     public void setAddressForSourceLoc()
        {
        // Populating Source Address fields
       if(NewRMASHPHeader.SVMXC__Source_Location__c !=null)
                {
                String AddressFieldType='Source';
                SVMXC__Site__c Loc = new SVMXC__Site__c();                              
                Loc = getLocationFromId (NewRMASHPHeader.SVMXC__Source_Location__c);                    
                if(Loc != null)           populateAddress( AddressFieldType , Loc.SVMXC__Street__c,  Loc.SVMXC__City__c,  Loc.SVMXC__State__c,  Loc.SVMXC__Zip__c,  Loc.SVMXC__Country__c, Loc.Id);
                }
       // return null;    
        }
         public void setAddressForTargetLoc()
        {
       // Populating Destination Address fields  
        if(NewRMASHPHeader.SVMXC__Destination_Location__c !=null)        
                {
                String AddressFieldType ='Destination';                 
                SVMXC__Site__c Loc = new SVMXC__Site__c();                              
                Loc = getLocationFromId (NewRMASHPHeader.SVMXC__Destination_Location__c);                 
                if(Loc != null)   populateAddress( AddressFieldType , Loc.SVMXC__Street__c,  Loc.SVMXC__City__c,  Loc.SVMXC__State__c,  Loc.SVMXC__Zip__c,  Loc.SVMXC__Country__c, Loc.Id);
                }
                           
        }        
           
    public void setAddress(){
        
         // Populating Destination Address fields
        String AddressFieldType='Destination';
        Location=null;         
        clearAddress(AddressFieldType); 
        if( SelectedAddressType =='Account Shipping Address' && CaseHeader.Account!=NULL)          
            populateAddress( AddressFieldType, CaseHeader.Account.ShippingStreet ,  CaseHeader.Account.ShippingCity,  CaseHeader.Account.ShippingState,  CaseHeader.Account.ShippingPostalCode,  CaseHeader.Account.ShippingCountry, null);  
            
        if( SelectedAddressType =='Account Billing Address' && CaseHeader.Account!=NULL)
            populateAddress(  AddressFieldType, CaseHeader.Account.BillingStreet,  CaseHeader.Account.BillingCity ,  CaseHeader.Account.BillingState,  CaseHeader.Account.BillingPostalCode,  CaseHeader.Account.BillingCountry, null);
                
        if( SelectedAddressType =='Contact Mailing Address' && CaseHeader.Contact!=NULL)
            populateAddress(  AddressFieldType, CaseHeader.Contact.MailingStreet,  CaseHeader.Contact.MailingCity ,  CaseHeader.Contact.MailingState,  CaseHeader.Contact.MailingPostalCode,  CaseHeader.Contact.MailingCountry , null); 
            
        if( SelectedAddressType =='Contact Other Address' && CaseHeader.Contact!=NULL)
            populateAddress(  AddressFieldType, CaseHeader.Contact.OtherStreet,  CaseHeader.Contact.OtherCity,  CaseHeader.Contact.OtherState,  CaseHeader.Contact.OtherPostalCode,  CaseHeader.Contact.OtherCountry, null );

        if( SelectedAddressType =='Installed Product Address' && CaseHeader.SVMXC__Component__c != null){ //By Gm on 20Jan10: Addded addition Parameter to send SiteId
              populateAddress(  AddressFieldType, 
                                CaseHeader.SVMXC__Component__r.SVMXC__Street__c,
                                CaseHeader.SVMXC__Component__r.SVMXC__City__c,  
                                CaseHeader.SVMXC__Component__r.SVMXC__State__c,  
                                CaseHeader.SVMXC__Component__r.SVMXC__Zip__c,  
                                CaseHeader.SVMXC__Component__r.SVMXC__Country__c, 
                                CaseHeader.SVMXC__Component__r.SVMXC__Site__c);
        }
        setDisableSourceAddress(true);
        if  ( SelectedAddressType ==getTAG056())// || SelectedAddressType ==null)
              {
                clearAddress(AddressFieldType);
                setDisableSourceAddress(false);
              }
    }
        
        
      public void populateAddress(String AddressFieldType ,String Street, String City, String State, String Zip, String Country, String locId)
        {
            if (AddressFieldType=='Destination')
                {
                if (Street != null)
                    NewRMASHPHeader.SVMXC__Destination_Street__c = Street;
                if (City != null)
                    NewRMASHPHeader.SVMXC__Destination_City__c  = City ;
                if (State != null)
                    NewRMASHPHeader.SVMXC__Destination_State__c=  State ; 
                if (Zip != null)
                    NewRMASHPHeader.SVMXC__Destination_Zip__c= Zip ; 
                if (Country != null)
                    NewRMASHPHeader.SVMXC__Destination_Country__c= Country ; 
                if (locId != null) //By GM 20Jan10
                    NewRMASHPHeader.SVMXC__Destination_Location__c = locId ; 
                }

            if( NewRMASHPHeader.SVMXC__Destination_Country__c == null) NewRMASHPHeader.SVMXC__Destination_Country__c = defDesCountry;

            if (AddressFieldType=='Source')
                {
                if (Street !=null)
                    NewRMASHPHeader.SVMXC__Source_Street__c = Street;
                if (City != null)
                    NewRMASHPHeader.SVMXC__Source_City__c  = City ;
                if (State != null)
                    NewRMASHPHeader.SVMXC__Source_State__c=  State ; 
                 if (Zip != null)
                    NewRMASHPHeader.SVMXC__Source_Zip__c= Zip ; 
                if (Country != null)
                    NewRMASHPHeader.SVMXC__Source_Country__c= Country ; 
                if (locId != null) //By GM 20Jan10
                    NewRMASHPHeader.SVMXC__Source_Location__c = locId ; 
                }
        }
     
        
        
      public void clearAddress(String AddressFieldType)
        {
          if (AddressFieldType=='Destination')
            {  
            NewRMASHPHeader.SVMXC__Destination_Street__c= '';
            NewRMASHPHeader.SVMXC__Destination_City__c  = '';
            NewRMASHPHeader.SVMXC__Destination_State__c=  '';
            NewRMASHPHeader.SVMXC__Destination_Zip__c= '';
            NewRMASHPHeader.SVMXC__Destination_Country__c='';
            NewRMASHPHeader.SVMXC__Destination_Location__c= null;  //By GM 20Jan10
            }
          if (AddressFieldType=='Source')
            {
            NewRMASHPHeader.SVMXC__Source_Street__c= '';
            NewRMASHPHeader.SVMXC__Source_City__c  = '';
            NewRMASHPHeader.SVMXC__Source_State__c=  '';
            NewRMASHPHeader.SVMXC__Source_Zip__c= '';
            NewRMASHPHeader.SVMXC__Source_Country__c='';
            NewRMASHPHeader.SVMXC__Source_Location__c= null;   //By GM 20Jan10
            }
        }       
        
   public PageReference Cancel() {
        PageReference scPage = new PageReference('/' + caseID);
        scPage.setRedirect(true);
        return scPage;             
    }
   public PageReference ClearWarnings(){
            WarningDisplayed=true;
            WarningMessages.clear();
            return AddRMASHPHeader();
        }
      public PageReference AddRMASHPHeader(){
           
            if(isValidData()==true && getshowWarnings()==false)
                {
                try{ 
                    RecordType HeaderRecordType = getRecordType(selectedRecordType,'SVMXC__RMA_Shipment_Order__c');
                    if( HeaderRecordType != null)
                    {   
                    NewRMASHPHeader.RecordTypeId =HeaderRecordType.Id;//getRecordType(selectedRecordType,'SVMXC__RMA_Shipment_Order__c').Id;
                    //insert NewRMASHPHeader;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( NewRMASHPHeader, COMM_SecurityUtils.Access.Createable ) ) {
                        //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                        insert NewRMASHPHeader;
                    } else {
                        ValidRecords = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    
                    for(SVMXC__RMA_Shipment_Line__c ListObj :TempRMASHPDetailArray)
                        {
                        if(TargetLineRecordType!=null){
                            ListObj.RecordTypeId  = TargetLineRecordType.Id;
                            ListObj.SVMXC__RMA_Shipment_Order__c    = NewRMASHPHeader.Id;                     
                            //insert ListObj;
                            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( ListObj, COMM_SecurityUtils.Access.Createable ) ) {
                                //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                                insert ListObj;
                            } else {
                                ValidRecords = false;
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                                return null;
                            }
                        }else{
                            ValidRecords = false;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG053()));
                        }
                     }
                        
                    PageReference newPage = new PageReference('/' + NewRMASHPHeader.Id);
                    newPage.setRedirect(true);
                    return newPage; 
                    }else{
                        ValidRecords = false; 
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG053()));
                    } 
                } catch (Exception e)
                { 
                    system.debug('This catch bock');
                    ValidRecords = false; ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));}                               
                }            
            return null;        
        }
   
    public PageReference AddLine()
        {       
         SVMXC__RMA_Shipment_Line__c newListLine =  new SVMXC__RMA_Shipment_Line__c();  ////  [Select id, SVMXC__Select__c, SVMXC__Product__c, SVMXC__Use_Price_From_Pricebook__c, SVMXC__Serial_Number__c, SVMXC__Actual_Quantity2__c, SVMXC__Line_Price2__c, SVMXC__Discount_Percentage__c, SVMXC__Expected_Ship_Date__c from SVMXC__RMA_Shipment_Line__c where id=:'a0470000008uswM'];  //

         if (Setng_usePriceFromPriceBook.toUpperCase() =='TRUE')
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  true;                
         else
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  false;     
         
         //newListLine.SVMXC__Expected_Ship_Date__c=Date.today();
         TempRMASHPDetailArray.add(newListLine);  
       //  System.debug('Testingadd>>>'+ TempRMASHPDetailArray);
                          
        return null;
        } 
       
  public PageReference RemoveLine()
        {  
        List<Integer> selectedLines = new List<Integer>();
        Integer i;      
         for (i=0;i<TempRMASHPDetailArray.size();i++)
            {
                if (TempRMASHPDetailArray.get(i).SVMXC__Select__c==true)
                    {
                        selectedLines.add(i);
                    }
            }
          if (selectedLines.size()<= 0)
            {
            DisplayBlockLevelMessage = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG018()));            
            return null;    
          }else
            DisplayBlockLevelMessage = false;
         selectedLines.sort();          
         for (i=selectedLines.size()-1;i>=0;i--)
            {
                TempRMASHPDetailArray.remove(selectedLines.get(i));
            }
           // System.debug('Testingdelete>>>'+ TempRMASHPDetailArray);
        return null;
        } 
    public PageReference UpdateLineRecord(){        
                for (SVMXC__RMA_Shipment_Line__c line : TempRMASHPDetailArray)
                            {
/*                            if ((line.Product__c ==null)&&(line.Serial_Number__c!=null))
                                line.Product__c = SVMX_getProductIdFromIB(line.Serial_Number__c);
*/                                
                            
                            if ((line.Product__c !=null)&& (line.SVMXC__Use_Price_From_Pricebook__c ==true))
                                {
                                PricebookEntry pbe = new PricebookEntry();
                                
                              
                                    if(userinfo.isMultiCurrencyOrganization())
                                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, string.valueOf(CaseHeader.get('CurrencyIsoCode')), line.Product__c);
                                    else
                                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, null, line.Product__c);
                             
                                     if (pbe !=null)
                                    line.Line_Price2__c =pbe.UnitPrice;     
                                }
                            }           
            return null;
        }   

    public Boolean isValidData()
        {
        ValidRecords = true;
        Boolean validLine= false;
        ErrorMessages.clear();
        DisplayBlockLevelMessage = false;         
        
        Boolean IsFromAddressBlank = isBlankLocation(NewRMASHPHeader.SVMXC__Source_Location__c,NewRMASHPHeader.SVMXC__Source_Street__c,  NewRMASHPHeader.SVMXC__Source_City__c,  NewRMASHPHeader.SVMXC__Source_State__c,  NewRMASHPHeader.SVMXC__Source_Zip__c,  NewRMASHPHeader.SVMXC__Source_Country__c);
        Boolean IsToAddressBlank   = isBlankLocation(NewRMASHPHeader.SVMXC__Destination_Location__c,NewRMASHPHeader.SVMXC__Destination_Street__c,  NewRMASHPHeader.SVMXC__Destination_City__c,  NewRMASHPHeader.SVMXC__Destination_State__c,  NewRMASHPHeader.SVMXC__Destination_Zip__c,  NewRMASHPHeader.SVMXC__Destination_Country__c);
        

        validLine = isValidLine();
        system.debug('SETTING VALUETest:'+Setng_ActionOnNoLine);
        if(TempRMASHPDetailArray.size()==0)
                {                       
                if(Setng_ActionOnNoLine.toUpperCase() =='DISALLOW')
                {
                ErrorMessages.add(getTag050()); 
                ValidRecords = false;                          
                }
                        if(Setng_ActionOnNoLine.toUpperCase() =='WARN')
                {               
                if (WarningDisplayed==false)
                    WarningMessages.add(getTag051());
                } 
                }
        
        if (IsFromAddressBlank==true)
            {
            if(Setng_ActionOnBlankFromAddress.toUpperCase() =='DISALLOW')
                {
                AddToErrorsList(getTag019()); 
                ValidRecords = false;        
                }
            if(Setng_ActionOnBlankFromAddress.toUpperCase() =='WARN')
                {
                if (WarningDisplayed==false)                
                    AddToWarningsList(getTag020());                                       
                }
            }
        if (IsToAddressBlank==true)
            {
            if(Setng_ActionOnBlankToAddress.toUpperCase() =='DISALLOW')
                {
                AddToErrorsList(getTag021()); 
                ValidRecords = false;                          
                }
            if(Setng_ActionOnBlankToAddress.toUpperCase() =='WARN')
                {               
                if (WarningDisplayed==false)
                    AddToWarningsList(getTag022());
                }
            }
        if(validLine !=true)
            {                           
            //ErrorMessages.add(getTag023());
            ValidRecords = false;                                                                 
            }
            
        DisplayErrorsNWarnings();
                    
        return ValidRecords;    
        }
        
     public Boolean isBlankLocation(String LocationName,String Street, String City, String State, String Zip, String Country)
        {
            Boolean isBlank=true;
            if (LocationName!=null || Street!=null || City!=null ||  State!=null ||  Zip!=null ||  Country!=null )
                isBlank=false;
            return isBlank;
        }  
    public Boolean isValidLine(){

            Boolean isValidRecord =true;
            for(SVMXC__RMA_Shipment_Line__c ListObj :TempRMASHPDetailArray)
                {      
                    if( (ListObj.SVMXC__Expected_Quantity2__c == null || ListObj.SVMXC__Expected_Quantity2__c <0) )//&& ListObj.SVMXC__Select__c==true)
                        {  
                       
                        //ListObj.SVMXC__Expected_Quantity2__c.addError(getTag023()); 
                         ErrorMessages.add(getTag023());                                         
                        isValidRecord =false;                      
                        //break;
                        }
                    if (ListObj.SVMXC__Product__c == null )
                        {                         
                        //ListObj.SVMXC__Product__c.addError(getTag046());
                        ErrorMessages.add(getTag046());                                         
                        isValidRecord =false;                      
                        //break;
                        }                        
                }
            return isValidRecord;
        }
   
/*******************************************************************************************************************
 Method to get RecordType
*******************************************************************************************************************/
 
    public RecordType getRecordType(String Name,String SobjectType)
    {
       RecordType rType;
        try
        {
            //Changed to the static Query due to security review 2010 on 22/10/2010 by amar
            //String SOQL  = 'SELECT Id  FROM RecordType  where SobjectType  =\''+SobjectType+'\' AND Name=\''+name+'\' ';
            //rType = Database.query(SOQL);
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
             rType = [SELECT Id FROM RecordType where SobjectType =: SobjectType AND Name =: name];
        }catch (Exception e){ 
           //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));
           }   
        return rType;
    }
/*******************************************************************************************************************
Object/Methods  to retrieve Settings and Translation Tag Values
*******************************************************************************************************************/

      public String getTAG001(){ return  system.label.PORD002_TAG001;}  //Create Shipment Order      
      public String getTAG002(){ return  system.label.PORD002_TAG002;}   //Create Shipment Order for      
      public String getTAG003(){ return  system.label.PORD002_TAG003;}  //Create Shipment Order Help      
      public String getTAG004(){ return  system.label.PORD002_TAG004;}  //Cancel
      //public String getTAG005(){ return  system.label.PORD002_TAG005')?svmxTagList.get('TAG005') : '';}  //Add Address      
      public String getTAG006(){ return system.label.PORD002_TAG006;}   //From Location      
      public String getTAG007(){ return system.label.PORD002_TAG007;}   //To Location      
      public String getTAG008(){ return system.label.PORD002_TAG008;}  //Order Lines      
      public String getTAG009(){ return system.label.PORD002_TAG009;}  //Add Line      
      public String getTAG010(){ return system.label.PORD002_TAG010;}  //Delete Lines      
     /*
      public String getTAG011(){ return system.label.PORD002_TAG011')?svmxTagList.get('TAG011') : '';}  //Product Name      
      public String getTAG012(){ return system.label.PORD002_TAG012')?svmxTagList.get('TAG012') : '';}  //Serial Number      
      public String getTAG013(){ return system.label.PORD002_TAG013')?svmxTagList.get('TAG013') : '';}  //Line Quantity      
      public String getTAG014(){ return system.label.PORD002_TAG014')?svmxTagList.get('TAG014') : '';}   //Line Price      
      public String getTAG015(){ return system.label.PORD002_TAG015')?svmxTagList.get('TAG015') : '';}  //Discount %      
      public String getTAG016(){ return system.label.PORD002_TAG016')?svmxTagList.get('TAG016') : '';}  //Expected Ship Date      
    */ 
      public String getTAG017(){ return system.label.PORD002_TAG017;}   //Error in Create Shipment Order    
      public String getTAG018(){ return system.label.PORD002_TAG018;}   //No Order Line has been selected      
      public String getTAG019(){ return system.label.PORD002_TAG019;}  //Source Address cannot be left blank      
      public String getTAG020(){ return system.label.PORD002_TAG020;}  //Source Address is blank      
      public String getTAG021(){ return system.label.PORD002_TAG021;}  //Destination Address cannot be left blank      
      public String getTAG022(){ return system.label.PORD002_TAG022;}  //Destination Address is blank      
      public String getTAG023(){ return system.label.PORD002_TAG023;}  //Invalid line quantity      
      public String getTAG024(){ return system.label.PORD002_TAG024;}  //Continue
      
      public String getTAG025(){ return system.label.PORD002_TAG025;}  //Settings not available for the SubModule: Create Parts Order Lines
      public String getTAG030(){ return system.label.PORD002_TAG030;}  //PriceBook not found
      public String getTAG036(){ return system.label.PORD002_TAG036;}  //Source Object Record Id not found
      public String getTAG039(){ return system.label.PORD002_TAG039;}  //Get Price/ Product
      public String getTAG040(){ return system.label.PORD002_TAG040;}  //Use Pricebook
      public String getTAG045(){ return system.label.PORD002_TAG045;}//svmxTagList.get('TAG045');}//Select Address Type
      public String getTAG046(){ return system.label.PORD002_TAG046;}//svmxTagList.get('TAG046');}//Please Enter Product
      public String getTAG047(){ return system.label.PORD002_TAG047;}//Save
      public String getTAG048(){ return system.label.PORD002_TAG048;}//Order Lines for
      public String getHLPURL(){ return system.label.PORD002_HLPURL;}//HLPURL 
            
      public String getTAG049(){ return system.label.PORD002_TAG049;}  //Loading...
      public String getTAG050(){ return system.label.PORD002_TAG050;}//Please add lines for Shipment
      public String getTAG051(){ return system.label.PORD002_TAG051;}//No lines have been created for Shipment
      public String getTAG052(){ return system.label.PORD002_TAG052;}//Header RecordType
      public String getTAG053(){ return system.label.PORD002_TAG053;}//Error Message if Record Type doesn't exist in the object
      public String getTAG054(){ return system.label.PORD002_TAG054;}//Line Record Type
      public String getTAG056(){ return system.label.PORD002_TAG056;}//'I will Enter a Location/Address'
}