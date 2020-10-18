/*******************************************************************************************************************
ServiceMax Controller Class for the VF Page PORD_CreateRMALines:
-----------------------------------------------------------------------
1. Manages creation of RMA Lines
Module      :   PORD
SubModule   :   PORD001

*******************************************************************************************************************/
/* Security Scanned */
public  with sharing class PORD_CreateRMALines
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
    
    /*******************************************************************************************************************
List to store new lines and the lines which are captured from Source object
*******************************************************************************************************************/
    List<SVMXC__RMA_Shipment_Line__c> TempRMASHPDetailArray = new List<SVMXC__RMA_Shipment_Line__c> ();     
    
    /*******************************************************************************************************************
Variables to store records based on setting values
*******************************************************************************************************************/
    
    SVMXC__Site__c Location = new SVMXC__Site__c();
    Pricebook2 priceBook = new Pricebook2();
    
    public String SelectedAddressType;
    //public String selectedRecordType;  
    //public String selectedLineRecordType;
    
    public String getSelectedAddressType(){ return SelectedAddressType;}
    public void setSelectedAddressType(String val){SelectedAddressType = val;}
    
    
    
    /*
Setter and Getter for RMA Header RecordType.
Changed on 06/17/2009
Changed By Prashant Singh

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
*/   
    /*
Setter and Getter for RMA Line RecordType.
Changed on 06/17/2009
Changed By Prashant Singh

public String getselectedLineRecordType(){
system.debug('selectedLineRecordType:'+selectedLineRecordType);
return selectedLineRecordType;   
}
public void setselectedLineRecordType(String rType){selectedLineRecordType=rType;  }    
public List<SelectOption> getLineRecordTypes(){
List<SelectOption> options = new List<SelectOption>(); 
String pListRT = AllSubModuleSettings.get('SET020');
system.debug('pListRT:'+pListRT);
if(pListRT!=null || pListRT!=''){
List<String> recordTypeList=new List<String>();
recordTypeList=pListRT.split(',');      
for(String  option :recordTypeList){ options.add(new SelectOption(option,option));}     
}        
return options;
}
*/ 
    /*******************************************************************************************************************
New objects which are to be created on submission of the VF Page
*******************************************************************************************************************/
    
    public List<SVMXC__RMA_Shipment_Line__c> getNewRMAShpipmentLines() {return TempRMASHPDetailArray; }
    public void setNewRMAShpipmentLines(List<SVMXC__RMA_Shipment_Line__c> objArray) {TempRMASHPDetailArray = objArray; }
    
    RecordType TargetLineRecordType = new RecordType ();
    
    /*******************************************************************************************************************
Variables to store FieldNames for various Objects
*******************************************************************************************************************/
    String LocationFieldNames; 
    
    // Variable to hold Defualt Pick List Value
    public String defExpCond;
    public String defDisp;
    public String defSouCountry;
    public String defDesCountry;
    
    /*******************************************************************************************************************
1. List to store the existing lines of Parts Order
2. Method to return the existing lines from Source Parts Order
*******************************************************************************************************************/
    List<SVMXC__RMA_Shipment_Line__c> ExistingRMALines= new List<SVMXC__RMA_Shipment_Line__c> (); 
    
    public List<SVMXC__RMA_Shipment_Line__c> getExistingLines(){
        List<SVMXC__RMA_Shipment_Line__c> POLines;
        List<SVMXC__RMA_Shipment_Line__c> POLineRecords = new List<SVMXC__RMA_Shipment_Line__c>();
        
        String fieldNames;
        String SOQLDetail;          
        try{
            Schema.DescribeSObjectResult dsoResult = SVMXC__RMA_Shipment_Line__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__RMA_Shipment_Line__c.fields.getMap();
            
            //build a list of all fieldnames for the object
            List<String> fieldList = utils.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utils.SVMX_getFieldNamesFromList(fieldList);            
            
            fieldNames +=' , SVMXC__Product__r.Name,SVMXC__Product__r.ProductCode ,SVMXC__Serial_Number__r.Name ';            
            
            SOQLDetail = 'SELECT '+fieldNames+' FROM SVMXC__RMA_Shipment_Line__c where SVMXC__RMA_Shipment_Order__c =\''+rmaID+'\'  ';        
            POLines = Database.query(SOQLDetail);     
            
            for ( SVMXC__RMA_Shipment_Line__c POLine : POLines)
            {
                POLineRecords.add(POLine);
            }                
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017(),e.getMessage()));}
        return POLineRecords;   
        
    }
    
    /*******************************************************************************************************************
Objects& method to populate the source object data with get method
*******************************************************************************************************************/
    
    public SVMXC__RMA_Shipment_Order__c SourcePO= new SVMXC__RMA_Shipment_Order__c(); 
    public SVMXC__RMA_Shipment_Order__c getSourcePO(){ return SourcePO; }
    public void setSourcePO(SVMXC__RMA_Shipment_Order__c obj) {SourcePO = obj; } 
    
    public SVMXC__RMA_Shipment_Order__c getSourcePOData(){ 
        SVMXC__RMA_Shipment_Order__c PO = new SVMXC__RMA_Shipment_Order__c();
        String fieldNames;
        String SOQLHeader;          
        try{
            Schema.DescribeSObjectResult dsoResult = SVMXC__RMA_Shipment_Order__c.sObjectType.getDescribe();
            Map<String, SObjectField> fieldMap = Schema.SObjectType.SVMXC__RMA_Shipment_Order__c.fields.getMap();
            
            //build a list of all fieldnames for the object
            List<String> fieldList = utils.SVMX_getFieldList(fieldMap,true);      
            fieldNames = utils.SVMX_getFieldNamesFromList(fieldList);               
            
            fieldNames +=' , SVMXC__Company__r.Name,SVMXC__Contact__r.Name ';            
            
            SOQLHeader = 'SELECT '+fieldNames+' FROM SVMXC__RMA_Shipment_Order__c where Id =\''+rmaID+'\'  ';        
            PO = Database.query(SOQLHeader);     
            
            
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017(),e.getMessage()));}
        return PO; 
    }
    
    
    /*******************************************************************************************************************
Global variables for Settings & Translation
*******************************************************************************************************************/
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();  
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags(); 
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('PORD001'); 
    
    public Map<String, String> AllSubModuleSettings;
    
    
    String Setng_ActionOnNoLine ;  //SET006   
    
    
    
    /*******************************************************************************************************************
Method to validate the availability of all the Settings
*******************************************************************************************************************/
    
    public void ValidateAllSettings(){           
        
        if (AllSubModuleSettings.size()==0) 
            AddToErrorsList(getTag025()); //Settings not available for the SubModule: Create RMA 
        else{////else1
            
            //SET006             
            Setng_ActionOnNoLine           = AllSubModuleSettings.get('SET006');  
            if (Setng_ActionOnNoLine ==null) 
                AddToErrorsList(getTag025()); //Setting not available for Action On No Line
            
        }////else1
        /* 
//SET019
selectedRecordType=AllSubModuleSettings.get('SET019');

//SET021
selectedLineRecordType=AllSubModuleSettings.get('SET021'); 
*/           
    }
    
    
    /*******************************************************************************************************************
Global variables with get & set methods
*******************************************************************************************************************/
    Boolean ValidRecords = true;
    
    Boolean CheckAllLines=false;    
    public Boolean getCheckAllLines() {return CheckAllLines;  }
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
    
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


