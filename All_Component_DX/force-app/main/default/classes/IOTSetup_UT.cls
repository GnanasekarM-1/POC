@isTest (SeeAllData=true)
private class IOTSetup_UT {
    static testMethod void iotImpl_Test()
    {
       
        
        SVMXC__IOTConfiguration__c iotUpdate = new SVMXC__IOTConfiguration__c();
        insert iotUpdate;
        
        SVMXC__IOTConfiguration__c iotDelete = new SVMXC__IOTConfiguration__c();
        insert iotDelete;

        SVMXC__SM_IoT_Field_Mapping__c iotDeleteMap = new SVMXC__SM_IoT_Field_Mapping__c();
        iotDeleteMap.SVMXC__SM_IoT_Event_Id__c = 'creatCase';
        insert iotDeleteMap;
        
        String req = '{"events":[{"eventName":"E6","className":"C4"},' +
            '{"eventName":"E3","eventId":"' + iotUpdate.Id + '","className":"C2"}],' +
            '"deletedEvents":["' + iotDelete.Id + '"],"deletedObjectMap":["'+iotDeleteMap.Id+'"]}';
        
        IOTSetup.JsrGetSetupMetadata('');
        IOTSetup.JsrBackToSetupHome('');
        IOTSetup.JsrSave(req);
        IOTSetup.JsrDescribeObject('{"allObjects":[{"objectAPIName":"SVMXC__Service_Order__c"}]}');
    }
}