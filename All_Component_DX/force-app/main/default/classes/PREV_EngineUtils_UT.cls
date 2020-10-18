@isTest(seeAllData = true)
private class PREV_EngineUtils_UT 
{
    static testMethod void PREV_EngineUtils_Test1() 
    {
        //Data Creation
        Account objAcc = new Account(Name = 'TestAcc001');
        insert objAcc;
        system.assert(objAcc.Name != null);
        
        Product2 objProd1 = new Product2(Name = 'Desktop');
        insert objProd1;
        system.assert(objProd1.Name != null);
        
        SVMXC__Service_Contract__c objSCON = new SVMXC__Service_Contract__c();
        objSCON.Name = 'SCON001';
        objSCON.SVMXC__Active__c = true;
        objSCON.SVMXC__Company__c = objAcc.Id;
        objSCON.SVMXC__End_Date__c = date.today().addDays(365);
        objSCON.SVMXC__Start_Date__c = date.today().addDays(-100);
        insert objSCON;
        system.assert(objSCON.Name != null);
        
        List<SVMXC__Installed_Product__c> lstInstalledProd = new List<SVMXC__Installed_Product__c>();
        for(integer j=0; j<50; j++)
        {
            SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
            objIB.SVMXC__Company__c = objAcc.Id;
            objIB.SVMXC__Product__c = objProd1.Id;
            objIB.SVMXC__Serial_Lot_Number__c = 'IB-001';
            objIB.SVMXC__Service_Contract__c = objSCON.Id;
            objIB.Name = 'IB-001';
            lstInstalledProd.add(objIB);
        }
        insert lstInstalledProd;
        system.assert(lstInstalledProd.size() > 0);
        
        SVMXC__PM_Plan__c objPMPlan = new SVMXC__PM_Plan__c();
        objPMPlan.Name = 'SVMXTest_Plan';
        objPMPlan.SVMXC__Account__c = objAcc.Id;
        objPMPlan.SVMXC__Service_Contract__c = objSCON.Id;
        objPMPlan.SVMXC__Start_Date__c = date.today().addDays(-365);
        objPMPlan.SVMXC__End_Date__c = date.today().addDays(365);
        objPMPlan.SVMXC__Status__c = 'Active';
        insert objPMPlan;
        
        SVMXC__Task_Template__c objTaskTemplate = new SVMXC__Task_Template__c();
        objTaskTemplate.SVMXC__Priority__c = 'High';
        objTaskTemplate.SVMXC__Task_Title__c = 'Task Temp-001';
        objTaskTemplate.SVMXC__Template_Name__c = 'Task Temp-001';
        insert objTaskTemplate;
        
        list<SVMXC__Required_Part__c> lstPartsUsed = new list<SVMXC__Required_Part__c>();
        lstPartsUsed.add(new SVMXC__Required_Part__c (SVMXC__Product__c = objProd1.Id, SVMXC__Quantity__c = 10, SVMXC__Work_Order_Purpose__c = objTaskTemplate.Id ));
        insert lstPartsUsed;
        
        
        list<SVMXC__PM_Schedule_Definition__c> lstPMScheduleDef = new list<SVMXC__PM_Schedule_Definition__c>();
        for(integer j=1; j<3; j++)
        {
            SVMXC__PM_Schedule_Definition__c objPMScheduleDef = new SVMXC__PM_Schedule_Definition__c();
            objPMScheduleDef.SVMXC__PM_Plan__c = objPMPlan.Id;
            objPMScheduleDef.SVMXC__Schedule_Type__c = 'Time Based';
            objPMScheduleDef.SVMXC__Frequency__c = 1*j;
            objPMScheduleDef.SVMXC__Frequency_Unit__c = 'weeks';
            objPMScheduleDef.SVMXC__Work_Order_Purpose__c = objTaskTemplate.Id;
            lstPMScheduleDef.add(objPMScheduleDef);
        }
        insert lstPMScheduleDef;
        system.assert(lstPMScheduleDef.size() != null);
        
        list<SVMXC__PM_Schedule__c> lstSchedule = new list<SVMXC__PM_Schedule__c>();
        for(integer i=0; i<2; i++)
        {
            SVMXC__PM_Schedule__c objSchedule = new SVMXC__PM_Schedule__c();
            objSchedule.SVMXC__PM_Plan__c = objPMPlan.Id;
            objSchedule.SVMXC__Scheduled_On__c = date.today().addDays(i+1);
            objSchedule.SVMXC__PM_Schedule_Definition__c = lstPMScheduleDef[i].Id;
            lstSchedule.add(objSchedule);
        }
        insert lstSchedule;
        
        list<SVMXC__PM_Coverage__c> lstPMCvrg = new list<SVMXC__PM_Coverage__c>();
        for(integer j=0; j<50; j++)
        {
            SVMXC__PM_Coverage__c objPMCvrg = new SVMXC__PM_Coverage__c();
            objPMCvrg.SVMXC__PM_Plan__c = objPMPlan.Id;
            objPMCvrg.SVMXC__Product_Name__c = lstInstalledProd[j].Id;
            lstPMCvrg.add(objPMCvrg);
        }
        insert lstPMCvrg;
        system.assert(lstPMCvrg.size() > 0);
        
        SVMXC__Task_Template__c objTaskTmplt = new SVMXC__Task_Template__c();
        objTaskTmplt.SVMXC__Description__c = 'Test Task';
        objTaskTmplt.SVMXC__Priority__c = 'High';
        objTaskTmplt.SVMXC__Task_Title__c = 'Test 0001';
        objTaskTmplt.SVMXC__Template_Name__c = 'Test 0001';
        objTaskTmplt.SVMXC__Task_Template__c = objTaskTemplate.Id;
        objTaskTmplt.RecordTypeId = [Select Id From RecordType where SobjectType = 'SVMXC__Task_Template__c' AND Name='Tasks' AND IsActive = true Limit 1].Id;
        insert objTaskTmplt;
        
        
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        String ObjectMapping = '';
        String Fieldmapping = '';
        for(RecordType r : lstRecType)
        {  
            if(r.Name == 'Object Mapping')  
            ObjectMapping = r.id;
            if(r.Name == 'Field Mapping')
            Fieldmapping = r.id;    
        }
        
        SVMXC__ServiceMax_Processes__c ObjectMap = new SVMXC__ServiceMax_Processes__c();
        ObjectMap.RecordTypeId = ObjectMapping;
        ObjectMap.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Contract__c';
        ObjectMap.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        ObjectMap.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMap.SVMXC__Name__c = 'CUSTOMMAP0001';
        insert ObjectMap;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapList = new list<SVMXC__ServiceMax_Config_Data__c>();        
        SVMXC__ServiceMax_Config_Data__c FieldMap = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap.RecordTypeId = Fieldmapping;
        FieldMap.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap.SVMXC__Source_Field_Name__c = 'SVMXC__Company__c' ;
        FieldMap.SVMXC__Target_Field_Name__c = 'SVMXC__Company__c' ;
        FieldMapList.add(FieldMap); 
        insert FieldMapList;       
        
        SVMXC__ServiceMax_Processes__c ObjectMapWOtoCase = new SVMXC__ServiceMax_Processes__c();
        ObjectMapWOtoCase.RecordTypeId = ObjectMapping;
        ObjectMapWOtoCase.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ObjectMapWOtoCase.SVMXC__Target_Object_Name__c = 'Case';
        ObjectMapWOtoCase.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMapWOtoCase.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMapWOtoCase;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapListWOtoCase = new list<SVMXC__ServiceMax_Config_Data__c>();        
        FieldMapListWOtoCase.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapWOtoCase.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Billing_Type__c', SVMXC__Target_Field_Name__c = 'SVMXC__Billing_Type__c'));
        FieldMapListWOtoCase.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapWOtoCase.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Component__c', SVMXC__Target_Field_Name__c = 'SVMXC__Component__c'));
        upsert FieldMapListWOtoCase; 
        
        SVMXC__ServiceMax_Processes__c ObjectMapforReqParts = new SVMXC__ServiceMax_Processes__c();
        ObjectMapforReqParts.RecordTypeId = ObjectMapping;
        ObjectMapforReqParts.SVMXC__Source_Object_Name__c = 'SVMXC__Required_Part__c';
        ObjectMapforReqParts.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMapforReqParts.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMapforReqParts.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMapforReqParts;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapListforReqParts = new list<SVMXC__ServiceMax_Config_Data__c>();        
        FieldMapListforReqParts.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapforReqParts.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Quantity__c', SVMXC__Target_Field_Name__c = 'SVMXC__Billable_Quantity__c'));
        FieldMapListforReqParts.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapforReqParts.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Product__c', SVMXC__Target_Field_Name__c = 'SVMXC__Product__c'));
        upsert FieldMapListforReqParts;       
        
        SVMXC__ServiceMax_Processes__c ObjectMapForTask = new SVMXC__ServiceMax_Processes__c();
        ObjectMapForTask.RecordTypeId = ObjectMapping;
        ObjectMapForTask.SVMXC__Source_Object_Name__c = 'SVMXC__Task_Template__c';
        ObjectMapForTask.SVMXC__Target_Object_Name__c = 'Task';
        ObjectMapForTask.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMapForTask.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMapForTask;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapListForTask = new list<SVMXC__ServiceMax_Config_Data__c>();        
        FieldMapListForTask.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapForTask.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Priority__c', SVMXC__Target_Field_Name__c = 'Priority'));
        upsert FieldMapListForTask;
        
        RecordType PMProcess_Rtype = [select Id from RecordType where Name = 'PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c objPMProcess = new SVMXC__ServiceMax_Processes__c();
        objPMProcess.SVMXC__Name__c = 'PMProcess1-Test';
        objPMProcess.SVMXC__ProcessID__c = 'PMProcess1-Test';
        objPMProcess.SVMXC__Description__c = 'PMProcess1-Test';        
        objPMProcess.RecordTypeId = PMProcess_Rtype.Id;
        objPMProcess.SVMXC__Create_Work_Order__c = 'One per Plan';
        objPMProcess.SVMXC__Frequency__c = 1000;
        objPMProcess.SVMXC__Active__c = true;
        objPMProcess.SVMXC__Node_Parent__c = ObjectMap.Id;
        objPMProcess.SVMXC__Product_Match_Enabled__c = true;
        objPMProcess.SVMXC__Email_On_Error__c = 'a@b.com';
        objPMProcess.SVMXC__Target_Object_Name__c = 'Task';
        objPMProcess.SVMXC__Include_Parent__c = true;
        objPMProcess.SVMXC__Process__c = ObjectMapWOtoCase.Id;
        objPMProcess.SVMXC__Process1__c = ObjectMapForTask.Id;
        objPMProcess.SVMXC__Process2__c = ObjectMapforReqParts.id;
        objPMProcess.SVMXC__Assign_Case_To__c = 'User';
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Dispatcher';
        objPMProcess.SVMXC__Assign_To_Dispatcher__c = UserInfo.getUserId();
        objPMProcess.SVMXC__Case_Assign_To_User__c = UserInfo.getUserId();
        insert objPMProcess;  
        
        system.assert(objPMProcess.SVMXC__Name__c != NULL);
        
        test.startTest();
        PREV_EngineUtils objPMEngine = new PREV_EngineUtils();
        objPMEngine.getTag001();
        objPMEngine.getTag002();
        objPMEngine.getTag003();
        objPMEngine.getTag004();
        objPMEngine.getTag005();
        objPMEngine.getTag006();
        objPMEngine.getTag007();
        objPMEngine.getTag008();
        objPMEngine.getTag009();
        
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest objSFMRequest = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        objSFMRequest.valueMap = new list<SVMXC.INTF_WebservicesDef.SVMXMap>();
        
        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);

        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap2 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap2.key = 'PM_PLAN_RECORD';
        objSVMXMap2.record = objPMPlan;
        objSFMRequest.valueMap.add(objSVMXMap2);

        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('PM_SCHEDULE_RECORDID', lstSchedule[0].Id));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_CREATION_SETTING', 'true'));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_PRIORITY_SETTING', 'High'));

        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap4 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap4.key = 'PM_COVERAGE_LST';
        objSVMXMap4.data = lstPMCvrg;
        objSFMRequest.valueMap.add(objSVMXMap4);
        objPMEngine.createWorkOrders(objSFMRequest);
        test.stopTest();
        
    }
    
    static testMethod void PREV_EngineUtils_Test2() 
    {
        //Data Creation
        
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c();
        objTeam.Name = 'Team-1';
        insert objTeam;
        system.assert(objTeam.Name != NULL);
        
        SVMXC__Service_Group_Members__c objTech = new SVMXC__Service_Group_Members__c();
        objTech.Name = 'Test Tech';
        objTech.SVMXC__Service_Group__c = objTeam.Id;
        insert objTech;
        system.assert(objTech.Name != NULL);
        
        Account objAcc = new Account(Name = 'TestAcc001');
        objAcc.SVMXC__Preferred_Technician__c = objTech.Id;
        insert objAcc;
        system.assert(objAcc.Name != NULL);
        
        Product2 objProd1 = new Product2(Name = 'Desktop');
        insert objProd1;
        
        SVMXC__Service_Contract__c objSCON = new SVMXC__Service_Contract__c();
        objSCON.Name = 'SCON001';
        objSCON.SVMXC__Active__c = true;
        objSCON.SVMXC__Primary_Technician__c = objTech.Id;
        objSCON.SVMXC__Company__c = objAcc.Id;
        objSCON.SVMXC__End_Date__c = date.today().addDays(365);
        objSCON.SVMXC__Start_Date__c = date.today().addDays(-100);
        insert objSCON;
        
        SVMXC__PM_Plan__c objPMPlan = new SVMXC__PM_Plan__c();
        objPMPlan.Name = 'SVMXTest_Plan';
        objPMPlan.SVMXC__Start_Date__c = date.today().addDays(-365);
        objPMPlan.SVMXC__End_Date__c = date.today().addDays(365);
        objPMPlan.SVMXC__Status__c = 'Active';
        insert objPMPlan;
        
        RecordType PMProcess_Rtype = [select Id from RecordType where Name = 'PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c objPMProcess = new SVMXC__ServiceMax_Processes__c();
        objPMProcess.SVMXC__Name__c = 'PMProcess1-Test';
        objPMProcess.SVMXC__ProcessID__c = 'PMProcess1-Test';
        objPMProcess.RecordTypeId = PMProcess_Rtype.Id;
        objPMProcess.SVMXC__Create_Work_Order__c = 'One per Plan';
        objPMProcess.SVMXC__Frequency__c = 1000;
        objPMProcess.SVMXC__Active__c = true;
        objPMProcess.SVMXC__Email_On_Error__c = 'a@b.com';
        objPMProcess.SVMXC__Target_Object_Name__c = 'Task';
        objPMProcess.SVMXC__Assign_Case_To__c = 'User';
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Dispatcher';
        objPMProcess.SVMXC__Assign_To_Dispatcher__c = UserInfo.getUserId();
        objPMProcess.SVMXC__Case_Assign_To_User__c = UserInfo.getUserId();
        insert objPMProcess;  
        system.assert(objPMProcess.SVMXC__Name__c != NULL);
        
        test.startTest();
        PREV_EngineUtils objPMEngine = new PREV_EngineUtils();
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest objSFMRequest = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        objSFMRequest.valueMap = new list<SVMXC.INTF_WebservicesDef.SVMXMap>();
        
        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);

        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap2 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap2.key = 'PM_PLAN_RECORD';
        objSVMXMap2.record = objPMPlan;
        objSFMRequest.valueMap.add(objSVMXMap2);

        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('PM_SCHEDULE_RECORDID', objPMProcess.Id));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_CREATION_SETTING', 'true'));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_PRIORITY_SETTING', 'High'));

        objPMEngine.createWorkOrders(objSFMRequest);
        
        Map<String, sObject> mapCase = new Map<String, sObject>();
        Case objCase = new Case(Priority = 'High');
        insert objCase;
        mapCase.put(objCase.Id,(sObject) objCase);
        objPMEngine.populateCaseFlds(mapCase);
        
        
        Map<String, sObject> mapWO = new Map<String, sObject>();
        SVMXC__Service_Order__c objWO = new SVMXC__Service_Order__c(SVMXC__Priority__c = 'High');
        insert objWO;
        mapWO.put(objWO.Id,(sObject) objWO);
        objPMEngine.populateWorkOrderFlds(mapWO);
        
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Primary Technician';
        objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);
        objPMEngine.populateWorkOrderFlds(mapWO);
        
        objSCON.SVMXC__Primary_Technician__c = null;
        update objSCON;
        
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Primary Technician';
        objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);
        objPMEngine.populateWorkOrderFlds(mapWO);
        
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        objPMProcess.SVMXC__Assign_To_Technician__c = objTech.Id;
        objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);
        objPMEngine.populateWorkOrderFlds(mapWO);
        
        
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Team';
        objPMProcess.SVMXC__Assign_To_Service_Team__c = objTeam.Id;
        objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);
        objPMEngine.populateWorkOrderFlds(mapWO);
        test.stopTest();
    }
    
     static testMethod void PREV_EngineUtils_Test3() 
    {
        //Data Creation
        Account objAcc = new Account(Name = 'TestAcc001');
        insert objAcc;
        
        Product2 objProd1 = new Product2(Name = 'Desktop');
        insert objProd1;
        
        SVMXC__Service_Contract__c objSCON = new SVMXC__Service_Contract__c();
        objSCON.Name = 'SCON001';
        objSCON.SVMXC__Active__c = true;
        objSCON.SVMXC__Company__c = objAcc.Id;
        objSCON.SVMXC__End_Date__c = date.today().addDays(365);
        objSCON.SVMXC__Start_Date__c = date.today().addDays(-100);
        insert objSCON;
        
        List<SVMXC__Installed_Product__c> lstInstalledProd = new List<SVMXC__Installed_Product__c>();
        for(integer j=0; j<50; j++)
        {
            SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
            objIB.SVMXC__Company__c = objAcc.Id;
            objIB.SVMXC__Product__c = objProd1.Id;
            objIB.SVMXC__Serial_Lot_Number__c = 'IB-001';
            objIB.SVMXC__Service_Contract__c = objSCON.Id;
            objIB.Name = 'IB-001';
            lstInstalledProd.add(objIB);
        }
        insert lstInstalledProd;
        
        SVMXC__PM_Plan__c objPMPlan = new SVMXC__PM_Plan__c();
        objPMPlan.Name = 'SVMXTest_Plan';
        objPMPlan.SVMXC__Account__c = objAcc.Id;
        objPMPlan.SVMXC__Service_Contract__c = objSCON.Id;
        objPMPlan.SVMXC__Start_Date__c = date.today().addDays(-365);
        objPMPlan.SVMXC__End_Date__c = date.today().addDays(365);
        objPMPlan.SVMXC__Status__c = 'Active';
        insert objPMPlan;
        
        SVMXC__Task_Template__c objTaskTemplate = new SVMXC__Task_Template__c();
        objTaskTemplate.SVMXC__Priority__c = 'High';
        objTaskTemplate.SVMXC__Task_Title__c = 'Task Temp-001';
        objTaskTemplate.SVMXC__Template_Name__c = 'Task Temp-001';
        insert objTaskTemplate;
        
        list<SVMXC__Required_Part__c> lstPartsUsed = new list<SVMXC__Required_Part__c>();
        lstPartsUsed.add(new SVMXC__Required_Part__c (SVMXC__Product__c = objProd1.Id, SVMXC__Quantity__c = 10, SVMXC__Work_Order_Purpose__c = objTaskTemplate.Id ));
        insert lstPartsUsed;
        
        
        list<SVMXC__PM_Schedule_Definition__c> lstPMScheduleDef = new list<SVMXC__PM_Schedule_Definition__c>();
        for(integer j=1; j<3; j++)
        {
            SVMXC__PM_Schedule_Definition__c objPMScheduleDef = new SVMXC__PM_Schedule_Definition__c();
            objPMScheduleDef.SVMXC__PM_Plan__c = objPMPlan.Id;
            objPMScheduleDef.SVMXC__Schedule_Type__c = 'Time Based';
            objPMScheduleDef.SVMXC__Frequency__c = 1*j;
            objPMScheduleDef.SVMXC__Frequency_Unit__c = 'weeks';
            objPMScheduleDef.SVMXC__Work_Order_Purpose__c = objTaskTemplate.Id;
            lstPMScheduleDef.add(objPMScheduleDef);
        }
        insert lstPMScheduleDef;
        system.assert(lstPMScheduleDef.size() != null);
        
        list<SVMXC__PM_Schedule__c> lstSchedule = new list<SVMXC__PM_Schedule__c>();
        for(integer i=0; i<2; i++)
        {
            SVMXC__PM_Schedule__c objSchedule = new SVMXC__PM_Schedule__c();
            objSchedule.SVMXC__PM_Plan__c = objPMPlan.Id;
            objSchedule.SVMXC__Scheduled_On__c = date.today().addDays(i+1);
            objSchedule.SVMXC__PM_Schedule_Definition__c = lstPMScheduleDef[i].Id;
            lstSchedule.add(objSchedule);
        }
        insert lstSchedule;
        
        list<SVMXC__PM_Coverage__c> lstPMCvrg = new list<SVMXC__PM_Coverage__c>();
        for(integer j=0; j<50; j++)
        {
            SVMXC__PM_Coverage__c objPMCvrg = new SVMXC__PM_Coverage__c();
            objPMCvrg.SVMXC__PM_Plan__c = objPMPlan.Id;
            objPMCvrg.SVMXC__Product_Name__c = lstInstalledProd[j].Id;
            lstPMCvrg.add(objPMCvrg);
        }
        insert lstPMCvrg;
        
        SVMXC__Task_Template__c objTaskTmplt = new SVMXC__Task_Template__c();
        objTaskTmplt.SVMXC__Description__c = 'Test Task';
        objTaskTmplt.SVMXC__Priority__c = 'High';
        objTaskTmplt.SVMXC__Task_Title__c = 'Test 0001';
        objTaskTmplt.SVMXC__Template_Name__c = 'Test 0001';
        objTaskTmplt.SVMXC__Task_Template__c = objTaskTemplate.Id;
        objTaskTmplt.RecordTypeId = [Select Id From RecordType where SobjectType = 'SVMXC__Task_Template__c' AND Name='Tasks' AND IsActive = true Limit 1].Id;
        insert objTaskTmplt;
        
        
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        String ObjectMapping = '';
        String Fieldmapping = '';
        for(RecordType r : lstRecType)
        {  
            if(r.Name == 'Object Mapping')  
            ObjectMapping = r.id;
            if(r.Name == 'Field Mapping')
            Fieldmapping = r.id;    
        }
        
        SVMXC__ServiceMax_Processes__c ObjectMap = new SVMXC__ServiceMax_Processes__c();
        ObjectMap.RecordTypeId = ObjectMapping;
        ObjectMap.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        ObjectMap.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        ObjectMap.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMap.SVMXC__Name__c = 'CUSTOMMAP0001';
        insert ObjectMap;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapList = new list<SVMXC__ServiceMax_Config_Data__c>();        
        SVMXC__ServiceMax_Config_Data__c FieldMap = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap.RecordTypeId = Fieldmapping;
        FieldMap.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap.SVMXC__Source_Field_Name__c = 'SVMXC__Company__c' ;
        FieldMap.SVMXC__Target_Field_Name__c = 'SVMXC__Company__c' ;
        FieldMapList.add(FieldMap); 
        insert FieldMapList;       
        
        SVMXC__ServiceMax_Processes__c ObjectMapWOtoCase = new SVMXC__ServiceMax_Processes__c();
        ObjectMapWOtoCase.RecordTypeId = ObjectMapping;
        ObjectMapWOtoCase.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ObjectMapWOtoCase.SVMXC__Target_Object_Name__c = 'Case';
        ObjectMapWOtoCase.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMapWOtoCase.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMapWOtoCase;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapListWOtoCase = new list<SVMXC__ServiceMax_Config_Data__c>();        
        FieldMapListWOtoCase.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapWOtoCase.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Billing_Type__c', SVMXC__Target_Field_Name__c = 'SVMXC__Billing_Type__c'));
        FieldMapListWOtoCase.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapWOtoCase.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Component__c', SVMXC__Target_Field_Name__c = 'SVMXC__Component__c'));
        upsert FieldMapListWOtoCase; 
        
        SVMXC__ServiceMax_Processes__c ObjectMapforReqParts = new SVMXC__ServiceMax_Processes__c();
        ObjectMapforReqParts.RecordTypeId = ObjectMapping;
        ObjectMapforReqParts.SVMXC__Source_Object_Name__c = 'SVMXC__Required_Part__c';
        ObjectMapforReqParts.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMapforReqParts.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMapforReqParts.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMapforReqParts;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapListforReqParts = new list<SVMXC__ServiceMax_Config_Data__c>();        
        FieldMapListforReqParts.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapforReqParts.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Quantity__c', SVMXC__Target_Field_Name__c = 'SVMXC__Billable_Quantity__c'));
        FieldMapListforReqParts.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapforReqParts.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Product__c', SVMXC__Target_Field_Name__c = 'SVMXC__Product__c'));
        upsert FieldMapListforReqParts;       
        
        SVMXC__ServiceMax_Processes__c ObjectMapForTask = new SVMXC__ServiceMax_Processes__c();
        ObjectMapForTask.RecordTypeId = ObjectMapping;
        ObjectMapForTask.SVMXC__Source_Object_Name__c = 'SVMXC__Task_Template__c';
        ObjectMapForTask.SVMXC__Target_Object_Name__c = 'Task';
        ObjectMapForTask.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMapForTask.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMapForTask;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapListForTask = new list<SVMXC__ServiceMax_Config_Data__c>();        
        FieldMapListForTask.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapForTask.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Priority__c', SVMXC__Target_Field_Name__c = 'Priority'));
        upsert FieldMapListForTask;
        
        RecordType PMProcess_Rtype = [select Id from RecordType where Name = 'PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c objPMProcess = new SVMXC__ServiceMax_Processes__c();
        objPMProcess.SVMXC__Name__c = 'PMProcess1-Test';
        objPMProcess.SVMXC__ProcessID__c = 'PMProcess1-Test';
        objPMProcess.SVMXC__Description__c = 'PMProcess1-Test';        
        objPMProcess.RecordTypeId = PMProcess_Rtype.Id;
        objPMProcess.SVMXC__Create_Work_Order__c = 'One per Product';
        objPMProcess.SVMXC__Frequency__c = 1000;
        objPMProcess.SVMXC__Active__c = true;
        objPMProcess.SVMXC__Node_Parent__c = ObjectMap.Id;
        objPMProcess.SVMXC__Product_Match_Enabled__c = true;
        objPMProcess.SVMXC__Email_On_Error__c = 'a@b.com';
        objPMProcess.SVMXC__Target_Object_Name__c = 'Task';
        objPMProcess.SVMXC__Include_Parent__c = true;
        objPMProcess.SVMXC__Process__c = ObjectMapWOtoCase.Id;
        objPMProcess.SVMXC__Process1__c = ObjectMapForTask.Id;
        objPMProcess.SVMXC__Process2__c = ObjectMapforReqParts.id;
        objPMProcess.SVMXC__Assign_Case_To__c = 'User';
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Dispatcher';
        objPMProcess.SVMXC__Assign_To_Dispatcher__c = UserInfo.getUserId();
        objPMProcess.SVMXC__Case_Assign_To_User__c = UserInfo.getUserId();
        insert objPMProcess;  
        system.assert(objPMProcess.SVMXC__Name__c != NULL);
        
        PREV_EngineUtils objPMEngine = new PREV_EngineUtils();
        
        test.startTest();
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest objSFMRequest = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        objSFMRequest.valueMap = new list<SVMXC.INTF_WebservicesDef.SVMXMap>();
        
        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);

        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap2 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap2.key = 'PM_PLAN_RECORD';
        objSVMXMap2.record = objPMPlan;
        objSFMRequest.valueMap.add(objSVMXMap2);

        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('PM_SCHEDULE_RECORDID', lstSchedule[0].Id));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_CREATION_SETTING', 'true'));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_PRIORITY_SETTING', 'High'));

        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap4 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap4.key = 'PM_COVERAGE_LST';
        objSVMXMap4.data = lstPMCvrg;
        objSFMRequest.valueMap.add(objSVMXMap4);
        
        objPMEngine.createWorkOrders(objSFMRequest);
        test.stopTest();
    }
    
    static testMethod void PREV_EngineUtils_Test4() 
    {
        //Data Creation
        
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c();
        objTeam.Name = 'Team-1';
        insert objTeam;
        
        SVMXC__Service_Group_Members__c objTech = new SVMXC__Service_Group_Members__c();
        objTech.Name = 'Test Tech';
        objTech.SVMXC__Service_Group__c = objTeam.Id;
        insert objTech;
        
        Account objAcc = new Account(Name = 'TestAcc001');
        objAcc.SVMXC__Preferred_Technician__c = objTech.Id;
        insert objAcc;
        
        Product2 objProd1 = new Product2(Name = 'Desktop');
        insert objProd1;
        
        SVMXC__Service_Contract__c objSCON = new SVMXC__Service_Contract__c();
        objSCON.Name = 'SCON001';
        objSCON.SVMXC__Active__c = true;
        objSCON.SVMXC__Primary_Technician__c = objTech.Id;
        objSCON.SVMXC__Company__c = objAcc.Id;
        objSCON.SVMXC__End_Date__c = date.today().addDays(365);
        objSCON.SVMXC__Start_Date__c = date.today().addDays(-100);
        insert objSCON;
        
        system.assert(objAcc.Name != NULL);
        system.assert(objProd1.Name != NULL);
        system.assert(objSCON.Name != NULL);
        
        SVMXC__PM_Plan__c objPMPlan = new SVMXC__PM_Plan__c();
        objPMPlan.Name = 'SVMXTest_Plan';
        objPMPlan.SVMXC__Start_Date__c = date.today().addDays(-365);
        objPMPlan.SVMXC__End_Date__c = date.today().addDays(365);
        objPMPlan.SVMXC__Status__c = 'Active';
        insert objPMPlan;
        
        RecordType PMProcess_Rtype = [select Id from RecordType where Name = 'PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c objPMProcess = new SVMXC__ServiceMax_Processes__c();
        objPMProcess.SVMXC__Name__c = 'PMProcess1-Test';
        objPMProcess.SVMXC__ProcessID__c = 'PMProcess1-Test';
        objPMProcess.RecordTypeId = PMProcess_Rtype.Id;
        objPMProcess.SVMXC__Create_Work_Order__c = 'One per Product';
        objPMProcess.SVMXC__Frequency__c = 1000;
        objPMProcess.SVMXC__Active__c = true;
        objPMProcess.SVMXC__Email_On_Error__c = 'a@b.com';
        objPMProcess.SVMXC__Target_Object_Name__c = 'Task';
        objPMProcess.SVMXC__Assign_Case_To__c = 'User';
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Dispatcher';
        objPMProcess.SVMXC__Assign_To_Dispatcher__c = UserInfo.getUserId();
        objPMProcess.SVMXC__Case_Assign_To_User__c = UserInfo.getUserId();
        insert objPMProcess;  
        
        system.assert(objPMProcess.SVMXC__Name__c != NULL);
        
        test.startTest();
        PREV_EngineUtils objPMEngine = new PREV_EngineUtils();
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest objSFMRequest = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        objSFMRequest.valueMap = new list<SVMXC.INTF_WebservicesDef.SVMXMap>();
        
        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);

        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap2 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap2.key = 'PM_PLAN_RECORD';
        objSVMXMap2.record = objPMPlan;
        objSFMRequest.valueMap.add(objSVMXMap2);

        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('PM_SCHEDULE_RECORDID', objPMProcess.Id));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_CREATION_SETTING', 'true'));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_PRIORITY_SETTING', 'High'));

        objPMEngine.createWorkOrders(objSFMRequest);
        
        Map<String, sObject> mapCase = new Map<String, sObject>();
        Case objCase = new Case(Priority = 'High');
        insert objCase;
        mapCase.put(objCase.Id,(sObject) objCase);
        objPMEngine.populateCaseFlds(mapCase);
        
        
        Map<String, sObject> mapWO = new Map<String, sObject>();
        SVMXC__Service_Order__c objWO = new SVMXC__Service_Order__c(SVMXC__Priority__c = 'High');
        insert objWO;
        mapWO.put(objWO.Id,(sObject) objWO);
        objPMEngine.populateWorkOrderFlds(mapWO);
        
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Primary Technician';
        objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);
        objPMEngine.populateWorkOrderFlds(mapWO);
        
        objSCON.SVMXC__Primary_Technician__c = null;
        update objSCON;
        
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Primary Technician';
        objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);
        objPMEngine.populateWorkOrderFlds(mapWO);
        
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Technician';
        objPMProcess.SVMXC__Assign_To_Technician__c = objTech.Id;
        objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);
        objPMEngine.populateWorkOrderFlds(mapWO);
        
        
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Team';
        objPMProcess.SVMXC__Assign_To_Service_Team__c = objTeam.Id;
        objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);
        objPMEngine.populateWorkOrderFlds(mapWO);
        test.stopTest();
    }
    static testMethod void PREV_EngineUtils_Test5() 
    {
        //Data Creation
        Account objAcc = new Account(Name = 'TestAcc001');
        insert objAcc;
        
        SVMXC__Site__c loc = new SVMXC__Site__c();
        loc.SVMXC__Account__c = objAcc.Id;
        loc.SVMXC__City__c = 'Pleasaton';
        loc.SVMXC__State__c = 'CA';
        loc.SVMXC__Country__c = 'United States';
        loc.SVMXC__Street__c = '5th Avenue';  
        loc.SVMXC__Zip__c = '32809';
        loc.SVMXC__Latitude__c = 28.433887;
        loc.SVMXC__Longitude__c = -81.448922;
        insert loc;
        
        Product2 objProd1 = new Product2(Name = 'Desktop');
        insert objProd1;
        
        SVMXC__Service_Contract__c objSCON = new SVMXC__Service_Contract__c();
        objSCON.Name = 'SCON001';
        objSCON.SVMXC__Active__c = true;
        objSCON.SVMXC__Company__c = objAcc.Id;
        objSCON.SVMXC__End_Date__c = date.today().addDays(365);
        objSCON.SVMXC__Start_Date__c = date.today().addDays(-100);
        insert objSCON;
        
        system.assert(objAcc.Name != NULL);
        system.assert(objProd1.Name != NULL);
        system.assert(objSCON.Name != NULL);
        
        List<SVMXC__Installed_Product__c> lstInstalledProd = new List<SVMXC__Installed_Product__c>();
        for(integer j=0; j<50; j++)
        {
            SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
            objIB.SVMXC__Company__c = objAcc.Id;
            objIB.SVMXC__Product__c = objProd1.Id;
            objIB.SVMXC__Serial_Lot_Number__c = 'IB-001';
            objIB.SVMXC__Service_Contract__c = objSCON.Id;
            objIB.Name = 'IB-001';
            lstInstalledProd.add(objIB);
        }
        insert lstInstalledProd;
        
        SVMXC__PM_Plan__c objPMPlan = new SVMXC__PM_Plan__c();
        objPMPlan.Name = 'SVMXTest_Plan';
        objPMPlan.SVMXC__Account__c = objAcc.Id;
        objPMPlan.SVMXC__Service_Contract__c = objSCON.Id;
        objPMPlan.SVMXC__Start_Date__c = date.today().addDays(-365);
        objPMPlan.SVMXC__End_Date__c = date.today().addDays(365);
        objPMPlan.SVMXC__Status__c = 'Active';
        objPMPlan.SVMXC__SM_Adjustment_Activity_Date__c = 'SVMXC__Completed_Date_Time__c';
        objPMPlan.SVMXC__SM_Activity_Date_To_Consider__c = 'First Activity';
        objPMPlan.SVMXC__SM_Adjustment_Type__c = 'Fixed';
        objPMPlan.SVMXC__SM_Adjustment_Unit__c = 'Weeks';
        objPMPlan.SVMXC__SM_Adjustment_Value__c = 1;
        objPMPlan.SVMXC__SM_Adjustment_Min__c = 3;
        objPMPlan.SVMXC__SM_Dynamic_Time_Based__c = true;
        objPMPlan.SVMXC__Location__c = loc.Id;
        
        insert objPMPlan;
        
        SVMXC__Task_Template__c objTaskTemplate = new SVMXC__Task_Template__c();
        objTaskTemplate.SVMXC__Priority__c = 'High';
        objTaskTemplate.SVMXC__Task_Title__c = 'Task Temp-001';
        objTaskTemplate.SVMXC__Template_Name__c = 'Task Temp-001';
        insert objTaskTemplate;
        
        list<SVMXC__Required_Part__c> lstPartsUsed = new list<SVMXC__Required_Part__c>();
        lstPartsUsed.add(new SVMXC__Required_Part__c (SVMXC__Product__c = objProd1.Id, SVMXC__Quantity__c = 10, SVMXC__Work_Order_Purpose__c = objTaskTemplate.Id ));
        insert lstPartsUsed;
        
        
        list<SVMXC__PM_Schedule_Definition__c> lstPMScheduleDef = new list<SVMXC__PM_Schedule_Definition__c>();
        for(integer j=1; j<3; j++)
        {
            SVMXC__PM_Schedule_Definition__c objPMScheduleDef = new SVMXC__PM_Schedule_Definition__c();
            objPMScheduleDef.SVMXC__PM_Plan__c = objPMPlan.Id;
            objPMScheduleDef.SVMXC__Schedule_Type__c = 'Time Based';
            objPMScheduleDef.SVMXC__Frequency__c = 1*j;
            objPMScheduleDef.SVMXC__Frequency_Unit__c = 'weeks';
            objPMScheduleDef.SVMXC__Work_Order_Purpose__c = objTaskTemplate.Id;
            lstPMScheduleDef.add(objPMScheduleDef);
        }
        insert lstPMScheduleDef;
        system.assert(lstPMScheduleDef.size() != null);
        
        list<SVMXC__PM_Schedule__c> lstSchedule = new list<SVMXC__PM_Schedule__c>();
        for(integer i=0; i<2; i++)
        {
            SVMXC__PM_Schedule__c objSchedule = new SVMXC__PM_Schedule__c();
            objSchedule.SVMXC__PM_Plan__c = objPMPlan.Id;
            objSchedule.SVMXC__Scheduled_On__c = date.today().addDays(i+1);
 			objSchedule.SVMXC__Last_Run_Date__c =  date.today().addDays(-365);
            objSchedule.SVMXC__PM_Schedule_Definition__c = lstPMScheduleDef[i].Id;
            lstSchedule.add(objSchedule);
        }
        insert lstSchedule;
        
        SVMXC__Service_Order__c workOrderRec = new SVMXC__Service_Order__c();
        workOrderRec.SVMXC__Order_Status__c = 'New';
        workOrderRec.SVMXC__Preferred_Start_Time__c = System.today() - 7;
        workOrderRec.SVMXC__Completed_Date_Time__c = System.today() - 5;
        insert workOrderRec;
        
        SVMXC__PM_History__c historyRec = new SVMXC__PM_History__c();
        historyRec.SVMXC__PM_Plan__c = objPMPlan.Id;
        historyRec.SVMXC__PM_Schedule_Definition__c = (!lstPMScheduleDef.isEmpty())?lstPMScheduleDef[0].Id:null;
        historyRec.SVMXC__Work_Order_Created_on__c = System.today()-7;
        historyRec.SVMXC__Work_Order__c = workOrderRec.Id;
        insert historyRec;
            
        list<SVMXC__PM_Coverage__c> lstPMCvrg = new list<SVMXC__PM_Coverage__c>();
        for(integer j=0; j<50; j++)
        {
            SVMXC__PM_Coverage__c objPMCvrg = new SVMXC__PM_Coverage__c();
            objPMCvrg.SVMXC__PM_Plan__c = objPMPlan.Id;
            objPMCvrg.SVMXC__Product_Name__c = lstInstalledProd[j].Id;
            lstPMCvrg.add(objPMCvrg);
        }
        insert lstPMCvrg;
        
        SVMXC__Task_Template__c objTaskTmplt = new SVMXC__Task_Template__c();
        objTaskTmplt.SVMXC__Description__c = 'Test Task';
        objTaskTmplt.SVMXC__Priority__c = 'High';
        objTaskTmplt.SVMXC__Task_Title__c = 'Test 0001';
        objTaskTmplt.SVMXC__Template_Name__c = 'Test 0001';
        objTaskTmplt.SVMXC__Task_Template__c = objTaskTemplate.Id;
        objTaskTmplt.RecordTypeId = [Select Id From RecordType where SobjectType = 'SVMXC__Task_Template__c' AND Name='Tasks' AND IsActive = true Limit 1].Id;
        insert objTaskTmplt;
        
        
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        String ObjectMapping = '';
        String Fieldmapping = '';
        for(RecordType r : lstRecType)
        {  
            if(r.Name == 'Object Mapping')  
            ObjectMapping = r.id;
            if(r.Name == 'Field Mapping')
            Fieldmapping = r.id;    
        }
        
        SVMXC__ServiceMax_Processes__c ObjectMap = new SVMXC__ServiceMax_Processes__c();
        ObjectMap.RecordTypeId = ObjectMapping;
        ObjectMap.SVMXC__Source_Object_Name__c = 'Account';
        ObjectMap.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        ObjectMap.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMap.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMap;
    
        list<SVMXC__ServiceMax_Config_Data__c> FieldMapList = new list<SVMXC__ServiceMax_Config_Data__c>();        
        SVMXC__ServiceMax_Config_Data__c FieldMap = new SVMXC__ServiceMax_Config_Data__c();
        FieldMap.RecordTypeId = Fieldmapping;
        FieldMap.SVMXC__MapID__c = ObjectMap.Id ;
        FieldMap.SVMXC__Source_Field_Name__c = 'SVMXC__Preferred_Technician__c' ;
        FieldMap.SVMXC__Target_Field_Name__c = 'SVMXC__Preferred_Technician__c' ;
        FieldMapList.add(FieldMap); 
        upsert FieldMapList; 
        
        SVMXC__ServiceMax_Processes__c ObjectMapWOtoCase = new SVMXC__ServiceMax_Processes__c();
        ObjectMapWOtoCase.RecordTypeId = ObjectMapping;
        ObjectMapWOtoCase.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ObjectMapWOtoCase.SVMXC__Target_Object_Name__c = 'Case';
        ObjectMapWOtoCase.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMapWOtoCase.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMapWOtoCase;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapListWOtoCase = new list<SVMXC__ServiceMax_Config_Data__c>();        
        FieldMapListWOtoCase.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapWOtoCase.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Billing_Type__c', SVMXC__Target_Field_Name__c = 'SVMXC__Billing_Type__c'));
        FieldMapListWOtoCase.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapWOtoCase.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Component__c', SVMXC__Target_Field_Name__c = 'SVMXC__Component__c'));
        upsert FieldMapListWOtoCase; 
        
        SVMXC__ServiceMax_Processes__c ObjectMapforReqParts = new SVMXC__ServiceMax_Processes__c();
        ObjectMapforReqParts.RecordTypeId = ObjectMapping;
        ObjectMapforReqParts.SVMXC__Source_Object_Name__c = 'SVMXC__Required_Part__c';
        ObjectMapforReqParts.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        ObjectMapforReqParts.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMapforReqParts.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMapforReqParts;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapListforReqParts = new list<SVMXC__ServiceMax_Config_Data__c>();        
        FieldMapListforReqParts.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapforReqParts.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Quantity__c', SVMXC__Target_Field_Name__c = 'SVMXC__Billable_Quantity__c'));
        FieldMapListforReqParts.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapforReqParts.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Product__c', SVMXC__Target_Field_Name__c = 'SVMXC__Product__c'));
        upsert FieldMapListforReqParts;       
        
        SVMXC__ServiceMax_Processes__c ObjectMapForTask = new SVMXC__ServiceMax_Processes__c();
        ObjectMapForTask.RecordTypeId = ObjectMapping;
        ObjectMapForTask.SVMXC__Source_Object_Name__c = 'SVMXC__Task_Template__c';
        ObjectMapForTask.SVMXC__Target_Object_Name__c = 'Task';
        ObjectMapForTask.SVMXC__MapID__c = 'CUSTOMMAP0001';
        ObjectMapForTask.SVMXC__Name__c = 'CUSTOMMAP0001';
        upsert ObjectMapForTask;

        list<SVMXC__ServiceMax_Config_Data__c> FieldMapListForTask = new list<SVMXC__ServiceMax_Config_Data__c>();        
        FieldMapListForTask.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Fieldmapping, SVMXC__MapID__c = ObjectMapForTask.Id, SVMXC__Source_Field_Name__c = 'SVMXC__Priority__c', SVMXC__Target_Field_Name__c = 'Priority'));
        upsert FieldMapListForTask;
        
        RecordType PMProcess_Rtype = [select Id from RecordType where Name = 'PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        SVMXC__ServiceMax_Processes__c objPMProcess = new SVMXC__ServiceMax_Processes__c();
        objPMProcess.SVMXC__Name__c = 'PMProcess1-Test';
        objPMProcess.SVMXC__ProcessID__c = 'PMProcess1-Test';
        objPMProcess.SVMXC__Description__c = 'PMProcess1-Test';        
        objPMProcess.RecordTypeId = PMProcess_Rtype.Id;
        objPMProcess.SVMXC__Create_Work_Order__c = 'One per Plan';
        objPMProcess.SVMXC__Frequency__c = 1000;
        objPMProcess.SVMXC__Active__c = true;
        objPMProcess.SVMXC__Node_Parent__c = ObjectMap.Id;
        objPMProcess.SVMXC__Product_Match_Enabled__c = true;
        objPMProcess.SVMXC__Email_On_Error__c = 'a@b.com';
        objPMProcess.SVMXC__Target_Object_Name__c = 'Task';
        objPMProcess.SVMXC__Include_Parent__c = true;
        objPMProcess.SVMXC__Process__c = ObjectMapWOtoCase.Id;
        objPMProcess.SVMXC__Process1__c = ObjectMapForTask.Id;
        objPMProcess.SVMXC__Process2__c = ObjectMapforReqParts.id;
        objPMProcess.SVMXC__Assign_Case_To__c = 'User';
        objPMProcess.SVMXC__Assign_Work_Order_To__c = 'Dispatcher';
        objPMProcess.SVMXC__Assign_To_Dispatcher__c = UserInfo.getUserId();
        objPMProcess.SVMXC__Case_Assign_To_User__c = UserInfo.getUserId();
        insert objPMProcess;  
        
        test.startTest();
        PREV_EngineUtils objPMEngine = new PREV_EngineUtils();
        
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest objSFMRequest = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        objSFMRequest.valueMap = new list<SVMXC.INTF_WebservicesDef.SVMXMap>();
        
        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap1 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap1.key = 'PM_PROCESS_RECORD';
        objSVMXMap1.record = objPMProcess;
        objSFMRequest.valueMap.add(objSVMXMap1);

        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap2 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap2.key = 'PM_PLAN_RECORD';
        objSVMXMap2.record = objPMPlan;
        objSFMRequest.valueMap.add(objSVMXMap2);

        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('PM_SCHEDULE_RECORDID', lstSchedule[0].Id));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_CREATION_SETTING', 'true'));
        objSFMRequest.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('TASK_PRIORITY_SETTING', 'High'));

        SVMXC.INTF_WebservicesDef.SVMXMap objSVMXMap4 = new SVMXC.INTF_WebservicesDef.SVMXMap();
        objSVMXMap4.key = 'PM_COVERAGE_LST';
        objSVMXMap4.data = lstPMCvrg;
        objSFMRequest.valueMap.add(objSVMXMap4);
        objPMEngine.createWorkOrders(objSFMRequest);
        test.stopTest();
    }
    

}