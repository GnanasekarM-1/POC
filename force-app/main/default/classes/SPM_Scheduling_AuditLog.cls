/**
 * Class holding the execution status. Message accumulated here will be emailed to the 
 * configured user's emailid. 
 **/
public class SPM_Scheduling_AuditLog {

    public List<String> messages = new List<String>();
    
    public integer totalRecordsCount = 0;
    
    public boolean isSuccess = true;
 
    public DateTime startTime;
    
    public DateTime endTime;

    
    public void addMessage(String value) {
        messages.add(value);
    }
    
    public void addFailureMessage(String value) {
        isSuccess = false;
        messages.add(value);
    }
    
    /**
     * Creates a audit record in the system and triggers an email to the user about the status.
     **/
    public void saveAuditAndSendMessage(String emailOnSuccess, String actionName) {
        
        System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_AuditLog.saveAuditAndSendMessage() - enter');
        
        SVMXC__SVMX_Jobs__c objJob = new SVMXC__SVMX_Jobs__c();
        objJob.SVMXC__Type__c = 'SPM Scheduling';
        objJob.SVMXC__Start_Time__c = this.startTime;
        objJob.SVMXC__End_Time__c = System.now();
        objJob.SVMXC__Batch_Job__c = actionName;
        objJob.SVMXC__Status__c = ( this.isSuccess ) ? 'Success' : 'Failed';
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objJob, COMM_SecurityUtils.Access.Createable ) ) {
            insert objJob;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
         
         
        String message = SPM_Utilities.getInstance().buildString(this.messages, '\n' );
         
        Attachment objAttach = new Attachment();
        blob attachBlob = Blob.valueOf( message );
        objAttach.Body = attachBlob;
        objAttach.ParentId = objJob.id;
        objAttach.Name = 'SPM Scheduling.txt';
        //Security check
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( objAttach, COMM_SecurityUtils.Access.Createable ) ) {
            insert objAttach;
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }

        if( emailOnSuccess != null ) {
            
            TimeZone tz = UserInfo.getTimeZone(); 
            
            
            Messaging.SingleEmailMessage singleEmailMessage =new Messaging.SingleEmailMessage();            
            singleEmailMessage.setSubject( actionName + ' ' + objJob.SVMXC__End_Time__c.format('MM/dd/yyyy HH:mm:ss', tz.getID() ) );
            singleEmailMessage.saveAsActivity = false;
            singleEmailMessage.setToAddresses(new List<String> {emailOnSuccess});
            singleEmailMessage.setPlainTextBody( message );
            
            List<Messaging.SingleEmailMessage> emailMessageList =  new List<Messaging.SingleEmailMessage> {
                singleEmailMessage    
            };
            
            try {
                if( !Test.isRunningTest() ) {
                    Messaging.sendEmail( emailMessageList );    
                }
            }
            catch( Exception ex ) {
                System.debug( LoggingLevel.ERROR, ex.getMessage() );
            }  
        }
        
       System.debug( LoggingLevel.DEBUG, 'SPM_Scheduling_AuditLog.saveAuditAndSendMessage() - exit');
    }
}