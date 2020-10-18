public with sharing class CONF_ManageReceivingProcesses
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
    public List<SelectOption> sourceObjectsOptns = new  List<SelectOption>();
    public boolean getDisableCusBtn(){return this.DisableCusBtn;}
    
    public CONF_ManageReceivingProcesses()
    {
        stndProcessLst = [select Id, SVMXC__Select__c, SVMXC__ProcessId__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedBy.Name from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Receiving Process' and SVMXC__IsStandard__c = true]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        custmProcessLst = [select Id, SVMXC__Select__c, SVMXC__ProcessId__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedBy.Name from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Receiving Process' and SVMXC__IsStandard__c = false]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
            String loc = '/apex/Conf_SetupReceivingProcess?SVMX_RecordId='+SVMX_RecordId;
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag018(),''));
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
            String loc = '/apex/Conf_SetupReceivingProcess?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Mode=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag018(),''));
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
    public pagereference newRcvProcess()
    {
        PageReference pageRef = new PageReference('/apex/Conf_SetupReceivingProcess');
        pageRef.getParameters().put('SVMX_Mode','New');
        pageRef.setRedirect(true);
        return pageRef;
    }
    public pagereference editRcvProcess()
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
            String loc = '/apex/Conf_SetupReceivingProcess?SVMX_RecordId='+SVMX_RecordId;
            PageReference pr = new PageReference(loc);
            pr.setRedirect(true);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag018(),''));
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
            String loc = '/apex/Conf_SetupReceivingProcess?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Mode=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag018(),''));
            return null;
        }
    }
    public pagereference delRcvProcess()
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
            try
            {
                List<SVMXC__ServiceMax_Processes__c> lstProcess = [Select Id from SVMXC__ServiceMax_Processes__c where Id = :SVMX_RecordId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstProcess != null && lstProcess.size()>0){
                    //Delete lstProcess;
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                        delete lstProcess; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                custmProcessLst = [select Id, SVMXC__Select__c, SVMXC__ProcessId__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Receiving Process' and SVMXC__IsStandard__c = false]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(custmProcessLst.size() == 0)
                {
                    DisableCusBtn = true;
                }
                else
                    DisableCusBtn = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTag016(),''));
            }
            catch(exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+ex.getMessage(),''));
            }
            return null;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTag018(),''));
            return null;
        }
        return null;
    }
    //Custom labels / tags
    public String getTag001(){ return System.label.CONF023_TAG092; }//'Processing...' ;}
    public String getTag002(){ return System.label.CONF023_TAG124; }//'Standard Receiving Processes' ;}
    public String getTag003(){ return System.label.CONF023_TAG125; }//'View' ;}
    public String getTag004(){ return System.label.CONF023_TAG126; }//'Clone' ;}
    public String getTag005(){ return System.label.CONF023_TAG127; }//'Back To Setup Home' ;}
    public String getTag006(){ return System.label.CONF023_TAG128; }//'Select' ;}
    public String getTag007(){ return System.label.CONF023_TAG003; }//'Process Id' ;}
    public String getTag008(){ return System.label.CONF023_TAG002; }//'Process Title' ;}
    public String getTag009(){ return System.label.CONF023_TAG004; }//'Process Details' ;}
    public String getTag010(){ return System.label.CONF023_TAG129; }//'Last Modified By' ;}
    public String getTag011(){ return System.label.CONF023_TAG130; }//'Custom Receiving Processes' ;}
    public String getTag012(){ return System.label.CONF023_TAG131; }//'New' ;}
    public String getTag013(){ return System.label.CONF023_TAG069; }//'Edit' ;}
    public String getTag014(){ return System.label.CONF023_TAG132; }//'Delete' ;}
    public String getTag015(){ return System.label.CONF023_TAG133; }//'Are you sure?' ;}
    public string getHLPURL() {return system.label.CONF023_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    public String getTag016(){ return System.label.CONF023_TAG142;} //'The selected Receiving Process was successfully deleted' 
    public String getTag017(){ return System.label.CONF023_TAG143;} //'Please select a Process to perform this operation.' 
    public String getTag018(){ return System.label.CONF023_TAG144;} //'Please select only one Process to perform this operation.' 
    
}