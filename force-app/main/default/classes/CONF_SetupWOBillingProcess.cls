public with sharing class CONF_SetupWOBillingProcess
{
    //-------------------------------------- Variables and Getter-Setter Methods ------------------------------------------------------
    public SVMXC__ServiceMax_Processes__c woBillingProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getwoBillingProcess(){return this.woBillingProcess;}
    public void setwoBillingProcess(SVMXC__ServiceMax_Processes__c proces){this.woBillingProcess = proces;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSrcUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSrcUpdates() { return this.lstSrcUpdates;}
    public void setlstSrcUpdates(List<SVMXC__ServiceMax_Config_Data__c> lst) { this.lstSrcUpdates = lst;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSchedules() { return this.lstSchedules;}
    public void setlstSchedules(List<SVMXC__ServiceMax_Config_Data__c> lst) { this.lstSchedules = lst;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSchedules_toDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    //neeed to comment this getter setter
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSchedules_toDelete(){return this.lstSchedules_toDelete;}
    public void setlstSchedules_toDelete(List<SVMXC__ServiceMax_Config_Data__c> lst){this.lstSchedules_toDelete = lst;}

    public SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
    public SFM_WrapperDef.SFM_Expression exp = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression expWO = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getexpWO(){return this.expWO;}
    public void setexpWO(SFM_WrapperDef.SFM_Expression sfmExp){this.expWO = sfmExp;}
    public SFM_WrapperDef.SFM_Expression exp_Case = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getexp_Case(){return this.exp_Case;}
    public void setexp_Case(SFM_WrapperDef.SFM_Expression sfmExp){this.exp_Case = sfmExp;}
    
    public Integer detailSize = 0;
    public integer expDetailSize = 0;
    public integer getexpDetailSize(){return this.expDetailSize;}
    public void setexpDetailSize(integer inte){this.expDetailSize = inte;}
    public integer srcUpdateHdrSize = 0;
    public integer getsrcUpdateHdrSize(){return this.srcUpdateHdrSize;}
    public void setsrcUpdateHdrSize(integer inte){this.srcUpdateHdrSize = inte;}
    public integer expDetailSize_Case = 0;
    public integer getexpDetailSize_Case(){return this.expDetailSize_Case;}
    public void setexpDetailSize_Case(integer inte){this.expDetailSize_Case = inte;}
    public integer srcUpdateHdrSize_Case = 0;
    public integer getsrcUpdateHdrSize_Case(){return this.srcUpdateHdrSize_Case;}
    public void setsrcUpdateHdrSize_Case(integer inte){this.srcUpdateHdrSize_Case = inte;}
    public integer intSeqVal;
    public integer getintSeqVal(){return this.intSeqVal;}
    public void setintSeqVal(integer index){this.intSeqVal = index;}
    
    public string recordId;
    public string mode;
    public string WOBilProcess_RtypeID = '';
    public String selectedRow {get; set;}
    public string selectedTab{get;set;}
    public string delIndex{get;set;}
    public string selectedExp{get;set;}
    public string strSCtoInvocObjMap{get;set;}
    public string strSCtoInvocDtlObjMap{get;set;}
    public string strWDtoInvocLinesObjMap{get;set;}
    public string selectedExp_Case{get;set;}
    public string strSCtoInvocDtlObjMap_Case{get;set;}
    public string strWDtoInvocLinesObjMap_Case{get;set;}
    public string strCasetoInvocDtlObjMap{get;set;}
    public string strCLtoInvocLinesObjMap{get;set;}
    public string strWOobjLabel{get;set;}
    public string strCaseobjLabel{get;set;}

    public boolean disableEditLink{get;set;}
    public boolean disabled{get;set;}
    public boolean validate{get;set;}
    public boolean isCreateNewExp{get;set;}
    public boolean renderExpBlock{get;set;}
    public boolean disableWOFldLst2{get;set;}
    public boolean disableWOFldLst3{get;set;}
    public boolean isRenderedForCase{get;set;}
    public boolean isRenderedForWO{get;set;}
    public boolean isScopeForCase{get; set;}
    public boolean isScopeForWO{get; set;}
    public boolean isConsolidate{get; set;}
    public boolean disableCaseFldLst3{get;set;}
    public boolean isCreateNewExp_Case{get;set;}
    public boolean renderExpBlock_Case{get;set;}
    public boolean disableEditLink_Case{get;set;}
    public boolean isCaseAvilabel{get; set;}
    
    RecordType expHdr_Rtype;
    RecordType expDtl_Rtype;
    RecordType expSrcUpdate_Rtype;
    RecordType schedule_Rtype;
    RecordType woBilProcess_Rtype;
    RecordType objMap_Rtype;
    
    List<SVMXC__ServiceMax_Config_Data__c> lstExp = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SelectOption> lstCriteria = new List<SelectOption>();
    public List<SelectOption> getlstCriteria(){return this.lstCriteria;}
    public List<SelectOption> lstUpdateOperator = new List<SelectOption>();
    public List<SelectOption> getlstUpdateOperator(){return this.lstUpdateOperator;} 
    public void setlstUpdateOperator(List<SelectOption> lstField){this.lstUpdateOperator = lstField;}
    public List<selectoption> woFldLst=new List<selectoption>();
    public List<selectoption> getwoFldLst() {return this.woFldLst;}
    public List<selectoption> woFldLst2=new List<selectoption>();
    public List<selectoption> getwoFldLst2() {return this.woFldLst2;}
    public List<selectoption> woFldLst3=new List<selectoption>();
    public List<selectoption> getwoFldLst3() {return this.woFldLst3;}
    public List<SelectOption> operatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getoperatorSelectLst(){return operatorSelectLst;}
    public List<SelectOption> objMapSCtoInvoiceLst = new List<SelectOption>();
    public List<SelectOption> getobjMapSCtoInvoiceLst(){return objMapSCtoInvoiceLst;}
    public List<SelectOption> objMapSCtoInvoiceDtlLst = new List<SelectOption>();
    public List<SelectOption> getobjMapSCtoInvoiceDtlLst(){return objMapSCtoInvoiceDtlLst;}
    public List<SelectOption> objMapWDtoInvoiceLineLst = new List<SelectOption>();
    public List<SelectOption> getobjMapWDtoInvoiceLineLst(){return objMapWDtoInvoiceLineLst;}
    public List<SelectOption> lstTimeZones{get;set;}
    // create select option of case invoice scope 
    public List<SelectOption> lstCriteria_Case = new List<SelectOption>();
    public List<SelectOption> getlstCriteria_Case(){return this.lstCriteria_Case;}
    public List<selectoption> CaseFldLst=new List<selectoption>();
    public List<selectoption> getCaseFldLst() {return this.CaseFldLst;}
    public List<selectoption> CaseFldLst2=new List<selectoption>();
    public List<selectoption> getCaseFldLst2() {return this.CaseFldLst2;}
    public List<selectoption> CaseFldLst3=new List<selectoption>();
    public List<selectoption> getCaseFldLst3() {return this.CaseFldLst3;}
    public List<SelectOption> objMapCasetoInvoiceDtlLst = new List<SelectOption>();
    public List<SelectOption> getobjMapCasetoInvoiceDtlLst(){return objMapCasetoInvoiceDtlLst;}
    public List<SelectOption> objMapCLtoInvoiceLineLst = new List<SelectOption>();
    public List<SelectOption> getobjMapCLtoInvoiceLineLst(){return objMapCLtoInvoiceLineLst;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSrcUpdates_Case = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSrcUpdates_Case() { return this.lstSrcUpdates_Case;}
    public void setlstSrcUpdates_Case(List<SVMXC__ServiceMax_Config_Data__c> lst) { this.lstSrcUpdates_Case = lst;}
    
    
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> map_SeqNumRecExp_Case = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> map_SeqNumsrcUpdate_Case = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> map_SeqNumRecExp = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> map_SeqNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> map_SeqNumsrcUpdate = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    
    
    public Integer lstSchedules_HighSeqNum 
    {
        get{return lstSchedules.size();}
    }
    
    //--------------------------------- Constructor/On-Load --------------------------------------------------
    public CONF_SetupWOBillingProcess()
    {
        try
        {
            mode = System.currentPageReference().getParameters().get('SVMX_Mode');
            recordId = System.currentPageReference().getParameters().get('SVMX_RecordId');
            lstTimeZones = new List<SelectOption>();
            retrieveRecordTypes();
            setDefaultValues();
            preparingPicklists();
            // code for checking case is applicable for this org or not
            COMM_Utils objComm_Utils = new COMM_Utils();
            Map<String, boolean> mapObject = new Map<String, boolean>();
            mapObject = objComm_Utils.SVMX_getPermittedStandardObjectList();
            System.debug('is Case avilable : '+mapObject.containsKey('Case'));
            if(mapObject != null && mapObject.containsKey('Case'))
                isCaseAvilabel = true;
            
            //code for checking case is applicable is completed
            
            if(mode != 'New' && recordId != null && recordId != '')
            {
                woBillingProcess = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Node_Parent__c, SVMXC__Process__c, SVMXC__Primary_Consolidation_Rule__c, SVMXC__Secondary_Consolidation_Rule__c, SVMXC__Tertiary_Consolidation_Rule__c, SVMXC__Include_Product__c, SVMXC__Process1__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Capture_Log__c, SVMXC__IsStandard__c, SVMXC__Active__c,SVMXC__Dispatch_Timezone__c, SVMXC__Invoice_Scope__c, SVMXC__Tertiary_Consolidation_Rule_Case__c, SVMXC__Secondary_Consolidation_Rule_Case__c, SVMXC__Process2__c, SVMXC__Process3__c, SVMXC__Submodule__c from SVMXC__ServiceMax_Processes__c where id =: recordId and RecordTypeId =: woBilProcess_Rtype.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                system.debug(logginglevel.WARN,'Retrive existing process : '+woBillingProcess);
                
                if(woBillingProcess != null)
                {
                    selectedExp = woBillingProcess.SVMXC__Module__c;
                    strSCtoInvocObjMap = woBillingProcess.SVMXC__Node_Parent__c;
                    strSCtoInvocDtlObjMap = woBillingProcess.SVMXC__Process__c;
                    strWDtoInvocLinesObjMap = woBillingProcess.SVMXC__Process1__c;
                    selectedExp_Case = woBillingProcess.SVMXC__Submodule__c;
                    strCasetoInvocDtlObjMap = woBillingProcess.SVMXC__Process2__c;
                    strCLtoInvocLinesObjMap = woBillingProcess.SVMXC__Process3__c;

                    if(woBillingProcess.SVMXC__Primary_Consolidation_Rule__c == 'Per Record' || woBillingProcess.SVMXC__Primary_Consolidation_Rule__c == 'Work Order')
                        isConsolidate = false;
                    else
                        isConsolidate = true;
                    
                    if(woBillingProcess.SVMXC__IsStandard__c == true)
                        disabled = true;
                    if(isConsolidate)
                    {
                        disableWOFldLst2 = false;
                        if(woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c != null)
                            disableWOFldLst3 = false;
                        if(woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c != null)
                            disableCaseFldLst3 = false;
                    }

                    woFldLst3 = new List<SelectOption>();
                    for(SelectOption so: woFldLst2)
                    {
                        if((woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c != null || woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c != getTAG009()) && so.getValue() == woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c)
                            continue;
                        woFldLst3.add(so);
                    }
                    
                    CaseFldLst3 = new List<SelectOption>();
                    for(SelectOption so: CaseFldLst2)
                    {
                        if((woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c != null || woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c != getTAG009()) && so.getValue() == woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c)
                            continue;
                        CaseFldLst3.add(so);
                    }
                    
                    if(woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c == null)
                        woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = getTAG009();
                    if(woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c == null)
                        woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = getTAG009();   
                    
                    if(selectedExp != getTAG009() && selectedExp != null)
                    {
                        onChngExp();
                    }
                    if(selectedExp_Case != getTAG009() && selectedExp_Case != null)
                    {
                        onChngExp_Case();
                    }
                    
                    lstSrcUpdates = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: expSrcUpdate_Rtype.Id and SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE' and SVMXC__Dispatch_Process__c =: woBillingProcess.Id Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    if(lstSrcUpdates != null)
                    {
                        if(lstSrcUpdates.size() == 0)
                        {
                            srcUpdateHdrADDRow();
                            srcUpdateHdrADDRow();
                        }
                        else
                        {
                            srcUpdateHdrSize = lstSrcUpdates.size();
                            for(SVMXC__ServiceMax_Config_Data__c conf: lstSrcUpdates)
                                map_SeqNumsrcUpdate.put(Math.Round(Integer.valueOf( conf.SVMXC__Sequence__c )), conf);
                        }
                    }
                    else
                    {
                        srcUpdateHdrADDRow();
                        srcUpdateHdrADDRow();
                    }
                    
                    lstSrcUpdates_Case = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: expSrcUpdate_Rtype.Id and SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE_CASE' and SVMXC__Dispatch_Process__c =: woBillingProcess.Id Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lstSrcUpdates_Case != null)
                    {
                        if(lstSrcUpdates_Case.size() == 0)
                        {
                            srcUpdateHdrADDRow_Case();
                            srcUpdateHdrADDRow_Case();
                        }
                        else
                        {
                            srcUpdateHdrSize_Case = lstSrcUpdates_Case.size();
                            for(SVMXC__ServiceMax_Config_Data__c conf: lstSrcUpdates_Case)
                                map_SeqNumsrcUpdate_Case.put(Math.Round(Integer.valueOf( conf.SVMXC__Sequence__c )), conf);
                        }
                    
                    }
                    else
                    {
                        srcUpdateHdrADDRow_Case();
                        srcUpdateHdrADDRow_Case();
                    }
                    
                    lstSchedules = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c ,SVMXC__Run_Type__c,SVMXC__Day_to_Run__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: schedule_Rtype.Id and SVMXC__Dispatch_Process__c =: woBillingProcess.Id Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    system.debug('Testing log 4');
                    
                    
                    
                    if(lstSchedules == null || lstSchedules.size() == 0)
                        lstSchedules_AddRow();
                }
            }
            else
            {
                woBillingProcess = new SVMXC__ServiceMax_Processes__c();                
                srcUpdateHdrADDRow();
                srcUpdateHdrADDRow();
                srcUpdateHdrADDRow_Case();
                srcUpdateHdrADDRow_Case();
                
                lstSchedules_AddRow();
                woBillingProcess.SVMXC__Active__c = true;
                setDefaultValues(); 
                System.debug('is Case avilable : '+mapObject.containsKey('Case'));
                if(mapObject != null && mapObject.containsKey('Case'))
                    isCaseAvilabel = true;
            }
            mapObject.clear();
            if(mode == 'Clone')
            {
                SVMXC__ServiceMax_Processes__c tempProcess = new SVMXC__ServiceMax_Processes__c();
                tempProcess = woBillingProcess.clone(false, true, false, false);
                woBillingProcess = new SVMXC__ServiceMax_Processes__c();
                woBillingProcess = tempProcess.clone(false, true, false, false);
                woBillingProcess.RecordTypeId = woBilProcess_Rtype.Id;
                woBillingProcess.SVMXC__IsStandard__c = false;
                tempProcess = new SVMXC__ServiceMax_Processes__c();
                
                disabled = false;
                List<SVMXC__ServiceMax_Config_Data__c> tempLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                tempLst.addAll(lstSrcUpdates);
                lstSrcUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
                for(SVMXC__ServiceMax_Config_Data__c CD : tempLst)
                {
                    SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
                    confData.SVMXC__Sequence__c = CD.SVMXC__Sequence__c;
                    confData.SVMXC__Target_Field_Name__c = CD.SVMXC__Target_Field_Name__c;
                    confData.SVMXC__Display_Value__c = CD.SVMXC__Display_Value__c;
                    confData.SVMXC__Configuration_Type__c = CD.SVMXC__Configuration_Type__c;
                    confData.RecordTypeId = expSrcUpdate_Rtype.Id;
                    lstSrcUpdates.add(confData);
                }
                tempLst.clear();
                
                tempLst.addAll(lstSchedules);
                lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
                for(SVMXC__ServiceMax_Config_Data__c CD : tempLst)
                {
                    SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
                    confData.SVMXC__Sequence__c = CD.SVMXC__Sequence__c;
                    confData.SVMXC__Run_At__c = CD.SVMXC__Run_At__c;
                    confData.SVMXC__Schedule_Days__c = CD.SVMXC__Schedule_Days__c;
                    confData.SVMXC__Run_Type__c = CD.SVMXC__Run_Type__c;
                    confData.SVMXC__Day_to_Run__c = CD.SVMXC__Day_to_Run__c;
                    confData.RecordTypeId = schedule_Rtype.Id;
                    lstSchedules.add(confData);
                }
                // for case invoice
                tempLst.clear();
                tempLst.addAll(lstSrcUpdates_Case);
                lstSrcUpdates_Case = new List<SVMXC__ServiceMax_Config_Data__c>();
                for(SVMXC__ServiceMax_Config_Data__c CD : tempLst)
                {
                    SVMXC__ServiceMax_Config_Data__c confData = new SVMXC__ServiceMax_Config_Data__c();
                    confData.SVMXC__Sequence__c = CD.SVMXC__Sequence__c;
                    confData.SVMXC__Target_Field_Name__c = CD.SVMXC__Target_Field_Name__c;
                    confData.SVMXC__Display_Value__c = CD.SVMXC__Display_Value__c;
                    confData.SVMXC__Configuration_Type__c = CD.SVMXC__Configuration_Type__c;
                    confData.RecordTypeId = expSrcUpdate_Rtype.Id;
                    lstSrcUpdates_Case.add(confData);
                }
                
            }
            system.debug(logginglevel.WARN,'Scope of the process : '+woBillingProcess.SVMXC__Invoice_Scope__c);
            if(woBillingProcess.SVMXC__Invoice_Scope__c == null || woBillingProcess.SVMXC__Invoice_Scope__c == 'Work Order')
            {
                //woBillingProcess.SVMXC__Invoice_Scope__c = 'Work Order';
                isScopeForWO = true;
                isScopeForCase = false;
                isRenderedForCase = false;
                isRenderedForWO = true;

            }else if(woBillingProcess.SVMXC__Invoice_Scope__c == 'Case')
            {
                isScopeForWO = false;
                isScopeForCase = true;
                isRenderedForCase = true;
                isRenderedForWO = false;
            }else
            {
                isScopeForWO = true;
                isScopeForCase = true;
                isRenderedForCase = true;
                isRenderedForWO = true;
            }
        }
        catch(exception ex)
        {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG052()));
        }
    }
    
    //-------------------------------- Method to set Default Values for different Variables ------------------------------------
    public void setDefaultValues()
    {
        isCaseAvilabel = false;
        disableEditLink = true;
        disableEditLink_Case = true;
        renderExpBlock = false;
        renderExpBlock_Case = false;
        validate = true;
        isCreateNewExp = false;
        isCreateNewExp_Case = false;
        disabled = false;
        selectedExp = getTAG009();
        selectedExp_Case = getTAG009();
        woBillingProcess.SVMXC__Include_Product__c = true;
        isConsolidate = false;
        disableWOFldLst2 = true;
        disableWOFldLst3 = true;
        disableCaseFldLst3 = true;
        User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        woBillingProcess.SVMXC__Dispatch_Timezone__c = userTimeZone.TimeZoneSidKey;
        
        operatorSelectLst.clear();
        operatorSelectLst.add(new SelectOption('SVMX.NONE', getTAG009()));
        operatorSelectLst.add(new SelectOption('eq', getTAG060()));
        operatorSelectLst.add(new SelectOption('ne', getTAG061()));
        operatorSelectLst.add(new SelectOption('gt', getTAG062()));
        operatorSelectLst.add(new SelectOption('ge', getTAG063()));
        operatorSelectLst.add(new SelectOption('lt', getTAG064()));
        operatorSelectLst.add(new SelectOption('le', getTAG065()));
        operatorSelectLst.add(new SelectOption('starts', getTAG066()));
        operatorSelectLst.add(new SelectOption('contains', getTAG067()));
        operatorSelectLst.add(new SelectOption('notcontain', getTAG068()));
        operatorSelectLst.add(new SelectOption('in', getTAG069()));
        operatorSelectLst.add(new SelectOption('notin', getTAG070()));
        operatorSelectLst.add(new SelectOption('isnull', getTAG071()));
        operatorSelectLst.add(new SelectOption('isnotnull', getTAG072()));
        
        lstUpdateOperator.clear();
        lstUpdateOperator.add(new SelectOption('Set', getTAG074()));
        lstUpdateOperator.add(new SelectOption('Increase', getTAG075()));
        lstUpdateOperator.add(new SelectOption('Decrease', getTAG076()));
        
        // retrive value maps and field amps
        objMapSCtoInvoiceLst.clear();
        objMapSCtoInvoiceLst.add(new SelectOption(getTAG009(),getTAG009()));
        string ObjMapRtypeId = objMap_Rtype.Id;
        List<SVMXC__ServiceMax_Processes__c> ObjMapSCLst = new List<SVMXC__ServiceMax_Processes__c>();
        ObjMapSCLst = [Select  id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c,   SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Active__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where RecordTypeId =: ObjMapRtypeId AND SVMXC__Source_Object_Name__c = null AND SVMXC__Target_Object_Name__c = 'SVMXC__Proforma_Invoice__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(ObjMapSCLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : ObjMapSCLst)
                objMapSCtoInvoiceLst.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
        }
        objMapSCtoInvoiceLst = sortingSelectOption(objMapSCtoInvoiceLst);
        
        
        objMapSCtoInvoiceDtlLst.clear();
        objMapCasetoInvoiceDtlLst.clear();
        objMapSCtoInvoiceDtlLst.add(new SelectOption(getTAG009(),getTAG009()));
        objMapCasetoInvoiceDtlLst.add(new SelectOption(getTAG009(),getTAG009()));
        ObjMapSCLst.clear();
        ObjMapSCLst = [Select  id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c,   SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Active__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where RecordTypeId =: ObjMapRtypeId AND (SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c' OR SVMXC__Source_Object_Name__c = 'Case') AND SVMXC__Target_Object_Name__c = 'SVMXC__Proforma_Invoice_Detail__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(ObjMapSCLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : ObjMapSCLst)
            {
                if(pro.SVMXC__Source_Object_Name__c == 'SVMXC__Service_Order__c')
                    objMapSCtoInvoiceDtlLst.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
                else
                    objMapCasetoInvoiceDtlLst.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
            }
        }
        objMapSCtoInvoiceDtlLst = sortingSelectOption(objMapSCtoInvoiceDtlLst);
        objMapCasetoInvoiceDtlLst = sortingSelectOption(objMapCasetoInvoiceDtlLst);
        
        objMapWDtoInvoiceLineLst.clear();
        objMapWDtoInvoiceLineLst.add(new SelectOption(getTAG009(),getTAG009()));
        ObjMapSCLst.clear();
        ObjMapSCLst = [Select  id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c,   SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Active__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where RecordTypeId =: ObjMapRtypeId AND SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order_Line__c' AND SVMXC__Target_Object_Name__c = 'SVMXC__Proforma_Invoice_Line__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(ObjMapSCLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : ObjMapSCLst)
            {
                objMapWDtoInvoiceLineLst.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
            }
        }
        objMapWDtoInvoiceLineLst = sortingSelectOption(objMapWDtoInvoiceLineLst);
        
        objMapCLtoInvoiceLineLst.clear();
        objMapCLtoInvoiceLineLst.add(new SelectOption(getTAG009(),getTAG009()));
        ObjMapSCLst.clear();
        ObjMapSCLst = [Select  id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Active__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where RecordTypeId =: ObjMapRtypeId AND SVMXC__Source_Object_Name__c = 'SVMXC__Time_Tracker__c' AND SVMXC__Target_Object_Name__c = 'SVMXC__Proforma_Invoice_Line__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(ObjMapSCLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : ObjMapSCLst)
            {
                objMapCLtoInvoiceLineLst.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
            }
        }
        objMapCLtoInvoiceLineLst = sortingSelectOption(objMapCLtoInvoiceLineLst);
        
    }
    //---------------------------------------- Method execute on change of scope ------------------------------------------------
    public pageReference onChangeScope()
    {
        if(isScopeForWO)
            isRenderedForWO = true;
        else
            isRenderedForWO = false;

        if(isScopeForCase)
            isRenderedForCase = true;
        else
            isRenderedForCase = false;

        return null;
    }
    //---------------------------------------- Method to retrieve All the Record Types -----------------------------------------
    public void retrieveRecordTypes()
    {
        expHdr_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        expDtl_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        expSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        woBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        objMap_Rtype = [select Id from RecordType where Name='Object Mapping'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        WOBilProcess_RtypeID = woBilProcess_Rtype.Id;
    }
    //---------------------------------------Method to retrive fields of the object-----------------------------------------------
    public List<SFM_WrapperDef.fieldProperties> getListFields(String strObject)
    {
        List<SFM_WrapperDef.fieldProperties> fieldProp = new List<SFM_WrapperDef.fieldProperties>();
        SFM_WrapperDef.SFM_Request SFMReq = new SFM_WrapperDef.SFM_Request();
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap strinmap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE', 'EXPRESSION');
        lstStringMap.add(strinmap1);
        SFM_WrapperDef.SFM_StringMap strinmap2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME', strObject);
        lstStringMap.add(strinmap2);
        
        SFMReq.stringMap = lstStringMap;
        
        SFM_GetObjectFieldList newObjToGetFields = new SFM_GetObjectFieldList();
        SFM_WrapperDef.SFM_Response_ObjectFields responseObjFields = newObjToGetFields.getObjectFieldList(SFMReq);
        
        if(responseObjFields.response.success)
        {
            fieldProp = responseObjFields.fields;
        }
        return fieldProp;
    }
    
    //---------------------------------------- Method to retrive Criteria of object---------------------------------------
    public void getCriteria(List<SelectOption> TemplstCriteria, String strObjName)
    {
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.clear();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME',strObjName);
        lstStringMap.add(stringMap1);
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
        
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            TemplstCriteria.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
        TemplstCriteria =  sortingSelectOption(TemplstCriteria);
    }
    //------------------------------ Method for Preparing all the Picklists for the Page ----------------------------------------
    public void preparingPicklists()
    {
        //Defect 013938 (Not to display case field when license is Titanium)
        Boolean isCaseObjAvailable = true;
        COMM_Utils objComm_Utils = new COMM_Utils();
        isCaseObjAvailable = objComm_Utils.SVMX_isObjectLicensed('Case');
        
        woFldLst.clear();
        woFldLst.add(new SelectOption('SVMX.NONE',getTAG009()));
        for(SFM_WrapperDef.fieldProperties fp : getListFields('SVMXC__Service_Order__c'))
        {
            woFldLst.add(new SelectOption(fp.key, fp.value));
        }
        woFldLst = sortingSelectOption(woFldLst);
        
        //getting labels of objects
        if(isCaseObjAvailable)
            strCaseobjLabel = Case.SObjectType.getDescribe().getLabel();
        strWOobjLabel = SVMXC__Service_Order__c.SObjectType.getDescribe().getLabel();
        
        CaseFldLst.clear();
        CaseFldLst.add(new SelectOption('SVMX.NONE',getTAG009()));
        for(SFM_WrapperDef.fieldProperties fp : getListFields('Case'))
        {
            CaseFldLst.add(new SelectOption(fp.key, fp.value));
        }
        CaseFldLst = sortingSelectOption(CaseFldLst);

        lstCriteria.clear();
        lstCriteria.add(new SelectOption(getTAG009(), getTAG009()));
        getCriteria(lstCriteria, 'SVMXC__Service_Order__c');

        lstCriteria_Case.clear();
        lstCriteria_Case.add(new SelectOption(getTAG009(), getTAG009()));
        getCriteria(lstCriteria_Case, 'Case');
        
        woFldLst2 = new List<SelectOption>();
        woFldLst2.add(new SelectOption(getTAG009(),getTAG009()));
        
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        objfieldMap = SVMXC__Service_Order__c.SObjectType.getDescribe().fields.getMap();
        
        
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            
            if(f.getName() != 'CurrencyIsoCode' && f.getName() != 'SVMXC__Company__c')
            {
                //Defect 013938 (Not to display case field when license is Titanium)
                if(String.valueOf(f.getType()).toUpperCase() == 'REFERENCE' && f.getReferenceTo()[0].getDescribe().getName().toUpperCase() == 'CASE' && !isCaseObjAvailable)
                    continue;

                if(f.getType().name().ToUpperCase() != 'TEXTAREA')
                    woFldLst2.add(new SelectOption(f.getName(),f.getLabel()));
                else if(f.getType().name().ToUpperCase() == 'TEXTAREA' && !f.isHtmlFormatted())
                    woFldLst2.add(new SelectOption(f.getName(),f.getLabel()));
            }
        }
        
        woFldLst2 = sortingSelectOption(woFldLst2);
        
        //getting fields for Case
        CaseFldLst2 = new List<SelectOption>();
        CaseFldLst2.add(new SelectOption(getTAG009(),getTAG009()));
        
        objfieldMap.clear();
        if(isCaseObjAvailable)
            objfieldMap = Case.SObjectType.getDescribe().fields.getMap();
        
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            
            if(f.getName() != 'CurrencyIsoCode' && f.getName() != 'Account')
            {
                if(f.getType().name().ToUpperCase() != 'TEXTAREA')
                    CaseFldLst2.add(new SelectOption(f.getName(),f.getLabel()));
                else if(f.getType().name().ToUpperCase() == 'TEXTAREA' && !f.isHtmlFormatted())
                    CaseFldLst2.add(new SelectOption(f.getName(),f.getLabel()));
            }
        }
        CaseFldLst2 = sortingSelectOption(CaseFldLst2);
        Schema.DescribeFieldResult timeZoneinfo =user.TimeZoneSidKey.getDescribe();
        system.debug('List of TimeZones ');
        List<Schema.PicklistEntry> lstallTimezones = timeZoneinfo.getPicklistValues();
        for(Schema.PicklistEntry timeZoneinst: lstallTimezones)
        {
            lstTimeZones.add(new selectOption(timeZoneinst.getValue(),timeZoneinst.getLabel()));
        }       
    }
    
    //------------------------------------- Method to sort the Options of the PickList --------------------------------------------
    public List<SelectOption> sortingSelectOption(List<SelectOption> sortList)
    {
        List<SelectOption> resultList = new List<SelectOption>();
        Map<String,List<SelectOption>> tempLst = new Map<String,List<SelectOption>>();
        for(SelectOption SO:sortList) {
            tempLst.put(SO.getLabel(), new List<SelectOption>()); 
            tempLst.get(SO.getLabel()).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String key:keys) { resultList.addAll(tempLst.get(key)); }
        return resultList;
    }
    
    //--------------------------------- Method for on change of WO Fields --------------------------------------------------
    public void onChngWOFld1()
    {
        //if(disabled == true || woBillingProcess.SVMXC__Primary_Consolidation_Rule__c == 'Per Record')
        if(disabled == true || isConsolidate == false)
        {
            disableWOFldLst2 = true;
            disableWOFldLst3 = true;
            disableCaseFldLst3 = true;
            woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = getTAG009();
            woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = getTAG009();
            woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c = getTAG009();
            woBillingProcess.SVMXC__Tertiary_Consolidation_Rule_Case__c = getTAG009();
        }
        else
        {
            disableWOFldLst2 = false;
        }   
    }
    
    //--------------------------------- Method for on change of Work Order Fields --------------------------------------------------
    public void onChngWOFld2()
    {
        woFldLst3 = new List<SelectOption>();
        if(woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c == getTAG009() || woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c == null)
        {
            disableWOFldLst3 = true;
            woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = getTAG009();
            woFldLst3.add(new selectOption(getTAG009(),getTAG009()));
        }
        else
            disableWOFldLst3 = false;
        System.debug('woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c : '+woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c);
        for(SelectOption so: woFldLst2)
        {
            if((woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c != null || woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c != getTAG009()) && so.getValue() == woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c)
                continue;
            woFldLst3.add(so);
        }
    }
    //--------------------------------- Method for on change of Case Fields --------------------------------------------------
    public void onChngCaseFld2()
    {
        CaseFldLst3 = new List<SelectOption>();
        if(woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c == getTAG009() || woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c == null)
        {
            disableCaseFldLst3 = true;
            woBillingProcess.SVMXC__Tertiary_Consolidation_Rule_Case__c = getTAG009();
            CaseFldLst3.add(new selectOption(getTAG009(),getTAG009()));
        }
        else
            disableCaseFldLst3 = false;
        for(SelectOption so: CaseFldLst2)
        {
            if((woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c != null || woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c != getTAG009()) && so.getValue() == woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c)
                continue;
            CaseFldLst3.add(so);
        }
    }
    
     //--------------------------------- Method for on change of Run Type --------------------------------------------------
    public void Chngruntype()
    {
        
        if(lstSchedules != null && lstSchedules.size()>0)
        {
            for(SVMXC__ServiceMax_Config_Data__c tempconfigdata : lstSchedules)
            {
                if(tempconfigdata.SVMXC__Sequence__c==(intSeqVal))
                {
                    tempconfigdata.SVMXC__Day_to_Run__c = null;
                        tempconfigdata.SVMXC__Schedule_Days__c = null;
                }     
            }
        }
    }
    
    //--------------------------------- Method for Quick Save of the Process --------------------------------------------------
    public void quickSave()
    {
        validate = true;
        validation();
        if(validate == true)
            saveExps();
        if(validate == true)
            saveExps_Case();
        if(validate == true)
        {
            save();
            preparingPicklists();
        }
    }
    
    //--------------------------------- Method for Save and Close of the Process --------------------------------------------------
    public pagereference saveClose()
    {
        validate = true;
        validation();
        if(validate == true)
            saveExps();
        if(validate == true)
            saveExps_Case();
        if(validate == true)
        {
            save();
            String loc = '/apex/CONF_ManagewoBillingProcesses';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else
            return null;
    }
    
    //---------------------------- Method to cancel the changes and going back to the previous page -------------------------
    public pagereference cancel()
    {
        String loc = '/apex/CONF_ManagewoBillingProcesses';
        PageReference pr = new PageReference(loc);
        return pr;
    }
    
    //------------------------------------ Method to Save the Process and Config Data ---------------------------------
    public void save()
    {
        try
        {
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataSrcUpdtToDelet = new List<SVMXC__ServiceMax_Config_Data__c>();
            woBillingProcess.RecordTypeId = woBilProcess_Rtype.Id;

            if(strSCtoInvocObjMap != getTAG009())
                woBillingProcess.SVMXC__Node_Parent__c = strSCtoInvocObjMap;
            else
                woBillingProcess.SVMXC__Node_Parent__c = null;   

            if(isScopeForWO)
            {
                if(selectedExp != getTAG009())
                {
                    woBillingProcess.SVMXC__Module__c = selectedExp;
                    disableEditLink = false;
                }
                else
                    woBillingProcess.SVMXC__Module__c = null;
                
                if(strSCtoInvocDtlObjMap != getTAG009())
                    woBillingProcess.SVMXC__Process__c = strSCtoInvocDtlObjMap;
                else
                    woBillingProcess.SVMXC__Process__c = null;
                    
                if(strWDtoInvocLinesObjMap != getTAG009())
                    woBillingProcess.SVMXC__Process1__c = strWDtoInvocLinesObjMap;
                else
                    woBillingProcess.SVMXC__Process1__c = null;
                
                if(isConsolidate)
                {
                    if(woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c == getTAG009())
                        woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = null;
                    
                    if(woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c == getTAG009())
                        woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = null;
                }
                else
                {
                    woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = null;
                    woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = null;
                }

                System.debug(logginglevel.WARN,'log for save test3: ');
                if(!isScopeForCase)
                {
                    woBillingProcess.SVMXC__Submodule__c = null;
                    woBillingProcess.SVMXC__Process2__c = null;
                    woBillingProcess.SVMXC__Process3__c = null;
                    woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c = null;
                    woBillingProcess.SVMXC__Tertiary_Consolidation_Rule_Case__c = null;
                    
                    disableEditLink_Case = true;
                    renderExpBlock_Case = false;
                    selectedExp_Case = getTAG009();
                    disableCaseFldLst3 = true;
                    strCasetoInvocDtlObjMap = getTAG009();
                    strCLtoInvocLinesObjMap = getTAG009();
                    srcUpdateHdrSize_Case = 0;
                    if(lstSrcUpdates_Case != null && lstSrcUpdates_Case.size()>0)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c configdata : lstSrcUpdates_Case)
                        {
                            if(configdata.Id != null)
                            {
                                lstConfigdataSrcUpdtToDelet.add(configdata);
                            }
                        }
                    }
                    lstSrcUpdates_Case.clear();
                }
            }

            if(isScopeForCase)
            {
                if(selectedExp_Case != getTAG009())
                {
                    woBillingProcess.SVMXC__Submodule__c = selectedExp_Case;
                    disableEditLink_Case = false;
                }
                else
                    woBillingProcess.SVMXC__Submodule__c = null;
                if(strCasetoInvocDtlObjMap != getTAG009())
                    woBillingProcess.SVMXC__Process2__c = strCasetoInvocDtlObjMap;
                else
                    woBillingProcess.SVMXC__Process2__c = null;
                    
                if(strCLtoInvocLinesObjMap != getTAG009())
                    woBillingProcess.SVMXC__Process3__c = strCLtoInvocLinesObjMap;
                else
                    woBillingProcess.SVMXC__Process3__c = null;

                if(isConsolidate)
                {
                    if(woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c == getTAG009())
                    woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c = null;
                    
                    if(woBillingProcess.SVMXC__Tertiary_Consolidation_Rule_Case__c == getTAG009())
                    woBillingProcess.SVMXC__Tertiary_Consolidation_Rule_Case__c = null;
                }
                else
                {
                    woBillingProcess.SVMXC__Secondary_Consolidation_Rule_Case__c = null;
                    woBillingProcess.SVMXC__Tertiary_Consolidation_Rule_Case__c = null;
                }
                if(!isScopeForWO)
                {
                    woBillingProcess.SVMXC__Module__c = null;
                    woBillingProcess.SVMXC__Process__c = null;
                    woBillingProcess.SVMXC__Process1__c = null;
                    woBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = null;
                    woBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = null;
                    disableEditLink = true;
                    renderExpBlock = false;
                    selectedExp = getTAG009();
                    disableWOFldLst3 = true;
                    strSCtoInvocDtlObjMap = getTAG009();
                    strWDtoInvocLinesObjMap = getTAG009();
                    srcUpdateHdrSize = 0;
                    if(lstSrcUpdates != null && lstSrcUpdates.size()>0)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c configdata : lstSrcUpdates)
                        {
                            if(configdata.Id != null)
                            {
                                lstConfigdataSrcUpdtToDelet.add(configdata);
                            }
                        }
                    }
                    lstSrcUpdates.clear();
                }
            }
            if(isScopeForWO == true && isScopeForCase == false)
            {
                woBillingProcess.SVMXC__Invoice_Scope__c = 'Work Order';
            }
            else if(isScopeForWO == false && isScopeForCase == true)
            {
                woBillingProcess.SVMXC__Invoice_Scope__c = 'Case';
            }
            else if(isScopeForWO == true && isScopeForCase == true)
            {
                woBillingProcess.SVMXC__Invoice_Scope__c = 'Work Order and Case Both';
            }
            
            if(isConsolidate)
                woBillingProcess.SVMXC__Primary_Consolidation_Rule__c = 'Account';
            else
                woBillingProcess.SVMXC__Primary_Consolidation_Rule__c = 'Per Record';

            //upsert woBillingProcess;
			if( COMM_SecurityUtils.getInstance().verifyFieldAccess( woBillingProcess, COMM_SecurityUtils.Access.Upsertable ) ) {
				upsert woBillingProcess; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
			} else {
				ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
				return;
			}

            if(lstSchedules_toDelete != null && lstSchedules_toDelete.size() > 0)
                delete lstSchedules_toDelete; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstSchedules_toDelete.clear();
            
            if(lstConfigdataSrcUpdtToDelet != null && lstConfigdataSrcUpdtToDelet.size() > 0)
                delete lstConfigdataSrcUpdtToDelet; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstConfigdataSrcUpdtToDelet.clear();
            
            if(lstSrcUpdates != null && lstSrcUpdates.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : lstSrcUpdates)
                {
                    if(configdata.SVMXC__Target_Field_Name__c != getTAG009() && configdata.SVMXC__Display_Value__c != null && configdata.SVMXC__Target_Field_Name__c != null && configdata.SVMXC__Display_Value__c != '')
                    {
                        configdata.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE';
                        configdata.SVMXC__Dispatch_Process__c = woBillingProcess.Id;
                        configdata.RecordTypeId = expSrcUpdate_Rtype.Id;
                        lstConfigdataToSave.add(configdata);
                    }
                }
            }

            if(lstSrcUpdates_Case != null && lstSrcUpdates_Case.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : lstSrcUpdates_Case)
                {
                    if(configdata.SVMXC__Target_Field_Name__c != getTAG009() && configdata.SVMXC__Display_Value__c != null && configdata.SVMXC__Target_Field_Name__c != null && configdata.SVMXC__Display_Value__c != '')
                    {
                        configdata.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE_CASE';
                        configdata.SVMXC__Dispatch_Process__c = woBillingProcess.Id;
                        configdata.RecordTypeId = expSrcUpdate_Rtype.Id;
                        lstConfigdataToSave.add(configdata);
                    }
                }
            }
            if(lstSchedules != null && lstSchedules.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : lstSchedules)
                {
                    if(configdata.SVMXC__Run_Type__c== getTAG009() ||configdata.SVMXC__Run_Type__c== '')
                        {
                            configdata.SVMXC__Run_Type__c=null;
                            configdata.SVMXC__Schedule_Days__c=null;
                            configdata.SVMXC__Day_to_Run__c=null;
                        }
                    if(configdata.SVMXC__Run_Type__c=='Day of Week')
                    if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c !=getTAG009() && configdata.SVMXC__Schedule_Days__c != null && configdata.SVMXC__Schedule_Days__c != '' && configdata.SVMXC__Schedule_Days__c !=getTAG009() && configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c !=getTAG009())
                    {
                        configdata.SVMXC__Day_to_Run__c=null;
                        configdata.RecordTypeId = Schedule_Rtype.Id;
                        configdata.SVMXC__Dispatch_Process__c = woBillingProcess.Id;
                        lstConfigdataToSave.add(configdata);
                    }
                    if(configdata.SVMXC__Run_Type__c=='Date of Month')
                    if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c !=getTAG009() && configdata.SVMXC__Day_to_Run__c != null && configdata.SVMXC__Day_to_Run__c != '' && configdata.SVMXC__Day_to_Run__c !=getTAG009()  && configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c !=getTAG009())
                    {   configdata.SVMXC__Schedule_Days__c=null;
                        configdata.RecordTypeId = Schedule_Rtype.Id;
                        configdata.SVMXC__Dispatch_Process__c = woBillingProcess.Id;
                        lstConfigdataToSave.add(configdata);
                    }
                }
            }

            if(lstConfigdataToSave != null && lstConfigdataToSave.size() > 0)
                upsert lstConfigdataToSave; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,getTAG088(),''));
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG056(),''));
        }
    }
    
    //------------------------------------- Method for the validations on the Page ----------------------------------
    public void validation()
    {
        if(woBillingProcess.SVMXC__Name__c == null || woBillingProcess.SVMXC__Name__c == '')
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG053(),''));
        }
        if(woBillingProcess.SVMXC__ProcessID__c == null || woBillingProcess.SVMXC__ProcessID__c == '')
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG054(),''));
        }
        else if(woBillingProcess.SVMXC__ProcessID__c.length() < 8)
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG055(),''));
        }
        if(isScopeForWO == false && isScopeForCase == false)
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG110(),''));
        }
        
        List<SVMXC__ServiceMax_Processes__c> LstToCheckId = new List<SVMXC__ServiceMax_Processes__c>();
        String UniqueProcessId = woBillingProcess.SVMXC__ProcessID__c;
        string WOID;
        if(woBillingProcess.get('Id') == null)
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId and RecordTypeId =: WOBilProcess_RtypeID');
        else
        {
            WOID = woBillingProcess.Id;
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId and RecordTypeId =: WOBilProcess_RtypeID AND Id !=: WOID');
        }
        
        if(LstToCheckId != null && LstToCheckId.size() > 0)
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG055(),''));
        }
        
        //---------------------------------------------- Validation for the Schedules -----------------------------------------------------------
        if(lstSchedules != null && lstSchedules.size()>0)
        {
            for(SVMXC__ServiceMax_Config_Data__c configdata : lstSchedules)
            {
                if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c !=getTAG009()) 
                {
                    if(configdata.SVMXC__Run_Type__c ==getTAG009() || configdata.SVMXC__Run_Type__c == null || configdata.SVMXC__Run_Type__c == '' )
                    {
                        validate=false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG089()));
                    }
                    if(configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c !=getTAG009())
                    {
                         if(configdata.SVMXC__Run_Type__c=='Day of Week')
                            if(configdata.SVMXC__Schedule_Days__c == null || configdata.SVMXC__Schedule_Days__c == '' || configdata.SVMXC__Schedule_Days__c ==getTAG009()) 
                            {
                                validate=false;
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG089()));
                            }
                          if(configdata.SVMXC__Run_Type__c=='Date of Month')
                            if(configdata.SVMXC__Day_to_Run__c == null || configdata.SVMXC__Day_to_Run__c == '' || configdata.SVMXC__Day_to_Run__c ==getTAG009())
                            {
                                validate=false;
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG089()));
                            }
                    }
                }
            }
        }
        
        Set<String> setAllRunAtRec = new Set<String>();
        for(SVMXC__ServiceMax_Config_Data__c ScheduleRec :lstSchedules)
        {
            if(ScheduleRec.SVMXC__Run_Type__c == 'Day of Week')
            {   
                list<string> strFinal = new list<string>();
                if(ScheduleRec.SVMXC__Schedule_Days__c != null)
                strFinal = ScheduleRec.SVMXC__Schedule_Days__c.split(';',7);
                for(string str: strFinal)
                {
                    if(setAllRunAtRec.contains(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + str))
                    {
                        validate=false;
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG083()+ ' ' + ScheduleRec.SVMXC__Run_At__c));
                        break;
                    }
                    else
                        setAllRunAtRec.add(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + str);
                }
            }
            else
            {
                if(setAllRunAtRec.contains(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + ScheduleRec.SVMXC__Day_to_Run__c))
                {
                    validate=false;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG083()+ ' ' + ScheduleRec.SVMXC__Run_At__c));
                    break;
                }
                else
                    setAllRunAtRec.add(ScheduleRec.SVMXC__Run_At__c + ':' + ScheduleRec.SVMXC__Run_Type__c + ':' + ScheduleRec.SVMXC__Day_to_Run__c);
            }
        }
    }
    
    //------------------------------------- Method to save the Expressions ----------------------------------
    public void saveExps()
    {
        if(woBillingProcess.SVMXC__Invoice_Scope__c == 'Work Order' || woBillingProcess.SVMXC__Invoice_Scope__c == 'Work Order and Case Both' )
        {
            APL_Utils APLUtilObj = new APL_Utils();
            if(expWO != null && expWO.namedExpression.SVMXC__IsStandard__c != true && ((selectedExp != getTAG009() && selectedExp != null) || isCreateNewExp == true))
            {
                for(integer i=0; i < expWO.expressionDetails.size(); i++)
                    expWO.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__Service_Order__c';
                expWO.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(expWO.expressionDetails);
                exp = expWO;
                detailSize = expDetailSize;
                submitExp();
                if(validate == true)
                    selectedExp = expWO.namedExpression.Id;
            }
        }
    }
    // save expression for case
    public void saveExps_Case()
    {
        if(woBillingProcess.SVMXC__Invoice_Scope__c == 'Case' || woBillingProcess.SVMXC__Invoice_Scope__c == 'Work Order and Case Both' )
        {
            APL_Utils APLUtilObj = new APL_Utils();
            if(exp_Case != null && exp_Case.namedExpression.SVMXC__IsStandard__c != true && ((selectedExp_Case != getTAG009() && selectedExp_Case != null) || isCreateNewExp_Case == true))
            {
                for(integer i=0; i < exp_Case.expressionDetails.size(); i++)
                    exp_Case.expressionDetails[i].SVMXC__Object_Name2__c = 'Case';
                exp_Case.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(exp_Case.expressionDetails);
                exp = exp_Case;
                system.debug('expDetailSize_Case log 1:'+expDetailSize_Case);
                detailSize = expDetailSize_Case;
                system.debug('detailSize log 1:'+detailSize);
                submitExp();
                if(validate == true)
                    selectedExp_Case = exp_Case.namedExpression.Id;
            }
        }
    }
    
    public String savedExpressionResultId;
    public String getsavedExpressionResultId() { return savedExpressionResultId;}
    public void setsavedExpressionResultId(String val){this.savedExpressionResultId = val;}
    
    //------------------------------------------------Method to save One Expression----------------------------------------------------------------------
    public void submitExp()
    {
        if(exp.namedExpression != null && exp.namedExpression.SVMXC__Name__c != null && (exp.namedExpression.SVMXC__Name__c).length() > 0 &&  exp.namedExpression.SVMXC__ProcessID__c != null && (exp.namedExpression.SVMXC__ProcessID__c).length() > 0 )
        {
            SFM_WrapperDef.SFM_Response Save_Response = new SFM_WrapperDef.SFM_Response();
            try
            {
                exp.namedExpression.SVMXC__SettingId__c = exp.namedExpression.SVMXC__ProcessID__c;
                List<SVMXC__ServiceMax_Config_Data__c> ExpressionDetails2Save = new List<SVMXC__ServiceMax_Config_Data__c>(); 
                for(SVMXC__ServiceMax_Config_Data__c expressiondtlRec :exp.expressionDetails)
                {
                    if(expressiondtlRec.SVMXC__Operator__c != null && expressiondtlRec.SVMXC__Operator__c != 'SVMX.NONE' && expressiondtlRec.SVMXC__Field_Name__c != 'None' && expressiondtlRec.SVMXC__Field_Name__c != 'SVMX.NONE')
                    ExpressionDetails2Save.add(expressiondtlRec);
                }
                exp.expressionDetails.clear();
                if(ExpressionDetails2Save.size()>0)
                    exp.expressionDetails.addAll(ExpressionDetails2Save);
                    system.debug('Detail size before check: '+detailSize);
                detailSize = Math.Round(exp.expressionDetails.size());
                system.debug('Detail size after check: '+detailSize);
                
                if(detailSize >0)
                {
                    SFM_WrapperDef.SFM_Expression oSFM_Exp = new SFM_WrapperDef.SFM_Expression(exp.namedExpression,exp.expressionDetails);
                    List<SFM_WrapperDef.SFM_Expression> LstSFM_Exp = new List<SFM_WrapperDef.SFM_Expression>();
                    LstSFM_Exp.add(oSFM_Exp);
                    SFM_WrapperDef.SFM_Request_Expression oRequest = new SFM_WrapperDef.SFM_Request_Expression(LstSFM_Exp);
                    SVMXC.SFM_saveExpression saveExp = new SVMXC.SFM_saveExpression();
                    Save_Response = saveExp.SFM_saveExpression(oRequest);
                    
                    if( Save_Response != null && Save_Response.success != null)
                    {
                        if(Boolean.valueOf(Save_Response.success))
                        {
                            if( Save_Response.resultIds != null && Save_Response.resultIds.size() > 0 )
                            {
                                savedExpressionResultId = Save_Response.resultIds[0];
                                setsavedExpressionResultId(Save_Response.resultIds[0]);
                            }
                        }
                        else
                        {
                            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, '' + Save_Response.message ));
                            validate = false;
                            HdrADDRow();
                            HdrADDRow();
                        }
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG056()));
                        validate = false;
                    }
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, getTAG057()));
                    validate = false;
                    HdrADDRow();
                    HdrADDRow();
                }   
            }
            catch(Exception ex)
            {
                if( Save_Response != null && Save_Response.message != null && Save_Response.success == false )
                {
                    ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, ''+Save_Response.message + ': ' + ex.getmessage()));
                    validate = false;
                }
            }
        }
        else
        {
            if( exp.namedExpression == null || exp.namedExpression.SVMXC__Name__c == null || exp.namedExpression.SVMXC__Name__c == '' || (exp.namedExpression.SVMXC__Name__c).length() == 0 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG058()));
                validate = false;
            }
            if( exp.namedExpression == null || exp.namedExpression.SVMXC__ProcessID__c == null || exp.namedExpression.SVMXC__ProcessID__c == '' || (exp.namedExpression.SVMXC__ProcessID__c).length() == 0 )
            {
                ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, getTAG059()));
                validate = false;
            }
        }
    }
    
    //----------------------------------------- Method to retrieve Expression Details ---------------------------------------------
    public SFM_WrapperDef.SFM_Response_Expression retrieveExpDetails(string expId)
    {
        SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
        SFM_WrapperDef.SFM_StringMap stringMap3 = new SFM_WrapperDef.SFM_StringMap('EXPRESSIONID',expId);
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        lstStringMap.add(stringMap3);
        SFM_WrapperDef.SFM_Request request2 = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        responseExp = namedExpLst.SFM_getNamedExpressionList(request2);
        return responseExp;
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Initiate Return Parent --------------------------------
    public void onChngExp()
    {
        isCreateNewExp = false;
        renderExpBlock = false;
        if(selectedExp != getTAG009())
        {
            disableEditLink = false;
            responseExp = retrieveExpDetails(selectedExp);
            if(responseExp.expressions.size() > 0)
            {
                expWO = responseExp.expressions[0];
                expDetailSize = expWO.expressionDetails.size();
                map_SeqNumRecExp.clear();
                if(expWO.expressionDetails != null && expWO.expressionDetails.size() >0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c confData : expWO.expressionDetails)
                    {
                        map_SeqNumRecExp.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                    }
                }
            }
        }
        else
            disableEditLink = true;
    }
    
    //------------------------- On Change of Picklist Value of Existing Criteria of Initiate Return Parent for Case --------------------------------
    public void onChngExp_Case()
    {
        isCreateNewExp_Case = false;
        renderExpBlock_Case = false;
        if(selectedExp_Case != getTAG009())
        {
            disableEditLink_Case = false;
            responseExp = retrieveExpDetails(selectedExp_Case);
            if(responseExp.expressions.size() > 0)
            {
                exp_Case = responseExp.expressions[0];
                expDetailSize_Case = exp_Case.expressionDetails.size();
                system.debug('expDetailSize_Case : '+expDetailSize_Case);
                map_SeqNumRecExp_Case.clear();
                if(exp_Case.expressionDetails != null && exp_Case.expressionDetails.size() >0)
                {
                    for(SVMXC__ServiceMax_Config_Data__c confData : exp_Case.expressionDetails)
                    {
                        map_SeqNumRecExp_Case.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                    }
                }
            }
        }
        else
            disableEditLink_Case = true;
    }
    
    //----------------------------------------- View/Edit of Initiate Return Parent ---------------------------------------------
    public void EditExp()
    {
        renderExpBlock = true;
    }
    
    public void EditExp_Case()
    {
        renderExpBlock_Case = true;
    }
    
    //----------------------------------------- New Criteria of Initiate Return Parent ---------------------------------------------
    public void NewExp()
    {
        isCreateNewExp = true;
        selectedExp = getTAG009();
        disableEditLink = true;
        renderExpBlock = true;
        expWO = new SFM_WrapperDef.SFM_Expression();
        expWO.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = expHdr_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c');
        expWO.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(expWO.expressionDetails != null)
            expDetailSize = expWO.expressionDetails.size();
        else
            expDetailSize = 0;
        exp = expWO;
        detailSize = expDetailSize;
        map_SeqNumRec.clear();
        if(map_SeqNumRecExp.size() > 0)
            map_SeqNumRec.putAll(map_SeqNumRecExp);
        HdrADDRow();
        HdrADDRow();
        expWO = exp;
        expDetailSize = detailSize;
        map_SeqNumRecExp.clear();
        map_SeqNumRecExp.putAll(map_SeqNumRec);
    }
    
    public void NewExp_Case()
    {
        isCreateNewExp_Case = true;
        selectedExp_Case = getTAG009();
        disableEditLink_Case = true;
        renderExpBlock_Case = true;
        exp_Case = new SFM_WrapperDef.SFM_Expression();
        exp_Case.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = expHdr_Rtype.Id, SVMXC__Source_Object_Name__c = 'Case');
        exp_Case.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(exp_Case.expressionDetails != null)
            expDetailSize_Case = exp_Case.expressionDetails.size();
        else
            expDetailSize_Case = 0;
        exp = exp_Case;
        detailSize = expDetailSize_Case;
        map_SeqNumRec.clear();
        if(map_SeqNumRecExp_Case.size() > 0)
            map_SeqNumRec.putAll(map_SeqNumRecExp_Case);
        HdrADDRow();
        HdrADDRow();
        exp_Case = exp;
        expDetailSize_Case = detailSize;
        map_SeqNumRecExp_Case.clear();
        map_SeqNumRecExp_Case.putAll(map_SeqNumRec);
        System.debug('ADDD new row on case exp : '+map_SeqNumRecExp_Case);
    }
    
    
    //----------------------------------------- Delete Row in the Initiate Return ---------------------------------------------
    public PageReference HdrDeleteRowExp()
    {
        exp = expWO;
        detailSize = expDetailSize;
        map_SeqNumRec.clear();
        map_SeqNumRec.putAll(map_SeqNumRecExp);
        HdrDeleteRow();
        map_SeqNumRecExp.clear();
        map_SeqNumRecExp.putAll(map_SeqNumRec);
        expDetailSize = detailSize;
        expWO = exp;
        return null;
    }
    
    public PageReference HdrDeleteRowExp_Case()
    {
        exp = exp_Case;
        detailSize = expDetailSize_Case;
        map_SeqNumRec.clear();
        map_SeqNumRec.putAll(map_SeqNumRecExp_Case);
        HdrDeleteRow();
        map_SeqNumRecExp_Case.clear();
        map_SeqNumRecExp_Case.putAll(map_SeqNumRec);
        expDetailSize_Case = detailSize;
        exp_Case = exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Initiate Return ---------------------------------------------
    public PageReference HdrADDRowExp()
    {
        exp = expWO;
        detailSize = expDetailSize;
        map_SeqNumRec.clear();
        if(map_SeqNumRecExp.size() > 0)
            map_SeqNumRec.putAll(map_SeqNumRecExp);
        HdrADDRow();
        expDetailSize = detailSize;
        map_SeqNumRecExp.clear();
        map_SeqNumRecExp.putAll(map_SeqNumRec);
        expWO = exp;
        return null;
    }
    
    public PageReference HdrADDRowExp_Case()
    {
        exp = exp_Case;
        detailSize = expDetailSize_Case;
        map_SeqNumRec.clear();
        if(map_SeqNumRecExp_Case.size() > 0)
            map_SeqNumRec.putAll(map_SeqNumRecExp_Case);
        HdrADDRow();
        expDetailSize_Case = detailSize;
        map_SeqNumRecExp_Case.clear();
        map_SeqNumRecExp_Case.putAll(map_SeqNumRec);
        exp_Case = exp;
        return null;
    }
    
    
    //-------------------------------------- Methods to add row of Expression details -------------------------------------------------------
    public void HdrADDRow()
    {
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = expDtl_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( exp.expressionDetails.size() + 1 ) );
            map_SeqNumRec.put( Math.Round(Integer.valueOf( exp.expressionDetails.size() + 1 )), NewExpDetailRec );
            exp.expressionDetails.add( NewExpDetailRec );
            if(exp.expressionDetails != null)
                detailSize = exp.expressionDetails.size();
            else
                detailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }

    //---------------------------- Methods to delete row of Expression details ------------------------------------------
    public void HdrDeleteRow()
    {
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SeqNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < exp.expressionDetails.size(); i++ )
            {
                if( map_SeqNumRec != null && map_SeqNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(DelIndex) )
                    TempMap_SeqNumRec.put( i + 1 - SeqNumToSubtract, exp.expressionDetails[i] );
                else if ( map_SeqNumRec != null && map_SeqNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(DelIndex)) )  
                    SeqNumToSubtract = 1;
            }
            map_SeqNumRec.clear();
            if( TempMap_SeqNumRec != null )
                map_SeqNumRec.putAll(TempMap_SeqNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :map_SeqNumRec.keyset())
            {
                SequenceCounter++;
                if( map_SeqNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = map_SeqNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            exp.expressionDetails.clear();
            exp.expressionDetails.addAll(Temp_ExpDetailsLst);
            if(exp.expressionDetails != null)
                detailSize = exp.expressionDetails.size();
            else
                detailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    
    
    //----------------------------------------- Delete Row in the Source Updates ---------------------------------------------
    public PageReference srcUpdateHdrDeleteRow()
    {
        lstExp = lstSrcUpdates;
        detailSize = srcUpdateHdrSize;
        map_SeqNumRec.clear();
        map_SeqNumRec.putAll(map_SeqNumsrcUpdate);
        SrcUpdateDeleteRow();
        map_SeqNumsrcUpdate.clear();
        map_SeqNumsrcUpdate.putAll(map_SeqNumRec);
        srcUpdateHdrSize = detailSize;
        lstSrcUpdates = lstExp;
        return null;
    }
    
    public PageReference srcUpdateHdrDeleteRow_Case()
    {
        lstExp = lstSrcUpdates_Case;
        detailSize = srcUpdateHdrSize_Case;
        map_SeqNumRec.clear();
        map_SeqNumRec.putAll(map_SeqNumsrcUpdate_Case);
        SrcUpdateDeleteRow();
        map_SeqNumsrcUpdate_Case.clear();
        map_SeqNumsrcUpdate_Case.putAll(map_SeqNumRec);
        srcUpdateHdrSize_Case = detailSize;
        lstSrcUpdates_Case = lstExp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Source Updates ---------------------------------------------
    public PageReference srcUpdateHdrADDRow()
    {
        lstExp = lstSrcUpdates;
        detailSize = srcUpdateHdrSize;
        map_SeqNumRec.clear();
        if(map_SeqNumsrcUpdate.size() > 0)
            map_SeqNumRec.putAll(map_SeqNumsrcUpdate);
        SrcUpdateADDRow();
        srcUpdateHdrSize = detailSize;
        map_SeqNumsrcUpdate.clear();
        map_SeqNumsrcUpdate.putAll(map_SeqNumRec);
        lstSrcUpdates = lstExp;
        return null;
    }
    
    public PageReference srcUpdateHdrADDRow_Case()
    {
        lstExp = lstSrcUpdates_Case;
        detailSize = srcUpdateHdrSize_Case;
        map_SeqNumRec.clear();
        if(map_SeqNumsrcUpdate_Case.size() > 0)
            map_SeqNumRec.putAll(map_SeqNumsrcUpdate_Case);
        SrcUpdateADDRow();
        srcUpdateHdrSize_Case = detailSize;
        map_SeqNumsrcUpdate_Case.clear();
        map_SeqNumsrcUpdate_Case.putAll(map_SeqNumRec);
        lstSrcUpdates_Case = lstExp;
        return null;
    }
    
    //--------------------------------------Methods to add row of Source Update-------------------------------------------------------
    public void SrcUpdateADDRow()
    {
        try
        {
            SVMXC__ServiceMax_Config_Data__c NewExpDetailRec = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = expSrcUpdate_Rtype.Id, SVMXC__Sequence__c = Integer.valueOf( lstExp.size() + 1 ) );
            map_SeqNumRec.put( Math.Round(Integer.valueOf( lstExp.size() + 1 )), NewExpDetailRec );
            lstExp.add( NewExpDetailRec );
            if(lstExp != null)
                detailSize = lstExp.size();
            else
                detailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //--------------------------------------Methods to delete row of Source Update-------------------------------------------------------
    public void SrcUpdateDeleteRow()
    {
        try
        {
            Map<Integer, SVMXC__ServiceMax_Config_Data__c> TempMap_SeqNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
            List<SVMXC__ServiceMax_Config_Data__c> Temp_ExpDetailsLst = new List<SVMXC__ServiceMax_Config_Data__c>();
            Integer SeqNumToSubtract = 0;
            
            for( integer i=0; i < lstExp.size(); i++ )
            {
                if( map_SeqNumRec != null && map_SeqNumRec.get(i + 1) != null && (i + 1) != integer.valueOf(DelIndex) )
                    TempMap_SeqNumRec.put( i + 1 - SeqNumToSubtract, lstExp[i] );
                else if ( map_SeqNumRec != null && map_SeqNumRec.get(i + 1) != null && ( (i + 1) == integer.valueOf(DelIndex)) )
                {
                    SeqNumToSubtract = 1;
                    if(lstExp[i].get('id') != null)
                        lstSchedules_toDelete.add(lstExp[i]);
                }
            }
            map_SeqNumRec.clear();
            if( TempMap_SeqNumRec != null )
                map_SeqNumRec.putAll(TempMap_SeqNumRec);
            
            Integer SequenceCounter = 0;
            for(integer SequenceNumber :map_SeqNumRec.keyset())
            {
                SequenceCounter++;
                if( map_SeqNumRec.get(SequenceNumber) != null )
                {
                    SVMXC__ServiceMax_Config_Data__c TempDetailExprObj = new SVMXC__ServiceMax_Config_Data__c();
                    TempDetailExprObj = map_SeqNumRec.get(SequenceNumber);
                    TempDetailExprObj.SVMXC__Sequence__c = SequenceCounter;
                    Temp_ExpDetailsLst.add(TempDetailExprObj);
                }
            }
            lstExp.clear();
            lstExp.addAll(Temp_ExpDetailsLst);
            if(lstExp != null)
                detailSize = lstExp.size();
            else
                detailSize = 0;
        }
        catch(exception ex)
        {
            AddException(ex.getMessage());
        }
    }
    
    //------------------------------------- Method to add new row for the schedules ----------------------------------
    public pagereference lstSchedules_AddRow()
    {
       lstSchedules.add(new SVMXC__ServiceMax_Config_Data__c(RecordTypeId = Schedule_Rtype.Id,SVMXC__Run_Type__c='Day of Week', SVMXC__Sequence__c = lstSchedules.size() + 1 ));
        return null;
    }
    
    //------------------------------------- Method to delete row for the schedules ----------------------------------
    public pagereference lstSchedules_DelRow()
    {
        if(lstSchedules == null || (lstSchedules != null && !(lstSchedules.size() > 0)))
            return null;
        Integer tempDeletedIndex = Integer.valueOf(selectedRow) - 1;
        if(lstSchedules[tempDeletedIndex] != null && lstSchedules[tempDeletedIndex].get('Id') != null)
            lstSchedules_toDelete.add(lstSchedules[tempDeletedIndex]);
        lstSchedules.remove(tempDeletedIndex);
        for(integer i=0; i< lstSchedules.size(); i++)
            lstSchedules[i].SVMXC__Sequence__c = i + 1;
        return null;
    }
    
    //-----------------------------------------------Method to validate string --------------------------------------------------------
    public boolean IsValidString(String str)
    {
        if (str != null && str != '' && str.length() > 0)
            return true;
        else
            return false;
    }
    
    //--------------------------------------------- Method to display exceptions ------------------------------------------------------
    public void AddException(String strErrorMessage)
    {
        if(isValidString(strErrorMessage))
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, strErrorMessage));
        else
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, ''));
    }
    
    //------------------------------------- Methods To Switch Between Tabs -----------------------------------------   
    public void GeneralInfo()
    {
        selectedTab = 'TAB1';
    }
    public void ConsolidationRule()
    {
        selectedTab = 'TAB2';
    }
    public void MappingRules()
    {
        selectedTab = 'TAB3';
    }
    public void SrcUpd()
    {
        selectedTab = 'TAB4';
    }
    public void Schedules()
    {
        selectedTab = 'TAB5';
    }
    
    //------------------------------------- Getter methods for the custom labels ----------------------------------
    public string getHLPURL(){return system.label.CONF035_HLPURL;} // 
    public string getHLPTITLE(){return system.label.COMM001_TAG064;} // 'Help'
    public string getTAG002(){return system.label.COMM001_TAG053;} // 'Quick Save'
    public string getTAG003(){return system.label.COMM001_TAG054;} // 'Save & Close'
    public string getTAG004(){return system.label.COMM001_TAG040;} // 'Cancel'
    public string getTAG009(){return system.label.COMM002_TAG005;} // '--None--'
    public string getTAG010(){return system.label.COMM001_TAG055;} // 'Process Name'
    public string getTAG011(){return system.label.COMM001_TAG056;} // 'Process Id'
    public string getTAG012(){return system.label.COMM001_TAG017;} // 'Description'
    public string getTAG017(){return system.label.COMM001_TAG041;} // 'Processing...'
    public string getTAG018(){return system.label.COMM002_TAG025;} // 'Expression Name'
    public string getTAG019(){return system.label.COMM002_TAG026;} // 'Expression ID'
    public string getTAG020(){return system.label.COMM002_TAG027;} // 'Field Name'
    public string getTAG021(){return system.label.COMM002_TAG028;} // 'Operator'
    public string getTAG022(){return system.label.COMM002_TAG029;} // 'Value'
    public string getTAG023(){return system.label.COMM002_TAG032;} // 'Add Row'
    public string getTAG024(){return system.label.COMM002_TAG033;} // 'Delete Row'
    public string getTAG025(){return system.label.COMM002_TAG024;} // 'Advanced Expression'
    public String getTAG057(){return system.label.COMM002_TAG004;} //'Invalid expression'
    public String getTAG060(){return system.label.COMM002_TAG006;} // Equals
    public String getTAG061(){return system.label.COMM002_TAG007;} // Not Equal
    public String getTAG062(){return system.label.COMM002_TAG008;} // Greater Than
    public String getTAG063(){return system.label.COMM002_TAG009;} // Greater or Equal To
    public String getTAG064(){return system.label.COMM002_TAG010;} // Less Than
    public String getTAG065(){return system.label.COMM002_TAG011;} // Less or Equal To
    public String getTAG066(){return system.label.COMM002_TAG012;} // Starts With
    public String getTAG067(){return system.label.COMM002_TAG013;} // Contains
    public String getTAG068(){return system.label.COMM002_TAG014;} // Does Not Contain
    public String getTAG069(){return system.label.COMM002_TAG015;} // Includes
    public String getTAG070(){return system.label.COMM002_TAG016;} // Excludes
    public String getTAG071(){return system.label.COMM002_TAG022;} // Is Null
    public String getTAG072(){return system.label.COMM002_TAG023;} // Is Not Null
    public String getTAG074(){return system.label.COMM002_TAG017;} // Set
    public String getTAG075(){return system.label.COMM002_TAG018;} // Increase
    public String getTAG076(){return system.label.COMM002_TAG019;} // Decrease
    public String getTAG088(){return system.label.COMM001_TAG058;} // 'Process saved successfully'
    
    public string getTAG014(){return system.label.COMM002_TAG031;} // 'Use an existing criteria from the list'
    public string getTAG015(){return system.label.COMM002_TAG037;} // 'View/Edit'
    public string getTAG016(){return system.label.COMM002_TAG036;} // 'Or Create a new criteria'
    public String getTAG058(){return system.label.COMM002_TAG034;} // 'Please enter a valid Expression Name.'
    public String getTAG059(){return system.label.COMM002_TAG035;} // 'Expression ID should be atleast 8 characters long.'
    public string getTAG005(){return system.label.COMM001_TAG072;} // 'General Info'
    public string getTAG044(){return system.label.COMM001_TAG078;} // 'Run At(GMT)'
    public string getTAG045(){return system.label.COMM001_TAG079;} // 'On These Days'
    public string getTAG049(){return system.label.COMM001_TAG082;} // 'Send success notifications to this email address'
    public string getTAG050(){return system.label.COMM001_TAG083;} // 'Send error notifications to this email address'
    public string getTAG052(){return system.label.COMM001_TAG084;} // 'Insufficient parameters provided. Please contact to your ServiceMax administrator.'
    public string getTAG053(){return system.label.COMM001_TAG059;} // 'Please enter a Process Name'
    public string getTAG054(){return system.label.COMM001_TAG059;} // 'Please enter a Process ID'
    public string getTAG055(){return system.label.COMM001_TAG085;} //   'Process ID must be unique and at least 8 characters long'
    public String getTAG056(){return system.label.COMM001_TAG077;} //   'An internal error occurred. Please try this operation later. If the problem persists, please contact ServiceMax support for assistance.'
    //public String getTAG082(){return system.label.COMM001_TAG059;} // 'Please enter an email id to notify about the errors'
    public string getTAG006(){return system.label.COMM001_TAG073;} // 'Invoice Rules'
    public string getTAG007(){return system.label.COMM001_TAG074;} // 'Source Updates'
    public string getTAG008(){return system.label.COMM001_TAG075;} // 'Schedule & Notifications'
    
    public string getTAG001(){return system.label.CONF035_TAG003;} // 'Setup Proforma Invoice Processes'
    public string getTAG013(){return system.label.CONF035_TAG004;} // 'Using the expression-builder below, indicate how hearder records qualify for Work Order billing process.'
    public string getTAG027(){return system.label.CONF035_TAG006;} // 'Consolidate'
    public string getTAG028(){return system.label.CONF035_TAG007;} // 'Group Invoice using primary attribute'
    public string getTAG029(){return system.label.CONF035_TAG008;} // 'Group Invoice using secondary attribute'
    public string getTAG030(){return system.label.CONF035_TAG005;} // 'Consolidation rules'
    public string getTAG031(){return system.label.CONF035_TAG009;} // 'Consolidation on Pricing rules'
    public string getTAG032(){return system.label.CONF035_TAG010;} // 'Include Non-Billable Lines'
    public string getTAG033(){return system.label.CONF035_TAG011;} // 'Use the Value Mapping to create Invoice from Work Order'
    public string getTAG034(){return system.label.CONF035_TAG012;} // 'Use the Object Mapping to create Invoice Detail from Work Order'
    public string getTAG038(){return system.label.CONF035_TAG013;} // 'In this section, configure the automatic field updates to be performed in the parent record when Invoice is generated'
    public string getTAG043(){return system.label.CONF035_TAG014;} // 'Choose the times and days to run SC Billing Engine for this process'
    public string getTAG048(){return system.label.COMM001_TAG086;} // 'Specify recipents of notifications and alerts'
    public string getTAG051(){return system.label.COMM001_TAG087;} // 'Enable Logging'
    public String getTAG083(){return system.label.COMM001_TAG088;} // ' has been entered twice in schedule frequency list'
    public String getTAG089(){return system.label.CONF035_TAG015;} // 'Insufficient time and day information to run Work Order Invoice Generation Engine'
    public String getTAG090(){return system.label.COMM001_TAG016;} //'Active'
    public String getTAG091(){return system.label.COMM001_TAG103;} //'Time Zone'
    public String getTAG092(){return system.label.CONF035_TAG016;} //'Use this field-map to create Proforma Invoice Lines from Work Details'
    
    public String getTAG093(){return system.label.CONF035_TAG017;}//'Invoice Scope'
    public string getTAG094(){return system.label.CONF035_TAG018;}//'Using the expression-builder below, indicate how Case qualify for this process'
    //public string getTAG095(){return 'Consolidation Rule';}
    public string getTAG096(){return system.label.CONF035_TAG019;}//'Perform Primary grouping of Proforma Invoice using'
    public string getTAG097(){return system.label.CONF035_TAG020;}//'Primary grouping of Work Order'
    public string getTAG098(){return system.label.CONF035_TAG021;}//'Primary grouping of Case'
    public string getTAG099(){return system.label.CONF035_TAG022;}//'Perform Secondary grouping of Proforma Invoice using'
    public string getTAG100(){return system.label.CONF035_TAG023;}//'Secondary grouping of Work Order'
    public string getTAG101(){return system.label.CONF035_TAG024;}//'Secondary grouping of Case'
    
    public string getTAG102(){return system.label.CONF035_TAG009;}//'Mapping Rules'
    public string getTAG103(){return system.label.CONF035_TAG025;}//'Mapping & Rules to create Performa Invoice for Work Order'
    public string getTAG104(){return system.label.CONF035_TAG026;}//'Mapping & Rules to create Performa Invoice for Case'
    //public string getTAG105(){return 'Include non-billable Case lines';}
    public string getTAG106(){return system.label.CONF035_TAG027;}//'Use this field-map to create Performa Invoice Detail from Case'
    public string getTAG107(){return system.label.CONF035_TAG028;}//'Use this field-map to create Performa Invoice Line from Case Activity'
    public string getTAG108(){return system.label.CONF035_TAG029;}//'Automatic field updates to Case when Proforma Invoice is created'
    //public string getTAG109(){return 'Per Record';}
    public string getTAG110(){return system.label.CONF035_TAG030;}//'Please select Invoice Scope'
}