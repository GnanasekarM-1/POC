@isTest(SeeAllData=true)
private class CONF_SetupForwardShipment_UT
{

    static testmethod void CONF_SetupForwardShipment_UnitTest1()
    {
    
        RecordType Rtype_FwdShipment = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name ='Forward Shipment Process'];
        List<SVMXC__ServiceMax_Processes__c> lst_FwdShipmentProcess = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c FwdShipmentRec = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =Rtype_FwdShipment.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'SampleProcess-SVMX001',
                                            SVMXC__ProcessId__c = 'SampleProcess-SVMX001',
                                            SVMXC__IsStandard__c = false,
                                            SVMXC__Email_On_Error__c = 'a@b.com'
                                            );
        insert FwdShipmentRec;
        lst_FwdShipmentProcess.add(FwdShipmentRec);
        RecordType Rtype_Depot = [Select Id, Name from RecordType where SObjectType = 'SVMXC__Site__c' AND Name = 'Depot'];
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Location1';
        Loc1.RecordTypeId = Rtype_Depot.Id;
        insert Loc1;
        
        SVMXC__Site__c Loc2 = new SVMXC__Site__c();
        Loc2.Name = 'Location1';
        Loc2.RecordTypeId = Rtype_Depot.Id;
        insert Loc2;
        
       
        //Expression starts here
        RecordType ExpressionsDetail_Rtype = [select Id from RecordType where Name=:'Expressions'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        system.assert(Loc2.Name!=null);
        system.assert(Loc1.Name!=null);
        system.assert(FwdShipmentRec.SVMXC__ProcessId__c!=null);

        List<SVMXC__ServiceMax_Config_Data__c> expdetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c expDetails01 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails01.SVMXC__Object_Name2__c ='SVMXC__RMA_Shipment_Order__c';
        expDetails01.SVMXC__Sequence__c = 1;
        expDetails01.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails01.SVMXC__Field_Name__c ='SVMXC__Source_City__c';
        expDetails01.SVMXC__Operator__c = 'eq';
        expDetails01.SVMXC__Operand__c = 'Bangalore';
        expDetails01.SVMXC__Display_Type__c = 'String';
        expDetails01.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails01.SVMXC__Expression_Rule__c = FwdShipmentRec.Id;
        expdetailsLst.add(expDetails01);
        system.assert(expDetails01.SVMXC__Sequence__c!=null);
        system.assert(expDetails01.SVMXC__Operand__c!=null);
        
        SVMXC__ServiceMax_Config_Data__c expDetails02 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails02.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails02.SVMXC__Sequence__c = 2;
        expDetails02.SVMXC__Object_Name2__c ='SVMXC__RMA_Shipment_Line__c';
        expDetails02.SVMXC__Field_Name__c ='SVMXC__Warehouse__c';
        expDetails02.SVMXC__Operator__c = 'eq';
        expDetails02.SVMXC__Operand__c = 'Bangalore';
        expDetails02.SVMXC__Display_Type__c = 'String';
        expDetails02.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails02.SVMXC__Expression_Rule__c = FwdShipmentRec.Id;
        expdetailsLst.add(expDetails02);
        insert expdetailsLst;
        
        RecordType Schedule_Rtype = [select Id from RecordType where Name=:'Schedule'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        List<SVMXC__ServiceMax_Config_Data__c> lstScheduleFrequencies = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c Schedule1 = new SVMXC__ServiceMax_Config_Data__c();
        Schedule1.RecordTypeId = Schedule_Rtype.Id;
        Schedule1.SVMXC__Sequence__c = 1;
        Schedule1.SVMXC__Run_At__c = '4 AM';
        Schedule1.SVMXC__Schedule_Days__c = 'Monday';
        Schedule1.SVMXC__Dispatch_Process__c = FwdShipmentRec.Id;
        lstScheduleFrequencies.add(Schedule1);
        SVMXC__ServiceMax_Config_Data__c Schedule2 = new SVMXC__ServiceMax_Config_Data__c();
        Schedule2.RecordTypeId = Schedule_Rtype.Id;
        Schedule2.SVMXC__Sequence__c = 1;
        Schedule2.SVMXC__Run_At__c = '4 AM';
        Schedule2.SVMXC__Schedule_Days__c = 'Monday';
        Schedule2.SVMXC__Dispatch_Process__c = FwdShipmentRec.Id;
        
        lstScheduleFrequencies.add(Schedule2);
        insert lstScheduleFrequencies;
        
        System.currentPageReference().getParameters().put('SVMX_RecordId',FwdShipmentRec.Id);
        System.currentPageReference().getParameters().put('SVMX_Mode',null);
        CONF_SetupForwardShipment SetupForwardShipmentInstance = new CONF_SetupForwardShipment();
        List<CONF_SetupForwardShipment.ObjExpressionWrapper> WrapObjlst = new List<CONF_SetupForwardShipment.ObjExpressionWrapper>();
        CONF_SetupForwardShipment.ObjExpressionWrapper WrapObj = new CONF_SetupForwardShipment.ObjExpressionWrapper();
        List<SelectOption> SelOpt = new List<SelectOption>();
        WrapObj.getExpressionRec();
        WrapObj.setExpressionRec(expDetails01);
        WrapObj.getObjectFields();
        WrapObj.setObjectFields(SelOpt);
        WrapObjlst.add(WrapObj);
        WrapObj.setExpressionRec(expDetails02);
        WrapObjlst.add(WrapObj);
        SetupForwardShipmentInstance.SelectedRow = '1';
        SetupForwardShipmentInstance.LstPreFilterCriteria = WrapObjlst;
        SetupForwardShipmentInstance.getlstScheduleFrequencies();
        SetupForwardShipmentInstance.setlstScheduleFrequencies(lstScheduleFrequencies);
        SetupForwardShipmentInstance.getslctLst_objectMappingPO_PO();
        SetupForwardShipmentInstance.ForwardShipment_Header = FwdShipmentRec;
        SetupForwardShipmentInstance.getslctLst_objectMappingPOL_POL();
        SetupForwardShipmentInstance.getOperatorSelectLst();
        SetupForwardShipmentInstance.getlstObjectsAllowedForCriteria();
        SetupForwardShipmentInstance.getAvailableDepotOptns();
        SetupForwardShipmentInstance.getselectedTab();
        SetupForwardShipmentInstance.setselectedTab('generalinfo');
        SetupForwardShipmentInstance.gotoGeneralInfoTab();
        SetupForwardShipmentInstance.gotoScheduleTab();
        SetupForwardShipmentInstance.LstPreFilterCriteria_AddRow();
        SetupForwardShipmentInstance.LstPreFilterCriteria_DelRow();
        SetupForwardShipmentInstance.onchangeObjectName();
        SetupForwardShipmentInstance.lstScheduleFrequencies_AddRow();
        SetupForwardShipmentInstance.lstScheduleFrequencies_DelRow();
        system.assert(SetupForwardShipmentInstance.lstScheduleFrequencies_HighestSeqNum!=null);
        system.assert(SetupForwardShipmentInstance.LstPreFilterCriteria_HighestSeqNum!=null);
        SetupForwardShipmentInstance.QuickSave();
        SetupForwardShipmentInstance.SaveNClose();
        SetupForwardShipmentInstance.Cancel();
    }
    static testmethod void CONF_SetupForwardShipment_UnitTest2()
    {
    
        RecordType Rtype_FwdShipment = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name ='Forward Shipment Process'];
        List<SVMXC__ServiceMax_Processes__c> lst_FwdShipmentProcess = new List<SVMXC__ServiceMax_Processes__c>();
        SVMXC__ServiceMax_Processes__c FwdShipmentRec = new SVMXC__ServiceMax_Processes__c(
                                            RecordTypeId =Rtype_FwdShipment.Id,
                                            SVMXC__Active__c = true,
                                            SVMXC__Name__c = 'SampleProcess-SVMX001',
                                            SVMXC__ProcessId__c = 'SampleProcess-SVMX001',
                                            SVMXC__IsStandard__c = false
                                            );
        insert FwdShipmentRec;
        lst_FwdShipmentProcess.add(FwdShipmentRec);
        RecordType Rtype_Depot = [Select Id, Name from RecordType where SObjectType = 'SVMXC__Site__c' AND Name = 'Depot'];
        SVMXC__Site__c Loc1 = new SVMXC__Site__c();
        Loc1.Name = 'Location1';
        Loc1.RecordTypeId = Rtype_Depot.Id;
        insert Loc1;
        
        SVMXC__Site__c Loc2 = new SVMXC__Site__c();
        Loc2.Name = 'Location1';
        Loc2.RecordTypeId = Rtype_Depot.Id;
        insert Loc2;
        
       
        //Expression starts here
        RecordType ExpressionsDetail_Rtype = [select Id from RecordType where Name=:'Expressions'and SobjectType=:'SVMXC__ServiceMax_Config_Data__c' Limit 1];
        
        system.assert(Loc2.Name!=null);
        system.assert(Loc1.Name!=null);
        system.assert(FwdShipmentRec.SVMXC__ProcessId__c!=null);

        List<SVMXC__ServiceMax_Config_Data__c> expdetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c expDetails01 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails01.SVMXC__Sequence__c = 1;
        expDetails01.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails01.SVMXC__Field_Name__c ='SVMXC__Source_City__c';
        expDetails01.SVMXC__Operator__c = 'eq';
        expDetails01.SVMXC__Operand__c = 'Bangalore';
        expDetails01.SVMXC__Object_Name2__c ='SVMXC__RMA_Shipment_Order__c';
        expDetails01.SVMXC__Display_Type__c = 'String';
        expDetails01.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails01.SVMXC__Expression_Rule__c = FwdShipmentRec.Id;
        expdetailsLst.add(expDetails01);
        system.assert(expDetails01.SVMXC__Sequence__c!=null);
        system.assert(expDetails01.SVMXC__Operand__c!=null);
        
        SVMXC__ServiceMax_Config_Data__c expDetails02 = new SVMXC__ServiceMax_Config_Data__c();
        expDetails02.RecordTypeId = ExpressionsDetail_Rtype.Id;
        expDetails02.SVMXC__Sequence__c = 2;
        expDetails02.SVMXC__Object_Name2__c ='SVMXC__RMA_Shipment_Line__c';
        expDetails02.SVMXC__Field_Name__c ='SVMXC__Warehouse__c';
        expDetails02.SVMXC__Operator__c = 'eq';
        expDetails02.SVMXC__Operand__c = 'Bangalore';
        expDetails02.SVMXC__Display_Type__c = 'String';
        expDetails02.SVMXC__Expression_Type__c = 'EXP_Named';
        expDetails02.SVMXC__Expression_Rule__c = FwdShipmentRec.Id;
        expdetailsLst.add(expDetails02);
        
        insert expdetailsLst;
        
        System.currentPageReference().getParameters().put('SVMX_RecordId',FwdShipmentRec.Id);
        System.currentPageReference().getParameters().put('SVMX_Mode','Clone');
        CONF_SetupForwardShipment SetupForwardShipmentInstance = new CONF_SetupForwardShipment();
        List<CONF_SetupForwardShipment.ObjExpressionWrapper> WrapObjlst = new List<CONF_SetupForwardShipment.ObjExpressionWrapper>();
        CONF_SetupForwardShipment.ObjExpressionWrapper WrapObj = new CONF_SetupForwardShipment.ObjExpressionWrapper();
        List<SelectOption> SelOpt = new List<SelectOption>();
        WrapObj.getExpressionRec();
        WrapObj.setExpressionRec(expDetails01);
        WrapObj.getObjectFields();
        WrapObj.setObjectFields(SelOpt);
        WrapObjlst.add(WrapObj);
        WrapObj.setExpressionRec(expDetails02);
        WrapObjlst.add(WrapObj);
        SetupForwardShipmentInstance.SelectedRow = '1';
        //SetupForwardShipmentInstance.LstPreFilterCriteria = WrapObjlst;
        SetupForwardShipmentInstance.getslctLst_objectMappingPO_PO();
        SetupForwardShipmentInstance.ForwardShipment_Header = FwdShipmentRec;
        SetupForwardShipmentInstance.getslctLst_objectMappingPOL_POL();
        SetupForwardShipmentInstance.getlstScheduleFrequencies();
        List<SVMXC__ServiceMax_Config_Data__c> lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
        SetupForwardShipmentInstance.setlstScheduleFrequencies(lstSchedules);
        SetupForwardShipmentInstance.getOperatorSelectLst();
        SetupForwardShipmentInstance.getlstObjectsAllowedForCriteria();
        SetupForwardShipmentInstance.getAvailableDepotOptns();
        SetupForwardShipmentInstance.getselectedTab();
        SetupForwardShipmentInstance.setselectedTab('generalinfo');
        SetupForwardShipmentInstance.gotoGeneralInfoTab();
        SetupForwardShipmentInstance.gotoScheduleTab();
        SetupForwardShipmentInstance.LstPreFilterCriteria_AddRow();
        SetupForwardShipmentInstance.LstPreFilterCriteria_DelRow();
        SetupForwardShipmentInstance.onchangeObjectName();
        SetupForwardShipmentInstance.lstScheduleFrequencies_AddRow();
        SetupForwardShipmentInstance.lstScheduleFrequencies_DelRow();
        system.assert(SetupForwardShipmentInstance.lstScheduleFrequencies_HighestSeqNum!=null);
        system.assert(SetupForwardShipmentInstance.LstPreFilterCriteria_HighestSeqNum!=null);
        SetupForwardShipmentInstance.QuickSave();
        SetupForwardShipmentInstance.SaveNClose();
        SetupForwardShipmentInstance.Cancel();
        SetupForwardShipmentInstance.getTag007();
        SetupForwardShipmentInstance.getTag017();
        SetupForwardShipmentInstance.getTag018();
        SetupForwardShipmentInstance.getTag018();
        SetupForwardShipmentInstance.getTag019();
        SetupForwardShipmentInstance.getTag020();
        SetupForwardShipmentInstance.getTag021();
        SetupForwardShipmentInstance.getTag022();
        SetupForwardShipmentInstance.getTag023();
        SetupForwardShipmentInstance.getTag024();
        SetupForwardShipmentInstance.getTag025();
        SetupForwardShipmentInstance.getTag026();
        SetupForwardShipmentInstance.getTag027();
        SetupForwardShipmentInstance.getTag028();
        SetupForwardShipmentInstance.getTag029();
        SetupForwardShipmentInstance.getTag030();
        SetupForwardShipmentInstance.getTag031();
        SetupForwardShipmentInstance.getTag032();
        SetupForwardShipmentInstance.getTag033();
        SetupForwardShipmentInstance.getTag034();
        SetupForwardShipmentInstance.getTag035();
        SetupForwardShipmentInstance.getTag036();
        SetupForwardShipmentInstance.getTag037();
        SetupForwardShipmentInstance.getTag038();
        SetupForwardShipmentInstance.getTag039();
        SetupForwardShipmentInstance.getTag040();
        SetupForwardShipmentInstance.getTag041();
        SetupForwardShipmentInstance.getTag042();
        SetupForwardShipmentInstance.getTag043();
        SetupForwardShipmentInstance.getTag044();
        SetupForwardShipmentInstance.getTag045();
    }
}