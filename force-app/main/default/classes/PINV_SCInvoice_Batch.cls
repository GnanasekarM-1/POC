global with sharing class PINV_SCInvoice_Batch implements Database.Batchable<sObject>, Database.Stateful
{
    global set<string> setProIds = new set<string>();
         
    global Iterable<sObject> start(Database.BatchableContext bcSCBillingEngine)
    {
        try
        {
            List<SVMXC__ServiceMax_Processes__c> lstSCBilEngProc = new List<SVMXC__ServiceMax_Processes__c>();
            lstSCBilEngProc = [select id, SVMXC__Name__c, SVMXC__ProcessID__c, SVMXC__Description__c, SVMXC__Module__c, SVMXC__Node_Parent__c, SVMXC__Process__c, SVMXC__Final_Exception_Process__c, SVMXC__Primary_Consolidation_Rule__c, SVMXC__Secondary_Consolidation_Rule__c, SVMXC__Tertiary_Consolidation_Rule__c, SVMXC__Include_Product__c, SVMXC__Include_Parent__c, SVMXC__Email_On_Success__c, SVMXC__Email_On_Error__c, SVMXC__Capture_Log__c from SVMXC__ServiceMax_Processes__c where id IN: setProIds and RecordType.Name = 'Contract Billing Process'];
            return lstSCBilEngProc;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
     
    global void execute(Database.BatchableContext bcSCBillingEngine, List<sObject> scope)
    {
        List<SVMXC.INTF_WebservicesDef.INTF_Response> lstResponses = new List<SVMXC.INTF_WebservicesDef.INTF_Response>();
        
        for(sObject s : scope)
        {
            SVMXC__ServiceMax_Processes__c pro = (SVMXC__ServiceMax_Processes__c)s;
        
            SVMXC.INTF_WebservicesDef.INTF_Request req = new SVMXC.INTF_WebservicesDef.INTF_Request();
            List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringListMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
            
            List<SVMXC.INTF_WebservicesDef.INTF_StringMap> lstStringMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringMap>();
            SVMXC.INTF_WebservicesDef.INTF_StringMap strMap = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
            strMap.key = 'ProcId';
            strMap.value = pro.SVMXC__ProcessID__c;
            lstStringMapReq.add(strMap);
            
            SVMXC.INTF_WebservicesDef.INTF_StringMap strMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringMap();
            strMap1.key = 'StepDetails';
            strMap1.value = 'All';
            lstStringMapReq.add(strMap1);
            
            req.stringListMap = lstStringListMapReq;
            req.stringMap = lstStringMapReq;
            
            SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
            PINV_SCInvoiceUtils scInvoiceUtil = new PINV_SCInvoiceUtils();
            res = scInvoiceUtil.PINV_GenerateSCInvoiceDocs(req);
            lstResponses.add(res);
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
    
    }
}