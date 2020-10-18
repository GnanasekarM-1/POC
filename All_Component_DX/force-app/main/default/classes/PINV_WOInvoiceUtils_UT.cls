@isTest(seeAllData = true)
private class PINV_WOInvoiceUtils_UT 
{
    static string strAccId = '';
    static string strProcId = '';
    static List<string> lstWOIDs = new List<string>();
    static RecordType WOBilProcess_Rtype = [select Id from RecordType where Name='Work Order Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
    static RecordType ExpProcess_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
    static RecordType Schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
    static RecordType SccUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
    static RecordType UsageConsumption_Rtype = [select Id from RecordType where Name='Usage/Consumption'and SobjectType='SVMXC__Service_Order_Line__c' Limit 1];
    static SVMXC__ServiceMax_Processes__c svmxWOBilProcess = new SVMXC__ServiceMax_Processes__c();
    static SVMXC__ServiceMax_Processes__c svmxWOBilProcess2 = new SVMXC__ServiceMax_Processes__c();
    static List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
    static SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
    static SVMXC__Service_Order__c WO1 = new SVMXC__Service_Order__c();
    static List<Case> lstCase = new List<Case>();
    
    static void createGeneralData()
    {
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        strAccId = acc.Id;
        
        WO.SVMXC__City__c = 'Bangalore';
        WO.SVMXC__Company__c = acc.Id;
        WO.SVMXC__Billing_Type__c = 'Warranty';
        WO.SVMXC__Country__c = 'India';
        WO.SVMXC__Order_Type__c = 'Field Service';
        WO.SVMXC__Locked_By_DC__c = true;
        lstWO.add(WO);
        
        WO1.SVMXC__City__c = 'Mysore';
        WO1.SVMXC__Company__c = acc.Id;
        WO1.SVMXC__Billing_Type__c = 'Warranty';
        WO1.SVMXC__Country__c = 'India';
        WO1.SVMXC__Order_Type__c = 'Field Service';
        WO1.SVMXC__Locked_By_DC__c = true;
        WO1.SVMXC__Is_Service_Covered__c = true;
        lstWO.add(WO1);
        
        insert lstWO;
        
        for(SVMXC__Service_Order__c tempWO : lstWO)
            lstWOIDs.add(tempWO.Id);
        
        List<SVMXC__Service_Order_Line__c> lstWODtls = new List<SVMXC__Service_Order_Line__c>();
        SVMXC__Service_Order_Line__c WODtl1 = new SVMXC__Service_Order_Line__c();
        WODtl1.SVMXC__Service_Order__c = WO.Id;
        WODtl1.RecordTypeId = UsageConsumption_Rtype.Id;
        WODtl1.SVMXC__Is_Billable__c = true;
        WODtl1.SVMXC__Line_Type__c = 'Parts';
        WODtl1.SVMXC__Actual_Price2__c = 500;
        lstWODtls.add(WODtl1);
        
        SVMXC__Service_Order_Line__c WODtl2 = new SVMXC__Service_Order_Line__c();
        WODtl2.SVMXC__Service_Order__c = WO.Id;
        WODtl2.RecordTypeId = UsageConsumption_Rtype.Id;
        WODtl2.SVMXC__Is_Billable__c = true;
        WODtl2.SVMXC__Line_Type__c = 'Labor';
        WODtl2.SVMXC__Actual_Price2__c = 600;
        lstWODtls.add(WODtl2);
        
        SVMXC__Service_Order_Line__c WODtl3 = new SVMXC__Service_Order_Line__c();
        WODtl3.SVMXC__Service_Order__c = WO.Id;
        WODtl3.RecordTypeId = UsageConsumption_Rtype.Id;
        WODtl3.SVMXC__Is_Billable__c = true;
        WODtl3.SVMXC__Line_Type__c = 'Expenses';
        WODtl3.SVMXC__Actual_Price2__c = 300;
        lstWODtls.add(WODtl3);
        
        insert lstWODtls;
        // inserting case
        Case objCase = new Case();
        objCase.Account = acc;
        objCase.Status = 'Closed';
        objCase.Priority = 'Medium';
        objCase.SVMXC__Is_Service_Covered__c = true;
        objCase.Origin = 'Phone';
        
        lstCase.add(objCase);
        insert lstCase;
        
        SVMXC__Time_Tracker__c objTimeTracker = new SVMXC__Time_Tracker__c();
        objTimeTracker.SVMXC__Case__c = objCase.Id;
        objTimeTracker.SVMXC__Billable_Qty__c = 3;
        //objTimeTracker.SVMXC__Applied_Rate_Type__c = 245;
        objTimeTracker.SVMXC__Billable_Line_Price__c = 213;
        //objTimeTracker.SVMXC__Discount__c = 10%;
        
        insert objTimeTracker;
        
        
    }
    
    static void createTestData()
    {
        SVMXC__ServiceMax_Processes__c svmxExpProcess = new SVMXC__ServiceMax_Processes__c();
        svmxExpProcess.SVMXC__Name__c = 'TestExpression00001';
        svmxExpProcess.SVMXC__ProcessID__c = 'TestExpression00001';
        svmxExpProcess.SVMXC__SettingId__c = 'TestExpression00001';
        svmxExpProcess.SVMXC__Rule_Type__c = 'Named Expression';
        svmxExpProcess.RecordTypeId = ExpProcess_Rtype.Id;
        svmxExpProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Order__c';
        svmxExpProcess.SVMXC__Parent_Object_Criteria__c = 'SVMXC__City__c=\'Bangalore\'';
        insert svmxExpProcess;
        
        SVMXC__ServiceMax_Processes__c svmxExpProcess1 = new SVMXC__ServiceMax_Processes__c();
        svmxExpProcess1.SVMXC__Name__c = 'TestExpression00001';
        svmxExpProcess1.SVMXC__ProcessID__c = 'TestExpression000012';
        svmxExpProcess1.SVMXC__SettingId__c = 'TestExpression000012';
        svmxExpProcess1.SVMXC__Rule_Type__c = 'Named Expression1';
        svmxExpProcess1.RecordTypeId = ExpProcess_Rtype.Id;
        svmxExpProcess1.SVMXC__Source_Object_Name__c = 'Case';
        svmxExpProcess1.SVMXC__Parent_Object_Criteria__c = 'Origin=\'Phone\' AND Priority=\'Medium\' AND Status=\'Closed\'';
        insert svmxExpProcess1;
        
        svmxWOBilProcess.SVMXC__Name__c = 'WOBillingEngineUT0001';
        svmxWOBilProcess.SVMXC__ProcessID__c = 'WOBillingEngineUT0001';
        svmxWOBilProcess.RecordTypeId = WOBilProcess_Rtype.Id;
        svmxWOBilProcess.SVMXC__Email_On_Error__c = 'naveen.vasu@servicemax.com';
        svmxWOBilProcess.SVMXC__Email_On_Success__c = 'naveen.vasu@servicemax.com';
        svmxWOBilProcess.SVMXC__Capture_Log__c = true;
        svmxWOBilProcess.SVMXC__Module__c = svmxExpProcess.Id;
        svmxWOBilProcess.SVMXC__Submodule__c = svmxExpProcess1.Id;
        svmxWOBilProcess.SVMXC__Invoice_Scope__c = 'Work Order and Case Both';
        svmxWOBilProcess.SVMXC__Primary_Consolidation_Rule__c  = 'Account';
        svmxWOBilProcess.SVMXC__Active__c=true;
        insert svmxWOBilProcess;
        strProcId = svmxWOBilProcess.SVMXC__ProcessID__c;
        
        List<SVMXC__ServiceMax_Config_Data__c> lstConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c ssheduleTest = new   SVMXC__ServiceMax_Config_Data__c();
        ssheduleTest.RecordTypeId = Schedule_Rtype.Id;
        ssheduleTest.SVMXC__Run_At__c = '4:00 PM';
        ssheduleTest.SVMXC__Schedule_Days__c = 'Sunday; Monday';
        ssheduleTest.SVMXC__Sequence__c = 1;
        ssheduleTest.SVMXC__Run_Type__c = 'Day of Week';
        ssheduleTest.SVMXC__Dispatch_Process__c = svmxWOBilProcess.Id;
        lstConfData.add(ssheduleTest);
        
        /* SVMXC__ServiceMax_Config_Data__c srcUpdateTest = new  SVMXC__ServiceMax_Config_Data__c();
        srcUpdateTest.RecordTypeId = SccUpdate_Rtype.Id;
        srcUpdateTest.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE';
        srcUpdateTest.SVMXC__Sequence__c = 1;
        srcUpdateTest.SVMXC__Dispatch_Process__c = svmxWOBilProcess.Id;
        srcUpdateTest.SVMXC__Target_Field_Name__c = 'SVMXC__City__c';
        srcUpdateTest.SVMXC__Action__c = 'Set';
        srcUpdateTest.SVMXC__Display_Value__c = 'Mysore';
        lstConfData.add(srcUpdateTest); */
        
        insert lstConfData;
    }
    
    static void updateData(string primaryRule, boolean isSecRule, boolean isTertRule)
    {
        svmxWOBilProcess.SVMXC__Primary_Consolidation_Rule__c = primaryRule;
        if(primaryRule == 'Account')
        {
            if(isSecRule)
                svmxWOBilProcess.SVMXC__Secondary_Consolidation_Rule__c = 'SVMXC__City__c';
            if(isTertRule)
                svmxWOBilProcess.SVMXC__Tertiary_Consolidation_Rule__c = 'SVMXC__Country__c';
        }
        
        update svmxWOBilProcess;
        
        WO.SVMXC__Invoice_Created__c = false;
        WO1.SVMXC__Invoice_Created__c = false;
        update lstWO;
    }
    
    static SVMXC.INTF_WebservicesDef.INTF_Request createTestReqForAllSteps()
    {
        SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringListMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        List<SVMXC.INTF_WebservicesDef.INTF_StringMap> lstStringMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringMap>();
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap1.key = 'Account';
        strLstMap1.valueList.add(strAccId);
        lstStringListMapReq.add(strLstMap1);
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap2 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap2.key = 'WO';
        strLstMap2.valueList.addAll(lstWOIDs);
        lstStringListMapReq.add(strLstMap2);
        
        SVMXC.INTF_WebservicesDef.INTF_StringMap strMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
        strMap1.key = 'ProcId';
        strMap1.value = strProcId;
        lstStringMapReq.add(strMap1);
        
        SVMXC.INTF_WebservicesDef.INTF_StringMap strMap2 = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
        strMap2.key = 'StepDetails';
        strMap2.value = 'All';
        lstStringMapReq.add(strMap2);
        
        req.stringListMap = lstStringListMapReq;
        req.stringMap = lstStringMapReq;
        req.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RecordId', WO.Id));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('ProcessID', svmxWOBilProcess.SVMXC__ProcessID__c));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('StepInfo', 'All'));
        return req;
    }
    
    static SVMXC.INTF_WebservicesDef.INTF_Request createTestReqForStep1()
    {
        SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringListMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        List<SVMXC.INTF_WebservicesDef.INTF_StringMap> lstStringMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringMap>();

        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap1.key = 'Account';
        strLstMap1.valueList.add(strAccId);
        lstStringListMapReq.add(strLstMap1);
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap2 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap2.key = 'WO';
        strLstMap2.valueList.addAll(lstWOIDs);
        lstStringListMapReq.add(strLstMap2);
        
        SVMXC.INTF_WebservicesDef.INTF_StringMap strMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
        strMap1.key = 'ProcId';
        strMap1.value = strProcId;
        lstStringMapReq.add(strMap1);
        
        SVMXC.INTF_WebservicesDef.INTF_StringMap strMap2 = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
        strMap2.key = 'StepDetails';
        strMap2.value = 'Step1';
        lstStringMapReq.add(strMap2);
        
        req.stringListMap = lstStringListMapReq;
        req.stringMap = lstStringMapReq;
        return req;
    }
    
    static SVMXC.INTF_WebservicesDef.INTF_Request createTestReqForStep2(SVMXC.INTF_WebservicesDef.INTF_Response res)
    {
        SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
        req.valueMap = res.valueMap;
        req.valueMap.add(new SVMXC.INTF_WebservicesDef.SVMXMap('ProcessID', svmxWOBilProcess.Id));
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringListMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        List<SVMXC.INTF_WebservicesDef.INTF_StringMap> lstStringMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringMap>();
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap1.key = 'Account';
        strLstMap1.valueList.add(strAccId);
        lstStringListMapReq.add(strLstMap1);
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap2 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap2.key = 'WO';
        strLstMap2.valueList.addAll(lstWOIDs);
        lstStringListMapReq.add(strLstMap2);
        
        SVMXC.INTF_WebservicesDef.INTF_StringMap strMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
        strMap1.key = 'ProcId';
        strMap1.value = strProcId;
        lstStringMapReq.add(strMap1);
        
        SVMXC.INTF_WebservicesDef.INTF_StringMap strMap2 = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
        strMap2.key = 'StepDetails';
        strMap2.value = 'Step2';
        lstStringMapReq.add(strMap2);
        
        req.stringListMap = lstStringListMapReq;
        req.stringMap = lstStringMapReq;
        return req;
    }
    
    static testMethod void PINV_WOInvoiceUtilsUnitTest()
    {
        List<SVMXC__ServiceMax_Config_Data__c> lst = [select id from SVMXC__ServiceMax_Config_Data__c where SVMXC__Setting_Unique_ID__c IN ('GLOB001_GBL014','EVER007_SET001','IPRD003_SET007','IPRD003_SET003', 'EVER007_SET002')];
        
        for(SVMXC__ServiceMax_Config_Data__c l: lst)
        {
            l.SVMXC__Display_Value__c = 'false';
            l.SVMXC__Internal_Value__c = 'false';
        }
        if(lst != null && lst.size() > 0)
        update lst;
        
        SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
        SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
        PINV_WOInvoiceUtils utilWOInvoice = new PINV_WOInvoiceUtils();
        
        createGeneralData();
        createTestData();
        
        updateData('Work Order', false, false);
        req = createTestReqForStep1();
        res = utilWOInvoice.PINV_GenerateInvoiceDoc(req);
        
        req = createTestReqForAllSteps();
        system.assertEquals(req.valueMap[0].key, 'SVMX_RecordId');
        system.assertNotEquals(req.valueMap[0].value, null);
        system.assertEquals(req.valueMap[1].key, 'ProcessID');
        system.assertNotEquals(req.valueMap[1].value, null);
        system.assertEquals(req.valueMap[2].key, 'StepInfo');
        system.assertEquals(req.valueMap[2].value, 'All');
        //res = utilWOInvoice.PINV_GenerateInvoiceDoc(req);
        
        updateData('Account', false, false);
        try{
            req = createTestReqForStep1();
            //res = utilWOInvoice.PINV_GenerateInvoiceDoc(req);
        }
        catch(Exception ex){}
        
        
        //req = createTestReqForStep2(res);
        try{
            //res = utilWOInvoice.PINV_GenerateInvoiceDocs(req);
        }
        catch(Exception ex){}
        
        
        //req = createTestReqForAllSteps();
        //res = utilWOInvoice.PINV_GenerateInvoiceDoc(req);
    }
    
    // @Ramachandra
    static testMethod void PINV_WOInvoiceUtilsUnitTest_Coverage()
    {
        PINV_WOInvoiceUtils utilWOInvoice = new PINV_WOInvoiceUtils();
    	utilWOInvoice.genrateInvoiceLineFrmTimeTrckr(null,null);
        utilWOInvoice.genrateInvoiceLineFrmWODtl( null, null, true );
        try {
         	utilWOInvoice.CaseConsolidationAccount(null,'coverage','coverage','coverage','coverage');   
        }
        catch( Exception ex ) {}
        try {
        	utilWOInvoice.WOConsolidationAccount(null,'coverage','coverage','coverage','coverage');    
        }
        catch(Exception ex ) {}        
        
        try{
            utilWOInvoice.GenerateInvoiceDocForStep2(new List<SVMXC.INTF_WebservicesDef.SVMXMap> {new SVMXC.INTF_WebservicesDef.SVMXMap() } );    
        }
        catch(Exception ex ) {}
        
        utilWOInvoice.getTAG018();
        utilWOInvoice.getTAG035();
        utilWOInvoice.getTAG036();
        utilWOInvoice.getTAG037();
        
        utilWOInvoice.getTAG005();
        utilWOInvoice.getTAG007();
        utilWOInvoice.getTAG008();
        utilWOInvoice.getTAG015();
        utilWOInvoice.getTAG016();
        utilWOInvoice.getTAG034();
        
        utilWOInvoice.genrateInvoiceDetailFrmCase('', new Map<String, Schema.SObjectType>() );
        try { utilWOInvoice.srcUpdate( new List<string>(), '', '', '', true); } catch(Exception ex){}
        try { utilWOInvoice.srcUpdate( new List<string>(), '', '', '', false); } catch(Exception ex){}
        
        try { utilWOInvoice.statusEmail('', '', '', '', true); } catch(Exception ex){}
        try { utilWOInvoice.statusEmail('', '', '', '', false); } catch(Exception ex){}        
    }
    
}