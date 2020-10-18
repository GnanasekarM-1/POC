@isTest(SeeAllData=true)
private class SFM_SearchUtils_UT
{
    static testMethod void SFM_SearchUtilsTest1() 
    {
        SFM_SearchUtils SrchUtil = new SFM_SearchUtils();
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request);
        request.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        ConfigExpRTypeId = ConfigRType[0].id;
        
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        
    
    insert processObj;
        System.assert(processObj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'Account';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Module__c = processObj.Id;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        insert processObj1;
        System.assert(processObj1.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj.RecordTypeId = ConfigExpRTypeId;
        ConfObj.SVMXC__Select__c = true;
        ConfObj.SVMXC__Object_Name2__c = 'SVMXC__Installed_Product__c';
        ConfObj.SVMXC__Active__c = true;
        ConfObj.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj.SVMXC__Lookup_Field_API_Name__c = 'REFERENCE'; 
        ConfObj.SVMXC__Sort_Order__c = 'Ascending';
        insert ConfObj;
        System.assert(ConfObj.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'SVMXC__Installed_Product__c';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj1.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj1.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj1.SVMXC__Display_Type__c = 'REFERENCE';        
        ConfObj1.SVMXC__Sort_Order__c = 'Ascending';
        insert ConfObj1;
        System.assert(ConfObj1.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj2.RecordTypeId = ConfigExpRTypeId;
        ConfObj2.SVMXC__Select__c = true;
        ConfObj2.SVMXC__Object_Name2__c = 'Account';
        ConfObj2.SVMXC__Active__c = true;
        ConfObj2.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj2.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj2.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj2.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj2.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Company__r'; 
        ConfObj2.SVMXC__Sort_Order__c = 'Descending';
        insert ConfObj2;
        System.assert(ConfObj2.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'Product2';
        ConfObj3.SVMXC__Active__c = true;
        ConfObj3.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj3.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj3.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj3.SVMXC__Field_Name__c='IsActive';
        ConfObj3.SVMXC__Display_Value__c = 'RELATED OBJECT';
        ConfObj3.SVMXC__Lookup_Field_API_Name__c = 'REFERENCE'; 
        ConfObj3.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj3.SVMXC__Sort_Order__c = 'Ascending';
        insert ConfObj3;
        System.assert(ConfObj3.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj4 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj4.RecordTypeId = ConfigExpRTypeId;
        ConfObj4.SVMXC__Select__c = true;
        ConfObj4.SVMXC__Object_Name2__c = 'Product2';
        ConfObj4.SVMXC__Active__c = true;
        ConfObj4.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj4.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj4.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj4.SVMXC__Field_Name__c='IsActive';
        ConfObj4.SVMXC__Display_Value__c = 'MAIN OBJECT'; 
        ConfObj4.SVMXC__Lookup_Field_API_Name__c = null;
        ConfObj4.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj4.SVMXC__Sort_Order__c = 'Ascending';
        insert ConfObj4;
        System.assert(ConfObj4.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj5 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj5.RecordTypeId = ConfigExpRTypeId;
        ConfObj5.SVMXC__Select__c = true;
        ConfObj5.SVMXC__Object_Name2__c = 'Product2';
        ConfObj5.SVMXC__Active__c = true;
        ConfObj5.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj5.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj5.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj5.SVMXC__Field_Name__c='IsActive';
        ConfObj5.SVMXC__Display_Value__c = 'MAIN OBJECT'; 
        ConfObj5.SVMXC__Lookup_Field_API_Name__c = null;
        ConfObj5.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj5.SVMXC__Sort_Order__c = 'Descending';
        insert ConfObj5;
        System.assert(ConfObj5.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj6 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj6.RecordTypeId = ConfigExpRTypeId;
        ConfObj6.SVMXC__Select__c = true;
        ConfObj6.SVMXC__Object_Name2__c = 'Product2';
        ConfObj6.SVMXC__Active__c = true;
        ConfObj6.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj6.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj6.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj6.SVMXC__Field_Name__c='IsActive';
        ConfObj6.SVMXC__Display_Value__c = 'RELATED OBJECT';
        ConfObj6.SVMXC__Lookup_Field_API_Name__c = 'REFERENCE'; 
        ConfObj6.SVMXC__Display_Type__c = 'DATE';
        ConfObj6.SVMXC__Sort_Order__c = 'Ascending';
        insert ConfObj6;
        System.assert(ConfObj6.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj7 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj7.RecordTypeId = ConfigExpRTypeId;
        ConfObj7.SVMXC__Select__c = true;
        ConfObj7.SVMXC__Object_Name2__c = 'SVMXC__Installed_Product__c';
        ConfObj7.SVMXC__Active__c = true;
        ConfObj7.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj7.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj7.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj7.SVMXC__Display_Value__c = 'RELATED OBJECT';
        ConfObj7.SVMXC__Display_Type__c = 'REFERENCE';        
        ConfObj7.SVMXC__Sort_Order__c = 'Ascending';
        ConfObj7.SVMXC__Lookup_Field_API_Name__c = 'REFERENCE';
        insert ConfObj7;
        System.assert(ConfObj7.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj8 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj8.RecordTypeId = ConfigExpRTypeId;
        ConfObj8.SVMXC__Select__c = true;
        ConfObj8.SVMXC__Object_Name2__c = 'SVMXC__Installed_Product__c';
        ConfObj8.SVMXC__Active__c = true;
        ConfObj8.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj8.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj8.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj8.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj8.SVMXC__Display_Type__c = 'DATE';        
        ConfObj8.SVMXC__Sort_Order__c = 'Ascending';
        ConfObj8.SVMXC__Lookup_Field_API_Name__c = null;
        insert ConfObj8;
        System.assert(ConfObj8.id != null); 
        
        SVMXC__ServiceMax_Config_Data__c ConfObj9 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj9.RecordTypeId = ConfigExpRTypeId;
        ConfObj9.SVMXC__Select__c = true;
        ConfObj9.SVMXC__Object_Name2__c = 'SVMXC__Installed_Product__c';
        ConfObj9.SVMXC__Active__c = true;
        ConfObj9.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj9.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj9.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj9.SVMXC__Display_Value__c = 'RELATED OBJECT';
        ConfObj9.SVMXC__Display_Type__c = 'DATE';        
        ConfObj9.SVMXC__Sort_Order__c = 'Ascending';
        ConfObj9.SVMXC__Lookup_Field_API_Name__c = 'DATE';
        insert ConfObj9;
        System.assert(ConfObj9.id != null);
        
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Bangalore'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        SrchUtil.INTF_getSearchInfoWithData(request);       
    }
    static testMethod void SFM_SearchUtilsTest2() 
    {
        SFM_SearchUtils SrchUtil = new SFM_SearchUtils();
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request);
        request.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        ConfigExpRTypeId = ConfigRType[0].id;
        
        SVMXC__Service_Order__c WO_Obj = new SVMXC__Service_Order__c();
        WO_Obj.SVMXC__City__c = 'Bangalore';
        insert WO_Obj;
        System.assert(WO_Obj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        insert processObj;
        System.assert(processObj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Module__c = processObj.Id;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        insert processObj1;
        System.assert(processObj1.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj.RecordTypeId = ConfigExpRTypeId;
        ConfObj.SVMXC__Select__c = true;
        ConfObj.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj.SVMXC__Active__c = true;
        ConfObj.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj.SVMXC__Display_Type__c = 'STRING';
        ConfObj.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj.SVMXC__Lookup_Field_API_Name__c = ''; 
        insert ConfObj;
        System.assert(ConfObj.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj1.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj1.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj1.SVMXC__Display_Type__c = 'STRING';
        insert ConfObj1;
        System.assert(ConfObj1.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj2.RecordTypeId = ConfigExpRTypeId;
        ConfObj2.SVMXC__Select__c = true;
        ConfObj2.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj2.SVMXC__Active__c = true;
        ConfObj2.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj2.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj2.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj2.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj2.SVMXC__Display_Type__c = 'REFERENCE';
        insert ConfObj2;
        System.assert(ConfObj2.id != null);
        
        /* SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj3.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj3.SVMXC__Active__c = false;
        ConfObj3.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj3.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj3.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj3.SVMXC__Display_Value__c = 'Related Object';
        ConfObj3.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj3.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj3.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        ConfObj3.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj3; */
        
        SVMXC__ServiceMax_Config_Data__c ConfObj4 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj4.RecordTypeId = ConfigExpRTypeId;
        ConfObj4.SVMXC__Select__c = true;
        ConfObj4.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj4.SVMXC__Active__c = true;
        ConfObj4.SVMXC__Search_Object_Field_Type__c = '';
        ConfObj4.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj4.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        ConfObj4.SVMXC__Display_Value__c = '';
        ConfObj4.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        ConfObj4.SVMXC__Display_Type__c = 'PICKLIST';
        insert ConfObj4;
        System.assert(ConfObj4.id != null);
        
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'contains'));
        SrchUtil.INTF_getSearchInfoWithData(request);
        
        INTF_WebServicesDef.INTF_SFMRequest request1 = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request1);
        request1.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', ''));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '-1'));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'contains'));
        SrchUtil.INTF_getSearchInfoWithData(request1);
    }
    
    static testMethod void SFM_SearchUtilsTest3() 
    {
        SFM_SearchUtils SrchUtil = new SFM_SearchUtils();
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request);
        request.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        ConfigExpRTypeId = ConfigRType[0].id;
        
        SVMXC__Service_Order__c WO_Obj = new SVMXC__Service_Order__c();
        WO_Obj.SVMXC__City__c = 'Bangalore';
        insert WO_Obj;
        System.assert(WO_Obj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        insert processObj;
        System.assert(processObj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Module__c = processObj.Id;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj1.SVMXC__Parent_Object_Criteria__c = 'SVMXC__City__c != null';
        insert processObj1;
        System.assert(processObj1.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj.RecordTypeId = ConfigExpRTypeId;
        ConfObj.SVMXC__Select__c = true;
        ConfObj.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj.SVMXC__Active__c = true;
        ConfObj.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj.SVMXC__Display_Type__c = 'STRING';
        ConfObj.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj.SVMXC__Lookup_Field_API_Name__c = ''; 
        insert ConfObj;
        System.assert(ConfObj.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj1.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj1.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj1.SVMXC__Lookup_Field_API_Name__c = '';
        ConfObj1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj1.SVMXC__Display_Type__c = 'STRING';
        insert ConfObj1;
        System.assert(ConfObj1.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj2.RecordTypeId = ConfigExpRTypeId;
        ConfObj2.SVMXC__Select__c = true;
        ConfObj2.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj2.SVMXC__Active__c = true;
        ConfObj2.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj2.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj2.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj2.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj2.SVMXC__Display_Type__c = 'REFERENCE';
        insert ConfObj2;
        System.assert(ConfObj2.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj3.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj3.SVMXC__Active__c = false;
        ConfObj3.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj3.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj3.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj3.SVMXC__Display_Value__c = 'Related Object';
        ConfObj3.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj3.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj3.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        //ConfObj3.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj3; 
        System.assert(ConfObj3.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj4 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj4.RecordTypeId = ConfigExpRTypeId;
        ConfObj4.SVMXC__Select__c = true;
        ConfObj4.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj4.SVMXC__Active__c = true;
        ConfObj4.SVMXC__Search_Object_Field_Type__c = '';
        ConfObj4.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj4.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        ConfObj4.SVMXC__Display_Value__c = '';
        ConfObj4.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        ConfObj4.SVMXC__Display_Type__c = 'PICKLIST';
        insert ConfObj4;
        System.assert(ConfObj4.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj5 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj5.RecordTypeId = ConfigExpRTypeId;
        ConfObj5.SVMXC__Select__c = true;
        ConfObj5.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj5.SVMXC__Active__c = true;
        ConfObj5.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj5.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj5.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj5.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj5.SVMXC__Display_Type__c = 'STRING';
        ConfObj5.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj5.SVMXC__Lookup_Field_API_Name__c = '';
        ConfObj5.SVMXC__Sort_Order__c = 'Ascending';
        insert ConfObj5;
        System.assert(ConfObj5.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj6 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj6.RecordTypeId = ConfigExpRTypeId;
        ConfObj6.SVMXC__Select__c = true;
        ConfObj6.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj6.SVMXC__Active__c = true;
        ConfObj6.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj6.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj6.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj6.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj6.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj6.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj6.SVMXC__Sort_Order__c = 'Ascending';
        ConfObj6.SVMXC__Lookup_Field_API_Name__c = '';
        insert ConfObj6;
        System.assert(ConfObj6.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj7 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj7.RecordTypeId = ConfigExpRTypeId;
        ConfObj7.SVMXC__Select__c = true;
        ConfObj7.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj7.SVMXC__Active__c = true;
        ConfObj7.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj7.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj7.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj7.SVMXC__Display_Value__c = 'Related Object';
        ConfObj7.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj7.SVMXC__Display_Type__c = 'DATE';
        ConfObj7.SVMXC__Sort_Order__c = 'Descending';
        ConfObj7.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj7;
        System.assert(ConfObj7.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj8 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj8.RecordTypeId = ConfigExpRTypeId;
        ConfObj8.SVMXC__Select__c = true;
        ConfObj8.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj8.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj8.SVMXC__Active__c = false;
        ConfObj8.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj8.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj8.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj8.SVMXC__Display_Value__c = 'Related Object';
        ConfObj8.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj8.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj8.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        ConfObj8.SVMXC__Sort_Order__c = 'Descending';
        ConfObj8.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj8; 
        System.assert(ConfObj8.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj9 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj9.RecordTypeId = ConfigExpRTypeId;
        ConfObj9.SVMXC__Select__c = true;
        ConfObj9.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj9.SVMXC__Active__c = true;
        ConfObj9.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj9.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj9.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj9.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj9.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj9.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj9.SVMXC__Lookup_Field_API_Name__c = '';      
        insert ConfObj9;
        System.assert(ConfObj9.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj10 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj10.RecordTypeId = ConfigExpRTypeId;
        ConfObj10.SVMXC__Select__c = true;
        ConfObj10.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj10.SVMXC__Active__c = true;
        ConfObj10.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj10.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj10.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj10.SVMXC__Display_Value__c = 'Related Object';
        ConfObj10.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj10.SVMXC__Display_Type__c = 'DATE';
        ConfObj10.SVMXC__Sort_Order__c = 'Descending';
        ConfObj10.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj10;
        System.assert(ConfObj10.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj11 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj11.RecordTypeId = ConfigExpRTypeId;
        ConfObj11.SVMXC__Select__c = true;
        ConfObj11.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj11.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj11.SVMXC__Active__c = false;
        ConfObj11.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj11.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj11.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj11.SVMXC__Display_Value__c = 'Related Object';
        ConfObj11.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj11.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj11.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        ConfObj11.SVMXC__Sort_Order__c = 'Descending';
        ConfObj11.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj11; 
        System.assert(ConfObj11.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj12 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj12.RecordTypeId = ConfigExpRTypeId;
        ConfObj12.SVMXC__Select__c = true;
        ConfObj12.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj12.SVMXC__Active__c = true;
        ConfObj12.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj12.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj12.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj12.SVMXC__Display_Value__c = 'Related Object';
        ConfObj12.SVMXC__Display_Type__c = 'STRING';
        ConfObj12.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj12.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__City__r'; 
        insert ConfObj12;
        System.assert(ConfObj12.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj13 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj13.RecordTypeId = ConfigExpRTypeId;
        ConfObj13.SVMXC__Select__c = true;
        ConfObj13.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj13.SVMXC__Active__c = true;
        ConfObj13.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj13.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj13.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj13.SVMXC__Display_Value__c = 'Related Object';
        ConfObj13.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj13.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj13.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Company__r'; 
        insert ConfObj13;
        System.assert(ConfObj13.id != null);
        
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'contains'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request);
        
        INTF_WebServicesDef.INTF_SFMRequest request1 = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request1);
        request1.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', ''));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '-1'));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'contains'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request1);
        
        INTF_WebServicesDef.INTF_SFMRequest request2 = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request2);
        request2.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'Exact Match'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request2);
        
        
        INTF_WebServicesDef.INTF_SFMRequest request3 = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request3);
        request3.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'Starts With'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request3);

    }
    
    static testMethod void SFM_SearchUtilsTest4() 
    {
        SFM_SearchUtils SrchUtil = new SFM_SearchUtils();
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request);
        request.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        ConfigExpRTypeId = ConfigRType[0].id;
        
        SVMXC__Service_Order__c WO_Obj = new SVMXC__Service_Order__c();
        WO_Obj.SVMXC__City__c = 'Bangalore';
        insert WO_Obj;
        System.assert(WO_Obj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        insert processObj;
        System.assert(processObj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Module__c = processObj.Id;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj1.SVMXC__Parent_Object_Criteria__c = 'SVMXC__City__c != null';
        insert processObj1;
        System.assert(processObj1.id != null);        
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj1.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj1.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj1.SVMXC__Lookup_Field_API_Name__c = '';
        ConfObj1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj1.SVMXC__Display_Type__c = 'STRING';
        insert ConfObj1;
        System.assert(ConfObj1.id != null);     
               
        SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj3.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj3.SVMXC__Active__c = false;
        ConfObj3.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj3.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj3.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj3.SVMXC__Display_Value__c = 'Related Object';
        ConfObj3.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj3.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj3.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        //ConfObj3.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj3; 
        System.assert(ConfObj3.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj4 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj4.RecordTypeId = ConfigExpRTypeId;
        ConfObj4.SVMXC__Select__c = true;
        ConfObj4.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj4.SVMXC__Active__c = true;
        ConfObj4.SVMXC__Search_Object_Field_Type__c = '';
        ConfObj4.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj4.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        ConfObj4.SVMXC__Display_Value__c = '';
        ConfObj4.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        ConfObj4.SVMXC__Display_Type__c = 'PICKLIST';
        insert ConfObj4;
        System.assert(ConfObj4.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj5 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj5.RecordTypeId = ConfigExpRTypeId;
        ConfObj5.SVMXC__Select__c = true;
        ConfObj5.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj5.SVMXC__Active__c = true;
        ConfObj5.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj5.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj5.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj5.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj5.SVMXC__Display_Type__c = 'STRING';
        ConfObj5.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj5.SVMXC__Lookup_Field_API_Name__c = '';
        ConfObj5.SVMXC__Sort_Order__c = 'Ascending';
        insert ConfObj5;
        System.assert(ConfObj5.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj6 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj6.RecordTypeId = ConfigExpRTypeId;
        ConfObj6.SVMXC__Select__c = true;
        ConfObj6.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj6.SVMXC__Active__c = true;
        ConfObj6.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj6.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj6.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj6.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj6.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj6.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj6.SVMXC__Sort_Order__c = 'Ascending';
        ConfObj6.SVMXC__Lookup_Field_API_Name__c = '';
        insert ConfObj6;
        System.assert(ConfObj6.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj7 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj7.RecordTypeId = ConfigExpRTypeId;
        ConfObj7.SVMXC__Select__c = true;
        ConfObj7.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj7.SVMXC__Active__c = true;
        ConfObj7.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj7.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj7.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj7.SVMXC__Display_Value__c = 'Related Object';
        ConfObj7.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj7.SVMXC__Display_Type__c = 'DATE';
        ConfObj7.SVMXC__Sort_Order__c = 'Descending';
        ConfObj7.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj7;
        System.assert(ConfObj7.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj8 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj8.RecordTypeId = ConfigExpRTypeId;
        ConfObj8.SVMXC__Select__c = true;
        ConfObj8.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj8.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj8.SVMXC__Active__c = false;
        ConfObj8.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj8.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj8.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj8.SVMXC__Display_Value__c = 'Related Object';
        ConfObj8.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj8.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj8.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        ConfObj8.SVMXC__Sort_Order__c = 'Descending';
        ConfObj8.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj8; 
        System.assert(ConfObj8.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj9 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj9.RecordTypeId = ConfigExpRTypeId;
        ConfObj9.SVMXC__Select__c = true;
        ConfObj9.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj9.SVMXC__Active__c = true;
        ConfObj9.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj9.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj9.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj9.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj9.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj9.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj9.SVMXC__Lookup_Field_API_Name__c = '';      
        insert ConfObj9;
        System.assert(ConfObj9.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj10 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj10.RecordTypeId = ConfigExpRTypeId;
        ConfObj10.SVMXC__Select__c = true;
        ConfObj10.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj10.SVMXC__Active__c = true;
        ConfObj10.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj10.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj10.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj10.SVMXC__Display_Value__c = 'Related Object';
        ConfObj10.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj10.SVMXC__Display_Type__c = 'DATE';
        ConfObj10.SVMXC__Sort_Order__c = 'Descending';
        ConfObj10.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj10;
        System.assert(ConfObj10.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj11 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj11.RecordTypeId = ConfigExpRTypeId;
        ConfObj11.SVMXC__Select__c = true;
        ConfObj11.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj11.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj11.SVMXC__Active__c = false;
        ConfObj11.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj11.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj11.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj11.SVMXC__Display_Value__c = 'Related Object';
        ConfObj11.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj11.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj11.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        ConfObj11.SVMXC__Sort_Order__c = 'Descending';
        ConfObj11.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj11; 
        System.assert(ConfObj11.id != null);       
        
        SVMXC__ServiceMax_Config_Data__c ConfObj12 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj12.RecordTypeId = ConfigExpRTypeId;
        ConfObj12.SVMXC__Select__c = true;
        ConfObj12.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj12.SVMXC__Active__c = true;
        ConfObj12.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj12.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj12.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj12.SVMXC__Display_Value__c = 'Related Object';
        ConfObj12.SVMXC__Display_Type__c = 'STRING';
        ConfObj12.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj12.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__City__r'; 
        insert ConfObj12;
        System.assert(ConfObj12.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj13 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj13.RecordTypeId = ConfigExpRTypeId;
        ConfObj13.SVMXC__Select__c = true;
        ConfObj13.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj13.SVMXC__Active__c = true;
        ConfObj13.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj13.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj13.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj13.SVMXC__Display_Value__c = 'Related Object';
        ConfObj13.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj13.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj13.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Company__r'; 
        insert ConfObj13;
        System.assert(ConfObj13.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj.RecordTypeId = ConfigExpRTypeId;
        ConfObj.SVMXC__Select__c = true;
        ConfObj.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj.SVMXC__Active__c = true;
        ConfObj.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj.SVMXC__Display_Type__c = 'STRING';
        ConfObj.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj.SVMXC__Lookup_Field_API_Name__c = ''; 
        insert ConfObj;
        System.assert(ConfObj.id != null);
        
        
        SVMXC__ServiceMax_Config_Data__c ConfObj2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj2.RecordTypeId = ConfigExpRTypeId;
        ConfObj2.SVMXC__Select__c = true;
        ConfObj2.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj2.SVMXC__Active__c = true;
        ConfObj2.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfObj2.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj2.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj2.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj2.SVMXC__Display_Type__c = 'REFERENCE';
        insert ConfObj2;
        System.assert(ConfObj2.id != null);
        
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'contains'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request);
        
        INTF_WebServicesDef.INTF_SFMRequest request1 = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request1);
        request1.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', ''));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '-1'));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'contains'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request1);
        
        INTF_WebServicesDef.INTF_SFMRequest request2 = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request2);
        request2.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'Ends With'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request2);
        
        INTF_WebServicesDef.INTF_SFMRequest request3 = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request3);
        request3.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', ''));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request3);
        
    }
    
    /* 
    static testMethod void SFM_SearchUtilsTest5() 
    {
        SFM_SearchUtils SrchUtil = new SFM_SearchUtils();
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request);
        request.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        ConfigExpRTypeId = ConfigRType[0].id;
        
        SVMXC__Service_Order__c WO_Obj = new SVMXC__Service_Order__c();
        WO_Obj.SVMXC__City__c = 'Bangalore';
        insert WO_Obj;
        System.assert(WO_Obj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        processObj.SVMXC__Name_Field__c = 'test';
        insert processObj;
        System.assert(processObj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Module__c = processObj.Id;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj1.SVMXC__Parent_Object_Criteria__c = 'SVMXC__City__c != null';
        processObj1.SVMXC__Name_Field__c = 'test';
        insert processObj1;
        System.assert(processObj1.id != null);        
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj1.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj1.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj1.SVMXC__Lookup_Field_API_Name__c = '';
        ConfObj1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj1.SVMXC__Display_Type__c = 'STRING';
        insert ConfObj1;
        System.assert(ConfObj1.id != null);     
               
        SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj3.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj3.SVMXC__Active__c = false;
        ConfObj3.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj3.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj3.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj3.SVMXC__Display_Value__c = 'Related Object';
        ConfObj3.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj3.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj3.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        //ConfObj3.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj3; 
        System.assert(ConfObj3.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj4 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj4.RecordTypeId = ConfigExpRTypeId;
        ConfObj4.SVMXC__Select__c = true;
        ConfObj4.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj4.SVMXC__Active__c = true;
        ConfObj4.SVMXC__Search_Object_Field_Type__c = '';
        ConfObj4.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj4.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        ConfObj4.SVMXC__Display_Value__c = '';
        ConfObj4.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        ConfObj4.SVMXC__Display_Type__c = 'PICKLIST';
        insert ConfObj4;
        System.assert(ConfObj4.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj5 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj5.RecordTypeId = ConfigExpRTypeId;
        ConfObj5.SVMXC__Select__c = true;
        ConfObj5.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj5.SVMXC__Active__c = true;
        ConfObj5.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj5.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj5.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj5.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj5.SVMXC__Display_Type__c = 'STRING';
        ConfObj5.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj5.SVMXC__Lookup_Field_API_Name__c = '';
        ConfObj5.SVMXC__Sort_Order__c = 'Ascending';
        insert ConfObj5;
        System.assert(ConfObj5.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj6 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj6.RecordTypeId = ConfigExpRTypeId;
        ConfObj6.SVMXC__Select__c = true;
        ConfObj6.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj6.SVMXC__Active__c = true;
        ConfObj6.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj6.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj6.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj6.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj6.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj6.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj6.SVMXC__Sort_Order__c = 'Ascending';
        ConfObj6.SVMXC__Lookup_Field_API_Name__c = '';
        insert ConfObj6;
        System.assert(ConfObj6.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj7 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj7.RecordTypeId = ConfigExpRTypeId;
        ConfObj7.SVMXC__Select__c = true;
        ConfObj7.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj7.SVMXC__Active__c = true;
        ConfObj7.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj7.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj7.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj7.SVMXC__Display_Value__c = 'Related Object';
        ConfObj7.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj7.SVMXC__Display_Type__c = 'DATE';
        ConfObj7.SVMXC__Sort_Order__c = 'Descending';
        ConfObj7.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj7;
        System.assert(ConfObj7.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj8 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj8.RecordTypeId = ConfigExpRTypeId;
        ConfObj8.SVMXC__Select__c = true;
        ConfObj8.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj8.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj8.SVMXC__Active__c = false;
        ConfObj8.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj8.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj8.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj8.SVMXC__Display_Value__c = 'Related Object';
        ConfObj8.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj8.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj8.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        ConfObj8.SVMXC__Sort_Order__c = 'Descending';
        ConfObj8.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj8; 
        System.assert(ConfObj8.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj9 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj9.RecordTypeId = ConfigExpRTypeId;
        ConfObj9.SVMXC__Select__c = true;
        ConfObj9.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj9.SVMXC__Active__c = true;
        ConfObj9.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj9.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj9.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj9.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj9.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj9.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj9.SVMXC__Lookup_Field_API_Name__c = '';      
        insert ConfObj9;
        System.assert(ConfObj9.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj10 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj10.RecordTypeId = ConfigExpRTypeId;
        ConfObj10.SVMXC__Select__c = true;
        ConfObj10.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj10.SVMXC__Active__c = true;
        ConfObj10.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj10.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj10.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj10.SVMXC__Display_Value__c = 'Related Object';
        ConfObj10.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj10.SVMXC__Display_Type__c = 'DATE';
        ConfObj10.SVMXC__Sort_Order__c = 'Descending';
        ConfObj10.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj10;
        System.assert(ConfObj10.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj11 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj11.RecordTypeId = ConfigExpRTypeId;
        ConfObj11.SVMXC__Select__c = true;
        ConfObj11.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj11.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj11.SVMXC__Active__c = false;
        ConfObj11.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj11.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj11.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj11.SVMXC__Display_Value__c = 'Related Object';
        ConfObj11.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj11.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj11.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        ConfObj11.SVMXC__Sort_Order__c = 'Descending';
        ConfObj11.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj11; 
        System.assert(ConfObj11.id != null);
        
         
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'contains'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request);
        
        INTF_WebServicesDef.INTF_SFMRequest request1 = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request1);
        request1.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'Ends With'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request1);
        
        INTF_WebServicesDef.INTF_SFMRequest request2 = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request2);
        request2.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'Exact Match'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request2);
        
        INTF_WebServicesDef.INTF_SFMRequest request3 = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request3);
        request3.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'Starts With'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request3);       
        
        INTF_WebServicesDef.INTF_SFMRequest request4 = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request4);
        request4.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', ''));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request4);
    }
    
    static testMethod void SFM_SearchUtilsTest6() 
    {
        SFM_SearchUtils SrchUtil = new SFM_SearchUtils();
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request);
        request.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        ConfigExpRTypeId = ConfigRType[0].id;
        
        SVMXC__Service_Order__c WO_Obj = new SVMXC__Service_Order__c();
        WO_Obj.SVMXC__City__c = 'Bangalore';
        insert WO_Obj;
        System.assert(WO_Obj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        processObj.SVMXC__Name_Field__c = 'test';
        insert processObj;
        System.assert(processObj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Module__c = processObj.Id;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';    
        processObj1.SVMXC__Name_Field__c = 'test';
        insert processObj1;
        System.assert(processObj1.id != null);        
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj1.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj1.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj1.SVMXC__Lookup_Field_API_Name__c = '';
        ConfObj1.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj1.SVMXC__Display_Type__c = 'STRING';
        insert ConfObj1;
        System.assert(ConfObj1.id != null);     
               
        SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj3.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj3.SVMXC__Active__c = false;
        ConfObj3.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj3.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj3.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj3.SVMXC__Display_Value__c = 'Related Object';
        ConfObj3.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj3.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj3.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        //ConfObj3.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj3; 
        System.assert(ConfObj3.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj4 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj4.RecordTypeId = ConfigExpRTypeId;
        ConfObj4.SVMXC__Select__c = true;
        ConfObj4.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj4.SVMXC__Active__c = true;
        ConfObj4.SVMXC__Search_Object_Field_Type__c = '';
        ConfObj4.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj4.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        ConfObj4.SVMXC__Display_Value__c = '';
        ConfObj4.SVMXC__Field_Name__c = 'SVMXC__Order_Status__c';
        ConfObj4.SVMXC__Display_Type__c = 'PICKLIST';
        insert ConfObj4;
        System.assert(ConfObj4.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj5 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj5.RecordTypeId = ConfigExpRTypeId;
        ConfObj5.SVMXC__Select__c = true;
        ConfObj5.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj5.SVMXC__Active__c = true;
        ConfObj5.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj5.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj5.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj5.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj5.SVMXC__Display_Type__c = 'STRING';
        ConfObj5.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj5.SVMXC__Lookup_Field_API_Name__c = '';
        ConfObj5.SVMXC__Sort_Order__c = 'Ascending';
        insert ConfObj5;
        System.assert(ConfObj5.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj6 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj6.RecordTypeId = ConfigExpRTypeId;
        ConfObj6.SVMXC__Select__c = true;
        ConfObj6.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj6.SVMXC__Active__c = true;
        ConfObj6.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj6.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj6.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj6.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj6.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj6.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj6.SVMXC__Sort_Order__c = 'Ascending';
        ConfObj6.SVMXC__Lookup_Field_API_Name__c = '';
        insert ConfObj6;
        System.assert(ConfObj6.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj7 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj7.RecordTypeId = ConfigExpRTypeId;
        ConfObj7.SVMXC__Select__c = true;
        ConfObj7.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj7.SVMXC__Active__c = true;
        ConfObj7.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj7.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj7.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj7.SVMXC__Display_Value__c = 'Related Object';
        ConfObj7.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj7.SVMXC__Display_Type__c = 'DATE';
        ConfObj7.SVMXC__Sort_Order__c = 'Descending';
        ConfObj7.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj7;
        System.assert(ConfObj7.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj8 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj8.RecordTypeId = ConfigExpRTypeId;
        ConfObj8.SVMXC__Select__c = true;
        ConfObj8.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj8.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj8.SVMXC__Active__c = false;
        ConfObj8.SVMXC__Search_Object_Field_Type__c = 'OrderBy';
        ConfObj8.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj8.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj8.SVMXC__Display_Value__c = 'Related Object';
        ConfObj8.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj8.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj8.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        ConfObj8.SVMXC__Sort_Order__c = 'Descending';
        ConfObj8.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj8; 
        System.assert(ConfObj8.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj9 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj9.RecordTypeId = ConfigExpRTypeId;
        ConfObj9.SVMXC__Select__c = true;
        ConfObj9.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj9.SVMXC__Active__c = true;
        ConfObj9.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj9.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj9.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj9.SVMXC__Display_Value__c = 'MAIN OBJECT';
        ConfObj9.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj9.SVMXC__Field_Name__c = 'SVMXC__City__c';
        ConfObj9.SVMXC__Lookup_Field_API_Name__c = '';      
        insert ConfObj9;
        System.assert(ConfObj9.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj10 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj10.RecordTypeId = ConfigExpRTypeId;
        ConfObj10.SVMXC__Select__c = true;
        ConfObj10.SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
        ConfObj10.SVMXC__Active__c = true;
        ConfObj10.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj10.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj10.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj10.SVMXC__Display_Value__c = 'Related Object';
        ConfObj10.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfObj10.SVMXC__Display_Type__c = 'DATE';
        ConfObj10.SVMXC__Sort_Order__c = 'Descending';
        ConfObj10.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj10;
        System.assert(ConfObj10.id != null);
        
        SVMXC__ServiceMax_Config_Data__c ConfObj11 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj11.RecordTypeId = ConfigExpRTypeId;
        ConfObj11.SVMXC__Select__c = true;
        ConfObj11.SVMXC__Object_Name2__c = 'SVMXC__RMA_Shipment_Order__c';
        ConfObj11.SVMXC__Object_Name__c = 'SVMXC__Site__c';
        ConfObj11.SVMXC__Active__c = false;
        ConfObj11.SVMXC__Search_Object_Field_Type__c = 'RESULT';
        ConfObj11.SVMXC__Expression_Rule__c = processObj1.Id;
        ConfObj11.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfObj11.SVMXC__Display_Value__c = 'Related Object';
        ConfObj11.SVMXC__Field_Name__c = 'SVMXC__Destination_Location__c';
        ConfObj11.SVMXC__Display_Type__c = 'REFERENCE';
        ConfObj11.SVMXC__Field_Relationship_Name__c = 'SVMXC__Destination_Location__r';
        ConfObj11.SVMXC__Sort_Order__c = 'Descending';
        ConfObj11.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__RMA_Shipment_Order__r';
        insert ConfObj11; 
        System.assert(ConfObj11.id != null);
        
         
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'contains'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request);
        
        INTF_WebServicesDef.INTF_SFMRequest request1 = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request1);
        request1.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request1.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'Ends With'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request1);
        
        INTF_WebServicesDef.INTF_SFMRequest request2 = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request2);
        request2.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request2.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'Exact Match'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request2);
        
        INTF_WebServicesDef.INTF_SFMRequest request3 = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request3);
        request3.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request3.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', 'Starts With'));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request3);       
        
        INTF_WebServicesDef.INTF_SFMRequest request4 = new INTF_WebServicesDef.INTF_SFMRequest();
        SrchUtil.INTF_getSearchInfo(request4);
        request4.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('KeyWord', 'Ban'));
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('RecordLimit', '15'));
        request4.valueMap.add(new INTF_WebServicesDef.SVMXMap('SEARCH_OPERATOR', ''));
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request4);
    } */
    
    static testMethod void SFM_SearchUtilsTest7() 
    {
        SFM_SearchUtils SrchUtil = new SFM_SearchUtils();
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        //SrchUtil.INTF_getSearchInfo(request);
        request.valueMap = new List<INTF_WebServicesDef.SVMXMap>(); 
        
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        ConfigExpRTypeId = ConfigRType[0].id;
        
        SVMXC__Service_Order__c WO_Obj = new SVMXC__Service_Order__c();
        WO_Obj.SVMXC__City__c = 'Bangalore';
        insert WO_Obj;
        System.assert(WO_Obj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        processObj.SVMXC__Name_Field__c = 'test';
        insert processObj;
        System.assert(processObj.id != null);
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'SVMXC__Service_Order__c';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Module__c = processObj.Id;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';    
        processObj1.SVMXC__Name_Field__c = 'test';
        insert processObj1;
        System.assert(processObj1.id != null);      
         

        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('SearchProcessId', processObj.Id));
        request.valueMap.add(new INTF_WebServicesDef.SVMXMap('ObjectId', processObj1.Id));
        
        
        SrchUtil.INTF_getSearchInfoExcludeGivenIDs(request);        
    }
}