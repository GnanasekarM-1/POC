@isTest(seeAllData = true)
private class PINV_Utils_UT 
{
    static testMethod void PINV_UtilsUnitTest()
    {
        PINV_Utils pinvUtil = new PINV_Utils();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecord request = new SVMXC.INTF_WebServicesDef.INTF_TargetRecord();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject wrpHdrTrgtRecObj = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> lstWrpObjHdrRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstWrpObjHdrTrgtRecAsKeyVal = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        
        SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
        WO.SVMXC__Invoice_Created__c = true;
        insert WO;
        
        SVMXC__Proforma_Invoice__c PINV = new SVMXC__Proforma_Invoice__c();
        PINV.SVMXC__Status__c = 'Open';
        insert PINV;
        
        SVMXC__Proforma_Invoice_Detail__c PINVDtl = new SVMXC__Proforma_Invoice_Detail__c();
        PINVDtl.SVMXC__Work_Order__c = WO.Id;
        PINVDtl.SVMXC__Proforma_Invoice__c = PINV.Id;
        insert PINVDtl;
        
        WO.SVMXC__Invoice_Number__c = PINV.Name;
        WO.SVMXC__Proforma_Invoice__c = PINV.Id;
        update WO;
        
        SVMXC.INTF_WebServicesDef.INTF_Record rec = new SVMXC.INTF_WebServicesDef.INTF_Record();
        rec.targetRecordId = PINV.Id;
        rec.targetRecordAsKeyValue = lstWrpObjHdrTrgtRecAsKeyVal;
        lstWrpObjHdrRec.add(rec);
        
        System.assert(lstWrpObjHdrRec[0].targetRecordId == PINV.Id);
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMap = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_StringMap obje = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        obje.key = 'SVMX_recordId';
        obje.value = WO.Id;
        lstStringMap.add(obje);
        
        SVMXC.INTF_WebServicesDef.INTF_StringMap obje2 = new SVMXC.INTF_WebServicesDef.INTF_StringMap();
        obje2.key = 'SVMX_NxtStepID';
        obje2.value = WO.Id;
        lstStringMap.add(obje2);
        
        wrpHdrTrgtRecObj.objName = 'SVMXC__Service_Order__c';
        wrpHdrTrgtRecObj.records = lstWrpObjHdrRec;
        request.headerRecord = wrpHdrTrgtRecObj;
        request.stringMap = lstStringMap;
        pinvUtil.PINV_CancelInvoice(request);
    }
}