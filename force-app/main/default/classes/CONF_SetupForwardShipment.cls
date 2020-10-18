public with sharing class CONF_SetupForwardShipment
{
    public String Mode;
    public String HeaderId;
    public RecordType Rtype_Expressions;
    public RecordType ForwardShipmentRT;
    public RecordType Rtype_Schedules;
    public List<SVMXC__Site__c> lstAvailableDepotRecs = new List<SVMXC__Site__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> lst_EntryCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
    //Header Object Map related Declaration and getter, setter
    public List<SVMXC__ServiceMax_Processes__c> objectMappingPO_PO;
    public List<SelectOption> slctLst_objectMappingPO_PO;
    public List<SelectOption> getslctLst_objectMappingPO_PO(){return slctLst_objectMappingPO_PO;}
    //Line Object Map related Declaration and getter, setter
    public List<SVMXC__ServiceMax_Processes__c> objectMappingPOL_POL;
    public List<SelectOption> slctLst_objectMappingPOL_POL;
    public List<SelectOption> getslctLst_objectMappingPOL_POL(){return slctLst_objectMappingPOL_POL;}
    
    public List<SVMXC__ServiceMax_Config_Data__c> lstScheduleFrequencies = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstScheduleFrequencies(){ return lstScheduleFrequencies; }
    public void setlstScheduleFrequencies(List<SVMXC__ServiceMax_Config_Data__c> lstSchedules){ lstScheduleFrequencies = lstSchedules; }
    public List<SVMXC__ServiceMax_Config_Data__c> lstScheduleFrequencies_toDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    public List<SelectOption> OperatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getOperatorSelectLst(){return OperatorSelectLst;}
    public List<SelectOption> lstObjectsAllowedForCriteria = new List<SelectOption>();
    public List<SelectOption> getlstObjectsAllowedForCriteria() { return lstObjectsAllowedForCriteria; }
    
    public SVMXC__ServiceMax_Processes__c ForwardShipment_Header{ get; set; }
    public String SelectedRow {get; set;}
    public Map<String, List<SelectOption>> mapObjectNamelstFieldSlctOptn = new Map<String, List<SelectOption>>();
    public String SelectedObjName_Criteria{ get; set; }
    
    public List<ObjExpressionWrapper> LstPreFilterCriteria{ get; set; }
    public List<SVMXC__ServiceMax_Config_Data__c> LstPreFilterCriteria_toDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    //Available Depots
    public List<SelectOption> AvailableDepotOptns = new List<SelectOption>();
    public List<SelectOption> getAvailableDepotOptns(){return AvailableDepotOptns;}
    
    //Fields related declarations and methods
    public MAP<String,Schema.SObjectType> allObjs = Schema.getGlobalDescribe();
    public List<SelectOption> lstPartsOrder_Fields;
    public List<SelectOption> lstPartsOrderLine_Fields;
    
    /**** Tab Navigation methods *****/
    public String selectedTab = 'generalinfo';
    public String getselectedTab(){return selectedTab;}
    public void setselectedTab(String seltab){this.selectedTab = seltab;}
    public pageReference gotoGeneralInfoTab()
    {
        selectedTab = 'generalinfo';
        return null;
    }
    public pageReference gotoScheduleTab()
    {
        selectedTab = 'Schedule';
        return null;
    }
    
    /**** Getter method to get highest seq.no. *****/
    public Integer lstScheduleFrequencies_HighestSeqNum 
    {
        get{return lstScheduleFrequencies.size();}
    }
    public Integer LstPreFilterCriteria_HighestSeqNum 
    {
        get{return LstPreFilterCriteria.size();}
    }
    
    /************* Constructor  **************/
    public CONF_SetupForwardShipment()
    {
        ForwardShipmentRT = [Select Id, Name from RecordType where Name = 'Forward Shipment Process' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Rtype_Expressions = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        Rtype_Schedules = [select Id from RecordType where Name = 'Schedule' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        ForwardShipment_Header = new SVMXC__ServiceMax_Processes__c(SVMXC__IsStandard__c = false);
        ForwardShipment_Header.RecordTypeId = [Select Id, Name from RecordType where Name = 'Forward Shipment Process' AND SObjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1].Id;
        
        HeaderId = System.currentPageReference().getParameters().get('SVMX_RecordId');
        String TempMode = System.currentPageReference().getParameters().get('SVMX_Mode');
        
        if(HeaderId == null || HeaderId == '')
            Mode = 'New';
        else if(HeaderId != null && HeaderId != '' && TempMode == null)
            Mode = 'Edit';
        else if(HeaderId != null && HeaderId != '' && TempMode == 'Clone')
            Mode = 'Clone';
        
        lstAvailableDepotRecs = [Select Id, Name from SVMXC__Site__c where RecordType.Name = 'Depot' Order by Name];
        if(lstAvailableDepotRecs != null && lstAvailableDepotRecs.size() > 0)
        {
            for(SVMXC__Site__c DepotRec:lstAvailableDepotRecs)
                AvailableDepotOptns.add(new SelectOption(DepotRec.Id, DepotRec.Name));
        }
        
        /************* List of Operator  **************/
        OperatorSelectLst.clear();
        OperatorSelectLst.add(new SelectOption('SVMX.NONE',getTAG049()));
        OperatorSelectLst.add(new SelectOption('eq', getTAG050()));
        OperatorSelectLst.add(new SelectOption('ne', getTAG051()));
        OperatorSelectLst.add(new SelectOption('gt', getTAG052()));
        OperatorSelectLst.add(new SelectOption('ge', getTAG053()));
        OperatorSelectLst.add(new SelectOption('lt', getTAG054()));
        OperatorSelectLst.add(new SelectOption('le', getTAG055()));
        OperatorSelectLst.add(new SelectOption('starts', getTAG056()));
        OperatorSelectLst.add(new SelectOption('contains', getTAG057()));
        OperatorSelectLst.add(new SelectOption('notcontain', getTAG058()));
        OperatorSelectLst.add(new SelectOption('in', getTAG059()));
        OperatorSelectLst.add(new SelectOption('notin', getTAG060()));
        OperatorSelectLst.add(new SelectOption('isnull', getTAG061()));
        OperatorSelectLst.add(new SelectOption('isnotnull', getTAG062()));
        
        
        //lst of Objects allowed for Criteria
        lstObjectsAllowedForCriteria.add(new SelectOption('SVMX.NONE',getTAG049()));
        lstObjectsAllowedForCriteria.add(new SelectOption('SVMXC__RMA_Shipment_Order__c',getTAG063()));
        lstObjectsAllowedForCriteria.add(new SelectOption('SVMXC__RMA_Shipment_Line__c',getTAG064()));
        
        preparePicklistValues();
        /*
        SVMXC.COMM_SVMXC_Search_Expressions HdrExpressions = new SVMXC.COMM_SVMXC_Search_Expressions(2);
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        
        //Header Fields
        List<SelectOption> TemplstSelectOptions_Header = new List<SelectOption>();
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Order__c', TemplstSelectOptions_Header, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        //Line Fields
        List<SelectOption> TemplstSelectOptions_Line = new List<SelectOption>();
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Line__c', TemplstSelectOptions_Line, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        //Header fields 
        lstPartsOrder_Fields = new List<SelectOption>();
        lstPartsOrder_Fields.add(new SelectOption('SVMX.NONE',getTAG049()));
        lstPartsOrder_Fields.addAll(TemplstSelectOptions_Header);
        
        //Line fields 
        lstPartsOrderLine_Fields = new List<SelectOption>();
        lstPartsOrderLine_Fields.add(new SelectOption('SVMX.NONE',getTAG049()));
        lstPartsOrderLine_Fields.addAll(TemplstSelectOptions_Line);
        mapObjectNamelstFieldSlctOptn.put('SVMXC__RMA_Shipment_Order__c',lstPartsOrder_Fields);
        mapObjectNamelstFieldSlctOptn.put('SVMXC__RMA_Shipment_Line__c',lstPartsOrderLine_Fields);

        LstPreFilterCriteria = new List<ObjExpressionWrapper>();

        //Header Object Map records
        objectMappingPO_PO = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPO_PO = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c' order by SVMXC__Name__c];
        slctLst_objectMappingPO_PO = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPO_PO)
        {
            slctLst_objectMappingPO_PO.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));
        }

        //Detail Object Map records
        objectMappingPOL_POL = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPOL_POL = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' order by SVMXC__Name__c];
        slctLst_objectMappingPOL_POL = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPOL_POL)
        {
            slctLst_objectMappingPOL_POL.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));
        }
        */
        
        if(Mode == 'New')
        {
            LstPreFilterCriteria_AddRow();
            lstScheduleFrequencies_AddRow();
        }
        else if(Mode == 'Edit' && HeaderId != null && HeaderId != '')
        {
            ForwardShipment_Header = [Select Id, SVMXC__IsStandard__c, SVMXC__Location__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Node_Parent__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,  SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where Id = :HeaderId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lst_EntryCriteria = [Select Id, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Type__c = 'Fwd_Shipment_Entry_Criteria' AND SVMXC__Expression_Rule__c = :HeaderId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lst_EntryCriteria == null || (lst_EntryCriteria != null && !(lst_EntryCriteria.size() > 0)))
                LstPreFilterCriteria_AddRow();
            else
            {
                for(SVMXC__ServiceMax_Config_Data__c EntryCriRec : lst_EntryCriteria)
                {
                    if(EntryCriRec.SVMXC__Object_Name2__c != null && mapObjectNamelstFieldSlctOptn != null && mapObjectNamelstFieldSlctOptn.get(EntryCriRec.SVMXC__Object_Name2__c) != null)
                    {
                        List<SelectOption> TempSelectOption = new List<SelectOption>();
                        TempSelectOption = mapObjectNamelstFieldSlctOptn.get(EntryCriRec.SVMXC__Object_Name2__c);
                        ObjExpressionWrapper ObjExprWrpr = new ObjExpressionWrapper(EntryCriRec.clone(false, true), TempSelectOption);
                        LstPreFilterCriteria.add(ObjExprWrpr);
                    }
                }
            }
            lstScheduleFrequencies = [Select Id, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Schedule' AND SVMXC__Dispatch_Process__c = :HeaderId Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        }
        else if(Mode == 'Clone' && HeaderId != null && HeaderId != '')
        {
            //Clone Header Record
            SVMXC__ServiceMax_Processes__c tempForwardShipment_Header = new SVMXC__ServiceMax_Processes__c();
            tempForwardShipment_Header = [Select Id, SVMXC__IsStandard__c, SVMXC__Location__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Node_Parent__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,  SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where Id = :HeaderId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            ForwardShipment_Header = tempForwardShipment_Header.clone(false, true);
            ForwardShipment_Header.SVMXC__IsStandard__c = false;

            //Clone Expression records
            lst_EntryCriteria = [Select Id, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Type__c = 'Fwd_Shipment_Entry_Criteria' AND SVMXC__Expression_Rule__c = :HeaderId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(lst_EntryCriteria != null && lst_EntryCriteria.size() >0)
            {
                for(SVMXC__ServiceMax_Config_Data__c EntryCriRec : lst_EntryCriteria)
                {
                    if(EntryCriRec.SVMXC__Object_Name2__c != null && mapObjectNamelstFieldSlctOptn != null && mapObjectNamelstFieldSlctOptn.get(EntryCriRec.SVMXC__Object_Name2__c) != null)
                    {
                        List<SelectOption> TempSelectOption = new List<SelectOption>();
                        TempSelectOption = mapObjectNamelstFieldSlctOptn.get(EntryCriRec.SVMXC__Object_Name2__c);
                        ObjExpressionWrapper ObjExprWrpr = new ObjExpressionWrapper(EntryCriRec.clone(false, true), TempSelectOption);
                        LstPreFilterCriteria.add(ObjExprWrpr);
                    }
                }
            }
            else
                LstPreFilterCriteria_AddRow();
                
            //Clone Scheduling Details
            List<SVMXC__ServiceMax_Config_Data__c> clone_lstScheduleFrequencies = new List<SVMXC__ServiceMax_Config_Data__c>();
            clone_lstScheduleFrequencies = [Select Id, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Schedule' AND SVMXC__Dispatch_Process__c = :HeaderId Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(clone_lstScheduleFrequencies != null && clone_lstScheduleFrequencies.size() >0)
            {
                lstScheduleFrequencies = clone_lstScheduleFrequencies.deepclone(false,false,false);
            }
            else
                lstScheduleFrequencies_AddRow();
        }
    }
    
    public void preparePicklistValues()
    {
        SVMXC.COMM_SVMXC_Search_Expressions HdrExpressions = new SVMXC.COMM_SVMXC_Search_Expressions(2);
        WORD_SetupDispatch_Methods DispMethods = new WORD_SetupDispatch_Methods();
        
        //Header Fields
        List<SelectOption> TemplstSelectOptions_Header = new List<SelectOption>();
        TemplstSelectOptions_Header.add(new SelectOption('SVMX.NONE',getTAG049()));
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Order__c', TemplstSelectOptions_Header, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        //Line Fields
        List<SelectOption> TemplstSelectOptions_Line = new List<SelectOption>();
        TemplstSelectOptions_Line.add(new SelectOption('SVMX.NONE',getTAG049()));
        DispMethods.RetriveField('SVMXC__RMA_Shipment_Line__c', TemplstSelectOptions_Line, HdrExpressions.mapFieldDispType, HdrExpressions.FieldApiLable);
        
        //Header fields 
        lstPartsOrder_Fields = new List<SelectOption>();
        lstPartsOrder_Fields.add(new SelectOption('SVMX.NONE',getTAG049()));
        lstPartsOrder_Fields.addAll(TemplstSelectOptions_Header);
        
        //Line fields 
        lstPartsOrderLine_Fields = new List<SelectOption>();
        lstPartsOrderLine_Fields.add(new SelectOption('SVMX.NONE',getTAG049()));
        lstPartsOrderLine_Fields.addAll(TemplstSelectOptions_Line);
        mapObjectNamelstFieldSlctOptn.put('SVMXC__RMA_Shipment_Order__c',lstPartsOrder_Fields);
        mapObjectNamelstFieldSlctOptn.put('SVMXC__RMA_Shipment_Line__c',lstPartsOrderLine_Fields);

        LstPreFilterCriteria = new List<ObjExpressionWrapper>();

        //Header Object Map records
        objectMappingPO_PO = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPO_PO = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        slctLst_objectMappingPO_PO = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPO_PO)
        {
            slctLst_objectMappingPO_PO.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));
        }

        //Detail Object Map records
        objectMappingPOL_POL = new List<SVMXC__ServiceMax_Processes__c>();
        objectMappingPOL_POL = [Select id, SVMXC__Select__c, SVMXC__IsStandard__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Sequence__c, SVMXC__Description__c From SVMXC__ServiceMax_Processes__c  where SVMXC__Record_Type_Name__c='Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' AND SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c' order by SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        slctLst_objectMappingPOL_POL = new List<Selectoption>();
        for(SVMXC__ServiceMax_Processes__c ObjMapRec :objectMappingPOL_POL)
        {
            slctLst_objectMappingPOL_POL.add(new selectOption(ObjMapRec.Id, ObjMapRec.SVMXC__Name__c));
        }
    }
    
    /**************** Method to Add Row *******************/
    public pagereference LstPreFilterCriteria_AddRow()
    {
        LstPreFilterCriteria.add(new ObjExpressionWrapper(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Expressions.Id, SVMXC__Expression_Type__c = 'Fwd_Shipment_Entry_Criteria', SVMXC__Sequence__c = LstPreFilterCriteria.size() + 1), new List<SelectOption>()));
        return null;
    }
    
    /**************** Method to Delete Row *******************/
    public pagereference LstPreFilterCriteria_DelRow()
    {
        if(LstPreFilterCriteria == null || (LstPreFilterCriteria != null && !(LstPreFilterCriteria.size() > 0)))
            return null;
        Integer tempDeletedIndex = Integer.valueOf(SelectedRow) - 1;
        if(LstPreFilterCriteria[tempDeletedIndex] != null && LstPreFilterCriteria[tempDeletedIndex].ExpressionRec != null && LstPreFilterCriteria[tempDeletedIndex].ExpressionRec.get('Id') != null)
            LstPreFilterCriteria_toDelete.add(LstPreFilterCriteria[tempDeletedIndex].ExpressionRec);
        LstPreFilterCriteria.remove(tempDeletedIndex);
        for(integer i=0; i< LstPreFilterCriteria.size(); i++)
            LstPreFilterCriteria[i].ExpressionRec.SVMXC__Sequence__c = i + 1;
        return null;
    }
    
    /**************** Method to Populate all fields of selected object on OnChange *******************/
    public pagereference onchangeObjectName()
    {
        for(ObjExpressionWrapper exprRec: LstPreFilterCriteria)
        {
            if(SelectedRow == null || (exprRec.ExpressionRec.SVMXC__Sequence__c != Integer.valueOf(SelectedRow))) continue;
            SelectedObjName_Criteria = exprRec.ExpressionRec.SVMXC__Object_Name2__c;
            if( SelectedObjName_Criteria == null || (SelectedObjName_Criteria != null && SelectedObjName_Criteria.startswith('SVMX.NONE')))
            {
                exprRec.ObjectFields.clear();
                return null;
            }
            exprRec.ObjectFields = new List<SelectOption>();
            if(mapObjectNamelstFieldSlctOptn.get(SelectedObjName_Criteria) != null)
            {
                exprRec.ObjectFields.addAll(mapObjectNamelstFieldSlctOptn.get(SelectedObjName_Criteria));
                break;
            }
            break;
        }
        return null;
    }
    
    /**************** Method to Add Row *******************/
    public pagereference lstScheduleFrequencies_AddRow()
    {
        lstScheduleFrequencies.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Rtype_Schedules.Id, SVMXC__Sequence__c = lstScheduleFrequencies.size() + 1 ));
        return null;
    }
    
    /**************** Method to Delete Row *******************/
    public pagereference lstScheduleFrequencies_DelRow()
    {
        if(lstScheduleFrequencies == null || (lstScheduleFrequencies != null && !(lstScheduleFrequencies.size() > 0)))
            return null;
        Integer tempDeletedIndex = Integer.valueOf(SelectedRow) - 1;
        if(lstScheduleFrequencies[tempDeletedIndex] != null && lstScheduleFrequencies[tempDeletedIndex].get('Id') != null)
            lstScheduleFrequencies_toDelete.add(lstScheduleFrequencies[tempDeletedIndex]);
        lstScheduleFrequencies.remove(tempDeletedIndex);
        for(integer i=0; i< lstScheduleFrequencies.size(); i++)
            lstScheduleFrequencies[i].SVMXC__Sequence__c = i + 1;
        return null;
    }
    
    boolean IsValidShipment = true;
    String WhereClause = null;
    Map<String,Schema.Displaytype> fieldNameToDisplayType = new Map<String,Schema.Displaytype>();
    Map<String,Schema.SObjectType>  mapFieldApiObjName = new Map<String,Schema.SObjectType>();
    Map<String,String>  mapFieldRelName = new Map<String,String>();
    public boolean IsValidShipmentProcess()
    {
        IsValidShipment = true;
        /*********** validation for null name process ***********/
        if(ForwardShipment_Header.SVMXC__Name__c == null || ForwardShipment_Header.SVMXC__Name__c == '')
        {
            IsValidShipment = false;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG040()));
        }
        /*********** validation for error mail ***********/
        if(ForwardShipment_Header.SVMXC__Email_On_Error__c == null || ForwardShipment_Header.SVMXC__Email_On_Error__c == '')
        {
            IsValidShipment = false;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG047()));
        }
        /*********** validation for unique process ***********/
        List<SVMXC__ServiceMax_Processes__c> lstProcessRecs_UniquenessCheck = new List<SVMXC__ServiceMax_Processes__c>();
        String tempProcessId = ForwardShipment_Header.SVMXC__Name__c;
        lstProcessRecs_UniquenessCheck = [Select Id from SVMXC__ServiceMax_Processes__c where SVMXC__Name__c = :tempProcessId AND RecordType.Name = 'Forward Shipment Process']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(lstProcessRecs_UniquenessCheck != null && lstProcessRecs_UniquenessCheck.size() > 0)
        {
            if((ForwardShipment_Header.get('Id') == null) || (lstProcessRecs_UniquenessCheck[0].Id  != ForwardShipment_Header.get('Id')))
            {
                IsValidShipment = false;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG065()));
            }
        }
       
       /*********** validation in scheduling frequencies list ***********/
        Set<String> setAllRunAtRec = new Set<String>();
        Set<String> setAllScheduleRec = new Set<String>();
        map<string, set<string>> TimeDaysMap = new map<string, set<string>>();
        for(SVMXC__ServiceMax_Config_Data__c ScheduleRec :lstScheduleFrequencies)
        {
            if(setAllRunAtRec.contains(ScheduleRec.SVMXC__Run_At__c))
            {
                if(TimeDaysMap != null)
                {
                    set<string> TempScheduleDay = new set<string>();
                    TempScheduleDay.add(ScheduleRec.SVMXC__Schedule_Days__c);
                    list<string> strFinal = new list<string>();
                    set<string> setAllVal = new set<string>();
                    if(ScheduleRec.SVMXC__Schedule_Days__c != null && ScheduleRec.SVMXC__Schedule_Days__c.contains(';'))
                    {  
                        strFinal = ScheduleRec.SVMXC__Schedule_Days__c.split(';',7);
                        for(string str : strFinal)
                            setAllVal.add(str);
                    }
                    else
                        setAllVal.add(ScheduleRec.SVMXC__Schedule_Days__c);
                    
                    for(string str : setAllVal)
                    {
                        if(TimeDaysMap.get(ScheduleRec.SVMXC__Run_At__c) != null && TimeDaysMap.get(ScheduleRec.SVMXC__Run_At__c).contains(str))
                        {
                            IsValidShipment = false;
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, ScheduleRec.SVMXC__Run_At__c +': '+getTAG041()));
                            break;
                        }
                    }
                }
            }
            setAllRunAtRec.add(ScheduleRec.SVMXC__Run_At__c);
            set<string> TempSet = new set<string>();
            if(ScheduleRec.SVMXC__Schedule_Days__c != null && ScheduleRec.SVMXC__Schedule_Days__c.contains(';'))
            {  
                list<string> strFinal = new list<string>();
                strFinal = ScheduleRec.SVMXC__Schedule_Days__c.split(';',7);
                for(string str : strFinal)
                    TempSet.add(str);
            }
            else
                TempSet.add(ScheduleRec.SVMXC__Schedule_Days__c);
            
            if(TimeDaysMap.containsKey(ScheduleRec.SVMXC__Run_At__c))
            {   
                setAllScheduleRec.addAll(TimeDaysMap.get(ScheduleRec.SVMXC__Run_At__c));
                setAllScheduleRec.addAll(TempSet);
                TimeDaysMap = new map<string, set<string>>();
                TimeDaysMap.put(ScheduleRec.SVMXC__Run_At__c, setAllScheduleRec);
            }
            else
            {
                TimeDaysMap.put(ScheduleRec.SVMXC__Run_At__c, TempSet);
            }
        }
        
        map<id, SVMXC__ServiceMax_Processes__c> Id_FSProcessMap = new map<id, SVMXC__ServiceMax_Processes__c>();
        list<SVMXC__ServiceMax_Processes__c> ForwardShipmentProcessLst = new list<SVMXC__ServiceMax_Processes__c>();
        if(ForwardShipment_Header.Id == null)
            ForwardShipmentProcessLst = [Select Id, SVMXC__IsStandard__c, SVMXC__Location__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Node_Parent__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,  SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c = 'Forward Shipment Process']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        else if(ForwardShipment_Header.Id != null)
            ForwardShipmentProcessLst = [Select Id, SVMXC__IsStandard__c, SVMXC__Location__c, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Node_Parent__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c,  SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Processes__c where Id !=: ForwardShipment_Header.Id AND SVMXC__Record_Type_Name__c = 'Forward Shipment Process']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
        Id_FSProcessMap.putAll(ForwardShipmentProcessLst);
        
        List<SVMXC__ServiceMax_Config_Data__c> lstOtherConfigSchedule = new List<SVMXC__ServiceMax_Config_Data__c>(); 
        lstOtherConfigSchedule = [Select Id, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Schedule' AND SVMXC__Dispatch_Process__r.RecordTypeId =: ForwardShipmentRT.Id AND SVMXC__Dispatch_Process__c IN: Id_FSProcessMap.keySet() Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        Map<string,integer> ScheduleAndCountMap = new Map<string,integer>();
        for(integer i =0; i < lstOtherConfigSchedule.size(); i++)
        {
            if(lstOtherConfigSchedule[i].SVMXC__Schedule_Days__c.contains(';'))
            {
                list<string> strFinal = new list<string>();
                strFinal = lstOtherConfigSchedule[i].SVMXC__Schedule_Days__c.split(';',7);
                for(string str : strFinal)
                {
                    if(ScheduleAndCountMap.containsKey(string.valueOf(lstOtherConfigSchedule[i].SVMXC__Run_At__c)+'~'+str))
                    {    
                        integer x = ScheduleAndCountMap.get(string.valueOf(lstOtherConfigSchedule[i].SVMXC__Run_At__c)+'~'+str);
                        ScheduleAndCountMap.put(string.valueOf(lstOtherConfigSchedule[i].SVMXC__Run_At__c)+'~'+str,x+1);
                    }
                    else
                        ScheduleAndCountMap.put(string.valueOf(lstOtherConfigSchedule[i].SVMXC__Run_At__c)+'~'+str,1);
                }   
            }
            else
            {
                if(ScheduleAndCountMap.containsKey(string.valueOf(lstOtherConfigSchedule[i].SVMXC__Run_At__c)+'~'+lstOtherConfigSchedule[i].SVMXC__Schedule_Days__c))
                {
                    integer x = ScheduleAndCountMap.get(string.valueOf(lstOtherConfigSchedule[i].SVMXC__Run_At__c)+'~'+string.valueOf(lstOtherConfigSchedule[i].SVMXC__Schedule_Days__c));
                    ScheduleAndCountMap.put(string.valueOf(lstOtherConfigSchedule[i].SVMXC__Run_At__c)+'~'+string.valueOf(lstOtherConfigSchedule[i].SVMXC__Schedule_Days__c),x+1);
                }
                else
                    ScheduleAndCountMap.put(string.valueOf(lstOtherConfigSchedule[i].SVMXC__Run_At__c)+'~'+string.valueOf(lstOtherConfigSchedule[i].SVMXC__Schedule_Days__c),1);
            }
        }   
        /* for(string s : ScheduleAndCountMap.keyset())
            system.debug('Time:'+s+'  Count:'+ScheduleAndCountMap.get(s)); */
        
        for(SVMXC__ServiceMax_Config_Data__c ScheduleRec :lstScheduleFrequencies)
        {
            if(ScheduleRec.SVMXC__Schedule_Days__c != null && ScheduleRec.SVMXC__Schedule_Days__c.contains(';'))
            {
                list<string> strFinal = new list<string>();
                strFinal = ScheduleRec.SVMXC__Schedule_Days__c.split(';',7);
                for(string str : strFinal)
                {
                    if(ScheduleAndCountMap.get(string.valueOf(ScheduleRec.SVMXC__Run_At__c)+'~'+str) > 9)
                    {
                        IsValidShipment = false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG048()+' '+ScheduleRec.SVMXC__Schedule_Days__c+': '+ScheduleRec.SVMXC__Run_At__c));
                    }
                }   
            }
            else
            {
                if(ScheduleAndCountMap.get(string.valueOf(ScheduleRec.SVMXC__Run_At__c)+'~'+string.valueOf(ScheduleRec.SVMXC__Schedule_Days__c)) > 9)
                {
                    IsValidShipment = false;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG048()+' '+ScheduleRec.SVMXC__Schedule_Days__c+': '+ScheduleRec.SVMXC__Run_At__c));
                }
            }
        }
        
        /*********** validation of entry criteria ***********/
        Map<String,String> mapObjName_RelationShipName = new Map<String,String>();
        List<SVMXC__ServiceMax_Config_Data__c> temp_LstEntryCriteria = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp1 = new List<SFM_WrapperDef.SFM_Expression>();
        List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp2 = new List<SFM_WrapperDef.SFM_Expression>();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigLstForPO = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> ConfigLstForPOL = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        SVMXC__ServiceMax_Processes__c ProcessObjForPO = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Order__c');
        SVMXC__ServiceMax_Processes__c ProcessObjForPOL = new SVMXC__ServiceMax_Processes__c(SVMXC__Source_Object_Name__c = 'SVMXC__RMA_Shipment_Line__c');
        for(ObjExpressionWrapper ExpressionRow :LstPreFilterCriteria)
        {
            if(ExpressionRow.ExpressionRec.SVMXC__Object_Name2__c != null && ExpressionRow.ExpressionRec.SVMXC__Object_Name2__c != '' && ExpressionRow.ExpressionRec.SVMXC__Object_Name2__c != 'SVMX.NONE')
            {
                temp_LstEntryCriteria.add(ExpressionRow.ExpressionRec);
                if(ExpressionRow.ExpressionRec.SVMXC__Object_Name2__c == 'SVMXC__RMA_Shipment_Order__c')
                {
                    ConfigLstForPO.add(ExpressionRow.ExpressionRec);
                    mapObjName_RelationShipName.put('SVMXC__RMA_Shipment_Order__c','SVMXC__RMA_Shipment_Order__r');
                }
                else if(ExpressionRow.ExpressionRec.SVMXC__Object_Name2__c == 'SVMXC__RMA_Shipment_Line__c')
                    ConfigLstForPOL.add(ExpressionRow.ExpressionRec);
            }
        }
        
        boolean IsValidPOLst = true;
        boolean IsValidPOLLst = true;
        if(ConfigLstForPO != null && ConfigLstForPO.size() >0)
        {
            oResponse = new SFM_WrapperDef.SFM_Response();
            SFM_WrapperDef.SFM_Expression instanceSFM_Exp = new SFM_WrapperDef.SFM_Expression(ProcessObjForPO , ConfigLstForPO );
            LstSFM_Exp1.add(instanceSFM_Exp);
            SFM_WrapperDef.SFM_Request_Expression oRequest1 = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp1);
            oResponse = ValidateExp.SFM_validateExpression(oRequest1);
            if( oResponse.success != null && Boolean.valueOf(oResponse.success))
                IsValidPOLst = true;
            else
                IsValidPOLst = false;
        }
        if(ConfigLstForPOL != null && ConfigLstForPOL.size() >0)
        {
            oResponse = new SFM_WrapperDef.SFM_Response();
            SFM_WrapperDef.SFM_Expression instanceSFM_Exp = new SFM_WrapperDef.SFM_Expression(ProcessObjForPOL , ConfigLstForPOL );
            LstSFM_Exp2.add(instanceSFM_Exp);
            SFM_WrapperDef.SFM_Request_Expression oRequest2 = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp2);
            oResponse = ValidateExp.SFM_validateExpression(oRequest2);
            if( oResponse.success != null && Boolean.valueOf(oResponse.success))
                IsValidPOLLst = true;
            else
                IsValidPOLLst = false;
        }
        if(!IsValidPOLst || !IsValidPOLLst)
        {
            IsValidShipment = false;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG042()));
        }
        else
        {
            List<SVMXC__ServiceMax_Config_Data__c> lstExprRows = new List<SVMXC__ServiceMax_Config_Data__c>();
            for(SVMXC__ServiceMax_Config_Data__c tempConfigObj : temp_LstEntryCriteria)
            {
                lstExprRows.add(fillingConfigData(tempConfigObj));
            }
            APL_Utils AplUtils = new APL_Utils();
            WhereClause = AplUtils.BuildWhereClause_MasterDetailObjects('SVMXC__RMA_Shipment_Line__c', mapObjName_RelationShipName, ForwardShipment_Header.SVMXC__Advance_Expression__c, lstExprRows, fieldNameToDisplayType, mapFieldApiObjName, mapFieldRelName);
            system.debug('Test'+WhereClause);
        }
        return IsValidShipment;
    }
    
    
    public SVMXC__ServiceMax_Config_Data__c fillingConfigData(SVMXC__ServiceMax_Config_Data__c confdata)
    {
        SVMXC__ServiceMax_Config_Data__c newConfigData = new SVMXC__ServiceMax_Config_Data__c();
        newConfigData.SVMXC__Sequence__c = confdata.SVMXC__Sequence__c;
        newConfigData.SVMXC__Object_Name2__c = confdata.SVMXC__Object_Name2__c;
        newConfigData.SVMXC__Field_Name__c = confdata.SVMXC__Field_Name__c;
        newConfigData.SVMXC__Operator__c = confdata.SVMXC__Operator__c;
        newConfigData.SVMXC__Operand__c = confdata.SVMXC__Operand__c;
        
        string ObjName = confdata.SVMXC__Object_Name2__c;
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        if(ObjName == 'SVMXC__RMA_Shipment_Order__c')
            objfieldMap = SVMXC__RMA_Shipment_Order__c.SObjectType.getDescribe().fields.getMap();
        else if(ObjName == 'SVMXC__RMA_Shipment_Line__c')
            objfieldMap = SVMXC__RMA_Shipment_Line__c.SObjectType.getDescribe().fields.getMap();
        
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            if(f.getName() == newConfigData.SVMXC__Field_Name__c)
            {
                newConfigData.SVMXC__Display_Type__c = f.getType().name();
                fieldNameToDisplayType.put(newConfigData.SVMXC__Field_Name__c, f.getType());
                if(f.getType().name().ToUpperCase() == 'REFERENCE') 
                {
                    mapFieldApiObjName.put(f.getName(),f.getReferenceTo()[0]);
                    mapFieldRelName.put(f.getName(),f.getRelationshipName());
                    newConfigData.SVMXC__Field_Relationship_Name__c = f.getRelationshipName();
                    List<Schema.sObjectType> schema1 = new List<Schema.sObjectType>();
                    schema1 = f.getReferenceTo();
                    newConfigData.SVMXC__Object_Name__c = string.valueOf(schema1[0]);
                    if(schema1[0] == Account.SObjectType)
                        newConfigData.SVMXC__FKey_Name_Field__c = 'Name';
                    else
                    {
                        Map<String,Schema.SObjectField> R = schema1[0].getDescribe().fields.getMap();
                        for(String fieldKey1 : R.keySet())
                        {
                            Schema.SObjectField fsObj1 = R.get(fieldKey1);
                            Schema.DescribeFieldResult f1 = fsObj1.getDescribe();
                            if(f1.isNameField())
                                newConfigData.SVMXC__FKey_Name_Field__c = f1.getName();
                        }
                    }
                }
            }
        }
        return newConfigData;
    }
    
    
    /**************** Method to save process *********************************/
    public Boolean QuickSaveComplete;
    public SVMXC.SFM_validateExpression ValidateExp = new SVMXC.SFM_validateExpression();
    public SFM_WrapperDef.SFM_Response oResponse = new SFM_WrapperDef.SFM_Response();
    public pagereference QuickSave()
    {
        QuickSaveComplete = false;
        try
        {
            if(IsValidShipmentProcess() == true)
            {
                if(ForwardShipment_Header.SVMXC__Name__c != null || ForwardShipment_Header.SVMXC__Name__c != '')
                {
                    ForwardShipment_Header.RecordTypeId = ForwardShipmentRT.Id;
                    if(WhereClause != null && WhereClause != '')
                        ForwardShipment_Header.SVMXC__Parent_Object_Criteria__c = WhereClause;
                    else
                        ForwardShipment_Header.SVMXC__Parent_Object_Criteria__c = '';
                    
                    //upsert ForwardShipment_Header;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(ForwardShipment_Header, COMM_SecurityUtils.Access.Upsertable)){
                        upsert ForwardShipment_Header; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                
                /********* save Config Data for scheduling records ***********/
                List<SVMXC__ServiceMax_Config_Data__c> tempScheduleLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                for(SVMXC__ServiceMax_Config_Data__c ScheduleRec :lstScheduleFrequencies)
                {
                    if(ScheduleRec.SVMXC__Run_At__c != null && ScheduleRec.SVMXC__Run_At__c != '' && ScheduleRec.SVMXC__Schedule_Days__c != null && ScheduleRec.SVMXC__Schedule_Days__c != '')
                    {
                        ScheduleRec.RecordTypeId = Rtype_Schedules.Id;
                        ScheduleRec.SVMXC__Dispatch_Process__c = ForwardShipment_Header.Id;
                        tempScheduleLst.add(ScheduleRec);
                    }
                }
                lstScheduleFrequencies = new List<SVMXC__ServiceMax_Config_Data__c>();
                if(tempScheduleLst != null && tempScheduleLst.size() > 0)
                    lstScheduleFrequencies = tempScheduleLst;
                
                for(integer i = 0; i< lstScheduleFrequencies.size(); i++)
                    lstScheduleFrequencies[i].SVMXC__Sequence__c = i + 1;
                
                /**************** Delete unwanted data *********************************/
                List<SVMXC__ServiceMax_Config_Data__c> temp_LsttoDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
                if(LstPreFilterCriteria_toDelete != null && LstPreFilterCriteria_toDelete.size() > 0)
                    temp_LsttoDelete.addAll(LstPreFilterCriteria_toDelete);
                if(lstScheduleFrequencies_toDelete != null && lstScheduleFrequencies_toDelete.size() > 0)
                    temp_LsttoDelete.addAll(lstScheduleFrequencies_toDelete);
                    
                HeaderId = ForwardShipment_Header.Id;
                if(HeaderId != null && HeaderId.length() > 0 && HeaderId != '')
                {
                    lst_EntryCriteria = [Select Id, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Expressions' AND SVMXC__Expression_Type__c = 'Fwd_Shipment_Entry_Criteria' AND SVMXC__Expression_Rule__c = :HeaderId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    temp_LsttoDelete.addAll(lst_EntryCriteria);
                }
                
                if(temp_LsttoDelete != null && temp_LsttoDelete.size() > 0)
                {
                    if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__ServiceMax_Config_Data__c' ) ) {
                        
                        delete temp_LsttoDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                        temp_LsttoDelete.clear();
                    } else {
                        ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR,System.Label.COMM001_TAG142 ));
                        return null;
                    }
                }
                
                /**************** save Config Data *********************************/
                list<SVMXC__ServiceMax_Config_Data__c> LstConfigExp = new list<SVMXC__ServiceMax_Config_Data__c>();
                SVMXC__ServiceMax_Config_Data__c TempConfigObj;
                
                for(ObjExpressionWrapper ExpressionRow : LstPreFilterCriteria)
                {
                    TempConfigObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempConfigObj.SVMXC__Sequence__c = ExpressionRow.ExpressionRec.SVMXC__Sequence__c;
                    TempConfigObj.SVMXC__Field_Name__c = ExpressionRow.ExpressionRec.SVMXC__Field_Name__c;
                    TempConfigObj.SVMXC__Operator__c = ExpressionRow.ExpressionRec.SVMXC__Operator__c;
                    TempConfigObj.SVMXC__Operand__c = ExpressionRow.ExpressionRec.SVMXC__Operand__c;
                    TempConfigObj.SVMXC__Object_Name2__c = ExpressionRow.ExpressionRec.SVMXC__Object_Name2__c;
                    TempConfigObj.SVMXC__Expression_Rule__c = ForwardShipment_Header.Id;
                    TempConfigObj.SVMXC__Expression_Type__c = 'Fwd_Shipment_Entry_Criteria';
                    TempConfigObj.RecordTypeId = Rtype_Expressions.Id;
                    LstConfigExp.add(TempConfigObj);
                }
                system.debug('ConfigDta Lst'+LstConfigExp);
                if(LstConfigExp != null && LstConfigExp.size() > 0)
                {
                    //upsert LstConfigExp;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(LstConfigExp, COMM_SecurityUtils.Access.Upsertable)){
                        upsert LstConfigExp; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                if(lstScheduleFrequencies != null && lstScheduleFrequencies.size() > 0)
                {
                    //upsert lstScheduleFrequencies;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstScheduleFrequencies, COMM_SecurityUtils.Access.Upsertable)){
                        upsert lstScheduleFrequencies; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                preparePicklistValues();
                QuickSaveComplete = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, getTAG043(), ''));
            }
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage(), ''));
            
        }
        return null;
    }

    /************** SaveNClose method *******************/
    public pagereference SaveNClose()
    {
        QuickSave();
        if(!QuickSaveComplete) return null;
        PageReference ReturnPage = new PageReference('/apex/CONF_ManageForwardShipments');
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    /************** Cancel method *******************/
    public pagereference Cancel()
    {
        PageReference ReturnPage = new PageReference('/apex/CONF_ManageForwardShipments');
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    public class ObjExpressionWrapper
    {
        /********* All getter setter of wrapper class ***********/
        public SVMXC__ServiceMax_Config_Data__c ExpressionRec;
        public SVMXC__ServiceMax_Config_Data__c getExpressionRec(){return ExpressionRec;}
        public void setExpressionRec(SVMXC__ServiceMax_Config_Data__c Rec){this.ExpressionRec = Rec;}
        
        public List<SelectOption> ObjectFields = new List<SelectOption>();
        public List<SelectOption> getObjectFields(){return ObjectFields;}
        public void setObjectFields(List<SelectOption> SelOpt){this.ObjectFields = SelOpt;}
    
        /*********** Constructor ******************/
        public ObjExpressionWrapper(){}
        public ObjExpressionWrapper(SVMXC__ServiceMax_Config_Data__c ExprRec, List<SelectOption> ObjFields)
        {
            this.ExpressionRec = ExprRec;
            this.ObjectFields = ObjFields;
        }
    }
    
    /************** Custom tags *******************/
    public String getTag007(){return System.Label.CONF030_TAG007;}              //{ return 'Processing...' ;}
    public String getTAG017(){return System.Label.CONF030_TAG017;}                //{ return 'Setup Forward Shipment Process';}
    public String getTAG018(){return System.Label.CONF030_TAG018;}                //{ return 'Quick Save';}
    public String getTAG019(){return System.Label.CONF030_TAG019;}                //{ return 'Save & Close';}
    public String getTAG020(){return System.Label.CONF030_TAG020;}                //{ return 'cancel';}
    public String getTAG021(){return System.Label.CONF030_TAG021;}                //{ return 'General Info & Criteria';}
    public String getTAG022(){return System.Label.CONF030_TAG022;}                //{ return 'Rule Name';}
    public String getTAG023(){return System.Label.CONF030_TAG023;}                //{ return 'Depot';}
    public String getTAG024(){return System.Label.CONF030_TAG024;}                //{ return 'Description';}
    public String getTAG025(){return System.Label.CONF030_TAG025;}                //{ return 'Criteria to pick Orders for Forward Shipment';}
    public String getTAG026(){return System.Label.CONF030_TAG026;}                //{ return 'Sequence';}
    public String getTAG027(){return System.Label.CONF030_TAG027;}                //{ return 'Object';}
    public String getTAG028(){return System.Label.CONF030_TAG028;}                //{ return 'Field';}
    public String getTAG029(){return System.Label.CONF030_TAG029;}                //{ return 'Operator';}
    public String getTAG030(){return System.Label.CONF030_TAG030;}                //{ return 'Value';}
    public String getTAG031(){return System.Label.CONF030_TAG031;}                //{ return 'Advance Expression';}
    public String getTAG032(){return System.Label.CONF030_TAG032;}                //{ return 'Configure Mapping to create Forward Shipment Order for Received Items';}
    public String getTAG033(){return System.Label.CONF030_TAG033;}                //{ return 'Use this mapping definition to create Forward Shipment Order';}
    public String getTAG034(){return System.Label.CONF030_TAG034;}                //{ return 'Use this mapping definition to create Forward Shipment Order Lines';}
    public String getTAG035(){return System.Label.CONF030_TAG035;}                //{ return 'Schedule';}
    public String getTAG036(){return System.Label.CONF030_TAG036;}                //{ return 'Configure frequency to execute Forward Shipment Engine for selected Inventory-org/Depot';}
    public String getTAG037(){return System.Label.CONF030_TAG026;}                //{ return 'Sequence';}
    public String getTAG038(){return System.Label.CONF030_TAG038;}                //{ return 'Run At (GMT)';}
    public String getTAG039(){return System.Label.CONF030_TAG039;}                //{ return 'Days';}
    public String getTAG040(){return System.Label.CONF030_TAG040;}                //{ return 'Please enter a valid Process Name';}
    public String getTAG041(){return System.Label.CONF030_TAG041;}                //{ return 'has been entered twice in schedule frequency list';}
    public String getTAG042(){return System.Label.CONF030_TAG042;}                //{ return 'Entry criteria is invalid';}
    public String getTAG043(){return System.Label.CONF030_TAG043;}                //{ return 'Forward shipment process saved successfully';}
    public String getTAG044(){ return System.Label.CONF030_TAG044;}              //'Specify recipients of notifications and alerts'
    public String getTAG045(){ return System.Label.CONF030_TAG045;}             //{return 'Send success notifications to this email address'}
    public String getTAG046(){ return System.Label.CONF030_TAG046;}              //{return 'Send error notifications to this email address'}
    public String getTAG047(){ return System.Label.CONF030_TAG047;}             //{return 'Please enter email address for error notification'}
    public String getTAG048(){ return System.Label.CONF030_TAG048;}             //{return 'You can schedule up to 10 depots for any given day and time. Limit exceeded for the following schedules: '}
    public String getTAG049(){return System.Label.CONF030_TAG037;}                      // '--None--'
    
    public String getTAG050(){return System.Label.COMM002_TAG006;}  // 'Equals'
    public String getTAG051(){return System.Label.COMM002_TAG007;}  // 'Not Equal'
    public String getTAG052(){return System.Label.COMM002_TAG008;}  // 'Greater Than'
    public String getTAG053(){return System.Label.COMM002_TAG009;}  // 'Greater or Equal To'
    public String getTAG054(){return System.Label.COMM002_TAG010;}  // 'Less Than'
    public String getTAG055(){return System.Label.COMM002_TAG011;}  // 'Less or Equal To'
    public String getTAG056(){return System.Label.COMM002_TAG012;}  // 'Starts With'
    public String getTAG057(){return System.Label.COMM002_TAG013;}  // 'Contains'
    public String getTAG058(){return System.Label.COMM002_TAG014;}  // 'Does Not Contain'
    public String getTAG059(){return System.Label.COMM002_TAG015;}  // 'Includes'
    public String getTAG060(){return System.Label.COMM002_TAG016;}  // 'Excludes'
    public String getTAG061(){return System.Label.COMM002_TAG022;}  // 'Is Null'
    public String getTAG062(){return System.Label.COMM002_TAG023;}  // 'Is Not Null'
    public String getTAG063(){return System.Label.CONF030_TAG049;}  // 'Parts Order'
    public String getTAG064(){return System.Label.CONF030_TAG050;}  // 'Parts Order Line'
    public String getTAG065(){return System.Label.CONF030_TAG051;}  // 'Please enter a unique process name'
    public String getTAG066() {return system.label.COMM002_TAG032;}//'Add Row'
    public String getTAG067() {return system.label.COMM002_TAG033;}//'Delete Row'
    public string getHLPURL() {return system.label.CONF030_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
}