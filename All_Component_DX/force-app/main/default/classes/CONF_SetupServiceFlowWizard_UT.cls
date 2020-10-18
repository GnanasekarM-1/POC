@isTest
private class CONF_SetupServiceFlowWizard_UT
{
  static Map<String,RecordType> recordTypeIdMap = new Map<String,RecordType>();    
    static testMethod void CONF_SetupServiceFlowWizard_UT_Test()
    {
        System.currentPageReference().getParameters().put('SVMX_ObjectName','SVMXC__Service_Order__c');
        CONF_SetupServiceFlowWizard setupServiceFlowWizard = new CONF_SetupServiceFlowWizard();
        SVMXC.CONF_SetupServiceFlowWizard.SvmxActionWrapper wrpr = new CONF_SetupServiceFlowWizard.SvmxActionWrapper(new SVMXC__ServiceMax_Processes__c(),null,null, null, null,'');
        wrpr.getSvmxActionRec();
        wrpr.setSvmxActionRec(new SVMXC__ServiceMax_Processes__c());
        
        wrpr.getSelectedActionType();
        wrpr.setSelectedActionType('SFM');
        wrpr.getSelectedCriteriaToEnable();
        wrpr.setSelectedCriteriaToEnable(null);
        String str = setupServiceFlowWizard.getSVMXRecId();
        
        str = setupServiceFlowWizard.getObjectName();
        str = setupServiceFlowWizard.getMode();
        
        
        boolean b;

        b = setupServiceFlowWizard.getDisableActnNew();

        b = setupServiceFlowWizard.getDisableActnDelete();
        b = setupServiceFlowWizard.getDisableActnSequence();

        List<SelectOption> slctFieldTypeOptn = setupServiceFlowWizard.getSFWActn_ActionFieldTypeOptns();
        List<SelectOption> slctModeOfExecOptn = setupServiceFlowWizard.getmodeOfExecutionOptns();
        SVMXC__ServiceMax_Processes__c c = new SVMXC__ServiceMax_Processes__c();

        List<CONF_SetupServiceFlowWizard.SvmxActionWrapper> actnWrpr = setupServiceFlowWizard.getSvmxActionWrapperLst();
        setupServiceFlowWizard.setSvmxActionWrapperLst(actnWrpr);
        b = setupServiceFlowWizard.getDisplayComponent();
        setupServiceFlowWizard.OnChangeOfShowNHideCriteria();
        str = setupServiceFlowWizard.getPageBlockTitle();
        str = setupServiceFlowWizard.getselectedTab();
        setupServiceFlowWizard.setselectedTab(str);
        str = setupServiceFlowWizard.getSelectedcriteria();
        setupServiceFlowWizard.setSelectedcriteria(str);
        str = setupServiceFlowWizard.getselectedSvmxSFW();
        setupServiceFlowWizard.setselectedSvmxSFW(str);
        List<SelectOption> slctOptn = setupServiceFlowWizard.getAvailableSvmxSFWs();
        List<String> lstStr = setupServiceFlowWizard.getavailableProfilesSelctd();
        setupServiceFlowWizard.setavailableProfilesSelctd(lstStr);
        slctOptn = setupServiceFlowWizard.getAvailableSvmxGrpProfiles();
        lstStr = setupServiceFlowWizard.getselectedProfilesSelctd();
        setupServiceFlowWizard.setselectedProfilesSelctd(lstStr);
        slctOptn = setupServiceFlowWizard.getSelectedSvmxGrpProfiles();
        c = setupServiceFlowWizard.getSFWRec();
        setupServiceFlowWizard.setSFWRec(c);
        slctOptn = setupServiceFlowWizard.getShowHidecriteriaOptns();
        List<SVMXC__ServiceMax_Processes__c> TActionsLst = setupServiceFlowWizard.getSFWActionsLst();
        SVMXC__ServiceMax_Processes__c[] arayProcess = setupServiceFlowWizard.getSFWActionsSEQLst();
        setupServiceFlowWizard.setSFWActionsLst(TActionsLst);
        setupServiceFlowWizard.onAddProfile();
        setupServiceFlowWizard.onRemProfile();
        pageReference pagRef = setupServiceFlowWizard.gotoGeneralInfoTab();
        pagRef = setupServiceFlowWizard.gotoManageActionsTab();
        pagRef = setupServiceFlowWizard.gotoManagePermissionsTab();
        b = setupServiceFlowWizard.getNewActionRecCreationMode();
        b = setupServiceFlowWizard.getDisableActionRecSave();
        pagRef = setupServiceFlowWizard.NewAction();
        //actnWrpr[0].SvmxActionRec.SVMXC__Select__c = true;
        pagRef = setupServiceFlowWizard.EditAction();
        setupServiceFlowWizard.rerenderAvailablesfws();
        b = setupServiceFlowWizard.getIsbuttonsDisabled();
        str = setupServiceFlowWizard.getSelectedCriteriaToenable();
        setupServiceFlowWizard.setSelectedCriteriaToenable(str);
        slctOptn = setupServiceFlowWizard.getCriteriaToEnableOptns();
        b = setupServiceFlowWizard.getDisableCriToEnableEditLink();
        
        setupServiceFlowWizard.onChangeOfActionPicklist();
        //pagRef = setupServiceFlowWizard.DeleteAction();
        b = setupServiceFlowWizard.getRenderSeqBlock();
        setupServiceFlowWizard.SequenceActions();
        //setupServiceFlowWizard.cancelAction();
        pagRef = setupServiceFlowWizard.SaveAction();
        b = setupServiceFlowWizard.ValidationsOnSave();
        pagRef = setupServiceFlowWizard.QuickSave();
        setupServiceFlowWizard.QuickSaveSuccessful = true;
        pagRef = setupServiceFlowWizard.SaveNClose();
        c = setupServiceFlowWizard.getSelectedexpHeader();
        SVMXC__ServiceMax_Config_Data__c[] arayConfigData = setupServiceFlowWizard.getexpdtlLst();
        setupServiceFlowWizard.OnchangeOfcriteriaPicklist();
        setupServiceFlowWizard.OnClickOfEditCriteria();
        pagRef = setupServiceFlowWizard.HeaderCancel();
        pagRef = setupServiceFlowWizard.ChangeActnExprCriteria();
        
        System.currentPageReference().getParameters().put('SVMX_ObjectName','SVMXC__RMA_Shipment_Order__c');
        String ObjName = setupServiceFlowWizard.getObjectName();
        //CONF_SetupServiceFlowWizard setupServiceFlowWizard1 = new CONF_SetupServiceFlowWizard();
        
        //setupServiceFlowWizard.isChkConformation();
        
        setupServiceFlowWizard.getTag001();
        setupServiceFlowWizard.getTag002();
        setupServiceFlowWizard.getTag003();
        setupServiceFlowWizard.getTag004();
        setupServiceFlowWizard.getTag005();
        setupServiceFlowWizard.getTag006();
        setupServiceFlowWizard.getTag007();
        setupServiceFlowWizard.getTag008();
        setupServiceFlowWizard.getTag009();
        setupServiceFlowWizard.getTag010();
        setupServiceFlowWizard.getTag011();
        setupServiceFlowWizard.getTag012();
        setupServiceFlowWizard.getTag013();
        setupServiceFlowWizard.getTag014();
        setupServiceFlowWizard.getTag015();
        setupServiceFlowWizard.getTag016();
        setupServiceFlowWizard.getTag017();
        setupServiceFlowWizard.getTag018();
        setupServiceFlowWizard.getTag019();
        setupServiceFlowWizard.getTag020();
        setupServiceFlowWizard.getTag021();
        setupServiceFlowWizard.getTag022();
        setupServiceFlowWizard.getTag023();
        setupServiceFlowWizard.getTag024();
        setupServiceFlowWizard.getTag025();
        setupServiceFlowWizard.getTag026();
        setupServiceFlowWizard.getTag027();
        setupServiceFlowWizard.getTag027();
        setupServiceFlowWizard.getTag028();
        setupServiceFlowWizard.getTag029();
        setupServiceFlowWizard.getTag030();
        setupServiceFlowWizard.getTag031();
        setupServiceFlowWizard.getTag032();
        setupServiceFlowWizard.getTag033();
        setupServiceFlowWizard.getTag034();
        setupServiceFlowWizard.getTag035();
        setupServiceFlowWizard.getTag036();
        setupServiceFlowWizard.getTag037();
        setupServiceFlowWizard.getTag038();
        setupServiceFlowWizard.getTag039();
        setupServiceFlowWizard.getTag040();
        setupServiceFlowWizard.getTag041();
        setupServiceFlowWizard.getTag042();
        setupServiceFlowWizard.getTag043();
        setupServiceFlowWizard.getTag044();
        setupServiceFlowWizard.getTag045();
        setupServiceFlowWizard.getTag046();
        setupServiceFlowWizard.getTag047();
        setupServiceFlowWizard.getTag048();
        setupServiceFlowWizard.getTag049();
        setupServiceFlowWizard.getTag050();
        setupServiceFlowWizard.getTag051();
        setupServiceFlowWizard.getTag052();
        setupServiceFlowWizard.getTag055();
        setupServiceFlowWizard.getTag056();
        setupServiceFlowWizard.getTag058();
        setupServiceFlowWizard.getTag059();
        
        setupServiceFlowWizard.getTAG074();
        setupServiceFlowWizard.getTAG077();
        setupServiceFlowWizard.getTAG078();
        setupServiceFlowWizard.getTAG079();
        setupServiceFlowWizard.getTAG080();
        setupServiceFlowWizard.getTAG081();
        setupServiceFlowWizard.getTAG082();
        setupServiceFlowWizard.getTAG083();
        setupServiceFlowWizard.getTAG084();
        setupServiceFlowWizard.getTAG085();
        setupServiceFlowWizard.getTAG086();
        setupServiceFlowWizard.getTAG087();
        
        setupServiceFlowWizard.getTAG0001();
        setupServiceFlowWizard.getTAG0002();
        setupServiceFlowWizard.getTAG0003();
        setupServiceFlowWizard.getTAG0004();
        setupServiceFlowWizard.getTAG0005();
        setupServiceFlowWizard.getTAG0006();
        setupServiceFlowWizard.getTAG0007();
        setupServiceFlowWizard.getTAG0008();
        setupServiceFlowWizard.getTAG0009();
        setupServiceFlowWizard.getTAG0010();
        setupServiceFlowWizard.getTAG0011();
        setupServiceFlowWizard.getTAG0012();
        setupServiceFlowWizard.getTAG0013();
        setupServiceFlowWizard.getTAG0014();
        setupServiceFlowWizard.getTAG0015();
        setupServiceFlowWizard.getTAG0016();

        setupServiceFlowWizard.getselectedSequence();
        setupServiceFlowWizard.setselectedSequence('1.0');
        if(actnWrpr != null && actnWrpr.size() > 0)

        wrpr.SvmxActionRec.SVMXC__Action_Type__c = 'SFM';
        setupServiceFlowWizard.onChangeOfActionFieldPicklist();
        

        setupServiceFlowWizard.getDisableEditCriteriaLnk();

        setupServiceFlowWizard.getObjectsWithSFW();
        setupServiceFlowWizard.getObjectModeHeading();
        setupServiceFlowWizard.refreshShowHidecriteriaOptns();
        setupServiceFlowWizard.getdisableSourceObjField();
        setupServiceFlowWizard.getActnExpDetailSize();
        setupServiceFlowWizard.getdisableOnView();
        setupServiceFlowWizard.getTAG053();
        setupServiceFlowWizard.getTAG054();

        setupServiceFlowWizard.getHdrfldlist();
        setupServiceFlowWizard.getSelectedIndex();
        setupServiceFlowWizard.setSelectedIndex('1.0');
        setupServiceFlowWizard.getOperatorSelectLst();
        setupServiceFlowWizard.getExpDetailSize();
        setupServiceFlowWizard.HdrADDRow();
        setupServiceFlowWizard.AddException('');
        setupServiceFlowWizard.AddException('Error');
        setupServiceFlowWizard.IsValidString('');
        setupServiceFlowWizard.IsValidString('hello');
        setupServiceFlowWizard.HdrDeleteRow();
        setupServiceFlowWizard.ActnHdrDeleteRow();
        
        setupServiceFlowWizard.getObjLabel();
        setupServiceFlowWizard.ObjectName = 'SVMXC__Service_order__c';
        setupServiceFlowWizard.getObjLabel();
        setupServiceFlowWizard.ActnHdrADDRow();

        setupServiceFlowWizard.getTag088();
        setupServiceFlowWizard.getTag089();
        setupServiceFlowWizard.getTag090();
        setupServiceFlowWizard.getTAG057();
        setupServiceFlowWizard.getTAG091();
        setupServiceFlowWizard.getTAG092();
        setupServiceFlowWizard.getTAG093();
        setupServiceFlowWizard.getTAG094();
    }
    static testMethod void CONF_SetupServiceFlowWizard_UT_Test2()
    {
        RecordType ExpressionHeader_Rtype = [select Id from RecordType where Name=:'SVMX Rule'and SobjectType=:'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsDetail_Rtype = [select Id from RecordType where Name=:'Expressions'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c ExpressionHeaderRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionHeaderRec.SVMXC__Sequence__c = 1;
        ExpressionHeaderRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ExpressionHeaderRec.SVMXC__Name__c = 'HeaderExpression001';
        ExpressionHeaderRec.SVMXC__SettingId__c = 'HeaderExpression001';
        ExpressionHeaderRec.SVMXC__ProcessId__c = 'HeaderExpression001';
        ExpressionHeaderRec.SVMXC__Description__c = 'Sample desc';
        ExpressionHeaderRec.SVMXC__Advance_Expression__c = '1 or 2';
        ExpressionHeaderRec.RecordTypeId = ExpressionHeader_Rtype.Id;
        ExpressionHeaderRec.SVMXC__Rule_Type__c = 'Named Expression';
        insert ExpressionHeaderRec;
        system.assert(ExpressionHeaderRec.SVMXC__ProcessID__c!=null);
        system.assert(ExpressionHeaderRec.SVMXC__Name__c!=null);
        system.assert(ExpressionHeaderRec.SVMXC__Source_Object_Name__c!=null);
        system.assert(ExpressionHeaderRec.SVMXC__SettingId__c!=null);

        List<SVMXC__ServiceMax_Config_Data__c> expdetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c expDetails01 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails01.SVMXC__Sequence__c = 1;
        expDetails01.SVMXC__Field_Name__c ='SVMXC__City__c';
        expDetails01.SVMXC__Operator__c = 'eq';
        expDetails01.SVMXC__Operand__c = 'Bangalore';
        expDetails01.SVMXC__Display_Type__c = 'String';
        expDetails01.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails01.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails01);
        system.assert(expDetails01.SVMXC__Operator__c!=null);
        system.assert(expDetails01.SVMXC__Field_Name__c!=null);
        
        SVMXC__ServiceMax_Config_Data__c expDetails02 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails02.SVMXC__Sequence__c = 2;
        expDetails02.SVMXC__Field_Name__c ='SVMXC__City__c';
        expDetails02.SVMXC__Operator__c = 'eq';
        expDetails02.SVMXC__Operand__c = 'Bangalore';
        expDetails02.SVMXC__Display_Type__c = 'String';
        expDetails02.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails02.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails02);
        system.assert(expDetails02.SVMXC__Operator__c!=null);
        system.assert(expDetails02.SVMXC__Field_Name__c!=null);
        
