@isTest
public class DCX_SchedulerServiceManager_UT {

public static SVMXC__Service_Group_Members__c objTechnician;
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
        dcon001Process.SVMXC__SubmoduleID__c = 'DCON001';
        dcon001Process.SVMXC__MapID__c = 'dcon001Process';
        insert dcon001Process;

        String settingValueRecordTypeId = 
            COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Setting_Value');

        SVMXC__ServiceMax_Processes__c set001Process = new SVMXC__ServiceMax_Processes__c();
        set001Process.SVMXC__SettingID__c = 'SET001';
        set001Process.SVMXC__Submodule__c = dcon001Process.Id;
        set001Process.SVMXC__MapID__c = 'set001Process';
        insert set001Process;

         SVMXC__ServiceMax_Processes__c set033Process = new SVMXC__ServiceMax_Processes__c();
        set033Process.SVMXC__SettingID__c = 'SET033';
        set033Process.SVMXC__Submodule__c = dcon001Process.Id;
        set033Process.SVMXC__MapID__c = 'set033Process';
        insert set033Process;

         SVMXC__ServiceMax_Processes__c set034Process = new SVMXC__ServiceMax_Processes__c();
        set034Process.SVMXC__SettingID__c = 'SET034';
        set034Process.SVMXC__Submodule__c = dcon001Process.Id;
        set034Process.SVMXC__MapID__c = 'set034Process';
        insert set034Process;

        SVMXC__ServiceMax_Config_Data__c set001Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set001Setting.SVMXC__Internal_Value__c = '5';
        set001Setting.SVMXC__Display_Value__c = '5';
        set001Setting.recordtypeid = settingValueRecordTypeId;
        set001Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set001Setting.SVMXC__Setting_ID__c = set001Process.Id;
        insert set001Setting;

         SVMXC__ServiceMax_Config_Data__c set033Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set033Setting.SVMXC__Internal_Value__c = '20';
        set033Setting.SVMXC__Display_Value__c = '20';
        set033Setting.recordtypeid = settingValueRecordTypeId;
        set033Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set033Setting.SVMXC__Setting_ID__c = set033Process.Id;
        insert set033Setting;

         SVMXC__ServiceMax_Config_Data__c set034Setting =  new SVMXC__ServiceMax_Config_Data__c();
        set034Setting.SVMXC__Internal_Value__c = '5';
        set034Setting.SVMXC__Display_Value__c = '5';
        set034Setting.recordtypeid = settingValueRecordTypeId;
        set034Setting.SVMXC__Setting_Configuration_Profile__c = globalProfile.Id;
        set034Setting.SVMXC__Setting_ID__c = set034Process.Id;
        insert set034Setting;

         List<BusinessHours> lstdefaultbh = [SELECT FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE IsDefault = true];
        BusinessHours defaultbh = lstdefaultbh.get(0);  

        List<SVMXC__Service_Group_Members__c> teamList = new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Work_Order_Resource__c> objWOResourceList = new  List<SVMXC__Work_Order_Resource__c>();
        Account objAccount = new Account(
                                        Name ='123Account',
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
        insert objAccount;

         system.assert(objAccount!=null, true);

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        insert objContact;

        system.assert(objContact!=null, true);

        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        insert objCase; 

        system.assertEquals(objCase.ContactId, objContact.Id);
        system.assertEquals(objCase.AccountId, objAccount.Id);
                       
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (
                                            Name = 'TEAM _a'
                                            );
        insert objTeam;

        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY _a'
                                            );
        insert objTerritory;
 String usid=UserInfo.getUserId();
 SVMXC__Dispatcher_Access__c dacc = new SVMXC__Dispatcher_Access__c (
                                            SVMXC__Service_Team__c = objTeam.Id,
                                            SVMXC__Dispatcher__c = usid,
                                            SVMXC__Territory__c = objTerritory.Id
                                            );
        insert dacc;

         objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH_a' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true,
                                            SVMXC__Working_Hours__c = defaultbh.Id,
                                            SVMXC__Break_Hours__c = defaultbh.Id
                                            );
                                            
        system.assertEquals(objTechnician.SVMXC__Service_Group__c, objTeam.Id);
        system.assertEquals(objTechnician.SVMXC__Service_Territory__c, objTerritory.Id);
                       
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH_b' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Active__c = true,
                                            SVMXC__Working_Hours__c = defaultbh.Id,
                                            SVMXC__Break_Hours__c = defaultbh.Id
                                            );
        SVMXC__Service_Group_Members__c objTechnician3 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH_c' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true,
                                            SVMXC__Working_Hours__c = defaultbh.Id,
                                            SVMXC__Break_Hours__c = defaultbh.Id
                                            );
        SVMXC__Service_Group_Members__c objTechnician4 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH_d' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true,
                                            SVMXC__Working_Hours__c = defaultbh.Id,
                                            SVMXC__Break_Hours__c = defaultbh.Id
                                            );  
        SVMXC__Service_Group_Members__c objTechnician5 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH_e' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Hyderabad',
                                            SVMXC__Active__c = true,
                                            SVMXC__Working_Hours__c = defaultbh.Id,
                                            SVMXC__Break_Hours__c = defaultbh.Id
                                            );                                  
        teamList.add(objTechnician2);                 
        teamList.add(objTechnician);
        teamList.add(objTechnician3);    
        teamList.add(objTechnician4);
        teamList.add(objTechnician5);     
        insert teamList;

        Product2 p1 = new Product2();
        p1.Name = 'Product1';
        p1.SVMXC__Enable_Serialized_Tracking__c = true;
        p1.SVMXC__Stockable__c = true;
        p1.Family = 'Laptop';

        insert p1;

         SVMXC__Service_Order__c objWorkOrder = new SVMXC__Service_Order__c (
                                            SVMXC__Case__c = objCase.Id ,
                                            SVMXC__Company__c = objAccount.Id , 
                                            SVMXC__Product__c = p1.Id , 
                                            SVMXC__Preferred_Technician__c = objTechnician5.Id , 
                                            SVMXC__Contact__c =objContact.Id, 
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Order_Status__c = 'Open',
                                            SVMXC__Priority__c = 'Medium',
                                            SVMXC__Order_Type__c= 'Field Service',
                                            SVMXC__Scheduled_Date__c = system.today(),
                                            SVMXC__Locked_By_DC__c = true,
                                            SVMXC__Skill_Set__c = ''
                                            //SVMXC__Group_Member__c = objTechnician.Id
                                            //SVMXC__Group_Member__c = objTechnician.Id
                                            );
        insert objWorkOrder;

        SVMXC__Work_Order_Resource__c objWOResource = new SVMXC__Work_Order_Resource__c (
                                            SVMXC__Work_Order__c = objWorkOrder.Id ,
                                            SVMXC__Group_Member__c = objTechnician.Id ,
                                            SVMXC__Preference_Type__c   = 'Mandatory'                                       
                                            );
        SVMXC__Work_Order_Resource__c objWOResource2 = new SVMXC__Work_Order_Resource__c (
                                            SVMXC__Work_Order__c = objWorkOrder.Id ,
                                            SVMXC__Group_Member__c = objTechnician2.Id ,
                                            SVMXC__Preference_Type__c   = 'Preferred'                                       
                                            );
        SVMXC__Work_Order_Resource__c objWOResource3 = new SVMXC__Work_Order_Resource__c (
                                            SVMXC__Work_Order__c = objWorkOrder.Id ,
                                            SVMXC__Group_Member__c = objTechnician3.Id ,
                                            SVMXC__Preference_Type__c   = 'Prohibited'                                      
                                            );  
       SVMXC__Work_Order_Resource__c objWOResource4 = new SVMXC__Work_Order_Resource__c (
                                            SVMXC__Work_Order__c = objWorkOrder.Id ,
                                            SVMXC__Group_Member__c = objTechnician4.Id ,
                                            SVMXC__Preference_Type__c   = 'Prohibited'                                      
                                            );   
        objWOResourceList.add(objWOResource);    
        objWOResourceList.add(objWOResource2); 
        objWOResourceList.add(objWOResource3); 
        objWOResourceList.add(objWOResource4); 

        insert objWOResourceList;

        

    }
    @isTest static void fetchSchedulerData_test() {

         SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM _a'];

        String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);
        
        DCX_SchedulerServiceManager.fetchSchedulerData();

        List<String> TechListid = new List<String>();
        String techId = '';
        List<SVMXC__Service_Group_Members__c> techList = [Select Id from SVMXC__Service_Group_Members__c ];
         

        for(SVMXC__Service_Group_Members__c tech : techList){
                techId = tech.id;
                break;
        }
        TechListid.add(techId);
        String DstartDate ='2019-11-27T00:00:00.000';
        string DendDate ='2019-12-03T00:00:00.000Z';
         DCX_SchedulerServiceManager.Tech_WorkingHours tech_workinghrs = DCX_SchedulerServiceManager.DCX_Retrieve_Tech_WorkingHrs_WS(TechListid,DstartDate,DendDate);
         
         List<String> techFields = new  List<String>();
        // techFields.add('SVMXC__City__c');
        DCX_Wrapper.technicianIds tech123 = new DCX_Wrapper.technicianIds(TechListid,techFields);
        tech123.techIds = TechListid;
        tech123.techFields = techFields;
        Map<Id,DCX_SchedulerServiceManager.Technician_WP> ft =DCX_SchedulerServiceManager.fetchTechDetails(tech123);

        SVMXC__Service_Order__c woObject = [Select Id,SVMXC__Case__c,SVMXC__Company__c,
                                                                            SVMXC__Product__c,SVMXC__Preferred_Technician__c,SVMXC__Contact__c,
                                                                            SVMXC__Latitude__c,SVMXC__Longitude__c,SVMXC__Order_Status__c,
                                                                            SVMXC__Priority__c,SVMXC__Order_Type__c,SVMXC__Scheduled_Date__c,
                                                                            SVMXC__Locked_By_DC__c,SVMXC__Skill_Set__c from SVMXC__Service_Order__c ];
      
        List<String> woIds = new  List<String>();
        List<SVMXC__Service_Order__c> woObj = new  List<SVMXC__Service_Order__c>();
        woIds.add(woObject.Id);
        woObj.add(woObject);
        DCX_SchedulerServiceManager.getMCTMDetails(woIds);
        DCX_SchedulerServiceManager.getSkillsetFromWO(woObj);
        DCX_SchedulerServiceManager.getMatchingTechnicianEligibilityRulesforWO(woObj);
          DCX_SchedulerServiceManager.getAllCandidateTechDetails(woObj);
          DCX_SchedulerServiceManager.fetchSchedulerDataNew();
    }

    @isTest static void fetchSchedulerData_wrapper() {
        DCX_SchedulerServiceManager.skill skills = new DCX_SchedulerServiceManager.skill();
       skills.skillId='';
        skills.skillName='';
        skills.isSkillMandatory= true;
        skills.skillLevel =10;
        DCX_SchedulerServiceManager.skill skills1 = new DCX_SchedulerServiceManager.skill('','',true,10);

        DCX_SchedulerServiceManager.Eligibility Eligibility1 = new DCX_SchedulerServiceManager.Eligibility();
       Eligibility1.techField='';
        Eligibility1.operator='';
        Eligibility1.WOfield= 'true';
        Eligibility1.value ='10';
        DCX_SchedulerServiceManager.Eligibility Eligibility2 = new DCX_SchedulerServiceManager.Eligibility('','','true','10');

        DCX_SchedulerServiceManager.SVMXMap maplist = new DCX_SchedulerServiceManager.SVMXMap();
        maplist.key = '';
        maplist.key ='';
        maplist.value='';
        maplist.values = null;
        maplist.valueMap = null;
        maplist.lstSkill= null;
        maplist.data=null;
        maplist.record=null;
        DCX_SchedulerServiceManager.SVMXMap maplist1 = new DCX_SchedulerServiceManager.SVMXMap('','');
        DCX_SchedulerServiceManager.SVMXMap maplist2 = new DCX_SchedulerServiceManager.SVMXMap('','',null);

         DCX_SchedulerServiceManager.MCTMDetails MCTMDetails1 = new DCX_SchedulerServiceManager.MCTMDetails();
       MCTMDetails1.productExpertise='';
        MCTMDetails1.lstEligibility=null;
        MCTMDetails1.lstskill= null;
        MCTMDetails1.lstCandidatePrefTechId =null;
        MCTMDetails1.lstEventHover =null;

        DCX_SchedulerServiceManager.MCTMDetails MCTMDetails2 = new DCX_SchedulerServiceManager.MCTMDetails('',null,null,null);
        DCX_SchedulerServiceManager.MCTMDetails MCTMDetails3 = new DCX_SchedulerServiceManager.MCTMDetails('',null,null,null,null);
    }


}