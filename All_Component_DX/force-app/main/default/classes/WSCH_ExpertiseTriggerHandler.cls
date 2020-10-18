public with sharing class WSCH_ExpertiseTriggerHandler {

    public static void handleExpertiseInsert(List<Service_Group_Skills__c> lstOfexpertise) {
        WSCH_AuditLogger.debug('WSCH_ExpertiseTriggerHandler:handleExpertiseInsert():start');
        try {
            //from the list of expertise , get all the technician Ids and query these technicians.
            Set<String> setOfTechIds = new Set<String>();
            for(Service_Group_Skills__c eachExpertise:lstOfexpertise) {
                if(eachExpertise.SVMXC__Is_Applicable__c.equalsIgnoreCase('TRUE')) {
                    setOfTechIds.add(eachExpertise.SVMXC__Group_Member__c);
                }
            }

            //for these each of the tech get the corresponding optimizer transaction and make manageTechnicians call.
            list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting = getTechOptimizers(setOfTechIds);
            WSCH_AuditLogger.debug('WSCH_ExpertiseTriggerHandler:handleExpertiseInsert():lstSVMXOptimizerToExisting.size(): ' + lstSVMXOptimizerToExisting.size());
            if(lstSVMXOptimizerToExisting.size() > 0) {
                List<String> lstOfOptTransIds = new List<String>();
                for(SVMXC__SVMX_Optimizer__c eachOptRecord:lstSVMXOptimizerToExisting) {
                    eachOptRecord.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE_TECH';
                    eachOptRecord.SVMXC__Optimizer_Status__c = WSCH_ECO_Constants.STATUS_OPT_PENDING;
                    lstOfOptTransIds.add(eachOptRecord.Id);
                }
                //save the optimizer transaction records as token and status is updated above.
                Database.update(lstSVMXOptimizerToExisting);
                //now make a future call
                WSCH_TechnicianTriggerHandler.manageTechnicians(lstOfOptTransIds);
            }
            WSCH_AuditLogger.finish();
        } catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_ExpertiseTriggerHandler::handleExpertiseInsert():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }

    public static void handleExpertiseUpdate(List<Service_Group_Skills__c> newExpertiseLst, List<Service_Group_Skills__c> oldExpertiseLst) {
        WSCH_AuditLogger.debug('WSCH_ExpertiseTriggerHandler:handleExpertiseUpdate():start');
        try {
            List<Service_Group_Skills__c> lstOfQualifiedExpertise = new List<Service_Group_Skills__c>();
            Boolean isQualifyAndMark = true;
            for(Integer i = 0; i < newExpertiseLst.size(); i++) {
                Service_Group_Skills__c newExpertiseObj = newExpertiseLst.get(i);
                Service_Group_Skills__c oldExpertiseObj = oldExpertiseLst.get(i);

                //allow callout for all changes except for service team
                if(newExpertiseObj.SVMXC__Service_Group__c != oldExpertiseObj.SVMXC__Service_Group__c) {
                    isQualifyAndMark = false; // do not qualify this change
                }
                //if there is a valid change in the expertise data add it to a qualified listOfExpertise
                if(isQualifyAndMark) {
                    lstOfQualifiedExpertise.add(newExpertiseObj);
                }
            }
            WSCH_AuditLogger.debug('WSCH_ExpertiseTriggerHandler:handleExpertiseUpdate():isQualifyAndMark - ' + isQualifyAndMark);
            
            //from the list of expertise , get all the technician Ids and query these technicians.
            Set<String> setOfTechIds = new Set<String>();
            for(Service_Group_Skills__c eachExpertise:lstOfQualifiedExpertise) {
                setOfTechIds.add(eachExpertise.SVMXC__Group_Member__c);
            }
            //for these each of the tech get the corresponding optimizer transaction and make manageTechnicians call.
            list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting = getTechOptimizers(setOfTechIds);
            WSCH_AuditLogger.debug('WSCH_ExpertiseTriggerHandler:handleExpertiseUpdate():lstSVMXOptimizerToExisting.size(): ' + lstSVMXOptimizerToExisting.size());
            if(lstSVMXOptimizerToExisting.size() > 0) {
                List<String> lstOfOptTransIds = new List<String>();
                for(SVMXC__SVMX_Optimizer__c eachOptRecord:lstSVMXOptimizerToExisting) {
                    eachOptRecord.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE_TECH';
                    eachOptRecord.SVMXC__Optimizer_Status__c = WSCH_ECO_Constants.STATUS_OPT_PENDING;
                    lstOfOptTransIds.add(eachOptRecord.Id);
                }
                //save the optimizer transaction records as token and status is updated above.
                Database.update(lstSVMXOptimizerToExisting);
                //now make a future call
                WSCH_TechnicianTriggerHandler.manageTechnicians(lstOfOptTransIds);
            }
            WSCH_AuditLogger.finish();
        } catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_ExpertiseTriggerHandler::handleExpertiseUpdate():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }

    public static void handleExpertiseDelete(List<Service_Group_Skills__c> lstExpertiseDel) {
        WSCH_AuditLogger.debug('WSCH_ExpertiseTriggerHandler:handleExpertiseDelete():start');
        try {
            //from the list of expertise , get all the technician Ids and query these technicians.
            Set<String> setOfTechIds = new Set<String>();
            for(Service_Group_Skills__c eachExpertise:lstExpertiseDel) {
                setOfTechIds.add(eachExpertise.SVMXC__Group_Member__c);
            }

            //for these each of the tech get the corresponding optimizer transaction and make manageTechnicians call.
            list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting = getTechOptimizers(setOfTechIds);
            WSCH_AuditLogger.debug('WSCH_ExpertiseTriggerHandler:handleExpertiseDelete():lstSVMXOptimizerToExisting.size(): ' + lstSVMXOptimizerToExisting.size());
            if(lstSVMXOptimizerToExisting.size() > 0) {
                List<String> lstOfOptTransIds = new List<String>();
                for(SVMXC__SVMX_Optimizer__c eachOptRecord:lstSVMXOptimizerToExisting) {
                    eachOptRecord.SVMXC__Optimizer_Change_Token__c = 'CHANGE_UPDATE_TECH';
                    eachOptRecord.SVMXC__Optimizer_Status__c = WSCH_ECO_Constants.STATUS_OPT_PENDING;
                    lstOfOptTransIds.add(eachOptRecord.Id);
                }
                //save the optimizer transaction records as token and status is updated above.
                Database.update(lstSVMXOptimizerToExisting);
                //now make a future call
                WSCH_TechnicianTriggerHandler.manageTechnicians(lstOfOptTransIds);
            }
            WSCH_AuditLogger.finish();
        } catch(Exception ex) {
            WSCH_AuditLogger.error('WSCH_ExpertiseTriggerHandler::handleExpertiseDelete():Exception occured..'+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    }

    public static list<SVMXC__SVMX_Optimizer__c> getTechOptimizers(Set<String> setOfTechIds) {
        WSCH_AuditLogger.debug('WSCH_ExpertiseTriggerHandler:getTechOptimizers():start');
        List<SVMXC__Service_Group_Members__c> lstTechnicians = [Select Name, Id From SVMXC__Service_Group_Members__c WHERE SVMXC__Service_Territory__c != null AND SVMXC__Active__c = true AND Id IN :setOfTechIds];
        list<String> lstTechID= new list<String> ();           
        list<SVMXC__SVMX_Optimizer__c> lstSVMXOptimizerToExisting = new list<SVMXC__SVMX_Optimizer__c> ();
        
        for(SVMXC__Service_Group_Members__c objTech : lstTechnicians){
            lstTechID.add(objTech.id+'_'+objTech.Name);
         }
        lstSVMXOptimizerToExisting = [Select id, SVMXC__Optimizer_Change_Token__c,SVMXC__WhatId__c,SVMXC__Optimizer_Connection_ID__c,SVMXC__Optimizer_Status__c,SVMXC__Optimizer_Error_Text__c  from SVMXC__SVMX_Optimizer__c  where SVMXC__WhatId__c in: lstTechID];
        
        return lstSVMXOptimizerToExisting;
    }

}