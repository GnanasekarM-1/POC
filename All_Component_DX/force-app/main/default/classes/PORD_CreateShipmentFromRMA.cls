/*******************************************************************************************************************
ServiceMax Controller Class for the VF Page PORD_CreateShipmentFromRMA:
-------------------------------------------------------------------------------
1. Manages creation of Shipment Parts Order Object with lines
Module      :   PORD
SubModule   :   PORD002
Default Validations on Page Launch:
-----------------------------------
1. Source Record Id cannot be null
*******************************************************************************************************************/
/* Security Scanned */
public  with sharing class PORD_CreateShipmentFromRMA
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
  String rmaID = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('rid'));

// Variable to hold Defualt Pick List Value
  public String defSouCountry;
  public String defDesCountry;

/*******************************************************************************************************************
List to store new lines and the lines which are captured from Source object
*******************************************************************************************************************/
  List<SVMXC__RMA_Shipment_Line__c> TempRMASHPDetailArray = new List<SVMXC__RMA_Shipment_Line__c> ();     
  public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting = new List<SVMXC__ServiceMax_Config_Data__c> ();

  SVMXC__Site__c Location = new SVMXC__Site__c();
  Pricebook2 priceBook = new Pricebook2();
  
  RecordType TargetLineRecordType = new RecordType();
  RecordType SourceLineRecordType = new RecordType();  
  
/*******************************************************************************************************************
New objects which are to be created on submission of the VF Page
*******************************************************************************************************************/

  SVMXC__RMA_Shipment_Order__c NewRMASHPHeader = new SVMXC__RMA_Shipment_Order__c(); 

  
  public SVMXC__RMA_Shipment_Order__c getNewRMAShpipmentHeader() {return NewRMASHPHeader; } 
  public void setNewRMAShpipmentHeader(SVMXC__RMA_Shipment_Order__c obj) {NewRMASHPHeader = obj; } 
  
  public List<SVMXC__RMA_Shipment_Line__c> getNewRMAShpipmentLines() {return TempRMASHPDetailArray; }
  public void setNewRMAShpipmentLines(List<SVMXC__RMA_Shipment_Line__c> objArray) {TempRMASHPDetailArray = objArray; }

/*******************************************************************************************************************
Variables to retrieve Address Type values
*******************************************************************************************************************/
 
  public String SelectedAddressType;
  public String selectedRecordType;
  public String selectedLineRecordType;
    
  public String getSelectedAddressType(){ return SelectedAddressType;}
  public void setSelectedAddressType(String val){SelectedAddressType = val;}
  
  /*
       Setter and Getter for Shipment Header RecordType.
       Changed on 06/18/2009
       Changed By Prashant Singh
   */   
    public String getSelectedRecordType()          { return selectedRecordType;   }
    public void setSelectedRecordType(String rType){ selectedRecordType=rType;    }    
    
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> options = new List<SelectOption>(); 
        String pListRT = AllSubModuleSettings.get('SET018');
        List<String> recordTypeList=new List<String>();
        recordTypeList=pListRT.split(',');      
        for(String  option :recordTypeList){ options.add(new SelectOption(option,option));}     
        return options;
    }
  
    
    /*
       Setter and Getter for Shipment Line RecordType.
       Changed on 06/18/2009
       Changed By Prashant Singh
   */   
    public String getselectedLineRecordType()          { return selectedLineRecordType;   }
    public void setselectedLineRecordType(String rType){ selectedLineRecordType=rType;  }    
    
    public List<SelectOption> getLineRecordTypes(){
        List<SelectOption> options = new List<SelectOption>(); 
        String pListRT = AllSubModuleSettings.get('SET020');
      //  system.debug('pListRT:'+pListRT);
        if(pListRT!=null || pListRT!=''){
            List<String> recordTypeList=new List<String>();
            recordTypeList=pListRT.split(',');      
            for(String  option :recordTypeList){ options.add(new SelectOption(option,option));}     
        }        
        return options;
    }
