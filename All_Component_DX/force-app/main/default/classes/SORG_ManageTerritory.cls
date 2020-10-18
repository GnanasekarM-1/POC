public with Sharing class SORG_ManageTerritory{
    //-------------------NPS Related...
    string ZoneDefinitionPage = '/apex/SVMXC__WORD_ManageZoneDefinition';
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    public String getZoneDefinitionPage(){
       return  ZoneDefinitionPage;
    }
    public void setZoneDefinitionPage(String str){
         ZoneDefinitionPage = str;
    }
    //---------------------------------
    
    //Changes done for defect 007042.
    public Map<String, String> svmxSettingList; 
    
    //Translations
    public String getGBL006() {return (svmxSettingList != null && svmxSettingList.containsKey('GBL006'))?svmxSettingList.get('GBL006') : 'Kilometer';}
    
    public String getTAG001() {return system.label.SORG002_TAG001;}// 'View Territory'
    public String getTAG002() {return system.label.SORG002_TAG002;}// 'Territory Attribute'
    public String getTAG003() {return system.label.SORG002_TAG003;}// 'Select'
    public String getTAG004() {return system.label.SORG002_TAG004;}// 'Add Coverage'
    public String getTAG005() {return system.label.SORG002_TAG005;}//  'Save'
    public String getTAG006() {return system.label.SORG002_TAG006;}// 'Delete'
    public String getTAG007() {return system.label.SORG002_TAG007;}// 'Record saved sucessfully'
    public String getTAG008() {return system.label.SORG002_TAG008;}// 'Record sucessfully deleted'
    public String getTAG009() {return system.label.SORG002_TAG009;}// 'No records to display'
    public String getTAG010() {return system.label.SORG002_TAG010;}// 'Requesting...'
    public String getTAG011() {return system.label.SORG002_TAG011;}// 'You must enter a territory name'
    public String getTAG012() {return system.label.SORG002_TAG012;}// 'Review all error messages below to correct your data.'
    public String getTAG013() {return system.label.SORG002_TAG013;}// 'Please choose coverage type'
    public String getTAG014() {return system.label.SORG002_TAG014;}// 'Please enter coverage value'
    public String getTAG015() {return system.label.SORG002_TAG015;}// 'Country List'
    public String getTAG016() {return system.label.SORG002_TAG016;}// 'Add Territory'
    public String getTAG017() {return system.label.SORG002_TAG017;}// 'Delete'
    public String getTAG018() {return system.label.SORG002_TAG018;}// 'Quick Add Zip Coverage'
    public String getTAG019() {return system.label.SORG002_TAG019;}// 'Quick Add Country Coverage'
    public String getTAG020() {return system.label.SORG002_TAG020;}// 'Create Zip Codes'
    public String getTAG021() {return system.label.SORG002_TAG021;}// 'Start Zip Code'
    public String getTAG022() {return system.label.SORG002_TAG022;}// 'End Zip Code'
    public String getTAG023() {return system.label.SORG002_TAG023;}// 'Select Country'
    public String getTAG024() {return system.label.SORG002_TAG024;}// 'Select Country'
    public String getTAG025() {return system.label.SORG002_TAG025;}// 'Add'
    public String getTAG026() {return system.label.SORG002_TAG026;}// 'Remove'
    public String getTAG027() {return system.label.SORG002_TAG027;}// 'Enter a valid:'
    public String getTAG028() {return system.label.SORG002_TAG028;}// 'Select some records to save'
    public String getTAG029() {return system.label.SORG002_TAG029;}// 'Edit Territory'
    public String getTAG030() {return system.label.SORG002_TAG030;}// 'Territory Name'
    public String getTAG031() {return system.label.SORG002_TAG031;}// 'Description'
    public String getTAG032() {return system.label.SORG002_TAG032;}// 'Are you sure to proceed?'
    public String getTAG033() {return system.label.SORG002_TAG033;}// 'Please select a record to delete'
    public String getTAG034() {return system.label.SORG002_TAG034;}// 'Please enter both zip codes'
    public String getTAG035() {return system.label.SORG002_TAG035;}// 'More than one pattern match found'
    public String getTAG036() {return system.label.SORG002_TAG036;}// 'This is not a valid range of zip codes'
    public String getTAG037() {return system.label.SORG002_TAG037;}// 'Start Zip Code and End zip Code should be of equal length'
    public String getTAG038() {return system.label.SORG002_TAG038;}// 'Territory Code'
    public String getTAG039() {return system.label.SORG002_TAG039;}// 'Parent Territory'
    public String getTAG040() {return system.label.SORG002_TAG040;}// 'Active'
    public String getTAG041() {return system.label.SORG002_TAG041;}// 'Territory Management Console'
    public String getTAG042() {return system.label.SORG002_TAG042;}// 'Submit'
    public String getTAG043() {return system.label.SORG002_TAG043;}// 'Close'
    public String getTAG044() {return system.label.SORG002_TAG044;}// 'Country Name'
    public String getTAG045() {return system.label.SORG002_TAG045;}// ''
    public String getTAG046() {return system.label.SORG002_TAG046;}//'Territory Code'
    public String getTAG047() {return system.label.SORG002_TAG047;}// 'Parent Territory'
    public String getTAG048() {return system.label.SORG002_TAG048;}// 'Edit'
    public String getTAG049() {return system.label.SORG002_TAG049;}// 'Please select a Territory first'
    public String getTAG050() {return system.label.SORG002_TAG050;}// 'Please create at least one coverage record to save'
    public String getTAG051() {return system.label.SORG002_TAG051;}// 'Duplicate coverage entry'
    public String getTAG052() {return system.label.SORG002_TAG052;}// 'Parent and child territory names cannot be the same'
    public String getTAG053() {return system.label.SORG002_TAG053;}// 'Back To Setup Home'
    public String getTAG054() {return system.label.SORG002_TAG054;}// 'Attribute'
    public String getTAG055() {return system.label.SORG002_TAG055;}// 'Value'
    public String getTAG056() {return system.label.SORG002_TAG056;}// 'Select'
    public String getTAG057() {return system.label.SORG002_TAG057;}// 'Zip code range must have numeric characters only'
    public String getTAG058() {return system.label.SORG002_TAG058;}// 'Please select atleast one country to save'
    public String getTAG059() {return system.label.SORG002_TAG059;}// 'Go'
    public String getTAG060() {return system.label.SORG002_TAG060;}// 'Add Selected'
    public String getTAG061() {return system.label.SORG002_TAG061;}// 'Please select a valid territory'
    public String getTAG062() {return system.label.SORG002_TAG062;}// 'A territory cannot be adjacent to itself'
    public String getTAG063() {return system.label.SORG002_TAG063;}// 'Please select at least one record first'
    public String getTAG064() {return system.label.SORG002_TAG064;}// 'More than 1000 territories found. Only 1000 territories are supported in this release of ServiceMax. Please report this to your ServiceMax administrator.'
    public String getTAG065() {return system.label.SORG002_TAG065;}// 'Parent territories or Child territories cannot be designated as adjacent territories'

    public String getHLPURL() {return system.label.SORG002_HLPURL;}
    public String getTAG066() {return system.label.SORG002_TAG066;}// 'Territoty Coverage'
    public String getTAG067() {return system.label.SORG002_TAG067;}// 'Adjacent Territory'
    public String getTAG068() {return system.label.SORG002_TAG068;}// 'ServiceMax Manage Territory Help' //'ServiceMax Manage Territory Help'
    public String getTAG069() {return system.label.SORG002_TAG069;}// 'Cannot create more than 100 records at a ti'
    public String getTAG070() {return system.label.SORG002_TAG070;}// 'Enter range of zip codes covered by this territory'
    public String getTAG071() {return system.label.SORG002_TAG071;}// 'Automatically manage bidirectional entries'
    public String getTAG072() {return system.label.SORG002_TAG072;}// 'Search territories by entering a keyword'
    public String getTAG073() {return system.label.SORG002_TAG073;}// 'Territory Name'
    public String getTAG074() {return system.label.SORG002_TAG074;}// 'Duplicate adjacent territory '
    public String getTAG075() {return system.label.SORG002_TAG075;}// 'All child & adjacent territories and coverage information for this territory will be deleted permanently. This cannot be rolled back. Are you sure to proceed?'
    public String getTAG076() {return system.label.SORG002_TAG076;}// 'Record deleted. The record you attempted to access has been deleted. Deleted data is stored in the Recycle Bin for 30 days.'
    public String getTAG077() {return system.label.SORG002_TAG077;}// 'Trying to create closed loop. Child cannot be a parent of itself'
    public String getTAG078() {return system.label.SORG002_TAG078;}// 'Number of Technicians'
    public String getTAG079() {return system.label.SORG002_TAG079;}// 'Select countries covered by this territory'
    public String getTAG080() {return system.label.SORG002_TAG080;}// 'Special character ^ is not allowed to be a part of the territory name'
    public String getTAG101() {return system.label.SORG002_TAG101;}// 'Cost'//Per Mile Cost//
    public String getTAG102() {return system.label.SORG002_TAG102;}// 'Per Hour Cost'//Per Hour Cost
    public String getTAG103() {return system.label.SORG002_TAG103;}// 'Fixed Cost'//Fixed Cost
    public String getTAG104() {return system.label.SORG002_TAG104;}// 'Average Driving Speed'//Average Speed//
    public String getTAG105() {return system.label.SORG002_TAG105;}// 'Max Round Trip Distance Daily'//Max Distance//
    public String getTAG106() {return system.label.SORG002_TAG106;}// 'Max Daily Hours'//Max Daily Hours  With Break//
    public String getTAG107() {return system.label.SORG002_TAG107;}// 'Max Hours'//Max Weekly Hours With Daily Break//
    public String getTAG108() {return system.label.SORG002_TAG108;}// 'Dispatch Factors'//Max Weekly Hours
    public String getTAG109() {return system.label.SORG002_TAG109;}// : '(Miles/Hour)'
    public String getTAG110() {return system.label.SORG002_TAG110;}// '(Km/Hour)'
    public String getTAG111() {return system.label.SORG002_TAG111;}// '(Miles)'
    public String getTAG112() {return system.label.SORG002_TAG112;}// '(Kilometer)'
    public String getTAG113() {return system.label.SORG002_TAG113;}// 'Territorys Business Hours'
    public String getTAG114() {return system.label.SORG002_TAG114;}// 'Per Mile'
    public String getTAG115() {return system.label.SORG002_TAG115;}// 'Per KM'
    public String getTAG116() {return system.label.SORG002_TAG116;}// 'Break Hours'
    public String getTAG117() {return system.label.SORG002_TAG117;}
    
    String ShowAddEdit;
    String TeritoryKeyword;
    public List<SVMXC__Dispatcher_Access__c> DsptchrList = new List<SVMXC__Dispatcher_Access__c>();
    //SVMXC__Territory__c ROterritoryChild = new SVMXC__Territory__c();
    // SVMXC__Territory__c ROterritoryParent = new SVMXC__Territory__c();
    public SVMXC__Territory__c AddTrtry = new SVMXC__Territory__c();
    public SVMXC__Territory__c EditTT = new SVMXC__Territory__c();
    
    //Added by Naveen V on 30-June-2012 for bug fix by Apurva Bug no. 003656
    Map<String, String> mapTparentsNameId =  new Map<String, String> {};
    
    //Map<String, Integer> TTECH =  new Map<String, Integer> {};
    public Boolean DisplayTopBlockLevelMessage = false;
    public Boolean DisplayBotBlockLevelMessage = false;
    public Boolean DisplayPPLevelMessage = false;
    public Boolean displayZipPopup = false;
    public Boolean displayCountryPopup = false;
    public Boolean DisplayADJTTLevelMessage = false;
    public Boolean DisplaySEARCHTTLevelMessage = false;
    Boolean ShowAlert=false;
    Boolean CheckAllLines=false; 
    Boolean CheckAllAdjLines=false; 
    Boolean isConfigureMode=false; 
    Boolean displayTTPopup=false;
    Boolean displayTTAttribute=false;
    Boolean IsEditTT=false;
    Boolean bidir;
    Boolean IsChildDataExist;
    Integer AvailCount=0;
    double SetingperHourCost;
    double SettingperKmMileCost;
    double SettingfixCost;
    double SettingavgSpeed;
    double SettingmaxDistance;
    double SettingAverageDriveTime;
    
    public String DeleteAlertMessage;
    public String getDeleteAlertMessage(){if(IsChildDataExist==true)return getTAG075();else return getTAG032();}
    
    public String TTId='';
    public String getTTId(){return TTId;}
    public void setTTId(String id){this.TTId=id;}
    
    String RO_Parent;
    public String getRO_Parent(){return RO_Parent;}
    public void setRO_Parent(String id){this.RO_Parent=id;}
    
    String RO_Child;
    public String getRO_Child(){return RO_Child;}
    public void setRO_Child(String id){this.RO_Child=id;}
    
    public String ZipStart;
    public String getZipStart(){return ZipStart;}
    public void setZipStart(String value){this.ZipStart=value;}
    
    public String ZipEnd;
    public String getZipEnd(){return ZipEnd;}
    public void setZipEnd(String value){this.ZipEnd=value;}
    
    public List<String> Countries = new List<String>();
    public List<String> SCountries = new List<String>();
    public List<String> ACountries = new List<String>();
    
    public List<String> Country = new List<String>(); //Base
    public List<String> getCountry(){   return this.Country; }  
    public void setCountry(String[] s){ this.Country =s; } 
    
    public List<String> SCountry = new List<String>();  //To
    public List<String> getSCountry(){  return this.SCountry; }  
    public void setSCountry(String[] s){ this.SCountry =s; } 
    
    public List<String> T1Country = new List<String>();
    public List<String> T2Country = new List<String>();
    
    public List<SelectOption> SelectedCountry = new List<SelectOption>();
    public List<SelectOption> AvailCountry = new List<SelectOption>();
    
    Map<Id , set<Id>> mParrent = new Map<Id , set<Id>>();  
    set<id> CHILDListIds= new set<id>();
    
    String Tid= System.currentPageReference().getParameters().get('Tid'); 
    String showOnlySel = System.currentPageReference().getParameters().get('ShowOnlySel'); 
    
    Id CoverageRecType = getEstRecordTypes('SVMXC__Territory_Coverage__c','Coverage').Id;
    Id AdjacencyRecType = getEstRecordTypes('SVMXC__Territory_Coverage__c','Adjacency').Id;

    public SORG_ManageTerritory(){
        //Changes done for defect 007042.
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        svmxSettingList = commSettings.SVMX_getSettingList('SORG002');
        Map<String, String> svmxOptSettingList = commSettings.SVMX_getSettingList('OMAX002');
        List<String> lstOMAX003Settings = new List<String>{'SET012'};
        Map<String, String> svmxDispatchCalcSettingList = commSettings.SVMX_getSettingList('OMAX003', lstOMAX003Settings);

        //Get the list of countries 
        Schema.DescribeFieldResult CT =SVMXC__ServiceMax_Settings__c.SVMXC__Country__c.getDescribe();
        List<Schema.PicklistEntry> P = CT.getPicklistValues();
        for(Schema.PicklistEntry pl: P){
            Countries.add(pl.getLabel());
        }
        if(getGBL006()=='Mile'){
            Speed = getTAG104() +' '+getTAG109();
            Distance = getTAG105() +' ' + getTAG111();
            Cost = getTAG101() +' '+ getTAG114();
        }
        else if(getGBL006()=='Kilometer'){
            Speed = getTAG104() +' '+ getTAG110();
            Distance = getTAG105() +' '+ getTAG112();
            Cost = getTAG101() +' '+ getTAG115();
        }
        
        SetingperHourCost = double.valueOf(svmxOptSettingList.get('SET005'));
        SettingperKmMileCost = double.valueOf(svmxOptSettingList.get('SET006'));
        SettingfixCost = double.valueOf(svmxOptSettingList.get('SET007'));
        SettingavgSpeed = double.valueOf(svmxOptSettingList.get('SET008'));
        SettingmaxDistance = double.valueOf(svmxOptSettingList.get('SET009'));
        SettingAverageDriveTime = double.valueOf(svmxDispatchCalcSettingList.get('SET012'));
        //SetingperHourCost = 60;
        //SettingperKmMileCost =1;
        //SettingfixCost =0;
        //SettingavgSpeed = 40;
        //SettingmaxDistance = 1000;
        
        if(Tid!=NULL)
            TTId=Tid;
    }

    public string Speed;
    public string getSpeed(){ return Speed;}        
    public void setSpeed(string s){ this.Speed=s;}
    
    public string Distance;
    public string getDistance(){ return Distance;}      
    public void setDistance(string s){ this.Distance=s;}
    
    public string Cost;
    public string getCost(){ return Cost;}      
    public void setCost(string s){ this.Cost=s;}

    //======================================== Recordtype ===================================================//
    public RecordType getEstRecordTypes(String ObjectName,String recTypeName){
        RecordType erTypes;
        String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\''+ObjectName+'\' and Name=\''+recTypeName+'\'';       
        erTypes = Database.query(SOQL);      
        return erTypes;
    }

    //Changes done for defect 007042.
    Boolean IsTrrAvail = false;
    public Boolean getIsTrrAvail(){ return IsTrrAvail;}  
    
    public String getOnload(){
        //Changes done for defect 009822/009832.
        String JSONString = '';
        list<SVMXC__Territory__c> lstTerritory = new list<SVMXC__Territory__c>();
        try{
            map<String, SVMXC__Territory__c> mapTerritory = new map<String, SVMXC__Territory__c>([Select Id, Name, SVMXC__Parent_Territory__c, SVMXC__Territory_Code__c From SVMXC__Territory__c where Name != null  order by LastModifiedDate]);
            
            if(mapTerritory != null){
                if(TTId != null && mapTerritory.containsKey(TTId))
                    IsTrrAvail = true;
                
                if(IsTrrAvail && showOnlySel == '1'){
                    mParrent.clear();
                    for(SVMXC__Territory__c objTerritory: mapTerritory.Values()){
                        if(objTerritory.SVMXC__Parent_Territory__c != null)
                            addToMparrent(objTerritory.SVMXC__Parent_Territory__c, objTerritory.Id);
                    }
                    
                    String tempId = TTId;
                    while(tempId != null && mapTerritory.containsKey(tempId)){
                        addChildTerritories(tempId, lstTerritory, mapTerritory);
                        tempId = mapTerritory.get(tempId).SVMXC__Parent_Territory__c;
                    }
                    mParrent.clear();
                }
                else{ 
                    lstTerritory.addAll(mapTerritory.values());
                }
                
                mapTerritory.clear();
                for(SVMXC__Territory__c objTerritory : lstTerritory){
                    objTerritory.Name = SpecialCharParser(objTerritory.Name);
                    objTerritory.SVMXC__Territory_Code__c = SpecialCharParser(objTerritory.SVMXC__Territory_Code__c);
                }
                JSONString = JSON.serialize(lstTerritory);
            }
        }
        catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        return JSONString;
    }
    
    public void addChildTerritories(String parentID, list<SVMXC__Territory__c> lstTerritory, map<String, SVMXC__Territory__c> mapTerritory){
        if(parentID != null && mapTerritory.containsKey(parentID)){
            lstTerritory.add(mapTerritory.get(parentID));
            
            set<Id> lstChild = mParrent.get(parentID);
            if(lstChild != null){
                for(String childID :lstChild)
                    addChildTerritories(childID, lstTerritory, mapTerritory);
            }
        }
    }

    //Changes done for defect 009822/009832.
    public void addToMparrent(Id PID, Id CID ){
        if(!mParrent.containsKey(PID))
            mParrent.put(PID, new set<Id>());
        mParrent.get(PID).add(CID);
    }
    
    //wrapperTTA Class
    public class wrapperTTA
    {
        //public  SVMXC__Territory_Coverage__c WSTTA {get; set;}
        public  SVMXC__Territory_Coverage__c WSTTA;
        public  SVMXC__Territory_Coverage__c getWSTTA(){return WSTTA;}
        public  void setWSTTA(SVMXC__Territory_Coverage__c  o){WSTTA = o;}
        public  boolean Selected{get; set;}

        public wrapperTTA(SVMXC__Territory_Coverage__c WS, boolean bselected)
        {
            WSTTA = WS;
            Selected = bselected;
        } 
    }  
    public class wrapperTT
    {
        public  SVMXC__Territory__c WSTTA {get; set;}
        public  boolean Selected{get; set;}

        public wrapperTT(SVMXC__Territory__c WS, boolean bselected)
        {
            WSTTA = WS;
            Selected = bselected;
        } 
    }    

    public List<wrapperTTA> wrapSetCOV = new List<wrapperTTA>(); 
    public List<wrapperTTA> getwrapSetCOV(){return wrapSetCOV;}  

    public List<wrapperTTA> wrapSetADJ = new List<wrapperTTA>(); 
    public List<wrapperTTA> getwrapSetADJ(){return wrapSetADJ;}  

    public List<wrapperTT> wrapSearchRes = new List<wrapperTT>(); 
    public List<wrapperTT> getwrapSearchRes(){return wrapSearchRes;}  

    //Getters Setters
    //========================================= Function : Lists Territory Attribute =============================================//
    public SVMXC__Territory__c getAddTrtry(){
        return AddTrtry;
    }
    public Boolean getCheckAllLines() {return CheckAllLines;  }
    public Boolean getCheckAllAdjLines() {return CheckAllAdjLines;  }
    public Boolean getbidir() {return bidir;  }
    public Boolean getShowAlert() {if(TTId!='')return true;else return false;  }
    public String getTTListStyle() {if(AvailCount==0)return 'display:none';else return 'display:block';  }
    public void setbidir(boolean b) {this.bidir=b;  }
    public String getShowAddEdit() {return ShowAddEdit;  }
    public String getTeritoryKeyword() {return TeritoryKeyword;  }
    public void setTeritoryKeyword(String s) {this.TeritoryKeyword=s;  }
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
    public void setCheckAllAdjLines(Boolean chkAll){CheckAllAdjLines=chkAll;}
     
    public boolean getIsListAvail(){
        boolean avail=false;
        if(wrapSetCOV.size()>0)
        avail=true;
        return avail;
    }

    public boolean getIsADJAvail(){
        boolean avail=false;
        if(wrapSetADJ.size()>0)
        avail=true;
        return avail;
    }

    public boolean getIsSRAvail(){
        boolean avail=false;
        if(wrapSearchRes.size()>0)
        avail=true;
        return avail;
    }

    public PageReference loadTerritory() { 
        displayTTAttribute=false;
        if(TTId!='' && TTId!=NULL){
            displayTTAttribute=true;
            loadTTattribute();
            ZoneDefinitionPage =  '/apex/SVMXC__WORD_ManageZoneDefinition' + '?id='+TTId ;
        }
        return null;
    }

    public void loadTTattribute(){
        uncheckCheckbox();
        bidir=false;
        wrapSetCOV.clear();
        wrapSetADJ.clear();
        generateCHILDList(TTId); 
        wrapSearchRes.clear();
        TeritoryKeyword='';
        List<SVMXC__Territory_Coverage__c> TTattribute = new List<SVMXC__Territory_Coverage__c>();
        DsptchrList.clear();
        system.debug('DsptchrList1  '+ DsptchrList );
        if(displayZipPopup==false || displayCountryPopup==false){
            DsptchrList = [select Id,Name,SVMXC__Select__c,SVMXC__Territory__c,SVMXC__Dispatcher__c from SVMXC__Dispatcher_Access__c where SVMXC__Territory__c=:TTId];      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug('DsptchrList2  '+ DsptchrList );
            TTattribute = [Select SVMXC__Type__c,SVMXC__value__c,SVMXC__Active__c,SVMXC__Territory__c from SVMXC__Territory_Coverage__c where SVMXC__Territory__c = :TTId and SVMXC__Record_Type_Name__c='Coverage'];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__Territory_Coverage__c tta:TTattribute){
                wrapperTTA Twrap = new wrapperTTA(tta,false);
                wrapSetCOV.add(Twrap);
            }
            TTattribute.clear();
            TTattribute = [Select SVMXC__Type__c,SVMXC__value__c,SVMXC__Active__c,SVMXC__Territory__c,SVMXC__Adjacent_Territory__c from SVMXC__Territory_Coverage__c where SVMXC__Territory__c = :TTId and SVMXC__Record_Type_Name__c='Adjacency'];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            for(SVMXC__Territory_Coverage__c tta:TTattribute){                                
                wrapperTTA Twrap = new wrapperTTA(tta,false);
                wrapSetADJ.add(Twrap);
            }
            if(wrapSetCOV.size()>0 || wrapSetADJ.size()>0 || CHILDListIds.size()>0)
                IsChildDataExist=true;
            else
                IsChildDataExist=false;
        } 
        // Dispatcher List Query depending on clicked territory id
    }

    public PageReference AddTrtry_Atrbute() {
            SVMXC__Territory_Coverage__c NewTTA = new SVMXC__Territory_Coverage__c(RecordTypeId=CoverageRecType,SVMXC__Active__c=true);
            wrapperTTA Twrap = new wrapperTTA(NewTTA,false);
            wrapSetCOV.add(Twrap);
            return null;
    }

    public static List<String> getValuesFromString(String Values) 
    {
        List<String> ValueList = new List<String>();
        List<String> Options = new List<String> ();
        ValueList = Values.split(',');
        return ValueList;
    }

    //Save Territory Attributes
    public PageReference SaveTrtryAtrbute() {
        uncheckCheckbox();
        List<SVMXC__Territory_Coverage__c> TTAsaveList = new List<SVMXC__Territory_Coverage__c>();
        List<SVMXC__Territory_Coverage__c> MultiTTAsaveList = new List<SVMXC__Territory_Coverage__c>();
        activateBlockMsg('BOT');
        boolean IsValid=true;
        List<String> ValueList = new List<String>();
        ValueList=getValuesFromString(TTId);
        
        IsChildDataExist=false;
        for(wrapperTTA tta: wrapSetCOV){
            IsChildDataExist=true;
            TTAsaveList.add(tta.WSTTA);
        }
        //Sets territory for all records and creates multiple records if needed
        for(SVMXC__Territory_Coverage__c att: TTAsaveList){
            if(att.SVMXC__Territory__c==NULL){
                for(String s: ValueList){
                    if(att.SVMXC__Territory__c==NULL)
                        att.SVMXC__Territory__c=s;
                    else{
                        SVMXC__Territory_Coverage__c NewTTA = new SVMXC__Territory_Coverage__c(SVMXC__Active__c=true,SVMXC__value__c=att.SVMXC__value__c,SVMXC__Type__c=att.SVMXC__Type__c,SVMXC__Territory__c=s);
                        MultiTTAsaveList.add(NewTTA);
                    }
                }
            }
        }
        IsValid = OnSave_validation(TTAsaveList);
        try{
            if(IsValid==true){
                if(TTAsaveList.size()>0) {
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TTAsaveList, COMM_SecurityUtils.Access.Upsertable)){  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert TTAsaveList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
                    //upsert TTAsaveList;
                if(MultiTTAsaveList.size()>0) {
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(MultiTTAsaveList, COMM_SecurityUtils.Access.Createable)){     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert MultiTTAsaveList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
                    //insert MultiTTAsaveList;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG007(),''));
            }
        }
        catch (Exception ex){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        return null;
    }

    //Delete Territory attributes
    public PageReference DelTrtryAtrbute() {
        uncheckCheckbox();
        integer i;
        boolean ischecked=false;
        List<SVMXC__Territory_Coverage__c> TTAdelList = new List<SVMXC__Territory_Coverage__c>();
        integer listSize=wrapSetCOV.size();
        List<wrapperTTA> wrapSetCOVbuf = new List<wrapperTTA>();
        activateBlockMsg('BOT');
        for(wrapperTTA tta: wrapSetCOV){
            if(tta.Selected==false)
                wrapSetCOVbuf.add(tta);
            else{
                ischecked=true;
                if(tta.WSTTA.Id!=NULL)
                    TTAdelList.add(tta.WSTTA);
            }
        }
        wrapSetCOV.clear();
        if(wrapSetCOVbuf.size()>0){
            IsChildDataExist=true;
            wrapSetCOV.addAll(wrapSetCOVbuf);
        }
        else
            IsChildDataExist=false;
        try{
            if(TTAdelList.size()>0){
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Territory_Coverage__c' ) ) {  //SDL-SVMX-DELETE-FLS-ENFORCED              
                    delete TTAdelList;
                } else {                
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                    return null;
                }
            }
            if(listSize==0 || (TTAdelList.size()==0 && ischecked==false))
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG033(),''));
            else
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG008(),''));
        }
        catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        uncheckCheckbox();
        return null;
    }

    //Show territory on click of add territory
    public void showTerritory()    {
        ShowAddEdit=getTAG016();
        IsEditTT=false;
        AddTrtry.clear();
        isConfigureMode=true;
        displayZipPopup = false;
        displayCountryPopup = false;
        displayTTAttribute=false;
        displayTTPopup=true;
        if(SetingperHourCost!=null)
            AddTrtry.SVMXC__Per_Hour_Cost__c = SetingperHourCost;
        if(SettingperKmMileCost!=null)
        AddTrtry.SVMXC__Per_Mile_Cost__c = SettingperKmMileCost;
        if(SettingfixCost!=null)
            AddTrtry.SVMXC__Fixed_Cost__c = SettingfixCost;
        if(SettingavgSpeed!=null)
            AddTrtry.SVMXC__Average_Speed__c = SettingavgSpeed;
        if(SettingmaxDistance!=null)    
            AddTrtry.SVMXC__Max_Distance__c = SettingmaxDistance;
        if(SettingAverageDriveTime!=null)    
            AddTrtry.Average_Driving_Time__c = SettingAverageDriveTime;
        AddTrtry.SVMXC__Active__c = true ;
        
        if(TTId!='' && TTId!=NULL)
        AddTrtry.SVMXC__Parent_Territory__c=TTId;
    } 
    //Show territory on click of edit territory
    public void editTerritory(){
        ShowAddEdit=getTAG029();
        if(TTId!='' && TTId!=NULL){
            IsEditTT=true;
            AddTrtry.clear();
            isConfigureMode=true;
            displayZipPopup = false;
            displayCountryPopup = false;
            DisplayTopBlockLevelMessage=false;
            //displayTTAttribute=false;
            displayTTPopup=true;
            if(IsEditTT==true){
                EditTT=[Select Name, SVMXC__Break_Hours__c, Average_Driving_Time__c, SVMXC__Description__c, Territory_s_Business_Hours__c, SVMXC__Parent_Territory__c, SVMXC__Active__c, SVMXC__Territory_Code__c, SVMXC__Per_Mile_Cost__c, SVMXC__Per_Hour_Cost__c, SVMXC__Max_Hours__c, SVMXC__Max_Distance__c, SVMXC__Max_Daily_Hours__c, SVMXC__Fixed_Cost__c, SVMXC__Average_Speed__c, SVMXC__Mode_Of_Travel__c from SVMXC__Territory__c where Id=:TTId];
                AddTrtry.Name=EditTT.Name;
                AddTrtry.SVMXC__Territory_Code__c=EditTT.SVMXC__Territory_Code__c;
                AddTrtry.SVMXC__Parent_Territory__c=EditTT.SVMXC__Parent_Territory__c;
                AddTrtry.SVMXC__Description__c=EditTT.SVMXC__Description__c;
                AddTrtry.SVMXC__Active__c=EditTT.SVMXC__Active__c;
                AddTrtry.SVMXC__Per_Mile_Cost__c=EditTT.SVMXC__Per_Mile_Cost__c;
                AddTrtry.SVMXC__Per_Hour_Cost__c=EditTT.SVMXC__Per_Hour_Cost__c;
                AddTrtry.SVMXC__Fixed_Cost__c=EditTT.SVMXC__Fixed_Cost__c;
                AddTrtry.SVMXC__Average_Speed__c=EditTT.SVMXC__Average_Speed__c;
                AddTrtry.SVMXC__Max_Distance__c=EditTT.SVMXC__Max_Distance__c;
                AddTrtry.SVMXC__Max_Daily_Hours__c=EditTT.SVMXC__Max_Daily_Hours__c;
                AddTrtry.SVMXC__Max_Hours__c=EditTT.SVMXC__Max_Hours__c;
                AddTrtry.Territory_s_Business_Hours__c=EditTT.Territory_s_Business_Hours__c;
                AddTrtry.SVMXC__Break_Hours__c=EditTT.SVMXC__Break_Hours__c;
                AddTrtry.Average_Driving_Time__c=EditTT.Average_Driving_Time__c;
                AddTrtry.SVMXC__Mode_Of_Travel__c=EditTT.SVMXC__Mode_Of_Travel__c;  
            }
            else
            AddTrtry.SVMXC__Parent_Territory__c=TTId;
        }
        else{
            activateBlockMsg('TOP');
            DisplayTopBlockLevelMessage=true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG049(),''));
        }
    } 

    //Changes done for defect 007042.
    String getTerritoryName(Id terId){
        List<SVMXC__Territory__c> Territories = [Select Name From SVMXC__Territory__c where Name != null and  Id =: terId limit 1];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(Territories.size()>0)
            return Territories[0].Name;
        return null;
    }

    //Save territory
    public PageReference SaveTrtryPopUp() {
        boolean Isvalid=true;
        generateCHILDList(TTId); 
        try{
            if(AddTrtry.Name==NULL){
                    activateBlockMsg('POPUP');
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG011(),''));
                    return null;    
            }
            if(TTId!='' && AddTrtry.SVMXC__Parent_Territory__c==TTId){
                IsChildDataExist=true;
            }
            String TerrName = AddTrtry.Name;
            if(TerrName.contains('^')==true){
                    activateBlockMsg('POPUP');
                    AddTrtry.Name.addError(getTAG080());
                    return null;    
            }
            if(CHILDListIds.contains(AddTrtry.SVMXC__Parent_Territory__c)){
                    activateBlockMsg('POPUP');
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG077(),''));
                    return null;    
            }
            if(IsEditTT==true){
                if(checkAdjacency(AddTrtry.SVMXC__Parent_Territory__c,EditTT.Id)==true){
                        activateBlockMsg('POPUP');
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG065(),''));
                        return null;    
                }
                EditTT.Name=AddTrtry.Name;
                EditTT.SVMXC__Territory_Code__c=AddTrtry.SVMXC__Territory_Code__c;
                EditTT.SVMXC__Parent_Territory__c=AddTrtry.SVMXC__Parent_Territory__c;
                EditTT.SVMXC__Description__c=AddTrtry.SVMXC__Description__c;
                EditTT.SVMXC__Active__c=AddTrtry.SVMXC__Active__c;
                EditTT.SVMXC__Per_Mile_Cost__c=AddTrtry.SVMXC__Per_Mile_Cost__c;
                EditTT.SVMXC__Per_Hour_Cost__c=AddTrtry.SVMXC__Per_Hour_Cost__c;
                EditTT.SVMXC__Fixed_Cost__c=AddTrtry.SVMXC__Fixed_Cost__c;
                EditTT.SVMXC__Average_Speed__c=AddTrtry.SVMXC__Average_Speed__c;
                EditTT.SVMXC__Max_Distance__c=AddTrtry.SVMXC__Max_Distance__c;
                EditTT.SVMXC__Max_Daily_Hours__c=AddTrtry.SVMXC__Max_Daily_Hours__c;
                EditTT.SVMXC__Max_Hours__c=AddTrtry.SVMXC__Max_Hours__c;
                EditTT.Territory_s_Business_Hours__c=AddTrtry.Territory_s_Business_Hours__c;
                EditTT.SVMXC__Break_Hours__c=AddTrtry.SVMXC__Break_Hours__c;
                EditTT.Average_Driving_Time__c=AddTrtry.Average_Driving_Time__c;
                EditTT.SVMXC__Mode_Of_Travel__c=AddTrtry.SVMXC__Mode_Of_Travel__c;
               //Changes done for defect 007042.
                if(EditTT.SVMXC__Parent_Territory__c!=TTId && EditTT.Name!=getTerritoryName(EditTT.SVMXC__Parent_Territory__c)) {
                    //update EditTT;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(EditTT, COMM_SecurityUtils.Access.Updateable)){       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update EditTT;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                } else {
                    Isvalid=false;
                }
            }
            else{
                SVMXC__Territory__c TempTrr= new SVMXC__Territory__c();
                TempTrr.Name=AddTrtry.Name;
                TempTrr.SVMXC__Territory_Code__c=AddTrtry.SVMXC__Territory_Code__c;
                TempTrr.SVMXC__Parent_Territory__c=AddTrtry.SVMXC__Parent_Territory__c;
                TempTrr.SVMXC__Description__c=AddTrtry.SVMXC__Description__c;
                TempTrr.SVMXC__Active__c=AddTrtry.SVMXC__Active__c;
                TempTrr.SVMXC__Per_Mile_Cost__c=AddTrtry.SVMXC__Per_Mile_Cost__c;
                TempTrr.SVMXC__Per_Hour_Cost__c=AddTrtry.SVMXC__Per_Hour_Cost__c;
                TempTrr.SVMXC__Fixed_Cost__c=AddTrtry.SVMXC__Fixed_Cost__c;
                TempTrr.SVMXC__Average_Speed__c=AddTrtry.SVMXC__Average_Speed__c;
                TempTrr.SVMXC__Max_Distance__c=AddTrtry.SVMXC__Max_Distance__c;
                TempTrr.SVMXC__Max_Daily_Hours__c=AddTrtry.SVMXC__Max_Daily_Hours__c;
                TempTrr.SVMXC__Max_Hours__c=AddTrtry.SVMXC__Max_Hours__c;
                TempTrr.Territory_s_Business_Hours__c=AddTrtry.Territory_s_Business_Hours__c;
                TempTrr.SVMXC__Break_Hours__c=AddTrtry.SVMXC__Break_Hours__c;
                TempTrr.Average_Driving_Time__c=AddTrtry.Average_Driving_Time__c;
                TempTrr.SVMXC__Mode_Of_Travel__c=AddTrtry.SVMXC__Mode_Of_Travel__c;
                //Changes done for defect 007042
                //Changes done for defect 009822/009832.
                if(TempTrr.Name!=getTerritoryName(TempTrr.SVMXC__Parent_Territory__c)){
                    //insert TempTrr;
                    // -CRUD
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TempTrr, COMM_SecurityUtils.Access.Createable ) ) { //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert TempTrr;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }   
                    TTId = TempTrr.Id;
                }
                else
                Isvalid=false;
            }
            if(Isvalid==true){
                ClosePopUp();
                activateBlockMsg('TOP');
                if(TTId!='')
                displayTTAttribute=true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG007(),''));
            }
            else{
                activateBlockMsg('POPUP');
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG052(),''));
            }
        }
        catch (Exception ex){
            activateBlockMsg('POPUP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        return null;
    }

    public PageReference hideTerritoryAtt() {
        TTId='';
        displayTTAttribute=false;
        return null;
    }

    public Boolean checkAdjacency(String T1, String T2){
        set<String> listTrr = new set<String>();
        listTrr.add(T1);
        listTrr.add(T2);
        Boolean IsAdjacent=false;
        List<SVMXC__Territory_Coverage__c> LSTCHKADJ = new List<SVMXC__Territory_Coverage__c>();
        LSTCHKADJ=[SELECT id,SVMXC__Adjacent_Territory__c,SVMXC__Territory__c from SVMXC__Territory_Coverage__c where SVMXC__Record_Type_Name__c='Adjacency' and SVMXC__Adjacent_Territory__c IN :listTrr];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        for(SVMXC__Territory_Coverage__c tc: LSTCHKADJ){
            if((tc.SVMXC__Adjacent_Territory__c==T1 && tc.SVMXC__Territory__c==T2)|| (tc.SVMXC__Adjacent_Territory__c==T2 && tc.SVMXC__Territory__c==T1))
            IsAdjacent=true;
        }
        return IsAdjacent;
    }

    //Changes done for defect 007042.
    //Recursive function generate list of childs for the selected territory 
    public void generateCHILDList1(String Pid){
       try{
            set<id> childs=mParrent.get(Pid);
            if(childs != NULL){
                for(id cID: childs){
                    CHILDListIds.add(cID);
                    generateCHILDList1(cID);
                }
            }
        }catch(Exception ex){
            activateBlockMsg('POPUP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        //Changes done for defect 009822/009832.
        //mParrent.clear();
    }

    public void generateCHILDList(String Pid){
        if(Pid != null && Pid != ''){
            mParrent.clear();
            //Changes done for defect 009822/009832.
            for(SVMXC__Territory__c objTerritory: [Select Id, Name, SVMXC__Parent_Territory__c, SVMXC__Territory_Code__c From SVMXC__Territory__c where Name != null and SVMXC__Parent_Territory__c != null  order by LastModifiedDate])        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                addToMparrent(objTerritory.SVMXC__Parent_Territory__c, objTerritory.Id);
            
            CHILDListIds.clear();
            generateCHILDList1(Pid);
            mParrent.clear();
        }
    }

    public PageReference DelTerritory() {
        if(TTId!='' && TTId!=NULL){
            generateCHILDList(TTId); 
            CHILDListIds.add(TTId);
            //Delete Territory attributes           
            
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Territory_Coverage__c' ) ) {    //SDL-SVMX-DELETE-FLS-ENFORCED
                
                List<SVMXC__Territory_Coverage__c> TempTrrattr= new List<SVMXC__Territory_Coverage__c> ();
                TempTrrattr = [SELECT id from SVMXC__Territory_Coverage__c where SVMXC__Territory__c IN :CHILDListIds];
                delete TempTrrattr;
                TempTrrattr = [SELECT id from SVMXC__Territory_Coverage__c where SVMXC__Record_Type_Name__c='Adjacency' and SVMXC__Adjacent_Territory__c IN :CHILDListIds];
                delete TempTrrattr;
            } else {
                activateBlockMsg('TOP');
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return null;
            }
            
            // Delete Dispatcher Access records of territories which has to be deleted (to handle Defect- 004342).
            List<SVMXC__Dispatcher_Access__c> lstDispatcherAccessToDel = new List<SVMXC__Dispatcher_Access__c>();
            if(CHILDListIds != null && CHILDListIds.size() > 0)
                lstDispatcherAccessToDel = [select Id, Name, SVMXC__Select__c, SVMXC__Territory__c, SVMXC__Dispatcher__c from SVMXC__Dispatcher_Access__c where SVMXC__Territory__c =: CHILDListIds];
            If(lstDispatcherAccessToDel != null && lstDispatcherAccessToDel.size() > 0) {
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Dispatcher_Access__c')){      //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete lstDispatcherAccessToDel;
                    }else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }
            }
                
            
            //Delete Territories
            
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Territory__c' ) ) {     //SDL-SVMX-DELETE-FLS-ENFORCED
                delete [SELECT id from SVMXC__Territory__c where id IN :CHILDListIds];
            } else {
                activateBlockMsg('TOP');
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return null;
            }
            
            //Changes done for defect 009822/009832.
            //TTId='';
            if(Tid != null && Tid != '' && Tid != TTId){
                TTId = Tid;
            }
            else{
                TTId='';
                showOnlySel='';
            }
            
            //Changes done for defect 007042.
            //onLoad();
            displayTTAttribute=false;
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG008(),''));
        }
        else{
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG049(),''));
        }
        return null;
    }

    public void showZipPopup(){
        ZipStart='';
        ZipEnd='';
        isConfigureMode=true;
        displayZipPopup = true;
        displayCountryPopup = false;
    } 

    public void showCountryPopup(){
        isConfigureMode=true;
        set<String> TACountry = new set<String>();
        List<SVMXC__Territory_Coverage__c> TCountry = new List<SVMXC__Territory_Coverage__c>();
        AvailCountry.clear();
        T1Country.clear();
        SelectedCountry.clear();
        T2Country.clear();
        
        for(wrapperTTA w:wrapSetCOV){
            TACountry.add(w.WSTTA.SVMXC__value__c);
        }
        for(String c: Countries){
            if(TACountry.contains(c)==false){
                AvailCountry.add(new SelectOption(c,c));
                T1Country.add(c);
            }
            else{
                SelectedCountry.add(new SelectOption(c,c));
                T2Country.add(c);
            }
        }
        displayZipPopup = false;
        displayCountryPopup = true;
        AvailCountry=sortingSelectAvailCOption(AvailCountry);
        //SelectedCountry=sortingSelectSelectedCOption(SelectedCountry);
    } 

    public PageReference SaveCountryPopUp() {
        uncheckCheckbox();
        List<SVMXC__Territory_Coverage__c> DELCountry = new List<SVMXC__Territory_Coverage__c>();
        DELCountry = [Select SVMXC__value__c from SVMXC__Territory_Coverage__c where SVMXC__Territory__c = :TTId and SVMXC__Type__c='Country' and SVMXC__Record_Type_Name__c='Coverage'];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA   
        if(DELCountry.size()>0) {
            if( COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Territory_Coverage__c') ){       //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
               delete DELCountry;
            } else {
               throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
            //delete DELCountry;
        
        List<wrapperTTA> wrapSetCOVbuf = new List<wrapperTTA>();
        for(wrapperTTA tta: wrapSetCOV){
            if(tta.WSTTA.SVMXC__Type__c!='Country')
                wrapSetCOVbuf.add(tta);
        }
        wrapSetCOV.clear();
        wrapSetCOV.addAll(wrapSetCOVbuf);
        
        List<SVMXC__Territory_Coverage__c> TTAsaveList = new List<SVMXC__Territory_Coverage__c>();
        system.debug('TEST PB2s:'+T2Country+TTId);
        if(T2Country!=NULL){
            for(String T2c: T2Country){
            SVMXC__Territory_Coverage__c NewTTA = new SVMXC__Territory_Coverage__c(SVMXC__Territory__c=TTId,SVMXC__Type__c='Country',SVMXC__value__c=T2c,SVMXC__Active__c=true,RecordTypeId=CoverageRecType);
            TTAsaveList.add(NewTTA);
            wrapperTTA Twrap = new wrapperTTA(NewTTA,false);
            wrapSetCOV.add(Twrap);
            }
        }
        if(TTAsaveList.size()>0){
            //insert TTAsaveList;
            // -CRUD
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( TTAsaveList, COMM_SecurityUtils.Access.Createable ) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                insert TTAsaveList;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
            }   
            activateBlockMsg('POPUP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG007(),''));
            ClosePopUp();
        }
        else{
            activateBlockMsg('POPUP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG058(),''));
        }
        return null;
    }

    public void ClosePopUp2(){
        if(TTId!='')
            loadTerritory();
        ClosePopUp();
    }

    public void ClosePopUp(){
        isConfigureMode=false;
        displayZipPopup = false;
        displayCountryPopup = false;
        displayTTPopup=false;
        DisplayPPLevelMessage=false;
        DisplayADJTTLevelMessage=false;
        DisplaySEARCHTTLevelMessage=false;
        DisplayTopBlockLevelMessage=false;
    }

    public PageReference SaveZipPopUp() {
        uncheckCheckbox();
        List<SVMXC__Territory_Coverage__c> TTAsaveList = new List<SVMXC__Territory_Coverage__c>();
        Boolean error = false;
        Integer StartCode;
        Integer EndCode;
        Integer i;
        String StartStr='',EndStr='';
        String ErrMsg;
        String NewZipCodes;
        Boolean PatternStart=false;
        Boolean PatternEnds=false;
        Integer St_Start,St_End;
        Boolean SetZip = false;
        
        //Identify the Count Patern
        List<String> FPStart = new List<String>();
        List<String> FPEnd = new List<String>();
        set<String> AvailZips = new set<String>();
        FPStart=ZipStart.Split('',0);
        FPEnd=ZipEnd.Split('',0);

        for(wrapperTTA ta:wrapSetCOV)
            AvailZips.add(ta.WSTTA.SVMXC__value__c);  
        
        if(ZipStart=='' || ZipEnd=='')
            ErrMsg=getTAG034();

        //If both strings are same insert 1 record
        else if((ZipStart==ZipEnd ||((ZipStart!=NULL)&&(ZipEnd==NULL))) && ErrMsg==NULL){
            SetZip=true;
            if(AvailZips.contains(ZipStart)==false){
                SVMXC__Territory_Coverage__c NewTTA = new SVMXC__Territory_Coverage__c(RecordTypeId=CoverageRecType,SVMXC__Territory__c=TTId,SVMXC__Type__c='Zip',SVMXC__value__c=ZipStart,SVMXC__Active__c=true);
                TTAsaveList.add(NewTTA);
                wrapperTTA Twrap = new wrapperTTA(NewTTA,false);
                wrapSetCOV.add(Twrap);
            }
        }

        else if(SetZip==false && ErrMsg==NULL){
            try{
                //Get the length of string
                Integer ZipStartLength=ZipStart.length();
                StartCode=integer.valueOf(ZipStart);
                EndCode=integer.valueOf(ZipEnd);
                
                if(St_End<FPStart.size()-1)
                    EndStr=ZipStart.substring(St_End,FPStart.size()-1);
                
                if(StartCode<EndCode){
                    if(EndCode>(StartCode+100)){
                        ErrMsg=getTAG069();
                    }
                    else{
                        for(i=StartCode;i<=EndCode;i++){
                                NewZipCodes=String.valueof(i);
                                if(NewZipCodes.length()<ZipStartLength)
                                NewZipCodes=doZeroPadding(NewZipCodes,ZipStartLength);
                                if(AvailZips.contains(NewZipCodes)==false){
                                SVMXC__Territory_Coverage__c NewTTA = new SVMXC__Territory_Coverage__c(RecordTypeId=CoverageRecType,SVMXC__Territory__c=TTId,SVMXC__Type__c='Zip',SVMXC__value__c=NewZipCodes,SVMXC__Active__c=true);
                                TTAsaveList.add(NewTTA);
                                wrapperTTA Twrap = new wrapperTTA(NewTTA,false);
                                wrapSetCOV.add(Twrap);
                                }
                        }
                        SetZip=true;
                    }
                }
                else
                    ErrMsg=getTAG036();
            }
            catch (Exception ex){
                ErrMsg=getTAG057();
            }
        }
        if(TTAsaveList.size()>0 && SetZip==true && ErrMsg==NULL){
            //insert TTAsaveList;
            activateBlockMsg('TOP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG007(),''));
        }
        if(ErrMsg!=NULL){
            activateBlockMsg('POPUP');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ErrMsg,''));
        }
        else
            ClosePopUp();
        return null;
    }

    public string doZeroPadding(String s, Integer i){
        Integer ZeroCount=i-s.length();
        String ZeroString='';
        for(Integer j=0;j<ZeroCount;j++)
            ZeroString+='0';
        return ZeroString+s;
    }
    public boolean IsNumber(String s){
        Integer i;
        try{
            i=integer.valueOf(s);
            return true;
        }
        catch (Exception ex){
            return false;
        }
    }

    public boolean OnSave_validation(List<SVMXC__Territory_Coverage__c> TTAsaveList)
    {
        Boolean Isvalid=true;
        set<String> strCmp = new set<String>();
        String str;
        for(SVMXC__Territory_Coverage__c tta: TTAsaveList){
            str = tta.SVMXC__Type__c+' '+tta.SVMXC__value__c;
            if(tta.SVMXC__Type__c==NULL){
                Isvalid=false;
                tta.SVMXC__Type__c.addError(getTAG013());
            }
            if(tta.SVMXC__value__c==NULL){
                Isvalid=false;
                tta.SVMXC__value__c.addError(getTAG014());
            }
            if(strCmp.contains(str)){
                Isvalid=false;
                tta.SVMXC__Type__c.addError(getTAG051());
                tta.SVMXC__value__c.addError(getTAG051());
            }
            strCmp.add(str);
        }
        if(TTAsaveList.size()==0){
            Isvalid=false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG050(),''));
        }
        return IsValid;
    }

    //Changes done for defect 007042.
    map<string,string> mapIdChildTree =new map<string,string>();
    void Tree_frm_Parent(String pID,String tree){
        if(mParrent.get(pID) != NULL){
            for(id cID: mParrent.get(pID))
                Tree_frm_Parent(cID,tree+':'+cID);
        }
        else if(IsTrrAvail && tree.contains(TTId) && showOnlySel =='1'){
            mapIdChildTree.clear();
            mapIdChildTree.put(TTId,tree);
        }
        else mapIdChildTree.put(pID,tree);
    }

    //========================================= Function : Handles Profiles =============================================//
    public List<SelectOption> getAvailCountry(){
        return AvailCountry;
    }  
    //========================================= Function : Handles Profiles =============================================//
    public List<SelectOption> getSelectedCountry(){
        return SelectedCountry;
    }  

    /**********************************************************************************************************************/
    public PageReference onAddCountry(){
    List<Integer> selectedLines = new List<Integer>();
        Integer i;
        system.debug('TEST PB:'+Country+T1Country+SelectedCountry+T2Country+AvailCountry+T1Country);
        if(Country!=NULL){
            for(String fs: Country){
                for(i = 0; i < T1Country.size();i++){
                    if(fs == T1Country[i]){
                        selectedLines.add(i);
                        SelectedCountry.add(AvailCountry.get(i));
                        T2Country.add(T1Country[i]);
                    }
                }
            }
            for (i=selectedLines.size()-1;i>=0;i--){
                AvailCountry.remove(selectedLines.get(i));
                T1Country.remove(selectedLines.get(i));
            }
            //SelectedCountry=sortingSelectSelectedCOption(SelectedCountry);
        }
        return null;
    }
    /*******************************************************************************************************/
    public PageReference onRemCountry(){
        List<Integer> selectedLines = new List<Integer>();
        Integer i;
        if(Country!=NULL){
            for(String ps: SCountry){
                for(i = 0; i < T2Country.size();i++){
                         if(ps == T2Country[i]){
                            selectedLines.add(i);
                             AvailCountry.add(SelectedCountry.get(i));
                             T1Country.add(T2Country[i]);
                         }  
                }
            }
            for (i=selectedLines.size()-1;i>=0;i--){
                SelectedCountry.remove(selectedLines.get(i));
                T2Country.remove(selectedLines.get(i));
            }
            AvailCountry=sortingSelectAvailCOption(AvailCountry);
        }
        return null;
    }

    //----------------------------------Sorting Function-----------------------------------------------
    public List<SelectOption> sortingSelectAvailCOption(List<SelectOption> so){
        /*SelectOption tempObj; 
        String tempLst;              
        Integer size = so.size();
        Integer i,j;
        for(i=0;i<size;i++){
            for(j=i+1;j<size;j++){
            Integer result=so[i].getLabel().compareTo(so[j].getLabel());
            if((so[i].getLabel().toUpperCase().compareTo(so[j].getLabel().toUpperCase()))>0){
                tempObj = so[j];
                so[j] = so[i];
                so[i] = tempObj;
                tempLst = T1Country[j];
                T1Country[j] = T1Country[i];
                T1Country[i] = tempLst;
            }
            }
        } */
        so.sort();
        return so;
    }
    //----------------------------------Sorting Function-----------------------------------------------
    public List<SelectOption> sortingSelectSelectedCOption(List<SelectOption> so){
        /*SelectOption tempObj; 
        String tempLst;              
        Integer size = so.size();
        Integer i,j;
        for(i=0;i<size;i++){
            for(j=i+1;j<size;j++){
                Integer result=so[i].getLabel().compareTo(so[j].getLabel());
                if((so[i].getLabel().toUpperCase().compareTo(so[j].getLabel().toUpperCase()))>0){
                    tempObj = so[j];
                    so[j] = so[i];
                    so[i] = tempObj;
                    tempLst = T2Country[j];
                    T2Country[j] = T2Country[i];
                    T2Country[i] = tempLst;
                }
            }
        }*/
        so.sort();
        return so;
    }

    //======================================== Action "Back To Setup Home" ===================================================//
    public PageReference GoSetupHome(){
      String url = '';
      //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
      //if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
      if(svmxSettingList.containsKey('SET001') == true){
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url =svmxSettingList.get('SET001');
        }
      }
      //Changes done by Nidhi ends here
      PageReference HomePage = new PageReference(url);
      HomePage.setRedirect(true);
      return HomePage; 
    }
    //Adjacent Territory Actions
    public PageReference AddAdjTrtry() {
        uncheckCheckbox();
        SVMXC__Territory_Coverage__c NewTTA = new SVMXC__Territory_Coverage__c(RecordTypeId=AdjacencyRecType,SVMXC__Active__c=true);
        wrapperTTA Twrap = new wrapperTTA(NewTTA,false);
        wrapSetADJ.add(Twrap);
        return null;
    }

    public PageReference DelAdjTrtry() {
        uncheckCheckbox();
        List<SVMXC__Territory_Coverage__c> TTAdelList = new List<SVMXC__Territory_Coverage__c>();
        List<SVMXC__Territory_Coverage__c> TTAdelListBDIR = new List<SVMXC__Territory_Coverage__c>();
        integer listSize=wrapSetADJ.size();
        boolean ischecked=false;
        List<wrapperTTA> wrapSetADJbuf = new List<wrapperTTA>();
        activateBlockMsg('ADJTT');
        for(wrapperTTA tta: wrapSetADJ){
            if(tta.Selected==false)
                wrapSetADJbuf.add(tta);
            else{
                ischecked=true;
                if(tta.WSTTA.Id!=NULL){
                    TTAdelList.add(tta.WSTTA);
                    if(bidir==true)
                    {
                        TTAdelListBDIR=[SELECT id from SVMXC__Territory_Coverage__c where SVMXC__Record_Type_Name__c='Adjacency' and SVMXC__Adjacent_Territory__c=:TTId and SVMXC__Territory__c=:tta.WSTTA.SVMXC__Adjacent_Territory__c];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        TTAdelList.addall(TTAdelListBDIR);
                    }
                }
            }
        }
        wrapSetADJ.clear();
        if(wrapSetADJbuf.size()>0){
            IsChildDataExist=true;
            wrapSetADJ.addAll(wrapSetADJbuf);
        }
        else
            IsChildDataExist=false;
        try{
                if(TTAdelList.size()>0){
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Territory_Coverage__c' ) ) {        //SDL-SVMX-DELETE-FLS-ENFORCED      
                        delete TTAdelList;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }   
                }
                if(listSize==0 || (TTAdelList.size()==0 && ischecked==false))
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG033(),''));
                else
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG008(),''));
        }
        catch (Exception ex){
        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        return null;
    }

    public boolean checkAdjcency(String TT, String ATT){
        List<SVMXC__Territory_Coverage__c> TAdj = new List<SVMXC__Territory_Coverage__c>();
        TAdj = [Select id from SVMXC__Territory_Coverage__c where SVMXC__Record_Type_Name__c='Adjacency' and SVMXC__Adjacent_Territory__c=:ATT and SVMXC__Territory__c=:TT];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('TEST1'+TAdj);
        if(TAdj.size()>0)
            return true;
        else
            return false;
    }
    public PageReference SaveAdjTrtry() {
        uncheckCheckbox();
        List<SVMXC__Territory_Coverage__c> TTAUpdateList = new List<SVMXC__Territory_Coverage__c>();
        List<SVMXC__Territory_Coverage__c> TTAInsertOnlyList = new List<SVMXC__Territory_Coverage__c>();
        integer listSize=wrapSetADJ.size();
        Boolean IsValid=true;
        set<String> SelectedSets = new set<String>();
        set<id> ChildParentSets = new set<id>();
        List<wrapperTTA> wrapSetADJbuf = new List<wrapperTTA>();
        List<SVMXC__Territory__c> TAdj = new List<SVMXC__Territory__c>();
        TAdj = [Select id,SVMXC__Parent_Territory__c from SVMXC__Territory__c where SVMXC__Parent_Territory__c=:TTID or Id=:TTID];
        for(SVMXC__Territory__c t: TAdj){
            if(t.Id==TTID)
            ChildParentSets.add(String.valueof(t.SVMXC__Parent_Territory__c));
            else
            ChildParentSets.add(String.valueof(t.id));
        }
        activateBlockMsg('ADJTT');
        //Validating whether the territories are unique
        //making a list to upsert
        for(wrapperTTA tta: wrapSetADJ){
            if(SelectedSets.contains(tta.WSTTA.SVMXC__Adjacent_Territory__c)==true || tta.WSTTA.SVMXC__Adjacent_Territory__c==NULL){
                if(tta.WSTTA.SVMXC__Adjacent_Territory__c!=NULL)
                    tta.WSTTA.SVMXC__Adjacent_Territory__c.addError(getTAG074()); 
                else
                    tta.WSTTA.SVMXC__Adjacent_Territory__c.addError(getTAG061()); 
                IsValid=false;
            }
            if(tta.WSTTA.SVMXC__Adjacent_Territory__c==TTID && IsValid==true){
                tta.WSTTA.SVMXC__Adjacent_Territory__c.addError(getTAG062()); 
                IsValid=false;
            }
            if(ChildParentSets.contains(tta.getWSTTA().SVMXC__Adjacent_Territory__c)==true  && IsValid==true){
                tta.WSTTA.SVMXC__Adjacent_Territory__c.addError(getTAG065()); 
                IsValid=false;
            }
            system.debug('TESTPB1:'+ChildParentSets+tta.WSTTA.SVMXC__Adjacent_Territory__c);
            SelectedSets.add(tta.WSTTA.SVMXC__Adjacent_Territory__c);
            tta.WSTTA.SVMXC__Territory__c = TTId;
            TTAUpdateList.add(tta.WSTTA);
            if(IsValid==true && bidir==true && checkAdjcency(tta.WSTTA.SVMXC__Adjacent_Territory__c,TTID)==false){
                SVMXC__Territory_Coverage__c NewTTA = new SVMXC__Territory_Coverage__c(RecordTypeId=AdjacencyRecType,SVMXC__Active__c=true,SVMXC__Territory__c=tta.WSTTA.SVMXC__Adjacent_Territory__c,SVMXC__Adjacent_Territory__c=TTId);
                TTAInsertOnlyList.add(NewTTA);
            }
        }
        if(IsValid==true){
            try{
                if(TTAUpdateList.size()>0) {
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TTAUpdateList, COMM_SecurityUtils.Access.Upsertable)){        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        upsert TTAUpdateList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
                    //upsert TTAUpdateList;
                if(TTAInsertOnlyList.size()>0) {
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(TTAInsertOnlyList, COMM_SecurityUtils.Access.Createable)){    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert TTAInsertOnlyList;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
                    //insert TTAInsertOnlyList;
                if(listSize==0)
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG028(),''));
                else
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG007(),''));
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
            }
        }
        for(SVMXC__Territory_Coverage__c tta:TTAUpdateList){
            wrapperTTA Twrap = new wrapperTTA(tta,false);
            wrapSetADJbuf.add(Twrap);
        }
        wrapSetADJ.clear();
        if(wrapSetADJbuf.size()>0){
            IsChildDataExist=true;
            wrapSetADJ.addAll(wrapSetADJbuf);
        }
        else
            IsChildDataExist=false;
            DisplayTopBlockLevelMessage=false;
        return null;
    }

    //Add selected list of territory
    public PageReference AddSelectedTrtry() {
        Boolean IsValid=false;
        List<wrapperTT> wrapSetbuf = new List<wrapperTT>();
        set<Id> AvailADJLIst = new set<Id>();
        for(wrapperTTA wb:wrapSetADJ){
            AvailADJLIst.add(String.valueof(wb.WSTTA.SVMXC__Adjacent_Territory__c));
        }
        if(wrapSearchRes.size()>0){
            for(wrapperTT tts:wrapSearchRes){
                SVMXC__Territory_Coverage__c NewTTA = new SVMXC__Territory_Coverage__c(RecordTypeId=AdjacencyRecType,SVMXC__Active__c=true,SVMXC__Adjacent_Territory__c=tts.WSTTA.Id);
                wrapperTTA Twrap = new wrapperTTA(NewTTA,false);
                if(tts.Selected==true){
                    IsValid=true;
                    system.debug('TESTPB3:'+AvailADJLIst+string.valueof(NewTTA.SVMXC__Adjacent_Territory__c));
                    if(AvailADJLIst.contains(string.valueof(NewTTA.SVMXC__Adjacent_Territory__c).substring(0, 15))==false)
                        wrapSetADJ.add(Twrap);
                }
                else
                    wrapSetbuf.add(tts);
            }
            wrapSearchRes.clear();
            wrapSearchRes=wrapSetbuf;
        }
        if(IsValid==false){
            activateBlockMsg('SEARCHTT');
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG063(),''));
        }
        return NULL;
    }

    public String CheckNull(String s){
        if(s==NULL)
            return '';
        else
            return s;
    }

    public void uncheckCheckbox(){
        CheckAllLines=false;
        CheckAlladjLines=false;
    }
    //Message visibilities
    public void activateBlockMsg(String s){
        deActivateAllMsg();
        if(s=='POPUP')  
        DisplayPPLevelMessage=true;
        else if(s=='TOP')       
        DisplayTopBlockLevelMessage=true;
        else if(s=='BOT')       
        DisplayBotBlockLevelMessage=true;
        else if(s=='ADJTT')
        DisplayADJTTLevelMessage=true;
        else if(s=='SEARCHTT')
        DisplaySEARCHTTLevelMessage=true;
    }
    public void deActivateAllMsg(){
        DisplayPPLevelMessage=false;
        DisplayADJTTLevelMessage=false;
        DisplayTopBlockLevelMessage=false;
        DisplayBotBlockLevelMessage=false;
        DisplaySEARCHTTLevelMessage=false;
    }
    
    //Changes done for defect 009822/009832.
    public String SpecialCharParser(String str){
        if(str != null)
            return str.replace('&','&#38;').replace('^','&#94;').replace('<','&#60;').replace('>','&#62;').replace('\n',' ');
       return '';     
    }
    
    //======================================== Set true to display blocklevel messges ===================================================//
    public Boolean getDisplayTopBlockLevelMessage(){ return DisplayTopBlockLevelMessage; }
    public Boolean getDisplayBotBlockLevelMessage(){ return DisplayBotBlockLevelMessage; }
    public Boolean getDisplayPPLevelMessage(){ return DisplayPPLevelMessage; }   
    public Boolean getDisplayADJTTLevelMessage(){ return DisplayADJTTLevelMessage; } 
    public Boolean getDisplaySEARCHTTLevelMessage(){ return DisplaySEARCHTTLevelMessage; } 
    public Boolean getisConfigureMode(){ return isConfigureMode; }
    public Boolean getdisplayZipPopup(){ return displayZipPopup; }
    public Boolean getdisplayCountryPopup(){ return displayCountryPopup; }    
    public Boolean getdisplayTTPopup(){ return displayTTPopup; }
    public Boolean getdisplayTTAttribute(){ return displayTTAttribute; }

     
    // others required in dispatcher 
    public integer UsrCounter = 0;
    public boolean DelDispCountRec = false;
    Map<String,integer> DispMap = new Map<String,integer>();
    list<string> ExpKWrdList = new list<string>();
    public boolean getDelDispCountRec(){  return DelDispCountRec;}
    public void setDelDispCountRec(boolean b){this.DelDispCountRec =b;}
    
    // query of dispatcherlst was here earlier
    public List<SVMXC__Dispatcher_Access__c> getDsptchrList(){
        return DsptchrList;
    }
    
    Boolean CheckAllDisp = false;
    public Boolean getCheckAllDisp() {return CheckAllDisp;}
    public void setCheckAllDisp(Boolean chkAll){CheckAllDisp=chkAll;}
    
    Boolean ChildTabs = false;
    public boolean getChildTabs(){ return ChildTabs;}   
    public void setChildTabs(boolean f){this.ChildTabs=f;}
    
    public List<User> UserList = new List<User>();
    public List<User> getUserList(){
        return UserList;
    }
     
        /* controller dispatcher tags */
    public String getTAG081() {return system.label.SORG002_TAG081;} //Please enter a keyword first'
    public String getTAG082() {return system.label.SORG002_TAG082;} //'No user records found matching the keyword'
    public String getTAG083() {return system.label.SORG002_TAG083;} //'Please select at least one record first'
    public String getTAG084() {return system.label.SORG002_TAG084;} //'Please select a user'
    public String getTAG085() {return system.label.SORG002_TAG085;}// 'Duplicate Records'  
    public String getTAG086() {return system.label.SORG002_TAG086;}// 'Please create at least one dispatcher record to save'
    public String getTAG087() {return system.label.SORG002_TAG087;}// 'Please select at least one record to delete'
      /* page dispatcher tags */
    public String getTAG088() {return system.label.SORG002_TAG088;}// 'Add Dispatcher'
    public String getTAG089() {return system.label.SORG002_TAG089;}// 'Delete'
    public String getTAG090() {return system.label.SORG002_TAG090;}// 'Save'
    public String getTAG091() {return system.label.SORG002_TAG091;}// 'Dispatcher Name'
    public String getTAG092() {return system.label.SORG002_TAG092;}// 'Processing.....'
    public String getTAG093() {return system.label.SORG002_TAG093;}// 'Search Product by entering a keyword'
    public String getTAG094() {return system.label.SORG002_TAG094;}// 'Go!'
    public String getTAG095() {return system.label.SORG002_TAG095;}// 'Add Selected'
    public String getTAG096() {return system.label.SORG002_TAG096;}// 'Cancel'
    public String getTAG097() {return system.label.SORG002_TAG097;}// 'Select'
    public String getTAG098() {return system.label.SORG002_TAG098;}// 'User Name'
    public String getTAG099() {return system.label.SORG002_TAG099;}// 'Dispatcher'
    public String getTAG100() {return system.label.SORG002_TAG100;}// 'Are you sure to proceed?'
    
        //Dspatcher Search Functionality
    public string DispKywrd;
    public boolean SaveDispCountRec=true;
    public boolean SaveUsrListSize = false;
    public boolean UserExist = false;
    public boolean AddUserCountRec = false;
    public string getDispKywrd(){return DispKywrd; }
    public void setDispKywrd(string k){ this.DispKywrd=k;  }
    
    public void SVMX_DispatchSearch(){
        ChildTabs = true;                  
        String DispStrng;       
        UserList.clear();     
        DispStrng='Select Id,Name,SVMXC__Select__c From User';    //change made
        string strKeyword;
        if(DispKywrd.contains('\''))
            strKeyword = String.escapeSingleQuotes(DispKywrd.replaceAll('\'', '\\\''));
        else
            strKeyword = String.escapeSingleQuotes(DispKywrd);
        DispStrng = DispStrng+' where Name like \'%'+strKeyword+'%\'';   
        
        if(DispKywrd==null || DispKywrd==''){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG081()));
        }
        else{
            UserList=Database.query(DispStrng);
            if(UserList.size()<=0){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG082()));
            }          
        }          
    } 
    
        /*********Dispatcher Functionality Added******/
    
    public void UserSearchCancel(){
        UserList.clear();
        DispKywrd='';
    }
    
    public boolean getSaveDispCountRec(){return SaveDispCountRec;}
    public void setSaveDispCountRec(boolean b){this.SaveDispCountRec =b;}
    public boolean getSaveUsrListSize(){return SaveUsrListSize;}
    public void setSaveUsrListSize(boolean b){this.SaveUsrListSize =b;}
    public boolean getAddUserCountRec(){return AddUserCountRec;}
    public void setAddUserCountRec(boolean b){this.AddUserCountRec =b;}
    public boolean getUserExist(){ return UserExist;}
    public void setUserExist(boolean b){this.UserExist =b;}
    
    public void SVMX_AddDisptacher(){                
        uncheckCheckbox();
        SVMXC__Dispatcher_Access__c dspch = new SVMXC__Dispatcher_Access__c();                
        if(TTId!=null && TTId!=''){         
            //Changes done for defect 007042.
            if(getTerritoryName(TTId)!=null){
                dspch.SVMXC__Territory__c=TTId;
            }
        }
        for(integer i=0;i<DsptchrList.size();i++){
            DsptchrList[i].SVMXC__Select__c= false;
        }
        DsptchrList.add(dspch);                     
    }
   
    public void SVMX_AddUsertoDispatch(){
        uncheckCheckbox();
        ChildTabs = true;
        AddUserCountRec = false;   
        for(integer i=0;i<UserList.size();i++){
            if(UserList[i].SVMXC__Select__c){              
                AddUserCountRec = true;
                for(integer j=0;j<DsptchrList.size();j++){                  
                    if(UserList[i].Id==DsptchrList[j].SVMXC__Dispatcher__c)
                        UserExist = true;
                    }
                    if(!UserExist){             
                        UserList[i].SVMXC__Select__c=false;
                        SVMXC__Dispatcher_Access__c Disp = new SVMXC__Dispatcher_Access__c();     
                        Disp.SVMXC__Dispatcher__c = UserList[i].Id;        
                        //Changes done for defect 007042.
                        if(getTerritoryName(TTId)!=null){
                            Disp.SVMXC__Territory__c=TTId;
                        }
                        DsptchrList.add(Disp);
                    }   
                    UserExist = false;
                }                       
            }           
            if(!AddUserCountRec){    
            apexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG083()));
        }  
    }
    
    public pageReference SVMX_SaveDispToTeam(){
        uncheckCheckbox();
        PageReference p;    
        UsrCounter = 0;
        ChildTabs = true;
        DispMap.clear();
        boolean DoSave = true;
        SaveUsrListSize = false;  
        ExpKWrdList.clear();
        UserList.clear();
        if(DsptchrList.size()>0){
            SaveUsrListSize = true;
            for(integer i=0;i<DsptchrList.size();i++){
                if(DsptchrList[i].SVMXC__Dispatcher__c!=null && SaveDispCountRec){
                    DsptchrList[i].Select__c = false;
                    SaveDispCountRec=true;
                    DispMap.put(DsptchrList[i].SVMXC__Dispatcher__c,i);                                    
                }
                else
                    SaveDispCountRec=false;
            }     
        }
        if(!SaveDispCountRec){    
            DoSave = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG084()));
            SaveDispCountRec = true;
        }
        else if(DispMap.size()!=DsptchrList.size()){
            DoSave = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG085()));
        }
        if(!SaveUsrListSize){
            DoSave = false;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG086()));
        }
        if(DoSave){
            
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( DsptchrList, COMM_SecurityUtils.Access.Upsertable ) ) {     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                upsert DsptchrList;
            } else {
                DoSave = false;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
            }
        }   
        return p;
    }

   /* boolean DelDispCountRec = false;
    public boolean getDelDispCountRec(){  return DelDispCountRec;}
    public void setDelDispCountRec(boolean b){this.DelDispCountRec =b;} */
     
    public pageReference SVMX_DelDisptch(){   
        ChildTabs = true;
        uncheckCheckbox();  
        List<SVMXC__Dispatcher_Access__c> DispIDs = new List<SVMXC__Dispatcher_Access__c>();
        List<SVMXC__Dispatcher_Access__c> TempDispIDs = new List<SVMXC__Dispatcher_Access__c>();
    
        for(integer i=0;i<DsptchrList.size();i++){
            if(DsptchrList[i].SVMXC__Select__c){
            DelDispCountRec=true;
            if(DsptchrList[i].Id!=NULL)
                DispIDs.add(DsptchrList[i]);     
            }
            else
                TempDispIDs.add(DsptchrList[i]); 
        }
        if(!DelDispCountRec){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG087()));
        }
        else{
            if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Dispatcher_Access__c' ) ) {     //SDL-SVMX-DELETE-FLS-ENFORCED
                delete DispIDs;
            } else {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                return null;
            }
            
            DsptchrList.clear();
            DsptchrList = TempDispIDs;
        }   
        
        CheckAllDisp = false;
        DelDispCountRec = false;
        return null;
    } 
}