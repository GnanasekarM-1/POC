public with sharing class CONF_ManagePMProcesses
{
    public List<SVMXC__ServiceMax_Processes__c> stndProcessLst{get;set;}
    public List<SVMXC__ServiceMax_Processes__c> custmProcessLst{get;set;}
    public boolean DisableStdBtn{get;set;}
    public boolean DisableCusBtn{get;set;}
    
    public boolean isDisplayStandardSec;
    public Boolean getisDisplayStandardSec(){ return isDisplayStandardSec;}
    public string customSecLabel;
    public string Helptitleonhide{get;set;}
    public string helpUrlonhide{get;set;}

    public CONF_ManagePMProcesses()
    {
        defaultValues();
        queryingProcesses();
        
        if(stndProcessLst.size() == 0)
        {
            Helptitleonhide=getHLPTITLE();
            helpUrlonhide=getHLPURL();
            isDisplayStandardSec=false;
            customSecLabel=system.label.CONF036_TAG047;
            DisableStdBtn = true;
        }
        else
        {
            Helptitleonhide='';
            helpUrlonhide='';
            isDisplayStandardSec=true;
            customSecLabel=system.label.CONF036_TAG002;
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
        customSecLabel=system.label.CONF036_TAG002;
        DisableStdBtn = false;
        DisableCusBtn = false;
        stndProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
        custmProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    }
    
    public void queryingProcesses()
    {
        stndProcessLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate,SVMXC__Active__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='PM Process' and SVMXC__IsStandard__c = true order By SVMXC__ProcessId__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        custmProcessLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate,SVMXC__Active__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='PM Process' and SVMXC__IsStandard__c = false order By SVMXC__ProcessId__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
            String loc = '/apex/SVMXC__CONF_SetupPMProcess?SVMX_RecordId='+ SVMX_RecordId + '&SVMX_Mode=View';
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
    
    public pagereference CONF_CL_PMProcess()
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
            String loc = '/apex/SVMXC__CONF_SetupPMProcess?SVMX_RecordId='+ SVMX_RecordId + '&SVMX_Mode=Clone';
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
    
    public pagereference CONF_CL_PMProcessCustm()
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
            String loc = '/apex/SVMXC__CONF_SetupPMProcess?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Mode=Clone';
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
        //String location = '/apex/SVMXC__CONF_SetupHome';
        //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String location='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            location = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            location ='/apex/SVMXC__CONF_SetupHome';
        }
        //Changes done by Nidhi ends here
        PageReference pr = new PageReference(location);
        pr.setredirect(true);
        return pr;
    }
    
    public pagereference CONF_NW_PMProcess()
    {
        PageReference pageRef = new PageReference('/apex/SVMXC__CONF_SetupPMProcess');
        pageRef.getParameters().put('SVMX_Mode','New');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pagereference CONF_ED_PMProcess()
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
            String loc = '/apex/SVMXC__CONF_SetupPMProcess?SVMX_RecordId='+ SVMX_RecordId + '&SVMX_Mode=Edit';
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
    
    public pagereference CONF_DL_PMProcess()
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
                
                custmProcessLst = [select Id, SVMXC__ProcessId__c, SVMXC__Source_Object_Name__c, SVMXC__Select__c, SVMXC__Name__C, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate,SVMXC__Active__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='PM Process' and SVMXC__IsStandard__c = false]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
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
    
    public string getHLPURL(){return 'https://www.servicemax.com';}//system.label.CONF036_HLPURL
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} // 'Help'
    public string getTAG001(){return system.label.CONF036_TAG001;}//'Standard Preventive Maintenance Processes'
    public string getTAG002(){return system.label.COMM001_TAG043;} // 'View'
    public string getTAG003(){return system.label.COMM001_TAG045;} // 'Clone'
    public string getTAG004(){return system.label.COMM001_TAG046;} // 'Back to Setup Home'
    public string getTAG005(){return system.label.COMM001_TAG044;} // 'Select'
    public string getTAG006(){return system.label.COMM001_TAG056;} // 'Process Id'COMM001_TAG056
    public string getTAG007(){return system.label.COMM001_TAG055;} // 'Process Name'
    public string getTAG008(){return system.label.COMM001_TAG017;} // 'Description'
    public string getTAG009(){return system.label.COMM001_TAG076;}//'Last Modified By'
    public string getTAG010(){return              customSecLabel;}//'Custom Preventive Maintenance Processes' or 'Preventive Maintenance Processes' 
    public string getTAG011(){return system.label.COMM001_TAG047;} // 'New'
    public string getTAG012(){return system.label.COMM001_TAG048;} //Edit
    public string getTAG013(){return system.label.COMM001_TAG049;} // Delete
    public string getTAG014(){return system.label.COMM001_TAG057;} // Are you sure
    public string getTAG015(){return system.label.COMM001_TAG051;} // Please select only one record to perform this action
    public string getTAG016(){return system.label.COMM001_TAG050;} //Please select at least one record to perform this action
    public string getTAG017(){return system.label.COMM001_TAG041;} // Processing...
    public string getTAG018(){return system.label.COMM001_TAG052;} // Record(s) deleted successfully
    public string getTAG019(){return 'An unexpected error occured. Please contact to your ServiceMax Administrator.';} //system.label.CONF036_
    public string getTAG020(){return system.label.COMM001_TAG016;} // 'Active'
}