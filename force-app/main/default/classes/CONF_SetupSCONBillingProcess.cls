public with sharing class CONF_SetupSCONBillingProcess
{
    //-------------------------------------- Variables and Getter-Setter Methods ------------------------------------------------------
    public SVMXC__ServiceMax_Processes__c sconBillingProcess = new SVMXC__ServiceMax_Processes__c();
    public SVMXC__ServiceMax_Processes__c getsconBillingProcess(){return this.sconBillingProcess;}
    public void setsconBillingProcess(SVMXC__ServiceMax_Processes__c proces){this.sconBillingProcess = proces;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSrcUpdates = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSrcUpdates() { return this.lstSrcUpdates;}
    public void setlstSrcUpdates(List<SVMXC__ServiceMax_Config_Data__c> lst) { this.lstSrcUpdates = lst;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSchedules = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSchedules() { return this.lstSchedules;}
    public void setlstSchedules(List<SVMXC__ServiceMax_Config_Data__c> lst) { this.lstSchedules = lst;}
    public List<SVMXC__ServiceMax_Config_Data__c> lstSchedules_toDelete = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__ServiceMax_Config_Data__c> getlstSchedules_toDelete(){return this.lstSchedules_toDelete;}
    public void setlstSchedules_toDelete(List<SVMXC__ServiceMax_Config_Data__c> lst){this.lstSchedules_toDelete = lst;}
    List<SVMXC__ServiceMax_Config_Data__c> lstExp = new List<SVMXC__ServiceMax_Config_Data__c>();
            
    public List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataToSave = new List<SVMXC__ServiceMax_Config_Data__c>();
    
    public Integer lstSchedules_HighSeqNum 
    {
        get{return lstSchedules.size();}
    }
    
    public string recordId;
    public string mode;
    public string processName{get;set;}
    public string processID{get;set;}
    public string processDesc{get;set;}
    public String selectedRow {get; set;}
    
    public boolean disableEditLink{get;set;}
    public boolean disabled{get;set;}
    public boolean validate{get;set;}
    public boolean isCreateNewExp{get;set;}
    public boolean renderExpBlock{get;set;}
    public boolean disableSCONFldLst2{get;set;}
    public boolean disableSCONFldLst3{get;set;}
    public boolean isIncludeNonBillableLines{get;set;}
    public string strSelectedTimeZone{get;set;}
    //public boolean isIncludeSLAPrice{get;set;}
    public boolean isEnableLogging{get;set;}
    public boolean isActive{get;set;}
    public Integer detailSize = 0;
    public integer expDetailSize = 0;
    public integer getExpDetailSize(){return this.expDetailSize;}
    public void setExpDetailSize(integer inte){this.expDetailSize = inte;}
    public integer srcUpdateHdrSize = 0;
    public integer getsrcUpdateHdrSize(){return this.srcUpdateHdrSize;}
    public void setsrcUpdateHdrSize(integer inte){this.srcUpdateHdrSize = inte;}
    public string selectedTab{get;set;}
    public string delIndex{get;set;}
    public string selectedExp{get;set;}
    public string selectedSCONFld1{get;set;}
    public string selectedSCONFld2{get;set;}
    public string selectedSCONFld3{get;set;}
    public string selectedInvoiceFld1{get;set;}
    public string selectedInvoiceFld2{get;set;}
    public string selectedInvoiceFld3{get;set;}
    public string strSCtoInvocObjMap{get;set;}
    public string strSCtoInvocDtlObjMap{get;set;}
    
    public List<SelectOption> lstCriteria = new List<SelectOption>();
    public List<SelectOption> getlstCriteria(){return this.lstCriteria;}
    
    public List<SelectOption> lstUpdateOperator = new List<SelectOption>();
    public List<SelectOption> getlstUpdateOperator(){return this.lstUpdateOperator;} 
    public void setlstUpdateOperator(List<SelectOption> lstField){this.lstUpdateOperator = lstField;}
    
    public List<selectoption> sconFldLst=new List<selectoption>();
    public List<selectoption> getSCONFldLst() {return this.sconFldLst;}
    
    public List<selectoption> sconFldLst1=new List<selectoption>();
    public List<selectoption> getsconFldLst1() {return this.sconFldLst1;}
    public List<selectoption> sconFldLst2=new List<selectoption>();
    public List<selectoption> getsconFldLst2() {return this.sconFldLst2;}
    public List<selectoption> sconFldLst3=new List<selectoption>();
    public List<selectoption> getsconFldLst3() {return this.sconFldLst3;}
    
    public List<SelectOption> operatorSelectLst = new List<SelectOption>();
    public List<SelectOption> getoperatorSelectLst(){return operatorSelectLst;}
    
    public List<SelectOption> objMapSCtoInvoiceLst = new List<SelectOption>();
    public List<SelectOption> getobjMapSCtoInvoiceLst(){return objMapSCtoInvoiceLst;}
    public List<SelectOption> objMapSCtoInvoiceDtlLst = new List<SelectOption>();
    public List<SelectOption> getobjMapSCtoInvoiceDtlLst(){return objMapSCtoInvoiceDtlLst;}
    public List<SelectOption> lstTimeZones{get;set;}
    public SFM_WrapperDef.SFM_Response_Expression responseExp = new SFM_WrapperDef.SFM_Response_Expression();
    
    public SFM_WrapperDef.SFM_Expression exp = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression expSCON = new SFM_WrapperDef.SFM_Expression();
    public SFM_WrapperDef.SFM_Expression getexpSCON(){return this.expSCON;}
    public void setExpSCON(SFM_WrapperDef.SFM_Expression sfmExp){this.expSCON = sfmExp;}
    public integer intSeqVal;
    public integer getintSeqVal(){return this.intSeqVal;}
    public void setintSeqVal(integer index){this.intSeqVal = index;}
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> map_SeqNumRecExp = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> map_SeqNumRec = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    Map<Integer, SVMXC__ServiceMax_Config_Data__c> map_SeqNumsrcUpdate = new Map<Integer, SVMXC__ServiceMax_Config_Data__c>();
    
    RecordType expHdr_Rtype;
    RecordType expDtl_Rtype;
    RecordType expSrcUpdate_Rtype;
    RecordType schedule_Rtype;
    RecordType sconBilProcess_Rtype;
    RecordType objMap_Rtype;
    
    //--------------------------------- Constructor/On-Load --------------------------------------------------
    public CONF_SetupSCONBillingProcess()
    {
        try
        {
            mode = System.currentPageReference().getParameters().get('SVMX_Mode');
            recordId = System.currentPageReference().getParameters().get('SVMX_RecordId');
            lstTimeZones = new List<SelectOption>();
            setDefaultValues();
            retrieveRecordTypes();
            preparingPicklists();
            
            if(mode != 'New' && recordId != null && recordId != '')
            {
                sconBillingProcess = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Node_Parent__c, SVMXC__Process__c, SVMXC__Final_Exception_Process__c, SVMXC__Primary_Consolidation_Rule__c, SVMXC__Secondary_Consolidation_Rule__c, SVMXC__Tertiary_Consolidation_Rule__c, SVMXC__Include_Product__c, SVMXC__Include_Parent__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Capture_Log__c, SVMXC__IsStandard__c, SVMXC__Active__c, SVMXC__Dispatch_Timezone__c from SVMXC__ServiceMax_Processes__c where id =: recordId and RecordTypeId =: sconBilProcess_Rtype.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA 
                
                if(sconBillingProcess != null)
                {
                    processName = sconBillingProcess.SVMXC__Name__c;
                    processID = sconBillingProcess.SVMXC__ProcessID__c;
                    processDesc = sconBillingProcess.SVMXC__Description__c;
                    isActive = sconBillingProcess.SVMXC__Active__c;
                    selectedExp = sconBillingProcess.SVMXC__Module__c;
                    selectedSCONFld1 = sconBillingProcess.SVMXC__Primary_Consolidation_Rule__c;
                    selectedSCONFld2 = sconBillingProcess.SVMXC__Secondary_Consolidation_Rule__c;
                    selectedSCONFld3 = sconBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c;
                    isEnableLogging = sconBillingProcess.SVMXC__Capture_Log__c;
                    strSCtoInvocObjMap = sconBillingProcess.SVMXC__Node_Parent__c;
                    strSCtoInvocDtlObjMap = sconBillingProcess.SVMXC__Process__c;
                    isIncludeNonBillableLines = sconBillingProcess.SVMXC__Include_Product__c;
                     strSelectedTimeZone = sconBillingProcess.SVMXC__Dispatch_Timezone__c;
                    //isIncludeSLAPrice = sconBillingProcess.SVMXC__Include_Parent__c;
                    
                    if(sconBillingProcess.SVMXC__IsStandard__c == true)
                        disabled = true;
                    if(selectedSCONFld1 != 'Contract')
                    {
                        disableSCONFldLst2 = false;
                        if(selectedSCONFld2 != null)
                            disableSCONFldLst3 = false;
                    }
                    
                    sconFldLst3 = new List<SelectOption>();
                    sconFldLst3.add(new SelectOption(getTAG009(),getTAG009()));
                    for(SelectOption so: sconFldLst2)
                    {
                        if(selectedSCONFld2 != null && so.getValue() == selectedSCONFld2)
                            continue;
                        sconFldLst3.add(so);
                    }
                    
                    if(selectedExp != getTAG009() && selectedExp != null)
                    {
                        onChngExp();
                    }
                    
                    lstSrcUpdates = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: expSrcUpdate_Rtype.Id and SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE' and SVMXC__Dispatch_Process__c =: sconBillingProcess.Id Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    srcUpdateHdrSize = lstSrcUpdates.size();
                    
                    lstSchedules = [select id, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c ,SVMXC__Run_Type__c,SVMXC__Day_to_Run__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: schedule_Rtype.Id and SVMXC__Dispatch_Process__c =: sconBillingProcess.Id Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    if(lstSrcUpdates == null || lstSrcUpdates.size() == 0)
                    {
                        srcUpdateHdrADDRow();
                        srcUpdateHdrADDRow();
                    }
                    else
                    {
                        for(SVMXC__ServiceMax_Config_Data__c conf: lstSrcUpdates)
                            map_SeqNumsrcUpdate.put(Math.Round(Integer.valueOf( conf.SVMXC__Sequence__c )), conf);
                    }
                    
                    if(lstSchedules == null || lstSchedules.size() == 0)
                        lstSchedules_AddRow();
                }
            }
            else
            {
                sconBillingProcess = new SVMXC__ServiceMax_Processes__c();
                
                //Adding 2 lines for the Source Updates by default
                srcUpdateHdrADDRow();
                srcUpdateHdrADDRow();                
                lstSchedules_AddRow();
                isActive = true;
            }
            
            if(mode == 'Clone')
            {
                SVMXC__ServiceMax_Processes__c tempProcess = new SVMXC__ServiceMax_Processes__c();
                tempProcess = sconBillingProcess;
                sconBillingProcess = new SVMXC__ServiceMax_Processes__c();
                sconBillingProcess.SVMXC__Email_On_Success__c = tempProcess.SVMXC__Email_On_Success__c;
                sconBillingProcess.SVMXC__Email_On_Error__c = tempProcess.SVMXC__Email_On_Error__c;
                sconBillingProcess.RecordTypeId = sconBilProcess_Rtype.Id;
                sconBillingProcess.SVMXC__IsStandard__c = false;
                sconBillingProcess.SVMXC__Active__c = tempProcess.SVMXC__Active__c;
                sconBillingProcess.SVMXC__Dispatch_Timezone__c = tempProcess.SVMXC__Dispatch_Timezone__c;
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
        disableEditLink = true;
        renderExpBlock = false;
        validate = true;
        isCreateNewExp = false;
        disabled = false;
        selectedExp = getTAG009();
        isIncludeNonBillableLines = true;
        //isIncludeSLAPrice = true;
        selectedSCONFld1 = 'Contract';
        disableSCONFldLst2 = true;
        disableSCONFldLst3 = true; 
        User userTimeZone = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA           
        strSelectedTimeZone = userTimeZone.TimeZoneSidKey;
    }
    
    public string SCONBilProcess_RtypeID = '';
    //---------------------------------------- Method to retrieve All the Record Types -----------------------------------------
    public void retrieveRecordTypes()
    {
        expHdr_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        expDtl_Rtype = [select Id from RecordType where Name='Expressions'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        expSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        sconBilProcess_Rtype = [select Id from RecordType where Name='Contract Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        objMap_Rtype = [select Id from RecordType where Name='Object Mapping'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        SCONBilProcess_RtypeID = sconBilProcess_Rtype.Id;
    }
    
    //------------------------------ Method for Preparing all the Picklists for the Page ----------------------------------------
    public void preparingPicklists()
    {
        SFM_WrapperDef.SFM_Request SFMReq = new SFM_WrapperDef.SFM_Request();
        
        List<SFM_WrapperDef.SFM_StringMap> lstStringMap = new List<SFM_WrapperDef.SFM_StringMap>();
        SFM_WrapperDef.SFM_StringMap strinmap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTTYPE', 'EXPRESSION');
        lstStringMap.add(strinmap1);
        SFM_WrapperDef.SFM_StringMap strinmap2 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME', 'SVMXC__Service_Contract__c');
        lstStringMap.add(strinmap2);
        
        SFMReq.stringMap = lstStringMap;
        
        SFM_GetObjectFieldList newObjToGetFields = new SFM_GetObjectFieldList();
        SFM_WrapperDef.SFM_Response_ObjectFields responseObjFields = newObjToGetFields.getObjectFieldList(SFMReq);
        List<SFM_WrapperDef.fieldProperties> fieldProp = new List<SFM_WrapperDef.fieldProperties>();
        if(responseObjFields.response.success)
        {
            fieldProp = responseObjFields.fields;
        }
      
        sconFldLst.clear();
        sconFldLst.add(new SelectOption('SVMX.NONE',getTAG009()));
        
        for(SFM_WrapperDef.fieldProperties fp : fieldProp)
        {
            sconFldLst.add(new SelectOption(fp.key, fp.value));
        }
        sconFldLst = sortingSelectOption(sconFldLst);
        
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
        
        lstCriteria.clear();
        lstCriteria.add(new SelectOption(getTAG009(), getTAG009()));
        
        lstStringMap.clear();
        SFM_WrapperDef.SFM_StringMap stringMap1 = new SFM_WrapperDef.SFM_StringMap('OBJECTNAME','SVMXC__Service_Contract__c');
        lstStringMap.add(stringMap1);
        
        SFM_WrapperDef.SFM_Request request = new SFM_WrapperDef.SFM_Request(null,null,null,lstStringMap);
        SFM_WrapperDef.SFM_Response response = new SFM_WrapperDef.SFM_Response();
        SFM_GetNamedExpressionList namedExpLst = new SFM_GetNamedExpressionList();
        response = namedExpLst.SFM_getAllObjectNamedExpressionList(request);
        
        for(SFM_WrapperDef.SFM_StringMap tempstringMap : response.stringMap)
            lstCriteria.add(new SelectOption(tempstringMap.key, tempstringMap.value ));
        lstCriteria = sortingSelectOption(lstCriteria);
        
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
        objMapSCtoInvoiceDtlLst.add(new SelectOption(getTAG009(),getTAG009()));
        ObjMapSCLst.clear();
        ObjMapSCLst = [Select  id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c,   SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c, SVMXC__Active__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where RecordTypeId =: ObjMapRtypeId AND SVMXC__Source_Object_Name__c = 'SVMXC__Service_Contract__c' AND SVMXC__Target_Object_Name__c = 'SVMXC__Proforma_Invoice_Detail__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(ObjMapSCLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : ObjMapSCLst)
                objMapSCtoInvoiceDtlLst.add(new SelectOption(pro.Id, pro.SVMXC__Name__C));
        }
        objMapSCtoInvoiceDtlLst = sortingSelectOption(objMapSCtoInvoiceDtlLst);
        
        sconFldLst1.clear();
        sconFldLst1.add(new SelectOption('Contract', SVMXC__Service_Contract__c.sObjectType.getDescribe().getLabel()));
        sconFldLst1.add(new SelectOption('Account', Account.sObjectType.getDescribe().getLabel()));
        
        sconFldLst2 = new List<SelectOption>();
        sconFldLst2.add(new SelectOption(getTAG009(),getTAG009()));
        Map<String,Schema.SObjectField> objfieldMap = new Map<String,Schema.SObjectField>();
        objfieldMap = SVMXC__Service_Contract__c.SObjectType.getDescribe().fields.getMap();
        
        for (String fieldKey : objfieldMap.keySet()) 
        {
            Schema.SObjectField fsObj = objfieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            
            if(f.getName() != 'CurrencyIsoCode' && f.getName() != 'SVMXC__Company__c')
            {
                if(f.getType().name().ToUpperCase() != 'TEXTAREA')
                    sconFldLst2.add(new SelectOption(f.getName(),f.getLabel()));
                else if(f.getType().name().ToUpperCase() == 'TEXTAREA' && !f.isHtmlFormatted())
                    sconFldLst2.add(new SelectOption(f.getName(),f.getLabel()));
            }
        }
        sconFldLst2 = sortingSelectOption(sconFldLst2);
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
    
    //--------------------------------- Method for on change of Service Contract Fields --------------------------------------------------
    public void onChngSCONFld1()
    {
        if(disabled == true || selectedSCONFld1 == 'Contract')
        {
            disableSCONFldLst2 = true;
            disableSCONFldLst3 = true;
            selectedSCONFld2 = getTAG009();
            selectedSCONFld3 = getTAG009();
        }
        else
            disableSCONFldLst2 = false;
    }
    
    //--------------------------------- Method for on change of Service Contract Fields --------------------------------------------------
    public void onChngSCONFld2()
    {
        if(selectedSCONFld2 == getTAG009() || selectedSCONFld2 == null)
        {
            disableSCONFldLst3 = true;
            selectedSCONFld3 = getTAG009();
        }
        else
        {
            disableSCONFldLst3 = false;
        }
        sconFldLst3 = new List<SelectOption>();
        for(SelectOption so: sconFldLst2)
        {
            if((selectedSCONFld2 != null || selectedSCONFld2 != getTAG009()) && so.getValue() == selectedSCONFld2)
                continue;
            sconFldLst3.add(so);
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
        system.debug('list of source updates: ' + lstSrcUpdates);
        validate = true;
        validation();
        if(validate == true)
            saveExps();
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
        {
            save();
            String loc = '/apex/CONF_ManagesconBillingProcesses';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else
            return null;
    }
    
    //---------------------------- Method to cancel the changes and going back to the previous page -------------------------
    public pagereference cancel()
    {
        String loc = '/apex/CONF_ManagesconBillingProcesses';
        PageReference pr = new PageReference(loc);
        return pr;
    }
    
    //------------------------------------ Method to Save the Process and Config Data ---------------------------------
    public void save()
    {
        try
        {
            sconBillingProcess.RecordTypeId = sconBilProcess_Rtype.Id;
            sconBillingProcess.SVMXC__Name__c = processName;
            sconBillingProcess.SVMXC__ProcessID__c = processID;
            sconBillingProcess.SVMXC__Description__c = processDesc;
            sconBillingProcess.SVMXC__Active__c = isActive;
            sconBillingProcess.SVMXC__Capture_Log__c = isEnableLogging;
            sconBillingProcess.SVMXC__Include_Product__c = isIncludeNonBillableLines;
             sconBillingProcess.SVMXC__Dispatch_Timezone__c = strSelectedTimeZone ;
            //sconBillingProcess.SVMXC__Include_Parent__c = isIncludeSLAPrice;
            
            if(selectedExp != getTAG009())
            {
                sconBillingProcess.SVMXC__Module__c = selectedExp;
                disableEditLink = false;
            }
            else
                sconBillingProcess.SVMXC__Module__c = null;
            
            
            sconBillingProcess.SVMXC__Primary_Consolidation_Rule__c = selectedSCONFld1;
            
            if(selectedSCONFld1 != 'Contract')
            {
                if(selectedSCONFld2 != getTAG009())
                    sconBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = selectedSCONFld2;
                else
                    sconBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = null;
                
                if(selectedSCONFld3 != getTAG009())
                    sconBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = selectedSCONFld3;
                else
                    sconBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = null;
            }
            else
            {
                sconBillingProcess.SVMXC__Secondary_Consolidation_Rule__c = null;
                sconBillingProcess.SVMXC__Tertiary_Consolidation_Rule__c = null;
            }
            
            if(strSCtoInvocObjMap != getTAG009())
                sconBillingProcess.SVMXC__Node_Parent__c = strSCtoInvocObjMap;
            else
                sconBillingProcess.SVMXC__Node_Parent__c = null;
            
            if(strSCtoInvocDtlObjMap != getTAG009())
                sconBillingProcess.SVMXC__Process__c = strSCtoInvocDtlObjMap;
            else
                sconBillingProcess.SVMXC__Process__c = null;
            
            //upsert sconBillingProcess;
			if(COMM_SecurityUtils.getInstance().verifyFieldAccess(sconBillingProcess, COMM_SecurityUtils.Access.Upsertable)){
				upsert sconBillingProcess; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
			}
			else{
				ApexPages.addMessage(new ApexPages.Message ( ApexPages.Severity.ERROR, System.Label.COMM001_TAG142 ) );
				return;
            }
            
            system.debug('List of Source Updates to delete: ' + lstSchedules_toDelete);
            if(lstSchedules_toDelete != null && lstSchedules_toDelete.size() > 0)
                delete lstSchedules_toDelete; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstSchedules_toDelete.clear();
            
            system.debug('List of Source Updates to save: ' + lstSrcUpdates);
            lstConfigdataToSave.clear();
            if(lstSrcUpdates != null && lstSrcUpdates.size()>0)
            {
                for(SVMXC__ServiceMax_Config_Data__c configdata : lstSrcUpdates)
                {
                    if(configdata.SVMXC__Target_Field_Name__c != getTAG009() && configdata.SVMXC__Display_Value__c != null && configdata.SVMXC__Target_Field_Name__c != null && configdata.SVMXC__Display_Value__c != '')
                    {
                        configdata.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE';
                        configdata.SVMXC__Dispatch_Process__c = sconBillingProcess.Id;
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
                        configdata.SVMXC__Dispatch_Process__c = sconBillingProcess.Id;
                        lstConfigdataToSave.add(configdata);
                    }
                    if(configdata.SVMXC__Run_Type__c=='Date of Month')
                    if(configdata.SVMXC__Run_At__c != null && configdata.SVMXC__Run_At__c != '' && configdata.SVMXC__Run_At__c !=getTAG009() && configdata.SVMXC__Day_to_Run__c != null && configdata.SVMXC__Day_to_Run__c != '' && configdata.SVMXC__Day_to_Run__c !=getTAG009()  && configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c !=getTAG009())
                    {   configdata.SVMXC__Schedule_Days__c=null;
                        configdata.RecordTypeId = Schedule_Rtype.Id;
                        configdata.SVMXC__Dispatch_Process__c = sconBillingProcess.Id;
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
        if(processName == null || processName == '')
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG053(),''));
        }
        if(processID == null || processID == '')
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG054(),''));
        }
        if(processID.length() < 8)
        {
            validate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG055(),''));
        }
        
        List<SVMXC__ServiceMax_Processes__c> LstToCheckId = new List<SVMXC__ServiceMax_Processes__c>();
        String UniqueProcessId = processID;
        string SCONID;
        if(sconBillingProcess.get('Id') == null)
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId and RecordTypeId =: SCONBilProcess_RtypeID');
        else
        {
            SCONID = sconBillingProcess.Id;
            LstToCheckId = Database.query('Select Id, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: UniqueProcessId and RecordTypeId =: SCONBilProcess_RtypeID AND Id !=: SCONID');
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
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG090()));
                    }
                    if(configdata.SVMXC__Run_Type__c != null && configdata.SVMXC__Run_Type__c != '' && configdata.SVMXC__Run_Type__c !=getTAG009())
                    {
                         if(configdata.SVMXC__Run_Type__c=='Day of Week')
                            if(configdata.SVMXC__Schedule_Days__c == null || configdata.SVMXC__Schedule_Days__c == '' || configdata.SVMXC__Schedule_Days__c ==getTAG009()) 
                            {
                                validate=false;
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG090()));
                            }
                          if(configdata.SVMXC__Run_Type__c=='Date of Month')
                            if(configdata.SVMXC__Day_to_Run__c == null || configdata.SVMXC__Day_to_Run__c == '' || configdata.SVMXC__Day_to_Run__c ==getTAG009())
                            {
                                validate=false;
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, getTAG090()));
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
        APL_Utils APLUtilObj = new APL_Utils();
        if(expSCON != null && expSCON.namedExpression.SVMXC__IsStandard__c != true && ((selectedExp != getTAG009() && selectedExp != null) || isCreateNewExp == true))
        {
            for(integer i=0; i < expSCON.expressionDetails.size(); i++)
                expSCON.expressionDetails[i].SVMXC__Object_Name2__c = 'SVMXC__Service_Contract__c';
            expSCON.expressionDetails = APLUtilObj.PopulateInfoForReferenceFields(expSCON.expressionDetails);
            exp = expSCON;
            detailSize = expDetailSize;
            submitExp();
            if(validate == true)
                selectedExp = expSCON.namedExpression.Id;
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
                detailSize = Math.Round(exp.expressionDetails.size());
                
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
                expSCON = responseExp.expressions[0];
                expDetailSize = expSCON.expressionDetails.size();
                map_SeqNumRecExp.clear();
                for(SVMXC__ServiceMax_Config_Data__c confData : expSCON.expressionDetails)
                {
                    map_SeqNumRecExp.put(integer.valueOf(confData.SVMXC__Sequence__c), confData);
                }
            }
        }
        else
            disableEditLink = true;
    }
    
    //----------------------------------------- View/Edit of Initiate Return Parent ---------------------------------------------
    public void EditExp()
    {
        renderExpBlock = true;
    }
    
    //----------------------------------------- New Criteria of Initiate Return Parent ---------------------------------------------
    public void NewExp()
    {
        isCreateNewExp = true;
        selectedExp = getTAG009();
        disableEditLink = true;
        renderExpBlock = true;
        expSCON = new SFM_WrapperDef.SFM_Expression();
        expSCON.namedExpression = new SVMXC__ServiceMax_Processes__c(RecordTypeId = expHdr_Rtype.Id, SVMXC__Source_Object_Name__c = 'SVMXC__Service_Contract__c');
        expSCON.expressionDetails = new List<SVMXC__ServiceMax_Config_Data__c>();
        if(expSCON.expressionDetails != null)
            expDetailSize = expSCON.expressionDetails.size();
        else
            expDetailSize = 0;
        exp = expSCON;
        detailSize = expDetailSize;
        map_SeqNumRec.clear();
        if(map_SeqNumRecExp.size() > 0)
            map_SeqNumRec.putAll(map_SeqNumRecExp);
        
        //Adding two Rows by Default
        HdrADDRow();
        HdrADDRow();
        
        expSCON = exp;
        expDetailSize = detailSize;
        map_SeqNumRecExp.clear();
        map_SeqNumRecExp.putAll(map_SeqNumRec);
    }
    
    
    //----------------------------------------- Delete Row in the Initiate Return ---------------------------------------------
    public PageReference HdrDeleteRowExp()
    {
        exp = expSCON;
        detailSize = expDetailSize;
        map_SeqNumRec.clear();
        map_SeqNumRec.putAll(map_SeqNumRecExp);
        HdrDeleteRow();
        map_SeqNumRecExp.clear();
        map_SeqNumRecExp.putAll(map_SeqNumRec);
        expDetailSize = detailSize;
        expSCON = exp;
        return null;
    }
    
    //----------------------------------------- Add Row in the Initiate Return ---------------------------------------------
    public PageReference HdrADDRowExp()
    {
        exp = expSCON;
        detailSize = expDetailSize;
        map_SeqNumRec.clear();
        if(map_SeqNumRecExp.size() > 0)
            map_SeqNumRec.putAll(map_SeqNumRecExp);
        HdrADDRow();
        expDetailSize = detailSize;
        map_SeqNumRecExp.clear();
        map_SeqNumRecExp.putAll(map_SeqNumRec);
        expSCON = exp;
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
        system.debug('Map of sequence to Config data before Delete: ' + map_SeqNumRec);
        SrcUpdateDeleteRow();
        map_SeqNumsrcUpdate.clear();
        map_SeqNumsrcUpdate.putAll(map_SeqNumRec);
        system.debug('Map of sequence to Config data after Delete: ' + map_SeqNumsrcUpdate);
        srcUpdateHdrSize = detailSize;
        lstSrcUpdates = lstExp;
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
            
            system.debug('Data to Delete: ' + lstSchedules_toDelete);
            
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
    public void InvoiceRules()
    {
        selectedTab = 'TAB2';
    }
    public void SrcUpd()
    {
        selectedTab = 'TAB3';
    }
    public void Schedules()
    {
        selectedTab = 'TAB4';
    }
    
    //------------------------------------- Getter methods for the custom labels ----------------------------------
    
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
    public String getTAG060(){return system.label.COMM002_TAG006;}//Equals
    public String getTAG061(){return system.label.COMM002_TAG007;}//Not Equal
    public String getTAG062(){return system.label.COMM002_TAG008;}//Greater Than
    public String getTAG063(){return system.label.COMM002_TAG009;}//Greater or Equal To
    public String getTAG064(){return system.label.COMM002_TAG010;}//Less Than
    public String getTAG065(){return system.label.COMM002_TAG011;}//Less or Equal To
    public String getTAG066(){return system.label.COMM002_TAG012;}//Starts With
    public String getTAG067(){return system.label.COMM002_TAG013;}//Contains
    public String getTAG068(){return system.label.COMM002_TAG014;}//Does Not Contain
    public String getTAG069(){return system.label.COMM002_TAG015;}//Includes
    public String getTAG070(){return system.label.COMM002_TAG016;}//Excludes
    public String getTAG071(){return system.label.COMM002_TAG022;}//Is Null
    public String getTAG072(){return system.label.COMM002_TAG023;}//Is Not Null
    public String getTAG074(){return system.label.COMM002_TAG017;}//Set
    public String getTAG075(){return system.label.COMM002_TAG018;}//Increase
    public String getTAG076(){return system.label.COMM002_TAG019;}//Decrease
    
    public String getTAG058(){return system.label.COMM002_TAG034;} // 'Please enter a valid Expression Name.'
    public String getTAG059(){return system.label.COMM002_TAG035;} // 'Expression ID should be atleast 8 characters long.'
    public string getTAG014(){return system.label.COMM002_TAG031;} // 'Use an existing criteria from the list'
    public string getTAG015(){return system.label.COMM002_TAG037;} // 'View/Edit'
    public string getTAG016(){return system.label.COMM002_TAG036;} // 'Or Create a new criteria'
    public string getTAG044(){return system.label.COMM001_TAG078;} // 'Run At(GMT)'
    public string getTAG045(){return system.label.COMM001_TAG079;} // 'On These Days'
    public string getTAG052(){return system.label.COMM001_TAG084;} // 'Insufficient parameters provided. Please contact to your ServiceMax administrator.'
    public string getTAG053(){return system.label.COMM001_TAG059;} // 'Please enter a Process Name'
    public string getTAG054(){return system.label.COMM001_TAG059;} // 'Please enter a Process ID'
    public string getTAG055(){return system.label.COMM001_TAG085;} //   'Process ID must be unique and at least 8 characters long'
    public String getTAG056(){return system.label.COMM001_TAG077;} //   'An internal error occurred. Please try this operation later. If the problem persists, please contact ServiceMax support for assistance.'
    //public String getTAG082(){return system.label.COMM001_TAG059;} // 'Please enter an email id to notify about the errors'
    public string getTAG049(){return system.label.COMM001_TAG082;} // 'Send success notifications to this email address'
    public string getTAG050(){return system.label.COMM001_TAG083;} // 'Send error notifications to this email address'
    public string getTAG005(){return system.label.COMM001_TAG072;} // 'General Info'
    public string getTAG006(){return system.label.COMM001_TAG073;} // 'Invoice Rules'
    public string getTAG007(){return system.label.COMM001_TAG074;} // 'Source Updates'
    public string getTAG008(){return system.label.COMM001_TAG075;} // 'Schedule & Notifications'
    
    public string getHLPURL(){return system.label.CONF034_HLPURL;} // 
    public string getTAG001(){return system.label.CONF034_TAG003;} // 'Setup Service Contract Billing Process'
    public string getTAG013(){return system.label.CONF034_TAG004;} // 'Using the expression-builder below, indicate how hearder records qualify for Service Contract billing process.'
    public string getTAG027(){return system.label.CONF034_TAG006;} // 'Consolidate based on'
    public string getTAG028(){return system.label.CONF034_TAG007;} // 'Group Invoice using primary attribute'
    public string getTAG029(){return system.label.CONF034_TAG008;} // 'Group Invoice using secondary attribute'
    public string getTAG030(){return system.label.CONF034_TAG005;} // 'Service Contract Consolidation rules'
    public string getTAG031(){return system.label.CONF034_TAG009;} // 'Consolidation on Pricing rules'
    public string getTAG032(){return system.label.CONF034_TAG010;} // 'Include Non-Billable Lines'
    public string getTAG033(){return system.label.CONF034_TAG011;} // 'Use the Value Mapping to create Invoice from Service Contract'
    public string getTAG034(){return system.label.CONF034_TAG012;} // 'Use the Object Mapping to create Invoice Detail from Service Contract'
    public string getTAG038(){return system.label.CONF034_TAG013;} // 
    public string getTAG043(){return system.label.CONF034_TAG014;} // 'Choose the times and days to run SC Billing Engine for this process'
    public string getTAG048(){return system.label.COMM001_TAG086;} // 'Specify recipents of notifications and alerts'
    public string getTAG051(){return system.label.COMM001_TAG087;} // 'Enable Logging'
    public String getTAG083(){return system.label.COMM001_TAG088;} // ' has been entered twice in schedule frequency list'
    public String getTAG088(){return system.label.COMM001_TAG058;} // 'Process saved successfully'
    public String getTAG090(){return system.label.CONF034_TAG015;} // 'Insufficient time and day information to run Service Contract Proforma Invoice Generation Engine'
    public String getTAG091(){return system.label.COMM001_TAG016;} //'Active'
    public String getTAG092(){return system.label.COMM001_TAG103;} //'Time Zone'
}