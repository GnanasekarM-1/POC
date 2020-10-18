/* Security Scanned */
public with sharing class CASE_SelectBookingWindow  
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
    //------------------------------------
    
    //CRUD security related functions
    public static COMM_SecurityUtils securityUtils = COMM_SecurityUtils.getInstance();
    
    
    public String CaseId = System.currentPageReference().getParameters().get('CaseId');
    Case objSelectedCase = new Case();
    public Case getobjSelectedCase(){ return objSelectedCase;}   

    public String selectedTab = '';
    public String getselectedTab(){return this.selectedTab;}
    public void setselectedTab(String s){this.selectedTab = s;}
    public String selectedTab2 = '';
    public String getselectedTab2(){return this.selectedTab2;}
    public void setselectedTab2(String s){this.selectedTab2 = s;}
    public String colHeader = '';
    public String getcolHeader(){return this.colHeader;}
    public String colWidth = '';
    public String getcolWidth(){return this.colWidth;}
    public String ArrString = '';
    public String getArrString(){return this.ArrString;}

    public integer iBookingWindowDuration;
    public integer iMaxBookingWindowDuration;
    boolean isAllIntegerValid = true;
    public integer iYellowColorStart = 2;
    public String getYellowColorStart(){return string.valueOf(iYellowColorStart);}
    public void setYellowColorStart(String str)
    {
        try
        {
            iYellowColorStart = integer.valueOf(str);
        }
        catch(exception ex)
        {
            isAllIntegerValid = false;
        }
    }
    public integer iYellowColorEnd = 0;
    public String getYellowColorEnd(){return string.valueOf(iYellowColorEnd);}
    public void setYellowColorEnd(String str)
    {
        try
        {
            iYellowColorEnd = integer.valueOf(str);
        }
        catch(exception ex)
        {  
        isAllIntegerValid = false;
        }
    }
    String strBookingWindowStart = '';
    String strSLATimestamp = '';
    String strSetupHomePage = '';

    String GridTitle = '';
    public String getGridTitle(){return this.GridTitle;}
    integer RowSize = 0;
    public integer getRowSize(){return this.RowSize;}
    integer CollSize = 0;
    public integer getCollSize(){return this.CollSize;}
    String GridWidth = '50';
    public String getGridWidth(){return this.GridWidth;}
    String GridAligne = 'left';
    public String getGridAligne(){return this.GridAligne;}
    String GridTypes = 'dyn';
    public String getGridTypes(){return this.GridTypes;}
    String strDataArray = '';
    public String getstrDataArray(){return this.strDataArray;}
    String XMLResultGrid='';
    
    public boolean bAllowOverbooking = false; 
    boolean isAllBookingWindow = false;
    public list<SVMXC__Service_Group_Skills__c> lstServiceGroupSkills = new list<SVMXC__Service_Group_Skills__c>();
    public list<SVMXC__Service_Group_Product__c> lstProd = new list<SVMXC__Service_Group_Product__c>();
    public Integer AvailCount=0;
    public Integer gesetAvailableTerritoriesCount()
    {
        return AvailCount;
    }
    boolean isError = false;
    boolean isWarning = false;
    public String getTTListStyle() 
    {
        if(AvailCount==0)
            return 'display:none';
        else 
            return 'display:block'; 
    }

    List<SVMXC__Territory__c> Territories = new List<SVMXC__Territory__c>();
    SVMXC__Territory__c ROterritoryChild = new SVMXC__Territory__c();
    SVMXC__Territory__c ROterritoryParent = new SVMXC__Territory__c();
    public SVMXC__Territory__c AddTrtry = new SVMXC__Territory__c();
    public SVMXC__Territory__c EditTT = new SVMXC__Territory__c();

    public String TTId = '';
    public String getTTId(){return TTId;}
    public void setTTId(String id){this.TTId = id;}
    public String TrtryId = '';
    public String getTrtryId(){return TrtryId;}
    public void setTrtryId(String id){this.TrtryId = id;}
    public boolean ShowProductSpecialization = false;
    public boolean getShowProductSpecialization(){return this.ShowProductSpecialization;}
    public boolean ShowExpertise = false;
    public boolean getShowExpertise(){return this.ShowExpertise;}
    set<Id> setAvailableTerritories = new set<Id>();
    set<Id> TPARENTS = new set<Id>();
    Map<Id, Id> ChildsParrent =  new Map<Id, Id>{};
    
    String selectedTerritoryTimezone = '';
    
    Map<Id , set<Id>> mParrent = new Map<Id , set<Id>>();
    set<id> CHILDListIds= new set<id>();
    Map<String, String> TNAME =  new Map<String, String>{};
    Map<String, Boolean> TACTIVE =  new Map<String, Boolean>{};
    Map<String, String> TCODE =  new Map<String, String>{};
    Map<String, String> TDESC =  new Map<String, String>{};
    Boolean displayTTAttribute = false;

    String XMLResult='';
    public String getXMLResult(){ return XMLResult;}

    public list<wrapperRec> lstExpertise = new list<wrapperRec>();
    public list<wrapperRec> getlstExpertise(){return this.lstExpertise;}
    public void setlstExpertise(list<wrapperRec> lst){this.lstExpertise = lst;}
    public list<wrapperRec> lstProductSpecialization = new list<wrapperRec>();
    public list<wrapperRec> getlstProductSpecialization(){return this.lstProductSpecialization;}
    public void setlstProductSpecialization(list<wrapperRec> lst){this.lstProductSpecialization = lst;}

    public SVMXC__ServiceMax_List__c tempSVMXList =  new SVMXC__ServiceMax_List__c();
    public SVMXC__ServiceMax_List__c gettempSVMXList(){return this.tempSVMXList;}
    public void settempSVMXList(SVMXC__ServiceMax_List__c o){this.tempSVMXList = o;}
    public SVMXC.COMM_Utils_ManageSettings CommSettingsUtils = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> mapSVMXSettings = CommSettingsUtils.SVMX_getSettingList('CASE001');
    List<String> lstOMAX003Settings = new List<String>{'SET018'};
    Map<String, String> mapOMAX003SettingValues = CommSettingsUtils.SVMX_getSettingList('OMAX003', lstOMAX003Settings);
    Boolean isDebugEnabled = FALSE;
    // Getting all translations
    public String getHLPURL() {return System.Label.CASE001_HLPURL;}
    public String getTAG001() {return System.Label.CASE001_TAG001;}
    public String getTAG002() {return System.Label.CASE001_TAG002;}
    public String getTAG003() {return System.Label.CASE001_TAG003;}
    public String getTAG004() {return System.Label.CASE001_TAG004;}
    public String getTAG005() {return System.Label.CASE001_TAG005;}
    public String getTAG006() {return System.Label.CASE001_TAG006;}
    public String getTAG007() {return System.Label.CASE001_TAG007;}
    public String getTAG008() {return System.Label.CASE001_TAG008;}
    public String getTAG009() {return System.Label.CASE001_TAG009;}
    public String getTAG010() {return System.Label.CASE001_TAG010;}
    public String getTAG011() {return System.Label.CASE001_TAG011;}
    public String getTAG012() {return System.Label.CASE001_TAG012;}
    public String getTAG013() {return System.Label.CASE001_TAG013;}
    public String getTAG014() {return System.Label.CASE001_TAG014;}
    public String getTAG015() {return System.Label.CASE001_TAG015;}
    public String getTAG016() {return System.Label.CASE001_TAG016;}
    public String getTAG017() {return System.Label.CASE001_TAG017;}
    public String getTAG019() {return System.Label.CASE001_TAG019;}
    public String getTAG020() {return System.Label.CASE001_TAG020;}
    public String getTAG021() {return System.Label.CASE001_TAG021;}
    public String getTAG022() {return System.Label.CASE001_TAG022;}
    public String getTAG023() {return System.Label.CASE001_TAG023;}
    public String getTAG024() {return System.Label.CASE001_TAG024;}
    public String getTAG025() {return System.Label.CASE001_TAG025;}
    public String getTAG026() {return System.Label.CASE001_TAG026;}
    public String getTAG027() {return System.Label.CASE001_TAG027;}
    public String getTAG028() {return System.Label.CASE001_TAG028;}
    public String getTAG029() {return System.Label.CASE001_TAG029;}
    public String getTAG030() {return System.Label.CASE001_TAG030;}
    public String getTAG031() {return System.Label.CASE001_TAG031;}
    public String getTAG032() {return System.Label.CASE001_TAG032;}
    public String getTAG033() {return System.Label.CASE001_TAG033;}
    public String getTAG034() {return System.Label.CASE001_TAG034;}
    public String getTAG035() {return System.Label.CASE001_TAG035;}
    public String getTAG036() {return System.Label.CASE001_TAG036;}

    public void getSettings()
    {
        // Getting setting definitions
        strSetupHomePage = mapSVMXSettings.get('SET001');
        strBookingWindowStart = mapSVMXSettings.get('SET002');
        iBookingWindowDuration = getIntegerSetting('SET003');
        iYellowColorStart = getIntegerSetting('SET004');
        iYellowColorEnd = getIntegerSetting('SET005');
        iMaxBookingWindowDuration = getIntegerSetting('SET006');
        strSLATimestamp = mapSVMXSettings.get('SET007');
        bAllowOverbooking = getBooleanSetting('SET008');
        isAllBookingWindow = getBooleanSetting('SET009');
        
        if(mapOMAX003SettingValues.containsKey('SET018') && mapOMAX003SettingValues.get('SET018').toUpperCase() == 'TRUE')
            isDebugEnabled = TRUE;
    }
    public integer getIntegerSetting(String setId)
    {
        integer i = 0;
        try
        {
            i = Integer.valueOf(mapSVMXSettings.get(setId));
        }
        catch(exception ex)
        {
            i = 0;
        }
        return i;
    }
    
    public boolean getBooleanSetting(String setId)
    {
        if(mapSVMXSettings.ContainsKey(setId) && mapSVMXSettings.get(setId).toUpperCase() == 'TRUE')
            return true;
        return false;
    }
    
    public User UserLocale;
    public User getUserLocale(){return this.UserLocale;}
    public void setUserLocale(User o){this.UserLocale = o;}

    public boolean DisableSLAChkBox = false;
    public boolean getDisableSLAChkBox(){ return DisableSLAChkBox; }

    public void setDisableSLAChkBox(boolean b){ this.DisableSLAChkBox = b;} 

    List<BusinessHours> lstTechniciansBusinessHours = new List<BusinessHours>();
    Map<String, BusinessHours> mapBusinessHours = new Map<String, BusinessHours>();
    public CASE_SelectBookingWindow()
    {
        getSettings();
        DefBH = [select Id, TimeZoneSidKey from BusinessHours where IsDefault=true]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        // Getting case details from where this page has been launched
        objSelectedCase = [select Id,SVMXC__Preferred_End_Time__c,SVMXC__Preferred_Start_Time__c,Booking_Window__c,BW_Date__c,SVMXC__Initial_Response_Customer_By__c,SVMXC__Onsite_Response_Customer_By__c,SVMXC__Restoration_Customer_By__c,SVMXC__Resolution_Customer_By__c,BW_Territory__c,BW_Selected_By__c,BW_Selected_On__c,BW_Slots_Before__c,SVMXC__SLA_Terms__c from case where id = :CaseId];
        UserLocale = [select id, TimeZoneSidKey from User where Id = :userinfo.getUserId()];   
        onLoad();
        if(strBookingWindowStart=='TODAY')
            tempSVMXList.SVMXC__Date_Required__c = date.Today();
        if(strBookingWindowStart=='TOMORROW')
            tempSVMXList.SVMXC__Date_Required__c = date.Today()+1;

        tempSVMXList.SVMXC__Expected_Ship_Date__c = tempSVMXList.SVMXC__Date_Required__c + iBookingWindowDuration;      

        if(strSLATimestamp == 'Initial Response')
        {
            if(objSelectedCase.SVMXC__Initial_Response_Customer_By__c == null)                
                DisableSLAChkBox = true; 
        }
        if(strSLATimestamp == 'Onsite Response')
        {
            if(objSelectedCase.SVMXC__Onsite_Response_Customer_By__c == null)
                DisableSLAChkBox = true;
        }
        if(strSLATimestamp == 'Restoration')
        {
            if(objSelectedCase.SVMXC__Restoration_Customer_By__c == null)
                DisableSLAChkBox = true;
        }
        if(strSLATimestamp == 'Resolution') 
        {
            if(objSelectedCase.SVMXC__Resolution_Customer_By__c == null)
                DisableSLAChkBox = true;
        }
    }
    
    Integer intLimitCpuTime = Limits.getLimitCpuTime();
    Integer intLimitHeapSize = Limits.getLimitHeapSize();
    

    public void onLoad()
    {
        // Clear Cache
        AvailCount=0;
        XMLResult='<?xml version="1.0" encoding="UTF-8"?><rows>';
        Territories.clear();
        TPARENTS.clear();
        setAvailableTerritories.clear();
        ChildsParrent.clear();
        mParrent.clear();
        Boolean IsTrrAvail=false;
        
         /*
            SECSCAN-822 : Security Scan 
        */
        // Get all territories, to list all territories so that user can select a territory for booking window
        List<String> queryFields = new List<String> {'Name', 'SVMXC__Description__c', 'SVMXC__Parent_Territory__c', 'SVMXC__Active__c', 'SVMXC__Territory_Code__c' };
        
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Territory__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        // Get all territories, to list all territories so that user can select a territory for booking window
        Territories = [Select Id, Name, SVMXC__Description__c, SVMXC__Parent_Territory__c, SVMXC__Active__c, SVMXC__Territory_Code__c From SVMXC__Territory__c where Name != NULL order by LastModifiedDate];
        // Construct the territory tree
        for(SVMXC__Territory__c Ter: Territories)
        {
            setAvailableTerritories.add(Ter.Id);
            TNAME.put(Ter.Id, Ter.Name);
            TCODE.put(Ter.Id, SVMX_SpecialCharParsing(Ter.SVMXC__Territory_Code__c)); // AL-286, XSS issues.
            TDESC.put(Ter.Id, Ter.SVMXC__Parent_Territory__c);
            TACTIVE.put(Ter.Id, Ter.SVMXC__Active__c);
            if(Ter.SVMXC__Parent_Territory__c == null)
                TPARENTS.add(Ter.Id);
            AvailCount++;
            if(string.valueOf(Ter.Id).contains(TTId) && TTId != '')
            {
                IsTrrAvail = true;
                TTId = Ter.Id;
            }
            // Child => Parrent Map 
            ChildsParrent.put(Ter.id, Ter.SVMXC__Parent_Territory__c);
            // Parrent => Child Map 
            addToMparrent(Ter.SVMXC__Parent_Territory__c,Ter.id);
        }
        // For each parrent bulid the XML
        for(Id Par: TPARENTS)
        {
            AvailCount++;
            Tree_frm_Parent(Par);
        }
        XMLResult = XMLResult + '</rows>';
        if(Territories.size() > 999)
        {
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG017(),''));
        }
        if(TTId!='' && IsTrrAvail==false)
        {
            activateBlockMsg('TOP');
            displayTTAttribute=false;
        }
    }
    private String SVMX_SpecialCharParsing(String inputString)  
    {
        if(inputString != NULL && inputString.length() > 0)
        {
            inputString = inputString.replace('&', '&amp;');
            inputString = inputString.replace('\'', '&apos;');
            inputString = inputString.replace('<', '&lt;');
            inputString = inputString.replace('>', '&gt;');
            inputString = inputString.replace('"', '&quot;');
        }
        return inputString;
    }
    public void addToMparrent(Id PID, Id CID )
    {
        if(mParrent.containsKey(PID))
            mParrent.get(PID).add(CID);
        else{ 
            set<Id> lst = new set<Id>();
            lst.add(CID);
            mParrent.put(PID, lst);
        }
    }

    public void Tree_frm_Parent(String parentId)
    {
        set<id> childs= new set<id>();
        // Removing Parrent Id from Available List
        setAvailableTerritories.remove(parentId);        
        if(parentId==TTId)
            XMLResult=XMLResult+'<row id="'+parentId+'" open="1"><cell>1</cell><cell image="../images/icons/shape_ungroup.png">'+'<![CDATA[<a href=/'+parentId+'>'+SpecialCharParser(TNAME.get(parentId))+'</a>]]>'+'</cell><cell>'+CheckNull(SpecialCharParser(TCODE.get(parentId)))+'</cell><cell>'+CheckNull(SpecialCharParser(TNAME.get(TDESC.get(parentId))))+'</cell>';
        else
            XMLResult=XMLResult+'<row id="'+parentId+'" open="1"><cell>0</cell><cell image="../images/icons/shape_ungroup.png">'+'<![CDATA[<a href=/'+parentId+'>'+SpecialCharParser(TNAME.get(parentId))+'</a>]]>'+'</cell><cell>'+CheckNull(SpecialCharParser(TCODE.get(parentId)))+'</cell><cell>'+CheckNull(SpecialCharParser(TNAME.get(TDESC.get(parentId))))+'</cell>';
        
        childs=mParrent.get(ParentId);
        if(childs!=NULL)
        {
            for(id cID: childs)
            {
                Tree_frm_Parent(cID);
                AvailCount++;
            }
        }
        XMLResult = XMLResult+'</row>';
    }
    public void activateBlockMsg(String s)
    {
        deActivateAllMsg();
        if(s == 'POPUP')  
            DisplayPPLevelMessage = true;
        else if(s == 'TOP')       
            DisplayTopBlockLevelMessage = true;
        else if(s == 'BOT')       
            DisplayBotBlockLevelMessage = true;
        else if(s == 'ADJTT')
            DisplayADJTTLevelMessage = true;
        else if(s == 'SEARCHTT')
            DisplaySEARCHTTLevelMessage = true;
    }
    
    public String CheckNull(String s)
    {
        if(s == null)
            return '';
        else
            return s;
    }
    
    public String SpecialCharParser(String s)
    {
        if(s!=NULL)
        {
            s = s.replace('&','&#38;');
            s = s.replace('^','&#94;');
            s = s.replace('\'','&#39;');
            s = s.replace('<','&#60;');
            s = s.replace('>','&#62;');
            s = s.replace('\n',' ');
            return s;
        }
        return NULL;
    }
    
    public Boolean DisplayTopBlockLevelMessage = false;
    public Boolean DisplayBotBlockLevelMessage = false;
    public Boolean DisplayPPLevelMessage = false;   
    public Boolean DisplayADJTTLevelMessage = false;
    public Boolean DisplaySEARCHTTLevelMessage = false;
    
    public Boolean getDisplayTopBlockLevelMessage(){ return DisplayTopBlockLevelMessage; }
    public Boolean getDisplayBotBlockLevelMessage(){ return DisplayBotBlockLevelMessage; }
    public Boolean getDisplayPPLevelMessage(){ return DisplayPPLevelMessage; }   
    public Boolean getDisplayADJTTLevelMessage(){ return DisplayADJTTLevelMessage; } 
    public Boolean getDisplaySEARCHTTLevelMessage(){ return DisplaySEARCHTTLevelMessage; } 
    
    Boolean ShowAlert=false;
    Boolean CheckAllLines=false; 
    Boolean CheckAllAdjLines=false; 
    Boolean IsEditTT=false;
    Boolean bidir;
    Boolean IsChildDataExist;   
    
    public String RowId = '';
    public String ColId = '';
    public String getRowId(){ return RowId; }
    public String getColId(){ return ColId; }
    public void setRowId(String s){ this.RowId = s; }
    public void setColId(String s){ this.ColId = s; }
    
    public void deActivateAllMsg()
    {
        DisplayPPLevelMessage = false;
        DisplayADJTTLevelMessage = false;
        DisplayTopBlockLevelMessage = false;
        DisplayBotBlockLevelMessage = false;
        DisplaySEARCHTTLevelMessage = false;
    }
    
    /******************************** Search Expertise and Product Functionality **********************************/
    Map<string, string> ExpMap = new Map<string, string>();
    Map<string, List<String>> SkillTechLstMap = new Map<string, List<String>>();
    Map<string, List<String>> ProdTechLstMap = new Map<string, List<String>>();
    Map<string, string> PrdMap = new Map<string, string>();
    
    public pageReference SVMX_SearchProductSpecialization()
    {        
        ShowExpertise = false;
        lstServiceGroupSkills.clear();
        lstProductSpecialization.clear();
        PrdMap.clear();
        if(TTId == null || TTId == '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG024()));
        }
        // If valid territory id is available, get all product specialization for the territory
        else
        {
            TrtryId = TTId;
            lstProd.clear();
            lstProd=[Select Id, SVMXC__Group_Member__c, SVMXC__Select__c, SVMXC__Product__c, SVMXC__Product__r.Name From SVMXC__Service_Group_Product__c where SVMXC__Group_Member__r.SVMXC__Service_Territory__c = :TTId];
            if(lstProd.size()>0)
            {
                for(SVMXC__Service_Group_Product__c SGS : lstProd)
                {                  
                    PrdMap.put(SGS.SVMXC__Product__c,SGS.SVMXC__Product__r.Name);                   
                }
                ShowExpertise = false;
                ShowProductSpecialization = true;
                lstProductSpecialization.clear();
                for(String str :PrdMap.KeySet())
                {
                    lstProductSpecialization.add(new wrapperRec(false, PrdMap.get(str), str));
                }               
            }
            else
            {
                ShowExpertise = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG033()));
            }
            TTId = '';
        }       
        return null;
    }   
    
    public pageReference SVMX_SearchExpertise()
    {    
        lstServiceGroupSkills.clear();
        lstProductSpecialization.clear();
        lstExpertise.clear();
        ExpMap.clear();     
        if(TTId == null || TTId == '')
        {         
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG024()));
        }
        // If valid territory id is available, get all skills specialization for the territory
        else
        {
            TrtryId = TTId;
            lstServiceGroupSkills.clear();          
            lstServiceGroupSkills = [select Id, SVMXC__Group_Member__c, SVMXC__Skill__c, SVMXC__Skill__r.Name from SVMXC__Service_Group_Skills__c where SVMXC__Group_Member__r.SVMXC__Service_Territory__c = :TTId];
            if(lstServiceGroupSkills.size()>0)
            {
                for(SVMXC__Service_Group_Skills__c SGS : lstServiceGroupSkills)
                {                 
                    ExpMap.put(SGS.SVMXC__Skill__c, SGS.SVMXC__Skill__r.Name);
                }
                ShowExpertise = true;
                ShowProductSpecialization = false;
                lstExpertise.clear();
                for(String str : ExpMap.KeySet())
                {
                    lstExpertise.add(new wrapperRec(false, ExpMap.get(str), str));
                }                   
            }
            else
            {
                ShowProductSpecialization = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG032()));
            }           
            TTId = '';
        }       
        return null;
    }

    /******************************** Show Booking Window Functionality **********************************/
    List<SVMXC__Booking_Window__c> lstBookingWindowAccess = new List<SVMXC__Booking_Window__c>();
    List<SVMXC__Booking_Window__c> lstAllowedBookingWindow = new List<SVMXC__Booking_Window__c>();
    map<id, SVMXC__Booking_Window__c> maplstAllowedBookingWindow = new map<Id, SVMXC__Booking_Window__c>();
    List<SVMXC__Service_Group_Members__c> TechLst = new List<SVMXC__Service_Group_Members__c>();    
    List<Event> lstSFEvent = new List<Event>();
    List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
    SVMXC__Territory__c objTerritory = new SVMXC__Territory__c();
    BusinessHours DefBH = new BusinessHours();
    Map<String, Integer> mapActualBookingSlot;

    Map<string,Map<string, DateTime>> TchStrtTimeMap = new Map<string,Map<string, DateTime>>();
    Map<string,Map<string, DateTime>> TchEndTimeMap = new Map<string,Map<string, DateTime>>();
    public list<date> lstBWDates = new list<date>();
    map<String, Integer> mapBWStDtCaseCnt = new map<String, Integer>();
    map<Id, String> mapCaseBWStDt = new map<Id, String>();
    public map<date, map<string, integer>> mapCaseCount = new map<date, map<string, integer>>();
    map<date, Map<string, string>> MapOutofSLA = new map<date, Map<string, string>>();
    list<id> lstCurrentBookingWindowIds = new list<id>();
    public String TrtryName;
    public String getTrtryName(){ return TrtryName;}
    public void setTrtryName(String s){ this.TrtryName = s;}

    public pageReference SVMX_ClearExpertiseANDSpecialization()
    {
        if(lstExpertise != null)
            lstExpertise.clear();
        if(lstProductSpecialization != null)
            lstProductSpecialization.clear();
        return null;
    }
    public void SVMX_ShowBookingWindow()
    {
        String strLogger = '';
        integer DaysBtwn;
        boolean ShowError = false;
        RowId = ''; 
        ColId='';
        list<string> lstBookingWindowIds = new list<string>();  
        list<string> ExpIds = new list<string>();
        list<string> ProdIds = new list<string>();
        list<string> TechIds = new list<string>();
        list<string> lstAllBookingWindowIds = new list<string>();    
        Map<string,DateTime> mapBWStartDateTime = new Map<string,DateTime>();
        Map<string,DateTime> mapBWEndDateTime = new Map<string,DateTime>();
        Date StrtDate;
        Boolean isDate = false; 
        DateTime ExpStrtDate;
        DateTime ExpEndDate;
        list<SVMXC__Service_Group_Skills__c> TemplstGroupSkills = new list<SVMXC__Service_Group_Skills__c>();
        list<SVMXC__Service_Group_Product__c> TemplstProd = new list<SVMXC__Service_Group_Product__c>();
        List<Case> lstExistingCase = new List<Case>();     
        MapOutofSLA.clear();
        if(TTId == null || TTId == '')
        {         
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG024()));           
        }
        else
        {
            mapBWStDtCaseCnt.clear();
            set<Id> setBusinessHourIds = new set<Id>();
            Map<String, Double> mapBWSlotDuration = new Map<String, Double>(); 
            Map<String, Double> mapBWAvgSlotDuration = new Map<String, Double>(); 
            TrtryId = TTId;
            TrtryName = TNAME.get(TTId);
            objTerritory = [Select Id, SVMXC__Territory_s_Business_Hours__c, SVMXC__Territory_s_Business_Hours__r.IsActive, SVMXC__Territory_s_Business_Hours__r.timeZoneSidKey, SVMXC__Break_Hours__c, SVMXC__Break_Hours__r.IsActive from SVMXC__Territory__c
                                where Id = :TrtryId];
            /*  If Territory business hours is NULL or is not active, set it to the Org's Default business hours.
            This is the default Business Hours to be used for this Dispatch job.
            */
            if(objTerritory.SVMXC__Territory_s_Business_Hours__c == NULL || objTerritory.SVMXC__Territory_s_Business_Hours__r.IsActive == FALSE)
            {
                objTerritory.SVMXC__Territory_s_Business_Hours__c = DefBH.Id;
                selectedTerritoryTimezone = DefBH.TimeZoneSidKey;
            }
            else
            {
                selectedTerritoryTimezone = objTerritory.SVMXC__Territory_s_Business_Hours__r.timeZoneSidKey;
            }
            
            // If territory's break hours is inactive, set it to NULL
            if (objTerritory.SVMXC__Break_Hours__c != NULL && objTerritory.SVMXC__Break_Hours__r.IsActive == FALSE)
                objTerritory.SVMXC__Break_Hours__c = NULL;
            
            
            setBusinessHourIds.add(objTerritory.SVMXC__Territory_s_Business_Hours__c);
            setBusinessHourIds.add(objTerritory.SVMXC__Break_Hours__c);
            
            if(tempSVMXList.SVMXC__Date_Required__c == null || tempSVMXList.SVMXC__Expected_Ship_Date__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG031()));
            }       
            else
            {
                StrtDate = tempSVMXList.SVMXC__Date_Required__c;
                Date SettingEndDate;
                DateTime SettingDateTime;
                // If SLA is selected by the user
                if(tempSVMXList.SVMXC__Chk_Parent_Product__c)
                {
                    if(strSLATimestamp == 'Initial Response')
                    {
                        SettingEndDate = objSelectedCase.SVMXC__Initial_Response_Customer_By__c.Date();             
                        SettingDateTime = objSelectedCase.SVMXC__Initial_Response_Customer_By__c;                       
                    }
                    if(strSLATimestamp == 'Onsite Response')
                    {
                        SettingEndDate = objSelectedCase.SVMXC__Onsite_Response_Customer_By__c.Date();
                        SettingDateTime = objSelectedCase.SVMXC__Onsite_Response_Customer_By__c;                        
                    }
                    if(strSLATimestamp == 'Restoration')
                    {
                        SettingEndDate = objSelectedCase.SVMXC__Restoration_Customer_By__c.Date();
                        SettingDateTime = objSelectedCase.SVMXC__Restoration_Customer_By__c ;
                    }
                    if(strSLATimestamp == 'Resolution') 
                    {
                        SettingEndDate = objSelectedCase.SVMXC__Resolution_Customer_By__c.Date();
                        SettingDateTime  = objSelectedCase.SVMXC__Resolution_Customer_By__c;
                    }
                    if(SettingEndDate!=null)
                    {
                        if(SettingEndDate >= tempSVMXList.SVMXC__Date_Required__c && SettingEndDate <= tempSVMXList.SVMXC__Expected_Ship_Date__c)
                        {
                            DaysBtwn = tempSVMXList.SVMXC__Date_Required__c.daysBetween(SettingEndDate);
                            isDate = true;
                        }
                        if(SettingEndDate < tempSVMXList.SVMXC__Date_Required__c)
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG014()));
                            isDate = true;
                        }
                    }               
                }               
                if(!isDate)
                {
                    DaysBtwn = tempSVMXList.SVMXC__Date_Required__c.daysBetween(tempSVMXList.SVMXC__Expected_Ship_Date__c);
                    Time myTime = Time.newInstance(0, 0, 0, 0);
                    Time myTime2 = Time.newInstance(23, 59, 59, 59);                                     
                    ExpStrtDate = DateTime.newInstanceGmt(tempSVMXList.SVMXC__Date_Required__c, myTime);
                    ExpEndDate = DateTime.newInstanceGmt(tempSVMXList.SVMXC__Expected_Ship_Date__c, myTime2);
                }

                lstBWDates.clear();

                for(integer i = 0;i <= DaysBtwn; i++)
                {
                    lstBWDates.add(StrtDate);
                    map<string, set<id>> mapNewStringSetId = new map<string, set<id>>();
                    map<string, map<String, List<event> >> mapNewBWTechEvent =  new map<string, map<String, List<event> >>();
                    map<string, integer> mapNewStringInt = new map<string, integer>();
                    map<string, string> mapNewStringString = new map<string, string>();
                    MapOutofSLA.put(StrtDate, mapNewStringString);
                    StrtDate = StrtDate + 1;
                }       

                if(tempSVMXList.SVMXC__Date_Required__c > tempSVMXList.SVMXC__Expected_Ship_Date__c)    
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG025()));
                    ShowError = true;
                }
                if(DaysBtwn > iMaxBookingWindowDuration)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG023()));
                    ShowError = true;
                }
                if(!ShowError)
                {
                    lstBookingWindowAccess = [select SVMXC__Booking_Definition__c from SVMXC__Booking_Window__c where RecordType.Name = 'Access' and SVMXC__User__c = : UserInfo.getUserId()];
                    if(lstBookingWindowAccess.size() > 0)
                    {
                        for(SVMXC__Booking_Window__c ab : lstBookingWindowAccess)
                        {
                            lstBookingWindowIds.add(ab.SVMXC__Booking_Definition__c);
                        }                    
                    }                
                    if(isAllBookingWindow == false)
                    {
                        if(lstBookingWindowIds.size() > 0)
                        {
                            lstAllowedBookingWindow = [select Id,SVMXC__Booking_Window_Name__c,SVMXC__Start_Time__c,SVMXC__End_Time__c,SVMXC__Average_Slots__c from SVMXC__Booking_Window__c where RecordType.Name = 'Definition' and id IN: lstBookingWindowIds order by SVMXC__Display_Order__c];
                        }
                        else
                        {
                            lstAllowedBookingWindow = [select Id,SVMXC__Booking_Window_Name__c,SVMXC__Start_Time__c,SVMXC__End_Time__c,SVMXC__Average_Slots__c from SVMXC__Booking_Window__c where RecordType.Name = 'Definition' and SVMXC__IsDefault__c = true order by SVMXC__Display_Order__c];
                        }
                    }
                    else
                    {
                        lstAllowedBookingWindow = [select Id, SVMXC__Booking_Window_Name__c, SVMXC__Start_Time__c, SVMXC__End_Time__c, SVMXC__Average_Slots__c from SVMXC__Booking_Window__c where RecordType.Name = 'Definition' and (SVMXC__IsDefault__c = true or Id IN : lstBookingWindowIds) order by SVMXC__Display_Order__c];
                    }
                    // DHTMLX properties
                    CollSize = lstAllowedBookingWindow.size();
                    GridTitle = ' ';
                    GridWidth = '100';
                    GridAligne = '';
                    GridTypes = 'ro';               
                    lstCurrentBookingWindowIds.clear();
                     if(lstAllowedBookingWindow.size()==0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG036()));
                        return;
                    } 
                    for(SVMXC__Booking_Window__c objBookingwindow : lstAllowedBookingWindow)
                    {
                        lstAllBookingWindowIds.add(objBookingwindow.Id);
                        maplstAllowedBookingWindow.put(objBookingwindow.Id, objBookingwindow);
                        // DHTMLX properties
                        GridWidth += ',*';
                        GridAligne += ',center';
                        GridTypes += ',ra';
                        
                        // Setting the booking window average slots, if null set it to 1
                        if(objBookingwindow.SVMXC__Average_Slots__c == null)
                        {
                              objBookingwindow.SVMXC__Average_Slots__c = 1;
                        }
                        lstCurrentBookingWindowIds.add(objBookingwindow.Id);
                        for(date d : MapOutofSLA.Keyset())
                        {
                            MapOutofSLA.get(d).put(objBookingwindow.Id, '');
                        }
                    }
                    
                    // Construct a map of Booking Window Start/End time against Booking Window Id
                    for(SVMXC__Booking_Window__c objBookingwindow :lstAllowedBookingWindow)
                    {
                        mapBWStartDateTime.putAll(getBookingWindowDateTime(objBookingwindow.Id, objBookingwindow.SVMXC__Start_Time__c, lstBWDates));
                        mapBWEndDateTime.putAll(getBookingWindowDateTime(objBookingwindow.Id, objBookingwindow.SVMXC__End_Time__c, lstBWDates));           
                    }
                    
                        lstExistingCase = [select Id, SVMXC__BW_Territory__c, SVMXC__Booking_Window__c, SVMXC__BW_Date__c from Case where SVMXC__BW_Territory__c= : TrtryId and SVMXC__Booking_Window__c IN : lstAllBookingWindowIds and SVMXC__BW_Date__c IN : lstBWDates];
                        if(lstExistingCase.size() > 0)
                        {
                            for(Date datBWDate :lstBWDates)
                            {
                                for(SVMXC__Booking_Window__c objBookingWindow :lstAllowedBookingWindow)
                                {
                                    for(Case objCase : lstExistingCase)
                                    {
                                        if(objCase.SVMXC__Booking_Window__c == objBookingWindow.Id && objCase.SVMXC__BW_Date__c == datBWDate)
                                        {
                                            mapCaseBWStDt.put(objCase.Id, objBookingWindow.Id + string.valueOf(datBWDate));
                                        }
                                    }
                                }                                   
                            }
                        }
                        // Get technicians list based on the user selection
                        if(ShowExpertise)
                        {
                           for(integer i = 0; i < lstExpertise.size(); i++)
                           {
                                if(lstExpertise[i].selected)
                                {
                                    ExpIds.add(lstExpertise[i].RecId);                  
                                }
                            }
                            TemplstGroupSkills = [select Id,SVMXC__Group_Member__c from SVMXC__Service_Group_Skills__c where SVMXC__Skill__c IN:ExpIds];
                            TechIds.clear();
                            for(SVMXC__Service_Group_Skills__c skl : TemplstGroupSkills)
                            {
                                TechIds.add(skl.SVMXC__Group_Member__c);
                            }
                            TechLst.clear();
                            TechLst = [Select Id, SVMXC__Enable_Scheduling__c, SVMXC__Break_Hours__c, SVMXC__Break_Hours__r.IsActive, SVMXC__Working_Hours__c, SVMXC__Working_Hours__r.IsActive, SVMXC__Working_Hours__r.timeZoneSidKey, SVMXC__Working_Hours__r.SaturdayEndTime, SVMXC__Working_Hours__r.SaturdayStartTime, SVMXC__Working_Hours__r.FridayEndTime, SVMXC__Working_Hours__r.FridayStartTime, SVMXC__Working_Hours__r.ThursdayEndTime, SVMXC__Working_Hours__r.ThursdayStartTime, SVMXC__Working_Hours__r.WednesdayEndTime, SVMXC__Working_Hours__r.WednesdayStartTime, SVMXC__Working_Hours__r.TuesdayEndTime, SVMXC__Working_Hours__r.TuesdayStartTime, SVMXC__Working_Hours__r.MondayEndTime, SVMXC__Working_Hours__r.MondayStartTime, SVMXC__Working_Hours__r.SundayEndTime, SVMXC__Working_Hours__r.SundayStartTime,SVMXC__Overtime_Hours__c,SVMXC__Service_Territory__c, SVMXC__Salesforce_User__c From SVMXC__Service_Group_Members__c where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c=:TrtryId and Id IN: TechIds];
                        }
                        if(ShowProductSpecialization)
                        {
                            for(integer i = 0; i < lstProductSpecialization.size(); i++)
                            {
                                if(lstProductSpecialization[i].selected)
                                {
                                    ProdIds.add(lstProductSpecialization[i].RecId);                 
                                }
                            }
                            TemplstProd = [select Id,SVMXC__Group_Member__c from SVMXC__Service_Group_Product__c where SVMXC__Product__c IN:ProdIds];
                            TechIds.clear();
                            for(SVMXC__Service_Group_Product__c skl : TemplstProd)
                            {
                                TechIds.add(skl.SVMXC__Group_Member__c);
                            }
                            TechLst.clear();
                            TechLst = [Select Id, SVMXC__Enable_Scheduling__c, SVMXC__Break_Hours__c, SVMXC__Break_Hours__r.IsActive, SVMXC__Working_Hours__c, SVMXC__Working_Hours__r.IsActive, SVMXC__Working_Hours__r.timeZoneSidKey, SVMXC__Working_Hours__r.SaturdayEndTime, SVMXC__Working_Hours__r.SaturdayStartTime, SVMXC__Working_Hours__r.FridayEndTime, SVMXC__Working_Hours__r.FridayStartTime, SVMXC__Working_Hours__r.ThursdayEndTime, SVMXC__Working_Hours__r.ThursdayStartTime, SVMXC__Working_Hours__r.WednesdayEndTime, SVMXC__Working_Hours__r.WednesdayStartTime, SVMXC__Working_Hours__r.TuesdayEndTime, SVMXC__Working_Hours__r.TuesdayStartTime, SVMXC__Working_Hours__r.MondayEndTime, SVMXC__Working_Hours__r.MondayStartTime, SVMXC__Working_Hours__r.SundayEndTime, SVMXC__Working_Hours__r.SundayStartTime,SVMXC__Overtime_Hours__c,SVMXC__Service_Territory__c, SVMXC__Salesforce_User__c From SVMXC__Service_Group_Members__c where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c=:TrtryId and Id IN: TechIds];
                        }
                        if(ProdIds.size() == 0 && ExpIds.size() == 0)
                        {
                            TechLst.clear();
                            TechLst = [Select Id, SVMXC__Enable_Scheduling__c, SVMXC__Break_Hours__c, SVMXC__Break_Hours__r.IsActive, SVMXC__Working_Hours__c, SVMXC__Working_Hours__r.IsActive, SVMXC__Working_Hours__r.timeZoneSidKey, SVMXC__Working_Hours__r.SaturdayEndTime, SVMXC__Working_Hours__r.SaturdayStartTime, SVMXC__Working_Hours__r.FridayEndTime, SVMXC__Working_Hours__r.FridayStartTime, SVMXC__Working_Hours__r.ThursdayEndTime, SVMXC__Working_Hours__r.ThursdayStartTime, SVMXC__Working_Hours__r.WednesdayEndTime, SVMXC__Working_Hours__r.WednesdayStartTime, SVMXC__Working_Hours__r.TuesdayEndTime, SVMXC__Working_Hours__r.TuesdayStartTime, SVMXC__Working_Hours__r.MondayEndTime, SVMXC__Working_Hours__r.MondayStartTime, SVMXC__Working_Hours__r.SundayEndTime, SVMXC__Working_Hours__r.SundayStartTime,SVMXC__Overtime_Hours__c,SVMXC__Service_Territory__c, SVMXC__Salesforce_User__c From SVMXC__Service_Group_Members__c where SVMXC__Active__c = TRUE AND SVMXC__Service_Territory__c=:TrtryId];
                        }

                        set<Id> setTechId = new set<Id>();
                        map<string, string> mapTechSFUser = new map<string, string>();
                        map<string, string> mapTechNonSFUser = new map<string, string>();
                        
                        Map<String, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>> mapTechnicianEvent = new Map<String, List<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>();
                        set<Date> setBWDates = new set<Date>();
                        setBWDates.addAll(lstBWDates);
                        Map<String, String> mapTechTimeZone = new Map<String, String>();
                        if(TechLst != NULL)
                            strLogger += 'Technician count available for the selected territory: ' + TechLst.size() + '\n';
                        if(TechLst.size()>0)    
                        {
                            for(Date oDate : lstBWDates)
                            {
                                for(SVMXC__Booking_Window__c objBookingwindow : lstAllowedBookingWindow)
                                {
                                    setTechId.clear();                          
                                    for(SVMXC__Service_Group_Members__c objTechnician : TechLst)
                                    {
                                        // In technicians business hour is inactive consider only territory business hour
                                        if(objTechnician.SVMXC__Working_Hours__c == NULL || objTechnician.SVMXC__Working_Hours__r.IsActive == FALSE)
                                        {
                                            mapTechTimeZone.put(objTechnician.Id, selectedTerritoryTimezone);
                                            objTechnician.SVMXC__Working_Hours__c = objTerritory.SVMXC__Territory_s_Business_Hours__c;
                                            objTechnician.SVMXC__Break_Hours__c = objTerritory.SVMXC__Break_Hours__c;
                                        }
                                        else
                                        {   // If technicians business hour is active, but if break hour is inactive set break hour to null 
                                            if(objTechnician.SVMXC__Break_Hours__r.IsActive == FALSE)
                                            {
                                                objTechnician.SVMXC__Break_Hours__c = NULL;
                                                setBusinessHourIds.add(objTechnician.SVMXC__Working_Hours__c);
                                            }
                                            else
                                            {
                                                mapTechTimeZone.put(objTechnician.Id, selectedTerritoryTimezone);
                                                setBusinessHourIds.add(objTechnician.SVMXC__Working_Hours__c);
                                                setBusinessHourIds.add(objTechnician.SVMXC__Break_Hours__c);
                                            }
                                        }
                                        setTechId.add(objTechnician.Id);
                                        if(objTechnician.SVMXC__Salesforce_User__c != null)
                                        {
                                            mapTechSFUser.put(objTechnician.SVMXC__Salesforce_User__c, objTechnician.Id);
                                        }
                                        else
                                        {
                                            if(objTechnician.SVMXC__Enable_Scheduling__c)
                                            mapTechNonSFUser.put(objTechnician.Id,objTechnician.Id);  
                                        }
                                    }
                                }
                            }
                            
                            // Get the businesshours that are associated with retrieved technicians.
                            lstTechniciansBusinessHours = [Select Id, IsDefault, IsActive, TimeZoneSidKey, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime,
                                ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, SundayStartTime, SundayEndTime
                                from BusinessHours where Id IN : setBusinessHourIds]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            for(BusinessHours objBH: lstTechniciansBusinessHours)
                            {
                                mapBusinessHours.put(objBH.Id, objBH);
                            }
                            
                            // Get Salesforce and ServiceMax events and check for the technicians availability
                            lstSFEvent = [Select IsAllDayEvent, StartDateTime, OwnerId, WhatId, Id, EndDateTime From Event where OwnerId IN : mapTechSFUser.KeySet() and ((StartDateTime >= : ExpStrtDate and StartDateTime <= : ExpEndDate) OR (EndDateTime >= : ExpStrtDate and StartDateTime <= : ExpEndDate)) order by StartDateTime asc];
                            lstSVMXEvents = [Select SVMXC__WhatId__c, SVMXC__StartDateTime__c, SVMXC__Technician__c, SVMXC__EndDateTime__c, Id From SVMXC__SVMX_Event__c where SVMXC__Technician__c IN : mapTechNonSFUser.KeySet()  and ((SVMXC__StartDateTime__c >= : ExpStrtDate and SVMXC__StartDateTime__c <= : ExpEndDate) OR (SVMXC__EndDateTime__c >= : ExpStrtDate and SVMXC__StartDateTime__c <= : ExpEndDate)) order by SVMXC__StartDateTime__c asc];
                            
                            if(lstSFEvent != NULL)
                            strLogger += 'Salesforce events count: ' + lstSFEvent.size() + '\n';
                            if(lstSVMXEvents != NULL)
                            strLogger += 'ServcieMax events count: ' + lstSVMXEvents.size() + '\n';
                            
                            // Get the unique 3 character key prefix of Work Order object. This is used to check if events are related to Work Orders
                            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
                            Schema.Describesobjectresult woDefinitions;
                            if (allObjs.containsKey('SVMXC__Service_Order__c') == TRUE)
                                woDefinitions = allObjs.get('SVMXC__Service_Order__c').getDescribe();
                            else
                                woDefinitions = allObjs.get('Service_Order__c').getDescribe();
                            String woKeyPrefix = woDefinitions.getKeyPrefix();
                            set<Id> setEventWorkOrderIds = new set<Id>();

                            for(Event objEvent: lstSFEvent)
                            {
                                // Build the event execution time from the event against technician
                                String technicianId = mapTechSFUser.get(objEvent.OwnerId);
                                list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                                SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(objEvent.StartDateTime, objEvent.EndDateTime);
                                if(mapTechnicianEvent.containsKey(technicianId) && mapTechnicianEvent.get(technicianId).size() > 0) // TRUE from the second event for each technician
                                    lstEventTimeWindows = mapTechnicianEvent.get(technicianId);
                                if(mapTechTimeZone.containsKey(technicianId))
                                    lstEventTimeWindows.addAll(wrpEventTimeWindow.doSplitDays(mapTechTimeZone.get(technicianId), setBWDates));
                                mapTechnicianEvent.put(technicianId, lstEventTimeWindows);
                                
                                // Identify whether it is a work order event
                                // If it is a work order event, add the work order to the list of work orders
                                if(objEvent.WhatId != NULL && String.valueof(objEvent.WhatId).startsWith(woKeyPrefix) == TRUE)
                                {
                                    setEventWorkOrderIds.add(objEvent.WhatId);
                                }
                            }
                            System.debug('TEST LOG1: ' + mapTechTimeZone);
                            for(SVMXC__SVMX_Event__c objEvent: lstSVMXEvents)
                            {
                                // Build the event execution time from the event against technician
                                String technicianId = objEvent.SVMXC__Technician__c;
                                list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                                SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpEventTimeWindow = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(objEvent.SVMXC__StartDateTime__c, objEvent.SVMXC__EndDateTime__c);
                                if(mapTechnicianEvent.containsKey(technicianId) && mapTechnicianEvent.get(technicianId).size() > 0) // TRUE from the second event for each technician
                                    lstEventTimeWindows = mapTechnicianEvent.get(technicianId);
                                System.debug('TEST LOG2: ' + mapTechTimeZone.containsKey(technicianId));
                                if(mapTechTimeZone.containsKey(technicianId))
                                    lstEventTimeWindows.addAll(wrpEventTimeWindow.doSplitDays(mapTechTimeZone.get(technicianId), setBWDates));
                                mapTechnicianEvent.put(technicianId, lstEventTimeWindows);
                                
                                // Identify whether it is a work order event
                                // If it is a work order event, add the work order to the list of work orders
                                if(objEvent.SVMXC__WhatId__c != NULL && String.valueof(objEvent.SVMXC__WhatId__c).startsWith(woKeyPrefix) == TRUE)
                                {
                                    setEventWorkOrderIds.add(objEvent.SVMXC__WhatId__c);
                                }
                            }
                            
                            Map<String, Integer> mapBookedSlotCount = new Map<String, Integer>();
                            // Retrieve all work orders related to event, if they are having a case associated with available booking window
                            List<SVMXC__Service_Order__c> lstWorkOrder = [SELECT Id, SVMXC__Case__r.SVMXC__Booking_Window__c, SVMXC__Case__r.SVMXC__BW_Date__c from SVMXC__Service_Order__c where Id IN : setEventWorkOrderIds AND SVMXC__Case__r.SVMXC__Booking_Window__c IN : lstAllBookingWindowIds AND SVMXC__Case__r.SVMXC__BW_Date__c != NULL];
                            set<Id> caseEvents = new set<Id>();
                            for(SVMXC__Service_Order__c objWorkOrder : lstWorkOrder)
                            {
                                caseEvents.add(objWorkOrder.SVMXC__Case__c);
                                String strBookingWindowKey = objWorkOrder.SVMXC__Case__r.SVMXC__Booking_Window__c + string.valueOf(objWorkOrder.SVMXC__Case__r.SVMXC__BW_Date__c);
                                Integer intCaseCount = 1;
                                if(mapBookedSlotCount.get(strBookingWindowKey) != NULL)
                                    intCaseCount += mapBookedSlotCount.get(strBookingWindowKey);
                                mapBookedSlotCount.put(strBookingWindowKey, intCaseCount);
                            }
                            
                            for(Id caseId : mapCaseBWStDt.keySet())
                            {
                                if(!caseEvents.contains(caseId))
                                {
                                    String strBookingWindowKey = mapCaseBWStDt.get(caseId);
                                    integer Count = 1;
                                    if(mapBWStDtCaseCnt.get(strBookingWindowKey) != NULL)
                                        Count += mapBWStDtCaseCnt.get(strBookingWindowKey);
                                    mapBWStDtCaseCnt.put(strBookingWindowKey, Count);
                                }
                            }
                            system.debug('TEST LOG4: ' + mapCaseBWStDt);
                            system.debug('TEST LOG4: ' + mapBWStDtCaseCnt);
                            SMAX_OptiMax_Engine_Ext clsExtension = new SMAX_OptiMax_Engine_Ext();
                            strLogger += 'Usage Details: Before processing technician availability\n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time         : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                            //Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> techAvailability = clsExtension.getTechiniciansAvailability(NULL, TechLst, mapBusinessHours, mapTechnicianEvent, setBWDates);
                            Map<id, Map<date, list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>>> techAvailability = clsExtension.getTechiniciansAvailability(NULL, TechLst, mapBusinessHours, null, setBWDates, null);
                            strLogger += 'Usage Details: After finding technician availability\n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time         : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
            
                            Map<String, Integer> mapBookingWindowAvailableSlot = new Map<String, Integer>();
                            
                            for(Date datBWDate : lstBWDates)
                            {
                                for(SVMXC__Booking_Window__c objBookingwindow : lstAllowedBookingWindow)
                                {
                                    String strBookingWindowKey = objBookingwindow.Id + string.valueOf(datBWDate);
                                    Double dblBWSlotDuration = (mapBWEndDateTime.get(strBookingWindowKey).getTime() - mapBWStartDateTime.get(strBookingWindowKey).getTime()) / (60000);
                                    Double dblAvgSlotDuration = ((mapBWEndDateTime.get(strBookingWindowKey).getTime() - mapBWStartDateTime.get(strBookingWindowKey).getTime()) / (60000 * objBookingwindow.SVMXC__Average_Slots__c) );
                                    Integer intAvailableSlotCount = 0;
                                    Double dblAvailableDuration = 0;
                                    DateTime dtmBWStartTime = mapBWStartDateTime.get(strBookingWindowKey);
                                    DateTime dtmBWEndTime = mapBWEndDateTime.get(strBookingWindowKey);
                                    
                                    for(Id technicianId : techAvailability.keySet())
                                    {
                                        list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstAvailTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                                        lstAvailTimeWindows = techAvailability.get(technicianId).get(datBWDate);
                                        
                                        if(lstAvailTimeWindows != NULL && lstAvailTimeWindows.size() > 0 && dblAvgSlotDuration > 0)
                                        {
                                            dblAvailableDuration = 0;
                                            // Get the events that lies on booking window alone
                                            list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP> lstActualEventTimeWindows = new list<SMAX_OptiMax_Engine_WS.ExecutionTime_WP>();
                                            for(SMAX_OptiMax_Engine_WS.ExecutionTime_WP exeTime: lstAvailTimeWindows)
                                            {
                                                SMAX_OptiMax_Engine_WS.ExecutionTime_WP wrpExeTime = new SMAX_OptiMax_Engine_WS.ExecutionTime_WP(exeTime.startDateTime, exeTime.endDateTime);
                                                if(wrpExeTime.startDateTime >= dtmBWEndTime)
                                                {
                                                    break;
                                                }
                                                else if(wrpExeTime.endDateTime <= dtmBWStartTime)
                                                {
                                                    continue;
                                                }
                                                if(wrpExeTime.startDateTime < dtmBWStartTime)
                                                {
                                                    wrpExeTime.startDateTime = dtmBWStartTime;
                                                    //exeTime.startDate = exeTime.startDateTime;
                                                }
                                                if(wrpExeTime.endDateTime > dtmBWEndTime)
                                                {
                                                    wrpExeTime.endDateTime = dtmBWEndTime;
                                                    //exeTime.endDate = exeTime.endDateTime;
                                                }
                                                // Available duration in minutes
                                                dblAvailableDuration += (wrpExeTime.endDateTime.getTime() - wrpExeTime.startDateTime.getTime()) / 60000;
                                            }
                                            intAvailableSlotCount += dblAvailableDuration.intValue() / dblAvgSlotDuration.intValue();
                                        }
                                    }
                                    //intAvailableSlotCount += dblAvailableDuration.intValue() / dblAvgSlotDuration.intValue();
                                    mapBookingWindowAvailableSlot.put(strBookingWindowKey, intAvailableSlotCount);
                                }
                            }
                            
                            System.debug('TEST LOGG:3 ' + mapBookedSlotCount);
                            mapActualBookingSlot = new Map<String, Integer>();
                            for(SVMXC__Booking_Window__c objBookingwindow : lstAllowedBookingWindow)
                            {
                                for(Date datBWDate : lstBWDates)
                                {
                                    Integer intAvailableSlotCount = 0;
                                    String strBookingWindowKey = objBookingwindow.Id + string.valueOf(datBWDate);
                                    if(mapBookingWindowAvailableSlot.get(strBookingWindowKey) != NULL)
                                    {
                                        intAvailableSlotCount = mapBookingWindowAvailableSlot.get(strBookingWindowKey);
                                    }
                                    /*
                                    // Get the case count related to events that we have considered
                                    if(mapBookedSlotCount.get(strBookingWindowKey) != NULL)
                                    {
                                        intAvailableSlotCount += mapBookedSlotCount.get(strBookingWindowKey);
                                    }
                                    // removing already booked case count
                                    if(mapCaseCount.get(datBWDate) != NULL && mapCaseCount.get(datBWDate).get(objBookingwindow.Id) != NULL)
                                        intAvailableSlotCount = intAvailableSlotCount - mapCaseCount.get(datBWDate).get(objBookingwindow.Id);
                                    */
                                    if(mapBWStDtCaseCnt.get(strBookingWindowKey) != NULL)
                                        intAvailableSlotCount = intAvailableSlotCount - mapBWStDtCaseCnt.get(strBookingWindowKey);
                                    
                                    mapActualBookingSlot.put(strBookingWindowKey, intAvailableSlotCount);
                                    //mapCaseCount.get(datBWDate).put(objBookingwindow.Id, intAvailableSlotCount);
                                    System.debug('TEST LOGG:2 ' + strBookingWindowKey + '=>' + intAvailableSlotCount);
                                }
                            }
                            strLogger += 'Usage Details: Before building the grid\n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time         : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                            
                            integer iDateIndex = 1;
                            XMLResultGrid = '<?xml version="1.0" encoding="UTF-8"?><rows>';
                            StrtDate = tempSVMXList.SVMXC__Date_Required__c;
                            strDataArray = '';
                            RowSize = 0;
                            boolean isheaderbuild = false;
                            for(integer i = 0; i <= DaysBtwn; i++)
                            {
                                XMLResultGrid += '<row id="' + iDateIndex + '">';
                                XMLResultGrid += '<cell id="0">' + StrtDate.format() + '</cell>';
                                integer iBWIndex = 1;                   
                                RowSize += 1;
                                for(String strBookingWindowId :lstCurrentBookingWindowIds)
                                {
                                    if(!isheaderbuild)
                                    {
                                        SVMXC__Booking_Window__c objBookingwindow = maplstAllowedBookingWindow.get(strBookingWindowId);
                                        GridTitle += ',' + objBookingwindow.SVMXC__Start_Time__c + ' To ' + objBookingwindow.SVMXC__End_Time__c + ' (' + objBookingwindow.SVMXC__Booking_Window_Name__c + ')';
                                    }
                                    ActualSlot = mapActualBookingSlot.get(strBookingWindowId + string.valueOf(StrtDate));
    
                                    String BID = strBookingWindowId + string.valueOf(StrtDate);                      
                                    if(SettingDateTime != null)
                                    {
                                        if(mapBWStartDateTime.get(BID) <= SettingDateTime && mapBWEndDateTime.get(BID) <= SettingDateTime)
                                        {
                                            XMLResultGrid += '<cell id="' + iBWIndex + '">' + '</cell>';                      
                                            strDataArray += ' sDataArray[' + iDateIndex + '][' + iBWIndex + '] = "' + ActualSlot + '&nbsp";';
                                            iBWIndex++;
                                        }
                                        else
                                        {
                                            XMLResultGrid += '<cell id="' + iBWIndex + '">' + '</cell>';                      
                                            strDataArray += ' sDataArray[' + iDateIndex + '][' + iBWIndex + '] = "' + 'Out of SLA Limit' + '";';
                                            MapOutofSLA.get(StrtDate).put(strBookingWindowId, 'Out of SLA Limit');                              
                                            iBWIndex++;
                                        }
                                    }
                                    else
                                    {
                                        XMLResultGrid += '<cell id="' + iBWIndex + '">' + '</cell>';                      
                                        strDataArray += ' sDataArray[' + iDateIndex + '][' + iBWIndex + '] = "' + ActualSlot + '&nbsp";';
                                        iBWIndex++;
                                    }
                                }
                                isheaderbuild= true;
                                XMLResultGrid += '</row>';
                                iDateIndex++;
                                StrtDate += 1;
                            }
                            XMLResultGrid += '</rows>';
                            strLogger += 'Usage Details: After building the grid\n\tHeap Size        : ' + Limits.getHeapSize() + ' / ' + intLimitHeapSize + '\n\tCPU Time         : ' + Limits.getCpuTime() + ' / ' + intLimitCpuTime + '\n';
                            if(isDebugEnabled)
                            {
                                // Create a new SVMX_Jobs__c record
                                SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();
                                objJob.SVMXC__OptiMax_Message__c = 'Booking Window Retrieve Available Slots: ' + String.valueof(system.now());
                                objJob.SVMXC__Message__c = strLogger;
                                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objJob, COMM_SecurityUtils.Access.Createable ) ) {
                                    insert objJob; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                                } else {
                                    isError = true;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));
                                }
                            }
                        }
                        else
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, getTAG034()));
                        }
                    }
            }
        }       
    }
    public integer ActualSlot;
    public integer getActualSlot(){return ActualSlot;}
    public void setActualSlot(integer s){this.ActualSlot = s;}

    public String selectedRadio='';
    public String getselectedRadio(){return selectedRadio; }
    public void setselectedRadio(String s){this.selectedRadio = s;  }

    public Map<string,DateTime> getBookingWindowDateTime(String strBookingWindowId, String strBWTime, List<Date> lstSelecteddates)
    {
        Map<string, DateTime> BWDtTimMap = new Map<string, DateTime>();
        String strt;
        time BWStartTime;
        DateTime NewStartDateTime;
        String strBookingWindowKey;
        if(strBWTime != null)
        {
            for(Date CurrDate: lstSelecteddates)
            {
                strBookingWindowKey = strBookingWindowId + string.valueOf(CurrDate);
                if(strBWTime.contains('PM'))
                {  
                    strt = strBWTime.replace(' PM', ':00');
                    BWStartTime = Time.newInstance(integer.valueOf(strt.split(':')[0]), integer.valueOf(strt.split(':')[1]), integer.valueOf(strt.split(':')[2]), 0);
                    if((strt.contains('12:00')) || (strt.contains('12:30')))
                    { }
                    else
                    { 
                        BWStartTime = BWStartTime.addHours(12);
                    }
                }   
                if(strBWTime.contains('AM'))
                {
                    strt = strBWTime.replace(' AM',':00');
                    BWStartTime = Time.newInstance(integer.valueOf(strt.split(':')[0]), integer.valueOf(strt.split(':')[1]), integer.valueOf(strt.split(':')[2]), 0); 
                    if((strt.contains('12:00')) || (strt.contains('12:30')))
                    {
                        BWStartTime = BWStartTime.addHours(12);
                    }
                }
                if(BWStartTime != NULL)
                {
                    NewStartDateTime = getDateTimeInTimezone(CurrDate, BWStartTime, UserLocale.TimeZoneSidKey);
                    BWDtTimMap.put(strBookingWindowKey, NewStartDateTime);
                }
            }
        }
        return BWDtTimMap;
    }
    /* Commented by bala: No need to consider the timezone */
    public Map<string,DateTime> FindDateWithTimeZone(String BId,String BStart, Date CurrDate)
    {      
        String strt;
        String Endd;
        time BWStartTime;
        time BWEndTime;
        DateTime NewStartDateTime;
        DateTime NewEndDateTime;
        Map<string, DateTime> BWDtTimMap = new Map<string, DateTime>();
        if(BStart != null)
        {
            if(BStart.contains('PM'))
            {  
                strt = BStart.replace(' PM', ':00');
                BWStartTime = Time.newInstance(integer.valueOf(strt.split(':')[0]), integer.valueOf(strt.split(':')[1]), integer.valueOf(strt.split(':')[2]), 0);
                if((strt.contains('12:00')) || (strt.contains('12:30')))
                { }
                else
                { 
                    BWStartTime = BWStartTime.addHours(12);
                }
            }   
            if(BStart.contains('AM'))
            {
                strt = BStart.replace(' AM',':00');
                BWStartTime = Time.newInstance(integer.valueOf(strt.split(':')[0]), integer.valueOf(strt.split(':')[1]), integer.valueOf(strt.split(':')[2]), 0); 
                if((strt.contains('12:00')) || (strt.contains('12:30')))
                {
                    BWStartTime = BWStartTime.addHours(12);
                }
            }
        }
        String strBookingWindowKey = '';
        if(BWStartTime!=null)
        {
            NewStartDateTime = getDateTimeInTimezone(CurrDate, BWStartTime, UserLocale.TimeZoneSidKey);
            BWDtTimMap.clear();
            strBookingWindowKey = BId + string.valueOf(CurrDate);
            BWDtTimMap.put(strBookingWindowKey, NewStartDateTime);
        }           
        return BWDtTimMap;
    }
    
    //comment by Akash : This function was commented because the same functionality works fine with Buisness Hours Diff Method              
    // we may need this function in future for multi day booking window feature...
    /*public boolean BWwithBusinessHour(integer index,Date CurrDate, Time Strt, Time Endd,SVMXC__Service_Group_Members__c Tech){
        boolean IsExist = true;
        boolean IsFullDayTrue = false;      
        
        if(index ==0){          
            if(string.valueof(Tech.SVMXC__Working_Hours__r.SundayStartTime)=='00:00:00.000Z' && string.valueof(Tech.SVMXC__Working_Hours__r.SundayEndTime) == '00:00:00.000Z'){
                IsExist = true;
                IsFullDayTrue = true;
            }
            if(Tech.SVMXC__Working_Hours__r.SundayStartTime == null && Tech.SVMXC__Working_Hours__r.SundayEndTime == null){
                IsExist = false;
                IsFullDayTrue = true;
            }
            if(!IsFullDayTrue){
                if(Tech.SVMXC__Working_Hours__r.SundayStartTime >= Endd || Tech.SVMXC__Working_Hours__r.SundayEndTime <= Strt)            
                    IsExist = false;
                else if(Strt<Tech.SVMXC__Working_Hours__r.SundayStartTime || Endd>Tech.SVMXC__Working_Hours__r.SundayEndTime)
                    IsExist = false;
                else 
                    IsExist = true; 
            }                   
        }
        
        if(index ==1){          
            if(string.valueof(Tech.SVMXC__Working_Hours__r.MondayStartTime)=='00:00:00.000Z' && string.valueof(Tech.SVMXC__Working_Hours__r.MondayEndTime) == '00:00:00.000Z'){
                IsExist = true;
                IsFullDayTrue = true;
            }
            if(Tech.SVMXC__Working_Hours__r.MondayStartTime == null && Tech.SVMXC__Working_Hours__r.MondayEndTime == null){
                IsExist = false;
                IsFullDayTrue = true;
            }
            if(!IsFullDayTrue){
                if(Tech.SVMXC__Working_Hours__r.MondayStartTime >= Endd || Tech.SVMXC__Working_Hours__r.MondayEndTime <= Strt)            
                    IsExist = false;
                else if(Strt<Tech.SVMXC__Working_Hours__r.MondayStartTime || Endd>Tech.SVMXC__Working_Hours__r.MondayEndTime)
                    IsExist = false;
                else
                    IsExist = true;                     
            }       
        }
        
        if(index ==2){          
            if(string.valueof(Tech.SVMXC__Working_Hours__r.TuesdayStartTime)=='00:00:00.000Z' && string.valueof(Tech.SVMXC__Working_Hours__r.TuesdayEndTime) == '00:00:00.000Z'){
                IsExist = true;
                IsFullDayTrue = true;
            }           
            if(Tech.SVMXC__Working_Hours__r.TuesdayStartTime == null && Tech.SVMXC__Working_Hours__r.TuesdayEndTime == null){
                IsExist = false;
                IsFullDayTrue = true;
            }
            if(!IsFullDayTrue){
                if(Tech.SVMXC__Working_Hours__r.TuesdayStartTime >= Endd || Tech.SVMXC__Working_Hours__r.TuesdayEndTime <= Strt)          
                    IsExist = false;            
                else if(Strt<Tech.SVMXC__Working_Hours__r.TuesdayStartTime || Endd>Tech.SVMXC__Working_Hours__r.TuesdayEndTime)
                    IsExist = false;
                else
                    IsExist = true; 
            }                   
        }
        
        if(index ==3){
            if(string.valueof(Tech.SVMXC__Working_Hours__r.WednesdayStartTime)=='00:00:00.000Z' && string.valueof(Tech.SVMXC__Working_Hours__r.WednesdayEndTime) == '00:00:00.000Z'){
                IsExist = true;
                IsFullDayTrue = true;
            }
            if(Tech.SVMXC__Working_Hours__r.WednesdayStartTime == null && Tech.SVMXC__Working_Hours__r.WednesdayEndTime == null){
                IsExist = false;
                IsFullDayTrue = true;
            }
            if(!IsFullDayTrue){
                if(Tech.SVMXC__Working_Hours__r.WednesdayStartTime >= Endd || Tech.SVMXC__Working_Hours__r.WednesdayEndTime <= Strt)          
                    IsExist = false;
                else if(Strt<Tech.SVMXC__Working_Hours__r.WednesdayStartTime || Endd>Tech.SVMXC__Working_Hours__r.WednesdayEndTime)
                    IsExist = false;
                else
                    IsExist = true; 
            }                   
        }
        
        if(index ==4){          
            if(string.valueof(Tech.SVMXC__Working_Hours__r.ThursdayStartTime)=='00:00:00.000Z' && string.valueof(Tech.SVMXC__Working_Hours__r.ThursdayEndTime) == '00:00:00.000Z'){
                IsExist = true;
                IsFullDayTrue = true;
            }
            if(Tech.SVMXC__Working_Hours__r.ThursdayStartTime == null && Tech.SVMXC__Working_Hours__r.ThursdayEndTime == null){
                IsExist = false;
                IsFullDayTrue = true;
            }
            if(!IsFullDayTrue){
                if(Tech.SVMXC__Working_Hours__r.ThursdayStartTime >= Endd || Tech.SVMXC__Working_Hours__r.ThursdayEndTime <= Strt)            
                    IsExist = false;
                else if(Strt<Tech.SVMXC__Working_Hours__r.ThursdayStartTime || Endd>Tech.SVMXC__Working_Hours__r.ThursdayEndTime)
                    IsExist = false;
                else
                    IsExist = true;
            }                       
        }
        if(index ==5){
            if(string.valueof(Tech.SVMXC__Working_Hours__r.FridayStartTime)=='00:00:00.000Z' && string.valueof(Tech.SVMXC__Working_Hours__r.FridayEndTime) == '00:00:00.000Z'){
                IsExist = true;
                IsFullDayTrue = true;
            }
            if(Tech.SVMXC__Working_Hours__r.FridayStartTime == null && Tech.SVMXC__Working_Hours__r.FridayEndTime == null){
                IsExist = false;
                IsFullDayTrue = true;
            }
            if(!IsFullDayTrue){
                if(Tech.SVMXC__Working_Hours__r.FridayStartTime >= Endd || Tech.SVMXC__Working_Hours__r.FridayEndTime <= Strt)            
                    IsExist = false;
                else if(Strt<Tech.SVMXC__Working_Hours__r.FridayStartTime || Endd>Tech.SVMXC__Working_Hours__r.FridayEndTime)
                    IsExist = false;
                else
                    IsExist = true;
            }                       
        }
        if(index ==6){
            if(string.valueof(Tech.SVMXC__Working_Hours__r.SaturdayStartTime)=='00:00:00.000Z' && string.valueof(Tech.SVMXC__Working_Hours__r.SaturdayEndTime) == '00:00:00.000Z'){
                IsExist = true;
                IsFullDayTrue = true;
            }
            if(Tech.SVMXC__Working_Hours__r.SaturdayStartTime == null && Tech.SVMXC__Working_Hours__r.SaturdayEndTime == null){
                IsExist = false;
                IsFullDayTrue = true;
            }
            if(!IsFullDayTrue){
                if(Tech.SVMXC__Working_Hours__r.SaturdayStartTime >= Endd || Tech.SVMXC__Working_Hours__r.SaturdayEndTime <= Strt)            
                    IsExist = false;
                else if(Strt<Tech.SVMXC__Working_Hours__r.SaturdayStartTime || Endd>Tech.SVMXC__Working_Hours__r.SaturdayEndTime)
                    IsExist = false;
                else
                    IsExist = true;                     
            }
        }
        return IsExist;
    }*/ 
    
    public static DateTime getDateTimeInTimezone(Date givenDate, Time givenTime, String timeZoneSidKey)
    {
            DateTime gmtDateTime = DateTime.newInstanceGmt(givenDate, givenTime);
            String gmtDateTimeStr = gmtDateTime.formatGmt('yyyy-MM-dd HH:mm:ss');
            Double tmzOffsetMins = (DateTime.valueOfGmt(gmtDateTimeStr).getTime() - DateTime.valueOfGmt(gmtDateTime.format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey)).getTime())/60000;
            DateTime retDateTime = gmtDateTime.addMinutes(tmzOffsetMins.intValue());
        
            // Check if the conversion is correct.
            // If not correct (can happen during DST transition points), adjust the returned date time.
            if(retDateTime.format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey) == gmtDateTimeStr)
                return retDateTime;
            else if(retDateTime.addhours(1).format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey) == gmtDateTimeStr)
                return retDateTime.addhours(1);
            else if(retDateTime.addhours(-1).format('yyyy-MM-dd HH:mm:ss', timeZoneSidKey) == gmtDateTimeStr)
                return retDateTime.addhours(-1);
            else // Given date time is illegal for the given time zone, e.g. 13/Mar/2011, 2:30 AM, America/Los_Angeles
                return retDateTime;
    }
    /*
    public static DateTime TimeZoneConvertor(DateTime givenDateTime, String timeZone)
    {
        //Create DateTime in user selected format
        String initDateStr = givenDateTime.format('yyyy-MM-dd HH:mm:ss', timeZone);
        //Create DateTime in GMT format
        String modDateStr = givenDateTime.format('yyyy-MM-dd HH:mm:ss', 'GMT');
        //Compute the difference
        Long st = datetime.valueof(initDateStr).getTime();
        Long et = datetime.valueof(modDateStr).getTime();
        Long differenceSec = ( (st - et) / 60000 );
        return (datetime.valueof(modDateStr).addMinutes(integer.valueof(String.valueof(differenceSec))));
    }
    */
    public String getXMLResultGrid()
    {
        if(XMLResultGrid != null && XMLResultGrid .length() > 0)
            return XMLResultGrid; 
        else
            return '<?xml version="1.0" encoding="UTF-8"?><rows></rows>';
    }
    public pageReference SVMX_ConfirmBookingWindow()
    {
        String url;
        pageReference p;        
        boolean IsError = false;
        boolean IsSave = true;
        boolean IsSLAError = true;
        Map<string,DateTime> mapPreferredStartDateTime = new Map<string,DateTime>();
        Map<string,DateTime> mapPreferredEndDateTime = new Map<string,DateTime>();
        try
        {  
            if(RowId=='' && ColId=='')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG015()));
                IsError = true;
            }       
            else
            {
                integer intSelectedRowId = integer.valueOf(RowId);
                integer intSelectedColumnId = integer.valueOf(ColId);
                intSelectedRowId = intSelectedRowId - 1;
                intSelectedColumnId = intSelectedColumnId - 1;
                String strBookingWindowKey = lstAllowedBookingWindow[intSelectedColumnId].Id + string.valueOf(lstBWDates[intSelectedRowId]);
                if(mapActualBookingSlot.get(strBookingWindowKey) <= 0)
                {
                    IsSLAError=false;
                    if(bAllowOverbooking == False)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, getTAG027()));
                        IsError = true;
                    }
                    else
                        IsError = false;
                }
                if(IsSLAError)
                {
                    if(MapOutofSLA.get(lstBWDates[intSelectedRowId]).get(lstAllowedBookingWindow[intSelectedColumnId].Id) == 'Out of SLA Limit')
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG028()));
                        IsError = true;             
                    }
                }
                if(!IsError)
                {
                    Case objSelectedCase = new Case(Id = objSelectedCase.Id);
                    objSelectedCase.SVMXC__BW_Date__c = lstBWDates[intSelectedRowId];
                    objSelectedCase.SVMXC__Booking_Window__c = lstAllowedBookingWindow[intSelectedColumnId].Id;
                    objSelectedCase.SVMXC__BW_Selected_By__c = Userinfo.getUserId();
                    objSelectedCase.SVMXC__BW_Selected_On__c  = system.now();
                    objSelectedCase.SVMXC__BW_Territory__c  = TrtryId;
                    objSelectedCase.SVMXC__BW_Time_Zone__c = UserLocale.TimeZoneSidKey;
                    objSelectedCase.SVMXC__BW_Slots_Before__c = mapActualBookingSlot.get(strBookingWindowKey);
                    mapPreferredStartDateTime.putAll(FindDateWithTimeZone(lstAllowedBookingWindow[intSelectedColumnId].Id, lstAllowedBookingWindow[intSelectedColumnId].SVMXC__Start_Time__c, lstBWDates[intSelectedRowId]));
                    mapPreferredEndDateTime.putAll(FindDateWithTimeZone(lstAllowedBookingWindow[intSelectedColumnId].Id, lstAllowedBookingWindow[intSelectedColumnId].SVMXC__End_Time__c, lstBWDates[intSelectedRowId]));
                    objSelectedCase.SVMXC__Preferred_Start_Time__c = mapPreferredStartDateTime.get(strBookingWindowKey);
                    objSelectedCase.SVMXC__Preferred_End_Time__c = mapPreferredEndDateTime.get(strBookingWindowKey);
                    //CRUD
                    if (!securityUtils.verifyFieldAccess(objSelectedCase, COMM_SecurityUtils.Access.Updateable))
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }           
                    else
                        {
                            update objSelectedCase; //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                        }
                    //update objSelectedCase;
                    url = '/' + objSelectedCase.Id;
                }
            }               
            if(IsError)
            {
                p = null; 
            }
            else
            {
                p = new pageReference(url);
                p.setRedirect(true);            
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return p;
    }

    public pageReference Cancel()
    {
        String url;
        pageReference p;
        url = '/' + objSelectedCase.Id;
        p = new pageReference(url);
        p.setRedirect(true);
        return p;
    }
    
    public class wrapperRec
    {
        public wrapperRec(){}
        public boolean selected = false;
        public boolean getselected(){return this.selected;}
        public void setselected(boolean b){this.selected = b;}

        public String RecName = '';
        public String getRecName(){return this.RecName;}
        public void setRecName(String str){this.RecName = str;}

        public String RecId = '';
        public String getRecId(){return this.RecId;}
        public void setRecId(String str){this.RecId = str;}

        public wrapperRec(boolean bselected, String strRecName, String strRecId)
        {
            selected = bselected;
            RecName = strRecName;
            RecId = strRecId;
        }
    }
}