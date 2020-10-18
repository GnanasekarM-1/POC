@isTest
private class SFM_GetData_UT 
{
    static testMethod void SFM_getData_Test()
    {
        String targetManager;
        String processNodeObjects;
        String objectMapping; 
        String fieldMapping;
        String expression;
        String SVMXRule;
        String nameSearch;
        String businessRule;
        String processBusinessRule;
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
                else if(r.Name == 'Business Rule')   
                    businessRule = r.id;
                else if(r.Name == 'Process Business Rule')   
                    processBusinessRule = r.id;
            }
        }

        //----Start---Added for the defect fix BAC-3885
        SVMXC__ServiceMax_Processes__c objBusinessRule = new SVMXC__ServiceMax_Processes__c();
        objBusinessRule.RecordTypeId = businessRule;
        objBusinessRule.SVMXC__Name__c = 'DataValidationRule';
        objBusinessRule.SVMXC__ProcessID__c = 'DataValidationRule';
        objBusinessRule.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        objBusinessRule.SVMXC__Parent_Error_Msg__c = 'Test mesg';
        objBusinessRule.SVMXC__Message_Type__c = 'Error';
        insert objBusinessRule;

        SVMXC__ServiceMax_Config_Data__c objExprBRule = new SVMXC__ServiceMax_Config_Data__c();
        objExprBRule.RecordTypeId = expression;
        objExprBRule.SVMXC__Expression_Rule__c = objBusinessRule.id;
        objExprBRule.SVMXC__Expression_Type__c = 'Business_Rule';
        objExprBRule.SVMXC__Parameter_Type__c = 'Value';
        objExprBRule.SVMXC__Field_Name__c = 'SVMXC__Valid_Until__c';
        objExprBRule.SVMXC__Display_Type__c = 'DATE';
        objExprBRule.SVMXC__Operator__c = 'isnotnull';
        objExprBRule.SVMXC__Sequence__c = 1;
        insert objExprBRule;

        SVMXC__ServiceMax_Processes__c objBusinessRule1 = new SVMXC__ServiceMax_Processes__c();
        objBusinessRule1.RecordTypeId = businessRule;
        objBusinessRule1.SVMXC__Name__c = 'DataValidationRuleQL';
        objBusinessRule1.SVMXC__ProcessID__c = 'DataValidationRuleQL';
        objBusinessRule1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        objBusinessRule1.SVMXC__Parent_Error_Msg__c = 'Test mesg1';
        objBusinessRule1.SVMXC__Message_Type__c = 'Error';
        insert objBusinessRule1;

        SVMXC__ServiceMax_Config_Data__c objExprBRule1 = new SVMXC__ServiceMax_Config_Data__c();
        objExprBRule1.RecordTypeId = expression;
        objExprBRule1.SVMXC__Expression_Rule__c = objBusinessRule1.id;
        objExprBRule1.SVMXC__Expression_Type__c = 'Business_Rule';
        objExprBRule1.SVMXC__Parameter_Type__c = 'Field Value';
        objExprBRule1.SVMXC__Field_Name__c = 'SVMXC__Quantity2__c';
        objExprBRule1.SVMXC__Display_Type__c = 'DOUBLE';
        objExprBRule1.SVMXC__Internal_Value__c = 'double';
        objExprBRule1.SVMXC__Operand__c = 'SVMXC__Discount__c';
        objExprBRule1.SVMXC__Operator__c = 'eq';
        objExprBRule1.SVMXC__Sequence__c = 1;
        insert objExprBRule1;
        //----End---Added for the defect fix BAC-3885
        
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

        //----Start---Added for the defect fix BAC-3884
        SVMXC__ServiceMax_Processes__c ObjectFieldMap = new SVMXC__ServiceMax_Processes__c();
        ObjectFieldMap.SVMXC__Source_Object_Name__c = 'Account';
        ObjectFieldMap.SVMXC__Target_Object_Name__c = 'SVMXC__Quote__c';
        ObjectFieldMap.SVMXC__MapID__c='Account_to_Quote_Map';
        ObjectFieldMap.SVMXC__Name__c = 'Account to Quote Map';
        ObjectFieldMap.RecordTypeId = objectMapping;
        insert ObjectFieldMap;

        SVMXC__ServiceMax_Config_Data__c objFieldMap = new SVMXC__ServiceMax_Config_Data__c();
        objFieldMap.RecordTypeId = fieldMapping;
        objFieldMap.SVMXC__Configuration_Type__c = 'Field Mapping';
        objFieldMap.SVMXC__Parameter_Type__c = 'Field Value';
        objFieldMap.SVMXC__MapID__c = ObjectFieldMap.id;
        objFieldMap.SVMXC__Source_Field_Name__c ='SVMXC__Latitude__c' ;
        objFieldMap.SVMXC__Target_Field_Name__c ='SVMXC__Total_Line_Price2__c' ;
        insert objFieldMap;
        //----End-----Added for the defect fix BAC-3884
       
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
        objfld1.SVMXC__Field_Mapping__c = ObjectFieldMap.id; //Added for the defect fix BAC-3884
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

        //----Start---Added for the defect fix BAC-3884
        SVMXC__ServiceMax_Processes__c ObjectFieldMapForDetail = new SVMXC__ServiceMax_Processes__c();
        ObjectFieldMapForDetail.SVMXC__Source_Object_Name__c = 'Product2';
        ObjectFieldMapForDetail.SVMXC__Target_Object_Name__c = 'SVMXC__Quote_Line__c';
        ObjectFieldMapForDetail.SVMXC__MapID__c='Account_to_QuoteLine_Map';
        ObjectFieldMapForDetail.SVMXC__Name__c = 'Account to QuoteLine Map';
        ObjectFieldMapForDetail.RecordTypeId = objectMapping;
        insert ObjectFieldMapForDetail;

        SVMXC__ServiceMax_Config_Data__c objFieldMapForDetail = new SVMXC__ServiceMax_Config_Data__c();
        objFieldMapForDetail.RecordTypeId = fieldMapping;
        objFieldMapForDetail.SVMXC__Configuration_Type__c = 'Field Mapping';
        objFieldMapForDetail.SVMXC__Parameter_Type__c = 'Field Value';
        objFieldMapForDetail.SVMXC__MapID__c = ObjectFieldMapForDetail.id;
        objFieldMapForDetail.SVMXC__Source_Field_Name__c ='SVMXC__Part_Type__c' ;
        objFieldMapForDetail.SVMXC__Target_Field_Name__c ='SVMXC__Line_Type__c' ;
        insert objFieldMapForDetail;
        //----End-----Added for the defect fix BAC-3884

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
        objfld4.SVMXC__Field_Mapping__c = ObjectFieldMapForDetail.id; //Added for the defect fix BAC-3884
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
        
        //----Start---Added for the defect fix BAC-3885
        SVMXC__ServiceMax_Processes__c objProcessBusiRule = new SVMXC__ServiceMax_Processes__c();
        objProcessBusiRule.RecordTypeId = processBusinessRule;
        objProcessBusiRule.SVMXC__Sequence__c = 0;
        objProcessBusiRule.SVMXC__Process1__c = SourceToTargetChild.id;
        objProcessBusiRule.SVMXC__Process2__c = listProcessNodeObjects[0].id;
        objProcessBusiRule.SVMXC__Process3__c = objBusinessRule.id;
        insert objProcessBusiRule;

        SVMXC__ServiceMax_Processes__c objProcessBusiRule1 = new SVMXC__ServiceMax_Processes__c();
        objProcessBusiRule1.RecordTypeId = processBusinessRule;
        objProcessBusiRule1.SVMXC__Sequence__c = 1;
        objProcessBusiRule1.SVMXC__Process1__c = SourceToTargetChild.id;
        objProcessBusiRule1.SVMXC__Process2__c = listProcessNodeObjects[1].id;
        objProcessBusiRule1.SVMXC__Process3__c = objBusinessRule1.id;
        insert objProcessBusiRule1;
        //----End-----Added for the defect fix BAC-3885

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
        
        SVMXC.SFM_GetData objGetData = new SVMXC.SFM_GetData();
        SVMXC.SFM_WrapperDef.SFM_Request_PageUI pageUIRequest = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI();
        SFMDeliveryServiceImpl.PageDataRequestV2 requestV2 = new SFMDeliveryServiceImpl.PageDataRequestV2();
        SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest detailDataSetInRequest = new SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest();
        List<SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest> detailDataSetInRequestList = new List<SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest>();
        SVMXC.SFM_WrapperDef.SFM_PageData responseV1 = new SVMXC.SFM_WrapperDef.SFM_PageData();
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
        SFMDeliveryServiceImpl.detailRecBatchSize = 50;
        responseV1 = objGetData.SFM_getData(pageUIRequest);
        system.debug('TEST NIDHI'+responseV1.detailDataSet);
        COMM_SecurityUtils.getInstance().isSecurityCheckEnabled = false;
        if(responseV1.detailDataSet.size()>0){
            detailDataSetInRequest.aliasName = responseV1.detailDataSet[0].aliasName ;
            detailDataSetInRequest.offsetValue  = responseV1.detailDataSet[0].offsetValue ;
            if(!String.isBlank(responseV1.detailDataSet[0].objectApiName)){
                detailDataSetInRequest.objectApiName   = responseV1.detailDataSet[0].objectApiName ;
            }else{
                detailDataSetInRequest.objectApiName   = 'SVMXC__Service_Order__c' ;
            }
            if(!String.isBlank(responseV1.detailDataSet[0].fieldList)){
                detailDataSetInRequest.fieldList  = responseV1.detailDataSet[0].fieldList ;
            }else
                detailDataSetInRequest.fieldList = 'AllFields';
            detailDataSetInRequest.whereClause  = responseV1.detailDataSet[0].whereClause ;
            detailDataSetInRequest.orderByFields  = responseV1.detailDataSet[0].orderByFields  ;
            detailDataSetInRequest.isAllRecordsLoaded = responseV1.detailDataSet[0].isAllRecordsLoaded;
            detailDataSetInRequestList.add(detailDataSetInRequest);
            requestV2.detailDataSet = detailDataSetInRequestList;
            objGetData.SFM_getDataV2(requestV2);
        }       
        //----Start---Added for the defect fix BAC-3884
        SFMDeliveryServiceImpl.setIsQueryOptimizerEnabled(true);
        objGetData.SFM_getData(pageUIRequest);
         //----End---Added for the defect fix BAC-3884
        Test.stopTest();
        
    }
    
    static testMethod void SFM_getData_ChecklistTest(){
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
        
        String targetManager;
        String processNodeObjects;
        
        List<RecordType> RTypeList = [SELECT Id, Name,SobjectType,IsActive,DeveloperName from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' OR  SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        
        if(RTypeList.size() > 0){
            for(RecordType r : RTypeList){
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
        
        //Create SFM Process Defination
        SVMXC__ServiceMax_Processes__c ChecklistProcess = new SVMXC__ServiceMax_Processes__c();
        ChecklistProcess.SVMXC__Name__c = 'TESTPROCESS001';
        ChecklistProcess.RecordTypeId = targetManager;
        ChecklistProcess.SVMXC__Purpose__c = 'CHECKLIST';
        ChecklistProcess.SVMXC__ProcessID__c = 'TESTPROCESS001';
        ChecklistProcess.SVMXC__Page_Layout__c = objHeaderLayout.id;
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
        
        SVMXC__Service_Order__c objWO  = new SVMXC__Service_Order__c();
        insert objWO;
        
        SVMXC__Checklist__c objChecklist = new SVMXC__Checklist__c();
        objChecklist.SVMXC__ChecklistJSON__c = '{"test":"value"}';
        objChecklist.SVMXC__ChecklistMetaJSON__c = '{"test":"value"}';
        objChecklist.SVMXC__ChecklistProcessID__c = ChecklistProcess.id;
        objChecklist.SVMXC__Completed_By__c = Userinfo.getUserId();
        objChecklist.SVMXC__Completed_On__c = System.Today();
        objChecklist.SVMXC__Status__c = 'Completed';
        objChecklist.SVMXC__What_Id__c = String.ValueOf(objWO.id);
        insert objChecklist;

        //Create checklist attachment records
        SVMXC__SM_Checklist_Attachment__c sobj = new SVMXC__SM_Checklist_Attachment__c(
          SVMXC__SM_Question__c = objQuestionBank.id,  // Question
          SVMXC__SM_Attachment_ID__c = 'test',          // Attachment ID
          SVMXC__SM_File_Type__c = 'Image',             // File Type
          SVMXC__SM_File_Size__c = 12.0000,             // File Size
          SVMXC__SM_Checklist__c = objChecklist.id,   // Checklist
          SVMXC__SM_Internal_Question_ID__c = 'QUE001'  // Internal Question ID
        );
        insert sobj;
        
        SVMXC.SFM_GetData objGetData = new SVMXC.SFM_GetData();
        SVMXC.SFM_WrapperDef.SFM_Request_PageUI pageUIRequest = new SVMXC.SFM_WrapperDef.SFM_Request_PageUI(); 
        list<SVMXC.SFM_WrapperDef.SFM_StringMap> StringMap = new list<SVMXC.SFM_WrapperDef.SFM_StringMap>();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap1 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap2 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap3 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SVMXC.SFM_WrapperDef.SFM_StringMap strMap4 = new SVMXC.SFM_WrapperDef.SFM_StringMap();
        SFMDeliveryServiceImpl.PageDataRequestV2 requestV2 = new SFMDeliveryServiceImpl.PageDataRequestV2();
        SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest detailDataSetInRequest = new SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest();
        List<SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest> detailDataSetInRequestList = new List<SVMXC.SFM_WrapperDef.SFM_DetailDataSetInRequest>();
        SVMXC.SFM_WrapperDef.SFM_PageData responseV1 = new SVMXC.SFM_WrapperDef.SFM_PageData();
        strMap1.key = 'PAGEID';
        strMap1.value = objHeaderLayout.id;
        strMap2.key = 'RECORDID';
        strMap2.value = objWO.id;
        strMap3.key = 'PROCESSID';
        strMap3.value = ChecklistProcess.id;
        strMap4.key = 'TARGETID';
        strMap4.value = objChecklist.id;
        
        StringMap.add(strMap1);
        StringMap.add(strMap2);
        StringMap.add(strMap3);
        StringMap.add(strMap4);
        pageUIRequest.request.StringMap = StringMap;
        Test.startTest();
        responseV1 = objGetData.SFM_getData(pageUIRequest);
        SFMDeliveryServiceImpl.detailRecBatchSize = 50;
        system.debug('TEST NIDHI'+responseV1.detailDataSet);
        if(responseV1.detailDataSet.size()>0){
            detailDataSetInRequest.aliasName = responseV1.detailDataSet[0].aliasName ;
            detailDataSetInRequest.offsetValue  = responseV1.detailDataSet[0].offsetValue ;
            detailDataSetInRequest.objectApiName   = responseV1.detailDataSet[0].objectApiName ;
            if(!String.isBlank(responseV1.detailDataSet[0].fieldList)){
                detailDataSetInRequest.fieldList  = responseV1.detailDataSet[0].fieldList ;
            }else
                detailDataSetInRequest.fieldList = 'AllFields';
            detailDataSetInRequest.whereClause  = responseV1.detailDataSet[0].whereClause ;
            detailDataSetInRequest.orderByFields  = responseV1.detailDataSet[0].orderByFields  ;
            detailDataSetInRequest.isAllRecordsLoaded = responseV1.detailDataSet[0].isAllRecordsLoaded;
            detailDataSetInRequestList.add(detailDataSetInRequest);
            requestV2.detailDataSet = detailDataSetInRequestList;
            objGetData.SFM_getDataV2(requestV2);
        }
        Test.stopTest();
    }
}