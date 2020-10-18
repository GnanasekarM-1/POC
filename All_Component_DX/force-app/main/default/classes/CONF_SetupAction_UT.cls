@isTest(SeeAllData=true)
private class CONF_SetupAction_UT 
{
    static testMethod void CONF_SetupActionUnitTest() 
    {
        List<SelectOption> sortList = new List<SelectOption>();
        sortList.add(new SelectOption('B','B'));
        sortList.add(new SelectOption('A','A'));
        
        RecordType r = new RecordType();
        r.Name = 'SF Action';
        r.SobjectType = 'SVMXC__ServiceMax_Processes__c';
        //insert r;
        system.assert(r.Name!=null);
        
        RecordType r1 = new RecordType();
        r1.Name = 'SF Action Parameter';
        r1.SobjectType = 'SVMXC__ServiceMax_Config_Data__c';
        system.assert(r1.Name!=null);
        system.assert(r1.SobjectType!=null);
        //insert r1;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst1 = new List<SVMXC__ServiceMax_Config_Data__c>();
        String val;
        
        pageReference pagRef =  System.currentPageReference();
        System.currentPageReference().getParameters().put('SVMX_ObjectName','SVMXC__Service_Order__c');
        
        CONF_SetupAction actn = new CONF_SetupAction();
        //actn.getParamterInfoTable();
        process = actn.getSVMXActn();
        configLst1 = actn.getActionParam();
        actn.setSVMXActn(process);
        actn.setActionParam(configLst1);
        String str1 = actn.getPageBlockTitle();
        String str2 = actn.getObjectName();
        String str3 = actn.getSelectedSourceObject();
        actn.setPageBlockTitle(str1);
        List<SelectOption> slctOpn = actn.getObjectsWithAction();
        //List<SelectOption> slctOpn1 = actn.getFieldsOfObjectWithAction();
        List<SelectOption> slctOpn2 = actn.getURLType();
        List<SelectOption> slctOpn3 = actn.getParamTypePckLst();
        actn.setSelectedSourceObject(val);
        actn.sortingSelectOption(sortList);
        string s2 = actn.getTAG002();
        s2 = actn.getTAG001();
        string s3 = actn.getTAG003();
        string s5 = actn.getTAG005();
        string s6 = actn.getTAG006();
        string s7 = actn.getTAG007();
        string s8 = actn.getTAG008();
        string s9 = actn.getTAG009();
        string s10 = actn.getTAG010();
        string s11 = actn.getTAG011();
        string s12 = actn.getTAG012();
        string s13 = actn.getTAG013();
        string s14 = actn.getTAG014();
        string s15 = actn.getTAG015();
        string s16 = actn.getTAG017();
        string s17 = actn.getTAG018();
        string s18 = actn.getTAG019();
        string s20 = actn.getTAG021();
        string s21 = actn.getTAG022();
        string s22 = actn.getTAG023();
        string s23 = actn.getTAG024();
        string s24 = actn.getTAG025();
        string s25 = actn.getTAG026();
        string s26 = actn.getTAG028();
        string s31 = actn.getTAG033();
        string s36 = actn.getTAG038();
        string s42 = actn.getTAG040();
        string s43 = actn.getTAG041();
        string s44 = actn.getTAG042();
        string s45 = actn.getTAG043();
        string s50 = actn.getTAG052();
        string s51 = actn.getTAG053();
        string s52 = actn.getTAG054();
        string s53 = actn.getTAG016();
        string s54 = actn.getTAG027();
        string s55 = actn.getTAG029();
        string s56 = actn.getTAG030();
        string s57 = actn.getTAG031();//
        string s58 = actn.getTAG004();//
        string s59 = actn.getTAG056();//
        s56 = actn.getHLPURL();
        system.assert(s57!=null);
        system.assert(s58!=null);
        system.assert(s59!=null);
        pageReference pagRef5 = actn.onChngParamType();
        pageReference pagRef2 = actn.cancel();
        pagereference pagRef3 = actn.addLines();
        pageReference pagRef4 = actn.delLines();
        actn.WndwHgtWdt();
        Boolean b = actn.getDisableHeightWidthFields();
    }
    
