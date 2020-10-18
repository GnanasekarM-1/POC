/**
 * @description This class implements the core capabilities for the SFM Delivery service.
 
 * @author      Indresh M S
 * @date        09.05.2012  
 * !!! Note : This class currently refers to multiple services; INTF, SFM, DCON !!! 
 */
 /* Security Scanned */
public with sharing class SFMDeliveryServiceImpl extends SFMDeliveryServiceBase{

    public SFMDeliveryServiceImpl(RestRequest req, RestResponse res){
        super(req, res);
    }
    
    public SFMDeliveryServiceImpl(){  
       /**
        * The empty constructor is introduced so that the service methods can be consumed from VF page.
        */
    }
    
    //Added for the story BAC-3256 query optimizer
    public static Boolean isQueryOptimizerEnabled = false;
    public static void setIsQueryOptimizerEnabled(Boolean val){
        isQueryOptimizerEnabled = val;
    }

    /* This method is used to set isQueryOptimizerEnabled flag based on the GLOB001_GBL036 setting */
    public static void setIsQueryOptimizerEnabled(){ //#newChangeOptiBGSFM
        COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        String settingValue = commManageSetting.SVMX_getGlobalSettingList('GLOB001_GBL036');
        isQueryOptimizerEnabled = String.isNotBlank(settingValue) ? Boolean.valueOf(settingValue) : true;
    }
    
    public static Integer detailRecBatchSize;//Added by Nidhi as part of LazyLoading BAc-4680
    
    override public Object getPageLayout() {
    
        SFMDeliveryServiceImpl.PageLayoutRequest plr = 
                (SFMDeliveryServiceImpl.PageLayoutRequest) deserializeRequestTo(SFMDeliveryServiceImpl.PageLayoutRequest.class);
        
        return getPageLayoutInternal(plr);
    }
    
    public Object getPageLayoutInternal(SFMDeliveryServiceImpl.PageLayoutRequest plr) { 
        SVMXC.SFM_WrapperDef.SFM_Response_PageUI  PageResponseUI = new SVMXC.SFM_WrapperDef.SFM_Response_PageUI();
        SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail profileDataSet = new SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail();//Profile data
        List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail> lstExecutionTimeProfileDetail = new List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail>();
        profileDataSet.name='getPageLayoutInternal'; 
        profileDataSet.reqtype=' ExecutionTime';
        profileDataSet.description='gets page layout data';
        profileDataSet.begintime=datetime.now();
    // create a request
        
    SVMXC.SFM_WrapperDef.SFM_Request_PageUI req = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI();
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = req.request.StringMap;
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('PROCESSID', plr.processId));
        //stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', plr.recordId));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('CLIENT_TYPE', 'WEB'));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('REQUEST_TYPE', 'META'));
        // end of create request
        
        //Added try-catch block for the story BAC-4426
        try{
            SVMXC.SFM_getPageLayout pagelayout = new SVMXC.SFM_getPageLayout(); 
             PageResponseUI=pagelayout.SFM_GetPageLayout(req);
             profileDataSet.endtime=datetime.now();   
             lstExecutionTimeProfileDetail.add(profileDataSet);
             PageResponseUI.response.profileData =  new SVMXC.SFM_WrapperDef.ProfileData(lstExecutionTimeProfileDetail);
             PageResponseUI.response.success = true;
             return PageResponseUI; 
        }
        catch(Exception ex){
            PageResponseUI.response = new SVMXC.SFM_WrapperDef.SFM_Response();
            PageResponseUI.response.success = false;
            PageResponseUI.response.message = ex.getMessage();
            return PageResponseUI;
        }
    }

    public Object getListOfChecklist(SVMXC.SFMDeliveryServiceImpl.PageDataRequest pdr){
         SVMXC.SFM_WrapperDef.SFM_Request ckRequest = new SVMXC.SFM_WrapperDef.SFM_Request();
         SVMXC.SFM_CheckListUtils listofChecklist = new SVMXC.SFM_CheckListUtils();
         SVMXC.SFM_WrapperDef.SFM_Response response = new SVMXC.SFM_WrapperDef.SFM_Response();
         List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
         stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID',pdr.recordId));
         ckRequest.StringMap = stringMap;   
         response = listofChecklist.SFM_GetListOfChecklist(ckRequest);
         return response;
    }
    
    override public Object retrieveDisplayTags() {
        SFMDeliveryServiceImpl.DisplayTagRequest dtr = 
                (SFMDeliveryServiceImpl.DisplayTagRequest) deserializeRequestTo(SFMDeliveryServiceImpl.DisplayTagRequest.class);
        
        return retrieveDisplayTagsInternal(dtr);
    }
    
    public Object retrieveDisplayTagsInternal(SFMDeliveryServiceImpl.DisplayTagRequest dtr){
        list<SVMXC.COMM_TagWebServices.TagsMap> TagListValueM = new List<SVMXC.COMM_TagWebServices.TagsMap>();
        TagListValueM = SVMXC.COMM_TagWebServices.TagdataforSubmodule(dtr.moduleId);
        
        //#PerformanceOptimization
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG133', System.label.IPAD026_TAG011));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG134', System.label.IPAD026_TAG012));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG135', System.label.IPAD026_TAG015));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG136', System.label.IPAD011_TAG002));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG137', System.label.IPAD026_TAG038));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG138', System.label.IPAD026_TAG039));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG139', System.label.IPAD026_TAG040));
        
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA002_TAG002', System.label.IPAD026_TAG001));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA016_TAG003', System.label.IPAD011_TAG002));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA016_TAG005', System.label.SFM002_TAG094));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA016_TAG006', System.label.SFM002_TAG095));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG065', System.label.SFM002_TAG244));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG069', System.label.IPAD022_TAG003));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG077', System.label.IPAD011_TAG006));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG116', System.label.IPAD006_TAG161));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG117', System.label.IPAD018_TAG059));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG118', System.label.IPAD022_TAG004));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG119', System.label.IPAD006_TAG188));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG120', System.label.FSA008_TAG120));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG123', System.label.SFM002_TAG111));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG124', System.label.SFM002_TAG090));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG125', System.label.SFM002_TAG110));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG126', System.label.SFM002_TAG087));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG127', System.label.SFM002_TAG076));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG128', System.label.IPAD006_TAG147));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG141', System.label.IPAD026_TAG032));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG142', System.label.IPAD026_TAG033));
        TagListValueM.add(new SVMXC.COMM_TagWebServices.TagsMap('FSA008_TAG143', System.label.IPAD026_TAG034));
        
        return TagListValueM;
    }
    
    override public Object retrieveSettings() {
        SFMDeliveryServiceImpl.RetrieveSettingsRequest rsr = 
                (SFMDeliveryServiceImpl.RetrieveSettingsRequest) deserializeRequestTo(SFMDeliveryServiceImpl.RetrieveSettingsRequest.class);
        return this.retrieveSettingsInternal(rsr);
    }
    
    public Object retrieveSettingsInternal(SFMDeliveryServiceImpl.RetrieveSettingsRequest rsr) {
        /**
         * The internal method is introduced so that the service methods can be consumed from VF page.
         */
        // create a request
        SVMXC.INTF_WebServicesDef.INTF_Request req = new SVMXC.INTF_WebServicesDef.INTF_Request();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = req.StringMap;
        stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SUBMODULEID', rsr.moduleId));
        // end of create request
        
        return SVMXC.INTF_WebServicesDef.SVMX_RetrieveSettings_WS(req);
    }
    
    override public Object getPageData() {
        
        SFMDeliveryServiceImpl.PageDataRequest pdr = 
                (SFMDeliveryServiceImpl.PageDataRequest) deserializeRequestTo(SFMDeliveryServiceImpl.PageDataRequest.class);
        return this.getPageDataInternal(pdr);
    }
    
    public Object getPageDataInternal(SFMDeliveryServiceImpl.PageDataRequest pdr){
        /**
         * The internal method is introduced so that the service methods can be consumed from VF page.
         */
        SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail profileDataSet = new SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail();//Profile data
        List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail> lstExecutionTimeProfileDetail = new List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail>();
        profileDataSet.name='getPageDataInternal';
        profileDataSet.reqtype=' ExecutionTime';
        profileDataSet.description='get Page Data Internal';
        profileDataSet.begintime=datetime.now();
    // create a request
        SVMXC.SFM_WrapperDef.SFM_Request_PageUI req = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI();
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = req.request.StringMap;
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('PROCESSID', pdr.processId));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', pdr.recordId));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('ACTIONTYPE', pdr.actionType));//Vinod
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('TARGETID', pdr.targetId));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('DATETIMECONVERSIONREQUIRED', pdr.dateTimeConversionRequired));
        // end of create request
        
        //-------Start---------Added for the story BAC-3256 query optimizer------//\
        /*
        List<String> queryFields = new List<String> {'SVMXC__Page_Layout__c'};
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
        List<SVMXC__ServiceMax_Processes__c> lstProcess = [SELECT SVMXC__Page_Layout__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Target Manager' AND SVMXC__ProcessID__c =: pdr.processId];
        if(lstProcess.size() == 1 && lstProcess[0].SVMXC__Page_Layout__c != null){
                //If only id is being queried then we are not checking isAccesible check and can be skip for Checkmarx check
                List<SVMXC__SFM_Event__c> lstSFMEvent = [SELECT Id FROM SVMXC__SFM_Event__c WHERE SVMXC__Page_Layout__c =: lstProcess[0].SVMXC__Page_Layout__c];
                if(lstSFMEvent.size() > 0){*/

                    //Removed the webservice check for the process and now SFM optimized behaviour is directly controlled through setting value.
                    //This is done for the defect 042957
                    COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
                    String settingValue = commManageSetting.SVMX_getGlobalSettingList('GLOB001_GBL036');
                    if(settingValue != null && settingValue.length() > 0){
                        setIsQueryOptimizerEnabled(Boolean.valueOf(settingValue));
                        System.debug('isQueryOptimizerEnabled found setting: '+SFMDeliveryServiceImpl.isQueryOptimizerEnabled);
                    }
                    else{
                        setIsQueryOptimizerEnabled(true);
                        System.debug('isQueryOptimizerEnabled setting not found: '+SFMDeliveryServiceImpl.isQueryOptimizerEnabled);
                    }
                /*}
                else{
                    setIsQueryOptimizerEnabled(true);
                    System.debug('isQueryOptimizerEnabled no event: '+SFMDeliveryServiceImpl.isQueryOptimizerEnabled);
                }
        }*/
        //-------End---------Added for the story BAC-3256 query optimizer------//
        
        //Added by Nidhi as part of LazyLoading BAc-4680
        if(!String.isblank(commManageSetting.SVMX_getGlobalSettingList('SFM002_SET005'))){
            detailRecBatchSize = Integer.valueOf(commManageSetting.SVMX_getGlobalSettingList('SFM002_SET005'));
        }else{
            detailRecBatchSize = 0;
        }        
        //Added by Nidhi Ends here
        
        SVMXC.SFMDeliveryServiceImpl.PageDataResponse pdResponse = new SVMXC.SFMDeliveryServiceImpl.PageDataResponse();
        pdResponse.success = true; // default
        pdResponse.isQualified = true; // default
        
        Boolean qualified = true;
        SVMXC.SFM_GetData getdata = null;
        SVMXC.SFM_WrapperDef.SFM_PageData res = null;
        
        //Added try-catch block for the story BAC-4426
        try{
            //if(pdr.qualify == true){
            // #PerformanceOptimization
            if(pdr.qualify == true && pdr.actionType != null && pdr.actionType.equalsIgnoreCase('QuickSave')){
                qualified = qualify(pdr.processId, pdr.recordId);
                pdResponse.isQualified = qualified;
            }
            if(qualified){
                getdata = new SVMXC.SFM_GetData();
                res = getdata.SFM_getData(req);
                
                pdResponse.data = res;
                //pdResponse.success = res.response.success;
                profileDataSet.endtime=datetime.now();
                lstExecutionTimeProfileDetail.add(profileDataSet);
                res.response.profileData =  new SVMXC.SFM_WrapperDef.ProfileData(lstExecutionTimeProfileDetail);  
                pdResponse.data = res;
            }
             
            return pdResponse;
        }
        
        catch(Exception ex){
            pdResponse.success = false;
            pdResponse.data = new SVMXC.SFM_WrapperDef.SFM_PageData();
            pdResponse.data.response = new SVMXC.SFM_WrapperDef.SFM_Response();
            pdResponse.data.response.message = ex.getMessage();
            System.debug('StackTrace: '+ex.getStackTraceString());
            return pdResponse;
        }
    }
    
    //Added by Nidhi as part of Lazy Loading BAC-4680
    public Object getPageDataInternalV2(SFMDeliveryServiceImpl.PageDataRequestV2 pdr){
        COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        String settingValue = commManageSetting.SVMX_getGlobalSettingList('GLOB001_GBL036');
        if(settingValue != null && settingValue.length() > 0){
            setIsQueryOptimizerEnabled(Boolean.valueOf(settingValue));
            System.debug('isQueryOptimizerEnabled found setting: '+SFMDeliveryServiceImpl.isQueryOptimizerEnabled);
        }
        else{
            setIsQueryOptimizerEnabled(true);
            System.debug('isQueryOptimizerEnabled setting not found: '+SFMDeliveryServiceImpl.isQueryOptimizerEnabled);
        }  
        
        if(!String.isblank(commManageSetting.SVMX_getGlobalSettingList('SFM002_SET005'))){
            detailRecBatchSize = Integer.valueOf(commManageSetting.SVMX_getGlobalSettingList('SFM002_SET005'));
        }else{
            detailRecBatchSize = 0;
        }
        
        SVMXC.SFMDeliveryServiceImpl.PageDataResponseV2 pdResponse = new SVMXC.SFMDeliveryServiceImpl.PageDataResponseV2();
        SVMXC.SFM_WrapperDef.SFM_PageDataV2 res = null;
        pdResponse.success = true; // default
        pdResponse.isQualified = true; // default
        SVMXC.SFM_GetData getdata = new SVMXC.SFM_GetData();
        try{
            res = getdata.SFM_getDataV2(pdr); 
            res.response = new SVMXC.SFM_WrapperDef.SFM_ResponseV2();
            res.response.success = true;
            pdResponse.data = res;      
            return pdResponse;
        }catch(Exception ex){
            pdResponse.success = false;
            pdResponse.data = new SVMXC.SFM_WrapperDef.SFM_PageDataV2();
            pdResponse.data.response = new SVMXC.SFM_WrapperDef.SFM_ResponseV2();
            pdResponse.data.response.message = ex.getMessage();
            pdResponse.data.response.success = false;
            return pdResponse;
        }
    }
    
    override public Object getUserInfo(){
        return this.getUserInfoInternal();
    }
    
    public Object getUserInfoInternal(){
        /**
         * The internal method is introduced so that the service methods can be consumed from VF page.
         */
        return new UserInfoResponse();
    }
    
    override public Object getLookupConfig(){
        SFMDeliveryServiceImpl.LookupConfigRequest lcr = 
                (SFMDeliveryServiceImpl.LookupConfigRequest) deserializeRequestTo(SFMDeliveryServiceImpl.LookupConfigRequest.class);
                
        return getLookupConfigInternal(lcr);
    }
    
    public Object getLookupConfigInternal(SFMDeliveryServiceImpl.LookupConfigRequest lcr){
        system.debug('Lookup Config');         
        // create a request
        SFM_WrapperDef.SFM_LookUpConfigData lkpCfgData=new SFM_WrapperDef.SFM_LookUpConfigData();
        SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail profileDataSet = new SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail();//Profile data
        List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail> lstExecutionTimeProfileDetail = new List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail>();
        profileDataSet.name='getLookupConfigInternal';
        profileDataSet.reqtype=' ExecutionTime';
        profileDataSet.description='gets lookup config data'; 
        profileDataSet.begintime=datetime.now();
        
        
        SVMXC.SFM_WrapperDef.SFM_Request req = new SVMXC.SFM_WrapperDef.SFM_Request();
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = req.stringMap;
        
        if(lcr.KeyWord != null && lcr.KeyWord.length() > 0)
            stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('KEYWORD', lcr.KeyWord));
        
        if(lcr.LookupRecordId != null && lcr.LookupRecordId.length() > 0)
            stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', lcr.LookupRecordId));
        
        if(lcr.ObjectName != null && lcr.ObjectName.length() > 0)
            stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('OBJECTNAME', lcr.ObjectName));
            
        if(lcr.LookupContext != null && lcr.LookupContext.length() > 0)
            stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('CONTEXTVALUE', lcr.LookupContext));
        
        if(lcr.LookupQueryField != null && lcr.LookupQueryField.length() > 0)
            stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('FIELDNAME', lcr.LookupQueryField));   
        
         if(lcr.SearchOperator != null && lcr.SearchOperator.length() > 0)
            stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('SEARCHOPERATOR', lcr.SearchOperator));
        // end of create request
          SVMXC.SFM_getLookUpConfigWithData lc = new SVMXC.SFM_getLookUpConfigWithData();
          lkpCfgData=lc.getLookUpConfigWithData(req);
          profileDataSet.endtime=datetime.now();
          lstExecutionTimeProfileDetail.add(profileDataSet);
          lkpCfgData.response.profileData =  new SVMXC.SFM_WrapperDef.ProfileData(lstExecutionTimeProfileDetail);
          return lkpCfgData; 
    }
    
    override public Object saveTarget() {
        SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = 
                (SVMXC.SFM_WrapperDef.SFM_TargetRecord) deserializeRequestTo(SVMXC.SFM_WrapperDef.SFM_TargetRecord.class);
        return saveTargetInternal(sfmtargetrec);
    }
    
    public Object saveTargetInternal(SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec) {
        
        // create a request
        SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail profileDataSet = new SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail();//Profile data
        List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail> lstExecutionTimeProfileDetail = new List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail>();
        profileDataSet.name='saveTargetInternal';
        profileDataSet.reqtype=' ExecutionTime';
        profileDataSet.description='saveTargetInternal'; 
        profileDataSet.begintime=datetime.now();
 
        SVMXC.SFM_WrapperDef.SFM_Response response=new SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.SFM_saveTargetRecords SaveTarget = new SVMXC.SFM_saveTargetRecords();  
        // end of create request
        
        //Added try-catch block for the story BAC-4426
        try{
            response=SaveTarget.SaveTargetRecords(sfmtargetrec);
            profileDataSet.endtime=datetime.now();
            lstExecutionTimeProfileDetail.add(profileDataSet);
            response.profileData =  new SVMXC.SFM_WrapperDef.ProfileData(lstExecutionTimeProfileDetail);
            return response;
        }
        catch(Exception ex){
            response.success = false;
            response.message = ex.getMessage();
            return response;
        }
    }
    
    override public Object getNextStepInfo() {
        SFMDeliveryServiceImpl.NextStepInfoRequest nsr = 
                (SFMDeliveryServiceImpl.NextStepInfoRequest) deserializeRequestTo(SFMDeliveryServiceImpl.NextStepInfoRequest.class);
        return getNextStepInfoInternal(nsr);
    }
    
    public Object getNextStepInfoInternal(SFMDeliveryServiceImpl.NextStepInfoRequest nsr) {
        
        // create a request
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        List<SVMXC.INTF_WebServicesDef.SVMXMap> valueMap = req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_recordId', nsr.recordId));
        valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_processId', nsr.nextStepId));
        // end of create request
        
        return SVMXC.INTF_WebServicesDef.INTF_GetNextStepURL_WS(req);
    }
    
    override public Object getSnippetForEvent(){
        SFMDeliveryServiceImpl.SnippetRequest sr = 
                (SFMDeliveryServiceImpl.SnippetRequest) deserializeRequestTo(SFMDeliveryServiceImpl.SnippetRequest.class);
        return getSnippetForEventInternal(sr);
    }
    
    public Object getSnippetForEventInternal(SFMDeliveryServiceImpl.SnippetRequest sr){
        
        // create a request
        SVMXC.INTF_WebServicesDef.INTF_Request req = new SVMXC.INTF_WebServicesDef.INTF_Request();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = req.StringMap;
        stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('EventId', sr.eventId));
        // end of create request
        
        return SVMXC.INTF_WebServicesDef.Get_CodeSnippet_SFMEvent_WS(req);
    }
    
    override public Object addRecords(){
        SFMDeliveryServiceImpl.AddRecordsRequest ar = 
                (SFMDeliveryServiceImpl.AddRecordsRequest) deserializeRequestTo(SFMDeliveryServiceImpl.AddRecordsRequest.class);
                
        return addRecordsInternal(ar);
    }
    
    public Object addRecordsInternal(SFMDeliveryServiceImpl.AddRecordsRequest ar){
        
        // create a request
       
     
        SVMXC.SFM_WrapperDef.SFM_Request req = new SVMXC.SFM_WrapperDef.SFM_Request();
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = req.stringMap;
        
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('PROCESSID', ar.processId));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('ALIAS', ar.alias)); 
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('FIELDAPINAME', ar.multiAddFieldApiName));  
        
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> stringListMap = req.stringListMap;
        SVMXC.SFM_WrapperDef.SFM_StringListMap item = new SVMXC.SFM_WrapperDef.SFM_StringListMap();
        item.key = 'RECORDID';
        List<String> valueList = new List<String>();
        item.setvalueList(valueList);
        stringListMap.add(item);
        
        List<String> multiAddFieldRecordIds = ar.multiAddFieldRecordIds;
        
        if(multiAddFieldRecordIds != null){
            Integer i;
            Integer l = multiAddFieldRecordIds.size();
    
            for(i = 0; i < l; i++){
                valueList.add(multiAddFieldRecordIds[i]);
            }
        }
        // end of create request
        
        
        return SVMXC.SFM_WebServicesDef.SFM_AddRecords_WS(req);
    }

    override public Object getBubbleData(){
        SFMDeliveryServiceImpl.BubbleDataRequest bdr = 
                (SFMDeliveryServiceImpl.BubbleDataRequest) deserializeRequestTo(SFMDeliveryServiceImpl.BubbleDataRequest.class);
        
        return getBubbleDataInternal(bdr);
    } 
    
    public Object getBubbleDataInternal(SFMDeliveryServiceImpl.BubbleDataRequest bdr){
        // create a request
        SVMXC.SFM_WrapperDef.SFM_Request req = new SVMXC.SFM_WrapperDef.SFM_Request();
        SVMXC.SFM_WrapperDef.SFM_BubbleWrapper bubble=new  SVMXC.SFM_WrapperDef.SFM_BubbleWrapper();
        SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail profileDataSet = new SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail();//Profile data
        List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail> lstExecutionTimeProfileDetail = new List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail>();
           
        profileDataSet.name='getBubbleDataInternal';
        profileDataSet.reqtype=' ExecutionTime';
        profileDataSet.description='gets internal bubble data'; 
        profileDataSet.begintime=datetime.now();
     
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = req.stringMap;
        
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('SEARCHRECORD', bdr.RecordId));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('RECORDID', bdr.LookupRecordId)); 
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('OBJECTNAME', bdr.ObjectName));
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('INFOTYPE', 'BUBBLE'));
        // end of create request
        
        //Added try-catch block for the story BAC-4426
        try{
            bubble=SVMXC.SFM_WebServicesDef.SFM_GetdBubbleInfo_WS(req); 
            profileDataSet.endtime=datetime.now();
            lstExecutionTimeProfileDetail.add(profileDataSet);
            bubble.response.profileData =  new SVMXC.SFM_WrapperDef.ProfileData(lstExecutionTimeProfileDetail);
            return bubble;
        }
        catch(Exception ex){
            bubble.response = new SVMXC.SFM_WrapperDef.SFM_Response();
            bubble.response.success = false;
            bubble.response.message = ex.getMessage();
            return bubble;
        }
    }   
    
    override public Object getObjectDescription() { 
        SFMDeliveryServiceImpl.ObjectDescriptionRequest odr = 
                (SFMDeliveryServiceImpl.ObjectDescriptionRequest) 
                deserializeRequestTo(SFMDeliveryServiceImpl.ObjectDescriptionRequest.class);
                
        return getObjectDescriptionInternal(odr); 
    }
    
    public Object getObjectDescriptionInternal(SFMDeliveryServiceImpl.ObjectDescriptionRequest odr) {
      
      return new SVMXDescribeObjectUtils().getDescribe(odr.objectName); 
       
    }
    
    override public Object getRecordTypes() { 
        SFMDeliveryServiceImpl.RecordTypesRequest rtr = 
            (SFMDeliveryServiceImpl.RecordTypesRequest) 
            deserializeRequestTo(SFMDeliveryServiceImpl.RecordTypesRequest.class);
        
        return getRecordTypesInternal(rtr); 
    }
    
    public Object getRecordTypesInternal(SFMDeliveryServiceImpl.RecordTypesRequest rtr) { 
        // create a request
        List<SObject> records = new List<SObject>();
        SVMXC.SFM_WrapperDef.SFM_Response_RecordTypes recTypes=new  SVMXC.SFM_WrapperDef.SFM_Response_RecordTypes(records);
        SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail profileDataSet = new SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail();//Profile data
        List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail> lstExecutionTimeProfileDetail = new List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail>();
        profileDataSet.name='getRecordTypesInternal';
        profileDataSet.reqtype=' ExecutionTime';
        profileDataSet.description='gets Record Types Internal'; 
        profileDataSet.begintime=datetime.now();
        SVMXC.SFM_WrapperDef.SFM_Request req = new SVMXC.SFM_WrapperDef.SFM_Request();
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> stringMap = req.stringMap;
        
        stringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('OBJECTNAME', rtr.objectName));
        // end of create request 
        
        recTypes=SVMXC.SFM_WebServicesDef.SFM_getRecordTypes_WS(req);
        profileDataSet.endtime=datetime.now();
        lstExecutionTimeProfileDetail.add(profileDataSet);
        recTypes.response.profileData =  new SVMXC.SFM_WrapperDef.ProfileData(lstExecutionTimeProfileDetail);
        System.debug(Logginglevel.WARN, 'Check Data : '+recTypes);
        return recTypes;
        
    }
        
    override public Object getLayoutDescription() { 
        SFMDeliveryServiceImpl.LayoutDescriptionRequest ldr = 
            (SFMDeliveryServiceImpl.LayoutDescriptionRequest) 
            deserializeRequestTo(SFMDeliveryServiceImpl.LayoutDescriptionRequest.class);
        return getLayoutDescriptionInternal(ldr); 
    }
    
    public Object getLayoutDescriptionInternal(SFMDeliveryServiceImpl.LayoutDescriptionRequest ldr) { 
        return null; 
    }
    
    override public Object getLookupData() { 
        
        SVMXC.SFM_WrapperDef.SFM_Request req = 
                (SVMXC.SFM_WrapperDef.SFM_Request) deserializeRequestTo(SVMXC.SFM_WrapperDef.SFM_Request.class);
        return getLookupDataInternal(req);
    }
    
    public Object getLookupDataInternal(SVMXC.SFM_WrapperDef.SFM_Request request) {  
        system.debug(request + '-- request Passed');
        SVMXC.SFM_WrapperDef.SFM_Response response=new  SVMXC.SFM_WrapperDef.SFM_Response();
        SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail profileDataSet = new SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail();//Profile data
        List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail> lstExecutionTimeProfileDetail = new List<SVMXC.SFM_WrapperDef.ExecutionTimeProfileDetail>();
        profileDataSet.name='getLookupDataInternal';
        profileDataSet.reqtype='ExecutionTime';
        profileDataSet.description='get Lookup Data Internal'; 
        profileDataSet.begintime=datetime.now();
        
        //Added try-catch block for the story BAC-4426
        try{
            SVMXC.SFM_ExecuteLookup el = new SVMXC.SFM_ExecuteLookup();
            response=el.executeLookup(request); 
            profileDataSet.endtime=datetime.now();
            lstExecutionTimeProfileDetail.add(profileDataSet);
            response.profileData =  new SVMXC.SFM_WrapperDef.ProfileData(lstExecutionTimeProfileDetail);
            return response; 
        }
        catch(Exception ex){
            response.success = false;
            response.message = ex.getMessage();
            System.debug('ex.getMessage() : ' + ex.getMessage());
            System.debug('ex.getStackTraceString() : ' + ex.getStackTraceString());
            return response;
        }
    }
    
    // applicable only during quick save / edit process
    // TODO: PUBLIC for testing purposes only, make private
    public Boolean qualify(String ProcessId, String RecordId){
        System.debug('ProcessId : ' + ProcessId  + ' RecordId : ' + RecordId);
        list<SVMXC__ServiceMax_Processes__c> ProList = null; 
        SVMXC__ServiceMax_Processes__c Process = null;
        list<SVMXC__ServiceMax_Processes__c> ProcessNodeObjects = null;
        String HdrExpression = '', HeaderObject = '';
        Boolean isQualified = true;
        String targetManager = '', processNodeObj = '';
        //Commented for BAC-4366
        /*List<RecordType> RecordTypes = null;
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        if(RecordTypes.size() > 0 ) {
            for(RecordType r : RecordTypes) {
                if(r.Name == 'Target Manager') {
                    targetManager = r.id;
                }else if(r.Name == 'Process Node Objects'){
                    processNodeObj = r.id;
                }
            }
        }*/
        //Added for BAC-4366
        List<String> lstRecordTypeName = new List<String>();
        lstRecordTypeName.add('Target_Manager');
        lstRecordTypeName.add('Process_Node_Objects');
        Map<String,Id> mapRecordTypeDetails = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c',lstRecordTypeName);
        targetManager = mapRecordTypeDetails.get('Target_Manager');
        processNodeObj = mapRecordTypeDetails.get('Process_Node_Objects');
        
        //End BAC-4366
    //Commented this query and added new one with only required fields to be queried for the story BAC-4410
        //ProList = [Select SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordTypeId =: TargetManager and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];
        
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ProList = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE RecordTypeId =: TargetManager AND (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)];
        Process = ProList[0];
        
        //Commented this query and added new one with only required fields to be queried for the story BAC-4410
        //ProcessNodeObjects = [Select  SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c,SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, SVMXC__Source_Object_Name__c,SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__c,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: Process.id and RecordTypeId =: ProcessNodeObj];

        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ProcessNodeObjects = [SELECT Id, SVMXC__Type__c, SVMXC__Submodule__c, SVMXC__Submodule__r.SVMXC__Source_Object_Name__c FROM  SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process__c =: Process.id AND RecordTypeId =: ProcessNodeObj];
        
        for(SVMXC__ServiceMax_Processes__c Pro : ProcessNodeObjects){
            
            if(Pro.SVMXC__Type__c.touppercase() == 'TARGET' && Pro.SVMXC__Submodule__c != null){
                HdrExpression = Pro.SVMXC__Submodule__c;
                /* Defect : 17896 
                   Root Cause : The variable 'HeaderObject' should have Source object API name, 
                                as the qualification criteria will be applied on the source record */
                HeaderObject = Pro.SVMXC__Submodule__r.SVMXC__Source_Object_Name__c; 
            }                        
            
            /* if(Pro.SVMXC__Type__c.touppercase() == 'TARGET')
                HeaderObject = Pro.SVMXC__Source_Object_Name__c;  */                 
        }
        System.debug('INFO => ' + HeaderObject + '::' + targetManager + '::' + processNodeObj);
        System.debug('Checking for header information');    
        if(HeaderObject != null && HeaderObject.length() > 0 && HdrExpression != null && HdrExpression.length() > 0 ){
             
            System.debug('Header information found');
            
            //------Start------This is commented for code optimization BAC-2993----//
            /*
            // set up the error message
            SVMXC__ServiceMax_Processes__c exp = [select id,SVMXC__Parent_Error_Msg__c from SVMXC__ServiceMax_Processes__c where id =: HdrExpression];
                    
            SVMXC.SFM_buildSobject BuildSobject = new SVMXC.SFM_buildSobject(); 
            SVMXC.SFM_parseExpression ExpParssig = new SVMXC.SFM_parseExpression(); 
            
            list<Sobject> HeaderSobjList = null;
            list<Sobject> SobjList = new list<Sobject>();
            HeaderSobjList =  BuildSobject.getSFM_BuildSobject(RecordID,HeaderObject,null,null);
            SVMXC__ServiceMax_Processes__c Expression = null;
            Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :HdrExpression];

            if(Expression != null && HeaderSobjList.size() > 0) {
                SVMXC.SFM_WrapperDef.SFM_Expression SFMExpression = new SVMXC.SFM_WrapperDef.SFM_Expression();
                SFMExpression.namedExpression = Expression;
                SobjList = ExpParssig.SFM_ParseExpression(HeaderSobjList,SFMExpression);
            }*/
            //------End------This is commented for code optimization BAC-2993----//
            
            System.debug('isQueryOptimizerEnabled SFMDeliveryServiceImpl: '+SFMDeliveryServiceImpl.isQueryOptimizerEnabled);
            //------Start------Added for code optimization BAC-2993----//
            if(SFMDeliveryServiceImpl.isQueryOptimizerEnabled){ //Check added as part of story BAC-3256
                    SVMXC.SFM_parseExpression objparseExpression = new SVMXC.SFM_parseExpression();
                List<Sobject> SobjList = new List<Sobject>();
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__ServiceMax_Processes__c> lstExpression = [SELECT Id, SVMXC__Source_Object_Name__c, SVMXC__Parent_Object_Criteria__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :HdrExpression];
                
                if(lstExpression.size() > 0){
                    String strObjectName = lstExpression[0].SVMXC__Source_Object_Name__c;
                    String strWhereClause = lstExpression[0].SVMXC__Parent_Object_Criteria__c;
                    SobjList = objparseExpression.SFM_GetRecordsAfterApplyingCriteria(RecordID, strObjectName, null, strWhereClause, 'Id', null);
                }
    
                if(SobjList.size() == 0){
                    isQualified = false;
                }
                System.debug('lstExpression: '+lstExpression);
                System.debug('SobjList: '+SobjList);
            }
            else{
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    SVMXC__ServiceMax_Processes__c exp = [select id,SVMXC__Parent_Error_Msg__c from SVMXC__ServiceMax_Processes__c where id =: HdrExpression];
                    
                SVMXC.SFM_buildSobject BuildSobject = new SVMXC.SFM_buildSobject(); 
                SVMXC.SFM_parseExpression ExpParssig = new SVMXC.SFM_parseExpression(); 
                
                list<Sobject> HeaderSobjList = null;
                list<Sobject> SobjList = new list<Sobject>();
                HeaderSobjList =  BuildSobject.getSFM_BuildSobject(RecordID,HeaderObject,null,null);
                SVMXC__ServiceMax_Processes__c Expression = null;
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :HdrExpression];
    
                if(Expression != null && HeaderSobjList.size() > 0) {
                    SVMXC.SFM_WrapperDef.SFM_Expression SFMExpression = new SVMXC.SFM_WrapperDef.SFM_Expression();
                    SFMExpression.namedExpression = Expression;
                    SobjList = ExpParssig.SFM_ParseExpression(HeaderSobjList,SFMExpression);
                }
                if(SobjList.size() == 0){
                    isQualified = false;
                }
            }
            //------End-------Added for code optimization BAC-2993----//  
        }
        return isQualified;
    }
    
    //BAC-5929 getLookupConfiguration Rest service
    override public Object getLookupConfiguration(){
        system.debug('Enter - getLookupConfiguration()');
        SVMXC.SFM_WrapperDef.SFM_Request lookUpConfigRequest = new SVMXC.SFM_WrapperDef.SFM_Request();
        lookUpConfigRequest.stringListMap.add((SVMXC.SFM_WrapperDef.SFM_StringListMap) deserializeRequestTo(SVMXC.SFM_WrapperDef.SFM_StringListMap.class));
                
        SVMXC.SFM_WrapperDef.SFM_PageLookupResponse sfmResponse = new SVMXC.SFM_WrapperDef.SFM_PageLookupResponse();
        sfmResponse.data = new SVMXC.SFM_GetLookupConfigDefinition().getLookupConfigDefinition(lookUpConfigRequest);
        sfmResponse.response.success = true;
        return sfmResponse;
    }

    //BAC-5929 getConfigInfo Rest service
    override public Object getConfigInfo(){
        system.debug('Enter - getConfigInfo()');
        SVMXC.SFMDeliveryController.SFMRequest configInfoRequest = (SVMXC.SFMDeliveryController.SFMRequest) deserializeRequestTo(SVMXC.SFMDeliveryController.SFMRequest.class);
        return new SVMXC.SFMDeliveryController().processConfigInfo(configInfoRequest);
    }
    
    //BAC-5929 getIsQualify Rest service
    override public Object getIsQualify(){
        system.debug('Enter - getIsQualify()');
        SVMXC.SFMDeliveryController.SFMRequest qualifyRequest = (SVMXC.SFMDeliveryController.SFMRequest) deserializeRequestTo(SVMXC.SFMDeliveryController.SFMRequest.class);
        return new SVMXC.SFMDeliveryController().qualify(qualifyRequest);
    }
    
    //BAC-6067 resolveLookUpDisplayValue Rest service
    override public Object resolveLookUpDisplayValue(){
        system.debug('Enter - resolveLookUpDisplayValue()');
        SVMXC.SFM_WrapperDef.SFM_Request lookUpRequest = (SVMXC.SFM_WrapperDef.SFM_Request) deserializeRequestTo(SVMXC.SFM_WrapperDef.SFM_Request.class);
        return new SVMXC.SFM_ExecuteLookup().resolveLookup(lookUpRequest);
    }
    
    public class LookupConfigRequest{
        
        // Record id of the lookup configuration, if there is one
        public String LookupRecordId;
        
        // The search string
        public String KeyWord;
        
        // The API name of the object on which this look up field exists. Used to show default look up
        public String ObjectName;
        
        // The context on which this look up is dependent on
        public String LookupContext;
        
        // The matching field
        public String LookupQueryField;
        
        // The search operator; eq, sw, ew, contains
        public String SearchOperator;
    }
    
    public class UserInfoResponse{
        public String UserId;
        public String DateFormat;
        public String Language;
        public String TimezoneOffset;
        public String OrganizationId;
        public String OrganizationName;
        public String OrganizationType;
        public String SFMD_AppVersion; //Added for the task BAC-5184
        public String CurrencyCode; //Added for BAC-6102
        public UserInfoResponse(){
            UserId = UserInfo.getUserId();
            Language = UserInfo.getLanguage();
            CurrencyCode = UserInfo.getDefaultCurrency();//Added for BAC-6102
            DateFormat = SVMXC.DCON_Configuration_WS.DCON_GetLocalDate_WS(UserId);
            TimezoneOffset = new SVMXC.SVMX_Constant_Utils().getUserTimezoneOffset();
            SFMD_AppVersion = String.valueOf(Decimal.valueOf(String.valueOf(System.requestVersion())).setScale(5)); //Added for the task BAC-5184
            List<Organization> lstOrganization =  [SELECT Id,IsSandbox,Name FROM Organization];
            if(lstOrganization.size() > 0){
                OrganizationId = lstOrganization[0].Id;
                OrganizationName =  lstOrganization[0].Name;
                OrganizationType = lstOrganization[0].IsSandbox == true ? 'Sandbox' : 'Production';
            }
        }
    }
    
    public class PageLayoutRequest {
        public String processId;
        public String recordId;
    }
    
    public class PageDataRequest {
        public String processId;
        public String recordId;
        public Boolean qualify;
        public String actionType;
        public String targetId;
        public String dateTimeConversionRequired;
        
        public PageDataRequest(){}
    
        public PageDataRequest(String processId, String recordId, String actionType){
            this.processId = processId;
            this.recordId = recordId;
            this.qualify = false;
            this.actionType = actionType;
        }        
        
        public PageDataRequest(String processId, String recordId, String actionType, String targetId){
            this.processId = processId;
            this.recordId = recordId;
            this.qualify = false;
            this.actionType = actionType;
            this.targetId = targetId;
        }
    }
    
    //Added by Nidhi as part of lazy loading BAC-4680
    public class PageDataRequestV2 {
        public String processId;
        public String recordId;
        public List<SVMXC.SFM_WrapperDef.SFM_StringMap> bubbleInfoCollections = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        public list<SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest> detailDataSet;
    }
    
    public class PageDataResponse {
        public Boolean success;
        public Boolean isQualified;
        public SVMXC.SFM_WrapperDef.SFM_PageData data;
    }
    
    //Added by Nidhi as part of lazy loading BAC-4680
    public class PageDataResponseV2 {
        public Boolean success;
        public Boolean isQualified;
        public SVMXC.SFM_WrapperDef.SFM_PageDataV2 data;
    }
    
    public class DisplayTagRequest {
        public String moduleId;
        public Boolean isSubModule; // TODO: Delete this attribute
    }
    
    public class RetrieveSettingsRequest {
        public String moduleId;
        
        public RetrieveSettingsRequest(){}
        
        public RetrieveSettingsRequest(String moduleId){
            this.moduleId = moduleId;
        }
    }
    
    public class NextStepInfoRequest {
        public String recordId;
        public String nextStepId;
    }
    
    public class SnippetRequest {
        public String eventId;
    }
    
    public class AddRecordsRequest {
        public String processId;
        public String alias;
        public String multiAddFieldApiName;
        public List<String> multiAddFieldRecordIds = new List<String>();
    }
    
    public class BubbleDataRequest{
        
        // Record id of the lookup configuration, if there is one
        public String LookupRecordId;
        
        // record id for which the bubble data has to be populated
        public String RecordId;
        
        // API name of the object
        public String ObjectName;
    }
    
    public class RecordTypesRequest{
        public String objectName;
    }
    
    public class LayoutDescriptionRequest{
        public String objectName;
        public String recordTypeId;
    }
    
    public class ObjectDescriptionRequest {
        public String objectName;
    }

}