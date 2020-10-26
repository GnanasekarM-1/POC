trigger Event_Trigger1 on Event (before insert, after insert, before update, after update, before delete, after delete)
{
    //Added fix for defect 045475 : When user doesn't have serviceMax package licence, manage trigger should not execute
    if(!Test.isRunningTest() && (!USER_LicenseAssignment.isServiceMaxPackageAccesible()))
    {
        System. ('Event_Trigger1  trigger disabled');
        return;
    }
    
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    public static boolean isRecursiveCall = true;
    public static map<string, Map<String, String>> mapEventTriggerSetting = new map<string, Map<String, String>>();
    //Important: when submodules are added to the list, add same submodules to list in workorder trigger too
    //Added MOBN002 for BAC-4839, MOBN002 replaced with SFA002
    list<string> lstSubModuleId = new list<string>{'GLOB001','OMAX001','OMAX003','SLAT003','PREV004','IPRD009','EVER007','IPRD003','DCON002','DCON003','DCON004','WORD023','WORD012','MOBN001','IPAD018','WORD022','SORG001','DCON005','SFA002'};
    
    system.debug(loggingLevel.WARN, '=====1= Settings Size' + SVMX_Constants.AllsvmxSettingList);
    if(SVMX_Constants.AllsvmxSettingList == NULL || SVMX_Constants.AllsvmxSettingList.size() == 0)
    {
        mapEventTriggerSetting = settings.SVMX_getSettingList(lstSubModuleId);
        //create settings cache..
        SVMX_Constants.AllsvmxSettingList = mapEventTriggerSetting;
    }
    else
    {
        mapEventTriggerSetting = SVMX_Constants.AllsvmxSettingList;
    }       
    
    //getting active real time optimization provider
    String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
    System.debug('Active Provider: ' + strActiveProvider);   
     
    //Checking whether trigger is enabled
    if(Trigger.isInsert && Trigger.isBefore) 
    {
        if(mapEventTriggerSetting.containsKey('WORD022') && mapEventTriggerSetting.get('WORD022').containsKey('SET002')&& 
            mapEventTriggerSetting.get('WORD022').get('SET002') == 'True')
        {
            /** To avoid recursive trigger execution. Please don't comment/remove this if statement */
            if(WSCH_CommonUtils.isOptimizerEnabled() && !WSCH_OptimizedSchedulingService.triggerExecuted)
            {
                WSCH_OptimizedSchedulingService.triggerExecuted = false;
                //Check if RelatedTo is enabled.
                //If its true then to update technician id into related to field for Linx for SP integration.
                if(mapEventTriggerSetting.containsKey('DCON004') && mapEventTriggerSetting.get('DCON004').containsKey('SET00997') && 
                mapEventTriggerSetting.get('DCON004').get('SET00997') == 'True')
                {
                    WSCH_EventTriggerHandler.handleSFEventBeforeInsert(Trigger.new);            
                }
            }
            
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO') && !WSCH_OptimizedSchedulingService.triggerExecuted){
                WSCH_AuditLogger.debug('Invoke the WSCH_ECO_EventTriggerHandler.updateSFEventLatLong');
                WSCH_ECO_EventTriggerHandler.updateSFEventLatLong(Trigger.new);
            }   
        }
    }
    
    else if(Trigger.isInsert && Trigger.isAfter) 
    {
        if(mapEventTriggerSetting.containsKey('WORD022') && mapEventTriggerSetting.get('WORD022').containsKey('SET002')&& 
            mapEventTriggerSetting.get('WORD022').get('SET002') == 'True')
        {
            /** To avoid recursive trigger execution. Please don't comment/remove this if statement */
            if(WSCH_CommonUtils.isOptimizerEnabled() && !WSCH_OptimizedSchedulingService.triggerExecuted)
            {
                //Handling Non WO related events for Linx for Service Power.Creating,Updating SVMX Optimizer object
                WSCH_OptimizedSchedulingService.triggerExecuted = false;
                WSCH_EventTriggerHandler.handleSFEventInsert(Trigger.new);            
            }
            
            //Event udpates for ECO
            WSCH_AuditLogger.debug('Event_Trigger1 Checking isOptiMaxEcoEnabled ');
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO') && !WSCH_OptimizedSchedulingService.triggerExecuted){
                WSCH_AuditLogger.debug('Invoke the WSCH_ECO_EventTriggerHandler.handleSFECOEventInsert');
                WSCH_OptimizedSchedulingService.triggerExecuted = false;
                //WSCH_ECO_EventTriggerHandler.handleSFECOEventInsert(Trigger.new); 
                WSCH_ECO_EventTriggerHandler.handleSFECOEventInsertNew(Trigger.new); 
            }
            
        }
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore) 
    {
        if(mapEventTriggerSetting.containsKey('WORD022') && mapEventTriggerSetting.get('WORD022').containsKey('SET002')&& 
            mapEventTriggerSetting.get('WORD022').get('SET002') == 'True')
        {
            /** To avoid recursive trigger execution. Please don't comment/remove this if statement */
            if(WSCH_CommonUtils.isOptimizerEnabled() && !WSCH_OptimizedSchedulingService.triggerExecuted)
            {
                WSCH_OptimizedSchedulingService.triggerExecuted = false;
                WSCH_EventTriggerHandler.handleSFEventUpdate(Trigger.new,Trigger.old);            
            }
            
            //Event udpates for ECO
            WSCH_AuditLogger.debug('Event_Trigger1 Checking isOptiMaxEcoEnabled ');
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO') && !WSCH_OptimizedSchedulingService.triggerExecuted){
                WSCH_AuditLogger.debug('Invoke the WSCH_ECO_EventTriggerHandler.handleSFECOEventUpdate');
                WSCH_OptimizedSchedulingService.triggerExecuted = false;
                //WSCH_ECO_EventTriggerHandler.handleSFECOEventUpdate(Trigger.new,Trigger.old); 
                WSCH_ECO_EventTriggerHandler.handleSFECOEventUpdateNew(Trigger.new,Trigger.old); 
            }            
        }
    }
    
    else if(Trigger.isDelete && Trigger.isBefore) 
    {
        //system.debug('Event_Trigger1 Checking Trigger.isDelete && Trigger.isBefore : '+Trigger.isDelete + '___' + Trigger.isBefore);
        //system.debug('Event_Trigger1 Checking mapEventTriggerSetting.get(WORD022) : '+mapEventTriggerSetting.get('WORD022').get('SET002'));
        //system.debug('Event_Trigger1 Checking strActiveProvider : '+strActiveProvider);
        //system.debug('Event_Trigger1 Checking WSCH_OptimizedSchedulingService.triggerExecute : '+WSCH_OptimizedSchedulingService.triggerExecuted);
        if(mapEventTriggerSetting.containsKey('WORD022') && mapEventTriggerSetting.get('WORD022').containsKey('SET002')&& 
            mapEventTriggerSetting.get('WORD022').get('SET002') == 'True')
        {
            /** To avoid recursive trigger execution. Please don't comment/remove this if statement */
            if(WSCH_CommonUtils.isOptimizerEnabled() && !WSCH_OptimizedSchedulingService.triggerExecuted)
            {
                WSCH_OptimizedSchedulingService.triggerExecuted = false;
                WSCH_EventTriggerHandler.handleSFEventDelete(Trigger.old);            
            }
            
            //Event udpates for ECO 
            WSCH_AuditLogger.debug('Event_Trigger1 Checking isOptiMaxEcoEnabled ');
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO') && !WSCH_OptimizedSchedulingService.triggerExecuted){
                WSCH_AuditLogger.debug('Invoke the WSCH_ECO_EventTriggerHandler.handleSFECOEventDelete');
                WSCH_OptimizedSchedulingService.triggerExecuted = false;
                //WSCH_ECO_EventTriggerHandler.handleSFECOEventDelete(Trigger.old); 
                WSCH_ECO_EventTriggerHandler.handleSFECOEventDeleteNew(Trigger.old);  
            }            
        }
    }

    //Trigger code for Push Notification
    system.debug(LoggingLevel.WARN, 'In Event Trigger for Push Notification ');
    if((Trigger.isUpdate && Trigger.isAfter) || (Trigger.isInsert && Trigger.isAfter))
    {
        Boolean isNotificationEnabled = false;
        map<String, String> mapEachSetting = new map<String, String>();
        if(mapEventTriggerSetting.containsKey('MOBN001') && mapEventTriggerSetting.get('MOBN001') != null && mapEventTriggerSetting.get('MOBN001').size() > 0)
        {
            mapEachSetting = mapEventTriggerSetting.get('MOBN001');
            if(mapEachSetting !=NULL && mapEachSetting.containsKey('SET001') && mapEachSetting.get('SET001') != null)
            {
                isNotificationEnabled = Boolean.valueOf(mapEachSetting.get('SET001'));
            }                    
        }    
        else if(mapEventTriggerSetting.containsKey('IPAD018') && mapEventTriggerSetting.get('IPAD018') != null && mapEventTriggerSetting.get('IPAD018').size() > 0)
        {
            if(mapEventTriggerSetting.get('IPAD018').containsKey('SET017') && mapEventTriggerSetting.get('IPAD018').get('SET017') != null)
            {
                isNotificationEnabled = Boolean.valueOf(mapEventTriggerSetting.get('IPAD018').get('SET017'));
            }                
        }
        List<String> listOfSubModuleIds = new List<String>();
        listOfSubModuleIds.add('IPAD018');
        listOfSubModuleIds.add('MOBN001');
        mapEachSetting = new Map<String,String>();
        for(String subModuleId:listOfSubModuleIds)
        {
            if(mapEventTriggerSetting.containsKey(subModuleId))    
            {
                Map<String,String> mapOfTempSettings = mapEventTriggerSetting.get(subModuleId);
                for(String settingId:mapOfTempSettings.keyset())
                {
                    mapEachSetting.put(subModuleId+'_'+settingId,mapOfTempSettings.get(settingId));
                }
            }
        }             
        String strAlertType = '';
        if(isNotificationEnabled)
        {
            if(Trigger.isInsert)
                strAlertType = '1';
            else if(Trigger.isUpdate)
                strAlertType = '2';
            system.debug(LoggingLevel.WARN, 'isNotificationEnabled = ' + isNotificationEnabled + '; Alert Type = ' + strAlertType);
            SVMX_PushNotification notify = new SVMX_PushNotification();
            notify.routingPN(Trigger.newMap, 'Event', strAlertType, mapEachSetting);
        }
        else
        {
            system.debug(LoggingLevel.WARN, 'Enable Push Notification Setting MOBN001_SET001 is ' + isNotificationEnabled);
        }
    }
    
    if(Trigger.isBefore && ! Trigger.isDelete)
    {
        for(Integer i =0; i<Trigger.new.size(); i++)
        {
                Decimal  tempDuration = 0;
                                
                If(Trigger.new[i].SVMXC__Overhead_Time_After__c == null)
                    Trigger.new[i].SVMXC__Overhead_Time_After__c = 0; 
                
                If(Trigger.new[i].SVMXC__Overhead_Time_Before__c == null)
                    Trigger.new[i].SVMXC__Overhead_Time_Before__c = 0;
                
                If(Trigger.new[i].SVMXC__Break_Time_Total__c == null)
                    Trigger.new[i].SVMXC__Break_Time_Total__c = 0;
                
                If(Trigger.new[i].SVMXC__Driving_Time_Home__c == null)
                    Trigger.new[i].SVMXC__Driving_Time_Home__c = 0;
                
                If(Trigger.new[i].SVMXC__Driving_Time__c == null)
                    Trigger.new[i].SVMXC__Driving_Time__c = 0;
                
                tempDuration = Trigger.new[i].SVMXC__Overhead_Time_After__c +
                               Trigger.new[i].SVMXC__Overhead_Time_Before__c +
                               Trigger.new[i].SVMXC__Break_Time_Total__c +
                               Trigger.new[i].SVMXC__Driving_Time_Home__c + 
                               Trigger.new[i].SVMXC__Driving_Time__c;                        
                //039794
                if(Trigger.new[i].DurationInMinutes != null)
                {
                    Trigger.new[i].SVMXC__Service_Duration__c = (Trigger.new[i].DurationInMinutes  - tempDuration) * 60;  
                }
                       
        }
    }
    
    if(!(trigger.isAfter && trigger.isDelete)){
        //This code is to handle JDM field updates on salesforce event insert/update/delete
        if(mapEventTriggerSetting.containsKey('DCON005') && mapEventTriggerSetting.get('DCON005').containsKey('SET006') && 
        mapEventTriggerSetting.get('DCON005').get('SET006') == 'Enabled')
        {
            if(isRecursiveCall)
            {
                String orderStatusValue = '';
                if(mapEventTriggerSetting.get('DCON005').containsKey('SET011') && 
                    mapEventTriggerSetting.get('DCON005').get('SET011') != '')
                    {
                        orderStatusValue = mapEventTriggerSetting.get('DCON005').get('SET011');         
                    }
                if(Trigger.isDelete)
                {
                    WSCH_DCON_EventTriggerHandler.handleSFEventOnDelete(Trigger.old,orderStatusValue);
                    isRecursiveCall = false;
                }
                else if(Trigger.isUpdate && Trigger.isBefore)
                {
                    WSCH_DCON_EventTriggerHandler.handleSFEventOnUpdate(Trigger.new, Trigger.old,orderStatusValue);
                    isRecursiveCall = false;            
                }
                else if(Trigger.isInsert && Trigger.isBefore)
                {
                    WSCH_DCON_EventTriggerHandler.handleSFEventOnInsert(Trigger.new,orderStatusValue);
                    isRecursiveCall = false;
                }
            }       
        }
    }
    //Start : BAC-4839 : SFA for ServiceMax Event
    static Map<String, String> svmxSettingListSFA002;
    static boolean isSFAEnabled=false;//BAC-4711
    public static boolean isSFAAfterUpdateExecuted=false;
    public static boolean isSFAAfterInsertExecuted=false;
    if(svmxSettingListSFA002 == null && SVMX_Constants.AllsvmxSettingList != null)
    {   
        svmxSettingListSFA002 = SVMX_Constants.AllsvmxSettingList.get('SFA002');
        if(svmxSettingListSFA002 != null){
             if(svmxSettingListSFA002.containsKey('SET001') && svmxSettingListSFA002.get('SET001') != null )
             {
                 isSFAEnabled = Boolean.valueOf(svmxSettingListSFA002.get('SET001'));
                 System.debug('isSFAEnabled: '+isSFAEnabled);
             }
        }
    }
    if(Trigger.isInsert && Trigger.isAfter && isSFAEnabled && !isSFAAfterInsertExecuted)
    {
        SFA_PlatformEventPublish sfaPlatformEvent = new SFA_PlatformEventPublish();
        sfaPlatformEvent.publishEventAfterInsert(trigger.new,'Event');
        isSFAAfterInsertExecuted = true;
    }
    if(Trigger.isUpdate && Trigger.isAfter && isSFAEnabled && !isSFAAfterUpdateExecuted)
    {
        SFA_PlatformEventPublish sfaPlatformEvent = new SFA_PlatformEventPublish();
        sfaPlatformEvent.publishEventAfterUpdate(trigger.new,trigger.old,'Event');
        isSFAAfterUpdateExecuted = true;
    }
    //End :BAC-4839 : SFA for ServiceMax Event

}