/*******************************************************************************************************************
Source Object with get method
*******************************************************************************************************************/
  
  
  SVMXC__RMA_Shipment_Order__c RMAHeader ; 
  public SVMXC__RMA_Shipment_Order__c getRMAHeader(){  return RMAHeader;    }
  
  List<SVMXC__RMA_Shipment_Line__c> RMADetailArray;


/*******************************************************************************************************************
Variables to store FieldNames for various Objects
*******************************************************************************************************************/
  String POFieldNames; 
  String POLineFieldNames;   
  String LocationFieldNames; 
    
/*******************************************************************************************************************
Global variables for Settings & Translation
*******************************************************************************************************************/
  SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
  SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
  SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags(); 
  //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('PORD002'); 

  public Map<String, String> AllSubModuleSettings;
  
  String Setng_DefaultFromLocation ;//  Setting for Default From Location 'SET005'
  String Setng_ShpFromRMAMapId;  //Returns MapId for Create Shipment from Work Order
  String Setng_ShpLineFromRMALineMapId;  //Returns MapId for Create Shipment Line from Work Order Line

  String Setng_DefaultAddressType;//Setting for Default Address Type values
  String Setng_ActionOnNoLine ;             //SET006
  String Setng_ActionOnBlankFromAddress ;  
  String Setng_ActionOnBlankToAddress  ;  
  String Setng_HeaderRecTypeName;           //SET014
  String Setng_LineRecTypeName;             //SET015
  String Setng_usePriceFromPriceBook ;      //SET010
  String Setng_ShipmentPriceBook ;          //SET011
  
    public void ValidateAllSettings(){      
        
        
        if (AllSubModuleSettings.size()==0) 
            AddToErrorsList(getTag025()); //Settings not available for the SubModule: Create Parts Order Lines
//SET003
        Setng_ShpFromRMAMapId =AllSubModuleSettings.get('SET003'); ////Returns MapId for Create Shipment from RMA
        if (Setng_ShpFromRMAMapId ==null) 
            AddToErrorsList(getTag025()); //Setting not available for MapId to Create Shipment from RMA
//SET004               
        Setng_DefaultAddressType= AllSubModuleSettings.get('SET004'); //Setting for Default Address Type values
        if (Setng_DefaultAddressType ==null) 
            AddToErrorsList(getTag025()); //Setting not available for Default Address Type values
       
        
/*   
        Setng_DefaultFromLocation =AllSubModuleSettings.get('SET005');  
        if (Setng_DefaultFromLocation ==null) 
            AddToErrorsList(getTag028()); //Setting not available for Default From Location
*/         

//SET006 
        Setng_ActionOnNoLine           = AllSubModuleSettings.get('SET006');  
        if (Setng_ActionOnNoLine ==null) 
            AddToErrorsList(getTag025()); //Setting not available for Action On No Line

        Setng_ActionOnBlankFromAddress = AllSubModuleSettings.get('SET007');  
        if (Setng_ActionOnBlankFromAddress ==null) 
            AddToErrorsList(getTag025()); //Setting not available for Action On Blank From Address
     
        Setng_ActionOnBlankToAddress   = AllSubModuleSettings.get('SET008');  
        if (Setng_ActionOnBlankToAddress ==null) 
            AddToErrorsList(getTag025()); //Setting not available for Action On Blank To Address
            

        Setng_ShpLineFromRMALineMapId = AllSubModuleSettings.get('SET013'); ////Returns MapId for Creating Shipment Line  from RMA  Line
        if (Setng_ShpLineFromRMALineMapId ==null) 
                AddToErrorsList(getTag025()); //Setting not available for MapId to Create Shipment Line from RMA Line


//SET010            
        Setng_usePriceFromPriceBook =AllSubModuleSettings.get('SET010');
        if (Setng_usePriceFromPriceBook==null)
            AddToErrorsList(getTag025());           //Setting not available for the flag usePriceFromPriceBook
            
        if ((Setng_usePriceFromPriceBook!=null)&& (Setng_usePriceFromPriceBook.toUpperCase() !='FALSE'))
        {   
            Setng_ShipmentPriceBook =  AllSubModuleSettings.get('SET011');      
            if (Setng_ShipmentPriceBook ==null)
                AddToErrorsList(getTag025()); //Setting not available for Shipment PriceBook            
            else  
                {
                priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(Setng_ShipmentPriceBook);        
                if(priceBook==null) 
                    AddToErrorsList(getTag030());//PriceBook not found           
                }
        }       


//SET014
        Setng_HeaderRecTypeName = AllSubModuleSettings.get('SET014');  
        if (Setng_HeaderRecTypeName ==null) 
            AddToErrorsList(getTag025()); //Setting not available for :Header Record Type
            
//SET015
        Setng_LineRecTypeName = AllSubModuleSettings.get('SET015');  
        if (Setng_LineRecTypeName ==null) 
            AddToErrorsList(getTag025()); //Setting not available for :Line Record Type                 

//SET019
        selectedRecordType=AllSubModuleSettings.get('SET019');

//SET021
        selectedLineRecordType=AllSubModuleSettings.get('SET021');    
    }


