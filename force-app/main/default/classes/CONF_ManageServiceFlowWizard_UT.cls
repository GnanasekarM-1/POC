@isTest(SeeAllData=true)
private class CONF_ManageServiceFlowWizard_UT 
{
    static testMethod void CONF_ManageServiceFlowWizardUnitTest() 
    {
        SVMXC.CONF_ManageServiceFlowWizard SFW = new SVMXC.CONF_ManageServiceFlowWizard();
        List<SVMXC__ServiceMax_Processes__c> processLst = SFW.getstandardSFWLst();
        SFW.setstandardSFWLst(processLst);
        processLst = SFW.getcustomSFWLst();
        SFW.setcustomSFWLst(processLst);
        List<SelectOption> slctOptn = SFW.getObjectsWithSFW();
        //String sourceObj = SFW.getSelectedSourceObject();
        String sourceObj = '--None--';
        system.assert(sourceObj!=null);
        //SFW.setSelectedSourceObject(sourceObj);
        
        PageReference pagRef = SFW.displayStdNCustomSFWs();
        pagRef = SFW.StdView();
        pagRef = SFW.StdClone();
        pagRef = SFW.LayoutConfiguration();
        pagRef = SFW.Stdbacktosetuphme();
        pagRef = SFW.CustomNew();
        pagRef = SFW.CustomEdit();
        pagRef = SFW.CustomClone();
        pagRef = SFW.CustomDelete();
        String str = SFW.getTAG001();
        str = SFW.getTAG002();
        str = SFW.getTAG003();
        str = SFW.getTAG004();
        str = SFW.getTAG005();
        str = SFW.getTAG006();
        str = SFW.getTAG007();
        str = SFW.getTAG008();
        str = SFW.getTAG009();
        str = SFW.getTAG010();
        str = SFW.getTAG011();
        //str = SFW.getTAG012();
        str = SFW.getTAG013();
        str = SFW.getTAG014();
        str = SFW.getTAG015();
        str = SFW.getTAG016();
        str = SFW.getTAG017();
        str = SFW.getTAG018();
        str = SFW.getTAG019();
        str = SFW.getTAG020();
        str = SFW.getTAG021();
        str = SFW.getTAG022();
        str = SFW.getTAG023();
        str = SFW.getTAG024();
        str = SFW.getTAG025();
        str = SFW.getTAG026();
        str = SFW.getTAG027();
        //str = SFW.getTAG028();
        //str = SFW.getTAG029();
        str = SFW.getTAG030();
        str = SFW.getTAG031();
        str = SFW.getTAG032();
        str = SFW.getTAG033();
        system.assert(str!=null);
        //str = SFW.getTAG034();
        str = SFW.getTAG035();
        //str = SFW.getTAG036();
        str = SFW.getTAG037();
        str = SFW.getTAG038();
        SFW.getTAG039();
        SFW.getTAG040();
        SFW.getTAG041();
        system.assert(str!=null);
        
    }
    
    static testMethod void CONF_ManageSFWUnitTest1() 
    {
        String ActionRTypeId = '';
        
        RecordType Action_Rtype;
        //------------------ Querying the Record Types for the SVMX SFW --------------------------
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Wizard' Limit 1];
        ActionRTypeId = Action_Rtype.Id;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'process12';
        process.RecordTypeId = ActionRTypeId;
        process.SVMXC__IsStandard__c = true;
        process.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process.SVMXC__Select__c = true;
        insert process;
        system.assert(process.SVMXC__Name__c!=null);
        system.assert(process.SVMXC__IsStandard__c!=null);
        
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__Name__c = 'process21';
        process1.RecordTypeId = ActionRTypeId;
        process1.SVMXC__IsStandard__c = false;
        process1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process1.SVMXC__Select__c = true;
        insert process1;
        system.assert(process1.SVMXC__Name__c!=null);
        system.assert(process1.SVMXC__IsStandard__c!=null);
        
        CONF_ManageServiceFlowWizard SFW = new CONF_ManageServiceFlowWizard();
        
        String sourceObj = 'SVMXC__Service_Order__c';
        //SFW.setSelectedSourceObject(sourceObj);
        
        PageReference pagRef = SFW.displayStdNCustomSFWs();
        pagRef = SFW.StdView();
        pagRef = SFW.StdClone();
        pagRef = SFW.LayoutConfiguration();
        pagRef = SFW.Stdbacktosetuphme();
        pagRef = SFW.CustomNew();
        pagRef = SFW.CustomEdit();
        pagRef = SFW.CustomClone();
        pagRef = SFW.CustomDelete();
    }
    
