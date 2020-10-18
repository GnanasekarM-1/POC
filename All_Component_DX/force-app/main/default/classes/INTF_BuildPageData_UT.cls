@isTest
private class INTF_BuildPageData_UT {
    static testMethod void INTF_buildPageData_test(){

        /*-----------------------------------------DATA CREATION-------------------------------------------------*/
        //---------------------------------Creating RecordTypeList-----------------------------------------
        list<RecordType> RecordTypeList = new list<RecordType>();
        RecordTypeList = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c'or SobjectType = 'SVMXC__ServiceMax_Config_Data__c'];
        System.assertEquals(true, RecordTypeList != null);
        
        String FldmappingId = '';
        String ProcessNodeobj = '';
        String TargetManager = '';
        if(RecordTypeList.size() > 0)
        {
            for(RecordType R : RecordTypeList)
            {
                if(R.Name == 'Field Mapping')
                    FldmappingId = R.id;
                if(R.Name == 'Process Node Objects')
                    ProcessNodeobj = R.id;
                if(R.Name == 'Target Manager')
                    TargetManager = R.id;       
            }
        }
        //Create the Pagelayout
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
        section1.SVMXC__Detail_Type__c = 'Field';
        section1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        section1.SVMXC__Page_Layout__c = headerLayout.Id;
        section1.SVMXC__Sequence__c = 1;
        section1.SVMXC__Field_API_Name__c ='SVMXC__Company__c';
        insert section1;
        sectionList.add(section1);
        
        SVMXC__Page_Layout_Detail__c section2 = new SVMXC__Page_Layout_Detail__c();
        section2.SVMXC__Detail_Type__c = 'Section';
        section2.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout2';
        section2.SVMXC__Page_Layout__c = headerLayout.Id;
        section2.SVMXC__Sequence__c = 2;
        section2.SVMXC__Field_API_Name__c = 'SVMXC__Actual_Initial_Response__c';
        insert section2;
        sectionList.add(section2);
        
        map<String,SVMXC__Page_Layout_Detail__c> HeaderFieldMap = new map<String,SVMXC__Page_Layout_Detail__c>(); 
        HeaderFieldMap.put('val1',section1);
        HeaderFieldMap.put('val2',section2);
        
        SVMXC__Page_Layout_Detail__c section3 = new SVMXC__Page_Layout_Detail__c();
        section3.SVMXC__Detail_Type__c = 'Section';
        section3.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout3';
        section3.SVMXC__Page_Layout__c = headerLayout.Id;
        section3.SVMXC__Sequence__c = 3;
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
        field6.SVMXC__Field_API_Name__c = 'SVMXC__Street__c';
        field6.SVMXC__DataType__c = 'text';
        field6.SVMXC__Sequence__c = 2;
        field6.SVMXC__Page_Layout__c = headerLayout.Id;  
        fieldList.add(field6);
        
       //Creating Fields for Detail Page Layout
        SVMXC__Page_Layout_Detail__c field7 = new SVMXC__Page_Layout_Detail__c();
        field7.SVMXC__Detail_Type__c = 'Field';
        field7.SVMXC__Field_API_Name__c = 'SVMXC__Activity_Type__c';
        field7.SVMXC__DataType__c = 'Picklist';
        field7.SVMXC__Page_Layout__c = detailLayout.Id;      
        field7.SVMXC__Sequence__c = 1;
        fieldList.add(field7);
        
        SVMXC__Page_Layout_Detail__c field8 = new SVMXC__Page_Layout_Detail__c();
        field8.SVMXC__Detail_Type__c = 'Field';
        field8.SVMXC__Field_API_Name__c = 'SVMXC__Received_Country__c';
        field8.SVMXC__DataType__c = 'Picklist';
        field8.SVMXC__Page_Layout__c = detailLayout.Id;
        field8.SVMXC__Sequence__c = 2;
        fieldList.add(field8);
        
         
        SVMXC__Page_Layout_Detail__c field9 = new SVMXC__Page_Layout_Detail__c();
        field9.SVMXC__Page_Layout__c = detailLayout.Id; 
        field9.SVMXC__Detail_Type__c = 'Field';
        field9.SVMXC__Field_API_Name__c = 'SVMXC__Cost_Category__c';
        field9.SVMXC__DataType__c = 'Picklist';
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
        
        //---------------------------------Creating the process object-------------------------------------
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId = TargetManager;
        processNodes.SVMXC__Name__c = 'process1';
        processNodes.SVMXC__Description__c = 'newprocess1';
        processNodes.SVMXC__ProcessID__c = 'process1';
        processNodes.SVMXC__IsStandard__c = true;
        processNodes.SVMXC__Page_Layout__c = headerLayout.id;
        insert processNodes;
        System.assertEquals(true, processNodes != null);
        
        SVMXC__ServiceMax_Processes__c NodeObj1 = new SVMXC__ServiceMax_Processes__c(); 
        NodeObj1.RecordTypeId = ProcessNodeobj;
        NodeObj1.SVMXC__Process__c = processNodes.id;
        NodeObj1.SVMXC__Source_Object_Name__c = 'Case';
        NodeObj1.SVMXC__Type__c = 'SOURCE';
        insert NodeObj1;
        System.assertEquals(true, NodeObj1 != null);
        
        SVMXC__ServiceMax_Processes__c NodeObj2 = new SVMXC__ServiceMax_Processes__c(); 
        NodeObj2.RecordTypeId = ProcessNodeobj;
        NodeObj2.SVMXC__Process__c = processNodes.id;
        NodeObj2.SVMXC__Source_Object_Name__c = 'Case';
        NodeObj2.SVMXC__Type__c = 'SOURCECHILD';
        NodeObj2.SVMXC__Node_Parent_API__c = 'Case';
        NodeObj2.SVMXC__Node_Parent__c = NodeObj1.id;
        insert NodeObj2;
        System.assertEquals(true, NodeObj2 != null);
        
        SVMXC__ServiceMax_Processes__c NodeObj3 = new SVMXC__ServiceMax_Processes__c();
        NodeObj3.RecordTypeId = ProcessNodeobj;
        NodeObj3.SVMXC__Process__c = processNodes.id;
        NodeObj3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        NodeObj3.SVMXC__Type__c = 'TARGET';
        NodeObj3.SVMXC__Parent_Object__c = NodeObj1.id;
        insert NodeObj3;
        System.assertEquals(true, NodeObj3 != null);
        
        SVMXC__ServiceMax_Processes__c NodeObj4 = new SVMXC__ServiceMax_Processes__c();
        NodeObj4.RecordTypeId = ProcessNodeobj;
        NodeObj4.SVMXC__Process__c = processNodes.id;
        NodeObj4.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        NodeObj4.SVMXC__Type__c = 'TARGETCHILD';
        NodeObj4.SVMXC__Node_Parent_API__c = 'SVMXC__Service_Order__c';
        NodeObj4.SVMXC__Parent_Object__c = NodeObj2.id;
        NodeObj4.SVMXC__Parent_Column_Name__c = 'SVMXC__Service_Order__c';
        NodeObj4.SVMXC__Page_Layout__c = detailLayout.id;
        insert NodeObj4;
        System.assertEquals(true, NodeObj4 != null);
        
        //Create Source update Records....
        list<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesRec = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c config1 = new SVMXC__ServiceMax_Config_Data__c(); 
        config1.RecordTypeId = FldmappingId;
        config1.SVMXC__Dispatch_Process__c = processNodes.id;
        config1.SVMXC__Source_Field_Name__c = 'SVMXC__Billing_Type__c';
        config1.SVMXC__Target_Field_Name__c = 'SVMXC__Billing_Type__c';
        config1.SVMXC__Action__c = 'Set';
        config1.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config1);
        
