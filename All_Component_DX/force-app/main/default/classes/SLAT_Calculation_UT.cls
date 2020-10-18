@isTest(SeeAlldata=true)
private class SLAT_Calculation_UT 
{
    static testMethod void SLAT_CalculationUnitTest()
    {
        SVMXC.SLAT_Calculation obj;
        List<Case> CaseObjLst = new List<Case>();
        List<SVMXC__Service_Order__c>  WOObjLst = new List<SVMXC__Service_Order__c>();
        List<SVMXC__SLA_Detail__c> SLADetail = new List<SVMXC__SLA_Detail__c>();
        
        BusinessHours bhour=[select id,name from BusinessHours where IsActive = true limit 1];
        System.assertEquals(true, bhour != null);
        
        String CommitmentRtypeId;
        String ServiceRtypeId;
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
        SVMXC__Service_Level__c slaone = new SVMXC__Service_Level__c();
        slaone.Name='Test one';
        slaone.SVMXC__Description__c='Test one Description';
        slaone.SVMXC__Active__c =true;
        slaone.SVMXC__Initial_Response_Tracked_On__c = 'Case'; 
        slaone.SVMXC__Onsite_Response_Tracked_On__c = 'Case'; 
        slaone.SVMXC__Resolution_Tracked_On__c = 'Case'; 
        slaone.SVMXC__Restoration_Tracked_On__c = 'Case'; 
        slaone.SVMXC__Business_Hours__c = bhour.id;
        system.debug('asdfBHR'+bhour.id);
        insert slaone;
        System.assertEquals('Case', slaone.SVMXC__Initial_Response_Tracked_On__c);
        
        Account acc = new Account();
        acc.Name = 'abc';
        acc.SVMXC__Access_Hours__c = bhour.id;
        insert acc;
        System.assertEquals('abc', acc.Name);
        
        Product2 p = new Product2();
        p.Name = 'BMW';
        insert p;
        System.assertEquals('BMW', p.Name);
        
        SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();
        ib.Name = 'Pro1';
        ib.SVMXC__Product__c = p.id;
        ib.SVMXC__Access_Hours__c = bhour.id;
        insert ib;
        
        SVMXC__Service_Contract__c contract = new SVMXC__Service_Contract__c();
        contract.name= 'Con1';
        contract.SVMXC__Business_Hours__c = bhour.id;
        insert contract;
        System.assertEquals(true, contract != null);
        
        SVMXC__SLA_Detail__c InitialResponse = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__SLA_Terms__c = slaone.id
            
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
            SVMXC__SLA_Terms__c = slaone.id
            
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
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__SLA_Terms__c = slaone.id
            
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
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution);
       
        SVMXC__SLA_Detail__c InitialResponse1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(InitialResponse1);
        
