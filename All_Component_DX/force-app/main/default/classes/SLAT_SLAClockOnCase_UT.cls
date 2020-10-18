@isTest(SeeAllData=true)
private class SLAT_SLAClockOnCase_UT 
{
    static testMethod void SLAT_SLAClockOnCaseUnitTest()
    {
        SVMXC.SLAT_SLAClockOnCase obj;
        String CommitmentRtypeId;
        String ServiceRtypeId;
        List<SVMXC__Service_Level__c> SLATerms = new list<SVMXC__Service_Level__c>();
        List<SVMXC__SLA_Detail__c> SLADetail = new List<SVMXC__SLA_Detail__c>();
        List<RecordType> RecordTypes = new List<RecordType>();
        RecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__SLA_Detail__c\'');
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
        
        Account acc = new Account();
        acc.Name = 'ABC';
        insert acc;
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        insert IB;
        
        BusinessHours bh = [Select id from BusinessHours where IsDefault = true];
        
        SVMXC__Service_Level__c slaone=new SVMXC__Service_Level__c(
                    Name='Test one',
                    SVMXC__Description__c='Test one Description',
                    SVMXC__Active__c =true,
                    SVMXC__Initial_Response_Tracked_On__c = 'Case',
                    SVMXC__Onsite_Response_Tracked_On__c = 'Case',
                    SVMXC__Resolution_Tracked_On__c = 'Case',
                    SVMXC__Restoration_Tracked_On__c = 'Case',
                    SVMXC__Select__c=true);
        SLATerms.add(slaone);
        
        /*SVMXC__Service_Level__c slatwo=new SVMXC__Service_Level__c(
                    Name='Test two',
                    SVMXC__Description__c='Test two Description',
                    SVMXC__Active__c =true,
                    SVMXC__Initial_Response_Tracked_On__c = 'WorkOrder',
                    SVMXC__Onsite_Response_Tracked_On__c = 'WorkOrder',
                    SVMXC__Resolution_Tracked_On__c = 'WorkOrder',
                    SVMXC__Restoration_Tracked_On__c = 'WorkOrder'
                    );
        SLATerms.add(slatwo);*/
        
        insert SLATerms;
        
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
        Case Caseobj = new Case();
        Caseobj.SVMXC__Initial_Response_Internal_By__c = system.now() + 12;
        Caseobj.SVMXC__Onsite_Response_Internal_By__c = system.now() + 12;
        Caseobj.SVMXC__Restoration_Internal_By__c = system.now() + 12;
        Caseobj.SVMXC__Resolution_Internal_By__c = system.now() + 12;
        Caseobj.SVMXC__Initial_Response_Customer_By__c = system.now() + 12;
        Caseobj.SVMXC__Onsite_Response_Customer_By__c = system.now() + 12;
        Caseobj.SVMXC__Restoration_Customer_By__c = system.now() + 12;
        Caseobj.SVMXC__Resolution_Customer_By__c = system.now() + 12;
        Caseobj.SVMXC__SLA_Clock_Paused__c = true;
        Caseobj.SVMXC__SLA_Clock_Pause_Time__c = System.now();
        Caseobj.SVMXC__SLA_Clock_Extension_Minutes__c = 12;
        Caseobj.SVMXC__SLA_Terms__c = SLATerms[0].id;
        Caseobj.Type = 'Electronic';
        Caseobj.Priority = 'Medium';
        Caseobj.AccountId = acc.Id;
        Caseobj.SVMXC__Component__c = IB.Id;
        insert Caseobj;
        
        test.startTest();
        apexpages.standardcontroller CaseobjController = new apexpages.standardcontroller (Caseobj);
        PageReference pageRef1 = new PageReference('Page.SVMXC.SLAT_SLAClockOnWO');
        pageRef1.getParameters().put('id',Caseobj.Id);
        Test.setCurrentPageReference(pageRef1); 
        obj = new SVMXC.SLAT_SLAClockOnCase (CaseobjController);
        obj.formatDate(Caseobj.SVMXC__Initial_Response_Internal_By__c,null);
        
        Caseobj.SVMXC__Actual_Initial_Response__c = system.now() + 1;
        Caseobj.SVMXC__Actual_Onsite_Response__c = system.now() + 1;
        Caseobj.SVMXC__Actual_Resolution__c = system.now() + 1;
        Caseobj.SVMXC__Actual_Restoration__c = system.now() + 1;
        Caseobj.SVMXC__SLA_Clock_Paused__c = False;
        update Caseobj;
        system.assertEquals(False, Caseobj.SVMXC__SLA_Clock_Paused__c);
        
        ////obj.SLAClockDisplayBasis = false;
        CaseobjController = new apexpages.standardcontroller (Caseobj);
        obj = new SVMXC.SLAT_SLAClockOnCase (CaseobjController);
        obj.formatDate(Caseobj.SVMXC__Initial_Response_Internal_By__c,null);
        obj.formatDate(Caseobj.SVMXC__Initial_Response_Internal_By__c,system.now());
        