        SVMXC__ServiceMax_Config_Data__c config2 = new SVMXC__ServiceMax_Config_Data__c(); 
        config2.RecordTypeId = FldmappingId;
        config2.SVMXC__Dispatch_Process__c = processNodes.id;
        config2.SVMXC__Source_Field_Name__c = 'SVMXC__Billing_Type__c';
        config2.SVMXC__Display_Value__c = 'Contract';
        config2.SVMXC__Action__c = 'Set';
        config2.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config2);
        
        SVMXC__ServiceMax_Config_Data__c config3 = new SVMXC__ServiceMax_Config_Data__c(); 
        config3.RecordTypeId = FldmappingId;
        config3.SVMXC__Dispatch_Process__c = processNodes.id;
        config3.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config3.SVMXC__Display_Value__c = '1';
        config3.SVMXC__Action__c = 'INCREASE';
        config3.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config3);
        insert SourceUpdatesRec;
        System.assertEquals(true, SourceUpdatesRec != null);
        
        
        //Create case for source record update
        Case c = new Case();
        c.Origin = 'Email';
        c.Priority = 'High';
        c.SVMXC__SLA_Clock_Pause_Days__c = 1;
        insert c;
        System.assertEquals(true, c != null);
       
       
        //-------------------------------Creating List of Work Order Object---------------------------------
        List<SVMXC__Service_Order__c> WOList = new List<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c();
        SVMXC__Service_Order__c WO2 = new SVMXC__Service_Order__c();
        WOList.add(WO1);
        WOList.add(WO2);
        insert WOList;
        System.assertEquals(true, WOList != null);
        
        //----------------Creating String List to pass to the method of Header TargetRecObj-------------------
        List<String> strLst1 = new List<String>();
        String str1 = WO1.Id;
        String str2 = WO2.Id;
        strLst1.add(str1);
        strLst1.add(str2);
        
        SVMXC__Service_Order__c WOrder = new SVMXC__Service_Order__c();
        WOrder.SVMXC__City__c = 'Bangalore';
        WOrder.SVMXC__Country__c = 'India';
        WOrder.SVMXC__Street__c = 'Cunninghum';
        insert WOrder;
        System.assertEquals(true, WOrder != null);
         
        //--------------Creating Work Detail Object to pass to the method of DtlTargetRecordObject-----------
        SVMXC__Service_Order_Line__c WOLine = new SVMXC__Service_Order_Line__c();
        WOLine.SVMXC__Service_Order__c = WOrder.Id;
        WOLine.SVMXC__Select__c = true;
        insert WOLine;
        System.assertEquals(true, WOLine != null);
        
        //-----------------------Creating Work Detail Object to pass to the method of Record------------------
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c();
        WOLine1.SVMXC__Service_Order__c = WOrder.Id;
        WOLine1.SVMXC__Select__c = true;
        insert WOLine1;
        System.assertEquals(true, WOLine1 != null);
        
        //---------------------Creating String List to pass to the method of DtlTargetRecordObject------------
        List<String> strLst2 = new List<String>();
        String str3 = WOLine.Id;
        strLst2.add(str3);
        
        //----------------------Creating List of StringMap for Header Target Record---------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__City__c','Bangalore');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Customer_Down__c','true');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Street__c','Cunninghum');
        ListOfStringMap.add(Stringmapcls1);
        ListOfStringMap.add(Stringmapcls2);
        ListOfStringMap.add(Stringmapcls3);
        
        //----------------------Creating List of StringMap for Detail Target Record(For Update)----------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap1 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls4 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Activity_Type__c','Installation');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls5 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Cost_Category__c','Straight');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls6 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Received_Country__c','India');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls7 = new INTF_WebServicesDef.INTF_StringMap('Id',string.valueof(WOLine1.id));
        ListOfStringMap1.add(Stringmapcls4);
        ListOfStringMap1.add(Stringmapcls5);
        ListOfStringMap1.add(Stringmapcls6);
        ListOfStringMap1.add(Stringmapcls7);
        
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap2 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls8 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Service_Order__c',String.valueof(WOrder.Id));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls9 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Activity_Type__c','Installation');
        INTF_WebServicesDef.INTF_StringMap Stringmapcls10 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Cost_Category__c','Straight');
        ListOfStringMap2.add(Stringmapcls8);
        ListOfStringMap2.add(Stringmapcls9);
        ListOfStringMap2.add(Stringmapcls10);
        
        
        
        //-----------------------------Creating List of INTF_Record for Header TargetRecObj----------------------------
        List<INTF_WebServicesDef.INTF_Record> SfmRecList1 = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec1 = new INTF_WebServicesDef.INTF_Record();
        SfmRec1.sourceRecordId = c.id;
        SfmRec1.targetRecordAsKeyValue = ListOfStringMap;
        SfmRecList1.add(SfmRec1);
        
        //-------------------------Creating List of INTF_Record for DtlTargetRecordObject(for update)-------------------------
        List<INTF_WebServicesDef.INTF_Record> SfmRecList2 = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec2 = new INTF_WebServicesDef.INTF_Record();
        SfmRec2.sourceRecordId = '';
        SfmRec2.targetRecordAsKeyValue = ListOfStringMap1;
        SfmRecList2.add(SfmRec2);
        
        //-------------------------Creating List of INTF_Record for DtlTargetRecordObject(for insert)-------------------------
        INTF_WebServicesDef.INTF_Record SfmRec3 = new INTF_WebServicesDef.INTF_Record();
        SfmRec3.sourceRecordId = '';
        SfmRec3.targetRecordAsKeyValue = ListOfStringMap2;
        SfmRecList2.add(SfmRec3);
        
        //-------------------------------Creating Header Target Record Object-------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj.objName = 'SVMXC__Service_Order__c';
        TargetRecObj.deleteRecID = strLst1;
        TargetRecObj.records =  SfmRecList1;
        TargetRecObj.pageLayoutId = headerLayout.id;
        //---------------------------Creating List of Detail Target Record-------------------------------------
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj1.objName = 'SVMXC__Service_Order_Line__c';
        TargetRecObj1.aliasName = 'WorkDetailLine';
        TargetRecObj1.deleteRecID = strLst2;
        TargetRecObj1.parentColumnName = 'SVMXC__Service_Order__c';
        TargetRecObj1.pageLayoutId = detailLayout.id;
        TargetRecObj1.records =  SfmRecList2;
        DtlTargetRecordObject.add(TargetRecObj1);
        
        
        //---------------------------------Creating Target Record Object---------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        sfmtargetrec.sfmProcessId = processNodes.Id;
        sfmtargetrec.headerRecord = TargetRecObj;
        sfmtargetrec.detailRecords = DtlTargetRecordObject;
        
        
        SVMXC.INTF_buildPageData buildpagedata = new SVMXC.INTF_buildPageData();
        buildpagedata.INTF_buildPageData(sfmtargetrec);
        
    }

}