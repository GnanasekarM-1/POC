@isTest(SeeAllData=true)
private class CONF_SetupScheduledSFM_UT{
    public static SVMXC__ServiceMax_Processes__c processNodes;
    static testMethod void CONF_SetupScheduledSFMTest(){
        User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()];
        RecordType schedule_Rtype;
        RecordType SFMScheduledProcess_Rtype;
        RecordType scheduleDetail_Rtype;
    
        List<RecordType> lstRecordType = [select Name,id from RecordType where (Name='Schedule' OR Name='Schedule Detail' OR Name='Schedule Header')AND (SobjectType='SVMXC__ServiceMax_Config_Data__c' OR SobjectType='SVMXC__ServiceMax_Processes__c')];
        for(RecordType rt : lstRecordType){
            if(rt.Name.equals('Schedule'))
                schedule_Rtype = rt;
            else if(rt.Name.equals('Schedule Detail'))
                scheduleDetail_Rtype = rt;
            else if(rt.Name.equals('Schedule Header'))
                SFMScheduledProcess_Rtype = rt;
        }
        
        SVMXC__ServiceMax_Processes__c objProcess1 = new SVMXC__ServiceMax_Processes__c();
        objProcess1.SVMXC__ProcessId__c = 'testProcess1';
        objProcess1.SVMXC__Name__c = 'testProcess1';        
        objProcess1.SVMXC__Description__c = 'TestDescription1';
        objProcess1.SVMXC__IsStandard__c = false;
        objProcess1.SVMXC__Active__c = true;            
        objProcess1.SVMXC__Capture_Log__c = true;
        objProcess1.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
        objProcess1.SVMXC__Assign_To_Dispatcher__c = UserInfo.getUserId();
        objProcess1.RecordTypeId = SFMScheduledProcess_Rtype.id;
        insert objProcess1;
        System.assert(objProcess1.id != null);

        SVMXC__ServiceMax_Processes__c objProcess2 = new SVMXC__ServiceMax_Processes__c();
        objProcess2.SVMXC__ProcessId__c = 'testProcess2';
        objProcess2.SVMXC__Name__c = 'testProcess2';
        objProcess2.SVMXC__Description__c = 'TestDescription2';
        objProcess2.SVMXC__IsStandard__c = false;
        objProcess2.SVMXC__Active__c = true;        
        objProcess2.SVMXC__Capture_Log__c = true;
        objProcess2.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
        objProcess2.SVMXC__Assign_To_Dispatcher__c = UserInfo.getUserId();
        objProcess2.RecordTypeId = SFMScheduledProcess_Rtype.id;
        insert objProcess2;
        System.assert(objProcess2.id != null);  
        
        List<SVMXC__ServiceMax_Config_Data__c> lstSchedule = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c objSchedule = new SVMXC__ServiceMax_Config_Data__c();
        objSchedule.SVMXC__Sequence__c = 1;
        objSchedule.SVMXC__Run_At__c = '00:00 AM';
        objSchedule.SVMXC__Schedule_Days__c = 'Sunday';
        objSchedule.SVMXC__Run_Type__c='Day of Week';
        objSchedule.SVMXC__Dispatch_Process__c = objProcess1.Id;
        objSchedule.RecordTypeId = Schedule_Rtype.Id;
        lstSchedule.add(objSchedule);
        
        SVMXC__ServiceMax_Config_Data__c objSchedule1 = new SVMXC__ServiceMax_Config_Data__c();
        objSchedule1.SVMXC__Sequence__c = 2;
        objSchedule1.SVMXC__Run_At__c = '00:00 AM';
        objSchedule1.SVMXC__Day_to_Run__c = '2';
        objSchedule1.SVMXC__Run_Type__c='Date of Month';
        objSchedule1.SVMXC__Dispatch_Process__c = objProcess1.Id;
        objSchedule1.RecordTypeId = Schedule_Rtype.Id;
        lstSchedule.add(objSchedule1);
        
