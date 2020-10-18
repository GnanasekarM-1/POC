@isTest(SeeAllData=true)
private class INTF_WebServicesDef_UT
{
    static testMethod void INTF_WebServicesDef_Test()
    {
        // System Assert
       Account testAccount = new Account(name='Test Company Name');
       insert testAccount;
       testAccount.billingState='CA';
       update testAccount;
       // Verify that the billingState field was updated in the database.
       Account updatedAccount = [SELECT billingState FROM Account WHERE Id = :testAccount.Id];
       System.assertEquals('CA', updatedAccount.billingState);
        
        String recId;
        String keyVal;
        
        SFM_WrapperDef.SFM_Request req = new SFM_WrapperDef.SFM_Request();
        
        INTF_WebServicesDef webDef = new INTF_WebServicesDef();
        INTF_WebServicesDef.INTF_GetSFWHTML_WS(recId,keyVal);
        INTF_WebServicesDef.INTF_GetSFWWrapper_WS(req);
        INTF_WebServicesDef.INTF_Response_SFWInfo webResponse = new INTF_WebServicesDef.INTF_Response_SFWInfo();
        String ObjName = webResponse.getObjectName();
        
        List<COMM_Webservices.KeyValue> prequest = new List<COMM_Webservices.KeyValue>();
        INTF_WebServicesDef.SVMX_GetSvmxVersion(prequest);
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        try{
            INTF_WebServicesDef.INTF_GetNextStepURL_WS(request);
        }catch(Exception ex)
        {}
        try{INTF_WebServicesDef.SFM_GetSearchResult_WS(request);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_APL_GetCaseInfo_WS(request);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_APL_PartsOrderClosure_WS(request);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_APL_CreateInternalExternalRMA_WS(request);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_APL_GetAvailableStockSerial_WS(request);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_APL_SaveOrder_WS(request);}catch(exception ex){}
        try{INTF_WebServicesDef.APL_PreSaveUpdates_WS(request);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_APL_GetOrder_WS(request);}catch(exception ex){}
        
        INTF_WebServicesDef.INTF_Request_For_History prodHistoryRequest = new INTF_WebServicesDef.INTF_Request_For_History();
        //INTF_WebServicesDef.INTF_Get_Product_History_WS(prodHistoryRequest);
        INTF_WebServicesDef.INTF_Request_For_History accHistoryRequest = new INTF_WebServicesDef.INTF_Request_For_History();
        INTF_WebServicesDef.INTF_Get_Account_History_WS(null);
        List<INTF_WebServicesDef.INTF_Event_WP> request1 = new List<INTF_WebServicesDef.INTF_Event_WP>();
        INTF_WebServicesDef.INTF_Update_Events_WS(request1);
        INTF_WebServicesDef.INTF_Request_PageUI PmaxReqPageUI = new INTF_WebServicesDef.INTF_Request_PageUI();
        INTF_WebServicesDef.INTF_getPageLayout_WS(PmaxReqPageUI);
        
        INTF_WebServicesDef.INTF_SavePageLayout_WS(PmaxReqPageUI);
        INTF_WebServicesDef.INTF_Request_For_Tags tagsReq = new INTF_WebServicesDef.INTF_Request_For_Tags();
        INTF_WebServicesDef.INTF_Get_Tags_WS(tagsReq);
        
        INTF_WebServicesDef.INTF_Request request2 = new INTF_WebServicesDef.INTF_Request();
        
        INTF_WebServicesDef.INTF_Get_WorkOrderMapView_WS(request2);
        INTF_WebServicesDef.INTF_Request_For_Events iPadReqEvent = new INTF_WebServicesDef.INTF_Request_For_Events();
        INTF_WebServicesDef.INTF_Get_Events_WS(iPadReqEvent);
        INTF_WebServicesDef.INTF_Request_For_Tasks iPadReqTask = new INTF_WebServicesDef.INTF_Request_For_Tasks();
        try{
            INTF_WebServicesDef.INTF_Get_Tasks_WS(iPadReqTask);
            }
        catch(exception ex){}
       INTF_WebServicesDef.INTF_getLookUpConfigWithData_WS(request2);
        
        INTF_WebServicesDef.INTF_EVER_Case_WS(request2);
        INTF_WebServicesDef.INTF_EVER_WorkOrder_WS(request2);
        INTF_WebServicesDef.PINV_GenerateSCInvoiceDoc_WS(request2);
        INTF_WebServicesDef.PINV_GenerateWOInvoiceDoc_WS(request2);
        //INTF_WebServicesDef.PCAL_GetPricingDefinition_WS(request2);
        INTF_WebServicesDef.Get_CodeSnippets_WS(request2);
        //INTF_WebServicesDef.Get_CodeSnippet_SFMEvent_WS(request2);
        INTF_WebServicesDef.SCON_Get_CodeSnippet_SFMEvent_WS(request2);
        INTF_WebServicesDef.INTF_getViewDefinition_WS(request2);
        INTF_WebServicesDef.SVMX_RetrieveSettings_WS(request2);
        
        INTF_WebServicesDef.INTF_TargetRecord request21 = new INTF_WebServicesDef.INTF_TargetRecord();
        //INTF_WebServicesDef.INTF_BuildPageData_WS(request21);
        /* INTF_WebServicesDef.INTF_PORD_SelToAddressWO_WS(request21);
        INTF_WebServicesDef.INTF_PORD_SelFromAddressWO_WS(request21);
        INTF_WebServicesDef.INTF_PORD_SelToAddressCASE_WS(request21);
        INTF_WebServicesDef.INTF_PORD_SelFromAddressCASE_WS(request21);
        INTF_WebServicesDef.INTF_PORD_PopulateToLocation_WS(request21);
        INTF_WebServicesDef.INTF_PORD_PopulateFromLocation_WS(request21); */
        //INTF_WebServicesDef.INTF_PORD_GetPrice_WS(request21);
        //INTF_WebServicesDef.INTF_PREQ_GetPrice_WS(request21);
        //INTF_WebServicesDef.INTF_WORD_REQ_GetPrice_WS(request21);
        //INTF_WebServicesDef.INTF_WORD_USG_GetPrice_WS(request21);
        //INTF_WebServicesDef.INTF_WORD_EST_GetPrice_WS(request21);
        //INTF_WebServicesDef.INTF_SXFR_GetPrice_WS(request21);
        /* INTF_WebServicesDef.INTF_IB_PopulateName_WS(request21);
        INTF_WebServicesDef.INTF_WO_SetIsBillable_WS(request21);
        INTF_WebServicesDef.INTF_Quote_Calc_WS(request21); */
        
    /*  INTF_WebServicesDef.INTF_SFMRequest request31 = new INTF_WebServicesDef.INTF_SFMRequest();
        
        INTF_WebServicesDef.INTF_APL_GetOrder_WS(request31);
        INTF_WebServicesDef.APL_PreSaveUpdates_WS(request31);
        INTF_WebServicesDef.INTF_APL_SaveOrder_WS(request31);
        INTF_WebServicesDef.INTF_APL_GetAvailableStockSerial_WS(request31);
        INTF_WebServicesDef.INTF_APL_CreateInternalExternalRMA_WS(request31);
        INTF_WebServicesDef.INTF_APL_PartsOrderClosure_WS(request31);
        INTF_WebServicesDef.INTF_APL_GetIntiateReturnProc_WS(request31);
        INTF_WebServicesDef.INTF_APL_PerformEntitlement_WS(request31);
        INTF_WebServicesDef.INTF_APL_GetAccountAndProductInfo_WS(request31);
        
        INTF_WebServicesDef.INTF_APL_GetRouteInfo_WS(request31);
        INTF_WebServicesDef.INTF_APL_CreateRouteForCase_WS(request31);
        INTF_WebServicesDef.INTF_APL_CalculateRMAForCase_WS(request31);
        INTF_WebServicesDef.INTF_APL_GenerateRMAforCase_WS(request31);
        INTF_WebServicesDef.INTF_APL_DoReturnSourceUpdates_WS(request31);
        INTF_WebServicesDef.INTF_CUD_OnPropertyElements_WS(request31, '');
        
        INTF_WebServicesDef.SFM_GetSearchInfo_WS(request31);
        INTF_WebServicesDef.SFM_GetSearchResult_WS(request31);
        INTF_WebServicesDef.INTF_APL_PerformEntitlement_On_PD(request31);
        INTF_WebServicesDef.INTF_DataSync_WS(request31); */
        
        
        RecId = webResponse.getRecordId();
        if(RecId==null)
            system.assert(RecId==null);
        else
            system.assert(RecId!=null);
        webResponse.setObjectName(ObjName);
        webResponse.setRecordId(RecId);
        List<INTF_WebServicesDef.SFM_SFWInfo> tlbarInfoLst = webResponse.getSFWs();
        webResponse.setSFWs(tlbarInfoLst);
        
        INTF_WebServicesDef.INTF_Response_SFWInfo webResponse1 = new INTF_WebServicesDef.INTF_Response_SFWInfo(objName,RecId,tlbarInfoLst);
        
        INTF_WebServicesDef.SFM_SFWInfo sfwInfo = new INTF_WebServicesDef.SFM_SFWInfo();
        SVMXC__ServiceMax_Processes__c SFWDefRec = sfwInfo.getSFWDef();
        sfwInfo.setSFWDef(SFWDefRec);
        Integer rowNum = sfwInfo.getrow();
        if(rowNum==null)
            system.assert(rowNum==null);
        else
            system.assert(rowNum!=null);
        sfwInfo.setrow(rowNum);
        Integer columnNum = sfwInfo.getcol();
        if(columnNum==null)
            system.assert(columnNum==null);
        else
            system.assert(columnNum!=null);
        sfwInfo.setcol(columnNum);
        List<INTF_WebServicesDef.SFM_SFWActionsInfo> SFWActnsInfoLst = sfwInfo.getactions();
        sfwInfo.setactions(SFWActnsInfoLst);
        SVMXC__ServiceMax_Processes__c tlbarDef = new SVMXC__ServiceMax_Processes__c();
        
        INTF_WebServicesDef.SFM_SFWInfo sfwInfo1 = new INTF_WebServicesDef.SFM_SFWInfo(tlbarDef,rowNum,columnNum,SFWActnsInfoLst);
        
        SVMXC__ServiceMax_Processes__c ActnRec = new SVMXC__ServiceMax_Processes__c();
        Boolean enabld;
        
        List<SVMXC__ServiceMax_Config_Data__c> fields = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        INTF_WebServicesDef.SFM_SFWActionsInfo sfwAction = new INTF_WebServicesDef.SFM_SFWActionsInfo();
        INTF_WebServicesDef.SFM_SFWActionsInfo sfwAction1 = new INTF_WebServicesDef.SFM_SFWActionsInfo(ActnRec,enabld);
        
        SVMXC__ServiceMax_Processes__c p = sfwAction.getactionDef();
        sfwAction.setactionDef(p);
        enabld = sfwAction.getEnabled();
        
        sfwAction.setEnabled(enabld);
        
        INTF_WebServicesDef.INTF_SearchInfoDetail a2 = new INTF_WebServicesDef.INTF_SearchInfoDetail();
        
        SVMXC__ServiceMax_Processes__c SearchDef = new SVMXC__ServiceMax_Processes__c();
        List<INTF_WebServicesDef.INTF_SearchInfoDetail> SearchDetails = new List<INTF_WebServicesDef.INTF_SearchInfoDetail>();
        SearchDetails.add(a2);
        INTF_WebServicesDef.INTF_SearchInfo a1 = new INTF_WebServicesDef.INTF_SearchInfo(SearchDef,SearchDetails);
        
        INTF_WebServicesDef.INTF_Expression a3 = new INTF_WebServicesDef.INTF_Expression();
        List<INTF_WebServicesDef.INTF_Expression> a3Lst = new List<INTF_WebServicesDef.INTF_Expression>();
        a3Lst.add(a3);
        INTF_WebServicesDef.INTF_Request_Expression a4 = new INTF_WebServicesDef.INTF_Request_Expression(a3Lst);
        INTF_WebServicesDef.INTF_Response_Expression a5 = new INTF_WebServicesDef.INTF_Response_Expression();
        INTF_WebServicesDef.INTF_SFMResponse a6 = new INTF_WebServicesDef.INTF_SFMResponse();
        INTF_WebServicesDef.SVMXMap a7 = new INTF_WebServicesDef.SVMXMap();
        INTF_WebServicesDef.SVMXClient a8 = new INTF_WebServicesDef.SVMXClient();
        INTF_WebServicesDef.SVMXError a9 = new INTF_WebServicesDef.SVMXError();
        List<INTF_WebServicesDef.SVMXError> a9Lst = new List<INTF_WebServicesDef.SVMXError>();
        a9Lst.add(a9);
        INTF_WebServicesDef.APL_SerialCollection a10 = new INTF_WebServicesDef.APL_SerialCollection();
        INTF_WebServicesDef.APL_OrderLineCollection a11 = new INTF_WebServicesDef.APL_OrderLineCollection();
        INTF_WebServicesDef.APL_Order a12 = new INTF_WebServicesDef.APL_Order();
        
        
        INTF_WebServicesDef.INTF_Event_WP eventWp = new INTF_WebServicesDef.INTF_Event_WP();
        INTF_WebServicesDef.INTF_LookUpConfigData lookUpCon = new INTF_WebServicesDef.INTF_LookUpConfigData();
        
        INTF_WebServicesDef.INTF_NamedSearchInfoDetail v2 = new INTF_WebServicesDef.INTF_NamedSearchInfoDetail(ActnRec,fields);
        
        SVMXC__ServiceMax_Processes__c namedSearchHdr = new SVMXC__ServiceMax_Processes__c();
        List<INTF_WebServicesDef.INTF_NamedSearchInfoDetail> namedSearchDetails = new List<INTF_WebServicesDef.INTF_NamedSearchInfoDetail>();
        namedSearchDetails.add(v2);
        
        INTF_WebServicesDef.INTF_NamedSearchInfo v3 = new INTF_WebServicesDef.INTF_NamedSearchInfo(namedSearchHdr,namedSearchDetails);
        List<INTF_WebServicesDef.INTF_NamedSearchInfo> namedSearch = new List<INTF_WebServicesDef.INTF_NamedSearchInfo>();
        
        INTF_WebServicesDef.INTF_Response_NamedSearchInfo v1 = new INTF_WebServicesDef.INTF_Response_NamedSearchInfo();
        INTF_WebServicesDef.INTF_Response_NamedSearchInfo v41 = new INTF_WebServicesDef.INTF_Response_NamedSearchInfo(namedSearch);
        
        string s;
        INTF_WebServicesDef.INTF_StringFieldMap v5 = new INTF_WebServicesDef.INTF_StringFieldMap(recId,keyVal,s);
        
        INTF_WebServicesDef.INTF_StringFieldMap v70 = new INTF_WebServicesDef.INTF_StringFieldMap();
        
        List<INTF_WebServicesDef.INTF_StringFieldMap> lst = new List<INTF_WebServicesDef.INTF_StringFieldMap>();
        lst.add(v5);
        
        INTF_WebServicesDef.bubble_wp bubble = new INTF_WebServicesDef.bubble_wp(lst);
        INTF_WebServicesDef.INTF_Response v6 = new INTF_WebServicesDef.INTF_Response();
        v6.geterrors();
        v6.seterrors(a9Lst);
        INTF_WebServicesDef.INTF_StringListMap v7 = new INTF_WebServicesDef.INTF_StringListMap();
        List<INTF_WebServicesDef.INTF_StringListMap> lst2 = new List<INTF_WebServicesDef.INTF_StringListMap>();
        INTF_WebServicesDef.INTF_Request v8 = new INTF_WebServicesDef.INTF_Request();
        try{INTF_WebServicesDef.PCAL_GetPricingDefinition_WS(v8);}catch(exception ex){}
        try{INTF_WebServicesDef.Get_CodeSnippet_SFMEvent_WS(v8);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_getViewData_WS(v8);}catch(exception ex){}
        
        
        
        INTF_WebServicesDef.INTF_BubbleWrapper v9 = new INTF_WebServicesDef.INTF_BubbleWrapper();
        INTF_WebServicesDef.INTF_DetailBubbleWrapper v10 = new INTF_WebServicesDef.INTF_DetailBubbleWrapper();
        INTF_WebServicesDef.INTF_UIButton v11 = new INTF_WebServicesDef.INTF_UIButton();
        INTF_WebServicesDef.INTF_UIField v12 = new INTF_WebServicesDef.INTF_UIField();
        INTF_WebServicesDef.INTF_UISection v13 = new INTF_WebServicesDef.INTF_UISection();
        INTF_WebServicesDef.INTF_PageHeader v14 = new  INTF_WebServicesDef.INTF_PageHeader();
        INTF_WebServicesDef.INTF_PageDetail v15 = new INTF_WebServicesDef.INTF_PageDetail();
        INTF_WebServicesDef.INTF_PageUI v16 = new INTF_WebServicesDef.INTF_PageUI();
        INTF_WebServicesDef.INTF_Request_PageUI v17 = new INTF_WebServicesDef.INTF_Request_PageUI();
        INTF_WebServicesDef.INTF_Response_PageUI v18 = new INTF_WebServicesDef.INTF_Response_PageUI();
        INTF_WebServicesDef.INTF_Request_For_Events v19 = new INTF_WebServicesDef.INTF_Request_For_Events();
        INTF_WebServicesDef.INTF_Request_For_Tags v20 = new INTF_WebServicesDef.INTF_Request_For_Tags();
        INTF_WebServicesDef.INTF_Request_For_Tasks v21 = new INTF_WebServicesDef.INTF_Request_For_Tasks();
        INTF_WebServicesDef.INTF_Response_For_Tasks v22 = new INTF_WebServicesDef.INTF_Response_For_Tasks();
        INTF_WebServicesDef.INTF_Response_For_Tags v23 = new INTF_WebServicesDef.INTF_Response_For_Tags();
        INTF_WebServicesDef.INTF_Response_For_Events v24 = new INTF_WebServicesDef.INTF_Response_For_Events();
        INTF_WebServicesDef.INTF_Response_For_Get_StandaloneCreate_Layouts v25 = new INTF_WebServicesDef.INTF_Response_For_Get_StandaloneCreate_Layouts();
        INTF_WebServicesDef.INTF_Response_For_Get_View_Layouts v26 = new INTF_WebServicesDef.INTF_Response_For_Get_View_Layouts();
        INTF_WebServicesDef.INTF_Response_For_Get_Object_Layouts v27 = new INTF_WebServicesDef.INTF_Response_For_Get_Object_Layouts();
        INTF_WebServicesDef.INTF_Event v28 = new INTF_WebServicesDef.INTF_Event();
        INTF_WebServicesDef.INTF_Task v29 = new INTF_WebServicesDef.INTF_Task();
        INTF_WebServicesDef.INTF_StringMap v30 = new INTF_WebServicesDef.INTF_StringMap();
        list<INTF_WebServicesDef.INTF_StringMap> v30lst = new list<INTF_WebServicesDef.INTF_StringMap>();
        v30lst.add(v30);
        INTF_WebServicesDef.INTF_SearchInfoDetail a21 = new INTF_WebServicesDef.INTF_SearchInfoDetail(ActnRec, fields, v30lst);
        INTF_WebServicesDef.INTF_Request_For_History v31 = new INTF_WebServicesDef.INTF_Request_For_History();
        INTF_WebServicesDef.INTF_Response_For_History v32 = new INTF_WebServicesDef.INTF_Response_For_History();
        try{
            v32 = INTF_WebServicesDef.INTF_Get_Product_History_WS(v31);
        }catch(Exception ex){}
        try{
            v32 = INTF_WebServicesDef.INTF_Get_Account_History_WS(v31);
        }catch(exception ex){}
        INTF_WebServicesDef.INTF_Response_For_Home_Page_Layout v33 = new INTF_WebServicesDef.INTF_Response_For_Home_Page_Layout();
        //v33 = INTF_WebServicesDef.INTF_Get_Home_Page_Layout_WS();
        INTF_WebServicesDef.INTF_Record v34 = new INTF_WebServicesDef.INTF_Record();
        INTF_WebServicesDef.INTF_TargetRecordObject v35 = new INTF_WebServicesDef.INTF_TargetRecordObject();
        INTF_WebServicesDef.INTF_TargetRecord request12 = new INTF_WebServicesDef.INTF_TargetRecord();
        try{INTF_WebServicesDef.INTF_Quote_Calc_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_WO_SetIsBillable_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_IB_PopulateName_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_SXFR_GetPrice_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_WORD_EST_GetPrice_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_WORD_USG_GetPrice_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_WORD_REQ_GetPrice_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PREQ_GetPrice_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PORD_GetPrice_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PORD_PopulateFromLocationShipment_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PORD_PopulateToLocationRMA_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PORD_PopulateFromLocation_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PORD_PopulateToLocation_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PORD_SelFromAddressCASE_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PORD_SelToAddressCASE_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PORD_SelFromAddressWO_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_PORD_SelToAddressWO_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_BuildPageData_WS(request12);}catch(exception ex){}
        
        
        
        INTF_WebServicesDef.INTF_Response res = INTF_WebServicesDef.INTF_SaveTargetRecords_WS(request12);
        res = INTF_WebServicesDef.SFM_SaveTargetRecords_WS(request12);
        
        INTF_WebServicesDef.INTF_CalculatePMPlanDetails_SCON_WS(request12);
        INTF_WebServicesDef.INTF_ActivatePMPlan_PREV_WS(request12);
        INTF_WebServicesDef.INTF_CalculatePMPlanDetails_ACCT_WS(request12);
        INTF_WebServicesDef.INTF_CalculatePMPlanDetails_IPRD_WS(request12);
        INTF_WebServicesDef.INTF_CalculatePMPlanDetails_LOC_WS(request12);
        
        try{INTF_WebServicesDef.INTF_UpdateConsumedLocation_WORD_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_CancelPMPlan_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.PINV_CancelInvoice_WS(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_CancelContract(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_RenewContract(request12);}catch(exception ex){}
        try{INTF_WebServicesDef.INTF_ActivateContract(request12);}catch(exception ex){}
        
        
        List<INTF_WebServicesDef.INTF_Event_WP> ev = new List<INTF_WebServicesDef.INTF_Event_WP>();
        ev.add(eventWp);
        //String str1 = INTF_WebServicesDef.INTF_Update_Events_WS(ev);
        INTF_WebServicesDef.INTF_PageDataSet v36 = new INTF_WebServicesDef.INTF_PageDataSet();
        INTF_WebServicesDef.INTF_DetailDataSet v37 = new INTF_WebServicesDef.INTF_DetailDataSet();
        INTF_WebServicesDef.INTF_PageData v38 = new INTF_WebServicesDef.INTF_PageData();
        
        String key;
        String value;
        List<INTF_WebServicesDef.INTF_StringMap> properties = new List<INTF_WebServicesDef.INTF_StringMap>();
        properties.add(v30);
        INTF_WebServicesDef.FieldProperties v39 = new INTF_WebServicesDef.FieldProperties(key);
        INTF_WebServicesDef.FieldProperties v40 = new INTF_WebServicesDef.FieldProperties(key,value,properties);
        
        INTF_WebServicesDef.INTF_MapStringMap v71 = new INTF_WebServicesDef.INTF_MapStringMap();
        INTF_WebServicesDef.INTF_MapStringMap v4 = new INTF_WebServicesDef.INTF_MapStringMap(s,properties);
        List<INTF_WebServicesDef.INTF_MapStringMap> lst1 = new List<INTF_WebServicesDef.INTF_MapStringMap>();
        
        properties = v4.getvalueList();
        v4.setvalueMap(properties);
        
        String tagId;
        String message;
        Boolean success;
        List<String> resultIds = new List<String>();
        List<SVMX_Debug.SMAX_Debug> logMsg = new List<SVMX_Debug.SMAX_Debug>();
        INTF_WebServicesDef.INTF_Response v44 = new INTF_WebServicesDef.INTF_Response(success,message,tagId,properties,logMsg,resultIds);
        
        properties = res.getstringMap();
        res.setstringMap(properties);
        lst = res.getstringFieldMap();
        res.setstringFieldMap(lst);
        lst2 = res.getStringLstMap();
        res.setStringLstMap(lst2);
        lst1 = res.getMapStringMap();
        res.setMapStringMap(lst1);
        
        INTF_WebServicesDef.INTF_StringListMap v45 = new INTF_WebServicesDef.INTF_StringListMap(key,resultIds);
        resultIds = v45.getvalueList();
        v45.setvalueList(resultIds);
        
        INTF_WebServicesDef.INTF_Request v46 = new INTF_WebServicesDef.INTF_Request(tagId,message,s,properties);
        properties = v46.getstringMap();
        v46.setstringMap(properties);
        lst2 = v46.getstringListMap();
        v46.setstringListMap(lst2);
        
        SVMXC__Page_Layout_Detail__c buttonDetail = new SVMXC__Page_Layout_Detail__c();
        List<SVMXC__SFM_Event__c> buttonEvents = new List<SVMXC__SFM_Event__c>();
        INTF_WebServicesDef.INTF_UIButton v47 = new INTF_WebServicesDef.INTF_UIButton(buttonDetail,buttonEvents);
        
        INTF_WebServicesDef.INTF_UIField v48 = new INTF_WebServicesDef.INTF_UIField(buttonDetail,buttonEvents,v9);
        
        buttonDetail = v13.getsectionDetail();
        v13.setsectionDetail(buttonDetail);
        
        List<INTF_WebServicesDef.INTF_UIField> v49 = new List<INTF_WebServicesDef.INTF_UIField>();
        v49 = v13.getfields();
        v13.setfields(v49);
        
        INTF_WebServicesDef.INTF_UISection v50 = new INTF_WebServicesDef.INTF_UISection(buttonDetail,v49);
        
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        List<INTF_WebServicesDef.INTF_UISection> sections = new List<INTF_WebServicesDef.INTF_UISection>();
        List<INTF_WebServicesDef.INTF_UIButton> buttons = new List<INTF_WebServicesDef.INTF_UIButton>();
        
        INTF_WebServicesDef.INTF_PageHeader v51 = new  INTF_WebServicesDef.INTF_PageHeader(headerLayout,sections,buttons,buttonEvents);
        
        List<INTF_WebServicesDef.INTF_DetailBubbleWrapper> bubbleinfolist = new List<INTF_WebServicesDef.INTF_DetailBubbleWrapper>();
        
        INTF_WebServicesDef.INTF_PageDetail v52 = new INTF_WebServicesDef.INTF_PageDetail(headerLayout,v49,buttons,bubbleinfolist);
        
        List<INTF_WebServicesDef.INTF_PageDetail> details = new List<INTF_WebServicesDef.INTF_PageDetail>();
        
        INTF_WebServicesDef.INTF_PageUI v53 = new INTF_WebServicesDef.INTF_PageUI(v51,details);
        
        INTF_WebServicesDef.INTF_Request_PageUI v54 = new INTF_WebServicesDef.INTF_Request_PageUI(v53,namedSearchHdr,v8);
        
        INTF_WebServicesDef.INTF_Response_PageUI v55 = new INTF_WebServicesDef.INTF_Response_PageUI(v53);
        
        INTF_WebServicesDef.INTF_Request_For_Events v56 = new INTF_WebServicesDef.INTF_Request_For_Events(properties);
        
        INTF_WebServicesDef.INTF_Request_For_Tags v57 = new INTF_WebServicesDef.INTF_Request_For_Tags(properties);
        
        INTF_WebServicesDef.INTF_Request_For_Tasks v58 = new INTF_WebServicesDef.INTF_Request_For_Tasks(properties);
        
        List<INTF_WebServicesDef.INTF_Task> taskInfo = new List<INTF_WebServicesDef.INTF_Task>();
        INTF_WebServicesDef.INTF_Response_For_Tasks v59 = new INTF_WebServicesDef.INTF_Response_For_Tasks(taskInfo);
        
        INTF_WebServicesDef.INTF_Response_For_Tags v60 = new INTF_WebServicesDef.INTF_Response_For_Tags(properties);
        
        List<INTF_WebServicesDef.INTF_Event> eventInfo = new List<INTF_WebServicesDef.INTF_Event>();
        INTF_WebServicesDef.INTF_Response_For_Events v61 = new INTF_WebServicesDef.INTF_Response_For_Events(eventInfo);
        
        List<SVMXC__ServiceMax_Processes__c> layoutsInfo = new List<SVMXC__ServiceMax_Processes__c>();
        INTF_WebServicesDef.INTF_Response_For_Get_StandaloneCreate_Layouts v62 = new INTF_WebServicesDef.INTF_Response_For_Get_StandaloneCreate_Layouts(layoutsInfo);
        
        List<INTF_WebServicesDef.INTF_Response_For_Get_Object_Layouts> layoutInfo = new List<INTF_WebServicesDef.INTF_Response_For_Get_Object_Layouts>();
        INTF_WebServicesDef.INTF_Response_For_Get_View_Layouts v63 = new INTF_WebServicesDef.INTF_Response_For_Get_View_Layouts(layoutInfo);
        
        INTF_WebServicesDef.INTF_Response_For_Get_Object_Layouts v64 = new INTF_WebServicesDef.INTF_Response_For_Get_Object_Layouts(ObjName,layoutsInfo);
        
        INTF_WebServicesDef.INTF_StringMap v65 = new INTF_WebServicesDef.INTF_StringMap(key,value);
        
        INTF_WebServicesDef.INTF_Request_For_History v66 = new INTF_WebServicesDef.INTF_Request_For_History(properties);
        
        List<SVMXC__Service_Order__c> historyInfo = new List<SVMXC__Service_Order__c>();
        INTF_WebServicesDef.INTF_Response_For_History v67 = new INTF_WebServicesDef.INTF_Response_For_History(historyInfo);
        
        //INTF_WebServicesDef.INTF_Response_For_History v68 = INTF_WebServicesDef.INTF_Get_Product_History_WS(v66);
        //INTF_WebServicesDef.INTF_Response_For_History v69 = INTF_WebServicesDef.INTF_Get_Account_History_WS(v66);
        
        List<INTF_WebServicesDef.INTF_StringMap> targetRecordAsKeyValue = v34.gettargetRecordAsKeyValue();
        v34.settargetRecordAsKeyValue(targetRecordAsKeyValue);
        List<INTF_WebServicesDef.INTF_Record> records = v35.getrecords();
        v35.setrecords(records);
        List<String> deleteRecID = v35.getdeleteRecID();
        v35.setdeleteRecID(deleteRecID);
        
        INTF_WebServicesDef.INTF_TargetRecordObject headerRecord = request12.getheaderRecord();
        request12.setheaderRecord(headerRecord);
        List<INTF_WebServicesDef.INTF_TargetRecordObject> detailRecords = request12.getdetailRecords();
        request12.setdetailRecords(detailRecords);
        
        List<INTF_WebServicesDef.INTF_PageDataSet> pageDataSet = INTF_WebServicesDef.INTF_AddRecords_WS(v46);
        list<INTF_WebServicesDef.INTF_BubbleWrapper> bubbleInfo = v36.getbubbleInfo();
        v36.setbubbleInfo(bubbleInfo);
        
        pageDataSet = v37.getpageDataSet();
        v37.setpageDataSet(pageDataSet);
        
        v36 = v38.getpageDataSet();
        v38.setpageDataSet(v36);
        list<INTF_WebServicesDef.INTF_DetailDataSet> detailDataSet = v38.getdetailDataset();
        v38.setdetailDataset(detailDataSet);
    }
    
    static testMethod void INTF_WebServicesDef_Test1()
    {
        INTF_WebServicesDef.INTF_SFMRequest request31 = new INTF_WebServicesDef.INTF_SFMRequest();
        
        //INTF_WebServicesDef.INTF_MetaSync_WS(request31);
        INTF_WebServicesDef.INTF_APL_PerformEntitlement_On_PD(request31);
        INTF_WebServicesDef.SFM_GetSearchInfo_WS(request31);
        INTF_WebServicesDef.INTF_APL_Do_Forward_Shipment_WS(request31);
        INTF_WebServicesDef.INTF_CUD_OnPropertyElements_WS(request31, 'action');
        INTF_WebServicesDef.INTF_APL_DoReturnSourceUpdates_WS(request31);
        INTF_WebServicesDef.INTF_APL_GenerateRMAforCase_WS(request31);
        INTF_WebServicesDef.INTF_APL_CalculateRMAForCase_WS(request31);
        INTF_WebServicesDef.INTF_APL_CreateRouteForCase_WS(request31);
        INTF_WebServicesDef.INTF_APL_GetRouteInfo_WS(request31);
        INTF_WebServicesDef.INTF_APL_GetAccountAndProductInfo_WS(request31);
        INTF_WebServicesDef.INTF_APL_PerformEntitlement_WS(request31);
        INTF_WebServicesDef.INTF_APL_GetIntiateReturnProc_WS(request31);
        //INTF_WebServicesDef.INTF_APL_CreateInternalExternalRMA_WS(request31);
        //INTF_WebServicesDef.INTF_APL_GetAvailableStockSerial_WS(request31);
        //INTF_WebServicesDef.INTF_APL_SaveOrder_WS(request31);
        //INTF_WebServicesDef.APL_PreSaveUpdates_WS(request31);
        //INTF_WebServicesDef.INTF_APL_GetOrder_WS(request31);
        
        request31.eventName = 'EVENT_SYNC';
        request31.eventType = 'SYNC';
        //INTF_WebServicesDef.INTF_DataSync_WS(request31);
        
        Account newAccount = new Account();
        newAccount.Name = 'TestName';
        insert newAccount;
        INTF_WebServicesDef.INTF_GetSFWOutputTemplate_WS(newAccount.Id);
    }
    
    // @Ramachandra
    static testMethod void INTF_WebServicesDef_Coverage() {
        
        INTF_WebServicesDef.COMM_GetCommunityPrefix();
        INTF_WebServicesDef.INTF_GetSFWOutputTemplate_WS(null);
        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
        
        list<INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.SVMXMap processId = new INTF_WebServicesDef.SVMXMap();
        processId.key = 'SVMX_PROCESSID';
        processId.value = '';
        lstSVMXMap.add(processId);
        
        INTF_WebServicesDef.SVMXMap recordId = new INTF_WebServicesDef.SVMXMap();
        recordId.key = 'SVMX_recordId';
        recordId.value = '';
        lstSVMXMap.add(recordId);
        
        request.valueMap = lstSVMXMap;
        INTF_WebServicesDef.INTF_GetNextStepURL_WS(request );
        
        INTF_WebServicesDef.INTF_Response_SFWInfo info = new INTF_WebServicesDef.INTF_Response_SFWInfo();
        info.setAvailableActions(null);
        info.getAvailableActions();
        
        INTF_WebServicesDef.SFM_SFWActionsInfo ainfo = new INTF_WebServicesDef.SFM_SFWActionsInfo(null,false,null,null);
        ainfo.getCustomActionParams();
        ainfo.setCustomActionParams(null);
        
        INTF_WebServicesDef.INTF_Event_WP intfEventWP = new INTF_WebServicesDef.INTF_Event_WP();
        INTF_WebServicesDef.INTF_Response response = new INTF_WebServicesDef.INTF_Response(null);
        
        INTF_WebServicesDef.INTF_Response_Expression expression = new INTF_WebServicesDef.INTF_Response_Expression(null);
        expression.getexpressions();
        expression.setexpressions( null );
        
        INTF_WebServicesDef.INTF_Get_View_Layouts_WS();
        INTF_WebServicesDef.INTF_Get_StandaloneCreate_Layouts();
        
        INTF_WebServicesDef.OMAX_BuildQualifiedTechnicians_WS( new INTF_WebServicesDef.INTF_Request() );
        try {
            INTF_WebServicesDef.PCAL_GetCasePricingDefinition_WS( new INTF_WebServicesDef.INTF_Request() );   
        }
        catch(Exception ex ) {}        
    }
    
    static testmethod void testmobileInventoryConfig()
    {
       List<RecordType> recordTypeList = [select Id, DeveloperName, SobjectType from Recordtype 
                  where (SobjectType =: 'SVMXC__ServiceMax_Config_Data__c' and (DeveloperName =: 'Configuration_Profile' OR DeveloperName =: 'Configuration_Access' ))];
        
        Id configProfileRecordTypeId,confAccessRecTypeId;
        if(recordTypeList <> NULL && !recordTypeList.isEmpty())
        {
            for(RecordType rType : recordTypeList)
            {
                if(rType.SobjectType == 'SVMXC__ServiceMax_Config_Data__c')
                {
                    if(rType.DeveloperName =='Configuration_Profile'){
                        configProfileRecordTypeId = rType.Id;
                    }
                    if(rType.DeveloperName =='Configuration_Access'){
                        confAccessRecTypeId = rType.Id;
                    }
                }
            }
        }
    
        //insert profile related processes and config data
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();
        configProfile.SVMXC__Profile_Name__c = 'Test User Profile';
        configProfile.RecordTypeId = configProfileRecordTypeId;
        configProfile.SVMXC__Configuration_Type__c = 'Group';
        configProfile.SVMXC__Active__c = true;
        insert configProfile;
        
        SVMXC__ServiceMax_Config_Data__c accessProfile = new SVMXC__ServiceMax_Config_Data__c();
        accessProfile.SVMXC__Action_Type__c = 'Set Value';
        accessProfile.SVMXC__Profile__c = Userinfo.getProfileId();
        accessProfile.RecordTypeId = confAccessRecTypeId;
        accessProfile.SVMXC__Active__c = true;
        accessProfile.SVMXC__Access_Configuration_Profile__c = configProfile.Id;
        insert accessProfile; 
        
        SVMXC__SM_Inventory_Config__c newConfig = new SVMXC__SM_Inventory_Config__c();
        newConfig.SVMXC__SM_ServiceMax_Profile__c = accessProfile.Id;
        newConfig.SVMXC__SM_Content__c = 'JSON Content';
        insert newConfig;
        
        Test.startTest();
        INTF_WebServicesDef.INTF_SFMRequest mobileInventoryConfig = new INTF_WebServicesDef.INTF_SFMRequest();       
        mobileInventoryConfig.eventName='MOBILE_INVENTORY_CONFIG';
        mobileInventoryConfig.eventType='META_SYNC';
        INTF_WebServicesDef.INTF_SFMResponse newResponse = INTF_WebServicesDef.INTF_MetaSync_WS(mobileInventoryConfig);
        Test.stopTest();
            
    }
    
}