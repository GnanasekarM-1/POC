public with sharing class APL_WorkOrderUtils 
{
	public SVMXC.INTF_WebServicesDef.INTF_SFMResponse APL_CreateWorkOrdersOnReceipt(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request)
	{
		SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
		response.success = true;
		try
		{
			system.debug('request'+request);
			SVMXC.INTF_ApplyMapping applymapping = new SVMXC.INTF_ApplyMapping();
	    	SVMXC.INTF_WebServicesDef.APL_Order aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
	    	map<String,String> mapLineIdUniqueIdForClient = new map<String,String>();
	    	SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
	    	SVMXC__RMA_Shipment_Order__c ObjPartsOrder = new SVMXC__RMA_Shipment_Order__c();
	        list<SVMXC__RMA_Shipment_Line__c> lstPOLines = new list<SVMXC__RMA_Shipment_Line__c>();
	        map<String,SVMXC__RMA_Shipment_Line__c> mapPOLines = new map<String,SVMXC__RMA_Shipment_Line__c>();
	        map<String,SVMXC__Service_Order__c> mapMasterLineIDWoObj = new map<String,SVMXC__Service_Order__c>();
	        map<String, Schema.SObjectType> gd = new map<String, Schema.SObjectType>();
	    	map<String, Schema.SObjectType> allobjmap  = new map<String, Schema.SObjectType>();
	        list<Sobject> lstWorkOrders = new list<Sobject>();
	        list<Sobject> lstWOToBeSaved  = new list<Sobject>();
	        list<SVMXC__Service_Order__c> lstFinalWO  = new list<SVMXC__Service_Order__c>();
	        set<String> setRouteStopIds = new set<String>();
	        String strHeaderObjMapId = '';
	    	String strLineObjMapId = '';
	    	String strMappingPreference = '';
	    	aplOrder = request.aplOrder;
	    	objSVMXProcess = aplOrder.svmxProcess;
	    	ObjPartsOrder = aplOrder.orderHdrRecord;
	    	gd = Schema.getGlobalDescribe();
	        for(Schema.SObjectType s : gd.values())
	        {
	            allobjmap.put(s.getDescribe().getName(),s);
	        }
	       	system.debug('allobjmap'+allobjmap);
	       	if(aplOrder.orderLines.size() > 0)
	    	{
	    		if(ObjPartsOrder.SVMXC__Fulfillment_Type__c != null && ObjPartsOrder.SVMXC__Fulfillment_Type__c.touppercase() != 'REPAIR')
    			{
	    			for(Integer i = 0;i<aplOrder.orderLines.size();i++)
    				{
	    				//Create WorkOrders only when Parts Order Line is not having reference to WorkOrders.
	    				if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Service_Order__c == null)
	    				{
		    				mapLineIdUniqueIdForClient.put(aplOrder.orderLines[i].orderLineRecord.id,aplOrder.orderLines[i].uniqueIdForClient);
		    				if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Route_Stop__c != null)
		    					setRouteStopIds.add(aplOrder.orderLines[i].orderLineRecord.SVMXC__Route_Stop__c);
		    				mapPOLines.put(aplOrder.orderLines[i].orderLineRecord.id,aplOrder.orderLines[i].orderLineRecord);
		    				lstWorkOrders.add(new SVMXC__Service_Order__c());
	    					if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Master_Order_Line__c != null)
		    					mapMasterLineIDWoObj.put(aplOrder.orderLines[i].orderLineRecord.SVMXC__Master_Order_Line__c, new SVMXC__Service_Order__c());
		    				else
		    				{
			    				response.message = system.label.APL003_TAG051;//RMA line does not have master RMA line associate with it.
		  						response.success = false;
		  						return response;
		    				}
	    				}		
	    			
    				}	
    			}
    			else 
    			{
    				for(Integer i = 0;i<aplOrder.orderLines.size();i++)
    				{
	    				mapLineIdUniqueIdForClient.put(aplOrder.orderLines[i].orderLineRecord.id,aplOrder.orderLines[i].uniqueIdForClient);
	    				//Create WorkOrders only when Parts Order Line is not having reference to WorkOrders.
	    				if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Service_Order__c == null)
	    				{
		    				if(aplOrder.orderLines[i].orderLineRecord.SVMXC__Route_Stop__c != null)
		    					setRouteStopIds.add(aplOrder.orderLines[i].orderLineRecord.SVMXC__Route_Stop__c);
		    				mapPOLines.put(aplOrder.orderLines[i].orderLineRecord.id,aplOrder.orderLines[i].orderLineRecord);
	    					lstWorkOrders.add(new SVMXC__Service_Order__c());
	    					if(aplOrder.orderLines[i].orderLineRecord.id != null)
		    					mapMasterLineIDWoObj.put(aplOrder.orderLines[i].orderLineRecord.id, new SVMXC__Service_Order__c());
	    				}		
	    			}	
    			}
    			if(mapPOLines.size() > 0)
    				lstPOLines.addall(mapPOLines.values());
	    	}
	    	system.debug('mapPOLines'+mapPOLines.size()+mapPOLines);	
	    	system.debug('lstPOLines'+lstPOLines.size()+lstPOLines);
	    	system.debug('mapMasterLineIDWoObj'+mapMasterLineIDWoObj.size()+mapMasterLineIDWoObj);
	    	system.debug('lstWorkOrders'+lstWorkOrders.size()+lstWorkOrders);
	    	system.debug('mapLineIdUniqueIdForClient'+mapLineIdUniqueIdForClient.size()+mapLineIdUniqueIdForClient);
	    	if((aplOrder.processType == 'PROCESSRECEIPT' && objSVMXProcess.SVMXC__APL_Create_Work_Order_On__c == 'RECEIPT') || (aplOrder.processType == 'DELIVERYONRECEIPT' && objSVMXProcess.SVMXC__APL_Create_Work_Order_On__c == 'DELIVERY'))//&& objSVMXProcess.SVMXC__APL_Group_Work_Order_By__c == 'ONE_PRODUCT'
	    	{
	    		system.debug('Entered..'+objSVMXProcess.SVMXC__APL_Create_WO_Preference__c);
	    		if(objSVMXProcess.SVMXC__Parent_Object__c != null)
	    			strHeaderObjMapId = objSVMXProcess.SVMXC__Parent_Object__c;
	    		if(objSVMXProcess.SVMXC__Process__c != null)
	    			strLineObjMapId = objSVMXProcess.SVMXC__Process__c;
	    		system.debug('strHeaderObjMapId: '+strHeaderObjMapId); 
	    		system.debug('strLineObjMapId: '+strLineObjMapId);
	    		if(objSVMXProcess.SVMXC__APL_Create_WO_Preference__c != null && objSVMXProcess.SVMXC__APL_Create_WO_Preference__c == 'APPLY_ORDER_FIRST')
	    		{
	    			//First Header..
	    			list<Sobject> lstOutput = new list<Sobject>();
	    			if(strHeaderObjMapId != null && strHeaderObjMapId.length() > 0 && ObjPartsOrder.SVMXC__Fulfillment_Type__c != 'Repair' && ObjPartsOrder.SVMXC__Master_Order__c != null)
	    				lstOutput = applymapping.getApplyMapping(lstWorkOrders,strHeaderObjMapId,ObjPartsOrder.SVMXC__Master_Order__c,false,allobjmap);
	    			else if(strHeaderObjMapId != null && strHeaderObjMapId.length() > 0 && ObjPartsOrder.SVMXC__Fulfillment_Type__c == 'Repair' && ObjPartsOrder.id != null)
	    			{
	    				lstOutput = applymapping.getApplyMapping(lstWorkOrders,strHeaderObjMapId,ObjPartsOrder.id,false,allobjmap);
	    			}
	    			system.debug('lstOutput: '+lstOutput.size()+lstOutput);
	    			//Now create the Work Orders and then update the Parts Order Line 
	    			if(lstOutput.size() > 0)
		    		{
		    			system.debug('lstOutput'+lstOutput.size()+lstOutput);
		    			try
		    			{
		    				//insert lstOutput;
		    				if(COMM_SecurityUtils.getInstance().verifyFieldAccess(lstOutput, COMM_SecurityUtils.Access.Createable)){
							    insert lstOutput; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
							}
							else{
	                            response.success = false;
	                            response.message = System.Label.COMM001_TAG142;
	                            return response;
	                        }	
		    			}
		    			catch(System.DmlException e)
		       			{
				       		/*list<String> UniqueIdForClient = new list<String>();
				       		LineIds.addall(mapLineIdUniqueIdForClient.keyset());
				       		for (Integer i = 0; i < e.getNumDml(); i++) 
				       		{
				       		 	SVMXC.INTF_WebServicesDef.SVMXError error = new SVMXC.INTF_WebServicesDef.SVMXError(); 
				       		 	error.errorMsg = e.getDmlMessage(i);
				       		 	error.errorMsg += ' For Unique Id: '+UniqueIdForClient.get(i);
			       		 		error.uniqueId = LineIds.get(i);
				       		 	response.errors.add(error);
				       		}*/
				       		//response.success = false;
				       		//return response;
		       			}	
		    		}
		    		if(lstPOLines.size() > 0 && lstOutput != NULL && lstOutput.size() > 0)
		    		{
			    		for(Integer i = 0;i<lstPOLines.size();i++)
			    		{
			    			lstPOLines[i].SVMXC__Service_Order__c = lstOutput[i].id;
			    		}
                        
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstPOLines, COMM_SecurityUtils.Access.Updateable ) ) {
                            update lstPOLines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } else {
                            response.success = false;
                            response.message = System.Label.COMM001_TAG142;
                            return response;
                        }			    		
		    		}
	    			if(lstOutput.size() > 0)
	    			{
	    				mapMasterLineIDWoObj.clear();
	    				if(ObjPartsOrder.SVMXC__Fulfillment_Type__c != 'Repair')
	    				{
		    				for(Integer i = 0;i<lstPOLines.size();i++)
				    		{
				    			if(lstPOLines[i].SVMXC__Master_Order_Line__c != null)
				    				mapMasterLineIDWoObj.put(lstPOLines[i].SVMXC__Master_Order_Line__c, (SVMXC__Service_Order__c)lstOutput[i]);
				    		}
	    				}
	    				else if(ObjPartsOrder.SVMXC__Fulfillment_Type__c == 'Repair')
	    				{
	    					for(Integer i = 0;i<lstPOLines.size();i++)
				    		{
				    			mapMasterLineIDWoObj.put(lstPOLines[i].id, (SVMXC__Service_Order__c)lstOutput[i]);
				    		}
	    				}	
	    			}
	    			system.debug('mapMasterLineIDWoObj: '+mapMasterLineIDWoObj.size()+mapMasterLineIDWoObj);
	    			//Then Line
	    			if(mapMasterLineIDWoObj.size() > 0 && strLineObjMapId != null && strLineObjMapId.length() > 0)
	    			{
	    				map<String,Sobject> mapOutPut = new map<String,Sobject>(); 
	    				list<SVMXC__Service_Order__c> lstWOs = new list<SVMXC__Service_Order__c>();
	    				mapOutPut = applymapping.getApplyMappingCore(strLineObjMapId,mapMasterLineIDWoObj,false,allobjmap);
	    				system.debug('mapOutPut'+mapOutPut.size()+mapOutPut);
	    				if(mapOutPut.size() > 0)
	    				{
	    					for(String str : mapOutPut.keyset())
	    					{
	    						SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
	    						wo = (SVMXC__Service_Order__c)mapOutPut.get(str);
	    						wo.SVMXC__Master_Order_Line__c = str;
	    						if(mapPOLines.containskey(str))
	    						{
	    							wo.SVMXC__Product__c = mapPOLines.get(str).SVMXC__Product__c;
	    							wo.SVMXC__Component__c = mapPOLines.get(str).SVMXC__Serial_Number__c;
	    						}
	    						lstWOs.add(wo);	
	    					}
	    					system.debug('lstWOs'+lstWOs.size()+lstWOs);
                            if(lstWOs.size() > 0) {
                                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstWOs, COMM_SecurityUtils.Access.Updateable ) ) {
                                    update lstWOs; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                } else {
                                    response.success = false;
                                    response.message = System.Label.COMM001_TAG142;
                                    return response;
                                }
                            }
	    						
	    				}
	    					
	    			}
	    		}
	    		else if(strLineObjMapId != null && strLineObjMapId.length() > 0 && objSVMXProcess.SVMXC__APL_Create_WO_Preference__c != null && objSVMXProcess.SVMXC__APL_Create_WO_Preference__c == 'APPLY_LINE_FIRST')
	    		{
	    			//First Line
	    			map<String,Sobject> mapOutPut = new map<String,Sobject>(); 
	    			mapOutPut = applymapping.getApplyMappingCore(strLineObjMapId,mapMasterLineIDWoObj,false,allobjmap);
	    			//Now create the Work Orders and then update the Parts Order Line 
	    			map<String,String> mapWOIdLineId = new map<String,String>();
	    			system.debug('mapOutPut'+mapOutPut.size()+mapOutPut);
	    			if(mapOutPut.size() > 0)
		    		{
		    			insert mapOutPut.values();
		    			for(String str : mapOutPut.keyset())
		    			{
		    				mapWOIdLineId.put(mapOutPut.get(str).id,str);
		    			}
		    		}
		    		system.debug('mapWOIdLineId'+mapWOIdLineId.size()+mapWOIdLineId);
		    		if(lstPOLines.size() > 0)
		    		{
			    		for(Integer i = 0;i<lstPOLines.size();i++)
			    		{
			    			if(mapOutPut.containskey(lstPOLines[i].id))
			    				lstPOLines[i].SVMXC__Service_Order__c = mapOutPut.get(lstPOLines[i].id).id;
			    		}
                        
                        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstPOLines, COMM_SecurityUtils.Access.Updateable ) ) {
                            update lstPOLines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                        } else {
                            
                            response.success = false;
                            response.message = System.Label.COMM001_TAG142;
                            return response;
                        }			    		
		    		}
	    			//Then Header
	    			if(mapOutPut.values().size() > 0 && strHeaderObjMapId != null && strHeaderObjMapId.length() > 0)
	    			{
	    				if(ObjPartsOrder.SVMXC__Fulfillment_Type__c != 'Repair')
	    				{
	    					lstWOToBeSaved = applymapping.getApplyMapping(mapOutPut.values(),strHeaderObjMapId,ObjPartsOrder.SVMXC__Master_Order__c,false,allobjmap);
	    				}
	    				else if(ObjPartsOrder.SVMXC__Fulfillment_Type__c == 'Repair')
	    				{
	    					lstWOToBeSaved = applymapping.getApplyMapping(mapOutPut.values(),strHeaderObjMapId,ObjPartsOrder.id,false,allobjmap);
	    				}	
	    				if(lstWOToBeSaved.size() > 0)
	    				{
	    					for(Sobject sobj : lstWOToBeSaved)
	    					{
	    						SVMXC__Service_Order__c WO = new SVMXC__Service_Order__c();
	    						WO = (SVMXC__Service_Order__c) sobj;
	    						if(mapWOIdLineId.containskey(WO.id))
	    							WO.SVMXC__Master_Order_Line__c = mapWOIdLineId.get(WO.id);
	    						if(WO.SVMXC__Master_Order_Line__c != null && mapPOLines.containskey(WO.SVMXC__Master_Order_Line__c))
	    						{
	    							WO.SVMXC__Product__c = mapPOLines.get(WO.SVMXC__Master_Order_Line__c).SVMXC__Product__c;
	    							WO.SVMXC__Component__c = mapPOLines.get(WO.SVMXC__Master_Order_Line__c).SVMXC__Serial_Number__c;
	    						}
	    						lstFinalWO.add(WO);	
	    					}
	    					system.debug('lstFinalWO'+lstFinalWO.size()+lstFinalWO);
                            if(lstFinalWO.size() > 0) {
                                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstFinalWO, COMM_SecurityUtils.Access.Updateable ) ) {
                                    update lstFinalWO; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                                } else {
                                    response.success = false;
                                    response.message = System.Label.COMM001_TAG142;
                                    return response;
                                }
                            }
	    						
	    				}	
	    			}	
	    		}
	    		//Once WorkOrders are created then update the Route Stop record as WorkOrderCreated = true;
	    		if(setRouteStopIds.size() > 0)
	    		{
	    			map<String,SVMXC__Route_Stop__c> mapRouteStop = new map<String,SVMXC__Route_Stop__c>();
                	mapRouteStop.putall([select Id,Name,SVMXC__Work_Order_Created__c from SVMXC__Route_Stop__c where Id IN : setRouteStopIds]);
                	if(mapRouteStop.size() > 0)
                	{
                		for(String str : mapRouteStop.keyset())
                		{
                			mapRouteStop.get(str).SVMXC__Work_Order_Created__c = true;
                		}
                		update mapRouteStop.values();
                	}
	    		} 
	    	}
	    }
	    catch(Exception ex)
		{
			response.message = ex.getMessage();
  			response.success = false;
		}
		return response;
	}
}