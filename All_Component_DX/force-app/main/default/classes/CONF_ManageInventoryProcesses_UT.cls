@isTest(SeeAllData=true)
Private class CONF_ManageInventoryProcesses_UT{
    private static SVMXC.CONF_ManageInventoryProcesses invobject, invobject1, invobject2, invobject3; 
    private static SVMXC.COMM_SVMXC_Search_Expressions serchexp = new SVMXC.COMM_SVMXC_Search_Expressions();
    static testMethod void CONF_ManageInventoryProcesses_UT(){
        map<String,map<string, string>> RTypeMap = new map<String,map<string, string>>();
        list<RecordType> allRecType = database.query('Select SystemModstamp,SobjectType,NamespacePrefix,Name,LastModifiedDate,LastModifiedById,IsActive,Id,DeveloperName, Description,CreatedDate,CreatedById,BusinessProcessId From RecordType');
        for(RecordType rt: allRecType){
        if(RTypeMap.containsKey(rt.SobjectType))
        RTypeMap.get(rt.SobjectType).put(rt.Name,rt.id);
        else{
        map<string, string> mapTempRType = new map<string, string>();
        mapTempRType.put(rt.Name, rt.id);
        RTypeMap.put(rt.SobjectType,mapTempRType);
        }
        }
        string ExpressionFields = 'id, SVMXC__Object_Name__c, RecordTypeID, SVMXC__Lookup_Field_API_Name__c, SVMXC__FKey_Name_Field__c, SVMXC__Expression_Type__c, SVMXC__Inventory_Process__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c';
        string ProcessFields = 'id, Name, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ModuleId__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__IsStandard__c, SVMXC__Name__c, SVMXC__Child_Object_Criteria__c, SVMXC__Parent_Object_Criteria__c';
        list<SVMXC__ServiceMax_Processes__c> lstSVMXPro = database.query('select ' + ProcessFields + ' from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = \'PORD007\'');
        SVMXC__ServiceMax_Processes__c Inventory_Process = lstSVMXPro[0];
        
        //Scenario to Launch Page without url parameters id  
        PageReference pageRef1 = new PageReference('Page.SVMXC.CONF_ManageInventoryProcesses');
        pageRef1.getParameters().put('Pid',Inventory_Process.Id);
        Test.setCurrentPageReference(pageRef1); 
        invobject = new SVMXC.CONF_ManageInventoryProcesses();
        test.startTest();
        invobject.getLstStockbleLocation();
        invobject.getlstChildRecordType();
        invobject.getlstActionOnQty();
        invobject.getlstStatus();
        invobject.getlstProduct2Fields();
        invobject.lstHdrObjOpt= new CONF_SetupAction.FieldListWrapper();
        CONF_SetupAction.FieldListWrapper obj = invobject.lstHdrObjOpt;
        boolean lstvar = invobject.getIsSecondListHasItemObject();
        invobject.getlstLineObjOpt();
        invobject.getSelectedIndex();
        invobject.setSelectedIndex('1');
        //invobject.getlstLinecriteria();
        invobject.getListofUniqunes();
        invobject.getLocationtoConsider();
        invobject.getlstLevalofhistorytrack();
        invobject.getModule();
        invobject.objSVMXPro.Is_Target_Location_Stockable = true;
        invobject.objSVMXPro.Is_Source_Location_Stockable = false;
        invobject.getSelStockbleLocation();
        invobject.objSVMXPro.Is_Source_Location_Stockable = true;
        invobject.getSelStockbleLocation();
        invobject.objSVMXPro.Is_Target_Location_Stockable = false;
        invobject.objSVMXPro.Is_Source_Location_Stockable = false;
        invobject.getSelStockbleLocation();
        invobject.objSVMXPro.Is_Source_Location_Stockable = true;
        invobject.getSelStockbleLocation();
        invobject.getstrHdrAdvOption();
        invobject.getstrLineAdvOption();
        invobject.getstrLineErrorMsg();
        invobject.getstrHdrErrorMsg();
        invobject.getlblHdrObj();
        invobject.getlblLineObj();
        invobject.getSelectedID();
        invobject.getSelectedLabel();
        invobject.getLevalofhistorytrack();
        invobject.getselectedTab();
        
        string ObjName = 'abc';//Inventory_Process.SVMXC__Parent_Object_Name__c;
        string FieldName = 'name';
          
        //PL TAGS methods
        /*system.assert(invobject.getPLTAG001()!=null,'getPLTAG001 assertion failed');
        invobject.setPLTAG001('STR');       
        system.assert(invobject.getPLTAG002()!=null,'getPLTAG002 assertion failed');
        invobject.setPLTAG002('STR');       
        system.assert(invobject.getPLTAG003()!=null,'getPLTAG003 assertion failed');
        invobject.setPLTAG003('STR');*/     
        
        //Integer Method        
        system.assert(invobject.getintHdrCriSize()!=null,'getintHdrCriSize assertion failed');      
        system.assert(invobject.getintlineCriSize()!=null,'getintlineCriSize assertion failed');
        
        //Boolean Methods
        invobject.getDisplayvalue();        
        invobject.getisEditMode();      
        invobject.getDisableValue();        
        invobject.getisSearch();        
        invobject.getisDateSearch();        
        invobject.getCheckAllLines();       
        invobject.objSVMXPro.ProcessID = 'testtesttest';
        invobject.ProcessObjSave();
        invobject.PLTagSave();
        invobject.ConfigDataSave();
        invobject.LocSource();
        invobject.filllstActionOnQty();
        invobject.getStatusPickList();
        invobject.HdrADDRow();
        invobject.HdrDeleteRow();
        invobject.LineADDRow();
        invobject.LineDeleteRow();
        
        String s;
        String s1;
        List<SVMXC__ServiceMax_Config_Data__c> lst = new List<SVMXC__ServiceMax_Config_Data__c>();
        integer iIndex;
        Boolean b;
        List<selectOption> lst1 = new List<selectOption>();
        Map<String,Schema.Displaytype> m = new Map<String,Schema.Displaytype>();
        Map<String,String> m2 = new Map<String,String>();
        Schema.Displaytype DT = Schema.Displaytype.REFERENCE;
        Map<string,SelectOption> m1 = new Map<string,SelectOption>();
        SVMXC__ServiceMax_Processes__c sp = new SVMXC__ServiceMax_Processes__c();
        
        invobject.setSelStockbleLocation('1');
        invobject.setSelStockbleLocation('2');
        invobject.setSelStockbleLocation('3');
        invobject.setSelStockbleLocation('0');
        invobject.isSearch = false;
        invobject.isdateSearch = false;
        invobject.getgraytab();
        invobject.isdateSearch = true;
        invobject.getgraytab();
        invobject.getobjSVMXPro();
        invobject.setobjSVMXPro(new COMM_Inventory_Classes.InventoryProcess());
        invobject.getHdrExpressions();
        invobject.getLineExpressions();
        invobject.getHdrCloserExpressions();
        invobject.getLineCloserExpressions();
        invobject.getRelatedCloserExpressions();
        invobject.getisCloneMode();
        invobject.getisNewMode();
        
        invobject.setstrHdrAdvOption(s);
        invobject.setstrLineAdvOption(s);
        invobject.setstrLineErrorMsg(s);
        invobject.setstrHdrErrorMsg(s);
        //invobject.getlstHdrcriteria();
        //invobject.getlstHdrCloCriteria();
        //invobject.getlstChildCloCriteria();
        invobject.getisInventoryEnabled();
        invobject.getisSeedDataComplate();
        
        invobject.setlblHdrObj(s);
        invobject.setlblLineObj(s);
        invobject.setSelectedID(s);
        invobject.setSelectedLabel(s);
        invobject.updateTags('test','test');
        invobject.updateTags('test','test');
        invobject.setCheckAllLines(b);
        
        //invobject.setlstHdrcriteria(lst);
        //invobject.setlstHdrCloCriteria(lst);
        //invobject.setlstChildCloCriteria(lst);
        
        invobject.setMaintainHistory(true);
        invobject.OnSelectStockHistory();
        invobject.setMaintainHistory(false);
        invobject.OnSelectStockHistory();
        invobject.EnableBarcode();
        invobject.objSVMXPro.Is_Multiline_Transaction = false;
        invobject.OnSelectChild(); 
        invobject.getfieldnames();
        invobject.SVMX_doQuickSave();
        invobject.SVMX_doSave();
        invobject.SVMX_doCancel();
        invobject.SVMX_GoHome();
        invobject.SVMX_ProcessInformation();
        invobject.SVMX_EntryCriteria();
        invobject.SVMX_UserInputs();
        invobject.SVMX_StockUpdates();
        invobject.SVMX_RelatedTranscation();
        invobject.SVMX_ClosureActions();
        invobject.getlstProductFields();
        invobject.OnEnable_Inventory_Action();
        invobject.QtyUpdate();
        invobject.HdrCloserADDRow();
        invobject.HdrCloserDeleteRow();
        invobject.LineCloserADDRow();
        invobject.LineCloserDeleteRow();
        invobject.RelatedCloserADDRow();
        invobject.RelatedCloserDeleteRow();
        invobject.getSR();
        invobject.setgraytab('test');
        invobject.SelectedIndex = '1';
        //invobject.getHLPURL();
        invobject.OnHdrEntryCriFieldSelect();
        invobject.OnLineEntryCriFieldSelect();
        invobject.OnHdrCloserEntryCriFieldSelect();
        invobject.OnLineCloserEntryCriFieldSelect();
        
        invobject.RetriveField2('Contact',new List<selectOption>(), new Map<String,Schema.Displaytype>(), new Map<String,String>(),Schema.Displaytype.REFERENCE);
        invobject.RetriveField('Contact',new List<selectOption>(), new Map<String,Schema.Displaytype>(), new Map<String,String>(),Schema.Displaytype.REFERENCE,'Account');
        invobject.RetriveField('Contact',new List<selectOption>(), null, null,Schema.Displaytype.REFERENCE);
        invobject.OnHdrObjSelect();
        invobject.getBooleanOptions();
        invobject.objSVMXPro.Number_of_locations = '';
        invobject.SVMX_OnNoofLocationSelect();
        invobject.objSVMXPro.Number_of_locations = 'One';
        invobject.SVMX_OnNoofLocationSelect();
        invobject.objSVMXPro.Number_of_locations = 'Two';
        invobject.SVMX_OnNoofLocationSelect();
        invobject.objSVMXPro.Maintain_Serial_History =true;
        invobject.objSVMXPro.Maintain_Stock_History =true;
        invobject.getLevalofhistorytrack();
        invobject.objSVMXPro.Maintain_Stock_History =false;
        invobject.getLevalofhistorytrack();
        invobject.objSVMXPro.Maintain_Serial_History =false;
        invobject.objSVMXPro.Maintain_Stock_History =true;
        invobject.getLevalofhistorytrack();
        invobject.objSVMXPro.Maintain_Stock_History =false;
        invobject.getLevalofhistorytrack();
        invobject.setLevalofhistorytrack('');
        invobject.setLevalofhistorytrack('Stock History Only');
        invobject.setLevalofhistorytrack('Serial History Only');
        invobject.setLevalofhistorytrack('Stock & Serial History');
        SVMXC__ServiceMax_Config_Data__c oConfigData = new SVMXC__ServiceMax_Config_Data__c();
        invobject.Do_Search();
        invobject.Do_Select();
        invobject.Do_CancelSearch();
        
        invobject.getRelationShip(ObjName,FieldName);
        invobject.getReferenceTo('Contact','Account');
        invobject.getIsChildRecordTypeRequired();
        invobject.Do_Search();
        invobject.Do_Select();
        invobject.OnselectRecord();
        list<SelectOption> so = new list<selectOption>();
        so.add(new selectoption('test', 'test'));
        so.add(new selectoption('test1', 'test2'));
        so.add(new selectoption('test2', 'test3'));
        //invobject.sortingSelectOption(so, true);
        //invobject.sortingSelectOption(so, false);
        invobject.selectedTab = 'test';//invobject.getTAG014();
        invobject.SVMX_StockUpdates();
        invobject.selectedTab = 'test';//invobject.getTAG108();
        invobject.SVMX_StockUpdates();
        invobject.setselectedTab('test');
        invobject.SVMX_StockUpdates();
        //exception tests
        //invobject.svmxTagList = null;
        //invobject.mapPLTags = null;
        
        invobject.objSVMXPro = null;
        invobject.getQtyFldlist();
        invobject.getProRefFldlist();
        invobject.getfldSourceLoc();
        invobject.getfldTargetLoc();
        invobject.getlstChildRecordType();
        invobject.getIsChildRecordTypeRequired();
        //invobject.getLineFldlist();
        invobject.getlstHdrStockHistoryFields();
        invobject.getlstLineStockHistoryFields();
        //invobject.getLineFldlist();
        invobject.RetriveField2(null, null, null, null, null);
        invobject.RetriveField(null, null, null, null);
        invobject.RetriveField(null, null, null, null, null);
        invobject.RetriveField(null, null, null, null, null, null);
        invobject.getChildObjects();
        //invobject.mapFieldApiName = null;
        invobject.getStatusPickList();
        invobject.OnSelectStockHistory();
        invobject.OnSelectChild();
        invobject.OnHdrObjSelect();
        invobject.getfieldnames();
        invobject.Do_Search();
        invobject.Do_Select();
        invobject.OnselectRecord();
        invobject.OnHdrEntryCriFieldSelect();
        invobject.OnLineEntryCriFieldSelect();
        invobject.OnHdrCloserEntryCriFieldSelect();
        invobject.OnLineCloserEntryCriFieldSelect();
        invobject.getBooleanOptions();
        invobject.getListofUniqunes();
        invobject.getLocationtoConsider();
        invobject.SVMX_OnNoofLocationSelect();
        invobject.getMaintainHistory();
        invobject.getlstLevalofhistorytrack();
        invobject.getLevalofhistorytrack();
        invobject.setMaintainHistory(null);
        invobject.setLevalofhistorytrack('');
        invobject.updateTags('', '');
        /*invobject.getPLTAG001();
        invobject.getPLTAG002();
        invobject.getPLTAG003();*/
        invobject.getRelationShip( '','');
        invobject.getReferenceTo('', '');
        invobject.ProcessObjSave();
        invobject.AddFieldValue('test', '');
        invobject.AddException('');
        invobject.PLTagSave();
        invobject.HdrExpressions = null;
        invobject.SVMX_doQuickSave();
        invobject.SVMX_doSave();
        invobject.HdrFind();
        invobject.HdrFindDate();
        
        invobject.HdrExpressions = null;
        invobject.HdrADDRow();
        invobject.HdrDeleteRow();
        invobject.LineExpressions = null;
        invobject.LineADDRow();
        invobject.LineDeleteRow();
        invobject.HdrCloserExpressions = null;
        invobject.HdrCloserADDRow();
        invobject.HdrCloserDeleteRow();
        invobject.LineCloserExpressions = null;
        invobject.LineCloserADDRow();
        invobject.LineCloserDeleteRow();
        invobject.RelatedCloserExpressions = null;
        invobject.RelatedCloserADDRow();
        invobject.RelatedCloserDeleteRow();
        //invobject.sortingSelectOption(null, false);
        
        invobject.mMapFieldList = null;
        invobject.RetriveUpdateableField(null, null, null, null);
        invobject.RetriveUpdateableField(null, null, null, null, null); 
        test.stopTest();
    }

    static testMethod void CONF_ManageInventoryProcesses_UT2(){
        //Scenario to Launch Page without url parameters id   
        SVMXC.CONF_ManageInventoryProcesses invobject11;   
        PageReference pageRef1 = new PageReference('Page.SVMXC.CONF_ManageInventoryProcesses');
        Test.setCurrentPageReference(pageRef1); 
        invobject11 = new SVMXC.CONF_ManageInventoryProcesses();
        invobject11.objSVMXPro.Child_Object_Name = 'SVMXC__RMA_Shipment_Line__c';
        invobject11.objSVMXPro.Parent_Object_Name = 'SVMXC__RMA_Shipment_Order__c';
        invobject11.getlstHdrStockHistoryFields();
        invobject11.getlstLineStockHistoryFields();
        //invobject11.getLineFldlist();
        invobject11.getlstProductFields();
        
        system.assert(invobject11.getTAG072()!=null,'TAG assertion failed');
        system.assert(invobject11.getTAG073()!=null,'TAG assertion failed');
    }

    static testMethod void CONF_ManageInventoryProcesses_UT3(){
        string ProcessFields = 'id, Name, SVMXC__Submodule__r.SVMXC__SubmoduleID__c, SVMXC__Module__c, SVMXC__Module__r.SVMXC__ModuleId__c, SVMXC__Description__c, SVMXC__ProcessID__c, SVMXC__Submodule__c, SVMXC__IsStandard__c, SVMXC__Name__c, SVMXC__Child_Object_Criteria__c, SVMXC__Parent_Object_Criteria__c';
        list<SVMXC__ServiceMax_Processes__c> lstSVMXPro = database.query('select ' + ProcessFields + ' from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c = \'PORD007\'');
        SVMXC__ServiceMax_Processes__c Inventory_Process = lstSVMXPro[0];
        
        //Scenario to Launch Page without url parameters id  
        PageReference pageRef1 = new PageReference('Page.SVMXC.CONF_ManageInventoryProcesses');
        pageRef1.getParameters().put('cid',Inventory_Process.Id);
        Test.setCurrentPageReference(pageRef1); 
        invobject2 = new SVMXC.CONF_ManageInventoryProcesses();
        system.assert(invobject2.getQtyFldlist()!=null,'getQtyFldlist assertion failed');
        system.assert(invobject2.getProRefFldlist()!=null,'getProRefFldlist assertion failed');
        system.assert(invobject2.getHdrReffldlist()!=null,'getHdrReffldlist assertion failed');
        system.assert(invobject2.getfldSourceLoc()!=null,'getfldSourceLoc assertion failed');
        system.assert(invobject2.getfldTargetLoc()!=null,'getfldTargetLoc assertion failed');       
        invobject2.selectedIndex = '1';
        //invobject2.RelatedCloserExpressions.lstExpressions.add(invobject2.HdrExpressions.lstExpressions[0]);
        //invobject2.RelatedCloserExpressions.lstExpressions[0].ObjectName = 'test';
        //invobject2.RetriveRefFld();   
    }

    static testMethod void CONF_ManageInventoryProcesses_UT4(){
        //Scenario to Launch Page without url parameters id  
        PageReference pageRef1 = new PageReference('Page.SVMXC.CONF_ManageInventoryProcesses');
        Test.setCurrentPageReference(pageRef1); 
        invobject3 = new SVMXC.CONF_ManageInventoryProcesses();
        invobject3.objSVMXPro.Parent_Object_Name = 'SVMXC__RMA_Shipment_Order__c';
        invobject3.objSVMXPro.Is_Multiline_Transaction = false;
        invobject3.getlstHdrStockHistoryFields();
        invobject3.getlstLineStockHistoryFields();
        invobject3.getlstProductFields();
        invobject3.getQtyFldlist();
        invobject3.getProRefFldlist();
        invobject3.getReferenceField();
        invobject3.objSVMXPro.Is_Multiline_Transaction = true;
        invobject3.objSVMXPro.Child_Object_Name = 'Contact';
        invobject3.getReferenceField();
        invobject3.getProRefFldlist();
        invobject3.objSVMXPro.Child_Object_Name = 'test';
        invobject3.getHdrReffldlist();
        System.assertEquals('test', invobject3.objSVMXPro.Child_Object_Name);
        System.assertEquals('SVMXC__RMA_Shipment_Order__c', invobject3.objSVMXPro.Parent_Object_Name);
    }
    
    // Ramachandra. Need to add this to dev org.
    static testMethod void CONF_ManageInventoryProcesses_Coverage(){
        
        invobject = new CONF_ManageInventoryProcesses();
        try {invobject.RetriveRefFld();} catch(Exception ex){}        
        invobject.getLongTextFields();
        //invobject.getrenderedValue();
        invobject.OnselectCurrentUser();
        invobject.OnselectRecordOwner();
        invobject.Linefind();
        invobject.LinefindDate();
        invobject.HdrCloserfind();
        invobject.HdrCloserfindDate();
        invobject.LineCloserfind();
        invobject.LineCloserfindDate();
        invobject.getTU();
        
        invobject.setLevalofhistorytrack('Stock History Only');
    }
}