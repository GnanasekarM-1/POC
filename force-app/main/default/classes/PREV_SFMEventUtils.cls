global with sharing class PREV_SFMEventUtils 
{
    //================================================These webservices are in use============================================================
    //Creating PM Plans from Service Contract
    webservice static SVMXC.INTF_WebServicesDef.INTF_PageData INTF_ActivatePMPlan_PREV_WS2(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.PREV_SFMEventUtils()).INTF_ActivatePMPlan_PREV(request);
    }
    
    //Creating PM Plans from Account
    webservice static SVMXC.INTF_WebServicesDef.INTF_PageData INTF_CalculatePMPlanDetails_ACCT_WS2(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.PREV_SFMEventUtils()).INTF_CalculatePMPlanDetails_ACCT(request);
    }
    
     //Creating PM Plans from Service Contract
    webservice static SVMXC.INTF_WebServicesDef.INTF_PageData INTF_CalculatePMPlanDetails_SCON_WS2(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.PREV_SFMEventUtils()).INTF_CalculatePMPlanDetails_SCON(request);
    }
    
    //Neeraj(10-Sep-2012): Webservice Method for PM Plan Cancellation.
    webservice static SVMXC.INTF_WebServicesDef.INTF_PageData INTF_CancelPMPlan_WS(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.PREV_PMPlanUtils()).PREV_CancelPMPlan(request);
    }
    
    //Creating PM Plans from Installed Product
    webservice static SVMXC.INTF_WebServicesDef.INTF_PageData INTF_CalculatePMPlanDetails_IPRD_WS2(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.PREV_SFMEventUtils()).INTF_CalculatePMPlanDetails_IPRD(request);
    }
    
    //Creating PM Plans from Location
    webservice static SVMXC.INTF_WebServicesDef.INTF_PageData INTF_CalculatePMPlanDetails_LOC_WS2(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.PREV_SFMEventUtils()).INTF_CalculatePMPlanDetails_LOC(request);
    }
    
    //===============================================================================================================================================
    
    //---------------------------------------------These Webservices are no more in use--------------------------------------------------------------
    webservice static SVMXC.INTF_WebServicesDef.INTF_Response INTF_CalculatePMPlanDetails_SCON_WS(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }
    
    webservice static SVMXC.INTF_WebServicesDef.INTF_Response INTF_ActivatePMPlan_PREV_WS(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }
    
    webservice static SVMXC.INTF_WebServicesDef.INTF_Response INTF_CalculatePMPlanDetails_ACCT_WS(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }
    
    webservice static SVMXC.INTF_WebServicesDef.INTF_Response INTF_CalculatePMPlanDetails_IPRD_WS(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }
    
    webservice static SVMXC.INTF_WebServicesDef.INTF_Response INTF_CalculatePMPlanDetails_LOC_WS(SVMXC.INTF_WebServicesDef.INTF_TargetRecord request)
    {
        return (new SVMXC.INTF_WebServicesDef.INTF_Response());
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------
    
    public SVMXC.INTF_WebServicesDef.INTF_PageData INTF_ActivatePMPlan_PREV(SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqTgtRec)
    {
        SVMXC.INTF_BuildSobjectFromKeyValue clsBuildSobjfromKeyValue = new SVMXC.INTF_BuildSobjectFromKeyValue();
        list<SVMXC__PM_Plan__c> lstPMPlans = new list<SVMXC__PM_Plan__c>();
        string strPMPlanId = '';
        string strPMPlanName = '';
        string strHeaderObjName = '';
        SVMXC.INTF_WebServicesDef.INTF_PageData wrpObjPageDataResp = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_WebServicesDef.INTF_Response res = new SVMXC.INTF_WebServicesDef.INTF_Response();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objPMHeaFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objPMScheduleDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstPMHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMapReq = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        lstStringMapReq =  reqTgtRec.stringMap;
        Boolean isNextStepURL = false;
        String strNextStepURL = '';
        
        if(lstStringMapReq != null && lstStringMapReq.size() > 0){
            String strRecordId = '';
            String strNextStepId = '';
            for(Integer i =0;i<lstStringMapReq.size();i++){
                if(lstStringMapReq[i].key.equals('SVMX_recordId') && lstStringMapReq[i].value != null)
                    strRecordId = lstStringMapReq[i].value;
                else if(lstStringMapReq[i].key.equals('SVMX_NxtStepID') && lstStringMapReq[i].value != null){
                    strNextStepId = lstStringMapReq[i].value;
                }   
            }
            if(strRecordId != '' && strNextStepId != ''){
                SVMXC.ServiceFlowWizard_Utils sfwUtils = new SVMXC.ServiceFlowWizard_Utils();
                strNextStepURL = sfwUtils.SVMX_GetNextStepURL(strRecordId,strNextStepId);
                if(strNextStepURL != '' )
                    isNextStepURL = true;
            }
        }
        
        res.success = true;
        
        //Extracting the Request
        objPMHeaFromReq = reqTgtRec.getheaderRecord();
        objPMScheduleDetRec = objPMHeaFromReq.records;
        //lstPMDetailsFromReq = reqTgtRec.detailRecords;
        
        if(objPMHeaFromReq.objName != null && objPMHeaFromReq.objName.length() > 0)
            strHeaderObjName = objPMHeaFromReq.objName;
            
        if(objPMScheduleDetRec != null && objPMScheduleDetRec.size() > 0)
            lstPMHeaAsKeyValue = objPMScheduleDetRec[0].targetRecordAsKeyValue;
        
        try
        {
            Map<String,Sobject> mapAction_PREV =  clsBuildSobjfromKeyValue.BuildSobjectFromKeyValue(lstPMHeaAsKeyValue,strHeaderObjName,null,null);
            lstPMPlans = mapAction_PREV.values();
            //lstPMPlans = [select SVMXC__PM_Plan_Template__c, SVMXC__Service_Contract__c, SVMXC__Status__c, SVMXC__Account__c, SVMXC__Location__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Coverage_Type__c from SVMXC__PM_Plan__c where id =: strPMPlanId OR Name =: strPMPlanName];
            system.debug(loggingLevel.WARN, 'List of PM Plans from the Process: ' + lstPMPlans);
            
            if(lstPMPlans != null && lstPMPlans.size() > 0)
            {
                List<SVMXC__PM_Plan__c> lstLocationPMPlan = new List<SVMXC__PM_Plan__c>();
                List<SVMXC__PM_Plan__c> lstAccountPMPlan = new List<SVMXC__PM_Plan__c>();
                List<SVMXC__PM_Plan__c> lstProductPMPlan = new List<SVMXC__PM_Plan__c>();
                
                for(SVMXC__PM_Plan__c objPMPlan : lstPMPlans)
                {
                    if(objPMPlan.SVMXC__Coverage_Type__c != null && objPMPlan.SVMXC__Coverage_Type__c.toUpperCase() == 'LOCATION (MUST HAVE LOCATION)')
                        lstLocationPMPlan.add(objPMPlan);
                    else if(objPMPlan.SVMXC__Coverage_Type__c != null && objPMPlan.SVMXC__Coverage_Type__c.toUpperCase() == 'ACCOUNT (VISIT ONLY)')
                        lstAccountPMPlan.add(objPMPlan);
                    else if(objPMPlan.SVMXC__Coverage_Type__c != null && objPMPlan.SVMXC__Coverage_Type__c.toUpperCase() == 'PRODUCT (MUST HAVE IB)')
                        lstProductPMPlan.add(objPMPlan);
                    else
                        lstProductPMPlan.add(objPMPlan);
                }
                lstPMPlans.clear();
                system.debug(loggingLevel.WARN, 'lstProductPMPlan: ' + lstProductPMPlan);
                system.debug(loggingLevel.WARN, 'lstLocationPMPlan: ' + lstLocationPMPlan);
                system.debug(loggingLevel.WARN, 'lstAccountPMPlan: ' + lstAccountPMPlan);
                
                if(lstProductPMPlan != null && lstProductPMPlan.size() > 0)
                {
                    lstProductPMPlan = (new PREV_PMPlanUtils()).setPMPlanStatus(true, lstProductPMPlan, 'Product (Must Have IB)');
                    lstPMPlans.addAll(lstProductPMPlan);
                }
                if(lstLocationPMPlan != null && lstLocationPMPlan.size() > 0)
                {
                    lstLocationPMPlan = (new PREV_PMPlanUtils()).setPMPlanStatus(true, lstLocationPMPlan, 'Location (Must Have Location)');
                    lstPMPlans.addAll(lstLocationPMPlan);
                }
                if(lstAccountPMPlan != null && lstAccountPMPlan.size() > 0)
                {
                    lstLocationPMPlan = (new PREV_PMPlanUtils()).setPMPlanStatus(true, lstAccountPMPlan, '');
                    lstPMPlans.addAll(lstAccountPMPlan);
                }
                
                system.debug(loggingLevel.WARN, 'List of PM Plans before DML: ' + lstPMPlans);
                if(lstPMPlans != null && lstPMPlans.size() > 0){
                    //update lstPMPlans;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstPMPlans, COMM_SecurityUtils.Access.Updateable)){
					    update lstPMPlans; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
					} else {
					    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
					}
                }
            }
        }
        catch(exception ex)
        {
            system.debug('ERROR'+ex.getMessage());
            res.success = false;
            res.messageType = 'SVMX_ERROR';
            res.message = ex.getmessage();
            wrpObjPageDataResp.response = res;
            return wrpObjPageDataResp;
        }
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        if(isNextStepURL){
            stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO',strNextStepURL));
        }
        else{
            if(lstPMPlans != null && lstPMPlans.size() > 0){
                stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO',lstPMPlans[0].Id));
            }   
       }
       res.stringMap = stringMap;
        
        system.debug(loggingLevel.WARN, 'Response generated is: ' + res);
        res.message = system.label.COMM001_TAG058;
        
        if(lstPMPlans[0].SVMXC__Status__c == 'Incomplete')
        {
            res.messageType = 'SVMX_INFO';
            res.message = system.label.PREV002_TAG102;//'This PM Plan has been set to Incomplete because it does not contain apllicable products';
        }
        
        wrpObjPageDataResp.response = res;
        return wrpObjPageDataResp;
    }   
    
    //Method for generating PM Plans for the Account
    public SVMXC.INTF_WebServicesDef.INTF_PageData INTF_CalculatePMPlanDetails_ACCT(SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqTgtRec)
    {
        system.debug('Target Record request: ' + reqTgtRec);
        SVMXC.INTF_WebServicesDef.INTF_PageData pageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_WebServicesDef.INTF_Response res = new SVMXC.INTF_WebServicesDef.INTF_Response();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objPMHeaFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objPMScheduleDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstPMHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringLstMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        SVMXC.INTF_WebServicesDef.INTF_Request objReqForPMPlanCalc = new SVMXC.INTF_WebServicesDef.INTF_Request();
        
        //Extracting the Request
        objPMHeaFromReq = reqTgtRec.getheaderRecord();
        objPMScheduleDetRec = objPMHeaFromReq.records;
        
        if(objPMScheduleDetRec != null && objPMScheduleDetRec.size() > 0)
            lstPMHeaAsKeyValue = objPMScheduleDetRec[0].targetRecordAsKeyValue;
        
        lstStringLstMapReq = addDtlStrLstMap('Account', lstPMHeaAsKeyValue);
        
        objReqForPMPlanCalc.stringListMap = lstStringLstMapReq;
        system.debug('Request for SCON PM Utils: : ' + objReqForPMPlanCalc);
        
        //Generating the PM Plans using the PREV_PMPlanUtils Utility Class
        res = (new PREV_PMPlanUtils()).PREV_CalculatePMPlanDetails(objReqForPMPlanCalc);
        system.debug('Response from SCON PM Utils: : ' + res);
        
        pageData.response = res;
        return pageData;
    }
    
    //Method for generating PM Plans for the Account
    public SVMXC.INTF_WebServicesDef.INTF_PageData INTF_CalculatePMPlanDetails_LOC(SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqTgtRec)
    {
        SVMXC.INTF_WebServicesDef.INTF_PageData pageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_WebServicesDef.INTF_Response res = new SVMXC.INTF_WebServicesDef.INTF_Response();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objPMHeaFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objPMScheduleDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstPMHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringLstMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        SVMXC.INTF_WebServicesDef.INTF_Request objReqForPMPlanCalc = new SVMXC.INTF_WebServicesDef.INTF_Request();
        
        //Extracting the Request
        objPMHeaFromReq = reqTgtRec.getheaderRecord();
        objPMScheduleDetRec = objPMHeaFromReq.records;
        
        if(objPMScheduleDetRec != null && objPMScheduleDetRec.size() > 0)
            lstPMHeaAsKeyValue = objPMScheduleDetRec[0].targetRecordAsKeyValue;
           
        lstStringLstMapReq = addDtlStrLstMap('Location', lstPMHeaAsKeyValue);
        
        objReqForPMPlanCalc.stringListMap = lstStringLstMapReq;
        system.debug('Request for SCON PM Utils: : ' + objReqForPMPlanCalc);
        
        //Generating the PM Plans using the PREV_PMPlanUtils Utility Class
        res = (new PREV_PMPlanUtils()).PREV_CalculatePMPlanDetails(objReqForPMPlanCalc);
        system.debug('Response from SCON PM Utils: : ' + res);
        
        pageData.response = res;
        return pageData;
    }
    
    //Method for generating PM Plans for the Account
    public SVMXC.INTF_WebServicesDef.INTF_PageData INTF_CalculatePMPlanDetails_IPRD(SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqTgtRec)
    {
        SVMXC.INTF_WebServicesDef.INTF_PageData pageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_WebServicesDef.INTF_Response res = new SVMXC.INTF_WebServicesDef.INTF_Response();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objPMHeaFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objPMScheduleDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        //List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject> lstPMDetailsFromReq = new List<SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject>();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringLstMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstPMHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_Request objReqForPMPlanCalc = new SVMXC.INTF_WebServicesDef.INTF_Request();
        
        //Extracting the Request
        objPMHeaFromReq = reqTgtRec.getheaderRecord();
        objPMScheduleDetRec = objPMHeaFromReq.records;
        //lstPMDetailsFromReq = reqTgtRec.detailRecords;
        
        if(objPMScheduleDetRec != null && objPMScheduleDetRec.size() > 0)
            lstPMHeaAsKeyValue = objPMScheduleDetRec[0].targetRecordAsKeyValue;
        
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add('IB');
        lstStringLstMapReq.add(strLstMap);
        
        //Preparing the Key Value pair for the Request to the PM Plan generation Util Class
        for(SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap : lstPMHeaAsKeyValue)
        {
            SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
            if(tempStrMap.key == 'Id')
            {
                strLstMap1.key = 'PM Plan';
                strLstMap1.valueList.add(tempStrMap.value);
            }
            lstStringLstMapReq.add(strLstMap1);
        }
        
        objReqForPMPlanCalc.stringListMap = lstStringLstMapReq;
        system.debug('Request for SCON PM Utils: : ' + objReqForPMPlanCalc);
        
        //Generating the PM Plans using the PREV_PMPlanUtils Utility Class
        res = (new PREV_PMPlanUtils()).PREV_CalculatePMPlanDetails(objReqForPMPlanCalc);
        system.debug('Response from SCON PM Utils: : ' + res);
        
        pageData.response = res;
        return pageData;
    }
    
    //Method for generating PM Plans for the Account
    public SVMXC.INTF_WebServicesDef.INTF_PageData INTF_CalculatePMPlanDetails_SCON(SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqTgtRec)
    {
        SVMXC.INTF_WebServicesDef.INTF_PageData pageData = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        SVMXC.INTF_WebServicesDef.INTF_Response res = new SVMXC.INTF_WebServicesDef.INTF_Response();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objPMHeaFromReq = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> objPMScheduleDetRec = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstPMHeaAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringLstMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        SVMXC.INTF_WebServicesDef.INTF_Request objReqForPMPlanCalc = new SVMXC.INTF_WebServicesDef.INTF_Request();
        
        //Extracting the Request
        objPMHeaFromReq = reqTgtRec.getheaderRecord();
        objPMScheduleDetRec = objPMHeaFromReq.records;
        
        if(objPMScheduleDetRec != null && objPMScheduleDetRec.size() > 0)
            lstPMHeaAsKeyValue = objPMScheduleDetRec[0].targetRecordAsKeyValue;
        
        lstStringLstMapReq = addDtlStrLstMap('SC', lstPMHeaAsKeyValue);
        
        objReqForPMPlanCalc.stringListMap = lstStringLstMapReq;
        system.debug('Request for SCON PM Utils: : ' + objReqForPMPlanCalc);
        
        //Generating the PM Plans using the PREV_PMPlanUtils Utility Class
        res = (new PREV_PMPlanUtils()).PREV_CalculatePMPlanDetails(objReqForPMPlanCalc);
        system.debug('Response from SCON PM Utils: : ' + res);
        
        pageData.response = res;
        return pageData;
    }
    
    public List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> addDtlStrLstMap(string mode, List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstPMHeaAsKeyValue)
    {
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringLstMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        
        SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
        strLstMap.key = 'Mode';
        strLstMap.valueList.add(mode);
        lstStringLstMapReq.add(strLstMap);
        
        //Preparing the Key Value pair for the Request to the PM Plan generation Util Class
        for(SVMXC.INTF_WebServicesDef.INTF_StringMap tempStrMap : lstPMHeaAsKeyValue)
        {
            SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMap1 = new SVMXC.INTF_WebservicesDef.INTF_StringListMap();
            
            if(tempStrMap.key == 'Id')
            {
                strLstMap1.key = 'PM Plan';
                strLstMap1.valueList.add(tempStrMap.value);
            }
            
            lstStringLstMapReq.add(strLstMap1);
        }
        
        return lstStringLstMapReq;
    }
}