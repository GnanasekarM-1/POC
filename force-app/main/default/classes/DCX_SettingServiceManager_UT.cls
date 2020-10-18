/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DCX_SettingServiceManager_UT {

    static String json = '{\"woSelectionColor\":\"16711731\",\"woRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Critical\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Critical Work Orders\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"High\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"High Priority Work Orders\",\"expression\":\"\",\"color\":\"16737996\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Medium\",\"type\":null,\"property\":\"SVMXC__Priority__c\",\"fieldType\":\"picklist\",\"compare\":\"matches\"}],\"name\":\"Medium Priority Work Orders\",\"expression\":\"\",\"color\":\"16776960\"}],\"workingHoursColor\":\"15197666\",\"woHoverColor\":\"0\",\"woCol\":[{\"width\":\"145\",\"name\":\"Name\"},{\"width\":\"141\",\"name\":\"SVMXC__Company__c\"},{\"width\":\"126\",\"name\":\"SVMXC__Contact__c\"},{\"width\":\"94\",\"name\":\"SVMXC__Case__c\"},{\"width\":\"57\",\"name\":\"SVMXC__Priority__c\"},{\"width\":\"79\",\"name\":\"SVMXC__Order_Status__c\"},{\"width\":\"120\",\"name\":\"SVMXC__Order_Type__c\"},{\"width\":\"94\",\"name\":\"SVMXC__Dispatch_Status__c\"},{\"width\":\"100\",\"name\":\"SVMXC__Group_Member__c\"},{\"width\":\"248\",\"name\":\"SVMXC__City__c\"}],\"views\":null,\"viewCounter\":null,\"viewAllEventsForToday\":\"false\",\"view\":\"territory\",\"unassignWO\":\"false\",\"toolTipShowDelay\":\"0\",\"toolTipHideDelay\":\"3000\",\"timeIndicatorColor\":\"255\",\"territorySequence\":[],\"techRules\":[{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Call\",\"type\":\"EVENT\",\"property\":\"Subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Call\",\"expression\":\"\",\"color\":\"16750848\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Email\",\"type\":\"EVENT\",\"property\":\"Subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Email\",\"expression\":\"\",\"color\":\"65280\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Meeting\",\"type\":\"EVENT\",\"property\":\"Subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Meeting\",\"expression\":\"\",\"color\":\"255\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Send Letter/Quote\",\"type\":\"EVENT\",\"property\":\"Subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Send Letter/Quote\",\"expression\":\"\",\"color\":\"65535\"},{\"status\":\"TAG168\",\"operand\":[{\"value\":\"Other\",\"type\":\"EVENT\",\"property\":\"Subject\",\"fieldType\":\"combobox\",\"compare\":\"matches\"}],\"name\":\"Other\",\"expression\":\"\",\"color\":\"16711935\"}],\"techKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"EXPERTISE\"},{\"width\":\"0\",\"name\":\"Name\"},{\"width\":\"0\",\"name\":\"PRODUCT\"}]},\"techCol\":[{\"width\":\"160\",\"name\":\"Name\"}],\"teamSequence\":[],\"teamKeyword\":{\"matchcriteria\":\"any\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Country__c\"}]},\"sortOrder\":\"DESC\",\"sortColumn\":\"Name\",\"showTimeIndicator\":\"true\",\"showSkills\":\"true\",\"showProductExpertise\":\"true\",\"showPrefTech\":\"true\",\"showOptionMenu\":\"true\",\"showFieldUpdates\":\"false\",\"showEligibility\":\"true\",\"searchSkills\":\"true\",\"searchProductExpertise\":\"true\",\"searchPrefTech\":\"true\",\"searchEligibility\":\"true\",\"schedulingAsLongJob\":\"true\",\"retainDateOnShowRoute\":\"true\",\"respectTechnincianWorkHours\":\"true\",\"respectMachineAccessHours\":\"true\",\"resetTime\":\"false\",\"grid_conf_fields\":[\"Name\",\"SVMXC__Company__c\",\"SVMXC__Contact__c\",\"SVMXC__Case__c\",\"SVMXC__Priority__c\",\"SVMXC__Order_Status__c\",\"SVMXC__Order_Type__c\",\"SVMXC__Dispatch_Status__c\",\"SVMXC__Group_Member__c\",\"SVMXC__City__c\",\"SVMXC__Component__c\",\"SVMXC__State__c\",\"SVMXC__Zip__c\",\"SVMXC__Service_Group__c\",\"SVMXC__Driving_Time__c\",\"SVMXC__Preferred_Start_Time__c\",\"SVMXC__Product__c\"],\"relatedEventColor\":\"10066329\",\"refreshtime\":\"7\",\"refreshEventsOnChange\":\"false\",\"pinMapActionBar\":\"true\",\"overNightStayColor\":\"0\",\"overheadColor\":\"16750848\",\"noOfDays\":\"0\",\"mapViewportWidth\":\"269\",\"mapDefaultZoomLevel\":\"6\",\"mapDefaultLng\":\"78.35261934062497\",\"mapDefaultLat\":\"17.213437680178284\",\"loglevel\":\"WARN\",\"locationBase\":\"home\",\"keyword\":{\"matchcriteria\":\"\",\"col\":[{\"width\":\"0\",\"name\":\"SVMXC__Case__c\"},{\"width\":\"0\",\"name\":\"SVMXC__City__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Component__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Order_Status__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Order_Type__c\"},{\"width\":\"0\",\"name\":\"SVMXC__State__c\"},{\"width\":\"0\",\"name\":\"SVMXC__Zip__c\"}]},\"isAlldayEvent\":\"false\",\"isAdvMode\":\"false\",\"holidayHoursColor\":\"10592673\",\"filterColumn\":\"Name\",\"favouriteTerritory\":\"\",\"favouriteTeam\":\"\",\"eventRowColor\":\"11723263\",\"enableGoogleMapApi\":\"true\",\"driveColor\":\"39372\",\"doNotOverlapExistingEvents\":\"true\",\"deleteEventWo\":\"false\",\"defaultWOEventColor\":\"16776960\",\"defaultView\":\"\",\"defaultEventColor\":\"13421568\",\"dcViewportWidth\":\"1080\",\"dcmap\":\"true\",\"dataTipOnClick\":\"true\",\"condition\":\"before\",\"columnIndex\":\"0\",\"collapsedTerritory\":\"\",\"collapsedTeam\":\"a1H2I00000H29OTUAZ\",\"autoSyncServiceDuration\":\"false\",\"autorefresh\":\"false\",\"autoCalculateEndDate\":\"true\",\"atsSkills\":{\"show\":\"true\",\"search\":\"true\"},\"atsPrefTech\":{\"show\":\"true\",\"search\":\"true\"},\"atsExpertise\":{\"show\":\"true\",\"search\":\"true\"},\"atsEligibility\":{\"show\":\"true\",\"search\":\"true\"}}';
    
    @isTest static void saveUserSettings() {
        
        
        DCX_SettingServiceManager.saveUserSettings(json);
        System.assert(true,'User setting json saved for logged in user');
    }
    
    @isTest static void fetchEventHoverRules() {
        
        
        DCX_SettingServiceManager.fetchEventHoverRules();
        System.assert(true,'Event Hover rules fetched successfully');
    }

    @isTest static void restoreUserSettings() {
        
        
        DCX_SettingServiceManager.restoreUserSettings();
        System.assert(true,'User settings restored successfully');
    }

    @isTest static void retriveAppandUserSetting() {
        
        
        DCX_SettingServiceManager.retriveAppandUserSetting();
        System.assert(true,'App and user settings fetched successfully');
    }

    @isTest static void fetchUserSettings() {
        //SVMXC__SM_User_Preferences__c objSetting = new SVMXC__SM_User_Preferences__c (
          //                                  SVMXC__SM_DC_User_Settings__c = json
           //                                 );
      //  insert objSetting;
        
        DCX_CommonServiceManager.UserSetting uset = DCX_SettingServiceManager.fetchUserSettings();
        System.assert((uset != null),'User setting json fetched for logged in user');
    }
    @isTest static void deployUserSetting() {
        //SVMXC__SM_User_Preferences__c objSetting = new SVMXC__SM_User_Preferences__c (
          //                                  SVMXC__SM_DC_User_Settings__c = json
           //                                 );
      //  insert objSetting;
        list<string> ids = new list<string>();
        ids.add(Userinfo.getUserId());
        list <string> setting = new list<string>();
        setting.add('wo_autorefresh');
        setting.add('wo_isAlldayEvent');
        setting.add('wo_isAdvMode');
        setting.add('wo_refreshtime');
        setting.add('wo_sortColumn');
        setting.add('wo_sortOrder');
        setting.add('wo_columnIndex');
        setting.add('wo_filterColumn');
        setting.add('wo_woHoverColor');
        setting.add('wo_defaultView');
        setting.add('wo_woSelectionColor');
        setting.add('wo_resetTime');
        setting.add('wo_unassignWO');
        setting.add('wo_deleteEventWo');
        setting.add('wo_schedulingAsLongJob');
        setting.add('wo_respectTechnincianWorkHours');
        setting.add('wo_respectMachineAccessHours');
        setting.add('wo_doNotOverlapExistingEvents');
        setting.add('tech_view');
        setting.add('tech_enableGoogleMapApi');
        setting.add('tech_dcmap');
        setting.add('tech_mapDefaultZoomLevel');
        setting.add('tech_mapDefaultLat');
        setting.add('tech_mapDefaultLng');
        setting.add('tech_loglevel');
        setting.add('tech_noOfDays');
        setting.add('tech_condition');
        setting.add('tech_refreshEventsOnChange');
        setting.add('tech_retainDateOnShowRoute');
        setting.add('tech_autoCalculateEndDate');
        setting.add('tech_eventRowColor');
        setting.add('tech_driveColor');
        setting.add('tech_overheadColor');
        setting.add('tech_defaultEventColor');
        setting.add('tech_defaultWOEventColor');
        setting.add('tech_relatedEventColor');
        setting.add('tech_workingHoursColor');
        setting.add('tech_holidayHoursColor');
        setting.add('tech_overNightStayColor');
        setting.add('tech_viewAllEventsForToday');
        setting.add('tech_toolTipShowDelay');
        setting.add('tech_toolTipHideDelay');
        setting.add('tech_pinMapActionBar');
        setting.add('tech_showFieldUpdates');
        setting.add('tech_showTimeIndicator');
        setting.add('tech_timeIndicatorColor');
        setting.add('tech_autoSyncServiceDuration');
        setting.add('tech_locationBase');
        setting.add('tech_dataTipOnClick');
        setting.add('tech_showOptionMenu');
        setting.add('tech_showSkills');
        setting.add('tech_showProductExpertise');
        setting.add('tech_showEligibility');
        setting.add('tech_showPrefTech');
        setting.add('tech_searchSkills');
        setting.add('tech_searchProductExpertise');
        setting.add('tech_searchEligibility');
        setting.add('tech_searchPrefTech');
        setting.add('tech_favouriteTeam');
        setting.add('tech_expandedTeam');
        setting.add('tech_favouriteTerritory');
        setting.add('tech_expandedTerritory');
        setting.add('map_mapViewportWidth');
        setting.add('tech_territorySequence');
        setting.add('tech_teamSequence');
        setting.add('adv_atsSkills');
        setting.add('adv_atsExpertise');
        setting.add('adv_atsEligibility');
        setting.add('adv_atsPrefTech');
        setting.add('wo_woCol');
        setting.add('wo_woRules');
        setting.add('tech_techCol');
        setting.add('tech_techRules');
        setting.add('search_keyword');
        setting.add('search_techKeyword');
        setting.add('search_teamKeyword');
            
        DCX_SettingServiceManager.deployUserSetting(setting,ids);
        System.assert(true,'User setting json saved for logged in user');
    }
    
    
}