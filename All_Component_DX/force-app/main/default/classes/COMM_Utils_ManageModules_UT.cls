@isTest(SeeAllData=true)
Private class COMM_Utils_ManageModules_UT { 
    
 static testMethod void COMM_Utils_ManageSettings_UT_Test()
    {

        try
        {
        
         RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
         RecordType[] rtsConf = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];    
            
         
        //Create Module, Submodule, ObjMap, inv process
        SVMXC__ServiceMax_Processes__c module;
        
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Module')
            {
                SVMXC__ServiceMax_Processes__c mod = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testModule',
                                            SVMXC__ModuleID__c = 'CUSTOMTEST'                                            
                                            );
                insert mod;
                module = mod;
            } 
        }   
         System.assertNotEquals(module.Id,null);
        SVMXC__ServiceMax_Processes__c subModule;
        for(RecordType rt2 : rts) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt2.Name == 'Submodule')
            {
                SVMXC__ServiceMax_Processes__c subMod = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModule',
                                            SVMXC__SubmoduleID__c = 'CUSTOMTEST001',
                                            SVMXC__Module__c = module.Id                                            
                                            );
                insert subMod;
                subModule = subMod;
            } 
        }
        System.assertNotEquals(subModule.Id,null);
        SVMXC__ServiceMax_Processes__c subModule2;
        for(RecordType rt2 : rts) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt2.Name == 'Submodule')
            {
                SVMXC__ServiceMax_Processes__c subMod2 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModule',
                                            SVMXC__SubmoduleID__c = 'CUSTOMTEST002',
                                            SVMXC__Module__c = module.Id                                           
                                            );
                insert subMod2;
                subModule2 = subMod2;
            } 
        }
      System.assertNotEquals(subModule2.Id,null);
        test.starttest();                                            
            SVMXC.COMM_Utils_ManageModules commUtil = new SVMXC.COMM_Utils_ManageModules();
            SVMXC__ServiceMax_Processes__c x =  commUtil.SVMX_cloneSubModule('CUSTOMTEST001', 'CUSTOMTEST002',null,module.SVMXC__ModuleID__c,module.Id);
            SVMXC__ServiceMax_Processes__c x1 =  commUtil.SVMX_cloneSubModule('', 'CUSTOMTEST002',null,module.SVMXC__ModuleID__c,module.Id);
        test.stoptest();
        
            
        
            }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }
        
        }
}