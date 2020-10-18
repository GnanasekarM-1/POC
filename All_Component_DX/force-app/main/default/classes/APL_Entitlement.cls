public with sharing class APL_Entitlement 
{
    /*Global variables*/
    public Map<String, String> mapSubModSettings;
    SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
    /*End of Global variables*/
    public APL_Entitlement()
    {
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse APL_PerformEntitlement(INTF_WebServicesDef.INTF_SFMRequest reqForEntitlement)
    {
        INTF_WebServicesDef.INTF_SFMResponse objResForUpdationOfEnti = new INTF_WebServicesDef.INTF_SFMResponse();
        String strCaseID = null;
        List<SVMXC__Case_Line__c> lstCaseLines = null;
        Date dtStartDate = null, dtEndDate = null;
        string strExchangeType = '';
        List<String> lstCaseLineIds = new List<String>();
        List<SVMXC__Entitlement_History__c> lstEtlHistory = new List<SVMXC__Entitlement_History__c>();
        String strCaseLineQuery = 'Select SVMXC__Warranty__c, SVMXC__Service_Contract__c, SVMXC__Warranty_Start_Date__c, SVMXC__Entitled_Exchange_Type__c, SVMXC__Service_Contract_Exchange_Type__c , SVMXC__Warranty_Exchange_Type__c, SVMXC__Entitlement_Status__c, SVMXC__Warranty_End_Date__c, SVMXC__Service_Contract_Start_Date__c, ' +
        'SVMXC__Service_Contract_End_Date__c From SVMXC__Case_Line__c where SVMXC__Case__c = :strCaseID ';      
        String strStartDate = 'SVMXC__Warranty_Start_Date__c', strEndDate = 'SVMXC__Warranty_End_Date__c', strEntitlementStatus = 'Warranty', strEntitleExchangeType = 'SVMXC__Warranty_Exchange_Type__c';       
        try
        {
            mapSubModSettings = commSettings.SVMX_getSettingList('APL001');
            if(mapSubModSettings != null && mapSubModSettings.size() > 0 && mapSubModSettings.containsKey('SET001'))
            {
                if(mapSubModSettings.get('SET001') == 'Pick The First Service Contract')
                {
                    strStartDate = 'SVMXC__Service_Contract_Start_Date__c';
                    strEndDate = 'SVMXC__Service_Contract_End_Date__c';
                    strEntitleExchangeType = 'SVMXC__Service_Contract_Exchange_Type__c';
                    strEntitlementStatus = 'Contract';
                }
            }
            
            //Get the Case Id from the request.
            List<INTF_WebServicesDef.SVMXMap> lstCaseReqMap = reqForEntitlement.valueMap;
            if(lstCaseReqMap != null && lstCaseReqMap.Size() > 0 && lstCaseReqMap[0].value != null && lstCaseReqMap[0].value.length() > 0)
            {
                strCaseID = lstCaseReqMap[0].value;
                if( lstCaseReqMap[1] != null && lstCaseReqMap[1].value != null && lstCaseReqMap[1].value.length() > 0)
                {
                    strCaseLineQuery += 'And ' + lstCaseReqMap[1].value;
                }
                lstCaseLines = database.query(strCaseLineQuery);
                if(lstCaseLines != null && lstCaseLines.Size() > 0)
                {
                    for(SVMXC__Case_Line__c objCurrCaseLine : lstCaseLines)
                    {
                        if((objCurrCaseLine.SVMXC__Warranty__c == null || objCurrCaseLine.SVMXC__Warranty__c.length() == 0) && (objCurrCaseLine.SVMXC__Service_Contract__c != null && objCurrCaseLine.SVMXC__Service_Contract__c.length() > 0))
                        {
                            strStartDate = 'SVMXC__Service_Contract_Start_Date__c';
                            strEndDate = 'SVMXC__Service_Contract_End_Date__c';
                            strEntitleExchangeType = 'SVMXC__Service_Contract_Exchange_Type__c';
                            strEntitlementStatus = 'Contract';
                        }
                        else if((objCurrCaseLine.SVMXC__Service_Contract__c == null || objCurrCaseLine.SVMXC__Service_Contract__c.length() == 0) && (objCurrCaseLine.SVMXC__Warranty__c != null && objCurrCaseLine.SVMXC__Warranty__c.length() > 0))
                        {
                            strStartDate = 'SVMXC__Warranty_Start_Date__c';
                            strEndDate = 'SVMXC__Warranty_End_Date__c';
                            strEntitlementStatus = 'Warranty';
                            strEntitleExchangeType = 'SVMXC__Warranty_Exchange_Type__c';
                        }
                        
                        dtStartDate = (Date)objCurrCaseLine.get(strStartDate);
                        dtEndDate = (Date)objCurrCaseLine.get(strEndDate);
                        strExchangeType = (string)objCurrCaseLine.get(strEntitleExchangeType);
                        if(dtStartDate != null && dtEndDate != null && dtStartDate <= system.today() && dtEndDate >= system.today())
                        {
                            objCurrCaseLine.SVMXC__Entitlement_Status__c = strEntitlementStatus;
                            objCurrCaseLine.SVMXC__Entitled_Exchange_Type__c = strExchangeType;
                        }else
                        {
                            objCurrCaseLine.SVMXC__Entitlement_Status__c = null;                          
                        }
                        lstCaseLineIds.add(objCurrCaseLine.id);
                        CreateEntitHistoryForCaseLine(lstEtlHistory, objCurrCaseLine, dtStartDate, dtEndDate);                                          
                    }
                    
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstCaseLines, COMM_SecurityUtils.Access.Updateable )){
                        update lstCaseLines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    
                    if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstEtlHistory, COMM_SecurityUtils.Access.Createable ) ) {
                        insert lstEtlHistory; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                }                                               
            }           
            objResForUpdationOfEnti.success = True;
            objResForUpdationOfEnti.values = lstCaseLineIds;
        }catch(Exception ex)
        {
            objResForUpdationOfEnti.success = false;
            objResForUpdationOfEnti.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
            objResForUpdationOfEnti.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage()));
        }
        return objResForUpdationOfEnti;
    }
    
    //Create the Entitlement History for the Case Line
    public void CreateEntitHistoryForCaseLine(List<SVMXC__Entitlement_History__c> etlHistory,SVMXC__Case_Line__c objCaseLine,Date startDate, Date endDate)
    {
        SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
        oEntitlementHistory.SVMXC__Case_Line__c = objCaseLine.Id;
        oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
        oEntitlementHistory.SVMXC__Start_Date__c = startDate; 
        oEntitlementHistory.SVMXC__End_Date__c = endDate;
        //oEntitlementHistory.SVMXC__Entitlement_Notes__c = objCaseLine.SVMXC__Entitlement_Notes__c;
        etlHistory.add(oEntitlementHistory);
    }
        
    //Create the Entitlement History for the RMA Line
    public void CreateEntitHistoryForCaseLine(List<SVMXC__Entitlement_History__c> etlHistory,SVMXC__RMA_Shipment_Line__c objRMALine,Date startDate, Date endDate)
    {
        SVMXC__Entitlement_History__c oEntitlementHistory = new SVMXC__Entitlement_History__c();
        oEntitlementHistory.SVMXC__RMA_Line__c = objRMALine.Id;
        oEntitlementHistory.SVMXC__Date_of_Entitlement__c = date.Today();
        oEntitlementHistory.SVMXC__Start_Date__c = startDate; 
        oEntitlementHistory.SVMXC__End_Date__c = endDate;
        etlHistory.add(oEntitlementHistory);
    }
    
    public INTF_WebServicesDef.INTF_SFMResponse APL_PerformEntitlement_PD(INTF_WebServicesDef.INTF_SFMRequest reqForEntitlement)
    {
        List<INTF_WebServicesDef.SVMXMap> lstRmaLineMaps = reqForEntitlement.valueMap;
        List<String> lstUnresolvedRMALinesIds = new List<String>();
        INTF_WebServicesDef.INTF_SFMResponse objResponse = new INTF_WebServicesDef.INTF_SFMResponse();
        try
        {
            objResponse.success = true;
            if(lstRmaLineMaps != NULL)
            {
            for(INTF_WebServicesDef.SVMXMap objCurrMap : lstRmaLineMaps)
            {
                if(objCurrMap.key == 'UNEXPECTEDLINES')
                {
                    lstUnresolvedRMALinesIds.add(objCurrMap.value);
                }
            }
            List<String> queryFields = new List<String> {'SVMXC__Warranty_Start_Date__c', 'SVMXC__Warranty_End_Date__c', 'SVMXC__Serial_Number__r.SVMXC__Service_Contract_Exchange_Type__c', 'SVMXC__Serial_Number__r.SVMXC__Warranty_Exchange_Type__c', 'SVMXC__Service_Contract_Start_Date__c', 'SVMXC__Service_Contract_End_Date__c', 'SVMXC__Entitlement_Status__c'};
            if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__RMA_Shipment_Line__c> lstUnresolvedRMALines = [select SVMXC__Warranty_Start_Date__c, SVMXC__Warranty_End_Date__c, SVMXC__Serial_Number__r.SVMXC__Service_Contract_Exchange_Type__c, SVMXC__Serial_Number__r.SVMXC__Warranty_Exchange_Type__c, SVMXC__Service_Contract_Start_Date__c, SVMXC__Service_Contract_End_Date__c, SVMXC__Entitlement_Status__c from SVMXC__RMA_Shipment_Line__c where Id in :lstUnresolvedRMALinesIds]; //SDL-SVMX-READ-FLS-ENFORCED
            APL_Entitlement_On_PD(lstUnresolvedRMALines);
            }
        }catch(Exception ex)
        {
                objResponse.success = false;
                objResponse.message = ex.getMessage();
        }
        return objResponse;     
    }
    
    public List<SVMXC__RMA_Shipment_Line__c> APL_Entitlement_On_PD(List<SVMXC__RMA_Shipment_Line__c> poLinesForEntitlement)
    {
        Date dtStartDate = null, dtEndDate = null;
        string strExchangeType = '';
        List<SVMXC__Entitlement_History__c> lstEtlHistory = new List<SVMXC__Entitlement_History__c>();         
        String strStartDate = 'SVMXC__Warranty_Start_Date__c', strEndDate = 'SVMXC__Warranty_End_Date__c', strEntitlementStatus = 'Entitled To Warranty', strEntitleExchangeType = 'SVMXC__Warranty_Exchange_Type__c';
        Boolean isEntitlementOnWarranty = true;
        try
        {
            mapSubModSettings = commSettings.SVMX_getSettingList('APL001');
            if(mapSubModSettings != null && mapSubModSettings.size() > 0 && mapSubModSettings.containsKey('SET001'))
            {
                if(mapSubModSettings.get('SET001') == 'Pick The First Service Contract')
                {
                    strStartDate = 'SVMXC__Service_Contract_Start_Date__c';
                    strEndDate = 'SVMXC__Service_Contract_End_Date__c';
                    strEntitleExchangeType = 'SVMXC__Entitled_Exchange_Type__c';
                    isEntitlementOnWarranty = false;
                }
            }
            //Get the Case Id from the request.
            if(poLinesForEntitlement != null && poLinesForEntitlement.Size() > 0)
            {
                for(SVMXC__RMA_Shipment_Line__c objCurrRMALine : poLinesForEntitlement)
                {
                    dtStartDate = (Date)objCurrRMALine.get(strStartDate);
                    dtEndDate = (Date)objCurrRMALine.get(strEndDate);
                    strExchangeType = (string)objCurrRMALine.get(strEntitleExchangeType);
                    if(dtStartDate != null && dtEndDate != null && dtStartDate <= system.today() && dtEndDate >= system.today())
                    {
                        objCurrRMALine.SVMXC__Entitlement_Status__c = strEntitlementStatus;
                        objCurrRMALine.SVMXC__Entitled_Exchange_Type__c = strExchangeType;
                    }else
                    {
                        objCurrRMALine.SVMXC__Entitlement_Status__c = null;                          
                    }
                    if(isEntitlementOnWarranty == true)
                        objCurrRMALine.SVMXC__Entitled_Exchange_Type__c = objCurrRMALine.SVMXC__Serial_Number__r.SVMXC__Warranty_Exchange_Type__c;
                    else
                        objCurrRMALine.SVMXC__Entitled_Exchange_Type__c = objCurrRMALine.SVMXC__Serial_Number__r.SVMXC__Service_Contract_Exchange_Type__c;
                    
                    CreateEntitHistoryForCaseLine(lstEtlHistory, objCurrRMALine, dtStartDate, dtEndDate);                                          
                }
                system.debug('poLinesForEntitlement'+poLinesForEntitlement);
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( poLinesForEntitlement, COMM_SecurityUtils.Access.Updateable ) ) {
                    update poLinesForEntitlement;
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstEtlHistory, COMM_SecurityUtils.Access.Createable ) ) {
                    insert lstEtlHistory; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }                                               
             return  poLinesForEntitlement;
        }catch(Exception ex)
        {
            throw ex;
        }
    }
    
    public List<SVMXC__RMA_Shipment_Line__c> APL_ResolveIB_On_PD(List<SVMXC__RMA_Shipment_Line__c> poLinesForEntitlement)
    {
        try
        {
            //Get all the serial numbers
            map<String,SVMXC__RMA_Shipment_Line__c> mapToResolveInvalidSNs = new map<String,SVMXC__RMA_Shipment_Line__c>();
            map<String,String> mapSNAndProducts = new map<String,String>();
            for(SVMXC__RMA_Shipment_Line__c objCurrentLine : poLinesForEntitlement)
            {
                if(objCurrentLine.SVMXC__Serial_Number_List__c != null)
                {
                    mapToResolveInvalidSNs.put(objCurrentLine.SVMXC__Serial_Number_List__c,objCurrentLine);
                    mapSNAndProducts.put(objCurrentLine.SVMXC__Serial_Number_List__c,objCurrentLine.SVMXC__Product__c);
                }
            }

            List<String> queryFields = new List<String> {'id', 'SVMXC__Serial_Lot_Number__c', 'SVMXC__Product__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Installed_Product__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            //get all the Ibs with the serial numbers that are provided 
            List<SVMXC__Installed_Product__c> lstIBs = [Select id, SVMXC__Serial_Lot_Number__c, SVMXC__Product__c from SVMXC__Installed_Product__c where SVMXC__Serial_Lot_Number__c IN :mapToResolveInvalidSNs.keySet()]; //SDL-SVMX-READ-FLS-ENFORCED
            if(lstIBs!= null && lstIBs.size() > 0)
            {
                //now update the PO with the valid IB
                List<SVMXC__RMA_Shipment_Line__c> lstRMALinesToUpdate = new List<SVMXC__RMA_Shipment_Line__c>();
                for(SVMXC__Installed_Product__c objCurrIb : lstIBs)
                {
                    if(objCurrIb.SVMXC__Product__c == mapSNAndProducts.get(objCurrIb.SVMXC__Serial_Lot_Number__c))
                    {
                        SVMXC__RMA_Shipment_Line__c objCurrRMALine = mapToResolveInvalidSNs.get(objCurrIb.SVMXC__Serial_Lot_Number__c);
                        objCurrRMALine.SVMXC__Serial_Number__c = objCurrIb.id;
                    }
                }
            }
            return poLinesForEntitlement;           
        }catch(Exception ex)
        {
            throw ex;
        }
        
    }
    
    //Method for Update List of Installed Products on change of Contract, to be called in the Trigger
    public void updateIBForContract(List<ID> lstSCID)
    {
        //COMM_PerformanceUtils.start('003:a: Query for SC Lines');
        List<SVMXC__Service_Contract_Products__c> lstSCLines = new List<SVMXC__Service_Contract_Products__c>();
        List<String> queryFields = new List<String> {'Id', 'SVMXC__End_Date__c', 'SVMXC__Installed_Product__c', 'SVMXC__Service_Contract__c', 'SVMXC__Service_Contract__r.SVMXC__End_Date__c', 'SVMXC__Service_Contract__r.SVMXC__Start_Date__c', 'SVMXC__Service_Contract__r.Id', 'SVMXC__Service_Contract__r.SVMXC__Exchange_Type__c', 'SVMXC__Start_Date__c', 'SVMXC__Exchange_Type__c', 'SVMXC__SLA_Terms__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Contract_Products__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        lstSCLines = [select Id, SVMXC__End_Date__c, SVMXC__Installed_Product__c, SVMXC__Service_Contract__c, SVMXC__Service_Contract__r.SVMXC__End_Date__c, SVMXC__Service_Contract__r.SVMXC__Start_Date__c, SVMXC__Service_Contract__r.Id, SVMXC__Service_Contract__r.SVMXC__Exchange_Type__c, SVMXC__Start_Date__c, SVMXC__Exchange_Type__c, SVMXC__SLA_Terms__c from SVMXC__Service_Contract_Products__c where SVMXC__Service_Contract__c IN: lstSCID AND SVMXC__Service_Contract__c != null]; //SDL-SVMX-READ-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('003:a: Query for SC Lines');
        //COMM_PerformanceUtils.start('003:b: Loop through SC Lines');
        List<String> lstCPID = new List<String>();
        
        for(SVMXC__Service_Contract_Products__c CP : lstSCLines)
            lstCPID.add(CP.Id);
        //COMM_PerformanceUtils.stop('003:b: Loop through SC Lines');    
        //updateIBForCoveredProduct(lstSCLines);
        //COMM_PerformanceUtils.start('003:c: Future Method for Calculations Called');
        updateIBForInValidCoveredProduct(lstCPID);
        //COMM_PerformanceUtils.stop('003:c: Future Method for Calculations Called');
    }
        
    //Method for Update List of Installed Products on change of Warranty which is invalid, to be called in the Trigger
    public void updateIBForInvalidWarranty(List<ID> lstIBId)
    {
        //COMM_PerformanceUtils.start('003:a: Variable Declaration');
        Map<ID, List<SVMXC__Warranty__c>> mapIBIdWarranty = new Map<ID, List<SVMXC__Warranty__c>>();
        Map<ID, List<string>> mapIBIdDataToUpdate = new Map<ID, List<string>>();
        List<SVMXC__Installed_Product__c> lstIB = new List<SVMXC__Installed_Product__c>();
        List<SVMXC__Installed_Product__c> lstIBToUpdate = new List<SVMXC__Installed_Product__c>();
        string wrnToUpdate;
        Date startDate;
        Date endDate;
        string exchangeType;
        
        List<SVMXC__Warranty__c> lstWarranty = new List<SVMXC__Warranty__c>();
        //COMM_PerformanceUtils.stop('003:a: Variable Declaration');
        //COMM_PerformanceUtils.start('003:b: Query for Warranties');
        List<String> queryFields = new List<String> {'Id', 'SVMXC__End_Date__c', 'SVMXC__Exchange_type__c', 'SVMXC__Installed_Product__c', 'SVMXC__Start_Date__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Warranty__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        lstWarranty = [select Id, SVMXC__End_Date__c, SVMXC__Exchange_type__c, SVMXC__Installed_Product__c, SVMXC__Start_Date__c from SVMXC__Warranty__c where SVMXC__Installed_Product__c IN: lstIBId AND SVMXC__Installed_Product__c != null]; //SDL-SVMX-READ-FLS-ENFORCED
        //COMM_PerformanceUtils.stop('003:b: Query for Warranties');
        //COMM_PerformanceUtils.start('003:c: Loop through Warranties');
        for(SVMXC__Warranty__c R : lstWarranty)
        {
            if(mapIBIdWarranty.containsKey(R.SVMXC__Installed_Product__c) == true)
                mapIBIdWarranty.get(R.SVMXC__Installed_Product__c).add(R);
            else
            {
                mapIBIdWarranty.put(R.SVMXC__Installed_Product__c, new List<SVMXC__Warranty__c>());
                mapIBIdWarranty.get(R.SVMXC__Installed_Product__c).add(R);
            }
        }
        //COMM_PerformanceUtils.stop('003:c: Loop through Warranties');
        system.debug('Map created: '+ mapIBIdWarranty);
        //COMM_PerformanceUtils.start('003:d: Loop through IB Ids');
        boolean isFoundValidWarranty = false;
        for(ID IBId : mapIBIdWarranty.keySet())
        {
            List<SVMXC__Warranty__c> wrntyLst = new List<SVMXC__Warranty__c>();
            List<string> dataToUpdate = new List<string>();
            wrntyLst = mapIBIdWarranty.get(IBId);
            for(SVMXC__Warranty__c wr : wrntyLst)
            {
                if((system.today() < wr.SVMXC__End_Date__c || system.today() == wr.SVMXC__End_Date__c) && (system.today() > wr.SVMXC__Start_Date__c || system.today() == wr.SVMXC__Start_Date__c))
                {
                    if(isFoundValidWarranty == true && wr.SVMXC__End_Date__c > endDate)
                    {
                        startDate = wr.SVMXC__Start_Date__c;
                        endDate = wr.SVMXC__End_Date__c;
                        exchangeType = wr.SVMXC__Exchange_type__c;
                        wrnToUpdate = wr.Id;
                    }
                    if(!isFoundValidWarranty)
                    {
                        startDate = wr.SVMXC__Start_Date__c;
                        endDate = wr.SVMXC__End_Date__c;
                        exchangeType = wr.SVMXC__Exchange_type__c;
                        wrnToUpdate = wr.Id;
                        isFoundValidWarranty = true;
                    }
                }
            }
            if(startDate != null && endDate != null && wrnToUpdate != null)
            {
                dataToUpdate.add(wrnToUpdate);
                dataToUpdate.add(string.valueOf(startDate));
                dataToUpdate.add(string.valueOf(endDate));
                dataToUpdate.add(exchangeType);
            }
            if(dataToUpdate.size() > 0)
                mapIBIdDataToUpdate.put(IBId, dataToUpdate);
        }
        //COMM_PerformanceUtils.stop('003:d: Loop through IB Ids');
        //COMM_PerformanceUtils.start('003:e: Query for IBs');
        queryFields = new List<String> {'Id', 'SVMXC__Warranty__c', 'SVMXC__Warranty_Start_Date__c', 'SVMXC__Warranty_End_Date__c', 'SVMXC__Warranty_Exchange_Type__c'};
        if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Installed_Product__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        lstIB = [select Id, SVMXC__Warranty__c, SVMXC__Warranty_Start_Date__c, SVMXC__Warranty_End_Date__c, SVMXC__Warranty_Exchange_Type__c from SVMXC__Installed_Product__c where id IN: lstIBId AND id != null]; //SDL-SVMX-READ-FLS-ENFORCED
        //COMM_PerformanceUtils.stop('003:e: Query for IBs');
        //COMM_PerformanceUtils.start('003:f: Loop through IBs');
        for(SVMXC__Installed_Product__c IB : lstIB)
        {
            List<string> dataToUpdate = mapIBIdDataToUpdate.get(IB.Id);
            if(dataToUpdate != null && dataToUpdate.size() >0)
            {
                if(IB.SVMXC__Warranty__c == dataToUpdate[0] 
                && IB.SVMXC__Warranty_Start_Date__c == date.valueOf(dataToUpdate[1])
                && IB.SVMXC__Warranty_End_Date__c == date.valueOf(dataToUpdate[2])
                && IB.SVMXC__Warranty_Exchange_Type__c == dataToUpdate[3])
                {
                    continue;
                }
                IB.SVMXC__Warranty__c = dataToUpdate[0];
                IB.SVMXC__Warranty_Start_Date__c = date.valueOf(dataToUpdate[1]);
                IB.SVMXC__Warranty_End_Date__c = date.valueOf(dataToUpdate[2]);
                IB.SVMXC__Warranty_Exchange_Type__c = dataToUpdate[3];
                lstIBToUpdate.add(IB);
            }
        }
        //COMM_PerformanceUtils.stop('003:f: Loop through IBs');
        //COMM_PerformanceUtils.start('003:g: Update IBs');
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstIBToUpdate, COMM_SecurityUtils.Access.Updateable ) ) {
            update lstIBToUpdate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        //COMM_PerformanceUtils.stop('003:g: Update IBs');
    }
    
    public void updateIBForCPs(List<String> lstCPID)
    {
        //COMM_PerformanceUtils.start('003:a: Future Method for Calculations Called');
        updateIBForInValidCoveredProduct(lstCPID);
        //COMM_PerformanceUtils.stop('003:a: Future Method for Calculations Called');
    }
    
    @future
    public static void updateIBForInValidCoveredProduct(List<String> lstCPID)
    {
        //Added by Naveen V on 10-April-2012 For Performance
        //COMM_PerformanceUtils perfUtil = new //COMM_PerformanceUtils();
        //perfUtil.begin();
        //COMM_PerformanceUtils.start('001: Variable Declarations');
        
        List<SVMXC__Installed_Product__c> lstIBToUpdate = new List<SVMXC__Installed_Product__c>();
        Map<ID, List<SVMXC__Service_Contract_Products__c>> mapIBIdLstCP = new Map<ID, List<SVMXC__Service_Contract_Products__c>>();
        Map<ID, List<SVMXC__Service_Contract_Products__c>> mapProdIdLstCP = new Map<ID, List<SVMXC__Service_Contract_Products__c>>();
        Map<ID, List<string>> mapIBIdDataToUpdate = new Map<ID, List<string>>();
        Map<ID, List<string>> mapProdIdDataToUpdate = new Map<ID, List<string>>();
        List<String> lstIBId = new List<String>();
        List<String> lstProdId = new List<String>();
        List<String> lstAccId = new List<String>();
        string cpToUpdate;
        string scToUpdate;
        Date startDate;
        Date endDate;
        string exchangeType;
        String strLogInfo = '';
        List<SVMXC__Service_Contract_Products__c> LstCP = new List<SVMXC__Service_Contract_Products__c>();
        //COMM_PerformanceUtils.stop('001: Variable Declarations');
        try
        {
            //COMM_PerformanceUtils.start('002: Query Covered Products');
            List<String> queryFields = new List<String> {'Id', 'SVMXC__End_Date__c', 'SVMXC__Installed_Product__c', 'SVMXC__Service_Contract__c', 'SVMXC__Service_Contract__r.SVMXC__End_Date__c', 'SVMXC__Service_Contract__r.SVMXC__Start_Date__c', 'SVMXC__Service_Contract__r.Id', 'SVMXC__Service_Contract__r.SVMXC__Exchange_Type__c', 'SVMXC__Service_Contract__r.SVMXC__Company__c', 'SVMXC__Start_Date__c', 'SVMXC__Exchange_Type__c', 'SVMXC__SLA_Terms__c', 'SVMXC__Product__c'};
            if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Service_Contract_Products__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            LstCP = [select Id, SVMXC__End_Date__c, SVMXC__Installed_Product__c, SVMXC__Service_Contract__c, SVMXC__Service_Contract__r.SVMXC__End_Date__c, SVMXC__Service_Contract__r.SVMXC__Start_Date__c, SVMXC__Service_Contract__r.Id, SVMXC__Service_Contract__r.SVMXC__Exchange_Type__c, SVMXC__Service_Contract__r.SVMXC__Company__c, SVMXC__Start_Date__c, SVMXC__Exchange_Type__c, SVMXC__SLA_Terms__c, SVMXC__Product__c from SVMXC__Service_Contract_Products__c where ID IN: lstCPID AND id != null]; //SDL-SVMX-READ-FLS-ENFORCED
            //COMM_PerformanceUtils.stop('002: Query Covered Products');
            //COMM_PerformanceUtils.start('003: Loop through Covered Products');
            for(SVMXC__Service_Contract_Products__c CP : LstCP)
            {
                if(CP.SVMXC__Installed_Product__c != null)
                {
                    if(mapIBIdLstCP.containsKey(CP.SVMXC__Installed_Product__c))
                        mapIBIdLstCP.get(CP.SVMXC__Installed_Product__c).add(CP);
                    else
                    {
                        mapIBIdLstCP.put(CP.SVMXC__Installed_Product__c, new List<SVMXC__Service_Contract_Products__c>());
                        mapIBIdLstCP.get(CP.SVMXC__Installed_Product__c).add(CP);
                    }
                    lstIBId.add(CP.SVMXC__Installed_Product__c);
                }
                if(CP.SVMXC__Product__c != null)
                {
                    if(mapProdIdLstCP.containsKey(CP.SVMXC__Product__c))
                        mapProdIdLstCP.get(CP.SVMXC__Product__c).add(CP);
                    else
                    {
                        mapProdIdLstCP.put(CP.SVMXC__Product__c, new List<SVMXC__Service_Contract_Products__c>());
                        mapProdIdLstCP.get(CP.SVMXC__Product__c).add(CP);
                    }
                    lstProdId.add(CP.SVMXC__Product__c);
                    lstAccId.add(CP.SVMXC__Service_Contract__r.SVMXC__Company__c);
                }
            }
            //COMM_PerformanceUtils.stop('003: Loop through Covered Products');
            system.debug('List of Product Ids: ' + lstProdId + ' and the size is: ' + lstProdId.size());
            system.debug('Map of Product Id and List CP: ' + mapProdIdLstCP + ' and the size is: ' + mapProdIdLstCP.size());
            
            boolean isFoundValidCPOrSCForIB = false;
            //COMM_PerformanceUtils.start('004: Loop through IBs in Covered Products');
            for(ID IBId : mapIBIdLstCP.keySet())
            {
                List<SVMXC__Service_Contract_Products__c> CPLst = new List<SVMXC__Service_Contract_Products__c>();
                List<string> dataToUpdate = new List<string>();
                CPLst = mapIBIdLstCP.get(IBId);
                for(SVMXC__Service_Contract_Products__c cp : CPLst)
                {
                    if(cp.SVMXC__End_Date__c != null && cp.SVMXC__Start_Date__c != null)
                    {
                        if((system.today() < cp.SVMXC__End_Date__c || system.today() == cp.SVMXC__End_Date__c) && (system.today() > cp.SVMXC__Start_Date__c || system.today() == cp.SVMXC__Start_Date__c))
                        {
                            if(isFoundValidCPOrSCForIB == true && cp.SVMXC__End_Date__c > endDate)
                            {
                                startDate = cp.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                            }
                            if(!isFoundValidCPOrSCForIB)
                            {
                                startDate = cp.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                                isFoundValidCPOrSCForIB = true;
                            }
                        }
                        else if((system.today() < cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c || system.today() == cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c) && (system.today() > cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c || system.today() == cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c))
                        {
                            if(isFoundValidCPOrSCForIB == true && cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c > endDate)
                            {
                                startDate = cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Service_Contract__r.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                            }
                            if(!isFoundValidCPOrSCForIB)
                            {
                                startDate = cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Service_Contract__r.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                                isFoundValidCPOrSCForIB = true;
                            }
                        }
                    }
                    else if(cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c != null && cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c != null)
                    {
                        if((system.today() < cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c || system.today() == cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c) && (system.today() > cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c || system.today() == cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c))
                        {
                            if(isFoundValidCPOrSCForIB == true && cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c > endDate)
                            {
                                startDate = cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Service_Contract__r.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                            }
                            if(!isFoundValidCPOrSCForIB)
                            {
                                startDate = cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Service_Contract__r.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                                isFoundValidCPOrSCForIB = true;
                            }
                        }
                    }
                }
                if(startDate != null && endDate != null && cpToUpdate != null && scToUpdate != null)
                {
                    dataToUpdate.add(cpToUpdate);
                    dataToUpdate.add(scToUpdate);
                    dataToUpdate.add(string.valueOf(startDate));
                    dataToUpdate.add(string.valueOf(endDate));
                    dataToUpdate.add(exchangeType);
                }
                if(dataToUpdate.size() > 0)
                    mapIBIdDataToUpdate.put(IBId, dataToUpdate);
            }
            //COMM_PerformanceUtils.stop('004: Loop through IBs in Covered Products');
            boolean isFoundValidCPOrSCForProd = false;
            //COMM_PerformanceUtils.start('005: Loop through Product Ids in Covered Products');
            for(ID ProdId : mapProdIdLstCP.keySet())
            {
                List<SVMXC__Service_Contract_Products__c> CPLst = new List<SVMXC__Service_Contract_Products__c>();
                List<string> dataToUpdate = new List<string>();
                CPLst = mapProdIdLstCP.get(ProdId);
                for(SVMXC__Service_Contract_Products__c cp : CPLst)
                {
                    if(cp.SVMXC__End_Date__c != null && cp.SVMXC__Start_Date__c != null)
                    {
                        if((system.today() < cp.SVMXC__End_Date__c || system.today() == cp.SVMXC__End_Date__c) && (system.today() > cp.SVMXC__Start_Date__c || system.today() == cp.SVMXC__Start_Date__c))
                        {
                            if(isFoundValidCPOrSCForProd == true && cp.SVMXC__End_Date__c > endDate)
                            {
                                startDate = cp.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                            }
                            if(!isFoundValidCPOrSCForProd)
                            {
                                startDate = cp.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                                isFoundValidCPOrSCForProd = true;
                            }
                        }
                        else if((system.today() < cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c || system.today() == cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c) && (system.today() > cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c || system.today() == cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c))
                        {
                            if(isFoundValidCPOrSCForProd == true && cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c > endDate)
                            {
                                startDate = cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Service_Contract__r.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                            }
                            if(!isFoundValidCPOrSCForProd)
                            {
                                startDate = cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Service_Contract__r.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                                isFoundValidCPOrSCForProd = true;
                            }
                        }
                    }
                    else if(cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c != null && cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c != null)
                    {
                        if((system.today() < cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c || system.today() == cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c) && (system.today() > cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c || system.today() == cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c))
                        {
                            if(isFoundValidCPOrSCForProd == true && cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c > endDate)
                            {
                                startDate = cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Service_Contract__r.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                            }
                            if(!isFoundValidCPOrSCForProd)
                            {
                                startDate = cp.SVMXC__Service_Contract__r.SVMXC__Start_Date__c;
                                endDate = cp.SVMXC__Service_Contract__r.SVMXC__End_Date__c;
                                exchangeType = cp.SVMXC__Service_Contract__r.SVMXC__Exchange_type__c;
                                cpToUpdate = cp.Id;
                                scToUpdate = cp.SVMXC__Service_Contract__r.Id;
                                isFoundValidCPOrSCForProd = true;
                            }
                        }
                    }
                }
                if(startDate != null && endDate != null && cpToUpdate != null && scToUpdate != null)
                {
                    dataToUpdate.add(cpToUpdate);
                    dataToUpdate.add(scToUpdate);
                    dataToUpdate.add(string.valueOf(startDate));
                    dataToUpdate.add(string.valueOf(endDate));
                    dataToUpdate.add(exchangeType);
                }
                if(dataToUpdate.size() > 0)
                    mapProdIdDataToUpdate.put(ProdId, dataToUpdate);
            }
            //COMM_PerformanceUtils.stop('005: Loop through Product Ids in Covered Products');
            system.debug('Map of Product Id and the Data to Update: ' + mapProdIdDataToUpdate + ' and size is: ' + mapProdIdDataToUpdate.size());
            //COMM_PerformanceUtils.start('006: Query IBs');
            queryFields = new List<String> {'Id', 'SVMXC__Service_Contract_Line__c', 'SVMXC__Service_Contract__c', 'SVMXC__Service_Contract_Start_Date__c', 'SVMXC__Service_Contract_End_Date__c', 'SVMXC__Service_Contract_Exchange_Type__c', 'SVMXC__Product__c'};
            if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Installed_Product__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__Installed_Product__c> lstIB = [select Id, SVMXC__Service_Contract_Line__c, SVMXC__Service_Contract__c, SVMXC__Service_Contract_Start_Date__c, SVMXC__Service_Contract_End_Date__c, SVMXC__Service_Contract_Exchange_Type__c, SVMXC__Product__c from SVMXC__Installed_Product__c where id IN: lstIBId OR (SVMXC__Product__c IN: lstProdId AND SVMXC__Product__c != null AND (SVMXC__Service_Contract_End_Date__c = null OR SVMXC__Service_Contract_End_Date__c <: system.today()) AND SVMXC__Company__c IN: lstAccId)]; //SDL-SVMX-READ-FLS-ENFORCED
            //COMM_PerformanceUtils.stop('006: Query IBs');
            system.debug('List of IBs to be Updated before updation: ' + lstIB);
            //COMM_PerformanceUtils.start('007: Loop through IBs');
            for(SVMXC__Installed_Product__c IB : lstIB)
            {
                List<string> dataToUpdate = mapIBIdDataToUpdate.get(IB.Id);
                if(dataToUpdate != null && dataToUpdate.size() >0)
                {
                    IB.SVMXC__Service_Contract_Line__c = dataToUpdate[0];
                    IB.SVMXC__Service_Contract__c = dataToUpdate[1];
                    IB.SVMXC__Service_Contract_Start_Date__c = date.valueOf(dataToUpdate[2]);
                    IB.SVMXC__Service_Contract_End_Date__c = date.valueOf(dataToUpdate[3]);
                    IB.SVMXC__Service_Contract_Exchange_Type__c = dataToUpdate[4];
                    lstIBToUpdate.add(IB);
                }
                else
                {
                    dataToUpdate = mapProdIdDataToUpdate.get(IB.SVMXC__Product__c);
                    if(dataToUpdate != null && dataToUpdate.size() >0)
                    {
                        IB.SVMXC__Service_Contract_Line__c = dataToUpdate[0];
                        IB.SVMXC__Service_Contract__c = dataToUpdate[1];
                        IB.SVMXC__Service_Contract_Start_Date__c = date.valueOf(dataToUpdate[2]);
                        IB.SVMXC__Service_Contract_End_Date__c = date.valueOf(dataToUpdate[3]);
                        IB.SVMXC__Service_Contract_Exchange_Type__c = dataToUpdate[4];
                        lstIBToUpdate.add(IB);
                    }
                }
            }
            //COMM_PerformanceUtils.stop('007: Loop through IBs');
            system.debug('List of IBs to Updated: ' + lstIB);
            //COMM_PerformanceUtils.start('008: Update IBs');
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstIBToUpdate, COMM_SecurityUtils.Access.Updateable ) ) {
                update lstIBToUpdate; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            //COMM_PerformanceUtils.stop('008: Update IBs');
            
            /* if(lstIBToUpdate != null && lstIBToUpdate.size() > 0)
            for(SVMXC__Installed_Product__c str: lstIBToUpdate)
                perfUtil.end(string.valueOf(str.Id), 'Future Method call from Trigger: APL_UpdateIBForCoveredProduct/APL_UpdateIBForContract'); */
        }catch(Exception ex)
        {
            //COMM_PerformanceUtils.start('EX: Exception Occured sending Email to Notify');
            String emailID = '';
            Map<String, String> svmxSettingList = new Map<String,String>();
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            svmxSettingList = commSettings.SVMX_getSettingList('GLOB001');
            emailID = string.valueOf(svmxSettingList.get('GBL015'));
            if(emailID != null && emailID != '' && emailID.length() > 0)
            {
                APL_Entitlement aplEntitleObj = new APL_Entitlement();
                strLogInfo = aplEntitleObj.getTAG003() + '\n\n';
                strLogInfo = ex.getMessage();
                failureStatusEmail(strLogInfo, emailID);
            }
            //COMM_PerformanceUtils.stop('EX: Exception Occured sending Email to Notify');
            
            /* if(LstCP != null && LstCP.size() > 0)
            for(SVMXC__Service_Contract_Products__c str: LstCP)
                perfUtil.end(string.valueOf(str.Id), 'Exception occured while Future Method call from Trigger: APL_UpdateIBForCoveredProduct/APL_UpdateIBForContract'); */
        }
    }
    
    public static void failureStatusEmail(String strMsg, String emailID)//,Boolean isException)
    {
          APL_Entitlement aplEntitleObj = new APL_Entitlement();
          Messaging.SingleEmailMessage objMailShpMessage = new Messaging.SingleEmailMessage();
          objMailShpMessage.setToAddresses(new String[] {emailID});
          objMailShpMessage.setSenderDisplayName(aplEntitleObj.getTAG001());
          objMailShpMessage.setSubject(aplEntitleObj.getTAG002());
          objMailShpMessage.setBccSender(false);
          objMailShpMessage.setUseSignature(false);
          objMailShpMessage.setPlainTextBody(strMsg);
        if(!Test.isRunningTest())
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMailShpMessage });       
    }
    
    public string getTAG001(){return system.label.APL001_TAG020;} //'ServiceMax'
    public string getTAG002(){return system.label.APL001_TAG021;} //'ServiceMax error occurred in Entitlement pre-calculation'
    public string getTAG003(){return system.label.APL001_TAG022;} //'The following error occurred in in Service Contract entitlement pre-calculation feature of ServiceMax. Please contact your ServiceMax administrator for assistance:'
}