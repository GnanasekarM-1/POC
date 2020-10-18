/* Security Scanned */
global with sharing class SFMDeliveryController {

    //-----Start-------New Wrapper classes--------//
    public class SFMRequest {
        public String processId;
        public String recordId;
    }

    public class SFMResponse {
        public Boolean isQualified;
        public Boolean isSFMProcess;
        public String errorMessage;
        public String userId;
        public String language;
        public String appInstanceName;
        public String appInstanceURL;
    }

    public class ConfigInfoWrapperResponse{
        public String recordId;
        public String processId;
        public String strLightningTitleProcessName;
        public String strLightningTitleSourceRecordValue;
        public Boolean salesforceFileGlobalValue;
        public String strTabStyleLogoURL;
        public String strColorCodeForIcon;
        public Boolean isSanitizehtmlEnabled;
        public Boolean isUsageStatisticsEnable;
        public Boolean isLaunchDesignerEnabled;
        public String urlForLaunchDesigner;
        public Long numLMD;
        public String ProcessTitle;
        public String Settings;
        public String UserInfo;
        public String strSitePrefix;
        public List<String> lstObjectNames; //Added for the story BAC-5376
        public String cacheSettingValue;//BAC-5829 Cache setting
    }

    public class JWTTokenWrapper{
        public String jwtTokenIdforCommunity;
        public Boolean isJWTTokenEnabledforClient;
    }

    class settingWrapperList {
        public List<SFMDeliveryController.settingWrapper> stringMap = new List<SFMDeliveryController.settingWrapper>();
    }

    class settingWrapper {
        public String key;
        public String value;
        public settingWrapper(String key, String value){
            this.key = key;
            this.value = value;
        }
    }
    //-----End-------New Wrapper classes--------//
    
    public SFMDeliveryController(){}
    
    public JWTTokenWrapper getJWTTokenByJSR(){
        Boolean isJWTTokenEnabled = false;
        String issDetails = '';
        String tokenEndpoint = '';
        String certificateName = '';
        String accessToken = '';
        
        COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        List<String> lstSettingIds = new List<String>();
        
        lstSettingIds.add('GLOB001_GBL039');
        lstSettingIds.add('GLOB001_GBL040');
        lstSettingIds.add('GLOB001_GBL041');
        lstSettingIds.add('GLOB001_GBL042');
        
        Map<String,String> mapAllSettings =  commManageSetting.SVMX_getGlobalSettingList(lstSettingIds);
        if(mapAllSettings.size() > 0){
            if(mapAllSettings.containskey('GLOB001_GBL039'))
                isJWTTokenEnabled = Boolean.valueOf(mapAllSettings.get('GLOB001_GBL039'));
            if(mapAllSettings.containskey('GLOB001_GBL040'))
                tokenEndpoint = mapAllSettings.get('GLOB001_GBL040');
            if(mapAllSettings.containskey('GLOB001_GBL041'))
                certificateName = mapAllSettings.get('GLOB001_GBL041');
            if(mapAllSettings.containskey('GLOB001_GBL042'))
                issDetails = mapAllSettings.get('GLOB001_GBL042');
        }

        if(isJWTTokenEnabled){

            String loginURL = '';
            List<String> loginUrlvar = tokenEndpoint.split('services');

            loginURL = loginUrlvar[0];
            Auth.JWT jwt = new Auth.JWT();
            jwt.setSub(UserInfo.getUserName()); 
            jwt.setAud(loginURL); 
            jwt.setIss(issDetails);
           
            //Create the object that signs the JWT bearer token
            Auth.JWS jws = new Auth.JWS(jwt, certificateName);
            
            if(!Test.isRunningTest()){
                Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
                accessToken = bearer.getAccessToken();
            }
            else{
                accessToken ='Success';
            }
        }

        SFMDeliveryController.JWTTokenWrapper respone = new SFMDeliveryController.JWTTokenWrapper();
        respone.jwtTokenIdforCommunity = accessToken;
        respone.isJWTTokenEnabledforClient = isJWTTokenEnabled;
        System.debug('respone: '+respone);
        return respone;
    }

    public SFMDeliveryController.SFMResponse qualify(SFMDeliveryController.SFMRequest request){
        String RecordID = request.recordId;
        String processID = request.processId;
        String HdrExpression = '', HeaderObject = '';
        Boolean isSFMProcess = false;
        Boolean IsQualified = true;
        String ErrorMessage = '';
        I18N_TranslationDelivery objTranslnUtil = new I18N_TranslationDelivery();

        List<SVMXC__ServiceMax_Processes__c> ProList = [SELECT Id, SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Target Manager' AND (Id =: processID OR SVMXC__ProcessID__c =: processID OR SVMXC__Name__c =: processID)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(ProList.size() == 1){
            if(ProList[0].SVMXC__Purpose__c.touppercase() == 'STANDALONE CREATE' || ProList[0].SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET ALL' || ProList[0].SVMXC__Purpose__c.touppercase() == 'STANDALONE EDIT' || ProList[0].SVMXC__Purpose__c.touppercase() == 'SOURCE TO TARGET CHILD'){
                isSFMProcess = true;
                List<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject = [SELECT Id, SVMXC__Type__c, SVMXC__Submodule__c, SVMXC__Source_Object_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process__c =: ProList[0].Id AND RecordType.Name = 'Process Node Objects']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                if(lstProcessNodeObject != null && lstProcessNodeObject.size() > 0 ){
                    for(SVMXC__ServiceMax_Processes__c Pro : lstProcessNodeObject){
                        if(Pro.SVMXC__Type__c.touppercase() == 'TARGET' && Pro.SVMXC__Submodule__c != null)
                                HdrExpression = Pro.SVMXC__Submodule__c;
                        if(ProList[0].SVMXC__Purpose__c == 'STANDALONE EDIT') {
                            if(Pro.SVMXC__Type__c.touppercase() == 'TARGET')
                                HeaderObject = Pro.SVMXC__Source_Object_Name__c;
                        }else {
                            if(Pro.SVMXC__Type__c.touppercase() == 'SOURCE')
                                HeaderObject = Pro.SVMXC__Source_Object_Name__c;
                        }
                    }
                }
                if(HeaderObject != null && HeaderObject.length() > 0 && HdrExpression != null && HdrExpression.length() > 0 ){

                    SVMXC__ServiceMax_Processes__c expressionProcess = [SELECT Id,SVMXC__Parent_Error_Msg__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Child_Error_Msg__c, SVMXC__Rule_Type__c,SVMXC__Module__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Confirmation_Message__c FROM SVMXC__ServiceMax_Processes__c WHERE Id =: HdrExpression]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

                    if(expressionProcess != null && expressionProcess.SVMXC__Parent_Error_Msg__c != null){
                        ErrorMessage = expressionProcess.SVMXC__Parent_Error_Msg__c;
                        
                        /* Translate SFM Process - Qualification Error Message */
                        if(expressionProcess.SVMXC__Parent_Error_Msg__c.length() > 0 && objTranslnUtil != NULL){
                            expressionProcess = objTranslnUtil.SVMX_GetProcessTranslation(expressionProcess);
                            if(expressionProcess != null && expressionProcess.SVMXC__Parent_Error_Msg__c != null){
                                ErrorMessage = expressionProcess.SVMXC__Parent_Error_Msg__c;
                            } 
                        }
                    }
                    else{
                        ErrorMessage = system.Label.SFM001_TAG158;
                    }
                    
                    List<Sobject> SobjList = new List<Sobject>();
                    List<SVMXC__ServiceMax_Processes__c> lstExpression = [SELECT Id, SVMXC__Source_Object_Name__c, SVMXC__Parent_Object_Criteria__c FROM SVMXC__ServiceMax_Processes__c WHERE Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id = :HdrExpression]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    if(lstExpression.size() > 0){
                        String strObjectName = lstExpression[0].SVMXC__Source_Object_Name__c;
                        String strWhereClause = lstExpression[0].SVMXC__Parent_Object_Criteria__c;
                        String query = 'SELECT Id FROM ' +strObjectName+ ' WHERE Id =: RecordID '+ ' AND ('+ strWhereClause+ ') ';
                        SobjList = Database.query(query);

                        if(SobjList.size() == 0){
                            isQualified = false;
                        }
                    }
                }
            }
        }
        else if(ProList.size() > 1){
            IsQualified = false;
            ErrorMessage = system.Label.SFM002_TAG091+' '+ProcessID;
        }
        else{
            IsQualified = false;
            ErrorMessage = system.Label.SFM002_TAG001;
        }

        if(!isSFMProcess){
             ErrorMessage = system.Label.SFM002_TAG001;
        }

        Organization org = [SELECT InstanceName FROM Organization]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        String appInstanceURL = 'https://'+org.InstanceName+'.salesforce.com';

        SFMDeliveryController.SFMResponse responseObj = new SFMDeliveryController.SFMResponse();
        responseObj.isQualified = isQualified;
        responseObj.isSFMProcess = isSFMProcess;
        responseObj.errorMessage = ErrorMessage;
        responseObj.userId = UserInfo.getUserId();
        responseObj.language = UserInfo.getLanguage();
        responseObj.appInstanceName = org.InstanceName;
        responseObj.appInstanceURL = appInstanceURL;
        return responseObj;
    }

    public static String getInstanceName(){
        Organization org = [SELECT InstanceName FROM Organization];
        return org.InstanceName; 
    }
   
    public SFMDeliveryController.ConfigInfoWrapperResponse processConfigInfo(SFMDeliveryController.SFMRequest request){

        SFMDeliveryController.ConfigInfoWrapperResponse objResponse = new SFMDeliveryController.ConfigInfoWrapperResponse();
        Boolean IsQualified = true;
        
        String RecordID = request.recordId;
        String ProcessID = request.processId;
        String isHTMLorFlash = '';
        String strTabStyleLogoURL = '';
        String strColorCodeForIcon = '';
        String cacheSettingValue = '';
        I18N_TranslationDelivery objTranslnUtil = new I18N_TranslationDelivery();

        objResponse.recordId = RecordID;
        objResponse.processId = ProcessID;


        //BAC-4364 Combined all setting to one
        COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        List<String> lstSettingIds = new List<String>();
        
        lstSettingIds.add('GLOB001_GBL037');
        lstSettingIds.add('GLOB001_GBL038');
        lstSettingIds.add('CONF005_SET052');
        lstSettingIds.add('COMM004_SET001');
        lstSettingIds.add('GLOB001_GBL017');
        lstSettingIds.add('GLOB001_GBL021');
        lstSettingIds.add('SFM001_SET006');
        //BAC-5829 Cache setting
        lstSettingIds.add('SFM002_SET006');
        
        Map<String,String> mapAllSettings =  new Map<String,String>();
        String lunDesignerURI;
        
        //Get all the setting values
        mapAllSettings = commManageSetting.SVMX_getGlobalSettingList(lstSettingIds);
        if(mapAllSettings.size() > 0){
            if(mapAllSettings.containskey('SFM001_SET006'))
              isHTMLorFlash = mapAllSettings.get('SFM001_SET006');
            if(mapAllSettings.containskey('GLOB001_GBL037'))
                objResponse.salesforceFileGlobalValue = Boolean.valueOf(mapAllSettings.get('GLOB001_GBL037'));
            if(mapAllSettings.containskey('GLOB001_GBL038'))
                objResponse.isSanitizehtmlEnabled = Boolean.valueOf(mapAllSettings.get('GLOB001_GBL038'));
            if(mapAllSettings.containskey('COMM004_SET001')){
                if(mapAllSettings.get('COMM004_SET001') == 'Allow')
                    objResponse.isUsageStatisticsEnable = true;
                else if(mapAllSettings.get('COMM004_SET001') == 'Disallow')
                    objResponse.isUsageStatisticsEnable = false;
            }
            //BAC-5829 Cache setting
            if(mapAllSettings.containskey('SFM002_SET006')){
                cacheSettingValue = mapAllSettings.get('SFM002_SET006');
            }
            //BAC-5155
            if('HTML'.equalsIgnoreCase(isHTMLorFlash))
            {
               lunDesignerURI = '/apex/SFM_Designer#/transaction-editor';
            }
            else
            {
              if(mapAllSettings.containskey('CONF005_SET052'))
                  lunDesignerURI = mapAllSettings.get('CONF005_SET052');
            }
        }

        //----Start----Getting SFM submodule Setting values
        SFMDeliveryController.settingWrapperList objSettingList = new SFMDeliveryController.settingWrapperList();
        
        Map<String,String> mapSettings = commManageSetting.SVMX_getSettingList('SFM002', new List<String>{'SET001','SET002','SET003','SET004'});
        
        if(mapSettings != null && mapSettings.size() > 0){
            
            for(String strKey : mapSettings.keyset()){
                
                SFMDeliveryController.settingWrapper objSetting = new SFMDeliveryController.settingWrapper(strKey, mapSettings.get(strKey));
                objSettingList.stringMap.add(objSetting);
            }

            objSettingList.stringMap.add(new SFMDeliveryController.settingWrapper('GBL017', mapAllSettings.get('GLOB001_GBL017')));
            objSettingList.stringMap.add(new SFMDeliveryController.settingWrapper('GBL021', mapAllSettings.get('GLOB001_GBL021')));
            System.debug('objSettingList: '+objSettingList);
        }
        //-----End----Getting SFM submodule Setting values

        SVMXC__Page_Layout__c objPageLayout;
        SVMXC__ServiceMax_Processes__c Process;
        List<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject;
        if(ProcessID != null && ProcessID.length() > 0) {
            List<SVMXC__ServiceMax_Processes__c> ProList = [Select LastModifiedDate, SVMXC__Type__c, SVMXC__Module__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c, SVMXC__Child_Error_Msg__c, SVMXC__Confirmation_Message__c, SVMXC__Tag_Keys__c, SVMXC__Target_Record_Type__c,SVMXC__Dispatch_Process_Status__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__Settings_Name__c, SVMXC__Setting_Unique_ID__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c,SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c, SVMXC__MTTS_Minutes__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__C,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Dispatch_Method__c, SVMXC__Description__c,SVMXC__Default_Value__c, SVMXC__Data_Type__c, SVMXC__Child_Object_Criteria__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Target Manager' and (Id =: ProcessId OR SVMXC__ProcessID__c =: ProcessId OR SVMXC__Name__c =: ProcessId)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(ProList.size() == 1){
                Process = ProList[0];
                
                /* Start - Logic to translate SFM Target Manager (ServiceMax Process) record  */
                if(Process.SVMXC__Tag_Keys__c != NULL && Process.SVMXC__Tag_Keys__c.length() > 0){
                    objTranslnUtil = new I18N_TranslationDelivery(Process.SVMXC__Tag_Keys__c, UserInfo.getLanguage());
                    Process = objTranslnUtil.SVMX_GetProcessTranslation(Process);
                }
                /* End */
            }
            if(Process != null){
                lstProcessNodeObject = [Select  SVMXC__Type__c, SVMXC__Target_Record_Type__c, SVMXC__Target_Object_label__c,SVMXC__Target_Object_Name__c, SVMXC__Submodule__c,SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c,SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Select__c,SVMXC__Search_Order__c, SVMXC__Rule_Type__c, SVMXC__Purpose__c, SVMXC__Process__c, SVMXC__ProcessID__c,SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Column_Name__c, SVMXC__Page_Layout__c, SVMXC__Node_Source_Object_API__c,SVMXC__Node_Parent_API__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c,SVMXC__MapID__c,SVMXC__IsStandard__c, SVMXC__IsPrivate__c, SVMXC__IsDefault__c,SVMXC__Final_Exception_Process__c, SVMXC__Expertise_Match_Enabled__c,SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Child_Object_Criteria__c,SVMXC__Child_Error_Msg__c, SVMXC__Active__c, RecordTypeId, OwnerId, Name, Id, CreatedDate, CreatedById From  SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: Process.id and RecordType.Name = 'Process Node Objects']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                //--------Start-----------Added for the story BAC-5376
                Set<String> setObjectNames = new Set<String>();
                for(SVMXC__ServiceMax_Processes__c objPNO : lstProcessNodeObject){
                    if(objPNO.SVMXC__Type__c == 'TARGET' || objPNO.SVMXC__Type__c == 'TARGETCHILD' ){
                        setObjectNames.add(objPNO.SVMXC__Source_Object_Name__c);
                    }
                }
                objResponse.lstObjectNames = new List<String>();
                objResponse.lstObjectNames.addAll(setObjectNames);
                //--------End-------------Added for the story BAC-5376
                
                if(Process.SVMXC__Page_Layout__c != null){
                    objPageLayout = [select id, LastModifiedDate From SVMXC__Page_Layout__c where id =: Process.SVMXC__Page_Layout__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                }
            }
        }
        
        //------Start------Added for the Story BAC-3057
        COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
        String urlForLaunchDesigner = '';
        Boolean isLaunchDesignerEnabled = objCommUtilV2.isFeatureEnabled('SFM_DESIGNER', UserInfo.getUserId());
        if(isLaunchDesignerEnabled && Process != null){
            if('HTML'.equalsIgnoreCase(isHTMLorFlash))
            {
                urlForLaunchDesigner = lunDesignerURI +'/'+ Process.SVMXC__Purpose__c.replaceAll(' ','_') + '/'+Process.id;
            }
            else 
            {   
                urlForLaunchDesigner = System.URL.getSalesforceBaseUrl().toExternalForm() + lunDesignerURI + '&processID=' +Process.id+'&isChecklistDisabled=true';
            }
        }
        //------End--------Added for the Story BAC-3057
        
        String ProcessTitle = '';
        String strLightningTitleProcessName = '';
        if(Process != null && Process.SVMXC__Name__c != null){
            ProcessTitle =  Process.SVMXC__Name__c;
            strLightningTitleProcessName = Process.SVMXC__Name__c;
        }
            
        // set up the process title with additional information only if we are dealing with an existing record
        if(RecordID != null && RecordID.length() > 0){
            String nameField = '', nameFieldLabel = '', objectName = '';
            Id recordIdObj = Id.valueOf(RecordID);
            Schema.DescribeSObjectResult objDescribe = recordIdObj.getSobjectType().getDescribe();
            Map<String, Schema.SObjectField> fldMap = objDescribe.fields.getMap();
            objectName = objDescribe.getName();

            if(objectName == 'Account'){
                nameField = 'Name';
                nameFieldLabel = Account.AccountNumber.getDescribe().getLabel();
            }
            else{   
                if(fldMap.size() > 0) {
                    for(String s : fldMap.keyset()) {
                        if(fldMap.get(s).getdescribe().isNameField()) {
                            nameField = fldMap.get(s).getdescribe().getName();
                            nameFieldLabel = fldMap.get(s).getdescribe().getlabel();
                            break;
                        }   
                    }
                }
            }
            if(nameField.length() > 0) {
                String query = 'Select '+ nameField + ' From ' +  objectName + ' Where Id = \''+RecordID+'\''; 
                Sobject sobj = Database.query(query);
                if(sobj != null){
                    ProcessTitle += ' (' +nameFieldLabel+ ': ' + String.valueof(sobj.get(nameField)) + ')';
                    objResponse.strLightningTitleSourceRecordValue = String.valueof(sobj.get(nameField));
                }
            }
            
            
            if(String.isNotBlank(objectName)){
                // Get tab set describes
                List<Schema.DescribeTabSetResult> tabSetDescribe = Schema.describeTabs();
                
                //get User theme
                String strUserTheme = UserInfo.getUiTheme();
                System.debug('User theme: '+strUserTheme);
                
                // Iterate through each tab set describe to get list of tabs
                for(DescribeTabSetResult dtsr : tabSetDescribe) {
                    List<Schema.DescribeTabResult> tabDescribe = dtsr.getTabs();
                    for(Schema.DescribeTabResult dtr : tabDescribe) {
                        if(objectName.equalsIgnoreCase(dtr.getSobjectName())){
                            List<Schema.DescribeIconResult> lstdIR = dtr.getIcons();
                            for(Schema.DescribeIconResult dIR : lstdIR){
                                if(strUserTheme == 'Theme4d' && dIR.getTheme() == 'theme4' && dIR.getHeight() == 120 && dIR.getWidth() == 120){
                                    strTabStyleLogoURL = dIR.getUrl();
                                    break;
                                }
                                else if(strUserTheme == 'Theme3' && dIR.getTheme() == 'theme3' && dIR.getHeight() == 32 && dIR.getWidth() == 32){
                                    strTabStyleLogoURL = dIR.getUrl();
                                    break;
                                }
                            }
                            if(strUserTheme == 'Theme4d'){
                                List<Schema.DescribeColorResult> lstdCR = dtr.getColors();
                                for(Schema.DescribeColorResult dCR : lstdCR){
                                    if(dCR.getTheme() == 'theme4' && dCR.getContext() == 'primary'){
                                        strColorCodeForIcon = dCR.getColor();
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //-------Start-----Find last modified date has been changed or not.-------//
        long numLMD;
        if(Process != null){
            list<SVMXC__ServiceMax_Processes__c> lstProcessBusinessRule = [select id, SVMXC__Process3__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Process Business Rule' and SVMXC__Process1__c =: Process.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            set<String> setMapExpId = new set<String>();
            long processLastModifiedDate = Process.LastModifiedDate.getTime();
            long mapExpLastModifiedDate = null;
            long pageLastModifiedDate = null;
            long maxVal;
            numLMD = processLastModifiedDate;
            if(objPageLayout != null && objPageLayout.LastModifiedDate != null)
                pageLastModifiedDate = objPageLayout.LastModifiedDate.getTime();
            if(lstProcessBusinessRule.size() > 0){
                for(SVMXC__ServiceMax_Processes__c pro : lstProcessBusinessRule){
                    if(pro.SVMXC__Process3__c != null)
                        setMapExpId.add(pro.SVMXC__Process3__c);
                }
            }   
            if(lstProcessNodeObject != null && lstProcessNodeObject.size() > 0){
                for(SVMXC__ServiceMax_Processes__c pro : lstProcessNodeObject){
                    if(pro.SVMXC__Module__c != null)
                        setMapExpId.add(pro.SVMXC__Module__c);
                    if(pro.SVMXC__Final_Exception_Process__c != null)
                        setMapExpId.add(pro.SVMXC__Final_Exception_Process__c);
                    if(pro.SVMXC__Submodule__c != null)  
                        setMapExpId.add(pro.SVMXC__Submodule__c);  
                }
                if(setMapExpId.size() > 0){
                    
                    AggregateResult[] groupedResults = [Select MAX(LastModifiedDate) from SVMXC__ServiceMax_Processes__c where Id IN : setMapExpId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(groupedResults != null){
                        for (AggregateResult ar : groupedResults)  {
                            mapExpLastModifiedDate = DateTime.valueof(ar.get('expr0')).getTime(); 
                        }
                    }
                }
            }
            if(mapExpLastModifiedDate != null && pageLastModifiedDate != null){
                maxVal = math.max(mapExpLastModifiedDate, pageLastModifiedDate);
                numLMD =  math.max(maxVal, processLastModifiedDate);
            }
            else if(mapExpLastModifiedDate != null && pageLastModifiedDate == null){
                numLMD =  math.max(mapExpLastModifiedDate, processLastModifiedDate);
            }
            else if(mapExpLastModifiedDate == null && pageLastModifiedDate != null){
                numLMD =  math.max(pageLastModifiedDate, processLastModifiedDate);
            } 
        }
        //-------End-----Find last modified date has been changed or not.-------//

        objResponse.strLightningTitleProcessName = strLightningTitleProcessName;
        objResponse.strTabStyleLogoURL = strTabStyleLogoURL;
        objResponse.strColorCodeForIcon = strColorCodeForIcon;
        objResponse.isLaunchDesignerEnabled = isLaunchDesignerEnabled;
        objResponse.urlForLaunchDesigner = urlForLaunchDesigner;
        objResponse.numLMD = numLMD;
        objResponse.ProcessTitle = ProcessTitle;
        objResponse.Settings = JSON.serialize(objSettingList);
        objResponse.UserInfo = JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getUserInfoInternal());
        objResponse.strSitePrefix = Site.getPathPrefix();
        //BAC-5829 Cache setting
        objResponse.cacheSettingValue = cacheSettingValue;
        return objResponse;
    }

    //------Start----New JSR methods added here---------//
    @RemoteAction
    global static Object JsrGetJwtToken(String requestStr){
        return JSON.serialize(new SVMXC.SFMDeliveryController().getJWTTokenByJSR());
    }    

    @RemoteAction
    global static Object JsrGetConfigInfo(String requestStr){
        SVMXC.SFMDeliveryController.SFMRequest plr = (SVMXC.SFMDeliveryController.SFMRequest)JSON.deserialize(requestStr, SVMXC.SFMDeliveryController.SFMRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryController().processConfigInfo(plr));
    }

    @RemoteAction
    global static Object JsrGetIsQualify(String requestStr){
        SVMXC.SFMDeliveryController.SFMRequest plr = (SVMXC.SFMDeliveryController.SFMRequest)JSON.deserialize(requestStr, SVMXC.SFMDeliveryController.SFMRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryController().qualify(plr));
    }
    //------End----New JSR methods added here---------//
 
    @RemoteAction
    global static Object JsrGetPageLayout(String requestStr){
        SVMXC.SFMDeliveryServiceImpl.PageLayoutRequest plr = (SVMXC.SFMDeliveryServiceImpl.PageLayoutRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.PageLayoutRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getPageLayoutInternal(plr));
    }
    
    @RemoteAction
    global static Object JsrGetBubbleData(String requestStr){
        SVMXC.SFMDeliveryServiceImpl.BubbleDataRequest bdr = (SVMXC.SFMDeliveryServiceImpl.BubbleDataRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.BubbleDataRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getBubbleDataInternal(bdr));
    }
    
    // Visualforce Remoting Exception: No serializer found for class common.api.soap.wsdl.DescribeSObjectResult
    // ----------------
    // if the code block that generates the map is in namespace N1, and an sObject is also in N1, the key in the map 
    // is represented as MyObject__c. However, if the code block is in namespace N1, and the sObject is in namespace N2, 
    // the key is N2__MyObject__c.
    @RemoteAction
    global static Object JsrDescribeObject(String requestStr){
        
        SVMXC.SFMDeliveryServiceImpl.ObjectDescriptionRequest odr = (SVMXC.SFMDeliveryServiceImpl.ObjectDescriptionRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.ObjectDescriptionRequest.class);          
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getObjectDescriptionInternal(odr));
    }
    
    @RemoteAction
    global static Object JsrGetLookupConfig(String requestStr){
        SVMXC.SFMDeliveryServiceImpl.LookupConfigRequest lcr = (SVMXC.SFMDeliveryServiceImpl.LookupConfigRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.LookupConfigRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getLookupConfigInternal(lcr));
    }
    
    @RemoteAction
    global static Object JsrAddRecords(String requestStr){
        
        SVMXC.SFMDeliveryServiceImpl.AddRecordsRequest ar = (SVMXC.SFMDeliveryServiceImpl.AddRecordsRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.AddRecordsRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().addRecordsInternal(ar));
    }
    
    @RemoteAction
    global static Object JsrSaveTarget(String requestStr){
        
        SVMXC.SFM_WrapperDef.SFM_TargetRecord sfmtargetrec = (SVMXC.SFM_WrapperDef.SFM_TargetRecord)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef.SFM_TargetRecord.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().saveTargetInternal(sfmtargetrec));
    }
    
    @RemoteAction
    global static Object JsrGetNextStepInfo(String requestStr){
        
        SVMXC.SFMDeliveryServiceImpl.NextStepInfoRequest nsr = (SVMXC.SFMDeliveryServiceImpl.NextStepInfoRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.NextStepInfoRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getNextStepInfoInternal(nsr));
    }
    
    @RemoteAction
    global static Object JsrGetSnippetForEvent(String requestStr){
        
        SVMXC.SFMDeliveryServiceImpl.SnippetRequest sr = (SVMXC.SFMDeliveryServiceImpl.SnippetRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.SnippetRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getSnippetForEventInternal(sr));
    }
    
    @RemoteAction
    global static Object JsrGetRecordTypes(String requestStr){
        
        SVMXC.SFMDeliveryServiceImpl.RecordTypesRequest rtr = (SVMXC.SFMDeliveryServiceImpl.RecordTypesRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.RecordTypesRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getRecordTypesInternal(rtr));
    }
    
    @RemoteAction
    global static Object JsrGetLookupData(String requestStr){
        
        SVMXC.SFM_WrapperDef.SFM_Request req = (SVMXC.SFM_WrapperDef.SFM_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef.SFM_Request.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getLookupDataInternal(req));
    }
    
    @RemoteAction
    global static Object JsrGetPageData(String requestStr){
        
        SVMXC.SFMDeliveryServiceImpl.PageDataRequest pdr = (SVMXC.SFMDeliveryServiceImpl.PageDataRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.PageDataRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getPageDataInternal(pdr));
    }
    
    //Added by Nidhi as part of lazy loading BAC-4680
    @RemoteAction
    global static Object JsrGetPageDataV2(String requestStr){
        
        SVMXC.SFMDeliveryServiceImpl.PageDataRequestV2 pdr = (SVMXC.SFMDeliveryServiceImpl.PageDataRequestV2)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.PageDataRequestV2.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getPageDataInternalV2(pdr));
    }
    
    @RemoteAction
    global static Object JsrRetrieveDisplayTags(String requestStr){
        
        SVMXC.SFMDeliveryServiceImpl.DisplayTagRequest dtr = (SVMXC.SFMDeliveryServiceImpl.DisplayTagRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.DisplayTagRequest.class);
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().retrieveDisplayTagsInternal(dtr));
    }
    
    @RemoteAction
    global static Object JsrSFM_GetSearchResult_WS(String requestStr){
      SVMXC.INTF_WebServicesDef.INTF_SFMRequest plr = (SVMXC.INTF_WebServicesDef.INTF_SFMRequest)
            JSON.deserialize(requestStr, SVMXC.INTF_WebServicesDef.INTF_SFMRequest.class);
      return JSON.serialize(new SVMXC.SFM_SearchUtils().INTF_getSearchInfoWithData(plr));
    }
    
    @RemoteAction
    global static Object JsrSFM_GetSearchInfo_WS(String requestStr){
      SVMXC.INTF_WebServicesDef.INTF_SFMRequest plr = (SVMXC.INTF_WebServicesDef.INTF_SFMRequest)
            JSON.deserialize(requestStr, SVMXC.INTF_WebServicesDef.INTF_SFMRequest.class);
      return JSON.serialize(new SVMXC.SFM_SearchUtils().INTF_getSearchInfo(plr));
    }


    @RemoteAction
    global static Object JsrGetListOfChecklist(String requestStr){
        SVMXC.SFMDeliveryServiceImpl.PageDataRequest pdr = (SVMXC.SFMDeliveryServiceImpl.PageDataRequest)
                    JSON.deserialize(requestStr, SVMXC.SFMDeliveryServiceImpl.PageDataRequest.class);  
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getListOfChecklist(pdr));                 
    }

    @RemoteAction
    global static Object JsrResolveLookUpDisplayValue(String requestStr){
        SVMXC.SFM_WrapperDef.SFM_Request req = (SVMXC.SFM_WrapperDef.SFM_Request)
                    JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef.SFM_Request.class);
        return JSON.serialize(new SVMXC.SFM_ExecuteLookup().resolveLookup(req));
    }
    
    //Added for BAC-5211
    //Get the lookup details 
    // requestStr -: lookup ids
    @RemoteAction
    global static Object JsrGetLookupConfiguration(String requestStr){
        System.debug('JsrGetLookupConfiguration requestStr '+requestStr);
        SVMXC.SFM_WrapperDef.SFM_PageLookupResponse sfmResponse = new SVMXC.SFM_WrapperDef.SFM_PageLookupResponse();
        try{
            SVMXC.SFM_WrapperDef.SFM_Request req = new SVMXC.SFM_WrapperDef.SFM_Request();
            req.stringListMap.add((SVMXC.SFM_WrapperDef.SFM_StringListMap)
            JSON.deserialize(requestStr, SVMXC.SFM_WrapperDef.SFM_StringListMap.class));
            System.debug('req req  '+req );
            sfmResponse.data = new SVMXC.SFM_GetLookupConfigDefinition().getLookupConfigDefinition(req);
            sfmResponse.response.success = true;
        }catch(Exception e){
            sfmResponse.response.success = false;
            sfmResponse.response.message = e.getMessage();
        }
        return JSON.serialize(sfmResponse);
    }
    //End for BAC-5211
}