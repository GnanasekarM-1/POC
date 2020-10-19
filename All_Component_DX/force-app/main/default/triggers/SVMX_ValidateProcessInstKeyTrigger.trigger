/* Security Scanned */
trigger SVMX_ValidateProcessInstKeyTrigger on SVMXC__ServiceMax_Processes__c (before insert, before update ,before delete)
{

        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        {
                      SVMXC.COMM_Utils commUtil = new SVMXC.COMM_Utils();
                      // SVMXC.COMM_Utils_ManageTags commUtilTags = new SVMXC.COMM_Utils_ManageTags();
                      // Map<String, String> svmxTagList = commUtilTags.SVMX_getTagList('CONF014');
                        //Below Commented for BAC-4377
                     /* RecordType[] rtlist = [SELECT Id, Name FROM RecordType 
                                  WHERE SObjectType = 'SVMXC__ServiceMax_Processes__c' 
                                  AND Name IN ('Module', 'Submodule', 'Settings', 'Inventory Process', 'Object Mapping', 'Dispatch Process', 'Named Search', 'SVMX Rule', 'Target Manager')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                      ID ModuleRTID;
                      ID SubmoduleRTID;
                      ID SettingsRTID;
                      ID InventoryRTID;
                      ID ObjMapRTID;
                      ID dispProcessRTID;
                      ID namedSearchRTID;
                      ID svmxRuleRTID;
                      ID targetManagerRTID;
                      
                      for (RecordType rt : rtlist)
                          {
                          if (rt.Name == 'Module')
                              ModuleRTID = rt.Id;
                          else if (rt.Name == 'Submodule')
                              SubmoduleRTID = rt.Id;
                          else if (rt.Name == 'Settings')
                              SettingsRTID = rt.Id;
                          else if (rt.Name == 'Inventory Process')
                              InventoryRTID = rt.Id;
                          else if (rt.Name == 'Object Mapping')
                              ObjMapRTID = rt.Id;
                          else if (rt.Name == 'Dispatch Process')
                              dispProcessRTID = rt.Id;
                          else if (rt.Name == 'Named Search')
                              namedSearchRTID = rt.Id;
                          else if (rt.Name == 'SVMX Rule')
                              svmxRuleRTID = rt.Id;
                          else if (rt.Name == 'Target Manager')
                              targetManagerRTID = rt.Id;
                          }
                        */
                    // Added for BAC-4377. We used recordtype developer name insted of name
                List<String> lstRecordTypeNameData= new List<String>();
                lstRecordTypeNameData.add('Module');
                lstRecordTypeNameData.add('Submodule');
                lstRecordTypeNameData.add('Settings');
                lstRecordTypeNameData.add('Inventory_Process');
                lstRecordTypeNameData.add('Object_Mapping');
                lstRecordTypeNameData.add('Dispatch_Process');
                lstRecordTypeNameData.add('Named_Search');
                lstRecordTypeNameData.add('SVMX_Rule');
                lstRecordTypeNameData.add('Target_Manager');
                Map<String,Id> mapRecordTypeData = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Processes__c',lstRecordTypeNameData);
                  ID ModuleRTID, SubmoduleRTID, SettingsRTID, InventoryRTID, ObjMapRTID, dispProcessRTID, namedSearchRTID, svmxRuleRTID, targetManagerRTID;
              for(String tempRecorfTypeName: mapRecordTypeData.keySet()){
                    if (tempRecorfTypeName == 'Module' && mapRecordTypeData.get(tempRecorfTypeName) != null)
                        ModuleRTID = mapRecordTypeData.get(tempRecorfTypeName);
                    else if (tempRecorfTypeName == 'Submodule' && mapRecordTypeData.get(tempRecorfTypeName) != null)
                        SubmoduleRTID = mapRecordTypeData.get(tempRecorfTypeName);
                    else if (tempRecorfTypeName == 'Settings' && mapRecordTypeData.get(tempRecorfTypeName) != null)
                        SettingsRTID = mapRecordTypeData.get(tempRecorfTypeName);
                    else if (tempRecorfTypeName == 'Inventory_Process' && mapRecordTypeData.get(tempRecorfTypeName) != null)
                        InventoryRTID = mapRecordTypeData.get(tempRecorfTypeName);
                    else if (tempRecorfTypeName == 'Object_Mapping' && mapRecordTypeData.get(tempRecorfTypeName) != null)
                        ObjMapRTID = mapRecordTypeData.get(tempRecorfTypeName);
                    else if (tempRecorfTypeName == 'Dispatch_Process' && mapRecordTypeData.get(tempRecorfTypeName) != null)
                        dispProcessRTID = mapRecordTypeData.get(tempRecorfTypeName);
                    else if (tempRecorfTypeName == 'Named_Search' && mapRecordTypeData.get(tempRecorfTypeName) != null)
                        namedSearchRTID = mapRecordTypeData.get(tempRecorfTypeName);
                    else if (tempRecorfTypeName == 'SVMX_Rule' && mapRecordTypeData.get(tempRecorfTypeName) != null)
                        svmxRuleRTID = mapRecordTypeData.get(tempRecorfTypeName);
                    else if (tempRecorfTypeName == 'Target_Manager' && mapRecordTypeData.get(tempRecorfTypeName) != null)
                        targetManagerRTID = mapRecordTypeData.get(tempRecorfTypeName);
                  }
                  // End for BAC-4377. We used recordtype developer name insted of name
                      for (Integer i = 0; i < Trigger.new.size(); i++)
                          {
                           system.debug('++++'+Trigger.new[i].RecordTypeId+'++'+i+ '==' +ObjMapRTId+ '&&'+ Trigger.new[i].SVMXC__MapID__c);
                      system.debug('TEST TRIGGER:1 ' + Trigger.new[i]);
                      system.debug('TEST TRIGGER:2 ' + Trigger.new[i].RecordTypeId );
                                  // If no installation key is given,
                                  // the data must adhere to min-length requirements
                          if (Trigger.new[i].SVMXC__Installation_Key__c == null)
                              {
                              if (Trigger.new[i].RecordTypeId == ModuleRTID && Trigger.new[i].SVMXC__ModuleID__c.length() < 8)
                                  {
                                  Trigger.new[i].SVMXC__ModuleID__c.addError(System.Label.CONF014_TAG001); // 'Module ID should be at least 8 characters long.'
                                  }
                              else if (Trigger.new[i].RecordTypeId == SubmoduleRTID && Trigger.new[i].SVMXC__SubmoduleID__c.length() < 8)
                                  {
                                  Trigger.new[i].SVMXC__SubmoduleID__c.addError(System.Label.CONF014_TAG002); // 'Subodule ID should be at least 8 characters long.'
                                  }
                              else if (Trigger.new[i].RecordTypeId == SettingsRTID && Trigger.new[i].SVMXC__SettingID__c.length() < 8)
                                  {
                                  Trigger.new[i].SVMXC__SettingID__c.addError(System.Label.CONF014_TAG003); // 'Setting ID should be at least 8 characters long.'
                                  }
                              else if (Trigger.new[i].RecordTypeId == InventoryRTId && Trigger.new[i].SVMXC__ProcessID__c.length() < 8)
                                  {
                                  Trigger.new[i].SVMXC__ProcessID__c.addError(System.Label.CONF014_TAG004); // 'Inventory Process ID should be at least 8 characters long.'
                                  }
                              else if (Trigger.new[i].RecordTypeId == ObjMapRTId && Trigger.new[i].SVMXC__MapID__c.length() < 8)
                                  {
                                  Trigger.new[i].SVMXC__MapID__c.addError(System.Label.CONF014_TAG005); // 'Map ID should be at least 8 characters long.'
                                  }
                              else if (Trigger.new[i].RecordTypeId == dispProcessRTID && Trigger.new[i].SVMXC__Name__c.length() < 8)
                                  {
                                  Trigger.new[i].SVMXC__Name__c.addError(System.Label.CONF014_TAG011); // Dispatch process name should be at least 8 characters long.
                                  }
                              else if (Trigger.new[i].RecordTypeId == namedSearchRTID && (Trigger.new[i].SVMXC__Rule_Type__c != 'SRCH_OBJECT' && Trigger.new[i].SVMXC__ProcessID__c.length() < 8))
                                  {
                                  Trigger.new[i].SVMXC__ProcessID__c.addError(System.Label.CONF014_TAG012); // Named serach process Id should be at least 8 characters long.
                                  }
                              else if (Trigger.new[i].RecordTypeId == svmxRuleRTID)
                                  {
                                       if((Trigger.new[i].SVMXC__Rule_Type__c == 'Named Expression' && Trigger.new[i].SVMXC__SettingId__c.length() < 8) || ( (Trigger.new[i].SVMXC__Rule_Type__c == 'Event Hover Rule' || Trigger.new[i].SVMXC__Rule_Type__c == 'Event Subject Rule' || Trigger.new[i].SVMXC__Rule_Type__c == 'MTTS' || Trigger.new[i].SVMXC__Rule_Type__c == 'Work Order Territory') && Trigger.new[i].SVMXC__Name__c.length() < 8))
                                          Trigger.new[i].SVMXC__SettingId__c.addError(System.Label.CONF014_TAG013); // Rule ID should be at least 8 characters long.
                                   }
                              else if (Trigger.new[i].RecordTypeId == targetManagerRTID && Trigger.new[i].SVMXC__ProcessID__c.length() < 8)
                                  {
                                  Trigger.new[i].SVMXC__ProcessID__c.addError(System.Label.CONF014_TAG014); // 'Map ID should be at least 8 characters long.'
                                  }
                              }
                          else        // If installation key IS given
                                  // make sure the key is valid for the org and hasn't expired
                              {
                              commUtil.SVMX_IsValidInstallationKey(Trigger.new[i].SVMXC__Installation_Key__c, Trigger.new[i]);
                              Trigger.new[i].SVMXC__Installation_Key__c = null;
                              }
                          }
                              
                 }   
                //added for defect 039663 high volume ServiceMax Tag
                 if(Trigger.isDelete && Trigger.isBefore)
                    {
                            List<String> lstRecordType = new List<String>{'Target Manager', 'Wizard', 'Inventory Process'};
                            List<SVMXC__ServiceMax_Processes__c> tobedeleteProcesses=Trigger.old;
                            Set<String> keys=new Set<String>();   
                            Set<ID> usedId=new Set<ID>();
                            for(SVMXC__ServiceMax_Processes__c proc:tobedeleteProcesses)
                               {
                                   if(proc.SVMXC__Tag_Keys__c!=null && ((proc.SVMXC__Record_Type_Name__c=='Target Manager' || proc.SVMXC__Record_Type_Name__c=='Wizard' || proc.SVMXC__Record_Type_Name__c=='Inventory Process') || (proc.SVMXC__Record_Type_Name__c == 'Named Search' && proc.SVMXC__Rule_Type__c == 'SRCH_NAMED_SEARCH')))
                                   {
                                       keys.addAll(proc.SVMXC__Tag_Keys__c.split(';'));
                                       usedId.add(proc.id);
                                   }
                               }
                           
                               if(keys.size()>0 && usedId.size()>0)
                               {
                                   List<SVMXC__ServiceMax_Processes__c> procList=[select ID,SVMXC__Tag_Keys__c from SVMXC__ServiceMax_Processes__c where ( (NOT ID IN:usedId) and ((SVMXC__Record_Type_Name__c IN:lstRecordType) OR (SVMXC__Record_Type_Name__c = 'Named Search' AND SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH')) )]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                   
                                   Set<String> existingkeys=new Set<String>();
                                   for(SVMXC__ServiceMax_Processes__c pr:procList)
                                   {
                                       if(pr.SVMXC__Tag_Keys__c!=null)
                                       {
                                          existingkeys.addAll(pr.SVMXC__Tag_Keys__c.split(';'));
                                       }
                                   }
                                     
                                   keys.removeAll(existingkeys);
                                   keys.remove(null);
                                    
                                    if(keys.size()>0)
                                    {           
                                      List<SVMXC__ServiceMax_Tags__c> todelete = [select ID,SVMXC__Tag_Key__c from SVMXC__ServiceMax_Tags__c where SVMXC__Tag_Key__c IN:(keys)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                      if((COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Tags__c')) && (todelete.size()>0))
                                       {
                                          delete todelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                                       }
                                    }   
                                
                                }
                      }
        
}