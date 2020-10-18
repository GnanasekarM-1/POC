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
private class DCX_MetaDataServiceManager_UT {

    @isTest static void saveUserSettings() {
        SVMXC__ServiceMax_Config_Data__c globalProfile = new SVMXC__ServiceMax_Config_Data__c();
        globalProfile.recordTypeId = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', 'Configuration_Profile');
        globalProfile.SVMXC__Configuration_Type__c = 'Global';
        globalProfile.SVMXC__Active__c = true;
        insert globalProfile;
        DCX_MetaDataServiceManager.metaDataSetting metaDataSettings = DCX_MetaDataServiceManager.fetchMetaData();
        System.assert((metaDataSettings != null),'User metadata json fetched for logged in user');
        
        DCX_CommonServiceManager.UserSetting setting = new DCX_CommonServiceManager.UserSetting();
        setting.wo_autorefresh = null ;
        setting.wo_isAlldayEvent = null ;
        setting.wo_isAdvMode = null ;
        setting.wo_refreshtime = null ;
        setting.wo_sortColumn = null ;
        setting.wo_sortOrder = null ;
        setting.wo_columnIndex = null ;
        setting.wo_filterColumn = null ;
        setting.wo_woHoverColor = null ;
        setting.wo_defaultView = null ;
        setting.wo_woSelectionColor = null ;
        setting.wo_resetTime = null ;
        setting.wo_unassignWO = null ;
        setting.wo_deleteEventWo = null ;
        setting.wo_deleteEventForTech = null;
        setting.wo_schedulingAsLongJob = null ;
        setting.wo_respectTechnincianWorkHours = null ;
        setting.wo_respectMachineAccessHours = null ;
        setting.wo_doNotOverlapExistingEvents = null ;
        setting.tech_view = null ;
        setting.tech_enableGoogleMapApi = null ;
        setting.tech_dcmap = null ;
        setting.tech_mapDefaultZoomLevel = null ;
        setting.tech_mapDefaultLat = null ;
        setting.tech_mapDefaultLng = null ;
        setting.tech_loglevel = null ;
        setting.tech_noOfDays = null ;
        setting.tech_condition = null ;
        setting.tech_refreshEventsOnChange = null ;
        setting.tech_retainDateOnShowRoute = null ;
        setting.tech_autoCalculateEndDate = null ;
        setting.tech_eventRowColor = null ;
        setting.tech_driveColor = null ;
        setting.tech_overheadColor = null ;
        setting.tech_defaultEventColor = null ;
        setting.tech_defaultWOEventColor = null ;
        setting.tech_relatedEventColor = null ;
        setting.tech_workingHoursColor = null ;
        setting.tech_holidayHoursColor = null ;
        setting.tech_overNightStayColor = null ;
        setting.tech_viewAllEventsForToday = null ;
        setting.tech_toolTipShowDelay = null ;
        setting.tech_toolTipHideDelay = null ;
        setting.tech_pinMapActionBar = null ;
        setting.tech_showFieldUpdates = null ;
        setting.tech_showTimeIndicator = null ;
        setting.tech_timeIndicatorColor = null ;
        setting.tech_autoSyncServiceDuration = null ;
        setting.tech_locationBase = null ;
        setting.tech_dataTipOnClick = null ;
        setting.tech_showOptionMenu = null ;
        setting.tech_showSkills = null ;
        setting.tech_showProductExpertise = null ;
        setting.tech_showEligibility = null ;
        setting.tech_showPrefTech = null ;
        setting.tech_searchSkills = null ;
        setting.tech_searchProductExpertise = null ;
        setting.tech_searchEligibility = null ;
        setting.tech_searchPrefTech = null ;
        setting.tech_favouriteTeam = null ;
        setting.tech_ExpandedTeam = null ;
        setting.tech_favouriteTerritory = null ;
        setting.tech_expandedTerritory = null ;
        setting.map_mapViewportWidth = null ;
        
        DCX_CommonServiceManager.Views viewsData = new DCX_CommonServiceManager.Views();
        viewsData.name = null;
        viewsData.id = null;
        viewsData.column = null;
        viewsData.sortOrder = null;
        viewsData.columnIndex = null;
        DCX_CommonServiceManager.ViewCounter viewsData1 = new DCX_CommonServiceManager.ViewCounter();
        viewsData1.color = null;
        viewsData1.name = null;
        viewsData1.id = null;
        viewsData1.column = null;
        viewsData1.sortOrder = null;
        viewsData1.columnIndex = null;
        DCX_CommonServiceManager.WoCol viewsData2 = new DCX_CommonServiceManager.WoCol();
        viewsData2.name = null;
        viewsData2.width = null;
        DCX_CommonServiceManager.WoRules viewsData3 = new DCX_CommonServiceManager.WoRules();
        viewsData3.name = null;
        viewsData3.status = null;
        viewsData3.expression = null;
        viewsData3.color = null;
        DCX_CommonServiceManager.TechCol viewsData4 = new DCX_CommonServiceManager.TechCol();
        viewsData4.name = null;
        viewsData4.width = null;
        DCX_CommonServiceManager.TechRules viewsData5 = new DCX_CommonServiceManager.TechRules();
        viewsData5.name = null;
        viewsData5.status = null;
        viewsData5.expression = null;
        viewsData5.color = null;
        DCX_CommonServiceManager.Operand viewsData6 = new DCX_CommonServiceManager.Operand();
        viewsData6.property = null;
        viewsData6.type = null;
        viewsData6.fieldType = null;
        viewsData6.compare = null;
        viewsData6.value = null;
        DCX_CommonServiceManager.testSetting viewsData7 = new DCX_CommonServiceManager.testSetting();
        viewsData7.autorefresh = null;
        viewsData7.isAlldayEvent = null;
        viewsData7.isAdvMode = null;
       
    }

}