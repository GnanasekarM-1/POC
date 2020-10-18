@isTest
private class CONF_ManageScheduledSFM_UT 
{
    static testMethod void CONF_ManageScheduledSFMTest() 
    {
        CONF_ManageScheduledSFM obj = new CONF_ManageScheduledSFM();
        PageReference objPageReference;
        obj.setIsCustomButtonEnabled(true);
        obj.getIsCustomButtonEnabled();
        
        SVMXC__ServiceMax_Processes__c objProcess1 = new SVMXC__ServiceMax_Processes__c();
        objProcess1.SVMXC__ProcessId__c = 'testProcess1';
        objProcess1.SVMXC__Name__c = 'testProcess1';        
        objProcess1.SVMXC__Description__c = 'TestDescription1';
        objProcess1.SVMXC__IsStandard__c = false;
        objProcess1.SVMXC__Active__c = true;
        objProcess1.SVMXC__Select__c = false;
        objProcess1.RecordTypeId = [select Id from RecordType where Name='Schedule Header'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        insert objProcess1;
        System.assert(objProcess1.id != null);
        
        CONF_ManageScheduledSFM obj1 = new CONF_ManageScheduledSFM();
        obj1.strActionType = 'SetupHome';
        objPageReference = obj1.backToSetupHomeAndNewProcess();
        System.assert(objPageReference != null);
        obj1.strActionType = 'New';
        objPageReference = obj1.backToSetupHomeAndNewProcess();
        System.assert(objPageReference != null);
        
        objPageReference = obj1.runCustomProcess();
        System.assert(objPageReference == null);
        objPageReference = obj1.cloneCustomScheduledSFMProcess();
        System.assert(objPageReference == null);
        objPageReference = obj1.editCustomScheduledSFMProcess();
        System.assert(objPageReference == null);
        objPageReference = obj1.deleteCustomScheduledSFMProcess();
        System.assert(objPageReference == null);

        SVMXC__ServiceMax_Processes__c objProcess2 = new SVMXC__ServiceMax_Processes__c();
        objProcess2.SVMXC__ProcessId__c = 'testProcess2';
        objProcess2.SVMXC__Name__c = 'testProcess2';
        objProcess2.SVMXC__Description__c = 'TestDescription2';
        objProcess2.SVMXC__IsStandard__c = false;
        objProcess2.SVMXC__Active__c = true;
        objProcess2.SVMXC__Select__c = true;
        objProcess2.RecordTypeId = [select Id from RecordType where Name='Schedule Header'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        insert objProcess2;
        System.assert(objProcess2.id != null);
        
        obj1 = new CONF_ManageScheduledSFM();
        obj1.lstCustomProcess[0].SVMXC__Select__c = true;
        objPageReference = obj1.runCustomProcess();
        System.assert(objPageReference == null);
        objPageReference = obj1.cloneCustomScheduledSFMProcess();   
        System.assert(objPageReference == null);
        objPageReference = obj1.editCustomScheduledSFMProcess();
        System.assert(objPageReference == null);
        objPageReference = obj1.deleteCustomScheduledSFMProcess();
        System.assert(objPageReference == null);
        
        SVMXC__ServiceMax_Processes__c objProcess3 = new SVMXC__ServiceMax_Processes__c();
        objProcess3.SVMXC__ProcessId__c = 'testProcess3';
        objProcess3.SVMXC__Name__c = 'testProcess3';
        objProcess3.SVMXC__Description__c = 'TestDescription3';
        objProcess3.SVMXC__IsStandard__c = false;
        objProcess3.SVMXC__Active__c = true;
        objProcess3.SVMXC__Select__c = true;
        objProcess3.RecordTypeId = [select Id from RecordType where Name='Schedule Header'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        insert objProcess3;
    System.assert(objProcess3.id != null);
        
        SVMXC__ServiceMax_Config_Data__c objProcessConfData = new SVMXC__ServiceMax_Config_Data__c();
        objProcessConfData.SVMXC__Dispatch_Process__c = objProcess3.id;
        objProcessConfData.RecordTypeId = [select Id from RecordType where Name='Schedule Detail'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1].Id;
        insert objProcessConfData;
        System.assert(objProcessConfData.id != null);
        
        obj1 = new CONF_ManageScheduledSFM();
        obj1.lstCustomProcess[0].SVMXC__Select__c = false;
        obj1.lstCustomProcess[1].SVMXC__Select__c = false;
        objPageReference = obj1.runCustomProcess();
        System.assert(objPageReference == null);
        objPageReference = obj1.cloneCustomScheduledSFMProcess();
        System.assert(objPageReference != null);
        objPageReference = obj1.editCustomScheduledSFMProcess();
        System.assert(objPageReference != null);
        objPageReference = obj1.deleteCustomScheduledSFMProcess();
        System.assert(objPageReference == null);
    }
}