public with sharing class CONF_ManageForwardShipments 
{
    public List<SVMXC__ServiceMax_Processes__c> custmProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> getcustmProcessLst(){return this.custmProcessLst;}
    public void setcustmProcessLst(List<SVMXC__ServiceMax_Processes__c> o){this.custmProcessLst = o;}
    public boolean DisableCusBtn = false;
    public List<SelectOption> sourceObjectsOptns = new  List<SelectOption>();
    public boolean getDisableCusBtn(){return this.DisableCusBtn;}
    public list<SVMXC__ServiceMax_Config_Data__c> lstConfigExp = new list<SVMXC__ServiceMax_Config_Data__c>();
    public list<SVMXC__ServiceMax_Config_Data__c> lstConfigScheduleRec = new list<SVMXC__ServiceMax_Config_Data__c>();
    public RecordType Rtype_Expressions;
    public RecordType Rtype_Schedules;
    
    public CONF_ManageForwardShipments()
    {
        Rtype_Expressions = [select Id from RecordType where Name = 'Expressions' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA 
        Rtype_Schedules = [select Id from RecordType where Name = 'Schedule' AND SobjectType= 'SVMXC__ServiceMax_Config_Data__c' Limit 1]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        custmProcessLst = [select Id, SVMXC__Select__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__ProcessId__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedBy.Name from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c = 'Forward Shipment Process' and SVMXC__IsStandard__c = false]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        
        if(custmProcessLst.size() == 0)
        {
            DisableCusBtn = true;
        }
        else
            DisableCusBtn = false;
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
        PageReference pageRef = new PageReference('/apex/CONF_SetupForwardShipment');
        pageRef.getParameters().put('SVMX_Mode','New');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pagereference BackToHomePage()
    { 
        PageReference pRef = new PageReference('/apex/CONF_SetupHome');  
        return pRef;
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
            String loc = '/apex/CONF_SetupForwardShipment?SVMX_RecordId='+SVMX_RecordId;
            PageReference pr = new PageReference(loc);
            pr.setRedirect(true);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG014(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG015(),''));
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
            String loc = '/apex/CONF_SetupForwardShipment?SVMX_RecordId='+SVMX_RecordId+'&SVMX_Mode=Clone';
            PageReference pr = new PageReference(loc);
            return pr;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG014(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG015(),''));
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
                lstConfigExp = new list<SVMXC__ServiceMax_Config_Data__c>();
                lstConfigScheduleRec = new list<SVMXC__ServiceMax_Config_Data__c>();
                if(SVMX_RecordId != null && SVMX_RecordId.length() > 0)
                {
                    
                    lstConfigExp = [Select Id, SVMXC__Sequence__c, SVMXC__Object_Name__c, SVMXC__Object_Name2__c, SVMXC__Field_Name__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Expression_Rule__c, SVMXC__Expression_Type__c from SVMXC__ServiceMax_Config_Data__c where recordTypeId =: Rtype_Expressions.Id AND SVMXC__Expression_Rule__c =: SVMX_RecordId AND SVMXC__Expression_Type__c = 'Fwd_Shipment_Entry_Criteria']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    if(lstConfigExp != null && lstConfigExp.size() > 0){
                        //delete lstConfigExp;
                        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                            delete lstConfigExp; //SDL-SVMX-DELETE-FLS-ENFORCED
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                            return null;
                        }
                    }
                    
                    lstConfigScheduleRec = [Select Id, SVMXC__Sequence__c, SVMXC__Run_At__c, SVMXC__Schedule_Days__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where recordTypeId =: Rtype_Schedules.Id AND SVMXC__Dispatch_Process__c = :SVMX_RecordId Order by SVMXC__Sequence__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    
                    if(lstConfigScheduleRec != null && lstConfigScheduleRec.size() > 0){
                        //delete lstConfigScheduleRec;
                        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                            delete lstConfigScheduleRec; //SDL-SVMX-DELETE-FLS-ENFORCED
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                            return null;
                        }
                    }
                    List<SVMXC__ServiceMax_Processes__c> lstProcess = [Select Id from SVMXC__ServiceMax_Processes__c where Id = :SVMX_RecordId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    if(lstProcess.size() > 0){
                        //Delete lstProcess;
                        if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                            delete lstProcess; //SDL-SVMX-DELETE-FLS-ENFORCED
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG142));
                            return null;
                        }
                    }
                }
                
                custmProcessLst = [select Id, SVMXC__Select__c, SVMXC__ProcessId__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Forward Shipment Process' and SVMXC__IsStandard__c = false]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(custmProcessLst.size() == 0)
            {
                DisableCusBtn = true;
            }
            else
                DisableCusBtn = false;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, getTag016(),''));
            }
            catch(exception ex)
            {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+ex.getMessage(),''));
            }
            return null;
        }
        else if( selectedCount == 0 )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG014(),''));
            return null;
        }    
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, getTAG015(),''));
            return null;
        }
        return null;
    }
        /************** Custom tags *******************/
        public String getTag001(){return System.Label.CONF030_TAG001;}                  // { return 'Forward Shipment Processes' ;}
        public String getTag002(){return System.Label.CONF030_TAG002;}                 //{ return 'New';}
        public String getTag003(){return System.Label.CONF030_TAG003;}                 //{ return 'Edit' ;}
        public String getTag004(){return System.Label.CONF030_TAG004;}                 //{ return 'Clone' ;}
        public String getTag005(){return System.Label.CONF030_TAG005;}                 //{ return 'Delete';}
        public String getTag006(){return System.Label.CONF030_TAG006;}                 //{ return 'Are you sure?';}
        public String getTag007(){return System.Label.CONF030_TAG007;}                 //{ return 'Processing...';}
        public String getTag008(){return System.Label.CONF030_TAG008;}                 //{ return 'Back To Setup Home' ;}
        public String getTag009(){return System.Label.CONF030_TAG009;}                 //{ return 'Select';}
        public String getTag010(){return System.Label.CONF030_TAG010;}                 //{ return 'Process Title';}
        public String getTag011(){return System.Label.CONF030_TAG011;}                 //{ return 'Process Details';}
        public String getTag012(){return System.Label.CONF030_TAG012;}                 //{ return 'Depot' ;}
        public String getTag013(){return System.Label.CONF030_TAG013;}                 //{ return 'Last Modified By' ;}
        public String getTag014(){return System.Label.CONF030_TAG014;}                 //{ return 'Please select an Action to perform this operation.' ;}
        public String getTag015(){return System.Label.CONF030_TAG015;}                 //{ return 'Please select only one Action to perform this operation' ;}
        public String getTag016(){return System.Label.CONF030_TAG016;}                 //{ return 'The selected Forward Shipment Process was successfully deleted';}
        public string getHLPURL() {return system.label.CONF030_HLPURL;} //'Help URL'
        public string getHLPTITLE() {return system.label.COMM001_TAG064;} //'Help Title'

        
}