/*******************************************************************************************************************
Global variables   
*******************************************************************************************************************/
  Boolean ValidRecords = true;  
  
     
  Boolean CheckAllLines=false;    
  public Boolean getCheckAllLines() {return CheckAllLines;  }
  public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
  String DefaultLocation;
  
  Boolean showWarnings=false;    
  public Boolean getshowWarnings() {
            if( (ValidRecords == true) && (WarningMessages.size()>0))
                showWarnings=true;
            else
                showWarnings=false;
            return showWarnings;  
            }
  public void setshowWarnings(Boolean sw){showWarnings=sw;}
 
 List<String> ErrorMessages = new  List<String> ();
 List<String> WarningMessages = new  List<String> ();
  public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
  public List<String> getErrorsList() {    return ErrorMessages; }  
            
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
                ValidRecords = false;  
                DisplayBlockLevelMessage = false; 
                for (String msg : ErrorMessages)
                    {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag017(),msg)) ;  
                    }
            }   
        else if(( WarningMessages.size()>0)&&(ValidRecords !=false))    
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
 
  public PORD_CreateShipmentFromRMA()
    {
    if (rmaID ==null){AddToErrorsList(getTag036());}                //Source Object Record Id not found

    AllSubModuleSettings= settings.SVMX_getSettingList('PORD002'); //SubModule: Create Parts Order (Shipment)     
    ValidateAllSettings();  
     
    DisplayErrorsNWarnings();   
     defSouCountry  = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Order__c', 'SVMXC__Source_Country__c');
    defDesCountry = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Order__c', 'SVMXC__Destination_Country__c');

    
    if (ValidRecords == true)   
        {
        RMAHeader = new SVMXC__RMA_Shipment_Order__c(); 
        RMADetailArray = new List<SVMXC__RMA_Shipment_Line__c> ();
        TargetLineRecordType = getRecordType(selectedLineRecordType,'SVMXC__RMA_Shipment_Line__c');
        SourceLineRecordType = getRecordType('RMA','SVMXC__RMA_Shipment_Line__c');
     
        PopulateFieldNames();
        PopulateSourceNTargetObject();
        setSelectedAddressType(Setng_DefaultAddressType); //Setting for Default Address Type values
        NewRMASHPHeader.OwnerId = UserInfo.getUserId();
 
         if(NewRMASHPHeader.SVMXC__Source_Country__c == null ) NewRMASHPHeader.SVMXC__Source_Country__c = defSouCountry;
         if( NewRMASHPHeader.SVMXC__Destination_Country__c == null) NewRMASHPHeader.SVMXC__Destination_Country__c = defDesCountry;
                    

        /* 
        *****NOT REQUIRED*****
        DefaultLocation =Setng_DefaultFromLocation; //Setting for Default From Location. Returns ID for Location
        Location = getLocationFromId (DefaultLocation); 
        
        if(Location !=null)
                NewRMASHPHeader.SVMXC__Source_Location__c=Location.Id ;
                
                
        NewRMASHPHeader.OwnerId = UserInfo.getUserId();
        PageReference pagerefAddress = setAddress();
        */
        //SelectedAddressType = AddTypeArray[0];// Setting the value None- which is the first value in sequence
        
        }
    else
        setDisplayForm(false);
   }

