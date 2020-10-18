@isTest(SeeAllData=true)
private class EVER_Entitlement_Utils_UT 
{
    static testMethod void Entitlement_Utils_Test() 
    {
        
        Account objAcc = new Account(Name = 'TestAcc001');
        insert objAcc;
        system.assert(objAcc.Name != null);
        
        SVMXC__Service_Contract__c objSCON = new SVMXC__Service_Contract__c();
        objSCON.Name = 'SCON001';
        objSCON.SVMXC__Active__c = true;
        objSCON.SVMXC__Company__c = objAcc.Id;
        objSCON.SVMXC__End_Date__c = date.today().addDays(10);
        objSCON.SVMXC__Start_Date__c = date.today().addDays(-2);
        insert objSCON;
        system.assert(objSCON.Name != null);
        
        list<Case> lstCase = new list<Case>();
        Case objCase = new Case();
        objCase = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', SVMXC__Service_Contract__c = objSCON.Id);
        Case objCase1 = new Case();
        objCase1 = new Case(Status ='New', Priority = 'High', Origin = 'Phone', SVMXC__Service_Contract__c = objSCON.Id);
        lstCase.add(objCase);
        lstCase.add(objCase1);
        insert lstCase;
        system.assert(objCase1.Status != null);
        system.assert(objCase1.Priority != null);
        system.assert(lstCase != null);
        
        Map<string,sObject> mapCase = new Map<string,sObject>();
        mapCase.put(objCase.Id, (sObject)objCase); 
        
        list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c objWorkOrd = new SVMXC__Service_Order__c();
        objWorkOrd.SVMXC__City__c = 'Bangalore';
        objWorkOrd.SVMXC__Order_Status__c = 'OPEN';
        objWorkOrd.SVMXC__Service_Contract__c = objSCON.Id;
        lstWorkOrder.add(objWorkOrd);
        insert lstWorkOrder;
        system.assert(objWorkOrd.SVMXC__Order_Status__c != null);
        system.assert(objWorkOrd.SVMXC__City__c != null);
        
        Map<string,sObject> mapWorkOrd = new Map<string,sObject>();
        mapWorkOrd.put(objWorkOrd.Id, (sObject)objWorkOrd); 
        
        RecordType[] array_Sobj = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
        RecordType[] ConfigDataRtype = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' ];
        
        SVMXC__ServiceMax_Processes__c process_Obj = new SVMXC__ServiceMax_Processes__c();
        process_Obj.RecordTypeId=array_Sobj[0].Id;
        process_Obj.SVMXC__Name__c='NamedExpression';
        process_Obj.SVMXC__Rule_Type__c = 'Named Expression';
        process_Obj.SVMXC__Sequence__c  = 1;
        process_Obj.SVMXC__SettingId__c='expid001';
        process_Obj.SVMXC__Source_Object_Name__c='SVMXC__Site__c';
        process_Obj.SVMXC__Advance_Expression__c = '';
        process_Obj.SVMXC__ProcessID__c = 'INV001_Process';
        insert process_Obj;
        system.assert(process_Obj.SVMXC__Name__c != null);
        
        SVMXC__ServiceMax_Config_Data__c svmx_configData_Obj = new SVMXC__ServiceMax_Config_Data__c();
        svmx_configData_Obj.RecordTypeId = ConfigDataRtype[0].Id;
        svmx_configData_Obj.SVMXC__Expression_Rule__c = process_Obj.Id;
        svmx_configData_Obj.SVMXC__Operator__c ='eq';
        svmx_configData_Obj.SVMXC__Operand__c = 'High';
        svmx_configData_Obj.SVMXC__Object_Name__c = 'Case';
        svmx_configData_Obj.SVMXC__Display_Type__c = 'STRING';
        svmx_configData_Obj.SVMXC__Display_Value__c = 'STRING';
        svmx_configData_Obj.SVMXC__Sequence__c  = 1;
        //svmx_configData_Obj.SVMXC__Object_Name2__c = 'Case';
        svmx_configData_Obj.SVMXC__Field_Name__c = 'Priority';
        svmx_configData_Obj.SVMXC__Expression_Type__c = 'EXP_Named';
        insert svmx_configData_Obj;
        
        SVMXC__ServiceMax_Processes__c process_ObjWO = new SVMXC__ServiceMax_Processes__c();
        process_ObjWO.RecordTypeId=array_Sobj[0].Id;
        process_ObjWO.SVMXC__Name__c='NamedExpression';
        process_ObjWO.SVMXC__Sequence__c  = 2;
        process_ObjWO.SVMXC__Rule_Type__c = 'Named Expression';
        process_ObjWO.SVMXC__SettingId__c='expid001';
        process_ObjWO.SVMXC__Source_Object_Name__c='SVMXC__Site__c';
        process_ObjWO.SVMXC__Advance_Expression__c = 'Name != null ';
        process_ObjWO.SVMXC__ProcessID__c = 'INV001_Process';
        insert process_ObjWO;
        system.assert(process_ObjWO.SVMXC__Name__c != null);
        
        SVMXC__ServiceMax_Config_Data__c svmx_configData_ObjWO = new SVMXC__ServiceMax_Config_Data__c();
        svmx_configData_ObjWO.RecordTypeId = ConfigDataRtype[0].Id;
        svmx_configData_ObjWO.SVMXC__Expression_Rule__c = process_ObjWO.Id;
        svmx_configData_ObjWO.SVMXC__Operator__c ='eq';
        svmx_configData_ObjWO.SVMXC__Operand__c = 'Open';
        svmx_configData_ObjWO.SVMXC__Sequence__c  = 1;
        svmx_configData_ObjWO.SVMXC__Display_Type__c = 'STRING';
        svmx_configData_ObjWO.SVMXC__Display_Value__c = 'STRING';
        svmx_configData_ObjWO.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        //svmx_configData_ObjWO.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        svmx_configData_ObjWO.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        svmx_configData_ObjWO.SVMXC__Expression_Type__c = 'EXP_Named';
        insert svmx_configData_ObjWO;
        
        SVMXC__Service__c objService1 = new SVMXC__Service__c();
        objService1.SVMXC__Qualifying_Criteria__c = process_ObjWO.Id;
        objService1.SVMXC__Tracked_On__c = 'Work Order';
        insert objService1;
        
        SVMXC__Service__c objService2 = new SVMXC__Service__c();
        objService2.SVMXC__Qualifying_Criteria__c = process_Obj.Id;
        objService2.SVMXC__Tracked_On__c = 'Case';
        insert objService2;
        
        SVMXC__Service__c objService3 = new SVMXC__Service__c();
        objService3.SVMXC__Qualifying_Criteria__c = null;
        objService3.SVMXC__Tracked_On__c = 'Work Order';
        insert objService3;
        
        SVMXC__Service__c objService4 = new SVMXC__Service__c();
        objService4.SVMXC__Qualifying_Criteria__c = null;
        objService4.SVMXC__Tracked_On__c = 'Case';
        insert objService4;
        
        list<SVMXC__Service_Contract_Services__c> lstIncludedServices = new list<SVMXC__Service_Contract_Services__c>();
        SVMXC__Service_Contract_Services__c objIncludedService1 = new SVMXC__Service_Contract_Services__c();
        objIncludedService1.SVMXC__Service__c = objService1.Id;
        objIncludedService1.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService1.SVMXC__Included_Units__c = 11;
        objIncludedService1.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService1);
        system.assert(lstIncludedServices != null);
        
