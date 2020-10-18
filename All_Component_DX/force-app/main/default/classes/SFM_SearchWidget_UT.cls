@isTest(SeeAllData=true)
Private with sharing class SFM_SearchWidget_UT
{
    static testMethod void SFM_SearchWidget_UT_Test()
    {
        /********** Record type creation *************/
        List<RecordType> ProcessRType = new List<RecordType>(); 
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        
        /********** Creation of Temp search Definition *************/
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRType[0].Id;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        insert processObj;
        
        /********** Class variable and method calling *************/
        SFM_SearchWidget WidgetObj = new SFM_SearchWidget();
        WidgetObj.getselectedSearch();
        WidgetObj.setselectedSearch(string.valueOf(processObj.Id));
        string keyWord = 'Acc';
        WidgetObj.getkeyWord();
        WidgetObj.setkeyWord(keyWord);
        WidgetObj.getSearchDefLst();
        WidgetObj.launchSearchDelivery();
    }
}