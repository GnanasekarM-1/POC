/* Security Scanned */
public with sharing class PORD_OutboundRouting
{
    public List<SVMXC__ServiceMax_Processes__c> outboundProcessLst = new List<SVMXC__ServiceMax_Processes__c>();
    public Set<ID> lstLocations = new Set<ID>();
    public Map<ID, ID> mapPOToLoc = new Map<ID, ID>();
    public Map<ID, string> mapLocIDToWhereClause = new Map<ID, string>();
    public Map<ID, string> mapPOWhereClause = new Map<ID, string>();
    public class SVMXException extends Exception {}
    public PORD_OutboundRouting()
    {
        
    }
    
    public void outboundRouteCalculation(List<SVMXC__RMA_Shipment_Order__c> lstPO)
    {
        for(SVMXC__RMA_Shipment_Order__c PO : lstPO)
        {
            mapPOToLoc.put(PO.Id, PO.SVMXC__Destination_Location__c);
            lstLocations.add(PO.SVMXC__Destination_Location__c);
        }
        map<string,string> mapLocToOutbndPro = new map<string,string>();
        //Querying Active Outbound Processes
        //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        outboundProcessLst = [select id, SVMXC__Name__c, SVMXC__IsStandard__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Process__c, SVMXC__Rule_Type__c, SVMXC__Description__c, SVMXC__Location__c, SVMXC__Location__r.Name,  SVMXC__Location__r.Id, SVMXC__Active__c, SVMXC__Node_Parent__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Outbound Route Calculation' and SVMXC__Rule_Type__c ='Outbound Route Calculation' and SVMXC__Active__c = true and SVMXC__Location__c IN: lstLocations];
        if(outboundProcessLst != null && outboundProcessLst.size() > 0)
        {
            for(SVMXC__ServiceMax_Processes__c pro : outboundProcessLst)
            {
                mapLocToOutbndPro.put(pro.SVMXC__Location__c, pro.Id);
                if(pro.SVMXC__Parent_Object_Criteria__c != null && pro.SVMXC__Parent_Object_Criteria__c.length() > 0)
                    mapLocIDToWhereClause.put(pro.SVMXC__Location__c, pro.SVMXC__Parent_Object_Criteria__c);
            }
            for(SVMXC__RMA_Shipment_Order__c PO : lstPO)
            {
                string LocId = mapPOToLoc.get(PO.Id);
                if(LocId != null && LocId.length() > 0 && mapLocToOutbndPro != null && mapLocToOutbndPro.size() > 0 && mapLocToOutbndPro.get(LocId) != null)
                {
                    string whereClause = '';
                    whereClause = mapLocIDToWhereClause.get(LocId);
                    mapPOWhereClause.put(PO.Id, whereClause);
                }
            }
            //System.debug('Map PO to Where Clause: ' + mapPOWhereClause);
            //Creating the Where Clause to query the Qualified PO Lines
            String bigWhereClause='';
            integer i = 0;
            for(string POID : mapPOWhereClause.keySet())
            {
                if(i == 0)
                    bigWhereClause += ' where (SVMXC__RMA_Shipment_Order__r.Id = \'' + POID + '\'' + ' AND SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Route_Type__c != \'Outbound\' AND SVMXC__Master_Order_Line__c != null AND SVMXC__Received__c = true';
                else
                    bigWhereClause += 'OR (SVMXC__RMA_Shipment_Order__r.Id = \'' + POID + '\'' + ' AND SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Route_Type__c != \'Outbound\' AND SVMXC__Master_Order_Line__c != null AND SVMXC__Received__c = true';
                i++;
                string ClauseToAdd = mapPOWhereClause.get(POID);
                if(ClauseToAdd != null && ClauseToAdd != 'ERROR' && ClauseToAdd != '')
                {
                    bigWhereClause +=  ' AND (' + ClauseToAdd + ')';
                }
                bigWhereClause += ')';
            }
            
            //System.debug('Big Where Clause: ' + bigWhereClause);
            outboundRouteCalculationPOLine(bigWhereClause);
        }
    }
    
    @future 
    public static void outboundRouteCalculationPOLine(string bigWhereClause)
    {
        String strLogInfo = '';
        
        List<SVMXC__RMA_Shipment_Line__c> lstPOLine = new List<SVMXC__RMA_Shipment_Line__c>();
        List<string> lstRouteRuleID = new List<string>();
        List<SVMXC__ServiceMax_Processes__c> lstRuleProcess = new List<SVMXC__ServiceMax_Processes__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstLocConfigData = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map<string, List<SVMXC__ServiceMax_Config_Data__c>> mapRouteRuleIDToLstConfData = new Map<string, List<SVMXC__ServiceMax_Config_Data__c>>();
        Map<string, string> mapMasterOrderLineIDPOLineID = new Map<string, string>();
        List<SVMXC__Route_Card__c> lstRouteCard = new List<SVMXC__Route_Card__c>();
        List<SVMXC__Route_Stop__c> lstRouteStop = new List<SVMXC__Route_Stop__c>();
        Set<ID> lstPOLineIDToUpdate = new Set<ID>();
        Set<ID> lstPOIDFoundError = new Set<ID>();
        Map<string, Map<string, string>> mapProductToMap = new Map<string, Map<string, string>>();
        Map<string, string> mapLocToAcc = new Map<string, string>();
        Map<string, string> mapPOLineIDRouteRuleID = new Map<string, string>();
        Map<string,string> mapCardToStop = new Map<string,string>();
        Map<string,string> mapPOLineToCard = new Map<string,string>();
        Map<string,List<string>> mapProductToLstPOLine = new Map<string,List<string>>();
        
        //Querying the Qualified PO Lines
        string SOQL = 'select id, SVMXC__Product__c, SVMXC__RMA_Shipment_Order__c, SVMXC__RMA_Shipment_Order__r.Id, SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__c, SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id, SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Name, SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Name, SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id, SVMXC__Route_Card__c, SVMXC__Route_Card__r.SVMXC__Route_Type__c, SVMXC__Master_Order_Line__c, SVMXC__Master_Order_Line__r.Id, SVMXC__Master_Order_Line__r.SVMXC__Route_Card__c, SVMXC__Master_Order_Line__r.SVMXC__Route_Card__r.SVMXC__Route_Type__c, SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c, SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.Id from SVMXC__RMA_Shipment_Line__c' + bigWhereClause;
        lstPOLine = database.query(SOQL);
        //System.debug('List of PO Line: ' + lstPOLine + ' size: ' + lstPOLine.size());
        try
        {
            APL_RoutingEngine routeEngine = new APL_RoutingEngine();
            
            if(lstPOLine != null && lstPOLine.size() > 0)
            {
                for(SVMXC__RMA_Shipment_Line__c POLine : lstPOLine)
                {
                    List<INTF_WebServicesDef.SVMXMap> lstSVMXMapForRequest = new List<INTF_WebServicesDef.SVMXMap>();
                    INTF_WebServicesDef.SVMXMap svmxMap1 = new INTF_WebServicesDef.SVMXMap('RouteType', 'Outbound');
                    lstSVMXMapForRequest.add(svmxMap1);
                    
                    Map<string, string> tempMapLocToAcc = mapProductToMap.get(POLine.SVMXC__Product__c);
                    if(tempMapLocToAcc != null)
                    {
                        string templocId = POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.id;
                        string tempAccId = mapLocToAcc.get(templocId);
                        if(tempAccId == null)
                        {
                            List<string> tempLstString = mapProductToLstPOLine.get(POLine.SVMXC__Product__c);
                            if(tempLstString == null || tempLstString.size() == 0)
                                tempLstString = new List<string>();
                            tempLstString.add(POLine.Id);
                            mapProductToLstPOLine.put(POLine.SVMXC__Product__c, tempLstString);
                            
                            mapLocToAcc.put(POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id, POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id);
                            tempMapLocToAcc.put(POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id, POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id);
                            mapProductToMap.put(POLine.SVMXC__Product__c, tempMapLocToAcc);
                            if(POLine.SVMXC__Product__c != null)
                            {
                                INTF_WebServicesDef.SVMXMap svmxMap2 = new INTF_WebServicesDef.SVMXMap('ProductID',POLine.SVMXC__Product__c);
                                lstSVMXMapForRequest.add(svmxMap2);
                            }
                            if(POLine.SVMXC__RMA_Shipment_Order__c != null)
                            {
                                if(POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__c != null)
                                {
                                    INTF_WebServicesDef.SVMXMap svmxMap3 = new INTF_WebServicesDef.SVMXMap('AccountID', POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id);
                                    lstSVMXMapForRequest.add(svmxMap3);
                                }
                                if(POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__c != null)
                                {
                                    INTF_WebServicesDef.SVMXMap svmxMap4 = new INTF_WebServicesDef.SVMXMap('LocationID', POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id);
                                    lstSVMXMapForRequest.add(svmxMap4);
                                }
                            }
                            
                            INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
                            request.valueMap = lstSVMXMapForRequest;
                            string strRouteRuleID;
                            INTF_WebServicesDef.INTF_SFMResponse response = routeEngine.APL_GetRouteInfo(request);
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
                                        mapPOLineIDRouteRuleID.put(POLine.Id, strRouteRuleID);
                                        break;
                                    }
                                }
                            }
                        }
                        else
                        {
                            List<string> tempLstString = mapProductToLstPOLine.get(POLine.SVMXC__Product__c);
                            string str = mapPOLineIDRouteRuleID.get(tempLstString[0]);
                            mapPOLineIDRouteRuleID.put(POLine.Id, str);
                        }
                    }
                    else
                    {
                        List<string> tempLstString = mapProductToLstPOLine.get(POLine.SVMXC__Product__c);
                        if(tempLstString == null || tempLstString.size() == 0)
                            tempLstString = new List<string>();
                        tempLstString.add(POLine.Id);
                        mapProductToLstPOLine.put(POLine.SVMXC__Product__c, tempLstString);
                        
                        string tempAccId = mapLocToAcc.get(POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id);
                        if(tempAccId == null)
                            mapLocToAcc.put(POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id, POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id);
                        tempMapLocToAcc = new Map<string, string>();
                        tempMapLocToAcc.put(POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id, POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id);
                        mapProductToMap.put(POLine.SVMXC__Product__c, tempMapLocToAcc);
                        if(POLine.SVMXC__Product__c != null)
                        {
                            INTF_WebServicesDef.SVMXMap svmxMap2 = new INTF_WebServicesDef.SVMXMap('ProductID', POLine.SVMXC__Product__c);
                            lstSVMXMapForRequest.add(svmxMap2);
                        }
                        if(POLine.SVMXC__RMA_Shipment_Order__c != null)
                        {
                            if(POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__c != null)
                            {
                                INTF_WebServicesDef.SVMXMap svmxMap3 = new INTF_WebServicesDef.SVMXMap('AccountID', POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id);
                                lstSVMXMapForRequest.add(svmxMap3);
                            }
                            if(POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__c != null)
                            {
                                INTF_WebServicesDef.SVMXMap svmxMap4 = new INTF_WebServicesDef.SVMXMap('LocationID', POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id);
                                lstSVMXMapForRequest.add(svmxMap4);
                            }
                        }
                        INTF_WebServicesDef.INTF_SFMRequest request = new INTF_WebServicesDef.INTF_SFMRequest();
                        request.valueMap = lstSVMXMapForRequest;
                        string strRouteRuleID;
                        INTF_WebServicesDef.INTF_SFMResponse response = routeEngine.APL_GetRouteInfo(request);
                        if(response.success == true)
                        {
                            List<INTF_WebServicesDef.SVMXMap> objRuleInfo = new List<INTF_WebServicesDef.SVMXMap>();
                            objRuleInfo = response.valueMap;
                            //System.debug('objRuleInfo: ' + objRuleInfo);
                            for(INTF_WebServicesDef.SVMXMap objTemp : objRuleInfo)
                            {
                                if(objTemp.key == 'RouteID')
                                {
                                    strRouteRuleID = objTemp.value;
                                }
                                if(strRouteRuleID != '-1' && strRouteRuleID != null)
                                {
                                    lstRouteRuleID.add(strRouteRuleID);
                                    mapPOLineIDRouteRuleID.put(POLine.Id, strRouteRuleID);
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            
            //System.debug('List of routing rule Ids: ' + lstRouteRuleID + ' and the size is: ' + lstRouteRuleID.size());
            
            //Querying the Routing Rules
            //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            lstRuleProcess = [Select Id, SVMXC__APL_Route_Rule_Type__c From SVMXC__ServiceMax_Processes__c where Id IN : lstRouteRuleID and SVMXC__Record_Type_Name__c ='SVMX Rule' and SVMXC__Rule_Type__c = 'Routing Rule'];
            lstLocConfigData = [Select SVMXC__Sequence__c, SVMXC__Location__c, SVMXC__Dispatch_Process__c, SVMXC__RecordType_Name__c, RecordTypeId, Id From SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c IN : lstRouteRuleID and SVMXC__RecordType_Name__c ='Route Stops' Order By SVMXC__Sequence__c];
            //System.debug('Routing Rule Processes found: ' + lstRuleProcess + ' and the size is: ' + lstRuleProcess.size());
            //System.debug('List of Route Stops found: ' + lstLocConfigData + ' and the size is: ' + lstLocConfigData.size());
            
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
            
            //System.debug('Map of Route Rule to List of Stops: ' + mapRouteRuleIDToLstConfData);
            
            //=============================================== Creating Route Cards =========================================================
            if(lstPOLine != null && lstPOLine.size() > 0)
            {
                for(SVMXC__RMA_Shipment_Line__c POLine : lstPOLine)
                {
                    string ruleId = mapPOLineIDRouteRuleID.get(POLine.Id);
                    if(ruleId != null)
                    {
                        List<SVMXC__ServiceMax_Config_Data__c> tempLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                        tempLst = mapRouteRuleIDToLstConfData.get(ruleId);
                        if(POLine.SVMXC__Master_Order_Line__c != null && POLine.SVMXC__Master_Order_Line__r.Id != null)
                        {
                            SVMXC__Route_Card__c objRouteCard = new SVMXC__Route_Card__c();
                            objRouteCard.SVMXC__RMA__c = POLine.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c;
                            objRouteCard.SVMXC__RMA_Line__c = POLine.SVMXC__Master_Order_Line__r.Id;
                            objRouteCard.SVMXC__Route_Type__c = 'Outbound';
                            if(tempLst != null && tempLst.size()>0 && POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__c != null && tempLst[0].SVMXC__Location__c == POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id)
                            {
                                objRouteCard.SVMXC__First_Stop__c = tempLst[0].SVMXC__Location__c;
                                objRouteCard.SVMXC__Current_Stop__c = tempLst[0].SVMXC__Location__c;
                                if(tempLst.size() > 1)
                                    objRouteCard.SVMXC__Next_Stop__c = tempLst[1].SVMXC__Location__c;
                                else
                                    objRouteCard.SVMXC__Next_Stop__c = tempLst[0].SVMXC__Location__c;
                                objRouteCard.SVMXC__Last_Stop__c = tempLst[integer.valueOf(tempLst.size() - 1 )].SVMXC__Location__c;
                            }
                            else if(tempLst != null && tempLst.size()>0 && POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__c != null && tempLst[0].SVMXC__Location__c != POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id)
                            {
                                objRouteCard.SVMXC__First_Stop__c = POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id;
                                objRouteCard.SVMXC__Current_Stop__c = POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id;
                                objRouteCard.SVMXC__Next_Stop__c = tempLst[0].SVMXC__Location__c;
                                //objRouteCard.SVMXC__Next_Stop__c = POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id;
                                objRouteCard.SVMXC__Last_Stop__c = tempLst[integer.valueOf(tempLst.size() - 1 )].SVMXC__Location__c;
                            }
                            objRouteCard.SVMXC__Status__c = 'Open';
                            objRouteCard.SVMXC__Customer__c = POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id;
                            lstRouteCard.add(objRouteCard);
                            mapMasterOrderLineIDPOLineID.put(POLine.SVMXC__Master_Order_Line__r.Id, POLine.Id);
                        }
                    }
                    else
                    {
                        if(POLine.SVMXC__Master_Order_Line__c != null && POLine.SVMXC__Master_Order_Line__r.Id != null && POLine.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c != null && POLine.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__c != null && POLine.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id != null)
                        {
                            SVMXC__Route_Card__c objRouteCard = new SVMXC__Route_Card__c();
                            objRouteCard.SVMXC__RMA__c = POLine.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__c;
                            objRouteCard.SVMXC__RMA_Line__c = POLine.SVMXC__Master_Order_Line__r.Id;
                            objRouteCard.SVMXC__Current_Stop__c = POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id;
                            objRouteCard.SVMXC__Last_Stop__c = POLine.SVMXC__Master_Order_Line__r.SVMXC__RMA_Shipment_Order__r.SVMXC__Destination_Location__r.Id;
                            objRouteCard.SVMXC__Status__c = 'Open';
                            objRouteCard.SVMXC__Route_Type__c = 'Outbound';
                            objRouteCard.SVMXC__Customer__c = POLine.SVMXC__RMA_Shipment_Order__r.SVMXC__Company__r.Id;
                            lstRouteCard.add(objRouteCard);
                            mapMasterOrderLineIDPOLineID.put(POLine.SVMXC__Master_Order_Line__r.Id, POLine.Id);
                        }
                        else
                        {
                            lstPOIDFoundError.add(POLine.SVMXC__RMA_Shipment_Order__r.Id);
                        }
                    }
                }
            }
            //============================================ Creation of Route Cards ends here==================================================
            
            //System.debug('Master Order Line Id to PO Line Id: ' + mapMasterOrderLineIDPOLineID + ' and the size is: ' + mapMasterOrderLineIDPOLineID.size());
            //System.debug('List of Route Card: ' + lstRouteCard + ' and the size is: ' + lstRouteCard.size());
            //System.debug('List of PO found error: ' + lstPOIDFoundError + ' and the size is: ' + lstPOIDFoundError.size());
            
            //=============================================== Creating Route Stops ==========================================================
            if(lstRouteCard != null && lstRouteCard.size() > 0)
            {
                //upsert lstRouteCard;
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRouteCard, COMM_SecurityUtils.Access.Upsertable ) ) {
                    //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                    upsert lstRouteCard;
                } else {
                    String emailID = '';
                    Map<String, String> svmxSettingList = new Map<String,String>();
                    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
                    svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
                    emailID = string.valueOf(svmxSettingList.get('GBL015'));
                    if(emailID != null && emailID != '' && emailID.length() > 0)
                    {
                        strLogInfo = 'Error found. Exception occured is: ' + '\n\n';
                        strLogInfo = System.Label.COMM001_TAG142;
                        failureStatusEmail(strLogInfo, emailID);
                    }
                    return;
                }
                
                integer intCarCnt = 0;
                SVMXC__Route_Stop__c objRouteStop = new SVMXC__Route_Stop__c();
                while(intCarCnt < lstRouteCard.size())
                {
                    integer intPrevCarCnt = -1;
                    string ruleId = mapPOLineIDRouteRuleID.get(mapMasterOrderLineIDPOLineID.get(lstRouteCard[intCarCnt].SVMXC__RMA_Line__c));
                    if(ruleId != null && ruleId != '')
                    {
                        List<SVMXC__ServiceMax_Config_Data__c> tempLst = new List<SVMXC__ServiceMax_Config_Data__c>();
                        tempLst = mapRouteRuleIDToLstConfData.get(ruleId);
                        if(tempLst != null && tempLst.size()>0 && tempLst[0].SVMXC__Location__c != lstRouteCard[intCarCnt].SVMXC__Current_Stop__c)
                        {
                            integer seq = 2;
                            for(SVMXC__ServiceMax_Config_Data__c objRutStops : tempLst)
                            {
                                objRutStops.SVMXC__Sequence__c = seq;
                                seq++;
                            }
                            tempLst.add(new SVMXC__ServiceMax_Config_Data__c(SVMXC__Sequence__c = 1, SVMXC__Location__c = lstRouteCard[intCarCnt].SVMXC__Current_Stop__c));
                        }
                        
                        //=================== Sorting the Route Stops according to the Route Number ==========================================
                        //System.debug('List of Route Stops before Sorting for ' + intCarCnt + ' : ' + tempLst);
                        
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
                        //System.debug('List of Route Stops after Sorting for ' + intCarCnt + ' : ' + tempLst);
                        //================================== Sorting of Route Stops ends here ==================================================
                        
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
                        
                        objRouteStop = new SVMXC__Route_Stop__c();
                        objRouteStop.SVMXC__Delivered__c = true;
                        objRouteStop.SVMXC__Delivered_By__c = userinfo.getUserId();
                        objRouteStop.SVMXC__Delivered_On__c = system.now();
                        objRouteStop.SVMXC__Record_Card__c = lstRouteCard[intCarCnt].id;
                        objRouteStop.SVMXC__Stop_Number__c = 2;
                        objRouteStop.SVMXC__Stop_Location__c = lstRouteCard[intCarCnt].SVMXC__Last_Stop__c;
                        lstRouteStop.add(objRouteStop);
                    }
                    intCarCnt++;
                }
                //COMM_PerformanceUtils.stop('009: Loop through Route Cards and creating Stops');
            }
            
            //System.debug('List of Route Stops: ' + lstRouteStop);
            if(lstRouteStop != null && lstRouteStop.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstRouteStop, COMM_SecurityUtils.Access.Upsertable)){
                //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                upsert lstRouteStop;
            }
            else{
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
            }
                
            //=========================================== Creation of Route Stops ends here =================================================
            
            if(lstRouteCard != null && lstRouteCard.size() > 0)
            {
                for(SVMXC__Route_Card__c card : lstRouteCard)
                {
                    mapPOLineToCard.put(card.SVMXC__RMA_Line__c, card.Id);
                    lstPOLineIDToUpdate.add(card.SVMXC__RMA_Line__c);
                }
            }
            
            mapCardToStop.clear();
            for(SVMXC__Route_Stop__c stop : lstRouteStop)
            {
                if(mapCardToStop.get(stop.SVMXC__Record_Card__c) == null)
                    mapCardToStop.put(stop.SVMXC__Record_Card__c, stop.Id);
            }
            //System.debug('lstPOLine to Update Ids : ' + lstPOLineIDToUpdate + ' and the size is: ' + lstPOLineIDToUpdate.size());
            //System.debug('mapPOLineToCard : ' + mapPOLineToCard + ' and the size is: ' + mapPOLineToCard.size());
            //System.debug('mapCardToStop : ' + mapCardToStop + ' and the size is: ' + mapCardToStop.size());
            
            List<SVMXC__RMA_Shipment_Line__c> lstPOLineToUpdate = new List<SVMXC__RMA_Shipment_Line__c>();
            if(lstPOLineIDToUpdate != null && lstPOLineIDToUpdate.size() >0)
            {
                lstPOLineToUpdate = [select id, SVMXC__Route_Card__c, SVMXC__Route_Stop__c from SVMXC__RMA_Shipment_Line__c where Id IN: lstPOLineIDToUpdate];
                if(lstPOLineToUpdate != null && lstPOLineToUpdate.size() > 0)
                {
                    for(Integer i=0; i < lstPOLineToUpdate.size(); i++)
                    {
                        string card = mapPOLineToCard.get(lstPOLineToUpdate[i].Id);
                        lstPOLineToUpdate[i].SVMXC__Route_Card__c = card;
                        string stop = mapCardToStop.get(card);
                        lstPOLineToUpdate[i].SVMXC__Route_Stop__c = stop;
                    }
                    //System.debug('List of Master Order Lines Updated: ' + lstPOLineToUpdate + ' and the size is: ' + lstPOLineToUpdate.size());
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstPOLineToUpdate, COMM_SecurityUtils.Access.Updateable ) ) {
                        //SDL-SVM-CREATE-UPDATE-FLS-ENFORCED
                        update lstPOLineToUpdate;
                    } else {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
            }
            
            /* if(lstPOLine != null && lstPOLine.size() > 0)
{
for(i=0; i < lstPOLine.size(); i++)
{
string card = mapPOLineToCard.get(lstPOLine[i].Id);
lstPOLine[i].SVMXC__Route_Card__c = card;
string stop = mapCardToStop.get(card);
lstPOLine[i].SVMXC__Route_Stop__c = stop;
}
update lstPOLine;
} */
            
            if(lstPOIDFoundError != null && lstPOIDFoundError.size() > 0)
            {
                string err = 'Please Provide the To Location for these Parts Order to calculate the Outbound Route: ' + '\n\n';
                for(string str : lstPOIDFoundError)
                    err += str + '\n';
                throw new SVMXException(err);
            }
            
            /* if(lstPOLineToUpdate != null && lstPOLineToUpdate.size() > 0)
for(SVMXC__RMA_Shipment_Line__c str: lstPOLineToUpdate)
perfUtil.end(string.valueOf(str.Id), 'Future Method of Trigger: PORD_Trigger1'); */
        }
        catch(Exception ex)
        {
            String emailID = '';
            Map<String, String> svmxSettingList = new Map<String,String>();
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
            emailID = string.valueOf(svmxSettingList.get('GBL015'));
            if(emailID != null && emailID != '' && emailID.length() > 0)
            {
                strLogInfo = 'Error found. Exception occured is: ' + '\n\n';
                strLogInfo = ex.getMessage();
                failureStatusEmail(strLogInfo, emailID);
            }
            /* if(lstPOLine != null && lstPOLine.size() > 0)
for(SVMXC__RMA_Shipment_Line__c str: lstPOLine)
perfUtil.end(string.valueOf(str.Id), 'Exception Occured while call of Future Method from Trigger: PORD_Trigger1'); */
        }   
    }
    
    public static void failureStatusEmail(String strMsg, String emailID)
    {
        APL_Entitlement aplEntitleObj = new APL_Entitlement();
        Messaging.SingleEmailMessage objMailShpMessage = new Messaging.SingleEmailMessage();
        objMailShpMessage.setToAddresses(new String[] {emailID});
        objMailShpMessage.setSenderDisplayName('ServiceMax');
        objMailShpMessage.setSubject('Success email for outbound routing.');
        objMailShpMessage.setBccSender(false);
        objMailShpMessage.setUseSignature(false);
        objMailShpMessage.setPlainTextBody(strMsg);
        if( !Test.isRunningTest() ) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMailShpMessage });           
        }        
    }
}