*******************************************************************************************************************/    
    
    public PORD_CreateRMALines()
    {
        if (rmaID ==null) {        AddToErrorsList(getTag036()); }       //Source Object Record Id not found
        
        AllSubModuleSettings= settings.SVMX_getSettingList('PORD001'); //SubModule: Create Parts Order (RMA)             
        ValidateAllSettings();  
        
        defExpCond  = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Line__c', 'SVMXC__Expected_Condition__c');
        defDisp = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Line__c', 'SVMXC__Disposition__c');
        defSouCountry  = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Order__c', 'SVMXC__Source_Country__c');
        defDesCountry = utils.SVMX_getDefaultPicklistValue('SVMXC__RMA_Shipment_Order__c', 'SVMXC__Destination_Country__c');
        
        DisplayErrorsNWarnings();   
        SourcePO = getSourcePOData(); 
        if(SourcePO.SVMXC__Source_Country__c == null ) SourcePO.SVMXC__Source_Country__c = defSouCountry;
        if( SourcePO.SVMXC__Destination_Country__c == null) SourcePO.SVMXC__Destination_Country__c = defDesCountry;
        if (ValidRecords == true)   
        {   
            PopulateFieldNames();
            ExistingRMALines = getExistingLines();
            TargetLineRecordType   = getRecordType('RMA','SVMXC__RMA_Shipment_Line__c');
            //TargetLineRecordType   = getRecordType(selectedLineRecordType,'SVMXC__RMA_Shipment_Line__c');
            //Automatically add an empty line by default if there are no existing records     
            if(ExistingRMALines.size() == 0)
            {
                AddLine();
                for(SVMXC__RMA_Shipment_Line__c line : TempRMASHPDetailArray)
                {
                    line.SVMXC__RMA_Shipment_Order__c = SourcePO.Id;
                    if(TargetLineRecordType!=null){
                        line.RecordTypeId = TargetLineRecordType.Id;
                    }else{
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,'Please make sure that RecordType must exist in the Object.'));
                    }
                    
                }
            }
            
            for (SVMXC__RMA_Shipment_Line__c line :  ExistingRMALines)
            {
                line.SVMXC__Select__c = false;
                if(line.SVMXC__Expected_Condition__c == null) line.SVMXC__Expected_Condition__c = defExpCond  ;
                if(line.SVMXC__Disposition__c == null) line.SVMXC__Disposition__c = defDisp ;
                
                TempRMASHPDetailArray.add(line);   
            }
        }         
        else
            setDisplayForm(false);
    }
    
    /*******************************************************************************************************************
Methods to Populate Field Names for various objects
*******************************************************************************************************************/
    public void PopulateFieldNames() { 
        
        //     fieldNames; 
        //     LocationFieldNames; 
        //     POHeaderFieldNames; 
        //     POLineFieldNames; 
        
        try{ 
            //Populating FieldNames for Location            
            
            
            Schema.DescribeSObjectResult dsoLocationResult = SVMXC__Site__c.sObjectType.getDescribe();
            Map<String, SObjectField> LocationfieldMap = Schema.SObjectType.SVMXC__Site__c.fields.getMap();
            //build a list of all fieldnames for the object
            List<String> LocationfieldList = utils.SVMX_getFieldList(LocationfieldMap,true);      
            LocationFieldNames = utils.SVMX_getFieldNamesFromList(LocationfieldList);    
            
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}
        
    }
    
    /*******************************************************************************************************************
Methods to retrieve Location Record
*******************************************************************************************************************/
    
    public SVMXC__Site__c getLocationFromId(String locId) {           
        String SOQLHeader;
        SVMXC__Site__c  LocRecord = new SVMXC__Site__c();
        try{
            
            SOQLHeader = 'SELECT '+LocationFieldNames+' FROM SVMXC__Site__c where Id=\''+locId+'\''; 
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
        if(SourcePO.SVMXC__Source_Location__c !=null)
        {
            String AddressFieldType='Source';
            SVMXC__Site__c Loc = new SVMXC__Site__c();                  
            Loc = getLocationFromId (SourcePO.SVMXC__Source_Location__c);                    
            populateAddress( AddressFieldType , Loc.SVMXC__Street__c,  Loc.SVMXC__City__c,  Loc.SVMXC__State__c,  Loc.SVMXC__Zip__c,  Loc.SVMXC__Country__c);
        }
        
    }
    public void setAddressForTargetLoc()
    {                
        // Populating Destination Address fields  
        if(SourcePO.SVMXC__Destination_Location__c !=null)        
        {
            String AddressFieldType ='Destination';             
            SVMXC__Site__c Loc = new SVMXC__Site__c();                          
            Loc = getLocationFromId (SourcePO.SVMXC__Destination_Location__c);                 
            populateAddress( AddressFieldType , Loc.SVMXC__Street__c,  Loc.SVMXC__City__c,  Loc.SVMXC__State__c,  Loc.SVMXC__Zip__c,  Loc.SVMXC__Country__c);
        }
        
    }        
    public void populateAddress(String AddressFieldType ,String Street, String City, String State, String Zip, String Country)
    {
        if (AddressFieldType=='Destination')
        {
            if (Street !=null)
                SourcePO.SVMXC__Destination_Street__c = Street;
            if (City !=null)
                SourcePO.SVMXC__Destination_City__c  = City ;
            if (State !=null)
                SourcePO.SVMXC__Destination_State__c=  State ; 
            if (Zip !=null)
                SourcePO.SVMXC__Destination_Zip__c= Zip ; 
            if (Country !=null)
                SourcePO.SVMXC__Destination_Country__c= Country ; 
        }
        if (AddressFieldType=='Source')
        {
            if (Street !=null)
                SourcePO.SVMXC__Source_Street__c = Street;
            if (City !=null)
                SourcePO.SVMXC__Source_City__c  = City ;
            if (State !=null)
                SourcePO.SVMXC__Source_State__c=  State ; 
            if (Zip !=null)
                SourcePO.SVMXC__Source_Zip__c= Zip ; 
            if (Country !=null)
                SourcePO.SVMXC__Source_Country__c= Country ; 
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
        return SaveRMA();
    }
    public PageReference SaveRMA()
    {
        
        if(isValidData()==true && getshowWarnings()==false)
        {
            try{
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( SourcePO, COMM_SecurityUtils.Access.Upsertable ) ) {
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    update SourcePO;
                } else {
                    ValidRecords = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                
                for (SVMXC__RMA_Shipment_Line__c PreEditLine : ExistingRMALines) 
                {
                    Boolean OldLineExist = false;
                    
                    for (SVMXC__RMA_Shipment_Line__c PostEditLine : TempRMASHPDetailArray)
                    {
                        if (PreEditLine.Id == PostEditLine.Id) 
                        {
                            OldLineExist = true;                            
                            break;                              
                        }
                    }               
                    if(OldLineExist !=true)
                    {
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__RMA_Shipment_Line__c' ) ) {
                            //SDL-SVMX-DELETE-FLS-ENFORCED
                            delete PreEditLine;
                        } else {
                            ValidRecords = false;
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                            return null;
                        }
                        
                    }
                }//for1
                
                //upsert TempRMASHPDetailArray;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempRMASHPDetailArray, COMM_SecurityUtils.Access.Upsertable ) ) {
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    upsert TempRMASHPDetailArray;
                } else {
                    ValidRecords = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                PageReference poPage = new PageReference('/' + rmaID);
                poPage.setRedirect(true);
                return poPage; 
            }catch (Exception e){ ValidRecords = false; ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}   
        }//if
        
        return null;        
    }  
    
    
    public PageReference AddLine()
    {       
        SVMXC__RMA_Shipment_Line__c newListLine = new SVMXC__RMA_Shipment_Line__c(); 
        newListLine.SVMXC__RMA_Shipment_Order__c =   SourcePO.Id;  
        newListLine.RecordTypeId                 =   TargetLineRecordType.Id;  
        newListLine.SVMXC__Expected_Condition__c = defExpCond  ;
        newListLine.SVMXC__Disposition__c = defDisp ;
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
            if ((line.Product__c ==null)&&(line.Serial_Number__c!=null))
                line.Product__c = SVMX_getProductIdFromIB(line.Serial_Number__c);                            
        }           
        
        return null;
    }   
    public Id SVMX_getProductIdFromIB(Id IBId){     
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        try{
            IB = [Select SVMXC__Product__c From SVMXC__Installed_Product__c where Id = :IBId];
            
            return IB.SVMXC__Product__c;
            
        } catch (Exception e){ 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017(),e.getMessage()));
            return null;}   
        
    }    
    
    public Boolean isValidData()
    {
        ValidRecords = true;
        Boolean validLine= false;
        ErrorMessages.clear();
        DisplayBlockLevelMessage =false;
        
        if(TempRMASHPDetailArray.size()==0)
        {               
            if(Setng_ActionOnNoLine.toUpperCase() == 'DISALLOW')
            {
                ErrorMessages.add(getTag050()); 
                ValidRecords = false;                          
            }
            if(Setng_ActionOnNoLine.toUpperCase() == 'WARN')
            {               
                if (WarningDisplayed==false)
                    WarningMessages.add(getTag051());
            } 
        }
        
        validLine = isValidLine();
        if(validLine !=true)
        {                           
            //ErrorMessages.add(getTag023());
            ValidRecords = false;                                                                 
        }
        
        DisplayErrorsNWarnings();
        return ValidRecords;    
    }
    
    public Boolean isValidLine()
    {
        
        Boolean isValidRecord =true;
        for(SVMXC__RMA_Shipment_Line__c ListObj :TempRMASHPDetailArray)
        {      
            if( (ListObj.SVMXC__Expected_Quantity2__c == null || ListObj.SVMXC__Expected_Quantity2__c <0) )//&& ListObj.SVMXC__Select__c==true)
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
        String SOQL  = 'SELECT Id,Name  FROM RecordType  where SobjectType  =\''+SobjectType+'\' AND Name=\''+Name+'\' ';        
        try{
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            rType = Database.query(SOQL); 
        } catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017() ,e.getMessage()));}   
        return rType;
    }
    /*******************************************************************************************************************
Object/Methods  to retrieve Settings and Translation Tag Values
*******************************************************************************************************************/
    
    
    
    public String getTAG001(){ return system.label.PORD001_TAG001;}  //Create RMA    
    public String getTAG003(){ return system.label.PORD001_TAG003;} //Create RMA Help     
    public String getTAG004(){ return system.label.PORD001_TAG004;} //Cancel  
    public String getTAG005(){ return system.label.PORD001_TAG005;} //Add Address       
    
    public String getTAG006(){ return system.label.PORD001_TAG006;} //From Location
    public String getTAG007(){ return system.label.PORD001_TAG007;}//To Location      
    
    public String getTAG008(){ return system.label.PORD001_TAG008;} //RMA Lines
    public String getTAG009(){ return system.label.PORD001_TAG009;}//Add Line      
    public String getTAG010(){ return system.label.PORD001_TAG010;} //Delete Lines      
    public String getTAG017(){ return system.label.PORD001_TAG017;} //Error in Create RMA   
    public String getTAG018(){ return system.label.PORD001_TAG018;} //No RMA Line has been selected      
    public String getTAG023(){ return system.label.PORD001_TAG023;}//Invalid line quantity      
    public String getTAG024(){ return system.label.PORD001_TAG024;}//Continue      
    public String getTAG025(){ return system.label.PORD001_TAG025;}//Settings not available for the SubModule: Create RMA
    public String getTAG036(){ return system.label.PORD001_TAG036;}//Source Object Record Id not found
    public String getTAG039(){ return system.label.PORD001_TAG039;}//Get Price
    public String getTAG043(){ return system.label.PORD001_TAG043;}//RMA Lines for 
    public String getTAG044(){ return system.label.PORD001_TAG044;}//Save
    public String getTAG045(){ return system.label.PORD001_TAG045;}//Select Address Type
    public String getTAG046(){ return system.label.PORD001_TAG046;}//Please Enter Product
    public String getTAG049(){ return system.label.PORD001_TAG049;}//Loading...
    public String getTAG050(){ return system.label.PORD001_TAG050;}//Please add lines for RMA
    public String getTAG051(){ return system.label.PORD001_TAG051;}//No lines have been created for RMA 
    public String getTAG052(){ return system.label.PORD001_TAG052;}// RecordType 
    
    public String getHLPURL() {return system.label.PORD001_HLPURL;} //HLPURL   
    
    
}