public  with sharing class CONF_EditProfile{
        /*****************************************************************************************************************************
    Wrapper Class
    *****************************************************************************************************************************/
        
        public class wrapper
        {
            public SVMXC__ServiceMax_Processes__c WSetting{get; set;}
            public  SVMXC__ServiceMax_Config_Data__c WSValue {get; set;}
            
            public wrapper(SVMXC__ServiceMax_Processes__c WS,  SVMXC__ServiceMax_Config_Data__c WSV)
            {
                WSetting = WS;
                WSValue = WSV;
            }
        }    
        //========================================= Variables =============================================//
        //public String SId= System.currentPageReference().getParameters().get('sid');//changed due to sid used by sfdc 29/12/2010 -HH
        public String SId= System.currentPageReference().getParameters().get('svmx_sid');
        public String Clone= System.currentPageReference().getParameters().get('cl');
        String profileName='';
        String profileDescription='';
        Boolean isprofileActive = false;
        Boolean OnLaunch=true;
        public SVMXC__ServiceMax_Config_Data__c conf_data=new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c Updconf_data=new SVMXC__ServiceMax_Config_Data__c();
        
        public List<wrapper> wrapSet = new List<wrapper>(); 
        public List<wrapper> getwrapSet(){return wrapSet;}  
        
        List<SVMXC__ServiceMax_Processes__c> serviceMaxSetting;
        List<SVMXC__ServiceMax_Config_Data__c> serviceMaxSetValue;
        List<SVMXC__ServiceMax_Config_Data__c> serviceMaxAccessBuf=new List<SVMXC__ServiceMax_Config_Data__c>();
        Id EstRecType = getEstRecordTypes().Id;
        Id SetingValRecType = getEstRecordTypes('Setting Value').Id;
        Id idMobileConfig = getEstRecordTypes('Mobile Configuration').Id;
        Id NewProf;
        public List<SVMXC__ServiceMax_Processes__c> Module;
        public List<Profile> Profiles;
        public List<Profile> SProfiles = new List<Profile>();
        public List<Profile> AProfiles = new List<Profile>();
        
        String profile1; //Base
        public String getProfile1(){   return profile1; }  
        public void setProfile1(String s){ profile1 =s; } 
        
        public List<String> profile = new List<String>(); //Base
        public List<String> getProfile(){   return this.profile; }  
        public void setProfile(String[] s){ this.profile =s; } 
        
        public List<String> Sprofile = new List<String>();  //To
        public List<String> getSProfile(){  return this.Sprofile; }  
        public void setSProfile(String[] s){ this.Sprofile =s; } 
        public String Sprofile1;  //To
        public String getSProfile1(){  return Sprofile1; }  
        public void setSProfile1(String s){ Sprofile1 =s; } 
        
        public List<String> T1profile = new List<String>();
        public List<String> T2profile = new List<String>();
        
        public List<Profile> SelectedProf = new List<Profile>();
        public List<Profile> AvailProf = new List<Profile>();
        
        Map<Id, String> IdToSMXProfileMap =  new Map<Id, String> {};
            Map<Id, String> IdToSFXProfileMap =  new Map<Id, String> {};
                Map<Id, Id> IdToSMXProfileIDMap =  new Map<Id, Id> {};
                    Set<Id> OthrProfList = new Set<Id>();
                    Map<Id, Profile> addProfileMap =  new Map<Id, Profile>();
                    Map<Id, Profile> removeProfileMap =  new Map<Id, Profile>();
        
        public List<SVMXC__ServiceMax_Processes__c> submodule;
        public String moduleView {get;set;}
        public String submoduleView {get; set;}
        
        public id getPageId(){
            return Sid;
        }
        public String getClone(){
            return Clone;
        }
        public boolean getIsDefault(){
            return IsDefault;
        }
        boolean AccessMessage;
        public boolean getAccessMessage(){
            return AccessMessage;
        }
        public boolean IsDefault {get; set;}
        public String ConfProfType {get; set;}
        
        Id ProfEstRecType = getProfEstRecordTypes().Id;
        public RecordType getProfEstRecordTypes(){
            RecordType erTypes;
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Config_Data__c\' and Name=\'Configuration Access\'';       
            erTypes = Database.query(SOQL);      
            return erTypes;
        }
        //======================================== Simple Display Utility ===================================================//
        
        //SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
        
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF006');
        
        //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CONF006');
        
        public String getTAG011() {return System.Label.CONF006_TAG011;} //'No records to display
        public String getTAG025() {return System.Label.CONF006_TAG025;} //'Configuration Profile'
        public String getTAG026() {return System.Label.CONF006_TAG026;} //'Setting Values'
        public String getTAG027() {return System.Label.CONF006_TAG027;} //'Setting List'
        public String getTAG028() {return System.Label.CONF006_TAG028;} //'Back To Setup Home'
        public String getTAG029() {return System.Label.CONF006_TAG029;} //'Save'
        public String getTAG030() {return System.Label.CONF006_TAG030;} //Cancel'
        public String getTAG031() {return System.Label.CONF006_TAG031;} //'Quick Save'
        public String getTAG032() {return System.Label.CONF006_TAG032;} //'Information'
        public String getTAG033() {return System.Label.CONF006_TAG033;} //'Access Permission'
        public String getTAG034() {return System.Label.CONF006_TAG034;} //'Clone'//
        public String getTAG035(){ return System.Label.CONF006_TAG035;} //'Invalid Data'//
        public String getTAG036(){ return System.Label.CONF006_TAG036;} //'Review all error messages below and click save'//
        public String getTAG037(){ return System.Label.CONF006_TAG037;} //'Save:'
        public String getTAG038(){ return System.Label.CONF006_TAG038;} //'Record saved sucessfully' 
        public String getTAG039(){ return System.Label.CONF006_TAG039;} //'Select Profiles'//
        public String getTAG040(){ return System.Label.CONF006_TAG040;} //'Requesting...'
        public String getTAG041(){ return System.Label.CONF006_TAG041;} //'Action'
        public String getTAG042(){ return System.Label.CONF006_TAG042;} //'ServiceMax Configuration Profile Help'
        public String getTAG044(){ return System.Label.CONF006_TAG044;} //Reset to Default
        public String getTAG045(){ return System.Label.CONF006_TAG045;} //Edit
        public String getTAG046(){ return System.Label.CONF006_TAG046;} //Refresh
        public String getTAG047(){ return System.Label.CONF006_TAG047;} //'--None--'
        public String getTAG048(){ return System.Label.CONF006_TAG048;} //Select Modules
        public String getTAG049(){ return System.Label.CONF006_TAG049;} //Select Submodules
        public String getTAG050(){ return System.Label.CONF006_TAG050;} //Please enter a value.
        public String getTAG051(){ return System.Label.CONF006_TAG051;} //Already an instance has been created with this name.
        public String getTAG052(){ return System.Label.CONF006_TAG052;} //Profile Name
        public String getTAG053(){ return System.Label.CONF006_TAG053;} //Update
        public String getTAG054(){ return System.Label.CONF006_TAG054;} //Data updated Sucessfully
        public String getTAG058(){ return System.Label.CONF006_TAG058;} //Please select one record to Reset
        public String getTAG060() {return System.Label.CONF006_TAG060;}//Following salesforce Profiles are already having an access assigned to servicemax online profile, this access would be revoked on save.
        public String getTAG061() {return System.Label.CONF006_TAG061;} //Setting ID
        public String getTAG062() {return System.Label.CONF006_TAG062;} //Settings Name
        public String getTAG063() {return System.Label.CONF006_TAG063;} //Description
        public String getTAG064() {return System.Label.CONF006_TAG064;} //Data Type
        public String getTAG065() {return System.Label.CONF006_TAG065;} //Values
        public String getTAG066() {return System.Label.CONF006_TAG066;} //Default Value
        public String getTAG067() {return System.Label.CONF006_TAG067;} //Internal Value
        public String getTAG068() {return System.Label.CONF006_TAG068;} //Display Value
        public String getTAG074() {return System.Label.CONF006_TAG074;} //Avalible Salesforce Profiles
        
        //Neeraj(Feb-7th-2012): Added new tags to fix translation related issues.
        public String getTAG071() {return System.Label.CONF006_TAG071;} //Add
        public String getTAG072() {return System.Label.CONF006_TAG072;} //Remove
        
        public String getHLPURL() {return System.Label.CONF006_HLPURL;}
        
        //======================================== Constructur call ===================================================//  
        public CONF_EditProfile(){
            
            subModuleOpts.add(new SelectOption(getTAG047(),getTAG047()));
            
            Profiles = [Select Id, Name From Profile where Name != '' order by Name]; //Added Order By Clause- GM 15Nov09 // # 01688
            
            onLoad();
        }
        public void onLoad(){
            
            Module = [Select  SVMXC__Name__c,SVMXC__ModuleID__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c = 'Module'order by SVMXC__Name__c];
            conf_data = [SELECT SVMXC__Profile_Name__c, SVMXC__Description__c, SVMXC__Active__c, SVMXC__IsDefault__c,SVMXC__Configuration_Type__c From SVMXC__ServiceMax_Config_Data__c where Id=:SId];
            serviceMaxAccessBuf=[Select Id,SVMXC__Profile__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access' and SVMXC__Access_Configuration_Profile__c = :SId];
            
            
            profileName=conf_data.SVMXC__Profile_Name__c;
            profileDescription = conf_data.SVMXC__Description__c;
            isprofileActive = conf_data.SVMXC__Active__c;
            ConfProfType=conf_data.SVMXC__Configuration_Type__c;
            IsDefault=conf_data.SVMXC__IsDefault__c;
            
            List<SVMXC__ServiceMax_Config_Data__c> LocSVMXprofiles;
            List<SVMXC__ServiceMax_Config_Data__c> serviceMaxAccessAvail=new List<SVMXC__ServiceMax_Config_Data__c>();
            List<String> T3profile = new List<String>();
            LocSVMXprofiles = [Select Id,SVMXC__Profile_Name__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Configuration Profile' and SVMXC__Configuration_Type__c = 'Group'];
            
            for(Integer i = 0; i < LocSVMXprofiles.size();i++)
            {
                if(LocSVMXprofiles[i].Id!=SId || Clone=='s')
                {
                    List<SVMXC__ServiceMax_Config_Data__c> temp;
                    temp=[Select Id,SVMXC__Profile__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access' and SVMXC__Access_Configuration_Profile__c = :LocSVMXprofiles[i].Id];
                    for(SVMXC__ServiceMax_Config_Data__c s :temp)
                    {
                        IdToSMXProfileMap.put(s.SVMXC__Profile__c,LocSVMXprofiles[i].SVMXC__Profile_Name__c);
                        IdToSMXProfileIDMap.put(s.SVMXC__Profile__c,LocSVMXprofiles[i].Id);
                        OthrProfList.add(s.SVMXC__Profile__c);
                    }
                    serviceMaxAccessAvail.addAll(temp);
                }
            }
            
            boolean Isvalid=true;
            if(Clone!=null)
            {
                conf_data.SVMXC__IsDefault__c=false;
                conf_data.SVMXC__Description__c='';
                if(ConfProfType=='Global')
                    conf_data.SVMXC__Active__c=false;
            }    
            if(Clone==NULL)
            {
                for(Integer i = 0; i < serviceMaxAccessBuf.size();i++)
                {
                    for(Integer j = 0; j < Profiles.size();j++)
                    {
                        if(serviceMaxAccessBuf[i].SVMXC__Profile__c==Profiles[j].Id)
                        {
                            SelectedProf.add(Profiles[j]);
                            T2profile.add(Profiles[j].Id);
                            T3profile.add(Profiles[j].Id);
                            SProfiles.add(Profiles[j]);
                        }
                    }
                }
                
            }
            If(Profiles.size()>0)
            {
                for(Integer i = 0; i < Profiles.size();i++)
                {
                    Isvalid=true;
                    for(Integer j = 0; j < T2profile.size();j++)
                    {
                        if(Profiles[i].Id==T2profile[j])
                            Isvalid=false;
                    }
                    if(Isvalid==true)
                    {
                        AvailProf.add(Profiles[i]);
                        IdToSFXProfileMap.put(Profiles[i].Id,Profiles[i].Name);
                        T1profile.add(Profiles[i].Id);
                        AProfiles.add(Profiles[i]);
                    }
                }
            }
            T2profile.clear();
            T2profile=T3profile;
        }
        /*
    Commented in 2.7 Release
    Reason(Defect:000442): CONF-EditProfile page does not load if there are more than 300 SFDC profiles in the org
    We are not able to create more than 300 profiles by applying these sorting functions
    //----------------------------------Sorting Function-----------------------------------------------
    public List<SelectOption> sortingSelectAvailProfOption(List<SelectOption> so){
    SelectOption tempObj; 
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
    tempLst = T1profile[j];
    T1profile[j] = T1profile[i];
    T1profile[i] = tempLst;
    }
    }
    }
    return so;
    }
    //----------------------------------Sorting Function-----------------------------------------------
    public List<SelectOption> sortingSelectSelectedProfOption(List<SelectOption> so){
    SelectOption tempObj; 
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
    tempLst = T2profile[j];
    T2profile[j] = T2profile[i];
    T2profile[i] = tempLst;
    }
    }
    }
    return so;
    }
    */
        //========================================= Function : Bound Profile details =============================================//
        public SVMXC__ServiceMax_Config_Data__c getProf_Detail() {
            if(Clone!=null && OnLaunch==true){OnLaunch=false; conf_data.SVMXC__Profile_Name__c='';}
            return conf_data;
        }
        //========================================= Function : Return PopUp URL =============================================//
        public String getPopUpLink(){
            String url;
            if(svmxSettingList.containsKey('SET004') == true) url =svmxSettingList.get('SET004');
            return url;
        } 
        //========================================= Function : Handles Profiles =============================================//
        public String getAvailProf(){
            return JSON.serialize(AvailProf);
        }  
        
        public boolean getActiveEditable(){
            if((ConfProfType=='Group' && IsDefault==false) || (ConfProfType=='Group' && Clone!=NULL))
                return true;
            else
                return false;
        }
        
        public String getSelectedProf(){
            return JSON.serialize(SelectedProf);
        }  
        //======================================== Setting Initial Checklist status ===================================================//
        public RecordType getEstRecordTypes(){
            RecordType erTypes;
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Config_Data__c\' and Name=\'Configuration Profile\'';       
            erTypes = Database.query(SOQL);      
            return erTypes;
        }
        public RecordType getEstRecordTypes(String recTypeName){
            RecordType erTypes;
            String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Config_Data__c\' and Name=\''+recTypeName+'\'';       
            erTypes = Database.query(SOQL);      
            return erTypes;
        }
        //========================================= Function : Selecting & Returning Modules Values =============================================//
        public List<SelectOption> getModule()
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(getTAG047(),getTAG047()));
            If(module.size()>0){ 
                for(Integer i = 0; i < module.size();i++){
                    options.add(new SelectOption(Module[i].SVMXC__ModuleID__c,Module[i].SVMXC__Name__c));
                }
            }
            return options;
        }
        //========================================= Function : Selecting & Returning Modules Values =============================================//
        //======================================== Module Selection functions ===================================================// 
        public List<SelectOption> subModuleOpts = new List<SelectOption>();
        
        public PageReference onSelectMod() {
            ProfDisplayBlockLevelMessage=false;
            headerDisplayBlockLevelMessage=false;
            headerRecDisplayBlockLevelMessage=false;
            wrapSet.clear();
            //submoduleView=getTAG047();
            submodule = [Select SVMXC__SubmoduleID__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c  
                         where SVMXC__Record_Type_Name__c ='Submodule' and SVMXC__Module__r.SVMXC__ModuleID__c = :moduleView order by SVMXC__Name__c];
            
            subModuleOpts.clear();
            subModuleOpts.add(new SelectOption(getTAG047(),getTAG047()));
            If(submodule.size()>0){ 
                for(Integer i = 0; i < submodule.size();i++){
                    subModuleOpts.add(new SelectOption(submodule[i].Id,submodule[i].SVMXC__Name__c));
                }
            }
            return null;
        }  
        public PageReference onSelectSubmod() {
            ProfDisplayBlockLevelMessage=false;
            wrapSet.clear();
            if(ConfProfType=='Group')
                serviceMaxSetting= [Select Id,SVMXC__Submodule__c, SVMXC__Settings_Name__c, SVMXC__Description__c, SVMXC__SettingID__c, SVMXC__Data_Type__c, SVMXC__Values__c,SVMXC__Select__c,SVMXC__Default_Value__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Settings' and SVMXC__IsPrivate__c=false and SVMXC__Submodule__r.Id = :submoduleView and SVMXC__Setting_Type__c= :ConfProfType order by SVMXC__SettingID__c];
            else if(ConfProfType=='Global')
                serviceMaxSetting= [Select Id,SVMXC__Submodule__c, SVMXC__Settings_Name__c, SVMXC__Description__c, SVMXC__SettingID__c, SVMXC__Data_Type__c, SVMXC__Values__c,SVMXC__Select__c,SVMXC__Default_Value__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Settings' and SVMXC__IsPrivate__c=false and SVMXC__Submodule__r.Id = :submoduleView order by SVMXC__SettingID__c];
            
            for(SVMXC__ServiceMax_Processes__c WS : serviceMaxSetting ){
                Boolean matchFound = false;
                wrapper Twrap;
                
                serviceMaxSetValue= [Select Id, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Setting_ID__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Setting Value' and SVMXC__Setting_ID__c=:WS.Id and SVMXC__Setting_Configuration_Profile__c = :SId];
                
                for(SVMXC__ServiceMax_Config_Data__c WSV : serviceMaxSetValue ){
                    //BAC-5889 Date/Time setting
                    System.debug('WSV.SVMXC__Internal_Value__c - '+WSV.SVMXC__Internal_Value__c);
                    if(WS.SVMXC__Data_Type__c == 'Date/Time' && WSV.SVMXC__Internal_Value__c != null && WSV.SVMXC__Internal_Value__c != 'Default Value' && WSV.SVMXC__Display_Value__c != null && WSV.SVMXC__Display_Value__c != 'Default Value'){
                        WSV.SVMXC__Internal_Value__c = String.valueOf(Datetime.valueOfGmt(WSV.SVMXC__Internal_Value__c));
                        WSV.SVMXC__Display_Value__c = String.valueOf(Datetime.valueOfGmt(WSV.SVMXC__Display_Value__c));
                    }
                    Twrap = new wrapper(WS,WSV);  
                    matchFound = true;
                }
                if(matchFound == false ){
                    SVMXC__ServiceMax_Config_Data__c TWSV = new SVMXC__ServiceMax_Config_Data__c();
                    Twrap = new wrapper(WS,TWSV ); 
                }    
                wrapSet.add(Twrap);    
            }
            if(wrapSet.size()>0)
            {
                headerRecDisplayBlockLevelMessage=false;
                headerDisplayBlockLevelMessage=true;
            }
            else
            {
                headerRecDisplayBlockLevelMessage=true;
                headerDisplayBlockLevelMessage=false;
            }
            
            return null;
        }
        
        //======================================== Function to check whether the data is valid for custom modules ===================================================//
        public Boolean isValidData(){
            Integer tempCount=[Select count() From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c = 'Configuration Profile' and SVMXC__Profile_Name__c = :conf_data.SVMXC__Profile_Name__c and SVMXC__Configuration_Type__c= :ConfProfType];
            Integer i;  
            boolean error=false;
            if (conf_data.SVMXC__Profile_Name__c==null){
                error=true;
                conf_data.SVMXC__Profile_Name__c.addError(getTAG050());
            }
            if (tempCount!=0 && Clone=='s' && error!=true){
                error=true;
                conf_data.SVMXC__Profile_Name__c.addError(getTAG051());
            }
            return error;
        }
        //======================================== Action for save ===================================================//
        public PageReference saveProf() 
        {
            AccessMessage=false;
            if(IsDefault==true && Clone==NULL && ConfProfType=='Group')
            {
                saveAccessProf();   
                return cancelProf();
            }
            DisplayBlockLevelMessage = false; 
            ProfDisplayBlockLevelMessage = true; 
            boolean error=false;
            error=isValidData();
            
            if (error==true)
            {
                return null;    
            }
            
            try 
            {
                if(Clone!='s' && Clone!='u')
                {
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_data, COMM_SecurityUtils.Access.Updateable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update conf_data;
                        
                        //BAC-4624 insert view servicemax configuration
                        String actionData = '';
                        if(profileName != conf_data.SVMXC__Profile_Name__c){
                            actionData = 'Modified Name for Profile '+profileName+' to '+conf_data.SVMXC__Profile_Name__c; 
                        }
                        else if(profileDescription != conf_data.SVMXC__Description__c){
                            actionData = 'Modified Description for Profile '+ conf_data.SVMXC__Profile_Name__c;
                        }
                        
                        COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                        String entityName = ConfProfType == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
                        if(actionData != ''){
                            commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
                        }
                        
                        if(isprofileActive != conf_data.SVMXC__Active__c){
                            if(conf_data.SVMXC__Active__c){
                                actionData = 'Activated ' + conf_data.SVMXC__Profile_Name__c;
                            }
                            else{
                                actionData = 'Inactivated ' + conf_data.SVMXC__Profile_Name__c;
                            }
                            commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
                        }
                    } else {                
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));
                        return null;
                    }
                }
                else if(Clone=='u')
                {
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Updconf_data, COMM_SecurityUtils.Access.Updateable ) ) {
                        Updconf_data.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
                        Updconf_data.SVMXC__Description__c=conf_data.SVMXC__Description__c;
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update Updconf_data;
                    } else {                
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));      
                        return null;
                    }
                }
                else if(Clone=='s')
                {
                    SVMXC__ServiceMax_Config_Data__c conf_set = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=EstRecType);
                    conf_set.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
                    conf_set.SVMXC__Description__c=conf_data.SVMXC__Description__c;
                    conf_set.SVMXC__Configuration_Type__c=ConfProfType;
                    conf_set.SVMXC__IsDefault__c=false;
                    conf_set.SVMXC__Active__c=conf_data.SVMXC__Active__c;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_set, COMM_SecurityUtils.Access.Createable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert conf_set;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    Updconf_data=conf_set;
                    NewProf=conf_set.Id;
                    CloneSettingValue();
                    CloneMobileConfigValue();
                    
                    //BAC-4624 insert view servicemax configuration
                    String actionData = 'Cloned ' + profileName + ' to ' + conf_data.SVMXC__Profile_Name__c;
                    String entityName = ConfProfType == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
                    COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                    commUtils.processServicemaxConfiguration(entityName,'Browser','Created',actionData);
                }
                saveAccessProf();
                return cancelProf();
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
            }
            return null;
        }
        
        
        public PageReference saveAccessProf() {
            SVMXC__ServiceMax_Config_Data__c tempAccess;
            List<SVMXC__ServiceMax_Config_Data__c> tempAccessList =  new List<SVMXC__ServiceMax_Config_Data__c>();
            
            AccessMessage=false;
            if(Clone==NULL || Clone=='u') {
                if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    
                    ApexPages.addMessage( new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;            
                }
                //SDL-SVMX-DELETE-FLS-ENFORCED
                if(serviceMaxAccessBuf.size()>0)delete serviceMaxAccessBuf;
            }            
            serviceMaxAccessBuf.clear();
            if(Clone==NULL)
            {
                for(Integer j = 0; j < T2profile.size();j++){
                    SVMXC__ServiceMax_Config_Data__c newProfLine = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=ProfEstRecType,SVMXC__Access_Configuration_Profile__c=SId,SVMXC__Profile__c=T2profile[j],SVMXC__Active__c=true);             
                    serviceMaxAccessBuf.add(newProfLine);
                }
                List<SVMXC__ServiceMax_Config_Data__c> temp;
                temp=[Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access' and SVMXC__Profile__c IN :T2profile and SVMXC__Profile__c IN :OthrProfList and SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile'];
                if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                    
                    ApexPages.addMessage( new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;            
                }
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete temp;
            } 
            else
            {
                for(Integer j = 0; j < T2profile.size();j++){
                    SVMXC__ServiceMax_Config_Data__c newProfLine = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=ProfEstRecType,SVMXC__Access_Configuration_Profile__c=NewProf,SVMXC__Profile__c=T2profile[j],SVMXC__Active__c=true);             
                    serviceMaxAccessBuf.add(newProfLine);
                    if(OthrProfList.contains(T2profile[j])==true){
                        tempAccess=[Select Id,SVMXC__Access_Configuration_Profile__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Access'  and SVMXC__Access_Configuration_Profile__c=:IdToSMXProfileIDMap.get(T2profile[j]) and  SVMXC__Profile__c=:T2profile[j] Limit 1];
                        tempAccess.SVMXC__Access_Configuration_Profile__c=SId;
                        tempAccessList.add(tempAccess);
                    }
                }
            }
            
            if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                
                ApexPages.addMessage( new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                return null;            
            }
            //SDL-SVMX-DELETE-FLS-ENFORCED
            if(tempAccessList.size()>0)delete tempAccessList;  
            
            for (Integer i=T2profile.size()-1;i>=0;i--){
                if(OthrProfList.contains(T2profile[i]))
                    OthrProfList.remove(T2profile[i]);
            }
            
            if(serviceMaxAccessBuf.size()>0) {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( serviceMaxAccessBuf, COMM_SecurityUtils.Access.Createable ) ) {
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    insert serviceMaxAccessBuf;
                } else {
                    ApexPages.addMessage( new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                    return null;
                }
            }
            
            //BAC-4624 insert view servicemax configuration
            if(addProfileMap.size() > 0){
                String salesforceProfile = '';
                for(Id profileId : addProfileMap.keySet()){
                    Profile profileData = addProfileMap.get(profileId);
                    if(salesforceProfile == ''){
                        salesforceProfile = profileData.Name;
                    }
                    else{
                        salesforceProfile += ',' +profileData.Name;
                    }
                }
                String actionData = 'Assigned SalesforceProfiles ' + salesforceProfile + ' for profile ' + profileName;
                String entityName = 'Group-wide Configuration';
                COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
            }
            
            if(removeProfileMap.size() > 0){
                String salesforceProfile = '';
                for(Id profileId : removeProfileMap.keySet()){
                    Profile profileData = removeProfileMap.get(profileId);
                    if(salesforceProfile == ''){
                        salesforceProfile = profileData.Name;
                    }
                    else{
                        salesforceProfile += ',' +profileData.Name;
                    }
                }
                String actionData = 'Unassigned SalesforceProfiles ' + salesforceProfile + ' for profile ' + profileName;
                String entityName = 'Group-wide Configuration';
                COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
            }
            addProfileMap.clear();
            removeProfileMap.clear();
            
            if(Clone=='s')Clone='u';
            return null;
        }
        public PageReference CloneSettingValue() 
        {
            Id ProfileId=NewProf;
            List<SVMXC__ServiceMax_Config_Data__c> CloneserviceMaxSetValue;
            List<SVMXC__ServiceMax_Config_Data__c> InsertserviceMaxSetValue= new List<SVMXC__ServiceMax_Config_Data__c>();
            CloneserviceMaxSetValue= [Select Id, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Setting_ID__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Setting Value' and SVMXC__Setting_Configuration_Profile__c = :SId];
            SVMXC__ServiceMax_Config_Data__c cloneConfig;
            
            for(Integer i = 0; i < CloneserviceMaxSetValue.size();i++){
                cloneConfig = new SVMXC__ServiceMax_Config_Data__c();
                cloneConfig.SVMXC__Internal_Value__c=CloneserviceMaxSetValue[i].SVMXC__Internal_Value__c;
                cloneConfig.SVMXC__Display_Value__c=CloneserviceMaxSetValue[i].SVMXC__Display_Value__c;
                cloneConfig.SVMXC__Setting_ID__c=CloneserviceMaxSetValue[i].SVMXC__Setting_ID__c;
                cloneConfig.SVMXC__Setting_Configuration_Profile__c=ProfileId;
                cloneConfig.RecordTypeId=SetingValRecType;
                InsertserviceMaxSetValue.add(cloneConfig);
            }
            
            try{
                if(InsertserviceMaxSetValue.size()>0) {
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( InsertserviceMaxSetValue, COMM_SecurityUtils.Access.Createable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert InsertserviceMaxSetValue;
                    } else {
                        ApexPages.addMessage( new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );    
                        return null;    
                    }
                }    
            }
            catch (Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));    
                return null;  
            }
            return null;
        }
        
        public PageReference CloneMobileConfigValue() 
        {
            Id ProfileId = NewProf;
            List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfig = new List<SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__SM_Device_Mobile_Config__c> lstDeviceMobileConfig = new List<SVMXC__SM_Device_Mobile_Config__c>();
            List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
            lstMobileConfigData = [Select Id, SVMXC__Internal_Value__c, SVMXC__Display_Type__c, SVMXC__Parameter_Name__c,SVMXC__SM_Device_Mobile_Config__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c='Mobile Configuration' and SVMXC__Display_Type__c <> null and SVMXC__Access_Configuration_Profile__c =:SId];
            
            
            //Bac-2838----------------------------
            Map<String,Id> mapExistingDevconfIdClonedId = new Map<String,Id>();
            try
            {
                lstDeviceMobileConfig = [Select SVMXC__SM_Name__c,SVMXC__SM_Description__c,SVMXC__SM_Device_Type__c, SVMXC__SM_IsDefault__c  From SVMXC__SM_Device_Mobile_Config__c where SVMXC__SM_Access_Configuration_Profile__c =:SId];
                for(SVMXC__SM_Device_Mobile_Config__c obj:lstDeviceMobileConfig)
                System.debug('Device Type  1 :  '+obj.SVMXC__SM_Device_Type__c);
            
                
                List<Id> lstExistingDevconfId = new List<Id>();
                List<SVMXC__SM_Device_Mobile_Config__c> lstClonedDevconf = new  List<SVMXC__SM_Device_Mobile_Config__c>();
                for(SVMXC__SM_Device_Mobile_Config__c ExistingConfig:lstDeviceMobileConfig)
                {
                    SVMXC__SM_Device_Mobile_Config__c DevConfCloned = new SVMXC__SM_Device_Mobile_Config__c();
                    DevConfCloned = ExistingConfig.clone(false);
                    DevConfCloned.SM_Access_Configuration_Profile__c=ProfileId;
                    lstClonedDevconf.add(DevConfCloned);
                    lstExistingDevconfId.add(ExistingConfig.Id);
                }
                
                
                if(lstClonedDevconf.size() > 0) {
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstClonedDevconf, COMM_SecurityUtils.Access.Createable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert lstClonedDevconf;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, '' ));    
                        return null;
                    }
                }
                for(Integer i=0; i<lstExistingDevconfId.size(); i++)
                {
                    mapExistingDevconfIdClonedId.put(lstExistingDevconfId[i],lstClonedDevconf[i].id);
                }
            }
            catch (Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));    
                return null;  
            }
           
            //-------------------------------------------------------
            SVMXC__ServiceMax_Config_Data__c cloneConfig;
            for(Integer i = 0; i < lstMobileConfigData.size();i++){
                cloneConfig = new SVMXC__ServiceMax_Config_Data__c();
                cloneConfig.SVMXC__Internal_Value__c = lstMobileConfigData[i].SVMXC__Internal_Value__c;
                cloneConfig.SVMXC__Display_Type__c = lstMobileConfigData[i].SVMXC__Display_Type__c;
                cloneConfig.SVMXC__Parameter_Name__c = lstMobileConfigData[i].SVMXC__Parameter_Name__c;
                cloneConfig.SVMXC__Access_Configuration_Profile__c = ProfileId;
                cloneConfig.RecordTypeId = idMobileConfig;
                System.debug('Device Type 2 :  '+lstMobileConfigData[i].SVMXC__SM_Device_Mobile_Config__c);
                if(!mapExistingDevconfIdClonedId.isEmpty() && lstMobileConfigData[i].SVMXC__SM_Device_Mobile_Config__c != null &&   mapExistingDevconfIdClonedId.Containskey(lstMobileConfigData[i].SVMXC__SM_Device_Mobile_Config__c))
                    cloneConfig.SVMXC__SM_Device_Mobile_Config__c = mapExistingDevconfIdClonedId.get(lstMobileConfigData[i].SVMXC__SM_Device_Mobile_Config__c);     
                
                lstMobileConfig.add(cloneConfig);
            }
            
            try
            {
                if(lstMobileConfig.size() > 0) {
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstMobileConfig, COMM_SecurityUtils.Access.Createable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert lstMobileConfig;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, '' ));    
                        return null;
                    }
                }
                
            }
            catch (Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));    
                return null;  
            }
            return null;
        }
        
        public PageReference onRefresh() {
            onSelectSubmod();
            return null;
        }
        //======================================== Action for Quick Save ===================================================//
        public PageReference QsaveProf() {
            DisplayBlockLevelMessage = false; 
            ProfDisplayBlockLevelMessage = true;  
            if(IsDefault==true && Clone==NULL && ConfProfType=='Group')
            {
                saveAccessProf();
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG037(),getTAG038()));  
                return null;
            }
            boolean error=false;
            error=isValidData();
            
            if (error==true){
                return null;    
            }
            try {
                if(Clone!='s' && Clone!='u'){
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_data, COMM_SecurityUtils.Access.Updateable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update conf_data;
                        
                        //BAC-4624 insert view servicemax configuration
                        String actionData = '';
                        if(profileName != conf_data.SVMXC__Profile_Name__c){
                            actionData = 'Modified Name for Profile '+profileName+' to '+conf_data.SVMXC__Profile_Name__c; 
                        }
                        else if(profileDescription != conf_data.SVMXC__Description__c){
                            actionData = 'Modified Description for Profile '+ conf_data.SVMXC__Profile_Name__c;
                        }
                        
                        COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                        String entityName = ConfProfType == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
                        if(actionData != ''){
                            commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
                        }
                        
                        if(isprofileActive != conf_data.SVMXC__Active__c){
                            if(conf_data.SVMXC__Active__c){
                                actionData = 'Activated ' + conf_data.SVMXC__Profile_Name__c;
                            }
                            else{
                                actionData = 'Inactivated ' + conf_data.SVMXC__Profile_Name__c;
                            }
                            commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
                        }
                    } else {                
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));      
                        return null;
                    }
                }
                else if(Clone=='u'){
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( Updconf_data, COMM_SecurityUtils.Access.Updateable ) ) {
                        Updconf_data.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
                        Updconf_data.SVMXC__Description__c=conf_data.SVMXC__Description__c;
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        update Updconf_data;
                    } else {                
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));      
                        return null;
                    }
                }
                else if(Clone=='s')
                {
                    SVMXC__ServiceMax_Config_Data__c conf_set = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=EstRecType);
                    conf_set.SVMXC__Profile_Name__c=conf_data.SVMXC__Profile_Name__c;
                    conf_set.SVMXC__Description__c=conf_data.SVMXC__Description__c;
                    conf_set.SVMXC__Configuration_Type__c=ConfProfType;
                    conf_set.SVMXC__IsDefault__c=false;
                    conf_set.SVMXC__Active__c=conf_data.SVMXC__Active__c;
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( conf_set, COMM_SecurityUtils.Access.Createable ) ) {
                        //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        insert conf_set;        
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
                        return null;
                    }
                    
                    Updconf_data=conf_set;
                    NewProf=conf_set.Id;
                    CloneSettingValue();
                    CloneMobileConfigValue();
                    
                    //BAC-4624 insert view servicemax configuration
                    String actionData = 'Cloned ' + profileName + ' to ' + conf_data.SVMXC__Profile_Name__c;
                    String entityName = ConfProfType == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
                    COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                    commUtils.processServicemaxConfiguration(entityName,'Browser','Created',actionData);
                }
                saveAccessProf();
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG037(),getTAG038()));   
            }
            catch (Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
            }
            return null;
        }
        
        //========================================= Page References for Goto Home And Cancel =============================================//
        public PageReference GoSetupHome(){
            String url = '/';
            //if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
            //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
            if(svmxSettingList.containsKey('SET002') == true){
                if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                    url = '/lightning/n/SVMXC__ServiceMax_Setup';
                }else{
                    url =svmxSettingList.get('SET002');
                }
            }
            //Changes done by Nidhi ends here           
            PageReference HomePage = new PageReference(url);
            HomePage.setRedirect(true);
            return HomePage; 
        }
        public PageReference cancelProf(){
            String url = '/';
            if(svmxSettingList.containsKey('SET001') == true) url =svmxSettingList.get('SET001');
            PageReference ManageProf = new PageReference(url);
            ManageProf.setRedirect(true);
            return ManageProf; 
        }
        //========================================= Function : Handles Reset To Default =============================================//
        SVMXC__ServiceMax_Config_Data__c ReSet_prof;
        public List<SVMXC__ServiceMax_Config_Data__c> BufReSet_prof = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        public PageReference onREsetDef() {
            DisplayBlockLevelMessage = true; 
            ProfDisplayBlockLevelMessage = false;
            for(wrapper wr: wrapSet){
                if(wr.WSetting.SVMXC__Select__c==true){
                    //BAC-4624 for Audit trial entry
                    SVMXC__ServiceMax_Config_Data__c profileData = [Select Id, SVMXC__Profile_Name__c,SVMXC__Configuration_Type__c  From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Configuration Profile' and Id =:SId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    SVMXC__ServiceMax_Processes__c settingData = [Select Id,SVMXC__SettingID__c ,SVMXC__Submodule__c  from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' and Id =:wr.WSetting.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    SVMXC__ServiceMax_Processes__c subModuleData = [Select Id,SVMXC__Name__C,SVMXC__Module__c from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Submodule' and Id =:settingData.SVMXC__Submodule__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    SVMXC__ServiceMax_Processes__c moduleData = [Select Id,SVMXC__Name__C from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Module' and Id =:subModuleData.SVMXC__Module__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    ReSet_prof = [SELECT SVMXC__Display_Value__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Setting Value' and SVMXC__Setting_ID__c=:wr.WSetting.Id and SVMXC__Setting_Configuration_Profile__c = :SId limit 1];
                    String actionData = 'Reset to Default ' + settingData.SVMXC__SettingID__c + ' from value ' + ReSet_prof.SVMXC__Display_Value__c + ' to '+ wr.WSetting.SVMXC__Default_Value__c + ' for profile '+ profileData.SVMXC__Profile_Name__c + ' Module '+moduleData.SVMXC__Name__C + ' Submodule ' +subModuleData.SVMXC__Name__C;
                    ReSet_prof.SVMXC__Display_Value__c=wr.WSetting.SVMXC__Default_Value__c;
                    ReSet_prof.SVMXC__Internal_Value__c=wr.WSetting.SVMXC__Default_Value__c;
                    BufReSet_prof.add(ReSet_prof);
                    
                    //BAC-4624 insert view servicemax configuration
                    String entityName = profileData.SVMXC__Configuration_Type__c == 'Global' ? 'Org-wide Configuration' : 'Group-wide Configuration';
                    COMM_Utils_V2 commUtils = new COMM_Utils_V2();
                    commUtils.processServicemaxConfiguration(entityName,'Browser','Modified',actionData);
                }
            }
            
            If(BufReSet_prof.size()==0){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG035(),getTAG058())); 
                return null;
            }
            
            try{
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( BufReSet_prof, COMM_SecurityUtils.Access.Updateable ) ) {
                    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    update BufReSet_prof;
                    BufReSet_prof.clear();
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG053(),getTAG054())); 
                } else {                
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ));      
                }
            }
            catch (Exception ex){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
            }
            onSelectSubmod();
            return null;
        }
        
        
        
        /**********************************************************************************************************************/
        public PageReference onAddProfile(){
            List<Integer> selectedLines = new List<Integer>();
            Integer i;
            System.debug('selected profile : '+profile1);
            if(profile1 != null)
                profile = profile1.split(',');
            System.debug('selected profile 2 : '+profile);
            for(String fs: profile){
                for(i = 0; i < T1profile.size();i++){
                    if(fs == T1profile[i]){
                        selectedLines.add(i);
                        SelectedProf.add(AvailProf.get(i));
                        //SProfiles.add(AProfiles[i]);
                        T2profile.add(T1profile[i]);
                        if(removeProfileMap.containsKey(T1profile[i])){
                            removeProfileMap.remove(T1profile[i]);
                        }
                        else{
                            addProfileMap.put(T1profile[i], AvailProf.get(i));
                        }
                    }
                }
            }
            for (i=selectedLines.size()-1;i>=0;i--){
                //AProfiles.remove(selectedLines.get(i));
                AvailProf.remove(selectedLines.get(i));
                T1profile.remove(selectedLines.get(i));
            }
            //SelectedProf=sortingSelectSelectedProfOption(SelectedProf);
            AccessStatusCheck();
            
            System.debug('selected profile 3 : '+SelectedProf);
            return null;
        }
        /*******************************************************************************************************/
        public PageReference onRemProfile(){
            List<Integer> selectedLines = new List<Integer>();
            Integer i;
            if(Sprofile1 != null)
                Sprofile = Sprofile1.split(',');
            for(String ps: Sprofile){
                for(i = 0; i < T2profile.size();i++){
                    if(ps == T2profile[i]){
                        selectedLines.add(i);
                        AvailProf.add(SelectedProf.get(i));
                        T1profile.add(T2profile[i]);
                        //AProfiles.add(SProfiles[i]);
                        if(addProfileMap.containsKey(T2profile[i])){
                            addProfileMap.remove(T2profile[i]);
                        }
                        else{
                            removeProfileMap.put(T2profile[i], SelectedProf.get(i));
                        }
                    }  
                }
            }
            for (i=selectedLines.size()-1;i>=0;i--){
                //SProfiles.remove(selectedLines.get(i));
                SelectedProf.remove(selectedLines.get(i));
                T2profile.remove(selectedLines.get(i));
            }
            //AvailProf=sortingSelectAvailProfOption(AvailProf);
            AccessStatusCheck();
            return null;
        }
        
        public void AccessStatusCheck()
        {
            AccessMessage=false;
            String Status='';
            Integer i;
            for (i=T2profile.size()-1;i>=0;i--){
                if(OthrProfList.contains(T2profile[i]))
                {
                    //AccessMessage=true;
                    //Status=getTAG061()+IdToSMXProfileMap.get(T2profile[i])+getTAG062()+IdToSFXProfileMap.get(T2profile[i])+getTAG063()+Status;
                    if(AccessMessage!=true){
                        AccessMessage=true;
                        Status=IdToSFXProfileMap.get(T2profile[i])+' -> '+IdToSMXProfileMap.get(T2profile[i])+Status;
                    }
                    else{
                        Status=Status+' , '+IdToSFXProfileMap.get(T2profile[i])+' -> '+IdToSMXProfileMap.get(T2profile[i]);
                    }
                }
            }
            if(AccessMessage==true)
                //Status=Status+getTAG064();
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.WARNING,getTAG060(),Status));   
        }
        
        //========================================= Function : Selecting & Returning SubModules Values =============================================//
        public List<SelectOption> getSubModule(){
            return subModuleOpts;
        } 
        //======================================== Set true to display blocklevel messge ===================================================//
        public Boolean DisplayBlockLevelMessage = false;
        public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }  
        public Boolean ProfDisplayBlockLevelMessage = false;
        public Boolean getProfDisplayBlockLevelMessage(){ return ProfDisplayBlockLevelMessage; }   
        public Boolean headerDisplayBlockLevelMessage = false;
        public Boolean getheaderDisplayBlockLevelMessage(){ return headerDisplayBlockLevelMessage; }   
        public Boolean headerRecDisplayBlockLevelMessage = false;
        public Boolean getheaderRecDisplayBlockLevelMessage(){ return headerRecDisplayBlockLevelMessage; }   
        public Boolean getDisplayProfiles(){ if(ConfProfType=='Global') return false; else return true; } 
        
    }