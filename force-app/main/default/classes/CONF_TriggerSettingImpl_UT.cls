@isTest
public class CONF_TriggerSettingImpl_UT {
    
    // Method is to cover CONF_TriggerSetting , remote methods 
    // Positive Flow
    static testMethod void getObjectName(){    
        CONF_TriggerSetting triggerSet = new CONF_TriggerSetting();
        CONF_TriggerSetting.getObjectName ('{}'); 
        CONF_TriggerSetting.getObjectTrigger ('{"objectName":"Case"}'); 
        CONF_TriggerSetting.saveTriggerSetting ('{"triggersettingvalue":[{"triggername":"SVMXC_CASE_Trigger1","isenabled":true}]}');
    }
    
    static testMethod void getObjectNameWO(){    
        CONF_TriggerSetting triggerSet = new CONF_TriggerSetting();
        CONF_TriggerSetting.getObjectName ('{}'); 
        CONF_TriggerSetting.getObjectTrigger ('{"objectName":"SVMXC__Service_Order__c"}'); 
        CONF_TriggerSetting.saveTriggerSetting ('{"triggersettingvalue":[{"triggername":"SVMXC_WORD_Trigger1","isenabled":true}]}');
        
        CONF_TriggerSetting.getObjectTrigger ('{"objectName":"Test"}'); 
    }
    
    // Trigger Enable/ Disable
    static testmethod void Enable_trigger(){
        // Positive Scenario
        CONF_TriggerSetting.saveTriggerSetting ('{"triggersettingvalue":[{"triggername":"SVMXC_CASE_Trigger1","isenabled":true}]}');
        Case casex = new Case();
        insert casex;
        
        CONF_TriggerSetting.saveTriggerSetting ('{"triggersettingvalue":[{"triggername":"SVMXC_WORD_Trigger1","isenabled":false}]}');
        SVMXC__Service_Order__c objWO = new SVMXC__Service_Order__c();
        insert objWO;
    }

}