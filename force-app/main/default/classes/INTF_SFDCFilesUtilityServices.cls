public class INTF_SFDCFilesUtilityServices
{
    
    public static List<string> lstSignatureIds;
   
    public INTF_WebServicesDef.INTF_SFMResponse createSalesforceFiles(INTF_WebServicesDef.INTF_SFMRequest request){
        //Check if Salesforce files is enabled
        //Parse request
        //Map fields for CV
        //Insert CV
        //Query CV to get CD ID
        //Map fields for CDL
        //Insert CDL
        //Prepare response and send
        //Error handling
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        response.eventName = 'SYNC_SALESFORCE_FILES';
        response.eventType = 'SYNC';
             
        if(request == NULL){
            response.success = false;
            response.message = 'Empty request. Unable to perform sync.';
            return response;
        }
        
        //Get Client details from the request
        String syncRequestId = request.value;
        map<String, String> mapClientDetails = new map<String, String>();
        if(request.clientInfo != NULL && request.clientInfo.size() > 0){
                for(INTF_WebServicesDef.SVMXClient clientInform : request.clientInfo){
                    for(String strInfo : clientInform.clientInfo){
                        if(strInfo != null && strInfo.length() > 0){
                        if(strInfo.split(':',2).size() == 2)
                            mapClientDetails.put(strInfo.split(':',2)[0], (strInfo.split(':',2)[1]).trim());
                    }
                }
                if(clientInform.clientType != null)
                    {
                        mapClientDetails.put('DeviceName',clientInform.clientType);
                        break;
                    }
            }
        }
        
        if(request.eventName == 'SYNC_SALESFORCE_FILES' && request.eventType == 'SYNC'){
            try{
                    
                map<String, String> mapSavedLocalIdToSFId = new map<String, String>();
                List<sObject> contVersToInsertList = new List<sObject>(); 
                List<INTF_WebServicesDef.SVMXMap> errorList = new List<INTF_WebServicesDef.SVMXMap>();
                Map<String, String> localIdToSFIdMap = new Map<String, String>();
                Database.Saveresult [] cvInsertResult; 
                List<String> localIdsList = new List<String>();
                Map<String, string> localIdToParentIDMap = new Map<String, String>();
                Map<String, String> localIdToContentDocIdMap = new Map<String,String>();
                String parentRecordId = '';
                String userID = mapClientDetails.get('userid');
                List<String> existingCVIDList = new List<String>();
                String processID = '',existingDocID = '';
                
                for(INTF_WebServicesDef.SVMXMap eachVM : request.valueMap){
                    if(eachVM.key == 'PROCESS_ID' && !String.isBlank(eachVM.value)){
                        processID = eachVM.value;
                    }
                }
                
                //Get SFID to Local Id mapping from cache
                SVMXC__SM_SFMTransactionSync__c singleTxnRec = (new SFMTransactionSync()).getSFMTxnCacheRec(syncRequestId, mapClientDetails.get('userid'), mapClientDetails.get('clientudid'), 'INSERT');
        
                if(singleTxnRec.SVMXC__SM_Local_and_Platform_Id__c != null && singleTxnRec.SVMXC__SM_Local_and_Platform_Id__c != ''){
                    mapSavedLocalIdToSFId = (map<String, String>)JSON.deserialize(singleTxnRec.SVMXC__SM_Local_and_Platform_Id__c, map<String, String>.Class);
                }
                    
                for(INTF_WebServicesDef.SVMXMap reqVM : request.valueMap){
                    if(reqVM.key == 'object_name' && reqVM.value == 'ContentVersion'){
                        
                        //Describe the object ContentVersion
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = reqVM.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        Map<String,String> fieldsType = new Map<String,String>();
                        Map<String,String> fieldCreateable = new Map<String,String>();
                        
                        if(objDef != NULL){
                            for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap){
                                if(objProp.key == 'FIELDPROPERTY'){   
                                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap){
                                        for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap){
                                            if(fldObj.key == 'TYPE'){
                                                fieldsType.put(lstField.value, fldObj.value);
                                            }
                                            if(fldObj.key == 'CREATEABLE'){
                                                fieldCreateable.put(lstField.value, fldObj.value);
                                            }
                                        }
                                    }
                                }
                            }
                         }
                         
                        //Process each record
                        for(INTF_WebServicesDef.SVMXMap fieldsVM : reqVM.valueMap){
                            Sobject sobj = NULL;
                            if(!String.isBlank(fieldsVM.key)){
                                system.debug(LoggingLevel.WARN, 'LocalId is '+fieldsVM.key);   //Gives the local Id
                                
                                String SFIDIfExists = mapSavedLocalIdToSFId.get(fieldsVM.key);  //map.get(local_ID) give the sfdc Id
                                if(SFIDIfExists != NULL){  //Record has been inserted already
                                    //TODO
                                    localIdToSFIdMap.put(fieldsVM.key, SFIDIfExists);
                                    existingCVIDList.add(fieldsVM.key);
                                    for(INTF_WebServicesDef.SVMXMap cvFieldsVM : fieldsVM.valueMap){
                                        if(!String.isBlank(cvFieldsVM.key)){
                                            localIdToParentIDMap.put(fieldsVM.key,cvFieldsVM.key);
                                        }
                                    }
                                    system.debug(LoggingLevel.WARN,'SFDC ID exists for this content Version'+SFIDIfExists);
                               }else{
                                    //CV needs to be inserted
                                    localIdsList.add(fieldsVM.key);
                                    for(INTF_WebServicesDef.SVMXMap cvFieldsVM : fieldsVM.valueMap){
                                            
                                        if(!String.isBlank(cvFieldsVM.key)){
                                            localIdToParentIDMap.put(fieldsVM.key,cvFieldsVM.key);
                                            parentRecordId = cvFieldsVM.key;
                                        }
                                        
                                        boolean userHasAccess = false;
                                            if(processID != '' && parentRecordId != ''){
                                            //Check if a ContentVersion for this ProcessID already exists
                                            //List<ContentDocumentLink> processCDLList = [select Id, ContentDocumentID, LinkedEntityID from ContentDocumentLink where (LinkedEntityID =:parentRecordId OR LinkedEntityID =:userID) AND ContentDocument.LatestPublishedVersion.SVMXC__SM_Process_ID__c =: processID ];
                                            List<ContentDocumentLink> processCDLList = [select Id, ContentDocumentID, LinkedEntityID from ContentDocumentLink where (LinkedEntityID =:userID AND ContentDocument.LatestPublishedVersion.SVMXC__SM_Process_ID__c =: processID) ];
                                            system.debug(LoggingLevel.WARN, '*** processCDLList = '+processCDLList);
                                            for(ContentDocumentLink eachCDL: processCDLList){
                                                if(eachCDL.LinkedEntityID == userID){
                                                    userHasAccess = true;
                                                    existingDocID = eachCDL.ContentDocumentId;
                                                }
                                            }
                                        }
                                        
                                         String jstr = cvFieldsVM.value;   
                                         JSONParser jsp = JSON.createParser(jstr);
                                         sObj = Schema.getGlobalDescribe().get(reqVM.value).newSObject();
                                         sObj.put('VersionData', Blob.Valueof('SVMX'));   //Special handling for versionData - which will be uploaded later
                                         
                                         if(existingDocID != '' && userHasAccess){ //Map the existing contentDocumentId
                                            system.debug(LoggingLevel.WARN, 'existingDocID is '+existingDocID); 
                                            sObj.put('ContentDocumentId',existingDocID);
                                            localIdToContentDocIdMap.put(fieldsVM.key,existingDocID);
                                         }
                                         
                                         while(jsp.nextToken() != NULL){
                                            if(jsp.getCurrentToken() == JSONToken.FIELD_NAME){
                                                String fieldName = jsp.getText();
                                                
                                                /*if(processID != '' && existingDocID != '' && userHasAccess && fieldName == 'FirstPublishLocationId' ){
                                                    continue;  //Do not map FirstPublishLocationId if its not the first version
                                                }*/
                                                if(fieldName == 'FirstPublishLocationId'){  //Not mapping FirstPublishLocationId
                                                    continue;
                                                }
                                                
                                                if(jsp.nextToken() == JSONToken.VALUE_STRING){
                                                    String fieldValue = jsp.getText();
                                                    if(fieldCreateable.get(fieldName) == 'true'){
                                                        if(fieldValue != NULL && fieldValue != ''){
                                                            system.debug('Field Name = '+fieldName + ' ---- Field Value = '+fieldValue);
                                                
                                                            if(mapClientDetails.get('DeviceName') != NULL && mapClientDetails.get('DeviceName') != '' && mapClientDetails.get('DeviceName').contains('iPad')){
                                                                fieldValue = fieldValue.replace('&amp;', '&');
                                                                fieldValue = fieldValue.replace('&apos;', '\'');
                                                                fieldValue = fieldValue.replace('&lt;', '<');
                                                                fieldValue = fieldValue.replace('&gt;', '>');
                                                                fieldValue = fieldValue.replace('&quot;', '"');
                                                            }
                                                
                                                            if(fieldsType.get(fieldName) == 'DATETIME' && fieldValue != ''){
                                                                fieldValue = fieldValue.replace('T', ' ');
                                                                fieldValue = fieldValue.replace('Z', ' ');
                                                                sObj.put(fieldName, Datetime.valueOfGmt(fieldValue));
                                                            }else if(fieldsType.get(fieldName) == 'DATE' && fieldValue != ''){
                                                                sObj.put(fieldName, Date.valueOf(fieldValue));
                                                            }else if(fieldsType.get(fieldName) == 'TIME'){
                                                                continue;
                                                            }else if(fieldsType.get(fieldName) == 'BOOLEAN'){
                                                                sObj.put(fieldName, Boolean.Valueof(fieldValue));
                                                            }else if(fieldsType.get(fieldName) == 'DOUBLE'){
                                                                sObj.put(fieldName, decimal.Valueof(fieldValue));
                                                            }else if(fieldsType.get(fieldName) == 'DECIMAL' || fieldsType.get(fieldName) == 'CURRENCY' || fieldsType.get(fieldName) == 'PERCENT'){
                                                                sObj.put(fieldName, decimal.Valueof(fieldValue));
                                                            }else if(fieldsType.get(fieldName) == 'INTEGER'){
                                                                sObj.put(fieldName, Integer.Valueof(fieldValue));
                                                            }else{
                                                                sObj.put(fieldName,fieldValue);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                if(sObj != NULL){
                                    contVersToInsertList.add(sObj);
                                }
                                
                            }
                        }
                        
                        
                        system.debug(LoggingLevel.WARN,' +++ contVersToInsertList = '+contVersToInsertList);
                        INTF_WebServicesDef.SVMXMap error;
                        integer i = 0;
                        //Insert Content Version Records
                        try{
                            cvInsertResult = Database.insert(contVersToInsertList,false);
                            system.debug(LoggingLevel.WARN,' +++ cvInsertResult = '+cvInsertResult);
                            for(Database.SaveResult res: cvInsertResult){
                                if(res.isSuccess()){
                                    system.debug(LoggingLevel.WARN,' +++ Success = '+res.getId());
                                    localIdToSFIdMap.put(localIdsList[i], res.getId());
                                }else{
                                    error = new INTF_WebServicesDef.SVMXMap();
                                    Database.Error err = res.GetErrors()[0];
                                    error.key = reqVM.value;
                                    error.Value = err.getMessage();
                                    system.debug(LoggingLevel.WARN,' +++ FAiled = '+err.getMessage());
                                    error.ValueMap.add(new INTF_WebServicesDef.SVMXMap(localIdsList[i],''));
                                    errorList.add(error);  
                                }
                                i++;
                            }
                        }catch(Exception ex){
                            error = new INTF_WebServicesDef.SVMXMap();
                             error.Key = reqVM.value;
                             error.Value = ex.getMessage();
                             error.valueMap.add(new INTF_WebServicesDef.SVMXMap(localIdsList[i],''));
                             errorList.add(error);
                        }
                    }
                
                }
                contVersToInsertList.clear();
                
                Map<Id,Id> cvIdToDocIDMap = new Map<Id,Id>();
                //Once ContentVersions have been inserted, get the ContentDocument for these Records:
                if(!localIdToSFIdMap.values().isempty()){
                    cvIdToDocIDMap = COMM_FileHandlerUtilities.getContentDocumentsId(localIdToSFIdMap.values());
                }
                
                system.debug(LoggingLevel.WARN,' +++ cvIdToDocIDMap = '+cvIdToDocIDMap);
                system.debug(LoggingLevel.WARN,' +++ localIdToParentIDMap = '+localIdToParentIDMap);
                system.debug(LoggingLevel.WARN,' +++ localIdToSFIdMap = '+localIdToSFIdMap);    
                
                //Create ContentDocumentLink for these CVs
                List<ContentDocumentLink> cdlToInsertList = new List<ContentDocumentLink>();
                ContentDocumentLink cdlRecord = NULL;
                for(String localId: localIdToSFIdMap.keyset()){
                    if(existingCVIDList.contains(localId) || localIdToContentDocIdMap.containsKey(localId)){
                        //CV and CD already exists - do not insert CDL
                    }else{
                        if(localIdToParentIDMap.get(localId) != NULL && cvIdToDocIDMap.get(localIdToSFIdMap.get(localId)) != NULL){
                            cdlRecord =new ContentDocumentLink();
                            cdlRecord.LinkedEntityId = localIdToParentIDMap.get(localId);
                            cdlRecord.ContentDocumentId = cvIdToDocIDMap.get(localIdToSFIdMap.get(localId));
                            cdlRecord.ShareType = 'I';
                            cdlRecord.Visibility = 'AllUsers';   //Check Mapping
                            cdlToInsertList.add(cdlRecord);
                        }
                    }
                }   
                
                system.debug(LoggingLevel.WARN,' +++ cdlToInsertList = '+cdlToInsertList);    
                //Insert cdlToInsertList
                List<Id> cdlIdList = COMM_FileHandlerUtilities.insertContentDocumentLink(cdlToInsertList);
                
                system.debug(LoggingLevel.WARN,' +++ cdlIdList = '+cdlIdList);
                Set<String> parentIdSet = new Set<String>();
                parentIdSet.addAll(localIdToParentIDMap.values());
                
                //Set<String> allDocIdSet = new Set<String>();
                //allDocIdSet.addAll(cvIdToDocIDMap.values());
                
                system.debug(LoggingLevel.WARN,' +++ parentIdSet = '+parentIdSet);
                //system.debug(LoggingLevel.WARN,' +++ allDocIdSet = '+allDocIdSet);
                
                List<ContentDocumentLink> insertedCDLList = [Select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where (LinkedEntityId IN: parentIdSet) AND (ContentDocumentId IN: cvIdToDocIDMap.values()) ];
                system.debug(LoggingLevel.WARN,' +++ insertedCDLList = '+insertedCDLList);
                INTF_WebServicesDef.SVMXMap innerRes = new INTF_WebServicesDef.SVMXMap();
                
                for(ContentDocumentLink eachCDL : insertedCDLList ){
                    for(String localId: localIdToParentIDMap.Keyset()){
                        if(localIdToParentIDMap.get(localId) == eachCDL.LinkedEntityId && eachCDL.ContentDocumentId == cvIdToDocIDMap.get(localIdToSFIdMap.get(localId))){
                            innerRes = new INTF_WebServicesDef.SVMXMap();
                            innerRes.Key = localId;
                            innerRes.value = localIdToSFIdMap.get(localId);
                            innerRes.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocument',cvIdToDocIDMap.get(localIdToSFIdMap.get(localId))));
                            innerRes.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink',eachCDL.Id));
                            response.valueMap.add(innerRes);
                        }
                    }
                }
                
                //Update Txn Record with SFDC id
                singleTxnRec.SVMXC__SM_Local_and_Platform_Id__c = JSON.serialize(localIdToSFIdMap);
                singleTxnRec.SVMXC__SM_Operation_Type__c = 'INSERT';
                 if(COMM_SecurityUtils.getInstance().verifyFieldAccess(singleTxnRec, COMM_SecurityUtils.Access.Createable)){
                    Database.UpsertResult saveCache = Database.upsert(singleTxnRec);
                 }else{
                    system.debug(LoggingLevel.WARN, 'Permission issue on SVMXC__SM_SFMTransactionSync__c : '+ System.label.COMM001_TAG142);
                    errorList.add(new INTF_WebServicesDef.SVMXMap('SVMXC__SM_SFMTransactionSync__c', System.label.COMM001_TAG142));
                 }
                
                if(errorList.size() > 0){
                    INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap('ERROR','');
                    ErrorHeader.valueMap = ErrorList;
                    response.valueMap.add(ErrorHeader);
                }
                
                system.debug(' Heap size before clearing = '+Limits.getHeapSize() + ' ; SOQLs used = '+ Limits.getQueries());
                cdlToInsertList.clear();
                localIdToSFIdMap.clear();
                cvIdToDocIDMap.clear();
                localIdToParentIDMap.clear();
                localIdToContentDocIdMap.clear();
                system.debug(' Heap size after clearing = '+Limits.getHeapSize());
                
             }catch(Exception ex){
                SmaxException customException = new SmaxException(null, ex);
                response.errors.add(customException.getDetailedErrorMsg());
                response.success = false;
                response.message = ex.getMessage();
                return response;
             }
        }
        response.success = true;
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getEventRelatedFiles(INTF_WebServicesDef.INTF_SFMRequest request, String  svmxGrpProfileId){
            
            //Check if Files enabled
            //Read mobile config for file related filters
            //Query events from cache - or get event what Ids
            //Query CDL related to those - based on LMD
            INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
            
            system.debug('+++Entered getEventRelatedFiles ');
            try{
                
                Boolean isFilesEnabled = COMM_FileHandlerUtilities.checkFileSetting();
                system.debug(LoggingLevel.WARN,'isFilesEnabled = '+isFilesEnabled);
                
                if(isFilesEnabled){
                    
                    if(request.EventType == 'SYNC' && request.EventName == 'DOWNLOAD_EVENT_FILES'){
                        
                    Boolean isCallBack = false, filesEnabledforProfile = false;
                    Datetime dtLastSyncTime = null, configLastModifiedDate = null;
                    String cdlLastID = '', strCDLLastIDClause = '', strFileTypes = '', strFileTypeClause = '', strFileSizeClause = '', strCDLQuery = '', lastSyncTimeClause = '' ;
                    CONF_MobileConfig.FileConfig fileConf = NULL;
                    Integer intMaxFileSize = 25, intLimit;
                    Set<String> setWhatIds = new Set<String>();
                    Set<String> setNewEventWhatIds = new Set<String>();
                    Set<String> fileTypeList = new Set<String>();
                    Set<String> fileTagsList = new Set<String>();
                    
                    
                    intLimit = getLimit(svmxGrpProfileId);
                    
                    //intLimit = 20; //For testing only
                                
                    //Get Client details from the request
                    String syncRequestId = request.value;
                    map<String, String> mapClientDetails = new map<String, String>();
                    if(request.clientInfo != NULL && request.clientInfo.size() > 0){
                        for(INTF_WebServicesDef.SVMXClient clientInform : request.clientInfo){
                            for(String strInfo : clientInform.clientInfo){
                                if(strInfo != null && strInfo.length() > 0){
                                    if(strInfo.split(':',2).size() == 2)
                                        mapClientDetails.put(strInfo.split(':',2)[0], (strInfo.split(':',2)[1]).trim());
                                }
                            }
                            if(clientInform.clientType != null)
                                {
                                    mapClientDetails.put('DeviceName',clientInform.clientType);
                                    break;
                                }
                        }
                    }
                    system.debug(LoggingLevel.WARN,'mapClientDetails = '+mapClientDetails);
                    for(INTF_WebServicesDef.SVMXMap eachVM : request.valueMap){
                        if(eachVM.key == 'LAST_SYNC_TIME' && eachVM.value != null && eachVM.value != ''){
                            dtLastSyncTime = Datetime.valueOf(eachVM.value);
                        }else if(eachVM.key == 'CALL_BACK' && !String.isBlank(eachVM.value) ){
                            //isCallBack = Boolean.valueOf(eachVM.value);
                            for(INTF_WebServicesDef.SVMXMap callbackVM : eachVM.valueMap){
                                    if(callbackVM.key == 'CDL_LASTID' && !String.isBlank(callbackVM.value) ){
                                        cdlLastID = String.valueOf(callbackVM.value);
                                        strCDLLastIDClause = ' AND ID >: cdlLastID ';
                                    }
                            }
                        }
                    }
                    
                    //Query Mobile Configuration  - TODO: CHECK FOR RECORD TYPE AND OBJECT NAME 
                    String strMobConfQuery  = 'select id, SVMXC__SM_Files_Config__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c = \'Files\' AND SVMXC__Display_Type__c = \'Advanced Download Criteria\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:svmxGrpProfileId';
                    String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(svmxGrpProfileId, mapClientDetails.get('DeviceName'));
                    if(strDevConfId != NULL && strDevConfId != ''){
                        strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                    }
                    
                    system.debug(LoggingLevel.WARN,'** Query is strMobConfQuery = '+strMobConfQuery);
                    List<SVMXC__ServiceMax_Config_Data__c> filesConfigList = Database.query(strMobConfQuery);
                    system.debug(LoggingLevel.WARN,'** filesConfigList = '+filesConfigList);
                    if(filesConfigList != NULL && !filesConfigList.isEmpty() && filesConfigList[0] != NULL){
                            
                            configLastModifiedDate = filesConfigList[0].LastModifiedDate;
                            
                            if(filesConfigList[0].SVMXC__SM_Files_Config__c != NULL){
                                fileConf = (CONF_MobileConfig.FileConfig)JSON.deserialize(filesConfigList[0].SVMXC__SM_Files_Config__c, CONF_MobileConfig.FileConfig.class);
                                system.debug(LoggingLevel.WARN,'** File filters are = '+fileConf);
                            }
                            
                            if(fileConf.isFilesEnabled != NULL){
                                filesEnabledforProfile = fileConf.isFilesEnabled;
                                system.debug(LoggingLevel.WARN,'filesEnabledforProfile = '+filesEnabledforProfile);
                            }
                            
                            strFileTypes = fileConf.fileTypes;
                            if(!String.isBlank(strFileTypes)){
                                fileTypeList.addAll(strFileTypes.remove('.').split(','));
                                strFileTypeClause = ' AND ( ContentDocument.LatestPublishedVersion.FileType IN: fileTypeList OR ContentDocument.LatestPublishedVersion.FileExtension IN: fileTypeList )';
                                system.debug(LoggingLevel.WARN,'fileTypeList = '+fileTypeList);
                            }
                            
                            if(!String.isBlank(fileConf.fileTags)){
                                    fileTagsList.addAll(fileConf.fileTags.split(','));
                                    system.debug(LoggingLevel.WARN,'fileTagsList = '+fileTagsList);
                            }
                            
                            if(!String.isBlank(fileConf.maxFileSize)){
                                intMaxFileSize = Integer.valueOf(fileConf.maxFileSize);
                            }
                            intMaxFileSize = intMaxFileSize * 1000 * 1000;
                            strFileSizeClause = ' AND ContentDocument.LatestPublishedVersion.ContentSize <=: intMaxFileSize ';
                            system.debug(LoggingLevel.WARN,'intMaxFileSize = '+intMaxFileSize);
                            
                    }
                        
                   if(filesEnabledforProfile){
                            
                         //Get All What Ids from events
                         String strSFUserId = mapClientDetails.get('userid');
                         String strDeviceUDID = mapClientDetails.get('clientudid');
                         Map<String, String> mapAllEventWhatIds = new Map<String, String>();
                         
                         List<SVMXC__SM_Request_Cache__c> requestCacheList = [Select Id, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Event_What_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strSFUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID];
                         if(requestCacheList != null && !requestCacheList.isEmpty()){  
                            system.debug(LoggingLevel.WARN, '***** requestCacheList = '+requestCacheList[0]); 
                            if(requestCacheList[0].SVMXC__SM_Client_Sync_Request_Id__c == syncRequestId && requestCacheList[0].SVMXC__SM_Event_What_IDs__c != NULL ){
                                mapAllEventWhatIds = (Map<String, String>)Json.deserialize(requestCacheList[0].SVMXC__SM_Event_What_IDs__c,Map<String, String>.Class);
                                system.debug(LoggingLevel.WARN, '***** After Deserializing = '+mapAllEventWhatIds);  
                            }
                        } 
                        
                        if(mapAllEventWhatIds != NULL && !mapAllEventWhatIds.isEmpty()){
                            if(mapAllEventWhatIds.get('ALL_EVENTS') != NULL){
                                setWhatIds = (Set<String>)Json.deserialize(mapAllEventWhatIds.get('ALL_EVENTS'),Set<String>.Class);
                            }  
                            if(dtLastSyncTime != null && mapAllEventWhatIds.get('MODIFIED_EVENTS') != NULL ){
                                setNewEventWhatIds = (Set<String>)Json.deserialize(mapAllEventWhatIds.get('MODIFIED_EVENTS'),Set<String>.Class);
                            } 
                            setWhatIds.removeAll(setNewEventWhatIds);
                        }else{
                                //TODO Query all the What Ids again
                                
                                Datetime dtToDate, dtFromDate, dtMovingDate;
                                   Datetime currentTime = Datetime.now();
                                String strMobConfQuery1  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:svmxGrpProfileId';
                                    if(strDevConfId != NULL && strDevConfId != ''){
                                    strMobConfQuery1 += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                                }
                                    system.debug(LoggingLevel.WARN,'Query formed for getAdvanceDownloadCriteriaRecIds = '+strMobConfQuery1);
        
                                    if(svmxGrpProfileId != null)
                                    {
                        
                                    for(SVMXC__ServiceMax_Config_Data__c objConfigData : Database.Query(strMobConfQuery1))
                                    {
                                        Integer intValue = 10;
                                        if(objConfigData.SVMXC__Display_Type__c == 'Synchronization To Remove Events')
                                        {
                                            if(objConfigData.SVMXC__Internal_value__c != null && objConfigData.SVMXC__Internal_value__c.length() > 0)
                                            {
                                                intValue = Integer.valueOf(objConfigData.SVMXC__Internal_value__c);
                                                if(intValue < 1)
                                                    intValue = 10;
                                            }   
                                            dtFromDate = currentTime - (intValue + 1);
                                        }   
                                        else if(objConfigData.SVMXC__Display_Type__c == 'Synchronization To Get Events')
                                        {
                                            if(objConfigData.SVMXC__Internal_value__c != null && objConfigData.SVMXC__Internal_value__c.length() > 0)
                                            {
                                                intValue = Integer.valueOf(objConfigData.SVMXC__Internal_value__c);
                                                if(intValue < 1)
                                                    intValue = 10;
                                            }   
                                            dtToDate = currentTime + intValue + 1;
                                            if(dtLastSyncTime != null)
                                                dtMovingDate = dtLastSyncTime + intValue + 1;
                                        }
                                    }
                                    }
                                    for(Event evt :[Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strSFUserId and WhatId != null])
                                        setWhatIds.add(evt.What.Id);
                        
                                    for(SVMXC__SVMX_Event__c evt :[Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strSFUserId and SVMXC__WhatId__c != null])
                                        setWhatIds.add(evt.SVMXC__WhatId__c);
                    
                                if(dtLastSyncTime != null)
                                {
                                    for(Event evt : [select Id, WhatId from Event where ((StartDateTime >= :dtMovingDate and EndDateTime <= :dtToDate) OR (LastModifiedDate >= :dtLastSyncTime and ((StartDateTime >= :dtFromDate and EndDateTime <= :dtToDate) OR (StartDateTime <= :dtFromDate and EndDateTime >= :dtToDate)))) and OwnerId = :strSFUserId and WhatId != null])
                                        setNewEventWhatIds.add(evt.WhatId);
                                        
                                    for(SVMXC__SVMX_Event__c evt : [select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate)) OR (LastModifiedDate >= :dtLastSyncTime and ((SVMXC__StartDateTime__c >= :dtFromDate and SVMXC__EndDateTime__c <= :dtToDate) OR (SVMXC__StartDateTime__c <= :dtFromDate and SVMXC__EndDateTime__c >= :dtToDate)))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strSFUserId and SVMXC__WhatId__c != null])
                                        setNewEventWhatIds.add(evt.SVMXC__WhatId__c);
                                }
                                system.debug(LoggingLevel.WARN, 'New event whatids = ' + setNewEventWhatIds + '; All Events except New Events' + setWhatIds);
                            }
                        
                        system.debug(LoggingLevel.WARN,'** dtLastSyncTime = '+dtLastSyncTime);
                        if(configLastModifiedDate <= dtLastSyncTime){
                                lastSyncTimeClause = ' AND ( ContentDocument.SystemModStamp >= :dtLastSyncTime OR SystemModStamp >= :dtLastSyncTime ) ';
                        }
                        
                        system.debug(LoggingLevel.WARN, '**dtLastSyncTime = '+dtLastSyncTime);  
                        if(dtLastSyncTime != NULL){   //Incremental
                            if(!setNewEventWhatIds.isEmpty() || !setWhatIds.isEmpty()){
                                strCDLQuery = 'Select Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Tagcsv, isDeleted, ContentDocument.isDeleted from ContentDocumentLink WHERE (( LinkedEntityID IN: setNewEventWhatIds ) OR ( LinkedEntityID IN: setWhatIds ' + lastSyncTimeClause + ' ))' + strFileTypeClause + strFileSizeClause + strCDLLastIDClause +' ORDER BY ID LIMIT : intLimit ALL ROWS';
                            }
                        }else{
                            if(!setWhatIds.isEmpty()){
                                strCDLQuery = ' Select Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Tagcsv, isDeleted, ContentDocument.isDeleted from ContentDocumentLink WHERE ( LinkedEntityID IN: setWhatIds )' + strFileTypeClause + strFileSizeClause + strCDLLastIDClause +' ORDER BY ID LIMIT : intLimit ALL ROWS';
                            }
                        }
                            
                        system.debug(LoggingLevel.WARN, '***** strCDLQuery = '+strCDLQuery);  
                        
                        if(strCDLQuery != ''){
                                    
                            List<ContentDocumentLink> cdlList = Database.Query(strCDLQuery);
                            
                            system.debug(LoggingLevel.WARN, '***** cdlList = '+cdlList.size());  
                            
                            List<String> linkIdList = new List<String>();
                            List<String> deletedLinkIds = new List<String>();  //For deleted Ids
                            List<String> deletedVersionIds = new List<String>();
                            List<String> deletedDocIds = new List<String>();
                            
                            //Get the contentDocumentId
                            for(ContentDocumentLink eachCDL: cdlList){
                                
                                //Filter contentVersion based on tags
                                Boolean isTagAvailable = checkAvailableTags(eachCDL.ContentDocument.LatestPublishedVersion.Tagcsv, fileTagsList);
                                
                                if(isTagAvailable){
                                    if(eachCDL.ContentDocument.isDeleted){
                                        deletedDocIds.add(eachCDL.ContentDocumentId);
                                        deletedVersionIds.add(eachCDL.ContentDocument.LatestPublishedVersionId);   //If the document is deleted, version also needs to be deleted
                                     }
                                        
                                     if(eachCDL.isDeleted){
                                        deletedLinkIds.add(eachCDL.Id);
                                     }else{
                                        linkIdList.add(eachCDL.Id);
                                     }   
                                 }
                            }
                            
                            response.valuemap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink','',linkIdList));
                            
                            system.debug(LoggingLevel.WARN, '***** linkIdList = '+linkIdList.size());  
                            
                            if(dtLastSyncTime != NULL && (deletedVersionIds.size() > 0 || deletedDocIds.size() > 0 || deletedLinkIds.size() > 0) ){   //Send deleted Ids only for Data Sync
                                INTF_WebServicesDef.SVMXMap deletedVM = new INTF_WebServicesDef.SVMXMap('SAFE_TO_DELETE', 'True');
                                deletedVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentVersion', '', deletedVersionIds));
                                deletedVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocument', '', deletedDocIds));
                                deletedVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink', '', deletedLinkIds));
                                response.valuemap.add(deletedVM);
                            }
                            
                            intLimit -= cdlList.size();
                            if(intLimit <= 0){
                                iscallBack = true;
                            }
                            if(isCallBack){
                                INTF_WebServicesDef.SVMXMap callbackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'True');
                                callbackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('CDL_LASTID', String.ValueOf(cdlList[cdlList.size()-1].Id)));
                                response.valuemap.add(callbackVM);
                            }
                       }
                            
                            
                    }//End of filesEnabledforProfile
                        
                }
            }
        }catch(Exception ex){
            system.debug(LoggingLevel.WARN, '*****Caught you! = '+ex.getMessage());  
            SmaxException customException = new SmaxException(null, ex);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
            response.message = ex.getMessage();
            return response;
        }
            
            response.success = true;
            response.EventType = request.EventType;
            response.EventName = request.EventName;
            return response;
    }
    
     public integer getLimit(String svmxGrpProfileId){
            
        Integer intLimit = 10000, intLimitPercent = 70;
            
        List<SVMXC__ServiceMax_Config_Data__c> svmxConfigList = (new INTF_ConfigSync()).getSettings(null, null, new set<string>{'IPAD018_SET011'}, svmxGrpProfileId);
        if(svmxConfigList != null && svmxConfigList.size() != 0)
            intLimitPercent = Integer.valueOf(svmxConfigList[0].SVMXC__Internal_Value__c);
                
        Integer intCPULimit = intLimitPercent * Limits.getLimitCPUTime()/100;
        Integer intHeapLimit = intLimitPercent * Limits.getLimitHeapSize()/100;
        Integer intQueryLimit = intLimitPercent * Limits.getLimitQueries()/100;
        Integer intQueryRowLimit = intLimitPercent * Limits.getLimitQueryRows()/100;
        
        List<Integer> lstIntPercent = new List<Integer>();
        lstIntPercent.add( (intLimitPercent * (intCPULimit - Limits.getCPUTime()))/intCPULimit );
        lstIntPercent.add( (intLimitPercent * (intHeapLimit - Limits.getHeapSize()))/intHeapLimit );
        lstIntPercent.add( (intLimitPercent * (intQueryLimit - Limits.getQueries()))/intQueryLimit );
        lstIntPercent.add( (intLimitPercent * (intQueryRowLimit - Limits.getQueryRows()))/intQueryRowLimit );
        
        lstIntPercent.sort();
        intLimit = (lstIntPercent[0] * (intQueryRowLimit - Limits.getQueryRows()))/100;
        
        return intLimit;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getProductIQFiles(INTF_WebServicesDef.INTF_SFMRequest request, String  svmxGrpProfileId){
        //Get filters from PIQ profile
        //For query for Initial and data sync
        //Query CDL based on the IDs from ParentId
        
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        Boolean isPIQEnabled = false;
        Set<String> setObjects = new Set<String>();
                    
        system.debug('Entered SYNC_PIQ_FILES');
        try{
            
            Boolean isFilesEnabled = COMM_FileHandlerUtilities.checkFileSetting();
            List<SVMXC__ServiceMax_Config_Data__c> svmxConfigList = (new INTF_ConfigSync()).getSettings(null, null, new set<string>{'PRODIQ002_SET001','IPAD018_SET013','IPAD018_SET004'}, svmxGrpProfileId);
            for(SVMXC__ServiceMax_Config_Data__c eachSet: svmxConfigList){
                    if(eachSet.SVMXC__Setting_Unique_ID__c == 'PRODIQ002_SET001' && !String.isBlank(eachSet.SVMXC__Internal_Value__c)){
                        isPIQEnabled = Boolean.valueOf(eachSet.SVMXC__Internal_Value__c);
                    }
            }
                            
            system.debug(LoggingLevel.WARN,'isFilesEnabled = ' + isFilesEnabled + '; isPIQEnabled = '+isPIQEnabled);
            if(isFilesEnabled && isPIQEnabled){
                
                DateTime dtLastSyncTime = null,dtPIQLastModfdDate = null;
                Boolean isPIQFilesEnabled = false;
                String strFileTypes = '', cdlLastID = '', strCDLLastIDClause = '', strFileTypeClause = '', strFileSizeClause = '';
                Set<String> fileTypeList = new Set<String>();
                Set<String> fileTagsList = new Set<String>();
                Integer intMaxFileSize = 25;
                map<String, List<String>> mapObjToIds = new map<String, List<String>>();
                map<String, List<String>> mapModifiedObjToIds = new map<String, List<String>>();
                
                List<SVMXC__ProductIQProfile__c> piqProfile = [SELECT Id, LastModifiedDate, SVMXC__Contents__c FROM SVMXC__ProductIQProfile__c WHERE SVMXC__ServiceMax_Profile__c =:svmxGrpProfileId];
                if(piqProfile != NULL && piqProfile.size() > 0 && piqProfile[0] != NULL){
                    ProductIQConfiguration.Profile prof = (ProductIQConfiguration.Profile)JSON.deserialize(String.valueOf(piqProfile[0].get('SVMXC__Contents__c')), ProductIQConfiguration.Profile.class);
                    if(prof.attachment != null && prof.attachment.size() > 0){
                        ProductIQConfiguration.AttachmentConfig filesConfig = prof.attachment[0];
                        
                        dtPIQLastModfdDate = piqProfile[0].LastModifiedDate;
                        
                        if(filesConfig.isAttachmentsEnabled != null)
                            isPIQFilesEnabled = Boolean.valueOf(filesConfig.isAttachmentsEnabled);
                          
                        strFileTypes = filesConfig.sfdcFileTypes;  
                        if(!String.isBlank(strFileTypes)){
                            fileTypeList.addAll(strFileTypes.remove('.').split(','));
                            strFileTypeClause = ' AND (ContentDocument.LatestPublishedVersion.FileType IN: fileTypeList OR ContentDocument.LatestPublishedVersion.FileExtension IN: fileTypeList ) ';
                            system.debug(LoggingLevel.WARN,'fileTypeList = '+fileTypeList);
                        } 
                         
                        if(!String.isBlank(filesConfig.sfdcFileTags)){
                            fileTagsList.addAll(filesConfig.sfdcFileTags.split(','));
                            system.debug(LoggingLevel.WARN,'fileTagsList = '+fileTagsList);
                        } 
                         
                        if(!String.isBlank(filesConfig.maxSfdcFileSize)){
                            intMaxFileSize = Integer.valueOf(filesConfig.maxSfdcFileSize);
                        }
                        intMaxFileSize = intMaxFileSize * 1000 * 1000;
                        strFileSizeClause = ' AND ContentDocument.LatestPublishedVersion.ContentSize <=: intMaxFileSize ';
                        system.debug(LoggingLevel.WARN,'intMaxFileSize = '+intMaxFileSize);
                        
                    }
                }
                
                if(isPIQFilesEnabled){
                    
                    String lastSyncTimeClause = '';
                    integer intQueryLimit = getLimit(svmxGrpProfileId);
                    //integer intQueryLimit = 2; //FOR TESTING PURPOSE ONLY
                    
                    //Parse request
                    for(INTF_WebServicesDef.SVMXMap eachVM : request.valueMap){
                        if(eachVM.Key == 'LAST_SYNC_TIME' && !String.isBlank(eachVM.value)){
                            dtLastSyncTime = Datetime.valueOf(eachVM.value);
                            if(dtPIQLastModfdDate <= dtLastSyncTime){
                                lastSyncTimeClause = ' AND ( ContentDocument.SystemModStamp >= :dtLastSyncTime OR SystemModStamp >= :dtLastSyncTime ) ';
                            }
                        }else if(eachVM.Key == 'TX_OBJECT' && !String.isBlank(eachVM.value)){
                            if(mapObjToIds.get(eachVM.value) == NULL){
                                mapObjToIds.put(eachVM.value, new List<String>());
                            }
                            mapObjToIds.get(eachVM.value).addAll(eachVM.values);
                            setObjects.add(eachVM.value);
                        }else if(eachVM.Key == 'MODIFIED_OBJECT' && !String.isBlank(eachVM.value)){
                                if(mapModifiedObjToIds.get(eachVM.value) == NULL){
                                mapModifiedObjToIds.put(eachVM.value, new List<String>());
                            }
                            mapModifiedObjToIds.get(eachVM.value).addAll(eachVM.values);
                            setObjects.add(eachVM.value);
                        }else if(eachVM.key == 'CALL_BACK' && !String.isBlank(eachVM.value) ){
                            for(INTF_WebServicesDef.SVMXMap callbackVM : eachVM.valueMap){
                                if(callbackVM.key == 'CDL_LASTID' && !String.isBlank(callbackVM.value) ){
                                    cdlLastID = String.valueOf(callbackVM.value);
                                    strCDLLastIDClause = ' AND ID >: cdlLastID ';
                                }
                            }
                        }
                    }
                    
                    system.debug(LoggingLevel.WARN,'**** mapModifiedObjToIds ='+ mapModifiedObjToIds);
                    
                    List<String> linkIdList = new List<String>();
                    List<String> deletedVersionIds = new List<String>();
                    List<String> deletedDocIds = new List<String>();
                    List<String> deletedCDLIds = new List<String>();
                    List<ContentDocumentLink> cdlList = NULL;
                    List<ContentDocumentLink> allCDLList = new List<ContentDocumentLink>();
                    
                    String technicianId = UserInfo.getUserId();
                    
                    for(String eachObject: setObjects){
                        
                        //Get the files for the IB/Loc Ids provided by the client
                        List<String> eachObjIds = new List<String>();
                        if( mapObjToIds.get(eachObject) != NULL){
                                eachObjIds = mapObjToIds.get(eachObject);
                        }
                       
                        String cdlQuery = 'Select Id, ContentDocumentId, LinkedEntityId, LinkedEntity.Type , ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Tagcsv, isDeleted, ContentDocument.isDeleted from ContentDocumentLink where ( ( LinkedEntityId IN: eachObjIds ' + strFileTypeClause + strFileSizeClause + lastSyncTimeClause + ' ) ';
                        
                        if(lastSyncTimeClause != ''){
                                cdlQuery += ' OR ( LinkedEntityId =: technicianId '+lastSyncTimeClause+' ) ';
                        }
                        
                        if(mapModifiedObjToIds != NULL && mapModifiedObjToIds.get(eachObject) != NULL && !mapModifiedObjToIds.get(eachObject).isEmpty() ){
                            List<String> modifiedObjIds = mapModifiedObjToIds.get(eachObject);
                            cdlQuery += ' OR ( LinkedEntityId IN: modifiedObjIds ' + strFileTypeClause + strFileSizeClause + ' ) ';
                        }
                        cdlQuery += ' ) ';
                        cdlQuery += strCDLLastIDClause +' ORDER BY ID LIMIT : intQueryLimit ALL ROWS';
                        
                        system.debug(LoggingLevel.WARN,'PIQ CDL Query is = '+cdlQuery);
                        //cdlList  = Database.Query('Select Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Tagcsv, isDeleted, ContentDocument.isDeleted from ContentDocumentLink where LinkedEntityID IN: eachObjIds ' + strFileTypeClause + strFileSizeClause + lastSyncTimeClause + strCDLLastIDClause +' ORDER BY ID LIMIT : intQueryLimit ALL ROWS');
                        cdlList = Database.Query(cdlQuery);
                        
                        if(cdlList != NULL){
                            intQueryLimit -= cdlList.size();
                            allCDLList.addAll(cdlList);
                        }
                            
                        if( intQueryLimit <= 0){
                             INTF_WebServicesDef.SVMXMap callbackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'True');
                             callbackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('CDL_LASTID', String.ValueOf(cdlList[cdlList.size()-1].Id)));
                             response.valuemap.add(callbackVM);
                             break;
                        }
                    }
                    
                    system.debug(LoggingLevel.WARN,'allCDLList = '+allCDLList.size());
                    
                    for(ContentDocumentLink eachCDL: allCDLList){
                        //Filter contentVersion based on tags
                        Boolean isTagAvailable = checkAvailableTags(eachCDL.ContentDocument.LatestPublishedVersion.Tagcsv, fileTagsList);
                        
                        if(isTagAvailable){
                              
                             if(eachCDL.ContentDocument.isDeleted){
                                deletedDocIds.add(eachCDL.ContentDocumentId);
                                deletedVersionIds.add(eachCDL.ContentDocument.LatestPublishedVersionId);   //If the document is deleted, version also needs to be deleted
                             }
                            
                            if(eachCDL.isDeleted){
                                deletedCDLIds.add(eachCDL.Id);
                             }else{
                                linkIdList.add(eachCDL.Id);
                             }   
                        }
                    }
                
                    if(request.EventName == 'DATA_ON_DEMAND'){  //For DOD - we query the records with all the fields and return to the client so that Tx_Fetch need not be performed 
                        
                        String fieldNamesForLink = getFieldNamesForObjects('ContentDocumentLink',svmxConfigList);
                        List<ContentDocumentLink> linkList = Database.query('Select ' + fieldNamesForLink + ' FROM ContentDocumentLink where ID IN :linkIdList ');
                        system.debug(LoggingLevel.WARN,'**** linkList ='+ linkList.size());  
                        response.valuemap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink',JSON.serialize(linkList)));
                        system.debug(LoggingLevel.WARN,'**** response DOD ='+ response);  
                    }else{
                        
                        response.valuemap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink',JSON.serialize(linkIdList)));
                        
                        if(dtLastSyncTime != NULL && (deletedVersionIds.size() > 0 || deletedDocIds.size() > 0 || deletedCDLIds.size() > 0 )){   //Send deleted Ids only during Data sync
                            INTF_WebServicesDef.SVMXMap deletedVM = new INTF_WebServicesDef.SVMXMap('SAFE_TO_DELETE', 'True');
                            deletedVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentVersion', '', deletedVersionIds));
                            deletedVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocument', '', deletedDocIds));
                            deletedVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink', '', deletedCDLIds));
                            response.valuemap.add(deletedVM);
                        }
                    }
                }//End of isPIQFilesEnabled
            }
        }catch(Exception ex){
            SmaxException customException = new SmaxException(null, ex);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
            response.message = ex.getMessage();
            return response;
        }
        
        response.eventName = request.eventName;
        response.eventType = request.eventType;
        return response;
    }
    
    
    //Method to filter Content version as per Tags configured
    public boolean checkAvailableTags(String versionTag, Set<String> fileTagsList){
            Boolean isTagAvailable = false;
        if(fileTagsList.isEmpty()){
                isTagAvailable = true;   //There were no tags configured in the settings - download all CV
        }else{
            if(versionTag != NULL){
                List<String> eachCVTags = versionTag.split(',');
                for(String eachTag: eachCVTags){
                    if(fileTagsList.contains(eachTag)){
                        isTagAvailable = true;
                        break;
                    }
                }
            }
        }
        return isTagAvailable;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getChecklistRelatedFiles(INTF_WebServicesDef.INTF_SFMRequest request, String  svmxGrpProfileId){
        //Get the ContentDocumentLink Ids from the request
        //Query the CD and CV ids related to these CDL
        //Form response and return
        
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        String strLastSyncTimeClause = '', strCDLLastIDClause = '', cdlLastID = '';
        Boolean isCallback = false;
        List<String> linkIdList = new List<String>();
        List<String> contentLinkIdList = new List<String>();
        List<String> documentIdList = new List<String>();
        List<String> versionIdList = new List<String>();
        List<String> deletedLinkIds = new List<String>();
        List<String> deletedDocIds = new List<String>();
        List<String> deletedVersionIds = new List<String>();
        
        try{
            if(request.eventName == 'DOWNLOAD_CHECKLIST_FILES'){
                for(INTF_WebServicesDef.SVMXMap eachKey : request.valueMap){
                    if(eachKey.key == 'CDL_IDS' && eachKey.values != NULL && eachKey.values.size() > 0){
                        linkIDList.addAll(eachKey.values);
                    }else if(eachKey.key == 'CALL_BACK' && !String.isBlank(eachKey.value)){
                        for(INTF_WebServicesDef.SVMXMap callbackVM : eachKey.valueMap){
                            if(callbackVM.key == 'CDL_LASTID' && !String.isBlank(callbackVM.value) ){
                                cdlLastID = String.valueOf(callbackVM.value);
                                strCDLLastIDClause = ' AND ID >: cdlLastID ';
                            }
                        }
                    }
                }
            }
            
            integer intQueryLimit = getLimit(svmxGrpProfileId);
            //intQueryLimit = 2; //For testing purpose only
            
            if(linkIDList.size() > 0 ){
                List<ContentDocumentLink> docLinkList = Database.Query('Select Id, isDeleted, ContentDocumentId, ContentDocument.isDeleted, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where ID IN: linkIDList' + strCDLLastIDClause + ' ORDER BY ID LIMIT: intQueryLimit ALL ROWS');
                system.debug(LoggingLevel.WARN,'docLinkList = '+docLinkList.size());
                if(docLinkList != NULL){
                    for(ContentDocumentLink eachCDL : docLinkList){
                        
                        if(eachCDL.isDeleted){
                            deletedLinkIds.add(eachCDL.Id);
                        }else{
                            contentLinkIdList.add(eachCDL.Id);
                        }   
                        
                        if(eachCDL.ContentDocument.isDeleted){
                            deletedDocIds.add(eachCDL.ContentDocumentId);
                            deletedVersionIds.add(eachCDL.ContentDocument.LatestPublishedVersionId);   //If the document is deleted, version also needs to be deleted
                         }else{
                            documentIdList.add(eachCDL.ContentDocumentId); 
                            versionIdList.add(eachCDL.ContentDocument.LatestPublishedVersionId);
                         }
                        }
                }
                
                system.debug(LoggingLevel.WARN,'deletedDocIds = '+deletedDocIds.size());
                system.debug(LoggingLevel.WARN,'deletedVersionIds = '+deletedVersionIds.size());
                system.debug(LoggingLevel.WARN,'deletedLinkIds = '+deletedLinkIds.size());
                
                response.valuemap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink','',contentLinkIdList));
                response.valuemap.add(new INTF_WebServicesDef.SVMXMap('ContentDocument','',documentIdList));
                response.valuemap.add(new INTF_WebServicesDef.SVMXMap('ContentVersion','',versionIdList));
                
                if(deletedVersionIds.size() > 0 || deletedDocIds.size() > 0 || deletedLinkIds.size() > 0 ){
                    INTF_WebServicesDef.SVMXMap deletedVM = new INTF_WebServicesDef.SVMXMap('SAFE_TO_DELETE', 'True');
                    deletedVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentVersion', '', deletedVersionIds));
                    deletedVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocument', '', deletedDocIds));
                    deletedVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink', '', deletedLinkIds));
                    response.valuemap.add(deletedVM);
                }
            
                intQueryLimit -= docLinkList.size();
                if(intQueryLimit <= 0){
                        isCallback = true;
                }
                if(isCallBack){
                        INTF_WebServicesDef.SVMXMap callbackVM = new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'True');
                        callbackVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('CDL_LASTID', String.ValueOf(docLinkList[docLinkList.size()-1].Id)));
                        response.valuemap.add(callbackVM);
                    }
            }
            
        }catch(Exception ex){
            SmaxException customException = new SmaxException(null, ex);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
            response.message = ex.getMessage();
            return response;
        }
        response.eventName = request.eventName;
        response.eventType = request.eventType;
        return response;    
    }
    
    
    public String getFieldNamesForObjects(String objectName, List<SVMXC__ServiceMax_Config_Data__c> svmxConfigList){
        integer intLimitRelationshipFields = 35;
        List<String> lstRefObjToSkip = new List<String>{'PARTNERNETWORKCONNECTION', 'USER', 'FEEDPOST', 'SOLUTION'};
        set<String> referencesToSkipList = new set<String>{'ContentDocument','LatestPublishedVersion','ContentAsset','ExternalDataSource','ContentVersion'};
        List<String> fieldNamesList = new List<String>();
        String strFldNames =  ''; 
        INTF_DataUtilityServices dataUtil = new INTF_DataUtilityServices();
    
        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
        clsObjectDefinition.objectName = objectName;
        
        if(svmxConfigList != null && svmxConfigList.size() != 0){
            for(SVMXC__ServiceMax_Config_Data__c eachSett: svmxConfigList){
                if(eachSett.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET004' && eachSett.SVMXC__Internal_Value__c != null && eachSett.SVMXC__Internal_Value__c != ''){
                    lstRefObjToSkip = eachSett.SVMXC__Internal_Value__c.ToUpperCase().split(',');
                }else if(eachSett.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET013' && eachSett.SVMXC__Internal_Value__c != null && eachSett.SVMXC__Internal_Value__c != '')
                    intLimitRelationshipFields = integer.valueOf(eachSett.SVMXC__Internal_Value__c);
            }
        }
        Set<String> setRefObjToSkip = new Set<String>();
        setRefObjToSkip.addAll(lstRefObjToSkip);
        Set<String> documentFields = new Set<String>();      
        if(objectName == 'ContentDocumentLink'){
                documentFields = dataUtil.getFieldsForFiles(setRefObjToSkip, intLimitRelationshipFields);
        }        
        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition(); 
        if(objDef != NULL){
            for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap){
                if(objProp.key=='FIELDPROPERTY')
                {
                    Integer refFieldCount = 0;
                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap){
                        if( (objectName == 'Attachment' && lstField.value == 'Body') || (objectName == 'ContentVersion' && lstField.value == 'VersionData'))
                        {
                            system.debug(LoggingLevel.WARN, 'Attachment/File Object - do not query Body field');
                        }
                        else
                            fieldNamesList.add(lstField.value);
                            
                        if(refFieldCount == intLimitRelationshipFields)
                            continue;
                            
                        String reference_to = (new INTF_DataUtilityServices()).GetValueForKeyInSVMXMapList('REFERENCETO', lstField.valueMap);
                        if (reference_to != null)
                        {
                            String relationship_name = (new INTF_DataUtilityServices()).GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', lstField.valueMap);
                            if(objectName == 'ContentDocumentLink' && reference_to =='ContentDocument' && relationship_name != NULL){
                                for(string cdlFieldName: documentFields){
                                    fieldNamesList.add(relationship_name+'.'+cdlFieldName);
                                }
                                refFieldCount++;
                            }else if (reference_to == 'Case')
                            {
                                fieldNamesList.add(relationship_name + '.CaseNumber');
                                refFieldCount++;
                            }else if(referencesToSkipList.contains(reference_to) || setRefObjToSkip.contains(reference_to.toUpperCase()) || relationship_name == null){//Added as there is no name field on these reference objects
                                continue;
                            }else{
                                fieldNamesList.add(relationship_name + '.Name');
                                refFieldCount++;
                            }
                        }
                    }
                }
            }
        }
        fieldNamesList = (new COMM_Utils_V2()).checkDuplicateFields(fieldNamesList, objectName);
        strFldNames = clsObjectDefinition.getObjectFieldNames(fieldNamesList);
        return strFldNames;
    }
    
    //submit Document
    public INTF_WebServicesDef.INTF_SFMResponse submitDocumentForFiles(INTF_WebServicesDef.INTF_SFMRequest inputRequest){
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        lstSignatureIds = new List<String>();
        
        List<String> htmlVersionIds = new List<String>();
        List<String> sigVersionIds = new List<String>();
        List<String> attachmentIds = new List<String>();
        List<String> resHTMLIds = new List<String>();
        
        try{
            for(INTF_WebServicesDef.SVMXMap eachVM: inputRequest.valueMap){
                if(eachVM.key == 'HTMLID'){
                    for(INTF_WebServicesDef.SVMXMap innerVM: eachVM.valueMap){
                        if(innerVM.Key == 'ContentVersion' && innerVM.values != null && innerVM.values.size() > 0){
                            htmlVersionIds = innerVM.values;
                        }
                    }
                }else{
                    if(eachVM.key == 'SIGNATURE'){
                        for(INTF_WebServicesDef.SVMXMap innerVM: eachVM.valueMap){
                            if(innerVM.Key == 'ContentVersion' && innerVM.values != null && innerVM.values.size() > 0){
                                sigVersionIds = innerVM.values;
                            }else if(innerVM.Key == 'Attachment' && innerVM.values != null && innerVM.values.size() > 0){
                                attachmentIds = innerVM.values;
                            }
                        }
                    } 
                }   
            }
            
            List<ContentVersion> versionList = [Select Id, ContentDocumentId, FileType, FileExtension, Title from ContentVersion where ID IN: htmlVersionIds ];
            for(integer i = 0; i< versionList.size(); i++){
                if(versionList[i].FileType == 'PDF' || versionList[i].FileExtension == 'PDF' || versionList[i].Title.contains('.pdf')){
                    htmlVersionIds.remove(i);
                    resHTMLIds.add(versionList[i].Id);
                }
            }
            
            INTF_WebServicesDef.SVMXMap HTMLIdsVM = new INTF_WebServicesDef.SVMXMap();  //All files that are already pdf are being sent to the client
            HTMLIdsVM.key = 'HTMLID';
            HTMLIdsVM.values = resHTMLIds;
            response.valueMap.add(HTMLIdsVM);
        
                offlineSubmitDocumentsFiles(htmlVersionIds, sigVersionIds, attachmentIds);
            
            INTF_WebServicesDef.SVMXMap sigIdsVM = new INTF_WebServicesDef.SVMXMap();
            sigIdsVM.key = 'SIGNATURE';        
            sigIdsVM.values = lstSignatureIds;
            response.valueMap.add(sigIdsVM);
        
            //Find the deleted records and return it to the client
            List<string> deleteIds = new List<string>();
            for(ContentVersion cv : [Select Id, ContentDocumentID, ContentDocument.isDeleted from ContentVersion where (Id In: htmlVersionIds OR Id IN: sigVersionIds) AND (IsDeleted = true OR ContentDocument.isDeleted = true) ALL ROWS])
            {
                deleteIds.add(cv.ID); 
            }
            response.valueMap.add(new INTF_WebServicesDef.SVMXMap('DELETE_CV_ID','', deleteIds));
            
            if(attachmentIds.size() > 0 ){
                List<string> deleteAttIds = new List<string>();
                for(Attachment attachToDelete : [Select Id, Body, Name from Attachment where (Id In: attachmentIds) AND IsDeleted = true ALL ROWS])
                {
                    deleteAttIds.add(attachToDelete.Id);
                }
                response.valueMap.add(new INTF_WebServicesDef.SVMXMap('DELETE_ATTACHMENT_ID','', deleteAttIds));
            }
        
            }catch(Exception ex){
            response.success = false;
            response.message = ex.getMessage();
            system.debug(LoggingLevel.WARN, 'Exception = ' + ex.getMessage()+ ' Line is = '+ex.getLineNumber());
        }
        response.success = true;
        return response;
    }
    
    public void offlineSubmitDocumentsFiles(List<String> htmlVersionIds, List<String> sigVersionIds, List<String> sigAttachIds){
            
        Map<String,String> versionDataToIdMap = new Map<String, String>();
        Map<String,ContentVersion> versionToIdMap = new Map<String, ContentVersion>();
        Map<String,String> sigNameAndURLMap = new Map<String, String>();
        Map<String,String> attNameAndURLMap = new Map<String,String>();
        
        List<ContentVersion> htmlVersionList = [select Id, VersionData, Title, ContentDocumentId from ContentVersion where ID IN: htmlVersionIds];
        for(ContentVersion eachCV: htmlVersionList){
            Blob contentBody = eachCV.VersionData;
            versionDataToIdMap.put(eachCV.Id, contentBody.ToString());
            versionToIdMap.put(eachCV.Id,eachCV);
        }
        
        List<ContentVersion> signatureList = [select Id, Title, ContentDocumentId from ContentVersion where ID IN: sigVersionIds ];
        for(ContentVersion eachSig: signatureList){
                sigNameAndURLMap.put(eachSig.Title, '/sfc/servlet.shepherd/version/download/'+ eachSig.Id);
        }
        
        List<Attachment> attachList = [select Id, Name from Attachment where ID IN: sigAttachIds];
        for(Attachment att: attachList){
                 attNameAndURLMap.put(att.Name,'/servlet/servlet.FileDownload?file=' + att.Id);
        }
        system.debug('++++sigNameAndURLMap = '+sigNameAndURLMap);
        system.debug('++++attNameAndURLMap = '+attNameAndURLMap);
        system.debug('++++versionDataToIdMap = '+versionDataToIdMap);
        
         //Parse the versionData
        String document = null;
        ContentVersion version = null;
        for(String eachVerId : versionDataToIdMap.keySet()){
            document = versionDataToIdMap.get(eachVerId);
            version = versionToIdMap.get(eachVerId);
            
            System.debug('before Parsing: ' + document);
            List<String> processedDocument = parseForStyle(document);
            System.debug('after Parsing: ' + processedDocument.get(1));
            
            String styleTag = processedDocument.get(0);  
            document = ReplaceHTMLImagesSrc(processedDocument.get(1), sigNameAndURLMap, attNameAndURLMap); 
            document = '<html><head><style type=\"text/css\">' + styleTag + '</style>' + 
                +' <style>body {font-family: Arial Unicode MS;}</style></head>' + document + '</html>';  
            
            system.debug('+++ VersionData after formatting = '+Blob.valueof(document));
            version.VersionData = Blob.valueof(document);  //TODO: CHECK THIS               
        }
        
        update versionToIdMap.values(); 
        
    }
    
    public String ReplaceHTMLImagesSrc(String htmlContent, Map<String, String> signatureNameIds, Map<string, String> attSigNameIds){
        //for formatting sake, now replace curly braces with svmx identifiers, 
        //here using svmx-open-brace in place of '{' and svmx-close-brace in place of '}'
        htmlContent = htmlContent.replace('{','svmx-open-brace');
        htmlContent = htmlContent.replace('}','svmx-close-brace');
        ParsedHTML parsedHTML = parseHTMLForImages(htmlContent);
        String content = parsedHTML.content;
        Map<integer, String> imageNames = parsedHTML.imageNames;
        integer length = imageNames.keySet().size();
        if(length > 0){
            Map<String, String> mapDocRecs = QueryDocumentObject(imageNames.values());
            System.debug('Image Document Records: ' + mapDocRecs);
            System.debug('Image names in template: ' + imageNames.values());
            
            List<String> finalImageList = new List<String>();
            integer index = 0;string currValue = null;
            string localImageName = null;
            while(index < length){
                localImageName = imageNames.get(index);
                if(mapDocRecs.containsKey(localImageName)){
                    currValue = mapDocRecs.get(localImageName);                 
                }
                else if(signatureNameIds.containsKey(localImageName) || attSigNameIds.containsKey(localImageName))
                {
                        if(signatureNameIds.get(localImageName) != NULL)
                            currValue = signatureNameIds.get(localImageName);
                        else if(attSigNameIds.get(localImageName) != NULL){
                            currValue = attSigNameIds.get(localImageName);
                        }   
                    
                    system.debug('Current Signature Value: ' + currValue);
                    List<string> lstSigIds = currValue.split('=');
                    if(lstSigIds != null && lstSigIds.size() == 2)
                    {
                        system.debug('Signature Id Used: ' + lstSigIds[1]);
                        lstSignatureIds.add(lstSigIds[1]);  //Check this
                    }
                }
                else{
                    currValue = '';
                }
                finalImageList.add('\'' + currValue + '\'');
                index++;
            }
            //System.debug('Parsed Content: ' + content);
            //System.debug('Images List: ' + finalImageList);
            //String.Format will not handle the quote gracefully, replace all the quote with svmx-handle-quote
            String temp = content.replace('\'','svmx-handle-quote'); 
            temp = String.Format(temp ,finalImageList);
            content = temp.replace('svmx-handle-quote', '\'');      
        }
        //now replace the identifiers to curly brackets
        System.Debug('Content: ' + content);
        content = content.replace('svmx-open-brace', '{');
        content = content.replace('svmx-close-brace', '}');
        System.Debug('Final Content: ' + content);
        return content;
    } 
    
    
    public List<String> parseForStyle(String document){
        String style = '';
        List<String> ret = new List<String>();
        
        if(document != null){
            try{
                integer startIndex = document.indexOf('<style'), contentStartIndex = 0;
                if(startIndex != -1){
                    contentStartIndex = document.indexOf('>', startIndex) + 1;
                }
                
                integer endIndex = document.indexOf('</style>'), contentEndIndex = 0;
                if(endIndex != -1){
                    contentEndIndex = endIndex;
                }
                
                if(startIndex != -1 && endIndex != -1){
                    endIndex = endIndex + 8;
                    style = document.substring(contentStartIndex, contentEndIndex);
                    document = document.substring(0, startIndex) + document.substring(endIndex, document.length());
                
                    System.debug(' *** ' + style + ' *** ' + document);
                    System.debug(' *** ' + contentStartIndex + ' *** ' + contentEndIndex);
                }
            }catch(Exception e){}
        }
        
        ret.add(style);
        ret.add(document);
        return ret;
    }
     
    public class ParsedHTML{
        public string content;
        public Map<Integer, String> imageNames = null;
        ParsedHTML(String content, Map<Integer, String> imageNames){
            this.content = content;
            this.imageNames = imageNames;
        }
    }
     
    public ParsedHTML parseHTMLForImages(String htmlContent){
        String localHTMLContent = htmlContent, imgExpression, parsedContent = '', imageName, imgContent = '', imgSeperator = '';
        integer startIndex, endIndex, dataIndex, srcIndex, uniqueIndex = 0;
        integer startImageNameIndex, endImageNameIndex;
        Map<integer, String> imageNames = new Map<integer, String>();
        while(true){
            startIndex = localHTMLContent.indexOfIgnoreCase('<img');            
            if(startIndex != -1){
                endIndex = localHTMLContent.indexOf('>', startIndex);
                parsedContent = parsedContent + localHTMLContent.substring(0, startIndex + 4);
                imgContent = localHTMLContent.substring(startIndex + 4, endIndex + 1);
                dataIndex = localHTMLContent.indexOfIgnoreCase('svmx-data', startIndex);
                srcIndex = localHTMLContent.indexOfIgnoreCase('src', startIndex);
                System.debug('endIndex: ' + endIndex + ' ,dataIndex: ' + dataIndex);
                if(dataIndex != -1 && endIndex > dataIndex){
                    //now try to get image name
                    startImageNameIndex = dataIndex + 11;
                    imgSeperator = localHTMLContent.substring(startImageNameIndex-1, startImageNameIndex);
                    System.debug('Image Seperator: ' + imgSeperator);
                    if(imgSeperator == '\"' || imgSeperator == '\''){
                        endImageNameIndex = localHTMLContent.indexOf(imgSeperator, startImageNameIndex);
                        imageName = localHTMLContent.substring(dataIndex + 11, endImageNameIndex);
                        imageNames.put(uniqueIndex, imageName);
                        parsedContent = parsedContent + ' src={'+ uniqueIndex +'} ';
                        imgContent = imgContent.replace('src','src1');
                        uniqueIndex++;
                    }                    
                }
                parsedContent = parsedContent + imgContent;
                localHTMLContent = localHTMLContent.length() > (endIndex + 1)? localHTMLContent.substring(endIndex + 1) : '';
                
            }
            else{
                break;
            }           
        }
        parsedContent = parsedContent + localHTMLContent;
        return new ParsedHTML(parsedContent, imageNames);
    } 
    
    public Map<String,String> QueryDocumentObject(List<String> uniqueNames){   //TODO: CHECK THIS
        List<Document> lstDocs = [select Id, DeveloperName from Document where DeveloperName In: uniqueNames];
        Map<String, String> mapDocRecs = new Map<String, String>();
        for(Document curr : lstDocs){
            mapDocRecs.put(curr.DeveloperName, '/servlet/servlet.FileDownload?file=' + curr.Id);
        }
        return mapDocRecs;
    } 
    
    //GENERATE OPDOC:
    public INTF_WebServicesDef.INTF_SFMResponse generatePdfForFiles(INTF_WebServicesDef.INTF_SFMRequest request, String svmxGrpProfileId){
            INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
            List<String> htmlCDLIds = new List<String>();
            List<String> sigCDIDs = new List<String>();
            String processID = '';
            String networkID = '';
            Boolean isVersionEnabled = false;
            for(INTF_WebServicesDef.SVMXMap eachVM : request.ValueMap){
                if(eachVM.Key == 'HTMLID' && eachVM.values.size()>0){
                    htmlCDLIds = eachVM.values;
                    for(INTF_WebServicesDef.SVMXMap innerVM : eachVM.ValueMap){
                        if(innerVM.key == 'PROCESS_ID' && !String.isBlank(innerVM.value)){
                            processID = innerVM.value;
                        }else if(innerVM.key == 'VERSION_ENABLED' && !String.isBlank(innerVM.value)){
                            isVersionEnabled = boolean.valueOf(innerVM.value);
                        }
                    }
                }else if(eachVM.Key == 'SIGNATURE'){
                    for(INTF_WebServicesDef.SVMXMap innerVM : eachVM.ValueMap){
                        if(innerVM.key == 'ContentDocument' && innerVM.values.size() > 0){
                                sigCDIDs = innerVM.values;
                        }
                    }
                }else if(eachVM.Key == 'NETWORK_ID'){
                    for(INTF_WebServicesDef.SVMXMap innerVM : eachVM.ValueMap){
                        if(innerVM.key == 'NetworkID' && !String.isBlank(innerVM.value)){
                                networkID = innerVM.value;
                        }
                    }
                }
            }
            
            if(htmlCDLIds.size() > 0){
                
                INTF_WebServicesDef.INTF_SFMResponse pdfResponse = createPDFForFiles(htmlCDLIds, isVersionEnabled, processID, svmxGrpProfileId, networkID);
                system.debug(LoggingLevel.Debug,('****in createPDF pdfResponse'+pdfResponse));
                system.debug(LoggingLevel.Debug,('****Success'+pdfResponse.success));
                if(pdfResponse.success){
                    
                    //PDF generation was successful - delete the signatures
                    if(sigCDIDs.size() > 0){
                        List<ContentDocument> sigDocuments = [select ID from ContentDocument where ID IN: sigCDIDs];
                        system.debug(LoggingLevel.Debug,('****Deleted'+sigDocuments));
                        delete sigDocuments;
                    }
                    
                    INTF_WebServicesDef.SVMXMap pdfFile = new INTF_WebServicesDef.SVMXMap();
                    pdfFile.Key = 'FINAL_PDF';
                    pdfFile.valueMap.addAll(pdfResponse.valueMap);
                    response.valueMap.add(pdfFile);
                    
                    INTF_WebServicesDef.SVMXMap sigVM = new INTF_WebServicesDef.SVMXMap();
                    sigVM.Key = 'SIGNATURE';
                    sigVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocument','',sigCDIDs));
                    response.valueMap.add(sigVM);
                    
                    INTF_WebServicesDef.SVMXMap htmlVM = new INTF_WebServicesDef.SVMXMap();
                    htmlVM.Key = 'HTML';
                    htmlVM.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink','',htmlCDLIds));
                    response.valueMap.add(htmlVM);
                    
                }
            }
            response.success = true;
            response.EventName = request.EventName;
            response.EventType = request.EventType;
            
            system.debug(LoggingLevel.Debug,('****Final response'+response));
            return response;
        
    }   
    
    public INTF_WebServicesDef.INTF_SFMResponse createPDFForFiles(List<String> htmlCDLIds, boolean isVersionEnabled, string processID, String  svmxGrpProfileId, String networkID){
            
            INTF_WebServicesDef.INTF_SFMResponse pdfResponse = new INTF_WebServicesDef.INTF_SFMResponse();
            
            try{
                //ContentDocumentLink related to HTML File
                List<ContentDocumentLink> lstCDL = [ select Id, ContentDocumentId, LinkedEntityID, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.PathOnClient, ContentDocument.LatestPublishedVersion.Title from ContentDocumentLink where ID IN: htmlCDLIds];
            
                if(lstCDL != NULL && lstCDL[0]!= NULL){
                    
                    String pdfVersionId, pdfDocId, pdfLinkId = '';
                    boolean versionAvailable = false;
                    PageReference pageRef = null;Blob blobPdf  = null;
                    pageRef = new PageReference('/sfc/servlet.shepherd/version/download/' + lstCDL[0].ContentDocument.LatestPublishedVersionId);
                    blobPdf = !Test.isRunningTest() ? pageRef.getContentAsPDF() : Blob.valueOf('Test content');   
                    system.debug('After PDF generation = '+blobPdf);
                    String existingDocID = '';
                    String userID = UserInfo.getUserId();
                    Boolean userHasAccess = false;
                    String parentRecordID = lstCDL[0].LinkedEntityId;
                    system.debug(LoggingLevel.WARN,'parentRecordID = '+parentRecordID);
                    
                    //Insert new contentVersion for PDF
                    ContentVersion pdfVersion = new ContentVersion();
                    if(isVersionEnabled && !String.isBlank(processID) && !String.isBlank(parentRecordID)){  //If versioning is enabled get the ContentDocumentID of the contentVersion with this process ID and create new version on the same Doc
                        //List<ContentVersion> versionlist = [Select ID, ContentDocumentID from ContentVersion where SVMXC__SM_Process_ID__c =: processID];
                        //List<ContentDocumentLink> processCDLList = [select Id, ContentDocumentID, LinkedEntityId from ContentDocumentLink where (LinkedEntityID =:parentRecordID OR LinkedEntityID =: userID) AND ContentDocument.LatestPublishedVersion.SVMXC__SM_Process_ID__c =: processID ];
                        List<ContentDocumentLink> processCDLList = [select Id, ContentDocumentID, LinkedEntityId from ContentDocumentLink where (LinkedEntityID =: userID AND ContentDocument.LatestPublishedVersion.SVMXC__SM_Process_ID__c =: processID )];
                        for(ContentDocumentLink eachCDL: processCDLList){
                             if(eachCDL.LinkedEntityID == userID){
                                userHasAccess = true;
                                existingDocID = eachCDL.ContentDocumentId;
                             }
                        }
                        
                        if(userHasAccess && existingDocID != ''){  //IF there's an existing version for this processID and user - Map the contentDocumentID
                            pdfVersion.ContentDocumentId = existingDocID;
                            versionAvailable = true;
                        }
                    }
                    pdfVersion.SVMXC__SM_Process_ID__c = processID;
                    pdfVersion.Pathonclient = lstCDL[0].ContentDocument.LatestPublishedVersion.PathOnClient.replace('.html','.pdf');
                    pdfVersion.VersionData = blobPdf;
                    pdfVersion.Title = lstCDL[0].ContentDocument.LatestPublishedVersion.Title.replace('.html','.pdf');
                    if(networkID != ''){
                        Boolean communitiesEnabled = ContentVersion.sObjectType.getDescribe().fields.getMap().containsKey( 'NetworkId' );
                        if(communitiesEnabled){
                            pdfVersion.put('NetworkId', networkID); //include the network Id for community users
                        }
                    }
                    pdfVersion.IsMajorVersion = false; 
                    if(!versionAvailable){
                        pdfVersion.firstPublishLocationId = parentRecordID; //New version - map the firstPublishLocationId
                    }
                    Database.Saveresult cvInsertResult = Database.insert(pdfVersion);
                    if(cvInsertResult.isSuccess()){
                        pdfVersionId = cvInsertResult.getId();
                    }
                    
                    List<SVMXC__ServiceMax_Config_Data__c> svmxConfigList = (new INTF_ConfigSync()).getSettings(null, null, new set<string>{'IPAD018_SET013','IPAD018_SET004'}, svmxGrpProfileId);
            
                    //Query the CV to be sent to the client
                    List<ContentVersion> pdfVersionList = [select Id, ContentDocumentId from ContentVersion where ID =: pdfVersionId ];
                    Database.Saveresult cdlSaveResult;
                    if(pdfVersionList[0] != NULL && pdfVersionList[0].ContentDocumentId != NULL){
                        
                        pdfDocId = pdfVersionList[0].ContentDocumentId;
                        system.debug(LoggingLevel.Debug,('****pdfDocId'+pdfDocId));
                        if(!versionAvailable){
                             //insert ContentDocumentLink in case it's the first time this version is being created
                            ContentDocumentLink pdfCDL = new ContentDocumentLink();
                            pdfCDL.LinkedEntityId = parentRecordID;
                            pdfCDL.ContentDocumentId = pdfDocId;
                            pdfCDL.ShareType = 'I';
                            pdfCDL.Visibility = 'AllUsers';   
                            
                            try{
                                    cdlSaveResult = Database.insert(pdfCDL);
                                    pdfLinkId = cdlSaveResult.getId(); 
                            }catch(Exception ex){
                                    system.debug(LoggingLevel.WARN, 'Exception = ' + ex.getMessage()+ ' Line is = '+ex.getLineNumber());
                            }
                            
                        }
                    
                        //Query CDL inserted for PDF
                        String fieldNamesForLink = getFieldNamesForObjects('ContentDocumentLink',svmxConfigList);
                        List<ContentDocumentLink> pdfLinkList = Database.query('Select '+ fieldNamesForLink + ' FROM ContentDocumentLink where ContentDocumentId =: pdfDocId AND LinkedEntityId =: parentRecordID ');
                        pdfResponse.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink',json.serialize(pdfLinkList[0])));
                        
                        pdfResponse.success = true;
                        system.debug(LoggingLevel.Debug,('****pdfResponse'+pdfResponse));
                    }
                    
                    //delete the document associated with the HTML
                    List<ContentDocument> oldHtmlDoc = [select ID from ContentDocument where ID =: lstCDL[0].ContentDocumentId];
                    delete oldHtmlDoc;
                    
                }
            }catch(Exception ex){
                pdfResponse.success = false;
                system.debug(LoggingLevel.WARN, 'Exception = ' + ex.getMessage()+ ' Line is = '+ex.getLineNumber());
            }
            
            system.debug(LoggingLevel.Debug,('****after forming response pdfResponse'+pdfResponse));
            return pdfResponse;
        }

}