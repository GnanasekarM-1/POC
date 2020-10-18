@isTest
private class SFM_InvtUpdOnWorkOrderClosure_UT{
    static testMethod void executeSFMTrigger_Test1(){
        
        
        // Getting record types
        List<RecordType> recordTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE sobjectType IN ('SVMXC__ServiceMax_Processes__c')];
        
        String strInventoryProcessRecordTypeId;
                
        for( RecordType recordTypeSObject : recordTypeList ){
            if( recordTypeSObject.Name.equalsIgnoreCase( 'Inventory Process') ) 
                strInventoryProcessRecordTypeId = recordTypeSObject.id;
        }
        
        // Create inventory Process
        SVMXC__ServiceMax_Processes__c inventoryProcess = new SVMXC__ServiceMax_Processes__c();
        inventoryProcess.RecordTypeId = strInventoryProcessRecordTypeId;
        inventoryProcess.SVMXC__ProcessID__c = 'CUSTOMWORD101';
        inventoryProcess.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Order_Status__c = \'Open\''; 
        inventoryProcess.SVMXC__Child_Object_Criteria__c  = 'SVMXC__Posted_To_Inventory__c = FALSE';
        inventoryProcess.SVMXC__Parent_Error_Msg__c = 'This work order is not open.';
        inventoryProcess.SVMXC__Child_Error_Msg__c = 'No pending usage lines in this work order to post to inventory.';   
         
        insert inventoryProcess;
        // Create Account
        Account account = new Account( Name = 'Account',
                ShippingStreet = 'ABC',
                ShippingCity = 'PQR',
                ShippingState = 'XYZ',
                ShippingPostalCode = '111',
                ShippingCountry = 'XYZ',
                BillingStreet = 'ABC',
                BillingCity = 'PQR',
                BillingState = 'XYZ',
                BillingPostalCode = '111',
                BillingCountry = 'XYZ'); 
        insert account;
        // Create Contact
        Contact contact = new Contact( LastName='Last',
                AccountId = account.Id,
                Email = 'svmxmailfortest@servicemax.com');
        insert contact;
        
        // Create workorder
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c( 
                SVMXC__Company__c = account.Id,
                SVMXC__Contact__c = contact.Id,             
                SVMXC__Order_Status__c = 'open' );
                
        insert workOrder;
       
        List<SVMXC.SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('SVMX_HearderId', workOrder.Id));
        lstStringMap.add(new SVMXC.SFM_WrapperDef.SFM_StringMap('SVMX_InventoryProcessId', inventoryProcess.Id));
        SVMXC.SFM_WrapperDef.SFM_Request objRequest = new SVMXC.SFM_WrapperDef.SFM_Request();
        objRequest.stringMap = lstStringMap;
        
        SFM_InvtUpdOnWorkOrderClosure objSFM_InvtUpdOnWorkOrderClosure = new SFM_InvtUpdOnWorkOrderClosure();
        objSFM_InvtUpdOnWorkOrderClosure.executeSFMTrigger(objRequest);
    
    }
}