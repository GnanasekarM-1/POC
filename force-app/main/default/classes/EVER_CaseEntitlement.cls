public with Sharing class EVER_CaseEntitlement
{ 
    //----------------------NPS Related...
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    //-------------------------------------
    
    //Global variables for Settings & Translation
    public COMM_SVMXC_Utils2 objCls = new COMM_SVMXC_Utils2();
    public String SelectedEntType = ''; 
    public List<SVMXC__Warranty__c> WarrResults = new List<SVMXC__Warranty__c>();
    public List<EVER_SCResults> SCResults = new List<EVER_SCResults>();
    Integer ChildLevelIterations; 
    public String strTabName = 'name2';
    public String strDetailId;
    SVMXC.COMM_Utils_V2 utils = new SVMXC.COMM_Utils_V2();  
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> AllSubModuleSettings; 
    String tabname = '';//'Worranties/Service Contracts';  
    
    // List of Settings
    public String Setng_AllowFutureEnt;      //SET001
    public String Setng_AllowExpiredEnt;     //SET002
    public String Setng_DefaultEntType ;     //SET003  //Product or Account
    public String Setng_AllowMatchAccount ;  //SET004  
    public String Setng_AllowMatchContact;   //SET005  
    public String Setng_ApplicableSLACovLevel;   //SET006
    public String Setng_AllowEntFilters  ;     //SET016  
    public String Setng_DefaultChkCovParProd ; //SET007
    public String Setng_DefaultChkCovTopProd;  //SET008
    public String Setng_DefaultChkCovChdProd;  //SET009
    public String Setng_DefaultChkCovPartNo;   //SET010
    public String Setng_DefaultChkCovProdFam;  //SET011
    public String Setng_DefaultChkCovProdLine; //SET012
    public String Setng_NoOfChildLevels;       //SET013
    public String Setng_setBillType; //SET017
    public String Setng_saveEntitleRedirectDetail;//SET00018
    public boolean Setng_pageRedirect;
    Boolean setBillType = false;
    Boolean AllowEntFilters =false;
    Boolean setRedir=false;
    public String ObjectIs = '';
    public String AccountID ='';
    public String ContactID = '';
    public String strLocId = '';
    public String IBID = '';
    public Map<String,String> TagMap = new Map<String,String>();
    public String caseId = '';
    
    // Changes for Included services ***
    public String SelectedIS;
    public String strSelectedSCID{get;set;}
    public boolean isShowServicePopUp{get;set;}
    public boolean isServiceAvailable;
    public boolean getIsServiceAvailable(){return isServiceAvailable;}
    public void setIsServiceAvailable(boolean isvar){}
    public boolean isServiceAvailableOnSave;
    public boolean getIsServiceAvailableOnSave(){return isServiceAvailableOnSave;}
    public String strSlectedService;
    public boolean isShowServiceColum{get; set;}
    // Changes for Included services ***
    
    public String getStrSlectedService(){return strSlectedService;}
    public void setStrSlectedService(String str) {strSlectedService = str;}
    
    public string Setng_EntitleUsingDateFld = null;
    public boolean isNotEntitled = false;
    public boolean getisNotEntitled(){return this.isNotEntitled;}
    public void setisNotEntitled(boolean isNotEntitled){this.isNotEntitled = isNotEntitled;}
    
    /* Defect 002752(Nov.-15th): Calculate Case & WO permission. */
    public Boolean IsRendered = false;
    public Boolean getIsWOUpdatable()
    {
        Schema.DescribeSObjectResult r = SVMXC__Service_Order__c.sObjectType.getDescribe();
        return r.isUpdateable();
    }
    public Boolean getIsCaseUpdatable()
    {
        Schema.DescribeSObjectResult r = Case.sObjectType.getDescribe();
        return r.isUpdateable();
    }
    public Boolean getIsRendered()
    {
        IsRendered = false;
        if(ObjectIs == 'WorkOrder' && getIsWOUpdatable())
            IsRendered = true;
        if(ObjectIs == 'Case' && getIsCaseUpdatable())
            IsRendered = true;
        return IsRendered;
    }
    
    public List<EVER_SCResults.IncludedServicesWrapper> lstIncludedServicesWrpr = new List<EVER_SCResults.IncludedServicesWrapper>();
        public List<EVER_SCResults.IncludedServicesWrapper> getlstIncludedServicesWrpr() {return lstIncludedServicesWrpr;}
        public void setlstIncludedServicesWrpr(List<EVER_SCResults.IncludedServicesWrapper> lstISC) {lstIncludedServicesWrpr = lstISC;}
        
    
    /*******************************************************************************************************************
    Wrapper class   
    *******************************************************************************************************************/        
      //Defect 009668 : To remove permission binding on warranty object(check box).
    public class WarrantyWrapper{
        public SVMXC__Warranty__c objWarranty{set; get;}
        public boolean isSelect {set; get;}
        public WarrantyWrapper(boolean isSelect, SVMXC__Warranty__c objWarranty){
            this.isSelect = isSelect;
            this.objWarranty = objWarranty;
        }
    }
    public List<WarrantyWrapper> lstWarrantyWrapper{set; get;}
    
    public class WrapperClass
    {
        public Boolean Show_Future_Entitlements{get; set;}
        public Boolean Show_Expired_Entitlement{get; set;}
        public Boolean Match_Account{get; set;}
        public Boolean Match_Contact{get; set;}
        public Boolean Chk_Parent_Product{get; set;}
        public Boolean Chk_Top_Level_Product{get; set;}    
        public Boolean Chk_Child_Products{get; set;}
        public Boolean Chk_Part_Number{get; set;}   
        public Boolean Chk_Product_Family{get; set;}
        public Boolean Chk_Product_Line{get; set;}  
        public Boolean Match_Location{get; set;} //Added new variable for Entitlement enhancement..
    }
    WrapperClass EntOptions = new WrapperClass(); 
    public WrapperClass getMyObject() 
    {
        return EntOptions ;
    }
    /*******************************************************************************************************************
    Getter  & Setter Methods 
    *******************************************************************************************************************/
    public String getTabname(){return strTabName;}
    public void setTabname(string stn){this.strTabName=stn;}
    public String getDetailId(){return strDetailId;}
    public void setDetailId(string stn){this.strDetailId=stn;}
    public pageReference switchtab()
    {
       tabname=ApexPages.currentPage().getParameters().get('tabname');
       strDetailId=ApexPages.currentPage().getParameters().get('pid');
       strTabName='name3';
       return null;
    }
    public Boolean getAllowEntFilters(){return AllowEntFilters;}
    public void setAllowEntFilters(Boolean val){AllowEntFilters = val;}
    
    public list<SVMXC__Warranty__c> getSVMX_WarrResults()   {   return WarrResults ;     }  
    public void setSVMX_WarrResults(list<SVMXC__Warranty__c> wl)    {   WarrResults =wl; }  
        
    public list<SVMXC.EVER_SCResults>     getSVMX_SCResults()     {    return SCResults ;      } 
    public void setSVMX_SCResults(list<SVMXC.EVER_SCResults> sc)  {    SCResults =sc;      } 
    public Case csHdr ;    
    public void setCaseHdr(Case cs)   { this.csHdr = cs; }        
    public Case getCaseHdr(){ return csHdr;}
    
    //Added by amar dueto WO changes
    public SVMXC__Service_Order__c WOHdr = new SVMXC__Service_Order__c();
    public SVMXC__Service_Order__c getWOHdr(){return WOHdr;}
    public void setWOHdr(SVMXC__Service_Order__c WO){WOHdr = WO;}
    
    public String getObjectIs() {return ObjectIs;}
    
    public void setEntOptions(WrapperClass ent_opts)   { this.EntOptions = ent_opts; }        
    public WrapperClass getEntOptions(){ return EntOptions;}
    
    String entitlementType; //BAC-7 Enhancement
    
    /*******************************************************************************************************************
    Constructor 
    1. Validates the url parameters : Source Record Id  
    2. Validates and populates all the Settings
    3. Populates the Saved Service Contract/Warranty for the case
    *******************************************************************************************************************/    
    public EVER_CaseEntitlement()
    { 
        lstWarrantyWrapper = new List<WarrantyWrapper>();
        entitlementType = System.currentPageReference().getParameters().get('type'); 
        if(String.isNotBlank(entitlementType))
            entitlementType = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('type'));
        
        
        if(System.currentPageReference().getParameters().get('cid') != null)
        {
            caseId = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('cid'));
        }   
        if (caseId == null && caseId.length() == 0)
        {
            AddToErrorsList(getTag038());
        }
        String PrifixVal = Schema.SObjectType.Case.getKeyPrefix();
        if(caseId != null && caseId.length() > 0)
        {
            if(caseId.substring(0,3) == PrifixVal)
                ObjectIs = 'Case';
            else
                ObjectIs = 'WorkOrder';
        }
        getTagMap();
        getTabname();
        
        if(ObjectIs == 'Case')
        {
            AllSubModuleSettings= settings.SVMX_getSettingList('EVER001');  
            ValidateNPopulateSettings();      
            DisplayErrors();
        }
        if(ObjectIs == 'WorkOrder')
        {
            AllSubModuleSettings= settings.SVMX_getSettingList('EVER005');
            ValidateNPopulateSettings();         
            DisplayErrors();
        }
        if (ValidRecords == true)   
        {
            if(ObjectIs == 'Case')
            {
                setSelectedEntType(Setng_DefaultEntType);
                csHdr = new case();                     
                csHdr = getCaseData();
                if(csHdr.AccountId != null)
                    AccountID = csHdr.AccountId;
                if(csHdr.ContactId != null)
                    ContactID = csHdr.ContactId;    
                if(csHdr.SVMXC__Component__c != null)   
                    IBID = csHdr.SVMXC__Component__c;
                
                // Entitlement enhancement: Get the location Id from Case record
                if(csHdr.SVMXC__Site__c != null)   
                    strLocId = csHdr.SVMXC__Site__c;
                
                
                // Perform On load Entitlement, if Case has not entitled with  Contract or Warranty.
                if(csHdr.SVMXC__Warranty__c != null || csHdr.SVMXC__Service_Contract__c != null)
                {
                    PopulateSavedWarrSC();
                    isNotEntitled = false;
                }
                else
                {
                    SVMX_doCheckEntitlement();
                    if(csHdr.SVMXC__Is_Entitlement_Performed__c)
                        isNotEntitled = true;
                }
            }
            if(ObjectIs == 'WorkOrder')
            {
                setSelectedEntType(Setng_DefaultEntType);
                WOHdr = getWOData();
                if(WOHdr.SVMXC__Company__c != null)
                    AccountID = WOHdr.SVMXC__Company__c;
                if(WOHdr.SVMXC__Contact__c != null)
                    ContactID = WOHdr.SVMXC__Contact__c;    
                if(WOHdr.SVMXC__Component__c != null)   
                    IBID = WOHdr.SVMXC__Component__c;
                
                // Entitlement enhancement: Get the location Id from Work Order record
                if(WOHdr.SVMXC__Site__c != null)   
                    strLocId = WOHdr.SVMXC__Site__c;
                                
                
                //Onload: Perform entitlment.
                if(WOHdr.SVMXC__Warranty__c != null || WOHdr.SVMXC__Service_Contract__c != null)
                {
                    PopulateSavedWarrSC();
                    isNotEntitled = false;
                }
                else
                {
                    SVMX_doCheckEntitlement();
                    if(WOHdr.SVMXC__Is_Entitlement_Performed__c)
                        isNotEntitled = true;
                }
            }
        }   
        else
            setDisplayForm(false); 
        //getTagMap();    
        tabname=getTAG071();
        //getTabname();
        // Changes for Included services ***
        if(AllSubModuleSettings.containsKey('SET022') && AllSubModuleSettings.get('SET022').toUpperCase() == 'TRUE')
            isShowServiceColum = true;
        else
            isShowServiceColum = false;
        isServiceAvailable = true;
        isServiceAvailableOnSave = true;
        
    }
    
    public pageReference PageRedirect(){
        pageReference pgr;
        if(ObjectIs == 'WorkOrder' && Setng_pageRedirect){
           String redirectUrl = '/apex/EVER_WOEntitlement?id=' + caseId;
           if(entitlementType != null){
              entitlementType = entitlementType;
              redirectUrl += '&type=' + entitlementType;    
           }
           pgr = new pageReference(redirectUrl);
           return pgr;
        }
        return null;    
    }
    /*******************************************************************************************************************
    Method to validate the availability of all the required Setting Values
    *******************************************************************************************************************/
    public void ValidateNPopulateSettings()
    { 
        if (AllSubModuleSettings.size()==0)
        { 
            AddToErrorsList(getTag001()); //Settings not available for the SubModule: Entitlement Verification
        }    
        else
        {
            ////else1 SET001            
            Setng_AllowFutureEnt =AllSubModuleSettings.get('SET001'); 
            if(Setng_AllowFutureEnt ==null)
            {    
                AddToErrorsList(getTag001()); //Setting not available for : Allow Future Entitlement
            }   
            else
            {
                if(Setng_AllowFutureEnt.toUpperCase()=='TRUE')
                {
                    EntOptions.Show_Future_Entitlements= true;
                }
                else
                {
                    EntOptions.Show_Future_Entitlements= false;
                }               
            }
            ////else1 SET002  
            Setng_AllowExpiredEnt = AllSubModuleSettings.get('SET002'); 
            if(Setng_AllowExpiredEnt ==null)
            {   
                AddToErrorsList(getTag001()); //Setting not available for : Allow Expired Entitlement
            }   
            else
            {
                if(Setng_AllowExpiredEnt.toUpperCase()=='TRUE')
                { 
                        EntOptions.Show_Expired_Entitlement= true;
                }                
                else
                {
                    EntOptions.Show_Expired_Entitlement= false;
                }   
            }  
            //SET003       
            Setng_DefaultEntType =AllSubModuleSettings.get('SET003');   
            if (Setng_DefaultEntType ==null) 
            {
                AddToErrorsList(getTag001()); //Setting not available for : Default Entitlement Type
            }   
            else
            {   
                if(Setng_DefaultEntType=='Account')
                    SelectedEntType='Account';   
                else if(Setng_DefaultEntType=='Product')    
                    SelectedEntType='Product';   
                setApplicableEntitlementType(SelectedEntType); 
            }
            //SET004        
            Setng_AllowMatchAccount = AllSubModuleSettings.get('SET004');  
            if (Setng_AllowMatchAccount ==null)  
                AddToErrorsList(getTag001()); //Setting not available for :Allow Match Account
            else
            {
                if(Setng_AllowMatchAccount.toUpperCase()=='TRUE')   
                    EntOptions.Match_Account=true; 
                else
                    EntOptions.Match_Account=false;                        
            }              
            //SET005            
            Setng_AllowMatchContact = AllSubModuleSettings.get('SET005');  
            if (Setng_AllowMatchContact ==null) 
                AddToErrorsList(getTag001()); //Setting not available for :Allow Match Contact
            else
            {
                if(Setng_AllowMatchContact.toUpperCase()=='TRUE')
                    EntOptions.Match_Contact=true;  
                else
                    EntOptions.Match_Contact=false; 
            }   
            //SET006     
            Setng_ApplicableSLACovLevel   = AllSubModuleSettings.get('SET006');
            system.debug('Setng_ApplicableSLACovLevel' + Setng_ApplicableSLACovLevel);
            if (Setng_ApplicableSLACovLevel ==null) 
                AddToErrorsList(getTag001()); //Setting not available for:Applicable SLA Coverage Level
            //SET007        
            Setng_DefaultChkCovParProd =AllSubModuleSettings.get('SET007');         
            if (Setng_DefaultChkCovParProd==null)  
                AddToErrorsList(getTag001()); //Setting not available for :Default Coverage for Parent Product
            else
            { 
                if (Setng_DefaultChkCovParProd.toUpperCase() =='TRUE')  
                    EntOptions.Chk_Parent_Product=true;
            }    
            //SET008        
            Setng_DefaultChkCovTopProd =AllSubModuleSettings.get('SET008');         
            if (Setng_DefaultChkCovTopProd==null)  
                AddToErrorsList(getTag001()); //Setting not available for :Default Coverage for Top-Level Product
            else
            { 
                if (Setng_DefaultChkCovTopProd.toUpperCase() =='TRUE') 
                    EntOptions.Chk_Top_Level_Product=true;
            }            
            //SET009        
            Setng_DefaultChkCovChdProd =AllSubModuleSettings.get('SET009');
            if (Setng_DefaultChkCovChdProd==null) 
                AddToErrorsList(getTag001()); //Setting not available for :Default Coverage for Child Product
            else
            {
                    if(Setng_DefaultChkCovChdProd.toUpperCase() =='TRUE')  
                        EntOptions.Chk_Child_Products=true;
            }
            //SET010        
            Setng_DefaultChkCovPartNo =AllSubModuleSettings.get('SET010');
            if (Setng_DefaultChkCovPartNo==null) 
                AddToErrorsList(getTag001()); //Setting not available for :Default Coverage for Part Number
            else
            {   
                if(Setng_DefaultChkCovPartNo.toUpperCase() =='TRUE')   
                    EntOptions.Chk_Part_Number=true;
            }         
            //SET011        
            Setng_DefaultChkCovProdFam =AllSubModuleSettings.get('SET011');
            if (Setng_DefaultChkCovProdFam==null) 
                AddToErrorsList(getTag001()); //Setting not available for :Default Coverage for Product Family
            else
            {
                if(Setng_DefaultChkCovProdFam.toUpperCase() =='TRUE')  
                    EntOptions.Chk_Product_Family=true;
            }                
            //SET012        
            Setng_DefaultChkCovProdLine =AllSubModuleSettings.get('SET012');
            if (Setng_DefaultChkCovProdLine==null) 
                AddToErrorsList(getTag001()); //Setting not available for :Default Coverage for Product Line
            else
            {
                if(Setng_DefaultChkCovProdLine.toUpperCase() =='TRUE')    
                    EntOptions.Chk_Product_Line=true;
            }
            //SET013
            Setng_NoOfChildLevels =AllSubModuleSettings.get('SET013');
            try
            {
                if((Setng_NoOfChildLevels==null)||(Setng_NoOfChildLevels.length()<=0))
                    AddToErrorsList(getTag001()); //Setting not available for :Number Of IB Child Levels
                else if(integer.valueOf(Setng_NoOfChildLevels)<0)
                    AddToErrorsList(getTag001()); //Invalid value for the Setting :Number of Product Child Level Iterations
                else
                {
                    ChildLevelIterations  = integer.valueOf(Setng_NoOfChildLevels);   
                } 
            } 
            catch (Exception e)
            {
                setDisplayForm(false);
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTag001()));
            }
            //SET016
            Setng_AllowEntFilters   = AllSubModuleSettings.get('SET016');  
            if (Setng_AllowEntFilters ==null)
                AddToErrorsList(getTag001()); //Setting not available for:Allow Entitlement Filters
            else
            {
                if(Setng_AllowEntFilters.toUpperCase()!='TRUE')  
                    AllowEntFilters =false;
                else
                AllowEntFilters =true;
            }
            //SET017        
            Setng_setBillType =AllSubModuleSettings.get('SET017');
            if(Setng_setBillType==null) 
                AddToErrorsList(getTag001()); //Setting not available for :Default Coverage for Product Line
            else
            {
                if(Setng_setBillType.toUpperCase() == 'TRUE')     
                    setBillType = true;
            }
            //SET00018
            Setng_saveEntitleRedirectDetail = AllSubModuleSettings.get('SET018');           
            if(Setng_saveEntitleRedirectDetail==null) 
                AddToErrorsList(getTag001()); 
            else
            {
                if(Setng_saveEntitleRedirectDetail.toUpperCase() == 'TRUE') 
                    setRedir = true;
            }
        
            //Match Location(SET00020): Setting for Covered Location.
            string Setng_isAllowMatchLoc = AllSubModuleSettings.get('SET020');
            if(Setng_isAllowMatchLoc == null)
                AddToErrorsList(getTag001());
            else
            {
                if(Setng_isAllowMatchLoc.toUpperCase()=='TRUE')
                    EntOptions.Match_Location = true;
                else
                    EntOptions.Match_Location= false;
            }
            
            // Entitlement enhancement (SET00021): Setting to get the field Name by Using is Case Entitled.
            if(AllSubModuleSettings.get('SET021') == null)
                AddToErrorsList(System.Label.EVER001_TAG001);
            else if(AllSubModuleSettings.containsKey('SET021') && AllSubModuleSettings.get('SET021') != null)
                Setng_EntitleUsingDateFld = AllSubModuleSettings.get('SET021');
            
            if(AllSubModuleSettings.get('SET025') == null)
                Setng_pageRedirect = false;
            else if(AllSubModuleSettings.containsKey('SET025') && AllSubModuleSettings.get('SET025') != null)
                Setng_pageRedirect = boolean.valueof(AllSubModuleSettings.get('SET025'));
        }
    } 
    /*******************************************************************************************************************
    Variables with get & set methods to manage Errors and Warnings
    *******************************************************************************************************************/
    Boolean ValidRecords = true;
    List<String> ErrorMessages = new  List<String> ();
    List<String> WarningMessages = new  List<String> ();
    public void AddToErrorsList(String msg) { ErrorMessages.add(msg); }
    public List<String> getErrorsList() {    return ErrorMessages; }  
    Boolean DisplayForm = true; 
    public Boolean getDisplayForm(){ return DisplayForm; }
    public void setDisplayForm(Boolean  val){ DisplayForm = val; }
    /*******************************************************************************************************************
    Method to Display Errors 
    *******************************************************************************************************************/
    public void DisplayErrors()
    {
        if(ErrorMessages != null && ErrorMessages.size()>0)
        {
            ValidRecords = false;  
            for (String msg : ErrorMessages)
            {
                if(msg != null)
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,msg)) ;                     
            }                   
        }   
    }    
    /**********************************************************************************************************************
    Options for Entitlement Types
    ***********************************************************************************************************************/
    public List<SelectOption> getEntitlementTypes() 
    {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption(getTAG002(),getTAG002()));
        //options.add(new SelectOption(getTAG003(),getTAG003()));
        //Modified for defect 011431 - if user change their language other than English then condition is not satisfying and causing problem.
        options.add(new SelectOption('Account',getTAG002()));
        options.add(new SelectOption('Product',getTAG003()));
        return options;
    }
    public String getSelectedEntType() {return SelectedEntType; }
    public void setSelectedEntType(String EType) 
    {   
        setApplicableEntitlementType(EType);
        this.SelectedEntType = EType; 
    }
    /*******************************************************************************************************************
    Methods to set the Entitlement Type(Based on User Selection)
    *******************************************************************************************************************/
    //This method gets invoked on selection of Entitlement Type Radio Button
    public void UpdateEntitlementType()
    {
        setApplicableEntitlementType(SelectedEntType);      
    }
    public void setApplicableEntitlementType(String SelectedEtype)
    {  
        SelectedEntType = SelectedEtype;                     
    }
    
    //Method to retrieve Case details
    public Case getCaseData()
    {
        Case CaseRec = new Case();            
        String SOQLHeader;  
        try
        {
            //Populating FieldNames for Case                   
            Set<String> setCaseFlds = new Set<String>();
            setCaseFlds.add('AccountId');
            setCaseFlds.add('CaseNumber');
            setCaseFlds.add('ContactId');
            setCaseFlds.add('SVMXC__Billing_Type__c');
            setCaseFlds.add('SVMXC__Component__c');
            setCaseFlds.add('SVMXC__Entitlement_Notes__c');
            setCaseFlds.add('SVMXC__Entitlement_Type__c');
            setCaseFlds.add('SVMXC__Perform_Auto_Entitlement__c');
            setCaseFlds.add('SVMXC__Product__c');
            setCaseFlds.add('SVMXC__SLA_Terms__c');
            setCaseFlds.add('SVMXC__Service_Contract__c');
            setCaseFlds.add('SVMXC__Site__c');
            setCaseFlds.add('SVMXC__Top_Level__c');
            setCaseFlds.add('SVMXC__Warranty__c');
            setCaseFlds.add('Description');
            setCaseFlds.add('Id');
            setCaseFlds.add('SVMXC__Is_Entitlement_Performed__c');
            setCaseFlds.add('SVMXC__Auto_Entitlement_Status__c');
            setCaseFlds.add('Contact.Name');
            setCaseFlds.add('Account.Name');
            setCaseFlds.add('SVMXC__Component__r.Name'); 
            setCaseFlds.add('SVMXC__Component__r.SVMXC__Parent__c');
            setCaseFlds.add('SVMXC__Component__r.SVMXC__Top_Level__c');
            setCaseFlds.add('SVMXC__Component__r.SVMXC__Parent__r.SVMXC__Product__c');
            setCaseFlds.add('SVMXC__Component__r.SVMXC__Product__c');
            setCaseFlds.add('SVMXC__Component__r.SVMXC__Product__r.Family');
            setCaseFlds.add('SVMXC__Component__r.SVMXC__Product__r.SVMXC__Product_Line__c');
            setCaseFlds.add('SVMXC__Warranty__r.Name');
            setCaseFlds.add('SVMXC__Warranty__r.SVMXC__Start_Date__c');
            setCaseFlds.add('SVMXC__Warranty__r.SVMXC__End_Date__c');
            setCaseFlds.add('SVMXC__Warranty__r.SVMXC__Installed_Product__c');
            setCaseFlds.add('SVMXC__Warranty__r.SVMXC__Service_Template__c');
            setCaseFlds.add('SVMXC__Service_Contract__r.Name');
            setCaseFlds.add('SVMXC__SLA_Terms__r.Name');
            setCaseFlds.add('SVMXC__Service_Contract__r.SVMXC__Start_Date__c');
            setCaseFlds.add('SVMXC__Service_Contract__r.SVMXC__End_Date__c');
            setCaseFlds.add('SVMXC__Service_Contract__r.SVMXC__Service_Level__c');
            setCaseFlds.add('SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name');
            
            system.debug('AllSubModuleSettings---' + AllSubModuleSettings.containsKey('SET022'));
            if(AllSubModuleSettings.containsKey('SET022') && AllSubModuleSettings.get('SET022').toUpperCase() == 'TRUE' )
            {
                set<string> setProcessIds = new set<string>();
                
                for(SVMXC__Service__c currService : [Select SVMXC__Qualifying_Criteria__c, Id from SVMXC__Service__c where SVMXC__Qualifying_Criteria__c != NULL AND SVMXC__Tracked_On__c = 'Case'])
                {
                    if(currService.SVMXC__Qualifying_Criteria__c != null)
                        setProcessIds.add(currService.SVMXC__Qualifying_Criteria__c);   
                }
                    
                if(setProcessIds != null && setProcessIds.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c oExpression :  [Select SVMXC__Field_Name__c, SVMXC__Field_Relationship_Name__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Type__c = 'EXP_Named' AND RecordType.Name='Expressions' AND SVMXC__Expression_Rule__c IN: setProcessIds])
                    {
                        if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setCaseFlds.contains(oExpression.SVMXC__Field_Name__c))
                        { 
                            setCaseFlds.add(oExpression.SVMXC__Field_Name__c);
                            if(oExpression.SVMXC__Display_Type__c == 'REFERENCE')
                                setCaseFlds.add(oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c);
                        }
                    }
                }
            }
            
            String strCaseFldsQry = '';
            for (String field : setCaseFlds) 
            {
                if(strCaseFldsQry.length() > 0) 
                    strCaseFldsQry += ', ';
                strCaseFldsQry += field;
            }

            system.debug('Case Fields : ' + strCaseFldsQry);
            SOQLHeader = ' SELECT ' + strCaseFldsQry + ' FROM Case where Id =: caseId';
            CaseRec = Database.query(SOQLHeader);                      
        } 
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
        }
        return CaseRec;        
    }
    
    //Method to retrieve Work Order details
    public SVMXC__Service_Order__c getWOData()
    {        
        SVMXC__Service_Order__c WORec = new SVMXC__Service_Order__c();            
        set<string> setProcessIds = new set<string>();
        String SOQLHeader;  
        
        try
        {
            //Populating FieldNames for Case
            Set<String> setWorkOrdFlds = new Set<String>();
            setWorkOrdFlds.add('SVMXC__Warranty__c');
            setWorkOrdFlds.add('SVMXC__Top_Level__c');
            setWorkOrdFlds.add('SVMXC__Service_Contract__c');
            setWorkOrdFlds.add('SVMXC__SLA_Terms__c');
            setWorkOrdFlds.add('SVMXC__Product__c');
            setWorkOrdFlds.add('SVMXC__Entitlement_Notes__c');
            setWorkOrdFlds.add('SVMXC__Contact__c');
            setWorkOrdFlds.add('SVMXC__Component__c');
            setWorkOrdFlds.add('SVMXC__Company__c');
            setWorkOrdFlds.add('SVMXC__Case__c');
            setWorkOrdFlds.add('SVMXC__Billing_Type__c');
            setWorkOrdFlds.add('Name');
            setWorkOrdFlds.add('Id');
            setWorkOrdFlds.add('SVMXC__Site__c');
            setWorkOrdFlds.add('SVMXC__Is_Entitlement_Performed__c');
            setWorkOrdFlds.add('SVMXC__Component__r.Name'); 
            setWorkOrdFlds.add('SVMXC__Component__r.SVMXC__Parent__c');
            setWorkOrdFlds.add('SVMXC__Component__r.SVMXC__Top_Level__c');            
            setWorkOrdFlds.add('SVMXC__Component__r.SVMXC__Parent__r.SVMXC__Product__c');                         
            setWorkOrdFlds.add('SVMXC__Component__r.SVMXC__Product__c');
            setWorkOrdFlds.add('SVMXC__Component__r.SVMXC__Product__r.Family');
            setWorkOrdFlds.add('SVMXC__Component__r.SVMXC__Product__r.SVMXC__Product_Line__c');
            setWorkOrdFlds.add('SVMXC__Warranty__r.Name');
            setWorkOrdFlds.add('SVMXC__Warranty__r.SVMXC__Start_Date__c');
            setWorkOrdFlds.add('SVMXC__Warranty__r.SVMXC__End_Date__c');
            setWorkOrdFlds.add('SVMXC__Warranty__r.SVMXC__Installed_Product__c');
            setWorkOrdFlds.add('SVMXC__Warranty__r.SVMXC__Service_Template__c');                                 
            setWorkOrdFlds.add('SVMXC__Service_Contract__r.Name');
            setWorkOrdFlds.add('SVMXC__SLA_Terms__r.Name'); 
            setWorkOrdFlds.add('SVMXC__Service_Contract__r.SVMXC__Start_Date__c');
            setWorkOrdFlds.add('SVMXC__Service_Contract__r.SVMXC__End_Date__c');
            setWorkOrdFlds.add('SVMXC__Service_Contract__r.SVMXC__Service_Level__c');
            setWorkOrdFlds.add('SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name');   
            setWorkOrdFlds.add('SVMXC__Contact__r.Name');
            setWorkOrdFlds.add('SVMXC__Company__r.Name');
            
            if(AllSubModuleSettings.containsKey('SET022') && AllSubModuleSettings.get('SET022').toUpperCase() == 'TRUE' )
            {
                for(SVMXC__Service__c currService : [Select SVMXC__Qualifying_Criteria__c, Id from SVMXC__Service__c where SVMXC__Qualifying_Criteria__c != NULL AND SVMXC__Tracked_On__c = 'Work Order'])
                {
                    if(currService.SVMXC__Qualifying_Criteria__c != null)
                        setProcessIds.add(currService.SVMXC__Qualifying_Criteria__c);   
                }
                    
                if(setProcessIds != null && setProcessIds.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c oExpression :  [Select SVMXC__Field_Name__c, SVMXC__Field_Relationship_Name__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Type__c = 'EXP_Named' AND RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c IN: setProcessIds])
                    {
                        if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setWorkOrdFlds.contains(oExpression.SVMXC__Field_Name__c))
                        { 
                            setWorkOrdFlds.add(oExpression.SVMXC__Field_Name__c);
                            if(oExpression.SVMXC__Display_Type__c == 'REFERENCE')
                                setWorkOrdFlds.add(oExpression.SVMXC__Field_Relationship_Name__c + '.' + oExpression.SVMXC__FKey_Name_Field__c);
                        }
                    }
                }
            }
            
            String strWOFldsQry = '';
            for (String field : setWorkOrdFlds) 
            {
                if(strWOFldsQry.length() > 0) 
                    strWOFldsQry += ', ';
                strWOFldsQry += field;
            }
            
            SOQLHeader = '  SELECT ' + strWOFldsQry + ' FROM SVMXC__Service_Order__c where Id=: caseId';
            WORec = Database.query(SOQLHeader);                      
        } 
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
        }
        return WORec;        
    }   
    
    //Method to Populate Saved Warranty / Service Contract for Case
    //Method to Populate Saved Warranty / Service Contract for Case
        public void PopulateSavedWarrSC()
        {
            list<SVMXC__Entitlement_History__c> lstEntlHistory = new list<SVMXC__Entitlement_History__c>();
            if(csHdr != null)
            {
                //Check for the Entitlement History.
                if(csHdr.Id != null)
                    lstEntlHistory = [Select SVMXC__Covered_By__c, SVMXC__Entitled_By_Service__c, SVMXC__Entitled_By_Service__r.SVMXC__Service__c from SVMXC__Entitlement_History__c where SVMXC__Case__c =: csHdr.Id AND SVMXC__Inactive_Date__c = NULL];
                    
                if (csHdr.SVMXC__Service_Contract__c !=null)
                {
                    SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
                    TempRecord.SCId =csHdr.SVMXC__Service_Contract__c;
                    TempRecord.SCName =csHdr.SVMXC__Service_Contract__r.Name;
                    if(lstEntlHistory != NULL && lstEntlHistory.size() == 1)
                        TempRecord.CoveredBy = lstEntlHistory[0].SVMXC__Covered_By__c;
                    TempRecord.StartDate =csHdr.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                    TempRecord.EndDate = csHdr.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                    TempRecord.SLAID = csHdr.SVMXC__SLA_Terms__c;
                    TempRecord.SLAName = csHdr.SVMXC__SLA_Terms__r.Name;
                    AddToSCResult(TempRecord);
                    
                    //for populating services also with service contract
                    // Changes for Included services ***
                    if(AllSubModuleSettings.containsKey('SET022') && AllSubModuleSettings.get('SET022').toUpperCase() == 'TRUE')
                    {
                        if(lstEntlHistory != NULL && lstEntlHistory.size() == 1 && SCResults != null && SCResults.size() >0 )
                        {
                            boolean isShowAllServices = false;
                            if(AllSubModuleSettings.containsKey('SET023') && AllSubModuleSettings.get('SET023').toUpperCase() == 'TRUE' )
                            {
                                isShowAllServices = true;
                            }
                            if(ObjectIs == 'Case')
                            {
                                new EVER_Entitlement_Utils().GetServicesOfSCON(SCResults, ObjectIs, csHdr, !(isShowAllServices), csHdr.SVMXC__Service_Contract__c, lstEntlHistory[0].SVMXC__Entitled_By_Service__c);
                            }
                            for(EVER_SCResults SCResult : SCResults)
                            {
                                if(csHdr.SVMXC__Service_Contract__c ==  SCResult.SCId && SCResult.lstISWrapper != null && SCResult.lstISWrapper.size() > 0)
                                {
                                    if(lstEntlHistory[0].SVMXC__Entitled_By_Service__r.SVMXC__Service__c != null)
                                    {
                                        for(EVER_SCResults.IncludedServicesWrapper SCISWrpr : SCResult.lstISWrapper)
                                        {
                                            if(SCISWrpr.IncludedServices.SVMXC__Service__c == lstEntlHistory[0].SVMXC__Entitled_By_Service__r.SVMXC__Service__c)
                                            {
                                                SCISWrpr.isSelected = true;
                                                SCResult.idSelectdIS = SCISWrpr.IncludedServices.Id;
                                                SCResult.strNameIS = SCISWrpr.IncludedServices.SVMXC__Service__r.Name;
                                                if(SCISWrpr.IncludedServices.SVMXC__Included_Units__c == null || SCISWrpr.IncludedServices.SVMXC__Included_Units__c == 0)
                                                    SCResult.strUnitsAvl = getTAG103();
                                                else
                                                {
                                                    if(Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Consumed_Units__c) > 0)
                                                        SCResult.strUnitsAvl = String.valueOf(Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Consumed_Units__c));
                                                    else
                                                        SCResult.strUnitsAvl = '0';
                                                }
                                            }
                                            else
                                                SCISWrpr.isSelected = false;
                                        }
                                    }
                                    else
                                    {
                                        for(EVER_SCResults.IncludedServicesWrapper SCISWrpr : SCResult.lstISWrapper)
                                        {
                                            SCISWrpr.isSelected = false;
                                        }
                                        SCResult.lstISWrapper[0].isSelected = true;
                                        SCResult.idSelectdIS = null;
                                        SCResult.strNameIS = '';//SCResult.lstISWrapper[0].IncludedServices.SVMXC__Service__r.Name;
                                        SCResult.strUnitsAvl = '';
                                    }
                                }
                            }
                        }
                    }

                }
                else if (csHdr.SVMXC__Warranty__c !=null)
                {
                    SVMXC__Warranty__c SavedWarranty ;
                    try
                    {
                        SavedWarranty = [select s.SVMXC__Start_Date__c,SVMXC__Select__c,                 
                                                s.SVMXC__Service_Template__c, s.SVMXC__Installed_Product__c,
                                                s.SVMXC__End_Date__c, s.Name, s.Id From SVMXC__Warranty__c s
                                         where s.Id = :csHdr.SVMXC__Warranty__c];                                    
                    }
                    catch (Exception e){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));} 
                    if (SavedWarranty!=null)                 
                        //WarrResults.add(SavedWarranty);    //Defect 009668 : To remove permission binding on warranty object(check box).
                        lstWarrantyWrapper.add(new WarrantyWrapper(false, SavedWarranty));
                }
            }
            else if(WOHdr != null)
            {
                //Check for the Entitlement History.
                if(WOHdr.Id != null)
                {
                    lstEntlHistory = [Select SVMXC__Covered_By__c, SVMXC__Entitled_By_Service__c, SVMXC__Entitled_By_Service__r.SVMXC__Service__c from SVMXC__Entitlement_History__c where SVMXC__Service_Order__c =: WOHdr.Id AND SVMXC__Inactive_Date__c = NULL];
                }

                if (WOHdr.SVMXC__Service_Contract__c !=null)
                {   
                    SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
                    TempRecord.SCId =WOHdr.SVMXC__Service_Contract__c;
                    TempRecord.SCName =WOHdr.SVMXC__Service_Contract__r.Name; 
                    if(lstEntlHistory != NULL && lstEntlHistory.size() == 1)
                        TempRecord.CoveredBy = lstEntlHistory[0].SVMXC__Covered_By__c;              
                    TempRecord.StartDate =WOHdr.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;                        
                    TempRecord.EndDate = WOHdr.SVMXC__Service_Contract__r.SVMXC__End_Date__c;                       
                    TempRecord.SLAID = WOHdr.SVMXC__SLA_Terms__c;                 
                    TempRecord.SLAName = WOHdr.SVMXC__SLA_Terms__r.Name;
                    AddToSCResult(TempRecord);
                    // Changes for Included services ***
                    System.debug('log level for SCResults 1 : '+SCResults);
                    if(AllSubModuleSettings.containsKey('SET022') && AllSubModuleSettings.get('SET022').toUpperCase() == 'TRUE')
                    {
                        if(lstEntlHistory != NULL && lstEntlHistory.size() == 1 && SCResults != null && SCResults.size() >0)
                        {
                            boolean isShowAllServices = false;
                            if(AllSubModuleSettings.containsKey('SET023') && AllSubModuleSettings.get('SET023').toUpperCase() == 'TRUE' )
                            {
                                isShowAllServices = true;
                            }
                            if(ObjectIs == 'WorkOrder')
                            {
                                new EVER_Entitlement_Utils().GetServicesOfSCON(SCResults, ObjectIs, WOHdr, !(isShowAllServices), WOHdr.SVMXC__Service_Contract__c, lstEntlHistory[0].SVMXC__Entitled_By_Service__c);
                            }
                            for(EVER_SCResults SCResult : SCResults)
                            {
                                if(WOHdr.SVMXC__Service_Contract__c ==  SCResult.SCId && SCResult.lstISWrapper != null && SCResult.lstISWrapper.size() > 0)
                                {
                                    if(lstEntlHistory[0].SVMXC__Entitled_By_Service__r.SVMXC__Service__c != null)
                                    {
                                        for(EVER_SCResults.IncludedServicesWrapper SCISWrpr : SCResult.lstISWrapper)
                                        {
                                            if(SCISWrpr.IncludedServices.SVMXC__Service__c == lstEntlHistory[0].SVMXC__Entitled_By_Service__r.SVMXC__Service__c)
                                            {
                                                SCISWrpr.isSelected = true;
                                                SCResult.idSelectdIS = SCISWrpr.IncludedServices.Id;
                                                SCResult.strNameIS = SCISWrpr.IncludedServices.SVMXC__Service__r.Name;
                                                if(SCISWrpr.IncludedServices.SVMXC__Included_Units__c == null || SCISWrpr.IncludedServices.SVMXC__Included_Units__c == 0)
                                                    SCResult.strUnitsAvl = getTAG103();
                                                else
                                                {
                                                    if(Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Consumed_Units__c) > 0)
                                                        SCResult.strUnitsAvl = String.valueOf(Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Consumed_Units__c));
                                                    else
                                                        SCResult.strUnitsAvl = '0';
                                                }
                                            }
                                            else
                                                SCISWrpr.isSelected = false;
                                        }
                                    }
                                    else
                                    {
                                        for(EVER_SCResults.IncludedServicesWrapper SCISWrpr : SCResult.lstISWrapper)
                                        {
                                            SCISWrpr.isSelected = false;
                                        }
                                        SCResult.lstISWrapper[0].isSelected = true;
                                        SCResult.idSelectdIS = null;
                                        SCResult.strNameIS = '';//SCResult.lstISWrapper[0].IncludedServices.SVMXC__Service__r.Name;
                                        SCResult.strUnitsAvl = '';
                                    }
                                }
                            }
                        }
                    }
                    System.debug('log level for SCResults 2 : '+SCResults);
                }
                else if (WOHdr.SVMXC__Warranty__c !=null)
                {
                    SVMXC__Warranty__c SavedWarranty ;
                    try
                    {
                        SavedWarranty = [select s.SVMXC__Start_Date__c,SVMXC__Select__c, s.SVMXC__Service_Template__c, s.SVMXC__Installed_Product__c, s.SVMXC__End_Date__c, s.Name, s.Id From SVMXC__Warranty__c s where s.Id = :WOHdr.SVMXC__Warranty__c];                                    
                    }
                    catch (Exception e){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));} 
                    if(SavedWarranty!=null)
                        //WarrResults.add(SavedWarranty);   //Defect 009668 : To remove permission binding on warranty object(check box).
                        lstWarrantyWrapper.add(new WarrantyWrapper(false, SavedWarranty));
                }
            } 
            
            
        }
        
    
    //Method to validate Search Criteria
    public Boolean isValidSearchCriteria()
    {
        ValidRecords = true;
        if(ObjectIs == 'Case')
        {          
            if(SelectedEntType=='Account')
            {
                if(csHdr.AccountId ==null)
                    AddToErrorsList(getTAG053()); //Account is not available
            }
            if(SelectedEntType == 'Product')
            {   
                if(csHdr.SVMXC__Component__c ==null)
                    AddToErrorsList(getTAG055()); //Product is not available
                
                if((csHdr.AccountId ==null)&&(EntOptions.Match_Account==true))  
                    AddToErrorsList(getTAG053()); //Account is not available
                
                if((csHdr.ContactId ==null)&&(EntOptions.Match_Contact==true))  
                    AddToErrorsList(getTAG054()); //Contact is not available
                
                if( (csHdr.SVMXC__Product__c ==null)&&(EntOptions.Chk_Part_Number ==true))  
                    AddToErrorsList(getTAG056()); //Part Number is not available
            }
        }
        if(ObjectIs == 'WorkOrder')
        {
            if(SelectedEntType=='Account')
            {
                if(WOHdr.SVMXC__Company__c == null)
                    AddToErrorsList(getTAG053()); //Account is not available
            }
            if(SelectedEntType == 'Product')
            {   
                if(WOHdr.SVMXC__Component__c == null)                                        
                    AddToErrorsList(getTAG055()); //Product is not available
                
                if((WOHdr.SVMXC__Company__c == null)&&(EntOptions.Match_Account==true))  
                    AddToErrorsList(getTAG053()); //Account is not available
                
                if((WOHdr.SVMXC__Contact__c == null)&&(EntOptions.Match_Contact==true))  
                    AddToErrorsList(getTAG054()); //Contact is not available
                
                if((WOHdr.SVMXC__Product__c == null)&&(EntOptions.Chk_Part_Number ==true))  
                    AddToErrorsList(getTAG056()); //Part Number is not available
            }
        }
        DisplayErrors();  
        return ValidRecords;  
    }
    
    /*******************************************************************************************************************
    Method to check Entitlement
    ---------------------------
    1. Retrieves all the Warranty Records for the Installed Product 
       based on Entitlement Options & No. of Child Level Iterations ( for Product -Based Entitlement)
    2.If Entitlement Type is 'Account', retrieves all the Service Contracts for the Account associated with the Case,
      irrespective of the checkboxes value 'Match Account' & 'Match Contact'
    3.If Entitlement Type is 'Product' , invokes the method which retrieves all the Service Contracts 
      by querying the object 'Covered Products' based on the setting Setng_ApplicableSLACovLevel and the Entitlement Options
    *******************************************************************************************************************/
    public PageReference SVMX_doCheckEntitlement() 
    { 
        isServiceAvailableOnSave = true;
        String InstallProID = '';
        date dtEntitleUsingbyFldVal = date.today(); //Its default value
        SVMXC__Installed_Product__c InstallProduct = new SVMXC__Installed_Product__c();
        if(ObjectIs == 'WorkOrder')
        {
            if(WOHdr.SVMXC__Component__c != null)
                InstallProID = WOHdr.SVMXC__Component__c;
            system.debug('Came here');
            //Get the date fields value from work order record
            try
            {
                if(Setng_EntitleUsingDateFld == null)
                {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,System.Label.EVER001_TAG001));
                    return null;
                }
                else if(Setng_EntitleUsingDateFld != null && (!Setng_EntitleUsingDateFld.equalsIgnoreCase('Today')) &&  Setng_EntitleUsingDateFld.length() > 0)
                {
                    SVMXC__Service_Order__c objWorkOrdTemp = new SVMXC__Service_Order__c();
                    objWorkOrdTemp = Database.Query('select Id,' + Setng_EntitleUsingDateFld + ' from SVMXC__Service_Order__c where Id = \'' + WOHdr.Id + '\'');
                    dtEntitleUsingbyFldVal = date.valueOf(objWorkOrdTemp.get(Setng_EntitleUsingDateFld));
                    if(dtEntitleUsingbyFldVal == null)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + getTag090()+ ' '+ Setng_EntitleUsingDateFld));
                        return null;
                    }
                }
                else
                    dtEntitleUsingbyFldVal = date.today();
            }
            catch(exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, +' '+ getTag089()+' ' + Setng_EntitleUsingDateFld));
                return null;
            }
        }   
        if(ObjectIs == 'Case')
        {
            if(csHdr.SVMXC__Component__c != null)
                InstallProID = csHdr.SVMXC__Component__c;
            
            //Get the date fields value from Case record
            try
            {
                if(Setng_EntitleUsingDateFld == null)
                {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error,System.Label.EVER001_TAG001));
                    return null;
                }
                else if(Setng_EntitleUsingDateFld != null && (!Setng_EntitleUsingDateFld.equalsIgnoreCase('Today')) && Setng_EntitleUsingDateFld.length() > 0)
                {
                    Case objCaseTemp = new Case();
                    objCaseTemp = Database.Query('select Id,' + Setng_EntitleUsingDateFld + ' from Case where Id = \'' + csHdr.Id + '\'');
                    dtEntitleUsingbyFldVal = date.valueOf(objCaseTemp.get(Setng_EntitleUsingDateFld));
                    if(dtEntitleUsingbyFldVal == null)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + getTag090() +' '+ Setng_EntitleUsingDateFld));
                        return null;
                    }
                }
                else
                    dtEntitleUsingbyFldVal = date.today();
            }
            catch(exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTag089()+ ' ' + Setng_EntitleUsingDateFld));
                return null;
            }
        }
        
        if(InstallProID != null && InstallProID.length() > 0)
        {
            InstallProduct = Database.Query('Select SVMXC__Zip__c, SVMXC__Top_Level__c, SVMXC__Street__c, SVMXC__Status__c, SVMXC__State__c, SVMXC__Site__c, SVMXC__Serial_Lot_Number__c, SVMXC__Sales_Order_Number__c, SVMXC__Product__r.SVMXC__Stockable__c, SVMXC__Product__r.SVMXC__Select__c, SVMXC__Product__r.SVMXC__Product_Cost__c, SVMXC__Product__r.SVMXC__Enable_Serialized_Tracking__c, SVMXC__Product__r.SVMXC__Unit_Of_Measure__c, SVMXC__Product__r.SVMXC__Tracking__c, SVMXC__Product__r.SVMXC__Product_Line__c, SVMXC__Product__r.SVMXC__Inherit_Parent_Warranty__c, SVMXC__Product__r.IsDeleted, SVMXC__Product__r.Family, SVMXC__Product__r.SystemModstamp, SVMXC__Product__r.LastModifiedById, SVMXC__Product__r.LastModifiedDate, SVMXC__Product__r.CreatedById, SVMXC__Product__r.CreatedDate, SVMXC__Product__r.IsActive, SVMXC__Product__r.Description, SVMXC__Product__r.ProductCode, SVMXC__Product__r.Name, SVMXC__Product__r.Id, SVMXC__Product__c, SVMXC__Product_Name__c, SVMXC__Preferred_Technician__c, SVMXC__Parent__c, SVMXC__Longitude__c, SVMXC__Latitude__c, SVMXC__Last_Date_Shipped__c, SVMXC__Installation_Notes__c, SVMXC__Distributor_Contact__c, SVMXC__Distributor_Company__c, SVMXC__Date_Shipped__c, SVMXC__Date_Ordered__c, SVMXC__Date_Installed__c, SVMXC__Country__c, SVMXC__Contact__c, SVMXC__Company__c, SVMXC__City__c, SVMXC__Business_Hours__c,  SVMXC__Access_Hours__c, Name, Id, CreatedDate, CreatedById From SVMXC__Installed_Product__c  where id = \'' + InstallProID + '\'');
        }   
        SCResults.clear();
        //WarrResults.clear();   //Defect 009668 : To remove permission binding on warranty object(check box).
        lstWarrantyWrapper.clear();
        ErrorMessages.clear();   
        String SOQLHeader,where_clause;
        if(isValidSearchCriteria()==true) 
        {
            if(SelectedEntType=='Account')
            {
                List<SVMXC__Service_Contract__c> ServiceContractRecords = new List<SVMXC__Service_Contract__c>();
                SOQLHeader='';
                where_clause ='';   
                String SCFieldNames;    
                try
                {
                    //Populating FieldNames for Service Contract                      
                    Schema.DescribeSObjectResult SCdsoResult= SVMXC__Service_Contract__c.sObjectType.getDescribe();
                    Map<String, SObjectField> SCfieldMap = Schema.SObjectType.SVMXC__Service_Contract__c.fields.getMap();
                    List<String> SCfieldList = utils.SVMX_getFieldList(SCfieldMap,true);             
                    SCFieldNames = utils.SVMX_getFieldNamesFromList(SCfieldList);    
                } 
                catch (Exception e)
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
                }                   
                SCFieldNames +=' ,SVMXC__Service_Level__r.Name ';
                SOQLHeader    = '   SELECT '+ SCFieldNames +' FROM SVMXC__Service_Contract__c  '; 
                where_clause += '   WHERE  SVMXC__Active__c =  true ';
                where_clause += '   AND  SVMXC__Company__c = \'' + AccountID + '\' ';
                
                // Entitlement enhancement: Get the setting value for date fields instead of TODAY.
                if(EntOptions.Show_Expired_Entitlement != true)
                    where_clause += ' AND SVMXC__End_Date__c >=: dtEntitleUsingbyFldVal'; 
                if(EntOptions.Show_Future_Entitlements != true)
                    where_clause +=  ' AND SVMXC__Start_Date__c <=: dtEntitleUsingbyFldVal ';
                
                //Added by amar on 2/SEP/2010 for Contact match..
                Set<String> SCIds = new Set<String>();
                
                if(EntOptions.Match_Contact == true)
                {
                    List<SVMXC__Service_Contract_Contacts__c> CoveredContacts = new List<SVMXC__Service_Contract_Contacts__c>();
                    CoveredContacts = [Select s.SystemModstamp, s.SVMXC__Service_Contract__c, s.SVMXC__Number_of_Service_Orders__c, s.SVMXC__Notes__c, s.SVMXC__Contact__c, s.Name, s.Id, s.CreatedDate, s.CreatedById From SVMXC__Service_Contract_Contacts__c s where SVMXC__Contact__c  =: ContactID];
                    if(CoveredContacts.size() > 0)
                    {
                        for(SVMXC__Service_Contract_Contacts__c SCC : CoveredContacts)
                        {
                            if(SCC.SVMXC__Service_Contract__c != null)
                                SCIds.add(SCC.SVMXC__Service_Contract__c);
                        }
                    }
                }
                
                // Entitlement enhancement: Query Covered Location to support Match Location.
                Set<String> setSCONLocId = new Set<String>();
                system.debug('strLocId----' + strLocId);
                if(EntOptions.Match_Location == true && strLocId != null && strLocId.length() > 0)
                {
                    List<SVMXC__Service_Contract_Sites__c> lstCoveredLocs = new List<SVMXC__Service_Contract_Sites__c>();
                    lstCoveredLocs = [Select SVMXC__Site__c, SVMXC__SLA_Terms__c, SVMXC__Service_Contract__c, Name, Id 
                                        From SVMXC__Service_Contract_Sites__c 
                                        where SVMXC__Site__c  =: strLocId];
                    if(lstCoveredLocs.size() > 0)
                    {
                        for(SVMXC__Service_Contract_Sites__c currLocation : lstCoveredLocs)
                        {
                            if(currLocation.SVMXC__Service_Contract__c != null)
                                setSCONLocId.add(currLocation.SVMXC__Service_Contract__c);
                        }
                    }
                }
                SOQLHeader +=where_clause + ' order by Name';
                try
                {
                    if(AccountID != null && AccountID.length() > 0)
                        ServiceContractRecords = Database.query(SOQLHeader);    
                } 
                catch (Exception e)
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
                }
                for (SVMXC__Service_Contract__c screc :ServiceContractRecords)
                {
                    if(EntOptions.Match_Location == true && EntOptions.Match_Contact == true)
                    { 
                        if((setSCONLocId.size() > 0 && setSCONLocId.contains(screc.id)) || (SCIds.size() > 0 && SCIds.contains(screc.id)))
                        {
                            SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
                            TempRecord.SCId = screc.Id; 
                            TempRecord.SCName = screc.Name;
                            if((setSCONLocId.size() > 0 && setSCONLocId.contains(screc.id)) && (SCIds.size() > 0 && SCIds.contains(screc.id)))
                                TempRecord.CoveredBy = System.Label.EVER001_TAG009 +', '+System.Label.COMM001_TAG099; 
                            else if(setSCONLocId.size() > 0 && setSCONLocId.contains(screc.id))
                                TempRecord.CoveredBy = System.Label.COMM001_TAG099; 
                            else if(SCIds.size() > 0 && SCIds.contains(screc.id))
                                TempRecord.CoveredBy = System.Label.EVER001_TAG009; 
                            TempRecord.StartDate = screc.SVMXC__Start_Date__c;                      
                            TempRecord.EndDate = screc.SVMXC__End_Date__c; 
                            TempRecord.SLAID = screc.SVMXC__Service_Level__c;         
                            TempRecord.SLAName = screc.SVMXC__Service_Level__r.Name;    
                            AddToSCResult(TempRecord);
                        }
                    }
                    else if(EntOptions.Match_Contact == true && EntOptions.Match_Location == false) 
                    { 
                        if(SCIds.size() > 0 && SCIds.contains(screc.id))
                        {
                            SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
                            TempRecord.SCId = screc.Id; 
                            TempRecord.SCName = screc.Name; 
                            TempRecord.CoveredBy = System.Label.EVER001_TAG009;          
                            TempRecord.StartDate = screc.SVMXC__Start_Date__c;                      
                            TempRecord.EndDate = screc.SVMXC__End_Date__c; 
                            TempRecord.SLAID = screc.SVMXC__Service_Level__c;         
                            TempRecord.SLAName = screc.SVMXC__Service_Level__r.Name;    
                            AddToSCResult(TempRecord);
                        }
                    }
                    else if(EntOptions.Match_Contact == false && EntOptions.Match_Location == true) 
                    { 
                        if(setSCONLocId.size() > 0 && setSCONLocId.contains(screc.id))
                        {
                            SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
                            TempRecord.SCId = screc.Id; 
                            TempRecord.SCName = screc.Name; 
                            TempRecord.CoveredBy = System.Label.COMM001_TAG099;                
                            TempRecord.StartDate = screc.SVMXC__Start_Date__c;                      
                            TempRecord.EndDate = screc.SVMXC__End_Date__c; 
                            TempRecord.SLAID = screc.SVMXC__Service_Level__c;         
                            TempRecord.SLAName = screc.SVMXC__Service_Level__r.Name;    
                            AddToSCResult(TempRecord);
                        }
                    }
                    else
                    {
                        SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
                        TempRecord.SCId = screc.Id; 
                        TempRecord.SCName = screc.Name; 
                        TempRecord.CoveredBy = System.Label.EVER001_TAG010;                       
                        TempRecord.StartDate = screc.SVMXC__Start_Date__c;                      
                        TempRecord.EndDate = screc.SVMXC__End_Date__c; 
                        TempRecord.SLAID = screc.SVMXC__Service_Level__c;         
                        TempRecord.SLAName = screc.SVMXC__Service_Level__r.Name;    
                        AddToSCResult(TempRecord);
                    }                            
                } 
            }
            System.debug('log level 1 : '+SCResults);
            if(SelectedEntType == 'Product')
            {   
                // Calling the method to retrieve the applicable Product Warranty
                if(InstallProduct != null && InstallProduct.id != null){
                    lstWarrantyWrapper.clear();
                    List<SVMXC__Warranty__c> lstTempWarrResults = new List<SVMXC__Warranty__c>();
                    lstTempWarrResults = getProductWarranty(InstallProduct.id,EntOptions, ChildLevelIterations, dtEntitleUsingbyFldVal);
                    for(SVMXC__Warranty__c obj : lstTempWarrResults){
                        lstWarrantyWrapper.add(new WarrantyWrapper(false, obj));
                    }
                }
                     
                List<SVMXC__Service_Contract_Products__c> SCPData = new List<SVMXC__Service_Contract_Products__c>();
                
                if(ObjectIs == 'Case')
                {
                    if(InstallProduct != null)
                    {
                        if(InstallProduct.SVMXC__Product__c != null && csHdr.SVMXC__Component__c != null && csHdr.SVMXC__Component__r.SVMXC__Product__c != null)
                            csHdr.SVMXC__Component__r.SVMXC__Product__c = InstallProduct.SVMXC__Product__c;
                        
                        //Assign new parent product
                        if(InstallProduct.SVMXC__Parent__c != null && csHdr.SVMXC__Component__c != null && csHdr.SVMXC__Component__r.SVMXC__Parent__c != null)
                            csHdr.SVMXC__Component__r.SVMXC__Parent__c = InstallProduct.SVMXC__Parent__c;
                        
                        //Assign Top Level..
                        if(InstallProduct.SVMXC__Top_Level__c != null && csHdr.SVMXC__Top_Level__c != null )
                             csHdr.SVMXC__Top_Level__c = InstallProduct.SVMXC__Top_Level__c;
                        
                        //Assign part 
                        if(InstallProduct.SVMXC__Product__c != null && csHdr.SVMXC__Component__c != null && csHdr.SVMXC__Component__r.SVMXC__Product__c != null)
                            csHdr.SVMXC__Component__r.SVMXC__Product__c = InstallProduct.SVMXC__Product__c ;    
                        
                        //Assing Product Family
                        if(InstallProduct.SVMXC__Product__r.Family != null && csHdr.SVMXC__Component__c != null && csHdr.SVMXC__Component__r.SVMXC__Product__c != null && csHdr.SVMXC__Component__r.SVMXC__Product__r.Family != null )
                            csHdr.SVMXC__Component__r.SVMXC__Product__r.Family = InstallProduct.SVMXC__Product__r.Family;   
                        
                        //Assign Product Line
                        if(InstallProduct.SVMXC__Product__r.SVMXC__Product_Line__c != null && csHdr.SVMXC__Component__c != null && csHdr.SVMXC__Component__r.SVMXC__Product__c != null && csHdr.SVMXC__Component__r.SVMXC__Product__r.SVMXC__Product_Line__c != null )
                            csHdr.SVMXC__Component__r.SVMXC__Product__r.SVMXC__Product_Line__c = InstallProduct.SVMXC__Product__r.SVMXC__Product_Line__c;
                    }
                    // Entitlement enhancement (Passing the additional parameter dtEntitleUsingbyFldVal) 
                    SCPData = getServiceContractData( null,csHdr, EntOptions, Setng_ApplicableSLACovLevel, ChildLevelIterations, dtEntitleUsingbyFldVal);
                }   
                else if(ObjectIs == 'WorkOrder')
                {
                    if(InstallProduct != null)
                    {
                        //Assign new parent product
                        if(InstallProduct.SVMXC__Parent__c != null && WOHdr.SVMXC__Component__c != null && WOHdr.SVMXC__Component__r.SVMXC__Parent__c != null)
                            WOHdr.SVMXC__Component__r.SVMXC__Parent__c = InstallProduct.SVMXC__Parent__c;
                        
                        //Assign Top Level..
                        if(InstallProduct.SVMXC__Top_Level__c != null && WOHdr.SVMXC__Top_Level__c != null)
                            WOHdr.SVMXC__Top_Level__c = InstallProduct.SVMXC__Top_Level__c;
                        
                        //Assign part 
                        if(InstallProduct.SVMXC__Product__c != null && WOHdr.SVMXC__Component__c != null && WOHdr.SVMXC__Component__r.SVMXC__Product__c != null)
                            WOHdr.SVMXC__Component__r.SVMXC__Product__c = InstallProduct.SVMXC__Product__c; 
                        
                        //Assing Product Family
                        if(InstallProduct.SVMXC__Product__r.Family != null && WOHdr.SVMXC__Component__c != null && WOHdr.SVMXC__Component__r.SVMXC__Product__c != null && WOHdr.SVMXC__Component__r.SVMXC__Product__r.Family != null)
                            WOHdr.SVMXC__Component__r.SVMXC__Product__r.Family = InstallProduct.SVMXC__Product__r.Family;       
                        
                        //Assign Product Line
                        if(InstallProduct.SVMXC__Product__r.SVMXC__Product_Line__c != null && WOHdr.SVMXC__Component__c != null && WOHdr.SVMXC__Component__r.SVMXC__Product__c != null && WOHdr.SVMXC__Component__r.SVMXC__Product__r.SVMXC__Product_Line__c != null)
                            WOHdr.SVMXC__Component__r.SVMXC__Product__r.SVMXC__Product_Line__c = InstallProduct.SVMXC__Product__r.SVMXC__Product_Line__c;
                    }
                    
                    // Entitlement enhancement (Passing the additional param dtEntitleUsingbyFldVal
                    SCPData = getServiceContractData( WOHdr,null, EntOptions, Setng_ApplicableSLACovLevel, ChildLevelIterations, dtEntitleUsingbyFldVal);
                }   
                
                //Populating the result to be displayed in VF Page
                Set<String> setSCONLocId = new Set<String>();
                Map<string,SVMXC__Service_Contract__c> mapLocBasedServiceContract = new Map<string,SVMXC__Service_Contract__c>();
                Map<String, SVMXC__Service_Contract_Sites__c> mapServiceContractIDANDCoveredLoc= new Map<String, SVMXC__Service_Contract_Sites__c>();
                
                Set<String> setSCONId  = new Set<String>();
                if(EntOptions.Match_Contact == true)
                {
                    List<SVMXC__Service_Contract_Contacts__c> CoveredContactsforProduct = new List<SVMXC__Service_Contract_Contacts__c>();
                    CoveredContactsforProduct = [Select s.SystemModstamp, s.SVMXC__Service_Contract__c, s.SVMXC__Number_of_Service_Orders__c, s.SVMXC__Notes__c, s.SVMXC__Contact__c, s.Name, s.Id, s.CreatedDate, s.CreatedById From SVMXC__Service_Contract_Contacts__c s where SVMXC__Contact__c  =: ContactID];
                    if(CoveredContactsforProduct.size() > 0)
                    {
                        for(SVMXC__Service_Contract_Contacts__c SCC : CoveredContactsforProduct)
                        {
                            if(SCC.SVMXC__Service_Contract__c != null)
                                setSCONId.add(SCC.SVMXC__Service_Contract__c);
                        }
                    }
                }
                
                if(EntOptions.Match_Location == true && strLocId != null && strLocId.length() > 0)
                {
                    List<SVMXC__Service_Contract_Sites__c> lstCoveredLocs = new List<SVMXC__Service_Contract_Sites__c>();
                    String coveredLocationQuery = 'SELECT SVMXC__Site__c, SVMXC__SLA_Terms__c,SVMXC__SLA_Terms__r.Name, SVMXC__Service_Contract__c,SVMXC__Service_Contract__r.SVMXC__Active__c, Name, Id, SVMXC__End_Date__c, SVMXC__Start_Date__c FROM SVMXC__Service_Contract_Sites__c WHERE SVMXC__Site__c  =: strLocId';
                    if(Setng_ApplicableSLACovLevel == 'Contract' || Setng_ApplicableSLACovLevel== 'Contract header level')
                    {
                        if(EntOptions.Show_Expired_Entitlement != true)
                            coveredLocationQuery += ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >=: dtEntitleUsingbyFldVal '; 
                        if(EntOptions.Show_Future_Entitlements != true)
                            coveredLocationQuery +=  ' AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <=: dtEntitleUsingbyFldVal '; 
                    }
                    if(Setng_ApplicableSLACovLevel =='Product' || Setng_ApplicableSLACovLevel  == 'Product or Location line level')
                    {
                        if(EntOptions.Show_Expired_Entitlement != true)
                            coveredLocationQuery += ' AND (SVMXC__End_Date__c >=: dtEntitleUsingbyFldVal OR SVMXC__End_Date__c = null )'; 
                        if(EntOptions.Show_Future_Entitlements != true)
                            coveredLocationQuery +=  ' AND (SVMXC__Start_Date__c <=: dtEntitleUsingbyFldVal OR SVMXC__Start_Date__c = null ) '; 
                    }
                    
                    lstCoveredLocs = Database.query(coveredLocationQuery);
                    
                    if(lstCoveredLocs.size() > 0)
                    {
                        for(SVMXC__Service_Contract_Sites__c currLocation : lstCoveredLocs)
                        {
                            if(currLocation.SVMXC__Service_Contract__c != null)
                                setSCONLocId.add(currLocation.SVMXC__Service_Contract__c);
                            if(currLocation.SVMXC__Service_Contract__r.SVMXC__Active__c)
                                mapServiceContractIDANDCoveredLoc.put(currLocation.SVMXC__Service_Contract__c, currLocation);
                        }
                        system.debug('setSCONLocId ---' + setSCONLocId );
                        string strServiceContractQuery = ' SELECT SVMXC__Company__c,Name, SVMXC__End_Date__c, SVMXC__Start_Date__c, SVMXC__Service_Level__c, SVMXC__Service_Level__r.Name, Id FROM SVMXC__Service_Contract__c WHERE Id IN: setSCONLocId AND SVMXC__Active__c =  true';
                        if(EntOptions.Match_Contact == true)
                            strServiceContractQuery += ' AND Id IN :setSCONId' ;  
                        if(EntOptions.Match_Account == true)
                            strServiceContractQuery += ' AND  SVMXC__Company__c = \'' + AccountID + '\' ';
                        if(EntOptions.Show_Expired_Entitlement != true)
                            strServiceContractQuery += ' AND SVMXC__End_Date__c >=: dtEntitleUsingbyFldVal'; 
                        if(EntOptions.Show_Future_Entitlements != true)
                            strServiceContractQuery +=  ' AND SVMXC__Start_Date__c <=: dtEntitleUsingbyFldVal ';
                        
                        //Get the location based Service Contract
                        mapLocBasedServiceContract.putAll((list<SVMXC__Service_Contract__c>)Database.query(strServiceContractQuery));
                    }
                }
                
                system.debug('SCPData-----'+SCPData);
                
                //Populate the Service Contract Covered by Covered Product + Location
                for (SVMXC__Service_Contract_Products__c scprec : SCPData)
                {
                    SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
                    TempRecord.SCId = scprec.SVMXC__Service_Contract__c;    
                    TempRecord.SCName = scprec.SVMXC__Service_Contract__r.Name; 
                    
                    if(mapLocBasedServiceContract.containsKey(scprec.SVMXC__Service_Contract__c))
                    {
                        mapLocBasedServiceContract.remove(scprec.SVMXC__Service_Contract__c);
                        if(scprec.SVMXC__Installed_Product__c !=null)
                        {
                            TempRecord.CoveredBy = System.Label.EVER001_TAG011 +', '+ System.Label.COMM001_TAG099;                        
                        }
                        else if(scprec.SVMXC__Product__c !=null)
                        {
                            TempRecord.CoveredBy = System.Label.EVER001_TAG012 +', '+ System.Label.COMM001_TAG099;                     
                        }
                        else if(scprec.SVMXC__Product_Family__c !=null)
                        {
                            TempRecord.CoveredBy = System.Label.EVER001_TAG013 +', '+ System.Label.COMM001_TAG099;                       
                        }
                        else if(scprec.SVMXC__Product_Line__c !=null)
                        {
                            TempRecord.CoveredBy = System.Label.EVER001_TAG014 +', '+ System.Label.COMM001_TAG099;                    
                        }
                    }
                    else
                    {
                        if(scprec.SVMXC__Installed_Product__c !=null)
                        {
                            TempRecord.CoveredBy = System.Label.EVER001_TAG011;                        
                        }
                        else if(scprec.SVMXC__Product__c !=null)
                        {
                            TempRecord.CoveredBy = System.Label.EVER001_TAG012;                     
                        }
                        else if(scprec.SVMXC__Product_Family__c !=null)
                        {
                            TempRecord.CoveredBy = System.Label.EVER001_TAG013;                       
                        }
                        else if(scprec.SVMXC__Product_Line__c !=null)
                        {
                            TempRecord.CoveredBy = System.Label.EVER001_TAG014;                    
                        }
                    }
                    
                    
                    if(Setng_ApplicableSLACovLevel == 'Contract' || Setng_ApplicableSLACovLevel == 'Contract header level')
                    {
                        TempRecord.SLAID = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;                          
                        TempRecord.SLAName = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name;
                        TempRecord.StartDate = scprec.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                        TempRecord.EndDate = scprec.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                        AddToSCResult(TempRecord);
                    }
                    else if(Setng_ApplicableSLACovLevel == 'Product' || Setng_ApplicableSLACovLevel == 'Product or Location line level'){
                        selectValidSLA(dtEntitleUsingbyFldVal, scprec, TempRecord, mapServiceContractIDANDCoveredLoc);
                        AddToSCResult(TempRecord);
                    }
                    
                    system.debug(SCResults + '----SCResults');
                }
                
                system.debug('mapLocBasedServiceContract &&&&' + mapLocBasedServiceContract);
                //Populate the Service Contract Covered by Location only
                if(mapLocBasedServiceContract != null && mapLocBasedServiceContract.size() > 0)
                {
                    for(string currSCONId : mapLocBasedServiceContract.keySet())    
                    {
                        SVMXC__Service_Contract__c tempLocBasedSCON= new SVMXC__Service_Contract__c();
                        tempLocBasedSCON = mapLocBasedServiceContract.get(currSCONId);
                        SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
                        TempRecord.SCId = tempLocBasedSCON.Id;    
                        TempRecord.SCName = tempLocBasedSCON.Name;
                        TempRecord.CoveredBy = getTag088();   
                        TempRecord.StartDate = tempLocBasedSCON.SVMXC__Start_Date__c;
                        TempRecord.EndDate = tempLocBasedSCON.SVMXC__End_Date__c;
                        
                        SVMXC__Service_Contract_Sites__c coveredLocationRec = mapServiceContractIDANDCoveredLoc.get(tempLocBasedSCON.Id);
                        system.debug(Setng_ApplicableSLACovLevel + '---Setng_ApplicableSLACovLevel'); 
                       /* if(EntOptions.Show_Expired_Entitlement == true && coveredLocationRec.SVMXC__End_Date__c < dtEntitleUsingbyFldVal){
                            if(Setng_ApplicableSLACovLevel == 'Contract' || Setng_ApplicableSLACovLevel == 'Contract header level')
                            {
                                TempRecord.SLAID = tempLocBasedSCON.SVMXC__Service_Level__c;                          
                                TempRecord.SLAName = tempLocBasedSCON.SVMXC__Service_Level__r.Name;
                                TempRecord.StartDate = tempLocBasedSCON.SVMXC__Start_Date__c;
                                TempRecord.EndDate = tempLocBasedSCON.SVMXC__End_Date__c;
                            }
                            else {
                                SVMXC.EVER_SCResults TempRecordExpiredLoc = new SVMXC.EVER_SCResults();
                                TempRecord.SCId = tempLocBasedSCON.Id;    
                                TempRecord.SCName = tempLocBasedSCON.Name;
                                TempRecord.SLAID = coveredLocationRec.SVMXC__SLA_Terms__c;                      
                                TempRecord.SLAName = coveredLocationRec.SVMXC__SLA_Terms__r.Name;
                                TempRecord.StartDate = coveredLocationRec.SVMXC__Start_Date__c;
                                TempRecord.EndDate = coveredLocationRec.SVMXC__End_Date__c;
                                TempRecord.CoveredBy = TempRecord.CoveredBy;   
                                
                            }
                            AddToSCResult(TempRecord);
                        }*/
                        
                        if(Setng_ApplicableSLACovLevel == 'Contract' || Setng_ApplicableSLACovLevel == 'Contract header level')
                        {
                            TempRecord.SLAID = tempLocBasedSCON.SVMXC__Service_Level__c;                          
                            TempRecord.SLAName = tempLocBasedSCON.SVMXC__Service_Level__r.Name;
                            TempRecord.StartDate = tempLocBasedSCON.SVMXC__Start_Date__c;
                            TempRecord.EndDate = tempLocBasedSCON.SVMXC__End_Date__c;
                            AddToSCResult(TempRecord);
                        }
                        else if(Setng_ApplicableSLACovLevel =='Product' || Setng_ApplicableSLACovLevel == 'Product or Location line level'){
                            
                            if(coveredLocationRec.SVMXC__Start_Date__c == null || coveredLocationRec.SVMXC__End_Date__c == null){
                                TempRecord.StartDate = tempLocBasedSCON.SVMXC__Start_Date__c;
                                TempRecord.EndDate = tempLocBasedSCON.SVMXC__End_Date__c;
                                if(coveredLocationRec.SVMXC__SLA_Terms__c != null && String.valueOf(coveredLocationRec.SVMXC__SLA_Terms__c).length() > 0){
                                    TempRecord.SLAID = coveredLocationRec.SVMXC__SLA_Terms__c;                      
                                    TempRecord.SLAName = coveredLocationRec.SVMXC__SLA_Terms__r.Name;        
                                }
                                else{
                                    TempRecord.SLAID = tempLocBasedSCON.SVMXC__Service_Level__c;                          
                                    TempRecord.SLAName = tempLocBasedSCON.SVMXC__Service_Level__r.Name;
                                }
                                AddToSCResult(TempRecord);
                            }
                            else{
                                if(EntOptions.Show_Expired_Entitlement == true && coveredLocationRec.SVMXC__End_Date__c < dtEntitleUsingbyFldVal){
                                    SVMXC.EVER_SCResults TempRecordExpiredLoc = new SVMXC.EVER_SCResults(); 
                                    TempRecordExpiredLoc.SCId = tempLocBasedSCON.Id;    
                                    TempRecordExpiredLoc.SCName = tempLocBasedSCON.Name;
                                    TempRecordExpiredLoc.SLAID = coveredLocationRec.SVMXC__SLA_Terms__c;                      
                                    TempRecordExpiredLoc.SLAName = coveredLocationRec.SVMXC__SLA_Terms__r.Name;
                                    TempRecordExpiredLoc.StartDate = coveredLocationRec.SVMXC__Start_Date__c;
                                    TempRecordExpiredLoc.EndDate = coveredLocationRec.SVMXC__End_Date__c;
                                    TempRecordExpiredLoc.CoveredBy = TempRecord.CoveredBy;
                                    AddToSCResult(TempRecordExpiredLoc);
                                }
                                
                                if(EntOptions.Show_Future_Entitlements == true && coveredLocationRec.SVMXC__Start_Date__c > dtEntitleUsingbyFldVal){
                                    SVMXC.EVER_SCResults TempRecordfuture = new SVMXC.EVER_SCResults(); 
                                    TempRecordfuture.SCId = tempLocBasedSCON.Id;    
                                    TempRecordfuture.SCName = tempLocBasedSCON.Name;
                                    TempRecordfuture.SLAID = coveredLocationRec.SVMXC__SLA_Terms__c;                      
                                    TempRecordfuture.SLAName = coveredLocationRec.SVMXC__SLA_Terms__r.Name;
                                    TempRecordfuture.StartDate = coveredLocationRec.SVMXC__Start_Date__c;
                                    TempRecordfuture.EndDate = coveredLocationRec.SVMXC__End_Date__c;
                                    TempRecordfuture.CoveredBy = TempRecord.CoveredBy;    
                                    AddToSCResult(TempRecordfuture);
                                }
                                
                                if(coveredLocationRec.SVMXC__Start_Date__c <= dtEntitleUsingbyFldVal && coveredLocationRec.SVMXC__End_Date__c >= dtEntitleUsingbyFldVal){
                                    TempRecord.StartDate = coveredLocationRec.SVMXC__Start_Date__c;                        
                                    TempRecord.EndDate = coveredLocationRec.SVMXC__End_Date__c;
                                    if(coveredLocationRec.SVMXC__SLA_Terms__c != null && String.valueOf(coveredLocationRec.SVMXC__SLA_Terms__c).length() > 0){
                                        TempRecord.SLAID = coveredLocationRec.SVMXC__SLA_Terms__c;                      
                                        TempRecord.SLAName = coveredLocationRec.SVMXC__SLA_Terms__r.Name;
                                    }
                                    else{
                                        TempRecord.SLAID = tempLocBasedSCON.SVMXC__Service_Level__c;                          
                                        TempRecord.SLAName = tempLocBasedSCON.SVMXC__Service_Level__r.Name;
                                    }
                                    AddToSCResult(TempRecord);
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
        // Changes for Included services ***
        if(AllSubModuleSettings.containsKey('SET022') && AllSubModuleSettings.get('SET022').toUpperCase() == 'TRUE')
        {
            boolean isShowAllServices = false;
            
            if(AllSubModuleSettings.containsKey('SET023') && AllSubModuleSettings.get('SET023').toUpperCase() == 'TRUE' )
            {
                isShowAllServices = true;
            }
            list<SVMXC__Entitlement_History__c> lstEntlHistory = new list<SVMXC__Entitlement_History__c>();
            String strSCID;
            String strSCISID;
            
            if(ObjectIs == 'Case')
            {
                if(csHdr.Id != null && csHdr.SVMXC__Service_Contract__c != null)
                {
                    strSCID = csHdr.SVMXC__Service_Contract__c;
                    lstEntlHistory = [Select SVMXC__Covered_By__c, SVMXC__Entitled_By_Service__c from SVMXC__Entitlement_History__c where SVMXC__Case__c =: csHdr.Id AND SVMXC__Inactive_Date__c = NULL];
                    if(lstEntlHistory != NULL && lstEntlHistory.size() == 1 && lstEntlHistory[0].SVMXC__Entitled_By_Service__c != null)
                        strSCISID = lstEntlHistory[0].SVMXC__Entitled_By_Service__c;
                    
                }
                new EVER_Entitlement_Utils().GetServicesOfSCON(SCResults, ObjectIs, csHdr, !(isShowAllServices), strSCID, strSCISID);
            }else if(ObjectIs == 'WorkOrder')
            {
                if(WOHdr.Id != null && WOHdr.SVMXC__Service_Contract__c != null)
                {
                    strSCID = WOHdr.SVMXC__Service_Contract__c;
                    lstEntlHistory = [Select SVMXC__Entitled_By_Service__c from SVMXC__Entitlement_History__c where SVMXC__Service_Order__c =: WOHdr.Id AND SVMXC__Inactive_Date__c = NULL];
                    if(lstEntlHistory != NULL && lstEntlHistory.size() == 1 && lstEntlHistory[0].SVMXC__Entitled_By_Service__c != null)
                        strSCISID = lstEntlHistory[0].SVMXC__Entitled_By_Service__c;
                    
                }
                new EVER_Entitlement_Utils().GetServicesOfSCON(SCResults, ObjectIs, WOHdr, !(isShowAllServices), strSCID, strSCISID);
            }
        }
        System.debug('log level 2 : '+SCResults);
        return null;   
    }
    
    public void selectValidSLA(date dtEntitleUsingbyFldVal, SVMXC__Service_Contract_Products__c scprec, SVMXC.EVER_SCResults TempRecord, Map<String, SVMXC__Service_Contract_Sites__c> mapServiceContractIDANDCoveredLoc){
        // Logic - Check if the Start and Enad Date for Covered Product are empty or not. If empty then go to Contract
        if(scprec.SVMXC__Start_Date__c == null || scprec.SVMXC__End_Date__c == null){
            TempRecord.StartDate = scprec.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
            TempRecord.EndDate = scprec.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
            if(scprec.SVMXC__SLA_Terms__c != null && String.valueOf(scprec.SVMXC__SLA_Terms__c).length() > 0){
                TempRecord.SLAID = scprec.SVMXC__SLA_Terms__c;                      
                TempRecord.SLAName = scprec.SVMXC__SLA_Terms__r.Name;
            }
            else{
                TempRecord.SLAID = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;                          
                TempRecord.SLAName = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name;
            }
        }
        else{
            // If the Service Contract assosiated to Covered Product is not valid, then don't do entitlement
            // If Covered Product is having start and End date, check its validity. If it's not valid then go to Location
            if(EntOptions.Show_Expired_Entitlement == true && scprec.SVMXC__End_Date__c < dtEntitleUsingbyFldVal){
                SVMXC.EVER_SCResults TempRecordExpired = new SVMXC.EVER_SCResults();
                TempRecordExpired.SCId = scprec.SVMXC__Service_Contract__c;    
                TempRecordExpired.SCName = scprec.SVMXC__Service_Contract__r.Name;
                TempRecordExpired.SLAID = scprec.SVMXC__SLA_Terms__c;                      
                TempRecordExpired.SLAName = scprec.SVMXC__SLA_Terms__r.Name;
                TempRecordExpired.StartDate = scprec.SVMXC__Start_Date__c;
                TempRecordExpired.EndDate = scprec.SVMXC__End_Date__c;
                TempRecordExpired.CoveredBy = TempRecord.CoveredBy;
                AddToSCResult(TempRecordExpired);
            }
            
            if(EntOptions.Show_Future_Entitlements == true && scprec.SVMXC__Start_Date__c > dtEntitleUsingbyFldVal){
                SVMXC.EVER_SCResults TempRecordFuture = new SVMXC.EVER_SCResults();
                TempRecordFuture.SCId = scprec.SVMXC__Service_Contract__c;    
                TempRecordFuture.SCName = scprec.SVMXC__Service_Contract__r.Name;
                TempRecordFuture.SLAID = scprec.SVMXC__SLA_Terms__c;                      
                TempRecordFuture.SLAName = scprec.SVMXC__SLA_Terms__r.Name;
                TempRecordFuture.StartDate = scprec.SVMXC__Start_Date__c;
                TempRecordFuture.EndDate = scprec.SVMXC__End_Date__c;
                TempRecordFuture.CoveredBy = TempRecord.CoveredBy;
                AddToSCResult(TempRecordFuture);
            }
                        
            if(scprec.SVMXC__Start_Date__c <= dtEntitleUsingbyFldVal && scprec.SVMXC__End_Date__c >= dtEntitleUsingbyFldVal){
                    TempRecord.StartDate = scprec.SVMXC__Start_Date__c;                        
                    TempRecord.EndDate = scprec.SVMXC__End_Date__c;
                    if(scprec.SVMXC__SLA_Terms__c != null && String.valueOf(scprec.SVMXC__SLA_Terms__c).length() > 0){
                        TempRecord.SLAID = scprec.SVMXC__SLA_Terms__c;                      
                        TempRecord.SLAName = scprec.SVMXC__SLA_Terms__r.Name;
                    }
                    else{
                        TempRecord.SLAID = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;                          
                        TempRecord.SLAName = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name;    
                    }
                }
            else{
                selectValidLocation (dtEntitleUsingbyFldVal, scprec, TempRecord, mapServiceContractIDANDCoveredLoc);        
            }
        }
    }
    
    public void selectValidLocation (date dtEntitleUsingbyFldVal, SVMXC__Service_Contract_Products__c scprec, SVMXC.EVER_SCResults TempRecord, Map<String, SVMXC__Service_Contract_Sites__c> mapServiceContractIDANDCoveredLoc){
        if(EntOptions.Match_Location == true && mapServiceContractIDANDCoveredLoc != null  && mapServiceContractIDANDCoveredLoc.size() > 0 && mapServiceContractIDANDCoveredLoc.get(scprec.SVMXC__Service_Contract__c) != null ){
            SVMXC__Service_Contract_Sites__c coveredLocationRec = mapServiceContractIDANDCoveredLoc.get(scprec.SVMXC__Service_Contract__c);
            if(coveredLocationRec.SVMXC__Start_Date__c == null || coveredLocationRec.SVMXC__End_Date__c == null){
                TempRecord.StartDate = scprec.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                TempRecord.EndDate = scprec.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                if(coveredLocationRec.SVMXC__SLA_Terms__c != null && String.valueOf(coveredLocationRec.SVMXC__SLA_Terms__c).length() > 0){
                    TempRecord.SLAID = coveredLocationRec.SVMXC__SLA_Terms__c;                      
                    TempRecord.SLAName = coveredLocationRec.SVMXC__SLA_Terms__r.Name;        
                }
                else{
                    TempRecord.SLAID = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;                          
                    TempRecord.SLAName = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name;   
                }
                TempRecord.CoveredBy = getTag088();
            }
            else{
                if(EntOptions.Show_Expired_Entitlement == true && coveredLocationRec.SVMXC__End_Date__c < dtEntitleUsingbyFldVal){
                    TempRecord.SLAID = coveredLocationRec.SVMXC__SLA_Terms__c;                      
                    TempRecord.SLAName = coveredLocationRec.SVMXC__SLA_Terms__r.Name;
                    TempRecord.StartDate = coveredLocationRec.SVMXC__Start_Date__c;
                    TempRecord.EndDate = coveredLocationRec.SVMXC__End_Date__c;
                }
                
                if(EntOptions.Show_Future_Entitlements == true && coveredLocationRec.SVMXC__Start_Date__c > dtEntitleUsingbyFldVal){
                    TempRecord.SLAID = coveredLocationRec.SVMXC__SLA_Terms__c;                      
                    TempRecord.SLAName = coveredLocationRec.SVMXC__SLA_Terms__r.Name;
                    TempRecord.StartDate = coveredLocationRec.SVMXC__Start_Date__c;
                    TempRecord.EndDate = coveredLocationRec.SVMXC__End_Date__c;        
                }
                else {
                    if(coveredLocationRec.SVMXC__Start_Date__c <= dtEntitleUsingbyFldVal && coveredLocationRec.SVMXC__End_Date__c >= dtEntitleUsingbyFldVal){
                        TempRecord.StartDate = coveredLocationRec.SVMXC__Start_Date__c;                        
                        TempRecord.EndDate = coveredLocationRec.SVMXC__End_Date__c;
                        if(coveredLocationRec.SVMXC__SLA_Terms__c != null && String.valueOf(coveredLocationRec.SVMXC__SLA_Terms__c).length() > 0){
                            TempRecord.SLAID = coveredLocationRec.SVMXC__SLA_Terms__c;                      
                            TempRecord.SLAName = coveredLocationRec.SVMXC__SLA_Terms__r.Name;
                        }
                        else{
                            TempRecord.SLAID = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__c;                          
                            TempRecord.SLAName = scprec.SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name;
                        }
                          
                    }
                }
                TempRecord.CoveredBy = getTag088();
            }
        }
    }
    
    public map<Id, SVMXC__Counter_Details__c> mapCounterDetails = new map<Id, SVMXC__Counter_Details__c>();                
    /*******************************************************************************************************************
    Method to append unique records to the list of Service Contracts
    *******************************************************************************************************************/
    public void AddToSCResult(SVMXC.EVER_SCResults rec)
    {
        Boolean AlreadyExist =false;
        for (SVMXC.EVER_SCResults r:SCResults)
        {
            if((r.SCId == rec.SCId)&&(r.CoveredBy == rec.CoveredBy))
            {
                AlreadyExist =true;
                break;
            }
        }
        if (AlreadyExist ==false)
            SCResults.add(rec);
    }
    /*******************************************************************************************************************
    Method to navigate back to the Case Page Layout
    *******************************************************************************************************************/
    public PageReference Cancel() 
    {
        System.debug(LoggingLevel.INFO, 'Case Record Id : ' + caseId);
        PageReference scPage = new PageReference('/' + caseId);
        scPage.setRedirect(true);
        return scPage;             
    }
    
    /*******************************************************************************************************************
    Method to Save Entitlement
    --------------------------
    1. Invokes the method to Validate user input (Selection of Warranty / Service Contract)
    2. Updates the existing Entitlement History Record associated with the Case( if any) by setting its
       Inactive Date to Current Date
    3. Creates a new Entitlement History Record for the case with the Warranty or Service COntract details
    4. Updates the Case
    5. Performs Current Page Refresh
    *******************************************************************************************************************/
    public PageReference SaveEntitlement() 
    {
        //String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); //Added for the Security fixes    
        isServiceAvailableOnSave = true;
        if(ObjectIs == 'Case' && csHdr != null)
        {
            if(isNotEntitled == false) 
            {
                try
                {
                    //Create new history Rec.
                    SVMXC__Entitlement_History__c HistoryRecord = new SVMXC__Entitlement_History__c();
                    HistoryRecord.SVMXC__Date_of_entitlement__c =System.Today();
                    HistoryRecord.SVMXC__Entitlement_notes__c = csHdr.SVMXC__Entitlement_Notes__c;    
                    HistoryRecord.SVMXC__Inactive_Date__c = NULL;
                    HistoryRecord.SVMXC__Case__c = caseId;
                    csHdr.SVMXC__Is_Service_Covered__c = false;                                                
                    /*for (SVMXC__Warranty__c warrRec :WarrResults)   //Defect 009668 : To remove permission binding on warranty object(check box).
                    {
                        if(warrRec.SVMXC__Select__c==true)
                        {
                            if(setBillType == true)csHdr.SVMXC__Billing_Type__c = 'Warranty';
                                csHdr.SVMXC__Warranty__c =warrRec.Id;
                            csHdr.SVMXC__Service_Contract__c =null;
                            csHdr.SVMXC__SLA_Terms__c =null;
                            HistoryRecord.SVMXC__Warranty__c =warrRec.Id;
                            if(warrRec.SVMXC__Start_Date__c !=null)
                                HistoryRecord.SVMXC__Start_Date__c = warrRec.SVMXC__Start_Date__c;
                            if(warrRec.SVMXC__End_Date__c !=null)
                                HistoryRecord.SVMXC__End_Date__c  = warrRec.SVMXC__End_Date__c;
                        }                         
                    }*/
                    for (WarrantyWrapper warrRec :lstWarrantyWrapper)
                    {
                        if(warrRec.isSelect==true)
                        {
                            if(setBillType == true)csHdr.SVMXC__Billing_Type__c = 'Warranty';
                            csHdr.SVMXC__Warranty__c =warrRec.objWarranty.Id;
                            csHdr.SVMXC__Service_Contract__c =null;
                            csHdr.SVMXC__SLA_Terms__c =null;
                            HistoryRecord.SVMXC__Warranty__c =warrRec.objWarranty.Id;
                            if(warrRec.objWarranty.SVMXC__Start_Date__c !=null)
                                HistoryRecord.SVMXC__Start_Date__c = warrRec.objWarranty.SVMXC__Start_Date__c;
                            if(warrRec.objWarranty.SVMXC__End_Date__c !=null)
                                HistoryRecord.SVMXC__End_Date__c  = warrRec.objWarranty.SVMXC__End_Date__c;
                        }                         
                    }
                    for (SVMXC.EVER_SCResults scRec :SCResults)
                    {
                        if(scRec.selected==true)
                        {
                            if(setBillType == true)
                                csHdr.SVMXC__Billing_Type__c = 'Contract';
                            
                            csHdr.SVMXC__Service_Contract__c =scRec.SCId;
                            csHdr.SVMXC__Warranty__c = null;
                            
                            if(scRec.SLAID != null)                        
                                csHdr.SVMXC__SLA_Terms__c = scRec.SLAID;
                            if (scRec.SLAID != null)
                                HistoryRecord.SVMXC__SLA_Terms__c = scRec.SLAID;                        
                            if(scRec.SCId != null)
                                HistoryRecord.SVMXC__Service_Contract__c = scRec.SCId;
                            if(scRec.StartDate != null)
                                HistoryRecord.SVMXC__Start_Date__c = scRec.StartDate;
                            if(scRec.EndDate != null)
                                HistoryRecord.SVMXC__End_Date__c = scRec.EndDate;
                            if(scRec.CoveredBy != NULL)
                                HistoryRecord.SVMXC__Covered_By__c = scRec.CoveredBy;
                        }
                    }  
                    // Entitlement enhancement : Update Threshold count in applicable service.
                    if(AllSubModuleSettings.containsKey('SET022') && AllSubModuleSettings.get('SET022').toUpperCase() == 'TRUE')
                    {
                        if(csHdr.SVMXC__Warranty__c != null)
                        {
                            //if Case is Entitled with Warranty, and earlier it was entitled with Service Contract, then needs to reduce service count. 
                            map<string,string> mapServiceId_status =(new EVER_Entitlement_Utils()).manageServiceThresholdCount('Case', string.valueOf(csHdr.Id), null, null);
                        }
                        else if(csHdr.SVMXC__Service_Contract__c != null)
                        {
                            map<string, sObject> mapCase = new map<string,Case>();
                            mapCase.put(csHdr.Id, (sObject)csHdr);
                            //map<string,string> mapCaseID_ServiceId = (new EVER_Entitlement_Utils()).IdentifyServiceForCase(mapCase, csHdr.SVMXC__Service_Contract__c);
                            // Changes for Included services ***
                            if(SelectedIS != null && SelectedIS.length() > 0 )
                            {
                                //string strServiceId = mapCaseID_ServiceId.get(csHdr.Id);
                                map<string,string> mapServiceId_status =(new EVER_Entitlement_Utils()).ManageServiceThresholdCount('Case', csHdr.Id, csHdr.SVMXC__Service_Contract__c, SelectedIS);
                                
                                if(mapServiceId_status != null && mapServiceId_status.size() == 1 )
                                {
                                    for(string currKey : mapServiceId_status.keySet())
                                    {
                                        if(currKey == 'NOT_APPLICABLE')
                                            HistoryRecord.SVMXC__Entitled_Within_Threshold__c = false;
                                        else
                                        {
                                            csHdr.SVMXC__Is_Service_Covered__c = true;
                                            HistoryRecord.SVMXC__Entitled_By_Service__c = currKey;
                                            if(mapServiceId_status.get(currKey) == 'WITHIN_THRESHOLD')
                                                HistoryRecord.SVMXC__Entitled_Within_Threshold__c = true;
                                            else if(mapServiceId_status.get(currKey) == 'OUTSIDE_THRESHOLD' || mapServiceId_status.get(currKey) == 'NOT_APPLICABLE')
                                                HistoryRecord.SVMXC__Entitled_Within_Threshold__c = false;
                                        }
                                    }
                                }
                            }
                            else
                            {
                                map<string,string> mapServiceId_status =(new EVER_Entitlement_Utils()).ManageServiceThresholdCount('Case', csHdr.Id, null, null);
                            }
                        }
                    }
                    
                    // Updating the Entitlement History Record after calling update threshold count method.
                    list<SVMXC__Entitlement_History__c> lstOldHistory = new  list<SVMXC__Entitlement_History__c> ();
                    lstOldHistory = [select Id, SVMXC__Inactive_Date__c from SVMXC__Entitlement_History__c where SVMXC__Inactive_Date__c  = null and SVMXC__Case__c = :csHdr.Id LIMIT 1];
                    if (lstOldHistory !=null && lstOldHistory.size() == 1)
                    {                                       
                        lstOldHistory[0].SVMXC__Inactive_Date__c =System.Today(); 
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstOldHistory[0] , COMM_SecurityUtils.Access.Updateable) ){       
                            update lstOldHistory[0];
                        } else {
                            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        }             
                        
                    }
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(HistoryRecord, COMM_SecurityUtils.Access.Createable)){
                        insert HistoryRecord; 
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    }
                    csHdr.SVMXC__Entitlement_Type__c = 'INTERACTIVE';
                    csHdr.SVMXC__Is_Entitlement_Performed__c = true; // Turn on this flag for Get Price.
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( csHdr, COMM_SecurityUtils.Access.Updateable ) ) {
                        update csHdr;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    }
                    
                    
                    String PageURL;
                    if(setRedir){
                        if(caseId.startsWith('/')){
                           caseId = caseId.replaceFirst('/','');
                        }
                        
                        PageURL='/'+caseId;
                        
                    }
                    else
                    {
                        String VFPageName='SVMXC__EVER_CaseEntitlement';  
                        PageURL='/apex/'+VFPageName+'?cid='+caseId;
                    }
                    
                    PageReference EntPage = new PageReference(PageURL); //Commented for the Security fixes
                    
                    /* This was causing issue in communities on redirection(Defect 037335). Hence, reverting back the changes
                    PageReference EntPage = new PageReference(baseURL + PageURL); */

                    EntPage.setRedirect(true);
                    return EntPage; 
                }
                catch (System.DmlException e)
                {
                    for(Integer i = 0; i < e.getNumDml(); i++){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(i)));}
                }
                catch (Exception e)
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
                }
            }
            else if(isNotEntitled == True)
            {
                try
                {
                    resetEntitlementInfo(csHdr, NULL, 'CASE');
                    
                    String PageURL;
                    if(setRedir){
                        if(caseId.startsWith('/')){
                           caseId = caseId.replaceFirst('/','');
                        }
                        
                        PageURL='/'+caseId;
                    }else
                    {
                        String VFPageName='SVMXC__EVER_CaseEntitlement';
                        PageURL='/apex/'+VFPageName+'?cid='+caseId;
                    }
                    
                    PageReference EntPage = new PageReference(PageURL); //Commented for the Security fixes
                    
                    /* This was causing issue in communities on redirection(Defect 037335). Hence, reverting back the changes
                    PageReference EntPage = new PageReference(baseURL + PageURL); */

                    EntPage.setRedirect(true);
                    return EntPage; 
                }
                catch(exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));}
            }
        }
        if(ObjectIs == 'WorkOrder' && WOHdr != null)
       {
            if(isNotEntitled == false) 
            {
                try
                {
                    SVMXC__Entitlement_History__c HistoryRecord = new SVMXC__Entitlement_History__c();
                    HistoryRecord.SVMXC__Date_of_entitlement__c =System.Today();
                    HistoryRecord.SVMXC__Entitlement_notes__c = WOHdr.SVMXC__Entitlement_Notes__c;    
                    HistoryRecord.SVMXC__Inactive_Date__c = null;
                    HistoryRecord.SVMXC__Service_Order__c = caseId;
                    WOHdr.SVMXC__Is_Service_Covered__c = false;                                
                    //Get the Selected Record 
                    /*for (SVMXC__Warranty__c warrRec :WarrResults)   //Defect 009668 : To remove permission binding on warranty object(check box).
                    {
                        if(warrRec.SVMXC__Select__c==true)
                        {
                            if(setBillType == true)
                            {
                                //System.debug('Entered for the updating a WO record as on woranty');   
                                WOHdr.SVMXC__Billing_Type__c = 'Warranty';
                                WOHdr.SVMXC__Warranty__c =warrRec.Id;
                                WOHdr.SVMXC__Service_Contract__c =null;
                                WOHdr.SVMXC__SLA_Terms__c =null;
                            }   
                            HistoryRecord.SVMXC__Warranty__c =warrRec.Id;
                            if(warrRec.SVMXC__Start_Date__c !=null)
                                HistoryRecord.SVMXC__Start_Date__c = warrRec.SVMXC__Start_Date__c;
                            if(warrRec.SVMXC__End_Date__c !=null)
                                HistoryRecord.SVMXC__End_Date__c  = warrRec.SVMXC__End_Date__c;
                        }                         
                    }*/                                      
                    for (WarrantyWrapper warrRec :lstWarrantyWrapper)
                    {
                        if(warrRec.isSelect==true)
                        {
                            if(setBillType == true)
                            {
                                //System.debug('Entered for the updating a WO record as on woranty');   
                                WOHdr.SVMXC__Billing_Type__c = 'Warranty';
                                WOHdr.SVMXC__Service_Contract__c =null;
                                WOHdr.SVMXC__SLA_Terms__c =null;
                            }
                            
                            if(warrRec.objWarranty.Id != null)
                              WOHdr.SVMXC__Warranty__c =warrRec.objWarranty.Id;  
                            
                            HistoryRecord.SVMXC__Warranty__c =warrRec.objWarranty.Id;
                            if(warrRec.objWarranty.SVMXC__Start_Date__c !=null)
                                HistoryRecord.SVMXC__Start_Date__c = warrRec.objWarranty.SVMXC__Start_Date__c;
                            if(warrRec.objWarranty.SVMXC__End_Date__c !=null)
                                HistoryRecord.SVMXC__End_Date__c  = warrRec.objWarranty.SVMXC__End_Date__c;
                        }                         
                    }
                    
                    for (SVMXC.EVER_SCResults scRec :SCResults)
                    {
                        if(scRec.selected==true)
                        {
                            if(setBillType == true)
                            {
                                WOHdr.SVMXC__Billing_Type__c = 'Contract';
                                WOHdr.SVMXC__Warranty__c =null;
                            }
                            
                            //Defect 12090; The setting 'Auto Calculate Billing Type' reads only about billing type assignement. Hence, the assignment of service contract 
                            // should be independent on setting 'Auto Calculate Billing Type'.
                            if(scRec.SCId != null)
                                WOHdr.SVMXC__Service_Contract__c =scRec.SCId;
                                
                            if (scRec.SLAID !=null)
                            {                        
                                WOHdr.SVMXC__SLA_Terms__c =scRec.SLAID;
                            }
                            if (scRec.SLAID !=null)
                            {
                                HistoryRecord.SVMXC__SLA_Terms__c = scRec.SLAID;                        
                            }
                            if(scRec.SCId !=null)
                            {
                                HistoryRecord.SVMXC__Service_Contract__c = scRec.SCId;
                            }   
                            if(scRec.StartDate!=null)
                            {
                                HistoryRecord.SVMXC__Start_Date__c = scRec.StartDate;
                            }   
                            if(scRec.EndDate!=null)
                            {
                                HistoryRecord.SVMXC__End_Date__c = scRec.EndDate;
                            }                                                 
                            if(scRec.CoveredBy != NULL)
                            {
                                HistoryRecord.SVMXC__Covered_By__c = scRec.CoveredBy;
                            }
                        }
                        
                    }  
                    
                    // Entitlement enhancement : Update Threshold count in applicable service.
                    if(AllSubModuleSettings.containsKey('SET022') && AllSubModuleSettings.get('SET022').toUpperCase() == 'TRUE' )
                    {
                        if(WOHdr.SVMXC__Warranty__c != null)
                        {
                            //if Work Order is Entitled with Warranty, and earlier it was entitled with Service Contract, then needs to reduce service count.   
                            map<string,string> mapServiceId_status =(new EVER_Entitlement_Utils()).manageServiceThresholdCount('SVMXC__Service_Order__c', string.valueOf(WOHdr.Id), null, null);
                        }
                        else if(WOHdr.SVMXC__Service_Contract__c != null)
                        {
                            boolean IsServiceCovered = true;
                            Map<string,sObject> mapWorkOrd = new map<string,SVMXC__Service_Order__c>();
                            mapWorkOrd.put(WOHdr.Id, (sObject) WOHdr);
                            //map<string,string> mapWorkOrdID_ServiceId = (new EVER_Entitlement_Utils()).identifyServiceForWorkOrd(mapWorkOrd, WOHdr.SVMXC__Service_Contract__c);
                            // Changes for Included services ***
                            if(SelectedIS != null && SelectedIS.length() > 0 )
                            {
                                //string strServiceId = mapWorkOrdID_ServiceId.get(WOHdr.Id);
                                map<string,string> mapServiceId_status =(new EVER_Entitlement_Utils()).ManageServiceThresholdCount('SVMXC__Service_Order__c', WOHdr.Id, WOHdr.SVMXC__Service_Contract__c, SelectedIS);
                                if(mapServiceId_status != null && mapServiceId_status.size() == 1 )
                                {
                                    for(string currKey : mapServiceId_status.keySet())
                                    {
                                        if(currKey == 'NOT_APPLICABLE')
                                        {
                                            HistoryRecord.SVMXC__Entitled_Within_Threshold__c = false;
                                        }
                                        else
                                        {
                                            HistoryRecord.SVMXC__Entitled_By_Service__c = currKey;
                                            WOHdr.SVMXC__Is_Service_Covered__c = true;
                                            if(mapServiceId_status.get(SelectedIS) == 'WITHIN_THRESHOLD')
                                                HistoryRecord.SVMXC__Entitled_Within_Threshold__c = true;
                                            else if(mapServiceId_status.get(SelectedIS) == 'OUTSIDE_THRESHOLD' || mapServiceId_status.get(SelectedIS) == 'NOT_APPLICABLE')
                                                HistoryRecord.SVMXC__Entitled_Within_Threshold__c = false;  
                                        }
                                    }
                                }
                            }
                            else
                            {
                                map<string,string> mapServiceId_status =(new EVER_Entitlement_Utils()).ManageServiceThresholdCount('SVMXC__Service_Order__c', WOHdr.Id, null, null);
                            }
                        }
                    }
                    // Updating the existing Entitlement History Record before inserting new History.
                    list<SVMXC__Entitlement_History__c> lstOldHistory = new  list<SVMXC__Entitlement_History__c> ();
                    lstOldHistory = [select Id, SVMXC__Inactive_Date__c from SVMXC__Entitlement_History__c  where SVMXC__Inactive_Date__c  =null and SVMXC__Service_Order__c = :WOHdr.Id LIMIT 1];
                    if (lstOldHistory != null && lstOldHistory.size() == 1)
                    {                                       
                        lstOldHistory[0].SVMXC__Inactive_Date__c = System.Today();              
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstOldHistory[0], COMM_SecurityUtils.Access.Updateable ) ) {
                            update lstOldHistory[0];
                        } else {
                            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                            return null;
                        }
                            
                    }
                    
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(HistoryRecord, COMM_SecurityUtils.Access.Createable)){
                        insert HistoryRecord; 
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }
                    WOHdr.SVMXC__Entitlement_Type__c = 'INTERACTIVE';
                    WOHdr.SVMXC__Is_Entitlement_Performed__c = true; // Turn on this flag for Get Price.
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( WOHdr, COMM_SecurityUtils.Access.Updateable ) ) {
                        update WOHdr;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        
                    }
                    
                    
                    String PageURL;
                    if(setRedir)
                    {   
                        if(caseId.startsWith('/')){
                           caseId = caseId.replaceFirst('/','');
                        }
                        
                        PageURL='/'+caseId;
                    }
                    else
                    {
                        String VFPageName='SVMXC__EVER_CaseEntitlement';
                        PageURL='/apex/'+VFPageName+'?cid='+caseId;
                    }
                    PageReference EntPage = new PageReference(PageURL); //Commented for the Security fixes
                    
                    /* This was causing issue in communities on redirection(Defect 037335). Hence, reverting back the changes
                    PageReference EntPage = new PageReference(baseURL + PageURL); */
                    
                    EntPage.setRedirect(true);
                    return EntPage; 
                } 
                catch (System.DmlException e)
                {
                    for(Integer i = 0; i < e.getNumDml(); i++){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(i)));}
                }
                catch (Exception e)
                {   
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
                }
            }
            else if(isNotEntitled == True)
            {
                try
                {
                    resetEntitlementInfo(NULL, WOHdr, 'WORK ORDER');
                    String PageURL;
                    if(setRedir)
                        PageURL='/'+caseId;
                    else
                    {
                        String VFPageName='SVMXC__EVER_CaseEntitlement';
                        PageURL='/apex/'+VFPageName+'?cid='+caseId;
                    }
                    PageURL = objCls.GetCommunityPrefix(PageURL);
                    PageReference EntPage = new PageReference(PageURL); 
                    EntPage.setRedirect(true);
                    return EntPage;  
                }
                catch(exception ex){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));}
            }
       }
       return null;
    }  
    
    // Method to reset all Entitlement related information from Case/Work Order.
    public void resetEntitlementInfo(Case objCase, SVMXC__Service_Order__c objWorkOrd, String ObjectName)
    {
        list<SVMXC__Entitlement_History__c> lstActiveEntitlementHistory = new list<SVMXC__Entitlement_History__c>();
        if(ObjectName == NULL)
            return;
        
        //Reset all the entitlement related fields from the Case / Work Order record.
        if(ObjectName.toUpperCase() == 'CASE' && objCase != NULL)
        {
            objCase.SVMXC__Is_Entitlement_Performed__c = true; // Turn on this flag for Get Price.
            objCase.SVMXC__Warranty__c = NULL;
            objCase.SVMXC__Service_Contract__c = NULL;
            objCase.SVMXC__Is_Service_Covered__c = false;
            
            if(setBillType == true){
                objCase.SVMXC__Billing_Type__c = NULL;
            }
            objCase.SVMXC__SLA_Terms__c = NULL;
            //objCase.SVMXC__Entitlement_Notes__c = ''; //commented for fixing customer defect 025326
            objCase.SVMXC__Entitlement_Type__c = NULL;
           List<String> fieldAPINameList = new List<String>{'SVMXC__Is_Entitlement_Performed__c','SVMXC__Warranty__c','SVMXC__Service_Contract__c','SVMXC__Is_Service_Covered__c','SVMXC__Billing_Type__c','SVMXC__SLA_Terms__c','SVMXC__Entitlement_Type__c'};
           //Sourabh:10/Nov/2016:calling verifyFieldAccess with field name list as passing case object directly was returning false negative for access check
           if( COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Case', fieldAPINameList, COMM_SecurityUtils.Access.Updateable) ){       
           // if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objCase, COMM_SecurityUtils.Access.Updateable ) ) {
                update objCase;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            //Query the active Entitlement Histroy Record.
            lstActiveEntitlementHistory = [select SVMXC__Entitled_By_Service__c, SVMXC__Inactive_Date__c from SVMXC__Entitlement_History__c where SVMXC__Inactive_Date__c  = NULL AND SVMXC__Case__c = : objCase.Id];
        }
        else if(ObjectName.toUpperCase() == 'WORK ORDER' && objWorkOrd != NULL)
        {
            objWorkOrd.SVMXC__Is_Entitlement_Performed__c = true; // Turn on this flag for Get Price.
            objWorkOrd.SVMXC__Warranty__c = NULL;
            objWorkOrd.SVMXC__Service_Contract__c = NULL;
            objWorkOrd.SVMXC__Is_Service_Covered__c = false;
            if(setBillType == true){
                objWorkOrd.SVMXC__Billing_Type__c = NULL;
            }
            objWorkOrd.SVMXC__SLA_Terms__c = NULL;
            //objWorkOrd.SVMXC__Entitlement_Notes__c = ''; //commented for fixing customer defect 025326
            objWorkOrd.SVMXC__Entitlement_Type__c = NULL;
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objWorkOrd, COMM_SecurityUtils.Access.Updateable ) ) {
                update objWorkOrd;
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            //Query the active Entitlement Histroy Record.
            lstActiveEntitlementHistory = [select SVMXC__Entitled_By_Service__c, SVMXC__Inactive_Date__c from SVMXC__Entitlement_History__c where SVMXC__Inactive_Date__c = NULL AND SVMXC__Service_Order__c = : objWorkOrd.Id];
        }
        
        //Reduce threshold count and Inactivate the Entitlement History records.
        if(lstActiveEntitlementHistory != NULL && lstActiveEntitlementHistory.size() == 1)
        {   
            if(lstActiveEntitlementHistory[0].SVMXC__Entitled_By_Service__c != NULL)
            {
                List<SVMXC__Service_Contract_Services__c> lstCvrdService = new List<SVMXC__Service_Contract_Services__c>();
                lstCvrdService = [Select SVMXC__Consumed_Units__c from SVMXC__Service_Contract_Services__c where Id =: lstActiveEntitlementHistory[0].SVMXC__Entitled_By_Service__c];
                
                if(lstCvrdService.size() == 1 && lstCvrdService[0].SVMXC__Consumed_Units__c != NULL && lstCvrdService[0].SVMXC__Consumed_Units__c != 0)
                {
                    lstCvrdService[0].SVMXC__Consumed_Units__c = Integer.valueOf(lstCvrdService[0].SVMXC__Consumed_Units__c) - 1;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstCvrdService[0], COMM_SecurityUtils.Access.Updateable ) ) {
                        update lstCvrdService[0];
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                }
            }
            lstActiveEntitlementHistory[0].SVMXC__Inactive_Date__c = System.Today();
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstActiveEntitlementHistory[0], COMM_SecurityUtils.Access.Updateable ) ) {
                update lstActiveEntitlementHistory[0];
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
        }
    }
                      
    /*******************************************************************************************************************
    Method to validate User Input
    1. Ensures that only one Result Entry (from Check Entitlement) is selected
    *******************************************************************************************************************/
    public PageReference isValidData()
    {
        boolean Validate = true;
        ErrorMessages.clear();          
        Integer RecordsSelected = 0;  
        boolean isSCONSelected = false;
        boolean isAllowed = true;
        boolean isQualifiedTest = true;
        boolean isUnvalidData = true;
        SelectedIS = '';
        /*for (SVMXC__Warranty__c warrRec :WarrResults)   //Defect 009668 : To remove permission binding on warranty object(check box).
        {
            if(warrRec.SVMXC__Select__c==true)
                RecordsSelected +=1;
        }*/
        for (WarrantyWrapper warrRec :lstWarrantyWrapper)
        {
            if(warrRec.isSelect==true)
                RecordsSelected +=1;
        }
        for(SVMXC.EVER_SCResults scRec :SCResults)
        {
            if(scRec.selected == true)
            {
                RecordsSelected +=1;
                isSCONSelected = true;
                SelectedIS = null;
                // Changes for Included services ***
                if(scRec.lstISWrapper != null && scRec.lstISWrapper.size() >0)
                {
                    for(EVER_SCResults.IncludedServicesWrapper SCON_SCWrpr : scRec.lstISWrapper)
                    {
                        if(SCON_SCWrpr.isSelected)
                        {
                            if(SCON_SCWrpr.IncludedServices.Id != null)
                            {
                                SelectedIS = SCON_SCWrpr.IncludedServices.Id;
                                if( SCON_SCWrpr.IncludedServices.SVMXC__Included_Units__c != null && (Integer.valueOf(SCON_SCWrpr.IncludedServices.SVMXC__Included_Units__c)) != 0 && SCON_SCWrpr.IncludedServices.SVMXC__Consumed_Units__c != null && (Integer.valueOf(SCON_SCWrpr.IncludedServices.SVMXC__Consumed_Units__c)!= 0 ))
                                if(Integer.valueOf(SCON_SCWrpr.IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCON_SCWrpr.IncludedServices.SVMXC__Consumed_Units__c) <= 0 )
                                    isAllowed = false;
                                if(!SCON_SCWrpr.isQualified)
                                    isQualifiedTest = false;
                            }
                        }
                    }
                }
                else
                {
                    isAllowed = true;
                }
            }
        }
        
        if(isNotEntitled)
            RecordsSelected +=1;
        
        if(RecordsSelected==0)
        {
            if(!isNotEntitled)
            {
                AddToErrorsList(getTag047()); //Please select a record to save 
                isUnvalidData = false;
                ValidRecords = false;
            }
        }
        
        if(RecordsSelected > 1 )
        {
            AddToErrorsList(getTag048()); //Please select only one record
            isUnvalidData = false;
            ValidRecords = false;
        }
        if(isUnvalidData && (!isAllowed || !isQualifiedTest))
        {
            if(!isAllowed && !isQualifiedTest)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, +getTAG112()));
            }
            else if(!isAllowed)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, +getTAG108()));
            }
            else if(!isQualifiedTest)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, +getTAG110()));
            }
            isServiceAvailableOnSave = false;
        }
        else if(isUnvalidData && isAllowed && isQualifiedTest)
        {
            return SaveEntitlement();
        }
        else if(!isUnvalidData)
        {
            DisplayErrors();  
        }
        return null;
    }
    /*******************************************************************************************************************
    Recursive Method to return the List of IB children Ids
    *******************************************************************************************************************/
    public List<String> getIBChildHierarchy(List<String> IPIds,Integer n)
    {
        if(n>0)
        {
            List<String> TempIPIds = new List<String>();
            String qry1 ='select Id from  SVMXC__Installed_Product__c where SVMXC__Parent__c IN : IPIds ';
            List<SVMXC__Installed_Product__c> ibList  = new List<SVMXC__Installed_Product__c>();
            
            try
            {
                 ibList = Database.query(qry1);
            }catch (Exception e){ 
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));
            }
           
            for(SVMXC__Installed_Product__c ibObj : ibList)
            {
                TempIPIds.add(ibObj.Id);  
            }
            for(string s: getIBChildHierarchy(TempIPIds,n-1))
            {                       
                IPIds.add(s);
            }
            return IPIds;
        }
        else
            return IPIds;
    }
    /*******************************************************************************************************************
    Method to  retrieve Contract Coverage Data
    *******************************************************************************************************************/
    // Method to return Covered Product Records including the respective Service Contract Information
    public  List<SVMXC__Service_Contract_Products__c> getServiceContractData(SVMXC__Service_Order__c WO ,Case cs, WrapperClass EntOpt, String SLACoverageLevel, Integer ChildLevelIterations, date dtEntitleUsingbyFldVal)
    {
        Boolean includeParentIB     = EntOpt.Chk_Parent_Product;
        Boolean includeTopIB        = EntOpt.Chk_Top_Level_Product;
        Boolean includeChildIB      = EntOpt.Chk_Child_Products;
        Boolean includePartNumber   = EntOpt.Chk_Part_Number;
        Boolean includeProdFamily   = EntOpt.Chk_Product_Family;
        Boolean includeProdLine     = EntOpt.Chk_Product_Line;
        Boolean dispFutureEnt       = EntOpt.Show_Future_Entitlements;
        Boolean dispExpiredEnt      = EntOpt.Show_Expired_Entitlement;
        Boolean doMatchAccount      = EntOpt.Match_Account;
        Boolean doMatchContact      = EntOpt.Match_Contact;
        Boolean doMatchLoc = EntOpt.Match_Location;
        Integer ChildLevelsToCover  = ChildLevelIterations; 
        Id  AccId ;
        Id  ConId ;
        Id LocId;
        Id IBId;    
        Id TopIBId;
        Id ParentIBId;
        List<String> IBIds = new List<String>() ;
        List<String> ChildIds = new List<String>() ;
        List<SVMXC__Service_Contract_Products__c>  CoveredProducts = new List<SVMXC__Service_Contract_Products__c>();
        list<SVMXC__Installed_Product__c> lstInstalledProd = new list<SVMXC__Installed_Product__c>();
        if(WO == null && cs != null)
        {
            if (cs.SVMXC__Component__c == null)
            {
                return CoveredProducts;
            }
            if((doMatchContact ==true)&&(cs.ContactId==null))
            {
                return CoveredProducts;
            }
            if(cs.AccountId!=null)
            {
                AccId =cs.AccountId;
            }   
            if(cs.ContactId !=null)
            {
                ConId = cs.ContactId;
            }
            if(cs.SVMXC__Component__c!=null)
            { 
                IBId = cs.SVMXC__Component__c;
                // Defect(005011): Query the Installed Product available in Case, and use this records instead of get the value like  cs.SVMXC__Component__r.SVMXC__Parent__c and other fields.
                if(IBId != null)
                {
                    lstInstalledProd = [select Id, SVMXC__Top_Level__c, SVMXC__Product__c, SVMXC__Parent__c, SVMXC__Product__r.Name, SVMXC__Product__r.Family, SVMXC__Product__r.SVMXC__Product_Line__c from SVMXC__Installed_Product__c  where Id =: IBId];
                }
            }
            if(IBId!=null) 
            { 
                IBIds.add('\'' + IBId + '\'');
            }
            if(cs.SVMXC__Site__c != null)
            { 
                LocId = cs.SVMXC__Site__c;
            }
            //Include Top Level(includeTopIB)
            if ((cs.SVMXC__Top_Level__c!=null)&&(includeTopIB==true))  
            {
                TopIBId =cs.SVMXC__Top_Level__c;
                IBIds.add('\'' + TopIBId + '\'');  
            }
            //includeParentIB
            if (lstInstalledProd != null && lstInstalledProd.size() == 1 && lstInstalledProd[0].SVMXC__Parent__c != null && (includeParentIB==true)) 
            {
                IBIds.add('\'' +  lstInstalledProd[0].SVMXC__Parent__c + '\'');  
            }
        }
        if(WO != null && cs == null)
        {
            if (WO.SVMXC__Component__c == null)
            {
                return CoveredProducts;
            }
            if((doMatchContact ==true)&&(WO.SVMXC__Contact__c==null))
            {
                return CoveredProducts;
            }
            if(WO.SVMXC__Company__c!=null)
            {
                AccId =WO.SVMXC__Company__c;
            }   
            if(WO.SVMXC__Contact__c !=null)
            {
                ConId = WO.SVMXC__Contact__c;
            }
            if(WO.SVMXC__Component__c!=null)
            { 
                IBId =WO.SVMXC__Component__c;
                // Defect(005011): Query the Installed Product rec available in Case, and use this records instead of get the value like cs.SVMXC__Component__r.SVMXC__Parent__c and other fields.
                if(IBId != null)
                {
                    lstInstalledProd = [select Id, SVMXC__Top_Level__c, SVMXC__Product__c, SVMXC__Parent__c, SVMXC__Product__r.Name, SVMXC__Product__r.Family, SVMXC__Product__r.SVMXC__Product_Line__c from SVMXC__Installed_Product__c  where Id =: IBId];
                }
            }
            if(IBId!=null) 
            { 
                IBIds.add('\'' + IBId + '\'');
            }
            //Include Top Level(includeTopIB)
            if ((WO.SVMXC__Top_Level__c!=null)&&(includeTopIB==true))  
            {
                TopIBId =WO.SVMXC__Top_Level__c;
                IBIds.add('\'' + TopIBId + '\'');  
            }
            //includeParentIB
            if(includeParentIB == true && lstInstalledProd != null && lstInstalledProd.size() == 1 && lstInstalledProd[0].SVMXC__Parent__c != null) 
            {
                IBIds.add('\'' + lstInstalledProd[0].SVMXC__Parent__c + '\'');
            }
        }
        
        if(includeChildIB ==true)      // Here the order of condition is significant as currently the array contains only one element i.e. IB
        {                     
            IBIds = getIBChildHierarchy(IBIds,ChildLevelIterations);           
        }              
        List<SVMXC__Installed_Product__c>   IBRecords = new  List<SVMXC__Installed_Product__c>();
        String  qry2 = 'select Id, Name ,SVMXC__Product__c,SVMXC__Product__r.Name, ';
                qry2+=  ' SVMXC__Product__r.Family, SVMXC__Product__r.SVMXC__Product_Line__c ';
                qry2+=  '   from SVMXC__Installed_Product__c   ';
                qry2+=  '   where ( Id = \''+IBId+'\' ';
        for(String str : IBIds)
        {
            qry2+=  ' OR  Id ='+str;
        }   
        qry2 += ' ) ';  
        
        IBRecords = Database.query(qry2); //TO UNCOMMENT THIS LINE
        system.debug('IBRecords'+IBRecords);
        String select_clause = 'SELECT Name, SVMXC__Service_Contract__c,SVMXC__SLA_Terms__c,SVMXC__SLA_Terms__r.Name, ' +
                    'SVMXC__Service_Contract__r.Name,  SVMXC__Service_Contract__r.SVMXC__Start_Date__c, ' +
                    'SVMXC__Service_Contract__r.SVMXC__End_Date__c, SVMXC__Service_Contract__r.SVMXC__Renewal_Date__c, ' +
                    'SVMXC__Service_Contract__r.SVMXC__Renewal_Number__c,' +
                    'SVMXC__Service_Contract__r.SVMXC__Service_Contract_Notes__c, ' +
                    'SVMXC__Service_Contract__r.SVMXC__Service_Level__c ,SVMXC__Service_Contract__r.SVMXC__Service_Level__r.Name, ' +
                    'SVMXC__Start_Date__c, SVMXC__End_Date__c , SVMXC__Product__c, '+
                    'SVMXC__Product_Line__c, SVMXC__Product_Family__c, SVMXC__Notes__c, SVMXC__Installed_Product__c '+
                    'FROM SVMXC__Service_Contract_Products__c ';
        select_clause += ' where (  SVMXC__Installed_Product__c = \''+IBId+'\' ';
        for( SVMXC__Installed_Product__c ibObj :IBRecords)
        {
            if (ibObj.Id!=null)
                select_clause += '  OR SVMXC__Installed_Product__c = \''+ibObj.Id+'\' ';
        }  
        //includePartNumber         
        if(includePartNumber==true)
        {
            if(WO == null && cs != null)
            {
                if(lstInstalledProd != null && lstInstalledProd.size() == 1)
                {

                    if(lstInstalledProd[0].SVMXC__Product__c !=null)
                        select_clause += '  OR SVMXC__Product__c = \''+lstInstalledProd[0].SVMXC__Product__c+'\'  ';
                    if((cs.SVMXC__Product__c !=null)&&(lstInstalledProd[0].SVMXC__Product__c !=cs.SVMXC__Product__c))
                        select_clause += '  OR SVMXC__Product__c = \''+cs.SVMXC__Product__c+'\'  ';
                }
            }
            if(WO != null && cs == null)
            {
                if(lstInstalledProd != null && lstInstalledProd.size() == 1)
                {
                    if(lstInstalledProd[0].SVMXC__Product__c !=null)
                        select_clause += '  OR SVMXC__Product__c = \''+ lstInstalledProd[0].SVMXC__Product__c+'\'  ';
                    if((WO.SVMXC__Product__c !=null) && (lstInstalledProd[0].SVMXC__Product__c !=WO.SVMXC__Product__c))
                        select_clause += '  OR SVMXC__Product__c = \''+WO.SVMXC__Product__c+'\'  ';
                }
            }
            //includeChildIB
            if(includeChildIB ==true)
            {
                for( SVMXC__Installed_Product__c ibObj :IBRecords)
                {   
                    if(ibObj.SVMXC__Product__c!=null)
                        select_clause += '  OR SVMXC__Product__c = \''+ibObj.SVMXC__Product__c+'\'  ';
                }
             }
        } 
        //includeProdFamily
        if(includeProdFamily==true)
        {
            if(WO == null && cs != null)
            {
                if(lstInstalledProd != null && lstInstalledProd.size() == 1 && lstInstalledProd[0].SVMXC__Product__r.Family !=null)
                    select_clause += '  OR SVMXC__Product_Family__c = \''+lstInstalledProd[0].SVMXC__Product__r.Family+'\'  ';
            }
            if(WO != null && cs == null)
            {
                if(lstInstalledProd != null && lstInstalledProd.size() == 1 && lstInstalledProd[0].SVMXC__Product__r.Family !=null)
                    select_clause += '  OR SVMXC__Product_Family__c = \''+lstInstalledProd[0].SVMXC__Product__r.Family+'\'  '; 
            }
            //if(includeChildIB       
            system.debug(includeChildIB + '---includeChildIB');
           if(includeChildIB ==true)
            {
                for( SVMXC__Installed_Product__c ibObj :IBRecords)
                {   
                    if(ibObj.SVMXC__Product__r.Family!=null)
                        select_clause += '  OR SVMXC__Product_Family__c =\''+ibObj.SVMXC__Product__r.Family+'\' ';
                }  
            }
        }
        //includeProdLine
        if(includeProdLine==true)
        {
            if(WO == null && cs != null)
            {
                if(lstInstalledProd != null && lstInstalledProd.size() == 1 && lstInstalledProd[0].SVMXC__Product__r.SVMXC__Product_Line__c !=null)
                    select_clause += '  OR SVMXC__Product_Line__c = \''+ lstInstalledProd[0].SVMXC__Product__r.SVMXC__Product_Line__c+'\'  ';
            }
            if(WO != null && cs == null)
            {
                if(lstInstalledProd != null && lstInstalledProd.size() == 1 &&lstInstalledProd[0].SVMXC__Product__r.SVMXC__Product_Line__c !=null)
                    select_clause += '  OR SVMXC__Product_Line__c = \''+ lstInstalledProd[0].SVMXC__Product__r.SVMXC__Product_Line__c+'\'  ';
            }
            //if(includeChildIB         
            if(includeChildIB ==true)
            {         
                for( SVMXC__Installed_Product__c ibObj :IBRecords)
                {   
                    if(ibObj.SVMXC__Product__r.SVMXC__Product_Line__c!=null)
                        select_clause += '  OR SVMXC__Product_Line__c =\''+ibObj.SVMXC__Product__r.SVMXC__Product_Line__c+'\'  ' ;
                }
            }
        }      
        select_clause += ' ) ';     
        String where_clause = ' AND  (  SVMXC__Service_Contract__r.SVMXC__Active__c = true  ';
        
        // Entitlement enhancement: Get the setting value for date fields instead of TODAY.
        if(SLACoverageLevel=='Contract' || SLACoverageLevel== 'Contract header level')
        {
            if(dispExpiredEnt != true)
                where_clause += ' AND SVMXC__Service_Contract__r.SVMXC__End_Date__c >=: dtEntitleUsingbyFldVal '; 
            if(dispFutureEnt != true)
                where_clause +=  ' AND SVMXC__Service_Contract__r.SVMXC__Start_Date__c <=: dtEntitleUsingbyFldVal '; 
        }
        if(SLACoverageLevel=='Product' || SLACoverageLevel == 'Product or Location line level')
        {
            //Added null check to handle defect: 005256
            if(dispExpiredEnt != true)
                where_clause += ' AND (SVMXC__End_Date__c >=: dtEntitleUsingbyFldVal OR SVMXC__End_Date__c = null )'; 
            if(dispFutureEnt != true)
                where_clause +=  ' AND (SVMXC__Start_Date__c <=: dtEntitleUsingbyFldVal OR SVMXC__Start_Date__c = null ) '; 
        }
        
        
        if(doMatchAccount==true)  
            where_clause += ' AND  SVMXC__Service_Contract__r.SVMXC__Company__c = \'' + AccId + '\' ';
        where_clause += ' ) '; 
        String qry3 = select_clause + where_clause + ' ORDER BY SVMXC__Service_Contract__r.Name';
        system.debug('Query: '+qry3);
        try
        {
            CoveredProducts = Database.query(qry3);
        } 
        catch (Exception e){ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));}
         
        if(doMatchContact==true)  
            return getContactCoveredProducts(CoveredProducts , ConId);
        else
            return CoveredProducts;
    }

    /*******************************************************************************************************************
     Function to Validate(filter) Service Contracts against Case Contact
    *******************************************************************************************************************/
    public List<SVMXC__Service_Contract_Products__c> getContactCoveredProducts(List<SVMXC__Service_Contract_Products__c> AllCPList,Id ConId)
    {
        List<SVMXC__Service_Contract_Contacts__c> SCCList = new List<SVMXC__Service_Contract_Contacts__c> ();
        List<SVMXC__Service_Contract_Products__c> ValidCoveredProducts = new List<SVMXC__Service_Contract_Products__c> ();
        if (ConId ==null)
            return ValidCoveredProducts;
        try
        {
            SCCList = [select SVMXC__Service_Contract__c, Name From SVMXC__Service_Contract_Contacts__c where SVMXC__Contact__c =:ConId];
        } 
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));
        }         
        for (SVMXC__Service_Contract_Products__c cp :AllCPList)
        {
            Boolean ValidCP = false;
            for (SVMXC__Service_Contract_Contacts__c scc :  SCCList)
            {
                if (cp.SVMXC__Service_Contract__c == scc.SVMXC__Service_Contract__c)
                {
                    ValidCP = true;
                    break;
                }
            }
            if(ValidCP==true)
                ValidCoveredProducts.add(cp);
        }
        return ValidCoveredProducts;
    }
    
    /*******************************************************************************************************************
    Method to  retrieve Applicable Product Warranty
    *******************************************************************************************************************/
    public List<SVMXC__Warranty__c> getProductWarranty(Id IB,WrapperClass  EntOpt,Integer ChildLevelIterations, date dtEntitleUsingbyFldVal)                    
    {
        Boolean includeParentIB = EntOpt.Chk_Parent_Product;
        Boolean includeTopIB = EntOpt.Chk_Top_Level_Product;
        Boolean includeChildIB = EntOpt.Chk_Child_Products;
        Boolean dispFutureEnt = EntOpt.Show_Future_Entitlements;
        Boolean dispExpiredEnt = EntOpt.Show_Expired_Entitlement; 
        
        List<SVMXC__Warranty__c> ProdWarrantyRecords = new List<SVMXC__Warranty__c>();
        String SOQLHeader;
        String where_clause ='';    
        List<String> IBList = new List<String>();
        Id TopIBId ;
        Id ParentIBId;
        if (IB==null)   
            return ProdWarrantyRecords;        
        
        // List to store Ids of Parent,Top-Level and Child IBs
        List<SVMXC__Installed_Product__c> IBGroup = new List<SVMXC__Installed_Product__c>();
        // Retrieving Ids of Parent,Top-Level and Child IBs
        String qry1 = 'select   SVMXC__Top_Level__c,    SVMXC__Top_Level__r.SVMXC__Product__c, '+
                            'SVMXC__Parent__c,      SVMXC__Parent__r.SVMXC__Product__c, '+
                            'SVMXC__Product__c, Name, Id  '+
                  'from     SVMXC__Installed_Product__c where   Id = \''+IB+'\' '+
                  ' or      SVMXC__Parent__c = \''+IB+'\' ';
        
        IBGroup = getIBsList(qry1);//IB);       
        for(SVMXC__Installed_Product__c ip : IBGroup)
        {
            if (ip.id == IB ){ //It's Self Record                
                if(ip.SVMXC__Parent__c != null)
                    ParentIBId = ip.SVMXC__Parent__c ;
                if(ip.SVMXC__Top_Level__c != null)
                    TopIBId = ip.SVMXC__Top_Level__c ;                
            }
        }   
        if (IB !=null)
            IBList.add('\'' + IB + '\'');
            
        if (includeChildIB==true)  // Here the order of condition is significant as currently the array
        {                     // contains only one element i.e. IB
            IBList = getIBChildHierarchy(IBList,ChildLevelIterations);    
        }
        if ((includeParentIB==true)&& (ParentIBId !=null))
            IBList.add('\'' + ParentIBId + '\'');           
        if ((includeTopIB==true)&& (TopIBId !=null))
            IBList.add('\'' + TopIBId + '\'');
        String select_clause = 'SELECT Id, Name,SVMXC__Select__c, SVMXC__Service_Template__c, ' +
                'SVMXC__Service_Template__r.Name,SVMXC__Start_Date__c, SVMXC__End_Date__c, ' +
                'SVMXC__Exclusions__c, SVMXC__Invoice_Required__c, SVMXC__Loaner_Provided__c, ' +
                'SVMXC__Onsite_Repair__c, SVMXC__RMA_Required__c, SVMXC__Shipment_Allowed__c, ' +
                'SVMXC__Transferable__c, SVMXC__Walk_in_Allowed__c ,SVMXC__Installed_Product__c FROM SVMXC__Warranty__c ';

        where_clause = 'WHERE ( SVMXC__Installed_Product__c = \''+IB+'\' ';
        for(String str : IBList)
        {
            where_clause+=  ' OR  SVMXC__Installed_Product__c ='+str;
        }   
        where_clause += ' ) ';  
        
        // Entitlement enhancement: Get the setting value for date fields instead of TODAY.
        if(dispExpiredEnt != true)
            where_clause = where_clause + ' AND SVMXC__End_Date__c >=: dtEntitleUsingbyFldVal '; 
        if(dispFutureEnt != true)
            where_clause = where_clause + ' AND SVMXC__Start_Date__c <=: dtEntitleUsingbyFldVal ';
        
        String final_soql = select_clause + where_clause + ' ORDER BY Name';
        system.debug('Final Query: '+ final_soql);
        try
        {            
            if (IBList.size()!=0)
            {
                ProdWarrantyRecords = Database.query(final_soql); //TO UNCOMMENT LATER
            }
        } 
        catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage()));}
        return ProdWarrantyRecords;
    }
    /*******************************************************************************************************************
    Method to  retrieve IB Records
    *******************************************************************************************************************/
    public  List<SVMXC__Installed_Product__c> getIBsList(String query)
    {
        //Get Top and child IBs for given ib
        List<SVMXC__Installed_Product__c> ibList  = new List<SVMXC__Installed_Product__c>();
        try
        {
            ibList = Database.query(query);
        } 
        Catch (Exception e){ ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,e.getMessage(),''));}
        return ibList;
    }
    /*******************************************************************************************************************
    Methods  to Display/Hide Page Block Tables
    *******************************************************************************************************************/
    public Boolean getDisplaySCBlockTab()
    {
        if (SCResults.size()==0)
            return false;
        else
            return true;
    }
    public Boolean getDisplayWarrBlockTab()
    {
        //if (WarrResults.size()==0)   //Defect 009668 : To remove permission binding on warranty object(check box).
        if (lstWarrantyWrapper.size()==0)
            return false;
        else
            return true;
    }
    // methods for Included services ***
    public void CancelPopup()
    {
        isShowServicePopUp = false;
    }
    public void showMoreServices()
    {
        isServiceAvailableOnSave = true;
        isServiceAvailable = true;
        lstIncludedServicesWrpr.clear();
        strSlectedService = '';
        if(SCResults != null && SCResults.size() >0 && strSelectedSCID != null)
        {
            for(EVER_SCResults SconWrprObj : SCResults)
            {
                if(SconWrprObj.SCId == strSelectedSCID)
                {
                    system.debug('logs 1 : '+SconWrprObj.lstISWrapper.size());
                    if(SconWrprObj.lstISWrapper != null && SconWrprObj.lstISWrapper.size() > 1)
                    {
                        isShowServicePopUp = true;
                        lstIncludedServicesWrpr.addAll(SconWrprObj.lstISWrapper);
                        strSlectedService = SconWrprObj.idSelectdIS;
                    }
                    break;
                }
            }
        }
    }
    
    //Method to validate Select Service Submit
    public PageReference serviceSubmitcheck()
    {
        isServiceAvailable = true;
        boolean isQualifiedTest = true;
        if(strSlectedService != 'None')
        {
            for(EVER_SCResults SCResult : SCResults)
            {
                if(SCResult.SCId == strSelectedSCID)
                {
                    for(EVER_SCResults.IncludedServicesWrapper SCISWrpr : SCResult.lstISWrapper){
                        if(SCISWrpr.IncludedServices.Id == strSlectedService)
                        {
                            if( SCISWrpr.IncludedServices.SVMXC__Included_Units__c != null && (Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Included_Units__c) != 0 ) && SCISWrpr.IncludedServices.SVMXC__Consumed_Units__c != null  && (Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Consumed_Units__c)!= 0) )
                            {
                                if(Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Consumed_Units__c) <= 0)
                                isServiceAvailable = false;
                            }
                            System.debug('test for qualified service : '+SCISWrpr.isQualified);
                            if(!SCISWrpr.isQualified)
                                isQualifiedTest = false;
                        }
                    }
                }
            }
        }
        if(isServiceAvailable && isQualifiedTest)
        {
            serviceSubmit();
        }else if( !(isServiceAvailable) && !(isQualifiedTest))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, +getTAG111()));
            isServiceAvailable = false;
        }
        else if(!(isServiceAvailable))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, +getTAG107()));
            isServiceAvailable = false;
        }
        else if(!(isQualifiedTest))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, +getTAG109()));
            isServiceAvailable = false;
        }
        
        return null;
    }
    public void serviceSubmitNo()
    {
        isServiceAvailable = true;
    }
    
    public void SaveEntitlementNo()
    {
        isServiceAvailableOnSave = true;
    }
    
    public void serviceSubmit()
    {
        isShowServicePopUp = false;
        for(EVER_SCResults SCResult : SCResults)
        {
            SCResult.selected  = false;
            if(SCResult.SCId == strSelectedSCID)
            {
                SCResult.selected  = true;
                if(strSlectedService != 'None')
                {
                    for(EVER_SCResults.IncludedServicesWrapper SCISWrpr : SCResult.lstISWrapper)
                    {
                        SCISWrpr.isSelected = false;
                        if(SCISWrpr.IncludedServices.Id == strSlectedService)
                        {
                            SCISWrpr.isSelected = true;
                            SCResult.idSelectdIS = SCISWrpr.IncludedServices.Id;
                            SCResult.strNameIS = SCISWrpr.IncludedServices.SVMXC__Service__r.Name;
                            if(SCISWrpr.IncludedServices.SVMXC__Included_Units__c == null || SCISWrpr.IncludedServices.SVMXC__Included_Units__c == 0)
                                SCResult.strUnitsAvl = getTAG103();
                            else
                            {
                                if(Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Consumed_Units__c) > 0)
                                    SCResult.strUnitsAvl = String.valueOf(Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Included_Units__c) - Integer.valueOf(SCISWrpr.IncludedServices.SVMXC__Consumed_Units__c));
                                else
                                    SCResult.strUnitsAvl = '0';
                            }
                        }
                    }
                }
                else
                {
                    for(EVER_SCResults.IncludedServicesWrapper SCISWrpr : SCResult.lstISWrapper)
                    {
                        SCISWrpr.isSelected = false;
                    }
                    SCResult.lstISWrapper[0].isSelected = true;
                    SCResult.idSelectdIS = null;
                    SCResult.strNameIS = '';//SCResult.lstISWrapper[0].IncludedServices.SVMXC__Service__r.Name;
                    SCResult.strUnitsAvl = '';
                }
                
            }
        }
        /* if(WarrResults != null && WarrResults.size() > 0)   //Defect 009668 : To remove permission binding on warranty object(check box).
        {
            for(SVMXC__Warranty__c ObjWrnt : WarrResults)
            {
                ObjWrnt.Select__c = false;
            }
        } */
        if(lstWarrantyWrapper != null && lstWarrantyWrapper.size() > 0)
        {
            for(WarrantyWrapper ObjWrnt : lstWarrantyWrapper)
            {
                ObjWrnt.isSelect = false;
            }
        }
    }
    
    /*******************************************************************************************************************
    Object/Methods  to retrieve Settings and Translation Tag Values
    *******************************************************************************************************************/
    // custom labels for Included services ***
    public String getTAG093() {return System.Label.COMM001_TAG116;}//'Available Units':
    public String getTAG094() {return System.Label.COMM001_TAG117;}//'Select a Service':
    public String getTAG095() {return System.Label.COMM001_TAG118;}//Included Services
    public String getTAG096() {return System.Label.COMM001_TAG119;}//'Yes'
    public String getTAG097() {return System.Label.COMM001_TAG120;}//'No'
    public String getTAG098() {return System.Label.COMM001_TAG121;}//'Service Name'
    public String getTAG099() {return System.Label.COMM001_TAG122;}//'Allowed Units'
    public String getTAG100() {return System.Label.COMM001_TAG123;}//'Consumed Units'
    public String getTAG101() {return System.Label.COMM001_TAG124;}//'Tracked?'
    public String getTAG102() {return System.Label.COMM001_TAG035;}//'None'
    public String getTAG103() {return System.Label.COMM001_TAG125;}//'Unlimited'
    public String getTAG104() {return System.Label.COMM001_TAG126;}//'Submit'
    public String getTAG105() {return System.Label.COMM001_TAG040;}//'Cancel'
    public String getTAG106() {return System.Label.COMM001_TAG127;}//'No Services Available'
    public String getTAG107() {return System.Label.COMM001_TAG128;}//'All the available units have already been consumed. Are you sure you want to select this service?'
    public String getTAG108() {return System.Label.COMM001_TAG129;}//'All the available units have already been consumed in the service selected for the service contract. Are you sure you want to entitle using this service contract?'
    
    public String getTAG109() {return System.Label.COMM001_TAG130;}//The selected service is not qualified. Are you sure you want to select this service?
    public String getTAG110() {return System.Label.COMM001_TAG131;}//The selected service for the service contract is not qualified. Are you sure you want to entitle using this service contract?
    public String getTAG111() {return System.Label.COMM001_TAG132;}//The selected service is not qualified and all its available units have been consumed. Are you sure you want to select this service?
    public String getTAG112() {return System.Label.COMM001_TAG133;}//The selected service for the service contract is not qualified and all its available units have been consumed. Are you sure you want to entitle using this service contract?
    
    
    public String getTAG001(){ return TagMap.get('Tag001');}  //Setting not available for :Number Of IB Child Levels        
    public String getTAG002(){ return TagMap.get('Tag002');}  //Account
    public String getTAG003(){ return TagMap.get('Tag003');}  //Product
    public String getTAG004(){ return TagMap.get('Tag004');} //Enter Details    
    public String getTAG005(){ return TagMap.get('Tag005');} //Entitlement Settings      
    public String getTAG006(){ return TagMap.get('Tag006');} //Options    
    public String getTAG007(){ return TagMap.get('Tag007');} //Check Entitlement        
    public String getTAG008(){ return TagMap.get('Tag008');}//Save Entitlement    
    public String getTAG009(){return TagMap.get('Tag009');}//Contact
    public String getTAG010(){return TagMap.get('Tag010');}//Account
    public String getTAG011(){return TagMap.get('Tag011');}//Installed Product
    public String getTAG012(){return TagMap.get('Tag012');}//Part
    public String getTAG013(){return TagMap.get('Tag013');}//Product Family
    public String getTAG014(){return TagMap.get('Tag014');}//Product Line
    public String getTAG020(){ return TagMap.get('Tag020');}//'Help for this page'
    public String getTAG021(){ return TagMap.get('Tag021');} //Warranties    
    public String getTAG022(){ return TagMap.get('Tag022');}//Entitlement History     
    public String getTAG038(){ return TagMap.get('Tag038');}//Source Object Record Id not found
    public String getTAG039(){ return TagMap.get('Tag039');}//Entitlement Verification
    public String getTAG040(){ return TagMap.get('Tag040');}//Product Coverage Options
    public String getTAG045(){ return TagMap.get('Tag045');}//Entitle Using     
    public String getTAG046(){ return TagMap.get('Tag046');}//Select
    public String getTAG047(){ return TagMap.get('Tag047');}//Please select a record to save
    public String getTAG048(){ return TagMap.get('Tag048');}//Please select only one record
    public String getTAG050(){ return TagMap.get('Tag050');}//Service Contracts
    public String getTAG051(){ return TagMap.get('Tag051');}//'Covered By'
    public String getTAG052(){ return TagMap.get('Tag052');}//Back to Case
    public String getTAG053(){ return TagMap.get('Tag053');}//Account is not available
    public String getTAG054(){ return TagMap.get('Tag054');}//Contact is not available
    public String getTAG055(){ return TagMap.get('Tag055');}//Product is not available
    public String getTAG056(){ return TagMap.get('Tag056');}//Part Number is not available
    public String getTAG057(){ return TagMap.get('Tag057');}//Processing...
    public String getTAG058(){ return TagMap.get('Tag058');}//Show Future Entitlements
    public String getTAG059(){ return TagMap.get('Tag059');}//Parent Product
    public String getTAG060(){ return TagMap.get('Tag060');}//Show Expired Entitlements
    public String getTAG061(){ return TagMap.get('Tag061');}//Top-Level Product
    public String getTAG062(){ return TagMap.get('Tag062');}//Match Accounts
    public String getTAG063(){ return TagMap.get('Tag063');}//Child Product
    public String getTAG064(){ return TagMap.get('Tag064');}//Match Contact
    public String getTAG065(){ return TagMap.get('Tag065');}//Part Number
    public String getTAG066(){ return TagMap.get('Tag066');}//Entitle Using
    public String getTAG067(){ return TagMap.get('Tag067');}//Product Family
    public String getTAG068(){ return TagMap.get('Tag068');}//Product Line
    public String getTAG069(){ return TagMap.get('Tag069');}//Settings
    public String getTAG070(){ return TagMap.get('Tag070');}//Entitlement
    public String getTAG071(){ return TagMap.get('Tag071');}//Worranties/Service Contracts
    public String getTAG072(){ return TagMap.get('Tag072');}//Case Number
    public String getTAG073(){ return TagMap.get('Tag073');}//Component Name
    public String getTAG074(){ return TagMap.get('Tag074');}//Account Name
    public String getTAG075(){ return TagMap.get('Tag075');}//Component SN
    public String getTAG076(){ return TagMap.get('Tag076');}//Contact Name
    public String getTAG077(){ return TagMap.get('Tag077');}//Entitlement Notes
    public String getTAG079(){ return TagMap.get('Tag079');}//Start Date
    public String getTAG080(){ return TagMap.get('Tag080');}//End Date
    public String getTAG081(){ return TagMap.get('Tag081');}//Covered By    
    public String getTAG082(){ return TagMap.get('Tag082');}//SLA Terms
    public String getTAG083(){ return TagMap.get('Tag083');}//Contract Name/Number
    public String getTAG084(){ return TagMap.get('Tag084');}//Warranty Name
    public String getTAG085(){ return TagMap.get('Tag085');}//Installed Product
    public String getTAG086(){ return TagMap.get('Tag086');}//Warranty Terms
    public String getHLPURL() {return TagMap.get('HLPURL');}//HLPURL
    
    public String getTag087() {return System.Label.COMM001_TAG098;} //Match Location
    public String getTag088() {return System.Label.COMM001_TAG099;} //Location
    public String getTag089() {return System.Label.COMM001_TAG081;} // Unable to perform entitlement because of invalid setting value:
    public String getTag090() {return System.Label.COMM001_TAG080;} // Unable to perform entitlement because of invalid value in field:
    public String getTag091() {return System.Label.COMM001_TAG101;} //Entitlement Information
    public String getTag092() {return System.Label.COMM001_TAG102;} //Not Entitled
    
    
    
        
    public String getPageNameToRedirect()
    {
        if(AllSubModuleSettings.containsKey('SET019'))
            return  AllSubModuleSettings.get('SET019');
        else 
            return  '/apex/COMM_Detail?pid=';
    }///apex/COMM_Detail?id=
    public String gettabNameValue(){return   tabname;}
    public String getDetailPageId(){return   strDetailId;}
    /*public String getTAG071(){return tabname;}//Worranties/Service Contracts*/
    public Map<String,String> getTagMap()
    {
        if(ObjectIs == 'Case')
        {
            TagMap.clear();
            TagMap.put('Tag001',System.Label.EVER001_TAG001);
            TagMap.put('Tag002',System.Label.EVER001_TAG002);
            TagMap.put('Tag003',System.Label.EVER001_TAG003);
            TagMap.put('Tag004',System.Label.EVER001_TAG004);
            TagMap.put('Tag005',System.Label.EVER001_TAG005);
            TagMap.put('Tag006',System.Label.EVER001_TAG006);
            TagMap.put('Tag007',System.Label.EVER001_TAG007);
            TagMap.put('Tag008',System.Label.EVER001_TAG008);
            TagMap.put('Tag009',System.Label.EVER001_TAG009);
            TagMap.put('Tag010',System.Label.EVER001_TAG010);
            TagMap.put('Tag011',System.Label.EVER001_TAG011);
            TagMap.put('Tag012',System.Label.EVER001_TAG012);
            TagMap.put('Tag013',System.Label.EVER001_TAG013);
            TagMap.put('Tag014',System.Label.EVER001_TAG014);
            TagMap.put('Tag020',System.Label.EVER001_TAG020);
            TagMap.put('Tag021',System.Label.EVER001_TAG021);
            TagMap.put('Tag022',System.Label.EVER001_TAG022);
            TagMap.put('Tag038',System.Label.EVER001_TAG038);
            TagMap.put('Tag039',System.Label.EVER001_TAG039);
            TagMap.put('Tag040',System.Label.EVER001_TAG040);
            TagMap.put('Tag045',System.Label.EVER001_TAG045);
            TagMap.put('Tag046',System.Label.EVER001_TAG046);
            TagMap.put('Tag047',System.Label.EVER001_TAG047);
            TagMap.put('Tag048',System.Label.EVER001_TAG048);
            TagMap.put('Tag050',System.Label.EVER001_TAG050);
            TagMap.put('Tag051',System.Label.EVER001_TAG051);
            TagMap.put('Tag052',System.Label.EVER001_TAG052);
            TagMap.put('Tag053',System.Label.EVER001_TAG053);
            TagMap.put('Tag054',System.Label.EVER001_TAG054);
            TagMap.put('Tag055',System.Label.EVER001_TAG055);
            TagMap.put('Tag056',System.Label.EVER001_TAG056);
            TagMap.put('Tag057',System.Label.EVER001_TAG057);
            TagMap.put('Tag058',System.Label.EVER001_TAG058);
            TagMap.put('Tag059',System.Label.EVER001_TAG059);
            TagMap.put('Tag060',System.Label.EVER001_TAG060);
            TagMap.put('Tag061',System.Label.EVER001_TAG061);
            TagMap.put('Tag062',System.Label.EVER001_TAG062);
            TagMap.put('Tag063',System.Label.EVER001_TAG063);
            TagMap.put('Tag064',System.Label.EVER001_TAG064);
            TagMap.put('Tag065',System.Label.EVER001_TAG065);
            TagMap.put('Tag066',System.Label.EVER001_TAG066);
            TagMap.put('Tag067',System.Label.EVER001_TAG067);
            TagMap.put('Tag068',System.Label.EVER001_TAG068);
            TagMap.put('Tag069',System.Label.EVER001_TAG069);
            TagMap.put('Tag070',System.Label.EVER001_TAG070);
            TagMap.put('Tag071',System.Label.EVER001_TAG071);
            TagMap.put('Tag072',System.Label.EVER001_TAG072);
            TagMap.put('Tag073',System.Label.EVER001_TAG073);
            TagMap.put('Tag074',System.Label.EVER001_TAG074);
            TagMap.put('Tag075',System.Label.EVER001_TAG075);
            TagMap.put('Tag076',System.Label.EVER001_TAG076);
            TagMap.put('Tag077',System.Label.EVER001_TAG077);
            TagMap.put('Tag079',System.Label.EVER001_TAG079);
            TagMap.put('Tag080',System.Label.EVER001_TAG080);
            TagMap.put('Tag081',System.Label.EVER001_TAG081);
            TagMap.put('Tag082',System.Label.EVER001_TAG082);
            TagMap.put('Tag083',System.Label.EVER001_TAG083);
            TagMap.put('Tag084',System.Label.EVER001_TAG084);
            TagMap.put('Tag085',System.Label.EVER001_TAG085);
            TagMap.put('Tag086',System.Label.EVER001_TAG086);
            TagMap.put('HLPURL',System.Label.EVER001_HLPURL);
        }
        if(ObjectIs == 'WorkOrder')
        {
            TagMap.clear();
            TagMap.put('Tag001',System.Label.EVER005_TAG001);
            TagMap.put('Tag002',System.Label.EVER005_TAG002);
            TagMap.put('Tag003',System.Label.EVER005_TAG003);
            TagMap.put('Tag004',System.Label.EVER005_TAG004);
            TagMap.put('Tag005',System.Label.EVER005_TAG005);
            TagMap.put('Tag006',System.Label.EVER005_TAG006);
            TagMap.put('Tag007',System.Label.EVER005_TAG007);
            TagMap.put('Tag008',System.Label.EVER005_TAG008);
            TagMap.put('Tag009',System.Label.EVER005_TAG009);
            TagMap.put('Tag010',System.Label.EVER005_TAG010);
            TagMap.put('Tag011',System.Label.EVER005_TAG011);
            TagMap.put('Tag012',System.Label.EVER005_TAG012);
            TagMap.put('Tag013',System.Label.EVER005_TAG013);
            TagMap.put('Tag014',System.Label.EVER005_TAG014);
            TagMap.put('Tag020',System.Label.EVER005_TAG020);
            TagMap.put('Tag021',System.Label.EVER005_TAG021);
            TagMap.put('Tag022',System.Label.EVER005_TAG022);
            TagMap.put('Tag038',System.Label.EVER005_TAG038);
            TagMap.put('Tag039',System.Label.EVER005_TAG039);
            TagMap.put('Tag040',System.Label.EVER005_TAG040);
            TagMap.put('Tag045',System.Label.EVER005_TAG045);
            TagMap.put('Tag046',System.Label.EVER005_TAG046);
            TagMap.put('Tag047',System.Label.EVER005_TAG047);
            TagMap.put('Tag048',System.Label.EVER005_TAG048);
            TagMap.put('Tag050',System.Label.EVER005_TAG050);
            TagMap.put('Tag051',System.Label.EVER005_TAG051);
            TagMap.put('Tag052',System.Label.EVER005_TAG052);
            TagMap.put('Tag053',System.Label.EVER005_TAG053);
            TagMap.put('Tag054',System.Label.EVER005_TAG054);
            TagMap.put('Tag055',System.Label.EVER005_TAG055);
            TagMap.put('Tag056',System.Label.EVER005_TAG056);
            TagMap.put('Tag057',System.Label.EVER005_TAG057);
            TagMap.put('Tag058',System.Label.EVER005_TAG058);
            TagMap.put('Tag059',System.Label.EVER005_TAG059);
            TagMap.put('Tag060',System.Label.EVER005_TAG060);
            TagMap.put('Tag061',System.Label.EVER005_TAG061);
            TagMap.put('Tag062',System.Label.EVER005_TAG062);
            TagMap.put('Tag063',System.Label.EVER005_TAG063);
            TagMap.put('Tag064',System.Label.EVER005_TAG064);
            TagMap.put('Tag065',System.Label.EVER005_TAG065);
            TagMap.put('Tag066',System.Label.EVER005_TAG066);
            TagMap.put('Tag067',System.Label.EVER005_TAG067);
            TagMap.put('Tag068',System.Label.EVER005_TAG068);
            TagMap.put('Tag069',System.Label.EVER005_TAG069);
            TagMap.put('Tag070',System.Label.EVER005_TAG070);
            TagMap.put('Tag071',System.Label.EVER005_TAG071);
            TagMap.put('Tag072',System.Label.EVER005_TAG072);
            TagMap.put('Tag073',System.Label.EVER005_TAG073);
            TagMap.put('Tag074',System.Label.EVER005_TAG074);
            TagMap.put('Tag075',System.Label.EVER005_TAG075);
            TagMap.put('Tag076',System.Label.EVER005_TAG076);
            TagMap.put('Tag077',System.Label.EVER005_TAG077);
            TagMap.put('Tag079',System.Label.EVER005_TAG079);
            TagMap.put('Tag080',System.Label.EVER005_TAG080);
            TagMap.put('Tag082',System.Label.EVER005_TAG082);
            TagMap.put('Tag083',System.Label.EVER005_TAG083);
            TagMap.put('Tag084',System.Label.EVER005_TAG084);
            TagMap.put('Tag085',System.Label.EVER005_TAG085);
            TagMap.put('Tag086',System.Label.EVER005_TAG086);
            TagMap.put('HLPURL',System.Label.EVER005_HLPURL);
        }
        return TagMap;
    }
}