public with sharing class APL_Inventory 
{
    public Boolean allowStockHistory = true;
    public Boolean allowSerialHistrory = true;
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse PopulateProductStockAndStockSerial(SVMXC.INTF_WebServicesDef.APL_Order aplOrder)
    {
        system.debug('Inv Called..'+aplOrder);
        
        //Added by Naveen V on 13-March-2012 For Performance
        //COMM_PerformanceUtils.start('8.d.1.INVENTORY-UPDATES - ActualInventoryMethodCalled - VariableDeclarationQueryRT');
        
        SVMXC.INTF_WebServicesDef.APL_Order responseALPOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        response.success = true;
        String strSourceLocation = '';
        String strTargetLocation = '';
        String strStatus = '';
        String strStockHistoryRtypeId = '';
        String strSerialHistoryRtypeId = '';    
        String strDepotLocationRtypeId = '';
        map<String,String> mapLineIdDeliveryLoationId = new map<String,String>();
        map<String,SVMXC__Product_Stock__c> mapProductStock = new map<String,SVMXC__Product_Stock__c>();
        map<String,SVMXC__Product_Stock__c> mapUniqueKeyProductStock = new map<String,SVMXC__Product_Stock__c>();
        list<SVMXC__Product_Stock__c> lstNewPS = new list<SVMXC__Product_Stock__c>();
        map<String,SVMXC__Stock_History__c> mapStockHistory = new map<String,SVMXC__Stock_History__c>();
        map<String,SVMXC__Product_Serial__c> mapStockSerial = new map<String,SVMXC__Product_Serial__c>(); 
        map<String,list<SVMXC__Product_Serial__c>> mapPSIdListStockSerial = new map<String,list<SVMXC__Product_Serial__c>>(); 
        list<SVMXC__Product_Serial__c> lstProSerialTobeUpserted = new list<SVMXC__Product_Serial__c>();
        list<SVMXC__Stock_History__c> lstStockSerialHistoryToBeUpserted = new list<SVMXC__Stock_History__c>();
        map<String,list<SVMXC__Stock_History__c>> mapProdStockIdSerialHistoryRec = new map<String,list<SVMXC__Stock_History__c>>();  
        set<String> setProductId = new set<String>();
        set<String> setShipmetLineId = new set<String>();
        set<String> setDeliveryLocationId = new set<String>();
        map<String,String> mapLineIdUniqueIdForClient = new map<String,String>();
        //Get the record tye of stcok history record..
        List<RecordType> RecordTypes = new List<RecordType>();
        
        List<String> queryFields = new List<String> {'Name','Id','SobjectType'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'RecordType', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        RecordTypes = [Select Name, Id From RecordType where SobjectType = 'SVMXC__Stock_History__c' OR SobjectType = 'SVMXC__Site__c']; //SDL-SVMX-READ-FLS-ENFORCED
        if(RecordTypes.size() > 0 )
        {
            for(RecordType r : RecordTypes)
            {
                if(r.Name == 'Stock History')
                    strStockHistoryRtypeId = r.id;
                else if(r.Name == 'Serial History')
                    strSerialHistoryRtypeId = r.id;
                else if(r.Name == 'Depot')
                    strDepotLocationRtypeId = r.id;    
            }
        }
        //Added by Naveen V on 13-March-2012 For Performance
        //COMM_PerformanceUtils.stop('8.d.1.INVENTORY-UPDATES - ActualInventoryMethodCalled - VariableDeclarationQueryRT');
        
        //Based on the Type of process first get the ProductStock records and then do the ProductStock Update.
        if(aplOrder.processType.touppercase() == 'PROCESSRECEIPT')
        {
        
            //COMM_PerformanceUtils.start('8.d.2.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryTargetLoc');
            //No Source Location Comes in picture For Process Receipt as discussed with Hari.
            /*if(aplOrder.orderHdrRecord != null && aplOrder.orderHdrRecord.SVMXC__Source_Location__c != null)
                strSourceLocation = aplOrder.orderHdrRecord.SVMXC__Source_Location__c;
                
            //If Given Source Location is Depot location than consider Depot's Receiving location as Source Location 
            
            list<SVMXC__Site__c> lstDepotLocation = new list<SVMXC__Site__c>();
            lstDepotLocation = [select id,Name,RecordTypeId From SVMXC__Site__c where id =: strSourceLocation and RecordTypeId =: strDepotLocationRtypeId];
            if(lstDepotLocation.size() > 0)
            {
                 list<SVMXC__Site__c> lstDepotsReceivingLocation = new list<SVMXC__Site__c>();
                 lstDepotsReceivingLocation = [select id,Name,RecordTypeId,SVMXC__Parent__c,SVMXC__IsReceiving_Location__c from SVMXC__Site__c where SVMXC__Parent__c =: lstDepotLocation[0].id and SVMXC__IsReceiving_Location__c = true and RecordType.Name = 'Depot Child'];
                 if(lstDepotsReceivingLocation.size() > 0)
                    strSourceLocation = lstDepotsReceivingLocation[0].id;   
            }*/
                
            if(aplOrder.orderHdrRecord != null && aplOrder.orderHdrRecord.SVMXC__Destination_Location__c != null)
                strTargetLocation = aplOrder.orderHdrRecord.SVMXC__Destination_Location__c;
             
            //If Given Target Location is Depot location than consider Depot's Receiving location as Target Location 
            list<SVMXC__Site__c> lstDepotLocation = new list<SVMXC__Site__c>();
            
            List<String> queryFieldslstDepotLocation = new List<String> {'id', 'RecordTypeId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFieldslstDepotLocation, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            lstDepotLocation = [select id From SVMXC__Site__c where id =: strTargetLocation and RecordTypeId =: strDepotLocationRtypeId]; //SDL-SVMX-READ-FLS-ENFORCED
            //COMM_PerformanceUtils.stop('8.d.2.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryTargetLoc');
            
            if(lstDepotLocation.size() > 0)
            {
            
                //COMM_PerformanceUtils.start('8.d.3.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotsReceivingLocation');
                list<SVMXC__Site__c> lstDepotsReceivingLocation = new list<SVMXC__Site__c>();
                
                List<String> queryFieldslstDepotsReceivingLocation = new List<String> {'id', 'SVMXC__Parent__c', 'SVMXC__IsReceiving_Location__c', 'RecordType.Name', 'SVMXC__Stocking_Location__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFieldslstDepotsReceivingLocation, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                lstDepotsReceivingLocation = [select id from SVMXC__Site__c where SVMXC__Parent__c =: lstDepotLocation[0].id and SVMXC__IsReceiving_Location__c = true and RecordType.Name = 'Depot Child' and SVMXC__Stocking_Location__c = true]; //SDL-SVMX-READ-FLS-ENFORCED
                //COMM_PerformanceUtils.stop('8.d.3.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotsReceivingLocation');
                if(lstDepotsReceivingLocation.size() > 0)
                    strTargetLocation = lstDepotsReceivingLocation[0].id;  
                else
                {
                    //response.success = false;
                    //response.message = 'Receiveing Location is not configured for this deopt';
                    return response;
                }   

                
            }
            system.debug('strSourceLocation: '+strSourceLocation + ' '+'strTargetLocation: '+strTargetLocation);
            system.debug('aplOrder'+aplOrder.orderLines.size()+aplOrder.orderLines);
            Set<String> receivedSerialNos = new set<String>();
            //Loop The APL Order Lines and take All Product Ids So we Can Query Product Stock Record in Bulk.
            if(aplOrder.orderLines.size() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.4.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopOrderLines');
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    mapLineIdUniqueIdForClient.put(aplOrder.orderLines[i].orderLineRecord.Id,aplOrder.orderLines[i].uniqueIdForClient);
                    if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Product__c != null)
                        setProductId.add(aplOrder.orderLines[i].orderLineRecord.SVMXC__Product__c);
                    list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> receivedSerialNoCollection = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                    if(aplOrder.orderLines[i].serialNumbers != null && aplOrder.orderLines[i].serialNumbers.size() > 0)
                    {
                        receivedSerialNoCollection = aplOrder.orderLines[i].serialNumbers;
                        for(Integer j = 0;j<receivedSerialNoCollection.size();j++)
                        {
                            if(receivedSerialNoCollection[j].isReceived != null && receivedSerialNoCollection[j].isReceived)
                                receivedSerialNos.add(receivedSerialNoCollection[j].serialNumber);
                        }
                    }    
                }
                
                //COMM_PerformanceUtils.stop('8.d.4.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopOrderLines');
            }
            system.debug('mapLineIdUniqueIdForClient'+mapLineIdUniqueIdForClient.size()+mapLineIdUniqueIdForClient);
            system.debug('setProductId'+setProductId.size()+setProductId);
            //Get the product stock for source location
            if(setProductId.size() > 0 && strSourceLocation != null && strSourceLocation.length() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.5.INVENTORY-UPDATES - ActualInventoryMethodCalled - RetrivingProdStockSourceLoc');

                map<String,SVMXC__Product_Stock__c> mapTemp = new map<String,SVMXC__Product_Stock__c>();
                
                List<String> queryFieldsProductStock = new List<String> {'SVMXC__Status__c','SVMXC__Quantity2__c','SVMXC__Product__c','SVMXC__Location__c','Name','Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFieldsProductStock, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                mapTemp.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Name, Id From SVMXC__Product_Stock__c where SVMXC__Status__c =: 'In Transit' and SVMXC__Product__c IN : setProductId and SVMXC__Location__c =: strSourceLocation]);
                system.debug('mapTemp'+mapTemp.size()+mapTemp);
                if(mapTemp.size() > 0)
                    mapProductStock.putall(mapTemp);
                    
                //COMM_PerformanceUtils.stop('8.d.5.INVENTORY-UPDATES - ActualInventoryMethodCalled - RetrivingProdStockSourceLoc');
            }
            
            //Get the product stock for target location
            if(setProductId.size() > 0 && strTargetLocation != null && strTargetLocation.length() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.6.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProdStockTargetLoc');
            
                map<String,SVMXC__Product_Stock__c> mapTemp = new map<String,SVMXC__Product_Stock__c>();
                List<String> queryFieldsProductStockAvailable = new List<String> {'SVMXC__Status__c','SVMXC__Quantity2__c','SVMXC__Product__c','SVMXC__Location__c','Name','Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFieldsProductStockAvailable, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                mapTemp.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Name, Id From SVMXC__Product_Stock__c where SVMXC__Status__c =: 'Available' and SVMXC__Product__c IN : setProductId and SVMXC__Location__c =: strTargetLocation]);
                system.debug('mapTemp'+mapTemp.size()+mapTemp);
                if(mapTemp.size() > 0)
                    mapProductStock.putall(mapTemp);
                    
                //COMM_PerformanceUtils.stop('8.d.6.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProdStockTargetLoc');    
                    
            }
            system.debug('mapProductStock'+mapProductStock.size()+mapProductStock);
            // Create map of Uniquekey(ProductID_LocationID_Status) and Product Stock Record..
            if(mapProductStock.size() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.7.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopToCreateMAPKeyToPS');
                for(String s:mapProductStock.keyset())
                {
                    if(mapProductStock.get(s).SVMXC__Product__c != null && mapProductStock.get(s).SVMXC__Location__c != null && mapProductStock.get(s).SVMXC__Status__c != null)
                    {
                        String strUniqueKey = String.valueof(mapProductStock.get(s).SVMXC__Product__c).substring(0,15)+'_'+String.valueof(mapProductStock.get(s).SVMXC__Location__c).substring(0,15)+'_'+mapProductStock.get(s).SVMXC__Status__c;
                        mapUniqueKeyProductStock.put(strUniqueKey,mapProductStock.get(s));
                    }    
                }
                //COMM_PerformanceUtils.stop('8.d.7.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopToCreateMAPKeyToPS'); 
            }
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
        
        
            //COMM_PerformanceUtils.start('8.d.8.INVENTORY-UPDATES - ActualInventoryMethodCalled - RetrivingStockedSerial');
            
            //Retrive the Stocked serial for all Porduct stock.
            if(mapProductStock.size() > 0){
                List<String> queryFieldsmapStockSerial = new List<String> {'SVMXC__Product__c','SVMXC__Product_Stock__c','SVMXC__Active__c','Name','Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Serial__c', queryFieldsmapStockSerial, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                mapStockSerial.putall([Select SVMXC__Product__c, SVMXC__Product_Stock__c, SVMXC__Active__c, Name, Id From SVMXC__Product_Serial__c where SVMXC__Product_Stock__c IN : mapProductStock.keyset() and Name IN : receivedSerialNos]);
            }
             
            //COMM_PerformanceUtils.stop('8.d.8.INVENTORY-UPDATES - ActualInventoryMethodCalled - RetrivingStockedSerial'); 
            
            system.debug('mapStockSerial'+mapStockSerial);
            //Create a map of PSId and List<SVMXC__Product_Serial__c> 
            if(mapStockSerial.size() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.9.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopPSToLstSS');
                for(String str:mapStockSerial.keyset())
                {
                    if(mapStockSerial.get(str).SVMXC__Product_Stock__c != null)
                    {
                        String strPSId = string.valueof(mapStockSerial.get(str).SVMXC__Product_Stock__c);
                        if(mapPSIdListStockSerial.containskey(strPSId))
                            mapPSIdListStockSerial.get(strPSId).add(mapStockSerial.get(str));
                        else
                        {
                            mapPSIdListStockSerial.put(strPSId,new list<SVMXC__Product_Serial__c>());
                            mapPSIdListStockSerial.get(strPSId).add(mapStockSerial.get(str));
                        }     
                    }
                }
                //COMM_PerformanceUtils.start('8.d.9.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopPSToLstSS');
            }
            system.debug('mapPSIdListStockSerial'+mapPSIdListStockSerial);
            // Now Loop APL Order Line and For the given APL Order Line Create a Unique Key Of ProductID_LocationID_Status Chekc if the Unique is exsist in
            //mapUniqueKeyProductStock if not then create a new product also create stock History records for all,,
            if(aplOrder.orderLines.size() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.10.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingKeyOfProdID_LocID_Status');
            
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    Double intExsistingQty = 0;
                    //No Source Location Comes in picture For Process Receipt as discussed with Hari.
                    /*if(strSourceLocation != null && strSourceLocation.length() > 0 && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_In Transit';
                        String strUniqueForStockHistory =  String.valueof(objLine.id).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_In Transit';
                        system.debug('strUnique'+strUnique);
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                        {
                            //For Process Receipt and Source Location Decrease the  Quntity of product stock.
                            intExsistingQty = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c =  mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c - objLine.SVMXC__Actual_Quantity2__c;
                        }   
                        else
                        {
                            system.debug('asdfggh'+mapUniqueKeyProductStock.containskey(strUnique));
                            intExsistingQty = 0;
                            SVMXC__Product_Stock__c objPS = new SVMXC__Product_Stock__c();
                            objPS.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objPS.SVMXC__Location__c = strSourceLocation;
                            objPS.SVMXC__Status__c = 'In Transit';
                            objPS.SVMXC__Quantity2__c = objLine.SVMXC__Actual_Quantity2__c;
                            //lstNewPS.add(objPS);
                            mapUniqueKeyProductStock.put(strUnique,objPS);
                        }
                        //Create Stock History Record.
                        SVMXC__Stock_History__c objSH = new SVMXC__Stock_History__c();
                        objSH.RecordTypeId = strStockHistoryRtypeId;
                        objSH.SVMXC__Product__c = objLine.SVMXC__Product__c;
                        objSH.SVMXC__Location__c = strSourceLocation;
                        objSH.SVMXC__Status__c = 'In Transit';
                        objSH.SVMXC__Transaction_Type__c  = 'Process Receipt';
                        objSH.SVMXC__Quantity_before_change2__c = intExsistingQty;
                        objSH.SVMXC__Transaction_Quantity2__c  = objLine.SVMXC__Actual_Quantity2__c;
                        objSH.SVMXC__Quantity_after_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                        objSH.SVMXC__Change_Type__c  = 'Decrease' ;
                        objSH.SVMXC__Date_Changed__c  = system.now();
                        objSH.SVMXC__Changed_By__c  = Userinfo.getUserId() ;
                        objSH.SVMXC__RMA__c  = aplOrder.orderHdrRecord.id;
                        objSH.SVMXC__RMA_Line__c  = objLine.id;
                        mapStockHistory.put(strUniqueForStockHistory,objSH);   
                    }*/
                    if(strTargetLocation != null && strTargetLocation.length() > 0 && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strTargetLocation.substring(0,15)+'_Available';
                        String strUniqueForStockHistory =  String.valueof(objLine.id).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strTargetLocation.substring(0,15)+'_Available';
                        system.debug('strUnique'+strUnique);
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                        {
                            //aplOrder.orderLines[i].targetLocationPSID = mapUniqueKeyProductStock.get(strUnique).id;
                            
                            //For Process Receipt and Target Location Increase the Product Quntity 
                            intExsistingQty = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c =  mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c + objLine.SVMXC__Actual_Quantity2__c;
                        }   
                        else
                        {
                            system.debug('asdfggh'+mapUniqueKeyProductStock.containskey(strUnique));
                            SVMXC__Product_Stock__c objPS = new SVMXC__Product_Stock__c();
                            objPS.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objPS.SVMXC__Location__c = strTargetLocation;
                            objPS.SVMXC__Status__c = 'Available';
                            objPS.SVMXC__Quantity2__c = objLine.SVMXC__Actual_Quantity2__c;
                            mapUniqueKeyProductStock.put(strUnique,objPS);
                        }
                        if(allowStockHistory)
                        {
                            //Create Stock History Record.
                            SVMXC__Stock_History__c objSH = new SVMXC__Stock_History__c();
                            objSH.RecordTypeId = strStockHistoryRtypeId;
                            objSH.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objSH.SVMXC__Location__c = strTargetLocation;
                            objSH.SVMXC__Status__c = 'Available';
                            objSH.SVMXC__Transaction_Type__c  = 'Process Receipt';
                            objSH.SVMXC__Quantity_before_change2__c = intExsistingQty;
                            objSH.SVMXC__Transaction_Quantity2__c  = objLine.SVMXC__Actual_Quantity2__c;
                            objSH.SVMXC__Quantity_after_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            objSH.SVMXC__Change_Type__c  = 'Increase' ;
                            objSH.SVMXC__Date_Changed__c  = system.now();
                            objSH.SVMXC__Changed_By__c  = Userinfo.getUserId() ;
                            objSH.SVMXC__RMA__c  = aplOrder.orderHdrRecord.id;
                            objSH.SVMXC__RMA_Line__c  = objLine.id;
                            mapStockHistory.put(strUniqueForStockHistory,objSH);
                        }        
                    }
                }
                
                //COMM_PerformanceUtils.stop('8.d.10.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingKeyOfProdID_LocID_Status');
            }
            system.debug('mapStockHistory'+mapStockHistory);
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
            //COMM_PerformanceUtils.start('8.d.11.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertPS');
            if(mapUniqueKeyProductStock.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapUniqueKeyProductStock.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapUniqueKeyProductStock.values(); 
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
                
            //COMM_PerformanceUtils.stop('8.d.11.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertPS');
            system.debug('mapProductStock'+mapProductStock);
            //Populate the Product StockIds in Stock History Record.. 
            if(mapStockHistory.size() > 0 && allowStockHistory)
            {
            
                //COMM_PerformanceUtils.start('8.d.12.INVENTORY-UPDATES - ActualInventoryMethodCalled - PopulateStockHistoryRecord');
                for(String str : mapStockHistory.keyset())
                {
                    String strUniqueKey = str.substring(16,str.length());
                    system.debug('strUniqueKey'+strUniqueKey+mapProductStock.containskey(strUniqueKey));
                    if(mapUniqueKeyProductStock.containskey(strUniqueKey))
                    {
                        system.debug('Entered..');
                        mapStockHistory.get(str).SVMXC__Product_Stock__c = mapUniqueKeyProductStock.get(strUniqueKey).id;
                    }
                }
                system.debug('mapStockHistory'+mapStockHistory.values());
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapStockHistory.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapStockHistory.values(); 
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                //COMM_PerformanceUtils.stop('8.d.12.INVENTORY-UPDATES - ActualInventoryMethodCalled - PopulateStockHistoryRecord');
            }    
            //populate the PS id in the remailning Order Lines.
            if(aplOrder.orderLines.size() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.13.INVENTORY-UPDATES - ActualInventoryMethodCalled - PopulateRemailningOrderLines');
                
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    if(strSourceLocation != null && strSourceLocation.length() > 0 && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_In Transit';
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                            aplOrder.orderLines[i].sourceLocationPSID = mapUniqueKeyProductStock.get(strUnique).id;
                    }
                    if(strTargetLocation != null && strTargetLocation.length() > 0 && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strTargetLocation.substring(0,15)+'_Available';
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                            aplOrder.orderLines[i].targetLocationPSID = mapUniqueKeyProductStock.get(strUnique).id;
                    }
                }
                
                //COMM_PerformanceUtils.stop('8.d.13.INVENTORY-UPDATES - ActualInventoryMethodCalled - PopulateRemailningOrderLines');
            }
            system.debug('asdfgh'+aplOrder.orderLines);
            //Now loop through the APL Order and check that all sourceLocationPSID have the stock serial other wise create the stock serial for those and populate the targetLocationPSID in it.
            if(aplOrder.orderLines.size() > 0)
            {
            
                //COMM_PerformanceUtils.start('8.d.14.INVENTORY-UPDATES - ActualInventoryMethodCalled - VerifyAplOrder');
                
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    list<SVMXC__Product_Serial__c> lstTempProductSerial;
                    list<SVMXC__Stock_History__c> lstTempStockSerialHistry;
                    //If Stock Serial Record Is Available then only change the Product Stock Id(From PS to To PS)
                    if(mapPSIdListStockSerial.containskey(aplOrder.orderLines[i].sourceLocationPSID))
                    {
                    
                        //COMM_PerformanceUtils.start('8.d.14.a.INVENTORY-UPDATES - ActualInventoryMethodCalled - VerifyAplOrder - ChangeProdId');
                        lstTempProductSerial = new list<SVMXC__Product_Serial__c>();
                        lstTempProductSerial = mapPSIdListStockSerial.get(aplOrder.orderLines[i].sourceLocationPSID);
                        if(lstTempProductSerial.size() > 0)
                        {
                        
                            lstTempStockSerialHistry = new list<SVMXC__Stock_History__c>();
                            for(SVMXC__Product_Serial__c ps : lstTempProductSerial)
                            {
                                ps.SVMXC__Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;
                                if(allowSerialHistrory)
                                {
                                    //Create Serial History Record..
                                    SVMXC__Stock_History__c serialHistory = new SVMXC__Stock_History__c();
                                    serialHistory.RecordTypeId = strSerialHistoryRtypeId;
                                    serialHistory.SVMXC__From_Product_Stock__c = aplOrder.orderLines[i].sourceLocationPSID;
                                    serialHistory.SVMXC__To_Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;
                                    serialHistory.SVMXC__Transaction_Type__c = 'Process Receipt';
                                    serialHistory.SVMXC__Date_Changed__c = system.now();
                                    serialHistory.SVMXC__Changed_By__c = userinfo.getUserId();
                                    serialHistory.SVMXC__RMA__c  = aplOrder.orderHdrRecord.id;
                                    serialHistory.SVMXC__RMA_Line__c  = aplOrder.orderLines[i].orderLineRecord.id;
                                    lstTempStockSerialHistry.add(serialHistory);
                                }   
                            }
                            if(lstTempStockSerialHistry.size() > 0)
                            {
                                if(mapProdStockIdSerialHistoryRec.containskey(aplOrder.orderLines[i].targetLocationPSID))
                                {
                                    mapProdStockIdSerialHistoryRec.get(aplOrder.orderLines[i].targetLocationPSID).addall(lstTempStockSerialHistry);
                                }
                                else
                                {
                                    mapProdStockIdSerialHistoryRec.put(aplOrder.orderLines[i].targetLocationPSID,lstTempStockSerialHistry);
                                }
                                //mapProdStockIdSerialHistoryRec.put(aplOrder.orderLines[i].targetLocationPSID,lstTempStockSerialHistry);
                            }   
                                    
                        }
                        lstProSerialTobeUpserted.addall(lstTempProductSerial);
                        
                    //COMM_PerformanceUtils.stop('8.d.14.a.INVENTORY-UPDATES - ActualInventoryMethodCalled - VerifyAplOrder - ChangeProdId');       
                    }
                    //Otherwise Create New Stock Serial reocord with TO PS Id..
                    else
                    {
                    
                        //COMM_PerformanceUtils.start('8.d.14.a.INVENTORY-UPDATES - ActualInventoryMethodCalled - VerifyAplOrder - CreateStockRecord');
                        
                        system.debug('Enterd in..');
                        list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> serialCollection = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                        if(aplOrder.orderLines[i].serialNumbers.size() > 0)
                        {
                            serialCollection = aplOrder.orderLines[i].serialNumbers;
                            lstTempProductSerial = new list<SVMXC__Product_Serial__c>();
                            lstTempStockSerialHistry = new list<SVMXC__Stock_History__c>();
                            for(Integer j = 0;j<serialCollection.size();j++)
                            {
                                if(serialCollection[j].isReceived != null && serialCollection[j].isReceived == true)
                                {
                                    SVMXC__Product_Serial__c objProductSerial = new SVMXC__Product_Serial__c();
                                    objProductSerial.SVMXC__Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;
                                    objProductSerial.Name = serialCollection[j].serialNumber;
                                    objProductSerial.SVMXC__Product__c = aplOrder.orderLines[i].orderLineRecord.SVMXC__Product__c;
                                    lstTempProductSerial.add(objProductSerial);
                                    if(allowSerialHistrory)
                                    {
                                        //Create Serial History Record..
                                        SVMXC__Stock_History__c serialHistory = new SVMXC__Stock_History__c();
                                        serialHistory.RecordTypeId = strSerialHistoryRtypeId;
                                        serialHistory.SVMXC__To_Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;
                                        serialHistory.SVMXC__Transaction_Type__c = 'Process Receipt';
                                        serialHistory.SVMXC__Date_Changed__c = system.now();
                                        serialHistory.SVMXC__Changed_By__c = userinfo.getUserId();
                                        serialHistory.SVMXC__RMA__c  = aplOrder.orderHdrRecord.id;
                                        serialHistory.SVMXC__RMA_Line__c  = aplOrder.orderLines[i].orderLineRecord.id;
                                        lstTempStockSerialHistry.add(serialHistory);
                                    }   
                                }   
                            }
                            if(lstTempStockSerialHistry.size() > 0)
                            {
                                if(mapProdStockIdSerialHistoryRec.containskey(aplOrder.orderLines[i].targetLocationPSID))
                                {
                                    mapProdStockIdSerialHistoryRec.get(aplOrder.orderLines[i].targetLocationPSID).addall(lstTempStockSerialHistry);
                                }
                                else
                                {
                                    mapProdStockIdSerialHistoryRec.put(aplOrder.orderLines[i].targetLocationPSID,lstTempStockSerialHistry);
                                }   
                            }    
                            lstProSerialTobeUpserted.addall(lstTempProductSerial);
                        }   
                        
                        //COMM_PerformanceUtils.stop('8.d.14.a.INVENTORY-UPDATES - ActualInventoryMethodCalled - VerifyAplOrder - CreateStockRecord');
                    }
                }
                
                //COMM_PerformanceUtils.stop('8.d.14.INVENTORY-UPDATES - ActualInventoryMethodCalled - VerifyAplOrder');
            }  
            system.debug('lstProSerialTobeUpserted'+lstProSerialTobeUpserted.size()+lstProSerialTobeUpserted);
            system.debug('mapProdStockIdSerialHistoryRec'+mapProdStockIdSerialHistoryRec);
            //First upsert stock serial and then pupulate the stock serial id in serial history and insert the serial history...
            map<String,list<String>> mapProStockIdListProSerialId = new map<String,list<String>>();
            if(lstProSerialTobeUpserted.size() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.15.INVENTORY-UPDATES - ActualInventoryMethodCalled - InsertSerialHistory');
            
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstProSerialTobeUpserted, COMM_SecurityUtils.Access.Upsertable)){
                   upsert lstProSerialTobeUpserted; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                if(allowSerialHistrory)
                {
                    for(SVMXC__Product_Serial__c proSerial : lstProSerialTobeUpserted)
                    {
                        if(mapProStockIdListProSerialId.containskey(proSerial.SVMXC__Product_Stock__c))
                            mapProStockIdListProSerialId.get(proSerial.SVMXC__Product_Stock__c).add(proSerial.id);
                        else
                        {   
                            mapProStockIdListProSerialId.put(proSerial.SVMXC__Product_Stock__c,new list<String>());
                            mapProStockIdListProSerialId.get(proSerial.SVMXC__Product_Stock__c).add(proSerial.id);
                        }   
                    }
                }   
                
                //COMM_PerformanceUtils.stop('8.d.15.INVENTORY-UPDATES - ActualInventoryMethodCalled - InsertSerialHistory');
            }
            system.debug('mapProStockIdListProSerialId'+mapProStockIdListProSerialId);  
            if(mapProdStockIdSerialHistoryRec.size() > 0 && allowSerialHistrory)
            {
                //COMM_PerformanceUtils.start('8.d.16.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertSerialHistory');
                for(String str : mapProdStockIdSerialHistoryRec.keyset())
                {
                    list<SVMXC__Stock_History__c> lstTempStockSerialHistry = new list<SVMXC__Stock_History__c>();
                    list<String> lstProductSerialId = new list<String>();
                    lstTempStockSerialHistry = mapProdStockIdSerialHistoryRec.get(str);
                    if(mapProStockIdListProSerialId.containskey(str))
                        lstProductSerialId  = mapProStockIdListProSerialId.get(str);
                    system.debug('lstTempStockSerialHistry'+lstTempStockSerialHistry.size()+lstTempStockSerialHistry);
                    system.debug('lstProductSerialId'+lstProductSerialId.size()+lstProductSerialId);    
                    if(lstTempStockSerialHistry.size() > 0 && lstProductSerialId.size() > 0)
                    {
                        for(Integer j = 0;j<lstTempStockSerialHistry.size();j++)
                        {
                            lstTempStockSerialHistry[j].SVMXC__Product_Serial__c = lstProductSerialId[j];
                        }   
                        lstStockSerialHistoryToBeUpserted.addall(lstTempStockSerialHistry);
                    }   
                }
                system.debug('lstStockSerialHistoryToBeUpserted'+lstStockSerialHistoryToBeUpserted.size()+lstStockSerialHistoryToBeUpserted);
                if(lstStockSerialHistoryToBeUpserted.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstStockSerialHistoryToBeUpserted, COMM_SecurityUtils.Access.Upsertable)){
                       upsert lstStockSerialHistoryToBeUpserted; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                 //COMM_PerformanceUtils.stop('8.d.16.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertSerialHistory');
            }  

                
            
        }
        else if(aplOrder.processType.touppercase() == 'DELIVERYONRECEIPT')
        {
            //COMM_PerformanceUtils.start('8.d.2.INVENTORY-UPDATES - ActualInventoryMethodCalled - DepotsSourceLocation');
        
            if(aplOrder.orderHdrRecord != null && aplOrder.orderHdrRecord.SVMXC__Destination_Location__c != null)//SVMXC__Source_Location__c
                strSourceLocation = aplOrder.orderHdrRecord.SVMXC__Destination_Location__c;
            
            //If it's Depot location than consider Depot's Receiving location as receipt location 
            list<SVMXC__Site__c> lstDepotLocation = new list<SVMXC__Site__c>();
            
            List<String> queryFieldsDepotLocation = new List<String> {'id', 'RecordTypeId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFieldsDepotLocation, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            lstDepotLocation = [select id From SVMXC__Site__c where id =: strSourceLocation and RecordTypeId =: strDepotLocationRtypeId]; //SDL-SVMX-READ-FLS-ENFORCED
            
            //COMM_PerformanceUtils.stop('8.d.2.INVENTORY-UPDATES - ActualInventoryMethodCalled - DepotsSourceLocation');
            
            if(lstDepotLocation.size() > 0) 
            {
            
                //COMM_PerformanceUtils.start('8.d.3.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotChildStagingLoc');
                
                list<SVMXC__Site__c> lstDepotsReceivingLocation = new list<SVMXC__Site__c>();
                List<String> queryFieldsDepotReceivingLocation = new List<String> {'id', 'SVMXC__Parent__c', 'SVMXC__IsReceiving_Location__c', 'RecordType.Name', 'SVMXC__Stocking_Location__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFieldsDepotReceivingLocation, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                lstDepotsReceivingLocation = [select id from SVMXC__Site__c where SVMXC__Parent__c =: lstDepotLocation[0].id and SVMXC__IsReceiving_Location__c = true and RecordType.Name = 'Depot Child' and SVMXC__Stocking_Location__c = true]; //SDL-SVMX-READ-FLS-ENFORCED
                
                //COMM_PerformanceUtils.stop('8.d.3.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotChildStagingLoc');
                 
                 if(lstDepotsReceivingLocation.size() > 0)
                    strSourceLocation = lstDepotsReceivingLocation[0].id;   
            }
            system.debug('strSourceLocation'+strSourceLocation);
            system.debug('aplOrder'+aplOrder.orderLines.size()+aplOrder.orderLines);
            Set<String> deliveredSerialNos = new set<String>();
            //Loop APL Order Lines to get the set of product Id and Delivery Location.
            if(aplOrder.orderLines.size() > 0)          
            {
                //COMM_PerformanceUtils.start('8.d.4.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopOrderLines');
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Product__c != null)
                        setProductId.add(aplOrder.orderLines[i].orderLineRecord.SVMXC__Product__c);
                    if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Delivery_Location__c != null)
                        setDeliveryLocationId.add(aplOrder.orderLines[i].orderLineRecord.SVMXC__Delivery_Location__c);
                    if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Serial_Number_List__c != null)
                        deliveredSerialNos.add(aplOrder.orderLines[i].orderLineRecord.SVMXC__Serial_Number_List__c);    
                }
                //COMM_PerformanceUtils.stop('8.d.4.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopOrderLines');
            }
            system.debug('setProductId'+setProductId.size()+setProductId);
            system.debug('setDeliveryLocationId'+setDeliveryLocationId.size()+setDeliveryLocationId);
            system.debug('deliveredSerialNos'+deliveredSerialNos.size()+deliveredSerialNos);
            //Get the product stock for source location
            if(setProductId.size() > 0 && strSourceLocation != null && strSourceLocation.length() > 0)
            {
            
                //COMM_PerformanceUtils.start('8.d.5.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProductStockforSourceLoc');
                
                map<String,SVMXC__Product_Stock__c> mapTemp = new map<String,SVMXC__Product_Stock__c>();
                
                List<String> queryFieldstockAvailable = new List<String> {'SVMXC__Status__c','SVMXC__Quantity2__c','SVMXC__Product__c','SVMXC__Location__c','Name','Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFieldstockAvailable, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                mapTemp.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Name, Id From SVMXC__Product_Stock__c where SVMXC__Status__c =: 'Available' and SVMXC__Product__c IN : setProductId and SVMXC__Location__c =: strSourceLocation]);
                system.debug('mapTemp'+mapTemp.size()+mapTemp);
                if(mapTemp.size() > 0)
                    mapProductStock.putall(mapTemp);
                
                //COMM_PerformanceUtils.stop('8.d.5.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProductStockforSourceLoc');
                    
            }
            
            //Get the product stock for delivery location
            if(setProductId.size() > 0 && setDeliveryLocationId.size() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.6.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProductStockforDeliveryLoc');
                map<String,SVMXC__Product_Stock__c> mapTemp = new map<String,SVMXC__Product_Stock__c>();
                
                List<String> queryFieldDeliveryOnReceipt = new List<String> {'SVMXC__Status__c','SVMXC__Quantity2__c','SVMXC__Product__c','SVMXC__Location__c','Name','Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFieldDeliveryOnReceipt, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                mapTemp.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Name, Id From SVMXC__Product_Stock__c where SVMXC__Status__c =: 'Available' and SVMXC__Product__c IN : setProductId and SVMXC__Location__c IN : setDeliveryLocationId]);
                system.debug('mapTemp'+mapTemp.size()+mapTemp);
                if(mapTemp.size() > 0)
                    mapProductStock.putall(mapTemp);
                    
                //COMM_PerformanceUtils.stop('8.d.6.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProductStockforDeliveryLoc');    
            }
            // Create map of Uniquekey(ProductID_LocationID_Status and product stock Record..
            if(mapProductStock.size() > 0)
            {
                //COMM_PerformanceUtils.start('8.d.7.INVENTORY-UPDATES - ActualInventoryMethodCalled - MapCreateForUniquePS');
                for(String s:mapProductStock.keyset())
                {
                    if(mapProductStock.get(s).SVMXC__Product__c != null && mapProductStock.get(s).SVMXC__Location__c != null && mapProductStock.get(s).SVMXC__Status__c != null)
                    {
                        String strUniqueKey = String.valueof(mapProductStock.get(s).SVMXC__Product__c).substring(0,15)+'_'+String.valueof(mapProductStock.get(s).SVMXC__Location__c).substring(0,15)+'_'+mapProductStock.get(s).SVMXC__Status__c;
                        mapUniqueKeyProductStock.put(strUniqueKey,mapProductStock.get(s));
                    }    
                }
                //COMM_PerformanceUtils.stop('8.d.7.INVENTORY-UPDATES - ActualInventoryMethodCalled - MapCreateForUniquePS');
            }
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock.size()+mapUniqueKeyProductStock);
            //Retrive the Stocked serial for all Porduct stock.
            //COMM_PerformanceUtils.start('8.d.8.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryStockSerialAndLoop');
            
            List<String> queryFieldDeliveryOnReceiptSerial = new List<String> {'SVMXC__Product__c','SVMXC__Product_Stock__c','SVMXC__Active__c','Name','Id'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Serial__c', queryFieldDeliveryOnReceiptSerial, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            if(mapProductStock.size() > 0)
                mapStockSerial.putall([Select SVMXC__Product__c, SVMXC__Product_Stock__c, SVMXC__Active__c, Name, Id From SVMXC__Product_Serial__c where SVMXC__Product_Stock__c IN : mapProductStock.keyset() and Name IN :deliveredSerialNos]);
            system.debug('mapStockSerial'+mapStockSerial.size()+mapStockSerial);
            map<String,SVMXC__Product_Serial__c> mapUniqueIdSerialRecord = new map<String,SVMXC__Product_Serial__c>(); 
            //Create a map of PSId and List<SVMXC__Product_Serial__c> 
            if(mapStockSerial.size() > 0)
            {
                for(String str:mapStockSerial.keyset())
                {
                    if(mapStockSerial.get(str).Name != null && mapStockSerial.get(str).SVMXC__Product__c != null)
                    {
                        String key = mapStockSerial.get(str).Name+'_'+String.valueof(mapStockSerial.get(str).SVMXC__Product__c).substring(0,15);
                        mapUniqueIdSerialRecord.put(key,mapStockSerial.get(str));
                    }
                    if(mapStockSerial.get(str).SVMXC__Product_Stock__c != null)
                    {
                        String strPSId = string.valueof(mapStockSerial.get(str).SVMXC__Product_Stock__c);
                        if(mapPSIdListStockSerial.containskey(strPSId))
                            mapPSIdListStockSerial.get(strPSId).add(mapStockSerial.get(str));
                        else
                        {
                            mapPSIdListStockSerial.put(strPSId,new list<SVMXC__Product_Serial__c>());
                            mapPSIdListStockSerial.get(strPSId).add(mapStockSerial.get(str));
                        }    
                            
                    }
                }
            }
            system.debug('mapPSIdListStockSerial'+mapPSIdListStockSerial);
            system.debug('mapUniqueIdSerialRecord'+mapUniqueIdSerialRecord);
            
            //COMM_PerformanceUtils.stop('8.d.8.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryStockSerialAndLoop');
            //COMM_PerformanceUtils.start('8.d.9.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapProdStockNPSHistory');
            
            //For all APL OrderLine Do the Product Stock & Product Stock History Update for the Source Location first
            if(aplOrder.orderLines.size() > 0)
            {
                Double intExsistingQty = 0;
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    intExsistingQty = 0;
                    if(strSourceLocation != null && strSourceLocation.length() > 0 && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_Available';
                        String strUniqueForStockHistory =  String.valueof(objLine.id).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_Available';
                        system.debug('strUnique'+strUnique);
                        system.debug('strUniqueForStockHistory'+strUniqueForStockHistory);
                        //If Product Stock is already in the map then update the SVMXC__Quantity_before_change2__c
                        if(mapUniqueKeyProductStock.containskey(strUnique)) //For Delivery Product Stock Must be created via receipt.
                        {
                            //For Delivery On Receipt and Source Location Decrease the Product Quntity 
                            intExsistingQty = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c =  mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c - objLine.SVMXC__Actual_Quantity2__c;
                        }  
                        else //Here in source Location Stock will alwyas decrease so if we create a new poduct then we put Quentity as 0
                        {
                            system.debug('strUnique'+mapUniqueKeyProductStock.containskey(strUnique));
                            SVMXC__Product_Stock__c objPS = new SVMXC__Product_Stock__c();
                            objPS.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objPS.SVMXC__Location__c = strSourceLocation;
                            objPS.SVMXC__Status__c = 'Available';
                            objPS.SVMXC__Quantity2__c = 0;//objLine.SVMXC__Actual_Quantity2__c;
                            mapUniqueKeyProductStock.put(strUnique,objPS);
                        }
                        if(allowStockHistory)
                        { 
                            //Create Stock History Record.
                            SVMXC__Stock_History__c objSH = new SVMXC__Stock_History__c();
                            objSH.RecordTypeId = strStockHistoryRtypeId;
                            objSH.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objSH.SVMXC__Location__c = strSourceLocation;
                            objSH.SVMXC__Status__c = 'Available';
                            objSH.SVMXC__Transaction_Type__c  = 'Delivery On Receipt';
                            objSH.SVMXC__Quantity_before_change2__c = intExsistingQty;
                            objSH.SVMXC__Transaction_Quantity2__c  = objLine.SVMXC__Actual_Quantity2__c;
                            if(mapUniqueKeyProductStock.Containskey(strUnique) && mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c != null)
                                objSH.SVMXC__Quantity_after_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            objSH.SVMXC__Change_Type__c  = 'Decrease' ;
                            objSH.SVMXC__Date_Changed__c  = system.now();
                            objSH.SVMXC__Changed_By__c  = Userinfo.getUserId() ;
                            objSH.SVMXC__RMA__c  = aplOrder.orderHdrRecord.id;
                            objSH.SVMXC__RMA_Line__c  = objLine.id;
                            mapStockHistory.put(strUniqueForStockHistory,objSH);
                        }    
                        
                    }
                }
            }
            
            //COMM_PerformanceUtils.stop('8.d.9.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapProdStockNPSHistory');
            //COMM_PerformanceUtils.start('8.d.10.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertingPSNPSHistory');
            system.debug('mapStockHistory'+mapStockHistory);
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
            if(mapUniqueKeyProductStock.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapUniqueKeyProductStock.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapUniqueKeyProductStock.values();
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
                
            system.debug('mapProductStock'+mapProductStock);
            //Populate the Product StockIds in Stock History Record.. 
            if(mapStockHistory.size() > 0 && allowStockHistory)
            {
                for(String str : mapStockHistory.keyset())
                {
                    String strUniqueKey = str.substring(16,str.length());
                    system.debug('strUniqueKey'+strUniqueKey+mapUniqueKeyProductStock.containskey(strUniqueKey));
                    if(mapUniqueKeyProductStock.containskey(strUniqueKey))
                    {
                        system.debug('Entered..');
                        mapStockHistory.get(str).SVMXC__Product_Stock__c = mapUniqueKeyProductStock.get(strUniqueKey).id;
                    }
                }
                system.debug('mapStockHistory'+mapStockHistory.values());
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapStockHistory.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapStockHistory.values(); 
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }   
            
            //COMM_PerformanceUtils.stop('8.d.10.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertingPSNPSHistory');
            //COMM_PerformanceUtils.start('8.d.11.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLines');
            //populate the PS id in the remailning Order Lines.
            if(aplOrder.orderLines.size() > 0)
            {
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    if(strSourceLocation != null && strSourceLocation.length() > 0 && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_Available';
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                            aplOrder.orderLines[i].sourceLocationPSID = mapUniqueKeyProductStock.get(strUnique).id;
                        if(objLine.SVMXC__Serial_Number_List__c != null && objLine.SVMXC__Product__c != null && mapUniqueIdSerialRecord.containskey(objLine.SVMXC__Serial_Number_List__c+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15)))
                            aplOrder.orderLines[i].serialNumberRecord =  mapUniqueIdSerialRecord.get(objLine.SVMXC__Serial_Number_List__c+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15));   
                    }
                }
            }
            
            //COMM_PerformanceUtils.stop('8.d.11.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLines');
            //COMM_PerformanceUtils.start('8.d.12.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapPSNPSHistoryForTargetLoc');
            //For all APL OrderLine Do the Product Stock & Product Stock History Update for the Delivery Location(Target Location). 
            if(aplOrder.orderLines.size() > 0)
            {
                mapStockHistory.clear();
                Double intExsistingQty = 0;
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    intExsistingQty = 0;
                    if(objLine.SVMXC__Delivery_Location__c != null && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Delivery_Location__c).substring(0,15)+'_Available';
                        String strUniqueForStockHistory =  String.valueof(objLine.id).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Delivery_Location__c).substring(0,15)+'_Available';
                        system.debug('strUnique'+strUnique);
                        system.debug('strUniqueForStockHistory'+strUniqueForStockHistory);
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                        {
                            //For Delivery On Receipt and Delivery Location(Target Location) Increase the Product Quntity 
                            intExsistingQty = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c =  mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c + objLine.SVMXC__Actual_Quantity2__c;
                        }   
                        else
                        {
                            system.debug('strUnique'+mapUniqueKeyProductStock.containskey(strUnique));
                            SVMXC__Product_Stock__c objPS = new SVMXC__Product_Stock__c();
                            objPS.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objPS.SVMXC__Location__c = objLine.SVMXC__Delivery_Location__c;
                            objPS.SVMXC__Status__c = 'Available';
                            objPS.SVMXC__Quantity2__c = objLine.SVMXC__Actual_Quantity2__c;
                            mapUniqueKeyProductStock.put(strUnique,objPS);
                        }
                        if(allowStockHistory)
                        {
                            //Create Stock History Record.
                            SVMXC__Stock_History__c objSH = new SVMXC__Stock_History__c();
                            objSH.RecordTypeId = strStockHistoryRtypeId;
                            objSH.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objSH.SVMXC__Location__c = objLine.SVMXC__Delivery_Location__c;
                            objSH.SVMXC__Status__c = 'Available';
                            objSH.SVMXC__Transaction_Type__c  = 'Delivery On Receipt';
                            objSH.SVMXC__Quantity_before_change2__c = intExsistingQty;
                            objSH.SVMXC__Transaction_Quantity2__c  = objLine.SVMXC__Actual_Quantity2__c;
                            objSH.SVMXC__Quantity_after_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            objSH.SVMXC__Change_Type__c  = 'Increase' ;
                            objSH.SVMXC__Date_Changed__c  = system.now();
                            objSH.SVMXC__Changed_By__c  = Userinfo.getUserId() ;
                            objSH.SVMXC__Quantity_before_change2__c = 0; 
                            objSH.SVMXC__RMA__c  = aplOrder.orderHdrRecord.id;
                            objSH.SVMXC__RMA_Line__c  = objLine.id;
                            mapStockHistory.put(strUniqueForStockHistory,objSH); 
                        }   
                           
                    }
                }
            }
            
            //COMM_PerformanceUtils.stop('8.d.12.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapPSNPSHistoryForTargetLoc');
            //COMM_PerformanceUtils.start('8.d.13.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertPSNPSHistoryForTargetLoc');
            
            system.debug('mapStockHistory'+mapStockHistory);
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
            if(mapUniqueKeyProductStock.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapUniqueKeyProductStock.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapUniqueKeyProductStock.values(); 
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
               
            system.debug('mapProductStock'+mapProductStock);
            //Populate the Product StockIds in Stock History Record.. 
            if(mapStockHistory.size() > 0 && allowStockHistory)
            {
                for(String str : mapStockHistory.keyset())
                {
                    String strUniqueKey = str.substring(16,str.length());
                    system.debug('strUniqueKey'+strUniqueKey+mapUniqueKeyProductStock.containskey(strUniqueKey));
                    if(mapUniqueKeyProductStock.containskey(strUniqueKey))
                    {
                        system.debug('Entered..');
                        mapStockHistory.get(str).SVMXC__Product_Stock__c = mapUniqueKeyProductStock.get(strUniqueKey).id;
                    }
                }
                system.debug('mapStockHistory'+mapStockHistory.values());
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapStockHistory.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapStockHistory.values(); 
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }       

            //COMM_PerformanceUtils.stop('8.d.13.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertPSNPSHistoryForTargetLoc');
            //COMM_PerformanceUtils.start('8.d.14.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLinesForTargetLoc');
            
            //populate the PS id in the remailning Order Lines.
            if(aplOrder.orderLines.size() > 0)
            {
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    if(objLine.SVMXC__Delivery_Location__c != null && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+string.valueof(objLine.SVMXC__Delivery_Location__c).substring(0,15)+'_Available';
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                            aplOrder.orderLines[i].targetLocationPSID = mapUniqueKeyProductStock.get(strUnique).id;
                    }
                }
            }
            system.debug('APL Order After population PS id'+aplOrder.orderLines);
            //COMM_PerformanceUtils.stop('8.d.14.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLinesForTargetLoc');
            //COMM_PerformanceUtils.start('8.d.15.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreateSSIfReqNPopulateTargetLocPSId');
            
            
            //Now loop through the APL Order and check that all sourceLocationPSID have the stock serial other wise create the stock serial for those and populate the targetLocationPSID in it.
            if(aplOrder.orderLines.size() > 0)
            {
                list<SVMXC__Product_Serial__c> lstProductSerial = new list<SVMXC__Product_Serial__c>();      
                list<SVMXC__Stock_History__c> lstSerialHistory = new list<SVMXC__Stock_History__c>();          
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    aplOrder.orderLines[i].serialNumberRecord.SVMXC__Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;
                    lstProductSerial.add(aplOrder.orderLines[i].serialNumberRecord);
                    if(allowSerialHistrory)
                    {
                        //Create Serial History Record..
                        SVMXC__Stock_History__c serialHistory = new SVMXC__Stock_History__c();
                        serialHistory.RecordTypeId = strSerialHistoryRtypeId;
                        serialHistory.SVMXC__From_Product_Stock__c = aplOrder.orderLines[i].sourceLocationPSID;//Source Location Product Stock Id
                        serialHistory.SVMXC__To_Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;//Target Location Product Stock Id
                        serialHistory.SVMXC__Transaction_Type__c = 'Delivery On Receipt';
                        serialHistory.SVMXC__Date_Changed__c = system.now();
                        serialHistory.SVMXC__Changed_By__c = userinfo.getUserId();
                        serialHistory.SVMXC__RMA__c  = aplOrder.orderHdrRecord.id;
                        serialHistory.SVMXC__RMA_Line__c  = aplOrder.orderLines[i].orderLineRecord.id;
                        lstSerialHistory.add(serialHistory);
                    }
                }
                system.debug('lstProductSerial : '+lstProductSerial.size()+lstProductSerial);
                system.debug('lstSerialHistory : '+lstSerialHistory.size()+lstSerialHistory);
                if(lstProductSerial.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstProductSerial, COMM_SecurityUtils.Access.Upsertable)){
                       upsert lstProductSerial; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
                    
                if(lstSerialHistory.size() > 0 && allowSerialHistrory) {
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstSerialHistory, COMM_SecurityUtils.Access.Upsertable)){
                       upsert lstSerialHistory; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                } 
            } 
           
            /*if(aplOrder.orderLines.size() > 0)
            {
                set<String> exsistingSourcePSID = new set<String>();
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    list<SVMXC__Product_Serial__c> lstTempProductSerial;
                    list<SVMXC__Stock_History__c> lstTempStockSerialHistry;
                    if(mapPSIdListStockSerial.containskey(aplOrder.orderLines[i].sourceLocationPSID) && !exsistingSourcePSID.contains(aplOrder.orderLines[i].sourceLocationPSID))
                    {
                        exsistingSourcePSID.add(aplOrder.orderLines[i].sourceLocationPSID);
                        lstTempProductSerial = new list<SVMXC__Product_Serial__c>();
                        lstTempStockSerialHistry = new list<SVMXC__Stock_History__c>();
                        lstTempProductSerial = mapPSIdListStockSerial.get(aplOrder.orderLines[i].sourceLocationPSID);
                        system.debug('lstTempProductSerial'+lstTempProductSerial.size()+lstTempProductSerial);
                        if(lstTempProductSerial.size() > 0)
                        {
                            for(SVMXC__Product_Serial__c ps : lstTempProductSerial)
                            {
                                ps.SVMXC__Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;
                                if(allowSerialHistrory)
                                {
                                    //Create Serial History Record..
                                    SVMXC__Stock_History__c serialHistory = new SVMXC__Stock_History__c();
                                    serialHistory.RecordTypeId = strSerialHistoryRtypeId;
                                    serialHistory.SVMXC__From_Product_Stock__c = aplOrder.orderLines[i].sourceLocationPSID;//Source Location Product Stock Id
                                    serialHistory.SVMXC__To_Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;//Target Location Product Stock Id
                                    serialHistory.SVMXC__Transaction_Type__c = 'Delivery On Receipt';
                                    serialHistory.SVMXC__Date_Changed__c = system.now();
                                    serialHistory.SVMXC__Changed_By__c = userinfo.getUserId();
                                    serialHistory.SVMXC__RMA__c  = aplOrder.orderHdrRecord.id;
                                    serialHistory.SVMXC__RMA_Line__c  = aplOrder.orderLines[i].orderLineRecord.id;
                                    lstTempStockSerialHistry.add(serialHistory);
                                }    
                            }
                            if(lstTempStockSerialHistry.size() > 0)
                            {
                                if(mapProdStockIdSerialHistoryRec.containskey(aplOrder.orderLines[i].targetLocationPSID))
                                {
                                    mapProdStockIdSerialHistoryRec.get(aplOrder.orderLines[i].targetLocationPSID).addall(lstTempStockSerialHistry);
                                }
                                else
                                {
                                    mapProdStockIdSerialHistoryRec.put(aplOrder.orderLines[i].targetLocationPSID,lstTempStockSerialHistry);
                                }   
                            }    
                        }
                        lstProSerialTobeUpserted.addall(lstTempProductSerial);
                    }
                }
            } 
            
            //COMM_PerformanceUtils.stop('8.d.15.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreateSSIfReqNPopulateTargetLocPSId');
            //COMM_PerformanceUtils.start('8.d.16.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertSSNSerialHistory');
            
            system.debug('lstProSerialTobeUpserted'+lstProSerialTobeUpserted.size()+lstProSerialTobeUpserted);
            system.debug('mapProdStockIdSerialHistoryRec'+mapProdStockIdSerialHistoryRec.size()+mapProdStockIdSerialHistoryRec);
            //First upsert stock serial and then pupulate the stock serial id in serial history and insert the serial history...
            map<String,list<String>> mapProStockIdListProSerialId = new map<String,list<String>>();
            if(lstProSerialTobeUpserted.size() > 0)
            {
                upsert lstProSerialTobeUpserted;
                if(allowSerialHistrory)
                {   
                    for(SVMXC__Product_Serial__c proSerial : lstProSerialTobeUpserted)
                    {
                        if(mapProStockIdListProSerialId.containskey(proSerial.SVMXC__Product_Stock__c))
                            mapProStockIdListProSerialId.get(proSerial.SVMXC__Product_Stock__c).add(proSerial.id);
                        else
                        {   
                            mapProStockIdListProSerialId.put(proSerial.SVMXC__Product_Stock__c,new list<String>());
                            mapProStockIdListProSerialId.get(proSerial.SVMXC__Product_Stock__c).add(proSerial.id);
                        }   
                    }
                }       
            }
            system.debug('mapProStockIdListProSerialId'+mapProStockIdListProSerialId);  
            if(mapProdStockIdSerialHistoryRec.size() > 0 && allowSerialHistrory)
            {
                for(String str : mapProdStockIdSerialHistoryRec.keyset())
                {
                    list<SVMXC__Stock_History__c> lstTempStockSerialHistry = new list<SVMXC__Stock_History__c>();
                    list<String> lstProductSerialId = new list<String>();
                    lstTempStockSerialHistry = mapProdStockIdSerialHistoryRec.get(str);
                    if(mapProStockIdListProSerialId.containskey(str))
                        lstProductSerialId  = mapProStockIdListProSerialId.get(str);
                    system.debug('lstTempStockSerialHistry'+lstTempStockSerialHistry.size()+lstTempStockSerialHistry);
                    system.debug('lstProductSerialId'+lstProductSerialId.size()+lstProductSerialId);    
                    if(lstTempStockSerialHistry.size() > 0 && lstProductSerialId.size() > 0)
                    {
                        for(Integer j = 0;j<lstTempStockSerialHistry.size();j++)
                        {
                            lstTempStockSerialHistry[j].SVMXC__Product_Serial__c = lstProductSerialId[j];
                        }   
                        lstStockSerialHistoryToBeUpserted.addall(lstTempStockSerialHistry);
                    }   
                }
                system.debug('lstStockSerialHistoryToBeUpserted'+lstStockSerialHistoryToBeUpserted.size()+lstStockSerialHistoryToBeUpserted);
                if(lstStockSerialHistoryToBeUpserted.size() > 0)
                    upsert lstStockSerialHistoryToBeUpserted;
            } */  
            //COMM_PerformanceUtils.stop('8.d.16.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertSSNSerialHistory');
        }
        else if(aplOrder.processType.touppercase() == 'PICKNMOVE')
        {
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.start('8.d.2.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotLoc');
            
            Set<String> pickedSerialNos = new set<String>();
            system.debug('aplOrder'+aplOrder);
            //For Pick and move source location would be SVMXC__Delivery_Location__c of the sipmment order line record and the target location would be staging location of depot..
            //Calculation of Target Location (If it's depot Location then get the staging location of it..)
            if(aplOrder.orderHdrRecord != null && aplOrder.orderHdrRecord.SVMXC__Source_Location__c != null)
                strTargetLocation = aplOrder.orderHdrRecord.SVMXC__Source_Location__c;
            list<SVMXC__Site__c> lstDepotLocation = new list<SVMXC__Site__c>();
            List<String> queryFieldslstDepotLocation = new List<String> {'id', 'RecordTypeId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFieldslstDepotLocation, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            } 
            lstDepotLocation = [select id From SVMXC__Site__c where id =: strTargetLocation and RecordTypeId =: strDepotLocationRtypeId]; //SDL-SVMX-READ-FLS-ENFORCED
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.2.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotLoc');
            
            if(lstDepotLocation.size() > 0)
            {
                     
                //Added by Naveen V on 13-March-2012 For Performance
                //COMM_PerformanceUtils.start('8.d.3.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotChildStagingLoc');
                
                list<SVMXC__Site__c> lstDepotsStagingLocation = new list<SVMXC__Site__c>();
                List<String> queryFieldslstDepotLocationPickMove = new List<String> {'id', 'RecordTypeId', 'Name', 'SVMXC__Parent__c', 'SVMXC__IsStaging_Location__c', 'SVMXC__Stocking_Location__c' };
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFieldslstDepotLocation, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                lstDepotsStagingLocation = [select id,Name,RecordTypeId,SVMXC__Parent__c,SVMXC__IsStaging_Location__c, SVMXC__Stocking_Location__c from SVMXC__Site__c where SVMXC__Parent__c =: lstDepotLocation[0].id and SVMXC__IsStaging_Location__c = true and RecordType.Name = 'Depot Child' and SVMXC__Stocking_Location__c = true]; //SDL-SVMX-READ-FLS-ENFORCED
                      
                //Added by Naveen V on 13-March-2012 For Performance
                //COMM_PerformanceUtils.stop('8.d.3.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotChildStagingLoc');
                
                 if(lstDepotsStagingLocation.size() > 0)
                    strTargetLocation = lstDepotsStagingLocation[0].id;   
                 else
                 {
                    //response.success = false;
                    //response.message = 'Staging Location is not configured for this deopt';
                    return response;
                 }   
            }
            system.debug('strTargetLocation'+strTargetLocation);
            //Loop APL Order Lines to get the set of product Id and Delivery Location.
            if(aplOrder.orderLines.size() > 0)
            {
                     
                //Added by Naveen V on 13-March-2012 For Performance
                //COMM_PerformanceUtils.start('8.d.4.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopOrderLines');
                
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Product__c != null)
                        setProductId.add(aplOrder.orderLines[i].orderLineRecord.SVMXC__Product__c);
                    if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Delivery_Location__c != null)
                        setDeliveryLocationId.add(aplOrder.orderLines[i].orderLineRecord.SVMXC__Delivery_Location__c);
                    if(aplOrder.orderLines[i].orderLineRecord.id != null)
                        setShipmetLineId.add(aplOrder.orderLines[i].orderLineRecord.id);
                    list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> pickedSerialNoCollection = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                    if(aplOrder.orderLines[i].serialNumbers != null && aplOrder.orderLines[i].serialNumbers.size() > 0)
                    {
                        pickedSerialNoCollection = aplOrder.orderLines[i].serialNumbers;
                        for(Integer j = 0;j<pickedSerialNoCollection.size();j++)
                        {
                            if(pickedSerialNoCollection[j].isPicked != null && pickedSerialNoCollection[j].isPicked)
                                pickedSerialNos.add(pickedSerialNoCollection[j].serialNumber);
                        }
                    }
                }
                     
                //Added by Naveen V on 13-March-2012 For Performance
                //COMM_PerformanceUtils.stop('8.d.4.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopOrderLines');
                
            }
            system.debug('pickedSerialNos'+pickedSerialNos.size()+pickedSerialNos);
            system.debug('setProductId'+setProductId.size()+setProductId);
            system.debug('setDeliveryLocationId'+setDeliveryLocationId.size()+setDeliveryLocationId);
            system.debug('setShipmetLineId'+setShipmetLineId.size()+setShipmetLineId);
            //Query Allocated Stock and split it and update shipment order in it also update the shiped quentity 
            list<SVMXC__Allocated_Stock__c> lstAllocatedStock = new list<SVMXC__Allocated_Stock__c>();
            list<SVMXC__Allocated_Stock__c> lstNewAllocatedStock = new list<SVMXC__Allocated_Stock__c>();
             
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.start('8.d.5.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryAllocatedStock');
            
            lstAllocatedStock = [Select SVMXC__Shipped_Qty__c, SVMXC__Shipment_Order__c, SVMXC__Shipment_Order_Line__c, SVMXC__Sales_Repair_Order__c, SVMXC__Sales_Repair_Order_Line__c, SVMXC__Product_Stock__c, SVMXC__Pending_Qty__c, SVMXC__Customer__c, SVMXC__Allocated_Qty__c, Name, Id From SVMXC__Allocated_Stock__c where SVMXC__Shipment_Order_Line__c IN : setShipmetLineId];
            system.debug('lstAllocatedStock'+lstAllocatedStock.size()+lstAllocatedStock);
             
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.5.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryAllocatedStock');
            //COMM_PerformanceUtils.start('8.d.6.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpdateAllocatedStock');
            
            if(lstAllocatedStock.size() == 1)
            {
                for(Integer i = 0 ;i<lstAllocatedStock[0].SVMXC__Allocated_Qty__c;i++)
                {
                    if(lstAllocatedStock[0].SVMXC__Shipment_Order_Line__c != aplOrder.orderLines[i].orderLineRecord.id)
                    {
                        SVMXC__Allocated_Stock__c objAllocatedStock = new SVMXC__Allocated_Stock__c();
                        objAllocatedStock = lstAllocatedStock[0].clone(false,true);
                        objAllocatedStock.SVMXC__Shipment_Order_Line__c = aplOrder.orderLines[i].orderLineRecord.id;
                        objAllocatedStock.SVMXC__Allocated_Qty__c = 1;
                        objAllocatedStock.SVMXC__Shipped_Qty__c = 1;  
                        lstNewAllocatedStock.add(objAllocatedStock);
                    }
                }
                lstAllocatedStock[0].SVMXC__Allocated_Qty__c = 1;
                lstAllocatedStock[0].SVMXC__Shipped_Qty__c = 1;
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstAllocatedStock, COMM_SecurityUtils.Access.Updateable)){
                    update lstAllocatedStock; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.6.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpdateAllocatedStock');
            //COMM_PerformanceUtils.start('8.d.7.INVENTORY-UPDATES - ActualInventoryMethodCalled - InsertNewStock');
            
            if(lstNewAllocatedStock.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstNewAllocatedStock, COMM_SecurityUtils.Access.Createable)){
                    insert lstNewAllocatedStock; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
                        
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.7.INVENTORY-UPDATES - ActualInventoryMethodCalled - InsertNewStock');
            //COMM_PerformanceUtils.start('8.d.8.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryPSForDeliveryLoc');
            
            //Get the product stock for delivery location
            if(setProductId.size() > 0 && setDeliveryLocationId.size() > 0)
            {
                map<String,SVMXC__Product_Stock__c> mapTemp = new map<String,SVMXC__Product_Stock__c>();
                List<String> queryFieldPickMove= new List<String> {'SVMXC__Status__c','SVMXC__Quantity2__c','SVMXC__Product__c','SVMXC__Location__c','Name','Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFieldPickMove, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
                
                mapTemp.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Name, Id From SVMXC__Product_Stock__c where SVMXC__Status__c =: 'Available' and SVMXC__Product__c IN : setProductId and SVMXC__Location__c IN : setDeliveryLocationId]);
                system.debug('mapTemp'+mapTemp.size()+mapTemp);
                if(mapTemp.size() > 0)
                    mapProductStock.putall(mapTemp);
            }
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.8.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryPSForDeliveryLoc');
            //COMM_PerformanceUtils.start('8.d.9.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryPSForTargetLoc');
            
            //Get the product stock for target location(Staging location of depot)
            if(setProductId.size() > 0 && strTargetLocation != null && strTargetLocation.length() > 0)
            {
                map<String,SVMXC__Product_Stock__c> mapTemp = new map<String,SVMXC__Product_Stock__c>();
                List<String> queryFieldPickMove= new List<String> {'SVMXC__Status__c','SVMXC__Quantity2__c','SVMXC__Product__c','SVMXC__Location__c','Name','Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFieldPickMove, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                mapTemp.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Name, Id From SVMXC__Product_Stock__c where SVMXC__Status__c =: 'Available' and SVMXC__Product__c IN : setProductId and SVMXC__Location__c =: strTargetLocation]);
                system.debug('mapTemp'+mapTemp.size()+mapTemp);
                if(mapTemp.size() > 0)
                    mapProductStock.putall(mapTemp);
            }
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.9.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryPSForTargetLoc');
            //COMM_PerformanceUtils.start('8.d.10.INVENTORY-UPDATES - ActualInventoryMethodCalled - MapCreateForUniquePS');
            
            // Create map of Uniquekey(Product_Location_Status) and product stock Id..
            if(mapProductStock.size() > 0)
            {
                for(String s:mapProductStock.keyset())
                {
                    if(mapProductStock.get(s).SVMXC__Product__c != null && mapProductStock.get(s).SVMXC__Location__c != null && mapProductStock.get(s).SVMXC__Status__c != null)
                    {
                        String strUniqueKey = String.valueof(mapProductStock.get(s).SVMXC__Product__c).substring(0,15)+'_'+String.valueof(mapProductStock.get(s).SVMXC__Location__c).substring(0,15)+'_'+mapProductStock.get(s).SVMXC__Status__c;
                        mapUniqueKeyProductStock.put(strUniqueKey,mapProductStock.get(s));
                    }    
                }
            }
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.10.INVENTORY-UPDATES - ActualInventoryMethodCalled - MapCreateForUniquePS');
            //COMM_PerformanceUtils.start('8.d.11.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryStockSerialAndLoop');
            
            //Retrive the Stocked serial for all Porduct stock.
            if(mapProductStock.size() > 0){
                List<String> queryFieldPickMove= new List<String> {'SVMXC__Product__c','SVMXC__Product_Stock__c','SVMXC__Active__c','Name','Id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Serial__c', queryFieldPickMove, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                mapStockSerial.putall([Select SVMXC__Product__c, SVMXC__Product_Stock__c, SVMXC__Active__c, Name, Id From SVMXC__Product_Serial__c where SVMXC__Product_Stock__c IN : mapProductStock.keyset() and Name IN : pickedSerialNos]);
            
            }
            system.debug('mapStockSerial'+mapStockSerial);
            //Create a map of PSId and List<SVMXC__Product_Serial__c> 
            if(mapStockSerial.size() > 0)
            {
                for(String str:mapStockSerial.keyset())
                {
                    if(mapStockSerial.get(str).SVMXC__Product_Stock__c != null)
                    {
                        String strPSId = string.valueof(mapStockSerial.get(str).SVMXC__Product_Stock__c);
                        if(mapPSIdListStockSerial.containskey(strPSId))
                            mapPSIdListStockSerial.get(strPSId).add(mapStockSerial.get(str));
                        else
                        {
                            mapPSIdListStockSerial.put(strPSId,new list<SVMXC__Product_Serial__c>());
                            mapPSIdListStockSerial.get(strPSId).add(mapStockSerial.get(str));
                        }
                    }
                }
            }
            system.debug('mapPSIdListStockSerial'+mapPSIdListStockSerial);
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.11.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryStockSerialAndLoop');
            //COMM_PerformanceUtils.start('8.d.12.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapProdStockNPSHistory');
            
            //For all APL OrderLine Do the Product Stock & Product Stock History Update for the Delivery Location first
            if(aplOrder.orderLines.size() > 0)
            {
                Double intExsistingQty = 0;
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    intExsistingQty = 0;    
                    if(objLine.SVMXC__Delivery_Location__c != null && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+string.valueof(objLine.SVMXC__Delivery_Location__c).substring(0,15)+'_Available';
                        String strUniqueForStockHistory =  String.valueof(objLine.id).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Delivery_Location__c).substring(0,15)+'_Available';
                        system.debug('strUnique'+strUnique);
                        system.debug('strUniqueForStockHistory'+strUniqueForStockHistory);
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                        {
                            //For Pick & Move and Delivery Location Decrease the Product Quntity 
                            intExsistingQty = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c =  mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c - objLine.SVMXC__Picked_Qty__c;
                        }  
                        else // In source Location Stock will alwyas decrease so if we create a new poduct then we put Quentity as 0
                        {
                            system.debug('strUnique'+mapUniqueKeyProductStock.containskey(strUnique));
                            SVMXC__Product_Stock__c objPS = new SVMXC__Product_Stock__c();
                            objPS.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objPS.SVMXC__Location__c = objLine.SVMXC__Delivery_Location__c;
                            objPS.SVMXC__Status__c = 'Available';
                            objPS.SVMXC__Quantity2__c = objLine.SVMXC__Actual_Quantity2__c;
                            mapUniqueKeyProductStock.put(strUnique,objPS);
                        }
                        if(allowStockHistory)
                        { 
                            //Create Stock History Record.
                            SVMXC__Stock_History__c objSH = new SVMXC__Stock_History__c();
                            objSH.RecordTypeId = strStockHistoryRtypeId;
                            objSH.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objSH.SVMXC__Location__c = objLine.SVMXC__Delivery_Location__c;
                            objSH.SVMXC__Status__c = 'Available';
                            objSH.SVMXC__Transaction_Type__c  = 'Pick & Move';
                            objSH.SVMXC__Transaction_Quantity2__c  = objLine.SVMXC__Picked_Qty__c;
                            objSH.SVMXC__Quantity_after_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            objSH.SVMXC__Change_Type__c  = 'Decrease' ;
                            objSH.SVMXC__Date_Changed__c  = system.now();
                            objSH.SVMXC__Changed_By__c  = Userinfo.getUserId() ;
                            objSH.SVMXC__Quantity_before_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            objSH.SVMXC__Shipment__c  = aplOrder.orderHdrRecord.id;
                            objSH.SVMXC__Shipment_Line__c  = objLine.id;
                            mapStockHistory.put(strUniqueForStockHistory,objSH); 
                        }      
                    }
                }
            }
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.12.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapProdStockNPSHistory');
            //COMM_PerformanceUtils.start('8.d.13.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertingPSNPSHistory');
            
            system.debug('mapStockHistory'+mapStockHistory);
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
            if(mapUniqueKeyProductStock.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapUniqueKeyProductStock.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapUniqueKeyProductStock.values(); 
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
                
            system.debug('mapProductStock'+mapProductStock);
            
            //Populate the Product StockIds in Stock History Record.. 
            if(mapStockHistory.size() > 0 && allowStockHistory)
            {
                for(String str : mapStockHistory.keyset())
                {
                    String strUniqueKey = str.substring(16,str.length());
                    system.debug('strUniqueKey'+strUniqueKey+mapProductStock.containskey(strUniqueKey));
                    if(mapUniqueKeyProductStock.containskey(strUniqueKey))
                    {
                        system.debug('Entered..');
                        mapStockHistory.get(str).SVMXC__Product_Stock__c = mapUniqueKeyProductStock.get(strUniqueKey).id;
                    }
                }
                system.debug('mapStockHistory'+mapStockHistory.values());
                 if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapStockHistory.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapStockHistory.values(); 
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                } 
            }   
            
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.13.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertingPSNPSHistory');
            //COMM_PerformanceUtils.start('8.d.14.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLines');
            
            //populate the PS id in the remailning Order Lines.
            if(aplOrder.orderLines.size() > 0)
            {
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    if(objLine.SVMXC__Delivery_Location__c != null && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+string.valueof(objLine.SVMXC__Delivery_Location__c).substring(0,15)+'_Available';
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                            aplOrder.orderLines[i].sourceLocationPSID = mapUniqueKeyProductStock.get(strUnique).id;
                    }
                }
            }
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.14.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLines');
            //COMM_PerformanceUtils.start('8.d.15.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapPSNPSHistoryForTargetLoc');
            
            //For all APL OrderLine Do the Product Stock & Product Stock History Update for the TargetLocation
            if(aplOrder.orderLines.size() > 0)
            {
                Double intExsistingQty = 0;
                mapStockHistory.clear();
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    intExsistingQty = 0;
                    if(strTargetLocation != null && strTargetLocation.length() > 0 && objLine.SVMXC__Product__c != null) 
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strTargetLocation.substring(0,15)+'_Available';
                        String strUniqueForStockHistory =  String.valueof(objLine.id).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strTargetLocation.substring(0,15)+'_Available';
                        system.debug('strUnique'+strUnique);
                        system.debug('strUniqueForStockHistory'+strUniqueForStockHistory);
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                        {
                            //For Pick & Move and Target Location Increase the Product Quntity 
                            intExsistingQty = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            if(mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c != null)
                                mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c =  mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c + objLine.SVMXC__Picked_Qty__c;
                        }
                        else
                        {
                            system.debug('strUnique'+mapUniqueKeyProductStock.containskey(strUnique));
                            SVMXC__Product_Stock__c objPS = new SVMXC__Product_Stock__c();
                            objPS.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objPS.SVMXC__Location__c = strTargetLocation;
                            objPS.SVMXC__Status__c = 'Available';
                            objPS.SVMXC__Quantity2__c = objLine.SVMXC__Picked_Qty__c;
                            mapUniqueKeyProductStock.put(strUnique,objPS);
                        }  
                        if(allowStockHistory)
                        {  
                            //Create Stock History Record.
                            SVMXC__Stock_History__c objSH = new SVMXC__Stock_History__c();
                            objSH.RecordTypeId = strStockHistoryRtypeId;
                            objSH.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objSH.SVMXC__Location__c = strTargetLocation;
                            objSH.SVMXC__Status__c = 'Available';
                            objSH.SVMXC__Transaction_Type__c  = 'Pick & Move';
                            objSH.SVMXC__Transaction_Quantity2__c  = objLine.SVMXC__Picked_Qty__c;
                            objSH.SVMXC__Quantity_after_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            objSH.SVMXC__Change_Type__c  = 'Increase' ;
                            objSH.SVMXC__Date_Changed__c  = system.now();
                            objSH.SVMXC__Changed_By__c  = Userinfo.getUserId() ;
                            objSH.SVMXC__Quantity_before_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            objSH.SVMXC__Shipment__c  = aplOrder.orderHdrRecord.id;
                            objSH.SVMXC__Shipment_Line__c  = objLine.id;
                            mapStockHistory.put(strUniqueForStockHistory,objSH); 
                        }          
                    }   
                }
            }       
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.15.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapPSNPSHistoryForTargetLoc');
            //COMM_PerformanceUtils.start('8.d.16.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertPSNPSHistoryForTargetLoc');
            
            system.debug('mapStockHistory'+mapStockHistory);
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
            if(mapUniqueKeyProductStock.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapUniqueKeyProductStock.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapUniqueKeyProductStock.values();
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
                
            system.debug('mapProductStock'+mapProductStock);
            //Populate the Product StockIds in Stock History Record.. 
            if(mapStockHistory.size() > 0 && allowStockHistory)
            {
                for(String str : mapStockHistory.keyset())
                {
                    String strUniqueKey = str.substring(16,str.length());
                    system.debug('strUniqueKey'+strUniqueKey+mapProductStock.containskey(strUniqueKey));
                    if(mapUniqueKeyProductStock.containskey(strUniqueKey))
                    {
                        system.debug('Entered..');
                        mapStockHistory.get(str).SVMXC__Product_Stock__c = mapUniqueKeyProductStock.get(strUniqueKey).id;
                    }
                }
                system.debug('mapStockHistory'+mapStockHistory.values());
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapStockHistory.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapStockHistory.values(); 
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.16.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertPSNPSHistoryForTargetLoc');
            //COMM_PerformanceUtils.start('8.d.17.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLinesForTargetLoc');
            
            //populate the PS id in the remailning Order Lines.
            if(aplOrder.orderLines.size() > 0)
            {
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    if(strTargetLocation != null && strTargetLocation.length() > 0 && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strTargetLocation.substring(0,15)+'_Available';
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                            aplOrder.orderLines[i].targetLocationPSID = mapUniqueKeyProductStock.get(strUnique).id;
                    }
                }
            }
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.17.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLinesForTargetLoc');
            //COMM_PerformanceUtils.start('8.d.18.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreateSSIfReqNPopulateTargetLocPSId');
            
            system.debug('aplOrder'+aplOrder.orderLines);    
            //Now loop through the APL Order and check that all sourceLocationPSID have the stock serial other wise create the stock serial for those and populate the targetLocationPSID in it.
            if(aplOrder.orderLines.size() > 0)
            {
                set<String> exsistingSourcePSID = new set<String>();
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    list<SVMXC__Product_Serial__c> lstTempProductSerial;
                    list<SVMXC__Stock_History__c> lstTempStockSerialHistry;
                    if(mapPSIdListStockSerial.containskey(aplOrder.orderLines[i].sourceLocationPSID) && !exsistingSourcePSID.contains(aplOrder.orderLines[i].sourceLocationPSID))
                    {
                        exsistingSourcePSID.add(aplOrder.orderLines[i].sourceLocationPSID);
                        lstTempProductSerial = new list<SVMXC__Product_Serial__c>();
                        lstTempStockSerialHistry = new list<SVMXC__Stock_History__c>();
                        lstTempProductSerial = mapPSIdListStockSerial.get(aplOrder.orderLines[i].sourceLocationPSID);
                        system.debug('lstTempProductSerial'+lstTempProductSerial.size()+lstTempProductSerial);
                        if(lstTempProductSerial.size() > 0)
                        {
                            for(SVMXC__Product_Serial__c ps : lstTempProductSerial)
                            {
                                ps.SVMXC__Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;
                                if(allowSerialHistrory)
                                {
                                    //Create Serial History Record..
                                    SVMXC__Stock_History__c serialHistory = new SVMXC__Stock_History__c();
                                    serialHistory.RecordTypeId = strSerialHistoryRtypeId;
                                    serialHistory.SVMXC__From_Product_Stock__c = aplOrder.orderLines[i].sourceLocationPSID;//Source Location Product Stock Id
                                    serialHistory.SVMXC__To_Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;//Target Location Product Stock Id
                                    serialHistory.SVMXC__Transaction_Type__c = 'Pick & Move';
                                    serialHistory.SVMXC__Date_Changed__c = system.now();
                                    serialHistory.SVMXC__Changed_By__c = userinfo.getUserId();
                                    serialHistory.SVMXC__Shipment__c  = aplOrder.orderHdrRecord.id;
                                    serialHistory.SVMXC__Shipment_Line__c  = aplOrder.orderLines[i].orderLineRecord.id;
                                    lstTempStockSerialHistry.add(serialHistory);
                                }    
                            }
                            if(lstTempStockSerialHistry.size() > 0)
                            {
                                if(mapProdStockIdSerialHistoryRec.containskey(aplOrder.orderLines[i].targetLocationPSID))
                                {
                                    mapProdStockIdSerialHistoryRec.get(aplOrder.orderLines[i].targetLocationPSID).addall(lstTempStockSerialHistry);
                                }
                                else
                                {
                                    mapProdStockIdSerialHistoryRec.put(aplOrder.orderLines[i].targetLocationPSID,lstTempStockSerialHistry);
                                }   
                            }    
                        }
                        lstProSerialTobeUpserted.addall(lstTempProductSerial);
                    }
                }
            }  
            system.debug('lstProSerialTobeUpserted'+lstProSerialTobeUpserted.size()+lstProSerialTobeUpserted);
            system.debug('mapProdStockIdSerialHistoryRec'+mapProdStockIdSerialHistoryRec.size()+mapProdStockIdSerialHistoryRec);
            
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.18.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreateSSIfReqNPopulateTargetLocPSId');
            //COMM_PerformanceUtils.start('8.d.19.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertSSNSerialHistory');
            
            
            //First upsert stock serial and then pupulate the stock serial id in serial history and insert the serial history...
            map<String,list<String>> mapProStockIdListProSerialId = new map<String,list<String>>();
            if(lstProSerialTobeUpserted.size() > 0)
            {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstProSerialTobeUpserted, COMM_SecurityUtils.Access.Upsertable)){
                   upsert lstProSerialTobeUpserted; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                 
                if(allowSerialHistrory)
                {
                    for(SVMXC__Product_Serial__c proSerial : lstProSerialTobeUpserted)
                    {
                        if(mapProStockIdListProSerialId.containskey(proSerial.SVMXC__Product_Stock__c))
                            mapProStockIdListProSerialId.get(proSerial.SVMXC__Product_Stock__c).add(proSerial.id);
                        else
                        {   
                            mapProStockIdListProSerialId.put(proSerial.SVMXC__Product_Stock__c,new list<String>());
                            mapProStockIdListProSerialId.get(proSerial.SVMXC__Product_Stock__c).add(proSerial.id);
                        }   
                    }
                }       
            }
            system.debug('mapProStockIdListProSerialId'+mapProStockIdListProSerialId);  
            if(mapProdStockIdSerialHistoryRec.size() > 0 && allowSerialHistrory)
            {
                for(String str : mapProdStockIdSerialHistoryRec.keyset())
                {
                    list<SVMXC__Stock_History__c> lstTempStockSerialHistry = new list<SVMXC__Stock_History__c>();
                    list<String> lstProductSerialId = new list<String>();
                    lstTempStockSerialHistry = mapProdStockIdSerialHistoryRec.get(str);
                    if(mapProStockIdListProSerialId.containskey(str))
                        lstProductSerialId  = mapProStockIdListProSerialId.get(str);
                    system.debug('lstTempStockSerialHistry'+lstTempStockSerialHistry.size()+lstTempStockSerialHistry);
                    system.debug('lstProductSerialId'+lstProductSerialId.size()+lstProductSerialId);    
                    if(lstTempStockSerialHistry.size() > 0 && lstProductSerialId.size() > 0)
                    {
                        for(Integer j = 0;j<lstTempStockSerialHistry.size();j++)
                        {
                            lstTempStockSerialHistry[j].SVMXC__Product_Serial__c = lstProductSerialId[j];
                        }   
                        lstStockSerialHistoryToBeUpserted.addall(lstTempStockSerialHistry);
                    }   
                }
                system.debug('lstStockSerialHistoryToBeUpserted'+lstStockSerialHistoryToBeUpserted.size()+lstStockSerialHistoryToBeUpserted);
                if(lstStockSerialHistoryToBeUpserted.size() > 0){
                    if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstStockSerialHistoryToBeUpserted, COMM_SecurityUtils.Access.Upsertable)){
                       upsert lstStockSerialHistoryToBeUpserted; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
            }       
            
            //Added by Naveen V on 13-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.19.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertSSNSerialHistory');
                           
        }
        else if(aplOrder.processType.touppercase() == 'SHIPCONFIRM')
        {
            //COMM_PerformanceUtils.start('8.d.2.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotLoc');
            //For Ship confirm the stock will go down in Depos' staging location..
            if(aplOrder.orderHdrRecord != null && aplOrder.orderHdrRecord.SVMXC__Source_Location__c != null)
                strSourceLocation = aplOrder.orderHdrRecord.SVMXC__Source_Location__c;
            list<SVMXC__Site__c> lstDepotLocation = new list<SVMXC__Site__c>();
            
            List<String> queryFieldDepotLocation= new List<String> {'id','RecordTypeId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFieldDepotLocation, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            lstDepotLocation = [select id From SVMXC__Site__c where id =: strSourceLocation and RecordTypeId =: strDepotLocationRtypeId]; //SDL-SVMX-READ-FLS-ENFORCED
            
            //COMM_PerformanceUtils.stop('8.d.2.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotLoc');
            if(lstDepotLocation.size() > 0)
            {
            
                //COMM_PerformanceUtils.start('8.d.3.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotChildStagingLoc');
            
                 list<SVMXC__Site__c> lstDepotsStagingLocation = new list<SVMXC__Site__c>();
                 List<String> queryFieldDepotStagingLocation= new List<String> {'id','RecordTypeId', 'Name', 'SVMXC__Parent__c','SVMXC__IsStaging_Location__c', 'SVMXC__Stocking_Location__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFieldDepotStagingLocation, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                 lstDepotsStagingLocation = [select id,Name,RecordTypeId,SVMXC__Parent__c,SVMXC__IsStaging_Location__c, SVMXC__Stocking_Location__c from SVMXC__Site__c where SVMXC__Parent__c =: lstDepotLocation[0].id and SVMXC__IsStaging_Location__c = true and RecordType.Name = 'Depot Child' and SVMXC__Stocking_Location__c = true]; //SDL-SVMX-READ-FLS-ENFORCED
                 
                 //COMM_PerformanceUtils.stop('8.d.3.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryDepotChildStagingLoc');
                 if(lstDepotsStagingLocation.size() > 0)
                    strSourceLocation = lstDepotsStagingLocation[0].id;   
                 else
                 {
                    //response.success = false;
                    //response.message = 'Staging Location is not configured for this deopt';
                    return response;
                 }   
            }
            system.debug('strSourceLocation'+strSourceLocation);   
            //Loop APL Order Lines to get the set of product Id and Delivery Location.
            if(aplOrder.orderLines.size() > 0)
            {
            
                //COMM_PerformanceUtils.start('8.d.4.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopOrderLines');
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Product__c != null)
                        setProductId.add(aplOrder.orderLines[i].orderLineRecord.SVMXC__Product__c);
                }
                
                //COMM_PerformanceUtils.stop('8.d.4.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopOrderLines');
            }
            system.debug('setProductId'+setProductId.size()+setProductId);
            //Get the product stock for Source location(Staging location of depot) Available stock(To decrease)
            if(setProductId.size() > 0 && strSourceLocation != null && strSourceLocation.length() > 0)
            {
            
                //COMM_PerformanceUtils.start('8.d.5.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProductStock');
                map<String,SVMXC__Product_Stock__c> mapTemp = new map<String,SVMXC__Product_Stock__c>();
                List<String> queryFieldShip= new List<String> {'id','SVMXC__Status__c', 'Name', 'SVMXC__Quantity2__c','SVMXC__Product__c', 'SVMXC__Location__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFieldShip, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                mapTemp.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Name, Id From SVMXC__Product_Stock__c where SVMXC__Status__c =: 'Available' and SVMXC__Product__c IN : setProductId and SVMXC__Location__c =: strSourceLocation]);
                system.debug('mapTemp'+mapTemp.size()+mapTemp);
                //COMM_PerformanceUtils.stop('8.d.5.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProductStock');
                if(mapTemp.size() > 0)
                    mapProductStock.putall(mapTemp);
            }
            //Get the product stock for Source location(Staging location of depot) DECREASED stock(To Increase)
            if(setProductId.size() > 0 && strSourceLocation != null && strSourceLocation.length() > 0)
            {
            
            //COMM_PerformanceUtils.start('8.d.6.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProductStockforSourceLoc');
            
                map<String,SVMXC__Product_Stock__c> mapTemp = new map<String,SVMXC__Product_Stock__c>();
                List<String> queryFieldShipDecreased= new List<String> {'id','SVMXC__Status__c', 'Name', 'SVMXC__Quantity2__c','SVMXC__Product__c', 'SVMXC__Location__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFieldShipDecreased, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                mapTemp.putAll([Select SVMXC__Status__c, SVMXC__Quantity2__c, SVMXC__Product__c, SVMXC__Location__c, Name, Id From SVMXC__Product_Stock__c where SVMXC__Status__c =: 'DECREASED' and SVMXC__Product__c IN : setProductId and SVMXC__Location__c =: strSourceLocation]);
                system.debug('mapTemp'+mapTemp.size()+mapTemp);
                if(mapTemp.size() > 0)
                    mapProductStock.putall(mapTemp);
                    
            //COMM_PerformanceUtils.stop('8.d.6.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryProductStockforSourceLoc');      
            }
            
            //COMM_PerformanceUtils.start('8.d.7.INVENTORY-UPDATES - ActualInventoryMethodCalled - MapCreateForUniquePS');
            // Create map of Uniquekey(Product_Location_Status) and product stock Id..
            if(mapProductStock.size() > 0)
            {
                for(String s:mapProductStock.keyset())
                {
                    if(mapProductStock.get(s).SVMXC__Product__c != null && mapProductStock.get(s).SVMXC__Location__c != null && mapProductStock.get(s).SVMXC__Status__c != null)
                    {
                        String strUniqueKey = String.valueof(mapProductStock.get(s).SVMXC__Product__c).substring(0,15)+'_'+String.valueof(mapProductStock.get(s).SVMXC__Location__c).substring(0,15)+'_'+mapProductStock.get(s).SVMXC__Status__c;
                        mapUniqueKeyProductStock.put(strUniqueKey,mapProductStock.get(s));
                    }    
                }
            }
            
            //COMM_PerformanceUtils.stop('8.d.7.INVENTORY-UPDATES - ActualInventoryMethodCalled - MapCreateForUniquePS');
            //COMM_PerformanceUtils.start('8.d.8.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryStockSerialAndLoop');
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
            //Retrive the Stocked serial for all Porduct stock.
            if(mapProductStock.size() > 0){
                List<String> queryFieldShipSerial= new List<String> {'id','SVMXC__Product__c', 'Name', 'SVMXC__Product_Stock__c','SVMXC__Active__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Serial__c', queryFieldShipSerial, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                mapStockSerial.putall([Select SVMXC__Product__c, SVMXC__Product_Stock__c, SVMXC__Active__c, Name, Id From SVMXC__Product_Serial__c where SVMXC__Product_Stock__c IN : mapProductStock.keyset()]);
            }
            system.debug('mapStockSerial'+mapStockSerial);
            //Create a map of PSId and List<SVMXC__Product_Serial__c> 
            if(mapStockSerial.size() > 0)
            {
                for(String str:mapStockSerial.keyset())
                {
                    if(mapStockSerial.get(str).SVMXC__Product_Stock__c != null)
                    {
                        String strPSId = string.valueof(mapStockSerial.get(str).SVMXC__Product_Stock__c);
                        if(mapPSIdListStockSerial.containskey(strPSId))
                            mapPSIdListStockSerial.get(strPSId).add(mapStockSerial.get(str));
                        else
                        {
                            mapPSIdListStockSerial.put(strPSId,new list<SVMXC__Product_Serial__c>());
                            mapPSIdListStockSerial.get(strPSId).add(mapStockSerial.get(str));
                        }
                    }
                }
            }
            system.debug('mapPSIdListStockSerial'+mapPSIdListStockSerial); 
            //COMM_PerformanceUtils.stop('8.d.8.INVENTORY-UPDATES - ActualInventoryMethodCalled - QueryStockSerialAndLoop');
            //COMM_PerformanceUtils.start('8.d.9.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapProdStockNPSHistory');
            //For all APL OrderLine Do the Product Stock & Product Stock History Update for the Source Location
            if(aplOrder.orderLines.size() > 0)
            {
                Double intExsistingQty = 0;
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    intExsistingQty = 0;
                    if(strSourceLocation != null && strSourceLocation.length() > 0 && objLine.SVMXC__Product__c != null) 
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_Available';
                        String strUniqueForStockHistory =  String.valueof(objLine.id).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_Available';
                        system.debug('strUnique'+strUnique);
                        system.debug('strUniqueForStockHistory'+strUniqueForStockHistory);
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                        {
                            //For Ship Confirm and Source Location Decrease the Product Quntity 
                            intExsistingQty = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c =  mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c - objLine.SVMXC__Picked_Qty__c;
                        }
                        else
                        {
                            system.debug('strUnique'+mapUniqueKeyProductStock.containskey(strUnique));
                            SVMXC__Product_Stock__c objPS = new SVMXC__Product_Stock__c();
                            objPS.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objPS.SVMXC__Location__c = strSourceLocation;
                            objPS.SVMXC__Status__c = 'Available';
                            objPS.SVMXC__Quantity2__c = objLine.SVMXC__Picked_Qty__c;
                            mapUniqueKeyProductStock.put(strUnique,objPS);
                        }
                        if(allowStockHistory)
                        {   
                            //Create Stock History Record.
                            SVMXC__Stock_History__c objSH = new SVMXC__Stock_History__c();
                            objSH.RecordTypeId = strStockHistoryRtypeId;
                            objSH.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objSH.SVMXC__Location__c = strSourceLocation;
                            objSH.SVMXC__Status__c = 'Available';
                            objSH.SVMXC__Transaction_Type__c  = 'Ship Confirm';
                            objSH.SVMXC__Transaction_Quantity2__c  = objLine.SVMXC__Picked_Qty__c;
                            objSH.SVMXC__Quantity_after_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            objSH.SVMXC__Change_Type__c  = 'Decrease' ;
                            objSH.SVMXC__Date_Changed__c  = system.now();
                            objSH.SVMXC__Changed_By__c  = Userinfo.getUserId() ;
                            objSH.SVMXC__Quantity_before_change2__c = intExsistingQty;
                            objSH.SVMXC__Shipment__c  = aplOrder.orderHdrRecord.id;
                            objSH.SVMXC__Shipment_Line__c  = objLine.id;
                            mapStockHistory.put(strUniqueForStockHistory,objSH);   
                        }        
                    }   
                }
            }       
            //COMM_PerformanceUtils.stop('8.d.9.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapProdStockNPSHistory');
            //COMM_PerformanceUtils.start('8.d.10.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertingPSNPSHistory');
            system.debug('mapStockHistory'+mapStockHistory);
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
            if(mapUniqueKeyProductStock.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapUniqueKeyProductStock.values(), COMM_SecurityUtils.Access.Upsertable)){
                   upsert mapUniqueKeyProductStock.values();
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
                
            system.debug('mapProductStock'+mapProductStock);
            //Populate the Product StockIds in Stock History Record.. 
            if(mapStockHistory.size() > 0 && allowStockHistory)
            {
                for(String str : mapStockHistory.keyset())
                {
                    String strUniqueKey = str.substring(16,str.length());
                    system.debug('strUniqueKey'+strUniqueKey+mapProductStock.containskey(strUniqueKey));
                    if(mapUniqueKeyProductStock.containskey(strUniqueKey))
                        mapStockHistory.get(str).SVMXC__Product_Stock__c = mapUniqueKeyProductStock.get(strUniqueKey).id;
                }
                system.debug('mapStockHistory'+mapStockHistory.values());
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapStockHistory.values(), COMM_SecurityUtils.Access.Upsertable)){
                    upsert mapStockHistory.values();
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
            }
            
            //COMM_PerformanceUtils.stop('8.d.10.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertingPSNPSHistory');
            //COMM_PerformanceUtils.start('8.d.11.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLines');
            
            //populate the PS id in the remailning Order Lines.
            if(aplOrder.orderLines.size() > 0)
            {
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    if(strSourceLocation != null && strSourceLocation.length() > 0 && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_Available';
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                            aplOrder.orderLines[i].sourceLocationPSID = mapUniqueKeyProductStock.get(strUnique).id;
                    }
                }
            }
            
            //COMM_PerformanceUtils.stop('8.d.11.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLines');
            //COMM_PerformanceUtils.start('8.d.12.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapPSNPSHistoryForSourceLoc');
            
            //For all APL OrderLine Do the Product Stock & Product Stock History Update for the Source Location
            if(aplOrder.orderLines.size() > 0)
            {
                Double intExsistingQty = 0;
                mapStockHistory.clear();
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    intExsistingQty = 0;
                    if(strSourceLocation != null && strSourceLocation.length() > 0 && objLine.SVMXC__Product__c != null) 
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_DECREASED';
                        String strUniqueForStockHistory =  String.valueof(objLine.id).substring(0,15)+'_'+String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_DECREASED';
                        system.debug('strUnique'+strUnique);
                        system.debug('strUniqueForStockHistory'+strUniqueForStockHistory);
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                        {
                            //For Ship Confirm and Source Location Increase the Product Quntity in DECREASED stage
                            intExsistingQty = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c =  mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c + objLine.SVMXC__Picked_Qty__c;
                        }
                        else
                        {
                            system.debug('asdfggh'+mapUniqueKeyProductStock.containskey(strUnique));
                            SVMXC__Product_Stock__c objPS = new SVMXC__Product_Stock__c();
                            objPS.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objPS.SVMXC__Location__c = strSourceLocation;
                            objPS.SVMXC__Status__c = 'DECREASED';
                            objPS.SVMXC__Quantity2__c = objLine.SVMXC__Picked_Qty__c;
                            mapUniqueKeyProductStock.put(strUnique,objPS);
                        }
                        if(allowStockHistory)
                        {   
                            //Create Stock History Record.
                            SVMXC__Stock_History__c objSH = new SVMXC__Stock_History__c();
                            objSH.RecordTypeId = strStockHistoryRtypeId;
                            objSH.SVMXC__Product__c = objLine.SVMXC__Product__c;
                            objSH.SVMXC__Location__c = strSourceLocation;
                            objSH.SVMXC__Status__c = 'DECREASED';
                            objSH.SVMXC__Transaction_Type__c  = 'Ship Confirm';
                            objSH.SVMXC__Transaction_Quantity2__c  = objLine.SVMXC__Picked_Qty__c;
                            objSH.SVMXC__Quantity_after_change2__c = mapUniqueKeyProductStock.get(strUnique).SVMXC__Quantity2__c;
                            objSH.SVMXC__Change_Type__c  = 'Increase' ;
                            objSH.SVMXC__Date_Changed__c  = system.now();
                            objSH.SVMXC__Changed_By__c  = Userinfo.getUserId() ;
                            objSH.SVMXC__Quantity_before_change2__c = intExsistingQty;
                            objSH.SVMXC__Shipment__c  = aplOrder.orderHdrRecord.id;
                            objSH.SVMXC__Shipment_Line__c  = objLine.id;
                            mapStockHistory.put(strUniqueForStockHistory,objSH);  
                        }        
                    }   
                }
            }       
            
            //COMM_PerformanceUtils.stop('8.d.12.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreatingMapPSNPSHistoryForSourceLoc');
            //COMM_PerformanceUtils.start('8.d.13.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertPSNPSHistoryForSourceLoc');
            
            system.debug('mapStockHistory'+mapStockHistory);
            system.debug('mapUniqueKeyProductStock'+mapUniqueKeyProductStock);
            if(mapUniqueKeyProductStock.size() > 0){
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapUniqueKeyProductStock.values(), COMM_SecurityUtils.Access.Upsertable)){
                    upsert mapUniqueKeyProductStock.values();
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
               
            system.debug('mapProductStock'+mapProductStock);
            //Populate the Product StockIds in Stock History Record.. 
            if(mapStockHistory.size() > 0 && allowStockHistory)
            {
                for(String str : mapStockHistory.keyset())
                {
                    String strUniqueKey = str.substring(16,str.length());
                    system.debug('strUniqueKey'+strUniqueKey+mapProductStock.containskey(strUniqueKey));
                    if(mapUniqueKeyProductStock.containskey(strUniqueKey))
                    {
                        system.debug('Entered..');
                        mapStockHistory.get(str).SVMXC__Product_Stock__c = mapUniqueKeyProductStock.get(strUniqueKey).id;
                    }
                }
                system.debug('mapStockHistory'+mapStockHistory.values());
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(mapStockHistory.values(), COMM_SecurityUtils.Access.Upsertable)){
                    upsert mapStockHistory.values();
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
            }
            
            //COMM_PerformanceUtils.stop('8.d.13.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertPSNPSHistoryForSourceLoc');
            //COMM_PerformanceUtils.start('8.d.14.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLinesForSourceLoc');
            
            //populate the PS id in the remailning Order Lines.
            if(aplOrder.orderLines.size() > 0)
            {
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                    objLine = aplOrder.orderLines[i].orderLineRecord;
                    if(strSourceLocation != null && strSourceLocation.length() > 0 && objLine.SVMXC__Product__c != null)
                    {
                        String strUnique =  String.valueof(objLine.SVMXC__Product__c).substring(0,15)+'_'+strSourceLocation.substring(0,15)+'_DECREASED';
                        if(mapUniqueKeyProductStock.containskey(strUnique))
                            aplOrder.orderLines[i].targetLocationPSID = mapUniqueKeyProductStock.get(strUnique).id;
                    }
                }
            }
            system.debug('aplOrder'+aplOrder.orderLines);
            
            //COMM_PerformanceUtils.stop('8.d.14.INVENTORY-UPDATES - ActualInventoryMethodCalled - LoopRemainingOrderLinesForSourceLoc');
            //COMM_PerformanceUtils.start('8.d.15.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreateSSIfReqNPopulateSourceLocPSId');
            //Now loop through the APL Order and check that all sourceLocationPSID have the stock serial other wise create the stock serial for those and populate the targetLocationPSID in it.
            if(aplOrder.orderLines.size() > 0)
            {
                set<String> exsistingSourcePSID = new set<String>();
                for(Integer i = 0 ;i<aplOrder.orderLines.size();i++)
                {
                    list<SVMXC__Product_Serial__c> lstTempProductSerial;
                    list<SVMXC__Stock_History__c> lstTempStockSerialHistry;
                    if(mapPSIdListStockSerial.containskey(aplOrder.orderLines[i].sourceLocationPSID) && !exsistingSourcePSID.contains(aplOrder.orderLines[i].sourceLocationPSID))
                    {
                        exsistingSourcePSID.add(aplOrder.orderLines[i].sourceLocationPSID);
                        lstTempProductSerial = new list<SVMXC__Product_Serial__c>();
                        lstTempStockSerialHistry = new list<SVMXC__Stock_History__c>();
                        lstTempProductSerial = mapPSIdListStockSerial.get(aplOrder.orderLines[i].sourceLocationPSID);
                        system.debug('lstTempProductSerial'+lstTempProductSerial.size()+lstTempProductSerial);
                        if(lstTempProductSerial.size() > 0)
                        {
                            for(SVMXC__Product_Serial__c ps : lstTempProductSerial)
                            {
                                ps.SVMXC__Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;
                                if(allowSerialHistrory)
                                {
                                    //Create Serial History Record..
                                    SVMXC__Stock_History__c serialHistory = new SVMXC__Stock_History__c();
                                    serialHistory.RecordTypeId = strSerialHistoryRtypeId;
                                    serialHistory.SVMXC__From_Product_Stock__c = aplOrder.orderLines[i].sourceLocationPSID;//Source Location Product Stock Id
                                    serialHistory.SVMXC__To_Product_Stock__c = aplOrder.orderLines[i].targetLocationPSID;//Target Location Product Stock Id
                                    serialHistory.SVMXC__Transaction_Type__c = 'Ship Confirm';
                                    serialHistory.SVMXC__Date_Changed__c = system.now();
                                    serialHistory.SVMXC__Changed_By__c = userinfo.getUserId();
                                    serialHistory.SVMXC__Shipment__c  = aplOrder.orderHdrRecord.id;
                                    serialHistory.SVMXC__Shipment_Line__c  = aplOrder.orderLines[i].orderLineRecord.id;
                                    lstTempStockSerialHistry.add(serialHistory);
                                }    
                            }
                            if(lstTempStockSerialHistry.size() > 0)
                            {
                                if(mapProdStockIdSerialHistoryRec.containskey(aplOrder.orderLines[i].targetLocationPSID))
                                {
                                    mapProdStockIdSerialHistoryRec.get(aplOrder.orderLines[i].targetLocationPSID).addall(lstTempStockSerialHistry);
                                }
                                else
                                {
                                    mapProdStockIdSerialHistoryRec.put(aplOrder.orderLines[i].targetLocationPSID,lstTempStockSerialHistry);
                                }   
                            }    
                        }
                        lstProSerialTobeUpserted.addall(lstTempProductSerial);
                    }
                }
            }  
            system.debug('lstProSerialTobeUpserted'+lstProSerialTobeUpserted.size()+lstProSerialTobeUpserted);
            system.debug('mapProdStockIdSerialHistoryRec'+mapProdStockIdSerialHistoryRec.size()+mapProdStockIdSerialHistoryRec);
            
            //COMM_PerformanceUtils.stop('8.d.15.INVENTORY-UPDATES - ActualInventoryMethodCalled - CreateSSIfReqNPopulateSourceLocPSId');
            //COMM_PerformanceUtils.start('8.d.16.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertSSNSerialHistory');
            
            
            //First upsert stock serial and then pupulate the stock serial id in serial history and insert the serial history...
            map<String,list<String>> mapProStockIdListProSerialId = new map<String,list<String>>();
            if(lstProSerialTobeUpserted.size() > 0)
            {
                if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstProSerialTobeUpserted, COMM_SecurityUtils.Access.Upsertable)){
                  upsert lstProSerialTobeUpserted; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                }
                else{
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                if(allowSerialHistrory)
                {   
                    for(SVMXC__Product_Serial__c proSerial : lstProSerialTobeUpserted)
                    {
                        if(mapProStockIdListProSerialId.containskey(proSerial.SVMXC__Product_Stock__c))
                            mapProStockIdListProSerialId.get(proSerial.SVMXC__Product_Stock__c).add(proSerial.id);
                        else
                        {   
                            mapProStockIdListProSerialId.put(proSerial.SVMXC__Product_Stock__c,new list<String>());
                            mapProStockIdListProSerialId.get(proSerial.SVMXC__Product_Stock__c).add(proSerial.id);
                        }   
                    }
                }       
            }
            system.debug('mapProStockIdListProSerialId'+mapProStockIdListProSerialId);  
            if(mapProdStockIdSerialHistoryRec.size() > 0 && allowSerialHistrory)
            {
                for(String str : mapProdStockIdSerialHistoryRec.keyset())
                {
                    list<SVMXC__Stock_History__c> lstTempStockSerialHistry = new list<SVMXC__Stock_History__c>();
                    list<String> lstProductSerialId = new list<String>();
                    lstTempStockSerialHistry = mapProdStockIdSerialHistoryRec.get(str);
                    if(mapProStockIdListProSerialId.containskey(str))
                        lstProductSerialId  = mapProStockIdListProSerialId.get(str);
                    system.debug('lstTempStockSerialHistry'+lstTempStockSerialHistry.size()+lstTempStockSerialHistry);
                    system.debug('lstProductSerialId'+lstProductSerialId.size()+lstProductSerialId);    
                    if(lstTempStockSerialHistry.size() > 0 && lstProductSerialId.size() > 0)
                    {
                        for(Integer j = 0;j<lstTempStockSerialHistry.size();j++)
                        {
                            lstTempStockSerialHistry[j].SVMXC__Product_Serial__c = lstProductSerialId[j];
                        }   
                        lstStockSerialHistoryToBeUpserted.addall(lstTempStockSerialHistry);
                    }   
                }
                system.debug('lstStockSerialHistoryToBeUpserted'+lstStockSerialHistoryToBeUpserted.size()+lstStockSerialHistoryToBeUpserted);
                if(lstStockSerialHistoryToBeUpserted.size() > 0){
                     if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstStockSerialHistoryToBeUpserted, COMM_SecurityUtils.Access.Upsertable)){
                       upsert lstStockSerialHistoryToBeUpserted; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                    }
                    else{
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                }
            }           

        //COMM_PerformanceUtils.stop('8.d.16.INVENTORY-UPDATES - ActualInventoryMethodCalled - UpsertSSNSerialHistory');            
        }    
        response.success = true;  
        return response;
    }
}