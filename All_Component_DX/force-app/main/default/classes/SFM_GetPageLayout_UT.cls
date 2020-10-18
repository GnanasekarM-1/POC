@isTest
private class SFM_GetPageLayout_UT
{
    static testMethod void SFM_getPageLayout_Test()
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
        PageEvent.SVMXC__Event_Type__c = 'On Page Load';
        PageEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        PageEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        PageEvent.SVMXC__Page_Layout__c = objHeaderLayout.Id;
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
        SVMXC__ServiceMax_Processes__c SourceToTargetChild = new SVMXC__ServiceMax_Processes__c();
        SourceToTargetChild.SVMXC__Name__c = 'CUSTOMPRO0001';
        SourceToTargetChild.RecordTypeId = targetManager;
        SourceToTargetChild.SVMXC__Purpose__c = 'SOURCE TO TARGET CHILD';
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
        valMapDetail.RecordTypeId = objectMapping;
        insert valMapDetail;
        
        //Create Expression Record
        SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionRec.RecordTypeId = SVMXRule;
        ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
        ExpressionRec.SVMXC__Name__c = 'EXpression111';
        ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
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
        SVMXC__Quote__c objQuote = new SVMXC__Quote__c();
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
        
        SVMXC.SFM_GetPageLayout objPage = new SVMXC.SFM_GetPageLayout();
        SVMXC.SFM_WrapperDef.SFM_Request_PageUI pageUIRequest = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI(); 
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap2 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap3 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        strMap1.key = 'PAGEID';
        strMap1.value = objHeaderLayout.id;
        strMap2.key = 'RECORDID';
        strMap2.value = objQuote.id;
        strMap3.key = 'PROCESSID';
        strMap3.value = SourceToTargetChild.id;
        
        
        StringMap.add(strMap1);
        StringMap.add(strMap2);
        StringMap.add(strMap3);
        pageUIRequest.request.StringMap = StringMap;
        Test.startTest();
        objPage.SFM_GetPageLayout(pageUIRequest);
        Test.stopTest();
    }
    static testMethod void SFM_getPageLayout_Test1()
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
        PageEvent.SVMXC__Event_Type__c = 'On Page Load';
        PageEvent.SVMXC__Event_Type__c = 'WEBSERVICE';
        PageEvent.SVMXC__Target_Call__c = 'SVMXC__INTF_WebServicesDef.INTF_Quote_Calc_WS';
        PageEvent.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        lstEvents.add(PageEvent);
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
        SVMXC__ServiceMax_Processes__c SourceToTargetChild = new SVMXC__ServiceMax_Processes__c();
        SourceToTargetChild.SVMXC__Name__c = 'CUSTOMPRO0001';
        SourceToTargetChild.RecordTypeId = targetManager;
        SourceToTargetChild.SVMXC__Purpose__c = 'STANDALONE CREATE';
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
        valMapDetail.RecordTypeId = objectMapping;
        insert valMapDetail;
        
        //Create Expression Record
        SVMXC__ServiceMax_Processes__c ExpressionRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionRec.RecordTypeId = SVMXRule;
        ExpressionRec.SVMXC__Rule_Type__c = 'Named Expression'; 
        ExpressionRec.SVMXC__Name__c = 'EXpression111';
        ExpressionRec.SVMXC__SettingID__c = 'EXpression111';
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
        SVMXC__Quote__c objQuote = new SVMXC__Quote__c();
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
        
        SVMXC.SFM_GetPageLayout objPage = new SVMXC.SFM_GetPageLayout();
        SVMXC.SFM_WrapperDef.SFM_Request_PageUI pageUIRequest = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI(); 
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap2 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap3 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        strMap1.key = 'PAGEID';
        strMap1.value = objHeaderLayout.id;
        //strMap2.key = 'RECORDID';
        //strMap2.value = objQuote.id;
        strMap3.key = 'PROCESSID';
        strMap3.value = SourceToTargetChild.id;
        
        
        StringMap.add(strMap1);
        StringMap.add(strMap2);
        StringMap.add(strMap3);
        pageUIRequest.request.StringMap = StringMap;
        Test.startTest();
        objPage.SFM_GetPageLayout(pageUIRequest);
        Test.stopTest();
    }
    static testMethod void SFM_getPageLayout_Test2(){
        SVMXC__QB_Response_Set__c objQBResposeSet = new SVMXC__QB_Response_Set__c();
        objQBResposeSet.Name = 'Test response set';
        objQBResposeSet.SVMXC__Response_Set_Values__c = 'value1;value2;';
        insert objQBResposeSet;
        
        SVMXC__Question_Bank__c objQuestionBank = new SVMXC__Question_Bank__c();
        objQuestionBank.SVMXC__QuestionID__c = 'QUE001';
        objQuestionBank.SVMXC__Question__c = 'Test Question';
        objQuestionBank.SVMXC__Response_Type__c = 'Picklist';
        objQuestionBank.SVMXC__Response_Set__c = objQBResposeSet.id;
        insert objQuestionBank;
        
        SVMXC__Question_Bank__c objQuestionBank1 = new SVMXC__Question_Bank__c();
        objQuestionBank1.SVMXC__QuestionID__c = 'QUE002';
        objQuestionBank1.SVMXC__Question__c = 'Test Question2';
        objQuestionBank1.SVMXC__Response_Type__c = 'Text';
        insert objQuestionBank1;
        
        //test
        SVMXC__Question_Bank__c objQuestionBank2 = new SVMXC__Question_Bank__c();
        objQuestionBank2.SVMXC__QuestionID__c = 'QUE001';
        objQuestionBank2.SVMXC__Question__c = 'Test Question';
        objQuestionBank2.SVMXC__Response_Type__c = 'Checkbox';
        //objQuestionBank3.SVMXC__Response_Set__c = null
        insert objQuestionBank2;

        SVMXC__SM_Default_Checklist_Response__c defaultResponeseSet = new SVMXC__SM_Default_Checklist_Response__c();
        defaultResponeseSet.SVMXC__SM_Default_Response__c = '{"literalValue":null,"listOfDefaultValues":["DAFAULTANS2"]}';
        defaultResponeseSet.SVMXC__SM_Question__c = objQuestionBank1.id;
        insert defaultResponeseSet;

        SVMXC__ServiceMax_Tags__c defaultAnswerTag = new SVMXC__ServiceMax_Tags__c();
        defaultAnswerTag.SVMXC__Tag_Key__c = 'DAFAULTANS2';
        defaultAnswerTag.SVMXC__Tag_Context__c = 'SFM DEFAULT ANSWER';
        defaultAnswerTag.SVMXC__Tag_Text__c = 'trans - dafault ans245';
        defaultAnswerTag.SVMXC__Language__c = 'en_US';
        defaultAnswerTag.SVMXC__Tag_Value__c = 'trans - dafault ans245';   
        insert defaultAnswerTag;
        
        String targetManager;
        String processNodeObjects;
        
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
        if(RTypeList.size() > 0)
        {
            for(RecordType r : RTypeList)
            {
                if(r.Name == 'Target Manager')
                    targetManager = r.id; 
                else if(r.Name ==  'Process Node Objects')
                    processNodeObjects = r.id;
            }
        }
        
        //Create Header Page layout
        SVMXC__Page_Layout__c objHeaderLayout = new SVMXC__Page_Layout__c();
        objHeaderLayout.SVMXC__Object_Name__c = 'SVMXC__Checklist__c';
        objHeaderLayout.SVMXC__Type__c = 'Header';
        insert objHeaderLayout;
        System.assertEquals(true, objHeaderLayout != null);
        
        //Create Sections for header
        SVMXC__Page_Layout_Detail__c objSection1 = new SVMXC__Page_Layout_Detail__c();
        objSection1.SVMXC__Detail_Type__c = 'Section';
        objSection1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        objSection1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objSection1.SVMXC__Title__c = 'Checklist Section Title';
        objSection1.SVMXC__Sequence__c = 1;
        insert objSection1;
       
        //Create Fields for Header Layout
        List<SVMXC__Page_Layout_Detail__c> lstHeaderFields = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c objfld1 = new SVMXC__Page_Layout_Detail__c();
        objfld1.SVMXC__Detail_Type__c = 'Question';
        objfld1.SVMXC__Question__c = objQuestionBank.id;
        objfld1.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld1.SVMXC__Section__c = objSection1.Id;
        objfld1.SVMXC__DataType__c = 'reference';
        objfld1.SVMXC__Sequence__c = 1;
        insert objfld1;
        
        SVMXC__Page_Layout_Detail__c objfld2 = new SVMXC__Page_Layout_Detail__c();
        objfld2.SVMXC__Detail_Type__c = 'Question';
        objfld2.SVMXC__Question__c = objQuestionBank1.id;
        objfld2.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld2.SVMXC__Section__c = objSection1.Id;
        objfld2.SVMXC__DataType__c = 'reference';
        objfld2.SVMXC__Sequence__c = 2;
        insert objfld2;
        
        SVMXC__Page_Layout_Detail__c objfld3 = new SVMXC__Page_Layout_Detail__c();
        objfld3.SVMXC__Detail_Type__c = 'Question';
        objfld3.SVMXC__Question__c = objQuestionBank2.id;
        objfld3.SVMXC__Page_Layout__c = objHeaderLayout.Id;
        objfld3.SVMXC__Section__c = objSection1.Id;
        objfld3.SVMXC__DataType__c = 'reference';
        objfld3.SVMXC__Sequence__c = 3;
        insert objfld3;
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c ChecklistProcess = new SVMXC__ServiceMax_Processes__c();
        ChecklistProcess.SVMXC__Name__c = 'TESTPROCESS001';
        ChecklistProcess.RecordTypeId = targetManager;
        ChecklistProcess.SVMXC__Purpose__c = 'CHECKLIST';
        ChecklistProcess.SVMXC__ProcessID__c = 'TESTPROCESS001';
        ChecklistProcess.SVMXC__Page_Layout__c = objHeaderLayout.id;
    ChecklistProcess.SVMXC__Tag_Keys__c = 'TESTPROCESS001;DAFAULTANS2';
        insert ChecklistProcess;
        
        //Create Process Node object Records.
        list<SVMXC__ServiceMax_Processes__c> listProcessNodeObjects = new list<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c PNObject1 = new SVMXC__ServiceMax_Processes__c();
        PNObject1.RecordTypeId = processNodeObjects;
        PNObject1.SVMXC__Type__c = 'TARGET';
        PNObject1.SVMXC__Source_Object_Name__c = 'SVMXC__Checklist__c';
        PNObject1.SVMXC__Process__c = ChecklistProcess.id;        
        PNObject1.SVMXC__Node_Source_Object_API__c = 'SVMXC__Service_Order__c';
        listProcessNodeObjects.add(PNObject1);
        
        SVMXC__ServiceMax_Processes__c PNObject2 = new SVMXC__ServiceMax_Processes__c();
        PNObject2.RecordTypeId = processNodeObjects;
        PNObject2.SVMXC__Type__c = 'SOURCE';
        PNObject2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        PNObject2.SVMXC__Process__c = ChecklistProcess.id;
        listProcessNodeObjects.add(PNObject2);
        insert listProcessNodeObjects;
        
        SVMXC.SFM_GetPageLayout objPage = new SVMXC.SFM_GetPageLayout();
        SVMXC.SFM_WrapperDef.SFM_Request_PageUI pageUIRequest = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI(); 
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap2 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap3 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        strMap1.key = 'PROCESSID';
        strMap1.value = ChecklistProcess.id;
        strMap2.key = 'CLIENT_TYPE';
        strMap2.value = 'WEB';
        strMap3.key = 'REQUEST_TYPE';
        strMap3.value = 'META';
        
        
        StringMap.add(strMap1);
        StringMap.add(strMap2);
        StringMap.add(strMap3);
        pageUIRequest.request.StringMap = StringMap;
        Test.startTest();
        objPage.SFM_GetPageLayout(pageUIRequest);
        Test.stopTest();
    }
    static testMethod void SFM_GetSectionEntryCriteriaRuleIds_test(){ 
        //*****Variable declaration and data creation*****
        String val = 'true';
        List<String> List_value = new List<String>();
        List_value.add(val);
        SVMXC.SFM_WrapperDef.SFM_StringListMap REC_stringlistmap = new SVMXC.SFM_WrapperDef.SFM_StringListMap ('RECORDID',List_value);
        SVMXC.SFM_WrapperDef.SFM_StringListMap Partial_stringlistmaps = new SVMXC.SFM_WrapperDef.SFM_StringListMap ('PARTIALDELETE',List_value);
        SVMXC__Page_Layout__c page_layout = new SVMXC__Page_Layout__c();
        page_layout.SVMXC__Object_Name__c='Case';
        page_layout.SVMXC__Page_Layout_ID__c='Case Layout';
        page_layout.SVMXC__IsStandard__c=true;
        insert page_layout;
        System.assertEquals(true, page_layout != null);
        System.debug('*****page_layout.Id'+page_layout.Id);
        SVMXC__Page_Layout_Detail__c  page_layout_detail = new SVMXC__Page_Layout_Detail__c ();
        page_layout_detail.SVMXC__Page_Layout__c =page_layout.Id;
        insert page_layout_detail;
        System.assertEquals(true, page_layout_detail != null);
        System.debug('*****page_layout_detail.Id'+page_layout_detail.Id);
        SVMXC__SFM_Event__c  page_event = new SVMXC__SFM_Event__c ();
        page_event.SVMXC__Page_Layout__c  = page_layout.Id;
        insert page_event;
        System.assertEquals(true, page_event != null);
        //*****Instance of classes
        SFM_GetPageLayout delPageLayout = new SFM_GetPageLayout();
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
        //*****creating the Lists*****
        List<SVMXC.SFM_WrapperDef.SFM_StringListMap> List_stringlstmap = new List<SVMXC.SFM_WrapperDef.SFM_StringListMap>();
        List_stringlstmap.add(REC_stringlistmap);
        List_stringlstmap.add(Partial_stringlistmaps);
        request.stringListMap = List_stringlstmap;
        List<String> StringLst = new List<String>();
        StringLst.add(page_layout.id);
        request.stringListMap[0].valueList = StringLst;
        SVMXC.SFM_WrapperDef.SFM_StringMap stringMap = new  SVMXC.SFM_WrapperDef.SFM_StringMap();
        stringMap.key='RECREATE';
        stringMap.value='true';
        request.stringMap.add(stringMap);
        System.debug('*****List_stringlstmap'+List_stringlstmap);
        //*****Calling method*****
        delPageLayout.SFM_GetSectionEntryCriteriaRuleIds(request);
        delPageLayout.SFM_GetSectionEntryCriteriaRuleInfo(request);
        delPageLayout.SFM_GetSectionExitCriteriaRuleInfo(request);
        List<Id> lstPageLayout = new List<Id>();
        lstPageLayout.add(page_layout.id);
        try{
        delPageLayout.clonePageLayout(lstPageLayout, false);
        }catch(Exception e){
        }
        try{
        List<SVMXC__Page_Layout_Detail__c> lstPageLayoutDetails = new List<SVMXC__Page_Layout_Detail__c>();
        lstPageLayoutDetails.add(page_layout_detail);
        delPageLayout.layoutElementWrapper(lstPageLayoutDetails, false);
        delPageLayout.layoutValueWrapper(page_layout, false);
        }catch(Exception e){
        }
    }
}