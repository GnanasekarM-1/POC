/* Class to Get events for the webservice */
public with sharing class INTF_Get_Events 
{
     public static DCON_Utils dcUtils = new DCON_Utils();
     public Map<String, String> mapObjKeyName = new Map<String, String>{};
     public Map<String, String> mapObjKeyActualName = new Map<String, String>{};
     Map<String, Schema.SObjectType> allObjDescribe = null;
     Map<String,Schema.Describesobjectresult> mapObjNameAndObjRes = new Map<String,Schema.Describesobjectresult>();
     Map<String,String> mapRecIdAndPriorityInfo = new Map<String,String>();
     Map<String,List<INTF_WebServicesDef.INTF_StringMap>> mapRecIdAndLocationInfo = new Map<String,List<INTF_WebServicesDef.INTF_StringMap>>();
     SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
     public Map<String, String> calenderSettingList = commSettings.SVMX_getSettingList('IPAD006');
     
     public INTF_WebServicesDef.INTF_Response_For_Events INTF_Get_Events(INTF_WebServicesDef.INTF_Request_For_Events iPadReqEvent)
     {
        system.debug('TEST LOG: ' + iPadReqEvent);
        List<Event> lstSalesforceEvents = new List<Event>();
        DateTime dtmStart,dtmEnd;
        String strWhereClause = '';
        String strTimeZone, strUserId;
         try
        {
            //Describe the objects as required
            describeObjectsAsRequired();
            //Get the request info
            List<INTF_WebServicesDef.INTF_StringMap> lstRequestMap = iPadReqEvent.eventReqInfo;
            
            if(lstRequestMap != null)
            {
                String currValue;
                for(INTF_WebServicesDef.INTF_StringMap curr : lstRequestMap)
                {
                    currValue = curr.value;
                    if(curr.key == 'userID' && currValue != null)
                    {
                        strUserId = currValue;
                    }
                }
                strTimeZone = getTimezone(strUserId);
                for(INTF_WebServicesDef.INTF_StringMap curr : lstRequestMap)
                {
                    currValue = curr.value;
                    if(curr.key == 'startDate' && currValue != null)
                    {                       
                        dtmStart = dcUtils.getDateTimeInTimezone(Date.valueOf(currValue), Time.newInstance(0, 0, 0, 0), strTimeZone);
                        system.debug('startDate: ' + currValue);
                    }else if(curr.key == 'endDate' && currValue != null)
                    {
                        dtmEnd = dcUtils.getDateTimeInTimezone(Date.valueOf(currValue), Time.newInstance(23, 59, 59, 59), strTimeZone);
                        system.debug('endDate' + currValue);
                    }
                }   
            }              
            strWhereClause = dtmStart != null ? strWhereClause + 'StartDateTime >=: dtmStart' : strWhereClause;
            strWhereClause = dtmEnd != null ? strWhereClause + ' and StartDateTime <=: dtmEnd' : strWhereClause;
            
            if(strWhereClause != null && strWhereClause.length() > 0)
            {
                strWhereClause = ' where ' + strWhereClause + ' and OwnerId =: strUserId and IsRecurrence = false and IsAllDayEvent = False';
            }
                        
            //Get all the Salesforce   
            system.debug('select query for the Events : ' + 'Select Id, ActivityDate, ActivityDateTime, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location from Event' + strWhereClause);  
            lstSalesforceEvents = database.query('Select Id, ActivityDate, ActivityDateTime, OwnerId, DurationInMinutes, Subject, Description, WhatId, StartDateTime, EndDateTime, Location from Event' + strWhereClause);
            List<INTF_WebServicesDef.INTF_Event> lstEvents = new List<INTF_WebServicesDef.INTF_Event>();
            if(lstSalesforceEvents != null && lstSalesforceEvents.size() > 0)
            {
                lstEvents = convertSFEventsForResponse(lstSalesforceEvents);
            }else
            {
                //No Records.
            }
            
            //Building the response for the iPad Event
            INTF_WebServicesDef.INTF_Response_For_Events objResponseForEvents = new INTF_WebServicesDef.INTF_Response_For_Events();
            objResponseForEvents.eventInfo = lstEvents;
            return objResponseForEvents;                        
        }   
        catch(Exception ex)
        {
            throw new SFM_WrapperDef.PMaxException(ex); 
        }
     }
     
     // get the timezone for the user
     private String getTimezone(String UserId)
     {
        User userDetail = [SELECT TimeZoneSidKey from User where Id = :UserId];
        return userDetail.TimeZoneSidKey;               
     }
     
     // method to convert the SFEvents to response for iPad get events request 
     private List<INTF_WebServicesDef.INTF_Event> convertSFEventsForResponse(List<Event> lstEvents)
     {
        List<INTF_WebServicesDef.INTF_Event> lstSFEvents = new List<INTF_WebServicesDef.INTF_Event>();
        INTF_WebServicesDef.INTF_Event currEvent;
        String strPrefix,strObjName,strAdditionalInfo;
        Schema.Describesobjectresult currObjResult;
        Map<String,String> mapRecIdAndAddInfo = getAdditionalInfo(lstEvents);
        String strWhatId = null;
        String strPriority = '';
        String strColorValue = '';
        List<INTF_WebServicesDef.INTF_StringMap> lstLocationInfo = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap locInfo = null;
        for(Event currSFEvent : lstEvents)
        {
            // if the event is not related to the object    
            strWhatId = currSFEvent.whatId;     
            if( strWhatId != null && mapRecIdAndAddInfo.keySet().contains(strWhatId))
            {   
                strPrefix = strWhatId != null ? strWhatId.substring(0,3): '';           
                strObjName = mapObjKeyName.get(strPrefix);
                System.debug('Object Name: ' + strObjName + ' Size:' + mapObjNameAndObjRes.size());
                currObjResult =  mapObjNameAndObjRes.get(strObjName);
                System.debug('Object result: ' + currObjResult);
                //Building the additional info details: Object Label: <Name Field Value> <Addl Info>
                strAdditionalInfo = currObjResult.getLabel() + ': ' + mapRecIdAndAddInfo.get(strWhatId) ;
                currEvent = new INTF_WebServicesDef.INTF_Event();
                currEvent.eventInfo = currSFEvent;
                currEvent.eventDisplay = new List<INTF_WebServicesDef.INTF_StringMap>();
                currEvent.eventDisplay.add(new INTF_WebServicesDef.INTF_StringMap('ObjectAPIName', mapObjKeyActualName.get(strPrefix)));
                currEvent.eventDisplay.add(new INTF_WebServicesDef.INTF_StringMap('ObjectLabel', currObjResult.getLabel()));
                currEvent.eventDisplay.add(new INTF_WebServicesDef.INTF_StringMap('AdditionalInfo', strAdditionalInfo));
                lstLocationInfo = mapRecIdAndLocationInfo.get(strWhatId);
                if(lstLocationInfo != null)
                {
                    currEvent.locationInfo = new List<INTF_WebServicesDef.INTF_StringMap>();
                    for(INTF_WebServicesDef.INTF_StringMap currLocInfo : lstLocationInfo)
                    {
                        locInfo = new INTF_WebServicesDef.INTF_StringMap();
                        locInfo.key = currLocInfo.key;
                        locInfo.value = currLocInfo.value;
                        currEvent.locationInfo.add(locInfo);
                    }
                }
                
                if(mapRecIdAndPriorityInfo.containsKey(strWhatId) && mapRecIdAndPriorityInfo.get(strWhatId) != NULL)
                {
                    strPriority = mapRecIdAndPriorityInfo.get(strWhatId).toUpperCase();
                }
                if(strPriority != null && strPriority.length() > 0)
                {
                    System.debug('Are settings are loaded: ' + calenderSettingList.containsKey('SET001'));
                    if(strPriority == 'HIGH' && calenderSettingList.containsKey('SET001'))
                    {
                        strColorValue = calenderSettingList.get('SET001');
                    }else if(strPriority == 'MEDIUM' && calenderSettingList.containsKey('SET002'))
                    {
                        strColorValue = calenderSettingList.get('SET002');
                    }else if(strPriority == 'LOW' && calenderSettingList.containsKey('SET003'))
                    {
                        strColorValue = calenderSettingList.get('SET003');
                    }
                }
                currEvent.eventDisplay.add(new INTF_WebServicesDef.INTF_StringMap('ColorCode', strColorValue));             
                lstSFEvents.add(currEvent);
            }
            else
            {
                currEvent = new INTF_WebServicesDef.INTF_Event();
                currEvent.eventInfo = currSFEvent;
                currEvent.eventDisplay = new List<INTF_WebServicesDef.INTF_StringMap>();
                currEvent.eventDisplay.add(new INTF_WebServicesDef.INTF_StringMap('AdditionalInfo', currSFEvent.Subject));
                lstSFEvents.add(currEvent);
            }       
        }
        return lstSFEvents;
     }
         
     // Method to describe the all SObjects and create the oupput as per the req.
     private void describeObjectsAsRequired()
     {
        allObjDescribe = Schema.getGlobalDescribe();
        Schema.Describesobjectresult discCurrObject;
        mapObjKeyName.clear();
        for(String currObj : allObjDescribe.keySet())
        {
            discCurrObject = allObjDescribe.get(currObj).getDescribe();
            mapObjKeyActualName.put(discCurrObject.getKeyPrefix(), discCurrObject.getName());
            mapObjKeyName.put(discCurrObject.getKeyPrefix(), currObj);
        }
     }
     
     // Methods to get the additional info from different events if whatid exists
     private Map<String,String> getAdditionalInfo(List<Event> lstEvents)
     {
        String strPrefix, strWhatId,strObjName,strCurrObj;
        Map<String,String> mapObjNameAndRecs = new Map<String,String>();
        Schema.Describesobjectresult currObjResult;
        mapRecIdAndPriorityInfo = new Map<String,String>();
                
        for(Event currSFEvent : lstEvents)
        {
            strWhatId = String.valueOf(currSFEvent.WhatId);
            strPrefix = strWhatId != null ? strWhatId.substring(0,3): '';           
            // if the event is not related to the object            
            if(strPrefix != null && strPrefix.length() > 0)
            {   
                strObjName = mapObjKeyName.get(strPrefix);
                currObjResult = mapObjNameAndObjRes.get(strObjName);
                if(currObjResult == null)
                {
                    currObjResult = allObjDescribe.get(strObjName).getDescribe();
                    mapObjNameAndObjRes.put(strObjName,currObjResult);
                }           
                if(mapObjNameAndRecs.get(strObjName) == null)
                {
                    mapObjNameAndRecs.put(strObjName,'\'' + strWhatId + '\'');
                }else
                {
                    mapObjNameAndRecs.put(strObjName,mapObjNameAndRecs.get(strObjName) + ',\'' + strWhatId + '\'');
                }           
            }
        }
        
        Map<String,String> mapRecIdAndAddInfo = new Map<String,String>();
        if(mapObjNameAndRecs != null && mapObjNameAndRecs.size() > 0)
        {
            String strSelectQry;
            String strFieldsToQry, strAddInfo, strPriority = '',strPriorityValue = '';
            String[] strQueryFields;
            Boolean isWorkOrder = false;
            for(String currObjRec : mapObjNameAndRecs.keySet())
            {
                strAddInfo = '';
                currObjResult = null;
                currObjResult = mapObjNameAndObjRes.get(currObjRec);
                strFieldsToQry = getFieldsToQry(currObjResult);
                strPriority = '';
                isWorkOrder = false;
                System.debug('Current Object Name: '+ currObjResult.getName());
                if(currObjResult.getName() == 'SVMXC__Service_Order__c')
                {
                    strPriority = 'SVMXC__Priority__c,SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Country__c,SVMXC__Zip__c,SVMXC__Latitude__c,SVMXC__Longitude__c';
                    isWorkOrder = true;
                }else if(currObjResult.getName() == 'Case')
                {
                    strPriority = 'Priority';
                }
                if(strPriority.length() > 0)
                {
                    strSelectQry = 'Select ' + strFieldsToQry + ',' + strPriority + ' From ' + currObjRec + ' where id IN ('+ mapObjNameAndRecs.get(currObjRec) +')';               
                }else
                {
                    strSelectQry = 'Select ' + strFieldsToQry + ' From ' + currObjRec + ' where id IN ('+ mapObjNameAndRecs.get(currObjRec) +')';           
                
                }
                system.debug('Select Query For the Object to get the info: ' + strSelectQry);
                List<SObject> lstRecs = database.query(strSelectQry);
                strQueryFields = strFieldsToQry.split(',');
                
                if(lstRecs != null && lstRecs.size() > 0)
                {
                    for(SObject cuRec : lstRecs)
                    {
                        strPriorityValue = '';
                        strAddInfo = String.valueOf(cuRec.get(strQueryFields[1]));
                        if(strPriority.length() > 0)
                        {
                            
                            System.debug('Workorder Priority: ' + strPriority + 'and Value: ' + strPriorityValue);
                        }
                        strAddInfo = strQueryFields.size() > 2 ? strAddInfo + ' ' + String.valueOf(cuRec.get(strQueryFields[2])) : strAddInfo;
                        mapRecIdAndAddInfo.put(String.valueOf(cuRec.get('Id')), strAddInfo);
                        if(strPriority != null && strPriority.length() > 0)
                        {
                            if(isWorkOrder)
                            {   
                                strPriorityValue = String.valueOf(cuRec.get('SVMXC__Priority__c'));
                                mapRecIdAndPriorityInfo.put(String.valueOf(cuRec.get('Id')), strPriorityValue);
                                List<INTF_WebServicesDef.INTF_StringMap> objAllLocationInfo = new List<INTF_WebServicesDef.INTF_StringMap>();
                                INTF_WebServicesDef.INTF_StringMap info = new INTF_WebServicesDef.INTF_StringMap();
                                info.key = 'Street';
                                info.value = String.valueOf(cuRec.get('SVMXC__Street__c'));
                                objAllLocationInfo.add(info);
                                info = new INTF_WebServicesDef.INTF_StringMap();
                                info.key = 'City';
                                info.value = String.valueOf(cuRec.get('SVMXC__City__c'));
                                objAllLocationInfo.add(info);
                                info = new INTF_WebServicesDef.INTF_StringMap();
                                info.key = 'State';
                                info.value = String.valueOf(cuRec.get('SVMXC__State__c'));
                                info = new INTF_WebServicesDef.INTF_StringMap();
                                info.key = 'Country';
                                info.value = String.valueOf(cuRec.get('SVMXC__Country__c'));
                                info = new INTF_WebServicesDef.INTF_StringMap();
                                info.key = 'Zip';
                                info.value = String.valueOf(cuRec.get('SVMXC__Zip__c'));
                                objAllLocationInfo.add(info);
                                info = new INTF_WebServicesDef.INTF_StringMap();
                                info.key = 'Latitude';
                                info.value = String.valueOf(cuRec.get('SVMXC__Latitude__c'));
                                objAllLocationInfo.add(info);
                                info = new INTF_WebServicesDef.INTF_StringMap();
                                info.key = 'Longitude';
                                info.value = String.valueOf(cuRec.get('SVMXC__Longitude__c'));
                                objAllLocationInfo.add(info);
                                
                                mapRecIdAndLocationInfo.put(String.valueOf(cuRec.get('Id')),objAllLocationInfo);
                            }else
                            {
                                strPriorityValue = String.valueOf(cuRec.get('Priority'));
                                mapRecIdAndPriorityInfo.put(String.valueOf(cuRec.get('Id')), strPriorityValue);                         
                            }
                        }
                    }
                }
            }
        }
        return mapRecIdAndAddInfo;
     }
     
     private String getFieldsToQry(Schema.Describesobjectresult objResult)
     {
        Map<String, Schema.SObjectField> allCurrObjFlds = objResult.fields.getMap() ;
        String nameField = 'Id,';
        if(objResult.getSObjectType()  == Account.SObjectType)
            nameField += 'Name';
        else
        {
            
            Schema.Describefieldresult currField = null;
            for(String strObjFieldName : allCurrObjFlds.keySet())
            {
                currField = allCurrObjFlds.get(strObjFieldName).getDescribe();          
                if(currField.isNameField())
                {
                    nameField += currField.getName();
                    break;
                }
            }
        }
                
        if(allCurrObjFlds.keySet().contains('additionalinfo__c'))
        {
            nameField += ',additionalinfo__c';
        }       
        return nameField;
     }
     
     
}