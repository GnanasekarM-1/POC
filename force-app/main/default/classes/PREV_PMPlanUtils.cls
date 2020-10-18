public with sharing class PREV_PMPlanUtils 
{
    public PREV_PMPlanUtils(){}
    
    //Method to Cancel PM Plan during the Service Contract Cancelation 
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse PREV_CancelPMForContract(SVMXC.INTF_WebServicesDef.INTF_SFMRequest objSFMRequest)
    {
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse objSFMResp = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        objSFMResp.success = true;
        try
        {
            string strSCONID = null;
            for(SVMXC.INTF_WebServicesDef.SVMXMap currentValMap : objSFMRequest.valueMap)
            {
                if(currentValMap.key == 'SCONID')
                    strSCONID = currentValMap.value;
            }
            if(strSCONID != null && strSCONID.length() > 0)
            {
                // Get the list of PM Plan, and set status to canceled to make it as an inactive
                list<SVMXC__PM_Plan__c> lstPMPlan = new list<SVMXC__PM_Plan__c>();
                lstPMPlan = [Select SVMXC__Status__c, SVMXC__Service_Contract__c, Name, Id From SVMXC__PM_Plan__c where SVMXC__Service_Contract__c =: strSCONID ];
                if(lstPMPlan != null && lstPMPlan.size() > 0)
                {
                    for(SVMXC__PM_Plan__c objPMPlan : lstPMPlan)
                        objPMPlan.SVMXC__Status__c = 'Canceled';
                    
                    //upsert lstPMPlan;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstPMPlan, COMM_SecurityUtils.Access.Upsertable)){
                        upsert lstPMPlan; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
            }
            return objSFMResp;
        }
        catch(exception ex)
        {
            system.debug(loggingLevel.WARN, 'ERROR'+ex.getMessage());
            objSFMResp.success = false;
            objSFMResp.messageType = 'ERROR';
            objSFMResp.message = ex.getmessage();
            return objSFMResp;
        }
    }
    
    
    // Method to Cancel PM Plan
    public SVMXC.INTF_WebServicesDef.INTF_PageData PREV_CancelPMPlan(SVMXC.INTF_WebServicesDef.INTF_TargetRecord reqPMPlan)
    {
        SVMXC.INTF_WebServicesDef.INTF_PageData objPageDataResp = new SVMXC.INTF_WebServicesDef.INTF_PageData();
        List<SVMXC.INTF_WebServicesDef.INTF_Record> lstwrapObjHeaderRecord = new List<SVMXC.INTF_WebServicesDef.INTF_Record>();
        List<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstHdrTargetRecordAsKeyValue = new List<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject objHdrTargetRecord = new SVMXC.INTF_WebServicesDef.INTF_TargetRecordObject();
        list<SVMXC__PM_Plan__c> lstPMPlan = new list<SVMXC__PM_Plan__c>();
        String strHeaderObjName, strPMPlanId;
        savepoint sp = Database.setSavepoint();
        objPageDataResp.response.success = true;
        
        list<SVMXC.INTF_WebServicesDef.INTF_StringMap> lstStringMapReq = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
        lstStringMapReq =  reqPMPlan.stringMap;
        Boolean isNextStepURL = false;
        String strNextStepURL = '';
        
        if(lstStringMapReq.size() > 0){
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
        
        try
        {
            if(reqPMPlan.headerRecord != null)
                objHdrTargetRecord = reqPMPlan.headerRecord;
            
            if(objHdrTargetRecord.objName != null && objHdrTargetRecord.objName.length() > 0)
                strHeaderObjName = objHdrTargetRecord.objName;
                
            if(objHdrTargetRecord.records != null && objHdrTargetRecord.records.size() > 0)
                lstwrapObjHeaderRecord = objHdrTargetRecord.records;
            
            if(lstwrapObjHeaderRecord != null && lstwrapObjHeaderRecord.size() > 0)
            {
                if(lstwrapObjHeaderRecord[0].targetRecordId != null && lstwrapObjHeaderRecord[0].targetRecordId.length() > 0)
                    strPMPlanId = lstwrapObjHeaderRecord[0].targetRecordId;
                if(lstwrapObjHeaderRecord[0].targetRecordAsKeyValue != null && lstwrapObjHeaderRecord[0].targetRecordAsKeyValue.size() > 0 && strHeaderObjName != null && strHeaderObjName.length() > 0)
                    lstHdrTargetRecordAsKeyValue = lstwrapObjHeaderRecord[0].targetRecordAsKeyValue;
            }
            
            map<String,Sobject> mapPMPlanObj = (new SVMXC.INTF_BuildSobjectFromKeyValue()).BuildSobjectFromKeyValue(lstHdrTargetRecordAsKeyValue, strHeaderObjName, null, null);
            
            if(mapPMPlanObj != null && mapPMPlanObj.size() == 1)
            {   
                //Cancel all the active PM Plan
                lstPMPlan = mapPMPlanObj.values();
                if(lstPMPlan != null && lstPMPlan.size() == 1)
                {
                    lstPMPlan[0].put('SVMXC__Status__c', 'Canceled');
                    lstPMPlan[0].put('SVMXC__Canceled_By__c', UserInfo.getUserId());
                    lstPMPlan[0].put('SVMXC__Canceled_On__c', System.now());
                }
                //update lstPMPlan;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstPMPlan, COMM_SecurityUtils.Access.Updateable)){
                    update lstPMPlan; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
                
            if(strPMPlanId != null && strPMPlanId.length() > 0)
            {
                //Get all the open Work Order
                list<SVMXC__Service_Order__c> lstWorkOrder = new list<SVMXC__Service_Order__c>();
                lstWorkOrder = [Select Id From SVMXC__Service_Order__c where SVMXC__PM_Plan__c =: strPMPlanId AND SVMXC__Is_PM_Work_Order__c = true AND SVMXC__Order_Status__c = 'Open'];
                
                //Cancel all the open Work Order created by PM Plan's
                if(lstWorkOrder != null && lstWorkOrder.size() > 0)
                {
                    for(SVMXC__Service_Order__c objWorkOrd : lstWorkOrder)
                        objWorkOrd.SVMXC__Order_Status__c = 'Canceled';
                    
                    //update lstWorkOrder;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstWorkOrder, COMM_SecurityUtils.Access.Updateable)){
                        update lstWorkOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
            }
            
            objPageDataResp.response.message = system.label.COMM001_TAG058;
            list<SVMXC.INTF_WebServicesDef.INTF_StringMap> stringMap = new list<SVMXC.INTF_WebServicesDef.INTF_StringMap>();
            if(isNextStepURL)
                stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO', strNextStepURL));
            else
                stringMap.add(new SVMXC.INTF_WebServicesDef.INTF_StringMap('NAVIGATE_TO', strPMPlanId));
            objPageDataResp.response.stringMap = stringMap;
            return objPageDataResp;
        }
        catch(exception ex)
        {
            system.debug(loggingLevel.WARN, 'Error : '+ex.getMessage());
            Database.rollback(sp);
            objPageDataResp.response.success = false;
            objPageDataResp.response.message = ex.getmessage();
            return objPageDataResp;
        }
    }
    
    //Method for generating PM Plans from PM Plan Template for Account, Service Contract or Installed Product
    public SVMXC.INTF_WebservicesDef.INTF_Response PREV_CalculatePMPlanDetails(SVMXC.INTF_WebservicesDef.INTF_Request req)
    {
        SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();        
        List<SVMXC.INTF_WebservicesDef.INTF_StringListMap> lstStringLstMapReq = new List<SVMXC.INTF_WebservicesDef.INTF_StringListMap>();
        List<SVMXC__PM_Plan__c> lstPMPlans = new List<SVMXC__PM_Plan__c>();
        set<string> lstPMPlanIDs = new set<string>();
        Set<String> setAccountBasedPMPlanIds = new Set<String>();
        Set<String> setProdBasedPMPlanIds = new Set<String>();
        Set<String> setLocBasedPMPlanIds = new Set<String>();
        List<SVMXC__PM_Plan__c> lstAccountBasedPMPlans = new List<SVMXC__PM_Plan__c>();
        List<SVMXC__PM_Plan__c> lstProdBasedPMPlans = new List<SVMXC__PM_Plan__c>();
        List<SVMXC__PM_Plan__c> lstLocBasedPMPlans = new List<SVMXC__PM_Plan__c>();
        Map<string, string> mapProdBasedPMPlanToTemplate = new Map<string, string>();
        Map<string, string> mapLocBasedPMPlanToTemplate = new Map<string, string>();
        
        string mode = '';
        boolean activatePMPlan = false;
        
        //getting setting block start
        Map<String, String> svmxSettingList = new Map<String,String>();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        if(commSettings.SVMX_getSettingList('PREV001') != null)
            svmxSettingList = commSettings.SVMX_getSettingList('PREV001');
        if(svmxSettingList.containsKey('SET002'))
            activatePMPlan = boolean.valueOf(svmxSettingList.get('SET002'));
        //getting setting block end
        
        
        system.debug(loggingLevel.WARN, 'activatePMPlan: ' + activatePMPlan);
        res.success = true;

        //Extract the Request to get the mode(Account/SC/IB/Location) of Execution and List of PM Plan IDs to process
        lstStringLstMapReq = req.stringListMap;
        if(lstStringLstMapReq != null && lstStringLstMapReq.size() >0)
        {
            for(SVMXC.INTF_WebservicesDef.INTF_StringListMap strLstMp: lstStringLstMapReq)
            {
                if(strLstMp.key == 'Mode' && strLstMp.valueList != null)
                    mode = strLstMp.valueList[0];
                else if(strLstMp.key == 'PM Plan' && strLstMp.valueList != null)
                    lstPMPlanIDs.addAll(strLstMp.valueList);
            }
            
            system.debug(loggingLevel.WARN, 'Mode: ' + mode + ' :PM Plan ID: ' + lstPMPlanIDs);
            system.debug(loggingLevel.WARN, 'activatePMPlan: ' + activatePMPlan);
            set<string> lstModes = new set<string>();
            lstModes.add('IB');
            lstModes.add('Account');
            lstModes.add('Location');
            lstModes.add('SC');
            
            //Querying PM Plans
            if(lstPMPlanIDs == null || lstPMPlanIDs.size() == 0 || !(lstModes.contains(mode)))
            {
                res.messageType = 'SVMX_INFO';
                res.message = getTAG002();
                return res;
            }
            try
            {
                lstPMPlans = [Select SVMXC__PM_Plan_Template__c, SVMXC__Service_Contract__c, SVMXC__Status__c, SVMXC__Account__c, SVMXC__Location__c, SVMXC__Start_Date__c, SVMXC__End_Date__c, SVMXC__Coverage_Type__c from SVMXC__PM_Plan__c where id IN: lstPMPlanIDs];
                    
                if(lstPMPlans != null && lstPMPlans.size() > 0)
                {
                    for(SVMXC__PM_Plan__c PMP : lstPMPlans)
                    {
                        if(PMP.SVMXC__Coverage_Type__c != null && PMP.SVMXC__Coverage_Type__c.toUpperCase() == 'ACCOUNT (VISIT ONLY)')
                        {
                            setAccountBasedPMPlanIds.add(PMP.Id);
                            lstAccountBasedPMPlans.add(PMP);
                        }
                        else if(PMP.SVMXC__Coverage_Type__c != null && PMP.SVMXC__Coverage_Type__c.toUpperCase() == 'LOCATION (MUST HAVE LOCATION)')
                        {
                            setLocBasedPMPlanIds.add(PMP.Id);
                            lstLocBasedPMPlans.add(PMP);
                            mapLocBasedPMPlanToTemplate.put(PMP.Id, PMP.SVMXC__PM_Plan_Template__c);
                        }
                        else if(PMP.SVMXC__Coverage_Type__c != null && PMP.SVMXC__Coverage_Type__c.toUpperCase() == 'PRODUCT (MUST HAVE IB)')
                        {
                            setProdBasedPMPlanIds.add(PMP.Id);
                            lstProdBasedPMPlans.add(PMP);
                            mapProdBasedPMPlanToTemplate.put(PMP.Id, PMP.SVMXC__PM_Plan_Template__c);
                        }
                        else
                        {
                            setProdBasedPMPlanIds.add(PMP.Id);
                            lstProdBasedPMPlans.add(PMP);
                            mapProdBasedPMPlanToTemplate.put(PMP.Id, PMP.SVMXC__PM_Plan_Template__c);
                        }
                    }
                    
                    if((lstProdBasedPMPlans != null && lstProdBasedPMPlans.size() > 0) || (lstLocBasedPMPlans != null && lstLocBasedPMPlans.size() > 0) 
                    || (lstAccountBasedPMPlans != null && lstAccountBasedPMPlans.size() > 0)){
                    
                        //Coverage Type = PRODUCT (MUST HAVE IB)
                        if(lstProdBasedPMPlans != null && lstProdBasedPMPlans.size() > 0){
                            res = createIBCoverage(lstProdBasedPMPlans, mapProdBasedPMPlanToTemplate, setProdBasedPMPlanIds, mode, activatePMPlan);
                        }
                        
                        //Coverage Type = LOCATION (MUST HAVE LOCATION)
                        if(lstLocBasedPMPlans != null && lstLocBasedPMPlans.size() > 0){
                            res = createLocationCoverage(lstLocBasedPMPlans, mapLocBasedPMPlanToTemplate, setLocBasedPMPlanIds, mode, activatePMPlan);
                        }
                        
                        //Coverage type = ACCOUNT (VISIT ONLY)
                        if(lstAccountBasedPMPlans != null && lstAccountBasedPMPlans.size() > 0){
                            
                            lstAccountBasedPMPlans = setPMPlanStatus(activatePMPlan, lstAccountBasedPMPlans, '');
                            if(lstAccountBasedPMPlans != null && lstAccountBasedPMPlans.size() > 0){
                                //update lstAccountBasedPMPlans;
                                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstAccountBasedPMPlans, COMM_SecurityUtils.Access.Updateable)){
                                    update lstAccountBasedPMPlans; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                } else {
                                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                                }
                            }
                                
                            INTF_WebServicesDef.INTF_Request reqToCalcNxtSchedule = new INTF_WebServicesDef.INTF_Request();
                            reqToCalcNxtSchedule.recordIds = new List<string>();
                            reqToCalcNxtSchedule.recordIds.addAll(setAccountBasedPMPlanIds);
                            PREV_CalculateNextSchedule(reqToCalcNxtSchedule);
                            return res;
                        }
                    }
                    else
                    {
                        res.messageType = 'SVMX_INFO';
                        res.message = getTAG002();
                    }
                }
                else
                {
                    res.messageType = 'SVMX_INFO';
                    res.message = getTAG004();
                }
            }
            catch(Exception ex)
            {
                res.success = false;
                res.messageType = 'ERROR';
                res.message = ex.getmessage();
            }
        }
        return res;
    }
    //method to create pm coverage from IB
    public SVMXC.INTF_WebservicesDef.INTF_Response createIBCoverage(List<SVMXC__PM_Plan__c> lstProdBasedPMPlans, Map<string, string> mapPMPlanToTemplate, set<string> lstPMPlanIDs, String mode, boolean activatePMPlan)
    {
        SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
        
        List<SVMXC__PM_Applicable_Product__c> lstApplicablePMProducts = new List<SVMXC__PM_Applicable_Product__c>();
        List<SVMXC__Installed_Product__c> lstInstalledProducts = new List<SVMXC__Installed_Product__c>();
        List<SVMXC__PM_Coverage__c> lstPMCov = new List<SVMXC__PM_Coverage__c>();
        List<SVMXC__PM_Plan_Template__c> lstPMTemplate = new List<SVMXC__PM_Plan_Template__c>();
        Map<string, string> mapPMTemplateToIBRule = new Map<string, string>();
        Map<string, string> mapIBRuleToWhereClause = new Map<string, string>();
        Map<string, set<string>> mapPMTempLstApplProd = new Map<string, set<string>>();
        Map<string, set<string>> mapPMTempLstApplProdLine = new Map<string, set<string>>();
        Map<string, set<string>> mapPMTempLstApplProdFamily = new Map<string, set<string>>();
        
        
        System.debug('Mode: ' + mode);
        res.success = true;
        //If mode is IB then only create next Schedule.
            if(mode == 'IB')
            {
                //setPMPlanStatus(activatePMPlan, lstProdBasedPMPlans, 'Product (Must Have IB)');
                
                lstProdBasedPMPlans = setPMPlanStatus(activatePMPlan, lstProdBasedPMPlans, 'Product (Must Have IB)');
                if(lstProdBasedPMPlans != null && lstProdBasedPMPlans.size() > 0){
                    //update lstProdBasedPMPlans;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstProdBasedPMPlans, COMM_SecurityUtils.Access.Updateable)){
                        update lstProdBasedPMPlans; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                
                INTF_WebServicesDef.INTF_Request reqToCalcNxtSchedule = new INTF_WebServicesDef.INTF_Request();
                reqToCalcNxtSchedule.recordIds = new List<string>();
                reqToCalcNxtSchedule.recordIds.addAll(lstPMPlanIDs);
                PREV_CalculateNextSchedule(reqToCalcNxtSchedule);
                return res;
            }
            
            if(mapPMPlanToTemplate != null && mapPMPlanToTemplate.size() > 0)
            {
                //Querying the PM Templates to get the IB criteria Process
                //set<string> lstCriProcIDs = new set<string>();
                set<string> lstPMTemplateIDs = new set<string>();
                if(mapPMPlanToTemplate.values() != null && mapPMPlanToTemplate.values().size() > 0)
                    lstPMTemplate = [select id, SVMXC__IB_Criteria__c from SVMXC__PM_Plan_Template__c where id IN: mapPMPlanToTemplate.values()];
                
                system.debug(loggingLevel.WARN, 'PM Catalogue queried is: ' + lstPMTemplate);
                
                if(lstPMTemplate == null || lstPMTemplate.size() == 0)
                {
                    res.messageType = 'SVMX_INFO';
                    res.message = getTAG001();
                    return res;
                }
                
                for(SVMXC__PM_Plan_Template__c pmTem : lstPMTemplate)
                {
                    if(pmTem.SVMXC__IB_Criteria__c != null)
                    {
                        mapPMTemplateToIBRule.put(pmTem.Id, pmTem.SVMXC__IB_Criteria__c);
                        //lstCriProcIDs.add(pmTem.SVMXC__IB_Criteria__c);
                    }
                    lstPMTemplateIDs.add(pmTem.Id);
                }
                
                List<SVMXC__ServiceMax_Processes__c> lstCriProc = new List<SVMXC__ServiceMax_Processes__c>();
                
                if(mapPMTemplateToIBRule.values() != null && mapPMTemplateToIBRule.values().size() > 0)
                    lstCriProc = [select id, SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id IN: mapPMTemplateToIBRule.values()];
                
                for(SVMXC__ServiceMax_Processes__c proc: lstCriProc)
                    mapIBRuleToWhereClause.put(proc.Id, proc.SVMXC__Parent_Object_Criteria__c);
                
                lstApplicablePMProducts = [select id, SVMXC__Product_Line__c, SVMXC__Product_Family__c, SVMXC__Product__c, SVMXC__PM_Plan_Template__c from SVMXC__PM_Applicable_Product__c where SVMXC__PM_Plan_Template__c =: lstPMTemplateIDs];
                
                system.debug(loggingLevel.WARN, 'List of Applicable Products queried are: ' + lstApplicablePMProducts + ' and size is: ' + lstApplicablePMProducts.size());
                
                for(SVMXC__PM_Applicable_Product__c appProd : lstApplicablePMProducts)
                {
                    if(appProd.SVMXC__Product__c != null)
                    {
                        if(!mapPMTempLstApplProd.containsKey(appProd.SVMXC__PM_Plan_Template__c))
                            mapPMTempLstApplProd.put(appProd.SVMXC__PM_Plan_Template__c, new set<string>());
                        mapPMTempLstApplProd.get(appProd.SVMXC__PM_Plan_Template__c).add(appProd.SVMXC__Product__c);
                    }
                    if(appProd.SVMXC__Product_Line__c != null)
                    {
                        if(!mapPMTempLstApplProdLine.containsKey(appProd.SVMXC__PM_Plan_Template__c))
                            mapPMTempLstApplProdLine.put(appProd.SVMXC__PM_Plan_Template__c, new set<string>());
                        mapPMTempLstApplProdLine.get(appProd.SVMXC__PM_Plan_Template__c).add(appProd.SVMXC__Product_Line__c);
                    }
                    if(appProd.SVMXC__Product_Family__c != null)
                    {
                        if(!mapPMTempLstApplProdFamily.containsKey(appProd.SVMXC__PM_Plan_Template__c))
                            mapPMTempLstApplProdFamily.put(appProd.SVMXC__PM_Plan_Template__c, new set<string>());
                        mapPMTempLstApplProdFamily.get(appProd.SVMXC__PM_Plan_Template__c).add(appProd.SVMXC__Product_Family__c);
                    }
                }
                
                system.debug(loggingLevel.WARN, '=======Product==== ' + mapPMTempLstApplProd + '\n=======Product Line==== ' + mapPMTempLstApplProdLine + '\n=======Product Family==== ' + mapPMTempLstApplProdFamily);
                
                for(SVMXC__PM_Plan__c PMP : lstProdBasedPMPlans)
                {
                    string querySOQL = '';
                    string PMTemplateID = mapPMPlanToTemplate.get(PMP.Id);
                    set<string> setStr = new set<string>(); 
                    set<string> setStr1 = new set<string>();
                    set<string> setStr2 =  new set<string>();
                    if(mode == 'Account')
                    {
                        string strAccId = PMP.SVMXC__Account__c;
                        string whereClause = mapIBRuleToWhereClause.get(mapPMTemplateToIBRule.get(PMTemplateID));
                        if(whereClause != null && whereClause.length() > 0)
                            querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Company__c =: strAccId AND (' + whereClause + ')';
                        else
                            querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Company__c =: strAccId';
                    }
                    else if(mode == 'Location')
                    {
                        string strLocId = PMP.SVMXC__Location__c;
                        string whereClause = mapIBRuleToWhereClause.get(mapPMTemplateToIBRule.get(PMTemplateID));
                        if(whereClause != null && whereClause.length() > 0)
                            querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Site__c =: strLocId AND (' + whereClause + ')';
                        else
                            querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Site__c =: strLocId';
                    }
                    else if(mode == 'SC')
                    {
                        map<string, string> mapIBToSC = new map<string, string>();
                        
                        List<SVMXC__Service_Contract_Products__c> lstCoveredProds = [select id, SVMXC__Service_Contract__c, SVMXC__Installed_Product__c from SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c =: PMP.SVMXC__Service_Contract__c];
                        system.debug(loggingLevel.WARN, 'List of Covered Products queried are: ' + lstCoveredProds + ' and size is: ' + lstCoveredProds.size());
                        if(lstCoveredProds != null && lstCoveredProds.size() >0)
                        {
                            Set<string> setIBIDs = new Set<string>();
                            for(SVMXC__Service_Contract_Products__c covProd : lstCoveredProds)
                                setIBIDs.add(covProd.SVMXC__Installed_Product__c);
                            string whereClause = mapIBRuleToWhereClause.get(mapPMTemplateToIBRule.get(PMTemplateID));
                            if(whereClause != null && whereClause.length() > 0)
                                querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where Id IN: setIBIDs AND (' + whereClause + ')';
                            else
                                querySOQL += 'select id, Name, SVMXC__Product__c from SVMXC__Installed_Product__c where Id IN: setIBIDs';
                        }
                    }
                    
                    if(((mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0) || (mapPMTempLstApplProdLine != null && mapPMTempLstApplProdLine.size() > 0) || (mapPMTempLstApplProdFamily != null && mapPMTempLstApplProdFamily.size() > 0)) && querySOQL != null && querySOQL.length() >0)
                        querySOQL += ' AND (';
                    System.debug('querySOQL: '+querySOQL);
                    String tempProductQuery = '';
                    if(mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0)
                    {
                        if(mapPMTempLstApplProd.containsKey(PMTemplateID) && mapPMTempLstApplProd.get(PMTemplateID) != null && mapPMTempLstApplProd.get(PMTemplateID).size() > 0)
                        {
                            setStr = mapPMTempLstApplProd.get(PMTemplateID);
                            tempProductQuery = 'SVMXC__Product__c IN: setStr'; //Added this line and commented below lines for fixing defect BAC-5568
                            //if(querySOQL != null && querySOQL.length() > 0)
                            //querySOQL += 'SVMXC__Product__c IN: setStr';
                        }
                    }
                    //Added mapPMTempLstApplProdLine.containsKey(PMTemplateID) condition in below if clause for fixing defect BAC-5568
                    if(mapPMTempLstApplProdLine != null && mapPMTempLstApplProdLine.size() > 0 && mapPMTempLstApplProdLine.containsKey(PMTemplateID))
                    {
                        if(mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0)
                        {
                            //Added this line and commented below lines for fixing defect BAC-5568
                            if(tempProductQuery != null && tempProductQuery.length() > 0)
                                tempProductQuery += ' OR ';
                            //if(querySOQL != null && querySOQL.length() > 0)
                            //querySOQL += ' OR ';
                        }
                        if(mapPMTempLstApplProdLine.containsKey(PMTemplateID) && mapPMTempLstApplProdLine.get(PMTemplateID) != null && mapPMTempLstApplProdLine.get(PMTemplateID).size() > 0)
                        {
                            setStr1 = mapPMTempLstApplProdLine.get(PMTemplateID);
                            tempProductQuery += 'SVMXC__Product__r.SVMXC__Product_Line__c IN: setStr1'; //Added this line and commented below lines for fixing defect BAC-5568
                            //if(querySOQL != null && querySOQL.length() > 0)
                            //querySOQL += 'SVMXC__Product__r.SVMXC__Product_Line__c IN: setStr1';
                        }
                    }
                    //Added mapPMTempLstApplProdFamily.containsKey(PMTemplateID) condition in below if clause for fixing defect BAC-5568
                    if(mapPMTempLstApplProdFamily != null && mapPMTempLstApplProdFamily.size() > 0 && mapPMTempLstApplProdFamily.containsKey(PMTemplateID))
                    {
                        if((mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0) || (mapPMTempLstApplProdLine != null && mapPMTempLstApplProdLine.size() > 0))
                        {
                            //Added this line and commented below lines for fixing defect BAC-5568
                            if(tempProductQuery != null && tempProductQuery.length() > 0)
                                tempProductQuery += ' OR ';
                            //if(querySOQL != null && querySOQL.length() > 0)
                            //querySOQL += ' OR ';
                        }
                        if(mapPMTempLstApplProdFamily.containsKey(PMTemplateID) && mapPMTempLstApplProdFamily.get(PMTemplateID) != null && mapPMTempLstApplProdFamily.get(PMTemplateID).size() > 0)
                        {
                            setStr2 = mapPMTempLstApplProdFamily.get(PMTemplateID);
                            tempProductQuery += 'SVMXC__Product__r.Family IN: setStr2'; //Added this line and commented below lines for fixing defect BAC-5568
                            //if(querySOQL != null && querySOQL.length() > 0)
                            //querySOQL += 'SVMXC__Product__r.Family IN: setStr2';
                        }
                    }
                    System.debug('tempProductQuery: '+tempProductQuery);
                    //Added this line for fixing defect BAC-5568
                    if(tempProductQuery != null && tempProductQuery.length() > 0){
                        querySOQL += tempProductQuery;
                    }
                    
                    if(((mapPMTempLstApplProd != null && mapPMTempLstApplProd.size() > 0) || (mapPMTempLstApplProdLine != null && mapPMTempLstApplProdLine.size() > 0) || (mapPMTempLstApplProdFamily != null && mapPMTempLstApplProdFamily.size() > 0)) && querySOQL != null && querySOQL.length() > 0)
                        querySOQL += ')';
                    
                    system.debug(loggingLevel.WARN, 'Query Prepared is: ' + querySOQL);
                    if(querySOQL != null && querySOQL.length() > 0)
                        lstInstalledProducts = database.query(querySOQL);
                    system.debug(loggingLevel.WARN, 'List of IBs queried: ' + lstInstalledProducts);
                        
                    if(lstInstalledProducts != null && lstInstalledProducts.size() > 0)
                    {
                        for(SVMXC__Installed_Product__c IB: lstInstalledProducts)
                        {
                            SVMXC__PM_Coverage__c pmCov = new SVMXC__PM_Coverage__c();
                            pmCov.SVMXC__PM_Plan__c = PMP.Id;
                            pmCov.SVMXC__Product_Name__c = IB.Id;
                            lstPMCov.add(pmCov);
                        }
                    }
                }
                
                system.debug(loggingLevel.WARN, 'List of PM Coverage to Create: ' + lstPMCov);
                
                if(lstPMCov != null && lstPMCov.size() > 0){
                    //upsert lstPMCov;
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstPMCov, COMM_SecurityUtils.Access.Upsertable)){
                        upsert lstPMCov; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                    }
                }
            }
            
            lstProdBasedPMPlans = setPMPlanStatus(activatePMPlan, lstProdBasedPMPlans, 'Product (Must Have IB)');
            if(lstProdBasedPMPlans != null && lstProdBasedPMPlans.size() > 0){
                //update lstProdBasedPMPlans;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstProdBasedPMPlans, COMM_SecurityUtils.Access.Updateable)){
                    update lstProdBasedPMPlans; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            
            INTF_WebServicesDef.INTF_Request reqToCalcNxtSchedule = new INTF_WebServicesDef.INTF_Request();
            reqToCalcNxtSchedule.recordIds = new List<string>();
            reqToCalcNxtSchedule.recordIds.addAll(lstPMPlanIDs);
            PREV_CalculateNextSchedule(reqToCalcNxtSchedule);
        
        
        system.debug(loggingLevel.WARN, 'Response created is: ' + res);
        return res;
        
    }
    
    //method to create pm coverage from Location
    public SVMXC.INTF_WebservicesDef.INTF_Response createLocationCoverage(List<SVMXC__PM_Plan__c> lstLocBasedPMPlans, Map<string, string> mapLocBasedPMPlanToTemplate, set<string> setPMPlanIDs, String mode, boolean activatePMPlan)
    {
        SVMXC.INTF_WebservicesDef.INTF_Response res = new SVMXC.INTF_WebservicesDef.INTF_Response();
        List<SVMXC__PM_Coverage__c> lstPMCvrgs = new List<SVMXC__PM_Coverage__c>();
        res.success = true;
        if(mode != null && mode.length() > 0)
            mode = mode.toUpperCase();
        
        System.debug(loggingLevel.WARN, 'Mode : ' + mode);
        
        if(lstLocBasedPMPlans != null && lstLocBasedPMPlans.size() > 0)
        {
            List<String> lstLocIds = new List<String>();
            if(mode == 'LOCATION'){
                for(SVMXC__PM_Plan__c PMP : lstLocBasedPMPlans){
                    if(PMP.SVMXC__Location__c != null)
                        lstLocIds.add(PMP.SVMXC__Location__c);
                    
                    lstPMCvrgs = createPMCoverages(lstLocIds, PMP.Id);
                    System.debug(loggingLevel.WARN, 'Location Ids : ' + lstLocIds + '; Coverages: ' + lstPMCvrgs);
                }
            }
            else{
                
                Set<String> setLocCrit = new Set<String>();
                Set<String> setPMTemplateIDs = new set<String>();
                Map<String, String> mapPMTemplateToLocCritRule = new Map<String, String>();
                Map<String, String> mapLocCritRuleToWhereClause = new Map<String, String>();
                
                if(mapLocBasedPMPlanToTemplate != null && mapLocBasedPMPlanToTemplate.size() > 0){
                    
                    setPMTemplateIDs.addAll(mapLocBasedPMPlanToTemplate.values());
                    setPMTemplateIDs = removeNullValueFromSet(setPMTemplateIDs);
                    List<SVMXC__PM_Plan_Template__c> lstPMTemplate = new List<SVMXC__PM_Plan_Template__c>();
                    lstPMTemplate = [Select Id, SVMXC__Location_Criteria__c from SVMXC__PM_Plan_Template__c where Id IN: setPMTemplateIDs];
                    
                    if(lstPMTemplate == null || lstPMTemplate.size() == 0)
                    {
                        res.messageType = 'SVMX_INFO';
                        res.message = getTAG001();
                        return res;
                    }
                    for(SVMXC__PM_Plan_Template__c PMTemplate : lstPMTemplate)
                    {
                        if(PMTemplate.SVMXC__Location_Criteria__c != null && String.valueOf(PMTemplate.SVMXC__Location_Criteria__c).length() > 0)
                            mapPMTemplateToLocCritRule.put(PMTemplate.Id, PMTemplate.SVMXC__Location_Criteria__c);
                    }
                
                    setLocCrit.addAll(mapPMTemplateToLocCritRule.values());
                    setLocCrit = removeNullValueFromSet(setLocCrit);
                    if(setLocCrit != null && setLocCrit.size() > 0){
                        for(SVMXC__ServiceMax_Processes__c proc: [Select Id, SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id IN: setLocCrit])
                            mapLocCritRuleToWhereClause.put(proc.Id, proc.SVMXC__Parent_Object_Criteria__c);
                    }
                }
                
                for(SVMXC__PM_Plan__c PMP : lstLocBasedPMPlans){
                    
                    String SOQL = '';
                    String whereClause = mapLocCritRuleToWhereClause.get(mapPMTemplateToLocCritRule.get(PMP.SVMXC__PM_Plan_Template__c));
                    Set<String> setLocationIDs = new Set<String>();
                    
                    if(mode == 'ACCOUNT'){
                        
                        if(PMP.SVMXC__Account__c != null && String.valueOf(PMP.SVMXC__Account__c).length() > 0){
                            for(SVMXC__Site__c objSite : [Select Id From SVMXC__Site__c Where SVMXC__Account__c =: PMP.SVMXC__Account__c])
                                setLocationIDs.add(objSite.Id);
                        }
                    }
                    else if(mode == 'SC'){
                        
                        if(PMP.SVMXC__Service_Contract__c != null && String.valueOf(PMP.SVMXC__Service_Contract__c).length() > 0){
                            for(SVMXC__Service_Contract_Sites__c objCoveredSite : [Select Id, SVMXC__Site__c From SVMXC__Service_Contract_Sites__c Where SVMXC__Service_Contract__c =: PMP.SVMXC__Service_Contract__c]){
                                if(objCoveredSite.SVMXC__Site__c != null && String.valueOf(objCoveredSite.SVMXC__Site__c).length() > 0)
                                    setLocationIDs.add(objCoveredSite.SVMXC__Site__c);
                            }
                        }
                    }
                    if(whereClause != null && whereClause.length() > 0)
                        SOQL = 'Select Id From SVMXC__Site__c where Id IN: setLocationIDs AND (' + whereClause + ')';
                    else
                        SOQL = 'Select Id From SVMXC__Site__c where Id IN: setLocationIDs';
                    
                    System.debug(loggingLevel.WARN, 'Query Prepared is: ' + SOQL);
                    if(SOQL != null && SOQL.length() > 0){
                        for(SVMXC__Site__c loc : database.query(SOQL)){
                            lstLocIds.add(loc.Id);
                        }
                    }
                    System.debug(loggingLevel.WARN, 'Location Ids : ' + lstLocIds);
                    
                    lstPMCvrgs = createPMCoverages(lstLocIds, PMP.Id);
                    System.debug(loggingLevel.WARN, 'Coverages: ' + lstPMCvrgs);
                }
                
            }
            
            system.debug(loggingLevel.WARN, 'List of PM Coverage to Create: ' + lstPMCvrgs);
            
            if(lstPMCvrgs != null && lstPMCvrgs.size() > 0){
                //upsert lstPMCvrgs;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstPMCvrgs, COMM_SecurityUtils.Access.Upsertable)){
                    upsert lstPMCvrgs; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
        }
        
        lstLocBasedPMPlans = setPMPlanStatus(activatePMPlan, lstLocBasedPMPlans, 'Location (Must Have Location)');
        if(lstLocBasedPMPlans != null && lstLocBasedPMPlans.size() > 0){
            //update lstLocBasedPMPlans;
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstLocBasedPMPlans, COMM_SecurityUtils.Access.Updateable)){
                update lstLocBasedPMPlans; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        
        INTF_WebServicesDef.INTF_Request reqToCalcNxtSchedule = new INTF_WebServicesDef.INTF_Request();
        reqToCalcNxtSchedule.recordIds = new List<string>();
        reqToCalcNxtSchedule.recordIds.addAll(setPMPlanIDs);
        PREV_CalculateNextSchedule(reqToCalcNxtSchedule);
        
        system.debug(loggingLevel.WARN, 'Response created is: ' + res);
        return res;
    }
    
    public List<SVMXC__PM_Coverage__c> createPMCoverages(List<String> lstLocationIds, Id PMPlanId){
    
        List<SVMXC__PM_Coverage__c> lstPMCvrgs = new List<SVMXC__PM_Coverage__c>();
        if(lstLocationIds != null && lstLocationIds.size() > 0){
            for(String LocId : lstLocationIds){
                if(LocId != null && LocId.length() > 0){
                    lstPMCvrgs.add(new SVMXC__PM_Coverage__c(SVMXC__PM_Plan__c = PMPlanId, SVMXC__Location_Name__c = LocId));
                }
            }
        }
        return lstPMCvrgs;
    }
    
    public Set<String> removeNullValueFromSet(Set<String> setValues){
        if(setValues != null && setValues.contains(null))
            setValues.remove(null);
        return setValues;
    }
    
    // Method to create next PM Schedule object.
    public void PREV_CalculateNextSchedule(INTF_WebServicesDef.INTF_Request reqToCalcNxtSchedule)
    {
        List<SVMXC__PM_Schedule__c> lstPMScheduleToBeDelete = new List<SVMXC__PM_Schedule__c>();
        list<SVMXC__PM_Schedule_Definition__c> lstPMScheduleDefinitions = new list<SVMXC__PM_Schedule_Definition__c>();
        list<SVMXC__PM_Schedule__c> lstExistingPMSchedule = new list<SVMXC__PM_Schedule__c>();
        map<Id,SVMXC__PM_Plan__c> mapPMPlans = new map<Id,SVMXC__PM_Plan__c>();
        map<Id, SVMXC__PM_Plan_Template__c > mapPMPlansTemplate = new map<Id, SVMXC__PM_Plan_Template__c >();
        map<Id,SVMXC__PM_Schedule_Definition__c> mapPMScheduleDefinitions = new map<Id,SVMXC__PM_Schedule_Definition__c>();
        map<Id,SVMXC__PM_Schedule__c> mapSchedDefIdPMSchedule = new Map<Id,SVMXC__PM_Schedule__c>();
        map<string, date> mapScheduleDefIdLastRunDate = new map<string, date>();
        list<ID> lstScheduleIDs = new list<ID>();
        //SK 03/08- BAC 2954   
         list<ID> lstPMTmplIDs = new list<ID>();    
        
        system.debug(loggingLevel.WARN, 'Request: ' + reqToCalcNxtSchedule);
        
        list<ID> lstPMIDs = reqToCalcNxtSchedule.recordIds;
        if(reqToCalcNxtSchedule.stringListMap != NULL && reqToCalcNxtSchedule.stringListMap.size() == 1 && (reqToCalcNxtSchedule.stringListMap)[0].key == 'SCHEDULEID')
            lstScheduleIDs = (reqToCalcNxtSchedule.stringListMap)[0].valueList;
        
        if((lstPMIDs != NULL && lstPMIDs.size() > 0) || (lstScheduleIDs != NULL && lstScheduleIDs.size() > 0)) 
        {
            //Get the PM Schedule records which have already been processed. 
            if(lstScheduleIDs != NULL && lstScheduleIDs.size() > 0)
                lstPMScheduleToBeDelete = [Select Id from SVMXC__PM_Schedule__c where SVMXC__PM_Schedule_Definition__c IN: lstScheduleIDs AND SVMXC__PM_Schedule_Definition__r.SVMXC__Processed__c = true AND SVMXC__PM_Plan__c IN: lstPMIDs];
            
            //Get the PM Plan records.
            mapPMPlans.putAll([Select SVMXC__End_Date__c, SVMXC__Start_Date__c,SVMXC__PM_Plan_Template__c from SVMXC__PM_Plan__c where ID IN: lstPMIDs]);
           
            //SK 03/08- BAC 2954 
            if(mapPMPlans!=NULL && mapPMPlans.size()>0)
            {
                for (SVMXC__PM_Plan__c tmpl :mapPMPlans.values() )
                {
                   if(tmpl.SVMXC__PM_Plan_Template__c!=NULL)
                   lstPMTmplIDs.add(tmpl.SVMXC__PM_Plan_Template__c) ;
                }
                if(lstPMTmplIDs!=NULL && lstPMTmplIDs.size()>0)
                 {
                   mapPMPlansTemplate.putAll([select id, SVMXC__SM_Unit_Value__c , SVMXC__SM_Unit_Type__c from SVMXC__PM_Plan_Template__c where id IN:lstPMTmplIDs]);
                 }
           } 
            if(lstScheduleIDs != NULL && lstScheduleIDs.size() > 0)
                lstPMScheduleDefinitions = [Select SVMXC__Frequency__c, SVMXC__Recurring__c, SVMXC__Frequency_Unit__c, SVMXC__PM_Plan__c, SVMXC__Processed__c from SVMXC__PM_Schedule_Definition__c where Id IN: lstScheduleIDs AND SVMXC__PM_Plan__c IN: lstPMIDs AND SVMXC__Processed__c = false];
            else
                lstPMScheduleDefinitions = [Select SVMXC__Frequency__c, SVMXC__Recurring__c, SVMXC__Frequency_Unit__c, SVMXC__PM_Plan__c, SVMXC__Processed__c from SVMXC__PM_Schedule_Definition__c where SVMXC__PM_Plan__c IN: lstPMIDs AND SVMXC__Processed__c = false];
            
            mapPMScheduleDefinitions.putAll(lstPMScheduleDefinitions);
            
            //Get the existing PM Schedule records
            if(mapPMScheduleDefinitions.keySet() != NULL && mapPMScheduleDefinitions.keySet().size() > 0)
                lstExistingPMSchedule = [Select SVMXC__PM_Schedule_Definition__c, SVMXC__Scheduled_On__c from SVMXC__PM_Schedule__c where SVMXC__PM_Schedule_Definition__c IN: mapPMScheduleDefinitions.keySet()];
            
            for(SVMXC__PM_Schedule__c currPMSchedule : lstExistingPMSchedule)
            {
                mapScheduleDefIdLastRunDate.put(currPMSchedule.SVMXC__PM_Schedule_Definition__c, currPMSchedule.SVMXC__Scheduled_On__c);
                mapSchedDefIdPMSchedule.put(currPMSchedule.SVMXC__PM_Schedule_Definition__c, currPMSchedule);
            }
            
            lstPMIDs.clear();
            lstScheduleIDs.clear();
            lstExistingPMSchedule.clear();
            mapPMScheduleDefinitions.clear();
            
            list<SVMXC__PM_Schedule__c> lstPMSchedule = new list<SVMXC__PM_Schedule__c>();
            for(SVMXC__PM_Schedule_Definition__c currentScheDef : lstPMScheduleDefinitions)
            {
                date dtNxtScheduleDate = PREV_CalculateNextSchedule(integer.valueOf(currentScheDef.SVMXC__Frequency__c), currentScheDef.SVMXC__Frequency_Unit__c, mapScheduleDefIdLastRunDate.get(currentScheDef.Id) != NULL ? mapScheduleDefIdLastRunDate.get(currentScheDef.Id) : mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__Start_Date__c);
                System.debug('dtNxtScheduleDate: '+dtNxtScheduleDate);

                //if(dtNxtScheduleDate != NULL && dtNxtScheduleDate >= mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__Start_Date__c && dtNxtScheduleDate <= mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__End_Date__c)

                //-----Start-------Added for the defect 045803 and commented above if condition
                Date dtNxtScheduleDateDelay = null;
                if (!mapSchedDefIdPMSchedule.containsKey(currentScheDef.Id) && (mapPMPlansTemplate.get(mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__PM_Plan_Template__c).SVMXC__SM_Unit_Value__c !=NULL) && (mapPMPlansTemplate.get(mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__PM_Plan_Template__c).SVMXC__SM_Unit_Type__c !=NULL)){

                    dtNxtScheduleDateDelay = PREV_CalculateNextSchedule(integer.valueOf((mapPMPlansTemplate.get(mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__PM_Plan_Template__c).SVMXC__SM_Unit_Value__c)), mapPMPlansTemplate.get(mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__PM_Plan_Template__c).SVMXC__SM_Unit_Type__c, mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__Start_Date__c) ;

                }

                if((dtNxtScheduleDate != NULL && dtNxtScheduleDate >= mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__Start_Date__c && dtNxtScheduleDate <= mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__End_Date__c) || (dtNxtScheduleDateDelay != null && dtNxtScheduleDateDelay >= mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__Start_Date__c && dtNxtScheduleDateDelay <= mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__End_Date__c))
                //-----End-------Added for the defect 045803
                {
                    if(mapSchedDefIdPMSchedule.containsKey(currentScheDef.Id) && mapSchedDefIdPMSchedule.get(currentScheDef.Id) != NULL)
                    {
                        SVMXC__PM_Schedule__c objPMSchedule = mapSchedDefIdPMSchedule.get(currentScheDef.Id);
                        objPMSchedule.SVMXC__Last_Run_Date__c = mapScheduleDefIdLastRunDate.get(currentScheDef.Id) != NULL ? mapScheduleDefIdLastRunDate.get(currentScheDef.Id) : mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__Start_Date__c;
                        objPMSchedule.SVMXC__Scheduled_On__c = dtNxtScheduleDate;
                        lstPMSchedule.add(objPMSchedule);
                    }
                    else
                    {
                        SVMXC__PM_Schedule__c objPMSchedule = new SVMXC__PM_Schedule__c();
                        objPMSchedule.SVMXC__PM_Schedule_Definition__c = currentScheDef.Id;
                         //SK 03/08- BAC 2954
                        if ((mapPMPlansTemplate.get(mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__PM_Plan_Template__c).SVMXC__SM_Unit_Value__c !=NULL) && (mapPMPlansTemplate.get(mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__PM_Plan_Template__c).SVMXC__SM_Unit_Type__c !=NULL) )
                        {
                            objPMSchedule.SVMXC__Scheduled_On__c = PREV_CalculateNextSchedule(integer.valueOf((mapPMPlansTemplate.get(mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__PM_Plan_Template__c).SVMXC__SM_Unit_Value__c)), mapPMPlansTemplate.get(mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__PM_Plan_Template__c).SVMXC__SM_Unit_Type__c, mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__Start_Date__c) ;
                        }
                        else 
                        {
                            objPMSchedule.SVMXC__Scheduled_On__c = dtNxtScheduleDate; 
                        }
                        objPMSchedule.SVMXC__PM_Plan__c = currentScheDef.SVMXC__PM_Plan__c;
                        objPMSchedule.SVMXC__Last_Run_Date__c = mapScheduleDefIdLastRunDate.get(currentScheDef.Id) != NULL ? mapScheduleDefIdLastRunDate.get(currentScheDef.Id) : mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__Start_Date__c;
                        lstPMSchedule.add(objPMSchedule);
                    }
                    if(currentScheDef.SVMXC__Recurring__c == false)
                        currentScheDef.SVMXC__Processed__c = true;
                }
                else if(dtNxtScheduleDate != NULL && dtNxtScheduleDate > mapPMPlans.get(currentScheDef.SVMXC__PM_Plan__c).SVMXC__End_Date__c &&  mapSchedDefIdPMSchedule.containsKey(currentScheDef.Id) && mapSchedDefIdPMSchedule.get(currentScheDef.Id) != NULL)
                {
                    currentScheDef.SVMXC__Processed__c = true;
                    lstPMScheduleToBeDelete.add(mapSchedDefIdPMSchedule.get(currentScheDef.Id));
                }
            }
            
            system.debug(loggingLevel.WARN, 'List of Schedule Def: ' + lstPMScheduleDefinitions);
            system.debug(loggingLevel.WARN, 'List of PM Schedule: ' + lstPMSchedule);
            system.debug(loggingLevel.WARN, 'List of PMSchedule to be Deleted: ' + lstPMScheduleToBeDelete );
            
            if(lstPMScheduleDefinitions != NULL && lstPMScheduleDefinitions.size() > 0){
                //update lstPMScheduleDefinitions;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstPMScheduleDefinitions, COMM_SecurityUtils.Access.Updateable)){
                    update lstPMScheduleDefinitions; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            
            if(lstPMSchedule != NULL && lstPMSchedule.size() > 0){
                //upsert lstPMSchedule;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstPMSchedule, COMM_SecurityUtils.Access.Upsertable)){
                    upsert lstPMSchedule; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                }
            }
                
            // Delete the Processed PM Schedules
            if(lstPMScheduleToBeDelete != NULL && lstPMScheduleToBeDelete.size() > 0){
                //delete lstPMScheduleToBeDelete;
                if( COMM_SecurityUtils.getInstance().isDeletableObject( 'SVMXC__PM_Schedule__c' ) ) {                        
                    delete lstPMScheduleToBeDelete; //SDL-SVMX-DELETE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            
        }
    }

    // Method to calculate next Schedule date based on last run date and frequency unit.
    public date PREV_CalculateNextSchedule(integer intFrequency, string strFreqUnit, date dtLastRunDate)
    {
        date dtNxtScheduleDate;
        if(strFreqUnit != NULL && intFrequency != NULL && dtLastRunDate != NULL)
        {
            if(strFreqUnit.toUpperCase() == 'WEEKS')
            {
                dtNxtScheduleDate = dtLastRunDate.addDays(intFrequency * 7);
            }
             //SK 03/08- BAC 2954
            else if(strFreqUnit.toUpperCase() == 'Days')
            {
                dtNxtScheduleDate = dtLastRunDate.addDays(intFrequency );
            }
            else if(strFreqUnit.toUpperCase() == 'MONTHS')
            {
                dtNxtScheduleDate = dtLastRunDate.addMonths(intFrequency);
            }
            else if(strFreqUnit.toUpperCase() == 'YEARS')
            {
                dtNxtScheduleDate = dtLastRunDate.addYears(intFrequency);
            }
        }
        system.debug(loggingLevel.WARN, 'Next Schedule Date: ' + dtNxtScheduleDate);
        return dtNxtScheduleDate;
    }
        
    public list<SVMXC__PM_Plan__c> setPMPlanStatus(boolean activatePMPlan, list<SVMXC__PM_Plan__c> lstPMPlans, String strCoverageType)
    {
        system.debug(loggingLevel.WARN, 'Entered to set the status with List of PM Plans to be updated are: ' + lstPMPlans + ' :Activate Plan?: ' + activatePMPlan);
        set<ID> setPMPlanIDs = new set<ID>();
        map<string, List<string>> mapPMPlanToCov = new map<string, List<string>>();
        
        for(SVMXC__PM_Plan__c PMP: lstPMPlans)
            setPMPlanIDs.add(PMP.Id);
            
        List<SVMXC__PM_Coverage__c> lstPMCov = new List<SVMXC__PM_Coverage__c>();
        lstPMCov = [select id, SVMXC__PM_Plan__c from SVMXC__PM_Coverage__c where SVMXC__PM_Plan__c IN: setPMPlanIDs];
        
        for(SVMXC__PM_Coverage__c PMC : lstPMCov)
        {
            if(!mapPMPlanToCov.containsKey(PMC.SVMXC__PM_Plan__c))
                mapPMPlanToCov.put(PMC.SVMXC__PM_Plan__c, new list<string>());
            mapPMPlanToCov.get(PMC.SVMXC__PM_Plan__c).add(PMC.Id);
        }
        
        
        for(SVMXC__PM_Plan__c PMP: lstPMPlans)
        {
            
            if(PMP.SVMXC__Coverage_Type__c == strCoverageType && activatePMPlan == true)
            {
                
                if((!mapPMPlanToCov.containsKey(PMP.Id) || mapPMPlanToCov.get(PMP.Id) == null || mapPMPlanToCov.get(PMP.Id).size() == 0))
                    PMP.SVMXC__Status__c = 'Incomplete';
                else
                    PMP.SVMXC__Status__c = 'Active';
                    
            }
            else if(activatePMPlan == true)
                PMP.SVMXC__Status__c = 'Active';
            else
                PMP.SVMXC__Status__c = null;
        }
        system.debug(loggingLevel.WARN, 'List of PM Plans after updats are: ' + lstPMPlans);
        
        return lstPMPlans;
    }
    
    // getCoverageType - Input Paramerter :  Field API name for which picklist needs to be retrieved
    // Output: List<SelectOption>
    public PREV_SetupPMPlan_Wrapper.Search_Response getSearchresults(PREV_SetupPMPlan_Wrapper.Search_Request request){
        PREV_SetupPMPlan_Wrapper.Search_Response searchResponseObj = new PREV_SetupPMPlan_Wrapper.Search_Response();
        List<PREV_SetupPMPlan_Wrapper.ObjectInfo>  objectRecList = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
        try{
            string searchtext = request.searchtext+'%';
            
            string field = 'Name';
            
            if(request.objAPIName.equalsIgnoreCase('SVMXC__Installed_Product__c')){
                field += ' ,SVMXC__Product__c'; 
            }
            
            String searchquery= 'SELECT ' + field + ' FROM '+ request.objAPIName + ' WHERE ';
            if(request.whereClause != null){
                searchquery += request.whereClause + ' AND';
            }
            searchquery += ' Name LIKE :searchtext';
            searchquery +=  ' ORDER BY Name ';
            searchquery += ' LIMIT 1000';
            system.debug(searchquery); 
            List<SObject> searchList=Database.query(searchquery);
            searchResponseObj.success = true;
            searchResponseObj.searchText = request.searchText;
            searchResponseObj.objAPIName = request.objAPIName;
            
            Map <string, Sobject> mapIDSearchRecord = new Map <string, SObject>();
            if(searchList != null && searchList.size() >0){
                for(Sobject sobj: searchList){
                    mapIDSearchRecord.put(String.valueOf(sobj.get('Id')), sobj);
                }
            }
            searchResponseObj.mapSearchRecord = mapIDSearchRecord;

            searchResponseObj.searchResponse = recordCombobox(searchList, null); 
        
        }
        catch(Exception ex){
            searchResponseObj.success = false;
            searchResponseObj.messageList.add(ex.getMessage());
        }
        return searchResponseObj;
    }
 
    public List<PREV_SetupPMPlan_Wrapper.ObjectInfo> recordCombobox (List<SObject> objResul, String nameField){
        List<PREV_SetupPMPlan_Wrapper.ObjectInfo> objectRecList = new List<PREV_SetupPMPlan_Wrapper.ObjectInfo>();
        for(SObject lineData: objResul){
            PREV_SetupPMPlan_Wrapper.ObjectInfo objDetail = new PREV_SetupPMPlan_Wrapper.ObjectInfo();
            if(nameField == null || String.isBlank(nameField)){
                nameField = 'name';
            }
            if(!String.isBlank(String.valueOf(lineData.get(nameField)))){
                objDetail = objRecPicklistVal(String.valueOf(lineData.get('id')),String.valueOf(lineData.get(nameField)));
                objectRecList.add(objDetail);
            }
            
        }
        return objectRecList;
    }

    public PREV_SetupPMPlan_Wrapper.ObjectInfo objRecPicklistVal (String id, String name){
        PREV_SetupPMPlan_Wrapper.ObjectInfo objDetail = new PREV_SetupPMPlan_Wrapper.ObjectInfo();
        objDetail.Id = id;
        objDetail.name = name;
        return objDetail;
    }

    //This method returns the list of fields of type Date and Datetime on Work Order object
    //Response will be list of KeyValue(fieldApiName, fieldLabel)
    public List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> getActivityDateFieldList(){
        List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> resultList = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();

        try{
            List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> tempList = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
            Map<String, Schema.SObjectField> workOrderFieldMap = Schema.SObjectType.SVMXC__Service_Order__c.fields.getMap();
            for(string fName : workOrderFieldMap.keySet()){
                Schema.DescribeFieldResult fieldDescribe = workOrderFieldMap.get(fName).getDescribe();
                Schema.Displaytype fieldDataType= fieldDescribe.getType();
                if(fieldDataType == Schema.Displaytype.DateTime || fieldDataType == Schema.Displaytype.Date){
                    SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue objOptionList= new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue();
                    objOptionList.key = fieldDescribe.getName();
                    objOptionList.value = fieldDescribe.getLabel();
                    tempList.add(objOptionList);
                }
            }
            Map<String,List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>> tempLst = new Map<String,List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>>();
            for(SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue SO : tempList) {
                if(!tempLst.containsKey(SO.value.toUpperCase()))
                    tempLst.put(SO.value.toUpperCase(), new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>()); 
                tempLst.get(SO.value.toUpperCase()).add(SO);
            }
            List<String> keys = new List<String>(tempLst.keySet());
            keys.sort();
            for(String value:keys) { 
                resultList.addAll(tempLst.get(value)); 
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception in getActivityDateFieldList method: ' + ex.getMessage());
        }
        System.debug(LoggingLevel.WARN, 'Response of getActivityDateFieldList method: ' + resultList);
        return resultList;
    }

    //This method returns the Field list(Technical attribute(Based on Product selection) and Fields on Installed Product object)
    //Request needs product Id
    //Response will be PM_Plan_Template_Response with list of KeyValue(fieldApi, fieldLabel, dataType)
    public SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response PREV_GetTechnicalAttribute(SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Request request){
        System.debug(LoggingLevel.WARN, 'Request in PREV_GetTechnicalAttribute method : ' + request);

        SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response objResponse = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Plan_Template_Response();
        objResponse.mapOfKeyAndListOfKeyValue = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue>();
        objResponse.messageList = new List<String>();
        objResponse.pmPlanTemplate = new SVMXC.PREV_SetupPMPlan_Wrapper.PM_Template_Detail();
        objResponse.success = false;
        String strProductId = '';
        String strConditionType = '';
        if(request.productId != null && request.productId.length() > 0){
            strProductId = request.productId;
        }
        if(request.pmPlanTemplate != null && request.pmPlanTemplate.conditionType != null && request.pmPlanTemplate.conditionType.length() > 0){
            strConditionType = request.pmPlanTemplate.conditionType;
        }

        try{
            List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> tempListOfFields = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
            Map<String, Schema.SObjectField> installedProductFieldMap = Schema.SObjectType.SVMXC__Installed_Product__c.fields.getMap();
            for(string fName : installedProductFieldMap.keySet()){
                Schema.DescribeFieldResult fieldDescribe = installedProductFieldMap.get(fName).getDescribe();
                Schema.Displaytype fieldDataType= fieldDescribe.getType();
                if(fieldDataType == Schema.Displaytype.Double){
                    SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue objKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue();
                    objKeyValue.key = fieldDescribe.getName();
                    objKeyValue.value = fieldDescribe.getLabel();
                    objKeyValue.dataType = 'Number';
                    objKeyValue.attrType = 'Schema';
                    tempListOfFields.add(objKeyValue);
                }
                if(strConditionType == 'Criteria_Comparison' && (fieldDataType == Schema.Displaytype.Picklist || fieldDataType == Schema.Displaytype.Date || fieldDataType == Schema.Displaytype.String)){
                    SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue objKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue();
                    objKeyValue.key = fieldDescribe.getName();
                    objKeyValue.value = fieldDescribe.getLabel();
                    if(fieldDataType == Schema.Displaytype.String){
                        objKeyValue.dataType = 'TEXT';
                    }
                    else{
                        objKeyValue.dataType = String.valueOf(fieldDataType);
                    }
                    objKeyValue.attrType = 'Schema';
                    if(fieldDataType == Schema.Displaytype.Picklist){
                        List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist> lstKeyValueForPicklist = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist>();

                        List<Schema.PicklistEntry> lstPicklistEntry = fieldDescribe.getPicklistValues();
                        for(Schema.PicklistEntry objPicklistEntry : lstPicklistEntry){
                            if(objPicklistEntry.isActive()){
                                lstKeyValueForPicklist.add(new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist(objPicklistEntry.getLabel(), objPicklistEntry.getValue()));
                            }
                        }
                        objKeyValue.lstValues = lstKeyValueForPicklist;
                    }
                    tempListOfFields.add(objKeyValue);
                }
            }
            //sort the list of fields on Installled Product object
            tempListOfFields = sortListOfKeyValue(tempListOfFields);

            //fetch the list of Fields from Technical Attribute template JSON
            List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> listTechnicalAttribute = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
            if(strProductId != ''){
                listTechnicalAttribute = getTechnicalAttributeFromJson(strProductId, strConditionType);
            }

            SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue objKeyAndListOfKeyValue;

            objKeyAndListOfKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue(getTAG005(),listTechnicalAttribute);
            objResponse.mapOfKeyAndListOfKeyValue.add(objKeyAndListOfKeyValue);

            objKeyAndListOfKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue(getTAG006(),tempListOfFields);
            objResponse.mapOfKeyAndListOfKeyValue.add(objKeyAndListOfKeyValue);

            if(strConditionType == '' || strConditionType == 'Usage_Frequency'){
                List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> listOfDateBasedFields = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
                SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue objDateBasedKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue();
                objDateBasedKeyValue.key = 'Months';
                objDateBasedKeyValue.value = getTAG008();
                objDateBasedKeyValue.dataType = 'Date';
                objDateBasedKeyValue.attrType = 'Date Based';
                listOfDateBasedFields.add(objDateBasedKeyValue);

                objDateBasedKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue();
                objDateBasedKeyValue.key = 'Weeks';
                objDateBasedKeyValue.value = getTAG009();
                objDateBasedKeyValue.dataType = 'Date';
                objDateBasedKeyValue.attrType = 'Date Based';
                listOfDateBasedFields.add(objDateBasedKeyValue);

                objDateBasedKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue();
                objDateBasedKeyValue.key = 'Years';
                objDateBasedKeyValue.value = getTAG010();
                objDateBasedKeyValue.dataType = 'Date';
                objDateBasedKeyValue.attrType = 'Date Based';
                listOfDateBasedFields.add(objDateBasedKeyValue);

                objKeyAndListOfKeyValue = new SVMXC.PREV_SetupPMPlan_Wrapper.KeyAndListOfKeyValue(getTAG007(),listOfDateBasedFields);
                objResponse.mapOfKeyAndListOfKeyValue.add(objKeyAndListOfKeyValue);
            }
            objResponse.success = true;
            objResponse.pmPlanTemplate.conditionType = strConditionType;
        }
        catch(Exception ex){
            objResponse.success = false;
            objResponse.messageList.add(ex.getMessage());
            System.debug(LoggingLevel.WARN, 'Exception in PREV_GetTechnicalAttribute method: ' + ex.getMessage());
            System.debug(LoggingLevel.WARN, 'StackTrace in PREV_GetTechnicalAttribute method: ' + ex.getStackTraceString());
        }
        System.debug(LoggingLevel.WARN, 'Response of PREV_GetTechnicalAttribute method: ' + objResponse);
        return objResponse;
    }

    //method to parse template json and get all the technical attributes associated with the selected product
    public List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> getTechnicalAttributeFromJson(String strProductId, String strConditionType){

        List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> listTechnicalAttribute = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();

        List<SVMXC__SM_Product_Attributes__c> listProductAttribute = [SELECT SVMXC__SM_Attribute_Template_Id__c FROM SVMXC__SM_Product_Attributes__c WHERE SVMXC__SM_Product__c =: strProductId AND SVMXC__SM_Attribute_Template_Id__c != null];
        
        if(listProductAttribute.isEmpty()){
            List<Product2> listProduct = [SELECT SVMXC__Product_Line__c, Family FROM Product2 WHERE Id =: strProductId];
            if(!listProduct.isEmpty()){
                String strProductLine = listProduct[0].SVMXC__Product_Line__c;
                if(strProductLine != null && strProductLine.length() > 0){
                    listProductAttribute = [SELECT SVMXC__SM_Attribute_Template_Id__c FROM SVMXC__SM_Product_Attributes__c WHERE SVMXC__SM_Product_Line__c =: strProductLine AND SVMXC__SM_Attribute_Template_Id__c != null];
                }
                if(listProductAttribute.isEmpty()){
                    String strProductFamily = listProduct[0].Family;
                    if(strProductFamily != null && strProductFamily.length() > 0){
                        listProductAttribute = [SELECT SVMXC__SM_Attribute_Template_Id__c FROM SVMXC__SM_Product_Attributes__c WHERE SVMXC__SM_Product_Family__c =: strProductFamily AND SVMXC__SM_Attribute_Template_Id__c != null];
                    }
                }
            }
        }

        if(!listProductAttribute.isEmpty()){
            String strTemplateId = listProductAttribute[0].SVMXC__SM_Attribute_Template_Id__c;
            List<SVMXC__SM_Attributes_Template__c> listAttributeTemplate = [SELECT SVMXC__SM_Template_Json__c, SVMXC__SM_Picklist_Id__c FROM SVMXC__SM_Attributes_Template__c WHERE Id =: strTemplateId AND SVMXC__SM_Active__c = true];

            if(!listAttributeTemplate.isEmpty()){
                //collect picklist sfId and query those records and then deserialize the value json and create map of Picklist Definition Id and List of Values
                Map<String, List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist>> mapPickDefIdVsListValues = new Map<String, List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist>>();
                if(listAttributeTemplate[0].SVMXC__SM_Picklist_Id__c != null && listAttributeTemplate[0].SVMXC__SM_Picklist_Id__c.length() > 0){

                    List<String> lstPicklistDefId = listAttributeTemplate[0].SVMXC__SM_Picklist_Id__c.split(',');
                    List<SVMXC__SM_TA_Picklist_Definition__c> lstTAPicklistDef = [SELECT Id, SVMXC__SM_Values__c FROM SVMXC__SM_TA_Picklist_Definition__c WHERE Id IN : lstPicklistDefId];
                    
                    for(SVMXC__SM_TA_Picklist_Definition__c objTAPD : lstTAPicklistDef){
                        if(objTAPD.SVMXC__SM_Values__c != null){
                            SVMXC.PREV_SetupPMPlan_Wrapper.TechnicalAttributesPicklistValues objTAPV = (SVMXC.PREV_SetupPMPlan_Wrapper.TechnicalAttributesPicklistValues) JSON.deserialize(objTAPD.SVMXC__SM_Values__c, SVMXC.PREV_SetupPMPlan_Wrapper.TechnicalAttributesPicklistValues.class);

                            List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist> lstKeyValueForPicklist = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist>();
                            for(String strObjValue : objTAPV.values){
                                lstKeyValueForPicklist.add(new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist(strObjValue, strObjValue));
                            }
                            mapPickDefIdVsListValues.put(objTAPD.Id, lstKeyValueForPicklist);
                        }
                    }
                }

                String strTemplateJSON = listAttributeTemplate[0].SVMXC__SM_Template_Json__c;
                if(strTemplateJSON != null){
                    SVMXC.PREV_SetupPMPlan_Wrapper.TechnicalAttributes objTechnicalAttributes = (SVMXC.PREV_SetupPMPlan_Wrapper.TechnicalAttributes) JSON.deserialize(strTemplateJSON, SVMXC.PREV_SetupPMPlan_Wrapper.TechnicalAttributes.class);

                    if(objTechnicalAttributes.fields != null){
                        for(SVMXC.PREV_SetupPMPlan_Wrapper.TechnicalAttributesSections objTecAttrSec : objTechnicalAttributes.fields){
                            if(objTecAttrSec.technicalAttributes != null){
                                for(SVMXC.PREV_SetupPMPlan_Wrapper.TechnicalAttributesFields objTechAttr : objTecAttrSec.technicalAttributes){
                                    if(strConditionType == 'Usage_Frequency' || strConditionType == '' || strConditionType == null){
                                        if(objTechAttr.format == 'Number'){
                                            listTechnicalAttribute.add(new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue(objTechAttr.label, objTechAttr.label, objTechAttr.format, 'Technical'));
                                        }
                                    }
                                    else if(strConditionType == 'Criteria_Comparison'){
                                        if(objTechAttr.format.toUpperCase() == 'PICKLIST'){
                                            List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist> pickValues = (mapPickDefIdVsListValues.size()>0 && mapPickDefIdVsListValues.containsKey(objTechAttr.picklistSfId)) ? mapPickDefIdVsListValues.get(objTechAttr.picklistSfId) : new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValueForPicklist>();
                                            listTechnicalAttribute.add(new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue(objTechAttr.label, objTechAttr.label, objTechAttr.format.toUpperCase(), 'Technical', pickValues));
                                        }
                                        else if(objTechAttr.format.toUpperCase() == 'NUMBER' || objTechAttr.format.toUpperCase() == 'TEXT'){
                                            listTechnicalAttribute.add(new SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue(objTechAttr.label, objTechAttr.label, objTechAttr.format.toUpperCase(), 'Technical'));
                                        }
                                    }
                                }
                            }
                        }
                    }

                    //sort the list of Technical Attribute
                    listTechnicalAttribute = sortListOfKeyValue(listTechnicalAttribute);
                }
            }
        }
        return listTechnicalAttribute;
    }

    //Method for sorting KeyValue list
    public List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> sortListOfKeyValue(List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> listOfFields){
        List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue> sortedListOfFields = new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>();
        Map<String,List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>> tempLst = new Map<String,List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>>();
        for(SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue SO : listOfFields) {
            if(!tempLst.containsKey(SO.value))
                tempLst.put(SO.value, new List<SVMXC.PREV_SetupPMPlan_Wrapper.KeyValue>()); 
            tempLst.get(SO.value).add(SO);
        }
        List<String> keys = new List<String>(tempLst.keySet());
        keys.sort();
        for(String value:keys) { 
            sortedListOfFields.addAll(tempLst.get(value)); 
        }
        return sortedListOfFields;
    }

    //Validate Advance Expression
    public Boolean validateAdvExpression(String advExpr, Integer countOfRules){
        System.debug(LoggingLevel.WARN, 'advExpr in validateAdvExpression method : ' + advExpr);
        System.debug(LoggingLevel.WARN, 'countOfRules in validateAdvExpression method : ' + countOfRules);

        try{
            String strCriteria = advExpr.toUpperCase();
            strCriteria = string.escapeSingleQuotes(strCriteria);
            System.debug(LoggingLevel.WARN, 'Original strCriteria : ' + strCriteria);

            Set<Integer> setAdvExprCount = new Set<Integer>();
            if(strCriteria != null && strCriteria.length() > 0){
                String strTempCriteria = '';

                for(String value : strCriteria.splitByCharacterTypeCamelCase()){
                    String valueAfterTrim = value.trim();

                    if(valueAfterTrim != null && valueAfterTrim.length() > 0){
                        
                        if(valueAfterTrim.isNumeric()){
                            setAdvExprCount.add(Integer.valueOf(valueAfterTrim));
                            valueAfterTrim = '~' + valueAfterTrim + '~';
                        }

                        strTempCriteria += valueAfterTrim + ' ';
                    }
                }
                strCriteria = strTempCriteria;
            }
            System.debug(LoggingLevel.WARN, 'Updated strCriteria: ' + strCriteria);
            System.debug(LoggingLevel.WARN, 'Integer values used in Adv expression are: ' + setAdvExprCount);


            String strQueryWhereClause = strCriteria;
            for(Integer i=0; i<countOfRules; i++)
            {
                if(setAdvExprCount != null && setAdvExprCount.size() > 0 && !setAdvExprCount.contains(i+1)){
                    return false;
                }
                String expr = 'Id != null'; //Changed BillingCity to Id for fixing defect BAC-5093
                strQueryWhereClause = strQueryWhereClause.replace('~' + (i+1) + '~', expr);
            }
            System.debug(LoggingLevel.WARN, 'Parent Object Crit: ' + strQueryWhereClause);

            if(strQueryWhereClause != null && strQueryWhereClause.length() > 0 && strCriteria  != null && strCriteria.length() > 0){
                List<Account> lstAccDummyQuery = Database.query('SELECT Id FROM Account WHERE ' + strQueryWhereClause + ' Limit 0');
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Exception in PREV_GetRecordInfo method: ' + ex.getMessage());
            return false;
        }
        System.debug(LoggingLevel.WARN, 'Valid Advance Expression');
        return true;
    }
    
    //------Added for the defect 046645 fix
    Map<String, SVMXC__ServiceMax_Processes__c> mapHeaderMappingIdRecord = new Map<String, SVMXC__ServiceMax_Processes__c>();
    Map<String, List<SVMXC__ServiceMax_Config_Data__c>> mapHeaderIdFieldMappingRecord = new Map<String, List<SVMXC__ServiceMax_Config_Data__c>>();
    Map<String, List<RecordType>> mapObjectNameRecordTypeList = new Map<String, List<RecordType>>();
    Map<String, Sobject> mapSourceRecIdVsRecord = new Map<String, Sobject>();
    public Map<String,Sobject> getApplyMappingPmPlan(String SFID,map<String,Sobject> SourceRecIdTargetObjMap,Boolean DoPopulateOwner,map<String,Schema.SObjectType> Allobj)
    {
        SVMXC.COMM_Utils commutils = new SVMXC.COMM_Utils();
        System.debug('SourceRecIdTargetObjMap: '+SourceRecIdTargetObjMap.size()+SourceRecIdTargetObjMap);
        Map<String, Schema.SObjectField> FieldMap = new Map<String, Schema.SObjectField>();
        Map<String, Schema.SObjectField> mapTargetFieldDesc = new Map<String, Schema.SObjectField>();
        Map<String,Sobject> mapFinalSourceRecIdTargetObj = new Map<String,Sobject>();
        Set<String> SourceRecIds = new Set<String>();
        map<String,Sobject> SourceRecMap = new map<String,Sobject>(); 
        if(SourceRecIdTargetObjMap.size() > 0)
        {
            for(String s : SourceRecIdTargetObjMap.keyset())
            {
                SourceRecIds.add(s);
            }
        }
        SVMXC__ServiceMax_Processes__c MapHeader = new SVMXC__ServiceMax_Processes__c();
        if(mapHeaderMappingIdRecord.size() > 0 && mapHeaderMappingIdRecord.containsKey(SFID)){
            System.debug('Found MapHeader');
            MapHeader = mapHeaderMappingIdRecord.get(SFID);
        }
        else{
            System.debug('Queried MapHeader');
            MapHeader = [SELECT Id, SVMXC__Target_Object_Name__c, SVMXC__Source_Object_Name__c FROM SVMXC__ServiceMax_Processes__c  WHERE Id =: SFID];
            mapHeaderMappingIdRecord.put(SFID, MapHeader);
        }
        system.debug('MapHeader: '+MapHeader);
        
        List<SVMXC__ServiceMax_Config_Data__c> FieldMappingList = new List<SVMXC__ServiceMax_Config_Data__c>(); 
        if(MapHeader != null && MapHeader.id != null)
        {
            if(mapHeaderIdFieldMappingRecord.size() > 0 && mapHeaderIdFieldMappingRecord.containsKey(MapHeader.id)){
                System.debug('Found FieldMappingList');
                FieldMappingList = mapHeaderIdFieldMappingRecord.get(MapHeader.id);
            }
            else{
                System.debug('Queried FieldMappingList');
                FieldMappingList = [SELECT Id, SVMXC__Target_Field_Name__c, SVMXC__Source_Field_Name__c, SVMXC__Preference_2__c, SVMXC__Preference_3__c, SVMXC__Display_Value__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__MapID__c =: MapHeader.id];
                mapHeaderIdFieldMappingRecord.put(MapHeader.id, FieldMappingList);
            }
        }
        System.debug('FieldMappingList: '+FieldMappingList.size()+FieldMappingList);
        
        set<String> TargetFieldsSet = new set<String>();
        Set<String> sourceFieldsSet = new Set<String>(); //Added for fixing defect 045064
        if(!(FieldMappingList.isEmpty()))
        {
            for(SVMXC__ServiceMax_Config_Data__c configData : FieldMappingList)
            {
                if(configData.SVMXC__Target_Field_Name__c != null)
                    TargetFieldsSet.add(configData.SVMXC__Target_Field_Name__c);

                //-----Start------Added for fixing defect 045064------------//
                if(configData.SVMXC__Source_Field_Name__c != null)
                    sourceFieldsSet.add(configData.SVMXC__Source_Field_Name__c);
                if(configData.SVMXC__Preference_2__c != null)
                    sourceFieldsSet.add(configData.SVMXC__Preference_2__c);
                if(configData.SVMXC__Preference_3__c != null)
                    sourceFieldsSet.add(configData.SVMXC__Preference_3__c);
                //------End-----Added for fixing defect 045064------------//
            }
        }
        System.debug('sourceFieldsSet: '+sourceFieldsSet);
        //Get the Target object Fields 
        if(MapHeader.SVMXC__Target_Object_Name__c != null && Allobj.containskey(MapHeader.SVMXC__Target_Object_Name__c))
        {
            map<String, Schema.SObjectField> LFieldMap = new map<String, Schema.SObjectField>();
            LFieldMap = Allobj.get(MapHeader.SVMXC__Target_Object_Name__c).getDescribe().fields.getMap();
            if(LFieldMap.size() > 0)
            {
                for(String s : LFieldMap.keyset())
                {
                    mapTargetFieldDesc.put(LFieldMap.get(s).getDescribe().getName(),LFieldMap.get(s));
                }
            }
        }  
        System.debug('mapTargetFieldDesc: '+mapTargetFieldDesc);    
        //Get the Source Records...
        list<Sobject> SourceObjRecordlist = new list<Sobject>();
        
        if(mapSourceRecIdVsRecord.size() > 0 && mapSourceRecIdVsRecord.keyset().containsAll(SourceRecIds)){
            System.debug('Found SourceRecord');
            SourceObjRecordlist = mapSourceRecIdVsRecord.values();
        }
        else if(MapHeader.SVMXC__Source_Object_Name__c != null && Allobj.containskey(MapHeader.SVMXC__Source_Object_Name__c)) {
            //Added this if condition block for fixing defect 045064 - to avoid querying all the fields of source object and ass a result it will reduce heap memory
            String fields = '';
            if(sourceFieldsSet != null && sourceFieldsSet.size() > 0){
                List<String> lstSourceFields = new List<String>();
                lstSourceFields.addAll(sourceFieldsSet);
                fields = commutils.SVMX_getFieldNamesFromList(lstSourceFields);
            }
            else{
                List<String> fieldlist = new List<String>();
                FieldMap = Allobj.get(MapHeader.SVMXC__Source_Object_Name__c).getDescribe().fields.getMap();
                if(FieldMap.size() > 0)
                    fieldlist = commutils.SVMX_getFieldList(FieldMap,true);
                if(fieldlist.size() > 0)
                    fields = commutils.SVMX_getFieldNamesFromList(fieldlist); 
            }

            if(fields != null && fields.length() > 0 && SourceRecIds != null && SourceRecIds.size() > 0)
            {
                String Query = 'SELECT ' + fields + ' FROM ' + MapHeader.SVMXC__Source_Object_Name__c + ' WHERE Id  IN: SourceRecIds';
                System.debug('Query: '+Query);               
                SourceObjRecordlist = Database.query(Query);
                System.debug('Queried SourceRecord');
                for(Sobject sobj: SourceObjRecordlist){
                    mapSourceRecIdVsRecord.put(String.valueOf(sobj.get('Id')), sobj);
                }
            }
        }
        if(MapHeader.SVMXC__Target_Object_Name__c != null && MapHeader.SVMXC__Target_Object_Name__c.length() > 0 && Allobj.containskey(MapHeader.SVMXC__Target_Object_Name__c)){
            map<String, Schema.SObjectField> mapFieldDesc = Allobj.get(MapHeader.SVMXC__Target_Object_Name__c).getDescribe().fields.getMap();
            if(mapFieldDesc.size() > 0){
                for(String str : mapFieldDesc.keyset()){
                    mapTargetFieldDesc.put(mapFieldDesc.get(str).getDescribe().getName(),mapFieldDesc.get(str));
                }
            }
        }
        system.debug('SourceObjRecordlist'+SourceObjRecordlist);
        if(SourceObjRecordlist.size() > 0 && SourceRecIdTargetObjMap.size() > 0)
        {
            for(Integer i = 0;i<SourceObjRecordlist.size();i++)
            {
                if(SourceObjRecordlist[i].get('id') != null && SourceRecIdTargetObjMap.containskey(String.valueof(SourceObjRecordlist[i].get('id'))))
                    SourceRecMap.put(String.valueof(SourceObjRecordlist[i].get('id')),SourceObjRecordlist[i]);
            }
        }
        system.debug('SourceRecMap'+SourceRecMap);
        if(SourceRecIdTargetObjMap.size() > 0 && FieldMappingList.size() > 0 && SourceRecMap.size() > 0)
        {
            
            List<RecordType> RecordtypeLst = new List<RecordType>();
            if(MapHeader.SVMXC__Target_Object_Name__c != null)
            {
                if(mapObjectNameRecordTypeList.size() > 0 && mapObjectNameRecordTypeList.containsKey(MapHeader.SVMXC__Target_Object_Name__c)){
                    System.debug('Found RecordtypeLst');
                    RecordtypeLst = mapObjectNameRecordTypeList.get(MapHeader.SVMXC__Target_Object_Name__c);
                }
                else{
                    RecordtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType =: MapHeader.SVMXC__Target_Object_Name__c];
                    mapObjectNameRecordTypeList.put(MapHeader.SVMXC__Target_Object_Name__c, RecordtypeLst);
                    System.debug('Queried RecordtypeLst');
                }
            }
            system.debug('RecordtypeLst: '+RecordtypeLst);
            for(String s1 : SourceRecIdTargetObjMap.keyset())
            {
                Sobject Sobj = SourceRecIdTargetObjMap.get(s1);
                system.debug('TargetRecord : '+Sobj);
                Sobject SourceObjRecord;
                if(SourceRecMap.containskey(s1))
                    SourceObjRecord = SourceRecMap.get(s1);
                if(DoPopulateOwner && TargetFieldsSet.size() > 0 && TargetFieldsSet.contains('OwnerId') == false && mapTargetFieldDesc.containskey('OwnerId'))
                {
                    Sobj.put('OwnerId',Userinfo.getUserId());
                }
                //check for the value map
                if(MapHeader.SVMXC__Source_Object_Name__c == null)
                {
                    system.debug('Enter for the value map');
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && FieldMappingList[j].SVMXC__Display_Value__c != null)
                            Sobj.put(FieldMappingList[j].SVMXC__Source_Field_Name__c,FieldMappingList[j].SVMXC__Display_Value__c);
                    }
                }
                //Field Map
                if(MapHeader.SVMXC__Source_Object_Name__c != null)
                {
                    system.debug('Enter for the field map');
                    for(Integer j = 0;j<FieldMappingList.size();j++)
                    {
                        if(FieldMappingList[j].SVMXC__Target_Field_Name__c != null)
                        {
                            system.debug('asdfgh'+FieldMappingList[j].SVMXC__Target_Field_Name__c);
                            if(FieldMappingList[j].SVMXC__Target_Field_Name__c == 'RecordTypeId')
                            {
                                system.debug('Display Val: '+FieldMappingList[j].SVMXC__Display_Value__c+' SourceFieldName :'+FieldMappingList[j].SVMXC__Source_Field_Name__c);
                                if(FieldMappingList[j].SVMXC__Display_Value__c != null)
                                {
                                    String RecordTypeId = '';
                                    if(RecordtypeLst.size() > 0)
                                    {
                                        for(RecordType r : RecordtypeLst)
                                        {
                                            if(FieldMappingList[j].SVMXC__Display_Value__c != null && r.Name.touppercase() == FieldMappingList[j].SVMXC__Display_Value__c.touppercase())
                                                RecordTypeId = r.id;
                                        }
                                    } 
                                    system.debug('Its Record Type'+RecordTypeId); 
                                    if(RecordTypeId != null && RecordTypeId.length() > 0)
                                        Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,RecordTypeId);
                                }
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) !=  null)
                                {
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)));
                                }        
                            }
                            else
                            {
                                system.debug('Its not Record Type'+FieldMappingList[j].SVMXC__Source_Field_Name__c + 'Source Object Record: ' + SourceObjRecord);
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c)) != null)
                                {   
                                    system.debug('Entered in first'+ FieldMappingList[j].SVMXC__Target_Field_Name__c+' : '+FieldMappingList[j].SVMXC__Source_Field_Name__c + ' : '+SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) != null)
                                {
                                    system.debug('Entered in second');
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c));
                                }    
                                else if(FieldMappingList[j].SVMXC__Source_Field_Name__c != null && SourceObjRecord.get(FieldMappingList[j].SVMXC__Source_Field_Name__c) == null && FieldMappingList[j].SVMXC__Preference_2__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_2__c)) == null && FieldMappingList[j].SVMXC__Preference_3__c != null && String.valueof(SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c)) != null)
                                {
                                    system.debug('Entered in third');
                                    Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,SourceObjRecord.get(FieldMappingList[j].SVMXC__Preference_3__c));
                                }    
                                if(FieldMappingList[j].SVMXC__Source_Field_Name__c  == null && FieldMappingList[j].SVMXC__Preference_2__c == null  && FieldMappingList[j].SVMXC__Preference_3__c == null && FieldMappingList[j].SVMXC__Display_Value__c != null && mapTargetFieldDesc.containskey(FieldMappingList[j].SVMXC__Target_Field_Name__c))
                                {
                                    //Desctibe the field to check differen attributes of fields..
                                    Schema.DescribeFieldResult f = mapTargetFieldDesc.get(FieldMappingList[j].SVMXC__Target_Field_Name__c).getDescribe();
                                    if((f.getType() == schema.Displaytype.Double  || f.getType() == schema.Displaytype.Percent || f.getType() == schema.Displaytype.Currency)&& f.isCreateable())//if Field Type is Double,persent,currency 
                                    {
                                        if(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c) != null )
                                        {
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(double.valueOf(FieldMappingList[j].SVMXC__Display_Value__c)));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Integer && f.isCreateable())//if field type is Integer
                                    {
                                        if(Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                        {
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Integer.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.Boolean && f.isCreateable())//if field type is Boolean
                                    {
                                        if(Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c)!= null)
                                        {
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Boolean.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }   
                                    }
                                    else if(f.getType() == schema.Displaytype.DateTime && f.isCreateable())//if field type is DateTime
                                    {
                                        system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            system.debug('Enterd for Today');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today(), time.newInstance(0, 0, 0, 0)));
                                        }   
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            system.debug('Enterd for YESTERDAY');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()-1, time.newInstance(0, 0, 0, 0)));
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,datetime.newInstance(system.today()+1, time.newInstance(0, 0, 0, 0)));
                                        }
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'NOW')
                                        {
                                            system.debug('Enterd for NOW');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.now());
                                        }
                                        else
                                        {           
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,DateTime.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }
                                                
                                    }
                                    else if(f.getType() == schema.Displaytype.Date && f.isCreateable())//if field type is Date
                                    {
                                        system.debug('asdf'+FieldMappingList[j].SVMXC__Display_Value__c);
                                        if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TODAY')
                                        {
                                            system.debug('Enterd for Today');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today());
                                        }   
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'YESTERDAY')
                                        {
                                            system.debug('Enterd for YESTERDAY');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() - 1);
                                        }       
                                        else if(FieldMappingList[j].SVMXC__Display_Value__c.touppercase() == 'TOMORROW')
                                        {
                                            system.debug('Enterd for TOMORROW');
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,system.today() + 1);
                                        }
                                        else
                                        {           
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,Date.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }
                                    }
                                    else if(f.getType() == schema.Displaytype.MultiPicklist && f.isCreateable())//if field type is MultiPicklist
                                    {
                                        if(String.valueof(FieldMappingList[j].SVMXC__Display_Value__c) != null)
                                        {
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,String.valueof(FieldMappingList[j].SVMXC__Display_Value__c));
                                        }
                                    }
                                    else //else field type is REFERENCE,String 
                                    {
                                        if((String)FieldMappingList[j].SVMXC__Display_Value__c != null && f.isCreateable())
                                        {
                                            Sobj.put(FieldMappingList[j].SVMXC__Target_Field_Name__c,(String)FieldMappingList[j].SVMXC__Display_Value__c);
                                        }
                                    }
                                }   
                            }       
                        }
                    }       
                }
                mapFinalSourceRecIdTargetObj.put(s1,Sobj);   
            }
        }
        system.debug('mapFinalSourceRecIdTargetObj: '+mapFinalSourceRecIdTargetObj);      
        return mapFinalSourceRecIdTargetObj;
    }
    
    public String getTAG001() {return system.label.PREV001_TAG024;} //'PM Plan Template not found.' 
    public String getTAG002() {return system.label.PREV001_TAG025;} // 'Request is not complete to process further.'
    public String getTAG004() {return system.label.PREV001_TAG026;} // 'PM Plans are not available to process.'
    public String getTAG005(){return System.Label.PREV004_TAG030;} //Technical Attribute
    public String getTAG006(){return System.Label.PREV004_TAG031;} //IB field
    public String getTAG007(){return System.Label.PREV004_TAG049;} //Date Based
    public String getTAG008(){return System.Label.PREV004_TAG036;} //Months
    public String getTAG009(){return System.Label.PREV004_TAG035;} //Weeks
    public String getTAG010(){return System.Label.PREV004_TAG037;} //Years
}