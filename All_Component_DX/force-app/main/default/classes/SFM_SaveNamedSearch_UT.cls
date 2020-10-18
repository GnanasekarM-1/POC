@isTest
private with sharing class SFM_SaveNamedSearch_UT 
{
    static testMethod void SFM_SaveNamedSearchUnitTest()
    { 
        List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'AND Name='Named Search'];
        
        //...................process data 1....................
        SVMXC__ServiceMax_Processes__c namedSearchHdr = new SVMXC__ServiceMax_Processes__c();
        namedSearchHdr.RecordTypeId=RtypeLst[0].Id;
        namedSearchHdr.SVMXC__IsDefault__C=true;
        namedSearchHdr.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        namedSearchHdr.SVMXC__ProcessID__c='WO Lookup Config';
        namedSearchHdr.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        System.assertEquals(namedSearchHdr!=null,true);
        
       	//...................process data 2.....................
        SVMXC__ServiceMax_Processes__c objectDetail = new SVMXC__ServiceMax_Processes__c();
        objectDetail.RecordTypeId=RtypeLst[0].Id;
        objectDetail.SVMXC__ProcessID__c='servicemax001';
        objectDetail.SVMXC__Rule_Type__c='SRCH_OBJECT';
        objectDetail.SVMXC__Module__c=namedSearchHdr.id;
        objectDetail.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        System.assertEquals(objectDetail!=null,true);
        
        //...................process data 2.....................
        SVMXC__ServiceMax_Processes__c SearchCriteria = new SVMXC__ServiceMax_Processes__c();
        SearchCriteria.RecordTypeId=RtypeLst[0].Id;
        SearchCriteria.SVMXC__ProcessID__c='servicemax001';
        SearchCriteria.SVMXC__Rule_Type__c='SRCH_CRITERIA';
        SearchCriteria.SVMXC__Module__c=namedSearchHdr.id;
        SearchCriteria.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        System.assertEquals(SearchCriteria!=null,true);
        
        
        
        //...............Config Data..................
        List<RecordType> RtypeLst1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'AND Name='Expressions'];
        //Fields
        List<SVMXC__ServiceMax_Config_Data__c> ConfigDataLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c ConfigData =new SVMXC__ServiceMax_Config_Data__c();
        ConfigData.RecordTypeId = RtypeLst1[0].id;
        ConfigData.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfigData.SVMXC__Display_Type__c = 'STRING';
        ConfigData.SVMXC__Field_Name__c = 'Name';
        ConfigData.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfigDataLst.add(ConfigData);
        
        SVMXC__ServiceMax_Config_Data__c ConfigData1 =new SVMXC__ServiceMax_Config_Data__c();
        ConfigData1.RecordTypeId = RtypeLst1[0].id;
        ConfigData1.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfigData1.SVMXC__Display_Type__c = 'REFERENCE';
        ConfigData1.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfigData1.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfigData1.SVMXC__Object_Name__c = 'Account';
        ConfigDataLst.add(ConfigData1);
        
        SVMXC__ServiceMax_Config_Data__c ConfigData2 =new SVMXC__ServiceMax_Config_Data__c();
        ConfigData2.RecordTypeId = RtypeLst1[0].id;
        ConfigData2.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfigData2.SVMXC__Display_Type__c = 'REFERENCE';
        ConfigData2.SVMXC__Field_Name__c = 'SVMXC__Contact__c';
        ConfigData2.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfigData2.SVMXC__Object_Name__c = 'Contact';
        ConfigDataLst.add(ConfigData2);
        
        //Expression
        List<SVMXC__ServiceMax_Config_Data__c> ExpressionList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c Expression =new SVMXC__ServiceMax_Config_Data__c();
        Expression.RecordTypeId = RtypeLst1[0].id;
        Expression.SVMXC__Expression_Type__c = 'LKUP_Prefilter_Criteria';
        Expression.SVMXC__Display_Type__c = 'STRING';
        Expression.SVMXC__Field_Name__c = 'Name';
        Expression.SVMXC__Operator__c = 'isnotnull';
        ExpressionList.add(Expression);
        
        SVMXC__ServiceMax_Config_Data__c Expression1 =new SVMXC__ServiceMax_Config_Data__c();
        Expression1.RecordTypeId = RtypeLst1[0].id;
        Expression1.SVMXC__Expression_Type__c = 'LKUP_Criteria';
        Expression1.SVMXC__Display_Type__c = 'STRING';
        Expression1.SVMXC__Field_Name__c = 'Name';
        Expression1.SVMXC__Operator__c = 'isnotnull';
        ExpressionList.add(Expression1);
        
        
        System.assertEquals(ConfigDataLst!=null,true);
        SFM_WrapperDef.SFM_NamedSearchInfo nameSearchInfo = new SFM_WrapperDef.SFM_NamedSearchInfo();
        SFM_WrapperDef.SFM_NamedSearchInfoDetail namedSearchDetails = new SFM_WrapperDef.SFM_NamedSearchInfoDetail();
        namedSearchDetails.objectDetails = objectDetail;
        namedSearchDetails.fields = ConfigDataLst;
        namedSearchDetails.expressionFields = ExpressionList;
        List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetailsLst = new List<SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        namedSearchDetailsLst.add(namedSearchDetails);
        System.assertEquals(namedSearchDetailsLst!=null,true); 
        
        SFM_WrapperDef.SFM_NamedSearchInfoDetail advNamedSearchDetails = new SFM_WrapperDef.SFM_NamedSearchInfoDetail();
        advNamedSearchDetails.objectDetails = SearchCriteria;
       	advNamedSearchDetails.expressionFields = ExpressionList;
       	advNamedSearchDetails.uniqueId = 'xyz';
        List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> lstAdvnamedSearchDetails = new List<SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        lstAdvnamedSearchDetails.add(advNamedSearchDetails);
        
        
        nameSearchInfo.namedSearchHdr = namedSearchHdr;
        nameSearchInfo.namedSearchDetails = namedSearchDetailsLst;
       	nameSearchInfo.advNamedSearchDetails = lstAdvnamedSearchDetails;
        List<SFM_WrapperDef.SFM_NamedSearchInfo> namedSearchLst = new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
        namedSearchLst.add(nameSearchInfo);
        
        //................Instance of class and Call methods.............
        SFM_WrapperDef.SFM_Request_NamedSearchInfo request = new SFM_WrapperDef.SFM_Request_NamedSearchInfo(namedSearchLst);
        SFM_SaveNamedSearch svNmdSrc = new SFM_SaveNamedSearch();
        svNmdSrc.saveNamedSearch(request);
        
    }
    static testMethod void SFM_SaveNamedSearchUnitTest1()
    {
        List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c'AND Name='Named Search'];
        //...................process data 1....................
        SVMXC__ServiceMax_Processes__c namedSearchHdr = new SVMXC__ServiceMax_Processes__c();
        namedSearchHdr.RecordTypeId=RtypeLst[0].Id;
        namedSearchHdr.SVMXC__IsDefault__C=true;
        namedSearchHdr.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        namedSearchHdr.SVMXC__ProcessID__c='WO Lookup Config';
        namedSearchHdr.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        insert namedSearchHdr;
        System.assertEquals(namedSearchHdr!=null,true);
        
        //...................process data 1....................
        SVMXC__ServiceMax_Processes__c forDefaultCheck = new SVMXC__ServiceMax_Processes__c();
        forDefaultCheck.RecordTypeId=RtypeLst[0].Id;
        forDefaultCheck.SVMXC__IsDefault__C=true;
        forDefaultCheck.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        forDefaultCheck.SVMXC__ProcessID__c='WO Lookup Config';
        forDefaultCheck.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        System.assertEquals(forDefaultCheck != null,true);
        insert forDefaultCheck;
        
        
        //...................process data 2.....................
        SVMXC__ServiceMax_Processes__c objectDetail = new SVMXC__ServiceMax_Processes__c();
        objectDetail.RecordTypeId=RtypeLst[0].Id;
        objectDetail.SVMXC__ProcessID__c='servicemax001';
        objectDetail.SVMXC__Rule_Type__c='SRCH_OBJECT';
        objectDetail.SVMXC__Module__c=namedSearchHdr.id;
        objectDetail.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        System.assertEquals(objectDetail!=null,true);
        
        SVMXC__ServiceMax_Processes__c searchObject = new SVMXC__ServiceMax_Processes__c();
        searchObject.RecordTypeId=RtypeLst[0].Id;
        searchObject.SVMXC__ProcessID__c='servicemax001';
        searchObject.SVMXC__Rule_Type__c='SRCH_CRITERIA';
        searchObject.SVMXC__Module__c=namedSearchHdr.id;
        searchObject.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        System.assertEquals(searchObject!=null,true);
        
        //...............Config Data..................
        List<RecordType> RtypeLst1 = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Config_Data__c'AND Name='Expressions'];
        //Fields
        List<SVMXC__ServiceMax_Config_Data__c> ConfigDataLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c ConfigData =new SVMXC__ServiceMax_Config_Data__c();
        ConfigData.RecordTypeId = RtypeLst1[0].id;
        ConfigData.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfigData.SVMXC__Display_Type__c = 'STRING';
        ConfigData.SVMXC__Field_Name__c = 'Name';
        ConfigData.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfigDataLst.add(ConfigData);
        
        SVMXC__ServiceMax_Config_Data__c ConfigData1 =new SVMXC__ServiceMax_Config_Data__c();
        ConfigData1.RecordTypeId = RtypeLst1[0].id;
        ConfigData1.SVMXC__Expression_Type__c = 'SRCH_Object_Fields';
        ConfigData1.SVMXC__Display_Type__c = 'REFERENCE';
        ConfigData1.SVMXC__Field_Name__c = 'SVMXC__Company__c';
        ConfigData1.SVMXC__Search_Object_Field_Type__c = 'SEARCH';
        ConfigData1.SVMXC__Object_Name__c = 'Account';
        ConfigDataLst.add(ConfigData1);
        
        //Expression
        List<SVMXC__ServiceMax_Config_Data__c> ExpressionList = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c Expression =new SVMXC__ServiceMax_Config_Data__c();
        Expression.RecordTypeId = RtypeLst1[0].id;
        Expression.SVMXC__Expression_Type__c = 'LKUP_Prefilter_Criteria';
        Expression.SVMXC__Display_Type__c = 'STRING';
        Expression.SVMXC__Field_Name__c = 'Name';
        Expression.SVMXC__Operator__c = 'isnotnull';
        ExpressionList.add(Expression);
        SVMXC__ServiceMax_Config_Data__c Expression1 =new SVMXC__ServiceMax_Config_Data__c();
        Expression1.RecordTypeId = RtypeLst1[0].id;
        Expression1.SVMXC__Expression_Type__c = 'LKUP_Criteria';
        Expression1.SVMXC__Display_Type__c = 'STRING';
        Expression1.SVMXC__Field_Name__c = 'Name';
        Expression1.SVMXC__Operator__c = 'isnotnull';
        ExpressionList.add(Expression1);
        
        System.assertEquals(ConfigDataLst!=null,true);
        SFM_WrapperDef.SFM_NamedSearchInfo nameSearchInfo = new SFM_WrapperDef.SFM_NamedSearchInfo();
        SFM_WrapperDef.SFM_NamedSearchInfoDetail namedSearchDetails = new SFM_WrapperDef.SFM_NamedSearchInfoDetail();
        namedSearchDetails.objectDetails = objectDetail;
        namedSearchDetails.fields = ConfigDataLst;
        namedSearchDetails.expressionFields = ExpressionList;
        List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetailsLst = new List<SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        namedSearchDetailsLst.add(namedSearchDetails);
        System.assertEquals(namedSearchDetailsLst!=null,true); 
       	SFM_WrapperDef.SFM_NamedSearchInfoDetail advNamedSearchDetails = new SFM_WrapperDef.SFM_NamedSearchInfoDetail();
        advNamedSearchDetails.objectDetails = searchObject;
       	advNamedSearchDetails.expressionFields = ExpressionList;
       	advNamedSearchDetails.uniqueId = 'abc';
        List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> lstAdvnamedSearchDetails = new List<SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        lstAdvnamedSearchDetails.add(advNamedSearchDetails);
        
        
        nameSearchInfo.namedSearchHdr = namedSearchHdr;
        nameSearchInfo.namedSearchDetails = namedSearchDetailsLst;
        nameSearchInfo.advNamedSearchDetails = lstAdvnamedSearchDetails;
        List<SFM_WrapperDef.SFM_NamedSearchInfo> namedSearchLst = new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
        namedSearchLst.add(nameSearchInfo);
        
        //................Instance of class and Call methods.............
        SFM_WrapperDef.SFM_Request_NamedSearchInfo request = new SFM_WrapperDef.SFM_Request_NamedSearchInfo(namedSearchLst);
        SFM_SaveNamedSearch svNmdSrc = new SFM_SaveNamedSearch();
        svNmdSrc.saveNamedSearch(request);
    }
    
    
    
}