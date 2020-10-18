@isTest
private class OMAX_BatchRunPrecalc_UT 
{
    
    static testMethod void OMAX_BatchRunPrecalcTest() 
    {
        List<RecordType> RecType = new  List<RecordType>();
        List<RecordType> ConfigRecordTypes = new  List<RecordType>();
        string DispatchRTypeId;
        string RuleRecordTypeId;
        string ExpressionRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        system.debug('RecType'+RecType);
        System.assert(RecType != null, 'RecType assertion failed');
        
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
            if(Rt.Name == 'SVMX Rule')
            {
                RuleRecordTypeId = Rt.id;
            }
        }
        ConfigRecordTypes = Database.query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\'');
        for(RecordType r : ConfigRecordTypes)
        {
            if(r.Name == 'Expressions')
            {
                ExpressionRTypeId = r.id;
            }
        }
        //Create the Territory....
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'india';
        Territorylst.add(Territory1);
        
        SVMXC__Territory__c Territory2 = new SVMXC__Territory__c();
        Territory2.name = 'bangalore';
        Territorylst.add(Territory2);
        
        insert Territorylst;
        SVMXC__ServiceMax_Processes__c prcessObjtwo=new SVMXC__ServiceMax_Processes__c();
        prcessObjtwo.RecordTypeId =  DispatchRTypeId;
        prcessObjtwo.SVMXC__Name__c = 'Test two';
        prcessObjtwo.SVMXC__Dispatch_Method__c = 'Optimized Batch';
        prcessObjtwo.SVMXC__Runs_Every_Monday__c = true;
        prcessObjtwo.SVMXC__Runs_Every_Friday__c = true;
        prcessObjtwo.SVMXC__Start_Time__c= '11:00 PM';
        prcessObjtwo.SVMXC__Start_Date__c = system.today();
        prcessObjtwo.SVMXC__End_Date__c = system.today() + 12;
        prcessObjtwo.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjtwo.SVMXC__Weight_Time_Window__c = 1;
        prcessObjtwo.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjtwo.SVMXC__Weight_Route_Time__c = 1;
        prcessObjtwo.SVMXC__Weight_Node_Type__c = 1;
        prcessObjtwo.SVMXC__Values__c = Territorylst[0].id + ':U,';
        prcessObjtwo.SVMXC__Advance_Expression__c = '1 AND 2';
        prcessObjtwo.SVMXC__Product_Match_Enabled__c = true;
        prcessObjtwo.SVMXC__Expertise_Match_Enabled__c = true;
        
        insert prcessObjtwo;
        
        SVMXC__SVMX_Jobs__c objSVMXJob = new SVMXC__SVMX_Jobs__c();
        objSVMXJob.SVMXC__SVMX_Process__c = prcessObjtwo.id;
        objSVMXJob.SVMXC__Territory__c = Territorylst[0].id;
        objSVMXJob.SVMXC__OptiMax_Message__c = 'Running Precalc';
        objSVMXJob.SVMXC__Start_Time__c = system.now();
        objSVMXJob.SVMXC__Initiated_By__c = Userinfo.getUserId();
        objSVMXJob.SVMXC__Status__c = '100';
        objSVMXJob.SVMXC__Type__c = 'FULL';
        insert objSVMXJob;
        Account account = new Account(
                                        Name ='Account',
                                        ShippingStreet='ABC',
                                        ShippingCity='PQR ',
                                        ShippingState = 'XYZ',
                                        ShippingPostalCode='111',
                                        ShippingCountry='XYZ',
                                        BillingStreet='ABC',
                                        BillingCity='PQR ',
                                        BillingState = 'XYZ',
                                        BillingPostalCode='111',
                                        BillingCountry='XYZ'
                                        ); 
        insert account;
        Contact contact = new Contact(          
                                        LastName='Last',
                                        AccountId = account.Id,
                                        Email='svmxmailfortest@servicemax.com'
                                        );
        insert contact;
        Case case1 = new Case(Status ='New', Priority = 'Medium', 
                                        Origin = 'Email',                                        
                                                                                    
                                        ContactId =contact.Id,
                                        AccountId=account.Id
                                        ); 
        insert case1;
        SVMXC__Service_Order__c workorder = new SVMXC__Service_Order__c(
                                        SVMXC__Company__c = account.Id,
                                        SVMXC__Contact__c = contact.Id,
                                        SVMXC__Case__c = case1.Id,
                                        SVMXC__Order_Status__c = 'Open',
                                        SVMXC__Priority__c = 'Medium',
                                        SVMXC__Order_Type__c = 'Field Service',
                                        SVMXC__Primary_Territory__c = Territorylst[0].id, 
                                        SVMXC__Dispatch_Process__c = prcessObjtwo.id,
                                        SVMXC__OptiMax_Status__c = 'Initiated',
                                        SVMXC__Scheduled_Date_Time__c = system.now() + 120
                                         );
                                       
        insert workorder;
        OMAX_BatchRunPrecalc batchpro = new OMAX_BatchRunPrecalc(prcessObjtwo.id,Territorylst[0].id,objSVMXJob.id);
        id batchinstanceid = database.executeBatch(batchpro);
        List<Sobject> wo = new List<Sobject>();
        wo.add(workorder);
        Database.BatchableContext BC;
        batchpro.start(BC);
        batchpro.execute(BC,wo);
        batchpro.finish(BC);
    }    
}