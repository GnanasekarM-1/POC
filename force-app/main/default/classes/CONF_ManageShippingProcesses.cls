public with sharing class CONF_ManageShippingProcesses
{
    public List<SVMXC__ServiceMax_Processes__c> stndProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getstndProcessLst(){return this.stndProcessLst;}
    public void setstndProcessLst(List<SVMXC__ServiceMax_Processes__c> o){this.stndProcessLst = o;}
    public List<SVMXC__ServiceMax_Processes__c> custmProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getcustmProcessLst(){return this.custmProcessLst;}
    public void setcustmProcessLst(List<SVMXC__ServiceMax_Processes__c> o){this.custmProcessLst = o;}
    public boolean DisableStdBtn = false;
    public boolean getDisableStdBtn(){return this.DisableStdBtn;}
    public void setDisableStdBtn(boolean b){this.DisableStdBtn = b;}
    public boolean DisableCusBtn = false;
    public boolean getDisableCusBtn(){return this.DisableCusBtn;}
    
    public CONF_ManageShippingProcesses()
    {
        stndProcessLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Shipping Process' and SVMXC__IsStandard__c = true order By SVMXC__ProcessId__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        custmProcessLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Shipping Process' and SVMXC__IsStandard__c = false order By SVMXC__ProcessId__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(stndProcessLst.size() == 0)
        {
            DisableStdBtn = true;
        }
        else
            DisableStdBtn = false;
            
        if(custmProcessLst.size() == 0)
        {
            DisableCusBtn = true;
        }
        else
            DisableCusBtn = false;
    }
    
    public pagereference StdView()
    {
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ProcessRec: stndProcessLst)
        {
            if(ProcessRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = ProcessRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/Conf_SetupShippingProcess?SVMX_RecordId='+ SVMX_RecordId + '&SVMX_Mode=View';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG014(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
            return null;
        }
    }
    
    public pagereference StdClone()
    {
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ProcessRec: stndProcessLst)
        {
            if(ProcessRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = ProcessRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/Conf_SetupShippingProcess?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Mode=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG014(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
            return null;
        }
    }
    
    public pagereference backToSetupHome()
    {
        //String location = '/apex/CONF_SetupHome';
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/SVMXC__CONF_SetupHome';
        }
        PageReference pr = new PageReference(url);
        pr.setredirect(true);
        return pr;
    }
    
    public pagereference newShpProcess()
    {
        PageReference pageRef = new PageReference('/apex/Conf_SetupShippingProcess');
        pageRef.getParameters().put('SVMX_Mode','New');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pagereference editShpProcess()
    {
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ProcessRec: custmProcessLst)
        {
            if(ProcessRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = ProcessRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/Conf_SetupShippingProcess?SVMX_RecordId='+SVMX_RecordId + '&SVMX_Mode=Edit';
            PageReference pr = new PageReference(loc);
            pr.setRedirect(true);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG014(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
            return null;
        }
    }
    
    public pagereference CustmClone()
    {
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ProcessRec: custmProcessLst)
        {
            if(ProcessRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = ProcessRec.Id;
            }
        }
        if( selectedCount == 1 )
        {
            String loc = '/apex/Conf_SetupShippingProcess?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Mode=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG014(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
            return null;
        }
    }
    
    public pagereference delShpProcess()
    {
        String SVMX_RecordId = '';
        Integer selectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c ProcessRec: custmProcessLst)
        {
            if(ProcessRec.Select__c == true)
            {
                selectedCount += 1;
                SVMX_RecordId = ProcessRec.Id;
            }
        }
        if(selectedCount == 1 && SVMX_RecordId != null)
        {
            Savepoint sp;
            try
            {
                RecordType ExpressionsSrcUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                string recordTypeId = ExpressionsSrcUpdate_Rtype.Id;
                SVMXC__ServiceMax_Processes__c shippingProcess = [Select  Id, SVMXC__Name__c, SVMXC__Process__c, SVMXC__Parent_Object__c, SVMXC__ProcessID__c, SVMXC__Description__c,SVMXC__Process1__c, SVMXC__Process2__c, SVMXC__APL_Serial_Number_Source__c, SVMXC__APL_Scan_First__c, SVMXC__Source_Object_Name__c, SVMXC__Active__c, SVMXC__Node_Parent__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Final_Exception_Process__c, SVMXC__Parent_Error_Msg__c, SVMXC__Child_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Child_Error_Msg2__c, SVMXC__APL_Allow_Partial_Shipment__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__IsStandard__c from SVMXC__ServiceMax_Processes__c Where Id =: SVMX_RecordId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                List<SVMXC__SFM_Event__c> lstSFMEvent = [Select SVMXC__Event_Id__c, SVMXC__Sequence__c, SVMXC__ServiceMax_Custom_Action__c, SVMXC__ServiceMax_Process__c, SVMXC__Event_Type__c, SVMXC__Namespace__c, SVMXC__Class__c, SVMXC__Method__c, SVMXC__Description__c, SVMXC__Event_Call_Type__c, SVMXC__URL_Window_Type__c from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c =: SVMX_RecordId];
                
                List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataForSrcUpdate = [Select SVMXC__Target_Field_Name__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Action__c, SVMXC__RecordType_Name__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: SVMX_RecordId and RecordTypeId =: recordTypeId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                //delete lstConfigdataForSrcUpdate;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete lstConfigdataForSrcUpdate; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addmessage(new apexpages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                
                //delete lstSFMEvent;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__SFM_Event__c')){
                    delete lstSFMEvent; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addmessage(new apexpages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                
                //delete shippingProcess;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete shippingProcess; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addmessage(new apexpages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG017(),''));
                custmProcessLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Shipping Process' and SVMXC__IsStandard__c = false]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(custmProcessLst.size() == 0)
                    DisableCusBtn = true;
                return null;
            }
            catch(exception ex)
            {
                apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, getTAG018()));
                Database.rollback(sp);
                return null;
            }
        }
        else if(selectedCount == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG014(),''));
            return null;
        }
        else
        {
            system.debug('More than one processes found' + getTAG015());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
            return null;
        }
    }
    public string getHLPURL() {return system.label.CONF024_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    public String getTAG001() {return system.label.CONF024_TAG001;}//'Standard Shipping Processes'
    public String getTAG002() {return system.label.CONF024_TAG002;}//'Custom Shipping Processes'
    public String getTAG003() {return system.label.CONF024_TAG003;}//'View'
    public String getTAG004() {return system.label.CONF024_TAG004;}//'Clone'
    public String getTAG005() {return system.label.CONF024_TAG005;}//'Back to Setup Home'
    public String getTAG006() {return system.label.CONF024_TAG006;}//'New'
    public String getTAG007() {return system.label.CONF024_TAG007;}//'Edit'
    public String getTAG008() {return system.label.CONF024_TAG008;}//'Delete'
    public String getTAG009() {return system.label.CONF024_TAG009;}//'Select'
    public String getTAG010() {return system.label.CONF024_TAG010;}//'Process ID'
    public String getTAG011() {return system.label.CONF024_TAG011;}//'Process Name'
    public String getTAG012() {return system.label.CONF024_TAG012;}//'Description'
    public String getTAG013() {return system.label.CONF024_TAG013;}//'Last Modified By'
    public String getTAG014() {return system.label.CONF024_TAG014;}//'Please select a Process to perform this operation.'
    public String getTAG015() {return system.label.CONF024_TAG015;}//'Please select only one Process to perform this operation.'
    public String getTAG016() {return system.label.CONF024_TAG071;}//'Processing...'
    public String getTAG017() {return system.label.CONF024_TAG092;}//'Successfully deleted the selected Process.'
    public String getTAG018() {return system.label.CONF024_TAG074;}//'An internal error occurred. Please contact your ServiceMax administrator to resolve this.'
}