        SVMXC__Service_Contract_Services__c objIncludedService2 = new SVMXC__Service_Contract_Services__c();
        objIncludedService2.SVMXC__Service__c = objService2.Id;
        objIncludedService2.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService2.SVMXC__Included_Units__c = 0;
        objIncludedService2.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService2);
        system.assert(lstIncludedServices != null);
        
        SVMXC__Service_Contract_Services__c objIncludedService3 = new SVMXC__Service_Contract_Services__c();
        objIncludedService3.SVMXC__Service__c = objService3.Id;
        objIncludedService3.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService3.SVMXC__Included_Units__c = 0;
        objIncludedService3.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService3);
        
        SVMXC__Service_Contract_Services__c objIncludedService4 = new SVMXC__Service_Contract_Services__c();
        objIncludedService4.SVMXC__Service__c = objService4.Id;
        objIncludedService4.SVMXC__Service_Contract__c = objSCON.Id;
        lstIncludedServices.add(objIncludedService4);
        
        SVMXC__Service_Contract_Services__c objIncludedService5 = new SVMXC__Service_Contract_Services__c();
        objIncludedService5.SVMXC__Service__c = null;
        objIncludedService5.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService5.SVMXC__Included_Units__c = 0;
        objIncludedService5.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService5);
        
        insert lstIncludedServices;
        system.assert(lstIncludedServices != null);
        
        list<SVMXC__Entitlement_History__c> lstHistory = new list<SVMXC__Entitlement_History__c>();
        SVMXC__Entitlement_History__c objHistory1 = new SVMXC__Entitlement_History__c();
        objHistory1.SVMXC__Inactive_Date__c = null;
        objHistory1.SVMXC__Case__c = objCase.Id;
        objHistory1.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory1.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory1);
        
        SVMXC__Entitlement_History__c objHistory2 = new SVMXC__Entitlement_History__c();
        objHistory2.SVMXC__Inactive_Date__c = date.today();
        objHistory2.SVMXC__Case__c = objCase.Id;
        objHistory2.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory2.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory2);
        
        SVMXC__Entitlement_History__c objHistory3 = new SVMXC__Entitlement_History__c();
        objHistory3.SVMXC__Inactive_Date__c = date.today();
        objHistory3.SVMXC__Case__c = objCase1.Id;
        objHistory3.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory3.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory3);
        
        SVMXC__Entitlement_History__c objHistory4 = new SVMXC__Entitlement_History__c();
        objHistory4.SVMXC__Inactive_Date__c = date.today();
        objHistory4.SVMXC__Service_Order__c = null;
        objHistory4.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory4.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory4);
        
        SVMXC__Entitlement_History__c objHistory5 = new SVMXC__Entitlement_History__c();
        objHistory5.SVMXC__Inactive_Date__c = date.today();
        objHistory5.SVMXC__Service_Order__c = objWorkOrd.Id;
        objHistory5.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory5.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory5);
        
        insert lstHistory;
        system.assert(lstHistory != null);
		
        test.startTest();
        string EntitledServiceId = objIncludedService2.Id;
        EVER_Entitlement_Utils objUtil = new EVER_Entitlement_Utils();
        objUtil.identifyServiceForCase(mapCase, objSCON.ID);
        objUtil.identifyServiceForWorkOrd(mapWorkOrd,objSCON.Id);
        objUtil.manageServiceThresholdCount('CASE' ,objCase.Id, objSCON.Id, lstIncludedServices[0].Id);
        objUtil.manageServiceThresholdCount('SVMXC__Service_Order__c', objWorkOrd.Id, objSCON.Id, lstIncludedServices[0].Id);
        objUtil.identifyServiceForCase(lstCase);
        map<string, string> mapCaseServiceIds = new map<string, string>();
        mapCaseServiceIds.put(lstCase[0].Id,process_Obj.Id);
        objUtil.manageServiceThresholdCount(lstCase, mapCaseServiceIds, false);
        objUtil.manageServiceThresholdCount(lstCase, mapCaseServiceIds, true);
        map<string, string> mapWorkOrdServiceIds = new map<string, string>();
        mapWorkOrdServiceIds.put(lstWorkOrder[0].Id, process_ObjWO.Id);
        objUtil.manageServiceThresholdCount(lstWorkOrder,mapWorkOrdServiceIds, false);
        objUtil.manageServiceThresholdCount(lstWorkOrder,mapWorkOrdServiceIds, true);
        map<integer, string> mapSobjIndexWithService = new map<integer, string>();
        mapSobjIndexWithService.put(0,process_Obj.Id);
        objUtil.manageServiceThresholdCount(lstCase, null, mapSobjIndexWithService );
        mapSobjIndexWithService.clear();
        mapSobjIndexWithService.put(0,process_ObjWO.Id);
        objUtil.manageServiceThresholdCount(null, lstWorkOrder,mapSobjIndexWithService );
        map<integer, Case> mapIndexdCase = new map<integer, Case>();
        for(integer i=0; i<lstCase.size();i++)
            mapIndexdCase.put(i,lstCase[i]);
        map<integer, SVMXC__Service_Order__c> mapIndexdWorkOrd = new map<integer, SVMXC__Service_Order__c>();
        for(integer i=0; i<lstWorkOrder.size();i++)
            mapIndexdWorkOrd.put(i,lstWorkOrder[i]);
        map<integer, SVMXC__Service_Order__c> mapIndexdWorkOrd1;
        map<integer, Case> mapIndexdCase1;
        objUtil.identifyServiceForWorkOrder(lstWorkOrder);
        objUtil.identifyServicesForIndexedRecs(mapIndexdCase, null);
        objUtil.identifyServicesForIndexedRecs(null, mapIndexdWorkOrd);
        
        objIncludedService1.SVMXC__Included_Units__c = 5;
        objIncludedService1.SVMXC__Consumed_Units__c = 10;
        update objIncludedService1;
        
        objIncludedService2.SVMXC__Included_Units__c = 10;
        objIncludedService2.SVMXC__Consumed_Units__c = 10;
        update objIncludedService2;
        
        objUtil.manageServiceThresholdCount('CASE' ,objCase.Id, objSCON.Id, lstIncludedServices[0].Id);
        objUtil.manageServiceThresholdCount('SVMXC__Service_Order__c', objWorkOrd.Id, objSCON.Id, lstIncludedServices[0].Id);
        
        mapSobjIndexWithService = new map<integer, string>();
        mapSobjIndexWithService.put(0,process_Obj.Id);
        objUtil.manageServiceThresholdCount(lstCase, null,mapSobjIndexWithService );
        mapSobjIndexWithService.clear();
        mapSobjIndexWithService.put(0,process_ObjWO.Id);
        objUtil.manageServiceThresholdCount(null, lstWorkOrder,mapSobjIndexWithService );
        mapIndexdCase = new map<integer, Case>();
        for(integer i=0; i<lstCase.size();i++)
            mapIndexdCase.put(i,lstCase[i]);
        mapIndexdWorkOrd = new map<integer, SVMXC__Service_Order__c>();
        for(integer i=0; i<lstWorkOrder.size();i++)
            mapIndexdWorkOrd.put(i,lstWorkOrder[i]);
        
        objUtil.identifyServiceForWorkOrder(lstWorkOrder);
        objUtil.identifyServicesForIndexedRecs(mapIndexdCase, null);
        objUtil.identifyServicesForIndexedRecs(null, mapIndexdWorkOrd);
        
        objUtil.manageServiceThresholdCount('CASE' ,objCase.Id, objSCON.Id, lstIncludedServices[0].Id);
                
        objUtil.manageServiceThresholdCount(lstWorkOrder,mapWorkOrdServiceIds, false);
        objUtil.manageServiceThresholdCount(lstWorkOrder,mapWorkOrdServiceIds, true);
        
        objUtil.manageServiceThresholdCount('SVMXC__Service_Order__c', objWorkOrd.Id, objSCON.Id, lstIncludedServices[0].Id);
        
        objUtil.manageServiceThresholdCount(null, lstWorkOrder,mapSobjIndexWithService );
        objUtil.manageServiceThresholdCount(lstCase, null,mapSobjIndexWithService );

        test.stopTest();
    }
    static testMethod void Entitlement_Utils_Test1() 
    {
        
        Account objAcc = new Account(Name = 'TestAcc001');
        insert objAcc;
        system.assert(objAcc.Name != null);
        
        SVMXC__Service_Contract__c objSCON = new SVMXC__Service_Contract__c();
        objSCON.Name = 'SCON001';
        objSCON.SVMXC__Active__c = true;
        objSCON.SVMXC__Company__c = objAcc.Id;
        objSCON.SVMXC__End_Date__c = date.today().addDays(10);
        objSCON.SVMXC__Start_Date__c = date.today().addDays(-2);
        insert objSCON;
        system.assert(objSCON.Name != null);
        
        list<Case> lstCase = new list<Case>();
        Case objCase = new Case();
        objCase = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', SVMXC__Service_Contract__c = objSCON.Id);
        Case objCase1 = new Case();
        objCase1 = new Case(Status ='New', Priority = 'High', Origin = 'Phone', SVMXC__Service_Contract__c = objSCON.Id);
        lstCase.add(objCase);
        lstCase.add(objCase1);
        insert lstCase;
        system.assert(objCase1.Status != null);
        system.assert(objCase1.Priority != null);
        system.assert(lstCase != null);
        
        Map<string,sObject> mapCase = new Map<string,sObject>();
        mapCase.put(objCase.Id, (sObject)objCase); 
        
        list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c objWorkOrd = new SVMXC__Service_Order__c();
        objWorkOrd.SVMXC__City__c = 'Bangalore';
        objWorkOrd.SVMXC__Order_Status__c = 'Open';
        objWorkOrd.SVMXC__Service_Contract__c = objSCON.Id;
        lstWorkOrder.add(objWorkOrd);
        insert lstWorkOrder;
        system.assert(objWorkOrd.SVMXC__Order_Status__c != null);
        system.assert(objWorkOrd.SVMXC__City__c != null);
        
        Map<string,sObject> mapWorkOrd = new Map<string,sObject>();
        mapWorkOrd.put(objWorkOrd.Id, (sObject)objWorkOrd); 
        
        RecordType[] array_Sobj = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='SVMX Rule' ];
        RecordType[] ConfigDataRtype = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name='Expressions' ];

        
        SVMXC__ServiceMax_Processes__c process_ObjWO = new SVMXC__ServiceMax_Processes__c();
        process_ObjWO.RecordTypeId=array_Sobj[0].Id;
        process_ObjWO.SVMXC__Name__c='NamedExpression';
        process_ObjWO.SVMXC__Sequence__c  = 1;
        process_ObjWO.SVMXC__Rule_Type__c = 'Named Expression';
        process_ObjWO.SVMXC__SettingId__c='expid001';
        process_ObjWO.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c';
        process_ObjWO.SVMXC__Advance_Expression__c = '1';
        process_ObjWO.SVMXC__ProcessID__c = 'INV001_Process';
        insert process_ObjWO;
        system.assert(process_ObjWO.SVMXC__Name__c != null);
        
        SVMXC__ServiceMax_Config_Data__c svmx_configData_ObjWO = new SVMXC__ServiceMax_Config_Data__c();
        svmx_configData_ObjWO.RecordTypeId = ConfigDataRtype[0].Id;
        svmx_configData_ObjWO.SVMXC__Expression_Rule__c = process_ObjWO.Id;
        svmx_configData_ObjWO.SVMXC__Operator__c ='eq';
        svmx_configData_ObjWO.SVMXC__Operand__c = 'Open';
        svmx_configData_ObjWO.SVMXC__Display_Type__c = 'PICKLIST';
        svmx_configData_ObjWO.SVMXC__Display_Value__c = 'STRING';
        svmx_configData_ObjWO.SVMXC__Sequence__c = 1;
        svmx_configData_ObjWO.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        //svmx_configData_ObjWO.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        svmx_configData_ObjWO.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        svmx_configData_ObjWO.SVMXC__Expression_Type__c = 'EXP_Named';
        insert svmx_configData_ObjWO;
        
        SVMXC__ServiceMax_Processes__c process_ObjWO1 = new SVMXC__ServiceMax_Processes__c();
        process_ObjWO1.RecordTypeId=array_Sobj[0].Id;
        process_ObjWO1.SVMXC__Name__c='NamedExpression';
        process_ObjWO1.SVMXC__Sequence__c  = 1;
        process_ObjWO1.SVMXC__Rule_Type__c = 'Named Expression';
        process_ObjWO1.SVMXC__SettingId__c='expid001';
        process_ObjWO1.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c';
        process_ObjWO1.SVMXC__Advance_Expression__c = '1';
        process_ObjWO1.SVMXC__ProcessID__c = 'INV001_Process';
        insert process_ObjWO1;
        system.assert(process_ObjWO1.SVMXC__Name__c != null);
        
        SVMXC__ServiceMax_Config_Data__c svmx_configData_ObjWO1 = new SVMXC__ServiceMax_Config_Data__c();
        svmx_configData_ObjWO1.RecordTypeId = ConfigDataRtype[0].Id;
        svmx_configData_ObjWO1.SVMXC__Expression_Rule__c = process_ObjWO1.Id;
        svmx_configData_ObjWO1.SVMXC__Operator__c ='eq';
        svmx_configData_ObjWO1.SVMXC__Operand__c = 'Close';
        svmx_configData_ObjWO1.SVMXC__Display_Type__c = 'PICKLIST';
        svmx_configData_ObjWO1.SVMXC__Display_Value__c = 'STRING';
        svmx_configData_ObjWO1.SVMXC__Sequence__c = 1;
        svmx_configData_ObjWO1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        //svmx_configData_ObjWO.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        svmx_configData_ObjWO1.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        svmx_configData_ObjWO1.SVMXC__Expression_Type__c = 'EXP_Named';
        insert svmx_configData_ObjWO1;
        
        SVMXC__Service__c objService1 = new SVMXC__Service__c();
        objService1.SVMXC__Qualifying_Criteria__c = process_ObjWO.Id;
        objService1.SVMXC__Tracked_On__c = 'Work Order';
        insert objService1;
        
        SVMXC__Service__c objService11 = new SVMXC__Service__c();
        objService11.SVMXC__Qualifying_Criteria__c = process_ObjWO.Id;
        objService11.SVMXC__Tracked_On__c = 'Work Order';
        insert objService11;
        
        SVMXC__Service__c objService10 = new SVMXC__Service__c();
        objService10.SVMXC__Qualifying_Criteria__c = process_ObjWO1.Id;
        objService10.SVMXC__Tracked_On__c = 'Work Order';
        insert objService10;
 
        
        SVMXC__Service__c objService3 = new SVMXC__Service__c();
        objService3.SVMXC__Qualifying_Criteria__c = null;
        objService3.SVMXC__Tracked_On__c = 'Work Order';
        insert objService3;
        
        SVMXC__Service__c objService32 = new SVMXC__Service__c();
        objService32.SVMXC__Qualifying_Criteria__c = null;
        //objService32.SVMXC__Tracked_On__c = 'Work Order';
        insert objService32;
        
        SVMXC__Service__c objService31 = new SVMXC__Service__c();
        objService31.SVMXC__Qualifying_Criteria__c = process_ObjWO1.Id;
        //objService3.SVMXC__Tracked_On__c = 'Work Order';
        insert objService31;
        
        
        list<SVMXC__Service_Contract_Services__c> lstIncludedServices = new list<SVMXC__Service_Contract_Services__c>();
        SVMXC__Service_Contract_Services__c objIncludedService1 = new SVMXC__Service_Contract_Services__c();
        objIncludedService1.SVMXC__Service__c = objService1.Id;
        objIncludedService1.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService1.SVMXC__Included_Units__c = 11;
        objIncludedService1.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService1);
        system.assert(lstIncludedServices != null);
        
        SVMXC__Service_Contract_Services__c objIncludedService11 = new SVMXC__Service_Contract_Services__c();
        objIncludedService11.SVMXC__Service__c = objService11.Id;
        objIncludedService11.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService11.SVMXC__Included_Units__c = 11;
        objIncludedService11.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService11);
        system.assert(lstIncludedServices != null);
        
        SVMXC__Service_Contract_Services__c objIncludedService10 = new SVMXC__Service_Contract_Services__c();
        objIncludedService10.SVMXC__Service__c = objService10.Id;
        objIncludedService10.SVMXC__Service_Contract__c = objSCON.Id;
        //objIncludedService1.SVMXC__Included_Units__c = 11;
        //objIncludedService1.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService10);
        
        
        SVMXC__Service_Contract_Services__c objIncludedService2 = new SVMXC__Service_Contract_Services__c();
        objIncludedService2.SVMXC__Service__c = objService31.Id;
        objIncludedService2.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService2.SVMXC__Included_Units__c = 0;
        objIncludedService2.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService2);
        system.assert(lstIncludedServices != null);
        
        SVMXC__Service_Contract_Services__c objIncludedService21 = new SVMXC__Service_Contract_Services__c();
        objIncludedService21.SVMXC__Service__c = objService31.Id;
        objIncludedService21.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService21.SVMXC__Included_Units__c = 20;
        objIncludedService21.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService21);
        system.assert(lstIncludedServices != null);
        
        SVMXC__Service_Contract_Services__c objIncludedService3 = new SVMXC__Service_Contract_Services__c();
        objIncludedService3.SVMXC__Service__c = objService3.Id;
        objIncludedService3.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService3.SVMXC__Included_Units__c = 0;
        objIncludedService3.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService3);
        
        SVMXC__Service_Contract_Services__c objIncludedService4 = new SVMXC__Service_Contract_Services__c();
        objIncludedService4.SVMXC__Service__c = objService3.Id;
        objIncludedService4.SVMXC__Service_Contract__c = objSCON.Id;
        lstIncludedServices.add(objIncludedService4);
        
        SVMXC__Service_Contract_Services__c objIncludedService42 = new SVMXC__Service_Contract_Services__c();
        objIncludedService42.SVMXC__Service__c = objService32.Id;
        objIncludedService42.SVMXC__Service_Contract__c = objSCON.Id;
        lstIncludedServices.add(objIncludedService42);
        
        SVMXC__Service_Contract_Services__c objIncludedService5 = new SVMXC__Service_Contract_Services__c();
        objIncludedService5.SVMXC__Service__c = null;
        objIncludedService5.SVMXC__Service_Contract__c = objSCON.Id;
        objIncludedService5.SVMXC__Included_Units__c = 0;
        objIncludedService5.SVMXC__Consumed_Units__c = 10;
        lstIncludedServices.add(objIncludedService5);
        
        insert lstIncludedServices;
        system.assert(lstIncludedServices != null);
        
        list<SVMXC__Entitlement_History__c> lstHistory = new list<SVMXC__Entitlement_History__c>();
        SVMXC__Entitlement_History__c objHistory1 = new SVMXC__Entitlement_History__c();
        objHistory1.SVMXC__Inactive_Date__c = null;
        objHistory1.SVMXC__Case__c = objCase.Id;
        objHistory1.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory1.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory1);
        
        SVMXC__Entitlement_History__c objHistory2 = new SVMXC__Entitlement_History__c();
        objHistory2.SVMXC__Inactive_Date__c = date.today();
        objHistory2.SVMXC__Case__c = objCase.Id;
        objHistory2.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory2.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory2);
        
        SVMXC__Entitlement_History__c objHistory3 = new SVMXC__Entitlement_History__c();
        objHistory3.SVMXC__Inactive_Date__c = date.today();
        objHistory3.SVMXC__Case__c = objCase1.Id;
        objHistory3.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory3.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory3);
        
        SVMXC__Entitlement_History__c objHistory4 = new SVMXC__Entitlement_History__c();
        objHistory4.SVMXC__Inactive_Date__c = date.today();
        objHistory4.SVMXC__Service_Order__c = null;
        objHistory4.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory4.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory4);
        
        SVMXC__Entitlement_History__c objHistory5 = new SVMXC__Entitlement_History__c();
        objHistory5.SVMXC__Inactive_Date__c = date.today();
        objHistory5.SVMXC__Service_Order__c = objWorkOrd.Id;
        objHistory5.SVMXC__Entitled_By_Service__c = objIncludedService5.Id;
        objHistory5.SVMXC__Service_Contract__c = objSCON.Id;
        lstHistory.add(objHistory5);
        
        insert lstHistory;
        system.assert(lstHistory != null);

        string EntitledServiceId = objIncludedService2.Id;
        EVER_Entitlement_Utils objUtil = new EVER_Entitlement_Utils();
        
        objIncludedService1.SVMXC__Included_Units__c = 5;
        objIncludedService1.SVMXC__Consumed_Units__c = 10;
        update objIncludedService1;
        
        objIncludedService2.SVMXC__Included_Units__c = 10;
        objIncludedService2.SVMXC__Consumed_Units__c = 10;
        update objIncludedService2;

        List<EVER_SCResults> lstSCResult = new List<EVER_SCResults>();
        SVMXC.EVER_SCResults TempRecord = new SVMXC.EVER_SCResults();
        TempRecord.SCId = objSCON.Id;    
        TempRecord.SCName = 'testing';
        TempRecord.CoveredBy = 'Location';   
        TempRecord.StartDate = date.today().addDays(-2);
        TempRecord.EndDate = date.today().addDays(10);
        
        lstSCResult.add(TempRecord);
        
        objUtil.GetServicesOfSCON(lstSCResult, 'WorkOrder', objWorkOrd, true, objSCON.Id, objIncludedService4.Id);
     
        map<string, string> mapWorkOrdServiceIds = new map<string, string>();
        mapWorkOrdServiceIds.put(lstWorkOrder[0].Id, process_ObjWO.Id);
        objUtil.manageServiceThresholdCount(lstWorkOrder,mapWorkOrdServiceIds, false);
        objUtil.manageServiceThresholdCount(lstWorkOrder,mapWorkOrdServiceIds, true);
     
    }
}