global with sharing class SFM_ExecuteScheduledSFM_Batch implements Database.Batchable<sObject>, Database.Stateful
{
    public DateTime dateTimeStart = null;
    global set<string> setProIds = new set<string>();
    global Map<String, String> mapSFMProcessIdSFMProcessName = new Map<String, String>();
    global Map<String, String> mapSFMIdLog = new Map<String, String>();
    global Map<String, Set<String>> mapSFMScheduleIdSFMProcess = new Map<String, Set<String>>();
    global Map<String, Integer> mapSFMProcessCountPass =  new Map<String, Integer>();
    global Map<String, Integer> mapSFMProcessCountFail =  new Map<String, Integer>();
    global Map<Id, SVMXC__ServiceMax_Processes__c> mapSFMScheduleProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
    global Map<String, String> mapSFMScheduleIDLog = new Map<String, String>();
    global Map<String, String> mapSFMScheduleIDTimeZone = new Map<String, String>();
    global Map<String, Set<String>> mapSFMProcessSFMScheduleId = new Map<String, Set<String>>();
    global Map<String, String> mapSobjectNameField = new Map<String, String>();
    
    
    // This is the start method of batch class it is responsible for creating Iterable of sObject and pass it to execute method
    global Iterable<sObject> start(Database.BatchableContext BC)
    {
        if(dateTimeStart == null)
            dateTimeStart = System.now();
        List<sObject> lstsObjectToReturn = new List<sObject>();
        list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObject = new list<SVMXC__ServiceMax_Processes__c>();
        Map<String, String> mapProcessParentObjCriteria = new Map<String, String>();
        Map<String, String> mapProcessSObject = new Map<String, String>();
        try
        {
            if(setProIds != null && setProIds.size() > 0)
            {
                List<SVMXC__ServiceMax_Config_Data__c> lstSFMProcessSCH = new List<SVMXC__ServiceMax_Config_Data__c>();
                set<Id> setSFMIds = new set<Id>();
                
                if(setProIds.contains(null))
                    setProIds.remove(null);

                mapSFMScheduleProcess.putAll([select Id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Assign_To_Dispatcher__c, SVMXC__Capture_Log__c, SVMXC__Dispatch_Timezone__c from SVMXC__ServiceMax_Processes__c where Id IN: setProIds]);
                
                for(String strScheduleId : mapSFMScheduleProcess.keySet())
                {
                    if(mapSFMScheduleProcess.get(strScheduleId).SVMXC__Dispatch_Timezone__c != null)
                        mapSFMScheduleIDTimeZone.put(strScheduleId, mapSFMScheduleProcess.get(strScheduleId).SVMXC__Dispatch_Timezone__c);
                    mapSFMScheduleIDLog.put(strScheduleId, '');
                }
                
                lstSFMProcessSCH = [Select Id, SVMXC__Expression_Rule__c, SVMXC__Expression_Rule__r.SVMXC__ProcessID__c , SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN : setProIds and RecordType.Name = 'Schedule Detail' and SVMXC__Expression_Rule__c != null];
                
                if(lstSFMProcessSCH != null && lstSFMProcessSCH.size() > 0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c configData : lstSFMProcessSCH)
                    {
                        setSFMIds.add(configData.SVMXC__Expression_Rule__c);
                        mapSFMIdLog.put(configData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c, '');
                        if(!mapSFMScheduleIdSFMProcess.containsKey(configData.SVMXC__Dispatch_Process__c))
                            mapSFMScheduleIdSFMProcess.put(configData.SVMXC__Dispatch_Process__c, new Set<String>());
                        mapSFMScheduleIdSFMProcess.get(configData.SVMXC__Dispatch_Process__c).add(configData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c);
                        
                        if(!mapSFMProcessSFMScheduleId.containsKey(configData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c))
                            mapSFMProcessSFMScheduleId.put(configData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c, new Set<String>());
                        mapSFMProcessSFMScheduleId.get(configData.SVMXC__Expression_Rule__r.SVMXC__ProcessID__c).add(configData.SVMXC__Dispatch_Process__c);
                        
                        
                    }
                }
               
                lstProcessNodeObject = [Select Id,SVMXC__Process__c, SVMXC__Process__r.SVMXC__ProcessID__c, SVMXC__Process__r.SVMXC__Name__c, SVMXC__Submodule__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,  SVMXC__Submodule__r.SVMXC__Source_Object_Name__c, SVMXC__Node_Source_Object_API__c, SVMXC__Source_Object_Name__c, SVMXC__Process__r.SVMXC__Purpose__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c IN : setSFMIds and RecordType.Name  = 'Process Node Objects' and SVMXC__Type__c = 'TARGET'];

                for(SVMXC__ServiceMax_Processes__c objProcess : lstProcessNodeObject)
                {
                    mapSFMProcessIdSFMProcessName.put(objProcess.SVMXC__Process__r.SVMXC__ProcessID__c, objProcess.SVMXC__Process__r.SVMXC__Name__c);
                    if(objProcess.SVMXC__Submodule__c != null)
                    {
                        mapProcessParentObjCriteria.put(objProcess.SVMXC__Process__r.SVMXC__ProcessID__c, objProcess.SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c);
                        mapProcessSObject.put(objProcess.SVMXC__Process__r.SVMXC__ProcessID__c, objProcess.SVMXC__Submodule__r.SVMXC__Source_Object_Name__c);
                    }
                    else
                    {
                        mapProcessParentObjCriteria.put(objProcess.SVMXC__Process__r.SVMXC__ProcessID__c, '');
                        //this check for creating map of source object
                        if(objProcess.SVMXC__Process__r.SVMXC__Purpose__c == 'SOURCE TO TARGET ALL' && objProcess.SVMXC__Node_Source_Object_API__c != null){
                            mapProcessSObject.put(objProcess.SVMXC__Process__r.SVMXC__ProcessID__c, objProcess.SVMXC__Node_Source_Object_API__c);
                        }
                        else if(objProcess.SVMXC__Process__r.SVMXC__Purpose__c == 'SOURCE TO TARGET ALL' && objProcess.SVMXC__Node_Source_Object_API__c != null){
                            mapProcessSObject.put(objProcess.SVMXC__Process__r.SVMXC__ProcessID__c, objProcess.SVMXC__Node_Source_Object_API__c);
                        }
                        else if(objProcess.SVMXC__Process__r.SVMXC__Purpose__c == 'STANDALONE EDIT' && objProcess.SVMXC__Source_Object_Name__c != null){
                            mapProcessSObject.put(objProcess.SVMXC__Process__r.SVMXC__ProcessID__c, objProcess.SVMXC__Source_Object_Name__c);
                        }
                    }
                }
                
                Set<String> setObjectName = new Set<String>();
                setObjectName.addAll(mapProcessSObject.values());
                getObjectNamedField(setObjectName);
                //lstProcessNodeObject = [Select Id,SVMXC__Process__c, SVMXC__Process__r.SVMXC__ProcessID__c, SVMXC__Process__r.SVMXC__Name__c, SVMXC__Submodule__c, SVMXC__Submodule__r.SVMXC__Parent_Object_Criteria__c,  SVMXC__Submodule__r.SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__r.SVMXC__ProcessID__c != null AND SVMXC__Submodule__r.SVMXC__Source_Object_Name__c != null AND SVMXC__Process__c IN : setSFMIds and RecordType.Name  = 'Process Node Objects' and SVMXC__Type__c = 'TARGET'];
            } 
            
            // this block is creating a list of Iterable
            if(mapSFMProcessIdSFMProcessName != null && mapSFMProcessIdSFMProcessName.size() > 0)
            {
                for(String strProcessId : mapSFMProcessIdSFMProcessName.keySet())
                {
                    if(mapProcessParentObjCriteria.containsKey(strProcessId) && mapProcessSObject.containsKey(strProcessId))
                    {
                        System.debug(logginglevel.WARN, 'Name of process : '+mapSFMProcessIdSFMProcessName.get(strProcessId));
                        String strQuery = 'select Id from '+ mapProcessSObject.get(strProcessId);
                        if(mapSobjectNameField.containsKey(mapProcessSObject.get(strProcessId)) && mapSobjectNameField.get(mapProcessSObject.get(strProcessId)) != null)
                            strQuery = 'select Id, '+mapSobjectNameField.get(mapProcessSObject.get(strProcessId))+' from '+ mapProcessSObject.get(strProcessId);
                        else
                            strQuery = 'select Id from '+ mapProcessSObject.get(strProcessId);
                        String strWhereClause = mapProcessParentObjCriteria.get(strProcessId);
                        if(strWhereClause != null && strWhereClause != '')
                            strQuery = strQuery+' where '+strWhereClause;
                        System.debug('query for the record : '+strQuery);
                        List<sObject> lstSobject = Database.query(strQuery);
                        mapSFMProcessCountPass.put(strProcessId, 0);
                        mapSFMProcessCountFail.put(strProcessId, 0);
                        if(lstSobject != null)
                        {
                            Integer intListSize = lstSobject.size();
                            String strLog = ''+intListSize;
                            mapSFMIdLog.put(strProcessId, strLog);
                            for(sObject objSobject : lstSobject)
                            {
                                SVMXC__ServiceMax_Processes__c objTemoProcess = new SVMXC__ServiceMax_Processes__c();
                                objTemoProcess.SVMXC__Name__c = (String)objSobject.get('Id');
                                objTemoProcess.SVMXC__ProcessID__c = strProcessId;
                                if(mapSobjectNameField.containsKey(mapProcessSObject.get(strProcessId)))
                                    objTemoProcess.SVMXC__Source_Object_Name__c = (String)objSobject.get(mapSobjectNameField.get(mapProcessSObject.get(strProcessId)));
                                else
                                    objTemoProcess.SVMXC__Source_Object_Name__c = '';
                                lstsObjectToReturn.add(objTemoProcess);
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug(logginglevel.WARN, 'on catch of start method for sfm scheduled batch process : '+ex.getMessage());
        }
        //strLogger =string.valueOfgmt(system.now()) + ': ' + 'Total number of Record to proceed in this call : '+lstsObjectToReturn.size();
        System.debug('number of records to proced : '+lstsObjectToReturn.size());
        System.debug('number of SFM Process : '+mapSFMProcessCountPass.size());
        return lstsObjectToReturn;
    }
    //This method is responsible for getting all Named Fields of given object
    public void getObjectNamedField(Set<String> setObjectName)
    {
        try
        {
            Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
            Map<String, Schema.DescribeSObjectResult> mapAPINameObjDesc = new Map<String, Schema.DescribeSObjectResult>();
            Map<String,Boolean> PermittedStandardObjectList = new Map<String,Boolean>();
            SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils();
            Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
            
            if(allObjs.size() > 0)
            {
                for(String s : allObjs.keyset())
                {
                    Schema.DescribeSObjectResult objDesc = allObjs.get(s).getDescribe();
                    if(!mapAPINameObjDesc.containskey(objDesc.getName()))
                      mapAPINameObjDesc.put(objDesc.getName(),objDesc);
                }
            }
            for(String s : mapAPINameObjDesc.keySet())
                system.debug('Name: '+s+' value: '+mapAPINameObjDesc.get(s));
                
            PermittedStandardObjectList = commutils.SVMX_getPermittedStandardObjectList();
            system.debug('Name: '+PermittedStandardObjectList);
            
            
            
            if(mapAPINameObjDesc.size() > 0)
            {
                for(String str : mapAPINameObjDesc.keyset())
                {
                    if(setObjectName.contains(str))
                    {
                        if(PermittedStandardObjectList.size() > 0 && PermittedStandardObjectList.containsKey(str))
                        {
                            objfieldMap = mapAPINameObjDesc.get(str).fields.getMap();
                            for(String strkey2 : objfieldMap.keyset())
                            {
                                Schema.DescribeFieldResult schmDescFildRstl = objfieldMap.get(strkey2).getDescribe();
                                if(schmDescFildRstl.isNameField())
                                {
                                    mapSobjectNameField.put(str , schmDescFildRstl.getName());
                                    break;
                                }
                            }
                        }
                        else
                        {
                            if(mapAPINameObjDesc.get(str).isCustom())
                                mapSobjectNameField.put(str, 'Name');
                        }
                    }
                }
            }
        }
        Catch(Exception ex)
        {
            System.debug(logginglevel.WARN, 'on catch of doLogging method for sfm scheduled batch process : '+ex.getMessage());
        }
    }
    // This is execute method This will take sObject from the list according to batch size and do proceed
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        for(sObject objSobject : scope)
        {
            DateTime dateTimeStartInn = System.now();
            
            if(objSobject.get('SVMXC__Name__c') != null && ((String)objSobject.get('SVMXC__Name__c')).length() > 0 && (String)objSobject.get('SVMXC__ProcessID__c') != null && ((String)objSobject.get('SVMXC__ProcessID__c')).length() > 0)
            {
                SVMXC.INTF_WebServicesDef.INTF_Request request = new SVMXC.INTF_WebServicesDef.INTF_Request();
                SVMXC.INTF_WebServicesDef.INTF_Response response = new SVMXC.INTF_WebServicesDef.INTF_Response();
                try
                {
                    list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmapRecordId = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    strmapRecordId.key = 'RECORDID';
                    strmapRecordId.value = (String)objSobject.get('SVMXC__Name__c');
                    lstStringMap.add(strmapRecordId);
                    SVMXC.INTF_WebServicesDef.INTF_StringMap strmapTDMID = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
                    strmapTDMID.key = 'TDMID';
                    strmapTDMID.value = (String)objSobject.get('SVMXC__ProcessID__c');
                    lstStringMap.add(strmapTDMID);
                    request.StringMap = lstStringMap;
                    system.debug(LoggingLevel.WARN,'request'+request);
                    SVMXC.INTF_SFMEngine RunEngine = new SVMXC.INTF_SFMEngine();
                    response = RunEngine.SVMX_ExecuteEngine(request);
                    system.debug(LoggingLevel.WARN,'response'+response);
                    if(response != null && response.success == false)
                    {
                        doLogging((String)objSobject.get('SVMXC__ProcessID__c'), (String)objSobject.get('SVMXC__Source_Object_Name__c'), dateTimeStartInn, response.success, response.message);
                        Integer intCountFail = mapSFMProcessCountFail.get((String)objSobject.get('SVMXC__ProcessID__c'))+1;
                        mapSFMProcessCountFail.put((String)objSobject.get('SVMXC__ProcessID__c'), intCountFail);
                    }
                    if(response != null && response.success == true)
                    {
                        doLogging((String)objSobject.get('SVMXC__ProcessID__c'), (String)objSobject.get('SVMXC__Source_Object_Name__c'), dateTimeStartInn, response.success, '');
                        Integer intCountPass = mapSFMProcessCountPass.get((String)objSobject.get('SVMXC__ProcessID__c'))+1;
                        mapSFMProcessCountPass.put((String)objSobject.get('SVMXC__ProcessID__c'), intCountPass);
                    }
                    
                }
                Catch(Exception ex)
                {
                    Integer intCountFail = mapSFMProcessCountFail.get((String)objSobject.get('SVMXC__ProcessID__c'))+1;
                    mapSFMProcessCountFail.put((String)objSobject.get('SVMXC__ProcessID__c'), intCountFail);
                    doLogging((String)objSobject.get('SVMXC__ProcessID__c'), (String)objSobject.get('SVMXC__Source_Object_Name__c'), dateTimeStartInn, false, ex.getMessage());
                    System.debug(logginglevel.WARN, 'on catch of execute method for sfm scheduled batch process : '+ex.getMessage());
                }
            }
        }
    }
    // This method is responsible for add logs in process ID map
    private void doLogging(String strSFMProcessId, String strRecordId, DateTime dateTimeStart, boolean isPass, String strMessage)
    {
        try
        {
            DateTime dateTimeEndInn = System.now();
            String strDateTimeStart = '';
            String strDateTimeEnd = '';
            if(mapSFMProcessSFMScheduleId.containsKey(strSFMProcessId))
            {
                for(String strKey : mapSFMProcessSFMScheduleId.get(strSFMProcessId))
                {
                    if(mapSFMScheduleIDLog.containsKey(strKey))
                    {
                        if(mapSFMScheduleIDTimeZone.containsKey(strKey) && mapSFMScheduleIDTimeZone.get(strKey) != null && mapSFMScheduleIDTimeZone.get(strKey) != '')
                        {
                            strDateTimeStart = dateTimeStart.format('MM/dd/yyyy HH:mm:ss', mapSFMScheduleIDTimeZone.get(strKey));
                            strDateTimeEnd = dateTimeEndInn.format('MM/dd/yyyy HH:mm:ss', mapSFMScheduleIDTimeZone.get(strKey));
                        }
                        String strLOgs = mapSFMScheduleIDLog.get(strKey);
                        strLOgs = strLOgs+'\n\n'+getTAG015()+' '+strSFMProcessId+', '+getTAG016()+' '+strRecordId;
                        strLOgs = strLOgs+'\n\t'+getTAG007()+': '+strDateTimeStart;
                        if(isPass)
                            strLOgs = strLOgs+'\n\t'+getTAG005()+': '+getTAG017();
                        else
                            strLOgs = strLOgs+'\n\t'+getTAG005()+': '+getTAG018()+', '+getTAG013()+': '+strMessage;
                        strLOgs = strLOgs+'\n\t'+getTAG008()+': '+strDateTimeEnd;
                        mapSFMScheduleIDLog.put(strKey, strLOgs);
                    }
                }
            }
        }
        Catch(Exception ex)
        {
            System.debug(logginglevel.WARN, 'on catch of doLogging method for sfm scheduled batch process : '+ex.getMessage());
        }
    }
    //This is finish method and it is responsible for doing logging and creating job object
    global void finish(Database.BatchableContext BC)
    {
        try
        {
            DateTime datetimeEnd = System.now();
            
            //code for logging
            List<Messaging.SingleEmailMessage> lstEmail =new List<Messaging.SingleEmailMessage>();
            List<SVMXC__SVMX_Jobs__c> lstJobs = new List<SVMXC__SVMX_Jobs__c>();
            Map<String, SVMXC__SVMX_Jobs__c> mapHeaderProcessIdJob = new Map<String, SVMXC__SVMX_Jobs__c>();
            Map<String, String> mapHeaderProcessIdAttachment = new Map<String, String>();
            
            for(string strScheId : mapSFMScheduleProcess.keySet())
            {
            //Scheduled SFM Process - “MyNewSFMSCheduled” was completed with the following results:
                //String strlogger = '\nScheduled SFM Process has been completed with the following results:';
                
                String strlogger = '\n'+getTAG002()+' '+mapSFMScheduleProcess.get(strScheId).SVMXC__Name__c;
                
                strlogger = strlogger+'\n'+getTAG003()+' '+mapSFMScheduleProcess.get(strScheId).SVMXC__ProcessID__c;
                String strLogPass = '';
                String strAttachmentlog = '';
                if(mapSFMScheduleIdSFMProcess.containsKey(strScheId))
                {
                    for(String strSMFID : mapSFMScheduleIdSFMProcess.get(strScheId))
                    {
                        
                        if(mapSFMProcessCountPass.containsKey(strSMFID))
                        {
                            strLogPass = strLogPass+'\n\n'+mapSFMProcessIdSFMProcessName.get(strSMFID)+':';
                            Integer intCountPass = mapSFMProcessCountPass.get(strSMFID);
                            Integer intCountFail = mapSFMProcessCountFail.get(strSMFID);
                            strLogPass = strLogPass+'\n\t'+getTAG004()+': '+mapSFMIdLog.get(strSMFID);
                            strLogPass = strLogPass+'\n\t'+getTAG005()+': '+intCountPass;
                            strLogPass = strLogPass+'\n\t'+getTAG006()+': '+intCountFail;
                        }
                        
                    }
                }
                if(mapSFMScheduleIDLog.containskey(strScheId))
                    strAttachmentlog = strAttachmentlog+mapSFMScheduleIDLog.get(strScheId);
                
                strlogger = strlogger+strLogPass;
                
                String strEndlog = '';
                strEndlog = strEndlog+'\n\n'+getTAG019()+': '+dateTimeStart.format('MM/dd/yyyy HH:mm:ss', mapSFMScheduleProcess.get(strScheId).SVMXC__Dispatch_Timezone__c)+' '+TimeZone.getTimeZone(mapSFMScheduleProcess.get(strScheId).SVMXC__Dispatch_Timezone__c).getDisplayName()+' ('+mapSFMScheduleProcess.get(strScheId).SVMXC__Dispatch_Timezone__c+')';
                strEndlog = strEndlog+'\n'+getTAG020()+': '+datetimeEnd.format('MM/dd/yyyy HH:mm:ss', mapSFMScheduleProcess.get(strScheId).SVMXC__Dispatch_Timezone__c)+' '+TimeZone.getTimeZone(mapSFMScheduleProcess.get(strScheId).SVMXC__Dispatch_Timezone__c).getDisplayName()+' ('+mapSFMScheduleProcess.get(strScheId).SVMXC__Dispatch_Timezone__c+')';
                Decimal decCoutTime  = (Decimal.valueOf(((datetimeEnd.day()-dateTimeStart.day())*24*60*60)+((datetimeEnd.hour()-dateTimeStart.hour())*60*60)+((datetimeEnd.minute()-dateTimeStart.minute())*60)+(datetimeEnd.second()-dateTimeStart.second())))/60;
                Decimal decRounded = Math.round(decCoutTime * 100) / 100.0;
                strEndlog = strEndlog+'\n'+getTAG009()+': '+ decRounded.toPlainString();
                
                strAttachmentlog = strlogger+'\n========================================================='+strAttachmentlog;
                strlogger = strlogger+strEndlog;
                strAttachmentlog = strAttachmentlog+'\n=========================================================\n'+strEndlog;
                
                String strFinaLlogger = getTAG001()+'\n';
                strFinaLlogger = strFinaLlogger+'\n'+getTAG014();
                strFinaLlogger = strFinaLlogger+strlogger;
                strFinaLlogger = strFinaLlogger+'\n\n'+getTAG010();
                String strNowDateMail =  datetimeEnd.format('MM/dd/yyyy', mapSFMScheduleProcess.get(strScheId).SVMXC__Dispatch_Timezone__c);
                if(mapSFMScheduleProcess.get(strScheId).SVMXC__Assign_To_Dispatcher__c != null)
                {
                    Messaging.EmailFileAttachment Attc = new Messaging.EmailFileAttachment();
                    blob attachBlob = Blob.valueOf(strAttachmentlog);
                    string flename= getTAG012()+'_'+strNowDateMail+'.txt';
                    Attc.setFileName(flename);
                    Attc.setBody(attachBlob);
                    Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                    String subject = getTAG011()+' '+strNowDateMail;
                    email.setSubject(subject);
                    email.saveAsActivity = false;
                    email.setTargetObjectId( mapSFMScheduleProcess.get(strScheId).SVMXC__Assign_To_Dispatcher__c );
                    email.setPlainTextBody(strFinaLlogger);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[]{Attc});
                    lstEmail.add(email);
                }
                
                mapHeaderProcessIdAttachment.put(strScheId, strAttachmentlog);
                
                if(mapSFMScheduleProcess.get(strScheId).SVMXC__Capture_Log__c)
                {
                    SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();
                    objJob.SVMXC__SVMX_Process__c = strScheId;
                    objJob.SVMXC__Type__c = 'Scheduled SFM';
                    objJob.SVMXC__Start_Time__c = dateTimeStart;
                    objJob.SVMXC__End_Time__c = datetimeEnd;
                    objJob.SVMXC__Message__c = strlogger;
                    lstJobs.add(objJob);
                    mapHeaderProcessIdJob.put(strScheId, objJob);
                }
                
            }
            if(lstEmail != null && lstEmail.size() > 0)
            {
                Messaging.SendEmailResult [] mainsend = Messaging.sendEmail(lstEmail);
                system.debug('cheack mail: '+mainsend);
            }
            if(lstJobs != null && lstJobs.size() > 0)
            {
                //insert lstJobs;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstJobs, COMM_SecurityUtils.Access.Createable ) ) {
                    insert lstJobs;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
                //Added for BAC-2276
                if(COMM_FileHandlerUtilities.checkFileSetting()){
                    List<ContentVersion> lstCVInstances = new List<ContentVersion>();
                    for(string strScheId : mapSFMScheduleProcess.keySet())
                    {
                        if(mapHeaderProcessIdJob.containsKey(strScheId) && mapHeaderProcessIdJob.get(strScheId).Id != null && mapHeaderProcessIdAttachment.containsKey(strScheId))
                        {
                            ContentVersion cvTemp = new ContentVersion();
                            cvTemp.VersionData = Blob.valueOf(mapHeaderProcessIdAttachment.get(strScheId));
                            cvTemp.Title = 'Scheduled SFM.txt';
                            cvTemp.PathOnClient = 'Scheduled SFM.txt';
                            cvTemp.IsMajorVersion = false;
                            cvTemp.SVMXC__SM_Process_ID__c = mapHeaderProcessIdJob.get(strScheId).Id;
                            lstCVInstances.add(cvTemp);
                            
                        }
                        
                    }
                    List<Id> lstCVIds = COMM_FileHandlerUtilities.insertListOfContentVersion(lstCVInstances);
                    List<String> fieldSet = new List<String>();
                    fieldSet.add('SVMXC__SM_Process_ID__c');
                    fieldSet.add('ContentDocumentId');
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'ContentVersion', fieldSet, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    List<ContentVersion> lstCVDetails = Database.query('SELECT Id, SVMXC__SM_Process_ID__c, ContentDocumentId FROM ContentVersion WHERE Id IN: lstCVIds');
                    List<ContentDocumentLink> listContentDocumentLinkInstances = new List<ContentDocumentLink>();
                    for(ContentVersion cv: lstCVDetails){
                        listContentDocumentLinkInstances.add(COMM_FileHandlerUtilities.createContentDocumentLink(cv.SVMXC__SM_Process_ID__c,cv.ContentDocumentId));
                        
                    }
                    List<Id> lstCDLids = COMM_FileHandlerUtilities.insertContentDocumentLink(listContentDocumentLinkInstances);
                }else{
                    List<Attachment> lstAttachment = new List<Attachment>();
                    for(string strScheId : mapSFMScheduleProcess.keySet())
                    {
                        if(mapHeaderProcessIdJob.containsKey(strScheId) && mapHeaderProcessIdJob.get(strScheId).Id != null && mapHeaderProcessIdAttachment.containsKey(strScheId))
                        {
                            Attachment objAttach = new Attachment();
                            blob attachBlob = Blob.valueOf(mapHeaderProcessIdAttachment.get(strScheId));
                            objAttach.Body = attachBlob;
                            objAttach.ParentId = mapHeaderProcessIdJob.get(strScheId).Id;
                            objAttach.Name = 'Scheduled SFM.txt';
                            lstAttachment.add(objAttach);
                        }
                        
                    }
                    if(lstAttachment != null && lstAttachment.size() > 0)
                        insert lstAttachment;
                }
                //End BAC-2276
            }
        }
        catch(Exception ex)
        {
            System.debug(logginglevel.WARN, 'on catch of finish method for sfm scheduled batch process : '+ex.getMessage());
        }
        
        
    }
        public string getTAG001(){return System.label.COMM001_TAG093;}//'NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.'
        public string getTAG002(){return System.label.CONF039_TAG017;}//'Schedule SFM Process Name:'
        public string getTAG003(){return System.label.CONF039_TAG018;}//'Scheduled SFM Process Id:'
        public string getTAG004(){return System.label.CONF039_TAG019;}//'Records to Process'
        public string getTAG005(){return System.label.COMM001_TAG096;}//'Success'
        public string getTAG006(){return System.label.COMM001_TAG097;}//'Failed'
        public string getTAG007(){return System.label.CONF039_TAG020;}//'Start Time'
        public string getTAG008(){return System.label.CONF039_TAG021;}//'Finish Time'
        public string getTAG009(){return System.label.CONF039_TAG022;}//'Elapsed Time in minutes'
        public string getTAG010(){return System.label.COMM001_TAG092;}//'For more information, review the attached log.'
        public string getTAG011(){return System.label.CONF039_TAG023;}//'ServiceMax: SFM Scheduled Status on:'
        public string getTAG012(){return System.label.COMM001_TAG095;}//'Attachment'
        public string getTAG013(){return System.label.CONF039_TAG024;}//'Reason'
        public string getTAG014(){return System.label.CONF039_TAG016;}//'Scheduled SFM Process has been completed with the following results:'
        public string getTAG015(){return System.label.CONF039_TAG031;}//'SFM Process:'
        public string getTAG016(){return System.label.CONF039_TAG032;}//'Record:'
        public string getTAG017(){return System.label.CONF039_TAG033;}//'True'
        public string getTAG018(){return System.label.CONF039_TAG034;}//'False'
        public string getTAG019(){return System.label.CONF039_TAG038;}//'Scheduler Start Time'
        public string getTAG020(){return System.label.CONF039_TAG039;}//'Scheduler Finish Time'
}