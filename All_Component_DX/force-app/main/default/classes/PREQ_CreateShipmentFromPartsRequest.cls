/* Security Scanned */
public with sharing class PREQ_CreateShipmentFromPartsRequest
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
    //public String getHLPURL() {
       // return null;
    //}
    Boolean ValidRecords = true;
    public Map<String, String> AllSubModuleSettings;
    String Setng_ActionOnBlankFromAddress ;   //SET007
    String Setng_ActionOnBlankToAddress  ;    //SET008
    public Map<String, String> svmxSettingList = new Map<String,String>();
    public SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public string HeaderRecType;
    public List<String> HeaderRecTypeArray = new List<String> ();
    public string LineRecType;
    public List<String> LineRecTypeArray = new List<String> ();
    Boolean disableSave = false;
    public Boolean getDisableSave(){return disableSave;}
    public string PricebookToUse;
    public String SelectedAddressType='';
    public String getSelectedAddressType(){ return SelectedAddressType;}
    public String defDesCountry;
    public void setSelectedAddressType(String val){SelectedAddressType = val;}
    public integer c;
    public integer d;
    public boolean savecheckS;
    public boolean savecheckD;
    public boolean message;
    public boolean Linemessage;
    Boolean CheckAllLines=false;
    public integer priceVar;
    public boolean Cont;
    public boolean displayTeamPopup;
    public string LocationFieldNames;
    SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    public map<String,String> SettingList = new map<String,String>();
    public String LineQryStr = '';
    public String HeaderQryStr = '';
    
    public String SelectedHeaderRecordType;
    public String getSelectedHeaderRecordType(){return SelectedHeaderRecordType;}
    public void setSelectedHeaderRecordType(String rType){SelectedHeaderRecordType=rType;}

    public String SelectedLineRecordType;
    public String getSelectedLineRecordType(){return SelectedLineRecordType;}
    public void setSelectedLineRecordType(String rType){SelectedLineRecordType=rType;}
    
    Public boolean desloc;
    Public String FromLoc;
    Public String SelectAddressType;
    List<String> SelectAddressTypeArray = new List<String> ();
    //Boolean showWarnings=false;
    //Boolean WarningDisplayed=false;
    List<SVMXC__RMA_Shipment_Line__c> InsertRMASHPDetailArray = new List<SVMXC__RMA_Shipment_Line__c> ();
    Pricebook2 priceBook = new Pricebook2();
    Public String AddressFieldType;
    Public String Selected;
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting_Header = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> fieldMapSetting_Line = new List<SVMXC__ServiceMax_Config_Data__c>();
    public String HeaderMapId_FrmSetn; //= SettingList.get('SET024');
    public String LineMapId_FrmSetn; //= SettingList.get('SET025');
    
    
    SVMXC__RMA_Shipment_Order__c NewRMASHPHeader = new SVMXC__RMA_Shipment_Order__c();
    SVMXC__Parts_Request__c PartsHeaderList = new  SVMXC__Parts_Request__c ();
    SVMXC__Parts_Request__c DestLocationList = new  SVMXC__Parts_Request__c ();
    String PageID = System.currentPageReference().getParameters().get('prid');
    List<SVMXC__RMA_Shipment_Line__c> RMASHPDetailArray = new List<SVMXC__RMA_Shipment_Line__c> ();
    List<SVMXC__Parts_Request_Line__c> PartsLineList = new List<SVMXC__Parts_Request_Line__c>();
    SVMXC__RMA_Shipment_Line__c TList1;
    
    public SVMXC__RMA_Shipment_Order__c getNewRMAShpipmentHeader() {return NewRMASHPHeader; } 
    public void setNewRMAShpipmentHeader(SVMXC__RMA_Shipment_Order__c obj) {this.NewRMASHPHeader = obj;}
    public List<SVMXC__RMA_Shipment_Line__c> getNewRMAShpipmentLines() {return RMASHPDetailArray; }
    public void setNewRMAShpipmentLines(List<SVMXC__RMA_Shipment_Line__c> objArray) {this.RMASHPDetailArray = objArray; }
   
    SVMXC__Site__c LocS = new SVMXC__Site__c();
    SVMXC__Site__c LocD = new SVMXC__Site__c();
    
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
  
     Boolean WarningDisplayed=false;
     List<String> WarningMessages = new  List<String> ();            
     public void AddToWarningsList(String msg) { WarningMessages.add(msg);}
     public List<String> getWarningsList() { return WarningMessages; }   
      
  
    Boolean DisplayBlockLevelMessage = false;
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }

    /****************************************************Command Button Functions***********************************************************************/
    public void ValidateAllSettings(){ 
        //SET007        
        Setng_ActionOnBlankFromAddress = SettingList.get('SET007');  
        if (Setng_ActionOnBlankFromAddress ==null) 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'Setting not available for Action On Blank From Address',''));//Setting not available for Action On Blank From Address
         //SET008     
        Setng_ActionOnBlankToAddress   = SettingList.get('SET008'); 
    }


    public void DisplayErrorsNWarnings(){
            if( ErrorMessages.size()>0)
            {
                ValidRecords = false;  
                DisplayBlockLevelMessage = false; 
                for (String msg : ErrorMessages)
                    {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,msg,'')) ;  
                    }
            }   
            else if( WarningMessages.size()>0&&(ValidRecords !=false))
            {
                for (String msg : WarningMessages)
                    {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning,msg,' ')) ;   
                    }
            }   
    }
    public Boolean isValidData() {
        ValidRecords = true;
        Boolean validLine= false;
        ErrorMessages.clear();
        DisplayBlockLevelMessage = false;
        Boolean IsFromAddressBlank = isBlankLocation(NewRMASHPHeader.SVMXC__Source_Location__c,NewRMASHPHeader.SVMXC__Source_Street__c,  NewRMASHPHeader.SVMXC__Source_City__c,  NewRMASHPHeader.SVMXC__Source_State__c,  NewRMASHPHeader.SVMXC__Source_Zip__c,  NewRMASHPHeader.SVMXC__Source_Country__c);
        Boolean IsToAddressBlank   = isBlankLocation(NewRMASHPHeader.SVMXC__Destination_Location__c,NewRMASHPHeader.SVMXC__Destination_Street__c,  NewRMASHPHeader.SVMXC__Destination_City__c,  NewRMASHPHeader.SVMXC__Destination_State__c,  NewRMASHPHeader.SVMXC__Destination_Zip__c,  NewRMASHPHeader.SVMXC__Destination_Country__c);
            if (IsFromAddressBlank==true)   
            {
                if(Setng_ActionOnBlankFromAddress.toUpperCase() =='DISALLOW')
                {
                  AddToErrorsList(getTAG046()); //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'Source Address cannot be left blank',''));
                  ValidRecords = false;        
                }
                if(Setng_ActionOnBlankFromAddress.toUpperCase() =='WARN')
                {
                  if (WarningDisplayed==false)                
                   AddToWarningsList(getTAG040());
                   //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Source Address is blank',' ')) ;
                   //WarningMessages.add('Source Address is blank');  
                   //ValidRecords = true;                                          
                }
            }
            if (IsToAddressBlank==true)
            {
                if(Setng_ActionOnBlankToAddress.toUpperCase() =='DISALLOW')
                {
                    AddToErrorsList(getTAG047()); 
                    ValidRecords = false;   //ErrorMessages.add('Destination Address cannot be left blank');
                }
                if(Setng_ActionOnBlankToAddress.toUpperCase() =='WARN')
                { 
                    if (WarningDisplayed==false)
                        AddToWarningsList(getTAG041()); //WarningMessages.add('Destination Address is blank');  
                }
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
        
    public PageReference Save()
    {
        if(isValidData()==true && getshowWarnings()==false)
        {   
          try
          {
                RecordType HeaderRecordType = getRecordType(SelectedHeaderRecordType,'SVMXC__RMA_Shipment_Order__c');
                RecordType LineRecordType = getRecordType(SelectedLineRecordType,'SVMXC__RMA_Shipment_Line__c');
                if( HeaderRecordType != null)
                {
                NewRMASHPHeader.RecordTypeId =HeaderRecordType.Id;
                }
               
                c=2;
                savecheckS=true;
                d=2;
                savecheckD=true;
                //upsert NewRMASHPHeader;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( NewRMASHPHeader, COMM_SecurityUtils.Access.Upsertable ) ) {
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert NewRMASHPHeader;
                } else {
                    ValidRecords = false;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
                 
                for(SVMXC__RMA_Shipment_Line__c ListObj :RMASHPDetailArray)
                {
                   ListObj.SVMXC__RMA_Shipment_Order__c = NewRMASHPHeader.Id;
                   if(ListObj.SVMXC__Product__c!=NULL)
                   {
                       //try{
                           for(SVMXC__Parts_Request_Line__c PRLINE : PartsLineList)
                           {
                               if(ListObj.SVMXC__Parts_Request_Line__c == PRLINE.Id)
                               {
                                    if(LineQryStr.contains('SVMXC__Quantity_Shipment_Initiated2__c'))
                                    {
                                    if(PRLINE.SVMXC__Quantity_Shipment_Initiated2__c == null)
                                        PRLINE.SVMXC__Quantity_Shipment_Initiated2__c = 0;
                                    }
                                    if(Listobj.SVMXC__Expected_Quantity2__c == null)
                                        Listobj.SVMXC__Expected_Quantity2__c = 0;
        
                                    if(LineQryStr.contains('SVMXC__Quantity_Shipment_Initiated2__c'))
                                    {
                                        /*double value = 0;
                                          value = (Double)PRLINE.get('SVMXC__Quantity_Shipment_Initiated2__c') + Listobj.SVMXC__Expected_Quantity2__c;
                                          PRLINE.put('SVMXC__Quantity_Shipment_Initiated2__c',value);*/
                                        PRLINE.SVMXC__Quantity_Shipment_Initiated2__c += Listobj.SVMXC__Expected_Quantity2__c;
                                    }
                               }
                           }
                           if( LineRecordType != null){
                           ListObj.RecordTypeId = LineRecordType.Id;
                           }
                           InsertRMASHPDetailArray.add(ListObj);
                       //}
                       //catch (Exception e){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG017(),e.getMessage()));}
                   }
                 }
                if(InsertRMASHPDetailArray.size()>0 && InsertRMASHPDetailArray.size() != null)
                {
                    //upsert InsertRMASHPDetailArray;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( InsertRMASHPDetailArray, COMM_SecurityUtils.Access.Upsertable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert InsertRMASHPDetailArray;
                    } else {
                        ValidRecords = false;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( PartsLineList, COMM_SecurityUtils.Access.Updateable ) ) {
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    update PartsLineList;
                    } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }

                    
                }
                
                PageReference newPage = new PageReference('/' + NewRMASHPHeader.Id);
                newPage.setRedirect(true);
                return newPage;
            }
            catch (Exception e){ValidRecords = false; ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));}
         }
         return null;   
    }
    
    public PageReference Cancel(){
        PageReference newPage = new PageReference('/' + PageID);
        return newPage;
    }
    
    public PageReference ClearWarnings()
    {
        WarningDisplayed=true;
        WarningMessages.clear();
        return Save();
    }

    public PageReference Addlines() {
        SVMXC__RMA_Shipment_Line__c ADDRMASHPDetailArray;
        if(UserInfo.isMultiCurrencyOrganization() && PartsHeaderList != null){
            ADDRMASHPDetailArray = new SVMXC__RMA_Shipment_Line__c();
            ADDRMASHPDetailArray.put('CurrencyIsoCode' ,PartsHeaderList.get('CurrencyIsoCode'));
        }
        else
            ADDRMASHPDetailArray = new SVMXC__RMA_Shipment_Line__c();
        RMASHPDetailArray.add(ADDRMASHPDetailArray);
        return null;
    }


    
    public PREQ_CreateShipmentFromPartsRequest()
    {
        svmxSettingList = commSettings.SVMX_getSettingList('PORD002');
        SelectedHeaderRecordType=svmxSettingList.get('SET019');
        SelectedLineRecordType=svmxSettingList.get('SET021');
        
        PricebookToUse = svmxSettingList.get('SET011');
        system.debug('zzzzzzzz'+PricebookToUse);
        displayTeamPopup=false;
        Cont=false;
        c=0;
        d=0;
        savecheckS=false;
        savecheckD=false;
        message=false;
        Linemessage=false;
        desloc=true;
        
        //New code added to meet mapping requirements
        SettingList = settings.SVMX_getSettingList('PORD002');
        
        HeaderMapId_FrmSetn = SettingList.get('SET024');
        
        LineMapId_FrmSetn = SettingList.get('SET025');
       
        if((HeaderMapId_FrmSetn == NULL || HeaderMapId_FrmSetn == '') || (LineMapId_FrmSetn == NULL || LineMapId_FrmSetn == ''))
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'Please check whether Object mapping\'s settings exist and try again',''));
        fieldMapSetting_Header = settings.SVMX_getFieldMapping(HeaderMapId_FrmSetn);
        system.debug('TestfieldMapSetting_Header' + fieldMapSetting_Header);
        fieldMapSetting_Line = settings.SVMX_getFieldMapping(LineMapId_FrmSetn);
        system.debug('TestfieldMapSetting_Line' + fieldMapSetting_Line);
        Boolean CopyField;
        Boolean containsCurrField = false;
        priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(PricebookToUse);
        
            ////ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG048(),''));
        ValidateAllSettings();
        if(priceBook==null)
                {AddToErrorsList(getTAG048()); disableSave =true;} //By GM 2-Oct-10
        DisplayErrorsNWarnings();
        
      //Code to prepare for Header query str 
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting_Header)
        
        {
            CopyField = true;
            // CurrencyIsoCode must be copied from source to target only if multi-currency is enabled for the organization
            if (fld.SVMXC__Source_Field_Name__c.equalsIgnoreCase('CurrencyIsoCode'))
            {
                containsCurrField = true;
                if (userinfo.isMultiCurrencyOrganization()) 
                    CopyField = true; 
                else
                    CopyField = false; 
            }
           
            if (fld.SVMXC__Source_Field_Name__c != null && CopyField == true)
            {
                if(HeaderQryStr.length()==0  || HeaderQryStr == '' || HeaderQryStr == NULL)
                    HeaderQryStr = fld.SVMXC__Source_Field_Name__c;
                else if(!HeaderQryStr.contains(fld.SVMXC__Source_Field_Name__c))
                   HeaderQryStr += ',' + fld.SVMXC__Source_Field_Name__c;
            }
        }
        if (containsCurrField == false && userinfo.isMultiCurrencyOrganization()){
            if(HeaderQryStr.length()==0  || HeaderQryStr == '' || HeaderQryStr == NULL)
                    HeaderQryStr = 'CurrencyIsoCode';
                else
                    HeaderQryStr += ',' +  'CurrencyIsoCode';
        }
            

        String SOQLHeader = 'SELECT '+HeaderQryStr+' FROM SVMXC__Parts_Request__c where Id=:PageID';
       
        
        PartsHeaderList= database.query(SOQLHeader);
       
        
        //Code to prepare for Line query str
        for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting_Line)
        {
            CopyField = true;
            // CurrencyIsoCode must be copied from source to target only if multi-currency is enabled for the organization
            if (fld.SVMXC__Source_Field_Name__c.equalsIgnoreCase('CurrencyIsoCode'))
            {
                containsCurrField = true;
                if (userinfo.isMultiCurrencyOrganization()) { CopyField = false; }
            }
            if (fld.SVMXC__Source_Field_Name__c != null && CopyField == true)
            {
                if(LineQryStr.length()==0 || LineQryStr == '' || LineQryStr == NULL)
                    LineQryStr = fld.SVMXC__Source_Field_Name__c;
                else if(!LineQryStr.contains(fld.SVMXC__Source_Field_Name__c))
                    LineQryStr += ',' + fld.SVMXC__Source_Field_Name__c;
            }
            
        }
        if(containsCurrField == false && UserInfo.isMultiCurrencyOrganization()){
            if(LineQryStr.length()==0 || LineQryStr == '' || LineQryStr == NULL)
                    LineQryStr = 'CurrencyIsoCode';
            else
                LineQryStr += ',' +  'CurrencyIsoCode';
        }
            
        String PartsHeaderID = PartsHeaderList.Id;
        String SOQLLine = 'Select '+LineQryStr+' FROM SVMXC__Parts_Request_Line__c where SVMXC__Parts_Request__c = :PartsHeaderID';
        PartsLineList = database.query(SOQLLine);
        system.debug('SOQLLine..........' + SOQLLine);
        //To create new Shipment Header record for saving, we do the following - Header
        try
        {
            //Populate fields and corresponding values using fieldMap
            for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting_Header)
            {
                String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                Object souFldVal = PartsHeaderList.get(sourceFieldName);
                if(souFldVal != null)
                {
                    NewRMASHPHeader.put(targetFieldName, souFldVal);
                }
            }
        } catch (Exception e)      {        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));      }
      system.debug('RMASHPDetailArray123' + NewRMASHPHeader);
        try
        {
            NewRMASHPHeader.SVMXC__Parts_Request__c=PageID;
            if(HeaderQryStr.contains('SVMXC__Requested_From__c'))
            {
                NewRMASHPHeader.SVMXC__Source_Location__c=PartsHeaderList.SVMXC__Requested_From__c;
                LocS= [Select Id, SVMXC__Street__c, SVMXC__State__c,SVMXC__City__c,SVMXC__Zip__c,SVMXC__Country__c from SVMXC__Site__c where Id=:PartsHeaderList.SVMXC__Requested_From__c ];
                if(LocS.Id != NULL)
                {
                    NewRMASHPHeader.SVMXC__Source_Street__c=LocS.SVMXC__Street__c;
                    NewRMASHPHeader.SVMXC__Source_City__c=LocS.SVMXC__City__c;
                    NewRMASHPHeader.SVMXC__Source_State__c=LocS.SVMXC__State__c;
                    NewRMASHPHeader.SVMXC__Source_Zip__c=LocS.SVMXC__Zip__c;
                    NewRMASHPHeader.SVMXC__Source_Country__c=LocS.SVMXC__Country__c;
                }
            }
        }
        catch(Exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'Parts Request Record does not have source location',''));}
        try
        {
            if(HeaderQryStr.contains('SVMXC__Required_At_Location__c'))
            {
                NewRMASHPHeader.SVMXC__Destination_Location__c=PartsHeaderList.SVMXC__Required_At_Location__c;
                LocD= [Select Id,SVMXC__Street__c, SVMXC__State__c,SVMXC__City__c,SVMXC__Zip__c,SVMXC__Country__c from SVMXC__Site__c where Id=:PartsHeaderList.SVMXC__Required_At_Location__c ];
                if(LocD.Id !=NULL)
                {
                    //To Location Values
                    NewRMASHPHeader.SVMXC__Destination_Street__c=LocD.SVMXC__Street__c;
                    NewRMASHPHeader.SVMXC__Destination_City__c=LocD.SVMXC__City__c;
                    NewRMASHPHeader.SVMXC__Destination_State__c=LocD.SVMXC__State__c;
                    NewRMASHPHeader.SVMXC__Destination_Zip__c=LocD.SVMXC__Zip__c;
                    NewRMASHPHeader.SVMXC__Destination_Country__c=LocD.SVMXC__Country__c;
                }
            }
        }
        catch(Exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'Parts Request Record does not have Destination location',''));}
        
        //Owner Name
        NewRMASHPHeader.OwnerId = UserInfo.getUserId();
      
       //Line Values
       //try{
       for(SVMXC__Parts_Request_Line__c p: PartsLineList){
            try
            {
            TList1 = new SVMXC__RMA_Shipment_Line__c();
                //Populate fields and corresponding values using fieldMap
                for(SVMXC__ServiceMax_Config_Data__c fld:fieldMapSetting_Line)
                {
                    String targetFieldName = fld.SVMXC__Target_Field_Name__c;
                    String sourceFieldName = fld.SVMXC__Source_Field_Name__c;
                    Object souFldVal = p.get(sourceFieldName);
                    if(souFldVal != null)
                    {
                    TList1.put(targetFieldName, souFldVal);
                    }
                }
            RMASHPDetailArray.add(TList1);
            } catch (Exception e)          {            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));          }
       }
       system.debug('RMASHPDetailArray123' + RMASHPDetailArray);
        if(((RMASHPDetailArray.size() == null || RMASHPDetailArray.size() == 0)) && (HeaderMapId_FrmSetn != NULL && HeaderMapId_FrmSetn != '') && (LineMapId_FrmSetn != NULL && LineMapId_FrmSetn != ''))
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG009(),''));
            Linemessage = false;
        }
    //   }
   //    catch(Exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'Fields Missing in Query',''));}
    }

    public List<SelectOption> getHeaderRecordTypes(){
       /* List<SelectOption> options = new List<SelectOption>(); 
        HeaderRecType = HeaderRecType.replace('~|~','~');
        HeaderRecTypeArray  = HeaderRecType.split('~');
        for(String  opt :HeaderRecTypeArray)
            { 
                options.add(new SelectOption(opt,opt));
            }
        return options;*/
        List<SelectOption> options = new List<SelectOption>(); 
        String pListRT = svmxSettingList.get('SET018');
        List<String> recordTypeList=new List<String>();
        recordTypeList=pListRT.split(',');      
        for(String  option :recordTypeList){ options.add(new SelectOption(option,option));}     
        return options;
    }

    public List<SelectOption> getLineRecordTypes()
    {
        /*List<SelectOption> options = new List<SelectOption>();
        LineRecType = LineRecType.replace('~|~','~');
        LineRecTypeArray  = LineRecType.split('~');
        for(String  opt :LineRecTypeArray)
        {
            options.add(new SelectOption(opt,opt));
        }
        return options;*/
        List<SelectOption> options = new List<SelectOption>(); 
        String pListRT = svmxSettingList.get('SET020');
      //  system.debug('pListRT:'+pListRT);
        if(pListRT!=null || pListRT!=''){
            List<String> recordTypeList=new List<String>();
            recordTypeList=pListRT.split(',');      
            for(String  option :recordTypeList){ options.add(new SelectOption(option,option));}     
        }        
        return options;
    }
    
    public List<SelectOption> getAddressTypes() 
    {
        List<SelectOption> options = new List<SelectOption>();
        SelectAddressType=getTAG042();
        SelectAddressType = SelectAddressType.replace('~|~','~');
        SelectAddressTypeArray  = SelectAddressType.split('~');                        
        for(String  opt :SelectAddressTypeArray)
            { 
                options.add(new SelectOption(opt,opt)); 
            }     
        return options;
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
             rType = [SELECT Id FROM RecordType where SobjectType =: SobjectType AND Name =: name];
        } 
        catch (Exception e)
        { 
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
        }   
        return rType;
    }
        
        public PageReference GetPrice()
        {        
            system.debug('1zzzzzzzEntered');
            priceVar=0;
            for (SVMXC__RMA_Shipment_Line__c line : RMASHPDetailArray)
            {
                if ((line.SVMXC__Product__c !=null) && (line.SVMXC__Use_Price_From_Pricebook__c ==true))
                {
                    priceBook = SVMXC.COMM_PriceClass.SVMXC_GetPricebook(PricebookToUse);
                    priceVar = priceVar +1;
                }
                PricebookEntry pbe = new PricebookEntry();
                try
                {
                     //Introduced newly to deal with defect 1768 
                    if( UserInfo.isMultiCurrencyOrganization() && line.get('CurrencyIsoCode') == null  && PartsHeaderList.get('CurrencyIsoCode') != null)
                        line.put('CurrencyIsoCode',PartsHeaderList.get('CurrencyIsoCode')); 
                    if(UserInfo.isMultiCurrencyOrganization())
                        pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, String.Valueof(line.get('CurrencyIsoCode')), line.SVMXC__Product__c);
                    else
                        pbe = SVMXC.COMM_PriceClass.SVMXC_GetPricebookEntry(priceBook, null, line.SVMXC__Product__c);
                        system.debug('2zzzzzzzEntered'+pbe);
                }
                catch(Exception e)
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,'test',e.getMessage()));
                }
                if ((pbe !=null) &&(line.SVMXC__Use_Price_From_Pricebook__c ==true))
                    line.SVMXC__Line_Price2__c =pbe.UnitPrice;                                
                //else
                    //line.SVMXC__Line_Price2__c =NULL;
                    system.debug('3zzzzzzzEntered'+line.SVMXC__Line_Price2__c);
            }
            if(priceVar<1)
            {
                Linemessage=true;
                //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG043(),''));
            } 
            return null;
        }   
        
        public pageReference delline()
        {
            List<SVMXC__RMA_Shipment_Line__c> TEMPRMASHPDetailArray = new List<SVMXC__RMA_Shipment_Line__c> ();
            Boolean deletecheck=false;
            savecheckS=true;
            savecheckD=true;
            for(SVMXC__RMA_Shipment_Line__c r: RMASHPDetailArray)
            {
                if(r.SVMXC__Select__c==false)
                {
                    TEMPRMASHPDetailArray.add(r);
                }
                else
                {
                    deletecheck=true;
                }
            }
            RMASHPDetailArray.clear();
            RMASHPDetailArray=TEMPRMASHPDetailArray;
            if (deletecheck==false)
            {
                Linemessage=true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag044(),''));
            }
            displayTeamPopup=false;
            return null;
        }

        public void setAddress()
        {      
            if( SelectedAddressType ==getTAG011())
            {    
                populateAddress(PartsHeaderList.SVMXC__Company__r.ShippingStreet ,PartsHeaderList.SVMXC__Company__r.ShippingCity,  PartsHeaderList.SVMXC__Company__r.ShippingState,  PartsHeaderList.SVMXC__Company__r.ShippingPostalCode,  PartsHeaderList.SVMXC__Company__r.ShippingCountry);  
                Selected='Account Shipping Address';
                desloc=true;
            }
            
            if( SelectedAddressType ==getTAG010())
            {    
                populateAddress(LocD.SVMXC__Street__c ,  LocD.SVMXC__City__c,  LocD.SVMXC__State__c,  LocD.SVMXC__Zip__c, LocD.SVMXC__Country__c);  
                Selected='None';
                desloc=true;
            }
            
            if( SelectedAddressType ==getTAG012())
            {
                populateAddress(PartsHeaderList.SVMXC__Company__r.BillingStreet,  PartsHeaderList.SVMXC__Company__r.BillingCity ,  PartsHeaderList.SVMXC__Company__r.BillingState,  PartsHeaderList.SVMXC__Company__r.BillingPostalCode,  PartsHeaderList.SVMXC__Company__r.BillingCountry);
                Selected='Account Billing Address';
                desloc=true;
            }
                    
            if  ( SelectedAddressType ==getTAG013() )//|| SelectedAddressType ==null)
            {
                clearAddress(AddressFieldType);       
            }
        }

        public void setAddressForSourceLoc()
        {
            // Populating Source Address fields
            if(NewRMASHPHeader.SVMXC__Source_Location__c !=NULL)
            {
                String AddressFieldType='Source';
                SVMXC__Site__c LocS = new SVMXC__Site__c();
                LocS = [Select SVMXC__Street__c, SVMXC__State__c,SVMXC__City__c,SVMXC__Zip__c,SVMXC__Country__c from SVMXC__Site__c where Id=:NewRMASHPHeader.SVMXC__Source_Location__c];
                NewRMASHPHeader.SVMXC__Source_Street__c=LocS.SVMXC__Street__c;
                NewRMASHPHeader.SVMXC__Source_City__c=LocS.SVMXC__City__c;
                NewRMASHPHeader.SVMXC__Source_State__c=LocS.SVMXC__State__c;
                NewRMASHPHeader.SVMXC__Source_Zip__c=LocS.SVMXC__Zip__c;
                NewRMASHPHeader.SVMXC__Source_Country__c=LocS.SVMXC__Country__c;
            }
        }

        public void setAddressForTargetLoc()
        {
            // Populating Destination Address fields
            if(NewRMASHPHeader.SVMXC__Destination_Location__c !=null)
            {
                String AddressFieldType ='Destination';
                SVMXC__Site__c LocD = new SVMXC__Site__c();
                LocD = [Select Id, SVMXC__Street__c, SVMXC__State__c,SVMXC__City__c,SVMXC__Zip__c,SVMXC__Country__c from SVMXC__Site__c where Id=:NewRMASHPHeader.SVMXC__Destination_Location__c];
                NewRMASHPHeader.SVMXC__Destination_Location__c = LocD.Id;
                NewRMASHPHeader.SVMXC__Destination_Street__c=LocD.SVMXC__Street__c;
                NewRMASHPHeader.SVMXC__Destination_City__c=LocD.SVMXC__City__c;
                NewRMASHPHeader.SVMXC__Destination_State__c=LocD.SVMXC__State__c;
                NewRMASHPHeader.SVMXC__Destination_Zip__c=LocD.SVMXC__Zip__c;
                NewRMASHPHeader.SVMXC__Destination_Country__c=LocD.SVMXC__Country__c;
                
            }
        }

        public void populateAddress(String Street, String City, String State, String Zip, String Country)
        {
            NewRMASHPHeader.SVMXC__Destination_Street__c = Street;
            NewRMASHPHeader.SVMXC__Destination_City__c  = City;
            NewRMASHPHeader.SVMXC__Destination_State__c=  State;
            NewRMASHPHeader.SVMXC__Destination_Zip__c= Zip;
            NewRMASHPHeader.SVMXC__Destination_Country__c= Country;
        }

        public void clearAddress(String AddressFieldType)
        {
            NewRMASHPHeader.Destination_Location__c = null;
            NewRMASHPHeader.SVMXC__Destination_Street__c= '';
            NewRMASHPHeader.SVMXC__Destination_Street__c= '';
            NewRMASHPHeader.SVMXC__Destination_City__c  = '';
            NewRMASHPHeader.SVMXC__Destination_State__c=  '';
            NewRMASHPHeader.SVMXC__Destination_Zip__c= '';
            NewRMASHPHeader.SVMXC__Destination_Country__c='';
            desloc=false;
        }
        public boolean getdesloc(){
            return desloc;
        }
        
        public boolean getsavecheckS()
        {
            if((savecheckD==true)&&(savecheckS==true))
                message=false;
            else
                message=true;
            return message;
        }
        public boolean getLineErrorcheck()
        {
            return Linemessage;
        }
        public void Canceled(){displayTeamPopup=false;}      
        public void del(){ displayTeamPopup=true;}
        public Boolean getCheckAllLines() {return CheckAllLines;  }
        public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
        public Boolean getContinue() {return Cont;}
        public Boolean getdisplayTeamPopup() {return displayTeamPopup;}
    
        public String getTAG001(){ return system.label.PREQ007_TAG001;}//Create Shipment Order 
        public String getTAG002(){ return system.label.PREQ007_TAG002;}//Header Record Type
        public String getTAG003(){ return system.label.PREQ007_TAG003;}//Line Record Type
        public String getTAG004(){ return system.label.PREQ007_TAG004;}//Cancel
        public String getTAG005(){ return system.label.PREQ007_TAG005;}//Save
        public String getTAG006(){ return system.label.PREQ007_TAG006;}//Owner ID
        public String getTAG007(){ return system.label.PREQ007_TAG007;}//From Location
        public String getTAG008(){ return system.label.PREQ007_TAG008;}//To Location
        public String getTAG009(){ return system.label.PREQ007_TAG009;}//There are no pending Parts request lines to process //old = Select address type
        public String getTAG010(){ return system.label.PREQ007_TAG010;}//None
        public String getTAG011(){ return system.label.PREQ007_TAG011;}//Account Shipping Address
        public String getTAG012(){ return system.label.PREQ007_TAG012;}//Account Billing Address
        public String getTAG013(){ return system.label.PREQ007_TAG013;}//I will Enter a Address
        public String getTAG014(){ return system.label.PREQ007_TAG014;}//Select Address Type
        public String getTAG015(){ return system.label.PREQ007_TAG015;}//Create Shipment Order Help
        public String getTAG016(){ return system.label.PREQ007_TAG016;}//From Street
        public String getTAG017(){ return system.label.PREQ007_TAG017;}//To Street
        public String getTAG018(){ return system.label.PREQ007_TAG018;}//From City
        public String getTAG019(){ return system.label.PREQ007_TAG019;}//To City
        public String getTAG020(){ return system.label.PREQ007_TAG020;}//From State
        public String getTAG021(){ return system.label.PREQ007_TAG021;}//To State
        public String getTAG022(){ return system.label.PREQ007_TAG022;}//From Zip
        public String getTAG023(){ return system.label.PREQ007_TAG023;}//To Zip
        public String getTAG024(){ return system.label.PREQ007_TAG024;}//From Country
        public String getTAG025(){ return system.label.PREQ007_TAG025;}//To Country
        public String getTAG026(){ return system.label.PREQ007_TAG026;}//Continue
        public String getTAG027(){ return system.label.PREQ007_TAG027;}//Delete
        public String getTAG028(){ return system.label.PREQ007_TAG028;}//Are you sure you want to delete?
        public String getTAG029(){ return system.label.PREQ007_TAG029;}//Processing...
        public String getTAG030(){ return system.label.PREQ007_TAG030;}//Add Line
        public String getTAG031(){ return system.label.PREQ007_TAG031;}//Delete Line
        public String getTAG032(){ return system.label.PREQ007_TAG032;}//Get price
        public String getTAG033(){ return system.label.PREQ007_TAG033;}//Product
        public String getTAG034(){ return system.label.PREQ007_TAG034;}//Use PriceBook
        public String getTAG035(){ return system.label.PREQ007_TAG035;}//Expected Qty
        public String getTAG036(){ return system.label.PREQ007_TAG036;}//Line Price
        public String getTAG037(){ return system.label.PREQ007_TAG037;}//Discount%
        public String getTAG038(){ return system.label.PREQ007_TAG038;}//Expected Ship Date
        public String getTAG039(){ return system.label.PREQ007_TAG039;}//Shipment Lines
        public String getTAG040(){ return system.label.PREQ007_TAG040;}//Not all Fields relating to "From Address" are filled,Please Verify and click on Continue
        public String getTAG041(){ return system.label.PREQ007_TAG041;}//Not all Fields relating to "To Address" are filled, Please Verify and  Click Continue
        public String getTAG042(){ return system.label.PREQ007_TAG042;}//Account Billing Address~|~Account Shipping Address~|~I will Enter a Address
        public String getTAG043(){ return system.label.PREQ007_TAG043;}//Please select the "Use Pricebook" checkbox corresponding to the Required Product and click on Get price
        public String getTAG044(){ return system.label.PREQ007_TAG044;}//Please select the checkbox and click on delete Line
        public String getTAG045(){ return system.label.PREQ007_TAG045;}
        public String getTAG046(){ return system.label.PREQ007_TAG046;}
        public String getTAG047(){ return system.label.PREQ007_TAG047;}
        public String getTAG048(){ return system.label.PREQ007_TAG048;}
        public String getHLPURL(){ return system.label.PREQ007_HLPURL;}//Help Url
}