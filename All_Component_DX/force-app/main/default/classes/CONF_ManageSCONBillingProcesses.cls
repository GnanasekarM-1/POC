public with sharing class CONF_ManageSCONBillingProcesses
{
    public List<SVMXC__ServiceMax_Processes__c> stndProcessLst{get;set;}
    public List<SVMXC__ServiceMax_Processes__c> custmProcessLst{get;set;}
    public boolean DisableStdBtn{get;set;}
    public boolean DisableCusBtn{get;set;}
    
    public boolean isDisplayStandardSec;
    public Boolean getisDisplayStandardSec(){ return isDisplayStandardSec;}
    public string customSecLabel;
    

    public CONF_ManageSCONBillingProcesses()
    {
        defaultValues();
        queryingProcesses();
        
        if(stndProcessLst.size() == 0)
        {
            isDisplayStandardSec=false;
            customSecLabel=system.label.CONF034_TAG016;
            DisableStdBtn = true;
        }
        else
        {
            isDisplayStandardSec=true;
            customSecLabel=system.label.CONF034_TAG002;
            DisableStdBtn = false;
        }
            
        if(custmProcessLst.size() == 0)
            DisableCusBtn = true;
        else
            DisableCusBtn = false;
    }
    
    public void defaultValues()
    {
        isDisplayStandardSec=true;
        customSecLabel=system.label.CONF034_TAG002;
        DisableStdBtn = false;
        DisableCusBtn = false;
        stndProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
        custmProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    }
    
    public void queryingProcesses()
    {
        stndProcessLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate, SVMXC__Active__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Contract Billing Process' and SVMXC__IsStandard__c = true order By SVMXC__ProcessId__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        custmProcessLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate, SVMXC__Active__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Contract Billing Process' and SVMXC__IsStandard__c = false order By SVMXC__ProcessId__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
            String loc = '/apex/Conf_SetupSCONBillingProcess?SVMX_RecordId='+ SVMX_RecordId + '&SVMX_Mode=View';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
            return null;
        }
    }
    
    public pagereference CONF_CL_SCBillingProcess()
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
            String loc = '/apex/Conf_SetupSCONBillingProcess?SVMX_RecordId='+ SVMX_RecordId + '&SVMX_Mode=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
            return null;
        }
    }
    
    public pagereference CONF_CL_SCBillingProcessCustm()
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
            String loc = '/apex/Conf_SetupSCONBillingProcess?SVMX_RecordId='+ SVMX_RecordId + '&SVMX_Mode=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
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
    
    public pagereference CONF_NW_SCBillingProcess()
    {
        PageReference pageRef = new PageReference('/apex/Conf_SetupSCONBillingProcess');
        pageRef.getParameters().put('SVMX_Mode','New');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pagereference CONF_ED_SCBillingProcess()
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
            String loc = '/apex/Conf_SetupSCONBillingProcess?SVMX_RecordId='+ SVMX_RecordId + '&SVMX_Mode=Edit';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
            return null;
        }
    }
    
    public pagereference CONF_DL_SCBillingProcess()
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
                RecordType ExpressionsSrcUpdate_Rtype1 = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                string recordTypeId = ExpressionsSrcUpdate_Rtype.Id;
                string recordTypeId1 = ExpressionsSrcUpdate_Rtype1.Id;
                
                SVMXC__ServiceMax_Processes__c SVMX_Process = [Select Id from SVMXC__ServiceMax_Processes__c Where Id =: SVMX_RecordId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataForSrcUpdate = [Select SVMXC__Target_Field_Name__c, SVMXC__Sequence__c, SVMXC__Field_Name__c, SVMXC__Action__c, SVMXC__RecordType_Name__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: SVMX_RecordId and ((RecordTypeId =: recordTypeId and SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE') OR RecordTypeId =: recordTypeId1)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                //delete lstConfigdataForSrcUpdate;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete lstConfigdataForSrcUpdate; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                //delete SVMX_Process;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete SVMX_Process; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.COMM001_TAG142));
                    Database.rollback(sp);
                    return null;
                }
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG018(),''));
                
                custmProcessLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate,SVMXC__Active__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Contract Billing Process' and SVMXC__IsStandard__c = false]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(custmProcessLst.size() == 0)
                    DisableCusBtn = true;
                
                return null;
            }
            catch(exception ex)
            {
                apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, getTAG019()));
                Database.rollback(sp);
                return null;
            }
        }
        else if(selectedCount == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG016(),''));
            return null;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG015(),''));
            return null;
        }
    }
    
    public string getHLPURL(){return system.label.CONF034_HLPURL;} // 
    public string getHLPTITLE(){return system.label.COMM001_TAG064;} // 'Help'
    public string getTAG001(){return system.label.CONF034_TAG001;} //  'Standard Service Contract Billing Processes'
    public string getTAG002(){return system.label.COMM001_TAG043;} // 'View'
    public string getTAG003(){return system.label.COMM001_TAG045;} // 'Clone'
    public string getTAG004(){return system.label.COMM001_TAG046;} // 'Back to Setup Home'
    public string getTAG005(){return system.label.COMM001_TAG044;} // 'Select'
    public string getTAG006(){return system.label.COMM001_TAG056;} // 'Process Id'
    public string getTAG007(){return system.label.COMM001_TAG055;} // 'Process Name'
    public string getTAG008(){return system.label.COMM001_TAG017;} // 'Description'
    public string getTAG009(){return system.label.COMM001_TAG076;} // 'Last Modified By'
    public string getTAG010(){return              customSecLabel;} // 'Custom Service Contract Billing Processes' or 'Service Contract Billing Processes'
    public string getTAG011(){return system.label.COMM001_TAG047;} // 'New'
    public string getTAG012(){return system.label.COMM001_TAG048;} // 'Edit'
    public string getTAG013(){return system.label.COMM001_TAG049;} // 'Delete'
    public string getTAG014(){return system.label.COMM001_TAG057;} // 'Are you sure?'
    public string getTAG015(){return system.label.COMM001_TAG051;} // 'Please select only one process to perform this operation'
    public string getTAG016(){return system.label.COMM001_TAG050;} // 'Please select a process to perform this operation'
    public string getTAG017(){return system.label.COMM001_TAG041;} // 'Processing...'
    public string getTAG018(){return system.label.COMM001_TAG052;} // 'Process deleted successfully'
    public string getTAG019(){return system.label.COMM001_TAG077;} // 'An unexpected error occured. Please contact to your ServiceMax Administrator.'
    public string getTAG020(){return system.label.COMM001_TAG067;}//Last Modified Date
    public string getTAG021(){return system.label.COMM001_TAG016;}//Active
    
}