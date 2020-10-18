@isTest
public with sharing class PIQ_TechAttributeHistory_UT {
    @testSetup static void setup() {
        PIQ_TestDataFactory.createAccountsContacts(1,1);   
        List<Product2> productList = PIQ_TestDataFactory.createProducts(1);
        PIQ_TestDataFactory.createInstalledProducts(productList);
        PIQ_TestDataFactory.createPicklistDefinition(1);
        PIQ_TestDataFactory.createTemplateData();
        List<SVMXC__SM_Attributes_Template__c> tempAttributes = [SELECT Id, SVMXC__SM_Template_Json__c,SVMXC__SM_Picklist_Id__c,SVMXC__SM_Title__c,SVMXC__SM_Attr_Type_Template__c FROM SVMXC__SM_Attributes_Template__c LIMIT 1];
        PIQ_TestDataFactory.createHistoryRecord();
        List<SVMXC__SM_IB_Attributes_Template_Instance__c> templateInstances = [SELECT Id FROM SVMXC__SM_IB_Attributes_Template_Instance__c];
    }

    static testMethod void PIQ_DisplayAttributeHistory(){
      PIQ_TechAttributeHistory clsTechHistory = new PIQ_TechAttributeHistory();
      SVMXC__Installed_Product__c installedProductRecord = [SELECT Id FROM SVMXC__Installed_Product__c LIMIT 1];
      PIQ_TechAttributeHistory.getHistory(installedProductRecord.Id, null, null);
      PIQ_TechAttributeHistory.getHistory(installedProductRecord.Id, '2000-01-01', null);
      PIQ_TechAttributeHistory.getHistory(installedProductRecord.Id, '2000-01-01', '2090-01-01');
      PIQ_TechAttributeHistory.getHistory(installedProductRecord.Id, '2001-01-01', '2000-01-01');
      PIQ_TechAttributeHistory.getHistory(installedProductRecord.Id, null, '2090-01-01');
    }
}