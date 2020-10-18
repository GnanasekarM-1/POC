@isTest(SeeAllData=true)
private with sharing class SLAT_ManageSLATerms_UT {
    
    static testMethod void SLAT_ManageSLATerms_UT_Test()
    {
        List<SVMXC__Service_Level__c> SLATerms = new list<SVMXC__Service_Level__c>();
        List<RecordType> RecordTypes = new List<RecordType>();
        List<SVMXC__SLA_Detail__c> SLADetail = new List<SVMXC__SLA_Detail__c>();
        String CommitmentRtypeId,ServiceRtypeId;
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
        // creating objects
        
        BusinessHours bhour=[select id,name from BusinessHours limit 1];
        Time cutOffTime = time.newInstance(11, 0, 0, 0);      
        SVMXC__Service_Level__c slaone=new SVMXC__Service_Level__c(
                    Name='Test one',
                    SVMXC__Description__c='Test one Description',
                    SVMXC__Active__c =true,
                    SVMXC__Business_Hours__c = bhour.id , 
                    SVMXC__Initial_Response_Tracked_On__c = 'Case'  , 
                    SVMXC__Resolution_Tracked_On__c = 'Case',
                    SVMXC__Restoration_Tracked_On__c = 'Case',
                    SVMXC__Onsite_Response_Tracked_On__c = 'Case',
                    SVMXC__Select__c=true ,
                    SVMXC__SM_Initial_Unit_of_Measure__c='Minute',
                    SVMXC__SM_Onsite_Unit_of_Measure__c='Minute',
                    SVMXC__SM_Resolution_Unit_of_Measure__c='Minute',
                    SVMXC__SM_Restoration_Unit_of_Measure__c='Minute',
                    SVMXC__SM_Initial_SLA_Cutoff_Time__c=cutOffTime,
                    SVMXC__SM_Onsite_SLA_Cutoff_Time__c=cutOffTime,
                    SVMXC__SM_Resolution_SLA_Cutoff_Time__c=cutOffTime,
                    SVMXC__SM_Restoration_SLA_Cutoff_Time__c=cutOffTime);
                        
        SLATerms.add(slaone);
        
        SVMXC__Service_Level__c slatwo=new SVMXC__Service_Level__c(
                    Name='Test two',
                    SVMXC__Description__c='Test two Description',
                    SVMXC__Active__c =true,
                    SVMXC__Business_Hours__c = bhour.id,
                    SVMXC__Initial_Response_Tracked_On__c = 'WorkOrder'                         
                        );
        SLATerms.add(slatwo);
        insert SLATerms;
        
        SVMXC__SLA_Detail__c InitialResponse = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Initial Response',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'FromAccount',
            SVMXC__Business_Hours__c = bhour.id,
            SVMXC__SLA_Terms__c = SLATerms[0].id
            
        );
        SLADetail.add(InitialResponse);
        
        SVMXC__SLA_Detail__c OnsiteResponse = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Onsite Response',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'FromAccount',
            SVMXC__Business_Hours__c = bhour.id,
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
            SVMXC__Business_Hours_Source__c = 'FromAccount',
            SVMXC__Business_Hours__c = bhour.id,
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
            SVMXC__Business_Hours_Source__c = 'FromAccount',
            SVMXC__Business_Hours__c = bhour.id,
            SVMXC__SLA_Terms__c = SLATerms[0].id
            
        );
        SLADetail.add(Resolution);
        SVMXC__SLA_Detail__c sladetailsix = new SVMXC__SLA_Detail__c(
            
            RecordTypeId = ServiceRtypeId
            
            
        );
        List<SVMXC__Service__c> serviceList=new List<SVMXC__Service__c>();
        SVMXC__Service__c serviceone=new  SVMXC__Service__c(SVMXC__Data_Type__c ='Text',Name='dummuone'); 
        SVMXC__Service__c servicetwo=new  SVMXC__Service__c(SVMXC__Data_Type__c ='Number',Name='dummutwo'); 
        SVMXC__Service__c servicethree=new  SVMXC__Service__c(SVMXC__Data_Type__c ='Frequency',Name='dummuthree'); 
        SVMXC__Service__c servicefour=new  SVMXC__Service__c(SVMXC__Data_Type__c ='Boolean',Name='dummufour'); 
        serviceList.add(serviceone);
        serviceList.add(servicetwo);
        serviceList.add(servicethree);
        serviceList.add(servicefour);
        insert serviceList;
        SLADetail.add(sladetailsix);
        insert SLADetail;
        Test.startTest();
        PageReference pageRef = Page.SLAT_ManageSLATerms;
        Test.setCurrentPage(pageRef);
        SVMXC.SLAT_ManageSLATerms mslaterms = new SVMXC.SLAT_ManageSLATerms();
        mslaterms.SVMX_ValidEditSALTerm();
        mslaterms.SVMX_EditSLATerm();
        cutOffTime = time.newInstance(14, 0, 0, 0);
        for(integer i = 0; i < SLATerms.size(); i++)
        {
            SLATerms[i].SVMXC__Select__c = true;
            SLATerms[i].SVMXC__Initial_Response_Tracked_On__c = 'WorkOrder'; 
            SLATerms[i].SVMXC__Resolution_Tracked_On__c = 'WorkOrder';
            SLATerms[i].SVMXC__Restoration_Tracked_On__c = 'WorkOrder';
            SLATerms[i].SVMXC__Onsite_Response_Tracked_On__c = 'WorkOrder';
        }
        
        update SLATerms;
        mslaterms.SVMX_ValidEditSALTerm();
        mslaterms.getApplicableService();
        mslaterms.getCheckAllLines();
        mslaterms.getDetailSection();
        mslaterms.getDisbaleChkBox();
        mslaterms.getDisbleCancleBttn();
        mslaterms.getDisbleDeleteBttn();
        mslaterms.getDisbleEditBttn();
        mslaterms.getDisbleNewBttn();
        mslaterms.getdisplayPopUp();
        mslaterms.getHdrMsg();
        mslaterms.getHLPURL();
        mslaterms.getInitialResponse();
        mslaterms.getIrClock();
        mslaterms.getIrPriority();
        mslaterms.getIrType();
        ////mslaterms.getIsWarn();
        ////mslaterms.getMSG();
        mslaterms.getOnsiteResponse();
        mslaterms.getOptions();
        mslaterms.getOrClock();
        mslaterms.getOrPriority();
        mslaterms.getOrType();
        mslaterms.getpanelMsg();
        mslaterms.getParameterID();
        mslaterms.getpopupdetail();
        mslaterms.getPopupMsg();
        mslaterms.getpopupservice();
        mslaterms.getResolution();
        mslaterms.getResolutionPriority();
        mslaterms.getResolutionType();
        mslaterms.getRestoration();
        mslaterms.getRestorationClock();
        mslaterms.getSearchKeyword();
        mslaterms.getselectedTab();
        mslaterms.getServiceWrapper();
        mslaterms.getSLA();
        mslaterms.getSLATerms();
        System.assert(mslaterms.getTab1Msg()!=null,true);
        System.assert(mslaterms.getTab2Msg()!=null,true);
        System.assert(mslaterms.getTab3Msg()!=null,true);
        System.assert(mslaterms.getTab4Msg()!=null,true);
        System.assert(mslaterms.getTab5Msg()!=null,true);
        System.assert(mslaterms.getTAG001()!=null,'TAG001 assertion failed');
        System.assert(mslaterms.getTAG002()!=null,'TAG002 assertion failed');
        System.assert(mslaterms.getTAG003()!=null,'TAG003 assertion failed');
        System.assert(mslaterms.getTAG004()!=null,'TAG004 assertion failed');
        System.assert(mslaterms.getTAG005()!=null,'TAG005 assertion failed');
        System.assert(mslaterms.getTAG006()!=null,'TAG006 assertion failed');
        System.assert(mslaterms.getTAG007()!=null,'TAG007 assertion failed');
        System.assert(mslaterms.getTAG008()!=null,'TAG008 assertion failed');
        System.assert(mslaterms.getTAG009()!=null,'TAG009 assertion failed');
        System.assert(mslaterms.getTAG010()!=null,'TAG010 assertion failed');
        System.assert(mslaterms.getTAG011()!=null,'TAG011 assertion failed');
        System.assert(mslaterms.getTAG012()!=null,'TAG012 assertion failed');
        System.assert(mslaterms.getTAG013()!=null,'TAG013 assertion failed');
        System.assert(mslaterms.getTAG014()!=null,'TAG014 assertion failed');
        System.assert(mslaterms.getTAG015()!=null,'TAG015 assertion failed');
        System.assert(mslaterms.getTAG016()!=null,'TAG016 assertion failed');
        System.assert(mslaterms.getTAG017()!=null,'TAG017 assertion failed');
        System.assert(mslaterms.getTAG018()!=null,'TAG018 assertion failed');
        System.assert(mslaterms.getTAG019()!=null,'TAG019 assertion failed');
        System.assert(mslaterms.getTAG020()!=null,'TAG020 assertion failed');
        System.assert(mslaterms.getTAG021()!=null,'TAG021 assertion failed');
        System.assert(mslaterms.getTAG022()!=null,'TAG022 assertion failed');
        System.assert(mslaterms.getTAG023()!=null,'TAG023 assertion failed');
        System.assert(mslaterms.getTAG024()!=null,'TAG024 assertion failed');
        System.assert(mslaterms.getTAG025()!=null,'TAG025 assertion failed');
        System.assert(mslaterms.getTAG026()!=null,'TAG026 assertion failed');
        System.assert(mslaterms.getTAG027()!=null,'TAG027 assertion failed');
        System.assert(mslaterms.getTAG028()!=null,'TAG028 assertion failed');
        System.assert(mslaterms.getTAG029()!=null,'TAG029 assertion failed');
        System.assert(mslaterms.getTAG030()!=null,'TAG030 assertion failed');
        System.assert(mslaterms.getTAG031()!=null,'TAG031 assertion failed');
        System.assert(mslaterms.getTAG032()!=null,'TAG032 assertion failed');
        System.assert(mslaterms.getTAG033()!=null,'TAG033 assertion failed');
        System.assert(mslaterms.getTAG034()!=null,'TAG034 assertion failed');
        System.assert(mslaterms.getTAG035()!=null,'TAG035 assertion failed');
        System.assert(mslaterms.getTAG036()!=null,'TAG036 assertion failed');
        System.assert(mslaterms.getTAG037()!=null,'TAG037 assertion failed');
        System.assert(mslaterms.getTAG038()!=null,'TAG038 assertion failed');
        System.assert(mslaterms.getTAG039()!=null,'TAG039 assertion failed');
        System.assert(mslaterms.getTAG040()!=null,'TAG040 assertion failed');
        System.assert(mslaterms.getTAG041()!=null,'TAG041 assertion failed');
        System.assert(mslaterms.getTAG042()!=null,'TAG042 assertion failed');
        System.assert(mslaterms.getTAG043()!=null,'TAG043 assertion failed');
        System.assert(mslaterms.getTAG044()!=null,'TAG044 assertion failed');
        System.assert(mslaterms.getTAG045()!=null,'TAG045 assertion failed');
        System.assert(mslaterms.getTAG046()!=null,'TAG046 assertion failed');
        System.assert(mslaterms.getTAG047()!=null,'TAG047 assertion failed');
        System.assert(mslaterms.getTAG048()!=null,'TAG048 assertion failed');
        System.assert(mslaterms.getTAG049()!=null,'TAG049 assertion failed');
        System.assert(mslaterms.getTAG050()!=null,'TAG050 assertion failed');
        System.assert(mslaterms.getTAG051()!=null,'TAG051 assertion failed');
        System.assert(mslaterms.getTAG052()!=null,'TAG052 assertion failed');
        System.assert(mslaterms.getTAG053()!=null,'TAG053 assertion failed');
        System.assert(mslaterms.getTAG054()!=null,'TAG053 assertion failed');
        System.assert(mslaterms.getTAG055()!=null,'TAG055 assertion failed');
        System.assert(mslaterms.getTAG056()!=null,'TAG056 assertion failed');
        System.assert(mslaterms.getTAG057()!=null,'TAG057 assertion failed');
        System.assert(mslaterms.getTAG058()!=null,'TAG058 assertion failed');
        System.assert(mslaterms.getTAG059()!=null,'TAG059 assertion failed');
        System.assert(mslaterms.getTAG060()!=null,'TAG060 assertion failed');
        System.assert(mslaterms.getTAG061()!=null,'TAG061 assertion failed');
        System.assert(mslaterms.getTAG062()!=null,'TAG062 assertion failed');
        System.assert(mslaterms.getTAG063()!=null,'TAG063 assertion failed');
        System.assert(mslaterms.getTAG064()!=null,'TAG064 assertion failed');
        System.assert(mslaterms.getTAG065()!=null,'TAG065 assertion failed');
        System.assert(mslaterms.getTAG066()!=null,'TAG066 assertion failed');
        System.assert(mslaterms.getTAG067()!=null,'TAG067 assertion failed');
        System.assert(mslaterms.getTAG068()!=null,'TAG068 assertion failed');
        System.assert(mslaterms.getTAG069()!=null,'TAG069 assertion failed');
        System.assert(mslaterms.getTAG070()!=null,'TAG070 assertion failed');
        System.assert(mslaterms.getTAG071()!=null,'TAG071 assertion failed');
        System.assert(mslaterms.getTAG072()!=null,'TAG072 assertion failed');
        System.assert(mslaterms.getTAG073()!=null,'TAG073 assertion failed');
        System.assert(mslaterms.getTAG074()!=null,'TAG074 assertion failed');
        System.assert(mslaterms.getTAG075()!=null,'TAG075 assertion failed');
        System.assert(mslaterms.getTAG076()!=null,'TAG076 assertion failed');
        System.assert(mslaterms.getTAG077()!=null,'TAG077 assertion failed');
        System.assert(mslaterms.getTAG078()!=null,'TAG078 assertion failed');
        mslaterms.SVMX_NewSLATerm();
        mslaterms.getSLATerms();
        SVMXC__Service_Level__c slaobj=new SVMXC__Service_Level__c(Name ='Test one',SVMXC__Select__c=true,SVMXC__Description__c='test description');
        mslaterms.newSLA=slaobj;
        //SVMXC__Service_Level__c slnew=mslaterms.newSLA;
        //slnew.Name ='Test one';
        //slnew.SVMXC__Select__c=true;
        //slnew.SVMXC__Description__c='test description';
        mslaterms.setInitialResponse(SLADetail);
        mslaterms.setOnsiteResponse(SLADetail);
        mslaterms.setRestoration(SLADetail);
        mslaterms.setResolution(SLADetail);
        SLATerms.add(slaobj);
        mslaterms.SVMX_ValidSaveSLA();
        mslaterms.SVMX_SaveSLA();
        mslaterms.SVMX_Cancel();
        mslaterms.SVMX_BackToSetupHome();
        mslaterms.SVMX_IR_ChangeCaseWo();
        mslaterms.SVMX_OR_ChangeCaseWo();
        mslaterms.SVMX_OR_CustomBH();
        mslaterms.SVMX_OR_AddRecord();
        mslaterms.SVMX_OR_Delete();
        mslaterms.getRestorationType();
        mslaterms.getRestorationPriority();
        mslaterms.SVMX_Restoration_ChangeCaseWo();
        mslaterms.SVMX_Restoration_CustomBH();
        mslaterms.SVMX_Restoration_AddRecord();
        mslaterms.SVMX_Restoration_Delete();
        //mslaterms.SVMX_ValidEditSALTerm();
        mslaterms.SVMX_ValidEditSALTerm = false;
       // mslaterms.SVMX_EditSLATerm();
        //mslaterms.setpopupdetail(SLADetail[0]);
        mslaterms.SVMX_IsValidPopup();
        mslaterms.SVMX_Submit();
        mslaterms.SVMX_CancelPopup();
        mslaterms.SVMX_IR_CustomBH();
        mslaterms.SVMX_IR_AddRecord();
        mslaterms.SVMX_IR_Delete();
        mslaterms.SVMX_IR_Delete();
        mslaterms.SVMX_Resolution_ChangeCaseWo();
        mslaterms.SVMX_Resolution_CustomBH();
        mslaterms.SVMX_Resolution_AddRecord();
        mslaterms.SVMX_Resolution_Delete();
        mslaterms.SVMX_AddService();
        mslaterms.SVMX_DeleteService();
        mslaterms.SVMX_GO();
        mslaterms.SVMX_AddSelected();
        mslaterms.SVMX_OpenPopup();
        mslaterms.SVMX_ChangeOfService();
        mslaterms.SVMX_NextToOR();
        mslaterms.SVMX_BackToIR();
        mslaterms.SVMX_NextToRestoration();
        mslaterms.SVMX_BackToOR();
        mslaterms.SVMX_NextToResolution();
        mslaterms.SVMX_BackToRestoration();
        mslaterms.SVMX_NextToServices();
        mslaterms.SVMX_BackToResolution();
        mslaterms.SVMX_DeleteSLA();
        mslaterms.setSearchKeyword('test');
        mslaterms.setDisbaleChkBox(true);
        mslaterms.setselectedTab('test');
        mslaterms.setCheckAllLines(true);
        mslaterms.setSLATerms(SLATerms);
        mslaterms.setSLA(SLATerms[0]);
        mslaterms.getResolutionClock();
        String str;
        mslaterms.setParameterID(str);
        mslaterms.setApplicableService(serviceList);
        SVMXC.SLAT_ManageSLATerms.SLAWrapper wraper=new SVMXC.SLAT_ManageSLATerms.SLAWrapper(SLADetail[0],'Per');
        wraper.updateCommitment(SLADetail[0],serviceList[0],'Per');
        wraper.updateCommitment(SLADetail[0],serviceList[1],'Per');
        wraper.updateCommitment(SLADetail[0],serviceList[2],'Per');
        wraper.updateCommitment(SLADetail[0],serviceList[3],'Per');
         //mslaterms.svmxTagList.clear();
        System.assert(mslaterms.getTAG001()!=null,'TAG001 assertion failed');
        System.assert(mslaterms.getTAG002()!=null,'TAG002 assertion failed');
        System.assert(mslaterms.getTAG003()!=null,'TAG003 assertion failed');
        System.assert(mslaterms.getTAG004()!=null,'TAG004 assertion failed');
        System.assert(mslaterms.getTAG005()!=null,'TAG005 assertion failed');
        System.assert(mslaterms.getTAG006()!=null,'TAG006 assertion failed');
        System.assert(mslaterms.getTAG007()!=null,'TAG007 assertion failed');
        System.assert(mslaterms.getTAG008()!=null,'TAG008 assertion failed');
        System.assert(mslaterms.getTAG009()!=null,'TAG009 assertion failed');
        System.assert(mslaterms.getTAG010()!=null,'TAG010 assertion failed');
        System.assert(mslaterms.getTAG011()!=null,'TAG011 assertion failed');
        System.assert(mslaterms.getTAG012()!=null,'TAG012 assertion failed');
        System.assert(mslaterms.getTAG013()!=null,'TAG013 assertion failed');
        System.assert(mslaterms.getTAG014()!=null,'TAG014 assertion failed');
        System.assert(mslaterms.getTAG015()!=null,'TAG015 assertion failed');
        System.assert(mslaterms.getTAG016()!=null,'TAG016 assertion failed');
        System.assert(mslaterms.getTAG017()!=null,'TAG017 assertion failed');
        System.assert(mslaterms.getTAG018()!=null,'TAG018 assertion failed');
        System.assert(mslaterms.getTAG019()!=null,'TAG019 assertion failed');
        System.assert(mslaterms.getTAG020()!=null,'TAG020 assertion failed');
        System.assert(mslaterms.getTAG021()!=null,'TAG021 assertion failed');
        System.assert(mslaterms.getTAG022()!=null,'TAG022 assertion failed');
        System.assert(mslaterms.getTAG023()!=null,'TAG023 assertion failed');
        System.assert(mslaterms.getTAG024()!=null,'TAG024 assertion failed');
        System.assert(mslaterms.getTAG025()!=null,'TAG025 assertion failed');
        System.assert(mslaterms.getTAG026()!=null,'TAG026 assertion failed');
        System.assert(mslaterms.getTAG027()!=null,'TAG027 assertion failed');
        System.assert(mslaterms.getTAG028()!=null,'TAG028 assertion failed');
        System.assert(mslaterms.getTAG029()!=null,'TAG029 assertion failed');
        System.assert(mslaterms.getTAG030()!=null,'TAG030 assertion failed');
        System.assert(mslaterms.getTAG031()!=null,'TAG031 assertion failed');
        System.assert(mslaterms.getTAG032()!=null,'TAG032 assertion failed');
        System.assert(mslaterms.getTAG033()!=null,'TAG033 assertion failed');
        System.assert(mslaterms.getTAG034()!=null,'TAG034 assertion failed');
        System.assert(mslaterms.getTAG035()!=null,'TAG035 assertion failed');
        System.assert(mslaterms.getTAG036()!=null,'TAG036 assertion failed');
        System.assert(mslaterms.getTAG037()!=null,'TAG037 assertion failed');
        System.assert(mslaterms.getTAG038()!=null,'TAG038 assertion failed');
        System.assert(mslaterms.getTAG039()!=null,'TAG039 assertion failed');
        System.assert(mslaterms.getTAG040()!=null,'TAG040 assertion failed');
        System.assert(mslaterms.getTAG041()!=null,'TAG041 assertion failed');
        System.assert(mslaterms.getTAG042()!=null,'TAG042 assertion failed');
        System.assert(mslaterms.getTAG043()!=null,'TAG043 assertion failed');
        System.assert(mslaterms.getTAG044()!=null,'TAG044 assertion failed');
        System.assert(mslaterms.getTAG045()!=null,'TAG045 assertion failed');
        System.assert(mslaterms.getTAG046()!=null,'TAG046 assertion failed');
        System.assert(mslaterms.getTAG047()!=null,'TAG047 assertion failed');
        System.assert(mslaterms.getTAG048()!=null,'TAG048 assertion failed');
        System.assert(mslaterms.getTAG049()!=null,'TAG049 assertion failed');
        System.assert(mslaterms.getTAG050()!=null,'TAG050 assertion failed');
        System.assert(mslaterms.getTAG051()!=null,'TAG051 assertion failed');
        System.assert(mslaterms.getTAG052()!=null,'TAG052 assertion failed');
        System.assert(mslaterms.getTAG053()!=null,'TAG053 assertion failed');
        System.assert(mslaterms.getTAG054()!=null,'TAG053 assertion failed');
        System.assert(mslaterms.getTAG055()!=null,'TAG055 assertion failed');
        System.assert(mslaterms.getTAG056()!=null,'TAG056 assertion failed');
        System.assert(mslaterms.getTAG057()!=null,'TAG057 assertion failed');
        System.assert(mslaterms.getTAG058()!=null,'TAG058 assertion failed');
        System.assert(mslaterms.getTAG059()!=null,'TAG059 assertion failed');
        System.assert(mslaterms.getTAG060()!=null,'TAG060 assertion failed');
        System.assert(mslaterms.getTAG061()!=null,'TAG061 assertion failed');
        System.assert(mslaterms.getTAG062()!=null,'TAG062 assertion failed');
        System.assert(mslaterms.getTAG063()!=null,'TAG063 assertion failed');
        System.assert(mslaterms.getTAG064()!=null,'TAG064 assertion failed');
        System.assert(mslaterms.getTAG065()!=null,'TAG065 assertion failed');
        System.assert(mslaterms.getTAG066()!=null,'TAG066 assertion failed');
        System.assert(mslaterms.getTAG067()!=null,'TAG067 assertion failed');
        System.assert(mslaterms.getTAG068()!=null,'TAG068 assertion failed');
        System.assert(mslaterms.getTAG069()!=null,'TAG069 assertion failed');
        System.assert(mslaterms.getTAG070()!=null,'TAG070 assertion failed');
        System.assert(mslaterms.getTAG071()!=null,'TAG071 assertion failed');
        System.assert(mslaterms.getTAG072()!=null,'TAG072 assertion failed');
        System.assert(mslaterms.getTAG073()!=null,'TAG073 assertion failed');
        System.assert(mslaterms.getTAG074()!=null,'TAG074 assertion failed');
        System.assert(mslaterms.getTAG075()!=null,'TAG075 assertion failed');
        System.assert(mslaterms.getTAG076()!=null,'TAG076 assertion failed');
        System.assert(mslaterms.getTAG077()!=null,'TAG077 assertion failed');
        System.assert(mslaterms.getTAG078()!=null,'TAG078 assertion failed');
        Test.stopTest();
    }
    
    static testMethod void unitTestMethod2(){
        List<SVMXC__Service_Level__c> SLATerms = new list<SVMXC__Service_Level__c>();
        List<RecordType> RecordTypes = new List<RecordType>();
        List<SVMXC__SLA_Detail__c> SLADetail = new List<SVMXC__SLA_Detail__c>();
        String CommitmentRtypeId,ServiceRtypeId;
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
        // creating objects
        
        BusinessHours bhour=[select id,name from BusinessHours limit 1];
        Time cutOffTime = time.newInstance(14, 0, 0, 0);      
        SVMXC__Service_Level__c slaone=new SVMXC__Service_Level__c(
                    Name='Test one',
                    SVMXC__Description__c='Test one Description',
                    SVMXC__Active__c =true,
                    SVMXC__Business_Hours__c = bhour.id , 
                    SVMXC__Initial_Response_Tracked_On__c = 'Workorder'  , 
                    SVMXC__Resolution_Tracked_On__c = 'Workorder',
                    SVMXC__Restoration_Tracked_On__c = 'Workorder',
                    SVMXC__Onsite_Response_Tracked_On__c = 'Workorder',
                    SVMXC__Select__c=true ,
                    SVMXC__SM_Initial_Unit_of_Measure__c='Day',
                    SVMXC__SM_Onsite_Unit_of_Measure__c='Day',
                    SVMXC__SM_Resolution_Unit_of_Measure__c='Day',
                    SVMXC__SM_Restoration_Unit_of_Measure__c='Day',
                    SVMXC__SM_Initial_SLA_Cutoff_Time__c=cutOffTime,
                    SVMXC__SM_Onsite_SLA_Cutoff_Time__c=cutOffTime,
                    SVMXC__SM_Resolution_SLA_Cutoff_Time__c=cutOffTime,
                    SVMXC__SM_Restoration_SLA_Cutoff_Time__c=cutOffTime);
                        
        SLATerms.add(slaone);
        insert SLATerms;
        
        SVMXC__SLA_Detail__c InitialResponse = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Initial Response',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'FromAccount',
            SVMXC__Business_Hours__c = bhour.id,
            SVMXC__SLA_Terms__c = SLATerms[0].id
            
        );
        SLADetail.add(InitialResponse);
        
        SVMXC__SLA_Detail__c OnsiteResponse = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Onsite Response',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'FromAccount',
            SVMXC__Business_Hours__c = bhour.id,
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
            SVMXC__Business_Hours_Source__c = 'FromAccount',
            SVMXC__Business_Hours__c = bhour.id,
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
            SVMXC__Business_Hours_Source__c = 'FromAccount',
            SVMXC__Business_Hours__c = bhour.id,
            SVMXC__SLA_Terms__c = SLATerms[0].id
            
        );
        SLADetail.add(Resolution);
        insert SLADetail;
        Test.startTest();
        PageReference pageRef = Page.SLAT_ManageSLATerms;
        Test.setCurrentPage(pageRef);
        SVMXC.SLAT_ManageSLATerms mslaterms = new SVMXC.SLAT_ManageSLATerms();
        //mslaterms.SVMX_ValidEditSALTerm();
        mslaterms.SVMX_EditSLATerm();
        mslaterms.toggleCutOffTimeIR();
        mslaterms.toggleCutOffTimeOR();
        mslaterms.toggleCutOffTimeREST();
        mslaterms.toggleCutOffTimeRESO();
        mslaterms.InitialCutoffTime();
        mslaterms.ResolutionCutoffTime();
        mslaterms.OnsiteCutoffTime();
        mslaterms.RestorationCutoffTime(); 
        mslaterms.toggleCutOffTimeIR();
        mslaterms.toggleCutOffTimeOR();
        mslaterms.toggleCutOffTimeREST();
        mslaterms.toggleCutOffTimeRESO();
        mslaterms.InitialCutoffTime();
        mslaterms.ResolutionCutoffTime();
        mslaterms.OnsiteCutoffTime();
        mslaterms.RestorationCutoffTime(); 
        mslaterms.SVMX_SaveSLA();
        test.stopTest();
    }
}