@isTest private class DCX_MultiCriteriaTechMatch_UT {
    public static SVMXC__Service_Group_Members__c objTechnician;
    @testSetup static void setup() {
        SVMXC__ServiceMax_Config_Data__c globalProfile = new SVMXC__ServiceMax_Config_Data__c();
        List<SVMXC__ServiceMax_Config_Data__c> configDataList = 
            new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Processes__c> settingValues = new List<SVMXC__ServiceMax_Processes__c>();

        globalProfile.recordTypeId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Profile');
        globalProfile.SVMXC__Configuration_Type__c = 'Global';
        globalProfile.SVMXC__Active__c = true;
        upsert globalProfile;

        List<SVMXC__Service_Group_Members__c> teamList = new List<SVMXC__Service_Group_Members__c>();
        List<SVMXC__Work_Order_Resource__c> objWOResourceList = new  List<SVMXC__Work_Order_Resource__c>();
        Account objAccount = new Account(
                                        Name ='Account123',
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
        upsert objAccount;

       //  system.assert(objAccount!=null, true);

        Contact objContact = new Contact(LastName='Last',AccountId =objAccount.Id);
        upsert objContact;

      //  system.assert(objContact!=null, true);

        Case objCase = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                        ContactId = objContact.Id,
                                        AccountId = objAccount.Id                                         
                                        ); 
        upsert objCase; 

      //  system.assertEquals(objCase.ContactId, objContact.Id);
       // system.assertEquals(objCase.AccountId, objAccount.Id);
                       
        SVMXC__Service_Group__c objTeam = new SVMXC__Service_Group__c (
                                            Name = 'TEAM123'
                                            );
        upsert objTeam;

        SVMXC__Territory__c objTerritory = new SVMXC__Territory__c (
                                            Name = 'TERRITORY 123'
                                            );
        upsert objTerritory;

         objTechnician = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH1_123' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true
                                            );
                                            
      //  system.assertEquals(objTechnician.SVMXC__Service_Group__c, objTeam.Id);
   //     system.assertEquals(objTechnician.SVMXC__Service_Territory__c, objTerritory.Id);
                       
