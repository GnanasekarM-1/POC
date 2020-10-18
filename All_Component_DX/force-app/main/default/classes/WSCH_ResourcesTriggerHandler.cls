public WITH SHARING class WSCH_ResourcesTriggerHandler {
    public static void reBookJob(Set<Id> setWoIds){
        WSCH_AuditLogger.debug('Work_Order_Resource_Trigger1 REBOOK JOB: ' + setWoIds);
        String strGBL007 = WSCH_CommonUtils.getSettingValue('GLOB001', 'GBL007');
        List<SVMXC__Service_Order__c> lstReBookWOs = new List<SVMXC__Service_Order__c>();
        try{
            Boolean boolGBL007 = Boolean.valueOf(strGBL007.trim());
            if(!boolGBL007){
                WSCH_AuditLogger.debug('WSCH_ResourcesTriggerHandler::reBookJob: GBL007 is  TURNED OFF');
                return;
            }
            WSCH_OptimizedSchedulingService.triggerExecuted = true;
            String strTrigQuery = 'SELECT ' +  WORD_Service_Order_Resources.fetchQueryFields('SVMXC__Service_Order__c' ,false)
                + ' FROM SVMXC__Service_Order__c ' 
                + ' WHERE Id IN :setWoIds';
            WSCH_AuditLogger.debug('WSCH_ResourcesTriggerHandler::reBookJob: Query: ' + strTrigQuery);
            List<Id> lstWoId = new List<Id>(setWoIds);
            lstReBookWOs = WSCH_CommonUtils.fetchWorkOrders(lstWoId);
            for(SVMXC__Service_Order__c wrkOrder: lstReBookWOs){
                wrkOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_RESOURCE_PREFERENCE';
                wrkOrder.SVMXC__OptiMax_Status__c = WSCH_Constants.STATUS_OPT_PENDING;
                wrkOrder.SVMXC__Scheduling_Retry_Count__c = 0;
            }
            WSCH_TriggerHandler.identifyAPIAndOptimize(lstReBookWOs,lstReBookWOs);
        }catch(exception ex){
            String exceptionMsg = 'ServiceOrderResourceTriggerHandler :: WSCH_RebookJob ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            WSCH_AuditLogger.finish();
        }
    
    }
    public static List<Work_Order_Resource__c> getAllWORes(Set<Id> setTechIds){
        String strTrigQuery = '';
        List<Work_Order_Resource__c> lstReturnTech = new List<Work_Order_Resource__c>();
        try{
            //if(WORD_Work_Order_Resources.getResourcePreferenceSetting()){
                strTrigQuery = 'SELECT ' + WORD_Service_Order_Resources.fetchQueryFields('SVMXC__Work_Order_Resource__c' ,true)
                                        + ' FROM Work_Order_Resource__c ' 
                                        + ' WHERE SVMXC__Group_Member__c IN :setTechIds';
                WSCH_AuditLogger.debug('Work_Order_Resource_Trigger1 Query: ' + strTrigQuery);
                lstReturnTech = Database.query(strTrigQuery);
            //}
        }catch(exception ex){
            String exceptionMsg = 'WSCH_ResourcesTriggerHandler :: getAllWORes ';
            WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
        }
        return lstReturnTech;
    
    }
    public static void checkWOResList (List<Work_Order_Resource__c> lstAllTechRes, List<Work_Order_Resource__c> lstNewWORes, String triggerMode){
        if(triggerMode == 'beforeInsert'){
            try{
                for (Integer i=0; i<lstNewWORes.size();i++){
                    for (Integer j=0; j<lstNewWORes.size();j++){
                        if(i!=j){
                            if((lstNewWORes[i].SVMXC__Work_Order__c != null) && (lstNewWORes[j].SVMXC__Work_Order__c != null) && (lstNewWORes[i].SVMXC__Work_Order__c == lstNewWORes[j].SVMXC__Work_Order__c) && (lstNewWORes[i].SVMXC__Group_Member__c == lstNewWORes[j].SVMXC__Group_Member__c)){                     
                                lstNewWORes[i].SVMXC__Work_Order__c.addError(Label.DCON003_TAG080);
                            }
                        }
                    }
                }
                for(Work_Order_Resource__c woRes: lstAllTechRes ){
                    for(Work_Order_Resource__c newRes: lstNewWORes){
                        if((newRes.SVMXC__Work_Order__c == woRes.SVMXC__Work_Order__c) && (newRes.SVMXC__Work_Order__c != null) && (woRes.SVMXC__Work_Order__c != null) && (newRes.SVMXC__Group_Member__c == woRes.SVMXC__Group_Member__c )){
                            //This Work Order already has the same technician association.
                            newRes.SVMXC__Work_Order__c.addError(Label.DCON003_TAG079 );
                        }
                    }
                }
            
            }catch(exception ex){
                String exceptionMsg = 'WSCH_ResourcesTriggerHandler :: checkInsertWOResList ';
                WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }
        }
        if(triggerMode == 'beforeUpdate'){
            Boolean boolAddError;
            try{
                for(Work_Order_Resource__c woRes: lstAllTechRes ){
                    for(Work_Order_Resource__c newRes: lstNewWORes){
                        boolAddError = false;
                        if((newRes.SVMXC__Work_Order__c != null) && (woRes.SVMXC__Work_Order__c != null) && (newRes.SVMXC__Work_Order__c == woRes.SVMXC__Work_Order__c) && (newRes.SVMXC__Group_Member__c == woRes.SVMXC__Group_Member__c )){
                            boolAddError = true;
                            if(woRes.Id == newRes.Id){
                                boolAddError = false;
                            }
                            //This Work Order already has the same technician association.
                            //newRes.SVMXC__Service_Order__c.addError(Label.DCON003_TAG079 );
                        }
                        if(boolAddError){
                            newRes.SVMXC__Group_Member__c.addError(Label.DCON003_TAG079);
                        }
                    }
                }           
            }catch(exception ex){
                String exceptionMsg = 'WSCH_ResourcesTriggerHandler :: checkUpdateWOResList ';
                WSCH_AuditLogger.error(exceptionMsg+ex.getMessage() + '\n Stack Trace:: ' + ex.getStackTraceString());
            }    
        }
    }
}