@isTest
public with sharing class PIQ_IBAttributeHistoryView_UT {

    @testSetup static void setup() {
    }

    static testMethod void PIQ_IBAttributeHistoryView_method1() {
        PIQ_IBAttributeHistoryView cls = new PIQ_IBAttributeHistoryView();
        PIQ_TestDataFactory.createAccountsContacts(1,1);   
        List<Product2> productList = PIQ_TestDataFactory.createProducts(1);
        PIQ_TestDataFactory.createInstalledProducts(productList);

        list<SVMXC__Installed_Product__c> lstIPs = [select id from SVMXC__Installed_Product__c limit 1];

        PIQ_IBAttributeHistoryView.getIBRecordId(lstIPs[0].Id, 'SVMXC__Top_Level__c');
        
        try{
            
            PIQ_IBAttributeHistoryView.getIBRecordId(lstIPs[0].Id, 'SVMXC__Invalid Field__c');
        }catch(exception ex){
            
        }
    }
    
    static testMethod void testDynamicPicklistMethod1() {
        
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'SVMXC__Service_Order__c';
        
        PIQ_IBAttributeDynamicPicklist picklist1 = new PIQ_IBAttributeDynamicPicklist(context);
        
        Test.StartTest();
        VisualEditor.DynamicPickListRows  picklistValues = picklist1.getValues();
        Test.StopTest();
       
    }
}