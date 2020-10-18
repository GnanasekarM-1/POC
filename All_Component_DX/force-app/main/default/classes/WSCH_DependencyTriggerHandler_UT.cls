@isTest
public with sharing class WSCH_DependencyTriggerHandler_UT {
    
    public static testMethod void testDependency(){
    System.Test.StartTest();
    SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
    workOrder1.SVMXC__Zip__c = '75001';
    workOrder1.SVMXC__Order_Status__c = 'Open';
    workOrder1.SVMXC__Service_Duration__c = 3600;
    workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
    insert workOrder1;
    SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
    workOrder2.SVMXC__Zip__c = '75001';
    workOrder2.SVMXC__Order_Status__c='Open';
    workOrder2.SVMXC__Service_Duration__c = 3600;
    workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
    insert workOrder2;
    SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
    dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
    insert dependencyManagement;
    SVMXC__Service_Order_Dependency__c dependencyRecord = new SVMXC__Service_Order_Dependency__c();
    dependencyRecord.SVMXC__Primary_Work_Order__c = workOrder1.Id;
    dependencyRecord.SVMXC__Secondary_Work_Order__c = workOrder2.Id;
    dependencyRecord.SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary';
    dependencyRecord.SVMXC__Dependency_Group__c = dependencyManagement.id;
    dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 30;
    dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
    dependencyRecord.SVMXC__Minimum_Time_Deviation__c = 60;
    dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
    dependencyRecord.SVMXC__Targeted_Time_Difference__c = 45;
    dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
    dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
    insert dependencyRecord;
    dependencyRecord.SVMXC__Time_Dependency__c = 'Set End Time of Secondary relative to the End Time of Primary';
    update dependencyRecord;
    dependencyRecord.SVMXC__Minimum_Time_Deviation__c = 80;
    update dependencyRecord;
    /*dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'hours';
    update dependencyRecord;
    dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 20;
    update dependencyRecord;
    dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'minutes';
    update dependencyRecord;
    dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'test';
    update dependencyRecord;
    dependencyRecord.SVMXC__Targeted_Time_Difference__c = 40;
    update dependencyRecord;
    dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'hours';
    update dependencyRecord;*/
    List<SVMXC__Service_Order_Dependency__c> dependencyList = new List<SVMXC__Service_Order_Dependency__c>();
    dependencyList.add(dependencyRecord);
        
    List<String> multiJobIdList = new List<String>();
    multiJobIdList.add('BDG-01');
    List<String> WoIds = new List<String>();
    WoIds.add(workOrder1.Id);
    WoIds.add(workOrder2.Id);
    //WSCH_DependencyTriggerHandler.cancelDependencyGroup(multiJobIdList, WoIds);
    WSCH_DependencyTriggerHandler.deleteWODependencyFromGroup(dependencyList);
    System.Test.StopTest();
    
    }
    
    public static testMethod void testDependency2(){
    System.Test.StartTest();
    SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
    workOrder1.SVMXC__Zip__c = '75001';
    workOrder1.SVMXC__Order_Status__c = 'Open';
    workOrder1.SVMXC__Service_Duration__c = 3600;
    workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
    insert workOrder1;
    SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
    workOrder2.SVMXC__Zip__c = '75001';
    workOrder2.SVMXC__Order_Status__c='Open';
    workOrder2.SVMXC__Service_Duration__c = 3600;
    workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
    insert workOrder2;
    SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
    dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
    insert dependencyManagement;
    SVMXC__Service_Order_Dependency__c dependencyRecord = new SVMXC__Service_Order_Dependency__c();
    dependencyRecord.SVMXC__Primary_Work_Order__c = workOrder1.Id;
    dependencyRecord.SVMXC__Secondary_Work_Order__c = workOrder2.Id;
    dependencyRecord.SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary';
    dependencyRecord.SVMXC__Dependency_Group__c = dependencyManagement.id;
    dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 30;
    dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
    dependencyRecord.SVMXC__Minimum_Time_Deviation__c = 60;
    dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
    dependencyRecord.SVMXC__Targeted_Time_Difference__c = 45;
    dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
    dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
    insert dependencyRecord;
    dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'hours';
    update dependencyRecord;
    dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 20;
    update dependencyRecord;
    dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'minutes';
    update dependencyRecord;
    /*dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'test';
    update dependencyRecord;
    dependencyRecord.SVMXC__Targeted_Time_Difference__c = 40;
    update dependencyRecord;
    dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'hours';
    update dependencyRecord;*/
    List<SVMXC__Service_Order_Dependency__c> dependencyList = new List<SVMXC__Service_Order_Dependency__c>();
    dependencyList.add(dependencyRecord);
        
    List<String> multiJobIdList = new List<String>();
    multiJobIdList.add('BDG-01');
    List<String> WoIds = new List<String>();
    WoIds.add(workOrder1.Id);
    WoIds.add(workOrder2.Id);
    //WSCH_DependencyTriggerHandler.cancelDependencyGroup(multiJobIdList, WoIds);
    WSCH_DependencyTriggerHandler.deleteWODependencyFromGroup(dependencyList);
    System.Test.StopTest();
    }
    
    public static testMethod void testDependency3(){
        System.Test.StartTest();
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75001';
        workOrder1.SVMXC__Order_Status__c = 'Open';
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
        insert workOrder1;
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Zip__c = '75001';
        workOrder2.SVMXC__Order_Status__c='Open';
        workOrder2.SVMXC__Service_Duration__c = 3600;
        workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = True;
        insert workOrder2;
        SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
        dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
        insert dependencyManagement;
        SVMXC__Service_Order_Dependency__c dependencyRecord = new SVMXC__Service_Order_Dependency__c();
        dependencyRecord.SVMXC__Primary_Work_Order__c = workOrder1.Id;
        dependencyRecord.SVMXC__Secondary_Work_Order__c = workOrder2.Id;
        dependencyRecord.SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary';
        dependencyRecord.SVMXC__Dependency_Group__c = dependencyManagement.id;
        dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 60;
        dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord.SVMXC__Minimum_Time_Deviation__c = 30;
        dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord.SVMXC__Targeted_Time_Difference__c = 45;
        dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
        dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
        insert dependencyRecord;
        dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'test';
        update dependencyRecord;
        dependencyRecord.SVMXC__Targeted_Time_Difference__c = 40;
        update dependencyRecord;
        dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'hours';
        update dependencyRecord;
        List<SVMXC__Service_Order_Dependency__c> dependencyList = new List<SVMXC__Service_Order_Dependency__c>();
        dependencyList.add(dependencyRecord);
            
        List<String> multiJobIdList = new List<String>();
        multiJobIdList.add('BDG-01');
        List<String> WoIds = new List<String>();
        WoIds.add(workOrder1.Id);
        WoIds.add(workOrder2.Id);
        //WSCH_DependencyTriggerHandler.cancelDependencyGroup(multiJobIdList, WoIds);
        WSCH_DependencyTriggerHandler.deleteWODependencyFromGroup(dependencyList);
        System.Test.StopTest();
    }

    public static testMethod void testDependency4() {

        System.Test.StartTest();

        createOptimizationSettings();

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

        Date dt = Date.today();
        dt = dt.addDays(1);
        
        SVMXC__ServiceMax_Processes__c svmxprocess1 = new SVMXC__ServiceMax_Processes__c();
        svmxprocess1.SVMXC__Name__c = 'Real Time Optimization test';
        svmxprocess1.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess1.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess1.SVMXC__Dispatch_Method__c='Real Time Optimization';
        svmxprocess1.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        svmxprocess1.SVMXC__End_Date__c = dt;
        svmxprocess1.SVMXC__Calendar_End_Days__c = 4;
        svmxprocess1.SVMXC__Full_Run_Unit__c = 'DAYS';
        svmxprocess1.SVMXC__Calendar_Start_Days__c = 2;
        svmxprocess1.SVMXC__Frequency__c = 2;
        insert svmxprocess1;
        
        BusinessHours lstOfBusinessHours1;
        lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,MondayStartTime,MondayEndTime,
                            TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                            ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                            SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                            WHERE IsDefault = TRUE AND IsActive = TRUE Limit 1];

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess1.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        territory.SVMXC__Per_Mile_Cost__c = 100;
        territory.SVMXC__Max_Distance__c = 20;
        territory.SVMXC__Average_Speed__c = 50;
        territory.SVMXC__Fixed_Cost__c = 20;
        territory.SVMXC__Per_hour_Cost__c = 30;
        insert territory;
        
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'California';
        territory1.SVMXC__Optimizer_External_ID__c = 'CA';
        territory1.SVMXC__Per_Mile_Cost__c = 100;
        territory1.SVMXC__Max_Distance__c = 20;
        territory1.SVMXC__Average_Speed__c = 50;
        territory1.SVMXC__Fixed_Cost__c = 20;
        territory1.SVMXC__Per_hour_Cost__c = 30;
        insert territory1;

        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = svmxprocess1.id;
        objSVMXJob.SVMXC__Territory__c = territory.Id;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'Running';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Status__c = '100';
        objSVMXJob.SVMXC__Type__c = 'ECO';            
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory.Id;
        insert technician;
        
        SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'Max';
        technician1.SVMXC__Service_Group__c  = team.Id;
        technician1.SVMXC__Service_Territory__c = territory.Id;
        insert technician1;

        Datetime nowTime = Datetime.now();
        Datetime scheduleTime = nowTime.addHours(24);
        
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75001';
        workOrder1.SVMXC__Order_Status__c='Open';
        workOrder1.SVMXC__Group_Member__c = technician.id;
        workOrder1.SVMXC__Scheduled_Date_Time__c = scheduleTime;
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__OptiMax_Status__c ='';
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
        workOrder1.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        workOrder1.SVMXC__Country__c = 'India';
        
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Zip__c = '75001';
        workOrder2.SVMXC__Order_Status__c='Open';
        workOrder2.SVMXC__Group_Member__c = technician.id;
        workOrder2.SVMXC__Scheduled_Date_Time__c = scheduleTime;
        workOrder2.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        workOrder2.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder2.SVMXC__Locked_By_DC__c = false;
        workOrder2.SVMXC__Service_Duration__c = 3600;
        workOrder2.SVMXC__OptiMax_Status__c ='';
        workOrder2.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder2.SVMXC__Primary_Territory__c=territory.Id;
        workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder2.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
        workOrder2.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        workOrder2.SVMXC__Country__c = 'India';

        SVMXC__Service_Order__c workOrder3 = new SVMXC__Service_Order__c();
        workOrder3.SVMXC__Zip__c = '75001';
        workOrder3.SVMXC__Order_Status__c='Open';
        workOrder3.SVMXC__Group_Member__c = technician.id;
        workOrder3.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        workOrder3.SVMXC__Scheduled_Date_Time__c = scheduleTime;
        workOrder3.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder3.SVMXC__Locked_By_DC__c = false;
        workOrder3.SVMXC__Service_Duration__c = 3600;
        workOrder3.SVMXC__OptiMax_Status__c ='';
        workOrder3.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder3.SVMXC__Primary_Territory__c=territory.Id;
        workOrder3.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder3.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
        workOrder3.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        workOrder3.SVMXC__Country__c = 'India';

        List<SVMXC__Service_Order__c> lstOfWOs = new List<SVMXC__Service_Order__c>();
        lstOfWOs.add(workOrder1);
        lstOfWOs.add(workOrder2);
        lstOfWOs.add(workOrder3);
        insert lstOfWOs;

        SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
        dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
        insert dependencyManagement;

        SVMXC__Service_Order_Dependency__c dependencyRecord = new SVMXC__Service_Order_Dependency__c();
        dependencyRecord.SVMXC__Primary_Work_Order__c = workOrder1.Id;
        dependencyRecord.SVMXC__Secondary_Work_Order__c = workOrder2.Id;
        dependencyRecord.SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary';
        dependencyRecord.SVMXC__Dependency_Group__c = dependencyManagement.id;
        dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 60;
        dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord.SVMXC__Minimum_Time_Deviation__c = 30;
        dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord.SVMXC__Targeted_Time_Difference__c = 45;
        dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
        dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
        insert dependencyRecord;

        List<SVMXC__Service_Order_Dependency__c> dependencyList = new List<SVMXC__Service_Order_Dependency__c>();
        dependencyList.add(dependencyRecord);

        SVMXC__Service_Order_Dependency__c dependencyRecord1 = new SVMXC__Service_Order_Dependency__c();
        dependencyRecord1.SVMXC__Primary_Work_Order__c = workOrder2.Id;
        dependencyRecord1.SVMXC__Secondary_Work_Order__c = workOrder3.Id;
        dependencyRecord1.SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary';
        dependencyRecord1.SVMXC__Dependency_Group__c = dependencyManagement.id;
        dependencyRecord1.SVMXC__Maximum_Time_Deviation__c = 60;
        dependencyRecord1.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord1.SVMXC__Minimum_Time_Deviation__c = 30;
        dependencyRecord1.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord1.SVMXC__Targeted_Time_Difference__c = 45;
        dependencyRecord1.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
        dependencyRecord1.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
        insert dependencyRecord1;
        dependencyList.add(dependencyRecord1);

        WSCH_DependencyTriggerHandler.doQualifyInsertDependency(dependencyList,lstOfWOs);

        System.Test.StopTest();
    }

    public static testMethod void testDependency5() {

        System.Test.StartTest();

        createOptimizationSettings();

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

        Date dt = Date.today();
        dt = dt.addDays(1);

        SVMXC__ServiceMax_Processes__c svmxprocess1 = new SVMXC__ServiceMax_Processes__c();
        svmxprocess1.SVMXC__Name__c = 'Real Time Optimization test';
        svmxprocess1.RecordTypeId = DispatchProRecordTypeId;
        svmxprocess1.SVMXC__Dispatch_Process_Status__c='Complete';
        svmxprocess1.SVMXC__Dispatch_Method__c='Real Time Optimization';
        svmxprocess1.SVMXC__Dispatch_Timezone__c= 'Asia/Colombo';
        svmxprocess1.SVMXC__End_Date__c = dt;
        svmxprocess1.SVMXC__Calendar_End_Days__c = 4;
        svmxprocess1.SVMXC__Full_Run_Unit__c = 'DAYS';
        svmxprocess1.SVMXC__Calendar_Start_Days__c = 2;
        svmxprocess1.SVMXC__Frequency__c = 2;
        insert svmxprocess1;
        
        BusinessHours lstOfBusinessHours1;
        lstOfBusinessHours1 = [SELECT Id,IsActive,IsDefault,MondayStartTime,MondayEndTime,
                            TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,
                            ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,
                            SaturdayEndTime,SundayStartTime,SundayEndTime FROM BusinessHours
                            WHERE IsDefault = TRUE AND IsActive = TRUE Limit 1];

        SVMXC__ServiceMax_Config_Data__c oConf = new SVMXC__ServiceMax_Config_Data__c();
        oConf.SVMXC__Expression_Type__c = 'DISP_Process_Entry';
        oConf.SVMXC__Field_Name__c='SVMXC__Order_Status__c';
        oConf.SVMXC__Display_Type__c = 'STRING';
        oConf.SVMXC__Operand__c='asdfgg';
        oConf.SVMXC__Operator__c='eq';
        oConf.RecordTypeId = ExpressionRTypeId;
        oConf.SVMXC__Sequence__c=1;
        oConf.SVMXC__Expression_Rule__c = svmxprocess1.id;
        insert oConf;

        SVMXC__Territory__c territory = new SVMXC__Territory__c();
        territory.name = 'South Central Region';
        territory.SVMXC__Optimizer_External_ID__c = 'SOU';
        territory.SVMXC__Per_Mile_Cost__c = 100;
        territory.SVMXC__Max_Distance__c = 20;
        territory.SVMXC__Average_Speed__c = 50;
        territory.SVMXC__Fixed_Cost__c = 20;
        territory.SVMXC__Per_hour_Cost__c = 30;
        insert territory;
        
        SVMXC__Territory__c territory1 = new SVMXC__Territory__c();
        territory1.name = 'California';
        territory1.SVMXC__Optimizer_External_ID__c = 'CA';
        territory1.SVMXC__Per_Mile_Cost__c = 100;
        territory1.SVMXC__Max_Distance__c = 20;
        territory1.SVMXC__Average_Speed__c = 50;
        territory1.SVMXC__Fixed_Cost__c = 20;
        territory1.SVMXC__Per_hour_Cost__c = 30;
        insert territory1;

        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = svmxprocess1.id;
        objSVMXJob.SVMXC__Territory__c = territory.Id;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'IDLE';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Status__c = '100';
        objSVMXJob.SVMXC__Type__c = 'ECO';            
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'testTeam';
        insert team;
        
        SVMXC__Service_Group_Members__c technician = new SVMXC__Service_Group_Members__c();
        technician.Name = 'John';
        technician.SVMXC__Service_Group__c  = team.Id;
        technician.SVMXC__Service_Territory__c = territory.Id;
        insert technician;
        
        SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'Max';
        technician1.SVMXC__Service_Group__c  = team.Id;
        technician1.SVMXC__Service_Territory__c = territory.Id;
        insert technician1;

        Datetime nowTime = Datetime.now();
        Datetime scheduleTime = nowTime.addHours(24);
        
        SVMXC__Service_Order__c workOrder1 = new SVMXC__Service_Order__c();
        workOrder1.SVMXC__Zip__c = '75001';
        workOrder1.SVMXC__Order_Status__c='Open';
        workOrder1.SVMXC__Group_Member__c = technician.id;
        workOrder1.SVMXC__Scheduled_Date_Time__c = scheduleTime;
        workOrder1.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        workOrder1.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder1.SVMXC__Locked_By_DC__c = false;
        workOrder1.SVMXC__Service_Duration__c = 3600;
        workOrder1.SVMXC__OptiMax_Status__c ='';
        workOrder1.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder1.SVMXC__Primary_Territory__c=territory.Id;
        workOrder1.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder1.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
        workOrder1.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        workOrder1.SVMXC__Country__c = 'India';
        
        SVMXC__Service_Order__c workOrder2 = new SVMXC__Service_Order__c();
        workOrder2.SVMXC__Zip__c = '75001';
        workOrder2.SVMXC__Order_Status__c='Open';
        workOrder2.SVMXC__Group_Member__c = technician.id;
        workOrder2.SVMXC__Scheduled_Date_Time__c = scheduleTime;
        workOrder2.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        workOrder2.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder2.SVMXC__Locked_By_DC__c = false;
        workOrder2.SVMXC__Service_Duration__c = 3600;
        workOrder2.SVMXC__OptiMax_Status__c ='';
        workOrder2.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder2.SVMXC__Primary_Territory__c=territory.Id;
        workOrder2.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder2.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
        workOrder2.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        workOrder2.SVMXC__Country__c = 'India';

        SVMXC__Service_Order__c workOrder3 = new SVMXC__Service_Order__c();
        workOrder3.SVMXC__Zip__c = '75001';
        workOrder3.SVMXC__Order_Status__c='Open';
        workOrder3.SVMXC__Group_Member__c = technician.id;
        workOrder3.SVMXC__Dispatch_Process__c =  svmxprocess1.id;
        workOrder3.SVMXC__Scheduled_Date_Time__c = scheduleTime;
        workOrder3.SVMXC__OptiMax_Error_Occurred__c = false;
        workOrder3.SVMXC__Locked_By_DC__c = false;
        workOrder3.SVMXC__Service_Duration__c = 3600;
        workOrder3.SVMXC__OptiMax_Status__c ='';
        workOrder3.SVMXC__Scheduling_Change_Token__c = 'CHANGE_CREATE_WO';
        workOrder3.SVMXC__Primary_Territory__c=territory.Id;
        workOrder3.SVMXC__Schedule_As_A_Dependent_Work_Order__c = true;
        workOrder3.SVMXC__Acknowledged_By_Technician_Date_Time__c=DateTime.now();
        workOrder3.SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 10;
        workOrder3.SVMXC__Country__c = 'India';

        List<SVMXC__Service_Order__c> lstOfWOs = new List<SVMXC__Service_Order__c>();
        lstOfWOs.add(workOrder1);
        lstOfWOs.add(workOrder2);
        lstOfWOs.add(workOrder3);
        insert lstOfWOs;

        SVMXC__Dependency_Management__c dependencyManagement = new SVMXC__Dependency_Management__c();
        dependencyManagement.SVMXC__Dependency_Group_Name__c = 'BDG-01';
        insert dependencyManagement;

        SVMXC__Service_Order_Dependency__c dependencyRecord = new SVMXC__Service_Order_Dependency__c();
        dependencyRecord.SVMXC__Primary_Work_Order__c = workOrder1.Id;
        dependencyRecord.SVMXC__Secondary_Work_Order__c = workOrder2.Id;
        dependencyRecord.SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary';
        dependencyRecord.SVMXC__Dependency_Group__c = dependencyManagement.id;
        dependencyRecord.SVMXC__Maximum_Time_Deviation__c = 60;
        dependencyRecord.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord.SVMXC__Minimum_Time_Deviation__c = 30;
        dependencyRecord.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord.SVMXC__Targeted_Time_Difference__c = 45;
        dependencyRecord.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
        dependencyRecord.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
        insert dependencyRecord;

        List<SVMXC__Service_Order_Dependency__c> dependencyList = new List<SVMXC__Service_Order_Dependency__c>();
        dependencyList.add(dependencyRecord);

        SVMXC__Service_Order_Dependency__c dependencyRecord1 = new SVMXC__Service_Order_Dependency__c();
        dependencyRecord1.SVMXC__Primary_Work_Order__c = workOrder2.Id;
        dependencyRecord1.SVMXC__Secondary_Work_Order__c = workOrder3.Id;
        dependencyRecord1.SVMXC__Time_Dependency__c = 'Set Arrival Time of Secondary relative to the Arrival Time of Primary';
        dependencyRecord1.SVMXC__Dependency_Group__c = dependencyManagement.id;
        dependencyRecord1.SVMXC__Maximum_Time_Deviation__c = 60;
        dependencyRecord1.SVMXC__Maximum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord1.SVMXC__Minimum_Time_Deviation__c = 30;
        dependencyRecord1.SVMXC__Minimum_Time_Deviation_Units__c = 'Minutes';
        dependencyRecord1.SVMXC__Targeted_Time_Difference__c = 45;
        dependencyRecord1.SVMXC__Targeted_Time_Variance_Cost_ID__c = 'testCost';
        dependencyRecord1.SVMXC__Targeted_Time_Difference_Units__c = 'Minutes';
        insert dependencyRecord1;
        dependencyList.add(dependencyRecord1);

        WSCH_DependencyTriggerHandler.doQualifyInsertDependency(dependencyList,lstOfWOs);
        
        delete dependencyManagement;

        System.Test.StopTest();
    }

    private static void createOptimizationSettings(){
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

        //adding GLOB001 GBL010 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_GLOB001_GBL010 = new SVMXC__ServiceMax_Processes__c();
        settingProc_GLOB001_GBL010.RecordTypeId = setTypeId;
        settingProc_GLOB001_GBL010.SVMXC__SettingID__c = 'GBL010';
        settingProc_GLOB001_GBL010.SVMXC__Data_Type__c = 'Boolean';
        settingProc_GLOB001_GBL010.SVMXC__Default_Value__c = 'True';
        settingProc_GLOB001_GBL010.SVMXC__Setting_Type__c = 'Global';
        settingProc_GLOB001_GBL010.SVMXC__Search_Order__c = 'Global';
        settingProc_GLOB001_GBL010.SVMXC__Active__c = true;
        settingProc_GLOB001_GBL010.SVMXC__IsStandard__c = true;
        settingProc_GLOB001_GBL010.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_GLOB001_GBL010.SVMXC__Submodule__c = subModProc_GLOB001.id;
        settingProc_GLOB001_GBL010.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_GLOB001_GBL010);        
        
        //adding GLOB001 GBL010 Configuration Profile
        SVMXC__ServiceMax_Config_Data__c confProfile_GLOB001_GBL010 = new SVMXC__ServiceMax_Config_Data__c();
        confProfile_GLOB001_GBL010.SVMXC__Profile_Name__c = 'TestSvmxGLB';
        confProfile_GLOB001_GBL010.RecordTypeId = confProfileTypeId;
        confProfile_GLOB001_GBL010.SVMXC__Configuration_Type__c = 'Global';
        confProfile_GLOB001_GBL010.SVMXC__Active__c = true;
        confProfile_GLOB001_GBL010.SVMXC__IsDefault__c = true;
        confProfile_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(confProfile_GLOB001_GBL010);
        
        //adding GLOB001 GBL010 Setting Value
        SVMXC__ServiceMax_Config_Data__c conf_GLOB001_GBL010 = new SVMXC__ServiceMax_Config_Data__c();
        conf_GLOB001_GBL010.RecordTypeId = setValTypeId;
        conf_GLOB001_GBL010.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL010.id;
        conf_GLOB001_GBL010.SVMXC__Display_Value__c = 'https://optimax-dev.servicemax.com:7343/optimax/optimization';
        conf_GLOB001_GBL010.SVMXC__Internal_Value__c = 'https://optimax-dev.servicemax.com:7343/optimax/optimization';
        conf_GLOB001_GBL010.SVMXC__Setting_ID__c = settingProc_GLOB001_GBL010.id;
        conf_GLOB001_GBL010.SVMXC__Active__c = true; //
        conf_GLOB001_GBL010.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_GLOB001_GBL010);
        
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
        
        //adding OMAX001 Process SubModule
        SVMXC__ServiceMax_Processes__c subModProc_OMAX001 = new SVMXC__ServiceMax_Processes__c();
        subModProc_OMAX001.RecordTypeId = subModTypeId;
        subModProc_OMAX001.SVMXC__SubmoduleID__c = 'OMAX001';
        subModProc_OMAX001.SVMXC__Name__c = 'Manage OptiMax Settings';
        subModProc_OMAX001.SVMXC__IsStandard__c = true;
        subModProc_OMAX001.SVMXC__Module__c = modProc_OMAX.id;
        subModProc_OMAX001.SVMXC__Description__c = 'TEST SUBMODULE DESCRIPTION';
        subModProc_OMAX001.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(subModProc_OMAX001);
        
        //adding OMAX001 SET00999 Process Setting
        SVMXC__ServiceMax_Processes__c settingProc_OMAX001_SET00999 = new SVMXC__ServiceMax_Processes__c();
        settingProc_OMAX001_SET00999.RecordTypeId = setTypeId;
        settingProc_OMAX001_SET00999.SVMXC__SettingID__c = 'SET00999';
        settingProc_OMAX001_SET00999.SVMXC__Data_Type__c = 'Boolean';
        settingProc_OMAX001_SET00999.SVMXC__Default_Value__c = 'True';
        settingProc_OMAX001_SET00999.SVMXC__Setting_Type__c = 'Global';
        settingProc_OMAX001_SET00999.SVMXC__Search_Order__c = 'Global';
        settingProc_OMAX001_SET00999.SVMXC__Active__c = true;
        settingProc_OMAX001_SET00999.SVMXC__IsStandard__c = false;
        settingProc_OMAX001_SET00999.SVMXC__Values__c = 'TRUE~|~FALSE';
        settingProc_OMAX001_SET00999.SVMXC__Submodule__c = subModProc_OMAX001.id;
        settingProc_OMAX001_SET00999.SVMXC__Description__c = 'TEST PROCESS DESCRIPTION';
        settingProc_OMAX001_SET00999.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(settingProc_OMAX001_SET00999);
        
        //associating OMAX001 SET00999 Setting Value to a Global profile defined above
        SVMXC__ServiceMax_Config_Data__c conf_OMAX001_SET00999 = new SVMXC__ServiceMax_Config_Data__c();
        conf_OMAX001_SET00999.RecordTypeId = setValTypeId;
        conf_OMAX001_SET00999.SVMXC__Setting_Configuration_Profile__c = confProfile_GLOB001_GBL007.id;
        conf_OMAX001_SET00999.SVMXC__Display_Value__c = 'True';
        conf_OMAX001_SET00999.SVMXC__Internal_Value__c = 'True';
        conf_OMAX001_SET00999.SVMXC__Setting_ID__c = settingProc_OMAX001_SET00999.id;
        conf_OMAX001_SET00999.SVMXC__Active__c = true; //
        conf_OMAX001_SET00999.SVMXC__Installation_Key__c = EncodingUtil.base64Encode(Blob.valueOf(userInfo.getOrganizationId().subString(0,15)));
        Database.upsert(conf_OMAX001_SET00999);
        
    }
}