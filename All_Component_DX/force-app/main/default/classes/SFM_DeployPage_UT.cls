@isTest
Private with sharing class SFM_DeployPage_UT
 {
    static testMethod void SFM_DeployPage_UT_Test()
    {
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        headerLayout.SVMXC__Page_Layout_ID__c = 'PageHeader';
        headerLayout.SVMXC__Type__c = 'Header';
        headerLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        headerLayout.SVMXC__Help_URL__c = 'www.test.com';
        headerLayout.SVMXC__Name__c = 'testName';
        headerLayout.SVMXC__Page_Help__c = 'test';
        insert headerLayout;
        
        System.assertEquals(true, headerLayout != null);
        
        SVMXC__Page_Layout__c headerLayout1 = new SVMXC__Page_Layout__c();
        headerLayout1.SVMXC__Page_Layout_ID__c = 'PageHeader1';
        headerLayout1.SVMXC__Type__c = 'Header';
        headerLayout1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        headerLayout1.SVMXC__Header_Page_Layout__c = headerLayout.id;
        insert headerLayout1;
        
        System.assertEquals(true, headerLayout1 != null);
        
        SVMXC__Page_Layout_Detail__c sectionDetail = new SVMXC__Page_Layout_Detail__c();
        sectionDetail.SVMXC__Page_Layout__c = headerLayout.id;
        insert sectionDetail;
        
        System.assertEquals(true, sectionDetail != null);
        
        List<SFM_WrapperDef.SFM_UIField> fields = new List<SFM_WrapperDef.SFM_UIField>();
        SFM_WrapperDef.SFM_UIField field1 = new SFM_WrapperDef.SFM_UIField();
        fields.add(field1);
        
        System.assertEquals(true, fields != null);
        
        List<SFM_WrapperDef.SFM_UISection> sections = new List<SFM_WrapperDef.SFM_UISection>();
        SFM_WrapperDef.SFM_UISection section1 = new SFM_WrapperDef.SFM_UISection(sectionDetail,fields);
        sections.add(section1);
        
        System.assertEquals(true, sections != null);
        
        List<SFM_WrapperDef.SFM_UIButton> buttons = new List<SFM_WrapperDef.SFM_UIButton>();
        SFM_WrapperDef.SFM_UIButton button1 = new SFM_WrapperDef.SFM_UIButton();
        buttons.add(button1);
        
        System.assertEquals(true, buttons != null);
        
        List<SVMXC__SFM_Event__c> pageEvents = new List<SVMXC__SFM_Event__c>();
        SVMXC__SFM_Event__c pageEvent1 = new SVMXC__SFM_Event__c();
        pageEvents.add(pageEvent1);
        insert pageEvents;
        
        System.assertEquals(true, pageEvents != null);
        
        SVMXC__ServiceMax_Processes__c processNode = new SVMXC__ServiceMax_Processes__c();
        processNode.SVMXC__Name__c = 'process001';
        processNode.SVMXC__ProcessID__c = 'process001';
        processNode.SVMXC__SettingID__c = 'setting001';
        
        System.assertEquals(true, processNode != null);
        
        String userId;
        String groupId;
        String profileId;
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap();
        stringMap.add(stringMap1);
        
        System.assertEquals(true, stringMap != null);
       
        SFM_WrapperDef.SFM_Request pmax = new SFM_WrapperDef.SFM_Request(userId,groupId,profileId,stringMap);
        
        System.assertEquals(true, pmax != null);
        
        SFM_WrapperDef.SFM_PageHeader header = new SFM_WrapperDef.SFM_PageHeader(headerLayout,sections,buttons,pageEvents);
        List<SFM_WrapperDef.SFM_PageDetail> details = new List<SFM_WrapperDef.SFM_PageDetail>();
        SFM_WrapperDef.SFM_PageDetail detail1 = new SFM_WrapperDef.SFM_PageDetail();
        details.add(detail1);
        
        System.assertEquals(true, details != null);
        
        SFM_WrapperDef.SFM_PageUI page = new SFM_WrapperDef.SFM_PageUI(header,details);
        
        SFM_WrapperDef.SFM_Request_PageUI request = new SFM_WrapperDef.SFM_Request_PageUI(page,processNode,pmax);
        SFM_DeployPage pageDeploy = new SFM_DeployPage();
        SFM_WrapperDef.SFM_Response response = pageDeploy.SFM_DeployPage(request);
    }
    
    static testMethod void SFM_DeployPage_UT_Test1()
    {
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        insert headerLayout;
        
        System.assertEquals(true, headerLayout != null);
        
        SVMXC__Page_Layout_Detail__c sectionDetail = new SVMXC__Page_Layout_Detail__c();
        sectionDetail.SVMXC__Page_Layout__c = headerLayout.id;
        insert sectionDetail;
        
        System.assertEquals(true, sectionDetail != null);
        
        List<SFM_WrapperDef.SFM_UIField> fields = new List<SFM_WrapperDef.SFM_UIField>();
        SFM_WrapperDef.SFM_UIField field1 = new SFM_WrapperDef.SFM_UIField();
        fields.add(field1);
        
        System.assertEquals(true, fields != null);
        
        List<SFM_WrapperDef.SFM_UISection> sections = new List<SFM_WrapperDef.SFM_UISection>();
        SFM_WrapperDef.SFM_UISection section1 = new SFM_WrapperDef.SFM_UISection(sectionDetail,fields);
        sections.add(section1);
        
        System.assertEquals(true, sections != null);
        
        List<SFM_WrapperDef.SFM_UIButton> buttons = new List<SFM_WrapperDef.SFM_UIButton>();
        SFM_WrapperDef.SFM_UIButton button1 = new SFM_WrapperDef.SFM_UIButton();
        buttons.add(button1);
        
        System.assertEquals(true, buttons != null);
        
        List<SVMXC__SFM_Event__c> pageEvents = new List<SVMXC__SFM_Event__c>();
        SVMXC__SFM_Event__c pageEvent1 = new SVMXC__SFM_Event__c();
        pageEvents.add(pageEvent1);
        insert pageEvents;
        
        System.assertEquals(true, pageEvents != null);
        
        SVMXC__ServiceMax_Processes__c processNode = new SVMXC__ServiceMax_Processes__c();
        processNode.SVMXC__Name__c = 'process001';
        processNode.SVMXC__ProcessID__c = 'process001';
        processNode.SVMXC__SettingID__c = 'setting001';
        
        System.assertEquals(true, processNode != null);
        
        String userId;
        String groupId;
        String profileId;
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap();
        stringMap.add(stringMap1);
        
        System.assertEquals(true, stringMap != null);
       
        SFM_WrapperDef.SFM_Request pmax = new SFM_WrapperDef.SFM_Request(userId,groupId,profileId,stringMap);
        
        SFM_WrapperDef.SFM_PageHeader header = new SFM_WrapperDef.SFM_PageHeader(headerLayout,sections,buttons,pageEvents);
        List<SFM_WrapperDef.SFM_PageDetail> details = new List<SFM_WrapperDef.SFM_PageDetail>();
        SFM_WrapperDef.SFM_PageDetail detail1 = new SFM_WrapperDef.SFM_PageDetail();
        details.add(detail1);
        SFM_WrapperDef.SFM_PageUI page = new SFM_WrapperDef.SFM_PageUI(header,details);
        
        SFM_WrapperDef.SFM_Request_PageUI request = new SFM_WrapperDef.SFM_Request_PageUI(page,processNode,pmax);
        SFM_DeployPage pageDeploy = new SFM_DeployPage();
        SFM_WrapperDef.SFM_Response response = pageDeploy.SFM_DeployPage(request);
    }
    static testMethod void SFM_DeployPage_UT_Test3()
    {
        SVMXC__Page_Layout__c headerLayout = new SVMXC__Page_Layout__c();
        headerLayout.SVMXC__Page_Layout_ID__c = 'PageHeader';
        headerLayout.SVMXC__Type__c = 'Header';
        headerLayout.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        headerLayout.SVMXC__Help_URL__c = 'www.test.com';
        headerLayout.SVMXC__Name__c = 'testName';
        headerLayout.SVMXC__Page_Help__c = 'test';
        headerLayout.SVMXC__IsStandard__c = true;
        insert headerLayout;
        
        System.assertEquals(true, headerLayout != null);
        
        SVMXC__Page_Layout__c headerLayout1 = new SVMXC__Page_Layout__c();
        headerLayout1.SVMXC__Page_Layout_ID__c = 'PageHeader1';
        headerLayout1.SVMXC__Type__c = 'Header';
        headerLayout1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        headerLayout1.SVMXC__Header_Page_Layout__c = headerLayout.id;
        headerLayout1.SVMXC__IsStandard__c = true;
        insert headerLayout1;
        
        System.assertEquals(true, headerLayout1 != null);
        
        SVMXC__Page_Layout_Detail__c sectionDetail = new SVMXC__Page_Layout_Detail__c();
        sectionDetail.SVMXC__Page_Layout__c = headerLayout.id;
        insert sectionDetail;
        
        System.assertEquals(true, sectionDetail != null);
        
        List<SFM_WrapperDef.SFM_UIField> fields = new List<SFM_WrapperDef.SFM_UIField>();
        SFM_WrapperDef.SFM_UIField field1 = new SFM_WrapperDef.SFM_UIField();
        fields.add(field1);
        
        System.assertEquals(true, fields != null);
        
        List<SFM_WrapperDef.SFM_UISection> sections = new List<SFM_WrapperDef.SFM_UISection>();
        SFM_WrapperDef.SFM_UISection section1 = new SFM_WrapperDef.SFM_UISection(sectionDetail,fields);
        sections.add(section1);
        
        System.assertEquals(true, sections != null);
        
        List<SFM_WrapperDef.SFM_UIButton> buttons = new List<SFM_WrapperDef.SFM_UIButton>();
        SFM_WrapperDef.SFM_UIButton button1 = new SFM_WrapperDef.SFM_UIButton();
        buttons.add(button1);
        
        System.assertEquals(true, buttons != null);
        
        List<SVMXC__SFM_Event__c> pageEvents = new List<SVMXC__SFM_Event__c>();
        SVMXC__SFM_Event__c pageEvent1 = new SVMXC__SFM_Event__c();
        pageEvents.add(pageEvent1);
        insert pageEvents;
        
        System.assertEquals(true, pageEvents != null);
        
        SVMXC__ServiceMax_Processes__c processNode = new SVMXC__ServiceMax_Processes__c();
        processNode.SVMXC__Name__c = 'process001';
        processNode.SVMXC__ProcessID__c = 'process001';
        processNode.SVMXC__SettingID__c = 'setting001';
        
        System.assertEquals(true, processNode != null);
        
        String userId;
        String groupId;
        String profileId;
        List<SFM_WrapperDef.SFM_StringMap> stringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap();
        stringMap.add(stringMap1);
        
        System.assertEquals(true, stringMap != null);
       
        SFM_WrapperDef.SFM_Request pmax = new SFM_WrapperDef.SFM_Request(userId,groupId,profileId,stringMap);
        
        System.assertEquals(true, pmax != null);
        
        SFM_WrapperDef.SFM_PageHeader header = new SFM_WrapperDef.SFM_PageHeader(headerLayout,sections,buttons,pageEvents);
        List<SFM_WrapperDef.SFM_PageDetail> details = new List<SFM_WrapperDef.SFM_PageDetail>();
        SFM_WrapperDef.SFM_PageDetail detail1 = new SFM_WrapperDef.SFM_PageDetail();
        details.add(detail1);
        
        System.assertEquals(true, details != null);
        
        SFM_WrapperDef.SFM_PageUI page = new SFM_WrapperDef.SFM_PageUI(header,details);
        
        SFM_WrapperDef.SFM_Request_PageUI request = new SFM_WrapperDef.SFM_Request_PageUI(page,processNode,pmax);
        SFM_DeployPage pageDeploy = new SFM_DeployPage();
        SFM_WrapperDef.SFM_Response response = pageDeploy.SFM_DeployPage(request);
    }
 }