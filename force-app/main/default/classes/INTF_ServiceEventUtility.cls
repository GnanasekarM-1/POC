public with sharing class INTF_ServiceEventUtility
{
    public static string strDevice;
    public static string strDeviceNameInFilter;
    public static APFT_Schema.Filters filterstoExclude;
    
    public INTF_WebServicesDef.INTF_SFMResponse eventController(INTF_WebServicesDef.INTF_SFMRequest inputRequest)//String eventType, String eventName)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('eventController');
        Sync_Utility clsUtility = new Sync_Utility();
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        String eventType = inputRequest.eventType;
        String eventName = inputRequest.eventName;
        INTF_GetServiceFlowAccess.client = true;
        Boolean isTargetedSyncEnabled = false;
        Map<String, String> mapErrorMessage = new Map<String, String>();
        try
        {
            if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                {
                    if(clientInform.clientType != null)
                    {
                        strDevice = clientInform.clientType;
                        break;
                    }
                }
            }
            if(strDevice != null && strDevice.contains('iPhone'))
                strDevice = 'iPhone';
                
            if(eventType == 'INITIAL_SYNC' && eventName == 'SFM_METADATA')
            {
                INTF_ServiceEventUtility.filterstoExclude = getApplicationFilters();
                
                Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
                allowedProcess = clsUtility.getSFMTransactions(NULL);
                if(INTF_GetServiceFlowAccess.strLastRecName != null && INTF_GetServiceFlowAccess.strLastRecName.length() > 0)
                    response.values.add(INTF_GetServiceFlowAccess.strLastRecName);  
                response.valueMap  = clsUtility.getServiceFlowObjData(allowedProcess);
            }
            else if(eventType == 'SYNC' && eventName == 'SFM_METADATA')
            {
                INTF_ServiceEventUtility.filterstoExclude = getApplicationFilters();
                
                Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
                Integer index;
                if(inputRequest.value != null)
                {
                    index = inputRequest.value.indexOf('|');
                    if(index != -1)
                    {
                        INTF_GetServiceFlowAccess.strProcessName = inputRequest.value.substring(0,index);//store the Process name of last record.
                        INTF_GetServiceFlowAccess.strLastRecName = inputRequest.value.substring(index+1,inputRequest.value.length());//store the lastrecord name.
                        allowedProcess = clsUtility.getSFMTransactions(NULL);
                    }
                    else
                    {
                        INTF_GetServiceFlowAccess.strProcessName = inputRequest.value;
                        INTF_GetServiceFlowAccess.strLastRecName = null;
                        allowedProcess = clsUtility.getSFMTransactions(NULL);
                    }
                    response.values.add(INTF_GetServiceFlowAccess.strLastRecName);
                    response.valueMap  = clsUtility.getServiceFlowObjData(allowedProcess);  
                }
            }
            else if(eventType == 'SYNC' && eventName == 'SFM_OBJECT_DEFINITIONS')
            {
                Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
                if(inputRequest.values != null && inputRequest.values.size() > 0)
                {
                    Set<String> setProcess = new Set<String>();
                    setProcess.addAll(inputRequest.values);
                    allowedProcess.putAll([Select Id, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__Page_Layout__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= 'Target Manager' AND Id IN: setProcess]);
                    if(allowedProcess != NULL && allowedProcess.size() > 0)
                    {
                        Map<String, INTF_WebServicesDef.SVMXMap> mapObjDefinitions = new Map<String, INTF_WebServicesDef.SVMXMap>();
                        mapObjDefinitions = clsUtility.getServiceFlowObjectDef(allowedProcess);
                        if(mapObjDefinitions != NULL && mapObjDefinitions.keySet() != null && mapObjDefinitions.keySet().size() > 0)
                        {
                            List<INTF_WebServicesDef.SVMXMap> lstObjDef = new List<INTF_WebServicesDef.SVMXMap>();
                            for(String objName: mapObjDefinitions.keySet())
                            {
                                if(mapObjDefinitions.get(objName) != null)
                                    lstObjDef.add(mapObjDefinitions.get(objName));
                                else
                                    response.values.add(objName);
                            }
                            response.valueMap = lstObjDef;
                        }
                    }
                }
            }
            else if(eventType == 'SYNC' && eventName == 'SFM_PICKLIST_DEFINITIONS')
            {
                response = clsUtility.getPicklistDefinitions(inputRequest.values);
            }
            else if(eventType == 'SYNC' && eventName == 'SFM_BATCH_OBJECT_DEFINITIONS')
            {
                if(inputRequest.values != NULL && inputRequest.values.size() > 0)
                {
                    Set<String> setObjectNames = new Set<String>();
                    setObjectNames.addAll(inputRequest.values);
                    List<INTF_WebServicesDef.SVMXMap> lstObjDef = new List<INTF_WebServicesDef.SVMXMap>();
                    Map<String, INTF_WebServicesDef.SVMXMap> mapObjDef = new Map<String, INTF_WebServicesDef.SVMXMap>();
                    mapObjDef = clsUtility.getObjectDefinition(setObjectNames);
                    if(mapObjDef != null && mapObjDef.keySet() != null && mapObjDef.keySet().size() > 0)
                    {
                        for(String objName: mapObjDef.keySet())
                        {
                            if(mapObjDef.get(objName) != null)
                                lstObjDef.add(mapObjDef.get(objName));
                            else
                                response.values.add(objName);
                        }
                        response.valueMap = lstObjDef;
                    }
                }
            }
            else if(eventType == 'SYNC' && eventName == 'OBJECT_PERMISSIONS')
            {
                INTF_MobileConfigUtility objMobileConfigUtil = new INTF_MobileConfigUtility();
                Map<Id, SVMXC__ServiceMax_Processes__c> processAccess = clsUtility.getSFMTransactions(null);
                Sync_Utility.objectAccess objectPermissions = clsUtility.getSFMTxObjects(processAccess);
                response.valueMap = objMobileConfigUtil.getObjectPermissions(objectPermissions.mapObjectProcess,objectPermissions.mapProcessPurpose);
            }
            else if(eventType == 'SYNC' && eventName == 'SFW_METADATA')
            {
                INTF_ServiceEventUtility.filterstoExclude = getApplicationFilters();
                
                String strIPadVersion, clientAppVersion;
                if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
                {
                    for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                    {
                        if(clientInform.clientType == 'iPad_Version' && clientInform.clientInfo.size() > 0)
                            strIPadVersion = clientInform.clientInfo[0];
                        if(clientAppVersion == null)
                        {
                            for(string clntInformation : clientInform.clientInfo)
                            {
                                if(clntInformation.contains('appversion'))
                                {
                                    clientAppVersion = clntInformation.split(':')[1];
                                    break;
                                }
                            }
                        }
                    }
                    if(clientAppVersion != null && clientAppVersion.length() > 0)
                        strIPadVersion = clientAppVersion;
                }   
                Map<Id, SVMXC__ServiceMax_Processes__c> processAccess = clsUtility.getAllowedSFW(null);
                response.valueMap  = clsUtility.getServiceFlowWizards(processAccess, strIPadVersion);
            }
            else if(eventType == 'SYNC' && eventName == 'MOBILE_DEVICE_TAGS')
            {
                COMM_Utils_ManageTags objDeviceUtil = new COMM_Utils_ManageTags();
                inputRequest.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                inputRequest.valueMap.add(new INTF_WebServicesDef.SVMXMap('IPAD', 'false'));
                inputRequest.valueMap.add(new INTF_WebServicesDef.SVMXMap('EVER', 'false'));
                inputRequest.valueMap.add(new INTF_WebServicesDef.SVMXMap('SFM002', 'false'));
                inputRequest.valueMap.add(new INTF_WebServicesDef.SVMXMap('SFM004', 'false'));
                inputRequest.valueMap.add(new INTF_WebServicesDef.SVMXMap('PRODIQ001', 'false'));
                response = objDeviceUtil.getMobileConfigTags(inputRequest);
            }
            else if(eventType == 'SYNC' && eventName == 'MOBILE_DEVICE_SETTINGS')
            {
                    if(inputRequest.valueMap != NULL && inputRequest.valueMap.size() > 0){
                        for(SVMXC.INTF_WebServicesDef.SVMXMap eachVM : inputRequest.valueMap){
                            if(eachVM.Key == 'TARGETED_SYNC_ENABLED'){
                                isTargetedSyncEnabled = Boolean.valueOF(eachVM.value);
                            }
                        }
                    }
                INTF_MobileConfigUtility objMobileConfigUtil = new INTF_MobileConfigUtility();
                response = objMobileConfigUtil.getMobileConfig('', strDevice, isTargetedSyncEnabled);
            }
            else if(eventType == 'GROUP_PROFILE' && eventName == 'VALIDATE_PROFILE')
            {
                Id profileId = UserInfo.getProfileId();
                INTF_DataSync.logSOQL(intMethodCount , 'SELECT Id, SVMXC__Access_Configuration_Profile__c FROM SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Configuration Access\' AND SVMXC__Profile__c = :profileId AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c = \'Configuration Profile\' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = True' );
                List<SVMXC__ServiceMax_Config_Data__c>profileAccessLst = [SELECT Id, SVMXC__Access_Configuration_Profile__c,SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c FROM SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Configuration Access' AND SVMXC__Profile__c = :profileId AND SVMXC__Access_Configuration_Profile__r.SVMXC__RecordType_Name__c = 'Configuration Profile' AND SVMXC__Access_Configuration_Profile__r.SVMXC__Active__c = True];     //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(!profileAccessLst.isEmpty())
                {
                    String strSSLSetting = 'False';                                    
                    String strSVMXGrpProfile = profileAccessLst[0].SVMXC__Access_Configuration_Profile__c;
                    response.values.add(String.valueOf(strSVMXGrpProfile));
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('PROFILEID',Userinfo.getProfileId()));
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('ORGNAME',Userinfo.getOrganizationName()));
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('ORGID',Userinfo.getOrganizationId()));
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('PROFILENAME',profileAccessLst[0].SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c));
                                                         
                        system.debug(LoggingLevel.WARN,'Device Type = '+strDevice );
                    
                    //Device specific setting 
                    String strMobConfQuery = 'SELECT SVMXC__Internal_Value__c,SVMXC__Display_Type__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Access_Configuration_Profile__c =:strSVMXGrpProfile AND SVMXC__RecordType_Name__c=\'Mobile Configuration\' AND (SVMXC__Display_Type__c=\'Enable Performance Profiling\' OR SVMXC__Display_Type__c=\'Performance Profiling Org Type\' OR SVMXC__Display_Type__c=\'Performance Profiling Endpoint Url\') ';     
                    
                    String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(strSVMXGrpProfile, strDevice);
                    
                    if(strDevConfId != NULL && strDevConfId != ''){
                        strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                    }
                    
                    system.debug(LoggingLevel.WARN,' Query prepared for validate profile = '+strMobConfQuery);
                    List<SVMXC__ServiceMax_Config_Data__c> lstSyncProfConfig = Database.query(strMobConfQuery); 
                    
                    String strOrgType = 'Production', strEndpointUrl = '', enableSyncProfiling ='false';
                    if(lstSyncProfConfig != NULL && !lstSyncProfConfig.isEmpty()){
                            for(SVMXC__ServiceMax_Config_Data__c syncConfig: lstSyncProfConfig){
                                if(syncConfig.SVMXC__Display_Type__c == 'Enable Performance Profiling' && syncConfig.SVMXC__Internal_Value__c != NULL){
                                    enableSyncProfiling = syncConfig.SVMXC__Internal_Value__c; 
                                }else if(syncConfig.SVMXC__Display_Type__c == 'Performance Profiling Org Type' && syncConfig.SVMXC__Internal_Value__c != NULL){
                                    strOrgType = syncConfig.SVMXC__Internal_Value__c;
                                }else if(syncConfig.SVMXC__Display_Type__c == 'Performance Profiling Endpoint Url' && syncConfig.SVMXC__Internal_Value__c != NULL){
                                    strEndpointUrl = syncConfig.SVMXC__Internal_Value__c;
                                }
                            }
                    }
                    
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SYNC_PROFILING',enableSyncProfiling)); 
                    if(boolean.ValueOf(enableSyncProfiling)){  //Send orgtype and URL only if sync profiling has been enabled
                        if(strOrgType == 'Production'){
                            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SYNC_PROFILING_ORG_TYPE',strOrgType)); 
                            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SYNC_PROFILING_ENDPOINT_URL','https://empp.servicemax-api.com')); 
                        }else if(strOrgType == 'Sandbox'){
                            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SYNC_PROFILING_ORG_TYPE',strOrgType)); 
                            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SYNC_PROFILING_ENDPOINT_URL','https://emppdev.servicemax-api.com')); 
                        }else if(strOrgType == 'Custom'){
                            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SYNC_PROFILING_ORG_TYPE',strOrgType)); 
                            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SYNC_PROFILING_ENDPOINT_URL',strEndpointUrl)); 
                        }
                    }
                    
                    List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (new INTF_ConfigSync()).getsettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET023'}, strSVMXGrpProfile);
                    if(lstSettings != null && !lstSettings.isEmpty())
                        strSSLSetting = String.valueOf(lstSettings[0].SVMXC__Internal_Value__c);
                            
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('SSL_PINNING', strSSLSetting));
                    List<SVMXC__Service_Group_Members__c> listOfTechnicians = [Select Id,Name,SVMXC__Active__c,SVMXC__Inventory_Location__c,SVMXC__Latitude__c,SVMXC__Longitude__c,SVMXC__Email__c,SVMXC__Phone__c,SVMXC__Salesforce_User__c From SVMXC__Service_Group_Members__c Where SVMXC__Salesforce_User__c=:Userinfo.getUserId() and SVMXC__Active__c =true Limit 1];
                    String technicianRecord='';
                    if(listOfTechnicians !=NULL && !listOfTechnicians.isEmpty())
                    {
                        technicianRecord = String.valueOf(JSON.serialize(listOfTechnicians));
                    }
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('TECHNICIAN', technicianRecord));    
                    
                    //Check if Edit_Event and VIEW_ENCRYPTED_DATA has been enabled on the profile 
                    Boolean editEventEnabled = false, viewEncrData = false;
                    List<Profile> profileList = [SELECT Id, PermissionsEditEvent, PermissionsViewEncryptedData FROM Profile where Id =: profileId ];

                    if(profileList[0].PermissionsEditEvent){
                        response.valueMap.add(new INTF_WebServicesDef.SVMXMap('EDIT_EVENTS', String.valueof(profileList[0].PermissionsEditEvent)));
                    }else{ //If not enabled at profile level, check for permission sets.
                        List<PermissionSetAssignment> psetList = [select Id, PermissionSet.PermissionsEditEvent from PermissionSetAssignment where AssigneeId =: UserInfo.getUserID()];
                        for(PermissionSetAssignment eachPS: psetList){
                            if(eachPS.PermissionSet.PermissionsEditEvent){
                                editEventEnabled = true;
                                break;
                            }
                        }
                        response.valueMap.add(new INTF_WebServicesDef.SVMXMap('EDIT_EVENTS', String.valueof(editEventEnabled)));
                    }
                    if(profileList[0].PermissionsViewEncryptedData){
                        response.valueMap.add(new INTF_WebServicesDef.SVMXMap('VIEW_ENCRYPTED_DATA', String.valueof(profileList[0].PermissionsViewEncryptedData)));
                    }else{ //If not enabled at profile level, check for permission sets.
                        List<PermissionSetAssignment> psetList = [select Id, PermissionSet.PermissionsViewEncryptedData from PermissionSetAssignment where AssigneeId =: UserInfo.getUserID()];
                        for(PermissionSetAssignment eachPS: psetList){
                            if(eachPS.PermissionSet.PermissionsViewEncryptedData){
                                viewEncrData = true;
                                break;
                            }
                        }
                        response.valueMap.add(new INTF_WebServicesDef.SVMXMap('VIEW_ENCRYPTED_DATA', String.valueof(viewEncrData)));
                    }
                    
                    system.debug(LoggingLevel.WARN, ' Community ID is '+Network.getNetworkId());
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('COMMUNITY_ID', String.valueof(Network.getNetworkId())));  //Include community ID

                }
                else
                {
                      mapErrorMessage.put('Profile', system.label.IPAD015_TAG011);
                      throw new SmaxException();
                }   
            }
            else if(eventType == 'SYNC' && eventName == 'SFM_PAGEDATA' && inputRequest.values != NULL)
            {
                response.pageUI = new List<SVMXC.INTF_WebServicesDef.INTF_Response_PageUI>();
                response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                SVMXC.INTF_GetPageLayout pagelayout = new SVMXC.INTF_GetPageLayout();
                set<String> processedPageIds = new set<String>();
                List<String> codeSnippetIdList = new List<String>();
                for(String pageIds: inputRequest.values)
                {
                    try
                    {
                        if(processedPageIds == NULL || !processedPageIds.contains(pageIds))
                        {
                            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> StringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                            StringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('PAGEID', pageIds));
                            INTF_WebServicesDef.INTF_Request_PageUI PmaxReqPageUI = new INTF_WebServicesDef.INTF_Request_PageUI();
                            PmaxReqPageUI.request.StringMap = StringMap;
                            INTF_WebServicesDef.INTF_Response_PageUI pageUI = pagelayout.INTF_GetPageLayout(PmaxReqPageUI);
                            if(pageUI.response != NULL && pageUI.response.success != NULL && pageUI.response.success == true)
                            {
                                response.pageUI.add(pageUI);
                                processedPageIds.add(pageIds);
                                
                                if(pageUI.response.valueMap.size() > 0){
                                    for(INTF_WebServicesDef.SVMXMap eachSnippet: pageUI.response.valueMap){
                                        if(eachSnippet.Key == 'CODE_SNIPPET_IDS' && eachSnippet.values.size() > 0){
                                            codeSnippetIdList.addAll(eachSnippet.values);
                                        }
                                    }
                                }
                            }
                            else
                                break;
                        }
                    }
                    catch(exception ex)
                    {
                        break;
                    }
                }
                List<String> unprocessedPageIds = new List<String>();
                for(String pageIds: inputRequest.values)
                {
                    if(!processedPageIds.contains(pageIds))
                        unprocessedPageIds.add(pageIds);
                }
                response.values = unprocessedPageIds;
                if(codeSnippetIdList.size() > 0){
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('CODE_SNIPPET_IDS','',codeSnippetIdList));
                } 
            }
            else if(eventType == 'SYNC' && eventName == 'SFM_SEARCH')
            {
                SFM_SearchUtils searchUtilObj = new SFM_SearchUtils();
                INTF_WebServicesDef.INTF_Response intfResp =  searchUtilObj.INTF_getSearchInfo(inputRequest);
                
                Map<String, String> mapObjectMappingConfigHeader1 = new Map<String, String>();
                Map<String, String> mapObjectMappingConfigHeader2 = new Map<String, String>();
                Map<String, String> mapObjectMapProcessHeader = new Map<String, String>();
                Map<String, String> mapProcessHeader = new Map<String, String>();
                
                mapObjectMappingConfigHeader1.put('Id', 'Id');
                mapObjectMappingConfigHeader1.put('SVMXC__Search_Object_Field_Type__c', 'SVMXC__Search_Object_Field_Type__c');
                //mapObjectMappingConfigHeader1.put('RecordTypeId', 'RecordTypeId');
                mapObjectMappingConfigHeader1.put('SVMXC__Expression_Rule__c', 'SVMXC__Expression_Rule__c');
                mapObjectMappingConfigHeader1.put('SVMXC__Object_Name__c', 'SVMXC__Object_Name__c');
                mapObjectMappingConfigHeader1.put('SVMXC__Object_Name2__c', 'SVMXC__Object_Name2__c');
                mapObjectMappingConfigHeader1.put('SVMXC__Field_Name__c', 'SVMXC__Field_Name__c');
                mapObjectMappingConfigHeader1.put('SVMXC__Display_Type__c', 'SVMXC__Display_Type__c');
                mapObjectMappingConfigHeader1.put('SVMXC__Lookup_Field_API_Name__c', 'SVMXC__Lookup_Field_API_Name__c');
                mapObjectMappingConfigHeader1.put('SVMXC__Field_Relationship_Name__c', 'SVMXC__Field_Relationship_Name__c');
                mapObjectMappingConfigHeader1.put('SVMXC__Sort_Order__c', 'SVMXC__Sort_Order__c');
                
                mapObjectMappingConfigHeader2.putAll(mapObjectMappingConfigHeader1);
                mapObjectMappingConfigHeader2.put('SVMXC__Display_Type__c', 'SVMXC__Display_Type__c');
                mapObjectMappingConfigHeader2.put('SVMXC__Operator__c', 'SVMXC__Operator__c');
                mapObjectMappingConfigHeader2.put('SVMXC__Operand__c', 'SVMXC__Operand__c');
                
                mapObjectMapProcessHeader.put('Id', 'Id');
                mapObjectMapProcessHeader.put('SVMXC__ProcessID__c', 'SVMXC__ProcessID__c');
                mapObjectMapProcessHeader.put('SVMXC__Target_Object_Name__c', 'SVMXC__Target_Object_Name__c');
                mapObjectMapProcessHeader.put('SVMXC__Module__c', 'SVMXC__Module__c');
                mapObjectMapProcessHeader.put('SVMXC__Advance_Expression__c','SVMXC__Parent_Object_Criteria__c');
                mapObjectMapProcessHeader.put('SVMXC__Parent_Object_Criteria__c','SVMXC__Advance_Expression__c');
                mapObjectMapProcessHeader.put('SVMXC__Name__c','SVMXC__Name__c');
                
                mapProcessHeader.put('Id', 'Id');
                mapProcessHeader.put('Name', 'Name');
                mapProcessHeader.put('SVMXC__Rule_Type__c', 'SVMXC__Rule_Type__c');
                mapProcessHeader.put('SVMXC__ProcessID__c', 'SVMXC__ProcessID__c');
                mapProcessHeader.put('SVMXC__Name__c', 'SVMXC__Name__c');
                mapProcessHeader.put('SVMXC__Description__c', 'SVMXC__Description__c');
                mapProcessHeader.put('SVMXC__Number_of_Lookup_Records__c', 'SVMXC__Number_of_Lookup_Records__c');
                mapProcessHeader.put('SVMXC__IsStandard__c', 'SVMXC__IsStandard__c');
                mapProcessHeader.put('SVMXC__Active__c', 'SVMXC__Active__c');
                mapProcessHeader.put('SVMXC__IsDefault__c', 'SVMXC__IsDefault__c');
                
                set<Id> setIds = new set<Id>();
                for(INTF_WebServicesDef.INTF_SearchInfo searchInfo : intfResp.lstSearchInfo)
                {
                    for(INTF_WebServicesDef.INTF_SearchInfoDetail searchInfoDetail : searchInfo.searchDetails)
                    {
                        if(searchInfoDetail.objectDetails.Id != null)
                        {
                            setIds.add(searchInfoDetail.objectDetails.Id);
                        }
                    }
                }
                List<SVMXC__ServiceMax_Config_Data__c> lstDisplayInfoRecords = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstDisplayInfoRecords = [Select SVMXC__Sequence__c, SVMXC__Sort_Order__c, SVMXC__Object_Name__c, SVMXC__Search_Object_Field_Type__c, SVMXC__Expression_Rule__c, SVMXC__Object_Name2__c,  SVMXC__Field_Name__c, SVMXC__Display_Type__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Lookup_Field_API_Name__c, SVMXC__Field_Relationship_Name__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c IN: setIds and Recordtype.Name='Expressions'  AND (((SVMXC__Search_Object_Field_Type__c = 'Search' OR SVMXC__Search_Object_Field_Type__c = 'OrderBy') AND SVMXC__Expression_Type__c = 'SRCH_Object_Fields') OR (SVMXC__Search_Object_Field_Type__c = '' AND SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria')) ORDER BY SVMXC__Sequence__c];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<INTF_WebServicesDef.SVMXMap> lstTempObj1 = new List<INTF_WebServicesDef.SVMXMap>();
                for(INTF_WebServicesDef.INTF_SearchInfo searchInfo : intfResp.lstSearchInfo)
                {
                    INTF_WebServicesDef.SVMXMap eachSearchInfo = new INTF_WebServicesDef.SVMXMap();
                    INTF_WebServicesDef.SVMXMap tempObj = new INTF_WebServicesDef.SVMXMap();
                    List<INTF_WebServicesDef.SVMXMap> lstTempObj = new List<INTF_WebServicesDef.SVMXMap>();
                    INTF_WebServicesDef.SVMXMap tempObj1 = new INTF_WebServicesDef.SVMXMap();
                    List<INTF_WebServicesDef.SVMXMap> lstSrchInfo = new List<INTF_WebServicesDef.SVMXMap>();
                    
                    List<INTF_WebServicesDef.SVMXMap> lstTemp2 = new List<INTF_WebServicesDef.SVMXMap>();
                    List<sObject> lstProcess = new List<sObject>();
                    for(INTF_WebServicesDef.INTF_SearchInfoDetail searchInfoDetail : searchInfo.searchDetails)
                    {
                        INTF_WebServicesDef.SVMXMap eachSearchDetails = new INTF_WebServicesDef.SVMXMap();
                        List<INTF_WebServicesDef.SVMXMap> eachObjectFieldDetails = new List<INTF_WebServicesDef.SVMXMap>();
                        INTF_WebServicesDef.SVMXMap objectDetails = new INTF_WebServicesDef.SVMXMap();
                        INTF_WebServicesDef.SVMXMap fieldDetails = new INTF_WebServicesDef.SVMXMap();
                        List<sObject> lstsrchfield = new List<sObject>();
                        List<sObject> lstSrchProcess = new List<sObject>();
                        List<INTF_WebServicesDef.SVMXMap> lstFields = new List<INTF_WebServicesDef.SVMXMap>();
                        lstFields = clsUtility.getKeyValueForData(mapObjectMappingConfigHeader1, searchInfoDetail.fields);
                        for(SVMXC__ServiceMax_Config_Data__c sObjectCriteria  : lstDisplayInfoRecords)
                        {
                            if(sObjectCriteria.SVMXC__Expression_Rule__c == searchInfoDetail.objectDetails.Id)
                            {
                                lstsrchfield.add(sObjectCriteria);
                            }
                        }   
                        lstFields.addAll(clsUtility.getKeyValueForData(mapObjectMappingConfigHeader2, lstsrchfield));
                        lstSrchProcess.add(searchInfoDetail.objectDetails);
                        fieldDetails.key = 'SVMXC__ServiceMax_Config_Data__c';
                        fieldDetails.valueMap = lstFields;
                        objectDetails.key = 'SVMXC__ServiceMax_Processes__c';
                        objectDetails.valueMap = clsUtility.getKeyValueForData(mapObjectMapProcessHeader, lstSrchProcess);
                        eachObjectFieldDetails.add(objectDetails);
                        eachObjectFieldDetails.add(fieldDetails);
                        eachSearchDetails.key = 'SEARCHDETAIL';
                        eachSearchDetails.valueMap = eachObjectFieldDetails;
                        lstTempObj.add(eachSearchDetails);
                    }
                    lstProcess.add(searchInfo.searchDef);
                    eachSearchInfo.key = 'SVMXC__ServiceMax_Processes__c';
                    eachSearchInfo.valueMap = lstTempObj;
                    lstTempObj1.addAll(clsUtility.getKeyValueForData(mapProcessHeader, lstProcess));
                    lstTempObj1.add(eachSearchInfo);
                }
                response.valueMap = lstTempObj1;
            }
            else if(eventType == 'SYNC' && eventName == 'PRICE_CALC_OBJECTS')
            {
                Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
                Set<String> setAccessibleObjs = new Set<String>();
                allObjs = Schema.getGlobalDescribe();
                for(String objName : allObjs.keySet())
                {
                    try
                    {
                        if(allObjs.get(objName).getDescribe().isAccessible())
                            setAccessibleObjs.add(allObjs.get(objName).getDescribe().getName());
                    }
                    catch(Exception ex)
                    {
                        system.debug(LoggingLevel.WARN, 'Exception for Object Name = ' + objName + ': ' + ex.getMessage());
                    }
                }
                Set<String> setObjects = new Set<String>{'SVMXC__Code_Snippet_Manifest__c','SVMXC__Entitlement_History__c', 'SVMXC__Warranty__c', 'SVMXC__Service_Contract__c', 'SVMXC__Pricing_Rule__c', 'SVMXC__Parts_Pricing__c', 'SVMXC__Parts_Discount__c', 'SVMXC__Labor_Pricing__c', 'SVMXC__Expense_Pricing__c', 'SVMXC__Travel_Policy__c', 'SVMXC__Mileage_Tiers__c', 'SVMXC__Zone_Pricing__c', 'SVMXC__Service_Contract_Services__c', 'Pricebook2', 'SVMXC__Service_Pricebook__c', 'PricebookEntry', 'SVMXC__Service_Pricebook_Entry__c', 'SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c', 'SVMXC__Code_Snippet__c', 'SVMXC__Custom_Coverage__c'};
                INTF_WebServicesDef.SVMXMap objReqObjs = new INTF_WebServicesDef.SVMXMap();
                objReqObjs.key = 'Required_Objects';
                objReqObjs.values.addAll(setObjects);
                if(setAccessibleObjs.containsAll(setObjects))
                {
                    if(inputRequest.values != null && inputRequest.values.size() > 0)
                    {
                        setObjects.clear();
                        setObjects.addAll(inputRequest.values);
                    }   
                    system.debug(LoggingLevel.WARN,'=='+setObjects);
                    
                
                    List<INTF_WebServicesDef.SVMXMap> lstObjDef = new List<INTF_WebServicesDef.SVMXMap>();
                    Map<String, INTF_WebServicesDef.SVMXMap> mapObjDef = new Map<String, INTF_WebServicesDef.SVMXMap>();
                    mapObjDef = clsUtility.getObjectDefinition(setObjects);
                    if(mapObjDef != null && mapObjDef.keySet() != null && mapObjDef.keySet().size() > 0)
                    {
                        for(String objName: mapObjDef.keySet())
                        {
                            if(mapObjDef.get(objName) != null)
                                lstObjDef.add(mapObjDef.get(objName));//send the defined objects and their definition to the client
                            else
                                response.values.add(objName);//send the undefined objects back to client
                        }
                        response.valueMap.addAll(lstObjDef);
                    }
                }
                response.valueMap.add(objReqObjs);
            }
            else if(eventType == 'SYNC' && eventName == 'PRICE_CALC_CODE_SNIPPET')
            {
                String CodeSnippetType = NULL;
                Set<String> setCodeSnippetIds = new Set<String>();
                Set<String> setCodeSnippetType = new Set<String>();
                Set<Id> setSnippetIds = new Set<Id>();
                
                if(inputRequest.values != NULL && inputRequest.values.size() > 0)
                    setCodeSnippetIds.addAll(inputRequest.values);
                
                if(setCodeSnippetIds.contains(NULL))
                    setCodeSnippetIds.remove(NULL);
                
                if(inputRequest.valueMap != NULL && inputRequest.valueMap.size() > 0)
                {
                    for(SVMXC.INTF_WebServicesDef.SVMXMap objSVMXMap : inputRequest.valueMap)
                    {
                        if(objSVMXMap.key == 'TYPE')
                        {
                            CodeSnippetType = objSVMXMap.value;
                            setCodeSnippetType.add(objSVMXMap.value);
                            //break;
                        }
                    }
                }   
                INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id, Name, SVMXC__Code_Snippet__c FROM SVMXC__SFM_Event__c WHERE SVMXC__Page_Layout_Detail__c IN (SELECT Id FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Detail_Type__c = \'Button\') AND SVMXC__Event_Call_Type__c = \'JAVASCRIPT\'');
                for(SVMXC__SFM_Event__c objSFMEvent : [SELECT Id, Name, SVMXC__Code_Snippet__c FROM SVMXC__SFM_Event__c WHERE SVMXC__Page_Layout_Detail__c IN (SELECT Id FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Detail_Type__c = 'Button') AND SVMXC__Event_Call_Type__c = 'JAVASCRIPT'])
                {
                    setSnippetIds.add(objSFMEvent.SVMXC__Code_Snippet__c);
                }
                INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id, Name, SVMXC__Code_Snippet__c, SVMXC__Referenced_Code_Snippet__c FROM SVMXC__Code_Snippet_Manifest__c WHERE (SVMXC__Code_Snippet__c in :setSnippetIds');
                for(SVMXC__Code_Snippet_Manifest__c objSnippetMnfst : [SELECT Id, Name, SVMXC__Code_Snippet__c, SVMXC__Referenced_Code_Snippet__c FROM SVMXC__Code_Snippet_Manifest__c WHERE (SVMXC__Code_Snippet__c in :setSnippetIds)])
                {
                    INTF_WebServicesDef.SVMXMap objMap = new INTF_WebServicesDef.SVMXMap();
                    objMap.value = Json.serialize(objSnippetMnfst);
                    response.valueMap.add(objMap);
                    if(!setSnippetIds.contains(objSnippetMnfst.SVMXC__Referenced_Code_Snippet__c))
                        setSnippetIds.add(objSnippetMnfst.SVMXC__Referenced_Code_Snippet__c);
                }
                system.debug(LoggingLevel.WARN, 'setSnippetIds = ' + setSnippetIds.size() + ';setCodeSnippetType = ' + setCodeSnippetType);
                //Query the Code Snippet records and send code snippet data as trigger code to iPad client
                if(CodeSnippetType != NULL && CodeSnippetType.length() > 0)
                {
                    INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id, Name, SVMXC__Data__c, SVMXC__SnippetId__c, SVMXC__Name__c, SVMXC__Type__c FROM SVMXC__Code_Snippet__c WHERE (SVMXC__SnippetId__c IN: setCodeSnippetIds AND (SVMXC__Type__c =: CodeSnippetType OR SVMXC__Type__c IN: setCodeSnippetType)) OR (Id in :setSnippetIds)');
                    for(SVMXC__Code_Snippet__c objSnippet : [SELECT Id, Name, SVMXC__Data__c, SVMXC__SnippetId__c, SVMXC__Name__c, SVMXC__Type__c FROM SVMXC__Code_Snippet__c WHERE (SVMXC__SnippetId__c IN: setCodeSnippetIds AND (SVMXC__Type__c =: CodeSnippetType OR SVMXC__Type__c IN: setCodeSnippetType)) OR (Id in :setSnippetIds)])
                    {
                        INTF_WebServicesDef.SVMXMap objMap = new INTF_WebServicesDef.SVMXMap();
                        objMap.value = Json.serialize(objSnippet);
                        response.valueMap.add(objMap);
                    }
                }
            }
            else if(eventType == 'SYNC' && eventName == 'CODE_SNIPPET')
            {
                response.success = true;
                //Get the Code Snippet Ids and Type (SQL)
                String CodeSnippetType = NULL;
                Set<String> setCodeSnippetIds = new Set<String>();
                
                if(inputRequest.values != NULL && inputRequest.values.size() > 0)
                    setCodeSnippetIds.addAll(inputRequest.values);
                
                if(setCodeSnippetIds.contains(NULL))
                    setCodeSnippetIds.remove(NULL);
                
                if(inputRequest.valueMap != NULL && inputRequest.valueMap.size() > 0)
                {
                    for(SVMXC.INTF_WebServicesDef.SVMXMap objSVMXMap : inputRequest.valueMap)
                    {
                        if(objSVMXMap.key == 'TYPE')
                        {
                            CodeSnippetType = objSVMXMap.value;
                            break;
                        }
                    }
                }
                //Query the Code Snippet records and send code snippet data as trigger code to iPad client
                if(CodeSnippetType != NULL && CodeSnippetType.length() > 0 && setCodeSnippetIds != NULL && setCodeSnippetIds.size() > 0)
                {
                    List<SVMXC__Code_Snippet__c> lstCodeSnippet = new List<SVMXC__Code_Snippet__c>();
                    lstCodeSnippet = [SELECT Id, SVMXC__SnippetId__c, SVMXC__Data__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Name__c, SVMXC__Type__c, SVMXC__SM_Snippet_Version__c FROM SVMXC__Code_Snippet__c WHERE ( SVMXC__SnippetId__c IN: setCodeSnippetIds OR Id IN: setCodeSnippetIds ) AND SVMXC__Type__c =: CodeSnippetType AND SVMXC__SM_Snippet_Version__c != ''];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    if(lstCodeSnippet != NULL && lstCodeSnippet.size() > 0)
                    {
                        for(SVMXC__Code_Snippet__c objSnippet : lstCodeSnippet)
                            response.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap(String.valueOf(objSnippet.Id), JSON.serialize(objSnippet)));
                    }
                    
                }
            }
            else if(eventType == 'SYNC' && eventName == 'SVMX_LIBRARY')
            {
                response.success = true;
                string clientAppVersion;
                SVMX_Constants svmx_Cons = new SVMX_Constants();
                set<string> set_CodeSnippetIds = new set<string>();
                set<string> set_StaticResourceNames = new set<string>();
                List<StaticResource> lstSR = new List<StaticResource>();
                response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                List<INTF_WebServicesDef.SVMXMap> lstResponse = new List<INTF_WebServicesDef.SVMXMap>();
                
                for(INTF_WebServicesDef.SVMXClient clnt: inputRequest.clientInfo)
                {
                    for(string clntInformation : clnt.clientInfo)
                    {
                        if(clntInformation.contains('appversion'))
                        {
                            clientAppVersion = clntInformation.split(':')[1];
                            break;
                        }
                    }
                    if(clientAppVersion != null)
                        break;
                }
                
                if(clientAppVersion != null && isVersionCorrect(clientAppVersion, '12') == true)
                {
                    svmx_Cons.outputDoc_Lib(set_StaticResourceNames);
                    svmx_Cons.bizRule_Lib(set_StaticResourceNames);
                }
                
                //svmx_Cons.getProductIQResources(set_StaticResourceNames);
                
                List<INTF_WebServicesDef.SVMXMap> lstResource_Res = new List<INTF_WebServicesDef.SVMXMap>();
                if(set_StaticResourceNames != null && set_StaticResourceNames.size() > 0)
                {
                    lstSR = [select id, Name from StaticResource where Name IN: set_StaticResourceNames];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                     if(lstSR != null && lstSR.size() > 0)
                    {
                        INTF_WebServicesDef.SVMXMap docResource = new INTF_WebServicesDef.SVMXMap();
                        docResource.key = 'STATIC_RESOURCE';
                        docResource.valueMap = clsUtility.getKeyValueForData(svmx_Cons.getStaticResourcesDef(), lstSR);
                        lstResource_Res.add(docResource);  
                    }
                }
                response.valueMap.addAll(lstResource_Res);
                
                set<string> setDocNames = new set<string>();
                List<SVMXC__Doc_Template__c> lstDocTemplates = new List<SVMXC__Doc_Template__c>();
                
                if(clientAppVersion != null && isVersionCorrect(clientAppVersion, '12') == true)
                    lstDocTemplates = [SELECT SVMXC__Media_Resources__c FROM SVMXC__Doc_Template__c];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                for(SVMXC__Doc_Template__c docTemplate : lstDocTemplates)
                    if(docTemplate.SVMXC__Media_Resources__c != null)
                        setDocNames.addAll(docTemplate.SVMXC__Media_Resources__c.split(','));
                
                List<Document> lstDocs = new List<Document>();
                if(setDocNames != null && setDocNames.size() > 0)
                    lstDocs = [select id, Name, DeveloperName from Document where DeveloperName IN: setDocNames AND Keywords = 'SFM_OUTPUT_DOCUMENT'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                List<INTF_WebServicesDef.SVMXMap> lstDoc_Res = new List<INTF_WebServicesDef.SVMXMap>();
                if(lstDocs != null && lstDocs.size() > 0)
                {
                    INTF_WebServicesDef.SVMXMap docResource = new INTF_WebServicesDef.SVMXMap();
                    docResource.key = 'DOCUMENT';
                    docResource.valueMap = clsUtility.getKeyValueForData(svmx_Cons.getDocumentDef(), lstDocs);
                    lstDoc_Res.add(docResource);
                }
                response.valueMap.addAll(lstDoc_Res);
            }
            else if(eventType == 'SYNC' && eventName == 'SYNC_CONFIG_LMD')
            {
                 Id idGrpProfile = clsUtility.getGroupProfileId(null, true);
                if(idGrpProfile != null)
                {
                 String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(idGrpProfile, strDevice);
                    String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c = \'CONFIG_LAST_MOD\' AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
         
                    if(strDevConfId != NULL && strDevConfId != ''){
                        strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId limit 1';
                    }else{
                        strMobConfQuery += ' limit 1';
                    }
                    
                    INTF_WebServicesDef.SVMXMap objLMD = new INTF_WebServicesDef.SVMXMap();
                    for(SVMXC__ServiceMax_Config_Data__c objCnfgData :Database.Query(strMobConfQuery))
                    {
                        objLMD.key = 'CONFIG_LAST_MOD';
                        objLMD.value = objCnfgData.SVMXC__Internal_value__c;
                        response.valueMap.add(objLMD);
                    }
                }
            }
            else if(eventType == 'SYNC' && eventName == 'SFM_OBJECT_NAMES')
            {
                Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
                if(inputRequest.values != null && inputRequest.values.size() > 0)
                {
                    allowedProcess.putAll([Select Id, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__Page_Layout__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= 'Target Manager' AND Id IN: inputRequest.values]);
                    if(allowedProcess != NULL && allowedProcess.size() > 0)
                    {
                        response.values.addAll(clsUtility.getSFMObjects(allowedProcess));
                    }
                }
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(mapErrorMessage, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        if(response.success == null)
            response.success = true;
        response.eventType = eventType;
        response.eventName = eventName;
        INTF_DataSync.logMethodEndTS(intMethodCount, 'eventController');
        return response;
    }
    
    public APFT_Schema.Filters getApplicationFilters()
    {
        APFT_Schema.Filters returnfilterstoExclude;
        system.debug('TeststrDevice : ' + strDevice);
        if(strDevice == 'MFL')
            strDeviceNameInFilter = 'APPPRO006';
        else if(strDevice == 'iPad')
            strDeviceNameInFilter = 'APPPRO002';
        else if(strDevice == 'iPhone')
            strDeviceNameInFilter = 'APPPRO003';
        else if(strDevice == 'Android')
            strDeviceNameInFilter = 'APPPRO004';
        else if(strDevice == 'Android Tablet')
            strDeviceNameInFilter = 'APPPRO005';
        else
            strDeviceNameInFilter = 'APPPRO006';
                
        returnfilterstoExclude = APFT_Utilities.getInstance().getDeviceFilters(strDeviceNameInFilter);
        return returnfilterstoExclude;
    }
    
    public boolean isVersionCorrect(string version_Client, string version_expected)
    {
        List<string> lst_VersionClient = version_Client.replace('.', ';').split(';');
        List<string> lst_VersionExpected = version_expected.replace('.', ';').split(';');
        
        if(lst_VersionClient.size() < 4)
        {
            while(lst_VersionClient.size() < 4)
            {
                lst_VersionClient.add('0');
            }
        }
        if(lst_VersionExpected.size() < 4)
        {
            while(lst_VersionExpected.size() < 4)
            {
                lst_VersionExpected.add('0');
            }
        }
        
        for(integer i=0; i<4; i++)
        {
            if(integer.valueOf(lst_VersionExpected[i]) < integer.valueOf(lst_VersionClient[i]))
                return true;
            else if(integer.valueOf(lst_VersionExpected[i]) > integer.valueOf(lst_VersionClient[i]))
                return false;
        }
        return true;
    }

    public INTF_WebServicesDef.INTF_SFMResponse saveClientLogs(INTF_WebServicesDef.INTF_SFMRequest req)
    {
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        res.eventName = req.eventName;
        res.eventType = req.eventType;
        res.success = true;
        res.valueMap = new List<INTF_WebservicesDef.SVMXMap>();
        
        if(req.valueMap == null || req.valueMap.size() == 0)
        {
            res.success = false;
            res.value = 'No Logs available to save.';
            return res;
        }
        
        string jsonStr;
        for(INTF_WebservicesDef.SVMXMap mp : req.valueMap)
        {
            if(mp.key == 'LOGS')
            {
                jsonStr = mp.value;
                break;
            }
        }
        
        if(jsonStr == null || jsonStr.length() == 0)
        {
            res.success = false;
            res.value = 'No Logs available to save.';
            return res;
        }
        system.debug(loggingLevel.WARN, 'JSON String from Request: ' + jsonStr);
        List<SVMXC__SVMX_Job_Logs__c> lstJobLogs = new List<SVMXC__SVMX_Job_Logs__c>();
        lstJobLogs = (List<SVMXC__SVMX_Job_Logs__c>)JSON.deserialize(jsonStr, List<SVMXC__SVMX_Job_Logs__c>.class);
        
        system.debug(loggingLevel.WARN, 'First Record deserialized: ' + lstJobLogs[0]);
        system.debug(loggingLevel.WARN, 'Number of Records deserialized: ' + lstJobLogs.size());
        system.debug(loggingLevel.WARN, 'Records deserialized: ' + lstJobLogs);
        
        if(lstJobLogs != null && lstJobLogs.size() > 0)
        {
            try
            {
                if(SVMXC__SVMX_Job_Logs__c.sObjectType.getDescribe().isCreateable()){
                    insert lstJobLogs;
                }
            }catch(Exception ex)
            {
                res.success = false;
                res.messageType = 'ERROR';
                res.message = ex.getMessage();
            }
        }
        return res;
    }
}