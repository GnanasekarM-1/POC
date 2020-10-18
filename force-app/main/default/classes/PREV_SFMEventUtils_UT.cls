@isTest(seeAllData = true)
private class PREV_SFMEventUtils_UT 
{
    static testMethod void PREV_SFMEventUtilsUnitTest()
    {
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqTgtRec = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objPMHeaFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> lstPMDetailsFromReq = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstPMHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objPMScheduleDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        
        //Data Creation for the different Scenerios for the generating PM Plans
        Account acc = new Account();
        acc.Name = 'ServiceMax';
        insert acc;
        
        SVMXC__Service_Contract__c SC = new SVMXC__Service_Contract__c();
        insert SC;
        
        Product2 prod = new Product2();
        prod.Name = 'SVMX Enterprise';
        insert prod;
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        IB.Name = 'SVMX Enterprise 00001';
        IB.SVMXC__Product__c = prod.Id;
        IB.SVMXC__Company__c = acc.Id;
        insert IB;
        
        SVMXC__Service_Contract_Products__c CP = new SVMXC__Service_Contract_Products__c();
        CP.SVMXC__Installed_Product__c = IB.Id;
        CP.SVMXC__Service_Contract__c = SC.Id;
        insert CP;
         
        SVMXC__PM_Plan_Template__c PMCat = new SVMXC__PM_Plan_Template__c();
        insert PMCat;
        
        SVMXC__PM_Applicable_Product__c applcblProd = new SVMXC__PM_Applicable_Product__c();
        applcblProd.SVMXC__PM_Plan_Template__c = PMCat.Id;
        applcblProd.SVMXC__Product__c = prod.Id;
        insert applcblProd;
        /*
        SVMXC__Time_Based_Visit_Schedule__c tmBsdSch = new SVMXC__Time_Based_Visit_Schedule__c();
        tmBsdSch.SVMXC__PM_Plan_Template__c = PMCat.Id;
        tmBsdSch.SVMXC__Recurring__c = true;
        tmBsdSch.SVMXC__Sequence__c = 1;
        tmBsdSch.SVMXC__Schedule_UOM__c = 'Months';
        tmBsdSch.SVMXC__Scheduled_On__c = 3;
        insert tmBsdSch;
        */
        date startDate = system.today();
        date endDate = system.today().addYears(2);
        
        //Creations of Key Values for the Header to be passed as parameter to the Methods of the AddPM Class
        SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap1 = new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Account__c', acc.Id);
        lstPMHeaAsKeyValue.add(tempStrMap1);
        SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap2 = new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__PM_Plan_Template__c', PMCat.Id);
        lstPMHeaAsKeyValue.add(tempStrMap2);
        SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap3 = new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Start_Date__c', string.valueOf(startDate));
        lstPMHeaAsKeyValue.add(tempStrMap3);
        SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap4 = new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__End_Date__c', string.valueOf(endDate));
        lstPMHeaAsKeyValue.add(tempStrMap4);
        SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap5 = new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Service_Maintenance_Contract__c', SC.Id);
        lstPMHeaAsKeyValue.add(tempStrMap5);
        SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap6 = new SVMXC.INTF_WebServicesDef.INTF_StringMap('Id', SC.Id);
        lstPMHeaAsKeyValue.add(tempStrMap6);
        SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap7 = new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Coverage_Type__c', 'PRODUCT (MUST HAVE IB)');
        lstPMHeaAsKeyValue.add(tempStrMap7);
        
        SVMXC.INTF_WebServicesDef.INTF_Record tempRec = new SVMXC.INTF_WebServicesDef.INTF_Record();
        tempRec.targetRecordAsKeyValue = lstPMHeaAsKeyValue;
        objPMScheduleDetRec.add(tempRec);
        objPMHeaFromReq.records = objPMScheduleDetRec;
        
        objPMHeaFromReq.objName = 'SVMXC__PM_Plan__c';
        
        //Creations of Key Values for the Details to be passed as parameter to the Methods of the AddPM Class
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringMap strMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Product__c', IB.Id);
        lstKeyValue.add(strMap);
        SVMXC.INTF_WebServicesDef.INTF_Record tempRec1 = new SVMXC.INTF_WebServicesDef.INTF_Record();
        tempRec1.targetRecordAsKeyValue = lstKeyValue;
        objDetRec.add(tempRec1);
        
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject dtlRec1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        dtlRec1.objName = 'SVMXC__PM_Schedule__c';
        lstPMDetailsFromReq.add(dtlRec1);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject dtlRec2 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        dtlRec2.objName = 'SVMXC__PM_Coverage_Advanced__c';
        dtlRec2.records = objDetRec;
        lstPMDetailsFromReq.add(dtlRec2);
        
        reqTgtRec.headerRecord = objPMHeaFromReq;
        reqTgtRec.detailRecords = lstPMDetailsFromReq;
        
        //Creation of the Object of the Class and calling all the Methods of the AddPM Class
        PREV_SFMEventUtils addPM = new PREV_SFMEventUtils();
        addPM.INTF_CalculatePMPlanDetails_ACCT(reqTgtRec);
        addPM.INTF_CalculatePMPlanDetails_SCON(reqTgtRec);
        addPM.INTF_CalculatePMPlanDetails_LOC(reqTgtRec);
        addPM.INTF_CalculatePMPlanDetails_IPRD(reqTgtRec);
        
        PREV_SFMEventUtils.INTF_ActivatePMPlan_PREV_WS2(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_SCON_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_ACCT_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_LOC_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_IPRD_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_ActivatePMPlan_PREV_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CancelPMPlan_WS(reqTgtRec);
    }
    static testMethod void PREV_SFMEventUtilsUnitTest1()
    {
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqTgtRec = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objPMHeaFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> lstPMDetailsFromReq = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstPMHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objPMScheduleDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        
        //Data Creation for the different Sceneries for the generating PM Plans
        Account acc = new Account();
        acc.Name = 'ServiceMax';
        insert acc;
        
        SVMXC__Service_Contract__c SC = new SVMXC__Service_Contract__c();
        insert SC;
        
        Product2 prod = new Product2();
        prod.Name = 'SVMX Enterprise';
        insert prod;
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        IB.Name = 'SVMX Enterprise 00001';
        IB.SVMXC__Product__c = prod.Id;
        IB.SVMXC__Company__c = acc.Id;
        insert IB;
        
        SVMXC__Service_Contract_Products__c CP = new SVMXC__Service_Contract_Products__c();
        CP.SVMXC__Installed_Product__c = IB.Id;
        CP.SVMXC__Service_Contract__c = SC.Id;
        insert CP;
         
        SVMXC__PM_Plan_Template__c PMCat = new SVMXC__PM_Plan_Template__c();
        insert PMCat;
        
        SVMXC__PM_Applicable_Product__c applcblProd = new SVMXC__PM_Applicable_Product__c();
        applcblProd.SVMXC__PM_Plan_Template__c = PMCat.Id;
        applcblProd.SVMXC__Product__c = prod.Id;
        insert applcblProd;
        
        date startDate = system.today();
        date endDate = system.today().addYears(2);
        
        //Creations of Key Values for the Header to be passed as parameter to the Methods of the AddPM Class
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Account__c', acc.Id));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__PM_Plan_Template__c', PMCat.Id));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Start_Date__c', string.valueOf(startDate)));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__End_Date__c', string.valueOf(endDate)));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Service_Maintenance_Contract__c', SC.Id));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Coverage_Type__c', 'ACCOUNT (VISIT ONLY)'));
        
        SVMXC.INTF_WebServicesDef.INTF_Record tempRec = new SVMXC.INTF_WebServicesDef.INTF_Record();
        tempRec.targetRecordAsKeyValue = lstPMHeaAsKeyValue;
        objPMScheduleDetRec.add(tempRec);
        objPMHeaFromReq.records = objPMScheduleDetRec;
        
        objPMHeaFromReq.objName = 'SVMXC__PM_Plan__c';
        
        //Creations of Key Values for the Details to be passed as parameter to the Methods of the AddPM Class
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringMap strMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Product__c', IB.Id);
        lstKeyValue.add(strMap);
        SVMXC.INTF_WebServicesDef.INTF_Record tempRec1 = new SVMXC.INTF_WebServicesDef.INTF_Record();
        tempRec1.targetRecordAsKeyValue = lstKeyValue;
        objDetRec.add(tempRec1);
        
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject dtlRec1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        dtlRec1.objName = 'SVMXC__PM_Schedule__c';
        lstPMDetailsFromReq.add(dtlRec1);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject dtlRec2 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        dtlRec2.objName = 'SVMXC__PM_Coverage_Advanced__c';
        dtlRec2.records = objDetRec;
        lstPMDetailsFromReq.add(dtlRec2);
        
        reqTgtRec.headerRecord = objPMHeaFromReq;
        reqTgtRec.detailRecords = lstPMDetailsFromReq;
        
        //Creation of the Object of the Class and calling all the Methods of the AddPM Class
        PREV_SFMEventUtils addPM = new PREV_SFMEventUtils();
        addPM.INTF_CalculatePMPlanDetails_ACCT(reqTgtRec);
        addPM.INTF_CalculatePMPlanDetails_SCON(reqTgtRec);
        addPM.INTF_CalculatePMPlanDetails_LOC(reqTgtRec);
        addPM.INTF_CalculatePMPlanDetails_IPRD(reqTgtRec);
        
        PREV_SFMEventUtils.INTF_ActivatePMPlan_PREV_WS2(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_SCON_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_ACCT_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_LOC_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_IPRD_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_ActivatePMPlan_PREV_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CancelPMPlan_WS(reqTgtRec);
    }
    static testMethod void PREV_SFMEventUtilsUnitTest2()
    {
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqTgtRec = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objPMHeaFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> lstPMDetailsFromReq = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstPMHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objPMScheduleDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        
        //Data Creation for the different Sceneries for the generating PM Plans
        Account acc = new Account();
        acc.Name = 'ServiceMax';
        insert acc;
        
        SVMXC__Service_Contract__c SC = new SVMXC__Service_Contract__c();
        insert SC;
        
        Product2 prod = new Product2();
        prod.Name = 'SVMX Enterprise';
        insert prod;
        
        SVMXC__Installed_Product__c IB = new SVMXC__Installed_Product__c();
        IB.Name = 'SVMX Enterprise 00001';
        IB.SVMXC__Product__c = prod.Id;
        IB.SVMXC__Company__c = acc.Id;
        insert IB;
        
        SVMXC__Service_Contract_Products__c CP = new SVMXC__Service_Contract_Products__c();
        CP.SVMXC__Installed_Product__c = IB.Id;
        CP.SVMXC__Service_Contract__c = SC.Id;
        insert CP;
         
        SVMXC__PM_Plan_Template__c PMCat = new SVMXC__PM_Plan_Template__c();
        insert PMCat;
        
        SVMXC__PM_Applicable_Product__c applcblProd = new SVMXC__PM_Applicable_Product__c();
        applcblProd.SVMXC__PM_Plan_Template__c = PMCat.Id;
        applcblProd.SVMXC__Product__c = prod.Id;
        insert applcblProd;
      
        date startDate = system.today();
        date endDate = system.today().addYears(2);
        
        //Creations of Key Values for the Header to be passed as parameter to the Methods of the AddPM Class
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Account__c', acc.Id));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__PM_Plan_Template__c', PMCat.Id));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Start_Date__c', string.valueOf(startDate)));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__End_Date__c', string.valueOf(endDate)));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Service_Maintenance_Contract__c', SC.Id));
        lstPMHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Coverage_Type__c', 'LOCATION (MUST HAVE LOCATION)'));
        
        SVMXC.INTF_WebServicesDef.INTF_Record tempRec = new SVMXC.INTF_WebServicesDef.INTF_Record();
        tempRec.targetRecordAsKeyValue = lstPMHeaAsKeyValue;
        objPMScheduleDetRec.add(tempRec);
        objPMHeaFromReq.records = objPMScheduleDetRec;
        
        objPMHeaFromReq.objName = 'SVMXC__PM_Plan__c';
        
        //Creations of Key Values for the Details to be passed as parameter to the Methods of the AddPM Class
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringMap strMap = new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Product__c', IB.Id);
        lstKeyValue.add(strMap);
        SVMXC.INTF_WebServicesDef.INTF_Record tempRec1 = new SVMXC.INTF_WebServicesDef.INTF_Record();
        tempRec1.targetRecordAsKeyValue = lstKeyValue;
        objDetRec.add(tempRec1);
        
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject dtlRec1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        dtlRec1.objName = 'SVMXC__PM_Schedule__c';
        lstPMDetailsFromReq.add(dtlRec1);
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject dtlRec2 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        dtlRec2.objName = 'SVMXC__PM_Coverage_Advanced__c';
        dtlRec2.records = objDetRec;
        lstPMDetailsFromReq.add(dtlRec2);
        
        reqTgtRec.headerRecord = objPMHeaFromReq;
        reqTgtRec.detailRecords = lstPMDetailsFromReq;
        
        //Creation of the Object of the Class and calling all the Methods of the AddPM Class
        PREV_SFMEventUtils addPM = new PREV_SFMEventUtils();
        addPM.INTF_CalculatePMPlanDetails_ACCT(reqTgtRec);
        addPM.INTF_CalculatePMPlanDetails_SCON(reqTgtRec);
        addPM.INTF_CalculatePMPlanDetails_LOC(reqTgtRec);
        addPM.INTF_CalculatePMPlanDetails_IPRD(reqTgtRec);
        
        PREV_SFMEventUtils.INTF_ActivatePMPlan_PREV_WS2(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_SCON_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_ACCT_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_LOC_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CalculatePMPlanDetails_IPRD_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_ActivatePMPlan_PREV_WS(reqTgtRec);
        PREV_SFMEventUtils.INTF_CancelPMPlan_WS(reqTgtRec);
    }
}