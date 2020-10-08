trigger SVMX_Event_Trigger1 on SVMXC__SVMX_Event__c (before insert,after insert, before update,after update,before delete, after delete)
{
    
    
    boolean isEventTriggerEnabledWO = true;
    public static boolean isRecursiveCall = true;
    SVMXC.COMM_Utils_ManageSettings settings = new SVMXC.COMM_Utils_ManageSettings();
    public static map<string, Map<String, String>> mapEventTriggerSetting = new map<string, Map<String, String>>();
    //Important: when submodules are added to the list, add same submodules to list in workorder trigger too
    //Added MOBN002 for BAC-4840, replaced MOBN002 with SFA002
    list<string> lstSubModuleId = new list<string>{'GLOB001','OMAX001','OMAX003','SLAT003','PREV004','IPRD009','EVER007','IPRD003','DCON002','DCON003','DCON004','WORD023','WORD012','MOBN001','IPAD018','WORD022','SORG001','DCON005','SFA002'};
    
    system.debug(loggingLevel.WARN, '=====1= Settings Size' + SVMX_Constants.AllsvmxSettingList);
    system.debug(loggingLevel.WARN, '###mapEventTriggerSetting' + mapEventTriggerSetting);
    if(SVMX_Constants.AllsvmxSettingList == NULL || SVMX_Constants.AllsvmxSettingList.size() == 0)
    {
        mapEventTriggerSetting = settings.SVMX_getSettingList(lstSubModuleId);
        
        //create settings cache..
        SVMX_Constants.AllsvmxSettingList = mapEventTriggerSetting;
        WSCH_Constants.allDMSettings = mapEventTriggerSetting;
    }
    else
    {
        mapEventTriggerSetting = SVMX_Constants.AllsvmxSettingList;
        WSCH_Constants.allDMSettings= SVMX_Constants.AllsvmxSettingList;
    }       
    
    //getting active real time optimization provider
    String strActiveProvider = WSCH_CommonUtils.getActiveRealTimeOptimizationEngine();
    System.debug('Active Provider: ' + strActiveProvider);    

     if((Trigger.isUpdate && Trigger.isAfter) || (Trigger.isInsert && Trigger.isAfter))
     {
         System.debug(LoggingLevel.WARN,'Inside push notificaiton '+trigger.newMap);
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
                notify.routingPN(Trigger.newMap, 'SVMXC__SVMX_Event__c', strAlertType, mapEachSetting);
            }
            else
            {
                system.debug(LoggingLevel.WARN, 'Enable Push Notification Setting MOBN001_SET001 is ' + isNotificationEnabled);
            }
     }
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
        if(mapEventTriggerSetting.containsKey('WORD022') && mapEventTriggerSetting.get('WORD022').containsKey('SET001')&& mapEventTriggerSetting.get('WORD022').get('SET001') == 'False')
            isEventTriggerEnabledWO = false;
            
        if(isEventTriggerEnabledWO == true)
        {
            List<String> lstWhtId = new List<String>();
            for(Integer i =0; i<Trigger.new.size(); i++)
            {
                if(Trigger.new[i].SVMXC__WhatId__c!=null)
                {
                    if(Schema.SObjectType.SVMXC__Service_Order__c.getKeyPrefix().equals(Trigger.new[i].SVMXC__WhatId__c.substring(0,3))){
                        Trigger.new[i].SVMXC__Service_Order__c = Trigger.new[i].SVMXC__WhatId__c;
                        lstWhtId.add(Trigger.new[i].SVMXC__WhatId__c);
                    }    
                    else
                        Trigger.new[i].SVMXC__Service_Order__c = null;
                }
                else
                    Trigger.new[i].SVMXC__Service_Order__c = null;
            }
            
            //Multi-assignment
            if(lstWhtId != null && lstWhtId.size() > 0)
              WSCH_ECO_EventTriggerHandler.updateSVMXEventLatLong(lstWhtId,Trigger.new);
        }
    }
    
    // Computing the Duration in minutes of SVMX Event 
    if(Trigger.isBefore && ! Trigger.isDelete)
    {
        system.debug('Enter into computing the Duration in minutes of SVMX Event');
        String startDateField;
        String endDateField;
        map<String, SObjectField> objectFieldDefinition = Schema.SObjectType.SVMXC__SVMX_Event__c.fields.getMap();
        
        for(Schema.SObjectField fieldMap: objectFieldDefinition.values())
        {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.getDescribe();
            if(fieldDescribe.getName() == 'SVMXC__StartDateTime__c')
                {
                    startDateField = fieldDescribe.getLabel();
                }
            if(fieldDescribe.getName() == 'SVMXC__EndDateTime__c')
                {
                    endDateField = fieldDescribe.getLabel();
                }   
        }
        
        for(Integer i =0; i<Trigger.new.size(); i++)
        {
            Decimal  Duration;
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
            
            if(Trigger.new[i].SVMXC__StartDateTime__c != null && Trigger.new[i].SVMXC__EndDateTime__c != null)
            {
                if((Decimal.valueOf(Trigger.new[i].SVMXC__EndDateTime__c.getTime()) > Decimal.valueOf(Trigger.new[i].SVMXC__StartDateTime__c.getTime()) && !Trigger.new[i].SVMXC__IsAllDayEvent__c) || (Decimal.valueOf(Trigger.new[i].SVMXC__EndDateTime__c.getTime()) >= Decimal.valueOf(Trigger.new[i].SVMXC__StartDateTime__c.getTime()) && Trigger.new[i].SVMXC__IsAllDayEvent__c))
                {
                    if(Trigger.new[i].SVMXC__IsAllDayEvent__c)
                    {
                       // system.debug('Duration ::'+Trigger.new[i].SVMXC__DurationInMinutes__c);
                       // Duration = Trigger.new[i].SVMXC__DurationInMinutes__c;
                        Duration = ((Trigger.new[i].SVMXC__StartDateTime__c.dateGMT().daysBetween(Trigger.new[i].SVMXC__EndDateTime__c.dateGMT()))+1)*1440;                    
                        Trigger.new[i].SVMXC__ActivityDate__c = Trigger.new[i].SVMXC__StartDateTime__c.dateGMT();
                       // DateTime endDate_T  =(Datetime) Trigger.new[i].SVMXC__ActivityDate__c;
                       // endDate_T = endDate_T.addMinutes(Integer.valueOf(Duration));
                      //  system.debug(Trigger.new[i].SVMXC__EndDateTime__c);
                       // system.debug('Trigger.new[i].endDate_T :'+endDate_T +'---'+Integer.valueOf(Duration));
                        //system.debug('trigger subject :' +Trigger.new[i]);
                       // List<String> timezoneLT = String.valueOf(Trigger.new[i].Name).split('\\@#*&&');

                       // String timeZone = timezoneLT[1];
                      //  DCX_Utils dcUtils = new DCX_Utils();

                      //  DateTime start=
                        //dcUtils.getDateTimeInTimezone(DateTime.valueof(Trigger.new[i].SVMXC__ActivityDate__c).dateGmt(), DateTime.valueof(Trigger.new[i].SVMXC__ActivityDate__c).timeGmt() , timeZone);
                       // DateTime startDate11 = DateTime.valueof(req.EventStartDateTime);
                      // DateTime end=
                     //  dcUtils.getDateTimeInTimezone(DateTime.valueof(Trigger.new[i].endDate_T).dateGmt(), DateTime.valueof(Trigger.new[i].endDate_T).timeGmt() , timeZone);
                      // DateTime startDate11 = DateTime.valueof(req.EventStartDateTime);

                     // system.debug('start +end :' +start+'++'+end);
                        Trigger.new[i].SVMXC__StartDateTime__c = Trigger.new[i].SVMXC__StartDateTime__c.dateGMT();
                        Trigger.new[i].SVMXC__EndDateTime__c = Trigger.new[i].SVMXC__EndDateTime__c.dateGMT();
                        Trigger.new[i].SVMXC__Overhead_Time_After__c = 0;
                        Trigger.new[i].SVMXC__Overhead_Time_Before__c = 0;
                        Trigger.new[i].SVMXC__Break_Time_Total__c = 0;
                        Trigger.new[i].SVMXC__Driving_Time_Home__c = 0;
                        Trigger.new[i].SVMXC__Driving_Time__c = 0;
                       // Trigger.new[i].Name = 'abcd';
                    }
                    
                    else
                    {
                        Duration = ((decimal.valueOf(Trigger.new[i].SVMXC__EndDateTime__c.getTime() ) - decimal.valueOf(Trigger.new[i].SVMXC__StartDateTime__c.getTime()))/(1000*60));
                    }
            
                    Trigger.new[i].SVMXC__ActivityDateTime__c = Trigger.new[i].SVMXC__StartDateTime__c;
                    Trigger.new[i].SVMXC__DurationInMinutes__c = Duration;
                                
                    tempDuration = Trigger.new[i].SVMXC__Overhead_Time_After__c +
                                    Trigger.new[i].SVMXC__Overhead_Time_Before__c +
                                    Trigger.new[i].SVMXC__Break_Time_Total__c +
                                    Trigger.new[i].SVMXC__Driving_Time_Home__c + 
                                    Trigger.new[i].SVMXC__Driving_Time__c;                        
            
                    Trigger.new[i].SVMXC__Service_Duration__c = (Duration - tempDuration) * 60;
                }
                else
                {
                    Trigger.new[i].addError(system.label.DCON001_TAG477);
                }
            }
            else if(Trigger.new[i].SVMXC__StartDateTime__c != null && Trigger.new[i].SVMXC__DurationInMinutes__c != null && !Trigger.new[i].SVMXC__IsAllDayEvent__c)
            {
                if(Trigger.new[i].SVMXC__DurationInMinutes__c > 0)
                {
                    Trigger.new[i].SVMXC__EndDateTime__c = Trigger.new[i].SVMXC__StartDateTime__c.addminutes(integer.valueOf(Trigger.new[i].SVMXC__DurationInMinutes__c));
                    Trigger.new[i].SVMXC__ActivityDateTime__c = Trigger.new[i].SVMXC__StartDateTime__c;
                         
                    tempDuration = Trigger.new[i].SVMXC__Overhead_Time_After__c +
                               Trigger.new[i].SVMXC__Overhead_Time_Before__c +
                               Trigger.new[i].SVMXC__Break_Time_Total__c +
                               Trigger.new[i].SVMXC__Driving_Time_Home__c + 
                               Trigger.new[i].SVMXC__Driving_Time__c;                        
                
                    Trigger.new[i].SVMXC__Service_Duration__c = (Trigger.new[i].SVMXC__DurationInMinutes__c - tempDuration) * 60;   
                }
                else
                {
                    Trigger.new[i].addError(system.label.DCON001_TAG478);
                }
            }
            else if(Trigger.new[i].SVMXC__StartDateTime__c == null && Trigger.new[i].SVMXC__EndDateTime__c == null)
            {
                Trigger.new[i].addError(system.label.DCON001_TAG476);   
            }
            else if(Trigger.new[i].SVMXC__StartDateTime__c == null)
            {
                Trigger.new[i].addError(system.label.DCON001_TAG476 + ':' + startDateField);
            }
            else if(Trigger.new[i].SVMXC__EndDateTime__c == null)
            {
                Trigger.new[i].addError(system.label.DCON001_TAG476 + ':' + endDateField);
            }
            else if(Trigger.new[i].SVMXC__DurationInMinutes__c == null)
            {
                Trigger.new[i].addError(system.label.DCON001_TAG478);
            }
        }
    }
    
    if(Trigger.isInsert && Trigger.isAfter)
    {
        //Checking whether trigger is enabled
        if(mapEventTriggerSetting.containsKey('WORD022') && mapEventTriggerSetting.get('WORD022').containsKey('SET002')&& 
            mapEventTriggerSetting.get('WORD022').get('SET002') == 'True')
        {
            /** To avoid recursive trigger execution. Please don't comment/remove this if statement */
            if(WSCH_CommonUtils.isOptimizerEnabled() && !WSCH_OptimizedSchedulingService.triggerExecuted)
            {
                //Handling Non WO related events for Linx for Service Power.Creating,Updating SVMX Optimizer object
                WSCH_EventTriggerHandler.handleSVMXEventInsert(Trigger.new);
            }
            
             //Event udpates for ECO
            WSCH_AuditLogger.debug('Event_Trigger1 Checking isOptiMaxEcoEnabled ');
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO') && !WSCH_OptimizedSchedulingService.triggerExecuted){
                WSCH_AuditLogger.debug('Invoke the WSCH_ECO_EventTriggerHandler.handleSVMXECOEventInsert');
                //WSCH_ECO_EventTriggerHandler.handleSVMXECOEventInsert(Trigger.new); 
                WSCH_ECO_EventTriggerHandler.handleSVMXECOEventInsertNew(Trigger.new); 
            }
        }
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore)
    {
        //Checking whether trigger is enabled
        if(mapEventTriggerSetting.containsKey('WORD022') && mapEventTriggerSetting.get('WORD022').containsKey('SET002')&& 
            mapEventTriggerSetting.get('WORD022').get('SET002') == 'True')
        {
            /** To avoid recursive trigger execution. Please don't comment/remove this if statement */
            if(WSCH_CommonUtils.isOptimizerEnabled() && !WSCH_OptimizedSchedulingService.triggerExecuted)
            {
                //Handling Non WO related events for Linx for Service Power.Creating,Updating SVMX Optimizer object
                WSCH_EventTriggerHandler.handleSVMXEventUpdate(Trigger.new,Trigger.old);
            }
            
            //Event udpates for ECO 
             system.debug('Event_Trigger1 Checking isOptiMaxEcoEnabled ');
             system.debug('WSCH_OptimizedSchedulingService.triggerExecuted: '+WSCH_OptimizedSchedulingService.triggerExecuted);
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO') && !WSCH_OptimizedSchedulingService.triggerExecuted){
               WSCH_AuditLogger.debug('Invoke the WSCH_ECO_EventTriggerHandler.handleSVMXECOEventUpdate');
               //WSCH_ECO_EventTriggerHandler.handleSVMXECOEventUpdate(Trigger.new, Trigger.old); 
               WSCH_ECO_EventTriggerHandler.handleSVMXECOEventUpdateNew(Trigger.new, Trigger.old); 
            }            
        }
    }
   
    else if(Trigger.isDelete && Trigger.isBefore)
    {
        //Checking whether trigger is enabled
        if(mapEventTriggerSetting.containsKey('WORD022') && mapEventTriggerSetting.get('WORD022').containsKey('SET002')&& 
            mapEventTriggerSetting.get('WORD022').get('SET002') == 'True')
        {
            /** To avoid recursive trigger execution. Please don't comment/remove this if statement */
            if(WSCH_CommonUtils.isOptimizerEnabled() && !WSCH_OptimizedSchedulingService.triggerExecuted)
            {
                //Handling Non WO related events for Linx for Service Power.Creating,Updating SVMX Optimizer object
                WSCH_EventTriggerHandler.handleSVMXEventDelete(Trigger.old);
            }
            
            system.debug('Event_Trigger1 Checking isOptiMaxEcoEnabled ');
            if(String.isNotBlank(strActiveProvider) && strActiveProvider.equals('OPTIMAXECO') && !WSCH_OptimizedSchedulingService.triggerExecuted){
                WSCH_AuditLogger.debug('Invoke the WSCH_ECO_EventTriggerHandler.handleSVMXECOEventDelete');
                //WSCH_ECO_EventTriggerHandler.handleSVMXECOEventDelete(Trigger.old); 
                WSCH_ECO_EventTriggerHandler.handleSVMXECOEventDeleteNew(Trigger.old); 
            }
        }
    }
    
    if(!(trigger.isDelete && trigger.isAfter)){
        //This code is to handle JDM field updates on salesforce event insert/update/delete
        if(mapEventTriggerSetting.containsKey('DCON005') && mapEventTriggerSetting.get('DCON005').containsKey('SET006') && 
        mapEventTriggerSetting.get('DCON005').get('SET006') == 'Enabled')
        {
            if(isRecursiveCall)
            {
                String orderStatusValue = '';
                if(mapEventTriggerSetting.get('DCON005').containsKey('SET011') && 
                    mapEventTriggerSetting.get('DCON005').get('SET011') != ''){
                        orderStatusValue = mapEventTriggerSetting.get('DCON005').get('SET011');         
                    }
                    System.debug('orderStatusValue :'+ orderStatusValue );
                if(Trigger.isDelete)
                {
                    WSCH_DCON_EventTriggerHandler.handleSMAXEventOnDelete(Trigger.old,orderStatusValue);
                    isRecursiveCall = false;
                }
                else if(Trigger.isUpdate && Trigger.isBefore)
                {
                    WSCH_DCON_EventTriggerHandler.handleSMAXEventOnUpdate(Trigger.new, Trigger.old,orderStatusValue);
                    isRecursiveCall = false;            
                }
                else if(Trigger.isInsert && Trigger.isBefore)
                {
                    WSCH_DCON_EventTriggerHandler.handleSMAXEventOnInsert(Trigger.new,orderStatusValue);
                    isRecursiveCall = false;
                }
            }       
        }
    }
    
    
    //Start : BAC-4840 : SFA for ServiceMax Event
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
        sfaPlatformEvent.publishEventAfterInsert(trigger.new,'SVMXC__SVMX_Event__c');
        isSFAAfterInsertExecuted = true;
    }
    if(Trigger.isUpdate && Trigger.isAfter && isSFAEnabled && !isSFAAfterUpdateExecuted)
    {
        SFA_PlatformEventPublish sfaPlatformEvent = new SFA_PlatformEventPublish();
        sfaPlatformEvent.publishEventAfterUpdate(trigger.new,trigger.old,'SVMXC__SVMX_Event__c');
        isSFAAfterUpdateExecuted = true;
    }
    //End :BAC-4840 : SFA for ServiceMax Event
}