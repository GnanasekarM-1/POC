public with sharing class APL_FulfillmentConsole {
    public set<Id> setAvailableLocations = new set<Id>();
    public List<SVMXC.INTF_WebServicesDef.SVMXMap> lstOrderLineProduct = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
    public list<SVMXC.INTF_WebServicesDef.SVMXMap> lstProductMapForResponse = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
    map<Id, String> locationNames = new map<Id, String>();
    map<String, Id> mapProductStockIds = new map<String, Id>();
    public class SVMXException extends Exception{}
    Id stockHistoryRtypeId;
    
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse getAPLFulfillmentOrder(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request)
    {
        //Added by Naveen V on 08-March-2012 For Performance
        //COMM_PerformanceUtils perfUtil = new COMM_PerformanceUtils();
        //perfUtil.begin();
        //COMM_PerformanceUtils.start('001: VARIABLE-DECLARATION');
        //COMM_PerformanceUtils.start('001:a: VARIABLE-DECLARATION _ Simple');
        
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        map<Id, SVMXC.INTF_WebServicesDef.SVMXMap> mapLineLocations = new map<Id, SVMXC.INTF_WebServicesDef.SVMXMap>();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForResponse = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        SVMXC.INTF_WebServicesDef.APL_Order aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        String strRecordId = '';
        String strProcessId = '';
        String strProcessType = '';
        String fldMapRecTypeId = '';
        String strHeaderErrorMsg = '';
        String strLineErrorMsg = '';
        String strDepotLocationRtypeId = '';
        String strDepot = '';
        String strHeaderFields = ''; 
        String strReceivingLocation = '';
        SVMXC.INTF_ParseExpression ExpParssig;
        SVMXC__ServiceMax_Processes__c Expression = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c lineExpression = new SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Config_Data__c> lstDocumentAttribute = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__RMA_Shipment_Order__c orderHeader = new SVMXC__RMA_Shipment_Order__c();
        SVMXC__RMA_Shipment_Order__c dataForDocumentAttribut = new SVMXC__RMA_Shipment_Order__c();
        list<SVMXC__RMA_Shipment_Line__c> lstOrderLines = new list<SVMXC__RMA_Shipment_Line__c>();
        map<Id,SVMXC__RMA_Shipment_Line__c> mapOrderLines = new map<Id,SVMXC__RMA_Shipment_Line__c>();
        map<String,Boolean> mapProIdStockable = new map<String,Boolean>();
        map<String,Boolean> mapProIdSerializable = new map<String,Boolean>();
        map<String, list<String>> mapProductLineIds = new map<String, list<String>>();
        list<Product2> lstProduct = new list<Product2>();
        set<String> setProductId = new set<String>();
        set<String> setLineIds = new set<String>();
        List<RecordType> RecordTypes = new List<RecordType>();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        
        //COMM_PerformanceUtils.stop('001:a: VARIABLE-DECLARATION _ Simple');
        //COMM_PerformanceUtils.start('001:b: VARIABLE-DECLARATION _ QueryingRT');
        List<String> queryFields = new List<String> {'Name', 'Id' };
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'RecordType', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        RecordTypes = [Select Name, Id From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' OR SobjectType = 'SVMXC__Site__c']; //SDL-SVMX-READ-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('001:b: VARIABLE-DECLARATION _ QueryingRT');
        
        String StrOrderLineFields = ' SVMXC__Master_Order_Line__c, SVMXC__Warehouse__c, SVMXC__Serial_Number__c, SVMXC__Serial_Number_List__c, SVMXC__Sales_Order_Number__c, SVMXC__Route_Stop__c, SVMXC__Route_Card__c, SVMXC__Reconciliation_Action__c, SVMXC__RMA_Shipment_Order__c, SVMXC__Product__c, SVMXC__Expected_Quantity2__c, SVMXC__Delivery_Location__c, SVMXC__Actual_Quantity2__c, RecordTypeId, Name, Id, SVMXC__Product__r.Name, SVMXC__Product__r.ProductCode ';
        system.debug('Request :' + request);
        
        Integer batchSize = 100;
        Integer currentCount = 0;
        list<String> remainingIds = new list<String>();
        set<String> currentBatchIds = new set<String>();
        SVMXC.INTF_WebServicesDef.SVMXMap nextBatchLineIds = new SVMXC.INTF_WebServicesDef.SVMXMap();
        nextBatchLineIds.key = 'BATCHIDS';
        nextBatchLineIds.valueMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstCurrentBatchIds = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        //COMM_PerformanceUtils.start('001:c: VARIABLE-DECLARATION _ LoopingRT');
        
        if(RecordTypes.size() > 0 )
        {
            for(RecordType r : RecordTypes)
            {
                if(r.Name == 'Field Mapping')
                    fldMapRecTypeId = r.id;
                else if(r.Name == 'Depot')
                    strDepotLocationRtypeId = r.id;     
            }
        }
        //COMM_PerformanceUtils.stop('001:c: VARIABLE-DECLARATION _ LoopingRT');
        //COMM_PerformanceUtils.start('001:d: VARIABLE-DECLARATION _ Request');
        lstSVMXMap = request.valueMap;
        if(lstSVMXMap.size() > 0)
        {
            for(Integer i = 0;i<lstSVMXMap.size();i++)
            {
                if(lstSVMXMap[i].key.touppercase() == 'SVMX_RECORDID')
                    strRecordId = lstSVMXMap[i].value;
                else if(lstSVMXMap[i].key.touppercase() == 'SVMX_PROCESSID')
                    strProcessId = lstSVMXMap[i].value; 
                else if(lstSVMXMap[i].key.touppercase() == 'SVMX_PROCESSTYPE')
                    strProcessType = lstSVMXMap[i].value;       
                else if(lstSVMXMap[i].key.touppercase() == 'SVMX_BATCHIDS')
                    lstCurrentBatchIds = lstSVMXMap[i].valueMap;     
            }
        }
        //COMM_PerformanceUtils.stop('001:d: VARIABLE-DECLARATION _ Request');
        //for SVMXC__RMA_Shipment_Order__c
        map<String,String> mapAPINameLablePO = new map<String,String>();
        map<String, Schema.SObjectField> mapPOField = Schema.SObjectType.SVMXC__RMA_Shipment_Order__c.fields.getMap();
        //COMM_PerformanceUtils.start('001:e: VARIABLE-DECLARATION _ LoopingRmaSO');
        if(mapPOField.size() > 0)
        {
            //Commented as part of story BAC-3591 and added COMM_Utils_V2
            //SVMXC.COMM_Utils commUtils = new SVMXC.COMM_Utils();
            SVMXC.COMM_Utils_V2 commUtils = new SVMXC.COMM_Utils_V2();
            for(String str:mapPOField.keyset())
            {
                mapAPINameLablePO.put(mapPOField.get(str).getDescribe().getName(),mapPOField.get(str).getDescribe().getLabel());

                strHeaderFields =  commUtils.SVMX_getFieldNamesFromList(commUtils.SVMX_getFieldList(mapPOField,true));
                if(strHeaderFields != null && strHeaderFields.length() > 0)
                    strHeaderFields += ', SVMXC__Source_Location__r.Name, SVMXC__Destination_Location__r.Name';
            }
        }
        //COMM_PerformanceUtils.stop('001:e: VARIABLE-DECLARATION _ LoopingRmaSO');
        //COMM_PerformanceUtils.stop('001: VARIABLE-DECLARATION');
        //COMM_PerformanceUtils.start('002: QueryingProcess');
        if(strProcessId != null && strProcessId.length() > 0)
        {
            queryFields = new List<String> {'Id','Name','RecordTypeId','SVMXC__Node_Parent__c', 'SVMXC__APL_Create_Internal_RMA__c', 'SVMXC__APL_Create_Supplier_RMA__c', 'SVMXC__Parent_Error_Msg__c', 'SVMXC__Parent_Error_Msg2__c', 'SVMXC__Child_Error_Msg__c', 'SVMXC__Child_Error_Msg2__c', 'SVMXC__Submodule__c', 'SVMXC__Module__c', 'SVMXC__Final_Exception_Process__c','SVMXC__Name__c','SVMXC__ProcessID__c','SVMXC__Description__c', 'SVMXC__APL_Action_On_Unexpected_Product__c', 'SVMXC__APL_Action_On_Unexpected_SN__c', 'SVMXC__APL_Action_On_Less_Qty__c', 'SVMXC__APL_Action_On_Excess_Qty__c', 'SVMXC__APL_Split_Lines__c' };
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            SVMXProcess = [select Id,Name,RecordTypeId,SVMXC__Node_Parent__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Child_Error_Msg__c, SVMXC__Child_Error_Msg2__c, SVMXC__Submodule__c, SVMXC__Module__c, SVMXC__Final_Exception_Process__c,SVMXC__Name__c,SVMXC__ProcessID__c,SVMXC__Description__c, SVMXC__APL_Action_On_Unexpected_Product__c, SVMXC__APL_Action_On_Unexpected_SN__c, SVMXC__APL_Action_On_Less_Qty__c, SVMXC__APL_Action_On_Excess_Qty__c, SVMXC__APL_Split_Lines__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strProcessId or id =: strProcessId]; //SDL-SVMX-READ-FLS-ENFORCED
            if(SVMXProcess != null)
                aplOrder.svmxProcess = SVMXProcess;
        }
        //COMM_PerformanceUtils.stop('002: QueryingProcess');
        //COMM_PerformanceUtils.start('003: QueryingConfData');
        if(SVMXProcess != null)
        {
            queryFields = new List<String> {'id','Name','RecordTypeId','SVMXC__Configuration_Type__c','SVMXC__Field_Name__c','SVMXC__Dispatch_Process__c','SVMXC__Display_Type__c', 'SVMXC__Field_Relationship_Name__c','SVMXC__FKey_Name_Field__c','SVMXC__Object_Name__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            lstConfigData = [select id,Name,RecordTypeId,SVMXC__Configuration_Type__c,SVMXC__Field_Name__c,SVMXC__Dispatch_Process__c,SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where  RecordTypeId =: fldMapRecTypeId and SVMXC__Dispatch_Process__c =: SVMXProcess.id]; //SDL-SVMX-READ-FLS-ENFORCED
            
            if(lstConfigData.size() > 0)
                aplOrder.configData = lstConfigData;
        }       
        //COMM_PerformanceUtils.stop('003: QueryingConfData');
        
        try
        {
            //COMM_PerformanceUtils.start('004: QueryingRmaSO');
            
            if(strRecordId != null && strRecordId.length() > 0)
            {
                queryFields = strHeaderFields.split(',');
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                
                String strQuery = 'Select '+ strHeaderFields +' From SVMXC__RMA_Shipment_Order__c where id =: strRecordId and RecordType.Name = \'RMA\' and SVMXC__On_Hold__c = false';
                system.debug('Query'+strQuery);
                orderHeader =  database.query(strQuery);
            }
            //COMM_PerformanceUtils.stop('004: QueryingRmaSO');
        }
        catch(exception ex)
        {
            response.success = false;
            response.message = system.label.APL003_TAG052;
            //COMM_PerformanceUtils.stop('004: QueryingRmaSO');
            //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
            return response;
        }
        system.debug('Order Header :' + orderHeader); 
        //Find the Depot and Receiving location for the PO 
        if(orderHeader.SVMXC__Destination_Location__c == null)
        {
            response.success = false;
            response.message = system.label.APL003_TAG041;//Destination location should not empty
            
            //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
            return response;
        }
        
        //COMM_PerformanceUtils.start('005: QueryingSiteDepotLoc');
        
        if(orderHeader.SVMXC__Destination_Location__c != null)
        {
            list<SVMXC__Site__c> lstDepotLocation = new list<SVMXC__Site__c>();
            
            queryFields = new List<String> {'id','Name','RecordTypeId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            lstDepotLocation = [select id,Name,RecordTypeId From SVMXC__Site__c where id =: orderHeader.SVMXC__Destination_Location__c and RecordTypeId =: strDepotLocationRtypeId]; //SDL-SVMX-READ-FLS-ENFORCED
            if(lstDepotLocation.size() > 0)
            {
                 strDepot = orderHeader.SVMXC__Destination_Location__r.Name;
                 list<SVMXC__Site__c> lstDepotsReceivingLocation = new list<SVMXC__Site__c>();
                 
                 //COMM_PerformanceUtils.start('005:a: QueryingSiteDepotLoc _ QueryingSiteReceivingLoc');
                queryFields = new List<String> {'id','Name','RecordTypeId','SVMXC__Parent__c','SVMXC__IsReceiving_Location__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                 lstDepotsReceivingLocation = [select id,Name,RecordTypeId,SVMXC__Parent__c,SVMXC__IsReceiving_Location__c from SVMXC__Site__c where SVMXC__Parent__c =: lstDepotLocation[0].id and SVMXC__IsReceiving_Location__c = true and RecordType.Name = 'Depot Child']; //SDL-SVMX-READ-FLS-ENFORCED
                 //COMM_PerformanceUtils.stop('005:a: QueryingSiteDepotLoc _ QueryingSiteReceivingLoc');
                 
                 if(lstDepotsReceivingLocation.size() == 0)
                 {
                    response.success = false;
                    response.message = system.label.APL003_TAG043+': '+orderHeader.SVMXC__Destination_Location__r.Name;//depot must have receiving location
                    
                    //COMM_PerformanceUtils.stop('005: QueryingSiteDepotLoc');
                    //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                    return response;
                 }   
                 else if(lstDepotsReceivingLocation.size() > 1)
                 {
                    response.success = false;
                    response.message = system.label.APL003_TAG044+': '+orderHeader.SVMXC__Destination_Location__r.Name;//depot has more then one receiving location
                    
                    //COMM_PerformanceUtils.stop('005: QueryingSiteDepotLoc');
                    //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                    return response;
                 }
                 else
                 {
                      strReceivingLocation = lstDepotsReceivingLocation[0].Name;
                 }    
            }
            else
            {
                response.success = false;
                response.message = system.label.APL003_TAG045;//Destination location must be depot.
                
                //COMM_PerformanceUtils.stop('005: QueryingSiteDepotLoc');
                //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                return response;
            }
        }
         //COMM_PerformanceUtils.stop('005: QueryingSiteDepotLoc');   
         //COMM_PerformanceUtils.start('006: INITIALSYNCorBatch');
        if(request.eventType == 'INITIALSYNC')
        {
            //Create a resonse map for the depot and receiving Location
            SVMXC.INTF_WebServicesDef.SVMXMap mapForHeaderAttribute = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForHeaderAttribute.key = 'HEADERATTRIBUTE';
            list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForHeaderAttribute = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
            SVMXC.INTF_WebServicesDef.SVMXMap mapForDepot = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForDepot.key = 'DEPOTNAME';
            mapForDepot.value = strDepot;
            lstSVMXMapForHeaderAttribute.add(mapForDepot);
            SVMXC.INTF_WebServicesDef.SVMXMap mapForReceivingLoc = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForReceivingLoc.key = 'RECEIVINGLOCATION';
            mapForReceivingLoc.value = strReceivingLocation;
            lstSVMXMapForHeaderAttribute.add(mapForReceivingLoc);
            mapForHeaderAttribute.valueMap = lstSVMXMapForHeaderAttribute;
            system.debug('Header Attribute: ' + mapForHeaderAttribute);
        
            String headerExpressionId = '';
            String childExpressionId = '';
            //Header Qualification...
            if(SVMXProcess.SVMXC__Module__c != null)
                headerExpressionId = SVMXProcess.SVMXC__Module__c;
            if(SVMXProcess.SVMXC__Submodule__c != null)
                childExpressionId = SVMXProcess.SVMXC__Submodule__c;
            if(SVMXProcess.SVMXC__Parent_Error_Msg__c != null)
                strHeaderErrorMsg = SVMXProcess.SVMXC__Parent_Error_Msg__c;
            
            //Added by Neeraj(March-8th): Handle to defect 003711.
            if(SVMXProcess.SVMXC__Child_Error_Msg__c != null)
                strLineErrorMsg = SVMXProcess.SVMXC__Child_Error_Msg__c;
                
            system.debug('Header Expression Id: ' + headerExpressionId);
            system.debug('Child Expression Id: ' + childExpressionId);
            
            //COMM_PerformanceUtils.start('006:a: INITIALSYNCorBatch _ QueryingProcessHE');
            
            if(headerExpressionId != '' && headerExpressionId.length() > 0) {
                
                queryFields = new List<String> {'Id', 'Name','SVMXC__Source_Object_Name__c', 'SVMXC__Name__c','SVMXC__SettingId__c','SVMXC__Description__c','SVMXC__Advance_Expression__c','SVMXC__ProcessID__c','SVMXC__Parent_Object_Criteria__c','SVMXC__Parent_Error_Msg__c','SVMXC__IsStandard__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                Expression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =: headerExpressionId]; //SDL-SVMX-READ-FLS-ENFORCED
            }
                
            
            //COMM_PerformanceUtils.stop('006:a: INITIALSYNCorBatch _ QueryingProcessHE');
            //COMM_PerformanceUtils.start('006:b: INITIALSYNCorBatch _ QueryingProcessRule');
            
            if(childExpressionId != '' && childExpressionId.length() > 0) {
                queryFields = new List<String> {'Id', 'Name','SVMXC__Source_Object_Name__c', 'SVMXC__Name__c', 'SVMXC__Submodule__c', 'SVMXC__SettingId__c','SVMXC__Description__c','SVMXC__Advance_Expression__c','SVMXC__ProcessID__c','SVMXC__Parent_Object_Criteria__c','SVMXC__Parent_Error_Msg__c','SVMXC__IsStandard__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                lineExpression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__Submodule__c, SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =: childExpressionId]; //SDL-SVMX-READ-FLS-ENFORCED
            }    
                
           
            //COMM_PerformanceUtils.stop('006:b: INITIALSYNCorBatch _ QueryingProcessRule');
            //COMM_PerformanceUtils.start('006:c: INITIALSYNCorBatch _ ParseExp');
            if(Expression != null && orderHeader != null)
            {
                system.debug('Entered for header qualification');
                SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                SFMExpression.namedExpression = Expression;
                list<Sobject> lstSobject = new list<Sobject>();
                list<SVMXC__RMA_Shipment_Order__c> lstPartsOrder = new list<SVMXC__RMA_Shipment_Order__c>();
                lstPartsOrder.add(orderHeader);
                ExpParssig = new SVMXC.INTF_ParseExpression();
                lstSobject = ExpParssig.INTF_ParseExpression(lstPartsOrder,SFMExpression);
                if(lstSobject.size() == 0)
                {
                    response.success = false;
                    response.message = strHeaderErrorMsg;
                    system.debug('Response: ' + response);
                    
                    //COMM_PerformanceUtils.stop('006: INITIALSYNCorBatch');
                    //COMM_PerformanceUtils.stop('006:c: INITIALSYNCorBatch _ ParseExp');
                    //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                    return response;
                }   
            }
            //COMM_PerformanceUtils.stop('006:c: INITIALSYNCorBatch _ ParseExp');
            
            String strRMALineStatus = 'Completed';
            String strShipmentLineStatus = 'Completed';
            SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
            list<String> setLstForAPL002 = new list<String>();
            list<String> setLstForAPL003 = new list<String>();
            setLstForAPL002.add('SET002');
            setLstForAPL003.add('SET002');
            map<String, String> svmxSettingListforAPL002 = commSettings.SVMX_getSettingList('APL002', setLstForAPL002);
            map<String, String> svmxSettingListforAPL003 = commSettings.SVMX_getSettingList('APL003', setLstForAPL003);
            if(svmxSettingListforAPL002.containskey('SET002'))
                strRMALineStatus = svmxSettingListforAPL002.get('SET002');
            if(svmxSettingListforAPL003.containskey('SET002'))
                strShipmentLineStatus = svmxSettingListforAPL003.get('SET002'); 
            //Line Qualification..
            //COMM_PerformanceUtils.start('006:d: INITIALSYNCorBatch _ QueryingRmaSO');
            
            if(strRecordId != null && strRecordId.length() > 0)
            {
                list<SVMXC__RMA_Shipment_Line__c> lstTempPOLines = new list<SVMXC__RMA_Shipment_Line__c>();
                list<Sobject> lstOutput = new list<Sobject>();
                queryFields =StrOrderLineFields.split(',');
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                String query = '';                
                query = 'Select ' +StrOrderLineFields+ '  From SVMXC__RMA_Shipment_Line__c  where SVMXC__RMA_Shipment_Order__c =: strRecordId';
                system.debug('Query String: ' + query);
                lstTempPOLines = Database.query(query);
                if(lstTempPOLines.size() > 0 && lineExpression != null)
                {
                    SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                    SFMExpression.namedExpression = lineExpression;
                    //SVMXC.INTF_ParseExpression ExpParssig = new SVMXC.INTF_ParseExpression();
                    lstOutput = ExpParssig.INTF_ParseExpression(lstTempPOLines,SFMExpression);
                    if(lstOutput.size() == 0)
                    {
                        response.success = false;
                        response.message = strLineErrorMsg;
                        system.debug('Response: ' + response);
                        //COMM_PerformanceUtils.stop('006:d: INITIALSYNCorBatch _ QueryingRmaSO');
                        //COMM_PerformanceUtils.stop('006: INITIALSYNCorBatch');
                        //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                        return response;
                    }
                    else
                    {
                        for(Integer i = 0;i<lstOutput.size();i++)
                        {
                            setLineIds.add(String.valueof(lstOutput[i].get('Id')));
                            list<String> lineIds = new list<String>();
                            lineIds.add(String.valueof(lstOutput[i].get('Id')));
                            if(mapProductLineIds.get(String.valueof(lstOutput[i].get('SVMXC__Product__c'))) != NULL)
                                lineIds.addAll(mapProductLineIds.get(String.valueof(lstOutput[i].get('SVMXC__Product__c'))));
                            mapProductLineIds.put(String.valueof(lstOutput[i].get('SVMXC__Product__c')), lineIds);
                        }
                    }
                }
                else
                {
                    response.success = false;
                    response.message = 'There is no line to process.';
                    system.debug('Response: ' + response);
                    //COMM_PerformanceUtils.stop('006:d: INITIALSYNCorBatch _ QueryingRmaSO');
                    //COMM_PerformanceUtils.stop('006: INITIALSYNCorBatch');
                    //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                    return response;
                }
            }
            //COMM_PerformanceUtils.stop('006:d: INITIALSYNCorBatch _ QueryingRmaSO');
            system.debug('setLineIds'+setLineIds.size()+setLineIds);
            //Loop config data and get the fields for the procuct attribute and document attrbutes fields and add in line query.
            
            //COMM_PerformanceUtils.start('006:e: INITIALSYNCorBatch _ LoopingConfDataToGetProdData');
            if(lstConfigData.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
                {
                    if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE')
                        StrOrderLineFields += ', SVMXC__Product__r.'+config.SVMXC__Field_Name__c;
                    if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && config.SVMXC__Field_Relationship_Name__c != null && config.SVMXC__FKey_Name_Field__c != null)
                        StrOrderLineFields += ' , '+config.SVMXC__Field_Relationship_Name__c+'.'+config.SVMXC__FKey_Name_Field__c;
                    else if(config.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE')  
                        lstDocumentAttribute.add(config);
                }
            }
            //COMM_PerformanceUtils.stop('006:e: INITIALSYNCorBatch _ LoopingConfDataToGetProdData');
            
            //Make Document Atttributes 
            
            //COMM_PerformanceUtils.start('006:f: INITIALSYNCorBatch _ DocAtt');
            if(lstDocumentAttribute.size() > 0)
            {
                SVMXC.INTF_WebServicesDef.SVMXMap mapForDocAttr = new SVMXC.INTF_WebServicesDef.SVMXMap();
                mapForDocAttr.key = 'DOCUMENTATTRIBUTE';
                list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForDocAttr = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
                
                //COMM_PerformanceUtils.start('006:f:001: INITIALSYNCorBatch _ DocAtt _ LoopingDocAtt');
                for(Integer i = 0;i<lstDocumentAttribute.size();i++)
                {
                    if(mapAPINameLablePO.containskey(lstDocumentAttribute[i].SVMXC__Field_Name__c))
                    {
                        system.debug('asdfgh'+mapAPINameLablePO.containskey(lstDocumentAttribute[i].SVMXC__Field_Name__c));
                        if(lstDocumentAttribute[i].SVMXC__Display_Type__c == 'REFERENCE' && lstDocumentAttribute[i].SVMXC__Object_Name__c != null && lstDocumentAttribute[i].SVMXC__FKey_Name_Field__c != null)
                        {
                            SVMXC.INTF_WebServicesDef.SVMXMap temp = new SVMXC.INTF_WebServicesDef.SVMXMap();
                            temp.key = mapAPINameLablePO.get(lstDocumentAttribute[i].SVMXC__Field_Name__c);
                            String strId = string.valueof(orderHeader.get(lstDocumentAttribute[i].SVMXC__Field_Name__c));
                            String strQuery = 'select id, '+lstDocumentAttribute[i].SVMXC__FKey_Name_Field__c+ ' from '+lstDocumentAttribute[i].SVMXC__Object_Name__c+ ' Where id =: strId'; 
                            
                            //COMM_PerformanceUtils.start('006:f:001:a INITIALSYNCorBatch _ DocAtt _ LoopingDocAtt _ QueryDocAtt');
                            
                            list<Sobject> Sobj = Database.Query(strQuery);
                            //COMM_PerformanceUtils.stop('006:e:001:a INITIALSYNCorBatch _ DocAtt _ LoopingDocAtt _ QueryDocAtt');
                            if(Sobj.size() > 0)
                                temp.value = String.valueof(Sobj[0].get(lstDocumentAttribute[i].SVMXC__FKey_Name_Field__c));
                            lstSVMXMapForDocAttr.add(temp);
                        }
                        else
                        {
                            SVMXC.INTF_WebServicesDef.SVMXMap temp = new SVMXC.INTF_WebServicesDef.SVMXMap();
                            temp.key = mapAPINameLablePO.get(lstDocumentAttribute[i].SVMXC__Field_Name__c);
                            temp.value = string.valueof(orderHeader.get(lstDocumentAttribute[i].SVMXC__Field_Name__c));
                            lstSVMXMapForDocAttr.add(temp);
                        }    
                    }   
                }
                //COMM_PerformanceUtils.stop('006:f:001: INITIALSYNCorBatch _ DocAtt _ LoopingDocAtt');
                mapForDocAttr.valueMap = lstSVMXMapForDocAttr;
                lstSVMXMapForResponse.add(mapForDocAttr);
            }
            //COMM_PerformanceUtils.stop('006:f: INITIALSYNCorBatch _ DocAtt');
            
            //COMM_PerformanceUtils.start('006:g: INITIALSYNCorBatch _ DocAtt');
            //Make Column info for Order line Table...
            APL_OrderUtils orderUtils = new APL_OrderUtils();
            SVMXC.INTF_WebServicesDef.SVMXMap mapForColumnInfo = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForColumnInfo.key = 'COLUMNINFO';
            mapForColumnInfo.value = orderUtils.MakeColumn(lstConfigData,strProcessType);
            lstSVMXMapForResponse.add(mapForColumnInfo);
            
            //Add mapForHeaderAttribute to final response
            lstSVMXMapForResponse.add(mapForHeaderAttribute);
            response.valueMap = lstSVMXMapForResponse;
            
            //COMM_PerformanceUtils.stop('006:g: INITIALSYNCorBatch _ DocAtt');
        }
        else
        {
            system.debug(Logginglevel.INFO, 'TESTLOG' + lstCurrentBatchIds);
            
            //COMM_PerformanceUtils.start('006:a: INITIALSYNCorBatch _ LoopingCurBatchId');
            
            for(SVMXC.INTF_WebServicesDef.SVMXMap productLines: lstCurrentBatchIds)
            {
                currentCount++;
                if(currentCount <= batchSize)
                {
                    setLineIds.addAll(productLines.values);
                    currentBatchIds.addAll(productLines.values);
                }
                else
                {
                    nextBatchLineIds.valueMap.add(productLines);
                }
            }
            //COMM_PerformanceUtils.stop('006:a: INITIALSYNCorBatch _ LoopingCurBatchId');
            // For second batch also we need to get product attributes
            //COMM_PerformanceUtils.start('006:b: INITIALSYNCorBatch _ LoopingConfData');
            
            if(lstConfigData.size() > 0)
            {
                for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
                {
                    if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE')
                        StrOrderLineFields += ', SVMXC__Product__r.'+config.SVMXC__Field_Name__c;
                    if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && config.SVMXC__Field_Relationship_Name__c != null && config.SVMXC__FKey_Name_Field__c != null)
                        StrOrderLineFields += ' , '+config.SVMXC__Field_Relationship_Name__c+'.'+config.SVMXC__FKey_Name_Field__c;
                }
            }
            //COMM_PerformanceUtils.stop('006:b: INITIALSYNCorBatch _ LoopingConfData');
        }
        
        //COMM_PerformanceUtils.stop('006: INITIALSYNCorBatch');
        //From the set of qualified lineids query lines again
        //We are doing this because the Expression parsing utility returns the Sobject List and we have to loop those objects and typecast to SVMXC__RMA_Shipment_Line__c instade we can query them again)
        queryFields =StrOrderLineFields.split(',');
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        String query = 'Select ' + StrOrderLineFields + '  From SVMXC__RMA_Shipment_Line__c  where Id IN : setLineIds ';
        system.debug('Query String: ' + query);
       

       //COMM_PerformanceUtils.start('007: QueryingRmaSL');
       if(setLineIds.size() > 0)
            lstOrderLines = Database.query(query);   
        
        //COMM_PerformanceUtils.stop('007: QueryingRmaSL');
        //COMM_PerformanceUtils.start('008: LoopingProdLineAndRmaSL');
        if(lstOrderLines.size() > 0)
        {
            //COMM_PerformanceUtils.start('008:a: LoopingProdLineAndRmaSL _ ProdLine');
            
            if(mapProductLineIds != NULL && mapProductLineIds.size() > 0)
            for(String productId: mapProductLineIds.keySet())
            {
                if(mapProductLineIds.get(productId) != NULL)
                {
                    currentCount++;
                    if(currentCount <= batchSize)
                    {
                        currentBatchIds.addAll(mapProductLineIds.get(productId));
                        setProductId.add(productId);
                    }
                    else
                    {
                        SVMXC.INTF_WebServicesDef.SVMXMap nextBatchIds = new SVMXC.INTF_WebServicesDef.SVMXMap();
                        nextBatchIds.key = productId;
                        nextBatchIds.values = mapProductLineIds.get(productId);
                        nextBatchLineIds.valueMap.add(nextBatchIds);
                    }
                }
            }   
            //COMM_PerformanceUtils.stop('008:a: LoopingProdLineAndRmaSL _ ProdLine');      
            
            //COMM_PerformanceUtils.start('008:b: LoopingProdLineAndRmaSL _ RmaSL');
            
            for(SVMXC__RMA_Shipment_Line__c orderLine: lstOrderLines)
            {
                if(currentBatchIds.contains(orderLine.Id))
                {
                    mapOrderLines.put(orderLine.Id,orderLine);
                }
            }
            //COMM_PerformanceUtils.stop('008:b: LoopingProdLineAndRmaSL _ RmaSL');
        }
        //COMM_PerformanceUtils.stop('008: LoopingProdLineAndRmaSL');
        
        //Setting additional lines for processing in next iteration
        if(nextBatchLineIds.valueMap != NULL && nextBatchLineIds.valueMap.size() > 0)
        {
            SVMXC.INTF_WebServicesDef.SVMXMap mapNextBatchIds = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapNextBatchIds.key = 'MAPKEYVALUES';
            mapNextBatchIds.valueMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
            mapNextBatchIds.valueMap.add(nextBatchLineIds);
            lstSVMXMapForResponse.add(mapNextBatchIds);
        }
        
        //Get all the product record to check the product is stockable or not.
        //COMM_PerformanceUtils.start('009: QueryingProduct');
        if(setProductId.size() > 0)
        {
            queryFields = new List<String> {'id','Name','SVMXC__Stockable__c','SVMXC__Enable_Serialized_Tracking__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Product2', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            lstProduct = [select id,Name,SVMXC__Stockable__c,SVMXC__Enable_Serialized_Tracking__c from Product2 where id IN : setProductId]; //SDL-SVMX-READ-FLS-ENFORCED
        }
        //COMM_PerformanceUtils.stop('009: QueryingProduct');
        //COMM_PerformanceUtils.start('010: LoopingProduct');
        if(lstProduct.size() > 0)
        {
            for(Product2 p : lstProduct)
            {
                if(p.SVMXC__Stockable__c != null)
                    mapProIdStockable.put(String.valueof(p.id).substring(0,15),p.SVMXC__Stockable__c);
                if(p.SVMXC__Enable_Serialized_Tracking__c != null)
                    mapProIdSerializable.put(String.valueof(p.id).substring(0,15),p.SVMXC__Enable_Serialized_Tracking__c);
            }   
        }
        //COMM_PerformanceUtils.stop('010: LoopingProduct');
        system.debug('Product Stockable: ' + mapProIdStockable.size() + mapProIdStockable);
        system.debug('Product Serializable: ' + mapProIdSerializable.size() + mapProIdSerializable);
        
        list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> lstOrderLine = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        
        //COMM_PerformanceUtils.start('011: FuncINTF_APL_GetAvailableStock');
        // If the porcess type is FULFILLMENTPROCESS we have APL_FulfillmentConsole class which gets order lines populated
        if(orderHeader.SVMXC__Fulfillment_Type__c != NULL && (orderHeader.SVMXC__Fulfillment_Type__c == 'Repair' || orderHeader.SVMXC__Fulfillment_Type__c == 'Sales'))
        {
            lstOrderLine = INTF_APL_GetAvailableStock(request, orderHeader, mapOrderLines, SVMXProcess);
            SVMXC.INTF_WebServicesDef.SVMXMap mapOrderLineProduct = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapOrderLineProduct.key = 'REQUESTATTRIBUTE';
            mapOrderLineProduct.valueMap = lstOrderLineProduct;
            SVMXC.INTF_WebServicesDef.SVMXMap mapAdditionalKeyValue = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapAdditionalKeyValue.key = 'MAPKEYVALUE';
            if(lstProductMapForResponse != NULL && lstProductMapForResponse.size() > 0)
            {
                mapAdditionalKeyValue.valueMap = lstProductMapForResponse;
                lstSVMXMapForResponse.add(mapAdditionalKeyValue);
            }
            lstSVMXMapForResponse.add(mapOrderLineProduct);
        }
        else
        {
            //COMM_PerformanceUtils.stop('011: FuncINTF_APL_GetAvailableStock');
            //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
            throw new SVMXException('The only fulfillment types that supported are repair and sales.');
        }
        
        //COMM_PerformanceUtils.stop('011: FuncINTF_APL_GetAvailableStock');
        
        aplOrder.orderLines = lstOrderLine;
        aplOrder.orderHdrRecord = orderHeader;
         
        response.valueMap = lstSVMXMapForResponse;
        response.success = true;
        response.aplOrder = aplOrder;
        system.debug('Response: '+response);
        
        //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
        return response;
    }
    
    public List<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> INTF_APL_GetAvailableStock(INTF_WebServicesDef.INTF_SFMRequest request, SVMXC__RMA_Shipment_Order__c orderHeader, Map<Id, SVMXC__RMA_Shipment_Line__c> mapOrderLines, SVMXC__ServiceMax_Processes__c fulfillmentProcess)
    {
        List<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> response = new List<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        SVMXC.INTF_ParseExpression ExpParssig = new SVMXC.INTF_ParseExpression();
        Map<SVMXC__ServiceMax_Processes__c, List<SVMXC__ServiceMax_Config_Data__c>> availableLocations = new Map<SVMXC__ServiceMax_Processes__c, List<SVMXC__ServiceMax_Config_Data__c>>();
        Map<String, Integer> mapAvailableStock = new Map<String, Integer>();
        
        //COMM_PerformanceUtils.start('011:a: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc');
        
        availableLocations = getProductExpressionLocationsForProcess(fulfillmentProcess);
        
        //COMM_PerformanceUtils.stop('011:a: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc');
        
        // Query the product and filter it based on the expression rules
        set<Id> setProductIds = new set<Id>();
        set<Id> setParsedProductIds = new set<Id>();
        Map<Id, Id> mapOrderLineProduct = new Map<Id, Id>();
        Map<Id, Id> mapProductOrderLine = new Map<Id, Id>();
        Map<Id, Decimal> mapExpectedProducts = new Map<Id, Decimal>();
        
        List<SVMXC__RMA_Shipment_Line__c> lstOrderLines = mapOrderLines.values();
        
        //COMM_PerformanceUtils.start('011:b: FuncINTF_APL_GetAvailableStock _ LoopingRmaSL');
        
        // Parsing order line for future references
        for(SVMXC__RMA_Shipment_Line__c orderLine: lstOrderLines)
        {
            if(orderLine.SVMXC__Product__c != NULL)
            {
                setProductIds.add(orderLine.SVMXC__Product__c);
                lstOrderLineProduct.add(new SVMXC.INTF_WebServicesDef.SVMXMap(orderLine.Id, orderLine.SVMXC__Product__c));
                mapOrderLineProduct.put(orderLine.Id, orderLine.SVMXC__Product__c);
                mapProductOrderLine.put(orderLine.SVMXC__Product__c, orderLine.Id);
                if(mapExpectedProducts.get(orderLine.SVMXC__Product__c) == NULL)
                    mapExpectedProducts.put(orderLine.SVMXC__Product__c, 0);
                mapExpectedProducts.put(orderLine.SVMXC__Product__c, mapExpectedProducts.get(orderLine.SVMXC__Product__c) + orderLine.SVMXC__Expected_Quantity2__c);
            }
        }
        //COMM_PerformanceUtils.stop('011:b: FuncINTF_APL_GetAvailableStock _ LoopingRmaSL');
        
        Map<Id, Product2> mapProduct = new Map<Id, Product2>();
        Map<Product2, List<SVMXC__ServiceMax_Config_Data__c>> mapProductLocation = new Map<Product2, List<SVMXC__ServiceMax_Config_Data__c>>();
        Map<Id, list<Id>> mapProductReplacement = new Map<Id, list<Id>>();
        List<String> queryFields = new List<String> {'Name', 'ProductCode', 'Family'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Product2', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        mapProduct.putAll([Select Name, ProductCode, Family from Product2 where Id IN : setProductIds]);
        
        //COMM_PerformanceUtils.start('011:c: FuncINTF_APL_GetAvailableStock _ LoopingProduct');
        
        for(Product2 prod: mapProduct.Values())
        {
            SVMXC.INTF_WebServicesDef.SVMXMap mapProdInfo = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapProdInfo.key = prod.Id;
            mapProdInfo.value = prod.Name;
            lstProductMapForResponse.add(mapProdInfo);
        }
        
        //COMM_PerformanceUtils.stop('011:c: FuncINTF_APL_GetAvailableStock _ LoopingProduct');
        system.debug('Products: ' + mapProduct);
        // Get all product replacement and build a map
        List<SVMXC__Product_Replacement__c> lstProdRep = new List<SVMXC__Product_Replacement__c>();
        
        //COMM_PerformanceUtils.start('011:d: FuncINTF_APL_GetAvailableStock _ QueryingProdReplacement');
        queryFields = new List<String> {'Id', 'SVMXC__Base_Product__c', 'SVMXC__Order_Of_Preference__c', 'SVMXC__Replacement_Product__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Replacement__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        lstProdRep = [Select Id, SVMXC__Base_Product__c, SVMXC__Order_Of_Preference__c, SVMXC__Replacement_Product__c, SVMXC__Replacement_Product__r.Name from SVMXC__Product_Replacement__c where SVMXC__Base_Product__c IN : setProductIds and SVMXC__Replacement_Product__c != NULL order by SVMXC__Order_Of_Preference__c desc]; //SDL-SVMX-READ-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('011:d: FuncINTF_APL_GetAvailableStock _ QueryingProdReplacement');
        //COMM_PerformanceUtils.start('011:e: FuncINTF_APL_GetAvailableStock _ loopingProdReplacement');
        
        for(SVMXC__Product_Replacement__c prdRep: lstProdRep)
        {
            list<Id> setReplacements = new list<Id>();
            setReplacements.add(prdRep.SVMXC__Replacement_Product__c);
            if(mapProductReplacement.get(prdRep.SVMXC__Base_Product__c) != NULL)
                setReplacements.addAll(mapProductReplacement.get(prdRep.SVMXC__Base_Product__c));
            mapProductReplacement.put(prdRep.SVMXC__Base_Product__c, setReplacements);
            
            SVMXC.INTF_WebServicesDef.SVMXMap mapProdInfo = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapProdInfo.key = prdRep.SVMXC__Replacement_Product__c;
            mapProdInfo.value = prdRep.SVMXC__Replacement_Product__r.Name;
            lstProductMapForResponse.add(mapProdInfo);
            setProductIds.add(prdRep.SVMXC__Replacement_Product__c);
        }
        //COMM_PerformanceUtils.stop('011:e: FuncINTF_APL_GetAvailableStock _ loopingProdReplacement');
        
        system.debug('Product Replacement: ' + mapProductReplacement);
        
        // Get the available stock for all the product/location combination
        //COMM_PerformanceUtils.start('011:f: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock');
        mapAvailableStock = getAvailableStock(setAvailableLocations, setProductIds, true);
        //COMM_PerformanceUtils.stop('011:f: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock');
        system.debug('Available Locations: ' + availableLocations);
        
        Map<Id, SVMXC__ServiceMax_Processes__c> lstFulfillmentExpression =  new Map<Id, SVMXC__ServiceMax_Processes__c>();
        set<Id> setExpressions = new set<Id>();
        //COMM_PerformanceUtils.start('011:g: FuncINTF_APL_GetAvailableStock _ LoopingAvailableLoc');
        for(SVMXC__ServiceMax_Processes__c rule: availableLocations.keySet())
        {
            setExpressions.add(rule.SVMXC__Submodule__c);
        }
        //COMM_PerformanceUtils.stop('011:g: FuncINTF_APL_GetAvailableStock _ LoopingAvailableLoc');
        
        //COMM_PerformanceUtils.start('011:h: FuncINTF_APL_GetAvailableStock _ QueryingProcessExp');
        queryFields = new List<String> {'SVMXC__Sequence__c', 'SVMXC__Source_Object_Name__c', 'SVMXC__IsDefault__c', 'SVMXC__Default_Location__c', 'SVMXC__Submodule__c', 'SVMXC__Process__c', 'SVMXC__Parent_Object_Criteria__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        lstFulfillmentExpression.putAll([Select SVMXC__Sequence__c, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Default_Location__c, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where Id = :setExpressions and SVMXC__Rule_Type__c = 'Named Expression' and RecordType.Name = 'SVMX Rule']);// 
        system.debug('lstFulfillmentExpression'+lstFulfillmentExpression);
        //COMM_PerformanceUtils.stop('011:h: FuncINTF_APL_GetAvailableStock _ QueryingProcessExp');
        
        // Apply rules for all order lines
        
        //COMM_PerformanceUtils.start('011:i: FuncINTF_APL_GetAvailableStock _ LoopingToApplyRule');
        
        for(SVMXC__ServiceMax_Processes__c rule: availableLocations.keySet())
        {
            if(mapProduct.size() == 0)
                break;
            system.debug('Product Rule: ' + mapProduct.size() + ':' + rule);
            if(rule != NULL && rule.SVMXC__Submodule__c != NULL && lstFulfillmentExpression.get(rule.SVMXC__Submodule__c) != NULL)
            {
                SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                SFMExpression.namedExpression = lstFulfillmentExpression.get(rule.SVMXC__Submodule__c);
                List<Product2> lstAvailableProduct = ExpParssig.INTF_ParseExpression(mapProduct.values(),SFMExpression);
                system.debug('Available Product: ' + lstAvailableProduct);
                
                //COMM_PerformanceUtils.start('011:i:001: FuncINTF_APL_GetAvailableStock _ LoopingToApplyRule _ LoopingAvailProd');
                
                for(Product2 prod: lstAvailableProduct)
                {
                    SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
                    SVMXC__RMA_Shipment_Line__c objOrderLine = mapOrderLines.get(mapProductOrderLine.get(prod.Id));
                    objOrderLine.SVMXC__Product__c = prod.Id;
                    objOrderLine.SVMXC__Expected_Quantity2__c = mapExpectedProducts.get(prod.Id);
                    orderLine.orderLineRecord = objOrderLine;
                    // Create availability details for everyline
                    list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> lstProductAvailability = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                    if(availableLocations.get(rule) == NULL)
                    {
                        SVMXC__ServiceMax_Config_Data__c location = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Location__c = rule.SVMXC__Default_Location__c);
                        availableLocations.put(rule, new List<SVMXC__ServiceMax_Config_Data__c>{location});
                    }
                    list<Id> availableProducts = new list<Id>();
                    availableProducts.add(prod.Id);
                    if(mapProductReplacement.get(prod.Id) != NULL && mapProductReplacement.get(prod.Id).size() > 0)
                    {
                        availableProducts.addAll(mapProductReplacement.get(prod.Id));
                    }
                    system.debug('Available Products: ' + availableProducts);
                    //mapProductReplacement.put(prod.Id, availableProducts);
                    
                    //COMM_PerformanceUtils.start('011:i:001:a: FuncINTF_APL_GetAvailableStock _ LoopingToApplyRule _ LoopingAvailProd _ LoopConfData');
                    
                    for(Integer i = 0; i < availableProducts.size(); i++)
                    {
                        Id prodId = availableProducts.get(i);
                        for(SVMXC__ServiceMax_Config_Data__c location: availableLocations.get(rule))
                        {
                            SVMXC.INTF_WebServicesDef.APL_SerialCollection locationDetail = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
                            locationDetail.uniqueId = location.SVMXC__Location__c;
                            locationDetail.productId = prodId;
                            locationDetail.serialNumber = location.SVMXC__Location__c + '' + prodId;
                            if(location.SVMXC__Location__c == rule.SVMXC__Default_Location__c)
                                locationDetail.locationName = locationNames.get(rule.SVMXC__Default_Location__c);
                            else
                                locationDetail.locationName = location.SVMXC__Location__r.Name;
                            if(mapAvailableStock.containsKey(location.SVMXC__Location__c + ':' + prodId) && mapAvailableStock.get(location.SVMXC__Location__c + ':' + prodId) != NULL)
                            {
                                locationDetail.availableCount = mapAvailableStock.get(location.SVMXC__Location__c + ':' + prodId);
                            }
                            else
                            {
                                locationDetail.availableCount = 0;
                            }
                            // Check whether its product replacement or not
                            if(prodId != prod.Id)
                            {
                                locationDetail.isProductReplacement = true;
                            }
                            else
                                locationDetail.isProductReplacement = false;
                            lstProductAvailability.add(locationDetail);
                        }
                    }
                    
                    //COMM_PerformanceUtils.stop('011:i:001:a: FuncINTF_APL_GetAvailableStock _ LoopingToApplyRule _ LoopingAvailProd _ LoopConfData');
                    
                    orderLine.serialNumbers = lstProductAvailability;
                    mapProductLocation.put(prod, availableLocations.get(rule));
                    mapProduct.remove(prod.Id);
                    setParsedProductIds.add(prod.Id);
                    response.add(orderLine);
                }
                
                //COMM_PerformanceUtils.stop('011:i:001: FuncINTF_APL_GetAvailableStock _ LoopingToApplyRule _ LoopingAvailProd');
            }
        }
        //COMM_PerformanceUtils.stop('011:i: FuncINTF_APL_GetAvailableStock _ LoopingToApplyRule');
        
        // For the remaining products identify the default location and set it up
        
        //COMM_PerformanceUtils.start('011:j: FuncINTF_APL_GetAvailableStock _ LoopingToSetDefLoc');
        
        for(SVMXC__ServiceMax_Processes__c rule: availableLocations.keySet())
        {
            if(rule.SVMXC__IsDefault__c == true)
            {
                system.debug('Product Rule: ' + mapProduct);
                
                //COMM_PerformanceUtils.start('011:j:a: FuncINTF_APL_GetAvailableStock _ LoopingToSetDefLoc _ LoopingProd');
                
                for(Product2 prod: mapProduct.Values())
                {
                    SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
                    SVMXC__RMA_Shipment_Line__c objOrderLine = mapOrderLines.get(mapProductOrderLine.get(prod.Id));
                    objOrderLine.SVMXC__Product__c = prod.Id;
                    objOrderLine.SVMXC__Expected_Quantity2__c = mapExpectedProducts.get(prod.Id);
                    orderLine.orderLineRecord = objOrderLine;
                    // Create availability details for everyline
                    list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> lstProductAvailability = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                    if(availableLocations.get(rule) == NULL)
                    {
                        SVMXC__ServiceMax_Config_Data__c location = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Location__c = rule.SVMXC__Default_Location__c);
                        availableLocations.put(rule, new List<SVMXC__ServiceMax_Config_Data__c>{location});
                    }
                    list<Id> availableProducts = new list<Id>();
                    availableProducts.add(prod.Id);
                    if(mapProductReplacement.get(prod.Id) != NULL && mapProductReplacement.get(prod.Id).size() > 0)
                    {
                        availableProducts.addAll(mapProductReplacement.get(prod.Id));
                    }
                    system.debug('Available Products: ' + availableProducts);
                    //mapProductReplacement.put(prod.Id, availableProducts);
                    
                    //COMM_PerformanceUtils.start('011:j:a:001: FuncINTF_APL_GetAvailableStock _ LoopingToSetDefLoc _ LoopingAvailProd');
                    for(Integer i = 0; i < availableProducts.size(); i++)
                    {
                        Id prodId = availableProducts.get(i);
                    
                        for(SVMXC__ServiceMax_Config_Data__c location: availableLocations.get(rule))
                        {
                            SVMXC.INTF_WebServicesDef.APL_SerialCollection locationDetail = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
                            locationDetail.uniqueId = location.SVMXC__Location__c;
                            locationDetail.productId = prodId;
                            locationDetail.serialNumber = location.SVMXC__Location__c + '' + prodId;
                            if(location.SVMXC__Location__c == rule.SVMXC__Default_Location__c)
                                locationDetail.locationName = locationNames.get(rule.SVMXC__Default_Location__c);
                            else
                                locationDetail.locationName = location.SVMXC__Location__r.Name;
                            if(mapAvailableStock.containsKey(location.SVMXC__Location__c + ':' + prodId) && mapAvailableStock.get(location.SVMXC__Location__c + ':' + prodId) != NULL)
                            {
                                locationDetail.availableCount = mapAvailableStock.get(location.SVMXC__Location__c + ':' + prodId);
                            }
                            else
                            {
                                locationDetail.availableCount = 0;
                            }
                            // Check whether its product replacement or not
                            if(prodId != prod.Id)
                            {
                                locationDetail.isProductReplacement = true;
                            }
                            else
                                locationDetail.isProductReplacement = false;
                            lstProductAvailability.add(locationDetail);
                        }
                        
                        
                    }
                    
                    //COMM_PerformanceUtils.stop('011:j:a:001: FuncINTF_APL_GetAvailableStock _ LoopingToSetDefLoc _ LoopingAvailProd');
                    orderLine.serialNumbers = lstProductAvailability;
                    mapProductLocation.put(prod, availableLocations.get(rule));
                    mapProduct.remove(prod.Id);
                    setParsedProductIds.add(prod.Id);
                    response.add(orderLine);
                }
                //COMM_PerformanceUtils.stop('011:j:a: FuncINTF_APL_GetAvailableStock _ LoopingToSetDefLoc _ LoopingProd');
            }
        }
        
        //COMM_PerformanceUtils.stop('011:j: FuncINTF_APL_GetAvailableStock _ LoopingToSetDefLoc');
        
        system.debug('Response: ' + response);
        return response;
    }
    // Get the expression vs list of location id/sequence for the given process
    public Map<SVMXC__ServiceMax_Processes__c, List<SVMXC__ServiceMax_Config_Data__c>> getProductExpressionLocationsForProcess(SVMXC__ServiceMax_Processes__c fulfillmentProcess)
    {
        Map<SVMXC__ServiceMax_Processes__c, List<SVMXC__ServiceMax_Config_Data__c>> response = new Map<SVMXC__ServiceMax_Processes__c, List<SVMXC__ServiceMax_Config_Data__c>>();
        Map<Id, List<SVMXC__ServiceMax_Config_Data__c>> mapProcessPath = new Map<Id, List<SVMXC__ServiceMax_Config_Data__c>>();
        Map<Id, SVMXC__ServiceMax_Processes__c> lstFulfillmentRule =  new Map<Id, SVMXC__ServiceMax_Processes__c>();
        
        //COMM_PerformanceUtils.start('011:a:001: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc _ QueryProc');
        List<String> queryFields = new List<String> {'SVMXC__Sequence__c', 'SVMXC__Source_Object_Name__c', 'SVMXC__IsDefault__c', 'SVMXC__Default_Location__c', 'SVMXC__Submodule__c', 'SVMXC__Process__c', 'SVMXC__Parent_Object_Criteria__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        lstFulfillmentRule.putAll([Select SVMXC__Sequence__c, SVMXC__Source_Object_Name__c, SVMXC__IsDefault__c, SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name, SVMXC__Submodule__c, SVMXC__Process__c, SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where SVMXC__Process__c = :fulfillmentProcess.Id and SVMXC__Rule_Type__c = 'FulFillment Path' and RecordType.Name = 'SVMX Rule' order by SVMXC__Sequence__c]);// 
        
        //COMM_PerformanceUtils.stop('011:a:001: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc _ QueryProc');
        
        system.debug('Fulfillment Rule: ' + lstFulfillmentRule);
        
        //COMM_PerformanceUtils.start('011:a:002: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc _ QueryConfData');
        
        queryFields = new List<String> {'SVMXC__Sequence__c', 'SVMXC__Location__c', 'SVMXC__Dispatch_Process__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        List<SVMXC__ServiceMax_Config_Data__c> lstFulfillmentPath = [Select SVMXC__Sequence__c, SVMXC__Location__c, SVMXC__Location__r.Name, SVMXC__Location__r.SVMXC__IsGood_Stock__c, SVMXC__Dispatch_Process__c from SVMXC__ServiceMax_Config_Data__c where SVMXC__Dispatch_Process__c = : lstFulfillmentRule.keySet() and RecordType.Name = 'Fulfillment Path' order by SVMXC__Sequence__c desc]; //SDL-SVMX-READ-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('011:a:002: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc _ QueryConfData');
        
        system.debug('Fulfillment Path: ' + lstFulfillmentPath);
        
        //COMM_PerformanceUtils.start('011:a:003: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc _ LoopLstFulfillmentPath');
        for(SVMXC__ServiceMax_Config_Data__c path: lstFulfillmentPath)
        {
            if(path.SVMXC__Location__r.SVMXC__IsGood_Stock__c != NULL && path.SVMXC__Location__r.SVMXC__IsGood_Stock__c == true)
            {
                setAvailableLocations.add(path.SVMXC__Location__c);
                SVMXC__ServiceMax_Processes__c fulfillmentRule = lstFulfillmentRule.get(path.SVMXC__Dispatch_Process__c);
                List<SVMXC__ServiceMax_Config_Data__c> lstPathLocation = new List<SVMXC__ServiceMax_Config_Data__c>();
                lstPathLocation.add(path);
                if(mapProcessPath.containsKey(fulfillmentRule.Id) && mapProcessPath.get(fulfillmentRule.Id) != NULL)
                    lstPathLocation.addAll(mapProcessPath.get(fulfillmentRule.Id));
                mapProcessPath.put(fulfillmentRule.Id, lstPathLocation);
            }
        }
        system.debug('mapProcessPath'+mapProcessPath);
        //COMM_PerformanceUtils.stop('011:a:003: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc _ LoopLstFulfillmentPath');
        //COMM_PerformanceUtils.start('011:a:004: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc _ LoopLstFulfillmentRule');
        
        for(Id ruleId: mapProcessPath.keySet())
        {
            if(lstFulfillmentRule.get(ruleId).SVMXC__Default_Location__c != NULL)
            {
                setAvailableLocations.add(lstFulfillmentRule.get(ruleId).SVMXC__Default_Location__c);
                locationNames.put(lstFulfillmentRule.get(ruleId).SVMXC__Default_Location__c, lstFulfillmentRule.get(ruleId).SVMXC__Default_Location__r.Name);
            }
            response.put(lstFulfillmentRule.get(ruleId), mapProcessPath.get(ruleId));
        }
        system.debug('response'+response);
        //COMM_PerformanceUtils.stop('011:a:004: FuncINTF_APL_GetAvailableStock _ FuncGetProdExpLocForProc _ LoopLstFulfillmentRule');
        return response;
    }
    
    public Map<String, Integer> getAvailableStock(set<Id> locationId, set<Id> productId, boolean createStockIfDoesnotExist)
    {
        Map<String, Integer> response = new Map<String, Integer>();
        List<SVMXC__Product_Stock__c> lstProductStock = new List<SVMXC__Product_Stock__c>();
        Map<String, List<SVMXC__Product_Stock__c>> mapLocationProductStock = new Map<String, List<SVMXC__Product_Stock__c>>();
        // Get available stock
        //COMM_PerformanceUtils.start('011:f:001: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncgetProductStock');
        
        lstProductStock = getProductStock(locationId, productId);
        
        //COMM_PerformanceUtils.stop('011:f:001: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncgetProductStock');
        //COMM_PerformanceUtils.start('011:f:002: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncCreateProdIfdoesnotExist');
        if(createStockIfDoesnotExist == true && (locationId.size() * productId.size() > lstProductStock.size()))
        {
            createProductIfdoesnotExist(locationId, productId, lstProductStock);
        }
        
        //COMM_PerformanceUtils.stop('011:f:002: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncCreateProdIfdoesnotExist');
        
        //COMM_PerformanceUtils.start('011:f:003: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ LoopProdStock');
        for(SVMXC__Product_Stock__c productStock: lstProductStock)
        {
            String key = productStock.SVMXC__Location__c + ':' + productStock.SVMXC__Product__c;
            List<SVMXC__Product_Stock__c> lstTempProductStock = new List<SVMXC__Product_Stock__c>();
            lstTempProductStock.add(productStock);
            if(mapLocationProductStock.containsKey(key) && mapLocationProductStock.get(key) != null)
                lstTempProductStock.addAll(mapLocationProductStock.get(key));
            mapLocationProductStock.put(key, lstTempProductStock);
        }
        //COMM_PerformanceUtils.stop('011:f:003: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ LoopProdStock');
        //COMM_PerformanceUtils.start('011:f:004: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ LoopProdStockLoc');
        for(String key: mapLocationProductStock.keySet())
        {
            response.put(key, getAvailableStock(mapLocationProductStock.get(key)));
        }
        //COMM_PerformanceUtils.stop('011:f:004: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ LoopProdStockLoc');
        return response;
    }
    
    public void createProductIfdoesnotExist(set<Id> locationId, set<Id> productId, List<SVMXC__Product_Stock__c> lstProductStock)
    {
        Map<Id, set<Id>> lstLocationProduct = new Map<Id, set<Id>>();
        List<SVMXC__Product_Stock__c> creaateNewProductStock = new List<SVMXC__Product_Stock__c>(); 
        
        //COMM_PerformanceUtils.start('011:f:002:a: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncCreateProdIfdoesnotExist _ LoopProdStock');
        
        for(SVMXC__Product_Stock__c productStock: lstProductStock)
        {
            set<Id> lstProducts = new set<Id>();
            lstProducts.add(productStock.SVMXC__Product__c);
            if(lstLocationProduct != NULL && lstLocationProduct.get(productStock.SVMXC__Location__c) != NULL)
                lstProducts.addAll(lstLocationProduct.get(productStock.SVMXC__Location__c));
            lstLocationProduct.put(productStock.SVMXC__Location__c, lstProducts);
        }
        //COMM_PerformanceUtils.stop('011:f:002:a: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncCreateProdIfdoesnotExist _ LoopProdStock');
        
        //COMM_PerformanceUtils.start('011:f:002:b: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncCreateProdIfdoesnotExist _ LoopLocId');
        
        for(Id locId: locationId)
        {
            set<Id> avaialbleProd = lstLocationProduct.get(locId);
            for(Id prodId: productId)
            {
                if(avaialbleProd == NULL || !avaialbleProd.contains(prodId))
                {
                    SVMXC__Product_Stock__c prdStockAvail = new SVMXC__Product_Stock__c(SVMXC__Location__c = locId, SVMXC__Product__c = prodId, SVMXC__Quantity2__c = 0, SVMXC__Status__c = 'Available');
                    creaateNewProductStock.add(prdStockAvail);
                    SVMXC__Product_Stock__c prdStockAlloc = new SVMXC__Product_Stock__c(SVMXC__Location__c = locId, SVMXC__Product__c = prodId, SVMXC__Quantity2__c = 0, SVMXC__Status__c = 'Allocated');
                    creaateNewProductStock.add(prdStockAlloc);
                }
            }
        }
        
        //COMM_PerformanceUtils.stop('011:f:002:b: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncCreateProdIfdoesnotExist _ LoopLocId');
    }
    
    public Integer getAvailableStock(List<SVMXC__Product_Stock__c> lstProductStock)
    {
        Decimal availableCount = 0;
        for(SVMXC__Product_Stock__c stock: lstProductStock)
        {
            availableCount += stock.SVMXC__Available_Qty__c;
        }
        return availableCount.intValue();
    }
    
    public List<SVMXC__Product_Stock__c> getProductStock(set<Id> locationId, set<Id> productId)
    {
        List<SVMXC__Product_Stock__c> lstProductStock = new List<SVMXC__Product_Stock__c>();
        // Get available stock
        //COMM_PerformanceUtils.start('011:f:001:a: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncgetProductStock _ QueryProdStock');
        List<String> queryFields = new List<String> {'Id', 'SVMXC__Location__c', 'SVMXC__Available_Qty__c', 'SVMXC__Product__c', 'SVMXC__Quantity2__c', 'SVMXC__Status__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        lstProductStock = [Select Id, SVMXC__Location__c, SVMXC__Available_Qty__c, SVMXC__Product__c, SVMXC__Quantity2__c, SVMXC__Status__c from SVMXC__Product_Stock__c where SVMXC__Location__c IN : locationId and SVMXC__Product__c IN : productId and SVMXC__Status__c = 'Available']; //SDL-SVMX-READ-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('011:f:001:a: FuncINTF_APL_GetAvailableStock _ FuncGetAvailableStock _ FuncgetProductStock _ QueryProdStock');
        
        return lstProductStock;
    }
    
    // Save Action
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse saveFulfillmentOrder(String strRecordId, INTF_WebServicesDef.INTF_SFMRequest request)
    {
        //COMM_PerformanceUtils.start('2.a.SAVE-FULFILLMENT _ VariableInitialization');
        system.debug('request'+request);
        SFM_Utils utils = new SFM_Utils();
        SVMXC.INTF_applyMapping Applymapping = new SVMXC.INTF_applyMapping(); 
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        response.success = true;
        Map<Id, List<Id>> mapProductLineIds = new Map<Id, List<Id>>();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForResponse = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        Map<Id, List<SVMXC__RMA_Shipment_Line__c>> mapLocationOrderLines = new Map<Id, List<SVMXC__RMA_Shipment_Line__c>>();
        lstSVMXMap = request.valueMap;
        List<String> recTypeNames = new List<String>();
        recTypeNames.add('SVMXC__RMA_Shipment_Order__c~Shipment');
        recTypeNames.add('SVMXC__RMA_Shipment_Line__c~Shipment');
        recTypeNames.add('SVMXC__Stock_History__c~Stock History');
        Map<String, Id> mapRecType_Map = new Map<String, Id>();
        map<Id, Decimal> mapShipLineAllocatedQty = new map<Id, Decimal>();
        SVMXC__ServiceMax_Processes__c objSVMXProcess;
        String strProcessId;
        String idForHeaderMapping;
        String idForChildMapping;
        mapRecType_Map = utils.getRecordTypes(recTypeNames);
        stockHistoryRtypeId = mapRecType_Map.get('SVMXC__Stock_History__c~Stock History');
        
        SVMXC.INTF_WebServicesDef.SVMXMap mapExistingShipmentLocations = new SVMXC.INTF_WebServicesDef.SVMXMap();
        mapExistingShipmentLocations.valueMap = new List<SVMXC.INTF_WebServicesDef.SVMXMap>();
        map<String, String> mapExistingShipmentLocation = new map<String, String>();
        lstSVMXMap = request.valueMap;
        
        //COMM_PerformanceUtils.stop('2.a.SAVE-FULFILLMENT _ VariableInitialization');
        
        if(lstSVMXMap.size() > 0)
        {
            //COMM_PerformanceUtils.start('2.b.SAVE-FULFILLMENT _ PopulatingMapExistingShipmentLoc');
            
            for(Integer i = 0;i<lstSVMXMap.size();i++)
            {
                if(lstSVMXMap[i].key.toUppercase() == 'SVMX_PROCESSID')
                    strProcessId = lstSVMXMap[i].value;
                if(lstSVMXMap[i].key.toUppercase() == 'EXISTINGSHIPMENTLOCATIONS')
                    mapExistingShipmentLocations.valueMap.addAll(lstSVMXMap[i].valueMap); 
            }
            
            //COMM_PerformanceUtils.stop('2.b.SAVE-FULFILLMENT _ PopulatingMapExistingShipmentLoc');
        }
        
        //COMM_PerformanceUtils.start('2.c.SAVE-FULFILLMENT _ LoopingMapExistingShipmentLocations');
        
        for(SVMXC.INTF_WebServicesDef.SVMXMap shipLoc: mapExistingShipmentLocations.valueMap)
        {
            mapExistingShipmentLocation.put(shipLoc.key, shipLoc.value);
        }
        
        //COMM_PerformanceUtils.stop('2.c.SAVE-FULFILLMENT _ LoopingMapExistingShipmentLocations');
        
        if(strProcessId != null && strProcessId.length() > 0)
        {
            //COMM_PerformanceUtils.start('2.d.SAVE-FULFILLMENT _ QueryingServiceMaxProcesses');
        
            List<String> queryFields = new List<String> {'Id', 'SVMXC__Node_Parent__c', 'SVMXC__Final_Exception_Process__c'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            objSVMXProcess = [select Id, SVMXC__Node_Parent__c, SVMXC__Final_Exception_Process__c from SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strProcessId or id =: strProcessId]; //SDL-SVMX-READ-FLS-ENFORCED
            
            //COMM_PerformanceUtils.stop('2.d.SAVE-FULFILLMENT _ QueryingServiceMaxProcesses');
            
        }
        idForHeaderMapping = objSVMXProcess.SVMXC__Node_Parent__c;
        idForChildMapping = objSVMXProcess.SVMXC__Final_Exception_Process__c;
        
        // Identify depo for all the locations
        Map<Id, List<Id>> mapDepoDepoChilds = new Map<Id, List<Id>>();
        Map<Id, Id> mapDepoChildsDepo = new Map<Id, Id>();
        Map<Id, String> mapDepoName = new Map<Id, String>();
        List<SVMXC__Site__c> lstAllLocations = new List<SVMXC__Site__c>();
        set<Id> lstAvailableLocations = new set<Id>();
        
        //COMM_PerformanceUtils.start('2.e.SAVE-FULFILLMENT _ LoopingAplOrder');
        
        for(SVMXC.INTF_WebServicesDef.APL_OrderLineCollection line: request.aplOrder.orderLines)
        {
            for(SVMXC.INTF_WebServicesDef.APL_SerialCollection availability: line.serialNumbers)
            {
                lstAvailableLocations.add(availability.uniqueId);
            }
        }
        
        //COMM_PerformanceUtils.stop('2.e.SAVE-FULFILLMENT _ LoopingAplOrder');
        
        //COMM_PerformanceUtils.start('2.f.SAVE-FULFILLMENT _ QueryingSite');
        
        List<String> queryFields = new List<String> {'Id', 'SVMXC__Parent__c', 'SVMXC__Parent__r.Name'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        lstAllLocations = [Select Id, SVMXC__Parent__c, SVMXC__Parent__r.Name from SVMXC__Site__c where Id IN : lstAvailableLocations]; //SDL-SVMX-READ-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('2.f.SAVE-FULFILLMENT _ QueryingSite');
        
        //COMM_PerformanceUtils.start('2.g.SAVE-FULFILLMENT _ LoopingLstAllLocations');
        
        for(SVMXC__Site__c location: lstAllLocations)
        {
            mapDepoName.put(location.SVMXC__Parent__c, location.SVMXC__Parent__r.Name);
            List<Id> childLocations = new List<Id>();
            childLocations.add(location.Id);
            
            if(mapDepoDepoChilds.get(location.SVMXC__Parent__c) != NULL)
            childLocations.addAll(mapDepoDepoChilds.get(location.SVMXC__Parent__c));
            
            mapDepoDepoChilds.put(location.SVMXC__Parent__c, childLocations);
            mapDepoChildsDepo.put(location.Id, location.SVMXC__Parent__c);
        }
        
        //COMM_PerformanceUtils.stop('2.g.SAVE-FULFILLMENT _ LoopingLstAllLocations');
        
        //COMM_PerformanceUtils.start('2.h.SAVE-FULFILLMENT _ LoopingMapDepoDepoChilds');
        
        // Adding depo as child to itself
        for(Id depoId: mapDepoDepoChilds.keySet())
        {
            List<Id> childLocations = new List<Id>();
            childLocations.add(depoId);
            
            if(mapDepoDepoChilds.get(depoId) != NULL)
            childLocations.addAll(mapDepoDepoChilds.get(depoId));
            
            mapDepoDepoChilds.put(depoId, childLocations);
        }
        
        //COMM_PerformanceUtils.stop('2.h.SAVE-FULFILLMENT _ LoopingMapDepoDepoChilds');
        
        //COMM_PerformanceUtils.start('2.i.SAVE-FULFILLMENT _ LoopingToPopulateProductLine');
        
        for(SVMXC.INTF_WebServicesDef.SVMXMap req: request.valueMap)
        {
            // Populate the product vs order list list from client
            if(req.key.toUppercase() == 'REQUESTATTRIBUTE')
            {
                for(SVMXC.INTF_WebServicesDef.SVMXMap addValues: req.valueMap)
                {
                    if(addValues.value != NULL)
                    {
                        List<Id> lineIds = new List<Id>();
                        lineIds.add(addValues.key);
                        if(mapProductLineIds.get(addValues.value) != NULL)
                            lineIds.addAll(mapProductLineIds.get(addValues.value));
                        mapProductLineIds.put(addValues.value, lineIds);
                    }
                }
            }
        }
        
        //COMM_PerformanceUtils.stop('2.i.SAVE-FULFILLMENT _ LoopingToPopulateProductLine');

        system.debug('Header: ' + request.aplOrder.orderHdrRecord);
        system.debug('ProductLine Ids: ' + mapProductLineIds);
        system.debug('Existing Shipment Locations: ' + mapExistingShipmentLocations);
        String StrOrderLineFields = ' SVMXC__Master_Order_Line__c, SVMXC__Warehouse__c, SVMXC__Serial_Number__c, SVMXC__Serial_Number_List__c, SVMXC__Sales_Order_Number__c, SVMXC__Route_Stop__c, SVMXC__Route_Card__c, SVMXC__Reconciliation_Action__c, SVMXC__RMA_Shipment_Order__c, SVMXC__Product__c, SVMXC__Expected_Quantity2__c, SVMXC__Delivery_Location__c, SVMXC__Actual_Quantity2__c, RecordTypeId, Name, Id, SVMXC__Product__r.Name, SVMXC__Product__r.ProductCode ';
        
        //COMM_PerformanceUtils.start('2.j.SAVE-FULFILLMENT _ QueryingRMAShipmentLine');
        
        //Get complete RMA header information
        String strHeaderFields = '';
        map<String,String> mapAPINameLablePO = new map<String,String>();
        map<String, Schema.SObjectField> mapPOField = Schema.SObjectType.SVMXC__RMA_Shipment_Order__c.fields.getMap();
        //COMM_PerformanceUtils.start('001:e: VARIABLE-DECLARATION _ LoopingRmaSO');
        if(mapPOField.size() > 0)
        {
            //Commented as part of story BAC-3591 and added COMM_Utils_V2
            //SVMXC.COMM_Utils commUtils = new SVMXC.COMM_Utils();
            SVMXC.COMM_Utils_V2 commUtils = new SVMXC.COMM_Utils_V2();
            for(String str:mapPOField.keyset())
            {
                mapAPINameLablePO.put(mapPOField.get(str).getDescribe().getName(),mapPOField.get(str).getDescribe().getLabel());
                strHeaderFields =  commUtils.SVMX_getFieldNamesFromList(commUtils.SVMX_getFieldList(mapPOField,true));
                if(strHeaderFields != null && strHeaderFields.length() > 0)
                    strHeaderFields += ', SVMXC__Source_Location__r.Name, SVMXC__Destination_Location__r.Name';
            }
        }
        try
        {
            //COMM_PerformanceUtils.start('004: QueryingRmaSO');
            
            if(strRecordId != null && strRecordId.length() > 0)
            {
                queryFields = strHeaderFields.split(',');
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                String strQuery = 'Select '+ strHeaderFields +' From SVMXC__RMA_Shipment_Order__c where id =: strRecordId and RecordType.Name = \'RMA\' and SVMXC__On_Hold__c = false';
                system.debug('Query'+strQuery);
                request.aplOrder.orderHdrRecord =  database.query(strQuery);
            }
            //COMM_PerformanceUtils.stop('004: QueryingRmaSO');
        }
        catch(exception ex)
        {
            response.success = false;
            response.message = system.label.APL003_TAG052;
            //COMM_PerformanceUtils.stop('004: QueryingRmaSO');
            //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
            return response;
        }

        queryFields = StrOrderLineFields.split(',');
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        String query = 'Select ' +StrOrderLineFields+ '  From SVMXC__RMA_Shipment_Line__c  where SVMXC__RMA_Shipment_Order__c =: strRecordId';
        List<SVMXC__RMA_Shipment_Line__c> lstOrderLines = Database.query(query);
        
        //COMM_PerformanceUtils.stop('2.j.SAVE-FULFILLMENT _ QueryingRMAShipmentLine');
        
        mapLocationOrderLines = parseOrderLineFromProductLocation(lstOrderLines, request.aplOrder.orderLines, mapDepoChildsDepo, mapProductLineIds);
        system.debug('Location OrderLines: ' + mapLocationOrderLines);
        List<SVMXC__RMA_Shipment_Order__c> lstShipmentOrder = new List<SVMXC__RMA_Shipment_Order__c>();
        List<SVMXC__RMA_Shipment_Order__c> lstExistingShipmentOrder = new List<SVMXC__RMA_Shipment_Order__c>();
        map<Id, SVMXC__RMA_Shipment_Order__c> mapShipmentOrder = new map<Id, SVMXC__RMA_Shipment_Order__c>();
        
        //COMM_PerformanceUtils.start('2.k.SAVE-FULFILLMENT _ QueryingRMAShipmentOrder');
        queryFields = new List<String> {'Id', 'SVMXC__Source_Location__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        mapShipmentOrder.putAll([Select Id, SVMXC__Source_Location__c from SVMXC__RMA_Shipment_Order__c where Id IN: mapExistingShipmentLocation.values()]);
        
        //COMM_PerformanceUtils.stop('2.k.SAVE-FULFILLMENT _ QueryingRMAShipmentOrder');
        
        system.debug('ShipmentOrder: ' + mapShipmentOrder);
        set<Id> shipmentOrderIDs = new set<Id>();
        map<Id, Id> mapShipmentOrderDepo = new map<Id, Id>();
        
        // For each depo create shipment order
        
        //COMM_PerformanceUtils.start('2.l.SAVE-FULFILLMENT _ LoopToCreateShipmentOrderForEachDepo');
        
        
        for(Id depoLocation: mapDepoDepoChilds.keySet())
        {
            if(mapDepoDepoChilds.get(depoLocation) != NULL)
            {
                boolean isValid = false;
                for(Id childId: mapDepoDepoChilds.get(depoLocation))
                {
                    if(mapLocationOrderLines.get(childId) != NULL && mapLocationOrderLines.get(childId).size() > 0)
                    {
                        isValid = true;
                    }
                }
                if(isValid == false)
                    continue;
            }
            else
                continue;
            system.debug('Depo Location: ' + depoLocation);
            // If the shipment has already been created, get the existing shipment order don't create new one
            SVMXC__RMA_Shipment_Order__c shipmentOrder = new SVMXC__RMA_Shipment_Order__c();
            if(mapExistingShipmentLocation.get(depoLocation) != NULL)
            {
                shipmentOrder = mapShipmentOrder.get(mapExistingShipmentLocation.get(depoLocation));
                lstExistingShipmentOrder.add(shipmentOrder);
            }
            else
            {
                shipmentOrder.RecordTypeId = mapRecType_Map.get('SVMXC__RMA_Shipment_Order__c~Shipment');
                shipmentOrder.SVMXC__Source_Location__c = depoLocation;
                lstShipmentOrder.add(shipmentOrder);
            }
            system.debug('Shipment Order: ' + lstShipmentOrder);
        }
        
        //COMM_PerformanceUtils.stop('2.l.SAVE-FULFILLMENT _ LoopToCreateShipmentOrderForEachDepo');
        
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstShipmentOrder, COMM_SecurityUtils.Access.Createable ) ) {
            insert lstShipmentOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        lstShipmentOrder.addAll(lstExistingShipmentOrder);
        SVMXC.INTF_WebServicesDef.SVMXMap mapResponseKeyValues = new SVMXC.INTF_WebServicesDef.SVMXMap();
        mapResponseKeyValues.key = 'MAPKEYVALUES';
        mapExistingShipmentLocations.key = 'EXISTINGSHIPMENTLOCATIONS';
        
        //COMM_PerformanceUtils.start('2.m.SAVE-FULFILLMENT _ LoopingShipmentOrder');
        
        for(SVMXC__RMA_Shipment_Order__c shipOrder: lstShipmentOrder)
        {
            SVMXC.INTF_WebServicesDef.SVMXMap keyValue = new SVMXC.INTF_WebServicesDef.SVMXMap(shipOrder.SVMXC__Source_Location__c, shipOrder.Id);
            mapExistingShipmentLocations.valueMap.add(keyValue);
        }
        
        //COMM_PerformanceUtils.stop('2.m.SAVE-FULFILLMENT _ LoopingShipmentOrder');
        
        mapResponseKeyValues.valueMap.add(mapExistingShipmentLocations);
        lstSVMXMapForResponse.add(mapResponseKeyValues);
        // Apply mapping for header
        // Schema information
        Map <String, Schema.SObjectType> schemaMap = new Map <String, Schema.SObjectType>();
        Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        //COMM_PerformanceUtils.start('2.n.SAVE-FULFILLMENT _ LoopingSObjectTypeVal');
        
        for(Schema.SObjectType s : gd.values())
        {
            schemaMap.put(s.getDescribe().getName(),s);
        }
        
        //COMM_PerformanceUtils.stop('2.n.SAVE-FULFILLMENT _ LoopingSObjectTypeVal');
        
        
        
        
        if(idForHeaderMapping != NULL && lstShipmentOrder.size() > 0)
        {
            map<String, SObject> mapShipmentOrderTemp = new map<String, SObject>();
            map<String, SObject> mapTempShipmentOrder = new map<String, SObject>();
            SVMXC__RMA_Shipment_Order__c objShipment = NULL;
            
            //COMM_PerformanceUtils.start('2.o.SAVE-FULFILLMENT _ LoopingRMAShipmentOrder');
            
            for(SVMXC__RMA_Shipment_Order__c shipOrder: lstShipmentOrder)
            {
                mapShipmentOrderDepo.put(shipOrder.Id, shipOrder.SVMXC__Source_Location__c);
                //mapShipmentOrderTemp.put(shipOrder.Id, shipOrder);
            }
            system.debug('mapShipmentOrderTemp'+mapShipmentOrderTemp);
            //COMM_PerformanceUtils.stop('2.o.SAVE-FULFILLMENT _ LoopingRMAShipmentOrder');
            
            lstShipmentOrder = Applymapping.getApplyMapping(lstShipmentOrder,idForHeaderMapping,request.aplOrder.orderHdrRecord.Id, false, schemaMap);
            system.debug('lstShipmentOrder'+lstShipmentOrder);
            //if(mapTempShipmentOrder != null && mapTempShipmentOrder.keySet() != null && mapTempShipmentOrder.keySet().size() > 0)
                //lstShipmentOrder = mapTempShipmentOrder.values();
            // If mapping currups your source location, get it from temp stored cache
            
            //COMM_PerformanceUtils.start('2.p.SAVE-FULFILLMENT _ LoopingRMASOtoAlterSourceLoc');
            
            for(SVMXC__RMA_Shipment_Order__c shipOrder: lstShipmentOrder)
            {
                shipOrder.SVMXC__Source_Location__c = mapShipmentOrderDepo.get(shipOrder.Id);
            }
            
            //COMM_PerformanceUtils.stop('2.p.SAVE-FULFILLMENT _ LoopingRMASOtoAlterSourceLoc');
        }
        
        
        
        system.debug('Header: ' + request.aplOrder.orderHdrRecord);
        
        
        // Setup default values on shipment
        
        
        //COMM_PerformanceUtils.start('2.q.SAVE-FULFILLMENT _ LoopingtoSetupDefValonShipment');
        
        for(SVMXC__RMA_Shipment_Order__c shipmentOrder: lstShipmentOrder)
        {
            if(!mapExistingShipmentLocation.containsKey(shipmentOrder.SVMXC__Source_Location__c) || mapExistingShipmentLocation.get(shipmentOrder.SVMXC__Source_Location__c) == NULL)
            {
                shipmentOrder.SVMXC__Master_Order__c = request.aplOrder.orderHdrRecord.Id;
                shipmentOrder.SVMXC__Shipment_Reference__c = request.aplOrder.orderHdrRecord.Id; //Added by Amar due to defect no 004173
                //shipmentOrder.SVMXC__Order_Type__c = 'Return'; //Commented by Amar due to defect 004317.
                if(request.aplOrder.orderHdrRecord.SVMXC__Source_Location__c != NULL)
                {
                    shipmentOrder.SVMXC__Destination_Location__c = request.aplOrder.orderHdrRecord.SVMXC__Source_Location__c;
                }
                else
                {
                    shipmentOrder.SVMXC__Destination_Location__c = null;
                }
                if(request.aplOrder.orderHdrRecord.SVMXC__Source_Street__c != NULL)
                    shipmentOrder.SVMXC__Destination_Street__c = request.aplOrder.orderHdrRecord.SVMXC__Source_Street__c;
                if(request.aplOrder.orderHdrRecord.SVMXC__Source_City__c != NULL)
                    shipmentOrder.SVMXC__Destination_City__c = request.aplOrder.orderHdrRecord.SVMXC__Source_City__c;
                if(request.aplOrder.orderHdrRecord.SVMXC__Source_State__c != NULL)
                    shipmentOrder.SVMXC__Destination_State__c = request.aplOrder.orderHdrRecord.SVMXC__Source_State__c;
                if(request.aplOrder.orderHdrRecord.SVMXC__Source_Country__c != NULL)
                    shipmentOrder.SVMXC__Destination_Country__c = request.aplOrder.orderHdrRecord.SVMXC__Source_Country__c;
                if(request.aplOrder.orderHdrRecord.SVMXC__Source_Zip__c != NULL)
                    shipmentOrder.SVMXC__Destination_Zip__c = request.aplOrder.orderHdrRecord.SVMXC__Source_Zip__c;
            }
        }
        
        //COMM_PerformanceUtils.stop('2.q.SAVE-FULFILLMENT _ LoopingtoSetupDefValonShipment');
        
        //COMM_PerformanceUtils.start('2.r.SAVE-FULFILLMENT _ UpdateRMAShipmentOrder');
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( lstShipmentOrder, COMM_SecurityUtils.Access.Updateable ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        } 
        update lstShipmentOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('2.r.SAVE-FULFILLMENT _ UpdateRMAShipmentOrder');
        
        system.debug('Shipment Order: ' + lstShipmentOrder);
        
        List<SVMXC__RMA_Shipment_Line__c> lstShipmentOrderLines = new List<SVMXC__RMA_Shipment_Line__c>();
        Map<Id, Integer> ShipmentOrderQty = new Map<Id, Integer>();
        Map<Id, Id> ShipmentOrderLineLocation = new Map<Id, Id>();
        
        //COMM_PerformanceUtils.start('2.s.SAVE-FULFILLMENT _ LoopingSO');
        
        for(SVMXC__RMA_Shipment_Order__c objShipmentOrder: lstShipmentOrder)
        {
            shipmentOrderIDs.add(objShipmentOrder.Id);
            if(mapDepoDepoChilds.get(objShipmentOrder.SVMXC__Source_Location__c) != NULL)
            {
            
                //COMM_PerformanceUtils.start('2.s.1.SAVE-FULFILLMENT _ LoopingmapDepoDepoChilds');
                
                for(Id location: mapDepoDepoChilds.get(objShipmentOrder.SVMXC__Source_Location__c))
                {
                
                    //COMM_PerformanceUtils.start('2.s.1.a.SAVE-FULFILLMENT _ LoopingmapLocOrderLines');
                
                    if(mapLocationOrderLines.get(location) != NULL)
                    for(SVMXC__RMA_Shipment_Line__c shipLines: mapLocationOrderLines.get(location))
                    {
                        shipLines.SVMXC__RMA_Shipment_Order__c = objShipmentOrder.Id;
                        // If delivery location is header source location then clear delivery location
                        // if(mapDepoDepoChilds.containsKey(shipLines.SVMXC__Delivery_Location__c))
                        
                        system.debug('shipLines: ' + shipLines.SVMXC__Delivery_Location__c + objShipmentOrder.SVMXC__Source_Location__c + shipLines);
                        if(objShipmentOrder.SVMXC__Source_Location__c == shipLines.SVMXC__Delivery_Location__c)
                            shipLines.SVMXC__Delivery_Location__c = NULL;
                        shipLines.RecordTypeId = mapRecType_Map.get('SVMXC__RMA_Shipment_Line__c~Shipment');
                        Integer qty = (shipLines.SVMXC__Fulfillment_Qty__c).intValue();
                        
                        lstShipmentOrderLines.add(shipLines);
                        // This quantity is used whole displaying shipment order lines
                        if(qty == NULL)
                            qty = 0;
                        if(ShipmentOrderQty.get(objShipmentOrder.Id) != NULL)
                            qty += ShipmentOrderQty.get(objShipmentOrder.Id);
                        ShipmentOrderQty.put(objShipmentOrder.Id, qty);
                    }
                    
                    //COMM_PerformanceUtils.stop('2.s.1.a.SAVE-FULFILLMENT _ LoopingmapLocOrderLines');
                    
                }
                
                //COMM_PerformanceUtils.stop('2.s.1.SAVE-FULFILLMENT _ LoopingmapDepoDepoChilds');
            }
        }
        
        //COMM_PerformanceUtils.stop('2.s.SAVE-FULFILLMENT _ LoopingSO');
        
        //COMM_PerformanceUtils.start('2.t.SAVE-FULFILLMENT _ InsertinglstShipmentOrderLines');
        
        if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstShipmentOrderLines, COMM_SecurityUtils.Access.Createable ) ) {
            insert lstShipmentOrderLines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        } else {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        //COMM_PerformanceUtils.stop('2.t.SAVE-FULFILLMENT _ InsertinglstShipmentOrderLines');
        
        system.debug('Shipment OrderLines: ' + lstShipmentOrderLines);
        
        // Apply mapping for childs
        
        //COMM_PerformanceUtils.start('2.u.SAVE-FULFILLMENT _ ApplyMappingforChilds');
        system.debug('idForChildMapping'+idForChildMapping);
        if(idForChildMapping != NULL && lstShipmentOrderLines.size() > 0)
        { 
            map<String, SObject> mapShipmentOrderLine = new map<String, SObject>();
            map<String, SObject> mapTempShipmentOrderLine = new map<String, SObject>();
            for(SVMXC__RMA_Shipment_Line__c shipOrderLine: lstShipmentOrderLines)
            {
                mapShipLineAllocatedQty.put(shipOrderLine.Id, shipOrderLine.SVMXC__Fulfillment_Qty__c);
                ShipmentOrderLineLocation.put(shipOrderLine.Id, shipOrderLine.SVMXC__Delivery_Location__c);
                mapShipmentOrderLine.put(shipOrderLine.SVMXC__Master_Order_Line__c, shipOrderLine);
            }
            system.debug('mapTempShipmentOrderLine'+mapTempShipmentOrderLine);
            mapTempShipmentOrderLine = Applymapping.getApplyMappingCore(idForChildMapping, mapShipmentOrderLine, false, schemaMap);
            system.debug('mapTempShipmentOrderLine'+mapTempShipmentOrderLine);
            if(mapTempShipmentOrderLine != null && mapTempShipmentOrderLine.keySet() != null && mapTempShipmentOrderLine.keySet().size() > 0)
                lstShipmentOrderLines = mapTempShipmentOrderLine.values();
        }
        
        //COMM_PerformanceUtils.stop('2.u.SAVE-FULFILLMENT _ ApplyMappingforChilds');
        
        // Setup default values on shipment
        
        //COMM_PerformanceUtils.start('2.v.SAVE-FULFILLMENT _ LoopingtoSetupDefValonShipment');
        
        for(SVMXC__RMA_Shipment_Line__c shipmentOrderLine: lstShipmentOrderLines)
        {
            if(ShipmentOrderLineLocation.get(shipmentOrderLine.Id) != NULL)
            shipmentOrderLine.SVMXC__Delivery_Location__c = ShipmentOrderLineLocation.get(shipmentOrderLine.Id);
            //Clearing the route card and route stop references
            shipmentOrderLine.SVMXC__Route_Card__c = NULL;
            shipmentOrderLine.SVMXC__Route_Stop__c = NULL;
            shipmentOrderLine.SVMXC__Serial_Number_List__c = '';
            shipmentOrderLine.SVMXC__Serial_Number__c = null; 
        }
        
        //COMM_PerformanceUtils.stop('2.v.SAVE-FULFILLMENT _ LoopingtoSetupDefValonShipment');
        
        //COMM_PerformanceUtils.start('2.w.SAVE-FULFILLMENT _ UpdatelstShipmentOrderLines');
        system.debug('lstShipmentOrderLines'+lstShipmentOrderLines);
        
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( lstShipmentOrderLines, COMM_SecurityUtils.Access.Updateable ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }         
        update lstShipmentOrderLines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('2.w.SAVE-FULFILLMENT _ UpdatelstShipmentOrderLines');
        
        //COMM_PerformanceUtils.start('2.x.SAVE-FULFILLMENT _ UpdatelstShipmentOrder');
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( lstShipmentOrder, COMM_SecurityUtils.Access.Updateable ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }          
        update lstShipmentOrder; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('2.x.SAVE-FULFILLMENT _ UpdatelstShipmentOrder');
        
        //COMM_PerformanceUtils.start('2.y.SAVE-FULFILLMENT _ QueryingRMASO');
        
        queryFields = new List<String> {'Name', 'SVMXC__Source_Location__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        lstShipmentOrder = [Select Name, SVMXC__Source_Location__c from SVMXC__RMA_Shipment_Order__c where Id IN : shipmentOrderIDs]; //SDL-SVMX-READ-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('2.y.SAVE-FULFILLMENT _ QueryingRMASO');
        
        system.debug('Get ShipmentOrder: ' + lstShipmentOrder + ShipmentOrderQty);
        // Create shipment order line from shipment, just to display it on UI
        List<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> lstShipmentOrderToDisplay = new List<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
        
        //COMM_PerformanceUtils.start('2.z.SAVE-FULFILLMENT _ LoopingToCreateSOL');
        
        for(SVMXC__RMA_Shipment_Order__c shipmentOrder: lstShipmentOrder)
        {
            SVMXC.INTF_WebServicesDef.APL_OrderLineCollection wrpShipment = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
            if(ShipmentOrderQty.get(shipmentOrder.Id) == NULL)
                ShipmentOrderQty.put(shipmentOrder.Id, 0);
            SVMXC__RMA_Shipment_Line__c shipLineTemp = new SVMXC__RMA_Shipment_Line__c(SVMXC__RMA_Shipment_Order__c = shipmentOrder.Id, SVMXC__Sales_Order_Number__c = shipmentOrder.Name,SVMXC__Warehouse__c = mapDepoName.get(shipmentOrder.SVMXC__Source_Location__c), SVMXC__Fulfillment_Qty__c = ShipmentOrderQty.get(shipmentOrder.Id));
            wrpShipment.orderLineRecord = shipLineTemp;
            lstShipmentOrderToDisplay.add(wrpShipment);
        }
        
        //COMM_PerformanceUtils.stop('2.z.SAVE-FULFILLMENT _ LoopingToCreateSOL');
    
        //COMM_PerformanceUtils.start('2.za.SAVE-FULFILLMENT _ FuncCreateAllocatedStock');
    
        createAllocatedStock(request.aplOrder.orderHdrRecord, lstShipmentOrderLines, mapDepoDepoChilds, mapShipLineAllocatedQty);
        
        //COMM_PerformanceUtils.stop('2.za.SAVE-FULFILLMENT _ FuncCreateAllocatedStock');
        
        //COMM_PerformanceUtils.start('2.zb.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine');
        
        updateFulfillmentQuantityonRMALine(lstShipmentOrderLines);
        
        //COMM_PerformanceUtils.stop('2.zb.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine');
        
        response.valueMap = lstSVMXMapForResponse;
        response.aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        response.aplOrder.orderLines = lstShipmentOrderToDisplay;
        //response.APL_Order
        return response;
    }
    
    public void updateFulfillmentQuantityonRMALine(List<SVMXC__RMA_Shipment_Line__c> lstShipmentLines)
    {
        set<Id> setRMALineIds = new set<Id>();
        map<Id, Integer> mapFulfilledQty = new map<Id, Integer>();
        
        //COMM_PerformanceUtils.start('2.zb.1.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ LoopingRMASL');
        
        for(SVMXC__RMA_Shipment_Line__c shipLine: lstShipmentLines)
        {
            if(shipLine.SVMXC__Master_Order_Line__c != NULL)
                setRMALineIds.add(shipLine.SVMXC__Master_Order_Line__c);
            if(shipLine.SVMXC__Fulfillment_Qty__c != NULL)
            {
                Integer qty = (shipLine.SVMXC__Fulfillment_Qty__c).intValue();
                // This quantity is consolidated RMA line fulfilled quantity
                if(qty == NULL)
                    qty = 0;
                if(mapFulfilledQty.get(shipLine.SVMXC__Master_Order_Line__c) != NULL)
                    qty += mapFulfilledQty.get(shipLine.SVMXC__Master_Order_Line__c);
                mapFulfilledQty.put(shipLine.SVMXC__Master_Order_Line__c, qty);
            }
            // Setup the expected quantity as allocated quantity
            shipLine.SVMXC__Expected_Quantity2__c = shipLine.SVMXC__Fulfillment_Qty__c;
            shipLine.SVMXC__Fulfillment_Qty__c = 0;
        }
        
        //COMM_PerformanceUtils.stop('2.zb.1.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ LoopingRMASL');
        
        //COMM_PerformanceUtils.start('2.zb.2.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ UpdateSL');
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( lstShipmentLines, COMM_SecurityUtils.Access.Updateable ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }  
        update lstShipmentLines;
        
        //COMM_PerformanceUtils.stop('2.zb.2.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ UpdateSL');
        
        //COMM_PerformanceUtils.start('2.zb.3.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ QueryingRMASL');
        
        List<String> queryFields = new List<String> {'Id', 'SVMXC__Fulfillment_Qty__c'};
		if( !COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
		    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
		}
        List<SVMXC__RMA_Shipment_Line__c> lstRMALines = [Select Id, SVMXC__Fulfillment_Qty__c from SVMXC__RMA_Shipment_Line__c where Id IN : setRMALineIds]; //SDL-SVMX-READ-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('2.zb.3.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ QueryingRMASL');
        
        //COMM_PerformanceUtils.start('2.zb.4.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ LoopingRMASLToUpdateQty');
        
        for(SVMXC__RMA_Shipment_Line__c rmaLine: lstRMALines)
        {
            rmaLine.SVMXC__Fulfillment_Qty__c = mapFulfilledQty.get(rmaLine.Id);
        }
        
        //COMM_PerformanceUtils.stop('2.zb.4.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ LoopingRMASLToUpdateQty');
        
        //COMM_PerformanceUtils.start('2.zb.5.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ UpdateRMAL');
        if(!COMM_SecurityUtils.getInstance().verifyFieldAccess( lstRMALines, COMM_SecurityUtils.Access.Updateable ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        } 
        update lstRMALines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('2.zb.5.SAVE-FULFILLMENT _ FuncupdateFulfillmentQuantityonRMALine _ UpdateRMAL');
    }

    
    public void createAllocatedStock(SVMXC__RMA_Shipment_Order__c partsOrder, List<SVMXC__RMA_Shipment_Line__c> lstShipmentOrderLines, Map<Id, List<Id>> mapDepoDepoChilds, map<Id, Decimal> mapShipLineAllocatedQty)
    {
        system.debug('Product StockIds: ' + mapProductStockIds);
        list<SVMXC__Allocated_Stock__c> lstAllocatedStk = new list<SVMXC__Allocated_Stock__c>();
        
        //COMM_PerformanceUtils.start('2.za.1.SAVE-FULFILLMENT _ FuncCreateAllocatedStock _ LoopingShipmentOrderLine');
        
        for(SVMXC__RMA_Shipment_Line__c shipmentLine: lstShipmentOrderLines)
        {
            // Create allocated stock entry for product stock
            if(!mapDepoDepoChilds.containsKey(shipmentLine.SVMXC__Delivery_Location__c)) // locatio has to be a depo child not depo
            {
                String prodStkKey = shipmentLine.SVMXC__Delivery_Location__c + ':' + shipmentLine.SVMXC__Product__c;
                if(mapProductStockIds.containsKey(prodStkKey) && mapProductStockIds.get(prodStkKey) != NULL)
                {
                    SVMXC__Allocated_Stock__c allocatedStk = new SVMXC__Allocated_Stock__c(SVMXC__Sales_Repair_Order__c = partsOrder.Id, SVMXC__Sales_Repair_Order_Line__c = shipmentLine.SVMXC__Master_Order_Line__c, SVMXC__Shipment_Order__c = shipmentLine.SVMXC__RMA_Shipment_Order__c, SVMXC__Shipment_Order_Line__c = shipmentLine.Id);
                    if(mapShipLineAllocatedQty.get(shipmentLine.Id) != NULL)
                        allocatedStk.SVMXC__Allocated_Qty__c = mapShipLineAllocatedQty.get(shipmentLine.Id);
                    if(partsOrder.SVMXC__Company__c != NULL)
                        allocatedStk.SVMXC__Customer__c = partsOrder.SVMXC__Company__c;
                    allocatedStk.SVMXC__Product_Stock__c = mapProductStockIds.get(prodStkKey);
                    lstAllocatedStk.add(allocatedStk);
                }
            }
        }
        
        //COMM_PerformanceUtils.stop('2.za.1.SAVE-FULFILLMENT _ FuncCreateAllocatedStock _ LoopingShipmentOrderLine');
        
        system.debug('Allocated Stock: ' + lstAllocatedStk);
        
        //COMM_PerformanceUtils.start('2.za.2.SAVE-FULFILLMENT _ FuncCreateAllocatedStock _ InsertlstAllocatedStk');
        
        if(lstAllocatedStk.size() > 0) {
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstAllocatedStk, COMM_SecurityUtils.Access.Createable ) ) {
            	insert lstAllocatedStk; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
            
        //COMM_PerformanceUtils.stop('2.za.2.SAVE-FULFILLMENT _ FuncCreateAllocatedStock _ InsertlstAllocatedStk'); 
    }
    
    // Populate the shipment lines for location
    public Map<Id, List<SVMXC__RMA_Shipment_Line__c>> parseOrderLineFromProductLocation(List<SVMXC__RMA_Shipment_Line__c> lstOrderLines, List<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> productLines, Map<Id, Id> mapDepoChildsDepo, Map<Id, List<Id>> mapProductLineIds)
    {
        Map<Id, List<SVMXC__RMA_Shipment_Line__c>> response = new Map<Id, List<SVMXC__RMA_Shipment_Line__c>>();
        Map<String, Decimal> mapProductAllocated = new Map<String, Decimal>();
        Map<Id, set<Id>> mapProductLocation = new Map<Id, set<Id>>();
        Map<String, Integer> mapProductAvailable = new Map<String, Integer>();
        list<SVMXC__Product_Stock__c> lstAllocatedStocks = new list<SVMXC__Product_Stock__c>(); 
        list<SVMXC__Product_Stock__c> lstProductStock = new list<SVMXC__Product_Stock__c>();
        set<Id> lstAvailableLocations = new set<Id>();
        set<Id> lstAvailableProducts = new set<Id>();
        map<Id, List<SVMXC.INTF_WebServicesDef.APL_SerialCollection>> mapProductReplacementRequest = new  map<Id, List<SVMXC.INTF_WebServicesDef.APL_SerialCollection>>();
        map<Id, set<Id>> mapAvailableProductReplacements = new map<Id, set<Id>>();

        // Get all location and product and build a product replacement map
        for(SVMXC.INTF_WebServicesDef.APL_OrderLineCollection line: productLines)
        {
            set<Id> avaialbelProducts = new set<Id>();
            for(SVMXC.INTF_WebServicesDef.APL_SerialCollection allocation: line.serialNumbers)
            {
                avaialbelProducts.add(allocation.productId);
                lstAvailableProducts.add(allocation.productId);
                lstAvailableLocations.add(allocation.uniqueId);
                if(allocation.isProductReplacement == false)
                {
                    mapProductAllocated.put(allocation.uniqueId + ':' + line.orderLineRecord.SVMXC__Product__c + ':' + allocation.productId, allocation.allocatedCount);
                }
                else
                {
                    List<SVMXC.INTF_WebServicesDef.APL_SerialCollection> allocatedInfo = new List<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                    allocatedInfo.add(allocation);
                    if(mapProductReplacementRequest.get(allocation.productId) != NULL)
                        allocatedInfo.addAll(mapProductReplacementRequest.get(allocation.productId));
                    mapProductReplacementRequest.put(allocation.productId, allocatedInfo);
                    mapProductAllocated.put(allocation.uniqueId + ':' + line.orderLineRecord.SVMXC__Product__c + ':' + allocation.productId, allocation.allocatedCount);
                }
            }
            lstAvailableProducts.add(line.orderLineRecord.SVMXC__Product__c);
            mapAvailableProductReplacements.put(line.orderLineRecord.SVMXC__Product__c, avaialbelProducts);
        }
        
        if(mapProductAllocated != NULL)
        {
            Map<String, List<SVMXC__Product_Stock__c>> mapLocationProductStock = new Map<String, List<SVMXC__Product_Stock__c>>();
            // Get available stock
            lstProductStock = getProductStock(lstAvailableLocations, lstAvailableProducts);
            system.debug('Available Product: ' + lstAvailableLocations + lstAvailableProducts);
            system.debug('Product Stock: ' + lstProductStock);
            if(lstProductStock.size() > 0)
            {
                for(SVMXC__Product_Stock__c productStock: lstProductStock)
                {
                    String key = productStock.SVMXC__Location__c + ':' + productStock.SVMXC__Product__c;
                    List<SVMXC__Product_Stock__c> lstTempProductStock = new List<SVMXC__Product_Stock__c>();
                    mapProductStockIds.put(key, productStock.Id);
                    lstTempProductStock.add(productStock);
                    if(mapLocationProductStock.containsKey(key) && mapLocationProductStock.get(key) != null)
                        lstTempProductStock.addAll(mapLocationProductStock.get(key));
                    mapLocationProductStock.put(key, lstTempProductStock);
                }
                
                for(String key: mapLocationProductStock.keySet())
                {
                    mapProductAvailable.put(key, getAvailableStock(mapLocationProductStock.get(key)));
                }
            }
        }
        
        system.debug('Product Available: ' + mapProductAvailable);
        // Create allocation as on product stock
        
        for(SVMXC.INTF_WebServicesDef.APL_OrderLineCollection line: productLines)
        {
            set<Id> setLocations = new set<Id>();
            if(mapProductLineIds.get(line.orderLineRecord.SVMXC__Product__c) != NULL)
            for(Id lineId : mapProductLineIds.get(line.orderLineRecord.SVMXC__Product__c))
            {
                boolean isAllocationUpdated = false;
                Integer updatedAllocatedQty = 0;
                for(SVMXC.INTF_WebServicesDef.APL_SerialCollection availability: line.serialNumbers)
                {
                    setLocations.add(availability.uniqueId);
                }
            }
            mapProductLocation.put(line.orderLineRecord.SVMXC__Product__c, setLocations);
        }

        system.debug('Product Location: ' + mapProductLocation);
        system.debug('Product Allocated: ' + mapProductAllocated);
        List<SVMXC__RMA_Shipment_Line__c> shipmentOrderLines = new List<SVMXC__RMA_Shipment_Line__c>();
        List<SVMXC__RMA_Shipment_Line__c> lstActualShipmentOrderLines = new List<SVMXC__RMA_Shipment_Line__c>();
        for(SVMXC__RMA_Shipment_Line__c orderLine: lstOrderLines)
        {
            if(mapProductLocation.get(orderLine.SVMXC__Product__c) != NULL)
            {
                Id lineId = orderLine.Id;
                // Iterate for all product location
                for(Id locationId: mapProductLocation.get(orderLine.SVMXC__Product__c))
                {
                    if(mapAvailableProductReplacements != NULL && mapAvailableProductReplacements.size() > 0 && mapAvailableProductReplacements.get(orderLine.SVMXC__Product__c) != NULL)
                    {
                        for(Id productId: mapAvailableProductReplacements.get(orderLine.SVMXC__Product__c))
                        {
                            String locationProdKey = locationId + ':' + orderLine.SVMXC__Product__c + ':' + productId;
                            if(mapProductAllocated.get(locationProdKey) != NULL && mapProductAllocated.get(locationProdKey) > 0)
                            {
                                Decimal actualAllocated = mapProductAllocated.get(locationProdKey);
                                SVMXC__RMA_Shipment_Line__c objLine = new SVMXC__RMA_Shipment_Line__c();
                                //objLine = orderLine.clone(false,true);
                                //Check whether it's replacement or expected product
                                //if(orderLine.SVMXC__Product__c != productId)// If it's an replacement update the product
                                objLine.SVMXC__Product__c = productId;
                                objLine.SVMXC__Master_Order_Line__c = orderLine.Id;
                                objLine.SVMXC__Delivery_Location__c = locationId;
                                objLine.SVMXC__Expected_Quantity2__c = orderLine.SVMXC__Expected_Quantity2__c;
                                if(actualAllocated == orderLine.SVMXC__Expected_Quantity2__c)
                                {
                                    objLine.SVMXC__Fulfillment_Qty__c = actualAllocated;
                                    mapProductAllocated.put(locationProdKey, 0);
                                    lstActualShipmentOrderLines.add(objLine);
                                    break;
                                }
                                // If we allocate more than expected
                                if(actualAllocated > orderLine.SVMXC__Expected_Quantity2__c)
                                {
                                    objLine.SVMXC__Fulfillment_Qty__c = orderLine.SVMXC__Expected_Quantity2__c;
                                    mapProductAllocated.put(locationProdKey, actualAllocated - objLine.SVMXC__Expected_Quantity2__c);
                                    lstActualShipmentOrderLines.add(objLine);
                                    break;
                                }
                                // If we allocate less than expected
                                else
                                {
                                    objLine.SVMXC__Fulfillment_Qty__c = actualAllocated;
                                    mapProductAllocated.put(locationProdKey, 0);
                                    lstActualShipmentOrderLines.add(objLine);
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('Actual Shipment OrderLines: ' + lstActualShipmentOrderLines);
        for(SVMXC__RMA_Shipment_Line__c objLine: lstActualShipmentOrderLines)
        {
            //if(mapProductLocation.get(objLine.SVMXC__Product__c) != NULL)
            {
                Id locationId = objLine.SVMXC__Delivery_Location__c;
                String locationProdKey = locationId + ':' + objLine.SVMXC__Product__c;
                Decimal actualAllocated = 0;
                Boolean isClearLocation = false;
                Decimal allocated = objLine.SVMXC__Fulfillment_Qty__c;
                // Split line if partial availability exist
                // If product is available in product stock, and its value is greater than 0.
                if(mapProductAvailable.containsKey(locationProdKey) && mapProductAvailable.get(locationProdKey) != NULL)
                {
                    if(mapProductAvailable.get(locationProdKey) > 0)
                    {
                        actualAllocated = mapProductAvailable.get(locationProdKey);
                        if(allocated < actualAllocated)
                            actualAllocated = allocated;
                        if(actualAllocated < 0)
                            actualAllocated = 0;
                    }
                    else
                    {
                        isClearLocation = true;
                    }
                }
                else
                {
                    isClearLocation = true;
                }
                if(allocated == 0)
                {
                    continue;
                }
                // Allocated less than expectes
                else if(allocated < objLine.SVMXC__Expected_Quantity2__c)
                {
                    if(actualAllocated > 0)
                    {
                        // Perform split lines
                        SVMXC__RMA_Shipment_Line__c objLine2 = new SVMXC__RMA_Shipment_Line__c();
                        objLine2 = objLine.clone(false,true);
                        objLine2.SVMXC__Fulfillment_Qty__c = actualAllocated;
                        shipmentOrderLines.add(objLine2);
                        
                        if((allocated - actualAllocated) > 0)
                        {
                            objLine.SVMXC__Fulfillment_Qty__c = allocated - actualAllocated;
                            objLine.SVMXC__Delivery_Location__c = mapDepoChildsDepo.get(objLine.SVMXC__Delivery_Location__c);
                            shipmentOrderLines.add(objLine);
                        }
                    }
                    else
                    {
                        objLine.SVMXC__Fulfillment_Qty__c = allocated;
                        //if(isClearLocation)
                            objLine.SVMXC__Delivery_Location__c = mapDepoChildsDepo.get(objLine.SVMXC__Delivery_Location__c);
                        shipmentOrderLines.add(objLine);
                    }
                }
                else // Allocated is greater than expected
                {
                    if(actualAllocated > 0)
                    {
                        // Perform split lines
                        SVMXC__RMA_Shipment_Line__c objLine2 = new SVMXC__RMA_Shipment_Line__c();
                        objLine2 = objLine.clone(false,true);
                        objLine2.SVMXC__Fulfillment_Qty__c = actualAllocated;
                        shipmentOrderLines.add(objLine2);
                        
                        if((objLine.SVMXC__Expected_Quantity2__c - actualAllocated) > 0)
                        {
                            objLine.SVMXC__Fulfillment_Qty__c = objLine.SVMXC__Expected_Quantity2__c - actualAllocated;
                            objLine.SVMXC__Delivery_Location__c = mapDepoChildsDepo.get(objLine.SVMXC__Delivery_Location__c);
                            shipmentOrderLines.add(objLine);
                        }
                    }
                    else
                    {
                        objLine.SVMXC__Fulfillment_Qty__c = objLine.SVMXC__Expected_Quantity2__c;
                        //if(isClearLocation)
                            objLine.SVMXC__Delivery_Location__c = mapDepoChildsDepo.get(objLine.SVMXC__Delivery_Location__c);
                        shipmentOrderLines.add(objLine);
                    }
                }
            }
        }
        
        // Group the order based on locations and create shipment order
        for(SVMXC__RMA_Shipment_Line__c orderLine: shipmentOrderLines)
        {
            List<SVMXC__RMA_Shipment_Line__c> shipmentLines = new List<SVMXC__RMA_Shipment_Line__c>();
            shipmentLines.add(orderLine);
            if(response.get(orderLine.SVMXC__Delivery_Location__c) != NULL)
                shipmentLines.addAll(response.get(orderLine.SVMXC__Delivery_Location__c));
            response.put(orderLine.SVMXC__Delivery_Location__c, shipmentLines);
        }
        system.debug('Response: ' + response);
        return response;
    }
    
}