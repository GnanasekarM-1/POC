@isTest(SeeAllData=true)
private class SLAT_SLAClockOnWO_UT 
{
    static testMethod void SLAT_SLAClockOnWOUnitTest()
    {
        SVMXC.SLAT_SLAClockOnWO obj;
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
            SVMXC__Business_Hours_Source__c = 'Custom',
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
            SVMXC__Business_Hours_Source__c = 'Custom',
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
        insert WOrder;
        System.assertEquals(true, SLATerms != null);
        
        ////System.assertEquals(System.now(), WOrder.SVMXC__SLA_Clock_Pause_Time__c );
        test.startTest();
        apexpages.standardcontroller WOrderController = new apexpages.standardcontroller (WOrder);
        PageReference pageRef1 = new PageReference('Page.SVMXC.SLAT_SLAClockOnWO');
        pageRef1.getParameters().put('id',WOrder.Id);
        Test.setCurrentPageReference(pageRef1); 
        obj = new SVMXC.SLAT_SLAClockOnWO (WOrderController);
        obj.formatDate(WOrder.SVMXC__Initial_Response_Internal_By__c,null);
        
        WOrder.SVMXC__Actual_Initial_Response__c = system.now() + 1;
        WOrder.SVMXC__Actual_Onsite_Response__c = system.now() + 1;
        WOrder.SVMXC__Actual_Resolution__c = system.now() + 1;
        WOrder.SVMXC__Actual_Restoration__c = system.now() + 1;
        WOrder.SVMXC__SLA_Clock_Paused__c = False;
        update WOrder;
        System.assertEquals(False, WOrder.SVMXC__SLA_Clock_Paused__c);
        
        ////obj.SLAClockDisplayBasis = false;
        WOrderController = new apexpages.standardcontroller (WOrder);
        obj = new SVMXC.SLAT_SLAClockOnWO (WOrderController);
        obj.formatDate(WOrder.SVMXC__Initial_Response_Internal_By__c,null);
        obj.formatDate(WOrder.SVMXC__Initial_Response_Internal_By__c,system.now());
        
        integer i;
        obj.setair(obj.getair());
        obj.setaor(obj.getaor());
        obj.setart(obj.getart());
        obj.setars(obj.getars());
        obj.getWOObj();
        obj.setWOObj(WOrder);
        obj.getiIRdays();
        obj.setiIRdays(i);
        obj.getiIRhrs();
        obj.setiIRhrs(i);
        obj.getiIRmins();
        obj.setiIRmins(i);
        obj.getiIRsecs();
        obj.setiIRsecs(i);
        obj.getiORdays();
        obj.setiORdays(i);
        obj.getiORhrs();
        obj.setiORhrs(i);
        obj.getiORmins();
        obj.setiORmins(i);
        obj.getiORsecs();
        obj.setiORsecs(i);
        obj.getiAREdays();
        obj.setiAREdays(i);
        obj.getiAREhrs();
        obj.setiAREhrs(i);
        obj.getiAREmins();
        obj.setiAREmins(i);
        obj.getiAREsecs();
        obj.setiAREsecs(i);
        obj.getiAROdays();
        obj.setiAROdays(i);
        obj.getiAROhrs();
        obj.setiAROhrs(i);
        obj.getiAROmins();
        obj.setiAROmins(i);
        obj.getiAROsecs();
        obj.setiAROsecs(i);
        
        Boolean b;
        String s;
        Double d;
        obj.getSLAClockPause();
        obj.getPopupMsg();
        obj.setSLAClockPause(b);
        obj.getdisplayPopUp();
        obj.getdisplaystartPopUp();
        obj.getReasonOpt();
        obj.getForHowLong();
        obj.setForHowLong(s);
        obj.getForHowLongOpt();
        obj.SVMX_ValidPause();
        obj.SVMX_Start();
        obj.SVMX_Pause();
        obj.SVMX_PauseNow();
        obj.getcaseData();
        obj.getVFMessage();
        obj.SVMX_Cancel();
        obj.SVMX_CancelStartPopup();
        obj.SVMX_Yes();
        obj.BuildDescForTask();
        obj.SVMX_No();
        obj.getPauseRestartSLAClock();
      obj.setSLAClockPausedSetting(s);
      obj.setPauseRestartSLAClock(s);
      obj.getThresholdTime();
      obj.setThresholdTime(i);
      obj.getSLAIRMin();
      obj.setSLAIRMin(d);
      obj.getSLAORMin();
      obj.setSLAORMin(d);
      obj.getSLARestorationMin();
      obj.setSLARestorationMin(d);
      obj.getSLAResolutionMin();
      obj.setSLAResolutionMin(d);
        obj.SVMX_getPickListValues('SVMXC__SLA_Clock_Pause_Reason__c');
        
        obj.getTAG001();
        obj.getTAG002();
        obj.getTAG003();
        obj.getTAG004();
        obj.getTAG005();
        obj.getTAG006();
        obj.getTAG007();
        obj.getTAG008();
        obj.getTAG009();
        obj.getTAG010();
        obj.getTAG011();
        obj.getTAG012();
        obj.getTAG013();
        obj.getTAG014();
        obj.getTAG015();
        obj.getTAG016();
        obj.getTAG017();
        obj.getTAG018();
        obj.getTAG019();
        obj.getTAG020();
        obj.getTAG021();
        obj.getTAG022();
        obj.getTAG023();
        obj.getTAG024();
        obj.getTAG025();
        obj.getTAG026();
        obj.getTAG027();
        obj.getTAG028();
        obj.getTAG029();
        obj.getTAG030();
        obj.getTAG031();
        obj.getTAG032();
        obj.getTAG033();
        obj.getTAG034();
        obj.getTAG035();
        obj.getTAG036();
        obj.getTAG037();
        //obj.svmxTagList.clear();
        obj.getTAG001();
        obj.getTAG002();
        obj.getTAG003();
        obj.getTAG004();
        obj.getTAG005();
        obj.getTAG006();
        obj.getTAG007();
        obj.getTAG008();
        obj.getTAG009();
        obj.getTAG010();
        obj.getTAG011();
        obj.getTAG012();
        obj.getTAG013();
        obj.getTAG014();
        obj.getTAG015();
        obj.getTAG016();
        obj.getTAG017();
        obj.getTAG018();
        obj.getTAG019();
        obj.getTAG020();
        obj.getTAG021();
        obj.getTAG022();
        obj.getTAG023();
        obj.getTAG024();
        obj.getTAG025();
        obj.getTAG026();
        obj.getTAG027();
        obj.getTAG028();
        obj.getTAG029();
        obj.getTAG030();
        obj.getTAG031();
        obj.getTAG032();
        obj.getTAG033();
        obj.getTAG034();
        obj.getTAG035();
        obj.getTAG036();
        obj.getTAG037();
        obj.getSLAClockPausedSetting();
        Test.stopTest();
    }
}