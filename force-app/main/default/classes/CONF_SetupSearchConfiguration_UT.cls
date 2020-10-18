@isTest
Private with sharing class CONF_SetupSearchConfiguration_UT
{
    static testMethod void CONF_SetupSearchConfiguration_UT_Test()
    {
        String ProcessRTypeId = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1].Id; 
        String ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1].Id; 
        
        CONF_SetupSearchConfiguration SearchObj1 =  new CONF_SetupSearchConfiguration();      
        SearchObj1.getIsSeqEnabale();
        SearchObj1.strSVMXMode='View';
        SearchObj1.getIsViewMode();
        SearchObj1.getIsEditBtnEnabled();
        SearchObj1.getIsDelBtnEnabled();
                
        SVMXC__ServiceMax_Processes__c Search_Process_1 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Active__c = true, SVMXC__Name__C = 'Search_Process_1', SVMXC__ProcessID__c = 'Search_Process_1', SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH');
        insert Search_Process_1;
        System.assertEquals(true,Search_Process_1.Id != null);
        
        SVMXC__ServiceMax_Processes__c Search_Process_11 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Target_Object_Name__c = 'Account', SVMXC__Name__C = 'AccountSearch',SVMXC__Description__c = 'AccountSearch', SVMXC__Module__c = Search_Process_1.Id,SVMXC__Rule_Type__c = 'SRCH_OBJECT',SVMXC__Sequence__c = 1);
        insert Search_Process_11;
        System.assertEquals(true,Search_Process_11.Id != null);
        
        SVMXC__ServiceMax_Processes__c Search_Process_21 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Target_Object_Name__c = 'Case', SVMXC__Name__C = 'CaseSearch', SVMXC__Description__c = 'CaseSearch',SVMXC__Module__c = Search_Process_1.Id, SVMXC__Rule_Type__c = 'SRCH_OBJECT', SVMXC__Sequence__c = 1);
        insert Search_Process_21;
        System.assertEquals(true,Search_Process_21.Id != null);
        
        SVMXC__ServiceMax_Processes__c Search_Process_22 = new SVMXC__ServiceMax_Processes__c(RecordTypeId = ProcessRTypeId, SVMXC__Select__c = true, SVMXC__Target_Object_Name__c = 'SVMX.NONE', SVMXC__Name__C = 'CaseSearch', SVMXC__Description__c = 'CaseSearch',SVMXC__Module__c = Search_Process_1.Id, SVMXC__Rule_Type__c = 'SRCH_OBJECT', SVMXC__Sequence__c = 1);
        insert Search_Process_22;
        System.assertEquals(true,Search_Process_22.Id != null);     
                
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Config_Data__c Search_Filter_11 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Expression_Rule__c = Search_Process_11.Id, SVMXC__Sequence__c = 1, SVMXC__Field_Name__c = 'Name', SVMXC__Operator__c = 'eq', SVMXC__Operand__c = 'ABC', SVMXC__Object_Name__c = 'Account', SVMXC__Object_Name2__c = 'Account', SVMXC__Search_Object_Field_Type__c = 'Result', SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria'); 
        lstConfigData.add(Search_Filter_11);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt_11 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Display_Value__c = 'MAIN OBJECT', SVMXC__Is_Name_Field__c = true, SVMXC__Lookup_Field_API_Name__c = '',SVMXC__Expression_Rule__c = Search_Process_11.Id, SVMXC__Sequence__c = 1, SVMXC__Select__c = true, SVMXC__Expression_Type__c = 'SRCH_Object_Fields', SVMXC__Object_Name__c = 'Account', SVMXC__Object_Name2__c = 'Account', SVMXC__Field_Name__c = 'Name', SVMXC__Search_Object_Field_Type__c = 'Result');
        lstConfigData.add(Search_Rslt_11);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt_12 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Display_Value__c = 'MAIN OBJECT', SVMXC__Is_Name_Field__c = true, SVMXC__Lookup_Field_API_Name__c = '', SVMXC__Expression_Rule__c = Search_Process_11.Id, SVMXC__Sequence__c = 2, SVMXC__Select__c = true, SVMXC__Expression_Type__c = 'SRCH_Object_Fields', SVMXC__Object_Name__c = 'Account', SVMXC__Object_Name2__c = 'Account', SVMXC__Field_Name__c = 'Name', SVMXC__Search_Object_Field_Type__c = 'Result');
        lstConfigData.add(Search_Rslt_12);
        
        SVMXC__ServiceMax_Config_Data__c Search_Srch_11 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Display_Value__c = 'MAIN OBJECT', SVMXC__Is_Name_Field__c = true, SVMXC__Lookup_Field_API_Name__c = '', SVMXC__Expression_Rule__c = Search_Process_11.Id, SVMXC__Sequence__c = 1, SVMXC__Select__c = true, SVMXC__Expression_Type__c = 'SRCH_Object_Fields', SVMXC__Object_Name__c = 'Account', SVMXC__Object_Name2__c = 'Account', SVMXC__Field_Name__c = 'Name', SVMXC__Search_Object_Field_Type__c = 'Result');
        lstConfigData.add(Search_Srch_11);        
               
        SVMXC__ServiceMax_Config_Data__c Search_Filter_21 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Expression_Rule__c = Search_Process_21.Id, SVMXC__Sequence__c = 1, SVMXC__Field_Name__c = 'Priority', SVMXC__Operator__c = 'eq', SVMXC__Operand__c = 'High', SVMXC__Object_Name__c = 'Case', SVMXC__Object_Name2__c = 'Case', SVMXC__Search_Object_Field_Type__c = 'Result', SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria');
        lstConfigData.add(Search_Filter_21);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt_21 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Display_Value__c = 'MAIN OBJECT', SVMXC__Is_Name_Field__c = false, SVMXC__Lookup_Field_API_Name__c = '', SVMXC__Expression_Rule__c = Search_Process_21.Id, SVMXC__Sequence__c = 1, SVMXC__Select__c = true, SVMXC__Expression_Type__c = 'SRCH_Object_Fields', SVMXC__Object_Name__c = 'Case', SVMXC__Object_Name2__c = 'Case', SVMXC__Field_Name__c = 'Priority', SVMXC__Search_Object_Field_Type__c = 'Result');
        lstConfigData.add(Search_Rslt_21);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt_22 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Display_Value__c = 'MAIN OBJECT', SVMXC__Is_Name_Field__c = true, SVMXC__Lookup_Field_API_Name__c = '', SVMXC__Expression_Rule__c = Search_Process_21.Id, SVMXC__Sequence__c = 2, SVMXC__Select__c = true, SVMXC__Expression_Type__c = 'SRCH_Object_Fields', SVMXC__Object_Name__c = 'Case', SVMXC__Object_Name2__c = 'Case',SVMXC__Field_Name__c = 'Number', SVMXC__Search_Object_Field_Type__c = 'Result');
        lstConfigData.add(Search_Rslt_22);
        
        SVMXC__ServiceMax_Config_Data__c Search_Srch_21 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Display_Value__c = 'MAIN OBJECT', SVMXC__Is_Name_Field__c = true, SVMXC__Lookup_Field_API_Name__c = '', SVMXC__Expression_Rule__c = Search_Process_21.Id, SVMXC__Sequence__c = 1, SVMXC__Select__c = true, SVMXC__Expression_Type__c = 'SRCH_Object_Rslts', SVMXC__Object_Name__c = 'Case', SVMXC__Object_Name2__c = 'Case', SVMXC__Field_Name__c = 'Number', SVMXC__Search_Object_Field_Type__c = 'Result');
        lstConfigData.add(Search_Srch_21);
        
        insert lstConfigData;
        System.assertEquals(lstConfigData.size(),8);
        
        List<CONF_SetupSearchConfiguration.ProcessDataWrapper> WrapLstSearchObj = new List<CONF_SetupSearchConfiguration.ProcessDataWrapper>();
        WrapLstSearchObj.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_11, new List<SelectOption>()));
        WrapLstSearchObj.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_21, new List<SelectOption>()));
        
        List<CONF_SetupSearchConfiguration.ProcessDataWrapper> WrapLstSearchObj1 = new List<CONF_SetupSearchConfiguration.ProcessDataWrapper>();
        CONF_SetupSearchConfiguration.ProcessDataWrapper proDataWrap = new CONF_SetupSearchConfiguration.ProcessDataWrapper();
        proDataWrap.setobjProcessData(Search_Process_11);
        proDataWrap.setLstAutoLaunch(new List<SelectOption>());
        proDataWrap.getobjProcessData();
        proDataWrap.getLstAutoLaunch();
        WrapLstSearchObj1.add(proDataWrap);
        
        List<CONF_SetupSearchConfiguration.ProcessDataWrapper> WrapLstSearchObj2 = new List<CONF_SetupSearchConfiguration.ProcessDataWrapper>();
        WrapLstSearchObj2.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_22, new List<SelectOption>()));
        
        List<CONF_SetupSearchConfiguration.ConfigDataWrapper> WrapLstResultFields = new List<CONF_SetupSearchConfiguration.ConfigDataWrapper>();
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt_11, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt_12, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt_21, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt_22, new List<SelectOption>()));
        
        List<CONF_SetupSearchConfiguration.ConfigDataWrapper> WrapLstFilterFields = new List<CONF_SetupSearchConfiguration.ConfigDataWrapper>();
        WrapLstFilterFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Srch_11, new List<SelectOption>()));
        WrapLstFilterFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Srch_21, new List<SelectOption>()));
        
        
        List<CONF_SetupSearchConfiguration.ConfigDataWrapper> WrapLstCri = new List<CONF_SetupSearchConfiguration.ConfigDataWrapper>();
        WrapLstCri.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Filter_11, new List<SelectOption>()));
        WrapLstCri.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Filter_21, new List<SelectOption>()));
        
        CONF_SetupSearchConfiguration.ConfigDataWrapper ConfDataWrap = new CONF_SetupSearchConfiguration.ConfigDataWrapper();
        ConfDataWrap.setobjConfigData(Search_Filter_11);
        ConfDataWrap.setObjFlds(new List<SelectOption>());      
        ConfDataWrap.getobjConfigData();
        ConfDataWrap.getObjFlds();
        
        //string SVMX_RecordID = Search_Process_1.id;
        System.currentPageReference().getParameters().put('SVMX_RecordID', Search_Process_1.id);
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Edit');
        
        SearchObj1.setobjSearchProcess(Search_Process_1);
        SearchObj1.setWrapLstSearchObj(WrapLstSearchObj1);
        SearchObj1.EditObjLst();
        
        CONF_SetupSearchConfiguration SearchObj =  new CONF_SetupSearchConfiguration();
        
        SearchObj.setintIndex(0);
        SearchObj.SelectObjectAction();
        SearchObj.getIsSeqEnabale();
        SearchObj.setintIndex(1);
        SearchObj.getintIndex();
        SearchObj.SelectObjectAction();
        SearchObj.ObjectFields2();
        SearchObj.strObjectName = null;
        SearchObj.getstrObjectName();
        SearchObj.ObjectFields2();        
            
        SearchObj.setobjSearchProcess(Search_Process_1);    
        SearchObj.getWrapLstSearchObj();                
        
        SearchObj.setWrapLstSearchObj(WrapLstSearchObj);
        SearchObj.EditObjLst();
        SearchObj.setWrapLstSearchObj(WrapLstSearchObj1);
        SearchObj.EditObjLst();
        SearchObj.setWrapLstSearchObj(WrapLstSearchObj2);
        SearchObj.EditObjLst();     
        SearchObj.setWrapLstSearchObj(WrapLstSearchObj);
        
        SearchObj.save();       
        
        SearchObj.getWrapLstResultFields();
        SearchObj.setWrapLstResultFields(WrapLstResultFields);
        SearchObj.getWrapLstFilterFields();
        SearchObj.setWrapLstFilterFields(WrapLstFilterFields);
        SearchObj.getWrapLstCri();
        SearchObj.setWrapLstCri(WrapLstCri);
        
        SearchObj.getIsNewBtnDisabled();
        SearchObj.getdisplaySeqPopup1();
        SearchObj.getstrObjectName();
        SearchObj.getdisplaySeqPopup();
        SearchObj.getIsFldSeq();
        
        SearchObj.getselectedTab();
        SearchObj.setselectedTab('Genaral Info');
        SearchObj.gotoGeneralInfoTab();
        SearchObj.gotoManageSearchObjectsTab();
        //SearchObj.DisplayFldsSequence();
        
        SearchObj.SVMX_PopupCancel();
                
        SearchObj.getIsRender();
        SearchObj.getIsViewMode();
        SearchObj.getIsEditMode();
        SearchObj.getIsObjDisable();
        SearchObj.getIsAddBtnEnabled();
        SearchObj.getIsEditBtnEnabled();
        SearchObj.getIsSaveBtnEnabled();
        SearchObj.getIsDelBtnEnabled();
        SearchObj.getintIndex();
        SearchObj.setintIndex(1);
        SearchObj.StrDelIndex = '1';
        SearchObj.getLstObjects();
        SearchObj.getlstRelatedObj();
        SearchObj.getOperatorsSelectLst();
        SearchObj.getobjSearchProcess();
        SearchObj.getSearchObjSize();
        SearchObj.getRsltFldsSize();
        SearchObj.getFlteFldsSize();
        SearchObj.getCritExpSize();
        SearchObj.Objlst('Account');
        SearchObj.ObjectFields3();
        SearchObj.getAllFields('Account');
        SearchObj.getAllFields('Case');
        SearchObj.EditObjLst();
        SearchObj.Quicksave();
        SearchObj.SaveNClose();
        SearchObj.IsValidate();        
        SearchObj.AddSearchObj();
        SearchObj.AddResultFields();
        SearchObj.AddFilterFields();
        SearchObj.cancel();
        SearchObj.ObjCancel();       
            
        
        SVMXC__ServiceMax_Processes__c delprocs = [SELECT Id FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Target_Object_Name__c = 'SVMX.NONE'];
        delete delprocs;
        System.assertEquals(delprocs.id!=null,true);
        
        String[] items = new String[]{Search_Process_1.Id,Search_Process_11.Id,Search_Process_21.Id};
        SearchObj.setitems(items);
        SearchObj.getitems();
        SearchObj.SVMX_RuleSequence();        
        SearchObj.UP();
        SearchObj.IsUpAction = true;
        SearchObj.SVMX_SaveSequence();
        SearchObj.Down();
        SearchObj.SVMX_SaveSequence();      
        SearchObj.Top();
        SearchObj.SVMX_SaveSequence();
        SearchObj.Bottom();
        SearchObj.SVMX_SaveSequence();
        SearchObj.onLoad();     
        SearchObj.getObjSeqoptions();
        SearchObj.shuffle(1,true);
        SearchObj.shuffle(1,false);
        
        SearchObj.AddSearchCri();
        SearchObj.DelSearchCri();
        SearchObj.DelSearchObj();
        SearchObj.DelFilterFields();
        SearchObj.DelResultFields();        
        
        SearchObj.DisplayFldsSequence();
        SearchObj.getDisplayFldsSeqoptions();
        Search_Rslt_11.SVMXC__Select__c=false;
        
        Search_Rslt_12.SVMXC__Select__c=false;
        Search_Srch_11.SVMXC__Select__c=false;
        update Search_Rslt_11;
        update Search_Rslt_12;
        update Search_Srch_11;
        SearchObj.DisplayFldsSeqLst.add(Search_Rslt_11);
        SearchObj.DisplayFldsSeqLst.add(Search_Rslt_12);
        SearchObj.DisplayFldsSeqLst.add(Search_Srch_11);
        SearchObj.DisplayFldsSeqLst.add(Search_Rslt_21);
        //SearchObj.DisplayFldshuffle(0,true);
        //SearchObj.DisplayFldshuffle(0,false);
        SearchObj.DisplayFldUP();
        SearchObj.DisplayFldSaveSequence();
        SearchObj.DisplayFldDown();
        SearchObj.DisplayFldSaveSequence();
        SearchObj.DisplayFldTop();
        SearchObj.DisplayFldSaveSequence();
        SearchObj.DisplayFldBottom();
        SearchObj.DisplayFldSaveSequence();
        
        SearchObj.strSVMXMode='Clone';
        System.debug('Mode = '+SearchObj.strSVMXMode);
        SearchObj.save();       
            
        SVMXC__ServiceMax_Processes__c proc = new SVMXC__ServiceMax_Processes__c();
        SearchObj.setobjSearchProcess(proc);
        SearchObj.ObjCancel();
        SearchObj.IsValidate();
            
        SearchObj.getHLPURL();
        SearchObj.getHLPTITLE();
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
        SearchObj.getTAG019();
        SearchObj.getTAG020();
        SearchObj.getTAG021();
        SearchObj.getTAG022();
        SearchObj.getTAG023();
        SearchObj.getTAG024();
        SearchObj.getTAG025();
        SearchObj.getTAG026();
        SearchObj.getTAG027();
        SearchObj.getTAG028();
        SearchObj.getTAG029();
        SearchObj.getTAG030();
        SearchObj.getTAG031();
        SearchObj.getTAG032();
        SearchObj.getTAG033();
        SearchObj.getTAG034();
        SearchObj.getTAG035();
        SearchObj.getTAG036();
        SearchObj.getTAG037();
        SearchObj.getTAG038();
        SearchObj.getTAG039();
        SearchObj.getTAG040();
        SearchObj.getTAG041();
        SearchObj.getTAG042();
        SearchObj.getTAG043();
        SearchObj.getTAG044();
        SearchObj.getTAG045();
        SearchObj.getTAG046();
        SearchObj.getTAG047();
        SearchObj.getTAG048();
        SearchObj.getTAG049();
        SearchObj.getTAG050();
        SearchObj.getTAG051();
        SearchObj.getTAG052();
        SearchObj.getTAG053();
        SearchObj.getTAG054();
        SearchObj.getTAG055();
        CONF_SetupSearchConfiguration.ObjectListWrapper obj = new CONF_SetupSearchConfiguration.ObjectListWrapper();
        obj.getSize();
        
        obj.get(1);
        obj.getSelectList();
        obj.getSubList(1,2);
        obj.getNthSubList(1);
        obj.get0();
        obj.get1();
        SearchObj.getIsSecondListHasItem();
        SearchObj.getWrapLstOrderFields();
        SearchObj.getOrderFldsSize();
        SearchObj.getOrderFldsSize();
        obj.add(new SelectOption('a','a'));
    }
    
    private static string ProcessRTypeId;
    private static string ConfigRType;
    private static SVMXC__ServiceMax_Processes__c Search_Process_1;
    private static SVMXC__ServiceMax_Processes__c Search_Process_2;
    private static SVMXC__ServiceMax_Processes__c Search_Process_1_Obj1;
    private static SVMXC__ServiceMax_Processes__c Search_Process_1_Obj2;
    private static SVMXC__ServiceMax_Processes__c Search_Process_1_Obj3;
    private static SVMXC__ServiceMax_Processes__c Search_Process_2_Obj1;
    private static SVMXC__ServiceMax_Processes__c Search_Process_2_Obj2;
    private static SVMXC__ServiceMax_Processes__c Search_Process_2_Obj3;
    private static List<SVMXC__ServiceMax_Config_Data__c> lstConfigData;
    private static List<CONF_SetupSearchConfiguration.ProcessDataWrapper> WrapLstSearchObj;
    private static List<CONF_SetupSearchConfiguration.ConfigDataWrapper> WrapLstResultFields;
    private static List<CONF_SetupSearchConfiguration.ConfigDataWrapper> WrapLstFilterFields;
    private static List<CONF_SetupSearchConfiguration.ConfigDataWrapper> WrapLstExpCriteria;
    private static CONF_SetupSearchConfiguration SearchObj;
    
    static void createData(Boolean isNewMode)
    {
        ProcessRTypeId = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1].Id; 
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1].Id; 
        
        Search_Process_1 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_1.RecordTypeId = ProcessRTypeId;
        Search_Process_1.SVMXC__Active__c = true;
        Search_Process_1.SVMXC__Name__C = 'Search_Process_1';
        Search_Process_1.SVMXC__ProcessID__c = 'Search_Process_1';
        Search_Process_1.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        if(!isNewMode) insert Search_Process_1;
        system.assert(Search_Process_1.SVMXC__Name__C != NULL);
        
        Search_Process_1_Obj1 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_1_Obj1.RecordTypeId = ProcessRTypeId;
        Search_Process_1_Obj1.SVMXC__Select__c = true;
        Search_Process_1_Obj1.SVMXC__Target_Object_Name__c = 'Account';
        Search_Process_1_Obj1.SVMXC__Name__C = 'AccountSearch';
        Search_Process_1_Obj1.SVMXC__Description__c = 'AccountSearch';
        Search_Process_1_Obj1.SVMXC__Module__c = Search_Process_1.Id;
        Search_Process_1_Obj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        Search_Process_1_Obj1.SVMXC__Sequence__c = 1;
        if(!isNewMode) insert Search_Process_1_Obj1;
        system.assert(Search_Process_1_Obj1.SVMXC__Name__C != NULL);
        
        CONF_SetupSearchConfiguration.ProcessDataWrapper objWrap1 = new CONF_SetupSearchConfiguration.ProcessDataWrapper();
        objWrap1.getobjProcessData();
        objWrap1.setobjProcessData(Search_Process_1_Obj1);
        objWrap1.setobjProcessData(Search_Process_1_Obj2);
        objWrap1.setobjProcessData(Search_Process_1_Obj3);
        objWrap1.setobjProcessData(Search_Process_2_Obj1);
        objWrap1.setobjProcessData(Search_Process_2_Obj2);
        objWrap1.setobjProcessData(Search_Process_2_Obj3);
        
        lstConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c Search_Filter_Process_1_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Filter_Process_1_Obj_1.SVMXC__Expression_Rule__c = Search_Process_1_Obj1.Id;
        Search_Filter_Process_1_Obj_1.SVMXC__Sequence__c = 1;
        Search_Filter_Process_1_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Filter_Process_1_Obj_1.SVMXC__Operator__c = 'eq';
        Search_Filter_Process_1_Obj_1.SVMXC__Operand__c = 'ABC';
        Search_Filter_Process_1_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Filter_Process_1_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Filter_Process_1_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Result';
        Search_Filter_Process_1_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        lstConfigData.add(Search_Filter_Process_1_Obj_1);
        system.assert(Search_Filter_Process_1_Obj_1.SVMXC__Field_Name__c != NULL);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt1_Process_1_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt1_Process_1_Obj_1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Is_Name_Field__c = true;
        Search_Rslt1_Process_1_Obj_1.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Expression_Rule__c = Search_Process_1_Obj1.Id;
        Search_Rslt1_Process_1_Obj_1.SVMXC__Sequence__c = 1;
        Search_Rslt1_Process_1_Obj_1.SVMXC__Select__c = true;
        Search_Rslt1_Process_1_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt1_Process_1_Obj_1);
        system.assert(Search_Rslt1_Process_1_Obj_1.SVMXC__Field_Name__c != NULL);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt2_Process_1_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt2_Process_1_Obj_1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Is_Name_Field__c = true;
        Search_Rslt2_Process_1_Obj_1.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Expression_Rule__c = Search_Process_1_Obj1.Id;
        Search_Rslt2_Process_1_Obj_1.SVMXC__Sequence__c = 2;
        Search_Rslt2_Process_1_Obj_1.SVMXC__Select__c = true;
        Search_Rslt2_Process_1_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt2_Process_1_Obj_1);
        system.assert(Search_Rslt2_Process_1_Obj_1.SVMXC__Field_Name__c != NULL);
       
        SVMXC__ServiceMax_Config_Data__c Search_Srch1_Process_1_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Srch1_Process_1_Obj_1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Srch1_Process_1_Obj_1.SVMXC__Is_Name_Field__c = true;
        Search_Srch1_Process_1_Obj_1.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Srch1_Process_1_Obj_1.SVMXC__Expression_Rule__c = Search_Process_1_Obj1.Id;
        Search_Srch1_Process_1_Obj_1.SVMXC__Sequence__c = 1;
        Search_Srch1_Process_1_Obj_1.SVMXC__Select__c = true;
        Search_Srch1_Process_1_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Srch1_Process_1_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Srch1_Process_1_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Srch1_Process_1_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Srch1_Process_1_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Search';
        lstConfigData.add(Search_Srch1_Process_1_Obj_1);
        
        Search_Process_1_Obj2 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_1_Obj2.RecordTypeId = ProcessRTypeId;
        Search_Process_1_Obj2.SVMXC__Select__c = false;
        Search_Process_1_Obj2.SVMXC__Target_Object_Name__c = 'Case';
        Search_Process_1_Obj2.SVMXC__Name__C = 'Case';
        Search_Process_1_Obj2.SVMXC__Description__c = 'Case';
        Search_Process_1_Obj2.SVMXC__Module__c = Search_Process_1.Id;
        Search_Process_1_Obj2.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        Search_Process_1_Obj2.SVMXC__Sequence__c = 1;
        if(!isNewMode) insert Search_Process_1_Obj2;
        
        SVMXC__ServiceMax_Config_Data__c Search_Filter_Process_1_Obj_2 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Filter_Process_1_Obj_2.SVMXC__Expression_Rule__c = Search_Process_1_Obj2.Id;
        Search_Filter_Process_1_Obj_2.SVMXC__Sequence__c = 1;
        Search_Filter_Process_1_Obj_2.SVMXC__Field_Name__c = 'Priority';
        Search_Filter_Process_1_Obj_2.SVMXC__Operator__c = 'eq';
        Search_Filter_Process_1_Obj_2.SVMXC__Operand__c = 'HIGH';
        Search_Filter_Process_1_Obj_2.SVMXC__Object_Name__c = 'Case';
        Search_Filter_Process_1_Obj_2.SVMXC__Object_Name2__c = 'Case';
        Search_Filter_Process_1_Obj_2.SVMXC__Search_Object_Field_Type__c = 'Result';
        Search_Filter_Process_1_Obj_2.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        lstConfigData.add(Search_Filter_Process_1_Obj_2);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt1_Process_1_Obj_2 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt1_Process_1_Obj_2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt1_Process_1_Obj_2.SVMXC__Is_Name_Field__c = true;
        Search_Rslt1_Process_1_Obj_2.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt1_Process_1_Obj_2.SVMXC__Expression_Rule__c = Search_Process_1_Obj2.Id;
        Search_Rslt1_Process_1_Obj_2.SVMXC__Sequence__c = 1;
        Search_Rslt1_Process_1_Obj_2.SVMXC__Select__c = true;
        Search_Rslt1_Process_1_Obj_2.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt1_Process_1_Obj_2.SVMXC__Object_Name__c = 'Case';
        Search_Rslt1_Process_1_Obj_2.SVMXC__Object_Name2__c = 'Case';
        Search_Rslt1_Process_1_Obj_2.SVMXC__Field_Name__c = 'Number';
        Search_Rslt1_Process_1_Obj_2.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt1_Process_1_Obj_2);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt2_Process_1_Obj_2 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt2_Process_1_Obj_2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt2_Process_1_Obj_2.SVMXC__Is_Name_Field__c = true;
        Search_Rslt2_Process_1_Obj_2.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt2_Process_1_Obj_2.SVMXC__Expression_Rule__c = Search_Process_1_Obj2.Id;
        Search_Rslt2_Process_1_Obj_2.SVMXC__Sequence__c = 2;
        Search_Rslt2_Process_1_Obj_2.SVMXC__Select__c = true;
        Search_Rslt2_Process_1_Obj_2.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt2_Process_1_Obj_2.SVMXC__Object_Name__c = 'Case';
        Search_Rslt2_Process_1_Obj_2.SVMXC__Object_Name2__c = 'Case';
        Search_Rslt2_Process_1_Obj_2.SVMXC__Field_Name__c = 'Number';
        Search_Rslt2_Process_1_Obj_2.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt2_Process_1_Obj_2);
        
        SVMXC__ServiceMax_Config_Data__c Search_Srch1_Process_1_Obj_2 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Srch1_Process_1_Obj_2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Srch1_Process_1_Obj_2.SVMXC__Is_Name_Field__c = true;
        Search_Srch1_Process_1_Obj_2.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Srch1_Process_1_Obj_2.SVMXC__Expression_Rule__c = Search_Process_1_Obj2.Id;
        Search_Srch1_Process_1_Obj_2.SVMXC__Sequence__c = 1;
        Search_Srch1_Process_1_Obj_2.SVMXC__Select__c = true;
        Search_Srch1_Process_1_Obj_2.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Srch1_Process_1_Obj_2.SVMXC__Object_Name__c = 'Case';
        Search_Srch1_Process_1_Obj_2.SVMXC__Object_Name2__c = 'Case';
        Search_Srch1_Process_1_Obj_2.SVMXC__Field_Name__c = 'Number';
        Search_Srch1_Process_1_Obj_2.SVMXC__Search_Object_Field_Type__c = 'Search';
        lstConfigData.add(Search_Srch1_Process_1_Obj_2);
        
        Search_Process_1_Obj3 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_1_Obj3.RecordTypeId = ProcessRTypeId;
        Search_Process_1_Obj3.SVMXC__Select__c = false;
        Search_Process_1_Obj3.SVMXC__Target_Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Process_1_Obj3.SVMXC__Name__C = 'SVMXC__PM_Plan__C';
        Search_Process_1_Obj3.SVMXC__Description__c = 'SVMXC__PM_Plan__C';
        Search_Process_1_Obj3.SVMXC__Module__c = Search_Process_1.Id;
        Search_Process_1_Obj3.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        Search_Process_1_Obj3.SVMXC__Sequence__c = 1;
        if(!isNewMode) insert Search_Process_1_Obj3;
        
        SVMXC__ServiceMax_Config_Data__c Search_Filter_Process_1_Obj_3 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Filter_Process_1_Obj_3.SVMXC__Expression_Rule__c = Search_Process_1_Obj3.Id;
        Search_Filter_Process_1_Obj_3.SVMXC__Sequence__c = 1;
        Search_Filter_Process_1_Obj_3.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        Search_Filter_Process_1_Obj_3.SVMXC__Operator__c = 'eq';
        Search_Filter_Process_1_Obj_3.SVMXC__Operand__c = 'ABC';
        Search_Filter_Process_1_Obj_3.SVMXC__Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Filter_Process_1_Obj_3.SVMXC__Object_Name2__c = 'SVMXC__PM_Plan__C';
        Search_Filter_Process_1_Obj_3.SVMXC__Search_Object_Field_Type__c = 'Result';
        Search_Filter_Process_1_Obj_3.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        lstConfigData.add(Search_Filter_Process_1_Obj_3);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt1_Process_1_Obj_3 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt1_Process_1_Obj_3.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt1_Process_1_Obj_3.SVMXC__Is_Name_Field__c = true;
        Search_Rslt1_Process_1_Obj_3.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt1_Process_1_Obj_3.SVMXC__Expression_Rule__c = Search_Process_1_Obj3.Id;
        Search_Rslt1_Process_1_Obj_3.SVMXC__Sequence__c = 1;
        Search_Rslt1_Process_1_Obj_3.SVMXC__Select__c = true;
        Search_Rslt1_Process_1_Obj_3.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt1_Process_1_Obj_3.SVMXC__Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Rslt1_Process_1_Obj_3.SVMXC__Object_Name2__c = 'SVMXC__PM_Plan__C';
        Search_Rslt1_Process_1_Obj_3.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        Search_Rslt1_Process_1_Obj_3.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt1_Process_1_Obj_3);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt2_Process_1_Obj_3 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt2_Process_1_Obj_3.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt2_Process_1_Obj_3.SVMXC__Is_Name_Field__c = true;
        Search_Rslt2_Process_1_Obj_3.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt2_Process_1_Obj_3.SVMXC__Expression_Rule__c = Search_Process_1_Obj3.Id;
        Search_Rslt2_Process_1_Obj_3.SVMXC__Sequence__c = 2;
        Search_Rslt2_Process_1_Obj_3.SVMXC__Select__c = true;
        Search_Rslt2_Process_1_Obj_3.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt2_Process_1_Obj_3.SVMXC__Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Rslt2_Process_1_Obj_3.SVMXC__Object_Name2__c = 'SVMXC__PM_Plan__C';
        Search_Rslt2_Process_1_Obj_3.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        Search_Rslt2_Process_1_Obj_3.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt2_Process_1_Obj_3);
        
        SVMXC__ServiceMax_Config_Data__c Search_Srch1_Process_1_Obj_3 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Srch1_Process_1_Obj_3.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Srch1_Process_1_Obj_3.SVMXC__Is_Name_Field__c = true;
        Search_Srch1_Process_1_Obj_3.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Srch1_Process_1_Obj_3.SVMXC__Expression_Rule__c = Search_Process_1_Obj3.Id;
        Search_Srch1_Process_1_Obj_3.SVMXC__Sequence__c = 1;
        Search_Srch1_Process_1_Obj_3.SVMXC__Select__c = true;
        Search_Srch1_Process_1_Obj_3.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Srch1_Process_1_Obj_3.SVMXC__Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Srch1_Process_1_Obj_3.SVMXC__Object_Name2__c = 'SVMXC__PM_Plan__C';
        Search_Srch1_Process_1_Obj_3.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        Search_Srch1_Process_1_Obj_3.SVMXC__Search_Object_Field_Type__c = 'Search';
        lstConfigData.add(Search_Srch1_Process_1_Obj_3);
        
        Search_Process_2 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_2.RecordTypeId = ProcessRTypeId;
        Search_Process_2.SVMXC__Select__c = true;
        Search_Process_2.SVMXC__Active__c = true;
        Search_Process_2.SVMXC__Name__C = 'Search_Process_2';
        Search_Process_2.SVMXC__ProcessID__c = 'Search_Process_2';
        Search_Process_2.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        if(!isNewMode) insert Search_Process_2;
        
        Search_Process_2_Obj1 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_2_Obj1.RecordTypeId = ProcessRTypeId;
        Search_Process_2_Obj1.SVMXC__Select__c = false;
        Search_Process_2_Obj1.SVMXC__Target_Object_Name__c = 'Account';
        Search_Process_2_Obj1.SVMXC__Name__C = 'AccountSearch';
        Search_Process_2_Obj1.SVMXC__Description__c = 'AccountSearch';
        Search_Process_2_Obj1.SVMXC__Module__c = Search_Process_2.Id;
        Search_Process_2_Obj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        Search_Process_2_Obj1.SVMXC__Sequence__c = 1;
        if(!isNewMode) insert Search_Process_2_Obj1;
        
        SVMXC__ServiceMax_Config_Data__c Search_Filter_Process_2_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Filter_Process_2_Obj_1.SVMXC__Expression_Rule__c = Search_Process_2_Obj1.Id;
        Search_Filter_Process_2_Obj_1.SVMXC__Sequence__c = 1;
        Search_Filter_Process_2_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Filter_Process_2_Obj_1.SVMXC__Operator__c = 'eq';
        Search_Filter_Process_2_Obj_1.SVMXC__Operand__c = 'ABC';
        Search_Filter_Process_2_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Filter_Process_2_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Filter_Process_2_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Result';
        Search_Filter_Process_2_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        lstConfigData.add(Search_Filter_Process_2_Obj_1);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt1_Process_2_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt1_Process_2_Obj_1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt1_Process_2_Obj_1.SVMXC__Is_Name_Field__c = true;
        Search_Rslt1_Process_2_Obj_1.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt1_Process_2_Obj_1.SVMXC__Expression_Rule__c = Search_Process_2_Obj1.Id;
        Search_Rslt1_Process_2_Obj_1.SVMXC__Sequence__c = 1;
        Search_Rslt1_Process_2_Obj_1.SVMXC__Select__c = true;
        Search_Rslt1_Process_2_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt1_Process_2_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Rslt1_Process_2_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Rslt1_Process_2_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Rslt1_Process_2_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt1_Process_2_Obj_1);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt2_Process_2_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt2_Process_2_Obj_1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt2_Process_2_Obj_1.SVMXC__Is_Name_Field__c = true;
        Search_Rslt2_Process_2_Obj_1.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt2_Process_2_Obj_1.SVMXC__Expression_Rule__c = Search_Process_2_Obj1.Id;
        Search_Rslt2_Process_2_Obj_1.SVMXC__Sequence__c = 2;
        Search_Rslt2_Process_2_Obj_1.SVMXC__Select__c = true;
        Search_Rslt2_Process_2_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt2_Process_2_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Rslt2_Process_2_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Rslt2_Process_2_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Rslt2_Process_2_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt2_Process_2_Obj_1);
        
        SVMXC__ServiceMax_Config_Data__c Search_Srch1_Process_2_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Srch1_Process_2_Obj_1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Srch1_Process_2_Obj_1.SVMXC__Is_Name_Field__c = true;
        Search_Srch1_Process_2_Obj_1.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Srch1_Process_2_Obj_1.SVMXC__Expression_Rule__c = Search_Process_2_Obj1.Id;
        Search_Srch1_Process_2_Obj_1.SVMXC__Sequence__c = 1;
        Search_Srch1_Process_2_Obj_1.SVMXC__Select__c = true;
        Search_Srch1_Process_2_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Srch1_Process_2_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Srch1_Process_2_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Srch1_Process_2_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Srch1_Process_2_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Search';
        lstConfigData.add(Search_Srch1_Process_2_Obj_1);
        
        Search_Process_2_Obj2 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_2_Obj2.RecordTypeId = ProcessRTypeId;
        Search_Process_2_Obj2.SVMXC__Select__c = false;
        Search_Process_2_Obj2.SVMXC__Target_Object_Name__c = 'Case';
        Search_Process_2_Obj2.SVMXC__Name__C = 'Case';
        Search_Process_2_Obj2.SVMXC__Description__c = 'Case';
        Search_Process_2_Obj2.SVMXC__Module__c = Search_Process_2.Id;
        Search_Process_2_Obj2.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        Search_Process_2_Obj2.SVMXC__Sequence__c = 1;
        if(!isNewMode) insert Search_Process_2_Obj2;
        
        SVMXC__ServiceMax_Config_Data__c Search_Filter_Process_2_Obj_2 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Filter_Process_2_Obj_2.SVMXC__Expression_Rule__c = Search_Process_2_Obj2.Id;
        Search_Filter_Process_2_Obj_2.SVMXC__Sequence__c = 1;
        Search_Filter_Process_2_Obj_2.SVMXC__Field_Name__c = 'Priority';
        Search_Filter_Process_2_Obj_2.SVMXC__Operator__c = 'eq';
        Search_Filter_Process_2_Obj_2.SVMXC__Operand__c = 'HIGH';
        Search_Filter_Process_2_Obj_2.SVMXC__Object_Name__c = 'Case';
        Search_Filter_Process_2_Obj_2.SVMXC__Object_Name2__c = 'Case';
        Search_Filter_Process_2_Obj_2.SVMXC__Search_Object_Field_Type__c = 'Result';
        Search_Filter_Process_2_Obj_2.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        lstConfigData.add(Search_Filter_Process_2_Obj_2);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt1_Process_2_Obj_2 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt1_Process_2_Obj_2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt1_Process_2_Obj_2.SVMXC__Is_Name_Field__c = true;
        Search_Rslt1_Process_2_Obj_2.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt1_Process_2_Obj_2.SVMXC__Expression_Rule__c = Search_Process_2_Obj2.Id;
        Search_Rslt1_Process_2_Obj_2.SVMXC__Sequence__c = 1;
        Search_Rslt1_Process_2_Obj_2.SVMXC__Select__c = true;
        Search_Rslt1_Process_2_Obj_2.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt1_Process_2_Obj_2.SVMXC__Object_Name__c = 'Case';
        Search_Rslt1_Process_2_Obj_2.SVMXC__Object_Name2__c = 'Case';
        Search_Rslt1_Process_2_Obj_2.SVMXC__Field_Name__c = 'Number';
        Search_Rslt1_Process_2_Obj_2.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt1_Process_2_Obj_2);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt2_Process_2_Obj_2 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt2_Process_2_Obj_2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt2_Process_2_Obj_2.SVMXC__Is_Name_Field__c = true;
        Search_Rslt2_Process_2_Obj_2.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt2_Process_2_Obj_2.SVMXC__Expression_Rule__c = Search_Process_2_Obj2.Id;
        Search_Rslt2_Process_2_Obj_2.SVMXC__Sequence__c = 2;
        Search_Rslt2_Process_2_Obj_2.SVMXC__Select__c = true;
        Search_Rslt2_Process_2_Obj_2.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt2_Process_2_Obj_2.SVMXC__Object_Name__c = 'Case';
        Search_Rslt2_Process_2_Obj_2.SVMXC__Object_Name2__c = 'Case';
        Search_Rslt2_Process_2_Obj_2.SVMXC__Field_Name__c = 'Number';
        Search_Rslt2_Process_2_Obj_2.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt2_Process_2_Obj_2);
        
        SVMXC__ServiceMax_Config_Data__c Search_Srch1_Process_2_Obj_2 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Srch1_Process_2_Obj_2.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Srch1_Process_2_Obj_2.SVMXC__Is_Name_Field__c = true;
        Search_Srch1_Process_2_Obj_2.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Srch1_Process_2_Obj_2.SVMXC__Expression_Rule__c = Search_Process_2_Obj2.Id;
        Search_Srch1_Process_2_Obj_2.SVMXC__Sequence__c = 1;
        Search_Srch1_Process_2_Obj_2.SVMXC__Select__c = true;
        Search_Srch1_Process_2_Obj_2.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Srch1_Process_2_Obj_2.SVMXC__Object_Name__c = 'Case';
        Search_Srch1_Process_2_Obj_2.SVMXC__Object_Name2__c = 'Case';
        Search_Srch1_Process_2_Obj_2.SVMXC__Field_Name__c = 'Number';
        Search_Srch1_Process_2_Obj_2.SVMXC__Search_Object_Field_Type__c = 'Search';
        lstConfigData.add(Search_Srch1_Process_2_Obj_2);
        
        Search_Process_2_Obj3 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_2_Obj3.RecordTypeId = ProcessRTypeId;
        Search_Process_2_Obj3.SVMXC__Select__c = false;
        Search_Process_2_Obj3.SVMXC__Target_Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Process_2_Obj3.SVMXC__Name__C = 'SVMXC__PM_Plan__C';
        Search_Process_2_Obj3.SVMXC__Description__c = 'SVMXC__PM_Plan__C';
        Search_Process_2_Obj3.SVMXC__Module__c = Search_Process_2.Id;
        Search_Process_2_Obj3.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        Search_Process_2_Obj3.SVMXC__Sequence__c = 1;
        if(!isNewMode) insert Search_Process_2_Obj3;
        
        SVMXC__ServiceMax_Config_Data__c Search_Filter_Process_2_Obj_3 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Filter_Process_2_Obj_3.SVMXC__Expression_Rule__c = Search_Process_2_Obj3.Id;
        Search_Filter_Process_2_Obj_3.SVMXC__Sequence__c = 1;
        Search_Filter_Process_2_Obj_3.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        Search_Filter_Process_2_Obj_3.SVMXC__Operator__c = 'eq';
        Search_Filter_Process_2_Obj_3.SVMXC__Operand__c = 'ABC';
        Search_Filter_Process_2_Obj_3.SVMXC__Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Filter_Process_2_Obj_3.SVMXC__Object_Name2__c = 'SVMXC__PM_Plan__C';
        Search_Filter_Process_2_Obj_3.SVMXC__Search_Object_Field_Type__c = 'Result';
        Search_Filter_Process_2_Obj_3.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        lstConfigData.add(Search_Filter_Process_2_Obj_3);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt1_Process_2_Obj_3 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt1_Process_2_Obj_3.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt1_Process_2_Obj_3.SVMXC__Is_Name_Field__c = true;
        Search_Rslt1_Process_2_Obj_3.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt1_Process_2_Obj_3.SVMXC__Expression_Rule__c = Search_Process_2_Obj3.Id;
        Search_Rslt1_Process_2_Obj_3.SVMXC__Sequence__c = 1;
        Search_Rslt1_Process_2_Obj_3.SVMXC__Select__c = true;
        Search_Rslt1_Process_2_Obj_3.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt1_Process_2_Obj_3.SVMXC__Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Rslt1_Process_2_Obj_3.SVMXC__Object_Name2__c = 'SVMXC__PM_Plan__C';
        Search_Rslt1_Process_2_Obj_3.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        Search_Rslt1_Process_2_Obj_3.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt1_Process_2_Obj_3);
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt2_Process_2_Obj_3 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt2_Process_2_Obj_3.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt2_Process_2_Obj_3.SVMXC__Is_Name_Field__c = true;
        Search_Rslt2_Process_2_Obj_3.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt2_Process_2_Obj_3.SVMXC__Expression_Rule__c = Search_Process_2_Obj3.Id;
        Search_Rslt2_Process_2_Obj_3.SVMXC__Sequence__c = 2;
        Search_Rslt2_Process_2_Obj_3.SVMXC__Select__c = true;
        Search_Rslt2_Process_2_Obj_3.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt2_Process_2_Obj_3.SVMXC__Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Rslt2_Process_2_Obj_3.SVMXC__Object_Name2__c = 'SVMXC__PM_Plan__C';
        Search_Rslt2_Process_2_Obj_3.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        Search_Rslt2_Process_2_Obj_3.SVMXC__Search_Object_Field_Type__c = 'Result';
        lstConfigData.add(Search_Rslt2_Process_2_Obj_3);
        
        SVMXC__ServiceMax_Config_Data__c Search_Srch1_Process_2_Obj_3 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Srch1_Process_2_Obj_3.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Srch1_Process_2_Obj_3.SVMXC__Is_Name_Field__c = true;
        Search_Srch1_Process_2_Obj_3.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Srch1_Process_2_Obj_3.SVMXC__Expression_Rule__c = Search_Process_2_Obj3.Id;
        Search_Srch1_Process_2_Obj_3.SVMXC__Sequence__c = 1;
        Search_Srch1_Process_2_Obj_3.SVMXC__Select__c = true;
        Search_Srch1_Process_2_Obj_3.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Srch1_Process_2_Obj_3.SVMXC__Object_Name__c = 'SVMXC__PM_Plan__C';
        Search_Srch1_Process_2_Obj_3.SVMXC__Object_Name2__c = 'SVMXC__PM_Plan__C';
        Search_Srch1_Process_2_Obj_3.SVMXC__Field_Name__c = 'SVMXC__Account__c';
        Search_Srch1_Process_2_Obj_3.SVMXC__Search_Object_Field_Type__c = 'Search';
        lstConfigData.add(Search_Srch1_Process_2_Obj_3);
        if(!isNewMode) upsert lstConfigData;
        
        WrapLstSearchObj = new List<CONF_SetupSearchConfiguration.ProcessDataWrapper>();
        WrapLstSearchObj.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_1_Obj1, new List<SelectOption>()));
        WrapLstSearchObj.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_1_Obj2, new List<SelectOption>()));
        WrapLstSearchObj.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_1_Obj3, new List<SelectOption>()));
        WrapLstSearchObj.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_2_Obj1, new List<SelectOption>()));
        WrapLstSearchObj.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_2_Obj2, new List<SelectOption>()));
        WrapLstSearchObj.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_2_Obj3, new List<SelectOption>()));
        
        WrapLstResultFields = new List<CONF_SetupSearchConfiguration.ConfigDataWrapper>();
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt1_Process_1_Obj_1, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt2_Process_1_Obj_1, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt1_Process_1_Obj_2, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt2_Process_1_Obj_2, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt1_Process_1_Obj_3, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt2_Process_1_Obj_3, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt1_Process_2_Obj_1, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt2_Process_2_Obj_1, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt1_Process_2_Obj_2, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt2_Process_2_Obj_2, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt1_Process_2_Obj_3, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt2_Process_2_Obj_3, new List<SelectOption>()));
        
        WrapLstFilterFields = new List<CONF_SetupSearchConfiguration.ConfigDataWrapper>();
        WrapLstFilterFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Srch1_Process_1_Obj_1, new List<SelectOption>()));
        WrapLstFilterFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Srch1_Process_1_Obj_2, new List<SelectOption>()));
        WrapLstFilterFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Srch1_Process_1_Obj_3, new List<SelectOption>()));
        WrapLstFilterFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Srch1_Process_2_Obj_1, new List<SelectOption>()));
        WrapLstFilterFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Srch1_Process_2_Obj_2, new List<SelectOption>()));
        WrapLstFilterFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Srch1_Process_2_Obj_3, new List<SelectOption>()));
        
        WrapLstExpCriteria = new List<CONF_SetupSearchConfiguration.ConfigDataWrapper>();
        WrapLstExpCriteria.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Filter_Process_1_Obj_1, new List<SelectOption>()));
        WrapLstExpCriteria.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Filter_Process_1_Obj_2, new List<SelectOption>()));
        WrapLstExpCriteria.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Filter_Process_1_Obj_3, new List<SelectOption>()));
        WrapLstExpCriteria.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Filter_Process_2_Obj_1, new List<SelectOption>()));
        WrapLstExpCriteria.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Filter_Process_2_Obj_2, new List<SelectOption>()));
        WrapLstExpCriteria.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Filter_Process_2_Obj_3, new List<SelectOption>()));
        
        CONF_SetupSearchConfiguration.ConfigDataWrapper objWrap2 = new CONF_SetupSearchConfiguration.ConfigDataWrapper();
        objWrap2.getobjConfigData();
        objWrap2.setobjConfigData(Search_Rslt1_Process_1_Obj_1);
        objWrap2.setobjConfigData(Search_Rslt2_Process_1_Obj_1);
        objWrap2.setobjConfigData(Search_Rslt1_Process_1_Obj_2);
        objWrap2.setobjConfigData(Search_Rslt2_Process_1_Obj_2);
    }
    
    static void createData1(Boolean isNewMode)
    {
        ProcessRTypeId = [select Id from RecordType where Name = 'Named Search' AND SobjectType= 'SVMXC__ServiceMax_Processes__c' Limit 1].Id; 
        ConfigRType = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1].Id; 
        
        Search_Process_1 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_1.RecordTypeId = ProcessRTypeId;
        Search_Process_1.SVMXC__Active__c = true;
        Search_Process_1.SVMXC__Name__C = 'Search_Process_1';
        Search_Process_1.SVMXC__ProcessID__c = 'Search_Process_1';
        Search_Process_1.SVMXC__Rule_Type__c = 'SRCH_NAMED_SEARCH';
        
        Search_Process_1_Obj1 = new SVMXC__ServiceMax_Processes__c();
        Search_Process_1_Obj1.RecordTypeId = ProcessRTypeId;
        Search_Process_1_Obj1.SVMXC__Select__c = false;
        Search_Process_1_Obj1.SVMXC__Target_Object_Name__c = 'Account';
        Search_Process_1_Obj1.SVMXC__Name__C = 'AccountSearch';
        Search_Process_1_Obj1.SVMXC__Description__c = 'AccountSearch';
        Search_Process_1_Obj1.SVMXC__Rule_Type__c = 'SRCH_OBJECT';
        Search_Process_1_Obj1.SVMXC__Sequence__c = 1;
        
        lstConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c Search_Filter_Process_1_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Filter_Process_1_Obj_1.SVMXC__Sequence__c = 1;
        Search_Filter_Process_1_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Filter_Process_1_Obj_1.SVMXC__Operator__c = 'eq';
        Search_Filter_Process_1_Obj_1.SVMXC__Operand__c = 'ABC';
        Search_Filter_Process_1_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Filter_Process_1_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Filter_Process_1_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Result';
        Search_Filter_Process_1_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Prefilter_Criteria';
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt1_Process_1_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt1_Process_1_Obj_1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Is_Name_Field__c = true;
        Search_Rslt1_Process_1_Obj_1.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Sequence__c = 1;
        Search_Rslt1_Process_1_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Rslt1_Process_1_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Result';
        
        SVMXC__ServiceMax_Config_Data__c Search_Rslt2_Process_1_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Rslt2_Process_1_Obj_1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Is_Name_Field__c = true;
        Search_Rslt2_Process_1_Obj_1.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Sequence__c = 2;
        Search_Rslt2_Process_1_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Rslt2_Process_1_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Result';
        
        SVMXC__ServiceMax_Config_Data__c Search_Srch1_Process_1_Obj_1 = new SVMXC__ServiceMax_Config_Data__c();
        Search_Srch1_Process_1_Obj_1.SVMXC__Display_Value__c = 'MAIN OBJECT';
        Search_Srch1_Process_1_Obj_1.SVMXC__Is_Name_Field__c = true;
        Search_Srch1_Process_1_Obj_1.SVMXC__Lookup_Field_API_Name__c = '';
        Search_Srch1_Process_1_Obj_1.SVMXC__Sequence__c = 1;
        Search_Srch1_Process_1_Obj_1.SVMXC__Select__c = false;
        Search_Srch1_Process_1_Obj_1.SVMXC__Expression_Type__c = 'SRCH_Object_Rslts';
        Search_Srch1_Process_1_Obj_1.SVMXC__Object_Name__c = 'Account';
        Search_Srch1_Process_1_Obj_1.SVMXC__Object_Name2__c = 'Account';
        Search_Srch1_Process_1_Obj_1.SVMXC__Field_Name__c = 'Name';
        Search_Srch1_Process_1_Obj_1.SVMXC__Search_Object_Field_Type__c = 'Search';
        
        WrapLstSearchObj = new List<CONF_SetupSearchConfiguration.ProcessDataWrapper>();
        WrapLstSearchObj.add(new CONF_SetupSearchConfiguration.ProcessDataWrapper(Search_Process_1_Obj1, new List<SelectOption>()));
        
        WrapLstResultFields = new List<CONF_SetupSearchConfiguration.ConfigDataWrapper>();
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt1_Process_1_Obj_1, new List<SelectOption>()));
        WrapLstResultFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Rslt2_Process_1_Obj_1, new List<SelectOption>()));
        
        WrapLstFilterFields = new List<CONF_SetupSearchConfiguration.ConfigDataWrapper>();
        WrapLstFilterFields.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Srch1_Process_1_Obj_1, new List<SelectOption>()));
        
        WrapLstExpCriteria = new List<CONF_SetupSearchConfiguration.ConfigDataWrapper>();
        WrapLstExpCriteria.add(new CONF_SetupSearchConfiguration.ConfigDataWrapper(Search_Filter_Process_1_Obj_1, new List<SelectOption>()));
    }

    
    static void callAllMethods()
    {
        SearchObj =  new CONF_SetupSearchConfiguration();
        SearchObj.getHLPURL();
        SearchObj.getHLPTITLE();
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
        SearchObj.getTAG019();
        SearchObj.getTAG020();
        SearchObj.getTAG021();
        SearchObj.getTAG022();
        SearchObj.getTAG023();
        SearchObj.getTAG024();
        SearchObj.getTAG025();
        SearchObj.getTAG026();
        SearchObj.getTAG027();
        SearchObj.getTAG028();
        SearchObj.getTAG029();
        SearchObj.getTAG030();
        SearchObj.getTAG031();
        SearchObj.getTAG032();
        SearchObj.getTAG033();
        SearchObj.getTAG034();
        SearchObj.getTAG035();
        SearchObj.getTAG036();
        SearchObj.getTAG037();
        SearchObj.getTAG038();
        SearchObj.getTAG039();
        SearchObj.getTAG040();
        SearchObj.getTAG041();
        SearchObj.getTAG042();
        SearchObj.getTAG043();
        SearchObj.getTAG044();
        SearchObj.getTAG045();
        SearchObj.getTAG046();
        SearchObj.getTAG047();
        SearchObj.getTAG048();
        SearchObj.getTAG049();
        SearchObj.getTAG050();
        SearchObj.getTAG051();
        SearchObj.getTAG052();
        SearchObj.getTAG053();
        SearchObj.getTAG054();
        SearchObj.getTAG055();
        SearchObj.getTAG056();
        SearchObj.getTAG057();
        
        SearchObj.setobjSearchProcess(Search_Process_1);
        SearchObj.setWrapLstSearchObj(WrapLstSearchObj);
        SearchObj.setWrapLstResultFields(WrapLstResultFields);
        SearchObj.setWrapLstFilterFields(WrapLstFilterFields);
        SearchObj.setWrapLstCri(WrapLstExpCriteria);
        SearchObj.setintIndex(0);
        SearchObj.getIsNewBtnDisabled();
        SearchObj.getdisplaySeqPopup1();
        SearchObj.getstrObjectName();
        SearchObj.getdisplaySeqPopup();
        SearchObj.getIsFldSeq();
        //SearchObj.SVMX_RuleSequence();
        SearchObj.getselectedTab();
        SearchObj.setselectedTab('Genaral Info');
        SearchObj.gotoGeneralInfoTab();
        SearchObj.gotoManageSearchObjectsTab();
        
        SearchObj.getDisplayFldsSeqoptions();
        SearchObj.DisplayFldUP();
        SearchObj.DisplayFldDown();
        SearchObj.DisplayFldTop();
        SearchObj.DisplayFldBottom();
        SearchObj.SVMX_PopupCancel();
        
        SearchObj.Down();
        SearchObj.Top();
        SearchObj.Bottom();
        SearchObj.getIsRender();
        SearchObj.getIsViewMode();
        SearchObj.getIsEditMode();
        SearchObj.getIsObjDisable();
        SearchObj.getIsAddBtnEnabled();
        SearchObj.getIsEditBtnEnabled();
        SearchObj.getIsSaveBtnEnabled();
        SearchObj.getIsDelBtnEnabled();
        SearchObj.getIsSeqEnabale();
        SearchObj.getIsSeqEnabale();
        SearchObj.getIsSeqEnabale();
        SearchObj.getIsSeqEnabale();
        SearchObj.StrDelIndex = '1';
        SearchObj.getLstObjects();
        SearchObj.getlstRelatedObj();
        SearchObj.getOperatorsSelectLst();
        SearchObj.getobjSearchProcess();
        SearchObj.getSearchObjSize();
        SearchObj.getRsltFldsSize();
        SearchObj.getFlteFldsSize();
        SearchObj.getCritExpSize();
        SearchObj.Objlst('Account');
        SearchObj.ObjectFields3();
        SearchObj.getAllFields('Account');
        SearchObj.getFilterableObjFields('Account');
        SearchObj.getAllFields('Case');
        SearchObj.getFilterableObjFields('Case');
        SearchObj.EditObjLst();
        SearchObj.Quicksave();
        SearchObj.SaveNClose();
        SearchObj.IsValidate();
        SearchObj.save();
        SearchObj.AddSearchObj();
        SearchObj.AddResultFields();
        SearchObj.AddFilterFields();
        SearchObj.cancel();
        SearchObj.ObjCancel();
        SearchObj.AddSearchCri();
        SearchObj.DelSearchCri();
        SearchObj.DelSearchObj();
        SearchObj.DelFilterFields();
        SearchObj.DelResultFields();
    }
    
    static testMethod void CONF_SetupSearchConfiguration_UT_Test1()
    {
        Boolean isNewMode = false;
        createData(isNewMode);
        System.currentPageReference().getParameters().put('SVMX_RecordID', Search_Process_1.Id);
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Edit');
        callAllMethods();
    }
    
    static testMethod void CONF_SetupSearchConfiguration_UT_Test2()
    {
        Boolean isNewMode = false;
        createData(isNewMode);
        System.currentPageReference().getParameters().put('SVMX_RecordID', Search_Process_1.Id);
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Clone');
        callAllMethods();
    }
    
    static testMethod void CONF_SetupSearchConfiguration_UT_Test3()
    {
        Boolean isNewMode = false;
        createData(isNewMode);
        System.currentPageReference().getParameters().put('SVMX_RecordID', Search_Process_2.Id);
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Edit');
        callAllMethods();
    }
    
    static testMethod void CONF_SetupSearchConfiguration_UT_Test4()
    {
        Boolean isNewMode = false;
        createData(isNewMode);
        System.currentPageReference().getParameters().put('SVMX_RecordID', Search_Process_2.Id);
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Clone');
        callAllMethods();
    }
    
    
    static testMethod void CONF_SetupSearchConfiguration_UT_Test5()
    {
        Boolean isNewMode = false;
        createData1(isNewMode);
        System.currentPageReference().getParameters().put('SVMX_RecordID', Search_Process_1.Id);
        System.currentPageReference().getParameters().put('SVMX_Mode', 'Clone');
        callAllMethods();
    }
    static testMethod void CONF_SetupSearchConfiguration_UT_Test6()
    {
        CONF_SetupSearchConfiguration customSearch= new CONF_SetupSearchConfiguration();
        customSearch.AddOrderFields();
        
    }
    
}