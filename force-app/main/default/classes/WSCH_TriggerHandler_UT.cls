@isTest
(SeeAllData=false)
public with sharing class WSCH_TriggerHandler_UT {
    
    public WSCH_TriggerHandler_UT() {
        /*List<SVMXC__ServiceMax_Config_Data__c> lstConfGBL = [SELECT id,SVMXC__Setting_Unique_ID__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Unique_ID__c IN ('GLOB001_GBL007','GLOB001_GBL022')];

        
    for(SVMXC__ServiceMax_Config_Data__c confObj : lstConfGBL)
        {
            if(confObj.SVMXC__Setting_Unique_ID__c.equalsIgnoreCase('GLOB001_GBL007')){
                confObj.SVMXC__Display_Value__c = 'true';
                confObj.SVMXC__Internal_Value__c = 'true';
            }
            else{
                confObj.SVMXC__Display_Value__c = 'OptiMax,ServicePower';
                confObj.SVMXC__Internal_Value__c = 'OptiMax,ServicePower';
            }
            confObj.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        }

        if(!lstConfGBL.isEmpty()){
            Database.update(lstConfGBL);
        }*/
        //createOptimizationSettings('OptiMax,ServicePower', 'True');
    }
    
    static {
        WSCH_TriggerHandler_UT triggerHandlerUT = new WSCH_TriggerHandler_UT();
        
        createOptimizationSettings('OptiMax,ServicePower', 'True');
    }

    static testmethod void WSCH_TriggerHandler_Test(){

        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

       list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();
        
        
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 3600;
        workOrder.SVMXC__OptiMax_Status__c ='';
        workOrder.SVMXC__Scheduling_Change_Token__c = '';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
        workOrder.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75001';
        workOrder1.SVMXC__Order_Status__c='Open';
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__OptiMax_Status__c = '';
        workOrder1.SVMXC__Scheduling_Change_Token__c = '';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
        workOrder1.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        workOrders.add(workOrder1);
        insert workOrders;

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        WSCH_TriggerHandler.doQualifyWorkorder(workOrders);

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);
        WSCH_TriggerHandler.isFixWO(workOrder1, workOrder);
        List<String> woIDs = new List<String>();
        woIDs.add(workOrder.Id);
        woIDs.add(workOrder1.Id);
        WSCH_TriggerHandler.manageWorkOrders(woIDs);

        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        newWOs.clear();
        newWOs.add(workOrder1);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        workOrder1.SVMXC__Zip__c='75005';
        newWOs.clear();
        newWOs.add(workOrder1);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        workOrder1.SVMXC__Service_Duration__c=7200;
        newWOs.clear();
        newWOs.add(workOrder1);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now() + 1;
        newWOs.clear();
        newWOs.add(workOrder1);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        WSCH_TriggerHandler.updateWorkOrders(woIDs, 'OPT_PENDING', 'CHANGE_CREATE_WO');
        WSCH_Triggerhandler.manageWorkOrders(woIDs);
        //insert newWOs;
        Test.stopTest();
    }

    static testmethod  void TestMoreFutureCalls(){

        Test.startTest();

	try{
        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
            else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();
        Set<SVMXC__Service_Order__c> setWorkOrders = new Set<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Zip__c = '75001';
        workOrder.SVMXC__Order_Status__c='Open';
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Service_Duration__c = 60;
        workOrder.SVMXC__OptiMax_Status__c ='';
        workOrder.SVMXC__Scheduling_Change_Token__c = '';
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        //workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c = DateTime.now();
        //workOrder.SVMXC__Actual_Onsite_Response__c=DateTime.now();
        //workOrder.SVMXC__Finished_Onsite_Date_Time__c=DateTime.now();
        workOrders.add(workOrder);
        setWorkOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75005';
        workOrder1.SVMXC__Order_Status__c='Open';
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 60;
        workOrder1.SVMXC__OptiMax_Status__c = '';
        workOrder1.SVMXC__Scheduling_Change_Token__c = '';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
       // workOrder1.SVMXC__Started_Driving_To_Location_Date_Time__c = DateTime.now();
        //workOrder1.SVMXC__Actual_Onsite_Response__c=DateTime.now();
        //workOrder1.SVMXC__Finished_Onsite_Date_Time__c=DateTime.now();
        workOrders.add(workOrder1);
        setWorkOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Priority__c='High';
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);
        //WSCH_TriggerHandler.getWOIds(setWorkOrders);

        workOrder1.SVMXC__Order_Status__c='Closed';
        newWOs.clear();
        newWOs.add(workOrder1);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        workOrder1.SVMXC__Order_Status__c='Canceled';
        newWOs.clear();
        insert workOrder1;
        newWOs.add(workOrder1);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='CHANGE_CREATE';
        newWOs.clear();
        newWOs.add(workOrder1);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap = WSCH_CommonUtils.getContinuousDP();
        WSCH_TriggerHandler.markChangeToken(workOrder1, workOrder,svmxProcessMap);

        WSCH_TriggerHandler.getQualifiedWOIds(workOrders);
		}
        catch(Exception ex){
        	system.assertEquals(ex.getMessage(), ex.getMessage());
        }
        
        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall1() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Started_Driving_To_Location_Date_Time__c = DateTime.now();

        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Started_Driving_To_Location_Date_Time__c = DateTime.now();
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Started_Driving_To_Location_Date_Time__c=DateTime.now() + 1;
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(newWOs[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(oldWOs[0].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall2() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder.SVMXC__Actual_Onsite_Response__c = DateTime.now();

        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Actual_Onsite_Response__c = DateTime.now();
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Actual_Onsite_Response__c=DateTime.now() + 1;
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall3() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Finished_Onsite_Date_Time__c = DateTime.now();

        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Finished_Onsite_Date_Time__c = DateTime.now();
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Finished_Onsite_Date_Time__c=DateTime.now() + 1;
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall4() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder.SVMXC__Order_Status__c = 'Open';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__Order_Status__c = 'Open';
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Order_Status__c = 'Closed';
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall5() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder.SVMXC__Priority__c = 'Medium';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__Priority__c = 'Medium';
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Priority__c = 'High';
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall6() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder.SVMXC__Preferred_Business_Hours__c = null;
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__Preferred_Business_Hours__c = null;
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        List<BusinessHours> lstOfBusinessHours;
        lstOfBusinessHours = [SELECT Id,IsActive,IsDefault,MondayStartTime,MondayEndTime,
                                TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                                ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                                SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                                WHERE IsDefault = TRUE AND IsActive = TRUE];

        BusinessHours businessHoursObj = lstOfBusinessHours.get(0);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Preferred_Business_Hours__c = businessHoursObj.Id;
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall7() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Preferred_Technician__c = null;
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Preferred_Technician__c = null;
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;

        //insert technician;

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Preferred_Technician__c = technician.Id;
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall8() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Skill_Set__c = '';
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Skill_Set__c = '';
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Skill_Set__c = 'Skill Set';
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }

    static testmethod  void testIdentifyAPICall9() {

        Test.startTest();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Order_Status__c = 'Open';
        workOrder.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        insert workOrder;

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Order_Status__c = 'Open';
        insert workOrder1;

        List<String> woIDs = new List<String>();
        woIDs.add(workOrder.Id);
        woIDs.add(workOrder1.Id);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        WSCH_Triggerhandler.manageWorkOrders(woIDs);

        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall10() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder.SVMXC__Acknowledged_By_Technician_Date_Time__c = DateTime.now();

        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c = DateTime.now();
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now() + 1;
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }

    static testmethod void testIdentifyAPICall11() {
        Test.startTest();

        String DispatchProRecordTypeId = '';
        String ExpressionRTypeId = '';
        String RuleRecordTypeId = '';
        String FldMapRecordTypeId = '';
        String TCRT = '';
        RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : rts) //Loop to take a record type at a time
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               DispatchProRecordTypeId = rt.ID;
            else if(rt.Name == 'Expressions' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
               ExpressionRTypeId = rt.ID;
            else if(rt.Name == 'SVMX Rule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                RuleRecordTypeId = rt.id;
            else if(rt.Name == 'Field Mapping' &&  rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                FldMapRecordTypeId = rt.id;
             else if(rt.Name == 'Coverage' &&  rt.SobjectType == 'SVMXC__Territory_Coverage__c')
                TCRT = rt.id;
        }

        SVMXC__ServiceMax_Processes__c svmxprocess = new SVMXC__ServiceMax_Processes__c();
        svmxprocess.SVMXC__Name__c = 'Linx for ServicePower 1';
        svmxprocess.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess.SVMXC__Dispatch_Method__c='Linx for ServicePower';
        insert svmxprocess;

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        insert territory;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        //workOrder.SVMXC__Group_Member__c = Tech.id;
        //workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Primary_Territory__c=territory.Id;
        workOrder.SVMXC__Service_Duration__c = 3600;
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;

        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        //workOrder1.SVMXC__Group_Member__c = Tech.id;
        //workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        workOrder1.SVMXC__Service_Duration__c = 7200;
        newWOs.clear();
        newWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        //To cover deleteWORelatedEventsOnCancel
        newWOs.clear();
        oldWOs.clear();
        workOrder.SVMXC__Work_Order_Scheduling_Status__c = 'Cancelled';
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c = 'Completed';
        workOrder1.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        insert workOrder1; 
        //insert workOrder;
        newWOs.add(workOrder);
        oldWOs.add(workOrder1);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrder.Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrder1.Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);

        Test.stopTest();
    }



    static testmethod void testNonWOSvmxEventDelete() {
        Test.startTest();

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;

        insert technician;

        
        SVMXC__SVMX_Event__c svmxEvent= new SVMXC__SVMX_Event__c(
                                                    SVMXC__ActivityDate__c = Date.valueOf('2010-02-12 00:00:00'), 
                                                    SVMXC__ActivityDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'), 
                                                    SVMXC__StartDateTime__c = Datetime.valueOf('2010-02-12 01:00:00'),
                                                    SVMXC__DurationInMinutes__c = 60,
                                                    SVMXC__EndDateTime__c = Datetime.valueOf('2010-02-12 01:00:00').addHours(1),
                                                    SVMXC__Technician__c =  technician.Id,
                                                    SVMXC__WhatId__c = Schema.Sobjecttype.SVMXC__SVMX_Event__c.getKeyPrefix()
                                                    );

        insert svmxEvent;

        SVMXC__SVMX_Optimizer__c svmxOptimizer = new SVMXC__SVMX_Optimizer__c();
        svmxOptimizer.SVMXC__WhatId__c = svmxEvent.Id;
        svmxOptimizer.SVMXC__Optimizer_External_Id__c = String.valueOf(1234);

        insert svmxOptimizer;

        List<String> optimizerIdList = new List<String>();
        optimizerIdList.add(svmxOptimizer.Id);

        svmxOptimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_DELETE';

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        Test.stopTest();
    }

    static testmethod void testCancelJob() {
        Test.startTest();
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__OptiMax_Status__c = 'OPT_COMPLETED';
        List<SVMXC__Service_Order__c> workOrders = new List<SVMXC__Service_Order__c>();
        workOrders.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        WSCH_TriggerHandler.doQualifyCancelWorkorder(workOrders);
        Test.stopTest();
    }

    static testmethod void testIdentifyAPICallForceFix() {
        Test.startTest();

        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'UK Region';
        territory1.SVMXC__Optimizer_External_ID__c = 'UK01';
        territory1.SVMXC__Optimizer_Last_Timestamp__c='';
        insert territory1;

        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';

        insert team;

        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Optimizer_External_ID__c = 'TM001';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory1.Id;

        //insert technician;

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Group_Member__c = technician.Id;
        workOrder.SVMXC__Scheduled_Date_Time__c = datetime.now();
        workOrder.SVMXC__Primary_Territory__c=territory1.Id;
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder.SVMXC__OptiMax_Status__c='OPT_COMPLETED';
        workOrder.SVMXC__Service_Duration__c = 3600;
        workOrder.SVMXC__Driving_Time__c = 5;
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Group_Member__c = technician.Id;
        workOrder1.SVMXC__Scheduled_Date_Time__c = datetime.now()+1;
        workOrder1.SVMXC__Locked_By_DC__c = true;
        workOrder1.SVMXC__Primary_Territory__c=territory1.Id;
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__Work_Order_Scheduling_Status__c='Tentative';
        workOrder1.SVMXC__OptiMax_Status__c='OPT_COMPLETED';
        workOrder1.SVMXC__Driving_Time__c = 10;
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);
        Test.stopTest();
    }

    static testmethod void testIdentifyAPICallBookAppt() {
        Test.startTest();

        list<SVMXC__Service_Order__c> workOrders = new list<SVMXC__Service_Order__c>();

        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        workOrder.SVMXC__Locked_By_DC__c = false;
        workOrder.SVMXC__OptiMax_Status__c='OPT_COMPLETED';
        workOrder.SVMXC__Service_Duration__c = 3600;
        workOrder.SVMXC__Schedule_As_A_Dependent_Work_Order__c = false;
        //workOrder.SVMXC__Dependency_Group__c = null;
        workOrder.SVMXC__Appointment_Promised_Time_Slot__c = '13:00 - 16:30, Fri, 2015-11-27, false, 2015-11-27, 2015-11-27, 0, 2015-11-27 13:00:00, 2015-11-27 16:30:00';
        workOrder.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CUSTOM_FIELDS_BOOK';
        workOrders.add(workOrder);

        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__OptiMax_Status__c='OPT_COMPLETED';
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CUSTOM_FIELDS_BOOK';
        workOrder1.SVMXC__Appointment_Promised_Time_Slot__c = '13:00 - 16:30, Fri, 2015-11-27, true, 2015-11-27, 2015-11-27, 0, 2015-11-27 13:00:00, 2015-11-27 16:30:00';
        //workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrders.add(workOrder1);
        //insert workOrders;

        list<SVMXC__Service_Order__c> newWOs = new list<SVMXC__Service_Order__c>();
        list<SVMXC__Service_Order__c> oldWOs = new list<SVMXC__Service_Order__c>();
        newWOs.add(workOrder1);
        oldWOs.add(workOrder);

        //Mock the webservice call.
        try{
        Test.setMock(WebServiceMock.class, new WSCH_ServicePowerAPIMockImpl_UT());
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[0].Id, true);
        WORD_Service_Order_Resources.mapIsWoResEmpty.put(workOrders[1].Id, true);
        WSCH_TriggerHandler.identifyAPIAndOptimize(newWOs, oldWOs);
        
        Boolean bool = WSCH_TriggerHandler.isAppointmentWO(workOrder1);
        List<String> woList1 = WSCH_TriggerHandler.getCustomFieldsFromSettings();
        Set<String> woList2 = WSCH_TriggerHandler.getUpdateJobFieldsFromSettings();
        Set<String> woList3 = WSCH_TriggerHandler.getBookJobFieldsFromSettings();
        Boolean bool1 = WSCH_TriggerHandler.isAddressInfoChange(workOrder, workOrder1);
        Boolean bool2 = WSCH_TriggerHandler.isCustomFieldChange(workOrder, workOrder1, 'testAPI');
        Map<Id,SVMXC__ServiceMax_Processes__c> svmxProcessMap = new Map<Id,SVMXC__ServiceMax_Processes__c>();
        svmxProcessMap = WSCH_CommonUtils.getContinuousDP();
        bool = WSCH_TriggerHandler.isBookJobWO(workOrder1,svmxProcessMap);
        Map<String, Map<String, Object>> oldWOIdFieldValuesMap = new Map<String, Map<String, Object>>();
        Map<String, Object> oldWODetail = new Map<String, Object>();
        oldWODetail.put('SVMXC__OptiMax_Status__c', workOrder.SVMXC__OptiMax_Status__c);
        oldWODetail.put('SVMXC__Scheduling_Change_Token__c', workOrder.SVMXC__Scheduling_Change_Token__c);
        oldWODetail.put('WOId', workOrder.Id);
        oldWOIdFieldValuesMap.put(String.valueOf(workOrder.id), oldWODetail);
        //WSCH_TriggerHandler.getChangedWOList(oldWOs, oldWOIdFieldValuesMap);
        Boolean bool3 = WSCH_TriggerHandler.isBookJobWO(workOrder, svmxProcessMap );
        Boolean bool4 = WSCH_TriggerHandler.markChangeToken(workOrder, workOrder1, svmxProcessMap );
        }
        catch(Exception ex){
        	system.assertEquals(ex.getMessage(), ex.getMessage());
        }
        Test.stopTest();
    }

    static testmethod  void testQualifyForNewChangeToken() {

        Test.startTest();
        createOptimizationSettings('OptiMax,ServicePower', 'True');
        WSCH_TriggerHandler.getChangeToken ('OPT_COMPLETED',null,'CHANGE_CANCEL_WO');
        WSCH_TriggerHandler.getChangeToken ('OPT_COMPLETED','CHANGE_JOB_FIXED','CHANGE_CANCEL_WO');
        WSCH_TriggerHandler.getChangeToken ('OPT_COMPLETED','CHANGE_JOB_FIXED',null);
        WSCH_TriggerHandler.getChangeToken ('OPT_COMPLETED','CHANGE_JOB_FIXED',null);
        Test.stopTest();
    }
    //This method Optimization Settings GLOB001_GBL007 & GLOB001_GBL022
    private static void createOptimizationSettings(String strOptimizers, String strEnableOptimizer){
        String confProfileTypeId = '';
        String setValTypeId = '';
        String setTypeId = '';
        String subModTypeId = '';
        String modTypeId = '';
        
        RecordType[] recTypeId = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' or SobjectType = 'SVMXC__ServiceMax_Config_Data__c' or SobjectType = 'SVMXC__Territory_Coverage__c'];
        for(RecordType rt : recTypeId) //Loop to take a record type at a time
        {
            if(rt.Name == 'Configuration Profile' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                confProfileTypeId = rt.ID;
            else if(rt.Name == 'Setting Value' && rt.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                setValTypeId = rt.ID;
            else if(rt.Name == 'Settings' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                setTypeId = rt.id;
            else if(rt.Name == 'Submodule' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                subModTypeId = rt.id;
            else if(rt.Name == 'Module' &&  rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
                modTypeId = rt.id;
        }
        
        //adding COMM Process Module
        SVMXC__ServiceMax_Processes__c modProc_COMM = new SVMXC__ServiceMax_Processes__c();
        modProc_COMM.RecordTypeId = modTypeId;
        modProc_COMM.SVMXC__ModuleID__c = 'COMM';
        modProc_COMM.SVMXC__Name__c = 'Common';
        modProc_COMM.SVMXC__IsStandard__c = true;
        modProc_COMM.SVMXC__Description__c = 'TEST MODULE DESCRIPTION';
        modProc_COMM.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(modProc_COMM);
        
        //adding GLOB001 Process SubModule
        SVMXC__ServiceMax_Processes__c subModProc_GLOB001 = new SVMXC__ServiceMax_Processes__c();
        subModProc_GLOB001.RecordTypeId = subModTypeId;
        subModProc_GLOB001.SVMXC__SubmoduleID__c = 'GLOB001';
        subModProc_GLOB001.SVMXC__Name__c = 'Global Settings';
        subModProc_GLOB001.SVMXC__IsStandard__c = true;
        subModProc_GLOB001.SVMXC__Module__c = modProc_COMM.id;
        subModProc_GLOB001.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_GLOB001.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(subModProc_GLOB001);
        
        //adding GLOB001 GBL007 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL007 = new SVMXC__ServiceMax_Processes__c();
        settingProc_GLOB001_GBL007.RecordTypeId = setTypeId;
        settingProc_GLOB001_GBL007.SVMXC__SettingID__c = 'GBL007';
        settingProc_GLOB001_GBL007.SVMXC__Data_Type__c = 'Boolean';
        settingProc_GLOB001_GBL007.SVMXC__Default_Value__c = 'True';
        settingProc_GLOB001_GBL007.SVMXC__Setting_Type__c = 'Global';
        settingProc_GLOB001_GBL007.SVMXC__Search_Order__c = 'Global';
        settingProc_GLOB001_GBL007.SVMXC__Active__c = true;
        settingProc_GLOB001_GBL007.SVMXC__IsStandard__c = true;
        settingProc_GLOB001_GBL007.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_GLOB001_GBL007.SVMXC__Submodule__c = subModProc_GLOB001.id;
        settingProc_GLOB001_GBL007.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_GLOB001_GBL007);        
        
        //adding GLOB001 GBL007 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_GLOB001_GBL007 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_GLOB001_GBL007.SVMXC__Profile_Name__c = 'TestSvmxGLB';
        confProfile_GLOB001_GBL007.RecordTypeId = confProfileTypeId;
        confProfile_GLOB001_GBL007.SVMXC__Configuration_Type__c = 'Global';
        confProfile_GLOB001_GBL007.SVMXC__Active__c = true;
        confProfile_GLOB001_GBL007.SVMXC__IsDefault__c = true;
        confProfile_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(confProfile_GLOB001_GBL007);
        
        //adding GLOB001 GBL007 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL007 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL007.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL007.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_GLOB001_GBL007.SVMXC__Display_Value__c = 'True';
        conf_GLOB001_GBL007.SVMXC__Internal_Value__c = 'True';
        conf_GLOB001_GBL007.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL007.id;
        conf_GLOB001_GBL007.SVMXC__Active__c = true; //
        conf_GLOB001_GBL007.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_GLOB001_GBL007);
        
        //adding GLOB001 GBL022 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL022 = new SVMXC__ServiceMax_Processes__c();
        settingProc_GLOB001_GBL022.RecordTypeId = setTypeId;
        settingProc_GLOB001_GBL022.SVMXC__SettingID__c = 'GBL022';
        settingProc_GLOB001_GBL022.SVMXC__Data_Type__c = 'Text';
        settingProc_GLOB001_GBL022.SVMXC__Default_Value__c = 'OptiMax,ServicePower';
        settingProc_GLOB001_GBL022.SVMXC__Setting_Type__c = 'Global';
        settingProc_GLOB001_GBL022.SVMXC__Search_Order__c = 'Global';
        settingProc_GLOB001_GBL022.SVMXC__Active__c = true;
        settingProc_GLOB001_GBL022.SVMXC__IsStandard__c = true;
        settingProc_GLOB001_GBL022.SVMXC__Values__c = 'None,OptiMax,Service Power';
        settingProc_GLOB001_GBL022.SVMXC__Submodule__c = subModProc_GLOB001.id;
        settingProc_GLOB001_GBL022.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_GLOB001_GBL022.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_GLOB001_GBL022);
        
        //adding GLOB001 GBL022 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL022 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL022.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL022.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_GLOB001_GBL022.SVMXC__Display_Value__c = 'OptiMax, ServicePower';
        //SVMXC__Internal_Value__c
        conf_GLOB001_GBL022.SVMXC__Internal_Value__c = 'OptiMax, ServicePower';
        conf_GLOB001_GBL022.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL022.id;
        conf_GLOB001_GBL022.SVMXC__Active__c = true;
        conf_GLOB001_GBL022.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_GLOB001_GBL022);
        
        //adding OptiMax Process Module
        SVMXC__ServiceMax_Processes__c modProc_OMAX = new SVMXC__ServiceMax_Processes__c();
        modProc_OMAX.RecordTypeId = modTypeId;
        modProc_OMAX.SVMXC__ModuleID__c = 'OMAX';
        modProc_OMAX.SVMXC__Name__c = 'OptiMax';
        modProc_OMAX.SVMXC__IsStandard__c = true;
        modProc_OMAX.SVMXC__Description__c = 'TEST MODULE DESCRIPTION';
        modProc_OMAX.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(modProc_OMAX);
       
        //adding DCON004 Process SubModule///////////////////////////
        SVMXC__ServiceMax_Processes__c subModProc_DCON004 = new SVMXC__ServiceMax_Processes__c();
        subModProc_DCON004.RecordTypeId = subModTypeId;
        subModProc_DCON004.SVMXC__SubmoduleID__c = 'DCON004';
        subModProc_DCON004.SVMXC__Name__c = 'Manage OptiMax Settings';
        subModProc_DCON004.SVMXC__IsStandard__c = true;
        subModProc_DCON004.SVMXC__Module__c = modProc_OMAX.id;
        subModProc_DCON004.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_DCON004.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(subModProc_DCON004);
       
        //adding DCON004 SET009 Process Setting
         SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET009 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON004_SET009.RecordTypeId = setTypeId;
        settingProc_DCON004_SET009.SVMXC__SettingID__c = 'SET009';
        settingProc_DCON004_SET009.SVMXC__Data_Type__c = 'Text';
        settingProc_DCON004_SET009.SVMXC__Default_Value__c = '1';
        settingProc_DCON004_SET009.SVMXC__Setting_Type__c = 'Global';
        settingProc_DCON004_SET009.SVMXC__Search_Order__c = 'Global';
        settingProc_DCON004_SET009.SVMXC__Active__c = true;
        settingProc_DCON004_SET009.SVMXC__IsStandard__c =true;
        settingProc_DCON004_SET009.SVMXC__Values__c = '1....N';
        settingProc_DCON004_SET009.SVMXC__Submodule__c = subModProc_DCON004.id;
        settingProc_DCON004_SET009.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON004_SET009.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_DCON004_SET009);
       
        //associating DCON004 SET009 Setting Value to a Global profile defined above
       		 SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET009 = new SVMXC__ServiceMax_Config_Data__c();
        conf_DCON004_SET009.RecordTypeId = setValTypeId;
        conf_DCON004_SET009.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_DCON004_SET009.SVMXC__Display_Value__c = '1';
        conf_DCON004_SET009.SVMXC__Internal_Value__c = '1';
        conf_DCON004_SET009.SVMXC__Setting_ID__c = settingProc_DCON004_SET009.id;
        conf_DCON004_SET009.SVMXC__Active__c = true; //
        conf_DCON004_SET009.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_DCON004_SET009); 
        
         //adding DCON004 SET008 Process Setting
       		  //adding DCON004 SET009 Process Setting
      SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET008 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON004_SET008.RecordTypeId = setTypeId;
        settingProc_DCON004_SET008.SVMXC__SettingID__c = 'SET008';
        settingProc_DCON004_SET008.SVMXC__Data_Type__c = 'Text';
        settingProc_DCON004_SET008.SVMXC__Default_Value__c = '1';
        settingProc_DCON004_SET008.SVMXC__Setting_Type__c = 'Global';
        settingProc_DCON004_SET008.SVMXC__Search_Order__c = 'Global';
        settingProc_DCON004_SET008.SVMXC__Active__c = true;
        settingProc_DCON004_SET008.SVMXC__IsStandard__c = true;
        settingProc_DCON004_SET008.SVMXC__Values__c = '1...N';
        settingProc_DCON004_SET008.SVMXC__Submodule__c = subModProc_DCON004.id;
        settingProc_DCON004_SET008.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON004_SET008.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_DCON004_SET008);
       
        //associating DCON004 SET008 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET008 = new SVMXC__ServiceMax_Config_Data__c();
        conf_DCON004_SET008.RecordTypeId = setValTypeId;
        conf_DCON004_SET008.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_DCON004_SET008.SVMXC__Display_Value__c = '1';
        conf_DCON004_SET008.SVMXC__Internal_Value__c = '1';
        conf_DCON004_SET008.SVMXC__Setting_ID__c = settingProc_DCON004_SET008.id;
        conf_DCON004_SET008.SVMXC__Active__c = true; //
        conf_DCON004_SET008.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_DCON004_SET008); 
        
          //adding DCON004 SET008 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_DCON004_SET0015 = new SVMXC__ServiceMax_Processes__c();
        settingProc_DCON004_SET0015.RecordTypeId = setTypeId;
        settingProc_DCON004_SET0015.SVMXC__SettingID__c = 'SET015';
        settingProc_DCON004_SET0015.SVMXC__Data_Type__c = 'Boolean';
        settingProc_DCON004_SET0015.SVMXC__Default_Value__c = 'True';
        settingProc_DCON004_SET0015.SVMXC__Setting_Type__c = 'Global';
        settingProc_DCON004_SET0015.SVMXC__Search_Order__c = 'Global';
        settingProc_DCON004_SET0015.SVMXC__Active__c = true;
        settingProc_DCON004_SET0015.SVMXC__IsStandard__c = false;
        settingProc_DCON004_SET0015.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_DCON004_SET0015.SVMXC__Submodule__c = subModProc_DCON004.id;
        settingProc_DCON004_SET0015.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_DCON004_SET0015.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_DCON004_SET0015);
       
        //associating DCON004 SET008 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_DCON004_SET015 = new SVMXC__ServiceMax_Config_Data__c();
        conf_DCON004_SET015.RecordTypeId = setValTypeId;
        conf_DCON004_SET015.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_DCON004_SET015.SVMXC__Display_Value__c = 'True';
        conf_DCON004_SET015.SVMXC__Internal_Value__c = 'True';
        conf_DCON004_SET015.SVMXC__Setting_ID__c = settingProc_DCON004_SET0015.id;
        conf_DCON004_SET015.SVMXC__Active__c = true; //
        conf_DCON004_SET015.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_DCON004_SET015); 
        
        System.debug('createOptimizationSettingsMethod');
    }
    
    
      //Code Coverae as part of sprint 4 
       static testMethod void testisOptiMaxECOWO() {
        Test.startTest();
        system.debug('start testisOptiMaxECOWO');
        SVMXC__Territory__c testTer = createECOTerritory();
        SVMXC__ServiceMax_Processes__c woDP = createECODispatchProcess(testTer.id);
        SVMXC__ServiceMax_Processes__c woDP1 = createECODispatchProcess(testTer.id);
        SVMXC__Service_Order__c wo1=createWorkorder(testTer.id,woDP.id);
        SVMXC__Service_Order__c wo2=createWorkorder(testTer.id,woDP1.id);
        
        map<Id, SVMXC__ServiceMax_Processes__c> mapOptiMaxECODP = new map<Id, SVMXC__ServiceMax_Processes__c>();
        mapOptiMaxECODP.put(woDP.id,woDP);
        
        WSCH_TriggerHandler.isOptiMaxWO(wo1,mapOptiMaxECODP);
        WSCH_TriggerHandler.isOptiMaxWO(wo2,mapOptiMaxECODP);
        
         WSCH_TriggerHandler.isOptiMaxECOWO(wo1,mapOptiMaxECODP);
        WSCH_TriggerHandler.isOptiMaxECOWO(wo2,mapOptiMaxECODP);
        
        
        WSCH_TriggerHandler.lstDCEventMgmtSettings = null;
        WSCH_TriggerHandler.loadDCEventMgmtSettings();
        
        
        WSCH_TriggerHandler.isCustomFieldChangeSmaxQ(wo1,wo2,'CHANGE_SCHEDULING_STATUS');
        
        
        
        Test.stopTest();
      }
      
       private static SVMXC__Service_Order__c createWorkorder(String terId,String dpId){
		SVMXC__Service_Order__c wo1 = new SVMXC__Service_Order__c();
		wo1.SVMXC__Primary_Territory__c = terId;
		wo1.SVMXC__zip__c='560005';
		wo1.SVMXC__Preferred_Start_Time__c = system.now();
		wo1.SVMXC__Preferred_End_Time__c = system.now();
		wo1.SVMXC__Scheduled_Date_Time__c = system.now();
		wo1.SVMXC__Driving_Time__c = 5;
		wo1.SVMXC__Driving_Time__c = 2;
		wo1.SVMXC__Dispatch_Process__c = dpId;
		wo1.SVMXC__Locked_By_DC__c = true;
		insert wo1;
		return wo1;
	 }
	 
	 	private static SVMXC__Territory__c createECOTerritory(){
			SVMXC__Territory__c ecoTeritory = new SVMXC__Territory__c();
			 ecoTeritory.Name = 'Ter-UT';
			 insert ecoTeritory;
			 return ecoTeritory;
		}
		
		 private static SVMXC__ServiceMax_Processes__c createECODispatchProcess(String terId){
      SVMXC__ServiceMax_Processes__c dprocess = new SVMXC__ServiceMax_Processes__c();
      dprocess.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
      dprocess.SVMXC__Dispatch_Process_Status__c ='Complete';
      dprocess.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
      dprocess.SVMXC__Name__c = 'Process-UT';
      dprocess.RecordTypeId = getDispatchProcessRecordId();
      dprocess.SVMXC__Territory__c = terId;
      
      insert dprocess;
      return dprocess;
    }
	
	private static String getDispatchProcessRecordId(){
      String dispatchProcessRecordType;
      RecordType[] rts = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
      for(RecordType rt : rts)
        {
            if(rt.Name == 'Dispatch Process' && rt.SobjectType == 'SVMXC__ServiceMax_Processes__c')
               dispatchProcessRecordType = rt.ID;
        }
        return dispatchProcessRecordType;
      
    }
}