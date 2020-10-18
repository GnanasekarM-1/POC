public with sharing class INTF_Get_WorkOrder_History
{
    public INTF_Get_WorkOrder_History()
    {}
    public static DCON_Utils dcUtils = new DCON_Utils();     
    public INTF_WebServicesDef.INTF_Response_For_History INTF_Get_Product_History(INTF_WebServicesDef.INTF_Request_For_History hisReqInfo)
    {
        String strTopLevelQuery = 'SELECT SVMXC__Top_Level__c, SVMXC__Problem_Description__c, Name, OwnerId ,CreatedDate, Id FROM SVMXC__Service_Order__c WHERE CreatedDate <=: dtmWRKOrderCreDate AND SVMXC__Top_Level__c =: strTopLevelId AND SVMXC__Order_Status__c = \'Closed\' AND Id !=: strCurrentWrkOrderId';
        String strCompLevelQuery = 'SELECT SVMXC__Top_Level__c, SVMXC__Problem_Description__c, Name, OwnerId ,CreatedDate, Id FROM SVMXC__Service_Order__c WHERE CreatedDate <=: dtmWRKOrderCreDate AND SVMXC__Component__c =: strWRKOrderComp AND SVMXC__Order_Status__c = \'Closed\' AND Id !=: strCurrentWrkOrderId';
        String strTopLevelId,strWRKOrderCreDate,strWRKOrderComp,strCurrentWrkOrderId;
        List<SVMXC__Service_Order__c> lstWrkOrders = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> respWrkOrders = new List<SVMXC__Service_Order__c>();
        
        DateTime dtmWRKOrderCreDate;        
        INTF_WebServicesDef.INTF_Response_For_History objResForHistory = new INTF_WebServicesDef.INTF_Response_For_History();
        try
        {
            if(hisReqInfo != null && hisReqInfo.historyReqInfo.size() > 0)
            {
                System.debug('TEST LOG: ' + hisReqInfo.historyReqInfo);
                for(INTF_WebServicesDef.INTF_StringMap currentPair : hisReqInfo.historyReqInfo)
                {
                    if(currentPair.key == 'CurrentWrkOrderId')
                    {
                        strCurrentWrkOrderId = currentPair.value;
                    }
                }
                if(strCurrentWrkOrderId != null)
                {
                System.debug('WorkOrder Id: '+ strCurrentWrkOrderId );
                    lstWrkOrders = [SELECT SVMXC__Top_Level__c, SVMXC__Component__c, Id, CreatedDate, SVMXC__Product__c from SVMXC__Service_Order__c where Id = :strCurrentWrkOrderId];
                    if(lstWrkOrders.size() > 0)
                    {
                        if(lstWrkOrders[0].SVMXC__Top_Level__c != NULL)
                            strTopLevelId = lstWrkOrders[0].SVMXC__Top_Level__c;
                        if(lstWrkOrders[0].SVMXC__Component__c != NULL)
                            strWRKOrderComp = lstWrkOrders[0].SVMXC__Component__c;
                        dtmWRKOrderCreDate = lstWrkOrders[0].CreatedDate;
                        
                        if(strTopLevelId != null && strTopLevelId.length() > 0)
                        {
                            System.debug('Entered to Execute TopLevel Query');
                            respWrkOrders = database.query(strTopLevelQuery);
                        }else if(strWRKOrderComp != null && strWRKOrderComp.length() > 0)
                        {
                            respWrkOrders = database.query(strCompLevelQuery);
                        }
                    }
                }
                objResForHistory.historyInfo =  respWrkOrders;  
            }           
            return objResForHistory;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
    
    public INTF_WebServicesDef.INTF_Response_For_History INTF_Get_Account_History(INTF_WebServicesDef.INTF_Request_For_History hisReqInfo)
    {
        String strAccountQuery = 'SELECT Id, Name, SVMXC__Problem_Description__c, CreatedDate FROM SVMXC__Service_Order__c WHERE CreatedDate <=: dtmWRKOrderCreDate  AND SVMXC__Order_Status__c = \'Closed\' AND Id !=: strCurrentWrkOrderId AND SVMXC__Company__c =: strAccountId';
        String strAccountId,strWRKOrderCreDate,strCurrentWrkOrderId;
        List<SVMXC__Service_Order__c> lstWrkOrders = new List<SVMXC__Service_Order__c>();
        List<SVMXC__Service_Order__c> respWrkOrders = new List<SVMXC__Service_Order__c>();
        DateTime dtmWRKOrderCreDate;
        INTF_WebServicesDef.INTF_Response_For_History objResForHistory = new INTF_WebServicesDef.INTF_Response_For_History();
        try
        {
            if(hisReqInfo != null && hisReqInfo.historyReqInfo.size() > 0)
            {
                for(INTF_WebServicesDef.INTF_StringMap currentPair : hisReqInfo.historyReqInfo)
                {
                    if(currentPair.key == 'CurrentWrkOrderId')
                    {
                        strCurrentWrkOrderId = currentPair.value;
                    }
                }
                if(strCurrentWrkOrderId != null)
                {
                    lstWrkOrders = [SELECT Id, CreatedDate, SVMXC__Company__c from SVMXC__Service_Order__c where Id = :strCurrentWrkOrderId];
                    
                    if(lstWrkOrders.size() > 0 && lstWrkOrders[0].SVMXC__Company__c != NULL)
                    {
                        strAccountId = lstWrkOrders[0].SVMXC__Company__c;
                        dtmWRKOrderCreDate = lstWrkOrders[0].CreatedDate;
                        system.debug('strAccountQuery: ' + strAccountId + dtmWRKOrderCreDate + strCurrentWrkOrderId);
                        respWrkOrders = database.query(strAccountQuery);
                    }
                }
                objResForHistory.historyInfo =  respWrkOrders;  
            }           
            return objResForHistory;
        }
        catch(Exception ex)
        {
            throw ex;
        }
    }
}