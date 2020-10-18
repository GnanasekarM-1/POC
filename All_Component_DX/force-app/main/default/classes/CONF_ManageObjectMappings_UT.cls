@isTest(SeeAllData=true)
Private class CONF_ManageObjectMappings_UT {
    
    private static SVMXC.CONF_ManageObjectMappings manAutoMapping;
    private static List<RecordType> rtSVMX_Processes = new List<RecordType>();
    private static List<SVMXC__ServiceMax_Processes__c> SVMX_Process = new List<SVMXC__ServiceMax_Processes__c>();
    private static List<SVMXC__ServiceMax_Config_Data__c> SVMX_Config_Data = new List<SVMXC__ServiceMax_Config_Data__c>();
    static testmethod void CONF_ManageObjectMappings_Test()
    {
      try
      {
         String ObjName=''; 
         String SOQLStatement=''; 
         ObjName = 'SVMXC__ServiceMax_Processes__c';
         SOQLStatement = 'SELECT Id, Name FROM RecordType WHERE SobjectType =\''+ ObjName+ '\' ';
         rtSVMX_Processes = Database.query(SOQLStatement);
         SVMXC__ServiceMax_Processes__c objMappingOne,objMappingTwo,objMappingThree,customObjMappingTwo,objMappingFour;
         for(RecordType rt : rtSVMX_Processes) //Loop to take a record type at a time
        {
            // Create Module Record
            if(rt.Name == 'Object Mapping')
            {
                 objMappingOne = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'Objecttest001',
                                            SVMXC__ModuleID__c = 'TESTONEOBJECT',
                                            SVMXC__IsStandard__c= false,
                                            SVMXC__Select__c = false,
                                            SVMXC__SOURCE_OBJECT_NAME__C = 'SVMXC__ServiceMax_Processes__c',
                                            SVMXC__TARGET_OBJECT_NAME__C = 'SVMXC__ServiceMax_Processes__c',
                                            SVMXC__TARGET_RECORD_TYPE__C = 'Settings',
                                            SVMXC__MAPID__C = 'CUSTOMMAP001'                                           
                                            );
                //
               insert objMappingOne;
               System.assertEquals('Objecttest001', objMappingOne.SVMXC__Name__c);
               SVMX_Process.add(objMappingOne);
                
                //module = mod;
            } 
             if(rt.Name == 'Object Mapping')
            {
                 customObjMappingTwo = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'Objecttest0012',
                                            SVMXC__ModuleID__c = 'CUSTTESTONEOBJECT',
                                            SVMXC__IsStandard__c= false,
                                            SVMXC__Select__c = true,
                                            SVMXC__SOURCE_OBJECT_NAME__C = 'SVMXC__ServiceMax_Processes__c',
                                            SVMXC__TARGET_OBJECT_NAME__C = 'SVMXC__ServiceMax_Processes__c',
                                            SVMXC__TARGET_RECORD_TYPE__C = 'Settings',
                                            SVMXC__MAPID__C = 'CUSTOMMAP001'                                           
                                            );
                //
               insert customObjMappingTwo;
               SVMX_Process.add(customObjMappingTwo);
                
                //module = mod;
            } 
             if(rt.Name == 'Object Mapping')
            {
                objMappingTwo = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = false,
                                            SVMXC__Name__c = 'Objecttest002',
                                            SVMXC__ModuleID__c = 'TESTTWOOBJECT' ,
                                            SVMXC__IsStandard__c= false ,
                                            SVMXC__Select__c = true  ,
                                            SVMXC__SOURCE_OBJECT_NAME__C = 'SVMXC__ServiceMax_Processes__c',
                                            SVMXC__TARGET_OBJECT_NAME__C = 'SVMXC__ServiceMax_Processes__c',
                                            SVMXC__TARGET_RECORD_TYPE__C = 'Settings',
                                            SVMXC__MAPID__C = 'CUSTOMMAP002'                                          
                                            );
               
              // 
               insert objMappingTwo;
               System.assertEquals('Objecttest002', objMappingTwo.SVMXC__Name__c);
               SVMX_Process.add(objMappingTwo);
                //module = mod;
            } 
             if(rt.Name == 'Object Mapping')
            {
                 objMappingThree = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'Objecttest003',
                                            SVMXC__ModuleID__c = 'TESTTHREEOBJECT',
                                            SVMXC__IsStandard__c= true,
                                            SVMXC__Select__c = true, 
                                            SVMXC__SOURCE_OBJECT_NAME__C = 'SVMXC__ServiceMax_Processes__c',
                                            SVMXC__TARGET_OBJECT_NAME__C = 'SVMXC__ServiceMax_Processes__c',
                                            SVMXC__TARGET_RECORD_TYPE__C = 'Settings',
                                            SVMXC__MAPID__C = 'CUSTOMMAP003'                                           
                                            );
                //
                insert objMappingThree;
                SVMX_Process.add(objMappingThree);
                
                //module = mod;
            } 
            
           

            if(rt.Name == 'Field Mapping')
            {
                SVMXC__ServiceMax_Config_Data__c fieldMappingone = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = false,
                                            SVMXC__MapID__c =objMappingOne.Id ,
                                            SVMXC__Source_Field_Name__c = 'Source Field Test One',
                                            SVMXC__Target_Field_Name__c = 'Target Field Test one'                                           
                                                                                        
                                            );
                SVMX_Config_Data.add(fieldMappingone);
                
            } 
             if(rt.Name == 'Field Mapping')
            {
                SVMXC__ServiceMax_Config_Data__c fieldMappingTwo = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__MapID__c =objMappingOne.Id ,
                                            SVMXC__Source_Field_Name__c = 'Source Field Test Two',
                                            SVMXC__Target_Field_Name__c = 'Target Field Test Two'                                           
                                                                                        
                                            );
                SVMX_Config_Data.add(fieldMappingTwo);
                
            }
            if(rt.Name == 'Field Mapping')
            {
                SVMXC__ServiceMax_Config_Data__c fieldMappingThree = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = false,
                                            SVMXC__MapID__c =objMappingTwo.Id ,
                                            SVMXC__Source_Field_Name__c = 'Source Field Test One',
                                            SVMXC__Target_Field_Name__c = 'Target Field Test one'                                         
                                            
                                                                                        
                                            );
               SVMX_Config_Data.add(fieldMappingThree);
                
            } 
             if(rt.Name == 'Field Mapping')
            {
                SVMXC__ServiceMax_Config_Data__c fieldMappingFour = new SVMXC__ServiceMax_Config_Data__c(
                                            RecordTypeId =rt.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__MapID__c =objMappingTwo.Id ,
                                            SVMXC__Source_Field_Name__c = 'Source Field Test Two',
                                            SVMXC__Target_Field_Name__c = 'Target Field Test Two'                                           
                                                                                        
                                            );
                SVMX_Config_Data.add(fieldMappingFour);
                 
            }  
             insert SVMX_Config_Data;
        } 
        test.startTest();
        PageReference pageRef = new PageReference('Page.SVMXC__CONF_ManageObjectMappings');
        Test.setCurrentPage(pageRef);  
        manAutoMapping =new SVMXC.CONF_ManageObjectMappings();
        manAutoMapping.getStandAutomation();
        manAutoMapping.getCustomAutomation();
        manAutoMapping.getTAG001();
        manAutoMapping.getTAG002();
        manAutoMapping.getTAG003();
        manAutoMapping.getTAG004();
        manAutoMapping.getTAG005();
        manAutoMapping.getTAG006();
        manAutoMapping.getTAG007();
        manAutoMapping.getTAG008();
        manAutoMapping.getTAG009();
        manAutoMapping.getTAG011();
        manAutoMapping.getTAG012();
        manAutoMapping.getTAG013();
        manAutoMapping.getTAG015();
        manAutoMapping.getTAG016();
        manAutoMapping.getTAG017();
        manAutoMapping.getHLPURL();
       // manAutoMapping.svmxTagList.clear();
        manAutoMapping.getTAG001();
        manAutoMapping.getTAG002();
        manAutoMapping.getTAG003();
        manAutoMapping.getTAG004();
        manAutoMapping.getTAG005();
        manAutoMapping.getTAG006();
        manAutoMapping.getTAG007();
        manAutoMapping.getTAG008();
        manAutoMapping.getTAG009(); 
        manAutoMapping.getTAG011();
        manAutoMapping.getTAG012();
        manAutoMapping.getTAG013();
        manAutoMapping.getTAG015();
        manAutoMapping.getTAG016();
        manAutoMapping.getTAG017();
        manAutoMapping.getHLPURL();
        manAutoMapping.view();
        objMappingThree.SVMXC__Select__c =false;
        objMappingTwo.SVMXC__Select__c =false;
        
        manAutoMapping.view();
        manAutoMapping.StandardClone();
        manAutoMapping.NewButton();
        manAutoMapping.EditButton();
        manAutoMapping.CloneButton();
        manAutoMapping.view();
        manAutoMapping.StandardClone();
        manAutoMapping.NewButton();
        manAutoMapping.EditButton();
        manAutoMapping.CloneButton();
        manAutoMapping.BackToHomePage();
        manAutoMapping.RemoveCustomObjectMapping();
        manAutoMapping.getDisplayBlockLevelMessage(); 
        manAutoMapping.getCustomDisplayBlockLevelMessage();
        manAutoMapping.isMultiSelected(SVMX_Process);
        manAutoMapping.getDisplayTableColumns();
        
        List<Id> idString = new List<Id>();
        idString.add(objMappingThree.Id);
        manAutoMapping.SVMX_getCommaSepratedStr(idString);
        test.stopTest();
      }
      catch(Exception ex)
       {
         ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ex.getMessage()));
       } 
        
    }  
    
    

}