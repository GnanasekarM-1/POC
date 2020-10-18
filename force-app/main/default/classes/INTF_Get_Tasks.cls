/* Class to Get Tasks for the webservice*/
public with sharing class INTF_Get_Tasks 
{
     public static DCON_Utils dcUtils = new DCON_Utils();
     public Map<String, String> mapObjKeyName = new Map<String, String>{};
     Map<String, Schema.SObjectType> allObjDescribe = null;
     Map<String,Schema.Describesobjectresult> mapObjNameAndObjRes = new Map<String,Schema.Describesobjectresult>();
     public INTF_WebServicesDef.INTF_Response_For_Tasks INTF_Get_Tasks(INTF_WebServicesDef.INTF_Request_For_Tasks iPadReqTasks)
     {
        List<Task> lstSalesforceEvents = new List<Task>();
        DateTime dtmStart,dtmEnd;
        String strWhereClause = '';
        String strTimeZone, strUserId;
         try
        {
            //Describe the objects as required
            describeObjectsAsRequired();
            //Get the request info
            List<INTF_WebServicesDef.INTF_StringMap> lstRequestMap = iPadReqTasks.taskReqInfo;
            
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
            strWhereClause = dtmStart != null ? strWhereClause + 'ReminderDateTime  >=: dtmStart' : strWhereClause;
            strWhereClause = dtmEnd != null ? strWhereClause + ' and ReminderDateTime  <=: dtmEnd' : strWhereClause;
            
            if(strWhereClause != null && strWhereClause.length() > 0)
            {
                strWhereClause = ' where ' + strWhereClause + ' and OwnerId =: strUserId and IsRecurrence = false';
            }
                        
            //Get all the Salesforce   
            system.debug('select query for the Tasks : ' + 'Select Id, ActivityDate, ReminderDateTime, OwnerId, Subject, Description, WhatId from Task' + strWhereClause);  
            lstSalesforceEvents = database.query('Select Id, ActivityDate, ReminderDateTime, OwnerId, Subject, Description, WhatId from Task' + strWhereClause);
            List<INTF_WebServicesDef.INTF_Task> lstTasks = new List<INTF_WebServicesDef.INTF_Task>();
            if(lstSalesforceEvents != null && lstSalesforceEvents.size() > 0)
            {
                lstTasks = convertSFEventsForResponse(lstSalesforceEvents);
            }else
            {
                //No Records.
            }
            
            //Building the response for the iPad Task
            INTF_WebServicesDef.INTF_Response_For_Tasks objResponseForTasks = new INTF_WebServicesDef.INTF_Response_For_Tasks();
            objResponseForTasks.taskInfo = lstTasks;
            return objResponseForTasks;                     
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
     
     // method to convert the SFTasks to response for iPad get events request 
     private List<INTF_WebServicesDef.INTF_Task> convertSFEventsForResponse(List<Task> lstTasks)
     {
        List<INTF_WebServicesDef.INTF_Task> lstSFTasks = new List<INTF_WebServicesDef.INTF_Task>();
        INTF_WebServicesDef.INTF_Task currTask;
        String strPrefix,strObjName,strAdditionalInfo;
        Schema.Describesobjectresult currObjResult;
        Map<String,String> mapRecIdAndAddInfo = getAdditionalInfo(lstTasks);
        String strWhatId = null;
        for(Task currSFTask : lstTasks)
        {
            // if the task is not related to the object 
            strWhatId = currSFTask.whatId;      
            if( strWhatId != null && mapRecIdAndAddInfo.keySet().contains(strWhatId))
            {   
                strPrefix = strWhatId != null ? strWhatId.substring(0,3): '';           
                strObjName = mapObjKeyName.get(strPrefix);
                System.debug('Object Name: ' + strObjName + ' Size:' + mapObjNameAndObjRes.size());
                currObjResult =  mapObjNameAndObjRes.get(strObjName);
                System.debug('Object result: ' + currObjResult);
                //Building the additional info details: Object Label: <Name Field Value> <Addl Info>
                strAdditionalInfo = currObjResult.getLabel() + ': ' + mapRecIdAndAddInfo.get(strWhatId) ;
                currTask = new INTF_WebServicesDef.INTF_Task();
                currTask.taskInfo = currSFTask;
                currTask.taskDisplay = new List<INTF_WebServicesDef.INTF_StringMap>();
                currTask.taskDisplay.add(new INTF_WebServicesDef.INTF_StringMap('ObjectAPIName', mapObjKeyName.get(strPrefix)));
                currTask.taskDisplay.add(new INTF_WebServicesDef.INTF_StringMap('ObjectLabel', currObjResult.getLabel()));
                currTask.taskDisplay.add(new INTF_WebServicesDef.INTF_StringMap('AdditionalInfo', strAdditionalInfo));
                currTask.taskDisplay.add(new INTF_WebServicesDef.INTF_StringMap('ColorCode', ''));
                lstSFTasks.add(currTask);
            }
            else
            {
                currTask = new INTF_WebServicesDef.INTF_Task();
                currTask.taskInfo = currSFTask;
                currTask.taskDisplay = new List<INTF_WebServicesDef.INTF_StringMap>();
                currTask.taskDisplay.add(new INTF_WebServicesDef.INTF_StringMap('AdditionalInfo', currSFTask.Subject));
                lstSFTasks.add(currTask);
            }       
        }
        return lstSFTasks;
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
            mapObjKeyName.put(discCurrObject.getKeyPrefix(),currObj);
        }
     }
     
     // Methods to get the additional info from different tasks if whatid exists
     private Map<String,String> getAdditionalInfo(List<Task> lstTasks)
     {
        String strPrefix, strWhatId,strObjName,strCurrObj;
        Map<String,String> mapObjNameAndRecs = new Map<String,String>();
        Schema.Describesobjectresult currObjResult;
        
                
        for(Task currSFTask : lstTasks)
        {
            strWhatId = String.valueOf(currSFTask.WhatId);
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
            String strFieldsToQry, strAddInfo;
            String[] strQueryFields;
            for(String currObjRec : mapObjNameAndRecs.keySet())
            {
                strAddInfo = '';
                currObjResult = mapObjNameAndObjRes.get(strObjName);
                strFieldsToQry = getFieldsToQry(currObjResult);
                strSelectQry = 'Select ' + strFieldsToQry + ' From ' + currObjRec + ' where id IN ('+ mapObjNameAndRecs.get(currObjRec) +')';
                system.debug('Select Query For the Object to get the info: ' + strSelectQry);
                List<SObject> lstRecs = database.query(strSelectQry);
                strQueryFields = strFieldsToQry.split(',');
                if(lstRecs != null && lstRecs.size() > 0)
                {
                    for(SObject cuRec : lstRecs)
                    {
                        strAddInfo = String.valueOf(cuRec.get(strQueryFields[1]));
                        strAddInfo = strQueryFields.size() > 2 ? strAddInfo + ' ' + String.valueOf(cuRec.get(strQueryFields[2])) : strAddInfo;
                        mapRecIdAndAddInfo.put(String.valueOf(cuRec.get('Id')), strAddInfo);
                    }
                }
            }
        }
        return mapRecIdAndAddInfo;
     }
     
     private String getFieldsToQry(Schema.Describesobjectresult objResult)
     {
        String nameField = 'Id,';
        Map<String, Schema.SObjectField> allCurrObjFlds = objResult.fields.getMap() ;
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