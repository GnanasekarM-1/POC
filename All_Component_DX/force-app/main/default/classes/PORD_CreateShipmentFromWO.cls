/*******************************************************************************************************************
ServiceMax Controller Class for the VF Page PORD_CreateShipmentFromWO:
----------------------------------------------------------------------- 
1. Manages creation of Shipment Parts Order Object with lines
Module      :   PORD
SubModule   :   PORD002

Release Notes: GM 20Jan10: Added logic to populate Site__c reference when populating address from IB
*******************************************************************************************************************/
/* Security Scanned */
public  with sharing class PORD_CreateShipmentFromWO 
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
  String woID = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('wid'));
  
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
  public String SelectedSrcAddressType;
  public String selectedRecordType;  
  public String selectedLineRecordType;
  public integer fromaddresscount=0;
  public Boolean AllowAddline;
  public String AllowLine;
  public Double difference;
  public List<SelectOption> FromOptions = new List<SelectOption>();
  public map<string,string> SrcLocMap = new map<string,string>();
  public List<SVMXC__Service_Order_Line__c> FromaddList = new List<SVMXC__Service_Order_Line__c>();
  public Boolean IsFieldAvail=false;
  public Boolean LsIsFieldAvail=false;
  public String Linestatus = 'Open,Completed,Canceled';
  public String LineStatusQuery;
  public List<String> LinestatusList;
  public Map<String, Schema.SObjectType> allObjs;
  public String getSelectedAddressType(){ return SelectedAddressType;}
  public void setSelectedAddressType(String val){SelectedAddressType = val;}
   
  public String getSelectedSrcAddressType(){ return SelectedSrcAddressType;}
  public void setSelectedSrcAddressType(String val){SelectedSrcAddressType = val;}
  
  public Boolean getAllowAddline(){return AllowAddline;}
  
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
    
    public List<SelectOption> getSrcAddressTypes() 
    {
        return FromOptions;
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
       Setter and Getter for Shipment Line RecordType.
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
      //  system.debug('pListRT:'+pListRT);
        if(pListRT!=null || pListRT!=''){
            List<String> recordTypeList=new List<String>();
            recordTypeList=pListRT.split(',');      
            for(String  option :recordTypeList){ options.add(new SelectOption(option,option));}     
        }        
        return options;
    }

 
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
Source Object with get method
*******************************************************************************************************************/
  
  public SVMXC__Service_Order__c WOHeader  = new SVMXC__Service_Order__c(); 
  public SVMXC__Service_Order__c getWOHeader(){  return WOHeader;    }
  
  List<SVMXC__Service_Order_Line__c> WODetailArray;

/*******************************************************************************************************************
Variables to store FieldNames for various Objects
*******************************************************************************************************************/
  String WOFieldNames; 
  String WOLineFieldNames;   
  String LocationFieldNames; 
    
/*******************************************************************************************************************
Global variables for Settings & Translation
*******************************************************************************************************************/
  SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
  SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
  // SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags(); 
  // public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('PORD002'); 

  public Map<String, String> AllSubModuleSettings;
    
  String Setng_ShpFromWOMapId;              //Returns MapId for Create Shipment from Work Order SET002
  String Setng_DefaultAddressType;          //Setting for Default Address Type values SET004
  String Setng_DefaultFromLocation ;        //  Setting for Default From Location 'SET005'  
  String Setng_ActionOnNoLine ;             //SET006
  String Setng_ActionOnBlankFromAddress ;   //SET007
  String Setng_ActionOnBlankToAddress  ;    //SET008

  String Setng_usePriceFromPriceBook ;      //SET010
  String Setng_ShipmentPriceBook ;          //SET011
  String Setng_ShpLineFromWOLineMapId;      //Returns MapId for Create Shipment Line from Work Order Line SET012
  String Setng_HeaderRecTypeName;           //SET014
  String Setng_LineRecTypeName;             //SET015
  


