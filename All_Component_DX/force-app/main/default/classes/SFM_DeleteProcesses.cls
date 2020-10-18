/* Security Scanned */
public with sharing class SFM_DeleteProcesses {
    
    public SFM_deleteProcesses()
    {
        
    }
    public SFM_WrapperDef.SFM_Response DeleteProcesses(SFM_WrapperDef.SFM_Request request)
    {
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        SVMX_Debug  log = new SVMX_Debug();
        Boolean response_success;
        String response_message;
        String response_tagId;
        list<SFM_WrapperDef.SFM_StringMap> response_stringMap = new list<SFM_WrapperDef.SFM_StringMap>();
        Set<string> ProcessNodeId = new Set<string>();
        list<SVMXC__ServiceMax_Processes__c> processNodes=new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> processNodeTargets = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new list<SVMXC__ServiceMax_Config_Data__c>();
        list<SVMXC__ServiceMax_Processes__c> processBizRules = new list<SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Config_Data__c >  lstConfigProfiles = new list<SVMXC__ServiceMax_Config_Data__c > ();
        list<SFM_WrapperDef.SFM_StringMap> lstStringMap =  new list<SFM_WrapperDef.SFM_StringMap>();
        list<string> ProcessId = new list<string>();
        list<string> ProcessId1 = new list<string>();
        String strRecordId;
      String strProcessType;
        Boolean isForceDelete = false;
        
        lstStringMap = request.stringMap;
        system.debug('lstStringMap'+lstStringMap);
        log.login('SFM_deleteProcesses', 'DeleteProcesses');
        Savepoint sp;
        
        try{
            
            log.setlog('SAVEPOINT', 'Setting up savepoint before cloning');
            sp = Database.setSavepoint();//Setting up save point
            for(Integer i = 0;i<lstStringMap.size();i++){
                
                if(lstStringMap[i].key.equals('RECORDID'))
                    strRecordId = lstStringMap[i].value;
                else if(lstStringMap[i].key.equals('FORCEDELETE') && lstStringMap[i].value.equals('TRUE'))
                    isForceDelete = true;
            }
            system.debug('isForceDelete'+isForceDelete);
            if(strRecordId != null){
            
            //Query SFM Process Record 
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            strProcessType = [select Id,SVMXC__Purpose__c from SVMXC__ServiceMax_Processes__c where Id =: strRecordId].SVMXC__Purpose__c;
            system.debug('strProcessType'+strProcessType);
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                processNodes=[Select Id,SVMXC__Purpose__c, SVMXC__Rule_Type__c, SVMXC__ProcessID__c, SVMXC__Page_Layout__c, SVMXC__Node_Parent__c, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__IsStandalone__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Description__c, SVMXC__Dispatch_Process_Status__c, SVMXC__Active__c  From SVMXC__ServiceMax_Processes__c where Id =: strRecordId];
                
                //Making a list of Linked process, MultiSource process and Wizard
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<SVMXC__ServiceMax_Processes__c> lstProcess= [SELECT Id, SVMXC__ProcessID__c, SVMXC__Module__c, SVMXC__Name__c, SVMXC__Module__r.SVMXC__Name__c, SVMXC__Process1__r.SVMXC__Name__c, SVMXC__Process1__r.SVMXC__ProcessID__c, SVMXC__Record_Type_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE (SVMXC__Record_Type_Name__c = 'Wizard Step' AND SVMXC__Module__c != null AND SVMXC__Process__c =: strRecordId) OR (SVMXC__Record_Type_Name__c = 'Target Manager' AND SVMXC__Process2__c =: strRecordId) OR (SVMXC__Record_Type_Name__c = 'Linked Process' AND SVMXC__Process1__c != null AND SVMXC__Process3__c =: strRecordId)];
                
                String strMsg1= System.Label.SFM001_TAG382;//This SFM transaction cannot be deleted because it is used in the following processes:
                String strMsg2= System.Label.SFM001_TAG423;//Remove the above dependencies and then delete the SFM transaction.
                list<String> lstSFW = new list<String>();
                list<String> lstMultisourceProcess = new list<String>();
                list<String> lstLinkedProcess = new list<String>();
                list<String> lstScheduledSFM = new list<String>();
                list<String> lstConfigurationProfile = new list<String>();
                
                //Extracting process name into different list
                Set<ID> setWizardID = new Set<ID>();
                for(SVMXC__ServiceMax_Processes__c obj: lstProcess){
                    if(obj.SVMXC__Record_Type_Name__c.equals('Wizard Step'))
                        setWizardID.add(obj.SVMXC__Module__c);
                    else if(obj.SVMXC__Record_Type_Name__c.equals('Target Manager'))
                        lstMultisourceProcess.add(obj.SVMXC__Name__c + ' ('+ obj.SVMXC__ProcessID__c + ')');
                    else if(obj.SVMXC__Record_Type_Name__c.equals('Linked Process'))
                        lstLinkedProcess.add(obj.SVMXC__Process1__r.SVMXC__Name__c + ' ('+ obj.SVMXC__Process1__r.SVMXC__ProcessID__c + ')');
                }
                
                //Since a SFW can have multiple wizard steps with same process, its iterated from Set(uniqueness)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<SVMXC__ServiceMax_Processes__c> lstWizard = [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE Id IN: setWizardID];
                if(lstWizard.size()>0){
                    for(SVMXC__ServiceMax_Processes__c pro : lstWizard)
                        lstSFW.add(pro.SVMXC__Name__c + ' ('+ pro.SVMXC__ProcessID__c + ')');
                }
                
                //Checking for SFM Schedule
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<SVMXC__ServiceMax_Config_Data__c> lstConfigdataScheduleDetail = [Select Id, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__RecordType_Name__c = 'Schedule Detail' AND SVMXC__Expression_Rule__c =: strRecordId];
                Set<ID> setSFMScheduleID = new Set<ID>();
                if(lstConfigdataScheduleDetail.size()>0){
                    for(SVMXC__ServiceMax_Config_Data__c obj : lstConfigdataScheduleDetail){
                        if(obj.SVMXC__Dispatch_Process__c != null)
                            setSFMScheduleID.add(obj.SVMXC__Dispatch_Process__c);
                    }
                }
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                list<SVMXC__ServiceMax_Processes__c> lstSFMSchedule = [SELECT Id, SVMXC__ProcessID__c, SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE Id IN: setSFMScheduleID];                
                if(lstSFMSchedule.size()>0){
                    for(SVMXC__ServiceMax_Processes__c pro : lstSFMSchedule)
                        lstScheduledSFM.add(pro.SVMXC__Name__c + ' ('+ pro.SVMXC__ProcessID__c + ')');
                }
                // Check If SFMs is associated to Config Profile for iPad.
                if(!isForceDelete){
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstConfigProfiles = [select Id, SVMXC__Dispatch_Process__c, SVMXC__Access_Configuration_Profile__c,SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c  from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: strRecordId and SVMXC__Access_Configuration_Profile__c != null and SVMXC__RecordType_Name__c = 'Service Flow Access'];
                }
                
                if(lstConfigProfiles.size() > 0){
                    for(SVMXC__ServiceMax_Config_Data__c configData : lstConfigProfiles)
                        lstConfigurationProfile.add(configData.SVMXC__Access_Configuration_Profile__r.SVMXC__Profile_Name__c);
                }
                //Forming the error messages in list form for flex client with list of processes.
                response.StringLstMap = new list<SFM_WrapperDef.SFM_StringListMap>();
                if(lstConfigurationProfile.size() > 0){
                    lstConfigurationProfile.sort();
                    response.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap(System.Label.SFM001_TAG449 ,lstConfigurationProfile));//Configuration Profile
                }
                if(lstLinkedProcess.size()>0){
                    lstLinkedProcess.sort();
                    response.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap(System.Label.SFM001_TAG447 ,lstLinkedProcess));//Linked Process
                }
                if(lstMultisourceProcess.size()>0){
                    lstMultisourceProcess.sort();
                    response.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap(System.Label.SFM001_TAG446 ,lstMultisourceProcess));//Multisource Process
                }
                if(lstScheduledSFM.size()>0){
                    lstScheduledSFM.sort();
                    response.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap(System.Label.SFM001_TAG448 ,lstScheduledSFM));//Scheduled SFM
                }
                if(lstSFW.size()>0){
                    lstSFW.sort();
                    response.StringLstMap.add(new SFM_WrapperDef.SFM_StringListMap(System.Label.SFM001_TAG445 ,lstSFW));//SFM Wizard
                }
                if(response.StringLstMap.size() > 0){
                    response.success = false;
                    String strJson = '{"message1": "'+strMsg1+'","message2": "'+strMsg2+'"}';
                    response.message = JSON.serialize(strJson);
                    return response;
                }   
                // Show warning message if SFM Process is not associated with Config Profile. 
                if(lstConfigProfiles.size() == 0 && !isForceDelete && (strProcessType == 'STANDALONE CREATE' || strProcessType == 'VIEW RECORD')){
                    response.success = false;
                    response.message = System.Label.SFM001_TAG450;
                    return response;
                }
                list<SVMXC__ServiceMax_Processes__c> lstLinkedProcesses = [Select id from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Linked Process' and SVMXC__Process1__c =: strRecordId];
                if(lstLinkedProcesses.size() > 0){
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {     //SDL-SVMX-DELETE-FLS-ENFORCED               
                        delete lstLinkedProcesses;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                //Delete Process Biz Rules
                processBizRules = Database.query('Select Id From SVMXC__ServiceMax_Processes__c Where SVMXC__Process1__c =: strRecordId AND SVMXC__Process1__c != NULL AND Recordtype.Name = \'Process Business Rule\'');
                System.debug(LoggingLevel.WARN, 'Process Biz Rule list: ' + processBizRules);
                if(processBizRules != NULL && processBizRules.size() > 0) {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {    //SDL-SVMX-DELETE-FLS-ENFORCED                
                        delete processBizRules;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                    
                if(processNodes.size() > 0){
                  for(SVMXC__ServiceMax_Processes__c p : processNodes){
                      ProcessId.add(p.Id);
                  }
                  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                  processNodeTargets=[Select Id,Name,SVMXC__ProcessID__c,SVMXC__Node_Parent__c,SVMXC__Source_Object_Name__c,SVMXC__Target_Object_Name__c,SVMXC__Submodule__c,SVMXC__Module__c,SVMXC__Sequence__c,SVMXC__Process__c,SVMXC__Target_Object_label__c From SVMXC__ServiceMax_Processes__c where SVMXC__Process__c IN:ProcessId  AND SVMXC__Record_Type_Name__c='Process Node Objects'];
              }
              if(processNodeTargets.size() > 0){
                  for(SVMXC__ServiceMax_Processes__c p : processNodeTargets)
                  {
                      ProcessId1.add(p.Id);
                  }
                  //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                  processSourceUpdates=[Select Id,Name,SVMXC__Dispatch_Process__c,SVMXC__Source_Field_Name__c,SVMXC__Target_Field_Name__c,SVMXC__Action__c,SVMXC__Display_Value__c,SVMXC__Configuration_Type__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN:ProcessId1 AND SVMXC__RecordType_Name__c='Field Mapping'];
              }
        
        //Deleting page layout record if the process type is CHECKLIST
        if(strProcessType.equals('CHECKLIST') && processNodes.size() > 0){
          String strPageLayoutID = processNodes[0].SVMXC__Page_Layout__c;
          //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          List<SVMXC__Page_Layout_Detail__c> lstPageLayoutDetail = [SELECT Id FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c =: strPageLayoutID];
          //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
          List<SVMXC__Page_Layout__c> lstPageLayout = [SELECT Id FROM SVMXC__Page_Layout__c WHERE Id =: strPageLayoutID];
                    if(lstPageLayoutDetail.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Page_Layout_Detail__c' ) ) {    //SDL-SVMX-DELETE-FLS-ENFORCED                        
                            delete lstPageLayoutDetail;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    }
            
                    if(lstPageLayout.size() > 0) {
                        if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__Page_Layout__c' ) ) {     //SDL-SVMX-DELETE-FLS-ENFORCED                       
                            delete lstPageLayout;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    }  
        }
        
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {     //SDL-SVMX-DELETE-FLS-ENFORCED               
                    delete processSourceUpdates;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
              
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Processes__c' ) ) {
                    //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete processNodeTargets;
                response = deleteSFMEvent(strRecordId);
                //SDL-SVMX-DELETE-FLS-ENFORCED
                    delete processNodes;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
              
              if(response.success){
               response_success = true;  
             }
             else{
               database.rollback(sp);
               response_success = false;
               response_message = response.message;
             }    
            }
        }
        catch (DmlException ex){
            log.setlog('ERROR', ex.getDmlMessage(0));
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getDmlMessage(0);
            
        }
        catch (Exception ex){
            log.setlog('ERROR', ex.getmessage());
            log.setlog('ROLLBACK', 'When fails rollback data donot commit');
            Database.rollback(sp);//When fails rollback data donot commit
            response_success = false;
            response_message = ex.getmessage();

        }
        log.logout();
        log.print();
        log.logout();
        log.print();
        response.logMsg = log.getlog();
        response.success = response_success;
        response.message = response_message;
        response.stringMap = response_stringMap;
        return response;
        
    }
     public SFM_WrapperDef.SFM_Response deleteSFMEvent(String strSFMProcessId)
    {
      SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
      response.success = true;
        if(strSFMProcessId != null && strSFMProcessId.length() > 0){
            try{
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__SFM_Event__c' ) ) {
                    
                    delete [select Id from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c =: strSFMProcessId];
                } else {
                    response.success = false;
                    response.message = System.Label.COMM001_TAG142;                    
                    return response;
                }
            }
            catch(Exception ex){
          response.success = false;
          response.message = ex.getMessage();
        }
      }
      else {
        response.success = false;
        response.message = 'Invalid Input Parameter';
      }  
      return response;
    }

    /*
        For SFM Designer 2.0
    */
    public Static void deleteEntities(List<String> entityIds, String entityType, COMM_AuditTrail.AuditData auditData){

        /*
            Security Check : To check if user has permission to delete
            Objects : SVMXC__ServiceMax_Processes__c, SVMXC__ServiceMax_Config_Data__c, SVMXC__SFM_Event__c
        */
        
        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SFM_Event__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Tag_Definition__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SM_Tag_Element__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Page_Layout__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(entityType == SFM_DesignerUtils.entity_template && !COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__Doc_Template__c')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(entityType == SFM_DesignerUtils.entity_template && !COMM_SecurityUtils.getInstance().isDeletableObject('Attachment')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(entityType == SFM_DesignerUtils.entity_template && !COMM_SecurityUtils.getInstance().isDeletableObject('ContentDocument')){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        Set<String> entityIdsSet = new Set<String>(entityIds); 
        List<SVMXC__SFM_Event__c> smaxEventsDeleteList;
        List<SVMXC__ServiceMax_Processes__c> sFMDeleteList;
        List<SVMXC__ServiceMax_Config_Data__c> configDeleteList;
        List<SVMXC__SM_Tag_Definition__c> tagDefList;
        List<SVMXC__SM_Tag_Element__c> tagElementList;
        List<SVMXC__Page_Layout__c> layoutDeleteList;
        List<SVMXC__Doc_Template__c> templateDeleteList;
        List<Attachment> attachmentDeleteList;
        List<ContentDocument> contentDocumentList;
        Set<String> tagDefs = new Set<String>();

        // Create audit trail information for delete.
        COMM_AuditTrail.AuditTrailInfo auditTrailInfo = new COMM_AuditTrail.AuditTrailInfo();
        auditTrailInfo.internalId = entityIds[0];
        auditTrailInfo.actionType = System.Label.AUDIT001_TAG011;

        if(entityType == SFM_DesignerUtils.entity_sfm || entityType == SFM_DesignerUtils.entity_opdoc || entityType == SFM_DesignerUtils.entity_checklist){
            /*
                To Delete 
                1. Wizard Step
                2. Linked Process 
                3. SFM Schedule
                4. Process Business Rule (Junction records for formulas & data validation rules)
                5. Process Node Object
                6. Target Manager
            */
            
            sFMDeleteList = [SELECT Id, SVMXC__Name__c, SVMXC__Page_Layout__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name IN ('Wizard Step', 'Process Node Objects') AND SVMXC__Process__c IN : entityIdsSet) OR (RecordType.Name = 'Linked Process' AND SVMXC__Process3__c IN : entityIdsSet)
                                                                        OR (RecordType.Name = 'Process Business Rule' AND SVMXC__Process1__c IN : entityIdsSet) OR Id IN: entityIdsSet];


            configDeleteList = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE (RecordType.Name = 'Schedule Detail' AND SVMXC__Expression_Rule__c IN : entityIdsSet) OR (SVMXC__Dispatch_Process__c IN: entityIdsSet AND RecordType.Name ='Field Mapping')];


            smaxEventsDeleteList = [SELECT Id FROM SVMXC__SFM_Event__c WHERE SVMXC__ServiceMax_Process__c IN : entityIdsSet];


            tagElementList = [SELECT Id, SVMXC__SM_Tag_Definition__r.Name FROM SVMXC__SM_Tag_Element__c WHERE SVMXC__SM_Target_Object__c IN:  entityIdsSet];
            for(SVMXC__SM_Tag_Element__c tagElement : tagElementList){
                tagDefs.add(tagElement.SVMXC__SM_Tag_Definition__r.Name);
            }
            
            String processName;
            Set<Id> pageLayoutIds = new Set<Id>();
            for( SVMXC__ServiceMax_Processes__c processRecord : sFMDeleteList ) {
                if( processRecord.id == entityIds[0] ) {
                    processName = processRecord.SVMXC__Name__c;
            }
                if(processRecord.SVMXC__Page_Layout__c != null){
                    pageLayoutIds.add(processRecord.SVMXC__Page_Layout__c);
                }
            }

            if(entityType == SFM_DesignerUtils.entity_checklist && !pageLayoutIds.isEmpty()){
                layoutDeleteList = new List<SVMXC__Page_Layout__c>();
                for(SVMXC__Page_Layout__c pageLayoutRec : [SELECT Id, SVMXC__Name__c FROM SVMXC__Page_Layout__c WHERE Id IN: pageLayoutIds]){
                    layoutDeleteList.add(pageLayoutRec);
                }
                for(SVMXC__Page_Layout__c pageLayoutRec : [SELECT Id, (SELECT Id FROM SVMXC__Page_Layout_Details__r) FROM SVMXC__Page_Layout__c WHERE SVMXC__Header_Page_Layout__c IN: pageLayoutIds]){
                    layoutDeleteList.add(pageLayoutRec);
                }
            }
            auditTrailInfo.entityName = entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_sfm) ? System.Label.AUDIT001_TAG012 : System.Label.AUDIT001_TAG013;
            auditTrailInfo.application = entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_sfm) ? System.Label.AUDIT001_TAG001 : System.Label.AUDIT001_TAG002;
            auditTrailInfo.action = ( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_sfm) && !sFMDeleteList.isEmpty() ) ? System.Label.AUDIT001_TAG024 + processName : System.Label.AUDIT001_TAG033 + processName;
        }else if(entityType == SFM_DesignerUtils.entity_expression || entityType == SFM_DesignerUtils.entity_checklistCriteria || entityType == SFM_DesignerUtils.entity_formula){
             
            configDeleteList = new List<SVMXC__ServiceMax_Config_Data__c>();
            sFMDeleteList = [SELECT Id, SVMXC__Name__c, (SELECT Id FROM SVMXC__ServiceMax_Config_Data2__r) FROM SVMXC__ServiceMax_Processes__c WHERE Id IN : entityIdsSet];
             
            for(SVMXC__ServiceMax_Processes__c expressionRecord : sFMDeleteList){
                configDeleteList.addAll(expressionRecord.SVMXC__ServiceMax_Config_Data2__r);
            }
            // Populate delete expression/formula audit trail information.
            if( entityType == SFM_DesignerUtils.entity_expression || entityType == SFM_DesignerUtils.entity_formula ) {
                
                auditTrailInfo.entityName = entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression) ? System.Label.AUDIT001_TAG003 : System.Label.AUDIT001_TAG006;
                auditTrailInfo.application = entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression) ? System.Label.AUDIT001_TAG003 : System.Label.AUDIT001_TAG006;
                auditTrailInfo.action = ( entityType.equalsIgnoreCase(SFM_DesignerUtils.entity_expression) && !sFMDeleteList.isEmpty() ) ? System.Label.AUDIT001_TAG039 + sFMDeleteList[0].SVMXC__Name__c : System.Label.AUDIT001_TAG048 + ' ' + sFMDeleteList[0].SVMXC__Name__c;
            }
        }else if(entityType == SFM_DesignerUtils.entity_businessrule){
            
            sFMDeleteList = [SELECT Id, SVMXC__Name__c, (SELECT Id FROM SVMXC__ServiceMax_Processes6__r), (SELECT Id FROM SVMXC__ServiceMax_Config_Data2__r) FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Business Rule' AND Id IN: entityIdsSet];
            List<SVMXC__ServiceMax_Processes__c> junctionRecordsList = new List<SVMXC__ServiceMax_Processes__c>();
            configDeleteList = new List<SVMXC__ServiceMax_Config_Data__c>();

            for(SVMXC__ServiceMax_Processes__c processRecord : sFMDeleteList){
                junctionRecordsList.addAll(processRecord.SVMXC__ServiceMax_Processes6__r);
                configDeleteList.addAll(processRecord.SVMXC__ServiceMax_Config_Data2__r);
            }   

            if(junctionRecordsList != null && !junctionRecordsList.isEmpty()){
                sFMDeleteList.addAll(junctionRecordsList);        
            }
            // Populate DVR delete audit trail information.
            auditTrailInfo.entityName = System.Label.AUDIT001_TAG005;
            auditTrailInfo.application = System.Label.AUDIT001_TAG005;
            auditTrailInfo.action = ( !sFMDeleteList.isEmpty() ) ? System.Label.AUDIT001_TAG045 + sFMDeleteList[0].SVMXC__Name__c : '';
        }else if(entityType == SFM_DesignerUtils.entity_mapping){
            
            configDeleteList = new List<SVMXC__ServiceMax_Config_Data__c>();
            sFMDeleteList = [SELECT Id, SVMXC__Name__c, (SELECT Id FROM SVMXC__SVMX_Config_Data2__r) FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Object Mapping' AND Id IN : entityIdsSet];
            
            for(SVMXC__ServiceMax_Processes__c processRecord : sFMDeleteList){
                configDeleteList.addAll(processRecord.SVMXC__SVMX_Config_Data2__r);
            }        
            // Populate Mapping delete audit trail information.
            auditTrailInfo.entityName = System.Label.AUDIT001_TAG004;
            auditTrailInfo.application = System.Label.AUDIT001_TAG004;
            auditTrailInfo.action = ( !sFMDeleteList.isEmpty() ) ? System.Label.AUDIT001_TAG042 + sFMDeleteList[0].SVMXC__Name__c : '';
        }else if(entityType == SFM_DesignerUtils.entity_layout){
            
            layoutDeleteList = new List<SVMXC__Page_Layout__c>();
            smaxEventsDeleteList = new List<SVMXC__SFM_Event__c>();
            Set<String> detailLayoutIds = new Set<String>();
            String pageLayoutName;
            for(SVMXC__Page_Layout__c pageLayoutRec : [SELECT Id, SVMXC__Name__c, (SELECT Id FROM SVMXC__SFM_Event__r) FROM SVMXC__Page_Layout__c WHERE Id IN: entityIdsSet]){
                layoutDeleteList.add(pageLayoutRec);
                smaxEventsDeleteList.addAll(pageLayoutRec.SVMXC__SFM_Event__r);
                pageLayoutName = pageLayoutRec.SVMXC__Name__c;
            }
            
            for(SVMXC__Page_Layout__c pageLayoutRec : [SELECT Id, (SELECT Id FROM SVMXC__SFM_Event__r), (SELECT Id FROM SVMXC__Page_Layout_Details__r) FROM SVMXC__Page_Layout__c WHERE SVMXC__Header_Page_Layout__c IN: entityIdsSet]){
                layoutDeleteList.add(pageLayoutRec);
                detailLayoutIds.add(pageLayoutRec.Id);
                smaxEventsDeleteList.addAll(pageLayoutRec.SVMXC__SFM_Event__r);
            }

            if(!detailLayoutIds.isEmpty()){
                entityIdsSet.addAll(detailLayoutIds);
            }

            for(SVMXC__Page_Layout_Detail__c detailRec : [SELECT Id, (SELECT Id FROM SVMXC__SFM_Event__r) FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Page_Layout__c IN: entityIdsSet]){
                smaxEventsDeleteList.addAll(detailRec.SVMXC__SFM_Event__r);
            }
            // Populate SFM Page layout delete audit trail information.
            auditTrailInfo.entityName = System.Label.AUDIT001_TAG015;
            auditTrailInfo.application = System.Label.AUDIT001_TAG008;
            auditTrailInfo.action = System.Label.AUDIT001_TAG054 + pageLayoutName;

        }else if(entityType == SFM_DesignerUtils.entity_lkpConfig){
            Set<Id> filterIds = new Set<Id>();
            sFMDeleteList = new List<SVMXC__ServiceMax_Processes__c>();
            String processName;
            for(SVMXC__ServiceMax_Processes__c processRecord: [SELECT Id, SVMXC__Name__c, (SELECT Id FROM SVMXC__ServiceMax_Processes2__r WHERE SVMXC__Rule_Type__c IN ('SRCH_OBJECT', 'SRCH_CRITERIA')) FROM
                                                                 SVMXC__ServiceMax_Processes__c WHERE Id IN: entityIdsSet]){
                sFMDeleteList.add(processRecord);
                for(SVMXC__ServiceMax_Processes__c filterRecord : processRecord.SVMXC__ServiceMax_Processes2__r){
                    filterIds.add(filterRecord.Id);
                    sFMDeleteList.add(filterRecord);
                }
                processName = processRecord.SVMXC__Name__c;
            }

           configDeleteList = [SELECT Id FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Expression_Rule__c IN: filterIds];
            // Populate lookup delete audit trail information.
            auditTrailInfo.entityName = System.Label.AUDIT001_TAG007;
            auditTrailInfo.application = System.Label.AUDIT001_TAG007;
            auditTrailInfo.action = System.Label.AUDIT001_TAG051 + processName;
        }else if(entityType == SFM_DesignerUtils.entity_template){
            
            templateDeleteList = [SELECT Id, SVMXC__Name__c FROM SVMXC__Doc_Template__c WHERE Id IN: entityIdsSet];
            attachmentDeleteList = [SELECT Id FROM Attachment WHERE ParentId IN: entityIdsSet];
            for(ContentDocumentLink cdLink : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: entityIdsSet]){
                if(cdLink.ContentDocumentId != null){
                    if(contentDocumentList == null){
                        contentDocumentList = new List<ContentDocument>();
                    }
                    ContentDocument cdDoc = new ContentDocument(Id=cdLink.ContentDocumentId);
                    contentDocumentList.add(cdDoc);
                }
            }
            //Populate Document Template delete audit trail information.
            auditTrailInfo.entityName = System.Label.AUDIT001_TAG014;
            auditTrailInfo.application = System.Label.AUDIT001_TAG002;
            auditTrailInfo.action = ( !templateDeleteList.isEmpty() ) ? System.Label.AUDIT001_TAG036 + templateDeleteList[0].SVMXC__Name__c : '';
        }

        Savepoint sp = Database.setSavepoint();     
        try{
            if(smaxEventsDeleteList != null && !smaxEventsDeleteList.isEmpty()){
                Database.delete(smaxEventsDeleteList, true);
            }

            if(configDeleteList != null && !configDeleteList.isEmpty()){
                Database.delete(configDeleteList, true);
            }

            if(sFMDeleteList != null && !sFMDeleteList.isEmpty()){
                Database.delete(sFMDeleteList, true);
                COMM_AuditTrail.getInstance().logAudit(auditTrailInfo, auditData);
            }

            if(tagElementList != null && !tagElementList.isEmpty()){
                Database.delete(tagElementList, true);
                tagDefList = new List<SVMXC__SM_Tag_Definition__c>();

                for(SVMXC__SM_Tag_Definition__c tagDefnRec : [SELECT Id, (SELECT Id from SVMXC__SM_Tag_Elements__r) from SVMXC__SM_Tag_Definition__c WHERE Name IN : tagDefs]){
                    Integer count = 0;
                    for (SVMXC__SM_Tag_Element__c obj : tagDefnRec.SVMXC__SM_Tag_Elements__r) {
                        count++;
                    }
                    
                    if(count == 0){
                        tagDefList.add(tagDefnRec);
                    }
                }

                if(!tagDefList.isEmpty()){
                    Database.delete(tagDefList, true);
                }
            }

            if(layoutDeleteList != null && !layoutDeleteList.isEmpty()){

                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id','SVMXC__Dispatch_Process_Status__c', 'SVMXC__Page_Layout__c'}, COMM_SecurityUtils.Access.Accessible)){
                
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                List<SVMXC__ServiceMax_Processes__c> processList = [SELECT Id, SVMXC__Dispatch_Process_Status__c FROM SVMXC__ServiceMax_Processes__c 
                                                                      WHERE RecordType.Name = 'Target Manager' AND SVMXC__Page_Layout__c IN : entityIdsSet];                
                for(SVMXC__ServiceMax_Processes__c processRecord : processList){
                    processRecord.SVMXC__Dispatch_Process_Status__c = 'Incomplete';
                }

                if(!processList.isEmpty()){

                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(processList, COMM_SecurityUtils.Access.Updateable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                    } 

                    update processList;
                }

                Database.delete(layoutDeleteList, true);
				COMM_AuditTrail.getInstance().logAudit(auditTrailInfo, auditData);
            }

            if(attachmentDeleteList != null && !attachmentDeleteList.isEmpty()){
                Database.delete(attachmentDeleteList, true);
            }

            if(contentDocumentList != null && !contentDocumentList.isEmpty()){
                Database.delete(contentDocumentList, true);
            }
            if(templateDeleteList != null && !templateDeleteList.isEmpty()){
                if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id','SVMXC__Dispatch_Process_Status__c', 'SVMXC__Doc_Template__c'}, COMM_SecurityUtils.Access.Accessible)){
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                List<SVMXC__ServiceMax_Processes__c> processList = [SELECT Id, SVMXC__Dispatch_Process_Status__c FROM SVMXC__ServiceMax_Processes__c
                                                                      WHERE RecordType.Name = 'Target Manager' AND SVMXC__Doc_Template__c IN : entityIdsSet];
                for(SVMXC__ServiceMax_Processes__c processRecord : processList){
                    processRecord.SVMXC__Dispatch_Process_Status__c = 'Incomplete';
                }
                if(!processList.isEmpty()){
                    if(!COMM_SecurityUtils.getInstance().verifyFieldAccess(processList, COMM_SecurityUtils.Access.Updateable)){
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142);
                    }
                    update processList;
                }
                Database.delete(templateDeleteList, true);
                COMM_AuditTrail.getInstance().logAudit(auditTrailInfo, auditData);
            }
        }catch(DmlException ex){
            Database.rollback(sp);
            throw ex;   
        }                      
    }
}