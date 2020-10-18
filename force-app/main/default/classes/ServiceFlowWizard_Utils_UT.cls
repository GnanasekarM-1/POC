@isTest(SeeAllData=true)
private class ServiceFlowWizard_Utils_UT 
{
    static testMethod void SFW_UtilsUnitTest() 
    {
        // System Assert
         Account testAccount = new Account(name='Test Company Name');
         insert testAccount;
         testAccount.billingState='CA';
         update testAccount;
         // Verify that the billingState field was updated in the database.
         Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
         System.assertEquals('CA', updatedAccount.billingState);
        
        
        String RTypeId = '';
        RecordType Rtype;
        
        String RTypeId1 = '';
        RecordType Rtype1;
        
        String RTypeId2 = '';
        RecordType Rtype2;
        
        Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Inventory Process' Limit 1];
        RTypeId = Rtype.Id;
        
        Rtype1 = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Wizard' Limit 1];
        RTypeId1 = Rtype1.Id;
        
        Rtype2 = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Process Node Objects' Limit 1];
        RTypeId2 = Rtype2.Id;
        
        SVMXC__ServiceMax_Processes__c proces = new SVMXC__ServiceMax_Processes__c();
        proces.SVMXC__Name__c = 'process001';
        proces.RecordTypeId = RTypeId;
        proces.SVMXC__ProcessID__c = 'process12345';
        insert proces;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'process123';
        process.SVMXC__Module__c = proces.id;
        process.SVMXC__Description__c = 'process123';
        process.SVMXC__ProcessID__c = 'process123';
        process.SVMXC__Submodule__c = proces.id;
        process.SVMXC__IsStandard__c = true;
        process.RecordTypeId = RTypeId;
        insert process;
        system.assert(process.SVMXC__Name__c!=null);
        system.assert(process.SVMXC__Description__c!=null);
        
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__Name__c = 'process12345';
        process1.SVMXC__Select__c = true;
        process1.SVMXC__Description__c = 'process12345';
        process1.SVMXC__ProcessID__c = 'process12345';
        process1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process1.SVMXC__IsStandard__c = true;
        process1.RecordTypeId = RTypeId1;
        insert process1;
        system.assert(process1.SVMXC__Name__c!=null);
        system.assert(process1.SVMXC__Description__c!=null);
        
        SVMXC__ServiceMax_Processes__c process2 = new SVMXC__ServiceMax_Processes__c();
        process2.SVMXC__Name__c = 'process12345';
        process2.SVMXC__Select__c = true;
        process2.SVMXC__Description__c = 'process12345';
        process2.SVMXC__ProcessID__c = 'process12345';
        process2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process2.SVMXC__IsStandard__c = true;
        process2.SVMXC__Submodule__c = proces.id;
        process2.SVMXC__Process__c = process.id;
        process2.SVMXC__Type__c = 'TARGET';
        process2.RecordTypeId = RTypeId2;
        insert process2;
        system.assert(process2.SVMXC__Name__c!=null);
        system.assert(process2.SVMXC__Description__c!=null);
        
        SVMXC__ServiceMax_Processes__c process3 = new SVMXC__ServiceMax_Processes__c();
        process3.SVMXC__Name__c = 'process12345';
        process3.SVMXC__Select__c = true;
        process3.SVMXC__Description__c = 'process12345';
        process3.SVMXC__ProcessID__c = 'process12345';
        process3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process3.SVMXC__IsStandard__c = true;
        process3.SVMXC__Action_Type__c = 'INVENTORY';
        process3.SVMXC__Submodule__c = proces.id;
        process3.SVMXC__Process__c = process.id;
        process3.SVMXC__Type__c = 'TARGET';
        process3.RecordTypeId = RTypeId2;
        insert process3;
        system.assert(process3.SVMXC__Name__c!=null);
        system.assert(process3.SVMXC__Description__c!=null);
        
        ServiceFlowWizard_Utils SFWUtil = new ServiceFlowWizard_Utils();
        String ObjName = 'SVMXC__Service_Order__c';
        Map<String,List<SVMXC__ServiceMax_Processes__c>> map1 = SFWUtil.SVMX_GetInventoryActions(ObjName);
        Map<String,List<SVMXC__ServiceMax_Processes__c>> map2 = SFWUtil.SVMX_GetSFMActions(ObjName);
        Map<String,List<SVMXC__ServiceMax_Processes__c>> map3 = SFWUtil.SVMX_GetOtherActions(ObjName);
        Map<String,List<SVMXC__ServiceMax_Processes__c>> map4 = SFWUtil.SVMX_GetObjNamesNsfwRecs(ObjName);
        Map<String,List<SVMXC__ServiceMax_Processes__c>> map5 = SFWUtil.SVMX_GetReceive_DeliveryActions(ObjName);
        Map<String,List<SVMXC__ServiceMax_Processes__c>> map6 = SFWUtil.SVMX_GetPicking_ShippingActions(ObjName);
        Map<String,List<SVMXC__ServiceMax_Processes__c>> map7 = SFWUtil.SVMX_GetInitiateReturnActions(ObjName);
        Map<String,List<SVMXC__ServiceMax_Processes__c>> map8 = SFWUtil.SVMX_GetFulfillmentProcessActions(ObjName);
        Map<String,List<SVMXC__ServiceMax_Processes__c>> map9 = SFWUtil.SVMX_GetSFMBackgroundActions(ObjName);
        
        ObjName = 'ALL';
        map1 = SFWUtil.SVMX_GetInventoryActions(ObjName);
        map2 = SFWUtil.SVMX_GetSFMActions(ObjName);
        map3 = SFWUtil.SVMX_GetOtherActions(ObjName);
        map4 = SFWUtil.SVMX_GetObjNamesNsfwRecs(ObjName);
        map5 = SFWUtil.SVMX_GetReceive_DeliveryActions(ObjName);
        map6 = SFWUtil.SVMX_GetPicking_ShippingActions(ObjName);
        map7 = SFWUtil.SVMX_GetInitiateReturnActions(ObjName);
        map8 = SFWUtil.SVMX_GetFulfillmentProcessActions(ObjName);
        map9 = SFWUtil.SVMX_GetSFMBackgroundActions(ObjName);
        ObjName = '';
        map1 = SFWUtil.SVMX_GetInventoryActions(ObjName);
        map2 = SFWUtil.SVMX_GetSFMActions(ObjName);
        map3 = SFWUtil.SVMX_GetOtherActions(ObjName);
        map4 = SFWUtil.SVMX_GetObjNamesNsfwRecs(ObjName);
        map5 = SFWUtil.SVMX_GetReceive_DeliveryActions(ObjName);
        map6 = SFWUtil.SVMX_GetPicking_ShippingActions(ObjName);
        map7 = SFWUtil.SVMX_GetInitiateReturnActions(ObjName);
        map8 = SFWUtil.SVMX_GetFulfillmentProcessActions(ObjName);
        map9 = SFWUtil.SVMX_GetSFMBackgroundActions(ObjName);
        map9 = SFWUtil.SVMX_GetSFMOutputDocActions(ObjName);
        SFWUtil.SVMX_GetNextStepURL(proces.id, process2.id);
        SFWUtil.SVMX_GetNextStepURL(process1.id, process2.id);
        SFWUtil.SVMX_GetNextStepURL(proces.id, process1.id);
    }
}