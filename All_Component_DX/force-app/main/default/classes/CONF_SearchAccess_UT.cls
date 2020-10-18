@isTest
Private with sharing class CONF_SearchAccess_UT
{
    static testMethod void CONF_SearchPermission_UT_Test()
    {
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        String SearchObjRTypeId = '';
        String SearchObjFldRTypeId = ''; 
        String PermissionRTypeId = ''; 
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = Database.query('Select Name, Id From RecordType where SobjectType=\'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRType)
        {
            if(r.Name == 'Expressions')
                ConfigExpRTypeId = r.id;
            if(r.Name == 'Wizard Access')
                PermissionRTypeId = r.id;   
        } 
    
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        insert processObj;
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'Account';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Process__c = processObj.Id;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        insert processObj1;
        
        SVMXC__ServiceMax_Processes__c processObj2 = new SVMXC__ServiceMax_Processes__c();
        processObj2.RecordTypeId = ProcessRTypeId;
        processObj2.SVMXC__Select__c = true;
        processObj2.SVMXC__Target_Object_Name__c = 'Case';
        processObj2.SVMXC__Active__c = true;
        processObj2.SVMXC__Name__C = 'Process-1';
        processObj2.SVMXC__Description__c = 'Process-1';
        processObj2.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj2.SVMXC__Process__c = processObj.Id;
        insert processObj2;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj.RecordTypeId = ConfigExpRTypeId;
        ConfObj.SVMXC__Select__c = true;
        ConfObj.SVMXC__Object_Name2__c = 'Case';
        ConfObj.SVMXC__Active__c = true;
        ConfObj.SVMXC__Dispatch_Process__c = processObj1.Id;
        insert ConfObj;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'Account';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Dispatch_Process__c = processObj1.Id;
        insert ConfObj1;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj2.RecordTypeId = ConfigExpRTypeId;
        ConfObj2.SVMXC__Select__c = true;
        ConfObj2.SVMXC__Object_Name2__c = 'Account';
        ConfObj2.SVMXC__Active__c = true;
        ConfObj2.SVMXC__Dispatch_Process__c = processObj1.Id;
        ConfObj2.SVMXC__Search_Object_Field_Type__c = 'Search';
        insert ConfObj2;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'Account';
        ConfObj3.SVMXC__Active__c = true;
        ConfObj3.SVMXC__Search_Object_Field_Type__c = 'Result';
        ConfObj3.SVMXC__Dispatch_Process__c = processObj1.Id;
        insert ConfObj3;
        
        SVMXC__ServiceMax_Config_Data__c permissionObj = new SVMXC__ServiceMax_Config_Data__c();
        permissionObj.RecordTypeId = PermissionRTypeId;
        insert permissionObj;
        //.......class instantiation and calling various methods.......
        List<SelectOption> tempOptnsList = new List<SelectOption>();
        
        
        tempOptnsList.add(new SelectOption(processObj.Id, processObj.Id));
       
        CONF_SearchAccess SearchObj =  new CONF_SearchAccess();
        SearchObj.getTAG001();
        SearchObj.getTAG002();
        SearchObj.getCurrentprofileAccess();
        SearchObj.getTag003();
        SearchObj.getTag004();
        SearchObj.getTag005();
        //SearchObj.getTag006();
        SearchObj.getTag007();
        SearchObj.getTag008();
        SearchObj.getTag009();
        SearchObj.getTag010();
        
        List<String> strIds = new List<String>();
        strIds.add(processObj.Id);
        SearchObj.availableSearchSelctd = strIds;
        SearchObj.SelectedSearchSelctd = strIds; 
        SearchObj.setCurrentprofileAccess(permissionObj);
        SearchObj.getSelectedSearchOptns();
        SearchObj.setSelectedSearchOptns(tempOptnsList);
        SearchObj.getAvailableSearchOptns();
        SearchObj.getAvailableSvmxGrpProfiles();
        SearchObj.Quicksave();
        SearchObj.SaveNClose();
        SearchObj.CancelSearch();
        SearchObj.getIsRender();
        SearchObj.setselectedProfile('');
        SearchObj.getselectedProfile();
        SearchObj.rerenderAvailableSearchDef();
        try{ SearchObj.OnAddsearch();}
        catch(exception ex)
        {}
        try { SearchObj.OnRemSearch();}
        catch(exception ex1){}
    }
}