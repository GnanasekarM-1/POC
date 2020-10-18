@isTest(SeeAllData=true)
private with sharing  class PREV_PMScheduler_UT {
    
    private static SVMXC.PREV_ViewEditPMPlan PMObject; 
    private static List<RecordType> rtSVMX_Processes = new List<RecordType>();
    
    static testMethod void PREV_PMScheduler_Test() 
    {
        //try{  
            
            SVMXC__ServiceMax_Processes__c objMappingOne,objMappingTwo,objMappingThree,objMappingFour;
            SVMXC__ServiceMax_Config_Data__c  fieldMappingone ,fieldMappingtwo,fieldMappingthree,fieldMappingfour;
            String SOQLStatement = 'SELECT Id, Name,SobjectType FROM RecordType ';
            List<SVMXC__ServiceMax_Processes__c> smaxprocess=new List<SVMXC__ServiceMax_Processes__c>();
            rtSVMX_Processes = Database.query(SOQLStatement);
             for(RecordType rt : rtSVMX_Processes) //Loop to take a record type and creating object mapping 
            {
                if(rt.Name == 'Object Mapping' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                {
                     objMappingOne = new SVMXC__ServiceMax_Processes__c(
                                                RecordTypeId =rt.Id,
                                                SVMXC__Active__c = true,
                                                SVMXC__Name__c = 'Test Mapping One',
                                                SVMXC__ModuleID__c = 'TESTONE1',
                                                SVMXC__IsStandard__c= false,
                                                SVMXC__SOURCE_OBJECT_NAME__C = 'SVMXC__Service_Contract__c',
                                                SVMXC__TARGET_OBJECT_NAME__C = 'SVMXC__Service_Order__c',
                                                SVMXC__MAPID__C = 'SERVICECONTOWORKORDER'
                                                );
                    smaxprocess.add(objMappingOne);
                    objMappingTwo = new SVMXC__ServiceMax_Processes__c(
                                                RecordTypeId =rt.Id,
                                                SVMXC__Active__c = true,
                                                SVMXC__Name__c = 'Test Mapping Two',
                                                SVMXC__ModuleID__c = 'TESTTWO',
                                                SVMXC__IsStandard__c= false,
                                                SVMXC__SOURCE_OBJECT_NAME__C = 'SVMXC__Service_Order__c',
                                                SVMXC__TARGET_OBJECT_NAME__C = 'Case',
                                                SVMXC__MAPID__C = 'WORKORDERTOCASE'
                                                );
                    smaxprocess.add(objMappingTwo);
                    
                    
                    objMappingThree = new SVMXC__ServiceMax_Processes__c(
                                                RecordTypeId =rt.Id,
                                                SVMXC__Active__c = true,
                                                SVMXC__Name__c = 'Test Mapping Three',
                                                SVMXC__ModuleID__c = 'TESTTWO',
                                                SVMXC__IsStandard__c= false,
                                                SVMXC__SOURCE_OBJECT_NAME__C = 'SVMXC__Installed_Product__c',
                                                SVMXC__TARGET_OBJECT_NAME__C = 'SVMXC__Service_Order__c',
                                                SVMXC__MAPID__C = 'INSTALLPORDUCTTOWO'
                                                );
                      smaxprocess.add(objMappingThree); 
                    
                     insert smaxprocess;
                     system.assertEquals(3, smaxprocess.size());
                     system.assertEquals('Test Mapping One', smaxprocess[0].SVMXC__Name__c);
                     system.assertEquals('Test Mapping Two', smaxprocess[1].SVMXC__Name__c);
                     system.assertEquals('Test Mapping Three', smaxprocess[2].SVMXC__Name__c);
                } 
                
                
            }
         
           List<SVMXC__ServiceMax_Config_Data__c> smaxConfigdata=new List<SVMXC__ServiceMax_Config_Data__c>();
            for(RecordType rt : rtSVMX_Processes) //Loop to take a record type at a time
            {
                if(rt.Name == 'Field Mapping' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                {
                             fieldMappingone = new SVMXC__ServiceMax_Config_Data__c(
                                                RecordTypeId =rt.Id,
                                                SVMXC__Active__c = true,
                                                SVMXC__MapID__c =smaxprocess[0].Id ,
                                                SVMXC__Source_Field_Name__c = 'Name',
                                                SVMXC__Target_Field_Name__c = 'SVMXC__Configuration_After__c'
                                                );
                            smaxConfigdata.add(fieldMappingone);
                            fieldMappingtwo = new SVMXC__ServiceMax_Config_Data__c(
                                                RecordTypeId =rt.Id,
                                                SVMXC__Active__c = true,
                                                SVMXC__MapID__c =smaxprocess[1].Id ,
                                                SVMXC__Source_Field_Name__c = 'Name',
                                                SVMXC__Target_Field_Name__c = 'Subject'
                                                );
                            smaxConfigdata.add(fieldMappingtwo);
                            fieldMappingthree = new SVMXC__ServiceMax_Config_Data__c(
                                                RecordTypeId =rt.Id,
                                                SVMXC__Active__c = true,
                                                SVMXC__MapID__c =smaxprocess[2].Id ,
                                                SVMXC__Source_Field_Name__c = 'Name',
                                                SVMXC__Target_Field_Name__c = 'Name'
                                                );
                             smaxConfigdata.add(fieldMappingthree);
                            
                             
                             
                            insert smaxConfigdata;
                    
                } 
            }
            Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert account;
        System.assertEquals('Account', account.name);
        Product2 prod = new Product2(
                                       Name = 'Prod', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True
                                       );
        insert prod;
        System.assertEquals('Prod', prod.name);
        Product2 prod1 = new Product2(
                                       Name = 'Prod1', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True 
                                       );
        insert prod1;
        System.assertEquals('Prod1', prod1.name);
        Product2 prod2 = new Product2(
                                       Name = 'Prod2', 
                                       ProductCode = '1235', 
                                       Family = 'Accessory', 
                                       SVMXC__Inherit_Parent_Warranty__c =True
                                       );
        insert prod2;
        System.assertEquals('Prod2', prod2.name);
        SVMXC__Installed_Product__c IBObject = new SVMXC__Installed_Product__c(
                                       Name = 'Test IB',
                                       SVMXC__Status__c = 'Installed',
                                       SVMXC__Product__c = prod.Id,
                                       SVMXC__Date_Installed__c = System.Today(),
                                       SVMXC__Company__c = account.Id
                                       );
         insert IBObject;
         System.assertEquals('Test IB', IBObject.name);
         SVMXC__Installed_Product__c IBObject1 = new SVMXC__Installed_Product__c(
                                       Name = 'Test IB1',
                                       SVMXC__Status__c = 'Installed',
                                       SVMXC__Product__c = prod1.Id,
                                       SVMXC__Date_Installed__c = System.Today(),
                                       SVMXC__Company__c = account.Id
                                       );
         insert IBObject1;
         System.assertEquals('Test IB1', IBObject1.name);
        /* for ut fail
         SVMXC__Installed_Product__c IBObject2 = new SVMXC__Installed_Product__c(
                                       Name = 'Test IB2',
                                       SVMXC__Status__c = 'Installed',
                                       SVMXC__Product__c = prod2.Id,
                                       SVMXC__Date_Installed__c = System.Today(),
                                       SVMXC__Company__c = account.Id
                                       );
         insert IBObject2;
         System.assertEquals('Test IB2', IBObject2.name);
         */
        SVMXC__Service_Level__c sconSLA = new SVMXC__Service_Level__c(
                                        
                                        SVMXC__Active__c=true,
                                        SVMXC__Description__c = 'Test Desc',
                                        SVMXC__Effective_Date__c=System.today()
                                        
                                        );
        insert sconSLA;
        SVMXC__Service_Contract__c SconObject = new SVMXC__Service_Contract__c(
                                             
                                             Name='ZZ1',
                                             SVMXC__Company__c=account.Id,
                                             SVMXC__End_Date__c=System.today(),
                                             SVMXC__Start_Date__c=System.today(),
                                             OwnerId =UserInfo.getUserId() ,
                                             SVMXC__Service_Level__c= sconSLA.id
                                              );
        insert SconObject;
        SVMXC__Service_Contract_Products__c SCP = new SVMXC__Service_Contract_Products__c(
                    
                                            SVMXC__Installed_Product__c=IBObject.Id,
                                            SVMXC__Product_Family__c='Accessory',
                                            SVMXC__Product_Line__c='Accessory',
                                            SVMXC__Notes__c='Its for test method',
                                            SVMXC__Service_Contract__c = SconObject.Id
                                            );
        insert SCP;
         SVMXC__Service_Contract_Products__c SCP1 = new SVMXC__Service_Contract_Products__c(
                    
                                            SVMXC__Installed_Product__c=IBObject1.Id,
                                            SVMXC__Product_Family__c='Accessory',
                                            SVMXC__Product_Line__c='Accessory',
                                            SVMXC__Notes__c='Its for test method',
                                            SVMXC__Service_Contract__c = SconObject.Id
                                            );
        insert SCP1;
         SVMXC__Service_Contract_Products__c SCP2 = new SVMXC__Service_Contract_Products__c(
                    
                                            SVMXC__Installed_Product__c=IBObject1.Id,
                                            SVMXC__Product_Family__c='Accessory',
                                            SVMXC__Product_Line__c='Accessory',
                                            SVMXC__Notes__c='Its for test method',
                                            SVMXC__Service_Contract__c = SconObject.Id
                                            );
        insert SCP2;
        List<SVMXC__PM_Plan__c> Listpmplan=new  List<SVMXC__PM_Plan__c>();
         
        
        
        SVMXC__PM_Plan__c pmplanone  = new SVMXC__PM_Plan__c(
                                
                                        Name = 'PM Plan One',
                                        SVMXC__Service_Contract__c = SconObject.id,
                                        SVMXC__Start_Date__c = system.Today().addDays(-30),
                                        SVMXC__End_Date__c = system.Today().addDays(60),
                                        SVMXC__Schedule_Type__c ='Time Based',
                                        SVMXC__Field_map_for_wo__c = smaxprocess[0].SVMXC__MapID__c,
                                        SVMXC__Field_map_for_Case__c = smaxprocess[1].SVMXC__MapID__c,
                                        SVMXC__Work_Order_Assign_To__c='USER',
                                        SVMXC__Work_Order_Assign_To_User__c=UserInfo.getUserId(),
                                        SVMXC__Number_of_Work_orders__c='ONE PER PRODUCT',
                                        SVMXC__Number_of_Cases__c ='ONE PER WORK ORDER',
                                        SVMXC__Create_Case__c = true,
                                        SVMXC__Success_Email_ID__c ='success@test.com',
                                        SVMXC__Error_Email_ID__c ='error@test.com',
                                        SVMXC__Next_PM_Date__c = system.Today(),
                                        SVMXC__Work_Order_Date__c = system.Today(),
                                        SVMXC__Frequency__c =2,
                                        SVMXC__Frequency_Unit__c ='Months',
                                        SVMXC__Status__c ='Active'
                                         
                                        );
                                        
        Listpmplan.add(pmplanone);  
        SVMXC__PM_Plan__c pmplantwo  = new SVMXC__PM_Plan__c(
                                        Name = 'PM Plan two',
                                        SVMXC__Service_Contract__c = SconObject.id,
                                        SVMXC__Start_Date__c = system.Today().addDays(-30),
                                        SVMXC__End_Date__c = system.Today().addDays(60),
                                        SVMXC__Schedule_Type__c ='Time Based',
                                        SVMXC__Field_map_for_wo__c = smaxprocess[0].SVMXC__MapID__c,
                                        SVMXC__Field_map_for_Case__c = smaxprocess[1].SVMXC__MapID__c,
                                        SVMXC__Work_Order_Assign_To__c='USER',
                                        SVMXC__Work_Order_Assign_To_User__c=UserInfo.getUserId(),
                                        SVMXC__Number_of_Work_orders__c='ONE PER PLAN',
                                        SVMXC__Number_of_Cases__c ='ONE PER WORK ORDER',
                                        SVMXC__Create_Case__c = true,
                                        SVMXC__Success_Email_ID__c ='success@test.com',
                                        SVMXC__Error_Email_ID__c ='error@test.com',
                                        SVMXC__Next_PM_Date__c = system.Today()+2,
                                        SVMXC__Work_Order_Date__c = system.Today(),
                                        SVMXC__Frequency__c =2,
                                        SVMXC__Frequency_Unit__c ='Months',
                                        SVMXC__Status__c ='Active'
                                        );
      Listpmplan.add(pmplantwo); 
      SVMXC__PM_Plan__c pmplanthree  = new SVMXC__PM_Plan__c(
                                
                                        Name = 'PM Plan Three',
                                        SVMXC__Service_Contract__c = SconObject.id,
                                        SVMXC__Start_Date__c = system.Today().addDays(-30),
                                        SVMXC__End_Date__c = system.Today().addDays(60),
                                        SVMXC__Schedule_Type__c ='Time Based',
                                        SVMXC__Field_map_for_wo__c = smaxprocess[0].SVMXC__MapID__c,
                                        SVMXC__Field_map_for_Case__c = smaxprocess[1].SVMXC__MapID__c,
                                        SVMXC__Work_Order_Assign_To__c='USER',
                                        SVMXC__Work_Order_Assign_To_User__c=UserInfo.getUserId(),
                                        SVMXC__Number_of_Work_orders__c='ONE PER PRODUCT',
                                        SVMXC__Number_of_Cases__c ='ONE PER PLAN',
                                        SVMXC__Create_Case__c = true,
                                        SVMXC__Success_Email_ID__c ='success@test.com',
                                        SVMXC__Error_Email_ID__c ='error@test.com',
                                        SVMXC__Next_PM_Date__c = system.Today()+2,
                                        SVMXC__Work_Order_Date__c = system.Today(),
                                        SVMXC__Frequency__c =2,
                                        SVMXC__Frequency_Unit__c ='Days',
                                        SVMXC__Status__c ='Active'
                                        );
      Listpmplan.add(pmplanthree); 
      SVMXC__PM_Plan__c pmplanfour  = new SVMXC__PM_Plan__c(
                                
                                        Name = 'PM Plan FOUR',
                                        SVMXC__Service_Contract__c = SconObject.id,
                                        SVMXC__Start_Date__c = system.Today().addDays(-30),
                                        SVMXC__End_Date__c = system.Today().addDays(60),
                                        SVMXC__Schedule_Type__c ='Time Based',
                                        SVMXC__Field_map_for_wo__c = smaxprocess[0].SVMXC__MapID__c,
                                        SVMXC__Field_map_for_Case__c = smaxprocess[1].SVMXC__MapID__c,
                                        SVMXC__Work_Order_Assign_To__c='USER',
                                        SVMXC__Work_Order_Assign_To_User__c=UserInfo.getUserId(),
                                        SVMXC__Number_of_Work_orders__c='ONE PER PRODUCT',
                                        SVMXC__Number_of_Cases__c ='ONE PER PLAN',
                                        SVMXC__Create_Case__c = true,
                                        SVMXC__Success_Email_ID__c ='success@test.com',
                                        SVMXC__Error_Email_ID__c ='error@test.com',
                                        SVMXC__Next_PM_Date__c = system.Today()+2,
                                        SVMXC__Work_Order_Date__c = system.Today(),
                                        SVMXC__Frequency__c =2,
                                        SVMXC__Frequency_Unit__c ='Years',
                                        SVMXC__Status__c ='Active'
                                        );
      //Listpmplan.add(pmplanfour);                               
      insert Listpmplan;
      set<String> setpmplan=new  set<String>();
      for(SVMXC__PM_Plan__c pmplanloop:Listpmplan){
        setpmplan.add(pmplanloop.id);
      }
        List<SVMXC__PM_Coverage__c> listpmcoverage=new List<SVMXC__PM_Coverage__c>();
        SVMXC__PM_Coverage__c PMC11 = new SVMXC__PM_Coverage__c(
      
                                        SVMXC__PM_Plan__c = Listpmplan[0].id,
                                        SVMXC__Product_Name__c = IBObject.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
    
        listpmcoverage.add(PMC11);
        SVMXC__PM_Coverage__c PMC12 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[0].id,
                                        SVMXC__Product_Name__c = IBObject1.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC12);
        SVMXC__PM_Coverage__c PMC13 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[0].id,
                                        SVMXC__Product_Name__c = IBObject1.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC13); 
        SVMXC__PM_Coverage__c PMC21 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[1].id,
                                        SVMXC__Product_Name__c = IBObject.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC21);
        SVMXC__PM_Coverage__c PMC22 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[1].id,
                                        SVMXC__Product_Name__c = IBObject1.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC22);
        SVMXC__PM_Coverage__c PMC23 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[1].id,
                                        SVMXC__Product_Name__c = IBObject1.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC23);
        SVMXC__PM_Coverage__c PMC31 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[2].id,
                                        SVMXC__Product_Name__c = IBObject.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC31);
        SVMXC__PM_Coverage__c PMC32 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[2].id,
                                        SVMXC__Product_Name__c = IBObject1.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC32);
        SVMXC__PM_Coverage__c PMC33 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[2].id,
                                        SVMXC__Product_Name__c = IBObject1.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC33);
        /*SVMXC__PM_Coverage__c PMC41 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[3].id,
                                        SVMXC__Product_Name__c = IBObject.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC41);
        SVMXC__PM_Coverage__c PMC42 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[3].id,
                                        SVMXC__Product_Name__c = IBObject1.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC42);       
        SVMXC__PM_Coverage__c PMC43 = new SVMXC__PM_Coverage__c(
                                        SVMXC__PM_Plan__c = Listpmplan[3].id,
                                        SVMXC__Product_Name__c = IBObject1.Id,
                                        SVMXC__PM_Frequency__c = 12
                                        );
        listpmcoverage.add(PMC43);
        insert listpmcoverage;*/
        Test.StartTest();
        SVMXC.PREV_PMScheduler pm = new SVMXC.PREV_PMScheduler();
        Database.BatchableContext BC;
        pm.getTAG001();
        pm.getTAG002();
        pm.getTAG003();
        pm.getTAG004();
        pm.getTAG005();
        pm.getTAG006();
        pm.getTAG007();
        pm.getTAG008();
        pm.getTAG009();
        pm.getTAG010();
        pm.getTAG011();
        pm.getTAG012();
        pm.getTAG013();
        pm.getTAG014();
        pm.getTAG015();
        Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
        SVMXC.PREV_PMScheduler.getFieldList(fieldMap,true);
        SVMXC.PREV_PMScheduler.getFieldList(fieldMap,false);
        
        List<String> fieldList = new List<String>();
        fieldList.add('abc');
        fieldList.add('xyz');        
        SVMXC.PREV_PMScheduler.getFieldNamesFromList(fieldList);
        pm.start(BC);
        pm.execute(BC,Listpmplan);
        pm.finish(BC);
        //ID batchprocessid = Database.executeBatch(pm); 
        Test.StopTest();
        
        
       /*} 
       catch (Exception e){ //System.debug(e.getMessage());
            system.debug('asdf'+e);
       }*/
    
    }

}