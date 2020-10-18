/* Security Scanned */
public with sharing class WORD_OutboundRouting
{
    public List<SVMXC__ServiceMax_Processes__c> outboundProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    public List<SVMXC__ServiceMax_Processes__c> lstExp = new List<SVMXC__ServiceMax_Processes__c>();
    //public List<SVMXC__ServiceMax_Processes__c> lstRuleProcess = new List<SVMXC__ServiceMax_Processes__c>(); //Commented as lstRuleProcess is not used anywhere -BAC-4367
    public List<SVMXC__ServiceMax_Config_Data__c> lstLocConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
    public List<SVMXC__RMA_Shipment_Line__c> lstPOLine = new List<SVMXC__RMA_Shipment_Line__c>();
    public List<SVMXC__Route_Card__c> lstInboundRouteCard = new List<SVMXC__Route_Card__c>();
    public Set<ID> lstLocations = new Set<ID>();
    public List<SVMXC__Service_Order__c> lstWO = new List<SVMXC__Service_Order__c>();
    //public Map<string,string> mapExpIdToProId = new Map<string,string>();
    public Map<string,string> mapProIdToExpId = new Map<string,string>();
    public Map<string,List<string>> mapLocIdToWOId = new Map<string,List<string>>();
    public Map<string,string> mapProIdToLocId = new Map<string,string>();
    public Map<string,string> mapExpIdToWhereClause = new Map<string,string>();
    public Map<string,string> mapWOIdToWhereClause = new Map<string,string>();
    public Map<string, string> mapPOLineIDRouteRuleID = new Map<string, string>();
    public Map<string, List<SVMXC__ServiceMax_Config_Data__c>> mapRouteRuleIDToLstConfData = new Map<string, List<SVMXC__ServiceMax_Config_Data__c>>();
    public List<SVMXC__Route_Card__c> lstRouteCard = new List<SVMXC__Route_Card__c>();
    public List<SVMXC__Route_Stop__c> lstRouteStop = new List<SVMXC__Route_Stop__c>();
    public List<string> lstPOLineID = new List<string>();
    public Set<ID> lstNodeParentCri = new Set<ID>();
    public List<string> lstRouteRuleID = new List<string>();
    public Map<string,string> mapCardToStop = new Map<string,string>();
    public Map<string,string> mapPOLineToCard = new Map<string,string>();
    public Map<string,SVMXC__Route_Card__c> mapPOLineIDToInboundCard = new Map<string,SVMXC__Route_Card__c>();
    
    public WORD_OutboundRouting(Set<ID> lstWOID)
    {
        system.debug('List of WO Updated Ids are: ' + lstWOID);
        //querying the WO updated
        lstWO = [select Id, SVMXC__Company__c, SVMXC__Company__r.Name, SVMXC__Master_Order_Line__c, SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c, SVMXC__Product__c, SVMXC__Product__r.Name from SVMXC__Service_Order__c where Id IN: lstWOID and  SVMXC__Master_Order_Line__c != null and SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c != null and (SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Fulfillment_Type__c = 'Repair' OR SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Fulfillment_Type__c = 'Sales') and SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__On_Hold__c != true and SVMXC__Master_Order_Line__r.SVMXC__Route_Card__c != null and SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c != null and SVMXC__Product__c != null and SVMXC__Company__c !=null and SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Route_Type__c = 'Inbound'];
        system.debug('List of WO Updated: ' + lstWO + ' and size is: ' + lstWO.size());
        
        if(lstWO != null && lstWO.size() > 0)
        {
            for(SVMXC__Service_Order__c WO: lstWO)
            {
                if(WO.SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c != null)
                {
                    lstLocations.add(WO.SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c);
                    
                    if(mapLocIdToWOId.get(WO.SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c) == null || mapLocIdToWOId.get(WO.SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c).size() == 0)
                    {
                        List<string> tempLstWOID = new List<string>();
                        tempLstWOID.add(WO.Id);
                        mapLocIdToWOId.put(WO.SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c, tempLstWOID);
                    }
                    else
                        mapLocIdToWOId.get(WO.SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c).add(WO.Id);
                }
            }
        
            system.debug('List of depots: ' + lstLocations);
            // Getting the Active Outbound Rules with the same Locations as in the current stop of the route card of the master Order Line
            if(lstLocations != null && lstLocations.size() > 0)
                //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                outboundProcessLst = [select id, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Process__c, SVMXC__Rule_Type__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name,  SVMXC__Location__r.Id, SVMXC__Active__c, SVMXC__Node_Parent__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Outbound Route Calculation' and SVMXC__Rule_Type__c ='Outbound Route Calculation' and SVMXC__Active__c = true and SVMXC__Location__c IN: lstLocations and SVMXC__Node_Parent__c != null];
            system.debug('Active Outbounds found: ' + outboundProcessLst + ' and size is: ' + outboundProcessLst.size());
            
            if(outboundProcessLst != null && outboundProcessLst.size() > 0)
            {
                for(SVMXC__ServiceMax_Processes__c pro : outboundProcessLst)
                {
                    //mapExpIdToProId.put(pro.SVMXC__Node_Parent__c, pro.Id);
                    mapProIdToExpId.put(pro.Id, pro.SVMXC__Node_Parent__c);
                    mapProIdToLocId.put(pro.Id, pro.SVMXC__Location__c);
                    lstNodeParentCri.add(pro.SVMXC__Node_Parent__c);
                }
                // Getting the expressions for the WO to Qualify
                if(lstNodeParentCri != null && lstNodeParentCri.size() > 0)
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstExp = [Select Id, Name,SVMXC__Parent_Object_Criteria__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = 'SVMX Rule' AND Id IN :lstNodeParentCri];
                system.debug('Exp found: ' + lstExp + ' and size is: ' + lstExp.size());
                
                if(lstExp != null && lstExp.size() != 0)
                    for(SVMXC__ServiceMax_Processes__c exp : lstExp)
                        mapExpIdToWhereClause.put(exp.Id, exp.SVMXC__Parent_Object_Criteria__c);
                for(SVMXC__ServiceMax_Processes__c pro : outboundProcessLst)
                {
                    string ExpId = '';
                    string tempWhereClause = '';
                    string tempLocId = '';
                    ExpId = mapProIdToExpId.get(pro.Id);
                    if(ExpId != null && ExpId != '' && ExpId.length()>0)
                        tempWhereClause = mapExpIdToWhereClause.get(ExpId);
                    tempLocId = mapProIdToLocId.get(pro.Id);
                    if(tempLocId != null && tempLocId != '' && tempLocId.length() > 0)
                    {
                        List<string> tempLstWOId = new List<string>();
                        tempLstWOId = mapLocIdToWOId.get(tempLocId);
                        if(tempLstWOId != null && tempLstWOId.size() > 0)
                        {
                            for(string tempWOId: tempLstWOId)
                                mapWOIdToWhereClause.put(tempWOId, tempWhereClause);
                        }
                    }
                }
                integer i = 0;
                String bigWhereClause = '';
                
                if(mapWOIdToWhereClause != null && mapWOIdToWhereClause.size() != 0)
                {
                    string ClauseToAdd = '';
                    for(string WOId : mapWOIdToWhereClause.keySet())
                    {
                        if(i == 0)
                            bigWhereClause += '((Id = \'' + WOId + '\'';
                        else
                            bigWhereClause += 'OR (Id = \'' + WOId + '\'';
                        i++;
                        ClauseToAdd = mapWOIdToWhereClause.get(WOId);
                        if(ClauseToAdd != null && ClauseToAdd != '')
                            bigWhereClause +=  ' and (' + ClauseToAdd + ')';
                        bigWhereClause += ')';
                    }
                    bigWhereClause += ')';
                }
                system.debug('Big Where Clause Created: ' + bigWhereClause);
                
                if(bigWhereClause.length() > 0)
                {
                    //Querying all the Qualified WOs
                    lstWO.clear();
                    string SOQL = 'select Id, SVMXC__Company__c, SVMXC__Company__r.Name, SVMXC__Company__r.Id, SVMXC__Master_Order_Line__c, SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Product__r.Id, SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c, SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__c, SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id from SVMXC__Service_Order__c where ' + bigWhereClause + ' and SVMXC__Master_Order_Line__c != null and SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c != null and (SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Fulfillment_Type__c = \'Repair\' OR SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Fulfillment_Type__c = \'Sales\') and SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__On_Hold__c != true and SVMXC__Master_Order_Line__r.SVMXC__Route_Card__c != null and SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c != null and SVMXC__Product__c != null and SVMXC__Company__c !=null and SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Route_Type__c = \'Inbound\'';
                    
                    system.debug('SOQL created: ' + SOQL);
                    
                    lstWO = database.query(SOQL);
                    system.debug('qualified WO: ' + lstWO + ' and the size is: ' + lstWO.size());
                    if(lstWO != null && lstWO.size() != 0)
                        for(SVMXC__Service_Order__c WO : lstWO)
                            lstPOLineID.add(WO.SVMXC__Master_Order_Line__r.Id);
                    system.debug('List of Parts Order Line IDs: ' + lstPOLineID + ' and the size is: ' + lstPOLineID.size());
                    
                    APL_RoutingEngine routeEngine = new APL_RoutingEngine();
                    
                    //Getting all the Inbound Route Cards for all the Master Order Line
                    lstInboundRouteCard = [select id, SVMXC__RMA_Line__c, SVMXC__Current_Stop__c, SVMXC__RMA__c, SVMXC__Status__c, SVMXC__Route_Type__c, SVMXC__Customer__c  from SVMXC__Route_Card__c where SVMXC__RMA_Line__c IN: lstPOLineID and SVMXC__Route_Type__c = 'Inbound'];
                    system.debug('List of Inbound Route Cards queried: ' + lstInboundRouteCard + ' and the size is: ' + lstInboundRouteCard.size());
                    if(lstInboundRouteCard != null && lstInboundRouteCard.size() > 0)
                        for(SVMXC__Route_Card__c RC : lstInboundRouteCard)
                            mapPOLineIDToInboundCard.put(RC.SVMXC__RMA_Line__c, RC);
                    system.debug('Map of POLine to Inbound Route Card: ' + mapPOLineIDToInboundCard + ' and the size is: ' + mapPOLineIDToInboundCard.size());
                    
                    //querying all the Master Order Lines
                    lstPOLine.clear();
                    if(lstPOLineID != null && lstPOLineID.size() > 0)
                        lstPOLine = [select id, SVMXC__Product__c, SVMXC__RMA_Shipment_Order__c, SVMXC__RMA_Shipment_Order__r.Id, SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__c, SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id, SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Name, SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Name, SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id from SVMXC__RMA_Shipment_Line__c where Id IN: lstPOLineID];
                    system.debug('List of Master Order Lines queried: ' + lstPOLine + ' and the size is: ' + lstPOLine.size());
                    
                    if(lstWO != null && lstWO.size() != 0)
                    {
                        for(SVMXC__Service_Order__c WO : lstWO)
                        {
                            List<INTF_WebServicesDef.SVMXMap> lstSVMXMapForRequest = new List<INTF_WebServicesDef.SVMXMap>();
                            INTF_WebServicesDef.SVMXMap svmxMap1 = new INTF_WebServicesDef.SVMXMap('RouteType', 'Outbound');
                            lstSVMXMapForRequest.add(svmxMap1);
                            
                            if(WO.SVMXC__Product__c != null)
                            {
                                INTF_WebServicesDef.SVMXMap svmxMap2 = new INTF_WebServicesDef.SVMXMap('ProductID', WO.SVMXC__Product__r.Id);
                                lstSVMXMapForRequest.add(svmxMap2);
                            }
                            if(WO.SVMXC__Company__c != null)
                            {
                                INTF_WebServicesDef.SVMXMap svmxMap3 = new INTF_WebServicesDef.SVMXMap('AccountID', WO.SVMXC__Company__r.Id);
                                lstSVMXMapForRequest.add(svmxMap3);
                            }
                            if(WO.SVMXC__Master_Order_Line__c != null)
                            {
                                if(WO.SVMXC__Master_Order_Line__r.SVMXC__Route_Card__c != null)
                                {
                                    if(WO.SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c != null)
                                    {
                                        INTF_WebServicesDef.SVMXMap svmxMap4 = new INTF_WebServicesDef.SVMXMap('LocationID', WO.SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Current_Stop__c);
                                        lstSVMXMapForRequest.add(svmxMap4);
                                    }
                                }
                            }
                            
                            system.debug('List of SVMX Map for the request: ' + lstSVMXMapForRequest + ' and the size is: ' + lstSVMXMapForRequest.size());
                            
                            INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
                            request.valueMap = lstSVMXMapForRequest;
                            string strRouteRuleID;
                            INTF_WebServicesDef.INTF_SFMResponse response = routeEngine.APL_GetRouteInfo(request);
                            
                            system.debug('response: ' + response + ' and the success: ' + response.success);
                            
                            if(response.success == true)
                            {
                                List<INTF_WebServicesDef.SVMXMap> objRuleInfo = new List<INTF_WebServicesDef.SVMXMap>();
                                objRuleInfo = response.valueMap;
                                for(INTF_WebServicesDef.SVMXMap objTemp : objRuleInfo)
                                {
                                    if(objTemp.key == 'RouteID')
                                        strRouteRuleID = objTemp.value;
                                    if(strRouteRuleID != '-1' && strRouteRuleID != null)
                                    {
                                        lstRouteRuleID.add(strRouteRuleID);
                                        mapPOLineIDRouteRuleID.put(WO.SVMXC__Master_Order_Line__r.Id, strRouteRuleID);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    //lstRuleProcess = [Select Id, SVMXC__APL_Route_Rule_Type__c From SVMXC__ServiceMax_Processes__c where Id IN : lstRouteRuleID and SVMXC__Record_Type_Name__c ='SVMX Rule' and SVMXC__Rule_Type__c = 'Routing Rule']; //Commented as lstRuleProcess is not used anywhere -BAC-4367
                    //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
                    lstLocConfigData = [Select SVMXC__Sequence__c, SVMXC__Location__c, SVMXC__Dispatch_Process__c, SVMXC__RecordType_Name__c, RecordTypeId, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN : lstRouteRuleID and SVMXC__RecordType_Name__c ='Route Stops' Order By SVMXC__Sequence__c];
                    if(lstLocConfigData != null && lstLocConfigData.size() > 0)
                    {
                        for(SVMXC__ServiceMax_Config_Data__c confData : lstLocConfigData)
                        {
                            List<SVMXC__ServiceMax_Config_Data__c> tempLstConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
                            tempLstConfData = mapRouteRuleIDToLstConfData.get(confData.SVMXC__Dispatch_Process__c);
                            if(tempLstConfData == null)
                                tempLstConfData = new List<SVMXC__ServiceMax_Config_Data__c>();
                            tempLstConfData.add(confData);
                            mapRouteRuleIDToLstConfData.put(confData.SVMXC__Dispatch_Process__c, tempLstConfData);
                        }
                    }
                    
                    if(lstWO != null && lstWO.size() != 0)
                    {
                        for(SVMXC__Service_Order__c WO : lstWO)
                        {
                            string ruleId = mapPOLineIDRouteRuleID.get(WO.SVMXC__Master_Order_Line__r.Id);
                            if(ruleId != null)
                            {
                                List<SVMXC__ServiceMax_Config_Data__c> tempLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                                tempLst = mapRouteRuleIDToLstConfData.get(ruleId);
                                
                                SVMXC__Route_Card__c inboundRC = new SVMXC__Route_Card__c();
                                inboundRC = mapPOLineIDToInboundCard.get(WO.SVMXC__Master_Order_Line__r.Id);
                                
                                SVMXC__Route_Card__c objRouteCard = new SVMXC__Route_Card__c();
                                objRouteCard = new SVMXC__Route_Card__c();
                                objRouteCard.SVMXC__RMA__c = WO.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c;
                                objRouteCard.SVMXC__RMA_Line__c = WO.SVMXC__Master_Order_Line__c;
                                objRouteCard.SVMXC__Route_Type__c = 'Outbound';
                                if(tempLst != null && inboundRC != null && tempLst[0].SVMXC__Location__c == inboundRC.SVMXC__Current_Stop__c && tempLst.size()>0)
                                {
                                    objRouteCard.SVMXC__First_Stop__c = tempLst[0].SVMXC__Location__c;
                                    objRouteCard.SVMXC__Current_Stop__c = tempLst[0].SVMXC__Location__c;
                                    if(tempLst.size()>1)
                                        objRouteCard.SVMXC__Next_Stop__c = tempLst[1].SVMXC__Location__c;
                                    else
                                        objRouteCard.SVMXC__Next_Stop__c = tempLst[0].SVMXC__Location__c;
                                    objRouteCard.SVMXC__Last_Stop__c = tempLst[integer.valueOf(tempLst.size() - 1 )].SVMXC__Location__c;
                                }
                                else if(tempLst != null && inboundRC != null && tempLst[0].SVMXC__Location__c != inboundRC.SVMXC__Current_Stop__c && tempLst.size()>0)
                                {
                                    objRouteCard.SVMXC__First_Stop__c = inboundRC.SVMXC__Current_Stop__c;
                                    objRouteCard.SVMXC__Current_Stop__c = inboundRC.SVMXC__Current_Stop__c;
                                    objRouteCard.SVMXC__Next_Stop__c = tempLst[0].SVMXC__Location__c;
                                    objRouteCard.SVMXC__Last_Stop__c = tempLst[integer.valueOf(tempLst.size() - 1 )].SVMXC__Location__c;
                                }
                                objRouteCard.SVMXC__Status__c = 'Open';
                                objRouteCard.SVMXC__Customer__c = WO.SVMXC__Company__r.Id;
                                lstRouteCard.add(objRouteCard);
                            }
                            else
                            {
                                SVMXC__Route_Card__c inboundRC = new SVMXC__Route_Card__c();
                                inboundRC = mapPOLineIDToInboundCard.get(WO.SVMXC__Master_Order_Line__r.Id);
                                SVMXC__Route_Card__c objRouteCard = new SVMXC__Route_Card__c();
                                objRouteCard.SVMXC__RMA__c = WO.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c;
                                objRouteCard.SVMXC__RMA_Line__c = WO.SVMXC__Master_Order_Line__r.Id;
                                if(WO.SVMXC__Master_Order_Line__c != null && WO.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c != null && WO.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__c != null)
                                {
                                    objRouteCard.SVMXC__Current_Stop__c = inboundRC.SVMXC__Current_Stop__c;//WO.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id;
                                    objRouteCard.SVMXC__First_Stop__c = inboundRC.SVMXC__Current_Stop__c;//WO.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id;
                                    objRouteCard.SVMXC__Last_Stop__c = WO.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id;
                                }
                                objRouteCard.SVMXC__Status__c = 'Open';
                                objRouteCard.SVMXC__Route_Type__c = 'Outbound';
                                objRouteCard.SVMXC__Customer__c = WO.SVMXC__Company__r.Id;
                                lstRouteCard.add(objRouteCard);
                            }
                        }
                    }
                    
                    system.debug('List of Route Cards to be created: ' + lstRouteCard + ' and the size is: ' + lstRouteCard.size());
                    
                    if(lstRouteCard != null && lstRouteCard.size() > 0)
                    {
                        //upsert lstRouteCard;
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRouteCard, COMM_SecurityUtils.Access.Upsertable ) ) {
                            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                            upsert lstRouteCard;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                        integer intCarCnt = 0;
                        SVMXC__Route_Stop__c objRouteStop = new SVMXC__Route_Stop__c();
                        while(intCarCnt < lstRouteCard.size())
                        {
                            integer intPrevCarCnt = -1;
                            //mapWOIDToRouteCardID.put(lstRouteCard[intCarCnt].SVMXC__RMA_Line__c, lstRouteCard[intCarCnt].Id);
                            List<SVMXC__ServiceMax_Config_Data__c> tempLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                            string ruleId = mapPOLineIDRouteRuleID.get(lstRouteCard[intCarCnt].SVMXC__RMA_Line__c);
                            
                            system.debug('Rule ID: ' + ruleId);
                            
                            tempLst = mapRouteRuleIDToLstConfData.get(ruleId);
                            
                            SVMXC__Route_Card__c inboundRC = new SVMXC__Route_Card__c();
                            inboundRC = mapPOLineIDToInboundCard.get(lstRouteCard[intCarCnt].SVMXC__RMA_Line__c);
                            if(tempLst != null && inboundRC != null && tempLst[0].SVMXC__Location__c != inboundRC.SVMXC__Current_Stop__c && tempLst.size()>0)
                            {
                                integer seq = 2;
                                for(SVMXC__ServiceMax_Config_Data__c objRutStops : tempLst)
                                {
                                    objRutStops.SVMXC__Sequence__c = seq;
                                    seq++;
                                }
                                tempLst.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = 1, SVMXC__Location__c = inboundRC.SVMXC__Current_Stop__c));
                            }
                            
                        //============== Sorting the Route Stops according to the Route Number ===================================================
                            system.debug('List of Route Stops before Sorting for ' + intCarCnt + ' : ' + tempLst);
                            
                            if(tempLst != null && tempLst.size() > 0)
                            {
                                Map<integer, SVMXC__ServiceMax_Config_Data__c> tempMapConfData = new Map<integer, SVMXC__ServiceMax_Config_Data__c>();
                                List<SVMXC__ServiceMax_Config_Data__c> tempLstConfDataToSort = new List<SVMXC__ServiceMax_Config_Data__c>();
                                
                                for(SVMXC__ServiceMax_Config_Data__c confD : tempLst)
                                    tempMapConfData.put(integer.valueOf(confD.SVMXC__Sequence__c), confD);
                                
                                tempLstConfDataToSort.clear();
                                Set<integer> setTempInt = new Set<integer>();
                                List<integer> tempSeqLst = new List<integer>();
                                setTempInt = tempMapConfData.keyset();
                                tempSeqLst.addAll(setTempInt);
                                tempSeqLst.sort();
                                
                                for(integer inte : tempSeqLst)
                                    tempLstConfDataToSort.add(tempMapConfData.get(inte));
                                
                                tempLst.clear();
                                tempLst.addAll(tempLstConfDataToSort);
                            }
                            system.debug('List of Route Stops after Sorting for ' + intCarCnt + ' : ' + tempLst);
                        //===================================== Sorting of Route Stops ends here ===================================================
                            
                            if(tempLst != null && tempLst.size() > 0)
                            {
                                for(SVMXC__ServiceMax_Config_Data__c objRutStops : tempLst)
                                {
                                    objRouteStop = new SVMXC__Route_Stop__c();
                                    if(integer.valueOf(objRutStops.SVMXC__Sequence__c) == 1)
                                    {
                                        objRouteStop.SVMXC__Delivered__c = true;
                                        objRouteStop.SVMXC__Delivered_By__c = userinfo.getUserId();
                                        objRouteStop.SVMXC__Delivered_On__c = system.now();
                                    }
                                    objRouteStop.SVMXC__Record_Card__c = lstRouteCard[intCarCnt].id;
                                    objRouteStop.SVMXC__Stop_Number__c = objRutStops.SVMXC__Sequence__c;
                                    objRouteStop.SVMXC__Stop_Location__c = objRutStops.SVMXC__Location__c;
                                    if(intPrevCarCnt == intCarCnt)
                                    {
                                        //placing the route stop for the previous next stop
                                        lstRouteStop[lstRouteStop.size()-1].SVMXC__Next_Stop__c =  objRutStops.SVMXC__Location__c;
                                    }
                                    intPrevCarCnt = intCarCnt;
                                    lstRouteStop.add(objRouteStop);
                                }
                            }
                            else
                            {
                                objRouteStop = new SVMXC__Route_Stop__c();
                                objRouteStop.SVMXC__Delivered__c = true;
                                objRouteStop.SVMXC__Delivered_By__c = userinfo.getUserId();
                                objRouteStop.SVMXC__Delivered_On__c = system.now();
                                objRouteStop.SVMXC__Record_Card__c = lstRouteCard[intCarCnt].id;
                                objRouteStop.SVMXC__Stop_Number__c = 1;
                                objRouteStop.SVMXC__Stop_Location__c = lstRouteCard[intCarCnt].SVMXC__Current_Stop__c;
                                objRouteStop.SVMXC__Next_Stop__c = lstRouteCard[intCarCnt].SVMXC__Last_Stop__c;
                                lstRouteStop.add(objRouteStop);
                                
                                SVMXC__Route_Stop__c objRouteStop1 = new SVMXC__Route_Stop__c();
                                objRouteStop1.SVMXC__Delivered__c = false;
                                objRouteStop1.SVMXC__Record_Card__c = lstRouteCard[intCarCnt].id;
                                objRouteStop1.SVMXC__Stop_Number__c = 2;
                                objRouteStop1.SVMXC__Stop_Location__c = lstRouteCard[intCarCnt].SVMXC__Last_Stop__c;
                                lstRouteStop.add(objRouteStop1);
                            }
                            intCarCnt++;
                        }
                    }
                    
                    system.debug('List of Route Stops to be created: ' + lstRouteStop + ' and the size is: ' + lstRouteStop.size());
                    if(lstRouteStop != null && lstRouteStop.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstRouteStop, COMM_SecurityUtils.Access.Upsertable)){
                        //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstRouteStop;
                    }
                    else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    } 
                    }
                        
                       
                    
                    mapPOLineToCard.clear();
                    if(lstRouteCard != null && lstRouteCard.size() > 0)
                    {
                        for(SVMXC__Route_Card__c card : lstRouteCard)
                            mapPOLineToCard.put(card.SVMXC__RMA_Line__c, card.Id);
                    }
                    
                    mapCardToStop.clear();
                    for(SVMXC__Route_Stop__c stop : lstRouteStop)
                    {
                        if(mapCardToStop.get(stop.SVMXC__Record_Card__c) == null)
                            mapCardToStop.put(stop.SVMXC__Record_Card__c, stop.Id);
                    }
                    
                    if(lstPOLine != null && lstPOLine.size() > 0)
                    {
                        for(i=0; i < lstPOLine.size(); i++)
                        {
                            string card = mapPOLineToCard.get(lstPOLine[i].Id);
                            lstPOLine[i].SVMXC__Route_Card__c = card;
                            string stop = mapCardToStop.get(card);
                            lstPOLine[i].SVMXC__Route_Stop__c = stop;
                        }
                        //update lstPOLine;
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstPOLine, COMM_SecurityUtils.Access.Updateable ) ) {
                            //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                            update lstPOLine;
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException(System.label.COMM001_TAG142);
                        }
                    }
                }
            }
        }
    }
}