/*******************************************************************************************************************
Method to validate the availability of all the Settings
*******************************************************************************************************************/
    public void ValidateAllSettings(){  
        
        if (AllSubModuleSettings.size()==0) 
            AddToErrorsList(getTag025()); //Settings not available for the SubModule: Create Parts Order Lines
//SET002            
        Setng_ShpFromWOMapId =AllSubModuleSettings.get('SET002'); //Returns MapId for Create Shipment from Work Order
        if (Setng_ShpFromWOMapId ==null)
            AddToErrorsList(getTag025()); //Setting not available for MapId to Create Shipment from WO
        
//SET004               
        Setng_DefaultAddressType= AllSubModuleSettings.get('SET004'); //Setting for Default Address Type values
        if (Setng_DefaultAddressType ==null) 
            AddToErrorsList(getTag025()); //Setting not available for Default Address Type values
        else
            {   // Populating the array for Picklist values
                SetDefAddTypeRec= settings.SVMX_getSettingDef('PORD002', 'SET004');
                AddTypeValues = SetDefAddTypeRec.get('SET004').SVMXC__VALUES__C;
                AddTypeValues = AddTypeValues.replace('~|~','~');       
                AddTypeArray = AddTypeValues.split('~');                        
            }
                        
//SET005     
        Setng_DefaultFromLocation =AllSubModuleSettings.get('SET005');  
        // if (Setng_DefaultFromLocation ==null) This is not an error HS: 6/13/2009 8:12am IST
        //    AddToErrorsList(getTag025()); //Setting not available for Default From Location

//SET006 
        Setng_ActionOnNoLine           = AllSubModuleSettings.get('SET006');  
        if (Setng_ActionOnNoLine ==null) 
            AddToErrorsList(getTag025()); //Setting not available for Action On No Line
        
//SET007        
        Setng_ActionOnBlankFromAddress = AllSubModuleSettings.get('SET007');  
        if (Setng_ActionOnBlankFromAddress ==null) 
            AddToErrorsList(getTag025()); //Setting not available for Action On Blank From Address
//SET008     
        Setng_ActionOnBlankToAddress   = AllSubModuleSettings.get('SET008');  
        if (Setng_ActionOnBlankToAddress ==null) 
            AddToErrorsList(getTag025()); //Setting not available for Action On Blank To Address
//SET010
        Setng_usePriceFromPriceBook =AllSubModuleSettings.get('SET010');
        if (Setng_usePriceFromPriceBook==null)
            AddToErrorsList(getTag025()); //Setting not available for the flag usePriceFromPriceBook
            
        //if ((Setng_usePriceFromPriceBook!=null)&& (Setng_usePriceFromPriceBook.toUpperCase() !='FALSE'))
        //{   
            Setng_ShipmentPriceBook =  AllSubModuleSettings.get('SET011');      
            if (Setng_ShipmentPriceBook ==null)
                AddToErrorsList(getTag025()); //Setting not available for Shipment PriceBook            
            else  
                {
                priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(Setng_ShipmentPriceBook);        
                if(priceBook==null) 
                    AddToErrorsList(getTag030());//PriceBook not found           
                }
        //}       

//SET012
        Setng_ShpLineFromWOLineMapId = AllSubModuleSettings.get('SET012');  
        if (Setng_ShpLineFromWOLineMapId ==null) 
            AddToErrorsList(getTag025()); //Setting not available for MapId to Create Shipment Line from WO Line

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

//SET022
        if ((AllSubModuleSettings.get('SET023') != null)&&(AllSubModuleSettings.get('SET023') != ''))
        {
        AllowLine = AllSubModuleSettings.get('SET023').toLowerCase();
        system.debug('AllowLine: '+AllowLine);
        }
    }


