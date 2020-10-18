/* Class to get all the view layouts for the Webservice*/
public with sharing class INTF_Get_ServiceFlowList 
{
    Map<String, Schema.SObjectType> allObjs = new Map<String, Schema.SObjectType>();
    SVMXC.SFM_Utils utils = new SVMXC.SFM_Utils();
    SVMXC.INTF_GetServiceFlowAccess access = new SVMXC.INTF_GetServiceFlowAccess();
    
    public INTF_WebServicesDef.INTF_Response_For_Get_View_Layouts INTF_Get_View_Layouts()
    {
        Map<Id, SVMXC__ServiceMax_Processes__c> lstAllViewLayouts = new Map<Id, SVMXC__ServiceMax_Processes__c>();
        Map<String, List<SVMXC__ServiceMax_Processes__c>> lstAllObjectDetailsViewLayouts = new Map<String, List<SVMXC__ServiceMax_Processes__c>>();
        List<SVMXC__ServiceMax_Processes__c> lstAllViewLayoutDetails;
        INTF_WebServicesDef.INTF_Response_For_Get_View_Layouts objRespForGetViewLay = new INTF_WebServicesDef.INTF_Response_For_Get_View_Layouts();
        try
        {
            set<Id> availableViews = new set<Id>();
            //lstAllViewLayouts.putAll([Select Id, SVMXC__ProcessID__c, SVMXC__IsDefault__c, SVMXC__Name__C, SVMXC__Description__c FROM SVMXC__ServiceMax_Processes__c Where Recordtype.Name='Target Manager' AND SVMXC__Purpose__c ='VIEW RECORD']);
            lstAllViewLayouts = access.getAllowedProcesses('VIEW RECORD');
            system.debug('TEST LOG 10: ' + lstAllViewLayouts);
            lstAllViewLayoutDetails = [Select Id, SVMXC__Source_Object_Name__c, SVMXC__Process__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c IN :lstAllViewLayouts.keySet() AND SVMXC__Type__c = 'TARGET'];   //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            for(SVMXC__ServiceMax_Processes__c targetDetails: lstAllViewLayoutDetails)
            {
                List<SVMXC__ServiceMax_Processes__c> lstTargetObjectDetails = new List<SVMXC__ServiceMax_Processes__c>();
                // Add existing data if exist
                if(lstAllObjectDetailsViewLayouts.get(targetDetails.SVMXC__Source_Object_Name__c) != NULL)
                    lstTargetObjectDetails = lstAllObjectDetailsViewLayouts.get(targetDetails.SVMXC__Source_Object_Name__c);
                
                lstTargetObjectDetails.add(lstAllViewLayouts.get(targetDetails.SVMXC__Process__c));
                lstAllObjectDetailsViewLayouts.put(targetDetails.SVMXC__Source_Object_Name__c, lstTargetObjectDetails);
            }
            
            List<INTF_WebServicesDef.INTF_Response_For_Get_Object_Layouts> lstObjDetails = new List<INTF_WebServicesDef.INTF_Response_For_Get_Object_Layouts>();
            for(String strObjectName: lstAllObjectDetailsViewLayouts.keySet())
            {
                lstObjDetails.add(new INTF_WebServicesDef.INTF_Response_For_Get_Object_Layouts(strObjectName, lstAllObjectDetailsViewLayouts.get(strObjectName)));
            }
            objRespForGetViewLay.layoutsInfo = lstObjDetails;
            return objRespForGetViewLay;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
    
    public INTF_WebServicesDef.INTF_Response_For_Get_StandaloneCreate_Layouts INTF_Get_StandaloneCreate_Layouts()
    {
        List<SVMXC__ServiceMax_Processes__c> lstAllStandaloneCreateLayouts = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Processes__c> lstAllViewLayoutDetails;
        INTF_WebServicesDef.INTF_Response_For_Get_StandaloneCreate_Layouts objRespForGetStandaloneCreate = new INTF_WebServicesDef.INTF_Response_For_Get_StandaloneCreate_Layouts();
        try
        {
            Map<Id, SVMXC__ServiceMax_Processes__c> allowedProcess = new Map<Id, SVMXC__ServiceMax_Processes__c>();
            allowedProcess = access.getAllowedProcesses('STANDALONE CREATE');
            
            lstAllViewLayoutDetails = [Select Id, SVMXC__Source_Object_Name__c, SVMXC__Process__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c IN :allowedProcess.keySet() AND SVMXC__Type__c = 'TARGET'];    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            for(SVMXC__ServiceMax_Processes__c targetDetails: lstAllViewLayoutDetails)
            {
                SVMXC__ServiceMax_Processes__c procesData = new SVMXC__ServiceMax_Processes__c();
                if(targetDetails.SVMXC__Process__c != NULL)
                {
                    procesData = allowedProcess.get(targetDetails.SVMXC__Process__c);
                    procesData.SVMXC__Source_Object_Name__c = targetDetails.SVMXC__Source_Object_Name__c;
                    lstAllStandaloneCreateLayouts.add(procesData);
                }
            }
            
            objRespForGetStandaloneCreate.layoutsInfo = lstAllStandaloneCreateLayouts;
            return objRespForGetStandaloneCreate;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
}