global virtual class SFMTransactionSync
{
    global static SVMXC__SM_SFMTransactionSync__c singleTxnRec;
    global static final String INSERT_OPERATION = 'INSERT';
    global static final String DELETE_OPERATION = 'DELETE';
    private static map<String, String> mapClientDetails = new map<String, String>();
    global Map<String, Set<String>> recordIdsPerObjectMap = new Map<String, Set<String>>();
    String svmxGrpProfileId = NULL;
    
    global virtual INTF_WebServicesDef.INTF_Response updateRecord(INTF_WebServicesDef.INTF_Request request, INTF_WebServicesDef.INTF_Response response)
    {
        response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        map<String, String> mapLocalIdToSFId = new map<String, String>();
        INTF_WebServicesDef.SVMXMap errorRecords = new INTF_WebServicesDef.SVMXMap('ERROR', '');
        list<INTF_WebServicesDef.SVMXMap> lstErrorRecords = new list<INTF_WebServicesDef.SVMXMap>();
        boolean isFieldAccessIssue = false;
        map<String, String> mapSavedLocalIdToSFId = new map<String, String>();
        
        singleTxnRec = getSFMTxnCacheRec(request.groupId, request.userId, request.profileId, INSERT_OPERATION);
        
        if(singleTxnRec.SVMXC__SM_Local_and_Platform_Id__c != null && singleTxnRec.SVMXC__SM_Local_and_Platform_Id__c != '')
            mapSavedLocalIdToSFId = (map<String, String>)JSON.deserialize(singleTxnRec.SVMXC__SM_Local_and_Platform_Id__c, map<String, String>.Class);
        
        system.debug(LoggingLevel.WARN, 'singleTxnRec = ' + singleTxnRec);
                
        for(INTF_WebServicesDef.SVMXMap objSVXMMap : request.valueMap) 
        {
            if(objSVXMMap.key == 'Parent_Object_Name' || objSVXMMap.key == 'Child_Object_Name')
            {
                system.debug(LoggingLevel.WARN, 'objSVXMMap = ' + objSVXMMap);
                List<sObject> sObjListToUpdate = new List<sObject>();
                List<sObject> sObjListToInsert = new List<sObject>();
                INTF_GetObjectDefinition objectDefinition = new INTF_GetObjectDefinition();
                objectDefinition.objectName = objSVXMMap.value;
                INTF_WebServicesDef.SVMXMap eachObjectResponse = new INTF_WebServicesDef.SVMXMap(objSVXMMap.key, objSVXMMap.value);
                
                INTF_WebServicesDef.SVMXMap objectDescribeInfo = objectDefinition.INTF_GetObjectDefinition();
                Set<String> setUpdatableFieldNames = new Set<String>();
                map<String, String> mapFieldAndItsType = new Map<String,String>();
                
                if(objectDescribeInfo != NULL) 
                {
                    for(INTF_WebServicesDef.SVMXMap objProp : objectDescribeInfo.valueMap)
                    {
                        if (objProp.key=='FIELDPROPERTY')
                        {
                            for(INTF_WebServicesDef.SVMXMap lstField : objProp.valueMap)
                            {
                                for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                {
                                    if(fldObj.key == 'TYPE')
                                        mapFieldAndItsType.put(lstField.value, fldObj.value);
                                    if(fldObj.key == 'UPDATEABLE' && fldObj.value == 'true')
                                        setUpdatableFieldNames.add(lstField.value);
                                }
                            }
                        }
                    }
                }
                sObject sObjToUpdate, sObjToInsert;
                List<String> localIds = new List<String>();
                map<String, String> mapFieldToValue = new map<String, String>();
                List<INTF_WebServicesDef.SVMXMap> idAlreadyExists = new List<INTF_WebServicesDef.SVMXMap>();
                
                for(INTF_WebServicesDef.SVMXMap eachRecord : objSVXMMap.valueMap){
                    mapFieldToValue = (Map<String, String>)JSON.deserialize(eachRecord.value, Map<String, String>.Class);
                    
                    if(eachRecord.key == 'RECORD_ID'){
                        if(mapFieldToValue != NULL && !mapFieldToValue.KeySet().isEmpty()){
                            sObjToUpdate = Schema.getGlobalDescribe().get(objSVXMMap.value).newSObject(mapFieldToValue.get('Id'));
                            for(String eachField : mapFieldToValue.keySet())
                                sObjToUpdate = createSObject(sObjToUpdate, mapFieldAndItsType, eachField, mapFieldToValue.get(eachField));
                         
                            sObjListToUpdate.add(sObjToUpdate);
                        }    
                    }
                    else
                    {
                        if(mapSavedLocalIdToSFId.containsKey(eachRecord.key))
                            idAlreadyExists.add(new INTF_WebServicesDef.SVMXMap(eachRecord.key, mapSavedLocalIdToSFId.get(eachRecord.key)));
                        else{   
                            localIds.add(eachRecord.key);
                            if(mapFieldToValue != NULL && !mapFieldToValue.KeySet().isEmpty()){
                                sObjToInsert = Schema.getGlobalDescribe().get(objSVXMMap.value).newSObject();
                                for(String eachField : mapFieldToValue.keySet())
                                    sObjToInsert = createSObject(sObjToInsert, mapFieldAndItsType, eachField, mapFieldToValue.get(eachField));
                                
                                sObjListToInsert.add(sObjToInsert);
                            }
                        }
                    }
                }
                system.debug(LoggingLevel.WARN, 'sObject list to Update = ' + sObjListToUpdate);
                system.debug(LoggingLevel.WARN, 'sObject list to Insert = ' + sObjListToInsert);

                //update records            
                list<String> lstUpdatedIds = new list<String>();
                if(sObjListToUpdate != null && sObjListToUpdate.size() > 0){
                    Database.SaveResult[] updateResult;
                    try{
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(sObjListToUpdate, COMM_SecurityUtils.Access.Updateable)){
                            updateResult = Database.update(sObjListToUpdate, false);
                        }else{
                            isFieldAccessIssue = true;
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                    }
                    catch(DmlException e){
                        if(isFieldAccessIssue){
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                        }else{
                            lstErrorRecords.add(new INTF_WebServicesDef.SVMXMap(objSVXMMap.value, e.getMessage()));  
                        } 
                    }
                    finally{
                        if(updateResult != null){
                            Integer i=0;
                            for(Database.SaveResult resultIds : updateResult){
                                if(resultIds.isSuccess()){
                                    lstUpdatedIds.add(resultIds.getId());
                                    system.debug(LoggingLevel.WARN, 'Update is Successfull');
                                }
                                else{
                                    system.debug(LoggingLevel.WARN, 'Error in Update');   
                                    Database.Error[] err = resultIds.getErrors();
                                    INTF_WebServicesDef.SVMXMap error = new INTF_WebServicesDef.SVMXMap(objSVXMMap.value, err[0].getMessage());
                                    error.valueMap.add(new INTF_WebServicesDef.SVMXMap('', String.valueOf(sObjListToUpdate[i].Id)));
                                    lstErrorRecords.add(error);
                                }
                                i++;
                            }
                        }
                    }
                    eachObjectResponse.valueMap.add(new INTF_WebServicesDef.SVMXMap('UPDATED_IDS', '', lstUpdatedIds));
                }
                
                //Insert new records
                INTF_WebServicesDef.SVMXMap insertedIds = null;
                if(sObjListToInsert != null && sObjListToInsert.size() > 0){
                    Database.SaveResult[] insertResult;
                    insertedIds = new INTF_WebServicesDef.SVMXMap('INSERTED_IDS', '');
                    try{
                        if(COMM_SecurityUtils.getInstance().verifyFieldAccess(sObjListToInsert, COMM_SecurityUtils.Access.Createable)){
                            insertResult = Database.insert(sObjListToInsert, false);
                        }else{
                            isFieldAccessIssue = true;
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }   
                    }
                    catch(DmlException e){
                        if(isFieldAccessIssue){
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + System.label.COMM001_TAG142 ));
                        }else{
                            lstErrorRecords.add(new INTF_WebServicesDef.SVMXMap(objSVXMMap.value, e.getMessage()));  
                        } 
                    }
                    finally{
                        if(insertResult != null){
                            Integer i=0;
                            for(Database.SaveResult resultIds : insertResult){
                                if(resultIds.isSuccess()){
                                    insertedIds.valueMap.add(new INTF_WebServicesDef.SVMXMap(localIds[i], resultIds.getId()));
                                    mapLocalIdToSFId.put(localIds[i], resultIds.getId());
                                    system.debug(LoggingLevel.WARN, 'Insert is Successfull');
                                    
                                }
                                else{
                                    system.debug(LoggingLevel.WARN, 'Error in Update');   
                                    Database.Error[] err = resultIds.getErrors();
                                    INTF_WebServicesDef.SVMXMap error = new INTF_WebServicesDef.SVMXMap(objSVXMMap.value, err[0].getMessage());
                                    error.valueMap.add(new INTF_WebServicesDef.SVMXMap(localIds[i], localIds[i]));
                                    lstErrorRecords.add(error);
                                }
                                i++;
                            }
                        }
                    }
                    eachObjectResponse.valueMap.add(insertedIds);
                }
                system.debug(LoggingLevel.WARN, 'idAlreadyExists = ' + idAlreadyExists);
                if(idAlreadyExists != null && idAlreadyExists.size() > 0){
                    if(insertedIds == null)
                        insertedIds = new INTF_WebServicesDef.SVMXMap('INSERTED_IDS', '');
                    insertedIds.valueMap.addAll(idAlreadyExists);
                    eachObjectResponse.valueMap.add(insertedIds);
                }
                singleTxnRec.SVMXC__SM_Local_and_Platform_Id__c = JSON.serialize(mapLocalIdToSFId);
                singleTxnRec.SVMXC__SM_Operation_Type__c = INSERT_OPERATION;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(singleTxnRec, COMM_SecurityUtils.Access.Createable)){
                   Database.UpsertResult saveCache = Database.upsert(singleTxnRec);
                }else{
                    isFieldAccessIssue = true;
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                response.valueMap.add(eachObjectResponse);
            }
        }
        
        errorRecords.valueMap = lstErrorRecords;
        response.valueMap.add(errorRecords);
        system.debug(LoggingLevel.WARN, 'response is = ' + response);
        return response;
    }

    //Method to perform Tx_Fetch on the records that were inserted/updated as part of custom webservice
    global virtual INTF_WebServicesDef.INTF_Response getRecord(INTF_WebServicesDef.INTF_Response response)
    {
        system.debug(LoggingLevel.WARN, 'response getRecord = ' + response);
        Integer intLimitRelationshipFields = 35;
        String strValue = '';
        set<String> setRefObjToSkip = new set<String>();
        INTF_ConfigSync configObj = new INTF_ConfigSync();
        
        string svmxGrpProfId = configObj.getSVMXGrpProfileId(userinfo.getProfileId());
        List<SVMXC__ServiceMax_Config_Data__c> lstSettings = configObj.getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET004', 'IPAD018_SET013'}, svmxGrpProfId);
        if(lstSettings != null && lstSettings.size() > 0){
            for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings){
                if(cnf.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET004' && cnf.SVMXC__Internal_Value__c != null)
                    strValue = cnf.SVMXC__Internal_Value__c;
                else if(cnf.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET013' && cnf.SVMXC__Internal_Value__c != null)
                    intLimitRelationshipFields = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
            }
        }
        
        list<String> lstValue = new list<String>();
        lstValue = strValue.split(',');
        if(lstValue.size() > 0){
            for(Integer i = 0; i < lstValue.size(); i++)
                setRefObjToSkip.add(lstValue[i].toUpperCase());
        }
        else{                    
            setRefObjToSkip.add('PARTNERNETWORKCONNECTION');
            setRefObjToSkip.add('USER');
            setRefObjToSkip.add('FEEDPOST');
            setRefObjToSkip.add('SOLUTION');
        }
        
        for(INTF_WebServicesDef.SVMXMap responseResult : response.valueMap){
            system.debug(LoggingLevel.WARN, 'responseResult = ' + responseResult);
            
            if(responseResult.key == 'Parent_Object_Name' || responseResult.key == 'Child_Object_Name'){
                INTF_GetObjectDefinition objectDefinition = new INTF_GetObjectDefinition();
                objectDefinition.objectName = responseResult.value;
                
                list<String> lstIds = new List<String>();
                for(INTF_WebServicesDef.SVMXMap idsResponse : responseResult.valueMap){
                    if(idsResponse.key == 'UPDATED_IDS'){
                        lstIds.addAll(idsResponse.values);
                    }    
                    if(idsResponse.key == 'INSERTED_IDS'){
                        for(INTF_WebServicesDef.SVMXMap insertedIds : idsResponse.valueMap)
                        lstIds.add(insertedIds.value);
                    }
                }              
            
                
                INTF_WebServicesDef.SVMXMap objDef = objectDefinition.INTF_GetObjectDefinition(); 
                List<String> lstFields = new List<String>();
                if(objDef != NULL) 
                {
                    for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                    {
                        if(objProp.key == 'FIELDPROPERTY')
                        {
                            Integer refFieldCount = 0;
                           for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                           {
                                lstFields.add(lstField.value);
                                if(refFieldCount == intLimitRelationshipFields)
                                    continue;
                                String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', lstField.valueMap);
                                if(reference_to != null)
                                {
                                    String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', lstField.valueMap);
                                    if(reference_to == 'Case'){
                                        lstFields.add(relationship_name + '.CaseNumber');
                                        refFieldCount++;
                                    }
                                    else if (setRefObjToSkip.contains(reference_to.toUpperCase()) || relationship_name == null)
                                        continue;
                                    else{
                                        lstFields.add(relationship_name + '.Name');
                                        refFieldCount++;
                                    }
                                }
                            }
                        }
                    }
                }
                lstFields = (new COMM_Utils_V2()).checkDuplicateFields(lstFields, responseResult.value); //Remove duplicate API Fields
                String strFldNames =  objectDefinition.getObjectFieldNames(lstFields);
                
                system.debug(LoggingLevel.WARN, 'Heap size before querying records = ' + Limits.getHeapSize());
                List<Sobject> lstsObjectRecords = Database.query('Select ' + strFldNames + ' FROM '+ responseResult.value + ' WHERE Id IN :lstIds');
                system.debug(LoggingLevel.WARN, 'Heap size after querying records = ' + Limits.getHeapSize());
                
                responseResult.valueMap.add(new INTF_WebServicesDef.SVMXMap('Record', JSON.serialize(lstsObjectRecords)));
            }
        }
        return response;
    }
    
    public SVMXC__SM_SFMTransactionSync__c getSFMTxnCacheRec(String groupId, String userId, String profileId, string operationType){
        //List<SVMXC__SM_SFMTransactionSync__c> lstSFMTxnRecs = [Select SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Local_and_Platform_Id__c, SVMXC__SM_User_Id__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Operation_Type__c from SVMXC__SM_SFMTransactionSync__c where SVMXC__SM_Client_Sync_Request_Id__c = :groupId and SVMXC__SM_Operation_Type__c = :INSERT_OPERATION and SVMXC__SM_User_Id__c = :userId and SVMXC__SM_Device_UDID__c = :profileId];
        //List<SVMXC__SM_SFMTransactionSync__c> lstSFMTxnRecs = [Select SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Local_and_Platform_Id__c, SVMXC__SM_User_Id__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Operation_Type__c from SVMXC__SM_SFMTransactionSync__c where SVMXC__SM_Operation_Type__c = :INSERT_OPERATION and SVMXC__SM_User_Id__c = :userId and SVMXC__SM_Device_UDID__c = :profileId];
        List<SVMXC__SM_SFMTransactionSync__c> lstSFMTxnRecs = [Select SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Local_and_Platform_Id__c, SVMXC__SM_User_Id__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Operation_Type__c from SVMXC__SM_SFMTransactionSync__c where SVMXC__SM_Operation_Type__c = :operationType and SVMXC__SM_User_Id__c = :userId and SVMXC__SM_Device_UDID__c = :profileId];
        if(lstSFMTxnRecs != null && lstSFMTxnRecs.size() > 0){
            if(lstSFMTxnRecs[0].SVMXC__SM_Client_Sync_Request_Id__c != groupId){
                singleTxnRec = lstSFMTxnRecs[0];
                singleTxnRec.SVMXC__SM_Local_and_Platform_Id__c = '';
                singleTxnRec.SVMXC__SM_Client_Sync_Request_Id__c = groupId;
                singleTxnRec.SVMXC__SM_User_Id__c = userId;
                singleTxnRec.SVMXC__SM_Device_UDID__c = profileId;
            }
            else{
                singleTxnRec = lstSFMTxnRecs[0];
            }
        }
        else{
            singleTxnRec = new SVMXC__SM_SFMTransactionSync__c();
            singleTxnRec.SVMXC__SM_Client_Sync_Request_Id__c = groupId;
            singleTxnRec.SVMXC__SM_User_Id__c = userId;
            singleTxnRec.SVMXC__SM_Device_UDID__c = profileId;
        }
        return singleTxnRec;
    }
    
    public SVMXC__SM_Request_Cache__c getRecFromCache(String groupId, String userId, String deviceId){
        //Query the Inserted/deleted Ids saved in request cache
        
        SVMXC__SM_Request_Cache__c singleCacheRec;
        List<SVMXC__SM_Request_Cache__c> cacheRecList = [Select Id, SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c, SVMXC__SM_Question_Bank_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :userId AND SVMXC__SM_Device_UDID__c =: deviceId];
        
        if(cacheRecList != null && cacheRecList.size() >= 1){
            if(cacheRecList[0].SVMXC__SM_Client_Sync_Request_Id__c != groupId){
                //make all txn fields blank or null
                singleCacheRec = cacheRecList[0];
                singleCacheRec.SVMXC__SM_User_Id__c = userId;
                singleCacheRec.SVMXC__SM_Device_UDID__c = deviceId;
                singleCacheRec.SVMXC__SM_Client_Sync_Request_Id__c = groupId;
                singleCacheRec.SVMXC__SM_Application_Filters__c = '';
                singleCacheRec.SVMXC__SM_Application_Name__c = '';
                singleCacheRec.SVMXC__SM_Application_Version__c = '';
                singleCacheRec.SVMXC__SM_Checklist_Wizard_Objects__c = '';
                singleCacheRec.SVMXC__SM_Device_Type__c = '';
                singleCacheRec.SVMXC__SM_Doc_Template_IDs__c = '';
                singleCacheRec.SVMXC__SM_Download_Criteria_Object_Definitions__c = '';
                singleCacheRec.SVMXC__SM_Download_Criteria_Object_List__c = '';
                singleCacheRec.SVMXC__SM_Expression_IDs__c = '';
                singleCacheRec.SVMXC__SM_Group_Profile_Id__c = '';
                singleCacheRec.SVMXC__SM_Mobile_Config_Settings__c = '';
                singleCacheRec.SVMXC__SM_Object_Access__c = '';
                singleCacheRec.SVMXC__SM_Object_Definitions__c = '';
                singleCacheRec.SVMXC__SM_Page_Layout_IDs__c = '';
                singleCacheRec.SVMXC__SM_Picklist_Definitions__c = '';
                singleCacheRec.SVMXC__SM_Settings__c = '';
                singleCacheRec.SVMXC__SM_SFM_Mappings__c = '';
                singleCacheRec.SVMXC__SM_SFM_Process_IDs__c = '';
                singleCacheRec.SVMXC__SM_SFM_Translations__c = '';
                singleCacheRec.SVMXC__SM_SFM_Wizard_SFM_Ids__c = '';
                singleCacheRec.SVMXC__SM_SFW_Translations__c = '';
                singleCacheRec.SVMXC__SM_SOQL_Query__c = '';
                singleCacheRec.SVMXC__SM_Question_Bank_IDs__c = '';
                singleCacheRec.SVMXC__SM_Event_What_IDs__c = '';
                }else{
                    singleCacheRec = cacheRecList[0];
                }
        }else{
            //create new request cache record for this user and device UDID
            singleCacheRec = new SVMXC__SM_Request_Cache__c();
            singleCacheRec.SVMXC__SM_User_Id__c = userId;
            singleCacheRec.SVMXC__SM_Device_UDID__c = deviceId;
            singleCacheRec.SVMXC__SM_Client_Sync_Request_Id__c = groupId;
        }
        
        return singleCacheRec;
        
        /*if(singleTxnRec.SVMXC__SM_Object_Name__c != NULL && singleTxnRec.SVMXC__SM_Object_Name__c != ''){
                 mapOperationToIds = (map<String, map<String, String>>)JSON.deserialize(singleCacheRec.SVMXC__SM_Object_Name__c, map<String, map<String, String>>.Class);
        }
        
        if(mapOperationToIds != NULL && mapOperationToIds.get(operationType) != NULL){
                cachedRecordsIDMap = mapOperationToIds.get(operationType);
        }
        return cachedRecordsIDMap;*/
    }
    
    private sObject createSObject(sObject sObj, map<String,String> mapFieldAndItsType, String strFieldName, String strFieldValue){
         if(strFieldValue == null || strFieldValue == '')
            sObj.put(strFieldName, null);
        else
        {
            if(mapFieldAndItsType.get(strFieldName) == 'DATETIME')
            {
                strFieldValue = strFieldValue.replace('T', ' ');
                strFieldValue = strFieldValue.replace('Z', ' ');
                sObj.put(strFieldName, Datetime.valueOfGmt(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'DATE')
                sObj.put(strFieldName, Date.valueOf(strFieldValue));
            else if(mapFieldAndItsType.get(strFieldName) == 'TIME'){
                //do nothing as we do not support time fields   
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'BOOLEAN')
                sObj.put(strFieldName, Boolean.valueOf(strFieldValue));
            else if(mapFieldAndItsType.get(strFieldName) == 'DOUBLE')
                sObj.put(strFieldName, decimal.valueOf(strFieldValue));
            else if(mapFieldAndItsType.get(strFieldName) == 'DECIMAL' || mapFieldAndItsType.get(strFieldName) == 'CURRENCY' || mapFieldAndItsType.get(strFieldName) == 'PERCENT')
                sObj.put(strFieldName, decimal.valueOf(strFieldValue));
            else if(mapFieldAndItsType.get(strFieldName) == 'INTEGER')
                sObj.put(strFieldName, Integer.valueOf(strFieldValue));
            else
                sObj.put(strFieldName, strFieldValue);
        }
        return sObj;
    }
    
    private String GetValueForKeyInSVMXMapList(String Key, List<INTF_WebServicesDef.SVMXMap> SVMXMapList)
    {
        for(INTF_WebServicesDef.SVMXMap svmxmapIter : SVMXMapList){
            if(svmxmapIter.key == Key)
                return svmxmapIter.value;
        }
        return null;
    }
    
    /***************** TARGETED SYNC **********************/
    
    public INTF_WebServicesDef.INTF_SFMResponse targetedSync(INTF_WebServicesDef.INTF_SFMRequest request){
            INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
            INTF_WebServicesDef.INTF_SFMResponse internalResponse = new INTF_WebServicesDef.INTF_SFMResponse();
            Datetime dtLastSyncTime;
            Map<String, DateTime> mapIdToRecordLST = new map<String, Datetime>();
            String syncRequestId;
           
           
            system.debug(LoggingLevel.WARN, ' Targeted Sync Started = '+DateTime.now());
            if(request == NULL){
                response.success = false;
                response.message = 'Empty request. Unable to perform sync.';
                return response;
            }
            
            Datetime dtSyncStartTime = Datetime.now();
            
            response.eventType = 'SYNC';
                response.eventName = 'TARGETED_SYNC';
            
            if(request.eventName == 'TARGETED_SYNC' && request.eventType == 'SYNC'){
            
                    syncRequestId = request.value;
                //Get client data from request
                if(request.clientInfo != NULL && request.clientInfo.size() > 0){
                    for(INTF_WebServicesDef.SVMXClient clientInform : request.clientInfo){
                        for(String strInfo : clientInform.clientInfo){
                        system.debug(LoggingLevel.WARN, 'strInfo = ' + strInfo);
                        if(strInfo != null && strInfo.length() > 0)
                        {
                            if(strInfo.split(':',2).size() == 2)
                                mapClientDetails.put(strInfo.split(':',2)[0], (strInfo.split(':',2)[1]).trim());
                        }
                    }
                    if(clientInform.clientType != null)
                    {
                        //strDeviceName = clientInform.clientType;
                        mapClientDetails.put('DeviceName',clientInform.clientType);
                        break;
                    }
                }
            }
            
            INTF_ConfigSync configObj = new INTF_ConfigSync();
            svmxGrpProfileId = configObj.getSVMXGrpProfileId(userinfo.getProfileId());
            
            INTF_WebServicesDef.INTF_SFMRequest putUpdateReq;
            INTF_WebServicesDef.INTF_SFMRequest putDeleteReq;
            INTF_WebServicesDef.INTF_SFMRequest putInsertReq;
            Map<String, Set<String>> excludedIdsPerObjectMap = new Map<String, Set<String>>();
            Map<String, Set<String>> childObjectPerHeaderMap = new Map<String, Set<String>>();
            Map<String, String> objectPerIDMap = new Map<String, String>();
            Set<String> allObjectSet = new Set<String>();
            
            boolean isError = false;
            
            for(INTF_WebServicesDef.SVMXMap reqVM : request.valueMap){
                    if(reqVM.key == 'PUT_UPDATE' && reqVM.lstInternal_Request != null && reqVM.lstInternal_Request.size() > 0 && reqVM.lstInternal_Request[0].eventName == 'PUT_UPDATE'){
                        putUpdateReq = reqVM.lstInternal_Request[0];
                    }else if(reqVM.key == 'PUT_DELETE' && reqVM.lstInternal_Request != null && reqVM.lstInternal_Request.size() > 0 && reqVM.lstInternal_Request[0].eventName == 'PUT_DELETE'){
                        putDeleteReq = reqVM.lstInternal_Request[0];
                    }else if(reqVM.key == 'PUT_INSERT' && reqVM.lstInternal_Request != null && reqVM.lstInternal_Request.size() > 0 && reqVM.lstInternal_Request[0].eventName == 'PUT_INSERT'){
                        putInsertReq = reqVM.lstInternal_Request[0];
                    }else if(reqVM.key == 'LAST_SYNC_TIME' && reqVM.value != NULL && reqVM.value.length() > 0){
                        dtLastSyncTime = Datetime.valueOf(reqVM.value);
                    }else if(reqVM.key == 'TS_KEYS' && reqVM.value != NULL && reqVM.Value != ''){
                        mapIdToRecordLST = (Map<String, Datetime>)JSON.deserialize(reqVM.value, Map<String, Datetime>.Class);
                    }else if(reqVM.key == 'SERVER_OVERRIDE'){
                        for(INTF_WebServicesDef.SVMXMap innerVM : reqVM.valueMap){
                            if(recordIdsPerObjectMap.get(innerVM.Key) == NULL){
                                recordIdsPerObjectMap.put(innerVM.Key, new Set<String>());
                            }
                            recordIdsPerObjectMap.get(innerVM.Key).addAll(innerVM.values);
                        }
                    }else if(reqVM.key == 'REFERENCE_DATA'){
                            for(INTF_WebServicesDef.SVMXMap innerVM : reqVM.valueMap){
                                if(innerVM.Key == 'EXCLUDED_IDS'){
                                    for(INTF_WebServicesDef.SVMXMap objVM : innerVM.valueMap){
                                        if(excludedIdsPerObjectMap.get(objVM.Key) == NULL){
                                            excludedIdsPerObjectMap.put(objVM.Key, new Set<String>());
                                        }
                                        excludedIdsPerObjectMap.get(objVM.Key).addAll(objVM.values);
                                    }
                                }else{
                                    allObjectSet.add(innerVM.key);
                                    objectPerIDMap.put(innerVM.key, innerVM.Value);
                                    if(innerVM.values != NULL && innerVM.values.size() > 0){
                                        if(childObjectPerHeaderMap.get(innerVM.key) == NULL){
                                            childObjectPerHeaderMap.put(innerVM.key, new Set<String>());
                                        }
                                        childObjectPerHeaderMap.get(innerVM.key).addAll(innerVM.values);
                                        allObjectSet.addAll(innerVM.values);
                                    }
                                }
                            }
                    }
            }
            
            system.debug(LoggingLevel.WARN, ' TimeStamp now is = '+DateTime.now());
            system.debug('TS_Keys are = '+mapIdToRecordLST);
        
            //Execute delete
            if(putDeleteReq != NULL){
                internalResponse = deleteBaseRecords(putDeleteReq, syncRequestId);
                INTF_WebServicesDef.SVMXMap putdeleteRes = new INTF_WebServicesDef.SVMXMap();
                putdeleteRes.key = 'PUT_DELETE';
                putdeleteRes.lstInternal_Response = new List<INTF_WebServicesDef.INTF_SFMResponse>();
                putdeleteRes.lstInternal_Response.add(internalResponse);
                response.valueMap.add(putdeleteRes);
                
                isError = operationFailCheck(internalResponse);
                if(isError){
                    response.success = false;
                    for(INTF_WebServicesDef.SVMXMap eachVM : internalResponse.ValueMap){
                        system.debug(Logginglevel.WARN,'++++ eachVM = '+eachVM);
                        if(eachVM.key == 'ERROR'){
                            for(INTF_WebServicesDef.SVMXMap eachInternalVM : eachVM.ValueMap){
                                if(eachInternalVM.value.Startswith('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                                    response.success = true;
                                    break;
                                }
                            }
                        }
                    }
                    system.debug(Logginglevel.WARN,'++++ response = '+response);
                    return response;
                }
            }
            
            //Insert
            if(putInsertReq != NULL){
                internalResponse = insertClientRecordsIntoBase(putInsertReq,syncRequestId);
                INTF_WebServicesDef.SVMXMap putInsertRes = new INTF_WebServicesDef.SVMXMap();
                putInsertRes.key = 'PUT_INSERT';
                putInsertRes.lstInternal_Response = new List<INTF_WebServicesDef.INTF_SFMResponse>();
                putInsertRes.lstInternal_Response.add(internalResponse);
                response.valueMap.add(putInsertRes);
                     
                isError = operationFailCheck(internalResponse);
                if(isError){
                    response.success = false;
                    for(INTF_WebServicesDef.SVMXMap eachVM : internalResponse.ValueMap){
                        if(eachVM.key == 'ERROR'){
                            for(INTF_WebServicesDef.SVMXMap eachInternalVM : eachVM.ValueMap){
                                if(eachInternalVM.value.Startswith('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                                    response.success = true;
                                    break;
                                }
                            }
                        }
                    }
                    return response;
                }
            }
            
            //Update
            if(putUpdateReq != NULL){
                internalResponse = updateClientRecordsIntoBase( putUpdateReq, dtSyncStartTime, dtLastSyncTime, mapIdToRecordLST);
                INTF_WebServicesDef.SVMXMap putUpdateRes = new INTF_WebServicesDef.SVMXMap();
                putUpdateRes.key = 'PUT_UPDATE';
                putUpdateRes.lstInternal_Response = new List<INTF_WebServicesDef.INTF_SFMResponse>();
                putUpdateRes.lstInternal_Response.add(internalResponse);
                response.valueMap.add(putUpdateRes);
                
                isError = operationFailCheck(internalResponse); 
                if(isError){
                        response.success = false;
                        
                        for(INTF_WebServicesDef.SVMXMap eachVM : internalResponse.ValueMap){
                        if(eachVM.key == 'ERROR'){
                            for(INTF_WebServicesDef.SVMXMap eachInternalVM : eachVM.ValueMap){
                                    if(eachInternalVM.value.Startswith('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                                        response.success = true;
                                        break;
                                    }
                            }
                        }
                    }
                        system.debug(LoggingLevel.WARN, 'response.success - ' + response.success);
                        return response;
                }
            }
            
            system.debug(LoggingLevel.WARN, 'objectPerIDMap = '+objectPerIDMap);
            //Get Attachments and checklists related to the header records
            if(objectPerIDMap != NULL && !objectPerIDMap.isEmpty()){
                response =  getAttachmentRecords(response, objectPerIDMap, dtLastSyncTime);
                response =  getChecklistRecords(response, objectPerIDMap, dtLastSyncTime);
            }
            
            //Perform Tx_fetch on all the records
            if( (recordIdsPerObjectMap != NULL && !recordIdsPerObjectMap.keySet().isEmpty() ) || objectPerIDMap.size() > 0){
                response = fetchRecordDetails(response, objectPerIDMap, childObjectPerHeaderMap, excludedIdsPerObjectMap, allObjectSet, dtLastSyncTime); 
                if(response.success){
                    //successful tx_fetch -> send all the record ids to the client as TS_RECORD_IDS
                    List<String> recordIdsList = new List<String>();
                    for(String eachObj : recordIdsPerObjectMap.KeySet()){
                        recordIdsList.addAll(recordIdsPerObjectMap.get(eachObj));
                    }
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('TS_RECORD_IDS','',recordIdsList));
                    
                    system.debug(LoggingLevel.WARN, 'Heap size before clearing map = ' + Limits.getHeapSize());
                    recordIdsPerObjectMap.clear(); //clear the map after tx_fetch
                    system.debug(LoggingLevel.WARN, 'Heap size after clearing = ' + Limits.getHeapSize());
                }
            }
        
        }
        
        response.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_SYNC_TIME',String.valueOfGmt(Datetime.now())));
        response.success = true;
        system.debug(LoggingLevel.WARN, ' Targeted Sync response is '+response);
        return response;
    }
    
    
    public Boolean operationFailCheck(INTF_WebServicesDef.INTF_SFMResponse response){
            boolean hasOperationFailed = false;
            
            for(INTF_WebServicesDef.SVMXMap eachVM : response.ValueMap){
                if(eachVM.key == 'ERROR'){
                    hasOperationFailed = true;
                    break;
                }
            }
            
            if(response.errors != NULL && response.errors.size() > 0){
                hasOperationFailed = true;
            }
            system.debug(LoggingLevel.WARN, ' hasOperationFailed = '+hasOperationFailed);
            return hasOperationFailed;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse updateClientRecordsIntoBase(INTF_WebServicesDef.INTF_SFMRequest putUpdateReq, Datetime dtSyncStartTime, Datetime dtLastSyncTime, Map<String, Datetime> mapIdToRecordLST )
    {
                INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
            String strSyncConflict = '';
            List<INTF_WebServicesDef.SVMXMap> ConflictList = new List<INTF_WebServicesDef.SVMXMap>();
            
            try{
                
                //Get the fieldLevel conflict setting
                Boolean isFieldLevelSyncConflict = false;
                COMM_Utils_ManageSettings commSettings = new COMM_Utils_ManageSettings();
                map<String, String> mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', new list<String>{'SET016'});
                if(mapSettingsForIPAD018 != NULL && mapSettingsForIPAD018.containskey('SET016') && !String.isBlank(mapSettingsForIPAD018.get('SET016')))
                    isFieldLevelSyncConflict = Boolean.valueOf(mapSettingsForIPAD018.get('SET016'));
                
                if(putUpdateReq.eventType == 'SYNC' && putUpdateReq.eventName == 'PUT_UPDATE'){
            
                        
                    List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
                    INTF_WebServicesDef.SVMXMap deletedRecIds = new INTF_WebServicesDef.SVMXMap('DELETED_IDS', '');
                        
                    String strDeviceType = '';
                    if(mapClientDetails != NULL &&  mapClientDetails.get('DeviceName') != NULL){
                        strDeviceType = mapClientDetails.get('DeviceName');
                    }
                    system.debug(LoggingLevel.WARN,' Device from Request = '+strDeviceType);
                    
                    //String svmxGrpProfileId = (new INTF_ConfigSync()).getSVMXGrpProfileId(null);  
                    String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(svmxGrpProfileId, strDeviceType);
                     
                    for(SVMXC__ServiceMax_Config_Data__c confgData : [select SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Mobile Configuration' AND SVMXC__Display_Type__c = 'Conflict Resolution' AND SVMXC__Access_Configuration_Profile__c =:svmxGrpProfileId AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId limit 1])
                            strSyncConflict = confgData.SVMXC__Internal_Value__c;
                    
                    system.debug(LoggingLevel.WARN,' Conflict option selected is = '+strSyncConflict);
                    
                for(INTF_WebServicesDef.SVMXMap firstLevelMap : putUpdateReq.valueMap){
                    
                    if(firstLevelMap.key == 'object_name'){
                        List<sObject> sobjList = new List<sObject>();
                        
                        Map<String,String> mapFieldAndItsType = new Map<String,String>();
                        Set<String> setUpdatableFieldNames = new Set<String>();
                        Map<String,Integer> mapFieldAndItsScale = new Map<String,Integer>();  //TODO: CHECK IF THIS IS ACTUALLY REQUIRED
                        
                        
                        INTF_GetObjectDefinition objectDefinition = new INTF_GetObjectDefinition();
                        objectDefinition.objectName = firstLevelMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = objectDefinition.INTF_GetObjectDefinition();
                        
                        if(recordIdsPerObjectMap.get(firstLevelMap.value) == NULL){
                            recordIdsPerObjectMap.put(firstLevelMap.value, new Set<String>());
                        }
                        
                        if(objDef != NULL){
                            for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap){
                                if(objProp.key == 'FIELDPROPERTY'){
                                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap){
                                        for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap){
                                            if(fldObj.key == 'TYPE'){
                                                mapFieldAndItsType.put(lstField.value, fldObj.value);
                                            }
                                            if(fldObj.key == 'UPDATEABLE' && fldObj.value == 'true'){
                                                setUpdatableFieldNames.add(lstField.value);
                                            }
                                            if(fldObj.key == 'SCALE' && fldObj.value != null && Integer.valueOf(fldObj.value) != 0){
                                                system.debug(LoggingLevel.WARN, 'Field = ' + lstField.value + '; Scale = ' + fldObj.value);
                                                mapFieldAndItsScale.put(lstField.value, Integer.valueOf(fldObj.value)); 
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    
                    for(INTF_WebServicesDef.SVMXMap secondLevelMap : firstLevelMap.valueMap){
                            if(secondLevelMap.key == 'Fields'){
                                system.debug(LoggingLevel.WARN, 'Inside Fields');
                                
                                Set<String> setSFIds = new Set<String>();
                                Set<String> setDeletedIds = new Set<String>();
                                Map<String, Map<String, String>> mapIdAndRecordToBeUpdated = new Map<String, Map<String, String>>();
                                Map<String, Map<String, String>> mapIdAndBeforeSaveRecord = new Map<String, Map<String, String>>();
                                Map<String, String> mapIdToRecordReqKey = new Map<String, String>();
                                DateTime newModifiedDate;
                                
                                for(INTF_WebServicesDef.SVMXMap eachRecordToUpdate : secondLevelMap.valueMap){
                                    system.debug(LoggingLevel.WARN, ' Each Record to Update in Request: ' + eachRecordToUpdate);
                                    if(eachRecordToUpdate.key != 'BEFORE_SAVE'){
                                        Map<string, String> mapFieldValue = (Map<string, String>)JSON.deserialize(eachRecordToUpdate.value, Map<String, String>.Class);
                                        system.debug(LoggingLevel.WARN, 'mapFieldValue' + mapFieldValue + ';mapFieldValue.get(Id) = ' + mapFieldValue.get('Id'));
                                        mapIdAndRecordToBeUpdated.put(mapFieldValue.get('Id'), mapFieldValue); 
                                        mapIdToRecordReqKey.put(mapFieldValue.get('Id'), eachRecordToUpdate.Key); 
                                         
                                    }else if(eachRecordToUpdate.key == 'BEFORE_SAVE'){
                                        for(String strJsonBeforeSave : eachRecordToUpdate.values){
                                            Map<String, String> mapFieldValue = (Map<String, String>)JSON.deserialize(strJsonBeforeSave, Map<String, String>.Class);
                                            mapIdAndBeforeSaveRecord.put(mapFieldValue.get('Id'), mapFieldValue);
                                        }
                                    }
                                }
                                
                                system.debug(LoggingLevel.WARN, '**** mapIdAndRecordToBeUpdated = '+mapIdAndRecordToBeUpdated);
                                system.debug(LoggingLevel.WARN, '**** mapIdToRecordReqKey = '+mapIdToRecordReqKey);
                                system.debug(LoggingLevel.WARN, '**** mapIdAndBeforeSaveRecord = '+mapIdAndBeforeSaveRecord);
                                
                                setSFIds.addAll(mapIdAndRecordToBeUpdated.keySet());
                                system.debug(LoggingLevel.WARN, '**** setSFIds during update = '+setSFIds);
                                //Query the deleted records and remove them from the list to be processed
                                for(sobject eachRec : Database.query('SELECT Id FROM ' + firstLevelMap.value + ' WHERE Id IN : setSFIds and isDeleted = true All Rows'))
                                {
                                    setDeletedIds.add(String.valueOf(eachRec.get('Id')));
                                    mapIdAndRecordToBeUpdated.keySet().remove(String.valueOf(eachRec.get('Id')));
                                }
                                if(setDeletedIds.size() > 0){
                                   deletedRecIds.valueMap.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, JSON.serialize(setDeletedIds))); 
                                   response.valueMap.add(deletedRecIds);  
                                   
                                   setSFIds.removeAll(setDeletedIds);
                                }
                                
                                if(setSFIds.isEmpty()){   //no records to update - remove it from recordIdsPerObjectMap
                                        recordIdsPerObjectMap.remove(firstLevelMap.value);
                                }
                            
                                String strQuery = 'SELECT LastModifiedById , LastModifiedDate FROM ' + firstLevelMap.value + ' WHERE Id IN : setSFIds';
                                List<SObject> queryResult = Database.query(strQuery);
                                system.debug(LoggingLevel.WARN, '**** queryResult = '+queryResult);
                           
                                //TODO: CONFLICT RESOLUTION
                                Integer a = 0;
                                for(String strRecordId : setSFIds){
                                        String strClientOvrde = '';
                                        Boolean strConflict = false;
                                        
                                        sObject sObjToUpdate = Schema.getGlobalDescribe().get(firstLevelMap.value).newSObject(strRecordId);
                                        
                                        DateTime dbLastModified = Datetime.valueOf(queryResult[a].get('LastModifiedDate'));
                                        String sUserId = UserInfo.getUserId();
                                        
                                        system.debug(LoggingLevel.WARN, 'strRecordId =' + strRecordId + '; sObject = ' + sObjToUpdate);
                                        system.debug(LoggingLevel.WARN, '**** dtSyncStartTime = '+dtSyncStartTime + ' ---- LMD of records = '+dbLastModified);
                                        
                                        if(mapIdToRecordReqKey != NULL){
                                            strClientOvrde = mapIdToRecordReqKey.get(strRecordId);
                                        }
                                        
                                        Datetime dtLastSyncForRecord = dtLastSyncTime;
                                        //Get the last sync time for that record from TS_Keys
                                        if(mapIdToRecordLST.containsKey(strRecordId) && mapIdToRecordLST.get(strRecordId)!= NULL){
                                            dtLastSyncForRecord = mapIdToRecordLST.get(strRecordId);
                                        }
                                        system.debug(LoggingLevel.WARN,'strClientOvrde = ' + strClientOvrde + '--- LST for this record = '+dtLastSyncForRecord);
                                        
                                        if(isFieldLevelSyncConflict){
                                        if(queryResult != null && queryResult.size() > 0 && strClientOvrde != 'CLIENT_OVERRIDE' && (dbLastModified > dtLastSyncForRecord) && ((dbLastModified < dtSyncStartTime) || queryResult[a].get('LastModifiedById') != sUserId )){
                                            INTF_WebServicesDef.SVMXMap conflict;  
                                            if(mapIdAndRecordToBeUpdated.containsKey(strRecordId) && mapIdAndBeforeSaveRecord.containsKey(strRecordId)){
                                                   List<String> updatableFieldNames = (new COMM_Utils_V2()).checkDuplicateFields(new List<String>(setUpdatableFieldNames), firstLevelMap.value); //Remove duplicate API Fields
                                                String strFieldNamesToQry =  objectDefinition.getObjectFieldNames(updatableFieldNames);
                                                sObject eachRecord = Database.query('Select ' + strFieldNamesToQry + ' from ' + firstLevelMap.value + ' where Id = \'' +  strRecordId + '\'');
                                            
                                                for(String eachField: mapIdAndBeforeSaveRecord.get(strRecordId).keySet()){
                                                    if(setUpdatableFieldNames.contains(eachField)){
                                                        String strFldValFrmClient = mapIdAndBeforeSaveRecord.get(strRecordId).get(eachField);
                                                        String strFldValAtSrvr = String.valueOf(eachRecord.get(eachField));
                                                        
                                                        system.debug(LoggingLevel.WARN, 'Field Name = ' + eachField + '; Type = ' + mapFieldAndItsType.get(eachField) + '; Field Value at Client Before Save = ' + strFldValFrmClient + '; Field Value at Server = ' + strFldValAtSrvr);
                                                        
                                                        
                                                        strFldValFrmClient = formatFieldValue(eachField, strFldValFrmClient,mapFieldAndItsType, mapFieldAndItsScale );
                                                        
                                                        if(strFldValAtSrvr == null)
                                                            strFldValAtSrvr = '';
                                                        
                                                        system.debug(LoggingLevel.WARN, 'Field Name = ' + eachField + '; Field Value at Client before save = ' + strFldValFrmClient + '; Field Value at Server = ' + strFldValAtSrvr);
                                                        
                                                        String strFieldValueToSave = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                        
                                                        strFieldValueToSave = formatFieldValue(eachField, strFieldValueToSave,mapFieldAndItsType, mapFieldAndItsScale );
                                                        
                                                        system.debug(LoggingLevel.WARN, 'Field value to be updated from client = ' + strFieldValueToSave + 'Field value at server = ' + strFldValAtSrvr);
                                        
                                                        if(!strFldValFrmClient.equals(strFldValAtSrvr) && strFieldValueToSave != strFldValAtSrvr){
                                                            system.debug(LoggingLevel.WARN,'Conflict in field = ' + eachField + ' and Sync Conflict = ' + strSyncConflict);
                                                            if(strSyncConflict == 'Allow user to choose'){
                                                                system.debug(LoggingLevel.WARN,'Conflict when Allow user to choose');
                                                                conflict = new INTF_WebServicesDef.SVMXMap();
                                                                conflict.key = firstLevelMap.value;
                                                                conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(dtSyncStartTime) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(dtLastSyncTime);
                                        
                                                                conflict.valueMap.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                                                conflictList.add(conflict);
                                                                strConflict = true;
                                                                break;  
                                                            }else if(strSyncConflict == 'ServiceMax online data'){
                                                                if(mapIdAndRecordToBeUpdated.get(strRecordId) != null){
                                                                    sObjToUpdate = createsObject(sObjToUpdate, mapFieldAndItsType, eachField, strFldValAtSrvr);
                                                                }
                                                            }else if(strSyncConflict == 'Mobile device data'){
                                                                if(mapIdAndRecordToBeUpdated.get(strRecordId) != null){
                                                                    String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                                    sObjToUpdate = createsObject(sObjToUpdate, mapFieldAndItsType, eachField, strFieldValue);
                                                             }
                                                            }
                                                        }else{
                                                            //Not a conflict
                                                            if(mapIdAndRecordToBeUpdated.get(strRecordId) != NULL){
                                                                //String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                                sObjToUpdate = createsObject(sObjToUpdate, mapFieldAndItsType, eachField, mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField));
                                                            }
                                                        }
                                                    }
                                                }
                                                if(!strConflict){
                                                    sobjList.add(sObjToUpdate);
                                                }
                                            }else{
                                                //There was no beforeSave record
                                                if(strSyncConflict != 'ServiceMax online data'){
                                                    conflict = new INTF_WebServicesDef.SVMXMap();
                                                    conflict.key = firstLevelMap.value;
                                                    conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(dtSyncStartTime) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(dtLastSyncTime);
                            
                                                    conflict.valueMap.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                                    conflictList.add(conflict);
                                                    strConflict = true;
                                                    break;  
                                                }else{
                                                    system.debug(LoggingLevel.WARN,'Conflict when ServiceMax online data');
                                                    //add it to response
                                                    recordIdsPerObjectMap.get(firstLevelMap.value).add(String.ValueOf(queryResult[a].get('Id')));
                                                    
                                                }
                                            }
                                        }else{
                                            //It's client_Override - directly update the record
                                            sObjList.add((new INTF_TxnCache()).createsObjectToUpdate(strRecordId, sObjToUpdate, setUpdatableFieldNames, mapIdAndRecordToBeUpdated, mapFieldAndItsType));  
                                        }
                                    }else{
                                            //Field level sync conflict has been disabled
                                            if(queryResult != null && queryResult.size() > 0 ){
                                            INTF_WebServicesDef.SVMXMap conflict;  
                                        
                                            if( strClientOvrde != 'CLIENT_OVERRIDE' && (strSyncConflict == 'Allow user to choose' || strSyncConflict =='ServiceMax online data') ){
                                                if(dbLastModified > dtLastSyncForRecord && ( (dbLastModified < dtSyncStartTime) || queryResult[a].get('LastModifiedById') != sUserId )){
                                                    if(strSyncConflict == 'Allow user to choose'){
                                                        conflict = new INTF_WebServicesDef.SVMXMap();
                                                        conflict.key = firstLevelMap.value;
                                                        conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(dtSyncStartTime) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(dtLastSyncTime);
                                                        conflict.valueMap.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                                        conflictList.add(conflict);
                                                        strConflict = true;
                                                        break;  
                                                    }else if(strSyncConflict == 'ServiceMax online data'){
                                                        recordIdsPerObjectMap.get(firstLevelMap.value).add(String.ValueOf(queryResult[a].get('Id'))); //online takes precedence - just do a tx_fetch on this record
                                                    }
                                                }else{
                                                    //no conflict - update the record
                                                    sObjList.add((new INTF_TxnCache()).createsObjectToUpdate(strRecordId, sObjToUpdate, setUpdatableFieldNames, mapIdAndRecordToBeUpdated, mapFieldAndItsType));  
                                                    }
                                             }else{
                                                //It's client_Override OR client takes precendence in the config - directly update the record
                                                 sObjList.add((new INTF_TxnCache()).createsObjectToUpdate(strRecordId, sObjToUpdate, setUpdatableFieldNames, mapIdAndRecordToBeUpdated, mapFieldAndItsType));  
                                                
                                             }
                                            }
                                            
                                    }
                                    a++; 
                                }
                            
                                system.debug(LoggingLevel.WARN, '**** List to be updated = '+sobjList);
                            
                            
                                     //Update the records
                                    if(sobjList != NULL && !sobjList.isEmpty()){
                                        INTF_WebServicesDef.SVMXMap error;
                                        Database.SaveResult[] updateResult;
                                        try{
                                                updateResult = Database.update(sobjList, false);
                                             system.debug(LoggingLevel.WARN, '+++updateResult = ' + updateResult);
                                            
                                        }catch(Exception e){
                                             system.debug(LoggingLevel.WARN, '+++Exception = ' + e);
                                             ErrorList.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, e.getMessage()));   
                                        }finally{
                                            if(updateResult != NULL){
                                                Integer i=0;
                                                for(Database.saveresult eachResult: updateResult){
                                                     if(eachResult.isSuccess()){
                                                         recordIdsPerObjectMap.get(firstLevelMap.value).add(String.ValueOf(eachResult.getId()));
                                                     }else{
                                                    
                                                         Database.Error[] err = eachResult.getErrors();
                                                         system.debug(LoggingLevel.WARN, '+++ Errors = '+err);
                                                         error = new INTF_WebServicesDef.SVMXMap(); 
                                                         error.key = firstLevelMap.value;
                                                         error.value = err[0].getMessage();
                                                         if(err[0].getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION || (err[0].getStatusCode() == StatusCode.INSUFFICIENT_ACCESS_OR_READONLY)){
                                                                error.value = 'FIELD_CUSTOM_VALIDATION_EXCEPTION ' + err[0].getMessage();
                                                         }
                                                         INTF_WebServicesDef.SVMXMap childErr = new INTF_WebServicesDef.SVMXMap(sobjList[i].Id,sobjList[i].Id);
                                                         error.valueMap.add(childErr);
                                                         ErrorList.add(Error);
                                                     }
                                                     i++;
                                                }
                                            }
                                       } //End of finally
                                }
                            } //End of if('Fields')
                        }
                    }
                        
                }//first levelmap end
                
                if(errorList.size() > 0){
                    INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap('ERROR','');
                    ErrorHeader.valueMap = ErrorList;
                    response.valueMap.add(ErrorHeader);
                }
                
                if(conflictList.size() > 0){
                        INTF_WebServicesDef.SVMXMap conflictHeader = new INTF_WebServicesDef.SVMXMap('CONFLICT', '');
                        conflictHeader.valueMap = conflictList;
                        response.valueMap.add(conflictHeader);
                }
                
                if(deletedRecIds.valueMap.size() > 0 ){
                        response.valueMap.add(deletedRecIds);  
                }
                
            }
        }catch(Exception e){
            system.debug(LoggingLevel.WARN, 'e = ' + e);
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        
        response.eventType = putUpdateReq.eventType;
        response.eventName = putUpdateReq.eventName;
        system.debug(LoggingLevel.WARN, 'Response after putUpdate = ' + response);
        return response;
    }
    
    
    public INTF_WebServicesDef.INTF_SFMResponse insertClientRecordsIntoBase(INTF_WebServicesDef.INTF_SFMRequest inputRequest, String syncRequestId)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        map<String, String> mapSavedLocalIdToSFId = new map<String, String>();
        Map<String, String> localIdMapToSFIDParent = new Map<String, String>();
        Map<String, String> localIdMapToSFIDChild = new Map<String, String>();
        List<String> localIdsParent = new List<String>();
        List<String> localIdsChild = new List<String>();
        Database.Saveresult [] parentsaveresult;
        Database.Saveresult [] childrensaveresult;
        map<String, map<String, String>> mapOperationToIds = new map<String, map<String, String>>();
        
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
         SVMXC__SM_Request_Cache__c singleCacheRec = getRecFromCache(syncRequestId, mapClientDetails.get('userid'), mapClientDetails.get('clientudid'));
        
        mapOperationToIds = (new INTF_TxnCache()).getCachedLocalIdsForInsertAndDel(singleCacheRec);
        
        if(mapOperationToIds != NULL && mapOperationToIds.get(INSERT_OPERATION) != NULL){
                mapSavedLocalIdToSFId = mapOperationToIds.get(INSERT_OPERATION);
        }
        
         String clientType;
         if(mapClientDetails != NULL &&  mapClientDetails.get('DeviceName') != NULL){
            clientType = mapClientDetails.get('DeviceName');
         }
         
         try{
             if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_INSERT'){
                
                List<INTF_WebServicesDef.SVMXMap> inputList = inputRequest.valueMap;
                List<INTF_WebServicesDef.SVMXMap> fieldsMapList;
                Iterator<INTF_WebServicesDef.SVMXMap> inputListIterator = inputList.iterator();
                List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
                List<INTF_WebServicesDef.SVMXMap> insertList = new List<INTF_WebServicesDef.SVMXMap>();
                    
                INTF_WebServicesDef.SVMXMap firstLevelMap;
                
                while(inputListIterator.hasNext()){
                    firstLevelMap = inputListIterator.next();
                    
                    if(firstLevelMap.Key == 'Parent_Object'){
                        
                        if(recordIdsPerObjectMap.get(firstLevelMap.value) == NULL){
                                recordIdsPerObjectMap.put(firstLevelMap.value, new Set<String>());
                        }
                                
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = firstLevelMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        
                        Map<String,String> fieldsType = new Map<String,String>();
                        Map<String,String> fieldCreateable = new Map<String,String>();
                        
                         if(objDef != NULL){
                            List<INTF_WebServicesDef.SVMXMap> objProps = objdef.valueMap;
                            for(INTF_WebServicesDef.SVMXMap objProp : objProps){
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
                         
                         fieldsMapList = firstLevelMap.valueMap;
                         iterator<INTF_WebServicesDef.SVMXMap> fieldsMapIterator = fieldsMapList.iterator();
                         INTF_WebServicesDef.SVMXMap secondLevelMap;
                         List<INTF_WebServicesDef.SVMXMap> fieldValues = new List<INTF_WebServicesDef.SVMXMap>();
                         
                         List<sObject> sobjListParent = new List<sObject>(); 
                         
                         while(fieldsMapIterator.hasNext()){
                            secondLevelMap =  fieldsMapIterator.next();  
                            if(secondLevelMap.key == 'Fields'){
                                fieldValues = secondLevelMap.valueMap;//fieldValues - each record to insert
                                Iterator<INTF_WebServicesDef.SVMXMap> it = fieldValues.iterator();
                                Sobject sobj = NULL;
                                String localId = NULL;
                                
                                while(it.hasNext()){
                                    INTF_WebServicesDef.SVMXMap selectedObj = it.next();
                                    String SFIDIfExists = mapSavedLocalIdToSFId.get(selectedObj.key);  //map.get(local_ID) give the sfdc Id
                                    if(SFIDIfExists != NULL){  //Record has been inserted already
                                        localIdMapToSFIDParent.put(selectedObj.key,SFIDIfExists);
                                        recordIdsPerObjectMap.get(firstLevelMap.value).add(SFIDIfExists);
                                        
                                    }else{
                                        //record needs to be inserted
                                        localId = selectedObj.key;
                                        localIdsParent.add(selectedObj.key);
                                        String jstr = selectedObj.value;
                                        
                                        if(clientType != NULL && clientType != '' && clientType.contains('iPad')){
                                            jstr = jstr.replace('&quot;', '"');
                                        }
                                        JSONParser jsp = JSON.createParser(jstr);
                                        sObj = Schema.getGlobalDescribe().get(firstLevelMap.value).newSObject();
                                        
                                        while(jsp.nextToken() != NULL){
                                            if(jsp.getCurrentToken() == JSONToken.FIELD_NAME){
                                                String fieldName = jsp.getText();
                                                if(jsp.nextToken() == JSONToken.VALUE_STRING){
                                                    String fieldValue = jsp.getText();
                                                    if(fieldCreateable.get(fieldName) == 'true'){
                                                        if(fieldValue != NULL && fieldValue != ''){
                                                            system.debug('Field Name = '+fieldName + ' ---- Field Value = '+fieldValue);
                                                            
                                                            if(clientType != NULL && clientType != '' && clientType.contains('iPad')){
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
                                    if(sObj != NULL){
                                        sobjListParent.add(sObj);
                                    }
                                }
                                
                                INTF_WebServicesDef.SVMXMap error;
                                //insert the parent records
                                try{
                                    parentsaveresult = Database.insert(sobjListParent, false);
                                    Integer i = 0;
                                    INTF_WebServicesDef.SVMXMap objMap;
                                    for(Database.SaveResult res: parentsaveresult){
                                        objMap = new INTF_WebServicesDef.SVMXMap();
                                        if(res.isSuccess()){
                                            recordIdsPerObjectMap.get(firstLevelMap.value).add(String.ValueOf(res.getId()));
                                            
                                            localIdMapToSFIDParent.put(localIdsParent[i],res.getId() );  
                                            mapSavedLocalIdToSFId.put(localIdsParent[i], String.ValueOf(res.getId()));
                                        }else{
                                            error = new INTF_WebServicesDef.SVMXMap();
                                            Database.Error err = res.GetErrors()[0];
                                            error.key = firstLevelMap.value;
                                            error.Value = err.getMessage();
                                            if(err.getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION || (err.getStatusCode() == StatusCode.INSUFFICIENT_ACCESS_OR_READONLY)){
                                                     error.value = 'FIELD_CUSTOM_VALIDATION_EXCEPTION ' + err.getMessage();
                                            }
                                            INTF_WebServicesDef.SVMXMap childError = new INTF_WebServicesDef.SVMXMap(localIdsParent[i],localIdsParent[i]);
                                            error.ValueMap.add(childError);
                                            ErrorList.add(Error);  
                                        }
                                        i++;
                                    }
                                }catch(DMLException ex){
                                    error = new INTF_WebServicesDef.SVMXMap();
                                    error.Key = firstLevelMap.value;
                                    error.Value = ex.getMessage();
                                    INTF_WebServicesDef.SVMXMap childError = new INTF_WebServicesDef.SVMXMap(localId, '');
                                    error.valueMap.add(childError);
                                    ErrorList.add(error);
                                    
                                }
                                sobjListParent.clear();
                                localIdsParent.clear();
                                
                             }                   
                         }
                        
                         //Add locaId:SfID to response
                         INTF_WebServicesDef.SVMXMap parentObjVM = new INTF_WebServicesDef.SVMXMap();
                         parentObjVM.Key = firstLevelMap.value;
                         parentObjVM.Value = JSON.serialize(localIdMapToSFIDParent);
                         insertList.add(parentObjVM);
                         
                         system.debug(LoggingLevel.WARN, ';****** = '+insertList);
                         
                    }else if(firstLevelMap.key == 'Child_Object'){
                            
                            if(recordIdsPerObjectMap.get(firstLevelMap.value) == NULL){
                                recordIdsPerObjectMap.put(firstLevelMap.value, new Set<String>());
                        }
                        
                        fieldsMapList = firstLevelMap.valueMap;
                        iterator<INTF_WebServicesDef.SVMXMap> fieldsMapIterator = fieldsMapList.iterator();
                        
                        List<INTF_WebServicesDef.SVMXMap> fieldValues = new List<INTF_WebServicesDef.SVMXMap>();
                        INTF_WebServicesDef.SVMXMap secondLevelMap;
                        
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = firstLevelMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        
                        Map<String,String> fieldsType= new Map<String,String>();
                        Map<String,String> fieldCreateable = new Map<String,String>();
                        Map<String,String> fieldReferenceto = new Map<String,String>();
                        
                        if(objDef != NULL){
                            for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap){
                                 if (objProp.key == 'FIELDPROPERTY'){
                                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap){
                                        List<INTF_WebServicesDef.SVMXMap> fldObjs = lstField.valueMap;
                                        Iterator<INTF_WebServicesDef.SVMXMap> it = fldObjs.iterator();
                                        while(it.hasNext()){
                                            INTF_WebServicesDef.SVMXMap checkMap = it.next();
                                            if(checkMap.key == 'REFERENCETO'){
                                                fieldReferenceto.put(lstField.value, checkMap.key);
                                            }
                                        }
                                        String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', fldObjs);
                                        if (reference_to != null){
                                            String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', fldObjs);
                                        }
                                        for(INTF_WebServicesDef.SVMXMap fldObj : fldObjs)
                                         {
                                            if(fldObj.key == 'TYPE')
                                                fieldsType.put(lstField.value, fldObj.value);
                                            if(fldObj.key == 'CREATEABLE')
                                                fieldCreateable.put(lstField.value, fldObj.value);
                                         }
                                    }
                                 }
                            }
                        }
                        List<sObject> sobjListChild = new List<sObject>();
                        while(fieldsMapIterator.hasNext()){
                            secondLevelMap = fieldsMapIterator.next();
                            if(secondLevelMap.key == 'Fields'){
                                fieldValues = secondLevelMap.valueMap;
                                Iterator<INTF_WebServicesDef.SVMXMap> it = fieldValues.iterator();
                                sObject sObj = null;
                                 String localIdChild = null;
                                while(it.hasNext()){
                                    INTF_WebServicesDef.SVMXMap selectedObj = it.next();
                                    String sfIdIfExists = mapSavedLocalIdToSFId.get(selectedObj.key);
                                    if(sfIdIfExists != NULL){
                                        localIdMapToSFIDChild.put(selectedObj.key,sfIdIfExists);
                                        recordIdsPerObjectMap.get(firstLevelMap.value).add(SFIDIfExists); 
                                    }else{
                                        localIdChild = selectedObj.key;
                                        localIdsChild.add(selectedObj.key);
                                        String SFIDParent = localIdMapToSFIDParent.get(selectedObj.key);
                                        if (SFIDParent != null){
                                            selectedObj.key = SFIDParent;
                                        }
                                         String jstr = selectedObj.value;   
                                         if(clientType != NULL && clientType != '' && clientType.contains('iPad')){
                                            jstr = jstr.replace('&quot;', '"');
                                        }
                                        JSONParser jsp = JSON.createParser(jstr);
                                        sObj = Schema.getGlobalDescribe().get(firstLevelMap.value).newSObject();
                                        while(jsp.nextToken() != null){
                                             if(jsp.getCurrentToken() == JSONToken.FIELD_NAME) {
                                                String fieldName = jsp.getText();
                                                if(jsp.nextToken() == JSONToken.VALUE_STRING){
                                                    String fieldValue = jsp.getText();
                                                    if(fieldCreateable.get(fieldName) == 'true'){
                                                        if(fieldValue != null && fieldValue != ''){
                                                            system.debug('Field Name = '+fieldName + ' ---- Field Value = '+fieldValue);
                                                            
                                                            if(clientType != NULL && clientType != '' && clientType.contains('iPad')){
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
                                                                if(fieldReferenceto.containsKey(fieldName)){
                                                                    String fldValueMapped = localIdMapToSFIDParent.get(fieldValue);
                                                                    if (fldValueMapped != null){
                                                                        fieldValue = fldValueMapped;
                                                                    }
                                                                }
                                                                sObj.put(fieldName,fieldValue);
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                        
                                                }
                                             }
                                        }
                                    } 
                                    system.debug(LoggingLevel.WARN, 'Each Child Record : ' + sObj);
                                    if(sObj != null){
                                        sobjListChild.add(sObj); 
                                    }
                                }
                                INTF_WebServicesDef.SVMXMap Error;
                                try{
                                    childrensaveresult = Database.insert(sobjListChild, false);
                                    Integer i = 0;
                                    INTF_WebServicesDef.SVMXMap objMap;
                                    for(Database.Saveresult resChildrec : childrensaveresult){
                                        objMap = new INTF_WebServicesDef.SVMXMap();
                                        if(resChildrec.isSuccess()){
                                            recordIdsPerObjectMap.get(firstLevelMap.value).add(String.ValueOF(resChildrec.getId()));
                                            
                                            localIdMapToSFIDChild.put(localIdsChild[i], resChildrec.getId());
                                            mapSavedLocalIdToSFId.put(localIdsChild[i], String.ValueOF(resChildrec.getId()));
                                        }else{
                                            error = new INTF_WebServicesDef.SVMXMap(); 
                                            Database.Error[] err = resChildrec.getErrors();
                                            error.key = firstLevelMap.value;
                                            error.value = err[0].getMessage();
                                            if(err[0].getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION || (err[0].getStatusCode() == StatusCode.INSUFFICIENT_ACCESS_OR_READONLY)){
                                                     error.value = 'FIELD_CUSTOM_VALIDATION_EXCEPTION ' + err[0].getMessage();
                                            }
                                            INTF_WebServicesDef.SVMXMap childErr = new INTF_WebServicesDef.SVMXMap(localIdsChild[i], localIdsChild[i]);
                                            error.valueMap.add(childErr);
                                            ErrorList.add(Error);
                                        }
                                        i++;
                                    }
                                }catch(DMLException ex){
                                    error = new INTF_WebServicesDef.SVMXMap(); 
                                    error.key = firstLevelMap.value;
                                    error.value = ex.getMessage();  
                                    
                                    INTF_WebServicesDef.SVMXMap childError = new INTF_WebServicesDef.SVMXMap(localIdChild,'');
                                    error.valueMap.add(childError);
                                    ErrorList.add(error);
                                    
                                }
                                sobjListChild.clear();
                                localIdsChild.clear();
                            }
                        }
                        
                        //Add locaId:SfID to response
                        INTF_WebServicesDef.SVMXMap childObjVM = new INTF_WebServicesDef.SVMXMap();
                        childObjVM.Key = firstLevelMap.value;
                        childObjVM.Value = JSON.serialize(localIdMapToSFIDChild);
                        insertList.add(childObjVM);
                        
                        system.debug(LoggingLevel.WARN, ';****** Child = '+insertList); 
                    }
                    
                } //End of while(inputListIterator)
                
                
                 //Update Txn Record with SFDC id
                 if(mapSavedLocalIdToSFId != null && mapSavedLocalIdToSFId.size() > 0){
                     mapOperationToIds.put(INSERT_OPERATION, mapSavedLocalIdToSFId);
                     singleCacheRec = (new INTF_TxnCache()).updateLocalIdsIntoCache(mapOperationToIds, singleCacheRec);
                     Database.Upsertresult result = Database.upsert(singleCacheRec);  
                 }
                 
                if(errorList.size() > 0){
                    INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap('ERROR','');
                    ErrorHeader.valueMap = ErrorList;
                    response.valueMap.add(ErrorHeader);
                }
                
                if(insertList.size() > 0){
                    INTF_WebServicesDef.SVMXMap successVM = new INTF_WebServicesDef.SVMXMap('INSERTED_IDS','');
                    successVM.valueMap = insertList;
                    response.valueMap.add(successVM);
                }
             }
                
        }catch(Exception e){
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
            
        if(response.success == null)
            response.success = true;
        
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        system.debug(LoggingLevel.WARN, 'Response after getInsert = ' + response);
        return response;    
   }
        
        
    
    public INTF_WebServicesDef.INTF_SFMResponse deleteBaseRecords(INTF_WebServicesDef.INTF_SFMRequest inputRequest, String syncRequestId)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        
        List<INTF_WebServicesDef.SVMXMap> reqMap = inputRequest.valueMap;
        Iterator<INTF_WebServicesDef.SVMXMap> reqMapIterator = reqMap.Iterator();
        Set<String> lstSFIDs = new Set<String>();
        map<String, String> mapObjNameToSFId = new map<String, String>();
        map<String, map<String, String>> mapOperationToIds = new map<String, map<String, String>>();
        
        SVMXC__SM_Request_Cache__c singleCacheRec = getRecFromCache(syncRequestId, mapClientDetails.get('userid'), mapClientDetails.get('clientudid'));
        
        mapOperationToIds = (new INTF_TxnCache()).getCachedLocalIdsForInsertAndDel(singleCacheRec);
        
        if(mapOperationToIds != NULL && mapOperationToIds.get(DELETE_OPERATION) != NULL){
                mapObjNameToSFId = mapOperationToIds.get(DELETE_OPERATION);
            lstSFIDs.addAll(mapOperationToIds.get(DELETE_OPERATION).values());
        }
        
        try{
        
            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_DELETE'){
                List<INTF_WebServicesDef.SVMXMap> errorList = new List<INTF_WebServicesDef.SVMXMap>();
                INTF_WebServicesDef.SVMXMap deletedRecIds = new INTF_WebServicesDef.SVMXMap('DELETED_IDS', '');
                
                 while(reqMapIterator.hasNext()){
                    INTF_WebServicesDef.SVMXMap selMap = new INTF_WebServicesDef.SVMXMap();
                    selMap = reqMapIterator.next();
                    if(selMap.key == 'Object_Name'){
                        List<Sobject> sobjList = new List<Sobject>();
                        List<String> allIdsToBeDeleted = new List<String>();
                        
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = selMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        
                        Iterator<INTF_WebServicesDef.SVMXMap> secondMapIterator = selMap.valueMap.Iterator();
                        List<INTF_WebServicesDef.SVMXMap> idValueMap = new List<INTF_WebServicesDef.SVMXMap>();
                        List<INTF_WebServicesDef.SVMXMAP> objValueMap;
                        
                        while(secondMapIterator.hasNext()){
                            INTF_WebServicesDef.SVMXMap selRecMap = new INTF_WebServicesDef.SVMXMap();
                            selRecMap = secondMapIterator.next();
                            if(selRecMap.key == 'Fields'){
                                
                                Set<String> setDeletedIds = new Set<String>();
                                
                                for(INTF_WebServicesDef.SVMXMap eachFieldId: selRecMap.valuemap){
                                        allIdsToBeDeleted.add(eachFieldId.value);
                                }
                                
                                for(Sobject selectedSobj : Database.Query('SELECT Id, isDeleted FROM ' + selMap.value + ' WHERE Id IN : allIdsToBeDeleted ALL ROWS')){
                                    if(selectedSobj.get('IsDeleted') == true || lstSFIDs.contains(String.Valueof(selectedSobj.get('Id')))){
                                        //record has been deleted from server
                                        setDeletedIds.add(String.Valueof(selectedSobj.get('Id')));
                                    }
                                }
                                
                                sObject selObject;
                                for(String idToDelete: allIdsToBeDeleted){
                                    if(!setDeletedIds.contains(idToDelete)){
                                        selObject = Schema.getGlobalDescribe().get(selMap.value).newSObject(idToDelete);
                                        sobjList.add(selObject);
                                    }   
                                }
                                
                                INTF_WebServicesDef.SVMXMap ErrorObj;
                                Database.Deleteresult[] delResult = Database.delete(sobjList,false);
                                for(Database.Deleteresult selResult : delResult){
                                    INTF_WebServicesDef.SVMXMAP recordMap = new INTF_WebServicesDef.SVMXMAP();
                                     if(selResult.isSuccess()){
                                        
                                        setDeletedIds.add(selResult.getId());
                                        
                                        //Update the txnCache records
                                        /*String recordIds = mapObjNameToSFId.get(selMap.value);
                                        if(recordIds == NULL || recordIds == ''){
                                            recordIds = String.valueOf(selResult.getId());
                                        }else{
                                            recordIds = recordIds + ','+ String.valueOf(selResult.getId());
                                        }*/
                                        mapObjNameToSFId.put(selMap.value,String.valueOf(selResult.getId()));
                                        
                                     }else{
                                        
                                        Database.Error[] err = selResult.getErrors();
                                        system.debug(LoggingLevel.WARN, '++++++++++ err = '+err);
                                        errorObj = new INTF_WebServicesDef.SVMXMap();
                                        errorObj.key = selMap.value;
                                        errorObj.value = err[0].getMessage();
                                        if(err[0].getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION || (err[0].getStatusCode() == StatusCode.INSUFFICIENT_ACCESS_OR_READONLY) ){
                                                errorObj.value = 'FIELD_CUSTOM_VALIDATION_EXCEPTION ' + err[0].getMessage();
                                         }
                                        INTF_WebServicesDef.SVMXMap childErr = new INTF_WebServicesDef.SVMXMap(String.ValueOF(selResult.getId()), String.ValueOF(selResult.getId()));
                                        errorObj.valueMap.add(childErr);
                                        errorList.add(ErrorObj);
                                     }
                                }
                                
                                deletedRecIds.valueMap.add(new INTF_WebServicesDef.SVMXMap(selMap.value, JSON.serialize(setDeletedIds)));
                                
                                if(mapObjNameToSFId != null && mapObjNameToSFId.size() > 0){
                                     mapOperationToIds.put(DELETE_OPERATION, mapObjNameToSFId);
                                     singleCacheRec = (new INTF_TxnCache()).updateLocalIdsIntoCache(mapOperationToIds, singleCacheRec);
                                     Database.Upsertresult result = Database.upsert(singleCacheRec);  
                                 }
                             }
                        }
                     }
                 }
                 
                if(errorList.size() > 0){
                    INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap('ERROR','');
                    ErrorHeader.valueMap = errorList;
                    response.valueMap.add(ErrorHeader);
                } 
                
                if(deletedRecIds.valueMap.size() > 0){
                        response.valueMap.add(deletedRecIds);
                }
                
            }
        }catch(Exception e){
            system.debug(LoggingLevel.WARN, 'e = ' + e);
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        
        if(response.success == null)
            response.success = true;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
      
        system.debug(LoggingLevel.WARN, 'Response after getDelete = ' + response);
        return response;  
    }
    
    
    //tx_fetch on Data + reference data
    
    public INTF_WebServicesDef.INTF_SFMResponse fetchRecordDetails(INTF_WebServicesDef.INTF_SFMResponse response, Map<String, String> objectPerIDMap, Map<String, Set<String>> childObjectPerHeaderMap, Map<String, Set<String>> excludedIdsPerObjectMap, Set<String> allObjectSet, Datetime lastSyncTime)
    {
        system.debug(LoggingLevel.WARN, 'response tx_fetch = ' + response);
        Integer intLimitRelationshipFields = 35;
        String strValue = '';
        set<String> setRefObjToSkip = new set<String>();
        INTF_WebServicesDef.SVMXMap deletedRecIds = new INTF_WebServicesDef.SVMXMap('DELETED_IDS', '');
        Set<String> setDeletedIds;
        
        try{
        
            INTF_ConfigSync configObj = new INTF_ConfigSync();
            //string svmxGrpProfileId = configObj.getSVMXGrpProfileId(userinfo.getProfileId());
            List<SVMXC__ServiceMax_Config_Data__c> lstSettings = configObj.getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET004', 'IPAD018_SET013'}, svmxGrpProfileId);
            if(lstSettings != null && lstSettings.size() > 0){
                for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings){
                    if(cnf.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET004' && cnf.SVMXC__Internal_Value__c != null)
                        strValue = cnf.SVMXC__Internal_Value__c;
                    else if(cnf.SVMXC__Setting_Unique_ID__c == 'IPAD018_SET013' && cnf.SVMXC__Internal_Value__c != null)
                        intLimitRelationshipFields = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
                }
            }
            
            list<String> lstObjectsToSkip = new list<String>();
                lstObjectsToSkip = strValue.split(',');
                if(lstObjectsToSkip.size() > 0){
                    for(integer i=0 ; i<lstObjectsToSkip.size(); i++ ){
                        setRefObjToSkip.add(lstObjectsToSkip[i].toUpperCase());
                        
                    }
                }else{                    
                setRefObjToSkip.add('PARTNERNETWORKCONNECTION');
                setRefObjToSkip.add('USER');
                setRefObjToSkip.add('FEEDPOST');
                setRefObjToSkip.add('SOLUTION');
            }
            
            INTF_WebServicesDef.SVMXMap txFetchResponse = new INTF_WebServicesDef.SVMXMap('TX_FETCH','');
            List<INTF_WebServicesDef.SVMXMap> txFetchValueMap  = new List<INTF_WebServicesDef.SVMXMap>();
            
            allObjectSet.addAll(recordIdsPerObjectMap.KeySet());
            
            
            
            for(String eachObj : allObjectSet){
                    
                String whereClause = '';
                set<string> recordIds = new Set<String>();
                set<string> excludedRecIds = new Set<String>();
                setDeletedIds = new Set<String>();
                
                INTF_GetObjectDefinition objectDefinition = new INTF_GetObjectDefinition();
                objectDefinition.objectName = eachObj;
                
                Set<String> documentFields = new Set<String>(); 
                INTF_DataUtilityServices dataUtil = new INTF_DataUtilityServices();     
                if(eachObj == 'ContentDocumentLink'){
                        documentFields = dataUtil.getFieldsForFiles(setRefObjToSkip, intLimitRelationshipFields);
                } 
                
                INTF_WebServicesDef.SVMXMap objDef = objectDefinition.INTF_GetObjectDefinition(); 
                List<String> lstFields = new List<String>();
                set<String> referencesToSkipList = new set<String>{'ContentDocument','LatestPublishedVersion','ContentAsset','ExternalDataSource','ContentVersion'};
                
                if(objDef != NULL){
                    for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap){
                        if(objProp.key == 'FIELDPROPERTY'){
                            Integer refFieldCount = 0;
                            for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap){
                                if( (eachObj == 'Attachment' && lstField.value == 'Body') || (eachObj == 'ContentVersion' && lstField.value == 'VersionData')){
                                        system.debug(LoggingLevel.WARN, 'Attachment Object - do not query Body field');
                                }else{
                                        lstFields.add(lstField.value);
                                }
                                if(refFieldCount == intLimitRelationshipFields){
                                    continue;
                                }
                                
                                String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', lstField.valueMap);
                                if(!String.isBlank(reference_to)){
                                    String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', lstField.valueMap);
                                    if(eachObj == 'ContentDocumentLink' && reference_to =='ContentDocument' && relationship_name != NULL){
                                        for(string cdlFieldName: documentFields){
                                            lstFields.add(relationship_name+'.'+cdlFieldName);
                                        }
                                        refFieldCount++;
                                    }else if(reference_to == 'Case'){
                                        lstFields.add(relationship_name + '.CaseNumber');
                                        refFieldCount++;
                                    }else if(referencesToSkipList.contains(reference_to) || setRefObjToSkip.contains(reference_to.toUpperCase()) || relationship_name == null ){//Added as there is no name field on these reference objects
                                        continue;
                                    }else{
                                        lstFields.add(relationship_name + '.Name');
                                        refFieldCount++;
                                    }
                                    
                                    //check if there is reference data to be downloaded for this object
                                    if(childObjectPerHeaderMap.containsKey(reference_to) && childObjectPerHeaderMap.get(reference_to).contains(eachObj) && objectPerIDMap.get(reference_to) != NULL){
                                            whereClause = lstField.value + ' = \''+ objectPerIDMap.get(reference_to) + '\' AND LastModifiedDate >: lastSyncTime ';
                                    }
                                }   
                            }
                        }
                    }
                }
                
                if(recordIdsPerObjectMap.containsKey(eachObj) && recordIdsPerObjectMap.get(eachObj).size() > 0){
                    recordIds.addAll(recordIdsPerObjectMap.get(eachObj));
                }
                if(objectPerIDMap.get(eachObj) != NULL){
                        recordIds.add(objectPerIDMap.get(eachObj));
                }
                
                if(recordIds.size() > 0){
                        if(whereClause != ''){
                        whereClause = ' ( '+ whereClause +' ) OR ';
                    }
                    whereClause += ' ( Id IN :recordIds ) ';
                }
                
                //Ensure we exclude the records with conflict 
                if(excludedIdsPerObjectMap.containsKey(eachObj) && excludedIdsPerObjectMap.get(eachObj).size() > 0){
                    excludedRecIds.addAll(excludedIdsPerObjectMap.get(eachObj));
                    if(whereClause != ''){
                            whereClause = ' ( '+ whereClause +' ) AND ';
                    }
                    whereClause += ' ID NOT IN: excludedRecIds ';
                }
                
                system.debug(LoggingLevel.WARN, ' Where Clause is '+ whereClause);
                
                if(whereClause != ''){
                        lstFields = (new COMM_Utils_V2()).checkDuplicateFields(lstFields, eachObj); //Remove duplicate API Fields
                    String strFldNames =  objectDefinition.getObjectFieldNames(lstFields);
                    system.debug(LoggingLevel.WARN, 'Fields being queried are ' + strFldNames);
                    system.debug(LoggingLevel.WARN, 'Heap size before querying records = ' + Limits.getHeapSize());
                    //List<Sobject> lstsObjectRecords = Database.query('Select ' + strFldNames + ' FROM '+ eachObj + ' WHERE '+ whereClause + ' ALL ROWS ');
                    
                    List<Sobject> lstsObjectRecords = new List<Sobject>();
                    for(sobject eachRecord : Database.query('Select ' + strFldNames + ' FROM '+ eachObj + ' WHERE '+ whereClause + ' ALL ROWS '))
                    {
                            if( (eachObj != 'User' && eachRecord.get('isDeleted') == true) || (eachObj == 'User' && eachRecord.get('isActive') == false)){
                                setDeletedIds.add(String.valueOf(eachRecord.get('Id')));
                            }else{
                                lstsObjectRecords.add(eachRecord);
                            }
                    }
                    system.debug(LoggingLevel.WARN, 'Heap size after querying records = ' + Limits.getHeapSize());
                    
                    
                    if(setDeletedIds.size() > 0){
                        deletedRecIds.valueMap.add(new INTF_WebServicesDef.SVMXMap(eachObj, JSON.serialize(setDeletedIds))); 
                     }
                    
                    //Add lstsObjectRecords to response
                    INTF_WebServicesDef.SVMXMap eachObjResponse = new INTF_WebServicesDef.SVMXMap();
                    eachObjResponse.key = eachObj;
                    eachObjResponse.value = JSON.serialize(lstsObjectRecords);
                    txFetchValueMap.add(eachObjResponse);
                }
                
            }
            
            txFetchResponse.valueMap = txFetchValueMap;
            txFetchResponse.valueMap.add(deletedRecIds); 
            response.valueMap.add(txFetchResponse);
            response.success = true;
            
        }catch(Exception e){
            system.debug(LoggingLevel.WARN, 'e = ' + e);
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        
        return response;
    }
    
    public String formatFieldValue(String eachField, String fieldValueToProcess, Map<String,String> mapFieldAndItsType, Map<String,Integer> mapFieldAndItsScale ){
        
        if(mapFieldAndItsType.get(eachField) == 'DATETIME' && fieldValueToProcess != NULL && fieldValueToProcess != ''){
            fieldValueToProcess = fieldValueToProcess.replace('T',' ');
            fieldValueToProcess = fieldValueToProcess.replace('Z',' ');
            fieldValueToProcess = String.valueOfGmt(DateTime.valueOfGmt(fieldValueToProcess));
        }
        if(mapFieldAndItsType.get(eachField) == 'DATE' && fieldValueToProcess != NULL && fieldValueToProcess != ''){
            fieldValueToProcess = String.valueOfGmt(Date.valueOf(fieldValueToProcess));
        }
        if( (mapFieldAndItsType.get(eachField) == 'DOUBLE' || mapFieldAndItsType.get(eachField) == 'DECIMAL' || mapFieldAndItsType.get(eachField) == 'CURRENCY' || mapFieldAndItsType.get(eachField) == 'PERCENT') && fieldValueToProcess != NULL && fieldValueToProcess != ''){
            String strTempFldVal = fieldValueToProcess;
            strTempFldVal = strTempFldVal.replace('.',':');
            List<String> lstDecimal = strTempFldVal.split(':');
            if(lstDecimal != null && lstDecimal.size() >= 2){
                if(mapFieldAndItsScale.get(eachField) != null){
                    for(Integer i = 0; i < mapFieldAndItsScale.get(eachField) - lstDecimal[1].length(); i++){
                         fieldValueToProcess += '0';
                    }
                }else{
                    fieldValueToProcess = lstDecimal[0];
                }
            }
        }
        return fieldValueToProcess;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getAttachmentRecords(INTF_WebServicesDef.INTF_SFMResponse response, Map<String, String> objectPerIDMap, Datetime dtLastSyncTime){
            
        //1. Query Event window
        //2. Find events where WhatId = header Id
        //3. Query ADC where object name = attachment  - get the criteria from Mobile configuration as per the device
        //4. Query the attachments on the header with the criteria 
            
            
        Datetime dtToDate, dtFromDate, dtMovingDate;
        Datetime currentTime = Datetime.now();
        String strUserId = mapClientDetails.get('userid');
        
        String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:svmxGrpProfileId';
         
        String strDeviceType = '';
        if(mapClientDetails != NULL &&  mapClientDetails.get('DeviceName') != NULL){
            strDeviceType = mapClientDetails.get('DeviceName');
        } 
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(svmxGrpProfileId, strDeviceType);   //1query
        
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        
        system.debug(LoggingLevel.WARN,'***** mapClientDetails = '+ mapClientDetails);
        system.debug(LoggingLevel.WARN,'***** strMobConfQuery = '+ strMobConfQuery);
        system.debug(LoggingLevel.WARN,'***** svmxGrpProfileId = '+ svmxGrpProfileId);
        system.debug(LoggingLevel.WARN,'***** strDevConfId = '+ strDevConfId);
       
        Datetime dtLastSyncForRecord = dtLastSyncTime;
        String strRecordId = '';
        String objectName = '';
        String strTimeClause = '';
        for(String objName: objectPerIDMap.KeySet()){  //Will have only one header
            objectName = objName;
            strRecordId = objectPerIDMap.get(objName);
        }
         
        for(SVMXC__ServiceMax_Config_Data__c configData : Database.Query(strMobConfQuery)){     //2query
            Integer intValue = 10;
            
            if(configData.SVMXC__Display_Type__c == 'Synchronization To Remove Events'){
                if(configData.SVMXC__Internal_value__c != NULL && configData.SVMXC__Internal_value__c.length() > 0){
                    intValue = Integer.valueOf(configData.SVMXC__Internal_value__c);
                     if(intValue < 1){
                        intValue = 10;
                     }
                }
                dtFromDate = currentTime - (intValue + 1);
            }else if(configData.SVMXC__Display_Type__c == 'Synchronization To Get Events'){
                if(configData.SVMXC__Internal_value__c != NULL && configData.SVMXC__Internal_value__c.length() > 0){
                    intValue = Integer.valueOf(configData.SVMXC__Internal_value__c);
                    if(intValue < 1){
                        intValue = 10;
                    }
                }
                dtToDate = currentTime + intValue + 1;
                //if(dtLastSyncForRecord != null)
                        //dtMovingDate = dtLastSyncForRecord + intValue + 1;
            }
            
         }
         
         //Query the events where WhatId = strRecordId
         
         //sfdc event - Query 3 and 4
         List<Event> eventList = [select Id, WhatId from Event where ( (StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <=:dtToDate AND  EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate) ) AND OwnerId = :strUserId AND WhatID = :strRecordId ];
             List<SVMXC__SVMX_Event__c> svmxEventList = [Select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) AND SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId AND SVMXC__WhatId__c = :strRecordId];
         
         if( (eventList != NULL && eventList.size() > 0) || (svmxEventList != NULL && svmxEventList.size() > 0) ){ //There are events on this header records - get the ADC configuration
            
            //Device specific settings
            strMobConfQuery = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Display_Type__c, SVMXC__Ownership_Type__c, LastModifiedDate,SVMXC__SM_Files_Config__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Display_Type__c = \'Advanced Download Criteria\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:svmxGrpProfileId AND ( SVMXC__Object_Name__c = \'Attachment\' OR SVMXC__Object_Name__c = \'Files\') ';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            
            List<SVMXC__ServiceMax_Config_Data__c> lstAdvMobConfigForGrpProfile = Database.Query(strMobConfQuery);  //Query 5
            
            if( lstAdvMobConfigForGrpProfile != NULL && !lstAdvMobConfigForGrpProfile.isEmpty()){
                
                //There is some ADC on attachment - get the criteria and query the attachment
                String strCriteria = '';
                SVMXC__ServiceMax_Config_Data__c eachADCrec;
                SVMXC__ServiceMax_Config_Data__c fileADCRec;
                
                for(SVMXC__ServiceMax_Config_Data__c eachConfig: lstAdvMobConfigForGrpProfile){
                        if(eachConfig.SVMXC__Object_Name__c == 'Attachment'){
                            eachADCrec = eachConfig;
                        }else if(eachConfig.SVMXC__Object_Name__c == 'Files'){
                            fileADCRec = eachConfig;
                        }
                }
                        
                if(dtLastSyncForRecord != null)
                    strTimeClause = ' AND LastModifiedDate >= :dtLastSyncForRecord ';
                    
                //****** Process attachments******    
                            
                if(eachADCrec!= NULL && eachADCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && eachADCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0){
                
                    strCriteria = '(' + eachADCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                    //Query 6
                    for(SVMXC__ServiceMax_Config_Data__c eachDCExpr : [select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c =: eachADCrec.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC]){
                        String strObjNameAndField = '';
                        if(((eachDCExpr.SVMXC__Display_Type__c == 'REFERENCE' || eachDCExpr.SVMXC__Display_Type__c == 'ID') && eachDCExpr.SVMXC__Object_Name2__c != null)){
                            String strReferenceFieldIds = '';
                            strObjNameAndField += '\':' + eachDCExpr.SVMXC__Object_Name2__c + '\',\'' + eachDCExpr.SVMXC__Source_Field_Name__c + '\'';
                            if(eachDCExpr.SVMXC__Object_Name2__c == objectName){   //get then event WhatIds only for that object
                                for(sobject sObj : Database.query('Select LastModifiedDate, ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id =: strRecordId')){
                                    if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null){
                                        if(strReferenceFieldIds != '')
                                            strReferenceFieldIds += ',';
                                        strReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';   
                                    }
                                }
                            }
                            if(strReferenceFieldIds == '')
                                strReferenceFieldIds = '\'DummyListOfIds1\'';
                                
                            strCriteria = strCriteria.replace(strObjNameAndField, strReferenceFieldIds);
                            system.debug(LoggingLevel.WARN, '*****strCriteria = ' + strCriteria);
                            }else{
                                //criteria exists in variable strCriteria.  - CHECK THIS!!!!
                            }
                    }
                }else{
                        strCriteria = '';
                }
                if(eachADCrec != NULL && eachADCrec.SVMXC__Ownership_Type__c == 'My Records'){
                        if(strCriteria != '')
                             strCriteria = strCriteria + ' AND ';
                     strCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
                }
                
                system.debug(LoggingLevel.WARN, 'Final ADC Criteria = ' + strCriteria);
                system.debug(LoggingLevel.WARN, 'Select Id, isDeleted from Attachment where '+ strCriteria + strTimeClause + ' ALL ROWS');
                        
                if(strCriteria != ''){
                    
                        //Query the attachment:
                    List<Attachment> attList = Database.Query( 'Select Id, isDeleted from Attachment where '+ strCriteria + strTimeClause + ' ALL ROWS');
                    system.debug(LoggingLevel.WARN, '***** Attachments queried are = '+attList);
                
                        Set<String> attachmentIdSet = new Set<String>();
                    List<String> deletedAttIdSet = new List<String>();
                    for(Attachment att: attList ){
                        if(!att.isDeleted){
                            attachmentIdSet.add(att.Id);
                        }else{
                            deletedAttIdSet.add(att.Id);
                        }
                    }
                        
                    //Add this attachments to the Tx_Fetch list    
                    if(attList != NULL && attList.size() > 0){
                        if(recordIdsPerObjectMap.containsKey('Attachment')){
                            recordIdsPerObjectMap.get('Attachment').addAll(attachmentIdSet);
                        }else{
                            recordIdsPerObjectMap.put('Attachment',new Set<String>());
                            recordIdsPerObjectMap.get('Attachment').addAll(attachmentIdSet);
                        }
                    }
                    
                    //Add deleted Attachment Ids to the response
                    if(deletedAttIdSet.size() > 0){
                        INTF_WebServicesDef.SVMXMap attachmentMap = new INTF_WebServicesDef.SVMXMap();
                        attachmentMap.key = 'ATTACHMENTS';
                        attachmentMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('DELETED_ATTACHMENT_IDS',JSON.serialize(deletedAttIdSet)));
                        response.valueMap.add(attachmentMap);
                    }
                }
                
                //********** Process Files**********
                Boolean isFilesEnabled = COMM_FileHandlerUtilities.checkFileSetting();
                system.debug(LoggingLevel.WARN,'isFilesEnabled = '+isFilesEnabled);
                
                if(isFilesEnabled){
                    
                    CONF_MobileConfig.FileConfig fileConf = NULL;
                    Boolean filesEnabledforProfile = false;
                    String strFileTypes = '', lastSyncTimeClause = '', strFileTypeClause ='', strFileSizeClause = '';
                    Integer intMaxFileSize = 37;
                    Set<String> fileTypeList = new Set<String>();
                    Set<String> fileTagsList = new Set<String>();
                    Datetime configLastModifiedDate = null;
                        
                        if(fileADCRec != NULL){
                            configLastModifiedDate = fileADCRec.LastModifiedDate;
                            
                            if(fileADCRec.SVMXC__SM_Files_Config__c != NULL){
                            fileConf = (CONF_MobileConfig.FileConfig)JSON.deserialize(fileADCRec.SVMXC__SM_Files_Config__c, CONF_MobileConfig.FileConfig.class);
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
                            intMaxFileSize = intMaxFileSize * 1000 * 1000;
                            strFileSizeClause = ' AND ContentDocument.LatestPublishedVersion.ContentSize <=: intMaxFileSize ';
                            system.debug(LoggingLevel.WARN,'intMaxFileSize = '+intMaxFileSize);
                        }
                        }
                        
                    if(filesEnabledforProfile){
                            if(configLastModifiedDate <= dtLastSyncTime){
                                lastSyncTimeClause = ' AND ( ContentDocument.SystemModStamp >= :dtLastSyncTime OR SystemModStamp >= :dtLastSyncTime ) ';
                         }
                        
                         String strCDLQuery = ' Select Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Tagcsv, isDeleted, ContentDocument.isDeleted from ContentDocumentLink WHERE ( LinkedEntityID =: strRecordId )' + lastSyncTimeClause + strFileTypeClause + strFileSizeClause + ' ALL ROWS';
                         List<ContentDocumentLink> allCDLList = Database.Query(strCDLQuery);
                         system.debug(LoggingLevel.WARN, '***** allCDLList = '+allCDLList.size());  
                         
                         Set<String> linkIdList = new Set<String>(); 
                         Set<String> deletedLinkIds = new Set<String>();  //For deleted Ids  
                         Set<String> deletedVersionIds = new Set<String>();
                         Set<String> deletedDocIds = new Set<String>();
                        
                        for(ContentDocumentLink eachCDL: allCDLList){
                        
                            //Filter contentVersion based on tags
                            Boolean isTagAvailable = (new INTF_SFDCFilesUtilityServices()).checkAvailableTags(eachCDL.ContentDocument.LatestPublishedVersion.Tagcsv, fileTagsList);
                            
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
                            
                            //Add this attachments to the Tx_Fetch list  
                            if(linkIdList.size() > 0 ){
                                if(recordIdsPerObjectMap.get('ContentDocumentLink') == NULL){
                                    recordIdsPerObjectMap.put('ContentDocumentLink', new Set<String>());
                                }
                                recordIdsPerObjectMap.get('ContentDocumentLink').addAll(linkIdList);
                            }
                            
                        //Add deleted CDL Ids to the response
                        if(deletedLinkIds.size() > 0 || deletedDocIds.size() > 0 || deletedVersionIds.size() > 0 ){
                            INTF_WebServicesDef.SVMXMap filesMap = new INTF_WebServicesDef.SVMXMap();
                            filesMap.key = 'DELETED_FILES';
                            filesMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentVersion',JSON.serialize(deletedVersionIds)));
                            filesMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocument',JSON.serialize(deletedDocIds)));
                            filesMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('ContentDocumentLink',JSON.serialize(deletedLinkIds)));
                            response.valueMap.add(filesMap);
                        }
                    }
                }
                
                
            }
        }
        return response;
    }  
    
    public INTF_WebServicesDef.INTF_SFMResponse getChecklistRecords(INTF_WebServicesDef.INTF_SFMResponse response, Map<String, String> objectPerIDMap, Datetime dtLastSyncTime){
            //1. Check setting if checklist has been enabled
            //2. Query for mobile config - in Progress and completed checklist
            //3. Query all checklists related to the header record
            //4. Query all the checklist attachment records 
            
            if(objectPerIDMap != NULL && !objectPerIDMap.isEmpty()){
                
                List<String> headerRecordIds = new List<String>();
                headerRecordIds.addAll(objectPerIDMap.values());
                
                Boolean isChecklist = false;
                String strChklstStatusClause = '', strChklstStatus=  '', strTimeClause = '';
                
                String strMobConfQuery  = 'select SVMXC__Display_Type__c, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =: svmxGrpProfileId AND (SVMXC__Display_Type__c = \'Enable Checklist\' OR SVMXC__Display_Type__c = \'Completed Checklists\' OR SVMXC__Display_Type__c = \'InProgress Checklists\') ';
             
            String strDeviceType = '';
            if(mapClientDetails != NULL &&  mapClientDetails.get('DeviceName') != NULL){
                strDeviceType = mapClientDetails.get('DeviceName');
            } 
            String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(svmxGrpProfileId, strDeviceType);   //1query
            
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            
            for(SVMXC__ServiceMax_Config_Data__c eachConf : Database.Query(strMobConfQuery)){
                    if(eachConf.SVMXC__Display_Type__c == 'Enable Checklist' && eachConf.SVMXC__Internal_Value__c != null && eachConf.SVMXC__Internal_Value__c != ''){
                        isChecklist = Boolean.valueOf(eachConf.SVMXC__Internal_Value__c);
                    }else if(eachConf.SVMXC__Display_Type__c == 'Completed Checklists' && eachConf.SVMXC__Internal_Value__c != null && eachConf.SVMXC__Internal_Value__c != ''){
                        if(Boolean.valueOf(eachConf.SVMXC__Internal_Value__c)){
                        if(strChklstStatus != '')
                            strChklstStatus += ' OR SVMXC__Status__c = \'Completed\'';
                        else
                            strChklstStatus = ' SVMXC__Status__c = \'Completed\'';   
                    }
                    }else if(eachConf.SVMXC__Display_Type__c == 'InProgress Checklists' && eachConf.SVMXC__Internal_Value__c != null && eachConf.SVMXC__Internal_Value__c != ''){
                    if(Boolean.valueOf(eachConf.SVMXC__Internal_Value__c))
                    {
                        if(strChklstStatus != '')
                            strChklstStatus += ' OR SVMXC__Status__c = \'In Process\'';
                        else
                            strChklstStatus = ' SVMXC__Status__c = \'In Process\'';
                    }
                }
            }
        
            if(strChklstStatus != '' && strChklstStatus.length() > 0)
                strChklstStatusClause = ' AND (' + strChklstStatus + ')';
            else
                isChecklist = false;
             
            
            if(dtLastSyncTime != null)
                strTimeClause = ' AND LastModifiedDate >: dtLastSyncTime '; 
                
            if(isChecklist){
                    
                    //Query the checklist Ids  TODO: Need to define limit!!!!!
                    List<SVMXC__Checklist__c> allChecklist = Database.Query('Select Id, isDeleted, SVMXC__What_Id__c, LastModifiedDate from SVMXC__Checklist__c where SVMXC__What_Id__c IN: headerRecordIds '+strChklstStatusClause + strTimeClause + ' ALL ROWS');
                    
                    Set<String> checklistIdSet = new Set<String>();
                    List<String> deletedChkIdSet = new List<String>();
                    List<String> deletedChkAttIds = new List<string>();
                    List<String> deletedAttIds = new List<string>();
                    Set<String> setDeletedCDLIds = new Set<String>();
                    
                    for(SVMXC__Checklist__c chk: allChecklist ){
                        if(!chk.isDeleted){
                            checklistIdSet.add(chk.Id);
                        }else{
                            deletedChkIdSet.add(chk.Id);
                        }
                    }
                    
                    if(!checklistIdSet.isEmpty()){
                        //Query the checklist attachment records
                        List<SVMXC__SM_Checklist_Attachment__c> chkAttachmentList = Database.query('Select Id,SVMXC__SM_Attachment_ID__c, IsDeleted, SVMXC__SM_ContentDocumentLink_ID__c from SVMXC__SM_Checklist_Attachment__c where SVMXC__SM_Checklist__c IN: checklistIdSet' + strTimeClause + ' ALL ROWS');
                        
                        Set<String> chkAttIdSet = new Set<String>();
                        Set<String> attachmentIds = new Set<string>();
                        Set<String> lstDocLinkIds = new Set<String>();
                        
                        
                        for(SVMXC__SM_Checklist_Attachment__c chkAtt: chkAttachmentList ){
                            if(!chkAtt.isDeleted){
                                chkAttIdSet.add(chkAtt.Id);
                                if(chkAtt.SVMXC__SM_Attachment_ID__c != NULL)
                                        attachmentIds.add(chkAtt.SVMXC__SM_Attachment_ID__c);
                                if(chkAtt.SVMXC__SM_ContentDocumentLink_ID__c != NULL)           
                                    lstDocLinkIds.add(chkAtt.SVMXC__SM_ContentDocumentLink_ID__c);
                                  
                            }else{
                                deletedChkAttIds.add(chkAtt.Id);
                                if(chkAtt.SVMXC__SM_Attachment_ID__c != NULL)
                                        deletedAttIds.add(chkAtt.SVMXC__SM_Attachment_ID__c);
                                if(chkAtt.SVMXC__SM_ContentDocumentLink_ID__c != NULL)        
                                        setDeletedCDLIds.add(chkAtt.SVMXC__SM_ContentDocumentLink_ID__c); //CDL related to deleted checklist attachments
                                
                            }   
                        }
                        
                        //Add the checklists and checklist attachments to the Tx_Fetch list    
                        if(recordIdsPerObjectMap.get('SVMXC__Checklist__c') == NULL){
                            recordIdsPerObjectMap.put('SVMXC__Checklist__c', new Set<string>());
                        }
                        recordIdsPerObjectMap.get('SVMXC__Checklist__c').addAll(checklistIdSet);
                        
                        
                        if(recordIdsPerObjectMap.get('SVMXC__SM_Checklist_Attachment__c') == NULL){
                            recordIdsPerObjectMap.put('SVMXC__SM_Checklist_Attachment__c', new Set<string>());
                        }
                        recordIdsPerObjectMap.get('SVMXC__SM_Checklist_Attachment__c').addAll(chkAttIdSet);
                        
                        if(attachmentIds.size() > 0){
                                if(recordIdsPerObjectMap.get('Attachment') == NULL){
                                recordIdsPerObjectMap.put('Attachment', new Set<string>());
                            }
                            recordIdsPerObjectMap.get('Attachment').addAll(attachmentIds);
                        }
                        
                        if(lstDocLinkIds.size() > 0){
                            if(recordIdsPerObjectMap.get('ContentDocumentLink') == NULL){
                                recordIdsPerObjectMap.put('ContentDocumentLink', new Set<string>());
                            }
                            recordIdsPerObjectMap.get('ContentDocumentLink').addAll(lstDocLinkIds);
                        }
                    }
                    
                    //add deleted checklist/attachments to the response
                    if(deletedChkIdSet.size() > 0 || deletedChkAttIds.size() > 0 || deletedAttIds.size() > 0 || setDeletedCDLIds.size() > 0){
                        INTF_WebServicesDef.SVMXMap attachmentMap = new INTF_WebServicesDef.SVMXMap();
                        attachmentMap.key = 'CHECKLIST';
                        attachmentMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('DELETED_CHECKLIST_IDS',JSON.serialize(deletedChkIdSet)));
                        attachmentMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('DELETED_CHECKLIST_ATTACHMENT_IDS',JSON.serialize(deletedChkAttIds)));
                        attachmentMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('DELETED_ATTACHMENT_IDS',JSON.serialize(deletedAttIds)));
                        attachmentMap.valueMap.add(new INTF_WebServicesDef.SVMXMap('DELETED_CDL_IDS',JSON.serialize(setDeletedCDLIds)));
                        response.valueMap.add(attachmentMap);
                    }
                    
            }    
        }
        return response;
    }            
        
}