/*******************************************************************************************************************
Global variables   
*******************************************************************************************************************/
  Boolean ValidRecords = true;
   
  Boolean DisableSourceAddress=true;    
  public Boolean getDisableSourceAddress() {return DisableSourceAddress;  }
  public void setDisableSourceAddress(Boolean val){DisableSourceAddress=val;}
  
  Boolean DisableSrcAddress=true;
  public Boolean getDisableSrcAddress() {return DisableSrcAddress;}
  public void setDisableSrcAddress(Boolean val){DisableSrcAddress=val;}  
    
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
 
  public PORD_CreateShipmentFromWO(){
    //try{
     
    if (woID ==null){AddToErrorsList(getTag036());} //Source Object Record Id not found 
    
    FromaddList = [Select Id,SVMXC__From_Location__c,SVMXC__From_Location__r.Name from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c =:woID and RecordType.Name='Request/Receipt'];
    //getSrcAddressTypes();
    //Set<String> FrmAddSet = SrcLocMap.keySet();
    //string a = FrmAddSet[0];
    //setSelectedSrcAddressType(FrmAddSet[0]);
    //Check Whether SVMXIDEV__Quantity_Shipment_Initiated2__c is there in work detail
     allObjs = Schema.getGlobalDescribe();
     Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
     Schema.SObjectType objT = allObjs.get('Service_Order_Line__c') ;
     objfieldMap = objT.getDescribe().fields.getMap();
     for (String fieldKey : objfieldMap.keySet())
      {
         Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
         Schema.DescribeFieldResult f = fsObj.getDescribe();
         
         if(f.getName() == 'SVMXC__Quantity_Shipment_Initiated2__c')
           {
           IsFieldAvail=true;
           }
         if(f.getName() == 'SVMXC__Line_Status__c')
           {
           LsIsFieldAvail=true;
           }
      }
      LinestatusList = Linestatus.split(',');
      if(LsIsFieldAvail==true)
        LineStatusQuery = 'SVMXC__Line_Status__c = \'Open\' Or SVMXC__Line_Status__c = \'Completed\' Or SVMXC__Line_Status__c = \'Canceled\'';
      /*if((LinestatusList.size()>0)&&(LsIsFieldAvail==true))//Commented to deal with defect 001688
      {
          for(integer i=0;i<LinestatusList.size();i++)
          {
          if(LineStatusQuery != NULL && LineStatusQuery.length() > 0)
            LineStatusQuery += ' OR SVMXC__Line_Status__c = \''+LinestatusList[i]+'\' ';
            else
            LineStatusQuery = ' SVMXC__Line_Status__c = \''+LinestatusList[i]+'\' ';
            //LineStatusQuery = 'SVMXC__Line_Status__c = \'Open\' Or SVMXC__Line_Status__c = \'Completed\' Or SVMXC__Line_Status__c = \'Canceled\''';
            
          }
      }*/
      
        for(SVMXC__Service_Order_Line__c  opt: FromaddList)
        {
          if (!SrcLocMap.ContainsKey(opt.SVMXC__From_Location__c))
          {
            SrcLocMap.put(opt.SVMXC__From_Location__c,opt.SVMXC__From_Location__r.Name);
          try{
            FromOptions.add(new SelectOption(opt.SVMXC__From_Location__r.Id,opt.SVMXC__From_Location__r.Name));
          }catch(exception ex){}
          }
        }
        //commented by pallavi
        FromOptions.add(new SelectOption(getTAG056(),getTAG056()));

    AllSubModuleSettings= settings.SVMX_getSettingList('PORD002'); //SubModule: Create Parts Order (Shipment) 
    system.debug('aaaazzzz');
    ValidateAllSettings();

    DisplayErrorsNWarnings();   
        defSouCountry  = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Order__c', 'SVMXC__Source_Country__c');
       
    defDesCountry = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Order__c', 'SVMXC__Destination_Country__c');
    if (ValidRecords == true)   
        {
        WOHeader = new SVMXC__Service_Order__c(); 
        WODetailArray = new List<SVMXC__Service_Order_Line__c> ();
        TargetLineRecordType = getRecordType(Setng_LineRecTypeName,'SVMXC__RMA_Shipment_Line__c');
        SourceLineRecordType = getRecordType('Request/Receipt','SVMXC__Service_Order_Line__c');
        
        PopulateFieldNames();
        PopulateSourceNTargetObject();
        CreateShipmentLines();
        setSelectedAddressType(Setng_DefaultAddressType); //Setting for Default Address Type values
        if((FromaddList.size()!=0))//&&(FromaddList[0].SVMXC__From_Location__c!=NULL))
        {
            if(FromaddList[0].SVMXC__From_Location__c!=NULL)
            {
                setSelectedSrcAddressType(FromaddList[0].SVMXC__From_Location__c);
            }
            
            else
            {
                ////FromOptions.add(new SelectOption('','')); //Commented by GM 1-Oct-10: We should notadd blank option
                setSelectedSrcAddressType(getTAG056()); 
            }
        }
        
        else
            {
                ////FromOptions.add(new SelectOption(getTAG056(),getTAG056()));
                setSelectedSrcAddressType(getTAG056()); //hh
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG055(),''));
            }
       
        //setSelectedSrcAddressType('a0H70000003m6oz');
        /* RollBacked this Ref Defect #1367
        if(Setng_DefaultFromLocation != null)
            {
            DefaultLocation =Setng_DefaultFromLocation; //Setting for Default From Location. Returns ID for Location
            Location = getLocationFromId (DefaultLocation); 

            if(Location !=null)
                    NewRMASHPHeader.SVMXC__Source_Location__c=Location.Id ;
            }
         */
         
          NewRMASHPHeader.OwnerId = UserInfo.getUserId();
           if(NewRMASHPHeader.SVMXC__Source_Country__c == null ) NewRMASHPHeader.SVMXC__Source_Country__c = defSouCountry;
           if( NewRMASHPHeader.SVMXC__Destination_Country__c == null) NewRMASHPHeader.SVMXC__Destination_Country__c = defDesCountry;
         
        //PageReference pagerefAddress = setAddress();
       
        //PageReference pagerefSourceAddress = setAddressForSourceLoc();                
        setAddressForTargetLoc();
        setAddressForSourceLoc();                
        setAddress();
        setSrcAddress();
        }
    else
        setDisplayForm(false);
   // }
  //  catch(Exception ex){
   //     ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
   // }
   }
 
