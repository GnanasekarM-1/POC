@isTest(SeeAllData = true)
private class SCON_SFMEventUtils_UT 
{
    static SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqTgtRec1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
    static testMethod void SCON_SFMEventUtils_Test1()
    {
        /* Create temporary data */
        Account objAccount = new Account();
        objAccount.Name = 'Account-01';
        insert objAccount;
        
        date startDate = date.today().addDays(-365);
        date endDate = date.today();
        
        SVMXC__Service_Contract__c objSCON;
        objSCON = new SVMXC__Service_Contract__c();                                         
        objSCON.Name='SCON-0001';
        objSCON.SVMXC__Company__c = objAccount.Id;
        objSCON.SVMXC__Activation_Notes__c = 'Its with Unit Test Case';
        objSCON.SVMXC__Start_Date__c = startDate;
        objSCON.SVMXC__End_Date__c = endDate;
        objSCON.SVMXC__Active__c = true;
        insert objSCON;
        
        SVMXC__Service_Contract__c objSCON1 = new SVMXC__Service_Contract__c();                                         
        objSCON1.Name='SCON-0001';
        objSCON1.SVMXC__Company__c = objAccount.Id;
        objSCON1.SVMXC__Activation_Notes__c = 'Its with Unit Test Case';
        objSCON1.SVMXC__Start_Date__c = startDate;
        objSCON1.SVMXC__End_Date__c = endDate;
        objSCON1.SVMXC__Active__c = true;
        objSCON1.SVMXC__Renewed_From__c = objSCON.Id;
        insert objSCON1;
        
        
        SVMXC__PM_Plan_Template__c PMCat = new SVMXC__PM_Plan_Template__c();
        insert PMCat;
        
        SVMXC__PM_Offering__c objPMOffer1 = new SVMXC__PM_Offering__c();
        objPMOffer1.SVMXC__Service_Contract__c = objSCON1.Id;
        objPMOffer1.SVMXC__PM_Plan_Template__c = PMCat.Id;
        insert objPMOffer1;
        
        
        prepareData(objSCON);
        SCON_SFMEventUtils objSCONUtil = new SCON_SFMEventUtils();
        SVMXC.INTF_WebServicesDef.INTF_PageData objPageDataResp1 = objSCONUtil.activateContract(reqTgtRec1);
        SVMXC.INTF_WebServicesDef.INTF_PageData objPageDataResp2 = objSCONUtil.renewContract(reqTgtRec1);
        SVMXC.INTF_WebServicesDef.INTF_PageData objPageDataResp3 = objSCONUtil.cancelContract(reqTgtRec1);
    }
    
    static testMethod void SCON_SFMEventUtils_Test2()
    {
        /* Create temporary data */
        Account objAccount = new Account();
        objAccount.Name = 'Account-01';
        insert objAccount;
        
        date startDate = date.today();
        date endDate = date.today().addDays(10);
        
        SVMXC__Service_Contract__c objSCON = new SVMXC__Service_Contract__c();                                         
        objSCON.Name='TestServiceContract';
        objSCON.SVMXC__Company__c = objAccount.Id;
        objSCON.SVMXC__Activation_Notes__c = 'Its with Unit Test Case';
        objSCON.SVMXC__Start_Date__c = startDate;
        objSCON.SVMXC__End_Date__c = endDate;
        insert objSCON;
        
        SVMXC__Service_Contract__c objSCON1 = new SVMXC__Service_Contract__c();                                         
        objSCON1.Name=null;
        objSCON1.SVMXC__Company__c = objAccount.Id;
        objSCON1.SVMXC__Activation_Notes__c = 'Its with Unit Test Case';
        objSCON1.SVMXC__Start_Date__c = startDate;
        objSCON1.SVMXC__Active__c = true;
        objSCON1.SVMXC__End_Date__c = endDate;
        objSCON1.SVMXC__Renewed_From__c  = objSCON.Id;
        insert objSCON1;
        
        prepareData(new SVMXC__Service_Contract__c(Name = null));
        SCON_SFMEventUtils objSCONUtil = new SCON_SFMEventUtils();
        objSCONUtil.activateContract(reqTgtRec1);
        objSCONUtil.renewContract(reqTgtRec1);
        objSCONUtil.cancelContract(reqTgtRec1);
        
        prepareData(new SVMXC__Service_Contract__c(Name='TestServiceContract', SVMXC__Start_Date__c = null));
        objSCONUtil.renewContract(reqTgtRec1);
        objSCONUtil.cancelContract(reqTgtRec1);
        
        prepareData(new SVMXC__Service_Contract__c(Name='TestServiceContract', SVMXC__Start_Date__c = startDate,SVMXC__End_Date__c=null ));
        objSCONUtil.renewContract(reqTgtRec1);
        objSCONUtil.cancelContract(reqTgtRec1);
        SCON_SFMEventUtils.getTAG004();
        SCON_SFMEventUtils.getTAG007();
        SCON_SFMEventUtils.getTAG009();
        SCON_SFMEventUtils.emailStatusInfo('Test Message notification', 'a@b.com');
    }
    