        integer i;
        obj.setair(obj.getair());
        obj.setaor(obj.getaor());
        obj.setart(obj.getart());
        obj.setars(obj.getars());
        obj.getcaseobj();
        obj.setcaseobj(Caseobj);
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
        double d;
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
        system.assert(obj.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(obj.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(obj.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(obj.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(obj.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(obj.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(obj.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(obj.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(obj.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(obj.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(obj.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(obj.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(obj.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(obj.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(obj.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(obj.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(obj.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(obj.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(obj.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(obj.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(obj.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(obj.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(obj.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(obj.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(obj.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(obj.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(obj.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(obj.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(obj.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(obj.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(obj.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(obj.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(obj.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(obj.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(obj.getTAG035()!=null,'TAG035 assertion failed');
        system.assert(obj.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(obj.getTAG037()!=null,'TAG037 assertion failed');
        system.assert(obj.getTAG038()!=null,'TAG037 assertion failed');
        //obj.svmxTagList.clear();
        system.assert(obj.getTAG001()!=null,'TAG001 assertion failed');
        system.assert(obj.getTAG002()!=null,'TAG002 assertion failed');
        system.assert(obj.getTAG003()!=null,'TAG003 assertion failed');
        system.assert(obj.getTAG004()!=null,'TAG004 assertion failed');
        system.assert(obj.getTAG005()!=null,'TAG005 assertion failed');
        system.assert(obj.getTAG006()!=null,'TAG006 assertion failed');
        system.assert(obj.getTAG007()!=null,'TAG007 assertion failed');
        system.assert(obj.getTAG008()!=null,'TAG008 assertion failed');
        system.assert(obj.getTAG009()!=null,'TAG009 assertion failed');
        system.assert(obj.getTAG010()!=null,'TAG010 assertion failed');
        system.assert(obj.getTAG011()!=null,'TAG011 assertion failed');
        system.assert(obj.getTAG012()!=null,'TAG012 assertion failed');
        system.assert(obj.getTAG013()!=null,'TAG013 assertion failed');
        system.assert(obj.getTAG014()!=null,'TAG014 assertion failed');
        system.assert(obj.getTAG015()!=null,'TAG015 assertion failed');
        system.assert(obj.getTAG016()!=null,'TAG016 assertion failed');
        system.assert(obj.getTAG017()!=null,'TAG017 assertion failed');
        system.assert(obj.getTAG018()!=null,'TAG018 assertion failed');
        system.assert(obj.getTAG019()!=null,'TAG019 assertion failed');
        system.assert(obj.getTAG020()!=null,'TAG020 assertion failed');
        system.assert(obj.getTAG021()!=null,'TAG021 assertion failed');
        system.assert(obj.getTAG022()!=null,'TAG022 assertion failed');
        system.assert(obj.getTAG023()!=null,'TAG023 assertion failed');
        system.assert(obj.getTAG024()!=null,'TAG024 assertion failed');
        system.assert(obj.getTAG025()!=null,'TAG025 assertion failed');
        system.assert(obj.getTAG026()!=null,'TAG026 assertion failed');
        system.assert(obj.getTAG027()!=null,'TAG027 assertion failed');
        system.assert(obj.getTAG028()!=null,'TAG028 assertion failed');
        system.assert(obj.getTAG029()!=null,'TAG029 assertion failed');
        system.assert(obj.getTAG030()!=null,'TAG030 assertion failed');
        system.assert(obj.getTAG031()!=null,'TAG031 assertion failed');
        system.assert(obj.getTAG032()!=null,'TAG032 assertion failed');
        system.assert(obj.getTAG033()!=null,'TAG033 assertion failed');
        system.assert(obj.getTAG034()!=null,'TAG034 assertion failed');
        system.assert(obj.getTAG035()!=null,'TAG035 assertion failed');
        system.assert(obj.getTAG036()!=null,'TAG036 assertion failed');
        system.assert(obj.getTAG037()!=null,'TAG037 assertion failed');
        system.assert(obj.getTAG038()!=null,'TAG037 assertion failed');
        
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        Map<String, String> svmxSettingList = commSettings.SVMX_getSettingList('SLAT002');
        svmxSettingList.remove('SET001');
        svmxSettingList.put('SET001','INTERNAL COMMITMENT');
        apexpages.standardcontroller CaseobjController1 = new apexpages.standardcontroller (Caseobj);
        PageReference pageRef2 = new PageReference('Page.SVMXC.SLAT_SLAClockOnWO');
        pageRef2.getParameters().put('id',Caseobj.Id);
        Test.setCurrentPageReference(pageRef2); 
        obj.getSLAClockPausedSetting();
        obj = new SVMXC.SLAT_SLAClockOnCase (CaseobjController1);
        test.stopTest();
    }
}