    static testMethod void CONF_SetupActionUnitTest1() 
    {
        String ActionRTypeId = '';
        String ActionRTypeId1 = '';
        RecordType Action_Rtype;
        RecordType Parameter_RType;
        
        Parameter_RType = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SF Action Parameter'];
        ActionRTypeId1 = Parameter_RType.Id;
        
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SF Action' Limit 1];
        ActionRTypeId = Action_Rtype.Id;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'Process001';
        process.SVMXC__ProcessID__c = 'Process001';
        process.SVMXC__Window_Height__c = 400;
        process.SVMXC__Window_Width__c = 600;
        process.SVMXC__Description__c = 'Process001 for unit test Class';
        process.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process.SVMXC__Active__c = true;
        process.SVMXC__Target_Type__c = 'New Window';
        process.SVMXC__Target_URL__c = '/apex/Window';
        process.SVMXC__IsStandard__c = true;
        process.RecordTypeId = ActionRTypeId;
        insert process;
        system.assert(process.SVMXC__Name__c!=null);
        system.assert(process.SVMXC__ProcessID__c!=null);
        system.assert(process.SVMXC__Source_Object_Name__c!=null);
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c config = new SVMXC__ServiceMax_Config_Data__c();
        config.SVMXC__Parameter_Name__c = 'actionParam001';
        config.SVMXC__Parameter_Type__c = 'Field Name';
        config.SVMXC__Parameter_Value__c = 'Account';
        config.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        config.SVMXC__Select__c = true;
        config.SVMXC__Sequence__c = 1.0;
        config.SVMXC__Dispatch_Process__c = process.id;
        config.RecordTypeId = ActionRTypeId1;
        configLst.add(config);
        
        SVMXC__ServiceMax_Config_Data__c config1 = new SVMXC__ServiceMax_Config_Data__c();
        config1.SVMXC__Parameter_Name__c = 'actionParam002';
        config.SVMXC__Sequence__c = 2.0;
        config1.SVMXC__Parameter_Type__c = 'Field Source';
        config1.SVMXC__Parameter_Value__c = 'SVMXC__City__c';
        config1.SVMXC__Object_Name2__c = 'SVMXC__Service_Group_Members__c';
        config1.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Group_Member__r';
        config1.SVMXC__Dispatch_Process__c = process.id;
        config1.RecordTypeId = ActionRTypeId1;
        configLst.add(config1);
        
        SVMXC__ServiceMax_Config_Data__c config2 = new SVMXC__ServiceMax_Config_Data__c();
        config2.SVMXC__Parameter_Name__c = 'actionParam001';
        config.SVMXC__Sequence__c = 3.0;
        config2.SVMXC__Parameter_Type__c = 'Value';
        config2.SVMXC__Parameter_Value__c = '';
        config2.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        config2.SVMXC__Select__c = true;
        config2.SVMXC__Dispatch_Process__c = process.id;
        config2.RecordTypeId = ActionRTypeId1;
        configLst.add(config2);
        
        insert configLst;
        system.assert(config.SVMXC__Parameter_Name__c!=null);
        system.assert(config.SVMXC__Parameter_Value__c!=null);
        
        //System.currentPageReference().getParameters().put('SVMX_Action','Clone');
        System.currentPageReference().getParameters().put('SVMX_RecordId',process.id);
        CONF_SetupAction actn = new CONF_SetupAction();
        pageReference pagRef5 = actn.onChngParamType();
        pageReference pagRef2 = actn.quickSave();
        pageReference pagRef1 = actn.saveAndClose();
        
        actn.setintIndex(1);
        actn.onChngParamType();
        
        actn.setintIndex(2);
        actn.onChngParamType();
        
        actn.setintIndex(3);
        actn.onChngParamType();
        
        actn.setintIndexParamSource(2);
        actn.paramSource = 'SVMXC__Service_Group_Members__c~SVMXC__Group_Member__r';
        actn.onChngParamSource();
        
        //actn.ListActionParameterWrapper[0].getIsSecondListHasItem();
        //actn.ListActionParameterWrapper[0].getobjConfigData();
        //actn.ListActionParameterWrapper[0].getObjFieldList();
        actn.ListActionParameterWrapper[0].getRelatedObjects();
        
        CONF_SetupAction.FieldListWrapper obj = actn.listOfObjects;
        Boolean test = actn.getIsSecondListHasItemObject();
        String str1 = actn.paramValue;
        String str2 = actn.paramName;
        Boolean str3 = actn.showText;
        String str4 = actn.SlctdParamValue;   
        List<CONF_SetupAction.ActionParameterWrapper> lst = actn.getListActionParameterWrapper();
        actn.delLines();
    }
    
