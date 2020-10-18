public with sharing class CONF_MobileConfig
{
    //--------------------------------- Variables and Getter Setters -------------------------------------------------
    public List<SVMXC__ServiceMax_Config_Data__c> lstInvalidDLCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> allSVMXProfiles = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfiguredProfiles = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfigDataToDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataDLCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<String, SVMXC__ServiceMax_Config_Data__c> Object_DispatchPorcesMap = new Map<String, SVMXC__ServiceMax_Config_Data__c>();
    public Map<String, SVMXC__ServiceMax_Config_Data__c> Object_AdvDwnldCrit = new Map<String, SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfigdata_AdvDwnldCrit = new List<SVMXC__ServiceMax_Config_Data__c>();
    public Map<string, string> objNameToLabel = new Map<string, string>();
    
    public List<selectOption> profileOptns = new List<selectOption>();
    public List<selectOption> getprofileOptns(){return profileOptns;}
    public List<SelectOption> configuredProfileOptns = new List<SelectOption>();
    public List<SelectOption> getconfiguredProfileOptns(){return this.configuredProfileOptns;}
    public List<selectOption> conflictResolutionOptns = new List<selectOption>();
    public List<selectOption> getconflictResolutionOptns(){return conflictResolutionOptns;}
    public List<selectOption> userAccessLstSelOptn = new List<selectOption>();
    public List<selectOption> getUserAccessLstSelOptn() {return userAccessLstSelOptn;}
    //public List<selectOption> datasetSynchronizationOptns = new List<selectOption>();
    //public List<selectOption> getdatasetSynchronizationOptns(){return datasetSynchronizationOptns;}
    public List<selectOption> processType = new List<selectOption>();
    public List<selectOption> getprocessType(){return processType;}
    public List<selectOption> OperatorSelectLst = new List<selectOption>();
    public List<SelectOption> getOperatorSelectLst(){return OperatorSelectLst;}
    public List<selectOption> txObj = new List<selectOption>();
    public List<selectOption> gettxObj() {return txObj;}
    public List<selectOption> txObjAdvDwnld = new List<selectOption>();
    public List<selectOption> gettxObjAdvDwnld() {return txObjAdvDwnld;}
    public List<SelectOption> Hdrfldlist = new List<SelectOption>();
    public List<SelectOption> getHdrfldlist(){return Hdrfldlist;}
    public List<SelectOption> AdcHdrfldlist = new List<SelectOption>();
    public List<SelectOption> getAdcHdrfldlist(){return AdcHdrfldlist;}
    public String ObjNameFrSaveExp{get; set;}
    public String selectedProfile{get;set;}
    public String selectedConfiguredProfile{get;set;}
    //public String DatasetSynchron{get;set;} 
    //public String syncDataEvery{get;set;}
    public String freqMasterData{get;set;}
    public String freqAppChng{get;set;}
    public String syncGetEvent{get;set;}
    public String syncRemoveEvent{get;set;}
    public String conflictResol{get;set;}
    public String chatterThreads{get;set;}
    public String downloadLimitKB{get;set;}
    public String strFreqLocTracking{get;set;}
    public String strEnableLocTrack{get;set;}
    public String strMaxRecToCache{get;set;}
    public string DelIndex{get;set;}
    public String savedExpressionResultId;
    public String selectedProcess{get;set;}
    public String searchByObjKey{get;set;}
    public String searchByTyp{get; set;}
    public string editFilterId{get;set;}
    public String ObjNameToFilter{get;set;}
    public String selectedProcessName{get; set;}
    public Integer selectedObjSerial{get;set;}
    public boolean isLocationTrack{get;set;}
    public boolean isChecklist{get;set;}
    public boolean isCompletedChecklist{get;set;}
    public boolean isInProgressChecklist{get;set;}
    public boolean showChklstOptions{get;set;}
    public boolean isSetLatestTechLoc{get;set;}
    public boolean disableSaveCancelBtn{get;set;}
    public boolean showExpPopUp{get;set;}
    public boolean reminget{get;set;}
    public boolean DeletMsg {get; set;}
    public boolean ExpMsg {get;set;}
    public boolean showTxObj{get; set;}
    
    public List<String> selectedProcessObjs = new List<String>();
    public List<String> getselectedProcessObjs() {return selectedProcessObjs;}
    public void SetselectedProcessObjs(List<String> ss) {selectedProcessObjs = ss;}
    public Map<String,SET<String>> mapProcessObject = new Map<String,SET<String>>();
    public Map<String,SET<String>> mapObjectProcess = new Map<String,SET<String>>();
    
    public Map<Id, SVMXC__ServiceMax_Processes__c> processMap = new  Map<Id, SVMXC__ServiceMax_Processes__c>();
    
    public Map<Integer, SVMXC__ServiceMax_Config_Data__c> Map_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    
    public List<SVMXC__ServiceMax_Processes__c> selectedLstPrss = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getSelectedLstPrss() { return selectedLstPrss;}
    
    RecordType RTExpressionsDetail = new RecordType();
    RecordType RTMobileConfig = new RecordType();
    
    public Map<String,String> mapAPILabel_Name = new Map<String,String>();
    public Map<String,String> getmapAPILabel_Name() {return mapAPILabel_Name;}
    
    public boolean IsFreqBased = false;
    public boolean getIsFreqBased(){return this.IsFreqBased;}
    public string strFreqBasedValue{get;set;}
    
    //Variables declaration for the Advanced Download Criteria
    public boolean showExp_AdvDwnldCrit{get;set;}
    public boolean isValidAdvExp{get;set;}
    public integer selectedAdvExpSeq{get;set;}
    public string AdvExp_DelIndex{get;set;}
    public string AdvDwnldCrit_editFilterId{get;set;}
    public string AdvDwnldCrit_ObjNameToFilter{get;set;}
    public string AdvDwnldCrit_selectedObjSerial{get;set;}
    public String ObjName_SaveAdvDwnldCritExp{get; set;}
    public String advExpId;
    public map<string, string> mapLkpFldReferObj = new map<string, string>();
    public map<string, List<string>> mapLkpFldListReferObj = new map<string, List<string>>();
    
    public advDwnldCritWrap var_advDwnldCrit{get;set;}
    public Integer getAdvExp_DetailSize()
    {
        if(var_advDwnldCrit == null || var_advDwnldCrit.dtlWrap == null || var_advDwnldCrit.dtlWrap.size() == 0)
            return 0;
        else
            return var_advDwnldCrit.dtlWrap.size();
    }
    
    public class advDwnldCritWrap
    {
        public SVMXC__ServiceMax_Processes__c ExpPro = new SVMXC__ServiceMax_Processes__c();
        public SVMXC__ServiceMax_Processes__c getExpPro(){return this.ExpPro;}
        public List<SVMXC__ServiceMax_Config_Data__c> lstExpDtls = new List<SVMXC__ServiceMax_Config_Data__c>();
        public List<advDwnldCrit_DtlWrap> dtlWrap = new List<advDwnldCrit_DtlWrap>();
        public List<advDwnldCrit_DtlWrap> getdtlWrap(){return this.dtlWrap;}
        public void setdtlWrap(List<advDwnldCrit_DtlWrap> lst){this.dtlWrap = lst;}
        
        public advDwnldCritWrap()
        {}
        
        public advDwnldCritWrap(SVMXC__ServiceMax_Processes__c pro, List<SVMXC__ServiceMax_Config_Data__c> lstDtl)
        {
            ExpPro = pro;
            lstExpDtls = lstDtl;
            
            if(lstExpDtls != null && lstExpDtls.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c expDtl: lstExpDtls)
                {
                    advDwnldCrit_DtlWrap wrpDtl = new advDwnldCrit_DtlWrap(integer.valueOf(expDtl.SVMXC__Sequence__c), expDtl.SVMXC__Field_Name__c, expDtl.SVMXC__Object_Name2__c, expDtl.SVMXC__Source_Field_Name__c, expDtl.SVMXC__Operator__c, expDtl.SVMXC__Operand__c);
                    
                    dtlWrap.add(wrpDtl);
                }
            }
        }
    }

    public class advDwnldCrit_DtlWrap
    {
        public boolean isReferField{get;set;}
        public integer sequence{get;set;}
        public string hdrFld{get;set;}
        public string dtlObj{get;set;}
        public string dtlFld{get;set;}
        public string op{get;set;}
        public string fldValue{get;set;}
        public List<SelectOption> dtlObjLstSO = new List<SelectOption>();
        public List<SelectOption> getdtlObjLstSO(){return this.dtlObjLstSO;}
        public List<SelectOption> dtlFldLstSO = new List<SelectOption>();
        public List<SelectOption> getdtlFldLstSO(){return this.dtlFldLstSO;}
        
        public advDwnldCrit_DtlWrap()
        {}
        
        public advDwnldCrit_DtlWrap(integer intSeq, string strhdrFld, string strdtlObj, string strdtlFld, string oper, string val)
        {
            isReferField = false;
            hdrFld = strhdrFld;
            dtlObj = strdtlObj;
            dtlFld = strdtlFld;
            sequence = intSeq;
            op = oper;
            fldValue = val;
            if(fldValue == null)
                isReferField = true;
                
            dtlObjLstSO = new List<SelectOption>();
            dtlObjLstSO.add(new selectOption('SVMX.None', system.label.COMM002_TAG005));
            dtlFldLstSO = new List<SelectOption>();
            dtlFldLstSO.add(new selectOption('SVMX.None', system.label.COMM002_TAG005));
        }
    }
    
    public class objConfDataWrapper
    {
        public string selectedObjName{get;Set;}
        public string selectedProName{get;Set;}
        public String userAccess{get;set;}
        public integer sequenceNo{get;Set;}
        public boolean renderStngOptn{get;set;}
        public boolean Dectfld{get; set;}
        public boolean IsSelectRow{get;set;}
        public boolean showEditDel{get;set;}
        public List<selectOption> objLstOptns = new List<selectOption>();
        public List<selectOption> getobjLstOptns() {return this.objLstOptns;}
        public void setobjLstOptns(List<selectOption> so) {this.objLstOptns = so;}
        public List<selectOption> proLstOptns = new List<selectOption>();
        public List<selectOption> getproLstOptns() {return this.proLstOptns;}
        public void setproLstOptns(List<selectOption> lstOptns) {this.proLstOptns = lstOptns;}
        public SVMXC__ServiceMax_Config_Data__c ConfDataInObj = new SVMXC__ServiceMax_Config_Data__c();
        public objConfDataWrapper(SVMXC__ServiceMax_Config_Data__c wrapConfData, List<selectOption> lstOptnsForObj, List<selectOption> lstOptns, Integer serialOfWrapper)
        {
            MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            Dectfld = false;
            if(wrapConfData.Id != null)
                userAccess = wrapConfData.SVMXC__Ownership_Type__c ;
            else
                userAccess = 'My Records';
            ConfDataInObj = wrapConfData;
            objLstOptns = lstOptnsForObj;
            proLstOptns = lstOptns;
            IsSelectRow = false;
            sequenceNo = serialOfWrapper +1 ;
            
            if(wrapConfData.SVMXC__Object_Name__c != null && wrapConfData.SVMXC__Object_Name__c.length() > 0)
            {
                selectedObjName = wrapConfData.SVMXC__Object_Name__c;
                renderStngOptn = false;
                String objectName = selectedObjName;
                SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
                objectName = utils.getOriginalAPIName(objectName, allObjs);
                Schema.SObjectType selectedObject = allObjs.get(objectName);
                Schema.DescribeSObjectResult objDescribe = selectedObject.getDescribe();
                Map<String,Schema.SObjectField> fieldMapping = objDescribe.fields.getMap();
                for(Schema.SObjectField fieldMap: fieldMapping.values())
                {
                    if(fieldMap.getDescribe().getName() == 'OwnerId')
                        Dectfld = true;
                }
                if(Dectfld == false)
                    userAccess = 'All Records';
            }
            else
            {
                selectedObjName = 'SVMX.None';
                renderStngOptn = true;
            }
            
            if(wrapConfData.SVMXC__Dispatch_Process__c != null )
            {
                selectedProName = wrapConfData.SVMXC__Dispatch_Process__c;
                showEditDel = true;
            }
            else
                showEditDel = false;
        }
    }
    
    public List<objConfDataWrapper> lstWrapperConfData = new List<objConfDataWrapper>();
    public List<objConfDataWrapper> getlstWrapperConfData() {return this.lstWrapperConfData;}
    public void setlstWrapperConfData(List<objConfDataWrapper> lstOptns) { this.lstWrapperConfData = lstOptns;}
    public Integer getWrapperSize(){ return lstWrapperConfData.size();}
    public Integer ExpDetailSize = 0;
    public Integer getExpDetailSize(){ return ExpDetailSize;}
    public string retURL = '';
    
    public List<objConfDataWrapper> lstAdvDwnldCriWrp = new List<objConfDataWrapper>();
    public List<objConfDataWrapper> getlstAdvDwnldCriWrp() {return this.lstAdvDwnldCriWrp;}
    public void setlstAdvDwnldCriWrp(List<objConfDataWrapper> lstOptns) { this.lstAdvDwnldCriWrp = lstOptns;}
    public Integer getAdvDwnldCriWrpSize(){ return lstAdvDwnldCriWrp.size();}
    
    //Variables for the Purging Settings -- Spring 14 release
    public String freqDataPurging{get;set;}
    public String purgeOlderRec{get;set;}
    //Variable for Laptop Mobile Setting
    public boolean allowAPIAccess{get;set;}
    //Variable for Enabling Logging
    public boolean enableLogging{get;set;}
    public string enableUsageLogging{get;set;}
    public String usageLogUserOpt{get;set;}
    public List<selectOption> usageLogUserOptOptns = new List<selectOption>();
    public List<selectOption> getusageLogUserOptOptns(){return usageLogUserOptOptns;}
    public boolean isUsageLogDisabled{get;set;}
    public boolean isSyncPerformance{get;set;}
    public boolean isSoqlPerformance{get;set;}
    public boolean isSyncPerformanceEnabled{get;set;}
    
    //EMPP
    public String orgTypeUserOption{get;set;}
    public List<selectOption> orgTypeAvailableOptns = new List<selectOption>();
    public List<selectOption> getorgTypeAvailableOptns(){return orgTypeAvailableOptns;}
    public String syncCustomUrl{get;set;}
    public boolean isCustomUrlEnabled{get;set;}
    
