@isTest
private class SFM_TriggerBaseManager_UT{
    static testMethod void createSFMTrigger_Test(){
        SVMXC.SFM_TriggerBaseManager objSFM_TriggerBaseManager = SVMXC.SFM_TriggerBaseManager.getInstance();
        objSFM_TriggerBaseManager.createSFMTrigger('ABCDEF');
        objSFM_TriggerBaseManager.createSFMTrigger('APL_Entitlement');
        objSFM_TriggerBaseManager.createSFMTrigger('SFM_InvtUpdOnWorkOrderClosure');
    }
}