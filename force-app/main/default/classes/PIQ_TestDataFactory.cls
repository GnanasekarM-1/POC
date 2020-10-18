@isTest
public class PIQ_TestDataFactory {
    public static void createAccountsContacts(Integer numAccts, Integer numContactsPerAcct) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        
        List<Contact> cons = new List<Contact>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];            
            // For each account just inserted, add contacts
            for (Integer k=numContactsPerAcct*j;k<numContactsPerAcct*(j+1);k++) {
                cons.add(new Contact(firstname='Test'+k,
                                     lastname='Test'+k,
                                     AccountId=acct.Id));
            }
        }
        // Insert all contacts for all accounts
        insert cons;
    }
    
    public static list<Product2> createProducts(Integer numProducts) {
        list<Product2> lstProd = new list<Product2>();
        for(Integer i=0;i<numProducts;i++) {
            Product2 pro = new Product2(Name='Product' + i, Family='Family', ProductCode='ProductCode'+i);
            lstProd.add(pro);
        }
        insert lstProd;
        return lstProd;
    }
    
    
    public static void createInstalledProducts(list<Product2> lstProducts) {
        list<SVMXC__Installed_Product__c> lstIPs = new list<SVMXC__Installed_Product__c>();
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        for(Integer i = 0 ; i < lstProducts.size(); i++) {
            Product2 objProduct = lstProducts[i];
            SVMXC__Installed_Product__c inst = new SVMXC__Installed_Product__c(Name='Test IB ' + i , SVMXC__Company__c = accRecord.Id, SVMXC__Product__c=objProduct.Id,SVMXC__Date_Installed__c=date.today());
            lstIPs.add(inst);
        }
        insert lstIPs;
    }
    
    public static void createPicklistDefinition(Integer numberOfRecords){
        List<SVMXC__SM_TA_Picklist_Definition__c > picklistRecords = new List<SVMXC__SM_TA_Picklist_Definition__c> ();
        String values = '{"values":["On","Off"],"setDefaultValue":false}';
        for(Integer i=0; i<numberOfRecords; i++){
            SVMXC__SM_TA_Picklist_Definition__c picklistRecord = new SVMXC__SM_TA_Picklist_Definition__c(SVMXC__SM_Name__c='picklist'+i);
            picklistRecord.SVMXC__SM_Values__c = values;
            picklistRecords.add(picklistRecord);
        }
        insert picklistRecords;
    }
    
    public static void createTemplateData(){
        SVMXC__SM_TA_Picklist_Definition__c picklistRecord = [SELECT Id FROM SVMXC__SM_TA_Picklist_Definition__c LIMIT 1];
        Product2 productRecord = [SELECT Id FROM Product2 LIMIT 1];
        String templateRequestData ='{"profiles":[],"technicalAttributesTemplate":{"templateTitle":"testData_template1","templateDescription":"testData_template1","templateApplicationCriteria":[{"productId":"PRODUCTID_PLACEHOLDER"}],"templateAttributesDetails":"{\\"fields\\":[{\\"title\\":\\"testData_section1\\",\\"description\\":\\"testData_section1\\",\\"technicalAttributes\\":[{\\"label\\":\\"testData_attribute1\\",\\"type\\":\\"Static\\",\\"sequence\\":0,\\"defaultValue\\":\\" dummyText\\",\\"unit\\":\\"km\\",\\"readOnly\\":\\"NO\\",\\"format\\":\\"Text\\"},{\\"label\\":\\"picklistAttribute\\",\\"type\\":\\"Static\\",\\"sequence\\":1,\\"defaultValue\\":\\"\\",\\"unit\\":\\"\\",\\"readOnly\\":\\"NO\\",\\"format\\":\\"Picklist\\",\\"picklistId\\":\\"testData_picklist1\\",\\"picklistSfId\\":\\"PICKLISTID_PLACEHOLDER\\",\\"picklistName\\":\\"testData_picklist1\\",\\"defaultDisplayValue\\":\\"\\"}]}],\\"picklist\\":{\\"testData_picklist1\\":{\\"values\\":[\\"On\\",\\"Off\\"],\\"setDefaultValue\\":false}}}","templateAttributesType":"TECHNICAL","templateIsActive":"true","templatePicklistId":"PICKLISTID_PLACEHOLDER"},"taDeletedTemplateIds":[],"isValideTAtemplate":"YES","deletedTACriteriaIds":[]}';        templateRequestData = templateRequestData.replace('PICKLISTID_PLACEHOLDER', picklistRecord.Id);
        templateRequestData = templateRequestData.replace('PRODUCTID_PLACEHOLDER', productRecord.Id);
        ProductIQSetup.JsrSaveSetupData(templateRequestData);
    }
    
    @testSetup static void setup() {
        createAccountsContacts(1,1);   
        List<Product2> productList = createProducts(1);
        createInstalledProducts(productList);
        createPicklistDefinition(1);
        createTemplateData();
        List<SVMXC__SM_Attributes_Template__c> tempAttributes = [SELECT Id, SVMXC__SM_Template_Json__c,SVMXC__SM_Picklist_Id__c,SVMXC__SM_Title__c,SVMXC__SM_Attr_Type_Template__c FROM SVMXC__SM_Attributes_Template__c LIMIT 1];
        createHistoryRecord();
        List<SVMXC__SM_IB_Attributes_Template_Instance__c> templateInstances = [SELECT Id FROM SVMXC__SM_IB_Attributes_Template_Instance__c];
    }
    
    public static void createHistoryRecord() {
        SVMXC__SM_Attributes_Template__c templateRecord = [SELECT Id, SVMXC__SM_Template_Json__c,SVMXC__SM_Picklist_Id__c,SVMXC__SM_Title__c,SVMXC__SM_Attr_Type_Template__c FROM SVMXC__SM_Attributes_Template__c LIMIT 1];
        SVMXC__SM_TA_Picklist_Definition__c picklistRecord = [SELECT Id FROM SVMXC__SM_TA_Picklist_Definition__c LIMIT 1];
        SVMXC__Installed_Product__c installedProductRecord = [SELECT Id FROM SVMXC__Installed_Product__c LIMIT 1];      
        String historyPayload = '{"totalHistoryRecords":null,"lastHistoryId":null,"lastHistoryCapturedOn":null,"isTemplateFound":true,"attributesTemplateInstance":{"templateId":"TEMPLATE_ID_PLACEHOLDER","sfdcId":null,"lmd":null,"isNew":true,"installedProductId":"INSTALLED_PRODUCT_ID_PLACEHOLDER","capturedOn":null,"attributesPayload":"{\\"picklist\\":{\\"testData_picklist1\\":{\\"values\\":[\\"On\\",\\"Off\\"],\\"setDefaultValue\\":false}},\\"fields\\":[{\\"title\\":\\"section1\\",\\"technicalAttributes\\":[{\\"unit\\":\\"km\\",\\"type\\":\\"Static\\",\\"sequence\\":\\"0\\",\\"readOnly\\":\\"NO\\",\\"picklistSfId\\":null,\\"picklistId\\":null,\\"label\\":\\"attribute1\\",\\"format\\":\\"Text\\",\\"defaultValue\\":\\" dummyText1\\"},{\\"unit\\":\\"\\",\\"type\\":\\"Static\\",\\"sequence\\":\\"1\\",\\"readOnly\\":\\"NO\\",\\"picklistSfId\\":\\"PICKLIST_ID_PLACEHOLDER\\",\\"picklistId\\":\\"testData_picklist1\\",\\"label\\":\\"picklistAttribute\\",\\"format\\":\\"Picklist\\",\\"defaultValue\\":\\"On\\"}],\\"description\\":\\"section1\\"}]}"}}';
        historyPayload = historyPayload.replace('TEMPLATE_ID_PLACEHOLDER', templateRecord.Id);
        historyPayload = historyPayload.replace('PICKLIST_ID_PLACEHOLDER', picklistRecord.Id);
        historyPayload = historyPayload.replace('INSTALLED_PRODUCT_ID_PLACEHOLDER', installedProductRecord.Id);
        TechnicalAttribute.JsrSaveTechnicalAttributeDetails(historyPayload);
        SVMXC__SM_IB_Attributes_History__c historyRecord = [SELECT Id FROM SVMXC__SM_IB_Attributes_History__c];
    }
    
    testmethod static void testGetAttrTempInstForIB(){
        SVMXC__Installed_Product__c installedProductRecord = [SELECT Id FROM SVMXC__Installed_Product__c LIMIT 1];      
        TechnicalAttribute.JsrGetAttributesTemplateInstanceForIB(installedProductRecord.Id);
    }
    
}