        insert expdetailsLst;
        
        RecordType Rtype_ServiceFlowWizardHeader = [Select Id, Name from RecordType where Name = 'Wizard' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RtypeSVMX_ServiceFlowWizard_Action = [Select Id, Name from RecordType where Name = 'Wizard step' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType Rtype_SVMXServiceFlowWizardPermission = [Select Id, Name from RecordType where Name = 'Wizard Access' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ];
        RecordType Rtype_SVMXConfigProfile = [Select Id, Name from RecordType where Name = 'Configuration Profile' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ];

        SVMXC__ServiceMax_Processes__c ServiceFlowWizardRec = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardRec.SVMXC__Select__c = false;
        ServiceFlowWizardRec.SVMXC__ProcessID__c = 'MyServiceFlowWizard0001';
        ServiceFlowWizardRec.SVMXC__Name__c = 'MyServiceFlowWizard0001';
        ServiceFlowWizardRec.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ServiceFlowWizardRec.SVMXC__Submodule__c = ExpressionHeaderRec.Id;
        ServiceFlowWizardRec.SVMXC__IsStandard__c = false;
        ServiceFlowWizardRec.RecordTypeId = Rtype_ServiceFlowWizardHeader.Id;
        insert ServiceFlowWizardRec;
        
        
        SVMXC__ServiceMax_Config_Data__c SampleGroupProfile = new SVMXC__ServiceMax_Config_Data__c();
        SampleGroupProfile.SVMXC__PROFILE_NAME__C = 'SampleProfile0001';
        SampleGroupProfile.SVMXC__Description__C  = 'Sample Description';
        SampleGroupProfile.SVMXC__CONFIGURATION_TYPE__C = 'Group';
        SampleGroupProfile.RecordTypeId = Rtype_SVMXConfigProfile.Id;
        insert SampleGroupProfile;
        
        SVMXC__ServiceMax_Config_Data__c ServiceFlowWizardLayoutRec = new SVMXC__ServiceMax_Config_Data__c();
        ServiceFlowWizardLayoutRec.SVMXC__Dispatch_Process__c = ServiceFlowWizardRec.Id;
        ServiceFlowWizardLayoutRec.SVMXC__Access_Configuration_Profile__c = SampleGroupProfile.Id;
        ServiceFlowWizardLayoutRec.RecordTypeId = Rtype_SVMXServiceFlowWizardPermission.Id;
        insert ServiceFlowWizardLayoutRec;
        RecordType RType_SampleProcess = [SELECT Id, Name,SobjectType from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Target Manager'limit 1];
        SVMXC__ServiceMax_Processes__c SampleProcess = new SVMXC__ServiceMax_Processes__c();
        SampleProcess.RecordTypeId = RType_SampleProcess.Id;
        SampleProcess.SVMXC__ProcessID__c = 'Newprocess0002';
        SampleProcess.SVMXC__SettingID__c = 'Newprocess0002';
        insert SampleProcess;
        
        List<SVMXC__ServiceMax_Processes__c> lstPrcssObj = new List<SVMXC__ServiceMax_Processes__c> ();
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction.SVMXC__Select__c = false;
        ServiceFlowWizardAction.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction.SVMXC__Module__c = ServiceFlowWizardRec.Id; //ServiceFlowWizard defn lookup
        ServiceFlowWizardAction.SVMXC__Process__c = SampleProcess.Id;
        ServiceFlowWizardAction.SVMXC__Name__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__ProcessID__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__SettingID__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction.SVMXC__Action_Type__c = 'OTHERS';
        ServiceFlowWizardAction.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction.SVMXC__Submodule__c = ExpressionHeaderRec.Id; 
        ServiceFlowWizardAction.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction.RecordTypeId = RtypeSVMX_ServiceFlowWizard_Action.Id;
        lstPrcssObj.add(ServiceFlowWizardAction);
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction1 = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction1.SVMXC__Select__c = false;
        ServiceFlowWizardAction1.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction1.SVMXC__Module__c = ServiceFlowWizardRec.Id; //ServiceFlowWizard defn lookup
        ServiceFlowWizardAction1.SVMXC__Process__c = SampleProcess.Id;
        ServiceFlowWizardAction1.SVMXC__Name__c = 'ServiceFlowWizardAction1001';
        ServiceFlowWizardAction1.SVMXC__ProcessID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction1.SVMXC__SettingID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction1.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction1.SVMXC__Action_Type__c = 'SFM';
        ServiceFlowWizardAction1.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction1.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        ServiceFlowWizardAction1.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction1.RecordTypeId = RtypeSVMX_ServiceFlowWizard_Action.Id;
        lstPrcssObj.add(ServiceFlowWizardAction1);
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction12 = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction12.SVMXC__Select__c = false;
        ServiceFlowWizardAction12.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction12.SVMXC__Module__c = ServiceFlowWizardRec.Id; //ServiceFlowWizard defn lookup
        ServiceFlowWizardAction12.SVMXC__Process__c = SampleProcess.Id;
        ServiceFlowWizardAction12.SVMXC__Name__c = 'ServiceFlowWizardAction1001';
        ServiceFlowWizardAction12.SVMXC__ProcessID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction12.SVMXC__SettingID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction12.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction12.SVMXC__Action_Type__c = 'OUTPUTDOC';
        ServiceFlowWizardAction12.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction12.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        ServiceFlowWizardAction12.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction12.RecordTypeId = RtypeSVMX_ServiceFlowWizard_Action.Id;
        lstPrcssObj.add(ServiceFlowWizardAction12);
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction13 = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction13.SVMXC__Select__c = false;
        ServiceFlowWizardAction13.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction13.SVMXC__Module__c = ServiceFlowWizardRec.Id; //ServiceFlowWizard defn lookup
        ServiceFlowWizardAction13.SVMXC__Process__c = SampleProcess.Id;
        ServiceFlowWizardAction13.SVMXC__Name__c = 'ServiceFlowWizardAction1001';
        ServiceFlowWizardAction13.SVMXC__ProcessID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction13.SVMXC__SettingID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction13.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction13.SVMXC__Action_Type__c = 'INVENTORY';
        ServiceFlowWizardAction13.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction13.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        ServiceFlowWizardAction13.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction13.RecordTypeId = RtypeSVMX_ServiceFlowWizard_Action.Id;
        lstPrcssObj.add(ServiceFlowWizardAction13);
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction14 = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction14.SVMXC__Select__c = false;
        ServiceFlowWizardAction14.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction14.SVMXC__Module__c = ServiceFlowWizardRec.Id; //ServiceFlowWizard defn lookup
        ServiceFlowWizardAction14.SVMXC__Process__c = SampleProcess.Id;
        ServiceFlowWizardAction14.SVMXC__Name__c = 'ServiceFlowWizardAction1001';
        ServiceFlowWizardAction14.SVMXC__ProcessID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction14.SVMXC__SettingID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction14.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction14.SVMXC__Action_Type__c = 'BACKGROUND_EXEC';
        ServiceFlowWizardAction14.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction14.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        ServiceFlowWizardAction14.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction14.RecordTypeId = RtypeSVMX_ServiceFlowWizard_Action.Id;
        lstPrcssObj.add(ServiceFlowWizardAction14);
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction15 = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction15.SVMXC__Select__c = false;
        ServiceFlowWizardAction15.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction15.SVMXC__Module__c = ServiceFlowWizardRec.Id; //ServiceFlowWizard defn lookup
        ServiceFlowWizardAction15.SVMXC__Process__c = SampleProcess.Id;
        ServiceFlowWizardAction15.SVMXC__Name__c = 'ServiceFlowWizardAction1001';
        ServiceFlowWizardAction15.SVMXC__ProcessID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction15.SVMXC__SettingID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction15.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction15.SVMXC__Action_Type__c = 'INITIATE_RETURN';
        ServiceFlowWizardAction15.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction15.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        ServiceFlowWizardAction15.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction15.RecordTypeId = RtypeSVMX_ServiceFlowWizard_Action.Id;
        lstPrcssObj.add(ServiceFlowWizardAction15);
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction16 = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction16.SVMXC__Select__c = false;
        ServiceFlowWizardAction16.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction16.SVMXC__Module__c = ServiceFlowWizardRec.Id; //ServiceFlowWizard defn lookup
        ServiceFlowWizardAction16.SVMXC__Process__c = SampleProcess.Id;
        ServiceFlowWizardAction16.SVMXC__Name__c = 'ServiceFlowWizardAction1001';
        ServiceFlowWizardAction16.SVMXC__ProcessID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction16.SVMXC__SettingID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction16.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction16.SVMXC__Action_Type__c = 'FULFILLMENT';
        ServiceFlowWizardAction16.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction16.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        ServiceFlowWizardAction16.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction16.RecordTypeId = RtypeSVMX_ServiceFlowWizard_Action.Id;
        lstPrcssObj.add(ServiceFlowWizardAction16);
        insert lstPrcssObj;

        System.currentPageReference().getParameters().put('SVMX_RecordId',ServiceFlowWizardRec.Id);
        System.currentPageReference().getParameters().put('SVMX_Action','Edit');
        System.currentPageReference().getParameters().put('SVMX_ObjectName','SVMXC__Service_Order__c');
        CONF_SetupServiceFlowWizard setupServiceFlowWizard = new CONF_SetupServiceFlowWizard();
        CONF_SetupServiceFlowWizard.ExpressionWrapper expHdrDtl = new CONF_SetupServiceFlowWizard.ExpressionWrapper(ExpressionHeaderRec,expdetailsLst,true,true);
        expHdrDtl.getExpHeader();
        expHdrDtl.setExpHeader(new SVMXC__ServiceMax_Processes__c());
        expHdrDtl.getExpDetailLst();
        expHdrDtl.setExpDetailLst(new List<SVMXC__ServiceMax_Config_Data__c>());
        expHdrDtl.getRenderAddButton();
        expHdrDtl.setRenderAddButton(true);
        expHdrDtl.getRenderDelButton();
        expHdrDtl.setRenderDelButton(true);

        SVMXC.CONF_SetupServiceFlowWizard.SvmxActionWrapper wrpr = new CONF_SetupServiceFlowWizard.SvmxActionWrapper(new SVMXC__ServiceMax_Processes__c(),null,null, null, null,'');
        wrpr.getSvmxActionRec();
        wrpr.setSvmxActionRec(new SVMXC__ServiceMax_Processes__c());
        List<SelectOption> LstStepType = wrpr.getslctLstStepType();
        wrpr.getSelectedActionType();
        wrpr.setSelectedActionType('SFM');
        wrpr.getSelectedCriteriaToEnable();
        wrpr.setSelectedCriteriaToEnable(null);
        wrpr.setexpHeaderDetailRec(expHdrDtl);
        wrpr.getexpHeaderDetailRec();
        String str = setupServiceFlowWizard.getSVMXRecId();
        str = setupServiceFlowWizard.getObjectName();
        str = setupServiceFlowWizard.getMode();
        boolean b;
       // b = setupServiceFlowWizard.getHeaderSaveNClose();
        b = setupServiceFlowWizard.getDisableActnNew();
        //b = setupServiceFlowWizard.getDisableActnEdit();
        //b = setupServiceFlowWizard.getDisableActnSave();
        b = setupServiceFlowWizard.getDisableActnDelete();
        b = setupServiceFlowWizard.getDisableActnSequence();
        //b = setupServiceFlowWizard.getDisableActnCancel();
        SVMXC__ServiceMax_Processes__c c = new SVMXC__ServiceMax_Processes__c();
        setupServiceFlowWizard.geteditActionWrapperObject();
        setupServiceFlowWizard.seteditActionWrapperObject(wrpr);
        List<CONF_SetupServiceFlowWizard.SvmxActionWrapper> actnWrpr = setupServiceFlowWizard.getSvmxActionWrapperLst();
        setupServiceFlowWizard.setSvmxActionWrapperLst(actnWrpr);
        b = setupServiceFlowWizard.getDisplayComponent();
        setupServiceFlowWizard.OnChangeOfShowNHideCriteria();
        str = setupServiceFlowWizard.getPageBlockTitle();
        str = setupServiceFlowWizard.getselectedTab();
        setupServiceFlowWizard.setselectedTab(str);
        str = setupServiceFlowWizard.getSelectedcriteria();
        setupServiceFlowWizard.setSelectedcriteria(str);
        str = setupServiceFlowWizard.getselectedSvmxSFW();
        setupServiceFlowWizard.setselectedSvmxSFW(str);
        List<SelectOption> slctOptn = setupServiceFlowWizard.getAvailableSvmxSFWs();
        List<String> lstStr = new List<String>();
        lstStr.add(SampleGroupProfile.Id);
        setupServiceFlowWizard.setavailableProfilesSelctd(lstStr);
        setupServiceFlowWizard.getavailableProfilesSelctd();
        slctOptn = setupServiceFlowWizard.getAvailableSvmxGrpProfiles();
        lstStr = setupServiceFlowWizard.getselectedProfilesSelctd();
        lstStr.add(SampleGroupProfile.Id);
        setupServiceFlowWizard.setselectedProfilesSelctd(lstStr);
        slctOptn = setupServiceFlowWizard.getSelectedSvmxGrpProfiles();
        c = setupServiceFlowWizard.getSFWRec();
        setupServiceFlowWizard.setSFWRec(c);
        slctOptn = setupServiceFlowWizard.getShowHidecriteriaOptns();
        List<SVMXC__ServiceMax_Processes__c> TActionsLst = setupServiceFlowWizard.getSFWActionsLst();
        SVMXC__ServiceMax_Processes__c[] arayProcess = setupServiceFlowWizard.getSFWActionsSEQLst();
        setupServiceFlowWizard.setSFWActionsLst(TActionsLst);
        setupServiceFlowWizard.onAddProfile();
        setupServiceFlowWizard.onRemProfile();
        pageReference pagRef = setupServiceFlowWizard.gotoGeneralInfoTab();
        pagRef = setupServiceFlowWizard.gotoManageActionsTab();
        pagRef = setupServiceFlowWizard.gotoManagePermissionsTab();
        b = setupServiceFlowWizard.getNewActionRecCreationMode();
        b = setupServiceFlowWizard.getDisableActionRecSave();
        pagRef = setupServiceFlowWizard.NewAction();
        pagRef = setupServiceFlowWizard.EditAction();
        setupServiceFlowWizard.rerenderAvailableSFWs();
    /*  str = 'ServiceMax_None';
        setupServiceFlowWizard.rerenderAvailableSFWs(); */
        b = setupServiceFlowWizard.getIsbuttonsDisabled();
        str = setupServiceFlowWizard.getSelectedCriteriaToenable();
        setupServiceFlowWizard.setSelectedCriteriaToenable(str);
        slctOptn = setupServiceFlowWizard.getCriteriaToEnableOptns();
        b = setupServiceFlowWizard.getDisableCriToEnableEditLink();
        setupServiceFlowWizard.onChangeOfActionFieldPicklist();
        setupServiceFlowWizard.onChangeOfActionPicklist();
        pagRef = setupServiceFlowWizard.DeleteAction();
        b = setupServiceFlowWizard.getRenderSeqBlock();
        setupServiceFlowWizard.SequenceActions();
        //setupServiceFlowWizard.cancelAction();
        pagRef = setupServiceFlowWizard.SaveAction();
        b = setupServiceFlowWizard.ValidationsOnSave();
        setupServiceFlowWizard.disableOnView = true;
        pagRef = setupServiceFlowWizard.QuickSave();
        setupServiceFlowWizard.disableOnView = false;
        pagRef = setupServiceFlowWizard.QuickSave();
        setupServiceFlowWizard.QuickSaveSuccessful = true;
        pagRef = setupServiceFlowWizard.SaveNClose();
        c = setupServiceFlowWizard.getSelectedexpHeader();
        SVMXC__ServiceMax_Config_Data__c[] arayConfigData = setupServiceFlowWizard.getexpdtlLst();
        setupServiceFlowWizard.OnchangeOfcriteriaPicklist();
        setupServiceFlowWizard.OnClickOfEditCriteria();
        pagRef = setupServiceFlowWizard.HeaderCancel();
        pagRef = setupServiceFlowWizard.ChangeActnExprCriteria();
        setupServiceFlowWizard.getselectedCriteriaActn();
        setupServiceFlowWizard.setselectedCriteriaActn('');
        //actnWrpr[0].SvmxActionRec.SVMXC__Select__c = true;
        setupServiceFlowWizard.DeleteAction();
        setupServiceFlowWizard.getcomponentMode();
        setupServiceFlowWizard.setcomponentMode('Edit');
        
        setupServiceFlowWizard.setselectedCriteriaActn('None');
        setupServiceFlowWizard.SelectedCriteriaToEnable = ExpressionHeaderRec.Id;
        setupServiceFlowWizard.EditActionCriteria();
        setupServiceFlowWizard.setselectedCriteriaActn('Edit');
        setupServiceFlowWizard.EditActionCriteria();
        /* setupServiceFlowWizard.Mode = 'Clone';
        setupServiceFlowWizard.DoQuickSaveIncloneMode(); */
        
        setupServiceFlowWizard.setexpwrapperObj(new CONF_SetupServiceFlowWizard.ExpressionWrapper(new SVMXC__ServiceMax_Processes__c(),new List<SVMXC__ServiceMax_Config_Data__c>(),true,false));
        setupServiceFlowWizard.getexpwrapperObj();
        setupServiceFlowWizard.setactnexpwrapperObj(new CONF_SetupServiceFlowWizard.ExpressionWrapper(new SVMXC__ServiceMax_Processes__c(),new List<SVMXC__ServiceMax_Config_Data__c>(),true,false));
        setupServiceFlowWizard.getactnexpwrapperObj();
        setupServiceFlowWizard.isChkSelecTempltRunTime();
        setupServiceFlowWizard.SaveWizardStep();
        setupServiceFlowWizard.getCountSteps();
        setupServiceFlowWizard.preDeleteAction();
        
        setupServiceFlowWizard.cancleCreateNewEditStep();
        setupServiceFlowWizard.NewActionRecCreationMode = true;
        setupServiceFlowWizard.NewWizardStepSave();
        setupServiceFlowWizard.NewActionRecCreationMode = false;
        setupServiceFlowWizard.NewWizardStepSave();
        setupServiceFlowWizard.DoQuickSaveIncloneMode();
        
        if(setupServiceFlowWizard.SvmxActionWrapperLst != null && setupServiceFlowWizard.SvmxActionWrapperLst.size() > 0)
        {
            setupServiceFlowWizard.editActionWrapperObject = setupServiceFlowWizard.SvmxActionWrapperLst[0].clone();
            setupServiceFlowWizard.editActionWrapperObject.displayEditButton = setupServiceFlowWizard.SvmxActionWrapperLst[0].displayEditButton;
            setupServiceFlowWizard.editActionWrapperObject.SvmxActionRec = setupServiceFlowWizard.SvmxActionWrapperLst[0].SvmxActionRec.clone(true, true, false, true);
            
        }
        /*setupServiceFlowWizard.NewActionRecCreationMode = true;
        setupServiceFlowWizard.NewWizardStepSave();
        setupServiceFlowWizard.NewActionRecCreationMode = false;
        setupServiceFlowWizard.NewWizardStepSave();
        
        setupServiceFlowWizard.createNewCriteria();
        */
        
    }
    static testMethod void CONF_SetupServiceFlowWizard_UT_Test3()
    {
        RecordType ExpressionHeader_Rtype = [select Id from RecordType where Name=:'SVMX Rule'and SobjectType=:'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType ExpressionsDetail_Rtype = [select Id from RecordType where Name=:'Expressions'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c ExpressionHeaderRec = new SVMXC__ServiceMax_Processes__c();
        ExpressionHeaderRec.SVMXC__Sequence__c = 1;
        ExpressionHeaderRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ExpressionHeaderRec.SVMXC__Name__c = 'HeaderExpression001';
        ExpressionHeaderRec.SVMXC__SettingId__c = 'HeaderExpression001';
        ExpressionHeaderRec.SVMXC__ProcessId__c = 'HeaderExpression001';
        ExpressionHeaderRec.SVMXC__Description__c = 'Sample desc';
        ExpressionHeaderRec.SVMXC__Advance_Expression__c = '1 or 2';
        ExpressionHeaderRec.RecordTypeId = ExpressionHeader_Rtype.Id;
        ExpressionHeaderRec.SVMXC__Rule_Type__c = 'Named Expression';
        insert ExpressionHeaderRec;
        system.assert(ExpressionHeaderRec.SVMXC__ProcessID__c!=null);
        system.assert(ExpressionHeaderRec.SVMXC__Name__c!=null);
        system.assert(ExpressionHeaderRec.SVMXC__Source_Object_Name__c!=null);
        system.assert(ExpressionHeaderRec.SVMXC__SettingId__c!=null);

        List<SVMXC__ServiceMax_Config_Data__c> expdetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c expDetails01 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails01.SVMXC__Sequence__c = 1;
        expDetails01.SVMXC__Field_Name__c ='SVMXC__City__c';
        expDetails01.SVMXC__Operator__c = 'eq';
        expDetails01.SVMXC__Operand__c = 'Bangalore';
        expDetails01.SVMXC__Display_Type__c = 'String';
        expDetails01.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails01.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails01);
        system.assert(expDetails01.SVMXC__Operator__c!=null);
        system.assert(expDetails01.SVMXC__Field_Name__c!=null);
        
        SVMXC__ServiceMax_Config_Data__c expDetails02 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails02.SVMXC__Sequence__c = 2;
        expDetails02.SVMXC__Field_Name__c ='SVMXC__City__c';
        expDetails02.SVMXC__Operator__c = 'eq';
        expDetails02.SVMXC__Operand__c = 'Bangalore';
        expDetails02.SVMXC__Display_Type__c = 'String';
        expDetails02.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails02.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails02);
        system.assert(expDetails02.SVMXC__Operator__c!=null);
        system.assert(expDetails02.SVMXC__Field_Name__c!=null);
        
        insert expdetailsLst;
        
        RecordType Rtype_ServiceFlowWizardHeader = [Select Id, Name from RecordType where Name = 'Wizard' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RtypeSVMX_ServiceFlowWizard_Action = [Select Id, Name from RecordType where Name = 'Wizard step' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType Rtype_SVMXServiceFlowWizardPermission = [Select Id, Name from RecordType where Name = 'Wizard Access' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ];
        RecordType Rtype_SVMXConfigProfile = [Select Id, Name from RecordType where Name = 'Configuration Profile' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ];

        SVMXC__ServiceMax_Processes__c ServiceFlowWizardRec = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardRec.SVMXC__Select__c = false;
        ServiceFlowWizardRec.SVMXC__ProcessID__c = 'MyServiceFlowWizard0001';
        ServiceFlowWizardRec.SVMXC__Name__c = 'MyServiceFlowWizard0001';
        ServiceFlowWizardRec.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardRec.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        ServiceFlowWizardRec.SVMXC__Submodule__c = ExpressionHeaderRec.Id;
        ServiceFlowWizardRec.SVMXC__IsStandard__c = false;
        ServiceFlowWizardRec.RecordTypeId = Rtype_ServiceFlowWizardHeader.Id;
        insert ServiceFlowWizardRec;
        
        
        SVMXC__ServiceMax_Config_Data__c SampleGroupProfile = new SVMXC__ServiceMax_Config_Data__c();
        SampleGroupProfile.SVMXC__PROFILE_NAME__C = 'SampleProfile0001';
        SampleGroupProfile.SVMXC__Description__C  = 'Sample Description';
        SampleGroupProfile.SVMXC__CONFIGURATION_TYPE__C = 'Group';
        SampleGroupProfile.RecordTypeId = Rtype_SVMXConfigProfile.Id;
        insert SampleGroupProfile;
        
        SVMXC__ServiceMax_Config_Data__c ServiceFlowWizardLayoutRec = new SVMXC__ServiceMax_Config_Data__c();
        ServiceFlowWizardLayoutRec.SVMXC__Dispatch_Process__c = ServiceFlowWizardRec.Id;
        ServiceFlowWizardLayoutRec.SVMXC__Access_Configuration_Profile__c = SampleGroupProfile.Id;
        ServiceFlowWizardLayoutRec.RecordTypeId = Rtype_SVMXServiceFlowWizardPermission.Id;
        insert ServiceFlowWizardLayoutRec;
        RecordType RType_SampleProcess = [SELECT Id, Name,SobjectType from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Target Manager'limit 1];
        SVMXC__ServiceMax_Processes__c SampleProcess = new SVMXC__ServiceMax_Processes__c();
        SampleProcess.RecordTypeId = RType_SampleProcess.Id;
        SampleProcess.SVMXC__ProcessID__c = 'Newprocess0002';
        SampleProcess.SVMXC__SettingID__c = 'Newprocess0002';
        insert SampleProcess;
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction.SVMXC__Select__c = false;
        ServiceFlowWizardAction.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction.SVMXC__Module__c = ServiceFlowWizardRec.Id; //ServiceFlowWizard defn lookup
        ServiceFlowWizardAction.SVMXC__Process__c = SampleProcess.Id;
        ServiceFlowWizardAction.SVMXC__Name__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__ProcessID__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__SettingID__c = 'ServiceFlowWizardAction001';
        ServiceFlowWizardAction.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction.SVMXC__Action_Type__c = 'OTHERS';
        ServiceFlowWizardAction.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction.SVMXC__Submodule__c = ExpressionHeaderRec.Id; 
        ServiceFlowWizardAction.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction.RecordTypeId = RtypeSVMX_ServiceFlowWizard_Action.Id;
        insert ServiceFlowWizardAction;
        
        SVMXC__ServiceMax_Processes__c ServiceFlowWizardAction1 = new SVMXC__ServiceMax_Processes__c();
        ServiceFlowWizardAction1.SVMXC__Select__c = false;
        ServiceFlowWizardAction1.SVMXC__Sequence__c = 1 ;
        ServiceFlowWizardAction1.SVMXC__Module__c = ServiceFlowWizardRec.Id; //ServiceFlowWizard defn lookup
        ServiceFlowWizardAction1.SVMXC__Process__c = SampleProcess.Id;
        ServiceFlowWizardAction1.SVMXC__Name__c = 'ServiceFlowWizardAction1001';
        ServiceFlowWizardAction1.SVMXC__ProcessID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction1.SVMXC__SettingID__c = 'ServiceFlowWizardAction002';
        ServiceFlowWizardAction1.SVMXC__Description__c = 'Sample Description';
        ServiceFlowWizardAction1.SVMXC__Action_Type__c = 'OTHERS';
        ServiceFlowWizardAction1.SVMXC__Action_URL__c = 'New url';
        ServiceFlowWizardAction1.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        ServiceFlowWizardAction1.SVMXC__IsStandard__c = false;
        ServiceFlowWizardAction1.RecordTypeId = RtypeSVMX_ServiceFlowWizard_Action.Id;
        insert ServiceFlowWizardAction1;
        
        
    }
    
    static testMethod void CONF_SetupServiceFlowWizard_UT_Test4(){
        System.currentPageReference().getParameters().put('SVMX_ObjectName','Case');
        CONF_SetupServiceFlowWizard setupServiceFlowWizard = new CONF_SetupServiceFlowWizard();
        SVMXC.CONF_SetupServiceFlowWizard.SvmxActionWrapper wrpr1 = new CONF_SetupServiceFlowWizard.SvmxActionWrapper(new SVMXC__ServiceMax_Processes__c(),'ServiceMax_None','ServiceMax_None', null, '','CHECKLIST');
      setupServiceFlowWizard.renderActionPicklistvalues();

        SVMXC__ServiceMax_Processes__c newProcess = new SVMXC__ServiceMax_Processes__c();
        newProcess.Select_Template_At_Runtime__c = true;
        newProcess.Name__c = 'Checklist Name';
        newProcess.SVMXC__Name__c = 'Name_Test';
        newProcess.SVMXC__ProcessID__c = 'Name_Test';
        newProcess.Action_Type__c = 'CHECKLIST';
        newProcess.Select__c = true;
        newProcess.SVMXC__Source_Object_Name__c = 'Case';
        Id exprId = createExpressionProcess();
        newProcess.SVMXC__SubModule__c = exprId;        
        setupServiceFlowWizard.SFWRec = newProcess;

        
        setupServiceFlowWizard.ObjectName = 'SVMXC__Service_Order__c';

        setupServiceFlowWizard.selectedCriteria = String.valueof(exprId);
        setupServiceFlowWizard.OnClickOfEditCriteria();
        CONF_SetupServiceFlowWizard.SvmxActionWrapper wrap = new CONF_SetupServiceFlowWizard.SvmxActionWrapper(newProcess,'CHECKLIST','CHECKLIST',null,'','CHECKLIST');
        wrap.stepID = 'New_Checklist';
        wrap.isActnTypChecklist = false;
        wrap.SvmxActionRec = newProcess;
        setupServiceFlowWizard.SvmxActionWrapperLst.add(wrap);
        setupServiceFlowWizard.editActionWrapperObject = wrap;
        setupServiceFlowWizard.NewWizardStepSave();
        setupServiceFlowWizard.EditAction();
        setupServiceFlowWizard.onChangeOfActionFieldPicklist();
        setupServiceFlowWizard.onChangeOfActionPicklist();
        setupServiceFlowWizard.createNewCriteria();
        setupServiceFlowWizard.SelectedCriteriaToEnable = String.valueof(exprId);
        setupServiceFlowWizard.EditActionCriteria();
}
    
    public static Id createExpressionProcess(){
        SVMXC__ServiceMax_Processes__c expressionProcess = new SVMXC__ServiceMax_Processes__c();
        expressionProcess.RecordType = recordTypeIdMap.get('SVMX_Rule');
        expressionProcess.SVMXC__Name__c = 'Test Rule Expression';
        expressionProcess.SVMXC__ProcessID__c = 'Test_Rule_Expression_for_CheckList';
        expressionProcess.SVMXC__Rule_Type__c = 'Named Expression';
        expressionProcess.SVMXC__Source_Object_Name__c = 'Case';
        expressionProcess.SVMXC__Parent_Error_Msg__c = 'This record does not meet the qualification criteria for this SFM Transaction';
        expressionProcess.SVMXC__Parent_Object_Criteria__c = 'Status<> \'Closed\'' ;
        expressionProcess.SVMXC__SettingID__c = 'Test_Rule_Expression_for_CheckList';
        expressionProcess.SVMXC__MapID__c = 'Test_Rule_Expression_for_Checklist';
        insert expressionProcess;
        
        SVMXC__ServiceMax_Config_Data__c expressionConfig = new SVMXC__ServiceMax_Config_Data__c();
        expressionConfig.RecordType = recordTypeIdMap.get('Expressions');
        expressionConfig.SVMXC__Field_Name__c = 'Status';
    expressionConfig.SVMXC__Display_Type__c = 'PICKLIST';
        expressionConfig.SVMXC__Expression_Type__c = 'EXP_Named';
        expressionConfig.SVMXC__Ownership_Type__c = 'All Records';
        expressionConfig.SVMXC__Operand__c = 'Closed';
        expressionConfig.SVMXC__Operator__c = 'ne';
        expressionConfig.SVMXC__Sort_Order__c = 'Ascending';
        expressionConfig.SVMXC__Expression_Rule__c = expressionProcess.Id;
        insert expressionConfig;
        return expressionProcess.Id;
    }    

    public static void getRecordTypeIds(){
        for(RecordType rec : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType IN ('SVMXC__ServiceMax_Processes__c','SVMXC__ServiceMax_Config_Data__c') AND isActive = true]){
           recordTypeIdMap.put(rec.DeveloperName, rec); 
        }
    }    
}