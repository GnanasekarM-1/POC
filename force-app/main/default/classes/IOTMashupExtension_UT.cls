@isTest (SeeAllData=true)
private class IOTMashupExtension_UT {
    static testMethod void JsrGetThingInfo_Test()
    {
        Product2 pro = new Product2();
        pro.Name = 'Mashup Product';
        insert pro;
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Product__c = pro.id;
        insert wo;
        
        Case ca = new Case();
        ca.SVMXC__Product__c = pro.id;
        IOTMashupExtension.JsrGetThingInfoFromWorkOrder('{"recordId":"'+ wo.Id +'"}');
        IOTMashupExtension.JsrGetThingInfoFromCase('{"recordId":"'+ ca.Id +'"}');
        IOTMashupExtension.JsrGetThingInfoFromWorkOrder('{"recordId":"ASDF"}');
        IOTMashupExtension.JsrGetThingInfoFromCase('{"recordId":"ASDF"}');
        
    }
}