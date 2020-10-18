/**
 * @description This class implements unit test scenario for SFMDeliveryServiceImpl.
 
 * @author      Ramachandra Mohan
 * @date        06 Jun 2015
 */

@isTest
private class SFMDeliveryServiceImpl_UT {

    static testMethod void testMethods() {

        Test.startTest();
        
        SFMDeliveryServiceImpl impl = new SFMDeliveryServiceImpl();
        new SFMDeliveryServiceImpl.PageDataRequest('tst', 'test', 'test');
        new SFMDeliveryServiceImpl.PageDataRequest('tst', 'test', 'test', 'test');
        new SFMDeliveryServiceImpl.RetrieveSettingsRequest('tst');
        try { impl.qualify('test', 'test'); } catch(Exception ex) {}
        impl.getUserInfo();
        impl.getLayoutDescriptionInternal( new SFMDeliveryServiceImpl.LayoutDescriptionRequest());
        try { impl.saveTarget(); } catch(Exception ex) {}
        try { impl.addRecords(); } catch(Exception ex) {}
        try { impl.getPageData(); } catch(Exception ex) {}
        try { impl.getBubbleData(); } catch(Exception ex) {}
        try { impl.getNextStepInfo(); } catch(Exception ex) {}        
        try { impl.getPageLayout(); } catch(Exception ex) {}
        try { impl.getLookupConfig(); } catch(Exception ex) {} 
        try { impl.getSnippetForEvent(); } catch(Exception ex) {}
        try { impl.retrieveDisplayTags(); } catch(Exception ex) {}
        try { impl.getObjectDescription(); } catch(Exception ex) {}
        try { impl.getRecordTypes(); } catch(Exception ex) {}
        try { impl.getLayoutDescription(); } catch(Exception ex) {}
        try { impl.getLookupData(); } catch(Exception ex) {}
		try { impl.getLookupConfiguration(); } catch(Exception ex) {}
		try { impl.getConfigInfo(); } catch(Exception ex) {}
		try { impl.getIsQualify(); } catch(Exception ex) {}
        try { impl.resolveLookUpDisplayValue(); } catch(Exception ex) {}
            
        try { impl.getPageLayoutInternal( new SFMDeliveryServiceImpl.PageLayoutRequest() ); } catch(Exception ex) {}        
        try { impl.getListOfChecklist( new SVMXC.SFMDeliveryServiceImpl.PageDataRequest() ); } catch(Exception ex) {}
        try { impl.retrieveDisplayTagsInternal( new SFMDeliveryServiceImpl.DisplayTagRequest() ); } catch(Exception ex) {}        
        try { impl.retrieveSettings(); } catch(Exception ex) {}
        try { impl.retrieveSettingsInternal( new SFMDeliveryServiceImpl.RetrieveSettingsRequest() ); } catch(Exception ex) {}
        try { impl.getPageDataInternal( new SFMDeliveryServiceImpl.PageDataRequest()); } catch(Exception ex) {}
        try { impl.getLookupConfigInternal(new SFMDeliveryServiceImpl.LookupConfigRequest()); } catch(Exception ex) {}
        try { impl.saveTargetInternal( new SVMXC.SFM_WrapperDef.SFM_TargetRecord() ); } catch(Exception ex) {}
        try { impl.getNextStepInfoInternal(new SFMDeliveryServiceImpl.NextStepInfoRequest()); } catch(Exception ex) {}
        try { impl.getSnippetForEventInternal(new SFMDeliveryServiceImpl.SnippetRequest()); } catch(Exception ex) {}
        try { impl.addRecordsInternal(new SFMDeliveryServiceImpl.AddRecordsRequest()); } catch(Exception ex) {}
        try { impl.getBubbleDataInternal(new SFMDeliveryServiceImpl.BubbleDataRequest()); } catch(Exception ex) {}
        try { impl.getObjectDescriptionInternal( new SFMDeliveryServiceImpl.ObjectDescriptionRequest()); } catch(Exception ex) {}
        try { impl.getRecordTypesInternal(new SFMDeliveryServiceImpl.RecordTypesRequest()); } catch(Exception ex) {}
        try { impl.getLookupDataInternal(new SVMXC.SFM_WrapperDef.SFM_Request()); } catch(Exception ex) {}
        
        Test.stopTest();
    }