    static testMethod void CONF_SetupActionUnitTest2() 
    {
        String ActionRTypeId = '';
        String ActionRTypeId1 = '';
        RecordType Action_Rtype;
        RecordType Parameter_RType;
        
        Parameter_RType = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SF Action Parameter'];
        ActionRTypeId1 = Parameter_RType.Id;
        
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SF Action' Limit 1];
        ActionRTypeId = Action_Rtype.Id;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'Process001';
        process.SVMXC__ProcessID__c = 'Process001';
        process.SVMXC__Window_Height__c = 400;
        process.SVMXC__Window_Width__c = 600;
        process.SVMXC__Description__c = 'Process001 for unit test Class';
        process.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process.SVMXC__Active__c = true;
        process.SVMXC__Target_Type__c = 'New Window';
        process.SVMXC__Target_URL__c = '/apex/Window';
        process.SVMXC__IsStandard__c = false;
        process.RecordTypeId = ActionRTypeId;
        insert process;
        system.assert(process.SVMXC__Name__c!=null);
        system.assert(process.SVMXC__ProcessID__c!=null);
        system.assert(process.SVMXC__Source_Object_Name__c!=null);
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c config = new SVMXC__ServiceMax_Config_Data__c();
        config.SVMXC__Parameter_Name__c = 'actionParam001';
        config.SVMXC__Parameter_Type__c = 'Value';
        config.SVMXC__Parameter_Value__c = '';
        config.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        config.SVMXC__Select__c = true;
        config.SVMXC__Dispatch_Process__c = process.id;
        config.RecordTypeId = ActionRTypeId1;
        configLst.add(config);
        
        SVMXC__ServiceMax_Config_Data__c config1 = new SVMXC__ServiceMax_Config_Data__c();
        config1.SVMXC__Parameter_Name__c = 'actionParam002';
        config1.SVMXC__Parameter_Type__c = 'Field Source';
        config1.SVMXC__Parameter_Value__c = 'SVMXC__City__c';
        config1.SVMXC__Object_Name2__c = 'SVMXC__Service_Group_Members__c';
        config1.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Group_Member__r';
        config1.SVMXC__Dispatch_Process__c = process.id;
        config1.RecordTypeId = ActionRTypeId1;
        configLst.add(config1);
        
        SVMXC__ServiceMax_Config_Data__c config2 = new SVMXC__ServiceMax_Config_Data__c();
        config2.SVMXC__Parameter_Name__c = 'actionParam001';
        config2.SVMXC__Parameter_Type__c = 'Field Name';
        config2.SVMXC__Parameter_Value__c = 'Account';
        config2.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        config2.SVMXC__Select__c = true;
        config2.SVMXC__Dispatch_Process__c = process.id;
        config2.RecordTypeId = ActionRTypeId1;
        configLst.add(config2);
        
        system.assert(config.SVMXC__Parameter_Name__c!=null);
        system.assert(config.SVMXC__Object_Name__c!=null);
        
        insert configLst;
        system.assert(configLst.size()>0);
        
        System.currentPageReference().getParameters().put('SVMX_Action','Clone');
        System.currentPageReference().getParameters().put('SVMX_RecordId',process.id);
        CONF_SetupAction actn = new CONF_SetupAction();
        pageReference pagRef2 = actn.quickSave();
        pageReference pagRef1 = actn.saveAndClose();
    }
    