        SVMXC__SLA_Detail__c OnsiteResponse1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(OnsiteResponse1);
        SVMXC__SLA_Detail__c Restoration1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Restoration1);
        
        SVMXC__SLA_Detail__c Resolution1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution1);
        
        SVMXC__SLA_Detail__c InitialResponse2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(InitialResponse2);
        
        SVMXC__SLA_Detail__c OnsiteResponse2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(OnsiteResponse2);
        SVMXC__SLA_Detail__c Restoration2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Restoration2);
        
        SVMXC__SLA_Detail__c Resolution2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution2);
        
        SVMXC__SLA_Detail__c InitialResponse3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Initial Response',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(InitialResponse3);
        
        SVMXC__SLA_Detail__c OnsiteResponse3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(OnsiteResponse3);
        SVMXC__SLA_Detail__c Restoration3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Restoration3);
        
        SVMXC__SLA_Detail__c Resolution3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution3);
        
        SVMXC__SLA_Detail__c InitialResponse4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id
        );
        SLADetail.add(InitialResponse4);
        
        SVMXC__SLA_Detail__c OnsiteResponse4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id
        );
        SLADetail.add(OnsiteResponse4);
        SVMXC__SLA_Detail__c Restoration4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id
        );
        SLADetail.add(Restoration4);
        
        SVMXC__SLA_Detail__c Resolution4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id     
        );
        SLADetail.add(Resolution4);
        
        insert SLADetail;
        System.assertEquals(true, SLADetail != null);
        
        
        Case Caseobj = new Case();
        Caseobj.Type = 'Electronic';
        Caseobj.Priority = 'Medium';
        Caseobj.SVMXC__SLA_Terms__c = slaone.id;
        Caseobj.AccountId = acc.id;
        Caseobj.SVMXC__Component__c = ib.id;
        Caseobj.SVMXC__Service_Contract__c = contract.id;
        CaseObjLst.add(Caseobj);
        //insert CaseObjLst;
        
        Case Caseobj1 = new Case();
        Caseobj1.SVMXC__Service_Contract__c = contract.id;
        insert Caseobj1;
        
        SVMXC__Service_Order__c WOObj = new SVMXC__Service_Order__c();
        WOObj.SVMXC__SLA_Terms__c = slaone.id;
        WOObj.SVMXC__Company__c = acc.id;
        WOObj.SVMXC__Component__c = ib.Id;
        WOObj.SVMXC__Order_Type__c = 'Electronic';
        WOObj.SVMXC__Priority__c = 'Medium';
        WOObj.SVMXC__Case__c = Caseobj1.id;
        WOObjLst.add(WOObj);
        insert WOObjLst;
        System.assertEquals(true, WOObjLst != null);
        
        test.startTest();
        obj = new SVMXC.SLAT_Calculation();
        obj.SLAT_CalculationOnCase(CaseObjLst);
        obj.SLAT_CalculationOnWO(WOObjLst);
        slaone.SVMXC__Initial_Response_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Onsite_Response_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Resolution_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Restoration_Tracked_On__c = 'WorkOrder'; 
        update slaone;
        obj.SLAT_CalculationOnWO(WOObjLst);
        
        ///////////////////added for SLA clock reporting
        List<Task> lstTask = new List<Task>();
        Task tsk1 = new Task();
        tsk1.Subject = 'SLA Clock Stop';
        tsk1.WhatId = WOObj.id;
        lstTask.add(tsk1);
        Task tsk2 = new Task();
        tsk2.Subject = 'SLA Clock Start';
        tsk2.WhatId = WOObj.id;
        lstTask.add(tsk2);
        insert lstTask;
        
        WOObj.SVMXC__Actual_Initial_Response__c = System.Now().addHours(1);
        WOObj.SVMXC__Actual_Onsite_Response__c = System.Now().addHours(2);
        WOObj.SVMXC__Actual_Restoration__c = System.Now().addHours(3);
        WOObj.SVMXC__Actual_Resolution__c = System.Now().addHours(4);
        update WOObj;
        
        WOObj.SVMXC__Actual_Initial_Response__c = null;
        WOObj.SVMXC__Actual_Onsite_Response__c = null;
        WOObj.SVMXC__Actual_Restoration__c = null;
        WOObj.SVMXC__Actual_Resolution__c = null;
        update WOObj;
        ///////////////////
        Test.stopTest();
    }
    
    static testMethod void SLAT_CalculationUnitTest1()
    {
        SVMXC.SLAT_Calculation obj;
        List<Case> CaseObjLst = new List<Case>();
        List<SVMXC__Service_Order__c>  WOObjLst = new List<SVMXC__Service_Order__c>();
        List<SVMXC__SLA_Detail__c> SLADetail = new List<SVMXC__SLA_Detail__c>();
        
        BusinessHours bhour=[select id,name from BusinessHours where IsActive = true limit 1];
        System.assertEquals(true, bhour != null);
        
        String CommitmentRtypeId;
        String ServiceRtypeId;
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
        Time cutOffTime = time.newInstance(14, 0, 0, 0);
        SVMXC__Service_Level__c slaone = new SVMXC__Service_Level__c();
        slaone.Name='Test one';
        slaone.SVMXC__Description__c='Test one Description';
        slaone.SVMXC__Active__c =true;
        slaone.SVMXC__Initial_Response_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Onsite_Response_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Resolution_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Restoration_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__SM_Initial_Unit_of_Measure__c='Day';
        slaone.SVMXC__SM_Onsite_Unit_of_Measure__c='Day';
        slaone.SVMXC__SM_Resolution_Unit_of_Measure__c='Day';
        slaone.SVMXC__SM_Restoration_Unit_of_Measure__c='Day';
        slaone.SVMXC__SM_Initial_SLA_Cutoff_Time__c=cutOffTime;
        slaone.SVMXC__SM_Onsite_SLA_Cutoff_Time__c=cutOffTime;
        slaone.SVMXC__SM_Resolution_SLA_Cutoff_Time__c=cutOffTime;
        slaone.SVMXC__SM_Restoration_SLA_Cutoff_Time__c=cutOffTime;
        
        slaone.SVMXC__Business_Hours__c = bhour.id;
        system.debug('asdfBHR'+bhour.id);
        insert slaone;
        System.assertEquals('WorkOrder', slaone.SVMXC__Initial_Response_Tracked_On__c);
        
        Account acc = new Account();
        acc.Name = 'abc';
        acc.SVMXC__Access_Hours__c = bhour.id;
        insert acc;
        System.assertEquals('abc', acc.Name);
        
        Product2 p = new Product2();
        p.Name = 'BMW';
        insert p;
        System.assertEquals('BMW', p.Name);
        
        SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();
        ib.Name = 'Pro1';
        ib.SVMXC__Product__c = p.id;
        ib.SVMXC__Access_Hours__c = bhour.id;
        insert ib;
        
        SVMXC__Service_Contract__c contract = new SVMXC__Service_Contract__c();
        contract.name= 'Con1';
        contract.SVMXC__Business_Hours__c = bhour.id;
        insert contract;
        System.assertEquals(true, contract != null);
        
        SVMXC__SLA_Detail__c InitialResponse = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__SLA_Terms__c = slaone.id
            
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
            SVMXC__SLA_Terms__c = slaone.id
            
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
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__SLA_Terms__c = slaone.id
            
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
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution);
       
        SVMXC__SLA_Detail__c InitialResponse1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(InitialResponse1);
        
        SVMXC__SLA_Detail__c OnsiteResponse1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(OnsiteResponse1);
        SVMXC__SLA_Detail__c Restoration1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Restoration1);
        
        SVMXC__SLA_Detail__c Resolution1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution1);

        SVMXC__SLA_Detail__c InitialResponse2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(InitialResponse2);
        
        SVMXC__SLA_Detail__c OnsiteResponse2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(OnsiteResponse2);
        
        SVMXC__SLA_Detail__c Restoration2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Restoration2);
        
        SVMXC__SLA_Detail__c Resolution2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution2);

        SVMXC__SLA_Detail__c InitialResponse3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id
        );
        SLADetail.add(InitialResponse3);
        
        SVMXC__SLA_Detail__c OnsiteResponse3= new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id
        );
        SLADetail.add(OnsiteResponse3);
        SVMXC__SLA_Detail__c Restoration3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id          
        );
        SLADetail.add(Restoration3);
        
        SVMXC__SLA_Detail__c Resolution3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id            
        );
        SLADetail.add(Resolution3);

        SVMXC__SLA_Detail__c InitialResponse4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(InitialResponse4);
        
        SVMXC__SLA_Detail__c OnsiteResponse4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(OnsiteResponse4);
        SVMXC__SLA_Detail__c Restoration4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Restoration4);
        
        SVMXC__SLA_Detail__c Resolution4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution4);

        
        insert SLADetail;
        System.assertEquals(true, SLADetail != null);
        
        
        Case Caseobj = new Case();
        Caseobj.Type = 'Electronic';
        Caseobj.Priority = 'Medium';
        Caseobj.SVMXC__SLA_Terms__c = slaone.id;
        Caseobj.AccountId = acc.id;
        Caseobj.SVMXC__Component__c = ib.id;
        Caseobj.SVMXC__Service_Contract__c = contract.id;
        CaseObjLst.add(Caseobj);
                
        Case Caseobj1 = new Case();
        Caseobj1.SVMXC__Service_Contract__c = contract.id;
        insert Caseobj1;
         CaseObjLst.add(Caseobj1);
         
        SVMXC__Service_Order__c WOObj = new SVMXC__Service_Order__c();
        WOObj.SVMXC__SLA_Terms__c = slaone.id;
        WOObj.SVMXC__Company__c = acc.id;
        WOObj.SVMXC__Component__c = ib.Id;
        WOObj.SVMXC__Order_Type__c = 'Electronic';
        WOObj.SVMXC__Priority__c = 'Medium';
        WOObj.SVMXC__Case__c = Caseobj1.id;
        WOObj.SVMXC__Is_SLA_Calculated__c =true;
          insert WOObj;
        WOObjLst.add(WOObj);
      
      SVMXC__Service_Order__c WOObj1 = new SVMXC__Service_Order__c();
        WOObj1.SVMXC__SLA_Terms__c = slaone.id;
        WOObj1.SVMXC__Company__c = acc.id;
        WOObj1.SVMXC__Component__c = ib.Id;
        WOObj1.SVMXC__Order_Type__c = 'Electronic';
        WOObj1.SVMXC__Priority__c = 'Medium';
        WOObj1.SVMXC__Case__c = Caseobj1.id;
        WOObj1.SVMXC__Is_SLA_Calculated__c =true;
          insert WOObj1;
           WOObjLst.add(WOObj1);
      
        System.assertEquals(true, WOObjLst != null);
        
        test.startTest();
        obj = new SVMXC.SLAT_Calculation();
        obj.SLAT_CalculationOnCase(CaseObjLst);
        obj.SLAT_CalculationOnWO(WOObjLst);
        slaone.SVMXC__Initial_Response_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Onsite_Response_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Resolution_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Restoration_Tracked_On__c = 'WorkOrder'; 
        update slaone;
        obj.SLAT_CalculationOnWO(WOObjLst);
        Test.stopTest();
    }
    static testMethod void SLAT_CalculationUnitTest2()
    {
        SVMXC.SLAT_Calculation obj;
        List<Case> CaseObjLst = new List<Case>();
        List<SVMXC__Service_Order__c>  WOObjLst = new List<SVMXC__Service_Order__c>();
        List<SVMXC__SLA_Detail__c> SLADetail = new List<SVMXC__SLA_Detail__c>();
        
        BusinessHours bhour=[select id,name from BusinessHours where IsActive = true limit 1];
        System.assertEquals(true, bhour != null);
        
        String CommitmentRtypeId;
        String ServiceRtypeId;
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
        SVMXC__Service_Level__c slaone = new SVMXC__Service_Level__c();
        slaone.Name='Test one';
        slaone.SVMXC__Description__c='Test one Description';
        slaone.SVMXC__Active__c =true;
        slaone.SVMXC__Initial_Response_Tracked_On__c = 'Case'; 
        slaone.SVMXC__Onsite_Response_Tracked_On__c = 'Case'; 
        slaone.SVMXC__Resolution_Tracked_On__c = 'Case'; 
        slaone.SVMXC__Restoration_Tracked_On__c = 'Case'; 
        slaone.SVMXC__Business_Hours__c = bhour.id;
        system.debug('asdfBHR'+bhour.id);
        insert slaone;
        System.assertEquals('Case', slaone.SVMXC__Initial_Response_Tracked_On__c);
        
        Account acc = new Account();
        acc.Name = 'abc';
        acc.SVMXC__Access_Hours__c = bhour.id;
        insert acc;
        System.assertEquals('abc', acc.Name);
        
        Product2 p = new Product2();
        p.Name = 'BMW';
        insert p;
        System.assertEquals('BMW', p.Name);
        
        SVMXC__Installed_Product__c ib = new SVMXC__Installed_Product__c();
        ib.Name = 'Pro1';
        ib.SVMXC__Product__c = p.id;
        ib.SVMXC__Access_Hours__c = bhour.id;
        insert ib;
        
        SVMXC__Service_Contract__c contract = new SVMXC__Service_Contract__c();
        contract.name= 'Con1';
        contract.SVMXC__Business_Hours__c = bhour.id;
        insert contract;
        System.assertEquals(true, contract != null);
        
        SVMXC__SLA_Detail__c InitialResponse = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__SLA_Terms__c = slaone.id
            
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
            SVMXC__SLA_Terms__c = slaone.id
            
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
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__SLA_Terms__c = slaone.id
            
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
            SVMXC__Business_Hours_Source__c = 'Account',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution);
       
        SVMXC__SLA_Detail__c InitialResponse1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(InitialResponse1);
        
        SVMXC__SLA_Detail__c OnsiteResponse1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(OnsiteResponse1);
        SVMXC__SLA_Detail__c Restoration1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Restoration1);
        
        SVMXC__SLA_Detail__c Resolution1 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Product',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution1);
        
        SVMXC__SLA_Detail__c InitialResponse2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(InitialResponse2);
        
        SVMXC__SLA_Detail__c OnsiteResponse2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(OnsiteResponse2);
        SVMXC__SLA_Detail__c Restoration2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Restoration2);
        
        SVMXC__SLA_Detail__c Resolution2 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Contract',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution2);
        
        SVMXC__SLA_Detail__c InitialResponse3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Initial Response',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(InitialResponse3);
        
        SVMXC__SLA_Detail__c OnsiteResponse3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(OnsiteResponse3);
        SVMXC__SLA_Detail__c Restoration3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Restoration3);
        
        SVMXC__SLA_Detail__c Resolution3 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'SLA',
            SVMXC__SLA_Terms__c = slaone.id
            
        );
        SLADetail.add(Resolution3);
        
        SVMXC__SLA_Detail__c InitialResponse4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'InitialResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id            
        );
        SLADetail.add(InitialResponse4);
        
        SVMXC__SLA_Detail__c OnsiteResponse4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'OnsiteResponse',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id
        );
        SLADetail.add(OnsiteResponse4);
        SVMXC__SLA_Detail__c Restoration4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Restoration',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id
        );
        SLADetail.add(Restoration4);
        
        SVMXC__SLA_Detail__c Resolution4 = new SVMXC__SLA_Detail__c(
            SVMXC__Commitment_Type__c = 'Resolution',
            RecordTypeId = CommitmentRtypeId,
            SVMXC__Type__c = 'Electronic',
            SVMXC__Priority__c = 'Medium',
            SVMXC__Clock_Starts_From__c = 'CreatedDate',
            SVMXC__Internal_Goal__c = 123,
            SVMXC__Customer_Commitment__c =123,
            SVMXC__Business_Hours_Source__c = 'Custom',
            SVMXC__SLA_Terms__c = slaone.id,
            SVMXC__Business_Hours__c = bhour.id            
        );
        SLADetail.add(Resolution4);
        
        insert SLADetail;
        System.assertEquals(true, SLADetail != null);
        
        
        Case Caseobj = new Case();
        Caseobj.Type = 'Electronic';
        Caseobj.Priority = 'Medium';
        Caseobj.SVMXC__SLA_Terms__c = slaone.id;
        Caseobj.AccountId = acc.id;
        Caseobj.SVMXC__Component__c = ib.id;
        Caseobj.SVMXC__Service_Contract__c = contract.id;
        CaseObjLst.add(Caseobj);
        
        Case Caseobj2 = new Case();
        Caseobj2.Type = 'Electronic';
        Caseobj2.Priority = 'Medium';
        Caseobj2.SVMXC__SLA_Terms__c = slaone.id;
        Caseobj2.AccountId = acc.id;
        Caseobj2.SVMXC__Component__c = ib.id;
        Caseobj2.SVMXC__Service_Contract__c = contract.id;
        Caseobj2.SVMXC__Actual_Initial_Response__c = System.Now();
        CaseObjLst.add(Caseobj2);
        insert CaseObjLst;
        
        Case Caseobj1 = new Case();
        Caseobj1.SVMXC__Service_Contract__c = contract.id;
        insert Caseobj1;
        
        SVMXC__Service_Order__c WOObj = new SVMXC__Service_Order__c();
        WOObj.SVMXC__SLA_Terms__c = slaone.id;
        WOObj.SVMXC__Company__c = acc.id;
        WOObj.SVMXC__Component__c = ib.Id;
        WOObj.SVMXC__Order_Type__c = 'Electronic';
        WOObj.SVMXC__Priority__c = 'Medium';
        WOObj.SVMXC__Case__c = Caseobj1.id;
        WOObjLst.add(WOObj);
        insert WOObjLst;
        System.assertEquals(true, WOObjLst != null);
        
        test.startTest();
        obj = new SVMXC.SLAT_Calculation();
        obj.calculateResponseTimeForCase(new map<String, Case>{CaseObjLst[0].id => CaseObjLst[0]}, new map<String, Case>{CaseObjLst[0].id => CaseObjLst[0]});//test
        obj.calculateResponseTimeForCase(new map<String, Case>{CaseObjLst[0].id => CaseObjLst[0]}, new map<String, Case>{CaseObjLst[0].id => CaseObjLst[1]});//test
        
        obj.SLAT_CalculationOnCase(CaseObjLst);
        
        CaseObjLst[0].SVMXC__Actual_Initial_Response__c = System.Now();
        update CaseObjLst;
        obj.calculateResponseTimeForCase(new map<String, Case>{CaseObjLst[0].id => CaseObjLst[0]}, new map<String, Case>{CaseObjLst[0].id => CaseObjLst[0]});//test
        
        obj.SLAT_CalculationOnWO(WOObjLst);
        slaone.SVMXC__Initial_Response_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Onsite_Response_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Resolution_Tracked_On__c = 'WorkOrder'; 
        slaone.SVMXC__Restoration_Tracked_On__c = 'WorkOrder'; 
        update slaone;
        obj.SLAT_CalculationOnWO(WOObjLst);
        
        obj.calculateResponseTimeForWO(new map<String,SVMXC__Service_Order__c>{WOObjLst[0].id => WOObjLst[0]}, new map<String,SVMXC__Service_Order__c>{WOObjLst[0].id => WOObjLst[0]});//test
        
        WOObjLst[0].SVMXC__Actual_Initial_Response__c = System.Now();///
        update WOObjLst;///
        obj.calculateResponseTimeForWO(new map<String,SVMXC__Service_Order__c>{WOObjLst[0].id => WOObjLst[0]}, new map<String,SVMXC__Service_Order__c>{WOObjLst[0].id => WOObjLst[0]});//test
        
        ///////////////////added by manish for SLA clock reporting
        Case objCase = new Case();
        objCase.SVMXC__Component__c = ib.id;
        objCase.Account = acc;
        objCase.Type = 'Electronic';
        objCase.Priority = 'Medium';
        objCase.SVMXC__Service_Contract__c = contract.id;
        objCase.SVMXC__SLA_Terms__c = slaone.id;
        insert objCase;
        
        List<Task> lstTask = new List<Task>();
        Task tsk1 = new Task();
        tsk1.Subject = 'SLA Clock Stop';
        tsk1.WhatId = objCase.id;
        lstTask.add(tsk1);
        Task tsk2 = new Task();
        tsk2.Subject = 'SLA Clock Start';
        tsk2.WhatId = objCase.id;
        lstTask.add(tsk2);
        insert lstTask;
        
        objCase.SVMXC__Actual_Initial_Response__c = System.Now().addHours(1);
        objCase.SVMXC__Actual_Onsite_Response__c = System.Now().addHours(2);
        objCase.SVMXC__Actual_Restoration__c = System.Now().addHours(3);
        objCase.SVMXC__Actual_Resolution__c = System.Now().addHours(4);
        update objCase;
        
        objCase.SVMXC__Actual_Initial_Response__c = null;
        objCase.SVMXC__Actual_Onsite_Response__c = null;
        objCase.SVMXC__Actual_Restoration__c = null;
        objCase.SVMXC__Actual_Resolution__c = null;
        update objCase;
        ///////////////////
        
        ///////////////
        SLAT_Calculation.SLAT_Request objSLAT_Request = new SLAT_Calculation.SLAT_Request();
        SLAT_Calculation.SLAT_Response objSLAT_Response = new SLAT_Calculation.SLAT_Response();
        SLAT_Calculation.SLAT_StringMap objSLAT_StringMap = new SLAT_Calculation.SLAT_StringMap();
        SLAT_Calculation.SLAT_StringMap objSLAT_StringMap1 = new SLAT_Calculation.SLAT_StringMap('ada','ada');
        SLAT_Calculation.SLAT_StringListMap objSLAT_StringListMap = new SLAT_Calculation.SLAT_StringListMap();
        SLAT_Calculation.SLAT_StringListMap objSLAT_StringListMap1 = new SLAT_Calculation.SLAT_StringListMap('ada',new List<String>());
        SLAT_Calculation.SLAT_SLABHInfo objSLAT_Calculation =  new SLAT_Calculation.SLAT_SLABHInfo('aa','aa','aa','aa','aa','aa','aa','aa','aa');
        //////////////
        Test.stopTest();
    }
    
}