/*******************************************************************************************************************
Methods to Populate Field Names for various objects [Method to optimize the usage of getDescribe() function]
*******************************************************************************************************************/
    public void PopulateFieldNames() { 
  //String POFieldNames; 
  //String POLineFieldNames;   
  //String LocationFieldNames; 
try{        
            //Schema.DescribeSObjectResult souObj = SVMXC__RMA_Shipment_Order__c.sObjectType.getDescribe();
            //Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__RMA_Shipment_Order__c.fields.getMap();

            //build a list of all fieldnames for the object
            //List<String> souObjFieldList = utils.SVMX_getFieldList(souObjfieldMap,true);             
            //POFieldNames = utils.SVMX_getFieldNamesFromList(souObjFieldList);
            
//Populating POLine Field Names
            //Schema.DescribeSObjectResult souObj2 = SVMXC__RMA_Shipment_Line__c.sObjectType.getDescribe();
            //Map<String, SObjectField> souObjfieldMap2 = Schema.SObjectType.SVMXC__RMA_Shipment_Line__c.fields.getMap();

            //build a list of all fieldnames for the object
            //List<String> souObjFieldList2 = utils.SVMX_getFieldList(souObjfieldMap2,true);             
            //POLineFieldNames = utils.SVMX_getFieldNamesFromList(souObjFieldList2);
            
//Populating Location field Names
            Schema.DescribeSObjectResult dsoResultLoc = SVMXC__Site__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMapLoc = Schema.SObjectType.SVMXC__Site__c.fields.getMap();
            //build a list of all fieldnames for the object
            List<String> fieldListLoc = utils.SVMX_getFieldList(fieldMapLoc,true);      
            LocationFieldNames = utils.SVMX_getFieldNamesFromList(fieldListLoc);

        } catch (Exception e){ ValidRecords = false; ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}           
    }  
