/*****************************************************************************
*                       Copyright (C) 2018 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The SFM_Wizard_LightningController calls the optimized INTF_GetServiceFlowWizard class to
* load the Wizards and wizard steps. It also defines the wrapper format in which the response is given back to the Lightning component
* @author Anchal Sharma
* @since 2018
*/
/*****************************************************************************
*    ID        Name                   Date            Comment
*****************************************************************************
*              Anchal Sharma        15 March 2018        Created.     
*****************************************************************************/
public with sharing class SFM_Wizard_LightningController {
    
    // a) Get the record ID from teh VF component
    
    @AuraEnabled
    public static RecordWizard getWizards(string recordId) {
        INTF_GetServiceFlowWizard sfwData = new INTF_GetServiceFlowWizard();
        RecordWizard responseWiz = new RecordWizard();
        responseWiz = sfwData.getLightningSFW(recordId, 'LIGHTNING');
        responseWiz.strSitePrefix = Site.getPathPrefix();
        responseWiz.isCommunityRunning = Site.getSiteId() != null ? true : false; //Added for the defect 046614 fix
        return responseWiz;
    }
    
    
    public class WizardStep{
        @AuraEnabled
        public String name; 
        
        @AuraEnabled
        public Boolean isDisabled;
        @AuraEnabled
        public String actionType; 
        @AuraEnabled
        public String actionURL;
        @AuraEnabled
        public Boolean isConfirmationMessageEnabled;
        @AuraEnabled
        public String confirmationMessage;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String winType;
        @AuraEnabled
        public String winWidth;
        @AuraEnabled
        public String winHeight;
        @AuraEnabled
        public String winScroll;
        @AuraEnabled
        public String fullscreen;
        @AuraEnabled
        public String processid;
        @AuraEnabled
        public String modeofexecution;
        @AuraEnabled
        public Boolean selectTemplateAtRuntime;
        
        public WizardStep(){}
    }
    
    public class RecordWizard {
        @AuraEnabled
        public Map <Id, SVMXC__ServiceMax_Processes__c> mapWizIdRecord;
        @AuraEnabled
        public Map <Id, List<WizardStep>> mapWizIdWizSteps;
        @AuraEnabled
        public String strSitePrefix;
        @AuraEnabled
        public Boolean isCommunityRunning; //Added for the defect 046614 fix
        public RecordWizard (){}
    }
    
    @AuraEnabled
    public static List<OutputDocTemplateWrapper> getOutputDocTemplate(string recordId) {
        List<OutputDocTemplateWrapper> listOPDOCTemplate = new List<OutputDocTemplateWrapper>();
        if(String.isNotBlank(recordId)){
           INTF_WebServicesDef.INTF_Response responseObj = new INTF_WebServicesDef.INTF_Response(); 
            responseObj = INTF_WebServicesDef.INTF_GetSFWOutputTemplate_WS(recordId);
            
            if(responseObj != null && responseObj.valueMap != null && responseObj.valueMap.size() > 0){
                System.debug(logginglevel.INFO, 'Opdoc - responseObj ValueMap :' + responseObj.valueMap );
                for(INTF_WebServicesDef.SVMXMap docItr : responseObj.valueMap){
                    SVMXC__ServiceMax_Processes__c processRec = (ServiceMax_Processes__c)docItr.record;
                    OutputDocTemplateWrapper processWrapRec = new OutputDocTemplateWrapper(processRec, recordId);
                    System.debug(logginglevel.INFO, 'Opdoc - responseObj  Wrapper Record:' + processWrapRec );
                    listOPDOCTemplate.add(processWrapRec);
                }
            }    
        }
        return listOPDOCTemplate;
    }

    @AuraEnabled
    public static boolean isCommunity(){
     Id siteId = Site.getSiteId(); 
        if (siteId != null) {
           return true;
        }
     return false;
    }

    public class OutputDocTemplateWrapper{
    @AuraEnabled
        public String processRecName; 
        
        @AuraEnabled
        public String description; 
            
        @AuraEnabled
        public String targetUrl ;
        
        public OutputDocTemplateWrapper(SVMXC__ServiceMax_Processes__c outputDocRec, String recordId){
          this.processRecName = outputDocRec.Name__c ;
            this.description = outputDocRec.Description__c ; 
            String sitePrefix = Site.getPathPrefix();
            if(String.isEmpty(sitePrefix)) sitePrefix = '';
            sitePrefix = sitePrefix.replace('/s','');
            this.targetUrl = sitePrefix + '/apex/SVMXC__OPDOC_Delivery?SVMX_processId=' + outputDocRec.SVMXC__ProcessID__c + '&SVMX_recordId=' + recordId + '&SVMX_retURL=/' + recordId;
        }
    }
    
    
    public String getTAG017(){return System.Label.SFW001_TAG017;}
    public String getTAG018(){return System.Label.SFW001_TAG018;}
   
}