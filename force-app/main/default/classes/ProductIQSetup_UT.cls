@isTest (SeeAllData=true)
private class ProductIQSetup_UT {
    static testMethod void productIQImpl_Test()
    {
        ProductIQSetup setup = new ProductIQSetup();
        ProductIQSetup.JsrGetSetupMetadata('');
        
        List<SObject> lstProfileData = [Select Id, SVMXC__PROFILE_NAME__c from SVMXC__ServiceMax_Config_Data__c 
                                    where RecordType.Name = 'Configuration Profile' and SVMXC__CONFIGURATION_TYPE__c = 'Group' Order By SVMXC__PROFILE_NAME__c];
        Product2 prod = new Product2();
        prod.Name = 'Test123';
        insert prod;
        
        String proId = lstProfileData[0].Id;
        String req = '{"profiles":[{"profileName":"Default Group Profile","profileId":"'+ proId +'","mappings":null,"filters":[{"parentProfileId":"'+ proId +'","name":"Test2","isGlobal":false,"expression":{"children":[{"operator":"Test2","exprType":"root","field":null,"condition":null,"value":"","children":[{"operator":"And","exprType":"operatorroot","field":null,"condition":null,"value":""}]}]}}],"actions":[{"parentProfileId":"'+ proId +'","name":"Test1","isGlobal":false,"actionType":"fieldupdate","action":"MAP043V"}]}],"templates":[{"templateName":"ProductIQ Template Thu Feb 26 2015 12:34:40 GMT+0530 (India Standard Time)","templateId":"ProductIQ_Template_1424934280","template":{"text":"ProductIQ Template Thu Feb 26 2015 12:34:40 GMT+0530 (India Standard Time)","type":"root","product":null,"templateDetails":{"templateName":"ProductIQ Template Thu Feb 26 2015 12:34:40 GMT+0530 (India Standard Time)","templateId":"ProductIQ_Template_1424934280","subLocationText":"","locationText":"","ibText":""},"children":[{"text":"My Prod1234","type":"product","product":{"productId":"'+ prod.id  +'","productIcon":null,"productDefaultValues":"MAP043V","productConfiguration":[{"type":"Text","name":"Test"}],"product":"My Prod1234","oldProductValueMap":"MAP043V","newProductValueMap":"MAP043V"},"templateDetails":null}]},"sfdcId":"a1x70000005ojL6AAI","mappings":null}],"delTemplateIds":[]}';
        ProductIQSetup.JsrSaveSetupData(req);
        
        SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();
        insert ib;
        
        SVMXC__Installed_Product__c ib1 = new SVMXC__Installed_Product__c();
        ib1.SVMXC__Top_Level__c = ib.Id;
        ib1.SVMXC__Parent__c = ib.Id;
        insert ib1;
        
        
        req = '{"InstalledProductId":"'+ ib.id +'"}';
        ProductIQSetup.JsrGetTemplateFromIB(req);
        
        ProductIQConfiguration.Action act = new ProductIQConfiguration.Action('','','',true,'');
        act = new ProductIQConfiguration.Action();
        
        ProductIQConfiguration.Expression exp = new ProductIQConfiguration.Expression('','',new List<ProductIQConfiguration.Expression>());
        exp = new ProductIQConfiguration.Expression('','');
        exp = new ProductIQConfiguration.Expression('','','','');
        exp = new ProductIQConfiguration.Expression();
        
        ProductIQConfiguration.Field fld = new ProductIQConfiguration.Field();
        fld.name = '';
        fld.priority = 1;
        
        ProductIQConfiguration.FieldMapping mapp = new ProductIQConfiguration.FieldMapping();
        mapp.targetField = '';
        mapp.value = '';
        
        ProductIQConfiguration.Mapping ma = new ProductIQConfiguration.Mapping();
        ma.name = '';
        ma.targetObjectName = '';
        ma.mappingType = '';
        ma.mappingFields = new List<ProductIQConfiguration.FieldMapping>();
        
        ProductIQConfiguration.Filter flt = new ProductIQConfiguration.Filter();
        flt = new ProductIQConfiguration.Filter('',true, new ProductIQConfiguration.Expression());
        
        ProductIQConfiguration.Template objTemplate = new ProductIQConfiguration.Template();
        objTemplate = new ProductIQConfiguration.Template('','');
        
        ProductIQConfiguration.TemplateHeader objHead = new ProductIQConfiguration.TemplateHeader();
        objHead = new ProductIQConfiguration.TemplateHeader('','',objTemplate );     
        
         ProductIQSetupImpl.GenerateRandomNumber(5);
        
    } 
    
    static testMethod void productIQImpl_TestJSRFunctions_EmptyRequest(){
        String pickListSaveRequest = '{"sfdcId":null,"name":"UT test case","description":"UT","picklistValues":{"values":["pass","fail"],"setDefaultValue":true}}';
        ProductIQSetup.JsrSaveTechnicalAttributePicklistDefinition(pickListSaveRequest);
        ProductIQSetup.JsrDeleteTechnicalAttributePicklistDefinition('');
        ProductIQSetup.JsrBackToSetupHome('');
        
    }  

}