//Device Targeted  
    public List<DeviceTargetWrap> listOfDeviceTargetWrap{get;set;} 
    public Boolean isDeviceMobileConfig{get;set;} 
    public Boolean isPopup{get;set;}
    public SVMXC__SM_Device_Mobile_Config__c newMobileConfig{get;set;} 
    public Boolean topPagMsgDevice{get;set;} 
    public Boolean isDefaultEnable{get;set;}
    public Boolean isDeviceAdded{get;set;}
    public Boolean saveMessageDevice{get;set;}
    
    public map<string, boolean> lstStdObjAccToLicense = new map<string, boolean>();
    
    //Salesforce Files
    public class FileConfig {
        public Boolean isFilesEnabled{get;set;}
        public String maxFileSize{get;set;}
        public String fileTypes{get;set;}
        public String fileTags{get;set;}
       
        public FileConfig() {
        }
        
        public FileConfig(Boolean isFilesEnabled, String maxFileSize, String fileTypes, String fileTags) {
                this.isFilesEnabled = isFilesEnabled;
                this.maxFileSize = maxFileSize;
                this.fileTypes = fileTypes;
                this.fileTags = fileTags;
        }
    }
    
    public List<FileConfig> fileConfigList{get;set;} 
    
    //---------------------------------------------------- Constructor/Onload -----------------------------------------------------------
    public CONF_MobileConfig()
    {
        MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        retURL = System.currentPageReference().getParameters().get('SVMX_RetURL');
        retrievingRecordTypes();
        queryingData();
        preparingPickLists();
        defaultValues();
        for(String s : allObjs.keyset())
        {
            Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
            if(!(objDesc.getName().contains('__Tag') || objDesc.getName().contains('__History')))
                mapAPILabel_Name.put(objDesc.getName(),objDesc.getLabel());
        }
        
        COMM_Utils comUtil = new COMM_Utils();
        lstStdObjAccToLicense = comUtil.SVMX_getPermittedStandardObjectList();
    }
    
    public void defaultValues()
    {
        searchByObjKey = 'SVMX.None';
        searchByTyp = 'SVMX.None';
        disableSaveCancelBtn = true;
        showExpPopUp = false;
        showTxObj = false;
        DeletMsg = true;
        ExpMsg = true;
        TopPagMsgDevice = false;
        selectedProfile = 'SVMX.None';
        selectedConfiguredProfile = 'SVMX.None';
        reminget = false;
        enableLogging= false;
        enableUsageLogging = '';
        isChecklist = false;
        isCompletedChecklist = false;
        isInProgressChecklist = false;
        //For Advanced Download Criteria
        showExp_AdvDwnldCrit = false;
        isSyncPerformance=false;
        isSoqlPerformance=false;
        isSyncPerformanceEnabled=true;
        
        orgTypeUserOption = getTag141();  //EMPP
        syncCustomUrl = '';
        isCustomUrlEnabled = false;
        
            //Device Targeted
        isPopup=false;
        listOfDeviceTargetWrap = new List<DeviceTargetWrap>();
        isDeviceMobileConfig=false;
        newMobileConfig = new SVMXC__SM_Device_Mobile_Config__c();
        topPagMsgDevice=false;
        isDefaultEnable=false;
        isDeviceAdded=false;
        saveMessageDevice=false; 
        
        //Salesforce files
        fileConfigList = new List<FileConfig>();       
    }
       
    public void queryingData()
    {
        allSVMXProfiles.clear();
        allSVMXProfiles = [Select Id, SVMXC__Profile_Name__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Profile'  and SVMXC__Configuration_Type__c = 'Group'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    
    public void retrievingRecordTypes()
    {
        RTExpressionsDetail = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Expressions' Limit 1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RTMobileConfig = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SVMX Rule' Limit 1];  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        advExpId = rt.Id;
    }
    
    public void preparingPickLists()
    {
        processType.clear();
        processType.add(new selectOption('SVMX.None', getTAG019()));
        processType.add(new selectOption('SOURCE TO TARGET ALL', getTAG054()));
        processType.add(new selectOption('SOURCE TO TARGET CHILD', getTAG055()));
        processType.add(new selectOption('STANDALONE EDIT', getTAG056()));
        processType.add(new selectOption('STANDALONE CREATE', getTAG057()));
        processType.add(new selectOption('VIEW RECORD', getTAG059()));
        processType.add(new selectOption('OUTPUT DOCUMENT', getTAG011()));
        
        userAccessLstSelOptn.clear();
        userAccessLstSelOptn.add(new selectOption('My Records', getTAG095()));
        userAccessLstSelOptn.add(new selectOption('All Records', getTAG096()));
        
        OperatorSelectLst.clear();
        OperatorSelectLst.add(new SelectOption('SVMX.None',getTAG019()));
        OperatorSelectLst.add(new SelectOption('eq',getTAG031()));
        OperatorSelectLst.add(new SelectOption('ne',getTAG032()));
        OperatorSelectLst.add(new SelectOption('gt',getTAG033()));
        OperatorSelectLst.add(new SelectOption('ge',getTAG034()));
        OperatorSelectLst.add(new SelectOption('lt',getTAG035()));
        OperatorSelectLst.add(new SelectOption('le',getTAG036()));
        OperatorSelectLst.add(new SelectOption('starts',getTAG037()));
        OperatorSelectLst.add(new SelectOption('contains',getTAG038()));
        OperatorSelectLst.add(new SelectOption('notcontain',getTAG039()));
        OperatorSelectLst.add(new SelectOption('in',getTAG040()));
        OperatorSelectLst.add(new SelectOption('notin',getTAG041()));
        OperatorSelectLst.add(new SelectOption('isnull',getTAG042()));
        OperatorSelectLst.add(new SelectOption('isnotnull',getTAG043()));
        
        conflictResolutionOptns.clear();
        conflictResolutionOptns.add(new SelectOption('ServiceMax online data', getTAG051()));
        conflictResolutionOptns.add(new SelectOption('Mobile device data', getTAG052()));
        conflictResolutionOptns.add(new SelectOption('Allow user to choose', getTAG053()));
        
        orgTypeAvailableOptns.clear();
        orgTypeAvailableOptns.add(new selectOption('Production', getTag141())); 
        orgTypeAvailableOptns.add(new selectOption('Sandbox', getTag142()));
        orgTypeAvailableOptns.add(new selectOption('Custom', getTag143()));
        
        /*datasetSynchronizationOptns.clear();
        datasetSynchronizationOptns.add(new SelectOption('Automatically when Online', getTAG049()));
        datasetSynchronizationOptns.add(new selectOption('Every', getTAG050()));*/
        
        profileOptns.clear();
        profileOptns.add(new selectOption('SVMX.None', getTAG019()));
        for(SVMXC__ServiceMax_Config_Data__c p : allSVMXProfiles )
            profileOptns.add(new selectOption(p.Id, P.SVMXC__Profile_Name__c));
        profileOptns = sortingSelectOption(profileOptns);
        
        configuredProfileOptns.clear();
        configuredProfileOptns.add(new selectOption('SVMX.None', getTAG019()));
    }
    
    //------------------------------------- Method to sort the Options of the PickList --------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            if(SO.getValue() == 'SVMX.None')
            {
                system.debug(LoggingLevel.WARN, 'SO =  '+ SO);
                resultList.add(SO);
            }
            else
            {
                system.debug(LoggingLevel.WARN, 'SO =  '+ SO.getLabel() + '; SO = ' + SO);
                tempLst.put(SO.getLabel(), new List<SelectOption>()); 
                tempLst.get(SO.getLabel()).add(SO);
            }
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }
    
    public void setDefaultGroupValues(String selectedProfile){   //If the selectedProfile is default profile - set the default values
            
        system.debug('SelectedProfile '+selectedProfile);
        List<SVMXC__ServiceMax_Config_Data__c> defaultList = [Select Id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c where Recordtype.Name = 'Configuration Profile' AND Id =: selectedProfile];
        if(defaultList != NULL && defaultList.size() > 0 && defaultList[0] != NULL && defaultList[0].SVMXC__Profile_Name__c == 'Default Group Profile'){
            //set default values
            freqMasterData = '600';
            freqAppChng = '1200';
            syncGetEvent = '10';
            syncRemoveEvent = '10';
            conflictResol = 'ServiceMax online data';
            chatterThreads = '10';
            downloadLimitKB = '50';
            strFreqLocTracking = '10';
            isLocationTrack = true;
            strEnableLocTrack = 'True';
            strMaxRecToCache = '100';
            isSetLatestTechLoc = true;
            allowAPIAccess= false;
            freqDataPurging = '168';
            purgeOlderRec = '10';
            enableLogging = false;
        }
    }
    
    public void onSelectProfile(List<SVMXC__SM_Device_Mobile_Config__c> listOfConfig)
    {
        enableLogging = false;
        showExpPopUp = false;
        showExp_AdvDwnldCrit = false;
        isSyncPerformance = false;
        isSoqlPerformance =false;
        orgTypeUserOption = getTAG141();
        isSyncPerformanceEnabled=true;
        isCustomUrlEnabled = false;
        Map<Id, SVMXC__ServiceMax_Processes__c> mpProcesses = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        
        mpProcesses.putAll([Select Id, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Purpose__c From SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Process Node Objects' or SVMXC__Record_Type_Name__c ='Target Manager' ]);
            
        List<string> lstIDs = new List<string>();
        for(SVMXC__ServiceMax_Config_Data__c SVMXProfile : allSVMXProfiles)
            lstIDs.add(SVMXProfile.Id);
        
        lstConfiguredProfiles.clear();
        lstConfiguredProfiles = [select SVMXC__Sequence__c, SVMXC__Access_Configuration_Profile__c, SVMXC__Ownership_Type__c, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Display_Type__c, SVMXC__Internal_Value__c, SVMXC__Object_Name__c,SVMXC__SM_Files_Config__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: RTMobileConfig.Id AND SVMXC__Access_Configuration_Profile__c IN: lstIDs AND SM_Device_Mobile_Config__c IN:listOfConfig Order By SVMXC__Sequence__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        system.debug('List of configured profiles size: ' + lstConfiguredProfiles.size() + ' :and the configured profiles are: ' + lstConfiguredProfiles);
        
        Object_DispatchPorcesMap.clear();
        Object_AdvDwnldCrit.clear();
        lstWrapperConfData.clear();
        lstAdvDwnldCriWrp.clear();
        txObj.clear();
        txObjAdvDwnld.clear();
        processMap.clear();
        selectedLstPrss.clear();
        mapProcessObject.clear();
        mapObjectProcess.clear();
        searchByObjKey = 'SVMX.None';
        searchByTyp = 'SVMX.None';
        fileConfigList.clear();
        
        if(selectedProfile != 'SVMX.None' && selectedProfile.length() > 0)
        {
            configuredProfileOptns.clear();
            configuredProfileOptns.add(new selectOption('SVMX.None', getTAG019()));
            Map<string, string> mapProfileConfigured = new Map<string, string>();
            for(SVMXC__ServiceMax_Config_Data__c p : lstConfiguredProfiles )
            {
                if(mapProfileConfigured == null || !mapProfileConfigured.containsKey(p.SVMXC__Access_Configuration_Profile__c))
                {
                    mapProfileConfigured.put(p.SVMXC__Access_Configuration_Profile__c, p.SVMXC__Access_Configuration_Profile__c);
                    if(p.SVMXC__Access_Configuration_Profile__c != selectedProfile)
                        configuredProfileOptns.add(new selectOption(p.SVMXC__Access_Configuration_Profile__c, P.SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c));
                }
            }
            mapProfileConfigured.clear();
            
            
            objNameToLabel = new Map<string, string>();
            Sync_Utility objUtils = new Sync_Utility();
            Map<Id, SVMXC__ServiceMax_Processes__c> processAccess = new  Map<Id, SVMXC__ServiceMax_Processes__c>();
            
            processAccess = objUtils.getSFMTransactions(selectedProfile);
            Sync_Utility.objectAccess objectPermissions = objUtils.getSFMTxObjects(processAccess);
            if(objectPermissions.mapProcessObject != null && objectPermissions.mapProcessObject.size() >0)
            {
                for(string s : objectPermissions.mapProcessObject.keyset())
                {
                    if(objectPermissions.mapProcessObject.get(s) != null && objectPermissions.mapProcessObject.get(s).size() > 0)
                    {
                        SET<string> tempLst1 = new SET<string>();
                        for(string str : objectPermissions.mapProcessObject.get(s))
                        {
                            tempLst1.add(mapAPILabel_Name.get(str));
                            try
                            {
                                objNameToLabel.put(str, mapAPILabel_Name.get(str));
                            }
                            catch(Exception e)
                            {}
                        }
                        mapProcessObject.put(mpProcesses.get(s).SVMXC__ProcessID__c,tempLst1);
                    }
                }
            }
            if(objectPermissions.mapObjectProcess != null && objectPermissions.mapObjectProcess.size() >0)
            {
                for(string s : objectPermissions.mapObjectProcess.keyset())
                {
                    if(objectPermissions.mapObjectProcess.get(s) != null && objectPermissions.mapObjectProcess.get(s).size() > 0)
                    {
                        system.debug('Process Ids for the Object: '+ s + ' :: ' + objectPermissions.mapObjectProcess.get(s));
                        for(string pro : objectPermissions.mapObjectProcess.get(s))
                        {
                            if(mapObjectProcess.size() == 0 || !mapObjectProcess.containsKey(s))
                                mapObjectProcess.put(s,new SET<string>());
                            mapObjectProcess.get(s).add(pro);
                        }
                        system.debug('Process Ids for the Object: '+ s + ' :: ' + mapObjectProcess.get(s));
                    }
                }
            }
            
            objectPermissions.mapProcessObject.clear();
            objectPermissions = null;
            processAccess = null;
            
            for(SVMXC__ServiceMax_Processes__c process : mpProcesses.values())
            {
                if(mapProcessObject.containsKey(process.SVMXC__ProcessID__c))
                {
                    processMap.put(process.id,process);
                    selectedLstPrss.add(process);
                }
            }
            for(String obj : objNameToLabel.keySet())
            {
                system.debug(LoggingLevel.WARN, 'Each Object = ' + obj + objNameToLabel.get(obj));
                if(obj != 'SVMXC__Checklist__c' && obj != 'RecordType' && obj != 'Event' && obj != 'Task' && obj != 'PartnerNetworkConnection' && objNameToLabel.get(obj) != null)
                    txObj.add(new SelectOption(obj, objNameToLabel.get(obj)));
            }
            txObj.add(new selectOption('SVMX.None', getTAG019()));
            txObjAdvDwnld.addAll(txObj);
            txObj = sortingSelectOption(txObj);
            
            txObjAdvDwnld.add(new SelectOption('Attachment', 'Attachment'));
            txObjAdvDwnld = sortingSelectOption(txObjAdvDwnld);
            
            //Salesforce files - include one with default values
            FileConfig fileSetting = new FileConfig(false,'','','');
            fileConfigList.add(fileSetting);
            
            //Set default values for Default group profile
            setDefaultGroupValues(selectedProfile);
            
            if(lstConfiguredProfiles != null && lstConfiguredProfiles.size() > 0)
            {
                lstConfigDataToDelete.clear();
                lstConfigdataDLCriteria.clear();
                lstConfigdata_AdvDwnldCrit.clear();
                boolean setConfgiId = false;
                for(SVMXC__ServiceMax_Config_Data__c configuredProfileData : lstConfiguredProfiles)
                {
                    if(configuredProfileData.SVMXC__Access_Configuration_Profile__c == selectedProfile)
                    {
                        setConfgiId = true;
                        if(configuredProfileData.SVMXC__Display_Type__c != null && configuredProfileData.SVMXC__Display_Type__c.length() > 0 && configuredProfileData.SVMXC__Display_Type__c != 'Advanced Download Criteria' && configuredProfileData.SVMXC__Display_Type__c != 'Download Criteria')
                        {
                            //if(configuredProfileData.SVMXC__Display_Type__c == 'Dataset Synchronization')
                                //syncDataEvery = configuredProfileData.SVMXC__Internal_Value__c;
                            //else 
                            if(configuredProfileData.SVMXC__Display_Type__c == 'Frequency of Master Data')
                                freqMasterData = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Frequency of Application Changes')
                                freqAppChng = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Synchronization To Get Events')
                                syncGetEvent = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Synchronization To Remove Events')
                                syncRemoveEvent = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Conflict Resolution')
                                conflictResol = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Chatter Threads')
                                chatterThreads = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Download Limit For KB')
                                downloadLimitKB = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Location Tracking Frequency')
                                strFreqLocTracking = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Enable Location Tracking')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    isLocationTrack = boolean.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                else
                                    isLocationTrack = false;
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Location History Records to cache')
                                strMaxRecToCache = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Set Technician Location')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    isSetLatestTechLoc = boolean.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                else
                                    isSetLatestTechLoc = false;
                            }
                            //Settings for Purging -- Spring 14 release
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'PURGE_FREQ')
                                freqDataPurging = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'PURGE_REC_OLDER_THAN')
                                purgeOlderRec = configuredProfileData.SVMXC__Internal_Value__c;
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Allow API Access')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    allowAPIAccess = boolean.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                else
                                    allowAPIAccess = false;
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Enable Logging')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    enableLogging = boolean.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                else
                                    enableLogging = false;
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Enable Usage Logging')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    enableUsageLogging = configuredProfileData.SVMXC__Internal_Value__c;
                                else
                                    enableUsageLogging = '';
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Usage Logging User Option')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    usageLogUserOpt = configuredProfileData.SVMXC__Internal_Value__c;
                                else
                                    usageLogUserOpt = 'never';
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Enable Performance Profiling')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    isSyncPerformance = boolean.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                else
                                    isSyncPerformance = false;
                                if(isSyncPerformance)
                                    isSyncPerformanceEnabled = false;
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Enable SOQL Profiling')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    isSoqlPerformance = boolean.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                else
                                    isSoqlPerformance = false;
                            }//EMPP
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Performance Profiling Org Type')
                            {
                                    if(configuredProfileData.SVMXC__Internal_Value__c != null)  
                                        orgTypeUserOption = String.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                    else
                                        orgTypeUserOption = getTag141();
                                        
                                    if(orgTypeUserOption == 'Custom'){
                                        isCustomUrlEnabled = true;
                                    }       
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Performance Profiling Endpoint Url')
                            {
                                    if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                        syncCustomUrl = String.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                    else
                                        syncCustomUrl = ''; 
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Enable Checklist')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    isChecklist = boolean.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                else
                                    isChecklist = false;
                                if(isChecklist)
                                    showChklstOptions = false;
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'Completed Checklists')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    isCompletedChecklist = boolean.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                else
                                    isCompletedChecklist = false;
                            }
                            else if(configuredProfileData.SVMXC__Display_Type__c == 'InProgress Checklists')
                            {
                                if(configuredProfileData.SVMXC__Internal_Value__c != null)
                                    isInProgressChecklist = boolean.valueOf(configuredProfileData.SVMXC__Internal_Value__c);
                                else
                                    isInProgressChecklist = false;
                            }
                            lstConfigDataToDelete.add(configuredProfileData);
                        }
                        if(configuredProfileData.SVMXC__Object_Name__c != null && configuredProfileData.SVMXC__Object_Name__c.length() > 0)
                        {
                                //Salesforce Files
                            if(configuredProfileData.SVMXC__Display_Type__c == 'Advanced Download Criteria' && configuredProfileData.SVMXC__Object_Name__c == 'Files'){
                                if(!String.isBlank(configuredProfileData.SVMXC__SM_Files_Config__c)){
                                    fileConfigList = new List<FileConfig>();
                                    FileConfig eachSetting = (FileConfig)JSON.deserialize(configuredProfileData.SVMXC__SM_Files_Config__c, FileConfig.class);
                                    fileConfigList.add(eachSetting);
                                    system.debug('**** fileConfigList='+fileConfigList);
                                }
                            }
                            else if(mapAPILabel_Name.keySet().contains(configuredProfileData.SVMXC__Object_Name__c))
                            {
                                if(configuredProfileData.SVMXC__Display_Type__c == 'Advanced Download Criteria')
                                {
                                    Object_AdvDwnldCrit.put(configuredProfileData.SVMXC__Object_Name__c , configuredProfileData);
                                    lstConfigdata_AdvDwnldCrit.add(configuredProfileData);
                                }
                                else
                                {
                                    Object_DispatchPorcesMap.put(configuredProfileData.SVMXC__Object_Name__c , configuredProfileData);
                                    lstConfigdataDLCriteria.add(configuredProfileData);
                                }
                            }
                            else
                            {
                                lstInvalidDLCriteria.add(configuredProfileData);
                                system.debug(LoggingLevel.WARN, 'Invalid DL Criteria = ' + lstInvalidDLCriteria);
                            }
                        }
                    }
                }
                
                loadUsageDataOptions();
                
                selectedConfiguredProfile = 'SVMX.None';
                /*if(syncDataEvery == '30')
                {
                    DatasetSynchron = 'Automatically when Online';
                    reminget = false;
                }
                else
                {
                    DatasetSynchron = 'Every';
                    reminget = true;
                }*/
                
                if(lstConfigdataDLCriteria == null || lstConfigdataDLCriteria.size() == 0)
                    addRowDispatch();
                else
                    getConfiguredData(lstConfigdataDLCriteria);
                    
                if(lstConfigdata_AdvDwnldCrit == null || lstConfigdata_AdvDwnldCrit.size() == 0)
                    addRow_AdvDwnldCrit();
                else
                    getConfiguredData(lstConfigdata_AdvDwnldCrit);
            }
            else
            {
                addRowDispatch();
                addRow_AdvDwnldCrit();
            }
        }
        else
            defaultValues();
    }
    
    public void getConfiguredData(List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfigData)
    {
        objConfDataWrapper WrapperConfData;
        Map<string, string> mapObjNameUsed = new Map<string, string>();
        
        if(lstMobileConfigData != null && lstMobileConfigData.size() > 0)
        {
            integer i = 0;
            for(SVMXC__ServiceMax_Config_Data__c confData : lstMobileConfigData)
            {
                if(confData.SVMXC__Display_Type__c != 'Advanced Download Criteria' && (confData.SVMXC__Display_Type__c == 'Download Criteria' || confData.SVMXC__Display_Type__c == null) && confData.SVMXC__Object_Name__c != null)
                {
                    List<selectOption> tempSlctOptn = new List<selectOption>();
                    List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
                    SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
                    SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
                    
                    SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME', confData.SVMXC__Object_Name__c);
                    lstStringMap.add(stringMap1);
                    SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
                    
                    response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
                    
                    tempSlctOptn.clear();
                    tempSlctOptn.add(new SelectOption('SVMX.None', getTAG019()));
                    for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
                        if(tempstringMap.key != null && tempstringMap.key.length() > 0)
                            tempSlctOptn.add(new SelectOption(tempstringMap.key, tempstringMap.value));
                    tempSlctOptn = sortingSelectOption(tempSlctOptn);
                
                    if(i == 0)
                    {
                        string objName = confData.SVMXC__Object_Name__c;
                        WrapperConfData = new objConfDataWrapper(confData, txObj, tempSlctOptn, lstWrapperConfData.size());
                        mapObjNameUsed.put(objName, objName);
                    }
                    else
                    {
                        string objName = confData.SVMXC__Object_Name__c;
                        List<selectOption> tempSlctOptnForObj = new List<selectOption>();
                        for(selectOption so : txObj)
                        {
                            if(!(mapObjNameUsed.containsKey(so.getValue())) )
                                tempSlctOptnForObj.add(so);
                        }
                        WrapperConfData = new objConfDataWrapper(confData, tempSlctOptnForObj, tempSlctOptn, lstWrapperConfData.size());
                        mapObjNameUsed.put(objName, objName);
                    }
                    WrapperConfData.selectedProName = confData.SVMXC__Dispatch_Process__c;
                    
                    if(confData.SVMXC__Dispatch_Process__c != null)
                        WrapperConfData.showEditDel = true;
                    else
                        WrapperConfData.showEditDel = false;
                        
                    system.debug(LoggingLevel.WARN, 'Configured Data wrapper' + WrapperConfData);
                    lstWrapperConfData.add(WrapperConfData);
                    i++;
                }
                else if(confData.SVMXC__Display_Type__c == 'Advanced Download Criteria' && confData.SVMXC__Object_Name__c != null)
                {
                    List<selectOption> tempSlctOptn = new List<selectOption>();
                    tempSlctOptn.add(new SelectOption('SVMX.None', getTAG019()));
                    List<SVMXC__ServiceMax_Processes__c> lstAdvCritExpPro = new List<SVMXC__ServiceMax_Processes__c>();
                    lstAdvCritExpPro = [select id, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Adv Criteria Exp' AND SVMXC__Source_Object_Name__c =: confData.SVMXC__Object_Name__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__ServiceMax_Processes__c critPro: lstAdvCritExpPro)
                        tempSlctOptn.add(new SelectOption(critPro.Id, critPro.SVMXC__Name__c));
                    
                    //WrapperConfData = new objConfDataWrapper(confData, txObj, tempSlctOptn, lstAdvDwnldCriWrp.size());
                    WrapperConfData = new objConfDataWrapper(confData, txObjAdvDwnld, tempSlctOptn, lstAdvDwnldCriWrp.size());
                    lstAdvDwnldCriWrp.add(WrapperConfData);
                }
            }
        }
        ListShort();
        system.debug(LoggingLevel.WARN, 'Configured Data wrapper after sort' + lstWrapperConfData);
    }      
    
    public void ListShort()
    {
        Integer i = 1;
        List<objConfDataWrapper> tempLstWrapperConfData = lstWrapperConfData.clone();
        lstWrapperConfData.clear();
        
        for( i = 1 ; i <= tempLstWrapperConfData.size() ; i++)
        {
            for(objConfDataWrapper s: tempLstWrapperConfData)
            {
                if(i == s.sequenceNo)
                    lstWrapperConfData.add(s);
            }
        }
    }

    
    //---------------- method searching process by  object-------------
    public pageReference searchByObj()
    {
        TopPagMsgDevice = false;
        showTxObj = false;
        selectedLstPrss.clear();
        if(searchByObjKey != 'SVMX.None' && searchByObjKey.length()>0)
        {
            /*for(String processId : processMap.keySet())
            {
                SVMXC__ServiceMax_Processes__c process = processMap.get(processId);
                if(mapProcessObject.containsKey(process.SVMXC__ProcessID__c) && mapProcessObject.get(process.SVMXC__ProcessID__c).contains(mapAPILabel_Name.get(searchByObjKey)))
                selectedLstPrss.add(process);
            }*/
            system.debug('Map Object Process: ' + mapObjectProcess);
            
            system.debug('Process Ids from the Map for the Object: ' + searchByObjKey + ' :is: ' + mapObjectProcess.get(searchByObjKey));
            if(mapObjectProcess.containsKey(searchByObjKey) && mapObjectProcess.get(searchByObjKey) != null && mapObjectProcess.get(searchByObjKey).size() > 0)
            {
                system.debug('Process Ids from the Map for the Object: ' + searchByObjKey + ' :is: ' + mapObjectProcess.get(searchByObjKey));
                for(string str : mapObjectProcess.get(searchByObjKey))
                {
                    selectedLstPrss.add(processMap.get(str));
                }
            }
        }
        else
        {
            for(String processId : processMap.keySet())
            {
                SVMXC__ServiceMax_Processes__c process = processMap.get(processId);
                if(mapProcessObject.containsKey(process.SVMXC__ProcessID__c) )
                    selectedLstPrss.add(process);
            }
        }
        selectedProcessObjs.clear();
        searchByTyp = 'SVMX.None';
        return null;
    }
    
    //-----------------method searching process by  type-------------
    public pageReference searchProcessByType()
    {
        TopPagMsgDevice = false;
        selectedLstPrss.clear();
        showTxObj = false;
        if(searchByTyp != 'SVMX.None' && searchByTyp.length()>0)
        {
            for(String processId : processMap.keySet())
            {
                SVMXC__ServiceMax_Processes__c process = processMap.get(processId);
                if(mapProcessObject.containsKey(process.SVMXC__ProcessID__c) && process.SVMXC__Purpose__c == searchByTyp )
                    selectedLstPrss.add(process);
            }
        }
        else
        {
            for(String processId : processMap.keySet())
            {
                SVMXC__ServiceMax_Processes__c process = processMap.get(processId);
                if(mapProcessObject.containsKey(process.SVMXC__ProcessID__c))
                    selectedLstPrss.add(process);
            }
        }
        selectedProcessObjs.clear();
        searchByObjKey = 'SVMX.None';
        return null;
    }
    
    //--------------- method when user select a process---------------
    public pageReference onSelectProcess()
    {
        TopPagMsgDevice = false;
        selectedProcessName = processMap.get(selectedProcess).SVMXC__Name__c ;
        Set<String> s = mapProcessObject.get(processMap.get(selectedProcess).SVMXC__ProcessID__c);
        selectedProcessObjs.clear();
        showTxObj = true;
        for(String ss : s)
            selectedProcessObjs.add(ss);
        
        return null;
    }
    
    // -------------------- method to add row in dispatch setting ----------
    public void addRowDispatch()
    {
        TopPagMsgDevice = false;
        showExpPopUp = false;
        SVMXC__ServiceMax_Config_Data__c newConfData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTMobileConfig.Id, SVMXC__Sequence__c = (lstWrapperConfData.size() + 1));
        
        List<selectOption> tempOpns = new List<selectOption>();
        if(lstWrapperConfData.size()>0)
        {
            objConfDataWrapper lastVarForWrap = lstWrapperConfData[lstWrapperConfData.size()-1];
            for(selectOption so : lastVarForWrap.objLstOptns)
            {
                if(lastVarForWrap.selectedObjName != so.getValue())
                    tempOpns.add(so);
            }
        }
        else
            tempOpns.addAll(txObj);
        List<selectOption> tempSlctOptn = new List<selectOption>();
        tempSlctOptn.add(new SelectOption('SVMX.None',getTAG019()));
        objConfDataWrapper newVarForWrap = new objConfDataWrapper(newConfData, tempOpns, tempSlctOptn, lstWrapperConfData.size());
        lstWrapperConfData.add(newVarForWrap);
    }
    
    //----------------------------- method for deleting row in dispatch setting--------------
    public pageReference delrow()
    {
        TopPagMsgDevice = false;
        showExpPopUp = false;
        List<Integer> lstSelectedRow = new List<Integer>();
        
        for(objConfDataWrapper tempWrapObj : lstWrapperConfData)
        {
            if(tempWrapObj.IsSelectRow == true)
                lstSelectedRow.add(tempWrapObj.sequenceNo);
        }
        DeletMsg = true;
        ExpMsg = false;
        if(lstSelectedRow.size() == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG080()));
            return null;
        }
        else
        {
            List<objConfDataWrapper> templstWrapperConfDatalst = new List<objConfDataWrapper>();
            Integer j = 1;
            for(Integer selectSerial : lstSelectedRow)
            {
                selectSerial = selectSerial - j;
                j++;
                String SelectObj = lstWrapperConfData.get(selectSerial).selectedObjName ;
                List<objConfDataWrapper> templstWrapperConfData = new List<objConfDataWrapper>();
                objConfDataWrapper tempWrprObj = lstWrapperConfData.remove(selectSerial);
                
                try
                {
                    if(tempWrprObj.ConfDataInObj.Id != null)
                        Delete tempWrprObj.ConfDataInObj;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG091()));
                }
                catch(Exception ex)
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
                }
                
                templstWrapperConfData = lstWrapperConfData.clone();
                lstWrapperConfData.clear();
                Integer i = 1;
                for(objConfDataWrapper obj : templstWrapperConfData)
                {
                    obj.ConfDataInObj.SVMXC__Sequence__c = i;
                    obj.sequenceNo = i;
                    if(SelectObj != 'SVMX.None')
                    obj.objLstOptns.add(new SelectOption( SelectObj , mapAPILabel_Name.get(SelectObj) ));
                    
                    List<selectOption> temp = new List<selectOption>();
                    for(selectOption op : obj.objLstOptns)
                    {
                        if(op.getValue() != 'SVMX.None')
                            temp.add(op);
                    }
                    List<selectOption> tempTxObj = new List<selectOption>();
                    tempTxObj = sortingSelectOption(temp);
                    obj.objLstOptns.clear();
                    obj.objLstOptns.add(new SelectOption('SVMX.None',getTAG019()));
                    obj.objLstOptns.addAll(tempTxObj); 
                    tempTxObj.clear();
                    temp.clear();
                    lstWrapperConfData.add(obj);
                    i++;
                }
                templstWrapperConfData.clear();
            }
        }
        
        lstSelectedRow.clear();
        if(lstWrapperConfData.size() == 0)
            addRowDispatch();
        return null;
    }
    
    // -------------------- method to add row in Advanced Download Criteria ----------
    public void addRow_AdvDwnldCrit()
    {
        TopPagMsgDevice = false;
        showExp_AdvDwnldCrit = false;
        SVMXC__ServiceMax_Config_Data__c newConfData = new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = RTMobileConfig.Id, SVMXC__Sequence__c = (lstAdvDwnldCriWrp.size() + 1));
        
        List<selectOption> tempSlctOptn = new List<selectOption>();
        tempSlctOptn.add(new SelectOption('SVMX.None',getTAG019()));
        //objConfDataWrapper newVarForWrap = new objConfDataWrapper(newConfData, txObj, tempSlctOptn, lstAdvDwnldCriWrp.size());
        objConfDataWrapper newVarForWrap = new objConfDataWrapper(newConfData, txObjAdvDwnld, tempSlctOptn, lstAdvDwnldCriWrp.size());
        lstAdvDwnldCriWrp.add(newVarForWrap);
        
        for(objConfDataWrapper wr : lstAdvDwnldCriWrp)
            wr.IsSelectRow = false;
    }
    
    //----------------------------- method for deleting row in Advanced Download Criteria--------------
    public pageReference delrow_AdvDwnldCrit()
    {
        TopPagMsgDevice = false;
        showExp_AdvDwnldCrit = false;
        List<Integer> lstSelectedRow = new List<Integer>();
        
        for(objConfDataWrapper tempWrapObj : lstAdvDwnldCriWrp)
        {
            if(tempWrapObj.IsSelectRow == true)
                lstSelectedRow.add(tempWrapObj.sequenceNo);
        }
        DeletMsg = true;
        //ExpMsg = false;
        if(lstSelectedRow.size() == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG080()));
            return null;
        }
        else
        {
            List<objConfDataWrapper> templstAdvDwnldCriWrplst = new List<objConfDataWrapper>();
            Integer j = 1;
            for(Integer selectSerial : lstSelectedRow)
            {
                selectSerial = selectSerial - j;
                j++;
                String SelectObj = lstAdvDwnldCriWrp.get(selectSerial).selectedObjName ;
                List<objConfDataWrapper> templstAdvDwnldCriWrp = new List<objConfDataWrapper>();
                objConfDataWrapper tempWrprObj = lstAdvDwnldCriWrp.remove(selectSerial);
                
                try
                {
                    if(tempWrprObj.ConfDataInObj.Id != null)
                        Delete tempWrprObj.ConfDataInObj;
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG091()));
                }
                catch(Exception ex)
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
                }
                
                templstAdvDwnldCriWrp = lstAdvDwnldCriWrp.clone();
                lstAdvDwnldCriWrp.clear();
                Integer i = 1;
                for(objConfDataWrapper obj : templstAdvDwnldCriWrp)
                {
                    obj.ConfDataInObj.SVMXC__Sequence__c = i;
                    obj.sequenceNo = i;
                    if(SelectObj != 'SVMX.None')
                    obj.objLstOptns.add(new SelectOption( SelectObj , mapAPILabel_Name.get(SelectObj) ));
                    
                    lstAdvDwnldCriWrp.add(obj);
                    i++;
                }
                templstAdvDwnldCriWrp.clear();
            }
        }
        
        lstSelectedRow.clear();
        if(lstAdvDwnldCriWrp.size() == 0)
            addRow_AdvDwnldCrit();
        return null;
    }
    
    // -------------------------- method for select an object----------------
    public void onSelectObj()
    {
        TopPagMsgDevice = false;
        showExpPopUp = false;
        List<objConfDataWrapper> templstWrapperConfData = new List<objConfDataWrapper>();
        templstWrapperConfData = lstWrapperConfData.clone();
        lstWrapperConfData.clear();
        for(objConfDataWrapper obj : templstWrapperConfData)
        {
            if(selectedObjSerial == Math.round(obj.sequenceNo))
            {
                SVMXC__ServiceMax_Config_Data__c tempCnfigDtaObj = obj.ConfDataInObj;
                if(tempCnfigDtaObj.Id != null)
                {
                    if(selectedConfiguredProfile == 'SVMX.None')
                    {
                        Object_DispatchPorcesMap.remove(tempCnfigDtaObj.SVMXC__Object_Name__c);
                        lstConfigDataToDelete.add(tempCnfigDtaObj);
                        List<SVMXC__ServiceMax_Config_Data__c> tempCfgLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                        tempCfgLst= lstConfigdataDLCriteria.clone();
                        lstConfigdataDLCriteria.clear();
                        for(SVMXC__ServiceMax_Config_Data__c tempdata : tempCfgLst)
                        {
                            if(tempCnfigDtaObj != tempdata)
                                lstConfigdataDLCriteria.add(tempdata);
                        }
                        tempCfgLst.clear();
                    }
                }
                
                
                if(obj.selectedObjName != 'SVMX.None' && obj.selectedObjName != null)
                {
                    List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
                    
                    SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME', obj.selectedObjName);
                    lstStringMap.add(stringMap1);
                    
                    SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
                    
                    SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
                    SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
                    response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
                    obj.proLstOptns.clear();
                    obj.proLstOptns.add(new SelectOption('SVMX.None', getTAG019()));
                    for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
                        if(tempstringMap.key != null && tempstringMap.key.length() > 0)
                            obj.proLstOptns.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
                    obj.proLstOptns = sortingSelectOption(obj.proLstOptns);
                    obj.renderStngOptn = false;
                    obj.showEditDel = false;
                    obj.Dectfld = false;
                        
                    SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
                    String objectName = obj.selectedObjName ;
                    
                    MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
                    objectName = utils.getOriginalAPIName(objectName, allObjs);
                    Schema.SObjectType selectedObject = allObjs.get(objectName);

                    Schema.DescribeSObjectResult objDescribe = selectedObject.getDescribe();
                    Map<String,Schema.SObjectField> fieldMapping = objDescribe.fields.getMap();
                    Integer i = 0;
                    for(Schema.SObjectField fieldMap: fieldMapping.values())
                    {
                        i++;
                        if(fieldMap.getDescribe().getName() == 'OwnerId')
                            obj.Dectfld = true;
                    }
                    
                    if(obj.Dectfld == false)
                        obj.userAccess = 'All Records';
                }
                else
                {
                    obj.proLstOptns.clear();
                    obj.proLstOptns.add(new selectOption('SVMX.None', getTAG019()));
                    obj.renderStngOptn = true;
                }
            }
            lstWrapperConfData.add(obj);
        }
        templstWrapperConfData.clear();
    }
    
    // -------------------------- method for select an object in Advanced Download Criteria ----------------
    public void onSelect_AdvDwnldCritObj()
    {
        TopPagMsgDevice = false;
        showExp_AdvDwnldCrit = false;
        List<objConfDataWrapper> templstAdvDwnldCriWrp = new List<objConfDataWrapper>();
        templstAdvDwnldCriWrp = lstAdvDwnldCriWrp.clone();
        lstAdvDwnldCriWrp.clear();
        for(objConfDataWrapper obj : templstAdvDwnldCriWrp)
        {
            obj.IsSelectRow = false;
            if(selectedObjSerial == Math.round(obj.sequenceNo))
            {
                SVMXC__ServiceMax_Config_Data__c tempCnfigDtaObj = obj.ConfDataInObj;
                if(tempCnfigDtaObj.Id != null)
                {
                    if(selectedConfiguredProfile == 'SVMX.None')
                    {
                        Object_AdvDwnldCrit.remove(tempCnfigDtaObj.SVMXC__Object_Name__c);
                        lstConfigDataToDelete.add(tempCnfigDtaObj);
                        List<SVMXC__ServiceMax_Config_Data__c> tempCfgLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                        tempCfgLst= lstConfigdata_AdvDwnldCrit.clone();
                        lstConfigdata_AdvDwnldCrit.clear();
                        for(SVMXC__ServiceMax_Config_Data__c tempdata : tempCfgLst)
                        {
                            if(tempCnfigDtaObj != tempdata)
                                lstConfigdata_AdvDwnldCrit.add(tempdata);
                        }
                        tempCfgLst.clear();
                    }
                }
                
                if(obj.selectedObjName != 'SVMX.None' && obj.selectedObjName != null)
                {
                    obj.proLstOptns.clear();
                    obj.proLstOptns.add(new SelectOption('SVMX.None', getTAG019()));
                    
                    List<SVMXC__ServiceMax_Processes__c> lstAdvCritExpPro = new List<SVMXC__ServiceMax_Processes__c>();
                    lstAdvCritExpPro = [select id, SVMXC__Name__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Adv Criteria Exp' AND SVMXC__Source_Object_Name__c =: obj.selectedObjName];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    for(SVMXC__ServiceMax_Processes__c critPro: lstAdvCritExpPro)
                        obj.proLstOptns.add(new SelectOption(critPro.Id, critPro.SVMXC__Name__c));
                        
                    obj.renderStngOptn = false;
                    obj.showEditDel = false;
                    obj.Dectfld = false;
                    
                    SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
                    String objectName = obj.selectedObjName ;
                    
                    MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
                    objectName = utils.getOriginalAPIName(objectName, allObjs);
                    Schema.SObjectType selectedObject = allObjs.get(objectName);

                    Schema.DescribeSObjectResult objDescribe = selectedObject.getDescribe();
                    Map<String,Schema.SObjectField> fieldMapping = objDescribe.fields.getMap();
                    for(Schema.SObjectField fieldMap: fieldMapping.values())
                    {
                        if(fieldMap.getDescribe().getName() == 'OwnerId')
                            obj.Dectfld = true;
                    }
                    
                    if(obj.Dectfld == false)
                        obj.userAccess = 'All Records';
                }
                else
                {
                    obj.proLstOptns.clear();
                    obj.proLstOptns.add(new selectOption('SVMX.None', getTAG019()));
                    obj.renderStngOptn = true;
                }
            }
            lstAdvDwnldCriWrp.add(obj);
        }
        templstAdvDwnldCriWrp.clear();
    }
    
    //----------------------------------------- Method to retrieve Expression Details ---------------------------------------------
    public SFM_WrapperDef.SFM_Response_Expression retrieveExpDetails(string expId)
    {
        SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
        SFM_WrapperDef.SFM_StringMap stringMap3 = new SFM_WrapperDef.SFM_StringMap('EXPRESSIONID',expId);
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(stringMap3);
        SFM_WrapperDef.SFM_Request request2 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        responseExp = namedExpLst.SFM_getNamedExpressionList(request2);
        return responseExp;
    }
    
    //------------------------------- method for select Download Criteria Expression----------------------
    public SFM_WrapperDef.SFM_Expression ExpToShow = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getExpToShow(){return this.ExpToShow;}
    public void setExpToShow(SFM_WrapperDef.SFM_Expression ex){this.ExpToShow = ex;}
    
    public void onSelectSetting()
    {
        TopPagMsgDevice = false;
        showExpPopUp = false;
        List<objConfDataWrapper> templstWrapperConfData = new List<objConfDataWrapper>();
        templstWrapperConfData = lstWrapperConfData.clone();
        lstWrapperConfData.clear();
        for(objConfDataWrapper obj : templstWrapperConfData)
        {
            if(selectedObjSerial == Math.round(obj.sequenceNo))
            {
                if(obj.selectedProName != null && obj.selectedProName != 'SVMX.None')
                    obj.showEditDel = true;
                else
                    obj.showEditDel = false;
            }
            lstWrapperConfData.add(obj);
        }
        templstWrapperConfData.clear();
    }
    
    public void onSelectPro_AdvDwnldCrit()
    {
        TopPagMsgDevice = false;
        showExp_AdvDwnldCrit = false;
        List<objConfDataWrapper> templstAdvDwnldCriWrp = new List<objConfDataWrapper>();
        templstAdvDwnldCriWrp = lstAdvDwnldCriWrp.clone();
        lstAdvDwnldCriWrp.clear();
        for(objConfDataWrapper obj : templstAdvDwnldCriWrp)
        {
            obj.IsSelectRow = false;
            if(selectedObjSerial == Math.round(obj.sequenceNo))
            {
                if(obj.selectedProName != null && obj.selectedProName != 'SVMX.None')
                    obj.showEditDel = true;
                else
                    obj.showEditDel = false;
            }
            lstAdvDwnldCriWrp.add(obj);
        }
        templstAdvDwnldCriWrp.clear();
    }
    
    public List<SVMXC__ServiceMax_Config_Data__c> addConfData(string displayType, string syncDataEvery, string unit, List<SVMXC__ServiceMax_Config_Data__c> lstToAdd,List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigs)
    {
        SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
        confData.SVMXC__Display_Type__c = displayType;
        confData.SVMXC__Parameter_Name__c = unit;
        confData.SVMXC__Internal_Value__c = syncDataEvery;
        confData.SVMXC__Access_Configuration_Profile__c = selectedProfile;
        confData.RecordTypeId = RTMobileConfig.Id;
    //Device Targeted
        if(listOfConfigs !=NULL && !listOfConfigs.isEmpty() && listOfConfigs[0].Id !=NULL)
        {
            confData.SM_Device_Mobile_Config__c = listOfConfigs[0].Id;        
        }        
        lstToAdd.add(confData);
        return lstToAdd;
    }
    
    public void save(List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigs)
    {
        DeletMsg = false;
        ExpMsg = false;
        TopPagMsgDevice = true;
 
        //if(syncDataEvery == null || syncDataEvery.length() == 0)
        if(freqMasterData == null || freqMasterData.length() == 0 || freqAppChng == null || freqAppChng.length() == 0 || syncGetEvent == null ||syncGetEvent.length() == 0 ||
           syncRemoveEvent == null || syncRemoveEvent.length() == 0 || chatterThreads == null || chatterThreads.length() == 0 ||
           downloadLimitKB == null || downloadLimitKB.length() == 0 || strFreqLocTracking == null || strFreqLocTracking.length() == 0 ||
           strMaxRecToCache == null || strMaxRecToCache.length() == 0 || freqDataPurging == null || freqDataPurging.length() == 0 || purgeOlderRec == null || purgeOlderRec.length() == 0 || (isCustomUrlEnabled && (syncCustomUrl == NULL || syncCustomUrl == '')))
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG013()));
            return;
        }
        
        if(lstInvalidDLCriteria != null && lstInvalidDLCriteria.size() > 0)
        {
            lstInvalidDLCriteria.clear();
        }
        
        system.debug(LoggingLevel.WARN, 'Config data to delete= ' + lstConfigDataToDelete);
        
        if(lstConfigDataToDelete != null && lstConfigDataToDelete.size() > 0)
        {
            lstConfigDataToDelete.clear();
        }
        List<SVMXC__ServiceMax_Config_Data__c> configDataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        if(isLocationTrack)
            strEnableLocTrack = 'true';
        else
            strEnableLocTrack = 'false';
            
        configDataToSave = addConfData('Frequency of Master Data', freqMasterData, 'min', configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Frequency of Application Changes', freqAppChng, 'min', configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Synchronization To Get Events', syncGetEvent, 'days', configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Synchronization To Remove Events', syncRemoveEvent, 'days', configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Conflict Resolution', conflictResol, null, configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Chatter Threads', chatterThreads, 'threads', configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Download Limit For KB', downloadLimitKB, 'MB', configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Location Tracking Frequency', strFreqLocTracking, 'min', configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Enable Location Tracking', strEnableLocTrack, null, configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Location History Records to cache', strMaxRecToCache, null, configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Enable Checklist', String.valueOf(isChecklist), null, configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Completed Checklists', String.valueOf(isCompletedChecklist), null, configDataToSave,listOfConfigs);
        configDataToSave = addConfData('InProgress Checklists', String.valueOf(isInProgressChecklist), null, configDataToSave,listOfConfigs);
        
        if(isSetLatestTechLoc)
            configDataToSave = addConfData('Set Technician Location', 'true', null, configDataToSave,listOfConfigs);
        else
            configDataToSave = addConfData('Set Technician Location', 'false', null, configDataToSave,listOfConfigs);
        
        //Setting for Purging -- Spring 14 release
        configDataToSave = addConfData('PURGE_FREQ', freqDataPurging, 'hours', configDataToSave,listOfConfigs);
        configDataToSave = addConfData('PURGE_REC_OLDER_THAN', purgeOlderRec, 'days', configDataToSave,listOfConfigs);
        configDataToSave = addConfData('CONFIG_LAST_MOD', string.valueofgmt(system.now()), null, configDataToSave,listOfConfigs);
        if(allowAPIAccess)
            configDataToSave = addConfData('Allow API Access', 'true', null, configDataToSave,listOfConfigs);
        else
            configDataToSave = addConfData('Allow API Access', 'false', null, configDataToSave,listOfConfigs);
        if(enableLogging)
            configDataToSave = addConfData('Enable Logging', 'true', null, configDataToSave,listOfConfigs);
        else
            configDataToSave = addConfData('Enable Logging', 'false', null, configDataToSave,listOfConfigs);
        
        configDataToSave = addConfData('Enable Usage Logging', enableUsageLogging, null, configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Usage Logging User Option', usageLogUserOpt, null, configDataToSave,listOfConfigs);
        
        configDataToSave = addConfData('Enable Performance Profiling', String.valueOf(isSyncPerformance), null, configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Enable SOQL Profiling', String.valueOf(isSoqlPerformance), null, configDataToSave,listOfConfigs);
        
        //EMPP  
        configDataToSave = addConfData('Performance Profiling Org Type', String.valueOf(orgTypeUserOption), null, configDataToSave,listOfConfigs);
        configDataToSave = addConfData('Performance Profiling Endpoint Url', String.valueOf(syncCustomUrl), null, configDataToSave,listOfConfigs);
        
        //Salesforce Files
        SVMXC__ServiceMax_Config_Data__c fileConfData = new SVMXC__ServiceMax_Config_Data__c();
        fileConfData.SVMXC__Display_Type__c = 'Advanced Download Criteria';
        fileConfData.SVMXC__SM_Files_Config__c = JSON.serialize(fileConfigList[0]);
        fileConfData.SVMXC__Object_Name__c = 'Files';
        fileConfData.SVMXC__Access_Configuration_Profile__c = selectedProfile;
        fileConfData.RecordTypeId = RTMobileConfig.Id;
        if(listOfConfigs != NULL && !listOfConfigs.isEmpty() && listOfConfigs[0].Id !=NULL){
            fileConfData.SM_Device_Mobile_Config__c = listOfConfigs[0].Id;        
        }
        configDataToSave.add(fileConfData);
        
        boolean ClonePofileCopy = true;
        
        system.debug(LoggingLevel.WARN, 'Selected Configured profile= ' + selectedConfiguredProfile);
        
        if(selectedConfiguredProfile != 'SVMX.None')
        {
            ClonePofileCopy = false;
            if(lstConfigdataDLCriteria != null && lstConfigdataDLCriteria.size() > 0)
            {
                lstConfigdataDLCriteria.clear();
            }
            if(lstConfigdata_AdvDwnldCrit != null && lstConfigdata_AdvDwnldCrit.size() > 0)
            {
                lstConfigdata_AdvDwnldCrit.clear();
            }
        }
        
        system.debug(LoggingLevel.WARN, 'Clone Profile Copy= ' + ClonePofileCopy);
        
        if(!ClonePofileCopy)
        {
            Object_DispatchPorcesMap.clear();
            Object_AdvDwnldCrit.clear();
        }
        
        system.debug(LoggingLevel.WARN, 'Download Criteria Wrapper= ' + lstWrapperConfData);
        
        if(lstWrapperConfData != null && lstWrapperConfData.size() > 0)
        {
            for(objConfDataWrapper wrpTemp : lstWrapperConfData)
            {
                system.debug(LoggingLevel.WARN, 'Download Criteria Wrapper Object Name= ' + wrpTemp.selectedObjName);
                
                if(wrpTemp.selectedObjName != 'SVMX.None')
                {
                    if(Object_DispatchPorcesMap.containsKey(wrpTemp.selectedObjName))
                    {
                        system.debug(LoggingLevel.WARN, 'Entered in the map clause edit Criteria= ' + wrpTemp.selectedProName + ' :And Dispatch Process: ' + Object_DispatchPorcesMap.get(wrpTemp.selectedObjName).SVMXC__Dispatch_Process__c);
                        
                        string strGetValue = wrpTemp.selectedProName;
                        if(strGetValue != 'SVMX.None' || Object_DispatchPorcesMap.get(wrpTemp.selectedObjName).SVMXC__Dispatch_Process__c != null)
                        {
                        
                            system.debug(LoggingLevel.WARN, 'Get Value:= ' + strGetValue);
                            
                            SVMXC__ServiceMax_Config_Data__c tempconfData = new SVMXC__ServiceMax_Config_Data__c();
                            tempconfData.SVMXC__Object_Name__c = wrpTemp.selectedObjName;
                            if(wrpTemp.selectedProName == 'SVMX.None')
                                tempconfData.SVMXC__Dispatch_Process__c = null;
                            else
                                tempconfData.SVMXC__Dispatch_Process__c = wrpTemp.selectedProName;
                            tempconfData.SVMXC__Access_Configuration_Profile__c = selectedProfile;
                            tempconfData.SVMXC__Ownership_Type__c = wrpTemp.userAccess ;
                            tempconfData.SVMXC__Sequence__c = wrpTemp.sequenceNo;
                            tempconfData.RecordTypeId = RTMobileConfig.Id;
                            tempconfData.SVMXC__Display_Type__c = 'Download Criteria';
//Device Targeted                                
                            tempconfData.SM_Device_Mobile_Config__c = listOfConfigs[0].Id;
                            tempconfData = tempconfData.clone(false);                                                                  
                            system.debug(LoggingLevel.WARN, 'Config Data Updated= ' + tempconfData);
                            
                            configDataToSave.add(tempconfData);      
                        }
                        if(strGetValue == 'SVMX.None' && Object_DispatchPorcesMap.get(wrpTemp.selectedObjName).SVMXC__Dispatch_Process__c == null)
                        {
                            
                            system.debug(LoggingLevel.WARN, 'Get Value None & Dispatch Process Null:= ');
                            
                            SVMXC__ServiceMax_Config_Data__c tempconfData = new SVMXC__ServiceMax_Config_Data__c();
                            tempconfData.SVMXC__Object_Name__c = wrpTemp.selectedObjName;
                            if(wrpTemp.selectedProName == 'SVMX.None')
                                tempconfData.SVMXC__Dispatch_Process__c = null;
                            else
                                tempconfData.SVMXC__Dispatch_Process__c = wrpTemp.selectedProName;
                            tempconfData.SVMXC__Access_Configuration_Profile__c = selectedProfile;
                            tempconfData.SVMXC__Ownership_Type__c = wrpTemp.userAccess ;
                            tempconfData.SVMXC__Sequence__c = wrpTemp.sequenceNo;
                            tempconfData.RecordTypeId = RTMobileConfig.Id;
                            tempconfData.SVMXC__Display_Type__c = 'Download Criteria';
//Device Targeted                                
                            tempconfData.SM_Device_Mobile_Config__c = listOfConfigs[0].Id;   
                            tempconfData = tempconfData.clone(false);                                                       
                            system.debug(LoggingLevel.WARN, 'Updated Config Data:= ' + tempconfData);
                            
                            configDataToSave.add(tempconfData);     
                        } 
                    }
                    else
                    {
                        SVMXC__ServiceMax_Config_Data__c tempconfData = new SVMXC__ServiceMax_Config_Data__c();
                        tempconfData.SVMXC__Object_Name__c = wrpTemp.selectedObjName;
                        if(wrpTemp.selectedProName == 'SVMX.None')
                            tempconfData.SVMXC__Dispatch_Process__c = null;
                        else
                            tempconfData.SVMXC__Dispatch_Process__c = wrpTemp.selectedProName;
                        tempconfData.SVMXC__Access_Configuration_Profile__c = selectedProfile;
                        tempconfData.SVMXC__Sequence__c = wrpTemp.sequenceNo;
                        tempconfData.SVMXC__Ownership_Type__c = wrpTemp.userAccess ;
                        tempconfData.RecordTypeId = RTMobileConfig.Id;
                        tempconfData.SVMXC__Display_Type__c = 'Download Criteria';
//Device Targeted                                
                        tempconfData.SM_Device_Mobile_Config__c = listOfConfigs[0].Id;
                        tempconfData = tempconfData.clone(false);                                          
                        system.debug(LoggingLevel.WARN, 'New Config Data:= ' + tempconfData);
                        
                        configDataToSave.add(tempconfData);
                    }
                }
            }
        }
        
        system.debug(LoggingLevel.WARN, 'Advanced Download Criteria Wrapper= ' + lstAdvDwnldCriWrp);
        
        if(lstAdvDwnldCriWrp != null && lstAdvDwnldCriWrp.size() > 0)
        {
            lstAdvDwnldCriWrp = sortListOfWrapper(lstAdvDwnldCriWrp);
        
            integer seq = 1;
            for(objConfDataWrapper wrpTemp : lstAdvDwnldCriWrp)
            {
                system.debug(LoggingLevel.WARN, 'Advanced Download Criteria Wrapper Object Name= ' + wrpTemp.selectedObjName + ' :Process Name: ' + wrpTemp.selectedProName);
                
                if(wrpTemp.selectedObjName != 'SVMX.None' && wrpTemp.selectedProName != 'SVMX.None' && wrpTemp.selectedObjName != null && wrpTemp.selectedProName != null)
                {
                    system.debug(LoggingLevel.WARN, 'Entered with wrapper' + wrpTemp + ' :And the sequence is: ' + seq);
                    if(Object_AdvDwnldCrit.containsKey(wrpTemp.selectedObjName))
                    {
                        system.debug(LoggingLevel.WARN, 'ADC Entered in the map clause edit Criteria= ' + wrpTemp.selectedProName + ' :And Dispatch Process: ' + Object_AdvDwnldCrit.get(wrpTemp.selectedObjName).SVMXC__Dispatch_Process__c);
                        
                        string strGetValue = wrpTemp.selectedProName;
                        if(strGetValue != 'SVMX.None' || Object_AdvDwnldCrit.get(wrpTemp.selectedObjName).SVMXC__Dispatch_Process__c != null || Integer.valueOf(Object_AdvDwnldCrit.get(wrpTemp.selectedObjName).SVMXC__Sequence__c) != seq)
                        {
                            
                            system.debug(LoggingLevel.WARN, 'ADC Get Value:= ' + strGetValue);
                            
                            SVMXC__ServiceMax_Config_Data__c tempconfData = new SVMXC__ServiceMax_Config_Data__c();
                            tempconfData.SVMXC__Object_Name__c = wrpTemp.selectedObjName;
                            if(wrpTemp.selectedProName == 'SVMX.None')
                                tempconfData.SVMXC__Dispatch_Process__c = null;
                            else
                                tempconfData.SVMXC__Dispatch_Process__c = wrpTemp.selectedProName;
                            tempconfData.SVMXC__Access_Configuration_Profile__c = selectedProfile;
                            tempconfData.SVMXC__Ownership_Type__c = wrpTemp.userAccess ;
                            tempconfData.SVMXC__Sequence__c = seq;
                            tempconfData.RecordTypeId = RTMobileConfig.Id;
                            tempconfData.SVMXC__Display_Type__c = 'Advanced Download Criteria';
//Device Targeted
                            tempconfData.SM_Device_Mobile_Config__c = listOfConfigs[0].Id; 
                            tempconfData = tempconfData.clone(false);                                                             
                            system.debug(LoggingLevel.WARN, 'ADC Config Data Updated= ' + tempconfData);
                            
                            configDataToSave.add(tempconfData);      
                        }
                        if(strGetValue == 'SVMX.None' && Object_AdvDwnldCrit.get(wrpTemp.selectedObjName).SVMXC__Dispatch_Process__c == null)
                        {
                            
                            system.debug(LoggingLevel.WARN, 'ADC Get Value None & Dispatch Process Null:= ');
                            
                            if(Object_AdvDwnldCrit.get(wrpTemp.selectedObjName).SVMXC__Ownership_Type__c != wrpTemp.userAccess || Integer.valueOf(Object_AdvDwnldCrit.get(wrpTemp.selectedObjName).SVMXC__Sequence__c) != seq)
                            {
                                SVMXC__ServiceMax_Config_Data__c tempconfData = wrpTemp.ConfDataInObj;
                                tempconfData.SVMXC__Object_Name__c = wrpTemp.selectedObjName;
                                if(wrpTemp.selectedProName == 'SVMX.None')
                                    tempconfData.SVMXC__Dispatch_Process__c = null;
                                else
                                    tempconfData.SVMXC__Dispatch_Process__c = wrpTemp.selectedProName;
                                tempconfData.SVMXC__Access_Configuration_Profile__c = selectedProfile;
                                tempconfData.SVMXC__Ownership_Type__c = wrpTemp.userAccess ;
                                tempconfData.SVMXC__Sequence__c = seq;
                                tempconfData.RecordTypeId = RTMobileConfig.Id;
                                tempconfData.SVMXC__Display_Type__c = 'Advanced Download Criteria';
                                //Device Targeted
                                tempconfData.SM_Device_Mobile_Config__c = listOfConfigs[0].Id; 
                                tempconfData = tempconfData.clone(false);                                                                                             
                                system.debug(LoggingLevel.WARN, 'ADC Updated Config Data:= ' + tempconfData);
                                
                                configDataToSave.add(tempconfData);
                            }  
                                   
                        } 
                    }
                    else
                    {
                        SVMXC__ServiceMax_Config_Data__c tempconfData = new SVMXC__ServiceMax_Config_Data__c();
                        tempconfData.SVMXC__Object_Name__c = wrpTemp.selectedObjName;
                        if(wrpTemp.selectedProName == 'SVMX.None')
                            tempconfData.SVMXC__Dispatch_Process__c = null;
                        else
                            tempconfData.SVMXC__Dispatch_Process__c = wrpTemp.selectedProName;
                        tempconfData.SVMXC__Access_Configuration_Profile__c = selectedProfile;
                        tempconfData.SVMXC__Sequence__c = seq;
                        tempconfData.SVMXC__Ownership_Type__c = wrpTemp.userAccess ;
                        tempconfData.RecordTypeId = RTMobileConfig.Id;
                        tempconfData.SVMXC__Display_Type__c = 'Advanced Download Criteria';
//Device Targeted
                        tempconfData.SM_Device_Mobile_Config__c = listOfConfigs[0].Id; 
                        tempconfData = tempconfData.clone(false);                                                 
                        system.debug(LoggingLevel.WARN, 'ADC New Config Data:= ' + tempconfData);
                        
                        configDataToSave.add(tempconfData);
                    }
                    seq++;
                }
                else if(wrpTemp.selectedObjName != 'SVMX.None' && wrpTemp.selectedObjName != null && Object_AdvDwnldCrit.get(wrpTemp.selectedObjName) != null && (wrpTemp.selectedProName == 'SVMX.None' || wrpTemp.selectedProName == null))
                {
                    lstConfigDataToDelete.add(Object_AdvDwnldCrit.get(wrpTemp.selectedObjName));
                }
            }
        }
        
        if(configDataToSave != null && configDataToSave.size() > 0)
        {
            boolean isFieldAccessIssue = false;
            try
            {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(configDataToSave, COMM_SecurityUtils.Access.Upsertable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    upsert configDataToSave;
                }
                else{
                    isFieldAccessIssue = true;
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    return;
                }
                configDataToSave.clear();
                if(lstConfigDataToDelete != null && lstConfigDataToDelete.size() > 0)
                {
                    lstConfigDataToDelete.clear();
                }
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG090()));
            }
            catch(Exception ex)
            {
                if(isFieldAccessIssue)
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                else
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
            }
            
        }
        queryingData();
        preparingPickLists();
        TopPagMsgDevice = true;
    }
    
    public List<objConfDataWrapper> sortListOfWrapper(List<objConfDataWrapper> lstAdvDwnldCriWrp)
    {
        List<objConfDataWrapper> tempWrap = new List<objConfDataWrapper>();
        Map<integer, objConfDataWrapper> mapSeqWrap = new Map<integer, objConfDataWrapper>();
        
        for(objConfDataWrapper wr : lstAdvDwnldCriWrp)
            mapSeqWrap.put(wr.sequenceNo, wr);
        
        for(integer i : mapSeqWrap.keyset())
            tempWrap.add(mapSeqWrap.get(i));
        
        return tempWrap;
    }
    
    public pageReference GoSetupHome()
    {
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        PageReference HomePage = new PageReference(url);
        HomePage.setRedirect(true);
        return HomePage; 
    }
    
    //-----------------------------------------------Method to add new filter----------------------------------------------------------------
    public void AddFilter()
    {
        TopPagMsgDevice = false;
        showExpPopUp = true;
        List<objConfDataWrapper> templstWrapperConfData = new List<objConfDataWrapper>();
        templstWrapperConfData = lstWrapperConfData.clone();
        lstWrapperConfData.clear();
        for(objConfDataWrapper obj : templstWrapperConfData)
        {
            if(selectedObjSerial == Math.round(obj.sequenceNo))
            {
                obj.showEditDel = false;
                obj.selectedProName = null;
                ObjNameFrSaveExp = obj.selectedObjName ;
            }
            lstWrapperConfData.add(obj);
        }
        templstWrapperConfData.clear();
        ExpToShow = new SFM_WrapperDef.SFM_Expression();
        
        COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        Hdrfldlist.clear();
        Hdrfldlist.add(new SelectOption('SVMX.NONE',getTAG019()));
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        DispMethods.RetriveField(ObjNameToFilter, Hdrfldlist, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        HdrADDRow(); 
    }

    //-----------------------------------------------Method to edit the selected filter----------------------------------------------------------------
    public void EditFilter()
    {
        TopPagMsgDevice = false;
        showExpPopUp = true;
        SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
        
        COMM_SVMXC_Search_Expressions HdrExpressions = new COMM_SVMXC_Search_Expressions(2);
        ObjNameFrSaveExp = ObjNameToFilter;
        Hdrfldlist.clear();
        Hdrfldlist.add(new SelectOption('SVMX.None',getTAG019()));
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        DispMethods.RetriveField(ObjNameToFilter, Hdrfldlist, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        responseExp = retrieveExpDetails(editFilterId);
        ExpToShow = new SFM_WrapperDef.SFM_Expression();
        if(responseExp.expressions.size() > 0)
        {
            ExpToShow = responseExp.expressions[0];
            ExpDetailSize = ExpToShow.expressionDetails.size();
            Map_SequenceNumRec.clear();
            for(SVMXC__ServiceMax_Config_Data__c confData : ExpToShow.expressionDetails)
                Map_SequenceNumRec.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
        }
    }
    
    //-----------------------------------------------Method to add new filter----------------------------------------------------------------
    public void AdvDwnldCrit_AddFilter()
    {
        COMM_Utils comUtil = new COMM_Utils();
        TopPagMsgDevice = false;
        showExp_AdvDwnldCrit = true;
        List<objConfDataWrapper> templstWrapperConfData = new List<objConfDataWrapper>();
        templstWrapperConfData = lstAdvDwnldCriWrp.clone();
        lstAdvDwnldCriWrp.clear();
        for(objConfDataWrapper obj : templstWrapperConfData)
        {
            if(selectedObjSerial == Math.round(obj.sequenceNo))
            {
                obj.showEditDel = false;
                obj.selectedProName = null;
                ObjName_SaveAdvDwnldCritExp = obj.selectedObjName ;
            }
            if(integer.valueOf(AdvDwnldCrit_selectedObjSerial) == Math.round(obj.sequenceNo))
                obj.IsSelectRow = true;
            else 
                obj.IsSelectRow = false;
                
            lstAdvDwnldCriWrp.add(obj);
        }
        templstWrapperConfData.clear();
        var_advDwnldCrit = new advDwnldCritWrap(new SVMXC__ServiceMax_Processes__c(RecordTypeId = advExpId), new List<SVMXC__ServiceMax_Config_Data__c>());
        
        AdcHdrfldlist.clear();
        AdcHdrfldlist.add(new SelectOption('SVMX.NONE',getTAG019()));
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        mapLkpFldReferObj.clear();
        mapLkpFldListReferObj.clear();
        for(string obj: gd.keyset())
        {
            if(gd.get(obj).getDescribe().getName() == AdvDwnldCrit_ObjNameToFilter)
            {
                Map<String, Schema.SObjectField> mapFlds = gd.get(obj).getDescribe().fields.getMap();
                for(string fld: mapFlds.keyset())
                {
                    Schema.DescribeFieldResult f = mapFlds.get(fld).getDescribe();
                    if(f.getName() == 'Id')
                    {
                        AdcHdrfldlist.add(new SelectOption(f.getName(), f.getLabel()));
                        mapLkpFldReferObj.put(f.getName(), AdvDwnldCrit_ObjNameToFilter);
                    }
                    else if(f.isAccessible() && f.isFilterable())
                    {
                        if(f.getType() == Schema.DisplayType.Reference)
                        {
                            if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                            {
                                if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                                {
                                    continue;
                                }
                            }
                        }
                        AdcHdrfldlist.add(new SelectOption(f.getName(), f.getLabel()));
                        if(f.getType() == Schema.DisplayType.Reference && f.getName() != 'RecordTypeId')
                        {
                            List<schema.sObjectType> lstRefSObj = f.getReferenceTo();
                            if(lstRefSObj != null && lstRefSObj.size() == 1)
                                mapLkpFldReferObj.put(f.getName(), lstRefSObj[0].getDescribe().getName());
                            else if(lstRefSObj != null && lstRefSObj.size() > 1)
                            {
                                for(schema.sObjectType refSObj: lstRefSObj)
                                {
                                    if(mapLkpFldListReferObj == null || mapLkpFldListReferObj.size() == 0 || !mapLkpFldListReferObj.containsKey(f.getName()))
                                        mapLkpFldListReferObj.put(f.getName(), new List<string>());
                                    mapLkpFldListReferObj.get(f.getName()).add(refSObj.getDescribe().getName());
                                }
                            }    
                        }
                    }
                }
            }
        }
        AdcHdrfldlist = sortingSelectOptionForADC(AdcHdrfldlist);
        
        AdvExp_ADDRow(); 
    }
    
    public List<SelectOption> sortingSelectOptionForADC(List<SelectOption> selOpt)
    {
        try
        {
            map<string, selectOption> mapTemp = new map<string, SelectOption>();
            for(selectOption o :selOpt){  
                mapTemp.put(o.getLabel()+'-'+o.getValue(), o);
            }
            
            list<string> lstTemp = new list<string>();
            lstTemp.addAll(mapTemp.KeySet());
            lstTemp.sort();
            selOpt.clear();
            for(string str: lstTemp)
            {       
                selOpt.add(mapTemp.get(str));
            }
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getmessage()));
        }
        return selOpt;
    }
    
    public void AdvDwnldCrit_EditFilter()
    {
        COMM_Utils comUtil = new COMM_Utils();
        TopPagMsgDevice = false;
        showExp_AdvDwnldCrit = true;
        
        for(objConfDataWrapper wr : lstAdvDwnldCriWrp)
        {
            if(Math.round(wr.sequenceNo) == integer.valueOf(AdvDwnldCrit_selectedObjSerial))
                wr.IsSelectRow = true;
            else
                wr.IsSelectRow = false;
        }
        
        List<SVMXC__ServiceMax_Processes__c> expPro = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> expDtls = new List<SVMXC__ServiceMax_Config_Data__c>();
        expPro = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__IsStandard__c, SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where id =: AdvDwnldCrit_editFilterId];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        expDtls = [select id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Rule__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c =: AdvDwnldCrit_editFilterId];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

        if(expPro == null || expPro.size() == 0 || expPro.size() > 1)
            return;
        
        var_advDwnldCrit = new advDwnldCritWrap(expPro[0], expDtls);
        ObjName_SaveAdvDwnldCritExp = AdvDwnldCrit_ObjNameToFilter;
        AdcHdrfldlist.clear();
        AdcHdrfldlist.add(new SelectOption('SVMX.NONE',getTAG019()));
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        mapLkpFldReferObj.clear();
        mapLkpFldListReferObj.clear();
        for(string obj: gd.keyset())
        {
            if(gd.get(obj).getDescribe().getName() == AdvDwnldCrit_ObjNameToFilter)
            {
                Map<String, Schema.SObjectField> mapFlds = gd.get(obj).getDescribe().fields.getMap();
                for(string fld: mapFlds.keyset())
                {
                    Schema.DescribeFieldResult f = mapFlds.get(fld).getDescribe();
                    if(f.getName() == 'Id')
                    {
                        AdcHdrfldlist.add(new SelectOption(f.getName(), f.getLabel()));
                        mapLkpFldReferObj.put(f.getName(), AdvDwnldCrit_ObjNameToFilter);
                    }
                    else if(f.isAccessible() && f.isFilterable())
                    {
                        if(f.getType() == Schema.DisplayType.Reference)
                        {
                            if(!comUtil.SVMX_isObjectCustom(String.valueof(f.getReferenceTo()[0])))
                            {
                                if(!lstStdObjAccToLicense.containsKey(String.valueof(f.getReferenceTo()[0])))
                                {
                                    continue;
                                }
                            }
                        }
                        AdcHdrfldlist.add(new SelectOption(f.getName(), f.getLabel()));
                        if(f.getType() == Schema.DisplayType.Reference && f.getName() != 'RecordTypeId')
                        {
                            List<schema.sObjectType> lstRefSObj = f.getReferenceTo();
                            if(lstRefSObj != null && lstRefSObj.size() == 1)
                                mapLkpFldReferObj.put(f.getName(), lstRefSObj[0].getDescribe().getName());
                            else if(lstRefSObj != null && lstRefSObj.size() > 1)
                            {
                                for(schema.sObjectType refSObj: lstRefSObj)
                                {
                                    if(mapLkpFldListReferObj == null || mapLkpFldListReferObj.size() == 0 || !mapLkpFldListReferObj.containsKey(f.getName()))
                                        mapLkpFldListReferObj.put(f.getName(), new List<string>());
                                    mapLkpFldListReferObj.get(f.getName()).add(refSObj.getDescribe().getName());
                                }
                            }
                        }
                    }
                }
            }
        }
        AdcHdrfldlist = sortingSelectOptionForADC(AdcHdrfldlist);
        
        if(var_advDwnldCrit != null && var_advDwnldCrit.dtlWrap != null && var_advDwnldCrit.dtlWrap.size() > 0)
        {
            for(advDwnldCrit_DtlWrap dtl: var_advDwnldCrit.dtlWrap)
            {
                dtl.isReferField = true;
                dtl.dtlObjLstSO = new List<SelectOption>();
                dtl.dtlObjLstSO.add(new selectOption('SVMX.None', getTAG019()));
                dtl.dtlFldLstSO = new List<SelectOption>();
                dtl.dtlFldLstSO.add(new selectOption('SVMX.None', getTAG019()));
                system.debug(loggingLevel.WARN, 'Field: ' + dtl.hdrFld);
                if(mapLkpFldReferObj.containsKey(dtl.hdrFld) || mapLkpFldListReferObj.containsKey(dtl.hdrFld))
                {
                    dtl.isReferField = false;
                    if(dtl.hdrFld == 'Id')
                        dtl.op = 'in';
                    else
                        dtl.op = 'eq';
                        
                    if(mapLkpFldReferObj.containsKey(dtl.hdrFld))
                    {
                        string refSObj = mapLkpFldReferObj.get(dtl.hdrFld);
                        SFM_GetGlobalObjectList getGlobalObjLst = new SFM_GetGlobalObjectList();
                        SFM_WrapperDef.SFM_Response res = getGlobalObjLst.getChildSourceObject(refSObj);
                        if(res.success == true && res.stringFieldMap != null && res.stringFieldMap.size() > 0)
                        {
                            for(SFM_WrapperDef.SFM_StringFieldMap fmap: res.stringFieldMap)
                            {
                                List<string> labelsObjFld = fmap.value.split(' \\(');
                                string objLabel = labelsObjFld[0];
                                //if(fmap.key != ObjName_SaveAdvDwnldCritExp)
                                    dtl.dtlObjLstSO.add(new selectOption(fmap.key, objLabel));
                            }
                        }
                    }
                    else if(mapLkpFldListReferObj.containsKey(dtl.hdrFld) && dtl.hdrFld == 'ParentId')
                    {
                        dtl.dtlObjLstSO.addAll(txObj);
                    }
                    else if(mapLkpFldListReferObj.containsKey(dtl.hdrFld) && dtl.hdrFld != 'ParentId')
                    {
                        for(string refSObjFld : mapLkpFldListReferObj.keyset())
                        {
                            system.debug(' =Key Object Field Name=: ' + refSObjFld);
                            for(string refSObj: mapLkpFldListReferObj.get(refSObjFld))
                            {
                                system.debug(' =Key Object Name=: ' + refSObj);
                                SFM_GetGlobalObjectList getGlobalObjLst = new SFM_GetGlobalObjectList();
                                SFM_WrapperDef.SFM_Response res = getGlobalObjLst.getChildSourceObject(refSObj);
                                system.debug(' =Success=: ' + res.success + ' =FieldMap=: ' + res.stringFieldMap);
                                if(res.success == true && res.stringFieldMap != null && res.stringFieldMap.size() > 0)
                                {
                                    for(SFM_WrapperDef.SFM_StringFieldMap fmap: res.stringFieldMap)
                                    {
                                        List<string> labelsObjFld = fmap.value.split(' \\(');
                                        string objLabel = labelsObjFld[0];
                                        //if(fmap.key != ObjName_SaveAdvDwnldCritExp)
                                            dtl.dtlObjLstSO.add(new selectOption(fmap.key, objLabel));
                                    }
                                }
                            }
                        }
                    }
                    else
                        dtl.dtlObjLstSO.addAll(txObj);
                        
                    dtl.dtlObjLstSO = sortingSelectOption(dtl.dtlObjLstSO);
                    dtl.fldValue = null;
                }
                
                selectedAdvExpSeq = dtl.sequence;
                onSelectRefObj_AdvExp();
            }
            selectedAdvExpSeq = null;
        }
        
        if(expDtls == null || expDtls.size() == 0)
            AdvExp_ADDRow(); 
    }
    
    //--------------------------------------Methods to add row of Expression details-------------------------------------------------------
    public void HdrADDRow()
    {
        TopPagMsgDevice = false;
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = RTExpressionsDetail.Id, SVMXC__Sequence__c = Integer.valueOf( ExpToShow.expressionDetails.size() + 1 ) );
            Map_SequenceNumRec.put( Math.Round(Integer.valueOf( ExpToShow.expressionDetails.size() + 1 )), NewExpDetailRec );
            ExpToShow.expressionDetails.add( NewExpDetailRec );
            if(ExpToShow.expressionDetails != null)
                ExpDetailSize = ExpToShow.expressionDetails.size();
            else
                ExpDetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //--------------------------------------Methods to delete row of Expression details-------------------------------------------------------
    public void HdrDeleteRow()
    {
        TopPagMsgDevice = false;
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SequenceNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < ExpToShow.expressionDetails.size(); i++ )
            {
                if( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(DelIndex) )
                    TempMap_SequenceNumRec.put( i + 1 - SeqNumToSubtract, ExpToShow.expressionDetails[i] );
                else if ( Map_SequenceNumRec != null && Map_SequenceNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(DelIndex)) )  
                    SeqNumToSubtract = 1;
            }
            Map_SequenceNumRec.clear();
            if( TempMap_SequenceNumRec != null )
                Map_SequenceNumRec.putAll(TempMap_SequenceNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :Map_SequenceNumRec.keyset())
            {
                SequenceCounter++;
                if( Map_SequenceNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = Map_SequenceNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            ExpToShow.expressionDetails.clear();
            ExpToShow.expressionDetails.addAll(Temp_ExpDetailsLst);
            if(ExpToShow.expressionDetails != null)
                ExpDetailSize = ExpToShow.expressionDetails.size();
            else
                ExpDetailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public void AdvExp_ADDRow()
    {
        TopPagMsgDevice = false;
        try
        {
            advDwnldCrit_DtlWrap newDtlWrap = new advDwnldCrit_DtlWrap(var_advDwnldCrit.dtlWrap.size() + 1, 'SVMX.NONE', 'SVMX.NONE', 'SVMX.NONE', 'SVMX.NONE', null);
            var_advDwnldCrit.dtlWrap.add(newDtlWrap);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public void AdvExp_DeleteRow()
    {
        TopPagMsgDevice = false;
        try
        {
            map<integer, advDwnldCrit_DtlWrap> tempMap_Dtls = new map<integer, advDwnldCrit_DtlWrap>();
            for(advDwnldCrit_DtlWrap dtl: var_advDwnldCrit.dtlWrap)
                if(dtl.sequence != integer.valueOf(AdvExp_DelIndex))
                    tempMap_Dtls.put(dtl.sequence, dtl);
            
            integer newSeq = 1;
            List<advDwnldCrit_DtlWrap> tempLst_Dtls = new List<advDwnldCrit_DtlWrap>();
            for(integer i: tempMap_Dtls.keyset())
            {
                advDwnldCrit_DtlWrap dtl = new advDwnldCrit_DtlWrap();
                dtl = tempMap_Dtls.get(i);
                dtl.sequence = newSeq;
                tempLst_Dtls.add(dtl);
                newSeq++;
            }
            var_advDwnldCrit.dtlWrap.clear();
            var_advDwnldCrit.dtlWrap.addAll(tempLst_Dtls);
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    public void onSelectfld_AdvExp()
    {
        for(advDwnldCrit_DtlWrap dtl: var_advDwnldCrit.dtlWrap)
        {
            if(dtl.sequence == selectedAdvExpSeq)
            {
                dtl.dtlObj = null;
                dtl.dtlFld = null;
                dtl.fldValue = null;
                dtl.op = null;
                dtl.dtlObjLstSO = new List<SelectOption>();
                dtl.dtlObjLstSO.add(new selectOption('SVMX.None', getTAG019()));
                dtl.dtlFldLstSO = new List<SelectOption>();
                dtl.dtlFldLstSO.add(new selectOption('SVMX.None', getTAG019()));
                
                if(dtl.hdrFld == null || dtl.hdrFld == 'SVMX.None' || dtl.hdrFld.length() == 0)
                    return;
                
                system.debug('field: ' + dtl.hdrFld + ' :LkpReferObj: ' + mapLkpFldReferObj.containsKey(dtl.hdrFld) + ' :LkpListReferObj: ' + mapLkpFldListReferObj.containsKey(dtl.hdrFld));
                
                if(mapLkpFldReferObj.containsKey(dtl.hdrFld) || mapLkpFldListReferObj.containsKey(dtl.hdrFld))// && dtl.hdrFld != 'RecordTypeId'
                {
                    dtl.isReferField = false;
                    if(dtl.hdrFld == 'Id')
                        dtl.op = 'in';
                    else
                        dtl.op = 'eq';
                    
                    if(mapLkpFldReferObj.containsKey(dtl.hdrFld))
                    {
                        string refSObj = mapLkpFldReferObj.get(dtl.hdrFld);
                        SFM_GetGlobalObjectList getGlobalObjLst = new SFM_GetGlobalObjectList();
                        SFM_WrapperDef.SFM_Response res = getGlobalObjLst.getChildSourceObject(refSObj);
                        if(res.success == true && res.stringFieldMap != null && res.stringFieldMap.size() > 0)
                        {
                            for(SFM_WrapperDef.SFM_StringFieldMap fmap: res.stringFieldMap)
                            {
                                List<string> labelsObjFld = fmap.value.split(' \\(');
                                string objLabel = labelsObjFld[0];
                                if(objNameToLabel.containsKey(fmap.key))// && fmap.key != ObjName_SaveAdvDwnldCritExp
                                    dtl.dtlObjLstSO.add(new selectOption(fmap.key, objLabel));
                            }
                        }
                    }
                    else if(mapLkpFldListReferObj.containsKey(dtl.hdrFld) && dtl.hdrFld == 'ParentId')
                    {
                        dtl.dtlObjLstSO.addAll(txObj);
                    }
                    else if(mapLkpFldListReferObj.containsKey(dtl.hdrFld) && dtl.hdrFld != 'ParentId')
                    {
                        system.debug('Not Parent ID: ' + mapLkpFldListReferObj.keyset());
                        for(string refFld : mapLkpFldListReferObj.keyset())
                        {
                            system.debug('List of Referenced Objec: ' + mapLkpFldListReferObj.get(refFld));
                            for(string refSObj: mapLkpFldListReferObj.get(refFld))
                            {
                                SFM_GetGlobalObjectList getGlobalObjLst = new SFM_GetGlobalObjectList();
                                SFM_WrapperDef.SFM_Response res = getGlobalObjLst.getChildSourceObject(refSObj);
                                system.debug('Response: ' + res);
                                if(res.success == true && res.stringFieldMap != null && res.stringFieldMap.size() > 0)
                                {
                                    for(SFM_WrapperDef.SFM_StringFieldMap fmap: res.stringFieldMap)
                                    {
                                        system.debug('FM Value: ' + fmap.value);
                                        List<string> labelsObjFld = fmap.value.split(' \\(');
                                        string objLabel = labelsObjFld[0];
                                        system.debug('FM Label Value: ' + labelsObjFld[0]);
                                        //if(fmap.key != ObjName_SaveAdvDwnldCritExp)
                                            dtl.dtlObjLstSO.add(new selectOption(fmap.key, objLabel));
                                    }
                                }
                            }
                        }
                    }
                    else
                        dtl.dtlObjLstSO.addAll(txObj);
                        
                    dtl.dtlObjLstSO = sortingSelectOption(dtl.dtlObjLstSO);
                }
                else
                    dtl.isReferField = true;
                break;
            }
        }
    }
    
    public void onSelectRefObj_AdvExp()
    {
        for(advDwnldCrit_DtlWrap dtl: var_advDwnldCrit.dtlWrap)
        {
            if(dtl.sequence == selectedAdvExpSeq)
            {
                if(dtl.dtlObj == null || dtl.dtlObj == 'SVMX.None' || dtl.dtlObj.length() == 0)
                {
                    dtl.dtlFldLstSO = new List<SelectOption>();
                    dtl.dtlFldLstSO.add(new selectOption('SVMX.None', getTAG019()));
                    dtl.dtlFld = null;
                    return;
                }
                dtl.dtlFldLstSO = new List<SelectOption>();
                dtl.dtlFldLstSO.add(new selectOption('SVMX.None', getTAG019()));
                
                if(mapLkpFldReferObj.containsKey(dtl.hdrFld))
                {
                    MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
                    for(String obj : allObjs.keyset())
                    {
                        if(allObjs.get(obj).getDescribe().getName() == dtl.dtlObj)
                        {
                            Map<String, Schema.SObjectField> mapFlds = allObjs.get(obj).getDescribe().fields.getMap();
                            for(string fld: mapFlds.keyset())
                            {
                                Schema.DescribeFieldResult f = mapFlds.get(fld).getDescribe();
                                if(f.getType() == Schema.DisplayType.Reference)
                                {
                                    for(schema.sObjectType refSObj: f.getReferenceTo())
                                    {
                                        if(refSObj.getDescribe().getName() == mapLkpFldReferObj.get(dtl.hdrFld))
                                            dtl.dtlFldLstSO.add(new selectOption(f.getName(), f.getLabel()));
                                    }
                                }
                            }
                        }
                    }
                }
                else if(mapLkpFldListReferObj != null && mapLkpFldListReferObj.size() > 0 && mapLkpFldListReferObj.containsKey(dtl.hdrFld) && !(AdvDwnldCrit_ObjNameToFilter == 'Attachment' && dtl.hdrFld == 'ParentId'))
                {
                    system.debug('=Found header field in the lookup list=' + dtl.hdrFld + ' =For Fields= ' + mapLkpFldListReferObj.get(dtl.hdrFld));
                    MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
                    for(String obj : allObjs.keyset())
                    {
                        if(allObjs.get(obj).getDescribe().getName() == dtl.dtlObj)
                        {
                            Map<String, Schema.SObjectField> mapFlds = allObjs.get(obj).getDescribe().fields.getMap();
                            for(string fld: mapFlds.keyset())
                            {
                                Schema.DescribeFieldResult f = mapFlds.get(fld).getDescribe();
                                if(f.getType() == Schema.DisplayType.Reference)
                                {
                                    for(schema.sObjectType refSObj: f.getReferenceTo())
                                    {
                                        for(string strFld: mapLkpFldListReferObj.get(dtl.hdrFld))
                                        {
                                            system.debug('=Field from Describe=' + refSObj.getDescribe().getName() + ' =Field from Map= ' + strFld + ' =Field Name= ' + f.getName());
                                            
                                            if(refSObj.getDescribe().getName() == strFld)
                                                dtl.dtlFldLstSO.add(new selectOption(f.getName(), f.getLabel()));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    dtl.dtlFldLstSO.add(new selectOption('Id', 'Id'));
                }
                dtl.dtlFldLstSO = sortingSelectOptionForADC(dtl.dtlFldLstSO);
                break;
            }
        }
    }
    
    //------------------------------------------------Method to save One Expression----------------------------------------------------------------------
    public void submitExp()
    {
        TopPagMsgDevice = false;
        ExpMsg = true;
        DeletMsg = false;
        if(ExpToShow.namedExpression != null && ExpToShow.namedExpression.SVMXC__Name__c != null && (ExpToShow.namedExpression.SVMXC__Name__c).length() > 0 &&  ExpToShow.namedExpression.SVMXC__ProcessID__c != null && (ExpToShow.namedExpression.SVMXC__ProcessID__c).length() >= 8)
        {
            SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
            try
            {
                ExpToShow.namedExpression.SVMXC__SettingId__c = ExpToShow.namedExpression.SVMXC__ProcessID__c;
                ExpToShow.namedExpression.SVMXC__Source_Object_Name__c = ObjNameFrSaveExp;
                List<SVMXC__ServiceMax_Config_Data__c> ExpressionDetails2Save = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :ExpToShow.expressionDetails)
                {
                    if( (expressiondtlRec.SVMXC__Operator__c == null || expressiondtlRec.SVMXC__Operator__c == 'SVMX.NONE') && (expressiondtlRec.SVMXC__Operand__c == null || expressiondtlRec.SVMXC__Operand__c == '') && expressiondtlRec.SVMXC__Field_Name__c == 'None' )
                        continue;
                    else
                        ExpressionDetails2Save.add(expressiondtlRec);
                }
                
                ExpToShow.expressionDetails.clear();
                
                if(ExpressionDetails2Save.size()>0)
                    ExpToShow.expressionDetails.addAll(ExpressionDetails2Save);
                ExpDetailSize = ExpToShow.expressionDetails.size();
                if(ExpDetailSize >0)
                {
                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(ExpToShow.namedExpression,ExpToShow.expressionDetails);
                    List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                    LstSFM_Exp.add(oSFM_Exp);
                    
                    SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                    SVMXC.SFM_saveExpression saveExp = new SVMXC.SFM_saveExpression();
                    Save_Response = saveExp.SFM_saveExpression(oRequest);
                    DeletMsg = true;
                    if( Save_Response != null && Save_Response.success != null)
                    {
                        if(boolean.valueOf(Save_Response.success))
                        {
                            if( Save_Response.resultIds != null && Save_Response.resultIds.size() > 0 )
                            {
                                savedExpressionResultId = Save_Response.resultIds[0];
                                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.CONFIRM, '' + getTAG030()));
    
                                List<objConfDataWrapper> templstWrapperConfData = new List<objConfDataWrapper>();
                                templstWrapperConfData = lstWrapperConfData.clone();
                                lstWrapperConfData.clear();
                                for(objConfDataWrapper obj : templstWrapperConfData)
                                {
                                    if(selectedObjSerial == Math.round(obj.sequenceNo))
                                    {
                                        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
                                        
                                        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME', obj.selectedObjName);
                                        lstStringMap.add(stringMap1);
                                        
                                        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
                                        
                                        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
                                        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
                                        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
                                        obj.proLstOptns.clear();
                                        obj.proLstOptns.add(new SelectOption('SVMX.None', getTAG019()));
                                        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
                                            if(tempstringMap.key != null && tempstringMap.key.length() > 0)
                                                obj.proLstOptns.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
                                        obj.proLstOptns = sortingSelectOption(obj.proLstOptns);
                                        obj.selectedProName = ExpToShow.namedExpression.Id;
                                        obj.showEditDel = true;                                                    
                                    }
                                    lstWrapperConfData.add(obj);
                                }
                                templstWrapperConfData.clear();
                            }
                        }
                        else
                        {
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + Save_Response.message ));
                        }
                    }
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG046()));
                }
                
            }
            catch(Exception ex)
            {
                if( Save_Response != null && Save_Response.message != null && Save_Response.success == false )
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''+Save_Response.message + ': ' + ex.getmessage()));
            }
        }
        else
        {
            if( ExpToShow.namedExpression == null || ExpToShow.namedExpression.SVMXC__Name__c == null || ExpToShow.namedExpression.SVMXC__Name__c == '' || (ExpToShow.namedExpression.SVMXC__Name__c).length() == 0 )
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG047()));
            
            if( ExpToShow.namedExpression == null || ExpToShow.namedExpression.SVMXC__ProcessID__c == null || ExpToShow.namedExpression.SVMXC__ProcessID__c == '' || (ExpToShow.namedExpression.SVMXC__ProcessID__c).length() < 8 )
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG048()));
        }
    }
    
    //--------------------------------------------Method to Close the Expression PopUp----------------------------------------------------------------
    public void cancelExp()
    {
        TopPagMsgDevice = false;
        showExpPopUp = false;
    }
    
    public void submitExp_AdvDwnldCrit()
    {
        TopPagMsgDevice = false;
        ExpMsg = true;
        DeletMsg = false;
        boolean isValidate = true;
        string validMsg = '';
        system.debug(LoggingLevel.WARN, 'Entered to save adv exp.' + var_advDwnldCrit.ExpPro.SVMXC__ProcessID__c);
        if(var_advDwnldCrit.ExpPro != null && var_advDwnldCrit.ExpPro.SVMXC__Name__c != null && (var_advDwnldCrit.ExpPro.SVMXC__Name__c).length() > 0 &&  var_advDwnldCrit.ExpPro.SVMXC__ProcessID__c != null && (var_advDwnldCrit.ExpPro.SVMXC__ProcessID__c).length() >= 8 )
        {
            SFM_WrapperDef.SFM_Response validate_Res = new SFM_WrapperDef.SFM_Response();
            boolean isFieldAccessIssue = false;
            try
            {
                var_advDwnldCrit.ExpPro.SVMXC__SettingId__c = var_advDwnldCrit.ExpPro.SVMXC__ProcessID__c;
                var_advDwnldCrit.ExpPro.SVMXC__Source_Object_Name__c = ObjName_SaveAdvDwnldCritExp;
                var_advDwnldCrit.ExpPro.RecordTypeId = advExpId;
                var_advDwnldCrit.ExpPro.SVMXC__Rule_Type__c = 'Adv Criteria Exp';
                
                List<SVMXC__ServiceMax_Config_Data__c> ExpressionDetails2Save = new List<SVMXC__ServiceMax_Config_Data__c>();
                List<SVMXC__ServiceMax_Config_Data__c> expDtlsFromWrap = new List<SVMXC__ServiceMax_Config_Data__c>();
                for(advDwnldCrit_DtlWrap dtl : var_advDwnldCrit.dtlWrap)
                {
                    system.debug(LoggingLevel.WARN, 'Detail Wrapper: ' + var_advDwnldCrit.ExpPro.SVMXC__Source_Object_Name__c);
                    Map<String,Schema.Displaytype>  mapFieldDispType = new Map<String,Schema.Displaytype>();
                    Map<String, Schema.SObjectType> Allobjs = Schema.getGlobalDescribe();
                    SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
                    string ObjectNameAPI = utils.getOriginalAPIName(var_advDwnldCrit.ExpPro.SVMXC__Source_Object_Name__c,Allobjs);
                    system.debug(LoggingLevel.WARN, 'Exp Process Object: ' + var_advDwnldCrit.ExpPro.SVMXC__Source_Object_Name__c);
                    system.debug(LoggingLevel.WARN, 'Api Name Object: ' + ObjectNameAPI);
                    system.debug(LoggingLevel.WARN, 'All Obj Contain Object: ' + Allobjs.containskey(ObjectNameAPI));
                    if(Allobjs.containskey(ObjectNameAPI))
                    {
                        Map<String, Schema.SObjectField> FieldMap = Allobjs.get(ObjectNameAPI).getDescribe().fields.getMap();
                        if(FieldMap.size() > 0)
                        {
                          for(String s :FieldMap.keyset())
                          {
                            Schema.DescribeFieldResult F = FieldMap.get(s).getDescribe();                 
                            mapFieldDispType.put(F.getName(),F.getType());
                          }
                        }
                    }
                    system.debug(LoggingLevel.WARN, 'Map Field to Type: ' + mapFieldDispType);
                    
                    SVMXC__ServiceMax_Config_Data__c cnf_Data = new SVMXC__ServiceMax_Config_Data__c();
                    cnf_Data.RecordTypeId = RTExpressionsDetail.Id;
                    cnf_Data.SVMXC__Object_Name__c = var_advDwnldCrit.ExpPro.SVMXC__Source_Object_Name__c;
                    cnf_Data.SVMXC__Operator__c = dtl.op;
                    cnf_Data.SVMXC__Sequence__c = dtl.sequence;
                    cnf_Data.SVMXC__Field_Name__c = dtl.hdrFld;
                    cnf_Data.SVMXC__Object_Name2__c = dtl.dtlObj;
                    cnf_Data.SVMXC__Source_Field_Name__c = dtl.dtlFld;
                    
                    if(mapFieldDispType.containsKey(dtl.hdrFld))
                        cnf_Data.SVMXC__Display_Type__c = String.valueOf(mapFieldDispType.get(cnf_Data.SVMXC__Field_Name__c));
                    
                    if(dtl.hdrFld == 'Id')
                        cnf_Data.SVMXC__Operand__c = 'abcdefghijklmn' + cnf_Data.SVMXC__Sequence__c;
                    else if((dtl.dtlObj == null || dtl.dtlObj == '' || dtl.dtlObj == 'SVMX.NONE') && (dtl.dtlFld == null || dtl.dtlFld == '' || dtl.dtlFld == 'SVMX.NONE') && dtl.fldValue != null && dtl.fldValue != '' && cnf_Data.SVMXC__Display_Type__c != 'Reference')
                        cnf_Data.SVMXC__Operand__c = dtl.fldValue;
                    else if(dtl.hdrFld == 'RecordTypeId')
                        cnf_Data.SVMXC__Operand__c = dtl.fldValue;
                    else if(cnf_Data.SVMXC__Display_Type__c == 'Reference')
                        cnf_Data.SVMXC__Operand__c = ':' + dtl.dtlObj + ',' + dtl.dtlFld;
                        
                    if((cnf_Data.SVMXC__Display_Type__c == 'Reference' && dtl.hdrFld != 'RecordTypeId') || cnf_Data.SVMXC__Field_Name__c == 'Id')
                    {
                        if(dtl.dtlObj == null || dtl.dtlObj == 'SVMX.NONE' || dtl.dtlObj == '' || dtl.dtlObj.length() == 0)
                        {
                            isValidate = false;
                            validMsg = getTAG014();
                        }
                        else if(dtl.dtlFld == null || dtl.dtlFld == 'SVMX.NONE' || dtl.dtlFld == '' || dtl.dtlFld.length() == 0)
                        {
                            isValidate = false;
                            validMsg = getTAG016();
                        }
                    }
                    else
                    {
                        dtl.dtlObj = null;
                        dtl.dtlFld = null;
                    }
                    system.debug(LoggingLevel.WARN, 'Config Data to Save: ' + cnf_Data.SVMXC__Operand__c);
                    expDtlsFromWrap.add(cnf_Data);
                }
                
                for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :expDtlsFromWrap)
                {
                    if( (expressiondtlRec.SVMXC__Operator__c == null || expressiondtlRec.SVMXC__Operator__c == 'SVMX.NONE') && (expressiondtlRec.SVMXC__Operand__c == null || expressiondtlRec.SVMXC__Operand__c == '') && expressiondtlRec.SVMXC__Field_Name__c == 'None' )
                        continue;
                    else
                        ExpressionDetails2Save.add(expressiondtlRec);
                }
                
                expDtlsFromWrap.clear();
                system.debug(LoggingLevel.WARN, 'List Config Data to save: ' + ExpressionDetails2Save);
                if(ExpressionDetails2Save.size()>0)
                    expDtlsFromWrap.addAll(ExpressionDetails2Save);
                
                if(expDtlsFromWrap != null && expDtlsFromWrap.size() >0)
                {
                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(var_advDwnldCrit.ExpPro,expDtlsFromWrap);
                    List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                    LstSFM_Exp.add(oSFM_Exp);
                    
                    SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                    SVMXC.SFM_validateExpression validateExp = new SVMXC.SFM_validateExpression();
                    validate_Res = validateExp.SFM_validateExpression(oRequest);
                    DeletMsg = true;
                    
                    system.debug(LoggingLevel.WARN, 'Valid Exp response: ' + validate_Res);
                    
                    if(isValidate == false)
                    {
                        validate_Res.success = false;
                        validate_Res.message = validMsg;
                    }
                    
                    if(validate_Res.success != null)
                    {
                        if(boolean.valueOf(validate_Res.success))
                        {
                            string query_Pro = 'select id from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =\'' +  var_advDwnldCrit.ExpPro.SVMXC__ProcessID__c + '\' AND RecordTypeId =: advExpId AND SVMXC__Rule_Type__c = \'Adv Criteria Exp\'';
                            string query_configDataToDelete;
                            if(var_advDwnldCrit.ExpPro.Id != null)
                            { 
                                query_Pro += ' AND ID != \'' + var_advDwnldCrit.ExpPro.Id + '\'';
                                query_configDataToDelete = 'select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c = \'' +  var_advDwnldCrit.ExpPro.Id + '\'';
                            }
                            
                            system.debug(LoggingLevel.WARN, 'Process query for unique Id check: ' + query_Pro);
                            system.debug(LoggingLevel.WARN, 'Config Data Query to delete: ' + query_configDataToDelete);
                            
                            List<SVMXC__ServiceMax_Processes__c> lstpro = database.query(query_Pro);
                            if(lstpro != null && lstpro.size() > 0)
                            {
                                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + getTAG048()));
                                return;
                            }
                            
                            string whereClause = validate_Res.message;
                            for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :expDtlsFromWrap)
                            {
                                if(expressiondtlRec.SVMXC__Display_Type__c == 'Reference' && expressiondtlRec.SVMXC__Field_Name__c != 'RecordTypeId')
                                {
                                    string replaceFromStr = expressiondtlRec.SVMXC__Field_Relationship_Name__c + '.' + expressiondtlRec.SVMXC__FKey_Name_Field__c;
                                    string replaceToStr = expressiondtlRec.SVMXC__Field_Name__c;
                                    whereClause = whereClause.replace(replaceFromStr, replaceToStr);
                                }
                                if(expressiondtlRec.SVMXC__Field_Name__c == 'Id')
                                {
                                    string replaceFromStr = 'abcdefghijklmn' + expressiondtlRec.SVMXC__Sequence__c;
                                    string replaceToStr = ':' + expressiondtlRec.SVMXC__Object_Name2__c + '\',\'' + expressiondtlRec.SVMXC__Source_Field_Name__c;
                                    whereClause = whereClause.replace(replaceFromStr, replaceToStr);
                                    expressiondtlRec.SVMXC__Operand__c = null;
                                }
                            }
                            
                            var_advDwnldCrit.ExpPro.SVMXC__Parent_Object_Criteria__c = whereClause;
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(new List<SObject>{var_advDwnldCrit.ExpPro}, COMM_SecurityUtils.Access.Createable)){
                                upsert var_advDwnldCrit.ExpPro;
                            }
                            else{
                                isFieldAccessIssue = true;
                                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                                return;
                            }
                            if(query_configDataToDelete != null && query_configDataToDelete.length() > 0)
                            {
                                List<SVMXC__ServiceMax_Config_Data__c> lst = database.query(query_configDataToDelete);
                                system.debug(LoggingLevel.WARN, 'Deleting config data: ' + lst);
                                if(lst != null && lst.size() > 0){
                                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){    //SDL-SVMX-DELETE-FLS-ENFORCED
                                        delete lst;
                                }else{
                                    isFieldAccessIssue = true;
                                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                                    return;
                                }
                                }
                                
                            }
                            
                            for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :expDtlsFromWrap)
                                expressiondtlRec.SVMXC__Expression_Rule__c = var_advDwnldCrit.ExpPro.Id;
                                
                            system.debug(LoggingLevel.WARN, 'Upserting the Config Data List: ' + expDtlsFromWrap);
                            
                            if(expDtlsFromWrap != null && expDtlsFromWrap.size() > 0){
                                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(expDtlsFromWrap, COMM_SecurityUtils.Access.Upsertable)){   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                    upsert expDtlsFromWrap;
                                }
                                else{
                                    isFieldAccessIssue = true;
                                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                                    return;
                                }
                            }
                                
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.CONFIRM, '' + getTAG030()));
                            
                            List<objConfDataWrapper> templstAdvDwnldCriWrp = new List<objConfDataWrapper>();
                            templstAdvDwnldCriWrp = lstAdvDwnldCriWrp.clone();
                            lstAdvDwnldCriWrp.clear();
                            for(objConfDataWrapper obj : templstAdvDwnldCriWrp)
                            {
                                if(selectedObjSerial == Math.round(obj.sequenceNo))
                                {
                                    List<SVMXC__ServiceMax_Processes__c> expPro = new List<SVMXC__ServiceMax_Processes__c>();
                                    expPro = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__IsStandard__c, SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where SVMXC__Source_Object_Name__c =: obj.selectedObjName AND SVMXC__Record_Type_Name__c = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Adv Criteria Exp'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                    
                                    obj.proLstOptns.clear();
                                    obj.proLstOptns.add(new SelectOption('SVMX.None', getTAG019()));
                                    for(SVMXC__ServiceMax_Processes__c pro : expPro)
                                        obj.proLstOptns.add(new SelectOption(pro.Id, pro.SVMXC__Name__c));
                                    obj.proLstOptns = sortingSelectOption(obj.proLstOptns);
                                    obj.selectedProName = var_advDwnldCrit.ExpPro.Id;
                                    obj.showEditDel = true;                                                    
                                }
                                lstAdvDwnldCriWrp.add(obj);
                            }
                            templstAdvDwnldCriWrp.clear();
                        }
                        else
                        {
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + validate_Res.message ));
                        }
                    }
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG046()));
                }
                
            }
            catch(Exception ex)
            {
                if(isFieldAccessIssue)
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                else if( validate_Res != null && validate_Res.message != null && validate_Res.success == false )
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''+validate_Res.message + ': ' + ex.getmessage()));
            }
        }
        else
        {
            if( var_advDwnldCrit.ExpPro == null || var_advDwnldCrit.ExpPro.SVMXC__Name__c == null || var_advDwnldCrit.ExpPro.SVMXC__Name__c == '' || (var_advDwnldCrit.ExpPro.SVMXC__Name__c).length() == 0 )
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG047()));
            
            if( var_advDwnldCrit.ExpPro == null || var_advDwnldCrit.ExpPro.SVMXC__ProcessID__c == null || var_advDwnldCrit.ExpPro.SVMXC__ProcessID__c == '' || (var_advDwnldCrit.ExpPro.SVMXC__ProcessID__c).length() < 8)
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG048()));
        }
    }
    
    public void cancelExp_AdvDwnldCrit()
    {
        TopPagMsgDevice = false;
        showExp_AdvDwnldCrit = false;
        for(objConfDataWrapper wr : lstAdvDwnldCriWrp)
            wr.IsSelectRow = false;
    }
    
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, ''));
    }
    
    
    //Method which checks if string is valid or not
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
    
    private String loadUsageDataOptions()
    {
        String keyStatus = validateKey(enableUsageLogging);
        usageLogUserOptOptns.clear();
        usageLogUserOptOptns.add(new selectOption('never', getTAG106()));
        if(keyStatus == 'error')
        {
            usageLogUserOptOptns.add(new selectOption('error', getTAG107()));
        }
        else if(keyStatus == 'always')
        {
            usageLogUserOptOptns.add(new selectOption('error', getTAG107()));
            usageLogUserOptOptns.add(new selectOption('always', getTAG108()));
        }
        isUsageLogDisabled = keyStatus == 'never' ? true : false;
        return keyStatus;
    }
    
    public void validateUsageKey()
    {
        usageLogUserOpt = loadUsageDataOptions();
    }

    private String validateKey(String key){
        try{
            String type = 'never';
            if(key == null || key.length() == 0) return type;
            Blob encryptedKey = EncodingUtil.base64Decode(key);
            String orgId = UserInfo.getOrganizationId();
            Blob aes = EncodingUtil.base64Decode('DHrjCunJBoQvVjRjvWJLnBKIvPNHO0cuWciRhy8mARQ=');
            Blob decrypted = Crypto.decryptWithManagedIV('AES256', aes, encryptedKey);
            String decryptedString = decrypted.toString();
            List<String> keys = decryptedString.split('\\|\\|');
            Date da = Date.valueOf(keys[1]);
            if(keys[0].subString(0, 15) == orgId.subString(0, 15) && da >= System.today()){
                type = keys[3];
            }
            
            if(type == 'All'){
                type = 'always';
            }
            return type;
        }catch(Exception ex){
            return 'never';
        }
        
    }
    
    public void disableChecklistFeature()
    {
        if(isChecklist)
        {
            showChklstOptions = false;
        }
        else
        {
            showChklstOptions = true;
            isCompletedChecklist = false;
            isInProgressChecklist = false;
        }
    }
    
    public void enablesoqlPerformance()
    {
        if(isSyncPerformance)
        {
            isSyncPerformanceEnabled = false;
            isSoqlPerformance=false;
            orgTypeUserOption = getTAG141();
        }
        else
        {
            isSyncPerformanceEnabled = true;
            isSoqlPerformance=false;
            orgTypeUserOption = getTAG141();
            isCustomUrlEnabled = false;
        }
    }
    
    public void enableCustomUrl(){  
            isCustomUrlEnabled = false;
            if(isSyncPerformance && orgTypeUserOption == 'Custom'){
                isCustomUrlEnabled = true;
            }else{
                isCustomUrlEnabled = false;
                syncCustomUrl = '';
            }
    }
    
