/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A Singleton class to log Audit trail informations.
 *
 *
 * @author Ramachandra Mohan
 * @version 20.1
 * @since 2019
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       14 Nov 2019     Created.
 *****************************************************************************************************/
public with sharing class COMM_AuditTrail {
    
    /**
     * Nested class to hold audit trail information.
     */
    public class AuditTrailInfo {
        
        public String action;
        public String actionType;
        public String entityName;
        public String application;
        public String additionalInfo;
        public String internalId;
        public String oldValue;
        public String newValue;
    }
    /*
      Capture Audit log delta changes
	*/
    public class AuditData {
       public String oldValue;
       public String newValue;
       public String additionalInfo;
    }
    
    /**
     * Static constant variable to hold instance of this class.
     */
    private static final COMM_AuditTrail instance = new COMM_AuditTrail();
    
    /**
     * Static method to retrieve instance of this class.
     */
    public static COMM_AuditTrail getInstance() {
        return instance;
    }
    
    /**
     * This method is used to log audit trail information to View ServiceMax Configuration Change.
     * 
     * @param auditTrailInfo Instance of AuditTrailInfo with audit trail details record to be created.
     */
    public void logAudit( final AuditTrailInfo auditTrailInfo ) {
        
        System.debug( LoggingLevel.INFO, 'logAudit() - enter; auditTrailInfo= ' + auditTrailInfo);
        
        try {
            // Verify firld level security and insert audit trail record.
            if( String.isNotBlank(auditTrailInfo.application ) && String.isNotBlank(auditTrailInfo.action ) ) {
                SVMXC__Config_Change_Detail__c auditTrailInfoRecord = new SVMXC__Config_Change_Detail__c();
                auditTrailInfoRecord.SVMXC__Entity_Name__c = auditTrailInfo.entityName;
                auditTrailInfoRecord.SVMXC__Application__c = auditTrailInfo.application;
                auditTrailInfoRecord.SVMXC__Action_Type__c = auditTrailInfo.actionType;
                auditTrailInfoRecord.SVMXC__Action__c = auditTrailInfo.action;
                auditTrailInfoRecord.SVMXC__Additional_information__c = auditTrailInfo.additionalInfo;
                auditTrailInfoRecord.SVMXC__SM_Internal_ID__c = auditTrailInfo.internalId;
                auditTrailInfoRecord.SVMXC__SM_Old_Value__c = auditTrailInfo.oldValue;
                auditTrailInfoRecord.SVMXC__SM_New_Value__c = auditTrailInfo.newValue;
        
                // Retrieve and assign current user id and time.
                auditTrailInfoRecord.SVMXC__User__c = UserInfo.getUserId();
                auditTrailInfoRecord.SVMXC__Date__c = DateTime.now();
        
                if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( auditTrailInfoRecord, COMM_SecurityUtils.Access.Createable) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            	insert auditTrailInfoRecord;
            }
        }
        catch(Exception e) {
            System.debug( LoggingLevel.FINEST, 'logAudit() - exit');
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'logAudit() - exit');
        }
    }

    /**
     * This method is used to log audit trail information to View ServiceMax Configuration Change.
     * 
     * @param auditTrailInfo Instance of AuditTrailInfo with audit trail details record to be created.
     * @param auditData Instance of AuditData with delta changes added to the record.
     */
    public void logAudit( final AuditTrailInfo auditTrailInfo, final AuditData auditData) {
       if (auditData != null) {
           auditTrailInfo.oldValue = auditData.oldValue;
           auditTrailInfo.newValue = auditData.newValue;
           auditTrailInfo.additionalInfo = auditData.additionalInfo;
       }
       logAudit(auditTrailInfo);
    }
	/**
     * Private class constructor.
     */    
    private COMM_AuditTrail() {}
}