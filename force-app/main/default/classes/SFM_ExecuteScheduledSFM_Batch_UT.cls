@isTest(seeAllData = true)
private class SFM_ExecuteScheduledSFM_Batch_UT 
{
    static testMethod void SFM_ExecuteScheduledSFM_BatchUnitTest()
    {
        SVMXC__ServiceMax_Processes__c objSFMScheduledProcess = new SVMXC__ServiceMax_Processes__c();
        objSFMScheduledProcess.SVMXC__Name__c = 'SFM Scheduled';
        objSFMScheduledProcess.SVMXC__ProcessID__c = 'SFM_Scheduled';
        objSFMScheduledProcess.SVMXC__Description__c = 'SFM_Scheduled';
        objSFMScheduledProcess.SVMXC__Capture_Log__c = true;
        objSFMScheduledProcess.SVMXC__Dispatch_Timezone__c = 'Asia/Kolkata';
        objSFMScheduledProcess.SVMXC__Assign_To_Dispatcher__c =  UserInfo.getUserId();
        objSFMScheduledProcess.RecordTypeId = [select Id from RecordType where Name='Schedule Header'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        objSFMScheduledProcess.SVMXC__IsStandard__c = false;
        objSFMScheduledProcess.SVMXC__Active__c = true;

        insert objSFMScheduledProcess;
        
        SVMXC__ServiceMax_Config_Data__c objConfigDate = new SVMXC__ServiceMax_Config_Data__c();
        objConfigDate.SVMXC__Dispatch_Process__c = objSFMScheduledProcess.Id;
        objConfigDate.SVMXC__Expression_Rule__c = [SELECT Id, SVMXC__ProcessID__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c = 'Target Manager' AND SVMXC__Dispatch_Process_Status__c = 'Complete' AND SVMXC__ProcessID__c = 'TDM014' limit 1].Id;
        objConfigDate.RecordTypeId = [select Id from RecordType where Name='Schedule Detail'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1].Id;

        Insert objConfigDate;
        
    

        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id, Status from Case];
        for(Case objCase : lstCase)
            objCase.Status = 'Closed';
        update lstCase;
        
        Case objCase = new Case();
        objCase.Status='Open';
        Insert objCase;
        
        SFM_ExecuteScheduledSFM_Batch batchClsObj = new SFM_ExecuteScheduledSFM_Batch();
        batchClsObj.setProIds.add(objSFMScheduledProcess.Id) ;
        database.executebatch(batchClsObj,1);
    }
}