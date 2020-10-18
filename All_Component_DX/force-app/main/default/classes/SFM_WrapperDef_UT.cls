@isTest
Private class SFM_WrapperDef_UT{

    static testMethod void SFM_WrapperDef_Test(){
    
        //*****Instance of classes and Object*****
        
        SVMXC__ServiceMax_Processes__c service_process = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Config_Data__c config_date = new SVMXC__ServiceMax_Config_Data__c ();
        SFM_WrapperDef wrapper = new SFM_WrapperDef();
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        SFM_WrapperDef.SFM_StringMap StringMap = new SFM_WrapperDef.SFM_StringMap();
        SFM_WrapperDef.SFM_StringFieldMap StringFieldMap = new SFM_WrapperDef.SFM_StringFieldMap();
        SFM_WrapperDef.SFM_StringListMap StringListMap =  new SFM_WrapperDef.SFM_StringListMap();
        SFM_WrapperDef.SFM_MapStringMap MapStringMap = new SFM_WrapperDef.SFM_MapStringMap();
        SFM_WrapperDef.SFM_UIButton ui_button = new SFM_WrapperDef.SFM_UIButton();
        SFM_WrapperDef.SFM_Request_ProcessNodeInfo ProcessNodeInfo = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo();
        SFM_WrapperDef.SFM_ProcessNodeDetail ProcessNodeDetail = new SFM_WrapperDef.SFM_ProcessNodeDetail();
        SFM_WrapperDef.SFM_BubbleWrapper BubbleWrapper = new SFM_WrapperDef.SFM_BubbleWrapper();
        SFM_WrapperDef.SFM_DetailBubbleWrapper DetailBubbleWrapper = new SFM_WrapperDef.SFM_DetailBubbleWrapper();
        SFM_WrapperDef.SFM_Response respon = new SFM_WrapperDef.SFM_Response();
        SFM_WrapperDef.SFM_Response_ProcessNodeInfo resp_procnodeinfo = new SFM_WrapperDef.SFM_Response_ProcessNodeInfo();
        SFM_WrapperDef.SFM_Request_ObjectMap req_objMap = new SFM_WrapperDef.SFM_Request_ObjectMap();
        SFM_WrapperDef.SFM_Request_PageList req_pageList = new SFM_WrapperDef.SFM_Request_PageList();
        SFM_WrapperDef.SFM_ObjectMap objMap = new SFM_WrapperDef.SFM_ObjectMap();
        SFM_WrapperDef.SFM_Response_ObjectMap resp_objMap = new SFM_WrapperDef.SFM_Response_ObjectMap();
        SFM_WrapperDef.SFM_Response_PageList resp_pageList = new SFM_WrapperDef.SFM_Response_PageList();
        SFM_WrapperDef.SFM_UIField ui_field= new SFM_WrapperDef.SFM_UIField();
        SFM_WrapperDef.SFM_UISection ui_section = new SFM_WrapperDef.SFM_UISection();
        SFM_WrapperDef.SFM_PageHeader page_header = new SFM_WrapperDef.SFM_PageHeader();
        SFM_WrapperDef.SFM_PageDetail page_detail = new SFM_WrapperDef.SFM_PageDetail();
        SFM_WrapperDef.SFM_PageUI page_ui = new SFM_WrapperDef.SFM_PageUI();
        SFM_WrapperDef.SFM_Request_PageUI req_page_ui = new SFM_WrapperDef.SFM_Request_PageUI();
        SFM_WrapperDef.SFM_NamedSearch name_search = new SFM_WrapperDef.SFM_NamedSearch();
        SFM_WrapperDef.SFM_Response_Expression resp_expression = new SFM_WrapperDef.SFM_Response_Expression();
        SFM_WrapperDef.SFM_Response_NamedSearchInfo name_searchinfo = new SFM_WrapperDef.SFM_Response_NamedSearchInfo();
        SFM_WrapperDef.SFM_TargetRecordObject targetrecobj = new SFM_WrapperDef.SFM_TargetRecordObject();
        SFM_WrapperDef.SFM_ToolbarGroup toolbar = new SFM_WrapperDef.SFM_ToolbarGroup();
        SFM_WrapperDef.SFM_TargetRecord targetrec = new SFM_WrapperDef.SFM_TargetRecord();
        SFM_WrapperDef.SFM_Response_Toolbar resp_toolbar = new SFM_WrapperDef.SFM_Response_Toolbar();
        SFM_WrapperDef.SFM_Response_ObjectMapLIst field_obj_map = new SFM_WrapperDef.SFM_Response_ObjectMapLIst();
        SFM_WrapperDef.SFM_LookUpConfigData lookup_confg = new SFM_WrapperDef.SFM_LookUpConfigData();
        SFM_WrapperDef.SFM_Response_ObjectFields res_ObjField = new SFM_WrapperDef.SFM_Response_ObjectFields();
        SFM_WrapperDef.SFM_Record Sfmrecord = new SFM_WrapperDef.SFM_Record();
        SFM_WrapperDef.SFM_Response_ObjectToolbarActions resp_ObjToolBarAct = new SFM_WrapperDef.SFM_Response_ObjectToolbarActions();
        SFM_WrapperDef.SFM_Response_ObjectToolbarActions res_objToolBarAct = new SFM_WrapperDef.SFM_Response_ObjectToolbarActions();
        SFM_WrapperDef.SFM_DetailDataSet  detailDataSet = new SFM_WrapperDef.SFM_DetailDataSet();
        SFM_WrapperDef.SFM_PageData  pageData = new SFM_WrapperDef.SFM_PageData();
        SFM_WrapperDef.SFM_PageDataSet PageDataSet = new SFM_WrapperDef.SFM_PageDataSet();
        
        //*****Data CReation and Lists of classes*****
        
        
        List<String> list_String = new List<String>();
        List<SVMXC__ServiceMax_Processes__c> list_process = new List<SVMXC__ServiceMax_Processes__c>();
        
        List<SVMXC__ServiceMax_Config_Data__c> list_config_data = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SFM_WrapperDef.SFM_StringMap> list_stringmap = new List<SFM_WrapperDef.SFM_StringMap>();
        List<SFM_WrapperDef.SFM_StringListMap> list_stringlistmap = new List<SFM_WrapperDef.SFM_StringListMap>();
        List<SFM_WrapperDef.SFM_MapStringMap> list_mapStringMap = new List<SFM_WrapperDef.SFM_MapStringMap>();
        List<SVMXC__ServiceMax_Processes__c> list_service_proc = new List<SVMXC__ServiceMax_Processes__c>();
        List<SFM_WrapperDef.SFM_FieldMapping> list_fieldMap = new List<SFM_WrapperDef.SFM_FieldMapping>();
        List<SFM_WrapperDef.SFM_ObjectMap> list_objMap = new List<SFM_WrapperDef.SFM_ObjectMap>();
        List<SFM_WrapperDef.SFM_Expression> list_expression = new List<SFM_WrapperDef.SFM_Expression>();
        List<SFM_WrapperDef.SFM_Object> globalObj = new List<SFM_WrapperDef.SFM_Object> ();
        List<SFM_WrapperDef.SFM_NamedSearchInfo> nameSearch = new List<SFM_WrapperDef.SFM_NamedSearchInfo>();
        List<SFM_WrapperDef.SFM_NamedSearchInfoDetail> namedSearchDetails = new List<SFM_WrapperDef.SFM_NamedSearchInfoDetail>();
        List<SObject> records = new List<SObject>();
        List<SFM_WrapperDef.SFM_SearchResult> searchResult = new List<SFM_WrapperDef.SFM_SearchResult>();
        List<SFM_WrapperDef.SFM_StringFieldMap> FieldMap = new List<SFM_WrapperDef.SFM_StringFieldMap>();
        
        
        SFM_WrapperDef.SFM_Request request_withPera = new SFM_WrapperDef.SFM_Request('userId','groupId','profileId',list_stringmap);
        SFM_WrapperDef.SFM_StringMap StringMap_withPera= new SFM_WrapperDef.SFM_StringMap('Key','Value');
        SFM_WrapperDef.SFM_StringMap StringMap_Test= new SFM_WrapperDef.SFM_StringMap('Key','Value','');
        SFM_WrapperDef.SFM_StringFieldMap StringFieldMap_withPera = new SFM_WrapperDef.SFM_StringFieldMap('key ','value ','ftype ');
        SFM_WrapperDef.SFM_StringListMap StringListMap_withPera =  new SFM_WrapperDef.SFM_StringListMap('key',list_String);
        SFM_WrapperDef.SFM_MapStringMap MapStringMap_withPera = new SFM_WrapperDef.SFM_MapStringMap('key',list_stringmap);
        SFM_WrapperDef.SFM_Request_ProcessNodeInfo ProcessNodeInfo_withPera = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo(ProcessNodeInfo.processNodes,ProcessNodeInfo.processNodeSourceObject,ProcessNodeInfo.processNodeTargetObject );
        SFM_WrapperDef.SFM_ProcessNodeDetail ProcessNodeDetail_withPera = new SFM_WrapperDef.SFM_ProcessNodeDetail(ProcessNodeDetail.processNodeObejct,ProcessNodeDetail.processSourceUpdates);
        SFM_WrapperDef.SFM_Response response_withPera = new SFM_WrapperDef.SFM_Response(true,'message','tagId',list_stringmap,respon.logMsg,list_String);
        SFM_WrapperDef.SFM_Response_ProcessNodeInfo resp_procnodeinfo_withPera = new SFM_WrapperDef.SFM_Response_ProcessNodeInfo(resp_procnodeinfo.processNodes ,resp_procnodeinfo.processNodeSourceObject ,resp_procnodeinfo.processNodeTargetObject );
        SFM_WrapperDef.SFM_Request_ObjectMap req_objMap_withPera = new SFM_WrapperDef.SFM_Request_ObjectMap(list_objMap);
        SFM_WrapperDef.SFM_ObjectMap objMap_withPera = new SFM_WrapperDef.SFM_ObjectMap(objMap.objectMap,list_fieldMap);
        SFM_WrapperDef.SFM_Response_ObjectMap res_objMap_withPera = new SFM_WrapperDef.SFM_Response_ObjectMap(list_objMap);
        SFM_WrapperDef.SFM_Request_PageList req_pageList_withPera = new SFM_WrapperDef.SFM_Request_PageList(req_pageList.PageList);
        SFM_WrapperDef.SFM_Response_PageList resp_pageList_withPera = new SFM_WrapperDef.SFM_Response_PageList(resp_pageList.PageList);
        SFM_WrapperDef.SFM_UIButton ui_button_withPera = new SFM_WrapperDef.SFM_UIButton(ui_button.buttonDetail,ui_button.buttonEvents );
        SFM_WrapperDef.SFM_UIField ui_field_withPera = new SFM_WrapperDef.SFM_UIField(ui_field.fieldDetail,ui_field.fieldEvents,ui_field.bubbleinfo);
        SFM_WrapperDef.SFM_PageHeader page_header_withPera = new SFM_WrapperDef.SFM_PageHeader(page_header.headerLayout,page_header.sections,page_header.buttons,page_header.pageEvents);
        SFM_WrapperDef.SFM_PageDetail page_detail_withpera = new SFM_WrapperDef.SFM_PageDetail(page_detail.DetailLayout,page_detail.fields,page_detail.buttons,page_detail.bubbleinfolist);
        SFM_WrapperDef.SFM_PageUI page_ui_withpera = new SFM_WrapperDef.SFM_PageUI(page_ui.header,page_ui.details);
        SFM_WrapperDef.SFM_Request_PageUI req_page_ui_withpera = new SFM_WrapperDef.SFM_Request_PageUI(req_page_ui.page,req_page_ui.processNode,req_page_ui.request );
        SFM_WrapperDef.SFM_Response_PageUI res_page_ui = new SFM_WrapperDef.SFM_Response_PageUI(req_page_ui.page );
        SFM_WrapperDef.SFM_NamedSearch name_search_withpera = new SFM_WrapperDef.SFM_NamedSearch(name_search.namedSearch,name_search.namedSearchDetails);
        SFM_WrapperDef.SFM_Response_NamedSearchInfo name_searchinfo_withpera = new SFM_WrapperDef.SFM_Response_NamedSearchInfo(name_searchinfo.namedSearch);
        SFM_WrapperDef.SFM_UISection ui_section_withPera = new SFM_WrapperDef.SFM_UISection(ui_section.sectionDetail,ui_section.fields);
        SFM_WrapperDef.SFM_Request_ProcessNode req_processNode = new SFM_WrapperDef.SFM_Request_ProcessNode(list_process);
        SFM_WrapperDef.SFM_Expression expression = new SFM_WrapperDef.SFM_Expression(service_process,list_config_data);
        SFM_WrapperDef.SFM_Request_Expression req_expression = new SFM_WrapperDef.SFM_Request_Expression(list_expression);
        SFM_WrapperDef.SFM_Response_Expression res_expression = new SFM_WrapperDef.SFM_Response_Expression(list_expression);
        SFM_WrapperDef.SFM_Object obj = new SFM_WrapperDef.SFM_Object(StringMap,list_stringmap);
        SFM_WrapperDef.SFM_Response_GlobalObjects resp_globObj = new SFM_WrapperDef.SFM_Response_GlobalObjects(globalObj);
        SFM_WrapperDef.SFM_Request_GlobalObjects req_globObj = new SFM_WrapperDef.SFM_Request_GlobalObjects(globalObj);
        SFM_WrapperDef.SFM_NamedSearchDetail name_searchDet = new SFM_WrapperDef.SFM_NamedSearchDetail(service_process,list_config_data,list_config_data);
        SFM_WrapperDef.SFM_Request_NamedSearch req_name_searchDet = new SFM_WrapperDef.SFM_Request_NamedSearch(list_service_proc);
        SFM_WrapperDef.SFM_Response_NamedSearch resp_name_searchDet = new SFM_WrapperDef.SFM_Response_NamedSearch(list_service_proc);
        SFM_WrapperDef.SFM_Request_NamedSearchInfo req_name_searchinfo = new SFM_WrapperDef.SFM_Request_NamedSearchInfo(nameSearch);
        SFM_WrapperDef.SFM_NamedSearchInfo SFM_name_searchinfo = new SFM_WrapperDef.SFM_NamedSearchInfo(service_process,namedSearchDetails);
        SFM_WrapperDef.SFM_NamedSearchInfoDetail SFM_name_searchinfodet = new SFM_WrapperDef.SFM_NamedSearchInfoDetail(service_process,list_config_data);
        SFM_WrapperDef.SFM_SearchResult SFM_name_searchResult = new SFM_WrapperDef.SFM_SearchResult('objectApiName',list_config_data);
        SFM_WrapperDef.SFM_Response_Search res_search = new SFM_WrapperDef.SFM_Response_Search(searchResult);
        SFM_WrapperDef.SFM_Response_RecordTypes res_recordType = new SFM_WrapperDef.SFM_Response_RecordTypes(records);
        SFM_WrapperDef.FieldProperties field_prop = new SFM_WrapperDef.FieldProperties('key');
        SFM_WrapperDef.FieldProperties field_prop_withWrp = new SFM_WrapperDef.FieldProperties('key','value',list_stringmap);
        SFM_WrapperDef.SFM_Response_ObjectMapLIst field_obj_map_withPara = new SFM_WrapperDef.SFM_Response_ObjectMapLIst(list_process);
        SFM_WrapperDef.bubble_wp bubble = new SFM_WrapperDef.bubble_wp(FieldMap);
        SFM_WrapperDef.SFM_Response_Toolbar res_toolbar_withPara = new SFM_WrapperDef.SFM_Response_Toolbar(resp_toolbar.toolbargroupLst);
        SFM_WrapperDef.SFM_Response_ProcessNode res_processNode = new SFM_WrapperDef.SFM_Response_ProcessNode(list_service_proc);
        SFM_WrapperDef.SFM_FieldMapping field_maping = new SFM_WrapperDef.SFM_FieldMapping(config_date,list_stringmap);
        
        
        //*****Calling method*****
        
        //*****SFM_Request*****
        request.getstringMap();
        request.setstringMap(list_stringmap);
        request.getstringListMap();
        request.setstringListMap(list_stringlistmap);
        System.assertEquals(true, request.getstringMap() != null);
        System.assertEquals(true, request.getstringListMap() != null);
        
        //*****SFM_StringListMap*****
        StringListMap.getvalueList();
        StringListMap.setvalueList(list_String);
        System.assertEquals(true, StringListMap.getvalueList() != null);
        
        //*****SFM_MapStringMap*****
        MapStringMap.getvalueList();
        MapStringMap.setvalueMap(list_stringmap);
        System.assertEquals(true, MapStringMap.getvalueList() != null);
        
        //*****SFM_Request_ProcessNodeInfo*****
        ProcessNodeInfo.getprocessNodes();
        System.assertEquals(true, ProcessNodeInfo.getprocessNodes() != null);
        ProcessNodeInfo.setprocessNodes(ProcessNodeInfo.processNodes );
        ProcessNodeInfo.getprocessprocessNodeSourceObject();
        System.assertEquals(true, ProcessNodeInfo.getprocessprocessNodeSourceObject() != null);
        ProcessNodeInfo.setprocessNodeSourceObject(ProcessNodeInfo.processNodeSourceObject );
        ProcessNodeInfo.getprocessNodeTargetObject();
        System.assertEquals(true, ProcessNodeInfo.getprocessNodeTargetObject() != null);
        ProcessNodeInfo.setprocessNodeTargetObject(ProcessNodeInfo.processNodeTargetObject );
        
        //*****SFM_ProcessNodeDetail*****
        ProcessNodeDetail.getprocessNodeObejct();
        System.assertEquals(true, ProcessNodeDetail.getprocessNodeObejct() != null);
        ProcessNodeDetail.setprocessNodeObejct(ProcessNodeDetail.processNodeObejct);
        ProcessNodeDetail.getprocessSourceUpdates();
        System.assertEquals(true, ProcessNodeDetail.getprocessSourceUpdates() != null);
        ProcessNodeDetail.setprocessSourceUpdates(ProcessNodeDetail.processSourceUpdates);
        
        //*****SFM_Response*****
        respon.getstringMap();
        System.assertEquals(true, respon.getstringMap() != null);
        respon.setstringMap(list_stringmap);
        respon.getStringLstMap();
        System.assertEquals(true, respon.getStringLstMap() != null);
        respon.setStringLstMap(list_stringlistmap);
        respon.getMapStringMap();
        System.assertEquals(true, respon.getMapStringMap() != null);
        respon.setMapStringMap(list_mapStringMap);
        
        //*****SFM_Response_ProcessNodeInfo*****
        resp_procnodeinfo.getprocessNodes();
        System.assertEquals(true, resp_procnodeinfo.getprocessNodes() != null);
        resp_procnodeinfo.setprocessNodes(resp_procnodeinfo.processNodes);
        resp_procnodeinfo.getprocessprocessNodeSourceObject();
        System.assertEquals(true, resp_procnodeinfo.getprocessprocessNodeSourceObject() != null);
        resp_procnodeinfo.setprocessNodeSourceObject(resp_procnodeinfo.processNodeSourceObject );
        resp_procnodeinfo.getprocessNodeTargetObject();
        System.assertEquals(true, resp_procnodeinfo.getprocessNodeTargetObject() != null);
        resp_procnodeinfo.setprocessNodeTargetObject(resp_procnodeinfo.processNodeTargetObject );
        
        //*****SFM_Request_ObjectMap*****
        req_objMap.getobjects();
        System.assertEquals(true, req_objMap.getobjects() != null);
        req_objMap.setobjects(list_objMap);
        
        //*****SFM_ObjectMap*****
        objMap.getobjectMap();
        System.assertEquals(true, objMap.getobjectMap() != null);
        objMap.setobjectMap(objMap.objectMap);
        objMap.fields();
        System.assertEquals(true, objMap.fields() != null);
        objMap.fields(list_fieldMap);
        
        //*****SFM_Response_ObjectMap*****
        resp_objMap.getobjects();
        System.assertEquals(true, resp_objMap.getobjects() != null);
        resp_objMap.setobjects(list_objMap);
        
        //*****SFM_Request_PageList*****
        req_pageList.getPageList();
        System.assertEquals(true, req_pageList.getPageList() != null);
        req_pageList.setPageList(req_pageList.PageList);
        
        //*****SFM_Response_PageList*****
        resp_pageList.getPageList();
        System.assertEquals(true, resp_pageList.getPageList() != null);
        resp_pageList.setPageList(resp_pageList.PageList);
        
        //*****SFM_UISection*****
        ui_section.getsectionDetail();
        System.assertEquals(true, ui_section.getsectionDetail() != null);
        ui_section.setsectionDetail(ui_section.sectionDetail);
        ui_section.getfields();
        System.assertEquals(true, ui_section.getfields() != null);
        ui_section.setfields(ui_section.fields );
        
        //*****SFM_TargetRecordObject*****
        targetrecobj.getrecords();
        System.assertEquals(true, targetrecobj.getrecords() != null);
        targetrecobj.setrecords(targetrecobj.records);
        targetrecobj.getdeleteRecID();
        System.assertEquals(true, targetrecobj.getdeleteRecID() != null);
        targetrecobj.setdeleteRecID(targetrecobj.deleteRecID);
        
        //*****SFM_TargetRecordObject*****
        targetrec.getheaderRecord();
        System.assertEquals(true, targetrec.getheaderRecord() != null);
        targetrec.setheaderRecord(targetrec.headerRecord);
        targetrec.getdetailRecords();
        System.assertEquals(true, targetrec.getdetailRecords() != null);
        targetrec.setdetailRecords(targetrec.detailRecords);
        
        //*****SFM_Request_ProcessNode*****
        req_processNode.getprocessNodes();
        System.assertEquals(true, req_processNode.getprocessNodes() != null);
        req_processNode.setprocessNodes(req_processNode.processNodes);
        
        //*****SFM_Expression*****
        expression.getnamedExpression();
        System.assertEquals(true, expression.getnamedExpression() != null);
        expression.setnamedExpression(service_process);
        expression.getexpressionDetails();
        System.assertEquals(true, expression.getexpressionDetails() != null);
        expression.setexpressionDetails(list_config_data);
        
        //*****SFM_Request_Expression*****
        req_expression.getexpressions();
        System.assertEquals(true, req_expression.getexpressions() != null);
        req_expression.setexpressions(list_expression);
        
        //*****SFM_Response_Expression*****
        res_expression.getexpressions();
        System.assertEquals(true, res_expression.getexpressions() != null);
        res_expression.setexpressions(list_expression);
        
        //*****SFM_Response_Toolbar*****
        resp_toolbar.gettoolbargroupLst();
        System.assertEquals(true, resp_toolbar.gettoolbargroupLst() != null);
        resp_toolbar.settoolbargroupLst(resp_toolbar.toolbargroupLst);
        
        //*****SFM_Record*****
        Sfmrecord.gettargetRecordAsKeyValue();
        System.assertEquals(true, Sfmrecord.gettargetRecordAsKeyValue() != null);
        Sfmrecord.settargetRecordAsKeyValue(Sfmrecord.targetRecordAsKeyValue);
        
        //*****SFM_Response_ProcessNode*****
        res_processNode.getprocessNodes();
        System.assertEquals(true, res_processNode.getprocessNodes() != null);
        res_processNode.setprocessNodes(list_service_proc);
        
        //*****SFM_PageDataSet*****
        PageDataSet.getbubbleInfo();
        PageDataSet.setbubbleInfo(PageDataSet.bubbleInfo);
        
        //*****SFM_DetailDataSet*****
        detailDataSet.getpageDataSet();
        detailDataSet.setpageDataSet(detailDataSet.pageDataSet);
        
        //*****SFM_PageData*****
        pageData.getpageDataSet();
        
        pageData.setpageDataSet(pageData.pageDataSet);
        pageData.getdetailDataset();
        
        pageData.setdetailDataset(pageData.detailDataset);
        
        /////////////////////
        SFM_WrapperDef.SVMXMessage objSVMXMessage = new SFM_WrapperDef.SVMXMessage('a','s','d');
        SFM_WrapperDef.SVMXMessage objSVMXMessage1 = new SFM_WrapperDef.SVMXMessage('a','s');
        request.setbizRuleInfo(new SFM_WrapperDef.SFM_BizRuleInfo());
        request.getbizRuleInfo();       
        respon.setstringFieldMap(new List<SFM_WrapperDef.SFM_StringFieldMap>());
        respon.getstringFieldMap();
        respon.getsobjectMap();
        respon.getlstFieldSetWithSorting();
        respon.setlstFieldSetWithSorting(new list<SFM_WrapperDef.FieldSetWithSorting>());
        respon.getlstBizRuleInfo();
        respon.setlstBizRuleInfo(new List<SFM_WrapperDef.SFM_BizRuleInfo>());
        ProcessNodeInfo.setSFMEvents(new list<SVMXC__SFM_Event__c>());
        resp_procnodeinfo.getSFMEvents();
        ProcessNodeDetail.getprocessBizRules();
        ProcessNodeDetail.setprocessBizRules(new List<SVMXC__ServiceMax_Processes__c>());
        ProcessNodeDetail.getlinkedProcesses();
        ProcessNodeDetail.setlinkedProcesses(new List<SVMXC__ServiceMax_Processes__c>());
        field_maping.sourceFieldsConstant();
        field_maping.sourceFieldsConstant(new List<SFM_WrapperDef.SFM_StringMap>());
        SFM_WrapperDef.linkedProcessDetail objlinkedProcessDetail = new SFM_WrapperDef.linkedProcessDetail();
        SFM_WrapperDef.linkedProcessDetail objlinkedProcessDetail1 = new SFM_WrapperDef.linkedProcessDetail(1,'s','x');
        SFM_WrapperDef.FieldProperties objFieldProperties = new SFM_WrapperDef.FieldProperties('d','s');
        SFM_WrapperDef.SFM_LookupDefinition objSFM_LookupDefinition = new SFM_WrapperDef.SFM_LookupDefinition();
        
        SVMXC__ServiceMax_Processes__c objproces = new SVMXC__ServiceMax_Processes__c();
        objproces.SVMXC__Source_Object_Name__c = 'test';
        SFM_WrapperDef.SFM_LookupDefinition objSFM_LookupDefinition1 = new SFM_WrapperDef.SFM_LookupDefinition(objproces,new list<SVMXC__ServiceMax_Config_Data__c>());
        SFM_WrapperDef.SFM_LookupDefinitionDetail objSFM_LookupDefinitionDetail = new SFM_WrapperDef.SFM_LookupDefinitionDetail();
        objSFM_LookupDefinitionDetail.getdisplayFields();
        objSFM_LookupDefinitionDetail.setdisplayFields(new list<SFM_WrapperDef.SFM_FieldDefinition>());
        objSFM_LookupDefinitionDetail.getsearchFields();
        objSFM_LookupDefinitionDetail.setsearchFields(new list<SFM_WrapperDef.SFM_FieldDefinition>());
        objSFM_LookupDefinitionDetail.getbubbleFields();
        objSFM_LookupDefinitionDetail.setbubbleFields(new list<SFM_WrapperDef.SFM_FieldDefinition>());
        SFM_WrapperDef.SFM_FieldDefinition obj11 = new SFM_WrapperDef.SFM_FieldDefinition();
        SFM_WrapperDef.FieldSetInfo obj232 = new SFM_WrapperDef.FieldSetInfo('qq','ww');
        SFM_WrapperDef.SortingRec objdj = new SFM_WrapperDef.SortingRec();
        SFM_WrapperDef.SFM_BizRuleInfo objBrule = new SFM_WrapperDef.SFM_BizRuleInfo();
        objBrule.getbizRule();
        objBrule.setbizRule(new SVMXC__ServiceMax_Processes__c());
        objBrule.getbizRuleDetails();
        objBrule.setbizRuleDetails(new List<SVMXC__ServiceMax_Config_Data__c>());     
        SFM_WrapperDef.SFM_ProcessBusinessRule objprBus = new SFM_WrapperDef.SFM_ProcessBusinessRule();
        objprBus.getruleInfo();
        objprBus.setruleInfo(new SFM_WrapperDef.SFM_BizRuleInfo());
        SFM_WrapperDef.ExecutionTimeProfileDetail objexe = new SFM_WrapperDef.ExecutionTimeProfileDetail(System.now(), System.now(), 'sdd');
        SFM_WrapperDef.ExecutionTimeProfileDetail objexe1 = new SFM_WrapperDef.ExecutionTimeProfileDetail();
        SFM_WrapperDef.ProfileData objproda = new SFM_WrapperDef.ProfileData(new List<SFM_WrapperDef.ExecutionTimeProfileDetail>());
        /////////////////////
        
        ///--------------
        SFM_WrapperDef.SFM_QuestionBank objSFM_QuestionBank = new SFM_WrapperDef.SFM_QuestionBank();
        SFM_WrapperDef.SFM_QuestionBank objSFM_QuestionBank1 = new SFM_WrapperDef.SFM_QuestionBank(new SVMXC__Question_Bank__c(), new List<SVMXC__QB_Response_Options__c>());
        objSFM_QuestionBank.setquestion(new SVMXC__Question_Bank__c());
        objSFM_QuestionBank.getquestion();
        objSFM_QuestionBank.setquestionBankResponseOptions(new List<SVMXC__QB_Response_Options__c>());
        objSFM_QuestionBank.getquestionBankResponseOptions();
        
        SFM_WrapperDef.SFM_Question objSFM_Question = new SFM_WrapperDef.SFM_Question();
        objSFM_Question.questionID = '';
        objSFM_Question.question = '';
        objSFM_Question.description = '';
        objSFM_Question.responseType = '';
        objSFM_Question.active = true;
        objSFM_Question.precision = 1.0;
        objSFM_Question.scale = 1.0;
        objSFM_Question.length = 1.0;
        objSFM_Question.captureComments = true;
        objSFM_Question.questionJSON = '';
        objSFM_Question.shortname = '';
        SFM_WrapperDef.SFM_QuestionResponse objSFM_QuestionResponse = new SFM_WrapperDef.SFM_QuestionResponse();
        objSFM_QuestionResponse.questionID = '';
        objSFM_QuestionResponse.response = '';
        objSFM_QuestionResponse.active = true;
        objSFM_QuestionResponse.sequence = 1.0;
        SFM_WrapperDef.SFM_QuestionInfo objSFM_QuestionInfo = new SFM_WrapperDef.SFM_QuestionInfo();
        List<SFM_WrapperDef.SFM_QuestionResponse> lst = new List<SFM_WrapperDef.SFM_QuestionResponse>();
        lst.add(objSFM_QuestionResponse);
        SFM_WrapperDef.SFM_QuestionInfo objSFM_QuestionInfo1 = new SFM_WrapperDef.SFM_QuestionInfo(objSFM_Question, lst);
        objSFM_QuestionInfo1.setquestion(objSFM_Question);
        objSFM_QuestionInfo1.getquestion();
        objSFM_QuestionInfo1.setquestionResponses(lst);
        objSFM_QuestionInfo1.getquestionResponses();
        ///-----------
        
        
        request.getFieldUpdateRuleInfoList();
        request.setFieldUpdateRuleInfoList(new List<SFM_WrapperDef.SFM_FieldUpdateRuleInfo>());
        request.setQuestionValidationRuleInfo(new SFM_WrapperDef.SFM_QuestionValidationRuleInfo ());
        request.getQuestionValidationRuleInfo();
        SFM_WrapperDef.SFM_QuestionValidationRuleInfo  objChecklistValRule = new SFM_WrapperDef.SFM_QuestionValidationRuleInfo ();
        SFM_WrapperDef.SFM_QuestionValidationRuleInfo  objChecklistValRule1 = new SFM_WrapperDef.SFM_QuestionValidationRuleInfo ( new SVMXC__ServiceMax_Processes__c(),new List<SVMXC__ServiceMax_Config_Data__c>());
        objChecklistValRule.getQuestionValidationRule();
        objChecklistValRule.getlstQuestionValidationRuleDetails();
        objChecklistValRule.setQuestionValidationRule( new SVMXC__ServiceMax_Processes__c());
        objChecklistValRule.setlstQuestionValidationRuleDetails( new List<SVMXC__ServiceMax_Config_Data__c>());
        
        //------------
        
        SFM_WrapperDef.SFM_Request_IntegrityCheck objSFM_Request_IntegrityCheck = new SFM_WrapperDef.SFM_Request_IntegrityCheck();
        SFM_WrapperDef.SFM_Request_ObjectFields objSFM_Request_ObjectFields = new SFM_WrapperDef.SFM_Request_ObjectFields();
        SFM_WrapperDef.SFM_Request_FieldProperties objSFM_Request_FieldProperties = new SFM_WrapperDef.SFM_Request_FieldProperties();
        SFM_WrapperDef.SFM_Request_FieldProperties objSFM_Request_FieldProperties1= new SFM_WrapperDef.SFM_Request_FieldProperties('','',11,'','',false);
        respon.setsobjectMap(new list<SFM_WrapperDef.SFM_StringSobjectMap>());
        //respon.getChecklistValidationRuleInfo();
        respon.getlstQuestionBank();
        respon.getlstChecklistInfo();
        respon.getFieldUpdateRuleInfoList();
         SFM_WrapperDef.SFM_Request_ProcessNodeInfo ProcessNodeInfo_withPera1 = new SFM_WrapperDef.SFM_Request_ProcessNodeInfo(ProcessNodeInfo.processNodes,new List<SFM_WrapperDef.SFM_ProcessNodeDetail>(),new List<SFM_WrapperDef.SFM_ProcessNodeDetail>(),new list<SVMXC__SFM_Event__c> ());
         
         //--------------
         
         
         SFM_WrapperDef.SFM_ChecklistInfo objSFM_ChecklistInfo= new SFM_WrapperDef.SFM_ChecklistInfo();
          SFM_WrapperDef.SFM_ChecklistInfo objSFM_ChecklistInfo1= new SFM_WrapperDef.SFM_ChecklistInfo('','','','', '', '', System.today());
          
          SFM_WrapperDef.SFM_ChecklistInfo objSFM_ChecklistInfo2= new SFM_WrapperDef.SFM_ChecklistInfo('','','','', '', '', System.today(),'');
          
          //--------------------
            SFM_WrapperDef.SFM_BizRuleInfo objSFM_BizRuleInfo12= new SFM_WrapperDef.SFM_BizRuleInfo(new SVMXC__ServiceMax_Processes__c(), new List<SVMXC__ServiceMax_Config_Data__c> ());
          //---------------------
          SFM_WrapperDef.FieldSetWithSorting objFieldSetWithSorting= new SFM_WrapperDef.FieldSetWithSorting();
          
          SFM_WrapperDef.FieldSetWithSorting objFieldSetWithSorting1= new SFM_WrapperDef.FieldSetWithSorting(new list<String>() ,new list<SFM_WrapperDef.SortingRec>(),null,null,null,null);
          //---------------------
          SFM_WrapperDef.SortingRec objSortingRec= new SFM_WrapperDef.SortingRec();
          SFM_WrapperDef.SortingRec objSortingRec1= new SFM_WrapperDef.SortingRec('','','','','','','');
          
          
          //---------------------
          
          SFM_WrapperDef.FieldsetDefinition objFieldsetDefinition2= new SFM_WrapperDef.FieldsetDefinition('',new list<SFM_WrapperDef.FieldSetInfo>());
          
          
          //---------------------
          SFM_WrapperDef.SFM_LookupRequest objSFM_LookupRequest = new SFM_WrapperDef.SFM_LookupRequest();
                  
          //---------------------
          SFM_WrapperDef.SFM_FieldDefinition objSFM_FieldDefinition1 = new SFM_WrapperDef.SFM_FieldDefinition();
          SFM_WrapperDef.SFM_FieldDefinition objSFM_FieldDefinition2 = new SFM_WrapperDef.SFM_FieldDefinition(new SVMXC__ServiceMax_Config_Data__c());
                  
          //---------------------
          
          SFM_WrapperDef.SFM_AdvCrieteriaDefinition objSFM_AdvCrieteriaDefinition2= new SFM_WrapperDef.SFM_AdvCrieteriaDefinition(new SVMXC__ServiceMax_Processes__c (), new list<SVMXC__ServiceMax_Config_Data__c> ());
                  
          //---------------------
          
          SFM_WrapperDef.SFM_DocTemplate objSFM_DocTemplate = new SFM_WrapperDef.SFM_DocTemplate();
          SFM_WrapperDef.SFM_DocTemplate objSFM_DocTemplate2= new SFM_WrapperDef.SFM_DocTemplate(new SVMXC__Doc_Template__c (), new list<SVMXC__Doc_Template_Details__c> (), new Attachment (), '');
          
          
          //---------------------
          
          SFM_WrapperDef.SFM_StringSobjectMap objSFM_StringSobjectMap = new SFM_WrapperDef.SFM_StringSobjectMap();
          SFM_WrapperDef.SFM_StringSobjectMap objSFM_StringSobjectMap2= new SFM_WrapperDef.SFM_StringSobjectMap('',new list<Sobject>());
          SFM_WrapperDef.SFM_StringSobjectMap objSFM_StringSobjectMap3= new SFM_WrapperDef.SFM_StringSobjectMap('','',new list<Sobject>());
          
          
          //---------------------
          SFM_WrapperDef.SFM_ProcessBusinessRule objSFM_ProcessBusinessRule= new SFM_WrapperDef.SFM_ProcessBusinessRule(1, '', '', new SFM_WrapperDef.SFM_BizRuleInfo ());
          //---------------------
          SFM_WrapperDef.SFM_FieldUpdateRuleInfo objSFM_FieldUpdateRuleInfo = new SFM_WrapperDef.SFM_FieldUpdateRuleInfo();
          objSFM_FieldUpdateRuleInfo.getFieldUpdateRule();
          objSFM_FieldUpdateRuleInfo.setFieldUpdateRule( new SVMXC__ServiceMax_Processes__c());
          objSFM_FieldUpdateRuleInfo.getFieldUpdateRuleDetails( );
          objSFM_FieldUpdateRuleInfo.setFieldUpdateRuleDetails( new List<SVMXC__ServiceMax_Config_Data__c>( ));
          //-------------------
          SFM_WrapperDef.SFM_QuestionBank objSFM_QuestionBank2 = new SFM_WrapperDef.SFM_QuestionBank();
          objSFM_QuestionBank2.setquestionResponseSet(new SVMXC__QB_Response_Set__c());
          //objSFM_QuestionBank2.getchecklistValidationRuleInfo();
            //ojSFM_QuestionBank2.getquestionResponseSet();
            //objSFM_QuestionBank2.setchecklistValidationRuleInfo(new SFM_WrapperDef.SFM_QuestionValidationRuleInfo ());
            SFM_WrapperDef.SFM_ChecklistInfo obj12 = new SFM_WrapperDef.SFM_ChecklistInfo('','','','');
            SFM_WrapperDef.SFM_Question objSFM_Question2 = new SFM_WrapperDef.SFM_Question();
            objSFM_Question2.helpURL = '';
            SFM_WrapperDef.SFM_QuestionBank obj13 = new SFM_WrapperDef.SFM_QuestionBank(new SVMXC__Question_Bank__c (), new List<SVMXC__QB_Response_Options__c> (), new SVMXC__QB_Response_Set__c ());
            SFM_WrapperDef.SFM_QuestionBank obj14 = new SFM_WrapperDef.SFM_QuestionBank(new SVMXC__Question_Bank__c(), new List<SVMXC__QB_Response_Options__c> (), new SVMXC__QB_Response_Set__c(), new List<String> ());
            SFM_WrapperDef.SFM_QuestionBank obj15 = new SFM_WrapperDef.SFM_QuestionBank(new SVMXC__Question_Bank__c (), new List<SVMXC__QB_Response_Options__c> (), new SVMXC__QB_Response_Set__c (), new List<String> (),new SFM_WrapperDef.SFM_QuestionValidationRuleInfo  ());
            /*SFM_WrapperDef.ProfileDetails objProfileDetails3 = new SFM_WrapperDef.ProfileDetails('','','');
            SFM_WrapperDef.SFM_LookupRequest objSFM_LookupRequest1 = new SFM_WrapperDef.SFM_LookupRequest('','','');
            objSFM_LookupRequest1.lookupDef = new SFM_WrapperDef.SFM_LookupDefinition();
            objSFM_LookupRequest1.contextMatchField ='';
            objSFM_LookupRequest1.contextValue ='';
            objSFM_LookupRequest1.operator ='';
            objSFM_LookupRequest1.Keyword ='';
            SVMXC__ServiceMax_Config_Data__c ConfigData1 = new SVMXC__ServiceMax_Config_Data__c();
            ConfigData1.SVMXC__Field_Name__c = 'SVMXC__Completed_Date_Time__c';
            ConfigData1.SVMXC__Display_Type__c = 'DATETIME'; 
            ConfigData1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
            ConfigData1.SVMXC__FKey_Name_Field__c='';
            ConfigData1.SVMXC__Field_Relationship_Name__c=''; 
            ConfigData1.SVMXC__Sequence__c = '1';
            ConfigData1.SVMXC__Parameter_Type__c  ='Value';*/
            
        //
        
    }
}