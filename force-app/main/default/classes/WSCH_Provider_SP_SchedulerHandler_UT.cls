@isTest
private class WSCH_Provider_SP_SchedulerHandler_UT {

    public WSCH_Provider_SP_SchedulerHandler_UT() {
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('DCON004_SET006')];
        for(SVMXC__ServiceMax_Config_Data__c confObj : lst){
                confObj.SVMXC__Display_Value__c = 'true';
                confObj.SVMXC__Internal_Value__c = 'true';
                confObj.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        }
        if(lst != null && lst.size() > 0)
        update lst; 
    }
    
    static{
        WSCH_Provider_SP_SchedulerHandler_UT schedulerUT = new WSCH_Provider_SP_SchedulerHandler_UT();
    }
    
    static testMethod void schedulerHandlerExecuteUT() {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        WSCH_Provider_SP_SchedulerHandler handler = new WSCH_Provider_SP_SchedulerHandler();
        Schedulablecontext sc;
        List<String> optimizerIds = new List<String>();
        SVMXC__SVMX_Optimizer__c optimizerObj = new SVMXC__SVMX_Optimizer__c();
        optimizerObj.SVMXC__Optimizer_Status__c='OPT_COMPLETED';
        insert optimizerObj;
        optimizerIds.add(optimizerObj.id);
        handler.execute(sc);
        optimizerObj.SVMXC__Optimizer_Status__c = 'OPT_ERROR';
        optimizerObj.SVMXC__WhatType__c = 'NON_WO_EVENT';
        optimizerObj.SVMXC__Optimizer_Retry_Count__c = 2;
        update optimizerObj;
        handler.execute(sc);
        optimizerObj.SVMXC__WhatType__c = 'WORK_ORDER';
        optimizerObj.SVMXC__Optimizer_Retry_Count__c = 2;
        update optimizerObj;
        handler.execute(sc);
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75001';
        workOrder1.SVMXC__Order_Status__c = 'Open';
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__OptiMax_Status__c = 'OPT_ERROR';
        workOrder1.SVMXC__Scheduling_Retry_Count__c = 2;
        insert workOrder1;
        handler.execute(sc);
        Test.stopTest();
    }
    
    static testMethod void retryFailedOptimizerUT() {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        List<String> optimizerIds = new List<String>();
        SVMXC__SVMX_Optimizer__c optimizerObj = new SVMXC__SVMX_Optimizer__c();
        optimizerObj.SVMXC__Optimizer_Status__c='OPT_COMPLETED';
        insert optimizerObj;
        optimizerIds.add(optimizerObj.id);

        WSCH_Provider_SP_SchedulerHandler.retryCancelWorkOrders(optimizerIds);
        WSCH_Provider_SP_SchedulerHandler.retryFailedOptimizers(optimizerIds);
        Test.stopTest();
    }
    
}