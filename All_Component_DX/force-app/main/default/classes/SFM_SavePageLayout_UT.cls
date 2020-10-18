@isTest
private with sharing class SFM_SavePageLayout_UT
{
    static Map<String,Id> recordTypeIdMap = new Map<String,Id>();
    
    static testMethod void SFM_SavePageLayoutUnitTest()
    {
       List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
       System.assertEquals(true, lstRecType != null);
       
       String TargetManager = '';
       String ObjectMapping = '';
       String Fieldmapping = '';
       String ProcessNodeObj = '';
       for(RecordType r : lstRecType)
       {
            if(r.Name == 'Target Manager')
                TargetManager = r.id;
            if(r.Name == 'Object Mapping')  
                ObjectMapping = r.id;
            if(r.Name == 'Field Mapping')
                Fieldmapping = r.id;    
            if(r.Name == 'Process Node Objects')    
                ProcessNodeObj = r.id;
        }
       //DATA CREATION
       //Creating Header PageLayout
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        headerLayout.SVMXC__Page_Layout_ID__c = '1';
        headerLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        headerLayout.SVMXC__Type__c = 'Header';
        insert headerLayout;
        System.assertEquals(true, headerLayout != null);
       
       //Creating Detail PageLayout
        SVMXC__Page_Layout__c detailLayout = new SVMXC__Page_Layout__c();
        detailLayout.SVMXC__Page_Layout_ID__c = '2';
        detailLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
        detailLayout.SVMXC__Type__c = 'Detail';
        detailLayout.SVMXC__Header_Page_Layout__c = headerLayout.Id;
        insert detailLayout;  
        System.assertEquals(true, detailLayout != null);
       
       //Creating Sections For Header Page Layout
        List<SVMXC__Page_Layout_Detail__c> sectionList = new List<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c section1 = new SVMXC__Page_Layout_Detail__c();
        section1.SVMXC__Detail_Type__c = 'Section';
        section1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        section1.SVMXC__Page_Layout__c = headerLayout.Id;
        section1.SVMXC__Sequence__c = 1;
        sectionList.add(section1);
        
        SVMXC__Page_Layout_Detail__c section2 = new SVMXC__Page_Layout_Detail__c();
        section2.SVMXC__Detail_Type__c = 'Section';
        section2.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout2';
        section2.SVMXC__Page_Layout__c = headerLayout.Id;
        section2.SVMXC__Sequence__c = 2;
        sectionList.add(section2);
        
        SVMXC__Page_Layout_Detail__c section3 = new SVMXC__Page_Layout_Detail__c();
        section3.SVMXC__Detail_Type__c = 'Section';
        section3.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout3';
        section3.SVMXC__Page_Layout__c = headerLayout.Id;
        section3.SVMXC__Sequence__c = 2;
        insert section3;
        System.assertEquals(true, section3 != null);
        
        //Creating Fields For Sections of Header Page Layout
        List<SVMXC__Page_Layout_Detail__c> fieldList = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c field1 = new SVMXC__Page_Layout_Detail__c();
        field1.SVMXC__Detail_Type__c = 'Field';
        field1.SVMXC__Field_API_Name__c = 'SVMXC__Company__c';
        field1.SVMXC__Related_Object_Name__c = 'Account';
        field1.SVMXC__DataType__c = 'REFERENCE';
        field1.SVMXC__Page_Layout__c = headerLayout.Id;  
        field1.SVMXC__Sequence__c = 1;
        fieldList.add(field1);
        
        SVMXC__Page_Layout_Detail__c field2 = new SVMXC__Page_Layout_Detail__c();
        field2.SVMXC__Detail_Type__c = 'Field';
        field2.SVMXC__Page_Layout__c = headerLayout.Id;  
        field2.SVMXC__Field_API_Name__c = 'SVMXC__Actual_Initial_Response__c';
        field2.SVMXC__DataType__c = 'Date/Time';
        field2.SVMXC__Sequence__c = 2;
        fieldList.add(field2);
        
        SVMXC__Page_Layout_Detail__c field3 = new SVMXC__Page_Layout_Detail__c();
        field3.SVMXC__Detail_Type__c = 'Field';
        field3.SVMXC__Field_API_Name__c = 'SVMXC__Actual_Onsite_Response__c';
        field3.SVMXC__DataType__c = 'Date/Time';
        field3.SVMXC__Page_Layout__c = headerLayout.Id;  
        field3.SVMXC__Sequence__c = 3;
        fieldList.add(field3);
        
        SVMXC__Page_Layout_Detail__c field4 = new SVMXC__Page_Layout_Detail__c();
        field4.SVMXC__Detail_Type__c = 'Field';
        field4.SVMXC__Field_API_Name__c = 'SVMXC__Actual_Resolution__c';
        field4.SVMXC__DataType__c = 'Date/Time';
        field4.SVMXC__Page_Layout__c = headerLayout.Id;  
        field4.SVMXC__Sequence__c = 4;
        fieldList.add(field4);
        
        SVMXC__Page_Layout_Detail__c field5 = new SVMXC__Page_Layout_Detail__c();
        field5.SVMXC__Detail_Type__c = 'Field';
        field5.SVMXC__Field_API_Name__c = 'SVMXC__Customer_Down__c';
        field5.SVMXC__DataType__c = 'Checkbox';
        field5.SVMXC__Sequence__c = 1;
        field5.SVMXC__Page_Layout__c = headerLayout.Id;  
        fieldList.add(field5);
        
        SVMXC__Page_Layout_Detail__c field6 = new SVMXC__Page_Layout_Detail__c();
        field6.SVMXC__Detail_Type__c = 'Field';
        field6.SVMXC__Field_API_Name__c = 'SVMXC__Dispatch_Response__c';
        field6.SVMXC__DataType__c = 'Picklist';
        field6.SVMXC__Sequence__c = 2;
        field6.SVMXC__Page_Layout__c = headerLayout.Id;  
        fieldList.add(field6);
        
       //Creating Fields for Detail Page Layout
        SVMXC__Page_Layout_Detail__c field7 = new SVMXC__Page_Layout_Detail__c();
        field7.SVMXC__Detail_Type__c = 'Field';
        field7.SVMXC__Field_API_Name__c = 'SVMXC__Log_Against__c';
        field7.SVMXC__DataType__c = 'Picklist';
        field7.SVMXC__Page_Layout__c = detailLayout.Id;      
        field7.SVMXC__Sequence__c = 1;
        fieldList.add(field7);
        
        SVMXC__Page_Layout_Detail__c field8 = new SVMXC__Page_Layout_Detail__c();
        field8.SVMXC__Detail_Type__c = 'Field';
        field8.SVMXC__Field_API_Name__c = 'SVMXC__Posted_To_Inventory__c';
        field8.SVMXC__DataType__c = 'Checkbox';
        field8.SVMXC__Page_Layout__c = detailLayout.Id;
        field8.SVMXC__Sequence__c = 2;
        fieldList.add(field8);
        
         
        SVMXC__Page_Layout_Detail__c field9 = new SVMXC__Page_Layout_Detail__c();
        field9.SVMXC__Page_Layout__c = detailLayout.Id; 
        field9.SVMXC__Detail_Type__c = 'Field';
        field9.SVMXC__Field_API_Name__c = 'SVMXC__Posted_To_Inventory__c';
        field9.SVMXC__DataType__c = 'Checkbox';
        field9.SVMXC__Sequence__c = 2;
        insert field9;
        System.assertEquals(true, field9 != null);
        
       //Creating Buttons for Header and Detail Page Layouts
        List<SVMXC__Page_Layout_Detail__c> buttonList = new List<SVMXC__Page_Layout_Detail__c>();
        
        SVMXC__Page_Layout_Detail__c button1 = new SVMXC__Page_Layout_Detail__c();
        button1.SVMXC__Detail_Type__c = 'Button';
        button1.SVMXC__Title__c = 'Save';
        button1.SVMXC__Sequence__c = 1;
        buttonList.add(button1);

        SVMXC__Page_Layout_Detail__c button2 = new SVMXC__Page_Layout_Detail__c();
        button2.SVMXC__Detail_Type__c = 'Button';
        button2.SVMXC__Title__c = 'Cancel';
        button2.SVMXC__Sequence__c = 2;
        buttonList.add(button2);
        
        SVMXC__Page_Layout_Detail__c button3 = new SVMXC__Page_Layout_Detail__c();
        button3.SVMXC__Detail_Type__c = 'Button';
        button3.SVMXC__Page_Layout__c = detailLayout.Id;
        button3.SVMXC__Title__c = 'Cancel';
        button3.SVMXC__Sequence__c = 3;
        insert button3;
        System.assertEquals(true, button3 != null);
       
       //Creating Page Events for Page Load, Button Click and Field Exist
        List<SVMXC__SFM_Event__c> eventList = new List<SVMXC__SFM_Event__c>();
        SVMXC__SFM_Event__c event1 = new SVMXC__SFM_Event__c();
        event1.SVMXC__Event_Type__c = 'On Page Load';
        event1.SVMXC__URL_Window_Type__c = 'Self';
        event1.SVMXC__Target_Call__c = '';
        eventList.add(event1);

        SVMXC__SFM_Event__c event2 = new SVMXC__SFM_Event__c();
        event2.SVMXC__Event_Type__c = 'Button Click';
        event2.SVMXC__URL_Window_Type__c = '';
        event2.SVMXC__Target_Call__c = '';
        eventList.add(event2);
        
        SVMXC__SFM_Event__c event3 = new SVMXC__SFM_Event__c();
        event3.SVMXC__Event_Type__c = 'Button Click';
        event3.SVMXC__URL_Window_Type__c = '';
        event3.SVMXC__Target_Call__c = '';
        eventList.add(event3);

        SVMXC__SFM_Event__c event4 = new SVMXC__SFM_Event__c();
        event4.SVMXC__Event_Type__c = 'Field Change';
        event4.SVMXC__URL_Window_Type__c = '';
        event4.SVMXC__Target_Call__c = '';
        eventList.add(event4);
        
        SVMXC__SFM_Event__c event5 = new SVMXC__SFM_Event__c();
        event5.SVMXC__Event_Type__c = 'Field Change';
        event5.SVMXC__URL_Window_Type__c = '';
        event5.SVMXC__Page_Layout__c = headerLayout.Id;
        event5.SVMXC__Page_Layout_Detail__c = field9.id;
        event5.SVMXC__Target_Call__c = '';
        insert event5;
        System.assertEquals(true, event5 != null);
        
        List<SVMXC__SFM_Event__c> pageEvents1 = new List<SVMXC__SFM_Event__c>();
        pageEvents1.add(eventList[0]);
        
        List<SVMXC__SFM_Event__c> pageEvents2 = new List<SVMXC__SFM_Event__c>();
        pageEvents2.add(eventList[1]);
        
        List<SVMXC__SFM_Event__c> pageEvents3 = new List<SVMXC__SFM_Event__c>();
        pageEvents3.add(eventList[2]);
        
        List<SVMXC__SFM_Event__c> pageEvents4 = new List<SVMXC__SFM_Event__c>();
        pageEvents4.add(eventList[3]);
        
        SFM_WrapperDef.SFM_BubbleWrapper bubbleinfo = new SFM_WrapperDef.SFM_BubbleWrapper();
        SFM_WrapperDef.SFM_UIField fieldDetail1 = new SFM_WrapperDef.SFM_UIField(fieldList[0], NULL, bubbleinfo);
        SFM_WrapperDef.SFM_UIField fieldDetail2 = new SFM_WrapperDef.SFM_UIField(fieldList[1], NULL, bubbleinfo);
        SFM_WrapperDef.SFM_UIField fieldDetail3 = new SFM_WrapperDef.SFM_UIField(fieldList[2], NULL, bubbleinfo);
        SFM_WrapperDef.SFM_UIField fieldDetail4 = new SFM_WrapperDef.SFM_UIField(fieldList[3], NULL, bubbleinfo);
        SFM_WrapperDef.SFM_UIField fieldDetail5 = new SFM_WrapperDef.SFM_UIField(fieldList[4], NULL, bubbleinfo);
        SFM_WrapperDef.SFM_UIField fieldDetail6 = new SFM_WrapperDef.SFM_UIField(fieldList[5], NULL, bubbleinfo);
        SFM_WrapperDef.SFM_UIField fieldDetail7 = new SFM_WrapperDef.SFM_UIField(fieldList[6], NULL, bubbleinfo);
        SFM_WrapperDef.SFM_UIField fieldDetail8 = new SFM_WrapperDef.SFM_UIField(fieldList[7], NULL, bubbleinfo);
        
        List<SFM_WrapperDef.SFM_UIField> List_fieldDetail1 = new List<SFM_WrapperDef.SFM_UIField>();
        List_fieldDetail1.add(fieldDetail1);
        List_fieldDetail1.add(fieldDetail2);
        List_fieldDetail1.add(fieldDetail3);
        List_fieldDetail1.add(fieldDetail4);
        
        List<SFM_WrapperDef.SFM_UIField> List_fieldDetail2 = new List<SFM_WrapperDef.SFM_UIField>();
        List_fieldDetail2.add(fieldDetail5);
        List_fieldDetail2.add(fieldDetail6);
        
        List<SFM_WrapperDef.SFM_UIField> List_fieldDetail3 = new List<SFM_WrapperDef.SFM_UIField>();
        List_fieldDetail3.add(fieldDetail7);
        List_fieldDetail3.add(fieldDetail8);
        
        SFM_WrapperDef.SFM_UISection sectionDetail1 = new SFM_WrapperDef.SFM_UISection(sectionList[0],List_fieldDetail1);
        SFM_WrapperDef.SFM_UISection sectionDetail2 = new SFM_WrapperDef.SFM_UISection(sectionList[1],List_fieldDetail2);
        
        List<SFM_WrapperDef.SFM_UISection> List_sectionDetail = new List<SFM_WrapperDef.SFM_UISection>();
        List_sectionDetail.add(sectionDetail1);
        List_sectionDetail.add(sectionDetail2);
        
        SFM_WrapperDef.SFM_UIButton buttonDetail1 = new SFM_WrapperDef.SFM_UIButton(buttonList[0],pageEvents2);
        SFM_WrapperDef.SFM_UIButton buttonDetail3 = new SFM_WrapperDef.SFM_UIButton(buttonList[1],pageEvents3);
        
        List<SFM_WrapperDef.SFM_UIButton> List_buttonDetail1 = new List<SFM_WrapperDef.SFM_UIButton>();
        List_buttonDetail1.add(buttonDetail1);
        
        List<SFM_WrapperDef.SFM_UIButton> List_buttonDetail2 = new List<SFM_WrapperDef.SFM_UIButton>();
        List_buttonDetail2.add(buttonDetail3);
        
        SFM_WrapperDef.SFM_PageHeader pageHeader = new SFM_WrapperDef.SFM_PageHeader(headerLayout,List_sectionDetail,List_buttonDetail1,pageEvents1);
        
        List<SFM_WrapperDef.SFM_DetailBubbleWrapper> bubbleinfolist = new List<SFM_WrapperDef.SFM_DetailBubbleWrapper>();

        SFM_WrapperDef.SFM_PageDetail detail1 = new SFM_WrapperDef.SFM_PageDetail(detailLayout,List_fieldDetail3,List_buttonDetail2,bubbleinfolist);
        List<SFM_WrapperDef.SFM_PageDetail> details = new List<SFM_WrapperDef.SFM_PageDetail>();
        details.add(detail1);
       
       //Creating Object of SFM_WrapperDef.SFM_Request_PageUI to pass as parameter to the Class     
        SFM_WrapperDef.SFM_PageUI pageui = new SFM_WrapperDef.SFM_PageUI(pageHeader,details);
        SVMXC__ServiceMax_Processes__c processNode = new SVMXC__ServiceMax_Processes__c();
        processNode.RecordTypeId = TargetManager;
        processNode.SVMXC__Name__c = 'SFMPROCESSNAME001';
        processNode.SVMXC__ProcessID__c = 'SFMPROCESSNAME001';
        processNode.SVMXC__Rule_Type__c = 'Interactive';
        processNode.SVMXC__IsStandalone__c = true;
        processNode.SVMXC__Purpose__c = 'EDIT';
        processNode.SVMXC__Page_Layout__c = headerLayout.Id;
        insert processNode ;
        //Creating List of StringMap
        List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap Stringmapcls1 = new SFM_WrapperDef.SFM_StringMap('RECORDID',processNode.Id);
        ListOfStringMap.add(Stringmapcls1);
        
        SFM_WrapperDef.SFM_StringMap SaveType = new SFM_WrapperDef.SFM_StringMap('SAVETYPE','SAVE');
        
        SFM_WrapperDef.SFM_Request pmax = new SFM_WrapperDef.SFM_Request('','','',ListOfStringMap);
        SFM_WrapperDef.SFM_Request_PageUI requestpage = new SFM_WrapperDef.SFM_Request_PageUI(pageui,processNode,pmax);
        requestpage.request.stringMap.add(SaveType);
       //Creating Object of the Class and Calling the Method       
        SFM_savePageLayout pagelayout = new SFM_savePageLayout();
        
        //SVMXC.SFM_WrapperDef.SFM_PageUI PageUI = new SVMXC.SFM_WrapperDef.SFM_PageUI();
        requestpage.page = PageUI;
        requestpage.processNode = processNode;
        //requestpage.header = 
        pagelayout.SFM_SavePageLayout(requestpage);
        
        
        SFM_WrapperDef.SFM_StringMap SaveType1 = new SFM_WrapperDef.SFM_StringMap('SAVETYPE','SAVEAS');
        SFM_WrapperDef.SFM_Request_PageUI requestpage1 = new SFM_WrapperDef.SFM_Request_PageUI(pageui,processNode,pmax);
        requestpage1.request.stringMap.add(SaveType1);
        //SVMXC.SFM_WrapperDef.SFM_PageUI PageUI = new SVMXC.SFM_WrapperDef.SFM_PageUI();
        requestpage1.page = PageUI;
        requestpage1.processNode = processNode;
        //requestpage.header = 
        pagelayout.SFM_SavePageLayout(requestpage1);
        SVMXC.SFM_WrapperDef.SFM_Response varSFM = pagelayout.SFM_SaveSectionExitCriteria(requestpage1);
        //---------------------------
        section1.SVMXC__SM_Description__c = 'sectionLayout1 Description ...............';
        section1.SVMXC__SM_Help_URL__c = 'test1.com';
        
        List<SFM_WrapperDef.SFM_UIField> List_fieldDetail11 = new List<SFM_WrapperDef.SFM_UIField>();
         SFM_WrapperDef.SFM_UISection sectionDetail11 = new SFM_WrapperDef.SFM_UISection(section1,List_fieldDetail11);
        SFM_WrapperDef.SFM_UISection sectionDetail12 = new SFM_WrapperDef.SFM_UISection(section2,List_fieldDetail11);
        List<SFM_WrapperDef.SFM_UISection> List_sectionDetail1 = new List<SFM_WrapperDef.SFM_UISection>();
        List_sectionDetail1.add(sectionDetail11);
        List_sectionDetail1.add(sectionDetail12);
        
        List<SFM_WrapperDef.SFM_PageDetail> details1 = new List<SFM_WrapperDef.SFM_PageDetail>();
        
        
         List<SVMXC__SFM_Event__c> pageEventstest = new List<SVMXC__SFM_Event__c>();
        List<SFM_WrapperDef.SFM_UIButton> List_buttonDetail11 = new List<SFM_WrapperDef.SFM_UIButton>();
         SFM_WrapperDef.SFM_PageHeader pageHeader1 = new SFM_WrapperDef.SFM_PageHeader(headerLayout,List_sectionDetail1,List_buttonDetail11,pageEventstest);
         SFM_WrapperDef.SFM_PageUI pageui1 = new SFM_WrapperDef.SFM_PageUI(pageHeader1,details1);
        // SVMXC__ServiceMax_Processes__c processNode = new SVMXC__ServiceMax_Processes__c();
          List<SFM_WrapperDef.SFM_StringMap> ListOfStringMap1 = new List<SFM_WrapperDef.SFM_StringMap>();
          SFM_WrapperDef.SFM_Request pmax1 = new SFM_WrapperDef.SFM_Request('','','',ListOfStringMap1);
         SFM_WrapperDef.SFM_Request_PageUI requestpage11 = new SFM_WrapperDef.SFM_Request_PageUI(pageui1,processNode,pmax1);
        //requestpage.request.stringMap.add(SaveType);
       //Creating Object of the Class and Calling the Method       
        SFM_savePageLayout pagelayout1 = new SFM_savePageLayout();
        
        //SVMXC.SFM_WrapperDef.SFM_PageUI PageUI = new SVMXC.SFM_WrapperDef.SFM_PageUI();
        requestpage11.page = pageui1;
        requestpage11.processNode = processNode;
        //requestpage.header = 
        
            system.debug('requestpage : '+requestpage11);
            system.debug('Response : '+pagelayout1.SFM_SaveSectionInfo(requestpage11));
            try
            {
                 SFM_WrapperDef.SFM_Request_PageUI requestpage12 = new SFM_WrapperDef.SFM_Request_PageUI();
                 
                requestpage12.page = pageui1;
                requestpage12.processNode = processNode;
                //requestpage.header = 
        
                system.debug('requestpage : '+requestpage12);
                system.debug('Response : '+pagelayout1.SFM_SaveSectionInfo(requestpage12));
            }
            catch(exception e){}
            
            //--------------------
            String RuleRecordTypeId = '';
        //String TargetManager = '';
        //String ProcessNodeObj = '';
        String ProBizRuleRTypeId = '';
        String ExpressionRTypeId = '';
        
         for(RecordType RType : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'])
        {
            if(RType.Name == 'Business Rule')
                RuleRecordTypeId = RType.id;
            else if(RType.Name == 'Expressions')
                ExpressionRTypeId = RType.id;
            if(RType.Name == 'Target Manager')
                TargetManager = RType.id;
            else if(RType.Name == 'Process Node Objects')    
                ProcessNodeObj = RType.id;
            else if(RType.Name == 'Process Business Rule')
                ProBizRuleRTypeId = RType.id;
        }
        SVMXC__ServiceMax_Processes__c BizRule1 = new SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Config_Data__c> lstBizRuleExpr = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr11 = new SVMXC__ServiceMax_Config_Data__c();
        SVMXC__ServiceMax_Config_Data__c BizRuleExpr12 = new SVMXC__ServiceMax_Config_Data__c();
        BizRule1.RecordTypeId = RuleRecordTypeId;
        BizRule1.SVMXC__Name__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__ProcessID__c = 'My_Biz_Rule_001';
        BizRule1.SVMXC__Description__c = 'Test Biz Rule 001';
        BizRule1.SVMXC__Source_Object_Name__c = 'Case';
        BizRule1.SVMXC__Advance_Expression__c = '1 AND 2';
        BizRule1.SVMXC__Parent_Error_Msg__c = 'Case should be High Priority, should not be Low priority';
        BizRule1.SVMXC__Message_Type__c = 'Error';
        insert BizRule1;
    
        BizRuleExpr11.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr11.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr11.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr11.SVMXC__Sequence__c = 1;
        BizRuleExpr11.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr11.SVMXC__Field_Name__c = 'Priority';
        BizRuleExpr11.SVMXC__Operator__c = 'eq';
        BizRuleExpr11.SVMXC__Operand__c = 'High';
        BizRuleExpr11.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        BizRuleExpr11.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr11.SVMXC__Display_Type__c = 'PICKLIST';
        BizRuleExpr11.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr11.SVMXC__FKey_Name_Field__c = NULL;
        lstBizRuleExpr.add(BizRuleExpr11);
        
        BizRuleExpr12.RecordTypeId = ExpressionRTypeId;
        BizRuleExpr12.SVMXC__Expression_Rule__c = BizRule1.Id;
        BizRuleExpr12.SVMXC__Expression_Type__c = 'Business_Rule';
        BizRuleExpr12.SVMXC__Sequence__c = 2;
        BizRuleExpr12.SVMXC__Object_Name__c = 'Case';
        BizRuleExpr12.SVMXC__Field_Name__c = 'ParentId';
        BizRuleExpr12.SVMXC__Operator__c = 'ne';
        BizRuleExpr12.SVMXC__Parameter_Type__c = 'FIELD VALUE';
        BizRuleExpr12.SVMXC__Operand__c = NULL;
        BizRuleExpr12.SVMXC__Object_Name2__c = 'Case';
        BizRuleExpr12.SVMXC__Display_Type__c = 'REFERENCE';
        BizRuleExpr12.SVMXC__Field_Relationship_Name__c = NULL;
        BizRuleExpr12.SVMXC__FKey_Name_Field__c = NULL;
        lstBizRuleExpr.add(BizRuleExpr12);
        insert lstBizRuleExpr;
        //SFM_BizRuleUtils objBizRuleUtils = new SFM_BizRuleUtils();
        SFM_savePageLayout pagelayout3 = new SFM_savePageLayout();
        SVMXC.SFM_WrapperDef.SFM_Request request = new SVMXC.SFM_WrapperDef.SFM_Request();
        List<SVMXC__ServiceMax_Config_Data__c> BizRuleExprs = new List<SVMXC__ServiceMax_Config_Data__c>();
        BizRuleExprs.add(BizRuleExpr11);
        BizRuleExprs.add(BizRuleExpr12);
        
        
        //request.bizRuleInfo = new SVMXC.SFM_WrapperDef.SFM_BizRuleInfo(BizRule1, BizRuleExprs);
        
        
         Id targetManagerProcessId = createTargetManagerProcess();
         upsert SEction1;
         
                SVMXC.SFM_WrapperDef.SFM_MapStringMap MapStrMap = new SVMXC.SFM_WrapperDef.SFM_MapStringMap();
                MapStrMap.key = 'ENTRY CRITERIA';
                    
                SVMXC.SFM_WrapperDef.SFM_StringMap processmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();               
                processmap.key = 'PROCESSID';
                processmap.value = targetManagerProcessId;
                
                SVMXC.SFM_WrapperDef.SFM_StringMap sectionIdValmap = new SVMXC.SFM_WrapperDef.SFM_StringMap();              
                sectionIdValmap.key = 'SECTIONID';
                sectionIdValmap.value = SEction1.id;
                
                SVMXC.SFM_WrapperDef.SFM_StringMap EntryCriteriamap = new SVMXC.SFM_WrapperDef.SFM_StringMap();             
                EntryCriteriamap.key = 'EntryCriteriaID';
                EntryCriteriamap.value = BizRule1.id;
                
                SVMXC.SFM_WrapperDef.SFM_StringMap EnableEntryCriteriamap = new SVMXC.SFM_WrapperDef.SFM_StringMap();               
                EnableEntryCriteriamap.key = 'EnableEntryCriteria';
                
                EnableEntryCriteriamap.value = 'false';
                MapStrMap.valuemap.add(processmap);
                MapStrMap.valuemap.add(EntryCriteriamap);
                MapStrMap.valuemap.add(EnableEntryCriteriamap);
                MapStrMap.valuemap.add(sectionIdValmap);
                system.debug('request : '+request);
                 
                requestpage1.page.header.sections[0].entryCriteriaId = BizRule1.id; 
                requestpage1.page.header.sections[0].enableEntryCriteria = 'true'; 
                system.debug('Resp : '+  pagelayout3.SFM_SaveSectionEntryCriteria(request));
        
        
                request.lstMapStringMap.add(MapStrMap);
                system.debug('Resp : '+  pagelayout3.SFM_SaveSectionEntryCriteria(request));
                system.debug('Resp : '+  pagelayout3.SFM_savePageLayout(requestpage1));
            
            //----------------------
        
    }
    
    public static Id createTargetManagerProcess(){
        getRecordTypeIds();
        SVMXC__ServiceMax_Processes__c checklistTargetRecord = new SVMXC__ServiceMax_Processes__c();
        checklistTargetRecord.RecordTypeId = recordTypeIdMap.get('Target_Manager');
        checklistTargetRecord.SVMXC__Name__c = 'Checklist Test0001';
        checklistTargetRecord.SVMXC__ProcessID__c = 'Checklist_Test0001';
        checklistTargetRecord.SVMXC__Purpose__c = 'CHECKLIST';
        checklistTargetRecord.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        checklistTargetRecord.SVMXC__Dispatch_Process_Status__c = 'Complete';
        checklistTargetRecord.SVMXC__Tag_Keys__c = 'Checklist_Test0001';
        insert checklistTargetRecord;  
        return checklistTargetRecord.Id;
    }
    public static void getRecordTypeIds(){
        for(RecordType rec : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c') AND isActive = true]){
           recordTypeIdMap.put(rec.DeveloperName, rec.Id); 
        }
    }
}