        /* ---Start OF Installed Product Expression----  */ 
        SVMXC__ServiceMax_Processes__c tsWORule = new SVMXC__ServiceMax_Processes__c();
        tsWORule.SVMXC__Source_Object_Name__c = 'SVMXC__Installed_Product__c';
        tsWORule.SVMXC__MapID__c = 'IB-Expression';
        tsWORule.SVMXC__Advance_Expression__c = '1 OR 2';
        tsWORule.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'SVMX Rule' AND SobjectType ='SVMXC__ServiceMax_Processes__c' limit 1].Id;
        insert tsWORule; 
        
        SVMXC__ServiceMax_Config_Data__c tsWOLineExpression1 = new  SVMXC__ServiceMax_Config_Data__c();
        tsWOLineExpression1.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsWOLineExpression1.SVMXC__Expression_Type__c = 'EXP_Named';
        tsWOLineExpression1.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        tsWOLineExpression1.SVMXC__Expression_Rule__c = tsWORule.id;
        tsWOLineExpression1.SVMXC__Operand__c = 'Shipped';
        tsWOLineExpression1.SVMXC__Operator__c = 'eq';
        insert tsWOLineExpression1;
        
        SVMXC__ServiceMax_Config_Data__c tsWOLineExpression2 = new  SVMXC__ServiceMax_Config_Data__c();
        tsWOLineExpression2.RecordTypeId = [Select Id,SobjectType, Name From RecordType 
                                         WHERE Name = 'Expressions' AND SobjectType ='SVMXC__ServiceMax_Config_Data__c' limit 1].Id;
        tsWOLineExpression2.SVMXC__Expression_Type__c = 'EXP_Named';
        tsWOLineExpression2.SVMXC__Field_Name__c = 'SVMXC__Status__c';
        tsWOLineExpression2.SVMXC__Expression_Rule__c = tsWORule.id;
        tsWOLineExpression2.SVMXC__Operand__c = 'Installed';
        tsWOLineExpression2.SVMXC__Operator__c = 'eq';
        insert tsWOLineExpression2;
        /* ---End of IB Expression----  */ 
        
        SVMXC__ServiceMax_Config_Data__c objScheduleServices = new SVMXC__ServiceMax_Config_Data__c();
        objScheduleServices.RecordTypeId = scheduleDetail_Rtype.Id;
        objScheduleServices.SVMXC__Class_Name__c = 'IPRD_CounterReadingRecord';
        objScheduleServices.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c';
        objScheduleServices.SVMXC__Expression_Rule__c = tsWORule.Id;
        objScheduleServices.SVMXC__Schedule_Type__c = 'Services';
        objScheduleServices.SVMXC__Dispatch_Process__c = objProcess2.Id;
        
        SVMXC__ServiceMax_Config_Data__c objScheduleServicesObjectNull = new SVMXC__ServiceMax_Config_Data__c();
        objScheduleServicesObjectNull.RecordTypeId = scheduleDetail_Rtype.Id;
        objScheduleServicesObjectNull.SVMXC__Class_Name__c = 'IPRD_CounterReadingRecord';
        objScheduleServicesObjectNull.SVMXC__Expression_Rule__c = tsWORule.Id;
        objScheduleServicesObjectNull.SVMXC__Schedule_Type__c = 'Services';
        objScheduleServicesObjectNull.SVMXC__Dispatch_Process__c = objProcess2.Id;
        lstSchedule.add(objScheduleServicesObjectNull);
        
        
        SVMXC__ServiceMax_Config_Data__c objScheduleServicesClassNull = new SVMXC__ServiceMax_Config_Data__c();
        objScheduleServicesClassNull.RecordTypeId = scheduleDetail_Rtype.Id;
        objScheduleServicesClassNull.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c';
        objScheduleServicesClassNull.SVMXC__Expression_Rule__c = tsWORule.Id;
        objScheduleServicesClassNull.SVMXC__Schedule_Type__c = 'Services';
        objScheduleServicesClassNull.SVMXC__Dispatch_Process__c = objProcess2.Id;
        lstSchedule.add(objScheduleServicesClassNull);
        
        SVMXC__ServiceMax_Config_Data__c objScheduleServicesExpressionNull = new SVMXC__ServiceMax_Config_Data__c();
        objScheduleServicesExpressionNull.RecordTypeId = scheduleDetail_Rtype.Id;
        objScheduleServicesExpressionNull.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c';
        objScheduleServicesObjectNull.SVMXC__Class_Name__c = 'IPRD_CounterReadingRecord';
        objScheduleServicesExpressionNull.SVMXC__Schedule_Type__c = 'Services';
        objScheduleServicesExpressionNull.SVMXC__Dispatch_Process__c = objProcess2.Id;
        lstSchedule.add(objScheduleServicesExpressionNull);
        
        SVMXC__ServiceMax_Config_Data__c objSchedule2 = new SVMXC__ServiceMax_Config_Data__c();
        objSchedule2.SVMXC__Sequence__c = 1;
        objSchedule2.SVMXC__Run_At__c = '00:00 AM';
        objSchedule2.SVMXC__Schedule_Days__c = 'Monday';
        objSchedule2.SVMXC__Run_Type__c='Day of Week';
        objSchedule2.SVMXC__Dispatch_Process__c = objProcess2.Id;
        objSchedule2.RecordTypeId = Schedule_Rtype.Id;
        lstSchedule.add(objSchedule2);
        
        SVMXC__ServiceMax_Config_Data__c objSchedule3 = new SVMXC__ServiceMax_Config_Data__c();
        objSchedule3.SVMXC__Sequence__c = 2;
        objSchedule3.SVMXC__Run_At__c = '00:00 AM';
        objSchedule3.SVMXC__Day_to_Run__c = '12';
        objSchedule3.SVMXC__Run_Type__c='Date of Month';
        objSchedule3.SVMXC__Dispatch_Process__c = objProcess2.Id;
        objSchedule3.RecordTypeId = Schedule_Rtype.Id;
        lstSchedule.add(objSchedule3);
        insert lstSchedule;
        System.assert(lstSchedule.size() > 0);
        
        ApexPages.currentPage().getParameters().put('SVMX_Mode', 'New');
        CONF_SetupScheduledSFM objCONF_SetupScheduledSFM = new CONF_SetupScheduledSFM();
        objCONF_SetupScheduledSFM.quickSave();
        
        ApexPages.currentPage().getParameters().put('SVMX_Mode', 'Edit');
        ApexPages.currentPage().getParameters().put('SVMX_RecordId', objProcess1.id);
        CONF_SetupScheduledSFM objCONF_SetupScheduledSFM1 = new CONF_SetupScheduledSFM();
        createSFMTestData();
        objCONF_SetupScheduledSFM1.strSelectedIds = processNodes.id + ',';
        createSFMTestData();
        objCONF_SetupScheduledSFM1.strSelectedIds = objCONF_SetupScheduledSFM1.strSelectedIds + processNodes.id + ',';
        objCONF_SetupScheduledSFM1.moveToSelected();
        objCONF_SetupScheduledSFM1.strRemoverIds = processNodes.id + ',';
        objCONF_SetupScheduledSFM1.moveToAvailable();
        
        objCONF_SetupScheduledSFM1.quickSave();
        objCONF_SetupScheduledSFM1.getUserLocaleKey();
        objCONF_SetupScheduledSFM1.getUserID();
        objCONF_SetupScheduledSFM1.getUserOrgID();
        objCONF_SetupScheduledSFM1.saveClose();
        objCONF_SetupScheduledSFM1.cancel();
        objCONF_SetupScheduledSFM1.GeneralInfo();
        objCONF_SetupScheduledSFM1.Schedules();
        //listScheduleServices
        
        ApexPages.currentPage().getParameters().put('SVMX_Mode', 'Clone');
        ApexPages.currentPage().getParameters().put('SVMX_RecordId', objProcess2.id);
        CONF_SetupScheduledSFM objCONF_SetupScheduledSFM2 = new CONF_SetupScheduledSFM();
        objCONF_SetupScheduledSFM2.lstSchedules_AddRow();
        objCONF_SetupScheduledSFM2.lstScheduleService_AddRow();
        objCONF_SetupScheduledSFM2.setintSeqVal(1);
        objCONF_SetupScheduledSFM2.changeRunType();
        objCONF_SetupScheduledSFM2.strSelectedRow = '1';
        objCONF_SetupScheduledSFM2.lstSchedules_DelRow();
        objCONF_SetupScheduledSFM2.strServicesSelectedRow = '1';
        objCONF_SetupScheduledSFM2.selectedServiceObject = '1';
        objCONF_SetupScheduledSFM2.listObjectSFMExpression();
        objCONF_SetupScheduledSFM2.lstScheduleServices_DelRow();
        objCONF_SetupScheduledSFM2.setSFMScheduledProcess(new SVMXC__ServiceMax_Processes__c());
        objCONF_SetupScheduledSFM2.getSFMScheduledProcess();         
        objCONF_SetupScheduledSFM2.setlstSchedules(new List<SVMXC__ServiceMax_Config_Data__c>());
        objCONF_SetupScheduledSFM2.getlstSchedules();       
        objCONF_SetupScheduledSFM2.getlstSFMProcessSelected();
        objCONF_SetupScheduledSFM2.getlstSFMProcessAvilable();
        objCONF_SetupScheduledSFM2.getintSeqVal();      
        Integer i = objCONF_SetupScheduledSFM2.lstSchedules_HighSeqNum;
        Integer j = objCONF_SetupScheduledSFM2.lstScheduleServices_HighSeqNum;
        CONF_SetupScheduledSFM.ObjectListWrapper sfmObj= new CONF_SetupScheduledSFM.ObjectListWrapper();
        List<SelectOption> lstSelectOpvar = sfmObj.get1stList();
        List<SelectOption> lstSelectOpvar2 = sfmObj.get2ndList();
    }
    
    static void createSFMTestData(){
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];        
        
        String TargetManager = '';
        String Fieldmapping = '';
        String ProcessNodeObj = '';
        
        for(RecordType r : lstRecType)
        {
            if(r.Name == 'Target Manager')
                TargetManager = r.id;
            else if(r.Name == 'Field Mapping')
                Fieldmapping = r.id;    
            else if(r.Name == 'Process Node Objects')    
                ProcessNodeObj = r.id;
        }
        
        processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId = TargetManager ;
        processNodes.SVMXC__Name__c = 'customprocess1';
        processNodes.SVMXC__Description__c = 'newprocess1';
        processNodes.SVMXC__ProcessID__c = 'process1';
        processNodes.SVMXC__IsStandard__c = true;
        insert processNodes;
        System.assertEquals(true, processNodes != null);
        
        //Creating List of ProcessNodeObject        
        List<SVMXC__ServiceMax_Processes__c> processNodeObject = new List<SVMXC__ServiceMax_Processes__c>();

        SVMXC__ServiceMax_Processes__c processNodeObject1 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject1.SVMXC__ProcessID__c = 'process2';
        processNodeObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        processNodeObject1.SVMXC__Type__c = 'TARGETCHILD';
        processNodeObject1.RecordTypeId = ProcessNodeObj;
        processNodeObject1.SVMXC__Process__c = processNodes.Id;

        SVMXC__ServiceMax_Processes__c processNodeObject2 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject2.SVMXC__ProcessID__c = 'process3';
        processNodeObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        processNodeObject2.SVMXC__Type__c = 'TARGET';
        processNodeObject2.SVMXC__Process__c = processNodes.Id;
        processNodeObject2.RecordTypeId = ProcessNodeObj;

        SVMXC__ServiceMax_Processes__c processNodeObject3 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject3.SVMXC__ProcessID__c = 'process4';
        processNodeObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Case_Tracker__c';
        processNodeObject3.SVMXC__Type__c = 'SOURCECHILD';
        processNodeObject3.RecordTypeId = ProcessNodeObj;
        processNodeObject3.SVMXC__Process__c = processNodes.Id;

        SVMXC__ServiceMax_Processes__c processNodeObject4 = new SVMXC__ServiceMax_Processes__c();
        processNodeObject4.SVMXC__ProcessID__c = 'process5';
        processNodeObject4.SVMXC__Source_Object_Name__c = 'Case';
        processNodeObject4.SVMXC__Type__c = 'SOURCE';
        processNodeObject4.RecordTypeId = ProcessNodeObj;
        processNodeObject4.SVMXC__Process__c = processNodes.Id;

        processNodeObject.add(processNodeObject1);
        processNodeObject.add(processNodeObject2);
        processNodeObject.add(processNodeObject3);
        processNodeObject.add(processNodeObject4);
        insert processNodeObject;
        System.assertEquals(true, processNodeObject != null);
        
         //Creating List of the Config Data
        List<SVMXC__ServiceMax_Config_Data__c> processSourceUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c svmxcd1 = new SVMXC__ServiceMax_Config_Data__c();
        svmxcd1.SVMXC__Dispatch_Process__c = processNodeObject4.Id;
        svmxcd1.SVMXC__MapID__c = processNodeObject4.Id;
        svmxcd1.SVMXC__Source_Field_Name__c = 'AVMXCX1configdata';
        svmxcd1.SVMXC__Setting_ID__c = processNodeObject4.Id;
        svmxcd1.RecordTypeId = Fieldmapping ;

        SVMXC__ServiceMax_Config_Data__c svmxcd2 = new SVMXC__ServiceMax_Config_Data__c();
        svmxcd2.SVMXC__Dispatch_Process__c = processNodeObject4.Id;
        svmxcd2.SVMXC__MapID__c = processNodeObject4.Id;
        svmxcd2.SVMXC__Source_Field_Name__c = 'AVMXCX1configdata123';
        svmxcd2.SVMXC__Setting_ID__c = processNodeObject4.Id;
        
        processSourceUpdates.add(svmxcd1);
        processSourceUpdates.add(svmxcd2);
        insert processSourceUpdates;
        System.assertEquals(true, processSourceUpdates != null);
    }
    
}