    static SVMXC__ServiceMax_Processes__c SourceToTargetChild;
    static SVMXC__Quote__c objQuote;
    static testMethod void testMethodsForGetData()
    {
        createTestData(false);
        Test.startTest();

        SFMDeliveryServiceImpl.PageDataRequest pageReq = new SFMDeliveryServiceImpl.PageDataRequest();
        pageReq.processId = SourceToTargetChild.SVMXC__ProcessID__c;
        pageReq.recordId = objQuote.id;
        pageReq.qualify = true;

        SFMDeliveryServiceImpl obj = new SFMDeliveryServiceImpl();
        obj.getPageDataInternal(pageReq);

        Test.stopTest();
    }

    static testMethod void testMethodsForGetData2()
    {
        createTestData(true);
        Test.startTest();

        SFMDeliveryServiceImpl.PageDataRequest pageReq = new SFMDeliveryServiceImpl.PageDataRequest();
        pageReq.processId = SourceToTargetChild.SVMXC__ProcessID__c;
        pageReq.recordId = objQuote.id;
        pageReq.qualify = true;

        SFMDeliveryServiceImpl obj = new SFMDeliveryServiceImpl();
        obj.getPageDataInternal(pageReq);

        Test.stopTest();
    }

    static void createTestData(Boolean createHeaderEvent)
    {
        String targetManager;
        String processNodeObjects;
        String objectMapping; 
        String fieldMapping;
        String expression;
        String SVMXRule;
        String nameSearch;
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
        if(RTypeList.size() > 0)
        {
            for(RecordType r : RTypeList)
            {
                if(r.Name == 'Target Manager')
                    targetManager = r.id; 
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
                else if(r.Name == 'Object Mapping')
                    objectMapping = r.id;
                else if(r.Name == 'Field Mapping')
                    fieldMapping = r.id;
                else if(r.Name == 'Expressions')
                    expression = r.id;  
                else if(r.Name == 'SVMX Rule')
                    SVMXRule = r.id;    
                else if(r.Name == 'Named Search')   
                    nameSearch = r.id;  
            }
        }
        
        SVMXC__ServiceMax_Processes__c objNameSearch = new SVMXC__ServiceMax_Processes__c();
        objNameSearch.RecordTypeId=nameSearch;
        objNameSearch.SVMXC__IsDefault__C=true;
        objNameSearch.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        objNameSearch.SVMXC__ProcessID__c='Account Lookup Config';
        objNameSearch.SVMXC__Source_Object_Name__c = 'Account';
        objNameSearch.SVMXC__Default_Lookup_Column__c = 'Name';
        insert objNameSearch;
        
        SVMXC__ServiceMax_Processes__c objNameSearch1 = new SVMXC__ServiceMax_Processes__c();
        objNameSearch1.RecordTypeId=nameSearch;
        objNameSearch1.SVMXC__IsDefault__C=true;
        objNameSearch1.SVMXC__Rule_Type__c = 'SRCH_LOOKUP_CONFIG';
        objNameSearch1.SVMXC__ProcessID__c='Product Lookup Config';
        objNameSearch1.SVMXC__Source_Object_Name__c = 'Product2';
        objNameSearch1.SVMXC__Default_Lookup_Column__c = 'Name';
        insert objNameSearch1;
        
        //Create Header Page layout
        SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        insert objHeaderLayout;
        System.assertEquals(true, objHeaderLayout != null);

        /*SVMXC__Code_Snippet__c sobjCode_Snippet = new SVMXC__Code_Snippet__c(
            SVMXC__Name__c = 'Standard Get Price', // Snippet Name
            SVMXC__SnippetId__c = 'Code001', // Snippet ID
            SVMXC__Type__c = 'JavaScript',   // Type
            SVMXC__IsStandard__c = false,  
            SVMXC__Data__c = 'alert()'
        );
        insert sobjCode_Snippet;

        SVMXC__SFM_Event__c sobjSFM_Event = new SVMXC__SFM_Event__c(
          SVMXC__Event_Call_Type__c = 'JAVASCRIPT',     // Event Call Type
          SVMXC__Event_Type__c = 'Before Save/Update',  // Event Type
          SVMXC__Page_Layout__c = objHeaderLayout.id,    // Page Layout
          SVMXC__IsStandard__c = false,                 // Is Standard?
          SVMXC__Code_Snippet__c = sobjCode_Snippet.id   // Code Snippet
        );
        insert sobjSFM_Event;*/

        //Create Detail Page layout
        SVMXC__Page_Layout__c objDetailLayout = new SVMXC__Page_Layout__c();
        objDetailLayout.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        objDetailLayout.SVMXC__Type__c = 'Detail';
        objDetailLayout.SVMXC__Header_Page_Layout__c = objHeaderLayout.Id;
        objDetailLayout.SVMXC__Header_Reference_Field__c = 'SVMXC__Quote__c';
        insert objDetailLayout; 
        
        //Create Sections for header 
        list<SVMXC__Page_Layout_Detail__c> lstSection = new list<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c objSection1 = new SVMXC__Page_Layout_Detail__c();
        objSection1.SVMXC__Detail_Type__c = 'Section';
        objSection1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        objSection1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection1.SVMXC__Title__c = 'Service Quote';
        objSection1.SVMXC__Sequence__c = 1;
        lstSection.add(objSection1);
        SVMXC__Page_Layout_Detail__c objSection2 = new SVMXC__Page_Layout_Detail__c();
        objSection2.SVMXC__Detail_Type__c = 'Section';
        objSection2.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout2';
        objSection2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection2.SVMXC__Sequence__c = 2;
        lstSection.add(objSection2);
        insert lstSection;
       
        //Create Fields for Header Layout
        List<SVMXC__Page_Layout_Detail__c> lstHeaderFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld1 = new SVMXC__Page_Layout_Detail__c();
        objfld1.SVMXC__Detail_Type__c = 'Field';
        objfld1.SVMXC__Field_API_Name__c = 'SVMXC__Company__c';
        objfld1.SVMXC__Related_Object_Name__c = 'Account';
        objfld1.SVMXC__Related_Object_Name_Field__c = 'Name';
        objfld1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld1.SVMXC__Section__c = lstSection[0].Id;
        objfld1.SVMXC__DataType__c = 'REFERENCE';
        objfld1.SVMXC__Sequence__c = 1;
        objfld1.SVMXC__Named_Search__c = objNameSearch.id;
        lstHeaderFields.add(objfld1);
        SVMXC__Page_Layout_Detail__c objfld2 = new SVMXC__Page_Layout_Detail__c();
        objfld2.SVMXC__Detail_Type__c = 'Field';
        objfld2.SVMXC__Field_API_Name__c = 'SVMXC__Discount__c';
        objfld2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld2.SVMXC__Section__c = lstSection[0].Id;
        objfld2.SVMXC__DataType__c = 'DOUBLE';
        objfld2.SVMXC__Sequence__c = 2;
        lstHeaderFields.add(objfld2);
        SVMXC__Page_Layout_Detail__c objfld3 = new SVMXC__Page_Layout_Detail__c();
        objfld3.SVMXC__Detail_Type__c = 'Field';
        objfld3.SVMXC__Field_API_Name__c = 'SVMXC__Discount_Type__c';
        objfld3.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld3.SVMXC__Section__c = lstSection[1].Id;
        objfld3.SVMXC__DataType__c = 'PICKLIST';
        objfld3.SVMXC__Sequence__c = 1;
        lstHeaderFields.add(objfld3);
        insert lstHeaderFields;
        //Create Fields for Detail Layout
        List<SVMXC__Page_Layout_Detail__c> lstDetailFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld4 = new SVMXC__Page_Layout_Detail__c();
        objfld4.SVMXC__Detail_Type__c = 'Field';
        objfld4.SVMXC__Field_API_Name__c = 'SVMXC__Product__c';
        objfld4.SVMXC__Related_Object_Name__c = 'Product2';
        objfld4.SVMXC__Related_Object_Name_Field__c = 'Name';
        objfld4.SVMXC__Page_Layout__c = objDetailLayout.Id;
        objfld4.SVMXC__DataType__c = 'REFERENCE';
        objfld4.SVMXC__Sequence__c = 1;
        objfld4.SVMXC__Named_Search__c = objNameSearch1.id;
        lstDetailFields.add(objfld4);
        SVMXC__Page_Layout_Detail__c objfld5 = new SVMXC__Page_Layout_Detail__c();
        objfld5.SVMXC__Detail_Type__c = 'Field';
        objfld5.SVMXC__Field_API_Name__c = 'SVMXC__Line_Description__c';
        objfld5.SVMXC__Page_Layout__c = objDetailLayout.Id;
        objfld5.SVMXC__DataType__c = 'TEXTAREA';
        objfld5.SVMXC__Sequence__c = 2;
        lstDetailFields.add(objfld5);
        insert lstDetailFields;
        
        //Create Buttons
        SVMXC__Page_Layout_Detail__c Button1 = new SVMXC__Page_Layout_Detail__c();
        Button1.SVMXC__Detail_Type__c = 'Button';
        Button1.SVMXC__Title__c = 'Get Price';
        Button1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        Button1.SVMXC__Sequence__c = 2;
        insert Button1;
        SVMXC__Page_Layout_Detail__c Button2 = new SVMXC__Page_Layout_Detail__c();
        Button2.SVMXC__Detail_Type__c = 'Button';
        Button2.SVMXC__Title__c = 'Get Price';
        Button2.SVMXC__Page_Layout__c = objDetailLayout.Id;
        Button2.SVMXC__Sequence__c = 2;
        insert Button2;
        
        //Create Events 
        List<SVMXC__SFM_Event__c> lstEvents = new List<SVMXC__SFM_Event__c>();

        SVMXC__SFM_Event__c PageEvent = new SVMXC__SFM_Event__c();
        if(createHeaderEvent){
            PageEvent.SVMXC__Event_Type__c = 'On Page Load';
            PageEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
            PageEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
            PageEvent.SVMXC__Page_Layout__c = objHeaderLayout.Id;
            lstEvents.add(PageEvent);
        }
        
        SVMXC__SFM_Event__c DetailPageEvent = new SVMXC__SFM_Event__c();
        DetailPageEvent.SVMXC__Event_Type__c = 'On Page Load';
        DetailPageEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        DetailPageEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        DetailPageEvent.SVMXC__Page_Layout__c = objDetailLayout.Id;
        lstEvents.add(DetailPageEvent);
        SVMXC__SFM_Event__c ButtonEvent = new SVMXC__SFM_Event__c();
        ButtonEvent.SVMXC__Event_Type__c = 'On Button Click';
        ButtonEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        ButtonEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        ButtonEvent.SVMXC__Page_Layout_Detail__c = Button1.Id;
        lstEvents.add(ButtonEvent);
        SVMXC__SFM_Event__c FieldChange = new SVMXC__SFM_Event__c();
        FieldChange.SVMXC__Event_Type__c = 'Field Change';
        FieldChange.SVMXC__Event_Type__c = 'WEBSERVICE';
        FieldChange.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        FieldChange.SVMXC__Page_Layout_Detail__c = lstHeaderFields[0].Id;
        lstEvents.add(FieldChange);
        insert lstEvents;
        
        //Create SFM Process Defination
        SourceToTargetChild = new SVMXC__ServiceMax_Processes__c();
        SourceToTargetChild.SVMXC__Name__c = 'CUSTOMPRO0001';
        SourceToTargetChild.RecordTypeId = targetManager;
        SourceToTargetChild.SVMXC__Purpose__c = 'STANDALONE EDIT';
        SourceToTargetChild.SVMXC__ProcessID__c = 'CUSTOMPRO0001';
        SourceToTargetChild.SVMXC__Page_Layout__c = objHeaderLayout.id;
        insert SourceToTargetChild;
        
        //Create Mapping For Header Record
        SVMXC__ServiceMax_Processes__c valMapHdr = new SVMXC__ServiceMax_Processes__c();
        valMapHdr.SVMXC__MapID__c = 'VMAP000001';
        valMapHdr.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
        valMapHdr.RecordTypeId = objectMapping;
        insert valMapHdr;
        //Create Mapping For Detail Record
        SVMXC__ServiceMax_Processes__c valMapDetail = new SVMXC__ServiceMax_Processes__c();
        valMapDetail.SVMXC__MapID__c = 'VMAP000002';
        valMapDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
        valMapDetail.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        valMapDetail.RecordTypeId = objectMapping;
        insert valMapDetail;
        
        //Create Field Mapping Records.
        SVMXC__ServiceMax_Config_Data__c fldMapping = new SVMXC__ServiceMax_Config_Data__c(); 
        fldMapping.recordTypeid = fieldMapping;
        fldMapping.SVMXC__Configuration_Type__c = 'Field Mapping';
        fldMapping.SVMXC__Source_Field_Name__c = 'SVMXC__Discount_Type__c';
        fldMapping.SVMXC__Target_Field_Name__c = 'SVMXC__Discount_Type__c';
        fldMapping.SVMXC__MapID__c = fldMapping.id;
        insert fldMapping;
        
        //Create Expression Record
        SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionRec.RecordTypeId = SVMXRule;
        ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
        ExpressionRec.SVMXC__Name__c = 'EXpression111';
        ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
        ExpressionRec.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        insert ExpressionRec;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject1.SVMXC__Process__c = SourceToTargetChild.id;
        PNObject1.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject1.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        PNObject1.SVMXC__Module__c = valMapHdr.id;
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote__c';
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'TARGETCHILD';
        PNObject2.SVMXC__Page_Layout__c = objDetailLayout.id;
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject2.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject2.SVMXC__Process__c = SourceToTargetChild.id;
        PNObject2.SVMXC__Submodule__c = ExpressionRec.id;
        PNObject2.SVMXC__Module__c = valMapDetail.id;
        PNObject2.SVMXC__Final_Exception_Process__c = valMapDetail.id;
        PNObject2.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote_Line__c';
        listProcessNodeObjects.add(PNObject2);
        
        SVMXC__ServiceMax_Processes__c PNObject3 = new SVMXC__ServiceMax_Processes__c();
        PNObject3.RecordTypeId = processNodeObjects;
        PNObject3.SVMXC__Type__c = 'SOURCE';
        PNObject3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        PNObject3.SVMXC__Process__c = SourceToTargetChild.id;
        PNObject3.SVMXC__Final_Exception_Process__c = valMapHdr.id;
        listProcessNodeObjects.add(PNObject3);
        
        SVMXC__ServiceMax_Processes__c PNObject4 = new SVMXC__ServiceMax_Processes__c();
        PNObject4.RecordTypeId = processNodeObjects;
        PNObject4.SVMXC__Type__c = 'SOURCECHILD';
        PNObject4.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        PNObject4.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        PNObject4.SVMXC__Process__c = SourceToTargetChild.id;
        PNObject4.SVMXC__Final_Exception_Process__c = valMapDetail.id;
        listProcessNodeObjects.add(PNObject4);
        insert listProcessNodeObjects;
        
        //Create Account
        Account objAcc = new Account();
        objAcc.name = 'ServiceMax Inc';
        insert objAcc;
        
        //Crearte Product
        Product2 objPro = new Product2();
        objPro.Name = 'ServiceMax Suite';
        insert objPro;
        
        //Create Quote
        objQuote = new SVMXC__Quote__c();
        objQuote.SVMXC__Company__c = objAcc.id;
        objQuote.SVMXC__Discount__c = 12;
        objQuote.SVMXC__Discount_Type__c = 'Ammount';
        objQuote.SVMXC__Status__c = 'Open';
        insert objQuote;
        
        //Create Quote Lines
        list<SVMXC__Quote_Line__c> lstQuoteLine = new list<SVMXC__Quote_Line__c>();
        SVMXC__Quote_Line__c objQuoteLine = new SVMXC__Quote_Line__c();
        objQuoteLine.SVMXC__Discount_Type__c = 'Amount';
        objQuoteLine.SVMXC__Line_Description__c = 'Line 1';
        objQuoteLine.SVMXC__Quote__c = objQuote.id;
        objQuoteLine.SVMXC__Product__c = objPro.id;
        lstQuoteLine.add(objQuoteLine);
        SVMXC__Quote_Line__c objQuoteLine1 = new SVMXC__Quote_Line__c();
        objQuoteLine1.SVMXC__Discount_Type__c = 'Amount';
        objQuoteLine1.SVMXC__Line_Description__c = 'Line 2';
        objQuoteLine1.SVMXC__Quote__c = objQuote.id;
        objQuoteLine1.SVMXC__Product__c = objPro.id;
        lstQuoteLine.add(objQuoteLine1);
        insert lstQuoteLine;
    }
}