/*******************************************************************************************************************
Methods to Populate Field Names for various objects [Method to optimize the usage of getDescribe() function]
*******************************************************************************************************************/
    public void PopulateFieldNames() { 
//     WOFieldNames; 
//     LocationFieldNames; 
        try{
            //Schema.DescribeSObjectResult souObj = SVMXC__Service_Order__c.sObjectType.getDescribe();
            //Map<String, SObjectField> souObjfieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();

            //build a list of all fieldnames for the object
            //List<String> souObjFieldList = utils.SVMX_getFieldList(souObjfieldMap,true);             
            //WOFieldNames = utils.SVMX_getFieldNamesFromList(souObjFieldList);
            
            
            
//Population Work Order Line Field Names
            
            Schema.DescribeSObjectResult souObj2 = SVMXC__Service_Order_Line__c.sObjectType.getDescribe();
            Map<String, SObjectField> souObjfieldMap2 = Schema.SObjectType.SVMXC__Service_Order_Line__c.fields.getMap();

            //build a list of all fieldnames for the object
            List<String> souObjFieldList2 = utils.SVMX_getFieldList(souObjfieldMap2,true);             
            WOLineFieldNames = utils.SVMX_getFieldNamesFromList(souObjFieldList2);
            
            WOLineFieldNames +=' , SVMXC__Product__r.Name,SVMXC__Product__r.ProductCode ,SVMXC__Serial_Number__r.Name ';
            //if(IsFieldAvail) //not required as field describe will get all the fields by now
            //WOLineFieldNames +=',SVMXC__Quantity_Shipment_Initiated2__c';
//Populating Location Field Names

            Schema.DescribeSObjectResult dsoLocResult = SVMXC__Site__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMapLoc = Schema.SObjectType.SVMXC__Site__c.fields.getMap();
            //build a list of all fieldnames for the object
            List<String> fieldListLoc = utils.SVMX_getFieldList(fieldMapLoc,true);      
            LocationFieldNames = utils.SVMX_getFieldNamesFromList(fieldListLoc); 
            //tempOP+= 'LocationFieldNames  '+LocationFieldNames;                     
  } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}
    } 
