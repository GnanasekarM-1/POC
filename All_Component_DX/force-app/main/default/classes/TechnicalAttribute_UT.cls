@isTest

private class TechnicalAttribute_UT {
    static String insertTemplate(){
        
        SVMXC__SM_Attributes_Template__c template = new SVMXC__SM_Attributes_Template__c();
        template.SVMXC__SM_Active__c = true;
        template.SVMXC__SM_Attr_Type_Template__c = 'TECHNICAL';
        template.SVMXC__SM_Template_Json__c = '{}';
        template.SVMXC__SM_Title__c = 'testMethod';
       try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( template, COMM_SecurityUtils.Access.Createable ) ) {
                upsert template;
            } 
            return template.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }
    static String insertProductAttributs(String templateId){
        
        SVMXC__SM_Product_Attributes__c prodAtt  = new SVMXC__SM_Product_Attributes__c();
        prodAtt.SVMXC__SM_Attribute_Template_Id__c = templateId;
        prodAtt.SVMXC__SM_Product_Family__c = 'Apple';
       try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( prodAtt, COMM_SecurityUtils.Access.Createable ) ) {
                upsert prodAtt;
            } 
            return prodAtt.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }
    static String insertAttributeInstance(String ib){
        
        SVMXC__SM_IB_Attributes_Template_Instance__c instance = new SVMXC__SM_IB_Attributes_Template_Instance__c();
        instance.SVMXC__SM_Attr_Payload__c = '{}';
        instance.SVMXC__SM_Attr_Type__c = '';
        instance.SVMXC__SM_Installed_Product_Id__c = ib;
        instance.SVMXC__SM_Captured_On__c = Date.valueOf('2017-06-29T04:45:43.000Z');
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( instance, COMM_SecurityUtils.Access.Createable ) ) {
                upsert instance;
            } 
            return instance.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }
    static String insertHistory(String ib, String instance){
        
        SVMXC__SM_IB_Attributes_History__c history = new SVMXC__SM_IB_Attributes_History__c();
        history.SVMXC__SM_Attr_Payload__c = '{}';
        history.SVMXC__SM_Attr_Type__c = '';
        history.SVMXC__SM_Installed_Product_Id__c = ib;
        history.SVMXC__SM_Instance_Template_Id__c = instance;
        history.SVMXC__SM_Captured_On__c = Date.valueOf('2017-06-29T04:45:43.000Z');
        
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( history, COMM_SecurityUtils.Access.Createable ) ) {
                upsert history;
            } 
            return history.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }
    static String insertIBrecord(String product){
        
        SVMXC__Installed_Product__c iBInsert = new SVMXC__Installed_Product__c();
        iBInsert.Name = 'IB tree ';
        iBInsert.SVMXC__Product__c = product;
        
       
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( iBInsert, COMM_SecurityUtils.Access.Createable ) ) {
                upsert iBInsert;
            } 
            return iBInsert.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }
    static String insertProduct(){
        
        Product2 product = new Product2();
        product.Name = 'iPhone';
        product.Family = 'Apple';
        
       
        try{
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( product, COMM_SecurityUtils.Access.Createable ) ) {
                upsert product;
            } 
            return product.id;
        }
        catch(Exception ex){
            return 'Error msg';
        }

    }

     static testMethod void testAttributesInstance(){
        String product = insertProduct();      
        String ib = insertIBrecord(product);
        String instance = insertAttributeInstance(ib);
        String history = insertHistory(ib, instance);
        String template =insertTemplate();
        SVMXC.TechnicalAttribute.JsrGetAttributesTemplateInstanceForIB(ib);

        String  request = '{\"isTemplateFound\":true,\"totalHistoryRecords\":2,\"lastHistoryId\":\"\",\"attributesTemplateInstance\":{\"sfdcId\":\"'+instance+'\",\"attributesPayload\":\"{}\",\"installedProductId\":\"'+ib+'\",\"templateId\":\"'+template+'\",\"capturedOn\":\"2017-06-29T04:45:43.000Z\",\"isNew\":true,\"lmd\":\"2017-06-29T04:45:43.000Z\"}}';
        SVMXC.TechnicalAttribute.JsrSaveTechnicalAttributeDetails(request);
          
    }
    static testMethod void testProductAttributes(){
        String template =insertTemplate();
        String prodAtt = insertProductAttributs(template);
        String product = insertProduct(); 
        String ib = insertIBrecord(product);
        SVMXC.TechnicalAttribute.JsrGetAttributesTemplateInstanceForIB(ib);
    }
    static testMethod void TechnicalAttribute_Test() {
        SVMXC__SM_IB_Attributes_Template_Instance__c instanceObject = new SVMXC__SM_IB_Attributes_Template_Instance__c(SVMXC__SM_Attr_Payload__c = '{}',SVMXC__SM_Attr_Type__c = 'TECHNICAL');
          insert instanceObject;
          instanceObject = [SELECT SVMXC__SM_Attr_Payload__c,SVMXC__SM_Installed_Product_Id__c FROM SVMXC__SM_IB_Attributes_Template_Instance__c WHERE Id =:instanceObject.Id];
           SVMXC.TechnicalAttribute.JsrGetAttributesTemplateInstanceForIB(instanceObject.Id);
           SVMXC.TechnicalAttribute.JsrGetMetadata('');
        
        try{
            SVMXC.TechnicalAttribute.JsrGetAllAttributesforIB('');
        } catch(exception e){}
        try{
            SVMXC.TechnicalAttribute.JsrGetInstalledProductforTechnicalAttribute('');
        } catch(exception e){}
        try{
            SVMXC.TechnicalAttribute.JsrGetAllProductFilter('');
        } catch(exception e){}
        try{
            SVMXC.TechnicalAttribute.JsrGetAllProductOperator('');
        } catch(exception e){}
        try{
            SVMXC.TechnicalAttribute.JsrGetAllAdditionalFilter('');
        } catch(exception e){}
        try{
            SVMXC.TechnicalAttribute.JsrGetPossibleFirstColumns('');
        } catch(exception e){}
        try{
            SVMXC.TechnicalAttribute.JsrGetIBDetails('');
        } catch(exception e){}
        try{
            SVMXC.TechnicalAttribute.JsrGetAllHistoryGroupByRecord('');
        } catch(exception e){}
        try{
            SVMXC.TechnicalAttribute.JsrGetAllHistoryGroupByAttribute('');
        } catch(exception e){}
        TechnicalAttribute obj = new TechnicalAttribute();
    }
}