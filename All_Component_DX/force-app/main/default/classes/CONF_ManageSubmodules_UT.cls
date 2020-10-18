@isTest(SeeAllData=true)
Private class CONF_ManageSubmodules_UT 
{   
    
     
    private static SVMXC.CONF_ManageSubmodules msmdef;
    
    //Variables for Configuration Setting Data   
    private static List<RecordType> rtSVMX_Processes = new List<RecordType>();
    private static List<SVMXC__ServiceMax_Processes__c> SVMX_subModule = new List<SVMXC__ServiceMax_Processes__c>();
    
    //Objects for Module, Submodule
    private static SVMXC__ServiceMax_Processes__c module,module2;
    private static SVMXC__ServiceMax_Processes__c subModule;
    
    
     static testmethod void CONF_ManageSubmodules_Test()
     {
      try
      {
        String ObjName=''; 
        String SOQLStatement=''; 
        
        ObjName = 'SVMXC__ServiceMax_Processes__c';
        SOQLStatement = 'SELECT Id, Name FROM RecordType WHERE SobjectType =\''+ ObjName+ '\' ';
        rtSVMX_Processes = Database.query(SOQLStatement);
        
         for(RecordType rt : rtSVMX_Processes) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Module')
            {
                SVMXC__ServiceMax_Processes__c mod = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'Moduletest001',
                                            SVMXC__ModuleID__c = 'CUSTOMTEST'                                            
                                            );
                insert mod;
                module = mod;
            }
             if(rt.Name == 'Module')
            {
                SVMXC__ServiceMax_Processes__c mod2 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'Moduletest001',
                                            SVMXC__ModuleID__c = 'CUSTOMTEST'                                            
                                            );
                insert mod2;
                module2 = mod2;
            }  
        }   
        System.assertEquals('Moduletest001', module.SVMXC__Name__c = 'Moduletest001');
        System.assertEquals('Moduletest001', module2.SVMXC__Name__c = 'Moduletest001');
        for(RecordType rt2 : rtSVMX_Processes) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt2.Name == 'Submodule')
            {
                SVMXC__ServiceMax_Processes__c subModOne = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModuleOne',
                                            SVMXC__SubmoduleID__c = 'SBMTEST001',
                                            SVMXC__IsStandard__c = true,
                                            SVMXC__Module__c = module.Id                                            
                                            );
                SVMXC__ServiceMax_Processes__c subModTwo = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModuleTwo',
                                            SVMXC__SubmoduleID__c = 'SBMTEST002',
                                            SVMXC__IsStandard__c = false,
                                            SVMXC__Module__c = module.Id                                            
                                            ); 
                SVMXC__ServiceMax_Processes__c subModThree = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModuleTwo',
                                            SVMXC__SubmoduleID__c = 'SBMTEST002',
                                            SVMXC__IsStandard__c = false,
                                            SVMXC__Module__c = module.Id                                            
                                            );   
                                                                                                                                         
                SVMX_subModule.add(subModOne) ;
                SVMX_subModule.add(subModTwo) ; 
                SVMX_subModule.add(subModThree) ; 
            
                insert SVMX_subModule;
               
           } 
        }
        
        PageReference pageRef = new PageReference('Page.SVMXC.CONF_ManageSubmodules');
        Test.setCurrentPage(pageRef);
        test.startTest();
        msmdef=new SVMXC.CONF_ManageSubmodules();
        msmdef.getTAG001();
        msmdef.getTAG002();
        msmdef.getTAG003();
        msmdef.getTAG004();
        msmdef.getTAG005();
        msmdef.getTAG006();
        msmdef.getTAG007();
        msmdef.getTAG008();
        msmdef.getTAG009();
        msmdef.getTAG010();
        msmdef.getTAG011();
        msmdef.getTAG012();
        //msmdef.getTAG013();
        msmdef.getTAG014();
        msmdef.getTAG015();
        msmdef.getTAG016();
        msmdef.getTAG017();
        msmdef.getHLPURL();
        msmdef.getTAG019();
        msmdef.getTAG020();
        msmdef.getTAG021();        
        msmdef.getTAG022();
        msmdef.getTAG023();
        msmdef.getTAG024();
        msmdef.getTAG025();
        msmdef.getTAG026();
        msmdef.getTAG027();
        msmdef.getTAG028();
        //msmdef.svmxSettingList.clear();
        msmdef.getTAG001();
        msmdef.getTAG002();
        msmdef.getTAG003();
        msmdef.getTAG004();
        msmdef.getTAG005();
        msmdef.getTAG006();
        msmdef.getTAG007();
        msmdef.getTAG008();
        msmdef.getTAG009();
        msmdef.getTAG010();
        msmdef.getTAG011();
        msmdef.getTAG012();
        //msmdef.getTAG013();
        msmdef.getTAG014();
        msmdef.getTAG015();
        msmdef.getTAG016();
        msmdef.getTAG017();
        msmdef.getHLPURL();
        msmdef.getTAG019();
        msmdef.getTAG020();
        msmdef.getTAG021();        
        msmdef.getTAG022();
        msmdef.getTAG023();
        msmdef.getTAG024();
        msmdef.getTAG025();
        msmdef.getTAG026();
        msmdef.getTAG027();
        msmdef.getTAG028();
        
       // msmdef.svmxTagList=null;     
        
        msmdef.setModuleView(module.Id);
        msmdef.getModuleView();
        msmdef.getRecordType();
        msmdef.getItems();
        msmdef.submodule();
        msmdef.getStandSubModule();
        msmdef.getCustomSubModule();
        msmdef.AddCustomSubModuleLine();
        msmdef.getCustomDisplayBlockLevelMessage();
        msmdef.setCheckAllLines(true);
        msmdef.getDisplayTableColumns();
        msmdef.getIsCustAvail();
        msmdef.RemoveCustomSubmoduleLine();
        RecordType RecordTypeObject=msmdef.getRecordType();
        SVMXC__ServiceMax_Processes__c smcsmone=new SVMXC__ServiceMax_Processes__c(RecordTypeId = RecordTypeObject.Id ,SVMXC__Module__c =module.Id  ,SVMXC__IsStandard__c=false);

        msmdef.Save();
        msmdef.BackToHomePage();
        msmdef.customSettings();
        msmdef.standardSettings();        
        msmdef.getDisplayBlockLevelMessage();    
        msmdef.getCheckAllLines();    
        pageRef=null;
        pageRef = new PageReference('Page.SVMXC.CONF_ManageSubmodules');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid',module.Id); 
        test.stopTest();
     }
     catch(Exception ex)
       {
         ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
       }  
        
    }
     static testmethod void CONF_ManageSubmodules_Test2()
     {
      try
      {
        String ObjName=''; 
        String SOQLStatement=''; 
        
        ObjName = 'SVMXC__ServiceMax_Processes__c';
        SOQLStatement = 'SELECT Id, Name FROM RecordType WHERE SobjectType =\''+ ObjName+ '\' ';
        rtSVMX_Processes = Database.query(SOQLStatement);
        
         for(RecordType rt : rtSVMX_Processes) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Module')
            {
                SVMXC__ServiceMax_Processes__c mod = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'Moduletest001',
                                            SVMXC__ModuleID__c = 'CUSTOMTEST'                                            
                                            );
                insert mod;
                System.assertEquals(true, mod != null);
                module = mod;
            }
             if(rt.Name == 'Module')
            {
                SVMXC__ServiceMax_Processes__c mod2 = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'Moduletest001',
                                            SVMXC__ModuleID__c = 'CUSTOMTEST'                                            
                                            );
                insert mod2;
                System.assertEquals(true, mod2 != null);
                module2 = mod2;
            }  
        }   
        
        for(RecordType rt2 : rtSVMX_Processes) //Loop to take a record type at a time
        {
            // Create Sub-Module Record, Link to Module
            if(rt2.Name == 'Submodule')
            {
                SVMXC__ServiceMax_Processes__c subModOne = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModuleOne',
                                            SVMXC__SubmoduleID__c = 'SBMTEST001',
                                            SVMXC__IsStandard__c = true,
                                            SVMXC__Module__c = module.Id  
                                                                                      
                                            );
                SVMXC__ServiceMax_Processes__c subModTwo = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModuleTwo',
                                            SVMXC__SubmoduleID__c = 'SBMTEST002',
                                            SVMXC__IsStandard__c = false,
                                            SVMXC__Module__c = module.Id  
                                                                                      
                                            ); 
                SVMXC__ServiceMax_Processes__c subModThree = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt2.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'testSubModuleTwo',
                                            SVMXC__SubmoduleID__c = 'SBMTEST002',
                                            SVMXC__IsStandard__c = false,
                                            SVMXC__Module__c = module.Id 
                                                                                   
                                            );   
                                                                                                                                         
                SVMX_subModule.add(subModOne) ;
                SVMX_subModule.add(subModTwo) ; 
                SVMX_subModule.add(subModThree) ; 
            
                insert SVMX_subModule;
                System.assertEquals(true, SVMX_subModule != null);
               
           } 
        }
        
        ApexPages.currentPage().getParameters().put('mid',module2.Id); 
         SVMXC__ServiceMax_Processes__c smcsmtwo=new SVMXC__ServiceMax_Processes__c(RecordTypeId = module2.RecordTypeId ,SVMXC__Module__c =module2.Id  ,SVMXC__IsStandard__c=false);       
        SVMXC.CONF_ManageSubmodules msmdef3=new SVMXC.CONF_ManageSubmodules();
        SVMX_subModule.get(2).SVMXC__Select__c=true;
        upsert SVMX_subModule; 
        
        msmdef3.setModuleView(module.Id);
        msmdef3.getModuleView();
        msmdef3.getRecordType();
        msmdef3.getItems();
        msmdef3.submodule();
        msmdef3.getStandSubModule();
        msmdef3.getCustomSubModule();
        msmdef3.AddCustomSubModuleLine();
        RecordType RecordTypeObject=msmdef3.getRecordType();
        SVMXC__ServiceMax_Processes__c smcsmone=new SVMXC__ServiceMax_Processes__c(RecordTypeId = RecordTypeObject.Id ,SVMXC__Module__c =module.Id  ,SVMXC__IsStandard__c=false);

        msmdef3.Save();
        msmdef3.BackToHomePage();
        msmdef3.customSettings();
        msmdef3.standardSettings();        
        msmdef3.getDisplayBlockLevelMessage();    
        msmdef3.getCheckAllLines();           
       
        msmdef3.Save();
      }
      catch(Exception ex)
       {
         ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
       }

}
}