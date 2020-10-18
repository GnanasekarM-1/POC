@isTest
private class INVT_SetupSparePartsImpl_UT{

    static testMethod void getProfileDetails_Test(){
        //SVMXC.INVT_SetupSpareParts getProfileData = new SVMXC.INVT_SetupSpareParts();
        INVT_SetupSpareParts.getSparePartsProfile('{}');
        
        // Create Profile Record 
        SVMXC__ServiceMax_Config_Data__c profileRec = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Profile_Name__c = 'Test Profile',SVMXC__Active__c = true, SVMXC__CONFIGURATION_TYPE__c = 'Group');
        Id devRecordTypeId = Schema.SObjectType.SVMXC__ServiceMax_Config_Data__c.getRecordTypeInfosByName().get('Configuration Profile').getRecordTypeId();
        profileRec.RecordTypeId = devRecordTypeId;
        insert profileRec;
        INVT_SetupSpareParts.getSparePartConfig('{"profileId":"'+profileRec.id+'"}');
        
        // Save 
        INVT_SetupSpareParts.saveSparePartConfig('{"profileId":"'+profileRec.id+'","locatepartsetup":{"isenabled":true,"radius":10,"locationtype":["Customer","Internal"],"inventoryprocess":"SXFR001Cust","distanceinunit":"Miles"}}');
        
    }
    
    static testMethod void getInventoryConfig(){
    
        SVMXC__ServiceMax_Config_Data__c profileRec = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Profile_Name__c = 'Test Profile',SVMXC__Active__c = true, SVMXC__CONFIGURATION_TYPE__c = 'Group');
        Id devRecordTypeId = Schema.SObjectType.SVMXC__ServiceMax_Config_Data__c.getRecordTypeInfosByName().get('Configuration Profile').getRecordTypeId();
        profileRec.RecordTypeId = devRecordTypeId;
        insert profileRec;
        
        SVMXC__SM_Inventory_Config__c invConfig = new SVMXC__SM_Inventory_Config__c();
        invConfig.SVMXC__SM_Content__c = '{"profileId":"'+profileRec.id+'","locatepartsetup":{"isenabled":true,"radius":10,"locationtype":["Customer","Internal"],"inventoryprocess":"SXFR001Cust","distanceinunit":"Miles"}}';
        //invConfig.SVMXC__SM_Device_Type__c = 'default'; 
        invConfig.SVMXC__SM_ServiceMax_Profile__c = profileRec.id;
        insert invConfig;
        
        INVT_SetupSpareParts.getSparePartConfig('{"profileId":"'+profileRec.id+'"}');
        
        
    }
    
    static testMethod void saveException(){
    
        // Save 
        INVT_SetupSpareParts.saveSparePartConfig('{"profileId":"","locatepartsetup":{"isenabled":true,"radius":10,"locationtype":["Customer","Internal"],"inventoryprocess":"SXFR001Cust","distanceinunit":"Miles"}}');
        
        
        
    }
}