    static void prepareData(sObject sObj)
    {
        
        Account objAccount = new Account();
        objAccount.Name = 'Account-01';
        insert objAccount;
        
        date startDate = date.today().addDays(-365);
        date endDate = date.today();
        
        SVMXC__Service_Contract__c objSCON1 = new SVMXC__Service_Contract__c();                                         
        objSCON1.Name='SCON-0001';
        objSCON1.SVMXC__Company__c = objAccount.Id;
        objSCON1.SVMXC__Activation_Notes__c = 'Its with Unit Test Case';
        objSCON1.SVMXC__Start_Date__c = startDate;
        objSCON1.SVMXC__End_Date__c = endDate;
        objSCON1.SVMXC__Active__c = false;
        insert objSCON1;
        
        
        List<SVMXC__PM_Plan__c> lstPMPlan = new List<SVMXC__PM_Plan__c>();
        lstPMPlan.add(new SVMXC__PM_Plan__c(Name = 'PM Plan 001', SVMXC__Account__c = objAccount.Id, SVMXC__Service_Contract__c = objSCON1.Id, SVMXC__Start_Date__c = date.today(), SVMXC__End_Date__c = date.today().addDays(365), SVMXC__Status__c = 'Active'));
        lstPMPlan.add(new SVMXC__PM_Plan__c(Name = 'PM Plan 001', SVMXC__Account__c = objAccount.Id, SVMXC__Service_Contract__c = objSCON1.Id, SVMXC__Start_Date__c = date.today(), SVMXC__End_Date__c = date.today().addDays(365), SVMXC__Status__c = 'Active'));
        lstPMPlan.add(new SVMXC__PM_Plan__c(Name = 'PM Plan 001', SVMXC__Account__c = objAccount.Id, SVMXC__Service_Contract__c = objSCON1.Id, SVMXC__Start_Date__c = date.today(), SVMXC__End_Date__c = date.today().addDays(365), SVMXC__Status__c = 'Active'));
        insert lstPMPlan;
        
        SVMXC__Service_Contract__c objSCON2 = new SVMXC__Service_Contract__c();                                         
        objSCON2.Name='SCON-0002';
        objSCON2.SVMXC__Company__c = objAccount.Id;
        objSCON2.SVMXC__Activation_Notes__c = 'Its with Unit Test Case';
        objSCON2.SVMXC__Start_Date__c = startDate;
        objSCON2.SVMXC__End_Date__c = endDate;
        objSCON2.SVMXC__Active__c = false;
        insert objSCON2;
        
        SVMXC__PM_Plan_Template__c PMCat = new SVMXC__PM_Plan_Template__c();
        insert PMCat;
        
        List<SVMXC__PM_Offering__c> objPMOfferLst = new List<SVMXC__PM_Offering__c>();
        for(Integer i=0; i<20; i++)
        {
            SVMXC__PM_Offering__c objPMOffer1 = new SVMXC__PM_Offering__c();
            objPMOffer1.SVMXC__Service_Contract__c = objSCON1.Id;
            objPMOffer1.SVMXC__PM_Plan_Template__c = PMCat.Id;
            objPMOfferLst.add(objPMOffer1);
        }
        insert objPMOfferLst;
        
        
        reqTgtRec1 = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objSCONFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> lstPMDetailsFromReq = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstSCONHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objSCONRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        
        string dtStartDate = string.valueOf(sObj.get('SVMXC__Start_Date__c'));
        string dtEndDate = string.valueOf(sObj.get('SVMXC__End_Date__c'));
        //Creations of Key Values for the Header to be passed as parameter to the Methods of the AddPM Class
        lstSCONHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('Name', sObj.Id));
        lstSCONHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Start_Date__c', dtStartDate));
        lstSCONHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__End_Date__c', dtEndDate));
        lstSCONHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Renewal_Notes__c', 'Renewal Done'));
        lstSCONHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('SVMXC__Activation_Notes__c','Activation done'));
        lstSCONHeaAsKeyValue.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('Id', sObj.Id));
        
        SVMXC.INTF_WebServicesDef.INTF_Record tempRec1 = new SVMXC.INTF_WebServicesDef.INTF_Record();
        tempRec1.targetRecordAsKeyValue = lstSCONHeaAsKeyValue;
        tempRec1.targetRecordId = string.valueOf(objSCON1.get('Id'));
        tempRec1.sourceRecordId = string.valueOf(objSCON1.get('Id'));
        
        SVMXC.INTF_WebServicesDef.INTF_Record tempRec2 = new SVMXC.INTF_WebServicesDef.INTF_Record();
        tempRec2.targetRecordAsKeyValue = lstSCONHeaAsKeyValue;
        tempRec2.targetRecordId = string.valueOf(objSCON2.get('Id'));
        tempRec2.sourceRecordId = string.valueOf(objSCON2.get('Id'));
         
        objSCONRec.add(tempRec1);
        objSCONRec.add(tempRec2);
        objSCONFromReq.records = objSCONRec;
        objSCONFromReq.objName = 'SVMXC__Service_Contract__c';
        reqTgtRec1.headerRecord = objSCONFromReq;
    }
    
}