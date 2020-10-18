/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * This is the class which checks and provides dependent entitiy details before 
 * deleting any entity.
 *
 * @author Servicemax
 * @version 
 * @since 2018
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
                Sachin S                Mar 2018
 *****************************************************************************************************/
public class SFM_GetEntityDependencies{
    
    Static final String dependency_wizardStep = 'Service Flow Wizard Step';
    Static final String dependency_linkedSFM = 'Linked SFM';
    Static final String dependency_multiSrcSFM = 'Multi-Source Update';
    Static final String dependency_scheduleSFM = 'Scheduled SFM Process'; 
    Static final String dependency_wizard = 'Service Flow Wizard';
    Static final String dependency_SFM = 'Service Flow Manager';
    Static final String dependency_IB_App = 'Installed Base App Setup';
    Static final String dependency_SPM_Setup = 'Service Performance Metrics Setup';
    Static final String dependency_Service_Proforma = 'Services Proforma Invoice Process';
    Static final String dependency_Scon_Proforma = 'Service Contract Proforma Invoice Process';
    Static final String dependency_PM_Process = 'Preventive Maintenance Process';
    Static final String dependency_Mobile_Configuration = 'Mobile Configuration';
    Static final String dependency_PageLayout = 'Page Layout';
    Static final String dependency_Checklist = 'Checklist';
    Static final String dependency_Question = 'Question';
    Static final String dependency_Output_Document = 'Output Document';
    Static final String dependency_Source_Object_Update = 'Source Object Update';
    Static final String dependency_Section_Exit_Criteria = 'Section Exit Criteria';