/*******************************************************************************************************************
Methods to Populate Source Object Data into Target Object
*******************************************************************************************************************/
       
  public void PopulateSourceNTargetObject() { 
            
//Populating the Header
        fieldMapSetting = settings.SVMX_getFieldMapping( Setng_ShpFromRMAMapId);   
        Boolean containsCurrField = false;
        Boolean CopyField = true;
                
        POFieldNames = '';

        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
            {
            CopyField = true;
                    // CurrencyIsoCode must be copied from source to target only if multi-currency is enabled
                    // for the organization
            if (fld.SVMXC__Source_Field_Name__c.equalsIgnoreCase('CurrencyIsoCode'))
                {
                containsCurrField = true;
                if (!userinfo.isMultiCurrencyOrganization()) { CopyField = false; }
                }
            if (fld.SVMXC__Source_Field_Name__c != null && CopyField == true)
                {
                POFieldNames += fld.SVMXC__Source_Field_Name__c + ', ';
                }
             }
        POFieldNames += ' SVMXC__Company__r.Name '; 
        
                // If multi-currency is enabled in an org but CurrencyIsoCode is not specified
                // in the field map, we must mandatorily copy the field from source to target
        if (containsCurrField == false && userinfo.isMultiCurrencyOrganization())  
            POFieldNames += ' , CurrencyIsoCode ';
        
        String SOQLHeader;
        String SOQLDetail;
        try{            
            SOQLHeader = '  SELECT '+POFieldNames+' FROM SVMXC__RMA_Shipment_Order__c where Id=\''+rmaID+'\''; 
            RMAHeader = Database.query(SOQLHeader);
            //Populate fields and corresponding values using fieldMap 
                
             for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
             {
                 String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                 String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
               
                 Object souFldVal = RMAHeader.get(sourceFieldName);                 
                 if(souFldVal != null)
                 {
                    NewRMASHPHeader.put(targetFieldName, souFldVal);
                 }  
             }

//Populating the Lines
        fieldMapSetting = settings.SVMX_getFieldMapping( Setng_ShpLineFromRMALineMapId); 
        
    POLineFieldNames = '';
     for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
     {
         if (fld.SVMXC__Source_Field_Name__c != null) POLineFieldNames += fld.SVMXC__Source_Field_Name__c + ', ';
     }
            POLineFieldNames +=' SVMXC__Product__r.Name,SVMXC__Product__r.ProductCode ,SVMXC__Serial_Number__r.Name, RecordTypeId ';          

            SOQLDetail = '  SELECT '+POLineFieldNames+' FROM SVMXC__RMA_Shipment_Line__c  where SVMXC__RMA_Shipment_Order__c=\''+rmaID+'\''; 
            RMADetailArray = Database.query(SOQLDetail);
            
            //Populate fields and corresponding values using fieldMap 
             
            for (SVMXC__RMA_Shipment_Line__c RMALine : RMADetailArray)
            {
                if(RMALine.RecordTypeId== SourceLineRecordType.Id)
                    {
                    SVMXC__RMA_Shipment_Line__c TempLineObj = new SVMXC__RMA_Shipment_Line__c();
                    //TempLineObj.SVMXC__Select__c = true;
                
                    for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
                        {
                        String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                        String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
               
                        Object souFldVal = RMALine.get(sourceFieldName);                 
                        if(souFldVal != null)
                            {
                            TempLineObj.put(targetFieldName, souFldVal);
                            }//if2  
                        }//for2
                TempRMASHPDetailArray.add(TempLineObj);
                    }//if1
            }//for1   
             
                
        } catch (Exception e){ValidRecords = false;  ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}
        
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
            } catch (Exception e){ValidRecords = false;  ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}
                return LocRecord;            
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
            populateAddress( AddressFieldType , Loc.SVMXC__Street__c,  Loc.SVMXC__City__c,  Loc.SVMXC__State__c,  Loc.SVMXC__Zip__c,  Loc.SVMXC__Country__c);
            }
            
        }
     public void setAddressForTargetLoc()
        {
       // Populating Destination Address fields  
        if(NewRMASHPHeader.SVMXC__Destination_Location__c !=null)        
            {
            String AddressFieldType ='Destination';             
            SVMXC__Site__c Loc = new SVMXC__Site__c();                          
            Loc = getLocationFromId (NewRMASHPHeader.SVMXC__Destination_Location__c);                 
            populateAddress( AddressFieldType , Loc.SVMXC__Street__c,  Loc.SVMXC__City__c,  Loc.SVMXC__State__c,  Loc.SVMXC__Zip__c,  Loc.SVMXC__Country__c);
            }
                                
        }        
  
        
     public void populateAddress(String AddressFieldType ,String Street, String City, String State, String Zip, String Country)
        {
            if (AddressFieldType=='Destination')
                {
                if (Street !=null)
                    NewRMASHPHeader.SVMXC__Destination_Street__c = Street;
                if (City !=null)
                    NewRMASHPHeader.SVMXC__Destination_City__c  = City ;
                if (State !=null)
                    NewRMASHPHeader.SVMXC__Destination_State__c=  State ; 
                if (Zip !=null)
                    NewRMASHPHeader.SVMXC__Destination_Zip__c= Zip ; 
                if (Country !=null)
                    NewRMASHPHeader.SVMXC__Destination_Country__c= Country ; 
                }
            if (AddressFieldType=='Source')
                {
                if (Street !=null)
                    NewRMASHPHeader.SVMXC__Source_Street__c = Street;
                if (City !=null)
                    NewRMASHPHeader.SVMXC__Source_City__c  = City ;
                if (State !=null)
                    NewRMASHPHeader.SVMXC__Source_State__c=  State ; 
                 if (Zip !=null)
                    NewRMASHPHeader.SVMXC__Source_Zip__c= Zip ; 
                if (Country !=null)
                    NewRMASHPHeader.SVMXC__Source_Country__c= Country ; 
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
            }
          if (AddressFieldType=='Source')
            {
            NewRMASHPHeader.SVMXC__Source_Street__c= '';
            NewRMASHPHeader.SVMXC__Source_City__c  = '';
            NewRMASHPHeader.SVMXC__Source_State__c=  '';
            NewRMASHPHeader.SVMXC__Source_Zip__c= '';
            NewRMASHPHeader.SVMXC__Source_Country__c='';
            }
        }       
   public PageReference Cancel() {
        PageReference scPage = new PageReference('/' + rmaID);
        scPage.setRedirect(true);
        return scPage;             
    }
   public PageReference ClearWarnings()
        {
            WarningDisplayed=true;
            WarningMessages.clear();
            return AddRMASHPHeader();
        }
   public PageReference AddRMASHPHeader(){

        if(isValidData()==true && getshowWarnings()==false)
        {
        try{    
                RecordType HeaderRecordType = getRecordType(selectedRecordType,'SVMXC__RMA_Shipment_Order__c');
                if( HeaderRecordType != null){ 
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
                            if(TargetLineRecordType!=null)
                            {
                                ListObj.RecordTypeId = TargetLineRecordType.Id;
                                ListObj.SVMXC__RMA_Shipment_Order__c = NewRMASHPHeader.Id; 
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
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,getTAG053()));
                            } 
                    }
                    PageReference newPage = new PageReference('/' + NewRMASHPHeader.Id);
                    newPage.setRedirect(true);
                    return newPage;
                }else{
                    ValidRecords = false; 
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,getTAG053()));
                }
           } catch (Exception e){ValidRecords = false;  ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}                               
        }//if            
    return null;        
    }
 
     public PageReference AddLine()
        {       
         SVMXC__RMA_Shipment_Line__c newListLine =  new SVMXC__RMA_Shipment_Line__c();   //[Select id, Select__c, Product__c, Use_Price_From_Pricebook__c, Serial_Number__c, Actual_Quantity2__c, Line_Price2__c, Discount_Percentage__c, Expected_Ship_Date__c from SVMXC__RMA_Shipment_Line__c limit 1]; //

         if (Setng_usePriceFromPriceBook.toUpperCase() =='TRUE')
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  true;                
         else
            newListLine.SVMXC__Use_Price_From_Pricebook__c=  false;               
         TempRMASHPDetailArray.add(newListLine);         
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
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017(),getTAG018()));            
            return null;    
            }
          else
            DisplayBlockLevelMessage = false;
         selectedLines.sort();          
         for (i=selectedLines.size()-1;i>=0;i--)
            {
                TempRMASHPDetailArray.remove(selectedLines.get(i));
            }
        return null;
        } 
    public PageReference UpdateLineRecord(){        
           for (SVMXC__RMA_Shipment_Line__c line : TempRMASHPDetailArray)
                        {                            
                        if ((line.Product__c !=null)&& (line.SVMXC__Use_Price_From_Pricebook__c ==true))
                             {
                             PricebookEntry pbe = new PricebookEntry();
                             try{
                                 if(userinfo.isMultiCurrencyOrganization())
                                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook,string.valueOf(RMAHeader.get('CurrencyIsoCode')), line.Product__c);  
                                 else
                                    pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, null, line.Product__c);                                                   
                             }catch(Exception e){
                                 ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));
                             }
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
        Boolean NoRecordsSelected = true;
        
        Boolean IsFromAddressBlank = isBlankLocation(NewRMASHPHeader.SVMXC__Source_Location__c,NewRMASHPHeader.SVMXC__Source_Street__c,  NewRMASHPHeader.SVMXC__Source_City__c,  NewRMASHPHeader.SVMXC__Source_State__c,  NewRMASHPHeader.SVMXC__Source_Zip__c,  NewRMASHPHeader.SVMXC__Source_Country__c);
        Boolean IsToAddressBlank   = isBlankLocation(NewRMASHPHeader.SVMXC__Destination_Location__c,NewRMASHPHeader.SVMXC__Destination_Street__c,  NewRMASHPHeader.SVMXC__Destination_City__c,  NewRMASHPHeader.SVMXC__Destination_State__c,  NewRMASHPHeader.SVMXC__Destination_Zip__c,  NewRMASHPHeader.SVMXC__Destination_Country__c);
    
        validLine = isvalidLine();
        
       /* for (SVMXC__RMA_Shipment_Line__c ListObj :TempRMASHPDetailArray)
            {
            if(ListObj.SVMXC__Select__c==true)  
                {
                    NoRecordsSelected = false;
                    break;
                }
            }
        */
        
        if(TempRMASHPDetailArray.size()>0)
             NoRecordsSelected = false;
             
        if  (NoRecordsSelected==true)
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
    // Returns false if a line is selected and Qty value is invalid      
    public Boolean isvalidLine()
        {
        Boolean isValidRecord =true;
        for(SVMXC__RMA_Shipment_Line__c ListObj :TempRMASHPDetailArray)
            {      
            if( (ListObj.SVMXC__Expected_Quantity2__c == null || ListObj.SVMXC__Expected_Quantity2__c <0) )
                {
                ListObj.SVMXC__Expected_Quantity2__c.addError(getTag023());                                         
                isValidRecord =false;                      
                //break;
                }
            if (ListObj.SVMXC__Product__c == null )
                {                         
                 ListObj.SVMXC__Product__c.addError(getTag046());                                         
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
        String SOQL  = 'SELECT Id  FROM RecordType  where SobjectType  =\''+String.escapeSingleQuotes(SobjectType)+'\' AND Name=\''+String.escapeSingleQuotes(Name)+'\' ';        
        try{
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            rType = Database.query(SOQL); 
        } catch (Exception e){ 
            //ValidRecords = false; 
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
      public String getTAG006(){ return  system.label.PORD002_TAG006;}   //From Location      
      public String getTAG007(){ return  system.label.PORD002_TAG007;}   //To Location      
      public String getTAG008(){ return  system.label.PORD002_TAG008;}  //Order Lines      
      public String getTAG009(){ return  system.label.PORD002_TAG009;}  //Add Line      
      public String getTAG010(){ return  system.label.PORD002_TAG010;}  //Delete Lines      

      public String getTAG017(){ return  system.label.PORD002_TAG017;}   //Error in Create Shipment Order    
      public String getTAG018(){ return  system.label.PORD002_TAG018;}   //No Order Line has been selected      
      public String getTAG019(){ return  system.label.PORD002_TAG019;}  //Source Address cannot be left blank      
      public String getTAG020(){ return  system.label.PORD002_TAG020;}  //Source Address is blank      
      public String getTAG021(){ return  system.label.PORD002_TAG021;}  //Destination Address cannot be left blank      
      public String getTAG022(){ return  system.label.PORD002_TAG022;}  //Destination Address is blank      
      public String getTAG023(){ return  system.label.PORD002_TAG023;}  //Invalid line quantity      
      public String getTAG024(){ return  system.label.PORD002_TAG024;}  //Continue
      
      public String getTAG025(){ return  system.label.PORD002_TAG025;}  //Settings not available for the SubModule: Create Parts Order Lines
      public String getTAG030(){ return  system.label.PORD002_TAG030;}  //PriceBook not found
      public String getTAG039(){ return  system.label.PORD002_TAG039;}  //Get Price/ Product      
      public String getTAG040(){ return  system.label.PORD002_TAG040;}  //Use Pricebook
      public String getTAG036(){ return  system.label.PORD002_TAG036;}  //Source Object Record Id not found
      public String getTAG045(){ return system.label.PORD002_TAG045;}//svmxTagList.get('TAG045');}//Select Address Type
      public String getTAG046(){ return system.label.PORD002_TAG046;}//Please Enter Product
      public String getTAG047(){ return system.label.PORD002_TAG047;}//svmxTagList.get('TAG047');}//Save
      public String getTAG048(){ return system.label.PORD002_TAG048;}//svmxTagList.get('TAG048');}//Order Lines for 
      public String getTAG049(){ return system.label.PORD002_TAG049;}  //Loading...
      public String getTAG050(){ return system.label.PORD002_TAG050;}//Please add lines for Shipment
      public String getTAG051(){ return system.label.PORD002_TAG051;}//No lines have been created for Shipment
      public String getTAG052(){ return system.label.PORD002_TAG052;}//Header Record Types
      public String getTAG053(){ return system.label.PORD002_TAG053;}//Error Message if Record Type doesn't exist in the object
      public String getTAG054(){ return system.label.PORD002_TAG054;}//Line Record Type 
      public String getHLPURL() {return system.label.PORD002_HLPURL;}
        
 
     
}