        SVMXC__Service_Group_Members__c objTechnician2 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH2_123' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__Active__c = true
                                            );
        SVMXC__Service_Group_Members__c objTechnician3 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH3_123' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true
                                            );
        SVMXC__Service_Group_Members__c objTechnician4 = new SVMXC__Service_Group_Members__c (
                                            Name = 'TECH4_123' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Bangalore',
                                            SVMXC__Active__c = true
                                            );  
        SVMXC__Service_Group_Members__c objTechnician5 = new SVMXC__Service_Group_Members__c (
                                            Name = 'Test123_TECH_5' ,
                                            SVMXC__Latitude__c = 40.739582 , 
                                            SVMXC__Longitude__c = -73.980772, 
                                            SVMXC__Service_Group__c = objTeam.Id ,
                                            SVMXC__Service_Territory__c = objTerritory.Id,
                                            SVMXC__Enable_Scheduling__c = true,
                                            SVMXC__City__c = 'Hyderabad',
                                            SVMXC__Active__c = true
                                            );                                  
        teamList.add(objTechnician2);                 
        teamList.add(objTechnician);
        teamList.add(objTechnician3);    
        teamList.add(objTechnician4);
        teamList.add(objTechnician5);     
        upsert teamList;

        Product2 p1 = new Product2();
        p1.Name = 'Product1234';
        p1.SVMXC__Enable_Serialized_Tracking__c = true;
        p1.SVMXC__Stockable__c = true;
        p1.Family = 'Laptop';

        upsert p1;

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
                                            SVMXC__Locked_By_DC__c = true
                                            //SVMXC__Group_Member__c = objTechnician.Id
                                            //SVMXC__Group_Member__c = objTechnician.Id
                                            );
        upsert objWorkOrder;

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

        upsert objWOResourceList;

        RecordType rtype = [select id from RecordType where Name=:'SVMX Rule']; 
        RecordType RC = [select id, Name, SobjectType from RecordType where Name = 'Expressions' and SobjectType ='SVMXC__ServiceMax_Config_Data__c'];
        SVMXC__ServiceMax_Processes__c objSkillrule1 = new SVMXC__ServiceMax_Processes__c();
        objSkillrule1.RecordTypeId = rtype.Id;
        objSkillrule1.SVMXC__Name__c = 'Skill Rule Test1';
        objSkillrule1.SVMXC__Description__c = 'Skill Rule Test1';
        objSkillrule1.SVMXC__Select__c = true;               
        //objSkillrule1.SVMXC__Rule_Type__c = 'Skill Matching';
        objSkillrule1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        objSkillrule1.SVMXC__Sequence__c = 0.0000;
        objSkillrule1.SVMXC__Rule_Type__c = 'Skill Matching';
        //objSkillrule1.RecordTypeId = objrule.ExpHdr_Rtype_Id;
        insert objSkillrule1;
        SVMXC__ServiceMax_Config_Data__c confobj1 = new  SVMXC__ServiceMax_Config_Data__c();
        confobj1.SVMXC__Expression_Type__c = 'Skill_Eligibility';
        confobj1.RecordTypeId = RC.id;
        confobj1.SVMXC__Expression_Rule__c = objSkillrule1.id;
        confobj1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confobj1.SVMXC__Operator__c = 'eq';
        confobj1.SVMXC__Operand__c = 'SVMXC__City__c';
        insert confobj1; 
        SVMXC__Skill__c Skillobj2 = new SVMXC__Skill__c();
        Skillobj2.Name = 'HardWare';
        Skillobj2.SVMXC__Skill_Category__c = 'Installation';
        //Skillobj2.SVMXC__Skill__Tag = 'Electric';
        SVMXC__Skill__c Skillobj3 = new SVMXC__Skill__c();
        Skillobj3.Name = 'Test Skill';
        Skillobj3.SVMXC__Skill_Category__c = 'Installation';
        insert Skillobj2; 
        insert Skillobj3; 
        SVMXC__ServiceMax_Config_Data__c confobj2 = new  SVMXC__ServiceMax_Config_Data__c();
        confobj1.SVMXC__Skill__c = Skillobj2.id;
        //confobj1.RecordTypeId = objrule.ExpDtl_AppSkill_Id;
        confobj1.SVMXC__Expression_Rule__c = objSkillrule1.id;        
        insert confobj2;    
        SVMXC__ServiceMax_Processes__c objEligibilityCriteria1 = new SVMXC__ServiceMax_Processes__c();
        objEligibilityCriteria1.RecordTypeId = rtype.Id;
        objEligibilityCriteria1.SVMXC__Name__c = 'Eligibility Rule Test1';
        objEligibilityCriteria1.SVMXC__Description__c ='Eligibility Rule Test1';
        objEligibilityCriteria1.SVMXC__Select__c = true;

        objEligibilityCriteria1.SVMXC__Rule_Type__c = 'Tech Eligibility';
        objEligibilityCriteria1.SVMXC__Source_Object_Name__c='SVMXC__Service_Order__c';
        objEligibilityCriteria1.SVMXC__Sequence__c = 1.0000;
        //objEligibilityCriteria1.RecordTypeId = objcriteria.ExpHdr_Rtype_Id;
        insert objEligibilityCriteria1;
        SVMXC__ServiceMax_Config_Data__c confobj = new  SVMXC__ServiceMax_Config_Data__c();
                
        confobj.SVMXC__Expression_Type__c = 'Tech_Eligibility';
        confobj.RecordTypeId =RC.id;
        confobj.SVMXC__Expression_Rule__c = objEligibilityCriteria1.id;
        confobj.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confobj.SVMXC__Operator__c = 'eq';
        confobj.SVMXC__Operand__c = 'Bangalore';
        insert confobj;
        SVMXC__ServiceMax_Config_Data__c confobj11 = new  SVMXC__ServiceMax_Config_Data__c();
        confobj11.SVMXC__Expression_Type__c = 'Tech_match';
        confobj11.RecordTypeId =RC.id;
        confobj11.SVMXC__Expression_Rule__c = objEligibilityCriteria1.id;
        confobj11.SVMXC__Field_Name__c = 'SVMXC__City__c';
        confobj11.SVMXC__Operator__c = 'eq';
        confobj11.Target_Field_Name__c = 'SVMXC__City__c';
        insert confobj11;
                
    }
    @isTest 
   public static void testUT()
    {
        List<String> woIds = new List<String> ();
        List<SVMXC__Service_Order__c> woDetails = new List<SVMXC__Service_Order__c> ();

         SVMXC__Service_Group_Members__c objTechnician5 = [Select Id,SVMXC__Salesforce_User__c from 
                                                         SVMXC__Service_Group_Members__c
                                                         where Name = 'Test123_TECH_5'];


        SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c where 
                                                SVMXC__Preferred_Technician__c = :objTechnician5.Id];

        SVMXC__Service_Group__c objTeam = [Select Id from SVMXC__Service_Group__c where
                                           Name = 'TEAM123'];

        SVMXC__Skill__c Skillobj2 = [Select Id from SVMXC__Skill__c where Name ='HardWare'];
        SVMXC__Skill__c Skillobj3 = [Select Id from SVMXC__Skill__c where Name ='Test Skill'];

        SVMXC__Service_Group_Members__c objTechnician = [Select Id from SVMXC__Service_Group_Members__c where Name ='TECH1_123'];
        SVMXC__Service_Group_Members__c objTechnician2 = [Select Id from SVMXC__Service_Group_Members__c where Name ='TECH2_123'];
        SVMXC__Service_Group_Members__c objTechnician3 = [Select Id from SVMXC__Service_Group_Members__c where Name ='TECH3_123'];
        SVMXC__Service_Group_Members__c objTechnician4 = [Select Id from SVMXC__Service_Group_Members__c where Name ='TECH4_123'];

          String json = '{\"wo_woSelectionColor\":\"16711731\",\"wo_woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"wo_woHoverColor\":\"0\",\"wo_woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":null,\"name\":\"SVMXC__Actual_Resolution__c\"},{\"width\":null,\"name\":\"SVMXC__City__c\"},{\"width\":null,\"name\":\"SVMXC__Actual_Restoration__c\"},{\"width\":null,\"name\":\"SVMXC__Dispatch_Status__c\"}],\"wo_views\":null,\"wo_viewCounter\":[{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF3300\"},{\"sortOrder\":\"desc\",\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":\"Name\",\"color\":\"#FF9501\"},{\"sortOrder\":null,\"name\":\"None\",\"id\":null,\"columnIndex\":null,\"column\":null,\"color\":\"#0070D2\"}],\"wo_unassignWO\":\"false\",\"wo_deleteEventForTech\":\"false\",\"wo_deleteEventForTech\":\"false\",\"wo_sortOrder\":\"asc\",\"wo_sortColumn\":\"SVMXC__City__c\",\"wo_schedulingAsLongJob\":\"true\",\"wo_sch_col_fields\":[],\"wo_respectTechnincianWorkHours\":\"true\",\"wo_respectMachineAccessHours\":\"true\",\"wo_resetTime\":\"false\",\"wo_refreshtime\":\"4\",\"wo_isAlldayEvent\":\"false\",\"wo_isAdvMode\":\"false\",\"wo_grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\",\"SVMXC__Actual_Resolution__c\",\"SVMXC__Actual_Restoration__c\"],\"wo_grid_col_fields\":[],\"wo_filterColumn\":\"Name\",\"wo_doNotOverlapExistingEvents\":\"true\",\"wo_deleteEventWo\":\"false\",\"wo_defaultView\":\"a2421000002OUmZAAW\",\"wo_columnIndex\":\"0\",\"wo_autorefresh\":\"false\",\"tech_workingHoursColor\":\"15197666\",\"tech_viewAllEventsForToday\":\"false\",\"tech_view\":\"territory\",\"tech_toolTipShowDelay\":\"0\",\"tech_toolTipHideDelay\":\"3000\",\"tech_timeIndicatorColor\":\"#b3e5fc\",\"tech_territorySequence\":[],\"tech_techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"COMBOBOX\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\",\"ruleType\":\"EventRule\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\",\"ruleType\":\"EventRule\"}],\"tech_techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"tech_teamSequence\":[],\"tech_showTimeIndicator\":\"true\",\"tech_showSkills\":\"true\",\"tech_showProductExpertise\":\"true\",\"tech_showPrefTech\":\"true\",\"tech_showOptionMenu\":\"true\",\"tech_showFieldUpdates\":\"false\",\"tech_showEligibility\":\"true\",\"tech_searchSkills\":\"true\",\"tech_searchProductExpertise\":\"true\",\"tech_searchPrefTech\":\"true\",\"tech_searchEligibility\":\"true\",\"tech_retainDateOnShowRoute\":\"true\",\"tech_relatedEventColor\":\"10066329\",\"tech_refreshEventsOnChange\":\"false\",\"tech_pinMapActionBar\":\"true\",\"tech_overNightStayColor\":\"0\",\"tech_overheadColor\":\"#f44336\",\"tech_noOfDays\":\"0\",\"tech_mapDefaultZoomLevel\":\"6\",\"tech_mapDefaultLng\":\"78.35261934062497\",\"tech_mapDefaultLat\":\"17.213437680178284\",\"tech_loglevel\":\"WARN\",\"tech_locationBase\":\"home\",\"tech_holidayHoursColor\":\"10592673\",\"tech_favouriteTerritory\":\"\",\"tech_favouriteTeam\":\"\",\"tech_expandedTerritory\":[],\"tech_ExpandedTeam\":[\"'+objTeam.Id+'\"],\"tech_eventRowColor\":\"11723263\",\"tech_enableGoogleMapApi\":\"true\",\"tech_driveColor\":\"#4caf50\",\"tech_defaultWOEventColor\":\"#9c27b0\",\"tech_defaultEventColor\":\"13421568\",\"tech_dcmap\":\"false\",\"tech_dataTipOnClick\":\"false\",\"tech_condition\":\"before\",\"tech_autoSyncServiceDuration\":\"false\",\"tech_autoCalculateEndDate\":\"false\",\"search_techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"search_teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"search_keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Company__c\"}]},\"map_mapViewportWidth\":\"269\",\"adv_atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"adv_atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';

        DCX_SettingServiceManager.saveUserSettings(json);                                  



         //SVMXC__Service_Order__c objWorkOrder = [Select Id from SVMXC__Service_Order__c ];
        woIds.add(objWorkOrder.Id);
        woDetails.add(objWorkOrder);
        DCX_MultiCriteriaTechMatch.getMCTMDetails(woIds);
        DCX_MultiCriteriaTechMatch.getMatchingTechnicianEligibilityRulesforWO(woDetails);
        DCX_MultiCriteriaTechMatch.getWO(woIds);
        //public MCTM_Request(string WOid, string productExpertise, list<string>lstTech,list<skill>lstSkill, list<Eligibility>lstEligibility)

        DCX_MultiCriteriaTechMatch.MCTM_Request obj = new DCX_MultiCriteriaTechMatch.MCTM_Request();
        list<DCX_MultiCriteriaTechMatch.skill> wrpSkillValues = new list<DCX_MultiCriteriaTechMatch.skill>();
        DCX_MultiCriteriaTechMatch.skill skill1 = new DCX_MultiCriteriaTechMatch.skill(Skillobj2.id,'Hardware', true, 3);
        DCX_MultiCriteriaTechMatch.skill skill2 = new DCX_MultiCriteriaTechMatch.skill(Skillobj3.id,'Test Skill', false, 3);
        DCX_MultiCriteriaTechMatch.Eligibility Elig = new DCX_MultiCriteriaTechMatch.Eligibility('SVMXC__City__c','eq', null,'Bangalore');
        list<DCX_MultiCriteriaTechMatch.Eligibility> lstElig = new list<DCX_MultiCriteriaTechMatch.Eligibility>();
         obj.lstEligibility.add(Elig);
         obj.lstSkill.add(skill1);
         obj.lstTech.add(objTechnician2.id);
         obj.lstTech.add(objTechnician.id);
         
         obj.lstTech.add(objTechnician3.id);     
         obj.lstTech.add(objTechnician4.id);
         DCX_MultiCriteriaTechMatch.MPXtechnicians mpx1 = new DCX_MultiCriteriaTechMatch.MPXtechnicians(objTechnician.id, 'Mandatory','');
         obj.lstMPXTechnicans.add(mpx1);
         DCX_MultiCriteriaTechMatch.MPXtechnicians mpx2 = new DCX_MultiCriteriaTechMatch.MPXtechnicians(objTechnician2.id, 'Mandatory','');
         obj.lstMPXTechnicans.add(mpx2);
         DCX_MultiCriteriaTechMatch.MPXtechnicians mpx3 = new DCX_MultiCriteriaTechMatch.MPXtechnicians(objTechnician3.id, 'Preferred','');
         obj.lstMPXTechnicans.add(mpx3);
         DCX_MultiCriteriaTechMatch.MPXtechnicians mpx4 = new DCX_MultiCriteriaTechMatch.MPXtechnicians(objTechnician4.id, 'Prohibited','Deleted');
         obj.lstMPXTechnicans.add(mpx4);
            
            
         obj.WOid=objWorkOrder.id;
         obj.isPreferredTechEnabled=true;
         obj.isproductExpertiseEnabled=true;
         obj.isSkillsEnabled=true;
         obj.isEligibilityEnabled=true;

        DCX_MultiCriteriaTechMatch.getQualifiedTechList(obj);
        
        DCX_Wrapper.advTechSearchRequest req = new DCX_Wrapper.advTechSearchRequest(objWorkOrder.Id,true,true,true,true,obj.lstTech);
        DCX_MultiCriteriaTechMatch.advTechSearch(req);
       // DCX_MultiCriteriaTechMatch.getSkillsetFromWO(woDetails);
     //   DCX_MultiCriteriaTechMatch.getAllCandidateTechDetails(woDetails);
    }
    // public DCX_MultiCriteriaTechMatch_UT() {

    // }
    @isTest 
   public static void wrapperUT()
    {
      
        DCX_MultiCriteriaTechMatch.SVMXMap maplist = new DCX_MultiCriteriaTechMatch.SVMXMap();
        maplist.key = '';
        maplist.key ='';
        maplist.value='';
        maplist.values = null;
        maplist.valueMap = null;
        maplist.lstSkill= null;
        maplist.data=null;
        maplist.record=null;

        DCX_MultiCriteriaTechMatch.SVMXMap maplist1 = new DCX_MultiCriteriaTechMatch.SVMXMap('','');
        DCX_MultiCriteriaTechMatch.SVMXMap maplist2 = new DCX_MultiCriteriaTechMatch.SVMXMap('','',null);

        DCX_MultiCriteriaTechMatch.skill skills = new DCX_MultiCriteriaTechMatch.skill();
       skills.skillId='';
        skills.skillName='';
        skills.isSkillMandatory= true;
        skills.skillLevel =10;

        DCX_MultiCriteriaTechMatch.skill skills1 = new DCX_MultiCriteriaTechMatch.skill('','',true,10);

        DCX_MultiCriteriaTechMatch.Eligibility Eligibility1 = new DCX_MultiCriteriaTechMatch.Eligibility();
       Eligibility1.techField='';
        Eligibility1.operator='';
        Eligibility1.WOfield= 'true';
        Eligibility1.value ='10';

        DCX_MultiCriteriaTechMatch.Eligibility Eligibility2 = new DCX_MultiCriteriaTechMatch.Eligibility('','','true','10');

         DCX_MultiCriteriaTechMatch.MCTMDetails MCTMDetails1 = new DCX_MultiCriteriaTechMatch.MCTMDetails();
       MCTMDetails1.productExpertise='';
        MCTMDetails1.lstEligibility=null;
        MCTMDetails1.lstskill= null;
        MCTMDetails1.lstCandidatePrefTechId =null;
        MCTMDetails1.lstEventHover =null;

        DCX_MultiCriteriaTechMatch.MCTMDetails MCTMDetails2 = new DCX_MultiCriteriaTechMatch.MCTMDetails('',null,null,null);

        DCX_MultiCriteriaTechMatch.MCTMDetails MCTMDetails3 = new DCX_MultiCriteriaTechMatch.MCTMDetails('',null,null,null,null);
    }
}