//Device Targeted
    public void getDeviceTargetedConfiguration()
    {   
        topPagMsgDevice=false;
        disableSaveCancelBtn=true;
        listOfDeviceTargetWrap = new List<DeviceTargetWrap>();
        if(selectedProfile !='SVMX.None')
        {
            List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigs = [Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedProfile ];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(listOfConfigs.isEmpty())
            {
                SVMXC__SM_Device_Mobile_Config__c newConfig = new SVMXC__SM_Device_Mobile_Config__c();
                newConfig.SM_Name__c = 'Default';
                newConfig.SM_Description__c = 'Default';
                newConfig.SM_IsDefault__c = true;
                
                String allDeviceTypes = '';
                Integer count = 1;
                for(Schema.PicklistEntry newEntries:SVMXC__SM_Device_Mobile_Config__c.SM_Device_Type__c.getDescribe().getPicklistValues())
                {
                    if(newEntries.isActive() && count == SVMXC__SM_Device_Mobile_Config__c.SM_Device_Type__c.getDescribe().getPicklistValues().size())
                    {
                        allDeviceTypes=allDeviceTypes+newEntries.getValue();
                    }
                    else if(newEntries.isActive())
                    {
                        allDeviceTypes = allDeviceTypes+newEntries.getValue()+';';
                    }
                    count = count+1;
                }
                
                newConfig.SM_Device_Type__c = allDeviceTypes;
                newConfig.SM_Access_Configuration_Profile__c=selectedProfile;
                
                boolean isFieldAccessIssue = false;
                try
                {
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(new List<SObject>{newConfig}, COMM_SecurityUtils.Access.Createable))
                    {
                        insert newConfig;   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        isFieldAccessIssue = true;
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                        return;
                    }
                    
                    listOfConfigs.add(newConfig);
                    List<SVMXC__ServiceMax_Config_Data__c> listOfDatas = new List<SVMXC__ServiceMax_Config_Data__c>();
                    for(SVMXC__ServiceMax_Config_Data__c newData:[select SVMXC__Sequence__c, SVMXC__Access_Configuration_Profile__c, SVMXC__Ownership_Type__c, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Display_Type__c, SVMXC__Internal_Value__c, SVMXC__Object_Name__c, SVMXC__SM_Files_Config__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: RTMobileConfig.Id AND SVMXC__Access_Configuration_Profile__c =: selectedProfile Order By SVMXC__Sequence__c])
                    {
                        newData.SM_Device_Mobile_Config__c = newConfig.Id;
                        listOfDatas.add(newData);
                    }
                    if(!listOfDatas.isEmpty())
                    {
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listOfDatas, COMM_SecurityUtils.Access.Updateable)){
                            update listOfDatas;   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        }else{
                            isFieldAccessIssue = true;
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                            return;
                        }
                        
                    }
                }catch(Exception ex){
                    if(isFieldAccessIssue)
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    else
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
                }
                
                DeviceTargetWrap newWrap = new DeviceTargetWrap();
                newWrap.isSelect=false;
                newWrap.deviceMobileConfig = newConfig;
                listOfDeviceTargetWrap.add(newWrap);
            }
            else
            {
                for(SVMXC__SM_Device_Mobile_Config__c newConfigs:listOfConfigs)
                {
                    DeviceTargetWrap newWrapper = new DeviceTargetWrap();
                    newWrapper.isSelect=false;
                    newWrapper.deviceMobileConfig = newConfigs;
                    listOfDeviceTargetWrap.add(newWrapper);                
                }
            }
            List<string> lstIDs = new List<string>();
            for(SVMXC__ServiceMax_Config_Data__c SVMXProfile : allSVMXProfiles)
            {
                lstIDs.add(SVMXProfile.Id);
            }
            
            lstConfiguredProfiles.clear();
            lstConfiguredProfiles = [select SVMXC__Sequence__c, SVMXC__Access_Configuration_Profile__c, SVMXC__Ownership_Type__c, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Display_Type__c, SVMXC__Internal_Value__c, SVMXC__Object_Name__c, SVMXC__SM_Files_Config__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: RTMobileConfig.Id AND SVMXC__Access_Configuration_Profile__c IN: lstIDs Order By SVMXC__Sequence__c];      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA         
            configuredProfileOptns.clear();
            configuredProfileOptns.add(new selectOption('SVMX.None', getTAG019()));
            Map<string, string> mapProfileConfigured = new Map<string, string>();
            for(SVMXC__ServiceMax_Config_Data__c p : lstConfiguredProfiles )
            {
                if(mapProfileConfigured == null || !mapProfileConfigured.containsKey(p.SVMXC__Access_Configuration_Profile__c))
                {
                    mapProfileConfigured.put(p.SVMXC__Access_Configuration_Profile__c, p.SVMXC__Access_Configuration_Profile__c);
                    if(p.SVMXC__Access_Configuration_Profile__c != selectedProfile)
                    {
                        System.debug('What is the profile to be cloned options ');
                        configuredProfileOptns.add(new selectOption(p.SVMXC__Access_Configuration_Profile__c, P.SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c));
                    }
                }
            }                       
        }
        else
        {
            disableSaveCancelBtn = true;   
            listOfDeviceTargetWrap = new List<DeviceTargetWrap>();     
            
        }
    }  
    public void editDeviceMobileConfig()
    {
        disableSaveCancelBtn = false;  
        topPagMsgDevice=false; 
        List<SVMXC__SM_Device_Mobile_Config__c> listOfConfig = new List<SVMXC__SM_Device_Mobile_Config__c>();
        for(DeviceTargetWrap newWrap:listOfDeviceTargetWrap)     
        {
            if(newWrap.isSelect)
            {
                listOfConfig.add(newWrap.deviceMobileConfig);
                newMobileConfig = new SVMXC__SM_Device_Mobile_Config__c(id=newWrap.deviceMobileConfig.Id);
                newMobileConfig.SM_IsDefault__c=newWrap.deviceMobileConfig.SM_IsDefault__c;
                newMobileConfig.SM_Name__c=newWrap.deviceMobileConfig.SM_Name__c;                
                newMobileConfig.SM_Description__c=newWrap.deviceMobileConfig.SM_Description__c;                                
                newMobileConfig.SM_Device_Type__c=newWrap.deviceMobileConfig.SM_Device_Type__c;                
            }
        }
        if(listOfConfig.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG120())); 
            topPagMsgDevice=true;
            disableSaveCancelBtn = true;                       
        }
        else if(listOfConfig.size()>1)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG121())); 
            topPagMsgDevice=true;           
            disableSaveCancelBtn = true;                       
        }
        else
        {
            onSelectProfile(listOfConfig);          
        }
        if(!newMobileConfig.SM_IsDefault__c)
        {
            isDefaultEnable=true;
        } 
        else
        {
            isDefaultEnable=false;
        }         
    }       
    public void addDeviceMobileConfig()
    {
        disableSaveCancelBtn = false;
        topPagMsgDevice = false;
        syncGetEvent='';
        syncRemoveEvent='';
        purgeOlderRec='';
        freqMasterData='';
        freqAppChng='';
        freqDataPurging='';
        isChecklist=false;
        isCompletedChecklist=false;
        isInProgressChecklist=false;
        isLocationTrack=false;
        strFreqLocTracking='';
        strMaxRecToCache='';
        isSetLatestTechLoc=false;
        chatterThreads='';
        downloadLimitKB='';
        allowAPIAccess=false;
        enableLogging=false;
        enableUsageLogging='';
        isUsageLogDisabled=true;
        isSyncPerformance=false;
        isSoqlPerformance=false;
        syncCustomUrl ='';
        orgTypeUserOption = '';
        fileConfigList = new List<FileConfig>();
        List<SVMXC__SM_Device_Mobile_Config__c> listOfConfig = new List<SVMXC__SM_Device_Mobile_Config__c>();        
        onSelectProfile(listOfConfig);  
        newMobileConfig = new SVMXC__SM_Device_Mobile_Config__c (); 
        isDefaultEnable=true;     
    } 
    public void deleteDeviceMobileConfig()
    { 
        topPagMsgDevice=false; 
        List<SVMXC__SM_Device_Mobile_Config__c> listOfConfig = new List<SVMXC__SM_Device_Mobile_Config__c>();
        Boolean isDefaultDelete = false;
        for(DeviceTargetWrap newWrap:listOfDeviceTargetWrap)     
        {
            if(newWrap.isSelect)
            {
                listOfConfig.add(newWrap.deviceMobileConfig);
                newMobileConfig = newWrap.deviceMobileConfig;
            }
            if(newWrap.isSelect && newWrap.deviceMobileConfig.SM_IsDefault__c)
            {
                isDefaultDelete = true;  
            }
        }
        if(listOfConfig.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG120())); 
            topPagMsgDevice=true;
            disableSaveCancelBtn = true;                       
        }
        else if(isDefaultDelete)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG122())); 
            topPagMsgDevice=true;        
            disableSaveCancelBtn = true; 
        }
        else
        {
                boolean isFieldAccessIssue = false;
                try{
                    List<SVMXC__ServiceMax_Config_Data__c> listOfDatas = [select SVMXC__Sequence__c, SVMXC__Access_Configuration_Profile__c, SVMXC__Ownership_Type__c, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Display_Type__c, SVMXC__Internal_Value__c, SVMXC__Object_Name__c, SVMXC__SM_Files_Config__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: RTMobileConfig.Id AND SVMXC__Access_Configuration_Profile__c =: selectedProfile and SM_Device_Mobile_Config__c In:listOfConfig Order By SVMXC__Sequence__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){   //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete listOfDatas;
                }else{
                    isFieldAccessIssue = true;
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    return;
                }
                
                List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigs = [Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedProfile And Id In:listOfConfig];       //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA       
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Device_Mobile_Config__c')){   //SDL-SVMX-DELETE-FLS-ENFORCED
                        delete listOfConfigs;
                }else{
                    isFieldAccessIssue = true;
                    topPagMsgDevice = true;
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    return;
                }
                    
                
                getDeviceTargetedConfiguration(); 
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM, getTAG129())); 
                topPagMsgDevice=true;        
                disableSaveCancelBtn = true;    
            }catch(Exception Ex){
                if(isFieldAccessIssue)
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    else
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
            }                     
        }
    }
    public PageReference cloneDeviceTargetConfig()
    {  
            boolean isFieldAccessIssue = false;
        try{
            List<SVMXC__ServiceMax_Config_Data__c> listOfDatasToDelete = [select SVMXC__Sequence__c, SVMXC__Access_Configuration_Profile__c, SVMXC__Ownership_Type__c, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Display_Type__c, SVMXC__Internal_Value__c, SVMXC__Object_Name__c,SVMXC__SM_Files_Config__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: RTMobileConfig.Id AND SVMXC__Access_Configuration_Profile__c =: selectedProfile Order By SVMXC__Sequence__c];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA        
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete listOfDatasToDelete;  //SDL-SVMX-DELETE-FLS-ENFORCED
            }else{
                isFieldAccessIssue = true;
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                return null;
            }
            
            List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigsToDelete = [Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedProfile ];      //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA                   
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Device_Mobile_Config__c')){
                delete listOfConfigsToDelete;   //SDL-SVMX-DELETE-FLS-ENFORCED
            }else{
                isFieldAccessIssue = true;
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                return null;
            }
            
            Map<String,Id> mapOfOldIdAndItsCloneId = new Map<String,Id>();
            List<Id> listOfOldId = new List<Id>();
            List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigsToInsert = new  List<SVMXC__SM_Device_Mobile_Config__c>();
            for(SVMXC__SM_Device_Mobile_Config__c newConfig:[Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c,SM_Access_Configuration_Profile__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedConfiguredProfile ])
            {
                SVMXC__SM_Device_Mobile_Config__c newConfigCloned = new SVMXC__SM_Device_Mobile_Config__c();
                newConfigCloned = newConfig.clone(false);
                newConfigCloned.SM_Access_Configuration_Profile__c=selectedProfile;
                listOfConfigsToInsert.add(newConfigCloned);
                listOfOldId.add(newConfig.Id);
            }
            
            List<Database.SaveResult> listOfSaveResult;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listOfConfigsToInsert, COMM_SecurityUtils.Access.Createable)){
                    listOfSaveResult = Database.insert(listOfConfigsToInsert);
            }else{
                isFieldAccessIssue = true;
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                return null;
            }
            
            Integer count = 0;
            String errorMessageToDisplay = '';
            for(Database.SaveResult newResult:listOfSaveResult)
            {
                if(newResult.isSuccess())
                {
                    count = count+1;
                }
                else
                {
                    for(Database.Error newError:newResult.getErrors())
                    {
                        errorMessageToDisplay = newError.getMessage();
                    }
                }
            }
            if(count == listOfConfigsToInsert.size())
            {
                for(Integer iterate=0; iterate<listOfOldId.size(); iterate++)
                {
                    mapOfOldIdAndItsCloneId.put(listOfOldId[iterate],listOfSaveResult[iterate].getId());
                }
                
                List<SVMXC__ServiceMax_Config_Data__C> listOfDatasToInsert = new List<SVMXC__ServiceMax_Config_Data__c>();
                for(SVMXC__ServiceMax_Config_Data__c newData:[select SVMXC__Sequence__c, SVMXC__Access_Configuration_Profile__c, SVMXC__Ownership_Type__c, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Display_Type__c, SVMXC__Internal_Value__c, SVMXC__Object_Name__c,SVMXC__SM_Device_Mobile_Config__c, SVMXC__SM_Files_Config__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: RTMobileConfig.Id AND SVMXC__Access_Configuration_Profile__c =: selectedConfiguredProfile Order By SVMXC__Sequence__c])
                {
                    SVMXC__ServiceMax_Config_Data__c newDataCloned = new SVMXC__ServiceMax_Config_Data__c();
                    System.debug('What is the record '+newData.SVMXC__SM_Device_Mobile_Config__c);
                    System.debug('What is the Id '+mapOfOldIdAndItsCloneId.containsKey(newData.SVMXC__SM_Device_Mobile_Config__c));                
                    newDataCloned = newData.clone(false);
                    if(mapOfOldIdAndItsCloneId.containsKey(newData.SVMXC__SM_Device_Mobile_Config__c))
                    {
                        newDataCloned.SVMXC__SM_Device_Mobile_Config__c = mapOfOldIdAndItsCloneId.get(newData.SVMXC__SM_Device_Mobile_Config__c);
                    }
                    newDataCloned.SVMXC__Access_Configuration_Profile__c=selectedProfile;
                    listOfDatasToInsert.add(newDataCloned);
                }
                
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listOfDatasToInsert, COMM_SecurityUtils.Access.Createable)){
                    insert listOfDatasToInsert;   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }else{
                    isFieldAccessIssue = true;
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                    return null;
                }
                
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.CONFIRM,getTAG090()));            
                getDeviceTargetedConfiguration();
                topPagMsgDevice=true;                
            }   
            else
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, errorMessageToDisplay));        
                topPagMsgDevice=true;                
            } 
        }catch(Exception Ex){
                if(isFieldAccessIssue)
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
            else
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
            }  
        isPopup=false;
        selectedConfiguredProfile ='SVMX.None';
        return NULL;                          
        
    }
    public void saveDeviceTargetConfig()
    {
        topPagMsgDevice=false;   
        boolean defaultChanged = false;     
        if(newMobileConfig !=NULL && (newMobileConfig.SM_Name__c ==NULL || newMobileConfig.SM_Name__c ==''))
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG123())); 
            topPagMsgDevice=true;                
        }
        else if(newMobileConfig !=NULL && (newMobileConfig.SM_Description__c ==NULL || newMobileConfig.SM_Description__c ==''))
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG124())); 
            topPagMsgDevice=true;                        
        }
        else if(newMobileConfig !=NULL && (newMobileConfig.SM_Device_Type__c ==NULL || newMobileConfig.SM_Device_Type__c ==''))
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG125())); 
            topPagMsgDevice=true;                                
        }
        
        if(fileConfigList[0]!= NULL && !String.isBlank(fileConfigList[0].maxFileSize) && ( !fileConfigList[0].maxFileSize.isNumeric() || integer.valueOf(fileConfigList[0].maxFileSize) < 0 || integer.valueOf(fileConfigList[0].maxFileSize) > 25 )){
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.FATAL,getTAG150()));
                topPagMsgDevice=true;    
        }
        
        if(!topPagMsgDevice)
        {
            if( freqMasterData == null || freqMasterData.length() == 0 || freqAppChng == null || freqAppChng.length() == 0 || syncGetEvent == null ||syncGetEvent.length() == 0 ||
               syncRemoveEvent == null || syncRemoveEvent.length() == 0 || chatterThreads == null || chatterThreads.length() == 0 ||
               downloadLimitKB == null || downloadLimitKB.length() == 0 || strFreqLocTracking == null || strFreqLocTracking.length() == 0 ||
               strMaxRecToCache == null || strMaxRecToCache.length() == 0 || freqDataPurging == null || freqDataPurging.length() == 0 || purgeOlderRec == null || purgeOlderRec.length() == 0 || (isCustomUrlEnabled && (syncCustomUrl == NULL || syncCustomUrl == '')) )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG013()));
                topPagMsgDevice=true;
            }
            else if(newMobileConfig !=NULL && newMobileConfig.SM_Device_Type__c !=NULL && newMobileConfig.SM_Device_Type__c !='')
            {
                List<String> listOfDeviceTypes = new List<String>();          
                if(newMobileConfig.SM_Device_Type__c.contains(';'))
                {
                    listOfDeviceTypes = newMobileConfig.SM_Device_Type__c.split(';');
                }
                else
                {
                    listOfDeviceTypes.add(newMobileConfig.SM_Device_Type__c);
                }
                Boolean isDeviceExist = false;
                Boolean isExistConfig = false;
                System.debug('Device Type '+listOfDeviceTypes);
                for(SVMXC__SM_Device_Mobile_Config__c newConfig:[Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedProfile])
                {
                    System.debug('Config data '+newConfig.Id);
                    for(String device:listOfDeviceTypes)
                    {
                        if((newMobileConfig.Id != NULL && newConfig.Id != newMobileConfig.Id && newConfig.SM_Device_Type__c !=NULL && device !=NULL && newConfig.SM_Device_Type__c.containsIgnoreCase(device)) || (newMobileConfig.Id == NULL && newConfig.SM_Device_Type__c !=NULL && device !=NULL && newConfig.SM_Device_Type__c.containsIgnoreCase(device)))
                        {
                            if(newConfig.SM_Device_Type__c.containsIgnoreCase(device+';'))
                            {
                                newConfig.SM_Device_Type__c = newConfig.SM_Device_Type__c.replace(device+';','');
                            }
                            else if (newConfig.SM_Device_Type__c.containsIgnoreCase(device))
                            {
                                newConfig.SM_Device_Type__c = newConfig.SM_Device_Type__c.replace(device,'');
                            }
                            if(newConfig.SM_Device_Type__c==NULL || newConfig.SM_Device_Type__c =='')
                            {
                                isExistConfig = true;
                            }
                            isDeviceExist = true;
                        }
                        if((newMobileConfig.Id != NULL && newConfig.Id != newMobileConfig.Id && newConfig.SM_Device_Type__c !=NULL && device !=NULL && newConfig.SM_Device_Type__c.equalsIgnoreCase(device)) || (newMobileConfig.Id == NULL && newConfig.SM_Device_Type__c !=NULL && device !=NULL && newConfig.SM_Device_Type__c.equalsIgnoreCase(device)))
                        {
                            isDeviceExist = false;
                            isExistConfig = true;
                        }
                    }
                }
                if(isExistConfig)
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG126()));
                    topPagMsgDevice=true;                   
                }
                else if(isDeviceExist && !isDeviceAdded)                                
                {
                    topPagMsgDevice=true;
                    isDeviceAdded=true;
                }
                else
                {
                    if(!newMobileConfig.SM_IsDefault__c)
                    {
                        List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigsDefault = new List<SVMXC__SM_Device_Mobile_Config__c>();                
                        if(newMobileConfig.Id !=NULL)
                        {
                            listOfConfigsDefault= [Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedProfile and SM_IsDefault__c= true and Id !=:newMobileConfig.Id];         //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED      
                        }
                        else
                        {
                            listOfConfigsDefault= [Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedProfile and SM_IsDefault__c= true];    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED             
                        }                    
                        if(listOfConfigsDefault.isEmpty())
                        {
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,getTAG127()));
                            topPagMsgDevice=true;                    
                        }
                    }
                }
            }            
            if(!topPagMsgDevice)
            { 
                    boolean isFieldAccessIssue = false;
                try{
                    List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigToUpdate = new List<SVMXC__SM_Device_Mobile_Config__c>();                
                    List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigs = new List<SVMXC__SM_Device_Mobile_Config__c>();
                    if(newMobileConfig.SM_IsDefault__c)
                    { 
                        if(newMobileConfig.Id !=NULL)
                        {
                            listOfConfigs= [Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedProfile and SM_IsDefault__c= true and Id !=:newMobileConfig.Id];    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED 
                        }
                        else
                        {
                            listOfConfigs= [Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedProfile and SM_IsDefault__c= true];     //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED            
                        }
                        if(!listOfConfigs.isEmpty())
                        {
                            for(SVMXC__SM_Device_Mobile_Config__c newConfig:listOfConfigs)
                            {
                                newConfig.SM_IsDefault__c = false;
                                listOfConfigToUpdate.add(newConfig);
                            }
                            newMobileConfig.SM_IsDefault__c = true;
                            defaultChanged = true;
                                         
                        }
                    }  
                    newMobileConfig.SM_Access_Configuration_Profile__c=selectedProfile;  
                    if(newMobileConfig.Id !=NULL)
                    {
                        listOfConfigToUpdate.add(newMobileConfig);                     
                        List<SVMXC__ServiceMax_Config_Data__c> listOfDatasToDelete = [select SVMXC__Sequence__c, SVMXC__Access_Configuration_Profile__c, SVMXC__Ownership_Type__c, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c, SVMXC__Display_Type__c, SVMXC__Internal_Value__c, SVMXC__Object_Name__c, SVMXC__SM_Files_Config__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: RTMobileConfig.Id  AND SVMXC__Access_Configuration_Profile__c =: selectedProfile AND SVMXC__SM_Device_Mobile_Config__c =:newMobileConfig.Id Order By SVMXC__Sequence__c];   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED 
                        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                            delete listOfDatasToDelete;    //SDL-SVMX-DELETE-FLS-ENFORCED
                        }else{
                            isFieldAccessIssue = true;
                            ExpMsg = false;
                            DeletMsg = false;
                            topPagMsgDevice = true;
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                            return;
                        }                                                                             
                    }
                    else
                    {
                            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(new List<SObject>{newMobileConfig}, COMM_SecurityUtils.Access.Createable)){
                                insert newMobileConfig;    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            }else{
                            isFieldAccessIssue = true;
                            ExpMsg = false;
                            DeletMsg = false;
                            topPagMsgDevice = true;
                            
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                            return;
                        }
                    }
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listOfConfigToUpdate , COMM_SecurityUtils.Access.Updateable)){
                            update listOfConfigToUpdate;   //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                            if(defaultChanged){
                                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.WARNING, getTAG128())); 
                                topPagMsgDevice=true;   
                            }     
                    }else{
                        isFieldAccessIssue = true;
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                        return;
                    }
                          
                    List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigsToSave = new List<SVMXC__SM_Device_Mobile_Config__c>();
                    listOfConfigsToSave.add(newMobileConfig);
                    save(listOfConfigsToSave);
                    getDeviceTargetedConfiguration();
                    topPagMsgDevice=true;                
                    disableSaveCancelBtn=true;
                }catch(Exception Ex){
                    if(isFieldAccessIssue)
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                        else
                            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
                }
            }
        }
        DeletMsg=false;
        ExpMsg=false;        
    }
    public pageReference cancelDeviceTargetConfig()
    {
        topPagMsgDevice=false;
        getDeviceTargetedConfiguration();
        disableSaveCancelBtn=true;
        return NULL;
    }
    public PageReference cancel()
    {
        isPopup=false;
        isDeviceAdded=false;
        selectedConfiguredProfile ='SVMX.None';
        return NULL;
    }
    public PageReference confirmMessage()
    {
        if(selectedConfiguredProfile !='SVMX.None')
        {    
            isPopup =true;
        }
        return NULL;
    }
    public PageReference saveDevice()
    {
        saveMessageDevice=false;
        List<String> listOfDeviceTypes = new List<String>();          
        if(newMobileConfig.SM_Device_Type__c.contains(';'))
        {
            listOfDeviceTypes = newMobileConfig.SM_Device_Type__c.split(';');
        }
        else
        {
            listOfDeviceTypes.add(newMobileConfig.SM_Device_Type__c);
        }
        Boolean isDeviceExist = false;
        System.debug('Device Type '+listOfDeviceTypes);
        List<SVMXC__SM_Device_Mobile_Config__c> listOfConfigToUpsert = new List<SVMXC__SM_Device_Mobile_Config__c>();
        for(SVMXC__SM_Device_Mobile_Config__c newConfig:[Select Id,SM_Name__c,SM_IsDefault__c,SM_Description__c,SM_Device_Type__c From SVMXC__SM_Device_Mobile_Config__c Where SM_Access_Configuration_Profile__c =:selectedProfile])
        {
            for(String device:listOfDeviceTypes)
            {
                if((newMobileConfig.Id != NULL && newConfig.Id != newMobileConfig.Id && newConfig.SM_Device_Type__c !=NULL && newConfig.SM_Device_Type__c.containsIgnoreCase(device)) || (newMobileConfig.Id == NULL && newConfig.SM_Device_Type__c !=NULL && newConfig.SM_Device_Type__c.containsIgnoreCase(device)))
                {
                    if(newConfig.SM_Device_Type__c.containsIgnoreCase(device+';'))
                    {
                        newConfig.SM_Device_Type__c = newConfig.SM_Device_Type__c.replace(device+';','');
                    }
                    else if (newConfig.SM_Device_Type__c.containsIgnoreCase(device))
                    {
                        newConfig.SM_Device_Type__c = newConfig.SM_Device_Type__c.replace(device,'');
                    }
                }
            }
            listOfConfigToUpsert.add(newConfig);
        }
        if( listOfConfigToUpsert != NULL && !listOfConfigToUpsert.isEmpty() ){
                boolean isFieldAccessIssue = false;
             try{
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(listOfConfigToUpsert, COMM_SecurityUtils.Access.Upsertable)){
                    upsert listOfConfigToUpsert;    //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }else{
                        isFieldAccessIssue = true;
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                        return null;
            }
             }catch(Exception Ex){
                if(isFieldAccessIssue)
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
            else
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,ex.getMessage()));
             }
        }
        saveDeviceTargetConfig();   
        isDeviceAdded=false; 
        topPagMsgDevice=true;             
        return NULL;
    }
    public class DeviceTargetWrap
    {
        public Boolean isSelect{get;set;}
        public SVMXC__SM_Device_Mobile_Config__c deviceMobileConfig{get;set;}
    }

    //-------------------------------------------------------- TAGS --------------------------------------------------------------------
    public String getHLPURL() {return system.label.CONF032_HLPURL;}//'Help URL'
    public String getTAG003()  {return system.label.CONF032_TAG036;}//'When there are data synchronization conflicts'
    public String getTAG004()  {return system.label.CONF032_TAG041;}//'Number of recent chatter threads to download and show in mobile'
    public String getTAG005()  {return system.label.CONF032_TAG042;}//'Limit maximum size of all Knowledge Base articles to'
    public String getTAG006()  {return system.label.CONF032_TAG025;}//'Synchronization settings for Calendar events and tasks'
    public String getTAG007()  {return system.label.CONF032_TAG033;}//'Mobile Configuration Help'
    public String getTAG009()  {return system.label.CONF032_TAG040;}//'Knowledge Base and Chatter Download Settings'
    public String getTAG012()  {return system.label.CONF032_TAG029;}//'Minutes'
    public String getTAG013()  {return system.label.COMM001_TAG059;}//'Please enter values for all the mandatory fields'
    public String getTAG015()  {return system.label.CONF032_TAG032;}//'days'
    public String getTAG018()  {return system.label.CONF032_TAG043;}//'MB'
    public String getTAG019()  {return system.label.COMM002_TAG005;}//'--None--'
    public String getTAG020()  {return system.label.CONF032_TAG006;}//'Synchronization Settings'
    public String getTAG021()  {return system.label.CONF032_TAG007;}//'Other Settings'
    public String getTAG022()  {return system.label.CONF032_TAG001;}//'ServiceMax Mobile Configuration'
    public String getTAG023()  {return system.label.COMM001_TAG039;}//'Save'
    public String getTAG024()  {return system.label.COMM001_TAG040;}//'Cancel'
    public String getTAG025()  {return system.label.COMM002_TAG025;}//'Expression Name'
    public String getTAG026()  {return system.label.COMM002_TAG026;}//'Expression Id'
    public String getTAG027()  {return system.label.COMM002_TAG027;}//'Field Name'
    public String getTAG028()  {return system.label.COMM002_TAG028;}//'Operator'
    public String getTAG029()  {return system.label.COMM002_TAG029;}//'Value'
    public String getTAG030()  {return system.label.COMM002_TAG030;}//'Expression saved successfully.'
    public String getTAG031()  {return system.label.COMM002_TAG006;}//'Equals'
    public String getTAG032()  {return system.label.COMM002_TAG007;}//'Not Equal'
    public String getTAG033()  {return system.label.COMM002_TAG008;}//'Greater Than'
    public String getTAG034()  {return system.label.COMM002_TAG009;}//'Greater or Equal To'
    public String getTAG035()  {return system.label.COMM002_TAG010;}//'Less Than'
    public String getTAG036()  {return system.label.COMM002_TAG011;}//'Less or Equal To'
    public String getTAG037()  {return system.label.COMM002_TAG012;}//'Starts With'
    public String getTAG038()  {return system.label.COMM002_TAG013;}//'Contains'
    public String getTAG039()  {return system.label.COMM002_TAG014;}//'Does Not Contain'
    public String getTAG040()  {return system.label.COMM002_TAG015;}//'Includes'
    public String getTAG041()  {return system.label.COMM002_TAG016;}//'Excludes'
    public String getTAG042()  {return system.label.COMM002_TAG022;}//'Is Null'
    public String getTAG043()  {return system.label.COMM002_TAG023;}//'Is Not Null'
    public String getTAG045()  {return system.label.COMM002_TAG024;}//'Advance Expression'
    public String getTAG046()  {return system.label.COMM002_TAG004;}//'Invalid Expression'
    public String getTAG047()  {return system.label.COMM002_TAG034;}//'Please enter valid Name'
    public String getTAG048()  {return system.label.COMM002_TAG035;}//'Please enter unique Expression Id which is at least 8 characters long'
    public String getTAG049()  {return system.label.CONF032_TAG027;}//'Automatically when Online'
    public String getTAG050()  {return system.label.CONF032_TAG028;}//'At Regular Intervals'
    public String getTAG051()  {return system.label.CONF032_TAG037;}//'Online Takes Precedence'
    public String getTAG052()  {return system.label.CONF032_TAG038;}//'Mobile Takes Precedence'
    public String getTAG053()  {return system.label.CONF032_TAG039;}//'Ask User'
    public String getTAG054()  {return system.label.CONF032_TAG011;}//'Source to Target All'
    public String getTAG055()  {return system.label.CONF032_TAG012;}//'Source to Traget Child'
    public String getTAG056()  {return system.label.CONF032_TAG013;}//'Standalone Edit'
    public String getTAG057()  {return system.label.CONF032_TAG014;}//'Standalone Create'
    public String getTAG059()  {return system.label.CONF032_TAG015;}//'Standalone View'
    //public String getTAG060()  {return 'Expression Deleted successfully.';}
    public String getTAG061()  {return system.label.COMM001_TAG036;}//'Add'
    public String getTAG062()  {return system.label.COMM001_TAG048;}//'Edit'
    public String getTAG063()  {return system.label.COMM001_TAG049;}//'Delete'
    //public String getTAG064()  {return 'Mobile Dataset';}
    public String getTAG065()  {return system.label.COMM001_TAG041;}//'Processing...'
    public String getTAG066()  {return system.label.COMM001_TAG046;}//'Back To Setup Home'
    public String getTAG067()  {return system.label.CONF032_TAG005;}//'Criteria Action'
    public String getTAG068()  {return system.label.CONF032_TAG005;}//'Download Criteria'
    public String getTAG069()  {return system.label.CONF032_TAG020;}//'Object Name'
    public String getTAG070()  {return system.label.CONF032_TAG018 +' '+selectedProcessName;}//'Objects referenced in SFM transaction'
    public String getTAG071()  {return system.label.CONF032_TAG016;}//'Process Type'
    public String getTAG072()  {return system.label.COMM001_TAG055;}//'Process Name'
    public String getTAG073()  {return system.label.COMM001_TAG056;}//'Process Id'
    public String getTAG074()  {return system.label.CONF032_TAG003;}//'Clone Mobile Configuration From'
    public String getTAG075()  {return system.label.CONF032_TAG002;}//'Select Profile'
    public String getTAG077()  {return system.label.CONF032_TAG004;}//system.label.CONF032_TAG004
    public String getTAG078()  {return system.label.CONF032_TAG008;}//'The selected profile has access to the SFM Transactions listed below. Objects used in these SFM transactions are automatically included in the mobile dataset.'
    public String getTAG080(){ return system.label.COMM001_TAG050;}//'Please select at least one record to perform this action'
    public String getTAG081() {return system.label.CONF032_TAG026;}//'Synchronize events, tasks, and related data'
    public String getTAG082() {return system.label.CONF032_TAG034;}//'Synchronize application data once every'
    public String getTAG083() {return system.label.CONF032_TAG035;}//'Synchronize configuration once every'
    public String getTAG084() {return system.label.CONF032_TAG030;}//'Retrieve past events and tasks up to'
    public String getTAG085() {return system.label.CONF032_TAG031;}//'Delete events and tasks older than'
    public String getTAG086() {return system.label.CONF032_TAG009;}//'Filter List By Object'
    public String getTAG087() {return system.label.CONF032_TAG010;}//'Filter List By Type'
    public String getTAG088() {return system.label.CONF032_TAG019;}//'Define download criteria for each object as applicable. For objects without a download criteria, data will be downloaded to mobile device if a related calendar event was assigned to the user.'
    public String getTAG089() {return system.label.COMM001_TAG057;}//'Are you sure ?'
    public String getTAG090() {return system.label.CONF032_TAG044;}//'Mobile Configuration saved successfully for the selected profile'
    public String getTAG091() {return system.label.COMM001_TAG052;}//'Record(s) deleted successfully'
    public String getTAG092() {return system.label.CONF032_TAG017;}//'Show objects referenced in this SFM Transaction'
    public String getTAG093() {return system.label.COMM002_TAG032;}//'Add Row'
    public String getTAG094() {return system.label.COMM002_TAG033;}//'Delete Row'
    public String getTAG095() {return system.label.CONF032_TAG022;}//'User\'s Records'
    public String getTAG096() {return system.label.CONF032_TAG023;}//'All Records'
    public String getTAG097() {return system.label.CONF032_TAG021;}//'Ownership Type'
    public String getTAG098() {return system.label.COMM001_TAG044;}//'Select'
    public String getTAG099() {return system.label.CONF032_TAG045;}//'Frequency of location tracking '
    public String getTAG100() {return system.label.CONF032_TAG046;}//'Enable Location Tracking'
    public String getTAG101() {return system.label.CONF032_TAG047;}//'Maximum number of location history records to cache in iPad'
    public String getTAG102() {return system.label.CONF032_TAG048;}//'Set latest location as Technician's Location'
    public String getTAG001()  {return system.label.CONF032_TAG050;}//'Advanced Download Criteria'
    public String getTAG002()  {return system.label.CONF032_TAG051;}//'Define advanced download criteria for each object as applicable. The dataset downloaded via advanced download criteria is related to the event window configured for the logged in user profile.'
    public String getTAG008()  {return system.label.CONF032_TAG052;}//'Referenced Object Name'
    public String getTAG010()  {return system.label.CONF032_TAG053;}//'Referenced Field Name'
    public String getTAG011()  {return system.label.CONF032_TAG049;}//'OUTPUT DOCUMENT'
    public String getTAG014()  {return system.label.CONF032_TAG054;}//'Invalid Expression. Please provide the reference Object Name.'
    public String getTAG016()  {return system.label.CONF032_TAG055;}//'Invalid Expression. Please provide the reference Field Name.'
    //public String getTAG017()  {return system.label.CONF032_TAG056 + ' ' + mapAPILabel_Name.get(ObjName_SaveAdvDwnldCritExp);}//'Advanced download criteria for: '
    public String getTAG079()  {return system.label.CONF032_TAG059;}//'Allow API access (Laptop Only)'
    public String getTAG017()  {return system.label.CONF032_TAG056;}//'Frequency for Data Purging'
    public String getTAG060()  {return system.label.CONF032_TAG057;}//'Purge records older than'
    public String getTAG064()  {return system.label.CONF032_TAG058;}//'Hours'
    public String getTAG103()  {return system.label.CONF032_TAG060;}//'Note: All events and event related records are purged automatically if they are outside of the event window.'
    public String getTAG104()  {return system.label.CONF032_TAG061;}//'Enable Logging (iPad/iPhone Only)'
    public String getTAG058()  {return system.label.CONF032_TAG062;}//Input key to enable Sync Activity Monitoring
    public String getTAG105()  {return system.label.CONF032_TAG063;}//Monitor sync activity under following conditions
    public String getTAG106()  {return system.label.CONF032_TAG064;}//None
    public String getTAG107()  {return system.label.CONF032_TAG065;}//Error
    public String getTAG108()  {return system.label.CONF032_TAG066;}//All
    public String getTAG109()  {return system.label.CONF032_TAG067;}//Location Tracking Settings
    public String getTAG110()  {return system.label.CONF032_TAG068;}//API Access and Sync Log Settings
    public String getTAG111()  {return system.label.CONF032_TAG069;}//Restricted Release Feature. Contact support to participate in the program.
    public String getTAG112()  {return system.label.CONF032_TAG070;}//Enable Checklist
    public String getTAG113()  {return system.label.CONF032_TAG071;}//Download Completed Checklists
    public String getTAG114()  {return system.label.CONF032_TAG072;}//Download In Progress Checklists
    public String getTAG115()  {return system.label.CONF032_TAG073;}//Checklists Settings
    public String getTAG116()  {return system.label.CONF032_TAG074;}//Enable Performance Profiling
    public String getTAG117()  {return system.label.CONF032_TAG075;}//Enable SOQL Profiling
    public String getTAG118()  {return system.label.CONF032_TAG076;}//Sync Intervals        
    public String getTAG119()  {return system.label.CONF032_TAG077;}//Other Settings 
    public String getTAG120()  {return system.label.CONF032_TAG078;}//Please select any One Device Specific Configuration   
    public String getTAG121()  {return system.label.CONF032_TAG079;}//Please select Only one Device Specific Configuration    
    public String getTAG122()  {return system.label.CONF032_TAG080;}//You cannot delete Default Mobile Configuration
    public String getTAG123()  {return system.label.CONF032_TAG081;}//Please Enter Name
    public String getTAG124()  {return system.label.CONF032_TAG082;}//Please Enter Description
    public String getTAG125()  {return system.label.CONF032_TAG083;}//Please Select Device Type
    public String getTAG126()  {return system.label.CONF032_TAG084;}//Device Type is already configured with different Configuration. You cannot have same device type for two Configuration
    public String getTAG127()  {return system.label.CONF032_TAG085;}//Yes
    public String getTAG128()  {return system.label.CONF032_TAG086;}//Default Configuration get changed 
    public String getTAG129()  {return system.label.CONF032_TAG087;}//Device Specific Configuration Deleted Successfully 
    public String getTAG130()  {return system.label.CONF032_TAG088;}//This action will copy all settings to the chosen profile. Click Proceed to clone and save configurations.  
    public String getTAG131()  {return system.label.CONF032_TAG089;}//Proceed    
    public String getTAG132()  {return system.label.CONF032_TAG090;}//This setting should be enabled to be able to locate a Part from Spare Parts Manager
    public String getTAG133()  {return system.label.CONF032_TAG091;}//No
    public String getTAG134()  {return system.label.CONF032_TAG092;}//Name
    public String getTAG135()  {return system.label.CONF032_TAG093;}//Description
    public String getTAG136()  {return system.label.CONF032_TAG094;}//Device List
    public String getTAG137()  {return system.label.CONF032_TAG095;}//Default
    public String getTAG138()  {return system.label.CONF032_TAG096;}//Device type already configured with different configuration, and it will be removed. Click proceed to save.
    public String getTAG139()  {return system.label.CONF032_TAG097;}//Performance Profiling enabled for Org Type
    public String getTAG140()  {return system.label.CONF032_TAG098;}//Custom Endpoint URL for Performance Profiling
    public String getTAG141()  {return system.label.CONF032_TAG099;}//Production
    public String getTAG142()  {return system.label.CONF032_TAG100;}//Sandbox
    public String getTAG143()  {return system.label.CONF032_TAG101;}//Custom URL
    public String getTAG144()  {return system.label.FSA020_TAG001;}//Files Download Configuration
    public String getTAG145()  {return system.label.FSA020_TAG002;}//Enable files download
    public String getTAG146()  {return system.label.FSA020_TAG003;}//Maximum file size to download (MB)
    public String getTAG147()  {return system.label.FSA020_TAG004;}//Download only these File types (Comma separated)
    public String getTAG148()  {return system.label.FSA020_TAG005;}//Download Files containing these tags (Comma separated)
    public String getTAG149()  {return system.label.FSA020_TAG006;}//*Note: Download Files related to Event window
    public String getTAG150()  {return system.label.FSA020_TAG007;}//File size limit can range from 0 to 25 MB. Please enter a valid number.
                
}