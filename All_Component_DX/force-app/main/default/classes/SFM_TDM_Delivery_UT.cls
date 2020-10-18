@isTest(SeeAllData=true) 
private class SFM_TDM_Delivery_UT
{
    static testMethod void SFM_TDM_Delivery_Test()
    {
    //--------------------------------------------DATA CREATION----------------------------------------------------------------------//
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
        System.assertEquals(true, detailLayout!= null);
        
        //Creating Sections For Header Page Layout
        List<SVMXC__Page_Layout_Detail__c> sectionList = new List<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c section1 = new SVMXC__Page_Layout_Detail__c();
        section1.SVMXC__Detail_Type__c = 'Section';
        section1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        section1.SVMXC__Page_Layout__c = headerLayout.Id;
        section1.SVMXC__Sequence__c = 1;
        sectionList.add(section1);
        
         //Creating Fields For Sections of Header Page Layout
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
        //creating process and record type
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'closed';
        insert wo;
        
        List<RecordType> RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
        RecordType RecordType_TargetManager = [Select SobjectType, Name, Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Target Manager'];
        RecordType RecordType_ProcessNodeObjects = [Select SobjectType, Name, Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Process Node Objects'];
        RecordType RecordType_Rule = [Select SobjectType, Name, Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule'];
        
        SVMXC__ServiceMax_Processes__c ProRec = new SVMXC__ServiceMax_Processes__c();
        ProRec.RecordTypeId = RecordType_Rule.Id;
        ProRec.SVMXC__Rule_Type__c = 'Named Expression';
        ProRec.SVMXC__SettingID__c = 'NEWexpression002';
        ProRec.SVMXC__ProcessID__c = 'NEWexpression002';
        ProRec.SVMXC__Source_Object_Name__c ='SVMXC__Service_Order__c';
        ProRec.SVMXC__Name__c = 'NEWexpression002';
        ProRec.SVMXC__Description__c='New description';
        ProRec.SVMXC__Advance_Expression__c=null;
        ProRec.SVMXC__Parent_Object_Criteria__c = null;
        ProRec.SVMXC__Parent_Error_Msg__c = 'New error';
        ProRec.SVMXC__IsStandard__c = false;
        insert ProRec;
        
        List<SVMXC__ServiceMax_Processes__c> ProList = new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c ProListRec = new SVMXC__ServiceMax_Processes__c();
        ProListRec.SVMXC__Type__c = 'TARGET';
        ProListRec.SVMXC__Submodule__c = ProRec.Id;
        ProListRec.SVMXC__SubmoduleID__c = ProRec.Id;
        ProListRec.SVMXC__Process__c = ProRec.Id;
        ProListRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ProListRec.SVMXC__Sequence__c = 1;
        ProListRec.SVMXC__Select__c = false;
        ProListRec.SVMXC__Rule_Type__c = 'TARGET';
        ProListRec.SVMXC__Purpose__c = 'STANDALONE EDIT';
        ProListRec.SVMXC__SettingID__c = 'NEWPROCESS001';
        ProListRec.SVMXC__ProcessID__c = 'NEWPROCESS001';
        ProListRec.SVMXC__Name__c ='NEWPROCESS001';
        ProListRec.SVMXC__IsStandard__c = false;
        ProListRec.SVMXC__IsPrivate__c = false;
        ProListRec.SVMXC__IsDefault__C = false;
        ProListRec.SVMXC__Expertise_Match_Enabled__c = false;
        ProListRec.SVMXC__Description__c = 'New description';
        ProListRec.SVMXC__Active__c = true;
        ProListRec.RecordTypeId = RecordType_TargetManager.Id;
        insert ProListRec;
        
        SVMXC__ServiceMax_Processes__c ProListRec2 = new SVMXC__ServiceMax_Processes__c();
        ProListRec2.SVMXC__Type__c = 'TARGET';
        ProListRec2.SVMXC__Submodule__c = ProRec.Id;
        ProListRec2.SVMXC__SubmoduleID__c = ProRec.Id;
        ProListRec2.SVMXC__Process__c = ProListRec.Id;
        ProListRec2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ProListRec2.SVMXC__Sequence__c = 1;
        ProListRec2.SVMXC__Select__c = false;
        ProListRec2.SVMXC__Rule_Type__c = 'TARGET';
        ProListRec2.SVMXC__Purpose__c = 'STANDALONE EDIT';
        ProListRec2.SVMXC__SettingID__c = 'NEWPROCESS001';
        ProListRec2.SVMXC__ProcessID__c = ProRec.Id;
        ProListRec2.SVMXC__Name__c =ProRec.Id;
        ProListRec2.SVMXC__IsStandard__c = false;
        ProListRec2.SVMXC__IsPrivate__c = false;
        ProListRec2.SVMXC__IsDefault__C = false;
        ProListRec2.SVMXC__Expertise_Match_Enabled__c = false;
        ProListRec2.SVMXC__Description__c = 'New description';
        ProListRec2.SVMXC__Active__c = true;
        ProListRec2.RecordTypeId = RecordType_ProcessNodeObjects.Id;
        insert ProListRec2;
        
        System.currentPagereference().getParameters().put('SVMX_recordID',ProListRec.Id);
        System.currentPagereference().getParameters().put('SVMX_ProcessID',ProListRec.Id);
        System.currentPagereference().getParameters().put('SVMX_pageID',headerLayout.Id);
        System.currentPagereference().getParameters().put('SVMX_retURL','/apex/CONF_SetupHome');
        
        //-----------------------------------INSTANTIATING THE CLASS-----------------------------------------------------------//
        SFM_TDM_Delivery prossDel_Obj  = new  SFM_TDM_Delivery();
        
        //-----------------------------------METHOD CALLING--------------------------------------------------------------------//
        prossDel_Obj.getRecordID();
        prossDel_Obj.getProcessID();
        prossDel_Obj.getPageID();
        prossDel_Obj.getHeight();
        prossDel_Obj.getMySessionId();
        prossDel_Obj.getIsIdExsists();
        prossDel_Obj.getIsProcessExsists();
        prossDel_Obj.getIsError();
        prossDel_Obj.getErrorMsg();
        prossDel_Obj.getProcessErrMsg();
        prossDel_Obj.getIdErrMsg();
        prossDel_Obj.ExpressionQulification();
        prossDel_Obj.getreturnURL();
        prossDel_Obj.getloadingTag();
        prossDel_Obj.getProcessTitle();
        prossDel_Obj.getHdrMsg();
        prossDel_Obj.getMode();
        //prossDel_Obj.getIsSFMProces();
        prossDel_Obj.getProTypeErr();
        //prossDel_Obj.DoPageAction(); // #optiChange
       // prossDel_Obj.getTargetRecord();  // #optiChange
       // prossDel_Obj.saveTargetRecord();  // #optiChange
        System.assertEquals(true, prossDel_Obj.getRecordID() != null);
        System.assertEquals(true, prossDel_Obj.getProcessID()!= null);
        System.assertEquals(true, prossDel_Obj.getPageID()!= null);
        System.assertEquals(true, prossDel_Obj.getHeight()!= null);
        System.assertEquals(true, prossDel_Obj.getisSFMProcess() == true);  
        prossDel_Obj.getnxtStepID();
        prossDel_Obj.getdefaultSearchOperator();
        ////System.assertEquals(true, prossDel_Obj.getMySessionId()!= null);
        System.currentPagereference().getParameters().put('SVMX_Execution_Mode','SVMXAUTO');
        prossDel_Obj  = new  SFM_TDM_Delivery();
        //prossDel_Obj.DoPageAction(); // #optiChange
        prossDel_Obj.getTargetRecord();  // #optiChange
        prossDel_Obj.saveTargetRecord();  // #optiChange
        prossDel_Obj.getUserLocaleKey();
        prossDel_Obj.getUserID();
        prossDel_Obj.getUserOrgID();
        prossDel_Obj.getIsDuplicateProcess();        
        prossDel_Obj.getduplicateProcessMsg();
        prossDel_Obj.getpartnerServerURL();
        prossDel_Obj.DoCancel();
        
        try{
            prossDel_Obj.doHeaderSourceObjectUpdate();
        } catch(Exception e) {}
        try{
            prossDel_Obj.postSaveAction();
        } catch(Exception e) {}
        SFM_TDM_Delivery.sourceUpdateDef obj = new SFM_TDM_Delivery.sourceUpdateDef(null,null,null,null,null);
        SVMXC__Service_Order__c objWO = new SVMXC__Service_Order__c();
        insert objWO;
        System.currentPagereference().getParameters().put('SVMX_recordId',objWO.id);
        System.currentPagereference().getParameters().put('SVMX_NxtStepID','TDM016');
        System.currentPagereference().getParameters().put('SVMX_Execution_Mode','SVMXAUTO');
        System.currentPagereference().getParameters().put('SVMX_ProcessID',ProListRec.Id);
        System.currentPagereference().getParameters().put('SVMX_SearchOperator','Contains');
        prossDel_Obj = new SFM_TDM_Delivery();
        prossDel_Obj.getnxtStepID();
        prossDel_Obj.getisSFMProcess();
        prossDel_Obj.getdefaultSearchOperator();
        prossDel_Obj.getTargetRecord();
        prossDel_Obj.saveTargetRecord();
        prossDel_Obj.HdrMsg = true;
        prossDel_Obj.postSaveAction();
        }//method
    
    static testMethod void SFM_TDM_Delivery_NextProcess_Test()
    {
    //--------------------------------------------DATA CREATION----------------------------------------------------------------------//
    //Creating Header PageLayout
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        headerLayout.SVMXC__Page_Layout_ID__c = '1';
        headerLayout.SVMXC__Object_Name__c = 'Account';
        headerLayout.SVMXC__Type__c = 'Header';
        insert headerLayout;
        System.assertEquals(true, headerLayout != null);
        
        //Creating Header PageLayout
        SVMXC__Page_Layout__c headerLayout2 = new SVMXC__Page_Layout__c();
        headerLayout2.SVMXC__Page_Layout_ID__c = '1';
        headerLayout2.SVMXC__Object_Name__c = 'Account';
        headerLayout2.SVMXC__Type__c = 'Header';
        insert headerLayout2;
        System.assertEquals(true, headerLayout2 != null);
        
 
       //Creating Detail PageLayout
        SVMXC__Page_Layout__c detailLayout = new SVMXC__Page_Layout__c();
        detailLayout.SVMXC__Page_Layout_ID__c = '2';
        detailLayout.SVMXC__Object_Name__c = 'Account';
        detailLayout.SVMXC__Type__c = 'Detail';
        detailLayout.SVMXC__Header_Page_Layout__c = headerLayout2.Id;
        insert detailLayout; 
        System.assertEquals(true, detailLayout!= null);
        
        //Creating Detail PageLayout
        SVMXC__Page_Layout__c detailLayout2 = new SVMXC__Page_Layout__c();
        detailLayout2.SVMXC__Page_Layout_ID__c = '22';
        detailLayout2.SVMXC__Object_Name__c = 'Account';
        detailLayout2.SVMXC__Type__c = 'Detail';
        detailLayout2.SVMXC__Header_Page_Layout__c = headerLayout2.Id;
        insert detailLayout2; 
        System.assertEquals(true, detailLayout2!= null);
        
        //Creating Sections For Header Page Layout
        List<SVMXC__Page_Layout_Detail__c> sectionList = new List<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c section1 = new SVMXC__Page_Layout_Detail__c();
        section1.SVMXC__Detail_Type__c = 'Section';
        section1.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout1';
        section1.SVMXC__Page_Layout__c = headerLayout.Id;
        section1.SVMXC__Sequence__c = 1;
        sectionList.add(section1);
        
        //Creating Sections For Header Page Layout
        List<SVMXC__Page_Layout_Detail__c> sectionList2 = new List<SVMXC__Page_Layout_Detail__c>();
        SVMXC__Page_Layout_Detail__c section2 = new SVMXC__Page_Layout_Detail__c();
        section2.SVMXC__Detail_Type__c = 'Section';
        section2.SVMXC__Page_Layout_Detail_Id__c = 'sectionLayout2';
        section2.SVMXC__Page_Layout__c = headerLayout2.Id; 
        section2.SVMXC__Sequence__c = 1;
        sectionList2.add(section2);
        
         //Creating Fields For Sections of Header Page Layout
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
        //creating process and record type
       /* SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c = 'closed';
        insert wo;*/
        Account accRecord = new Account(name='testAccount');
        insert accRecord;
        
        List<RecordType> RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' ];
        RecordType RecordType_TargetManager = [Select SobjectType, Name, Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Target Manager'];
        RecordType RecordType_ProcessNodeObjects = [Select SobjectType, Name, Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'Process Node Objects'];
        RecordType RecordType_Rule = [Select SobjectType, Name, Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name = 'SVMX Rule'];
        
        SVMXC__ServiceMax_Processes__c ProRec = new SVMXC__ServiceMax_Processes__c();
        ProRec.RecordTypeId = RecordType_Rule.Id;
        ProRec.SVMXC__Rule_Type__c = 'Named Expression';
        ProRec.SVMXC__SettingID__c = 'NEWexpression002';
        ProRec.SVMXC__ProcessID__c = 'NEWexpression002';
        ProRec.SVMXC__Source_Object_Name__c ='Account';
        ProRec.SVMXC__Name__c = 'NEWexpression002';
        ProRec.SVMXC__Description__c='New description';
        ProRec.SVMXC__Advance_Expression__c=null;
        ProRec.SVMXC__Parent_Object_Criteria__c = null;
        ProRec.SVMXC__Parent_Error_Msg__c = 'New error';
        ProRec.SVMXC__IsStandard__c = false;
        insert ProRec;
        
        SVMXC__ServiceMax_Processes__c ProRec2 = new SVMXC__ServiceMax_Processes__c();
        ProRec2.RecordTypeId = RecordType_Rule.Id;
        ProRec2.SVMXC__Rule_Type__c = 'Named Expression';
        ProRec2.SVMXC__SettingID__c = 'NEWexpression0023';
        ProRec2.SVMXC__ProcessID__c = 'NEWexpression0023';
        ProRec2.SVMXC__Source_Object_Name__c ='Account';
        ProRec2.SVMXC__Name__c = 'NEWexpression002';
        ProRec2.SVMXC__Description__c='New description';
        ProRec2.SVMXC__Advance_Expression__c=null;
        ProRec2.SVMXC__Parent_Object_Criteria__c = null;
        ProRec2.SVMXC__Parent_Error_Msg__c = 'New error';
        ProRec2.SVMXC__IsStandard__c = false;
        insert ProRec2;
        
        List<SVMXC__ServiceMax_Processes__c> ProList = new List<SVMXC__ServiceMax_Processes__c>();
        
        SVMXC__ServiceMax_Processes__c ProListRec = new SVMXC__ServiceMax_Processes__c();
        ProListRec.SVMXC__Type__c = 'TARGET';
        ProListRec.SVMXC__Submodule__c = ProRec.Id;
        ProListRec.SVMXC__SubmoduleID__c = ProRec.Id;
        ProListRec.SVMXC__Process__c = ProRec.Id;
        ProListRec.SVMXC__Source_Object_Name__c = 'Account';
        ProListRec.SVMXC__Sequence__c = 1;
        ProListRec.SVMXC__Select__c = false;
        ProListRec.SVMXC__Rule_Type__c = 'TARGET';
        ProListRec.SVMXC__Purpose__c = 'STANDALONE EDIT';
        ProListRec.SVMXC__SettingID__c = 'NEWPROCESS001';
        ProListRec.SVMXC__ProcessID__c = 'NEWPROCESS001';
        ProListRec.SVMXC__Name__c ='NEWPROCESS001';
        ProListRec.SVMXC__IsStandard__c = false;
        ProListRec.SVMXC__IsPrivate__c = false;
        ProListRec.SVMXC__IsDefault__C = false;
        ProListRec.SVMXC__Expertise_Match_Enabled__c = false;
        ProListRec.SVMXC__Description__c = 'New description';
        ProListRec.SVMXC__Active__c = true;
        ProListRec.RecordTypeId = RecordType_TargetManager.Id;
        ProListRec.SVMXC__Dispatch_Process_Status__c = 'Complete';
        insert ProListRec;
        
        SVMXC__ServiceMax_Processes__c ProListRec3 = new SVMXC__ServiceMax_Processes__c();
        ProListRec3.SVMXC__Type__c = 'TARGET';
        ProListRec3.SVMXC__Submodule__c = ProRec2.Id;
        ProListRec3.SVMXC__SubmoduleID__c = ProRec2.Id;
        ProListRec3.SVMXC__Process__c = ProRec2.Id;
        ProListRec3.SVMXC__Source_Object_Name__c = 'Account';
        ProListRec3.SVMXC__Sequence__c = 1;
        ProListRec3.SVMXC__Select__c = false;
        ProListRec3.SVMXC__Rule_Type__c = 'TARGET';
        ProListRec3.SVMXC__Purpose__c = 'STANDALONE EDIT';
        ProListRec3.SVMXC__SettingID__c = 'NEWPROCESS0012';
        ProListRec3.SVMXC__ProcessID__c = 'NEWPROCESS0012';
        ProListRec3.SVMXC__Name__c ='NEWPROCESS0012';
        ProListRec3.SVMXC__IsStandard__c = false;
        ProListRec3.SVMXC__IsPrivate__c = false;
        ProListRec3.SVMXC__IsDefault__C = false;
        ProListRec3.SVMXC__Expertise_Match_Enabled__c = false;
        ProListRec3.SVMXC__Description__c = 'New description';
        ProListRec3.SVMXC__Active__c = true;
        ProListRec3.RecordTypeId = RecordType_TargetManager.Id;
        insert ProListRec3;
        
        SVMXC__ServiceMax_Processes__c ProListRec2 = new SVMXC__ServiceMax_Processes__c();
        ProListRec2.SVMXC__Type__c = 'SOURCE';
        ProListRec2.SVMXC__Submodule__c = ProRec.Id;
        ProListRec2.SVMXC__SubmoduleID__c = ProRec.Id;
        ProListRec2.SVMXC__Process__c = ProListRec.Id;
        ProListRec2.SVMXC__Source_Object_Name__c = 'Account';
        ProListRec2.SVMXC__Sequence__c = 1;
        ProListRec2.SVMXC__Select__c = false;
        ProListRec2.SVMXC__Rule_Type__c = 'TARGET';
        ProListRec2.SVMXC__Purpose__c = 'STANDALONE EDIT';
        ProListRec2.SVMXC__SettingID__c = 'NEWPROCESS001';
        ProListRec2.SVMXC__ProcessID__c = ProRec.Id;
        ProListRec2.SVMXC__Name__c =ProRec.Id;
        ProListRec2.SVMXC__IsStandard__c = false;
        ProListRec2.SVMXC__IsPrivate__c = false;
        ProListRec2.SVMXC__IsDefault__C = false;
        ProListRec2.SVMXC__Expertise_Match_Enabled__c = false;
        ProListRec2.SVMXC__Description__c = 'New description';
        ProListRec2.SVMXC__Active__c = true;
        ProListRec2.RecordTypeId = RecordType_ProcessNodeObjects.Id;
        insert ProListRec2;
        
         SVMXC__ServiceMax_Processes__c ProListRec4 = new SVMXC__ServiceMax_Processes__c();
        ProListRec4.SVMXC__Type__c = 'TARGET';
        ProListRec4.SVMXC__Submodule__c = ProRec2.Id;
        ProListRec4.SVMXC__SubmoduleID__c = ProRec2.Id;
        ProListRec4.SVMXC__Process__c = ProListRec3.Id;
        ProListRec4.SVMXC__Source_Object_Name__c = 'Account';
        ProListRec4.SVMXC__Sequence__c = 1;
        ProListRec4.SVMXC__Select__c = false;
        ProListRec4.SVMXC__Rule_Type__c = 'TARGET';
        ProListRec4.SVMXC__Purpose__c = 'STANDALONE EDIT';
        ProListRec4.SVMXC__SettingID__c = 'NEWPROCESS0012';
        ProListRec4.SVMXC__ProcessID__c = ProRec2.Id;
        ProListRec4.SVMXC__Name__c =ProRec2.Id;
        ProListRec4.SVMXC__IsStandard__c = false;
        ProListRec4.SVMXC__IsPrivate__c = false;
        ProListRec4.SVMXC__IsDefault__C = false;
        ProListRec4.SVMXC__Expertise_Match_Enabled__c = false;
        ProListRec4.SVMXC__Description__c = 'New description';
        ProListRec4.SVMXC__Active__c = true;
        ProListRec4.RecordTypeId = RecordType_ProcessNodeObjects.Id;
        insert ProListRec4;
        
        System.currentPagereference().getParameters().put('SVMX_recordID',accRecord.Id);
        System.currentPagereference().getParameters().put('SVMX_ProcessID',ProListRec.Id);
        System.currentPagereference().getParameters().put('SVMX_pageID',headerLayout.Id);
        System.currentPagereference().getParameters().put('SVMX_nxtStepID',ProListRec3.Id);
        System.currentPagereference().getParameters().put('SVMX_retURL','/apex/CONF_SetupHome');
        
        //-----------------------------------INSTANTIATING THE CLASS-----------------------------------------------------------//
        SFM_TDM_Delivery prossDel_Obj  = new  SFM_TDM_Delivery();
        
        //-----------------------------------METHOD CALLING--------------------------------------------------------------------//
        prossDel_Obj.getRecordID();
        prossDel_Obj.getProcessID();
        prossDel_Obj.getPageID();
        prossDel_Obj.getHeight();
        prossDel_Obj.getMySessionId();
        prossDel_Obj.getIsIdExsists();
        prossDel_Obj.getIsProcessExsists();
        prossDel_Obj.getIsError();
        prossDel_Obj.getErrorMsg();
        prossDel_Obj.getProcessErrMsg();
        prossDel_Obj.getIdErrMsg();
        prossDel_Obj.ExpressionQulification();
        prossDel_Obj.getreturnURL();
        prossDel_Obj.getloadingTag();
        prossDel_Obj.getProcessTitle();
        prossDel_Obj.getHdrMsg();
        prossDel_Obj.getMode();
        //prossDel_Obj.getIsSFMProces();
        prossDel_Obj.getProTypeErr();
        //prossDel_Obj.DoPageAction(); // #optiChange
       // prossDel_Obj.getTargetRecord();  // #optiChange
       // prossDel_Obj.saveTargetRecord();  // #optiChange
        System.assertEquals(true, prossDel_Obj.getRecordID() != null);
        System.assertEquals(true, prossDel_Obj.getProcessID()!= null);
        System.assertEquals(true, prossDel_Obj.getPageID()!= null);
        System.assertEquals(true, prossDel_Obj.getHeight()!= null);
        System.assertEquals(true, prossDel_Obj.getisSFMProcess() == true);  
        prossDel_Obj.getnxtStepID();
        prossDel_Obj.getdefaultSearchOperator();
        ////System.assertEquals(true, prossDel_Obj.getMySessionId()!= null);
        System.currentPagereference().getParameters().put('SVMX_Execution_Mode','SVMXAUTO');
        prossDel_Obj  = new  SFM_TDM_Delivery();
        //prossDel_Obj.DoPageAction(); // #optiChange
        prossDel_Obj.getTargetRecord();  // #optiChange
        prossDel_Obj.saveTargetRecord();  // #optiChange
        prossDel_Obj.getUserLocaleKey();
        prossDel_Obj.getUserID();
        prossDel_Obj.getUserOrgID();
        prossDel_Obj.getIsDuplicateProcess();        
        prossDel_Obj.getduplicateProcessMsg();
        prossDel_Obj.getpartnerServerURL();
        prossDel_Obj.DoCancel();
        
        SVMXC__ServiceMax_Processes__c ProListRec5 = new SVMXC__ServiceMax_Processes__c(Id=ProListRec.Id, SVMXC__Dispatch_Process_Status__c='Incomplete');
        update ProListRec5; 
        SFM_TDM_Delivery prossDel_Obj3  = new  SFM_TDM_Delivery();
        prossDel_Obj3.getTargetRecord();  
        }//method
    }//class