@isTest
public with sharing class CONF_PushNotifications_UT 
{
    static testMethod void testMethodEdit()
    {
        CONF_PushNotifications obj = new CONF_PushNotifications();
        SVMXC__ServiceMax_Config_Data__c selectedNotification = new SVMXC__ServiceMax_Config_Data__c();
    	
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
        selectedNotification.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1][0].Id;
        system.debug(LoggingLevel.WARN, 'First Notification = ' + selectedNotification);
    	insert selectedNotification;
    	obj.mode = 'edit';
    	System.currentPageReference().getParameters().put('SVMX_RecordId', selectedNotification.id);
    	obj = new CONF_PushNotifications();
    	obj.getListOfConfiguredNotifications();
    }
    
    static testMethod void testMethodNew()
    {
        CONF_PushNotifications obj = new CONF_PushNotifications();
        SVMXC__ServiceMax_Config_Data__c selectedNotification = new SVMXC__ServiceMax_Config_Data__c();
    	obj.mode = 'new';
    	selectedNotification.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        selectedNotification.SVMXC__Display_Value__c = '1';
        selectedNotification.SVMXC__Internal_Value__c = 'WO Created';
        selectedNotification.SVMXC__Description__c = 'This record is craeted';
        selectedNotification.SVMXC__Parameter_Name__c = 'Immediately';
        selectedNotification.SVMXC__Profile_Name__c = 'Test Notification2';
        selectedNotification.SVMXC__Active__c = True;
        selectedNotification.SVMXC__FKey_Name_Field__c = 'SVMXC__Closed_By__c';
        selectedNotification.SVMXC__Profile__c = 'abc@servicemax.com,xyz@servicemax.com';
        selectedNotification.SVMXC__Display_Type__c = 'Push Notification';
        selectedNotification.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'Mobile Configuration' Limit 1][0].Id;
        system.debug(LoggingLevel.WARN, 'First Notification = ' + selectedNotification);
    	insert selectedNotification;
    	obj = new CONF_PushNotifications();
    }
    
    static testMethod void testMethod2()
    {
        CONF_PushNotifications obj = new CONF_PushNotifications();
        obj.onSelectObject();
    }
    
    static testMethod void testMethod3()
    {
        CONF_PushNotifications obj = new CONF_PushNotifications();
        obj.onChangeFilter();
    }
    
    static testMethod void testMethod4()
    {
        CONF_PushNotifications obj = new CONF_PushNotifications();
        obj.selectRecipients();
    }
    
    static testMethod void testMethod5()
    {
        CONF_PushNotifications obj = new CONF_PushNotifications();
        obj.prepareRecipientsList('Account');
        obj.prepareListOfFilters('Account');
        obj.addFilter();
        obj.editFilter();
        obj.unSelectRecipients();
        obj.saveExpression();
        obj.HdrDeleteRow();
        obj.quickSave();
        obj.saveAndClose();
        obj.showFldLstToSelectFld();
        obj.onSelectFldInPopup();
    }
    
    static testMethod void testMethod6()
    {
        CONF_PushNotifications obj = new CONF_PushNotifications();
        obj.getTAG001();
        obj.getTAG002();
        obj.getTAG003();
        obj.getTAG004();
        obj.getTAG005();
        obj.getTAG006();
        obj.getTAG008();
        obj.getTAG008();
        obj.getTAG010();
        obj.getTAG011();
        obj.getTAG012();
        obj.getTAG013();
        obj.getTAG014();
        obj.getTAG015();
        obj.getTAG016();
        obj.getTAG017();
        obj.getTAG018();
        obj.getTAG020();
        obj.getTAG021();
        obj.getTAG022();
        obj.getTAG023();
        obj.getTAG024();
        obj.getTAG025();
        obj.getTAG027();
        obj.getTAG028();
        obj.getTAG029();
        obj.getTAG030();
        obj.getTAG045();
        obj.getTAG046();
        obj.getTAG047();
        obj.getTAG048();
        obj.getTAG049();
        obj.getTAG050();
        obj.getTAG051();
        obj.getTAG052();
        obj.getTAG053();
        obj.getTAG054();
        obj.getTAG055();
        obj.getTAG056();
        obj.getTAG057();
        obj.getTAG058();
        obj.getTAG059();
        obj.getTAG060();
    }
}