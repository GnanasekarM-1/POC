@isTest
public class DCX_ServiceIntf_UT{
  public Static RestRequest req;
  public Static RestResponse res;
  @testSetup static void setup() {
    SVMXC__ServiceMax_Config_Data__c globalProfile = new SVMXC__ServiceMax_Config_Data__c();
    List<SVMXC__ServiceMax_Config_Data__c> configDataList = 
        new List<SVMXC__ServiceMax_Config_Data__c>();
    List<SVMXC__ServiceMax_Processes__c> settingValues = new List<SVMXC__ServiceMax_Processes__c>();

    globalProfile.recordTypeId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Profile');
    globalProfile.SVMXC__Configuration_Type__c = 'Global'; 
    globalProfile.SVMXC__Active__c = true;
    insert globalProfile;

    SVMXC__ServiceMax_Processes__c dcon001Process = new SVMXC__ServiceMax_Processes__c();
    dcon001Process.SVMXC__SubmoduleID__c = 'COMM4';
    dcon001Process.SVMXC__MapID__c = 'dcon001Process';
    insert dcon001Process;

    SVMXC__ServiceMax_Processes__c set001Process = new SVMXC__ServiceMax_Processes__c();
    set001Process.SVMXC__SettingID__c = 'SET001';
    set001Process.SVMXC__MapID__c = 'set001Process';
    set001Process.SVMXC__Submodule__c = dcon001Process.Id;
    settingValues.add(set001Process);

    insert settingValues;
    String settingValueRecordTypeId = 
            COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Setting_Value');

    SVMXC__ServiceMax_Config_Data__c set001Setting =  new SVMXC__ServiceMax_Config_Data__c();
    set001Setting.SVMXC__Internal_Value__c = 'Allow';
    set001Setting.SVMXC__Display_Value__c = 'Allow';
    set001Setting.recordtypeid = settingValueRecordTypeId;
    set001Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
    set001Setting.SVMXC__Setting_ID__c = set001Process.Id;
    configDataList.add(set001Setting);

    insert configDataList;

  }
  Static testMethod void test_metaData(){ 

        restUtils('metaData', 'GET', '');
        test.startTest();
        DCX_ServiceIntf intf = new DCX_ServiceIntf();

        DCX_ServiceIntf.doGet();
        test.stopTest();
       // DispatchConsoleRestBase restBase =new DispatchConsoleRestBase();
        DCX_ServiceBase serviceBase =new DCX_ServiceBase();
        serviceBase.saveUserSettings();
        serviceBase.fetchSchedulerData();
        serviceBase.fetchEventsOnLaunch();
        serviceBase.fetchEvents();
        serviceBase.fetchMetaData();
        serviceBase.MCTMDetail();
        serviceBase.techInfo();
        serviceBase.keywordSearch();
        serviceBase.retrievePageOfWorkOrders();
        serviceBase.getViewWOCount();
        serviceBase.getViewDefinition();
        serviceBase.getViewData();

         serviceBase.updateWOTech();
         serviceBase.assignWOTeam();
         serviceBase.assignWOTech();
         serviceBase.unassignWO();
         serviceBase.unassignJDMWO();
         serviceBase.assignWOTOMutliTech();
         serviceBase.unassignWOTOMutliTech();
         serviceBase.resetWO();
         serviceBase.getWOforMutliAssign();
         serviceBase.getEventHover();
         serviceBase.getDependencyDetails();
         serviceBase.getDependencyCheck();
         serviceBase.retriveWO();
         serviceBase.fetchEventWOInfo();
         serviceBase.fetchWOEvents();
         serviceBase.fetchUpdatedEvents();
         serviceBase.fetchDeletedEvents();
         serviceBase.createEvents();
         serviceBase.upsertEvents();
         serviceBase.deleteEvents();
         serviceBase.eventExistInBusinessHour();
         serviceBase.eventSubjectDefinition();
         serviceBase.fetchAllEvents();
         serviceBase.fetchEventWarnings();
         serviceBase.fetchOvernightEvents();
         serviceBase.getTechWorkingHours();
         serviceBase.getQualifiedTechList();
         serviceBase.getListOfTechScheduled();
         serviceBase.deployUserSetting();
         serviceBase.restoreUserSetting();
         serviceBase.getWObyIds();
       serviceBase.retrieveWorkOrdersforIds();
       serviceBase.retrieveEventsAndWOInfoForIds();
       serviceBase.retrieveEventForIds();

       serviceBase.fetchEvents1();
       serviceBase.getEventHoverRules();
       serviceBase.createLJSEvent();
        serviceBase.listDispatcher();
        serviceBase.fetchDCXSetting() ;
        serviceBase.deleteAESEvent() ;
        serviceBase.singleWODetails();
       serviceBase.schedulerDataNew() ;
       serviceBase.fetchTechnicianDetails();
       serviceBase.fetchEventsAndWOInfo();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void callWrapper(){
        List<String> lt = new List<String>();
        DateTime dt = Datetime.valueOf('2017-09-30 11:45:00');
        Date dat = Date.valueOf('2017-09-30');
        List<Event> sfEvents = new List<Event>();
        List<Event> svmxEvents = new List<Event>();
        
        Dcon_DeployUserSetting.DCUserSettings dcSetting = new Dcon_DeployUserSetting.DCUserSettings();
       
        DCX_Wrapper.SVMX_StringMap mapstr1 = new  DCX_Wrapper.SVMX_StringMap('','');
        DCX_Wrapper.SVMX_StringMap mapstr = new  DCX_Wrapper.SVMX_StringMap('','');
        mapstr.woViewType = '';
        mapstr.columnInfo = '';
        mapstr.Key= '';
        mapstr.Value = '';
        mapstr.ValueList = lt;
        mapstr.DateTimeValue= dt;
        mapstr.DateValue = dat;
        mapstr.fieldsToNull = '';
        mapstr.dcSetting = dcSetting;

        List<DCX_Wrapper.SVMX_StringMap> ltMap = new List<DCX_Wrapper.SVMX_StringMap>();
        DCX_Wrapper.UnAssignTechToWO_Request reUnassign = new DCX_Wrapper.UnAssignTechToWO_Request();
        reUnassign.UserId = '';
        reUnassign.WorkOrderIds =lt;
        reUnassign.TechnicianId = '';    
        reUnassign.timeZone ='';    
        reUnassign.EventList = sfEvents;
        reUnassign.setOwner= false;
        reUnassign.lstKeyValue = ltMap;
        reUnassign.isUpdate = false;

        DCX_Wrapper.UnAssignTechToWO_Request reUnassign1 = new DCX_Wrapper.UnAssignTechToWO_Request('',lt,'','',sfEvents,false,ltMap,false);

        DCX_Wrapper.skill skill = new DCX_Wrapper.skill();
        skill.skillId = 'dt';
        skill.skillName = '';
        skill.isSkillMandatory = false;
        skill.skillLevel = 10;
        DCX_Wrapper.skill skill1 = new DCX_Wrapper.skill('','',false,10);

        DCX_Wrapper.DCEventWarningResp_WP DCEventWarningResp = new DCX_Wrapper.DCEventWarningResp_WP();
        DCEventWarningResp.STOutsideBusinessHrs = dt;
        DCEventWarningResp.ETOutsideBusinessHrs = dt;
        DCEventWarningResp.STOutsideMachineAccesshrs = dt;
        DCEventWarningResp.ETOutsideMachineAccesshrs = dt;
        DCX_Wrapper.DCEventWarningResp_WP DCEventWarningResp1 = new DCX_Wrapper.DCEventWarningResp_WP(dt,dt,dt,dt);

        DCX_Wrapper.DCTech_WO_WP DCTech_WO = new DCX_Wrapper.DCTech_WO_WP('dt','dt','dt',false,dt,'','',false);
        DCX_Wrapper.DCTech_WO_WP DCTech_WO1 = new DCX_Wrapper.DCTech_WO_WP('dt','dt','dt',false,'dt');
        DCX_Wrapper.DCTech_WO_Response_WP DCTech_WO2 = new DCX_Wrapper.DCTech_WO_Response_WP('dt');


    }
    Static testMethod void test_saveUserSettings(){
        string json = '{autorefresh:"false"}';
        //String serializedRequest = JSON.serialize(json);

        restUtils('saveUserSettings', 'POST', json);

        test.startTest();
        DCX_ServiceIntf.doPost();
        test.stopTest();


        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

     Static testMethod void fetchTechnicianDetails(){
DCX_Wrapper.technicianIds obj = new DCX_Wrapper.technicianIds();
List<String> woids = new List<String>();
woids.add('123');
        obj.techIds=woids;
        obj.techFields = woids;
        DCX_Wrapper.technicianIds obj1 = new DCX_Wrapper.technicianIds(woids,woids);
        String str = JSON.serialize(obj1);
        restUtils('fetchTechnicianDetails', 'POST ', '');

        test.startTest();
        DCX_ServiceIntf.doPost();
        test.stopTest();


        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
     Static testMethod void test_schedulerData(){
        restUtils('schedulerData', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

     /*Static testMethod void test_schedulerData1(){
         List<String> strList = new List<String>();
         strList.add('123');

         DCX_Wrapper.technicianIds obj = new DCX_Wrapper.technicianIds();
        obj.techIds=strList;
        obj.techFields = strList;
        DCX_Wrapper.technicianIds obj1 = new DCX_Wrapper.technicianIds(strList,strList);
        String str = JSON.serialize(obj1);
        restUtils('fetchTechnicianDetails', 'POST ', str);

        restUtils('fetchTechnicianDetails', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }*/
     Static testMethod void test_eventData(){

        List <string> stringMap;
        DCX_Wrapper.EventDataRequest obj = new DCX_Wrapper.EventDataRequest();
        obj.startDate='';
        obj.endDate = '';
        obj.tzDtFormat ='';
        obj.techIds = stringMap;
        DCX_Wrapper.EventDataRequest obj1 = new DCX_Wrapper.EventDataRequest('','','',stringMap,null);

        restUtils('eventData', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
     Static testMethod void test_eventDataOnLaunch(){
        restUtils('eventDataOnLaunch', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
      Static testMethod void schedulerDataNew(){
        restUtils('schedulerDataNew', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }


    Static testMethod void test_MCTMDetail(){
        restUtils('MCTMDetail', 'POST', '');
        test.startTest();
        DCX_ServiceIntf.doPost();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void getViewDefinition(){

        DCX_Wrapper.INTF_getViewDefinition_WS_Object obj = new DCX_Wrapper.INTF_getViewDefinition_WS_Object();
        obj.userId ='';
        obj.groupId='';
        obj.profileId ='';
        obj.stringMap =null;

        DCX_Wrapper.INTF_getViewDefinition_WS_Object obj1 = new DCX_Wrapper.INTF_getViewDefinition_WS_Object('','','',null);
String serializedRequest = JSON.serialize(obj1);
        restUtils('getViewDefinition', 'POST', serializedRequest);
        test.startTest();
        DCX_ServiceIntf.doPost();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void fetchEvents(){

        DCX_Wrapper.EventDataRequest obj = new DCX_Wrapper.EventDataRequest();
        obj.startDate ='';
        obj.endDate='';
        obj.tzDtFormat ='';
        obj.techIds =null;

        DCX_Wrapper.EventDataRequest obj1 = new DCX_Wrapper.EventDataRequest('','','',null,null);

        restUtils('fetchEvents', 'POST', '');
        test.startTest();
        DCX_ServiceIntf.doPost();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void fetchEventsAndWOInfo(){

        DCX_Wrapper.EventDataRequest obj = new DCX_Wrapper.EventDataRequest();
        obj.startDate ='';
        obj.endDate='';
        obj.tzDtFormat ='';
        obj.techIds =null;

        DCX_Wrapper.EventDataRequest obj1 = new DCX_Wrapper.EventDataRequest('','','',null,null);

        restUtils('eventDataAndWOInfo', 'POST', '');
        test.startTest();
        DCX_ServiceIntf.doPost();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void retrieveWorkOrdersforIds(){

        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (Name = 'TEAM 1');
        insert objTeam;

        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (Name = 'TERRITORY 1');
        insert objTerritory;

        SVMXC__Service_Group_Members__c objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH 1' ,
                                            SVMXC__Latitude__c = 40.739582 ,
                                            SVMXC__Longitude__c = -73.980772,
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Salesforce_User__c = UserInfo.getUserId()
                                            );
        insert objTechnician;

        Account objAccount = new Account(Name ='Account'  );
        insert objAccount;


        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;


        Case objCase = new Case(Status ='New', Priority = 'Medium',
                                        Origin = 'Email',
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id
                                        );
        Datetime t = system.now();
        SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Contact__c =objContact.Id,
                                            SVMXC__Latitude__c = 40.739582 ,
                                            SVMXC__Longitude__c = -73.980772,
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Group_Member__c = objTechnician.Id,
                                            SVMXC__Preferred_Start_Time__c = t.addHours(4)
                                            );
        insert objWorkOrder;

        List<String> workorderIds = new List<String>();
        workorderIds.add(objWorkOrder.Id);

        DCX_Wrapper.workOrdersForIds obj = new DCX_Wrapper.workOrdersForIds();
        obj.workorderIds = workorderIds;

        restUtils('retrieveWOForIds', 'POST', '');
        test.startTest();
        DCX_ServiceIntf.doPost();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }



     Static testMethod void test_techInfo(){

        List <string> stringMap;
        DCX_Wrapper.DCON_Retrieve_TechnicianInfo_Tree_WS_Object obj = new DCX_Wrapper.DCON_Retrieve_TechnicianInfo_Tree_WS_Object();
        obj.keyValPairs='';
        obj.techIds = stringMap;
        DCX_Wrapper.DCON_Retrieve_TechnicianInfo_Tree_WS_Object obj1 = new DCX_Wrapper.DCON_Retrieve_TechnicianInfo_Tree_WS_Object('',stringMap);

        restUtils('techInfo', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void test_keywordSearch(){
                DCX_Wrapper.DCON_Keyword_Search_WS_Object obj = new DCX_Wrapper.DCON_Keyword_Search_WS_Object();
        obj.keyword='';
        obj.findWhat = '';
        obj.keywordMatch ='';
        obj.searchType = '';
        DCX_Wrapper.DCON_Keyword_Search_WS_Object obj1 = new DCX_Wrapper.DCON_Keyword_Search_WS_Object('','','','');

        restUtils('keywordSearch', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }



    Static testMethod void test_pageOfWorkOrders(){
        restUtils('pageOfWorkOrders', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void test_getViewWOCount(){
       /* List <string> stringMap;
        DCX_Wrapper.DCON_ViewWoCount_WS_Object obj = new DCX_Wrapper.DCON_ViewWoCount_WS_Object();
        obj.viewIds = stringMap;
        DCX_Wrapper.DCON_ViewWoCount_WS_Object obj1 = new DCX_Wrapper.DCON_ViewWoCount_WS_Object(stringMap);
        string json = '{viewIds:["123"]}';
        restUtils('getViewWOCount', 'POST',json);
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();*/

         List <string> stringMap = new list<string>();
         stringMap.add('a120G00000AJ9DWQA1');
        DCX_Wrapper.DCON_ViewWoCount_WS_Object obj = new DCX_Wrapper.DCON_ViewWoCount_WS_Object();
        obj.viewIds = stringMap;
         String serializedRequest = JSON.serialize(obj);
         system.debug('serializedRequest ::' + serializedRequest);
          string json = '{viewIds:["a120G00000AJ9DWQA1"]}';
        DCX_Wrapper.DCON_ViewWoCount_WS_Object obj1 = new DCX_Wrapper.DCON_ViewWoCount_WS_Object(stringMap);
        restUtils('getViewWOCount', 'POST',serializedRequest);
        test.startTest();
        DCX_ServiceIntf.doPost();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
   /* Static testMethod void test_getViewDefinition(){
        List <INTF_WebServicesDef.INTF_StringMap> stringMap;
        DCX_Wrapper.INTF_getViewDefinition_WS_Object obj = new DCX_Wrapper.INTF_getViewDefinition_WS_Object();
        obj.userId='';
        obj.groupId = '';
        obj.profileId ='';
        obj.stringMap = stringMap;
        DCX_Wrapper.INTF_getViewDefinition_WS_Object obj1 = new DCX_Wrapper.INTF_getViewDefinition_WS_Object('','','',stringMap);
        restUtils('getViewDefinition', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }*/
    Static testMethod void test_getViewData(){
        restUtils('getViewData', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

     Static testMethod void test_UpdateWOTech(){
        DCX_Wrapper.UpdateWOTech_Object obj = new DCX_Wrapper.UpdateWOTech_Object();
        list<string> woids = new list<string>();
        woids.add('123456');
        list<Event> events = new list<Event>();
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue;
        obj.WorkOrderIds=woids;
        obj.TechnicianId = '12345';
        obj.timeZone ='1235';
        obj.EventList = events;
        obj.setOwner = false;
        obj.lstKeyValue = lstKeyValue;
        obj.isUpdate = false;
        String serializedRequest = JSON.serialize(obj);

       DCX_Wrapper.UpdateWOTech_Object obj1 = new DCX_Wrapper.UpdateWOTech_Object(woids,'','',events,false,lstKeyValue,false);

        restUtils('updateWOTech', 'POST', serializedRequest);
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }



    Static testMethod void test_assignWOTeam(){
        DCX_Wrapper.AssignWOTeam_Object obj = new DCX_Wrapper.AssignWOTeam_Object();
        list<string> woids;
        obj.WorkOrderIds=woids;
        obj.TeamId = '';
        obj.SetOwner =false;
        obj.dispatchStatus ='';
        obj.unassignWorkorder =false;

        DCX_Wrapper.AssignWOTeam_Object obj1 = new DCX_Wrapper.AssignWOTeam_Object(woids,'',false,'',false);

        restUtils('assignWOTeam', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void assignWOTech(){
        DCX_Wrapper.AssignWOTeam_Object obj = new DCX_Wrapper.AssignWOTeam_Object();
        list<string> woids;
        obj.WorkOrderIds=woids;
        obj.TeamId = '';
        obj.SetOwner =false;
        obj.dispatchStatus ='';
        obj.unassignWorkorder =false;

        DCX_Wrapper.AssignWOTeam_Object obj1 = new DCX_Wrapper.AssignWOTeam_Object(woids,'',false,'',false);

        restUtils('assignWOTech', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void test_unassignJDMWO(){
        DCX_Wrapper.UnassignJDMWO_Object obj = new DCX_Wrapper.UnassignJDMWO_Object();
         Datetime lastFiveMin = System.now();
        obj.WorkOrderId= '';
        obj.TechId = '';
        obj.OwnerId = '';
        obj.EventStartDateTime = '';
        obj.EventStartDtTm = lastFiveMin;
        obj.isEarlierEvents  = false;
        obj.timeZone ='';
        obj.eventId = '';//will get this event Id only when we are trying to select and delete an event from past.
        obj.isDeleteAllEvents = false;
        obj.deleteSingleEventId =''; //When user selects single event for delete, this variable will be fed.
        obj.isUnassignTech= false;


        DCX_Wrapper.UnassignJDMWO_Object obj1 = new DCX_Wrapper.UnassignJDMWO_Object('','','',false,lastFiveMin,'','',false,'',false);

        String serializedRequest = JSON.serialize(obj1);

        restUtils('unassignJDMWO', 'POST', serializedRequest);
       // restUtils('unassignJDMWO', 'POST', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

Static testMethod void getDependencyDetails(){
        DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object obj = new DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object();
       List<Event> lstSFEvent = new   List<Event>();
       List<SVMXC__SVMX_Event__c> lstSVMXEvent = New List<SVMXC__SVMX_Event__c>();
       List<String> woids = new List<String>();
       obj.lstSFEvent = lstSFEvent;
       obj.lstSVMXEvent = lstSVMXEvent;
       obj.timeZone = '';
       obj.listWOIds = woids;

        DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object obj1 = new DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object(null,null,'',null);

        String serializedRequest = JSON.serialize(obj1);

        restUtils('getDependencyDetails', 'POST', serializedRequest);
       // restUtils('unassignJDMWO', 'POST', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void test_unassignWO(){
        DCX_Wrapper.UnassignWO_Object obj = new DCX_Wrapper.UnassignWO_Object();
        list<string> woids;
        obj.WorkOrderIds=woids;

        DCX_Wrapper.UnassignWO_Object obj1 = new DCX_Wrapper.UnassignWO_Object(woids);

        restUtils('unassignWO', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void test_assignWOTOMutliTech(){
        DCX_Wrapper.AssignWOTOMutliTech_Object obj = new DCX_Wrapper.AssignWOTOMutliTech_Object();
        string woid;
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue;
        List<Event> EventList;

        obj.WorkOrderId = woid;
        obj.TechnicianId= '';
        obj.timeZone='';
        obj.EventList =EventList;
        obj.updatePrimaryTech = false;
        obj.lstKeyValue = lstKeyValue;
        obj.deleteEventForOtherTechs = false;

        DCX_Wrapper.AssignWOTOMutliTech_Object obj1 = new DCX_Wrapper.AssignWOTOMutliTech_Object(woid, '', '',  EventList, false, lstKeyValue,false,null,true,null);

        restUtils('assignWOTOMutliTech', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }


    Static testMethod void test_unassignWOTOMutliTech(){
        DCX_Wrapper.UnassignWOTOMutliTech_Object obj = new DCX_Wrapper.UnassignWOTOMutliTech_Object();
        list<string> woids;
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue;
        List<Event> EventList;

        obj.WorkOrderIds = woids;
        obj.TechnicianId= '';
        obj.timeZone='';
        obj.EventList =EventList;
        obj.setOwner = false;
        obj.lstKeyValue = lstKeyValue;

        DCX_Wrapper.UnassignWOTOMutliTech_Object obj1 = new DCX_Wrapper.UnassignWOTOMutliTech_Object(woids, '', '',  EventList, false, lstKeyValue);

        restUtils('unassignWOTOMutliTech', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void ResetWO_Object(){
        DCX_Wrapper.ResetWO_Object obj = new DCX_Wrapper.ResetWO_Object();
        list<string> woids;
        obj.WorkOrderIds =woids;

        DCX_Wrapper.ResetWO_Object obj1 = new DCX_Wrapper.ResetWO_Object(woids);

        restUtils('resetWO', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

     Static testMethod void eventWODataRequest(){
        DCX_Wrapper.eventWODataRequest obj = new DCX_Wrapper.eventWODataRequest();
        List<String> eventIds;
        List<String> keyValPairs;
        List<String> dispatchStatus;
        List<String> workOrderIds;

        obj.eventIds = eventIds;
        obj.keyValPairs = keyValPairs;
        obj.viewId ='';
        obj.dispatchStatus = dispatchStatus;
        obj.timeZoneDateTimeFormat = '';
        obj.workOrderIds = workOrderIds;


        restUtils('fetchEventWorkOrderInfo', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void woEventsRequest(){
        DCX_Wrapper.woEventsRequest obj = new DCX_Wrapper.woEventsRequest();
        obj.startDate ='';
        obj.endDate ='';
        obj.timeZone ='';
        obj.woId ='';

        restUtils('fetchWorkOrderEvents', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

     Static testMethod void updateDeleteEventsRequest(){
        DCX_Wrapper.updateDeleteEventsRequest obj = new DCX_Wrapper.updateDeleteEventsRequest();
        List<String> technicianIds;
        obj.startDate ='';
        obj.endDate ='';
        obj.eventType ='';
        obj.timeZoneDateTimeFormat ='';
        obj.lastRetrievedDate ='';
        obj.technicianIds =technicianIds;

        restUtils('fetchDeletedEvents', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

     Static testMethod void upsertEventsRequest(){
        DCX_Wrapper.upsertEventsRequest obj = new DCX_Wrapper.upsertEventsRequest();
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue;
        List<Event> events;

       obj.events = events;
       obj.timeZone ='';
       obj.lstKeyValue =lstKeyValue;

        restUtils('upsertEvents', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void createEvents(){
        DCX_Wrapper.upsertEventsRequest obj = new DCX_Wrapper.upsertEventsRequest();
        list<DCX_Wrapper.SVMX_StringMap> lstKeyValue;
        List<Event> events;

       obj.events = events;
       obj.timeZone ='';
       obj.lstKeyValue =lstKeyValue;

        restUtils('createEvents', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }



     Static testMethod void fetchUpdatedEvents(){
        DCX_Wrapper.updateDeleteEventsRequest obj = new DCX_Wrapper.updateDeleteEventsRequest();
        List<String> technicianIds;
        obj.startDate ='';
        obj.endDate ='';
        obj.eventType ='';
        obj.timeZoneDateTimeFormat ='';
        obj.lastRetrievedDate ='';
        obj.technicianIds =technicianIds;

        restUtils('fetchUpdatedEvents', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }


    Static testMethod void deleteEventsRequest(){
        DCX_Wrapper.deleteEventsRequest obj = new DCX_Wrapper.deleteEventsRequest();
        List<String> eventIds;
        obj.eventIds =eventIds;

        restUtils('deleteEvents', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void fetchEventWarnings(){


        restUtils('fetchEventWarnings', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }



    Static testMethod void allEventsRequest(){
        DCX_Wrapper.allEventsRequest obj = new DCX_Wrapper.allEventsRequest();
        List<String> woIds;
        List<String> technicianIds;
        obj.woIds =woIds;
        obj.technicianIds =technicianIds;
        obj.timeZoneDateTimeFormat ='';

        restUtils('fetchAllEvents', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void DCON_Retrieve_Tech_WorkingHrs_WS_Object(){
        DCX_Wrapper.DCON_Retrieve_Tech_WorkingHrs_WS_Object obj = new DCX_Wrapper.DCON_Retrieve_Tech_WorkingHrs_WS_Object();
        List<String> lsttechId;
         obj.lsttechId =lsttechId;
        obj.startdate ='';
        obj.enddate='';
        DCX_Wrapper.DCON_Retrieve_Tech_WorkingHrs_WS_Object obj1 = new DCX_Wrapper.DCON_Retrieve_Tech_WorkingHrs_WS_Object(lsttechId, '', '');

        restUtils('getTechWorkingHours', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void scheduledTechniciansRequest(){
        DCX_Wrapper.scheduledTechniciansRequest obj = new DCX_Wrapper.scheduledTechniciansRequest();
        List<String> workOrderIds;
        obj.workOrderIds =workOrderIds;
        DCX_Wrapper.scheduledTechniciansRequest obj1 = new DCX_Wrapper.scheduledTechniciansRequest(workOrderIds);

        restUtils('getListOfTechScheduled', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void getWOforMutliAssign_Object(){
        DCX_Wrapper.getWOforMutliAssign_Object obj = new DCX_Wrapper.getWOforMutliAssign_Object();
        List<String> workOrderIds = new List<string>();
        List<String> technicianIds = new List<string>();
        List<Event> Eventlist = new List<Event>();
        List< String > EventIds = new List<string>();
        List<DCX_Wrapper.SVMX_StringMap> lstKeyValue;// =  List<DCX_Wrapper.SVMX_StringMap>();
        List<String> getworkOrderIds= new List<string>();
        List<Event> getEventlist= new List<Event>();
        List<Event> setEventlist= new List<Event>();

        technicianIds.add('1235');
        workOrderIds.add('1235');

        obj.workOrderIds = workOrderIds;
        obj.technicianIds = technicianIds;
        obj.operationType='';
        obj.timezone='';
        obj.Eventlist = Eventlist;
        obj.EventIds =EventIds;
        obj.lstKeyValue = lstKeyValue;
        obj.getworkOrderIds = getworkOrderIds;
        obj.getEventlist = getEventlist;
        obj.setEventlist = setEventlist;

        DCX_Wrapper.getWOforMutliAssign_Object obj1 = new DCX_Wrapper.getWOforMutliAssign_Object(workOrderIds,technicianIds,'','',Eventlist,EventIds,lstKeyValue,getworkOrderIds,getEventlist,setEventlist,null,null);

         String serializedRequest = JSON.serialize(obj);

        restUtils('getWOforMutliAssign', 'POST', serializedRequest);
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
     Static testMethod void getEventHover_Object(){
        DCX_Wrapper.getEventHover_Object obj = new DCX_Wrapper.getEventHover_Object();
         obj.WorkOrderId ='';

        DCX_Wrapper.getEventHover_Object obj1 = new DCX_Wrapper.getEventHover_Object('');

        restUtils('getEventHover', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void getEventHover_Object1(){

         Account account = new Account(Name ='Account');
            insert account;


            Contact contact = new Contact(LastName='Last',AccountId =account.Id);
            insert contact;
            Case case1 = new Case(Status ='New', Priority = 'Medium',
                                            Origin = 'Email',
                                            ContactId =contact.Id,
                                            AccountId=account.Id
                                            );
        SVMXC__Service_Order__c svo = new SVMXC__Service_Order__c (
                                                SVMXC__Case__c = case1.Id ,
                                                SVMXC__Company__c = account.Id ,
                                                SVMXC__Contact__c =contact.Id,
                                                SVMXC__Latitude__c = 40.739582 ,
                                                SVMXC__Longitude__c = -73.980772,
                                                SVMXC__Order_Status__c = 'Open',
                                                SVMXC__Priority__c ='Medium',
                                                SVMXC__Order_Type__c='Field Service',
                                                SVMXC__Locked_By_DC__c = true,
                                                SVMXC__SM_Estimated_Duration__c = 100,
                                                SVMXC__SM_Scope_Change__c = 0,
                                                SVMXC__SM_Variance__c = 0,
                                                SVMXC__SM_Scheduled_Duration__c = 20,
                                                SVMXC__SM_LJS_Minimum_Schedule_Duration__c = 4
                                                );
        upsert svo;
        List<String> WorkOrderIds = new List<String>();
        WorkOrderIds.add(svo.Id);

        DCX_Wrapper.getEventHover_Object obj = new DCX_Wrapper.getEventHover_Object();
         obj.WorkOrderId =svo.Id;

        DCX_Wrapper.getEventHover_Object obj1 = new DCX_Wrapper.getEventHover_Object(svo.Id);

         String serializedRequest = JSON.serialize(obj1);

        restUtils('getEventHover', 'POST', serializedRequest);
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();
    }
    /*  Static testMethod void DCON_WO_Get_Dependency_Details_WS_Object(){
        DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object obj = new DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object();
        List<Event> lstSFEvent = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstSVMXEvent = new List<SVMXC__SVMX_Event__c>();
        List<String> listWOIds = new List<String>();
         obj.lstSFEvent= lstSFEvent;
        obj.lstSVMXEvent = lstSVMXEvent;
        obj.timeZone ='';
        obj.listWOIds =listWOIds;

        DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object obj1 = new DCX_Wrapper.DCON_WO_Get_Dependency_Details_WS_Object(lstSFEvent,lstSVMXEvent,'',listWOIds);

        restUtils('getDependencyDetails', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }*/

    Static testMethod void getDependencyCheck(){
        DCX_Wrapper.getDependencyCheck_Object obj = new DCX_Wrapper.getDependencyCheck_Object();
        List<Event> lstSFEvent = new List<Event>();
        List<SVMXC__SVMX_Event__c> lstSVMXEvent = new List<SVMXC__SVMX_Event__c>();
        List<String> listWOIds =  new List<String>();
         obj.lstSFEvent= lstSFEvent;
        obj.lstSVMXEvent = lstSVMXEvent;
        obj.timeZone ='';
        obj.userId ='';
        obj.listWOIds =listWOIds;

        DCX_Wrapper.getDependencyCheck_Object obj1 = new DCX_Wrapper.getDependencyCheck_Object(lstSFEvent,lstSVMXEvent,'','',listWOIds);
        String serializedRequest = JSON.serialize(obj1);
        restUtils('getDependencyCheck', 'POST', serializedRequest);
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void getWObyIds(){
        DCX_Wrapper.getWObyIdsObject obj = new DCX_Wrapper.getWObyIdsObject();
      obj.timeZone ='';
      obj.workorderIds = null;

        DCX_Wrapper.getWObyIdsObject obj1 = new DCX_Wrapper.getWObyIdsObject('',null);

        restUtils('getWObyIds', 'GET', '');
        restUtils('getWObyIds', 'POST', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }





    Static testMethod void singleWODetails(){
        restUtils('singleWODetails', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void diployUserSettingObject(){
        DCX_Wrapper.diployUserSettingObject obj = new DCX_Wrapper.diployUserSettingObject();
        List<string> settings = new  List<string>();
         List<string> userids = new List<string>();
       obj.settings =settings;
        obj.userids =userids;

        DCX_Wrapper.diployUserSettingObject obj1 = new DCX_Wrapper.diployUserSettingObject(settings,userids);

        restUtils('deployUserSetting', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void createLJSEvent(){
        DCX_Wrapper.createLJSEvent_object obj = new DCX_Wrapper.createLJSEvent_object();
        obj.timeZone = null;
        obj.lstEvent = null;
        obj.lsttechId = null;
        obj.eventMinDuration = null;
        obj.isTechWorkingHrsEnabled = null;
        obj.isMachineWorkingHrsEnabled = null;
        obj.isOverlappingEnabled = null;
        obj.isCalculateEndTime = null;
        obj.lstKeyValue = null;
        obj.updatePrimaryTech = null;
        obj.IsdeleteEvents = null;
        obj.deleteEventForOtherTechs = false;



        DCX_AES_EventServiceManager.AES_Request wrapper = new DCX_AES_EventServiceManager.AES_Request();
        list<Event> eventlist = new list<Event> ();
        List<string> techIds = new  List<string>();
DCX_Wrapper.createLJSEvent_object obj1 = new DCX_Wrapper.createLJSEvent_object(eventlist,'',techIds,10,true,true,true,true,null,false,false,false,null,null);
        wrapper.UserId ='123' ;
               wrapper.timeZone = 'req.timeZone';
              wrapper.lstEvent =  eventlist;
        wrapper.lsttechId =   techIds;
        wrapper.eventMinDuration = 120;
        wrapper.isTechWorkingHrsEnabled =true;
        wrapper.isMachineWorkingHrsEnabled= false;
        wrapper.isOverlappingEnabled =false;
        wrapper.isCalculateEndTime=false;
        wrapper.lstKeyValue =null;
        wrapper.updatePrimaryTech =false;
        wrapper.deleteEventForOtherTechs= false;

        DCX_AES_EventServiceManager.AES_Request wrapper1 = new DCX_AES_EventServiceManager.AES_Request('',eventlist,'',techIds,10,true,true,true,true,null,false,false,null,null);
        String str = JSON.serialize(wrapper1);
        restUtils('createLJSEvent', 'POST', str);
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void getEventHoverRules(){

        restUtils('getEventHoverRules', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }


    Static testMethod void listDispatcher(){

        restUtils('listDispatcher', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }


    Static testMethod void fetchDCXSetting(){

        restUtils('fetchDCXSetting', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }


    Static testMethod void deleteAESEvent(){
       DCX_Wrapper.deleteJDMEvent req = new DCX_Wrapper.deleteJDMEvent();
       req.EventStartDtTm= null;
         req.WorkOrderId= null;
          req.TechId = null;
         req.isDeleteAllEvents= null;
          req.timeZone= null;
          req.eventId= null;
         req.isUnassignTech= null;
         req.OwnerId= null;
        // public String EventStartDateTime {get;set;}
         req.isEarlierEvents= null;
          req.deleteSingleEventId = null;
          List<String> woids = new List<String>();
          woids.add('123');
DCX_Wrapper.deleteJDMEvent req1 = new DCX_Wrapper.deleteJDMEvent(woids);
String str = JSON.serialize(req);
        restUtils('deleteAESEvent', 'POST', str);
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }


    Static testMethod void restoreUserSetting(){
        restUtils('restoreUserSetting', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void eventSubjectDefinition(){
        restUtils('eventSubjectDefinition', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void eventExistInBusinessHour(){
        restUtils('existInBusinessHour', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void retriveWO(){
        restUtils('retriveWO', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void fetchOvernightEvents(){
        restUtils('fetchOvernightEvents', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void getQualifiedTechList(){
        restUtils('getQualifiedTechList', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    Static testMethod void getViewData_mising(){
        restUtils('getViewData_mising', 'GET', '');
        test.startTest();
        DCX_ServiceIntf.doGet();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }

    Static testMethod void test_MCTMDetail_missing(){
        restUtils('test_MCTMDetail_missing?woId=1001a', 'POST', '');
        test.startTest();
        DCX_ServiceIntf.doPost();
        DCX_ServiceIntf.doPut();
        test.stopTest();

        //System.assert(res.responseBody.toString().contains('TAG'), 'Tags not Retrieved');
    }
    
    Static testMethod void testDispatchConsole(){
        DispatchConsole_DCH dchClass = new DispatchConsole_DCH();
        dchClass.getTimeFormat();
        dchClass.getDateFormat(); 
    }



    Static void restUtils(String endPointUrl, String httpMethod, String serializedRequest){
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/svmx/rest/DCX_ServiceIntf/' + endPointUrl ;
        System.debug(loggingLevel.Info , 'URL ' + req.requestURI);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(serializedRequest);
        RestContext.request = req;
        RestContext.response = res;
    }

}