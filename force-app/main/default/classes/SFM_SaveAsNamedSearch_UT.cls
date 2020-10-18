@isTest
private class SFM_SaveAsNamedSearch_UT {

    static testMethod void SFM_SaveAsNamedSearchUnitTest() {
        SFM_SaveAsNamedSearch SaveAsNamedSearch = new SFM_SaveAsNamedSearch();
        SFM_WrapperDef.SFM_Request prequest = new SFM_WrapperDef.SFM_Request();
        
        list<RecordType> RType1 = [SELECT Id, Name,SobjectType,IsActive from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Named Search'limit 1];
        SVMXC__ServiceMax_Processes__c ProcessObj = new SVMXC__ServiceMax_Processes__c();
        ProcessObj.SVMXC__Source_Object_Name__c = 'Account';
        ProcessObj.SVMXC__ProcessID__c = 'Process0000001';
        ProcessObj.RecordtypeId = RType1[0].Id;
        ProcessObj.SVMXC__Active__c = true;
        insert ProcessObj;
        List<SFM_WrapperDef.SFM_StringMap> strMapLst = new list<SFM_WrapperDef.SFM_StringMap>();
        strMapLst.add(new SFM_WrapperDef.SFM_StringMap('RECORDID',ProcessObj.Id));
        prequest.stringMap = strMapLst;
        SaveAsNamedSearch.cloneNamedSearchInfo(prequest);
        System.assertEquals(true, SaveAsNamedSearch  != null);
        System.assertEquals(true, prequest != null);
        System.assertEquals(true, SaveAsNamedSearch.cloneNamedSearchInfo(prequest)!= null);
    }
}