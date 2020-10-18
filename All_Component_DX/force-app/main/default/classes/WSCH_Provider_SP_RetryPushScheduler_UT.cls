@isTest
public with sharing class WSCH_Provider_SP_RetryPushScheduler_UT {
    
    public WSCH_Provider_SP_RetryPushScheduler_UT() {
        //test.startTest();
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('DCON004_SET007')];
        for(SVMXC__ServiceMax_Config_Data__c confObj : lst){
                confObj.SVMXC__Display_Value__c = 'true';
                confObj.SVMXC__Internal_Value__c = 'true';
                confObj.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        }
        if(lst != null && lst.size() > 0)
        update lst;
        //test.stopTest();
    }
    
    static{
        WSCH_Provider_SP_RetryPushScheduler_UT retrySchedulerUT = new WSCH_Provider_SP_RetryPushScheduler_UT();
    }
    
    static testMethod void pushRetrySchedulerHandlerExecuteUT() {
        
        test.startTest();
        
        WSCH_Provider_SP_RetryPushScheduler pushRetryHandler = new WSCH_Provider_SP_RetryPushScheduler();
        
        pushRetryHandler.startRetryPushScheduler();
        
        test.stopTest();
    }
    
}