    public Static Set<Id> entityDependencyCheck(Set<Id> entityIds, String entityType){
        
        System.debug(LoggingLevel.ERROR, 'entityDependencyCheck - Enter, entityIds : ' + entityIds + ' entityType: ' + entityType); 
        //Map<Id, boolean> processDependencyMap = new Map<Id, boolean>();
        Set<Id> processWithDependencies = new Set<Id>();
        Id cmpId;
        Integer countRes = 0;
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'SVMXC__Process__c', 'SVMXC__Process2__c', 'SVMXC__Process3__c', 'SVMXC__Submodule__c', 
            'SVMXC__Page_Layout__c', 'SVMXC__Doc_Template__c', 'SVMXC__Module__c', 'SVMXC__ProcessID__c', 'SVMXC__Final_Exception_Process__c', 'SVMXC__Node_Parent__c'}, COMM_SecurityUtils.Access.Accessible)){
                
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Config_Data__c' , new List<String>{'Id', 'SVMXC__Expression_Rule__c', 'SVMXC__Dispatch_Process__c', 'SVMXC__Formula__c', 'SVMXC__Dispatch_Process__r.SVMXC__Name__c'}, COMM_SecurityUtils.Access.Accessible)){
            
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ProductIQProfile__c', new List<String>{'Id', 'SVMXC__Contents__c'}, COMM_SecurityUtils.Access.Accessible )){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Page_Layout_Detail__c', new List<String>{'Id', 'SVMXC__Field_Mapping__c', 'SVMXC__Question__c'}, COMM_SecurityUtils.Access.Accessible )){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }           

        try{
            if(entityType == SFM_DesignerUtils.entity_sfm || entityType == SFM_DesignerUtils.entity_opdoc || entityType == SFM_DesignerUtils.entity_checklist){
                /*
                    For wizards
                */
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Process__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name = 'Wizard Step' AND SVMXC__Process__c IN : entityIds) 
                                                                    group by SVMXC__Process__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Process__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }

                }

                if(entityType != SFM_DesignerUtils.entity_opdoc){
                    /*
                        For Linked SFM
                    */
                    for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Process3__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name = 'Linked Process' AND SVMXC__Process3__c IN : entityIds) 
                                                                        group by SVMXC__Process3__c]){
                        
                        cmpId = (Id)aggResult.get('SVMXC__Process3__c');
                        countRes = (Integer)aggResult.get('expr0');
                        
                        if(countRes > 0){
                           
                           processWithDependencies.add(cmpId); 
                        }

                    }
                             
                    
                    /*
                        For MultiSource Configuration
                    */
                    for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Process2__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name = 'Target Manager' AND SVMXC__Process2__c IN : entityIds) 
                                                                        group by SVMXC__Process2__c]){
                        
                        cmpId = (Id)aggResult.get('SVMXC__Process2__c');
                        countRes = (Integer)aggResult.get('expr0');
                        
                        if(countRes > 0){
                           
                           processWithDependencies.add(cmpId); 
                        }
               
                    }

                    /*
                        For Scheduled SFM
                    */
                    for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Expression_Rule__c FROM SVMXC__ServiceMax_Config_Data__c WHERE (RecordType.Name = 'Schedule Detail' AND SVMXC__Expression_Rule__c IN : entityIds) 
                                                                        group by SVMXC__Expression_Rule__c]){
                        
                        cmpId = (Id)aggResult.get('SVMXC__Expression_Rule__c');
                        countRes = (Integer)aggResult.get('expr0');
                        
                        if(countRes > 0){
                           
                           processWithDependencies.add(cmpId); 
                        }
             
                    }   

                    /*
                        For Product IQ Setup
                    */
                    for(SVMXC__ProductIQProfile__c productIQProfile : [SELECT Id, SVMXC__Contents__c FROM SVMXC__ProductIQProfile__c]){
                        
                        for(Id entityId : entityIds){
                            
                            if(productIQProfile.SVMXC__Contents__c != null && productIQProfile.SVMXC__Contents__c.contains(entityId)){
                                processWithDependencies.add(entityId);
                            }
                        }           
                    }
                }
                    
                if(entityType == SFM_DesignerUtils.entity_checklist){
                    for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Process2__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name = 'Checklist Smart Doc' AND SVMXC__Process2__c IN : entityIds)
                                                                    group by SVMXC__Process2__c]){
                        cmpId = (Id)aggResult.get('SVMXC__Process2__c');
                        countRes = (Integer)aggResult.get('expr0');
                        if(countRes > 0){
                            processWithDependencies.add(cmpId);
                        }
                    }
                }
            }


            if(entityType == SFM_DesignerUtils.entity_expression){
                /*
                    For Wizards, Wizard Steps, Service Proforma Invoice Process & SFMs
                    TBD : Include mobile configuration in the dependency list
                */
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Submodule__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name  IN ('Wizard Step', 'Wizard', 'Process Node Objects', 'Work Order Billing Process') AND SVMXC__Submodule__c IN : entityIds
                                                                    group by SVMXC__Submodule__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Submodule__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }

                }
                
                /*
                    For Service Proforma Invoice Process & Service Contract Proforma Invoice Process
                */
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Module__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name  IN ('Contract Billing Process', 'Work Order Billing Process','PM Process') AND SVMXC__Module__c IN : entityIds 
                                                                    group by SVMXC__Module__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Module__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }
                }


                /*
                    For Mobile Configuration
                */
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Dispatch_Process__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name IN ('Mobile Configuration') AND SVMXC__Dispatch_Process__c IN : entityIds AND SVMXC__Display_Type__c IN ('Download Criteria','Advanced Download Criteria')
                                                                    group by SVMXC__Dispatch_Process__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Dispatch_Process__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }
                }


                List<SVMXC__ServiceMax_Processes__c> expressionsList =  [SELECT Id,SVMXC__ProcessID__c FROM SVMXC__ServiceMax_Processes__c WHERE ID IN : entityIds];

                /*
                    For SPM Rules
                */
                for(SVMXC__ServiceMax_Config_Data__c configRec : [SELECT Id, SVMXC__Formula__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = 'SPM Details']){
                    for(SVMXC__ServiceMax_Processes__c expressionRec : expressionsList){
                        System.debug(LoggingLevel.INFO, 'SPM Config JSON :' + configRec.SVMXC__Formula__c);
                        if(configRec.SVMXC__Formula__c != null && (configRec.SVMXC__Formula__c.trim().contains('"expressionRuleId":"'+ expressionRec.SVMXC__ProcessID__c + '"') || configRec.SVMXC__Formula__c.trim().contains('"selectedCriteria":"'+ expressionRec.SVMXC__ProcessID__c + '"'))){
                            processWithDependencies.add(expressionRec.Id);
                        }
                    }
                }
            }

            if(entityType == SFM_DesignerUtils.entity_businessrule || entityType == SFM_DesignerUtils.entity_formula ){
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Process3__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name  IN ('Process Business Rule') AND SVMXC__Process3__c IN : entityIds) 
                                                                    group by SVMXC__Process3__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Process3__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }

                }            
            }

            if(entityType == SFM_DesignerUtils.entity_mapping){
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Module__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name  IN ('Process Node Objects') AND SVMXC__Module__c IN : entityIds) 
                                                                    group by SVMXC__Module__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Module__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }

                }    
                
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Final_Exception_Process__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name  IN ('Process Node Objects') AND SVMXC__Final_Exception_Process__c IN : entityIds) 
                                                                    group by SVMXC__Final_Exception_Process__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Final_Exception_Process__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }

                } 

                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Field_Mapping__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Field_Mapping__c IN : entityIds 
                                                                    group by SVMXC__Field_Mapping__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Field_Mapping__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }

                }  
                
                for(SVMXC__ServiceMax_Processes__c processRecord : [SELECT Id, SVMXC__Process__c, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Submodule__c, SVMXC__Node_Parent__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name IN ('PM Process') AND (SVMXC__Process1__c IN : entityIds OR 
                                                        SVMXC__Process2__c IN : entityIds OR SVMXC__Process3__c IN : entityIds OR SVMXC__Submodule__c IN : entityIds OR SVMXC__Node_Parent__c IN : entityIds OR SVMXC__Process__c IN : entityIds)]){
                    
                    if(processRecord.SVMXC__Process__c != null && entityIds.contains(processRecord.SVMXC__Process__c)){
                        processWithDependencies.add(processRecord.SVMXC__Process__c); 
                    }

                    if(processRecord.SVMXC__Process1__c != null && entityIds.contains(processRecord.SVMXC__Process1__c)){
                        processWithDependencies.add(processRecord.SVMXC__Process1__c); 
                    }
                    
                    if(processRecord.SVMXC__Process2__c != null && entityIds.contains(processRecord.SVMXC__Process2__c)){
                        processWithDependencies.add(processRecord.SVMXC__Process2__c); 
                    }
                    
                    if(processRecord.SVMXC__Process3__c != null && entityIds.contains(processRecord.SVMXC__Process3__c)){
                        processWithDependencies.add(processRecord.SVMXC__Process3__c); 
                    }

                    if(processRecord.SVMXC__Submodule__c != null && entityIds.contains(processRecord.SVMXC__Submodule__c)){
                        processWithDependencies.add(processRecord.SVMXC__Submodule__c); 
                    }

                    if(processRecord.SVMXC__Node_Parent__c != null && entityIds.contains(processRecord.SVMXC__Node_Parent__c)){
                        processWithDependencies.add(processRecord.SVMXC__Node_Parent__c); 
                    }
                }   
            }

            if(entityType == SFM_DesignerUtils.entity_layout){
                
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Page_Layout__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name = 'Target Manager' AND SVMXC__Page_Layout__c IN : entityIds) 
                                                                    group by SVMXC__Page_Layout__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Page_Layout__c');
                    countRes = (Integer)aggResult.get('expr0');
                    
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }
           
                }
            }

            if(entityType == SFM_DesignerUtils.entity_template){
                
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Doc_Template__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name = 'Target Manager' AND SVMXC__Doc_Template__c IN : entityIds) 
                                                                    group by SVMXC__Doc_Template__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Doc_Template__c');
                    countRes = (Integer)aggResult.get('expr0');
                    
                    if(countRes > 0){
                       
                       processWithDependencies.add(cmpId); 
                    }
           
                }
            }

            if(entityType == SFM_DesignerUtils.entity_lkpConfig){
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Named_Search__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Named_Search__c IN : entityIds 
                                                                    group by SVMXC__Named_Search__c]){
                    
                    cmpId = (Id)aggResult.get('SVMXC__Named_Search__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       processWithDependencies.add(cmpId);
                    }
                }
            }
            
            /*if(entityType == SFM_DesignerUtils.entity_question){
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Question__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Question__c IN : entityIds
                                                                    group by SVMXC__Question__c]){
                    cmpId = (Id)aggResult.get('SVMXC__Question__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){

                       processWithDependencies.add(cmpId);
                    }                    
                }
            }

            if(entityType == SFM_DesignerUtils.entity_sectionEntryCriteria){
                for(AggregateResult aggResult : [SELECT count(Id), SVMXC__Process3__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process3__c IN : entityIds AND SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria'
                                                                    group by SVMXC__Process3__c]){
                    cmpId = (Id)aggResult.get('SVMXC__Process3__c');
                    countRes = (Integer)aggResult.get('expr0');
                    if(countRes > 0){
                       processWithDependencies.add(cmpId); 
                    }

                }                  
            }*/

         }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'entityDependencyCheck - Exception ' + ex.getMessage());
            throw ex;
         }   

        System.debug(LoggingLevel.ERROR, 'entityDependencyCheck - Exit, Response' + processWithDependencies); 
        return processWithDependencies;     
                    
    }

    public Static Map<Id,List<SFM_WrapperDef2.SFM2_Dependency>> getWhereUsedDetails(List<String> entityIds, String entityType){
        
        System.debug(LoggingLevel.INFO, 'getWhereUsedDetails - Enter , entityIds : ' + entityIds + ' entityType: ' + entityType);
        /*
            For wizards
        */
        Set<String> entityIdsSet = new Set<String>(entityIds);
        Map<Id, List<sObject>> processMap = new Map<Id, List<sObject>>();
        Map<Id, List<SFM_WrapperDef2.SFM2_Dependency>> entityDependencyMap = new Map<Id, List<SFM_WrapperDef2.SFM2_Dependency>>();

        /*
            Security Check: Checking FLS for all querying fields
            Objects: SVMXC__ServiceMax_Processes__c, SVMXC__ServiceMax_Config_Data__c, SVMXC__ProductIQProfile__c, SVMXC__Page_Layout_Detail__c
        */


        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Processes__c', new List<String>{'Id', 'RecordType.Name', 'SVMXC__ProcessID__c', 'SVMXC__IsStandard__c', 'SVMXC__Name__c', 'SVMXC__Action_Type__c', 'SVMXC__Process__c', 'SVMXC__Module__c', 'SVMXC__Module__r.SVMXC__Name__c', 'SVMXC__Process1__r.SVMXC__Name__c', 
            'SVMXC__Page_Layout__c', 'SVMXC__Doc_Template__c', 'SVMXC__Process2__c', 'SVMXC__Submodule__c', 'SVMXC__Process__r.SVMXC__Name__c', 'SVMXC__Process1__c', 'SVMXC__Process3__c', 'SVMXC__Final_Exception_Process__c', 'SVMXC__Node_Parent__c'}, COMM_SecurityUtils.Access.Accessible)){
                
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ServiceMax_Config_Data__c' , new List<String>{'Id', 'RecordType.Name', 'SVMXC__Dispatch_Process__c', 'SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c', 'SVMXC__Dispatch_Process__r.SVMXC__Name__c', 'SVMXC__Expression_Rule__c', 
            'SVMXC__Formula__c', 'SVMXC__SM_Device_Mobile_Config__c', 'SVMXC__SM_Device_Mobile_Config__r.SVMXC__SM_Name__c'}, COMM_SecurityUtils.Access.Accessible)){
                
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__ProductIQProfile__c', new List<String>{'Id', 'SVMXC__Contents__c', 'SVMXC__ServiceMax_Profile__c', 'SVMXC__ServiceMax_Profile__r.SVMXC__Profile_Name__c'}, COMM_SecurityUtils.Access.Accessible )){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess('SVMXC__Page_Layout_Detail__c', new List<String>{'Id', 'SVMXC__Page_Layout__c', 'SVMXC__IsStandard__c', 'SVMXC__Page_Layout__r.SVMXC__Name__c', 'SVMXC__Field_Mapping__c', 'SVMXC__Question__c'}, COMM_SecurityUtils.Access.Accessible )){
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }



        try{
            if(entityType == SFM_DesignerUtils.entity_sfm || entityType == SFM_DesignerUtils.entity_opdoc || entityType == SFM_DesignerUtils.entity_checklist){

                for(SVMXC__ServiceMax_Processes__c wizardResult : [SELECT Id, RecordType.Name, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Action_Type__c, SVMXC__Process__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__Name__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Wizard Step' AND SVMXC__Process__c IN : entityIdsSet]){
                    
                    putToMap(wizardResult.SVMXC__Process__c, processMap, wizardResult);

                }  

                if(entityType != SFM_DesignerUtils.entity_opdoc){
                    /*
                        For Linked SFM
                    */
                    
                    for(SVMXC__ServiceMax_Processes__c linkedSFM : [SELECT Id, RecordType.Name, SVMXC__ProcessID__c, SVMXC__Process1__r.SVMXC__Name__c, SVMXC__Process1__r.SVMXC__IsStandard__c, SVMXC__Process3__c, SVMXC__Process1__r.SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Linked Process' AND SVMXC__Process3__c IN : entityIdsSet]){
                        
                        putToMap(linkedSFM.SVMXC__Process3__c, processMap, linkedSFM);


                    }    

                    /*
                        For MultiSource Configuration
                    */
                   
                    for(SVMXC__ServiceMax_Processes__c multiSrcSFM : [SELECT Id, RecordType.Name, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Process2__c, SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Target Manager' AND SVMXC__Process2__c IN : entityIdsSet]){
                        
                        putToMap(multiSrcSFM.SVMXC__Process2__c, processMap, multiSrcSFM);
               
                    }  


                    /*
                        For Scheduled SFM
                    */
                    for(SVMXC__ServiceMax_Config_Data__c configRec : [SELECT Id, RecordType.Name, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__IsStandard__c, SVMXC__Expression_Rule__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = 'Schedule Detail' AND SVMXC__Expression_Rule__c IN : entityIdsSet]){
                        putToMap(configRec.SVMXC__Expression_Rule__c, processMap, configRec);
             
                    } 


                    /*
                        For Product IQ Setup
                    */
                    for(SVMXC__ProductIQProfile__c productIQProfile : [SELECT Id, SVMXC__Contents__c, SVMXC__ServiceMax_Profile__c, SVMXC__ServiceMax_Profile__r.SVMXC__Profile_Name__c FROM SVMXC__ProductIQProfile__c]){
                        
                        for(Id entityId : entityIds){
                            
                            if(productIQProfile.SVMXC__Contents__c != null && productIQProfile.SVMXC__Contents__c.contains(entityId)){
                                putToMap(entityId, processMap, productIQProfile);
                            }
                        }           
                    }  
                }          

                if(entityType == SFM_DesignerUtils.entity_checklist){
                    /*
                        For opdoc checklist
                    */
                    for(SVMXC__ServiceMax_Processes__c opdocChecklist : [SELECT Id, RecordType.Name, SVMXC__Process1__c, SVMXC__Process1__r.SVMXC__IsStandard__c, SVMXC__Process1__r.SVMXC__Name__c, SVMXC__Process2__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name = 'Checklist Smart Doc' AND SVMXC__Process2__c IN : entityIdsSet]){
                        putToMap(opdocChecklist.SVMXC__Process2__c, processMap, opdocChecklist);
                    }                    
                }
            }else if(entityType == SFM_DesignerUtils.entity_expression){
            
                List<SVMXC__ServiceMax_Processes__c> expressionsList = new List<SVMXC__ServiceMax_Processes__c>();
                for(SVMXC__ServiceMax_Processes__c processRecord :  [SELECT Id, RecordType.Name, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Name__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__Name__c, SVMXC__Process__r.SVMXC__IsStandard__c, SVMXC__Process__r.SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c WHERE (RecordType.Name IN ('Wizard Step', 'Wizard', 'Process Node Objects', 'Work Order Billing Process') AND SVMXC__Submodule__c IN : entityIdsSet) 
                                                                        OR (Id IN : entityIdsSet)]){
                    if(processRecord.RecordType.Name != 'SVMX Rule'){
                        putToMap(processRecord.SVMXC__Submodule__c, processMap, processRecord);
                    }else{
                        expressionsList.add(processRecord);
                    }    
                }
                                                                   
                
                for(SVMXC__ServiceMax_Processes__c processRecord :  [SELECT Id, RecordType.Name, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name IN ('Contract Billing Process', 'Work Order Billing Process', 'PM Process') AND SVMXC__Module__c IN : entityIdsSet]){
                    putToMap(processRecord.SVMXC__Module__c, processMap, processRecord);
                }

                /*
                    For SPM Rules
                */
                for(SVMXC__ServiceMax_Config_Data__c configRec : [SELECT Id, RecordType.Name, SVMXC__Formula__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = 'SPM Details']){
                    for(SVMXC__ServiceMax_Processes__c expressionRec : expressionsList){
                        System.debug('Formula ' + configRec.SVMXC__Formula__c.trim() + ' "expressionRuleId":"'+ expressionRec.SVMXC__ProcessID__c + '" ');
                        if(configRec.SVMXC__Formula__c != null && (configRec.SVMXC__Formula__c.trim().contains('"expressionRuleId":"'+ expressionRec.SVMXC__ProcessID__c + '"') || configRec.SVMXC__Formula__c.trim().contains('"selectedCriteria":"'+ expressionRec.SVMXC__ProcessID__c + '"'))){
                            putToMap(expressionRec.Id, processMap, configRec);
                        }
                    }
                }
                
                /*
                    For Scheduled SFM
                */
                for(SVMXC__ServiceMax_Config_Data__c configRec : [SELECT Id, RecordType.Name, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__ProcessID__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__IsStandard__c, SVMXC__Expression_Rule__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name = 'Schedule Detail' AND SVMXC__Expression_Rule__c IN : entityIdsSet]){
                    putToMap(configRec.SVMXC__Expression_Rule__c, processMap, configRec);
                    
                } 

                /*
                    For Mobile Configuration
                */
                for(SVMXC__ServiceMax_Config_Data__c configRec : [SELECT Id, RecordType.Name, SVMXC__SM_Device_Mobile_Config__c, SVMXC__SM_Device_Mobile_Config__r.SVMXC__SM_Name__c, SVMXC__Dispatch_Process__c FROM SVMXC__ServiceMax_Config_Data__c WHERE RecordType.Name  IN ('Mobile Configuration') AND SVMXC__Dispatch_Process__c IN : entityIds 
                                                 AND SVMXC__Display_Type__c IN ('Download Criteria','Advanced Download Criteria')]){
                    
                    putToMap(configRec.SVMXC__Dispatch_Process__c, processMap, configRec);
                }            

            }else if(entityType == SFM_DesignerUtils.entity_businessrule || entityType == SFM_DesignerUtils.entity_formula){

                for(SVMXC__ServiceMax_Processes__c processRecord :  [SELECT Id, SVMXC__Rule_Type__c, RecordType.Name, SVMXC__Process1__c, SVMXC__Process1__r.SVMXC__Name__c, SVMXC__Process1__r.SVMXC__IsStandard__c, SVMXC__Process3__c, SVMXC__Process1__r.SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c 
                                                                       WHERE RecordType.Name  IN ('Process Business Rule') AND SVMXC__Process3__c IN : entityIdsSet]){
                    putToMap(processRecord.SVMXC__Process3__c, processMap, processRecord);
                }
            }else if(entityType == SFM_DesignerUtils.entity_mapping){
                
                /*
                    For SFMs
                */
                for(SVMXC__ServiceMax_Processes__c processRecord : [SELECT Id, RecordType.Name, SVMXC__Process__c, SVMXC__Process__r.SVMXC__Name__c, SVMXC__Process__r.SVMXC__IsStandard__c, SVMXC__Module__c,
                    SVMXC__Final_Exception_Process__c,SVMXC__Process__r.SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c 
                    WHERE RecordType.Name  IN ('Process Node Objects') AND (SVMXC__Module__c IN : entityIdsSet OR SVMXC__Final_Exception_Process__c IN : entityIdsSet)]){
                    if(processRecord.SVMXC__Module__c != null && entityIdsSet.contains(processRecord.SVMXC__Module__c)){
                        putToMap(processRecord.SVMXC__Module__c, processMap, processRecord);
                    }

                    if(processRecord.SVMXC__Final_Exception_Process__c != null && entityIdsSet.contains(processRecord.SVMXC__Final_Exception_Process__c)){
                        putToMap(processRecord.SVMXC__Final_Exception_Process__c, processMap, processRecord);
                    }
                } 


                for(SVMXC__Page_Layout_Detail__c pageLayoutRecord : [SELECT Id, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__r.SVMXC__Name__c, SVMXC__Question__c,
                                                                        SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__r.SVMXC__IsStandard__c, SVMXC__Page_Layout__r.SVMXC__Name__c, SVMXC__Page_Layout__r.SVMXC__IsStandard__c, SVMXC__Field_Mapping__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Field_Mapping__c IN : entityIdsSet]){
                    
                   putToMap(pageLayoutRecord.SVMXC__Field_Mapping__c, processMap, pageLayoutRecord);

                } 

                /*
                    For PMs
                */
                for(SVMXC__ServiceMax_Processes__c processRecord : [SELECT Id, RecordType.Name, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Process__c, SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Submodule__c, SVMXC__Node_Parent__c FROM SVMXC__ServiceMax_Processes__c WHERE RecordType.Name  IN ('PM Process') AND (SVMXC__Process1__c IN : entityIdsSet OR 
                                                        SVMXC__Process2__c IN : entityIdsSet OR SVMXC__Process3__c IN : entityIdsSet OR SVMXC__Submodule__c IN : entityIdsSet OR SVMXC__Node_Parent__c IN : entityIdsSet OR SVMXC__Process__c IN : entityIdsSet)]){
                    
                    if(processRecord.SVMXC__Process__c != null && entityIdsSet.contains(processRecord.SVMXC__Process__c)){
                        putToMap(processRecord.SVMXC__Process__c, processMap, processRecord);
                    }

                    if(processRecord.SVMXC__Process1__c != null && entityIdsSet.contains(processRecord.SVMXC__Process1__c)){
                        putToMap(processRecord.SVMXC__Process1__c, processMap, processRecord);
                    }

                    if(processRecord.SVMXC__Process2__c != null && entityIdsSet.contains(processRecord.SVMXC__Process2__c)){
                        putToMap(processRecord.SVMXC__Process2__c, processMap, processRecord);
                    }

                    if(processRecord.SVMXC__Process3__c != null && entityIdsSet.contains(processRecord.SVMXC__Process3__c)){
                        putToMap(processRecord.SVMXC__Process3__c, processMap, processRecord);
                    }

                    if(processRecord.SVMXC__Submodule__c != null && entityIdsSet.contains(processRecord.SVMXC__Submodule__c)){
                        putToMap(processRecord.SVMXC__Submodule__c, processMap, processRecord);
                    }

                    if(processRecord.SVMXC__Node_Parent__c != null && entityIdsSet.contains(processRecord.SVMXC__Node_Parent__c)){
                        putToMap(processRecord.SVMXC__Node_Parent__c, processMap, processRecord);
                    }
                }            
            }else if(entityType == SFM_DesignerUtils.entity_layout){
                
                for(SVMXC__ServiceMax_Processes__c processRecord : [SELECT Id, RecordType.Name, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Page_Layout__c, SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c 
                                                                      WHERE RecordType.Name = 'Target Manager' AND SVMXC__Page_Layout__c IN : entityIdsSet]){
                    putToMap(processRecord.SVMXC__Page_Layout__c, processMap, processRecord);
                }                    
            }else if(entityType == SFM_DesignerUtils.entity_template){
                
                for(SVMXC__ServiceMax_Processes__c processRecord : [SELECT Id, RecordType.Name, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Doc_Template__c, SVMXC__IsStandard__c, SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c 
                                                                      WHERE RecordType.Name = 'Target Manager' AND SVMXC__Doc_Template__c IN : entityIdsSet]){
                    putToMap(processRecord.SVMXC__Doc_Template__c, processMap, processRecord);
                }                    
            }else if(entityType == SFM_DesignerUtils.entity_lkpConfig){
                
                for(SVMXC__Page_Layout_Detail__c pageLayoutRecord : [SELECT Id, SVMXC__Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__r.SVMXC__Name__c, SVMXC__Question__c,
                                                                        SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__r.SVMXC__IsStandard__c, SVMXC__Page_Layout__r.SVMXC__Name__c, SVMXC__Page_Layout__r.SVMXC__IsStandard__c, SVMXC__Named_Search__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Named_Search__c IN : entityIdsSet]){
                    
                   putToMap(pageLayoutRecord.SVMXC__Named_Search__c, processMap, pageLayoutRecord);

                }
            }else if(entityType == SFM_DesignerUtils.entity_question){
                List<SVMXC__Page_Layout_Detail__c> questionDetailList = new List<SVMXC__Page_Layout_Detail__c>();
                Set<Id> pageLayoutIds = new Set<Id>();
                for(SVMXC__Page_Layout_Detail__c pageLayoutDetailRecord : [SELECT Id, SVMXC__Page_Layout__c, SVMXC__Question__c FROM SVMXC__Page_Layout_Detail__c WHERE SVMXC__Question__c IN: entityIdsSet]){
                    if(pageLayoutDetailRecord.SVMXC__Page_Layout__c != null){
                        pageLayoutIds.add(pageLayoutDetailRecord.SVMXC__Page_Layout__c );
                        questionDetailList.add(pageLayoutDetailRecord);
                    }                    
                }
                if(!pageLayoutIds.isEmpty()){
                    Map<String, SVMXC__ServiceMax_Processes__c> layoutProcessMap = new Map<String, SVMXC__ServiceMax_Processes__c>();
                    for(SVMXC__ServiceMax_Processes__c processRecord : [SELECT Id, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Page_Layout__c, RecordType.Name, SVMXC__Purpose__c FROM SVMXC__ServiceMax_Processes__c 
                                                                            WHERE SVMXC__Page_Layout__c IN: pageLayoutIds AND SVMXC__Purpose__c = 'CHECKLIST' AND RecordType.Name = 'Target Manager']){
                        layoutProcessMap.put(processRecord.SVMXC__Page_Layout__c, processRecord);                                                    
                    }
                    for(SVMXC__Page_Layout_Detail__c pageLayoutDetailRecord : questionDetailList){
                        if(layoutProcessMap.containsKey(pageLayoutDetailRecord.SVMXC__Page_Layout__c)){
                            putToMap(pageLayoutDetailRecord.SVMXC__Question__c, processMap, layoutProcessMap.get(pageLayoutDetailRecord.SVMXC__Page_Layout__c));
                        }
                    }
                }

                for(SVMXC__ServiceMax_Config_Data__c configRec : [SELECT Id, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c, SVMXC__Dispatch_Process__r.SVMXC__IsStandard__c, RecordType.Name, SVMXC__SM_Question__c FROM 
                                                                    SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__SM_Question__c IN: entityIdsSet AND SVMXC__Configuration_Type__c = 'Source Update' AND RecordType.Name = 'Field Mapping']){
                    putToMap(configRec.SVMXC__SM_Question__c, processMap, configRec);
                }

                for(SVMXC__ServiceMax_Processes__c exitCriteraJunctionRec : [SELECT Id, SVMXC__Process1__c, SVMXC__Process1__r.SVMXC__Name__c, SVMXC__Process1__r.SVMXC__IsStandard__c, SVMXC__Process1__r.SVMXC__Purpose__c, SVMXC__Process3__c, SVMXC__Process3__r.SVMXC__Question_Bank__c,
                                                                                RecordType.Name, SVMXC__Rule_Type__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process3__r.SVMXC__Question_Bank__c IN: entityIdsSet AND SVMXC__Rule_Type__c = 'Checklist_Section_Exit_Criteria'
                                                                                AND RecordType.Name = 'Process Business Rule']){

                    putToMap(exitCriteraJunctionRec.SVMXC__Process3__r.SVMXC__Question_Bank__c, processMap, exitCriteraJunctionRec);
                }

            }else if(entityType == SFM_DesignerUtils.entity_responseSet){
                for(SVMXC__Question_Bank__c questionRecord : [SELECT Id, SVMXC__Question__c, SVMXC__Response_Set__c FROM SVMXC__Question_Bank__c WHERE SVMXC__Response_Set__c IN : entityIdsSet]){
                   putToMap(questionRecord.SVMXC__Response_Set__c, processMap, questionRecord);
                }
            }else if(entityType == SFM_DesignerUtils.entity_sectionEntryCriteria){
                for(SVMXC__ServiceMax_Processes__c entryCriteraJunctionRec : [SELECT Id, SVMXC__Process1__c, SVMXC__Process1__r.SVMXC__Name__c, SVMXC__Process1__r.SVMXC__IsStandard__c, SVMXC__Process1__r.SVMXC__Purpose__c, SVMXC__Process3__c, 
                                                                                RecordType.Name, SVMXC__Rule_Type__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Process3__c IN: entityIdsSet AND SVMXC__Rule_Type__c = 'Checklist_Section_Entry_Criteria'
                                                                                AND RecordType.Name = 'Process Business Rule']){
                    putToMap(entryCriteraJunctionRec.SVMXC__Process3__c, processMap, entryCriteraJunctionRec);
                }              
            }

            for(Id processId : processMap.keySet()){
                List<SFM_WrapperDef2.SFM2_EntityDetail> wizardStepsList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> linkedSFMList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> multiSrcList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> scheduleList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> wizardList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> processNodeList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> processBusinessRuleList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> productIQSetupList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> sPMExpressionList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> serviceProformaList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> sconProformaList;    
                List<SFM_WrapperDef2.SFM2_EntityDetail> pmProcessList;  
                List<SFM_WrapperDef2.SFM2_EntityDetail> mobileConfigList;  
                List<SFM_WrapperDef2.SFM2_EntityDetail> pageLayoutList;  
                List<SFM_WrapperDef2.SFM2_EntityDetail> questionList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> outputDocList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> sourceObjectUpdateList;
                List<SFM_WrapperDef2.SFM2_EntityDetail> exitCriteriaList;
                
                for(sObject sObjRec : processMap.get(processId)){
                    sObjectType sObjType = sObjRec.getSObjectType();
                    Schema.DescribeSObjectResult sObjRes = sObjType.getDescribe();
                    List<Schema.RecordTypeInfo> recordTypeInfos = sObjRes.getRecordTypeInfos();
                    String rTypeName;
                    if(recordTypeInfos.size() > 1)
                        rTypeName = (String)sobjRec.getSObject('RecordType').get('Name');

                    if(rTypeName == null){
                        if(String.valueOf(sObjType) == 'SVMXC__ProductIQProfile__c'){
                            if(productIQSetupList == null)
                                productIQSetupList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();

                            SVMXC__ProductIQProfile__c productIQsetup = (SVMXC__ProductIQProfile__c)sobjRec; 
                            addToEntityDetails(productIQsetup.SVMXC__ServiceMax_Profile__r.SVMXC__Profile_Name__c, productIQsetup.Id, productIQsetup.Id, false, productIQSetupList, null);
              
                        }else if(String.valueOf(sObjType) == 'SVMXC__Page_Layout_Detail__c'){ 
                            SVMXC__Page_Layout_Detail__c pageLayoutDetailRec = (SVMXC__Page_Layout_Detail__c)sobjRec;
                            if(pageLayoutList == null)
                                pageLayoutList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();

                            if(pageLayoutDetailRec.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c != null){
                                addToEntityDetails(pageLayoutDetailRec.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__r.SVMXC__Name__c, pageLayoutDetailRec.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, pageLayoutDetailRec.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__c, 
                                    pageLayoutDetailRec.SVMXC__Page_Layout__r.SVMXC__Header_Page_Layout__r.SVMXC__IsStandard__c, pageLayoutList, null);
                            }else{
                                addToEntityDetails(pageLayoutDetailRec.SVMXC__Page_Layout__r.SVMXC__Name__c, pageLayoutDetailRec.SVMXC__Page_Layout__c, pageLayoutDetailRec.SVMXC__Page_Layout__c, 
                                    pageLayoutDetailRec.SVMXC__Page_Layout__r.SVMXC__IsStandard__c, pageLayoutList, null);
                            }
                        }else if(String.valueOf(sObjType) == 'SVMXC__Question_Bank__c'){
                            if(questionList == null){
                                questionList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        }       
                            SVMXC__Question_Bank__c questionRecord = (SVMXC__Question_Bank__c)sobjRec;
                            addToEntityDetails(questionRecord.SVMXC__Question__c, questionRecord.Id, questionRecord.Id, false, questionList, null);
                        }
                    }else if(rTypeName == 'Wizard Step'){
                        if(wizardStepsList == null)
                            wizardStepsList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();

                        SVMXC__ServiceMax_Processes__c wizardRec = (SVMXC__ServiceMax_Processes__c)sobjRec; 
                        addToEntityDetails(wizardRec.SVMXC__Name__c, wizardRec.Id, wizardRec.SVMXC__Module__c, wizardRec.SVMXC__IsStandard__c, wizardStepsList, null);
                    
                    }else if(rTypeName == 'Linked Process'){
                        if(linkedSFMList == null)
                            linkedSFMList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        SVMXC__ServiceMax_Processes__c linkedSFMRec = (SVMXC__ServiceMax_Processes__c)sobjRec; 
                        addToEntityDetails(linkedSFMRec.SVMXC__Process1__r.SVMXC__Name__c, linkedSFMRec.Id, linkedSFMRec.SVMXC__Process1__c, linkedSFMRec.SVMXC__Process1__r.SVMXC__IsStandard__c, linkedSFMList, linkedSFMRec.SVMXC__Process1__r.SVMXC__Purpose__c);

                    }else if(rTypeName == 'Target Manager'){
                        if(multiSrcList == null)
                            multiSrcList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();

                        SVMXC__ServiceMax_Processes__c multiSrcRec = (SVMXC__ServiceMax_Processes__c)sobjRec; 
                        addToEntityDetails(multiSrcRec.SVMXC__Name__c, multiSrcRec.Id, multiSrcRec.Id, multiSrcRec.SVMXC__IsStandard__c, multiSrcList, multiSrcRec.SVMXC__Purpose__c);
                                         
                    }else if(rTypeName == 'Schedule Detail'){
                        if(scheduleList == null)
                            scheduleList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        SVMXC__ServiceMax_Config_Data__c scheduleSFMRec = (SVMXC__ServiceMax_Config_Data__c)sobjRec; 
                        addToEntityDetails(scheduleSFMRec.SVMXC__Dispatch_Process__r.SVMXC__Name__c, scheduleSFMRec.SVMXC__Dispatch_Process__r.Id, scheduleSFMRec.SVMXC__Dispatch_Process__r.Id, 
                            scheduleSFMRec.SVMXC__Dispatch_Process__r.SVMXC__IsStandard__c, scheduleList, null);
                       
                    }else if(rTypeName == 'Wizard'){
                        if(wizardList == null)
                            wizardList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        SVMXC__ServiceMax_Processes__c wizardRec = (SVMXC__ServiceMax_Processes__c)sobjRec; 
                        addToEntityDetails(wizardRec.SVMXC__Name__c, wizardRec.Id,wizardRec.Id, wizardRec.SVMXC__IsStandard__c, wizardList, null);

                    }else if(rTypeName == 'Process Node Objects'){
                        if(processNodeList == null)
                            processNodeList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        SVMXC__ServiceMax_Processes__c processNode = (SVMXC__ServiceMax_Processes__c)sobjRec; 
                        addToEntityDetails(processNode.SVMXC__Process__r.SVMXC__Name__c, processNode.SVMXC__Process__c, processNode.SVMXC__Process__c, processNode.SVMXC__Process__r.SVMXC__IsStandard__c, processNodeList, processNode.SVMXC__Process__r.SVMXC__Purpose__c);
                      
                    }else if(rTypeName == 'Process Business Rule'){
                        SVMXC__ServiceMax_Processes__c bizRule = (SVMXC__ServiceMax_Processes__c)sobjRec;

                        if(bizRule.SVMXC__Rule_Type__c == 'Checklist_Section_Exit_Criteria'){
                            if(exitCriteriaList == null){
                                exitCriteriaList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                            }
                            addToEntityDetails(bizRule.SVMXC__Process1__r.SVMXC__Name__c, bizRule.SVMXC__Process1__c, bizRule.SVMXC__Process1__c, bizRule.SVMXC__Process1__r.SVMXC__IsStandard__c, exitCriteriaList, bizRule.SVMXC__Process1__r.SVMXC__Purpose__c);

                        }else{
                            if(processBusinessRuleList == null){
                                processBusinessRuleList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                            }
    
                            addToEntityDetails(bizRule.SVMXC__Process1__r.SVMXC__Name__c, bizRule.SVMXC__Process1__c, bizRule.SVMXC__Process1__c, bizRule.SVMXC__Process1__r.SVMXC__IsStandard__c, processBusinessRuleList, bizRule.SVMXC__Process1__r.SVMXC__Purpose__c);
                            
                        }
                        
                    }else if(rTypeName == 'SPM Details'){
                        if(sPMExpressionList == null)
                            sPMExpressionList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        SVMXC__ServiceMax_Config_Data__c spmConfig = (SVMXC__ServiceMax_Config_Data__c)sobjRec; 
                        addToEntityDetails(spmConfig.SVMXC__Dispatch_Process__r.SVMXC__Name__c, spmConfig.SVMXC__Dispatch_Process__c, spmConfig.SVMXC__Dispatch_Process__c, spmConfig.SVMXC__Dispatch_Process__r.SVMXC__IsStandard__c, sPMExpressionList, null);
                       
                    }else if(rTypeName == 'Work Order Billing Process'){
                        if(serviceProformaList == null)
                            serviceProformaList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        SVMXC__ServiceMax_Processes__c proformaProcess = (SVMXC__ServiceMax_Processes__c)sobjRec; 
                        addToEntityDetails(proformaProcess.SVMXC__Name__c, proformaProcess.Id, proformaProcess.Id, proformaProcess.SVMXC__IsStandard__c, serviceProformaList, null);
                       
                    }else if(rTypeName == 'Contract Billing Process'){
                        if(sconProformaList == null)
                            sconProformaList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        SVMXC__ServiceMax_Processes__c proformaProcess = (SVMXC__ServiceMax_Processes__c)sobjRec; 
                        addToEntityDetails(proformaProcess.SVMXC__Name__c, proformaProcess.Id, proformaProcess.Id, proformaProcess.SVMXC__IsStandard__c, sconProformaList, null);
                       
                    }else if(rTypeName == 'PM Process'){
                        if(pmProcessList == null)
                            pmProcessList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        SVMXC__ServiceMax_Processes__c pmProcess = (SVMXC__ServiceMax_Processes__c)sobjRec; 
                        addToEntityDetails(pmProcess.SVMXC__Name__c, pmProcess.Id, pmProcess.Id, pmProcess.SVMXC__IsStandard__c, pmProcessList, null);
                       
                    }else if(rTypeName == 'Mobile Configuration'){
                        if(mobileConfigList == null)
                            mobileConfigList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        
                        SVMXC__ServiceMax_Config_Data__c configRec = (SVMXC__ServiceMax_Config_Data__c)sobjRec; 
                        addToEntityDetails(configRec.SVMXC__SM_Device_Mobile_Config__r.SVMXC__SM_Name__c, configRec.SVMXC__SM_Device_Mobile_Config__c, configRec.SVMXC__SM_Device_Mobile_Config__c, false, mobileConfigList, null);
                        
                    }else if(rTypeName == 'Checklist Smart Doc'){
                        if(outputDocList == null){
                            outputDocList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();  
                        }  
                        SVMXC__ServiceMax_Processes__c opDocProcess = (SVMXC__ServiceMax_Processes__c)sobjRec;
                        addToEntityDetails(opDocProcess.SVMXC__Process1__r.SVMXC__Name__c, opDocProcess.SVMXC__Process1__c, opDocProcess.SVMXC__Process1__c, opDocProcess.SVMXC__Process1__r.SVMXC__IsStandard__c, outputDocList, null);
                    
                    }else if(rTypeName == 'Field Mapping'){
                        if(sourceObjectUpdateList == null){
                            sourceObjectUpdateList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
                        }

                        SVMXC__ServiceMax_Config_Data__c configRec = (SVMXC__ServiceMax_Config_Data__c)sobjRec;
                        addToEntityDetails(configRec.SVMXC__Dispatch_Process__r.SVMXC__Name__c, configRec.SVMXC__Dispatch_Process__c, configRec.SVMXC__Dispatch_Process__c, configRec.SVMXC__Dispatch_Process__r.SVMXC__IsStandard__c, sourceObjectUpdateList, null);

                    }

                }

                List<SFM_WrapperDef2.SFM2_Dependency> dependencyRecordsList = new List<SFM_WrapperDef2.SFM2_Dependency>();
                SFM_WrapperDef2.SFM2_Dependency dependencyRecord;
                
                if(wizardStepsList != null && !wizardStepsList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, wizardStepsList, dependency_wizardStep);
                }

                if(linkedSFMList != null && !linkedSFMList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, linkedSFMList, dependency_linkedSFM);
                }

                if(multiSrcList != null && !multiSrcList.isEmpty()){
                    String processType = dependency_multiSrcSFM;
                    
                    if(entityType == SFM_DesignerUtils.entity_layout || entityType == SFM_DesignerUtils.entity_template){
                        processType = dependency_SFM;
                    }else if(entityType == SFM_DesignerUtils.entity_question){
                        processType = dependency_Checklist;
                    }

                    createDependencyWrapper(dependencyRecordsList, multiSrcList, processType);

                }


                if(scheduleList != null && !scheduleList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, scheduleList, dependency_scheduleSFM);
                }

                System.debug(loggingLevel.DEBUG, 'wizardList ' + wizardList);
                if(wizardList != null && !wizardList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, wizardList, dependency_wizard);
                }

                System.debug(loggingLevel.DEBUG, 'processNodeList ' + processNodeList);
                if(processNodeList != null && !processNodeList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, processNodeList, dependency_SFM);
                }

                if(processBusinessRuleList != null && !processBusinessRuleList.isEmpty()){
                    String processType = entityType == SFM_DesignerUtils.entity_sectionEntryCriteria ? dependency_Checklist : dependency_SFM;
                    createDependencyWrapper(dependencyRecordsList, processBusinessRuleList, processType);
                }

                if(productIQSetupList != null && !productIQSetupList.isEmpty()){
                   createDependencyWrapper(dependencyRecordsList, productIQSetupList, dependency_IB_App);
                }

                if(sPMExpressionList != null && !sPMExpressionList.isEmpty()){
                   createDependencyWrapper(dependencyRecordsList, sPMExpressionList, dependency_SPM_Setup);
                }

                if(serviceProformaList != null && !serviceProformaList.isEmpty()){
                   createDependencyWrapper(dependencyRecordsList, serviceProformaList, dependency_Service_Proforma);
                }

                if(sconProformaList != null && !sconProformaList.isEmpty()){
                   createDependencyWrapper(dependencyRecordsList, sconProformaList, dependency_Scon_Proforma);
                }

                if(pmProcessList != null && !pmProcessList.isEmpty()){
                   createDependencyWrapper(dependencyRecordsList, pmProcessList, dependency_PM_Process);
                }

                if(mobileConfigList != null && !mobileConfigList.isEmpty()){
                   createDependencyWrapper(dependencyRecordsList, mobileConfigList, dependency_Mobile_Configuration);
                }

                if(pageLayoutList != null && !pageLayoutList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, pageLayoutList, dependency_PageLayout);
                }

                if(questionList != null && !questionList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, questionList, dependency_Question);
                }
                if(outputDocList != null && !outputDocList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, outputDocList, dependency_Output_Document);
                }

                if(sourceObjectUpdateList != null && !sourceObjectUpdateList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, sourceObjectUpdateList, dependency_Source_Object_Update);
                }

                if(exitCriteriaList != null && !exitCriteriaList.isEmpty()){
                    createDependencyWrapper(dependencyRecordsList, exitCriteriaList, dependency_Section_Exit_Criteria);
                }

                entityDependencyMap.put(processId, dependencyRecordsList);
            }

        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'getWhereUsedDetails - Exception ' + ex.getMessage());
            throw ex;
        }

        System.debug(LoggingLevel.INFO, 'getWhereUsedDetails - Exit , Response : ' + entityDependencyMap);
        return entityDependencyMap;
    }

    Static void addToEntityDetails(String entityName, String entityId, String entityPath, boolean isStandard, List<SFM_WrapperDef2.SFM2_EntityDetail> entityDetailList, String entitySubType ){
        SFM_WrapperDef2.SFM2_EntityDetail entityDetail = new SFM_WrapperDef2.SFM2_EntityDetail();
        entityDetail.entityName = entityName;
        entityDetail.entityPath = entityPath;
        entityDetail.entityId = entityId;
        entityDetail.isStandard = isStandard;        
        entityDetail.entitySubType = entitySubType;
        entityDetailList.add(entityDetail);
    }

    Static void createDependencyWrapper(List<SFM_WrapperDef2.SFM2_Dependency> dependencyRecordsList, List<SFM_WrapperDef2.SFM2_EntityDetail> entityDetails, String entityType){
        SFM_WrapperDef2.SFM2_Dependency dependencyRecord = new SFM_WrapperDef2.SFM2_Dependency();
        dependencyRecord.entityType = entityType;
        dependencyRecord.entityDetailList = removeDuplicates(entityDetails);
        dependencyRecordsList.add(dependencyRecord);
    }

    Static List<SFM_WrapperDef2.SFM2_EntityDetail> removeDuplicates(List<SFM_WrapperDef2.SFM2_EntityDetail> entityDetails){
        Set<String> uniqueIds = new Set<String>();
        List<SFM_WrapperDef2.SFM2_EntityDetail> uniqueList = new List<SFM_WrapperDef2.SFM2_EntityDetail>();
        for(SFM_WrapperDef2.SFM2_EntityDetail entityDetailRec : entityDetails){
            if(!uniqueIds.contains(entityDetailRec.entityId)){
                uniqueList.add(entityDetailRec);
            }

            uniqueIds.add(entityDetailRec.entityId);
        }

        return uniqueList;
    }

    Static void putToMap(Id key, Map<Id, List<sObject>> referenceMap, sObject processRecord){
        List<sObject> tempList = new List<sObject>();
        
        if(referenceMap.containsKey(key)){
            tempList = referenceMap.get(key);
        }

        tempList.add(processRecord);
        referenceMap.put(key, tempList);
    }
}