/*******************************************************************************************************************
Methods to Populate Source Object Data into Target Object
*******************************************************************************************************************/
       
    public void PopulateSourceNTargetObject() { 
        Boolean CopyField = true;
        //Populating the Header
        fieldMapSetting = settings.SVMX_getFieldMapping( Setng_ShpFromWOMapId);           
        system.debug('fieldMapSetting'+fieldMapSetting );
        Boolean containsCurrField = false;
        WOFieldNames = '';
        
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
        {
            CopyField = true;
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
                WOFieldNames += fld.SVMXC__Source_Field_Name__c+',';
            }
        }
        
        WOFieldNames +='SVMXC__Contact__r.OtherStreet '; 
        WOFieldNames +=' ,SVMXC__Contact__r.OtherState ';  
        WOFieldNames +=' ,SVMXC__Contact__r.OtherPostalCode '; 
        
        WOFieldNames +=' ,SVMXC__Contact__r.OtherCountry '; 
        WOFieldNames +=' ,SVMXC__Contact__r.OtherCity '; 
        WOFieldNames +=' ,SVMXC__Contact__r.MailingStreet '; 
        WOFieldNames +=' ,SVMXC__Contact__r.MailingState '; 
        WOFieldNames +=' ,SVMXC__Contact__r.MailingPostalCode '; 
        WOFieldNames +=' ,SVMXC__Contact__r.MailingCountry '; 
        WOFieldNames +=' ,SVMXC__Contact__r.MailingCity ';  
        WOFieldNames +=' ,SVMXC__Company__r.ShippingStreet '; 
        WOFieldNames +=' ,SVMXC__Company__r.ShippingState '; 
        WOFieldNames +=' ,SVMXC__Company__r.ShippingPostalCode '; 
        WOFieldNames +=' ,SVMXC__Company__r.ShippingCountry '; 
        WOFieldNames +=' ,SVMXC__Company__r.ShippingCity '; 
            
        WOFieldNames +=' ,SVMXC__Company__r.BillingStreet '; 
        WOFieldNames +=' ,SVMXC__Company__r.BillingState '; 
        WOFieldNames +=' ,SVMXC__Company__r.BillingPostalCode '; 
        WOFieldNames +=' ,SVMXC__Company__r.BillingCountry '; 
        WOFieldNames +=' ,SVMXC__Company__r.BillingCity  '; 
        
        WOFieldNames +=' ,SVMXC__Component__r.SVMXC__Zip__c '; 
        WOFieldNames +=' ,SVMXC__Component__r.SVMXC__Street__c '; 
        WOFieldNames +=' ,SVMXC__Component__r.SVMXC__State__c '; 
        WOFieldNames +=' ,SVMXC__Component__r.SVMXC__Country__c '; 
        WOFieldNames +=' ,SVMXC__Component__r.SVMXC__City__c  '; 
        WOFieldNames +=' ,SVMXC__Component__r.SVMXC__Site__c  ';      
        WOFieldNames +=' ,SVMXC__Company__r.Name '; 

        // in the field map, we must mandatorily copy the field from source to target
        if (containsCurrField == false && userinfo.isMultiCurrencyOrganization())  
            WOFieldNames += ' , CurrencyIsoCode ';
            
       String SOQLHeader;
       try{        
            SOQLHeader = '  SELECT '+WOFieldNames+' FROM SVMXC__Service_Order__c where Id=\''+woID+'\''; 
            WOHeader = Database.query(SOQLHeader);
            //Populate fields and corresponding values using fieldMap 
                
             for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
             {
                 String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                 String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
               
                 Object souFldVal = WOHeader.get(sourceFieldName);                 
                 if(souFldVal != null)
                 {
                    NewRMASHPHeader.put(targetFieldName, souFldVal);
                 }  
             }
      } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}
    }
    
    public void CreateShipmentLines(){
    //Populating the Lines
    try{
    system.debug('LineStatusQuery'+LineStatusQuery);
        String SOQLDetail;
        fieldMapSetting = settings.SVMX_getFieldMapping( Setng_ShpLineFromWOLineMapId); 
            if  ( SelectedSrcAddressType !=getTAG056())
            {
                /* Added next 4 lines newly by hh on 03/12/2010 to solve the error "Argument 1 cannot be null" */
                //if(woID != null && woID != '')
                //  woID = string.escapeSingleQuotes(woID);
                
                //if(SelectedSrcAddressType != null && SelectedSrcAddressType != '')
                //  SelectedSrcAddressType = string.escapeSingleQuotes(SelectedSrcAddressType);
                
                if(WOLineFieldNames != null && WOLineFieldNames != '' && SelectedSrcAddressType != null && SelectedSrcAddressType.length() > 0 )//added newly by hh for defect closure
                {
                    if(LineStatusQuery!=NULL && LineStatusQuery!='')
                        SOQLDetail = 'SELECT '+WOLineFieldNames+' FROM SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c =\''+string.escapeSingleQuotes(woID)+'\' AND SVMXC__From_Location__c =\''+string.escapeSingleQuotes(SelectedSrcAddressType)+'\' and ('+LineStatusQuery +')';
                    else
                        SOQLDetail = 'SELECT '+WOLineFieldNames+' FROM SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c =\''+string.escapeSingleQuotes(woID)+'\' AND SVMXC__From_Location__c =\''+string.escapeSingleQuotes(SelectedSrcAddressType)+'\'';
                    /*if(LineStatusQuery!=NULL && LineStatusQuery!='')
                    {
                        SOQLDetail = 'SELECT '+WOLineFieldNames+' FROM SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c =\''+string.escapeSingleQuotes(woID)+'\' AND SVMXC__From_Location__c =\''+SelectedSrcAddressType+'\' and ('+LineStatusQuery +')';
                    }
                    else
                    SOQLDetail = 'SELECT '+WOLineFieldNames+' FROM SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c =\''+string.escapeSingleQuotes(woID)+'\' AND SVMXC__From_Location__c =\''+SelectedSrcAddressType+'\''; //Changed by hh to deal with security review 10/01/2011*/ 
                    /*if(LineStatusQuery!=NULL && LineStatusQuery!='')
                    {
                        SOQLDetail = 'SELECT '+WOLineFieldNames+' FROM SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c = :woID AND SVMXC__From_Location__c =\''+SelectedSrcAddressType+'\' and ('+LineStatusQuery +')';
                    }
                    else
                    SOQLDetail = 'SELECT '+WOLineFieldNames+' FROM SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c = :woID AND SVMXC__From_Location__c =\''+SelectedSrcAddressType+'\''; //introduced :woid by hh 10/01/2011*/

                    try{
                    WODetailArray = Database.query(SOQLDetail);}
                    catch(exception ex){}
                }
            }
            else
            {
                if(LineStatusQuery!=NULL && LineStatusQuery!='')
                SOQLDetail = 'SELECT '+WOLineFieldNames+' FROM SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c =\''+string.escapeSingleQuotes(woID)+'\' and ('+LineStatusQuery +')'; //Add new data here
                else
                SOQLDetail = 'SELECT '+WOLineFieldNames+' FROM SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c =\''+string.escapeSingleQuotes(woID)+'\''; //Add new data here
                WODetailArray = Database.query(SOQLDetail);
                
            }
            if(AllowLine.toUpperCase()=='TRUE')
            AllowAddline=true;
            else
            AllowAddline=false;
            
            //added by hh, the following for defect closure
             if( AllowAddline == false && (WODetailArray.size() == 0 || WODetailArray == null ) )
             {
                DisplayForm = false;
             }

            //Populate fields and corresponding values using fieldMap 
            TempRMASHPDetailArray.clear(); 
            for (SVMXC__Service_Order_Line__c WODetailLine : WODetailArray)
            {
                if(WODetailLine.RecordTypeId== SourceLineRecordType.Id)
                    {
                    SVMXC__RMA_Shipment_Line__c TempLineObj = new SVMXC__RMA_Shipment_Line__c();

                    for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting)
                        {
                        String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                        String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                        Object souFldVal = WODetailLine.get(sourceFieldName);
                        if(souFldVal != null)
                            {
                                TempLineObj.put(targetFieldName, souFldVal);
                            }//if2  
                     }//for2
                if(IsFieldAvail==true)
                {
                if(WODetailLine.SVMXC__Requested_Quantity2__c!=NULL)    
                    {
                        if(WODetailLine.get('SVMXC__Quantity_Shipment_Initiated2__c')==NULL)
                        difference = WODetailLine.SVMXC__Requested_Quantity2__c;
                        else
                        difference = WODetailLine.SVMXC__Requested_Quantity2__c - (Double)WODetailLine.get('SVMXC__Quantity_Shipment_Initiated2__c');

                        if(difference>0)
                        {
                            TempLineObj.SVMXC__Expected_Quantity2__c = difference;
                            TempRMASHPDetailArray.add(TempLineObj);
                        }
                    }
                }
                else
                {
                    TempLineObj.SVMXC__Expected_Quantity2__c = WODetailLine.SVMXC__Requested_Quantity2__c;
                    TempRMASHPDetailArray.add(TempLineObj);
                
                }
              }//if1
            }//for1
        }
        catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}
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
            } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}
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
            populateAddress( AddressFieldType , Loc.SVMXC__Street__c,  Loc.SVMXC__City__c,  Loc.SVMXC__State__c,  Loc.SVMXC__Zip__c,  Loc.SVMXC__Country__c, null);
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
            populateAddress( AddressFieldType , Loc.SVMXC__Street__c,  Loc.SVMXC__City__c,  Loc.SVMXC__State__c,  Loc.SVMXC__Zip__c,  Loc.SVMXC__Country__c, null);
            }
                                
        }        
    
    public void setSrcAddress()
    {
    setDisableSrcAddress(true);
    String AddressFieldType='Source';
    Location=null;
    clearAddress(AddressFieldType);
    if  ( SelectedSrcAddressType ==getTAG056() )//|| SelectedAddressType ==null)
            {
              clearAddress(AddressFieldType);
              setDisableSrcAddress(false);
              DisableSrcAddress=false;
            }
    else
            {
              SVMXC__Site__c Loc = new SVMXC__Site__c();
              if(((SelectedSrcAddressType!=NULL)&&(SelectedSrcAddressType!=''))&&(SelectedSrcAddressType!=getTAG056()))
              Loc = [select SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Zip__c,SVMXC__Country__c from SVMXC__Site__c where Id=:SelectedSrcAddressType];
              populateAddress(AddressFieldType, Loc.SVMXC__Street__c,  Loc.SVMXC__City__c,  Loc.SVMXC__State__c,  Loc.SVMXC__Zip__c,  Loc.SVMXC__Country__c, Loc.Id);
            }
    //PopulateSourceNTargetObject();
    CreateShipmentLines();
    }
                 
    public void setAddress()
        {
         // Populating Destination Address fields
        String AddressFieldType='Destination';
        Location=null;  
        clearAddress(AddressFieldType);
        system.debug('ADDRESS:'+WOHeader);
        if( SelectedAddressType =='Account Shipping Address' && WOHeader.SVMXC__Company__c!=NULL)          
            populateAddress( AddressFieldType, WOHeader.SVMXC__Company__r.ShippingStreet ,  WOHeader.SVMXC__Company__r.ShippingCity,  WOHeader.SVMXC__Company__r.ShippingState,  WOHeader.SVMXC__Company__r.ShippingPostalCode,  WOHeader.SVMXC__Company__r.ShippingCountry, null);  
            
        if( SelectedAddressType =='Account Billing Address' && WOHeader.SVMXC__Company__c!=NULL)
           populateAddress(  AddressFieldType, WOHeader.SVMXC__Company__r.BillingStreet,  WOHeader.SVMXC__Company__r.BillingCity ,  WOHeader.SVMXC__Company__r.BillingState,  WOHeader.SVMXC__Company__r.BillingPostalCode,  WOHeader.SVMXC__Company__r.BillingCountry, null);
                
        if( SelectedAddressType =='Contact Mailing Address' && WOHeader.SVMXC__Contact__c!=NULL)
           populateAddress(  AddressFieldType, WOHeader.SVMXC__Contact__r.MailingStreet,  WOHeader.SVMXC__Contact__r.MailingCity ,  WOHeader.SVMXC__Contact__r.MailingState,  WOHeader.SVMXC__Contact__r.MailingPostalCode,  WOHeader.SVMXC__Contact__r.MailingCountry, null ); 
        if( SelectedAddressType =='Contact Other Address' && WOHeader.SVMXC__Contact__c!=NULL)
            populateAddress(  AddressFieldType, WOHeader.SVMXC__Contact__r.OtherStreet,  WOHeader.SVMXC__Contact__r.OtherCity,  WOHeader.SVMXC__Contact__r.OtherState,  WOHeader.SVMXC__Contact__r.OtherPostalCode,  WOHeader.SVMXC__Contact__r.OtherCountry , null);
        if( SelectedAddressType =='Installed Product Address' && WOHeader.SVMXC__Component__c != null){ //By Gm on 20Jan10: Addded addition Parameter to send SiteId 
              populateAddress(  AddressFieldType, 
                                WOHeader.SVMXC__Component__r.SVMXC__Street__c,  
                                WOHeader.SVMXC__Component__r.SVMXC__City__c,  
                                WOHeader.SVMXC__Component__r.SVMXC__State__c,  
                                WOHeader.SVMXC__Component__r.SVMXC__Zip__c,  
                                WOHeader.SVMXC__Component__r.SVMXC__Country__c,
                                WOHeader.SVMXC__Component__r.SVMXC__Site__c);
        }
        setDisableSourceAddress(true);
        if  ( SelectedAddressType ==getTAG056() )//|| SelectedAddressType ==null)
            {
              clearAddress(AddressFieldType);       
              setDisableSourceAddress(false);
                if( NewRMASHPHeader.SVMXC__Destination_Country__c == null) NewRMASHPHeader.SVMXC__Destination_Country__c = defDesCountry;

            }
        
        }


     public void populateAddress(String AddressFieldType ,String Street, String City, String State, String Zip, String Country, String locId)
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
                if (locId != null) //By GM 20Jan10
                    NewRMASHPHeader.SVMXC__Destination_Location__c = locId ;                
                }
            if( NewRMASHPHeader.SVMXC__Destination_Country__c == null) NewRMASHPHeader.SVMXC__Destination_Country__c = defDesCountry;
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
                if (locId != null) //By GM 20Jan10
                    NewRMASHPHeader.SVMXC__Source_Location__c = locId ; 
                    system.debug('qqqqqqqq'+NewRMASHPHeader);
                }
            
        }
        
        
     public void clearAddress(String AddressFieldType)
        {
          if (AddressFieldType=='Destination')
            {  
            NewRMASHPHeader.SVMXC__Destination_Street__c = '';
            NewRMASHPHeader.SVMXC__Destination_City__c = '';
            NewRMASHPHeader.SVMXC__Destination_State__c =  '';
            NewRMASHPHeader.SVMXC__Destination_Zip__c = '';
            NewRMASHPHeader.SVMXC__Destination_Country__c ='';
            NewRMASHPHeader.SVMXC__Destination_Location__c = null; //By GM 20Jan10

            }
          if (AddressFieldType=='Source')
            {
            NewRMASHPHeader.SVMXC__Source_Street__c = '';
            NewRMASHPHeader.SVMXC__Source_City__c = '';
            NewRMASHPHeader.SVMXC__Source_State__c =  '';
            NewRMASHPHeader.SVMXC__Source_Zip__c = '';
            NewRMASHPHeader.SVMXC__Source_Country__c = '';
            NewRMASHPHeader.SVMXC__Source_Location__c = null; //By GM 20Jan10
            }
        }  
        
   public PageReference Cancel() {
        PageReference scPage = new PageReference('/' + woID);
        scPage.setRedirect(true);
        return scPage;             
    }
   public PageReference ClearWarnings()
        {
            WarningDisplayed=true;
            WarningMessages.clear();
            return AddRMASHPHeader();
        }
      public PageReference AddRMASHPHeader()
        {
            
        List<SVMXC__Service_Order_Line__c> UpdateWOArray = new List<SVMXC__Service_Order_Line__c> ();
        if(isValidData()==true && getshowWarnings()==false)
        
            {
            try{
                if(IsFieldAvail==true)
                {
                    for (SVMXC__Service_Order_Line__c WL : WODetailArray)
                    {
                        for(SVMXC__RMA_Shipment_Line__c SL :TempRMASHPDetailArray)
                        {
                            if(SL.SVMXC__Product__c==WL.SVMXC__Product__c)
                            {
                                //WL.put('SVMXC__Quantity_Shipment_Initiated2__c',SL.SVMXC__Expected_Quantity2__c);
                                if(WL.get('SVMXC__Quantity_Shipment_Initiated2__c')==NULL)
                                {
                                    WL.put('SVMXC__Quantity_Shipment_Initiated2__c', SL.SVMXC__Expected_Quantity2__c);
                                }
                                else
                                {
                                    WL.put('SVMXC__Quantity_Shipment_Initiated2__c', (Double)WL.get('SVMXC__Quantity_Shipment_Initiated2__c')+SL.SVMXC__Expected_Quantity2__c);
                                }
                            }
                        }
                        UpdateWOArray.add(WL);
                    }
                }
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(UpdateWOArray, COMM_SecurityUtils.Access.Upsertable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                update UpdateWOArray;
                }
                else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
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
                       if(TargetLineRecordType!=null){
                            ListObj.SVMXC__RMA_Shipment_Order__c = NewRMASHPHeader.Id;                        
                            ListObj.RecordTypeId = TargetLineRecordType.Id;
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
              } catch (Exception e){ValidRecords = false; ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}              
            }            
       return null;        
       }
       
    public PageReference AddLine()
        {       
         SVMXC__RMA_Shipment_Line__c newListLine = new SVMXC__RMA_Shipment_Line__c();   
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
          }else
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
                if ((line.SVMXC__Product__c !=null)&&(line.SVMXC__Use_Price_From_Pricebook__c ==true))
                    {
                    PricebookEntry pbe = new PricebookEntry();
                 
                        //Hanish 21/05
                        if(Userinfo.isMultiCurrencyOrganization())
                            pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, string.valueOf(WOHeader.get('CurrencyIsoCode')), line.SVMXC__Product__c);
                        else
                            pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, null, line.SVMXC__Product__c);
                  
                    
                    if (pbe !=null)
                        line.SVMXC__Line_Price2__c =pbe.UnitPrice;                             
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
        validLine                  = isvalidLine();

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
    public Boolean isvalidLine(){
         Boolean isValidRecord =true;
         for(SVMXC__RMA_Shipment_Line__c ListObj :TempRMASHPDetailArray)
         {      
         if ( (ListObj.SVMXC__Expected_Quantity2__c == null || ListObj.SVMXC__Expected_Quantity2__c <0) )//&& ListObj.SVMXC__Select__c==true)
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
 
    public RecordType getRecordType(String name,String SobjectType)
        {
        RecordType rType;
        try
        {
            //Changed to the static Query due to security review 2010 on 22/10/2010 by amar
            //String SOQL  = 'SELECT Id  FROM RecordType  where SobjectType  =\''+SobjectType+'\' AND Name=\''+name+'\' ';  
            //rType = Database.query(SOQL);
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
             rType = [SELECT Id  FROM RecordType  where SobjectType =: SobjectType AND Name =: name];
        } catch (Exception e){ 
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));
        }   
        return rType;
        }
