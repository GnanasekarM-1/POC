@isTest
Private  with sharing class INTF_GetServiceFlowWizard_UT {

static testmethod void INTF_GetServiceFlowWizard_UnitTest(){

        RecordType Rtype_SFWHeader = [Select Id, Name from RecordType where Name = 'Wizard' and SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType RtypeSVMX_SFW_Action = [Select Id, Name from RecordType where Name = 'Wizard Step' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1];
        RecordType Rtype_SVMXSFWPermission = [Select Id, Name from RecordType where Name = 'Wizard Access' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ];
        RecordType Rtype_SVMXConfigProfile = [Select Id, Name from RecordType where Name = 'Configuration Profile' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1 ];
        
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
        

        List<SVMXC__ServiceMax_Config_Data__c> expdetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c expDetails01 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails01.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails01.SVMXC__Sequence__c = 1;
        expDetails01.SVMXC__Field_Name__c ='Name';
        expDetails01.SVMXC__Operator__c = 'eq';
        expDetails01.SVMXC__Operand__c = 'Acc';
        expDetails01.SVMXC__Display_Type__c = 'String';
        expDetails01.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails01.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails01);
        system.assert(expDetails01.SVMXC__Field_Name__c!=null);
        system.assert(expDetails01.SVMXC__Operand__c!=null);
        
        SVMXC__ServiceMax_Config_Data__c expDetails02 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails02.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails02.SVMXC__Sequence__c = 2;
        expDetails02.SVMXC__Field_Name__c ='Name';
        expDetails02.SVMXC__Operator__c = 'eq';
        expDetails02.SVMXC__Operand__c = 'Acc';
        expDetails02.SVMXC__Display_Type__c = 'String';
        expDetails02.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails02.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails02);
       
        system.assert(expDetails02.SVMXC__Field_Name__c!=null);
        system.assert(expDetails02.SVMXC__Operand__c!=null);
        
        //Defect fix 43293 : Equal and not equal operator for Text and Picklist field
        SVMXC__ServiceMax_Config_Data__c expDetails03 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails03.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails03.SVMXC__Sequence__c = 3;
        expDetails03.SVMXC__Field_Name__c ='Name';
        expDetails03.SVMXC__Operator__c = 'ne';
        expDetails03.SVMXC__Operand__c = 'Acc1';
        expDetails03.SVMXC__Display_Type__c = 'String';
        expDetails03.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails03.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails03);
        
        system.assert(expDetails03.SVMXC__Field_Name__c!=null);
        system.assert(expDetails03.SVMXC__Operand__c!=null);
    
        SVMXC__ServiceMax_Config_Data__c expDetails04 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails04.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails04.SVMXC__Sequence__c = 4;
        expDetails04.SVMXC__Field_Name__c ='Name';
        expDetails04.SVMXC__Operator__c = 'ne';
        expDetails04.SVMXC__Operand__c = 'Acc';
        expDetails04.SVMXC__Display_Type__c = 'String';
        expDetails04.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails04.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails04);
        
                //Changes added by nidhi to cover DateTime field LAST_N_DAYS: criteria
        SVMXC__ServiceMax_Config_Data__c expDetails05 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails05.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails05.SVMXC__Sequence__c = 5;
        expDetails05.SVMXC__Field_Name__c ='createddate';
        expDetails05.SVMXC__Operator__c = 'eq';
        expDetails05.SVMXC__Operand__c = 'LAST_N_DAYS:7';
        expDetails05.SVMXC__Display_Type__c = 'datetime';
        expDetails05.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails05.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails05);
        
        SVMXC__ServiceMax_Config_Data__c expDetails06 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails06.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails06.SVMXC__Sequence__c = 6;
        expDetails06.SVMXC__Field_Name__c ='createddate';
        expDetails06.SVMXC__Operator__c = 'LE';
        expDetails06.SVMXC__Operand__c = 'LAST_N_DAYS:7';
        expDetails06.SVMXC__Display_Type__c = 'datetime';
        expDetails06.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails06.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails06);
        
        SVMXC__ServiceMax_Config_Data__c expDetails07 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails07.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails07.SVMXC__Sequence__c = 7;
        expDetails07.SVMXC__Field_Name__c ='createddate';
        expDetails07.SVMXC__Operator__c = 'NE';
        expDetails07.SVMXC__Operand__c = 'LAST_N_DAYS:7';
        expDetails07.SVMXC__Display_Type__c = 'datetime';
        expDetails07.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails07.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails07);
        
        
        //Changes added by nidhi to cover DateTime field NEXT_N_DAYS: criteria
        SVMXC__ServiceMax_Config_Data__c expDetails08 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails08.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails08.SVMXC__Sequence__c = 8;
        expDetails08.SVMXC__Field_Name__c ='createddate';
        expDetails08.SVMXC__Operator__c = 'eq';
        expDetails08.SVMXC__Operand__c = 'NEXT_N_DAYS:7';
        expDetails08.SVMXC__Display_Type__c = 'datetime';
        expDetails08.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails08.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails08);
        
        SVMXC__ServiceMax_Config_Data__c expDetails09 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails09.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails09.SVMXC__Sequence__c = 9;
        expDetails09.SVMXC__Field_Name__c ='createddate';
        expDetails09.SVMXC__Operator__c = 'LE';
        expDetails09.SVMXC__Operand__c = 'NEXT_N_DAYS:7';
        expDetails09.SVMXC__Display_Type__c = 'datetime';
        expDetails09.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails09.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails09);
        
        SVMXC__ServiceMax_Config_Data__c expDetails10 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails10.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails10.SVMXC__Sequence__c = 10;
        expDetails10.SVMXC__Field_Name__c ='createddate';
        expDetails10.SVMXC__Operator__c = 'NE';
        expDetails10.SVMXC__Operand__c = 'NEXT_N_DAYS:7';
        expDetails10.SVMXC__Display_Type__c = 'datetime';
        expDetails10.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails10.SVMXC__Expression_Rule__c = ExpressionHeaderRec.Id;
        expdetailsLst.add(expDetails10);
           
        insert expdetailsLst;
        
        system.assert(expDetails04.SVMXC__Field_Name__c!=null);
        system.assert(expDetails04.SVMXC__Operand__c!=null);
        
        
        MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
        Schema.SObjectType objT = allObjs.get('Account');

        SVMXC__ServiceMax_Processes__c SFWRec = new SVMXC__ServiceMax_Processes__c();
        SFWRec.SVMXC__Select__c = false;
        SFWRec.SVMXC__ProcessID__c = 'MySFW0001';
        SFWRec.SVMXC__Name__c = 'MySFW0001';
        SFWRec.SVMXC__Description__c = 'Sample Description';
        SFWRec.SVMXC__Source_Object_Name__c = 'Account';
        SFWRec.SVMXC__Submodule__c = ExpressionHeaderRec.Id;
        SFWRec.SVMXC__IsStandard__c = true;
        SFWRec.RecordTypeId = Rtype_SFWHeader.Id;
        SFWRec.SVMXC__Active__c = true;
        SFWRec.SVMXC__Object_key_prefix__c = objT.getDescribe().getkeyPrefix();
        insert SFWRec;
        system.assert(SFWRec.SVMXC__ProcessID__c!=null);
        system.assert(SFWRec.SVMXC__Name__c!=null);

        SVMXC__ServiceMax_Config_Data__c SampleGroupProfile = new SVMXC__ServiceMax_Config_Data__c();
        SampleGroupProfile.SVMXC__PROFILE_NAME__C = 'SampleProfile0001';
        SampleGroupProfile.SVMXC__Description__C  = 'Sample Description';
        SampleGroupProfile.SVMXC__CONFIGURATION_TYPE__C = 'Group';
        SampleGroupProfile.RecordTypeId = Rtype_SVMXConfigProfile.Id;
        insert SampleGroupProfile;
        
        /*SVMXC__ServiceMax_Config_Data__c SFWLayoutRec = new SVMXC__ServiceMax_Config_Data__c();
        SFWLayoutRec.SVMXC__Dispatch_Process__c = SFWRec.Id;
        SFWLayoutRec.SVMXC__Access_Configuration_Profile__c = SampleGroupProfile.Id;
        SFWLayoutRec.RecordTypeId = Rtype_SVMXSFWPermission.Id;
        insert SFWLayoutRec;*/
        RecordType RType_SampleProcess = [SELECT Id, Name,SobjectType from RecordType  where SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Target Manager'limit 1];
        SVMXC__ServiceMax_Processes__c SampleProcess = new SVMXC__ServiceMax_Processes__c();
        SampleProcess.RecordTypeId = RType_SampleProcess.Id;
        SampleProcess.SVMXC__ProcessID__c = 'Newprocess0002';
        SampleProcess.SVMXC__SettingID__c = 'Newprocess0002';
        insert SampleProcess;
        
        SVMXC__ServiceMax_Processes__c SFWAction = new SVMXC__ServiceMax_Processes__c();
        SFWAction.SVMXC__Select__c = false;
        SFWAction.SVMXC__Sequence__c = 1 ;
        SFWAction.SVMXC__Module__c = SFWRec.Id; //SFW defn lookup
        SFWAction.SVMXC__Process__c = SampleProcess.Id;
        SFWAction.SVMXC__Name__c = 'SFWAction001';
        SFWAction.SVMXC__ProcessID__c = 'SFWAction001';
        SFWAction.SVMXC__SettingID__c = 'SFWAction001';
        SFWAction.SVMXC__Description__c = 'Sample Description';
        SFWAction.SVMXC__Action_Type__c = 'OTHERS';
        SFWAction.SVMXC__Action_URL__c = 'New url';
        SFWAction.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        SFWAction.SVMXC__IsStandard__c = false;
        SFWAction.RecordTypeId = RtypeSVMX_SFW_Action.Id;
        insert SFWAction;
        
        SVMXC__ServiceMax_Processes__c SFWAction1 = new SVMXC__ServiceMax_Processes__c();
        SFWAction1.SVMXC__Select__c = true;
        SFWAction1.SVMXC__Sequence__c = 1 ;
        SFWAction1.SVMXC__Module__c = SFWRec.Id; //SFW defn lookup
        SFWAction1.SVMXC__Process__c = SampleProcess.Id;
        SFWAction1.SVMXC__Name__c = 'SFWAction1001';
        SFWAction1.SVMXC__ProcessID__c = 'SFWAction002';
        SFWAction1.SVMXC__SettingID__c = 'SFWAction002';
        SFWAction1.SVMXC__Description__c = 'Sample Description';
        SFWAction1.SVMXC__Action_Type__c = 'OTHERS';
        SFWAction1.SVMXC__Action_URL__c = 'New url';
        SFWAction1.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        SFWAction1.SVMXC__IsStandard__c = false;
        SFWAction1.RecordTypeId = RtypeSVMX_SFW_Action.Id;
        insert SFWAction1;
        
        RecordType Action_Rtype = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Processes__c' and Name = 'SF Action' Limit 1];

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
        process.RecordTypeId = Action_Rtype.Id;
        insert process;
        
        RecordType Parameter_RType = [Select Id, SobjectType, Name From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' and Name = 'SF Action Parameter'];
        
        List<SVMXC__ServiceMax_Config_Data__c> configLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c config = new SVMXC__ServiceMax_Config_Data__c();
        config.SVMXC__Parameter_Name__c = 'actionParam001';
        config.SVMXC__Parameter_Type__c = 'Field Name';
        config.SVMXC__Parameter_Value__c = 'Name';
        config.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        config.SVMXC__Select__c = true;
        config.SVMXC__Dispatch_Process__c = process.id;
        config.RecordTypeId = Parameter_RType.Id;
        SVMXC__ServiceMax_Config_Data__c config1 = new SVMXC__ServiceMax_Config_Data__c();
        config1.SVMXC__Parameter_Name__c = 'actionParam001';
        config1.SVMXC__Parameter_Type__c = 'value';
        config1.SVMXC__Parameter_Value__c = 'new001';
        config1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        config1.SVMXC__Select__c = true;
        config1.SVMXC__Dispatch_Process__c = process.id;
        config1.RecordTypeId = Parameter_RType.Id;
        SVMXC__ServiceMax_Config_Data__c config2 = new SVMXC__ServiceMax_Config_Data__c();
        config2.SVMXC__Parameter_Name__c = 'actionParam0011';
        config2.SVMXC__Parameter_Type__c = 'Field Source';
        config2.SVMXC__Parameter_Value__c = 'Name';
        config2.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Access_Hours__r';
        config2.SVMXC__Object_Name2__c = 'SVMXC__Service_Group_Members__c';
        config2.SVMXC__Select__c = true;
        config2.SVMXC__Dispatch_Process__c = process.id;
        config2.RecordTypeId = Parameter_RType.Id;

        configLst.add(config);
        configLst.add(config1);
        configLst.add(config2);
        insert configLst;
        
        RecordType Rtype_SVMX_SFW_Layout = [Select Id, Name, SObjectType from RecordType where Name = 'Wizard Layout' and SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        SVMXC__ServiceMax_Config_Data__c SFWLayoutRec = new SVMXC__ServiceMax_Config_Data__c();
        SFWLayoutRec.SVMXC__Dispatch_Process__c = SFWRec.Id;
        SFWLayoutRec.SVMXC__Access_Configuration_Profile__c = SampleGroupProfile.Id;
        SFWLayoutRec.RecordTypeId = Rtype_SVMX_SFW_Layout.Id;
        SFWLayoutRec.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        SFWLayoutRec.SVMXC__Wizard_Layout_Row__c = 1;
        SFWLayoutRec.SVMXC__Wizard_Layout_Column__c = 1;
        SFWLayoutRec.SVMXC__Dispatch_Process__c = SFWRec.Id;
        insert SFWLayoutRec;
        
        SVMXC__ServiceMax_Config_Data__c SFWLayoutRec1 = new SVMXC__ServiceMax_Config_Data__c();
        SFWLayoutRec1.SVMXC__Dispatch_Process__c = SFWRec.Id;
        SFWLayoutRec1.SVMXC__Access_Configuration_Profile__c = SampleGroupProfile.Id;
        SFWLayoutRec1.RecordTypeId = Rtype_SVMX_SFW_Layout.Id;
        SFWLayoutRec1.SVMXC__Object_Name__c = 'SVMXC__Service_Order__c';
        SFWLayoutRec1.SVMXC__Wizard_Layout_Row__c = 1;
        SFWLayoutRec1.SVMXC__Wizard_Layout_Column__c = 2;
        SFWLayoutRec1.SVMXC__Dispatch_Process__c = SFWRec.Id;
        insert SFWLayoutRec1;

        SVMXC__ServiceMax_Processes__c SFWAction2 = new SVMXC__ServiceMax_Processes__c();
        SFWAction2.SVMXC__Select__c = true;
        SFWAction2.SVMXC__Sequence__c = 1 ;
        SFWAction2.SVMXC__Module__c = SFWRec.Id; //SFW defn lookup
        SFWAction2.SVMXC__Process__c = process.Id;
        SFWAction2.SVMXC__Name__c = 'SFWAction1001';
        SFWAction2.SVMXC__ProcessID__c = 'SFWAction002';
        SFWAction2.SVMXC__SettingID__c = 'SFWAction002';
        SFWAction2.SVMXC__Description__c = 'Sample Description';
        SFWAction2.SVMXC__Action_Type__c = 'OTHERS';
        SFWAction2.SVMXC__Action_URL__c = 'New url';
        SFWAction2.SVMXC__Submodule__c = ExpressionHeaderRec.Id; //named expression lookup
        SFWAction2.SVMXC__IsStandard__c = false;
        SFWAction2.RecordTypeId = RtypeSVMX_SFW_Action.Id;
        insert SFWAction2;

    Account AccObj = new Account();
    AccObj.Name = 'Acc';
    insert AccObj;

    INTF_GetServiceFlowWizard SFWObj = new INTF_GetServiceFlowWizard();
    SFWObj.GetSFWHTML(AccObj.Id,null);
    SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request();
    List<SFM_WrapperDef.SFM_StringMap> inputKeyValues = new List<SVMXC.SFM_WrapperDef.SFM_StringMap>();
    SFM_WrapperDef.SFM_StringMap StrngMap1 = new SFM_WrapperDef.SFM_StringMap();
    SFM_WrapperDef.SFM_StringMap StrngMap2 = new SFM_WrapperDef.SFM_StringMap();
    StrngMap1.key = 'RECORDID';
    StrngMap1.value = AccObj.Id;
    StrngMap2.key = 'OBJECTNAME';
    StrngMap2.value = 'SVMXC__Service_Order__c';
    inputKeyValues.add(StrngMap1);
    inputKeyValues.add(StrngMap2);
    request.stringMap = inputKeyValues;
    List<SFM_WrapperDef.SFM_StringListMap> stringListmp = new List<SFM_WrapperDef.SFM_StringListMap>();
    List<String> ActnTypeStrngLst = new List<String>();
    ActnTypeStrngLst.add('SFM');
    ActnTypeStrngLst.add('INVENTORY');
    ActnTypeStrngLst.add('OTHERS');
    stringListmp.add(new SFM_WrapperDef.SFM_StringListMap('ACTIONTYPE', ActnTypeStrngLst));
    request.stringListMap = stringListmp;
    SFWObj.getSFWWrapper(request);
    SFWObj.SVMX_GenerateActionUrl(SFWAction,'preview');
    
}

}