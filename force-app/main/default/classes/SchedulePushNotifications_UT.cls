@isTest(seeAllData = true)
class SchedulePushNotifications_UT
{
    static testmethod void testMethod1() 
    {
        Test.startTest();
        User newUser = [Select Id from User Limit 1];
        List<SVMXC__SVMX_Job_Logs__c> listOfLogs = new List<SVMXC__SVMX_Job_Logs__c>();
        SVMXC__SVMX_Job_Logs__c log = new SVMXC__SVMX_Job_Logs__c();
        log.SVMXC__Message__c = 'Test';
        log.SVMXC__Log_Context__c = 'This is test';
        log.SVMXC__Event_Type__c = 'Event';
        log.SVMXC__Group_Id__c = Userinfo.getUserId()+','+newUser.Id;
        log.SVMXC__Log_level__c = 1;
		log.SVMXC__Operation__c = 'PUSH NOTIFICATION';
        log.SVMXC__Call_Status__c = 'NOT_SENT';  
        log.SVMXC__Log_Category__c ='Salesforce';
        listOfLogs.add(log);
        
		log = new SVMXC__SVMX_Job_Logs__c();
        log.SVMXC__Message__c = 'Test';
        log.SVMXC__Log_Context__c = 'This is test';
        log.SVMXC__Event_Type__c = 'Event';
        log.SVMXC__Group_Id__c = Userinfo.getUserId()+','+newUser.Id;
        log.SVMXC__Log_level__c = 1;
		log.SVMXC__Operation__c = 'PUSH NOTIFICATION';
        log.SVMXC__Call_Status__c = 'NOT_SENT';  
        log.SVMXC__Log_Category__c ='Servicemax';        
        listOfLogs.add(log);
        insert listOfLogs;
        
        List<SVMXC__SM_SNS_Detail__c> listOfDetails = new List<SVMXC__SM_SNS_Detail__c>();
		SVMXC__SM_SNS_Detail__c newDetail = new SVMXC__SM_SNS_Detail__c();
        newDetail.SVMXC__SM_User__c=Userinfo.getUserId();
        newDetail.SVMXC__SM_IsActive__c=true;
        newDetail.SVMXC__SM_Status__c='Registered';
        newDetail.SVMXC__SM_TargetARN__c='Test1';
        listOfDetails.add(newDetail);
        
		newDetail = new SVMXC__SM_SNS_Detail__c();
        newDetail.SVMXC__SM_User__c=newUser.Id;
        newDetail.SVMXC__SM_IsActive__c=true;
        newDetail.SVMXC__SM_Status__c='Registered';
        newDetail.SVMXC__SM_TargetARN__c='Test2';
        listOfDetails.add(newDetail);    
        insert listOfDetails;
        
        try
        {
        	String jobId = System.schedule('Test Schedule Push Notifications', '0 0 10 ? * MON-FRI', new SchedulePushNotifications());
        }
        catch(Exception exceptionHandling)
        {
            
        }
        // Verify the next time the job will run
        //System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        //System.assertNotEquals('testScheduledApexFromTestMethodUpdated', [SELECT id, name FROM account WHERE id = :a.id].name);
        Test.stopTest();
        //System.assertEquals('testScheduledApexFromTestMethodUpdated', [SELECT Id, Name FROM Account WHERE Id = :a.Id].Name);
    }
}