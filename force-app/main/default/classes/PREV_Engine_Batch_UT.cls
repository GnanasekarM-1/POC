@isTest(seeAllData = true)
private class PREV_Engine_Batch_UT 
{
    static testMethod void PREV_Engine_BatchUnitTest()
    {
        //Data Creation
        RecordType PMProcess_Rtype = [select Id from RecordType where Name = 'PM Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
        
        SVMXC__ServiceMax_Processes__c objPMProcess1 = new SVMXC__ServiceMax_Processes__c();
        objPMProcess1.SVMXC__Name__c = 'PMProcess1-Test';
        objPMProcess1.SVMXC__ProcessID__c = 'PMProcess1-Test';
        objPMProcess1.SVMXC__Description__c = 'PMProcess1-Test';        
        objPMProcess1.RecordTypeId = PMProcess_Rtype.Id;
        objPMProcess1.SVMXC__Create_Work_Order__c = 'One per Plan';
        objPMProcess1.SVMXC__Frequency__c = 365;
        objPMProcess1.SVMXC__Active__c = true;
        objPMProcess1.SVMXC__Product_Match_Enabled__c = true;
        objPMProcess1.SVMXC__Email_On_Error__c = 'a@b.com';
        objPMProcess1.SVMXC__Email_On_Success__c = 'a@b.com';
        objPMProcess1.SVMXC__Target_Object_Name__c = 'Task';
        objPMProcess1.SVMXC__Include_Parent__c = true;
        insert objPMProcess1;  
        
        SVMXC__ServiceMax_Processes__c objPMProcess2 = new SVMXC__ServiceMax_Processes__c();
        objPMProcess2.SVMXC__Name__c = 'PMProcess1-Test';
        objPMProcess2.SVMXC__ProcessID__c = 'PMProcess1-Test';
        objPMProcess2.SVMXC__Description__c = 'PMProcess1-Test';        
        objPMProcess2.RecordTypeId = PMProcess_Rtype.Id;
        objPMProcess2.SVMXC__Create_Work_Order__c = 'One per Plan';
        objPMProcess2.SVMXC__Frequency__c = 365;
        objPMProcess2.SVMXC__Active__c = true;
        objPMProcess2.SVMXC__Product_Match_Enabled__c = true;
        objPMProcess2.SVMXC__Email_On_Error__c = 'a@b.com';
        objPMProcess2.SVMXC__Email_On_Success__c = 'a@b.com';
        objPMProcess2.SVMXC__Target_Object_Name__c = 'Task';
        objPMProcess2.SVMXC__Include_Parent__c = true;
        insert objPMProcess2;
        
        SVMXC__ServiceMax_Processes__c objPMProcess3 = new SVMXC__ServiceMax_Processes__c();
        objPMProcess3.SVMXC__Name__c = 'PMProcess3-Test';
        objPMProcess3.SVMXC__ProcessID__c = 'PMProcess3-Test';
        objPMProcess3.SVMXC__Description__c = 'PMProcess3-Test';        
        objPMProcess3.RecordTypeId = PMProcess_Rtype.Id;
        objPMProcess3.SVMXC__Create_Work_Order__c = 'One per Product';
        objPMProcess3.SVMXC__Frequency__c = 365;
        objPMProcess3.SVMXC__Active__c = true;
        objPMProcess3.SVMXC__Product_Match_Enabled__c = true;
        objPMProcess3.SVMXC__Email_On_Error__c = 'a@b.com';
        objPMProcess3.SVMXC__Email_On_Success__c = 'a@b.com';
        objPMProcess3.SVMXC__Target_Object_Name__c = 'Task';
        objPMProcess3.SVMXC__Include_Parent__c = false;
        insert objPMProcess3;
        
        Account objAcc = new Account(Name = 'SVMXTestAcc');
        insert objAcc;
        system.assert(objAcc.Name !=null);
        
        Product2 objProd = new Product2(Name = 'SVMXTestProduct');
        insert objProd;
        
        SVMXC__Service_Contract__c objSCON = new SVMXC__Service_Contract__c();
        objSCON.Name = 'SVMXTest_SCON001';
        objSCON.SVMXC__Active__c = true;
        objSCON.SVMXC__Company__c = objAcc.Id;
        objSCON.SVMXC__End_Date__c = date.today().addDays(1000);
        objSCON.SVMXC__Start_Date__c = date.today().addDays(-30);
        insert objSCON;
        system.assert(objSCON.Name !=null);
        
        List<SVMXC__PM_Plan__c> lstPMPlan = new List<SVMXC__PM_Plan__c>();
        SVMXC__PM_Plan__c objPMPlan1 = new SVMXC__PM_Plan__c();
        objPMPlan1.Name = 'SVMXTest_Plan1';
        objPMPlan1.SVMXC__Account__c = objAcc.Id;
        objPMPlan1.SVMXC__Service_Contract__c = objSCON.Id;
        objPMPlan1.SVMXC__Start_Date__c = date.today().addDays(-30);
        objPMPlan1.SVMXC__End_Date__c = date.today().addDays(1000);
        objPMPlan1.SVMXC__Status__c = 'Active';
        lstPMPlan.add(objPMPlan1);
        
        SVMXC__PM_Plan__c objPMPlan2 = new SVMXC__PM_Plan__c();
        objPMPlan2.Name = 'SVMXTest_Plan2';
        objPMPlan2.SVMXC__Account__c = objAcc.Id;
        objPMPlan2.SVMXC__Service_Contract__c = objSCON.Id;
        objPMPlan2.SVMXC__Start_Date__c = date.today().addDays(-30);
        objPMPlan2.SVMXC__End_Date__c = date.today().addDays(1000);
        objPMPlan2.SVMXC__Status__c = 'Cancel';
        lstPMPlan.add(objPMPlan2);
        
        SVMXC__PM_Plan__c objPMPlan3 = new SVMXC__PM_Plan__c();
        objPMPlan3.Name = 'SVMXTest_Plan3';
        objPMPlan3.SVMXC__Account__c = objAcc.Id;
        objPMPlan3.SVMXC__Service_Contract__c = objSCON.Id;
        objPMPlan3.SVMXC__Start_Date__c = date.today().addDays(-30);
        objPMPlan3.SVMXC__End_Date__c = date.today().addDays(1000);
        objPMPlan3.SVMXC__Status__c = 'Active';
        lstPMPlan.add(objPMPlan3);
        
        insert lstPMPlan;
        
        list<SVMXC__Installed_Product__c> InstalledProdLst = new list<SVMXC__Installed_Product__c>();
        for(integer j=0; j<501; j++)
        {
            SVMXC__Installed_Product__c objIB = new SVMXC__Installed_Product__c();
            objIB.SVMXC__Company__c = objAcc.Id;
            objIB.SVMXC__Product__c = objProd.Id;
            objIB.SVMXC__Serial_Lot_Number__c = 'Test_IB-00' + j;
            objIB.Name = 'Test_IB-00' + j;
            InstalledProdLst.add(objIB);
        }
        insert InstalledProdLst;
        
        list<SVMXC__PM_Schedule_Definition__c> lstScheduleDef = new list<SVMXC__PM_Schedule_Definition__c>();
        for(integer j=0; j<2; j++)
        {
            SVMXC__PM_Schedule_Definition__c objScheduleDef = new SVMXC__PM_Schedule_Definition__c();
            objScheduleDef.SVMXC__PM_Plan__c = lstPMPlan[j].Id;
            objScheduleDef.SVMXC__Schedule_Type__c = 'Time Based';
            objScheduleDef.SVMXC__Frequency__c = 5*(j+1);
            objScheduleDef.SVMXC__Frequency_Unit__c = 'weeks';
            lstScheduleDef.add(objScheduleDef);
        }
        insert lstScheduleDef;
        
        list<SVMXC__PM_Schedule__c> lstSchedule = new list<SVMXC__PM_Schedule__c>();
        for(integer j=1; j<2; j++)
        {
            SVMXC__PM_Schedule__c objSchedule = new SVMXC__PM_Schedule__c();
            objSchedule.SVMXC__PM_Plan__c = lstPMPlan[j-1].Id;
            objSchedule.SVMXC__PM_Schedule_Definition__c = lstScheduleDef[j-1].Id;
            objSchedule.SVMXC__Scheduled_On__c = date.today().addDays(5);
            objSchedule.SVMXC__Last_Run_Date__c = date.today();
            lstSchedule.add(objSchedule);
        }
        insert lstSchedule;
        
        list<SVMXC__PM_Coverage__c> lstPMCvrg = new list<SVMXC__PM_Coverage__c>();
        for(integer k=0; k<2; k++)
        {
            for(integer j=0; j<500; j++)
            {
                SVMXC__PM_Coverage__c objPMCvrg = new SVMXC__PM_Coverage__c();
                objPMCvrg.SVMXC__PM_Plan__c = lstPMPlan[k].Id;
                objPMCvrg.SVMXC__Product_Name__c = InstalledProdLst[j].Id;
                lstPMCvrg.add(objPMCvrg);
            }
            
        }
        insert lstPMCvrg;
        
        // Instanse creation and Calling method
        PREV_Engine_Batch objPMUtilsBatch = new PREV_Engine_Batch();
        Database.BatchableContext scPMEngine;
        
        objPMUtilsBatch.mapPMPlanIdPMProcessId2.put(lstPMPlan[0].Id, objPMProcess1.Id);
        objPMUtilsBatch.mapPMPlanIdPMProcessId2.put(lstPMPlan[1].Id, objPMProcess2.Id);
        objPMUtilsBatch.mapPMPlanIdPMProcessId2.put(lstPMPlan[2].Id, objPMProcess3.Id);
        objPMUtilsBatch.setProcessIds.add(objPMProcess1.Id);
        objPMUtilsBatch.setProcessIds.add(objPMProcess2.Id);
        objPMUtilsBatch.setProcessIds.add(objPMProcess3.Id);        
        objPMUtilsBatch.start(scPMEngine);
        /* try{
            objPMUtilsBatch.finish(scPMEngine);
        }
        catch(exception ex){} */
        objPMUtilsBatch.execute(scPMEngine,lstPMPlan);
        
        //ID Batch = database.executebatch(objPMUtilsBatch,1);
        try{
            objPMUtilsBatch.finish(scPMEngine);
        }
        catch(exception ex){}
    
        SVMXC__PM_Plan__c objPMPlan = new SVMXC__PM_Plan__c(Name = 'SVMXTest_Plan1', SVMXC__Start_Date__c = date.today().addDays(-30), SVMXC__End_Date__c = date.today().addDays(1000), SVMXC__Status__c = 'Active');
        insert objPMPlan;
        SVMXC__Service_Order__c objWO = new SVMXC__Service_Order__c(SVMXC__Order_Status__c = 'Open', SVMXC__PM_Plan__c = objPMPlan.Id,  SVMXC__Is_PM_Work_Order__c = true);
        insert objWO;
        List<String> lstWorkOrdIDs = new List<String>();
        lstWorkOrdIDs.add(objWO.Id);
        Set<String> setFailurePMPlanID = new Set<String>();
        setFailurePMPlanID.add(objPMPlan.Id);
        objPMUtilsBatch.rollBackPMExecution(lstWorkOrdIDs, setFailurePMPlanID);
        
        objPMUtilsBatch.getTAG001();
        objPMUtilsBatch.getTAG002();
        objPMUtilsBatch.getTAG003();
        objPMUtilsBatch.getTAG004();
        objPMUtilsBatch.getTAG005();
        objPMUtilsBatch.getTAG006();
        PREV_Engine_Batch.getTAG007();
        objPMUtilsBatch.getTAG008();
        objPMUtilsBatch.getTAG009();
        objPMUtilsBatch.getTAG010();
        objPMUtilsBatch.getTAG011();
        objPMUtilsBatch.getTAG012();
        objPMUtilsBatch.getTAG013();
        objPMUtilsBatch.getTAG014();
        objPMUtilsBatch.getTAG015();
        objPMUtilsBatch.getTAG016();
        objPMUtilsBatch.getTAG017();
        
        //test email attachment
        String subject = 'Testing Email';
        String testString = 'This is a test email\n sent for UT Coverage';
        Set<String> setEmailIDs = new Set<String>();
        setEmailIDs.add('a@b.com');
        PREV_Engine_Batch.emailStatusInfo(subject, testString, setEmailIDs, subject, TRUE);
    }
}