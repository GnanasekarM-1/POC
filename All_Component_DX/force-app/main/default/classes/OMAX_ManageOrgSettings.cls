public with Sharing class OMAX_ManageOrgSettings {
    
    public Boolean Iscustomerguy;
    public List<string> res;
    public string UNpassSec;
    public string Encs;
    public string Dcsvalue;
    public string SettingsRecordTypeId;
    public List<SVMXC__ServiceMax_Processes__c> settinglist = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> endPointUrlsetting = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Properties__c> SPsettinglist = new List<SVMXC__ServiceMax_Properties__c>();
    public map<string,SVMXC__ServiceMax_Properties__c> mapSPsettinglist = new map<string,SVMXC__ServiceMax_Properties__c>();
    public List<SVMXC__ServiceMax_Properties__c> SPsettinglistUpdated = new List<SVMXC__ServiceMax_Properties__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> SFMMapSettings = new List<SVMXC__ServiceMax_Config_Data__c>();
    public map<string, SVMXC__ServiceMax_Properties__c> mapSettingToSFMMap = new map<string, SVMXC__ServiceMax_Properties__c>();
    public String UserData;
    public String Pass;
    public String Stoken;
    public String SEmail;
    public String EEmail;
    public string orgid15bit = UserInfo.getOrganizationId();
    public Boolean sanorpro;
    public Boolean disablesubmit=false;
    public Boolean enablesubmitCancel=true;
    public Boolean Allfieldsfull=false;
    public Boolean checkNewdata=true;
    public Boolean wrongnorecords=false;
    public string unb;
    public string psb;
    public string stkb;
    public Boolean unfailed=false;
    public boolean isValidSPCredentials = false;
    public String EndpointURL_x;
    public Boolean getsanorpro()
    {
        return sanorpro;
    }
    
    public void setsanorpro(Boolean sp)
    {
        sanorpro = sp;
    }
    
    
    public String CustomDomainURL;
    public String getCustomDomainURL(){
        return CustomDomainURL;
    }
    
    public void setCustomDomainURL(String cd){
        CustomDomainURL = cd;
    }
    public String orgType{get; set;}
    Public String OPUserName{get; set;}
    Public String SPUserName{get; set;}
    Public String SPUsernameDatabase{get; set;}
    Public String SPPassDatabase{get; set;}
    Public String SPEndPointURL{get; set;}
    public boolean isOptimaxEnabled {get; set;}
    public boolean isSPEnabled {get; set;}  
    public boolean isOptiMaxSPEnabled{get; set;}    
    Public String strSelectedOptimizer{get; set;}   
    public List<SelectOption> lstOptimizer = new List<SelectOption>();
    public List<SelectOption> getlstOptimizer(){return lstOptimizer;}
    
    public List<SelectOption> lstOrgTypes = new List<SelectOption>();
    public List<SelectOption> getlstOrgTypes(){return lstOrgTypes;}
    public boolean isCustomDomainEnabled {get; set;}
    
    public map<string, String> mapOptimizationSetting = new map<string, String>();
    public List<SelectOption> lstSOGetAppointment{get;set;}
    public List<SelectOption> lstSOBookAppointment{get;set;}
    public List<SelectOption> lstSOBookJob{get;set;}
    public List<SelectOption> lstSOUpdateWO{get;set;}
    public string slctdGetAppointment{get;set;}
    public string slctdBookAppointment{get;set;}
    public string slctdBookJob{get;set;}
    public string slctdUpdateWO{get;set;}
    
    /* variables for new UI */
    public boolean isRenderNew{get;set;}
    public boolean isRenderEdit{get;set;}
    public boolean isRenderSave{get;set;}
    public boolean isRenderDelete{get;set;}
    public boolean isRendercancel{get;set;}
    public boolean isActive{get;set;}
    public boolean isDefault{get;set;}
    public boolean isDisableSelect{get;set;}
    public boolean isSuccess{get;set;}
    public List<SPInstanceDataWrapper> lstSPInstanceDataWrap = new List<SPInstanceDataWrapper>();
    public List<SPInstanceDataWrapper> getlstSPInstanceDataWrap(){ return this.lstSPInstanceDataWrap;}
    public void setlstSPInstanceDataWrap(List<SPInstanceDataWrapper> value){ this.lstSPInstanceDataWrap = value; }
    public String StrDelIndex {get; set;}
    public List<SPInstanceDataWrapper> lstSPInstanceDataWrapDel = new List<SPInstanceDataWrapper>();
    
    public Integer getlstSPInstanceDataWrapSize(){return lstSPInstanceDataWrap.size();}
    
    public OMAX_ManageOrgSettings ()
    {
        try
        {
            isOptimaxEnabled = false;
            isSPEnabled = false;
            isOptiMaxSPEnabled = false;
            strSelectedOptimizer = '';
            CustomDomainURL = '';
            orgType = '';
            OPUserName = '';
            orgid15bit = orgid15bit.substring(0, 15);
            /*RefreshList();          
            ChecKOptimizerSetting();
            getSPCredentials();
            setDefaultValues();
            if(isSPEnabled){
                loadSpInstSetting();
            }*/
            
        }
        catch(Exception ex){
            
            System.debug(logginglevel.warn,'Exception in OMAX_ManageOrgSettings: '+ ex.getmessage());
            System.debug(logginglevel.warn,'Exception in OMAX_ManageOrgSettings: '+ ex.getstackTracestring());
        }
        
    }
    public void loadOMAX_ManageOrgSettings()
    {
        try
        {
            isOptimaxEnabled = false;
            isSPEnabled = false;
            isNewSPEnabled= false;
            isOptiMaxSPEnabled = false;
            strSelectedOptimizer = '';
            orgid15bit = orgid15bit.substring(0, 15);
            RefreshList();
            setParameterValue();
            ChecKOptimizerSetting();
            getSPCredentials();
            setDefaultValues();

            /*allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
            if((isNewSPEnabled) ){
                if((allSpSettings.get('SP_MIGRATED') == null)){
                    
                }else{
                    loadSpInstSetting();
                }
            }*/
            if(strSelectedOptimizer == 'Linx for Service Power'){
                isNewSPEnabled = true;
                loadSpInstSetting();
            } else if(strSelectedOptimizer == 'OptiMax Batch') {
                isOptimaxEnabled = true;
                loadOptimaxUI();
            }
            
        }
        catch(Exception ex){
            
            System.debug(logginglevel.warn,'Exception in loadOMAX_ManageOrgSettings: '+ ex.getmessage());
            System.debug(logginglevel.warn,'Exception in loadOMAX_ManageOrgSettings: '+ ex.getstackTracestring());
        }
        
    }
    
    public void setParameterValue(){
        Map<String, String> paramMap = System.currentPageReference().getParameters();
        String value = '';
        isSuccess = false;

        if(paramMap != null && paramMap.size()>0){
            value = paramMap.get('isSuccess');
            isSuccess = (value == null) ? false : Boolean.valueOf(value);
            strSelectedOptimizer = 'OptiMax Batch';
        }
        if(isSuccess){
            //saveOptiMaxCredentials();
            SEmail = paramMap.get('smail');
            EEmail = paramMap.get('email');
            OPUserName = paramMap.get('uname');
            if(paramMap.get('org').equalsIgnoreCase('prod')){
                orgType = 'Production';
            }else if(paramMap.get('org').equalsIgnoreCase('sandbox')){
                orgType = 'Sandbox';
            }else if(paramMap.get('org').equalsIgnoreCase('custom')){
                orgType = 'CustomDomain';
            }
            
            if(orgType.equalsIgnoreCase('CustomDomain')){
                CustomDomainURL = paramMap.get('curl');
            }else{
                CustomDomainURL = '';
            }
            InsertOrUpdateRecords();
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, getTAG036()));
        } else if(paramMap != null && paramMap.size()>0 && 'false'.equals(value)){
            //clear the OAuth info that is already saved in the process Obj is OAuth is not successful
            //clearoAuthInfoFromProcess();
            //Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG037()+ ' \n' +getTAG012()));
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG037()));
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG012()));
        } else if(paramMap != null &&paramMap.size()>0 && 'none'.equals(value)){
            //
        }
        
        if(orgType.equalsIgnoreCase('CustomDomain')){
            isCustomDomainEnabled = true;
        }
    }
    
    public String getButtonValue() {
        
        String strValue = '';
        if(isSuccess) {
            strValue = getTAG034();
        } else {
            strValue = getTAG033();
        }
        return strValue;
    }

    public void setDefaultValues() {
        
        isRenderNew =true;
        isRenderEdit=true;
        isRenderSave=false;
        isRenderDelete=true;
        isRendercancel=false;
        isactive = true;
        isDefault = true;
        isDisableSelect = false;
    }
    
    public void newInstance() {
        
        isDisableSelect = true;
        
    }
    
    public void saveInstance() {
        
    }
    
    public void editInstance() {
        
    }
    
    public void deleteInstance() {
        
    }
    
    //Method to verify 
    private void ChecKOptimizerSetting()
    {
        
        SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
        
        list<string> settinglist = new list<string>();
        lstOptimizer.add(new SelectOption('--None--', '--None--'));
        settinglist.add('GBL007');
        settinglist.add('GBL022');
        settinglist.add('GBL023');
        mapOptimizationSetting = settings.SVMX_getSettingList('GLOB001',settinglist); 
        Set<String> providersSet = new Set<String>();
        if( mapOptimizationSetting.size() > 0 && mapOptimizationSetting.containsKey('GBL007') && mapOptimizationSetting.get('GBL007') == 'True' &&  mapOptimizationSetting.containsKey('GBL022'))
        {
            if(mapOptimizationSetting.get('GBL022') != null )
                for(String StrProvider : mapOptimizationSetting.get('GBL022').split(','))
                    providersSet.add(StrProvider.touppercase());

            if((providersSet.contains('SERVICEPOWER') || providersSet.contains('SERVICE POWER')) && providersSet.contains('OPTIMAX')) 
            {
                isOptiMaxSPEnabled  = true;
                isNewSPEnabled = false;
                lstOptimizer.add(new SelectOption('OptiMax Batch', system.label.OMAX001_TAG031));
                lstOptimizer.add(new SelectOption('Linx for Service Power', system.label.OMAX001_TAG032));
            }
            else if(providersSet.contains('SERVICEPOWER') || providersSet.contains('SERVICE POWER'))
            {
                isSPEnabled = true;
                isNewSPEnabled = true;
                lstOptimizer.add(new SelectOption('Linx for Service Power', system.label.OMAX001_TAG032));
                strSelectedOptimizer = 'Linx for Service Power';
            }
            else if(providersSet.contains('OPTIMAX') ) 
            {           
                isOptimaxEnabled = true;
                lstOptimizer.add(new SelectOption('OptiMax Batch', system.label.OMAX001_TAG031));
                strSelectedOptimizer = 'OptiMax Batch';
            }
            else
            {
                enablesubmitCancel=false;
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, system.label.OMAX001_TAG033));
            }
            
            if(isOptiMaxSPEnabled){
                isNewSPEnabled = false;
            }
            if(isSPEnabled){
                isNewSPEnabled = true;
            }
            
        }
        else
        {
            enablesubmitCancel=false;
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, system.label.OMAX001_TAG033));
        }
    }
    
    public void getFieldMapdata(){
        /*  INTF_ConfigSync confSync = new INTF_ConfigSync();
SFMMapSettings = confSync.getSettings(new set<string>(), new set<string>(), new set<string>{'DCON005_SET001', 'DCON005_SET002', 'DCON005_SET003', 'DCON005_SET004'}, '');

if(SFMMapSettings != null && SFMMapSettings.size() > 0){
for(SVMXC__ServiceMax_Config_Data__c SFMMap: SFMMapSettings){
mapSettingToSFMMap.put(SFMMap.SVMXC__Setting_Unique_ID__c, SFMMap);
if(SFMMap.SVMXC__Internal_Value__c != null && SFMMap.SVMXC__Internal_Value__c.length()>0){
if(SFMMap.SVMXC__Setting_Unique_ID__c == 'DCON005_SET001')
slctdGetAppointment = SFMMap.SVMXC__Internal_Value__c;
else if(SFMMap.SVMXC__Setting_Unique_ID__c == 'DCON005_SET002')
slctdBookAppointment = SFMMap.SVMXC__Internal_Value__c;
else if(SFMMap.SVMXC__Setting_Unique_ID__c == 'DCON005_SET003')
slctdBookJob = SFMMap.SVMXC__Internal_Value__c;
else if(SFMMap.SVMXC__Setting_Unique_ID__c == 'DCON005_SET004')
slctdUpdateWO = SFMMap.SVMXC__Internal_Value__c;
}
}
}
*/
        lstSOGetAppointment = new List<SelectOption>{new SelectOption('--None--','--None--')};
            lstSOBookAppointment = new List<SelectOption>{new SelectOption('--None--','--None--')};
                lstSOBookJob = new List<SelectOption>{new SelectOption('--None--','--None--')};
                    lstSOUpdateWO = new List<SelectOption>{new SelectOption('--None--','--None--')};
                        
                        for(SVMXC__ServiceMax_Processes__c pro: [select id, SVMXC__Target_Object_Name__c, SVMXC__MapID__c, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Object Mapping' AND (SVMXC__Target_Object_Name__c ='Offer_Appointment_Request' OR SVMXC__Target_Object_Name__c ='Appointment_Book_Request' OR SVMXC__Target_Object_Name__c ='Job_Book_Request' OR SVMXC__Target_Object_Name__c ='Update_Job_Request')]){
                            if(pro.SVMXC__Target_Object_Name__c == 'Offer_Appointment_Request')
                                lstSOGetAppointment.add(new SelectOption(pro.SVMXC__MapID__c,pro.SVMXC__Name__c));
                            if(pro.SVMXC__Target_Object_Name__c == 'Appointment_Book_Request')
                                lstSOBookAppointment.add(new SelectOption(pro.SVMXC__MapID__c,pro.SVMXC__Name__c));
                            if(pro.SVMXC__Target_Object_Name__c == 'Job_Book_Request')
                                lstSOBookJob.add(new SelectOption(pro.SVMXC__MapID__c,pro.SVMXC__Name__c));
                            if(pro.SVMXC__Target_Object_Name__c == 'Update_Job_Request')
                                lstSOUpdateWO.add(new SelectOption(pro.SVMXC__MapID__c,pro.SVMXC__Name__c));
                        } 
        
    }
    
    //retrieving SP credentials
    Public void getSPCredentials()
    {
        unfailed = false;
        SPsettinglist = [Select Name, SVMXC__Key__c, SVMXC__Value__c from SVMXC__ServiceMax_Properties__c where Name in ('SP001','SP002','SP003','SP004','SP005','SP006','SP007') ];    //SVMXC__ServiceMax_Properties__c
        
        for(SVMXC__ServiceMax_Properties__c setting :SPsettinglist)
        {
            if(setting.Name == 'SP001')
            {
                SPUserName = decryption2(setting.SVMXC__Value__c);                
            }
            
            else if(setting.Name == 'SP002')
                SPUsernameDatabase = decryption2(setting.SVMXC__Value__c);
            
            else if(setting.Name == 'SP003')
                SPPassDatabase = decryption2(setting.SVMXC__Value__c);
            else if(setting.Name == 'SP004')
                slctdGetAppointment = decryption2(setting.SVMXC__Value__c);
            
            else if(setting.Name == 'SP005')
                slctdBookAppointment = decryption2(setting.SVMXC__Value__c);
            
            else if(setting.Name == 'SP006')
                slctdBookJob = decryption2(setting.SVMXC__Value__c);
            
            else if(setting.Name == 'SP007')
                slctdUpdateWO = decryption2(setting.SVMXC__Value__c);
            mapSettingToSFMMap.put(setting.Name,setting);    
        }
        string str1 = 'GLOB001';
        string str2 = 'GBL023';
        
        //endPointUrlsetting = [SELECT Name, Id,SVMXC__Display_Value__c  FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c='Setting Value' And SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__SubmoduleID__c ='GLOB001' And SVMXC__Setting_ID__r.SVMXC__SettingID__c =: 'GBL023' AND SVMXC__Active__c = true];
        endPointUrlsetting = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'GLOB001_GBL023'}, '');
        
        if(mapOptimizationSetting.containsKey('GBL023') && mapOptimizationSetting.containsKey('GBL023') && mapOptimizationSetting.get('GBL023') != null)
            SPEndPointURL = mapOptimizationSetting.get('GBL023');
        System.debug(logginglevel.warn,'mapOptimizationSetting  '+mapOptimizationSetting);
        System.debug(logginglevel.warn,'SPEndPointURL  '+SPEndPointURL);
        getFieldMapdata();
        //WSCH_AuditLogger.finish();
        
    }
    //Based on the optimizer selected from the picklist in UI, set which Optimizer details to be displayed
    public void onChangeOfOptimizer()
    {
        system.debug(logginglevel.warn,'strSelectedOptimizer  '+strSelectedOptimizer);
        disablesubmit = false;
        showEditSPInst = false;
        if(strSelectedOptimizer == '--None--')
        {
            isOptimaxEnabled = false;
            isSPEnabled = false;
            isNewSPEnabled = false;
        }
        else if(strSelectedOptimizer == 'OptiMax Batch')
        {
            
            isOptimaxEnabled = true;
            isSPEnabled = false;
            isNewSPEnabled = false;
            loadOptimaxUI();
            system.debug(logginglevel.warn,'isOptimaxEnabled  '+isOptimaxEnabled);
        }
        else if(strSelectedOptimizer == 'Linx for Service Power')
        {
            isOptimaxEnabled = false;
            isSPEnabled = true;
            isNewSPEnabled = true;
            loadSpInstSetting();
            
        }
        
    }
    
        //Based on the org type selected, values will change
    public void onChangeOfOrgType()
    {
        system.debug(logginglevel.warn,'orgType  '+orgType);
        if(orgType.equalsIgnoreCase('CustomDomain'))
        {
            isCustomDomainEnabled = true;
            loadOptimaxUI();
            orgType = 'CustomDomain';
            system.debug(logginglevel.warn,'isCustomDomainEnabled  '+isCustomDomainEnabled);
        }else{
            isCustomDomainEnabled = false;
            //loadOptimaxUI();
            system.debug(logginglevel.warn,'isCustomDomainEnabled  '+isCustomDomainEnabled);
        }
        
    }
    
    public void loadOptimaxUI() {
        
        settinglist = [select id,SVMXC__SettingID__c,SVMXC__Settings_Name__c,SVMXC__Installation_Key__c,RecordTypeId,SVMXC__Default_Value__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' AND SVMXC__IsPrivate__c = true AND SVMXC__Setting_Type__c ='Global' AND SVMXC__SettingID__c in ('PS04','PS05','PS06','PS07','PS08','PS09')];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        lstOrgTypes.clear();
        lstOrgTypes.add(new SelectOption('--None--', '--None--'));
        lstOrgTypes.add(new SelectOption('Production', getTAG042()));
        lstOrgTypes.add(new SelectOption('Sandbox', getTAG043()));
        lstOrgTypes.add(new SelectOption('CustomDomain', getTAG044()));
        
        for(SVMXC__ServiceMax_Processes__c setting :settinglist)
        {
            if(setting.SVMXC__SettingID__c == 'PS04')
            {
                orgType = setting.SVMXC__Default_Value__c;
            }
            if(setting.SVMXC__SettingID__c == 'PS05')
                SEmail = setting.SVMXC__Default_Value__c;
            
            if(setting.SVMXC__SettingID__c == 'PS06')
                EEmail = setting.SVMXC__Default_Value__c;
                
            if(setting.SVMXC__SettingID__c == 'PS07')
            {
                if(setting.SVMXC__Default_Value__c=='false')
                    isSuccess = false;
                else
                    isSuccess = true;
            }
                            
            if(setting.SVMXC__SettingID__c == 'PS08')
                CustomDomainURL = setting.SVMXC__Default_Value__c;
                
            if(setting.SVMXC__SettingID__c == 'PS09')
                OPUserName = setting.SVMXC__Default_Value__c;
        }
    }
    
    public SVMXC.COMM_Utils_ManageSettings CommSettingsUtils = new SVMXC.COMM_Utils_ManageSettings();
    public Map<String, String> mapSVMXSettings = CommSettingsUtils.SVMX_getSettingList('OMAX001');
    
    //Retrive Optimax credentils
    public void RefreshList()
    {
        //settinglist = [select id,SVMXC__SettingID__c,SVMXC__Settings_Name__c,SVMXC__Installation_Key__c,RecordTypeId,SVMXC__Default_Value__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' AND SVMXC__IsPrivate__c = true AND SVMXC__Setting_Type__c ='Global' AND SVMXC__SettingID__c in ('PS01','PS02','PS03','PS04','PS05','PS06')];
        //commented the above query as we need only Org related settings only(sandbox or production)
        settinglist = [select id,SVMXC__SettingID__c,SVMXC__Settings_Name__c,SVMXC__Installation_Key__c,RecordTypeId,SVMXC__Default_Value__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' AND SVMXC__IsPrivate__c = true AND SVMXC__Setting_Type__c ='Global' AND SVMXC__SettingID__c in ('PS04','PS05','PS06','PS07','PS08','PS09')];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        /*if(settinglist.size()==6)
            checkNewdata = false;
        else
            checkNewdata = true;
        
        for(SVMXC__ServiceMax_Processes__c setting :settinglist)
        {
            if(setting.SVMXC__SettingID__c == 'PS01')
                UserData = decryption1(setting.SVMXC__Default_Value__c);
            
            if(setting.SVMXC__SettingID__c == 'PS02')
                Pass = decryption1(setting.SVMXC__Default_Value__c);
            
            if(setting.SVMXC__SettingID__c == 'PS03')
                Stoken = decryption1(setting.SVMXC__Default_Value__c);
            
            if(setting.SVMXC__SettingID__c == 'PS04')
            {
                if(setting.SVMXC__Default_Value__c=='false')
                    sanorpro = false;
                else
                    sanorpro = true;
            }
            if(setting.SVMXC__SettingID__c == 'PS05')
                SEmail = setting.SVMXC__Default_Value__c;
            
            if(setting.SVMXC__SettingID__c == 'PS06')
                EEmail = setting.SVMXC__Default_Value__c;
        }*/
        //system.debug('sanorpro before refresh - ' + sanorpro);
        if(settinglist.size()==6)
            checkNewdata = false;
        else
            checkNewdata = true;
        
        for(SVMXC__ServiceMax_Processes__c setting :settinglist)
        {
            if(setting.SVMXC__SettingID__c == 'PS04')
            {
                orgType = setting.SVMXC__Default_Value__c;
            }
            
            if(setting.SVMXC__SettingID__c == 'PS05')
                SEmail = setting.SVMXC__Default_Value__c;
            
            if(setting.SVMXC__SettingID__c == 'PS06')
                EEmail = setting.SVMXC__Default_Value__c;
                
            if(setting.SVMXC__SettingID__c == 'PS07')
            {
                if(setting.SVMXC__Default_Value__c=='false')
                    isSuccess = false;
                else
                    isSuccess = true;
            }
            
            if(setting.SVMXC__SettingID__c == 'PS08')
                CustomDomainURL = setting.SVMXC__Default_Value__c;
                            
            if(setting.SVMXC__SettingID__c == 'PS09')
                OPUserName = setting.SVMXC__Default_Value__c;
        }
        //system.debug('sanorpro after refresh - ' + sanorpro);
    }
    
    //Tags Related code
    SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
    //public Map<String, String> svmxTagList = commUtil.SVMX_getTagList('OMAX001');
    
    //getters and setters 
    public String getUser(){
        return UserData;
    }
    
    public void setUser(String uname){
        UserData= uname;
        unb = uname;
    }
    
    public PageReference Cancel(){
        String url = '/';
        //if(mapSVMXSettings.containsKey('SET010') == true) url=mapSVMXSettings.get('SET010');
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        if(mapSVMXSettings.containsKey('SET010') == true){
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url=mapSVMXSettings.get('SET010');
            }
        }
        //Changes done by Nidhi ends here
        PageReference HomePage = new PageReference(url);
        HomePage.setRedirect(true);
        return HomePage; 
    }
    
    public String getpass(){
        return pass;
    }
    
    public void setpass(String p){
        pass=p;
        psb=p;
    }
    
    public String getStoken(){
        return Stoken;
    }
    
    public void setStoken(String s){
        Stoken = s;
        stkb=s;
    }
    
    public String getSEmail(){
        return SEmail;
    }
    
    public void setSEmail(String se){
        SEmail = se;
    }
    
    public String getEEmail(){
        return EEmail;
    }
    
    public void setEEmail(String ee){
        EEmail = ee;
    }
    
    //Encryption
    public String Encryption(String ups){
        UNpassSec = ups;
        res=UNpassSec.split('');
        for(integer k=1;k<res.size();k++)
        {
            if(Encs!=NULL)
            {
                Integer remainder = math.mod(k, 2);
                if(remainder==0)
                    Encs=Encs+res[k]+'oMlcUstUdDnNdDuTSuCLmO'+UserInfo.getOrganizationId();
                else
                    Encs=Encs+res[k]+UserInfo.getOrganizationId();
            }
            else
                Encs=res[k]+UserInfo.getOrganizationId();
        }
        return Encs;
    }
    //Method to encrypt Data
    public static String encryption1(String normalstr)
    {
        string Encrypteddata = EncodingUtil.base64Encode(Blob.valueOf(normalstr));
        return Encrypteddata;
    }
    //Method to decrypt encrypted data by encryption1
    public String decryption1(String Encstr)
    {
        String Decodeddata;
        try{
            if(unfailed==true)
                Decodeddata=Encstr;
            else{
                blob Decodeblob = EncodingUtil.base64Decode(Encstr);
                Decodeddata = Decodeblob.toString();
            }
        }
        catch(Exception ex){
            unfailed=true;
            Decodeddata = Encstr;
            System.debug(logginglevel.warn,'Exception in decryption1 '+ ex);
        }
        return Decodeddata;
    }
    
    //Method to decrypt encrypted data by encryption1
    public static String decryption2(String Encstr)
    {
        String Decodeddata;
        try{
            
            blob Decodeblob = EncodingUtil.base64Decode(Encstr);
            Decodeddata = Decodeblob.toString();
        }
        catch(Exception ex){
            Decodeddata = Encstr;
            WSCH_AuditLogger.debug('OMAX_ManageOrgSettings : decryption2 - ' + ex.getMessage());
            WSCH_AuditLogger.debug('OMAX_ManageOrgSettings : Encstr - ' + Encstr);
        }
        return Decodeddata;
    }
    //Decryption
    public String Decryption(String Decr){
        Dcsvalue = Decr;
        Dcsvalue=Dcsvalue.ReplaceAll(UserInfo.getOrganizationId(),'');
        Dcsvalue=Dcsvalue.Replace('oMlcUstUdDnNdDuTSuCLmO','');
        return Dcsvalue;
    }
    
    private string getInstallKey()
    {
        try
        {
            return EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15) )); //// + '~' + String.valueOf(date.Today()
        }
        catch(exception ex){System.debug(logginglevel.warn,'Exception in getInstallKey '+ ex);}
        return '';
    }
    
    
    Id SetingValRecTypeSet = RecordTypeId('Settings').Id;
    public RecordType RecordTypeId(String recTypeName){
        RecordType rType;
        String SOQL  = 'SELECT Id,Name FROM RecordType where SobjectType = \'SVMXC__ServiceMax_Processes__c\' and Name=\''+recTypeName+'\'';
        rType = Database.query(SOQL);
        return rType;
    }
    //Method to save Optimax and SP credentials Based on the optimizers enabled
    public void Submit() {
        
        System.debug(logginglevel.warn,'strSelectedOptimizer  '+strSelectedOptimizer);
        //save both SP and Optimax if both settings are enabled
        if(isOptiMaxSPEnabled  == true)
        {
            
            if(strSelectedOptimizer == 'OptiMax Batch')
                saveOptiMaxCredentials();
            else if(strSelectedOptimizer == 'Linx for Service Power')
                UpdateSPCredentials();
            else
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, system.label.OMAX001_TAG037));
            
            
        }
        else if(isSPEnabled)
        {
            //save SP and Optimax if both settings are enabled
            UpdateSPCredentials();
        }
        else if(isOptiMaxEnabled)
        {
            saveOptiMaxCredentials();
        }
        
    }
    
    //Authenticate via OAUTH
    public PageReference Authenticate() {
        system.debug('Authentication test');
        //saveOptiMaxCredentials();
        OPUserName = UserInfo.getName();
        //InsertOrUpdateRecords();
        
        PageReference pr ;
        String optimaxUrl = null;
        Allfieldsfull = false;
        if(((SEmail!='')&&(SEmail!=null))&&((EEmail!='')&&(EEmail!=null))&&(!orgType.equalsIgnoreCase('--none--')))
        {
            if(orgType.equalsIgnoreCase('CustomDomain')){
                if((CustomDomainURL!='')&&(CustomDomainURL!=null)){
                    Allfieldsfull=true;
                }
            }else{
                Allfieldsfull=true;
            }           
        }
        System.debug('Allfieldsfull value is : '+Allfieldsfull);
        if(Allfieldsfull == true){
        if(mapSVMXSettings.containsKey('GBL010') == true && mapSVMXSettings.get('GBL010') != NULL)
        {
            optimaxUrl = mapSVMXSettings.get('GBL010');
            String modifiedUrl = optimaxUrl.substring(0, optimaxUrl.indexOf(':', 7));
            System.debug('modifiedUrl: '+modifiedUrl);  
            /*if(sanorpro == true){
                //pr = new PageReference(modifiedUrl+':8083/OptimaxOauth/test?orgtype=sandbox');
                pr = new PageReference(modifiedUrl+':8083/OptimaxOauth/test?orgtype=sandbox&smail='+SEmail+'&email='+EEmail);
            }else if(sanorpro == false){
                //pr = new PageReference(modifiedUrl+':8083/OptimaxOauth/test?orgtype=prod');
                pr = new PageReference(modifiedUrl+':8083/OptimaxOauth/test?orgtype=prod&smail='+SEmail+'&email='+EEmail);
            }*/
            System.debug('orgType '+orgType);

            if(orgType.equalsIgnoreCase('Production')){
                pr = new PageReference(modifiedUrl+':8083/OptimaxOauth/test?orgtype=prod&smail='+SEmail+'&email='+EEmail+'&uname='+OPUserName);
            }else if(orgType.equalsIgnoreCase('Sandbox')){
                pr = new PageReference(modifiedUrl+':8083/OptimaxOauth/test?orgtype=sandbox&smail='+SEmail+'&email='+EEmail+'&uname='+OPUserName);
            }else if(orgType.equalsIgnoreCase('CustomDomain')){
                pr = new PageReference(modifiedUrl+':8083/OptimaxOauth/test?orgtype=custom&smail='+SEmail+'&email='+EEmail+'&uname='+OPUserName+'&customurl='+CustomDomainURL);
            }
            pr.setRedirect(true);
        }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG015()));
        }
        return pr;
    }
    
    //Insert or update process object
    public void InsertOrUpdateRecords()
    {
        if(((SEmail!=null)&&(SEmail!=''))&&((EEmail!='')&&(EEmail!=null))&&(!orgType.equalsIgnoreCase('--none--')))
        {
            Allfieldsfull=true;
        }

        if(Allfieldsfull==true)
        {
        try {
                System.debug(logginglevel.warn,'In InsertOrUpdateRecords');
    
                if(((settinglist.size()!=6) && (settinglist.size()>0)))
                {
                    wrongnorecords=true;
                    checkNewdata = true;
                }
                
                if(wrongnorecords==true)
                {
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){ //SDL-SVMX-DELETE-FLS-ENFORCED
                        Delete settinglist; 
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    }
                }
                    
                if(checkNewdata==true)
                {
                   Insertrecords();
                }
                
                if(checkNewdata==false)
                {
                    Updaterecords();
                }
        } catch(Exception ex) {
            System.debug(logginglevel.warn,'Exception in InsertOrUpdateRecords '+ ex+'Line No '+ex.getLineNumber()+'Stack  '+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, ex.getmessage()));
        }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG015()));
        }
    }
    
    
    //Save OptiMax Credentials and  other optimization related information
    public void saveOptiMaxCredentials()
    {   /*
        System.debug(logginglevel.warn,'In Save Optimax');
        //settings the endpoint url
        
        //Creating org parameters to send to organization in the form of list of organization parameters
        List<OMAX_ServicemaxCom.organizationParameter> OrgParameters = new List<OMAX_ServicemaxCom.organizationParameter>();
        // Here we check if the settings related to optimax are correct in no. or not
        //if(((settinglist.size()!=6) && (settinglist.size()>0)))
        if(((settinglist.size()!=2) && (settinglist.size()>0)))
        {
            wrongnorecords=true;
            //settinglist.clear();
            checkNewdata = true;
        }   
        //Jopt and other related settings list sent to webservice
        OMAX_ServicemaxCom.organizationParameter opSet001= new OMAX_ServicemaxCom.organizationParameter();
        opSet001.category='';
        opSet001.description='';
        opSet001.id=null;
        opSet001.paramName ='JOpt.Assisted'; 
        opSet001.paramValue = mapSVMXSettings.get('SET001'); //JOpt.Assisted
        OrgParameters.add(opSet001);
        
        OMAX_ServicemaxCom.organizationParameter opSet002= new OMAX_ServicemaxCom.organizationParameter();
        opSet002.category='';
        opSet002.description='';
        opSet002.id=null;
        opSet002.paramName ='JOpt.AssistedMode';
        opSet002.paramValue = mapSVMXSettings.get('SET002'); //JOpt.AssistedMode
        OrgParameters.add(opSet002);
        
        
        OMAX_ServicemaxCom.organizationParameter opSet003= new OMAX_ServicemaxCom.organizationParameter();
        opSet003.category='';
        opSet003.description='';
        opSet003.id=null;
        opSet003.paramName = 'JOpt.OptimizationRule';
        opSet003.paramValue = mapSVMXSettings.get('SET003'); //JOpt.OptimizationRule
        OrgParameters.add(opSet003);
        
        OMAX_ServicemaxCom.organizationParameter opSet004= new OMAX_ServicemaxCom.organizationParameter();
        opSet004.category='';
        opSet004.description='';
        opSet004.id=null;
        opSet004.paramName = 'JOptExitCondition.Type';
        String set4Val = mapSVMXSettings.get('SET004');
        if(set4Val!=null)
        { 
           set4Val = set4Val.replace('OptiMax', 'JOpt');
           opSet004.paramValue = set4Val; //JOptExitCondition.Type
        }
        
        OrgParameters.add(opSet004);
        
        OMAX_ServicemaxCom.organizationParameter opSet005= new OMAX_ServicemaxCom.organizationParameter();
        opSet005.category='';
        opSet005.description='';
        opSet005.id=null;
        opSet005.paramName = 'JOptExitCondition.Count';
        opSet005.paramValue = mapSVMXSettings.get('SET005'); //JOptExitCondition.Count
        OrgParameters.add(opSet005);
        
        OMAX_ServicemaxCom.organizationParameter opSet006= new OMAX_ServicemaxCom.organizationParameter();
        opSet006.category='';
        opSet006.description='';
        opSet006.id=null;
        opSet006.paramName = 'JOptExitCondition.JOptConvergencyCount';
        opSet006.paramValue = mapSVMXSettings.get('SET006'); //JOptExitCondition.JOptConvergencyCount
        OrgParameters.add(opSet006);
        
        OMAX_ServicemaxCom.organizationParameter opSet007= new OMAX_ServicemaxCom.organizationParameter();
        opSet007.category='';
        opSet007.description='';
        opSet007.id=null;
        opSet007.paramName = 'JOptExitCondition.JOptGenerationCount';
        opSet007.paramValue = mapSVMXSettings.get('SET007'); //JOptExitCondition.JOptGenerationCount
        OrgParameters.add(opSet007);
        
        OMAX_ServicemaxCom.organizationParameter opSet008= new OMAX_ServicemaxCom.organizationParameter();
        opSet008.category='';
        opSet008.description='';
        opSet008.id=null;
        opSet008.paramName = 'JOptWeight.Capacity';
        opSet008.paramValue = mapSVMXSettings.get('SET008'); //JOptWeight.Capacity
        OrgParameters.add(opSet008);
        
        OMAX_ServicemaxCom.organizationParameter opSet009= new OMAX_ServicemaxCom.organizationParameter();
        opSet009.category='';
        opSet009.description='';
        opSet009.id=null;
        opSet009.paramName ='JOptWeight.ResourceLoadBalance';
        opSet009.paramValue = mapSVMXSettings.get('SET009'); //JOptWeight.ResourceLoadBalance
        OrgParameters.add(opSet009);
        
        /*if(((UserData!='')&&(UserData!=null))&&((pass!='')&&(pass!=null))&&((Stoken!='')&&(Stoken!=null))&&((SEmail!='')&&(SEmail!=null))&&((EEmail!='')&&(EEmail!=null)))
        {
            Allfieldsfull=true;
        }*/
        //RefreshList();
        //settinglist = [select id,SVMXC__SettingID__c,SVMXC__Settings_Name__c,SVMXC__Installation_Key__c,RecordTypeId,SVMXC__Default_Value__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Settings' AND SVMXC__IsPrivate__c = true AND SVMXC__Setting_Type__c ='Global' AND SVMXC__SettingID__c in ('PS01','PS02','PS03','PS04','PS05','PS06')];
        //if(Allfieldsfull==true)
        /*{
            OMAX_ServicemaxCom.credential c = new OMAX_ServicemaxCom.credential();
            c.orgGuid = orgid15bit;
            OMAX_ServicemaxCom.OptimaxServicePort o = new OMAX_ServicemaxCom.OptimaxServicePort();
            OMAX_ServicemaxCom.organization org = new OMAX_ServicemaxCom.organization();
            org.organizationParameters=OrgParameters;
            org.userName = unb;
            org.password = psb;
            org.securityToken = stkb;
            org.errorEmailId = EEmail;
            org.successEmailId = SEmail;
            org.orgGUId = orgid15bit;
            if(sanorpro==true)
            {
               // org.endpointUrl = 'https://test.salesforce.com/services/Soap/u/14.0';
            }
            else
            {
                //org.endpointUrl = 'https://www.salesforce.com/services/Soap/u/14.0';
                org.endpointUrl = 'https://login.salesforce.com/services/Soap/u/14.0';
            }
            //Assumptions and calculation parameters
            org.lmo = false;
            org.lastUpdateOrgGuid = orgid15bit;
            org.orgStatus= 0;
            OMAX_ServicemaxCom.status s = new OMAX_ServicemaxCom.status();
            system.debug('oooooooo'+org);
            if(mapSVMXSettings.containsKey('GBL010') == true && mapSVMXSettings.get('GBL010') != NULL)
            {
                //o.endpoint_x=mapSVMXSettings.get('GBL010');
                try
                {
                    EndpointURL_x = mapSVMXSettings.get('GBL010');
                    HttpRequest req = new HttpRequest();
                    req.setMethod('GET');
                    req.setEndpoint(EndpointURL_x);
                    req.setTimeout(60000);//Added by amar on 30th Aug 2010
                    HttpResponse res = new Http().send(req);
                    
                    string loc = res.getHeader('Location');
                    system.debug('yyyyyyyy'+EndpointURL_x);
                    
                    if((loc != NULL)&&(loc != '')) { EndpointURL_x = loc; }
                    //o.endpoint_x = EndpointURL_x;
                    system.debug('OptiMax Endpoint Url'+o.endpoint_x);
                }
                catch(Exception ex){System.debug(logginglevel.warn,'Exception in saveOptiMaxCredentials '+ ex);ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, ex.getmessage()));}
            }
            
            try
            {
                o.endpoint_x = EndpointURL_x;
                s = o.OMAX_Org_Definition_WS(c,org,'Update','Enable');
                if(s.status=='SUCCESS')
                { 
                    if(wrongnorecords==true)
                    {
                        Delete settinglist;
                    }
                    if(checkNewdata==true)
                    {
                        system.debug('sanorpro before insert - ' + sanorpro);
                        Insertrecords();
                        system.debug('sanorpro after insert - ' + sanorpro);
                        //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Confirm, getTAG011()));
                        disablesubmit=true;
                    }
                    if(checkNewdata==false)
                    {
                        system.debug('sanorpro before update - ' + sanorpro);
                        Updaterecords();
                        system.debug('sanorpro after update - ' + sanorpro);
                        //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Confirm, getTAG011()));
                        disablesubmit=true;
                    }
                }
                else
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, getTAG012()));
            }
            catch(Exception ex)
            {
                System.debug(logginglevel.warn,'Exception in saveOptiMaxCredentials '+ ex+'Line No '+ex.getLineNumber()+'Stack  '+ex.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, ex.getmessage()));
            }
        //}
        //else
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG015()));
        */
    }
    
    //Retursn List of values sandbox and production to the page and hence forms a picklist there
    /*    public List<SelectOption> getOptions() {
List<SelectOption> opt = new List<SelectOption>();
opt.add(new SelectOption(getTAG009(),getTAG009()));
opt.add(new SelectOption(getTAG010(),getTAG010()));
return opt;
}*/
    
    public Boolean getdisablesubmit(){
        return disablesubmit;
    }
    public Boolean getenablesubmitCancel(){
        return enablesubmitCancel;
    }
    public Boolean getIscustomerguy(){
        return Iscustomerguy;
    }
    // Insert(Creating) OptiMax and  other optimization related information
    public void insertrecords()
    {
        List<SVMXC__ServiceMax_Processes__c> newsettinglist = new List<SVMXC__ServiceMax_Processes__c>();
        /*SVMXC__ServiceMax_Processes__c addsettingobj = new SVMXC__ServiceMax_Processes__c(); // username
        addsettingobj.RecordTypeId=SetingValRecTypeSet;
        addsettingobj.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj.SVMXC__SettingID__c = 'PS01';
        addsettingobj.SVMXC__Settings_Name__c=getTag020();
        addsettingobj.SVMXC__Default_Value__c=encryption1(UserData);
        addsettingobj.SVMXC__IsPrivate__c=true;
        addsettingobj.SVMXC__Setting_Type__c ='Global';
        addsettingobj.SVMXC__Description__c=getTag020();
        addsettingobj.SVMXC__Active__c=true;
        //List<SVMXC__ServiceMax_Processes__c> namelist = new List<SVMXC__ServiceMax_Processes__c>();
        newsettinglist.add(addsettingobj);
        
        SVMXC__ServiceMax_Processes__c addsettingobj1 = new SVMXC__ServiceMax_Processes__c(); //password
        addsettingobj1.RecordTypeId=SetingValRecTypeSet;
        addsettingobj1.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj1.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj1.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj1.SVMXC__SettingID__c = 'PS02';
        addsettingobj1.SVMXC__Settings_Name__c=getTag021();
        addsettingobj1.SVMXC__Default_Value__c=encryption1(Pass);
        addsettingobj1.SVMXC__IsPrivate__c=true;
        addsettingobj1.SVMXC__Setting_Type__c ='Global';
        addsettingobj1.SVMXC__Description__c=getTag021();
        addsettingobj1.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj1);
        
        SVMXC__ServiceMax_Processes__c addsettingobj2 = new SVMXC__ServiceMax_Processes__c(); //securityToken
        addsettingobj2.RecordTypeId=SetingValRecTypeSet;
        addsettingobj2.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj2.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj2.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj2.SVMXC__SettingID__c = 'PS03';
        addsettingobj2.SVMXC__Settings_Name__c=getTag022();
        addsettingobj2.SVMXC__Default_Value__c=encryption1(Stoken);
        addsettingobj2.SVMXC__IsPrivate__c=true;
        addsettingobj2.SVMXC__Setting_Type__c ='Global';
        addsettingobj2.SVMXC__Description__c=getTag022();
        addsettingobj2.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj2);
        
        SVMXC__ServiceMax_Processes__c addsettingobj3 = new SVMXC__ServiceMax_Processes__c(); //isSandbox
        addsettingobj3.RecordTypeId=SetingValRecTypeSet;
        addsettingobj3.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj2.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj2.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj3.SVMXC__SettingID__c = 'PS04';
        addsettingobj3.SVMXC__Settings_Name__c=getTag023();
        if(sanorpro==false)
            addsettingobj3.SVMXC__Default_Value__c='false';
        else
            addsettingobj3.SVMXC__Default_Value__c='true';
        addsettingobj3.SVMXC__IsPrivate__c=true;
        addsettingobj3.SVMXC__Setting_Type__c ='Global';
        addsettingobj3.SVMXC__Description__c= getTag023();
        addsettingobj3.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj3);
        
        SVMXC__ServiceMax_Processes__c addsettingobj4 = new SVMXC__ServiceMax_Processes__c(); //Success Email
        addsettingobj4.RecordTypeId=SetingValRecTypeSet;
        addsettingobj4.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj2.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj2.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj4.SVMXC__SettingID__c = 'PS05';
        addsettingobj4.SVMXC__Settings_Name__c=getTag024();
        addsettingobj4.SVMXC__Default_Value__c=SEmail;
        addsettingobj4.SVMXC__IsPrivate__c=true;
        addsettingobj4.SVMXC__Setting_Type__c ='Global';
        addsettingobj4.SVMXC__Description__c=getTag024();
        addsettingobj4.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj4);
        
        SVMXC__ServiceMax_Processes__c addsettingobj5 = new SVMXC__ServiceMax_Processes__c(); //Error Email
        addsettingobj5.RecordTypeId=SetingValRecTypeSet;
        addsettingobj5.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj2.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj2.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj5.SVMXC__SettingID__c = 'PS06';
        addsettingobj5.SVMXC__Settings_Name__c=getTag025();
        addsettingobj5.SVMXC__Default_Value__c=EEmail;
        addsettingobj5.SVMXC__IsPrivate__c=true;
        addsettingobj5.SVMXC__Setting_Type__c ='Global';
        addsettingobj5.SVMXC__Description__c=getTag025();
        addsettingobj5.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj5);*/
        
        //Just saving the the info if it is sandbox or not as this is OAuth implementation
        SVMXC__ServiceMax_Processes__c addsettingobj1 = new SVMXC__ServiceMax_Processes__c(); //orgType
        addsettingobj1.RecordTypeId=SetingValRecTypeSet;
        addsettingobj1.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj2.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj2.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj1.SVMXC__SettingID__c = 'PS04';
        addsettingobj1.SVMXC__Settings_Name__c=getTag023();
        addsettingobj1.SVMXC__Default_Value__c=orgType;
            
        addsettingobj1.SVMXC__IsPrivate__c=true;
        addsettingobj1.SVMXC__Setting_Type__c ='Global';
        addsettingobj1.SVMXC__Description__c= getTag023();
        addsettingobj1.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj1);
        
        SVMXC__ServiceMax_Processes__c addsettingobj3 = new SVMXC__ServiceMax_Processes__c(); //Success Email
        addsettingobj3.RecordTypeId=SetingValRecTypeSet;
        addsettingobj3.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj3.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj3.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj3.SVMXC__SettingID__c = 'PS05';
        addsettingobj3.SVMXC__Settings_Name__c=getTag024();
        addsettingobj3.SVMXC__Default_Value__c=SEmail;
        addsettingobj3.SVMXC__IsPrivate__c=true;
        addsettingobj3.SVMXC__Setting_Type__c ='Global';
        addsettingobj3.SVMXC__Description__c=getTag024();
        addsettingobj3.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj3);
        
        SVMXC__ServiceMax_Processes__c addsettingobj4 = new SVMXC__ServiceMax_Processes__c(); //Error Email
        addsettingobj4.RecordTypeId=SetingValRecTypeSet;
        addsettingobj4.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj4.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj4.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj4.SVMXC__SettingID__c = 'PS06';
        addsettingobj4.SVMXC__Settings_Name__c=getTag025();
        addsettingobj4.SVMXC__Default_Value__c=EEmail;
        addsettingobj4.SVMXC__IsPrivate__c=true;
        addsettingobj4.SVMXC__Setting_Type__c ='Global';
        addsettingobj4.SVMXC__Description__c=getTag025();
        addsettingobj4.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj4);
        
        SVMXC__ServiceMax_Processes__c addsettingobj2 = new SVMXC__ServiceMax_Processes__c(); //isSuccess - storing a boolean if OAuth is successfull
        addsettingobj2.RecordTypeId=SetingValRecTypeSet;
        addsettingobj2.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj2.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj2.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj2.SVMXC__SettingID__c = 'PS07';
        addsettingobj2.SVMXC__Settings_Name__c=getTAG038();
        if(isSuccess==false)
            addsettingobj2.SVMXC__Default_Value__c='false';
        else
            addsettingobj2.SVMXC__Default_Value__c='true';
        addsettingobj2.SVMXC__IsPrivate__c=true;
        addsettingobj2.SVMXC__Setting_Type__c ='Global';
        addsettingobj2.SVMXC__Description__c=getTag038();
        addsettingobj2.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj2);
        
        SVMXC__ServiceMax_Processes__c addsettingobj5 = new SVMXC__ServiceMax_Processes__c(); //Custom Domain URL
        addsettingobj5.RecordTypeId=SetingValRecTypeSet;
        addsettingobj5.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj5.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj5.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj5.SVMXC__SettingID__c = 'PS08';
        addsettingobj5.SVMXC__Settings_Name__c=getTag039();
        addsettingobj5.SVMXC__Default_Value__c=CustomDomainURL;
        addsettingobj5.SVMXC__IsPrivate__c=true;
        addsettingobj5.SVMXC__Setting_Type__c ='Global';
        addsettingobj5.SVMXC__Description__c=getTag039();
        addsettingobj5.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj5);  
        
        SVMXC__ServiceMax_Processes__c addsettingobj6 = new SVMXC__ServiceMax_Processes__c(); //Authenticated By User
        addsettingobj6.RecordTypeId=SetingValRecTypeSet;
        addsettingobj6.SVMXC__Installation_Key__c=getInstallKey();
        //addsettingobj6.SVMXC__Submodule__c=SubModuleobj.Id;
        //addsettingobj6.SVMXC__SubmoduleID__c='CUSTOMAX001';
        addsettingobj6.SVMXC__SettingID__c = 'PS09';
        addsettingobj6.SVMXC__Settings_Name__c=getTag040();
        addsettingobj6.SVMXC__Default_Value__c=OPUserName;
        addsettingobj6.SVMXC__IsPrivate__c=true;
        addsettingobj6.SVMXC__Setting_Type__c ='Global';
        addsettingobj6.SVMXC__Description__c=getTag040();
        addsettingobj6.SVMXC__Active__c=true;
        newsettinglist.add(addsettingobj6);         
        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(newsettinglist, COMM_SecurityUtils.Access.Createable)){ //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            insert newsettinglist;  
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
        }
    }
    // Updating OptiMax and  other optimization related information
    public void Updaterecords()
    {
        for(SVMXC__ServiceMax_Processes__c setting :settinglist)
        {
            /*if(setting.SVMXC__SettingID__c == 'PS01')
            {                       
                setting.SVMXC__Default_Value__c=encryption1(UserData);
            }
            
            if(setting.SVMXC__SettingID__c == 'PS02')
            {  
                setting.SVMXC__Default_Value__c=encryption1(Pass);
            }    
            if(setting.SVMXC__SettingID__c == 'PS03')
            {
                setting.SVMXC__Default_Value__c=encryption1(Stoken);
            }
            if(setting.SVMXC__SettingID__c == 'PS04')
            { 
                setting.SVMXC__Default_Value__c=String.Valueof(sanorpro);
            }
            if(setting.SVMXC__SettingID__c == 'PS05')
            {
                setting.SVMXC__Default_Value__c=SEmail;
            }
            if(setting.SVMXC__SettingID__c == 'PS06')
            { 
                setting.SVMXC__Default_Value__c=EEmail;
            }*/
            
            //Just updating the info if it is sandbox or not as this is OAuth implementation
            if(setting.SVMXC__SettingID__c == 'PS04')
            { 
                setting.SVMXC__Default_Value__c=orgType;
            }
            if(setting.SVMXC__SettingID__c == 'PS05')
            {
                setting.SVMXC__Default_Value__c=SEmail;
            }
            if(setting.SVMXC__SettingID__c == 'PS06')
            { 
                setting.SVMXC__Default_Value__c=EEmail;
            } 
            if(setting.SVMXC__SettingID__c == 'PS07')
            { 
                setting.SVMXC__Default_Value__c=String.Valueof(isSuccess);
            }           
            if(setting.SVMXC__SettingID__c == 'PS08')
            { 
                setting.SVMXC__Default_Value__c=CustomDomainURL;
            }
            if(setting.SVMXC__SettingID__c == 'PS09')
            { 
                setting.SVMXC__Default_Value__c=OPUserName;
            }
            setting.SVMXC__Installation_Key__c=getInstallKey();
        }
        update settinglist; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
    }
    // Validating SP Credentials by trying to login
    public boolean validateSPcredentials()
    {
        //this method returns true is login is successful else false
        try
        {
            return WSCH_Provider_SP_RealTimeOptimizer.loginToSP(SPUsernameDatabase,SPPassDatabase,SPUserName,SPEndPointURL);
        }
        catch(exception ex)
        {
            System.debug(logginglevel.warn,'Exception in UpdateSPCredentials '+ ex);
            throw ex;
        }
    }
    //Update SP Credentials
    public void UpdateSPCredentials(){
        /*try
        {
            if(String.isNotBlank(SPUsernameDatabase) && String.isNotBlank(SPEndPointURL) && String.isNotBlank(SPUserName) && String.isNotBlank(SPPassDatabase)){
                boolean isSaved = false;
                System.debug(logginglevel.warn,'endPointUrlsetting '+ endPointUrlsetting);
                if(endPointUrlsetting != null && endPointUrlsetting.size() > 0 )
                    isValidSPCredentials = validateSPcredentials();
                SPsettinglistUpdated = new List<SVMXC__ServiceMax_Properties__c>();
                System.debug(logginglevel.warn,'isValidSPCredentials '+ isValidSPCredentials);
                if(isValidSPCredentials)
                {
                    //Enrypting all SP credentials and Storing
                    SVMXC__ServiceMax_Properties__c ObjProperty ;
                    if(mapSettingToSFMMap.containskey('SP001'))
                    {
                        mapSettingToSFMMap.get('SP001').SVMXC__Value__c  = encryption1(SPUserName);
                        SPsettinglistUpdated.add(mapSettingToSFMMap.get('SP001'));
                    }
                    else
                    {
                        ObjProperty = new SVMXC__ServiceMax_Properties__c();
                        ObjProperty.Name = 'SP001';
                        ObjProperty.SVMXC__Key__c = 'ServicePower API User Name';
                        ObjProperty.SVMXC__Value__c  = encryption1(SPUserName);
                        SPsettinglistUpdated.add(ObjProperty);
                    }
                    if(mapSettingToSFMMap.containskey('SP002'))
                    {
                        mapSettingToSFMMap.get('SP002').SVMXC__Value__c  = encryption1(SPUsernameDatabase);
                        SPsettinglistUpdated.add(mapSettingToSFMMap.get('SP002'));
                    }
                    else
                    {
                        ObjProperty = new SVMXC__ServiceMax_Properties__c();
                        ObjProperty.Name = 'SP002';
                        ObjProperty.SVMXC__Key__c = 'ServicePower Database User Name';
                        ObjProperty.SVMXC__Value__c  = encryption1(SPUsernameDatabase);
                        SPsettinglistUpdated.add(ObjProperty);
                    }
                    if(mapSettingToSFMMap.containskey('SP003'))
                    {
                        mapSettingToSFMMap.get('SP003').SVMXC__Value__c  = encryption1(SPPassDatabase);
                        SPsettinglistUpdated.add(mapSettingToSFMMap.get('SP003'));
                    }
                    else
                    {
                        ObjProperty = new SVMXC__ServiceMax_Properties__c();
                        ObjProperty.Name = 'SP003';
                        ObjProperty.SVMXC__Key__c = 'ServicePower Password';
                        ObjProperty.SVMXC__Value__c  = encryption1(SPPassDatabase);
                        SPsettinglistUpdated.add(ObjProperty);
                    }
                    
                    updateSFMMapsInSettings();  
                    for (integer i=0; i<endPointUrlsetting.size();i++)
                    {
                        endPointUrlsetting[i].SVMXC__Display_Value__c = SPEndPointURL  ;
                        endPointUrlsetting[i].SVMXC__Internal_Value__c = SPEndPointURL  ;
                        endPointUrlsetting[i].SVMXC__Installation_Key__c = getInstallKey();
                    }
                    system.debug(logginglevel.warn,'SPsettinglistUpdated'+SPsettinglistUpdated);                
                    if(SPsettinglistUpdated.size()> 0&& endPointUrlsetting.size()>0)
                    {   
                        upsert SPsettinglistUpdated;                   
                        update endPointUrlsetting;  
                        isSaved = true; 
                    }   
                    
                    if(isSaved)
                    {
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Confirm, getTAG011()));
                        disablesubmit = true;
                    }                
                    else
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, system.label.OMAX001_TAG018));
                }
                else
                {
                    disablesubmit = false;
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, system.label.OMAX001_TAG036));
                    System.debug(logginglevel.warn,'isValidSPCredentials '+ isValidSPCredentials);
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,getTAG015()));
            }
        }
        catch(System.CalloutException ex)
        {
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, ex.getmessage()));
        }
        catch(Exception ex)
        {
            
            System.debug(logginglevel.warn,'Exception in UpdateSPCredentials '+ ex);
            System.debug(logginglevel.warn,'Exception in UpdateSPCredentials '+ ex.getStackTraceString());
            System.debug(logginglevel.warn,'Exception in UpdateSPCredentials '+ ex.getLineNumber());
            disablesubmit = false; 
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, ex.getmessage()));
            //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, system.label.OMAX001_TAG018));
        }*/
    }
    
    public void updateSFMMapsInSettings()
    {
        /*  if(mapSettingToSFMMap != null && mapSettingToSFMMap.size() > 0){
if(slctdGetAppointment != null && slctdGetAppointment.length() > 0 && slctdGetAppointment != '--None--')
mapSettingToSFMMap.get('DCON005_SET001').SVMXC__Internal_Value__c = slctdGetAppointment;
else
mapSettingToSFMMap.get('DCON005_SET001').SVMXC__Internal_Value__c = null;
if(slctdBookAppointment != null && slctdBookAppointment.length() > 0 && slctdBookAppointment != '--None--')
mapSettingToSFMMap.get('DCON005_SET002').SVMXC__Internal_Value__c = slctdBookAppointment;
else
mapSettingToSFMMap.get('DCON005_SET002').SVMXC__Internal_Value__c = null;
if(slctdBookJob != null && slctdBookJob.length() > 0 && slctdBookJob != '--None--')
mapSettingToSFMMap.get('DCON005_SET003').SVMXC__Internal_Value__c = slctdBookJob;
else
mapSettingToSFMMap.get('DCON005_SET003').SVMXC__Internal_Value__c = null;
if(slctdUpdateWO != null && slctdUpdateWO.length() > 0 && slctdUpdateWO != '--None--')
mapSettingToSFMMap.get('DCON005_SET004').SVMXC__Internal_Value__c = slctdUpdateWO;
else
mapSettingToSFMMap.get('DCON005_SET004').SVMXC__Internal_Value__c = null;

System.debug('Config data to update=: '+ mapSettingToSFMMap.values());

update mapSettingToSFMMap.values();

System.debug('Config data after update=: '+ mapSettingToSFMMap.values()); */
        system.debug(logginglevel.warn,'mapSettingToSFMMap'+mapSettingToSFMMap);    
        SVMXC__ServiceMax_Properties__c ObjProperty ;
        if(mapSettingToSFMMap.containskey('SP004'))
        {
            if(slctdGetAppointment != null && slctdGetAppointment.length() > 0 && slctdGetAppointment != '--None--')
                mapSettingToSFMMap.get('SP004').SVMXC__Value__c  =  encryption1(slctdGetAppointment);
            else
                mapSettingToSFMMap.get('SP004').SVMXC__Value__c  =  null;
            SPsettinglistUpdated.add(mapSettingToSFMMap.get('SP004'));
        }
        else
        {
            ObjProperty = new SVMXC__ServiceMax_Properties__c();
            ObjProperty.Name = 'SP004';
            ObjProperty.SVMXC__Key__c = 'ServicePower API Get Appointment';
            if(slctdGetAppointment != null && slctdGetAppointment.length() > 0 && slctdGetAppointment != '--None--')
                ObjProperty.SVMXC__Value__c  = encryption1(slctdGetAppointment);
            else
                ObjProperty.SVMXC__Value__c = null;
            SPsettinglistUpdated.add(ObjProperty);
        }
        if(mapSettingToSFMMap.containskey('SP005'))
        {
            if(slctdBookAppointment != null && slctdBookAppointment.length() > 0 && slctdBookAppointment != '--None--')
                mapSettingToSFMMap.get('SP005').SVMXC__Value__c  = encryption1(slctdBookAppointment);
            else
                mapSettingToSFMMap.get('SP005').SVMXC__Value__c   = null;
            SPsettinglistUpdated.add(mapSettingToSFMMap.get('SP005'));
        }
        else
        {
            ObjProperty = new SVMXC__ServiceMax_Properties__c();
            ObjProperty.Name = 'SP005';
            ObjProperty.SVMXC__Key__c = 'ServicePower API Book Appointment';
            if(slctdBookAppointment != null && slctdBookAppointment.length() > 0 && slctdBookAppointment != '--None--')
                ObjProperty.SVMXC__Value__c  = encryption1(slctdBookAppointment);
            else
                ObjProperty.SVMXC__Value__c   = null;
            SPsettinglistUpdated.add(ObjProperty);
        }
        if(mapSettingToSFMMap.containskey('SP006'))
        {
            if(slctdBookJob != null && slctdBookJob.length() > 0 && slctdBookJob != '--None--')
                mapSettingToSFMMap.get('SP006').SVMXC__Value__c = encryption1(slctdBookJob);
            else
                mapSettingToSFMMap.get('SP006').SVMXC__Value__c  = null;
            SPsettinglistUpdated.add(mapSettingToSFMMap.get('SP006'));
        }
        else
        {
            ObjProperty = new SVMXC__ServiceMax_Properties__c();
            ObjProperty.Name = 'SP006';
            ObjProperty.SVMXC__Key__c = 'ServicePower API Book Job';
            if(slctdBookJob != null && slctdBookJob.length() > 0 && slctdBookJob != '--None--')
                ObjProperty.SVMXC__Value__c = encryption1(slctdBookJob);
            else
                ObjProperty.SVMXC__Value__c  = null;
            SPsettinglistUpdated.add(ObjProperty);
        }
        if(mapSettingToSFMMap.containskey('SP007'))
        {
            if(slctdUpdateWO != null && slctdUpdateWO.length() > 0 && slctdUpdateWO != '--None--')
                mapSettingToSFMMap.get('SP007').SVMXC__Value__c = encryption1(slctdUpdateWO);
            else
                mapSettingToSFMMap.get('SP007').SVMXC__Value__c  = null;
            SPsettinglistUpdated.add(mapSettingToSFMMap.get('SP007'));
        }
        else
        {
            ObjProperty = new SVMXC__ServiceMax_Properties__c();
            ObjProperty.Name = 'SP007';
            ObjProperty.SVMXC__Key__c = 'ServicePower API Update Work Order';
            if(slctdUpdateWO != null && slctdUpdateWO.length() > 0 && slctdUpdateWO != '--None--')
                ObjProperty.SVMXC__Value__c = encryption1(slctdUpdateWO);
            else
                ObjProperty.SVMXC__Value__c  = null;
            SPsettinglistUpdated.add(ObjProperty);
        }
        
        system.debug(logginglevel.warn,'SPsettinglistUpdated'+SPsettinglistUpdated);                
        
    }
    
    public String getTAG011() {return system.label.OMAX001_TAG035;} //Dear Customer you have successfully Updated Your Details
    public String getTAG012() {return system.label.OMAX001_TAG012;}//Dear Customer you Details are Invalid, Please Contact your systems Administrator
    public String getTAG015() {return system.label.OMAX001_TAG015;}//INCOMPLETE DATA : Please enter data in all the fields and try again
    public String getTAG020() {return system.label.OMAX001_TAG020;}//parameter 1
    public String getTAG021() {return system.label.OMAX001_TAG021;}//parameter 2
    public String getTAG022() {return system.label.OMAX001_TAG022;}//parameter 3
    public String getTAG023() {return system.label.OMAX001_TAG023;}//parameter 4
    public String getTAG024() {return system.label.OMAX001_TAG024;}//parameter 5
    public String getTAG025() {return system.label.OMAX001_TAG025;}//parameter 6
    public String getTAG026() {return system.label.OMAX001_TAG038;}//'Override Default API Parameters with SFM Field Map';
    public String getTAG027() {return system.label.OMAX001_TAG039;}//'ServicePower API Names';
    public String getTAG028() {return system.label.OMAX001_TAG040;}//'SFM Field Map';
    public String getTAG029() {return system.label.OMAX001_TAG041;}//'Appointment Offer Request';
    public String getTAG030() {return system.label.OMAX001_TAG042;}//'Appointment Book Request';
    public String getTAG031() {return system.label.OMAX001_TAG043;}//'Job Book Request';
    public String getTAG032() {return system.label.OMAX001_TAG044;}//'Job Update Request';
    public String getTAG033() {return system.label.OMAX001_TAG045;}//'Authenticate';
    public String getTAG034() {return system.label.OMAX001_TAG046;}//'Re-Authenticate';
    public String getTAG035() {return system.label.OMAX001_TAG047;}//'Authenticated by: ';
    public String getTAG036() {return system.label.OMAX001_TAG048;}//'Oauth authentication is successful';
    public String getTAG037() {return system.label.OMAX001_TAG049;}//'Oauth authentication failed';
    public String getTAG038() {return system.label.OMAX001_TAG050;}//'parameter 7'; 
    public String getTAG039() {return system.label.OMAX001_TAG051;}//'parameter 8'; 
    public String getTAG040() {return system.label.OMAX001_TAG052;}//'parameter 9'; 
    
    public String getTAG041() {return system.label.OMAX001_TAG053;}//'Environment';
    public String getTAG042() {return system.label.OFFL013_TAG018;}//'Production';
    public String getTAG043() {return system.label.OFFL013_TAG019;}//'Sandbox';
    public String getTAG044() {return system.label.OMAX001_TAG054;}//'I have a custom Salesforce domain';
    public String getTAG045() {return system.label.OMAX001_TAG055;}//'Custom Domain';
        
    public String getProcessingText() { return system.label.COMM001_TAG041; } //Processing...
    
    /*public void HdrADDRow() {

WSCH_AuditLogger.debug('OMAX_ManageOrgSettings::Inside HdrADDRow2');
try {

WSCH_AuditLogger.debug(' Before if() LstTargetSourceMatchWrap.size() -- ' + lstSPInstanceDataWrap.size());
if(lstSPInstanceDataWrap.isEmpty()) {
WSCH_AuditLogger.debug(' Inside if() lstSPInstanceDataWrap.size() -- ' + lstSPInstanceDataWrap.size());
lstSPInstanceDataWrap.add(new SPInstanceDataWrapper(new SVMXC__ServiceMax_Config_Data__c(), 1) ); 
} else {
lstSPInstanceDataWrap.add(new SPInstanceDataWrapper(new SVMXC__ServiceMax_Config_Data__c(), Integer.valueOf(lstSPInstanceDataWrap.size() + 1)));
}
} catch(Exception ex) {
WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings::HdrADDRow(): ' + ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
}
WSCH_AuditLogger.finish(); 
}

public void HdrDeleteRow()
{
WSCH_AuditLogger.debug('OMAX_ManageOrgSettings::Inside HdrDeleteRow2()');
integer IntVal;           
IntVal = integer.valueOf(StrDelIndex);
WSCH_AuditLogger.debug('Inside HdrDeleteRow, IntVal val'+IntVal);
if(IntVal <= lstSPInstanceDataWrap.size())
{
WSCH_AuditLogger.debug('Inside HdrDeleteRow if(), lstSPInstanceDataWrap.size() - ' + lstSPInstanceDataWrap.size());
for(integer i=IntVal;i< lstSPInstanceDataWrap.size();i++)
{
SPInstanceDataWrapper cnfwrp = lstSPInstanceDataWrap.get(i);
//cnfwrp.objConf.SVMXC__Sequence__c = cnfwrp.objConf.SVMXC__Sequence__c-1;
//cnfwrp.targetSourceMatchConfig.SVMXC__Sequence__c = cnfwrp.Sequence - 1;
cnfwrp.instanceDataConfigObj.SVMXC__Sequence__c = cnfwrp.instanceDataConfigObj.SVMXC__Sequence__c - 1;
lstSPInstanceDataWrap.set(i,cnfwrp);
}
}
if(lstSPInstanceDataWrap != null && lstSPInstanceDataWrap.size() > 0)
{   
SVMXC__ServiceMax_Config_Data__c cnfobj1 = new SVMXC__ServiceMax_Config_Data__c();              
cnfobj1 = lstSPInstanceDataWrap.get(IntVal-1).instanceDataConfigObj;              
lstSPInstanceDataWrap.remove(IntVal-1);*/
    
    /*if(cnfobj1.id!=null)
lstSPInstanceDataWrapDel.add(cnfobj1);
*/
    /*}
if(IntVal <= lstSPInstanceDataWrap.size())    
{       
for(integer i = IntVal; i <= lstSPInstanceDataWrap.size(); i++ )
//LstCriWrap[i-1].objConf.SVMXC__Sequence__c = i;
//LstTargetSourceMatchWrap[i-1].Sequence = i;
lstSPInstanceDataWrap[i-1].instanceDataConfigObj.SVMXC__Sequence__c = i;
} 
WSCH_AuditLogger.debug('LstTargetSourceMatchWrap val'+lstSPInstanceDataWrap);   
WSCH_AuditLogger.finish();                
}*/
    
    /*public class SPInstanceDataWrapper {

public SVMXC__ServiceMax_Config_Data__c instanceDataConfigObj = new SVMXC__ServiceMax_Config_Data__c();
public Boolean selected {get; set;}
public Integer Sequence;
public Integer getSequence(){return Sequence;}
public void setSequence(Integer i){this.Sequence = i;}    

public SPInstanceDataWrapper(SVMXC__ServiceMax_Config_Data__c eachInstanceDataConfig, Integer iSeq) {

this.instanceDataConfigObj = eachInstanceDataConfig;
this.Sequence = iSeq;
}
}*/
    /*** @Multiple Instance BEGIN ***/
    //wrapper class for the settings value
    public class SPInstanceDataWrapper {
        
        public Boolean selected {get; set;}
        public String instName  {get; set;}
        public String instDescription  {get; set;}
        public Boolean isActive {get; set;}
        public Boolean isDefault {get; set;}
        
        public String instURL  {get; set;}
        public String instDbUserName  {get; set;}
        public String instUserName  {get; set;}
        public String instPwd  {get; set;}
        public String instGetAppt  {get; set;}
        public String instBookAppt  {get; set;}
        public String instBookJob  {get; set;}
        public String instUpdWO  {get; set;}
        //wrapper class constructor
        public SPInstanceDataWrapper(){
            this.instName = '';
            this.instDescription = '';
            this.selected = true;
            this.isActive = false;
            this.isDefault = false;
            this.instURL = '';
            this.instDbUserName = '';
            this.instUserName = '';
            this.instPwd = '';
            this.instGetAppt = '';
            this.instBookAppt = '';
            this.instBookJob = '';
            this.instUpdWO = '';
        }
    }
    //Method the getthe maximum number of SP Connections
    public Integer getMaxConnections(){
        SVMXC__ServiceMax_Properties__c instanceName = new SVMXC__ServiceMax_Properties__c();
        Integer tempConNum;
        MAX_SP_CONNECTIONS = 0;
        for(String strConNum: allSpSettings.keySet()){
            instanceName = allSpSettings.get(strConNum);
            if ('ServicePower Connection Name'.equalsIgnoreCase(instanceName.SVMXC__Key__c)){
                tempConNum = Integer.valueOf((instanceName.Name).right(2));
                //check if previous connection number is greater than previous
                If(MAX_SP_CONNECTIONS < tempConNum){
                    MAX_SP_CONNECTIONS = tempConNum;
                }
            }
        }
        return MAX_SP_CONNECTIONS;
    }
    //Method to get all the Sp COnnection Settings and map them to list of wrapper object.
    public List<SPInstanceDataWrapper> getSpInsSettings(){
        List<SPInstanceDataWrapper> lstRetSpSetting =  new List<SPInstanceDataWrapper>();
        SPInstanceDataWrapper spInstSet;
        mapInstNameNum= new Map<String, String>();
        allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
        SVMXC__ServiceMax_Properties__c instanceName = new SVMXC__ServiceMax_Properties__c();
        String strInstNum = '';
        try{
            if((allSpSettings != null) && (!allSpSettings.isEmpty())){
                //Get the Highest Instace  Number.
                //getMaxConnections() is used in case of delete scenario, where in when we delete the instance/row from the middle,
                //we do not lose out on the max instance count.
                MAX_SP_CONNECTIONS = getMaxConnections();
                //create a list of wrapper object from the Custom Settings.
                for(Integer instanceNumber=1;instanceNumber <= MAX_SP_CONNECTIONS; instanceNumber++){
                    strInstNum = getDoubleDigit(instanceNumber);
                    spInstSet = new SPInstanceDataWrapper();
                    instanceName = allSpSettings.get('SP_CON_00_' + strInstNum);
                    If(instanceName != null){
                        spInstSet.instName = allSpSettings.get('SP_CON_00_' + strInstNum).SVMXC__Value__c;
                        spInstSet.selected = false;
                        spInstSet.isActive = Boolean.valueOf(allSpSettings.get('SP_CON_01_' + strInstNum).SVMXC__Value__c);
                        spInstSet.isDefault = Boolean.valueOf(allSpSettings.get('SP_CON_02_' + strInstNum).SVMXC__Value__c);
                        spInstSet.instDescription = allSpSettings.get('SP_CON_03_' + strInstNum).SVMXC__Value__c;
                        spInstSet.instURL = allSpSettings.get('SP_CON_04_' + strInstNum).SVMXC__Value__c;
                        spInstSet.instDbUserName = decryption2(allSpSettings.get('SP_CON_05_' + strInstNum).SVMXC__Value__c);
                        spInstSet.instUserName = decryption2(allSpSettings.get('SP_CON_06_' + strInstNum).SVMXC__Value__c);
                        spInstSet.instPwd = decryption2(allSpSettings.get('SP_CON_07_' + strInstNum).SVMXC__Value__c);
                        spInstSet.instGetAppt = allSpSettings.get('SP_API_11_' + strInstNum).SVMXC__Value__c;
                        spInstSet.instBookAppt = allSpSettings.get('SP_API_12_' + strInstNum).SVMXC__Value__c;
                        spInstSet.instBookJob = allSpSettings.get('SP_API_13_' + strInstNum).SVMXC__Value__c;
                        spInstSet.instUpdWO = allSpSettings.get('SP_API_14_' + strInstNum).SVMXC__Value__c;
                        lstRetSpSetting.add(spInstSet);
                        mapInstNameNum.put(spInstSet.instName, strInstNum);
                    }
                }
            }else{
                WSCH_AuditLogger.ERROR('OMAX_ManageOrgSettings: getSpInsSettings: No Valid Connection Name');
                throw new WSCH_EXCEPTION('OMAX_ManageOrgSettings: getSpInsSettings: No Valid Connection Name');
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: getSpInsSettings() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        return lstRetSpSetting;
    }
    //This method migrates the Existing Settings to new Data Model.
    public void migrateSpSettings(){
        //allSpSettings = new Map<String, SVMXC__ServiceMax_Properties__c>();
        isMigrated = false;
        List<SVMXC__ServiceMax_Config_Data__c> lstConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstUpdConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstNewSPSettings = new List<SVMXC__ServiceMax_Properties__c>();
        String strGBL023 = '';
        try{
            allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
            //check if it has a single instance. i.e., old configuration of SP instance details
            if((allSpSettings != null) && (!allSpSettings.isEmpty())){
                strGBL023 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL023');
                //allSpSettings.get('SP_CON_00_01') == null is used to check if the new multiple instance configuration is not present for this org
                //If atleast there was a single connection as per the new datamodel then SP_CON_00_01 will have some connection info and won't be null.
                if((String.isNotBlank(strGBL023)) && (allSpSettings.get('SP_CON_00_01') == null)){
                    lstConfData = [SELECT  Id,
                                   Name,
                                   SVMXC__Active__c,
                                   SVMXC__IsDefault__c, 
                                   SVMXC__Description__c,
                                   SVMXC__Display_Value__c,
                                   SVMXC__Installation_Key__c
                                   FROM SVMXC__ServiceMax_Config_Data__c 
                                   WHERE (SVMXC__Setting_Unique_ID__c = 'GLOB001_GBL023')
                                   AND SVMXC__Active__c = true];        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    ///Copy Existing Data to New Data Model. Creating the new SP settings using the existing data as per the new data model
                    lstNewSPSettings = createSPSettings(1,
                                                        //'Default Connection' ,
                                                        System.label.DCON003_TAG082,
                                                        'true',
                                                        'true',
                                                        //'Existing Connection',
                                                        System.label.DCON003_TAG083,
                                                        strGBL023,
                                                        decryption2(allSpSettings.get('SP002').SVMXC__Value__c),
                                                        decryption2(allSpSettings.get('SP001').SVMXC__Value__c),
                                                        decryption2(allSpSettings.get('SP003').SVMXC__Value__c),
                                                        decryption2(allSpSettings.get('SP004').SVMXC__Value__c),
                                                        decryption2(allSpSettings.get('SP005').SVMXC__Value__c),
                                                        decryption2(allSpSettings.get('SP006').SVMXC__Value__c),
                                                        decryption2(allSpSettings.get('SP007').SVMXC__Value__c));
                    
                    if((lstNewSPSettings != null) && (!lstNewSPSettings.isEmpty())){
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstNewSPSettings, COMM_SecurityUtils.Access.Upsertable) ) {
                            //Database.upsert(lstNewSPSettings); // commenting due to CSRF security violation Feb 2017 - Anush
                        } else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }
                    }
                    
                    //Populate values on VF Page for inital load after migration
                    strInstName = System.label.DCON003_TAG082;
                    strInstURL = strGBL023;
                    strInstDBUserName = decryption2(allSpSettings.get('SP002').SVMXC__Value__c);
                    strInstUserName = decryption2(allSpSettings.get('SP001').SVMXC__Value__c);
                    strInstPwd = decryption2(allSpSettings.get('SP003').SVMXC__Value__c);
                    strInstDesc = System.label.DCON003_TAG083;
                    strInstGetAppt = decryption2(allSpSettings.get('SP004').SVMXC__Value__c);
                    strInstBookAppt = decryption2(allSpSettings.get('SP005').SVMXC__Value__c);
                    strInstBookJob = decryption2(allSpSettings.get('SP006').SVMXC__Value__c);
                    strInstUpdWO = decryption2(allSpSettings.get('SP007').SVMXC__Value__c);
                    boolIsActive = true;
                    boolIsDefault = true;
                    
                    /*SPInstanceDataWrapper spVFPInst = new SPInstanceDataWrapper();
                    spVFPInst.selected = true;
                    spVFPInst.instName = strInstName;
                    spVFPInst.isActive = true;
                    spVFPInst.isDefault = true;
                    lstSpInstanceSetting.add(spVFPInst);*/
                    
                    //De-Activate Existing Setting where the old GBL023 config data was stored
                    if(!lstConfData.isEmpty()){
                        for(SVMXC__ServiceMax_Config_Data__c spInst: lstConfData){
                            spInst.SVMXC__Description__c = 'This setting has been migrated on ' + String.valueOf(datetime.now());
                            //SET ACTIVE AS FALSE for the Existing Setting, so it is not fetched by WSCH_CommonUtils.getSettingValue
                            //spInst.SVMXC__Active__c = false;
                            spInst.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
                            lstUpdConfData.add(spInst);
                        }
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstUpdConfData, COMM_SecurityUtils.Access.Updateable) ) {
                            //Database.update(lstUpdConfData); // commenting due to CSRF security violation Feb 2017 - Anush//updating this old config data by marking SVMXC__Active__c as false
                        } else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        }
                    }
                    isMigrated = true;
                    lstUpdConfData.clear();
                    lstUpdConfData.clear();
                }
            }else{
                WSCH_AuditLogger.ERROR('OMAX_ManageOrgSettings: migrateSpSettings: No Valid Connection Name');
                throw new WSCH_EXCEPTION('OMAX_ManageOrgSettings: migrateSpSettings: No Valid Connection Name');
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: migrateSpSettings() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }
    public List<SPInstanceDataWrapper> lstSpInstanceSetting {get;set;}
    public String strInstName {get;set;}
    public String strInstDesc {get;set;}
    public String strInstURL {get;set;}
    public String strInstDBUserName {get;set;}
    public String strInstUserName {get;set;}
    public String strInstPwd {get;set;}
    public String strInstGetAppt {get;set;}
    public String strInstBookAppt {get;set;}
    public String strInstBookJob {get;set;}
    public String strInstUpdWO {get;set;}
    public Boolean boolIsActive {get;set;}
    public Boolean boolIsDefault {get;set;}
    public Boolean showListSPInst{get;set;}
    public Boolean showEditSPInst{get;set;}
    public Boolean isNewRecord{get;set;}
    public Boolean isMigrated{get;set;}
    public Boolean isNewSPEnabled{get;set;}
    public Boolean isFirstRecord{get;set;}
    public Map<String, SVMXC__ServiceMax_Properties__c> allSpSettings;
    public Map<String,String> mapInstNameNum;
    public Integer MAX_SP_CONNECTIONS;
    public static String strDefaultVar = 'ServicePower Connection Default';
    public static String strConnNameVar = 'ServicePower Connection Name';
    public static String strActiveVar = 'ServicePower Connection Active';
    public static String strConnUrlVar = 'ServicePower End Point URL';
    public Boolean boolIsOkToDereference;
    public Boolean boolIsDelete{get;set;}
    public Boolean boolIsEdit{get;set;}
    public Boolean boolShowOk{get;set;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstUpdConfData;
    public List<SVMXC__ServiceMax_Properties__c> lstNewSPSettings;
    
    //This method deletes or deactivates an instance after confirmation from User.
    public void confirmDelete(){
        boolIsOkToDereference = true;
        try{
            if(boolIsDelete){
                deleteSpInstSetting();
            }else if(boolIsEdit){
                saveSpInstSetting();
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: confirmDelete() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }
    //This method loads when User chooses ServicePower from the list of connectiuon types.
    //This method migrates the existing settings, then creates a list of wrapper to be displayed on VF Page.
    public void loadSpInstSetting(){
        showListSPInst = false;
        showEditSPInst = false;
        isNewRecord = false;
        isFirstRecord = false;
        boolIsOkToDereference=false;
        boolIsDelete = false;
        boolIsEdit = false;
        boolShowOk= false;
        isMigrated = false;
        try{
            lstSpInstanceSetting = new List<SPInstanceDataWrapper>();
            allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
            if((allSpSettings.get('SP_MIGRATED') == null)){
                migrateSpSettings();
            }
            lstSpInstanceSetting.addAll(getSpInsSettings());
            if(isMigrated && (lstSpInstanceSetting != null)){
                lstSpInstanceSetting[0].selected = true;
            }
            showListSPInst = (!lstSpInstanceSetting.isEmpty());
            showEditSPInst = (!lstSpInstanceSetting.isEmpty());
            //showEditSPInst = (isMigrated || (!lstSpInstanceSetting.isEmpty()));
            if(isMigrated){
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, System.label.DCON003_TAG089));
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: loadSpInstSetting() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }
    //This method checks that only one record if selected for EDITING, and enables the user to edit the values.
    public PageReference editSpInstSetting(){
        //declare & set boolean variable to control UI
        isNewRecord = false;
        isMigrated = false;
        Integer intEditCount =0;
        for(SPInstanceDataWrapper spInst: lstSpInstanceSetting){
            if(spInst.selected){
                intEditCount++;
                //showEditSPInst = true;
                boolIsEdit = true;
                strInstName = spInst.instName;
                strInstURL = spInst.instURL;
                strInstDBUserName = spInst.instDbUserName;
                strInstUserName = spInst.instUserName;
                strInstPwd = spInst.instPwd;
                strInstDesc = spInst.instDescription;
                strInstGetAppt = spInst.instGetAppt;
                strInstBookAppt = spInst.instBookAppt;
                strInstBookJob = spInst.instBookJob;
                strInstUpdWO = spInst.instUpdWO;
                boolIsActive = spInst.isActive;
                boolIsDefault = spInst.isDefault;
            }
        }
        if(intEditCount!=1){
            boolIsEdit = false;
            //Please select only one record to edit
            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, System.Label.CONF006_TAG020));
        }
        return null;
    }
    //This method saves the NEW or EDITED settings.
    public PageReference saveSpInstSetting(){
        Boolean boolNoError = true;
        Integer intSPConNum = 0;
        Integer intLstSize = 0;
        isMigrated = false;
        boolIsDelete = false;
        boolIsEdit = true;
        showEditSPInst = false;
        List<SVMXC__ServiceMax_Properties__c> lstSaveSPSetting = new List<SVMXC__ServiceMax_Properties__c>();
        try{
            if(isNewRecord){
                if(lstSpInstanceSetting.size()>0){
                  strInstName = lstSpInstanceSetting[lstSpInstanceSetting.size()-1].instName;
                  boolIsActive = lstSpInstanceSetting[lstSpInstanceSetting.size()-1].isActive;
                  boolIsDefault = lstSpInstanceSetting[lstSpInstanceSetting.size()-1].isDefault;
                }
                intSPConNum  = MAX_SP_CONNECTIONS +1;
            }else{
                for(SPInstanceDataWrapper spInst: lstSpInstanceSetting){
                    if(spInst.selected){
                        if(String.isNotBlank(spInst.instName)){
                            strInstName = spInst.instName;
                            boolIsActive = spInst.isActive;
                            boolIsDefault = spInst.isDefault;
                            intSPConNum  = Integer.valueOf(mapInstNameNum.get(spInst.instName).trim());
                        }else{
                            boolNoError = false;
                            //Please enter a Valid and Unique Connection Instance Name.
                            ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, System.Label.DCON003_TAG084));
                        }
                    }
                }
            }
            //if it the new/edited setting is marked as default, then reset the isDefault for the other settings. 
            if(boolIsDefault){
                intLstSize = MAX_SP_CONNECTIONS;
                for(Integer i=1;i<=intLstSize;i++){
                    if(intSPConNum != i){
                        String strInstNum = getDoubleDigit(i);
                        SVMXC__ServiceMax_Properties__c SP_CON_02_NN = new SVMXC__ServiceMax_Properties__c();
                        SP_CON_02_NN = allSpSettings.get('SP_CON_02_' + strInstNum);
                        if(SP_CON_02_NN != null){
                            SP_CON_02_NN.SVMXC__Value__c = String.valueOf(false);
                            lstSaveSPSetting.add(SP_CON_02_NN);
                        }
                    }                   
                }
            }
            //check for valid connection values by making a callout.
            try{
                boolNoError = (WSCH_Provider_SP_RealTimeOptimizer.loginToSP(strInstDBUserName.trim(),strInstPwd.trim(),strInstUserName.trim(),strInstURL.trim()));
                if(!boolNoError){
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, system.label.OMAX001_TAG036));
                }
                
            }catch(Exception e){
                boolNoError = false;
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, system.label.OMAX001_TAG036));
                WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: saveSpInstSetting() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
                WSCH_AuditLogger.finish();
            }
            for(String str: allSpSettings.keySet()){
                //check for DUPLICATE setting name
                if(
                    (String.isBlank(strInstName)) || 
                    (
                        (isNewRecord) &&
                        (strConnNameVar.equalsIgnoreCase(allSpSettings.get(str).SVMXC__Key__c)) &&
                        (strInstName.equalsIgnoreCase(allSpSettings.get(str).SVMXC__Value__c))
                    ) ||
                    (
                        (!isNewRecord) &&
                        (strConnNameVar.equalsIgnoreCase(allSpSettings.get(str).SVMXC__Key__c)) &&
                        (!(strInstName.equalsIgnoreCase(allSpSettings.get('SP_CON_00_'+getDoubleDigit(intSPConNum)).SVMXC__Value__c))) &&
                        (strInstName.equalsIgnoreCase(allSpSettings.get(str).SVMXC__Value__c))
                    )
                ){
                    boolNoError = false;
                    if(String.isBlank(strInstName)){
                        //Please enter a valid name.
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, System.Label.DCON003_TAG084));
                    }else{
                        //Duplicate Connection name.
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, System.Label.DCON003_TAG085));
                    }
                }
                //check for DUPLICATE setting URL
                if(
                    (String.isBlank(strInstURL)) || 
                    (
                        (isNewRecord) &&
                        (strConnUrlVar.equalsIgnoreCase(allSpSettings.get(str).SVMXC__Key__c)) &&
                        (strInstURL.equalsIgnoreCase(allSpSettings.get(str).SVMXC__Value__c))
                    ) ||
                    (
                        (!isNewRecord) &&
                        (strConnUrlVar.equalsIgnoreCase(allSpSettings.get(str).SVMXC__Key__c)) &&
                        (!(strInstURL.equalsIgnoreCase(allSpSettings.get('SP_CON_04_'+getDoubleDigit(intSPConNum)).SVMXC__Value__c))) &&
                        (strInstURL.equalsIgnoreCase(allSpSettings.get(str).SVMXC__Value__c))
                    )
                ){
                    boolNoError = false;
                    if(String.isBlank(strInstURL)){
                        //Please enter a valid Endpoint URL.
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, System.Label.DCON003_TAG086));
                    }else{
                        //Duplicate Endpoint URL.
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, System.Label.DCON003_TAG087));
                    }
                }
            }
            //Check for Instance association, if the User has not confirmed the deactivation
            if((!boolIsOkToDereference) && (!isNewRecord) && ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_01_' + getDoubleDigit(intSPConNum)).SVMXC__Value__c)) && (!boolIsActive)){
                List<String> lstSaveInst = new List<String>();
                lstSaveInst.add(getDoubleDigit(intSPConNum));
                boolNoError = checkDeleteInstance(lstSaveInst);
            }
            //if No errors save the records
            if(boolNoError){
                if(isNewRecord){
                    lstSaveSPSetting.addAll(createSPSettings(intSPConNum, strInstName, String.valueOf(boolIsActive), String.valueOf(boolIsDefault), strInstDesc, strInstURL, strInstDBUserName, strInstUserName, strInstPwd, strInstGetAppt , strInstBookAppt , strInstBookJob , strInstUpdWO ));   
                }
                else{
                    lstSaveSPSetting.addAll(updateSPSettings(intSPConNum, strInstName, String.valueOf(boolIsActive), String.valueOf(boolIsDefault), strInstDesc, strInstURL, strInstDBUserName, strInstUserName, strInstPwd, strInstGetAppt , strInstBookAppt , strInstBookJob , strInstUpdWO ));
                }
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSaveSPSetting, COMM_SecurityUtils.Access.Upsertable)){
                    Database.upsert(lstSaveSPSetting);
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
                lstSaveSPSetting.clear();
                loadSpInstSetting();
            }//if there are errors show Warning Messages & show Edit Details
            else{
                showEditSPInst = true;
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: saveSpInstSetting() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        return null;
    }
    //This method is used to delete single/multiple instances
    public PageReference deleteSpInstSetting(){
        isMigrated = false;
        boolIsDelete = true;
        boolIsEdit = false;
        isFirstRecord = false;
        List<SVMXC__ServiceMax_Properties__c> lstDelSpSetting =  new List<SVMXC__ServiceMax_Properties__c>();
        List<String> setDelSpInst = new List<String>();
        Integer CONNECTION_VARIABLE_SIZE = 7;
        Integer API_VARIABLE_SIZE = 14;
        Boolean isNoError = true;
        try{
            for(SPInstanceDataWrapper spInst: lstSpInstanceSetting){
                if(spInst.selected){
                    //showEditSPInst = true;
                    setDelSpInst.add(mapInstNameNum.get(spInst.instName).right(2));
                }
            }
            //Check for Instance association, if the User has not confirmed the deletion
            if((!boolIsOkToDereference)){
                isNoError = checkDeleteInstance(setDelSpInst);
            }
            //Collate all the SVMXC__ServiceMax_Properties__c records related to the Selected instance.
            if(!setDelSpInst.isEmpty()){
                for(String str: setDelSpInst){
                    for(Integer i =0;i<=CONNECTION_VARIABLE_SIZE;i++){
                        lstDelSpSetting.add(allSpSettings.get('SP_CON_0' + String.valueOf(i) +'_' + str));
                        /*if((i ==2) && ('true'.equalsIgnoreCase(allSpSettings.get('SP_CON_0' + String.valueOf(i) +'_' + str).SVMXC__Value__c))){
ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.WARNING, 'This is a Default Connection'));
isNoError = false;
}*/
                    }
                    for(Integer i =11;i<=API_VARIABLE_SIZE;i++){
                        lstDelSpSetting.add(allSpSettings.get('SP_API_' + String.valueOf(i) +'_' + str));
                    }
                }
            }else{
                //Please select a record to delete.
                ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, System.Label.OFFL002_TAG034));
            }
            if(isNoError){
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Properties__c')){
                    Database.delete(lstDelSpSetting);   
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                }
                lstDelSpSetting.clear();
                emptyValues();
                loadSpInstSetting();
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: deleteSpInstSetting() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        return null;
    }
    public PageReference newSpInstSetting(){
        isMigrated = false;
        showEditSPInst = true;
        showListSPInst = true;
        isNewRecord = true;
        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, System.label.DCON003_TAG089));
        lstSpInstanceSetting.clear();
        lstSpInstanceSetting.addAll(getSpInsSettings());
        SPInstanceDataWrapper newSpInst = new SPInstanceDataWrapper();
        newSpInst.selected = true;
        newSpInst.isDefault = false;
        newSpInst.isActive = false;
        if(lstSpInstanceSetting.size() == 0){
            newSpInst.isDefault = true;
            isFirstRecord = true;
        }
        lstSpInstanceSetting.add(newSpInst);
        emptyValues();
        return null;
    }
    public PageReference cancelSpInstSetting(){
        isMigrated = false;
        loadSpInstSetting();
        emptyValues();
        //declare & set boolean variable to control UI
        return null;
    }
    public void emptyValues(){
        strInstName = '';
        strInstURL = '';
        strInstDBUserName = '';
        strInstUserName = '';
        strInstPwd = '';
        strInstDesc = '';
        strInstGetAppt = '';
        strInstBookAppt = '';
        strInstBookJob = '';
        strInstUpdWO = '';
        boolIsActive = false;
        boolIsDefault = false;
    }
    //This method returns two digits for the setting number.
    public String getDoubleDigit(Integer intInstNum){
        String strDoubleDigit = intInstNum<10?'0'+String.valueOf(intInstNum):String.valueOf(intInstNum);
        return strDoubleDigit;
    }
    //This method creates NEW ServicePower settings in the New Data Model.
    public List<SVMXC__ServiceMax_Properties__c> createSPSettings(Integer intInstNum, String strConName,String strIsActv,String strIsDefault,String strDesc,String strURL,String strDBUsrName,String strAPIUsrNm,String strPwd,String strInstGetAppt,String strInstBookAppt,String strInstBookJob,String strUpdWo){
        List<SVMXC__ServiceMax_Properties__c> lstRetSetting = new List<SVMXC__ServiceMax_Properties__c>();
        SVMXC__ServiceMax_Properties__c SP_CON_00_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_CON_01_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_CON_02_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_CON_03_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_CON_04_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_CON_05_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_CON_06_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_CON_07_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_API_11_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_API_12_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_API_13_NN = new SVMXC__ServiceMax_Properties__c();
        SVMXC__ServiceMax_Properties__c SP_API_14_NN = new SVMXC__ServiceMax_Properties__c();
        try{
            String strInstNum = getDoubleDigit(intInstNum);
            SP_CON_00_NN.Name = 'SP_CON_00_' + strInstNum;
            SP_CON_00_NN.SVMXC__Key__c = 'ServicePower Connection Name';
            SP_CON_00_NN.SVMXC__Value__c = strConName;
            lstRetSetting.add(SP_CON_00_NN);
            SP_CON_01_NN.Name = 'SP_CON_01_' + strInstNum;
            SP_CON_01_NN.SVMXC__Key__c = 'ServicePower Connection Active';
            SP_CON_01_NN.SVMXC__Value__c = strIsActv;
            lstRetSetting.add(SP_CON_01_NN);
            SP_CON_02_NN.Name = 'SP_CON_02_' + strInstNum;
            SP_CON_02_NN.SVMXC__Key__c = 'ServicePower Connection Default';
            SP_CON_02_NN.SVMXC__Value__c = strIsDefault;
            lstRetSetting.add(SP_CON_02_NN);
            SP_CON_03_NN.Name = 'SP_CON_03_' + strInstNum;
            SP_CON_03_NN.SVMXC__Key__c = 'ServicePower Connection Description';
            SP_CON_03_NN.SVMXC__Value__c = strDesc;
            lstRetSetting.add(SP_CON_03_NN);
            SP_CON_04_NN.Name = 'SP_CON_04_' + strInstNum;
            SP_CON_04_NN.SVMXC__Key__c = 'ServicePower End Point URL';
            SP_CON_04_NN.SVMXC__Value__c = strURL;
            lstRetSetting.add(SP_CON_04_NN);
            SP_CON_05_NN.Name = 'SP_CON_05_' + strInstNum;
            SP_CON_05_NN.SVMXC__Key__c = 'ServicePower Database User Name';
            SP_CON_05_NN.SVMXC__Value__c = encryption1(strDBUsrName);
            lstRetSetting.add(SP_CON_05_NN);
            SP_CON_06_NN.Name = 'SP_CON_06_' + strInstNum;
            SP_CON_06_NN.SVMXC__Key__c = 'ServicePower API User Name';
            SP_CON_06_NN.SVMXC__Value__c = encryption1(strAPIUsrNm);
            lstRetSetting.add(SP_CON_06_NN);
            SP_CON_07_NN.Name = 'SP_CON_07_' + strInstNum;
            SP_CON_07_NN.SVMXC__Key__c = 'ServicePower Password';
            SP_CON_07_NN.SVMXC__Value__c = encryption1(strPwd);
            lstRetSetting.add(SP_CON_07_NN);
            SP_API_11_NN.Name = 'SP_API_11_' + strInstNum;
            SP_API_11_NN.SVMXC__Key__c = 'ServicePower API Get Appointment';
            SP_API_11_NN.SVMXC__Value__c = strInstGetAppt;
            lstRetSetting.add(SP_API_11_NN);
            SP_API_12_NN.Name = 'SP_API_12_' + strInstNum;
            SP_API_12_NN.SVMXC__Key__c = 'ServicePower API Book Appointment';
            SP_API_12_NN.SVMXC__Value__c = strInstBookAppt;
            lstRetSetting.add(SP_API_12_NN);
            SP_API_13_NN.Name = 'SP_API_13_' + strInstNum;
            SP_API_13_NN.SVMXC__Key__c = 'ServicePower API Book Job';
            SP_API_13_NN.SVMXC__Value__c = strInstBookJob;
            lstRetSetting.add(SP_API_13_NN);
            SP_API_14_NN.Name = 'SP_API_14_' + strInstNum;
            SP_API_14_NN.SVMXC__Key__c = 'ServicePower API Book Job';
            SP_API_14_NN.SVMXC__Value__c = strUpdWo;
            lstRetSetting.add(SP_API_14_NN);
            
            //Create a Custom Setting which confirms that the settings were migrated.
            allSpSettings = SVMXC__ServiceMax_Properties__c.getAll();
            if((allSpSettings.get('SP_MIGRATED') == null)){
                SVMXC__ServiceMax_Properties__c SP_MIGRATED = new SVMXC__ServiceMax_Properties__c();
                SP_MIGRATED.Name = 'SP_MIGRATED';
                SP_MIGRATED.SVMXC__Key__c = 'GBL023 Migrated';
                SP_MIGRATED.SVMXC__Value__c = 'GBL023 Migrated or Updated on ' + String.valueOf(datetime.now());
                lstRetSetting.add(SP_MIGRATED);
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: createSPSettings() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        return lstRetSetting;
    }
    //This method Updates the existing ServicePower settings in the new Data Model
    public List<SVMXC__ServiceMax_Properties__c> updateSPSettings(Integer intInstNum, String strConName,String strIsActv,String strIsDefault,String strDesc,String strURL,String strDBUsrName,String strAPIUsrNm,String strPwd,String strInstGetAppt,String strInstBookAppt,String strInstBookJob,String strUpdWo){
        List<SVMXC__ServiceMax_Properties__c> lstRetSetting = new List<SVMXC__ServiceMax_Properties__c>();
        try{
            String strInstNum = getDoubleDigit(intInstNum);
            
            SVMXC__ServiceMax_Properties__c SP_CON_00_NN = allSpSettings.get('SP_CON_00_' + strInstNum);
            if(SP_CON_00_NN!=null){
              SP_CON_00_NN.SVMXC__Key__c = 'ServicePower Connection Name';
              SP_CON_00_NN.SVMXC__Value__c = strConName;
            }
            lstRetSetting.add(SP_CON_00_NN);
            
            
            SVMXC__ServiceMax_Properties__c SP_CON_01_NN = allSpSettings.get('SP_CON_01_' + strInstNum);
            if(SP_CON_01_NN!=null){
              SP_CON_01_NN.SVMXC__Key__c = 'ServicePower Connection Active';
              SP_CON_01_NN.SVMXC__Value__c = strIsActv;
            }
            lstRetSetting.add(SP_CON_01_NN);
            
            SVMXC__ServiceMax_Properties__c SP_CON_02_NN = allSpSettings.get('SP_CON_02_' + strInstNum);
            if(SP_CON_02_NN!=null){
              SP_CON_02_NN.SVMXC__Key__c = 'ServicePower Connection Default';
              SP_CON_02_NN.SVMXC__Value__c = strIsDefault;
            }
            lstRetSetting.add(SP_CON_02_NN);
            
            SVMXC__ServiceMax_Properties__c SP_CON_03_NN = allSpSettings.get('SP_CON_03_' + strInstNum);
            if(SP_CON_03_NN!=null){
              SP_CON_03_NN.SVMXC__Key__c = 'ServicePower Connection Description';
              SP_CON_03_NN.SVMXC__Value__c = strDesc;
            }
            lstRetSetting.add(SP_CON_03_NN);
            
            SVMXC__ServiceMax_Properties__c SP_CON_04_NN = allSpSettings.get('SP_CON_04_' + strInstNum);
            if(SP_CON_04_NN!=null){
              SP_CON_04_NN.SVMXC__Key__c = 'ServicePower End Point URL';
              SP_CON_04_NN.SVMXC__Value__c = strURL;
            }
            lstRetSetting.add(SP_CON_04_NN);
            
            SVMXC__ServiceMax_Properties__c SP_CON_05_NN = allSpSettings.get('SP_CON_05_' + strInstNum);
            if(SP_CON_05_NN!=null){
              SP_CON_05_NN.SVMXC__Key__c = 'ServicePower Database User Name';
              SP_CON_05_NN.SVMXC__Value__c = encryption1(strDBUsrName);
            }
            lstRetSetting.add(SP_CON_05_NN);
            
            SVMXC__ServiceMax_Properties__c SP_CON_06_NN = allSpSettings.get('SP_CON_06_' + strInstNum);
            if(SP_CON_06_NN!=null){
              SP_CON_06_NN.SVMXC__Key__c = 'ServicePower API User Name';
              SP_CON_06_NN.SVMXC__Value__c = encryption1(strAPIUsrNm);
            }
            lstRetSetting.add(SP_CON_06_NN);
            
            SVMXC__ServiceMax_Properties__c SP_CON_07_NN = allSpSettings.get('SP_CON_07_' + strInstNum);
            if(SP_CON_07_NN!=null){
              SP_CON_07_NN.SVMXC__Key__c = 'ServicePower Password';
              SP_CON_07_NN.SVMXC__Value__c = encryption1(strPwd);
            }
            lstRetSetting.add(SP_CON_07_NN);
            
            SVMXC__ServiceMax_Properties__c SP_API_11_NN = allSpSettings.get('SP_API_11_' + strInstNum);
            if(SP_API_11_NN!=null){
              SP_API_11_NN.SVMXC__Key__c = 'ServicePower API Get Appointment';
              SP_API_11_NN.SVMXC__Value__c = strInstGetAppt;
            }
            lstRetSetting.add(SP_API_11_NN);
            
            SVMXC__ServiceMax_Properties__c SP_API_12_NN = allSpSettings.get('SP_API_12_' + strInstNum);
            if(SP_API_12_NN!=null){
              SP_API_12_NN.SVMXC__Key__c = 'ServicePower API Book Appointment';
              SP_API_12_NN.SVMXC__Value__c = strInstBookAppt;
            }
            lstRetSetting.add(SP_API_12_NN);
            
            SVMXC__ServiceMax_Properties__c SP_API_13_NN = allSpSettings.get('SP_API_13_' + strInstNum);
            if(SP_API_13_NN!=null){
              SP_API_13_NN.SVMXC__Key__c = 'ServicePower API Book Job';
              SP_API_13_NN.SVMXC__Value__c = strInstBookJob;
            }
            lstRetSetting.add(SP_API_13_NN);
            
            SVMXC__ServiceMax_Properties__c SP_API_14_NN = allSpSettings.get('SP_API_14_' + strInstNum);
            if(SP_API_14_NN!=null){
              SP_API_14_NN.SVMXC__Key__c = 'ServicePower API Book Job';
              SP_API_14_NN.SVMXC__Value__c = strUpdWo;
            }
            lstRetSetting.add(SP_API_14_NN);
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: updateSPSettings() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
        return lstRetSetting;
    }
    //This message checks if the ServicePower Instance is associated to any SFM, DispatchProcess, ServiceTeam Or Territory
    public Boolean checkDeleteInstance(List<String> lstDelSpInst){
        Boolean boolNoError = true;
        List<SVMXC__ServiceMax_Config_Data__c> lstSFMConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Processes__c> lstDispProc = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__Territory__c> lstTerr = new List<SVMXC__Territory__c>();
        List<SVMXC__Service_Group__c> lstServcTeam = new List<SVMXC__Service_Group__c>();
        Map<String, Map<Id, String>> mapWarnMsg = new Map<String, Map<Id, String>>();
        Map<Id,String> mapRelatedRecords;
        String strErrormsg, strCompMsg;
        String strSfmQuery = '', strDispQuery = '', strTeamQuery = '', strTerrQuery = '', strParameterName = 'spInstance', strDispmethod = 'Linx for ServicePower';
        Id idSfActParamRecType, idDispProcRecType;
        Set<String> setSettingName = new Set<String>();
        try{
            if(!lstDelSpInst.isEmpty()){
                List<RecordType> lstRecordType = [SELECT Id, Name FROM RecordType WHERE (Name LIKE '%SF Action Parameter%') OR (Name LIKE '%Dispatch Process%')];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                for(RecordType recType: lstRecordType){
                    if('SF Action Parameter'.equalsIgnoreCase(recType.Name)){
                        idSfActParamRecType = recType.id;
                    }
                    if('Dispatch Process'.equalsIgnoreCase(recType.Name)){
                        idDispProcRecType = recType.id;
                    }
                }
                strSfmQuery = 'SELECT Id, '
                    + 'RecordTypeId, '
                    + 'SVMXC__Parameter_Name__c, '
                    + 'SVMXC__Parameter_Value__c, '
                    + 'SVMXC__Dispatch_Process__c, '
                    + 'SVMXC__Dispatch_Process__r.SVMXC__Name__c '
                    + 'FROM SVMXC__ServiceMax_Config_Data__c '
                    + 'WHERE SVMXC__Parameter_Value__c IN :setSettingName '
                    + 'AND RecordTypeId = :idSfActParamRecType';
                strDispQuery = 'SELECT Id, '
                    + 'RecordTypeId, '
                    + 'SVMXC__Name__c, '
                    + 'SVMXC__Target_URL__c  '
                    + 'FROM SVMXC__ServiceMax_Processes__c '
                    + 'WHERE SVMXC__Dispatch_Method__c = :strDispmethod '
                    + 'AND RecordTypeId = :idDispProcRecType '
                    + 'AND SVMXC__Target_URL__c != null '
                    + 'AND SVMXC__Target_URL__c IN :setSettingName';
                strTeamQuery = 'SELECT Id, '
                    + 'Name, '
                    + 'SVMXC__Active__c, '
                    + 'SVMXC__Optimizer_Connection_Name__c, '
                    + 'RecordTypeId '
                    + 'FROM SVMXC__Service_Group__c '
                    + 'WHERE SVMXC__Optimizer_Connection_Name__c IN :setSettingName';
                strTerrQuery = 'SELECT Id, '
                    + 'Name, '
                    + 'SVMXC__Active__c, '
                    + 'SVMXC__Optimizer_External_ID__c, '
                    + 'SVMXC__Optimizer_Connection_Name__c '
                    + 'FROM SVMXC__Territory__c '
                    + 'WHERE SVMXC__Optimizer_Connection_Name__c IN :setSettingName';
                    
                SVMXC__ServiceMax_Properties__c strSP_CON_00 ;
                for(String str: lstDelSpInst){
                    strSP_CON_00 = allSpSettings.get('SP_CON_00_' + str);
                    //setSettingName.add(allSpSettings.get('SP_CON_00_' + str).SVMXC__Value__c);
                    if(strSP_CON_00!=null){
                        setSettingName.add(strSP_CON_00.SVMXC__Value__c);
                    }
                }
                lstSFMConfData = Database.query(strSfmQuery);
                lstDispProc = Database.query(strDispQuery);
                //lstServcTeam = Database.query(strTeamQuery);
                //lstTerr = Database.query(strTerrQuery);
                String fullInstURL = URL.getSalesforceBaseUrl().toExternalForm();
                if(lstSFMConfData!=null&&!lstSFMConfData.isEmpty()){
                    mapRelatedRecords = new Map<Id,String>();
                    for(SVMXC__ServiceMax_Config_Data__c sfm: lstSFMConfData){
                        for(String str: setSettingName){
                            boolNoError = false;
                            boolShowOk = true;
                            if(str.equalsIgnoreCase(sfm.SVMXC__Parameter_Value__c)){
                                //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, str + ' ServicePower instance is associated to ' + sfm.SVMXC__Dispatch_Process__r.SVMXC__Name__c + ' SFM'));
                                //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.WARNING, '<b>' + str + '</b> ' + System.label.DCON003_TAG090 + ' <b><a href="' + fullInstURL + '/apex/Conf_SetupAction?SVMX_RecordId='+ sfm.SVMXC__Dispatch_Process__c + '">'+ sfm.SVMXC__Dispatch_Process__r.SVMXC__Name__c + '</a></b> ' + System.label.CONF018_TAG001));
                                mapRelatedRecords.put(sfm.SVMXC__Dispatch_Process__c, sfm.SVMXC__Dispatch_Process__r.SVMXC__Name__c);
                            }
                        }
                    }
                    if(!mapRelatedRecords.isEmpty()){
                        mapWarnMsg.put(System.label.CONF018_TAG001,mapRelatedRecords);
                    }
                }
                if(lstDispProc!=null&&!lstDispProc.isEmpty()){
                    mapRelatedRecords = new Map<Id,String>();
                    for(SVMXC__ServiceMax_Processes__c dProc: lstDispProc){
                        for(String str: setSettingName){
                            boolNoError = false;
                            boolShowOk = true;
                            if(str.equalsIgnoreCase(dProc.SVMXC__Target_URL__c)){
                                //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.WARNING, '<b>' + str + '</b> ' + System.label.DCON003_TAG090 + ' <b><a href="' + fullInstURL + '/apex/WORD_SetupDispatchProcess?dpeid=' + dProc.Id + '">'+ dProc.SVMXC__Name__c + '</a></b> ' + System.label.WORD015_TAG003));
                                mapRelatedRecords.put(dProc.Id, dProc.SVMXC__Name__c);
                            }
                        }
                    }
                    if(!mapRelatedRecords.isEmpty()){
                        mapWarnMsg.put(System.label.WORD015_TAG003,mapRelatedRecords);
                    }
                }
                if(!lstServcTeam.isEmpty()){
                    mapRelatedRecords = new Map<Id,String>();
                    for(SVMXC__Service_Group__c srvTeam: lstServcTeam){
                        for(String str: setSettingName){
                            boolNoError = false;
                            boolShowOk = true;
                            if(str.equalsIgnoreCase(srvTeam.SVMXC__Optimizer_Connection_Name__c)){
                                //ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.WARNING, '<b>' + str + '</b> ' + System.label.DCON003_TAG090 + ' <b><a href="' + fullInstURL + '/' + srvTeam.Id + '">'+ srvTeam.Name + '</a></b> ' + System.label.SORG001_TAG032));
                                mapRelatedRecords.put(srvTeam.Id, srvTeam.Name);
                            }
                        }
                    }
                    if(!mapRelatedRecords.isEmpty()){
                        mapWarnMsg.put(System.label.SORG001_TAG032,mapRelatedRecords);
                    }
                }
                /*if(!lstTerr.isEmpty()){
for(SVMXC__Territory__c terr: lstTerr){
for(String str: setSettingName){
boolNoError = false;
if(str.equalsIgnoreCase(terr.SVMXC__Optimizer_Connection_Name__c)){
ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.Error, str + ' ServicePower instance is associated to <a href="' + fullInstURL + '/' +  terr.Id + '">'+ terr.Name + '</a> Territory'));
}
}
}
}*/
                if(boolShowOk){
                    ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.INFO, System.label.DCON003_TAG088));
                }
                if(!boolNoError){
                    if((!mapWarnMsg.isEmpty())){
                        strErrormsg = '';
                        for(String strComp: mapWarnMsg.keySet()){
                            //mapRelatedRecords.clear();
                            mapRelatedRecords = new Map<Id,String>();
                            mapRelatedRecords = mapWarnMsg.get(strComp.trim());
                            if(!mapRelatedRecords.isEmpty()){
                                strErrormsg += '</br><b>' + strComp + '</b>: ';
                                strCompMsg = '';
                                for(Id compId: mapRelatedRecords.keySet()){
                                    if(String.isNotBlank(strCompMsg))
                                        strCompMsg += ', ';
                                    strCompMsg += '<a href="' + fullInstURL + '/' + compId + '">'+ mapRelatedRecords.get(compId) + '</a>';
                                }
                                strErrormsg += strCompMsg;
                            }
                        }
                        ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.WARNING, System.label.DCON003_TAG090  + strErrorMsg));
                    }
                }
            }
        }catch(Exception e){
            WSCH_AuditLogger.error('Exception caught:OMAX_ManageOrgSettings: checkDeleteInstance() ' + e.getMessage() + '\n  Stack Trace:: ' + e.getStackTraceString());
            WSCH_AuditLogger.finish();
            boolNoError = false;
        }
        return boolNoError;
    }
    /*** @Multiple Instance END ***/
}