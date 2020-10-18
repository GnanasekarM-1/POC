public with sharing class APL_RMAUtils 
{
    Map <String, Schema.SObjectType> schemaMap = new Map <String, Schema.SObjectType>();//Schema.getGlobalDescribe();
    //Method to get the create the RMA and RMA lines.
    public INTF_WebServicesDef.INTF_SFMResponse APL_GenerateRMADoc(INTF_WebServicesDef.INTF_SFMRequest docGenRequest)
    {
        String strCaseID = null, strHeaderMapID = null, strLineMapId = null, strLocationId = null, strRMAId = null;
        INTF_WebServicesDef.INTF_SFMResponse objResForGenDocs = new INTF_WebServicesDef.INTF_SFMResponse();
        objResForGenDocs.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        List<String> lstCaseLineIds = new List<String>();   
        Map<String,List<String>> mapLocLstCaseIds = new Map<String,List<String>>();
        INTF_ApplyMapping objApplyRMAMapping = new INTF_ApplyMapping();
        objResForGenDocs.success = true;
        try
        {   
            Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType s : gd.values())
            {
                schemaMap.put(s.getDescribe().getName(),s);
            }
            system.debug('Input request: ' + docGenRequest);
            for(INTF_WebServicesDef.SVMXMap objCurMap : docGenRequest.valueMap)
            {
                if(objCurMap.key == 'CaseID')
                {
                    strCaseID = objCurMap.value;
                }else if(objCurMap.key == 'HeaderMapId')
                {
                    strHeaderMapID = objCurMap.value;
                }else if(objCurMap.key == 'LineMapId')
                {
                    strLineMapId = objCurMap.value;
                }else if(objCurMap.key == 'RMADetails')
                {
                    strLocationId = objCurMap.value;
                    lstCaseLineIds = objCurMap.values;
                }else if(objCurMap.key == 'RMAId')
                {
                    strRMAId = objCurMap.value;
                }
            }
            if(lstCaseLineIds != null && lstCaseLineIds.size() > 0)
            {
               
                //Check whether already RMA is existing for the Combination of case and location.
                List<SVMXC__RMA_Shipment_Order__c> lstExistingRMAOrder = null;
                if(strRMAId != null)
                {
                    List<String> queryFields = new List<String>{'id'};
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    lstExistingRMAOrder = [Select id from SVMXC__RMA_Shipment_Order__c where ID = :strRMAId]; //SDL-SVMX-READ-FLS-ENFORCED
                }
                if(lstExistingRMAOrder != null && lstExistingRMAOrder.size() > 0)
                {
                    //Add the remaining lines to the RMA Order.
                    CreateRMALinesForRMA(lstCaseLineIds,strRMAId,strLineMapId,objApplyRMAMapping);              
                }else
                {
                    //Create the RMA Order and the RMA lines to the RMA Order.                  
                    List<SVMXC__RMA_Shipment_Order__c> lstRMAOrder = new List<SVMXC__RMA_Shipment_Order__c>();
                    lstRMAOrder.add(new SVMXC__RMA_Shipment_Order__c());
                    if(strHeaderMapID != null && strHeaderMapID.length() > 0 )
                    {
                        lstRMAOrder = objApplyRMAMapping.getApplyMapping(lstRMAOrder, strHeaderMapID, strCaseID, false, schemaMap);
                    }
                    if(lstRMAOrder != null && lstRMAOrder.size() > 0)
                    {
                        lstRMAOrder[0].SVMXC__Destination_Location__c = strLocationId;
                        lstRMAOrder[0].SVMXC__Case__c = strCaseID;
                        lstRMAOrder[0].SVMXC__Fulfillment_Type__c = 'Repair';
                        
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRMAOrder[0], COMM_SecurityUtils.Access.Createable ) ) {
                            insert lstRMAOrder[0];
                        } else {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        
                        strRMAId = lstRMAOrder[0].id;
                        //CreateRMALinesForRMA(lstCaseLineIds,strRMAId,strLineMapId,objApplyRMAMapping);
                    }
                    objResForGenDocs.valueMap.addAll(docGenRequest.valueMap);
                    objResForGenDocs.valueMap.add(new INTF_WebServicesDef.SVMXMap('RMAid', strRMAId));
                }
                
            }else
            {
                objResForGenDocs.success = false;
                objResForGenDocs.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ''));
            }
            System.debug('Case Rec Id: ' + strCaseID);
        }catch(DMLException ex)
        {
            objResForGenDocs.success = false;
            objResForGenDocs.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage()));   
        }  
        catch(Exception ex)
        {
            objResForGenDocs.success = false;
            objResForGenDocs.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage()));   
        }
        return objResForGenDocs;
    }
    
    //Create the lines for the RMA
    private void CreateRMALinesForRMA(List<String> caseLines,String rmaID,String lineMapId,INTF_ApplyMapping appMapping)
    {
        List<String> lstIDsFromRMALines = new List<String>();
        List<SVMXC__RMA_Shipment_Line__c> lstRMALines = new List<SVMXC__RMA_Shipment_Line__c>();
         List<SVMXC__RMA_Shipment_Line__c> lstRMALinesAfterMapping = new List<SVMXC__RMA_Shipment_Line__c>();
        SVMXC__RMA_Shipment_Line__c objCurrLine = null;
        boolean thereMAPId = false;
        Map<String,SObject> mapCaseLineToRMALine = new Map<String,SObject>();
        try
        {
            if(lineMapId != null && lineMapId.length() > 0)
            {
                thereMAPId = true;
            }
            List<String> queryFields = new List<String>{'id', 'SVMXC__Quantity__c','SVMXC__Route_Card__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Case_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            //get the quantity for the caseline
            Map<Id,SVMXC__Case_Line__c> mapIdCaseLine = new Map<Id,SVMXC__Case_Line__c>();
             mapIdCaseLine.putAll([Select Id, SVMXC__Quantity__c,SVMXC__Route_Card__c from SVMXC__Case_Line__c where Id in :caseLines]);
            List<Id> lstRouteCardIds = new List<Id>();
            Map<String,String> mapRouteCardStop = new Map<String,String>();
            
            queryFields = new List<String>{'id'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Route_Stop__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            //This info is to update the routestop in the RMA line
            Map<Id,SVMXC__Route_Stop__c> mapIdRouteStop = new Map<Id,SVMXC__Route_Stop__c>();
            mapIdRouteStop.putAll([Select Id, SVMXC__Record_Card__c from SVMXC__Route_Stop__c where SVMXC__Record_Card__r.SVMXC__Case_Line__c in :caseLines and SVMXC__Stop_Number__c = 1]);
            for(ID objCurr : mapIdRouteStop.keySet())
            {
                mapRouteCardStop.put(mapIdRouteStop.get(objCurr).SVMXC__Record_Card__c,objCurr);
            }
            
            for(String strCaseLineID : caseLines)
            {
                system.debug('Case Line ID: ' + strCaseLineID);
                objCurrLine = new SVMXC__RMA_Shipment_Line__c();
                objCurrLine.SVMXC__Case_Line__c = strCaseLineID;
                objCurrLine.SVMXC__RMA_Shipment_Order__c = rmaID;
                objCurrLine.SVMXC__Route_Card__c = mapIdCaseLine.get(strCaseLineID).SVMXC__Route_Card__c;
                objCurrLine.SVMXC__Route_Stop__c = mapRouteCardStop.get(objCurrLine.SVMXC__Route_Card__c);
                if(mapIdCaseLine.containsKey(strCaseLineID))
                {
                    objCurrLine.SVMXC__Expected_Quantity2__c = mapIdCaseLine.get(strCaseLineID).SVMXC__Quantity__c;
                }
                mapCaseLineToRMALine.put(strCaseLineID,objCurrLine);
                lstRMALines.add(objCurrLine); 
                lstRouteCardIds.add(mapIdCaseLine.get(strCaseLineID).SVMXC__Route_Card__c);                          
            }
            if(thereMAPId)
            {
                lstRMALinesAfterMapping = appMapping.getApplyMapping1(lineMapId, mapCaseLineToRMALine, false, schemaMap);
                if(lstRMALinesAfterMapping != null && lstRMALinesAfterMapping.size() > 0)
                {
                    lstRMALines = lstRMALinesAfterMapping;
                }
                System.debug('All RMA lines after ApplyMapping: ' + lstRMALines);                             
            }
            
            if( !lstRMALines.isEmpty() && COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRMALines, COMM_SecurityUtils.Access.Createable ) ) {
                insert lstRMALines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            Map<String,String> mapCaseRmaInfo = new Map<String,String>();
            for(SVMXC__RMA_Shipment_Line__c objCurrRMALine : lstRMALines)
            {
                mapCaseRmaInfo.put(objCurrRMALine.SVMXC__Case_Line__c,objCurrRMALine.id);
            }
            //now update the route card
            List<SVMXC__Route_Card__c> lstRouteCards = [Select Id, SVMXC__RMA__c, SVMXC__RMA_Line__c, SVMXC__Case_Line__c from SVMXC__Route_Card__c where Id in :lstRouteCardIds];
            if(lstRouteCards.size() > 0)
            {
                for(SVMXC__Route_Card__c objCurr : lstRouteCards)
                {
                    objCurr.SVMXC__RMA__c = rmaID;
                    objCurr.SVMXC__RMA_Line__c = mapCaseRmaInfo.get(objCurr.SVMXC__Case_Line__c);
                }
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRouteCards, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert lstRouteCards; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            }
        }catch(DMLException ex)
        {
            throw ex;   
        }        
        catch(Exception ex)
        {
            throw ex;
        }       
    }
    
    // Get the Information related to the common locations for the given case id for creating RMA for each locations
    public INTF_WebServicesDef.INTF_SFMResponse APL_CalculateRMAFromCase(INTF_WebServicesDef.INTF_SFMRequest docCalcRequest)
    {
        String strCaseID = null;
        String strProcessID = null;
        INTF_WebServicesDef.INTF_SFMResponse objResForGenDocs = new INTF_WebServicesDef.INTF_SFMResponse();
        objResForGenDocs.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
        INTF_WebServicesDef.INTF_SFMRequest objDocCalcRequest = docCalcRequest;
        string strLocId = null;
        Set<String> lstCaseLines = null;
        Map<String,Set<String>> mapLocLstCaseIds = new Map<String,Set<String>>();
        INTF_WebServicesDef.SVMXMap objResMap = null;
        try
        {
            system.debug('Case Details: ' + objDocCalcRequest);
            if(objDocCalcRequest != null)
            {
                for(INTF_WebServicesDef.SVMXMap svmxMap: objDocCalcRequest.valueMap)
                {
                    if(svmxMap.key == 'CaseId')
                        strCaseID = svmxMap.value;
                    if(svmxMap.key == 'ProcessId')
                        strProcessID = svmxMap.value;
                }
            }
           
            List<String> queryFields = new List<String>{'id',  'Name', 'RecordTypeId', 'SVMXC__Submodule__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            //List<SVMXC__Route_Card__c> lstRouteInfoFrCase = [Select Id, SVMXC__Case_Line__c, SVMXC__First_Stop__c From SVMXC__Route_Card__c where SVMXC__Case__c = :strCaseID];
            List<SVMXC__ServiceMax_Processes__c> SVMXProcess = new List<SVMXC__ServiceMax_Processes__c>();
            SVMXProcess = [select Id, Name, RecordTypeId, SVMXC__Submodule__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Initiate Return Process' and (SVMXC__ProcessID__c =: strProcessId or id =: strProcessId)]; //SDL-SVMX-READ-FLS-ENFORCED
            
            string strWhereClause = '';
            if(SVMXProcess != null && SVMXProcess.size() == 1)
            {
                string expId = SVMXProcess[0].SVMXC__Submodule__c;
                if(expId != null && expId.length() > 0)
                {
                    SVMXC__ServiceMax_Processes__c expProcess = new SVMXC__ServiceMax_Processes__c();
                    queryFields = new List<String>{'id', 'SVMXC__Parent_Object_Criteria__c'};
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    expProcess = [select id, SVMXC__Parent_Object_Criteria__c  from SVMXC__ServiceMax_Processes__c where id =: expId]; //SDL-SVMX-READ-FLS-ENFORCED
                    strWhereClause = expProcess.SVMXC__Parent_Object_Criteria__c;
                }
            }
            
            List<SVMXC__Case_Line__c> lstRouteInfoFrCaseLine = new List<SVMXC__Case_Line__c>();
            queryFields = new List<String>{'Id', 'SVMXC__Route_Card__r.SVMXC__First_Stop__c', 'SVMXC__Case__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Case_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            if(strWhereClause != null && strWhereClause.length() > 0)
            {
                string strSOQL = 'Select Id, SVMXC__Route_Card__r.SVMXC__First_Stop__c From SVMXC__Case_Line__c where SVMXC__Case__c=\'' + strCaseID + '\' and ' + strWhereClause;
                lstRouteInfoFrCaseLine = database.query(strSOQL);
            }
            else
                lstRouteInfoFrCaseLine = [Select Id, SVMXC__Route_Card__r.SVMXC__First_Stop__c From SVMXC__Case_Line__c where SVMXC__Case__c = :strCaseID]; //SDL-SVMX-READ-FLS-ENFORCED
                
            if(lstRouteInfoFrCaseLine != null && lstRouteInfoFrCaseLine.size() > 0)
            {
                //Create the mao for the common locations for the case lines
                system.debug('Route card :'+lstRouteInfoFrCaseLine);
                
                for(SVMXC__Case_Line__c objCurrRoutCard : lstRouteInfoFrCaseLine)
                {
                    system.debug('Route card for case line: '+objCurrRoutCard.SVMXC__Route_Card__c);
                    if(objCurrRoutCard.SVMXC__Route_Card__c != null)
                    {
                        strLocId = objCurrRoutCard.SVMXC__Route_Card__r.SVMXC__First_Stop__c;
                        if(strLocId != null && !mapLocLstCaseIds.containsKey(strLocId))
                        {
                            lstCaseLines = new Set<String>();
                            lstCaseLines.add(objCurrRoutCard.Id);
                            mapLocLstCaseIds.put(strLocId,lstCaseLines);
                        }
                        else
                        {
                            if(mapLocLstCaseIds.get(strLocId) != null)
                                mapLocLstCaseIds.get(strLocId).add(objCurrRoutCard.Id);
                        }
                    }
                }
                system.debug('Map Location to CAse IDs: ' + mapLocLstCaseIds);
                
                //Convert the map to the response.
                for(String strLoc : mapLocLstCaseIds.keySet())
                {
                    objResMap = new INTF_WebServicesDef.SVMXMap();
                    objResMap.key = strLoc;
                    objResMap.values = new List<String>();
                    objResMap.values.addAll(mapLocLstCaseIds.get(strLoc));                    
                    objResForGenDocs.valueMap.add(objResMap);   
                }
            }
            if(objResForGenDocs.valueMap != null && objResForGenDocs.valueMap.size()>0)
                objResForGenDocs.success = true;
            else
            {
                objResForGenDocs.success = false;
                objResForGenDocs.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', system.label.APL001_TAG026));
            }
            System.debug('Response: ' + objResForGenDocs);
        }catch(Exception ex)
        {
            objResForGenDocs.success = false;
            objResForGenDocs.valueMap.add(new INTF_WebServicesDef.SVMXMap('Error', ex.getMessage()));   
        }
        return objResForGenDocs;
    }
    
    public boolean APL_GetRMATemplate(String docGenRequest)
    {
        return true;
    }
    
      public class SVMXException extends Exception{}
  APL_Utils clsAPLUtils = new APL_Utils();
  APL_OrderUtils clsAPLOrderUtils = new APL_OrderUtils();
  map<Id, SVMXC.INTF_WebServicesDef.SVMXMap> mapLineLocations = new map<Id, SVMXC.INTF_WebServicesDef.SVMXMap>();
  
  public SVMXC.INTF_WebServicesDef.INTF_SFMResponse getOrderLinesWithLocation(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request, String strRecordId, String strProcessId, String strProcessType)
  {
    SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse(); 
    list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForResponse = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
    SVMXC.INTF_WebServicesDef.APL_Order aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
    list<SVMXC__ServiceMax_Config_Data__c> lstDocumentAttribute = new list<SVMXC__ServiceMax_Config_Data__c>();
    SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
    list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
    SVMXC__RMA_Shipment_Order__c orderHeader = new SVMXC__RMA_Shipment_Order__c();
    list<SVMXC__RMA_Shipment_Line__c> lstOrderLines = new list<SVMXC__RMA_Shipment_Line__c>();
    list<SVMXC__RMA_Shipment_Line__c> lstQualifiedLines = new list<SVMXC__RMA_Shipment_Line__c>();
    map<String, SVMXC__RMA_Shipment_Line__c> mapOrderLines = new map<String, SVMXC__RMA_Shipment_Line__c>();
    SVMXC__ServiceMax_Processes__c deliveryRule = new SVMXC__ServiceMax_Processes__c();

    Id depoLocation;
    map<String,String> mapAPINameLablePO = new map<String,String>();
    map<String, Schema.SObjectField> mapPOField = Schema.SObjectType.SVMXC__RMA_Shipment_Order__c.fields.getMap();
    if(mapPOField.size() > 0)
     {
       for(String str:mapPOField.keyset())
       {
         mapAPINameLablePO.put(mapPOField.get(str).getDescribe().getName(),mapPOField.get(str).getDescribe().getLabel());
       }
     }
    if(strProcessId != null && strProcessId.length() > 0)
    {
      try
      {
        SVMXProcess = [select Id, Name, RecordTypeId, SVMXC__Module__c, SVMXC__Final_Exception_Process__c, SVMXC__Name__c, SVMXC__ProcessID__c from SVMXC__ServiceMax_Processes__c where RecordType.Name = 'Receiving Process' and (SVMXC__ProcessID__c =: strProcessId or id =: strProcessId)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
        if(SVMXProcess != null)
          aplOrder.svmxProcess = SVMXProcess;
      }
      catch(exception ex)
      {
        throw new SVMXException('Process not available, please check the process definition.');
      }
    }
    if(SVMXProcess != null)
    {
      lstConfigData = [select id, Name, RecordTypeId, SVMXC__Configuration_Type__c, SVMXC__Display_Type__c, SVMXC__FKey_Name_Field__c, SVMXC__Object_Name__c, SVMXC__Field_Relationship_Name__c, SVMXC__Field_Name__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where  RecordType.Name = 'Field Mapping' and SVMXC__Dispatch_Process__c =: SVMXProcess.id]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
    }
    system.debug('lstConfigData :'+lstConfigData);
    if(strRecordId != null && strRecordId.length() > 0)
      orderHeader = [Select SVMXC__Warehouse__c, SVMXC__Tracking_Number__c, SVMXC__Total_Price2__c, SVMXC__Source_Zip__c, SVMXC__Source_Street__c, SVMXC__Source_State__c, SVMXC__Source_Location__c, SVMXC__Destination_Location__c, SVMXC__Destination_Location__r.Name, SVMXC__Source_Country__c, SVMXC__Source_City__c, SVMXC__Shipping_Terms__c, SVMXC__Shipping_Receiving_Notes__c, SVMXC__Shipping_Courier__c, SVMXC__Shipment_Reference__c, SVMXC__Shipment_Age_Bucket__c, SVMXC__Service_Order__c, SVMXC__Service_Engineer__c, SVMXC__Sales_Order_Number__c, SVMXC__SESSION_ID__c, SVMXC__Receiving_Courier__c, SVMXC__RMA_Age_Bucket__c, SVMXC__Priority__c, SVMXC__Parts_Request__c, SVMXC__Partner_Contact__c, SVMXC__Partner_Account__c, SVMXC__Order_Type__c, SVMXC__Order_Status__c, SVMXC__IsPartner__c, SVMXC__IsPartnerRecord__c, SVMXC__Expected_Receive_Date__c, SVMXC__Expected_Delivery_Date__c, SVMXC__EndpointURL__c, SVMXC__Destination_Zip__c, SVMXC__Destination_Street__c, SVMXC__Destination_State__c, SVMXC__Destination_Country__c, SVMXC__Destination_City__c, SVMXC__Delivery_Option__c, SVMXC__Contact__c, SVMXC__Company__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Case__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Billing_Type__c, SVMXC__Bill_To__c, SVMXC__Address_Type__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__RMA_Shipment_Order__c where id =: strRecordId];
    if(orderHeader != NULL && orderHeader.SVMXC__Destination_Location__c != NULL)
    {
      orderHeader.SVMXC__Source_Street__c = orderHeader.SVMXC__Destination_Location__r.Name;
      depoLocation = orderHeader.SVMXC__Destination_Location__c;
    }
    String StrOrderLineFields = ' SVMXC__Warehouse__c,SVMXC__Serial_Number_List__c,SVMXC__Picked_Qty__c,SVMXC__Use_Price_From_Pricebook__c, SVMXC__Total_Line_Price2__c, SVMXC__Ship_Location__c, SVMXC__Service_Order_Line__c, SVMXC__Service_Engineer__c, SVMXC__Serial_Number__c, SVMXC__Select__c, SVMXC__Sales_Order_Number__c, SVMXC__Returned_Condition__c, SVMXC__Reconciliation_Action__c, SVMXC__RMA_Shipment_Order__c, SVMXC__Product__c, SVMXC__Posted_To_Inventory__c, SVMXC__Parts_Request_Line__c, SVMXC__Packing_Instructions__c, SVMXC__Line_Type__c, SVMXC__Line_Status__c, SVMXC__Line_Price2__c, SVMXC__Expected_Ship_Date__c, SVMXC__Expected_Receipt_Date__c, SVMXC__Expected_Quantity2__c, SVMXC__Expected_Condition__c, SVMXC__Disposition__c, SVMXC__Disposition_Instructions__c, SVMXC__Discount_Percentage__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Actual_Ship_Date__c, SVMXC__Actual_Receipt_Date__c, SVMXC__Actual_Quantity2__c, RecordTypeId, Name, Id, SVMXC__Product__r.Name, SVMXC__Product__r.ProductCode ';
    if(lstConfigData.size() > 0)
    {
      for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
      {
        if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE')
          StrOrderLineFields += ', SVMXC__Product__r.'+config.SVMXC__Field_Name__c;
        else if(config.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE')  
          lstDocumentAttribute.add(config);
      }
    }
    if(strRecordId != null && strRecordId.length() > 0)
    {
      String query = 'Select ' +StrOrderLineFields+ ', SVMXC__Ship_Location__r.Name From SVMXC__RMA_Shipment_Line__c  where SVMXC__RMA_Shipment_Order__c =: strRecordId';
      lstOrderLines = Database.query(query);
      if(lstOrderLines.size() > 0)
      {
        for(SVMXC__RMA_Shipment_Line__c PO : lstOrderLines)
        {
          mapOrderLines.put(PO.id, PO);
        }
      }
    }
    // Get delivery rules
    try
    {
        system.debug('depoLocation ' + depoLocation);
      deliveryRule = [Select SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Delivery Rule' And SVMXC__Location__c = :depoLocation]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
      system.debug('deliveryRule ' + deliveryRule);
    }
    catch(exception ex)
    {
      throw new SVMXException('Delivery rules are not defined for the header location');
    }
    if(orderHeader != NULL)
    {
      // Do entry criteria validation for header
      if(SVMXProcess.SVMXC__Module__c != null && lstOrderLines.size() > 0)
      {
        List<SVMXC__RMA_Shipment_Order__c> allowedOrderHeader = clsAPLUtils.checkHeaderQualification(new SVMXC__RMA_Shipment_Order__c[]{orderHeader}, SVMXProcess.SVMXC__Module__c, NULL);
        if(allowedOrderHeader != NULL && allowedOrderHeader.size() > 0)
          orderHeader = allowedOrderHeader[0];
        else
          throw new SVMXException('Header qualification doesnot match');
      }
      // Do entry criteria validation for child entries
      if(SVMXProcess.SVMXC__Final_Exception_Process__c != null && lstOrderLines.size() > 0)
      {
        lstOrderLines = clsAPLUtils.checkChildQualification(lstOrderLines, SVMXProcess.SVMXC__Final_Exception_Process__c, NULL);
      }
      // Identify the location for order linesbased on delivery rules
      //populateLocationforDelivery(lstOrderLines, deliveryRule, orderHeader.SVMXC__Company__c);
    }
    system.debug('lstOrderLines'+ lstOrderLines.size() + lstOrderLines);
    
    
    // Populate locations for lines
    SVMXC.INTF_WebServicesDef.SVMXMap availableLocations = new SVMXC.INTF_WebServicesDef.SVMXMap();
    set<Id> setUniqueAvailableLocation = new set<Id>();
    availableLocations.key = 'AVAILABLELOCATIONS';
    list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForAvailableLocations = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
    SVMXC.INTF_WebServicesDef.SVMXMap defaultDeliveryLocation = new SVMXC.INTF_WebServicesDef.SVMXMap();
    setUniqueAvailableLocation.add(deliveryRule.SVMXC__Default_Location__c);
    defaultDeliveryLocation.key = deliveryRule.SVMXC__Default_Location__c;
    defaultDeliveryLocation.value = deliveryRule.SVMXC__Default_Location__r.Name;
    lstSVMXMapForAvailableLocations.add(defaultDeliveryLocation);
    SVMXC.INTF_WebServicesDef.SVMXMap mapForDefaultLocInfo = new SVMXC.INTF_WebServicesDef.SVMXMap();
    mapForDefaultLocInfo.key = 'DEFAULTLOCATION';
    mapForDefaultLocInfo.value = deliveryRule.SVMXC__Default_Location__c + '~|~' + deliveryRule.SVMXC__Default_Location__r.Name;
    lstSVMXMapForResponse.add(mapForDefaultLocInfo);
    
    list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> lstOrderLine = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
    if(lstOrderLines.size() > 0)
    {
        for(SVMXC__RMA_Shipment_Line__c line : lstOrderLines)
        {
            if(mapOrderLines.containskey(line.id))
            {
                SVMXC__RMA_Shipment_Line__c orderLines = mapOrderLines.get(line.id);
                if(mapLineLocations.get(orderLines.Id) != NULL)// Updated by rules
                {
                    orderLines.SVMXC__Ship_Location__c = mapLineLocations.get(orderLines.Id).key;
                    if(!setUniqueAvailableLocation.contains(orderLines.SVMXC__Ship_Location__c))
                {
                    setUniqueAvailableLocation.add(mapLineLocations.get(orderLines.Id).key);
                    lstSVMXMapForAvailableLocations.add(mapLineLocations.get(orderLines.Id));
                }
                }
                else // Set default location, if rules doesnot match
                orderLines.SVMXC__Ship_Location__c = deliveryRule.SVMXC__Default_Location__c;

                SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
                orderLine.orderLineRecord = orderLines;
                lstOrderLine.add(orderLine);
            }
        }
    }
    aplOrder.orderLines = lstOrderLine;
    aplOrder.orderHdrRecord = orderHeader;
    if(lstSVMXMapForAvailableLocations.size() > 0)
    {
      availableLocations.valueMap = lstSVMXMapForAvailableLocations;
      lstSVMXMapForResponse.add(availableLocations);
    }
    //Make Document Atttributes 
    if(lstDocumentAttribute.size() > 0)
    {
      SVMXC.INTF_WebServicesDef.SVMXMap mapForDocAttr = new SVMXC.INTF_WebServicesDef.SVMXMap();
      mapForDocAttr.key = 'DOCUMENTATTRIBUTE';
      list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForDocAttr = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
      for(Integer i = 0;i<lstDocumentAttribute.size();i++)
      {
        if(mapAPINameLablePO.containskey(lstDocumentAttribute[i].SVMXC__Field_Name__c))
        {
          SVMXC.INTF_WebServicesDef.SVMXMap temp = new SVMXC.INTF_WebServicesDef.SVMXMap();
          temp.key = mapAPINameLablePO.get(lstDocumentAttribute[i].SVMXC__Field_Name__c);
          temp.value = string.valueof(orderHeader.get(lstDocumentAttribute[i].SVMXC__Field_Name__c));
          lstSVMXMapForDocAttr.add(temp);
        }
      }
      mapForDocAttr.valueMap = lstSVMXMapForDocAttr;
      lstSVMXMapForResponse.add(mapForDocAttr);
    }
    //Make Column info for Order line Table...
    SVMXC.INTF_WebServicesDef.SVMXMap mapForColumnInfo = new SVMXC.INTF_WebServicesDef.SVMXMap();
    mapForColumnInfo.key = 'COLUMNINFO';
    mapForColumnInfo.value = clsAPLOrderUtils.MakeColumn(lstConfigData,strProcessType);
    lstSVMXMapForResponse.add(mapForColumnInfo);
    
    response.valueMap = lstSVMXMapForResponse;
    response.success = true;
    response.aplOrder = aplOrder;
    
    String strLogger = '';
    strLogger += system.now() + ': Usage Details: Before processing settings\n\tHeap Size     : ' + Limits.getHeapSize() + ' / ' + Limits.getLimitHeapSize() + '\n\tCPU Time        : ' + Limits.getCpuTime() + ' / ' + Limits.getLimitCpuTime() + '\n';
    response.message = strLogger;
        
    system.debug('response'+response);
    return response;
  }
  
    public map<Id, SVMXC.INTF_WebServicesDef.SVMXMap> populateLocationforDelivery(List<SVMXC__RMA_Shipment_Line__c> orderLines, SVMXC__ServiceMax_Processes__c deliveryRule, Id accountId)
    {
        map<Id, SVMXC.INTF_WebServicesDef.SVMXMap> response = new map<Id, SVMXC.INTF_WebServicesDef.SVMXMap>();
        String strAccountFldsQry = ''; 
        Set<String> setAccFlds = new Set<String>();
        String strProdFldsQry = ''; 
        Set<String> setPodFlds = new Set<String>();
        map<String, sObject> maprecords = new map<String, sObject>();
        map<Id, SVMXC__ServiceMax_Processes__c> mapRules = new map<Id, SVMXC__ServiceMax_Processes__c>();
        map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapRulesExpressions = new map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
        map<Id, Id> mapLineLocation = new map<Id, Id>();
        try
        {
            List<String> queryFields = new List<String>{'SVMXC__Select__c', 'SVMXC__Location__c', 'SVMXC__Location__r.Name', 'SVMXC__Sequence__c', 'SVMXC__Active__c', 'SVMXC__APL_Route_Rule_Type__c' , 'SVMXC__Name__c', 'SVMXC__Description__c', 'SVMXC__Advance_Expression__c', 'SVMXC__IsStandard__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            mapRules.putAll([select SVMXC__Select__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Sequence__c, SVMXC__Active__c, SVMXC__APL_Route_Rule_Type__c , SVMXC__Name__C, SVMXC__Description__c, SVMXC__Advance_Expression__c, SVMXC__IsStandard__c from  SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='SVMX Rule' And SVMXC__Module__c =: deliveryRule.Id ORDER BY SVMXC__Sequence__c ]);
            
            queryFields = new List<String> {'SVMXC__Display_Type__c', 'SVMXC__Location__c', 'SVMXC__Location__r.Name', 'SVMXC__Dispatch_Process__c', 'SVMXC__Sequence__c', 'SVMXC__Select__c', 'SVMXC__RecordType_Name__c', 'SVMXC__Profile__c', 'SVMXC__Operator__c', 'SVMXC__Operand__c', 'SVMXC__Object_Name__c',  'SVMXC__Field_Name__c',  'SVMXC__Expression_Type__c', 'SVMXC__Expression_Rule__c', 'SVMXC__Description__c', 'SVMXC__Active__c', 'RecordTypeId', 'SVMXC__Object_Name2__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            List<SVMXC__ServiceMax_Config_Data__c> lstExpressions = [Select SVMXC__Display_Type__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Dispatch_Process__c, SVMXC__Sequence__c, SVMXC__Select__c, SVMXC__RecordType_Name__c, SVMXC__Profile__c, SVMXC__Operator__c, SVMXC__Operand__c, SVMXC__Object_Name__c,  SVMXC__Field_Name__c,  SVMXC__Expression_Type__c, SVMXC__Expression_Rule__c, SVMXC__Description__c, SVMXC__Active__c, RecordTypeId, SVMXC__Object_Name2__c From SVMXC__ServiceMax_Config_Data__c  where SVMXC__Expression_Rule__c IN: mapRules.keySet()]; //SDL-SVMX-READ-FLS-ENFORCED
        
        set<Id> availableRule = new set<Id>();
        
        for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
        {
            availableRule.add(oExpression.SVMXC__Expression_Rule__c);
        }
        
        String foundDefaultLocationID = null;
        for(Id ruleID: mapRules.keySet())
        {
            if(!availableRule.contains(ruleID))
                foundDefaultLocationID = ruleID;
        }
        
        if(foundDefaultLocationID == null)
        {
            for(SVMXC__ServiceMax_Config_Data__c oExpression: lstExpressions)
            {
              List<SVMXC__ServiceMax_Config_Data__c> lstExp = new List<SVMXC__ServiceMax_Config_Data__c>();
              if(mapRulesExpressions.get(oExpression.SVMXC__Expression_Rule__c) != NULL)
              lstExp.addAll(mapRulesExpressions.get(oExpression.SVMXC__Expression_Rule__c));
              lstExp.add(oExpression);
              mapRulesExpressions.put(oExpression.SVMXC__Expression_Rule__c, lstExp);
          
              if(oExpression.SVMXC__Object_Name2__c == 'Account')
              {
              if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setAccFlds.contains(oExpression.SVMXC__Field_Name__c))
              { 
              setAccFlds.add(oExpression.SVMXC__Field_Name__c);
              if(strAccountFldsQry.length() > 0)
              strAccountFldsQry += ',';
              strAccountFldsQry += oExpression.SVMXC__Field_Name__c;
              }
              }
              else if(oExpression.SVMXC__Object_Name2__c == 'Product2')
              {
                if(oExpression.SVMXC__Field_Name__c != null && oExpression.SVMXC__Field_Name__c.length() > 0 && !setPodFlds.contains(oExpression.SVMXC__Field_Name__c))
                { 
                  setPodFlds.add(oExpression.SVMXC__Field_Name__c);
                  if(strProdFldsQry.length() > 0)
                  strProdFldsQry += ',';
                  strProdFldsQry += oExpression.SVMXC__Field_Name__c;
                }
              }
            }
            Account objAccount;
            try
            {
                queryFields = strAccountFldsQry.split(',');
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Account', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                objAccount = database.query('Select ' + strAccountFldsQry + ' From Account' + ' where Id =: accountId');
            }
            catch(exception ex)
            {
            
            }
            
            set<Id> setProductIds = new set<Id>();
            list<Product2> lstLineProduct = new list<Product2>();
            map<Id, Product2> mapLineProduct = new map<Id, Product2>();
            for(SVMXC__RMA_Shipment_Line__c orderLine: orderLines)
            {
                if(orderLine.SVMXC__Product__c != NULL)
                    setProductIds.add(orderLine.SVMXC__Product__c);
            }
            
            try
            {
                queryFields = strProdFldsQry.split(',');
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Product2', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                lstLineProduct = database.query('Select ' + strProdFldsQry + ' From Product2' + ' where Id IN : setProductIds');
                for(Product2 prod: lstLineProduct)
                {
                    mapLineProduct.put(prod.Id, prod);
                }
            }
            catch(exception ex)
            {
            
            }
            for(SVMXC__RMA_Shipment_Line__c orderLine: orderLines)
            {
              try
              {
                if(orderLine.SVMXC__Product__c != NULL)
                {
                    Id productId = orderLine.SVMXC__Product__c;
                    maprecords.put('Product2', mapLineProduct.get(productId));
                    maprecords.put('Account', objAccount);
                    system.debug('TEST LOG: ' + mapRulesExpressions + mapRules);
                    system.debug('TEST LOG: ' + maprecords);
                    map<string, string> mapResult = clsAPLUtils.SVMX_ExpressionParsing(maprecords, mapRulesExpressions, mapRules);
                    system.debug('TEST LOG2: ' + mapResult);
                    for(String expId: mapResult.keySet())
                    {
                        if(orderLine.SVMXC__Ship_Location__c != mapRules.get(expId).SVMXC__Location__c)
                        {
                        SVMXC.INTF_WebServicesDef.SVMXMap temp = new SVMXC.INTF_WebServicesDef.SVMXMap();
                        temp.key = mapRules.get(expId).SVMXC__Location__c;
                        temp.value = mapRules.get(expId).SVMXC__Location__r.Name;
                        response.put(orderLine.Id, temp);
                        }
                    }
                }
              }
              catch(exception ex)
              {
          
              }
            }
        }
        else// Setup location from blank expression rule
        {
            for(SVMXC__RMA_Shipment_Line__c orderLine: orderLines)
            {
                if(orderLine.SVMXC__Ship_Location__c != mapRules.get(foundDefaultLocationID).SVMXC__Location__c)
                {
                    SVMXC.INTF_WebServicesDef.SVMXMap temp = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    temp.key = mapRules.get(foundDefaultLocationID).SVMXC__Location__c;
                    temp.value = mapRules.get(foundDefaultLocationID).SVMXC__Location__r.Name;
                    response.put(orderLine.Id, temp);
                }
            }
        }
      
        }
        catch(exception ex)
        {
          //throw new SVMXException('Failed while identifying location for the line.' + ex.getMessage());
        }
        system.debug('response: ' + response);
        return response;
    }
    
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse performDeliveryOnReceipt(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request)
    {
        APL_RMAUtils rmaUtilsCls = new APL_RMAUtils(); 
        SVMXC__RMA_Shipment_Order__c orderHeader = new SVMXC__RMA_Shipment_Order__c();
        list<SVMXC__RMA_Shipment_Line__c> lstOrderLines = new list<SVMXC__RMA_Shipment_Line__c>();
        map<Id, SVMXC.INTF_WebServicesDef.SVMXMap> mapLineLocations = new map<Id, SVMXC.INTF_WebServicesDef.SVMXMap>();
        map<Id,SVMXC__RMA_Shipment_Line__c> mapOrderLines = new map<Id,SVMXC__RMA_Shipment_Line__c>();
        String strRecordId;
        set<Id> setLineIds = new set<Id>();
                        
        for(SVMXC.INTF_WebServicesDef.SVMXMap req: request.valueMap)
        {
            if(req.key.toUppercase() == 'REQUESTEDLINEIDS')
            {
                strRecordId = req.value;
            }
            if(req.key.toUppercase() == 'REQUESTEDLINEIDS')
            {
                for(SVMXC.INTF_WebServicesDef.SVMXMap addValues: req.valueMap)
                {
                    if(addValues.key != NULL)
                    {
                        setLineIds.add(addValues.key);
                    }
                }
            }
        }
        
        String StrOrderLineFields = ' SystemModstamp, SVMXC__Master_Order_Line__c, SVMXC__Work_Order_Created__c, SVMXC__Warehouse__c, SVMXC__Use_Price_From_Pricebook__c, SVMXC__Total_Line_Price2__c, SVMXC__Shipped__c, SVMXC__Shipped_On__c, SVMXC__Shipped_By__c, SVMXC__Ship_Location__c, SVMXC__Service_Order__c, SVMXC__Service_Order_Line__c, SVMXC__Service_Engineer__c, SVMXC__Serial_Number__c, SVMXC__Serial_Number_List__c, SVMXC__Select__c, SVMXC__Sales_Order_Number__c, SVMXC__Route_Stop__c, SVMXC__Route_Card__c, SVMXC__Returned_Condition__c, SVMXC__Reconciliation_Action__c, SVMXC__Received__c, SVMXC__Received_On__c, SVMXC__Received_By__c, SVMXC__RMA_Shipment_Order__c, SVMXC__Product__c, SVMXC__Posted_To_Inventory__c, SVMXC__Picked__c, SVMXC__Picked_Qty__c, SVMXC__Picked_On__c, SVMXC__Picked_By__c, SVMXC__Parts_Request_Line__c, SVMXC__Packing_Instructions__c, SVMXC__Line_Type__c, SVMXC__Line_Status__c, SVMXC__Line_Price2__c, SVMXC__Expected_Ship_Date__c, SVMXC__Expected_Receipt_Date__c, SVMXC__Expected_Quantity2__c, SVMXC__Expected_Condition__c, SVMXC__Disposition__c, SVMXC__Disposition_Instructions__c, SVMXC__Discount_Percentage__c, SVMXC__Delivery_Location__c, SVMXC__Delivered__c, SVMXC__Delivered_On__c, SVMXC__Delivered_By__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Case_Line__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Actual_Ship_Date__c, SVMXC__Actual_Receipt_Date__c, SVMXC__Actual_Quantity2__c, RecordTypeId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById, SVMXC__Product__r.Name, SVMXC__Product__r.ProductCode ';
        orderHeader = [Select SVMXC__Warehouse__c, SVMXC__Fulfillment_Type__c, SVMXC__Master_Order__c, SVMXC__Tracking_Number__c, SVMXC__Total_Price2__c, SVMXC__Source_Zip__c, SVMXC__Source_Street__c, SVMXC__Source_State__c, SVMXC__Source_Location__c, SVMXC__Source_Location__r.Name, SVMXC__Source_Country__c, SVMXC__Source_City__c, SVMXC__Shipping_Terms__c, SVMXC__Shipping_Receiving_Notes__c, SVMXC__Shipping_Courier__c, SVMXC__Shipment_Reference__c, SVMXC__Shipment_Age_Bucket__c, SVMXC__Service_Order__c, SVMXC__Service_Engineer__c, SVMXC__Sales_Order_Number__c, SVMXC__SESSION_ID__c, SVMXC__Receiving_Courier__c, SVMXC__RMA_Age_Bucket__c, SVMXC__Priority__c, SVMXC__Parts_Request__c, SVMXC__Partner_Contact__c, SVMXC__Partner_Account__c, SVMXC__Order_Type__c, SVMXC__Order_Status__c, SVMXC__IsPartner__c, SVMXC__IsPartnerRecord__c, SVMXC__Expected_Receive_Date__c, SVMXC__Expected_Delivery_Date__c, SVMXC__EndpointURL__c, SVMXC__Destination_Zip__c, SVMXC__Destination_Street__c, SVMXC__Destination_State__c, SVMXC__Destination_Location__c,SVMXC__Destination_Location__r.Name, SVMXC__Destination_Country__c, SVMXC__Destination_City__c, SVMXC__Delivery_Option__c, SVMXC__Contact__c, SVMXC__Company__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Case__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Billing_Type__c, SVMXC__Bill_To__c, SVMXC__Address_Type__c, SVMXC__On_Hold__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__RMA_Shipment_Order__c where id =: strRecordId and RecordType.Name = 'RMA' and SVMXC__On_Hold__c = false];
        String query = 'Select ' +StrOrderLineFields+ '  From SVMXC__RMA_Shipment_Line__c  where Id IN : setLineIds';
        system.debug('query'+query);
        if(setLineIds.size() > 0)
            lstOrderLines = Database.query(query);   
        system.debug('lstOrderLines'+lstOrderLines.size()+lstOrderLines);
        
        if(lstOrderLines.size() > 0)
        {
            for(SVMXC__RMA_Shipment_Line__c PO : lstOrderLines)
            {
                mapOrderLines.put(PO.id,PO);
            }
        }
        
        // Get delivery rules
        SVMXC__ServiceMax_Processes__c deliveryRule;
        Id defaultDeliveryRuleId;
        String defaultDeliveryRuleName;
        try
        {
            deliveryRule = [Select SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Delivery Rule' And SVMXC__Location__c = :orderHeader.SVMXC__Destination_Location__c]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            defaultDeliveryRuleId = deliveryRule.SVMXC__Default_Location__c;
            defaultDeliveryRuleName = deliveryRule.SVMXC__Default_Location__r.Name;
            mapLineLocations = rmaUtilsCls.populateLocationforDelivery(lstOrderLines, deliveryRule, orderHeader.SVMXC__Company__c);
            system.debug('mapLineLocations' + mapLineLocations);
        }
        catch(exception ex)
        {
            try
            {
                SVMXC__Site__c deliveryLoc = [Select Id, Name from SVMXC__Site__c where SVMXC__IsDefault_Delivery__c = true and SVMXC__Parent__c = : orderHeader.SVMXC__Destination_Location__c limit 1];
                defaultDeliveryRuleId = deliveryLoc.Id;
                defaultDeliveryRuleName = deliveryLoc.Name;
            }
            catch(exception ex2)
            { 
              throw new SVMXException(system.label.APL003_TAG027);
            }
        }
        
        for(SVMXC__RMA_Shipment_Line__c orderLines : lstOrderLines)
        {
            SVMXC__RMA_Shipment_Line__c orderLine = mapOrderLines.get(orderLines.Id);
            if(mapLineLocations.get(orderLine.Id) != NULL)// Updated by rules
            {
                orderLine.SVMXC__Delivery_Location__c = mapLineLocations.get(orderLine.Id).key;
            }
            else // Set default location, if rules doesnot match
                orderLine.SVMXC__Delivery_Location__c = defaultDeliveryRuleId;
            mapOrderLines.put(orderLine.Id, orderLine);
        }
        return NULL;
    }
}