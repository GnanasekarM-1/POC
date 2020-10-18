public with sharing class CONF_ManageFulfillmentProcesses 
{
    //public List<SVMXC__ServiceMax_Processes__c> stndProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    //public List<SVMXC__ServiceMax_Processes__c> getstndProcessLst(){return this.stndProcessLst;}
    //public void setstndProcessLst(List<SVMXC__ServiceMax_Processes__c> o){this.stndProcessLst = o;}
    public List<SVMXC__ServiceMax_Processes__c> custmProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getcustmProcessLst(){return this.custmProcessLst;}
    public void setcustmProcessLst(List<SVMXC__ServiceMax_Processes__c> o){this.custmProcessLst = o;}
    public boolean DisableStdBtn = false;
    public boolean getDisableStdBtn(){return this.DisableStdBtn;}
    public void setDisableStdBtn(boolean b){this.DisableStdBtn = b;}
    public boolean DisableCusBtn = false;
    public List<SelectOption> sourceObjectsOptns = new  List<SelectOption>();
    public boolean getDisableCusBtn(){return this.DisableCusBtn;}
    
    public CONF_ManageFulfillmentProcesses()
    {
       // stndProcessLst = [select Id, SVMXC__Select__c, SVMXC__ProcessId__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedBy.Name from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c = 'Forward Shipment Process' and SVMXC__IsStandard__c = true];
        custmProcessLst = [select Id, SVMXC__Select__c, SVMXC__ProcessId__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedBy.Name from  SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Fulfillment Process' and SVMXC__IsStandard__c = false Order BY SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        //if(stndProcessLst.size() == 0)
        //{
        //    DisableStdBtn = true;
       // }
       // else
          //  DisableStdBtn = false;
            
        if(custmProcessLst.size() == 0)
        {
            DisableCusBtn = true;
        }
        else
            DisableCusBtn = false;
    }
    /* public pagereference StdView()
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
            String loc = '/apex/CONF_SetupFulfillmentProcess?SVMX_RecordId='+SVMX_RecordId;
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG018(),''));
            return null;
        }
    } */
    /* public pagereference StdClone()
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
            String loc = '/apex/CONF_SetupFulfillmentProcess?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Mode=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG018(),''));
            return null;
        }
    } */
    
    public pagereference backToSetupHome()
    {
        //String location = '/apex/CONF_SetupHome';
         //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
        String url='';
        if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
            url = '/lightning/n/SVMXC__ServiceMax_Setup';
        }else{
            url ='/apex/CONF_SetupHome';
        }
        PageReference pr = new PageReference(url);
        pr.setredirect(true);
        return pr;
    }
    
    public pagereference newRcvProcess()
    {
        PageReference pageRef = new PageReference('/apex/CONF_SetupFulfillmentProcess');
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
            String loc = '/apex/CONF_SetupFulfillmentProcess?SVMX_RecordId='+SVMX_RecordId;
            PageReference pr = new PageReference(loc);
            pr.setRedirect(true);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG018(),''));
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
            String loc = '/apex/CONF_SetupFulfillmentProcess?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Mode=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG018(),''));
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
                SVMXC__ServiceMax_Processes__c fulfillmentProcess = new SVMXC__ServiceMax_Processes__c();
                List<SVMXC__ServiceMax_Processes__c> lstPathRules = new List<SVMXC__ServiceMax_Processes__c>();
                List<SVMXC__ServiceMax_Config_data__c> lstConfDataToDelete = new List<SVMXC__ServiceMax_Config_data__c>();
                List<ID> lstPathRulesID = new List<ID>();
                RecordType Rtype_FulFillmentProcess;
                RecordType Rtype_Prod_Doc_Attributes;
                
                Rtype_FulFillmentProcess = [select Id from RecordType where Name = 'Fulfillment Process' and SobjectType = 'SVMXC__ServiceMax_Processes__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                Rtype_Prod_Doc_Attributes = [Select Id, Name from RecordType where Name = 'Field Mapping' AND SObjectType = 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                fulfillmentProcess = [Select Id from SVMXC__ServiceMax_Processes__c where Id =: SVMX_RecordId AND RecordTypeId =: Rtype_FulFillmentProcess.Id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                lstConfDataToDelete = [select id, SVMXC__Dispatch_Process__c, SVMXC__Configuration_Type__c, SVMXC__Sequence__c, SVMXC__Field_Name__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: FulfillmentProcess.Id AND SVMXC__Dispatch_Process__c != null AND RecordTypeId =:Rtype_Prod_Doc_Attributes.Id AND (SVMXC__Configuration_Type__c = 'PRODUCT_ATTRIBUTE' OR SVMXC__Configuration_Type__c = 'DOCUMENT_ATTRIBUTE')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstConfDataToDelete != null && lstConfDataToDelete.size() >0){
                    //delete lstConfDataToDelete;
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                        delete lstConfDataToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                lstConfDataToDelete.clear();
                
                lstPathRules = [Select Id, SVMXC__Name__c, RecordTypeId, SVMXC__ProcessID__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__Rule_Type__c, SVMXC__Parent_Column_Name__c, SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__IsDefault__c, LastModifiedDate from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c =: FulfillmentProcess.Id AND SVMXC__Process__c!= null AND RecordType.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'FulFillment Path']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                
                if(lstPathRules != null && lstPathRules.size() > 0)
                {
                    for(SVMXC__ServiceMax_Processes__c pro : lstPathRules)
                        lstPathRulesID.add(pro.Id);
                    
                    if(lstPathRulesID != null && lstPathRulesID.size() >0)
                    {
                        lstConfDataToDelete = [Select Id, SVMXC__Sequence__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Dispatch_Process__c, SVMXC__IsDefault__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN: lstPathRulesID AND RecordType.Name = 'Fulfillment Path' AND SVMXC__Location__c != NULL AND SVMXC__Dispatch_Process__c != null Order By SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                        
                        if(lstConfDataToDelete != null && lstConfDataToDelete.size() >0){
                            //delete lstConfDataToDelete;
                            if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                                delete lstConfDataToDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                            }
                            else{
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                                return null;
                            }
                        }
                    }
                    //delete lstPathRules;
                    if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                        delete lstPathRules; //SDL-SVMX-DELETE-FLS-ENFORCED
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                        return null;
                    }
                }
                
                //delete fulfillmentProcess;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete fulfillmentProcess; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                    return null;
                }
                
                custmProcessLst = [select Id, SVMXC__Select__c, SVMXC__ProcessId__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c = 'Fulfillment Process' and SVMXC__IsStandard__c = false Order BY SVMXC__Name__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(custmProcessLst.size() == 0)
                    DisableCusBtn = true;
                else
                    DisableCusBtn = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,getTAG019(),''));
            }
            catch(exception ex)
            {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+ex.getMessage(),''));
            }
            return null;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG017(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,getTAG018(),''));
            return null;
        }
        return null;
    }
    
    //Custom labels / tags
    public String getTag001(){ return system.label.CONF028_TAG001;} //'Processing...' 
    public String getTag002(){ return system.label.CONF028_TAG002;} //'Fulfillment Processes'
    //public String getTag003(){ return 'View' ;}
    public String getTag004(){ return system.label.CONF028_TAG003;} //'Clone' 
    public String getTag005(){ return system.label.CONF028_TAG004;} //'Back To Setup Home'
    public String getTag006(){ return system.label.CONF028_TAG005;} //'Select' 
    public String getTag007(){ return system.label.CONF028_TAG006;} //'Process Id' 
    public String getTag008(){ return system.label.CONF028_TAG007;} //'Process Title' 
    public String getTag009(){ return system.label.CONF028_TAG008;} //'Process Details' 
    public String getTag010(){ return system.label.CONF028_TAG009;} //'Last Modified By' 
    //public String getTag011(){ return 'Custom Forward Shipment Processes' ;}
    public String getTag012(){ return system.label.CONF028_TAG010;} //'New' 
    public String getTag013(){ return system.label.CONF028_TAG011;} //'Edit' 
    public String getTag014(){ return system.label.CONF028_TAG012;} //'Delete' 
    public String getTag015(){ return system.label.CONF028_TAG013;} //'Are you sure?' 
    public string getHLPURL() {return system.label.CONF028_HLPURL;} //'Help URL'
    public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'
    //public String getTAG016(){ return 'Back To Setup Home' ;}
    public String getTAG017(){ return system.label.CONF028_TAG014;} //'Please select a process to perform this operation.'
    public String getTAG018(){ return system.label.CONF028_TAG015;} //'Please select only one process to perform this operation.'
    public String getTAG019(){ return system.label.CONF028_TAG016;} //'The selected Process was successfully deleted'
}