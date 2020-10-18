/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief The SPM_WrapperDef class contains request and response structures. This
 * structures are used to process Save/SaveAs/Delete/Retrieve operations by 
 * SPM configuration services. Also used by SPM Controller to create
 * SPM_Request and create JSON string from SPM_Response.
 *
 * @author Ramachandra Mohan
 * @version 15.59100
 * @since 2015
 */
/****************************************************************************************
 *    ID        Name                   Date            Comment
 ****************************************************************************************
 *              Ramachandra Mohan      08 Oct 2015     Created.
 *              Ramachandra Mohan      31 Mar 2016     Updated class with 'with sharing'.
 ****************************************************************************************/

global with sharing class SPM_WrapperDef {
    
    global class ObjectInfo {
    
        public String Id;
        public String name;
        
        public ObjectInfo() {}
    }
    
    global class AuditLogInfo {
        
        webservice Id attachmentId { set; get; }
        webservice SVMXC__SVMX_Jobs__c jobs { set; get;}
            
        global AuditLogInfo(){            
        }
    }
    
    global class SPM_ProcessDetails {
        
        webservice Boolean isActive {set; get;}
        Webservice String scheduleId { set; get;}
        Webservice String processId { set; get;}
        Webservice String processName { set; get;}
        Webservice String description { set; get;}
        Webservice String timezone { set; get;}        
        Webservice String emailOnSuccess { set; get;}
        Webservice String emailOnFailure { set; get;}
        Webservice String dashboardId { set; get;}
        webservice String ruleDetailsMetaJSON {set; get;}
        webservice List<SVMXC__ServiceMax_Config_Data__c> spmDetailsList = new List<SVMXC__ServiceMax_Config_Data__c>();
        
        global SPM_ProcessDetails() {}
    }
    
	global class SPM_Request {
        
        webservice List<SPM_ProcessDetails> spmProcessDetailsList = new List<SPM_ProcessDetails>();
        global SPM_Request() {}
    }
    
    global class SPM_Response {

        webservice Boolean success {set; get;}
        webservice Boolean warning {set; get;}
        webservice List<String> messageList {set; get;}        
        webservice List<SPM_ProcessDetails> spmProcessDetailsList = new List<SPM_ProcessDetails>();
        webservice List<AuditLogInfo> spmJobsList = new List<AuditLogInfo>();
        webservice List<ObjectInfo> timezoneList = new List<ObjectInfo>();
        
        global SPM_Response() {
            messageList = new List<String>();
        }
    }
}