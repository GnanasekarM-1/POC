@isTest
private class SFM_ScheduledBatchUtils_UT{
    static testMethod void invalidClassInstance_Test(){
        SFM_ScheduledBatchUtils objSFM_CounterReadingManager = SVMXC.SFM_ScheduledBatchUtils.getInstance();
        SFM_ScheduledBatchUtils.getInstance('','ABCDEF');
    }
    
    static testMethod void subscribeClassClassInstance_Test(){
        SFM_ScheduledBatchUtils objSFM_CounterReadingManager = SVMXC.SFM_ScheduledBatchUtils.getInstance();
        SFM_ScheduledBatchUtils.getInstance('','APL_Entitlement');
        
    }
    
    static testMethod void validClassInstance_Test(){
        SFM_ScheduledBatchUtils objSFM_CounterReadingManager = SVMXC.SFM_ScheduledBatchUtils.getInstance();
        SFM_ScheduledBatchUtils.getInstance('','IPRD_CreateInitialCounterReading');
    }
}