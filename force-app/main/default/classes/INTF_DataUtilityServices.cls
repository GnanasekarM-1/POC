public class INTF_DataUtilityServices
{
    public class SVMXException extends Exception{}
    public static List<string> lstSignatureIds;
    // Select task, event and related records with only Id
    public INTF_WebServicesDef.INTF_SFMResponse RequestDataFromBase(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('RequestDataFromBase');
        Sync_Utility clsUtility = new Sync_Utility();
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.SVMXMap> masterResponse = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXMap> multiWrapList;
        
        Datetime dtToDate, dtFromDate;
        Date ToDate, FromDate;
        Datetime currentTime = Datetime.now();
        
        try
        {
            Id idGrpProfile = clsUtility.getGroupProfileId(null, true);
                string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);
            system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);
            
            String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
            
            String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(idGrpProfile, strDeviceType);
       
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            system.debug(LoggingLevel.WARN,'Query formed for Events = '+strMobConfQuery);
         
            INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery); 
            List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfig = Database.Query(strMobConfQuery);
            if(lstMobileConfig != null && lstMobileConfig.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c objConfigData : lstMobileConfig)
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
                    }
                }       
            }
            FromDate = Date.valueOf(dtFromDate);
            ToDate = Date.valueOf(dtToDate);
            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'EVENT_SYNC')
            {
                INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
                INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();    
                String sUserId = UserInfo.getUserId();
                Set<Id> setIdsToRemove = new Set<Id>();
                //Retrieve all tasks for the requested range associated with the user
                INTF_DataSync.logSOQL(intMethodCount, 'Select Id from Task where OwnerId= :sUserId  and (ActivityDate <= : ToDate And ActivityDate >= :FromDate )');
                List<Task> incTasks  =  Database.query('Select Id from Task where OwnerId= :sUserId  and (ActivityDate <= : ToDate And ActivityDate >= :FromDate )');
                if(incTasks != null && incTasks.size() > 0)
                {
                    INTF_WebServicesDef.SVMXMap taskWrap = new INTF_WebServicesDef.SVMXMap();
                    taskWrap.key = 'Parent_Object';
                    taskWrap.value = 'Task';
                    multiWrapList = new List<INTF_WebServicesDef.SVMXMap>(); 
                    INTF_WebServicesDef.SVMXMap masterTaskWrap = new INTF_WebServicesDef.SVMXMap();
                    masterTaskWrap.key = 'Fields';
                    masterTaskWrap.value = JSON.serialize(incTasks);
                   
                    multiWrapList.add(masterTaskWrap);
                    taskWrap.valueMap = multiWrapList;
                    masterResponse.add(taskWrap); 
                }
                
                /************Service Power - Drip Feed***************/
                Boolean isDripFeed = false;
                String strListObjandFields = '';
                Set<Id> setEventIdsToRemove = new Set<Id>();
                Map<Id, List<Id>> mapEventIdToWhatId = new Map<Id, List<Id>>();
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                list<String> lstSettingId = new list<String>{'SET001','SET002'};
                map<String, String> mapSettForDispatch = new map<String, String>();
                mapSettForDispatch = commSettings.SVMX_getSettingList('DCON002', lstSettingId);
                system.debug(LoggingLevel.WARN,'Settings = ' + mapSettForDispatch);
                if(mapSettForDispatch.containskey('SET001') && mapSettForDispatch.get('SET001') != null && mapSettForDispatch.get('SET001').length() > 0)
                {
                    isDripFeed = Boolean.valueOf(mapSettForDispatch.get('SET001'));
                }
                if(mapSettForDispatch.containskey('SET002') && mapSettForDispatch.get('SET002') != null && mapSettForDispatch.get('SET002').length() > 0)
                {
                    strListObjandFields = String.valueOf(mapSettForDispatch.get('SET002'));
                }
                system.debug(LoggingLevel.WARN, 'isDripFeed = ' + isDripFeed + '; List of Objects configured = ' + strListObjandFields);
                
                if(isDripFeed)
                {
                    mapEventIdToWhatId = getDripFeedRelatedRecords(dtToDate, dtFromDate, sUserId, strListObjandFields);
                    setIdsToRemove.addAll(mapEventIdToWhatId.keySet());
                    for(Id eachId : mapEventIdToWhatId.keySet())
                        setEventIdsToRemove.addAll(mapEventIdToWhatId.get(eachId));
                }
                /***************************/
                
                string strEventSOQL = 'SELECT Id, What.Type, WhatId FROM Event WHERE (((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId= :sUserId and Id NOT IN :setEventIdsToRemove)';
                string set012 = getsettingIPAD018SET012();
                if(set012 != null)
                    strEventSOQL += ' ' + set012;
                system.debug(loggingLevel.WARN, 'Event Query: ' + strEventSOQL);
                INTF_DataSync.logSOQL(intMethodCount,strEventSOQL);
                List<Event> lstAllEvents  =  Database.query(strEventSOQL);
                if(lstAllEvents != null && lstAllEvents.size() > 0 )
                {
                    masterWrap.key = 'Parent_Object';
                    masterWrap.value = 'Event';
                    masterFieldWrap.key = 'Fields';
                    masterFieldWrap.value = JSON.serialize(lstAllEvents);
                    multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                    multiWrapList.add(masterFieldWrap);  
                    masterWrap.valueMap = multiWrapList;    
                    masterResponse.add(masterWrap);
                }
                
                string strSVMXEventSOQL = 'SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :sUserId and Id NOT IN :setEventIdsToRemove)';
                if(set012 != null)
                    strSVMXEventSOQL += ' ' + set012;
                system.debug(loggingLevel.WARN, 'ServiceMax Event Query: ' + strSVMXEventSOQL);
                INTF_DataSync.logSOQL(intMethodCount, strSVMXEventSOQL);
                List<SVMXC__SVMX_Event__c> lstAllSVMXEvents  =  Database.query(strSVMXEventSOQL);
                if(lstAllSVMXEvents != null && lstAllSVMXEvents.size() > 0 )
                    masterResponse.add(new INTF_WebServicesDef.SVMXMap('SVMXC__SVMX_Event__c', JSON.serialize(lstAllSVMXEvents)));
                
                Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
                allowedProcess = clsUtility.getSFMTransactions(NULL);
                Set<String> setAllowedObjects = new Set<String>();
                INTF_GetServiceFlowAccess flowAccess = new INTF_GetServiceFlowAccess();
                flowAccess.INTF_GetProcessObjects(allowedProcess);
                if(flowAccess.transactionalObjects != NULL && flowAccess.transactionalObjects.size() > 0)
                    setAllowedObjects.addAll(flowAccess.transactionalObjects);
                if(flowAccess.lookupObjects != NULL && flowAccess.lookupObjects.size() > 0)
                    setAllowedObjects.addAll(flowAccess.lookupObjects);
                    
                Map<String, INTF_WebServicesDef.SVMXMap> mapObjDefinitions = new Map<String, INTF_WebServicesDef.SVMXMap>();
                INTF_WebServicesDef.SVMXMap EachObjDef = new INTF_WebServicesDef.SVMXMap();
                List<Event> lstEvents = new List<Event>();
                List<String> recordIDs = new List<String>();
                lstEvents = GetObjsTaggedToEvents(dtFromDate, dtToDate, setAllowedObjects, setEventIdsToRemove);
                if((lstEvents != null && lstEvents.size() > 0) || (lstAllSVMXEvents != null && lstAllSVMXEvents.size() > 0))
                {                
                    String strAllObjs = '';
                    INTF_GetObjectDefinition clsObjectDef = new INTF_GetObjectDefinition();
                    for (Event evt: lstEvents)
                    {
                        if(evt.What.Type != null)
                        {
                            if(mapObjDefinitions.size() == 0 || (!mapObjDefinitions.containsKey(evt.What.Type)))
                            {
                                clsObjectDef.objectName = evt.What.Type;
                                EachObjDef = clsObjectDef.INTF_GetMasterChildDefinition();
                                mapObjDefinitions.put(evt.What.Type, EachObjDef);
                            }
                            recordIDs.Add(evt.WhatID);
                        }   
                    }
                    for (SVMXC__SVMX_Event__c evt: lstAllSVMXEvents)
                    {
                        if(evt.SVMXC__WhatId__c != null && evt.SVMXC__WhatId__c != '' && Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType() != null)
                        {
                            if(mapObjDefinitions.size() == 0 || (!mapObjDefinitions.containsKey(String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType()))))
                            {
                                clsObjectDef.objectName = String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType());
                                EachObjDef = clsObjectDef.INTF_GetMasterChildDefinition();
                                mapObjDefinitions.put(String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType()), EachObjDef);
                            }
                            recordIDs.Add(evt.SVMXC__WhatId__c);
                        }   
                    }
                    for(String objName: mapObjDefinitions.keySet())
                    {
                        strAllObjs += ', ' + objName;
                        if (recordIDs.size() > 0)
                        {
                            List<INTF_WebServicesDef.SVMXMap> objProps = new List<INTF_WebServicesDef.SVMXMap>();
                            objProps = mapObjDefinitions.get(objName).valueMap;
                            for(INTF_WebServicesDef.SVMXMap objProp : objProps)
                            {
                                if(objProp.key=='OBJECTPROPERTY')
                                {
                                    for(INTF_WebServicesDef.SVMXMap eachMasterDetail : objProp.valueMap)
                                    {
                                        for(INTF_WebServicesDef.SVMXMap masterDetail : eachMasterDetail.valueMap)
                                        {
                                            if(masterdetail.key=='MASTERDETAILS')
                                            {
                                                for(INTF_WebServicesDef.SVMXMap lstChild: masterdetail.valueMap)
                                                {
                                                    if(setAllowedObjects.contains(lstChild.key))
                                                    {
                                                        List<SObject> qryChildResult = GetChildDataSet(lstChild.key, lstChild.value, recordIDs);
                                                        if( qryChildResult!=null && qryChildResult.size() > 0 )
                                                        {
                                                            masterWrap = new INTF_WebServicesDef.SVMXMap();
                                                            masterWrap.key = 'Child_Object';
                                                            masterWrap.value = lstChild.key;
                                        
                                                            masterFieldWrap = new INTF_WebServicesDef.SVMXMap();    
                                                            masterFieldWrap.key = 'Fields';
                                                            masterFieldWrap.value = JSON.serialize(qryChildResult);
                                                                        
                                                            multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                                            multiWrapList.add(masterFieldWrap);  
                                                            masterWrap.valueMap = multiWrapList;    
                                                            masterResponse.add(masterWrap);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id FROM ' + objName + ' WHERE Id IN :recordIDs');
                            List<SObject> qryResult = Database.query('SELECT Id FROM ' + objName + ' WHERE Id IN :recordIDs');
                            if (qryResult != null && qryResult.size() > 0)
                            {
                                masterWrap = new INTF_WebServicesDef.SVMXMap();
                                masterWrap.key = 'Parent_Object';
                                masterWrap.value = objName;
    
                                masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                                masterFieldWrap.key = 'Fields';
                                masterFieldWrap.value = Json.serialize(qryResult);
                                
                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                multiWrapList.add(masterFieldWrap);  
                                masterWrap.valueMap = multiWrapList;
                                masterResponse.add(masterWrap);
                            }
                        }
                    }
                }
                INTF_WebServicesDef.SVMXMap CurrentTimeMap = new INTF_WebServicesDef.SVMXMap();
                CurrentTimeMap.key = 'LAST_SYNC'; 
                CurrentTimeMap.value = String.valueOf(currentTime);
                masterResponse.add(CurrentTimeMap);
                response.valueMap = masterResponse;
                response.success = true;
                
                //cache the eventIds
                if(!recordIDs.isEmpty()){ 
                        updateEventIdsInRequestCache(recordIDs, NULL, inputRequest);
                }
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        system.debug(LoggingLevel.WARN, 'Response = ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'RequestDataFromBase');
        return response;
    }
    
    public Map<Id, List<Id>> getDripFeedRelatedRecords(Datetime dtToDate, Datetime dtFromDate, String sUserId, String strListObjandFields)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDripFeedRelatedRecords');
        Set<Id> setWhatIds = new Set<Id>();
        Map<String, String> mapObjToDripField = new Map<String, String>();
        Map<Id, List<Id>> mapEventIdToWhatId = new Map<Id, List<Id>>();
        if(strListObjandFields != null && strListObjandFields.length() > 0)
        {
            List<String> lstObjField = strListObjandFields.split(',');
            for(String strObjField : lstObjField)
            {
                strObjField = strObjField.replace('.',':');
                List<String> lstObjectAndFields = new List<String>();
                lstObjectAndFields = strObjField.split(':');
                if(lstObjectAndFields != null && lstObjectAndFields.size() == 2)
                    mapObjToDripField.put(lstObjectAndFields[0], lstObjectAndFields[1]);
            }
            system.debug(LoggingLevel.WARN, 'mapObjToDripField Before = ' + mapObjToDripField);
            for(String ObjName : mapObjToDripField.keySet())
            {
                Set<String> setFieldNames = new Set<String>();
                system.debug(LoggingLevel.WARN, 'Object name = ' + ObjName);
                INTF_WebServicesDef.SVMXMap objDef = new INTF_WebServicesDef.SVMXMap();
                try
                {
                    INTF_GetObjectDefinition objectDef = new INTF_GetObjectDefinition();
                    objectDef.objectName = ObjName;
                    objDef = objectDef.INTF_GetObjectDefinition();
                    if(objDef != NULL) 
                    {
                        for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                        {
                            if(objProp.key=='FIELDPROPERTY')
                            {
                                for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                {
                                    setFieldNames.add(lstField.value);
                                }
                            }
                        }
                    }
                }
                catch(Exception ex)
                {
                    system.debug(LoggingLevel.WARN,'Exception occurred = ' + ex.getMessage());
                    mapObjToDripField.remove(ObjName);
                }
                if(!setFieldNames.contains(mapObjToDripField.get(ObjName)))
                {
                    //system.debug(LoggingLevel.WARN, 'Field Name in Setting = ' + mapObjToDripField.get(ObjName) + '; Field Name as in Describe = ' + lstField.value);
                    mapObjToDripField.remove(ObjName);
                }
            }
            system.debug(LoggingLevel.WARN, 'mapObjToDripField After = ' + mapObjToDripField);
            if(mapObjToDripField.containsKey('Event') && mapObjToDripField.get('Event') != null && mapObjToDripField.get('Event').length() > 0)
            {
                String strDripField = mapObjToDripField.get('Event');
                INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id, WhatId, What.Type, ' + strDripField + ' FROM Event WHERE (((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId= :sUserId and WhatId != null)');
                for(Event evt : Database.query('SELECT Id, WhatId, What.Type, ' + strDripField + ' FROM Event WHERE (((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId= :sUserId and WhatId != null)'))
                {
                    if(evt.get(strDripField) == false)
                    {
                        if(mapEventIdToWhatId.keySet().contains(String.valueOf(evt.get('WhatId'))))
                            mapEventIdToWhatId.get(String.valueOf(evt.get('WhatId'))).add(String.valueOf(evt.get('Id')));
                        else
                        {
                            List<Id> lstEventIds = new List<Id>();
                            lstEventIds.add(String.valueOf(evt.get('Id')));
                            mapEventIdToWhatId.put(String.valueOf(evt.get('WhatId')), lstEventIds);
                        }
                        system.debug(LoggingLevel.WARN, 'Event Id = ' + evt.Id + '; What Id = ' + evt.WhatId + '; What.Type = ' + String.valueOf(evt.What.Type));
                    }
                }
                system.debug(LoggingLevel.WARN, 'Set of WhatIds whose event drip field is false = ' + setWhatIds);
            }
            //this else condition is for supporting drip feed in multiday event
            else if(mapObjToDripField.containsKey('SVMXC__SVMX_Event__c') && mapObjToDripField.get('SVMXC__SVMX_Event__c') != null && mapObjToDripField.get('SVMXC__SVMX_Event__c').length() > 0)
            {
                String strDripField = mapObjToDripField.get('SVMXC__SVMX_Event__c');
                INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id, SVMXC__WhatId__c, ' + strDripField + ' FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :sUserId and SVMXC__WhatId__c != null)');
                for(SVMXC__SVMX_Event__c evt : Database.query('SELECT Id, SVMXC__WhatId__c, ' + strDripField + ' FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :sUserId and SVMXC__WhatId__c != null)'))
                {
                    if(evt.get(strDripField) == false)
                    {
                        if(mapEventIdToWhatId.keySet().contains(String.valueOf(evt.get('SVMXC__WhatId__c'))))
                            mapEventIdToWhatId.get(String.valueOf(evt.get('SVMXC__WhatId__c'))).add(String.valueOf(evt.get('Id')));
                        else
                        {
                            List<Id> lstEventIds = new List<Id>();
                            lstEventIds.add(String.valueOf(evt.get('Id')));
                            mapEventIdToWhatId.put(String.valueOf(evt.get('SVMXC__WhatId__c')), lstEventIds);
                        }
                        system.debug(LoggingLevel.WARN, 'Event Id = ' + evt.Id + '; What Id = ' + evt.SVMXC__WhatId__c + '; What.Type = ' + Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType());
                    }
                }
                system.debug(LoggingLevel.WARN, 'Set of WhatIds whose event drip field is false = ' + setWhatIds);
            }
            else
            {
                INTF_DataSync.logSOQL(intMethodCount,'SELECT Id, WhatId, What.Type FROM Event WHERE (((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId= :sUserId and WhatId != null)');
                for(Event ev : [SELECT Id, WhatId, What.Type FROM Event WHERE (((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId= :sUserId and WhatId != null)])
                {
                    if(mapEventIdToWhatId.keySet().contains(ev.WhatId))
                        mapEventIdToWhatId.get(ev.WhatId).add(ev.Id);
                    else
                    {
                        List<Id> lstEventIds = new List<Id>();
                        lstEventIds.add(String.valueOf(ev.get('Id')));
                        mapEventIdToWhatId.put(String.valueOf(ev.get('WhatId')), lstEventIds);
                    }
                    if(!mapObjToDripField.keySet().contains(ev.What.Type))
                        mapEventIdToWhatId.remove(ev.WhatId);
                }
                //this for loop is for supporting drip feed in multiday event 
                INTF_DataSync.logSOQL(intMethodCount,'SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :sUserId and SVMXC__WhatId__c != null)'); 
                for(SVMXC__SVMX_Event__c ev : [SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :sUserId and SVMXC__WhatId__c != null)])
                {
                    if(mapEventIdToWhatId.keySet().contains(ev.SVMXC__WhatId__c))
                        mapEventIdToWhatId.get(ev.SVMXC__WhatId__c).add(ev.Id);
                    else
                    {
                        List<Id> lstEventIds = new List<Id>();
                        lstEventIds.add(String.valueOf(ev.get('Id')));
                        mapEventIdToWhatId.put(String.valueOf(ev.get('SVMXC__WhatId__c')), lstEventIds);
                    }
                    if(!mapObjToDripField.keySet().contains(String.valueOf(Id.valueOf(ev.SVMXC__WhatId__c).getsObjectType())))
                        mapEventIdToWhatId.remove(ev.SVMXC__WhatId__c);
                }
            }
            setWhatIds.addAll(mapEventIdToWhatId.keySet());
            system.debug(LoggingLevel.WARN,'mapEventIdToWhatId = ' + mapEventIdToWhatId);
            system.debug(LoggingLevel.WARN, 'mapObjToDripField After removing Event = ' + mapObjToDripField);
            mapObjToDripField.remove('Event');
            for(String ObjName : mapObjToDripField.keySet())
            {
                if(mapObjToDripField.get(ObjName) != null && mapObjToDripField.get(ObjName).length() > 0)
                {
                    String strDripField = mapObjToDripField.get(ObjName);
                    INTF_DataSync.logSOQL(intMethodCount,'SELECT Id, ' + strDripField + ' FROM ' + ObjName + ' WHERE Id IN:setWhatIds');
                    for(sObject obj : Database.query('SELECT Id, ' + strDripField + ' FROM ' + ObjName + ' WHERE Id IN:setWhatIds'))
                    {
                        if(obj.get(strDripField) == false)
                        {
                            //setIdsToRemove.add(obj.Id);
                        }
                        else
                        {
                            mapEventIdToWhatId.remove(String.valueOf(obj.get('Id')));
                        }
                    }
                }
            } 
        }
        system.debug(LoggingLevel.WARN, 'Map of WhatId and EventId to remove for which both Drip Feed field is False = ' + mapEventIdToWhatId);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getDripFeedRelatedRecords');
        return mapEventIdToWhatId;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse RequestForCriteriaRecords(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS( 'RequestForCriteriaRecords');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.SVMXMap> masterResponse = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXMap> masterWrapList;
        List<INTF_WebServicesDef.SVMXMap> reqValMap = inputRequest.valueMap;
        List<String> lstUserTrunk = new List<String>();
        List<String> recordIds = new List<String>();
        if(inputRequest.values != null)
            recordIds = inputRequest.values;
        else
            recordIds.add(null);
        
        Set<String> setOldPriceBookIds = new Set<String>();
        Set<String> setOldServicePriceBookIds = new Set<String>();
        Iterator<INTF_WebServicesDef.SVMXMap> inputIterator = reqValMap.iterator();
        List<SVMXC__Sync_Request_Records__c> criteriaObjects = new List<SVMXC__Sync_Request_Records__c>();
        String strOldTechLocId = '';
        Datetime dtToDate, dtFromDate, LastSynchTime;
        Date ToDate, FromDate;
        Datetime currentTime = Datetime.now();
        String strDeviceName = '';
        
        Map<String,String> obj_clause = new Map<String,String>();
         
        for(INTF_WebServicesDef.SVMXMap TimeStampMap : inputRequest.valueMap)
        {
            if(TimeStampMap.key == 'RANGE_START')
            {
                dtFromDate = Datetime.valueOf(TimeStampMap.value);
                FromDate = Date.valueOf(TimeStampMap.value);
            }
            else if(TimeStampMap.key == 'RANGE_END') 
            {
                dtToDate = Datetime.valueOf(TimeStampMap.value);
                ToDate = Date.valueOf(TimeStampMap.value);
            }
            else if(TimeStampMap.key == 'LAST_SYNC_TIME')
            {
                LastSynchTime = Datetime.valueOf(TimeStampMap.value);
            }
            else if(TimeStampMap.key == 'DOWNLOAD_CRITERIA_OBJECTS')
            {
                
                System.debug(LoggingLevel.WARN, 'DC Objects from client' + TimeStampMap.valueMap);
                if(TimeStampMap.valueMap != null)
                {
                    for(INTF_WebServicesDef.SVMXMap dc_object :TimeStampMap.valueMap)
                    {
                        Blob afterblob = EncodingUtil.base64Decode(dc_object.value);
                        String str = afterblob.toString();
                        obj_clause.put(dc_object.key,str);
                    }
                }
                System.debug(LoggingLevel.WARN, 'DC Objects from client' + obj_clause);
            }
            else if(TimeStampMap.key == 'PRICEBOOK_IDs')
            {
                if(TimeStampMap.values != null && TimeStampMap.values.size() > 0)
                    setOldPriceBookIds.addAll(TimeStampMap.values);
            }
            else if(TimeStampMap.key == 'SERVICE_PRICEBOOK_IDs')
            {
                if(TimeStampMap.values != null && TimeStampMap.values.size() > 0)
                    setOldServicePriceBookIds.addAll(TimeStampMap.values);
            }
        }
        
        if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
        {
            for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
            {
                for(String strInfo : clientInform.clientInfo)
                {
                    if(strInfo != null && strInfo.length() > 0 && strInfo.contains('usertrunklocation'))
                    {
                        lstUserTrunk = strInfo.split(':');
                        if(lstUserTrunk != null && lstUserTrunk.size() == 2)
                            strOldTechLocId = lstUserTrunk[1];
                    }
                }
                //Get Device type
                if(clientInform.clientType != null){
                    strDeviceName = clientInform.clientType;
                }                
            }
        }
        system.debug(LoggingLevel.WARN, 'Technician Location Id = ' + strOldTechLocId);
        
        String Record_id;
        List<SVMXC__Sync_Request__c> Sync_request_id = new List<SVMXC__Sync_Request__c>();
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value');
        Sync_request_id =[Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(Sync_request_id.size()>0)
        {
            INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__Iteration_Index__c, SVMXC__Object_Name__c, SVMXC__SOQL_Query__c, SVMXC__Status__c, SVMXC__Record_Id__c, SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Operation_Type__c = \'Select\' and SVMXC__Sync_Request__c =: Sync_request_id[0].id');
            criteriaObjects = [Select Id, SVMXC__Iteration_Index__c, SVMXC__Object_Name__c, SVMXC__SOQL_Query__c, SVMXC__Status__c, SVMXC__Record_Id__c, SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Operation_Type__c = 'Select' and SVMXC__Sync_Request__c =: Sync_request_id[0].id];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            Record_id = Sync_request_id[0].id;
        }
        try
        {
            if(criteriaObjects.size() <= 0)
            {
                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                {
                    if(Sync_request_id.size() == 0)
                    {
                        SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = inputRequest.value);
                        Database.SaveResult Result = Database.insert(requestRecord);
                        Record_id = Result.getId();
                    }
                    List<SVMXC__Sync_Request_Records__c> DCObjectList = new List<SVMXC__Sync_Request_Records__c>(); 
                    masterWrapList = new List<INTF_WebServicesDef.SVMXMap>(); 
                    Map<String, INTF_WebServicesDef.SVMXMap> mapDownloadCriteriaObjDefns = new Map<String, INTF_WebServicesDef.SVMXMap>();
                    mapDownloadCriteriaObjDefns = getDownloadCriteriaObjDefns(strDeviceName);
                    if(mapDownloadCriteriaObjDefns != null && !mapDownloadCriteriaObjDefns.isEmpty())
                    {
                        System.debug(LoggingLevel.info,'Inside dwlod criteria'+mapDownloadCriteriaObjDefns.size());
                        List<String> objs_clauses = new List<String>();
                        for(String objName: mapDownloadCriteriaObjDefns.keySet())
                        {
                            System.debug(LoggingLevel.WARN,'DC object name : '+objName);
                            String strQuery = 'SELECT Id FROM ' + objName + ' WHERE ';
                            if (mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                            {
                                strQuery +=  ' (' + mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                            }
                            
                            strQuery = strQuery.replace('SVMX.CURRENTUSERID15', UserInfo.getUserId().substring(0,15));
                            strQuery = strQuery.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());
                            strQuery = strQuery.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
                            String strTechLocId = '';
                            INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
                            for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
                            {
                                if(eachTech.SVMXC__Inventory_Location__c != null)
                                    strTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
                            }
                            strQuery = strQuery.replace('SVMX.USERTRUNK', strTechLocId);
                            
                            Map<String, String> mapSFCSToValue = replaceLiteralWithValue(strQuery);
                            for(String eachLiteral : mapSFCSToValue.keySet())
                            {
                                system.debug(LoggingLevel.Debug, 'Literal Key = ' + eachLiteral + '; Value = ' + mapSFCSToValue.get(eachLiteral));
                                strQuery = strQuery.replace(eachLiteral, mapSFCSToValue.get(eachLiteral));
                            }
                            system.debug(LoggingLevel.Debug, 'After Replace = ' + strQuery);
                            
                            SVMXC__Sync_Request_Records__c DCObjects = new SVMXC__Sync_Request_Records__c(SVMXC__Sync_Request__c = Record_id, SVMXC__Operation_Type__c = 'Select' , SVMXC__Iteration_Index__c = 0 , SVMXC__Object_Name__c = objName , SVMXC__SOQL_Query__c = strQuery , SVMXC__Status__c = 'NOT_EXECUTED');
                            DCObjectList.add(DCObjects);
                            String werClause = mapDownloadCriteriaObjDefns.get(objName).value;
                            Blob blobStr = blob.valueOf(werClause);
                            String encodeStr = EncodingUtil.base64Encode(blobStr);
                            objs_clauses.add(objName+','+encodeStr);
                        }
                        
                        masterWrapList.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'True'));
                        masterWrapList.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
                        masterWrapList.add(new INTF_WebServicesDef.SVMXMap('DOWNLOAD_CRITERIA_OBJECTS', '', objs_clauses));
                    }
                    response.valueMap = masterWrapList; 
                    List<Database.Saveresult> ObjectSaveResult = Database.insert(DCObjectList);
                }
                else if(inputRequest.eventName == 'GET_INSERT_DOWNLOAD_CRITERIA' || inputRequest.eventName == 'GET_UPDATE_DOWNLOAD_CRITERIA' || inputRequest.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA')
                {
                    masterWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                    INTF_DataSync.logSOQL(intMethodCount,'Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value');
                    List<SVMXC__Sync_Request__c> sync_requests = [Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    Record_id = sync_requests[0].Id;
                    List<SVMXC__Sync_Request_Records__c> DCObjectList = new List<SVMXC__Sync_Request_Records__c>();
                    String deltaClause;
                    Set<String> setDCPriceCalcObjects = new Set<String>();
                    Set<String> setPriceCalObjects = new Set<String>{'SVMXC__Entitlement_History__c', 'SVMXC__Warranty__c', 'SVMXC__Service_Contract__c', 'SVMXC__Pricing_Rule__c', 'SVMXC__Parts_Pricing__c', 'SVMXC__Parts_Discount__c', 'SVMXC__Labor_Pricing__c', 'SVMXC__Expense_Pricing__c', 'SVMXC__Travel_Policy__c', 'SVMXC__Mileage_Tiers__c', 'SVMXC__Zone_Pricing__c', 'SVMXC__Service_Contract_Services__c', 'SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c', 'Pricebook2', 'PricebookEntry', 'SVMXC__Service_Pricebook__c', 'SVMXC__Service_Pricebook_Entry__c', 'SVMXC__Custom_Coverage__c'};
                    
                    if (inputRequest.eventName == 'GET_INSERT_DOWNLOAD_CRITERIA')
                        deltaClause = ' CreatedDate >= :LastSynchTime and isDeleted = false ';
                    
                    else if (inputRequest.eventName == 'GET_UPDATE_DOWNLOAD_CRITERIA')
                        deltaClause = ' LastModifiedDate >= :LastSynchTime and isDeleted = false ';
                    
                    else if (inputRequest.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA')
                    {
                        deltaClause = ' LastModifiedDate >= :LastSynchTime and isDeleted = true ';
                        Boolean isGetPriceEnabled = false;
                        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                        List<String> lstSettingId = new list<String>();
                        lstSettingId.add('SET009');
                        Map<String, String> mapSettingsForIPAD018 = new Map<String, String>();
                        mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
                        if(mapSettingsForIPAD018.containskey('SET009') && mapSettingsForIPAD018.get('SET009') != null)
                        {
                            isGetPriceEnabled = Boolean.valueOf(mapSettingsForIPAD018.get('SET009'));
                        }
                        else
                            isGetPriceEnabled = false;
                        if(isGetPriceEnabled)   
                            setDCPriceCalcObjects.addAll(setPriceCalObjects);
                    }
                    String strCurrTechLocId = '';
                    INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1' );
                    for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
                    {
                        if(eachTech.SVMXC__Inventory_Location__c != null)
                            strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
                    }
                    Map<String, INTF_WebServicesDef.SVMXMap> mapDownloadCriteriaObjDefns = new Map<String, INTF_WebServicesDef.SVMXMap>(); 
                    mapDownloadCriteriaObjDefns = getDownloadCriteriaObjDefns(strDeviceName);
                    
                    setDCPriceCalcObjects.addAll(mapDownloadCriteriaObjDefns.keySet());
                    system.debug(LoggingLevel.WARN, 'Set of Objects' + setDCPriceCalcObjects);
                    if(mapDownloadCriteriaObjDefns != null && !mapDownloadCriteriaObjDefns.isEmpty())
                    {
                        List<String> objs_clauses = new List<String>();
                        for(String objName: setDCPriceCalcObjects)
                        {
                            //system.debug(LoggingLevel.WARN, ' Last Sync Time = ' + LastSynchTime + ', Last Modified Date = ' + mapDownloadCriteriaObjDefns.get(objName).values[0] + ', valueOfGMT = ' + Datetime.valueOfGmt(mapDownloadCriteriaObjDefns.get(objName).values[0]));
                            system.debug(LoggingLevel.WARN, ' DC Object Name = ' + objName + ', value = ' + mapDownloadCriteriaObjDefns.get(objName));
                            if(objName == 'User')
                            {
                                deltaClause = deltaClause.replace('isDeleted = false','isActive = true');
                                deltaClause = deltaClause.replace('isDeleted = true','isActive = false');
                            }
                            else 
                            {
                                deltaClause = deltaClause.replace('isActive = true','isDeleted = false');
                                deltaClause = deltaClause.replace('isActive = false','isDeleted = true');
                            }
                            String strQuery = 'SELECT Id FROM ' + objName + ' WHERE ';
                            if(inputRequest.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA')
                            {
                                if(mapDownloadCriteriaObjDefns.get(objName) != NULL)
                                {
                                    if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                    {
                                        strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                    }
                                }
                                strQuery += deltaClause + ' and ';
                            }
                            else if(inputRequest.eventName == 'GET_INSERT_DOWNLOAD_CRITERIA')
                            {
                                if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                {
                                    strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                }
                                strQuery += deltaClause + ' and ';
                            }
                            else if(inputRequest.eventName == 'GET_UPDATE_DOWNLOAD_CRITERIA')
                            {
                                if(mapDownloadCriteriaObjDefns.get(objName).values != null && mapDownloadCriteriaObjDefns.get(objName).values.size() > 0)
                                {
                                    if(Datetime.valueOfGmt(mapDownloadCriteriaObjDefns.get(objName).values[0]) > LastSynchTime)
                                    {
                                        if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                        {
                                            strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                        }
                                    }
                                    else if(mapDownloadCriteriaObjDefns.get(objName).record != null)
                                    { 
                                        if(((SVMXC__ServiceMax_Processes__c)mapDownloadCriteriaObjDefns.get(objName).record).LastModifiedDate > LastSynchTime)
                                        {
                                            if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                            {
                                                strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                            }
                                        }
                                        else if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                        {
                                            if(mapDownloadCriteriaObjDefns.get(objName).value.containsIgnoreCase('USERTRUNK') && strCurrTechLocId != strOldTechLocId)
                                            {
                                                strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                            }
                                            else if(objName == 'Pricebook2')
                                                strQuery +=  ' ((' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID IN:setOldPriceBookIds AND ' + deltaClause + ') OR (' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID NOT IN:setOldPriceBookIds)) AND ';
                                            else if(objName == 'SVMXC__Service_Pricebook__c')
                                                strQuery +=  ' ((' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID IN:setOldServicePriceBookIds AND ' + deltaClause + ') OR (' + mapDownloadCriteriaObjDefns.get(objName).value + ' AND ID NOT IN:setOldServicePriceBookIds)) AND ';
                                            else
                                                strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ' + deltaClause + ' and ';
                                        }
                                    }
                                    else
                                    {
                                        if(mapDownloadCriteriaObjDefns.get(objName).value != NULL && mapDownloadCriteriaObjDefns.get(objName).value != '')
                                        {
                                            strQuery +=  ' ('+ mapDownloadCriteriaObjDefns.get(objName).value + ') and ';
                                        }
                                        strQuery += deltaClause + ' and ';
                                    }
                                }
                            }
                            
                            system.debug(LoggingLevel.WARN, ' Query for Each DC Object' + strQuery);
                            
                            strQuery = strQuery.replace('SVMX.CURRENTUSERID15', UserInfo.getUserId().substring(0,15));
                            strQuery = strQuery.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());
                            strQuery = strQuery.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
                            strQuery = strQuery.replace('SVMX.USERTRUNK', strCurrTechLocId);
                            
                            Map<String, String> mapSFCSToValue = replaceLiteralWithValue(strQuery);
                            for(String eachLiteral : mapSFCSToValue.keySet())
                            {
                                system.debug(LoggingLevel.Debug, 'Literal Key = ' + eachLiteral + '; Value = ' + mapSFCSToValue.get(eachLiteral));
                                strQuery = strQuery.replace(eachLiteral, mapSFCSToValue.get(eachLiteral));
                            }
                            system.debug(LoggingLevel.Debug, 'After Replace = ' + strQuery);
                            
                            if(inputRequest.eventName == 'GET_UPDATE_DOWNLOAD_CRITERIA' || inputRequest.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA' || inputRequest.eventName == 'GET_INSERT_DOWNLOAD_CRITERIA')
                            {
                                SVMXC__Sync_Request_Records__c DCObjects = new SVMXC__Sync_Request_Records__c(SVMXC__Sync_Request__c = Record_id, SVMXC__Operation_Type__c = 'Select', SVMXC__Iteration_Index__c = 0, SVMXC__Object_Name__c = objName, SVMXC__SOQL_Query__c = strQuery, SVMXC__Status__c = 'NOT_EXECUTED');
                                DCObjectList.add(DCObjects);
                            }
                            if(mapDownloadCriteriaObjDefns.get(objName) != null)
                            {
                                String werClause = mapDownloadCriteriaObjDefns.get(objName).value;
                                Blob blobStr = blob.valueOf(werClause);
                                String encodeStr = EncodingUtil.base64Encode(blobStr); 
                                objs_clauses.add(objName + ',' + encodeStr);
                            }
                        }
                        INTF_WebServicesDef.SVMXMap call_back = new INTF_WebServicesDef.SVMXMap();
                        call_back.key = 'CALL_BACK';
                        call_back.value = 'false';
                        if(DCObjectList.size() > 0)
                            call_back.value = 'True';
                        masterWrapList.add(call_back);
                        masterWrapList.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', '0'));
                        masterWrapList.add(new INTF_WebServicesDef.SVMXMap('DOWNLOAD_CRITERIA_OBJECTS', '', objs_clauses));
                        System.debug(LoggingLevel.WARN, 'master wrap list' + masterWrapList);
                    }
                    response.valueMap = masterWrapList;
                    List<Database.Saveresult> ObjectSaveResult = Database.insert(DCObjectList);
                }
            }
            else
            {
                List<String> SFDC_Records = new List<String>();
                INTF_DataSync.logSOQL(intMethodCount,'Select SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__r.SVMXC__Client_Request_Id__c = :inputRequest.value and SVMXC__Operation_Type__c != \'Select\'');
                List<SVMXC__Sync_Request_Records__c> Request_Records = [Select SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__r.SVMXC__Client_Request_Id__c = :inputRequest.value and SVMXC__Operation_Type__c != 'Select'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(Request_Records != null || Request_Records.size() > 0)
                {
                    for(SVMXC__Sync_Request_Records__c request_record : Request_Records)
                    {
                        SFDC_Records.add(request_record.SVMXC__SFDC_Record_Id__c);
                    }
                }
                
                List<INTF_WebServicesDef.SVMXMap> multiWrapList;
                Integer batch_index, current_batch_index;
                String HighestId , LowestId;
                Integer recordsLimit = 35000; 
                
                map<String, String> mapSettingsForIPAD018 = new map<String, String>();
                SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                list<String> lstSettingId = new list<String>();
                lstSettingId.add('SET006');
                mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                
                if(mapSettingsForIPAD018.containskey('SET006') && mapSettingsForIPAD018.get('SET006') != null && mapSettingsForIPAD018.get('SET006').length() > 0)
                {
                    recordsLimit = Integer.valueOf(mapSettingsForIPAD018.get('SET006'));
                }
                if(recordsLimit < 1)
                {
                    recordsLimit = 35000;
                } 
                while(inputIterator.hasNext())
                {
                    INTF_WebServicesDef.SVMXMap selObject = new  INTF_WebServicesDef.SVMXMap();
                    selObject = inputIterator.next();
                    System.debug(LoggingLevel.WARN,'sb object---'+selObject);
                    if(selObject.key == 'LAST_INDEX')
                    {
                        batch_index = Integer.valueOf(selObject.value);
                        current_batch_index = batch_index + 1;
                        System.debug(LoggingLevel.WARN,'Current batch index-- '+current_batch_index); 
                    }
                }
                
                List<Integer> ser_batch_indexes = new List<Integer>();
                for(Integer i = 0 ; i< criteriaObjects.size(); i++)
                {
                    Integer a = Integer.valueOf(criteriaObjects[i].SVMXC__Iteration_Index__c);
                    ser_batch_indexes.add(a);
                }
                ser_batch_indexes.sort();
                Integer siz = ser_batch_indexes.size();
                Integer server_higestIndex = ser_batch_indexes[siz-1];
                Integer record_count = 0;
                Boolean callBack = false;
                String strLastId = '';
                
                if(server_higestIndex == batch_index)
                {
                    for(Integer j=0 ; j < criteriaObjects.size() ; j++)
                    {
                        callBack = true;
                        if(criteriaObjects[j].SVMXC__Status__c != 'EXECUTED')
                        {                   
                            system.debug(LoggingLevel.WARN, 'Record Limit ' + recordsLimit);
                            if(record_count == 35000)
                            {
                                break;
                            } 
                            String query = criteriaObjects[j].SVMXC__SOQL_Query__c; 
                            HighestId = criteriaObjects[j].SVMXC__SFDC_Record_Id__c;
                            LowestId =  criteriaObjects[j].SVMXC__Record_Id__c;
                            if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && criteriaObjects[j].SVMXC__SFDC_Record_Id__c != null && criteriaObjects[j].SVMXC__SFDC_Record_Id__c.length() > 0)
                            {
                                strLastId = criteriaObjects[j].SVMXC__SFDC_Record_Id__c;
                            }
                            if(HighestId == null || HighestId == '')
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                    {
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    }
                                    else
                                    {
                                        query = query.trim();
                                        query = query.removeEnd('WHERE');
                                        query = query.removeEnd('and');
                                        query += ' Order By Id Limit : recordsLimit ';
                                        //query += ' Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                    }
                                }
                                else 
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA')
                                    {
                                        if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        {
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                        else
                                        {
                                            query = query.trim();
                                            query = query.removeEnd('WHERE');
                                            query = query.removeEnd('and');
                                            query += ' Order By Id Limit : recordsLimit ALL ROWS';
                                            //query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                    }
                                    else
                                    {
                                        if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        {
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit';
                                        }
                                        else
                                        {
                                            query = query.trim();
                                            query = query.removeEnd('WHERE');
                                            query = query.removeEnd('and');
                                            query += ' Order By Id Limit : recordsLimit ';
                                            //query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                    {
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    }
                                    else
                                    {
                                        query = query.trim();
                                        query = query.removeEnd('WHERE');
                                        query = query.removeEnd('and');
                                        query += ' Order By Id Limit : recordsLimit ';
                                        //query += ' Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                    }
                                }
                                else
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA')
                                    {
                                        if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        {
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                        else
                                        {
                                            query = query.trim();
                                            query = query.removeEnd('WHERE');
                                            query = query.removeEnd('and');
                                            query += ' Order By Id Limit : recordsLimit ALL ROWS';
                                            //query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                    }
                                    else
                                    {
                                        if(criteriaObjects[j].SVMXC__Status__c == 'PARTIAL_EXECUTED' && strLastId != null && strLastId.length() > 0)
                                        {
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit';
                                        }
                                        else
                                        {
                                            query = query.trim();
                                            query = query.removeEnd('WHERE');
                                            query = query.removeEnd('and');
                                            query += ' Order By Id Limit : recordsLimit ';
                                            //query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                        }
                                    }
                                }
                            }
                            
                            system.debug(LoggingLevel.WARN, 'Query string ' + query);
                            INTF_DataSync.logSOQL(intMethodCount,query);
                            List<Sobject> queryResult = database.query(query);
                            system.debug(LoggingLevel.WARN, 'Query string ' + queryResult);
                            if(queryResult.size() > 0 || queryResult != null)
                            {
                                INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
                                masterWrap.key = 'Parent_Object';
                                masterWrap.value = criteriaObjects[j].SVMXC__Object_Name__c;
                                INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                                masterFieldWrap.key = 'Fields';
                                masterFieldWrap.value = Json.serialize(queryResult);
                                
                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                multiWrapList.add(masterFieldWrap);
                                masterWrap.valueMap = multiWrapList;
                                masterResponse.add(masterWrap);
                            }
                            system.debug(LoggingLevel.WARN,'Records limit' + recordsLimit + 'no of rows ' + queryResult.size());
                            if(queryResult != null && queryResult.size() >= recordsLimit)
                            {
                                System.debug(LoggingLevel.info,'In result > recordsLIMIT');
                                HighestId = queryResult[queryResult.size()-1].Id;
                                LowestId = queryResult[0].Id;
                                criteriaObjects[j].SVMXC__Record_Id__c = LowestId;
                                criteriaObjects[j].SVMXC__SFDC_Record_Id__c = HighestId;
                                criteriaObjects[j].SVMXC__Status__c = 'PARTIAL_EXECUTED';
                                criteriaObjects[j].SVMXC__Iteration_Index__c = current_batch_index;
                                update(criteriaObjects[j]);
                                
                                masterResponse.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', criteriaObjects[j].SVMXC__Object_Name__c));
                                break;
                            }
                            else if(queryResult.size() < recordsLimit && queryResult.size() != 0)
                            {
                                System.debug(LoggingLevel.info,'In result < recordsLIMIT');
                                recordsLimit -= queryResult.size();
                                record_count = record_count + queryResult.size();
                                
                                HighestId = queryResult[queryResult.size()-1].Id;
                                LowestId = queryResult[0].Id;
                                criteriaObjects[j].SVMXC__Record_Id__c = LowestId;
                                criteriaObjects[j].SVMXC__SFDC_Record_Id__c = HighestId;
                                criteriaObjects[j].SVMXC__Status__c = 'EXECUTED';
                                criteriaObjects[j].SVMXC__Iteration_Index__c = current_batch_index;
                                update(criteriaObjects[j]);
                            }
                            else if(queryResult.size() == 0)
                            {
                                System.debug(LoggingLevel.info,'In result == 0');
                                criteriaObjects[j].SVMXC__Status__c = 'EXECUTED';
                                criteriaObjects[j].SVMXC__Iteration_Index__c = current_batch_index;
                                update(criteriaObjects[j]);
                            }
                            if(j == criteriaObjects.size() - 1 && recordsLimit != 0)
                            {
                                callBack = false;
                                break;
                            }
                        }                  
                    }
                    
                    masterResponse.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(callBack)));
                    masterResponse.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(current_batch_index)));
                }
                else if(server_higestIndex > batch_index)
                { 
                    for(Integer i = 0; i< criteriaObjects.size(); i++)
                    {
                        callBack = true;
                        Integer bt_Index = Integer.valueOf(criteriaObjects[i].SVMXC__Iteration_Index__c);
                        if(bt_Index == current_batch_index)
                        {
                            System.debug(LoggingLevel.WARN, 'Inside mismatch loop------');
                            if(record_count == 35000)
                            {
                                break;
                            }
                            String query = criteriaObjects[i].SVMXC__SOQL_Query__c;
                            HighestId = criteriaObjects[i].SVMXC__SFDC_Record_Id__c;
                            LowestId =  criteriaObjects[i].SVMXC__Record_Id__c;
                            
                            if(recordIds != null)
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                {
                                    if(recordIds.size() > 0)
                                    {
                                        recordIds.sort();
                                        strLastId = recordIds[recordIds.size() - 1];
                                        query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ';
                                    }
                                    else
                                    {
                                        query = query.trim();
                                        query = query.removeEnd('WHERE');
                                        query = query.removeEnd('and');
                                        query += ' Order By Id Limit : recordsLimit ';
                                        //query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                    }
                                }
                                else
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA')
                                    {
                                        if(recordIds.size() > 0)
                                        {
                                            recordIds.sort();
                                            strLastId = recordIds[recordIds.size() - 1];
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                        else
                                        {
                                            query = query.trim();
                                            query = query.removeEnd('WHERE');
                                            query = query.removeEnd('and');
                                            query += ' Order By Id Limit : recordsLimit ALL ROWS';
                                            //query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ALL ROWS';
                                        }
                                    }
                                    else
                                    {
                                        if(recordIds.size() > 0)
                                        {
                                            recordIds.sort();
                                            strLastId = recordIds[recordIds.size() - 1];
                                            query += ' Id >\'' + strLastId + '\' Order By Id Limit : recordsLimit';
                                        }
                                        else
                                        {
                                            query = query.trim();
                                            query = query.removeEnd('WHERE');
                                            query = query.removeEnd('and');
                                            query += ' Order By Id Limit : recordsLimit ';
                                            //query += ' Id NOT IN : SFDC_Records and Id NOT IN :recordIds Order By Id Limit : recordsLimit ';
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if(inputRequest.eventName == 'DOWNLOAD_CREITERIA_SYNC')
                                    query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                                else
                                {
                                    if(inputRequest.eventName == 'GET_DELETE_DOWNLOAD_CRITERIA')
                                        query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ALL ROWS';
                                    else
                                        query += ' Id NOT IN : SFDC_Records Order By Id Limit : recordsLimit ';
                                }
                            }
                            INTF_DataSync.logSOQL(intMethodCount,query);
                            List<Sobject> queryResult = database.query(query);
                            if(queryResult.size() > 0 || queryResult != null)
                            {
                                INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
                                masterWrap.key = 'Parent_Object';
                                masterWrap.value = criteriaObjects[i].SVMXC__Object_Name__c;
                                INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                                masterFieldWrap.key = 'Fields';
                                masterFieldWrap.value = Json.serialize(queryResult);
                                
                                multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                multiWrapList.add(masterFieldWrap);  
                                masterWrap.valueMap = multiWrapList;
                                masterResponse.add(masterWrap);
                            }
                            if(queryResult != null && queryResult.size() >= recordsLimit)
                            {
                                INTF_WebServicesDef.SVMXMap NotIn_Ids = new INTF_WebServicesDef.SVMXMap();
                                NotIn_Ids.key = 'PARTIAL_EXECUTED_OBJECT';
                                NotIn_Ids.value = criteriaObjects[i].SVMXC__Object_Name__c;
                                masterResponse.add(NotIn_Ids);
                                break;
                            }
                            else if(queryResult.size() < recordsLimit && queryResult.size() != 0)
                            {
                                System.debug(LoggingLevel.info,'In result < recordsLIMIT');
                                recordsLimit -= queryResult.size();
                                record_count = record_count + queryResult.size();
                            }
                            if(i == criteriaObjects.size() - 1 && recordsLimit != 0)
                            {
                                callBack = false;
                                break;
                            }
                        }
                        INTF_WebServicesDef.SVMXMap call_back = new INTF_WebServicesDef.SVMXMap();
                        call_back.key = 'CALL_BACK';
                        call_back.value = String.valueOf(callBack);
                        masterResponse.add(call_back);
                        
                        INTF_WebServicesDef.SVMXMap server_batch_index = new INTF_WebServicesDef.SVMXMap();
                        server_batch_index.key = 'LAST_INDEX';
                        server_batch_index.value = String.valueOf(current_batch_index);
                        masterResponse.add(server_batch_index);
                    }
                }
                response.valueMap = masterResponse;
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        INTF_DataSync.logMethodEndTS( intMethodCount, 'RequestForCriteriaRecords');
        return response;
    }
    
    //Get the list of record with Id field for the child objects
    //if child object name is feed return null
    public List<SObject> GetChildDataSet(String childObjName, String ParentKeyField, List<String> ParentKeyValues)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('GetChildDataSet');
        List<SObject> response = new List<SObject>();
        List<INTF_WebServicesDef.SVMXMap> objProps = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_GetObjectDefinition GetobjectDef = new INTF_GetObjectDefinition();
    
        if(childObjName.contains('Feed'))
        {
            return response;
        }
        GetobjectDef.objectName = childObjName;
        INTF_WebServicesDef.SVMXMap childObjDef = GetobjectDef.INTF_GetObjectDefinition();
            
        objProps = childObjDef.valueMap;
        String keyvalue = null;
        if(objProps != null)
        {
            for(INTF_WebServicesDef.SVMXMap objProp : objProps)
            {
                if(objProp.key == 'OBJECTPROPERTY')
                {
                    for(INTF_WebServicesDef.SVMXMap eachMasterDetail : objProp.valueMap)
                    {
                        for(INTF_WebServicesDef.SVMXMap masterDetail : eachMasterDetail.valueMap)
                        {
                            if(masterdetail.key == 'QUERYABLE')
                            {
                                keyvalue = masterdetail.value;
                            }
                        }
                    }
                    
                }
            }
        }
        if(keyvalue != null)
        {
            if(keyvalue == 'true')
            {
                string childObjQry = 'SELECT Id FROM ' + childObjName + ' WHERE ('+ ParentKeyField + ' IN :ParentKeyValues)';
                if(childObjName == 'Event')
                {
                    string set012 = getsettingIPAD018SET012();
                    if(set012 != null)
                        childObjQry += ' ' + set012;
                    system.debug(loggingLevel.WARN, 'Child Object Query: ' + childObjQry);
                }
                INTF_DataSync.logSOQL(intMethodCount, childObjQry);
                List<SObject> qryResult = database.query(childObjQry);
                //List<SObject> qryResult = Database.query('SELECT Id FROM ' + childObjName + ' WHERE '+ ParentKeyField + ' IN :ParentKeyValues');
                if (qryResult != null && qryResult.size() > 0)
                    response = qryResult;
            }
        }
        INTF_DataSync.logMethodEndTS( intMethodCount, 'GetChildDataSet');
        return response;
    }

    public String GetValueForKeyInSVMXMapList(String Key, List<INTF_WebServicesDef.SVMXMap> SVMXMapList)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('GetValueForKeyInSVMXMapList');
        for (INTF_WebServicesDef.SVMXMap svmxmapIter : SVMXMapList)
        {
            if (svmxmapIter.key == Key)
            {
                INTF_DataSync.logMethodEndTS(intMethodCount, 'GetValueForKeyInSVMXMapList');
                return svmxmapIter.value;
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'GetValueForKeyInSVMXMapList');
        return null;
    }

    //To get events for requested range
    public List<Event> GetObjsTaggedToEvents(Datetime dtFromDateTime, Datetime dtToDateTime, Set<String> setAllowedObjects, Set<Id> setEventIdsToRemove)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('GetObjsTaggedToEvents');
        List<Event> lstEvents = new List<Event>();
        INTF_GetObjectDefinition clsObjectDef = new INTF_GetObjectDefinition();
        clsObjectDef.objectName = 'Event';
        INTF_WebServicesDef.SVMXMap objDef = clsObjectDef.INTF_GetObjectDefinition();
        if (objDef != NULL)
        {
            String strQuery = 'SELECT Id , What.Type , WhatId FROM EVENT ';
            if (dtToDateTime != null)
            {
                if (dtFromDateTime == null)
                {
                    //If start date is not available then set start day as end day - 10
                    Datetime dtCalculatedFromDate = dtToDateTime.addDays(-10);
                    strQuery += ' WHERE (((EndDateTime <= :dtToDateTime AND EndDateTime >= :dtCalculatedFromDate) OR (StartDateTime <= :dtToDateTime AND StartDateTime >= :dtCalculatedFromDate) OR (StartDateTime <= :dtCalculatedFromDate AND EndDateTime >= :dtToDateTime))';
                }
                else if (dtFromDateTime != null)
                {
                    System.debug(LoggingLevel.info,'Start date : '+dtFromDateTime + 'End date : '+dtToDateTime);
                    strQuery += ' WHERE (((StartDateTime <= :dtToDateTime AND StartDateTime >= :dtFromDateTime) OR (EndDateTime <= :dtToDateTime AND EndDateTime >= :dtFromDateTime) OR (StartDateTime <= :dtFromDateTime AND EndDateTime >= :dtToDateTime))';
                }
            }
            else if (dtToDateTime == null)
            {
                Datetime dn = datetime.now().addDays(30);
                strQuery += ' WHERE (EndDateTime <= :dn';
            }
            if(setAllowedObjects != null && setAllowedObjects.size() > 0)
                strQuery += ' AND OwnerId = ' + '\'' + Userinfo.getUserId() + '\'' + ' AND (What.Type IN:setAllowedObjects OR What.Type = null)) ';
            else
                strQuery += ' AND OwnerId = ' + '\'' + Userinfo.getUserId() + '\')'; 
            
            if(setEventIdsToRemove != null && setEventIdsToRemove.size() > 0)
                strQuery += ' and Id NOT IN :setEventIdsToRemove ';
            
            string set012 = getsettingIPAD018SET012();
            if(set012 != null)
                strQuery += ' ' + set012;
            system.debug(loggingLevel.WARN, 'Event Query: ' + strQuery);
            INTF_DataSync.logSOQL(intMethodCount,strQuery);
            lstEvents = Database.query(strQuery);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'GetObjsTaggedToEvents');
        return lstEvents;
    }
    
    public List<INTF_WebServicesDef.SVMXMap> getDownloadCriteriaObjects(String strDeviceType)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDownloadCriteriaObjects');
        Set<String> setAccessibleObjs = new Set<String>();  
        List<SVMXC__ServiceMax_Config_Data__c> lstMobileConfigForGrpProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map<Id, SVMXC__ServiceMax_Processes__c> mapIdSVMXRuleProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();        
        List<INTF_WebServicesDef.SVMXMap> response = new List<INTF_WebServicesDef.SVMXMap>();
        
        Id grpProfileId;
        Sync_Utility clsUtility = new Sync_Utility();
        grpProfileId = clsUtility.getGroupProfileId(null, true);

        system.debug(LoggingLevel.WARN, 'In getDownloadCriteriaObjects');
        system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);
        String strMobConfQuery = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId' ;
        
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        
        system.debug(LoggingLevel.WARN,'Query formed for getDownloadCriteriaObjects = '+strMobConfQuery);
        INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
        
        lstMobileConfigForGrpProfile = Database.Query(strMobConfQuery);
        
        List<SVMXC__ServiceMax_Config_Data__c> lstDefaultGrpProf = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(lstMobileConfigForGrpProfile == null  || lstMobileConfigForGrpProfile.size() == 0 )
        {
            INTF_DataSync.logSOQL(intMethodCount,'Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = \'Configuration Profile\'  and SVMXC__Configuration_Type__c = \'Group\' and SVMXC__IsDefault__c = true');
            lstDefaultGrpProf = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Configuration Profile'  and SVMXC__Configuration_Type__c = 'Group' and SVMXC__IsDefault__c = true];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            if(lstDefaultGrpProf != null  && lstDefaultGrpProf.size() == 1 ){
                String strDefaultProfileId = lstDefaultGrpProf[0].Id;
                String strMobConfigForGrpProfileQuery = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =: strDefaultProfileId';
                if(strDevConfId != NULL && strDevConfId != ''){
                    strMobConfigForGrpProfileQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                }
                system.debug(LoggingLevel.WARN,'Second Query formed for getDownloadCriteriaObjects = '+strMobConfigForGrpProfileQuery);
                INTF_DataSync.logSOQL(intMethodCount,strMobConfigForGrpProfileQuery);
                lstMobileConfigForGrpProfile = Database.Query(strMobConfigForGrpProfileQuery);
            }
        }
        INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__Parent_Object_Criteria__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, LastModifiedDate FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= \'SVMX Rule\'');
        mapIdSVMXRuleProcess.putAll([Select Id, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Source_Object_Name__c, SVMXC__Parent_Object_Criteria__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c, LastModifiedDate FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name= 'SVMX Rule']);
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        allObjs = Schema.getGlobalDescribe();
        for(String objName : allObjs.keySet())
        {
            try
            {
                if(allObjs.get(objName).getDescribe().isAccessible())
                    setAccessibleObjs.add(allObjs.get(objName).getDescribe().getName().toLowerCase());
                /*else    
                    system.debug(LoggingLevel.WARN, 'Object Name which is not accessible is ' + objName);*/
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception during describing Object ' + objName + ': ' + ex.getMessage());
            }
        }
        // Identify allowed objects and criteria
        if(lstMobileConfigForGrpProfile != NULL && lstMobileConfigForGrpProfile.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c profile: lstMobileConfigForGrpProfile)
            {
                INTF_WebServicesDef.SVMXMap objCriteria = new INTF_WebServicesDef.SVMXMap();
                if(profile.SVMXC__Object_Name__c != null && setAccessibleObjs.contains(profile.SVMXC__Object_Name__c.toLowerCase()))
                {
                    objCriteria.key = profile.SVMXC__Object_Name__c;
                    objCriteria.value = '';
                    String sCriteria = '';
                    String sUserId = UserInfo.getUserId();
                    if(String.ValueOf(profile.SVMXC__Ownership_Type__c) == 'My Records')
                        sCriteria = ' OwnerId = \'' + sUserId + '\'';
                    
                    if(mapIdSVMXRuleProcess.containsKey(profile.SVMXC__Dispatch_Process__c))
                    {
                        objCriteria.key = mapIdSVMXRuleProcess.get(profile.SVMXC__Dispatch_Process__c).SVMXC__Source_Object_Name__c;
                        objCriteria.record = mapIdSVMXRuleProcess.get(profile.SVMXC__Dispatch_Process__c);
                        if(sCriteria != '')
                            sCriteria += ' AND ';
                        sCriteria += '(' + mapIdSVMXRuleProcess.get(profile.SVMXC__Dispatch_Process__c).SVMXC__Parent_Object_Criteria__c + ')';
                    }
                    objCriteria.value = sCriteria;
                    objCriteria.values.add(String.valueOfGmt(profile.LastModifiedDate));
                    response.add(objCriteria);
                }
                else
                    system.debug(LoggingLevel.WARN, 'Object in Download Criteria which is not accessible is : ' + profile.SVMXC__Object_Name__c);
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getDownloadCriteriaObjects');
        return response;
    }
    
    //Get the download criteria in wrapper structure expected by client
    public Map<String, INTF_WebServicesDef.SVMXMap> getDownloadCriteriaObjDefns(String strDeviceType)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDownloadCriteriaObjDefns');
        Map<String, INTF_WebServicesDef.SVMXMap> mapObjDefinitions = new Map<String, INTF_WebServicesDef.SVMXMap>();
        mapObjDefinitions = new Map<String, INTF_WebServicesDef.SVMXMap>();
        for(INTF_WebServicesDef.SVMXMap eachprocessObj : getDownloadCriteriaObjects(strDeviceType))
        {
            INTF_WebServicesDef.SVMXMap tmpObj = new INTF_WebServicesDef.SVMXMap();
            tmpObj.key = eachprocessObj.key;
            tmpObj.value = eachprocessObj.value;
            tmpObj.record = eachprocessObj.record;
            tmpObj.values = eachprocessObj.values;
            if(!mapObjDefinitions.containsKey(tmpObj.key))
                  mapObjDefinitions.put(tmpObj.key, tmpObj);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getDownloadCriteriaObjDefns');
        return mapObjDefinitions;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse InsertClientDataIntoBase(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('InsertClientDataIntoBase');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<String> localIdsParent = new List<String>();
        List<String> localIdsChild = new List<String>();
        Map<String, String> localIdMapToSFIDParent = new Map<String, String>();
        Map<String, String> localIdMapToSFIDChild = new Map<String, String>();
        Database.Saveresult [] parentsaveresult;
        Database.Saveresult [] childrensaveresult;
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        responseValueMap.add(new INTF_WebServicesDef.SVMXMap('PUT_INSERT_TIME', String.valueOf(DateTime.now())));
        system.debug(LoggingLevel.WARN, 'PUT_INSERT_TIME' + responseValueMap);
        system.debug(LoggingLevel.WARN, 'inputRequest = ' + inputRequest.value + '; Put Insert Request = ' + inputRequest);
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap();
        ErrorHeader.key = 'ERROR';
        try
        {
            String strClientType = '';
            INTF_DataSync.logSOQL(intMethodCount , 'Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value');
            List<SVMXC__Sync_Request__c> sync_requests = [Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            String Record_id;
            if (sync_requests.size() <= 0)
            {        
                SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = inputRequest.value);
                Database.SaveResult Result = Database.insert(requestRecord);
                Record_id = Result.getId();
            }
            else
                Record_id = sync_requests[0].Id;
                
            INTF_DataSync.logSOQL(intMethodCount , 'Select SVMXC__Client_Record_Id__c, SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__c = :Record_Id and SVMXC__Operation_Type__c = \'Insert\'');
            List<SVMXC__Sync_Request_Records__c> request_records = [Select SVMXC__Client_Record_Id__c, SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__c = :Record_Id and SVMXC__Operation_Type__c = 'Insert'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            system.debug(LoggingLevel.WARN, 'SVMXC__Sync_Request_Records__c : ' + request_records);
            Map<String,String> localSFMap = new Map<String,String>();
            for (SVMXC__Sync_Request_Records__c request_record: request_records)
                localSFMap.put(request_record.SVMXC__Client_Record_Id__c,request_record.SVMXC__SFDC_Record_Id__c);
            
            if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                {
                    if(clientInform.clientType != null)
                    {
                        strClientType = clientInform.clientType;
                        break;
                    }
                }
            }
            
            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_INSERT')
            {
                List<INTF_WebServicesDef.SVMXMap> inputList = inputRequest.valueMap;
                List<INTF_WebServicesDef.SVMXMap> fieldsMapList;
                Iterator<INTF_WebServicesDef.SVMXMap> inputListIterator = inputList.iterator();
                List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
                
                INTF_WebServicesDef.SVMXMap firstLevelMap;
                while(inputListIterator.hasNext())
                {
                    firstLevelMap = inputListIterator.next();
                    system.debug(LoggingLevel.WARN, ' Each Value Map in Request: ' + firstLevelMap);
                    INTF_WebServicesDef.SVMXMap responseSVMXMap = new INTF_WebServicesDef.SVMXMap();
                    List<INTF_WebServicesDef.SVMXMap> listresponseSVMXMap = new List<INTF_WebServicesDef.SVMXMap>();
                    
                    if(firstLevelMap.key == 'Parent_Object')
                    {
                        List<SVMXC__Sync_Request_Records__c> Sync_Request_Rec_List = new List<SVMXC__Sync_Request_Records__c>();
                        
                        fieldsMapList = firstLevelMap.valueMap;
                        List<INTF_WebServicesDef.SVMXMap> fieldValues = new List<INTF_WebServicesDef.SVMXMap>();
                        Iterator<INTF_WebServicesDef.SVMXMap> fieldsMapIterator = fieldsMapList.iterator();
                        INTF_WebServicesDef.SVMXMap secondLevelMap;
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = firstLevelMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        MAP<String,String> fieldsType = new Map<String,String>();
                        Map<String, String> fieldCreateable = new Map<String, String>(); 
                        
                        if(objDef != NULL) 
                        {
                            List<INTF_WebServicesDef.SVMXMap> objProps;
                            objProps = objdef.valueMap;
                            for(INTF_WebServicesDef.SVMXMap objProp : objProps)
                            {
                                if (objProp.key == 'FIELDPROPERTY')
                                {   
                                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                    {
                                        for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                        {
                                            if(fldObj.key == 'TYPE')
                                            {
                                                fieldsType.put(lstField.value, fldObj.value);
                                            }
                                            if(fldObj.key == 'CREATEABLE')
                                            {
                                                fieldCreateable.put(lstField.value, fldObj.value);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                            
                        List<sObject> sobjListParent = new List<sObject>(); 
                        while(fieldsMapIterator.hasNext())
                        {
                            secondLevelMap = fieldsMapIterator.next();
                            INTF_WebServicesDef.SVMXMap tableValueMap = new INTF_WebServicesDef.SVMXMap();
                            List<INTF_WebServicesDef.SVMXMap> listValueMaps = new List<INTF_WebServicesDef.SVMXMap>();
                            
                            if(secondLevelMap.key == 'Fields')
                            {
                                fieldValues = secondLevelMap.valueMap;//fieldValues - each record to insert
                                Iterator<INTF_WebServicesDef.SVMXMap> it = fieldValues.iterator();
                                sObject sObj = null;
                                String localId = null;
                                while(it.hasNext())
                                {
                                    INTF_WebServicesDef.SVMXMap selectedObj = it.next();
                                    String SFIDIfExists = localSFMap.get(selectedObj.key);  
                                    if (SFIDIfExists != null)
                                    {
                                        localIdMapToSFIDParent.put(selectedObj.key,SFIDIfExists);
                                        INTF_WebServicesDef.SVMXMap existRecordMap = new INTF_WebServicesDef.SVMXMap();
                                        existRecordMap.key = selectedObj.key;
                                        existRecordMap.value = SFIDIfExists;
                                        listresponseSVMXMap.add(existRecordMap);
                                    }
                                    else
                                    {
                                        localId = selectedObj.key;
                                        localIdsParent.add(localId);
                                        String jstr = selectedObj.value;
                                        if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                            jstr = jstr.replace('&quot;', '"');
                                        JSONParser jsp = JSON.createParser(jstr);
                                        sObj = Schema.getGlobalDescribe().get(clsObjectDefinition.objectName).newSObject();
                                        ObjectNameID objid = new ObjectNameID(localId);
                                        while(jsp.nextToken() != null)
                                        {
                                            if(jsp.getCurrentToken() == JSONToken.FIELD_NAME) 
                                            {  
                                                String fldName = jsp.getText();
                                                if(jsp.nextToken() == JSONToken.VALUE_STRING)
                                                {
                                                    String fldValue = jsp.getText();
                                                    if(fieldCreateable.get(fldName) == 'true')
                                                    {
                                                        if(fldValue != null && fldValue != '')
                                                        {
                                                            system.debug(LoggingLevel.Debug, ' fldName = ' + fldName + ';fldValue = ' + fldValue);
                                                            if(fldValue != null && fldValue != '')
                                                            {
                                                                if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                                {
                                                                    fldValue = fldValue.replace('&amp;', '&');
                                                                    fldValue = fldValue.replace('&apos;', '\'');
                                                                    fldValue = fldValue.replace('&lt;', '<');
                                                                    fldValue = fldValue.replace('&gt;', '>');
                                                                    fldValue = fldValue.replace('&quot;', '"');
                                                                }
                                                            }
                                                            if(fieldsType.get(fldName) == 'DATETIME' && fldValue != '')
                                                            {
                                                                fldValue = fldValue.replace('T', ' ');
                                                                fldValue = fldValue.replace('Z', ' ');
                                                                sObj.put(fldName, Datetime.valueOfGmt(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DATE' && fldValue != '')
                                                            {

                                                                sObj.put(fldName, Date.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'TIME')
                                                            {
                                                                continue;
                                                            }
                                                            else if(fieldsType.get(fldName) == 'BOOLEAN')
                                                            {
                                                                sObj.put(fldName, Boolean.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DOUBLE')
                                                            {
                                                                sObj.put(fldName, decimal.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DECIMAL'|| fieldsType.get(fldName) == 'CURRENCY' || fieldsType.get(fldName) == 'PERCENT')
                                                            {
                                                                sObj.put(fldName, decimal.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'INTEGER')
                                                            {
                                                                sObj.put(fldName, Integer.valueOf(fldValue));
                                                            }
                                                            else
                                                            {
                                                                sObj.put(fldName, fldValue);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    system.debug(LoggingLevel.WARN, 'Each Parent Record : ' + sObj);
                                    if(sObj != null)
                                        sobjListParent.add(sObj);
                                }
                                INTF_WebServicesDef.SVMXMap Error;
                                try
                                {
                                    parentsaveresult = Database.insert(sobjListParent,false);
                                    Integer i = 0;
                                    INTF_WebServicesDef.SVMXMap objMap;
                                    for(Database.Saveresult res : parentsaveresult)
                                    {
                                        objMap = new INTF_WebServicesDef.SVMXMap();
                                        if(res.isSuccess())
                                        {
                                            objMap.key = localIdsParent[i];
                                            objMap.value = res.getId();
                                            listresponseSVMXMap.add(objMap);
                                            localIdMapToSFIDParent.put(localIdsParent[i], res.getId());
                                            SVMXC__Sync_Request_Records__c Sync_Request_Rec = new SVMXC__Sync_Request_Records__c(SVMXC__Client_Record_Id__c = localIdsParent[i], SVMXC__Object_Name__c = '', SVMXC__Operation_Type__c = 'Insert', SVMXC__SFDC_Record_Id__c = res.getId(), SVMXC__Sync_Request__c = Record_id);
                                            Sync_Request_Rec_List.add(Sync_Request_Rec);
                                        }
                                        else
                                        {
                                            Error = new INTF_WebServicesDef.SVMXMap(); 
                                            Database.Error err = res.getErrors()[0];
                                            Error.key = firstLevelMap.value;
                                            Error.value = err.getMessage();
                                            
                                            List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                            INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                            child.key = localIdsParent[i];
                                            child.value = localIdsParent[i];
                                            errChild.add(child);
                                            Error.valueMap = errChild;
                                            ErrorList.add(Error);
                                        }
                                        i++;
                                    }
                                }
                                catch(DMLException e)
                                {
                                    Error = new INTF_WebServicesDef.SVMXMap(); 
                                    Error.key = firstLevelMap.value;
                                    Error.value = e.getMessage();
                                    system.debug(LoggingLevel.WARN, 'Exception caught:' + e.getMessage());
                                    List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                    INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                    child.key = localId;
                                    child.value = localId;
                                    errChild.add(child);
                                    Error.valueMap = errChild;
                                    ErrorList.add(Error);
                                }
                                sobjListParent.clear();
                                localIdsParent.clear();
                            }
                        }
                        Database.Saveresult[] parentRecords = Database.insert(Sync_Request_Rec_List);
                    }//end of parent_object
                    else if(firstLevelMap.key == 'Child_Object')
                    {
                        DateTime dt = datetime.now();
                        String strdt = String.valueOf(dt);
                        List<SVMXC__Sync_Request_Records__c> Sync_Request_Rec_List = new List<SVMXC__Sync_Request_Records__c>();
                        fieldsMapList = firstLevelMap.valueMap;
                        List<INTF_WebServicesDef.SVMXMap> fieldValues = new List<INTF_WebServicesDef.SVMXMap>();
                        Iterator<INTF_WebServicesDef.SVMXMap> fieldsMapIterator = fieldsMapList.iterator();
                        INTF_WebServicesDef.SVMXMap secondLevelMap;
                        
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = firstLevelMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        
                        MAP<String,String> fieldsType = new Map<String,String>();
                        Map<String, String> fieldUpdateable = new Map<String, String>();
                        Map<String, String> fieldCreateable = new Map<String, String>(); 
                        Map<String, String> fieldReferenceto = new Map<String, String>();
                            
                        if(objDef != NULL) 
                        {
                            for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                            {
                                if (objProp.key == 'FIELDPROPERTY')
                                {   
                                    for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                    {
                                        List<INTF_WebServicesDef.SVMXMap> fldObjs = lstField.valueMap;
                                        Iterator<INTF_WebServicesDef.SVMXMap> it = fldObjs.iterator();
                                        while(it.hasNext())
                                        {
                                            INTF_WebServicesDef.SVMXMap checkMap = it.next();
                                            if(checkMap.key == 'REFERENCETO')
                                                fieldReferenceto.put(lstField.value, checkMap.key);
                                                //fieldReferenceto.put(checkMap.value, checkMap.key);
                                        }
                                        String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', fldObjs);
                                        if (reference_to != null)
                                        {
                                            String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', fldObjs);
                                        }
                                        for(INTF_WebServicesDef.SVMXMap fldObj : fldObjs)
                                        {
                                            if(fldObj.key == 'TYPE')
                                            {
                                                fieldsType.put(lstField.value, fldObj.value);
                                            }
                                            if(fldObj.key == 'CREATEABLE')
                                            {
                                                fieldCreateable.put(lstField.value, fldObj.value);
                                            }
                                            if(fldObj.key == 'UPDATEABLE')
                                            {
                                                fieldUpdateable.put(lstField.value,fldObj.value);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        List<sObject> sobjListChild = new List<sObject>(); 
                        while(fieldsMapIterator.hasNext())
                        {
                            secondLevelMap = fieldsMapIterator.next();
                            if(secondLevelMap.key == 'Fields')
                            {
                                fieldValues = secondLevelMap.valueMap;
                                Iterator<INTF_WebServicesDef.SVMXMap> it = fieldValues.iterator();
                                sObject sObj = null;
                                String localIdChild = null;
                                ObjectNameID objid;
                                while(it.hasNext())
                                {
                                    INTF_WebServicesDef.SVMXMap selectedObj = it.next();
                                    String SFIDIfExists = localSFMap.get(selectedObj.key);  
                                    if (SFIDIfExists != null)
                                    {
                                        localIdMapToSFIDChild.put(selectedObj.key,SFIDIfExists);
                                        INTF_WebServicesDef.SVMXMap existRecordMap = new INTF_WebServicesDef.SVMXMap();
                                        existRecordMap.key = selectedObj.key;
                                        existRecordMap.value = SFIDIfExists;
                                        listresponseSVMXMap.add(existRecordMap);
                                    }
                                    else
                                    {
                                        localIdChild = selectedObj.key;
                                        localIdsChild.add(selectedObj.key);
                                        objid = new ObjectNameID(localIdChild);
                                        String SFIDParent = localIdMapToSFIDParent.get(selectedObj.key);
                                        if (SFIDParent != null)
                                            selectedObj.key = SFIDParent;
                                        String jstr = selectedObj.value;
                                        if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                            jstr = jstr.replace('&quot;', '"');
                                        JSONParser jsp = JSON.createParser(jstr);
                                        
                                        sObj = Schema.getGlobalDescribe().get(clsObjectDefinition.objectName).newSObject();
                                        while(jsp.nextToken() != null)
                                        {
                                            if(jsp.getCurrentToken() == JSONToken.FIELD_NAME) 
                                            {  
                                                String fldName = jsp.getText();

                                                if(jsp.nextToken() == JSONToken.VALUE_STRING)
                                                {
                                                    String fldValue = jsp.getText();


                                                    if(fieldCreateable.get(fldName) == 'true')
                                                    {
                                                        if(fldValue != null && fldValue != '')
                                                        {
                                                            if(fldValue != null && fldValue != '')
                                                            {
                                                                if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                                {   
                                                                    fldValue = fldValue.replace('&amp;', '&');
                                                                    fldValue = fldValue.replace('&apos;', '\'');
                                                                    fldValue = fldValue.replace('&lt;', '<');
                                                                    fldValue = fldValue.replace('&gt;', '>');
                                                                    fldValue = fldValue.replace('&quot;', '"');
                                                                }
                                                            }
                                                            if(fieldsType.get(fldName) == 'DATETIME' && fldValue != '')
                                                            {
                                                                fldValue = fldValue.replace('T', ' ');
                                                                fldValue = fldValue.replace('Z', ' ');
                                                                sObj.put(fldName, Datetime.valueOfGmt(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DATE' && fldValue != '')
                                                            {
                                                                sObj.put(fldName, Date.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'TIME')
                                                            {
                                                                continue;
                                                            }
                                                            else if(fieldsType.get(fldName) == 'BOOLEAN')
                                                            {
                                                                sObj.put(fldName, Boolean.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DOUBLE')
                                                            {
                                                                sObj.put(fldName, decimal.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'DECIMAL' || fieldsType.get(fldName) == 'CURRENCY' || fieldsType.get(fldName) == 'PERCENT')
                                                            {

                                                                sObj.put(fldName, decimal.valueOf(fldValue));
                                                            }
                                                            else if(fieldsType.get(fldName) == 'INTEGER')
                                                            {
                                                                sObj.put(fldName, Integer.valueOf(fldValue));
                                                            }
                                                            else
                                                            {
                                                                if(fieldReferenceto.containsKey(fldName))
                                                                {
                                                                    if(fldValue != null && fldValue != '')
                                                                    {
                                                                        String fldValueMapped = localIdMapToSFIDParent.get(fldValue);
                                                                        if (fldValueMapped != null)
                                                                            fldValue = fldValueMapped;
                                                                    }
                                                                }
                                                                sObj.put(fldName, fldValue);
                                                            }
                                                        }
                                                    }
                                                }                                   
                                            }
                                        }
                                    }
                                    system.debug(LoggingLevel.WARN, 'Each Child Record : ' + sObj);
                                    if(sObj != null)
                                        sobjListChild.add(sObj);
                                }
                                INTF_WebServicesDef.SVMXMap Error;
                                try
                                {
                                    childrensaveresult = Database.insert(sobjListChild, false);
                                    Integer i = 0;
                                    INTF_WebServicesDef.SVMXMap objMap;
                                    for(Database.Saveresult resChildrec : childrensaveresult)
                                    {
                                        objMap = new INTF_WebServicesDef.SVMXMap();
                                        if(resChildrec.isSuccess())
                                        {
                                            objMap.key = localIdsChild[i];
                                            objMap.value = resChildrec.getId();
                                            listresponseSVMXMap.add(objMap);
                                            localIdMapToSFIDChild.put(localIdsChild[i], resChildrec.getId());
                                            SVMXC__Sync_Request_Records__c Sync_Request_Rec = new SVMXC__Sync_Request_Records__c(SVMXC__Client_Record_Id__c = localIdsChild[i] , SVMXC__Object_Name__c = strdt ,SVMXC__Operation_Type__c = 'Insert',SVMXC__SFDC_Record_Id__c = resChildrec.getId() ,SVMXC__Sync_Request__c = Record_id);
                                            Sync_Request_Rec_List.add(Sync_Request_Rec);
                                        }
                                        else
                                        {
                                            Error = new INTF_WebServicesDef.SVMXMap(); 
                                            Database.Error[] err = resChildrec.getErrors();
                                            Error.key = firstLevelMap.value;
                                            Error.value = err[0].getMessage();
                                            
                                            List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                            INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                            child.key = localIdsChild[i];
                                            child.value = resChildrec.getId();
                                            errChild.add(child);
                                            Error.valueMap = errChild;
                                            ErrorList.add(Error);
                                        }
                                        i++;
                                    }
                                    //system.debug(LoggingLevel.WARN, 'Total Records : ' + i);
                                }
                                catch(DMLException e)
                                {
                                    Error = new INTF_WebServicesDef.SVMXMap(); 
                                    Error.key = firstLevelMap.value;
                                    Error.value = e.getMessage();
                                    
                                    List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                    INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                    
                                    child.key = localIdChild;
                                    child.value = '';
                                    errChild.add(child);
                                    Error.valueMap = errChild;
                                    ErrorList.add(Error);
                                }
                                sobjListChild.clear();
                                localIdsChild.clear();
                            }
                        }
                        Database.Saveresult[] childRecords = Database.insert(Sync_Request_Rec_List);
                    }
                    responseSVMXMap.key = firstLevelMap.key;
                    responseSVMXMap.value = firstLevelMap.value;
                    responseSVMXMap.valueMap = listresponseSVMXMap;
                    responseValueMap.add(responseSVMXMap);
                }
                ErrorHeader.valueMap = ErrorList;
                responseValueMap.add(ErrorHeader);
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        if(response.success == null)
            response.success = true;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        response.valueMap = responseValueMap;
        system.debug(LoggingLevel.WARN, 'Response = ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount,'InsertClientDataIntoBase');
        return response;
    }

    public INTF_WebServicesDef.INTF_SFMResponse UpdateClientDataIntoBase(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        Database.Saveresult[] parentsaveresult;
        List<INTF_WebServicesDef.SVMXError> errors = new List<INTF_WebServicesDef.SVMXError>(); 
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap();
        ErrorHeader.key = 'ERROR'; 
        INTF_WebServicesDef.SVMXMap conflictHeader = new INTF_WebServicesDef.SVMXMap();
        conflictHeader.key = 'CONFLICT';
        DateTime dtSyncStartTime;
        try
        {
            String strSyncConflict = '', strClientType = '';
            Boolean isFieldLevelSyncConflict = false;
            list<String> lstSettingId = new list<String>{'SET016'};
            Id grpProfileId = (new Sync_Utility()).getGroupProfileId(null, true);
            map<String, String> mapSettingsForIPAD018 = new map<String, String>();
            List<SVMXC__Sync_Request__c> lstSyncRequest = new List<SVMXC__Sync_Request__c>();
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            
            lstSyncRequest =[Select Id, CreatedDate from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lstSyncRequest != null && lstSyncRequest.size() > 0)
                dtSyncStartTime = lstSyncRequest[0].CreatedDate;
            
                string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);
            system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);
            
            String strMobConfQuery  = 'select SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c = \'Conflict Resolution\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';
            
            String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            strMobConfQuery += ' LIMIT 1';
            
            system.debug(LoggingLevel.WARN,'Query formed for UpdateClientDataIntoBase = '+strMobConfQuery);
            
            for(SVMXC__ServiceMax_Config_Data__c confgData : Database.Query(strMobConfQuery))
                strSyncConflict = confgData.SVMXC__Internal_Value__c;
        
            mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
            if(mapSettingsForIPAD018.containskey('SET016') && mapSettingsForIPAD018.get('SET016') != null && mapSettingsForIPAD018.get('SET016').length() > 0)
            {
                isFieldLevelSyncConflict = Boolean.valueOf(mapSettingsForIPAD018.get('SET016'));
            }
            
            if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                {
                    if(clientInform.clientType != null)
                    {
                        strClientType = clientInform.clientType;
                        break;
                    }
                }
            }
            system.debug(LoggingLevel.WARN, 'Sync Start Time = ' + dtSyncStartTime + '; Sync Conflict = ' + strSyncConflict + '; Field Level Sync Conflict = ' + isFieldLevelSyncConflict + '; Client Type = ' + strClientType);
            
            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_UPDATE')
            {
                if(isFieldLevelSyncConflict)
                    responseValueMap = updateRecordsFromClient(inputRequest, dtSyncStartTime, strSyncConflict);
                else
                {       
                    List<INTF_WebServicesDef.SVMXMap> inputList = inputRequest.valueMap;
                    List<INTF_WebServicesDef.SVMXMap> fieldsMapList;
                    Iterator<INTF_WebServicesDef.SVMXMap> inputListIterator = inputList.iterator();
                    List<INTF_WebServicesDef.SVMXMap> ConflictList = new List<INTF_WebServicesDef.SVMXMap>();
                    List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
                    Datetime LastSynchTime ;
                    INTF_WebServicesDef.SVMXMap firstLevelMap;
                     
                    while(inputListIterator.hasNext())
                    {
                        firstLevelMap = inputListIterator.next();
                        system.debug(LoggingLevel.WARN, ' Each Value Map in Request: ' + firstLevelMap);
                        INTF_WebServicesDef.SVMXMap responseSVMXMap = new INTF_WebServicesDef.SVMXMap();
                        List<INTF_WebServicesDef.SVMXMap> listValueMaps = new List<INTF_WebServicesDef.SVMXMap>();
                        
                        if(firstLevelMap.key == 'SYNC_TIME_STAMP')
                            LastSynchTime = Datetime.valueOf(firstLevelMap.value);
            
                        if(firstLevelMap.key == 'object_name') 
                        {
                            fieldsMapList = firstLevelMap.valueMap;
                            List<INTF_WebServicesDef.SVMXMap> fieldValues = new List<INTF_WebServicesDef.SVMXMap>();
                            Iterator<INTF_WebServicesDef.SVMXMap> fieldsMapIterator = fieldsMapList.iterator();
                            INTF_WebServicesDef.SVMXMap secondLevelMap;
                            
                            INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                            clsObjectDefinition.objectName = firstLevelMap.value;
                            
                            INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                            MAP<String,String> fieldsType = new Map<String,String>();
                            Map<String, String> fieldUpdateable = new Map<String, String>();
                            //Map<String, String> fieldCreateable = new Map<String, String>(); 
                            
                            if(objDef != NULL) 
                            {
                                for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                                {
                                    if (objProp.key=='FIELDPROPERTY')
                                    {
                                        for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                        {
                                            for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                            {
                                                if(fldObj.key == 'TYPE')
                                                {
                                                    fieldsType.put(lstField.value, fldObj.value);
                                                }
                                                /*if(fldObj.key == 'CREATEABLE')
                                                {
                                                    fieldCreateable.put(lstField.value, fldObj.value);
                                                }*/
                                                if(fldObj.key == 'UPDATEABLE')
                                                {
                                                    fieldUpdateable.put(lstField.value,fldObj.value);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            List<sObject> sobjList = new List<sObject>(); 
                            while(fieldsMapIterator.hasNext())
                            {
                                MAP<String,Sobject> idSobjectMap = new MAP<String,Sobject>();
                                secondLevelMap = fieldsMapIterator.next();
                                if(secondLevelMap.key == 'Fields')
                                {
                                    system.debug(LoggingLevel.WARN, 'Inside Fields');
                                    fieldValues = secondLevelMap.valueMap;
                                    Iterator<INTF_WebServicesDef.SVMXMap> it = fieldValues.iterator();
                                    List<String> RequestSFIDs = new List<String>();
                                    List<String> RecSfids = new List<String>();
                                    Iterator<INTF_WebServicesDef.SVMXMap> it1 = fieldValues.iterator();
                                    while(it1.hasNext())
                                    {
                                        INTF_WebServicesDef.SVMXMap selectedObj = it1.next();
                                        system.debug(LoggingLevel.WARN, 'selectedObj= ' + selectedObj);
                                        if(selectedObj.key != 'BEFORE_SAVE')
                                        {
                                            String conflictHandle =  selectedObj.key;
                                            String jstr = selectedObj.value;
                                            if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                jstr = jstr.replace('&quot;', '"');
                                            JSONParser newjsp = JSON.createParser(jstr);
                                            if(conflictHandle != 'CLIENT_OVERRIDE')
                                            {
                                                while(newjsp.nextToken()!=null)
                                                {
                                                    if (newjsp.getCurrentToken() == JSONToken.FIELD_NAME ) 
                                                    {  
                                                        String fldName = newjsp.getText();
                                                        if(fldName=='type' || fldName=='url')
                                                        {
                                                            newjsp.nextToken();
                                                            continue;
                                                        }
                                                        
                                                        if(newjsp.nextToken()==JSONToken.VALUE_STRING)
                                                        {
                                                            String fldValue = newjsp.getText();
                                                            if(fldName == 'Id')
                                                            {
                                                                RecSfids.add(fldValue); 
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    String stringQuery = 'SELECT LastModifiedById , LastModifiedDate FROM ' + firstLevelMap.value + ' WHERE Id IN : RecSfids All Rows';
                                    system.debug(LoggingLevel.WARN,'Query  = ' + stringQuery + 'RecSfids = ' + RecSfids);
                                    List<SObject> queryResult = Database.query(stringQuery);
                                    system.debug(LoggingLevel.WARN, 'Sync Start Time = ' + dtSyncStartTime + ', Current Time = ' + DateTime.now());
                                    DateTime newModifiedDate;
                                    
                                    if(dtSyncStartTime != null)
                                        newModifiedDate = dtSyncStartTime;
                                    else
                                        newModifiedDate = DateTime.now();
        
                                    Integer a = 0;
                                    while(it.hasNext())
                                    {
                                        INTF_WebServicesDef.SVMXMap selectedObj = it.next();
                                        if(selectedObj.key == 'CLIENT_OVERRIDE' || selectedObj.key != 'BEFORE_SAVE')
                                        {
                                            String conflictHandle =  selectedObj.key;
                                            String jstr = selectedObj.value;
                                            if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                jstr = jstr.replace('&quot;', '"');
                                            JSONParser jsp = JSON.createParser(jstr);
                                            JSONParser newjsp = JSON.createParser(jstr);
                                            String currentId ;
                                            while(newjsp.nextToken()!=null)
                                            {
                                                if (newjsp.getCurrentToken() == JSONToken.FIELD_NAME ) 
                                                {  
                                                    String fldName = newjsp.getText();
                                                    if(newjsp.nextToken()==JSONToken.VALUE_STRING)
                                                    {
                                                        String fldValue = newjsp.getText();
                                                        if(fldName == 'Id')
                                                        {
                                                            RequestSFIDs.add(fldValue); 
                                                            currentId = fldValue;
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            List<String> idToDelete = new List<String>();
                                            if(conflictHandle != 'CLIENT_OVERRIDE' && (strSyncConflict == 'Allow user to choose' || strSyncConflict =='ServiceMax online data') && queryResult != null && queryResult.size() > 0)
                                            {
                                                INTF_WebServicesDef.SVMXMap conflict;
                                                String selId = (String)queryResult[a].get('Id');
                                                DateTime dbLastModified = Datetime.valueOf(queryResult[a].get('LastModifiedDate'));
                                                String sUserId = UserInfo.getUserId();
                                                if(dbLastModified > LastSynchTime)
                                                {
                                                    system.debug(LoggingLevel.WARN,'Conflict : ' + 'LMD of Record = ' + dbLastModified + ', Last Sync = ' + LastSynchTime + ', New Modified Date = ' + newModifiedDate);
                                                    if(((dbLastModified < newModifiedDate) || queryResult[a].get('LastModifiedById') != sUserId))
                                                    {
                                                        idToDelete.add((String)queryResult[a].get('Id'));
                                                        if(strSyncConflict != 'ServiceMax online data')
                                                        {
                                                            system.debug(LoggingLevel.WARN,'Conflict when ServiceMax NOT online data');
                                                            conflict = new INTF_WebServicesDef.SVMXMap();
                                                            conflict.key = firstLevelMap.value;
                                                            conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(newModifiedDate) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(LastSynchTime);
                                                            
                                                            List<INTF_WebServicesDef.SVMXMap> confChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                            confChild.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                                            conflict.valueMap = confChild;
                                                            ConflictList.add(conflict);
                                                        }
                                                        else
                                                        {
                                                            system.debug(LoggingLevel.WARN,'Conflict when ServiceMax online data');
                                                            INTF_WebServicesDef.SVMXMap record = new INTF_WebServicesDef.SVMXMap();
                                                            record.value = (String)queryResult[a].get('Id');
                                                            listValueMaps.add(record);
                                                        }
                                                    }
                                                }
                                            }
                                            system.debug(LoggingLevel.WARN, 'currentId =' + currentId);
                                            sObject sObj;
                                            if(RequestSFIDs.size() > 0 && currentId!= null)
                                            {
                                                sObj = Schema.getGlobalDescribe().get(clsObjectDefinition.objectName).newSObject(currentId);
                                            }
                                            
                                            while(jsp.nextToken()!=null && currentId != null)
                                            {
                                                if(jsp.getCurrentToken() == JSONToken.FIELD_NAME ) 
                                                {  
                                                    String fldName = jsp.getText();
                                                    if(jsp.nextToken()==JSONToken.VALUE_STRING)
                                                    {
                                                        String fldValue = jsp.getText();
                                                        if(fieldUpdateable.get(fldName) == 'true')
                                                        {
                                                            if(fldValue == null || fldValue == '')
                                                            {
                                                                sObj.put(fldName, null);
                                                            }
                                                            else
                                                            {
                                                                if(fldValue != null && fldValue != '')
                                                                {
                                                                    if(strClientType != null && strClientType != '' && strClientType.contains('iPad'))
                                                                    {
                                                                        fldValue = fldValue.replace('&amp;', '&');
                                                                        fldValue = fldValue.replace('&apos;', '\'');
                                                                        fldValue = fldValue.replace('&lt;', '<');
                                                                        fldValue = fldValue.replace('&gt;', '>');
                                                                        fldValue = fldValue.replace('&quot;', '"');
                                                                    }
                                                                }
                                                                if(fieldsType.get(fldName)=='DATETIME' && fldValue != '')
                                                                {
                                                                    fldValue = fldValue.replace('T', ' ');
                                                                    fldValue = fldValue.replace('Z', ' ');
                                                                    sObj.put(fldName, Datetime.valueOfGmt(fldValue));
                                                                }
                                                                else if(fieldsType.get(fldName)=='DATE' && fldValue != '')
                                                                {
                                                                    sObj.put(fldName, Date.valueOf(fldValue));
                                                                }
                                                                else if(fieldsType.get(fldName)=='BOOLEAN')
                                                                {
                                                                    sObj.put(fldName, Boolean.valueOf(fldValue));
                                                                }
                                                                else if(fieldsType.get(fldName)=='DOUBLE')
                                                                {
                                                                    sObj.put(fldName, decimal.valueOf(fldValue));
                                                                }
                                                                else if(fieldsType.get(fldName)=='DECIMAL' || fieldsType.get(fldName)== 'CURRENCY' || fieldsType.get(fldName)== 'PERCENT')
                                                                {
                                                                    sObj.put(fldName, decimal.valueOf(fldValue));
                                                                }
                                                                else if(fieldsType.get(fldName)=='INTEGER')
                                                                {
                                                                    sObj.put(fldName, Integer.valueOf(fldValue));
                                                                }
                                                                else
                                                                {
                                                                    sObj.put(fldName, fldValue);
                                                                }
                                                            } 
                                                        }
                                                        if(fldName == 'Id')
                                                        {
                                                            idSobjectMap.put(fldValue,sObj);
                                                        }
                                                    }                                       
                                                }
                                            }
                                            a++;
                                            Boolean updateIt = true;
                                            if(!idToDelete.isEmpty()) 
                                            {
                                                for(String id : idToDelete)
                                                {
                                                    if(sObj.get('Id') == id)
                                                    {   
                                                        updateIt = false;
                                                    }
                                                }
                                            }
                                            if(updateIt && RequestSFIDs != null)
                                            {
                                                sObjList.add(sObj);
                                            }
                                        }
                                    }
                                    system.debug(LoggingLevel.WARN, 'sObjList =' + sObjList);
                                    INTF_WebServicesDef.SVMXMap Error;
                                    try
                                    {
                                        parentsaveresult = Database.update(sObjList,false);
                                    }
                                    catch(DmlException e)
                                    {
                                        List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        errChild.add(new INTF_WebServicesDef.SVMXMap('', ''));
                                        ErrorList.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, e.getMessage()));   
                                    }
                                    finally
                                    {
                                        List<String> sfids = new List<String>();
                                        if(parentsaveresult != null)
                                        {
                                            Integer i=0;
                                            for(Database.Saveresult parentSave : parentsaveresult)
                                            {
                                                sfids.add(parentSave.getId());
                                                if(parentSave.isSuccess())
                                                {
                                                    listValueMaps.add(new INTF_WebServicesDef.SVMXMap('', parentSave.getId()));
                                                    system.debug(LoggingLevel.WARN, 'Update is Successfull');
                                                }
                                                else
                                                {
                                                    system.debug(LoggingLevel.WARN, 'Problem in Update');   
                                                    Error = new INTF_WebServicesDef.SVMXMap();
                                                    Error.key = firstLevelMap.value;
                                                    Database.Error[] err = parentSave.getErrors();                                      
                                                    Error.value = err[0].getMessage();
                                                    List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                    errChild.add(new INTF_WebServicesDef.SVMXMap('', String.valueOf(sObjList[i].Id)));
                                                    Error.valueMap = errChild;
                                                    ErrorList.add(Error);
                                                }
                                                i++;
                                            }
                                        }
                                    }
                                }
                            }    
                        }
                        responseSVMXMap.key = firstLevelMap.key;
                        responseSVMXMap.value = firstLevelMap.value;
                        responseSVMXMap.values = null;
                        responseSVMXMap.valueMap = listValueMaps;
                        responseValueMap.add(responseSVMXMap);
                    }
                    conflictHeader.valueMap = ConflictList;
                    ErrorHeader.valueMap = ErrorList;
                    responseValueMap.add(conflictHeader);
                    responseValueMap.add(ErrorHeader);
                }
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        if(response.success == null)
            response.success = true;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        response.valueMap = responseValueMap;
        return response;
    }
    
    public List<INTF_WebServicesDef.SVMXMap> updateRecordsFromClient(INTF_WebServicesDef.INTF_SFMRequest inputRequest, DateTime dtSyncStartTime, String strSyncConflict)
    {
        Datetime dtLastSyncTime;
        Database.Saveresult[] parentsaveresult;
        List<INTF_WebServicesDef.SVMXMap> ErrorList = new List<INTF_WebServicesDef.SVMXMap>();
        List<INTF_WebServicesDef.SVMXError> errors = new List<INTF_WebServicesDef.SVMXError>(); 
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap('ERROR', '');
        List<INTF_WebServicesDef.SVMXMap> ConflictList = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap conflictHeader = new INTF_WebServicesDef.SVMXMap('CONFLICT', '');
        List<INTF_WebServicesDef.SVMXMap> responseValueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        for(INTF_WebServicesDef.SVMXMap firstLevelMap : inputRequest.valueMap)
        {
            system.debug(LoggingLevel.WARN, ' Each Value Map in Request: ' + firstLevelMap);
            INTF_WebServicesDef.SVMXMap responseSVMXMap = new INTF_WebServicesDef.SVMXMap();
            List<INTF_WebServicesDef.SVMXMap> listValueMaps = new List<INTF_WebServicesDef.SVMXMap>();
            
            if(firstLevelMap.key == 'SYNC_TIME_STAMP')
                dtLastSyncTime = Datetime.valueOf(firstLevelMap.value);
    
            if(firstLevelMap.key == 'object_name') 
            {
                List<sObject> sobjList = new List<sObject>();
                INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                clsObjectDefinition.objectName = firstLevelMap.value;
                INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                MAP<String,String> mapFieldAndItsType = new Map<String,String>();
                MAP<String,Integer> mapFieldAndItsScale = new Map<String,Integer>();
                Set<String> setUpdatableFieldNames = new Set<String>();
                
                if(objDef != NULL) 
                {
                    for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                    {
                        if (objProp.key=='FIELDPROPERTY')
                        {
                            for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                            {
                                for(INTF_WebServicesDef.SVMXMap fldObj : lstField.valueMap)
                                {
                                    if(fldObj.key == 'TYPE')
                                    {
                                        mapFieldAndItsType.put(lstField.value, fldObj.value);
                                    }
                                    if(fldObj.key == 'UPDATEABLE')
                                    {
                                        if(fldObj.value == 'true')
                                            setUpdatableFieldNames.add(lstField.value);
                                    }
                                    if(fldObj.key == 'SCALE' && fldObj.value != null && Integer.valueOf(fldObj.value) != 0)
                                    {
                                        system.debug(LoggingLevel.WARN, 'Field = ' + lstField.value + '; Scale = ' + fldObj.value);
                                        mapFieldAndItsScale.put(lstField.value, Integer.valueOf(fldObj.value)); 
                                    }
                                }
                            }
                        }
                    }
                }
                
                for(INTF_WebServicesDef.SVMXMap secondLevelMap : firstLevelMap.valueMap)
                {
                    if(secondLevelMap.key == 'Fields')
                    {
                        system.debug(LoggingLevel.WARN, 'Inside Fields');
                        DateTime newModifiedDate;
                        List<String> lstSFIds = new List<String>();
                        Map<String, String> mapIdToRecordReqKey = new Map<String, String>();
                        Map<String, Map<String, String>> mapIdAndBeforeSaveRecord = new Map<String, Map<String, String>>();
                        Map<String, Map<String, String>> mapIdAndRecordToBeUpdated = new Map<String, Map<String, String>>();
                        
                        for(INTF_WebServicesDef.SVMXMap eachRecordToUpdate : secondLevelMap.valueMap)
                        {
                            system.debug(LoggingLevel.WARN, ' Each Record to Update in Request: ' + eachRecordToUpdate);
                            if(eachRecordToUpdate.key != 'BEFORE_SAVE')
                            {
                                Map<String, String> mapFieldValue = (Map<String, String>)JSON.deserialize(eachRecordToUpdate.value, Map<String, String>.Class);
                                system.debug(LoggingLevel.WARN, 'mapFieldValue' + mapFieldValue + ';mapFieldValue.get(Id) = ' + mapFieldValue.get('Id'));
                                mapIdAndRecordToBeUpdated.put(mapFieldValue.get('Id'), mapFieldValue);
                                mapIdToRecordReqKey.put(mapFieldValue.get('Id'), eachRecordToUpdate.key);
                                system.debug(LoggingLevel.WARN, 'Id = ' + mapFieldValue.get('Id') + '; eachRecordToUpdate.key = ' + eachRecordToUpdate.key);
                            }
                            else if(eachRecordToUpdate.key == 'BEFORE_SAVE')
                            {
                                for(String strJsonBeforeSave : eachRecordToUpdate.values)
                                {
                                    Map<String, String> mapFieldValue = (Map<String, String>)JSON.deserialize(strJsonBeforeSave, Map<String, String>.Class);
                                    system.debug(LoggingLevel.WARN, 'mapFieldValue' + mapFieldValue + ';mapFieldValue.get(Id) = ' + mapFieldValue.get('Id'));
                                    mapIdAndBeforeSaveRecord.put(mapFieldValue.get('Id'), mapFieldValue);
                                }   
                            }
                        }
                        
                        lstSFIds.addAll(mapIdAndRecordToBeUpdated.keySet());
                        system.debug(LoggingLevel.WARN,'List of Record Ids to be updated = ' + lstSFIds);
                        
                        String strQuery = 'SELECT LastModifiedById , LastModifiedDate FROM ' + firstLevelMap.value + ' WHERE Id IN : lstSFIds';
                        List<SObject> queryResult = Database.query(strQuery);
                        system.debug(LoggingLevel.WARN,'Query  = ' + strQuery + '; lstSFIds = ' + lstSFIds + '; Query Results = ' + queryResult);
                        system.debug(LoggingLevel.WARN, 'Sync Start Time = ' + dtSyncStartTime + ', Current Time = ' + DateTime.now());
                        
                        if(dtSyncStartTime != null)
                            newModifiedDate = dtSyncStartTime;
                        else
                            newModifiedDate = DateTime.now();
    
                        Integer a = 0;
                        for(String strRecordId : lstSFIds)
                        {
                            String strClientOvrde = '';
                            Boolean strConflict = false;
                            sObject sObj = Schema.getGlobalDescribe().get(clsObjectDefinition.objectName).newSObject(strRecordId);
                            system.debug(LoggingLevel.WARN, 'strRecordId =' + strRecordId + '; sObject = ' + sObj);
                            String sUserId = UserInfo.getUserId();
                            DateTime dbLastModified = Datetime.valueOf(queryResult[a].get('LastModifiedDate'));
                            system.debug(LoggingLevel.WARN,'LMD of Record = ' + dbLastModified + ', Last Sync = ' + dtLastSyncTime + ', New Modified Date = ' + newModifiedDate);
                            
                            if(mapIdToRecordReqKey != null)
                                strClientOvrde = mapIdToRecordReqKey.get(strRecordId);
                            system.debug(LoggingLevel.WARN,'strClientOvrde = ' + strClientOvrde);
                            
                            if(strClientOvrde != 'CLIENT_OVERRIDE' && (dbLastModified > dtLastSyncTime) && ((dbLastModified < newModifiedDate) || queryResult[a].get('LastModifiedById') != sUserId) && queryResult != null && queryResult.size() > 0)
                            {
                                INTF_WebServicesDef.SVMXMap conflict;                               
                                if(mapIdAndRecordToBeUpdated.containsKey(strRecordId) && mapIdAndBeforeSaveRecord.containsKey(strRecordId))
                                {
                                    List<String> lstFieldNames = (new COMM_Utils_V2()).checkDuplicateFields(new List<String>(setUpdatableFieldNames) , firstLevelMap.value); //Remove duplicate API fields
                                    String strFieldNamesToQry =  clsObjectDefinition.getObjectFieldNames(lstFieldNames);
                                    sObject eachRecord = Database.query('Select ' + strFieldNamesToQry + ' from ' + firstLevelMap.value + ' where Id = \'' +  strRecordId + '\'');
                                    
                                    for(String eachField : mapIdAndBeforeSaveRecord.get(strRecordId).keySet())
                                    {
                                        if(setUpdatableFieldNames.contains(eachField))
                                        {
                                            String strFldValFrmClient = mapIdAndBeforeSaveRecord.get(strRecordId).get(eachField);
                                            String strFldValAtSrvr = String.valueOf(eachRecord.get(eachField));
                                            system.debug(LoggingLevel.WARN, 'Field Name = ' + eachField + '; Type = ' + mapFieldAndItsType.get(eachField) + '; Field Value at Client = ' + strFldValFrmClient + '; Field Value at Server = ' + strFldValAtSrvr);
                                            if(mapFieldAndItsType.get(eachField) == 'DATETIME' && strFldValFrmClient != '')
                                            {
                                                strFldValFrmClient = strFldValFrmClient.replace('T', ' ');
                                                strFldValFrmClient = strFldValFrmClient.replace('Z', ' ');
                                                strFldValFrmClient = String.valueOfGmt(DateTime.valueOfGmt(strFldValFrmClient));    
                                            }
                                            if(mapFieldAndItsType.get(eachField) == 'DATE' && strFldValFrmClient != '')
                                            {
                                                strFldValFrmClient = String.valueOfGmt(Date.valueOf(strFldValFrmClient));
                                            }
                                            if(mapFieldAndItsType.get(eachField) == 'TIME')
                                            {
                                                continue;
                                            }
                                            if((mapFieldAndItsType.get(eachField) == 'DOUBLE' || mapFieldAndItsType.get(eachField) == 'DECIMAL' || mapFieldAndItsType.get(eachField) == 'CURRENCY' || mapFieldAndItsType.get(eachField) == 'PERCENT') && strFldValFrmClient != '')
                                            {
                                                String strTempFldVal = strFldValFrmClient;
                                                strTempFldVal = strTempFldVal.replace('.',':');
                                                List<String> lstDecimal = strTempFldVal.split(':');
                                                if(lstDecimal != null && lstDecimal.size() >= 2)
                                                {
                                                    if(mapFieldAndItsScale.get(eachField) != null)
                                                    {
                                                        for(Integer i = 0; i< mapFieldAndItsScale.get(eachField) - lstDecimal[1].length(); i++)
                                                            strFldValFrmClient += '0';
                                                    }
                                                    else
                                                    {
                                                        strFldValFrmClient = lstDecimal[0];
                                                    }
                                                }
                                            }
                                            
                                            if(strFldValAtSrvr == null)
                                                strFldValAtSrvr = '';
                                            
                                            system.debug(LoggingLevel.WARN, 'Field Name = ' + eachField + '; Field Value at Client before save = ' + strFldValFrmClient + '; Field Value at Server = ' + strFldValAtSrvr);
                                            String strFieldValueToSave = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                            if(mapFieldAndItsType.get(eachField) == 'DATETIME' && strFieldValueToSave != null && strFieldValueToSave != '')
                                            {
                                                strFieldValueToSave = strFieldValueToSave.replace('T', ' ');
                                                strFieldValueToSave = strFieldValueToSave.replace('Z', ' ');
                                                strFieldValueToSave = String.valueOfGmt(DateTime.valueOfGmt(strFieldValueToSave));  
                                            }
                                            if(mapFieldAndItsType.get(eachField) == 'DATE' && strFieldValueToSave != null && strFieldValueToSave != '')
                                            {
                                                system.debug(LoggingLevel.WARN, 'strFieldValueToSave = ' + strFieldValueToSave);
                                                strFieldValueToSave = strFieldValueToSave.replace('T', ' ');
                                                strFieldValueToSave = strFieldValueToSave.replace('Z', ' ');
                                                strFieldValueToSave = String.valueOfGmt(Date.valueOf(strFieldValueToSave));
                                                system.debug(LoggingLevel.WARN, 'strFieldValueToSave = ' + strFieldValueToSave);  
                                            }
                                            if((mapFieldAndItsType.get(eachField) == 'DOUBLE' || mapFieldAndItsType.get(eachField) == 'DECIMAL' || mapFieldAndItsType.get(eachField) == 'CURRENCY' || mapFieldAndItsType.get(eachField) == 'PERCENT') && strFieldValueToSave != null && strFieldValueToSave != '')
                                            {
                                                String strTempFldVal = strFieldValueToSave;
                                                strTempFldVal = strTempFldVal.replace('.',':');
                                                List<String> lstDecimal = strTempFldVal.split(':');
                                                if(lstDecimal != null && lstDecimal.size() >= 2)
                                                {
                                                    if(mapFieldAndItsScale.get(eachField) != null)
                                                    {
                                                        for(Integer i = 0; i< mapFieldAndItsScale.get(eachField) - lstDecimal[1].length(); i++)
                                                            strFieldValueToSave += '0';
                                                    }
                                                    else
                                                    {
                                                        strFieldValueToSave = lstDecimal[0];
                                                    }
                                                }
                                            }
                                            system.debug(LoggingLevel.WARN, 'Field value to be updated from client = ' + strFieldValueToSave + 'Field value at server = ' + strFldValAtSrvr);
                                            
                                            if(!strFldValFrmClient.equals(strFldValAtSrvr) && strFieldValueToSave != strFldValAtSrvr)
                                            {
                                                system.debug(LoggingLevel.WARN,'Conflict in field = ' + eachField + ' and Sync Conflict = ' + strSyncConflict);
                                                if(strSyncConflict == 'Allow user to choose')
                                                {
                                                    system.debug(LoggingLevel.WARN,'Conflict when Allow user to choose');
                                                    conflict = new INTF_WebServicesDef.SVMXMap();
                                                    conflict.key = firstLevelMap.value;
                                                    conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(newModifiedDate) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(dtLastSyncTime);
                                            
                                                    List<INTF_WebServicesDef.SVMXMap> confChild = new List<INTF_WebServicesDef.SVMXMap>();
                                                    confChild.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                                    conflict.valueMap = confChild;
                                                    ConflictList.add(conflict);
                                                    strConflict = true;
                                                    break;  
                                                }
                                                else if(strSyncConflict == 'ServiceMax online data')
                                                {
                                                    if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
                                                    {
                                                        sObj = createsObject(sObj, mapFieldAndItsType, eachField, strFldValAtSrvr);
                                                    }
                                                }
                                                else if(strSyncConflict == 'Mobile device data')
                                                {
                                                    if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
                                                    {
                                                        String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                        sObj = createsObject(sObj, mapFieldAndItsType, eachField, strFieldValue);
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
                                                {
                                                    String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(eachField);
                                                    sObj = createsObject(sObj, mapFieldAndItsType, eachField, strFieldValue);
                                                }   
                                            }
                                        }
                                    }
                                    if(!strConflict)
                                        sObjList.add(sobj);
                                    system.debug(LoggingLevel.WARN,'sObj to UPDATE = ' + sObj);
                                }
                                else
                                {
                                    if(strSyncConflict != 'ServiceMax online data')
                                    {
                                        system.debug(LoggingLevel.WARN,'Conflict when ServiceMax NOT online data');
                                        conflict = new INTF_WebServicesDef.SVMXMap();
                                        conflict.key = firstLevelMap.value;
                                        conflict.value = system.label.IPAD018_TAG029 + ' – ' + system.label.IPAD018_TAG052  + String.ValueOf(dbLastModified ) + '; ' + system.label.IPAD018_TAG053  + String.ValueOf(newModifiedDate) + '; ' + system.label.IPAD018_TAG056 + String.ValueOf(dtLastSyncTime);
                                    
                                        List<INTF_WebServicesDef.SVMXMap> confChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        confChild.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                        conflict.valueMap = confChild;
                                        ConflictList.add(conflict);
                                    }
                                    else
                                    {
                                        system.debug(LoggingLevel.WARN,'Conflict when ServiceMax online data');
                                        listValueMaps.add(new INTF_WebServicesDef.SVMXMap('', (String)queryResult[a].get('Id')));
                                    }
                                }
                            }
                            else
                            {
                                sObjList.add(createsObjectToUpdate(strRecordId, sObj, setUpdatableFieldNames, mapIdAndRecordToBeUpdated, mapFieldAndItsType));  
                            }
                            a++;
                        }
                        system.debug(LoggingLevel.WARN, 'sObjList =' + sObjList);
                        INTF_WebServicesDef.SVMXMap Error;
                        try
                        {
                            parentsaveresult = Database.update(sObjList,false);
                        }
                        catch(DmlException e)
                        {
                            List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                            errChild.add(new INTF_WebServicesDef.SVMXMap('', ''));
                            ErrorList.add(new INTF_WebServicesDef.SVMXMap(firstLevelMap.value, e.getMessage()));   
                        }
                        finally
                        {
                            List<String> sfids = new List<String>();
                            if(parentsaveresult != null)
                            {
                                Integer i=0;
                                for(Database.Saveresult parentSave : parentsaveresult)
                                {
                                    sfids.add(parentSave.getId());
                                    if(parentSave.isSuccess())
                                    {
                                        listValueMaps.add(new INTF_WebServicesDef.SVMXMap('', parentSave.getId()));
                                        system.debug(LoggingLevel.WARN, 'Update is Successfull');
                                    }
                                    else
                                    {
                                        system.debug(LoggingLevel.WARN, 'Problem in Update');   
                                        Error = new INTF_WebServicesDef.SVMXMap();
                                        Error.key = firstLevelMap.value;
                                        Database.Error[] err = parentSave.getErrors();                                      
                                        Error.value = err[0].getMessage();
                                        List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        errChild.add(new INTF_WebServicesDef.SVMXMap('', String.valueOf(sObjList[i].Id)));
                                        Error.valueMap = errChild;
                                        ErrorList.add(Error);
                                    }
                                    i++;
                                }
                            }
                        }
                    }
                }    
            }
            responseSVMXMap.key = firstLevelMap.key;
            responseSVMXMap.value = firstLevelMap.value;
            responseSVMXMap.values = null;
            responseSVMXMap.valueMap = listValueMaps;
            responseValueMap.add(responseSVMXMap);
        }
        conflictHeader.valueMap = ConflictList;
        ErrorHeader.valueMap = ErrorList;
        responseValueMap.add(conflictHeader);
        responseValueMap.add(ErrorHeader);
        return responseValueMap;
    }
    
    public sObject createsObjectToUpdate(String strRecordId, sObject sObj, Set<String> setUpdatableFieldNames, Map<String, Map<String, String>> mapIdAndRecordToBeUpdated, map<String,String> mapFieldAndItsType)
    {
        system.debug(LoggingLevel.WARN, 'sObj = ' + sObj);
        if(mapIdAndRecordToBeUpdated.get(strRecordId) != null)
        {
            for(String strFieldName : mapIdAndRecordToBeUpdated.get(strRecordId).keySet())
            {
                String strFieldValue = mapIdAndRecordToBeUpdated.get(strRecordId).get(strFieldName);
                if(setUpdatableFieldNames.contains(strFieldName))
                {
                    system.debug(LoggingLevel.WARN, 'sObj before = ' + sObj);
                    sObj = createsObject(sObj, mapFieldAndItsType, strFieldName, strFieldValue);
                    system.debug(LoggingLevel.WARN, 'sObj after = ' + sObj);
                }
            }
        }
        system.debug(LoggingLevel.WARN, 'sObj = ' + sObj);
        return sObj;
    }
    
    public sObject createsObject(sObject sObj, map<String,String> mapFieldAndItsType, String strFieldName, String strFieldValue)
    {
        if(strFieldValue == null || strFieldValue == '')
            sObj.put(strFieldName, null);
        else
        {
            strFieldValue = strFieldValue.replace('&amp;', '&');
            strFieldValue = strFieldValue.replace('&apos;', '\'');
            strFieldValue = strFieldValue.replace('&lt;', '<');
            strFieldValue = strFieldValue.replace('&gt;', '>');
            strFieldValue = strFieldValue.replace('&quot;', '"');
        
            if(mapFieldAndItsType.get(strFieldName) == 'DATETIME')
            {
                strFieldValue = strFieldValue.replace('T', ' ');
                strFieldValue = strFieldValue.replace('Z', ' ');
                sObj.put(strFieldName, Datetime.valueOfGmt(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'DATE')
            {
                sObj.put(strFieldName, Date.valueOf(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'TIME')
            {
                //do nothing as we do not support time field
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'BOOLEAN')
            {
                sObj.put(strFieldName, Boolean.valueOf(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'DOUBLE')
            {
                sObj.put(strFieldName, decimal.valueOf(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'DECIMAL' || mapFieldAndItsType.get(strFieldName) == 'CURRENCY' || mapFieldAndItsType.get(strFieldName) == 'PERCENT')
            {
                sObj.put(strFieldName, decimal.valueOf(strFieldValue));
            }
            else if(mapFieldAndItsType.get(strFieldName) == 'INTEGER')
            {
                sObj.put(strFieldName, Integer.valueOf(strFieldValue));
            }
            else
            {
                sObj.put(strFieldName, strFieldValue);
            }
        }
        return sObj;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse SendClientDeletesToBase(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('SendClientDeletesToBase');
        system.debug(LoggingLevel.WARN,'Put_Delete request = ' + inputRequest);
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.SVMXMap> reqMap = inputRequest.valueMap;
        Iterator<INTF_WebServicesDef.SVMXMap> reqMapIterator = reqMap.Iterator();
        INTF_WebServicesDef.SVMXMap ErrorHeader = new INTF_WebServicesDef.SVMXMap();
        List<INTF_WebServicesDef.SVMXMAP> respValueMap;
        ErrorHeader.key = 'ERROR';
        try
        {
            INTF_DataSync.logSOQL(intMethodCount,'Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value');
            List<SVMXC__Sync_Request__c> sync_requests = [Select Id from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            String Record_id;
            if(sync_requests.size() <= 0)
            {        
                SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = inputRequest.value);
                Database.SaveResult Result = Database.insert(requestRecord);
                Record_id = Result.getId();
            }
            else
                Record_id = sync_requests[0].Id;
            
            List<String> SFList = new List<String>();
            INTF_DataSync.logSOQL(intMethodCount,'Select SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__c = :Record_Id and SVMXC__Operation_Type__c = \'Delete\'');
            for(SVMXC__Sync_Request_Records__c request_record: [Select SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__c = :Record_Id and SVMXC__Operation_Type__c = 'Delete'])
                SFList.add(request_record.SVMXC__SFDC_Record_Id__c);
                
            if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'PUT_DELETE')
            {        
                List<INTF_WebServicesDef.SVMXMap> secondLevelMap = new List<INTF_WebServicesDef.SVMXMap>();
                List<INTF_WebServicesDef.SVMXMap> errorList = new List<INTF_WebServicesDef.SVMXMap>();
                respValueMap = new List<INTF_WebServicesDef.SVMXMap>();  
                while(reqMapIterator.hasNext())
                {
                    INTF_WebServicesDef.SVMXMap selMap = new INTF_WebServicesDef.SVMXMap();
                    selMap = reqMapIterator.next();
                    if(selMap.key == 'Object_Name')
                    {
                        String tableName = selMap.value;
                        INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
                        clsObjectDefinition.objectName = selMap.value;
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                        secondLevelMap = selMap.valueMap;
                        Integer sizeOfSecondLevelMap = secondLevelMap.size();
                        Iterator<INTF_WebServicesDef.SVMXMap> secondMapIterator = secondLevelMap.Iterator();
                        List<Sobject> sobjList = new List<Sobject>();
                        List<INTF_WebServicesDef.SVMXMap> idValueMap = new List<INTF_WebServicesDef.SVMXMap>();
                        List<SVMXC__Sync_Request_Records__c> Sync_Request_Rec_List = new List<SVMXC__Sync_Request_Records__c>();
                        INTF_WebServicesDef.SVMXMAP parentMap = new INTF_WebServicesDef.SVMXMAP();
                        List<INTF_WebServicesDef.SVMXMAP> objValueMap;
                        while(secondMapIterator.hasNext())
                        {
                            INTF_WebServicesDef.SVMXMap selRecMap = new INTF_WebServicesDef.SVMXMap();
                            selRecMap = secondMapIterator.next();
                            if(selRecMap.key == 'Fields')
                            {
                                idValueMap = selRecMap.valueMap;
                                Iterator<INTF_WebServicesDef.SVMXMap> idMapIterator = idValueMap.Iterator();
                                while(idMapIterator.hasNext())
                                {
                                    objValueMap = new List<INTF_WebServicesDef.SVMXMap>();
                                    Boolean idExist = false;
                                    INTF_WebServicesDef.SVMXMap selRec = new INTF_WebServicesDef.SVMXMap();
                                    selRec = idMapIterator.next();
                                    String idToDelete = selRec.value;
                                    if(SFList != null && idToDelete != null)
                                    {
                                        for(String id : SFList)
                                        {
                                            if(id.equals(idToDelete))
                                            {
                                                INTF_WebServicesDef.SVMXMAP existMap = new INTF_WebServicesDef.SVMXMAP();
                                                existMap.value = id;
                                                objValueMap.add(existMap);
                                                idExist = true;
                                                break;
                                            }
                                        }
                                    }
                                    sObject selObject;
                                    if(!idExist && idToDelete !='')
                                    {
                                        selObject = Schema.getGlobalDescribe().get(clsObjectDefinition.objectName).newSObject(idToDelete);
                                        sobjList.add(selObject);
                                    }
                                }          
                                INTF_WebServicesDef.SVMXMap ErrorObj;
                                Database.Deleteresult[] delResult = Database.delete(sobjList,false);
                                for(Database.Deleteresult selResult : delResult)
                                {
                                    INTF_WebServicesDef.SVMXMAP recordMap = new INTF_WebServicesDef.SVMXMAP();
                                    String success = 'true';
                                    if(selResult.isSuccess())
                                    {
                                        success = 'Sucess';
                                        recordMap.key = success;
                                        recordMap.value = String.valueOf(selResult.getId());
                                        objValueMap.add(recordMap);
                                        
                                        SVMXC__Sync_Request_Records__c Sync_Request_Rec = new SVMXC__Sync_Request_Records__c(SVMXC__Operation_Type__c = 'Delete', SVMXC__SFDC_Record_Id__c = selResult.getId(), SVMXC__Sync_Request__c = Record_id);
                                        Sync_Request_Rec_List.add(Sync_Request_Rec);
                                    }
                                    else
                                    {
                                        success = 'Fail';
                                        ErrorObj = new INTF_WebServicesDef.SVMXMap();
                                        ErrorObj.key = selMap.value;
                                        Database.Error[] err = selResult.getErrors();
                                        ErrorObj.value = err[0].getMessage();
                                        
                                        List<INTF_WebServicesDef.SVMXMap> errChild = new List<INTF_WebServicesDef.SVMXMap>();
                                        INTF_WebServicesDef.SVMXMap child = new INTF_WebServicesDef.SVMXMap();
                                        child.key = '';
                                        child.value = selResult.getId();
                                        errChild.add(child);
                                        ErrorObj.valueMap = errChild;
                                        errorList.add(ErrorObj);
                                    }
                                }
                                if(Sync_Request_Rec_List.size() > 0)
                                    Database.Saveresult[] dbRecords = Database.insert(Sync_Request_Rec_List);
                            }
                        }
                        parentMap.valueMap = objValueMap;
                        parentMap.key = 'Object_Name';
                        parentMap.value = selMap.value;
                        respValueMap.add(parentMap);
                    }
                }
                ErrorHeader.valueMap = errorList;
                respValueMap.add(ErrorHeader);
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        if(response.success == null)
            response.success = true;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        response.valueMap = respValueMap;
        system.debug(LoggingLevel.WARN,'Put_Delete response = ' + response);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'SendClientDeletesToBase');
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getRecordsForIds(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        system.debug(LoggingLevel.WARN, ' From TXFETCH class Community ID is '+Network.getNetworkId());
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getRecordsForIds');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        Map<String, String> mapErrorMessage = new Map<String, String>();
        try
        {
            String strVersion = '';
            Boolean isCompatible = false;
            set<String> setRefObjToSkip = new set<String>();
            List<String> lstVersionInfo = new List<String>();
            Integer intLimitPercent = 70, intLimitRelationshipFields = 35;
            INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
            
            list<String> lstSettingId = new list<String>{'SET004', 'SET011', 'SET013'};
            List<String> lstExpectedVersionInfo = new List<String>{'13','1','0','9'};
            
            map<String, String> mapSettingsForIPAD018 = new map<String, String>();
            mapSettingsForIPAD018 = (new SVMXC.COMM_Utils_ManageSettings()).SVMX_getSettingList('IPAD018', lstSettingId);
            system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
            if(mapSettingsForIPAD018.containskey('SET004') && mapSettingsForIPAD018.get('SET004') != null)
            {
                String strValue = mapSettingsForIPAD018.get('SET004');
                list<String> lstValue = new list<String>();
                lstValue = strValue.split(',');
                if(lstValue.size() > 0)
                {
                    for(Integer i = 0; i < lstValue.size(); i++)
                        setRefObjToSkip.add(lstValue[i].toUpperCase());
                }
            }
            else
            {
                setRefObjToSkip.add('PARTNERNETWORKCONNECTION');
                setRefObjToSkip.add('USER');
                setRefObjToSkip.add('FEEDPOST');
                setRefObjToSkip.add('SOLUTION');
            }
            if(mapSettingsForIPAD018.containskey('SET011') && mapSettingsForIPAD018.get('SET011') != null)
                intLimitPercent = integer.valueOf(mapSettingsForIPAD018.get('SET011'));
            else
                intLimitPercent = 70;
                
            if(mapSettingsForIPAD018.containskey('SET013') && mapSettingsForIPAD018.get('SET013') != null)
                intLimitRelationshipFields = integer.valueOf(mapSettingsForIPAD018.get('SET013'));
            else
                intLimitRelationshipFields = 35;
            system.debug(LoggingLevel.WARN,'intLimitRelationshipFields = ' + intLimitRelationshipFields);   
            if(inputRequest.clientInfo != null && inputRequest.clientInfo.size() > 0)
            {
                for(INTF_WebServicesDef.SVMXClient clientInform : inputRequest.clientInfo)
                {
                    for(String strVersionInfo : clientInform.clientInfo)
                    {
                        if(strVersionInfo != null && strVersionInfo.length() > 0 && strVersionInfo.contains('appversion'))
                        {
                            List<String> lstVersion = new List<String>();
                            lstVersion = strVersionInfo.split(':');
                            if(lstVersion != null && lstVersion.size() == 2)
                            {
                                strVersion = lstVersion[1];
                                system.debug(LoggingLevel.WARN, 'Version = ' + strVersion);
                                strVersion = strVersion.replace('.', ':');
                                system.debug(LoggingLevel.WARN, 'Version = ' + strVersion);
                                lstVersionInfo = strVersion.split(':');
                                if(lstVersionInfo != null && lstVersionInfo.size() < 4)
                                {
                                    while(lstVersionInfo.size() < 4)
                                        lstVersionInfo.add('0');
                                }
                                for(Integer i = 0; i < 4; i++)
                                {
                                    if(Integer.valueOf(lstVersionInfo[i]) > Integer.valueOf(lstExpectedVersionInfo[i]))
                                    {
                                        isCompatible = true;
                                        break;
                                    }
                                }
                            }   
                        }
                    }
                    if(isCompatible)
                        break;
                }
            }
            if(inputRequest.valueMap != null && inputRequest.valueMap.size() != 0)
            {
                Integer response_size = 0;
                String strErrObjNames = '';
                List<INTF_WebServicesDef.SVMXMap> secondLevelMap = new List<INTF_WebServicesDef.SVMXMap>();
                
                if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'TX_FETCH')
                {        
                    for(INTF_WebServicesDef.SVMXMap eachObjMap : inputRequest.valueMap)
                    {
                        System.debug('eachObjMap '+eachObjMap);
                        INTF_WebServicesDef.SVMXMap selObj = new INTF_WebServicesDef.SVMXMap();
                                                
                        if(eachObjMap.key == 'SVMX_TIME_LOG')
                            continue;
                            
                        String tableName = eachObjMap.value;
                        Set<String> documentFields; 
                        if(tableName == 'ContentDocumentLink'){
                            documentFields = getFieldsForFiles(setRefObjToSkip, intLimitRelationshipFields);
                        }                        

                        List<String> SFIDList = new List<String>();
                        SFIDList.addAll(eachObjMap.values);
                        //List<String> SFIDList = eachObjMap.values;
                        System.debug(LoggingLevel.WARN, 'Retrieving ' + SFIDList.size() + ' records for Object ' + tableName );
                        if(tableName != '' && tableName != null)
                        {
                            clsObjectDefinition.objectName = tableName;
                            try
                            {
                                INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition(); 
                                List<String> fieldsName = new List<String>();
                                if(objDef != NULL) 
                                {
                                    for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                                    {
                                        if(objProp.key=='FIELDPROPERTY')
                                        {
                                            Integer refFieldCount = 0;
                                           for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                           {
                                                if( (tableName == 'Attachment' && lstField.value == 'Body') || (tableName == 'ContentVersion' && lstField.value == 'VersionData'))
                                                {
                                                    system.debug(LoggingLevel.WARN, 'Attachment/File Object - do not query Body field');
                                                }
                                                else
                                                    fieldsName.add(lstField.value);
                                                if(refFieldCount == intLimitRelationshipFields)
                                                    continue;
                                                String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', lstField.valueMap);
                                                if (reference_to != null)
                                                {
                                                    String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', lstField.valueMap);
                                                    
                                                    if(tableName == 'ContentDocumentLink' && reference_to =='ContentDocument' && relationship_name != NULL){
                                                            for(string cdlFieldName: documentFields){
                                                                fieldsName.add(relationship_name+'.'+cdlFieldName);
                                                            }
                                                            refFieldCount++;
                                                   }else if (reference_to == 'Case'){
                                                        fieldsName.add(relationship_name + '.CaseNumber');
                                                        refFieldCount++;
                                                    }else if(reference_to=='ContentDocument' || reference_to=='LatestPublishedVersion' || reference_to =='ContentAsset' || reference_to =='ExternalDataSource' || reference_to =='ContentBody' || reference_to=='ContentVersion' || reference_to=='FeedItem'){//Added as there is no name field in ContentDocumnt
                                                        continue;
                                                    }else if (setRefObjToSkip.contains(reference_to.toUpperCase()) || relationship_name == null)
                                                        continue;
                                                    else
                                                    {
                                                        fieldsName.add(relationship_name + '.Name');
                                                        refFieldCount++;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                fieldsName = (new COMM_Utils_V2()).checkDuplicateFields(fieldsName, tableName); //Remove duplicate API Fields
                                
                                List<INTF_WebServicesDef.SVMXMap> tableValueMap = new List<INTF_WebServicesDef.SVMXMap>();
                                INTF_WebServicesDef.SVMXMap objSafeToDelete = new INTF_WebServicesDef.SVMXMap('SAFE_TO_DELETE','');
                                List<String> lstDeletedIds = new List<String>();
                                String strFldNames =  clsObjectDefinition.getObjectFieldNames(fieldsName);
                                system.debug(Logginglevel.WARN, '**** Object Name is = '+tableName);
                                system.debug(Logginglevel.WARN, '**** Fields are = '+strFldNames);
                                objdef.valueMap.clear();
                                fieldsName.clear();
                                
                                system.debug(LoggingLevel.WARN, 'Heap size before querying records = ' + Limits.getHeapSize() + '; response_size = ' + response_size);
                                
                                INTF_DataSync.logSOQL(intMethodCount, 'Select ' + strFldNames + ' FROM '+ tableName + ' WHERE Id IN :SFIDList ALL ROWS');
                                
                                List<Sobject> sobjectList1 = Database.query('Select '+ strFldNames + ' FROM '+ tableName + ' WHERE Id IN :SFIDList ALL ROWS');
                                system.debug(LoggingLevel.WARN, '******sobjectList1 = ' + sobjectList1.size());
                                
                                for(Sobject selectedSobj : sobjectList1)
                                //for(Sobject selectedSobj : Database.query('Select ' + strFldNames + ' FROM '+ tableName + ' WHERE Id IN :SFIDList ALL ROWS'))
                                {
                                    
                                    if( (tableName == 'User' && selectedSobj.get('isActive') == true ) || ( tableName != 'User' && selectedSobj.get('IsDeleted') == false) ){
                                        INTF_WebServicesDef.SVMXMap objMap = new INTF_WebServicesDef.SVMXMap();
                                        objMap.value = JSON.serialize(selectedSobj);
                                        tableValueMap.add(objMap);
                                        response_size += objMap.value.length();
                                        
                                        if(response_size > 3000000 || isLimitReached(intLimitPercent)){
                                             break;
                                        }
                                    }else{
                                        //respond back to client with deleted records
                                        lstDeletedIds.add(String.valueOf(selectedSobj.get('Id')));
                                    }
                                }
                                
                                if(sobjectList1 == NULL || sobjectList1.isEmpty()){
                                        //None of the records could be queried
                                        lstDeletedIds.addAll(SFIDList);
                                        response_size += lstDeletedIds.size();
                                }
                                 
                                system.debug(LoggingLevel.WARN, 'lstDeletedIds = ' + lstDeletedIds.size()); 
                                
                                if(lstDeletedIds.size() > 0)
                                        objSafeToDelete.valueMap.add(new INTF_WebServicesDef.SVMXMap(tableName, '', lstDeletedIds));
                                        
                                strFldNames = '';
                                system.debug(LoggingLevel.WARN, 'Heap size after querying records = ' + Limits.getHeapSize() + '; response_size = ' + response_size);
                                
                                selObj.value = tableName;
                                selObj.valueMap = tableValueMap;
                                if(tableValueMap.size() > 0){
                                        secondLevelMap.add(selObj);
                                }
                                secondLevelMap.add(objSafeToDelete);
                                if(response_size > 3000000 || isLimitReached(intLimitPercent))
                                    break;
                            }
                            catch(Exception ex)
                            {
                                system.debug(LoggingLevel.WARN, 'Error when trying to describe object ' + tableName + ':-' + ex.getMessage());
                                if(strErrObjNames != '') strErrObjNames += ',';
                                strErrObjNames += ' ' + tableName;
                                continue;
                            }
                        }
                    }
                    
                     
                }
                if(response_size == 0)
                {
                    system.debug(LoggingLevel.WARN, 'Objects with Errors = ' + strErrObjNames + '; isCompatible = ' + isCompatible);
                    if((strErrObjNames != null && strErrObjNames.length() > 0) || !isCompatible)
                    {
                        mapErrorMessage.put(system.label.IPAD018_TAG054, strErrObjNames + system.label.IPAD018_TAG055);
                        INTF_DataSync.logMethodEndTS(intMethodCount, 'getRecordsForIds');
                        throw new SmaxException();
                    }else{
                        INTF_WebServicesDef.SVMXMap objSafeToDelete = new INTF_WebServicesDef.SVMXMap();
                        objSafeToDelete.key = 'SAFE_TO_DELETE';
                        for(INTF_WebServicesDef.SVMXMap eachObj : inputRequest.valueMap)
                        {
                            if(eachObj.key == 'TX_OBJECT')
                            {
                                List<String> lstSuspectedIds = eachObj.values;
                                List<String> lstDeletedIds = new List<String>();
                                String isDeletedField = 'isDeleted';
                                if(eachObj.value == 'User'){
                                        isDeletedField = 'isActive';
                                }
                                INTF_DataSync.logSOQL(intMethodCount, 'Select Id, '+ isDeletedField+ ' FROM '+ eachObj.value + ' WHERE Id IN :lstSuspectedIds ALL ROWS');
                                for(sobject eachRecord : Database.query('Select Id, '+ isDeletedField+ ' FROM '+ eachObj.value + ' WHERE Id IN :lstSuspectedIds ALL ROWS'))
                                {
                                    if( (eachObj.value != 'User' && eachRecord.get('isDeleted') == true ) || (eachObj.value == 'User' && eachRecord.get('isActive') == false))
                                    {
                                        lstDeletedIds.add(String.valueOf(eachRecord.get('Id')));
                                    }
                                }
                                system.debug(LoggingLevel.WARN, 'Total deleted Ids during Sync are = ' + lstDeletedIds.size() + '; Ids are = ' + lstDeletedIds);
                                objSafeToDelete.valueMap.add(new INTF_WebServicesDef.SVMXMap(eachObj.value, '', lstDeletedIds));
                            }
                        }
                        secondLevelMap.add(objSafeToDelete);
                    } 
                }
                response.valueMap = secondLevelMap;
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(mapErrorMessage, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getRecordsForIds');
        system.debug(LoggingLevel.WARN, 'response txfetch = ' + response);
        return response;
    }
    
    public Set<String> getFieldsForFiles(set<String> setRefObjToSkip, integer intLimitRelationshipFields ){
            string fieldsForFiles = '';
            List<String> versionFields = new List<String>();
            Set<String> documentFields = new Set<String>();
            Set<String> objectsToSkip = new Set<String>{'ContentDocument','ContentVersion','LatestPublishedVersion','ContentAsset','ExternalDataSource','ContentBody'};
            Integer refFieldCount = 0; 
            
            //Get Fields related to contentVersion
            INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
        clsObjectDefinition.objectName = 'ContentVersion';
        
        INTF_WebServicesDef.SVMXMap objDefCV = clsObjectDefinition.INTF_GetObjectDefinition(); 
        
        for(INTF_WebServicesDef.SVMXMap objProp : objDefCV.valueMap){
            if(objProp.key=='FIELDPROPERTY'){
                refFieldCount = 0;
                
                for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap){
                    if(lstField.value != 'VersionData')  //Skip Versiondata for ContentVersion
                        versionFields.add(lstField.value);
                        
                    if(refFieldCount == intLimitRelationshipFields)
                        continue;   
                    String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', lstField.valueMap);
                    if (reference_to != null){
                        String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', lstField.valueMap);
                        if(objectsToSkip.contains(reference_to) || setRefObjToSkip.contains(reference_to.toUpperCase()) || relationship_name == NULL){
                            continue;
                        }else if (reference_to == 'Case'){
                            versionFields.add(relationship_name + '.CaseNumber');
                             refFieldCount++;
                         }else{
                            if(relationship_name != NULL){
                                versionFields.add(relationship_name + '.Name');
                                refFieldCount++;
                            }
                        }
                    }
                }
            }
        }
        
        
        system.debug('**** versionFields = '+versionFields.size());
        for(String eachfieldName: versionFields){
            system.debug('*** '+eachfieldName);
        }
        
        //Get Fields related to ContentDocument
        clsObjectDefinition = new INTF_GetObjectDefinition();
        clsObjectDefinition.objectName = 'ContentDocument';
        
        INTF_WebServicesDef.SVMXMap objDefCD = clsObjectDefinition.INTF_GetObjectDefinition(); 
        
        for(INTF_WebServicesDef.SVMXMap objProp : objDefCD.valueMap){
            if(objProp.key=='FIELDPROPERTY'){
                refFieldCount = 0;
                
                for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap){
                    documentFields.add(lstField.value);
                    
                    if(refFieldCount == intLimitRelationshipFields)
                        continue;
                    String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', lstField.valueMap);
                    if (reference_to != null){
                        String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', lstField.valueMap);
                        if(reference_to == 'ContentVersion' && relationship_name != NULL){
                            for(string versionFieldName: versionFields){
                                    documentFields.add(relationship_name+'.'+versionFieldName);
                                }
                                refFieldCount++;
                        }else if(objectsToSkip.contains(reference_to) || setRefObjToSkip.contains(reference_to.toUpperCase()) || relationship_name == NULL){
                            continue;
                        }else if (reference_to == 'Case'){
                            documentFields.add(relationship_name + '.CaseNumber');
                             refFieldCount++;
                         }else{
                            if(relationship_name != NULL){
                                documentFields.add(relationship_name + '.Name');
                                refFieldCount++;
                            }
                        }
                    }
                }
            }
        }
        
        system.debug('**** documentFields = '+documentFields.size());
        for(String cdName: documentFields){
            system.debug('*** '+cdName);
        }
        
        return documentFields;
    }
    
    //New Method for incremental data sync with the Event Window fix
    public INTF_WebServicesDef.INTF_SFMResponse RequestIncrementaldataFromBase(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Date ToDate, FromDate;
        String Record_id, deltaClause;
        Sync_Utility clsUtility = new Sync_Utility();
        List<String> SFDC_Records = new List<String>();
        List<INTF_WebServicesDef.SVMXMap> multiWrapList;
        Datetime dtToDate, dtFromDate, LastSynchTime, dtMovingDate;
        List<SVMXC__Sync_Request__c> sync_requests = new List<SVMXC__Sync_Request__c>();
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.SVMXMap> masterResponse = new List<INTF_WebServicesDef.SVMXMap>();
        
        sync_requests =[Select Id, CreatedDate from SVMXC__Sync_Request__c where SVMXC__Client_Request_Id__c = :inputRequest.value];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if (sync_requests.size() <= 0)
        {
            sync_requests = new List<SVMXC__Sync_Request__c>();
            SVMXC__Sync_Request__c requestRecord = new SVMXC__Sync_Request__c(SVMXC__Client_Request_Id__c = inputRequest.value);
            Database.SaveResult Result = Database.insert(requestRecord);
            Record_id = Result.getId();
            sync_requests.add(requestRecord);
        }
        else
        {
            Record_id = sync_requests[0].Id;
        }
        
        Datetime currentTime = Datetime.now();
        
        System.debug(LoggingLevel.info,'inputRequest.valueMap: ' + inputRequest);
        for(INTF_WebServicesDef.SVMXMap TimeStampMap : inputRequest.valueMap)
        {
            if(TimeStampMap.key == 'LAST_SYNC_TIME')
            {
                LastSynchTime = Datetime.valueOf(TimeStampMap.value);
                break;
            }
        }
        
        for(SVMXC__Sync_Request_Records__c request_record : [Select SVMXC__SFDC_Record_Id__c from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__r.SVMXC__Client_Request_Id__c = :inputRequest.value])
            SFDC_Records.add(request_record.SVMXC__SFDC_Record_Id__c);
        
        if (inputRequest.eventName == 'GET_INSERT')
        {
            if(SFDC_Records != null && SFDC_Records.size() > 0)
                deltaClause = ' CreatedDate >= :LastSynchTime AND Id not in : SFDC_Records ';
            else
                deltaClause = ' CreatedDate >= :LastSynchTime ';
        }
        else if (inputRequest.eventName == 'GET_UPDATE')
            deltaClause = ' LastModifiedDate >= :LastSynchTime AND isDeleted = false ';
        else if (inputRequest.eventName == 'GET_DELETE')
        {
            if(SFDC_Records != null && SFDC_Records.size() > 0)
                deltaClause = ' LastModifiedDate >= :LastSynchTime AND isDeleted = true AND Id not in : SFDC_Records ';
            else
                deltaClause = ' LastModifiedDate >= :LastSynchTime AND isDeleted = true ';
        }
        
        Id idGrpProfile;
        idGrpProfile = clsUtility.getGroupProfileId(null, true);
        //Device Specific setting
        string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);
        system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);
        String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, LastModifiedDate, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
        
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(idGrpProfile, strDeviceType); 
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed for RequestIncrementaldataFromBase = '+strMobConfQuery);
         
        for(SVMXC__ServiceMax_Config_Data__c objConfigData : Database.Query(strMobConfQuery))
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
                dtMovingDate = LastSynchTime + intValue + 1;
            }
            if(objConfigData.LastModifiedDate > LastSynchTime && inputRequest.eventName == 'GET_UPDATE')
            {
                deltaClause = '';//do not apply lastsync in query
            }
        }
        FromDate = Date.valueOf(dtFromDate);
        ToDate = Date.valueOf(dtToDate);
        system.debug(LoggingLevel.WARN,'dtFromDate = ' + dtFromDate + '; dtToDate = ' + dtToDate + '; Moving Date = ' + dtMovingDate);
        
        masterResponse.add(new INTF_WebServicesDef.SVMXMap('LAST_SYNC', String.valueOf(currentTime)));
        
        String incEventQuery, strSVMXEventSOQL;
        string set012 = getsettingIPAD018SET012();
        
        /************Service Power - Drip Feed***************/
        Boolean isDripFeed = false;
        String strListObjandFields = '';
        String strUserId = UserInfo.getUserId();
        Set<Id> setIdsToRemove = new Set<Id>();
        Set<Id> setEventIdsToRemove = new Set<Id>();
        Map<Id, List<Id>> mapEventIdToWhatId = new Map<Id, List<Id>>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<String> lstSettingId = new list<String>{'SET001','SET002'};
        map<String, String> mapSettForDispatch = new map<String, String>();
        mapSettForDispatch = commSettings.SVMX_getSettingList('DCON002', lstSettingId);
        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettForDispatch);
        if(mapSettForDispatch.containskey('SET001') && mapSettForDispatch.get('SET001') != null && mapSettForDispatch.get('SET001').length() > 0)
        {
            isDripFeed = Boolean.valueOf(mapSettForDispatch.get('SET001'));
        }
        if(mapSettForDispatch.containskey('SET002') && mapSettForDispatch.get('SET002') != null && mapSettForDispatch.get('SET002').length() > 0)
        {
            strListObjandFields = String.valueOf(mapSettForDispatch.get('SET002'));
        }
        system.debug(LoggingLevel.WARN, 'isDripFeed = ' + isDripFeed + '; List of Objects configured = ' + strListObjandFields);
        
        if(isDripFeed)
        {
            mapEventIdToWhatId = getDripFeedRelatedRecords(dtToDate, dtFromDate, strUserId, strListObjandFields);
            setIdsToRemove.addAll(mapEventIdToWhatId.keySet());
            for(Id eachId : mapEventIdToWhatId.keySet())
                setEventIdsToRemove.addAll(mapEventIdToWhatId.get(eachId));
        }
        /***************************/
        
        if(inputRequest.eventName == 'GET_INSERT' || inputRequest.eventName == 'GET_UPDATE') 
        {
            if(deltaClause != null && deltaClause != '' && deltaClause.length() > 0)
            {
                incEventQuery = 'Select Id, WhatId from Event where (OwnerId = ' + '\'' + Userinfo.getUserId() + '\'' + ' AND ((' + deltaClause + ' and ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate))) OR ((StartDateTime >= :dtMovingDate AND StartDateTime <= :dtToDate) OR (EndDateTime >= :dtMovingDate AND EndDateTime <= :dtToDate))) and Id NOT IN :setEventIdsToRemove)';
                strSVMXEventSOQL = 'SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) AND ' + deltaClause + ') OR ((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate))) AND SVMXC__Technician__r.SVMXC__Salesforce_User__c = ' + '\'' + Userinfo.getUserId() + '\'' +' AND Id NOT IN :setEventIdsToRemove)';
            }
            else
            {
                incEventQuery = 'Select Id, WhatId from Event where (OwnerId = ' + '\'' + Userinfo.getUserId() + '\'' + ' AND (((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) OR ((StartDateTime >= :dtMovingDate AND StartDateTime <= :dtToDate) OR (EndDateTime >= :dtMovingDate AND EndDateTime <= :dtToDate))) and Id NOT IN :setEventIdsToRemove)';
                strSVMXEventSOQL = 'SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = ' + '\'' + Userinfo.getUserId() + '\'' + ' and Id NOT IN :setEventIdsToRemove)';
            }
            
            if(set012 != null)
            {
                incEventQuery += ' ' + set012;
                strSVMXEventSOQL += ' ' + set012;
            }
        }
        else if(inputRequest.eventName == 'GET_DELETE') 
        {
            incEventQuery = 'Select Id, WhatId from Event where (OwnerId = ' + '\'' + Userinfo.getUserId() + '\'' + ' and ' + deltaClause +' and ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and Id NOT IN :setEventIdsToRemove)';
            strSVMXEventSOQL = 'SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = ' + '\'' + Userinfo.getUserId() + '\'' + ' and ' + deltaClause + ' AND Id NOT IN :setEventIdsToRemove)';
            
            if(set012 != null)
            {
                incEventQuery += ' ' + set012;
                strSVMXEventSOQL += ' ' + set012;
            }
            incEventQuery += ' ALL ROWS';
            strSVMXEventSOQL += ' ALL ROWS';
        }
        
        system.debug(loggingLevel.WARN, 'Query Prepared to query SF Events: ' + incEventQuery);
        system.debug(loggingLevel.WARN, 'Query Prepared to query SVMX Events: ' + strSVMXEventSOQL);
        
        set<Id> setEventIds = new set<Id>();
        Map<id, Event> incEvents = new Map<id, Event>();
        Map<id, SVMXC__SVMX_Event__c> mapSVMXEventIdToEvent = new Map<id, SVMXC__SVMX_Event__c>();
        
        for(Event ev : Database.query(incEventQuery))
        {
            incEvents.put(ev.Id, ev);
            if(ev.WhatId != null && inputRequest.eventName != 'GET_DELETE')
                setEventIds.add(ev.WhatId);
        }
        for(SVMXC__SVMX_Event__c ev : Database.query(strSVMXEventSOQL))
        {
            mapSVMXEventIdToEvent.put(ev.Id, ev);
            if(ev.SVMXC__WhatId__c != null && inputRequest.eventName != 'GET_DELETE')
                setEventIds.add(ev.SVMXC__WhatId__c);
        }
        
        system.debug(loggingLevel.WARN, 'Queried SF Events: ' + incEvents);
        system.debug(loggingLevel.WARN, 'Queried SVMX Events: ' + mapSVMXEventIdToEvent);
        
        List<Task> incTasks = new List<Task>();
        if(inputRequest.eventName == 'GET_INSERT' || inputRequest.eventName == 'GET_UPDATE') 
        {
            if(deltaClause != null && deltaClause != '' && deltaClause.length() > 0)
                incTasks  =  Database.query('Select Id from Task where OwnerId= ' + '\'' + Userinfo.getUserId() + '\'' + ' and '+deltaClause + ' and (ActivityDate <= : ToDate And ActivityDate >= :FromDate ) ');
            else
                incTasks  =  Database.query('Select Id from Task where OwnerId= ' + '\'' + Userinfo.getUserId() + '\'' + ' and (ActivityDate <= : ToDate And ActivityDate >= :FromDate ) ');
        }
        else if(inputRequest.eventName == 'GET_DELETE')
        {
            incTasks  =  Database.query('Select Id from Task where OwnerId= ' + '\'' + Userinfo.getUserId() + '\'' + ' and '+deltaClause + 
            ' and (ActivityDate <= : ToDate And ActivityDate >= :FromDate ) ' +' All ROWS');
        } 
        if(incTasks != null && incTasks.size() > 0)
        {
            INTF_WebServicesDef.SVMXMap taskWrap = new INTF_WebServicesDef.SVMXMap();
            taskWrap.key = 'Parent_Object';
            taskWrap.value = 'Task';
            multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
            
            INTF_WebServicesDef.SVMXMap masterTaskWrap = new INTF_WebServicesDef.SVMXMap();
            masterTaskWrap.key = 'Fields';
            masterTaskWrap.value = Json.serialize(incTasks);
            
            multiWrapList.add(masterTaskWrap);
            taskWrap.valueMap = multiWrapList;
            masterResponse.add(taskWrap); 
        }
        
        //create unique set of objects based on the processes.
        Set<String> setAllowedObjects = new Set<String>();
        INTF_GetServiceFlowAccess flowAccess = new INTF_GetServiceFlowAccess();
        Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = flowAccess.INTF_getAllAllowedProcessed(null);
        flowAccess.INTF_GetProcessObjects(allowedProcess);
        if(flowAccess.transactionalObjects != NULL && flowAccess.transactionalObjects.size() > 0)
            setAllowedObjects.addAll(flowAccess.transactionalObjects);
        if(flowAccess.lookupObjects != NULL && flowAccess.lookupObjects.size() > 0)
            setAllowedObjects.addAll(flowAccess.lookupObjects);
        INTF_WebServicesDef.SVMXMap EachObjDef = new INTF_WebServicesDef.SVMXMap();
        
        //get events based on the allowed objects
        List<Event> lstEvents = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstSVMXEvents = new List<SVMXC__SVMX_Event__c>();
        lstEvents = GetObjsTaggedToEvents(dtFromDate, dtToDate, setAllowedObjects, setEventIdsToRemove);
        
        if(set012 == null)
            set012 = '';
            
        lstSVMXEvents = Database.query('SELECT Id, SVMXC__WhatId__c FROM SVMXC__SVMX_Event__c WHERE (((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = ' + '\'' + Userinfo.getUserId() + '\'' + ' and Id NOT IN :setEventIdsToRemove) ' + set012);
        
        if(inputRequest.eventName == 'GET_UPDATE')
        {
            multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap allEvents = new INTF_WebServicesDef.SVMXMap('ALL_EVENTS', 'Event');
            multiWrapList.add(new INTF_WebServicesDef.SVMXMap('REC_IDS', Json.serialize(lstEvents)));
            allEvents.valueMap = multiWrapList;
            masterResponse.add(allEvents);
            
            multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap allSVMXEvents = new INTF_WebServicesDef.SVMXMap('ALL_SVMXEVENTS', 'SVMXC__SVMX_Event__c');
            multiWrapList.add(new INTF_WebServicesDef.SVMXMap('REC_IDS', Json.serialize(lstSVMXEvents)));
            allSVMXEvents.valueMap = multiWrapList;
            masterResponse.add(allSVMXEvents);
        }
        
        INTF_WebServicesDef.SVMXMap masterWrap = new INTF_WebServicesDef.SVMXMap();
        INTF_WebServicesDef.SVMXMap masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
        INTF_GetObjectDefinition clsObjectDef = new INTF_GetObjectDefinition();
        List<String> recordIDs = new List<String>();
        Map<String, INTF_WebServicesDef.SVMXMap> mapObjDefinitions = new Map<String, INTF_WebServicesDef.SVMXMap>();
        List<sObject> lstsObjects = new List<sObject>();
        if((lstEvents != null && lstEvents.size() > 0) || (lstSVMXEvents != null && lstSVMXEvents.size() > 0))
        {
            for (Event evt: lstEvents)
            {
                if (evt.What.Type != null)
                {
                    if(mapObjDefinitions.size() == 0 || (!mapObjDefinitions.containsKey(evt.What.Type)))
                    {
                        clsObjectDef.objectName = evt.What.Type;
                        EachObjDef = clsObjectDef.INTF_GetMasterChildDefinition();
                        mapObjDefinitions.put(evt.What.Type, EachObjDef);
                    }
                    recordIDs.add(evt.WhatID);
                }
            }
            for (SVMXC__SVMX_Event__c evt: lstSVMXEvents)
            {
                if(evt.SVMXC__WhatId__c != null && evt.SVMXC__WhatId__c != '' && Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType() != null)
                {
                    if(mapObjDefinitions.size() == 0 || (!mapObjDefinitions.containsKey(String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType()))))
                    {
                        clsObjectDef.objectName = String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType());
                        EachObjDef = clsObjectDef.INTF_GetMasterChildDefinition();
                        mapObjDefinitions.put(String.valueOf(Id.valueOf(evt.SVMXC__WhatId__c).getsObjectType()), EachObjDef);
                    }
                    recordIDs.Add(evt.SVMXC__WhatId__c);
                }   
            }
            for(String objName: mapObjDefinitions.keySet())
            {
                if (recordIDs.size() > 0 || incEvents.size() > 0)
                {
                    List<INTF_WebServicesDef.SVMXMap> objProps = new List<INTF_WebServicesDef.SVMXMap>();
                    objProps = mapObjDefinitions.get(objName).valueMap;
                    for(INTF_WebServicesDef.SVMXMap objProp : objProps)
                    {
                        if(objProp.key=='OBJECTPROPERTY')
                        {
                            for(INTF_WebServicesDef.SVMXMap eachMasterDetail : objProp.valueMap)
                            {
                                for(INTF_WebServicesDef.SVMXMap masterDetail : eachMasterDetail.valueMap)
                                {
                                    if(masterdetail.key=='MASTERDETAILS')
                                    {
                                        for(INTF_WebServicesDef.SVMXMap lstChild: masterdetail.valueMap)
                                        {
                                            if(setAllowedObjects.contains(lstChild.key))
                                            {
                                                String childQuery;
                                                if(inputRequest.eventName == 'GET_DELETE')
                                                    //childQuery = 'SELECT Id from '+ lstChild.key + ' WHERE LastModifiedDate >= :LastSynchTime and isDeleted = true All Rows ';
                                                    childQuery = 'SELECT Id from '+ lstChild.key + ' WHERE ' + lstChild.Value + ' IN :recordIDs and LastModifiedDate >= :LastSynchTime and isDeleted = true All Rows ';
                                                else if(inputRequest.eventName == 'GET_INSERT')
                                                {
                                                    if(setEventIds !=  null && setEventIds.size() > 0)
                                                        childQuery = 'SELECT Id from '+ lstChild.key + ' WHERE ' + lstChild.Value + ' in : setEventIds OR (' + lstChild.Value + ' IN :recordIDs AND CreatedDate >= :LastSynchTime) ';
                                                    else
                                                        childQuery = 'SELECT Id from '+ lstChild.key + ' WHERE ' + lstChild.Value + ' IN :recordIDs AND CreatedDate >= :LastSynchTime ';
                                                }
                                                else if(inputRequest.eventName == 'GET_UPDATE')
                                                {
                                                    if(setEventIds !=  null && setEventIds.size() > 0)
                                                        childQuery = 'SELECT Id from '+ lstChild.key + ' WHERE ' + lstChild.Value + ' in : setEventIds OR (' + lstChild.Value + ' IN :recordIDs AND LastModifiedDate >= :LastSynchTime) ';
                                                    else
                                                        childQuery = 'SELECT Id from '+ lstChild.key + ' WHERE ' + lstChild.Value + ' IN :recordIDs AND LastModifiedDate >= :LastSynchTime ';
                                                }
                                                system.debug('Child Query: ' + childQuery);
                                                
                                                List<SObject> qryChildResult = Database.query(childQuery);
                                                if( qryChildResult!=null && qryChildResult.size() > 0 )
                                                {
                                                    masterWrap = new INTF_WebServicesDef.SVMXMap();
                                                    masterWrap.key = 'Child_Object';
                                                    masterWrap.value = lstChild.key;
                                                    
                                                    multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                                                    masterFieldWrap = new INTF_WebServicesDef.SVMXMap();    
                                                    masterFieldWrap.key = 'Fields';
                                                    masterFieldWrap.value = Json.serialize(qryChildResult);
                                                    
                                                    multiWrapList.add(masterFieldWrap); 
                                                    masterWrap.valueMap = multiWrapList;    
                                                    masterResponse.add(masterWrap);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    String strQuery;
                    if(inputRequest.eventName == 'GET_DELETE')
                        strQuery = 'SELECT Id FROM ' + objName + ' WHERE LastModifiedDate >= :LastSynchTime and isDeleted = true All Rows ';
                    else if(inputRequest.eventName == 'GET_INSERT')
                    {
                        if(setEventIds !=  null && setEventIds.size() > 0)
                            strQuery = 'SELECT Id FROM ' + objName + ' WHERE (Id IN :recordIDs AND CreatedDate >= :LastSynchTime) OR (Id IN : setEventIds) ';
                        else
                            strQuery = 'SELECT Id FROM ' + objName + ' WHERE (Id IN :recordIDs AND CreatedDate >= :LastSynchTime) ';
                    }
                    else if(inputRequest.eventName == 'GET_UPDATE')
                    {
                        if(setEventIds !=  null && setEventIds.size() > 0)
                            strQuery = 'SELECT Id FROM ' + objName + ' WHERE (Id IN :recordIDs AND LastModifiedDate >= :LastSynchTime) OR (Id IN : setEventIds) ';
                        else
                            strQuery = 'SELECT Id FROM ' + objName + ' WHERE (Id IN :recordIDs AND LastModifiedDate >= :LastSynchTime) ';
                    }
                        
                    List<SObject> qryResult = Database.query(strQuery);
                    lstsObjects.addAll(qryResult);
                    if (qryResult != null && qryResult.size() > 0)
                    {
                        masterWrap = new INTF_WebServicesDef.SVMXMap();
                        masterWrap.key = 'Parent_Object';
                        masterWrap.value = objName;
                        multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
                        
                        masterFieldWrap = new INTF_WebServicesDef.SVMXMap();
                        masterFieldWrap.key = 'Fields';
                        masterFieldWrap.value = Json.serialize(qryResult);
                        multiWrapList.add(masterFieldWrap);
                        
                        masterWrap.valueMap = multiWrapList;
                        masterResponse.add(masterWrap);
                    }
                }
            }
            /***********/
            for(Event eachEvent : [select Id, WhatId from Event where whatId IN:lstsObjects and Id NOT IN:incEvents.keySet()])
            {
                incEvents.put(eachEvent.Id, eachEvent);
            }
            system.debug(LoggingLevel.Warn, 'All Events which are modified and whose Whatids are modified = ' + incEvents);
            /***********/
        }
        /***********/
        if (incEvents != null && incEvents.size() > 0)
        {
            INTF_WebServicesDef.SVMXMap eventWrap = new INTF_WebServicesDef.SVMXMap();
            eventWrap.key = 'Parent_Object';
            eventWrap.value = 'Event';
            multiWrapList = new List<INTF_WebServicesDef.SVMXMap>();
            INTF_WebServicesDef.SVMXMap masterEventWrap = new INTF_WebServicesDef.SVMXMap();
            masterEventWrap.key = 'Fields';
            masterEventWrap.value = Json.serialize(incEvents.values());
            
            multiWrapList.add(masterEventWrap);
            eventWrap.valueMap = multiWrapList;
            masterResponse.add(eventWrap);
        }
        if(mapSVMXEventIdToEvent != null && mapSVMXEventIdToEvent.size() > 0 )
        {
            masterResponse.add(new INTF_WebServicesDef.SVMXMap('SVMXC__SVMX_Event__c', JSON.serialize(mapSVMXEventIdToEvent.values())));
        }
        /***********/
        response.valueMap = masterResponse;
        
        if(response.success == null)
            response.success = true; 
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse RequestIdCleanUp(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        dateTime dt = system.now().addHours(-6);
        if(inputRequest.eventName == 'CLEAN_UP')
        {
            try
            {
                string strSyncSOQL = 'Select Id from SVMXC__Sync_Request__c ';
                string strSyncReqId = inputRequest.value;
                if(strSyncReqId != null && strSyncReqId.length() > 0)
                    strSyncSOQL += 'where SVMXC__Client_Request_Id__c = :strSyncReqId OR LastModifiedDate <=: dt';
                else
                    strSyncSOQL += 'where LastModifiedDate <=: dt';
                
                integer limitNoOfRecords = Limits.getLimitDMLRows() - Limits.getDMLRows() - 500;
                system.debug(loggingLevel.WARN, 'DML Row Limit: ' + Limits.getLimitDMLRows() + ' :Remaining DML Rows: ' + Limits.getDMLRows() + ' :Limit for query: ' + limitNoOfRecords);
                if(limitNoOfRecords > 0)
                {
                    strSyncSOQL += ' limit :limitNoOfRecords';
                    system.debug(loggingLevel.WARN, 'Query Prepared: ' + strSyncSOQL);
                    List<SVMXC__Sync_Request__c> lstSyncRequest = database.query(strSyncSOQL);
                    //if(lstSyncRequest != null && lstSyncRequest.size() > 0)
                        //Database.Deleteresult [] deleteResult = Database.delete(lstSyncRequest, false);
                        
                    integer remainingLimitNoOfRecords = Limits.getLimitDMLRows() - Limits.getDMLRows() - 100;
                    if(remainingLimitNoOfRecords!= null && remainingLimitNoOfRecords > 0)
                    {
                        integer noOfDays = 30;
                        INTF_ConfigSync confSync = new INTF_ConfigSync();
                        string svmxGrpProfileId = confSync.getSVMXGrpProfileId(userinfo.getProfileId());
                        List<SVMXC__ServiceMax_Config_Data__c> lstSettings = confSync.getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET015'}, svmxGrpProfileId);
                        if(lstSettings != null && lstSettings.size() > 0){
                            for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings)
                                noOfDays = integer.valueOf(cnf.SVMXC__Internal_Value__c);
                        }
                        noOfDays = -noOfDays;
                        dateTime dtToDelete = system.now().addDays(noOfDays);
                        string strSVMXJobLogQuery = 'Select Id from SVMXC__SVMX_Job_Logs__c where (SVMXC__Type__c = \'iPad\' OR SVMXC__Type__c = \'iPhone\') AND LastModifiedDate <=: dtToDelete limit: remainingLimitNoOfRecords';
                        List<SVMXC__SVMX_Job_Logs__c> lstSVMXJobLogs = database.query(strSVMXJobLogQuery);
                        //if(lstSVMXJobLogs != null && lstSVMXJobLogs.size() > 0)
                            //Database.Deleteresult [] deleteResult = Database.delete(lstSVMXJobLogs, false);
                    }
                }
            }
            catch(DMLException e)
            {
                String errorMessage = e.getMessage();
            }   
        }
        else if(inputRequest.eventName == 'CLEAN_UP_SELECT')
        {
            List<SVMXC__Sync_Request_Records__c> sync_req_rec = [Select id from SVMXC__Sync_Request_Records__c where SVMXC__Sync_Request__r.SVMXC__Client_Request_Id__c = : inputRequest.value and SVMXC__Operation_Type__c = 'Select'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            System.debug(LoggingLevel.WARN,'sync_req_rec'+sync_req_rec);
            if(sync_req_rec.size() > 0 && sync_req_rec != null)
            {
                try
                {
                    List<Database.Deleteresult> delResult = Database.delete(sync_req_rec); 
                    
                }
                catch(DMLException e)
                {
                    String errorMessage = e.getMessage();
                }
            }
        }
        response.eventName = inputRequest.eventName;
        return response;
    }
    
    // SFMSearch for iPad
    public INTF_WebServicesDef.INTF_SFMResponse getSearchResults(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        try
        {
            INTF_WebServicesDef.INTF_Response INTFResponse = new INTF_WebServicesDef.INTF_Response();
            SFM_SearchUtils searchObj = new SFM_SearchUtils();
            INTFResponse = searchObj.INTF_getSearchInfoExcludeGivenIDs(inputRequest);
            system.debug(LoggingLevel.WARN, 'INTFResponse==' + INTFResponse);
            List<INTF_WebServicesDef.SVMXMap> lst = new List<INTF_WebServicesDef.SVMXMap>();
            for(INTF_WebServicesDef.INTF_MapStringMap mapStrmapObj : INTFResponse.MapStringMap)
            {
                INTF_WebServicesDef.SVMXMap Obj = new INTF_WebServicesDef.SVMXMap();
                List<INTF_WebServicesDef.SVMXMap> lstSVMXMapObj = new List<INTF_WebServicesDef.SVMXMap>();
                for(INTF_WebServicesDef.INTF_StringMap valueMapObj : mapStrmapObj.valueMap)
                {
                    INTF_WebServicesDef.SVMXMap svmxMapObj = new INTF_WebServicesDef.SVMXMap();
                    svmxMapObj.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                    svmxMapObj.key = valueMapObj.key;
                    svmxMapObj.value = valueMapObj.value;
                    if(valueMapObj.value1 != null)
                        svmxMapObj.valueMap.add(new INTF_WebServicesDef.SVMXMap('Reference',valueMapObj.value1));
                    lstSVMXMapObj.add(svmxMapObj);
                }
                Obj.key = mapStrmapObj.key;
                Obj.value = mapStrmapObj.id;
                Obj.valueMap = lstSVMXMapObj;
                lst.add(Obj);
            }
            response.valueMap = lst;
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        system.debug('response=='+response);
        return response;
    }
    
    // Added this method by Shashank on 24th April for Purging event
    public INTF_WebServicesDef.INTF_SFMResponse purgeEvents(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        Map<String, String> mapObjKey = new Map<String, String>();
        allObjs = Schema.getGlobalDescribe();
        for(Schema.SObjectType sObj:allObjs.values())
        { 
            mapObjKey.put(sObj.getDescribe().getKeyPrefix(), sObj.getDescribe().getName());
        }

        // Get all records from the request i.e. in inputRequest.values
        List<String> lstOfRecords = new List<String>();
        lstOfRecords.addAll(inputRequest.values);

        // Put records in a map based on the object key prefix
        // Ex:- a0a is for SVMXC__ServiceMax_Processes__c so records id's with a0a will go into this object
        Set<String> setKeyPrefix  = new Set<String>();
        setKeyPrefix = mapObjKey.keySet();// contains all objects

        Map<String, List<String>> mapObjNameRec = new Map<String, List<String>>();// map of Object and list of All ID's
        for(Integer i=0; i<lstOfRecords.size(); i++)
        {
            String rec = lstOfRecords[i];
            for(String key:setKeyPrefix)
            {
                if(key != null)
                {
                    if(rec.startsWith(key))
                    {
                        if(mapObjNameRec.containsKey(mapObjKey.get(key)))
                        {   
                            mapObjNameRec.get(mapObjKey.get(key)).add(rec);
                        }   
                        else
                        {
                            List<String> lstRec = new List<String>();
                            lstRec.add(rec);
                            mapObjNameRec.put(mapObjKey.get(key),lstRec);
                        }   
                    }
                }
            }
        }
        //Get Device Type
        String strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);
        // Now we have a map<ObjName, List of Rec id's so get where clause for each object in this map
        Map<String, String> mapObjDefinitions = new Map<String, String>();
        Map<String, String> mapObjQuery = new Map<String, String>();// fill ths map in this for loop
        INTF_GetObjectDefinition clsObjectDef = new INTF_GetObjectDefinition();
        for(INTF_WebServicesDef.SVMXMap eachprocessObj : getDownloadCriteriaObjects(strDeviceType))
        {
            clsObjectDef.objectName = eachprocessObj.key;
            INTF_WebServicesDef.SVMXMap objDef = clsObjectDef.INTF_GetObjectDefinition();
            if(objDef != NULL)
            {
                INTF_WebServicesDef.SVMXMap tmpObj = new INTF_WebServicesDef.SVMXMap();
                mapObjDefinitions.put(objdef.value, eachprocessObj.value);
            }
        }
        
        List<String> lstAllRecIds = new List<String>();
        for(String ObjName : mapObjNameRec.keySet())
        {
            String strQuery = null;
            lstAllRecIds = mapObjNameRec.get(ObjName);
            string lstIDs = '(';
            for(string str: lstAllRecIds)
            {
                if(lstIDs != '(')
                    lstIDs += ',';
                lstIDs += '\'' + str + '\'';
            }
            lstIDs += ')';
            if (mapObjDefinitions.get(ObjName) != NULL && mapObjDefinitions.get(ObjName) != '')
            {
                strQuery =  '  SELECT Id FROM '+ ObjName +' WHERE ' + mapObjDefinitions.get(ObjName) + ' AND Id IN '+ lstIDs;
            }
            mapObjQuery.put(ObjName,strQuery);
        }

        // Now we have a map<ObjName, query with where clause and ID in clause> so get the matching records with this clause.
        List<Sobject> lstSObject = new List<Sobject>();
        Set<Id> setAllMatchedID = new Set<Id>();
        Map<String,List<String>> mapObjId = new Map<String, List<String>>();
        Boolean match = true;
        for(String Objname : mapObjNameRec.keySet())
        {
            if(mapObjQuery.get(objName) != null)
            {
                lstSObject = database.query(mapObjQuery.get(objName));
                for(SObject sObj : lstSObject)
                {
                    setAllMatchedID.add(sObj.Id);
                } 
                for(String recordId: mapObjNameRec.get(objName))
                {
                    if(setAllMatchedID != NULL && setAllMatchedID.contains(recordId))
                    {
                       // Records are matching the download criteria, please dont delete
                    }
                    else
                    {
                        if(mapObjId.containsKey(Objname))
                        {
                            mapObjId.get(Objname).add(recordId);
                        }
                        else
                        {
                            List<String> lstRecID = new List<String>();
                            lstRecID.add(recordId);
                            mapObjId.put(Objname,lstRecID);
                        }
                    }
                }
            }
        }
        // Iterate mapObjId and frame it in INTF_SFMResponse
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.SVMXMap> lstObj = new List<INTF_WebServicesDef.SVMXMap>();

        for(String Objname : mapObjId.keySet())
        {
            if(mapObjId.get(Objname) != NULL)
                lstObj.add(new INTF_WebServicesDef.SVMXMap(Objname, NULL, mapObjId.get(Objname)));
        }
        response.valueMap = lstObj;
        return response;
    }   
    
    public INTF_WebServicesDef.INTF_SFMResponse getRecordsForPurging(INTF_WebServicesDef.INTF_SFMRequest inputRequest, String grpProfileId)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        map<String, List<String>> mapObjNameToIds = new map<String, List<String>>();
        Integer intLimit = 10000;
        Datetime dtToDate, dtFromDate;
        Datetime currentTime = Datetime.now();
        String strUserId = UserInfo.getUserId();
        Set<String> setWhatIds = new Set<String>();
        
        List<SVMXC__ServiceMax_Config_Data__c> lst = (new INTF_ConfigSync()).getSettings(null, null, new set<string>{'IPAD018_SET006'}, grpProfileId);
        if(lst != null && lst.size() != 0 && lst.size() == 1)
            intLimit = Integer.valueOf(lst[0].SVMXC__Internal_Value__c);
        
        string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);
        system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);
        String strMobConfQuery  = 'select Id, SVMXC__Display_Type__c, SVMXC__Internal_value__c, SVMXC__Object_Name__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR SVMXC__Display_Type__c = \'Synchronization To Remove Events\' OR SVMXC__Display_Type__c = \'Download Criteria\' OR SVMXC__Display_Type__c = \'Advanced Download Criteria\')';
         
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed for getRecordsForPurging = '+strMobConfQuery);
        
        for(SVMXC__ServiceMax_Config_Data__c objConfigData: Database.Query(strMobConfQuery))
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
            }
        }
            
        for(Event evt :[Select What.Id, What.Type from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId and WhatId != null])
            setWhatIds.add(evt.What.Id);

        for(SVMXC__SVMX_Event__c evt :[Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
            setWhatIds.add(evt.SVMXC__WhatId__c);
                    
        for(INTF_WebServicesDef.SVMXMap eachObjMap: inputRequest.valueMap)
        {
            system.debug(LoggingLevel.WARN, 'Each Object VM in request = ' + eachObjMap);
            if(eachObjMap.key == 'Object_Name' && eachObjMap.value != null && eachObjMap.value != '')
            {
                Boolean isDCObjectNoCriteria = false;
                Set<String> setIds = new Set<String>();
                List<sObject> lstQryResult = new List<sObject>();
                String strFinalCriteria = '', strFinalQry = '', strObjName = eachObjMap.value;
                setIds.addAll(eachObjMap.values);
                
                //Device specific setting
                strMobConfQuery = 'select Id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Display_Type__c, SVMXC__Internal_value__c, SVMXC__Ownership_Type__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId AND (SVMXC__Display_Type__c = \'Download Criteria\' OR SVMXC__Display_Type__c = \'Advanced Download Criteria\') AND SVMXC__Object_Name__c != null AND SVMXC__Object_Name__c =: strObjName';
                
                if(strDevConfId != NULL && strDevConfId != ''){
                    strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                }
                system.debug(LoggingLevel.WARN,'Second Query formed for getRecordsForPurging = '+strMobConfQuery);
        
                for(SVMXC__ServiceMax_Config_Data__c objConfigData: Database.Query(strMobConfQuery))
                {
                    String strCriteria = '';
                    system.debug(LoggingLevel.WARN, 'Each Mobile Config record = ' + objConfigData);
                    if(objConfigData.SVMXC__Display_Type__c == 'Download Criteria')
                    {
                        if(objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null)
                            strCriteria = '(' + objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c;
    
                        if(objConfigData.SVMXC__Ownership_Type__c == 'My Records')
                        {
                            if(strCriteria != '')
                                strCriteria = ' ( ' + strCriteria + ' ) and ';
                            else
                                strCriteria += '(';
                            strCriteria += 'OwnerId = \'' + UserInfo.getUserId() + '\' ';
                        }
                        if(strCriteria != '')
                            strCriteria += ')';
        
                        strCriteria = strCriteria.replace('SVMX.CURRENTUSERID15', UserInfo.getUserId().substring(0,15));
                        strCriteria = strCriteria.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());    
                        strCriteria = strCriteria.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
                        //strCriteria = strCriteria.replace('SVMX.USERTRUNK', strCurrTechLocId);
                        system.debug(LoggingLevel.WARN, 'UserInfo.getUserId() = ' + UserInfo.getUserId());
                        Map<String, String> mapSFCSToValue = (new INTF_DataUtilityServices()).replaceLiteralWithValue(strCriteria);
            
                        for(String eachLiteral : mapSFCSToValue.keySet())
                        {
                            system.debug(LoggingLevel.WARN, 'Literal Key = ' + eachLiteral + '; Value = ' + mapSFCSToValue.get(eachLiteral));
                            strCriteria = strCriteria.replace(eachLiteral, mapSFCSToValue.get(eachLiteral));
                        }
            
                        system.debug(LoggingLevel.WARN, 'Final DC Criteria = ' + strCriteria);
                        if(strCriteria == '' && strCriteria.length() <= 0)
                        {
                            isDCObjectNoCriteria = true;
                            break;
                        }
                    }
                    if(objConfigData.SVMXC__Display_Type__c == 'Advanced Download Criteria')
                    {
                        if(objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                        {
                            strCriteria = '((' + objConfigData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                            for(SVMXC__ServiceMax_Config_Data__c eachDCExpr : [select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c =: objConfigData.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC])
                            {
                                String strObjNameAndField = '';
                                if((eachDCExpr.SVMXC__Display_Type__c == 'REFERENCE' || eachDCExpr.SVMXC__Display_Type__c == 'ID') && eachDCExpr.SVMXC__Object_Name2__c != null)
                                {
                                    String strReferenceFieldIds = '';
                                    strObjNameAndField += '\':' + eachDCExpr.SVMXC__Object_Name2__c + '\',\'' + eachDCExpr.SVMXC__Source_Field_Name__c + '\'';
                                    for(sobject sObj : Database.query('Select LastModifiedDate, ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds'))
                                    {
                                        if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null)
                                        {
                                            if(strReferenceFieldIds != '')
                                            strReferenceFieldIds += ',';
                                            strReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';
                                        }
                                    }
                                    if(strReferenceFieldIds == '')
                                        strReferenceFieldIds = '\'DummyListOfIds1\'';
                            
                                    strCriteria = strCriteria.replace(strObjNameAndField, strReferenceFieldIds);
                                    system.debug(LoggingLevel.WARN, 'strCriteria = ' + strCriteria);
                                }
                                else
                                {
                                    //criteria exists in variable strCriteria.
                                }
                            }
                        }
                        else
                        {
                            strCriteria = '';
                        }
                        if(objConfigData.SVMXC__Ownership_Type__c == 'My Records')
                        {
                            if(strCriteria != '')
                                strCriteria = ' ( ' + strCriteria + ' ) and ';
                            else
                                strCriteria += '(';
                
                            strCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
                        }
                        strCriteria += ') ';    
                        system.debug(LoggingLevel.WARN, 'Final ADC Criteria = ' + strCriteria);
                    }
        
                    if(strFinalCriteria != '' && strCriteria != '')
                        strFinalCriteria += ' OR ';
                    strFinalCriteria += strCriteria;
                    system.debug(LoggingLevel.WARN, 'Final Criteria = ' + strCriteria);            
                }
                if(isDCObjectNoCriteria)
                    strFinalQry = 'Select Id from ' + strObjName + ' where ID IN:setIds Order By Id limit ' + intLimit; 
                else if(strFinalCriteria != '')
                    strFinalQry = 'Select Id from ' + strObjName + ' where (' + strFinalCriteria + ') ' + ' AND ID IN:setIds Order By Id limit ' + intLimit;
                 
                system.debug(LoggingLevel.WARN, 'Final Query = ' + strFinalQry);
                 
                if(strFinalQry != null && strFinalQry != '' && strFinalQry.length() > 0)
                {
                    lstQryResult = Database.query(strFinalQry);
                    for(sObject sobj : lstQryResult)
                        setIds.remove(sobj.Id);
                }
                
                intLimit -= lstQryResult.size();
                List<String> lstIds = new List<String>();
                lstIds.addAll(setIds);
                response.valueMap.add(new INTF_WebServicesDef.SVMXMap('Object_Name', strObjName, lstIds));
                
                if(intLimit <= 0)
                {
                    response.valueMap.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', strObjName, new List<String>{lstQryResult[lstQryResult.size() - 1].Id}));
                    break;
                }
                system.debug(LoggingLevel.WARN, 'setIds = ' + setIds.size() + '; setIds = ' + setIds);
            }
        }
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse updateTechLocation(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<SVMXC__Service_Group_Members__c> technician = new List<SVMXC__Service_Group_Members__c>();
        Sync_Utility clsUtility = new Sync_Utility();
        Id grpProfileId = clsUtility.getGroupProfileId(null, false);
        if(grpProfileId != null)
        {
            string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);
            system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);
            String strMobConfQuery  = 'select id, SVMXC__Internal_Value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c = \'Set Technician Location\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';
            
            String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            strMobConfQuery += ' LIMIT 1';
            system.debug(LoggingLevel.WARN,'Query formed for updateTechLocation = '+strMobConfQuery);
            
            
            List<SVMXC__ServiceMax_Config_Data__c> lstGrpProfileData = Database.Query(strMobConfQuery);
            if(lstGrpProfileData != null && lstGrpProfileData.size() == 1 && lstGrpProfileData[0].SVMXC__Internal_Value__c == 'true')
            {
                technician = [Select Id, SVMXC__Latlong_Captured_On__c, SVMXC__Latitude__c, SVMXC__Longitude__c,  Name from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1];
                if(technician != null && technician.size() > 0)
                {
                    for(INTF_WebServicesDef.SVMXMap fieldMap : inputRequest.valueMap)
                    {
                        if(fieldMap.key == 'Fields')
                        {
                            for(INTF_WebServicesDef.SVMXMap eachField : fieldMap.valueMap)
                            {
                                if(eachField.key == 'SVMXC__Latitude__c')
                                    technician[0].SVMXC__Latitude__c = Decimal.valueOf(eachField.value);
                                else if(eachField.key == 'SVMXC__Longitude__c')
                                    technician[0].SVMXC__Longitude__c = Decimal.valueOf(eachField.value); 
                            }
                        }
                    }
                    try
                    {
                        if(inputRequest.values !=NULL && !inputRequest.values.isEmpty() && inputRequest.values[0] !=NULL)
                        {
                            technician[0].SVMXC__Latlong_Captured_On__c = Datetime.valueOfGMT(inputRequest.values[0]);
                        }                     
                        update(technician[0]);
                        response.success = true;
                        response.message = String.valueOf(technician[0].Id);
                    }
                    catch(Exception e)
                    {
                        response.success = false;
                        response.message = e.getMessage();                        
                        system.debug('update failed' + e.getMessage());
                    }
                }
            }
            else
            {
                response.message = 'Set latest location is FALSE or no data for this profile';
            }
        } 
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        return response;
    }
        
    //6th June 2012 - to insert Location History records received from iPad client to Location History Object
    public INTF_WebServicesDef.INTF_SFMResponse updateTechLocHistory(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.SVMXMap> lstIdtoSendInResponse = new List<INTF_WebServicesDef.SVMXMap>();
        List<String> lstLocalId = new List<String>();
        if(inputRequest.eventType == 'SYNC' && inputRequest.eventName == 'LOCATION_HISTORY')
        {
            List<SVMXC__User_GPS_Log__c> lstGPSRec = new List<SVMXC__User_GPS_Log__c>();
            SVMXC__User_GPS_Log__c objGPSLog;
            for(INTF_WebServicesDef.SVMXMap eachRecord : inputRequest.valueMap)
            {
                if(eachRecord.key == 'Record')
                {
                    objGPSLog = new SVMXC__User_GPS_Log__c();
                    for(INTF_WebServicesDef.SVMXMap eachField : eachRecord.valueMap)
                    {
                        system.debug(LoggingLevel.WARN, 'eachField.key:'+ eachField.key + ', eachField.value:'+eachField.value);
                        if(eachField.key == 'localId')
                            lstLocalId.add(eachField.value);
                        else if(eachField.key == 'SVMXC__Latitude__c')
                        {
                            if(eachField.value != null && eachField.value.length() > 0) 
                                objGPSLog.SVMXC__Latitude__c = Decimal.valueOf(eachField.value);
                        }
                        else if(eachField.key == 'SVMXC__Longitude__c')
                        {
                            if(eachField.value != null && eachField.value.length() > 0)
                                objGPSLog.SVMXC__Longitude__c = Decimal.valueOf(eachField.value);
                        }   
                        else if(eachField.key == 'SVMXC__Status__c')
                            objGPSLog.SVMXC__Status__c = eachField.value;
                        else if(eachField.key == 'SVMXC__User__c')
                        {
                            if(eachField.value != null && eachField.value.length() > 0) 
                                objGPSLog.SVMXC__User__c = eachField.value;
                            else
                                objGPSLog.SVMXC__User__c = UserInfo.getUserId();
                        }
                        else if(eachField.key == 'SVMXC__Device_Type__c')
                            objGPSLog.SVMXC__Device_Type__c = eachField.value;
                        else if(eachField.key == 'SVMXC__Additional_Info__c')
                            objGPSLog.SVMXC__Additional_Info__c = eachField.value;
                        else if(eachField.key == 'SVMXC__Time_Recorded__c')
                            objGPSLog.SVMXC__Time_Recorded__c = Datetime.valueOfGMT(eachField.value);
                    }
                    lstGPSRec.add(objGPSLog);
                }
            }
            if(lstGPSRec!= null && lstGPSRec.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap obj;
                try
                {
                    Database.Saveresult[] insertResult = Database.insert(lstGPSRec, false);
                    Integer i = 0;
                    for(Database.Saveresult res : insertResult)
                    {
                        obj = new INTF_WebServicesDef.SVMXMap();
                        if(res.isSuccess())
                        {
                            obj.key = lstLocalid[i];
                            obj.value = res.getId();
                        }
                        else
                        {
                            obj.key = lstLocalid[i];
                            //obj.value = res.getId();
                            obj.value = 'Insert Failed for this record';
                        }
                        i++;
                        lstIdtoSendInResponse.add(obj);
                    }
                }
                catch(Exception e)
                {
                    INTF_WebServicesDef.SVMXMap errObj = new INTF_WebServicesDef.SVMXMap();
                    errObj.value = e.getMessage();
                    lstIdtoSendInResponse.add(errObj);
                }
            }
        }
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        response.valueMap = lstIdtoSendInResponse;
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMRequest prepareRequestForAttachment(INTF_WebServicesDef.SVMXMap inputRequest){
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        List<String> lstObjIds = new List<String>();
        for(INTF_WebServicesDef.SVMXMap eachObject : inputRequest.valueMap){
            if(eachObject.key == 'Id' && !String.isBlank(eachObject.value)){
                lstObjIds.add(eachObject.value);
            }
        }
        SVMXC.INTF_WebServicesDef.SVMXMap inputValueMap = new SVMXC.INTF_WebServicesDef.SVMXMap('TX_OBJECT', inputRequest.value , lstObjIds);
        request.valueMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>{inputValueMap};
        request.EventName = 'DATA_ON_DEMAND';
        return request;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse downloadOnDemand(INTF_WebServicesDef.INTF_SFMRequest inputRequest, string svmxGrpProfileId)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.SVMXMap eachObjResponse;
        INTF_GetObjectDefinition clsObjectDefinition;
        Integer intLimitRelationshipFields = 35;
        List<INTF_WebServicesDef.SVMXMap> lstEachRecord = new List<INTF_WebServicesDef.SVMXMap>();
        set<String> setRefObjToSkip = new set<String>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<String> lstSettingId = new list<String>{'SET004', 'SET013', 'SET009'};
        map<String, String> mapSettingsForIPAD018 = new map<String, String>();
        mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
        Boolean isGetPriceEnabled = false;
        if(mapSettingsForIPAD018.containskey('SET009') && mapSettingsForIPAD018.get('SET009') != null)
                isGetPriceEnabled = Boolean.valueOf(mapSettingsForIPAD018.get('SET009'));
            else
                isGetPriceEnabled = false;      
        if(mapSettingsForIPAD018.containskey('SET004') && mapSettingsForIPAD018.get('SET004') != null)
        {
            String strValue = mapSettingsForIPAD018.get('SET004');
            list<String> lstValue = new list<String>();
            lstValue = strValue.split(',');
            if(lstValue.size() > 0)
            {
                for(Integer i = 0; i < lstValue.size(); i++)
                    setRefObjToSkip.add(lstValue[i].toUpperCase());
            }
        }
        else
        {
            setRefObjToSkip.add('PARTNERNETWORKCONNECTION');
            setRefObjToSkip.add('USER');
            setRefObjToSkip.add('FEEDPOST');
            setRefObjToSkip.add('SOLUTION');
        }
        
        if(mapSettingsForIPAD018.containskey('SET013') && mapSettingsForIPAD018.get('SET013') != null)
            intLimitRelationshipFields = integer.valueOf(mapSettingsForIPAD018.get('SET013'));
        else
            intLimitRelationshipFields = 35;
            
        if(inputRequest.eventName == 'DATA_ON_DEMAND' && inputRequest.eventType == 'GET_DATA')
        {
            system.debug(LoggingLevel.WARN, 'inputRequest.valueMap '+ inputRequest.valueMap);
            for(INTF_WebServicesDef.SVMXMap eachObject : inputRequest.valueMap)
            {
                String strObjName = null, idParentRec = null, strFieldNames = null, strParentRefField = null;
                eachObjResponse = new INTF_WebServicesDef.SVMXMap();
                List<INTF_WebServicesDef.SVMXMap> lstRecords = new List<INTF_WebServicesDef.SVMXMap>();
                clsObjectDefinition = new INTF_GetObjectDefinition();
                if(eachObject.key == 'Object_Name' && eachObject.value != null && eachObject.value.length() > 0)
                {
                    strObjName = eachObject.value;
                    clsObjectDefinition.objectName = strObjName;
                    try
                    {
                        INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition(); 
                        List<String> lstFieldNames = new List<String>();
                        if (objDef != NULL) 
                        {
                            for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                            {
                                if (objProp.key=='FIELDPROPERTY')
                                {
                                   Integer refFieldCount = 0; 
                                   for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                                   {
                                        lstFieldNames.add(lstField.value);
                                        if(refFieldCount == intLimitRelationshipFields)
                                            continue;
                                        List<INTF_WebServicesDef.SVMXMap> fldProps = new List<INTF_WebServicesDef.SVMXMap>();
                                        fldProps = lstField.valueMap;
                                        String reference_to = GetValueForKeyInSVMXMapList('REFERENCETO', fldProps);
                                        if (reference_to != null)
                                        {
                                            String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', fldProps);
                                            if (reference_to == 'Case')
                                            {
                                                lstFieldNames.add(relationship_name + '.CaseNumber');
                                                refFieldCount++;
                                            }
                                            else if (setRefObjToSkip.contains(reference_to.toUpperCase()) || relationship_name == null)
                                                continue;
                                            else
                                            {
                                                lstFieldNames.add(relationship_name + '.Name');
                                                refFieldCount++;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        for(INTF_WebServicesDef.SVMXMap ObjDetails : eachObject.valueMap)
                        {
                            if(ObjDetails.key == 'Id')
                            {
                                idParentRec = ObjDetails.value;
                            }
                            else if(ObjDetails.key == 'Fields')
                            {
                                //strFieldNames = ObjDetails.value;
                            }
                            else if(ObjDetails.key == 'Parent_Reference_Field')
                            {
                                strParentRefField = ObjDetails.value;
                            }
                        }
                        lstFieldNames = (new COMM_Utils_V2()).checkDuplicateFields(lstFieldNames, strObjName); //Remove duplicate API Fields
                        strFieldNames =  clsObjectDefinition.getObjectFieldNames(lstFieldNames);
                        //system.debug(LoggingLevel.WARN, ' Field Names = '+ strFieldNames);
                        if(strObjName != null && strObjName.length() > 0 && strFieldNames != null && strFieldNames.length() > 0)
                        {
                            INTF_WebServicesDef.SVMXMap objEachRecord;
                            if((strParentRefField == null || strParentRefField.length() <= 0) && (idParentRec != null && idParentRec.length() > 0))
                            {
                                //query for Parent  objects
                                for(sObject sobj : Database.query('Select ' + strFieldNames + ' FROM '+ strObjName + ' WHERE Id = :idParentRec'))
                                {
                                    objEachRecord = new INTF_WebServicesDef.SVMXMap();
                                    objEachRecord.key = 'Parent_Record';
                                    objEachRecord.value = JSON.serialize(sobj);
                                    lstRecords.add(objEachRecord);
                                }
                            }
                            else if((strParentRefField != null && strParentRefField.length() > 0) && (idParentRec != null && idParentRec.length() > 0))
                            {
                                //query for Child objects
                                for(sObject sobj : Database.query('Select ' + strFieldNames + ' FROM '+ strObjName + ' WHERE ' + strParentRefField + ' = : idParentRec'))
                                {
                                    objEachRecord = new INTF_WebServicesDef.SVMXMap();
                                    objEachRecord.key = 'Child_Record';
                                    objEachRecord.value = JSON.serialize(sobj);
                                    lstRecords.add(objEachRecord);
                                }
                            }
                            //system.debug(LoggingLevel.WARN, 'Response after each Parent/Child object '+objEachRecord);
                        }
                    }
                    catch(exception ex)
                    {
                        system.debug(LoggingLevel.WARN, 'Error occurred during describe or querying' + ex.getMessage());
                    }
                }
                eachObjResponse.key = 'Object_Name';
                eachObjResponse.value = strObjName;
                eachObjResponse.valueMap.addAll(lstRecords);
                 //Get Device specific setting
                string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);
                system.debug(LoggingLevel.WARN,' Device from Request for DownloadOnDemand = '+strDeviceType);
                String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(svmxGrpProfileId, strDeviceType);
        
                                        
                if(strObjName == 'SVMXC__Service_Order__c' && isGetPriceEnabled)
                    eachObjResponse.valueMap.add(getSingleWOPricingDefinition(idParentRec, setRefObjToSkip, intLimitRelationshipFields, svmxGrpProfileId, strDevConfId));
                
                if(strObjName == 'SVMXC__Installed_Product__c' || strObjName == 'SVMXC__Site__c'){
                    INTF_WebServicesDef.INTF_SFMResponse innerResponse = (new INTF_TxnCache()).getAttachments(prepareRequestForAttachment(eachObject), svmxGrpProfileId);
                    INTF_WebServicesDef.SVMXMap attachmentResponse = new INTF_WebServicesDef.SVMXMap('Attachment','SVMXC__Installed_Product__c');
                    attachmentResponse.valueMap.addAll(innerResponse.valueMap);
                    eachObjResponse.valueMap.add(attachmentResponse);
                    system.debug(LoggingLevel.WARN, 'Inside IP/Site - attachmentResponse '+attachmentResponse);
                    
                    INTF_WebServicesDef.INTF_SFMResponse innerFileResponse = (new INTF_SFDCFilesUtilityServices()).getProductIQFiles(prepareRequestForAttachment(eachObject), svmxGrpProfileId);
                    INTF_WebServicesDef.SVMXMap filesResponse = new INTF_WebServicesDef.SVMXMap('Files',eachObject.value);
                    filesResponse.valueMap.addAll(innerFileResponse.valueMap);
                    eachObjResponse.valueMap.add(filesResponse);
                    system.debug(LoggingLevel.WARN, 'Inside IP/Site - FilesResponse '+filesResponse);
                }
                
                lstEachRecord.add(eachObjResponse);
                system.debug(LoggingLevel.WARN, 'Response after each object '+eachObjResponse);
            }
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        response.valueMap = lstEachRecord;
        return response;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getWOPriceInfo(INTF_WebServicesDef.INTF_SFMRequest req, String svmxGrpProfileId)
    {
        system.debug(loggingLevel.WARN, 'Request for one Work Order: ' + req);
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        res.eventName = req.eventName;
        res.eventType = req.eventType;
        string IDWorkOrder = '';
        string objName = '';
        Integer intLimitRelationshipFields = 35;
        set<String> setRefObjToSkip = new set<String>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<String> lstSettingId = new list<String>{'SET004', 'SET013'};
        map<String, String> mapSettingsForIPAD018 = new map<String, String>();
        mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
        if(mapSettingsForIPAD018.containskey('SET004') && mapSettingsForIPAD018.get('SET004') != null)
        {
            String strValue = mapSettingsForIPAD018.get('SET004');
            list<String> lstValue = new list<String>();
            lstValue = strValue.split(',');
            if(lstValue.size() > 0)
            {
                for(Integer i = 0; i < lstValue.size(); i++)
                    setRefObjToSkip.add(lstValue[i].toUpperCase());
            }
        }
        else
        {
            setRefObjToSkip.add('PARTNERNETWORKCONNECTION');
            setRefObjToSkip.add('USER');
            setRefObjToSkip.add('FEEDPOST');
            setRefObjToSkip.add('SOLUTION');
        }
        
        if(mapSettingsForIPAD018.containskey('SET013') && mapSettingsForIPAD018.get('SET013') != null)
            intLimitRelationshipFields = integer.valueOf(mapSettingsForIPAD018.get('SET013'));
        else
            intLimitRelationshipFields = 35;
            
        for(INTF_WebServicesDef.SVMXMap eachObject : req.valueMap)
        {
            if(eachObject.key == 'Object_Name')
            {
                objName = eachObject.value;
                for(INTF_WebServicesDef.SVMXMap eachId : eachObject.valueMap)
                {
                    if(eachId.key == 'Id')
                    {
                        system.debug(LoggingLevel.WARN,'Value for Id: ' + eachId.value);
                        IDWorkOrder = eachId.value;
                    }
                }
            }
        }
        
        system.debug(LoggingLevel.WARN,'Work Order Id: ' + IDWorkOrder);
        //Get Device specific setting
        string strDeviceType = (new INTF_ConfigSync()).getDeviceName(req);
        system.debug(LoggingLevel.WARN,' Device from Request for getWOPriceInfo = '+strDeviceType);
        String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(svmxGrpProfileId, strDeviceType);        
        res.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        if(objName == 'SVMXC__Service_Order__c' && IDWorkOrder != null)
        {
            system.debug(LoggingLevel.WARN,'Making the call: ' + IDWorkOrder + ' And: ' + setRefObjToSkip);
            res.valueMap.add(getSingleWOPricingDefinition(IDWorkOrder, setRefObjToSkip, intLimitRelationshipFields, svmxGrpProfileId, strDevConfId));
        }
        
        return res;
    }
    
    public INTF_WebServicesDef.SVMXMap getSingleWOPricingDefinition(ID IDWorkOrder, Set<String> setRefObjToSkip, Integer intLimitRelationshipFields, String svmxGrpProfileId, String strDevConfId)
    {
        system.debug(LoggingLevel.WARN, 'In getSingleWOPricingDefinition Start Queries executed = ' + Limits.getQueries());
        INTF_WebServicesDef.SVMXMap MasterWrapper = new INTF_WebServicesDef.SVMXMap();
        MasterWrapper.key = 'PRICING_DATA';
        Map<String, String> mapErrorMessage = new Map<String, String>();
        try
        {
            ID idWO = IDWorkOrder;
            Boolean isModified = false;
            Boolean isCallBack = false;
            Integer intResponseSize = 0;
            String strWhrClause = '', strCurrency = '', strFieldNames = '';
            Set<String> setProductIds = new Set<String>();
            Set<ID> setPricebooks = new Set<ID>();
            Set<ID> entitlementIds = new Set<ID>();
            Set<ID> setWarrantyIds = new Set<ID>();
            Set<ID> setSCIds = new Set<ID>();
            Set<String> setCurrencyISOCodes = new Set<String>();
            List<String> lstCurrencyISOCodes = new List<String>();
            List<INTF_WebServicesDef.SVMXMap> lstWrpData= new List<INTF_WebServicesDef.SVMXMap>();
            List<INTF_WebServicesDef.SVMXMap> lstPricingDetails = new List<INTF_WebServicesDef.SVMXMap>();
            List<INTF_WebServicesDef.SVMXMap> lstPBData = new List<INTF_WebServicesDef.SVMXMap>();
            COMM_Utils_V2 commUtil2 = new COMM_Utils_V2();
            
            INTF_GetObjectDefinition clsObjectDefinition = new INTF_GetObjectDefinition();
            Map<String, List<String>> mapObjectFields = new map<String, List<String>>();
            Set<String> setAllObjectNames = new Set<String>{'SVMXC__Entitlement_History__c', 'SVMXC__Warranty__c', 'SVMXC__Service_Contract__c', 'SVMXC__Pricing_Rule__c', 'SVMXC__Parts_Pricing__c', 'SVMXC__Parts_Discount__c', 'SVMXC__Labor_Pricing__c', 'SVMXC__Expense_Pricing__c', 'SVMXC__Travel_Policy__c', 'SVMXC__Mileage_Tiers__c', 'SVMXC__Zone_Pricing__c', 'SVMXC__Service_Contract_Services__c', 'SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c', 'Pricebook2', 'PricebookEntry', 'SVMXC__Service_Pricebook__c', 'SVMXC__Service_Pricebook_Entry__c', 'SVMXC__Custom_Coverage__c'};
            for(String strObj : setAllObjectNames)
            {
                clsObjectDefinition.objectName = strObj;
                INTF_WebServicesDef.SVMXMap objDef = clsObjectDefinition.INTF_GetObjectDefinition();
                List<String> lstFieldNames = new List<String>();
                if (objDef != NULL) 
                {
                    for(INTF_WebServicesDef.SVMXMap objProp : objdef.valueMap)
                    {
                        if (objProp.key=='FIELDPROPERTY')
                        {
                           Integer refFieldCount = 0; 
                           for(INTF_WebServicesDef.SVMXMap lstField: objProp.valueMap)
                           {
                                lstFieldNames.add(lstField.value);
                                if(refFieldCount == intLimitRelationshipFields)
                                    continue;
                                List<INTF_WebServicesDef.SVMXMap> fldProps = new List<INTF_WebServicesDef.SVMXMap>();
                                fldProps = lstField.valueMap;
                                String strRefTo = GetValueForKeyInSVMXMapList('REFERENCETO', fldProps);
                                if (strRefTo != null)
                                {
                                    String relationship_name = GetValueForKeyInSVMXMapList('RELATIONSHIPNAME', fldProps);
                                    if (strRefTo == 'Case')
                                    {
                                        lstFieldNames.add(relationship_name + '.CaseNumber');
                                        refFieldCount++;
                                    }
                                    else if (setRefObjToSkip.contains(strRefTo.toUpperCase()) || relationship_name == null)
                                        continue;
                                    else
                                    {
                                        lstFieldNames.add(relationship_name + '.Name');
                                        refFieldCount++;
                                    }
                                }
                            }
                        }
                    }
                }
                if(!mapObjectFields.containsKey(strObj))
                    mapObjectFields.put(strObj, lstFieldNames);
            }
            
            String workOrderQuery = 'Select Id, SVMXC__Product__c ';
            String workDetailQuery = 'Select Id, SVMXC__Product__c,RecordType.Name ';
            
            set<string> lstWDLineIds = new set<string>();
            if(UserInfo.isMultiCurrencyOrganization())
            {
                    workOrderQuery = workOrderQuery+', CurrencyIsoCode from SVMXC__Service_Order__c  where Id =: idWO';
                    workDetailQuery = workDetailQuery+', CurrencyIsoCode from SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c =: idWO';          
            }else{
                    workOrderQuery = workOrderQuery+' from SVMXC__Service_Order__c  where Id =: idWO';
                    workDetailQuery = workDetailQuery+' from SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c =: idWO'; 
            }
            
            for(SVMXC__Service_Order__c eachRec : database.query(workOrderQuery))
            {
                    if(Userinfo.isMultiCurrencyOrganization())
                    {
                        setCurrencyISOCodes.add(String.valueOf(eachRec.get('CurrencyIsoCode')));
                    }
                    setProductIds.add(eachRec.SVMXC__Product__c);
            }
            
            for(SVMXC__Service_Order_Line__c eachRec : database.query(workDetailQuery))
            {
                    if(Userinfo.isMultiCurrencyOrganization() && eachRec.RecordType.Name == 'Products Serviced')
                    {
                        setCurrencyISOCodes.add(String.valueOf(eachRec.get('CurrencyIsoCode')));
                    }
                    lstWDLineIds.add(String.valueOf(eachRec.get('Id')));
                    setProductIds.add(eachRec.SVMXC__Product__c); 
            }
            
            lstCurrencyISOCodes.addAll(setCurrencyISOCodes);
            if(lstCurrencyISOCodes != null && lstCurrencyISOCodes.size() > 0)
                    strCurrency = lstCurrencyISOCodes[0];
                    
            String strCurrClause = '';
            // Get the following pricing information only for the work order currency code, else get all pricing information for the contract
            if(UserInfo.isMultiCurrencyOrganization())
                strCurrClause = ' AND ( CurrencyIsoCode =:strCurrency OR CurrencyIsoCode IN :setCurrencyISOCodes ) ';
            system.debug(LoggingLevel.WARN, 'strCurrClause = ' + strCurrClause);
            
            mapObjectFields.put('SVMXC__Entitlement_History__c',commUtil2.checkDuplicateFields(mapObjectFields.get('SVMXC__Entitlement_History__c'), 'SVMXC__Entitlement_History__c'));//Remove duplicate API Fields
            strFieldNames =  clsObjectDefinition.getObjectFieldNames(mapObjectFields.get('SVMXC__Entitlement_History__c'));
            INTF_WebServicesDef.SVMXMap EH = new INTF_WebServicesDef.SVMXMap();
            EH.key = 'SVMXC__Entitlement_History__c';
            List<INTF_WebServicesDef.SVMXMap> lstEH = new List<INTF_WebServicesDef.SVMXMap>();
            for(SVMXC__Entitlement_History__c eachRec : database.query('select ' + strFieldNames + ' from SVMXC__Entitlement_History__c  where (SVMXC__Service_Order__c =: idWO OR SVMXC__Work_Detail__c IN: lstWDLineIds) and SVMXC__Inactive_Date__c = NULL '))
            {
                lstEH.add(new INTF_WebServicesDef.SVMXMap('', JSON.serialize(eachRec)));
                if(eachRec.SVMXC__Warranty__c != null)
                    setWarrantyIds.add(eachRec.SVMXC__Warranty__c);
                if(eachRec.SVMXC__Service_Contract__c != null)
                    setSCIds.add(eachRec.SVMXC__Service_Contract__c);
            }
            EH.valueMap = lstEH;
            lstWrpData.add(EH);
            
            /*****Get Price 2.0 (Location based Get Price) ******/
            for(SVMXC__Service_Order_Line__c eachWOLine : [Select Id, SVMXC__Product_Warranty__c from SVMXC__Service_Order_Line__c where RecordType.Name = 'Products Serviced' and SVMXC__Product_Warranty__c != null and SVMXC__Service_Order__c =:idWO])
            {
                if(!setWarrantyIds.contains(eachWOLine.SVMXC__Product_Warranty__c))
                    setWarrantyIds.add(eachWOLine.SVMXC__Product_Warranty__c);
            }
            
            /***********/
            mapObjectFields.put('SVMXC__Warranty__c', commUtil2.checkDuplicateFields(mapObjectFields.get('SVMXC__Warranty__c'), 'SVMXC__Warranty__c'));//Remove duplicate API Fields
            strFieldNames =  clsObjectDefinition.getObjectFieldNames(mapObjectFields.get('SVMXC__Warranty__c'));
            INTF_WebServicesDef.SVMXMap warranty = new INTF_WebServicesDef.SVMXMap();
            warranty.key = 'SVMXC__Warranty__c';
            List<INTF_WebServicesDef.SVMXMap> lstWarranty = new List<INTF_WebServicesDef.SVMXMap>();
            for(SVMXC__Warranty__c eachRec : database.query('select ' + strFieldNames + ' from SVMXC__Warranty__c  where Id IN: setWarrantyIds'))
                lstWarranty.add(new INTF_WebServicesDef.SVMXMap('', JSON.serialize(eachRec)));
            warranty.valueMap = lstWarranty;
            lstWrpData.add(warranty);
            
            mapObjectFields.put('SVMXC__Service_Contract__c',commUtil2.checkDuplicateFields(mapObjectFields.get('SVMXC__Service_Contract__c'), 'SVMXC__Service_Contract__c'));//Remove duplicate API Fields
            strFieldNames =  clsObjectDefinition.getObjectFieldNames(mapObjectFields.get('SVMXC__Service_Contract__c'));
            INTF_WebServicesDef.SVMXMap SC = new INTF_WebServicesDef.SVMXMap();
            SC.key = 'SVMXC__Service_Contract__c';
            List<INTF_WebServicesDef.SVMXMap> lstSC = new List<INTF_WebServicesDef.SVMXMap>();
            for(SVMXC__Service_Contract__c eachRec : database.query('select ' + strFieldNames + ' from SVMXC__Service_Contract__c  where Id IN: setSCIds'))
                lstSC.add(new INTF_WebServicesDef.SVMXMap('', JSON.serialize(eachRec)));
            SC.valueMap = lstSC;
            lstWrpData.add(SC); 
            
            Set<String> setObjectNames = new Set<String>{'SVMXC__Pricing_Rule__c', 'SVMXC__Parts_Pricing__c', 'SVMXC__Parts_Discount__c', 'SVMXC__Labor_Pricing__c', 'SVMXC__Expense_Pricing__c', 'SVMXC__Travel_Policy__c', 'SVMXC__Mileage_Tiers__c', 'SVMXC__Zone_Pricing__c', 'SVMXC__Service_Contract_Services__c', 'SVMXC__Custom_Coverage__c'};
            system.debug(LoggingLevel.WARN, 'SC Ids = ' + setSCIds);
            if(setSCIds != null && setSCIds.size() > 0)
            {
                List<INTF_WebServicesDef.SVMXMap> eachObjValueMap = new List<INTF_WebServicesDef.SVMXMap>();
                for(String strObjName : setObjectNames)
                {
                    if(strObjName == 'SVMXC__Pricing_Rule__c' || strObjName == 'SVMXC__Travel_Policy__c')
                    {
                        Set<Id> setExpressionIds = new Set<Id>();
                        for(SVMXC__Pricing_Rule__c objExpr : [Select Id, SVMXC__Named_Expression__c from SVMXC__Pricing_Rule__c where SVMXC__Named_Expression__c != null])
                            setExpressionIds.add(objExpr.SVMXC__Named_Expression__c);
                            
                        for(SVMXC__Travel_Policy__c objExpr : [Select Id, SVMXC__Named_Expression__c from SVMXC__Travel_Policy__c where SVMXC__Named_Expression__c != null])
                            setExpressionIds.add(objExpr.SVMXC__Named_Expression__c);
                            
                        INTF_WebServicesDef.SVMXMap wrpHdrExpressions = new INTF_WebServicesDef.SVMXMap();
                        wrpHdrExpressions.key = 'SVMXC__ServiceMax_Processes__c';
                        strFieldNames =  clsObjectDefinition.getObjectFieldNames(mapObjectFields.get('SVMXC__ServiceMax_Processes__c'));
                        for(SVMXC__ServiceMax_Processes__c objExpr : Database.query('Select ' + strFieldNames + ' from SVMXC__ServiceMax_Processes__c where id in: setExpressionIds and RecordType.Name = \'SVMX RULE\''))
                            wrpHdrExpressions.valueMap.add(new INTF_WebServicesDef.SVMXMap('', JSON.serialize(objExpr)));
                            
                        lstPricingDetails.add(wrpHdrExpressions);
                        
                        INTF_WebServicesDef.SVMXMap wrpDtlExpressions = new INTF_WebServicesDef.SVMXMap();
                        wrpDtlExpressions.key = 'SVMXC__ServiceMax_Config_Data__c';
                        strFieldNames =  clsObjectDefinition.getObjectFieldNames(mapObjectFields.get('SVMXC__ServiceMax_Config_Data__c'));
                        for(SVMXC__ServiceMax_Config_Data__c objExpr : Database.query('Select ' + strFieldNames + ' from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c in: setExpressionIds and RecordType.Name = \'EXPRESSIONS\''))
                            wrpDtlExpressions.valueMap.add(new INTF_WebServicesDef.SVMXMap('', JSON.serialize(objExpr)));
                            
                        lstPricingDetails.add(wrpDtlExpressions);
                    }
                    mapObjectFields.put(strObjName,commUtil2.checkDuplicateFields(mapObjectFields.get(strObjName), strObjName));//Remove duplicate API Fields
                        strFieldNames =  clsObjectDefinition.getObjectFieldNames(mapObjectFields.get(strObjName));
                    INTF_WebServicesDef.SVMXMap wrpPricing = new INTF_WebServicesDef.SVMXMap();
                    wrpPricing.key = strObjName;
                    for(Sobject eachRec : Database.query('Select ' + strFieldNames + ' from ' + strObjName + ' where SVMXC__Service_Contract__c IN :setSCIds ' + strCurrClause ))
                    {
                        INTF_WebServicesDef.SVMXMap wrpRecord = new INTF_WebServicesDef.SVMXMap();
                        wrpRecord.value = JSON.serialize(eachRec);
                        wrpPricing.valueMap.add(wrpRecord);
                    }
                    lstPricingDetails.add(wrpPricing);
                }
            }
            
            list<String> lstLabor = new list<String>{'Calibration', 'Repair', 'Installation', 'CleanUp', 'Service'};
            //setProductIds = getProductIds(isModified, null, strDevConfId);
            
            Set<String> setPricebookNames = new Set<String>();
            if(setWarrantyIds != null && setWarrantyIds.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c eachPriceBookFromSetting : (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'WORD005_SET004', 'WORD005_SET006', 'WORD005_SET008', 'WORD005_SET017', 'WORD005_SET018'}, svmxGrpProfileId))
                {
                    if(eachPriceBookFromSetting.SVMXC__Internal_Value__c != null && eachPriceBookFromSetting.SVMXC__Internal_Value__c != '')
                        setPricebookNames.add(eachPriceBookFromSetting.SVMXC__Internal_Value__c);   
                }
            }
            
            for(SVMXC__Service_Contract__c scObjs : database.query('SELECT Id, Name, SVMXC__Default_Parts_Price_Book__c, SVMXC__Service_Pricebook__c FROM SVMXC__Service_Contract__c WHERE ID IN :setSCIds'))
            {
                //include both the service and parts pricebooks into this set
                if(scObjs.SVMXC__Default_Parts_Price_Book__c != null)
                    setPricebooks.add(scObjs.SVMXC__Default_Parts_Price_Book__c);
                if(scObjs.SVMXC__Service_Pricebook__c != null)
                    setPricebooks.add(scObjs.SVMXC__Service_Pricebook__c);
            }
            
            system.debug(LoggingLevel.WARN, 'setPricebookNames = ' + setPricebookNames + '; setPricebooks = ' + setPricebooks);
            Set<String> setObjNames = new Set<String>{'Pricebook2', 'PricebookEntry', 'SVMXC__Service_Pricebook__c', 'SVMXC__Service_Pricebook_Entry__c'};
            for(String strObjName : setObjNames)
            {
                    mapObjectFields.put(strObjName,commUtil2.checkDuplicateFields(mapObjectFields.get(strObjName), strObjName));//Remove duplicate API Fields
                    strFieldNames =  clsObjectDefinition.getObjectFieldNames(mapObjectFields.get(strObjName));
                if(strObjName == 'Pricebook2')
                    strWhrClause = ' (ID IN :setPricebooks OR Name IN :setPricebookNames) AND IsActive = true ';
                else if(strObjName == 'PricebookEntry')
                    strWhrClause = ' Pricebook2.IsActive = true AND Product2Id IN:setProductIds AND IsActive = true AND (Pricebook2Id IN :setPricebooks OR Pricebook2.Name IN:setPricebookNames) ' + strCurrClause;
                else if(strObjName == 'SVMXC__Service_Pricebook__c')
                    strWhrClause = ' (ID IN :setPricebooks OR Name IN :setPricebookNames) AND SVMXC__Active__c = true ';
                else if(strObjName == 'SVMXC__Service_Pricebook_Entry__c')
                    strWhrClause = ' SVMXC__Activity_Type__c IN :lstLabor AND SVMXC__Price_Book__r.SVMXC__Active__c = true AND (SVMXC__Price_Book__c IN :setPricebooks OR SVMXC__Price_Book__r.Name IN :setPricebookNames) ' + strCurrClause;
    
                INTF_WebServicesDef.SVMXMap wrpPriceBook = new INTF_WebServicesDef.SVMXMap();
                wrpPriceBook.key = strObjName;
                List<INTF_WebServicesDef.SVMXMap> lstPriceBookData = new List<INTF_WebServicesDef.SVMXMap>();
                for(Sobject eachRec : database.query('SELECT ' + strFieldNames + ' FROM ' + strObjName + ' where ' + strWhrClause))
                {
                    INTF_WebServicesDef.SVMXMap wrpRecord = new INTF_WebServicesDef.SVMXMap();
                    wrpRecord.value = JSON.serialize(eachRec);
                    lstPriceBookData.add(wrpRecord);
                    intResponseSize += wrpRecord.value.length();
                    if (intResponseSize > 2500000 || Limits.getHeapSize() > 5500000)
                    {
                        isCallBack = true;
                        break;
                    }
                }
                wrpPriceBook.valueMap = lstPriceBookData;
                lstPBData.add(wrpPriceBook);
                setObjNames.remove(strObjName);
                if (intResponseSize > 2500000 || Limits.getHeapSize() > 5500000)
                {
                    isCallBack = true;
                    break;
                }
            }           
            MasterWrapper.valueMap.addAll(lstwrpData);
            MasterWrapper.valueMap.addAll(lstPricingDetails);
            MasterWrapper.valueMap.addAll(lstPBData);
            MasterWrapper.values.addAll(setObjNames);
        }
        catch(Exception e)
        {
            system.debug(LoggingLevel.WARN, 'Exception = ' + e.getStackTraceString() + '; Message = ' + e.getMessage());
        }
        system.debug(LoggingLevel.WARN, 'In getSingleWOPricingDefinition End Queries executed = ' + Limits.getQueries());
        return MasterWrapper;
    }
    
    
    public INTF_WebServicesDef.INTF_SFMResponse getPricingDefinitions(INTF_WebServicesDef.INTF_SFMRequest request)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getPricingDefinitions');        
        system.debug(LoggingLevel.WARN, 'In getPricingDefinitions Start Queries executed = ' + Limits.getQueries() + ', Records queried = ' + Limits.getQueryRows());
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.SVMXMap MasterWrapper = new INTF_WebServicesDef.SVMXMap();
        MasterWrapper.key = 'PRICING_DATA';
        try
        {
            Integer intLimit = 10000;
            Integer intLimitPercent = 70;
            Boolean isGetPriceEnabled = false;
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            List<String> lstSettingId = new list<String>{'SET009', 'SET006', 'SET011'};
            Map<String, String> mapSettingsForIPAD018 = new Map<String, String>();
            mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
            system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
            if(mapSettingsForIPAD018.containskey('SET009') && mapSettingsForIPAD018.get('SET009') != null)
                isGetPriceEnabled = Boolean.valueOf(mapSettingsForIPAD018.get('SET009'));
            else
                isGetPriceEnabled = false;
            
            if(mapSettingsForIPAD018 != null && mapSettingsForIPAD018.size() > 0 && mapSettingsForIPAD018.containskey('SET011') && mapSettingsForIPAD018.get('SET011') != null)
                intLimitPercent = integer.valueOf(mapSettingsForIPAD018.get('SET011'));
            else
                intLimitPercent = 70;
                
            if(mapSettingsForIPAD018 != null && mapSettingsForIPAD018.size() > 0 && mapSettingsForIPAD018.containskey('SET006') && mapSettingsForIPAD018.get('SET006') != null)
                intLimit = Integer.valueOf(mapSettingsForIPAD018.get('SET006'));
            else
                intLimit = 10000;   
                
            if(isGetPriceEnabled)
            {
                Integer intLastIndex = 0;
                Datetime dtLastSyncTime = null;
                Set<String> setWOIds = new Set<String>();
                Set<String> setWhatIds = new Set<String>();
                list<String> lstLabor = new list<String>();
                Set<String> setEventWOIds = new Set<String>();
                Set<String> setOldPriceBookIds = new Set<String>();
                Set<String> setCurrencyISOCodes = new Set<String>();
                List<String> lstCurrencyISOCodes = new List<String>();
                Set<String> setClientWOCurrencies = new Set<String>();
                Set<String> setOldServicePriceBookIds = new Set<String>();
                Set<String> entHistoryIDs = new Set<String>();
                 //Map<String, SVMXC__Service_Order__c> mapIdToWO = new Map<String, SVMXC__Service_Order__c>();
                Boolean isCallBack = false, isModified = false, isCallBackCompatible = false, isDCResponseType = false;
                String strCurrency = '', strTimeClause = '', strPartialExecObjName = '', strLastId = '', strLastIdClause = '', strLastIdForPartialExcObj = '';
                
                Id idGrpProfile = (new Sync_Utility()).getGroupProfileId(null, false);
                String strDeviceType = '';
                
                if(request.clientInfo != null && request.clientInfo.size() > 0)
                {
                    for(INTF_WebServicesDef.SVMXClient clientInform : request.clientInfo)
                    {
                        for(String strVersion : clientInform.clientInfo)
                        {
                            if(strVersion != null && strVersion.length() > 0 && strVersion.contains('appversion'))
                            {
                                isCallBackCompatible = true;
                            }
                        }
                        if(clientInform.clientType != null){
                            strDeviceType = clientInform.clientType;
                        }
                    }
                }
                
                //GET DEVICE SPECIFIC SETTING
                system.debug(LoggingLevel.WARN,' Device from Request getPricingDefinitions = '+strDeviceType);
                String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(idGrpProfile, strDeviceType);
                for(SVMXC.INTF_WebServicesDef.SVMXMap currentValMap : request.valueMap)
                {
                    if(currentValMap.key == 'LABOR' && currentValMap.values != null && currentValMap.values.size() > 0)
                    {
                        lstLabor.addAll(currentValMap.values);
                    }
                    else if(currentValMap.key == 'CALL_BACK' && currentValMap.value != null)
                    {
                        isCallBack = Boolean.valueOf(currentValMap.value);
                    }
                    else if(currentValMap.key == 'LAST_INDEX' && currentValMap.value != null)
                    {
                        intLastIndex = Integer.valueOf(currentValMap.value);
                    }
                    else if(currentValMap.key == 'LAST_SYNC_TIME' && currentValMap.value != null && currentValMap.value != '')
                    {
                        dtLastSyncTime = DateTime.valueOf(currentValMap.value);
                    }
                    else if(currentValMap.key == 'CurrencyISO')
                    {
                        if(currentValMap.values != null && currentValMap.values.size() > 0)
                            setClientWOCurrencies.addAll(currentValMap.values);
                    }
                    else if(currentValMap.key == 'PARTIAL_EXECUTED_OBJECT')
                    {
                        strPartialExecObjName = currentValMap.value;
                        if(currentValMap.values != null && currentValMap.values.size() > 0)
                        {
                            currentValMap.values.sort();
                            strLastIdForPartialExcObj = currentValMap.values[currentValMap.values.size() - 1];
                        }
                    }
                    else if(currentValMap.key == 'LAST_ID' && currentValMap.value != null && currentValMap.value != '')
                    {
                        strLastId = currentValMap.value;
                    }
                    else if(currentValMap.key == 'GET_PRICE_RESPONSE_TYPE' && currentValMap.value != null && currentValMap.value != '')
                    {
                        if(currentValMap.value == 'DOWNLOAD_CRITERIA_TYPE')
                        {
                            isDCResponseType =  true;
                        }
                    }
                    else if(currentValMap.key == 'PRICEBOOK_IDs')
                    {
                        if(currentValMap.values != null && currentValMap.values.size() > 0)
                            setOldPriceBookIds.addAll(currentValMap.values);
                    }
                    else if(currentValMap.key == 'SERVICE_PRICEBOOK_IDs')
                    {
                        if(currentValMap.values != null && currentValMap.values.size() > 0)
                            setOldServicePriceBookIds.addAll(currentValMap.values);
                    }
                    else if(currentValMap.key == 'ENT_HISTORY_IDs'){
                            if(currentValMap.values != null && currentValMap.values.size() > 0)
                            entHistoryIDs.addAll(currentValMap.values);
                    }
                }
                
                system.debug(LoggingLevel.WARN, 'Last Id = ' + strLastId + '; Response Type = ' + isDCResponseType + '; isCallBackCompatible = ' + isCallBackCompatible);
                
                if(strLastIdForPartialExcObj != null && strLastIdForPartialExcObj.length() > 0)
                    strLastIdClause = ' AND ID > :strLastIdForPartialExcObj ';
               
                List<INTF_WebServicesDef.SVMXMap> lstWrpData= new List<INTF_WebServicesDef.SVMXMap>();
                if(intLastIndex == 0)
                {
                    Set<ID> setSCIds = new Set<ID>();
                    Set<ID> entitlementIds = new Set<ID>();
                    Set<ID> setWarrantyIds = new Set<ID>();
                    Set<String> entitledWOIds = new Set<String>();
                    //Set<String> entitledWDLineIds = new Set<String>();
                    Set<String> setIsModifiedFlag = new Set<String>();
                    Map<String, SVMXC__Service_Order_Line__c> mapWDRelatedToAllWO = new Map<String, SVMXC__Service_Order_Line__c>();
                    Map<String, SVMXC__Service_Order_Line__c> mapWDRelatedToEventWO = new Map<String, SVMXC__Service_Order_Line__c>();
                    String entLastId = '', strEntLastIDClause = '';
                    List<String> lstEntitlementLastId = new List<String>();
                    
                    Integer intResponseSize = 0;
                    String strMdfdEvents = '';
                    set<string> setWDIdsRelatedtoEventWO = new set<string>();
                    setWOIds.addAll(getWOIds(setIsModifiedFlag, dtLastSyncTime, setCurrencyISOCodes, strDevConfId));
                    system.debug(LoggingLevel.WARN, 'Mobile Configuration WO entry is modified ? ' + setIsModifiedFlag + ', Set of Currencies from WO: ' + setCurrencyISOCodes);
                    setWhatIds = getEventRelatedWOIDs(strDevConfId);
                    setWhatIds.addAll(getSVMXEventRelatedWOIDs(strDevConfId));
                    setWOIds.addAll(setWhatIds);
                    
                    if(dtLastSyncTime != null && !setIsModifiedFlag.contains('true'))
                    {
                        strTimeClause = ' AND LastModifiedDate >= :dtLastSyncTime ';
                        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, WhatId from Event where WhatId IN :setWhatIds AND LastModifiedDate >= :dtLastSyncTime');                        
                        for(Event ev : [Select Id, WhatId from Event where WhatId IN :setWhatIds AND LastModifiedDate >= :dtLastSyncTime])
                            setEventWOIds.add(ev.WhatId);
                            
                        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :setWhatIds AND LastModifiedDate >= :dtLastSyncTime');                                                
                        for(SVMXC__SVMX_Event__c ev : [Select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :setWhatIds AND LastModifiedDate >= :dtLastSyncTime])
                            setEventWOIds.add(ev.SVMXC__WhatId__c);
                            
                        INTF_DataSync.logSOQL(intMethodCount, 'select Id from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c IN: setEventWOIds AND RecordType.Name = \'Products Serviced\'');
                        mapWDRelatedToEventWO.putAll([select Id from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c IN: setEventWOIds AND RecordType.Name = 'Products Serviced']);
                        setWDIdsRelatedtoEventWO.addAll(mapWDRelatedToEventWO.keyset());
                        
                        strMdfdEvents = ' OR ((SVMXC__Service_Order__c IN :setEventWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoEventWO) and SVMXC__Inactive_Date__c = NULL) ';
                    }
                    
                    if(UserInfo.isMultiCurrencyOrganization())
                    {
                        INTF_DataSync.logSOQL(intMethodCount, 'select Id, CurrencyIsoCode from SVMXC__Service_Order__c  where Id IN: setWOIds');                                                
                        for(SVMXC__Service_Order__c eachRec : database.query('select Id, CurrencyIsoCode from SVMXC__Service_Order__c  where Id IN: setWOIds'))
                            setCurrencyISOCodes.add(String.valueOf(eachRec.get('CurrencyIsoCode')));
                        
                        INTF_DataSync.logSOQL(intMethodCount, 'select Id, CurrencyIsoCode from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c IN: setWhatIds AND RecordType.Name = \'Products Serviced\'');                         
                        for(SVMXC__Service_Order_Line__c eachRec : database.query('select Id, CurrencyIsoCode from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c IN: setWhatIds AND RecordType.Name = \'Products Serviced\''))
                            setCurrencyISOCodes.add(String.valueOf(eachRec.get('CurrencyIsoCode')));
                    }
                    
                    String strCurrClause = '';
                    if(UserInfo.isMultiCurrencyOrganization())
                        strCurrClause = ' AND (CurrencyIsoCode IN :setCurrencyISOCodes) ';
                    system.debug(LoggingLevel.WARN, 'Work Order Ids size = ' + setWOIds.size() + ', All WO CurrencyISO Codes = ' + setCurrencyISOCodes + '; strCurrClause = ' + strCurrClause);
                    
                    if(request.values != null && request.values.size() > 0)
                    {
                        system.debug(LoggingLevel.WARN, 'Request values = ' + request.values.size());
                        //setWOIds.retainAll(request.values);
                        entLastId = request.values[0];
                        strEntLastIDClause = ' AND ID >:entLastId ';
                    }
                                                                 
                    set<string> setWDIdsRelatedtoAllWO = new set<string>();
                    INTF_DataSync.logSOQL(intMethodCount, 'select Id from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c IN: setWhatIds AND RecordType.Name = \'Products Serviced\'');
                    for(SVMXC__Service_Order_Line__c WD : [select Id from SVMXC__Service_Order_Line__c where SVMXC__Service_Order__c IN: setWhatIds AND RecordType.Name = 'Products Serviced'])
                        setWDIdsRelatedtoAllWO.add(WD.Id);
                        
                    /*INTF_DataSync.logSOQL(intMethodCount,'select Id, SVMXC__Service_Order__c, SVMXC__Work_Detail__c, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Entitlement_History__c  where ((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoAllWO) AND SVMXC__Inactive_Date__c = NULL ' + strTimeClause + ') ' + strMdfdEvents);                                                               
                    for(SVMXC__Entitlement_History__c eachRec : database.query('select Id, SVMXC__Service_Order__c, SVMXC__Work_Detail__c, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Entitlement_History__c  where ((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoAllWO) AND SVMXC__Inactive_Date__c = NULL ' + strTimeClause + ') OR ((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoAllWO) AND (SVMXC__Warranty__r.LastModifiedDate >=:dtLastSyncTime OR SVMXC__Service_Contract__r.LastModifiedDate >=:dtLastSyncTime) AND SVMXC__Inactive_Date__c = NULL) ' + strMdfdEvents))
                    {
                        if(eachRec.SVMXC__Service_Order__c != null)
                            entitledWOIds.add(eachRec.SVMXC__Service_Order__c);
                        if(eachRec.SVMXC__Work_Detail__c != null)
                            entitledWDLineIds.add(eachRec.SVMXC__Work_Detail__c);
                    }
                    setWOIDs.retainAll(entitledWOIds);
                    Integer intQryLimit = Limits.getLimitQueryRows() - Limits.getQueryRows() - 100; */
                    
                    Integer intQryLimit = intLimit;
                    
                    system.debug(LoggingLevel.WARN, 'intQryLimit ' + intQryLimit );
                    
                    system.debug(LoggingLevel.WARN, 'Work Order Ids = ' + setWOIds.size()  + '; Response size = ' + intResponseSize + '; Limit = ' + intQryLimit);
                    INTF_DataSync.logSOQL(intMethodCount,'select Id, SVMXC__Service_Order__c, SVMXC__Warranty__c, SVMXC__Service_Contract__c, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Entitlement_History__c  where (((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoAllWO) AND SVMXC__Inactive_Date__c = NULL ' + strTimeClause + ') OR ((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoAllWO) AND (SVMXC__Warranty__r.LastModifiedDate >:dtLastSyncTime OR SVMXC__Service_Contract__r.LastModifiedDate > :dtLastSyncTime) AND SVMXC__Inactive_Date__c = NULL) ' + strMdfdEvents + ' ) '+ strEntLastIDClause + 'ORDER BY ID limit '  + intQryLimit);                                                                                   
                    List<SVMXC__Entitlement_History__c> entitleList = database.query('select Id, SVMXC__Service_Order__c, SVMXC__Warranty__c, SVMXC__Service_Contract__c, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Entitlement_History__c  where (((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoAllWO) AND SVMXC__Inactive_Date__c = NULL ' + strTimeClause + ') OR ((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoAllWO) AND (SVMXC__Warranty__r.LastModifiedDate >:dtLastSyncTime OR SVMXC__Service_Contract__r.LastModifiedDate > :dtLastSyncTime) AND SVMXC__Inactive_Date__c = NULL) ' + strMdfdEvents + ' ) ' + strEntLastIDClause + 'ORDER BY ID limit ' + intQryLimit);
                    for(SVMXC__Entitlement_History__c eachRec: entitleList){
                            entitlementIds.add(eachRec.Id);
                         if(eachRec.SVMXC__Warranty__c != null)
                            setWarrantyIds.add(eachRec.SVMXC__Warranty__c);
                         if(eachRec.SVMXC__Service_Contract__c != null)
                            setSCIds.add(eachRec.SVMXC__Service_Contract__c);
                    }
                    if(entitleList != NULL ){
                            intQryLimit -= entitleList.size();
                    }
                    
                    system.debug(LoggingLevel.WARN, 'intQryLimit ' + intQryLimit );
                    
                    if(intQryLimit <= 0){
                            isCallBack = true;
                            lstEntitlementLastId.add(entitleList[entitleList.size() - 1].ID);
                    }
                    
                    /*for(SVMXC__Entitlement_History__c eachRec : database.query('select Id, SVMXC__Service_Order__c, SVMXC__Warranty__c, SVMXC__Service_Contract__c, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Entitlement_History__c  where ((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoAllWO) AND SVMXC__Inactive_Date__c = NULL ' + strTimeClause + ') OR ((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDIdsRelatedtoAllWO) AND (SVMXC__Warranty__r.LastModifiedDate >:dtLastSyncTime OR SVMXC__Service_Contract__r.LastModifiedDate > :dtLastSyncTime) AND SVMXC__Inactive_Date__c = NULL) ' + strMdfdEvents + ' limit ' + intQryLimit))
                    {
                        entitlementIds.add(eachRec.Id);
                        if(eachRec.SVMXC__Warranty__c != null)
                            setWarrantyIds.add(eachRec.SVMXC__Warranty__c);
                        if(eachRec.SVMXC__Service_Contract__c != null)
                            setSCIds.add(eachRec.SVMXC__Service_Contract__c);
                        if(eachRec.SVMXC__Service_Order__c != null){
                            setWOIDs.remove(eachRec.SVMXC__Service_Order__c);
                        }
                            
                        //intResponseSize += json.serialize(entitlementIds).length() + json.serialize(setWOIDs).length() + json.serialize(setWarrantyIds).length() + json.serialize(setSCIds).length();                        
                        //if(intResponseSize > 2500000 || isLimitReached(intLimitPercent))
                        if(isLimitReached(intLimitPercent))
                        {
                            if(setWOIDs != null && setWOIDs.size() > 0)
                            {
                                isCallBack = true;
                                break;
                            } 
                        }
                    }*/
                    system.debug(LoggingLevel.WARN, 'entitlementIds size after execution  = ' + entitlementIds.size() + '; Call back = ' + isCallBack);   
                    system.debug(LoggingLevel.WARN, 'setWOIDs size after execution  = ' + setWOIDs.size() + '; Call back = ' + isCallBack);   
                    system.debug(LoggingLevel.WARN, 'Heap size after adding the retrieved record Ids : ' + Limits.getHeapSize() + '; Response size = ' + intResponseSize);
                    
                    lstWrpData.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Entitlement_History__c', JSON.serialize(entitlementIds)));
                    lstWrpData.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Service_Order__c', JSON.serialize(lstEntitlementLastId)));
                    lstWrpData.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Warranty__c', JSON.serialize(setWarrantyIds)));
                    lstWrpData.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Service_Contract__c', JSON.serialize(setSCIds)));
                    lstwrpData.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(isCallBack)));
                    lstwrpData.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(intLastIndex)));
                    MasterWrapper.valueMap = lstwrpData;
                    MasterWrapper.value = '1';
                }
                else if(intLastIndex == 1)
                {
                    system.debug(LoggingLevel.WARN, 'dtLastSyncTime = ' + dtLastSyncTime);
                    String strCurrClause = '';
                    Integer intResponseSize = 0;
                    Set<ID> setSCIds = new Set<ID>();
                    Set<ID> setSCIdsOfModifiedWOs = new Set<ID>();
                    Set<String> setModifiedWOIds = new Set<String>();
                    Set<String> setIsModifiedFlag = new Set<String>();
                    Set<String> setWDLineIds = new Set<String>();
                    Set<String> setModifiedWDLineIds = new Set<String>();
                    List<INTF_WebServicesDef.SVMXMap> lstPricingDetails = new List<INTF_WebServicesDef.SVMXMap>();
                    
                    setWhatIds.addAll(getSFandSVMXEventRelatedWOIDs(idGrpProfile,strDevConfId ));
                    
                    setWOIds.addAll(getWOIds(setIsModifiedFlag, dtLastSyncTime, setCurrencyISOCodes, strDevConfId));
                    setWOIds.addAll(setWhatIds);
                    
                    string strWDLineSOQL = 'select id, SVMXC__Service_Order__c';
                    if(UserInfo.isMultiCurrencyOrganization())
                    {
                        strWDLineSOQL += ', CurrencyIsoCode';
                    }
                    strWDLineSOQL += ' from SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c IN: setWhatIds AND RecordType.Name = \'Products Serviced\'';
                    INTF_DataSync.logSOQL(intMethodCount,strWDLineSOQL);                                                                                                       
                    for(SVMXC__Service_Order_Line__c eachRec : database.query(strWDLineSOQL))
                    {
                        if(UserInfo.isMultiCurrencyOrganization())
                        {
                            setCurrencyISOCodes.add(String.valueOf(eachRec.get('CurrencyIsoCode')));
                        }
                        setWDLineIds.add(String.valueOf(eachRec.get('Id')));
                    }
                    if(UserInfo.isMultiCurrencyOrganization())
                    {
                        INTF_DataSync.logSOQL(intMethodCount,'select Id, CurrencyIsoCode from SVMXC__Service_Order__c  where Id IN: setWOIds');                        
                        for(SVMXC__Service_Order__c eachRec : database.query('select Id, CurrencyIsoCode from SVMXC__Service_Order__c  where Id IN: setWOIds'))
                            setCurrencyISOCodes.add(String.valueOf(eachRec.get('CurrencyIsoCode')));
                    }
                    
                    system.debug(LoggingLevel.WARN, 'setIsModifiedFlag = ' + setIsModifiedFlag + 'Total WOs = ' + setWOIds.size() + ', Total WO Currencies = ' + setCurrencyISOCodes);
                    
                    if(UserInfo.isMultiCurrencyOrganization())
                        strCurrClause = ' AND (CurrencyIsoCode IN :setCurrencyISOCodes) ';
                    
                    Set<String> setObjectNames = new Set<String>{'SVMXC__Pricing_Rule__c', 'SVMXC__Parts_Pricing__c', 'SVMXC__Parts_Discount__c', 'SVMXC__Labor_Pricing__c', 'SVMXC__Expense_Pricing__c', 'SVMXC__Travel_Policy__c', 'SVMXC__Mileage_Tiers__c', 'SVMXC__Zone_Pricing__c', 'SVMXC__Service_Contract_Services__c', 'SVMXC__Custom_Coverage__c'};
                    
                    if(request.values != null && request.values.size() > 0)
                    {
                        request.values.add(strPartialExecObjName);
                        setObjectNames.retainAll(request.values);
                    }
                    
                    system.debug(LoggingLevel.WARN, 'Size of setObjectNames ' + setObjectNames.size() + '-Set of Object Names to Query : ' + setObjectNames);
                    INTF_DataSync.logSOQL(intMethodCount,'select Id, SVMXC__Service_Order__c, SVMXC__Service_Contract__c, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Entitlement_History__c where (SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDLineIds) AND SVMXC__Inactive_Date__c = NULL AND SVMXC__Service_Contract__c != null');                                            
                    for(SVMXC__Entitlement_History__c eachRec : [select Id, SVMXC__Service_Order__c, SVMXC__Service_Contract__c, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Entitlement_History__c where (SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__c IN: setWDLineIds) AND SVMXC__Inactive_Date__c = NULL AND SVMXC__Service_Contract__c != null])
                        setSCIds.add(eachRec.SVMXC__Service_Contract__c);
                        
                    //if WOEvent is modified then send all the data again for those WO. If DC configuration is modified then also send all data. If WO is newly entitled then also send whole data for that WO.
                    if(dtLastSyncTime != null)
                    {     
                        INTF_DataSync.logSOQL(intMethodCount,'Select Id, WhatId from Event where WhatId IN :setWhatIds AND LastModifiedDate >= :dtLastSyncTime');                                            
                        for(Event ev : [Select Id, WhatId from Event where WhatId IN :setWhatIds AND LastModifiedDate >= :dtLastSyncTime])
                            setModifiedWOIds.add(ev.WhatId);
                        INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :setWhatIds AND LastModifiedDate >= :dtLastSyncTime');
                        for(SVMXC__SVMX_Event__c ev : [Select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where SVMXC__WhatId__c IN :setWhatIds AND LastModifiedDate >= :dtLastSyncTime])
                            setModifiedWOIds.add(ev.SVMXC__WhatId__c);
                    
                        if(!setIsModifiedFlag.contains('true'))
                            strTimeClause = ' AND LastModifiedDate >= :dtLastSyncTime ';
                        INTF_DataSync.logSOQL(intMethodCount,'select Id, SVMXC__Service_Order__c, SVMXC__Service_Contract__c, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Entitlement_History__c where (SVMXC__Service_Order__c IN: setModifiedWOIds OR SVMXC__Work_Detail__r.SVMXC__Service_Order__c IN: setModifiedWOIds OR ((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__r.SVMXC__Service_Order__c IN: setWhatIds) AND LastModifiedDate >= :dtLastSyncTime)) and SVMXC__Inactive_Date__c = NULL AND SVMXC__Service_Contract__c != null');
                        for(SVMXC__Entitlement_History__c eachRec : [select Id, SVMXC__Service_Order__c, SVMXC__Service_Contract__c, SVMXC__Start_Date__c, SVMXC__End_Date__c from SVMXC__Entitlement_History__c where (SVMXC__Service_Order__c IN: setModifiedWOIds OR SVMXC__Work_Detail__r.SVMXC__Service_Order__c IN: setModifiedWOIds OR ((SVMXC__Service_Order__c IN: setWOIds OR SVMXC__Work_Detail__r.SVMXC__Service_Order__c IN: setWhatIds) AND LastModifiedDate >= :dtLastSyncTime)) and SVMXC__Inactive_Date__c = NULL AND SVMXC__Service_Contract__c != null])
                            setSCIdsOfModifiedWOs.add(eachRec.SVMXC__Service_Contract__c);
                    }
                    
                    system.debug(LoggingLevel.WARN, 'strCurrClause = ' + strCurrClause + 'strTimeClause = ' + strTimeClause + '; Number of Modified WOs = ' + setModifiedWOIds.size());
                    system.debug(LoggingLevel.WARN, 'SC Ids = ' + setSCIds.size() + '; setSCIdsOfModifiedWOs ' + setSCIdsOfModifiedWOs.size());
                    
                    if(setSCIds != null && setSCIds.size() > 0)
                    {
                        List<INTF_WebServicesDef.SVMXMap> eachObjValueMap = new List<INTF_WebServicesDef.SVMXMap>();
                        for(String strObjName : setObjectNames)
                        {
                            if(strObjName == 'SVMXC__Pricing_Rule__c' || strObjName == 'SVMXC__Travel_Policy__c')
                            {
                                Set<Id> setExpressionIds = new Set<Id>();
                                if(strObjName == 'SVMXC__Pricing_Rule__c')
                                {
                                    INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__Named_Expression__c from SVMXC__Pricing_Rule__c where SVMXC__Named_Expression__c != null');
                                    for(SVMXC__Pricing_Rule__c objExpr : [Select Id, SVMXC__Named_Expression__c from SVMXC__Pricing_Rule__c where SVMXC__Named_Expression__c != null])
                                        setExpressionIds.add(objExpr.SVMXC__Named_Expression__c);
                                }
                                if(strObjName == 'SVMXC__Travel_Policy__c')
                                {
                                    INTF_DataSync.logSOQL(intMethodCount,'Select Id, SVMXC__Named_Expression__c from SVMXC__Travel_Policy__c where SVMXC__Named_Expression__c != null');
                                    for(SVMXC__Travel_Policy__c objExpr : [Select Id, SVMXC__Named_Expression__c from SVMXC__Travel_Policy__c where SVMXC__Named_Expression__c != null])
                                        setExpressionIds.add(objExpr.SVMXC__Named_Expression__c);
                                }
                                INTF_WebServicesDef.SVMXMap wrpHdrExpressions = new INTF_WebServicesDef.SVMXMap();
                                wrpHdrExpressions.key = 'SVMXC__ServiceMax_Processes__c';
                                INTF_DataSync.logSOQL(intMethodCount,'Select Id from SVMXC__ServiceMax_Processes__c where id in: setExpressionIds and RecordType.Name = \'SVMX RULE\'');
                                for(SVMXC__ServiceMax_Processes__c objExpr : [Select Id from SVMXC__ServiceMax_Processes__c where id in: setExpressionIds and RecordType.Name = 'SVMX RULE'])
                                    wrpHdrExpressions.valueMap.add(new INTF_WebServicesDef.SVMXMap('', JSON.serialize(objExpr)));
                                
                                lstPricingDetails.add(wrpHdrExpressions);
                                
                                INTF_WebServicesDef.SVMXMap wrpDtlExpressions = new INTF_WebServicesDef.SVMXMap();
                                wrpDtlExpressions.key = 'SVMXC__ServiceMax_Config_Data__c';  
                                INTF_DataSync.logSOQL(intMethodCount,'Select Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c in: setExpressionIds and RecordType.Name = \'EXPRESSIONS\'');
                                for(SVMXC__ServiceMax_Config_Data__c objExpr : [Select Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Expression_Rule__c in: setExpressionIds and RecordType.Name = 'EXPRESSIONS'])
                                    wrpDtlExpressions.valueMap.add(new INTF_WebServicesDef.SVMXMap('', JSON.serialize(objExpr)));
                                
                                lstPricingDetails.add(wrpDtlExpressions);
                            }
                            INTF_WebServicesDef.SVMXMap wrpPricing = new INTF_WebServicesDef.SVMXMap();
                            wrpPricing.key = strObjName;
                            String strQry = 'Select Id from ' + strObjName + ' where ((SVMXC__Service_Contract__c IN :setSCIds ' + strCurrClause + strTimeClause + ' ) OR (SVMXC__Service_Contract__c IN :setSCIdsOfModifiedWOs ' + strCurrClause + ' )) ';
                            
                            if(strObjName == strPartialExecObjName)
                                strQry += strLastIdClause;
                                
                            strQry += ' Order By Id ';
                            system.debug(LoggingLevel.WARN, 'Query = ' + strQry);
                            INTF_DataSync.logSOQL(intMethodCount,strQry);                            
                            for(Sobject eachRec : Database.query(strQry))
                            {
                                INTF_WebServicesDef.SVMXMap wrpRecord = new INTF_WebServicesDef.SVMXMap();
                                wrpRecord.value = JSON.serialize(eachRec);
                                wrpPricing.valueMap.add(wrpRecord);
                                intResponseSize += wrpRecord.value.length();
                                if(intResponseSize > 2500000 || isLimitReached(intLimitPercent))
                                {
                                    isCallBack = true;
                                    break;
                                }
                            }
                            lstPricingDetails.add(wrpPricing);
                            if(isCallBack != true)
                                setObjectNames.remove(strObjName);
                            else
                            {
                                setObjectNames.remove(strObjName);
                                if(setObjectNames.size() == 0)
                                    isCallBack = false;
                                lstPricingDetails.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', strObjName));
                                break;
                            }
                        }
                    }
                    else
                    {
                        setObjectNames.clear();
                    }
                    lstPricingDetails.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(isCallBack)));
                    lstPricingDetails.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(intLastIndex)));
                    MasterWrapper.valueMap = lstPricingDetails;
                    MasterWrapper.values.addAll(setObjectNames);//send remaining object names
                    MasterWrapper.value = '2';
                }
                else if(intLastIndex == 2)
                {
                    Integer intResponseSize = 0;
                    set<string> newCurrSet = new set<string>();
                    Set<String> setIsModifiedFlag = new Set<String>();
                    List<String> modifiedEventProdIds = new List<String>();
                    Set<String> setServerCurrencies = new Set<String>();
                    Map<String, String> mapObjToQry = new Map<String, String>();
                    List<INTF_WebServicesDef.SVMXMap> lstPBData = new List<INTF_WebServicesDef.SVMXMap>();
                    String strWhrClause = '', strTimeClauseforPB = '', strTimeClauseforCurr = '', strProductQry = '', strProductLMDQry = '', strClauseforPBEntry = '', strClauseforPBEntry1 = '', strClauseforSrvcPBEntry = '';
                    String strNewEventProductQuery = '', strNewEventClauseForPBE ='';  
                    
                    //setWhatIds = getEventRelatedWOIDs(strDevConfId);
                    //setWhatIds.addAll(getSVMXEventRelatedWOIDs(strDevConfId));
                    
                    /*********************/
                    //get all Events and modified Events
                    
                    Id svmxGrpProfileId = (new Sync_Utility()).getGroupProfileId(null, false);
                    Datetime dtToDate, dtFromDate, dtMovingDate;
                    Datetime currentTime = Datetime.now();
                    String strUserId = UserInfo.getUserId();
                    Set<String> setNewEventWhatIds = new Set<String>();
                    
                    if(idGrpProfile != null){
                            //Get device specific mobile configuration
                        String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
                        if(strDevConfId != NULL && strDevConfId != ''){
                            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                        }
                        system.debug(LoggingLevel.WARN,'Query formed for getEventRelatedWOIDs = '+strMobConfQuery);
                        INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
                        for(SVMXC__ServiceMax_Config_Data__c objConfigData : Database.Query(strMobConfQuery))
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
                    
                    INTF_DataSync.logSOQL(intMethodCount, 'Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId AND What.Id != NULL');
                    for(Event evt :[Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId AND What.Id != NULL])
                    {
                        setWhatIds.add(evt.What.Id);
                    }
                    
                    INTF_DataSync.logSOQL(intMethodCount,'Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
                    for(SVMXC__SVMX_Event__c evt :[Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
                    {
                        setWhatIds.add(evt.SVMXC__WhatId__c);
                    } 
                    
                    if(dtLastSyncTime != null){
                        
                        INTF_DataSync.logSOQL(intMethodCount , 'select Id, WhatId from Event where ((StartDateTime >= :dtMovingDate and EndDateTime <= :dtToDate) OR (LastModifiedDate >= :dtLastSynchTime and ((StartDateTime >= :dtFromDate and EndDateTime <= :dtToDate) OR (StartDateTime <= :dtFromDate and EndDateTime >= :dtToDate)))) and OwnerId = :UserInfo.getUserId() and WhatId != null');
                        for(Event evt : [select Id, WhatId from Event where ((StartDateTime >= :dtMovingDate and EndDateTime <= :dtToDate) OR (LastModifiedDate >= :dtLastSyncTime and ((StartDateTime >= :dtFromDate and EndDateTime <= :dtToDate) OR (StartDateTime <= :dtFromDate and EndDateTime >= :dtToDate)))) and OwnerId = :UserInfo.getUserId() and WhatId != null])
                            setNewEventWhatIds.add(evt.WhatId);
                            
                        INTF_DataSync.logSOQL(intMethodCount ,'select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate)) OR (LastModifiedDate >= :dtLastSynchTime and ((SVMXC__StartDateTime__c >= :dtFromDate and SVMXC__EndDateTime__c <= :dtToDate) OR (SVMXC__StartDateTime__c <= :dtFromDate and SVMXC__EndDateTime__c >= :dtToDate)))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
                        for(SVMXC__SVMX_Event__c evt : [select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate)) OR (LastModifiedDate >= :dtLastSyncTime and ((SVMXC__StartDateTime__c >= :dtFromDate and SVMXC__EndDateTime__c <= :dtToDate) OR (SVMXC__StartDateTime__c <= :dtFromDate and SVMXC__EndDateTime__c >= :dtToDate)))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
                            setNewEventWhatIds.add(evt.SVMXC__WhatId__c);
                    } 
                    
                    /*********************/
                    
                    setWOIds.addAll(getWOIds(setIsModifiedFlag, dtLastSyncTime, setCurrencyISOCodes, strDevConfId));
                    setWOIds.addAll(setWhatIds);
                    
                    if(UserInfo.isMultiCurrencyOrganization())
                    {
                        INTF_DataSync.logSOQL(intMethodCount,'select id, CurrencyIsoCode from SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c IN: setWhatIds AND RecordType.Name = \'Products Serviced\'');
                        for(SVMXC__Service_Order_Line__c eachRec : database.query('select id, CurrencyIsoCode from SVMXC__Service_Order_Line__c  where SVMXC__Service_Order__c IN: setWhatIds AND RecordType.Name = \'Products Serviced\''))
                        {
                            setCurrencyISOCodes.add(String.valueOf(eachRec.get('CurrencyIsoCode')));
                        }
                        INTF_DataSync.logSOQL(intMethodCount,'select Id, CurrencyIsoCode from SVMXC__Service_Order__c  where Id IN: setWOIds');
                        for(SVMXC__Service_Order__c eachRec : database.query('select Id, CurrencyIsoCode from SVMXC__Service_Order__c  where Id IN: setWOIds'))
                        {
                            setCurrencyISOCodes.add(String.valueOf(eachRec.get('CurrencyIsoCode')));
                        }
                        strTimeClauseforCurr = ' AND CurrencyIsoCode IN: setCurrencyISOCodes ';
                    }

                    system.debug(loggingLevel.WARN, 'Work Order Ids size = ' + setWOIds.size() + '; Set of Currencies from WO: ' + setCurrencyISOCodes + '; Set of WO currencies from Client: ' + setClientWOCurrencies);
                    setServerCurrencies.addAll(setCurrencyISOCodes);
                    if(setClientWOCurrencies != null)
                    {
                        setCurrencyISOCodes.removeAll(setClientWOCurrencies);
                        newCurrSet = setCurrencyISOCodes;
                    }
                    
                    if(UserInfo.isMultiCurrencyOrganization())
                    {
                        strClauseforPBEntry = ' AND CurrencyIsoCode IN: setServerCurrencies ';
                        strClauseforSrvcPBEntry = ' AND CurrencyIsoCode IN: setServerCurrencies ';
                        strNewEventClauseForPBE = ' AND CurrencyIsoCode IN: setServerCurrencies ';
                    }
                    if(dtLastSyncTime != null)
                            setWhatIds.removeAll(setNewEventWhatIds);
                            
                    system.debug(loggingLevel.WARN, 'isModified = ' + setIsModifiedFlag + '; New WO currencies added at server' + newCurrSet + '; Set of Currencies from WO: ' + setCurrencyISOCodes + '; Set of Currencies in Server' + setServerCurrencies);
                    //strProductQry = getProductIdQuery(setIsModifiedFlag, dtLastSyncTime, strDevConfId);
                    strProductQry = getProductIdQuery(setIsModifiedFlag, dtLastSyncTime, strDevConfId, setWhatIds, setNewEventWhatIds, modifiedEventProdIds);
                    system.debug('*** Products for new events '+modifiedEventProdIds);
                    
                    mapObjToQry = getPricebookIdQuery(setIsModifiedFlag, dtLastSyncTime, idGrpProfile, strDevConfId);
                    system.debug(loggingLevel.WARN, 'isModified = ' + setIsModifiedFlag);
                    List<sObject> lstPBIds = new List<sObject>();
                    List<sObject> lstSrvcPBIds = new List<sObject>();
                    if(mapObjToQry.containsKey('Pricebook2') && mapObjToQry.get('Pricebook2') != null && mapObjToQry.get('Pricebook2') != '')
                    {
                        strClauseforPBEntry += ' AND Pricebook2Id IN (' + mapObjToQry.get('Pricebook2') + ') ';
                        strNewEventClauseForPBE += ' AND Pricebook2Id IN (' + mapObjToQry.get('Pricebook2') + ') ';
                        INTF_DataSync.logSOQL(intMethodCount,mapObjToQry.get('Pricebook2'));
                        lstPBIds = database.query(mapObjToQry.get('Pricebook2'));
                    }
                    
                    if(mapObjToQry.containsKey('SVMXC__Service_Pricebook__c') && mapObjToQry.get('SVMXC__Service_Pricebook__c') != null && mapObjToQry.get('SVMXC__Service_Pricebook__c') != '')
                    {
                        strClauseforSrvcPBEntry += ' AND SVMXC__Price_Book__c IN (' + mapObjToQry.get('SVMXC__Service_Pricebook__c') + ') ';
                        INTF_DataSync.logSOQL(intMethodCount,mapObjToQry.get('SVMXC__Service_Pricebook__c'));
                        lstSrvcPBIds = database.query(mapObjToQry.get('SVMXC__Service_Pricebook__c'));
                    }
                    
                    if(dtLastSyncTime != null && !setIsModifiedFlag.contains('true'))
                    {
                        if(!UserInfo.isMultiCurrencyOrganization())
                        {
                            if(mapObjToQry.containsKey('Pricebook2') && mapObjToQry.get('Pricebook2') != null)
                                strClauseforPBEntry =   ' AND ((Pricebook2Id IN: setOldPriceBookIds AND LastModifiedDate >= :dtLastSyncTime) OR (Pricebook2Id IN:lstPBIds AND Pricebook2Id NOT IN :setOldPriceBookIds))';
                            else
                                strClauseforPBEntry = ' AND LastModifiedDate >= :dtLastSyncTime ';  
                            
                            if(mapObjToQry.containsKey('SVMXC__Service_Pricebook__c') && mapObjToQry.get('SVMXC__Service_Pricebook__c') != null)
                                strClauseforSrvcPBEntry =   ' AND ((SVMXC__Price_Book__c IN: setOldServicePriceBookIds AND LastModifiedDate >= :dtLastSyncTime) OR (SVMXC__Price_Book__c IN :lstSrvcPBIds AND SVMXC__Price_Book__c NOT IN :setOldServicePriceBookIds))';
                            else
                                strClauseforSrvcPBEntry = ' AND LastModifiedDate >= :dtLastSyncTime ';  
                        }
                        else
                        {
                            if(mapObjToQry.containsKey('Pricebook2') && mapObjToQry.get('Pricebook2') != null)
                                strClauseforPBEntry =   ' AND ((Pricebook2Id IN: setOldPriceBookIds AND CurrencyISOCode IN: setServerCurrencies AND LastModifiedDate >= :dtLastSyncTime) OR (CurrencyISOCode IN: setServerCurrencies AND Pricebook2Id IN:lstPBIds AND Pricebook2Id NOT IN :setOldPriceBookIds) OR (CurrencyISOCode IN: newCurrSet AND Pricebook2Id IN:lstPBIds))';
                            else
                                strClauseforPBEntry = ' AND (CurrencyISOCode IN: newCurrSet OR (CurrencyISOCode IN: setServerCurrencies AND LastModifiedDate >= :dtLastSyncTime))';
                            
                            if(mapObjToQry.containsKey('SVMXC__Service_Pricebook__c') && mapObjToQry.get('SVMXC__Service_Pricebook__c') != null)
                                strClauseforSrvcPBEntry =   ' AND ((SVMXC__Price_Book__c IN: setOldServicePriceBookIds AND CurrencyISOCode IN: setServerCurrencies AND LastModifiedDate >= :dtLastSyncTime) OR (CurrencyISOCode IN: setServerCurrencies AND SVMXC__Price_Book__c IN :lstSrvcPBIds AND SVMXC__Price_Book__c NOT IN :setOldServicePriceBookIds) OR (CurrencyISOCode IN: newCurrSet AND SVMXC__Price_Book__c IN :lstSrvcPBIds))';
                            else
                                strClauseforSrvcPBEntry = ' AND (CurrencyISOCode IN: newCurrSet OR (CurrencyISOCode IN: setServerCurrencies AND LastModifiedDate >= :dtLastSyncTime))'; 
                        }
                        strTimeClauseforPB = ' AND LastModifiedDate >= :dtLastSyncTime';
                    }
                    
                    system.debug(loggingLevel.WARN, '== Clause for PB: ' + strTimeClauseforPB + ' ==Clause for Currency: ' + strTimeClauseforCurr);
                    system.debug(loggingLevel.WARN, 'Clause for Price Book Entry = ' + strClauseforPBEntry + '; Clause for Service Price Book Entry = ' + strClauseforSrvcPBEntry);
                    
                    Set<String> setObjNames = new Set<String>{'Pricebook2', 'PricebookEntry', 'SVMXC__Service_Pricebook__c', 'SVMXC__Service_Pricebook_Entry__c'};
                    if(modifiedEventProdIds.size() > 0){  //Products from new event that came as part of data sync - download all PBE for these products
                            setObjNames.add('PricebookEntry_All');  
                    }
                    if(mapObjToQry.containsKey('Pricebook2') && mapObjToQry.get('Pricebook2') != null)
                        setObjNames.remove('Pricebook2');
                    
                    if(mapObjToQry.containsKey('SVMXC__Service_Pricebook__c') && mapObjToQry.get('SVMXC__Service_Pricebook__c') != null)
                        setObjNames.remove('SVMXC__Service_Pricebook__c');
                        
                    if(strProductQry == null || strProductQry == '' || strProductQry.length() <= 0){
                            setObjNames.remove('PricebookEntry');
                            setObjNames.remove('PricebookEntry_All');
                    }
                    system.debug(LoggingLevel.WARN, 'setObjNames = ' + setObjNames);
                    if(request.values != null && request.values.size() > 0)
                    {
                        request.values.add(strPartialExecObjName);
                        setObjNames.retainAll(request.values);
                    }
                    system.debug(LoggingLevel.WARN, 'Response size = ' + intResponseSize);
                    
                    Boolean isALLPricebookEntry = false;
                    for(String strObjName : setObjNames)
                    {
                        if(strObjName == 'Pricebook2')
                            strWhrClause = ' (IsActive = true OR IsActive = false) ' + strTimeClauseforPB;
                        else if(strObjName == 'PricebookEntry')
                        {
                            strWhrClause = ' Pricebook2.IsActive = true AND Product2Id IN (' + strProductQry + ') ' + strClauseforPBEntry;
                            if(intLimit <= 0)
                                intLimit = 0;
                        }
                        else if(strObjName == 'SVMXC__Service_Pricebook__c')
                            strWhrClause = ' (SVMXC__Active__c = true OR SVMXC__Active__c = false) ' + strTimeClauseforPB;
                        else if(strObjName == 'SVMXC__Service_Pricebook_Entry__c')
                            strWhrClause = ' SVMXC__Activity_Type__c IN :lstLabor AND SVMXC__Price_Book__r.SVMXC__Active__c = true ' + strClauseforSrvcPBEntry;
                        else if(strObjName == 'PricebookEntry_All'){
                                strWhrClause = 'Pricebook2.IsActive = true AND Product2Id IN: modifiedEventProdIds ' + strNewEventClauseForPBE;
                                isALLPricebookEntry = true;
                        }
                        INTF_WebServicesDef.SVMXMap wrpPriceBook = new INTF_WebServicesDef.SVMXMap();
                        wrpPriceBook.key = strObjName;
                        List<INTF_WebServicesDef.SVMXMap> lstPriceBookData = new List<INTF_WebServicesDef.SVMXMap>();
                        String strQry = 'SELECT Id FROM ' + strObjName + ' where ' + strWhrClause;
                        if(isALLPricebookEntry){
                                strQry = 'SELECT Id FROM PricebookEntry where ' + strWhrClause;  //we need to query PricebookEntry
                                wrpPriceBook.key = 'PricebookEntry';
                        }
                        system.debug('Query for the Object - ' + strObjName  + ' - is - '  + strQry);
                        system.debug('Internal Variables - setOldPriceBookIds - ' + setOldPriceBookIds + ' - dtLastSyncTime - '  + dtLastSyncTime + ' - lstPBIds - ' + lstPBIds + ' - setOldPriceBookIds - ' + setOldPriceBookIds + ' - lstSrvcPBIds - ' + lstSrvcPBIds + ' - setOldServicePriceBookIds - ' + setOldServicePriceBookIds);
                        
                        if(strObjName == strPartialExecObjName)
                        {
                            strQry += strLastIdClause;
                        }
                        strQry += '  Order By Id limit : intLimit ';
                        system.debug(LoggingLevel.WARN, 'Query = ' + strQry + '; Limit = ' + intLimit);
                        INTF_DataSync.logSOQL(intMethodCount,strQry);
                        List<sObject> lstSobject = database.query(strQry);
                        if(isDCResponseType)
                        {
                            if(lstSobject != null && lstSobject.size() > 0)
                            {
                                wrpPriceBook.value = JSON.serialize(lstSobject);
                                intLimit = intLimit - lstSobject.size();
                            }
                        }
                        else
                        {
                            for(Sobject eachRec : lstSobject)
                            {
                                intLimit--;
                                INTF_WebServicesDef.SVMXMap wrpRecord = new INTF_WebServicesDef.SVMXMap();
                                wrpRecord.value = JSON.serialize(eachRec);
                                lstPriceBookData.add(wrpRecord);
                                intResponseSize += wrpRecord.value.length();
                                if(intResponseSize > 2500000 || intLimit <= 0 || isLimitReached(intLimitPercent))
                                {
                                    isCallBack = true;
                                    break;
                                }
                            }
                        }
                        if(intLimit <= 0)
                        {
                            isCallBack = true;
                        }
                        wrpPriceBook.valueMap = lstPriceBookData;
                        lstPBData.add(wrpPriceBook);
                        if(isCallBack != true)
                        {
                            setObjNames.remove(strObjName);
                        }
                        else
                        {
                            lstPBData.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', strObjName));
                            break;
                        }
                    }
                    system.debug(LoggingLevel.WARN, 'Heap size before adding the retrieved record Ids : ' + Limits.getHeapSize() + '; Response size = ' + intResponseSize);
                    if(isCallBack && isCallBackCompatible)
                        isCallBack = true;
                    else
                        isCallBack = false;
                    system.debug(loggingLevel.WARN, 'CALL_BACK = ' + isCallBack + ' intLimit = ' + intLimit);
                    
                    if(isDCResponseType)
                        lstPBData.add(new INTF_WebServicesDef.SVMXMap('GET_PRICE_RESPONSE_TYPE', 'DOWNLOAD_CRITERIA_TYPE'));
                        
                    lstPBData.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(isCallBack)));
                    lstPBData.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(intLastIndex)));
                        
                    MasterWrapper.valueMap = lstPBData;
                    MasterWrapper.value = '3';
                    MasterWrapper.values.addAll(setObjNames);
                }
                else if(intLastIndex == 3)
                {
                    Integer intRecLimit = 0;
                    String strIdClause = '', strLastIdToSend = '';
                    List<ID> lstWarrantyIds = new List<ID>();
                    Set<String> setIsModifiedFlag = new Set<String>();
                    String strIBQueryDC = getIBIds(setIsModifiedFlag, dtLastSyncTime, strDevConfId);
                    system.debug(LoggingLevel.WARN, 'IB Query in DC = ' + strIBQueryDC);
                    if(strIBQueryDC.contains('where'))
                    {
                        for(INTF_WebServicesDef.SVMXMap eachObj : getAdvDownloadCriteriaDefForIB(setIsModifiedFlag, dtLastSyncTime,strDevConfId ))
                        {
                            strIBQueryDC += ' OR ' + eachObj.value;
                        }
                    }
                    else if(strIBQueryDC == null || strIBQueryDC == '')
                    {
                        for(INTF_WebServicesDef.SVMXMap eachObj : getAdvDownloadCriteriaDefForIB(setIsModifiedFlag, dtLastSyncTime, strDevConfId))
                        {
                            strIBQueryDC = ' Select Id from SVMXC__Installed_Product__c where ' + eachObj.value;
                        }
                    }
                    if(strLastId != null && strLastId != '')
                    {
                        strIdClause = ' and ID > :strLastId ';
                    }
                    if(dtLastSyncTime!= null && !setIsModifiedFlag.contains('true'))
                    {
                        strTimeClause = ' AND LastModifiedDate >= :dtLastSyncTime ';
                    }
                    intRecLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
                    system.debug(LoggingLevel.WARN, 'Last Id = ' + strIdClause + '; Last Sync Time = ' + dtLastSyncTime + '; IB Query in DC and ADC = ' + strIBQueryDC + '; Time Clause = ' + strTimeClause + '; Limit = ' + intRecLimit);
                    if(strIBQueryDC != null && strIBQueryDC != '')
                    {
                        INTF_DataSync.logSOQL(intMethodCount, 'SELECT Id FROM SVMXC__Warranty__c where SVMXC__Installed_Product__c IN  ( ' + strIBQueryDC + ') ' + strIdClause + strTimeClause + ' Order By ID limit :intRecLimit ' );
                        for(SVMXC__Warranty__c eachWarrantyRec : Database.query('SELECT Id FROM SVMXC__Warranty__c where SVMXC__Installed_Product__c IN  ( ' + strIBQueryDC + ') ' + strIdClause + strTimeClause + ' Order By ID limit :intRecLimit '))
                        {
                            lstWarrantyIds.add(eachWarrantyRec.Id);
                            if(isLimitReached(intLimitPercent) && lstWarrantyIds.size() > 0)
                            {
                                isCallBack = true;
                                lstWarrantyIds.sort();
                                strLastIdToSend = lstWarrantyIds[lstWarrantyIds.size() - 1];
                                break;
                            }
                        }
                    }
                    if(strLastIdToSend == '' || strLastIdToSend.length() <= 0)
                        lstwrpData.add(new INTF_WebServicesDef.SVMXMap('LAST_SYNC_PRICE_CALC', String.valueOf(DateTime.now())));//to maintain separate LST for Get Price Calls
                    lstwrpData.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Warranty__c', JSON.serialize(lstWarrantyIds)));
                    lstwrpData.add(new INTF_WebServicesDef.SVMXMap('LAST_ID', strLastIdToSend));
                    lstwrpData.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(isCallBack)));
                    lstwrpData.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(intLastIndex)));
                    system.debug(LoggingLevel.WARN, 'lstwrpData = ' + lstwrpData);
                    MasterWrapper.valueMap = lstwrpData;
                    MasterWrapper.value = '4';
                }
                else if(intLastIndex == 4)
                {
                    system.debug('Entered Index 4');
                    if(entHistoryIDs.size() > 0 && dtLastSyncTime != NULL){
                        List<String> inactiveEhIds = new List<String>();
                        Integer intRecLimit = intLimit;
                            
                        strTimeClause = ' AND LastModifiedDate >= :dtLastSyncTime ';
                        system.debug(LoggingLevel.WARN, '***Last sync time'+strTimeClause);
                            
                        //Query Entitlement history records that were made inactive in the last data sync
                        List<SVMXC__Entitlement_History__c> ehRecords = Database.Query('Select Id from SVMXC__Entitlement_History__c where ID IN: entHistoryIDs AND SVMXC__Inactive_Date__c != NULL '+ strTimeClause + strLastIdClause + ' Order By ID limit :intRecLimit ');
                        system.debug('Query being executed is: '+'Select Id from SVMXC__Entitlement_History__c where ID IN: entHistoryIDs AND SVMXC__Inactive_Date__c != NULL '+ strTimeClause + strLastIdClause + ' Order By ID limit :intRecLimit ');
                        for(SVMXC__Entitlement_History__c eachRec: ehRecords){
                            inactiveEhIds.add(eachRec.Id);
                        }
                        lstWrpData.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Entitlement_History__c', JSON.serialize(inactiveEhIds)));
                        lstwrpData.add(new INTF_WebServicesDef.SVMXMap('LAST_INDEX', String.valueOf(intLastIndex)));
                            
                        if(ehRecords != NULL){
                            intRecLimit -= ehRecords.size();
                            if(intRecLimit <= 0){  //Call back
                                lstWrpData.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', 'true'));
                                lstWrpData.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', 'SVMXC__Entitlement_History__c', new List<String>{ehRecords[ehRecords.size()-1].Id}));
                            }
                        }
                            
                        MasterWrapper.valueMap = lstWrpData;
                        system.debug(LoggingLevel.WARN, '***'+MasterWrapper.valueMap);
                    }
                }
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventName = request.eventName;
        response.eventType = request.eventType;
        response.valueMap.add(MasterWrapper);
        system.debug(LoggingLevel.WARN, 'In getPricingDefinitions End Queries executed = ' + Limits.getQueries() + ', Records queried = ' + Limits.getQueryRows());
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getPricingDefinitions');
        return response;
    }
    
    public List<INTF_WebServicesDef.SVMXMap> getAdvDownloadCriteriaDefForIB(Set<String> setIsModifiedFlag, Datetime dtLastSynchTime, String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getAdvDownloadCriteriaDefForIB');
        Set<String> setWhatIds = new Set<String>();
        Set<String> setAccessibleObjs = new Set<String>();
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        List<INTF_WebServicesDef.SVMXMap> lstAllDCObjects = new List<INTF_WebServicesDef.SVMXMap>();
        List<SVMXC__ServiceMax_Config_Data__c> lstAdvMobConfigForGrpProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        setWhatIds = getEventRelatedWOIDs(strDevConfId);
        setWhatIds.addAll(getSVMXEventRelatedWOIDs(strDevConfId));
        Id grpProfileId = (new Sync_Utility()).getGroupProfileId(null, true);
        //Device specific setting
        String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Display_Type__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c = \'SVMXC__Installed_Product__c\' and SVMXC__Display_Type__c = \'Advanced Download Criteria\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        system.debug(LoggingLevel.WARN,'Query formed for getAdvDownloadCriteriaDefForIB = '+strMobConfQuery);
        
        INTF_DataSync.logSOQL(intMethodCount, strMobConfQuery);
        
        lstAdvMobConfigForGrpProfile = Database.Query(strMobConfQuery);
        
        allObjs = Schema.getGlobalDescribe();
        for(String objName : allObjs.keySet())
        {
            try
            {
                if(allObjs.get(objName).getDescribe().isAccessible())
                    setAccessibleObjs.add(allObjs.get(objName).getDescribe().getName().toLowerCase());
            }
            catch(Exception ex)
            {
                system.debug(LoggingLevel.WARN, 'Exception during describing Object ' + objName + ': ' + ex.getMessage());
            }
        }
        
        if(setWhatIds != null && setWhatIds.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c eachDCrec : lstAdvMobConfigForGrpProfile)
            {
                INTF_WebServicesDef.SVMXMap responseEachDCObject = new INTF_WebServicesDef.SVMXMap();
                responseEachDCObject.key = eachDCrec.SVMXC__Object_Name__c;
                if(eachDCrec.SVMXC__Object_Name__c != null && eachDCrec.SVMXC__Display_Type__c == 'Advanced Download Criteria' && setAccessibleObjs.contains(eachDCrec.SVMXC__Object_Name__c.toLowerCase()))
                {
                    String strCriteria = '';
                    if(eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                    {
                        strCriteria = '((' + eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                        system.debug(LoggingLevel.WARN, 'Saved Criteria = ' + eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c);
                        INTF_DataSync.logSOQL(intMethodCount,'select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Expressions\' AND SVMXC__Expression_Rule__c =: eachDCRec.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC');
                        for(SVMXC__ServiceMax_Config_Data__c eachDCExpr : [select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c =: eachDCRec.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC])
                        {
                            String strObjNameAndField = '';
                            if(((eachDCExpr.SVMXC__Display_Type__c == 'REFERENCE' || eachDCExpr.SVMXC__Display_Type__c == 'ID') && eachDCExpr.SVMXC__Object_Name2__c != null))
                            {
                                String strReferenceFieldIds = '';
                                strObjNameAndField += '\':' + eachDCExpr.SVMXC__Object_Name2__c + '\',\'' + eachDCExpr.SVMXC__Source_Field_Name__c + '\'';
                                for(sobject sObj : Database.query('Select ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds'))
                                {
                                    system.debug(LoggingLevel.WARN, 'Source Field Value = ' + sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c));
                                    if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null)
                                    {
                                        if(strReferenceFieldIds != '')
                                            strReferenceFieldIds += ',';
                                        strReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';
                                    }     
                                }
                                if(strReferenceFieldIds == '')
                                    strReferenceFieldIds = '\'DummyListOfIds1\'';  
                                strCriteria = strCriteria.replace(strObjNameAndField, strReferenceFieldIds);
                            }
                            else
                            {
                                //criteria exists in variable strCriteria.
                            }
                        }
                    }
                    else
                    {
                        strCriteria = '';
                    }
                    if(eachDCrec.SVMXC__Ownership_Type__c == 'My Records')
                    {
                        if(strCriteria != '')
                            strCriteria = ' ( '+ strCriteria + ' ) and ';
                        else
                            strCriteria += '(';
                        strCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';  
                        
                    }
                    system.debug(LoggingLevel.WARN, 'LastModifiedDate of Each DC Record = ' + eachDCrec.LastModifiedDate + ', Last Sync Time = ' + dtLastSynchTime);
                    if(dtLastSynchTime != null && (eachDCrec.LastModifiedDate > dtLastSynchTime || eachDCrec.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSynchTime))
                        setIsModifiedFlag.add('true');
                    strCriteria += ' )';
                    responseEachDCObject.value = strCriteria;
                    system.debug(LoggingLevel.WARN, 'Each IB Criteria = ' + responseEachDCObject);
                    lstAllDCObjects.add(responseEachDCObject);
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getAdvDownloadCriteriaDefForIB');
        return lstAllDCObjects;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getTechnicianLocation(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.SVMXMap> lstTechDetails = new List<INTF_WebServicesDef.SVMXMap>();
        try
        {
            List<SVMXC__Service_Group_Members__c> lstTechnicians = new List<SVMXC__Service_Group_Members__c>();
            List<Id> lstTechLocIds = new List<Id>();
            List<SVMXC__Site__c> lstTechnicianLoc = new List<SVMXC__Site__c>();
            
            //get Technician record
            lstTechnicians = [Select Id, SVMXC__Latitude__c, SVMXC__Longitude__c, SVMXC__Inventory_Location__c, SVMXC__Street__c, SVMXC__State__c, SVMXC__City__c, SVMXC__Country__c, SVMXC__Zip__c, SVMXC__Latitude_Home__c, SVMXC__Longitude_Home__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1];
            lstTechDetails.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Service_Group_Members__c', JSON.serialize(lstTechnicians)));
            
            //get Technician's Location record
            for(SVMXC__Service_Group_Members__c eachTech : lstTechnicians)
            {
                lstTechLocIds.add(eachTech.SVMXC__Inventory_Location__c);
            }
            lstTechnicianLoc = [SELECT Id, Name, SVMXC__City__c, SVMXC__Country__c, SVMXC__Inventory_Account__c, SVMXC__Location_Type__c FROM SVMXC__Site__c where ID IN :lstTechLocIds];
            lstTechDetails.add(new INTF_WebServicesDef.SVMXMap('SVMXC__Site__c', JSON.serialize(lstTechnicianLoc)));
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.valueMap = lstTechDetails;
        response.eventType = inputRequest.eventType;
        response.eventName = inputRequest.eventName;
        return response;
    }
    
    /*public INTF_WebServicesDef.INTF_SFMResponse getAdvanceDownloadCriteriaRecIds(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getAdvanceDownloadCriteriaRecIds');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        try
        {
            if(inputRequest.eventName == 'ADV_DOWNLOAD_CRITERIA' && inputRequest.eventType == 'SYNC')
            {
                system.debug(LoggingLevel.WARN, 'Request = ' + inputRequest);
                Boolean isCallBack = false;
                Datetime dtLastSynchTime = null;
                Datetime dtToDate, dtFromDate, dtMovingDate;
                Datetime currentTime = Datetime.now();
                String strUserId = UserInfo.getUserId();
                Integer intResponseSize = 0, intLimitPercent = 70;
                Set<String> setWhatIds = new Set<String>();
                Set<String> setObjects = new Set<String>();
                Set<String> setNewEventWhatIds = new Set<String>();
                Set<String> setRemainingObjects = new Set<String>();
                List<String> lstExecutedIds = new List<String>();
                Map<String, List<String>> mapObjectCriteria = new Map<String, List<String>>();
                String strPartialExecObjName = '', strAllRows = '', strIsDeletedField = '', strIsActiveField = '', strLastId = '';
                List<INTF_WebServicesDef.SVMXMap> lstDCObjectRecords = new List<INTF_WebServicesDef.SVMXMap>();
                List<SVMXC__ServiceMax_Config_Data__c> lstAdvMobConfigForGrpProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
                Boolean isOptimized = false;
                
                for(INTF_WebServicesDef.SVMXMap eachReqParam : inputRequest.valueMap)
                {
                    if(eachReqParam.key == 'LAST_SYNC_TIME' && eachReqParam.value != null && eachReqParam.value != ''){
                        dtLastSynchTime = Datetime.valueOf(eachReqParam.value);
                    }else if(eachReqParam.key == 'PARTIAL_EXECUTED_OBJECT' && eachReqParam.values != null && eachReqParam.values.size() > 0)
                    {
                        strPartialExecObjName = eachReqParam.value;
                        lstExecutedIds = eachReqParam.values;
                        strLastId = eachReqParam.values[eachReqParam.values.size() - 1];
                    }else if(eachReqParam.key == 'ADC_OPTIMIZED' && eachReqParam.value != null && eachReqParam.value != ''){
                            isOptimized = Boolean.ValueOf(eachReqParam.value);
                    }
                }
                
                Id idGrpProfile = (new Sync_Utility()).getGroupProfileId(null, false);
                system.debug(LoggingLevel.WARN, 'Group Profile Id = ' + idGrpProfile);
                
                //Device specific setting
                string strDeviceType = (new INTF_ConfigSync()).getDeviceName(inputRequest);
                system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);
                
                String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(idGrpProfile, strDeviceType);
                
                if(!isOptimized){
                    String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
                    
                    if(strDevConfId != NULL && strDevConfId != ''){
                        strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                    }
                    system.debug(LoggingLevel.WARN,'Query formed for getAdvanceDownloadCriteriaRecIds = '+strMobConfQuery);
        
                    if(idGrpProfile != null)
                    {
                        INTF_DataSync.logSOQL(intMethodCount , strMobConfQuery);
                        for(SVMXC__ServiceMax_Config_Data__c objConfigData : Database.Query(strMobConfQuery))
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
                                if(dtLastSynchTime != null)
                                    dtMovingDate = dtLastSynchTime + intValue + 1;
                            }
                        }
                    }
                    INTF_DataSync.logSOQL(intMethodCount , 'Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId and WhatId != null');
                    for(Event evt :[Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId and WhatId != null])
                        setWhatIds.add(evt.What.Id);
                        
                    INTF_DataSync.logSOQL(intMethodCount , 'Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
                    for(SVMXC__SVMX_Event__c evt :[Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
                        setWhatIds.add(evt.SVMXC__WhatId__c);
                    
                    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                    List<String> lstSettingId = new list<String>{'SET011'};
                    Map<String, String> mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                    if(mapSettingsForIPAD018 != null && mapSettingsForIPAD018.size() > 0 && mapSettingsForIPAD018.containskey('SET011') && mapSettingsForIPAD018.get('SET011') != null)
                        intLimitPercent = integer.valueOf(mapSettingsForIPAD018.get('SET011'));
                    else
                        intLimitPercent = 70;
                        
                    if(dtLastSynchTime != null)
                    {
                        INTF_DataSync.logSOQL(intMethodCount , 'select Id, WhatId from Event where ((StartDateTime >= :dtMovingDate and EndDateTime <= :dtToDate) OR (LastModifiedDate >= :dtLastSynchTime and ((StartDateTime >= :dtFromDate and EndDateTime <= :dtToDate) OR (StartDateTime <= :dtFromDate and EndDateTime >= :dtToDate)))) and OwnerId = :UserInfo.getUserId() and WhatId != null');
                        for(Event evt : [select Id, WhatId from Event where ((StartDateTime >= :dtMovingDate and EndDateTime <= :dtToDate) OR (LastModifiedDate >= :dtLastSynchTime and ((StartDateTime >= :dtFromDate and EndDateTime <= :dtToDate) OR (StartDateTime <= :dtFromDate and EndDateTime >= :dtToDate)))) and OwnerId = :UserInfo.getUserId() and WhatId != null])
                            setNewEventWhatIds.add(evt.WhatId);
                            
                        INTF_DataSync.logSOQL(intMethodCount ,'select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate)) OR (LastModifiedDate >= :dtLastSynchTime and ((SVMXC__StartDateTime__c >= :dtFromDate and SVMXC__EndDateTime__c <= :dtToDate) OR (SVMXC__StartDateTime__c <= :dtFromDate and SVMXC__EndDateTime__c >= :dtToDate)))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
                        for(SVMXC__SVMX_Event__c evt : [select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate)) OR (LastModifiedDate >= :dtLastSynchTime and ((SVMXC__StartDateTime__c >= :dtFromDate and SVMXC__EndDateTime__c <= :dtToDate) OR (SVMXC__StartDateTime__c <= :dtFromDate and SVMXC__EndDateTime__c >= :dtToDate)))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
                            setNewEventWhatIds.add(evt.SVMXC__WhatId__c);
                            
                        setWhatIds.removeAll(setNewEventWhatIds);
                        strIsDeletedField = ' ,isDeleted ';
                        strIsActiveField = ' ,isActive ';
                        strAllRows = ' All ROWS ';
                    }
                    system.debug(LoggingLevel.WARN, 'New event whatids = ' + setNewEventWhatIds + '; All Events except New Events' + setWhatIds);
                    
                }else{
                    //ADC optimization:
                    if(idGrpProfile != null){
                        Map<String, String> mapClientInfo = new Map<String, String>();
                        mapClientInfo = (new INTF_ConfigSync()).getClientData(inputRequest);
                        system.debug(LoggingLevel.WARN, 'mapClientInfo = ' + mapClientInfo);
                        
                        String strSFUserId = mapClientInfo.get('userid');
                        String strDeviceUDID = mapClientInfo.get('clientudid');
                        String strSyncReqId = inputRequest.value;
                        
                        Map<String, String> mapAllEventWhatIds = new Map<String, String>();
                        
                        INTF_DataSync.logSOQL(intMethodCount ,'Select Id, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Event_What_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strSFUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID');
                        List<SVMXC__SM_Request_Cache__c> requestCacheList = [Select Id, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Event_What_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strSFUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                       
                        if(requestCacheList != null && !requestCacheList.isEmpty()){  
                            if(requestCacheList[0].SVMXC__SM_Client_Sync_Request_Id__c == strSyncReqId && requestCacheList[0].SVMXC__SM_Event_What_IDs__c != NULL ){
                                mapAllEventWhatIds = (Map<String, String>)Json.deserialize(requestCacheList[0].SVMXC__SM_Event_What_IDs__c,Map<String, String>.Class);
                                system.debug(LoggingLevel.WARN, '***** ADC After Deserializing = '+mapAllEventWhatIds);  
                            }
                        }
                        if(mapAllEventWhatIds != NULL && !mapAllEventWhatIds.isEmpty()){
                                if(mapAllEventWhatIds.get('ALL_EVENTS') != NULL){
                                    setWhatIds = (Set<String>)Json.deserialize(mapAllEventWhatIds.get('ALL_EVENTS'),Set<String>.Class);
                                }
                            if(dtLastSynchTime != null && mapAllEventWhatIds.get('MODIFIED_EVENTS') != NULL ){
                                setNewEventWhatIds = (Set<String>)Json.deserialize(mapAllEventWhatIds.get('MODIFIED_EVENTS'),Set<String>.Class);
                            }
                            setWhatIds.removeAll(setNewEventWhatIds);
                        }
                        
                        if(dtLastSynchTime != null){
                            strIsDeletedField = ' ,isDeleted ';
                            strIsActiveField = ' ,isActive ';
                            strAllRows = ' All ROWS ';
                        }
                    }
                    system.debug(LoggingLevel.WARN,'After retrieving IDs from cache ALL = '+setWhatIds +'*** Modified = '+setNewEventWhatIds);
                }
                
                system.debug(LoggingLevel.WARN, '***** inputRequest.values = '+inputRequest.values);
                if(inputRequest.values != null && inputRequest.values.size() > 0)
                {
                    setRemainingObjects.addAll(inputRequest.values);
                }
                if(strPartialExecObjName != ''){
                    setRemainingObjects.add(strPartialExecObjName);
                }
                
                system.debug(LoggingLevel.WARN, '***** After setObjects = '+setObjects);
                
                String strMobConfQuery = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Display_Type__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Display_Type__c = \'Advanced Download Criteria\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
                
                if(setRemainingObjects.size() > 0){  //In case of incremental sync, query ADC config for pending objects only
                        strMobConfQuery += ' AND SVMXC__Object_Name__c IN: setRemainingObjects ';
                }
                //Device specific settings
                if(strDevConfId != NULL && strDevConfId != ''){
                    strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                }
                
                system.debug(LoggingLevel.WARN,'Second Query formed for getAdvanceDownloadCriteriaRecIds = '+strMobConfQuery);
    
                //lstAdvMobConfigForGrpProfile = [select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Display_Type__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Display_Type__c = 'Advanced Download Criteria' AND RecordType.Name = 'Mobile Configuration' AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile];
                INTF_DataSync.logSOQL(intMethodCount ,strMobConfQuery);
                lstAdvMobConfigForGrpProfile = Database.Query(strMobConfQuery);
                
                if(lstAdvMobConfigForGrpProfile != null && lstAdvMobConfigForGrpProfile.size() > 0)
                {
                    for(INTF_WebServicesDef.SVMXMap eachObj : getAdvDownloadCriteriaDef(dtLastSynchTime, setWhatIds, setNewEventWhatIds, idGrpProfile, lstAdvMobConfigForGrpProfile))
                    {
                        if(!mapObjectCriteria.containsKey(eachObj.key))
                            mapObjectCriteria.put(eachObj.key, new List<String>{eachObj.value});
                        else
                        {
                            String str = mapObjectCriteria.get(eachObj.key)[0];
                            str += ' OR (' + eachObj.value + ')';
                            mapObjectCriteria.get(eachObj.key).clear();
                            mapObjectCriteria.get(eachObj.key).add(str);
                        }
                    }
                }
                setObjects.addAll(mapObjectCriteria.keySet());
                system.debug(LoggingLevel.WARN,'setObjects = '+setObjects.size());
                
                INTF_WebServicesDef.SVMXMap objDeletedValueMap = new INTF_WebServicesDef.SVMXMap();
                objDeletedValueMap.key = 'DELETE';
                List<INTF_WebServicesDef.SVMXMap> lstDeletedRec = new List<INTF_WebServicesDef.SVMXMap>();
                for(String eachObj : setObjects)
                {
                    String strADCQry = '';
                    INTF_WebServicesDef.SVMXMap eachDCObjectResp = new INTF_WebServicesDef.SVMXMap();
                    eachDCObjectResp.key = eachObj;
                    INTF_WebServicesDef.SVMXMap objDeletedRecId = new INTF_WebServicesDef.SVMXMap();
                    objDeletedRecId.key = eachObj;
                    system.debug(LoggingLevel.WARN, 'Object Name = ' + eachDCObjectResp.key + ', Query = ' + mapObjectCriteria.get(eachObj));
                    
                    if(eachObj == 'User')
                        strADCQry = 'Select Id ' + strIsActiveField + ' from ' + eachObj + ' where ' + mapObjectCriteria.get(eachObj) + ' Order By Id ' + strAllRows;
                    else
                        strADCQry = 'Select Id ' + strIsDeletedField + ' from ' + eachObj + ' where ' + mapObjectCriteria.get(eachObj) + ' Order By Id ' + strAllRows;
                    
                    if(eachObj == strPartialExecObjName)
                    {
                        if(eachObj == 'User')
                            strADCQry = 'Select Id ' + strIsActiveField + ' from ' + eachObj + ' where ' + mapObjectCriteria.get(eachObj) + ' AND ID > \'' + strLastId + '\' Order By Id ' + strAllRows;
                        else
                            strADCQry = 'Select Id ' + strIsDeletedField + ' from ' + eachObj + ' where ' + mapObjectCriteria.get(eachObj) + ' AND ID > \'' + strLastId + '\' Order By Id ' + strAllRows;   
                    }
                    system.debug(LoggingLevel.WARN, 'Query = ' + strADCQry);
                    system.debug(LoggingLevel.WARN, 'Last Sync Time = ' + dtLastSynchTime);
                    INTF_DataSync.logSOQL(intMethodCount , strADCQry);
                    //for(sobject eachRec: Database.query(strADCQry))
                    List<SObject> sobjList = Database.query(strADCQry);
                    system.debug(LoggingLevel.WARN, 'sobjList = ' + sobjList.size());
                    for(sobject eachRec: sobjList)
                    {
                        system.debug(LoggingLevel.WARN, 'eachRec = ' + eachRec);
                        if(strIsDeletedField != null && strIsDeletedField.length() > 0 && dtLastSynchTime != null)
                        {
                            if(eachObj != 'User' && eachRec.get('isDeleted') == true)
                            {
                                objDeletedRecId.values.add(String.valueOf(eachRec.get('Id')));
                            }
                            else
                            {
                                INTF_WebServicesDef.SVMXMap wrpRecord = new INTF_WebServicesDef.SVMXMap();
                                wrpRecord.value = JSON.serialize(eachRec.Id);
                                eachDCObjectResp.valueMap.add(wrpRecord);
                                intResponseSize += wrpRecord.value.length();
                            }
                        }
                        else
                        {
                            INTF_WebServicesDef.SVMXMap wrpRecord = new INTF_WebServicesDef.SVMXMap();
                            wrpRecord.value = JSON.serialize(eachRec.Id);
                            eachDCObjectResp.valueMap.add(wrpRecord);
                            intResponseSize += wrpRecord.value.length();
                        }
                        if(intResponseSize > 2500000 || isLimitReached(intLimitPercent))
                        {
                            isCallBack = true;
                            break;
                        }
                    }
                    system.debug(LoggingLevel.WARN, 'isCallBack = ' + isCallBack);
                    lstDCObjectRecords.add(eachDCObjectResp);
                    objDeletedValueMap.valueMap.add(objDeletedRecId);
                    setObjects.remove(eachObj);
                    if(isCallBack == true)
                    {
                        setObjects.add(eachObj);    
                        lstDCObjectRecords.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', eachObj));
                        break;
                    }
                }
                lstDCObjectRecords.add(objDeletedValueMap);
                lstDCObjectRecords.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(isCallBack)));
                response.valueMap = lstDCObjectRecords;
                response.values.addAll(setObjects);
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getAdvanceDownloadCriteriaRecIds');
        return response;
    }*/
    
    public INTF_WebServicesDef.INTF_SFMResponse getAdvanceDownloadCriteriaRecIds(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getAdvanceDownloadCriteriaRecIds');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        try
        {
            if(inputRequest.eventName == 'ADV_DOWNLOAD_CRITERIA' && inputRequest.eventType == 'SYNC')
            {
                system.debug(LoggingLevel.WARN, 'Request = ' + inputRequest);
                Boolean isCallBack = false;
                Datetime dtLastSynchTime = null;
                Datetime dtToDate, dtFromDate, dtMovingDate;
                Datetime currentTime = Datetime.now();
                String strUserId = UserInfo.getUserId();
                Integer intResponseSize = 0, intLimitPercent = 70;
                Set<String> setWhatIds = new Set<String>();
                Set<String> setObjects = new Set<String>();
                Set<String> setNewEventWhatIds = new Set<String>();
                Set<String> setRemainingObjects = new Set<String>();
                Map<String, List<String>> mapObjectCriteria = new Map<String, List<String>>();
                String strPartialExecObjName = '', strAllRows = '', strIsDeletedField = '', strIsActiveField = '', strLastId = '';
                List<INTF_WebServicesDef.SVMXMap> lstDCObjectRecords = new List<INTF_WebServicesDef.SVMXMap>();
                List<SVMXC__ServiceMax_Config_Data__c> lstAdvMobConfigForGrpProfile = new List<SVMXC__ServiceMax_Config_Data__c>();
                Boolean isOptimized = false;
                
                for(INTF_WebServicesDef.SVMXMap eachReqParam : inputRequest.valueMap)
                {
                    if(eachReqParam.key == 'LAST_SYNC_TIME' && eachReqParam.value != null && eachReqParam.value != ''){
                        dtLastSynchTime = Datetime.valueOf(eachReqParam.value);
                    }else if(eachReqParam.key == 'PARTIAL_EXECUTED_OBJECT' && eachReqParam.values != null && eachReqParam.values.size() > 0)
                    {
                        strPartialExecObjName = eachReqParam.value;
                        strLastId = eachReqParam.values[eachReqParam.values.size() - 1];
                    }else if(eachReqParam.key == 'ADC_OPTIMIZED' && eachReqParam.value != null && eachReqParam.value != ''){
                            isOptimized = Boolean.ValueOf(eachReqParam.value);
                    }
                }
                
                Id idGrpProfile = (new Sync_Utility()).getGroupProfileId(null, false);
                system.debug(LoggingLevel.WARN, 'Group Profile Id = ' + idGrpProfile);
                
                //Device specific setting
                INTF_ConfigSync conSync = new INTF_ConfigSync();
                string strDeviceType = conSync.getDeviceName(inputRequest);
                system.debug(LoggingLevel.WARN,' Device from Request strDeviceType = '+strDeviceType);
                
                String strDevConfId = conSync.getDeviceMobileConfig(idGrpProfile, strDeviceType);
                String svmxGrpProfileId = conSync.getSVMXGrpProfileId(userinfo.getProfileId());
                for(SVMXC__ServiceMax_Config_Data__c cnf: conSync.getSettings(new set<string>(), new set<string>(), new set<string>{'IPAD018_SET011'}, svmxGrpProfileId))
                        intLimitPercent = Integer.valueOf(cnf.SVMXC__Internal_Value__c);
                        system.debug(LoggingLevel.WARN, 'IPAD018_SET011 = '+intLimitPercent);
                        
                Integer queryLimit = conSync.calculateLimit(intLimitPercent);       
                
               if(!isOptimized){
                    String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
                    
                    if(strDevConfId != NULL && strDevConfId != ''){
                        strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                    }
                    system.debug(LoggingLevel.WARN,'Query formed for getAdvanceDownloadCriteriaRecIds = '+strMobConfQuery);
        
                    if(idGrpProfile != null)
                    {
                        INTF_DataSync.logSOQL(intMethodCount , strMobConfQuery);
                        for(SVMXC__ServiceMax_Config_Data__c objConfigData : Database.Query(strMobConfQuery))
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
                                if(dtLastSynchTime != null)
                                    dtMovingDate = dtLastSynchTime + intValue + 1;
                            }
                        }
                    }
                    INTF_DataSync.logSOQL(intMethodCount , 'Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId and WhatId != null');
                    for(Event evt :[Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId and WhatId != null])
                        setWhatIds.add(evt.What.Id);
                        
                    INTF_DataSync.logSOQL(intMethodCount , 'Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
                    for(SVMXC__SVMX_Event__c evt :[Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
                        setWhatIds.add(evt.SVMXC__WhatId__c);
                    
                    if(dtLastSynchTime != null)
                    {
                        INTF_DataSync.logSOQL(intMethodCount , 'select Id, WhatId from Event where ((StartDateTime >= :dtMovingDate and EndDateTime <= :dtToDate) OR (LastModifiedDate >= :dtLastSynchTime and ((StartDateTime >= :dtFromDate and EndDateTime <= :dtToDate) OR (StartDateTime <= :dtFromDate and EndDateTime >= :dtToDate)))) and OwnerId = :UserInfo.getUserId() and WhatId != null');
                        for(Event evt : [select Id, WhatId from Event where ((StartDateTime >= :dtMovingDate and EndDateTime <= :dtToDate) OR (LastModifiedDate >= :dtLastSynchTime and ((StartDateTime >= :dtFromDate and EndDateTime <= :dtToDate) OR (StartDateTime <= :dtFromDate and EndDateTime >= :dtToDate)))) and OwnerId = :UserInfo.getUserId() and WhatId != null])
                            setNewEventWhatIds.add(evt.WhatId);
                            
                        INTF_DataSync.logSOQL(intMethodCount ,'select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate)) OR (LastModifiedDate >= :dtLastSynchTime and ((SVMXC__StartDateTime__c >= :dtFromDate and SVMXC__EndDateTime__c <= :dtToDate) OR (SVMXC__StartDateTime__c <= :dtFromDate and SVMXC__EndDateTime__c >= :dtToDate)))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
                        for(SVMXC__SVMX_Event__c evt : [select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate)) OR (LastModifiedDate >= :dtLastSynchTime and ((SVMXC__StartDateTime__c >= :dtFromDate and SVMXC__EndDateTime__c <= :dtToDate) OR (SVMXC__StartDateTime__c <= :dtFromDate and SVMXC__EndDateTime__c >= :dtToDate)))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
                            setNewEventWhatIds.add(evt.SVMXC__WhatId__c);
                            
                        setWhatIds.removeAll(setNewEventWhatIds);
                        strIsDeletedField = ' ,isDeleted ';
                        strIsActiveField = ' ,isActive ';
                        strAllRows = ' All ROWS ';
                    }
                    system.debug(LoggingLevel.WARN, 'New event whatids = ' + setNewEventWhatIds + '; All Events except New Events' + setWhatIds);
                    
                }else{
                    //ADC optimization:
                    if(idGrpProfile != null){
                        Map<String, String> mapClientInfo = new Map<String, String>();
                        mapClientInfo = (new INTF_ConfigSync()).getClientData(inputRequest);
                        system.debug(LoggingLevel.WARN, 'mapClientInfo = ' + mapClientInfo);
                        
                        String strSFUserId = mapClientInfo.get('userid');
                        String strDeviceUDID = mapClientInfo.get('clientudid');
                        String strSyncReqId = inputRequest.value;
                        
                        Map<String, String> mapAllEventWhatIds = new Map<String, String>();
                        
                        INTF_DataSync.logSOQL(intMethodCount ,'Select Id, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Event_What_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strSFUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID');
                        List<SVMXC__SM_Request_Cache__c> requestCacheList = [Select Id, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Event_What_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strSFUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                       
                        if(requestCacheList != null && !requestCacheList.isEmpty()){  
                            if(requestCacheList[0].SVMXC__SM_Client_Sync_Request_Id__c == strSyncReqId && requestCacheList[0].SVMXC__SM_Event_What_IDs__c != NULL ){
                                mapAllEventWhatIds = (Map<String, String>)Json.deserialize(requestCacheList[0].SVMXC__SM_Event_What_IDs__c,Map<String, String>.Class);
                                system.debug(LoggingLevel.WARN, '***** ADC After Deserializing = '+mapAllEventWhatIds);  
                            }
                        }
                        if(mapAllEventWhatIds != NULL && !mapAllEventWhatIds.isEmpty()){
                                if(mapAllEventWhatIds.get('ALL_EVENTS') != NULL){
                                    setWhatIds = (Set<String>)Json.deserialize(mapAllEventWhatIds.get('ALL_EVENTS'),Set<String>.Class);
                                }
                            if(dtLastSynchTime != null && mapAllEventWhatIds.get('MODIFIED_EVENTS') != NULL ){
                                setNewEventWhatIds = (Set<String>)Json.deserialize(mapAllEventWhatIds.get('MODIFIED_EVENTS'),Set<String>.Class);
                            }
                            setWhatIds.removeAll(setNewEventWhatIds);
                        }
                        
                        if(dtLastSynchTime != null){
                            strIsDeletedField = ' ,isDeleted ';
                            strIsActiveField = ' ,isActive ';
                            strAllRows = ' All ROWS ';
                        }
                    }
                    system.debug(LoggingLevel.WARN,'After retrieving IDs from cache ALL = '+setWhatIds +'*** Modified = '+setNewEventWhatIds);
                }
                
                system.debug(LoggingLevel.WARN, '***** inputRequest.values = '+inputRequest.values);
                if(inputRequest.values != null && inputRequest.values.size() > 0)
                {
                    setRemainingObjects.addAll(inputRequest.values);
                }
                if(strPartialExecObjName != ''){
                    setRemainingObjects.add(strPartialExecObjName);
                }
                system.debug(LoggingLevel.WARN, '***** After setRemainingObjects = '+setRemainingObjects);
                
                String strMobConfQuery = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Display_Type__c, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Display_Type__c = \'Advanced Download Criteria\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
                if(setRemainingObjects.size() > 0){  //In case of batching, query ADC config for pending objects only
                        strMobConfQuery += ' AND SVMXC__Object_Name__c IN: setRemainingObjects ';
                }
                if(strDevConfId != NULL && strDevConfId != ''){ //Device specific settings
                    strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
                }
                
                system.debug(LoggingLevel.WARN,'Second Query formed for getAdvanceDownloadCriteriaRecIds = '+strMobConfQuery);
    
                INTF_DataSync.logSOQL(intMethodCount ,strMobConfQuery);
                lstAdvMobConfigForGrpProfile = Database.Query(strMobConfQuery);
                
                if(lstAdvMobConfigForGrpProfile != null && lstAdvMobConfigForGrpProfile.size() > 0)
                {
                    for(INTF_WebServicesDef.SVMXMap eachObj : getAdvDownloadCriteriaDef(dtLastSynchTime, setWhatIds, setNewEventWhatIds, idGrpProfile, lstAdvMobConfigForGrpProfile))
                    {
                        if(!mapObjectCriteria.containsKey(eachObj.key))
                            mapObjectCriteria.put(eachObj.key, new List<String>{eachObj.value});
                        else
                        {
                            String str = mapObjectCriteria.get(eachObj.key)[0];
                            str += ' OR (' + eachObj.value + ')';
                            mapObjectCriteria.get(eachObj.key).clear();
                            mapObjectCriteria.get(eachObj.key).add(str);
                        }
                    }
                }
                setObjects.addAll(mapObjectCriteria.keySet());
                system.debug(LoggingLevel.WARN,'All setObjects = '+setObjects.size());
                
                INTF_WebServicesDef.SVMXMap objDeletedValueMap = new INTF_WebServicesDef.SVMXMap();
                objDeletedValueMap.key = 'DELETE';
                List<INTF_WebServicesDef.SVMXMap> lstDeletedRec = new List<INTF_WebServicesDef.SVMXMap>();
                
                for(String eachObj : setObjects)
                {
                        String strADCQry = '';
                    String lastID = '';
                    INTF_WebServicesDef.SVMXMap eachDCObjectResp = new INTF_WebServicesDef.SVMXMap();
                    eachDCObjectResp.key = eachObj;
                    INTF_WebServicesDef.SVMXMap objDeletedRecId = new INTF_WebServicesDef.SVMXMap();
                    objDeletedRecId.key = eachObj;
                    system.debug(LoggingLevel.WARN, 'Remaining limit = '+ queryLimit+' Object Name = ' + eachDCObjectResp.key + ', Query = ' + mapObjectCriteria.get(eachObj));
                    
                    if(eachObj == 'User')
                        strADCQry = 'Select Id ' + strIsActiveField + ' from ' + eachObj + ' where ' + mapObjectCriteria.get(eachObj) + ' Order By Id LIMIT ' + queryLimit + strAllRows;
                    else
                        strADCQry = 'Select Id ' + strIsDeletedField + ' from ' + eachObj + ' where ' + mapObjectCriteria.get(eachObj) + ' Order By Id LIMIT ' + queryLimit + strAllRows;
                    
                    if(eachObj == strPartialExecObjName)
                    {
                        if(eachObj == 'User')
                            strADCQry = 'Select Id ' + strIsActiveField + ' from ' + eachObj + ' where ' + mapObjectCriteria.get(eachObj) + ' AND ID > \'' + strLastId + '\' Order By Id LIMIT ' + queryLimit + strAllRows;
                        else
                            strADCQry = 'Select Id ' + strIsDeletedField + ' from ' + eachObj + ' where ' + mapObjectCriteria.get(eachObj) + ' AND ID > \'' + strLastId + '\' Order By Id LIMIT ' + queryLimit + strAllRows;
                    }
                    system.debug(LoggingLevel.WARN, 'Query = ' + strADCQry);
                    system.debug(LoggingLevel.WARN, 'Last Sync Time = ' + dtLastSynchTime);
                    INTF_DataSync.logSOQL(intMethodCount , strADCQry);
                    List<SObject> sobjList = Database.query(strADCQry);
                    system.debug(LoggingLevel.WARN, 'sobjList = ' + sobjList.size());
                    queryLimit = queryLimit - sobjList.size();
                    if( queryLimit <= 0){
                            isCallBack = true;
                            lastID = sobjList[sobjList.size()-1].Id;
                    }
                    
                    for(sobject eachRec: sobjList)
                    {
                        system.debug(LoggingLevel.WARN, 'eachRec = ' + eachRec);
                        if(strIsDeletedField != null && strIsDeletedField.length() > 0 && dtLastSynchTime != null)
                        {
                            if(eachObj != 'User' && eachRec.get('isDeleted') == true)
                            {
                                objDeletedRecId.values.add(String.valueOf(eachRec.get('Id')));
                            }
                            else
                            {
                                INTF_WebServicesDef.SVMXMap wrpRecord = new INTF_WebServicesDef.SVMXMap('',JSON.serialize(eachRec.Id));
                                eachDCObjectResp.valueMap.add(wrpRecord);
                                intResponseSize += wrpRecord.value.length();
                            }
                        }
                        else
                        {
                            INTF_WebServicesDef.SVMXMap wrpRecord = new INTF_WebServicesDef.SVMXMap('',JSON.serialize(eachRec.Id));
                            eachDCObjectResp.valueMap.add(wrpRecord);
                            intResponseSize += wrpRecord.value.length();
                        }
                        if(intResponseSize > 2500000 || isLimitReached(intLimitPercent))
                        {
                            isCallBack = true;
                            lastID = eachRec.Id;
                            break;
                        }
                    }
                    system.debug(LoggingLevel.WARN, 'isCallBack = ' + isCallBack);
                    lstDCObjectRecords.add(eachDCObjectResp);
                    objDeletedValueMap.valueMap.add(objDeletedRecId);
                    setObjects.remove(eachObj);
                    if(isCallBack)
                    {
                        setObjects.add(eachObj);    
                        lstDCObjectRecords.add(new INTF_WebServicesDef.SVMXMap('PARTIAL_EXECUTED_OBJECT', eachObj, new List<string>{lastID}));
                        break;
                    }
                }
                lstDCObjectRecords.add(objDeletedValueMap);
                lstDCObjectRecords.add(new INTF_WebServicesDef.SVMXMap('CALL_BACK', String.valueOf(isCallBack)));
                response.valueMap = lstDCObjectRecords;
                response.values.addAll(setObjects);
            }
        }
        catch(Exception e)
        {
            SmaxException customException = new SmaxException(null, e);
            response.errors.add(customException.getDetailedErrorMsg());
            response.success = false;
        }
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getAdvanceDownloadCriteriaRecIds');
        return response;
    }
    
    public List<INTF_WebServicesDef.SVMXMap> getAdvDownloadCriteriaDef(Datetime dtLastSynchTime, Set<String> setWhatIds, Set<String> setNewEventWhatIds, Id grpProfileId, List<SVMXC__ServiceMax_Config_Data__c> lstAdvMobConfigForGrpProfile)
    {
        
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getAdvDownloadCriteriaDef');
        String strTimeClause = '';
        Set<String> setAccessibleObjs = new Set<String>();
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        List<INTF_WebServicesDef.SVMXMap> lstAllDCObjects = new List<INTF_WebServicesDef.SVMXMap>();
    
        if((setWhatIds != null && setWhatIds.size() > 0) || (setNewEventWhatIds != null && setNewEventWhatIds.size() > 0))
        {
            allObjs = Schema.getGlobalDescribe();
            for(String objName : allObjs.keySet())
            {
                try
                {
                    if(allObjs.get(objName).getDescribe().isAccessible())
                        setAccessibleObjs.add(allObjs.get(objName).getDescribe().getName().toLowerCase());
                }
                catch(Exception ex)
                {
                    system.debug(LoggingLevel.WARN, 'Exception during describing Object ' + objName + ': ' + ex.getMessage());
                }
            }
            for(SVMXC__ServiceMax_Config_Data__c eachDCrec : lstAdvMobConfigForGrpProfile)
            {
                if(dtLastSynchTime != null)
                    strTimeClause = ' AND LastModifiedDate >= :dtLastSynchTime ';
                    
                INTF_WebServicesDef.SVMXMap responseEachDCObject = new INTF_WebServicesDef.SVMXMap();
                responseEachDCObject.key = eachDCrec.SVMXC__Object_Name__c;
                if(eachDCrec.SVMXC__Object_Name__c != null && eachDCrec.SVMXC__Display_Type__c == 'Advanced Download Criteria' && setAccessibleObjs.contains(eachDCrec.SVMXC__Object_Name__c.toLowerCase()))
                {
                    String strCriteria = '', strCriteriaForNewEvents = '';
                    if(eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                    {
                        strCriteria = '((' + eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                        strCriteriaForNewEvents = '((' + eachDCrec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                        system.debug(LoggingLevel.WARN, 'strCriteria = ' + strCriteria);
                        system.debug(LoggingLevel.WARN, 'strCriteriaForNewEvents = ' + strCriteriaForNewEvents);
                        INTF_DataSync.logSOQL(intMethodCount , 'select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Expressions\' AND SVMXC__Expression_Rule__c =: eachDCRec.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC');
                        for(SVMXC__ServiceMax_Config_Data__c eachDCExpr : [select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c =: eachDCRec.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC])
                        {
                            String strObjNameAndField = '';
                            if(((eachDCExpr.SVMXC__Display_Type__c == 'REFERENCE' || eachDCExpr.SVMXC__Display_Type__c == 'ID') && eachDCExpr.SVMXC__Object_Name2__c != null))
                            {
                                String strReferenceFieldIds = '', strNewReferenceFieldIds = '';
                                strObjNameAndField += '\':' + eachDCExpr.SVMXC__Object_Name2__c + '\',\'' + eachDCExpr.SVMXC__Source_Field_Name__c + '\'';
                                INTF_DataSync.logSOQL(intMethodCount , 'Select LastModifiedDate, ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds OR ID IN:setNewEventWhatIds');
                                for(sobject sObj : Database.query('Select LastModifiedDate, ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds OR ID IN:setNewEventWhatIds'))
                                {
                                    datetime dtLMDOfRltdRec = datetime.valueOf(sObj.get('LastModifiedDate'));
                                    system.debug(LoggingLevel.Debug, 'dtLMDOfRltdRec = ' + dtLMDOfRltdRec + '; Last Sync Time = ' + dtLastSynchTime);
                                    system.debug(LoggingLevel.Debug, 'Source Field Value = ' + sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c));
                                    if(setNewEventWhatIds.contains(String.valueOf(sObj.get('Id'))) || dtLMDOfRltdRec > dtLastSynchTime)
                                    //if(setNewEventWhatIds.contains(String.valueOf(sObj.get('Id'))))
                                    {
                                        if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null)
                                        {
                                            if(strNewReferenceFieldIds != '')
                                                strNewReferenceFieldIds += ',';
                                            strNewReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';
                                        }
                                    }
                                    else
                                    {
                                        system.debug(LoggingLevel.Debug, 'In Else');
                                        if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null)
                                        {
                                            if(strReferenceFieldIds != '')
                                                strReferenceFieldIds += ',';
                                            strReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';
                                        }
                                        /*datetime dt = datetime.valueOf(sObj.get('LastModifiedDate'));
                                        if(dt > dtLastSynchTime)
                                            strTimeClause = ' ';*/
                                    }
                                }
                                if(strReferenceFieldIds == '')
                                    strReferenceFieldIds = '\'DummyListOfIds1\'';
                                if(strNewReferenceFieldIds == '')
                                    strNewReferenceFieldIds = '\'DummyListOfIds1\'';
                                     
                                strCriteria = strCriteria.replace(strObjNameAndField, strReferenceFieldIds);
                                strCriteriaForNewEvents = strCriteriaForNewEvents.replace(strObjNameAndField, strNewReferenceFieldIds);
                                system.debug(LoggingLevel.WARN, 'strCriteria = ' + strCriteria);
                                system.debug(LoggingLevel.WARN, 'strCriteriaForNewEvents = ' + strCriteriaForNewEvents);
                                
                                //fix for incremental data sync --> if there are no new event Ids, include the last sync time clause
                                //if(strNewReferenceFieldIds == '\'DummyListOfIds1\''){
                                        //strCriteriaForNewEvents = ' ( ' + strCriteriaForNewEvents + ' ) ' + strTimeClause;
                                //}
                                system.debug(LoggingLevel.WARN, 'Check for new events strCriteriaForNewEvents = ' + strCriteriaForNewEvents);  
                            }
                            else
                            {
                                //criteria exists in variable strCriteria.
                            }
                        }
                    }
                    else
                    {
                        strCriteria = '';
                        strCriteriaForNewEvents = '';
                    }
                    if(eachDCrec.SVMXC__Ownership_Type__c == 'My Records')
                    {
                        if(strCriteria != '')
                        {
                            strCriteria += ' and ';
                            strCriteriaForNewEvents += ' and ';
                        }
                        else
                        {
                            strCriteria += '(';
                            strCriteriaForNewEvents += '(';
                        }
                        strCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
                        strCriteriaForNewEvents += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
                        
                    }
                    
                    system.debug(LoggingLevel.WARN, 'LastModifiedDate of Each DC Record = ' + eachDCrec.LastModifiedDate + ', Last Sync Time = ' + dtLastSynchTime);
                    if(dtLastSynchTime != null && (eachDCrec.LastModifiedDate > dtLastSynchTime || eachDCrec.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSynchTime))
                        strTimeClause = ' ';
                    /*if(setNewEventWhatIds != null && setNewEventWhatIds.size() > 0)
                        strCriteria += strTimeClause + ') OR ' + strCriteriaForNewEvents + ')';
                    else
                        strCriteria += strTimeClause + ' )';*/
                    strCriteria += strTimeClause + ') ';  
                    strCriteria += ' OR ' + strCriteriaForNewEvents + ')';
                    system.debug(LoggingLevel.WARN, 'Final Criteria = ' + strCriteria);
                    responseEachDCObject.value = strCriteria;
                    lstAllDCObjects.add(responseEachDCObject);
                }
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getAdvDownloadCriteriaDef');
        return lstAllDCObjects;
    }
    
    public Set<String> getNewEventWhatIDs(DateTime dtLastSynchTime)
    {
        Set<String> setWhatIds = new Set<String>();
        Datetime dtToDate, dtFromDate, dtMovingDate;
        Datetime currentTime = Datetime.now();
        Id idGrpProfile = (new Sync_Utility()).getGroupProfileId(null, false);
        if(idGrpProfile != null)
        {
            for(SVMXC__ServiceMax_Config_Data__c objConfigData : [select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Mobile Configuration' AND (SVMXC__Display_Type__c = 'Synchronization To Get Events' OR  SVMXC__Display_Type__c = 'Synchronization To Remove Events') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile])
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
                    dtMovingDate = dtLastSynchTime + intValue + 1;
                }
            }
            
            for(Event evt : [select Id, WhatId from Event where ((StartDateTime >= :dtMovingDate and EndDateTime <= :dtToDate) OR (LastModifiedDate >= :dtLastSynchTime and ((StartDateTime >= :dtFromDate and EndDateTime <= :dtToDate) OR (StartDateTime <= :dtFromDate and EndDateTime >= :dtToDate)))) and OwnerId = :UserInfo.getUserId() AND WhatId != NULL])
            {
                setWhatIds.add(evt.WhatId);
            }
        }
        return setWhatIds;
    }
    
    public Set<String> getNewSVMXEventWhatIDs(DateTime dtLastSynchTime)
    {
        Set<String> setWhatIds = new Set<String>();
        Datetime dtToDate, dtFromDate, dtMovingDate;
        Datetime currentTime = Datetime.now();
        String strUserId = UserInfo.getUserId();
        Id idGrpProfile = (new Sync_Utility()).getGroupProfileId(null, false);
        if(idGrpProfile != null)
        {
            for(SVMXC__ServiceMax_Config_Data__c objConfigData : [select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Mobile Configuration' AND (SVMXC__Display_Type__c = 'Synchronization To Get Events' OR  SVMXC__Display_Type__c = 'Synchronization To Remove Events') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile])
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
                    dtMovingDate = dtLastSynchTime + intValue + 1;
                }
            }
            
            for(SVMXC__SVMX_Event__c evt : [select Id, SVMXC__WhatId__c from SVMXC__SVMX_Event__c where (((SVMXC__StartDateTime__c >= :dtMovingDate AND SVMXC__StartDateTime__c <= :dtToDate) OR (SVMXC__EndDateTime__c >= :dtMovingDate AND SVMXC__EndDateTime__c <= :dtToDate)) OR (LastModifiedDate >= :dtLastSynchTime and ((SVMXC__StartDateTime__c >= :dtFromDate and SVMXC__EndDateTime__c <= :dtToDate) OR (SVMXC__StartDateTime__c <= :dtFromDate and SVMXC__EndDateTime__c >= :dtToDate)))) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
            {
                setWhatIds.add(evt.SVMXC__WhatId__c);
            }
        }
        return setWhatIds;
    }
    
    public String getIBIds(Set<String> setIsModifiedFlag, DateTime dtLastSyncTime, String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getIBIds');
        String strQuery = '', strWhereClause = '', strWhereOwnerClause = '', strCurrTechLocId = '';
        Id IdgrpProfile = (new Sync_Utility()).getGroupProfileId(null, false);
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
        for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
        {
            if(eachTech.SVMXC__Inventory_Location__c != null)
                strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
        }
        if(IdgrpProfile != null)
        {
            String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c,  SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c = \'SVMXC__Installed_Product__c\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =:IdgrpProfile';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            strMobConfQuery += ' LIMIT 1';
            system.debug(LoggingLevel.WARN,'Query formed for getIBIds = '+strMobConfQuery);
        
            INTF_DataSync.logSOQL(intMethodCount, strMobConfQuery);
            for(SVMXC__ServiceMax_Config_Data__c  objCnfgData : Database.Query(strMobConfQuery))
            {
                strQuery = 'Select Id from ' + objCnfgData.SVMXC__Object_Name__c ;
                if(objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                    strWhereClause += ' where ((' + objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                if(String.valueOf(objCnfgData.SVMXC__Ownership_Type__c) == 'My Records')
                {
                    if(strWhereClause != '')
                        strWhereOwnerClause += ' and ';
                    else    
                        strWhereOwnerClause += ' where (';
                    
                    strWhereOwnerClause += ' OwnerId = \'' + UserInfo.getUserId() + '\' )';  
                }
                else
                {
                    if(strWhereClause != '')
                        strWhereClause += ')';  
                }
            
                if(dtLastSyncTime != null && (objCnfgData.LastModifiedDate > dtLastSyncTime || objCnfgData.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSyncTime))
                {
                    setIsModifiedFlag.add('true');
                }
                strQuery += strWhereClause + strWhereOwnerClause;
            }
        }
        strQuery = strQuery.replace('SVMX.USERTRUNK', strCurrTechLocId);
        system.debug(LoggingLevel.WARN, 'Query = ' + strQuery + '; isModified = ' + setIsModifiedFlag);
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getIBIds');
        return strQuery;
    }
    
    public Set<String> getWOIds(Set<String> setIsModifiedFlag, DateTime dtLastSyncTime, Set<String> setCurrencyISOCodes, String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getWOIds');
        String strCurrTechLocId = '';
        Set<String> setWOIds = new Set<String>();
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
        for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
        {
            if(eachTech.SVMXC__Inventory_Location__c != null)
                strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
        }
        Id grpProfileId = (new Sync_Utility()).getGroupProfileId(null, false);
        if(grpProfileId != null)
        {
            String strQuery = '', strWhereClause = '', strWhereOwnerClause = '';
           //Get device specific mobile configuration
            String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c,  SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c = \'SVMXC__Service_Order__c\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            strMobConfQuery += ' LIMIT 1';
            system.debug(LoggingLevel.WARN,'Query formed for getWOIds = '+strMobConfQuery);
        
            INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
            
            for(SVMXC__ServiceMax_Config_Data__c objCnfgData : Database.Query(strMobConfQuery))
            {
                if(UserInfo.isMultiCurrencyOrganization())
                {   
                    strQuery = 'Select Id, CurrencyIsoCode from ' + objCnfgData.SVMXC__Object_Name__c;
                }
                else
                {
                    strQuery = 'Select Id from ' + objCnfgData.SVMXC__Object_Name__c;
                }
                if(objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                    strWhereClause += ' where ( ' + objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ' ) ';
                if(String.valueOf(objCnfgData.SVMXC__Ownership_Type__c) == 'My Records')
                {
                    if(strWhereClause != '')
                        strWhereOwnerClause += ' and ';
                    else    
                        strWhereOwnerClause += ' where ';
                        
                    strWhereOwnerClause += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';  
                }
                
                if(dtLastSyncTime != null && (objCnfgData.LastModifiedDate > dtLastSyncTime || objCnfgData.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSyncTime))
                {
                    setIsModifiedFlag.add('true');
                }
                strQuery += strWhereClause + strWhereOwnerClause;
                strQuery = strQuery.replace('SVMX.USERTRUNK', strCurrTechLocId);
                system.debug(LoggingLevel.WARN, 'WO in DC Query = ' + strQuery);
                if(UserInfo.isMultiCurrencyOrganization())
                {
                    INTF_DataSync.logSOQL(intMethodCount,strQuery );
                    for(sObject sobj : Database.query(strQuery))
                    {
                        setWOIds.add(sobj.Id);
                        setCurrencyISOCodes.add(String.valueOf(sobj.get('CurrencyIsoCode')));
                    }
                }
                else
                {
                    INTF_DataSync.logSOQL(intMethodCount,strQuery );
                    for(sObject sobj : Database.query(strQuery))
                        setWOIds.add(sobj.Id);
                }
                
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getWOIds');
        return setWOIds;
    }

    public Set<String> getEventRelatedWOIDs(String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getEventRelatedWOIDs');
        Set<String> setWhatIds = new Set<String>();
        Datetime dtToDate, dtFromDate;
        Datetime currentTime = Datetime.now();
        String strUserId = UserInfo.getUserId();
        Id idGrpProfile = (new Sync_Utility()).getGroupProfileId(null, false);
        if(idGrpProfile != null)
        {
            String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            system.debug(LoggingLevel.WARN,'Query formed for getEventRelatedWOIDs = '+strMobConfQuery);
        
            INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
            for(SVMXC__ServiceMax_Config_Data__c objConfigData : Database.Query(strMobConfQuery))
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
                }
            }
            INTF_DataSync.logSOQL(intMethodCount, 'Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId AND What.Id != NULL');
            for(Event evt :[Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId AND What.Id != NULL ])
            {
                setWhatIds.add(evt.What.Id);
            }     
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'getEventRelatedWOIDs' );
        return setWhatIds;
    }
    
    public Set<String> getSVMXEventRelatedWOIDs(String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getSVMXEventRelatedWOIDs');
        Set<String> setWhatIds = new Set<String>();
        Datetime dtToDate, dtFromDate;
        Datetime currentTime = Datetime.now();
        String strUserId = UserInfo.getUserId();
        Id idGrpProfile = (new Sync_Utility()).getGroupProfileId(null, false);
        if(idGrpProfile != null)
        {
            String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            system.debug(LoggingLevel.WARN,'Query formed for getSVMXEventRelatedWOIDs = '+strMobConfQuery);
        
            INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
            for(SVMXC__ServiceMax_Config_Data__c objConfigData : Database.Query(strMobConfQuery))
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
                }
            }
            INTF_DataSync.logSOQL(intMethodCount,'Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
            for(SVMXC__SVMX_Event__c evt :[Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
            {
                setWhatIds.add(evt.SVMXC__WhatId__c);
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getSVMXEventRelatedWOIDs');
        return setWhatIds;
    }
    
    public Set<String> getSFandSVMXEventRelatedWOIDs(String idGrpProfile, String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getSFandSVMXEventRelatedWOIDs');
        Set<String> setWhatIds = new Set<String>();
        Datetime dtToDate, dtFromDate;
        Datetime currentTime = Datetime.now();
        String strUserId = UserInfo.getUserId();
        
        if(idGrpProfile != null)
        {
            String strMobConfQuery  = 'select id, SVMXC__Display_Type__c, SVMXC__Internal_value__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Synchronization To Get Events\' OR  SVMXC__Display_Type__c = \'Synchronization To Remove Events\') AND SVMXC__Access_Configuration_Profile__c =:idGrpProfile';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            system.debug(LoggingLevel.WARN,'Query formed for getSFandSVMXEventRelatedWOIDs = '+strMobConfQuery);
        
            INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
            
            for(SVMXC__ServiceMax_Config_Data__c objConfigData : Database.Query(strMobConfQuery))
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
                }
            }
            INTF_DataSync.logSOQL(intMethodCount, 'Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId and WhatId != null');
            for(Event evt :[Select What.Id from Event where ((StartDateTime <= :dtToDate AND StartDateTime >= :dtFromDate) OR (EndDateTime <= :dtToDate AND EndDateTime >= :dtFromDate) OR (StartDateTime <= :dtFromDate AND EndDateTime >= :dtToDate)) and OwnerId = :strUserId and WhatId != null])
                setWhatIds.add(evt.What.Id);
            
            INTF_DataSync.logSOQL(intMethodCount,'Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null');
            for(SVMXC__SVMX_Event__c evt :[Select SVMXC__WhatId__c from SVMXC__SVMX_Event__c where ((SVMXC__StartDateTime__c <= :dtToDate AND SVMXC__StartDateTime__c >= :dtFromDate) OR (SVMXC__EndDateTime__c <= :dtToDate AND SVMXC__EndDateTime__c >= :dtFromDate) OR (SVMXC__StartDateTime__c <= :dtFromDate AND SVMXC__EndDateTime__c >= :dtToDate)) and SVMXC__Technician__r.SVMXC__Salesforce_User__c = :strUserId and SVMXC__WhatId__c != null])
                setWhatIds.add(evt.SVMXC__WhatId__c);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getSFandSVMXEventRelatedWOIDs');
        return setWhatIds;
    }
    
    public Set<String> getProductIds(Boolean isModified, DateTime dtLastSyncTime, String strDevConfId)
    {
        String strCurrTechLocId = '';
        Set<String> setProductIds = new Set<String>();
        Id grpProfileId = (new Sync_Utility()).getGroupProfileId(null, false);
        for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
        {
            if(eachTech.SVMXC__Inventory_Location__c != null)
                strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
        }
        
        if(grpProfileId != null)
        {
            String strQuery = '', strWhereClause = '', strWhereOwnerClause = '';
            //Get device specific mobile configuration
            String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c,  SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c = \'Product2\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            strMobConfQuery += ' LIMIT 1';
            system.debug(LoggingLevel.WARN,'Query formed for getProductIds = '+strMobConfQuery);
        
            for(SVMXC__ServiceMax_Config_Data__c  objCnfgData : Database.Query(strMobConfQuery) )
            {
                strQuery = 'Select Id from ' + objCnfgData.SVMXC__Object_Name__c ;
                if(objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                    strWhereClause += ' where ( ' + objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ' ) ';
                if(String.valueOf(objCnfgData.SVMXC__Ownership_Type__c) == 'My Records')
                {
                    if(strWhereClause != '')
                        strWhereOwnerClause += ' and ';
                    else    
                        strWhereOwnerClause += ' where';
                        
                    strWhereOwnerClause += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';  
                }
                
                if(dtLastSyncTime != null && (objCnfgData.LastModifiedDate > dtLastSyncTime || objCnfgData.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSyncTime))
                {
                    isModified = true;
                }
                strWhereClause = strWhereClause.replace('SVMX.USERTRUNK', strCurrTechLocId);
                system.debug(LoggingLevel.WARN, 'Query = ' + strQuery + strWhereClause + strWhereOwnerClause);
                for(sObject sobj : Database.query(strQuery + strWhereClause + strWhereOwnerClause))
                    setProductIds.add(sobj.Id);
            }
        }
        return setProductIds;
    }
    
    public String getProductIdQuery(Set<String> setIsModifiedFlag, DateTime dtLastSyncTime, String strDevConfId, Set<String> setWhatIds, Set<String> setNewEventWhatIds, List<String> modifiedEventProdIds)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getProductIdQuery');
        String strQuery = '', strWhereClause = '', strWhereOwnerClause = '', strCurrTechLocId = '';
        String strFinalCriteria = '', strQueryForNewEvents = '';
        
        Id grpProfileId = (new Sync_Utility()).getGroupProfileId(null, false);
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
        for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
        {
            if(eachTech.SVMXC__Inventory_Location__c != null)
                strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
        }
        
        if(grpProfileId != null)
        {
            //Get device specific mobile configuration
            String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Display_Type__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c,  SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c = \'Product2\' AND RecordType.Name = \'Mobile Configuration\' AND (SVMXC__Display_Type__c = \'Advanced Download Criteria\' OR SVMXC__Display_Type__c = \'Download Criteria\' )  AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            system.debug(LoggingLevel.WARN,'Query formed for getProductIds = '+strMobConfQuery);
        
            INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
            for(SVMXC__ServiceMax_Config_Data__c  objCnfgData : Database.Query(strMobConfQuery) )
            {
                strQuery = 'Select Id from ' + objCnfgData.SVMXC__Object_Name__c ;
                
                String strCriteria = '', strCriteriaForNewEvents = '';
                
                if(objCnfgData.SVMXC__Display_Type__c == 'Download Criteria'){
                    if(objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null){
                        strCriteria = '((' + objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                    }
                    if(objCnfgData.SVMXC__Ownership_Type__c == 'My Records'){
                        if(strCriteria != '')
                            strCriteria += ' AND ';
                        else
                            strCriteria += '(';
                        strCriteria += 'OwnerId = \'' + UserInfo.getUserId() + '\' ';
                    }
                    if(strCriteria != '')
                            strCriteria += ')';
                            
                    strCriteria = strCriteria.replace('SVMX.CURRENTUSERID15', UserInfo.getUserId().substring(0,15));
                    strCriteria = strCriteria.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());    
                    strCriteria = strCriteria.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));  
                    strCriteria = strCriteria.replace('SVMX.USERTRUNK', strCurrTechLocId);  
                }
                
                if(objCnfgData.SVMXC__Display_Type__c == 'Advanced Download Criteria'){
                        if(objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0){
                            strCriteria = '((' + objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                            strCriteriaForNewEvents = '((' + objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ')';
                            
                            for(SVMXC__ServiceMax_Config_Data__c eachDCExpr : [select id, SVMXC__Display_Type__c, SVMXC__Object_Name2__c, SVMXC__Source_Field_Name__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Rule__c =: objCnfgData.SVMXC__Dispatch_Process__c ORDER BY SVMXC__Sequence__c ASC]){
                                String strObjNameAndField = '';
                                if((eachDCExpr.SVMXC__Display_Type__c == 'REFERENCE' || eachDCExpr.SVMXC__Display_Type__c == 'ID') && eachDCExpr.SVMXC__Object_Name2__c != null){
                                    String strReferenceFieldIds = '', strNewReferenceFieldIds = '';
                                    strObjNameAndField += '\':' + eachDCExpr.SVMXC__Object_Name2__c + '\',\'' + eachDCExpr.SVMXC__Source_Field_Name__c + '\'';
                                    for(sobject sObj : Database.query('Select LastModifiedDate, ' + eachDCExpr.SVMXC__Source_Field_Name__c + ' from ' + eachDCExpr.SVMXC__Object_Name2__c + ' where Id IN :setWhatIds OR ID IN: setNewEventWhatIds')){
                                        datetime dtLMDOfRltdRec = datetime.valueOf(sObj.get('LastModifiedDate'));
                                        if(setNewEventWhatIds.contains(String.valueOf(sObj.get('Id'))) || dtLMDOfRltdRec > dtLastSyncTime){
                                                if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null){
                                                if(strNewReferenceFieldIds != '')
                                                    strNewReferenceFieldIds += ',';
                                                strNewReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';
                                             }
                                        }else{
                                            if(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c) != null){
                                                if(strReferenceFieldIds != '')
                                                    strReferenceFieldIds += ',';
                                                strReferenceFieldIds += '\'' + String.valueOf(sObj.get(eachDCExpr.SVMXC__Source_Field_Name__c)) + '\'';   
                                            }
                                        }
                                    }
                                    if(strReferenceFieldIds == '')
                                            strReferenceFieldIds = '\'DummyListOfIds1\'';
                                    if(strNewReferenceFieldIds == '')
                                            strNewReferenceFieldIds = '\'DummyListOfIds1\'';        
                                    
                                 strCriteria = strCriteria.replace(strObjNameAndField, strReferenceFieldIds);
                                 strCriteriaForNewEvents = strCriteriaForNewEvents.replace(strObjNameAndField, strNewReferenceFieldIds);
                                 system.debug(LoggingLevel.WARN, 'strCriteria = ' + strCriteria); 
                                 system.debug(LoggingLevel.WARN, 'strCriteriaForNewEvents = ' + strCriteriaForNewEvents);  
                                }
                            }
                        }else{
                            strCriteria = '';
                        }
                        
                        if(objCnfgData.SVMXC__Ownership_Type__c == 'My Records'){
                        if(strCriteria != ''){
                            strCriteria += ' AND ';
                            strCriteriaForNewEvents += ' AND ';
                        }else{
                            strCriteria += '(';
                            strCriteriaForNewEvents += '(';
                        }    
                        strCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
                        strCriteriaForNewEvents += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
                     }
                     strCriteria += ') ';    
                     strCriteriaForNewEvents += ') ';  
                     system.debug(LoggingLevel.WARN, 'Final ADC Criteria = ' + strCriteria);
                     system.debug(LoggingLevel.WARN, 'Final new event Criteria = ' + strCriteriaForNewEvents);
                }
                
                if(strFinalCriteria != '' && strCriteria != '')
                        strFinalCriteria += ' OR ';
                strFinalCriteria += strCriteria;
                
                if(dtLastSyncTime != null && (objCnfgData.LastModifiedDate > dtLastSyncTime || (objCnfgData.SVMXC__Dispatch_Process__c != null && objCnfgData.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSyncTime))){
                    //dtLastSynchTime = NULL;
                    //strTimeClause = ' ';
                    setIsModifiedFlag.add('true');
                }
                
                if(strCriteriaForNewEvents != '' && setNewEventWhatIds.size() > 0){
                        strQueryForNewEvents = 'Select Id from ' + objCnfgData.SVMXC__Object_Name__c +' WHERE '+strCriteriaForNewEvents;
                }
                system.debug(LoggingLevel.WARN, 'strQueryForNewEvents = ' + strQueryForNewEvents);
             }
             
             if(strFinalCriteria != ''){
                strFinalCriteria = ' WHERE ' + strFinalCriteria;
             }
             system.debug(LoggingLevel.WARN, 'Query = ' + strQuery + strFinalCriteria + '; isModified = ' + setIsModifiedFlag);
        }
        
        if(strQueryForNewEvents != ''){
                for(Product2 eachProd: Database.Query(strQueryForNewEvents)){
                    modifiedEventProdIds.add(eachProd.Id);
                }
        }
        
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getProductIdQuery');
        return strQuery + strFinalCriteria;
    }
    
    public map<String, String> getProductQueryFromDC(Set<String> setIsModifiedFlag, DateTime dtLastSyncTime, String grpProfileId, String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getProductQueryFromDC');
        map<String, String> mapProductToCriteria = new map<String, String>(); 
        String strWhereClause = '', strCurrTechLocId = '';
        INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
        for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true and SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
        {
            if(eachTech.SVMXC__Inventory_Location__c != null)
                strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
        }
        if(grpProfileId != null)
        {
            //Get device specific mobile configuration
            String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c,  SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c = \'Product2\' AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            strMobConfQuery += ' LIMIT 1';
            system.debug(LoggingLevel.WARN,'Query formed for getProductIds = '+strMobConfQuery);
        
            INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);
            
            //for(SVMXC__ServiceMax_Config_Data__c  objCnfgData : [select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c,  SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where SVMXC__Object_Name__c = 'Product2' AND RecordType.Name = 'Mobile Configuration' AND SVMXC__Display_Type__c != 'Advanced Download Criteria' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId limit 1])
            for(SVMXC__ServiceMax_Config_Data__c  objCnfgData : Database.Query(strMobConfQuery))
            {
                if(objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                    strWhereClause = objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c;
                
                if(dtLastSyncTime != null && (objCnfgData.LastModifiedDate > dtLastSyncTime || objCnfgData.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSyncTime))
                    setIsModifiedFlag.add('true');
                    
                system.debug(LoggingLevel.WARN, 'strWhereClause = ' + strWhereClause + '; isModified = ' + setIsModifiedFlag);
                strWhereClause = strWhereClause.replace('SVMX.USERTRUNK', strCurrTechLocId);
                mapProductToCriteria.put('Product2', strWhereClause);
            }
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getProductQueryFromDC');
        return mapProductToCriteria;
    }
        
    public Map<String, String> getPricebookIdQuery(Set<String> setIsModifiedFlag, DateTime dtLastSyncTime, Id grpProfileId, String strDevConfId)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getPricebookIdQuery');
        String strQuery = '', strWhereClause = '';
        Map<String, String> mapObjToQry = new Map<String, String>();
        String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c,  SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.LastModifiedDate, SVMXC__Ownership_Type__c, LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where (SVMXC__Object_Name__c = \'Pricebook2\' OR SVMXC__Object_Name__c = \'SVMXC__Service_Pricebook__c\') AND RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c != \'Advanced Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId';
        if(strDevConfId != NULL && strDevConfId != ''){
            strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
        }
        strMobConfQuery += ' LIMIT 2';
        system.debug(LoggingLevel.WARN,'Query formed for getPricebookIdQuery = '+strMobConfQuery);
        
        INTF_DataSync.logSOQL(intMethodCount,strMobConfQuery);

        for(SVMXC__ServiceMax_Config_Data__c  objCnfgData :  Database.Query(strMobConfQuery))
        {
            strQuery = 'Select Id from ' + objCnfgData.SVMXC__Object_Name__c ;
            if(objCnfgData.SVMXC__Dispatch_Process__c != null && objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null && objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c.length() > 0)
                strWhereClause = ' where ( ' + objCnfgData.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ' ) ';
            if(String.valueOf(objCnfgData.SVMXC__Ownership_Type__c) == 'My Records')
            {
                if(strWhereClause != '')
                    strWhereClause += ' and ';
                else    
                    strWhereClause += ' where';
                    
                strWhereClause += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';  
            }
            
            if(dtLastSyncTime != null && (objCnfgData.LastModifiedDate > dtLastSyncTime || objCnfgData.SVMXC__Dispatch_Process__r.LastModifiedDate > dtLastSyncTime))
            {
                setIsModifiedFlag.add('true');
            }
            mapObjToQry.put(objCnfgData.SVMXC__Object_Name__c, strQuery + strWhereClause);
            system.debug(LoggingLevel.WARN, 'mapObjToQry = ' + mapObjToQry.size() + '; mapObjToQry = ' + mapObjToQry);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'getPricebookIdQuery');
        return mapObjToQry;
    }
    
    public class ObjectNameID
    {
        public Boolean Error;
        public DMLException e;
        public String localId;
        public String sfId;
        public String objName;
        public List<String> objectFieldNames;
        public Map<String, String> fieldUpdateable = new Map<String, String>();
        public Map<String, String> fieldCreateable = new Map<String, String>();
        
        
        public ObjectNameID(String locId)
        {
            this.localId = locId;
        }
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse submitDocument(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('submitDocument');
        system.debug('==Request=: ' + inputRequest);
        INTF_DataUtilityServices.lstSignatureIds = new List<string>();
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        List<INTF_WebServicesDef.SVMXMap> reqValueMap = inputRequest.valueMap;
        OPDOC_DeliveryImpl opDocDelVar = new OPDOC_DeliveryImpl();
        List<string> reqLstHTMLIds = new List<string>();
        List<string> reqLstSigIds = new List<string>();
        res.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        List<string> resLstHTMLIds = new List<string>();
        res.eventName = inputRequest.eventName;
        res.eventType = inputRequest.eventType;
        res.success = true;
        try
        {
            for(INTF_WebServicesDef.SVMXMap vm : reqValueMap)
            {
                if(vm.key == 'HTMLID' && vm.values != null && vm.values.size() > 0)
                    reqLstHTMLIds = vm.values;
                else if(vm.key == 'SIGNATURE' && vm.values != null && vm.values.size() > 0)
                    reqLstSigIds = vm.values;
            }
            
            INTF_DataSync.logSOQL(intMethodCount,'Select Id, Body, Name from Attachment where Id In: reqLstHTMLIds');
            List<Attachment> lstHTMLAttachments = [Select Id, Body, Name from Attachment where Id In: reqLstHTMLIds];
            integer removeIndex = 0;
            for(Attachment att: lstHTMLAttachments)
            {
                if(att.Name.contains('.pdf'))
                {
                    reqLstHTMLIds.remove(removeIndex);
                    resLstHTMLIds.add(att.Id);
                }
                removeIndex++;
            }
            INTF_WebServicesDef.SVMXMap HTMLIdsVM = new INTF_WebServicesDef.SVMXMap();
            HTMLIdsVM.key = 'HTMLID';
            HTMLIdsVM.values = resLstHTMLIds;
            res.valueMap.add(HTMLIdsVM);
            
            opDocDelVar.offlineSubmitDocuments(reqLstHTMLIds, reqLstSigIds);
        }
        catch(exception ex)
        {
            res.success = false;
            res.message = ex.getMessage();
        }
        
        INTF_WebServicesDef.SVMXMap sigIdsVM = new INTF_WebServicesDef.SVMXMap();
        sigIdsVM.key = 'SIGNATURE';
        sigIdsVM.values = INTF_DataUtilityServices.lstSignatureIds;
        res.valueMap.add(sigIdsVM);
        
        List<string> deleteIds = new List<string>();
        INTF_DataSync.logSOQL(intMethodCount,'Select Id, Body, Name from Attachment where (Id In: reqLstSigIds OR Id IN: reqLstHTMLIds) AND IsDeleted = true ALL ROWS');
        for(Attachment attachToDelete : [Select Id, Body, Name from Attachment where (Id In: reqLstSigIds OR Id IN: reqLstHTMLIds) AND IsDeleted = true ALL ROWS])
        {
            deleteIds.add(attachToDelete.Id);
        }
        
        INTF_WebServicesDef.SVMXMap delIdsVM = new INTF_WebServicesDef.SVMXMap();
        delIdsVM.key = 'DELETE_ID';
        delIdsVM.values = deleteIds;
        res.valueMap.add(delIdsVM);
        INTF_DataSync.logMethodEndTS(intMethodCount,'submitDocument');
        return res; 
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse generatePdf(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('generatePdf');
        INTF_WebServicesDef.INTF_SFMResponse res = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_DataUtilityServices.lstSignatureIds = new List<string>();
        List<INTF_WebServicesDef.SVMXMap> reqValueMap = inputRequest.valueMap;
        OPDOC_DeliveryImpl opDocDelVar = new OPDOC_DeliveryImpl();
        List<string> reqLstHTMLIds = new List<string>();
        List<string> reqLstSigIds = new List<string>();
        res.eventName = inputRequest.eventName;
        res.eventType = inputRequest.eventType;
        
        res.success = true;
        try
        {
            for(INTF_WebServicesDef.SVMXMap vm : reqValueMap)
            {
                if(vm.key == 'HTMLID' && vm.values != null && vm.values.size() > 0)
                    reqLstHTMLIds = vm.values;
                else if(vm.key == 'SIGNATURE' && vm.values != null && vm.values.size() > 0)
                    reqLstSigIds = vm.values;
            }
            opDocDelVar.offlineCreatePDF(reqLstHTMLIds, reqLstSigIds);
        }
        catch(exception ex)
        {
            res.success = false;
            res.message = ex.getMessage();
        }
        INTF_WebServicesDef.SVMXMap HTMLIdsVM = new INTF_WebServicesDef.SVMXMap();
        HTMLIdsVM.key = 'HTMLID';
        HTMLIdsVM.values = INTF_DataUtilityServices.lstSignatureIds;
        res.valueMap.add(HTMLIdsVM);
        
        INTF_WebServicesDef.SVMXMap sigIdsVM = new INTF_WebServicesDef.SVMXMap();
        sigIdsVM.key = 'SIGNATURE';
        sigIdsVM.values = reqLstSigIds;
        res.valueMap.add(sigIdsVM);
        INTF_DataSync.logMethodEndTS(intMethodCount,'generatePdf');
        return res; 
    }
    
    public string getsettingIPAD018SET012()
    {
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        List<String> lstSettingId = new list<String>();
        lstSettingId.add('SET012');
        Map<String, String> mapSettingsForIPAD018 = new Map<String, String>();
        mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
        system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
        if(mapSettingsForIPAD018.containskey('SET012') && mapSettingsForIPAD018.get('SET012') != null && mapSettingsForIPAD018.get('SET012').length() > 0)
        {
            return mapSettingsForIPAD018.get('SET012');
        }
        else{
            return null;
        }
    }
    
    public boolean isLimitReached(Integer intLimitPercent)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('isLimitReached');
        if(intLimitPercent <= 0)
            intLimitPercent = 70;
            
        system.debug(LoggingLevel.WARN, 'Setting value for Limits = ' + intLimitPercent);
        integer intCPUTimeLimit = intLimitPercent * Limits.getLimitCpuTime()/100;
        integer intHeapLimit = intLimitPercent * Limits.getLimitHeapSize()/100;
        integer intQueriesLimit = intLimitPercent *  Limits.getLimitQueries()/100;
        system.debug(LoggingLevel.WARN, 'CPU Limit = ' + intCPUTimeLimit + '; Heap Limit = ' + intHeapLimit + '; Query Limit = ' + intQueriesLimit);
        //system.debug(LoggingLevel.WARN, 'CPU Limit used = ' + Limits.getCpuTime() + '; Heap Limit Used = ' + Limits.getHeapSize() + '; Query used = ' + Limits.getQueries());
        if(Limits.getCpuTime() >= intCPUTimeLimit || Limits.getHeapSize() >= intHeapLimit || Limits.getQueries() >= intQueriesLimit)
        {
            INTF_DataSync.logMethodEndTS(intMethodCount, 'isLimitReached');
            return true;
        }
        INTF_DataSync.logMethodEndTS(intMethodCount, 'isLimitReached');
        return false;
    }
    
    //New method for downloading Download Criteria records during Initial Sync and also can be used during Incremental sync in future ()
    public INTF_WebServicesDef.INTF_SFMResponse getDownloadCriteriaRecordIds(INTF_WebServicesDef.INTF_SFMRequest request)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('getDownloadCriteriaRecordIds');
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        if(request.eventName == 'SYNC_DOWNLOAD_CRITERIA')
        {
            Integer intLimit = 35000;
            Datetime dtLastSynchTime = null;
            Set<String> setExecObjects = new Set<String>();
            Set<String> setInAccessibleObjs = new Set<String>();
            List<String> lstSettingId = new list<String>{'SET006'};
            Map<String, String> mapObjectAndCriteria = new Map<String, String>();
            Map<String, String> mapSettingsForIPAD018 = new Map<String, String>();
            Id grpProfileId = (new Sync_Utility()).getGroupProfileId(null, true);
            Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            String strPartialExecObjName = '', strLastIdForPartialExcObj = '', strIsDeletedField = '', strCurrTechLocId = '';
            
            mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
                
            if(mapSettingsForIPAD018 != null && mapSettingsForIPAD018.size() > 0 && mapSettingsForIPAD018.containskey('SET006') && mapSettingsForIPAD018.get('SET006') != null)
                intLimit = Integer.valueOf(mapSettingsForIPAD018.get('SET006'));
            else
                intLimit = 35000;
                  
            for(INTF_WebServicesDef.SVMXMap eachReqParam : request.valueMap)
            {
                if(eachReqParam.key == 'LAST_SYNC_TIME' && eachReqParam.value != null && eachReqParam.value != '')
                {
                    dtLastSynchTime = Datetime.valueOf(eachReqParam.value);
                }
                else if(eachReqParam.key == 'PARTIAL_EXECUTED_OBJECT' && eachReqParam.value != null && eachReqParam.value.length() > 0)
                {
                    strPartialExecObjName = eachReqParam.value;
                    strLastIdForPartialExcObj = eachReqParam.values[eachReqParam.values.size() - 1];
                }
            }
            
            if(request.values != null && request.values.size() > 0)
            {
                setExecObjects.addAll(request.values);
            }
            INTF_DataSync.logSOQL(intMethodCount, 'Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true AND SVMXC__Inventory_Location__c != null AND SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1');
            for(SVMXC__Service_Group_Members__c eachTech : [Select Id, SVMXC__Inventory_Location__c from SVMXC__Service_Group_Members__c where SVMXC__Active__c = true AND SVMXC__Inventory_Location__c != null AND SVMXC__Salesforce_User__c = :UserInfo.getUserId() limit 1])
            {
                strCurrTechLocId = String.valueOf(eachTech.SVMXC__Inventory_Location__c);
            }
            system.debug(LoggingLevel.WARN, 'Settings = ' + mapSettingsForIPAD018 + '; Technician Location Id = ' + strCurrTechLocId + '; Limit = ' + intLimit);
    
            allObjs = Schema.getGlobalDescribe();
            for(String objName : allObjs.keySet())
            {
                try
                {
                    if(!allObjs.get(objName).getDescribe().isAccessible())
                        setInAccessibleObjs.add(allObjs.get(objName).getDescribe().getName().toLowerCase());
                }
                catch(Exception ex)
                {
                    system.debug(LoggingLevel.WARN, 'Exception during describing Object ' + objName + ': ' + ex.getMessage());
                }
            }
            system.debug(LoggingLevel.WARN, 'Set of In Accessible Objects = ' + setInAccessibleObjs);
            //Get Device specific settings:
            string strDeviceType = (new INTF_ConfigSync()).getDeviceName(request);
            system.debug(LoggingLevel.WARN,' Device in getDownloadCriteriaRecordIds strDeviceType = '+strDeviceType);
            
            String strMobConfQuery  = 'select id, SVMXC__Object_Name__c, SVMXC__Dispatch_Process__c, SVMXC__Ownership_Type__c, LastModifiedDate, CreatedDate, SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.LastModifiedDate from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = \'Mobile Configuration\' AND SVMXC__Display_Type__c = \'Download Criteria\' AND SVMXC__Access_Configuration_Profile__c =:grpProfileId AND SVMXC__Object_Name__c != null AND SVMXC__Object_Name__c NOT IN :setExecObjects';
            
            String strDevConfId = (new INTF_ConfigSync()).getDeviceMobileConfig(grpProfileId, strDeviceType);
            if(strDevConfId != NULL && strDevConfId != ''){
                strMobConfQuery += ' AND SVMXC__SM_Device_Mobile_Config__c =: strDevConfId ';
            }
            system.debug(LoggingLevel.WARN,'Query formed for getDownloadCriteriaRecordIds = '+strMobConfQuery);
        
            INTF_Datasync.logSOQL(intMethodCount,strMobConfQuery);
            for(SVMXC__ServiceMax_Config_Data__c eachDCRec: Database.Query(strMobConfQuery))
            {
                if(!setInAccessibleObjs.contains(eachDCRec.SVMXC__Object_Name__c.toLowerCase()))
                {
                    String strCriteria = '', strLastIdClause = '';
                    List<sObject> lstQryResult = new List<sObject>();
                    //List<sObject> lstDeletedIds = new List<sObject>();
                    INTF_WebServicesDef.SVMXMap eachObjectRecords = new INTF_WebServicesDef.SVMXMap();
                    INTF_WebServicesDef.SVMXMap partialExecObj = new INTF_WebServicesDef.SVMXMap();
                    system.debug(LoggingLevel.WARN, 'Object Name = ' + eachDCRec.SVMXC__Object_Name__c);
                    if(eachDCRec.SVMXC__Object_Name__c == strPartialExecObjName && strLastIdForPartialExcObj != null && strLastIdForPartialExcObj.length() > 0)
                    {
                        system.debug(LoggingLevel.WARN, 'Partial Executed Object = ' + strPartialExecObjName);
                        strLastIdClause = ' ID > :strLastIdForPartialExcObj ';
                    }
                    
                    if(eachDCRec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c != null)
                        strCriteria = ' WHERE (' + eachDCRec.SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c + ') ';
                    
                    if(eachDCrec.SVMXC__Ownership_Type__c == 'My Records')
                    {
                        if(strCriteria != '')
                            strCriteria += ' and ';
                        else
                            strCriteria += ' WHERE ';
                        strCriteria += ' OwnerId = \'' + UserInfo.getUserId() + '\' ';
                    }
                    
                    if(strLastIdClause != '' && strLastIdClause.length() > 0 && strCriteria != '' && strCriteria.length() > 0)
                        strCriteria += ' AND ';
                    else if(strLastIdClause != '' && strLastIdClause.length() > 0 && strCriteria == '' && strCriteria.length() <= 0)
                        strCriteria += ' WHERE ';   
                    else
                        strCriteria += ' ';
                    
                    strCriteria += strLastIdClause + ' ORDER BY ID LIMIT : intLimit ';
                    
                    strCriteria = strCriteria.replace('SVMX.CURRENTUSERID15', UserInfo.getUserId().substring(0,15));
                    strCriteria = strCriteria.replace('SVMX.CURRENTUSERID', UserInfo.getUserId());    
                    strCriteria = strCriteria.replace('SVMX.CURRENTUSER', String.escapeSingleQuotes(UserInfo.getName()));
                    strCriteria = strCriteria.replace('SVMX.USERTRUNK', strCurrTechLocId);
                    system.debug(LoggingLevel.Debug, 'UserInfo.getUserId() = ' + UserInfo.getUserId());
                    Map<String, String> mapSFCSToValue = replaceLiteralWithValue(strCriteria);
                    for(String eachLiteral : mapSFCSToValue.keySet())
                    {
                        system.debug(LoggingLevel.Debug, 'Literal Key = ' + eachLiteral + '; Value = ' + mapSFCSToValue.get(eachLiteral));
                        strCriteria = strCriteria.replace(eachLiteral, mapSFCSToValue.get(eachLiteral));
                    }
                    system.debug(LoggingLevel.Debug, 'After Replace = ' + strCriteria);
                    
                    system.debug(LoggingLevel.WARN, 'Object Name = ' + eachDCRec.SVMXC__Object_Name__c + '; Criteria = ' + strCriteria + '; Query Result = ' + lstQryResult.size());                
                    INTF_DataSync.logSOQL(intMethodCount,'Select Id FROM ' + eachDCRec.SVMXC__Object_Name__c + strCriteria);
                    lstQryResult = Database.query('Select Id FROM ' + eachDCRec.SVMXC__Object_Name__c + strCriteria);
                    system.debug(LoggingLevel.WARN, 'Object Name = ' + eachDCRec.SVMXC__Object_Name__c + '; Criteria = ' + strCriteria + '; Query Result = ' + lstQryResult.size());
                    eachObjectRecords.key = eachDCRec.SVMXC__Object_Name__c;
                    eachObjectRecords.value = JSON.serialize(lstQryResult);
                    intLimit -= lstQryResult.size();
                    if(intLimit <= 0)
                    {
                        partialExecObj.key = 'PARTIAL_EXECUTED_OBJECT';
                        partialExecObj.value = eachDCRec.SVMXC__Object_Name__c;
                        partialExecObj.valueMap.add(new INTF_WebServicesDef.SVMXMap('LAST_ID', lstQryResult[lstQryResult.size() - 1].Id));
                        response.valueMap.add(eachObjectRecords);
                        response.valueMap.add(partialExecObj);
                        break;
                    }
                    else
                    {
                        response.values.add(eachDCRec.SVMXC__Object_Name__c);
                        response.valueMap.add(eachObjectRecords);
                    }
                    system.debug(LoggingLevel.WARN, 'response.values = ' + response.values);
                    system.debug(LoggingLevel.WARN, 'Each Object response = ' + eachObjectRecords + '; Object Executed = ' + eachDCRec.SVMXC__Object_Name__c);
                }
            }
            response.values.addAll(setExecObjects);
        }
        response.eventName = request.eventName;
        response.eventType = request.eventType;
        INTF_DataSync.logMethodEndTS(intMethodCount,'getDownloadCriteriaRecordIds');
        return response;
    }
    
    public map<String, String> replaceLiteralWithValue(String strCriteria)
    {
        Integer intMethodCount = INTF_DataSync.logMethodStartTS('replaceLiteralWithValue');
        Map<String, String> mapSFCSToValue = new Map<String, String>();
        try
        {
            while((strCriteria.indexOf('%SVMX.SFCS', 0)) != -1){
                mapSFCSToValue.put(strCriteria.substring(strCriteria.indexOf('%SVMX.SFCS')+1, strCriteria.indexOf('%\'',strCriteria.indexOf('%SVMX.SFCS') )), '');
                strCriteria = strCriteria.left(strCriteria.indexOf('%SVMX.SFCS'))+ strCriteria.right(strCriteria.length()-strCriteria.indexOf('%SVMX.SFCS')-10);
            }
            system.debug('Remaining strCriteria = ' + strCriteria);

            while((strCriteria.indexOf('SVMX.SFCS', 0)) != -1){
                mapSFCSToValue.put(strCriteria.substring(strCriteria.indexOf('SVMX.SFCS'), strCriteria.indexOf('\'',strCriteria.indexOf('SVMX.SFCS') )), '');
                strCriteria = strCriteria.substring(strCriteria.indexOf('SVMX.SFCS')+9);   
            }
            system.debug('mapSFCSToValue = ' + mapSFCSToValue);
        
            for(String eachCustomSett : mapSFCSToValue.keySet())
            {
                String strFieldName = '';
                String strUserId = UserInfo.getUserId();
                String strProfileId = UserInfo.getProfileId();
                String strOrgId = UserInfo.getOrganizationId();         
                List<sObject> lstsobj = new List<sObject>();
                List<String> lstCustSettValues = new List<String>();
                
                system.debug(LoggingLevel.Debug,'eachCustomSett = ' + eachCustomSett);
                
                lstCustSettValues = eachCustomSett.split('\\.');
                System.debug(LoggingLevel.Debug,'lstCustSettValues = ' + lstCustSettValues);
                
                if(eachCustomSett.startsWithIgnoreCase('SVMX.SFCSH'))
                {
                    if(lstCustSettValues != null && lstCustSettValues.size() == 4)
                    {
                        strFieldName = lstCustSettValues[3];
                        INTF_DataSync.logSOQL(intMethodCount, 'Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strUserId');
                        lstsobj = Database.query('Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strUserId');
                        if(lstsobj == null || lstsobj.size() <= 0)
                        {
                            INTF_DataSync.logSOQL(intMethodCount, 'Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strProfileId');
                            lstsobj = Database.query('Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strProfileId');
                            if(lstsobj == null || lstsobj.size() <= 0){
                                INTF_DataSync.logSOQL(intMethodCount,'Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strOrgId');
                                lstsobj = Database.query('Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strOrgId');
                            }
                        }
                    }
                }
                else if(eachCustomSett.startsWithIgnoreCase('SVMX.SFCSL'))
                {
                    if(lstCustSettValues != null && lstCustSettValues.size() == 4)
                    {
                        if(lstCustSettValues[3].indexOf(':', 0) != -1)
                        {
                            strFieldName = lstCustSettValues[3].split(':')[0];
                            String strListVal = lstCustSettValues[3].split(':')[1];
                            system.debug(LoggingLevel.Debug,'strFieldName = ' + strFieldName + '; strListVal = ' + strListVal);
                            INTF_DataSync.logSOQL(intMethodCount,'Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strOrgId and Name = :strListVal Order by Name limit 1 ');
                            lstsobj = Database.query('Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strOrgId and Name = :strListVal Order by Name limit 1 ');
                        }
                        else
                        {
                            strFieldName = lstCustSettValues[3];
                            INTF_DataSync.logSOQL(intMethodCount,'Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strOrgId Order by Name limit 1 ');
                            lstsobj = Database.query('Select '+ strFieldName + ' from ' + lstCustSettValues[2] + ' where SetupOwnerId = :strOrgId Order by Name limit 1 ');
                        }
                    }
                }
                
                system.debug(LoggingLevel.Debug,'lstsobj = ' + lstsobj + '; strFieldName = ' + strFieldName);
                
                if(lstsobj != null && lstsobj.size() > 0)
                    mapSFCSToValue.put(eachCustomSett, String.valueOf(lstsobj[0].get(strFieldName)));
            }
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.Debug,'Exception = ' + ex);
        }
        INTF_DataSync.logMethodEndTS(intMethodCount,'replaceLiteralWithValue');
        return mapSFCSToValue;
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse getPushNotificationData(INTF_WebServicesDef.INTF_SFMRequest inputRequest)
    {
        INTF_WebServicesDef.INTF_SFMResponse response = new INTF_WebServicesDef.INTF_SFMResponse();
        response.eventName = inputRequest.eventName;
        response.eventType = inputRequest.eventType;
        response.success = true;
        response.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        string objectName, recIdToDownload, eventRecId;
        map<string, string> mapChildObjToSOQL = new map<string, string>();
        Integer intLimitRelationshipFields = 35;
        set<String> setRefObjToSkip = new set<String>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        list<String> lstSettingId = new list<String>{'SET004', 'SET013', 'SET008'};
        map<String, String> mapSettingsForIPAD018 = new map<String, String>();
        list<string> lstDeletedIds = new list<string>();
        
        try{
            mapSettingsForIPAD018 = commSettings.SVMX_getSettingList('IPAD018', lstSettingId);
            system.debug(LoggingLevel.WARN,'Settings = ' + mapSettingsForIPAD018);
            if(mapSettingsForIPAD018.containskey('SET004') && mapSettingsForIPAD018.get('SET004') != null)
            {
                String strValue = mapSettingsForIPAD018.get('SET004');
                list<String> lstValue = new list<String>();
                lstValue = strValue.split(',');
                if(lstValue.size() > 0)
                {
                    for(Integer i = 0; i < lstValue.size(); i++)
                    {
                        setRefObjToSkip.add(lstValue[i].toUpperCase());
                    }
                }
            }
            else
            {
                setRefObjToSkip.add('PARTNERNETWORKCONNECTION');
                setRefObjToSkip.add('USER');
                setRefObjToSkip.add('FEEDPOST');
                setRefObjToSkip.add('SOLUTION');
                setRefObjToSkip.add('OPENACTIVITY');
            }
            
            if(mapSettingsForIPAD018.containskey('SET013') && mapSettingsForIPAD018.get('SET013') != null)
                intLimitRelationshipFields = integer.valueOf(mapSettingsForIPAD018.get('SET013'));
            else
                intLimitRelationshipFields = 35;
            
            for(INTF_WebServicesDef.SVMXMap eachObject : inputRequest.valueMap)
            {
                if(eachObject.key == 'Object_Name' && eachObject.value != null && eachObject.value.length() > 0)
                {
                    objectName = eachObject.value;
                    for(INTF_WebServicesDef.SVMXMap ObjDetails : eachObject.valueMap)
                    {
                        if(ObjDetails.key == 'Record_Id' && ObjDetails.value != null && ObjDetails.value.length() > 0)
                        {
                            if(objectName == 'Event')
                                eventRecId = ObjDetails.value;
                            else
                                recIdToDownload = ObjDetails.value;
                        }
                    }
                }
            }
            
            system.debug('==: Object Name: ' + objectName + ' =Event Id= ' + eventRecId + ' =Record Id= ' + recIdToDownload);
            
            if(objectName == null || objectName == '' || objectName.length() == 0 || ((eventRecId == null || eventRecId == '' || eventRecId.length() == 0) && (recIdToDownload == null || recIdToDownload == '' || recIdToDownload.length() == 0)))
            {
                response.success = false;
                response.message = 'Object Name or Record Id is not available to download.';
                return response;
            }
            
            boolean skipField = false;
            if(mapSettingsForIPAD018.containskey('SET008') && mapSettingsForIPAD018.get('SET008') != null)
            {
                skipField = Boolean.valueOf(mapSettingsForIPAD018.get('SET008'));
            }
            else
                skipField = false;
            
            if(objectName == 'Event' && eventRecId != null)
            {
                string strEventSOQL = 'select id';
                Schema.DescribeSObjectResult objDescribe;
                for(string Obj: allObjs.keyset())
                {
                    Schema.SObjectType selectedObject = allObjs.get(Obj);
                    objDescribe = selectedObject.getDescribe();
                    if(objDescribe.getName() == objectName)
                        break;
                }
                
                Map<String,Schema.SObjectField> fieldMapping = objDescribe.fields.getMap();
                
                for(Schema.SObjectField fieldMap: fieldMapping.values())
                {
                    if(skipField && !fieldMap.getDescribe().isAccessible())
                        continue;
                    Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
                    
                    if(fieldDescribe.getName() != 'Id')
                        strEventSOQL += ', ' + fieldDescribe.getName();
                }
                
                if(!strEventSOQL.contains('IsDeleted'))
                    strEventSOQL += ', IsDeleted';
                
                strEventSOQL += ' from Event where Id = \'' + eventRecId + '\' ALL ROWS';
                system.debug('==: SOQL for Event: ' + strEventSOQL);
                
                List<Event> lstEvents = (List<Event>)database.query(strEventSOQL);
                
                if(!lstEvents[0].IsDeleted)
                {
                    INTF_WebServicesDef.SVMXMap eventRecValueMap = new INTF_WebServicesDef.SVMXMap('Event', JSON.serialize(lstEvents));
                    response.valueMap.add(eventRecValueMap);
                    
                    for(Event ev: lstEvents)
                        recIdToDownload = ev.WhatId;
                    
                    string objKeyPrefix = recIdToDownload.substring(0,3);   
                    
                    system.debug('==: Object KeyPrefix: ' + objKeyPrefix);
                    
                    for(string obj : allObjs.keyset())
                    {
                        Schema.SObjectType eventRelObj = allObjs.get(obj);
                        Schema.DescribeSObjectResult eventRelObjDescribe = eventRelObj.getDescribe();
                        if(eventRelObjDescribe.getKeyPrefix() == objKeyPrefix)
                        {
                            objectName = eventRelObjDescribe.getName();
                            break;
                        }
                    }
                }
                else
                {
                    lstDeletedIds.add(lstEvents[0].Id);
                }
            }
            
            system.debug('==: Object Name: ' + objectName + ' =Record Id= ' + recIdToDownload + ' =Is Skip field= ' + skipField);
            map<string, string> mapObjToSOQL = getRecForMasterDtlObj(objectName, recIdToDownload, skipField, setRefObjToSkip);
            for(string objKey : mapObjToSOQL.keyset())
            {
                system.debug('==: Object Name: ' + objKey + ' =SOQL= ' + mapObjToSOQL.get(objKey));
                
                List<sObject> lstRecs = database.query(mapObjToSOQL.get(objKey));
                if(lstRecs != null && lstRecs.size() > 0)
                {
                    List<sObject> lstObjToAddToResponse = new List<sObject>();
                    
                    for(sObject sObj : lstRecs)
                    {
                        if(boolean.valueOf(sObj.get('IsDeleted')))
                        {
                            lstDeletedIds.add(string.valueOf(sObj.get('Id')));
                        }else
                        {
                            lstObjToAddToResponse.add(sObj);
                        }
                    }
                    if(lstObjToAddToResponse != null && lstObjToAddToResponse.size() > 0)
                        response.valueMap.add(new INTF_WebServicesDef.SVMXMap(objKey, JSON.serialize(lstObjToAddToResponse)));
                }
            }
                    
            if(lstDeletedIds != null && lstDeletedIds.size() > 0)
            {
                INTF_WebServicesDef.SVMXMap eventRecValueMap = new INTF_WebServicesDef.SVMXMap('DELETE', '');
                eventRecValueMap.values = lstDeletedIds;
                response.valueMap.add(eventRecValueMap);
            }
        }catch(exception ex)
        {
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }
    
    public map<string, string> getRecForMasterDtlObj(string objectName, string masterRecId, boolean isSkipInAccessibleFlds, set<String> setRefObjToSkip)
    {
        map<string, string> mapObjSOQL = new map<string, string>();
        INTF_TxnCache cacheObj = new INTF_TxnCache();
        
        Set<String> setAllowedObj = new Set<String>();
        INTF_ConfigSync confSync = new INTF_ConfigSync();
        string svmxGrpProfileId = confSync.getSVMXGrpProfileId(userinfo.getProfileId());
        setAllowedObj = cacheObj.getAllowedSetOfObjects(svmxGrpProfileId);
        
        if(!setAllowedObj.contains(objectName))
            return mapObjSOQL;
        
        Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult objDescribe;
        
        for(string Obj: allObjs.keyset())
        {
            Schema.SObjectType selectedObject = allObjs.get(Obj);
            objDescribe = selectedObject.getDescribe();
            if(objDescribe.getName() == objectName)
                break;
        }
        Map<String,Schema.SObjectField> fieldMapping = objDescribe.fields.getMap();
        string strObjSOQL = 'select Id';
        
        for(Schema.SObjectField fieldMap: fieldMapping.values())
        {
            if(isSkipInAccessibleFlds && !fieldMap.getDescribe().isAccessible())
                continue;
            Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
            
            if(fieldDescribe.getName() != 'Id')
                strObjSOQL += ', ' + fieldDescribe.getName();
        }

        if(!strObjSOQL.contains('IsDeleted'))
            strObjSOQL += ', IsDeleted';
        
        strObjSOQL += ' from ' + objectName + ' Where Id = ' + '\'' + masterRecId + '\' ALL ROWS';
        
        mapObjSOQL.put(objectName, strObjSOQL);
        
        for(Schema.ChildRelationship childRel : objDescribe.getChildRelationships())
        {
            if(childRel.isCascadeDelete())
            {
                Schema.SObjectType childObjType = childRel.getChildSObject();
                Schema.DescribeSObjectResult childObjDescribe = childObjType.getDescribe();
                
                if(!childObjDescribe.isAccessible() || !childObjDescribe.isQueryable() || childObjDescribe.getName().contains('__Tag') || childObjDescribe.getName().contains('__History'))
                    continue;
                    
                string childObj = childObjDescribe.getName(), childObjSOQL = 'select id', fldLookupToMasterObj;
                
                if(setRefObjToSkip.contains(childObj) || !setAllowedObj.contains(childObj))
                    continue;
                
                Map<String,Schema.SObjectField> childFldMapping = childObjDescribe.fields.getMap();
                
                Schema.sObjectField lookupFld = childRel.getField();
                Schema.DescribeFieldResult lookupFldDesc = lookupFld.getDescribe();
                fldLookupToMasterObj = lookupFldDesc.getName();
                
                for(Schema.SObjectField fieldMap: childFldMapping.values())
                {
                    if(isSkipInAccessibleFlds && !fieldMap.getDescribe().isAccessible())
                        continue;
                    Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
                    
                    if(fieldDescribe.getName() != 'Id')
                        childObjSOQL += ', ' + fieldDescribe.getName();
                }
        
                if(!childObjSOQL.contains('IsDeleted'))
                    childObjSOQL += ', IsDeleted';
                
                childObjSOQL += ' from ' + childObj + ' where ' + fldLookupToMasterObj + ' = \'' + masterRecId + '\' ALL ROWS';
                mapObjSOQL.put(childObj, childObjSOQL);
            }
        }
        
        return mapObjSOQL;
    }
    
    public void updateEventIdsInRequestCache(List<String> lstAllEventIds, List<String> lstModifiedEventIds, INTF_WebServicesDef.INTF_SFMRequest inputRequest){
            Integer intMethodCount = INTF_DataSync.logMethodStartTS('updateEventIdsInRequestCache');
            SVMXC__SM_Request_Cache__c singleCacheRec;
            Map<String, String> mapClientInfo = new Map<String, String>();
            mapClientInfo = (new INTF_ConfigSync()).getClientData(inputRequest);
            system.debug(LoggingLevel.WARN, 'mapClientInfo = ' + mapClientInfo);
            
            String strUserId = mapClientInfo.get('userid');
            String strDeviceUDID = mapClientInfo.get('clientudid');
            String strSyncReqId = inputRequest.value;
            
            Map<String, String> mapAllEventWhatIds = new Map<String, String>();
            if(lstAllEventIds != NULL && !lstAllEventIds.isEmpty()){
                mapAllEventWhatIds.put('ALL_EVENTS', Json.serialize(lstAllEventIds));
            }
            if(lstModifiedEventIds != NULL && !lstModifiedEventIds.isEmpty()){
                mapAllEventWhatIds.put('MODIFIED_EVENTS', Json.serialize(lstModifiedEventIds));
            }
            
            List<SVMXC__SM_Request_Cache__c> requestCacheList = [Select Id, LastModifiedDate, SVMXC__SM_Application_Filters__c, SVMXC__SM_Application_Name__c, SVMXC__SM_Application_Version__c, SVMXC__SM_Checklist_Wizard_Objects__c, SVMXC__SM_Client_Sync_Request_Id__c, SVMXC__SM_Device_Type__c, SVMXC__SM_Device_UDID__c, SVMXC__SM_Doc_Template_IDs__c, SVMXC__SM_Download_Criteria_Object_Definitions__c, SVMXC__SM_Download_Criteria_Object_List__c, SVMXC__SM_Expression_IDs__c, SVMXC__SM_Group_Profile_Id__c, SVMXC__SM_Mobile_Config_Settings__c, SVMXC__SM_Object_Access__c, SVMXC__SM_Object_Definitions__c, SVMXC__SM_Object_Name__c, SVMXC__SM_Page_Layout_IDs__c, SVMXC__SM_Picklist_Definitions__c, SVMXC__SM_Settings__c, SVMXC__SM_SFM_Mappings__c, SVMXC__SM_SFM_Process_IDs__c, SVMXC__SM_SFM_Translations__c, SVMXC__SM_SFM_Wizard_SFM_Ids__c, SVMXC__SM_SFW_Translations__c, SVMXC__SM_SOQL_Query__c, SVMXC__SM_Sync_Start_Time__c, SVMXC__SM_User_id__c,SVMXC__SM_Question_Bank_IDs__c, SVMXC__SM_Event_What_IDs__c FROM SVMXC__SM_Request_Cache__c where SVMXC__SM_User_Id__c = :strUserId AND SVMXC__SM_Device_UDID__c =: strDeviceUDID];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(requestCacheList != null && !requestCacheList.isEmpty()){    
                if(requestCacheList[0].SVMXC__SM_Client_Sync_Request_Id__c != strSyncReqId){
                    //It isn't a part of the same request Id, Reset all txn fields
                    singleCacheRec = requestCacheList[0];
                    singleCacheRec.SVMXC__SM_User_Id__c = strUserId;
                    singleCacheRec.SVMXC__SM_Device_UDID__c = strDeviceUDID;
                    singleCacheRec.SVMXC__SM_Client_Sync_Request_Id__c = strSyncReqId;
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
                    singleCacheRec.SVMXC__SM_Event_What_IDs__c = Json.serialize(mapAllEventWhatIds); 
                }else{
                    singleCacheRec = requestCacheList[0];  //use the record as it is because it is a part of the same request ID
                    singleCacheRec.SVMXC__SM_Event_What_IDs__c = Json.serialize(mapAllEventWhatIds);
                }
            }else{
                //There is no existing request cache record for this user/Device --> create one
                singleCacheRec = new SVMXC__SM_Request_Cache__c();
                singleCacheRec.SVMXC__SM_User_Id__c = strUserId;
                singleCacheRec.SVMXC__SM_Device_UDID__c = strDeviceUDID;
                singleCacheRec.SVMXC__SM_Client_Sync_Request_Id__c = strSyncReqId;
                singleCacheRec.SVMXC__SM_Sync_Start_Time__c = Datetime.now();
                singleCacheRec.SVMXC__SM_Event_What_IDs__c = Json.serialize(mapAllEventWhatIds);
            }
            Database.upsert(singleCacheRec,false);
            INTF_DataSync.logMethodEndTS(intMethodCount,'updateEventIdsInRequestCache');
    }
}