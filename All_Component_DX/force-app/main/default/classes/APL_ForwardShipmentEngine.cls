global with sharing class APL_ForwardShipmentEngine implements Schedulable
{
    global boolean isTestClass = false;
    global void execute(SchedulableContext scFrForwardShipmentEngine)
    {
        Map<String,SVMXC__ServiceMax_Config_Data__c> mapAllFwdShipmentProcs = new Map<String,SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstAllDeposFrFwdShpProc = new List<SVMXC__ServiceMax_Config_Data__c>();
        List<SVMXC__ServiceMax_Config_Data__c> lstAllScheduleFrFwdShpProc = new List<SVMXC__ServiceMax_Config_Data__c>();
        Map<String,String> mapLocProcData = null;
        integer intCount = 0;
        String strLocation = null;
        try
        {
            //Actual schedular           
            CronTrigger ctFrForwardShipmentEngine = null;
            String strCurrFireTime;
            Datetime dtCurrFire;
            if(isTestClass)
            {  
                //This condition is only to make test class success full.
                dtCurrFire = Datetime.now();//ctFrForwardShipmentEngine.NextFireTime.addHours(-1);
                strCurrFireTime = '4:00 PM';//dtCurrFire.format('h:mm a');
            }else
            {
                ctFrForwardShipmentEngine = [SELECT Id, CronExpression, NextFireTime From CronTrigger WHERE Id = :scFrForwardShipmentEngine.getTriggerId()]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA               
                dtCurrFire = ctFrForwardShipmentEngine.NextFireTime.addHours(-1);
                strCurrFireTime = dtCurrFire.formatGmt('h:mm a');
            }
            String strDay = dtCurrFire.formatGmt('EEEE');
            //get all the process data
            //get the config data for the considerable schedules for the above processes
            
            lstAllScheduleFrFwdShpProc = [Select id, SVMXC__Run_At__c, SVMXC__Schedule_Days__c, SVMXC__Dispatch_Process__c,SVMXC__Dispatch_Process__r.SVMXC__Location__c, SVMXC__Dispatch_Process__r.SVMXC__Module__c,SVMXC__Dispatch_Process__r.SVMXC__Node_Parent__c, SVMXC__Dispatch_Process__r.SVMXC__Start_Date__c, SVMXC__Dispatch_Process__r.SVMXC__End_Date__c, SVMXC__Dispatch_Process__r.SVMXC__Email_On_Success__c, SVMXC__Dispatch_Process__r.SVMXC__Email_On_Error__c, SVMXC__Dispatch_Process__r.SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Config_Data__c where RecordType.Name = 'Schedule' and SVMXC__Run_At__c = :strCurrFireTime and SVMXC__Schedule_Days__c includes (:strDay)]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
           
            //Get all the process that need to run now
            for(SVMXC__ServiceMax_Config_Data__c currentSch : lstAllScheduleFrFwdShpProc)
            {
                strLocation = currentSch.SVMXC__Dispatch_Process__r.SVMXC__Location__c;
                if(strLocation != null)
                {
                  if(intCount > 9) // now schedule for the remaining locations
                  {
                    //send the error email from the setting that there are more than 10 locations that are configured
                    break;
                  }              
                  processForwardShipmentFor(strLocation,currentSch.id);        
                  intCount++;
                }          
            }
          }catch(Exception exInShipmentEngine)
          {  
            
          }
    }
    
    //here depotid is nothing but location id
    @Future  
    public static void processForwardShipmentFor(String depotID, String forwardShipmentProcessId)
    {
      String strLogInfo = '';
      List<SVMXC__ServiceMax_Config_Data__c> listForwardShipmentProcess = null;
      List<SVMXC__Route_Stop__c> lstStopsForLocationType = null;      
      Map<Id,SVMXC__RMA_Shipment_Order__c> mapRMAOrders = new Map<Id,SVMXC__RMA_Shipment_Order__c>();
      Map<Id,SVMXC__RMA_Shipment_Line__c> mapRMALineOrders = new Map<Id,SVMXC__RMA_Shipment_Line__c>();
      Map<String,String> mapRMALineNxtStop = new Map<String,String>();
      Boolean isException = false;
      String strEmailId = null;
      Set<String> setUniquePro = new Set<String>();
      Set<String> setUniqueLoc = new Set<String>();
      Map<String,SObject> mapReturnShipmentOrders = new Map<String,SObject>();      
      List<SObject> lstNewShipmentOrders = new List<SObject>();
      Map <String, Schema.SObjectType> schemaMap = new Map <String, Schema.SObjectType>();
      Savepoint sp;
      sp = Database.setSavepoint();        
      try
      {                     
            system.debug('Depot ID: ' + depotID + ' and Forward Shipment Process ID: ' + forwardShipmentProcessId);
            //Neeraj: I removed the field SVMXC__Capture_Log__c from the query, bcoz it has been deleted. 
            listForwardShipmentProcess = [Select id, SVMXC__Run_At__c, SVMXC__Schedule_Days__c, SVMXC__Dispatch_Process__c, SVMXC__Dispatch_Process__r.SVMXC__Name__c ,SVMXC__Dispatch_Process__r.SVMXC__Module__c,SVMXC__Dispatch_Process__r.SVMXC__Node_Parent__c,SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c, SVMXC__Dispatch_Process__r.SVMXC__Start_Date__c, SVMXC__Dispatch_Process__r.SVMXC__End_Date__c, SVMXC__Dispatch_Process__r.SVMXC__Email_On_Success__c, SVMXC__Dispatch_Process__r.SVMXC__Email_On_Error__c,  SVMXC__Dispatch_Process__r.SVMXC__Advance_Expression__c from SVMXC__ServiceMax_Config_Data__c where id=:forwardShipmentProcessId]; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            system.debug('List of Processes: ' + listForwardShipmentProcess + ' and size is: ' + listForwardShipmentProcess.size());
            
            //Schema information
            
            Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
              for(Schema.SObjectType s : gd.values())
              {
                  schemaMap.put(s.getDescribe().getName(),s);
              }
            //get the information from the process related to the expressions and the mapping and other info
            String idForHeaderMapping = listForwardShipmentProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Module__c;
            String idForChildMapping = listForwardShipmentProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Node_Parent__c;
            String strWhrClause = listForwardShipmentProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Parent_Object_Criteria__c;
            System.debug('Whrere Clause for the current process : ' + strWhrClause);
            strEmailId = listForwardShipmentProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Email_On_Success__c;
            //Query the Route Stops entries where depot is the depotID(Location id) for inbound
            List<String> queryFields = new List<String> {'Id', 'SVMXC__Record_Card__c', 'SVMXC__Record_Card__r.SVMXC__RMA__c', 'SVMXC__Record_Card__r.SVMXC__RMA_Line__c', 'SVMXC__Record_Card__r.SVMXC__Current_Stop__c', 'SVMXC__Record_Card__r.SVMXC__Route_Type__c', 'SVMXC__Record_Card__r.SVMXC__Next_Stop__c', 'SVMXC__Next_Stop__c', 'SVMXC__Stop_Location__c', 'SVMXC__Record_Card__r.SVMXC__RMA__r.SVMXC__Source_Location__c', 'SVMXC__Record_Card__r.SVMXC__Current_Stop__r.Name'};
            if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Route_Stop__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            lstStopsForLocationType = [Select Id, SVMXC__Record_Card__c, SVMXC__Record_Card__r.SVMXC__RMA__c, SVMXC__Record_Card__r.SVMXC__RMA_Line__c, SVMXC__Record_Card__r.SVMXC__Current_Stop__c, SVMXC__Record_Card__r.SVMXC__Route_Type__c, SVMXC__Record_Card__r.SVMXC__Next_Stop__c,SVMXC__Next_Stop__c, SVMXC__Stop_Location__c, SVMXC__Record_Card__r.SVMXC__RMA__r.SVMXC__Source_Location__c,SVMXC__Record_Card__r.SVMXC__Current_Stop__r.Name from SVMXC__Route_Stop__c where SVMXC__Delivered__c = true and SVMXC__Shipment_Initiated__c = false and SVMXC__Stop_Location__c =: depotID and SVMXC__Record_Card__r.SVMXC__Current_Stop__c =:depotID and SVMXC__Record_Card__r.SVMXC__RMA__r.RecordType.Name = 'RMA' and SVMXC__Record_Card__r.SVMXC__RMA_Line__r.RecordType.Name = 'RMA' and SVMXC__Record_Card__r.SVMXC__Status__c != 'Close']; //SDL-SVMX-READ-FLS-ENFORCED
            Map<String,set<String>> allRMAIdAndRotInfos = new Map<String,set<String>>();
            List<String> allRMALineIds = new List<String>();
            List<String> allNxtStops = new List<String>();
            Map<String,String> mapRMALineCurrStop = new Map<String,String>();
            Map<String,String> mapRMALineNxtLoc = new Map<String,String>();
            if(lstStopsForLocationType == null || lstStopsForLocationType.size() == 0 )
            {
                return;
            }
            for(SVMXC__Route_Stop__c currStop : lstStopsForLocationType)
            {
                              
                  //if the next stop is null and type is inbound then skip else to location will be the customer address
                  if(currStop.SVMXC__Record_Card__r.SVMXC__Route_Type__c == 'Inbound' && (currStop.SVMXC__Next_Stop__c == null ))
                  {
                    continue;
                  }else if(currStop.SVMXC__Record_Card__r.SVMXC__Route_Type__c == 'Outbound' && (currStop.SVMXC__Next_Stop__c == null )) 
                  {
                    if(!allRMAIdAndRotInfos.containsKey(currStop.SVMXC__Record_Card__r.SVMXC__RMA__c))
                    {
                        allRMAIdAndRotInfos.put(currStop.SVMXC__Record_Card__r.SVMXC__RMA__c,new set<String>());                        
                    }
                    allRMAIdAndRotInfos.get(currStop.SVMXC__Record_Card__r.SVMXC__RMA__c).add(currStop.SVMXC__Record_Card__r.SVMXC__RMA__r.SVMXC__Source_Location__c);
                    allRMALineIds.add(currStop.SVMXC__Record_Card__r.SVMXC__RMA_Line__c); 
                    mapRMALineNxtLoc.put(currStop.SVMXC__Record_Card__r.SVMXC__RMA_Line__c, currStop.SVMXC__Record_Card__r.SVMXC__RMA__r.SVMXC__Source_Location__c);
                    mapRMALineCurrStop.put(currStop.SVMXC__Record_Card__r.SVMXC__RMA_Line__c,currStop.id);
                    //currStop.SVMXC__Shipment_Initiated__c = true;
                  continue;
                  }
                  if(!allRMAIdAndRotInfos.containsKey(currStop.SVMXC__Record_Card__r.SVMXC__RMA__c))
                  {
                    allRMAIdAndRotInfos.put(currStop.SVMXC__Record_Card__r.SVMXC__RMA__c,new set<String>());                    
                  }
                  mapRMALineCurrStop.put(currStop.SVMXC__Record_Card__r.SVMXC__RMA_Line__c,currStop.id);
                  mapRMALineNxtLoc.put(currStop.SVMXC__Record_Card__r.SVMXC__RMA_Line__c, currStop.SVMXC__Next_Stop__c);
                  //currStop.SVMXC__Shipment_Initiated__c = true;
                  allRMAIdAndRotInfos.get(currStop.SVMXC__Record_Card__r.SVMXC__RMA__c).add(currStop.SVMXC__Next_Stop__c);
                  allRMALineIds.add(currStop.SVMXC__Record_Card__r.SVMXC__RMA_Line__c);        
                  allNxtStops.add(currStop.SVMXC__Next_Stop__c);
            }
            //now get all the RMA and RMA lines configured to the route cards and matching the process criteria
            mapRMAOrders.putAll([Select Id,SVMXC__Master_Order__c,SVMXC__Fulfillment_Type__c from SVMXC__RMA_Shipment_Order__c where id in :allRMAIdAndRotInfos.keySet() and SVMXC__On_Hold__c = false]);
            // get the where clause and apply on the Shipment line
            strWhrClause = strWhrClause != null && strWhrClause.length() > 0 ? ' and ' + strWhrClause : '';
            mapRMALineOrders.putAll((List<SVMXC__RMA_Shipment_Line__c>)database.query('Select Id,SVMXC__RMA_Shipment_Order__c,SVMXC__Product__c,SVMXC__Route_Card__c,SVMXC__Master_Order_Line__c from SVMXC__RMA_Shipment_Line__c where id in :allRMALineIds' + strWhrClause));
            //Check if there are any RMA line records if not don't process the next steps
            if(mapRMALineOrders.keySet().size() == 0)
            {
              return;
            }        
            SVMXC__RMA_Shipment_Order__c objShipment = null;      
            //now get all the Next route info for the current stop
            Map<Id,SVMXC__Route_Stop__c> mapNextStopsForCurrentStop = new Map<Id,SVMXC__Route_Stop__c>();
            mapNextStopsForCurrentStop.putAll([Select id, SVMXC__Record_Card__c, SVMXC__Record_Card__r.SVMXC__RMA__c, SVMXC__Record_Card__r.SVMXC__RMA_Line__c, SVMXC__Record_Card__r.SVMXC__Current_Stop__c, SVMXC__Record_Card__r.SVMXC__Route_Type__c, SVMXC__Record_Card__r.SVMXC__Next_Stop__c,SVMXC__Next_Stop__c,SVMXC__Stop_Location__c from SVMXC__Route_Stop__c 
            where SVMXC__Delivered__c = false and SVMXC__Shipment_Initiated__c = false and SVMXC__Stop_Location__c IN: allNxtStops 
            and SVMXC__Record_Card__r.SVMXC__RMA_Line__c In:allRMALineIds]);        
            
            //Now get the record shipment Id
            RecordType objShpRecTpe = [Select Id from RecordType where Name = 'Shipment' and SobjectType = 'SVMXC__RMA_Shipment_Order__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            RecordType objShpRecTpeForLine = [Select Id from RecordType where Name = 'Shipment' and SobjectType = 'SVMXC__RMA_Shipment_Line__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            
            
            /*for(ID idNxtStop : mapNextStopsForCurrentStop.keySet())
            {
              mapRMALineNxtStop.put(mapNextStopsForCurrentStop.get(idNxtStop).SVMXC__Record_Card__r.SVMXC__RMA_Line__c,idNxtStop);
              if(!mapRMALineNxtLoc.containsKey(mapNextStopsForCurrentStop.get(idNxtStop).SVMXC__Record_Card__r.SVMXC__RMA_Line__c))
              mapRMALineNxtLoc.put(mapNextStopsForCurrentStop.get(idNxtStop).SVMXC__Record_Card__r.SVMXC__RMA_Line__c,mapNextStopsForCurrentStop.get(idNxtStop).SVMXC__Stop_Location__c);
            }*/
                        
            for(Id objCurrentRMA : mapRMAOrders.keySet())
            {
              objShipment = new SVMXC__RMA_Shipment_Order__c();
              mapReturnShipmentOrders.put(objCurrentRMA,objShipment);        
            }
            
             //now apply mapping
            INTF_ApplyMapping objApplyRMAMapping = new INTF_ApplyMapping();
            if(idForHeaderMapping != null)
            {
              Map<String,SObject> mapReturnShipmentOrdersTemp = new Map<String,SObject>();
              mapReturnShipmentOrdersTemp = objApplyRMAMapping.getApplyMappingCore(idForHeaderMapping, mapReturnShipmentOrders, false, schemaMap);
              if(mapReturnShipmentOrdersTemp != null && mapReturnShipmentOrdersTemp.keySet() != null && mapReturnShipmentOrdersTemp.keySet().size() > 0)
              {
                mapReturnShipmentOrders = mapReturnShipmentOrdersTemp;
              }
            }
            
            //Looping through all the RMA lines and creating shipment lines
            //From the set of lines that are filtered from the where clause, Get the set of all RMA for the consideration of creation of shipment records
            Map<String,SObject> mapReturnShipmentOrderLines = new Map<String,SObject>();
            Map<String,String> mapRMALineHeaderInfo = new Map<String,String>();
            Set<String> setALLRMAToConsider = new Set<String>();
            SVMXC__RMA_Shipment_Line__c objShipmentLine = null;
            for(Id objCurrentRMALine : mapRMALineOrders.keySet())
            {
              objShipmentLine = new SVMXC__RMA_Shipment_Line__c();
              mapReturnShipmentOrderLines.put(objCurrentRMALine,objShipmentLine); 
              mapRMALineHeaderInfo.put(objCurrentRMALine,mapRMALineOrders.get(objCurrentRMALine).SVMXC__RMA_Shipment_Order__c);
              setALLRMAToConsider.add(mapRMALineOrders.get(objCurrentRMALine).SVMXC__RMA_Shipment_Order__c);            
            }
            
            //now apply the target updates for header
            String strNextStop = null;
            String strMasterRMA = null;
            for(Id objCurrent : mapReturnShipmentOrders.keySet())
            {
                if(!setALLRMAToConsider.contains(objCurrent))
                {
                    // There is no RMA line for the RMA so we will not consider for Shipment creation
                    continue;
                }
                strMasterRMA = mapRMAOrders.get(objCurrent).SVMXC__Master_Order__c == null && mapRMAOrders.get(objCurrent).SVMXC__Fulfillment_Type__c != null && (mapRMAOrders.get(objCurrent).SVMXC__Fulfillment_Type__c == 'Repair' || mapRMAOrders.get(objCurrent).SVMXC__Fulfillment_Type__c == 'Sales')  ? objCurrent : mapRMAOrders.get(objCurrent).SVMXC__Master_Order__c;
                for(String strNxtLocation : allRMAIdAndRotInfos.get(objCurrent))
                {
                    mapReturnShipmentOrders.get(objCurrent).put('SVMXC__Destination_Location__c',strNxtLocation);
                    mapReturnShipmentOrders.get(objCurrent).put('SVMXC__Source_Location__c',depotID);
                    mapReturnShipmentOrders.get(objCurrent).put('RecordTypeId',objShpRecTpe.id);
                    mapReturnShipmentOrders.get(objCurrent).put('SVMXC__Shipment_Reference__c',objCurrent);
                    mapReturnShipmentOrders.get(objCurrent).put('SVMXC__Master_Order__c',strMasterRMA);
                    lstNewShipmentOrders.add(mapReturnShipmentOrders.get(objCurrent).clone(false,true));
                }                           
            }
            
            /* SECSCAN-822 */ 
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstNewShipmentOrders, COMM_SecurityUtils.Access.Createable ) ) {
                insert lstNewShipmentOrders; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
            
            //map to store the Master RMA and there Shipment order based on location
            Map<String,Map<String,String>> mapRMANewLocNewShpId = new Map<String,Map<String,String>>();
            for(SObject objCurrShpOrder : lstNewShipmentOrders)
            {
                if(!mapRMANewLocNewShpId.containsKey(String.valueOf(objCurrShpOrder.get('SVMXC__Shipment_Reference__c'))))
                {
                    mapRMANewLocNewShpId.put(String.valueOf(objCurrShpOrder.get('SVMXC__Shipment_Reference__c')),new map<String,String>());
                }
                mapRMANewLocNewShpId.get(String.valueOf(objCurrShpOrder.get('SVMXC__Shipment_Reference__c'))).put(String.valueOf(objCurrShpOrder.get('SVMXC__Destination_Location__c')),objCurrShpOrder.id);                                
            }
            
            
            //now apply mapping
            //idForChildMapping = null;
            if(idForChildMapping != null)
            {
              Map<String,SObject> mapReturnShipmentLinesTemp = new Map<String,SObject>();
              try
              {
                mapReturnShipmentLinesTemp = objApplyRMAMapping.getApplyMappingCore(idForChildMapping, mapReturnShipmentOrderLines, false, schemaMap);
              }catch(Exception ex)
              {
                
              }
              if(mapReturnShipmentLinesTemp != null && mapReturnShipmentLinesTemp.keySet() != null && mapReturnShipmentLinesTemp.keySet().size() > 0)
              {
                mapReturnShipmentOrderLines = mapReturnShipmentLinesTemp;
              }
            }
            //now apply the target updates
            String strMasterRMALine = null;
            for(Id objCurrent : mapReturnShipmentOrderLines.keySet())
            {
                  strMasterRMALine = mapRMALineOrders.get(objCurrent).SVMXC__Master_Order_Line__c != null ? mapRMALineOrders.get(objCurrent).SVMXC__Master_Order_Line__c : objCurrent;              
                  setUniquePro.add(mapRMALineOrders.get(objCurrent).SVMXC__Product__c);
                  setUniqueLoc.add(mapRMALineNxtLoc.get(objCurrent));
                  System.debug('Currnet RMA Line: '+ objCurrent);
                  System.debug('Next Location: ' + mapRMALineNxtLoc.get(objCurrent));
                  System.debug('RMA Line Header Info: ' + mapRMALineHeaderInfo.get(objCurrent));                  
                  System.debug('New Location New Shipment Id: ' + mapRMANewLocNewShpId.get(mapRMALineHeaderInfo.get(objCurrent)));
                  System.debug('New Shipment Id: ' + mapRMANewLocNewShpId.get(mapRMALineHeaderInfo.get(objCurrent)).get(mapRMALineNxtLoc.get(objCurrent)));
                  mapReturnShipmentOrderLines.get(objCurrent).put('SVMXC__RMA_Shipment_Order__c',mapRMANewLocNewShpId.get(mapRMALineHeaderInfo.get(objCurrent)).get(mapRMALineNxtLoc.get(objCurrent))); 
                  mapReturnShipmentOrderLines.get(objCurrent).put('SVMXC__Expected_Quantity2__c',1);
                  mapReturnShipmentOrderLines.get(objCurrent).put('SVMXC__Product__c',mapRMALineOrders.get(objCurrent).SVMXC__Product__c);
                  mapReturnShipmentOrderLines.get(objCurrent).put('SVMXC__Route_Card__c',mapRMALineOrders.get(objCurrent).SVMXC__Route_Card__c);
                  mapReturnShipmentOrderLines.get(objCurrent).put('SVMXC__Master_Order_Line__c',strMasterRMALine);
                  mapReturnShipmentOrderLines.get(objCurrent).put('RecordTypeId',objShpRecTpeForLine.id);
                  mapReturnShipmentOrderLines.get(objCurrent).put('SVMXC__Route_Stop__c',mapRMALineCurrStop.get(objCurrent));                   
            }
            /*if(mapReturnShipmentOrderLines.size() > 2000)
            {
                //Batch the DML
                integer intCount = 0;
                List<SObject> lstBtchCollec = new List<SObject>();
                for(SObject objCurrLine : mapReturnShipmentOrderLines.values())
                {
                    lstBtchCollec.add(objCurrLine);                 
                    if(intCount > 1000)
                    {
                        insert lstBtchCollec;
                        lstBtchCollec = new List<SObject>();
                        intCount = 0;
                    }
                    intCount++;
                }
                insert lstBtchCollec;
            }else
            { */    
                insert mapReturnShipmentOrderLines.values();
            //}
            
            //here update the Route Stops as ShipmentInitiated to true only the RMA lines that are processed.
            for(SVMXC__Route_Stop__c currStop : lstStopsForLocationType)
            {
                if(mapRMALineOrders.containsKey(currStop.SVMXC__Record_Card__r.SVMXC__RMA_Line__c))
                {
                    currStop.SVMXC__Shipment_Initiated__c = true;
                }
            }
            
             /* SECSCAN-822 */ 
            if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstStopsForLocationType, COMM_SecurityUtils.Access.Updateable )){
                update lstStopsForLocationType; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            }
                  
            
          }
          catch(Exception exForFrwdShpEngine)
          {
            Database.rollback(sp);
            strLogInfo += getTAG009() + listForwardShipmentProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Name__c + ' \n ';
            strLogInfo += exForFrwdShpEngine.getMessage();
            isException = true;
            strEmailId = listForwardShipmentProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Email_On_Error__c;
            
          }
                
          //sending the log info
          if(!isException)
          {
            //Describe the Shipment Order and get the name field label and dispay
            /*SVMXC__RMA_Shipment_Order__c objOrder = new SVMXC__RMA_Shipment_Order__c();
            Schema.DescribeSObjectResult descSHPObject= objOrder.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> allFields = descSHPObject.fields.getMap();
            for(String strCurrFld : allFields.keyName())
            {
                if(allFields.get(strCurrFld).isNameField)
                {
                    
                }
            }*/
            //strLogInfo += 'The forward shipment process '+ listForwardShipmentProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Name__c+' completed successfully. Here are the details:' + ' \n ';
            strLogInfo += getTAG001();
            strLogInfo += getTAG002() +  setUniquePro.size() + ' \n ';
            strLogInfo += getTAG003() +  setUniqueLoc.size() + ' \n ';
            strLogInfo += getTAG004() +  mapReturnShipmentOrders.keySet().size() + ' \n \n ';
            strLogInfo += getTAG005() +  ' \n \n';
            Map<String,List<String>> mapUniDestLocAndShpIds = new Map<String,List<String>>();
            Set<Id> setSHPIds = new Set<Id>();
            String strDestLocation = null;
            List<String> lstShipOrderIfDestNull = new List<String>();
            for(SObject objRMAOrder : lstNewShipmentOrders)
            {
                setSHPIds.add(String.valueOf(objRMAOrder.get('Id')));
                if(objRMAOrder.get('SVMXC__Destination_Location__c') != null)
                {
                    strDestLocation = String.valueOf(objRMAOrder.get('SVMXC__Destination_Location__c'));                
                    if(!mapUniDestLocAndShpIds.containsKey(strDestLocation))
                    {
                        mapUniDestLocAndShpIds.put(strDestLocation,new List<String>());
                    }
                    mapUniDestLocAndShpIds.get(strDestLocation).add(String.valueOf(objRMAOrder.get('Id')));                 
                }else
                {
                    lstShipOrderIfDestNull.add(String.valueOf(objRMAOrder.get('Id')));
                }
                
            }
            Map<Id,SVMXC__RMA_Shipment_Order__c> mapRevisedRMAShpOrds = new Map<Id,SVMXC__RMA_Shipment_Order__c>();
            mapRevisedRMAShpOrds.putAll([Select Id, Name, SVMXC__Destination_Location__c, SVMXC__Destination_Location__r.Name from SVMXC__RMA_Shipment_Order__c where Id In: setSHPIds]);           
            integer intRecCount = 0 ;
            Schema.SObjectType descPartsOrder = schemamap.get('SVMXC__RMA_Shipment_Order__c');
            Schema.DescribeSObjectResult objPODESCRes = descPartsOrder.getDescribe();
            Map<String, Schema.SObjectField> mapPOFields = objPODESCRes.fields.getMap();
            String lblPONameField = '';
            for(string objCurrField : mapPOFields.keySet())
            {
                Schema.DescribeFieldResult descCurrField = mapPOFields.get(objCurrField).getDescribe();
                if(descCurrField.isNameField())
                {
                    lblPONameField = descCurrField.getLabel();
                    break;
                }
            }
            System.debug('Name Field label for teh Parts Order: ' + lblPONameField);
            for(Id idOfShp : mapUniDestLocAndShpIds.keySet())
            {
                List<String> lstShpOrd = mapUniDestLocAndShpIds.get(idOfShp);
                intRecCount = 0;
                for(String strShpID : lstShpOrd)
                {
                    if(intRecCount == 0)
                        strLogInfo += getTAG006() + mapRevisedRMAShpOrds.get(strShpID).SVMXC__Destination_Location__r.Name + ' \n ';
                    strLogInfo += lblPONameField + ': ' + mapRevisedRMAShpOrds.get(strShpID).Name + ' \n ';
                }               
            } 
            if(lstShipOrderIfDestNull.size() > 0)
            {
                intRecCount = 0;
                for(String strShpID : lstShipOrderIfDestNull)
                {
                    if(intRecCount == 0)
                        strLogInfo += getTAG006() + ' \n ';
                    strLogInfo += lblPONameField + ': ' + mapRevisedRMAShpOrds.get(strShpID).Name + ' \n ';             
                }
            }       
            
          }
          
          if(strEmailId != null)//listForwardShipmentProcess[0].SVMXC__Dispatch_Process__r.SVMXC__Capture_Log__c)
          {
            frwdShpmentStatusEmail(strLogInfo,strEmailId,lstStopsForLocationType[0].SVMXC__Record_Card__r.SVMXC__Current_Stop__r.Name);//,isException);
          }
    }
    
    public static void frwdShpmentStatusEmail(String frwdShpMessage, String emailID, String locationName)//,Boolean isException)
    {
          Messaging.SingleEmailMessage objMailShpMessage = new Messaging.SingleEmailMessage();
          objMailShpMessage.setToAddresses(new String[] {emailID});
          objMailShpMessage.setSenderDisplayName(getTAG007());
          objMailShpMessage.setSubject(getTAG008() + locationName);
          objMailShpMessage.setBccSender(false);
          objMailShpMessage.setUseSignature(false);
          objMailShpMessage.setPlainTextBody(frwdShpMessage);
          if(!Test.isRunningTest())
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMailShpMessage });       
    }
    
     public static String getTAG001(){ return System.Label.APL004_TAG001;}
     public static String getTAG002(){ return System.Label.APL004_TAG002;}
     public static String getTAG003(){ return System.Label.APL004_TAG003;}
     public static String getTAG004(){ return System.Label.APL004_TAG004;}
     public static String getTAG005(){ return System.Label.APL004_TAG005;}
     public static String getTAG006(){ return System.Label.APL004_TAG006;}
     public static String getTAG007(){ return System.Label.APL004_TAG007;}
     public static String getTAG008(){ return System.Label.APL004_TAG008;}
     public static String getTAG009(){ return System.Label.APL004_TAG009;}
    
}