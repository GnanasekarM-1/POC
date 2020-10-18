@isTest
private class INTF_GetPageLayout_UT
{
    static testMethod void INTF_GetPageLayout_UT_Test()
    {       
       /*--------------------------------DATA CREATION-----------------------------*/
       //--------------------Creating Header PageLayout
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        headerLayout.SVMXC__Page_Layout_ID__c = '1';
        headerLayout.SVMXC__Object_Name__c = 'SVMXC__Quote__c';
        headerLayout.SVMXC__Type__c = 'Header';
        insert headerLayout;
        System.assertEquals(true, headerLayout != null);
       
       //-------------------Creating Detail PageLayout
        List<SVMXC__Page_Layout__c> detailLayout_list = new List<SVMXC__Page_Layout__c>();
        SVMXC__Page_Layout__c detailLayout = new SVMXC__Page_Layout__c();
        detailLayout.SVMXC__Object_Name__c = 'SVMXC__Quote_Line__c';
        detailLayout.SVMXC__Type__c = 'Detail';
        detailLayout.SVMXC__Header_Page_Layout__c = headerLayout.Id;
        insert detailLayout; 
        
        detailLayout_list.add(headerLayout);
        detailLayout_list.add(detailLayout);//*****
        System.assertNotEquals(headerLayout, detailLayout);
        
       //----------------------Creating Sections For Header Page Layout
        List<SVMXC__Page_Layout_Detail__c> sectionList = new List<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c section1 = new SVMXC__Page_Layout_Detail__c();
        section1.SVMXC__Detail_Type__c = 'Section';
        section1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        section1.SVMXC__Page_Layout__c = headerLayout.Id;
        section1.SVMXC__Sequence__c = 1;
        section1.SVMXC__DataType__c = 'REFERENCE';//*****
        sectionList.add(section1);
        
        SVMXC__Page_Layout_Detail__c section2 = new SVMXC__Page_Layout_Detail__c();
        section2.SVMXC__Detail_Type__c = 'Section';
        section2.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout2';
        section2.SVMXC__Page_Layout__c = headerLayout.Id;
        section2.SVMXC__Sequence__c = 2;
        section2.SVMXC__DataType__c = 'REFERENCE';//*****
        sectionList.add(section2);
        System.debug('*****'+sectionList);
        insert sectionList;
        System.assertEquals(true, sectionList != null);
        
        SVMXC__Page_Layout_Detail__c section3 = new SVMXC__Page_Layout_Detail__c();
        section3.SVMXC__Detail_Type__c = 'Section';
        section3.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout3';
        section3.SVMXC__Page_Layout__c = headerLayout.Id;
        section3.SVMXC__Sequence__c = 2;
        section3.SVMXC__DataType__c = 'REFERENCE';//*****
        insert section3;
        System.assertEquals(true, section3 != null);
        System.debug('section3'+sectionList);
        
        //--------------------Creating Fields For Sections of Header Page Layout
        List<SVMXC__Page_Layout_Detail__c> fieldList = new List<SVMXC__Page_Layout_Detail__c>();    
        SVMXC__Page_Layout_Detail__c field1 = new SVMXC__Page_Layout_Detail__c();
        field1.SVMXC__Detail_Type__c = 'Field';
        field1.SVMXC__Field_API_Name__c = 'SVMXC__Company__c';
        field1.SVMXC__Related_Object_Name__c = 'Account';
        field1.SVMXC__Page_Layout__c = headerLayout.Id;
        field1.SVMXC__Section__c = section1.Id;
        field1.SVMXC__DataType__c = 'REFERENCE';
        field1.SVMXC__Sequence__c = 1;      
        fieldList.add(field1);
        
        SVMXC__Page_Layout_Detail__c field2 = new SVMXC__Page_Layout_Detail__c();
        field2.SVMXC__Detail_Type__c = 'Field';//*****Changed button - field
        field2.SVMXC__Named_Search__c =field1.Id;//*****
        field2.SVMXC__Related_Object_Name_Field__c ='Name';//*****
        field2.SVMXC__Field_API_Name__c = 'SVMXC__Discount_Type__c';
        field2.SVMXC__DataType__c = 'picklist';
        field2.SVMXC__Page_Layout__c = headerLayout.Id;
        field2.SVMXC__Section__c = section1.Id;
        field2.SVMXC__Sequence__c = 2;
        fieldList.add(field2);
        
        SVMXC__Page_Layout_Detail__c field3 = new SVMXC__Page_Layout_Detail__c();
        field3.SVMXC__Detail_Type__c = 'Field';
        field3.SVMXC__Field_API_Name__c = 'SVMXC__Discount__c';
        field3.SVMXC__DataType__c = 'Number';//*****
        field3.SVMXC__Page_Layout__c = headerLayout.Id;
        field3.SVMXC__Section__c = section1.Id;
        field3.SVMXC__Sequence__c = 3;
        fieldList.add(field3);
        System.debug('field3'+fieldList);
        
        SVMXC__Page_Layout_Detail__c field4 = new SVMXC__Page_Layout_Detail__c();
        field4.SVMXC__Detail_Type__c = 'Field';
        field4.SVMXC__Field_API_Name__c = 'SVMXC__Valid_Until__c';
        field4.SVMXC__DataType__c = 'Date';
        field4.SVMXC__Page_Layout__c = headerLayout.Id;
        field4.SVMXC__Section__c = section1.Id;
        field4.SVMXC__Sequence__c = 4;
        fieldList.add(field4);
        
        SVMXC__Page_Layout_Detail__c field5 = new SVMXC__Page_Layout_Detail__c();
        field5.SVMXC__Detail_Type__c = 'Field';
        field5.SVMXC__Field_API_Name__c = 'SVMXC__Service_Order__c';
        field5.SVMXC__Related_Object_Name__c = 'SVMXC__Service_Order__c';
        field5.SVMXC__DataType__c = 'REFERENCE';
        field5.SVMXC__Page_Layout__c = headerLayout.Id;
        field5.SVMXC__Section__c = section2.Id;
        field5.SVMXC__Sequence__c = 1;
        fieldList.add(field5);
        
        SVMXC__Page_Layout_Detail__c field6 = new SVMXC__Page_Layout_Detail__c();
        field6.SVMXC__Detail_Type__c = 'Field';
        field6.SVMXC__Field_API_Name__c = 'SVMXC__Status__c';
        field6.SVMXC__DataType__c = 'Picklist';
        field6.SVMXC__Page_Layout__c = headerLayout.Id;
        field6.SVMXC__Section__c = section2.Id;
        field6.SVMXC__Sequence__c = 2;
        fieldList.add(field6);
        
       //---------------------------Creating Fields for Detail Page Layout
        SVMXC__Page_Layout_Detail__c field7 = new SVMXC__Page_Layout_Detail__c();
        field7.SVMXC__Detail_Type__c = 'Field';
        field7.SVMXC__Field_API_Name__c = 'SVMXC__Discount_Type__c';
        field7.SVMXC__DataType__c = 'Picklist';
        field7.SVMXC__Page_Layout__c = detailLayout.Id;      
        field7.SVMXC__Sequence__c = 1;
        fieldList.add(field7);
        
        SVMXC__Page_Layout_Detail__c field8 = new SVMXC__Page_Layout_Detail__c();
        field8.SVMXC__Detail_Type__c = 'Field';
        field8.SVMXC__Field_API_Name__c = 'SVMXC__Select__c';
        field8.SVMXC__DataType__c = 'Checkbox';
        field8.SVMXC__Page_Layout__c = detailLayout.Id;      
        field8.SVMXC__Sequence__c = 2;
        fieldList.add(field8);
        insert fieldList;
        System.assertEquals(true, fieldList != null);

        SVMXC__Page_Layout_Detail__c field9 = new SVMXC__Page_Layout_Detail__c();
        field9.SVMXC__Detail_Type__c = 'Field';
        field9.SVMXC__Field_API_Name__c = 'SVMXC__Product__c';
        field9.SVMXC__DataType__c = 'REFERENCE';
        field9.SVMXC__Sequence__c = 3;
        field9.SVMXC__Page_Layout__c = detailLayout.Id;
        insert field9;
        System.assertEquals(true, field9 != null);
        
       //-------------------------Creating Buttons for Header and Detail Page Layouts
        List<SVMXC__Page_Layout_Detail__c> buttonList = new List<SVMXC__Page_Layout_Detail__c>();
        List<SVMXC__Page_Layout_Detail__c> buttonList2 = new List<SVMXC__Page_Layout_Detail__c>();//*****
        
        SVMXC__Page_Layout_Detail__c button1 = new SVMXC__Page_Layout_Detail__c();
        button1.SVMXC__Detail_Type__c = 'Button';
        button1.SVMXC__Title__c = 'Save';
        button1.SVMXC__Page_Layout__c = headerLayout.Id;
        button1.SVMXC__Sequence__c = 1;
        button1.SVMXC__DataType__c = 'REFERENCE';//*****
        buttonList.add(button1);

        SVMXC__Page_Layout_Detail__c button2 = new SVMXC__Page_Layout_Detail__c();
        button2.SVMXC__Detail_Type__c = 'Button';
        button2.SVMXC__Title__c = 'Cancel';
        button2.SVMXC__Page_Layout__c = detailLayout.Id;
        button2.SVMXC__Sequence__c = 2;
        button2.SVMXC__DataType__c = 'REFERENCE';//*****
        buttonList.add(button2);
        
        SVMXC__Page_Layout_Detail__c button4 = new SVMXC__Page_Layout_Detail__c();
        button4.SVMXC__Detail_Type__c = 'Button';
        button4.SVMXC__Title__c = 'Cancel';
        button4.SVMXC__Page_Layout__c = headerLayout.Id;
        button4.SVMXC__Sequence__c = 4;
        button4.SVMXC__DataType__c = 'REFERENCE';//*****
        buttonList.add(button4);
        
        insert buttonList;
        System.assertEquals(true, buttonList != null);
        
        SVMXC__Page_Layout_Detail__c button3 = new SVMXC__Page_Layout_Detail__c();
        button3.SVMXC__Detail_Type__c = 'Button';
        button3.SVMXC__Page_Layout__c = headerLayout.Id;
        button3.SVMXC__Title__c = 'Cancel';
        button3.SVMXC__Sequence__c = 3;
        insert button3;
        System.assertEquals(true, button3 != null);
       
       //----------------Creating Page Events for Page Load, Button Click and Field Exist
        List<SVMXC__SFM_Event__c> eventList = new List<SVMXC__SFM_Event__c>();
        SVMXC__SFM_Event__c event1 = new SVMXC__SFM_Event__c();
        event1.SVMXC__Event_Type__c = 'On Page Load';
        event1.SVMXC__URL_Window_Type__c = 'Self';
        event1.SVMXC__Target_Call__c = '';
        event1.SVMXC__Page_Layout__c = headerLayout.Id;
        eventList.add(event1);

        SVMXC__SFM_Event__c event2 = new SVMXC__SFM_Event__c();
        event2.SVMXC__Event_Type__c = 'Button Click';
        event2.SVMXC__URL_Window_Type__c = '';
        event2.SVMXC__Target_Call__c = '';
        event2.SVMXC__Page_Layout_Detail__c  = event1.id;//*****
        event2.SVMXC__Page_Layout__c = headerLayout.Id;
        eventList.add(event2);
        
        SVMXC__SFM_Event__c event3 = new SVMXC__SFM_Event__c();
        event3.SVMXC__Event_Type__c = 'Button Click';
        event3.SVMXC__URL_Window_Type__c = '';
        event3.SVMXC__Page_Layout_Detail__c  = event2.id;//*****
        event3.SVMXC__Target_Call__c = '';
        event3.SVMXC__Page_Layout__c = detailLayout.Id;
        eventList.add(event3);

        SVMXC__SFM_Event__c event4 = new SVMXC__SFM_Event__c();
        event4.SVMXC__Event_Type__c = 'Field Change';
        event4.SVMXC__URL_Window_Type__c = '';
        event4.SVMXC__Target_Call__c = '';
        event4.SVMXC__Page_Layout__c = headerLayout.Id;
        event4.SVMXC__Page_Layout_Detail__c = field1.id;
        eventList.add(event4);
        
        SVMXC__SFM_Event__c event6 = new SVMXC__SFM_Event__c();
        event6.SVMXC__Event_Type__c = 'Button Click';
        event6.SVMXC__URL_Window_Type__c = '';
        event6.SVMXC__Target_Call__c = '';
        event6.SVMXC__Page_Layout__c = headerLayout.Id;
        event6.SVMXC__Page_Layout_Detail__c = button2.id;
        eventList.add(event6);
        insert eventList;
        System.assertEquals(true, eventList != null);
        
        SVMXC__SFM_Event__c event5 = new SVMXC__SFM_Event__c();
        event5.SVMXC__Event_Type__c = 'Field Change';
        event5.SVMXC__URL_Window_Type__c = '';
        event5.SVMXC__Page_Layout__c = headerLayout.Id;
        event5.SVMXC__Page_Layout_Detail__c = field9.id;
        event5.SVMXC__Target_Call__c = '';
        insert event5;
        System.assertEquals(true, event5 != null);
        
        //----------------------------------Creating List of Page Events
        List<SVMXC__SFM_Event__c> pageEvents1 = new List<SVMXC__SFM_Event__c>();
        pageEvents1.add(eventList[0]);
        
        List<SVMXC__SFM_Event__c> pageEvents2 = new List<SVMXC__SFM_Event__c>();
        pageEvents2.add(eventList[1]);
        
        List<SVMXC__SFM_Event__c> pageEvents3 = new List<SVMXC__SFM_Event__c>();
        pageEvents3.add(eventList[2]);
        
        List<SVMXC__SFM_Event__c> pageEvents4 = new List<SVMXC__SFM_Event__c>();
        pageEvents4.add(eventList[3]);
        
        List<SVMXC__SFM_Event__c> pageEvents5 = new List<SVMXC__SFM_Event__c>();
        pageEvents5.add(eventList[4]);
        
        //------------------------------------------Creating instace of BubbleWrapper
        INTF_WebServicesDef.INTF_BubbleWrapper bubbleinfo = new INTF_WebServicesDef.INTF_BubbleWrapper();
        
        //---------------------------------------Creating UIFields
        INTF_WebServicesDef.INTF_UIField fieldDetail1 = new INTF_WebServicesDef.INTF_UIField(fieldList[0], pageEvents1, bubbleinfo);
        INTF_WebServicesDef.INTF_UIField fieldDetail2 = new INTF_WebServicesDef.INTF_UIField(fieldList[1], NULL, bubbleinfo);
        INTF_WebServicesDef.INTF_UIField fieldDetail3 = new INTF_WebServicesDef.INTF_UIField(fieldList[2], NULL, bubbleinfo);
        INTF_WebServicesDef.INTF_UIField fieldDetail4 = new INTF_WebServicesDef.INTF_UIField(fieldList[3], NULL, bubbleinfo);
        INTF_WebServicesDef.INTF_UIField fieldDetail5 = new INTF_WebServicesDef.INTF_UIField(fieldList[4], NULL, bubbleinfo);
        INTF_WebServicesDef.INTF_UIField fieldDetail6 = new INTF_WebServicesDef.INTF_UIField(fieldList[5], NULL, bubbleinfo);
        INTF_WebServicesDef.INTF_UIField fieldDetail7 = new INTF_WebServicesDef.INTF_UIField(fieldList[6], NULL, bubbleinfo);
        INTF_WebServicesDef.INTF_UIField fieldDetail8 = new INTF_WebServicesDef.INTF_UIField(fieldList[7], NULL, bubbleinfo);
        
        List<INTF_WebServicesDef.INTF_UIField> List_fieldDetail1 = new List<INTF_WebServicesDef.INTF_UIField>();
        List_fieldDetail1.add(fieldDetail1);
        List_fieldDetail1.add(fieldDetail2);
        List_fieldDetail1.add(fieldDetail3);
        List_fieldDetail1.add(fieldDetail4);
        
        List<INTF_WebServicesDef.INTF_UIField> List_fieldDetail2 = new List<INTF_WebServicesDef.INTF_UIField>();
        List_fieldDetail2.add(fieldDetail5);
        List_fieldDetail2.add(fieldDetail6);
        
        List<INTF_WebServicesDef.INTF_UIField> List_fieldDetail3 = new List<INTF_WebServicesDef.INTF_UIField>();
        List_fieldDetail3.add(fieldDetail7);
        List_fieldDetail3.add(fieldDetail8);
        
        //------------------------------------Creating UISection
        INTF_WebServicesDef.INTF_UISection sectionDetail1 = new INTF_WebServicesDef.INTF_UISection(sectionList[0],List_fieldDetail1);
        INTF_WebServicesDef.INTF_UISection sectionDetail2 = new INTF_WebServicesDef.INTF_UISection(sectionList[1],List_fieldDetail2);
        
        List<INTF_WebServicesDef.INTF_UISection> List_sectionDetail = new List<INTF_WebServicesDef.INTF_UISection>();
        List_sectionDetail.add(sectionDetail1);
        List_sectionDetail.add(sectionDetail2);
        
        //-----------------------------------Creating UIButtons
        INTF_WebServicesDef.INTF_UIButton buttonDetail1 = new INTF_WebServicesDef.INTF_UIButton(buttonList[0],pageEvents2);
        INTF_WebServicesDef.INTF_UIButton buttonDetail2 = new INTF_WebServicesDef.INTF_UIButton(buttonList[2],pageEvents2);
        INTF_WebServicesDef.INTF_UIButton buttonDetail3 = new INTF_WebServicesDef.INTF_UIButton(buttonList[1],pageEvents3);
        INTF_WebServicesDef.INTF_UIButton buttonDetail4 = new INTF_WebServicesDef.INTF_UIButton(buttonList[1],pageEvents4);//*****
        INTF_WebServicesDef.INTF_UIButton buttonDetail5 = new INTF_WebServicesDef.INTF_UIButton(buttonList[1],pageEvents5);//*****
        
        List<INTF_WebServicesDef.INTF_UIButton> List_buttonDetail1 = new List<INTF_WebServicesDef.INTF_UIButton>();
        List_buttonDetail1.add(buttonDetail1);
        List_buttonDetail1.add(buttonDetail2);
        
        List<INTF_WebServicesDef.INTF_UIButton> List_buttonDetail2 = new List<INTF_WebServicesDef.INTF_UIButton>();
        List_buttonDetail2.add(buttonDetail3);
        List_buttonDetail2.add(buttonDetail4);
        List_buttonDetail2.add(buttonDetail5);
        
        //-----------------------------------Creating PageHeaders
        INTF_WebServicesDef.INTF_PageHeader pageHeader = new INTF_WebServicesDef.INTF_PageHeader(headerLayout,List_sectionDetail,List_buttonDetail1,pageEvents1);
        
        //-----------------------------------Creating List of INTF_DetailBubbleWrapper
        List<INTF_WebServicesDef.INTF_DetailBubbleWrapper> bubbleinfolist = new List<INTF_WebServicesDef.INTF_DetailBubbleWrapper>();
        
        //----------------------------------Creating List of Page Details
        INTF_WebServicesDef.INTF_PageDetail detail1 = new INTF_WebServicesDef.INTF_PageDetail(detailLayout,List_fieldDetail3,List_buttonDetail2,bubbleinfolist);
        List<INTF_WebServicesDef.INTF_PageDetail> details = new List<INTF_WebServicesDef.INTF_PageDetail>();
        details.add(detail1);
        
        //---------------------------------Creating RecordTypes
        List<RecordType> lstRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' OR SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
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
        Account account;
        Contact contact;
        Case case1;
        SVMXC__Service_Order__c workorder;
        account = new Account(
                                Name ='Account',
                                ShippingStreet='ABC',
                                ShippingCity='PQR ',
                                ShippingState = 'XYZ',
                                ShippingPostalCode='111',
                                ShippingCountry='XYZ',
                                BillingStreet='ABC',
                                BillingCity='PQR ',
                                BillingState = 'XYZ',
                                BillingPostalCode='111',
                                BillingCountry='XYZ'
                            ); 
        insert account;
        System.assertEquals(true, account != null);
        
        contact = new Contact(          
                                LastName='Last',
                                AccountId = account.Id,
                                Email='svmxmailfortest@servicemax.com'
                            );
        insert contact;
        System.assertEquals(true, contact != null);
        case1 = new Case(Status ='New', Priority = 'Medium', 
                         Origin = 'Email',                                        
                         //CurrencyIsoCode = 'USD',                                            
                         ContactId =contact.Id,
                         AccountId=account.Id
                        ); 
        insert case1;
        Product2 p2 = new Product2();
        p2.Name = 'Product';
        p2.Family = 'asdf';
        insert p2;
        System.assertEquals(true, case1 != null);
        workorder = new SVMXC__Service_Order__c(
                                                    SVMXC__Company__c = account.Id,
                                                    SVMXC__Contact__c = contact.Id,
                                                    SVMXC__Case__c = case1.Id,
                                                    SVMXC__Order_Status__c = 'Open',
                                                    SVMXC__Priority__c = 'Medium',
                                                    SVMXC__Order_Type__c = 'Field Service'
                                                    //CurrencyIsoCode = 'USD'
                                                    );
        insert workorder;
        SVMXC__Service_Order_Line__c WODetail = new SVMXC__Service_Order_Line__c();
        WODetail.SVMXC__Service_Order__c = workorder.id;
        WODetail.SVMXC__Product__c = p2.id;
        insert WODetail;
        
        SVMXC__Quote__c quote = new SVMXC__Quote__c();
        quote.SVMXC__Company__c = account.id;
        quote.SVMXC__Discount__c = 12;
        quote.SVMXC__Discount_Type__c = 'Ammount';
        quote.SVMXC__Valid_Until__c = system.today()+15;
        quote.SVMXC__Status__c = 'Open';
        
        insert quote;
        SVMXC__Quote_Line__c quoteLine = new SVMXC__Quote_Line__c();
        quoteLine.SVMXC__Discount_Type__c = 'Amount';
        quoteLine.SVMXC__Select__c = true;
        quoteLine.SVMXC__Quote__c = quote.id;
        quoteLine.SVMXC__Product__c = p2.id;
        
        insert quoteLine;
        System.assertEquals(true, workorder != null);
        
        //----------------------------Creating Page, Process, and Request to pass it to Request_PageUI
        INTF_WebServicesDef.INTF_PageUI page = new INTF_WebServicesDef.INTF_PageUI(pageHeader,details);
        SVMXC__ServiceMax_Processes__c SFMProcess = new SVMXC__ServiceMax_Processes__c();
        SFMProcess.SVMXC__Page_Layout__c = headerLayout.ID;
        SFMProcess.SVMXC__ProcessID__c='PROCESS11';
        SFMProcess.SVMXC__Name__c = 'Create WO From Case';
        SFMProcess.RecordTypeId = TargetManager; //processNode.RecordTypeId = AllRecordTypes[0].Id;
        SFMProcess.SVMXC__Purpose__c = 'SOURCE TO TARGET ALL';
        SFMProcess.SVMXC__Dispatch_Process_Status__c = 'COMPLETE';
        insert SFMProcess;
        
        
        //---------------------------------------Creating ProcessNode
        SVMXC__ServiceMax_Processes__c processNodeObj1 = new SVMXC__ServiceMax_Processes__c();
        processNodeObj1.SVMXC__Page_Layout__c = headerLayout.ID;
        processNodeObj1.RecordTypeId = ProcessNodeObj;
        processNodeObj1.SVMXC__Process__c = SFMProcess.Id;
        processNodeObj1.SVMXC__Type__c = 'TARGET';
        processNodeObj1.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';       
        insert processNodeObj1;
         
        SVMXC__ServiceMax_Processes__c processNodeObj2 = new SVMXC__ServiceMax_Processes__c();
        processNodeObj2.RecordTypeId = ProcessNodeObj;
        processNodeObj2.SVMXC__Process__c = SFMProcess.Id;
        processNodeObj2.SVMXC__Type__c = 'SOURCE';
        processNodeObj2.SVMXC__Source_Object_Name__c = 'SVMXC__Quote__c';
        insert processNodeObj2;
        
        SVMXC__ServiceMax_Processes__c processNodeObj3 = new SVMXC__ServiceMax_Processes__c();
        processNodeObj3.RecordTypeId = ProcessNodeObj;
        processNodeObj3.SVMXC__Page_Layout__c = detailLayout.id;
        processNodeObj3.SVMXC__Process__c = SFMProcess.Id;
        processNodeObj3.SVMXC__Type__c = 'TARGETCHILD';
        processNodeObj3.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        processNodeObj3.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote_Line__c';
        processNodeObj3.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        insert processNodeObj3;
        
        SVMXC__ServiceMax_Processes__c processNodeObj4 = new SVMXC__ServiceMax_Processes__c();
        processNodeObj4.RecordTypeId = ProcessNodeObj;
        processNodeObj4.SVMXC__Process__c = SFMProcess.Id;
        processNodeObj4.SVMXC__Type__c = 'SOURCECHILD';
        processNodeObj4.SVMXC__Parent_Column_Name__c = 'SVMXC__Quote__c';
        processNodeObj4.SVMXC__Node_Source_Object_API__c = 'SVMXC__Quote_Line__c';
        processNodeObj4.SVMXC__Source_Object_Name__c = 'SVMXC__Quote_Line__c';
        processNodeObj4.SVMXC__Target_Object_label__c = 'SVMXC__Quote_Line__c';
        insert processNodeObj4;
        
        //----------------------------Creating Map for TargetRecMap
        map<String,List<Sobject>> TargetRecMap = new map<String,List<Sobject>>();
        
        //--------------------------Creating Data to pass to the instance of INTF_Request_PageUI
        INTF_ParseProcess parseProcess = new INTF_ParseProcess();
        ////TargetRecMap = parseProcess.getINTF_ParseProcess(processNode.Id,processNode.RecordTypeId);
        INTF_WebServicesDef.INTF_Request pmax = new INTF_WebServicesDef.INTF_Request();
        INTF_WebServicesDef.INTF_Request_PageUI PmaxReqPageUI = new INTF_WebServicesDef.INTF_Request_PageUI(page,SFMProcess,pmax);
        
        //--------------------------Creating List of StringMap
        List<INTF_WebServicesDef.INTF_StringMap> StringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('RECORDID',case1.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('PROCESSID',SFMProcess.Id);
        //////////////
        INTF_WebServicesDef.INTF_StringMap Stringmapcls5 = new INTF_WebServicesDef.INTF_StringMap('PAGEID',headerLayout.Id);//headerLayout detailLayout
        INTF_WebServicesDef.INTF_StringMap Stringmapcls6 = new INTF_WebServicesDef.INTF_StringMap('CLIENT_TYPE','DESIGNER');
        StringMap.add(Stringmapcls5);
        StringMap.add(Stringmapcls6);
        ///////////////
        StringMap.add(Stringmapcls1);
        StringMap.add(Stringmapcls3);
        PmaxReqPageUI.request.StringMap = StringMap;
        
        //----------------------------Creating Object of the Class and Calling the Methods
        INTF_getPageLayout pageLayout = new INTF_getPageLayout ();
        INTF_getPageLayout.Wrapper wrapper = new INTF_getPageLayout.Wrapper();
        pageLayout.INTF_GetPageLayout(PmaxReqPageUI);
        
        List<INTF_WebServicesDef.INTF_StringMap> StringMap1 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('RECORDID',quote.Id);
        INTF_WebServicesDef.INTF_StringMap Stringmapcls4 = new INTF_WebServicesDef.INTF_StringMap('PROCESSID',SFMProcess.Id);
        ////////////////////
        INTF_WebServicesDef.INTF_StringMap Stringmapcls11 = new INTF_WebServicesDef.INTF_StringMap('PAGEID',headerLayout.Id);//headerLayout detailLayout
        INTF_WebServicesDef.INTF_StringMap Stringmapcls22 = new INTF_WebServicesDef.INTF_StringMap('CLIENT_TYPE','DESIGNER');
        StringMap1.add(Stringmapcls11);
        StringMap1.add(Stringmapcls22);
        ///////////////////
        StringMap1.add(Stringmapcls2);
        StringMap1.add(Stringmapcls4);
        INTF_WebServicesDef.INTF_Request_PageUI PmaxReqPageUI1 = new INTF_WebServicesDef.INTF_Request_PageUI(page,SFMProcess,pmax);
        PmaxReqPageUI1.request.StringMap = StringMap1;
        INTF_getPageLayout pageLayout1 = new INTF_getPageLayout();      
        pageLayout1.INTF_GetPageLayout(PmaxReqPageUI1);
    }
}