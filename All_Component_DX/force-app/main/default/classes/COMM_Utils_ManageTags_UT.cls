@isTest
Private class COMM_Utils_ManageTags_UT 
{
    static testMethod void SVMX_cloneTags_test()
    {
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
        //Create Module, Submodule, ObjMap, inv process
        SVMXC__ServiceMax_Processes__c module;
        system.assert(rts.size()>0);
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Module')
            {
                    SVMXC__ServiceMax_Processes__c mod = new SVMXC__ServiceMax_Processes__c(RecordTypeId =rt.Id,SVMXC__Active__c = true,SVMXC__Name__c = 'testModule',SVMXC__ModuleID__c = 'CUSTOMTEST');
                    insert mod;
                    module = mod;
            } 
        }   
        SVMXC__ServiceMax_Processes__c subModule;
        for(RecordType rt2 : rts) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt2.Name == 'Submodule')
            {
                SVMXC__ServiceMax_Processes__c subMod = new SVMXC__ServiceMax_Processes__c(RecordTypeId =rt2.Id,SVMXC__Active__c = true,SVMXC__Name__c = 'testSubModule',SVMXC__SubmoduleID__c = 'CUSTOMTEST001',SVMXC__Module__c = module.Id);
                insert subMod;
                subModule = subMod;
            } 
        }
        SVMXC.COMM_Utils_ManageTags obj = new SVMXC.COMM_Utils_ManageTags();
        Id exSubModule; 
        Id newSubModule;
        Map<String, SVMXC__ServiceMax_Tags__c> tagsMap = new Map<String, SVMXC__ServiceMax_Tags__c>();
        String installKey;
        obj.SVMX_cloneTags(exSubModule,newSubModule,tagsMap,installKey);
        //obj.SVMX_getTagRecordList(exSubModule);
        obj.SVMX_getTagRecordList(subModule.SVMXC__SubmoduleID__c);
        obj.SVMX_getTagList(subModule.SVMXC__SubmoduleID__c);
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
            
           SVMXC__ServiceMax_Tags__c tagMaster2 = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'Master Tag text2',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'Master', 
                                            Name = 'CUSTOMTAG002'                                        
                                            );
            insert tagMaster2;
       
         Map<String, SVMXC__ServiceMax_Tags__c> tagsMap1 = new Map<String, SVMXC__ServiceMax_Tags__c>();
         tagsMap1.put('CUSTOMTAG002',tagMaster2) ;  
         test.starttest();
         SVMXC.COMM_Utils_ManageTags commUtil1 = new SVMXC.COMM_Utils_ManageTags();
         commUtil1.SVMX_getTagRecordList(subModule.Id);
         SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
         commUtil.SVMX_cloneTags(subModule.Id, subModule2.Id, tagsMap1, null);
         Map<String, SVMXC__ServiceMax_Tags__c> x = commUtil.SVMX_getTagRecordList(subModule.SVMXC__SubmoduleID__c);
         test.stoptest();       
    }
    
    
    static testMethod void NoTagRecordTest_Test()
    {
      try
      { 
        //test.starttest();                                            
            SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
            system.assert(commUtil.SVMX_getTagList('NOSUBMODULE')!=null);
         //       Map<String, String> svmxTagList = commUtil.SVMX_getTagList('NOSUBMODULE');
        //test.stoptest();
      }
      catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }  
    }
    
   
   static testMethod void DefLangEnTags_Test()
    {
     try
     {  
        //Create Module, Submodule
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];    
        system.assert(rts.size()>0);
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
        //create tags, Link to SubModule, atleast one for each Lang

        SVMXC__ServiceMax_Tags__c tagsEn = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'Master Tag text',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'Master', 
                                            Name = 'CUSTOMTAG001'                                       
                                            );
        insert tagsEn;
        SVMXC__ServiceMax_Tags__c tagsEn2 = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'English Tag text2',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'Master', 
                                            Name = 'CUSTOM TAG002'                                        
                                            );
        insert tagsEn2;
       
        //test.starttest();                                            
            SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
         //       Map<String, String> svmxTagList = commUtil.SVMX_getTagList('CUSTOMTEST001');
        //test.stoptest();
     }
     catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
  
  
  static testMethod void GermanTagsTest_Test()
    {
      try
      {
        //Create Module, Submodule
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        system.assert(rts.size()>0);
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
        

         SVMXC__ServiceMax_Tags__c tagsDe =  new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'German Tag text',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'German', 
                                            Name = 'CUSTOMTAG001'                                          
                                            );
         insert tagsDe;
                                      
        Profile p = [select id from profile Limit 1]; 
        system.assert(p.Id!=null);
            
       
 
        
        //test.starttest();                                            
            SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
        //test.stoptest();
      }
      catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        } 
    }

    
    static testMethod void GermanWithDefLangEnTagsTest_Test()
    {
      try
      {
        //Create Module, Submodule
        RecordType[] rts = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'];
        system.assert(rts.size()>0);
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
        

        SVMXC__ServiceMax_Tags__c tagsEn = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'English Tag text',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'English', 
                                            Name = 'CUSTOMTAG001'                                       
                                            );
        insert tagsEn;
        SVMXC__ServiceMax_Tags__c tagsEn2 = new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'English Tag text2',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'English', 
                                            Name = 'CUSTOMTAG002'                                        
                                            );
        insert tagsEn2;
         SVMXC__ServiceMax_Tags__c tagsDe =  new SVMXC__ServiceMax_Tags__c(
                                            SVMXC__Tag_Text__c = 'German Tag text',
                                            SVMXC__Submodule__c = subModule.Id,
                                            SVMXC__Language__c = 'German', 
                                            Name = 'CUSTOMTAG001'                                          
                                            );
         insert tagsDe;
         
                                      
       Profile p = [select id from profile Limit 1];
       system.assert(p.Id!=null); 
        //test.starttest();                                            
            SVMXC.COMM_Utils_ManageTags commUtil = new SVMXC.COMM_Utils_ManageTags();
        //test.stoptest();
      }
      catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    static testMethod void INTF_MobileDeviceTagsUtility_Test1() 
    {
        COMM_Utils_ManageTags mobileDeviceTagsUtilityObj = new COMM_Utils_ManageTags();
        
        List<INTF_WebServicesDef.SVMXMap> mapLst = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap map1 = new INTF_WebServicesDef.SVMXMap();
        map1.key ='IPAD010';
        map1.value = 'TAG007';
        mapLst.add(map1);
        
        INTF_WebServicesDef.SVMXMap map2 = new INTF_WebServicesDef.SVMXMap();
        map2.key = 'IPAD010';
        map2.value = 'TAG006';
        mapLst.add(map2);
        
        INTF_WebServicesDef.SVMXMap map3 = new INTF_WebServicesDef.SVMXMap();
        map3.key ='IPAD004';
        map3.value = 'TAG034';
        mapLst.add(map3);
        
        INTF_WebServicesDef.INTF_SFMRequest tagsReq = new INTF_WebServicesDef.INTF_SFMRequest();
        tagsReq.valueMap = mapLst;
        
        mobileDeviceTagsUtilityObj.getMobileConfigTags(tagsReq);
    }
    
    static testMethod void INTF_MobileDeviceTagsUtility_Test2() 
    {
        COMM_Utils_ManageTags mobileDeviceTagsUtilityObj = new COMM_Utils_ManageTags();
        INTF_WebServicesDef.INTF_SFMRequest tagsReq = new INTF_WebServicesDef.INTF_SFMRequest();
        mobileDeviceTagsUtilityObj.getMobileConfigTags(tagsReq);
        
    }

}