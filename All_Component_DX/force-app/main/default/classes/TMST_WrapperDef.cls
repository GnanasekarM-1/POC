/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The TMST_WrapperDef class contains request and response structures. This
 * structures are used to process Save/SaveAs/Delete/Rtrieve operations by 
 * Timesheet Manager services. Also used by Timesheet Controller to create
 * TMST_Request and create JSON string from TMST_Response.
 *
 * @author Ramachandra Mohan
 * @version 15.39100
 * @since 2015
 */
/*****************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************
 *              Ramachandra Mohan      28 Jan 2015     Created. 
 * 018852       Ramachandra Mohan      10 Jul 2015     New fields to support timezone.
 *              Ramachandra Mohan      31 Mar 2016     Security fixes.
 *              Sourabh Singh          19 Dec 2016     BAC-1276 to support prior time sheet entries
 *  BAC-5189    Soumyaranjan Pati      9th Sept 2019   Configuration Profile Setting to Filter Which Users have Timesheets Processed 
 *****************************************************************************/

global with sharing class TMST_WrapperDef {

    global class ObjectInfo {
    
        public String Id;
        public String name;
        
        public ObjectInfo() {}
    }
    
    global class SalesforceProfileInfo{ // Added for BAC-5189
        public List<ObjectInfo> salesforceProfileIds = new List<ObjectInfo>();
        public SalesforceProfileInfo(){}
    }
    
    //Added for BAC-5189
    global class SalesforceProfileAssociation {
    
        public String profileId;
        public String profileName;
        public String description;
        public Boolean leaf = true;
        public String timesheetProcessId;
        public String timesheetProcessName;
        
    }
    //End for BAC-5189

    global class TMST_WorkDetailOwnership {
    
        webservice String labelName {set; get;}
        webservice String apiName {set; get;}
        
        global TMST_WorkDetailOwnership() {}
    }
    
    global class TMST_TimesheetConfiguration {
        
        webservice SVMXC__ServiceMax_Processes__c timesheetProcess = new SVMXC__ServiceMax_Processes__c();
        webservice List<SVMXC__ServiceMax_Config_Data__c> scheduleDetailsList = new List<SVMXC__ServiceMax_Config_Data__c>();
        webservice List<TMST_TimesheetAccess> assignedProfilesList = new List<TMST_TimesheetAccess>();
        webservice String scheduleType;
        
        global TMST_TimesheetConfiguration() {}
    }
    
    global class TMST_TimesheetAccess {
    
        webservice SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c();

        webservice String timesheetProcessId {set; get;}
        webservice String timesheetProcessName {set; get;}
        
        global TMST_TimesheetAccess() {}
    }
    
    global class TMST_Request {
    
        webservice List<TMST_TimesheetConfiguration> timesheetConfigurationList = new List<TMST_TimesheetConfiguration>();
       
        global TMST_Request() {}
    }
    
    global class TMST_Response {

        webservice Boolean success {set; get;}
        webservice Boolean warning {set; get;}
        webservice List<String> messageList {set; get;}
        
        webservice List<TMST_TimesheetConfiguration> timesheetConfigurationList = new List<TMST_TimesheetConfiguration>();
        webservice List<TMST_TimesheetAccess> profileAssociationList = new List<TMST_TimesheetAccess>();
        webservice List<BusinessHours> businessHoursList = new List<BusinessHours>();
        webservice List<TMST_WorkDetailOwnership> workDetailOwnershipList = new List<TMST_WorkDetailOwnership>();
        webservice List<ObjectInfo> timezoneList = new List<ObjectInfo>();
        
        webservice List<ObjectInfo> priorPeriodList = new List<ObjectInfo>();//Added BAC-1276:19Dec2016
        webservice List<ObjectInfo> workDetailsMappingList = new List<ObjectInfo>();
        webservice List<ObjectInfo> workDetailsRuleList = new List<ObjectInfo>();
        webservice List<ObjectInfo> taskMappingList = new List<ObjectInfo>();
        webservice List<ObjectInfo> taskRuleList = new List<ObjectInfo>();
        webservice List<ObjectInfo> eventMappingList = new List<ObjectInfo>();
        webservice List<ObjectInfo> eventRuleList = new List<ObjectInfo>();
        webservice List<ObjectInfo> servicemaxEventMappingList = new List<ObjectInfo>();
        webservice List<ObjectInfo> servicemaxEventRuleList = new List<ObjectInfo>();
        webservice List<SalesforceProfileAssociation> salesforceProfileIds = new List<SalesforceProfileAssociation>(); // Added for BAC-5189   
        global TMST_Response() {
        
            this.success = true;
            this.warning = false;
            this.messageList = new List<String>();
        }
    }
}