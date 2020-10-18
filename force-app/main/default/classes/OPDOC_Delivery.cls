global with sharing class OPDOC_Delivery {

    //-----Start-------New Wrapper classes--------//Added for the story BAC-5383
    public class OPDOC_Request {
        public String processId;
        public String recordId;
    }

    public class OPDOC_ConfigResponse{
        public String recordId;
        public String processId;
        public Boolean isQualified;
        public String errorMessage;
        public String objectLabel;
        public String strNameFieldValue;
        public String strTabStyleLogoURL;
        public String strColorCodeForIcon;
        public Boolean isSanitizehtmlEnabled;
        public Boolean isLaunchDesignerEnabled;
        public String urlForLaunchDesigner;
        public Long numLMD;
        public String strSettings;
        public String strSfmDeliverySettings;
        public String strUserInfo;
    }

    public class OPDOC_QualifyResponse{
        public Boolean isQualified;
        public String errorMessage;
    }

    class settingWrapperList{
        public List<OPDOC_Delivery.settingWrapper> stringMap = new List<OPDOC_Delivery.settingWrapper>();
    }

    class settingWrapper{
        public String key;
        public String value;
        public settingWrapper(String key, String value){
            this.key = key;
            this.value = value;
        }
    }
    //-----End-------New Wrapper classes--------//Added for the story BAC-5383

    //-----Start-------New Methods--------//Added for the story BAC-5383

    public OPDOC_Delivery.OPDOC_ConfigResponse processConfigInfo(OPDOC_Delivery.OPDOC_Request request){
        OPDOC_Delivery.OPDOC_ConfigResponse objResponse = new OPDOC_Delivery.OPDOC_ConfigResponse();

        String RecordID = request.recordId;
        String ProcessID = request.processId;
        String isHTMLorFlash = '';
        Boolean isLaunchDesignerEnabled = false;

        //----Call qualify method
        OPDOC_Delivery.OPDOC_QualifyResponse objQualifyRes = qualify(request);
        objResponse.isQualified = objQualifyRes.isQualified;
        objResponse.errorMessage = objQualifyRes.errorMessage;

        //----Fetching Setting Values
        COMM_Utils_ManageSettings commManageSetting = new COMM_Utils_ManageSettings();
        List<String> lstSettingIds = new List<String>();
        lstSettingIds.add('CONF005_SET052');
        lstSettingIds.add('GLOB001_GBL038');
        lstSettingIds.add('SFM001_SET006');
        Map<String,String> mapAllSettings =  new Map<String,String>();
        String lunDesignerURI;
        //Get all the setting values
        mapAllSettings = commManageSetting.SVMX_getGlobalSettingList(lstSettingIds);
        if(mapAllSettings.size() > 0){
            if(mapAllSettings.containskey('GLOB001_GBL038'))
                objResponse.isSanitizehtmlEnabled = Boolean.valueOf(mapAllSettings.get('GLOB001_GBL038'));
            if(mapAllSettings.containskey('CONF005_SET052'))
                lunDesignerURI = mapAllSettings.get('CONF005_SET052');
            if(mapAllSettings.containskey('SFM001_SET006'))
              isHTMLorFlash = mapAllSettings.get('SFM001_SET006');
        }

        //-------Start--------//Forming URL for launch designer
        List<SVMXC__ServiceMax_Processes__c> lstProcess = [Select Id, LastModifiedDate, SVMXC__Doc_Template__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Target Manager' AND (Id =: ProcessID OR SVMXC__ProcessID__c =: ProcessID)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstProcess.size() == 1){
            COMM_Utils_V2 objCommUtilV2 = new COMM_Utils_V2();
            isLaunchDesignerEnabled = objCommUtilV2.isFeatureEnabled('SFM_DESIGNER', UserInfo.getUserId());
            if(isLaunchDesignerEnabled){
                if(isHTMLorFlash.equalsIgnoreCase('HTML')){
                    objResponse.urlForLaunchDesigner = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SVMXC__SFM_Designer#/transaction-editor/OUTPUT_DOCUMENT/' + lstProcess[0].Id;
                }else{
                    objResponse.urlForLaunchDesigner = System.URL.getSalesforceBaseUrl().toExternalForm() + lunDesignerURI + '&processID=' +lstProcess[0].Id+'&isChecklistDisabled=true';
                }
            }
        }
        //-------End--------//Forming URL for launch designer

        //---Start------Added for the story BAC-3627 for sending info related to ObjectLabel, NameValue and Tab style logo URL
        String objectName = '';
        String objectLabel = '';
        String strNameFieldValue = '';
        String strTabStyleLogoURL = '';
        String strColorCodeForIcon = '';
        if(String.isNotBlank(RecordID)){
            String nameField = '';
            Id recordIdObj = Id.valueOf(RecordID);
            Schema.DescribeSObjectResult objDescribe = recordIdObj.getSobjectType().getDescribe();
            Map<String, Schema.SObjectField> fldMap = objDescribe.fields.getMap();
            objectName = objDescribe.getName();
            objectLabel = objDescribe.getLabel();
            
            //Iterate through all fields and get Name field from the object
            if(fldMap.size() > 0) {
                for(String s : fldMap.keyset()) {
                    if(fldMap.get(s).getdescribe().isNameField()) {
                        nameField = fldMap.get(s).getdescribe().getName();
                        break;
                    }   
                }
            }
            //Query name field value from the record
            if(String.isNotBlank(nameField) && String.isNotBlank(objectName)) {
                //Checking accessibility of fields
                List<String> queryFields = new List<String> {nameField};
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( objectName, queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
        
                //querying record to get name field value
                String query = 'Select '+ nameField + ' From ' +  objectName + ' Where Id = \''+RecordID+'\'';
                System.debug('query: '+query);
                Sobject sobj = Database.query(query);
                if(sobj != null){
                    strNameFieldValue = String.valueof(sobj.get(nameField));
                }
            }
        }
        
        if(String.isNotBlank(objectName)){
            // Get tab set describes
            List<Schema.DescribeTabSetResult> tabSetDescribe = Schema.describeTabs();
            //get User theme
            String strUserTheme = UserInfo.getUiThemeDisplayed();
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
        //---End------Added for the story BAC-3627 for sending info related to ObjectLabel, NameValue and Tab style logo URL

        //-------Start-----------//LMD calculation
        Long numLMD;
        if(lstProcess.size() == 1){
            SVMXC__ServiceMax_Processes__c Process = lstProcess[0];
            list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject = [SELECT Id, SVMXC__Submodule__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Process Node Objects' AND SVMXC__Process__c =: Process.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA

            List<SVMXC__Doc_Template__c> docTempDetail = [SELECT Id, LastModifiedDate FROM SVMXC__Doc_Template__c WHERE Id =: Process.SVMXC__Doc_Template__c];

            Set<String> setMapExpId = new Set<String>();
            long processLastModifiedDate = Process.LastModifiedDate.getTime();
            long mapExpLastModifiedDate = null;
            long templateLastModifiedDate = null;
            
            if(docTempDetail != null && docTempDetail.size() > 0)
                templateLastModifiedDate = docTempDetail[0].LastModifiedDate.getTime();
            
            numLMD = templateLastModifiedDate;
            if(lstProcessNodeObject != null && lstProcessNodeObject.size() > 0){
                for(SVMXC__ServiceMax_Processes__c pro : lstProcessNodeObject){
                    if(pro.SVMXC__Submodule__c != null)  
                        setMapExpId.add(pro.SVMXC__Submodule__c);  
                }

                if(setMapExpId.size() > 0){
                    AggregateResult[] groupedResults = [SELECT MAX(LastModifiedDate) FROM SVMXC__ServiceMax_Processes__c WHERE Id IN: setMapExpId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(groupedResults != null){
                        for(AggregateResult ar : groupedResults)  {
                            mapExpLastModifiedDate = DateTime.valueof(ar.get('expr0')).getTime(); 
                        }
                    }
                }
            }
            if(mapExpLastModifiedDate != null && templateLastModifiedDate != null){
                long maxVal = math.max(mapExpLastModifiedDate, templateLastModifiedDate);
                numLMD =  math.max(maxVal, processLastModifiedDate);
            }
            else if(mapExpLastModifiedDate != null && templateLastModifiedDate == null){
                numLMD =  math.max(mapExpLastModifiedDate, processLastModifiedDate);
            }
            else if(mapExpLastModifiedDate == null && templateLastModifiedDate != null){
                numLMD =  math.max(templateLastModifiedDate, processLastModifiedDate);
            } 
        }
        //-------End-----------//LMD calculation

        //------Start----------//Setting fetching
        OPDOC_Delivery.settingWrapperList objSFMSettingList = new OPDOC_Delivery.settingWrapperList();
        OPDOC_Delivery.settingWrapperList objOpdocSettingList = new OPDOC_Delivery.settingWrapperList();

        Map<String,String> mapSettings = commManageSetting.SVMX_getSettingList('SFM002', new List<String>{'SET004'});
        if(mapSettings != null && mapSettings.size() > 0){
            for(String strKey : mapSettings.keyset()){
                OPDOC_Delivery.settingWrapper objSetting = new OPDOC_Delivery.settingWrapper(strKey, mapSettings.get(strKey));
                objSFMSettingList.stringMap.add(objSetting);
            }
        }

        mapSettings = commManageSetting.SVMX_getSettingList('SFM004', new List<String>{'SET001'});
        if(mapSettings != null && mapSettings.size() > 0){
            for(String strKey : mapSettings.keyset()){
                OPDOC_Delivery.settingWrapper objSetting = new OPDOC_Delivery.settingWrapper(strKey, mapSettings.get(strKey));
                objOpdocSettingList.stringMap.add(objSetting);
            }
        }
        //------End----------//Setting fetching

        objResponse.recordId = RecordID;
        objResponse.processId = ProcessID;
        objResponse.objectLabel = objectLabel;
        objResponse.strNameFieldValue = strNameFieldValue;
        objResponse.strTabStyleLogoURL = strTabStyleLogoURL;
        objResponse.strColorCodeForIcon = strColorCodeForIcon;
        objResponse.numLMD = numLMD;
        objResponse.strSettings = JSON.serialize(objOpdocSettingList);
        objResponse.strSfmDeliverySettings = JSON.serialize(objSFMSettingList);
        objResponse.strUserInfo = JSON.serialize(new OPDOC_DeliveryImpl().getUserInfo());
        objResponse.isLaunchDesignerEnabled = isLaunchDesignerEnabled;
        return objResponse;
    }

    public OPDOC_Delivery.OPDOC_QualifyResponse qualify(OPDOC_Delivery.OPDOC_Request request){
        OPDOC_Delivery.OPDOC_QualifyResponse objResponse = new OPDOC_Delivery.OPDOC_QualifyResponse();
        objResponse.isQualified = true;
        objResponse.errorMessage = '';
        String ProcessID = request.processId;
        String RecordID = request.recordId;

        //process node records      
        List<SVMXC__ServiceMax_Processes__c> lstProcNodeRecs = [SELECT Id, SVMXC__Submodule__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Doc_Template_Details__c, SVMXC__Submodule__r.SVMXC__Parent_Error_Msg__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process__r.SVMXC__ProcessID__c =: ProcessID AND RecordType.Name = 'PROCESS NODE OBJECTS' AND SVMXC__Type__c = 'TARGET'];
        
        if(lstProcNodeRecs.size() == 0){
            objResponse.isQualified = false;
            objResponse.errorMessage = System.Label.SFM004_TAG005;
            return objResponse;
        }
                                                            
        String docTempDetailId = lstProcNodeRecs[0].SVMXC__Doc_Template_Details__c;
        // Doc Template Detail Recs
        List<SVMXC__Doc_Template_Details__c> lstDocTemplateDetials = [SELECT Id, SVMXC__Object_Name__c, SVMXC__Header_Reference_Field__c FROM SVMXC__Doc_Template_Details__c WHERE Id =: docTempDetailId AND SVMXC__Type__c = 'Header_Object'];
        
        if(lstDocTemplateDetials.size() == 0){
            objResponse.isQualified = false;
            objResponse.errorMessage = System.Label.SFM004_TAG005;
            return objResponse;
        }

        String criteria = lstProcNodeRecs[0].SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c;
        if(criteria != null && criteria.length() > 0){
            String query = 'Select Id from ' + lstDocTemplateDetials[0].SVMXC__Object_Name__c + ' where ' + lstDocTemplateDetials[0].SVMXC__Header_Reference_Field__c + '= \'' + RecordID + '\' and (' + criteria + ')';
            List<SObject> lstRecs = database.query(query);
            if(lstRecs == null || lstRecs.size() == 0){
                objResponse.isQualified = false;
                objResponse.errorMessage = lstProcNodeRecs[0].SVMXC__Submodule__r.SVMXC__Parent_Error_Msg__c;
                return objResponse;
            }               
        }

        return objResponse;
    }
    
    //-----End---------New Methods--------//Added for the story BAC-5383
    
    //Added for the story BAC-5393
    public Map<String, String> getDisplayTags(){
        Map<String, String> mapDisplayTags = new Map<String, String>();
        mapDisplayTags.put('SFM004_TAG006', System.Label.SFM004_TAG006);
        mapDisplayTags.put('SFM004_TAG007', System.Label.SFM004_TAG007);
        mapDisplayTags.put('SFM004_TAG008', System.Label.SFM004_TAG008);
        mapDisplayTags.put('SFM004_TAG009', System.Label.SFM004_TAG009);
        mapDisplayTags.put('SFM004_TAG010', System.Label.SFM004_TAG010);
        mapDisplayTags.put('SFM004_TAG011', System.Label.SFM004_TAG011);
        mapDisplayTags.put('SFM004_TAG012', System.Label.SFM004_TAG012);
        mapDisplayTags.put('SFM004_TAG013', System.Label.SFM004_TAG013);
        mapDisplayTags.put('SFM004_TAG014', System.Label.SFM004_TAG014);
        mapDisplayTags.put('SFM004_TAG015', System.Label.SFM004_TAG015);
        return mapDisplayTags;
    }

    //constructor code goes here
    public OPDOC_Delivery(){}

    //------Start----New JSR methods added here---------//Added for the story BAC-5383
    @RemoteAction
    public static Object JsrGetConfigInfo(String requestStr){
        SVMXC.OPDOC_Delivery.OPDOC_Request request = (SVMXC.OPDOC_Delivery.OPDOC_Request)JSON.deserialize(requestStr, SVMXC.OPDOC_Delivery.OPDOC_Request.class);
        return JSON.serialize(new SVMXC.OPDOC_Delivery().processConfigInfo(request));
    }
    //------End----New JSR methods added here---------//Added for the story BAC-5383
   
    //Added for the story BAC-5393
    @RemoteAction
    public static Object JsrGetDisplayTags(String requestStr){
        return JSON.serialize(new SVMXC.OPDOC_Delivery().getDisplayTags());
    }
    
    @RemoteAction
    global static Object JsrGetTemplate(String requestStr){     
      OPDOC_DeliveryImpl.GetTemplateRequest gtr = 
          (OPDOC_DeliveryImpl.GetTemplateRequest)
          JSON.deserialize(requestStr, OPDOC_DeliveryImpl.GetTemplateRequest.class);
      OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
      return JSON.serialize(objDocDelImpl.getTemplate(gtr));      
    }
    
    @RemoteAction
    global static Object JsrSubmitDocument(String requestStr) { 
      OPDOC_DeliveryImpl.SubmitDocumentRequest gtr = 
          (OPDOC_DeliveryImpl.SubmitDocumentRequest)
          JSON.deserialize(requestStr, OPDOC_DeliveryImpl.SubmitDocumentRequest.class);
      OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
      //Added for Salesforce file global setting --BAC-2197
      Boolean salesforceFileGlobalValue = COMM_FileHandlerUtilities.checkFileSetting();
      System.debug('salesforceFileGlobalValue '+salesforceFileGlobalValue);
      //Added for BAC-2197
        if(salesforceFileGlobalValue){
            return JSON.serialize(objDocDelImpl.submitDocumentforFile(gtr));
        }else{
            return JSON.serialize(objDocDelImpl.submitDocument(gtr));   
        }
        
    }
    
    @RemoteAction
    global static Object JsrCreatePDF(String requestStr) { 
      OPDOC_DeliveryImpl.CreatePDFRequest gpr = 
          (OPDOC_DeliveryImpl.CreatePDFRequest)
          JSON.deserialize(requestStr, OPDOC_DeliveryImpl.CreatePDFRequest.class);
      OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
      //Added for BAC-2197
      Boolean salesforceFileGlobalValue = COMM_FileHandlerUtilities.checkFileSetting();
      System.debug('salesforceFileGlobalValue '+salesforceFileGlobalValue);
        if(salesforceFileGlobalValue){
            return JSON.serialize(objDocDelImpl.createPDFForFile(gpr));
        }else{
            return JSON.serialize(objDocDelImpl.createPDF(gpr));
        }
    }
    
    @RemoteAction
    global static Object JsrSubmitQuery(String requestStr) { 
      OPDOC_DeliveryImpl.SubmitQueryRequest sqr = 
          (OPDOC_DeliveryImpl.SubmitQueryRequest)
          JSON.deserialize(requestStr, OPDOC_DeliveryImpl.SubmitQueryRequest.class);
      OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
      return JSON.serialize(objDocDelImpl.submitQuery(sqr));      
        
    }
    
    @RemoteAction
    global static Object JsrGetUserInfo(String requestStr) { 
      OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
      return JSON.serialize(objDocDelImpl.getUserInfo());
        
    }
    
    @RemoteAction
    global static Object JsrGetDocumentData(String requestStr) { 
      OPDOC_DeliveryImpl.GetDocumentDataRequest ddr = 
          (OPDOC_DeliveryImpl.GetDocumentDataRequest)
          JSON.deserialize(requestStr, OPDOC_DeliveryImpl.GetDocumentDataRequest.class);
      OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
      return JSON.serialize(objDocDelImpl.getDocumentData(ddr));
      
                    
    }
    
    @RemoteAction
    global static Object JsrGetDocumentMetadata(String requestStr) { 
      OPDOC_DeliveryImpl.GetDocumentMetadataRequest dmr = 
          (OPDOC_DeliveryImpl.GetDocumentMetadataRequest)
          JSON.deserialize(requestStr, OPDOC_DeliveryImpl.GetDocumentMetadataRequest.class);
      OPDOC_DeliveryImpl objDocDelImpl = new OPDOC_DeliveryImpl();     
      return JSON.serialize(objDocDelImpl.getDocumentMetadata(dmr));
                    
    }
    
    @RemoteAction
    global static Object JsrDescribeObject(String requestStr){
        
        SVMXC.OPDOC_DeliveryImpl.ObjectDescriptionRequest odr = (SVMXC.OPDOC_DeliveryImpl.ObjectDescriptionRequest)
                    JSON.deserialize(requestStr, SVMXC.OPDOC_DeliveryImpl.ObjectDescriptionRequest.class);          
        return JSON.serialize(new SVMXC.OPDOC_DeliveryImpl().getObjectDescription(odr));
    }
    
    @RemoteAction
    global static Object JsrTargetUpdates(String requestStr){       
        SVMXC.OPDOC_DeliveryImpl.TargetUpdatesRequest tur = (SVMXC.OPDOC_DeliveryImpl.TargetUpdatesRequest)
                    JSON.deserialize(requestStr, SVMXC.OPDOC_DeliveryImpl.TargetUpdatesRequest.class);          
        return JSON.serialize(new SVMXC.OPDOC_DeliveryImpl().doTargetUpdates(tur));
    }
   
}