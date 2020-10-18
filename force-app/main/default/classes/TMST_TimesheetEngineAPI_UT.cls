@isTest
private class TMST_TimesheetEngineAPI_UT {
  static testMethod void testTMST_TimesheetEngineAPI() {
    
    SVMXC__Timesheet__c tsHeader = new SVMXC__Timesheet__c();
    tsHeader.SVMXC__Status__c = 'Open';
    tsHeader.SVMXC__User__c = Userinfo.getuserid();
    tsHeader.SVMXC__Start_Date__c = System.today().addDays(-4);
    tsHeader.SVMXC__End_Date__c = System.today().addDays(3);
    BusinessHours stdBusinessHours = [select id from BusinessHours where Name = 'Default'];
    tsHeader.SVMXC__SM_Business_Hours__c = stdBusinessHours.id;
    insert tsHeader;
    
    SVMXC__Timesheet__c tsHeaderold = new SVMXC__Timesheet__c();
    tsHeaderold.SVMXC__Status__c = 'Open';
    tsHeaderold.SVMXC__User__c = Userinfo.getuserid();
    tsHeaderold.SVMXC__Start_Date__c = System.today().addDays(-10);
    tsHeaderold.SVMXC__End_Date__c = System.today().addDays(-5);
    tsHeaderold.SVMXC__SM_Business_Hours__c = stdBusinessHours.id;
    insert tsHeaderold;
    
    List<SVMXC__Timesheet_Day_Entry__c> lstTMSTDay = setTMSTDayEntry(tsHeader.id);
    
    setUpData('Technician Record');
    
    SVMXC__Service_Order__c wd = new SVMXC__Service_Order__c();
    wd.SVMXC__Order_Status__c = 'Open';
    wd.SVMXC__Preferred_Business_Hours__c = stdBusinessHours.id;
    insert wd;
    
    SVMXC__Service_Order_Line__c wdLine = new SVMXC__Service_Order_Line__c();
    wdLine.SVMXC__Is_Billable__c = true;
    wdLine.SVMXC__Line_Type__c = 'Labor';
    wdLine.SVMXC__Closed_By__c = Userinfo.getuserid();
    wdLine.SVMXC__Start_Date_and_Time__c = system.today() - 2;
    wdLine.SVMXC__End_Date_and_Time__c = system.today();
    wdLine.SVMXC__Service_Order__c = wd.id;
    insert wdLine;
    
    SVMXC__Service_Group__c serviceGrp = new SVMXC__Service_Group__c();
    serviceGrp.Name = 'Bangalore Group';
    serviceGrp.SVMXC__Active__c = true;
    insert serviceGrp;
    
    SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
    tech.SVMXC__Salesforce_User__c = Userinfo.getuserid();
    tech.Name = 'Test Tech';
    tech.SVMXC__Service_Group__c = serviceGrp.id;
    insert tech;
    
    SVMXC__SVMX_Event__c sEvent = new SVMXC__SVMX_Event__c();
    sEvent.SVMXC__StartDateTime__c = system.today() - 2;
    sEvent.SVMXC__EndDateTime__c = system.today();
    sEvent.Name = 'Test';
    sEvent.SVMXC__Service_Order__c = wd.id;
    sEvent.SVMXC__SM_Status__c = 'Confirmed';
    sEvent.SVMXC__Technician__c = tech.id;
    insert sEvent;
    
    Event ev = new Event();
    ev.OwnerId = Userinfo.getuserid();
    ev.Type = 'Email';
    ev.Subject = 'Email';
    ev.StartDateTime = system.today() - 2;
    ev.EndDateTime = system.today();
    ev.ActivityDate = system.today();
    insert ev;
    
    Task tsk = new Task();
    tsk.Priority = 'High';
    tsk.OwnerId = Userinfo.getuserid();
    tsk.Subject = 'Email';
    tsk.ActivityDate = system.today();
    tsk.Status = 'In Progress';
    insert tsk;
    setUpTimeEntryData(wd.id, tech.id);
    SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
        SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
    List<SVMXC.INTF_WebservicesDef.SVMXMap> valueMapVar = new  List<SVMXC.INTF_WebservicesDef.SVMXMap>();
    
    SVMXC.INTF_WebservicesDef.SVMXMap tempValueVar = new SVMXC.INTF_WebservicesDef.SVMXMap();
    tempValueVar.key = 'SVMX_RECORDID';
    tempValueVar.value = String.valueOf(tsHeader.id);
    valueMapVar.add(tempValueVar);
    req.valueMap = valueMapVar;
        TMST_TimesheetEngineAPI tsAPIvar = new TMST_TimesheetEngineAPI();
    res = tsAPIvar.processTimesheetHeaderData(req);
        System.assert( res != null );
    }
  static testMethod void testTMST_TimesheetEngineAPI2() {
    
    SVMXC__Timesheet__c tsHeader = new SVMXC__Timesheet__c();
    tsHeader.SVMXC__Status__c = 'Open';
    tsHeader.SVMXC__User__c = Userinfo.getuserid();
    tsHeader.SVMXC__Start_Date__c = System.today().addDays(-4);
    tsHeader.SVMXC__End_Date__c = System.today().addDays(3);
    BusinessHours stdBusinessHours = [select id from BusinessHours where Name = 'Default'];
    tsHeader.SVMXC__SM_Business_Hours__c = stdBusinessHours.id;
    insert tsHeader;
    
    List<SVMXC__Timesheet_Day_Entry__c> lstTMSTDay = setTMSTDayEntry(tsHeader.id);
    
    
    setUpData('WO Business Hours');
    
    SVMXC__Service_Order__c wd = new SVMXC__Service_Order__c();
    wd.SVMXC__Order_Status__c = 'Open';
    wd.SVMXC__Preferred_Business_Hours__c = stdBusinessHours.id;
    insert wd;
    
    SVMXC__Service_Order_Line__c wdLine = new SVMXC__Service_Order_Line__c();
    wdLine.SVMXC__Is_Billable__c = true;
    wdLine.SVMXC__Line_Type__c = 'Labor';
    wdLine.SVMXC__Closed_By__c = Userinfo.getuserid();
    wdLine.SVMXC__Start_Date_and_Time__c = system.today() - 2;
    wdLine.SVMXC__End_Date_and_Time__c = system.today();
    wdLine.SVMXC__Service_Order__c = wd.id;
    insert wdLine;
    
    SVMXC__Service_Order_Line__c wdLine1 = new SVMXC__Service_Order_Line__c();
    wdLine1.SVMXC__Is_Billable__c = true;
    wdLine1.SVMXC__Line_Type__c = 'Labor';
    wdLine1.SVMXC__Closed_By__c = Userinfo.getuserid();
    wdLine1.SVMXC__Start_Date_and_Time__c = system.today() - 2;
    wdLine1.SVMXC__End_Date_and_Time__c = system.today();
    wdLine1.SVMXC__Service_Order__c = wd.id;
    insert wdLine1;
    
    SVMXC__Service_Group__c serviceGrp = new SVMXC__Service_Group__c();
    serviceGrp.Name = 'Bangalore Group';
    serviceGrp.SVMXC__Active__c = true;
    insert serviceGrp;
    
    SVMXC__Service_Group_Members__c tech = new SVMXC__Service_Group_Members__c();
    tech.SVMXC__Salesforce_User__c = Userinfo.getuserid();
    tech.Name = 'Test Tech';
    tech.SVMXC__Service_Group__c = serviceGrp.id;
    insert tech;
    
    SVMXC__SVMX_Event__c sEvent = new SVMXC__SVMX_Event__c();
    sEvent.SVMXC__StartDateTime__c = system.today() - 2;
    sEvent.SVMXC__EndDateTime__c = system.today();
    sEvent.Name = 'Test';
    sEvent.SVMXC__Service_Order__c = wd.id;
    sEvent.SVMXC__SM_Status__c = 'Confirmed';
    sEvent.SVMXC__Technician__c = tech.id;
    insert sEvent;
    
    SVMXC__SVMX_Event__c sEvent1 = new SVMXC__SVMX_Event__c();
    sEvent1.SVMXC__StartDateTime__c = system.today() - 2;
    sEvent1.SVMXC__EndDateTime__c = system.today();
    sEvent1.Name = 'Test';
    sEvent1.SVMXC__Service_Order__c = wd.id;
    sEvent1.SVMXC__SM_Status__c = 'Confirmed';
    sEvent1.SVMXC__Technician__c = tech.id;
    insert sEvent1;
    
    Event ev = new Event();
    ev.OwnerId = Userinfo.getuserid();
    ev.Type = 'Email';
    ev.Subject = 'Email';
    ev.StartDateTime = system.today() - 2;
    ev.EndDateTime = system.today();
    ev.ActivityDate = system.today();
    ev.WhatId = wd.id;
    insert ev;
    
    Event ev1 = new Event();
    ev1.OwnerId = Userinfo.getuserid();
    ev1.Type = 'Email';
    ev1.Subject = 'Email';
    ev1.StartDateTime = system.today() - 2;
    ev1.EndDateTime = system.today();
    ev1.ActivityDate = system.today();
    ev1.WhatId = wd.id;
    insert ev1;
    
    Task tsk = new Task();
    tsk.Priority = 'High';
    tsk.OwnerId = Userinfo.getuserid();
    tsk.Subject = 'Email';
    tsk.ActivityDate = system.today();
    tsk.Status = 'In Progress';
    tsk.WhatId = wd.id;
    insert tsk;
    
    Task tsk1 = new Task();
    tsk1.Priority = 'High';
    tsk1.OwnerId = Userinfo.getuserid();
    tsk1.Subject = 'Email';
    tsk1.ActivityDate = system.today();
    tsk1.Status = 'In Progress';
    tsk1.WhatId = wd.id;
    insert tsk1;
    
    
    List<SVMXC__Timesheet_Entry__c> listTimeentry = new List<SVMXC__Timesheet_Entry__c>();
    SVMXC__Timesheet_Entry__c tm1 = new SVMXC__Timesheet_Entry__c();
    tm1.SVMXC__Timesheet_Day__c = lstTMSTDay[0].id;
    tm1.SVMXC__Timesheet__c = tsHeader.id;
    tm1.SVMXC__Work_Detail__c = wdLine.id;
    listTimeentry.add(tm1);
    
    SVMXC__Timesheet_Entry__c tm2 = new SVMXC__Timesheet_Entry__c();
    tm2.SVMXC__Timesheet_Day__c = lstTMSTDay[0].id;
    tm2.SVMXC__Timesheet__c = tsHeader.id;
    tm2.SVMXC__ServiceMax_Event__c = sEvent.id;
    listTimeentry.add(tm2);
    
    SVMXC__Timesheet_Entry__c tm3 = new SVMXC__Timesheet_Entry__c();
    tm3.SVMXC__Timesheet_Day__c = lstTMSTDay[0].id;
    tm3.SVMXC__Timesheet__c = tsHeader.id;
    tm3.SVMXC__Salesforce_Event__c = String.valueOf(ev.id);
    listTimeentry.add(tm3);
    
    SVMXC__Timesheet_Entry__c tm4 = new SVMXC__Timesheet_Entry__c();
    tm4.SVMXC__Timesheet_Day__c = lstTMSTDay[0].id;
    tm4.SVMXC__Timesheet__c = tsHeader.id;
    tm4.SVMXC__Task__c = String.valueOf(tsk.id);
    listTimeentry.add(tm4);
    
    insert listTimeentry;
    
    SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
        SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
    List<SVMXC.INTF_WebservicesDef.SVMXMap> valueMapVar = new  List<SVMXC.INTF_WebservicesDef.SVMXMap>();
    
    SVMXC.INTF_WebservicesDef.SVMXMap tempValueVar = new SVMXC.INTF_WebservicesDef.SVMXMap();
    tempValueVar.key = 'SVMX_RECORDID';
    tempValueVar.value = String.valueOf(tsHeader.id);
    valueMapVar.add(tempValueVar);
    req.valueMap = valueMapVar;
        TMST_TimesheetEngineAPI tsAPIvar = new TMST_TimesheetEngineAPI();
    res = tsAPIvar.processTimesheetHeaderData(req);
        System.assert( res != null );
    }
  private static List<SVMXC__Timesheet_Day_Entry__c> setTMSTDayEntry(Id tsHeader){
    List<SVMXC__Timesheet_Day_Entry__c> lstDayEntry = new List<SVMXC__Timesheet_Day_Entry__c>();
    SVMXC__Timesheet_Day_Entry__c tsDayEntry = new SVMXC__Timesheet_Day_Entry__c();
    tsDayEntry.SVMXC__Timsheet_Day__c = System.Today().addDays(-2);
    tsDayEntry.SVMXC__Timesheet__c = tsHeader;
    tsDayEntry.SVMXC__Total_Hours__c = 10.10;
    tsDayEntry.SVMXC__SM_Working_Minutes__c = 1400;
    lstDayEntry.add(tsDayEntry);
    SVMXC__Timesheet_Day_Entry__c tsDayEntry1 = new SVMXC__Timesheet_Day_Entry__c();
    tsDayEntry1.SVMXC__Timsheet_Day__c = System.Today().addDays(-2);
    tsDayEntry1.SVMXC__Timesheet__c = tsHeader;
    tsDayEntry1.SVMXC__Total_Hours__c = 10.10;
    tsDayEntry1.SVMXC__SM_Working_Minutes__c = 1400;
    lstDayEntry.add(tsDayEntry1);
    SVMXC__Timesheet_Day_Entry__c tsDayEntry2 = new SVMXC__Timesheet_Day_Entry__c();
    tsDayEntry2.SVMXC__Timsheet_Day__c = System.Today().addDays(-2);
    tsDayEntry2.SVMXC__Timesheet__c = tsHeader;
    tsDayEntry2.SVMXC__Total_Hours__c = 10.10;
    tsDayEntry2.SVMXC__SM_Working_Minutes__c = 1400;
    lstDayEntry.add(tsDayEntry2);
    SVMXC__Timesheet_Day_Entry__c tsDayEntry3 = new SVMXC__Timesheet_Day_Entry__c();
    tsDayEntry3.SVMXC__Timsheet_Day__c = System.Today().addDays(-2);
    tsDayEntry3.SVMXC__Timesheet__c = tsHeader;
    tsDayEntry3.SVMXC__Total_Hours__c = 10.10;
    tsDayEntry3.SVMXC__SM_Working_Minutes__c = 1400;
    lstDayEntry.add(tsDayEntry3);
    
    insert lstDayEntry;
    return lstDayEntry;
  }
  private static void setUpTimeEntryData(Id wd, Id tech){
    
    SVMXC__Service_Order_Line__c wdLine1 = new SVMXC__Service_Order_Line__c();
    wdLine1.SVMXC__Is_Billable__c = true;
    wdLine1.SVMXC__Line_Type__c = 'Labor';
    wdLine1.SVMXC__Closed_By__c = Userinfo.getuserid();
    wdLine1.SVMXC__Start_Date_and_Time__c = system.today() - 5;
    wdLine1.SVMXC__End_Date_and_Time__c = system.today() - 4;
    wdLine1.SVMXC__Service_Order__c = wd;
    insert wdLine1;
    
    SVMXC__SVMX_Event__c sEvent1 = new SVMXC__SVMX_Event__c();
    sEvent1.SVMXC__StartDateTime__c = system.today() - 5;
    sEvent1.SVMXC__EndDateTime__c = system.today() - 4;
    sEvent1.Name = 'Test';
    sEvent1.SVMXC__Service_Order__c = wd;
    sEvent1.SVMXC__SM_Status__c = 'Confirmed';
    sEvent1.SVMXC__Technician__c = tech;
    insert sEvent1;
    
    Event ev1 = new Event();
    ev1.OwnerId = Userinfo.getuserid();
    ev1.Type = 'Email';
    ev1.Subject = 'Email';
    ev1.StartDateTime = system.today() - 5;
    ev1.EndDateTime = system.today() - 4;
    ev1.ActivityDate = system.today();
    ev1.WhatId = wd;
    insert ev1;
    
    Task tsk1 = new Task();
    tsk1.Priority = 'High';
    tsk1.OwnerId = Userinfo.getuserid();
    tsk1.Subject = 'Email';
    tsk1.ActivityDate = system.today();
    tsk1.Status = 'In Progress';
    tsk1.WhatId = wd;
    insert tsk1;
  }
  private static void setUpData(String tzPull){
    Id recordTypeIdConfProfile = Schema.SObjectType.SVMXC__ServiceMax_Config_Data__c.getRecordTypeInfosByName().get('Configuration Profile').getRecordTypeId();
    Id recordTypeIdConfAccess = Schema.SObjectType.SVMXC__ServiceMax_Config_Data__c.getRecordTypeInfosByName().get('Configuration Access').getRecordTypeId();
    Id recordTypeIdTimesheetAccess = Schema.SObjectType.SVMXC__ServiceMax_Config_Data__c.getRecordTypeInfosByName().get('Timesheet Access').getRecordTypeId();
    Id processrecordTypeTimesheet = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getRecordTypeInfosByName().get('Timesheet').getRecordTypeId();
    Id processrecordTypeTimesheetrule = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getRecordTypeInfosByName().get('SVMX Rule').getRecordTypeId();
    Id processrecordTypeTimesheetObjectMapping = Schema.SObjectType.SVMXC__ServiceMax_Processes__c.getRecordTypeInfosByName().get('Object Mapping').getRecordTypeId();
    Id recordTypeIdTimesheetWDFieldmapping = Schema.SObjectType.SVMXC__ServiceMax_Config_Data__c.getRecordTypeInfosByName().get('Field Mapping').getRecordTypeId();
    
    SVMXC__ServiceMax_Config_Data__c confProfile = new SVMXC__ServiceMax_Config_Data__c();
    confProfile.SVMXC__Configuration_Type__c = 'Group';
    confProfile.SVMXC__Profile_Name__c = 'Cloned Default for SP';
    confProfile.RecordTypeId = recordTypeIdConfProfile;
    insert confProfile;
    
    SVMXC__ServiceMax_Config_Data__c confAccess = new SVMXC__ServiceMax_Config_Data__c();
    confAccess.SVMXC__Profile__c = String.valueOf(Userinfo.getProfileId());
    confAccess.RecordTypeId = recordTypeIdConfAccess;
    confAccess.SVMXC__Access_Configuration_Profile__c = confProfile.id;
    insert confAccess;
    
    SVMXC__ServiceMax_Processes__c tsProcessrule = new SVMXC__ServiceMax_Processes__c();
    tsProcessrule.RecordTypeId = processrecordTypeTimesheetrule;
    tsProcessrule.SVMXC__Source_Object_Name__c ='SVMXC__Service_Order_Line__c';
    tsProcessrule.SVMXC__Advance_Expression__c = '1 AND 2';
    tsProcessrule.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Line_Type__c=\'Labor\' AND SVMXC__Is_Billable__c=true';
    insert tsProcessrule;
    
    SVMXC__ServiceMax_Processes__c tsProcessruleTask = new SVMXC__ServiceMax_Processes__c();
    tsProcessruleTask.RecordTypeId = processrecordTypeTimesheetrule;
    tsProcessruleTask.SVMXC__Source_Object_Name__c ='Task';
    tsProcessruleTask.SVMXC__Advance_Expression__c = '1';
    tsProcessruleTask.SVMXC__Parent_Object_Criteria__c = 'Priority=\'High\'';
    insert tsProcessruleTask;
    
    SVMXC__ServiceMax_Processes__c tsProcessruleEvent = new SVMXC__ServiceMax_Processes__c();
    tsProcessruleEvent.RecordTypeId = processrecordTypeTimesheetrule;
    tsProcessruleEvent.SVMXC__Source_Object_Name__c ='Event';
    tsProcessruleEvent.SVMXC__Advance_Expression__c = '1';
    tsProcessruleEvent.SVMXC__Parent_Object_Criteria__c = 'Type=\'Email\'';
    insert tsProcessruleEvent;
    
    SVMXC__ServiceMax_Processes__c tsProcessruleSVMXEvent = new SVMXC__ServiceMax_Processes__c();
    tsProcessruleSVMXEvent.RecordTypeId = processrecordTypeTimesheetrule;
    tsProcessruleSVMXEvent.SVMXC__Source_Object_Name__c ='SVMXC__SVMX_Event__c';
    tsProcessruleSVMXEvent.SVMXC__Advance_Expression__c = '1';
    tsProcessruleSVMXEvent.SVMXC__Parent_Object_Criteria__c = 'SVMXC__SM_Status__c=\'Confirmed\'';
    insert tsProcessruleSVMXEvent;
    
    SVMXC__ServiceMax_Processes__c objMapping1 = new SVMXC__ServiceMax_Processes__c();
    objMapping1.RecordTypeId = processrecordTypeTimesheetObjectMapping;
    objMapping1.SVMXC__Source_Object_Name__c ='SVMXC__Service_Order_Line__c';
    objMapping1.SVMXC__Target_Object_Name__c = 'SVMXC__Timesheet_Entry__c';
    objMapping1.SVMXC__Active__c = true;
    objMapping1.SVMXC__Name__c = 'MapIds';
    objMapping1.SVMXC__MapID__c = 'Test_MapIds';
    insert objMapping1;
    
    SVMXC__ServiceMax_Config_Data__c objMapping1WD = new SVMXC__ServiceMax_Config_Data__c();
    objMapping1WD.SVMXC__Target_Field_Name__c = 'SVMXC__Work_Detail__c';
    objMapping1WD.RecordTypeId = recordTypeIdTimesheetWDFieldmapping;
    objMapping1WD.SVMXC__MapID__c = objMapping1.id;
    objMapping1WD.SVMXC__Source_Field_Name__c = 'Id';
    objMapping1WD.SVMXC__Parameter_Type__c = 'Field Value';
    objMapping1WD.SVMXC__Action_Type__c = 'Set Value';
    insert objMapping1WD;
    
    SVMXC__ServiceMax_Config_Data__c objMapping1WD1 = new SVMXC__ServiceMax_Config_Data__c();
    objMapping1WD1.SVMXC__Target_Field_Name__c = 'SVMXC__End_Time__c';
    objMapping1WD1.RecordTypeId = recordTypeIdTimesheetWDFieldmapping;
    objMapping1WD1.SVMXC__MapID__c = objMapping1.id;
    objMapping1WD1.SVMXC__Source_Field_Name__c = 'SVMXC__End_Date_and_Time__c';
    objMapping1WD1.SVMXC__Parameter_Type__c = 'Field Value';
    objMapping1WD1.SVMXC__Action_Type__c = 'Set Value';
    insert objMapping1WD1;
    
    SVMXC__ServiceMax_Config_Data__c objMapping1WD2 = new SVMXC__ServiceMax_Config_Data__c();
    objMapping1WD2.SVMXC__Target_Field_Name__c = 'SVMXC__Start_Time__c';
    objMapping1WD2.RecordTypeId = recordTypeIdTimesheetWDFieldmapping;
    objMapping1WD2.SVMXC__MapID__c = objMapping1.id;
    objMapping1WD2.SVMXC__Source_Field_Name__c = 'SVMXC__Start_Date_and_Time__c';
    objMapping1WD2.SVMXC__Parameter_Type__c = 'Field Value';
    objMapping1WD2.SVMXC__Action_Type__c = 'Set Value';
    insert objMapping1WD2;
    
    SVMXC__ServiceMax_Processes__c tsProcess = new SVMXC__ServiceMax_Processes__c();
    tsProcess.RecordTypeId = processrecordTypeTimesheet;
    tsProcess.SVMXC__Name__c ='TSTest';
    tsProcess.SVMXC__Field_Name__c = 'SVMXC__Closed_By__c';
    tsProcess.SVMXC__Process__c = tsProcessrule.id;
    tsProcess.SVMXC__Node_Parent__c = tsProcessruleTask.id;
    tsProcess.SVMXC__Submodule__c = tsProcessruleSVMXEvent.id;
    tsProcess.SVMXC__Parent_Object__c = tsProcessruleEvent.id;
    tsProcess.SVMXC__Event_Type__c = 'BOTH';
    tsProcess.SVMXC__Process1__c = objMapping1.id;
    tsProcess.SVMXC__SM_Business_Hour_Source__c = tzPull;
    tsProcess.SVMXC__Active__c = true;
    insert tsProcess;
    
    SVMXC__ServiceMax_Config_Data__c confTSAccess = new SVMXC__ServiceMax_Config_Data__c();
    confTSAccess.RecordTypeId = recordTypeIdTimesheetAccess;
    confTSAccess.SVMXC__Dispatch_Process__c = tsProcess.id;
    confTSAccess.SVMXC__Access_Configuration_Profile__c = confProfile.id;
    confTSAccess.SVMXC__SM_Scope__c = '{"salesforceProfileIds":[{"name":"System Administrator","Id":"'+String.valueOf(Userinfo.getProfileId())+'"},{"name":"System Admin SP","Id":"00e2I000001MjqRQAS"}]}';
    insert confTSAccess;
  }
  
  
}