@isTest
public with sharing class CONF_ManagePushNotifications_UT 
{
    static testMethod void testMethod1()
    {
        SVMXC__ServiceMax_Config_Data__c selectedNotification = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__SVMX_Job_Logs__c logNotification = new SVMXC__SVMX_Job_Logs__c();
        
        selectedNotification.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        selectedNotification.SVMXC__Display_Value__c = '1';
        selectedNotification.SVMXC__Internal_Value__c = 'WO Updated';
        selectedNotification.SVMXC__Description__c = 'This record is updated';
        selectedNotification.SVMXC__Parameter_Name__c = 'Immediately';
        selectedNotification.SVMXC__Profile_Name__c = 'Test Notification1';
        selectedNotification.SVMXC__Active__c = True;
        selectedNotification.SVMXC__FKey_Name_Field__c = 'SVMXC__Closed_By__c';
        selectedNotification.SVMXC__Profile__c = 'abc@servicemax.com,xyz@servicemax.com';
        selectedNotification.SVMXC__Display_Type__c = 'Push Notification';
        selectedNotification.SVMXC__Select__c = true;
        selectedNotification.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1][0].Id;
        system.debug(LoggingLevel.WARN, 'First Notification = ' + selectedNotification);
        insert selectedNotification;
         
        logNotification.SVMXC__Call_Status__c = 'SENT';
        logNotification.SVMXC__Operation__c = 'PUSH NOTIFICATION';
        logNotification.SVMXC__Log_level__c = 1;
        logNotification.SVMXC__Apex_CPU_Time__c = 1;
        logNotification.SVMXC__Message__c = selectedNotification.SVMXC__Description__c;
        logNotification.SVMXC__Log_Context__c = selectedNotification.SVMXC__Internal_Value__c;
        logNotification.SVMXC__Apex_CPU_Time__c = 1;
        logNotification.SVMXC__Event_Name__c = selectedNotification.SVMXC__Profile_Name__c;
        logNotification.SVMXC__Event_Type__c = selectedNotification.SVMXC__Object_Name__c;
        insert logNotification;
        CONF_ManagePushNotifications obj = new CONF_ManagePushNotifications();
        obj.getlstNotificationConfigs();
        //obj.getlstNotificationLogs();
        obj.SVMXEdit();
        obj.SVMXDelete();
    }
    
    static testMethod void testMethod2()
    {
        CONF_ManagePushNotifications obj = new CONF_ManagePushNotifications();
        obj.SVMXNew();
    }
    
    static testMethod void testMethod3()
    {
        CONF_ManagePushNotifications obj = new CONF_ManagePushNotifications();
        obj.SVMXEdit();
    }
    
    static testMethod void testMethod4()
    {
        CONF_ManagePushNotifications obj = new CONF_ManagePushNotifications();
        obj.BackToSetupHome();
    }
    
    static testMethod void testTagMethods()
    {
        CONF_ManagePushNotifications obj = new CONF_ManagePushNotifications();
        obj.getHLPURL();
        obj.getHLPTITLE();
        obj.getTAG001();
        obj.getTAG002();
        obj.getTAG003();
        obj.getTAG004();
        obj.getTAG005();
        obj.getTAG006();
        obj.getTAG007();
        obj.getTAG012();
        obj.getTAG013();
        obj.getTAG014();
        obj.getTAG015();
        obj.getTAG016();
        obj.getTAG017();
        obj.getTAG018();
        obj.getTAG019();
        obj.getTAG020();
        obj.getTAG021();
        obj.getTAG022();
        obj.getIsHdrMsg();
    }
    
    static testMethod void testDeleteMethod()
    {
        CONF_ManagePushNotifications obj = new CONF_ManagePushNotifications();
        obj.SVMXDelete();
    }
}