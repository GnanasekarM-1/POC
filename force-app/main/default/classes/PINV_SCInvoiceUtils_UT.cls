@isTest
private class PINV_SCInvoiceUtils_UT 
{
    static string strAccId = '';
    static string strProcId = '';
    static List<string> lstSCIDs = new List<string>();
    static RecordType SCBilProcess_Rtype = [select Id from RecordType where Name='Contract Billing Process'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
    static RecordType ExpProcess_Rtype = [select Id from RecordType where Name='SVMX Rule'and SobjectType='SVMXC__ServiceMax_Processes__c' Limit 1];
    static RecordType Schedule_Rtype = [select Id from RecordType where Name='Schedule'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
    static RecordType SccUpdate_Rtype = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];
    static SVMXC__ServiceMax_Processes__c svmxSCBilProcess = new SVMXC__ServiceMax_Processes__c();
    static List<SVMXC__Service_Contract__c> lstSC = new List<SVMXC__Service_Contract__c>();
    static SVMXC__Service_Contract__c SC = new SVMXC__Service_Contract__c();
    static SVMXC__Service_Contract__c SC1 = new SVMXC__Service_Contract__c();
    
    static void createGeneralData()
    {
        Account acc = new Account();
        acc.Name = 'Testacc01';
        insert acc;
        strAccId = acc.Id;
        
        SC.SVMXC__Company__c = acc.Id;
        SC.SVMXC__Active__c = true;
        SC.SVMXC__Billing_Schedule__c = 'Annual';
        lstSC.add(SC);
        
        SC1.SVMXC__Company__c = acc.Id;
        SC1.SVMXC__Active__c = true;
        SC1.SVMXC__Billing_Schedule__c = 'Quarterly';
        lstSC.add(SC1);
        
        insert lstSC;
        
        for(SVMXC__Service_Contract__c tempSC : lstSC)
            lstSCIDs.add(tempSC.Id);
        
        List<SVMXC__Service_Contract_Products__c> lstSCDtlspro = new List<SVMXC__Service_Contract_Products__c>();
        SVMXC__Service_Contract_Products__c SCDtl1pro = new SVMXC__Service_Contract_Products__c();
        SCDtl1pro.SVMXC__Service_Contract__c = SC.Id;
        SCDtl1pro.SVMXC__Is_Billable__c = true;
        SCDtl1pro.SVMXC__Line_Price__c = 300;
        SCDtl1pro.SVMXC__Notes__c = 'test';
        lstSCDtlspro.add(SCDtl1pro);
        
        SVMXC__Service_Contract_Products__c SCDtl2pro = new SVMXC__Service_Contract_Products__c();
        SCDtl2pro.SVMXC__Service_Contract__c = SC.Id;
        SCDtl2pro.SVMXC__Is_Billable__c = true;
        SCDtl2pro.SVMXC__Line_Price__c = 400;
        SCDtl2pro.SVMXC__Notes__c = 'test';
        lstSCDtlspro.add(SCDtl2pro);
        
        SVMXC__Service_Contract_Products__c SCDtl3pro = new SVMXC__Service_Contract_Products__c();
        SCDtl3pro.SVMXC__Service_Contract__c = SC.Id;
        SCDtl3pro.SVMXC__Is_Billable__c = true;
        SCDtl3pro.SVMXC__Line_Price__c = 300;
        SCDtl3pro.SVMXC__Notes__c = 'test';
        lstSCDtlspro.add(SCDtl3pro);
                
        insert lstSCDtlspro;
        
        List<SVMXC__PM_Offering__c> lstSCDtlspm = new List<SVMXC__PM_Offering__c>();
        SVMXC__PM_Offering__c SCDtl1pm = new SVMXC__PM_Offering__c();
        SCDtl1pm.SVMXC__Service_Contract__c = SC.Id;
        SCDtl1pm.SVMXC__Is_Billable__c = true;
        lstSCDtlspm.add(SCDtl1pm);
        
        SVMXC__PM_Offering__c SCDtl2pm = new SVMXC__PM_Offering__c();
        SCDtl2pm.SVMXC__Service_Contract__c = SC.Id;
        SCDtl2pm.SVMXC__Is_Billable__c = true;
        lstSCDtlspm.add(SCDtl2pm);
        
        SVMXC__PM_Offering__c SCDtl3pm = new SVMXC__PM_Offering__c();
        SCDtl3pm.SVMXC__Service_Contract__c = SC.Id;
        SCDtl3pm.SVMXC__Is_Billable__c = true;
        lstSCDtlspm.add(SCDtl3pm);
        
        insert lstSCDtlspm;
        
        List<SVMXC__Service_Contract_Services__c> lstSCDtlsser = new List<SVMXC__Service_Contract_Services__c>();
        SVMXC__Service_Contract_Services__c SCDtl1ser = new SVMXC__Service_Contract_Services__c();
        SCDtl1ser.SVMXC__Service_Contract__c = SC.Id;
        SCDtl1ser.SVMXC__Is_Billable__c = true;
        SCDtl1ser.SVMXC__Line_Price__c = 300;
        lstSCDtlsser.add(SCDtl1ser);
        
        SVMXC__Service_Contract_Services__c SCDtl2ser = new SVMXC__Service_Contract_Services__c();
        SCDtl2ser.SVMXC__Service_Contract__c = SC.Id;
        SCDtl2ser.SVMXC__Is_Billable__c = true;
        SCDtl2ser.SVMXC__Line_Price__c = 400;
        lstSCDtlsser.add(SCDtl2ser);
        
        SVMXC__Service_Contract_Services__c SCDtl3ser = new SVMXC__Service_Contract_Services__c();
        SCDtl3ser.SVMXC__Service_Contract__c = SC.Id;
        SCDtl3ser.SVMXC__Is_Billable__c = true;
        SCDtl3ser.SVMXC__Line_Price__c = 300;
        lstSCDtlsser.add(SCDtl3ser);
        
        insert lstSCDtlsser;
        
        List<SVMXC__Service_Contract_Sites__c> lstSCDtlssites = new List<SVMXC__Service_Contract_Sites__c>();
        SVMXC__Service_Contract_Sites__c SCDtl1sites= new SVMXC__Service_Contract_Sites__c();
        SCDtl1sites.SVMXC__Service_Contract__c = SC.Id;
        SCDtl1sites.SVMXC__Is_Billable__c = true;
        SCDtl1sites.SVMXC__Line_Price__c = 300;
        lstSCDtlssites.add(SCDtl1sites);
        
        SVMXC__Service_Contract_Sites__c SCDtl2sites = new SVMXC__Service_Contract_Sites__c();
        SCDtl2sites.SVMXC__Service_Contract__c = SC.Id;
        SCDtl2sites.SVMXC__Is_Billable__c = true;
        SCDtl2sites.SVMXC__Line_Price__c = 400;
        lstSCDtlssites.add(SCDtl2sites);
        
        SVMXC__Service_Contract_Sites__c SCDtl3sites = new SVMXC__Service_Contract_Sites__c();
        SCDtl3sites.SVMXC__Service_Contract__c = SC.Id;
        SCDtl3sites.SVMXC__Is_Billable__c = true;
        SCDtl3sites.SVMXC__Line_Price__c = 300;
        lstSCDtlssites.add(SCDtl3sites);
        
        insert lstSCDtlssites;
    }
    
    static void createTestData()
    {
        SVMXC__ServiceMax_Processes__c svmxExpProcess = new SVMXC__ServiceMax_Processes__c();
        svmxExpProcess.SVMXC__Name__c = 'TestExpression00001';
        svmxExpProcess.SVMXC__ProcessID__c = 'TestExpression00001';
        svmxExpProcess.SVMXC__SettingId__c = 'TestExpression00001';
        svmxExpProcess.SVMXC__Rule_Type__c = 'Named Expression';
        svmxExpProcess.RecordTypeId = ExpProcess_Rtype.Id;
        svmxExpProcess.SVMXC__Source_Object_Name__c = 'SVMXC__Service_Contract__c';
        svmxExpProcess.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Active__c = true';
        svmxExpProcess.SVMXC__Primary_Consolidation_Rule__c= 'Account';     
        insert svmxExpProcess;
        
        svmxSCBilProcess.SVMXC__Name__c = 'SCBillingEngineUT0001';
        svmxSCBilProcess.SVMXC__ProcessID__c = svmxExpProcess.id;
        svmxSCBilProcess.RecordTypeId = SCBilProcess_Rtype.Id;
        svmxSCBilProcess.SVMXC__Email_On_Error__c = 'moshe.s@servicemax.com';
        svmxSCBilProcess.SVMXC__Email_On_Success__c = 'moshe.s@servicemax.com';
        svmxSCBilProcess.SVMXC__Capture_Log__c = true;
        svmxSCBilProcess.SVMXC__Module__c = svmxExpProcess.Id;
        svmxSCBilProcess.SVMXC__Primary_Consolidation_Rule__c= 'Account';
        svmxSCBilProcess.SVMXC__Active__c=true;
        insert svmxSCBilProcess;
        strProcId = svmxSCBilProcess.SVMXC__ProcessID__c;
      
        List<SVMXC__ServiceMax_Config_Data__c> lstConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c ssheduleTest = new SVMXC__ServiceMax_Config_Data__c();
        ssheduleTest.RecordTypeId = Schedule_Rtype.Id;
        ssheduleTest.SVMXC__Run_At__c = '4:00 PM';
        ssheduleTest.SVMXC__Schedule_Days__c = 'Sunday; Monday';
        ssheduleTest.SVMXC__Sequence__c = 1;
        ssheduleTest.SVMXC__Run_Type__c = 'Day of Week';
        ssheduleTest.SVMXC__Dispatch_Process__c = svmxSCBilProcess.Id;
        lstConfData.add(ssheduleTest);
                   
        SVMXC__ServiceMax_Config_Data__c srcUpdateTest = new  SVMXC__ServiceMax_Config_Data__c();
        srcUpdateTest.RecordTypeId = SccUpdate_Rtype.Id;
        srcUpdateTest.SVMXC__Configuration_Type__c = 'HEADER_UPD_ON_INVOICE';
        srcUpdateTest.SVMXC__Sequence__c = 1;
        srcUpdateTest.SVMXC__Dispatch_Process__c = svmxSCBilProcess.Id;
        srcUpdateTest.SVMXC__Target_Field_Name__c = 'SVMXC__Billing_Schedule__c';
        srcUpdateTest.SVMXC__Action__c = 'Set';
        srcUpdateTest.SVMXC__Display_Value__c = 'Monthly';
        lstConfData.add(srcUpdateTest); 
        
        insert lstConfData;
    }
    
    static void updateData(string primaryRule, boolean isSecRule, boolean isTertRule)
    {
        svmxSCBilProcess.SVMXC__Primary_Consolidation_Rule__c = primaryRule;
        if(primaryRule == 'Account')
        {
            if(isSecRule)
                svmxSCBilProcess.SVMXC__Secondary_Consolidation_Rule__c = 'SVMXC__Active__c';
            if(isTertRule)
                svmxSCBilProcess.SVMXC__Tertiary_Consolidation_Rule__c = 'SVMXC__Billing_Schedule__c';
        }
        update svmxSCBilProcess;
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
        strLstMap2.key = 'SC';
        strLstMap2.valueList.addAll(lstSCIDs);
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
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('SVMX_RecordId', SC.Id));
        req.valueMap.add(new SVMXC.INTF_WebServicesDef.SVMXMap('ProcessID', svmxSCBilProcess.SVMXC__ProcessID__c));
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
        strLstMap2.key = 'SC';
        strLstMap2.valueList.addAll(lstSCIDs);
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
    
    static SVMXC.INTF_WebservicesDef.INTF_Request createTestReqForStep2()
    {
        SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringListMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        List<SVMXC.INTF_WebservicesDef.INTF_StringMap> lstStringMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringMap>();
        
        List<SVMXC.INTF_WebservicesDef.SVMXMap> valuemap = new List<SVMXC.INTF_WebservicesDef.SVMXMap>();
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap1.key = 'Account';
        strLstMap1.valueList.add(strAccId);
        lstStringListMapReq.add(strLstMap1);
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap2 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap2.key = 'SC';
        strLstMap2.valueList.addAll(lstSCIDs);
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
        req.valueMap = valuemap;
        return req;
    }
       
    static testMethod void PINV_SCInvoiceUtilsUnitTest()
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
        PINV_SCInvoiceUtils utilSCInvoice = new PINV_SCInvoiceUtils();
        
        createGeneralData();
        createTestData();
        
        updateData('Account', false, false);
        req = createTestReqForStep1();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        updateData('Account', false, true);
        req = createTestReqForStep1();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        updateData('Account', true, false);
        req = createTestReqForStep1();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        updateData('Account', true, true);
        req = createTestReqForStep1();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        updateData('Contract', false, false);
        req = createTestReqForStep1();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        updateData('Contract', false, true);
        req = createTestReqForStep1();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        updateData('Contract', true, false);
        req = createTestReqForStep1();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        updateData('Contract', true, true);
        req = createTestReqForStep1();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        req = createTestReqForAllSteps();
        system.assertEquals(req.valueMap[0].key, 'SVMX_RecordId');
        system.assertNotEquals(req.valueMap[0].value, null);
        system.assertEquals(req.valueMap[1].key, 'ProcessID');
        system.assertNotEquals(req.valueMap[1].value, null);
        system.assertEquals(req.valueMap[2].key, 'StepInfo');
        system.assertEquals(req.valueMap[2].value, 'All');
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        //updateData('Account', false, false);
        //req = createTestReqForAllSteps();
        //res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
    }
    
    static testMethod void PINV_SCInvoiceUtilsUnitTest1()
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
        PINV_SCInvoiceUtils utilSCInvoice = new PINV_SCInvoiceUtils();
        
        createGeneralData();
        createTestData();
        
        updateData('Contract', false, false);
        req = createTestReqForStep1();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
        
        req = createTestReqForStep2();
        res = utilSCInvoice.PINV_GenerateSCInvoiceDoc(req);
    }
}