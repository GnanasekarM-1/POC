global with sharing class CONF_SFMMobilePermissions {
    
    global class Request{
        webservice String name;
        webservice String sortBy;
        webservice String objectName;
        webservice String searchText;
        webservice String processType;
        webservice String svmxProfile;
        webservice List<ProcessDetails> processDetails;
    }
    
    global class Response{
        webservice String page;
        webservice String objectName;
        webservice String svmxProfile;
        webservice List<String> items;
        webservice List<ProcessDetails> processDetails;
        
        global Response(){
            items = new List<String>();
            processDetails = new List<ProcessDetails>();
        }
    }
    
    global class ProcessDetails{
        webservice String id;
        webservice String name;
        webservice String processID;
        webservice String processType;
        webservice String field;
        webservice List<ProcessDetails> processDetails;
        
        global ProcessDetails()
        {
            processDetails = new List<ProcessDetails>();
        }
        
        global ProcessDetails(String id, String name, String processID, String processType, String field){
            this.id = id;
            this.name = name;
            this.processID = processID;
            this.processType = processType;
            this.field = field;
        }
    }
    
    public String getUserInfo(){
        return JSON.serialize(new SVMXC.SFMDeliveryServiceImpl().getUserInfoInternal());
    }
     
    @RemoteAction
    global static CONF_SFMMobilePermissions.Response onPageLoad(){
        CONF_SFMMobilePermissions.Response response = new CONF_SFMMobilePermissions.Response();
        response.processDetails.add(new ProcessDetails('--NONE--', (new CONF_SFMMobilePermissions()).getTAG021(), '', '', ''));
        
        for(SVMXC__ServiceMax_Config_Data__c eachProfile : [Select Id, SVMXC__Profile_Name__c from SVMXC__ServiceMax_Config_Data__c  where SVMXC__RecordType_Name__c = 'Configuration Profile' and SVMXC__Configuration_Type__c = 'Group' Order By SVMXC__Profile_Name__c])
            response.processDetails.add(new ProcessDetails(eachProfile.Id, eachProfile.SVMXC__Profile_Name__c, '', '', ''));
            
        return response;
    }
    
    @RemoteAction
    global static CONF_SFMMobilePermissions.Response onChangeProfile(String requestString){
        CONF_SFMMobilePermissions.Request request = (CONF_SFMMobilePermissions.Request)JSON.deserialize(requestString, CONF_SFMMobilePermissions.Request.class);
        CONF_SFMMobilePermissions.Response response = new CONF_SFMMobilePermissions.Response();
        String isChecklist = 'false';
        List<SVMXC__ServiceMax_Config_Data__c> lstSettings = (new INTF_ConfigSync()).getSettings(new set<string>(), new set<string>(), new set<string>{'GLOB001_GBL029'}, null);
        if(lstSettings != null && lstSettings.size() > 0)
        {
            for(SVMXC__ServiceMax_Config_Data__c cnf: lstSettings)
                isChecklist = cnf.SVMXC__Internal_Value__c;
        }
        response = (new CONF_SFMMobilePermissions()).getProcesses(request);
        response.processDetails.add(new ProcessDetails('CHECKLIST', isChecklist, '', '', ''));
        return response;
    }
    
    @RemoteAction
    global static CONF_SFMMobilePermissions.Response onChangeProcessType(String requestString){
        system.debug(LoggingLevel.WARN, ' In onChangeProcessType()');
        CONF_SFMMobilePermissions.Request request = (CONF_SFMMobilePermissions.Request)JSON.deserialize(requestString, CONF_SFMMobilePermissions.Request.class);
        CONF_SFMMobilePermissions.Response response = new CONF_SFMMobilePermissions.Response();
        response = (new CONF_SFMMobilePermissions()).getProcesses(request);
        return response;
    }
    
    public map<String, String> getAssignedProcesses(String strGrpProfile){
        map<String, String> mapIdToSFProcess = new map<String, String>();
        system.debug(LoggingLevel.Debug, ' In getAssignedProcesses() ; strGrpProfile = ' + strGrpProfile);
        for(SVMXC__ServiceMax_Config_Data__c eachAccess : [Select Id, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Access_Configuration_Profile__c =:strGrpProfile and SVMXC__RecordType_Name__c =: 'Service Flow Access' AND SVMXC__Dispatch_Process__c != null])
            mapIdToSFProcess.put(eachAccess.Id, eachAccess.SVMXC__Dispatch_Process__c);
        
        return mapIdToSFProcess;
    }
    
    @RemoteAction
    global static CONF_SFMMobilePermissions.Response onChangeObject(String requestString){
        system.debug(LoggingLevel.WARN, ' In onChangeObject()');
        CONF_SFMMobilePermissions.Request request = (CONF_SFMMobilePermissions.Request)JSON.deserialize(requestString, CONF_SFMMobilePermissions.Request.class);
        CONF_SFMMobilePermissions.Response response = new CONF_SFMMobilePermissions.Response();
        response = (new CONF_SFMMobilePermissions()).getProcesses(request);
        return response;
    }
    
    @RemoteAction
    global static CONF_SFMMobilePermissions.Response onSearchOrSort(String requestString){
        system.debug(LoggingLevel.WARN, ' In onSearchOrSort()');
        CONF_SFMMobilePermissions.Request request = (CONF_SFMMobilePermissions.Request)JSON.deserialize(requestString, CONF_SFMMobilePermissions.Request.class);
        CONF_SFMMobilePermissions.Response response = new CONF_SFMMobilePermissions.Response();
        response = (new CONF_SFMMobilePermissions()).getProcesses(request);
        return response;
    }
    
    public CONF_SFMMobilePermissions.Response getProcesses(CONF_SFMMobilePermissions.Request request){
        system.debug(LoggingLevel.WARN, ' In getProcesses() ; Request = ' + request);
        Integer intLimit = 2000, intCountAssgnd = 0, intCountNotAssgnd = 0;
        Set<String> setAssignedProcesses = new Set<String>();
        list<String> lstObjectNames = new list<String>();
        Map<String,String> mapLabelToAPIName = new Map<String,String>();
        Map<String,String> mapFieldAPIToName = new Map<String,String>();
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        list<SVMXC__ServiceMax_Processes__c> lstProcessNodesAssgnd = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> lstProcessNodesNotAssgnd = new list<SVMXC__ServiceMax_Processes__c>();
        
        CONF_SFMMobilePermissions.Response response = new CONF_SFMMobilePermissions.Response();
        CONF_SFMMobilePermissions.ProcessDetails fieldNames = new CONF_SFMMobilePermissions.ProcessDetails();
        CONF_SFMMobilePermissions.ProcessDetails objectDetails = new CONF_SFMMobilePermissions.ProcessDetails();
        CONF_SFMMobilePermissions.ProcessDetails assignedProcesses = new CONF_SFMMobilePermissions.ProcessDetails();
        CONF_SFMMobilePermissions.ProcessDetails unAssignedProcesses = new CONF_SFMMobilePermissions.ProcessDetails();
        CONF_SFMMobilePermissions.ProcessDetails lastProcessAssgnd = new CONF_SFMMobilePermissions.ProcessDetails();
        CONF_SFMMobilePermissions.ProcessDetails firstProcessAssgnd = new CONF_SFMMobilePermissions.ProcessDetails();
        CONF_SFMMobilePermissions.ProcessDetails lastProcessNotAssgnd = new CONF_SFMMobilePermissions.ProcessDetails();
        CONF_SFMMobilePermissions.ProcessDetails firstProcessNotAssgnd = new CONF_SFMMobilePermissions.ProcessDetails();
        CONF_SFMMobilePermissions.ProcessDetails countAssgndProcesses = new CONF_SFMMobilePermissions.ProcessDetails();
        CONF_SFMMobilePermissions.ProcessDetails countUnAssgndProcesses = new CONF_SFMMobilePermissions.ProcessDetails();
        
        String strAssigned = request.name;
        String strSortBy = request.sortBy;
        String strSrchTxt = request.searchText;
        String strObject = request.objectName;
        String strProcessPurpose = request.processType;
        
        String strSearchClause = '', strObjectNameClause = '', strPNOType = '', strIDClauseInAssgnd = '', strIDClauseInNotAssgnd = '';
        String strSortByClause = ' Order By SVMXC__Process__r.SVMXC__Name__c ASC ';
        
        if(strSortBy != null && strSortBy != '' && strSortBy.length() > 0)
            strSortByClause = ' Order By SVMXC__Process__r.' + strSortBy;    
            
        if(strSrchTxt != null && strSrchTxt != '' && strSrchTxt.length() > 0)
            strSearchClause = ' AND SVMXC__Process__r.SVMXC__Name__c Like \'%' + strSrchTxt + '%\'';
        
        if(strObject != null && strObject != '' && strObject.length() > 0)
            strObjectNameClause = ' AND SVMXC__Source_Object_Name__c = :strObject ';
        
        if(strProcessPurpose == 'CHECKLIST')
            strPNOType = ' AND SVMXC__Type__c = \'SOURCE\'';
        else
            strPNOType = ' AND SVMXC__Type__c = \'TARGET\'';
            
        String strName = '';
        if(request.processDetails != null)
        {
            for(CONF_SFMMobilePermissions.ProcessDetails eachProcessInfo: request.processDetails)
            {
                strName = eachProcessInfo.name;
                if(eachProcessInfo.id == 'FIRST_ID_ASSIGNED' && eachProcessInfo.name != null)
                    strIDClauseInAssgnd = ' AND SVMXC__Process__r.SVMXC__Name__c <= : strName ';
                else if(eachProcessInfo.id == 'FIRST_ID_UN_ASSIGNED' && eachProcessInfo.name != null)
                    strIDClauseInNotAssgnd = ' AND SVMXC__Process__r.SVMXC__Name__c <= : strName ';
                else if(eachProcessInfo.id == 'LAST_ID_ASSIGNED' && eachProcessInfo.name != null)
                    strIDClauseInAssgnd = ' AND SVMXC__Process__r.SVMXC__Name__c >= : strName ';
                else if(eachProcessInfo.id == 'LAST_ID_UN_ASSIGNED' && eachProcessInfo.name != null)
                    strIDClauseInNotAssgnd = ' AND SVMXC__Process__r.SVMXC__Name__c >= : strName '; 
            }
        }
        allObjs = Schema.getGlobalDescribe();
        for(String s : allObjs.keyset())    
            mapFieldAPIToName.put(allObjs.get(s).getDescribe().getName(),allObjs.get(s).getDescribe().getLabel());
         
        firstProcessAssgnd.id = 'FIRST_ID_ASSIGNED';
        
        firstProcessNotAssgnd.id = 'FIRST_ID_UN_ASSIGNED';
        
        lastProcessAssgnd.id = 'LAST_ID_ASSIGNED';
        
        lastProcessNotAssgnd.id = 'LAST_ID_UN_ASSIGNED';
        
        countAssgndProcesses.id = 'COUNT_ASSIGNED';
        countUnAssgndProcesses.id = 'COUNT_UNASSIGNED';
        
        fieldNames.name = 'FIELDS';
        fieldNames.processDetails.add(new ProcessDetails('SVMXC__Name__c', 'SVMXC__Name__c', '', '', ''));
        fieldNames.processDetails.add(new ProcessDetails('SVMXC__Source_Object_Name__c', 'SVMXC__Source_Object_Name__c', '', '', ''));
        fieldNames.processDetails.add(new ProcessDetails('LastModifiedDate', 'LastModifiedDate', '', '', ''));
        
        objectDetails.name = 'OBJECTS';
        objectDetails.processDetails.add(new ProcessDetails('--ALL--', (new CONF_SFMMobilePermissions()).getTAG016(), '', '', ''));
        
        assignedProcesses.processType = strProcessPurpose;
        assignedProcesses.name = 'ASSIGNED';
        
        unAssignedProcesses.processType = strProcessPurpose;
        unAssignedProcesses.name = 'UN-ASSIGNED';
        
        map<String, String> mapIdToSFProcess = (new CONF_SFMMobilePermissions()).getAssignedProcesses(request.svmxProfile);
        setAssignedProcesses.addAll(mapIdToSFProcess.values());
                
        system.debug(LoggingLevel.WARN, 'strSortByClause = ' + strSortByClause + '; strSearchClause = ' + strSearchClause + '; strObjectNameClause = ' + strObjectNameClause + '; strProcessPurpose = ' + strProcessPurpose + '; strIDClauseInNotAssgnd = ' + strIDClauseInNotAssgnd);
        
        intCountAssgnd = Database.countQuery('Select count() from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Process Node Objects\' AND SVMXC__Process__r.SVMXC__Purpose__c =:strProcessPurpose AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN (\'SVMXEVT_005\', \'SVMXEVT_003\') AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = \'Complete\' AND SVMXC__Process__c IN :setAssignedProcesses ' + strPNOType + strObjectNameClause);
        intCountNotAssgnd = Database.countQuery('Select count() from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Process Node Objects\' AND SVMXC__Process__r.SVMXC__Purpose__c =:strProcessPurpose AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN (\'SVMXEVT_005\', \'SVMXEVT_003\') AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = \'Complete\' AND SVMXC__Process__c NOT IN :setAssignedProcesses ' + strPNOType + strObjectNameClause + strSearchClause);
        
        lstProcessNodesAssgnd = Database.query('Select Id, SVMXC__Process__c, SVMXC__Source_Object_Name__c, SVMXC__Process__r.SVMXC__Name__c, SVMXC__Process__r.SVMXC__ProcessID__c, SVMXC__Process__r.LastModifiedDate from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Process Node Objects\' AND SVMXC__Process__r.SVMXC__Purpose__c =:strProcessPurpose AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN (\'SVMXEVT_005\', \'SVMXEVT_003\') AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = \'Complete\' AND SVMXC__Process__c IN :setAssignedProcesses ' + strPNOType + strObjectNameClause + strIDClauseInAssgnd + strSortByClause + ' LIMIT:intLimit ');
        lstProcessNodesNotAssgnd = Database.query('Select Id, SVMXC__Process__c, SVMXC__Source_Object_Name__c, SVMXC__Process__r.SVMXC__Name__c, SVMXC__Process__r.SVMXC__ProcessID__c, SVMXC__Process__r.LastModifiedDate from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Process Node Objects\' AND SVMXC__Process__r.SVMXC__Purpose__c =:strProcessPurpose AND SVMXC__Process__r.SVMXC__ProcessID__c NOT IN (\'SVMXEVT_005\', \'SVMXEVT_003\') AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = \'Complete\' AND SVMXC__Process__c NOT IN :setAssignedProcesses ' + strPNOType + strObjectNameClause + strSearchClause + strIDClauseInNotAssgnd + strSortByClause + ' LIMIT:intLimit ');
        
        countAssgndProcesses.name = String.valueOf(intCountAssgnd);
        countUnAssgndProcesses.name = String.valueOf(intCountNotAssgnd);
        
        for(SVMXC__ServiceMax_Processes__c eachPNO : lstProcessNodesAssgnd)
        {
            system.debug(LoggingLevel.WARN, 'eachPNO = ' + eachPNO);
            assignedProcesses.processDetails.add(new ProcessDetails(eachPNO.SVMXC__Process__c, eachPNO.SVMXC__Process__r.SVMXC__Name__c, eachPNO.SVMXC__Process__r.SVMXC__ProcessID__c, mapFieldAPIToName.get(eachPNO.SVMXC__Source_Object_Name__c), String.valueOf(eachPNO.SVMXC__Process__r.LastModifiedDate)));
            
            if(mapFieldAPIToName != null && mapFieldAPIToName.keySet().contains(eachPNO.SVMXC__Source_Object_Name__c))
                mapLabelToAPIName.put(mapFieldAPIToName.get(eachPNO.SVMXC__Source_Object_Name__c), eachPNO.SVMXC__Source_Object_Name__c);
        }
        
        for(SVMXC__ServiceMax_Processes__c eachPNO : lstProcessNodesNotAssgnd)
        {
            system.debug(LoggingLevel.WARN, 'eachPNO = ' + eachPNO);
            unAssignedProcesses.processDetails.add(new ProcessDetails(eachPNO.SVMXC__Process__c, eachPNO.SVMXC__Process__r.SVMXC__Name__c, eachPNO.SVMXC__Process__r.SVMXC__ProcessID__c, mapFieldAPIToName.get(eachPNO.SVMXC__Source_Object_Name__c), String.valueOf(eachPNO.SVMXC__Process__r.LastModifiedDate)));
            
            if(mapFieldAPIToName != null && mapFieldAPIToName.keySet().contains(eachPNO.SVMXC__Source_Object_Name__c))
                mapLabelToAPIName.put(mapFieldAPIToName.get(eachPNO.SVMXC__Source_Object_Name__c), eachPNO.SVMXC__Source_Object_Name__c);
        }
        
        if(lstProcessNodesAssgnd != null && lstProcessNodesAssgnd.size() > 0)
        {
            firstProcessAssgnd.name = lstProcessNodesAssgnd[0].SVMXC__Process__r.SVMXC__Name__c;
            lastProcessAssgnd.name = lstProcessNodesAssgnd[lstProcessNodesAssgnd.size() - 1].SVMXC__Process__r.SVMXC__Name__c;
        }
        
        system.debug(LoggingLevel.WARN, ' firstProcessAssgnd = ' + firstProcessAssgnd + '; lastProcessAssgnd = ' +  lastProcessAssgnd);
        
        if(lstProcessNodesNotAssgnd != null && lstProcessNodesNotAssgnd.size() > 0)
        {
            firstProcessNotAssgnd.name = lstProcessNodesNotAssgnd[0].SVMXC__Process__r.SVMXC__Name__c;
            lastProcessNotAssgnd.name = lstProcessNodesNotAssgnd[lstProcessNodesNotAssgnd.size() - 1].SVMXC__Process__r.SVMXC__Name__c;
        }
        
        system.debug(LoggingLevel.WARN, ' firstProcessNotAssgnd = ' + firstProcessNotAssgnd + '; lastProcessNotAssgnd = ' +  lastProcessNotAssgnd);
        
        lstObjectNames.addAll(mapLabelToAPIName.keySet());
        lstObjectNames.sort();
        for(String strEachObject : lstObjectNames)
            objectDetails.processDetails.add(new ProcessDetails(mapLabelToAPIName.get(strEachObject), strEachObject, '', strEachObject, ''));
            
        response.svmxProfile = request.svmxProfile;
        response.processDetails.add(fieldNames);
        response.processDetails.add(objectDetails);
        response.processDetails.add(assignedProcesses);
        response.processDetails.add(unAssignedProcesses);
        response.processDetails.add(firstProcessAssgnd);
        response.processDetails.add(firstProcessNotAssgnd);
        response.processDetails.add(lastProcessAssgnd);
        response.processDetails.add(lastProcessNotAssgnd);
        response.processDetails.add(countAssgndProcesses);
        response.processDetails.add(countUnAssgndProcesses);
        return response;
    }
    
    @RemoteAction
    global static CONF_SFMMobilePermissions.Response Save(String requestString){
        system.debug(LoggingLevel.WARN, 'requestString = ' + requestString);
        CONF_SFMMobilePermissions.Request request = (CONF_SFMMobilePermissions.Request)JSON.deserialize(requestString, CONF_SFMMobilePermissions.Request.class);
        Set<String> setAllProcessIds = new Set<String>();
        List<String> lstServiceFlowAccesstoDelete = new List<String>();
        CONF_SFMMobilePermissions.Response response = new CONF_SFMMobilePermissions.Response();
        List<SVMXC__ServiceMax_Config_Data__c> lstConfDataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        
        map<String, String> mapIdToSFProcess = (new CONF_SFMMobilePermissions()).getAssignedProcesses(request.svmxProfile);
        setAllProcessIds.addAll(mapIdToSFProcess.values());
        
        String strRecordTypeId = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Service Flow Access' Limit 1].Id;

        List<SVMXC__ServiceMax_Processes__c> lstEventProcesses = [Select Id, SVMXC__ProcessID__c From SVMXC__ServiceMax_Processes__c  
                                                                    where SVMXC__isPrivate__c = true AND SVMXC__isStandard__c = true AND 
                                                                    ( (SVMXC__Purpose__c = 'VIEW RECORD' AND SVMXC__ProcessID__c = 'SVMXEVT_005')
                                                                    OR (SVMXC__Purpose__c = 'STANDALONE CREATE' AND SVMXC__ProcessID__c = 'SVMXEVT_003')
                                                                    OR (SVMXC__Purpose__c = 'VIEW RECORD' AND SVMXC__ProcessID__c = 'EVT_005')
                                                                    OR (SVMXC__Purpose__c = 'STANDALONE CREATE' AND SVMXC__ProcessID__c = 'EVT_003') ) ];

        SVMXC__ServiceMax_Processes__c SVMXEventViewProcess, SVMXEventCreateProcess, SFEventViewProcess, SFEventCreateProcess = NULL;
        for(SVMXC__ServiceMax_Processes__c eachEvtPro: lstEventProcesses){
            if(eachEvtPro.SVMXC__ProcessID__c == 'SVMXEVT_005' ){
                SVMXEventViewProcess = eachEvtPro;
            }else if(eachEvtPro.SVMXC__ProcessID__c == 'SVMXEVT_003'){
                SVMXEventCreateProcess = eachEvtPro;
            }else if(eachEvtPro.SVMXC__ProcessID__c == 'EVT_005'){
                SFEventViewProcess = eachEvtPro;
            }else if(eachEvtPro.SVMXC__ProcessID__c == 'EVT_003'){
                SFEventCreateProcess = eachEvtPro;
            }
        }
        
        /*
        SVMXC__ServiceMax_Processes__c SVMXEventViewProcess =     [Select Id From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'VIEW RECORD' AND SVMXC__ProcessID__c = 'SVMXEVT_005' AND SVMXC__isPrivate__c = true AND SVMXC__isStandard__c = true limit 1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        SVMXC__ServiceMax_Processes__c SVMXEventCreateProcess =   [Select Id From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'STANDALONE CREATE' AND SVMXC__ProcessID__c = 'SVMXEVT_003' AND SVMXC__isPrivate__c = true AND SVMXC__isStandard__c = true limit 1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        SVMXC__ServiceMax_Processes__c SFEventViewProcess =       [Select Id From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'VIEW RECORD' AND SVMXC__ProcessID__c = 'EVT_005' AND SVMXC__isPrivate__c = true AND SVMXC__isStandard__c = true limit 1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        SVMXC__ServiceMax_Processes__c SFEventCreateProcess =     [Select Id From SVMXC__ServiceMax_Processes__c  where SVMXC__Purpose__c = 'STANDALONE CREATE' AND SVMXC__ProcessID__c = 'EVT_003' AND SVMXC__isPrivate__c = true AND SVMXC__isStandard__c = true limit 1];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        */

        for(CONF_SFMMobilePermissions.ProcessDetails eachProcessType: request.processDetails)
        {
            system.debug(LoggingLevel.WARN, 'eachProcessType = ' + eachProcessType);
            if(eachProcessType.name == 'INSERT')
            {
                for(CONF_SFMMobilePermissions.ProcessDetails eachProcessRec: eachProcessType.processDetails)
                {
                    SVMXC__ServiceMax_Config_Data__c configAccess = new SVMXC__ServiceMax_Config_Data__c();
                    configAccess.RecordTypeId = strRecordTypeId;
                    configAccess.SVMXC__Access_Configuration_Profile__c = request.svmxProfile;
                    configAccess.SVMXC__Dispatch_Process__c = eachProcessRec.Id;
                    lstConfDataToSave.add(configAccess);
                    //If Standard View Event Process is assigned then assign Standard View SVMX Event also
                    if(SFEventViewProcess != NULL && SVMXEventViewProcess != NULL && eachProcessRec.Id == SFEventViewProcess.Id)
                    {
                        SVMXC__ServiceMax_Config_Data__c configRec = new SVMXC__ServiceMax_Config_Data__c();
                        configRec.RecordTypeId = strRecordTypeId;
                        configRec.SVMXC__Access_Configuration_Profile__c = request.svmxProfile;
                        configRec.SVMXC__Dispatch_Process__c = SVMXEventViewProcess.Id;
                        lstConfDataToSave.add(configRec);
                    }
                    if(SFEventCreateProcess != NULL && SVMXEventCreateProcess != NULL && eachProcessRec.Id == SFEventCreateProcess.Id )
                    {
                        SVMXC__ServiceMax_Config_Data__c configRec = new SVMXC__ServiceMax_Config_Data__c();
                        configRec.RecordTypeId = strRecordTypeId;
                        configRec.SVMXC__Access_Configuration_Profile__c = request.svmxProfile;
                        configRec.SVMXC__Dispatch_Process__c = SVMXEventCreateProcess.Id;
                        lstConfDataToSave.add(configRec);
                    }
                }
            }
            else if(eachProcessType.name == 'DELETE')
            {
                for(CONF_SFMMobilePermissions.ProcessDetails eachProcessRec: eachProcessType.processDetails)
                {
                    if(setAllProcessIds.contains(eachProcessRec.Id))
                        lstServiceFlowAccesstoDelete.add(eachProcessRec.Id);
                    //If Standard View Event Process is unassigned then unassign Standard View SVMX Event also
                    if(SFEventViewProcess != NULL && SVMXEventViewProcess!= NULL && eachProcessRec.Id == SFEventViewProcess.Id)
                        lstServiceFlowAccesstoDelete.add(SVMXEventViewProcess.Id);
                    if(SFEventCreateProcess != NULL && SVMXEventCreateProcess != NULL && eachProcessRec.Id == SFEventCreateProcess.Id)
                        lstServiceFlowAccesstoDelete.add(SVMXEventCreateProcess.Id);
                }
            }
        }
        
        if(lstServiceFlowAccesstoDelete != null && lstServiceFlowAccesstoDelete.size() > 0){
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                delete [Select Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Access_Configuration_Profile__c =:request.svmxProfile and SVMXC__RecordType_Name__c = 'Service Flow Access' AND SVMXC__Dispatch_Process__c IN:lstServiceFlowAccesstoDelete];
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        
        if(lstConfDataToSave != null && lstConfDataToSave.size() > 0){
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfDataToSave, COMM_SecurityUtils.Access.Upsertable)){
                upsert lstConfDataToSave;  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        return (new CONF_SFMMobilePermissions()).getProcesses(request);
    }
    
    @RemoteAction
    global static CONF_SFMMobilePermissions.Response addAllChecklist(String requestString){
        system.debug(LoggingLevel.WARN, 'Heap size before = ' + Limits.getHeapSize());
        CONF_SFMMobilePermissions.Request request = (CONF_SFMMobilePermissions.Request)JSON.deserialize(requestString, CONF_SFMMobilePermissions.Request.class);
        Set<String> setAllProcessIds = new Set<String>();
        map<String, String> mapIdToSFProcess = new map<String, String>();
        String strSearchClause = '', strObjectNameClause = '', strPNOType = '';
        CONF_SFMMobilePermissions.Response response = new CONF_SFMMobilePermissions.Response();
        List<SVMXC__ServiceMax_Processes__c> lstProcesses = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstConfDataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        String strSrchTxt = request.searchText;
        String strObject = request.objectName;
        String strProcessPurpose = request.processType;
            
        if(strSrchTxt != null && strSrchTxt != '' && strSrchTxt.length() > 0)
            strSearchClause = ' AND SVMXC__Process__r.SVMXC__Name__c Like \'%' + strSrchTxt + '%\'';
        
        if(strObject != null && strObject != '' && strObject.length() > 0)
            strObjectNameClause = ' AND SVMXC__Source_Object_Name__c = :strObject ';
        
        if(strProcessPurpose == 'CHECKLIST')
            strPNOType = ' AND SVMXC__Type__c = \'SOURCE\'';
        else
            strPNOType = ' AND SVMXC__Type__c = \'TARGET\'';
        
        mapIdToSFProcess = (new CONF_SFMMobilePermissions()).getAssignedProcesses(request.svmxProfile);
        setAllProcessIds.addAll(mapIdToSFProcess.values());
        
        String strRecordTypeId = [Select Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Service Flow Access' Limit 1].Id;
        
        lstProcesses = Database.query('Select Id, SVMXC__Process__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'Process Node Objects\' AND SVMXC__Process__r.SVMXC__Purpose__c = :strProcessPurpose AND SVMXC__Process__c NOT IN:setAllProcessIds AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = \'Complete\'' + strPNOType + strObjectNameClause + strSearchClause);
        
        for(SVMXC__ServiceMax_Processes__c eachProcess : lstProcesses)
        {
            SVMXC__ServiceMax_Config_Data__c configAccess = new SVMXC__ServiceMax_Config_Data__c();
            configAccess.RecordTypeId = strRecordTypeId;
            configAccess.SVMXC__Access_Configuration_Profile__c = request.svmxProfile;
            configAccess.SVMXC__Dispatch_Process__c = eachProcess.SVMXC__Process__c;
            lstConfDataToSave.add(configAccess);
        }
        
        if(lstConfDataToSave != null && lstConfDataToSave.size() > 0){
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstConfDataToSave, COMM_SecurityUtils.Access.Upsertable)){
                insert lstConfDataToSave;  //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
            }
        }
        
        response.svmxProfile = request.svmxProfile;
        response = (new CONF_SFMMobilePermissions()).getProcesses(request);
        system.debug(LoggingLevel.WARN, ' response = ' + response);
        system.debug(LoggingLevel.WARN, 'Heap size after = ' + Limits.getHeapSize());
        return response;
    }
    public String getTAG016(){return system.label.CONF020_TAG016;}//--ALL--
    public String getTAG021(){return system.label.CONF020_TAG007;}//--None--
}