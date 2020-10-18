/*--------------------------------------------File Definition ----------------------*/
//CONF_ManageScheduledSFM is the controller class for VF page CONF_ManageScheduledSFM
//Created as part of Feb 14 Sprint for ScheduledSFM feature development

public with sharing class CONF_ManageScheduledSFM{
    
    /** Start - NPS Related code **/
    public string getUserLocaleKey(){
        return UserInfo.getLanguage();
    }
    public string getUserID(){
        return UserInfo.getUserId().substring(0, 15);
    }
    public string getUserOrgID(){
        return UserInfo.getOrganizationId().substring(0, 15);
    }
    /** End - NPS Related code **/

/*---------------Global variable declaration--------------------------------------------------*/

    public List<SVMXC__ServiceMax_Processes__c> lstCustomProcess{get;set;}
    public boolean isCustomButtonEnabled = false;
    public void setIsCustomButtonEnabled(boolean isEnabled){ this.isCustomButtonEnabled = isEnabled; }
    public boolean getIsCustomButtonEnabled(){ return this.isCustomButtonEnabled; }
    public String strActionType {set; get;}
    private integer intBatchLimit = 5;
    
/*---------------------------Constructor-------------------------------------------------------*/

    public CONF_ManageScheduledSFM(){
        try{
            isCustomButtonEnabled = false;
            lstCustomProcess = new List<SVMXC__ServiceMax_Processes__c>();
            lstCustomProcess = [select Id, SVMXC__ProcessID__c, //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                                            SVMXC__Select__c, 
                                            SVMXC__Name__c, 
                                            SVMXC__Description__c, 
                                            SVMXC__IsStandard__c, 
                                            LastModifiedBy.Name, 
                                            LastModifiedDate,
                                            (SELECT ID, SVMXC__Schedule_Type__c 
                                                FROM SVMXC__ServiceMax_Config_Data__r 
                                                    WHERE  RecordType.Name ='Schedule Detail'),
                                            SVMXC__Active__c 
                                                from  SVMXC__ServiceMax_Processes__c 
                                                where SVMXC__Record_Type_Name__c ='Schedule Header' and SVMXC__IsStandard__c = false order By SVMXC__ProcessID__c];
            if(lstCustomProcess.size() == 0)
                isCustomButtonEnabled = true;
            System.debug(LoggingLevel.WARN, 'lstCustomProcess in constructor :' + lstCustomProcess);
            
            //getting setting
            map<string, Map<String, String>> mapSubmoduleIdMapSeetingIdValue = new map<string, Map<String, String>>(); 
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            list<string> lstSubModuleId = new list<string>();
            lstSubModuleId.add('GLOB001');
            mapSubmoduleIdMapSeetingIdValue = commSettings.SVMX_getSettingList(lstSubModuleId);
            map<String,String> mapGlobalSeetingIdValue = new map<String,String>(); 
            if(mapSubmoduleIdMapSeetingIdValue.containskey('GLOB001'))
                mapGlobalSeetingIdValue = mapSubmoduleIdMapSeetingIdValue.get('GLOB001'); 
            if(mapGlobalSeetingIdValue.containskey('GBL020'))
                intBatchLimit = integer.valueOf(mapGlobalSeetingIdValue.get('GBL020'));
            System.debug(LoggingLevel.WARN, 'Batch Limit in Constructor : ' + intBatchLimit);
        }catch(exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
    }
    
/*--------------------------------------------Public methods-------------------------------------*/
    
    //method to Run scheduled SFM process instantly
    public PageReference runCustomProcess(){
        try{
            String strRecordId = '';
            Integer intSelectedCount = 0;
            for(SVMXC__ServiceMax_Processes__c objProcess: lstCustomProcess){
                if(objProcess.SVMXC__Select__c == true){
                    intSelectedCount += 1;
                    strRecordId = objProcess.Id;
                }
            }
            if( intSelectedCount == 1 ){ 
                for(SVMXC__ServiceMax_Processes__c objProcess: lstCustomProcess){
                    system.debug(objProcess);
                    List<SVMXC__ServiceMax_Config_Data__c> listScheduleDetail = objProcess.SVMXC__ServiceMax_Config_Data__r;
                    List<SVMXC__ServiceMax_Config_Data__c> listValidScheduleSFM = new List<SVMXC__ServiceMax_Config_Data__c>();
                    for(SVMXC__ServiceMax_Config_Data__c scheduleSFMServiceRec: listScheduleDetail){
                        if(scheduleSFMServiceRec.SVMXC__Schedule_Type__c == '' || scheduleSFMServiceRec.SVMXC__Schedule_Type__c == null)
                            listValidScheduleSFM.add(scheduleSFMServiceRec);
                    }
                    
                    system.debug(listValidScheduleSFM + '--------------');
                    if(objProcess.SVMXC__Select__c == true && objProcess.SVMXC__Active__c == false){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.CONF039_TAG005,''));
                        return null;
                    }
                    
                    /*else if(objProcess.SVMXC__Select__c == true && (listValidScheduleSFM != null && listValidScheduleSFM.size() == 0)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.CONF039_TAG047, ''));
                        return null;
                    }*/
                }
                
                List<AsyncApexJob> lstApexJob = new List<AsyncApexJob>();
                lstApexJob = [SELECT Id, Status FROM AsyncApexJob Where JobType = 'BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                if(lstApexJob.size() < intBatchLimit){
                    SFM_ExecuteScheduledSFM_Batch BatchObj = new SFM_ExecuteScheduledSFM_Batch();
                    BatchObj.setProIds.add(strRecordId);
                    database.executebatch(BatchObj,1);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, System.label.CONF039_TAG003,''));
                }
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.CONF039_TAG004,''));
                return null;
            }
            else if( intSelectedCount == 0 ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG050,''));
                return null;
            }    
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG051,''));
                return null;
            }
        }catch(exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    //method to clone a process
    public pagereference cloneCustomScheduledSFMProcess(){
        String strRecordId = '';
        Integer intSelectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c objProcess: lstCustomProcess){
            if(objProcess.SVMXC__Select__c == true){
                intSelectedCount += 1;
                strRecordId = objProcess.Id;
            }
        }        
        if( intSelectedCount == 1 ){
            String loc = '/apex/CONF_SetupScheduledSFM?SVMX_RecordId='+ strRecordId + '&SVMX_Mode=Clone';
            PageReference objPageReference = new PageReference(loc);
            return objPageReference;
        }
        else if( intSelectedCount == 0 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG050,''));
            return null;
        }    
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG051,''));
            return null;
        }
    }
    
    //method for backTo Setup Home and also for Creation of NEW process
    public PageReference backToSetupHomeAndNewProcess(){
        PageReference objPageReference;
        if(strActionType.equals('SetupHome')){
            //Changes done by Nidhi as part of BAC-4747. Handling redirection on Lightning Experience
            String url='';
            if(UserInfo.getUiThemeDisplayed()=='Theme4d' || UserInfo.getUiThemeDisplayed()=='Theme4u'){
                url = '/lightning/n/SVMXC__ServiceMax_Setup';
            }else{
                url ='/apex/SVMXC__CONF_SetupHome';
            }
            objPageReference = new PageReference(url);
        }
        else if(strActionType.equals('New')){
            objPageReference = new PageReference('/apex/CONF_SetupScheduledSFM');
            objPageReference.getParameters().put('SVMX_Mode','New');
        }
        objPageReference.setredirect(true);     
        return objPageReference;
    }
    
    //method to edit the selected process
    public PageReference editCustomScheduledSFMProcess(){
        String strRecordId = '';
        Integer intSelectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c objProcess: lstCustomProcess){
            if(objProcess.SVMXC__Select__c == true){
                intSelectedCount += 1;
                strRecordId = objProcess.Id;
            }
        }
        
        if( intSelectedCount == 1 ){
            String loc = '/apex/CONF_SetupScheduledSFM?SVMX_RecordId='+ strRecordId + '&SVMX_Mode=Edit';
            PageReference objPageReference = new PageReference(loc);
            return objPageReference;
        }
        else if( intSelectedCount == 0 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG050,''));
            return null;
        }    
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG051,''));
            return null;
        }
    }
    
    //method to delete the selected process
    public pagereference deleteCustomScheduledSFMProcess(){
        String strRecordId = '';
        Integer intSelectedCount = 0;
        for(SVMXC__ServiceMax_Processes__c objProcess: lstCustomProcess){
            if(objProcess.SVMXC__Select__c == true){
                intSelectedCount += 1;
                strRecordId = objProcess.Id;
            }
        }
        if(intSelectedCount == 1 && strRecordId != null){
            Savepoint objSavePoint;
            try{
                SVMXC__ServiceMax_Processes__c objHeaderProcess = [Select Id from SVMXC__ServiceMax_Processes__c Where Id =: strRecordId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                List<SVMXC__ServiceMax_Config_Data__c> lstConfigdataScheduleAndDetail = [Select Id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c =: strRecordId and (RecordType.Name = 'Schedule Detail' OR RecordType.Name = 'Schedule')]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                System.debug(LoggingLevel.WARN, 'objHeaderProcess in deleteCustomScheduledSFMProcess method :' + objHeaderProcess);
                System.debug(LoggingLevel.WARN, 'lstConfigdataScheduleAndDetail in deleteCustomScheduledSFMProcess method :' + lstConfigdataScheduleAndDetail);
                
                //delete lstConfigdataScheduleAndDetail;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Config_Data__c')){
                    delete lstConfigdataScheduleAndDetail; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                    Database.rollback(objSavePoint);
                    return null;
                }
                //delete objHeaderProcess;
                if(COMM_SecurityUtils.getInstance().isDeletableObject('SVMXC__ServiceMax_Processes__c')){
                    delete objHeaderProcess; //SDL-SVMX-DELETE-FLS-ENFORCED
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG142));
                    Database.rollback(objSavePoint);
                    return null;
                }
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, System.label.COMM001_TAG052,''));
                
                lstCustomProcess = [SELECT Id, SVMXC__Select__c, SVMXC__ProcessID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__Active__c, LastModifiedBy.Name, LastModifiedDate FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Record_Type_Name__c ='Schedule Header' AND SVMXC__IsStandard__c = false order By SVMXC__ProcessID__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                System.debug(LoggingLevel.WARN, 'lstCustomProcess in deleteCustomScheduledSFMProcess method :' + lstCustomProcess);
                if(lstCustomProcess.size() == 0)
                    isCustomButtonEnabled = true;
                return null;
            }
            catch(exception ex){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.COMM001_TAG077));
                Database.rollback(objSavePoint);
                return null;
            }
        }
        else if(intSelectedCount == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG050,''));
            return null;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.COMM001_TAG051,''));
            return null;
        }
    }
}