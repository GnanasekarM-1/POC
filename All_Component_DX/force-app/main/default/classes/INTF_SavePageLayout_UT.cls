@isTest(SeeAllData=true)
private with sharing class INTF_SavePageLayout_UT 
{
    static testMethod void INTF_SavePageLayoutUnitTest()
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
        
        INTF_WebServicesDef.INTF_BubbleWrapper bubbleinfo = new INTF_WebServicesDef.INTF_BubbleWrapper();
        INTF_WebServicesDef.INTF_UIField fieldDetail1 = new INTF_WebServicesDef.INTF_UIField(fieldList[0], NULL, bubbleinfo);
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
        
        INTF_WebServicesDef.INTF_UISection sectionDetail1 = new INTF_WebServicesDef.INTF_UISection(sectionList[0],List_fieldDetail1);
        INTF_WebServicesDef.INTF_UISection sectionDetail2 = new INTF_WebServicesDef.INTF_UISection(sectionList[1],List_fieldDetail2);
        
        List<INTF_WebServicesDef.INTF_UISection> List_sectionDetail = new List<INTF_WebServicesDef.INTF_UISection>();
        List_sectionDetail.add(sectionDetail1);
        List_sectionDetail.add(sectionDetail2);
        
        INTF_WebServicesDef.INTF_UIButton buttonDetail1 = new INTF_WebServicesDef.INTF_UIButton(buttonList[0],pageEvents2);
        INTF_WebServicesDef.INTF_UIButton buttonDetail3 = new INTF_WebServicesDef.INTF_UIButton(buttonList[1],pageEvents3);
        
        List<INTF_WebServicesDef.INTF_UIButton> List_buttonDetail1 = new List<INTF_WebServicesDef.INTF_UIButton>();
        List_buttonDetail1.add(buttonDetail1);
        
        List<INTF_WebServicesDef.INTF_UIButton> List_buttonDetail2 = new List<INTF_WebServicesDef.INTF_UIButton>();
        List_buttonDetail2.add(buttonDetail3);
        
        INTF_WebServicesDef.INTF_PageHeader pageHeader = new INTF_WebServicesDef.INTF_PageHeader(headerLayout,List_sectionDetail,List_buttonDetail1,pageEvents1);
        
        List<INTF_WebServicesDef.INTF_DetailBubbleWrapper> bubbleinfolist = new List<INTF_WebServicesDef.INTF_DetailBubbleWrapper>();

        INTF_WebServicesDef.INTF_PageDetail detail1 = new INTF_WebServicesDef.INTF_PageDetail(detailLayout,List_fieldDetail3,List_buttonDetail2,bubbleinfolist);
        List<INTF_WebServicesDef.INTF_PageDetail> details = new List<INTF_WebServicesDef.INTF_PageDetail>();
        details.add(detail1);
       
       //Creating Object of INTF_WebServicesDef.INTF_Request_PageUI to pass as parameter to the Class     
        INTF_WebServicesDef.INTF_PageUI pageui = new INTF_WebServicesDef.INTF_PageUI(pageHeader,details);
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
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('RECORDID',processNode.Id);
        ListOfStringMap.add(Stringmapcls1);
        INTF_WebServicesDef.INTF_StringMap SaveType = new INTF_WebServicesDef.INTF_StringMap('SAVETYPE','SAVE');
        INTF_WebServicesDef.INTF_Request pmax = new INTF_WebServicesDef.INTF_Request('','','',ListOfStringMap);
        INTF_WebServicesDef.INTF_Request_PageUI requestpage = new INTF_WebServicesDef.INTF_Request_PageUI(pageui,processNode,pmax);
        requestpage.request.stringMap.add(SaveType);
       
       //Creating Object of the Class and Calling the Method       
        INTF_savePageLayout pagelayout = new INTF_savePageLayout();
        
        //SVMXC.INTF_WebServicesDef.INTF_PageUI PageUI = new SVMXC.INTF_WebServicesDef.INTF_PageUI();
        requestpage.page = PageUI;
        requestpage.processNode = processNode;
        //requestpage.header = 
        pagelayout.INTF_SavePageLayout(requestpage);
        
        INTF_WebServicesDef.INTF_Request_PageUI requestpage1 = new INTF_WebServicesDef.INTF_Request_PageUI(pageui,processNode,pmax);
        INTF_WebServicesDef.INTF_StringMap SaveType1 = new INTF_WebServicesDef.INTF_StringMap('SAVETYPE','SAVE');
        requestpage1.request.stringMap.add(SaveType1);
        requestpage1.page = PageUI;
        requestpage1.processNode = processNode;
        //requestpage.header = 
        pagelayout.INTF_SavePageLayout(requestpage1);
    }
}