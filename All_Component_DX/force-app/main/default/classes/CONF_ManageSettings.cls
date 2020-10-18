public with sharing class CONF_ManageSettings{
    //String Sid= System.currentPageReference().getParameters().get('sid');//changed due to sid used by sfdc 29/12/2010 -HH 
    String Sid= System.currentPageReference().getParameters().get('svmx_sid');
    String Mid= System.currentPageReference().getParameters().get('mid');
    
    
    String Submod;
    public Integer custSize=0;
    public Integer stdSize=0;
    
    Boolean isLaunch=true;
    Boolean isAdd=false;  
    Boolean CheckAllLines=false;    
    public Boolean DisplaySettings = false;
    public Boolean DisplayBlockLevelMessage = false;
    
    SVMXC__ServiceMax_Processes__c SubModId;
    SVMXC__ServiceMax_Processes__c conf_set;
    
    public List<String> Default_Type;
    public  List<SVMXC__ServiceMax_Processes__c> deleteCustomSettings = new List<SVMXC__ServiceMax_Processes__c>(); 
    public  List<SVMXC__ServiceMax_Processes__c> createProf = new List<SVMXC__ServiceMax_Processes__c>(); 
    public  List<SVMXC__ServiceMax_Processes__c> resetSeting = new List<SVMXC__ServiceMax_Processes__c>(); 
    public List<SVMXC__ServiceMax_Processes__c> Module;
    public List<SVMXC__ServiceMax_Processes__c> submodule;
    public List<SVMXC__ServiceMax_Config_Data__c> Profiles;
    public List<SelectOption> subModuleOpts = new List<SelectOption>();
    List<SVMXC__ServiceMax_Processes__c> serviceMaxConfData;
    public List<SVMXC__ServiceMax_Processes__c> cust_serviceMaxConfData;
    List<SVMXC__ServiceMax_Processes__c> cust_serviceMaxConfDataType;
    List<SVMXC__ServiceMax_Config_Data__c> DelMaxAccessBuf = new List<SVMXC__ServiceMax_Config_Data__c>(); 
    List<SVMXC__ServiceMax_Config_Data__c> serviceMaxProfConfData = new List<SVMXC__ServiceMax_Config_Data__c>(); 
    
    Id SettingEstRecType = getEstRecordTypes().Id;
    Id ProfEstRecType = getProfEstRecordTypes().Id;
    
    //======================================== Simple Display Utility ===================================================// 
    //=========================================== Translation ===============================================//
    // Call a Method in UTIL class to return Tags, Send SubModule ID for getting TAGS
    //SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('CONF003');
    
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CONF003');
    
    public String getTAG001() {return System.Label.CONF003_TAG001;} //Module Selection
    public String getTAG002() {return System.Label.CONF003_TAG002;} //Standard Setting Values
    public String getTAG003() {return System.Label.CONF003_TAG003;} //Custom Setting Values
    public String getTAG004() {return System.Label.CONF003_TAG004;} //Back To Setup Home
    public String getTAG005() {return System.Label.CONF003_TAG005;} //Add Setting
    public String getTAG006() {return System.Label.CONF003_TAG006;} //Add Setting
    public String getTAG007() {return System.Label.CONF003_TAG007;} //Delete
    public String getTAG008(){ return System.Label.CONF003_TAG008;} //ServiceMax Configuration Settings Help
    public String getTAG010(){ return System.Label.CONF003_TAG010;} //Review all error messages below and click save
    public String getTAG011(){ return System.Label.CONF003_TAG011;} //Save:
    public String getTAG012(){ return System.Label.CONF003_TAG012;} //Record saved sucessfully
    public String getTAG013(){ return System.Label.CONF003_TAG013;} //Delete:
    public String getTAG014(){ return System.Label.CONF003_TAG014;} //Record sucessfully deleted
    public String getTAG015(){ return System.Label.CONF003_TAG015;} //Please select a Module You must select a Module in order to delete
    public String getTAG016(){ return System.Label.CONF003_TAG016;} //You must enter a value
    public String getTAG017(){ return System.Label.CONF003_TAG017;} //You must select a value 
    public String getTAG018(){ return System.Label.CONF003_TAG018;} //No records to display
    public String getTAG019(){ return System.Label.CONF003_TAG019;} //Invalid Data
    public String getTAG020(){ return System.Label.CONF003_TAG020;} //Requesting...
    public String getTAG021(){ return System.Label.CONF003_TAG021;} //'Action'
    public String getTAG022(){ return System.Label.CONF003_TAG022;} //--None--
    public String getTAG023(){ return System.Label.CONF003_TAG023;} //Select modules
    public String getTAG024(){ return System.Label.CONF003_TAG024;} //Select Submodules
    public String getTAG025(){ return System.Label.CONF003_TAG025;} //Submodules
    
    //Neeraj(16-02-2012): Added to solve translation related issues.
    public String getTAG026(){ return System.Label.CONF003_TAG026;} //'Setting ID' 
    public String getTAG027(){ return System.Label.CONF003_TAG027;} //'Setting Name' 
    public String getTAG028(){ return System.Label.COMM001_TAG017;} //'Description' 
    public String getTAG029(){ return System.Label.CONF003_TAG028;} //'Data Type' 
    public String getTAG030(){ return System.Label.CONF003_TAG029;} //'Default Value' 
    public String getTAG031(){ return System.Label.CONF003_TAG030;} //'Setting Type' 
    public String getTAG032(){ return System.Label.CONF003_TAG031;} //'Search Order' 
    
    public String getHLPURL() {return System.Label.CONF003_HLPURL;}
    
    //======================================== Constructure call ===================================================//  
    public CONF_ManageSettings(){
        subModuleOpts.add(new SelectOption(getTAG022(),getTAG022()));
        Module = [Select  SVMXC__Name__c,SVMXC__ModuleID__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c = 'Module' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        onLoad();
    }
    public void onLoad() {
        if(Sid!=NULL)
        {
            moduleView=Mid;
            onSelectMod();
            submoduleView=Sid;
            onSelectSubmod();
        }
    }
    Public String moduleView {get{if(Mid!=null && isLaunch==true){return Mid;}else {return moduleView;}}set;}
    Public String submoduleView {get{if(Sid!=null && isLaunch==true){return Sid;}else {return submoduleView;}} set;}
    //Public String moduleView {get;set;}
    //Public String submoduleView {get;set;}
    Public String submoduleId {get;set;}
    
    public String getSid() {return Sid;  }
    public String getMid() {return Mid;  }
    //======================================== Counts custom records ===================================================//
    public boolean getIsStdAvail(){
        boolean avail=false;
        if(stdSize>0)
            avail=true;
        return avail;
    }
    
    public boolean getIsCustAvail(){
        boolean avail=false;
        if(custSize>0 || isAdd==true)
            avail=true;
        return avail;
    }
    //======================================== Identify Record Ids ===================================================//
    public RecordType getEstRecordTypes(){
        RecordType erTypes;
        String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Processes__c\' and Name=\'Settings\'';       
        erTypes = Database.query(SOQL);      
        return erTypes;
    }
    public RecordType getProfEstRecordTypes(){
        RecordType erTypes;
        String SOQL  = 'SELECT Id,Name  FROM RecordType where SobjectType  =\'SVMXC__ServiceMax_Config_Data__c\' and Name=\'Setting Value\'';       
        erTypes = Database.query(SOQL);        
        return erTypes;
    }
    
    //======================================== Module Selection functions ===================================================// 
    public PageReference onSelectMod() {
        submoduleView=getTAG022();
        DisplaySettings=false;
        submodule = [Select SVMXC__SubmoduleID__c, SVMXC__Name__c From SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Submodule' and SVMXC__Module__r.Id = :moduleView order by SVMXC__SubmoduleID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('zzzzzzzz'+submodule);
        system.debug('zzzzzzzz1'+moduleView);
        system.debug('zzzzzzzz2----'+submodule.size());
        subModuleOpts.clear();
        subModuleOpts.add(new SelectOption(getTAG022(),getTAG022()));
        If(submodule.size()>0){ 
            for(Integer i = 0; i < submodule.size();i++){
                subModuleOpts.add(new SelectOption(submodule[i].Id,submodule[i].SVMXC__Name__c));
            }
        }
        return null;
    }  
    public PageReference onSelectSubmod() {
        try{
            isLaunch=false;
            DisplaySettings=true;
            isAdd=false;
            
            serviceMaxConfData= [Select SVMXC__Description__c, SVMXC__SettingID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Select__c, //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                 SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Settings' 
                                 and SVMXC__IsStandard__c=true and SVMXC__IsPrivate__c=false and SVMXC__Submodule__r.Id = :submoduleView order by SVMXC__SettingID__c];
            stdSize=serviceMaxConfData.size();          
            
            cust_serviceMaxConfData = [Select Name, SVMXC__Description__c, SVMXC__SettingID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Select__c, //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                       SVMXC__Setting_Type__c, SVMXC__Search_Order__c, Default_Value__c, Values__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Settings' 
                                       and SVMXC__IsStandard__c=false  and SVMXC__IsPrivate__c=false and SVMXC__Submodule__r.Id = :submoduleView order by SVMXC__SettingID__c];
            custSize=cust_serviceMaxConfData.size();
            if(submoduleView==getTAG022())
                DisplaySettings=false;
            return null;
        }catch(Exception e){ return null;}
    }
    
    //======================================== Setting Initial Checklist status ===================================================//
    
    public Boolean getCheckAllLines() {return CheckAllLines;  }
    public void setCheckAllLines(Boolean chkAll){CheckAllLines=chkAll;}
    
    //======================================== Set true to display blocklevel messges ===================================================//
    
    public Boolean getDisplaySettings(){ return DisplaySettings; }     
    public Boolean getDisplayBlockLevelMessage(){ return DisplayBlockLevelMessage; }  
    
    //========================================= Function : Selecting & Returning Modules Values =============================================//
    public List<SelectOption> getModule()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(getTAG022(),getTAG022()));
        If(module.size()>0){ 
            for(Integer i = 0; i < module.size();i++){
                options.add(new SelectOption(Module[i].Id,Module[i].SVMXC__Name__c));
            }
        }
        return options;
    }
    
    //========================================= Function : Selecting & Returning SubModules Values =============================================//
    public List<SelectOption> getSubModule(){
        return subModuleOpts;
    } 
    //========================================= Function : Return PopUp URL =============================================//
    public String getPopUpLink(){
        String url;
        if(svmxSettingList.containsKey('SET002') == true) url =svmxSettingList.get('SET002');
        return url;
    } 
    //========================================= Function : Lists Standard Setting Values =============================================//
    public List<SVMXC__ServiceMax_Processes__c> getSMXStdSettings(){
        return serviceMaxConfData;
    }
    //========================================= Function : Lists Custom Setting Values =============================================//
    public List<SVMXC__ServiceMax_Processes__c> getSMXCustSettings(){
        return cust_serviceMaxConfData;
    }
    
    //======================================== Function to check whether the data is valid for custom modules ===================================================//
    public Boolean isValidData(String OpType){
        List<SVMXC__ServiceMax_Processes__c> tempCustomSettings = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> tempCustomProfiles = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<Integer> selectedLines = new List<Integer>();
        
        Integer i;  
        boolean error=false;
        if(cust_serviceMaxConfData.size()==0){
            error=true;
        }
        for (i=0;i<cust_serviceMaxConfData.size();i++)
        {
            if(cust_serviceMaxConfData.get(i).SVMXC__Select__c==false || OpType=='Save')
            {
                tempCustomSettings.add(cust_serviceMaxConfData.get(i));
                if (cust_serviceMaxConfData.get(i).SettingID__c==null && OpType!='Del'){
                    error=true;
                    cust_serviceMaxConfData.get(i).SettingID__c.addError(getTAG016());
                }
                if (cust_serviceMaxConfData.get(i).Settings_Name__c==null && OpType!='Del'){
                    error=true;
                    cust_serviceMaxConfData.get(i).Settings_Name__c.addError(getTAG016());
                }
                if (cust_serviceMaxConfData.get(i).Data_Type__c==null && OpType!='Del'){
                    error=true;
                    cust_serviceMaxConfData.get(i).Data_Type__c.addError(getTAG017());
                }
                if (cust_serviceMaxConfData.get(i).Setting_Type__c==null && OpType!='Del'){
                    error=true;
                    cust_serviceMaxConfData.get(i).Setting_Type__c.addError(getTAG017());
                }
                if (cust_serviceMaxConfData.get(i).Search_Order__c==null && OpType!='Del'){
                    error=true;
                    cust_serviceMaxConfData.get(i).Search_Order__c.addError(getTAG017());
                }
            }
            else
            {
                selectedLines.add(i);
                if(cust_serviceMaxConfData.get(i).Id!=NULL)
                    deleteCustomSettings.add(cust_serviceMaxConfData.get(i));
            }
        }
        
        for (i=0;i<deleteCustomSettings.size();i++)
        {
            tempCustomProfiles=[Select Id From SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Setting Value' and SVMXC__Setting_ID__c = :cust_serviceMaxConfData.get(i).Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            //if(tempCustomProfiles.size() >0)delete tempCustomProfiles; //commented for fixing security scanner issues
            if(tempCustomProfiles.size() >0){
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c'))
                    delete tempCustomProfiles; //SDL-SVMX-DELETE-FLS-ENFORCED
                else{
                    DisplayBlockLevelMessage = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));               
                    return null;
                }
            }
        }
        
        try{
            //if(deleteCustomSettings.size() >0)delete deleteCustomSettings; //commented for fixing security scanner issues
            if(deleteCustomSettings.size() >0){
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete deleteCustomSettings; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    DisplayBlockLevelMessage = true;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));               
                    return null;
                }
            }
        }
        catch (Exception ex){
            DisplayBlockLevelMessage = true;
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
        }
        cust_serviceMaxConfData.clear();
        deleteCustomSettings.clear();
        cust_serviceMaxConfData=tempCustomSettings;
        custSize=cust_serviceMaxConfData.size();
        
        if(selectedLines.size()==0 && OpType=='Del')
        {
            error=true;
        }
        return error;
    }
    
    //========================================= Function : Reset Default Values =============================================//
    public void ResetDef() {
        SVMXC__ServiceMax_Config_Data__c newProfLine;
        cust_serviceMaxConfDataType=[Select SVMXC__Data_Type__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Settings' and SVMXC__IsStandard__c=false  and SVMXC__IsPrivate__c=false and SVMXC__Submodule__r.Id = :submoduleView ]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Integer i;  
        Integer j;
        for (i=0;i<cust_serviceMaxConfDataType.size();i++)
        {
            for (j=0;j<cust_serviceMaxConfData.size();j++)
            {
                if(cust_serviceMaxConfData.get(j).Id==cust_serviceMaxConfDataType.get(i).Id && cust_serviceMaxConfData.get(j).Data_Type__c!=cust_serviceMaxConfDataType.get(i).Data_Type__c)
                {
                    cust_serviceMaxConfData.get(j).Default_Value__c='';
                    cust_serviceMaxConfData.get(j).Values__c='';
                    newProfLine = [SELECT SVMXC__Display_Value__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c='Setting Value' and SVMXC__Setting_ID__c=:cust_serviceMaxConfData[j].Id LIMIT 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    newProfLine.SVMXC__Display_Value__c='Default Value';
                    newProfLine.SVMXC__Internal_Value__c='Default Value';
                    DelMaxAccessBuf.add(newProfLine);
                }
            }
            
        }
        //if(DelMaxAccessBuf.size() >0)update DelMaxAccessBuf; //commented for fixing security scanner issues
        if(DelMaxAccessBuf.size() >0){
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(DelMaxAccessBuf[0], COMM_SecurityUtils.Access.Updateable)){
                update DelMaxAccessBuf; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        DelMaxAccessBuf.clear();
    }
    //========================================= Function : Lists Custom Setting Values =============================================//
    public PageReference AddNewSetting() {
        try{
            isAdd=true;
            boolean error=false;
            //error=isValidData();
            
            if (error==true){
                DisplayBlockLevelMessage = true;     
                return null;    
            }
            else{
                SVMXC__ServiceMax_Processes__c newListLine = new SVMXC__ServiceMax_Processes__c(RecordTypeId=SettingEstRecType,SVMXC__Module__c=moduleView,SVMXC__Submodule__c=submoduleView,SVMXC__Active__c=true);              
                cust_serviceMaxConfData.add(newListLine);
                createProf.add(newListLine);
                return null;
            }
        }catch(Exception e){ return null;}
        
    }
    
    //======================================== Action for saving the custom Setting changes ===================================================//
    public PageReference saveSet() {
        List<SVMXC__ServiceMax_Processes__c> tempcreateProf = new List<SVMXC__ServiceMax_Processes__c>();
        
        boolean error=false;
        error=isValidData('Save');
        Integer i;
        
        if(error==true){
            DisplayBlockLevelMessage = true; 
            //ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG019(),getTAG015()));      
            return null;    
        }
        else
        {
            try
            {
                for (i=0;i<createProf.size();i++)
                {
                    if(createProf.get(i).SVMXC__Select__c==false)
                    {
                        tempcreateProf.add(createProf.get(i));
                    }
                }
                
                //if(tempcreateProf.size() >0)insert tempcreateProf; //commented for fixing security scanner issues
                if(tempcreateProf.size() >0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(tempcreateProf[0], COMM_SecurityUtils.Access.Createable)){
                        insert tempcreateProf; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        DisplayBlockLevelMessage = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                
                for (i=0;i<tempcreateProf.size();i++){
                    serviceMaxProfConfData.clear(); 
                    if(tempcreateProf.get(i).Setting_Type__c=='Group'||tempcreateProf.get(i).Setting_Type__c=='User')
                        Profiles = [Select Id, SVMXC__Configuration_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Profile']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    else if(tempcreateProf.get(i).Setting_Type__c=='Global')
                    {
                        Profiles = [Select Id, SVMXC__Configuration_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Profile' and SVMXC__Configuration_Type__c='Global']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    }
                    if(tempcreateProf.get(i).Id!=NULL)
                    {
                        for(Integer j = 0; j < Profiles.size();j++){
                            if(Profiles[j].Id!=NULL){
                                SVMXC__ServiceMax_Config_Data__c newProfLine = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId=ProfEstRecType,SVMXC__Setting_Configuration_Profile__c=Profiles[j].Id,SVMXC__Display_Value__c='Default Value',SVMXC__Internal_Value__c='Default Value',SVMXC__Active__c=true,SVMXC__Setting_ID__c=tempcreateProf.get(i).Id);             
                                serviceMaxProfConfData.add(newProfLine);
                            }
                        }
                        //if(serviceMaxProfConfData.size() >0)insert serviceMaxProfConfData;
                        if(serviceMaxProfConfData.size() >0){
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(serviceMaxProfConfData[0], COMM_SecurityUtils.Access.Createable)){
                                insert serviceMaxProfConfData; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            }
                            else{
                                DisplayBlockLevelMessage = true;
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                                return null;
                            }
                        }
                    }
                    Profiles.clear();
                }
                ResetDef();
                //if(cust_serviceMaxConfData.size() >0)upsert cust_serviceMaxConfData; //commented for fixing security scanner issues
                if(cust_serviceMaxConfData.size() >0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(cust_serviceMaxConfData[0], COMM_SecurityUtils.Access.Upsertable )){
                        upsert cust_serviceMaxConfData; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        DisplayBlockLevelMessage = true;
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                
                //if(resetSeting.size() >0)update resetSeting;
                //resetSeting.clear();
                tempcreateProf.clear();
                createProf.clear();
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG011(),getTAG012())); 
            }
            catch (Exception ex){
                DisplayBlockLevelMessage = true;
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));      
            }
        }
        return null;
    }
    //======================================== Action for delete the custom Setting changes ===================================================//
    public PageReference delSet() {
        isAdd=false;
        boolean error=false;
        error=isValidData('Del');
        DisplayBlockLevelMessage = true; 
        if(error==true){
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG019(),getTAG015()));      
            return null;    
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG013(),getTAG014()));
        }
        return null;
    }
    //======================================== Action "Back To Setup Home" ===================================================//
    public PageReference GoSetupHome(){
        String url = '/';
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
    //======================================== Action "Back To SubModules" ===================================================//
    public PageReference GoSubMod(){
        String url = '/';
        if(svmxSettingList.containsKey('SET003') == true) url =svmxSettingList.get('SET003');
        PageReference Submod = new PageReference(url);
        Submod.setRedirect(true);
        return Submod;
    }
}