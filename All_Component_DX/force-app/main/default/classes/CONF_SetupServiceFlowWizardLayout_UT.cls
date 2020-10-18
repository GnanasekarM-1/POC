@isTest(SeeAllData=true)
private class CONF_SetupServiceFlowWizardLayout_UT 
{
    static testMethod void CONF_SetupSFWLayoutUnitTest() 
    {
        RecordType Rtype_ToolbarHeader = [Select Id, Name from RecordType where Name = 'Wizard' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RtypeSVMX_Toolbar_Action = [Select Id, Name from RecordType where Name = 'Wizard step' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType Rtype_SVMXToolbarPermission = [Select Id, Name from RecordType where Name = 'Service Flow Access' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ];
        RecordType Rtype_SVMXConfigProfile = [Select Id, Name from RecordType where Name = 'Configuration Profile' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ];
        RecordType Rtype_SVMX_Toolbar_Layout = [Select Id, Name, SObjectType from RecordType where Name = 'Wizard Layout' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c ToolbarRec = new SVMXC__ServiceMax_Processes__c();
        ToolbarRec.SVMXC__Select__c = false;
        ToolbarRec.SVMXC__ProcessID__c = 'MyToolbar0001';
        ToolbarRec.SVMXC__Name__c = 'MyToolbar0001';
        ToolbarRec.SVMXC__Description__c = 'Sample Description';
        ToolbarRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        //ToolbarRec.SVMXC__Submodule__c = ;
        ToolbarRec.SVMXC__IsStandard__c = false;
        ToolbarRec.RecordTypeId = Rtype_ToolbarHeader.Id;
        insert ToolbarRec;
        system.assert(ToolbarRec.SVMXC__ProcessID__c!=null);
        system.assert(ToolbarRec.SVMXC__Name__c!=null);
        
        SVMXC__ServiceMax_Processes__c ToolbarRec1 = new SVMXC__ServiceMax_Processes__c();
        ToolbarRec1.SVMXC__Select__c = false;
        ToolbarRec1.SVMXC__ProcessID__c = 'MyToolbar0002';
        ToolbarRec1.SVMXC__Name__c = 'MyToolbar0002';
        ToolbarRec1.SVMXC__Description__c = 'Sample Description';
        ToolbarRec1.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        //ToolbarRec.SVMXC__Submodule__c = ;
        ToolbarRec1.SVMXC__IsStandard__c = false;
        ToolbarRec1.RecordTypeId = Rtype_ToolbarHeader.Id;
        insert ToolbarRec1;
        system.assert(ToolbarRec1.SVMXC__ProcessID__c!=null);
        system.assert(ToolbarRec1.SVMXC__Name__c!=null);
        
        SVMXC__ServiceMax_Config_Data__c SampleGroupProfile = new SVMXC__ServiceMax_Config_Data__c();
        SampleGroupProfile.SVMXC__PROFILE_NAME__C = 'SampleProfile0001';
        SampleGroupProfile.SVMXC__Description__C  = 'Sample Description';
        SampleGroupProfile.SVMXC__CONFIGURATION_TYPE__C = 'Group';
        SampleGroupProfile.RecordTypeId = Rtype_SVMXConfigProfile.Id;
        insert SampleGroupProfile;
        system.assert(SampleGroupProfile.SVMXC__Description__C!=null);
        
        SVMXC__ServiceMax_Config_Data__c ToolbarLayoutRec = new SVMXC__ServiceMax_Config_Data__c();
        ToolbarLayoutRec.SVMXC__Dispatch_Process__c = ToolbarRec.Id;
        ToolbarLayoutRec.SVMXC__Access_Configuration_Profile__c = SampleGroupProfile.Id;
        ToolbarLayoutRec.RecordTypeId = Rtype_SVMX_Toolbar_Layout.Id;
        ToolbarLayoutRec.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        ToolbarLayoutRec.SVMXC__Wizard_Layout_Row__c = 1;
        ToolbarLayoutRec.SVMXC__Wizard_Layout_Column__c = 1;
        ToolbarLayoutRec.SVMXC__Dispatch_Process__c = ToolbarRec.Id;
        insert ToolbarLayoutRec;
        system.assert(ToolbarLayoutRec.SVMXC__Object_Name__c!=null);
        
        SVMXC__ServiceMax_Config_Data__c ToolbarLayoutRec1 = new SVMXC__ServiceMax_Config_Data__c();
        ToolbarLayoutRec1.SVMXC__Dispatch_Process__c = ToolbarRec.Id;
        ToolbarLayoutRec1.SVMXC__Access_Configuration_Profile__c = SampleGroupProfile.Id;
        ToolbarLayoutRec1.RecordTypeId = Rtype_SVMX_Toolbar_Layout.Id;
        ToolbarLayoutRec1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        ToolbarLayoutRec1.SVMXC__Wizard_Layout_Row__c = 1;
        ToolbarLayoutRec1.SVMXC__Wizard_Layout_Column__c = 2;
        ToolbarLayoutRec1.SVMXC__Dispatch_Process__c = ToolbarRec.Id;
        insert ToolbarLayoutRec1;
        system.assert(ToolbarLayoutRec1.SVMXC__Object_Name__c!=null);
        
        SVMXC__ServiceMax_Config_Data__c ToolbarPermissionRec = new SVMXC__ServiceMax_Config_Data__c();
        ToolbarPermissionRec.SVMXC__Dispatch_Process__c = ToolbarRec.Id;
        ToolbarPermissionRec.SVMXC__Access_Configuration_Profile__c = SampleGroupProfile.Id;
        ToolbarPermissionRec.RecordTypeId = Rtype_SVMXToolbarPermission.Id;
        insert ToolbarPermissionRec;

        RecordType RType_SampleProcess = [SELECT Id, Name,SobjectType from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Target Manager'limit 1];
        SVMXC__ServiceMax_Processes__c SampleProcess = new SVMXC__ServiceMax_Processes__c();
        SampleProcess.RecordTypeId = RType_SampleProcess.Id;
        SampleProcess.SVMXC__ProcessID__c = 'Newprocess0002';
        SampleProcess.SVMXC__SettingID__c = 'Newprocess0002';
        insert SampleProcess;
        system.assert(SampleProcess.SVMXC__ProcessID__c!=null);
        system.assert(SampleProcess.SVMXC__SettingID__c!=null);
        
        SVMXC__ServiceMax_Processes__c ToolbarAction = new SVMXC__ServiceMax_Processes__c();
        ToolbarAction.SVMXC__Select__c = false;
        ToolbarAction.SVMXC__Sequence__c = 1 ;
        ToolbarAction.SVMXC__Module__c = ToolbarRec.Id; //Toolbar defn lookup
        ToolbarAction.SVMXC__Process__c = SampleProcess.Id;
        ToolbarAction.SVMXC__Name__c = 'ToolbarAction001';
        ToolbarAction.SVMXC__ProcessID__c = 'ToolbarAction001';
        ToolbarAction.SVMXC__SettingID__c = 'ToolbarAction001';
        ToolbarAction.SVMXC__Description__c = 'Sample Description';
        ToolbarAction.SVMXC__Action_Type__c = 'OTHERS';
        ToolbarAction.SVMXC__Action_URL__c = 'New url';
        //ToolbarAction.SVMXC__Submodule__c = ; //named expression lookup
        ToolbarAction.SVMXC__IsStandard__c = false;
        ToolbarAction.RecordTypeId = RtypeSVMX_Toolbar_Action.Id;
        insert ToolbarAction;
        
        SVMXC__ServiceMax_Processes__c ToolbarAction1 = new SVMXC__ServiceMax_Processes__c();
        ToolbarAction1.SVMXC__Select__c = false;
        ToolbarAction1.SVMXC__Sequence__c = 1 ;
        ToolbarAction1.SVMXC__Module__c = ToolbarRec.Id; //Toolbar defn lookup
        ToolbarAction1.SVMXC__Process__c = SampleProcess.Id;
        ToolbarAction1.SVMXC__Name__c = 'ToolbarAction1001';
        ToolbarAction1.SVMXC__ProcessID__c = 'ToolbarAction002';
        ToolbarAction1.SVMXC__SettingID__c = 'ToolbarAction002';
        ToolbarAction1.SVMXC__Description__c = 'Sample Description';
        ToolbarAction1.SVMXC__Action_Type__c = 'OTHERS';
        ToolbarAction1.SVMXC__Action_URL__c = 'New url';
        //ToolbarAction1.SVMXC__Submodule__c = ; //named expression lookup
        ToolbarAction1.SVMXC__IsStandard__c = false;
        ToolbarAction1.RecordTypeId = RtypeSVMX_Toolbar_Action.Id;
        insert ToolbarAction1;
        
        RecordType r1 = new RecordType();
        r1.Name = 'SVMX Toolbar Layout';
        r1.SobjectType = 'SVMXC__ServiceMax_Config_Data__c';
        
        pageReference pagRef =  System.currentPageReference();
        System.currentPageReference().getParameters().put('SVMX_ObjectName','SVMXC__Service_Order__c');
        
        SVMXC.CONF_SetupServiceFlowWizardLayout SFWLayout = new SVMXC.CONF_SetupServiceFlowWizardLayout();
        List<SelectOption> slctOptn = SFWLayout.getObjectsOptns();
        pagereference pageRef1 = SFWLayout.QuickSave();
        pagereference pageRef2 = SFWLayout.SaveNClose();
        pagereference pageRef3 = SFWLayout.Cancel();
        pagereference pageRef4 = SFWLayout.BackToSetupHome();
        SFWLayout.RedrawLayout();
        String str = SFWLayout.getSelectedObject();
        SFWLayout.setSelectedObject(str);
        List<SelectOption> slctOptn1 = SFWLayout.getAllSFWOptns();
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigData = SFWLayout.getSFWLayoutRecs_Column1();
        List<SVMXC__ServiceMax_Config_Data__c> lstConfigData1 =SFWLayout.getSFWLayoutRecs_Column2();
        SFWLayout.setSFWLayoutRecs_Column1(lstConfigData);
        SFWLayout.setSFWLayoutRecs_Column2(lstConfigData1);
        SFWLayout.AddRow();
        SFWLayout.getTag001();
        SFWLayout.getTag002();
        SFWLayout.getTag003();
        SFWLayout.getTag004();
        SFWLayout.getTag005();
        SFWLayout.getTag006();
        SFWLayout.getTag007();
        SFWLayout.getTag008();
        SFWLayout.getTag009();
        SFWLayout.getcontinueQuickSave();
        SFWLayout.getButtonsizeObj();
        SVMXC__ServiceMax_Config_Data__c buttonSizeObj = new SVMXC__ServiceMax_Config_Data__c();
        SFWLayout.setButtonsizeObj(buttonSizeObj);
        SFWLayout.getPreviewHtml();
        SFWLayout.PreviewLayout();
        SFWLayout.getTag010();
        SFWLayout.getTag011();
        SFWLayout.getTag012();
        SFWLayout.getTag013();
        SFWLayout.getTag014();
    }
}