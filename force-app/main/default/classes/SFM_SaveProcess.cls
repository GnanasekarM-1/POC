/* Security Scanned */
global with sharing class SFM_SaveProcess
{
    public SFM_WrapperDef.SFM_Response saveProcess(SFM_WrapperDef.SFM_Request_ProcessNodeInfo processNodeinfo)
    {
        system.debug('processNodeinfo'+processNodeinfo);
        Boolean response_success = true;
        String response_message;
        String response_tagId;
        SFM_Utils utils = new SFM_Utils();
        List<SFM_WrapperDef.SFM_StringMap> response_stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SVMX_Debug log = new SVMX_Debug();
        log.login('SFM_saveProcess', 'saveProcess');
        List<String> resultIds=new List<String>();
        Map<String, Id> objectRecType_Map = new Map<String, Id>();
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Target Manager');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Process Business Rule');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Process Node Objects');
        recTypeNames.add('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
        recTypeNames.add('SVMXC__ServiceMax_Processes__c~Linked Process');
        objectRecType_Map = utils.getRecordTypes(recTypeNames);
        SVMXC__ServiceMax_Processes__c processNode = new SVMXC__ServiceMax_Processes__c();
        List<SVMXC__ServiceMax_Processes__c> processNodeObj = new List<SVMXC__ServiceMax_Processes__c>();
        Map<String, List<SVMXC__ServiceMax_Config_Data__c>> processSourceUpdates_Map = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdatesexp = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Processes__c> processBizRules = new List<SVMXC__ServiceMax_Processes__c>();
        Map<String, List<SVMXC__ServiceMax_Processes__c>> Uniquekey_ProcessBizRulesMap = new Map<String, List<SVMXC__ServiceMax_Processes__c>>();
        map<String, List<SVMXC__ServiceMax_Processes__c>> mapTagetObjLableLinkdProcesses = new map<String, List<SVMXC__ServiceMax_Processes__c>>();
        list<SVMXC__ServiceMax_Processes__c> lstLinkedProcessesToBeInserted = new list<SVMXC__ServiceMax_Processes__c>();
        List<SFM_WrapperDef.SFM_SelectedChecklistProcess> savedProcessList;

        Savepoint sp;
        String PrcsId;
        String UniqueProcessId;
        Boolean isCloneCall = FALSE;
        List<SVMXC__ServiceMax_Processes__c> uniquecheck = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c processNodesLmd = new SVMXC__ServiceMax_Processes__c();
        //---Start----Added for the story BAC-3774 for checking designer type
        Boolean isChecklistDesigner = false;
        if(processNodeinfo != null && processNodeinfo.request != null && String.isNotBlank(processNodeinfo.request.clientType) && processNodeinfo.request.clientType.equalsIgnoreCase('Checklist_Designer')){
            isChecklistDesigner = true;
        }
        //----End----Added for the story BAC-3774 for checking designer type
        try
        {
            log.setlog('SAVEPOINT', 'Setting up savepoint before creating');
            sp = Database.setSavepoint();
            //Start-Inserting Main Header
            processNode = processNodeinfo.processNodes;
            log.setlog('UPSERT', 'upsert process node');
            processNode.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Target Manager');
            if(processNode.Id!=null)
            {
                isCloneCall = TRUE;
                PrcsId=processNode.Id;
                system.debug('isCloneCall'+PrcsId);
            }
            if(processNode != null)
            {
                UniqueProcessId=processNode.SVMXC__ProcessID__c;
            }
            
            //End-Inserting Main Header
            log.setlog('LOOPING', 'Update process target with process node id');
            
            if(isCloneCall == TRUE)
            {
                //Get Target Process Node Object Ids if available
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodeObj = [Select Id,SVMXC__Type__c  From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c = :PrcsId AND (SVMXC__Type__c = 'TARGET' OR SVMXC__Type__c = 'TARGETCHILD')];
                set<String> setProNodeObjId = new set<String>();
                if(processNodeObj.size() > 0){
                    for(SVMXC__ServiceMax_Processes__c pNode : processNodeObj){
                        if(pNode.SVMXC__Type__c.equals('TARGETCHILD'))
                            setProNodeObjId.add(pNode.id);
                    }
                }
                system.debug('setProNodeObjId'+setProNodeObjId);
                //Delete Linked processes 
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<SVMXC__ServiceMax_Processes__c> lstLinkedProToBeDeleted = new list<SVMXC__ServiceMax_Processes__c>();
                lstLinkedProToBeDeleted = [select id from SVMXC__ServiceMax_Processes__c where SVMXC__Process1__c =: PrcsId and SVMXC__Process2__c IN: setProNodeObjId and RecordType.Name = 'Linked Process'];
                system.debug('lstLinkedProToBeDeleted'+lstLinkedProToBeDeleted.size()+lstLinkedProToBeDeleted);
                if(!test.isRunningTest() && lstLinkedProToBeDeleted.size() > 0){
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete lstLinkedProToBeDeleted;
                }
                
                //Delete Process Business Rules (i.e Associated Business Rule) exclude checklist opdoc junction records of type Checklist Criteria in Output Doc
                List<SVMXC__ServiceMax_Processes__c> processBizRulesToBeDeleted = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Process1__c =: PrcsId AND SVMXC__Process1__c != NULL AND Recordtype.Name = \'Process Business Rule\' AND SVMXC__Rule_Type__c != \'Checklist Criteria in Output Doc\'');
                if(!test.isRunningTest() && processBizRulesToBeDeleted != NULL && processBizRulesToBeDeleted.size() > 0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete processBizRulesToBeDeleted;
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processSourceUpdatesexp = [Select Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c = :PrcsId and Recordtype.Name = 'Field Mapping'];
                if(!test.isRunningTest() && processSourceUpdatesexp.size()>0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete processSourceUpdatesexp;
                
                //Delete Target Process Node Object.
                if(!test.isRunningTest() && processNodeObj.size()>0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    delete processNodeObj;
                    
                //Commented by: Bala(March 1 2011) - We are locking the process node object records, so donot delete the source object records as well as dont create them too.
                //processNodeObj = [Select Id  From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c = :PrcsId];
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodeObj = [Select Id,SVMXC__Type__c  From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c = :PrcsId AND (SVMXC__Type__c = 'SOURCE' OR SVMXC__Type__c = 'SOURCECHILD')];
                system.debug('SourceProcessNodeObj size is :'+ processNodeObj.size());
                if(!test.isRunningTest() && processNodeObj.size()>0)
                   delete processNodeObj;
                    
                //if(processNodeinfo.processNodeSourceObject != NULL)
                //    processNodeinfo.processNodeSourceObject.clear();
            }
            
            List<SVMXC__ServiceMax_Processes__c> sourceNodeObjects = new List<SVMXC__ServiceMax_Processes__c>();
            Map<String, Id> source_Id_Map = new Map<String, Id>();
            Map<String, Id> sourcechild_Id_Map = new Map<String, Id>();
            Map<String, Id> target_Id_Map = new Map<String, Id>();
            Map<String, Id> Uniquekey_TargetChildObjIdMap = new Map<String, Id>();
            
            system.debug('processNode: ' + processNode);
            if(processNode!=null)
            {
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                uniquecheck = [Select Id, Name, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c,  SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Node_Source_Object_API__c, SVMXC__IsStandard__c,SVMXC__IsStandalone__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Target Manager' AND SVMXC__ProcessID__c=:UniqueProcessId];

                system.debug('uniquecheck: ' + uniquecheck + PrcsId);
                system.debug('processNodeinfo: ' + processNodeinfo);
                
                if(uniquecheck.size()>0)
                {
                    if(uniquecheck[0].Id!=PrcsId)
                    {
                        response_success = false;
                        //response_message = System.Label.SFM001_TAG186;//'Process cannot be saved as the it is not unique';
                        //---Start----Added for the story BAC-3774 for checking designer type
                        if(isChecklistDesigner){
                            response_message = System.Label.SFM001_TAG635;//The Checklist Transaction ID you have entered already exists. Please enter a unique ID
                        }
                        else{
                            response_message = System.Label.SFM001_TAG186;//The SFM Transaction ID you have entered already exists. Please enter a unique ID
                        }
                        //---End----Added for the story BAC-3774 for checking designer type
                    }
                    else
                    {
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert processNode;
                        response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('PROCESS',processNode.Id));
                         //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        processNodesLmd = [Select Id, Name, SVMXC__Purpose__c, SVMXC__Page_Layout__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Node_Source_Object_API__c, SVMXC__IsStandard__c,SVMXC__IsStandalone__c,CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, CreatedBy.Name From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Target Manager' And Id=:processNode.Id];
                    
                        response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('PROCESSLMD',String.valueOf(processNodesLmd.LastModifiedDate)));
                        response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('PROCESSLMBYID',processNodesLmd.LastModifiedBy.Name));
                        response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('CREATEDON',String.valueOf(processNodesLmd.CreatedDate)));
                        response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('CREATEDBY',processNodesLmd.CreatedBy.Name));
                        resultIds.add(processNode.Id);
                        //end first block
                        
                        
                        //Query Source/Soruce Child records as we are not deleting it..
                        /*list<SVMXC__ServiceMax_Processes__c> lstSourceNodeObject = new list<SVMXC__ServiceMax_Processes__c>();
                        lstSourceNodeObject = [Select Id,SVMXC__Type__c, SVMXC__Source_Key__c, SVMXC__Source_Object_Name__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Process Node Objects' and SVMXC__Process__c =:  processNode.Id and (SVMXC__Type__c = 'SOURCE' OR SVMXC__Type__c = 'SOURCECHILD') ];
                        map<String,Id> mapNameId = new map<String,Id>();
                        if(lstSourceNodeObject.size() > 0){
                            for(SVMXC__ServiceMax_Processes__c pro : lstSourceNodeObject){
                                if(pro.SVMXC__Type__c == 'SOURCE')
                                    source_Id_Map.put(pro.SVMXC__Source_Object_Name__c,pro.Id);
                                else if(pro.SVMXC__Type__c == 'SOURCECHILD')
                                    sourcechild_Id_Map.put(Integer.valueof(pro.SVMXC__Source_Key__c)+'~'+pro.SVMXC__Source_Object_Name__c,pro.Id);  
                            }
                        } */

                        //Start-If processNodeSourceObject is not null then insert the processNodeObejct i.e. SourceObject Details for the Source Parent
                        if(processNodeinfo.processNodeSourceObject != NULL && processNodeinfo.processNodeSourceObject.size()>0)
                        {
                            for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeSourceObject)
                            {
                                system.debug('Source-processNodeObejct:'+processObjectDetail.processNodeObejct);
                                SVMXC__ServiceMax_Processes__c pnt = processObjectDetail.processNodeObejct;
                                if(pnt.SVMXC__Type__c=='SOURCE')
                                {
                                    pnt.SVMXC__Process__c = processNode.Id;
                                    pnt.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                                    sourceNodeObjects.add(pnt);
                                }
                            }
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            upsert sourceNodeObjects;
                            for(SVMXC__ServiceMax_Processes__c sn: sourceNodeObjects)
                            {
                                if(sn.SVMXC__Source_Object_Name__c!=NULL)
                                    source_Id_Map.put(sn.SVMXC__Source_Object_Name__c, sn.Id);
                            }
                        }
                        system.debug('source_Id_Map'+source_Id_Map);
                        //end first block
                        //End-If processNodeSourceObject is not null then insert the processNodeObejct i.e. SourceObject Details for the Source Parent
                        //Start Second block
                        if(processNodeinfo.processNodeTargetObject != NULL && processNodeinfo.processNodeTargetObject.size()>0)
                        {
                            for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeTargetObject)
                            {
                                system.debug('Target-processNodeObejct:'+processObjectDetail.processNodeObejct);
                                system.debug('Target-processSourceUpdates:'+processObjectDetail.processSourceUpdates);
                            }
                        }
                        //end Second block
                        //start Third block
                        
                        List<SVMXC__ServiceMax_Processes__c> sourceDetailsNodeObjects = new List<SVMXC__ServiceMax_Processes__c>();
                        if(processNodeinfo.processNodeSourceObject != NULL && processNodeinfo.processNodeSourceObject.size()>0)
                        {
                            for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeSourceObject)
                            {
                                SVMXC__ServiceMax_Processes__c pnt = processObjectDetail.processNodeObejct;
                                if(pnt.SVMXC__Type__c=='SOURCECHILD')
                                {
                                    pnt.SVMXC__Process__c = processNode.Id;
                                    pnt.SVMXC__Node_Parent__c = source_Id_Map.get(pnt.SVMXC__Node_Parent_API__c);
                                    pnt.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                                    sourceDetailsNodeObjects.add(pnt);
                                }
                            }
                            if(sourceDetailsNodeObjects.size() > 0)
                            {
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                upsert sourceDetailsNodeObjects;
                                for(SVMXC__ServiceMax_Processes__c sn: sourceDetailsNodeObjects)
                                {
                                    if(sn.SVMXC__Source_Object_Name__c!=NULL)
                                        sourcechild_Id_Map.put(Integer.valueof(sn.SVMXC__Source_Key__c)+'~'+sn.SVMXC__Source_Object_Name__c, sn.Id);
                                }
                            }
                        }   
                    
                        system.debug('sourcechild_Id_Map'+sourcechild_Id_Map);
                        
                        //Start Third block
                        if(processNodeinfo.processNodeTargetObject != NULL && processNodeinfo.processNodeTargetObject.size()>0)
                        {
                            List<SVMXC__ServiceMax_Processes__c> targetNodeObjects = new List<SVMXC__ServiceMax_Processes__c>();
                            if(processNodeinfo.processNodeTargetObject != NULL && processNodeinfo.processNodeTargetObject.size()>0)
                            {
                                for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeTargetObject)
                                {
                                    SVMXC__ServiceMax_Processes__c pnt = processObjectDetail.processNodeObejct;
                                    if(pnt.SVMXC__Type__c=='TARGET')
                                    {
                                        pnt.SVMXC__Process__c = processNode.Id;
                                        pnt.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                                        pnt.SVMXC__Parent_Object__c=source_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                        targetNodeObjects.add(pnt);
                                    }
                                    List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates_T = processObjectDetail.processSourceUpdates;
                                    system.debug(LoggingLevel.Warn, 'Source Update Recs: ' + processSourceUpdates_T);
                                    
                                    if(processSourceUpdates_T!=NULL && pnt.SVMXC__Node_Source_Object_API__c!=NULL)
                                    {
                                        for(SVMXC__ServiceMax_Config_Data__c su: processSourceUpdates_T)
                                        {
                                            su.SVMXC__MapID__c = source_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                            su.SVMXC__Dispatch_Process__c=processNode.Id;
                                        }
                                        //007488 - Changed logic to save source update info. Now we are using alias name to save this instead of Object Name
                                        if(pnt.SVMXC__Target_Object_label__c != NULL)
                                            processSourceUpdates_Map.put(pnt.SVMXC__Target_Object_label__c, processSourceUpdates_T);
                                    }else if(processNode.SVMXC__Purpose__c == 'OUTPUT DOCUMENT'){
                                        
                                        if(pnt.SVMXC__Type__c == 'TARGET' && processSourceUpdates_T != NULL){
                                            for(SVMXC__ServiceMax_Config_Data__c TargetUpdate : processSourceUpdates_T)
                                                TargetUpdate.SVMXC__Dispatch_Process__c = processNode.Id;
                                                
                                            if(pnt.SVMXC__Target_Object_label__c != NULL)
                                                processSourceUpdates_Map.put(pnt.SVMXC__Target_Object_label__c, processSourceUpdates_T);
                                        }else if(pnt.SVMXC__Type__c.equalsIgnoreCase('TARGETCHILD') && pnt.SVMXC__Source_Object_Name__c.equalsIgnoreCase('SVMXC__Checklist__c')){
                                            savedProcessList = saveChecklistOpdocProcessInfo(processNodeinfo.lstSelectedChecklistProcess, processNode.Id);
                                        }
                                    }
                                    

                                    /*else if(pnt.SVMXC__Type__c == 'TARGET' && processNode.SVMXC__Purpose__c == 'OUTPUT DOCUMENT' && processSourceUpdates_T != NULL)
                                    {
                                        for(SVMXC__ServiceMax_Config_Data__c TargetUpdate : processSourceUpdates_T)
                                            TargetUpdate.SVMXC__Dispatch_Process__c = processNode.Id;
                                            if(pnt.SVMXC__Target_Object_label__c != NULL)
                                            processSourceUpdates_Map.put(pnt.SVMXC__Target_Object_label__c, processSourceUpdates_T);
                                    }else if(pnt.SVMXC__Type__c == 'TARGETCHILD' && pnt.SVMXC__Source_Object_Name__c == 'SVMXC__Checklist__c'){

                                    }*/


                                    system.debug(LoggingLevel.Warn, 'Source Update Map: ' + processSourceUpdates_Map);
                                    
                                    //Process Business Rules
                                    system.debug(LoggingLevel.Warn, 'Process biz rules: ' + processObjectDetail.processBizRules);
                                    if(processObjectDetail != NULL && processObjectDetail.processBizRules != NULL)
                                    {
                                        List<SVMXC__ServiceMax_Processes__c> lstProcessBizRule = new List<SVMXC__ServiceMax_Processes__c>();
                                        for(SVMXC__ServiceMax_Processes__c CurrProBizRule : processObjectDetail.processBizRules)
                                        {
                                            lstProcessBizRule.add(new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c = CurrProBizRule.SVMXC__Sequence__c, SVMXC__Parent_Error_Msg__c = CurrProBizRule.SVMXC__Parent_Error_Msg__c, SVMXC__Process1__c = processNode.Id, SVMXC__Process3__c = CurrProBizRule.Id));
                                        }
                                        if(pnt.SVMXC__Target_Object_label__c != NULL)
                                            Uniquekey_ProcessBizRulesMap.put(pnt.SVMXC__Target_Object_label__c, lstProcessBizRule);
                                    }
                                }
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                upsert targetNodeObjects;
                                for(SVMXC__ServiceMax_Processes__c sn : targetNodeObjects)
                                {
                                    if(sn.SVMXC__Source_Object_Name__c != NULL)
                                    {
                                        target_Id_Map.put(sn.SVMXC__Source_Object_Name__c, sn.Id);
                                    }
                                    
                                    if(sn.SVMXC__Target_Object_label__c != NULL)
                                        Uniquekey_TargetChildObjIdMap.put(sn.SVMXC__Target_Object_label__c, sn.Id); //for Process biz Rules and Source Update
                                    
                                    response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('PARENTNODE',sn.Id));
                                }
                            }
                            List<SVMXC__ServiceMax_Processes__c> targetDetailsNodeObjects = new List<SVMXC__ServiceMax_Processes__c>();
                            if(processNodeinfo.processNodeTargetObject != NULL && processNodeinfo.processNodeTargetObject.size()>0)
                            {
                                for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeTargetObject)
                                {
                                    SVMXC__ServiceMax_Processes__c pnt = processObjectDetail.processNodeObejct;
                                    if(pnt.SVMXC__Type__c=='TARGETCHILD')
                                    {
                                        pnt.SVMXC__Process__c = processNode.Id;
                                        pnt.SVMXC__Node_Parent__c = target_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                        pnt.SVMXC__Parent_Object__c=sourcechild_Id_Map.get(Integer.valueof(pnt.SVMXC__Source_Key__c)+'~'+pnt.SVMXC__Node_Source_Object_API__c);
                                        pnt.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                                        targetDetailsNodeObjects.add(pnt);
                                    }
                                    //Get the source updates and update the source id
                                    List<SVMXC__ServiceMax_Config_Data__c> sourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                                    List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates_T = processObjectDetail.processSourceUpdates;
                                    system.debug(LoggingLevel.Warn, 'Source Update Recs: ' + processSourceUpdates_T);
                                    
                                    if(processSourceUpdates_T!=NULL && pnt.SVMXC__Node_Source_Object_API__c!=NULL)
                                    {
                                        for(SVMXC__ServiceMax_Config_Data__c su: processSourceUpdates_T)
                                        {
                                            //Setting up source object reference
                                            su.SVMXC__MapID__c = source_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                            //Setting up target object reference if exist
                                            if(target_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c)!=NULL)
                                                su.SVMXC__Setting_ID__c = target_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                            //Setting up process id
                                            su.SVMXC__Dispatch_Process__c=processNode.Id;
                                        }
                                        if(pnt.SVMXC__Target_Object_label__c != NULL)
                                            processSourceUpdates_Map.put(pnt.SVMXC__Target_Object_label__c, processSourceUpdates_T);
                                    }
                                    system.debug(LoggingLevel.Warn, 'Source Update Recs Map: ' + processSourceUpdates_Map);
                                    
                                    //Process Business Rules
                                    system.debug(LoggingLevel.Warn, 'Process biz rules: ' + processObjectDetail.processBizRules);
                                    if(processObjectDetail != NULL && processObjectDetail.processBizRules != NULL)
                                    {
                                        List<SVMXC__ServiceMax_Processes__c> lstProcessBizRule = new List<SVMXC__ServiceMax_Processes__c>();
                                        for(SVMXC__ServiceMax_Processes__c CurrProBizRule : processObjectDetail.processBizRules)
                                        {
                                            lstProcessBizRule.add(new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c = CurrProBizRule.SVMXC__Sequence__c, SVMXC__Parent_Error_Msg__c = CurrProBizRule.SVMXC__Parent_Error_Msg__c, SVMXC__Process1__c = processNode.Id, SVMXC__Process3__c = CurrProBizRule.Id));
                                        }
                                        if(pnt.SVMXC__Target_Object_label__c != NULL)
                                            Uniquekey_ProcessBizRulesMap.put(pnt.SVMXC__Target_Object_label__c, lstProcessBizRule);
                                    }
                                    // Linked Processes
                                    if(processObjectDetail != NULL && processObjectDetail.linkedProcesses != NULL){
                                        mapTagetObjLableLinkdProcesses.put(pnt.SVMXC__Target_Object_label__c,processObjectDetail.linkedProcesses);
                                    }
                                }
                                if(targetDetailsNodeObjects.size() > 0){
                                    system.debug('targetDetailsNodeObjects'+targetDetailsNodeObjects);
                                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                    upsert targetDetailsNodeObjects;
                                }
                                    
                                    
                                for(SVMXC__ServiceMax_Processes__c sn : targetDetailsNodeObjects)
                                {
                                    if(mapTagetObjLableLinkdProcesses.containskey(sn.SVMXC__Target_Object_label__c)){
                                        for(SVMXC__ServiceMax_Processes__c linkPro : mapTagetObjLableLinkdProcesses.get(sn.SVMXC__Target_Object_label__c)){
                                            linkPro.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Linked Process');
                                            linkPro.SVMXC__Process1__c = processNode.Id;
                                            linkPro.SVMXC__Process2__c = sn.id;
                                            lstLinkedProcessesToBeInserted.add(linkPro);        
                                        }
                                    }
                                    
                                    if(sn.SVMXC__Source_Object_Name__c!=NULL)
                                    {
                                        target_Id_Map.put(sn.SVMXC__Source_Object_Name__c, sn.Id);
                                    }
                                    response_stringMap.add(new SFM_WrapperDef.SFM_StringMap(sn.SVMXC__Target_Object_label__c,sn.Id));
                                    
                                    //for Process biz Rules and Source Update
                                    if(sn.SVMXC__Target_Object_label__c != NULL)
                                        Uniquekey_TargetChildObjIdMap.put(sn.SVMXC__Target_Object_label__c, sn.Id); 
                                }
                            }
                            if(lstLinkedProcessesToBeInserted.size() > 0){
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                upsert lstLinkedProcessesToBeInserted;
                            }
                            
                            system.debug(LoggingLevel.Warn, 'Source Update Recs Map: ' + processSourceUpdates_Map);
                            for(String tarObjAliasName : processSourceUpdates_Map.keySet())
                            {
                                List<SVMXC__ServiceMax_Config_Data__c> sourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
                                sourceUpdates = processSourceUpdates_Map.get(tarObjAliasName);
                                if(sourceUpdates != null && sourceUpdates.size() > 0)
                                {
                                    for(SVMXC__ServiceMax_Config_Data__c su: sourceUpdates)
                                    {
                                        if(Uniquekey_TargetChildObjIdMap.get(tarObjAliasName) != NULL)
                                            su.SVMXC__Setting_ID__c = Uniquekey_TargetChildObjIdMap.get(tarObjAliasName);
                                        su.SVMXC__Configuration_Type__c='Source Update';
                                        su.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
                                    }
                                    processSourceUpdates.addAll(sourceUpdates);
                                }
                            }
            
                            if(processSourceUpdates!=NULL && processSourceUpdates.size() > 0)
                            {
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                upsert processSourceUpdates;
                                response_success = true;
                            }
                            system.debug(LoggingLevel.Warn, 'Source Update : ' + processSourceUpdates);
                            system.debug(LoggingLevel.Warn, 'Process biz rules map: ' + Uniquekey_ProcessBizRulesMap);
                            system.debug(LoggingLevel.Warn, 'Unique map: ' + Uniquekey_TargetChildObjIdMap);
                            
                            //Insert Process Business Rules
                            if(Uniquekey_ProcessBizRulesMap != NULL && Uniquekey_ProcessBizRulesMap.size() > 0)
                            {
                                for(String key : Uniquekey_ProcessBizRulesMap.keySet())
                                {
                                    if(Uniquekey_ProcessBizRulesMap.get(key) != NULL && Uniquekey_ProcessBizRulesMap.get(key).size() > 0)
                                    {
                                        for(SVMXC__ServiceMax_Processes__c CurrProBizRule : Uniquekey_ProcessBizRulesMap.get(key))
                                        {
                                            if(Uniquekey_TargetChildObjIdMap.get(key) != NULL)
                                            {
                                                CurrProBizRule.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Business Rule');
                                                CurrProBizRule.SVMXC__Process2__c = Uniquekey_TargetChildObjIdMap.get(key);
                                                processBizRules.add(CurrProBizRule);
                                            }
                                        }
                                    }
                                }
                                system.debug(LoggingLevel.Warn, 'Process biz rules list: ' + processBizRules);
                                if(processBizRules != NULL && processBizRules.size() > 0)
                                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                    upsert processBizRules;
                            }
                        }
                        //end Third block
                        //end main block
                    }
                }
                else
                {
                    //main block
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    upsert processNode;
                    response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('PROCESS',processNode.Id));
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    processNodesLmd = [Select Id, Name, SVMXC__Purpose__c, SVMXC__Page_Layout__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Rule_Type__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Node_Parent__c,  SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,SVMXC__Node_Source_Object_API__c, SVMXC__IsStandard__c,SVMXC__IsStandalone__c,CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, CreatedBy.Name  From SVMXC__ServiceMax_Processes__c where Recordtype.Name='Target Manager' And Id=:processNode.Id];
                    
                    response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('PROCESSLMD',String.valueOf(processNodesLmd.LastModifiedDate)));
                    response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('PROCESSLMBYID',processNodesLmd.LastModifiedBy.Name));
                    response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('CREATEDON',String.valueOf(processNodesLmd.CreatedDate)));
                    response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('CREATEDBY',processNodesLmd.CreatedBy.Name));
                    resultIds.add(processNode.Id);
                    
                    //start first block
                    //Start-If processNodeSourceObject is not null then insert the processNodeObejct i.e. SourceObject Details for the Source Parent
                    if(processNodeinfo.processNodeSourceObject != NULL && processNodeinfo.processNodeSourceObject.size()>0)
                    {
                        for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeSourceObject)
                        {
                            system.debug('Source-processNodeObejct:'+processObjectDetail.processNodeObejct);
                            SVMXC__ServiceMax_Processes__c pnt = processObjectDetail.processNodeObejct;
                            if(pnt.SVMXC__Type__c=='SOURCE')
                            {
                                pnt.SVMXC__Process__c = processNode.Id;
                                pnt.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                                sourceNodeObjects.add(pnt);
                            }
                        }
                        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        upsert sourceNodeObjects;
                        for(SVMXC__ServiceMax_Processes__c sn: sourceNodeObjects)
                        {
                            if(sn.SVMXC__Source_Object_Name__c!=NULL)
                                source_Id_Map.put(sn.SVMXC__Source_Object_Name__c, sn.Id);
                        }
                    }
                    system.debug('source_Id_Map'+source_Id_Map);
                    //end first block
                    //End-If processNodeSourceObject is not null then insert the processNodeObejct i.e. SourceObject Details for the Source Parent
                    //Start Second block
                    if(processNodeinfo.processNodeTargetObject != NULL && processNodeinfo.processNodeTargetObject.size()>0)
                    {
                        for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeTargetObject)
                        {
                            system.debug('Target-processNodeObejct:'+processObjectDetail.processNodeObejct);
                            system.debug('Target-processSourceUpdates:'+processObjectDetail.processSourceUpdates);
                        }
                    }
                    //end Second block
                    //start Third block
                    if(processNodeinfo.processNodeTargetObject != NULL && processNodeinfo.processNodeTargetObject.size()>0)
                    {
                        List<SVMXC__ServiceMax_Processes__c> sourceDetailsNodeObjects = new List<SVMXC__ServiceMax_Processes__c>();
                        if(processNodeinfo.processNodeSourceObject != NULL && processNodeinfo.processNodeSourceObject.size()>0)
                        {
                            for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeSourceObject)
                            {
                                SVMXC__ServiceMax_Processes__c pnt = processObjectDetail.processNodeObejct;
                                if(pnt.SVMXC__Type__c=='SOURCECHILD')
                                {
                                    pnt.SVMXC__Process__c = processNode.Id;
                                    pnt.SVMXC__Node_Parent__c = source_Id_Map.get(pnt.SVMXC__Node_Parent_API__c);
                                    pnt.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                                    sourceDetailsNodeObjects.add(pnt);
                                }
                            }
                            if(sourceDetailsNodeObjects.size() > 0)
                            {
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                upsert sourceDetailsNodeObjects;
                                for(SVMXC__ServiceMax_Processes__c sn: sourceDetailsNodeObjects)
                                {
                                    if(sn.SVMXC__Source_Object_Name__c!=NULL)
                                        sourcechild_Id_Map.put(Integer.valueof(sn.SVMXC__Source_Key__c)+'~'+sn.SVMXC__Source_Object_Name__c, sn.Id);
                                }
                            }
                        }
    
                        List<SVMXC__ServiceMax_Processes__c> targetNodeObjects = new List<SVMXC__ServiceMax_Processes__c>();
                        if(processNodeinfo.processNodeTargetObject != NULL && processNodeinfo.processNodeTargetObject.size()>0)
                        {
                            for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeTargetObject)
                            {
                                SVMXC__ServiceMax_Processes__c pnt = processObjectDetail.processNodeObejct;
                                if(pnt.SVMXC__Type__c=='TARGET')
                                {
                                    pnt.SVMXC__Process__c = processNode.Id;
                                    pnt.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                                    pnt.SVMXC__Parent_Object__c=source_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                    targetNodeObjects.add(pnt);
                                }
                                List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates_T = processObjectDetail.processSourceUpdates;
                                if(processSourceUpdates_T!=NULL && pnt.SVMXC__Node_Source_Object_API__c!=NULL)
                                {
                                    for(SVMXC__ServiceMax_Config_Data__c su: processSourceUpdates_T)
                                    {
                                        su.SVMXC__MapID__c = source_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                        su.SVMXC__Dispatch_Process__c=processNode.Id;
                                    }
                                    if(pnt.SVMXC__Target_Object_label__c != NULL)
                                        processSourceUpdates_Map.put(pnt.SVMXC__Target_Object_label__c, processSourceUpdates_T);
                                }else if(processNode.SVMXC__Purpose__c == 'OUTPUT DOCUMENT'){
                                        
                                        if(pnt.SVMXC__Type__c == 'TARGET' && processSourceUpdates_T != NULL){
                                            for(SVMXC__ServiceMax_Config_Data__c TargetUpdate : processSourceUpdates_T)
                                                TargetUpdate.SVMXC__Dispatch_Process__c = processNode.Id;
                                                
                                            if(pnt.SVMXC__Target_Object_label__c != NULL)
                                                processSourceUpdates_Map.put(pnt.SVMXC__Target_Object_label__c, processSourceUpdates_T);
                                        }else if(pnt.SVMXC__Type__c.equalsIgnoreCase('TARGETCHILD') && pnt.SVMXC__Source_Object_Name__c.equalsIgnoreCase('SVMXC__Checklist__c')){
                                            savedProcessList = saveChecklistOpdocProcessInfo(processNodeinfo.lstSelectedChecklistProcess, processNode.Id);
                                        }
                                    }
                                

                                /*else if(pnt.SVMXC__Type__c == 'TARGET' && processNode.SVMXC__Purpose__c == 'OUTPUT DOCUMENT' && processSourceUpdates_T != NULL)
                                {
                                       TargetUpdate.SVMXC__Dispatch_Process__c = processNode.Id;
                                        
                                    if(pnt.SVMXC__Target_Object_label__c != NULL)
                                        processSourceUpdates_Map.put(pnt.SVMXC__Target_Object_label__c, processSourceUpdates_T);
                                }*/
                                
                                //Process Business Rules
                                system.debug(LoggingLevel.Warn, 'Process biz rules: ' + processObjectDetail.processBizRules);
                                if(processObjectDetail != NULL && processObjectDetail.processBizRules != NULL)
                                {
                                    List<SVMXC__ServiceMax_Processes__c> lstProcessBizRule = new List<SVMXC__ServiceMax_Processes__c>();
                                    for(SVMXC__ServiceMax_Processes__c CurrProBizRule : processObjectDetail.processBizRules)
                                    {
                                        lstProcessBizRule.add(new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c = CurrProBizRule.SVMXC__Sequence__c, SVMXC__Parent_Error_Msg__c = CurrProBizRule.SVMXC__Parent_Error_Msg__c, SVMXC__Process1__c = processNode.Id, SVMXC__Process3__c = CurrProBizRule.Id));
                                    }
                                    if(pnt.SVMXC__Target_Object_label__c != NULL)
                                        Uniquekey_ProcessBizRulesMap.put(pnt.SVMXC__Target_Object_label__c, lstProcessBizRule);
                                }
                            }
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            upsert targetNodeObjects;
                            for(SVMXC__ServiceMax_Processes__c sn : targetNodeObjects)
                            {
                                if(sn.SVMXC__Source_Object_Name__c!=NULL)
                                {
                                    target_Id_Map.put(sn.SVMXC__Source_Object_Name__c, sn.Id);
                                }
                                
                                if(sn.SVMXC__Target_Object_label__c != NULL)
                                    Uniquekey_TargetChildObjIdMap.put(sn.SVMXC__Target_Object_label__c, sn.Id); //for Process biz Rules
                                
                                response_stringMap.add(new SFM_WrapperDef.SFM_StringMap('PARENTNODE',sn.Id));
                            }
                        }
                        
                        List<SVMXC__ServiceMax_Processes__c> targetDetailsNodeObjects = new List<SVMXC__ServiceMax_Processes__c>();
                        if(processNodeinfo.processNodeTargetObject != NULL && processNodeinfo.processNodeTargetObject.size()>0)
                        {
                            for(SFM_WrapperDef.SFM_ProcessNodeDetail processObjectDetail: processNodeinfo.processNodeTargetObject)
                            {
                                SVMXC__ServiceMax_Processes__c pnt = processObjectDetail.processNodeObejct;
                                if(pnt.SVMXC__Type__c=='TARGETCHILD')
                                {
                                    pnt.SVMXC__Process__c = processNode.Id;
                                    pnt.SVMXC__Node_Parent__c = target_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                    pnt.SVMXC__Parent_Object__c=sourcechild_Id_Map.get(Integer.valueof(pnt.SVMXC__Source_Key__c)+'~'+pnt.SVMXC__Node_Source_Object_API__c);
                                    pnt.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Node Objects');
                                    targetDetailsNodeObjects.add(pnt);
                                }
                                
                                //Get the source updates and update the source id
                                List<SVMXC__ServiceMax_Config_Data__c> sourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                                List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates_T = processObjectDetail.processSourceUpdates;
                                if(processSourceUpdates_T!=NULL && pnt.SVMXC__Node_Source_Object_API__c!=NULL)
                                {
                                    for(SVMXC__ServiceMax_Config_Data__c su: processSourceUpdates_T)
                                    {
                                        //Setting up source object reference
                                        su.SVMXC__MapID__c = source_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                        //Setting up target object reference if exist
                                        if(target_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c)!=NULL)
                                            su.SVMXC__Setting_ID__c = target_Id_Map.get(pnt.SVMXC__Node_Source_Object_API__c);
                                        //Setting up process id
                                        su.SVMXC__Dispatch_Process__c=processNode.Id;
                                    }
                                    if(pnt.SVMXC__Target_Object_label__c != NULL)
                                        processSourceUpdates_Map.put(pnt.SVMXC__Target_Object_label__c, processSourceUpdates_T);
                                }
                                
                                // Linked Processes
                                if(processObjectDetail != NULL && processObjectDetail.linkedProcesses != NULL){
                                    mapTagetObjLableLinkdProcesses.put(pnt.SVMXC__Target_Object_label__c,processObjectDetail.linkedProcesses);
                                }
                                
                                //Process Business Rules
                                system.debug(LoggingLevel.Warn, 'Process biz rules: ' + processObjectDetail.processBizRules);
                                if(processObjectDetail != NULL && processObjectDetail.processBizRules != NULL)
                                {
                                    List<SVMXC__ServiceMax_Processes__c> lstProcessBizRule = new List<SVMXC__ServiceMax_Processes__c>();
                                    for(SVMXC__ServiceMax_Processes__c CurrProBizRule : processObjectDetail.processBizRules)
                                    {
                                        lstProcessBizRule.add(new SVMXC__ServiceMax_Processes__c(SVMXC__Sequence__c = CurrProBizRule.SVMXC__Sequence__c, SVMXC__Parent_Error_Msg__c = CurrProBizRule.SVMXC__Parent_Error_Msg__c, SVMXC__Process1__c = processNode.Id, SVMXC__Process3__c = CurrProBizRule.Id));
                                    }
                                    if(pnt.SVMXC__Target_Object_label__c != NULL)
                                        Uniquekey_ProcessBizRulesMap.put(pnt.SVMXC__Target_Object_label__c, lstProcessBizRule);
                                }
                            }
                            system.debug('targetDetailsNodeObjects'+targetDetailsNodeObjects);
                            if(targetDetailsNodeObjects.size() > 0)
                                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                upsert targetDetailsNodeObjects;
                            
                            for(SVMXC__ServiceMax_Processes__c sn: targetDetailsNodeObjects)
                            {
                                if(mapTagetObjLableLinkdProcesses.containskey(sn.SVMXC__Target_Object_label__c)){
                                    for(SVMXC__ServiceMax_Processes__c linkPro : mapTagetObjLableLinkdProcesses.get(sn.SVMXC__Target_Object_label__c)){
                                        linkPro.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Linked Process');
                                        linkPro.SVMXC__Process1__c = processNode.Id;
                                        linkPro.SVMXC__Process2__c = sn.id;
                                        lstLinkedProcessesToBeInserted.add(linkPro);        
                                    }
                                }
                                if(sn.SVMXC__Source_Object_Name__c!=NULL)
                                {
                                    target_Id_Map.put(sn.SVMXC__Source_Object_Name__c, sn.Id);
                                }
                                response_stringMap.add(new SFM_WrapperDef.SFM_StringMap(sn.SVMXC__Target_Object_label__c,sn.Id));
                                
                                if(sn.SVMXC__Target_Object_label__c != NULL)
                                    Uniquekey_TargetChildObjIdMap.put(sn.SVMXC__Target_Object_label__c, sn.Id);
                            }
                        }
                        if(lstLinkedProcessesToBeInserted.size() > 0){
                            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                            upsert lstLinkedProcessesToBeInserted;
                        }
                        
                        for(String tarObjAliasName : processSourceUpdates_Map.keySet())
                        {
                            List<SVMXC__ServiceMax_Config_Data__c> sourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
                            sourceUpdates = processSourceUpdates_Map.get(tarObjAliasName);
                            if(sourceUpdates !=null && sourceUpdates.size() > 0)
                            {
                                for(SVMXC__ServiceMax_Config_Data__c su: sourceUpdates)
                                {
                                    if(Uniquekey_TargetChildObjIdMap.get(tarObjAliasName) != NULL)
                                        su.SVMXC__Setting_ID__c = Uniquekey_TargetChildObjIdMap.get(tarObjAliasName);
                                    su.SVMXC__Configuration_Type__c = 'Source Update';
                                    su.RecordTypeId=objectRecType_Map.get('SVMXC__ServiceMax_Config_Data__c~Field Mapping');
                                }
                                processSourceUpdates.addAll(sourceUpdates);
                            }
                        }

                        if(processSourceUpdates!=NULL && processSourceUpdates.size() > 0)
                        {
                            upsert processSourceUpdates;
                            response_success = true;
                        }
                        
                        //Insert Process Business Rules
                        if(Uniquekey_ProcessBizRulesMap != NULL && Uniquekey_ProcessBizRulesMap.size() > 0)
                        {
                            for(String key : Uniquekey_ProcessBizRulesMap.keySet())
                            {
                                if(Uniquekey_ProcessBizRulesMap.get(key) != NULL && Uniquekey_ProcessBizRulesMap.get(key).size() > 0)
                                {
                                    for(SVMXC__ServiceMax_Processes__c CurrProBizRule : Uniquekey_ProcessBizRulesMap.get(key))
                                    {
                                        if(Uniquekey_TargetChildObjIdMap.get(key) != NULL)
                                        {
                                            CurrProBizRule.RecordTypeId = objectRecType_Map.get('SVMXC__ServiceMax_Processes__c~Process Business Rule');
                                            CurrProBizRule.SVMXC__Process2__c = Uniquekey_TargetChildObjIdMap.get(key);
                                            processBizRules.add(CurrProBizRule);
                                        }
                                    }
                                }
                            }
                            if(processBizRules != NULL && processBizRules.size() > 0)
                                upsert processBizRules;
                        }
                    }
                    //end Third block
                    //end main block
                }
            }
            //Always delete & create SFM Events 
            if(processNode.Id != null){
                 if( !COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SFM_Event__c' ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                //SDL-SVMX-DELETE-FLS-ENFORCED
                delete [Select Id from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c =: processNode.Id];
                list<SVMXC__SFM_Event__c> lstSFMEvent = new list<SVMXC__SFM_Event__c>();
                if(processNodeinfo.getSFMEvents() != null && !processNodeinfo.getSFMEvents().isEmpty()){
                    for(SVMXC__SFM_Event__c objSFMEvent : processNodeinfo.getSFMEvents()){
                        objSFMEvent.SVMXC__ServiceMax_Process__c = processNode.Id;
                        if(objSFMEvent.SVMXC__Event_Call_Type__c.equals('SFM TRIGGER') && objSFMEvent.SVMXC__Event_Type__c.equals('Inventory Updates') && (objSFMEvent.SVMXC__Class__c == null || objSFMEvent.SVMXC__Class__c == '')){
                            objSFMEvent.SVMXC__Class__c = 'SFM_InvtUpdOnWorkOrderClosure';
                            lstSFMEvent.add(objSFMEvent);
                        }
                    }
                }   
                if(!lstSFMEvent.isEmpty()){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSFMEvent, COMM_SecurityUtils.Access.Upsertable)){
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstSFMEvent;
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                }
                    
            } 
        }
        catch (DmlException ex)
        {
            log.setlog('ERROR', ex.getDmlMessage(0));
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getDmlMessage(0);
        }
        catch(exception ex)
        {
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);
            response_success = false;
            response_message = ex.getmessage();
        }

        //Setting up resultset
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        log.logout();
        log.print();
        response.logMsg = log.getlog();
        response.success = response_success;
        response.message = response_message;
        response.stringMap = response_stringMap;
        response.resultIds = resultIds;   
        if(savedProcessList != null) { 
            response.lstChecklistBusinessProcessInfo = savedProcessList; 
        }
        //BAC-4012 : To support translation for for SFM and checklist
        if(response_success)
        {   
            CONF_ManageTranslations conf_manageTranslations = new CONF_ManageTranslations();
            conf_manageTranslations.generateMasterTag(processNode.id);
        }
        return response;
    }

    /* 
        Steps for Output Document Checklist process configuration Save
        1. Two junction records to be created 
           a. For opdoc and Checklist process
           b. For opdoc, checklist and business rule
        2. business rule and its related configuration to be saved before creating junction records
        3. Deleting all Orphan junction records and the business rule records  
        
    */
    List<SFM_WrapperDef.SFM_SelectedChecklistProcess> saveChecklistOpdocProcessInfo(List<SFM_WrapperDef.SFM_SelectedChecklistProcess> checklistProcessList, Id opdocProcessId){
        
        
        Map<String,Id> recordTypeIdMap = getRecordTypes(new Set<String>{'SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c'});
        Map<Id,SVMXC__ServiceMax_Processes__c> opdocCklBizRuleJunctionRecordMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        Map<Id,SVMXC__ServiceMax_Processes__c> businessRuleChecklistProcessIdMap = new  Map<Id,SVMXC__ServiceMax_Processes__c>();
        Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> configRecordsChecklistProcessIdMap = new Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();

        
        Set<Id> selectedChecklistProcessIdSet = new Set<Id>();
        Set<Id> selectedChecklistProcessIdWithoutCriteria =  new Set<Id>();
        Set<String> expressionRecordIdsToDelete = new Set<String>();
        List<SVMXC__ServiceMax_Processes__c> opdocCklJunctionRecordList = new List<SVMXC__ServiceMax_Processes__c>();
       
       
        
        if(checklistProcessList != null && !checklistProcessList.isEmpty()){
            for(SFM_WrapperDef.SFM_SelectedChecklistProcess checklistProcessWrapRec : checklistProcessList){
                
                selectedChecklistProcessIdSet.add(checklistProcessWrapRec.selectedChecklistId);

                if(checklistProcessWrapRec.checklistCriteriaProcess != null && checklistProcessWrapRec.lstExpressionRecord != null){
                    
                    //Criteria record creation
                    SVMXC__ServiceMax_Processes__c criteriaRecord = checklistProcessWrapRec.checklistCriteriaProcess;
                    criteriaRecord.RecordTypeId = recordTypeIdMap.get('Business Rule'); //Replace with record id
                    criteriaRecord.SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc';
                    businessRuleChecklistProcessIdMap.put(checklistProcessWrapRec.selectedChecklistId, criteriaRecord);

                    if(!checklistProcessWrapRec.lstExpressionRecord.isEmpty()){
                        
                        configRecordsChecklistProcessIdMap.put(checklistProcessWrapRec.selectedChecklistId, checklistProcessWrapRec.lstExpressionRecord);
                    }

                    //Criteria junction record creation
                    SVMXC__ServiceMax_Processes__c bizJunctionRecordInstance = new SVMXC__ServiceMax_Processes__c();
                    //bizJunctionRecordInstance.Id = checklistProcessWrapRec.selectedChecklistId;
                    bizJunctionRecordInstance.SVMXC__Process1__c = opdocProcessId;
                    bizJunctionRecordInstance.SVMXC__Process2__c = checklistProcessWrapRec.selectedChecklistId;  
                    //bizJunctionRecordInstance.SVMXC__Question_Bank__c = checklistProcessWrapRec.selectedQuestionId;

                    bizJunctionRecordInstance.recordTypeId = recordTypeIdMap.get('Process Business Rule'); //To Do: Checklist Smart Doc Record TypeId;
                    bizJunctionRecordInstance.SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc';
                    opdocCklBizRuleJunctionRecordMap.put(checklistProcessWrapRec.selectedChecklistId, bizJunctionRecordInstance);


                    if(checklistProcessWrapRec.expressionsToDelete != null && !checklistProcessWrapRec.expressionsToDelete.isEmpty()){
                        expressionRecordIdsToDelete.addAll(checklistProcessWrapRec.expressionsToDelete);
                    }

                }else{
                    selectedChecklistProcessIdWithoutCriteria.add(checklistProcessWrapRec.selectedChecklistId);
                }


                SVMXC__ServiceMax_Processes__c ckJunctionRecordInstance = new SVMXC__ServiceMax_Processes__c();
                //ckJunctionRecordInstance.Id = checklistProcessWrapRec.selectedChecklistId;
                ckJunctionRecordInstance.SVMXC__Process1__c = opdocProcessId;
                ckJunctionRecordInstance.SVMXC__Process2__c = checklistProcessWrapRec.selectedChecklistId;
                ckJunctionRecordInstance.SVMXC__SM_Checklist_Version__c = checklistProcessWrapRec.selectedChecklistVersion;

                ckJunctionRecordInstance.RecordTypeId =  recordTypeIdMap.get('Checklist Smart Doc'); //To Do: Checklist Smart Doc Record TypeId;

                opdocCklJunctionRecordList.add(ckJunctionRecordInstance);

                /*Added this condition for fixing defect BAC-2841
                if(checklistProcessWrapRec.lstExpressionRecord != null){
                    SVMXC__ServiceMax_Processes__c bizJunctionRecordInstance = new SVMXC__ServiceMax_Processes__c();
                    //bizJunctionRecordInstance.Id = checklistProcessWrapRec.selectedChecklistId;
                    bizJunctionRecordInstance.SVMXC__Process1__c = opdocProcessId;
                    bizJunctionRecordInstance.SVMXC__Process2__c = checklistProcessWrapRec.selectedChecklistId;  
                    //bizJunctionRecordInstance.SVMXC__Question_Bank__c = checklistProcessWrapRec.selectedQuestionId;

                    bizJunctionRecordInstance.recordTypeId = recordTypeIdMap.get('Process Business Rule'); //To Do: Checklist Smart Doc Record TypeId;
                    bizJunctionRecordInstance.SVMXC__Rule_Type__c = 'Checklist Criteria in Output Doc';
                    opdocCklBizRuleJunctionRecordMap.put(checklistProcessWrapRec.selectedChecklistId, bizJunctionRecordInstance);
                }*/
            } 
        }   

        deleteOrphanRecords(selectedChecklistProcessIdSet,opdocProcessId,selectedChecklistProcessIdWithoutCriteria, expressionRecordIdsToDelete);

        if(!opdocCklJunctionRecordList.isEmpty()){
            
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(opdocCklJunctionRecordList, COMM_SecurityUtils.Access.Createable)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); 
            }
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            insert opdocCklJunctionRecordList;
            opdocCklJunctionRecordList.clear();
        }

        if(!businessRuleChecklistProcessIdMap.values().isEmpty()){
            
            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(businessRuleChecklistProcessIdMap.values(), COMM_SecurityUtils.Access.Upsertable)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); 
            }
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            upsert businessRuleChecklistProcessIdMap.values();

            List<SVMXC__ServiceMax_Config_Data__c> configDataList = new List<SVMXC__ServiceMax_Config_Data__c>();
            
            for(Id checklistProcessID : businessRuleChecklistProcessIdMap.keySet()){
                
                SVMXC__ServiceMax_Processes__c businessRuleRec = businessRuleChecklistProcessIdMap.get(checklistProcessID);

                

                if(configRecordsChecklistProcessIdMap.containsKey(checklistProcessID) && !configRecordsChecklistProcessIdMap.get(checklistProcessID).isEmpty()){

                    for(SVMXC__ServiceMax_Config_Data__c configRecord : configRecordsChecklistProcessIdMap.get(checklistProcessID)){
                        
                        configRecord.SVMXC__Expression_Rule__c = businessRuleRec.Id;
                        configRecord.RecordTypeId = recordTypeIdMap.get('Expressions');
                        configRecord.SVMXC__Expression_Type__c = 'Business_Rule';
                        configDataList.add(configRecord);
                    
                    }

                   
                }


                if(opdocCklBizRuleJunctionRecordMap.containsKey(checklistProcessID)){
                    SVMXC__ServiceMax_Processes__c bizJunctionRecordInstance = opdocCklBizRuleJunctionRecordMap.get(checklistProcessID);
                    bizJunctionRecordInstance.SVMXC__Process3__c = businessRuleRec.Id;
                }

            }

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(configDataList, COMM_SecurityUtils.Access.Upsertable)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); 
            }
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            upsert configDataList;

            if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(opdocCklBizRuleJunctionRecordMap.values(), COMM_SecurityUtils.Access.Createable)){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 ); 
            }
            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
            insert opdocCklBizRuleJunctionRecordMap.values();

        } 

        return checklistProcessList;
    }

    static void deleteOrphanRecords(Set<Id> selectedChecklistProcessIdSet, Id opdocProcessId, Set<Id> selectedChecklistProcessIdWithoutCriteria,Set<String> expressionRecordIdsToDelete){


        Set<Id> businessRuleIds = new Set<Id>(); //Orphan business rule Ids 
        //Set<Id> selectedBusinessRuleIds = new Set<Id>();
        List<String> queryFields = new List<String> {'SVMXC__Process2__c', 'SVMXC__Process3__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        //SDL-SVMX-READ-FLS-ENFORCED
        List<SVMXC__ServiceMax_Processes__c> orphanJunctionRecordsList = [SELECT Id,SVMXC__Process2__c, SVMXC__Process3__c,RecordType.Name FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process1__c =: opdocProcessId 
                                                                            AND SVMXC__Record_Type_Name__c IN ('Checklist Smart Doc','Process Business Rule')]; // AND  SVMXC__Process2__c NOT IN : selectedChecklistProcessIdSet 
        
        for(SVMXC__ServiceMax_Processes__c junctionRecord : orphanJunctionRecordsList){
            
            if(junctionRecord.RecordType.Name == 'Process Business Rule' && junctionRecord.SVMXC__Process3__c != null){
                businessRuleIds.add(junctionRecord.SVMXC__Process3__c);
                
                if(selectedChecklistProcessIdSet.contains(junctionRecord.SVMXC__Process2__c) && !selectedChecklistProcessIdWithoutCriteria.contains(junctionRecord.SVMXC__Process2__c)){
                    businessRuleIds.remove(junctionRecord.SVMXC__Process3__c);
                }
            }
        }

        if(!orphanJunctionRecordsList.isEmpty()){
            
            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                delete orphanJunctionRecordsList;
       
            }else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }    
        }

        if(!expressionRecordIdsToDelete.isEmpty() || !businessRuleIds.isEmpty()){

            if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c') || !COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            //SDL-SVMX-DELETE-FLS-ENFORCED
            delete [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE Id IN : expressionRecordIdsToDelete OR SVMXC__Expression_Rule__c IN : businessRuleIds ];
            //SDL-SVMX-DELETE-FLS-ENFORCED
            delete [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE Id IN : businessRuleIds OR (SVMXC__Process3__c IN : businessRuleIds AND SVMXC__Process1__c  =: opdocProcessId)];
           // delete [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE Id IN : businessRuleIds];
        }           
    }

    Map<String, Id> getRecordTypes(Set<String> objectAPINameSet){

       Map<String, Id> recordTypeIdMap = new Map<String, Id>();
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA      
       for(RecordType recordTypeRec : [SELECT Id,Name FROM RecordType WHERE sObjectType IN : objectAPINameSet AND isActive = true]){
            recordTypeIdMap.put(recordTypeRec.Name, recordTypeRec.Id);
       }

       return recordTypeIdMap;
    }


    public SFM_WrapperDef2.SFM2_ProcessInfo saveProcess_V2(String entityType, SFM_WrapperDef2.SFM2_ProcessInfo processInfo, String tabInfo, Boolean isChildCardAddedDeleted, COMM_AuditTrail.AuditData auditData) {

        System.debug(LoggingLevel.INFO, 'saveProcess_V2 - Entry , Parameters : processInfo ' + processInfo + ' tabInfo ' + tabInfo + 'auditData '+auditData);
        SFM_ProcessUtils processUtilsInstance = new SFM_ProcessUtils();
        SFM_ProcessUtils.tabInfo = tabInfo;
        entityType = entityType != null ? entityType : SFM_DesignerUtils.entity_sfm;
        SFM_ProcessUtils.entityType = entityType;
        Savepoint sp = Database.setSavepoint();

        try{
            Boolean isNewProcess = processInfo.targetManager.entityId == null ? true : false;
            if(tabInfo.equalsIgnoreCase('ALL')){
                processInfo.tagKeys = null;
                processUtilsInstance.savePropertiesTab(processInfo, entityType);
                processUtilsInstance.saveObjectMappingTab(processInfo);
                if(entityType == SFM_DesignerUtils.entity_checklist){
                    if( processInfo.isClone != null && processInfo.isClone && processInfo.pageLayoutId != null){
                        SFM_WrapperDef2.SFM2_Layout pageLayoutInfo = new SFM_GetPageLayout().clonePageLayout(new List<String>{processInfo.pageLayoutId}, true); 
                        pageLayoutInfo.layoutDetail.entityName = processInfo.targetManager.entityName;
                        new SFM_SavePageLayout().savePageLayout_v2(pageLayoutInfo, auditData);
                        processInfo.pageLayoutId = pageLayoutInfo.layoutDetail.entityId;
                    }
                }
                processUtilsInstance.savePageLayoutTab(processInfo, entityType);
                processUtilsInstance.saveSourceObjectUpdateTab(processInfo);
                if(entityType == SFM_DesignerUtils.entity_sfm){
                    processUtilsInstance.saveDvrTab(processInfo);
                    processUtilsInstance.saveFormulaTab(processInfo);
                }else if(entityType == SFM_DesignerUtils.entity_opdoc){
                    processUtilsInstance.saveChecklistTab(processInfo);
            }

            } else if( tabInfo.equalsIgnoreCase('PROPERTIES') ) {
                processUtilsInstance.savePropertiesTab(processInfo, entityType);

            } else if( tabInfo.equalsIgnoreCase('OBJECTMAPPING') ) {
                processUtilsInstance.saveObjectMappingTab(processInfo);

            } else if( tabInfo.equalsIgnoreCase('PAGELAYOUT') ) {
                processUtilsInstance.savePageLayoutTab(processInfo, entityType);

            } else if( tabInfo.equalsIgnoreCase('SOURCEOBJECTUPDATE') ){
                processUtilsInstance.saveSourceObjectUpdateTab(processInfo);

            } else if( entityType == SFM_DesignerUtils.entity_sfm && (tabInfo.equalsIgnoreCase('DataValidationRules') ) ) {
                processUtilsInstance.saveDvrTab(processInfo);

            } else if(entityType == SFM_DesignerUtils.entity_sfm && (tabInfo.equalsIgnoreCase('FORMULAS') ) ) {
                processUtilsInstance.saveFormulaTab(processInfo);
            } else if(entityType != SFM_DesignerUtils.entity_sfm && tabInfo.equalsIgnoreCase('OPDOCCHECKLIST') ) {
                processUtilsInstance.saveChecklistTab(processInfo);
            } else if(entityType != SFM_DesignerUtils.entity_sfm && tabInfo.equalsIgnoreCase('SORTING')){
                processUtilsInstance.saveSortingTab(processInfo);
            }

            processAuditTrailInfo(entityType, processInfo, tabInfo, isNewProcess, isChildCardAddedDeleted, auditData);

            if(processInfo.targetManager != null && processInfo.targetManager.entityId != null){
                processUtilsInstance.deleteRecords(processInfo.targetManager.entityId);
                
                // Log the entries into the servicemax tags object for translations
                SFM_ProcessUtils.getManageTranslationInstance().updateServiceMaxTagKeys();
            }
        }catch(Exception ex){
            Database.rollback(sp);
            throw ex;
        }
        
        System.debug(LoggingLevel.INFO, 'saveProcess_V2 - Exit , Response : processInfo ' + processInfo);
        return processInfo;
    }
    /**
     * Private method to log audit trail informations.
     *
     * @param entityType Entity type for which audit trail details to be created.
     * @param processInfo Process information on which action performed.
     * @param tabInfo tab for which save/update action has been performed.
     * @param isNewProcess Boolean instance variable represents whether the transaction is new.
     */
    private void processAuditTrailInfo( String entityType, SFM_WrapperDef2.SFM2_ProcessInfo processInfo, String tabInfo, Boolean isNewProcess, Boolean isChildCardAddedDeleted, COMM_AuditTrail.AuditData auditData) {
        COMM_AuditTrail.AuditTrailInfo auditTrailInfo = new COMM_AuditTrail.AuditTrailInfo();
        auditTrailInfo.actionType = isNewProcess ? System.Label.AUDIT001_TAG009 : System.Label.AUDIT001_TAG010;
            if (processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.OUTPUT_DOCUMENT)) {
                auditTrailInfo.entityName = System.Label.AUDIT001_TAG013;
                auditTrailInfo.application = System.Label.AUDIT001_TAG002;
            } else if (processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.CHECKLIST)) {
                auditTrailInfo.entityName = System.Label.AUDIT001_TAG055;
                auditTrailInfo.application = System.Label.AUDIT001_TAG056;
            } else {
                 auditTrailInfo.entityName = System.Label.AUDIT001_TAG012;
                 auditTrailInfo.application = System.Label.AUDIT001_TAG001;
            }

        auditTrailInfo.internalId = processInfo.targetManager.entityId;
        // Populating audit trail details for save button action.
        if( tabInfo.equalsIgnoreCase('ALL') || processInfo.targetManager.entityId == null ) {
            if(isChildCardAddedDeleted == null || !isChildCardAddedDeleted ) {
                auditTrailInfo.action = isNewProcess ? System.Label.AUDIT001_TAG016 + ' ' + processInfo.targetManager.entityName : System.Label.AUDIT001_TAG017 + ' ' + processInfo.targetManager.entityName;
                    if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.OUTPUT_DOCUMENT) ) {
                    auditTrailInfo.action = isNewProcess ? System.Label.AUDIT001_TAG025 + ' ' + processInfo.targetManager.entityName : System.Label.AUDIT001_TAG026 + ' ' + processInfo.targetManager.entityName;
                    } else if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.CHECKLIST) ) {
                        auditTrailInfo.action = isNewProcess ? System.Label.AUDIT001_TAG057 + ' ' + processInfo.targetManager.entityName : System.Label.AUDIT001_TAG058 + ' ' + processInfo.targetManager.entityName;
                }
            } else {
                auditTrailInfo.action = System.Label.AUDIT001_TAG019 + ' ' + processInfo.targetManager.entityName;
                    if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.OUTPUT_DOCUMENT) ) {
                    auditTrailInfo.action = System.Label.AUDIT001_TAG028 + ' ' + processInfo.targetManager.entityName;
                }
            }
        } else if( tabInfo.equalsIgnoreCase('PROPERTIES') ) {
            // Populating audit trial details for properties tab save.
            if( isNewProcess ) {
                auditTrailInfo.action = System.Label.AUDIT001_TAG016 + ' ' + processInfo.targetManager.entityName;
                    if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.OUTPUT_DOCUMENT) ) {
                    auditTrailInfo.action = System.Label.AUDIT001_TAG025 + ' ' + processInfo.targetManager.entityName;
                    } else if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.CHECKLIST) ) {
                        auditTrailInfo.action = System.Label.AUDIT001_TAG057 + ' ' + processInfo.targetManager.entityName;
                }
            } else {
                auditTrailInfo.action = System.Label.AUDIT001_TAG018 + ' ' + processInfo.targetManager.entityName;
                    if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.OUTPUT_DOCUMENT) ) {
                    auditTrailInfo.action = System.Label.AUDIT001_TAG027 + ' ' + processInfo.targetManager.entityName;
                    } else if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.CHECKLIST) ) {
                        auditTrailInfo.action = System.Label.AUDIT001_TAG059 + ' ' + processInfo.targetManager.entityName;
                }
            }
        } else if( tabInfo.equalsIgnoreCase('OBJECTMAPPING') ) {
            // Populating audit trail details for object & mapping tab.
            auditTrailInfo.action = System.Label.AUDIT001_TAG019 + ' ' + processInfo.targetManager.entityName;
                if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.OUTPUT_DOCUMENT) ) {
                auditTrailInfo.action = System.Label.AUDIT001_TAG028 + ' ' + processInfo.targetManager.entityName;
            }
        } else if( tabInfo.equalsIgnoreCase('PAGELAYOUT') ) {
            // Populating audit trail details for page layout.
            auditTrailInfo.action = System.Label.AUDIT001_TAG020 + ' ' + processInfo.targetManager.entityName;
                if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.OUTPUT_DOCUMENT) ) {
                auditTrailInfo.action = System.Label.AUDIT001_TAG029 + ' ' + processInfo.targetManager.entityName;
            }
        } else if( tabInfo.equalsIgnoreCase('SOURCEOBJECTUPDATE') ){
            // Populating audit trail details for source object update.
            auditTrailInfo.action = System.Label.AUDIT001_TAG023 + ' ' + processInfo.targetManager.entityName;
                if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.OUTPUT_DOCUMENT) ) {
                auditTrailInfo.action = System.Label.AUDIT001_TAG031 + ' ' + processInfo.targetManager.entityName;
                // Populating audit trail details for checklist source object update
                } else if( processInfo.targetManager.entitySubType.equalsIgnoreCase(SFM_Consts.CHECKLIST) ) {
                    auditTrailInfo.action = System.Label.AUDIT001_TAG060 + ' ' + processInfo.targetManager.entityName;
            }
        } else if( entityType == SFM_DesignerUtils.entity_sfm && (tabInfo.equalsIgnoreCase('DataValidationRules') ) ) {
            // Populating audit trail details for data validation rule.
            auditTrailInfo.action = System.Label.AUDIT001_TAG022 + ' ' + processInfo.targetManager.entityName;
        } else if(entityType == SFM_DesignerUtils.entity_sfm && (tabInfo.equalsIgnoreCase('FORMULAS') ) ) {
            // Populating audit trail details for formula editor.
            auditTrailInfo.action = System.Label.AUDIT001_TAG021 + ' ' + processInfo.targetManager.entityName;
        } else if( entityType != SFM_DesignerUtils.entity_sfm && tabInfo.equalsIgnoreCase('OPDOCCHECKLIST') ) {
            // Populating audit trail details for OP Doc checklist
            auditTrailInfo.action = System.Label.AUDIT001_TAG030 + ' ' + processInfo.targetManager.entityName;
        } if( entityType != SFM_DesignerUtils.entity_sfm && (tabInfo.equalsIgnoreCase('SORTING') ) ) {
            // Populating audit trail details for sorting
            auditTrailInfo.action = System.Label.AUDIT001_TAG032 + ' ' + processInfo.targetManager.entityName;
        }
        // Log audit trail information
        COMM_AuditTrail.getInstance().logAudit(auditTrailInfo, auditData);
    }
}