/*******************************************************************************************************************
Object/Methods  to retrieve Settings and Translation Tag Values
*******************************************************************************************************************/
       
      public String getTAG001(){ return  System.Label.PORD002_TAG001;}  //Create Shipment Order      
      public String getTAG002(){ return  System.Label.PORD002_TAG002;}   //Create Shipment Order for      
      public String getTAG003(){ return  System.Label.PORD002_TAG003;}  //Create Shipment Order Help      
      public String getTAG004(){ return  System.Label.PORD002_TAG004;}  //Cancel      
      //public String getTAG005(){ return  System.Label.PORD002_TAG005;}  //Add Address      
      public String getTAG006(){ return  System.Label.PORD002_TAG006;}   //From Location      
      public String getTAG007(){ return  System.Label.PORD002_TAG007;}   //To Location      
      public String getTAG008(){ return  System.Label.PORD002_TAG008;}  //Order Lines      
      public String getTAG009(){ return  System.Label.PORD002_TAG009;}  //Add Line      
      public String getTAG010(){ return  System.Label.PORD002_TAG010;}  //Delete Lines      
      public String getTAG017(){ return  System.Label.PORD002_TAG017;}   //Error in Create Shipment Order    
      public String getTAG018(){ return  System.Label.PORD002_TAG018;}   //No Order Line has been selected      
      public String getTAG019(){ return  System.Label.PORD002_TAG019;}  //Source Address cannot be left blank      
      public String getTAG020(){ return  System.Label.PORD002_TAG020;}  //Source Address is blank      
      public String getTAG021(){ return  System.Label.PORD002_TAG021;}  //Destination Address cannot be left blank      
      public String getTAG022(){ return  System.Label.PORD002_TAG022;}  //Destination Address is blank      
      public String getTAG023(){ return  System.Label.PORD002_TAG023;}  //Invalid line quantity      
      public String getTAG024(){ return  System.Label.PORD002_TAG024;}  //Continue
      public String getTAG025(){ return  System.Label.PORD002_TAG025;}  //Settings not available for the SubModule: Create Parts Order Lines
      public String getTAG030(){ return  System.Label.PORD002_TAG030;}  //PriceBook not found
      public String getTAG036(){ return  System.Label.PORD002_TAG036;}  //Source Object Record Id not found
      public String getTAG039(){ return  System.Label.PORD002_TAG039;}  //Get Price/ Product
      public String getTAG040(){ return  System.Label.PORD002_TAG040;}  //Use Pricebook
      public String getTAG045(){ return System.Label.PORD002_TAG045;}//svmxTagList.get('TAG045');}//Select Address Type
      public String getTAG046(){ return System.Label.PORD002_TAG046;}//svmxTagList.get('TAG046');}//Please Enter Product
      public String getTAG047(){ return System.Label.PORD002_TAG047;}//svmxTagList.get('TAG047');}//Save
      public String getTAG048(){ return System.Label.PORD002_TAG048;}//svmxTagList.get('TAG048');}//Order Lines for
      public String getTAG049(){ return System.Label.PORD002_TAG049;}  //Loading...
      public String getTAG050(){ return System.Label.PORD002_TAG050;}//Please add lines for Shipment
      public String getTAG051(){ return System.Label.PORD002_TAG051;}//No lines have been created for Shipment
      public String getTAG052(){ return System.Label.PORD002_TAG052;}//Header Record Type
      public String getTAG053(){ return System.Label.PORD002_TAG053;}//Error Message if Record Type doesn't exist in the object
      public String getTAG054(){ return System.Label.PORD002_TAG054;}//Line Record Type
      public String getTAG055(){ return System.Label.PORD002_TAG055;}//Line Record Type
      public String getTAG056(){ return System.Label.PORD002_TAG056;}//I will Enter a Location/Address
      
      public String getHLPURL() {return System.Label.PORD002_HLPURL;} 
   
}