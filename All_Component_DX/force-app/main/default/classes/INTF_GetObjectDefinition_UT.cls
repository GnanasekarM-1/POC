@isTest
private with sharing class INTF_GetObjectDefinition_UT {

    static testMethod void INTF_GetObjectDefinitionTest()
    {
        Set<String> strFields = new Set<String>{'CreatedById', 'SVMXC__Symptom__c'};
        INTF_GetObjectDefinition clsObjDef = new INTF_GetObjectDefinition();
        clsObjDef.objectName = 'SVMXC__Service_Order__c';
        clsObjDef.INTF_GetObjectDefinition();
        
        clsObjDef.objectName = 'SVMXC__Service_Order__c';
        clsObjDef.INTF_GetMasterChildDefinition();
        
        clsObjDef.objectName = 'SVMXC__Service_Order__c';
        clsObjDef.INTF_GetPicklistDefinition(strFields);
        
        list<String> lstFields = new list<String>();
        lstFields.add('SVMXC__Company__c');
        lstFields.add('SVMXC__Company2__c');
        clsObjDef.getObjectFieldNames(lstFields);
        
        clsObjDef.objectFields = lstFields;
        clsObjDef.getObjectFieldNames();
        
        set<String> setObjNames = new set<String>();
        setObjNames.add('Service_Order__c');
        setObjNames.add('Booking_Window__c');
        
        Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
        allObjs = Schema.getGlobalDescribe();
        clsObjDef.INTF_ValidateProcessObjects(allObjs, setObjNames);
    } 
}