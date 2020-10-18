@isTest
Private with sharing class CONF_ManageSearchConfiguration_UT
{
    static testMethod void CONF_ManageSearchConfiguration_UT_Test1()
    {
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        String SearchObjRTypeId = '';
        String SearchObjFldRTypeId = ''; 
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
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = true;
        processObj1.SVMXC__Target_Object_Name__c = 'Account';
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Name__C = 'Process-111';
        processObj1.SVMXC__Description__c = 'Process-111';
        processObj1.SVMXC__Module__c = processObj.Id;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        insert processObj1;
        
        SVMXC__ServiceMax_Processes__c processObj2 = new SVMXC__ServiceMax_Processes__c();
        processObj2.RecordTypeId = ProcessRTypeId;
        processObj2.SVMXC__Select__c = true;
        processObj2.SVMXC__Target_Object_Name__c = 'Case';
        processObj2.SVMXC__Active__c = true;
        processObj2.SVMXC__Name__C = 'Process-1';
        processObj2.SVMXC__Description__c = 'Process-1';
        processObj2.SVMXC__Module__c = processObj.Id;
        processObj2.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        insert processObj2;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj.RecordTypeId = ConfigExpRTypeId;
        ConfObj.SVMXC__Select__c = true;
        ConfObj.SVMXC__Object_Name2__c = 'Case';
        ConfObj.SVMXC__Active__c = true;
        ConfObj.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'Account';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj1;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj2.RecordTypeId = ConfigExpRTypeId;
        ConfObj2.SVMXC__Select__c = true;
        ConfObj2.SVMXC__Object_Name2__c = 'Account';
        ConfObj2.SVMXC__Active__c = true;
        ConfObj2.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj2;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'Account';
        ConfObj3.SVMXC__Active__c = true;
        ConfObj3.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj3;
		
        //.......class instantiation and calling various methods.......
        CONF_ManageSearchConfiguration SearchObj =  new CONF_ManageSearchConfiguration();
        SearchObj.getTAG001();
        SearchObj.getTAG002();
        SearchObj.getTAG003();
        SearchObj.getTAG004();
        SearchObj.getTAG005();
        SearchObj.getTAG006();
        SearchObj.getTAG007();
        SearchObj.getTAG008();
        SearchObj.getTAG009();
        SearchObj.getIsHdrMsg();
        SearchObj.getlstStandardSearch();
        SearchObj.getlstCustomSearch();
        SearchObj.SVMXEdit();
        SearchObj.SVMXStdClone();
        SearchObj.SVMXCustomClone();
        SearchObj.SVMXManagePermission();
        SearchObj.BackToSetupHome();
        SearchObj.SVMXView();
        SearchObj.SVMXNew();
        SearchObj.SVMXdeleteRules();
        SearchObj.getHLPURL();
        SearchObj.getHLPTITLE();
        SearchObj.SVMX_PopupCancel();
    }
    static testMethod void CONF_ManageSearchConfiguration_UT_Test2()
    {
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        String SearchObjRTypeId = '';
        String SearchObjFldRTypeId = ''; 
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        ConfigExpRTypeId = ConfigRType[0].id;
    
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__IsStandard__c = true;
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        insert processObj;
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'Account';
        processObj1.SVMXC__IsStandard__c = true;
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Module__c = processObj.Id;
        insert processObj1;
        
        SVMXC__ServiceMax_Processes__c processObj2 = new SVMXC__ServiceMax_Processes__c();
        processObj2.RecordTypeId = ProcessRTypeId;
        processObj2.SVMXC__Select__c = false;
        processObj2.SVMXC__Target_Object_Name__c = 'Case';
        processObj2.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj2.SVMXC__Active__c = true;
        processObj2.SVMXC__Name__C = 'Process-1';
        processObj2.SVMXC__Description__c = 'Process-1';
        processObj2.SVMXC__Module__c = processObj.Id;
        insert processObj2;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj.RecordTypeId = ConfigExpRTypeId;
        ConfObj.SVMXC__Select__c = true;
        ConfObj.SVMXC__Object_Name2__c = 'Case';
        ConfObj.SVMXC__Active__c = true;
        ConfObj.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'Account';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj1;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj2.RecordTypeId = ConfigExpRTypeId;
        ConfObj2.SVMXC__Select__c = true;
        ConfObj2.SVMXC__Object_Name2__c = 'Account';
        ConfObj2.SVMXC__Active__c = true;
        ConfObj2.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj2;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'Account';
        ConfObj3.SVMXC__Active__c = true;
        ConfObj3.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj3;
        
        SVMXC__ServiceMax_Processes__c processObj12 = new SVMXC__ServiceMax_Processes__c();
        processObj12.RecordTypeId = ProcessRTypeId;
        processObj12.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        processObj12.SVMXC__IsStandard__c = true;
        processObj12.SVMXC__Select__c = false;
        processObj12.SVMXC__Active__c = true;
        processObj12.SVMXC__Name__C = 'Process-1';
        processObj12.SVMXC__ProcessID__c = 'ProcessID001';
        insert processObj12;
        
        SVMXC__ServiceMax_Processes__c processObj21 = new SVMXC__ServiceMax_Processes__c();
        processObj21.RecordTypeId = ProcessRTypeId;
        processObj21.SVMXC__Select__c = false;
        processObj21.SVMXC__Target_Object_Name__c = 'Account';
        processObj21.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj21.SVMXC__Active__c = true;
        processObj21.SVMXC__Name__C = 'Process-1';
        processObj21.SVMXC__Description__c = 'Process-1';
        processObj21.SVMXC__Module__c = processObj12.Id;
        insert processObj21;
        
        SVMXC__ServiceMax_Processes__c processObj22 = new SVMXC__ServiceMax_Processes__c();
        processObj22.RecordTypeId = ProcessRTypeId;
        processObj22.SVMXC__Select__c = false;
        processObj22.SVMXC__Target_Object_Name__c = 'Case';
        processObj22.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj22.SVMXC__Active__c = true;
        processObj22.SVMXC__Name__C = 'Process-1';
        processObj22.SVMXC__Description__c = 'Process-1';
        processObj22.SVMXC__Module__c = processObj12.Id;
        insert processObj22;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj21 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj21.RecordTypeId = ConfigExpRTypeId;
        ConfObj21.SVMXC__Select__c = true;
        ConfObj21.SVMXC__Object_Name2__c = 'Case';
        ConfObj21.SVMXC__Active__c = true;
        ConfObj21.SVMXC__Expression_Rule__c = processObj12.Id;
        insert ConfObj21;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj22 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj22.RecordTypeId = ConfigExpRTypeId;
        ConfObj22.SVMXC__Select__c = true;
        ConfObj22.SVMXC__Object_Name2__c = 'Account';
        ConfObj22.SVMXC__Active__c = true;
        ConfObj22.SVMXC__Expression_Rule__c = processObj12.Id;
        insert ConfObj22;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj23 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj23.RecordTypeId = ConfigExpRTypeId;
        ConfObj23.SVMXC__Select__c = true;
        ConfObj23.SVMXC__Object_Name2__c = 'Account';
        ConfObj23.SVMXC__Active__c = true;
        ConfObj23.SVMXC__Expression_Rule__c = processObj12.Id;
        insert ConfObj23;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj24 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj24.RecordTypeId = ConfigExpRTypeId;
        ConfObj24.SVMXC__Select__c = true;
        ConfObj24.SVMXC__Object_Name2__c = 'Account';
        ConfObj24.SVMXC__Active__c = true;
        ConfObj24.SVMXC__Expression_Rule__c = processObj12.Id;
        insert ConfObj24;
        
        //.......class instantiation and calling various methods.......
        CONF_ManageSearchConfiguration SearchObj =  new CONF_ManageSearchConfiguration();
        SearchObj.getTAG001();
        SearchObj.getTAG002();
        SearchObj.getTAG003();
        SearchObj.getTAG004();
        SearchObj.getTAG005();
        SearchObj.getTAG006();
        SearchObj.getTAG007();
        SearchObj.getTAG008();
        SearchObj.getTAG009();
        SearchObj.getTAG010();
        SearchObj.getTAG011();
        SearchObj.getTAG012();
        SearchObj.getTAG013();
        SearchObj.getTAG014();
        SearchObj.getTAG015();
        SearchObj.getTAG016();
        SearchObj.getTAG017();
        SearchObj.getTAG018();
        SearchObj.getIsHdrMsg();
        SearchObj.getlstStandardSearch();
        SearchObj.getlstCustomSearch();
        SearchObj.SVMXEdit();
        SearchObj.getStdLstSize();
        SearchObj.getCustomLstSize();
        SearchObj.SVMXStdClone();
        SearchObj.SVMXCustomClone();
        SearchObj.SVMXManagePermission();
        SearchObj.BackToSetupHome();
        SearchObj.SVMXView();
        SearchObj.SVMXNew();
        SearchObj.SVMXdeleteRules();
       	SearchObj.getTempSearchesLst();
       	SearchObj.getitems();
       	SearchObj.getdisplaySeqPopup();
       	SearchObj.Search_Sequence();
       	SearchObj.getSeqoptions();
       	SearchObj.getitems();
       	SearchObj.shuffle(0, false );
       	SearchObj.UP();
       	SearchObj.Down();
       	SearchObj.Top();
       	SearchObj.Bottom();
       	SearchObj.SVMX_SaveSequence();
       	SearchObj.Down();
		
		processObj.SVMXC__Select__c = true;
		
		
		processObj12.SVMXC__Select__c = true;
		update processObj12;
		SearchObj =  new CONF_ManageSearchConfiguration();
		SearchObj.SVMXStdClone();
		SearchObj =  new CONF_ManageSearchConfiguration();
		SearchObj.SVMXView();
    }
	static testMethod void CONF_ManageSearchConfiguration_UT_Test3()
    {
        List<RecordType> ProcessRType = new List<RecordType>(); 
        List<RecordType> ConfigRType = new List<RecordType>(); 
        String ConfigExpRTypeId = '';
        String ProcessRTypeId = '';
        String SearchObjRTypeId = '';
        String SearchObjFldRTypeId = ''; 
        ProcessRType = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1]; 
        ProcessRTypeId = ProcessRType[0].id;
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; 
        ConfigExpRTypeId = ConfigRType[0].id;
    
        SVMXC__ServiceMax_Processes__c processObj = new SVMXC__ServiceMax_Processes__c();
        processObj.RecordTypeId = ProcessRTypeId;
        processObj.SVMXC__Select__c = true;
        processObj.SVMXC__Active__c = true;
        processObj.SVMXC__IsStandard__c = false;
        processObj.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        processObj.SVMXC__Name__C = 'Process-1';
        processObj.SVMXC__ProcessID__c = 'ProcessID001';
        insert processObj;
        
        SVMXC__ServiceMax_Processes__c processObj1 = new SVMXC__ServiceMax_Processes__c();
        processObj1.RecordTypeId = ProcessRTypeId;
        processObj1.SVMXC__Select__c = false;
        processObj1.SVMXC__Target_Object_Name__c = 'Account';
        processObj1.SVMXC__IsStandard__c = true;
        processObj1.SVMXC__Active__c = true;
        processObj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj1.SVMXC__Name__C = 'Process-1';
        processObj1.SVMXC__Description__c = 'Process-1';
        processObj1.SVMXC__Module__c = processObj.Id;
        insert processObj1;
        
        SVMXC__ServiceMax_Processes__c processObj2 = new SVMXC__ServiceMax_Processes__c();
        processObj2.RecordTypeId = ProcessRTypeId;
        processObj2.SVMXC__Select__c = false;
        processObj2.SVMXC__Target_Object_Name__c = 'Case';
        processObj2.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj2.SVMXC__Active__c = true;
        processObj2.SVMXC__Name__C = 'Process-1';
        processObj2.SVMXC__Description__c = 'Process-1';
        processObj2.SVMXC__Module__c = processObj.Id;
        insert processObj2;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj.RecordTypeId = ConfigExpRTypeId;
        ConfObj.SVMXC__Select__c = true;
        ConfObj.SVMXC__Object_Name2__c = 'Case';
        ConfObj.SVMXC__Active__c = true;
        ConfObj.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj1 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj1.RecordTypeId = ConfigExpRTypeId;
        ConfObj1.SVMXC__Select__c = true;
        ConfObj1.SVMXC__Object_Name2__c = 'Account';
        ConfObj1.SVMXC__Active__c = true;
        ConfObj1.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj1;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj2 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj2.RecordTypeId = ConfigExpRTypeId;
        ConfObj2.SVMXC__Select__c = true;
        ConfObj2.SVMXC__Object_Name2__c = 'Account';
        ConfObj2.SVMXC__Active__c = true;
        ConfObj2.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj2;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj3 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj3.RecordTypeId = ConfigExpRTypeId;
        ConfObj3.SVMXC__Select__c = true;
        ConfObj3.SVMXC__Object_Name2__c = 'Account';
        ConfObj3.SVMXC__Active__c = true;
        ConfObj3.SVMXC__Expression_Rule__c = processObj.Id;
        insert ConfObj3;
        
        SVMXC__ServiceMax_Processes__c processObj12 = new SVMXC__ServiceMax_Processes__c();
        processObj12.RecordTypeId = ProcessRTypeId;
        processObj12.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        processObj12.SVMXC__IsStandard__c = false;
        processObj12.SVMXC__Select__c = false;
        processObj12.SVMXC__Active__c = true;
        processObj12.SVMXC__Name__C = 'Process-1';
        processObj12.SVMXC__ProcessID__c = 'ProcessID001';
        insert processObj12;
        
        SVMXC__ServiceMax_Processes__c processObj21 = new SVMXC__ServiceMax_Processes__c();
        processObj21.RecordTypeId = ProcessRTypeId;
        processObj21.SVMXC__Select__c = false;
        processObj21.SVMXC__Target_Object_Name__c = 'Account';
        processObj21.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj21.SVMXC__Active__c = true;
        processObj21.SVMXC__Name__C = 'Process-1';
        processObj21.SVMXC__Description__c = 'Process-1';
        processObj21.SVMXC__Module__c = processObj12.Id;
        insert processObj21;
        
        SVMXC__ServiceMax_Processes__c processObj22 = new SVMXC__ServiceMax_Processes__c();
        processObj22.RecordTypeId = ProcessRTypeId;
        processObj22.SVMXC__Select__c = false;
        processObj22.SVMXC__Target_Object_Name__c = 'Case';
        processObj22.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        processObj22.SVMXC__Active__c = true;
        processObj22.SVMXC__Name__C = 'Process-1';
        processObj22.SVMXC__Description__c = 'Process-1';
        processObj22.SVMXC__Module__c = processObj12.Id;
        insert processObj22;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj21 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj21.RecordTypeId = ConfigExpRTypeId;
        ConfObj21.SVMXC__Select__c = true;
        ConfObj21.SVMXC__Object_Name2__c = 'Case';
        ConfObj21.SVMXC__Active__c = true;
        ConfObj21.SVMXC__Expression_Rule__c = processObj12.Id;
        insert ConfObj21;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj22 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj22.RecordTypeId = ConfigExpRTypeId;
        ConfObj22.SVMXC__Select__c = true;
        ConfObj22.SVMXC__Object_Name2__c = 'Account';
        ConfObj22.SVMXC__Active__c = true;
        ConfObj22.SVMXC__Expression_Rule__c = processObj12.Id;
        insert ConfObj22;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj23 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj23.RecordTypeId = ConfigExpRTypeId;
        ConfObj23.SVMXC__Select__c = true;
        ConfObj23.SVMXC__Object_Name2__c = 'Account';
        ConfObj23.SVMXC__Active__c = true;
        ConfObj23.SVMXC__Expression_Rule__c = processObj12.Id;
        insert ConfObj23;
        
        SVMXC__ServiceMax_Config_Data__c ConfObj24 = new SVMXC__ServiceMax_Config_Data__c();
        ConfObj24.RecordTypeId = ConfigExpRTypeId;
        ConfObj24.SVMXC__Select__c = true;
        ConfObj24.SVMXC__Object_Name2__c = 'Account';
        ConfObj24.SVMXC__Active__c = true;
        ConfObj24.SVMXC__Expression_Rule__c = processObj12.Id;
        insert ConfObj24;
        
        //.......class instantiation and calling various methods.......
        CONF_ManageSearchConfiguration SearchObj =  new CONF_ManageSearchConfiguration();
        SearchObj.getIsHdrMsg();
        SearchObj.getlstStandardSearch();
        SearchObj.getlstCustomSearch();
        SearchObj.SVMXEdit();
        SearchObj.getStdLstSize();
        SearchObj.getCustomLstSize();
        SearchObj.SVMXStdClone();
        SearchObj.SVMXCustomClone();
        SearchObj.SVMXManagePermission();
        SearchObj.BackToSetupHome();
        SearchObj.SVMXView();
        SearchObj.SVMXNew();
        SearchObj.SVMXdeleteRules();
       	SearchObj.getTempSearchesLst();
       	SearchObj.getitems();
       	SearchObj.getdisplaySeqPopup();
       	SearchObj.Search_Sequence();
       	SearchObj.getSeqoptions();
       	SearchObj.getitems();
       	SearchObj.shuffle(1, true );
		
		SearchObj.setitems(new String[]{processObj12.id});
       	SearchObj.UP();
		SearchObj.SVMX_SaveSequence();
       	SearchObj.Down();
		SearchObj.SVMX_SaveSequence();
       	SearchObj.Top();
		SearchObj.SVMX_SaveSequence();
       	SearchObj.Bottom();
       	SearchObj.SVMX_SaveSequence();
		
		processObj12.SVMXC__Select__c = true;
		update processObj12;
		SearchObj =  new CONF_ManageSearchConfiguration();
		SearchObj.SVMXEdit();
		SearchObj =  new CONF_ManageSearchConfiguration();
		SearchObj.SVMXCustomClone();
    }
 }