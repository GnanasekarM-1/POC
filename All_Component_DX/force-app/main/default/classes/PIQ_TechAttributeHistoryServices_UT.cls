@isTest

public with sharing class PIQ_TechAttributeHistoryServices_UT {

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

    static testMethod void getAdditionalIBforAttributes(){
        
        Test.startTest();
        
        PIQ_Wrapper.PIQ_Request request = new PIQ_Wrapper.PIQ_Request();
        PIQ_Wrapper.expression expression = new PIQ_Wrapper.expression();
        list<PIQ_Wrapper.attribute> techProductAttributes = new list<PIQ_Wrapper.attribute>();
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, PIQ_Constants.OPERATOR_GREATERTHAN, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, PIQ_Constants.OPERATOR_GREATERTHANEQUAL, 'Product0_NO'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, PIQ_Constants.OPERATOR_LESSTHAN, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, PIQ_Constants.OPERATOR_LESSTHANEQUAL, 'Product0_NO'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, PIQ_Constants.OPERATOR_CONTAINS, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, PIQ_Constants.OPERATOR_NOTCONTAINS, 'Product0_NO'));

        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_GREATERTHAN, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_GREATERTHANEQUAL, 'Product0_NO'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_LESSTHAN, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_LESSTHANEQUAL, 'Product0_NO'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_CONTAINS, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_NOTCONTAINS, 'Product0_NO'));

        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTFAMILY, PIQ_Constants.OPERATOR_EQUALTO, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTFAMILY, PIQ_Constants.OPERATOR_NOTQUALTO, 'Product0_NO'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTFAMILY, PIQ_Constants.OPERATOR_GREATERTHAN, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTFAMILY, PIQ_Constants.OPERATOR_GREATERTHANEQUAL, 'Product0_NO'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTFAMILY, PIQ_Constants.OPERATOR_LESSTHAN, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTFAMILY, PIQ_Constants.OPERATOR_LESSTHANEQUAL, 'Product0_NO'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTFAMILY, PIQ_Constants.OPERATOR_CONTAINS, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute('FIELD', PIQ_Constants.FILTER_PRODUCTFAMILY, PIQ_Constants.OPERATOR_NOTCONTAINS, 'Product0_NO'));
        expression.lstProductAttributes = techProductAttributes;

        request.operator = 'AND';
        request.expression = expression;
        
        PIQ_TechAttributeHistoryServices cls = new PIQ_TechAttributeHistoryServices();
        PIQ_Wrapper.jsrData IBs = (PIQ_Wrapper.jsrData)cls.getInstalledProductforTechnicalAttribute(request);

        request.operator = 'OR';

        PIQ_Wrapper.jsrData IB2 = (PIQ_Wrapper.jsrData)cls.getInstalledProductforTechnicalAttribute(request);

        Test.stopTest();
        
    }
    static testMethod void getIBforAttributes(){
        PIQ_Wrapper.PIQ_Request request = new PIQ_Wrapper.PIQ_Request();
        PIQ_Wrapper.expression expression = new PIQ_Wrapper.expression();
        list<PIQ_Wrapper.attribute> techProductAttributes = new list<PIQ_Wrapper.attribute>();
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, PIQ_Constants.OPERATOR_EQUALTO, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, PIQ_Constants.OPERATOR_NOTQUALTO, 'Product0_NO'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_EQUALTO, 'ProductCode0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_NOTQUALTO, 'ProductCode0_NO'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_GREATERTHAN, 'ProductCode0'));
        expression.lstProductAttributes = techProductAttributes;

        list<SVMXC__SM_IB_Technical_Attributes__c> lstTechAttrLatestValues = new list<SVMXC__SM_IB_Technical_Attributes__c>();
        request.operator = 'AND';
        request.expression = expression;
        
        PIQ_TechAttributeHistoryServices cls = new PIQ_TechAttributeHistoryServices();
        PIQ_Wrapper.jsrData IBs = (PIQ_Wrapper.jsrData)cls.getInstalledProductforTechnicalAttribute(request);
        
        if(IBs.data != NULL){
            list<SVMXC__Installed_Product__c> lstInstalledProducts = (list<SVMXC__Installed_Product__c>)IBs.data;
            for(SVMXC__Installed_Product__c objIB: lstInstalledProducts){
                lstTechAttrLatestValues.add(new SVMXC__SM_IB_Technical_Attributes__c(
                    SVMXC__SM_Installed_Product_id__c= objIB.Id,
                    SVMXC__SM_Attr_Name__c = 'Temperature',
                    SVMXC__SM_Attr_Value__c = '100'
                ));
                lstTechAttrLatestValues.add(new SVMXC__SM_IB_Technical_Attributes__c(
                    SVMXC__SM_Installed_Product_id__c= objIB.Id,
                    SVMXC__SM_Attr_Name__c = 'Fuel',
                    SVMXC__SM_Attr_Value__c = '100'
                ));
                lstTechAttrLatestValues.add(new SVMXC__SM_IB_Technical_Attributes__c(
                    SVMXC__SM_Installed_Product_id__c= objIB.Id,
                    SVMXC__SM_Attr_Name__c = 'Fuel',
                    SVMXC__SM_Attr_Value__c = '200'
                ));
            }
            insert lstTechAttrLatestValues;
        }
        
        request = new PIQ_Wrapper.PIQ_Request();
        list<PIQ_Wrapper.attribute> techAttributes = new list<PIQ_Wrapper.attribute>();
        techAttributes.add(new PIQ_Wrapper.attribute('Temperature', PIQ_Constants.OPERATOR_EQUALTO, '100'));
        techAttributes.add(new PIQ_Wrapper.attribute('ATTRIBUTE','Fuel', PIQ_Constants.OPERATOR_EQUALTO, '200'));
        expression.lstTechnicalAttributes = techAttributes;

        request.operator = 'AND';
        request.expression = expression;

        cls.getInstalledProductforTechnicalAttribute(request);

        request = new PIQ_Wrapper.PIQ_Request();
        techAttributes = new list<PIQ_Wrapper.attribute>();
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD','Temperature', PIQ_Constants.OPERATOR_NOTQUALTO, '10'));
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD', 'Fuel', PIQ_Constants.OPERATOR_LESSTHAN, '300'));
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD', 'Fuel2', PIQ_Constants.OPERATOR_LESSTHANEQUAL, '300'));
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD', 'Fuel3', PIQ_Constants.OPERATOR_CONTAINS, '0'));
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD', 'Fuel4', PIQ_Constants.OPERATOR_NOTCONTAINS, '51'));
        expression.lstTechnicalAttributes = techAttributes;

        request.operator = 'AND';
        request.expression = expression;
        system.debug(LoggingLevel.DEBUG,'****request = '+request);
        String attrQuery = PIQ_TechAttributeHistoryServicesUtils.buildAttributeQueryFilter(techAttributes);
        cls.getInstalledProductforTechnicalAttribute(request);
    }

    static testMethod void getIBforAttributes_Test2(){
        PIQ_Wrapper.PIQ_Request request = new PIQ_Wrapper.PIQ_Request();
        PIQ_Wrapper.expression expression = new PIQ_Wrapper.expression();
        list<SVMXC__SM_IB_Technical_Attributes__c> lstTechAttrLatestValues = new list<SVMXC__SM_IB_Technical_Attributes__c>();

        list<PIQ_Wrapper.attribute> techProductAttributes = new list<PIQ_Wrapper.attribute>();
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTNAME, PIQ_Constants.OPERATOR_EQUALTO, 'Product0'));
        techProductAttributes.add(new PIQ_Wrapper.attribute(PIQ_Constants.FILTER_PRODUCTLINE, PIQ_Constants.OPERATOR_EQUALTO, 'ProductCode0'));
        expression.lstProductAttributes = techProductAttributes;

        request.operator = 'AND';
        request.expression = expression;
        
        PIQ_TechAttributeHistoryServices cls = new PIQ_TechAttributeHistoryServices();
        PIQ_Wrapper.jsrData IBs = (PIQ_Wrapper.jsrData)cls.getInstalledProductforTechnicalAttribute(request);
        
        if(IBs.data != NULL){
            list<SVMXC__Installed_Product__c> lstInstalledProducts = (list<SVMXC__Installed_Product__c>)IBs.data;
            for(SVMXC__Installed_Product__c objIB: lstInstalledProducts){
                lstTechAttrLatestValues.add(new SVMXC__SM_IB_Technical_Attributes__c(
                    SVMXC__SM_Installed_Product_id__c= objIB.Id,
                    SVMXC__SM_Attr_Name__c = 'Temperature',
                    SVMXC__SM_Attr_Value__c = '100'
                ));
                lstTechAttrLatestValues.add(new SVMXC__SM_IB_Technical_Attributes__c(
                    SVMXC__SM_Installed_Product_id__c= objIB.Id,
                    SVMXC__SM_Attr_Name__c = 'Fuel',
                    SVMXC__SM_Attr_Value__c = '100'
                ));
                lstTechAttrLatestValues.add(new SVMXC__SM_IB_Technical_Attributes__c(
                    SVMXC__SM_Installed_Product_id__c= objIB.Id,
                    SVMXC__SM_Attr_Name__c = 'Fuel',
                    SVMXC__SM_Attr_Value__c = '200'
                ));
            }
            insert lstTechAttrLatestValues;
        }
        
        list<PIQ_Wrapper.attribute> techAttributes = new list<PIQ_Wrapper.attribute>();
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD','Temperature', PIQ_Constants.OPERATOR_GREATERTHAN, '10'));
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD','Fuel22', PIQ_Constants.OPERATOR_GREATERTHANEQUAL, '20'));
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD','Fuel33', PIQ_Constants.OPERATOR_EQUALTO, '20'));
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD','Fuel44', PIQ_Constants.OPERATOR_NOTQUALTO, '20'));
        techAttributes.add(new PIQ_Wrapper.attribute('FIELD','Fuel55', PIQ_Constants.OPERATOR_LESSTHAN, '1000'));
        
        PIQ_Wrapper.attribute attr1 = new PIQ_Wrapper.attribute('FIELD','Fuel2', PIQ_Constants.OPERATOR_GREATERTHANEQUAL, '40');
        attr1.type = 'Number';
        techAttributes.add(attr1);
        
        PIQ_Wrapper.attribute attr2 = new PIQ_Wrapper.attribute('FIELD','Fuel3', PIQ_Constants.OPERATOR_EQUALTO, '41');
        attr2.type = 'Number';
        techAttributes.add(attr2);
        
        PIQ_Wrapper.attribute attr3 = new PIQ_Wrapper.attribute('FIELD','Fuel4', PIQ_Constants.OPERATOR_NOTQUALTO, '42');
        attr3.type = 'Number';
        techAttributes.add(attr3);
        
        PIQ_Wrapper.attribute attr4 = new PIQ_Wrapper.attribute('FIELD','Fuel5', PIQ_Constants.OPERATOR_LESSTHAN, '1000');
        attr4.type = 'Number';
        techAttributes.add(attr4);
        
        PIQ_Wrapper.attribute attr5 = new PIQ_Wrapper.attribute('FIELD','Fuel6', PIQ_Constants.OPERATOR_LESSTHANEQUAL, '1000');
        attr5.type = 'Number';
        techAttributes.add(attr5);
        
        expression.lstTechnicalAttributes = techAttributes;

        request.operator = 'AND';
        request.expression = expression;

        test.StartTest();
        String attrQuery = PIQ_TechAttributeHistoryServicesUtils.buildAttributeQueryFilter(techAttributes);
        cls.getInstalledProductforTechnicalAttribute(request);
        test.StopTest();
    }

    static testMethod void getAttributeForIB(){
        PIQ_TechAttributeHistoryServices cls = new PIQ_TechAttributeHistoryServices();
        list<SVMXC__Installed_Product__c> lstInstalledProducts = [select id from SVMXC__Installed_Product__c limit 10];
        list<Id> lstIBId = new list<Id>();
        for(SVMXC__Installed_Product__c objIB: lstInstalledProducts){
            lstIBId.add(objIB.Id);
        }
        cls.getAllAttributesforIB(lstIBId);

        cls.getAllProductFilter();
        cls.getAllProductOperator();
        cls.getAllAdditionalFilter();
        cls.getPossibleFirstColumns();

        list<String> lstFields = new list<String>{'Name', 'SVMXC__City__c'};
        cls.getIBDetails(lstIBId, lstFields);
    }

    /*static testMethod void getHistoryGroupByAttributes(){
        
        PIQ_Wrapper.PIQ_History_Request objReq = new PIQ_Wrapper.PIQ_History_Request();
        objReq.ibIdList =ibIds;
        objReq.attributeNameList = attrNames;
        objReq.startDate =startDate;
        objReq.endDate =endDate;

        TechnicalAttributeImpl temp = new TechnicalAttributeImpl();
        Object responseObj = temp.getAllHistoryGroupByRecord(json.serialize(objReq));
    }*/

    static testMethod void getHistoryGroupByRecord(){
        
        createIBHistoryRecords();
        String ibID = [SELECT Id FROM SVMXC__Installed_Product__c ORDER BY ID LIMIT 1].Id;  

        String response = '';
        PIQ_Wrapper.PIQ_History_Request request = new PIQ_Wrapper.PIQ_History_Request();
        request.ibIdList = new List<String>{ibID};
        request.attributeNameList = new List<String>{'Temperature','Time of the day','Color'};
        request.startDate = String.valueOf(Date.today() - 40);
        request.endDate = String.valueOf(Date.today());
        system.debug('*** request = '+request);

        Test.startTest();
            response = TechnicalAttribute.JsrGetAllHistoryGroupByRecord(json.serialize(request));
        Test.stopTest();        

        system.assert(response != '');
    
    }

    static testMethod void getHistoryGroupByAttributes(){
        
        createIBHistoryRecords();
        String ibID = [SELECT Id FROM SVMXC__Installed_Product__c ORDER BY ID LIMIT 1].Id;  

        String response = '';
        PIQ_Wrapper.PIQ_History_Request request = new PIQ_Wrapper.PIQ_History_Request();
        request.ibIdList = new List<String>{ibID};
        request.attributeNameList = new List<String>{'Temperature','Time of the day','Color'};
        request.startDate = String.valueOf(Date.today() - 40);
        request.endDate = NULL; //String.valueOf(Date.today());
        system.debug('*** request = '+request);

        Test.startTest();
            response = TechnicalAttribute.JsrGetAllHistoryGroupByAttribute(json.serialize(request));
        Test.stopTest();    

        system.debug('***response '+response);
        system.assert(response != '');
        
    }

    private static void createIBHistoryRecords(){
        
        String ibID = [SELECT Id FROM SVMXC__Installed_Product__c ORDER BY ID LIMIT 1].Id;      
        String historyPayload = '{"fields":[{"title":"Initial details","description":"","technicalAttributes":[{"label":"Temperature","type":"","sequence":0,"defaultValue":"","unit":"C","readOnly":"NO","format":"Number","isMandatory":"NO","maxNumber":"","minNumber":"","message":"Recorded temperate"},{"label":"Time of the day","type":"","sequence":1,"defaultValue":"First","unit":"","readOnly":"","format":"Picklist","isMandatory":"","maxNumber":"","minNumber":"","message":"","picklistId":"TimeOftheday","picklistSfId":"a2j2I000000e4umQAA","picklistName":"Time Of the day","defaultDisplayValue":""},{"label":"Color","type":"","sequence":2,"defaultValue":"","unit":"","readOnly":"","format":"Picklist","isMandatory":"","maxNumber":"","minNumber":"","message":"","picklistId":"picklist1","picklistSfId":"a2j2I000000du2gQAA","picklistName":"picklist1","defaultDisplayValue":""}]}],"picklist":{"TimeOftheday":{"values":["Morning","Afternoon","Evening","Night","MidNight","After midnight lol","Next1","First","second","third","fourth"],"setDefaultValue":false},"picklist1":{"values":["On","Off"],"setDefaultValue":false}}}';
        
        SVMXC__SM_IB_Attributes_History__c hist1 = new SVMXC__SM_IB_Attributes_History__c(SVMXC__SM_Captured_On__c = Datetime.now() - 5, 
        SVMXC__SM_Attr_Type__c = 'TECHNICAL', SVMXC__SM_Installed_Product_Id__c = ibID, SVMXC__SM_Attr_Payload__c = historyPayload );
        insert hist1;
    }
    
    static testMethod void testFetchingTags(){
        Test.startTest();
            Object response = TechnicalAttribute.JsrGetAllTags('');
        Test.stopTest();
        system.assert(response != '');
    }
    
}