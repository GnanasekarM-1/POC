public with sharing class WSCH_BA_CommonUtils {

    public static boolean canExecuteBatchApex() {
       /* Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};
        List<AsyncApexJob> apexjobs = [Select ID, ApexClass.Name from AsyncApexJob where Status in :activejobstates];
        if(apexjobs.size() == 5) {
            WSCH_AuditLogger.debug('WSCH_BA_CommonUtils::canExecuteBatchApex()::apexjobs.size() '+apexjobs.size());
            return false;  // The batch queue is full
        }*/
        
        Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};
        //Check the current usage of batch apex job
        List<AsyncApexJob> batchApexjobs = [Select ID, ApexClass.Name from AsyncApexJob where JobType='BatchApex' AND Status in :activejobstates];
        if(batchApexjobs.size() >= WSCH_Constants.INT_MAX_BATCH_JOBS) {
            WSCH_AuditLogger.debug('WSCH_BA_CommonUtils::canExecuteBatchApex()::batchApexjobs.size() '+batchApexjobs.size());
            return false;
        }
        //Check the current usage for scheduled apex jobs
        List<AsyncApexJob> scheduledApexjobs = [Select ID, ApexClass.Name from AsyncApexJob where JobType='ScheduledApex' AND Status in :activejobstates];
        if(scheduledApexjobs .size() >= WSCH_Constants.INT_MAX_SCHEDULED_JOBS) {
            WSCH_AuditLogger.debug('WSCH_BA_CommonUtils::canExecuteBatchApex()::scheduledApexjobs.size() '+scheduledApexjobs.size());
            return false;
        }        
        
        return true;
    }
}