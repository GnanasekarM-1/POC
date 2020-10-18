@isTest(SeeAllData = true)
private class SLA_Clock_WO_Controller_UT 
{
    static testMethod void SLAT_SLAClockOnWOUnitTest()
    {
        SVMXC.SLA_Clock_WO_Controller obj;
        String CommitmentRtypeId;
        String ServiceRtypeId;
        List<SVMXC__Service_Level__c> SLATerms = new list<SVMXC__Service_Level__c>();
        List<SVMXC__SLA_Detail__c> SLADetail = new List<SVMXC__SLA_Detail__c>();
        List<RecordType> RecordTypes = new List<RecordType>();
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__SLA_Detail__c\'');
        System.assertEquals(true, RecordTypes != null);
        for(RecordType r : RecordTypes)
        {
            if(r.Name == 'Commitment')
            {
                CommitmentRtypeId = r.id;
            }
            if(r.Name == 'Services')
            {
                ServiceRtypeId = r.id;
            }
        }
        
        BusinessHours bh = [Select id from BusinessHours where IsDefault = true];
        
        /*SVMXC__Service_Level__c slaone=new SVMXC__Service_Level__c(
                    Name='Test one',
                    SVMXC__Description__c='Test one Description',
                    SVMXC__Active__c =true,
                    SVMXC__Initial_Response_Tracked_On__c = 'Case'  , 
                    SVMXC__Select__c=true);
        SLATerms.add(slaone);*/
        SVMXC__Service_Level__c slatwo=new SVMXC__Service_Level__c(
                    Name='Test two',
                    SVMXC__Description__c='Test two Description',
                    SVMXC__Active__c =true,
                    SVMXC__Initial_Response_Tracked_On__c = 'WorkOrder',
                    SVMXC__Onsite_Response_Tracked_On__c = 'WorkOrder',
                    SVMXC__Resolution_Tracked_On__c = 'WorkOrder',
                    SVMXC__Restoration_Tracked_On__c = 'WorkOrder');
        SLATerms.add(slatwo);
        insert SLATerms;
        System.assertEquals(true, SLATerms != null);
        
