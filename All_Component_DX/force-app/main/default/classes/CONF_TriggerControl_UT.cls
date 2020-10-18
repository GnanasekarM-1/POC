@isTest
public class CONF_TriggerControl_UT{
    static testMethod void getData(){ 
      CONF_TriggerControl triggerControl = new CONF_TriggerControl();
        CONF_TriggerControl.JsrGetTRCProcessList('');
        string jsonStr = '{"lstWrapClass":[[{"isEnabled":false,"objectLabel":"Case","objectName":"Case","selectedType":null,"selectedUsers":null,"typeOptionsList":[{"name":"Global","id":"0"},{"name":"User","id":"1"},{"name":"Profile","id":"2"}]}]]}';
      CONF_TriggerControl.JsrSaveTRCProcessList(jsonStr);
        CONF_TriggerControl.JsrGetTRCProcessList('');
        CONF_TriggerControl.isTriggerEnabled('Case',userInfo.getUserId(),userInfo.getProfileId());
    }
    static testMethod void getDataforActiveUser(){ // Added for BAC-5307
    Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String uniqueName='uniqueNameSVMXUser'; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test.org', 
                         Username = uniqueName + '@test.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'spati', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
    SVMXC__SM_ServiceMax_Trigger_Control__c customSettingVar = new SVMXC__SM_ServiceMax_Trigger_Control__c();
    customSettingVar.SVMXC__SM_Is_Enabled__c = true;
    customSettingVar.Name = 'Case';
    customSettingVar.SVMXC__SM_Object_Name__c = 'Case';
    customSettingVar.SVMXC__SM_Type__c = 'Users';
    customSettingVar.SVMXC__SM_Value__c = String.valueOf(uu.id);
    
    insert customSettingVar;
    
    SVMXC__SM_ServiceMax_Trigger_Control__c customSettingVar1 = new SVMXC__SM_ServiceMax_Trigger_Control__c();
    customSettingVar1.SVMXC__SM_Is_Enabled__c = true;
    customSettingVar1.Name = 'SVMXC__Installed_Product__c';
    customSettingVar1.SVMXC__SM_Object_Name__c = 'SVMXC__Installed_Product__c';
    customSettingVar1.SVMXC__SM_Type__c = 'Salesforce Profile';
    customSettingVar1.SVMXC__SM_Value__c = String.valueOf(pf.id);
    
    insert customSettingVar1;
    
      CONF_TriggerControl triggerControl = new CONF_TriggerControl();
        CONF_TriggerControl.JsrGetTRCProcessList('');
        string jsonStr = '{"lstWrapClass":[[{"isEnabled":false,"objectLabel":"Case","objectName":"Case","selectedType":null,"selectedUsers":null,"typeOptionsList":[{"name":"Global","id":"0"},{"name":"User","id":"1"},{"name":"Profile","id":"2"}]}]]}';
      CONF_TriggerControl.JsrSaveTRCProcessList(jsonStr);
        CONF_TriggerControl.JsrGetTRCProcessList('');
        
        userRequest userwrapper = new userRequest();
        userwrapper.value = 'test';
        String jsonRequest = JSON.Serialize(userwrapper);
        CONF_TriggerControl.JsrGetUserRecords(jsonRequest);
        
        CONF_TriggerControl.isTriggerEnabled('Case',userInfo.getUserId(),userInfo.getProfileId());
    }
    public class userRequest{
        String value;
    }
}