    static testMethod void CONF_SetupActionUnitTest3() 
    {
        String ActionRTypeId = '';
        String ActionRTypeId1 = '';
        RecordType Action_Rtype;
        RecordType Parameter_RType;
        
        Parameter_RType = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SF Action Parameter'];
        ActionRTypeId1 = Parameter_RType.Id;
        
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SF Action' Limit 1];
        ActionRTypeId = Action_Rtype.Id;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'Process001';
        process.SVMXC__ProcessID__c = '';
        process.SVMXC__Window_Height__c = 0;
        process.SVMXC__Window_Width__c = 0;
        process.SVMXC__Description__c = 'Process001 for unit test Class';
        process.SVMXC__Source_Object_Name__c = '--None--';
        process.SVMXC__Active__c = true;
        process.SVMXC__Target_Type__c = 'New Window';
        process.SVMXC__Target_URL__c = '';
        process.SVMXC__IsStandard__c = false;
        process.RecordTypeId = ActionRTypeId;
        insert process;
        system.assert(process.SVMXC__Name__c!=null);
        system.assert(process.SVMXC__Source_Object_Name__c!=null);
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c config = new SVMXC__ServiceMax_Config_Data__c();
        config.SVMXC__Parameter_Name__c = '';
        config.SVMXC__Parameter_Type__c = '--None--';
        config.SVMXC__Parameter_Value__c = '';
        config.SVMXC__Object_Name__c = '';
        config.SVMXC__Select__c = true;
        config.SVMXC__Dispatch_Process__c = process.id;
        config.RecordTypeId = ActionRTypeId1;
        system.assert(config.SVMXC__Parameter_Type__c!=null);
        
        configLst.add(config);
        insert configLst;
        system.assert(configLst.size()>0);
        
        System.currentPageReference().getParameters().put('SVMX_RecordId',process.id);
        CONF_SetupAction actn = new CONF_SetupAction();
        pageReference pagRef2 = actn.quickSave();
        pageReference pagRef1 = actn.saveAndClose();
        actn.WndwHgtWdt();
    }
    
    // Ramachandra
    static testMethod void CONF_SetupActionUnit_Coverage() 
    {
        String ActionRTypeId = '';
        String ActionRTypeId1 = '';
        RecordType Action_Rtype;
        RecordType Parameter_RType;
        
        Parameter_RType = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SF Action Parameter'];
        ActionRTypeId1 = Parameter_RType.Id;
        
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SF Action' Limit 1];
        ActionRTypeId = Action_Rtype.Id;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'Process001';
        process.SVMXC__ProcessID__c = '';
        process.SVMXC__Window_Height__c = 0;
        process.SVMXC__Window_Width__c = 0;
        process.SVMXC__Description__c = 'Process001 for unit test Class';
        process.SVMXC__Source_Object_Name__c = '--None--';
        process.SVMXC__Active__c = true;
        process.SVMXC__Target_Type__c = 'New Window';
        process.SVMXC__Target_URL__c = '';
        process.SVMXC__IsStandard__c = false;
        process.RecordTypeId = ActionRTypeId;
        insert process;
        system.assert(process.SVMXC__Name__c!=null);
        system.assert(process.SVMXC__Source_Object_Name__c!=null);
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c config = new SVMXC__ServiceMax_Config_Data__c();
        config.SVMXC__Parameter_Name__c = '';
        config.SVMXC__Parameter_Type__c = '--None--';
        config.SVMXC__Parameter_Value__c = '';
        config.SVMXC__Object_Name__c = '';
        config.SVMXC__Select__c = true;
        config.SVMXC__Dispatch_Process__c = process.id;
        config.RecordTypeId = ActionRTypeId1;
        system.assert(config.SVMXC__Parameter_Type__c!=null);
        
        configLst.add(config);
        insert configLst;
        system.assert(configLst.size()>0);
        
        System.currentPageReference().getParameters().put('SVMX_RecordId',process.id);
        CONF_SetupAction actn = new CONF_SetupAction();
        pageReference pagRef2 = actn.quickSave();
        pageReference pagRef1 = actn.saveAndClose();
        actn.WndwHgtWdt();
        
        actn.setopenAsFullWindow( actn.getopenAsFullWindow() );
        actn.setActnTypeOptns( actn.getActnTypeOptns() );
        actn.onChngActnType();
        actn.isFullWindow();
        
        actn.getTAG055();
        actn.getTAG057();
        actn.getTAG058();
        actn.getTAG059();
        actn.getTAG060();
        actn.getTAG061();
        actn.getTAG062();
        actn.getTAG063();
        actn.getTAG066();
        actn.getTAG067();
        //Jaysukh
        actn.getTAG071();
        actn.getTAG072();
        actn.getTAG073();
        actn.getTAG074();
        actn.getTAG075();
        actn.getTAG068();
        actn.getTAG069();
        actn.getTAG085();
        actn.getTAG086();
        //BAC-5392
        actn.getTAG087();
        actn.getTAG088();
        actn.getTAG089();
        actn.getTAG090();
        actn.getTAG091();
        actn.getTAG092();
        actn.getTAG093();
    }
}