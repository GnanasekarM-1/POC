/* Security Scanned */
public with sharing class SFM_GetListOfProcesses {
    
    public SFM_getListOfProcesses()
    {
        
    }
    public SFM_WrapperDef.SFM_Response_ProcessNode GetAllProcesses(SFM_WrapperDef.SFM_Request prequest)
    {
        Boolean isPrivate = false;
        Boolean isLinkedProcess = false;
        String strObjectName = '';
        Boolean isFeatureChecklistEnabled = false;
        Boolean isChecklistDisabled = false; // Added for BAC-5181
        if(prequest != null && prequest.stringMap != null && prequest.stringMap.size() > 0)
        {
            for(Integer i = 0;i<prequest.stringMap.size();i++)
            {
                if(prequest.stringMap[i].key != null && prequest.stringMap[i].value != null && prequest.stringMap[i].key.touppercase() == 'SHOWPRIVATE' && prequest.stringMap[i].value.touppercase() == 'YES')
                    isPrivate = true;
                else if(prequest.stringMap[i].key != null && prequest.stringMap[i].value != null && prequest.stringMap[i].key.touppercase() == 'LINKEDPROCESS' && prequest.stringMap[i].value.touppercase() == 'YES')
                    isLinkedProcess = true; 
                else if(prequest.stringMap[i].key != null && prequest.stringMap[i].value != null && prequest.stringMap[i].key.touppercase() == 'OBJECTNAME')
                     strObjectName = prequest.stringMap[i].value;  
                else if(prequest.stringMap[i].key != null && prequest.stringMap[i].value != null && prequest.stringMap[i].key.touppercase() == 'CHECKLISTFEATURE' && prequest.stringMap[i].value.touppercase() == 'YES')      
                    isFeatureChecklistEnabled = true;
                else if(prequest.stringMap[i].key != null && prequest.stringMap[i].value != null && prequest.stringMap[i].key.touppercase() == 'CHECKLISTDISABLED' && prequest.stringMap[i].value.touppercase() == 'YES') // Added for BAC-5181  
                    isChecklistDisabled = true;         
            }
        }
        SVMX_Debug  log = new SVMX_Debug();
        DCON_Utils utils = new DCON_Utils();
        Boolean response_success;
        String response_message;
        String response_tagId;
        List<SVMXC__ServiceMax_Processes__c> processNodes = new List<SVMXC__ServiceMax_Processes__c>();
        List<SFM_WrapperDef.SFM_StringMap> strmap = new List<SFM_WrapperDef.SFM_StringMap>();
        Boolean s = false;
        String msg;
        String tid;
        Set<String> setAllProcessId = new Set<String>();
        //Commenting below line as it is not needed by the designer for fixing defect 043119
        //List<SFM_WrapperDef.SFM_StringMap> lstStrMapProID_CountChecklist = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_MapStringMap> lstProIdSrcTarObjName = new List<SFM_WrapperDef.SFM_MapStringMap>();
    
    //Checking checklist feature is enable or not
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    Map<String, String> mapSettingToEnableChecklist = commSettings.SVMX_getSettingList('GLOB001');    
    Boolean isChecklistEnable = false;
    if(mapSettingToEnableChecklist.containsKey('GBL029') && mapSettingToEnableChecklist.get('GBL029') != null && Boolean.valueOf(mapSettingToEnableChecklist.get('GBL029')))
      isChecklistEnable = true;
         if(isChecklistDisabled){ // Added for BAC-5181
            isFeatureChecklistEnabled = false;
            isChecklistEnable = false;
        }
        log.login('SFM_getListOfProcesses', 'GetAllProcesses');
        try
        {
            log.setlog('QUERY_TEXT', 'Fetching all the processes');
            
            if(isLinkedProcess && strObjectName.length() > 0)
            {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<SVMXC__ServiceMax_Processes__c> lstProcessNodeObjects = [select Id, SVMXC__Process__c from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Process Node Objects' and SVMXC__Source_Object_Name__c =: strObjectName and ( (SVMXC__Type__c = 'TARGET' and SVMXC__Process__r.SVMXC__Purpose__c = 'STANDALONE EDIT') or (SVMXC__Type__c = 'SOURCE' and (SVMXC__Process__r.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL' or SVMXC__Process__r.SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD')))];
                system.debug('lstProcessNodeObjects'+lstProcessNodeObjects.size()+lstProcessNodeObjects);
                set<String> setProcessId = new set<String>();
                if(lstProcessNodeObjects.size() > 0){
                    for(SVMXC__ServiceMax_Processes__c pro : lstProcessNodeObjects){
                        if(pro.SVMXC__Process__c != null)
                            setProcessId.add(pro.SVMXC__Process__c);
                    }
                }
                system.debug('setProcessId'+setProcessId.size()+setProcessId);
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodes = [Select Id, SVMXC__IsGlobal__c, SVMXC__Name__c, LastModifiedBy.Name, CreatedBy.Name, SVMXC__Purpose__c, SVMXC__IsStandard__c, SVMXC__IsPrivate__c, Name, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Page_Layout__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__IsStandalone__c, LastModifiedDate, SVMXC__Target_Object_label__c From SVMXC__ServiceMax_Processes__c where Id IN : setProcessId and SVMXC__Record_Type_Name__c='Target Manager' AND (SVMXC__IsStandard__c = false OR (SVMXC__IsStandard__c = true AND SVMXC__IsPrivate__c = false))];
                system.debug('processNodes'+processNodes.size()+processNodes);
                if(isPrivate)
                {
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    list<SVMXC__ServiceMax_Processes__c> lstPrivateProcesses = new list<SVMXC__ServiceMax_Processes__c>();
                    lstPrivateProcesses = [Select Id, SVMXC__IsGlobal__c, SVMXC__Name__c, LastModifiedBy.Name, CreatedBy.Name, SVMXC__Purpose__c, SVMXC__IsStandard__c, SVMXC__IsPrivate__c, Name, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Page_Layout__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__IsStandalone__c, LastModifiedDate, SVMXC__Target_Object_label__c From SVMXC__ServiceMax_Processes__c where Id IN : setProcessId and SVMXC__Record_Type_Name__c='Target Manager' AND  SVMXC__IsStandard__c = true AND SVMXC__IsPrivate__c = true];
                    system.debug('lstPrivateProcesses'+lstPrivateProcesses.size()+lstPrivateProcesses);
                    if(lstPrivateProcesses.size() > 0)
                        processNodes.addall(lstPrivateProcesses);
                }
                system.debug('processNodes'+processNodes.size()+processNodes);
            }
            else if(!isLinkedProcess){
                if(isFeatureChecklistEnabled)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodes = [Select Id, SVMXC__IsGlobal__c, SVMXC__Name__c, LastModifiedBy.Name, CreatedBy.Name, SVMXC__Purpose__c, SVMXC__IsStandard__c, SVMXC__IsPrivate__c, Name, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Page_Layout__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__IsStandalone__c, LastModifiedDate, SVMXC__Target_Object_label__c From SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c='Target Manager' AND (SVMXC__IsStandard__c = false OR (SVMXC__IsStandard__c = true AND SVMXC__IsPrivate__c = false)) AND SVMXC__Purpose__c = 'CHECKLIST'];
                else if(isChecklistEnable)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodes = [Select Id, SVMXC__IsGlobal__c, SVMXC__Name__c, LastModifiedBy.Name, CreatedBy.Name,  SVMXC__Purpose__c, SVMXC__IsStandard__c, SVMXC__IsPrivate__c, Name, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Page_Layout__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__IsStandalone__c, LastModifiedDate, SVMXC__Target_Object_label__c From SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c='Target Manager' AND (SVMXC__IsStandard__c = false OR (SVMXC__IsStandard__c = true AND SVMXC__IsPrivate__c = false))];
                else
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodes = [Select Id, SVMXC__IsGlobal__c, SVMXC__Name__c, LastModifiedBy.Name, CreatedBy.Name, SVMXC__Purpose__c, SVMXC__IsStandard__c, SVMXC__IsPrivate__c, Name, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Page_Layout__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__IsStandalone__c, LastModifiedDate, SVMXC__Target_Object_label__c From SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c='Target Manager' AND (SVMXC__IsStandard__c = false OR (SVMXC__IsStandard__c = true AND SVMXC__IsPrivate__c = false)) AND SVMXC__Purpose__c != 'CHECKLIST'];
                if(isPrivate)
                {
                    list<SVMXC__ServiceMax_Processes__c> lstPrivateProcesses = new list<SVMXC__ServiceMax_Processes__c>();
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstPrivateProcesses = [Select Id, SVMXC__IsGlobal__c, SVMXC__Name__c, LastModifiedBy.Name, CreatedBy.Name,  SVMXC__Purpose__c, SVMXC__IsStandard__c, SVMXC__IsPrivate__c, Name, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Page_Layout__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__IsStandalone__c, LastModifiedDate, SVMXC__Target_Object_label__c From SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c='Target Manager' AND  SVMXC__IsStandard__c = true AND SVMXC__IsPrivate__c = true];
                    if(lstPrivateProcesses.size() > 0)
                        processNodes.addall(lstPrivateProcesses);
                }
            }
            
            for(SVMXC__ServiceMax_Processes__c pro: processNodes)
            {
                pro.SVMXC__Target_Object_label__c = string.valueof(pro.LastModifiedDate.format());
                setAllProcessId.add(pro.id);
            }
            system.debug(LoggingLevel.WARN ,'setAllProcessId: ' + setAllProcessId.size()+'----'+setAllProcessId);
            
            /*Commenting below piece of code as it is no more needed by the designer - for fixing defect 043119
            //Code for counting checklist records for every SFM process
            Map<String, List<SVMXC__Checklist__c>> mapProcessIDAndListOfChecklist = new Map<String, List<SVMXC__Checklist__c>>();
            if(setAllProcessId != null && setAllProcessId.size() > 0){
                List<SVMXC__Checklist__c> lstChecklist = [SELECT Id, SVMXC__ChecklistProcessID__c from SVMXC__Checklist__c WHERE SVMXC__ChecklistProcessID__c IN : setAllProcessId];
                if(lstChecklist != null && lstChecklist.size() > 0){
                    for(SVMXC__Checklist__c objCHK : lstChecklist){
                        if(!mapProcessIDAndListOfChecklist.ContainsKey(objCHK.SVMXC__ChecklistProcessID__c))
                            mapProcessIDAndListOfChecklist.put(objCHK.SVMXC__ChecklistProcessID__c, new List<SVMXC__Checklist__c>());
                        mapProcessIDAndListOfChecklist.get(objCHK.SVMXC__ChecklistProcessID__c).add(objCHK);
                    }
                }
            }
            System.debug(LoggingLevel.WARN ,'mapProcessIDAndListOfChecklist: ' + mapProcessIDAndListOfChecklist.size()+'---'+mapProcessIDAndListOfChecklist);
            if(mapProcessIDAndListOfChecklist.size() > 0){
                for(String proID : mapProcessIDAndListOfChecklist.keyset()){
                    SFM_WrapperDef.SFM_StringMap objTemp = new SFM_WrapperDef.SFM_StringMap(proID, String.ValueOf(mapProcessIDAndListOfChecklist.get(proID).size()));
                    lstStrMapProID_CountChecklist.add(objTemp);
                }
            }
            System.debug(LoggingLevel.WARN ,'lstStrMapProID_CountChecklist: ' + lstStrMapProID_CountChecklist.size()+'---'+lstStrMapProID_CountChecklist);
            */
            
            //Code for finding Source and Target Object Name of the process         
            List<SVMXC__ServiceMax_Processes__c> lstALLProcessNodeObjects = new List<SVMXC__ServiceMax_Processes__c>();
            Map<String, List<SVMXC__ServiceMax_Processes__c>> mapProIdAndListNode = new Map<String, List<SVMXC__ServiceMax_Processes__c>>();
            Map<String, String> mapAPINameAndLabel = new Map<String, String>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            for(String str : schemaMap.keyset()){
                Schema.DescribeSObjectResult objDescribe = schemaMap.get(str).getDescribe();
                mapAPINameAndLabel.put(objDescribe.getName(), objDescribe.getLabel());
            }
            if(setAllProcessId != null && setAllProcessId.size() > 0){
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                lstALLProcessNodeObjects = [SELECT Id, SVMXC__Process__c, SVMXC__Type__c, SVMXC__Source_Object_Name__c FROM  SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process__c IN: setAllProcessId AND RecordType.Name = 'Process Node Objects' AND (SVMXC__Type__c = 'TARGET' OR SVMXC__Type__c = 'SOURCE')];
            }
            System.debug(LoggingLevel.WARN ,'lstALLProcessNodeObjects: ' + lstALLProcessNodeObjects.size()+'---'+lstALLProcessNodeObjects);
            
            for(SVMXC__ServiceMax_Processes__c objProcessNode : lstALLProcessNodeObjects){
                if(!mapProIdAndListNode.ContainsKey(objProcessNode.SVMXC__Process__c))
                    mapProIdAndListNode.put(objProcessNode.SVMXC__Process__c, new List<SVMXC__ServiceMax_Processes__c>());
                mapProIdAndListNode.get(objProcessNode.SVMXC__Process__c).add(objProcessNode);
            }
            for(String proID : mapProIdAndListNode.keyset()){
                List<SVMXC__ServiceMax_Processes__c> lstProcessNode = mapProIdAndListNode.get(proID);
                List<SFM_WrapperDef.SFM_StringMap> lstStrMap = new List<SFM_WrapperDef.SFM_StringMap>();
                for(SVMXC__ServiceMax_Processes__c objTemp : lstProcessNode){
                    if(objTemp.SVMXC__Source_Object_Name__c != null && mapAPINameAndLabel.containsKey(objTemp.SVMXC__Source_Object_Name__c)){
                        SFM_WrapperDef.SFM_StringMap objStrMap = new SFM_WrapperDef.SFM_StringMap(objTemp.SVMXC__Type__c, mapAPINameAndLabel.get(objTemp.SVMXC__Source_Object_Name__c), objTemp.SVMXC__Source_Object_Name__c);
                        lstStrMap.add(objStrMap);
                    }
                }
                SFM_WrapperDef.SFM_MapStringMap objTempMSM = new SFM_WrapperDef.SFM_MapStringMap(proID, lstStrMap);
                lstProIdSrcTarObjName.add(objTempMSM);
            }
            System.debug(LoggingLevel.WARN ,'lstProIdSrcTarObjName: ' + lstProIdSrcTarObjName.size()+'---'+lstProIdSrcTarObjName);
            
            system.debug('TEST LOG: ' + processNodes.size()+processNodes);
            response_success = true;
        }
        catch (Exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            response_success = false;
            response_message = ex.getmessage();
        }
        log.logout();
        log.print();
        SFM_WrapperDef.SFM_Response_ProcessNode oResponseNode = new SFM_WrapperDef.SFM_Response_ProcessNode(processNodes);
        //Commenting below line as it is not needed by the designer - for fixing defect 043119
        //oResponseNode.response.stringMap = lstStrMapProID_CountChecklist;
        oResponseNode.response.MapStringMap = lstProIdSrcTarObjName;
        oResponseNode.response.success = response_success;
        oResponseNode.response.logMsg = log.getlog();
        oResponseNode.response.message = response_message;
        return oResponseNode;
    }
    /**
    * API to fetch the number of process using the given page layout.
    */
    public SFM_WrapperDef.SFM_Response getCountOfProcesses(SFM_WrapperDef.SFM_Request request) {
        
        SFM_WrapperDef.SFM_Response countResponse = new SFM_WrapperDef.SFM_Response();
        countResponse.success = false;
        String page_layout_id = '';
        String process_id = '';
        
        System.debug(LoggingLevel.WARN, 'Processing getCountOfProcesses() request' );       
        
        try{
        
            if(request != null && request.stringMap != null && request.stringMap.size() > 0){
                    for(SVMXC.SFM_WrapperDef.SFM_StringMap stringMap : request.stringMap){
                        if(stringMap.key != null && stringMap.key.toUpperCase() == 'PAGEID' && stringMap.value != null){
                            page_layout_id = stringMap.value;
                            System.debug('Page layout ID is :' + page_layout_id);
                        }
                        if(stringMap.key != null && stringMap.key.toUpperCase() == 'PROCESSID' && stringMap.value != null){
                            process_id = stringMap.value;
                            System.debug('Process ID is :' + process_id);
                        }   
                    }
                    if(page_layout_id != '' && process_id != '' ) {
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        Integer count = [SELECT count() FROM SVMXC__ServiceMax_Processes__c  WHERE SVMXC__Page_Layout__r.SVMXC__Page_Layout_ID__c =: page_layout_id and SVMXC__ProcessID__c =: process_id and SVMXC__Record_Type_Name__c = 'Target Manager'];
                        System.debug('Process count is :' + count);
                        if(count > 1) {
                            countResponse.success = true;
                        }
                    }
            }
        }catch(exception ex){           
            countResponse.message = ex.getMessage();
            System.debug(LoggingLevel.WARN, 'Exception while fetching all the count() of processes for given page layout in getCountOfProcesses() api: ' + ex.getMessage());
        }
        
        return countResponse;
    }   

    /*
     * This method is used to retrieve all the SFM process of type STANDALONE EDIT,SOURCE TO TARGET ALL, SOURCE TO TARGET CHILD.
     * 
     * 
     * @param request can be empty or can have specific process ids 
     * 
     * @return Returns the list of process details with data required for process list view
     */

    public List<SFM_WrapperDef2.SFM2_ListViewDetails> getListOfProcess_V2(String entityType){
        
        
        Map<String, Schema.SObjectType> sobjectDescribeMap = COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
        Map<Id, List<String>> processTagsMap = new Map<Id, List<String>>();
        List<SFM_WrapperDef2.SFM2_ListViewDetails> processWrapperList = new List<SFM_WrapperDef2.SFM2_ListViewDetails>();
        
        try{
            /*
                Secuirty Check : FLS check for each of the fields queried
            */
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Name__c', 'SVMXC__Description__c', 'SVMXC__ProcessID__c', 'SVMXC__Purpose__c', 'SVMXC__Dispatch_Process_Status__c', 'LastModifiedDate', 'CreatedDate', 'SVMXC__IsStandard__c', 'SVMXC__Source_Object_Name__c', 'SVMXC__Target_Object_label__c', 'RecordType.Name', 'SVMXC__Type__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }


            String queryStr = 'SELECT Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Purpose__c, SVMXC__Dispatch_Process_Status__c, LastModifiedDate, LastModifiedBy.Name, CreatedDate, CreatedBy.Name, SVMXC__IsStandard__c, (SELECT ID, SVMXC__Source_Object_Name__c, SVMXC__Target_Object_label__c, RecordType.Name, SVMXC__Type__c FROM ServiceMax_Processes3__r WHERE RecordType.Name = \'Process Node Objects\' AND SVMXC__Type__c IN (\'SOURCE\', \'TARGET\') ) ' + 
                                                                  + ' FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = \'Target Manager\' AND (SVMXC__IsStandard__c = false OR (SVMXC__IsStandard__c = true AND SVMXC__IsPrivate__c = false))';

            /*
                SOQL to get the target manager and the related process node records
            */

            if(entityType == SFM_DesignerUtils.entity_sfm){
                queryStr += ' AND SVMXC__Purpose__c IN (\'STANDALONE EDIT\',\'SOURCE TO TARGET ALL\', \'SOURCE TO TARGET CHILD\', \'VIEW RECORD\', \'STANDALONE CREATE\') ';
            }else if(entityType == SFM_DesignerUtils.entity_opdoc){
                queryStr += ' AND SVMXC__Purpose__c IN (\'OUTPUT DOCUMENT\') ';
            }else if(entityType == SFM_DesignerUtils.entity_checklist){
                queryStr += ' AND SVMXC__Purpose__c IN (\'CHECKLIST\') ';
            }
            
            Map<Id, SVMXC__ServiceMax_Processes__c> processMap = new Map<Id, SVMXC__ServiceMax_Processes__c>((List<SVMXC__ServiceMax_Processes__c>)Database.query(queryStr));      
            

            Set<Id> processIds = processMap.keySet();

            /*
                Checking if the process being referenced or used by any other linked SFM, Mutlisource, Wizards & Schedule SFM
            */
            Set<Id> dependentProcessIds = SFM_GetEntityDependencies.entityDependencyCheck(processIds, entityType);

            /*
                Secuirty Check : FLS check for each of the fields queried
            */
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__SM_Tag_Element__c', new List<String>{'SVMXC__SM_Tag_Definition__c','SVMXC__SM_Tag_Definition__r.Name','SVMXC__SM_Target_Object__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            for(SVMXC__SM_Tag_Element__c tagElement : [SELECT SVMXC__SM_Tag_Definition__r.Name,SVMXC__SM_Target_Object__c FROM SVMXC__SM_Tag_Element__c WHERE SVMXC__SM_Target_Object__c IN: processIds]){ 

                if(tagElement.SVMXC__SM_Target_Object__c != null){
                    
                    List<String> tempList = new List<String>();
                    if(processTagsMap.containsKey(tagElement.SVMXC__SM_Target_Object__c)){
                        tempList = processTagsMap.get(tagElement.SVMXC__SM_Target_Object__c);
                    }

                    tempList.add(tagElement.SVMXC__SM_Tag_Definition__r.Name);

                    processTagsMap.put(tagElement.SVMXC__SM_Target_Object__c, tempList);
                }
            }
            
           

            for(SVMXC__ServiceMax_Processes__c processRecord : processMap.values()){

                SFM_WrapperDef2.SFM2_ListViewDetails sfmWrapper = new SFM_WrapperDef2.SFM2_ListViewDetails();
                sfmWrapper.entityType = entityType ; 

                if(dependentProcessIds.contains(processRecord.Id)){
                    sfmWrapper.dependencyExist = true;
                }

                for(SVMXC__ServiceMax_Processes__c processNodeRecord : processRecord.ServiceMax_Processes3__r){
                
                    if(processNodeRecord.RecordType.Name == 'Process Node Objects' && processNodeRecord.SVMXC__Source_Object_Name__c != null){
                        String sobjectType = processNodeRecord.SVMXC__Source_Object_Name__c.trim();
                        String objectLabel =  sobjectDescribeMap.containsKey(sobjectType) ? sobjectDescribeMap.get(sobjectType).getDescribe().getLabel(): '';

                        if(processNodeRecord.SVMXC__Type__c == 'SOURCE'){
                            sfmWrapper.sourceObject = objectLabel;    
                            sfmWrapper.sourceObjectApi = sobjectType;                      
                        }else{
                            sfmWrapper.targetObject = objectLabel; 
                            sfmWrapper.targetObjectApi = sobjectType;  
                        }
                    }
                }

                SFM_WrapperDef2.SFM2_EntityDetail sfmEntityDetail = buildEntityDetail(processRecord);
                if(processTagsMap.containsKey(processRecord.Id)){
                    sfmEntityDetail.tagsList = processTagsMap.get(processRecord.Id);
                }
                sfmWrapper.entityDetail = sfmEntityDetail; 
                processWrapperList.add(sfmWrapper);
            } 

            
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'getListOfProcess_V2 - Exit , Response ' + ex.getMessage());
            throw ex;
        }     

        System.debug(LoggingLevel.INFO, 'getListOfProcess_V2 - Exit , Response : processWrapperList ' + processWrapperList);
        return processWrapperList;
    }

    public List<SFM_WrapperDef2.SFM2_Dependency> getListOfLinkedProcess(List<String> targetObjects){
        List<SFM_WrapperDef2.SFM2_Dependency> linkedProcessList ;

        try{
            /*
                Secuirty Check : FLS check for each of the fields queried
            */
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__IsStandard__c', 'SVMXC__Process__c', 'SVMXC__Name__c', 'SVMXC__Description__c', 'SVMXC__Dispatch_Process_Status__c', 'LastModifiedDate',
                                                                                                                        'CreatedDate', 'SVMXC__Source_Object_Name__c', 'SVMXC__Purpose__c', 'RecordType.Name', 'SVMXC__Type__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }

            if(targetObjects != null && !targetObjects.isEmpty()){

                Map<String, List<SFM_WrapperDef2.SFM2_EntityDetail>> processObjectMap = new Map<String, List<SFM_WrapperDef2.SFM2_EntityDetail>>(); 
                SFM_WrapperDef2.SFM2_EntityDetail sfmEntityDetail;
                
                for(SVMXC__ServiceMax_Processes__c processRecord : [SELECT Id, SVMXC__Process__c, SVMXC__Process__r.Id, SVMXC__Process__r.SVMXC__Name__c, SVMXC__Process__r.SVMXC__Description__c, SVMXC__Process__r.SVMXC__Purpose__c, SVMXC__Source_Object_Name__c,
                                                                      SVMXC__Process__r.SVMXC__IsStandard__c, SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c, SVMXC__Process__r.LastModifiedDate, SVMXC__Process__r.CreatedDate,
                                                                      SVMXC__Process__r.CreatedBy.Name, SVMXC__Process__r.LastModifiedBy.Name FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Process Node Objects' AND SVMXC__Source_Object_Name__c IN: targetObjects AND
                                                                      ((SVMXC__Type__c = 'TARGET' AND SVMXC__Process__r.SVMXC__Purpose__c = 'STANDALONE EDIT') OR (SVMXC__Type__c = 'SOURCE' AND SVMXC__Process__r.SVMXC__Purpose__c IN ('SOURCE TO TARGET ALL', 'SOURCE TO TARGET CHILD')))
                                                                      AND (SVMXC__Process__r.SVMXC__IsStandard__c = false OR (SVMXC__Process__r.SVMXC__IsStandard__c = true AND SVMXC__Process__r.SVMXC__IsPrivate__c = false))]){

                    List<SFM_WrapperDef2.SFM2_EntityDetail> tempEntityList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                    if(processObjectMap.containsKey(processRecord.SVMXC__Source_Object_Name__c)){
                        tempEntityList = processObjectMap.get(processRecord.SVMXC__Source_Object_Name__c);
                    }
                    sfmEntityDetail = buildEntityDetail(processRecord.SVMXC__Process__r);
                    tempEntityList.add(sfmEntityDetail);
                    processObjectMap.put(processRecord.SVMXC__Source_Object_Name__c, tempEntityList);
                }

                if(!processObjectMap.isEmpty()){
                    linkedProcessList = new List<SFM_WrapperDef2.SFM2_Dependency>();
                    
                    for(String objectApiName : processObjectMap.keySet()){
                        linkedProcessList.add(new SFM_WrapperDef2.SFM2_Dependency(null, objectApiName, processObjectMap.get(objectApiName)));
                    }
                }
            } 
        
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'getListOfLinkedProcess - Exit , Response ' + ex.getMessage());
            throw ex;
        }

        return linkedProcessList;
    }
    public List<SFM_WrapperDef2.SFM2_EntityDetail> getListOfChecklistProcess(List<String> targetObjects){
        try{
            /*
                Secuirty Check : FLS check for each of the fields queried
            */
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__IsStandard__c', 'SVMXC__Process__c', 'SVMXC__Name__c', 'SVMXC__Description__c', 'SVMXC__Dispatch_Process_Status__c', 'LastModifiedDate',
                                                                                                                        'CreatedDate', 'SVMXC__Source_Object_Name__c', 'SVMXC__Purpose__c', 'RecordType.Name', 'SVMXC__Type__c'}, COMM_SecurityUtils.Access.Accessible)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SFM_WrapperDef2.SFM2_EntityDetail> checklistProcessList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
            if(targetObjects != null && !targetObjects.isEmpty()){
                SFM_WrapperDef2.SFM2_EntityDetail sfmEntityDetail;
                for(SVMXC__ServiceMax_Processes__c processRecord : [SELECT Id, SVMXC__Process__c, SVMXC__Process__r.Id, SVMXC__Process__r.SVMXC__Name__c, SVMXC__Process__r.SVMXC__Description__c, SVMXC__Process__r.SVMXC__Purpose__c, SVMXC__Source_Object_Name__c,
                                                                    SVMXC__Process__r.SVMXC__IsStandard__c, SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c, SVMXC__Process__r.LastModifiedDate, SVMXC__Process__r.CreatedDate,
                                                                    SVMXC__Process__r.CreatedBy.Name, SVMXC__Process__r.LastModifiedBy.Name FROM SVMXC__ServiceMax_Processes__c
                                                                    WHERE RecordType.Name = 'Process Node Objects' AND SVMXC__Source_Object_Name__c IN: targetObjects AND SVMXC__Type__c = 'SOURCE' AND SVMXC__Process__r.SVMXC__Purpose__c = 'CHECKLIST' AND
                                                                    (SVMXC__Process__r.SVMXC__IsStandard__c = false OR (SVMXC__Process__r.SVMXC__IsStandard__c = true AND SVMXC__Process__r.SVMXC__IsPrivate__c = false))
                                                                    AND SVMXC__Process__r.SVMXC__Dispatch_Process_Status__c = 'Complete']) {
                    sfmEntityDetail = buildEntityDetail(processRecord.SVMXC__Process__r);
                    checklistProcessList.add(sfmEntityDetail);
                }
            }
            return checklistProcessList;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'getListOfLinkedProcess - Exit , Response ' + ex.getMessage());
            throw ex;
        }
    }
    SFM_WrapperDef2.SFM2_EntityDetail buildEntityDetail(SVMXC__ServiceMax_Processes__c processRecord){
        SFM_WrapperDef2.SFM2_EntityDetail sfmEntityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
        sfmEntityDetail.entityId = processRecord.Id;
        sfmEntityDetail.entityName = processRecord.SVMXC__Name__c;
        sfmEntityDetail.entityDescription = processRecord.SVMXC__Description__c;
        sfmEntityDetail.entitySubType = processRecord.SVMXC__Purpose__c;
        sfmEntityDetail.isStandard = processRecord.SVMXC__IsStandard__c;
        sfmEntityDetail.entityStatus = processRecord.SVMXC__Dispatch_Process_Status__c;
        sfmEntityDetail.lastModifiedDate = String.valueOfGmt(processRecord.LastModifiedDate);
        sfmEntityDetail.createdDate = String.valueOfGmt(processRecord.CreatedDate);
        sfmEntityDetail.createdBy = processRecord.CreatedBy.Name;
        sfmEntityDetail.lastModifiedBy = processRecord.LastModifiedBy.Name;
        return sfmEntityDetail;
    }
}