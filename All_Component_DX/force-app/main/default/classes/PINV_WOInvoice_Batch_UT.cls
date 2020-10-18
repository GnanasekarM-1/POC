@isTest(seeAllData = true)
private class PINV_WOInvoice_Batch_UT 
{
    static string createTestData()
    {
        RecordType WOBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c svmxWOBilProcess = new SVMXC__ServiceMax_Processes__c();
        svmxWOBilProcess.SVMXC__Name__c = 'WOBillingEngineUT0001';
        svmxWOBilProcess.SVMXC__ProcessID__c = 'WOBillingEngineUT0001';
        svmxWOBilProcess.RecordTypeId = WOBilProcess_Rtype.Id;
        svmxWOBilProcess.SVMXC__Email_On_Error__c = 'naveen.vasu@servicemax.com';
        svmxWOBilProcess.SVMXC__Email_On_Success__c = 'naveen.vasu@servicemax.com';
        svmxWOBilProcess.SVMXC__Capture_Log__c = true;
        svmxWOBilProcess.SVMXC__Primary_Consolidation_Rule__c = 'Work Order';
        insert svmxWOBilProcess;
        
        return svmxWOBilProcess.Id;
    }
    
    static testMethod void PINV_WOInvoice_BatchUnitTest()
    {
        string procId = createTestData();
                
        PINV_WOInvoice_Batch batchClsObj = new PINV_WOInvoice_Batch();
        batchClsObj.setProIds.add(procId);
        database.executebatch(batchClsObj,1);
    }
}