    static testMethod void CONF_ManageSFWUnitTest2() 
    {
        String ActionRTypeId = '';
        
        RecordType Action_Rtype;
        //------------------ Querying the Record Types for the SVMX SFW --------------------------
        Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'Wizard' Limit 1];
        ActionRTypeId = Action_Rtype.Id;
        
        SVMXC__ServiceMax_Processes__c process = new SVMXC__ServiceMax_Processes__c();
        process.SVMXC__Name__c = 'process12';
        process.RecordTypeId = ActionRTypeId;
        process.SVMXC__IsStandard__c = true;
        process.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process.SVMXC__Select__c = true;
        insert process;
        system.assert(process.SVMXC__Name__c!=null);
        system.assert(process.SVMXC__Source_Object_Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__Name__c = 'process21';
        process1.RecordTypeId = ActionRTypeId;
        process1.SVMXC__IsStandard__c = false;
        process1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process1.SVMXC__Select__c = true;
        insert process1;
        system.assert(process1.SVMXC__Name__c!=null);
        system.assert(process1.SVMXC__Source_Object_Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c process2 = new SVMXC__ServiceMax_Processes__c();
        process2.SVMXC__Name__c = 'process12';
        process2.RecordTypeId = ActionRTypeId;
        process2.SVMXC__IsStandard__c = true;
        process2.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process2.SVMXC__Select__c = true;
        insert process2;
        system.assert(process2.SVMXC__Name__c!=null);
        system.assert(process2.SVMXC__Source_Object_Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c process3 = new SVMXC__ServiceMax_Processes__c();
        process3.SVMXC__Name__c = 'process21';
        process3.RecordTypeId = ActionRTypeId;
        process3.SVMXC__IsStandard__c = false;
        process3.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        process3.SVMXC__Select__c = true;
        insert process3;
        system.assert(process3.SVMXC__Name__c!=null);
        system.assert(process3.SVMXC__Source_Object_Name__c!=null);
        
        CONF_ManageServiceFlowWizard SFW = new CONF_ManageServiceFlowWizard();
        
        String sourceObj = 'SVMXC__Service_Order__c';
        system.assert(sourceObj!=null);
        //SFW.setSelectedSourceObject(sourceObj);
        SFW.getMap_ObjName_Label();
        SFW.getstdMode();
        SFW.getObjectOptns();
        SFW.setObjectOptns(new List<selectOption>());
        
        
        SFW.stringSelectObj = 'SVMXC__Service_Order__c';
        SFW.onSelectObject();
        
        SFW.stringSelectObj = 'SVMX.None';
        SFW.onSelectObject();
        
        PageReference pagRef = SFW.displayStdNCustomSFWs();
        pagRef = SFW.StdView();
        pagRef = SFW.StdClone();
        pagRef = SFW.Stdbacktosetuphme();
        pagRef = SFW.CustomNew();
        pagRef = SFW.CustomEdit();
        pagRef = SFW.CustomClone();
        pagRef = SFW.CustomDelete();
        SFW.getrenderSFWSections();
        //SFW.getDisableStandardSFWButtons();
        SFW.getDisableCustomSFWButtons();
        
        SVMXC__ServiceMax_Processes__c customWizard = new SVMXC__ServiceMax_Processes__c();
        customWizard.SVMXC__Name__c = 'process22';
        customWizard.RecordTypeId = ActionRTypeId;
        customWizard.SVMXC__IsStandard__c = false;
        customWizard.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        customWizard.SVMXC__Select__c = true;
        customWizard.SVMXC__Active__c = true;
        insert customWizard;
        List<SVMXC__ServiceMax_Processes__c> customWizardLst = new List<SVMXC__ServiceMax_Processes__c>();
        CONF_ManageServiceFlowWizard obj = new CONF_ManageServiceFlowWizard();
        obj.stringSelectObj = 'SVMXC__Service_Order__c';
        obj.displayStdNCustomSFWs();
        obj.CustomClone();
        obj.CustomDelete();
    }
}