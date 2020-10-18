/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * Service manager which has business logic for all the services, related to user settings and svmx settings, re-written for DCx
 * @author Vinay Vijay
 * @version 19.2000
 * @since 2019
 */
public with sharing class DCX_SettingServiceManager {
    
        public static SVMXC.DCX_CommonServiceManager.UserSetting fetchUserSettings() {
        SVMXC.DCX_CommonServiceManager.UserSetting uSet;
        
        try{
            String userSettings = '';
            // Read User Settings from Dispatch Console Settings field in User Preference record
            try {
                SVMXC__SM_User_Preferences__c obj = [SELECT SVMXC__SM_DC_User_Settings__c from SVMXC__SM_User_Preferences__c where SVMXC__SM_User_Reference_Id__c=:Userinfo.getUserId() AND SVMXC__SM_Type__c='DCx' limit 1];
                if(obj != null){
                    userSettings = obj.SVMXC__SM_DC_User_Settings__c;
                    system.debug('User specific user settings: '+userSettings);             
                }
            }
            catch(Exception e) {
                system.debug('INFO - No user settings available for the logged in user.' +e);
            }

            // If User record does not have valid User Settings, use Custom UI Settings if they exist
            try {
                if(userSettings == null || userSettings == ''){
                    StaticResource customStaticResource = new StaticResource();
                    customStaticResource = [Select Name, Body From StaticResource where Name =  'DCx_Custom_User_Settings' limit 1];
                    userSettings = customStaticResource.Body.toString();
                    system.debug('Customer specifc user settings: '+userSettings);
                }
            }
            catch(Exception e) {
                system.debug('INFO - No Org specific user settings available.');
            }
            
            // If Custom UI Settings do not exist, use managed UI Settings
            try {
                if(userSettings == null || userSettings == ''){
                    StaticResource managedStaticResource = new StaticResource();
                    managedStaticResource = [Select Name, Body From StaticResource where Name =  'DCx_User_Settings' limit 1];
                    userSettings = managedStaticResource.Body.toString();
                    system.debug('SVMX specific user settings: '+userSettings);
                }
            }
            catch(Exception e) {
                system.debug('INFO - No default SVMX specific user settings available. Please contact system administrator.');
            }
            uSet = (SVMXC.DCX_CommonServiceManager.UserSetting)JSON.deserialize(userSettings, SVMXC.DCX_CommonServiceManager.UserSetting.class);
            string str = uSet.wo_autorefresh;
            system.debug('uSet str:' +str);
         //test
       //  if(Test.isRunningTest())
       //  {
         //    System.debug(1/0);
        // }
         //test
        }
        catch (DmlException ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getDmlMessage(0));
        }
        catch (Exception ex){
            throw new DCX_CommonServiceManager.DCxException(ex.getmessage());
        }
        return uSet;
    }
    
    public static void saveUserSettings(String usrSettings) {
        system.debug('User Settings for Saving: '+usrSettings);
            if(usrSettings == null || usrSettings == 'null' || usrSettings=='undefined'|| usrSettings == '{null}'){
                   throw new DCX_CommonServiceManager.DCxException('User setting can not be null');

            }
        try {
            SVMXC__SM_User_Preferences__c obj;
            try {
                obj = [select ID, SVMXC__SM_DC_User_Settings__c from SVMXC__SM_User_Preferences__c where SVMXC__SM_User_Reference_Id__c=:Userinfo.getUserId() AND SVMXC__SM_Type__c='DCx' limit 1];
                
            } catch (Exception e) {
                //do nothing
            }
                
            if(obj == null) {//create
                obj = new SVMXC__SM_User_Preferences__c(SVMXC__SM_DC_User_Settings__c = usrSettings, SVMXC__SM_Type__c='DCx', SVMXC__SM_User_Reference_Id__c = Userinfo.getUserId());
            }
            else {//update
                obj.SVMXC__SM_DC_User_Settings__c = usrSettings;
            }

            // if(COMM_SecurityUtils.getInstance().verifyFieldAccess(obj, COMM_SecurityUtils.Access.Upsertable)){
                    if(SVMXC__SM_User_Preferences__c.sObjectType.getDescribe().isCreateable() && SVMXC__SM_User_Preferences__c.sObjectType.getDescribe().isUpdateable()) {
                        upsert obj;
                    }
                    else {
                        throw new DCX_CommonServiceManager.DCxException('The logged in user does not have permissions to create and/or update the user preference object.');
                    }
            // }
            // else {
      //        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
      //       }
            
        } catch (DmlException e) {
            System.debug(e.getMessage());
            system.debug(logginglevel.error,'e.getstackTrace() '+e.getStackTraceString());
            throw new DCX_CommonServiceManager.DCxException(e.getDmlMessage(0));
        }
    }

    public class EventHoverRules {
        public Map<Id, SVMXC__ServiceMax_Processes__c> mapEventHoverRules {get; set;}
        public Map<Id, list<SVMXC__ServiceMax_Config_Data__c> > mapEventHoverRuleIdExpr {get; set;}
        public Map<Id, SVMXC__ServiceMax_Config_Data__c> mapEventHoverFields {get; set;}
        public Map<Id, List<Id> > mapEventHoverRuleIdFieldIdList {get; set;}
        public Set<String> setWOQueryFields {get; set;}

        EventHoverRules(Map<Id, SVMXC__ServiceMax_Processes__c> mapEventHoverRules,
                Map<Id, list<SVMXC__ServiceMax_Config_Data__c> > mapEventHoverRuleIdExpr,
                Map<Id, SVMXC__ServiceMax_Config_Data__c> mapEventHoverFields,
                Map<Id, List<Id> > mapEventHoverRuleIdFieldIdList,
                Set<String> setWOQueryFields) {
            this.mapEventHoverRules = mapEventHoverRules;
            this.mapEventHoverRuleIdExpr = mapEventHoverRuleIdExpr;
            this.mapEventHoverFields = mapEventHoverFields;
            this.mapEventHoverRuleIdFieldIdList = mapEventHoverRuleIdFieldIdList;
            this.setWOQueryFields = setWOQueryFields;
        }
    } 

    public static EventHoverRules fetchEventHoverRules() {
        Map<Id, SVMXC__ServiceMax_Processes__c> mapEventHoverRules  = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<Id, list<SVMXC__ServiceMax_Config_Data__c> > mapEventHoverRuleIdExpr  = new Map<Id, list<SVMXC__ServiceMax_Config_Data__c> >();
        Map<Id, SVMXC__ServiceMax_Config_Data__c> mapEventHoverFields = new Map<Id, SVMXC__ServiceMax_Config_Data__c>();
        Set<String> setWOQueryFields = new Set<String>();
        Map<Id, List<Id> > mapEventHoverRuleIdFieldIdList = new Map<Id, List<Id> >();
        String FieldMapRTypeId;
        String RuleRecordTypeId;
        String ExpressionRTypeId;

        // Get the labels for all the fields of Work Order and put them against field APIName
        Map<String, SObjectField> objWorkOrderFieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
        DCX_Utils dcUtils = new DCX_Utils();
        DCX_Utils.referenceFields_WP reference_M = dcUtils.SVMX_getReferenceFields(objWorkOrderFieldMap,true);
        objWorkOrderFieldMap.clear();
        List<String> allFields_L = reference_M.allFields_L;         //Get the all field list

        for(RecordType recType : [Select SobjectType, Id, Name From RecordType where (SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule') OR (SobjectType = 'SVMXC__ServiceMax_Config_Data__c' AND Name IN ('Expressions', 'Field Mapping'))]) {
            if(recType.Name == 'SVMX Rule')
                RuleRecordTypeId = recType.id;
            else if(recType.Name == 'Expressions')
                ExpressionRTypeId = recType.id;
            else if(recType.Name == 'Field Mapping')
                FieldMapRTypeId = recType.id;
        }

        // Get the Event Hover Rules' header definition
        for(SVMXC__ServiceMax_Processes__c oPro : [Select SVMXC__Sequence__c, SVMXC__Advance_Expression__c, Id From SVMXC__ServiceMax_Processes__c where RecordTypeId =:RuleRecordTypeId and SVMXC__Rule_Type__c = 'Event Hover Rule']) {
            mapEventHoverRules.put(oPro.Id, oPro);
        }

        if(mapEventHoverRules.size() > 0)       {
            // Get the Event Hover Rules' entry criteria
            for(SVMXC__ServiceMax_Config_Data__c oExp : [Select Id, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Display_Type__c, SVMXC__Expression_Rule__c, SVMXC__Field_Relationship_Name__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId = :ExpressionRTypeId and SVMXC__Expression_Type__c = 'DISP_Event_Hover_Rule' and SVMXC__Expression_Rule__c IN :mapEventHoverRules.keyset() Order By SVMXC__Sequence__c])
            {
                if(!mapEventHoverRuleIdExpr.ContainsKey(oExp.SVMXC__Expression_Rule__c))
                    mapEventHoverRuleIdExpr.put(oExp.SVMXC__Expression_Rule__c, new list<SVMXC__ServiceMax_Config_Data__c>());

                mapEventHoverRuleIdExpr.get(oExp.SVMXC__Expression_Rule__c).add(oExp);
                setWOQueryFields.add(oExp.SVMXC__Field_Name__c);
            }

            // Get the Hover Fields and store against the Rule Id
            for(SVMXC__ServiceMax_Config_Data__c objEventHoverField: [Select Id, SVMXC__Target_Field_Name__c, SVMXC__Sequence__c, SVMXC__Expression_Rule__c From SVMXC__ServiceMax_Config_Data__c where RecordTypeId = :FieldMapRTypeId and SVMXC__Expression_Rule__c IN :mapEventHoverRules.keyset() order by SVMXC__Sequence__c DESC]) {
                mapEventHoverFields.put(objEventHoverField.Id, objEventHoverField);
                List<Id> lstHoverFieldId = new List<Id>();
                lstHoverFieldId.add(objEventHoverField.Id);

                if(mapEventHoverRuleIdFieldIdList.get(objEventHoverField.SVMXC__Expression_Rule__c) != NULL)
                    lstHoverFieldId.addAll(mapEventHoverRuleIdFieldIdList.get(objEventHoverField.SVMXC__Expression_Rule__c));

                mapEventHoverRuleIdFieldIdList.put(objEventHoverField.SVMXC__Expression_Rule__c, lstHoverFieldId);
                setWOQueryFields.add(objEventHoverField.SVMXC__Target_Field_Name__c);
            }
        }

        for(String fieldName : allFields_L) {
            // Add the name fields for the reference fields
            if(fieldName.contains('.'))     {
                if(setWOQueryFields.contains(fieldName.split('\\.',2)[0].replace('__r','__c')))
                    setWOQueryFields.add(fieldName);
                else if((fieldName == 'Owner.Name' && setWOQueryFields.contains('OwnerId')) || (fieldName == 'CreatedBy.Name' && setWOQueryFields.contains('CreatedById')) || (fieldName == 'LastModifiedBy.Name' && setWOQueryFields.contains('LastModifiedById')) || (fieldName == 'RecordType.Name' && setWOQueryFields.contains('RecordTypeId')))
                    setWOQueryFields.add(fieldName);
            }
        }
        setWOQueryFields.retainAll(allFields_L);

        EventHoverRules rules = new EventHoverRules(mapEventHoverRules,mapEventHoverRuleIdExpr,
                mapEventHoverFields,mapEventHoverRuleIdFieldIdList,setWOQueryFields);
        return rules;
    }
        
     public static boolean deployUserSetting(list<string>settings,list<string>userids){
        SVMXC.DCX_CommonServiceManager.UserSetting uSet;
         String userSettings = '';
        String defaultUserSettings = '';
        boolean isUpdateable = false;
        
        SVMXC__SM_User_Preferences__c userObject;
        
        
            
         try{
                SVMXC__SM_User_Preferences__c userSettingObj = [SELECT SVMXC__SM_DC_User_Settings__c from SVMXC__SM_User_Preferences__c where SVMXC__SM_User_Reference_Id__c=:Userinfo.getUserId() AND SVMXC__SM_Type__c='DCx' limit 1];
                if(userSettingObj != null){
                    userSettings = userSettingObj.SVMXC__SM_DC_User_Settings__c;
                }
             } catch (Exception e) {
                system.debug('Exception :'+ e);
            }
            
                    StaticResource customStaticResource = new StaticResource();
                    try{
                    customStaticResource = [Select Name, Body From StaticResource where Name =  'DCx_Custom_User_Settings' limit 1];
                   
                   defaultUserSettings = customStaticResource.Body.toString();
                    } 
                    catch (Exception e) {
                        system.debug('defaultUserSettings 1'+defaultUserSettings);
                    }
             if(defaultUserSettings == null || defaultUserSettings == ''){
                    StaticResource managedStaticResource = new StaticResource();
                    try{
                    managedStaticResource = [Select Name, Body From StaticResource where Name =  'DCx_User_Settings' limit 1];
                    defaultUserSettings = managedStaticResource.Body.toString();
                    } 
                    catch (Exception e) {
                        system.debug('defaultUserSettings '+defaultUserSettings);
                    }
             }
             
              if(userSettings == null || userSettings == ''){
                userSettings = defaultUserSettings;
              }
              try {
                userObject = [select ID, SVMXC__SM_DC_User_Settings__c from SVMXC__SM_User_Preferences__c where SVMXC__SM_User_Reference_Id__c=:Userinfo.getUserId() AND SVMXC__SM_Type__c='DCx' limit 1];
                
            } catch (Exception e) {
                //do nothing
            }
            if(userObject == null) {//create
                userObject = new SVMXC__SM_User_Preferences__c(SVMXC__SM_DC_User_Settings__c = userSettings, SVMXC__SM_Type__c='DCx', SVMXC__SM_User_Reference_Id__c = Userinfo.getUserId());
            }
            
            // if(COMM_SecurityUtils.getInstance().verifyFieldAccess(userObject, COMM_SecurityUtils.Access.Upsertable) && userids.size() > 0){
                        //isUpdateable = true;
                    // }
                    // else {
                    //  isUpdateable = false;
              //        throw new COMM_SecurityUtils.SecurityAccessException(System.Label.COMM001_TAG142);
              //       }
             uSet = (SVMXC.DCX_CommonServiceManager.UserSetting)JSON.deserialize(userSettings, SVMXC.DCX_CommonServiceManager.UserSetting.class);
                     isUpdateable = SVMXC__SM_User_Preferences__c.sObjectType.getDescribe().isCreateable() && SVMXC__SM_User_Preferences__c.sObjectType.getDescribe().isUpdateable();
              if(isUpdateable){
                for(string DispatcherRecId:userids)
              {
                string dispUserSetting = '';
                try {
                    SVMXC__SM_User_Preferences__c obj;
                    try {
                        obj = [select ID, SVMXC__SM_DC_User_Settings__c from SVMXC__SM_User_Preferences__c where SVMXC__SM_User_Reference_Id__c=:DispatcherRecId AND SVMXC__SM_Type__c='DCx' limit 1];
                    } catch (Exception e) {
                    }
                    if(obj == null)
                    {
                        dispUserSetting = defaultUserSettings;
                    }   
                    else
                    {
                        dispUserSetting = obj.SVMXC__SM_DC_User_Settings__c;
                    }
                    SVMXC.DCX_CommonServiceManager.UserSetting deploySetting =  (SVMXC.DCX_CommonServiceManager.UserSetting)JSON.deserialize(dispUserSetting, SVMXC.DCX_CommonServiceManager.UserSetting.class);
                    
                    for(string settingValue:settings)
                    {
                        if(settingValue == 'wo_autorefresh')
                        {
                            deploySetting.wo_autorefresh = uSet.wo_autorefresh;
                        }
                        else if(settingValue == 'wo_isAlldayEvent')
                        {
                            deploySetting.wo_isAlldayEvent = uSet.wo_isAlldayEvent;
                        }
                        else if(settingValue == 'wo_isAdvMode')
                        {
                            deploySetting.wo_isAdvMode = uSet.wo_isAdvMode;
                        }
                        else if(settingValue == 'wo_refreshtime')
                        {
                            deploySetting.wo_refreshtime = uSet.wo_refreshtime;
                        }
                        else if(settingValue == 'wo_sortColumn')
                        {
                            deploySetting.wo_sortColumn = uSet.wo_sortColumn;
                        }
                        else if(settingValue == 'wo_sortOrder')
                        {
                            deploySetting.wo_sortOrder = uSet.wo_sortOrder;
                        }
                        else if(settingValue == 'wo_columnIndex')
                        {
                            deploySetting.wo_columnIndex = uSet.wo_columnIndex;
                        }
                        else if(settingValue == 'wo_filterColumn')
                        {
                            deploySetting.wo_filterColumn = uSet.wo_filterColumn;
                        }
                        else if(settingValue == 'wo_woHoverColor')
                        {
                            deploySetting.wo_woHoverColor = uSet.wo_woHoverColor;
                        }
                        else if(settingValue == 'wo_defaultView')
                        {
                            deploySetting.wo_defaultView = uSet.wo_defaultView;
                        }
                        else if(settingValue == 'wo_woSelectionColor')
                        {
                            deploySetting.wo_woSelectionColor = uSet.wo_woSelectionColor;
                        }
                        else if(settingValue == 'wo_resetTime')
                        {
                            deploySetting.wo_resetTime = uSet.wo_resetTime;
                        }
                        else if(settingValue == 'wo_unassignWO')
                        {
                            deploySetting.wo_unassignWO = uSet.wo_unassignWO;
                        }
                        else if(settingValue == 'wo_deleteEventForTech')
                        {
                            deploySetting.wo_deleteEventForTech = uSet.wo_deleteEventForTech;
                        }
                        else if(settingValue == 'wo_deleteEventWo')
                        {
                            deploySetting.wo_deleteEventWo = uSet.wo_deleteEventWo;
                        }
                        else if(settingValue == 'wo_schedulingAsLongJob')
                        {
                            deploySetting.wo_schedulingAsLongJob = uSet.wo_schedulingAsLongJob;
                        }
                        else if(settingValue == 'wo_respectTechnincianWorkHours')
                        {
                            deploySetting.wo_respectTechnincianWorkHours = uSet.wo_respectTechnincianWorkHours;
                        }
                        else if(settingValue == 'wo_respectMachineAccessHours')
                        {
                            deploySetting.wo_respectMachineAccessHours = uSet.wo_respectMachineAccessHours;
                        }
                        else if(settingValue == 'wo_doNotOverlapExistingEvents')
                        {
                            deploySetting.wo_doNotOverlapExistingEvents = uSet.wo_doNotOverlapExistingEvents;
                        }
                        else if(settingValue == 'tech_view')
                        {
                            deploySetting.tech_view = uSet.tech_view;
                        }
                        else if(settingValue == 'tech_enableGoogleMapApi')
                        {
                            deploySetting.tech_enableGoogleMapApi = uSet.tech_enableGoogleMapApi;
                        }
                        else if(settingValue == 'tech_dcmap')
                        {
                            deploySetting.tech_dcmap = uSet.tech_dcmap;
                        }
                        else if(settingValue == 'tech_mapDefaultZoomLevel')
                        {
                            deploySetting.tech_mapDefaultZoomLevel = uSet.tech_mapDefaultZoomLevel;
                        }
                        else if(settingValue == 'tech_mapDefaultLat')
                        {
                            deploySetting.tech_mapDefaultLat = uSet.tech_mapDefaultLat;
                        }
                        else if(settingValue == 'tech_mapDefaultLng')
                        {
                            deploySetting.tech_mapDefaultLng = uSet.tech_mapDefaultLng;
                        }
                        else if(settingValue == 'tech_loglevel')
                        {
                            deploySetting.tech_loglevel = uSet.tech_loglevel;
                        }
                        else if(settingValue == 'tech_noOfDays')
                        {
                            deploySetting.tech_noOfDays = uSet.tech_noOfDays;
                        }
                        else if(settingValue == 'tech_condition')
                        {
                            deploySetting.tech_condition = uSet.tech_condition;
                        }
                        else if(settingValue == 'tech_refreshEventsOnChange')
                        {
                            deploySetting.tech_refreshEventsOnChange = uSet.tech_refreshEventsOnChange;
                        }
                        else if(settingValue == 'tech_retainDateOnShowRoute')
                        {
                            deploySetting.tech_retainDateOnShowRoute = uSet.tech_retainDateOnShowRoute;
                        }
                        else if(settingValue == 'tech_autoCalculateEndDate')
                        {
                            deploySetting.tech_autoCalculateEndDate = uSet.tech_autoCalculateEndDate;
                        }
                        else if(settingValue == 'tech_eventRowColor')
                        {
                            deploySetting.tech_eventRowColor = uSet.tech_eventRowColor;
                        }
                        else if(settingValue == 'tech_driveColor')
                        {
                            deploySetting.tech_driveColor = uSet.tech_driveColor;
                        }
                        else if(settingValue == 'tech_overheadColor')
                        {
                            deploySetting.tech_overheadColor = uSet.tech_overheadColor;
                        }
                        else if(settingValue == 'tech_defaultEventColor')
                        {
                            deploySetting.tech_defaultEventColor = uSet.tech_defaultEventColor;
                        }
                        else if(settingValue == 'tech_defaultWOEventColor')
                        {
                            deploySetting.tech_defaultWOEventColor = uSet.tech_defaultWOEventColor;
                        }
                        else if(settingValue == 'tech_relatedEventColor')
                        {
                            deploySetting.tech_relatedEventColor = uSet.tech_relatedEventColor;
                        }
                        else if(settingValue == 'tech_workingHoursColor')
                        {
                            deploySetting.tech_workingHoursColor = uSet.tech_workingHoursColor;
                        }
                        else if(settingValue == 'tech_holidayHoursColor')
                        {
                            deploySetting.tech_holidayHoursColor = uSet.tech_holidayHoursColor;
                        }
                        else if(settingValue == 'tech_overNightStayColor')
                        {
                            deploySetting.tech_overNightStayColor = uSet.tech_overNightStayColor;
                        }
                        else if(settingValue == 'tech_viewAllEventsForToday')
                        {
                            deploySetting.tech_viewAllEventsForToday = uSet.tech_viewAllEventsForToday;
                        }
                        else if(settingValue == 'tech_toolTipShowDelay')
                        {
                            deploySetting.tech_toolTipShowDelay = uSet.tech_toolTipShowDelay;
                        }
                        else if(settingValue == 'tech_toolTipHideDelay')
                        {
                            deploySetting.tech_toolTipHideDelay = uSet.tech_toolTipHideDelay;
                        }
                        else if(settingValue == 'tech_pinMapActionBar')
                        {
                            deploySetting.tech_pinMapActionBar = uSet.tech_pinMapActionBar;
                        }
                        else if(settingValue == 'tech_showFieldUpdates')
                        {
                            deploySetting.tech_showFieldUpdates = uSet.tech_showFieldUpdates;
                        }
                        else if(settingValue == 'tech_showTimeIndicator')
                        {
                            deploySetting.tech_showTimeIndicator = uSet.tech_showTimeIndicator;
                        }
                        else if(settingValue == 'tech_timeIndicatorColor')
                        {
                            deploySetting.tech_timeIndicatorColor = uSet.tech_timeIndicatorColor;
                        }
                        else if(settingValue == 'tech_autoSyncServiceDuration')
                        {
                            deploySetting.tech_autoSyncServiceDuration = uSet.tech_autoSyncServiceDuration;
                        }
                        else if(settingValue == 'tech_locationBase')
                        {
                            deploySetting.tech_locationBase = uSet.tech_locationBase;
                        }
                        else if(settingValue == 'tech_dataTipOnClick')
                        {
                            deploySetting.tech_dataTipOnClick = uSet.tech_dataTipOnClick;
                        }
                        else if(settingValue == 'tech_showOptionMenu')
                        {
                            deploySetting.tech_showOptionMenu = uSet.tech_showOptionMenu;
                        }
                        else if(settingValue == 'tech_showSkills')
                        {
                            deploySetting.tech_showSkills = uSet.tech_showSkills;
                        }
                        else if(settingValue == 'tech_showProductExpertise')
                        {
                            deploySetting.tech_showProductExpertise = uSet.tech_showProductExpertise;
                        }
                        else if(settingValue == 'tech_showEligibility')
                        {
                            deploySetting.tech_showEligibility = uSet.tech_showEligibility;
                        }
                        else if(settingValue == 'tech_showPrefTech')
                        {
                            deploySetting.tech_showPrefTech = uSet.tech_showPrefTech;
                        }
                        else if(settingValue == 'tech_searchSkills')
                        {
                            deploySetting.tech_searchSkills = uSet.tech_searchSkills;
                        }
                        else if(settingValue == 'tech_searchProductExpertise')
                        {
                            deploySetting.tech_searchProductExpertise = uSet.tech_searchProductExpertise;
                        }
                        else if(settingValue == 'tech_searchEligibility')
                        {
                            deploySetting.tech_searchEligibility = uSet.tech_searchEligibility;
                        }
                        else if(settingValue == 'tech_searchPrefTech')
                        {
                            deploySetting.tech_searchPrefTech = uSet.tech_searchPrefTech;
                        }
                        else if(settingValue == 'tech_favouriteTeam')
                        {
                            deploySetting.tech_favouriteTeam = uSet.tech_favouriteTeam;
                        }
                        else if(settingValue == 'tech_ExpandedTeam')
                        {
                            deploySetting.tech_ExpandedTeam = uSet.tech_ExpandedTeam;
                        }
                        else if(settingValue == 'tech_favouriteTerritory')
                        {
                            deploySetting.tech_favouriteTerritory = uSet.tech_favouriteTerritory;
                        }
                        else if(settingValue == 'tech_expandedTerritory')
                        {
                            deploySetting.tech_expandedTerritory = uSet.tech_expandedTerritory;
                        }
                        else if(settingValue == 'map_mapViewportWidth')
                        {
                            deploySetting.map_mapViewportWidth = uSet.map_mapViewportWidth;
                        }
                        else if(settingValue == 'tech_territorySequence')
                        {
                            deploySetting.tech_territorySequence = uSet.tech_territorySequence;
                        }
                        else if(settingValue == 'tech_teamSequence')
                        {
                            deploySetting.tech_teamSequence = uSet.tech_teamSequence;
                        }
                        else if(settingValue == 'adv_atsSkills')
                        {
                            deploySetting.adv_atsSkills = uSet.adv_atsSkills;
                        }
                        else if(settingValue == 'adv_atsExpertise')
                        {
                            deploySetting.adv_atsExpertise = uSet.adv_atsExpertise;
                        }
                        else if(settingValue == 'adv_atsEligibility')
                        {
                            deploySetting.adv_atsEligibility = uSet.adv_atsEligibility;
                        }
                        else if(settingValue == 'adv_atsPrefTech')
                        {
                            deploySetting.adv_atsPrefTech = uSet.adv_atsPrefTech;
                        }
                        else if(settingValue == 'wo_woCol')
                        {
                            deploySetting.wo_woCol = uSet.wo_woCol;
                        }
                        else if(settingValue == 'wo_woRules')
                        {
                            deploySetting.wo_woRules = uSet.wo_woRules;
                        }
                        else if(settingValue == 'tech_techCol')
                        {
                            deploySetting.tech_techCol = uSet.tech_techCol;
                        }
                        else if(settingValue == 'tech_techRules')
                        {
                            deploySetting.tech_techRules = uSet.tech_techRules;
                        }
                        else if(settingValue == 'search_keyword')
                        {
                            deploySetting.search_keyword = uSet.search_keyword;
                        }
                        else if(settingValue == 'search_techKeyword')
                        {
                            deploySetting.search_techKeyword = uSet.search_techKeyword;
                        }
                        else if(settingValue == 'search_teamKeyword')
                        {
                            deploySetting.search_teamKeyword = uSet.search_teamKeyword;
                        }
                        
                        
                        
                    }
                    string uset12 = JSON.serialize(deploySetting);
                        
                    if(obj == null) {//create
                        
                        obj = new SVMXC__SM_User_Preferences__c(SVMXC__SM_DC_User_Settings__c = uset12, SVMXC__SM_Type__c='DCx', SVMXC__SM_User_Reference_Id__c = Userinfo.getUserId());
                    }
                    else {//update
                        obj.SVMXC__SM_DC_User_Settings__c = uset12;
                    }
                    if(SVMXC__SM_User_Preferences__c.sObjectType.getDescribe().isCreateable() && SVMXC__SM_User_Preferences__c.sObjectType.getDescribe().isUpdateable()) {
                        upsert obj;
                    }
                    else {
                        throw new DCX_CommonServiceManager.DCxException('The logged in user does not have permissions to create and/or update the user preference object.');
                    }                   
                } catch (DmlException e) {
                    System.debug(e.getMessage());
                    system.debug(logginglevel.error,'e.getstackTrace() '+e.getStackTraceString());
                    throw new DCX_CommonServiceManager.DCxException(e.getDmlMessage(0));
                }
              }
              }
                    else {
                        throw new DCX_CommonServiceManager.DCxException('The logged in user does not have permissions to create and/or update the user preference object.');
                    }

              
            return isUpdateable;
        
     }

    public static boolean restoreUserSettings() {
       Boolean status = true;
       String defaultUserSettings = '';
       SVMXC__SM_User_Preferences__c userSettingObj;
       try {
           List<SVMXC__SM_User_Preferences__c> userSettingObjs = [SELECT SVMXC__SM_DC_User_Settings__c from 
                                                           SVMXC__SM_User_Preferences__c where 
                                                           SVMXC__SM_User_Reference_Id__c=:Userinfo.getUserId() AND 
                                                           SVMXC__SM_Type__c='DCx' limit 1];
           if(userSettingObjs.size() > 0) {
               userSettingObj = userSettingObjs[0];
           }
            StaticResource managedStaticResource = new StaticResource();
            managedStaticResource = [Select Name, Body From StaticResource where Name =  'DCx_User_Settings' limit 1];
            defaultUserSettings = managedStaticResource.Body.toString();
           DCX_CommonServiceManager.UserSetting deploySetting =  
               (DCX_CommonServiceManager.UserSetting)JSON.deserialize(defaultUserSettings, DCX_CommonServiceManager.UserSetting.class);
           string uset12 = JSON.serialize(deploySetting); 
           if(userSettingObj == null) {//create
                userSettingObj = new SVMXC__SM_User_Preferences__c(SVMXC__SM_DC_User_Settings__c = uset12, 
                                                        SVMXC__SM_Type__c='DCx', 
                                                        SVMXC__SM_User_Reference_Id__c = Userinfo.getUserId());
            } else {//update
                userSettingObj.SVMXC__SM_DC_User_Settings__c = uset12;
            }
                    if(SVMXC__SM_User_Preferences__c.sObjectType.getDescribe().isCreateable() && SVMXC__SM_User_Preferences__c.sObjectType.getDescribe().isUpdateable()) {
                        upsert userSettingObj;
                    }
                    else {
                        throw new DCX_CommonServiceManager.DCxException('The logged in user does not have permissions to create and/or update the user preference object.');
                    }
       } catch (Exception ex) {
           status = false;
       }
       return status;
    }
    /*public static boolean deployUserSetting1(list<string>settings,list<string>userids){
        
           String str = '{"autorefresh": "false","isAlldayEvent": "false","isAdvMode": "false","refreshtime": "7"}';
           
           SVMXC.DCxCommonServiceManager.testSetting uSet1 = (SVMXC.DCxCommonServiceManager.testSetting)JSON.deserialize(str, SVMXC.DCxCommonServiceManager.testSetting.class); 
             system.debug('strstr : '+ uSet1.autorefresh);
           uSet1.autorefresh = 'true';
           system.debug('strstr : '+ uSet1.autorefresh);
        SVMXC.DCxCommonServiceManager.UserSetting uSet;
        
            String userSettings = '';
             String defaultUserSettings = '';
             boolean isUpdateble = false;
             try{
            // Read User Settings from Dispatch Console Settings field in User Preference record
                SVMXC__SM_User_Preferences__c obj1 = [SELECT SVMXC__SM_DC_User_Settings__c from SVMXC__SM_User_Preferences__c where SVMXC__SM_User_Reference_Id__c=:Userinfo.getUserId() AND SVMXC__SM_Type__c='DCx' limit 1];
                if(obj1 != null){
                    userSettings = obj1.SVMXC__SM_DC_User_Settings__c;
                    //system.debug('User specific user settings: '+userSettings);             
                }
             } catch (Exception e) {
                //do nothing
            }
            

            // If User record does not have valid User Settings, use Custom UI Settings if they exist
                if(userSettings == null || userSettings == ''){
                    StaticResource customStaticResource = new StaticResource();
                    try{
                    customStaticResource = [Select Name, Body From StaticResource where Name =  'DCx_Custom_User_Settings' limit 1];
                   
                   defaultUserSettings = customStaticResource.Body.toString();
                   // system.debug('Customer specifc user settings: '+userSettings);
                    } catch (Exception e) {
                //do nothing
            }
                }
                
            
            // If Custom UI Settings do not exist, use managed UI Settings
                if(defaultUserSettings == null || defaultUserSettings == ''){
                    StaticResource managedStaticResource = new StaticResource();
                    try{
                    managedStaticResource = [Select Name, Body From StaticResource where Name =  'DCx_User_Settings' limit 1];
                    defaultUserSettings = managedStaticResource.Body.toString();
                   // system.debug('SVMX specific user settings: '+userSettings);
                    } catch (Exception e) {
                //do nothing
            }
                }
             if(userSettings == null || userSettings == ''){
                userSettings = defaultUserSettings;
            }
            uSet = (SVMXC.DCxCommonServiceManager.UserSetting)JSON.deserialize(userSettings, SVMXC.DCxCommonServiceManager.UserSetting.class);
         List<User> allDispatchers = [Select Id, SVMXC__Dispatch_Console_Settings__c from User where Id IN :userids];
       string userXML = '';
      // SVMXC__SM_User_Preferences__c obj;
      system.debug('userids :'+userids);
       List<SVMXC__SM_User_Preferences__c> allDispatchers1 = [select ID, SVMXC__SM_DC_User_Settings__c from SVMXC__SM_User_Preferences__c where SVMXC__SM_User_Reference_Id__c  IN :userids AND SVMXC__SM_Type__c='DCx'];
       system.debug('allDispatchers1 :'+allDispatchers1);
       for(SVMXC__SM_User_Preferences__c DispatcherRec:allDispatchers1)
        {
            SVMXC__SM_User_Preferences__c obj;
            system.debug('DispatcherRec :'+DispatcherRec);
            userXML = '';
            if(DispatcherRec == null) {//create
                userXML = defaultUserSettings;
            //  SVMXC__SM_User_Preferences__c obj2 = defaultUserSettings;//new SVMXC__SM_User_Preferences__c(SVMXC__SM_DC_User_Settings__c = usrSettings, SVMXC__SM_Type__c='DCx', SVMXC__SM_User_Reference_Id__c = Userinfo.getUserId());
            }
            else {//update
                
                obj = DispatcherRec;
                userXML = obj.SVMXC__SM_DC_User_Settings__c;
                //obj.SVMXC__SM_DC_User_Settings__c = usrSettings;
            }
            SVMXC.DCxCommonServiceManager.UserSetting deploySetting = (SVMXC.DCxCommonServiceManager.UserSetting)JSON.deserialize(userXML, SVMXC.DCxCommonServiceManager.UserSetting.class); 
            system.debug('deploySetting.deploySetting : '+deploySetting);
             for(string settingValue:settings)
                {
                    //system.debug('deploySetting.settingValue : '+deploySetting);
                    //deploySetting.settingValue ='true';//uSet.settingValue;
                    deploySetting.autorefresh = 'true';
                }
                obj.SVMXC__SM_DC_User_Settings__c = JSON.serialize(deploySetting);
                 if(COMM_SecurityUtils.getInstance().verifyFieldAccess(allDispatchers1, COMM_SecurityUtils.Access.Updateable)){
                    update obj; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
        }
         
        
        return true;
    }  */
            public static SettingDCX retriveAppandUserSetting() {
                    List<string> lstSubModules = new List<string>{'DCON001','DCON005','OMAX003','SLAT003','DCON006', 'GLOB001'};
                    Map<String,String> appSetting = COMM_Utils_ManageSettings.SVMX_getDCSetting(lstSubModules);
                    system.debug('APP SETTINGS: '+appSetting);  
                    if(!Test.isRunningTest()){
                        String str= SVMXC__ServiceMax_Properties__c.getValues('MAPS_API_KEY_DC').SVMXC__Value__c;
                        if(str != null || str !=''){
                            appSetting.put('MAPS_API_KEY_DC',str);
                        }
                    }

                   /* SVMXC__ServiceMax_Properties__c objProperties = SVMXC__ServiceMax_Properties__c.getValues('MAPS_API_KEY_DC').SVMXC__Value__c;
                    if(objProperties != null && objProperties.SVMXC__Value__c != null) {
                        appSetting.put('MAPS_API_KEY_DC',objProperties.SVMXC__Value__c);
                    }  */
                    SVMXC.DCX_CommonServiceManager.UserSetting userSettings = SVMXC.DCX_SettingServiceManager.fetchUserSettings();
                    system.debug('USER SETTINGS: '+userSettings);   
                     
                    SettingDCX woData = new SettingDCX();
                    woData.appSettings = appSetting;
                    woData.userSettings = userSettings;
                    return woData;
            }

            public class SettingDCX{
        public Map<String, String> appSettings {get; set;}
        public SVMXC.DCX_CommonServiceManager.UserSetting userSettings {get; set;}

        // public SettingDCX( Map<String, String> appSettings ,SVMXC.DCX_CommonServiceManager.UserSetting settings){
        //      appSettings = appSettings;
                //      userSettings = settings;
        // }
                public SettingDCX(){

                }
    }
}