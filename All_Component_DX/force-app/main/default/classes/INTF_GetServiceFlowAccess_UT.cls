@isTest
Private  with sharing class INTF_GetServiceFlowAccess_UT {

    static testmethod void INTF_GetServiceFlowAccess_UnitTest()
    {
        String strPurpose = '';
        RecordType RT = [select Id from RecordType where Name=:'Service Flow Access'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        allObjs = Schema.getGlobalDescribe();
        
        
        SVMXC__ServiceMax_Config_Data__c conf1 = new SVMXC__ServiceMax_Config_Data__c();
        insert conf1;
        
        SVMXC__ServiceMax_Config_Data__c conf = new SVMXC__ServiceMax_Config_Data__c();
        conf.SVMXC__Access_Configuration_Profile__c = conf1.Id;
        conf.RecordTypeId = RT.Id;
        insert conf;
        
        INTF_GetServiceFlowAccess Obj = new INTF_GetServiceFlowAccess();
        INTF_GetServiceFlowAccess Obj1 = new INTF_GetServiceFlowAccess( allObjs);
        Obj.getAllowedProcesses(strPurpose);
        
        Obj.INTF_getAllAllowedProcessed(null);
        Obj.getAllowedProcesses('STANDALONE CREATE');
        Obj.getAllowedProcesses('STANDALONE CREATE',null);
        
        Sync_Utility clsUtility = new Sync_Utility();
        Map<Id, SVMXC__ServiceMax_Processes__c> processAccess = clsUtility.getSFMTransactions(null);
        Obj.INTF_GetProcessObjects(processAccess);
    }

}