        SVMXC__SLA_Detail__c InitialResponse1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'All',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__Business_Hours__c = bh.Id,
            SVMXC__SLA_Terms__c = SLATerms[0].id
            
        );
        SLADetail.add(InitialResponse1);
        
        SVMXC__SLA_Detail__c InitialResponse = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__Business_Hours__c = bh.Id,
            SVMXC__SLA_Terms__c = SLATerms[0].id
            
        );
        SLADetail.add(InitialResponse);
        
        SVMXC__SLA_Detail__c OnsiteResponse = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__Business_Hours__c = bh.Id,
            SVMXC__SLA_Terms__c = SLATerms[0].id
            
        );
        SLADetail.add(OnsiteResponse);
        SVMXC__SLA_Detail__c Restoration = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__Business_Hours__c = bh.Id,
            SVMXC__SLA_Terms__c = SLATerms[0].id
            
        );
        SLADetail.add(Restoration);
        
        SVMXC__SLA_Detail__c Resolution = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__Business_Hours__c = bh.Id,
            SVMXC__SLA_Terms__c = SLATerms[0].id
            
        );
        SLADetail.add(Resolution);
        insert SLADetail;
        
        Account account = new Account();
        account.Name = 'Tesla';
        insert account;
        
        SVMXC__Service_Order__c WOrder = new SVMXC__Service_Order__c();
        WOrder.SVMXC__Initial_Response_Internal_By__c = system.now() + 12;
        WOrder.SVMXC__Onsite_Response_Internal_By__c = system.now() + 12;
        WOrder.SVMXC__Restoration_Internal_By__c = system.now() + 12;
        WOrder.SVMXC__Resolution_Internal_By__c = system.now() + 12;
        WOrder.SVMXC__Initial_Response_Customer_By__c = system.now() + 12;
        WOrder.SVMXC__Onsite_Response_Customer_By__c = system.now() + 12;
        WOrder.SVMXC__Restoration_Customer_By__c = system.now() + 12;
        WOrder.SVMXC__Resolution_Customer_By__c = system.now() + 12;
        WOrder.SVMXC__SLA_Clock_Paused__c = true;
        WOrder.SVMXC__SLA_Clock_Pause_Time__c = System.now();
        WOrder.SVMXC__SLA_Clock_Extension_Minutes__c = 12;
        WOrder.SVMXC__SLA_Terms__c = SLATerms[0].id;
        WOrder.SVMXC__Order_Type__c = 'Electronic';
        WOrder.SVMXC__Priority__c = 'Medium';
        WOrder.SVMXC__Company__c = account.id;
        insert WOrder;
        System.assertEquals(true, SLATerms != null);
        
        test.startTest();
        SLA_Clock_WO_Controller.getSLADetails(WOrder.Id);
        
        WOrder.SVMXC__SLA_Clock_Paused__c = False;
        update WOrder;
        
        System.assertEquals(False, WOrder.SVMXC__SLA_Clock_Paused__c);
        SLA_Clock_WO_Controller.getSLADetails(WOrder.Id);
        SLA_Clock_WO_Controller.getWorkOrderData('b',WOrder);
        WOrder.SVMXC__SLA_Clock_Pause_Reason__c = 'Customer Not Available';
        WOrder.SVMXC__SLA_Clock_Pause_Minutes__c = 10;
        update WOrder;
        SLA_Clock_WO_Controller.SVMX_PauseNow(WOrder,'b');  
        
        SLA_Clock_WO_Controller.getElapsedMinutes(WOrder);
        
        SLA_Clock_WO_Controller.SVMX_Yes(WOrder,SLADetail,new map<String,String>(),2);
        
        
        WOrder.SVMXC__Actual_Initial_Response__c = system.now() + 1;
        WOrder.SVMXC__Actual_Onsite_Response__c = system.now() + 1;
        WOrder.SVMXC__Actual_Resolution__c = system.now() + 1;
        WOrder.SVMXC__Actual_Restoration__c = system.now() + 1;
        update WOrder;
        
        System.assertEquals(False, WOrder.SVMXC__SLA_Clock_Paused__c);
        SLA_Clock_WO_Controller.getSLADetails(WOrder.Id);
        
        
        WOrder.SVMXC__SLA_Clock_Pause_Reason__c = 'Customer Not Available';
        WOrder.SVMXC__SLA_Clock_Pause_Minutes__c = 10;
        update WOrder;
        SLA_Clock_WO_Controller.SVMX_PauseNow(WOrder,'b');  
        
        SLA_Clock_WO_Controller.getElapsedMinutes(WOrder);
        
        SLA_Clock_WO_Controller.SVMX_Yes(WOrder,SLADetail,new map<String,String>(),2);
        
        SLA_Clock_WO_Controller.getTAG002();
        SLA_Clock_WO_Controller.getTAG007();
        SLA_Clock_WO_Controller.getTAG009();
        SLA_Clock_WO_Controller.getTAG010();
        SLA_Clock_WO_Controller.getTAG011();
        SLA_Clock_WO_Controller.getTAG012();
        SLA_Clock_WO_Controller.getTAG013();
        SLA_Clock_WO_Controller.getTAG014();
        SLA_Clock_WO_Controller.getTAG015();
        SLA_Clock_WO_Controller.getTAG016();
        SLA_Clock_WO_Controller.getTAG018(); 
        SLA_Clock_WO_Controller.getTAG019();
        SLA_Clock_WO_Controller.getTAG020();
        SLA_Clock_WO_Controller.getTAG021();
        SLA_Clock_WO_Controller.getTAG027();
        SLA_Clock_WO_Controller.getTAG028();
        SLA_Clock_WO_Controller.getTAG029();
        Test.stopTest();
    }
}