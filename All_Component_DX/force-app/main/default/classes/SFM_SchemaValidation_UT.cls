@isTest(SeeAllData=true)
private class SFM_SchemaValidation_UT {

    static testMethod void SFM_SchemaValidation_UnitTest() 
    {
        // Schema validation
        SFM_WrapperDef.SFM_Request_IntegrityCheck request = new SFM_WrapperDef.SFM_Request_IntegrityCheck();
        request.processId = 'ProcessId';
        List<SFM_WrapperDef.SFM_Request_ObjectFields> lstObjFields = new List<SFM_WrapperDef.SFM_Request_ObjectFields>();
        SFM_WrapperDef.SFM_Request_ObjectFields objfld = new SFM_WrapperDef.SFM_Request_ObjectFields();
        objfld.relatedTo = 'MAPPING';
        objfld.relatedReference = 'MAP001';
        objfld.objectAPI = 'SVMXC__Service_Order__c';
        List<SFM_WrapperDef.SFM_Request_FieldProperties> fields = new List<SFM_WrapperDef.SFM_Request_FieldProperties>();
        fields.add(new SFM_WrapperDef.SFM_Request_FieldProperties('SVMXC__BatchUpdate__c', 'Picklist', 250,null, null, null));
        fields.add(new SFM_WrapperDef.SFM_Request_FieldProperties('SVMXC__Customer_Down__c', 'Checkbox', 2, null, null, null));
        fields.add(new SFM_WrapperDef.SFM_Request_FieldProperties('SVMXC__Group_Email__c', 'Email', 250, null, null, null));
        fields.add(new SFM_WrapperDef.SFM_Request_FieldProperties('SVMXC__Group_Email2__c', 'Email', 250, null, null, null));
        lstObjFields.add(objfld);
        objfld.fields = fields;
        lstObjFields.add(objfld);
        system.assert(fields.size()>0);
        system.assert(lstObjFields.size()>0);
        request.objects = lstObjFields;
        SFM_WebServicesDef.SFM_SchemaValidation_WS(request);
        
        // To get all source updates
        SFM_WrapperDef.SFM_Request request2 = new SFM_WrapperDef.SFM_Request();
        SVMXC__ServiceMax_Config_Data__c SourceUpdate = [Select SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Dispatch_Process__c, SVMXC__Display_Value__c,   SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, Name, Id, SVMXC__Preference_2__c, SVMXC__Preference_3__c From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c != null and Recordtype.Name='Field Mapping' limit 1];
        request2.stringMap.add(new SFM_WrapperDef.SFM_StringMap('PROCESSID', SourceUpdate.SVMXC__Dispatch_Process__c));
        SFM_WebServicesDef.SFM_getAllSourceUpdates_WS(request2);
        
        // To get all named serach info
        SFM_WrapperDef.SFM_Request request3 = new SFM_WrapperDef.SFM_Request();
        SVMXC__ServiceMax_Processes__c namedSearch = [SELECT Id, Name, SVMXC__Name__c,SVMXC__Source_Object_Name__c,SVMXC__Description__c ,SVMXC__ProcessID__c,SVMXC__Rule_Type__c,SVMXC__IsStandard__c,SVMXC__IsDefault__C,SVMXC__Active__c,SVMXC__Number_of_Lookup_Records__c,SVMXC__Default_Lookup_Column__c from SVMXC__ServiceMax_Processes__c where Recordtype.Name='Named Search' limit 1];
        request3.stringMap.add(new SFM_WrapperDef.SFM_StringMap('RECORDID', namedSearch.Id));
        SFM_WebServicesDef.SFM_getAllNamedSearchInfo_WS(request3);
        
    }
}