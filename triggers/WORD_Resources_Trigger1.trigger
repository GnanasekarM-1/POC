trigger WORD_Resources_Trigger1 on Work_Order_Resource__c (before insert, before update, after insert, after update, after delete) {

    try{
        List<Work_Order_Resource__c> lstNewWORes = new List<Work_Order_Resource__c>();
        List<Work_Order_Resource__c> lstAllTechRes = new List<Work_Order_Resource__c>();
        Set<Id> setTechIds =  new Set<Id>();
        Set<Id> setWoIds =  new Set<Id>();
        
        if (Trigger.isDelete){
            //collect the WorkOrder Ids whose ResourcePreferece were deleted.
            for(Work_Order_Resource__c res: Trigger.old){
                // Make sure we don't treat a record that doesn't have a Technician.
                if(res.SVMXC__Group_Member__c != null){
                    setWoIds.add(res.SVMXC__Work_Order__c);
                }
            }
        }else{
            //collect the WorkOrder Ids, Technician Ids whose ResourcePreferece were updated or newly inserted.
            for(Work_Order_Resource__c res: Trigger.new){
                // Make sure we don't treat a record that doesn't have a Technician.
                if(res.SVMXC__Group_Member__c != null){
                    lstNewWORes.add(res);
                    setTechIds.add(res.SVMXC__Group_Member__c);
                    setWoIds.add(res.SVMXC__Work_Order__c);
                }
            }
        }
        if(Trigger.isBefore){
            lstAllTechRes = WSCH_ResourcesTriggerHandler.getAllWORes(setTechIds);
            if(Trigger.isInsert){
                //Invoke the Before Insert Logic
                WSCH_AuditLogger.debug('INSIDE WORD_Resources_Trigger1: BEFORE INSERT');
                //WSCH_ResourcesTriggerHandler.checkInsertWOResList(lstAllTechRes,lstNewWORes);
                WSCH_ResourcesTriggerHandler.checkWOResList(lstAllTechRes,lstNewWORes, 'beforeInsert');
            }
            if(Trigger.isUpdate){
                //Invoke the Before Update Logic
                WSCH_AuditLogger.debug('INSIDE WORD_Resources_Trigger1: BEFORE UPDATE');
                //WSCH_ResourcesTriggerHandler.checkUpdateWOResList(lstAllTechRes,lstNewWORes, Trigger.oldMap, Trigger.newMap);
                WSCH_ResourcesTriggerHandler.checkWOResList(lstAllTechRes,lstNewWORes, 'beforeUpdate');
            }
        }
        //Invoke Re-Book Job
        if(Trigger.isAfter){
            WSCH_AuditLogger.debug('INSIDE WORD_Resources_Trigger1: AFTER INSERT/UPDATE/DELETE');
            WSCH_AuditLogger.debug('WORD_Service_Order_Resources.isWordTriggerExecuted: ' + WORD_Service_Order_Resources.isWordTriggerExecuted);
            WSCH_AuditLogger.debug('setWoIds() ' + setWoIds);
                if(!WORD_Service_Order_Resources.isWordTriggerExecuted){
                    if(!setWoIds.isEmpty()){
                        WSCH_ResourcesTriggerHandler.reBookJob(setWoIds);
                    }
                }
        }
    }catch(exception ex){
        String exceptionMsg = 'WORD_Resources_Trigger1 :: ';
        WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        WSCH_AuditLogger.finish();
    }
    finally{
        WSCH_AuditLogger.finish();
    }
}