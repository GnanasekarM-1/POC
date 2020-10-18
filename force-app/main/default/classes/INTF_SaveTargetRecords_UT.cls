@isTest 
private with sharing class INTF_SaveTargetRecords_UT
{   
    static testMethod void SINTF_SaveTargetRecords_test1(){

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
        
        //--------------------Creating Header PageLayout-------------------------------------
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        headerLayout.SVMXC__Page_Layout_ID__c = '1';
        headerLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        headerLayout.SVMXC__Type__c = 'Header';
        insert headerLayout;
        System.assertEquals(true, headerLayout != null);
       
       //-------------------Creating Detail PageLayout-------------------------------------
        SVMXC__Page_Layout__c detailLayout = new SVMXC__Page_Layout__c();
        detailLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order_Line__c';
        detailLayout.SVMXC__Type__c = 'WorkDetailLine';
        detailLayout.SVMXC__Header_Page_Layout__c = headerLayout.Id;
        insert detailLayout; 
        
        System.assertNotEquals(headerLayout, detailLayout);
        
       //----------------------Creating Sections For Header Page Layout-------------------------------------
        SVMXC__Page_Layout_Detail__c section1 = new SVMXC__Page_Layout_Detail__c();
        section1.SVMXC__Detail_Type__c = 'Section';
        section1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        section1.SVMXC__Page_Layout__c = headerLayout.Id;
        section1.SVMXC__Sequence__c = 1;
        section1.SVMXC__DataType__c = 'REFERENCE';//*****
        insert section1;
        
        //---------------------------------Creating the process object-------------------------------------
        SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
        processNodes.RecordTypeId = TargetManager;
        processNodes.SVMXC__ProcessID__c='PROCESS11';
        processNodes.SVMXC__Page_Layout__c = headerLayout.id;
        processNodes.SVMXC__IsStandard__c = true;
        insert processNodes;
        System.assertEquals(true, processNodes != null);
        
        SVMXC__ServiceMax_Processes__c NodeObj1 = new SVMXC__ServiceMax_Processes__c(); 
        NodeObj1.RecordTypeId = ProcessNodeobj;
        NodeObj1.SVMXC__Process__c = processNodes.id;
        NodeObj1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        NodeObj1.SVMXC__Node_Source_Object_API__c = 'Case';
        NodeObj1.SVMXC__Type__c = 'Target';
        insert NodeObj1;
        System.assertEquals(true, NodeObj1 != null);  
        
        SVMXC__ServiceMax_Processes__c NodeObj2 = new SVMXC__ServiceMax_Processes__c();
        NodeObj2.RecordTypeId = ProcessNodeobj;
        NodeObj2.SVMXC__Process__c = processNodes.id;
        NodeObj2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c';
        NodeObj2.SVMXC__Node_Source_Object_API__c ='SVMXC__Service_Order__c';
        NodeObj2.SVMXC__Type__c = 'TARGETCHILD';
        NodeObj2.SVMXC__Parent_Object__c = NodeObj1.id;
        NodeObj2.SVMXC__Page_Layout__c = detailLayout.id;
        NodeObj2.SVMXC__Parent_Column_Name__c = 'SVMXC__Service_Order__c';
        insert NodeObj2;
        System.assertEquals(true, NodeObj2 != null);
        
        
        //---------------------------------Create Header Source update Records---------------------------------
        list<SVMXC__ServiceMax_Config_Data__c> SourceUpdatesRec = new list<SVMXC__ServiceMax_Config_Data__c>();     
        SVMXC__ServiceMax_Config_Data__c config13 = new SVMXC__ServiceMax_Config_Data__c(); 
        config13.RecordTypeId = FldmappingId;
        config13.SVMXC__Dispatch_Process__c = processNodes.id;
        config13.SVMXC__Setting_ID__c = NodeObj1.id;
        config13.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config13.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Hours__c';
        config13.SVMXC__Action__c = 'SET';
        config13.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config13);
        
        SVMXC__ServiceMax_Config_Data__c config2 = new SVMXC__ServiceMax_Config_Data__c(); 
        config2.RecordTypeId = FldmappingId;
        config2.SVMXC__Dispatch_Process__c = processNodes.id;
        config2.SVMXC__Setting_ID__c = NodeObj1.id;
        config2.SVMXC__Source_Field_Name__c = 'SVMXC__Clock_Paused_Forever__c';
        config2.SVMXC__Display_Value__c = String.valueof(true);      
        config2.SVMXC__Action__c = 'SET';
        config2.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config2);
        
        SVMXC__ServiceMax_Config_Data__c config14 = new SVMXC__ServiceMax_Config_Data__c(); 
        config14.RecordTypeId = FldmappingId;
        config14.SVMXC__Dispatch_Process__c = processNodes.id;
        config14.SVMXC__Setting_ID__c = NodeObj1.id;
        config14.SVMXC__Source_Field_Name__c = 'SVMXC__Clock_Paused_Forever__c';
        config14.SVMXC__Target_Field_Name__c = 'SVMXC__Clock_Paused_Forever__c';    
        config14.SVMXC__Action__c = 'SET';
        config14.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config14);
       
        SVMXC__ServiceMax_Config_Data__c config3 = new SVMXC__ServiceMax_Config_Data__c(); 
        config3.RecordTypeId = FldmappingId;
        config3.SVMXC__Dispatch_Process__c = processNodes.id;
        config3.SVMXC__Setting_ID__c = NodeObj1.id;
        config3.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config3.SVMXC__Display_Value__c = 'TODAY';        
        config3.SVMXC__Action__c = 'SET';
        config3.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config3);
        
        SVMXC__ServiceMax_Config_Data__c config4 = new SVMXC__ServiceMax_Config_Data__c(); 
        config4.RecordTypeId = FldmappingId;
        config4.SVMXC__Dispatch_Process__c = processNodes.id;
        config4.SVMXC__Setting_ID__c = NodeObj1.id;
        config4.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config4.SVMXC__Display_Value__c = 'YESTERDAY';        
        config4.SVMXC__Action__c = 'SET';
        config4.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config4);
        
        SVMXC__ServiceMax_Config_Data__c config5 = new SVMXC__ServiceMax_Config_Data__c(); 
        config5.RecordTypeId = FldmappingId;
        config5.SVMXC__Dispatch_Process__c = processNodes.id;
        config5.SVMXC__Setting_ID__c = NodeObj1.id;
        config5.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config5.SVMXC__Display_Value__c = 'TOMORROW';        
        config5.SVMXC__Action__c = 'SET';
        config5.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config5);
        
        SVMXC__ServiceMax_Config_Data__c config6 = new SVMXC__ServiceMax_Config_Data__c(); 
        config6.RecordTypeId = FldmappingId;
        config6.SVMXC__Dispatch_Process__c = processNodes.id;
        config6.SVMXC__Setting_ID__c = NodeObj1.id;
        config6.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config6.SVMXC__Display_Value__c = 'NOW';        
        config6.SVMXC__Action__c = 'SET';
        config6.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config6);
        
        SVMXC__ServiceMax_Config_Data__c config15 = new SVMXC__ServiceMax_Config_Data__c(); 
        config15.RecordTypeId = FldmappingId;
        config15.SVMXC__Dispatch_Process__c = processNodes.id;
        config15.SVMXC__Setting_ID__c = NodeObj1.id;
        config15.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config15.SVMXC__Target_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config15.SVMXC__Action__c = 'SET';
        config15.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config15); 
        
        SVMXC__ServiceMax_Config_Data__c config8 = new SVMXC__ServiceMax_Config_Data__c(); 
        config8.RecordTypeId = FldmappingId;
        config8.SVMXC__Dispatch_Process__c = processNodes.id;
        config8.SVMXC__Setting_ID__c = NodeObj1.id;
        config8.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        config8.SVMXC__Display_Value__c = 'TODAY';        
        config8.SVMXC__Action__c = 'SET';
        config8.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config8);
        
        SVMXC__ServiceMax_Config_Data__c config9 = new SVMXC__ServiceMax_Config_Data__c(); 
        config9.RecordTypeId = FldmappingId;
        config9.SVMXC__Dispatch_Process__c = processNodes.id;
        config9.SVMXC__Setting_ID__c = NodeObj1.id;
        config9.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        config9.SVMXC__Display_Value__c = 'YESTERDAY';        
        config9.SVMXC__Action__c = 'SET';
        config9.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config9);
        
        SVMXC__ServiceMax_Config_Data__c config10 = new SVMXC__ServiceMax_Config_Data__c(); 
        config10.RecordTypeId = FldmappingId;
        config10.SVMXC__Dispatch_Process__c = processNodes.id;
        config10.SVMXC__Setting_ID__c = NodeObj1.id;
        config10.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        config10.SVMXC__Display_Value__c = 'TOMORROW';        
        config10.SVMXC__Action__c = 'SET';
        config10.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config10);
        
        SVMXC__ServiceMax_Config_Data__c config16 = new SVMXC__ServiceMax_Config_Data__c(); 
        config16.RecordTypeId = FldmappingId;
        config16.SVMXC__Dispatch_Process__c = processNodes.id;
        config16.SVMXC__Setting_ID__c = NodeObj1.id;
        config16.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        config16.SVMXC__Target_Field_Name__c = 'SVMXC__Scheduled_Date__c';       
        config16.SVMXC__Action__c = 'SET';
        config16.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config16);
        
        SVMXC__ServiceMax_Config_Data__c config18 = new SVMXC__ServiceMax_Config_Data__c(); 
        config18.RecordTypeId = FldmappingId;
        config18.SVMXC__Dispatch_Process__c = processNodes.id;
        config18.SVMXC__Setting_ID__c = NodeObj1.id;
        config18.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config18.SVMXC__Display_Value__c = String.valueof(2);
        config18.SVMXC__Action__c = 'INCREASE';
        config18.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config18);
        
        SVMXC__ServiceMax_Config_Data__c config19 = new SVMXC__ServiceMax_Config_Data__c(); 
        config19.RecordTypeId = FldmappingId;
        config19.SVMXC__Dispatch_Process__c = processNodes.id;
        config19.SVMXC__Setting_ID__c = NodeObj1.id;
        config19.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Extension_Minutes__c';
        config19.SVMXC__Display_Value__c = String.valueof(10);
        config19.SVMXC__Action__c = 'INCREASE';
        config19.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config19);
        
        SVMXC__ServiceMax_Config_Data__c config17 = new SVMXC__ServiceMax_Config_Data__c(); 
        config17.RecordTypeId = FldmappingId;
        config17.SVMXC__Dispatch_Process__c = processNodes.id;
        config17.SVMXC__Setting_ID__c = NodeObj1.id;
        config17.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config17.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Extension_Minutes__c';
        config17.SVMXC__Action__c = 'INCREASE';
        config17.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config17);
        
        SVMXC__ServiceMax_Config_Data__c config7 = new SVMXC__ServiceMax_Config_Data__c(); 
        config7.RecordTypeId = FldmappingId;
        config7.SVMXC__Dispatch_Process__c = processNodes.id;
        config7.SVMXC__Setting_ID__c = NodeObj1.id;
        config7.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config7.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Hours__c';
        config7.SVMXC__Action__c = 'INCREASE';
        config7.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config7);
        
        SVMXC__ServiceMax_Config_Data__c config11 = new SVMXC__ServiceMax_Config_Data__c(); 
        config11.RecordTypeId = FldmappingId;
        config11.SVMXC__Dispatch_Process__c = processNodes.id;
        config11.SVMXC__Setting_ID__c = NodeObj1.id;
        config11.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Hours__c';
        config11.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';
        config11.SVMXC__Action__c = 'INCREASE';
        config11.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config11);
        
        SVMXC__ServiceMax_Config_Data__c config22 = new SVMXC__ServiceMax_Config_Data__c(); 
        config22.RecordTypeId = FldmappingId;
        config22.SVMXC__Dispatch_Process__c = processNodes.id;
        config22.SVMXC__Setting_ID__c = NodeObj1.id;
        config22.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config22.SVMXC__Display_Value__c = String.valueof(2);
        config22.SVMXC__Action__c = 'DECREASE';
        config22.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config22);
        
        SVMXC__ServiceMax_Config_Data__c config23 = new SVMXC__ServiceMax_Config_Data__c(); 
        config23.RecordTypeId = FldmappingId;
        config23.SVMXC__Dispatch_Process__c = processNodes.id;
        config23.SVMXC__Setting_ID__c = NodeObj1.id;
        config23.SVMXC__Source_Field_Name__c = 'SVMXC__BW_Slots_Before__c';
        config23.SVMXC__Display_Value__c = String.valueof(10);
        config23.SVMXC__Action__c = 'DECREASE';
        config23.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config23);
        
        SVMXC__ServiceMax_Config_Data__c config20 = new SVMXC__ServiceMax_Config_Data__c(); 
        config20.RecordTypeId = FldmappingId;
        config20.SVMXC__Dispatch_Process__c = processNodes.id;
        config20.SVMXC__Setting_ID__c = NodeObj1.id;
        config20.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config20.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Hours__c';
        config20.SVMXC__Action__c = 'DECREASE';
        config20.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config20);
        
        SVMXC__ServiceMax_Config_Data__c config21 = new SVMXC__ServiceMax_Config_Data__c(); 
        config21.RecordTypeId = FldmappingId;
        config21.SVMXC__Dispatch_Process__c = processNodes.id;
        config21.SVMXC__Setting_ID__c = NodeObj1.id;
        config21.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';
        config21.SVMXC__Target_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Minutes__c';
        config21.SVMXC__Action__c = 'DECREASE';
        config21.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config21);
    
     //---------------------------------Create Detail Source update Records---------------------------------    
        SVMXC__ServiceMax_Config_Data__c config24 = new SVMXC__ServiceMax_Config_Data__c(); 
        config24.RecordTypeId = FldmappingId;
        config24.SVMXC__Dispatch_Process__c = processNodes.id;
        config24.SVMXC__Setting_ID__c = NodeObj2.id;
        config24.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config24.SVMXC__Target_Field_Name__c = 'SVMXC__Billable_Quantity__c';
        config24.SVMXC__Action__c = 'SET';
        config24.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config24);
        
        SVMXC__ServiceMax_Config_Data__c config25 = new SVMXC__ServiceMax_Config_Data__c(); 
        config25.RecordTypeId = FldmappingId;
        config25.SVMXC__Dispatch_Process__c = processNodes.id;
        config25.SVMXC__Setting_ID__c = NodeObj2.id;
        config25.SVMXC__Source_Field_Name__c = 'SVMXC__Clock_Paused_Forever__c';
        config25.SVMXC__Display_Value__c = String.valueof(true);      
        config25.SVMXC__Action__c = 'SET';
        config25.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config25);
       
        SVMXC__ServiceMax_Config_Data__c config27 = new SVMXC__ServiceMax_Config_Data__c(); 
        config27.RecordTypeId = FldmappingId;
        config27.SVMXC__Dispatch_Process__c = processNodes.id;
        config27.SVMXC__Setting_ID__c = NodeObj2.id;
        config27.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config27.SVMXC__Display_Value__c = 'TODAY';        
        config27.SVMXC__Action__c = 'SET';
        config27.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config27);
        
        SVMXC__ServiceMax_Config_Data__c config28 = new SVMXC__ServiceMax_Config_Data__c(); 
        config28.RecordTypeId = FldmappingId;
        config28.SVMXC__Dispatch_Process__c = processNodes.id;
        config28.SVMXC__Setting_ID__c = NodeObj2.id;
        config28.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config28.SVMXC__Display_Value__c = 'YESTERDAY';        
        config28.SVMXC__Action__c = 'SET';
        config28.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config28);
        
        SVMXC__ServiceMax_Config_Data__c config29 = new SVMXC__ServiceMax_Config_Data__c(); 
        config29.RecordTypeId = FldmappingId;
        config29.SVMXC__Dispatch_Process__c = processNodes.id;
        config29.SVMXC__Setting_ID__c = NodeObj2.id;
        config29.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config29.SVMXC__Display_Value__c = 'TOMORROW';        
        config29.SVMXC__Action__c = 'SET';
        config29.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config29);
        
        SVMXC__ServiceMax_Config_Data__c config30 = new SVMXC__ServiceMax_Config_Data__c(); 
        config30.RecordTypeId = FldmappingId;
        config30.SVMXC__Dispatch_Process__c = processNodes.id;
        config30.SVMXC__Setting_ID__c = NodeObj2.id;
        config30.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config30.SVMXC__Display_Value__c = 'NOW';        
        config30.SVMXC__Action__c = 'SET';
        config30.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config30);
        
        SVMXC__ServiceMax_Config_Data__c config32 = new SVMXC__ServiceMax_Config_Data__c(); 
        config32.RecordTypeId = FldmappingId;
        config32.SVMXC__Dispatch_Process__c = processNodes.id;
        config32.SVMXC__Setting_ID__c = NodeObj2.id;
        config32.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        config32.SVMXC__Display_Value__c = 'TODAY';        
        config32.SVMXC__Action__c = 'SET';
        config32.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config32);
        
        SVMXC__ServiceMax_Config_Data__c config33 = new SVMXC__ServiceMax_Config_Data__c(); 
        config33.RecordTypeId = FldmappingId;
        config33.SVMXC__Dispatch_Process__c = processNodes.id;
        config33.SVMXC__Setting_ID__c = NodeObj2.id;
        config33.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        config33.SVMXC__Display_Value__c = 'YESTERDAY';        
        config33.SVMXC__Action__c = 'SET';
        config33.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config33);
        
        SVMXC__ServiceMax_Config_Data__c config34 = new SVMXC__ServiceMax_Config_Data__c(); 
        config34.RecordTypeId = FldmappingId;
        config34.SVMXC__Dispatch_Process__c = processNodes.id;
        config34.SVMXC__Setting_ID__c = NodeObj2.id;
        config34.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        config34.SVMXC__Display_Value__c = 'TOMORROW';        
        config34.SVMXC__Action__c = 'SET';
        config34.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config34);
        
        SVMXC__ServiceMax_Config_Data__c config35 = new SVMXC__ServiceMax_Config_Data__c(); 
        config35.RecordTypeId = FldmappingId;
        config35.SVMXC__Dispatch_Process__c = processNodes.id;
        config35.SVMXC__Setting_ID__c = NodeObj2.id;
        config35.SVMXC__Source_Field_Name__c = 'SVMXC__Scheduled_Date__c';
        config35.SVMXC__Target_Field_Name__c = 'SVMXC__Date_Requested__c';      
        config35.SVMXC__Action__c = 'SET';
        config35.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config35);
        
        SVMXC__ServiceMax_Config_Data__c config36 = new SVMXC__ServiceMax_Config_Data__c(); 
        config36.RecordTypeId = FldmappingId;
        config36.SVMXC__Dispatch_Process__c = processNodes.id;
        config36.SVMXC__Setting_ID__c = NodeObj2.id;
        config36.SVMXC__Source_Field_Name__c = 'SVMXC__Onsite_Response_Internal_By__c';
        config36.SVMXC__Target_Field_Name__c = 'SVMXC__Start_Date_and_Time__c';      
        config36.SVMXC__Action__c = 'SET';
        config36.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config36);
        
        SVMXC__ServiceMax_Config_Data__c config37 = new SVMXC__ServiceMax_Config_Data__c(); 
        config37.RecordTypeId = FldmappingId;
        config37.SVMXC__Dispatch_Process__c = processNodes.id;
        config37.SVMXC__Setting_ID__c = NodeObj2.id;
        config37.SVMXC__Source_Field_Name__c = 'SVMXC__Clock_Paused_Forever__c';
        config37.SVMXC__Target_Field_Name__c = 'SVMXC__Is_Billable__c';
        config37.SVMXC__Action__c = 'SET';
        config37.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config37);
    
        SVMXC__ServiceMax_Config_Data__c config38 = new SVMXC__ServiceMax_Config_Data__c(); 
        config38.RecordTypeId = FldmappingId;
        config38.SVMXC__Dispatch_Process__c = processNodes.id;
        config38.SVMXC__Setting_ID__c = NodeObj2.id;
        config38.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config38.SVMXC__Display_Value__c = String.valueof(2);
        config38.SVMXC__Action__c = 'INCREASE';
        config38.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config38);
        
        SVMXC__ServiceMax_Config_Data__c config39 = new SVMXC__ServiceMax_Config_Data__c(); 
        config39.RecordTypeId = FldmappingId;
        config39.SVMXC__Dispatch_Process__c = processNodes.id;
        config39.SVMXC__Setting_ID__c = NodeObj2.id;
        config39.SVMXC__Source_Field_Name__c = 'SVMXC__Preferred_Resource_Priority__c';
        config39.SVMXC__Display_Value__c = String.valueof(10);
        config39.SVMXC__Action__c = 'INCREASE';
        config39.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config39);
        
        SVMXC__ServiceMax_Config_Data__c config40 = new SVMXC__ServiceMax_Config_Data__c(); 
        config40.RecordTypeId = FldmappingId;
        config40.SVMXC__Dispatch_Process__c = processNodes.id;
        config40.SVMXC__Setting_ID__c = NodeObj2.id;
        config40.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config40.SVMXC__Target_Field_Name__c = 'SVMXC__Estimated_Quantity2__c';
        config40.SVMXC__Action__c = 'INCREASE';
        config40.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config40);
        
        SVMXC__ServiceMax_Config_Data__c config41 = new SVMXC__ServiceMax_Config_Data__c(); 
        config41.RecordTypeId = FldmappingId;
        config41.SVMXC__Dispatch_Process__c = processNodes.id;
        config41.SVMXC__Setting_ID__c = NodeObj2.id;
        config41.SVMXC__Source_Field_Name__c = 'SVMXC__Idle_Time__c';
        config41.SVMXC__Target_Field_Name__c = 'SVMXC__Estimated_Quantity2__c';
        config41.SVMXC__Action__c = 'INCREASE';
        config41.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config41);
        
        SVMXC__ServiceMax_Config_Data__c config42 = new SVMXC__ServiceMax_Config_Data__c(); 
        config42.RecordTypeId = FldmappingId;
        config42.SVMXC__Dispatch_Process__c = processNodes.id;
        config42.SVMXC__Setting_ID__c = NodeObj2.id;
        config42.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config42.SVMXC__Target_Field_Name__c = 'SVMXC__Quantity_Shipped2__c';
        config42.SVMXC__Action__c = 'INCREASE';
        config42.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config42);
    
        SVMXC__ServiceMax_Config_Data__c config43 = new SVMXC__ServiceMax_Config_Data__c(); 
        config43.RecordTypeId = FldmappingId;
        config43.SVMXC__Dispatch_Process__c = processNodes.id;
        config43.SVMXC__Setting_ID__c = NodeObj2.id;
        config43.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config43.SVMXC__Display_Value__c = String.valueof(2);
        config43.SVMXC__Action__c = 'DECREASE';
        config43.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config43);
        
        SVMXC__ServiceMax_Config_Data__c config44 = new SVMXC__ServiceMax_Config_Data__c(); 
        config44.RecordTypeId = FldmappingId;
        config44.SVMXC__Dispatch_Process__c = processNodes.id;
        config44.SVMXC__Setting_ID__c = NodeObj2.id;
        config44.SVMXC__Source_Field_Name__c = 'SVMXC__Dispatch_Priority__c';
        config44.SVMXC__Display_Value__c = String.valueof(10);
        config44.SVMXC__Action__c = 'DECREASE';
        config44.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config44);
        
        SVMXC__ServiceMax_Config_Data__c config45 = new SVMXC__ServiceMax_Config_Data__c(); 
        config45.RecordTypeId = FldmappingId;
        config45.SVMXC__Dispatch_Process__c = processNodes.id;
        config45.SVMXC__Setting_ID__c = NodeObj2.id;
        config45.SVMXC__Source_Field_Name__c = 'SVMXC__SLA_Clock_Pause_Days__c';
        config45.SVMXC__Target_Field_Name__c = 'SVMXC__Estimated_Quantity2__c';
        config45.SVMXC__Action__c = 'DECREASE';
        config45.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config45);
        
        SVMXC__ServiceMax_Config_Data__c config46 = new SVMXC__ServiceMax_Config_Data__c(); 
        config46.RecordTypeId = FldmappingId;
        config46.SVMXC__Dispatch_Process__c = processNodes.id;
        config46.SVMXC__Setting_ID__c = NodeObj2.id;
        config46.SVMXC__Source_Field_Name__c = 'SVMXC__Driving_Time__c';
        config46.SVMXC__Target_Field_Name__c = 'SVMXC__Estimated_Quantity2__c';
        config46.SVMXC__Action__c = 'DECREASE';
        config46.SVMXC__Configuration_Type__c = 'Source Update';
        SourceUpdatesRec.add(config46);
    
        insert SourceUpdatesRec;
        System.assertEquals(true, SourceUpdatesRec != null);
        
        //---------------------------------Create case for source record update---------------------------------
        Case Case1 = new Case();
        Case1.Origin = 'Email';
        Case1.Priority = 'High';
        Case1.SVMXC__SLA_Clock_Pause_Days__c = 1;
        insert Case1;
        System.assertEquals(true, Case1 != null);
        
        //----------------------Creating List of StringMap for Header Target Record---------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap1 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls1 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__SLA_Clock_Pause_Days__c',String.valueof(10));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls2 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Clock_Paused_Forever__c',String.valueof(true));        
        INTF_WebServicesDef.INTF_StringMap Stringmapcls3 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Scheduled_Date__c',String.valueof(system.today()));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls4 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Onsite_Response_Internal_By__c',String.valueof(datetime.now()));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls5 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__SLA_Clock_Pause_Hours__c',String.valueof(3));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls6 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__SLA_Clock_Pause_Minutes__c',String.valueof(5));
        ListOfStringMap1.add(Stringmapcls1);
        ListOfStringMap1.add(Stringmapcls2);
        ListOfStringMap1.add(Stringmapcls3);
        ListOfStringMap1.add(Stringmapcls4);
        ListOfStringMap1.add(Stringmapcls5);
        ListOfStringMap1.add(Stringmapcls6);
        
        //-----------------------------Creating List of INTF_Record for Header TargetRecObj----------------------------
        List<INTF_WebServicesDef.INTF_Record> SfmRecList1 = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec1 = new INTF_WebServicesDef.INTF_Record();
        SfmRec1.sourceRecordId = Case1.id;
        SfmRec1.targetRecordAsKeyValue = ListOfStringMap1;
        SfmRecList1.add(SfmRec1);
        
        //-------------------------------Creating Header Target Record Object-------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj1.objName = 'SVMXC__Service_Order__c';
        TargetRecObj1.records =  SfmRecList1;
        
        //---------------------------------Create Work Order for source record update---------------------------------
        SVMXC__Service_Order__c  WOrder1 = new SVMXC__Service_Order__c();
        WOrder1.SVMXC__City__c = 'Bangalore';
        WOrder1.SVMXC__Country__c = 'India';
        WOrder1.SVMXC__Street__c = 'Cunninghum';
        insert WOrder1;
        System.assertEquals(true, WOrder1 != null);
        
        //-----------------------Creating Work Detail Object to pass to the method of Record------------------
        SVMXC__Service_Order_Line__c WOLine1 = new SVMXC__Service_Order_Line__c();
        WOLine1.SVMXC__Service_Order__c = WOrder1.Id;
        WOLine1.SVMXC__Select__c = true;
        insert WOLine1;
        System.assertEquals(true, WOLine1 != null);
        
        //----------------------Creating List of StringMap for Detail Target Record(For Update)----------------------------
        List<INTF_WebServicesDef.INTF_StringMap> ListOfStringMap2 = new List<INTF_WebServicesDef.INTF_StringMap>();
        INTF_WebServicesDef.INTF_StringMap Stringmapcls11 = new  INTF_WebServicesDef.INTF_StringMap('SVMXC__Date_Requested__c', String.valueof(system.today()));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls21 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Start_Date_and_Time__c',String.valueof(datetime.now()));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls31 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Is_Billable__c',String.valueof(true));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls41 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Billable_Quantity__c',string.valueof(4));
        INTF_WebServicesDef.INTF_StringMap Stringmapcls51 = new INTF_WebServicesDef.INTF_StringMap('SVMXC__Estimated_Quantity2__c',String.valueof(10));
        ListOfStringMap2.add(Stringmapcls11);
        ListOfStringMap2.add(Stringmapcls21);
        ListOfStringMap2.add(Stringmapcls31);
        ListOfStringMap2.add(Stringmapcls41);
        ListOfStringMap2.add(Stringmapcls51);
        
        //-------------------------Creating List of INTF_Record for DtlTargetRecordObject(for update)-------------------------
        List<INTF_WebServicesDef.INTF_Record> SfmRecList2 = new List<INTF_WebServicesDef.INTF_Record>();
        INTF_WebServicesDef.INTF_Record SfmRec2 = new INTF_WebServicesDef.INTF_Record();
        SfmRec2.sourceRecordId = WOrder1.id;
        SfmRec2.targetRecordAsKeyValue = ListOfStringMap2;
        SfmRec2.targetRecordId = WOLine1.id;
        SfmRecList2.add(SfmRec2);
        
        //-------------------------Creating List of INTF_Record for DtlTargetRecordObject(for insert)-------------------------
        INTF_WebServicesDef.INTF_Record SfmRec3 = new INTF_WebServicesDef.INTF_Record();
        SfmRec3.sourceRecordId = WOrder1.id;
        SfmRec3.targetRecordAsKeyValue = ListOfStringMap2;
        SfmRecList2.add(SfmRec3);
        
        //---------------------Creating String List to pass to the method of DtlTargetRecordObject------------
        List<String> strLst1 = new List<String>();
        String str1 = WOLine1.Id;
        strLst1.add(str1);
        
        //---------------------------Creating List of Detail Target Record-------------------------------------
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> DtlTargetRecordObject1 = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject TargetRecObj2 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        TargetRecObj2.objName = 'SVMXC__Service_Order_Line__c';
        TargetRecObj2.aliasName = String.valueof(detailLayout.id);
        TargetRecObj2.deleteRecID = strLst1;
        TargetRecObj2.parentColumnName = 'SVMXC__Service_Order__c';
        TargetRecObj2.records =  SfmRecList2;
        DtlTargetRecordObject1.add(TargetRecObj2);
        
        //---------------------------------Creating Target Record Object---------------------------------------
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord sfmtargetrec1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        sfmtargetrec1.sfmProcessId = processNodes.Id;
        sfmtargetrec1.headerRecord = TargetRecObj1;
        sfmtargetrec1.detailRecords = DtlTargetRecordObject1;
        
        //--------------------Creating the Object of the Class and Passing the Parameters----------------------
        INTF_SaveTargetRecords saveTargetRec1 = new INTF_SaveTargetRecords();
        saveTargetRec1.SaveTargetRecords(sfmtargetrec1);
    }
}