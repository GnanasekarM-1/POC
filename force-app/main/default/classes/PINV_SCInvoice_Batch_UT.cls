@isTest(seeAllData = true)
private class PINV_SCInvoice_Batch_UT 
{
    static string createTestData()
    {
        RecordType SCBilProcess_Rtype = [select Id from RecordType where Name='Contract Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c svmxSCBilProcess = new SVMXC__ServiceMax_Processes__c();
        svmxSCBilProcess.SVMXC__Name__c = 'SCBillingEngineUT0001';
        svmxSCBilProcess.SVMXC__ProcessID__c = 'SCBillingEngineUT0001';
        svmxSCBilProcess.RecordTypeId = SCBilProcess_Rtype.Id;
        svmxSCBilProcess.SVMXC__Email_On_Error__c = 'moshe.s@servicemax.com';
        svmxSCBilProcess.SVMXC__Email_On_Success__c = 'moshe.s@servicemax.com';
        svmxSCBilProcess.SVMXC__Capture_Log__c = true;
        svmxSCBilProcess.SVMXC__Primary_Consolidation_Rule__c = 'Contract';
        insert svmxSCBilProcess;
        
        return svmxSCBilProcess.Id;
    }
    
    static testMethod void PINV_SCInvoice_BatchUnitTest()
    {
        string procId = createTestData();
                
        PINV_SCInvoice_Batch batchClsObj = new PINV_SCInvoice_Batch();
        batchClsObj.setProIds.add(procId);
        database.executebatch(batchClsObj,1);
    }
}