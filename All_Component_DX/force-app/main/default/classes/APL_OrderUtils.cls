public with sharing class APL_OrderUtils {
    public class SVMXException extends Exception{}
    
    
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse getAPLOrder(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request)
    {
        //Added by Naveen V on 08-March-2012 For Performance
        //COMM_PerformanceUtils //perfUtil = new //COMM_PerformanceUtils();
        //perfUtil.begin();
        //COMM_PerformanceUtils.start('001: VARIABLE-DECLARATION'); 
        
        system.debug('request'+request);
        //Variable Decleration..
        //COMM_PerformanceUtils.start('001:a: VARIABLE-DECLARATION _ Simple');
        Boolean isDebugMode = false;
        String strLog = '';
        String strFldMapRecTypeId = '';
        String strDepotLocationRtypeId = '';
        String strRecordId = '';
        String strProcessId = '';
        String strProcessType = '';
        String strEventType = '';
        String strHeaderExpressionId = '';
        String strChildExpressionId = '';
        String strHeaderErrorMsg = '';
        String strLineErrorMsg = '';
        String strDepot = '';
        String strReceivingLocation = '';
        String strRMALineStatus = 'Completed';
        String strShipmentLineStatus = 'Completed';
        Integer intBatchsize = 500;
        set<String> setPOLines = new set<String>{'SystemModstamp','SVMXC__Master_Order_Line__c','SVMXC__Work_Order_Created__c','SVMXC__Warehouse__c','SVMXC__Use_Price_From_Pricebook__c','SVMXC__Total_Line_Price2__c','SVMXC__Shipped__c','SVMXC__Shipped_On__c','SVMXC__Shipped_By__c','SVMXC__Ship_Location__c','SVMXC__Service_Order__c','SVMXC__Service_Order_Line__c','SVMXC__Service_Engineer__c','SVMXC__Serial_Number__c','SVMXC__Serial_Number_List__c','SVMXC__Sales_Order_Number__c', 'SVMXC__Route_Stop__c','SVMXC__Route_Card__c','SVMXC__Returned_Condition__c','SVMXC__Reconciliation_Action__c','SVMXC__Received__c','SVMXC__Received_On__c','SVMXC__Received_By__c','SVMXC__RMA_Shipment_Order__c','SVMXC__Product__c','SVMXC__Posted_To_Inventory__c','SVMXC__Picked__c','SVMXC__Picked_Qty__c','SVMXC__Picked_On__c','SVMXC__Picked_By__c','SVMXC__Parts_Request_Line__c','SVMXC__Packing_Instructions__c','SVMXC__Line_Type__c','SVMXC__Line_Status__c','SVMXC__Line_Price2__c','SVMXC__Expected_Ship_Date__c','SVMXC__Expected_Receipt_Date__c','SVMXC__Expected_Quantity2__c','SVMXC__Expected_Condition__c','SVMXC__Disposition__c','SVMXC__Disposition_Instructions__c','SVMXC__Discount_Percentage__c','SVMXC__Delivery_Location__c','SVMXC__Delivery_Location__r.Name','SVMXC__Delivered__c','SVMXC__Delivered_On__c','SVMXC__Delivered_By__c','SVMXC__Closed_On__c','SVMXC__Closed_By__c','SVMXC__Case_Line__c','SVMXC__Canceled_On__c','SVMXC__Canceled_By__c','SVMXC__Actual_Ship_Date__c','SVMXC__Actual_Receipt_Date__c','SVMXC__Actual_Quantity2__c','RecordTypeId','Name', 'LastModifiedDate','LastModifiedById','IsDeleted','Id','CreatedDate','CreatedById','SVMXC__Product__r.Name','SVMXC__Product__r.ProductCode'};
        String StrOrderLineFields = ' SystemModstamp, SVMXC__Master_Order_Line__c, SVMXC__Work_Order_Created__c, SVMXC__Warehouse__c, SVMXC__Use_Price_From_Pricebook__c, SVMXC__Total_Line_Price2__c, SVMXC__Shipped__c, SVMXC__Shipped_On__c, SVMXC__Shipped_By__c, SVMXC__Ship_Location__c, SVMXC__Service_Order__c, SVMXC__Service_Order_Line__c, SVMXC__Service_Engineer__c, SVMXC__Serial_Number__c, SVMXC__Serial_Number_List__c, SVMXC__Sales_Order_Number__c, SVMXC__Route_Stop__c, SVMXC__Route_Card__c, SVMXC__Returned_Condition__c, SVMXC__Reconciliation_Action__c, SVMXC__Received__c, SVMXC__Received_On__c, SVMXC__Received_By__c, SVMXC__RMA_Shipment_Order__c, SVMXC__Product__c, SVMXC__Posted_To_Inventory__c, SVMXC__Picked__c, SVMXC__Picked_Qty__c, SVMXC__Picked_On__c, SVMXC__Picked_By__c, SVMXC__Parts_Request_Line__c, SVMXC__Packing_Instructions__c, SVMXC__Line_Type__c, SVMXC__Line_Status__c, SVMXC__Line_Price2__c, SVMXC__Expected_Ship_Date__c, SVMXC__Expected_Receipt_Date__c, SVMXC__Expected_Quantity2__c, SVMXC__Expected_Condition__c, SVMXC__Disposition__c, SVMXC__Disposition_Instructions__c, SVMXC__Discount_Percentage__c, SVMXC__Delivery_Location__c, SVMXC__Delivery_Location__r.Name, SVMXC__Delivered__c, SVMXC__Delivered_On__c, SVMXC__Delivered_By__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Case_Line__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Actual_Ship_Date__c, SVMXC__Actual_Receipt_Date__c, SVMXC__Actual_Quantity2__c, RecordTypeId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById, SVMXC__Product__r.Name, SVMXC__Product__r.ProductCode ';
        String strHeaderFields= '';
        SVMXC.INTF_ParseExpression ExpParssig;
        SVMXC.INTF_WebServicesDef.APL_Order aplOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        SVMXC.COMM_Utils_ManageSettings commSettings = new SVMXC.COMM_Utils_ManageSettings();
        SVMXC.APL_Utils aplUtil = new SVMXC.APL_Utils();
        SVMXC.COMM_Utils utils = new SVMXC.COMM_Utils();
        SVMXC__RMA_Shipment_Order__c orderHeader = new SVMXC__RMA_Shipment_Order__c();
        SVMXC__ServiceMax_Processes__c SVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c headerExpression = new SVMXC__ServiceMax_Processes__c();
        SVMXC__ServiceMax_Processes__c lineExpression = new SVMXC__ServiceMax_Processes__c();
        
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigData = new list<SVMXC__ServiceMax_Config_Data__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstDocumentAttribute = new list<SVMXC__ServiceMax_Config_Data__c>();
        list<SVMXC__RMA_Shipment_Line__c> lstOrderLines = new list<SVMXC__RMA_Shipment_Line__c>();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForResponse = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        list<RecordType> RecordTypes = new list<RecordType>();
        list<String> settigListForAPL002 = new list<String>();
        list<String> settigListForAPL003 = new list<String>();
        list<String> lstBatchIds = new list<String>();
        
        set<String> setLineIds = new set<String>();
        set<String> setProductId = new set<String>();
        system.debug('setPOLines:'+setPOLines.size()+setPOLines);
        
        //COMM_PerformanceUtils.stop('001:a: VARIABLE-DECLARATION _ Simple');
        //COMM_PerformanceUtils.start('001:b: VARIABLE-DECLARATION _ ExtractingRequest');
        
        lstSVMXMap = request.valueMap;
        strEventType = request.eventType;
        strLog += '\n \n'+'METHOD_ENTRY: getAPLOrder1' + ' INPUT_PARAMETERS : '+request;
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
                    lstBatchIds = lstSVMXMap[i].values;   
                else if(lstSVMXMap[i].key.touppercase() == 'SVMX_DEBUGMODE')
                    isDebugMode = Boolean.valueof(lstSVMXMap[i].value);         
            }
        }
        
        //COMM_PerformanceUtils.stop('001:b: VARIABLE-DECLARATION _ ExtractingRequest');
        
        system.debug('strRecordId'+strRecordId);
        system.debug('strProcessId'+strProcessId);
        system.debug('isDebugMode'+isDebugMode);
        system.debug('strProcessType'+strProcessType);
        system.debug('strEventType'+strEventType);
        system.debug('lstBatchIds'+lstBatchIds.size()+lstBatchIds);
        
        //COMM_PerformanceUtils.start('001:c: VARIABLE-DECLARATION _ ExtractingSetting');
        
       
        map<Id,SVMXC__RMA_Shipment_Line__c> mapOrderLines = new map<Id,SVMXC__RMA_Shipment_Line__c>();
        map<Id, SVMXC.INTF_WebServicesDef.SVMXMap> mapLineLocations = new map<Id, SVMXC.INTF_WebServicesDef.SVMXMap>();
        
        settigListForAPL002.add('SET002');
        settigListForAPL003.add('SET002');
        settigListForAPL003.add('SET008');
        settigListForAPL003.add('SET009');
        settigListForAPL003.add('SET010');
        map<String, String> svmxSettingListforAPL002 = commSettings.SVMX_getSettingList('APL002', settigListForAPL002);
        map<String, String> svmxSettingListforAPL003 = commSettings.SVMX_getSettingList('APL003', settigListForAPL003);
        system.debug('svmxSettingListforAPL003'+svmxSettingListforAPL003);
        if(svmxSettingListforAPL002.containskey('SET002'))
            strRMALineStatus = svmxSettingListforAPL002.get('SET002');
        if(svmxSettingListforAPL003.containskey('SET002'))
            strShipmentLineStatus = svmxSettingListforAPL003.get('SET002'); 
        //COMM_PerformanceUtils.stop('001:c: VARIABLE-DECLARATION _ ExtractingSetting');  
        
        //COMM_PerformanceUtils.stop('001: VARIABLE-DECLARATION');
        //COMM_PerformanceUtils.start('002: QueringRT'); 
        if(isDebugMode)
            strLog += '\n \n'+'SOQL_QUERY : For Sobject RecordType - Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = \'SVMXC__ServiceMax_Config_Data__c\' OR SobjectType = \'SVMXC__Site__c\'';
        
        List<String> queryFields = new List<String>{'SystemModstamp','SobjectType','NamespacePrefix','Name','LastModifiedDate','LastModifiedById','IsActive','Id','DeveloperName','Description','CreatedDate','CreatedById','BusinessProcessId'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'RecordType', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c' OR SobjectType = 'SVMXC__Site__c']; //SDL-SVMX-READ-FLS-ENFORCED
        
        //COMM_PerformanceUtils.stop('002: QueringRT');   
        //COMM_PerformanceUtils.start('003: LoopingRT'); 
        
        if(RecordTypes.size() > 0 )
        {
            for(RecordType r : RecordTypes)
            {
                if(r.Name == 'Field Mapping')
                    strFldMapRecTypeId = r.id;
                else if(r.Name == 'Depot')
                    strDepotLocationRtypeId = r.id;     
            }
        }
        
        //COMM_PerformanceUtils.stop('003: LoopingRT');
        //COMM_PerformanceUtils.start('004: INITIALSYNCorBATCHCALL');
        
        if(strEventType != null && strEventType.length() > 0 && strEventType == 'INITIALSYNC')
        {
            map<String, Schema.SObjectField> mapPOField = Schema.SObjectType.SVMXC__RMA_Shipment_Order__c.fields.getMap();
            system.debug('mapPOField'+mapPOField);
            strHeaderFields = utils.SVMX_getFieldNamesFromList(utils.SVMX_getFieldList(mapPOField,true));
            strHeaderFields += ',SVMXC__Source_Location__r.Name, SVMXC__Destination_Location__r.Name';
            if(strProcessId != null && strProcessId.length() > 0)
            {
                //COMM_PerformanceUtils.start('004:a: INITIALSYNCorBATCHCALL _ QueryingServiceMaxProc');
                
                if(isDebugMode)
                    strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__ServiceMax_Processes__c - Select SVMXC__Target_Record_Type__c, SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Resolve_Unexpected_SN_To_IB__c, SVMXC__Record_Type_Name__c, SVMXC__Purpose__c,  SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Process2__c, SVMXC__Process1__c, SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Parent_Column_Name__c, SVMXC__Node_Parent__c, SVMXC__Node_Parent_API__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c, SVMXC__MapID__c, SVMXC__Final_Exception_Process__c,  SVMXC__Entitlement_Scope__c, SVMXC__Entitlement_By__c,SVMXC__Description__c,  SVMXC__Default_Location__c, SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Consider_Location_From__c, SVMXC__Consider_Location_From_Object__c, SVMXC__Child_Object_Criteria__c, SVMXC__Child_Error_Msg__c, SVMXC__Child_Error_Msg2__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, SVMXC__APL_Split_Lines__c, SVMXC__APL_Shipment_Note_Template__c, SVMXC__APL_Serial_Number_Source__c, SVMXC__APL_Scan_First__c, SVMXC__APL_Route_Rule_Type__c, SVMXC__APL_Print_RMA_Template__c, SVMXC__APL_Print_Label_Template__c, SVMXC__APL_Perform_Route_Calculations__c, SVMXC__APL_Perform_Entitlement__c, SVMXC__APL_Group_Work_Order_By__c, SVMXC__APL_Field_Name__c, SVMXC__APL_Create_Work_Order_On__c, SVMXC__APL_Create_WO_Preference__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Allow_Partial_Shipment__c, SVMXC__APL_Allow_Partial_Delivery__c, SVMXC__APL_Action_On_Unexpected_SN__c, SVMXC__APL_Action_On_Unexpected_Product__c, SVMXC__APL_Action_On_Less_Qty__c, SVMXC__APL_Action_On_Excess_Qty__c, RecordTypeId, OwnerId, Name, Id From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: '+strProcessId+ 'OR id =: '+strProcessId;
                queryFields = new List<String>{'SVMXC__Target_Record_Type__c','SVMXC__Target_Object_Name__c','SVMXC__Submodule__c','SVMXC__SubmoduleID__c','SVMXC__Source_Object_Name__c','SVMXC__SettingID__c','SVMXC__Sequence__c','SVMXC__Resolve_Unexpected_SN_To_IB__c','SVMXC__Record_Type_Name__c','SVMXC__Purpose__c',' SVMXC__Process__c','SVMXC__ProcessID__c','SVMXC__Process2__c','SVMXC__Process1__c','SVMXC__Parent_Object__c','SVMXC__Parent_Object_Criteria__c','SVMXC__Parent_Error_Msg__c','SVMXC__Parent_Error_Msg2__c','SVMXC__Parent_Column_Name__c','SVMXC__Node_Parent__c','SVMXC__Node_Parent_API__c','SVMXC__Name__c','SVMXC__Module__c','SVMXC__ModuleID__c','SVMXC__MapID__c','SVMXC__Final_Exception_Process__c',' SVMXC__Entitlement_Scope__c','SVMXC__Entitlement_By__c','SVMXC__Description__c',' SVMXC__Default_Location__c','SVMXC__Data_Type__c','SVMXC__Counter_Vs_Dates_Rule__c','SVMXC__Consider_Location_From__c','SVMXC__Consider_Location_From_Object__c','SVMXC__Child_Object_Criteria__c','SVMXC__Child_Error_Msg__c','SVMXC__Child_Error_Msg2__c','SVMXC__Advance_Expression__c','SVMXC__Active__c','SVMXC__APL_Split_Lines__c','SVMXC__APL_Shipment_Note_Template__c','SVMXC__APL_Serial_Number_Source__c','SVMXC__APL_Scan_First__c','SVMXC__APL_Route_Rule_Type__c','SVMXC__APL_Print_RMA_Template__c','SVMXC__APL_Print_Label_Template__c','SVMXC__APL_Perform_Route_Calculations__c','SVMXC__APL_Perform_Entitlement__c','SVMXC__APL_Group_Work_Order_By__c','SVMXC__APL_Field_Name__c','SVMXC__APL_Create_Work_Order_On__c','SVMXC__APL_Create_WO_Preference__c','SVMXC__APL_Create_Supplier_RMA__c','SVMXC__APL_Create_Internal_RMA__c','SVMXC__APL_Allow_Partial_Shipment__c','SVMXC__APL_Allow_Partial_Delivery__c','SVMXC__APL_Action_On_Unexpected_SN__c','SVMXC__APL_Action_On_Unexpected_Product__c','SVMXC__APL_Action_On_Less_Qty__c','SVMXC__APL_Action_On_Excess_Qty__c','RecordTypeId','OwnerId','Name','Id'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                SVMXProcess = [Select SVMXC__Target_Record_Type__c, SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Resolve_Unexpected_SN_To_IB__c, SVMXC__Record_Type_Name__c, SVMXC__Purpose__c,  SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Process2__c, SVMXC__Process1__c, SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Parent_Column_Name__c, SVMXC__Node_Parent__c, SVMXC__Node_Parent_API__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c, SVMXC__MapID__c, SVMXC__Final_Exception_Process__c,  SVMXC__Entitlement_Scope__c, SVMXC__Entitlement_By__c,SVMXC__Description__c,  SVMXC__Default_Location__c, SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Consider_Location_From__c, SVMXC__Consider_Location_From_Object__c, SVMXC__Child_Object_Criteria__c, SVMXC__Child_Error_Msg__c, SVMXC__Child_Error_Msg2__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, SVMXC__APL_Split_Lines__c, SVMXC__APL_Shipment_Note_Template__c, SVMXC__APL_Serial_Number_Source__c, SVMXC__APL_Scan_First__c, SVMXC__APL_Route_Rule_Type__c, SVMXC__APL_Print_RMA_Template__c, SVMXC__APL_Print_Label_Template__c, SVMXC__APL_Perform_Route_Calculations__c, SVMXC__APL_Perform_Entitlement__c, SVMXC__APL_Group_Work_Order_By__c, SVMXC__APL_Field_Name__c, SVMXC__APL_Create_Work_Order_On__c, SVMXC__APL_Create_WO_Preference__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Allow_Partial_Shipment__c, SVMXC__APL_Allow_Partial_Delivery__c, SVMXC__APL_Action_On_Unexpected_SN__c, SVMXC__APL_Action_On_Unexpected_Product__c, SVMXC__APL_Action_On_Less_Qty__c, SVMXC__APL_Action_On_Excess_Qty__c, RecordTypeId, OwnerId, Name, Id From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strProcessId or id =: strProcessId]; //SDL-SVMX-READ-FLS-ENFORCED
                
                //COMM_PerformanceUtils.stop('004:a: INITIALSYNCorBATCHCALL _  QueryingServiceMaxProc');
                
                system.debug('SVMXProcess'+SVMXProcess);
                if(SVMXProcess != null && SVMXProcess.id != null )
                {
                    aplOrder.svmxProcess = SVMXProcess;
                    
                    //COMM_PerformanceUtils.start('004:b: INITIALSYNCorBATCHCALL _ QueryingServiceMaxConfData');
                    if(isDebugMode)
                        strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__ServiceMax_Config_Data__c - select id,Name,RecordTypeId,SVMXC__Configuration_Type__c,SVMXC__Field_Name__c,SVMXC__Dispatch_Process__c,SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where  RecordTypeId =:'+strFldMapRecTypeId+ ' and SVMXC__Dispatch_Process__c =: '+SVMXProcess.id;
                    queryFields = new List<String>{'id','Name','RecordTypeId','SVMXC__Configuration_Type__c','SVMXC__Field_Name__c','SVMXC__Dispatch_Process__c','SVMXC__Display_Type__c', 'SVMXC__Field_Relationship_Name__c','SVMXC__FKey_Name_Field__c','SVMXC__Object_Name__c'};
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    lstConfigData = [select id,Name,RecordTypeId,SVMXC__Configuration_Type__c,SVMXC__Field_Name__c,SVMXC__Dispatch_Process__c,SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where  RecordTypeId =: strFldMapRecTypeId and SVMXC__Dispatch_Process__c =: SVMXProcess.id]; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    //COMM_PerformanceUtils.stop('004:b: INITIALSYNCorBATCHCALL _ QueryingServiceMaxConfData');
                    
                    system.debug('lstConfigData :'+lstConfigData);
                    if(lstConfigData.size() > 0)
                    {
                        aplOrder.configData = lstConfigData;
                        //Loop config data and get the fields for the procuct attribute and document attrbutes fields and add in line query.
                        
                        
                        if(lstConfigData.size() > 0)
                        {
                            //COMM_PerformanceUtils.start('004:c: INITIALSYNCorBATCHCALL _ LoopingServiceMaxConfData');
                            
                            for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
                            {
                                /*if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE' && !setPOLines.contains('SVMXC__Product__r.'+config.SVMXC__Field_Name__c))
                                {
                                    StrOrderLineFields += ', SVMXC__Product__r.'+config.SVMXC__Field_Name__c;
                                    setPOLines.add('SVMXC__Product__r.'+config.SVMXC__Field_Name__c);
                                }    
                                if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && config.SVMXC__Field_Relationship_Name__c != null && config.SVMXC__FKey_Name_Field__c != null && !setPOLines.contains(config.SVMXC__Field_Relationship_Name__c+'.'+config.SVMXC__FKey_Name_Field__c))
                                {    
                                    StrOrderLineFields += ' , '+config.SVMXC__Field_Relationship_Name__c+'.'+config.SVMXC__FKey_Name_Field__c;
                                    setPOLines.add(config.SVMXC__Field_Relationship_Name__c+'.'+config.SVMXC__FKey_Name_Field__c);
                                } */   
                                if(config.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE') 
                                { 
                                    lstDocumentAttribute.add(config);
                                }    
                            }
                            //COMM_PerformanceUtils.stop('004:c: INITIALSYNCorBATCHCALL _ LoopingServiceMaxConfData');
                        } 
                    }   
                }   
            }
            try
            {
                if(strRecordId != null && strRecordId.length() > 0)
                {
                    if(strProcessType.toUpperCase() == 'PROCESSRECEIPT' || strProcessType.toUpperCase() == 'DELIVERYONRECEIPT' || strProcessType.toUpperCase() == 'FULFILLMENTPROCESS')
                    {
                        //COMM_PerformanceUtils.start('004:d: INITIALSYNCorBATCHCALL _ QueryingRmaSO');
                    
                        queryFields = strHeaderFields.split(',');
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        String Query = 'Select '+strHeaderFields+' From SVMXC__RMA_Shipment_Order__c where id =: strRecordId and RecordType.Name = \'RMA\' and SVMXC__On_Hold__c = false';
                        system.debug('AAQuery'+Query);
                        if(isDebugMode) 
                            strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__RMA_Shipment_Order__c -'+Query; 
                        orderHeader = database.query(Query);
                        
                        //COMM_PerformanceUtils.stop('004:d: INITIALSYNCorBATCHCALL _ QueryingRmaSO');
                    }
                    else if(strProcessType.toUpperCase() == 'PICKNMOVE' || strProcessType.toUpperCase() == 'SHIPCONFIRM')
                    {
                        //COMM_PerformanceUtils.start('004:d: INITIALSYNCorBATCHCALL _ QueryingRmaSO');
                        queryFields = strHeaderFields.split(',');
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                        String Query = 'Select '+strHeaderFields+' From SVMXC__RMA_Shipment_Order__c where id =: strRecordId and RecordType.Name = \'Shipment\' and SVMXC__On_Hold__c = false';
                        system.debug('AAQuery'+Query);
                        if(isDebugMode)
                            strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__RMA_Shipment_Order__c -' +Query;
                        orderHeader = database.query(Query);
                        
                        //COMM_PerformanceUtils.stop('004:d: INITIALSYNCorBATCHCALL _ QueryingRmaSO');    
                    }   
                    system.debug('orderHeader :'+orderHeader);
                }
            }
            catch(exception ex)
            {
                response.success = false;
                response.message = system.label.APL003_TAG052;
                
                //COMM_PerformanceUtils.stop('004:d: INITIALSYNCorBATCHCALL _ QueryingRmaSO');
                //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                return response;
            }
            //Validation
            if(strProcessType == 'PROCESSRECEIPT' || strProcessType == 'DELIVERYONRECEIPT')
            {
                if((orderHeader.SVMXC__Fulfillment_Type__c == NULL || orderHeader.SVMXC__Fulfillment_Type__c.touppercase() != 'REPAIR') && orderHeader.SVMXC__Master_Order__c == null )//|| orderHeader.SVMXC__Master_Order__c == '')
                {
                    response.message = system.label.APL003_TAG050;//RMA order does not have master RMA associate with it
                    response.success = false;
                    
                    //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                    //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                    return response;
                }
            }
            //Find the Depot and Receiving Location for Parts Order 
            if(strProcessType == 'PROCESSRECEIPT' || strProcessType == 'DELIVERYONRECEIPT' || strProcessType.toUpperCase() == 'FULFILLMENTPROCESS')
            {
                if(orderHeader.SVMXC__Destination_Location__c == null)
                {
                    response.success = false;
                    response.message = system.label.APL003_TAG041;//Destination location should not empty
                    
                    //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                    //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                    return response;
                }
                if(orderHeader.SVMXC__Destination_Location__c != null)
                {
                    list<SVMXC__Site__c> lstDepotLocation = new list<SVMXC__Site__c>();
                    
                    //COMM_PerformanceUtils.start('004:e: INITIALSYNCorBATCHCALL _ QueryingDepotLoc');
                    
                    queryFields = new List<String> {'id','Name','RecordTypeId'};
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    lstDepotLocation = [select id,Name,RecordTypeId From SVMXC__Site__c where id =: orderHeader.SVMXC__Destination_Location__c and RecordTypeId =: strDepotLocationRtypeId]; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    //COMM_PerformanceUtils.stop('004:e: INITIALSYNCorBATCHCALL _ QueryingDepotLoc');
                    
                    if(lstDepotLocation.size() > 0)
                    {
                         strDepot = orderHeader.SVMXC__Destination_Location__r.Name;
                         list<SVMXC__Site__c> lstDepotsReceivingLocation = new list<SVMXC__Site__c>();
                         
                         //COMM_PerformanceUtils.start('004:f: INITIALSYNCorBATCHCALL _ QueryingRecieveLoc');
                         
                        queryFields = new List<String> {'id','Name','RecordTypeId','SVMXC__Parent__c','SVMXC__IsReceiving_Location__c' };
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                         lstDepotsReceivingLocation = [select id,Name,RecordTypeId,SVMXC__Parent__c,SVMXC__IsReceiving_Location__c from SVMXC__Site__c where SVMXC__Parent__c =: lstDepotLocation[0].id and SVMXC__IsReceiving_Location__c = true and RecordType.Name = 'Depot Child']; //SDL-SVMX-READ-FLS-ENFORCED
                         
                         //COMM_PerformanceUtils.stop('004:f: INITIALSYNCorBATCHCALL _ QueryingRecieveLoc');
                         
                         if(lstDepotsReceivingLocation.size() == 0)
                         {
                            response.success = false;
                            response.message = system.label.APL003_TAG043+': '+orderHeader.SVMXC__Destination_Location__r.Name;//depot must have receiving location
                            
                            //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                            //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                            return response;
                         }   
                         else if(lstDepotsReceivingLocation.size() > 1)
                         {
                            response.success = false;
                            response.message = system.label.APL003_TAG044+': '+orderHeader.SVMXC__Destination_Location__r.Name;//depot has more then one receiving location
                            
                            //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
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
                        
                        //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                        //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                        return response;
                    }
                }
            }
            else if(strProcessType == 'PICKNMOVE' || strProcessType == 'SHIPCONFIRM')
            {
                if(orderHeader.SVMXC__Source_Location__c == null)
                {
                    response.success = false;
                    response.message = system.label.APL002_TAG047;//Source location should not empty
                    
                    //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                    //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                    return response;
                }
                if(orderHeader.SVMXC__Source_Location__c != null)
                {
                    list<SVMXC__Site__c> lstDepotLocation = new list<SVMXC__Site__c>();
                    
                    //COMM_PerformanceUtils.start('004:e: INITIALSYNCorBATCHCALL _ QueryingDepotLoc');
                    
                    queryFields = new List<String> {'id','Name','RecordTypeId'};
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    lstDepotLocation = [select id,Name,RecordTypeId From SVMXC__Site__c where id =: orderHeader.SVMXC__Source_Location__c and RecordTypeId =: strDepotLocationRtypeId]; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    //COMM_PerformanceUtils.stop('004:e: INITIALSYNCorBATCHCALL _ QueryingDepotLoc');
                    
                    if(lstDepotLocation.size() > 0)
                    {
                         strDepot = orderHeader.SVMXC__Source_Location__r.Name;
                         list<SVMXC__Site__c> lstDepotsStagingLocation = new list<SVMXC__Site__c>();
                         
                         //COMM_PerformanceUtils.start('004:f: INITIALSYNCorBATCHCALL _ QueryingDepotStagLoc');
                        queryFields = new List<String> {'id','Name','RecordTypeId','SVMXC__Parent__c','SVMXC__IsStaging_Location__c'};
                            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                         lstDepotsStagingLocation = [select id,Name,RecordTypeId,SVMXC__Parent__c,SVMXC__IsStaging_Location__c from SVMXC__Site__c where SVMXC__Parent__c =: lstDepotLocation[0].id and SVMXC__IsStaging_Location__c = true and RecordType.Name = 'Depot Child']; //SDL-SVMX-READ-FLS-ENFORCED
                         
                         //COMM_PerformanceUtils.stop('004:f: INITIALSYNCorBATCHCALL _ QueryingDepotStagLoc');
                         
                         if(lstDepotsStagingLocation.size() == 0)
                         {
                            response.success = false;
                            response.message = system.label.APL002_TAG048+': '+orderHeader.SVMXC__Source_Location__r.Name;//depot must have staging location.
                            
                            //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                            //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                            return response;
                         }
                         else if(lstDepotsStagingLocation.size() > 1)
                         {
                            response.success = false;
                            response.message = system.label.APL002_TAG049+': '+orderHeader.SVMXC__Source_Location__r.Name;//depot has more then one staging location
                            
                            //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                            //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                            return response;
                         }
                         else
                         {
                              strReceivingLocation = lstDepotsStagingLocation[0].Name;
                         }    
                    }
                    else
                    {
                        response.success = false;
                        response.message = system.label.APL002_TAG050;//Source location must be depot
                        
                        //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                        //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                        return response;
                    }
                }
            }     
            //Create  Resonse Map for the Depot and Receiving Location
            SVMXC.INTF_WebServicesDef.SVMXMap mapForHeaderAttribute = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForHeaderAttribute.key = 'HEADERATTRIBUTE';
            list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForHeaderAttribute = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
            SVMXC.INTF_WebServicesDef.SVMXMap mapForDepot = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForDepot.key = 'DEPOTNAME';
            mapForDepot.value = strDepot;
            lstSVMXMapForHeaderAttribute.add(mapForDepot);
            mapForDepot = null;
            SVMXC.INTF_WebServicesDef.SVMXMap mapForReceivingLoc = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForReceivingLoc.key = 'RECEIVINGLOCATION';
            mapForReceivingLoc.value = strReceivingLocation;
            lstSVMXMapForHeaderAttribute.add(mapForReceivingLoc);
            mapForReceivingLoc = null;
            mapForHeaderAttribute.valueMap = lstSVMXMapForHeaderAttribute;
            system.debug('mapForHeaderAttribute'+mapForHeaderAttribute);
            lstSVMXMapForResponse.add(mapForHeaderAttribute);
            //Get Data For Header & Line  Qualification...
            if(strProcessType == 'PROCESSRECEIPT' || strProcessType == 'PICKNMOVE')
            {
                if(SVMXProcess.SVMXC__Node_Parent__c != null)
                    strHeaderExpressionId = SVMXProcess.SVMXC__Node_Parent__c;
                if(SVMXProcess.SVMXC__Submodule__c != null)
                    strChildExpressionId = SVMXProcess.SVMXC__Submodule__c;
                if(SVMXProcess.SVMXC__Parent_Error_Msg__c != null)
                    strHeaderErrorMsg = SVMXProcess.SVMXC__Parent_Error_Msg__c;
                if(SVMXProcess.SVMXC__Child_Error_Msg__c != null)
                    strLineErrorMsg = SVMXProcess.SVMXC__Child_Error_Msg__c;
            }
            else if(strProcessType == 'DELIVERYONRECEIPT' || strProcessType == 'SHIPCONFIRM')
            {
                if(SVMXProcess.SVMXC__Module__c != null)
                    strHeaderExpressionId = SVMXProcess.SVMXC__Module__c;
                if(SVMXProcess.SVMXC__Final_Exception_Process__c != null)
                    strChildExpressionId = SVMXProcess.SVMXC__Final_Exception_Process__c;
                if(SVMXProcess.SVMXC__Parent_Error_Msg2__c != null)
                    strHeaderErrorMsg = SVMXProcess.SVMXC__Parent_Error_Msg2__c;
                if(SVMXProcess.SVMXC__Child_Error_Msg2__c != null)
                    strLineErrorMsg = SVMXProcess.SVMXC__Child_Error_Msg2__c;
            }
            system.debug('strHeaderExpressionId'+strHeaderExpressionId);
            system.debug('strChildExpressionId'+strChildExpressionId); 
            
            if(strHeaderExpressionId != '' && strHeaderExpressionId.length() > 0)
            {
                //COMM_PerformanceUtils.start('004:g: INITIALSYNCorBATCHCALL _ QueryingProcessObjHE');
            
                if(isDebugMode)
                    strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__ServiceMax_Processes__c - Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'SVMX Rule\' AND SVMXC__Rule_Type__c = \'Named Expression\' AND Id =: '+strHeaderExpressionId;
                queryFields = new List<String> {'Id', 'Name','SVMXC__Source_Object_Name__c', 'SVMXC__Name__c','SVMXC__SettingId__c','SVMXC__Description__c','SVMXC__Advance_Expression__c','SVMXC__ProcessID__c','SVMXC__Parent_Object_Criteria__c','SVMXC__Parent_Error_Msg__c','SVMXC__IsStandard__c'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                headerExpression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =: strHeaderExpressionId]; //SDL-SVMX-READ-FLS-ENFORCED
                
                //COMM_PerformanceUtils.stop('004:g: INITIALSYNCorBATCHCALL _ QueryingProcessObjHE');
                
            }   
            if(strChildExpressionId != '' && strChildExpressionId.length() > 0)  
            {   
                //COMM_PerformanceUtils.start('004:h: INITIALSYNCorBATCHCALL _ QueryingProcessObjLE');
            
                if(isDebugMode)
                    strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__ServiceMax_Processes__c - Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c,SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name = \'SVMX Rule\' AND SVMXC__Rule_Type__c = \'Named Expression\' AND Id =: '+strChildExpressionId;
                queryFields = new List<String> {'Id', 'Name','SVMXC__Source_Object_Name__c', 'SVMXC__Name__c', 'SVMXC__Submodule__c', 'SVMXC__SettingId__c','SVMXC__Description__c','SVMXC__Advance_Expression__c','SVMXC__ProcessID__c','SVMXC__Parent_Object_Criteria__c','SVMXC__Parent_Error_Msg__c','SVMXC__IsStandard__c'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                lineExpression = [Select Id, Name,SVMXC__Source_Object_Name__c, SVMXC__Name__c, SVMXC__Submodule__c, SVMXC__SettingId__c,SVMXC__Description__c,SVMXC__Advance_Expression__c,SVMXC__ProcessID__c,SVMXC__Parent_Object_Criteria__c,SVMXC__Parent_Error_Msg__c,SVMXC__IsStandard__c From SVMXC__ServiceMax_Processes__c where Recordtype.Name='SVMX Rule' AND SVMXC__Rule_Type__c = 'Named Expression' AND Id =: strChildExpressionId]; //SDL-SVMX-READ-FLS-ENFORCED
                
                //COMM_PerformanceUtils.stop('004:h: INITIALSYNCorBATCHCALL _ QueryingProcessObjLE');
                
            }   
            
            system.debug('headerExpression'+headerExpression);
            system.debug('lineExpression'+lineExpression);

            //COMM_PerformanceUtils.start('004:h:001 INITIALSYNCorBATCHCALL _ ParsingExp');
            //Check for Header Qualification..
            if(headerExpression != null && orderHeader != null)
            {
                system.debug('Entered for header qualification');
                SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                SFMExpression.namedExpression = headerExpression;
                list<Sobject> lstSobject = new list<Sobject>();
                list<SVMXC__RMA_Shipment_Order__c> lstPartsOrder = new list<SVMXC__RMA_Shipment_Order__c>();
                lstPartsOrder.add(orderHeader);
                ExpParssig = new SVMXC.INTF_ParseExpression();
                lstSobject = ExpParssig.INTF_ParseExpression(lstPartsOrder,SFMExpression);
                if(lstSobject.size() == 0)
                {
                    response.success = false;
                    response.message = strHeaderErrorMsg;
                    system.debug('response'+response);
                    
                    //COMM_PerformanceUtils.start('004:h:001 INITIALSYNCorBATCHCALL _ ParsingExp');
                    //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                    //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                    return response;
                }   
            }
            //COMM_PerformanceUtils.stop('004:h:001 INITIALSYNCorBATCHCALL _ ParsingExp');
            //Add If Header is Qualified..
            aplOrder.orderHdrRecord = orderHeader;
            //Line Qualification..
            if(strRecordId != null && strRecordId.length() > 0)
            {
                list<SVMXC__RMA_Shipment_Line__c> lstTempPOLines = new list<SVMXC__RMA_Shipment_Line__c>();
                //list<Sobject> lstOutput = new list<Sobject>();
                String query = '';
                queryFields = new List<String> {'id', 'SVMXC__RMA_Shipment_Order__c', 'SVMXC__Received__c', 'SVMXC__Picked__c', 'SVMXC__Delivered__c'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                
                if(strProcessType.toUpperCase() == 'PROCESSRECEIPT')
                    query = 'Select id From SVMXC__RMA_Shipment_Line__c  where SVMXC__RMA_Shipment_Order__c =: strRecordId and SVMXC__Received__c = false';//SVMXC__Line_Status__c !=: strRMALineStatus'; // ' +StrOrderLineFields+ ' 
                else if(strProcessType.toUpperCase() == 'DELIVERYONRECEIPT')
                    query = 'Select id From SVMXC__RMA_Shipment_Line__c  where SVMXC__RMA_Shipment_Order__c =: strRecordId and SVMXC__Received__c = true and SVMXC__Delivered__c = false ';//SVMXC__Line_Status__c =: strRMALineStatus'; //' +StrOrderLineFields+ ' 
                else if(strProcessType.toUpperCase() == 'PICKNMOVE')
                    query = 'Select id From SVMXC__RMA_Shipment_Line__c  where SVMXC__RMA_Shipment_Order__c =: strRecordId and SVMXC__Picked__c = false';//SVMXC__Line_Status__c !=: strShipmentLineStatus';
                else if(strProcessType.toUpperCase() == 'SHIPCONFIRM')
                    query = 'Select id From SVMXC__RMA_Shipment_Line__c  where SVMXC__RMA_Shipment_Order__c =: strRecordId and SVMXC__Picked__c = true and SVMXC__Shipped__c = false';//SVMXC__Line_Status__c =: strShipmentLineStatus';
                else
                    query = 'Select id From SVMXC__RMA_Shipment_Line__c  where SVMXC__RMA_Shipment_Order__c =: strRecordId ';
                system.debug('query'+query);
                if(isDebugMode)
                    strLog += '\n \n'+'SOQL_QUERY :For Sobject SVMXC__RMA_Shipment_Line__c - '+query;
                    
                //COMM_PerformanceUtils.start('004:i: INITIALSYNCorBATCHCALL _ QueryingRmaSL');
                    
                lstTempPOLines = Database.query(query);
                
                //COMM_PerformanceUtils.stop('004:i: INITIALSYNCorBATCHCALL _ QueryingRmaSL');
                
                //COMM_PerformanceUtils.start('004:i:001 INITIALSYNCorBATCHCALL _ parsingExp1');
                system.debug('lstTempPOLines: '+lstTempPOLines.size());
                if(lstTempPOLines.size() > 0 && lineExpression != null)
                {
                    list<Sobject> lstOutput = new list<Sobject>();
                    SVMXC.INTF_WebServicesDef.INTF_Expression SFMExpression = new SVMXC.INTF_WebServicesDef.INTF_Expression();
                    SFMExpression.namedExpression = lineExpression;
                    system.debug('Resp. of Parsing:'+ExpParssig.INTF_parseExpression1(lstTempPOLines,SFMExpression));
                    lstOutput.addAll(ExpParssig.INTF_parseExpression1(lstTempPOLines,SFMExpression));
                    lstTempPOLines.clear();
                    system.debug('lstOutput'+lstOutput.size()+lstOutput);
                    if(lstOutput.size() == 0)
                    {
                        response.success = false;
                        response.message = strLineErrorMsg;
                        system.debug('response'+response);
                        
                        //COMM_PerformanceUtils.stop('004:i:001 INITIALSYNCorBATCHCALL _ parsingExp1');
                        //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                        //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                        return response;
                    }
                    else
                    {
                        for(Integer i = 0;i<lstOutput.size();i++)
                        {
                            setLineIds.add(String.valueof(lstOutput[i].get('Id')));
                        }
                    }
                    lstOutput.clear();
                }
                else if(lstTempPOLines.size() > 0 && lineExpression == null)
                {
                    for(Integer i = 0;i<lstTempPOLines.size();i++)
                    {
                        setLineIds.add(String.valueof(lstTempPOLines[i].get('Id')));
                    }
                }
                //COMM_PerformanceUtils.stop('004:i:001 INITIALSYNCorBATCHCALL _ parsingExp1');
            }
            system.debug('setLineIds'+setLineIds.size()+setLineIds);
            //Add Qualified Line Ids in response..
            SVMXC.INTF_WebServicesDef.SVMXMap mapForLineIds = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForLineIds.key = 'MAPKEYVALUES';
            SVMXC.INTF_WebServicesDef.SVMXMap mapLineIds = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapLineIds.key = 'LINEIDS';
            mapLineIds.values.addall(setLineIds);
            setLineIds.clear();
            mapForLineIds.valueMap.add(mapLineIds);
            mapLineIds = null;
            lstSVMXMapForResponse.add(mapForLineIds);
            mapForLineIds = null;
            
            //Make Header Document Atttributes 
            if(lstDocumentAttribute.size() > 0)
            {
                system.debug('lstDocumentAttribute: ' + lstDocumentAttribute);
                map<String,String> mapAPINameLablePO = new map<String,String>();
                //COMM_PerformanceUtils.start('004:j: INITIALSYNCorBATCHCALL _ LoopingRmaSO');
                if(mapPOField.size() > 0)
                {
                    for(String str:mapPOField.keyset())
                    {
                        mapAPINameLablePO.put(mapPOField.get(str).getDescribe().getName(),mapPOField.get(str).getDescribe().getLabel());
                    }
                }
                //COMM_PerformanceUtils.stop('004:j: INITIALSYNCorBATCHCALL _ LoopingRmaSO');
                system.debug('mapAPINameLablePO'+mapAPINameLablePO);
                SVMXC.INTF_WebServicesDef.SVMXMap mapForDocAttr = new SVMXC.INTF_WebServicesDef.SVMXMap();
                mapForDocAttr.key = 'DOCUMENTATTRIBUTE';
                list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForDocAttr = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
                
                //COMM_PerformanceUtils.start('004:k: INITIALSYNCorBATCHCALL _ LoopingToPopulateLstDocAtt');
                
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
                            
                            //COMM_PerformanceUtils.start('004:k:1: INITIALSYNCorBATCHCALL _ LoopingToPopulateLstDocAtt _ QueryingLstDocAtt');
                            
                            list<Sobject> Sobj = Database.Query(strQuery);
                            
                            //COMM_PerformanceUtils.stop('004:k:1: INITIALSYNCorBATCHCALL _ LoopingToPopulateLstDocAtt _ QueryingLstDocAtt');
                            
                            if(Sobj.size() > 0)
                                temp.value = String.valueof(Sobj[0].get(lstDocumentAttribute[i].SVMXC__FKey_Name_Field__c));
                            lstSVMXMapForDocAttr.add(temp);
                        }
                        else if(lstDocumentAttribute[i].SVMXC__Display_Type__c != 'REFERENCE')
                        {
                            SVMXC.INTF_WebServicesDef.SVMXMap temp = new SVMXC.INTF_WebServicesDef.SVMXMap();
                            temp.key = mapAPINameLablePO.get(lstDocumentAttribute[i].SVMXC__Field_Name__c);
                            temp.value = string.valueof(orderHeader.get(lstDocumentAttribute[i].SVMXC__Field_Name__c));
                            lstSVMXMapForDocAttr.add(temp);
                        }    
                    }   
                }
                //COMM_PerformanceUtils.stop('004:k: INITIALSYNCorBATCHCALL _ LoopingToPopulateLstDocAtt');
                
                mapForDocAttr.valueMap = lstSVMXMapForDocAttr;
                lstSVMXMapForResponse.add(mapForDocAttr);
            }
            lstDocumentAttribute.clear();
            system.debug('lstSVMXMapForResponse'+lstSVMXMapForResponse);
            //Make Column info for Order line Table...
            SVMXC.INTF_WebServicesDef.SVMXMap mapForColumnInfo = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForColumnInfo.key = 'COLUMNINFO';
            mapForColumnInfo.value = MakeColumn(lstConfigData,strProcessType);
            system.debug('COLUMNINFO'+mapForColumnInfo);
            lstSVMXMapForResponse.add(mapForColumnInfo);
            mapForColumnInfo = new SVMXC.INTF_WebServicesDef.SVMXMap();
            /*
            //Make Sorting for Column Info..
            SVMXC.INTF_WebServicesDef.SVMXMap mapForSorting = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForSorting.key = 'SORTINGINFO';
            mapForSorting.value = getSortingColumns(lstConfigData,strProcessType);
            lstSVMXMapForResponse.add(mapForSorting);
            */
            SVMXC.INTF_WebServicesDef.SVMXMap wrpSettings = new SVMXC.INTF_WebServicesDef.SVMXMap();
            wrpSettings.key = 'MAPKEYVALUE';
            if(strProcessType.toUpperCase() == 'PROCESSRECEIPT')
            {
                // Get the delivery rule and identify whether it's saying to perform delivery on receipt
                try
                {
                    //COMM_PerformanceUtils.start('004:l: INITIALSYNCorBATCHCALL _ QueryingProcToGetDelveryRule');
                
                    if(isDebugMode)
                        strLog += '\n \n'+'SOQL_QUERY : Select SVMXC__Type__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c = \'Delivery Rule\' And SVMXC__Location__c =: '+orderHeader.SVMXC__Destination_Location__c;
                    queryFields = new List<String> {'SVMXC__Type__c', 'SVMXC__Record_Type_Name__c','SVMXC__Location__c'};
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    SVMXC__ServiceMax_Processes__c deliveryRule = [Select SVMXC__Type__c from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Delivery Rule' And SVMXC__Location__c = :orderHeader.SVMXC__Destination_Location__c]; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    //COMM_PerformanceUtils.stop('004:l: INITIALSYNCorBATCHCALL _ QueryingProcToGetDelveryRule');
                    
                    SVMXC.INTF_WebServicesDef.SVMXMap wrpIsFullyAutomatic = new SVMXC.INTF_WebServicesDef.SVMXMap();
                    wrpIsFullyAutomatic.key = 'DELIVERYTYPE';
                    if(deliveryRule.SVMXC__Type__c == 'Automatic')
                    {
                        wrpIsFullyAutomatic.value = 'AUTOMATIC';
                    }
                    else
                    {
                        wrpIsFullyAutomatic.value = 'MANUAL';
                    }
                    wrpSettings.valueMap = new List<INTF_WebServicesDef.SVMXMap>();
                    wrpSettings.valueMap.add(wrpIsFullyAutomatic);
                }
                catch(exception ex){
                    //COMM_PerformanceUtils.stop('004:l: INITIALSYNCorBATCHCALL _ QueryingProcToGetDelveryRule');
                }
            }
            //Get Events Associated with Process 
            list<SVMXC__SFM_Event__c> Events = new list<SVMXC__SFM_Event__c>();
            
            //COMM_PerformanceUtils.start('004:m: INITIALSYNCorBATCHCALL _ QueryingProcToGetEvent');
            
            if(isDebugMode)
                strLog += '\n \n'+'SOQL_QUERY :For Sobject SVMXC__SFM_Event__c - Select SVMXC__ServiceMax_Process__c, SVMXC__Namespace__c, SVMXC__Method__c, SVMXC__Event_Type__c, SVMXC__Class__c, Name, Id From SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c =: '+SVMXProcess.id;
            queryFields = new List<String> {'SVMXC__ServiceMax_Process__c', 'SVMXC__Namespace__c', 'SVMXC__Method__c', 'SVMXC__Event_Type__c', 'SVMXC__Class__c', 'Name', 'Id' };
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SFM_Event__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            Events = [Select SVMXC__ServiceMax_Process__c, SVMXC__Namespace__c, SVMXC__Method__c, SVMXC__Event_Type__c, SVMXC__Class__c, Name, Id From SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c =: SVMXProcess.id]; //SDL-SVMX-READ-FLS-ENFORCED
            
            //COMM_PerformanceUtils.stop('004:m: INITIALSYNCorBATCHCALL _ QueryingProcToGetEvent');
            
            if(Events.size() > 0)
            {
                //COMM_PerformanceUtils.start('004:n: INITIALSYNCorBATCHCALL _ LoopingEvent');
            
                for(SVMXC__SFM_Event__c evt : Events)
                {
                    if(evt.SVMXC__Namespace__c != null && evt.SVMXC__Class__c != null && evt.SVMXC__Method__c != null)
                    {
                        SVMXC.INTF_WebServicesDef.SVMXMap eventMap = new SVMXC.INTF_WebServicesDef.SVMXMap();
                        eventMap.key = 'EVENT_'+evt.SVMXC__Event_Type__c.touppercase();
                        if(evt.SVMXC__Namespace__c == NULL)
                            evt.SVMXC__Namespace__c = '';
                        eventMap.value = evt.SVMXC__Namespace__c +':'+evt.SVMXC__Class__c+':'+evt.SVMXC__Method__c;
                        wrpSettings.valueMap.add(eventMap);
                        
                    }
                }
                //COMM_PerformanceUtils.stop('004:n: INITIALSYNCorBATCHCALL _ LoopingEvent');
            }
            if(wrpSettings.valueMap.size() > 0)
            {
                lstSVMXMapForResponse.add(wrpSettings);
            }
        
        }
        else if(strEventType != null && strEventType.length() > 0 && strEventType == 'BATCHCALL')
        {
            if(strRecordId != null && strRecordId.length() > 0)
            {
                if(strProcessType.toUpperCase() == 'PROCESSRECEIPT' || strProcessType.toUpperCase() == 'DELIVERYONRECEIPT' || strProcessType.toUpperCase() == 'FULFILLMENTPROCESS')
                {
                    //COMM_PerformanceUtils.start('004:a: INITIALSYNCorBATCHCALL _ QueryingServiceMaxProc');
                
                    if(isDebugMode)
                        strLog += '\n \n'+'SOQL_QUERY :For Sobject SVMXC__RMA_Shipment_Order__c - Select SVMXC__Warehouse__c,SVMXC__RMA_Type__c, SVMXC__Fulfillment_Type__c, SVMXC__Master_Order__c, SVMXC__Tracking_Number__c, SVMXC__Total_Price2__c, SVMXC__Source_Zip__c, SVMXC__Source_Street__c, SVMXC__Source_State__c, SVMXC__Source_Location__c, SVMXC__Source_Location__r.Name, SVMXC__Source_Country__c, SVMXC__Source_City__c, SVMXC__Shipping_Terms__c, SVMXC__Shipping_Receiving_Notes__c, SVMXC__Shipping_Courier__c, SVMXC__Shipment_Reference__c, SVMXC__Shipment_Age_Bucket__c, SVMXC__Service_Order__c, SVMXC__Service_Engineer__c, SVMXC__Sales_Order_Number__c, SVMXC__SESSION_ID__c, SVMXC__Receiving_Courier__c, SVMXC__RMA_Age_Bucket__c, SVMXC__Priority__c, SVMXC__Parts_Request__c, SVMXC__Partner_Contact__c, SVMXC__Partner_Account__c, SVMXC__Order_Type__c, SVMXC__Order_Status__c, SVMXC__IsPartner__c, SVMXC__IsPartnerRecord__c, SVMXC__Expected_Receive_Date__c, SVMXC__Expected_Delivery_Date__c, SVMXC__EndpointURL__c, SVMXC__Destination_Zip__c, SVMXC__Destination_Street__c, SVMXC__Destination_State__c, SVMXC__Destination_Location__c,SVMXC__Destination_Location__r.Name, SVMXC__Destination_Country__c, SVMXC__Destination_City__c, SVMXC__Delivery_Option__c, SVMXC__Contact__c, SVMXC__Company__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Case__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Billing_Type__c, SVMXC__Bill_To__c, SVMXC__Address_Type__c, SVMXC__On_Hold__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__RMA_Shipment_Order__c where id =: '+strRecordId+' and RecordType.Name =\'RMA\' and SVMXC__On_Hold__c = false';
                    queryFields = new List<String> {'SVMXC__Warehouse__c','SVMXC__RMA_Type__c','SVMXC__Fulfillment_Type__c','SVMXC__Master_Order__c','SVMXC__Tracking_Number__c','SVMXC__Total_Price2__c','SVMXC__Source_Zip__c','SVMXC__Source_Street__c','SVMXC__Source_State__c','SVMXC__Source_Location__c','SVMXC__Source_Location__r.Name','SVMXC__Source_Country__c','SVMXC__Source_City__c','SVMXC__Shipping_Terms__c','SVMXC__Shipping_Receiving_Notes__c','SVMXC__Shipping_Courier__c','SVMXC__Shipment_Reference__c','SVMXC__Shipment_Age_Bucket__c','SVMXC__Service_Order__c','SVMXC__Service_Engineer__c','SVMXC__Sales_Order_Number__c','SVMXC__SESSION_ID__c','SVMXC__Receiving_Courier__c','SVMXC__RMA_Age_Bucket__c','SVMXC__Priority__c','SVMXC__Parts_Request__c','SVMXC__Partner_Contact__c','SVMXC__Partner_Account__c','SVMXC__Order_Type__c','SVMXC__Order_Status__c','SVMXC__IsPartner__c','SVMXC__IsPartnerRecord__c','SVMXC__Expected_Receive_Date__c','SVMXC__Expected_Delivery_Date__c','SVMXC__EndpointURL__c','SVMXC__Destination_Zip__c','SVMXC__Destination_Street__c','SVMXC__Destination_State__c','SVMXC__Destination_Location__c','SVMXC__Destination_Location__r.Name','SVMXC__Destination_Country__c','SVMXC__Destination_City__c','SVMXC__Delivery_Option__c','SVMXC__Contact__c','SVMXC__Company__c','SVMXC__Closed_On__c','SVMXC__Closed_By__c','SVMXC__Case__c','SVMXC__Canceled_On__c','SVMXC__Canceled_By__c','SVMXC__Billing_Type__c','SVMXC__Bill_To__c','SVMXC__Address_Type__c','SVMXC__On_Hold__c','RecordTypeId','OwnerId','Name','LastModifiedDate','LastModifiedById',' IsDeleted','Id','CreatedDate','CreatedById'};
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    orderHeader = [Select SVMXC__Warehouse__c,SVMXC__RMA_Type__c, SVMXC__Fulfillment_Type__c, SVMXC__Master_Order__c, SVMXC__Tracking_Number__c, SVMXC__Total_Price2__c, SVMXC__Source_Zip__c, SVMXC__Source_Street__c, SVMXC__Source_State__c, SVMXC__Source_Location__c, SVMXC__Source_Location__r.Name, SVMXC__Source_Country__c, SVMXC__Source_City__c, SVMXC__Shipping_Terms__c, SVMXC__Shipping_Receiving_Notes__c, SVMXC__Shipping_Courier__c, SVMXC__Shipment_Reference__c, SVMXC__Shipment_Age_Bucket__c, SVMXC__Service_Order__c, SVMXC__Service_Engineer__c, SVMXC__Sales_Order_Number__c, SVMXC__SESSION_ID__c, SVMXC__Receiving_Courier__c, SVMXC__RMA_Age_Bucket__c, SVMXC__Priority__c, SVMXC__Parts_Request__c, SVMXC__Partner_Contact__c, SVMXC__Partner_Account__c, SVMXC__Order_Type__c, SVMXC__Order_Status__c, SVMXC__IsPartner__c, SVMXC__IsPartnerRecord__c, SVMXC__Expected_Receive_Date__c, SVMXC__Expected_Delivery_Date__c, SVMXC__EndpointURL__c, SVMXC__Destination_Zip__c, SVMXC__Destination_Street__c, SVMXC__Destination_State__c, SVMXC__Destination_Location__c,SVMXC__Destination_Location__r.Name, SVMXC__Destination_Country__c, SVMXC__Destination_City__c, SVMXC__Delivery_Option__c, SVMXC__Contact__c, SVMXC__Company__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Case__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Billing_Type__c, SVMXC__Bill_To__c, SVMXC__Address_Type__c, SVMXC__On_Hold__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__RMA_Shipment_Order__c where id =: strRecordId and RecordType.Name = 'RMA' and SVMXC__On_Hold__c = false]; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    //COMM_PerformanceUtils.stop('004:a: INITIALSYNCorBATCHCALL _ QueryingServiceMaxProc');
                    
                } 
                else if(strProcessType.toUpperCase() == 'PICKNMOVE' || strProcessType.toUpperCase() == 'SHIPCONFIRM')
                {
                    //COMM_PerformanceUtils.start('004:a: INITIALSYNCorBATCHCALL _ QueryingRmaSO');
                
                    if(isDebugMode)
                        strLog += '\n \n'+'SOQL_QUERY :For Sobject SVMXC__RMA_Shipment_Order__c - Select SVMXC__Warehouse__c,SVMXC__RMA_Type__c, SVMXC__Fulfillment_Type__c, SVMXC__Master_Order__c, SVMXC__Tracking_Number__c, SVMXC__Total_Price2__c, SVMXC__Source_Zip__c, SVMXC__Source_Street__c, SVMXC__Source_State__c, SVMXC__Source_Location__c, SVMXC__Source_Location__r.Name, SVMXC__Source_Country__c, SVMXC__Source_City__c, SVMXC__Shipping_Terms__c, SVMXC__Shipping_Receiving_Notes__c, SVMXC__Shipping_Courier__c, SVMXC__Shipment_Reference__c, SVMXC__Shipment_Age_Bucket__c, SVMXC__Service_Order__c, SVMXC__Service_Engineer__c, SVMXC__Sales_Order_Number__c, SVMXC__SESSION_ID__c, SVMXC__Receiving_Courier__c, SVMXC__RMA_Age_Bucket__c, SVMXC__Priority__c, SVMXC__Parts_Request__c, SVMXC__Partner_Contact__c, SVMXC__Partner_Account__c, SVMXC__Order_Type__c, SVMXC__Order_Status__c, SVMXC__IsPartner__c, SVMXC__IsPartnerRecord__c, SVMXC__Expected_Receive_Date__c, SVMXC__Expected_Delivery_Date__c, SVMXC__EndpointURL__c, SVMXC__Destination_Zip__c, SVMXC__Destination_Street__c, SVMXC__Destination_State__c, SVMXC__Destination_Location__c,SVMXC__Destination_Location__r.Name, SVMXC__Destination_Country__c, SVMXC__Destination_City__c, SVMXC__Delivery_Option__c, SVMXC__Contact__c, SVMXC__Company__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Case__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Billing_Type__c, SVMXC__Bill_To__c, SVMXC__Address_Type__c, SVMXC__On_Hold__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById From SVMXC__RMA_Shipment_Order__c where id =: '+strRecordId+' and RecordType.Name =\'Shipment\' and SVMXC__On_Hold__c = false';
                    queryFields = new List<String> {'SVMXC__Warehouse__c','SVMXC__RMA_Type__c','SVMXC__Master_Order__c','SVMXC__Fulfillment_Type__c','SVMXC__Tracking_Number__c','SVMXC__Total_Price2__c','SVMXC__Source_Zip__c','SVMXC__Source_Street__c','SVMXC__Source_State__c','SVMXC__Source_Location__c','SVMXC__Source_Location__r.Name','SVMXC__Source_Country__c','SVMXC__Source_City__c','SVMXC__Shipping_Terms__c','SVMXC__Shipping_Receiving_Notes__c','SVMXC__Shipping_Courier__c','SVMXC__Shipment_Reference__c','SVMXC__Shipment_Age_Bucket__c','SVMXC__Service_Order__c','SVMXC__Service_Engineer__c','SVMXC__Sales_Order_Number__c','SVMXC__SESSION_ID__c','SVMXC__Receiving_Courier__c','SVMXC__RMA_Age_Bucket__c','SVMXC__Priority__c','SVMXC__Parts_Request__c','SVMXC__Partner_Contact__c','SVMXC__Partner_Account__c','SVMXC__Order_Type__c','SVMXC__Order_Status__c','SVMXC__IsPartner__c','SVMXC__IsPartnerRecord__c','SVMXC__Expected_Receive_Date__c','SVMXC__Expected_Delivery_Date__c','SVMXC__EndpointURL__c','SVMXC__Destination_Zip__c','SVMXC__Destination_Street__c','SVMXC__Destination_State__c','SVMXC__Destination_Location__c','SVMXC__Destination_Location__r.Name','SVMXC__Destination_Country__c','SVMXC__Destination_City__c','SVMXC__Delivery_Option__c','SVMXC__Contact__c','SVMXC__Company__c','SVMXC__Closed_On__c','SVMXC__Closed_By__c','SVMXC__Case__c','SVMXC__Canceled_On__c','SVMXC__Canceled_By__c','SVMXC__Billing_Type__c','SVMXC__Bill_To__c','SVMXC__Address_Type__c','SVMXC__On_Hold__c','RecordTypeId','OwnerId','Name','LastModifiedDate','LastModifiedById',' IsDeleted','Id','CreatedDate','CreatedById'};
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Order__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    orderHeader = [Select SVMXC__Warehouse__c, SVMXC__RMA_Type__c,SVMXC__Master_Order__c, SVMXC__Fulfillment_Type__c, SVMXC__Tracking_Number__c, SVMXC__Total_Price2__c, SVMXC__Source_Zip__c, SVMXC__Source_Street__c, SVMXC__Source_State__c, SVMXC__Source_Location__c, SVMXC__Source_Location__r.Name, SVMXC__Source_Country__c, SVMXC__Source_City__c, SVMXC__Shipping_Terms__c, SVMXC__Shipping_Receiving_Notes__c, SVMXC__Shipping_Courier__c, SVMXC__Shipment_Reference__c, SVMXC__Shipment_Age_Bucket__c, SVMXC__Service_Order__c, SVMXC__Service_Engineer__c, SVMXC__Sales_Order_Number__c, SVMXC__SESSION_ID__c, SVMXC__Receiving_Courier__c, SVMXC__RMA_Age_Bucket__c, SVMXC__Priority__c, SVMXC__Parts_Request__c, SVMXC__Partner_Contact__c, SVMXC__Partner_Account__c, SVMXC__Order_Type__c, SVMXC__Order_Status__c, SVMXC__IsPartner__c, SVMXC__IsPartnerRecord__c, SVMXC__Expected_Receive_Date__c, SVMXC__Expected_Delivery_Date__c, SVMXC__EndpointURL__c, SVMXC__Destination_Zip__c, SVMXC__Destination_Street__c, SVMXC__Destination_State__c, SVMXC__Destination_Location__c,SVMXC__Destination_Location__r.Name, SVMXC__Destination_Country__c, SVMXC__Destination_City__c, SVMXC__Delivery_Option__c, SVMXC__Contact__c, SVMXC__Company__c, SVMXC__Closed_On__c, SVMXC__Closed_By__c, SVMXC__Case__c, SVMXC__Canceled_On__c, SVMXC__Canceled_By__c, SVMXC__Billing_Type__c, SVMXC__Bill_To__c, SVMXC__Address_Type__c, SVMXC__On_Hold__c, RecordTypeId, OwnerId, Name, LastModifiedDate, LastModifiedById,  IsDeleted, Id, CreatedDate, CreatedById From SVMXC__RMA_Shipment_Order__c where id =: strRecordId and RecordType.Name = 'Shipment' and SVMXC__On_Hold__c = false]; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    //COMM_PerformanceUtils.stop('004:a: INITIALSYNCorBATCHCALL _ QueryingRmaSO');
                    
                }
                system.debug('orderHeader :'+orderHeader);
            }
            aplOrder.orderHdrRecord = orderHeader;
            
            set<String> setBatchIds = new set<String>();
            setBatchIds.addall(lstBatchIds);
            set<String> setCurrnetBatchIds = new set<String>();
            list<String> lstNextBatchIds = new list<String>();
            list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> lstOrderLine = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
            if(lstBatchIds.size() > 0 && lstBatchIds.size() >= intBatchsize)
            {
                //COMM_PerformanceUtils.start('004:b: INITIALSYNCorBATCHCALL _ LoopingCurrBatchID');
            
                for(Integer i = 0;i<intBatchsize;i++)
                {
                    setCurrnetBatchIds.add(lstBatchIds[i]);
                }
                //COMM_PerformanceUtils.stop('004:b: INITIALSYNCorBATCHCALL _ LoopingCurrBatchID');
            }
            else if(lstBatchIds.size() < intBatchsize)
            {
                //COMM_PerformanceUtils.start('004:b: INITIALSYNCorBATCHCALL _ LoopingCurrBatchID');
            
                for(Integer i = 0;i<lstBatchIds.size();i++)
                {
                    setCurrnetBatchIds.add(lstBatchIds[i]);
                }
                //COMM_PerformanceUtils.stop('004:b: INITIALSYNCorBATCHCALL _ LoopingCurrBatchID');
            }
            
            system.debug('setCurrnetBatchIds'+setCurrnetBatchIds.size()+setCurrnetBatchIds);
            Boolean result = setBatchIds.removeall(setCurrnetBatchIds);
            if(result)
                lstNextBatchIds.addall(setBatchIds);
            system.debug('lstNextBatchIds'+lstNextBatchIds.size()+lstNextBatchIds);
            //Add Next Batch IDs to response..
            SVMXC.INTF_WebServicesDef.SVMXMap mapForLineIds = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapForLineIds.key = 'MAPKEYVALUES';
            SVMXC.INTF_WebServicesDef.SVMXMap mapLineIds = new SVMXC.INTF_WebServicesDef.SVMXMap();
            mapLineIds.key = 'LINEIDS';
            mapLineIds.values.addall(lstNextBatchIds);
            mapForLineIds.valueMap.add(mapLineIds);
            lstSVMXMapForResponse.add(mapForLineIds);
            if(strProcessId != null && strProcessId.length() > 0)
            {
                //COMM_PerformanceUtils.start('004:c: INITIALSYNCorBATCHCALL _ QueryingSMProc');
                if(isDebugMode)
                    strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__ServiceMax_Processes__c - Select SVMXC__Target_Record_Type__c, SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Resolve_Unexpected_SN_To_IB__c, SVMXC__Record_Type_Name__c, SVMXC__Purpose__c,  SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Process2__c, SVMXC__Process1__c, SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Parent_Column_Name__c, SVMXC__Node_Parent__c, SVMXC__Node_Parent_API__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c, SVMXC__MapID__c, SVMXC__Final_Exception_Process__c,  SVMXC__Entitlement_Scope__c, SVMXC__Entitlement_By__c,SVMXC__Description__c,  SVMXC__Default_Location__c, SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Consider_Location_From__c, SVMXC__Consider_Location_From_Object__c, SVMXC__Child_Object_Criteria__c, SVMXC__Child_Error_Msg__c, SVMXC__Child_Error_Msg2__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, SVMXC__APL_Split_Lines__c, SVMXC__APL_Shipment_Note_Template__c, SVMXC__APL_Serial_Number_Source__c, SVMXC__APL_Scan_First__c, SVMXC__APL_Route_Rule_Type__c, SVMXC__APL_Print_RMA_Template__c, SVMXC__APL_Print_Label_Template__c, SVMXC__APL_Perform_Route_Calculations__c, SVMXC__APL_Perform_Entitlement__c, SVMXC__APL_Group_Work_Order_By__c, SVMXC__APL_Field_Name__c, SVMXC__APL_Create_Work_Order_On__c, SVMXC__APL_Create_WO_Preference__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Allow_Partial_Shipment__c, SVMXC__APL_Allow_Partial_Delivery__c, SVMXC__APL_Action_On_Unexpected_SN__c, SVMXC__APL_Action_On_Unexpected_Product__c, SVMXC__APL_Action_On_Less_Qty__c, SVMXC__APL_Action_On_Excess_Qty__c, RecordTypeId, OwnerId, Name, Id From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: '+strProcessId+ 'OR id =: '+strProcessId;
                queryFields = new List<String> {'SVMXC__Target_Record_Type__c','SVMXC__Target_Object_Name__c','SVMXC__Submodule__c','SVMXC__SubmoduleID__c','SVMXC__Source_Object_Name__c','SVMXC__SettingID__c','SVMXC__Sequence__c','SVMXC__Resolve_Unexpected_SN_To_IB__c','SVMXC__Record_Type_Name__c','SVMXC__Purpose__c',' SVMXC__Process__c','SVMXC__ProcessID__c','SVMXC__Process2__c','SVMXC__Process1__c','SVMXC__Parent_Object__c','SVMXC__Parent_Object_Criteria__c','SVMXC__Parent_Error_Msg__c','SVMXC__Parent_Error_Msg2__c','SVMXC__Parent_Column_Name__c','SVMXC__Node_Parent__c','SVMXC__Node_Parent_API__c','SVMXC__Name__c','SVMXC__Module__c','SVMXC__ModuleID__c','SVMXC__MapID__c','SVMXC__Final_Exception_Process__c',' SVMXC__Entitlement_Scope__c','SVMXC__Entitlement_By__c','SVMXC__Description__c',' SVMXC__Default_Location__c','SVMXC__Data_Type__c','SVMXC__Counter_Vs_Dates_Rule__c','SVMXC__Consider_Location_From__c','SVMXC__Consider_Location_From_Object__c','SVMXC__Child_Object_Criteria__c','SVMXC__Child_Error_Msg__c','SVMXC__Child_Error_Msg2__c','SVMXC__Advance_Expression__c','SVMXC__Active__c','SVMXC__APL_Split_Lines__c','SVMXC__APL_Shipment_Note_Template__c','SVMXC__APL_Serial_Number_Source__c','SVMXC__APL_Scan_First__c','SVMXC__APL_Route_Rule_Type__c','SVMXC__APL_Print_RMA_Template__c','SVMXC__APL_Print_Label_Template__c','SVMXC__APL_Perform_Route_Calculations__c','SVMXC__APL_Perform_Entitlement__c','SVMXC__APL_Group_Work_Order_By__c','SVMXC__APL_Field_Name__c','SVMXC__APL_Create_Work_Order_On__c','SVMXC__APL_Create_WO_Preference__c','SVMXC__APL_Create_Supplier_RMA__c','SVMXC__APL_Create_Internal_RMA__c','SVMXC__APL_Allow_Partial_Shipment__c','SVMXC__APL_Allow_Partial_Delivery__c','SVMXC__APL_Action_On_Unexpected_SN__c','SVMXC__APL_Action_On_Unexpected_Product__c','SVMXC__APL_Action_On_Less_Qty__c','SVMXC__APL_Action_On_Excess_Qty__c','RecordTypeId','OwnerId','Name','Id'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                SVMXProcess = [Select SVMXC__Target_Record_Type__c, SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Resolve_Unexpected_SN_To_IB__c, SVMXC__Record_Type_Name__c, SVMXC__Purpose__c,  SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Process2__c, SVMXC__Process1__c, SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Parent_Column_Name__c, SVMXC__Node_Parent__c, SVMXC__Node_Parent_API__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c, SVMXC__MapID__c, SVMXC__Final_Exception_Process__c,  SVMXC__Entitlement_Scope__c, SVMXC__Entitlement_By__c,SVMXC__Description__c,  SVMXC__Default_Location__c, SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Consider_Location_From__c, SVMXC__Consider_Location_From_Object__c, SVMXC__Child_Object_Criteria__c, SVMXC__Child_Error_Msg__c, SVMXC__Child_Error_Msg2__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, SVMXC__APL_Split_Lines__c, SVMXC__APL_Shipment_Note_Template__c, SVMXC__APL_Serial_Number_Source__c, SVMXC__APL_Scan_First__c, SVMXC__APL_Route_Rule_Type__c, SVMXC__APL_Print_RMA_Template__c, SVMXC__APL_Print_Label_Template__c, SVMXC__APL_Perform_Route_Calculations__c, SVMXC__APL_Perform_Entitlement__c, SVMXC__APL_Group_Work_Order_By__c, SVMXC__APL_Field_Name__c, SVMXC__APL_Create_Work_Order_On__c, SVMXC__APL_Create_WO_Preference__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Allow_Partial_Shipment__c, SVMXC__APL_Allow_Partial_Delivery__c, SVMXC__APL_Action_On_Unexpected_SN__c, SVMXC__APL_Action_On_Unexpected_Product__c, SVMXC__APL_Action_On_Less_Qty__c, SVMXC__APL_Action_On_Excess_Qty__c, RecordTypeId, OwnerId, Name, Id From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strProcessId or id =: strProcessId]; //SDL-SVMX-READ-FLS-ENFORCED
                
                //COMM_PerformanceUtils.stop('004:c: INITIALSYNCorBATCHCALL _ QueryingSMProc');
                
                system.debug('SVMXProcess'+SVMXProcess);
                if(SVMXProcess != null && SVMXProcess.id != null )
                {
                    aplOrder.svmxProcess = SVMXProcess;
                    
                    //COMM_PerformanceUtils.start('004:d: INITIALSYNCorBATCHCALL _ QueryingSMConfata');
                    
                    if(isDebugMode)
                        strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__ServiceMax_Config_Data__c - select id,Name,RecordTypeId,SVMXC__Configuration_Type__c,SVMXC__Field_Name__c,SVMXC__Dispatch_Process__c,SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where  RecordTypeId =:'+strFldMapRecTypeId+ ' and SVMXC__Dispatch_Process__c =: '+SVMXProcess.id;
                    queryFields = new List<String> {'id','Name','RecordTypeId','SVMXC__Configuration_Type__c','SVMXC__Field_Name__c','SVMXC__Dispatch_Process__c','SVMXC__Display_Type__c', 'SVMXC__Field_Relationship_Name__c','SVMXC__FKey_Name_Field__c','SVMXC__Object_Name__c'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    lstConfigData = [select id,Name,RecordTypeId,SVMXC__Configuration_Type__c,SVMXC__Field_Name__c,SVMXC__Dispatch_Process__c,SVMXC__Display_Type__c, SVMXC__Field_Relationship_Name__c,SVMXC__FKey_Name_Field__c,SVMXC__Object_Name__c from SVMXC__ServiceMax_Config_Data__c where  RecordTypeId =: strFldMapRecTypeId and SVMXC__Dispatch_Process__c =: SVMXProcess.id]; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    //COMM_PerformanceUtils.stop('004:d: INITIALSYNCorBATCHCALL _ QueryingSMConfata');
                    
                    system.debug('lstConfigData :'+lstConfigData);
                    if(lstConfigData.size() > 0)
                    {
                        aplOrder.configData = lstConfigData;
                        //Loop config data and get the fields for the procuct attribute and document attrbutes fields and add in line query.
                        if(lstConfigData.size() > 0)
                        {
                            //COMM_PerformanceUtils.start('004:e: INITIALSYNCorBATCHCALL _ LoopingConfData');
                        
                            for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
                            { 
                                if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE' && !setPOLines.contains('SVMXC__Product__r.'+config.SVMXC__Field_Name__c))
                                {
                                    StrOrderLineFields += ', SVMXC__Product__r.'+config.SVMXC__Field_Name__c;
                                    setPOLines.add('SVMXC__Product__r.'+config.SVMXC__Field_Name__c);
                                }    
                                if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE')
                                {    
                                    if(config.SVMXC__Display_Type__c != null && config.SVMXC__Display_Type__c.touppercase() == 'REFERENCE' && config.SVMXC__Field_Relationship_Name__c != null && config.SVMXC__FKey_Name_Field__c != null && !setPOLines.contains(config.SVMXC__Field_Relationship_Name__c+'.'+config.SVMXC__FKey_Name_Field__c))
                                    {
                                        StrOrderLineFields += ' , '+config.SVMXC__Field_Relationship_Name__c+'.'+config.SVMXC__FKey_Name_Field__c;
                                        setPOLines.add(config.SVMXC__Field_Relationship_Name__c+'.'+config.SVMXC__FKey_Name_Field__c);
                                    }
                                    else if(config.SVMXC__Display_Type__c != null && config.SVMXC__Display_Type__c.touppercase() != 'REFERENCE' && !setPOLines.contains(config.SVMXC__Field_Name__c))
                                    {
                                        StrOrderLineFields += ' , '+config.SVMXC__Field_Name__c;
                                        setPOLines.add(config.SVMXC__Field_Name__c);
                                    }   
                                }  
                                else if(config.SVMXC__Configuration_Type__c == 'DOCUMENT_ATTRIBUTE')  
                                    lstDocumentAttribute.add(config);
                            }
                            //COMM_PerformanceUtils.stop('004:e: INITIALSYNCorBATCHCALL _ LoopingConfData');
                        } 
                    }   
                }   
            }
            //get field for source updates and add them in query..
            SVMXC.INTF_WebServicesDef.INTF_SFMResponse responseAPLUtils = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
            SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            SVMXC.INTF_WebServicesDef.SVMXMap recordIdMap = new SVMXC.INTF_WebServicesDef.SVMXMap();
            SVMXC.INTF_WebServicesDef.SVMXMap processTypeMap = new SVMXC.INTF_WebServicesDef.SVMXMap();
            recordIdMap.key = 'SVMX_RECORDID';
            recordIdMap.value = SVMXProcess.id;
            req.valueMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
            req.valueMap.add(recordIdMap);
            processTypeMap.key = 'SVMX_PROCESSTYPE';
            processTypeMap.value = strProcessType;
            req.valueMap.add(processTypeMap);
            responseAPLUtils = aplUtil.getFieldsToQuery(req);
            system.debug('responseAPLUtils'+responseAPLUtils);
            if(responseAPLUtils.success)
            {
                list<String> lstField = new list<String>();
                //COMM_PerformanceUtils.start('004:f: INITIALSYNCorBATCHCALL _ LoopingRespAPLUtils');
                if(responseAPLUtils.valueMap != null && responseAPLUtils.valueMap.size() > 0)
                {
                    for(Integer i = 0;i<responseAPLUtils.valueMap.size();i++)
                    {
                        if(responseAPLUtils.valueMap[i].key == 'FIELDLIST')
                            lstField = responseAPLUtils.valueMap[i].values;
                    }
                }
                //COMM_PerformanceUtils.stop('004:f: INITIALSYNCorBATCHCALL _ LoopingRespAPLUtils');
                //COMM_PerformanceUtils.start('004:g: INITIALSYNCorBATCHCALL _ LoopingPOLines');
                if(lstField.size() > 0)
                {
                
                    for(Integer i = 0;i<lstField.size();i++)
                    {
                        if(!setPOLines.contains(lstField[i]))
                        {
                            StrOrderLineFields += ', '+lstField[i];
                            setPOLines.add(lstField[i]);
                        }
                    }
                }
                //COMM_PerformanceUtils.stop('004:g: INITIALSYNCorBATCHCALL _ LoopingPOLines');
            }
            //COMM_PerformanceUtils.start('004:h: INITIALSYNCorBATCHCALL _ LoopingOL');
            if(setCurrnetBatchIds.size() > 0)
            {
                queryFields = StrOrderLineFields.split(',');
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__RMA_Shipment_Line__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                String query = 'Select ' +StrOrderLineFields+ '  From SVMXC__RMA_Shipment_Line__c  where Id IN : setCurrnetBatchIds ';
                system.debug('query'+query);
                lstOrderLines = Database.query(query);   
                
                system.debug('lstOrderLines'+lstOrderLines.size()+lstOrderLines);
            }      
            //COMM_PerformanceUtils.stop('004:h: INITIALSYNCorBATCHCALL _ LoopingOL');
            //COMM_PerformanceUtils.start('004:i: INITIALSYNCorBATCHCALL _ LoopingRmaSL');            
            if(lstOrderLines.size() > 0)
            {
                for(SVMXC__RMA_Shipment_Line__c PO : lstOrderLines)
                {
                    mapOrderLines.put(PO.id,PO);
                    if(PO.SVMXC__Product__c != null)
                        setProductId.add(PO.SVMXC__Product__c);
                }
            }
            //COMM_PerformanceUtils.stop('004:i: INITIALSYNCorBATCHCALL _ LoopingRmaSL');
            system.debug('mapOrderLines: '+mapOrderLines.size()+mapOrderLines);
            system.debug('setProductId: '+setProductId.size()+setProductId);
            if(strProcessType.toUpperCase() == 'DELIVERYONRECEIPT')
            {
                // Get delivery rules
                SVMXC__ServiceMax_Processes__c deliveryRule;
                Id defaultDeliveryRuleId;
                String defaultDeliveryRuleName;
                try
                {
                    //COMM_PerformanceUtils.start('004:j: INITIALSYNCorBATCHCALL _ QueryingProcessObjDefLoc');
                    
                    if(isDebugMode)
                        strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__ServiceMax_Processes__c - Select SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c =\'Delivery Rule\' And SVMXC__Location__c =: '+orderHeader.SVMXC__Destination_Location__c;
                    queryFields = new List<String> {'SVMXC__Default_Location__c', 'SVMXC__Default_Location__r.Name'};
                        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                        }
                    deliveryRule = [Select SVMXC__Default_Location__c, SVMXC__Default_Location__r.Name from SVMXC__ServiceMax_Processes__c where SVMXC__Record_Type_Name__c ='Delivery Rule' And SVMXC__Location__c = :orderHeader.SVMXC__Destination_Location__c]; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    system.debug('deliveryRule'+deliveryRule);
                    defaultDeliveryRuleId = deliveryRule.SVMXC__Default_Location__c;
                    defaultDeliveryRuleName = deliveryRule.SVMXC__Default_Location__r.Name;
                    APL_RMAUtils rmaUtilsCls = new APL_RMAUtils();
                    mapLineLocations = rmaUtilsCls.populateLocationforDelivery(lstOrderLines, deliveryRule, orderHeader.SVMXC__Company__c);
                    system.debug('mapLineLocations' + mapLineLocations);
                    //COMM_PerformanceUtils.stop('004:j: INITIALSYNCorBATCHCALL _ QueryingProcessObjDefLoc');
                }
                catch(exception ex)
                {
                    try
                    {
                        //COMM_PerformanceUtils.start('004:j:1: INITIALSYNCorBATCHCALL _ QueryingProcessObjDefLoc _ QueryingSitedeliveryLoc');
                        if(isDebugMode)
                            strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__Site__c - Select Id, Name from SVMXC__Site__c where SVMXC__IsDefault_Delivery__c = true and SVMXC__Parent__c =: '+orderHeader.SVMXC__Destination_Location__c+ 'limit 1';
                        queryFields = new List<String> {'Name', 'Id', 'SVMXC__IsDefault_Delivery__c', 'SVMXC__Parent__c'};
                            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                        SVMXC__Site__c deliveryLoc = [Select Id, Name from SVMXC__Site__c where SVMXC__IsDefault_Delivery__c = true and SVMXC__Parent__c = : orderHeader.SVMXC__Destination_Location__c limit 1]; //SDL-SVMX-READ-FLS-ENFORCED
                        
                        //COMM_PerformanceUtils.stop('004:j:1: INITIALSYNCorBATCHCALL _ QueryingProcessObjDefLoc _ QueryingSitedeliveryLoc');
                        
                        system.debug('deliveryLoc'+deliveryLoc);
                        defaultDeliveryRuleId = deliveryLoc.Id;
                        defaultDeliveryRuleName = deliveryLoc.Name;
                    }
                    catch(exception ex2)
                    { 
                        //COMM_PerformanceUtils.stop('004:j:1: INITIALSYNCorBATCHCALL _ QueryingProcessObjDefLoc _ QueryingSitedeliveryLoc');
                        //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
                        //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                        throw new SVMXException(system.label.APL003_TAG027);
                    }
                    //COMM_PerformanceUtils.stop('004:j: INITIALSYNCorBATCHCALL _ QueryingProcessObjDefLoc');
                }
                // Populate locations for lines
                SVMXC.INTF_WebServicesDef.SVMXMap availableLocations = new SVMXC.INTF_WebServicesDef.SVMXMap();
                set<Id> setUniqueAvailableLocation = new set<Id>();
                availableLocations.key = 'AVAILABLELOCATIONS';
                list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMapForAvailableLocations = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
                SVMXC.INTF_WebServicesDef.SVMXMap defaultDeliveryLocation = new SVMXC.INTF_WebServicesDef.SVMXMap();
                setUniqueAvailableLocation.add(defaultDeliveryRuleId);
                defaultDeliveryLocation.key = defaultDeliveryRuleId;
                defaultDeliveryLocation.value = defaultDeliveryRuleName;
                lstSVMXMapForAvailableLocations.add(defaultDeliveryLocation);
                SVMXC.INTF_WebServicesDef.SVMXMap mapForDefaultLocInfo = new SVMXC.INTF_WebServicesDef.SVMXMap();
                mapForDefaultLocInfo.key = 'DEFAULTLOCATION';
                mapForDefaultLocInfo.value = defaultDeliveryRuleId + '~|~' + defaultDeliveryRuleName;
                lstSVMXMapForResponse.add(mapForDefaultLocInfo);
                
                //COMM_PerformanceUtils.start('004:k: INITIALSYNCorBATCHCALL _ LoopingRmaSLsetDeliveryLoc');
                
                for(SVMXC__RMA_Shipment_Line__c orderLines : lstOrderLines)
                {
                    SVMXC__RMA_Shipment_Line__c orderLine = mapOrderLines.get(orderLines.Id);
                    if(mapLineLocations.get(orderLine.Id) != NULL)// Updated by rules
                    {
                        orderLine.SVMXC__Delivery_Location__c = mapLineLocations.get(orderLine.Id).key;
                        if(!setUniqueAvailableLocation.contains(orderLine.SVMXC__Delivery_Location__c))
                        {
                            setUniqueAvailableLocation.add(mapLineLocations.get(orderLine.Id).key);
                            lstSVMXMapForAvailableLocations.add(mapLineLocations.get(orderLine.Id));
                        }
                    }
                    else // Set default location, if rules doesnot match
                    orderLine.SVMXC__Delivery_Location__c = defaultDeliveryRuleId;
                    mapOrderLines.put(orderLine.Id, orderLine);
                }
                //COMM_PerformanceUtils.stop('004:k: INITIALSYNCorBATCHCALL _ LoopingRmaSLsetDeliveryLoc');
                //COMM_PerformanceUtils.start('004:l: INITIALSYNCorBATCHCALL _ QueryingSite');
                
                if(isDebugMode)
                    strLog += '\n \n'+'SOQL_QUERY : For Sobject SVMXC__Site__c - Select Id, Name from SVMXC__Site__c where SVMXC__IsDelivery_Location__c = true and SVMXC__Parent__c =: '+orderHeader.SVMXC__Destination_Location__c;
                queryFields = new List<String> {'Name', 'Id', 'SVMXC__IsDelivery_Location__c', 'SVMXC__Parent__c'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                List<SVMXC__Site__c> lstDeliveryLoc = [Select Id, Name from SVMXC__Site__c where SVMXC__IsDelivery_Location__c = true and SVMXC__Parent__c = : orderHeader.SVMXC__Destination_Location__c]; //SDL-SVMX-READ-FLS-ENFORCED
                
                //COMM_PerformanceUtils.stop('004:l: INITIALSYNCorBATCHCALL _ QueryingSite');
                //COMM_PerformanceUtils.start('004:m: INITIALSYNCorBATCHCALL _ LoopInglstDeliveryLoc');
                
                for(SVMXC__Site__c loc: lstDeliveryLoc)
                {
                    if(!setUniqueAvailableLocation.contains(loc.Id))
                    {
                        setUniqueAvailableLocation.add(loc.Id);
                        SVMXC.INTF_WebServicesDef.SVMXMap temp = new SVMXC.INTF_WebServicesDef.SVMXMap();
                        temp.key = loc.Id;
                        temp.value = loc.Name;
                        lstSVMXMapForAvailableLocations.add(temp);
                    }
                }
                //COMM_PerformanceUtils.stop('004:m: INITIALSYNCorBATCHCALL _ LoopInglstDeliveryLoc');
                
                if(lstSVMXMapForAvailableLocations.size() > 0)
                {
                  availableLocations.valueMap = lstSVMXMapForAvailableLocations;
                  lstSVMXMapForResponse.add(availableLocations);
                }
            }
            //If Process Type is Pick & Move We need to send some extra parameters 
            map<String,list<String>> mapProductIdListSerialNo = new map<String,list<String>>();
            map<String,map<String,String>> mapProductIdMapSerialNumberId = new map<String,map<String,String>>();
            if(strProcessType.toUpperCase() == 'PICKNMOVE')
            {
                String strOrderByField = 'LastModifiedDate';
                String strOrder = 'ASC';
                String strNull = 'Last'; 
                //Integer intLimit = 10;
                String strWhereClause = '';
                if(svmxSettingListforAPL003.containskey('SET008'))
                    strOrderByField = svmxSettingListforAPL003.get('SET008');
                if(svmxSettingListforAPL003.containskey('SET009'))
                    strOrder = svmxSettingListforAPL003.get('SET009');
                if(svmxSettingListforAPL003.containskey('SET010'))
                    strNull = svmxSettingListforAPL003.get('SET010');    
                list<SVMXC__ServiceMax_Processes__c> lstprocess = new list<SVMXC__ServiceMax_Processes__c>();
                if(strProcessId != null && strProcessId.length() > 0) {
                    
                    queryFields = new List<String> {'SVMXC__Process3__c', 'SVMXC__ProcessID__c', 'Name', 'Id'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    lstprocess = [Select  SVMXC__Process3__c, SVMXC__ProcessID__c, Name, Id From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strProcessId or id =: strProcessId]; //SDL-SVMX-READ-FLS-ENFORCED
                }
                    
                if(lstprocess != null && lstprocess.size() > 0 && lstprocess[0].SVMXC__Process3__c != null) 
                {
                    queryFields = new List<String> {'id','SVMXC__Parent_Object_Criteria__c'};
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    list<SVMXC__ServiceMax_Processes__c> lstPro = [select id,SVMXC__Parent_Object_Criteria__c from SVMXC__ServiceMax_Processes__c where id =: lstprocess[0].SVMXC__Process3__c and RecordType.Name = 'SVMX Rule']; //SDL-SVMX-READ-FLS-ENFORCED
                    
                    if(lstPro.size() > 0 && lstPro[0].SVMXC__Parent_Object_Criteria__c != null)
                        strWhereClause = lstPro[0].SVMXC__Parent_Object_Criteria__c;
                }
                system.debug('strWhereClause'+strWhereClause);
                map<String,SVMXC__Site__c> mapDeliveryLocation = new map<String,SVMXC__Site__c>();
                map<String,SVMXC__Product_Stock__c> mapProductStock = new map<String,SVMXC__Product_Stock__c>();
                list<SVMXC__Product_Serial__c> lstStockSerial = new list<SVMXC__Product_Serial__c>(); 
                if(orderHeader.SVMXC__Source_Location__c != null)
                {
                    //COMM_PerformanceUtils.start('004:n: INITIALSYNCorBATCHCALL _ QueryingSiteMapDeliveryLoc');
                    queryFields = new List<String> {'Id', 'Name','SVMXC__IsGood_Stock__c', 'SVMXC__IsDelivery_Location__c', 'SVMXC__Parent__c' };
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Site__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    mapDeliveryLocation.putall([Select Id, Name,SVMXC__IsGood_Stock__c from SVMXC__Site__c where SVMXC__IsDelivery_Location__c = true and SVMXC__Parent__c = : orderHeader.SVMXC__Source_Location__c]);
                    
                    //COMM_PerformanceUtils.stop('004:n: INITIALSYNCorBATCHCALL _ QueryingSiteMapDeliveryLoc');
                }
                system.debug('mapDeliveryLocation'+mapDeliveryLocation.size()+mapDeliveryLocation);
                if(setProductId.size() > 0 && mapDeliveryLocation.size() > 0)
                {
                    set<String> setLocation = new set<String>();
                    setLocation = mapDeliveryLocation.keyset();
                    setLocation.remove(Null);
                    //COMM_PerformanceUtils.start('004:o: INITIALSYNCorBATCHCALL _ QueryingProdStock');
                    map<String, Schema.SObjectField> mapProductStockDescribe = new map<String, Schema.SObjectField>();
                    String strfld = '';
                    mapProductStockDescribe = Schema.SObjectType.SVMXC__Product_Stock__c.fields.getMap();
                    list<String> lstPSFld = new list<String>();
                    if(mapProductStockDescribe.size() > 0)
                        lstPSFld = utils.SVMX_getFieldList(mapProductStockDescribe,true);
                    if(lstPSFld.size() > 0)
                        strfld = utils.SVMX_getFieldNamesFromList(lstPSFld);
                    String strQuery = '';
                    system.debug('strWhereClause'+strWhereClause);
                    
                    queryFields = strfld.split(',');
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                    }
                    
                    if(strWhereClause != null && strWhereClause.length() > 0)
                    {
                        strQuery = 'Select '+strfld+ ' From  SVMXC__Product_Stock__c Where '+strWhereClause+' AND SVMXC__Status__c = \'Available\' AND SVMXC__Product__c IN : setProductId AND SVMXC__Location__c IN : setLocation ';
                    }   
                    else
                        strQuery = 'Select '+strfld+ ' From  SVMXC__Product_Stock__c Where SVMXC__Status__c = \'Available\' and SVMXC__Product__c IN : setProductId and SVMXC__Location__c IN : setLocation';
                    system.debug('strQuery'+strQuery);
                    mapProductStock.putall((list<SVMXC__Product_Stock__c>)Database.query(strQuery));
                    
                    //COMM_PerformanceUtils.stop('004:o: INITIALSYNCorBATCHCALL _ QueryingProdStock');
                }
                system.debug('mapProductStock'+mapProductStock.size()+mapProductStock);
                map<String,String> map1 = new map<String,String>(); 
                if(mapProductStock.size() > 0)
                {
                    COMM_PerformanceUtils.start('004:p: INITIALSYNCorBATCHCALL _ QueryingProdSerial');
                    map<String, Schema.SObjectField> mapStockSerialDescribe = new map<String, Schema.SObjectField>();
                    String strStockSerialfld = '';
                    mapStockSerialDescribe = Schema.SObjectType.SVMXC__Product_Serial__c.fields.getMap();
                    list<String> lstStockSerialFld = new list<String>();
                    if(mapStockSerialDescribe.size() > 0)
                        lstStockSerialFld = utils.SVMX_getFieldList(mapStockSerialDescribe,true);
                    if(lstStockSerialFld.size() > 0)
                        strStockSerialfld = utils.SVMX_getFieldNamesFromList(lstStockSerialFld);
                    system.debug('strStockSerialfld'+strStockSerialfld);
                    set<String> setPSID = new set<String>();
                    setPSID = mapProductStock.keyset();
                    setPSID.remove(null);
                    if(strStockSerialfld != null && strStockSerialfld.length() > 0)
                    {
                        queryFields = strStockSerialfld.split(',');
                            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Serial__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                            }
                        String Query = 'Select '+strStockSerialfld+ ' From SVMXC__Product_Serial__c where SVMXC__Product_Stock__c IN : setPSID order by '+ strOrderByField +' '+strOrder +' NULLS '+strNull;//+' Limit '+intLimit;
                        system.debug('strQuery'+query);
                        lstStockSerial = Database.query(query);
                    }   
                    COMM_PerformanceUtils.stop('004:p: INITIALSYNCorBATCHCALL _ QueryingProdSerial');
                }
                system.debug('lstStockSerial'+lstStockSerial.size()+lstStockSerial);
                if(lstStockSerial.size() > 0)
                {
                    //COMM_PerformanceUtils.start('004:q: INITIALSYNCorBATCHCALL _ LoopStockSerial');
                    
                    for(SVMXC__Product_Serial__c PS : lstStockSerial)
                    {
                        if(PS.SVMXC__Product__c != null)
                        {
                            if(mapProductIdListSerialNo.containskey(PS.SVMXC__Product__c))
                                mapProductIdListSerialNo.get(PS.SVMXC__Product__c).add(PS.Name);
                            else
                            {
                                mapProductIdListSerialNo.put(PS.SVMXC__Product__c,new list<String>());
                                mapProductIdListSerialNo.get(PS.SVMXC__Product__c).add(PS.Name);
                            }
                        }     
                    }
                    //COMM_PerformanceUtils.stop('004:q: INITIALSYNCorBATCHCALL _ LoopStockSerial');
                }
                system.debug('mapProductIdListSerialNo'+mapProductIdListSerialNo.size()+mapProductIdListSerialNo);
            }    
            if(lstOrderLines.size() > 0)
            {
                //COMM_PerformanceUtils.start('004:r: INITIALSYNCorBATCHCALL _ LoopLstOrderLines');
                
                for(SVMXC__RMA_Shipment_Line__c line : lstOrderLines)
                {
                    if(mapOrderLines.containskey(line.id))
                    {
                        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
                        orderLine.orderLineRecord = mapOrderLines.get(line.id);
                        /*if(orderLine.orderLineRecord.SVMXC__Product__c != null)
                        {
                            String strProductId = String.valueof(orderLine.orderLineRecord.SVMXC__Product__c).substring(0,15);
                            system.debug('entered..'+strProductId);
                            if(mapProIdStockable.containskey(strProductId))
                                orderLine.isProductStockable = mapProIdStockable.get(strProductId); 
                            if(mapProIdSerializable.containskey(strProductId))  
                                orderLine.isEnableSerializedTracking = mapProIdSerializable.get(strProductId);
                        }*/
                        if(strProcessType.toUpperCase() == 'PROCESSRECEIPT')
                        {
                            if(orderLine.orderLineRecord.SVMXC__Serial_Number_List__c != null)
                            {
                                String strSN = orderLine.orderLineRecord.SVMXC__Serial_Number_List__c;
                                list<String> lstSerialNos = new list<String>(); 
                                if(strSN != null && strSN.length() > 0)
                                    lstSerialNos = strSN.split(';');
                                if(lstSerialNos.size() > 0)
                                {
                                    list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> lstserialNo = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                                    
                                    //COMM_PerformanceUtils.start('004:r:1: INITIALSYNCorBATCHCALL _ LoopLstOrderLines _ LoopLstSerialNos');
                                    
                                    for(Integer i=0;i<lstSerialNos.size();i++)
                                    {
                                        SVMXC.INTF_WebServicesDef.APL_SerialCollection serialNo = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
                                        serialNo.serialNumber = lstSerialNos[i];
                                        serialNo.isExpected = true;
                                        //serialNo.isReceived = true;
                                        lstserialNo.add(serialNo);
                                    }
                                    
                                    //COMM_PerformanceUtils.stop('004:r:1: INITIALSYNCorBATCHCALL _ LoopLstOrderLines _ LoopLstSerialNos');
                                    
                                    orderLine.serialNumbers = lstserialNo;  
                                }
                            }
                                
                        }
                        else if(strProcessType.toUpperCase() == 'PICKNMOVE')
                        {
                            system.debug('Entered'+orderLine.orderLineRecord.SVMXC__Product__c);
                            list<String> lstSerialNumber = new list<String>();
                            set<String> setSerialNumber = new set<String>();
                            if(mapProductIdListSerialNo.containskey(orderLine.orderLineRecord.SVMXC__Product__c))
                            {
                                
                                lstSerialNumber = mapProductIdListSerialNo.get(orderLine.orderLineRecord.SVMXC__Product__c);
                                setSerialNumber.addall(mapProductIdListSerialNo.get(orderLine.orderLineRecord.SVMXC__Product__c));
                                system.debug('lstSerialNumber'+lstSerialNumber.size()+lstSerialNumber);
                            }
                            if(orderLine.orderLineRecord.SVMXC__Serial_Number_List__c != null)
                            {   
                                String strSN = mapOrderLines.get(line.id).SVMXC__Serial_Number_List__c;
                                list<String> lstSerialNos = new list<String>(); 
                                if(strSN != null && strSN.length() > 0)
                                    lstSerialNos = strSN.split(';');
                                if(lstSerialNos.size() > 0)
                                {
                                    list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> lstserialNo = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                                    
                                    //COMM_PerformanceUtils.start('004:r:1: INITIALSYNCorBATCHCALL _ LoopLstOrderLines _ LoopLstSerialNos');
                                    
                                    for(Integer i=0;i<lstSerialNos.size();i++)
                                    {
                                        if(setSerialNumber.contains(lstSerialNos[i]))
                                        {
                                            SVMXC.INTF_WebServicesDef.APL_SerialCollection serialNo = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
                                            serialNo.serialNumber = lstSerialNos[i];
                                            serialNo.isExpected = true;
                                            //serialNo.isPicked = true;
                                            lstserialNo.add(serialNo);
                                        }
                                        else
                                        {
                                            response.success = false;
                                            response.message = 'Expected serial numbers are not available in product stock.';
                                            //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
                                            return response;
                                        }    
                                    }
                                    //COMM_PerformanceUtils.stop('004:r:1: INITIALSYNCorBATCHCALL _ LoopLstOrderLines _ LoopLstSerialNos');
                                    
                                    orderLine.serialNumbers = lstserialNo;  
                                }
                            }
                            else
                            {
                                if(lstSerialNumber.size() > 0)
                                {
                                    list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> lstserialNo = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                                    
                                    //COMM_PerformanceUtils.start('004:r:1: INITIALSYNCorBATCHCALL _ LoopLstOrderLines _ LoopLstSerialNos');
                                    
                                    for(Integer i = 0;i<lstSerialNumber.size();i++)
                                    {
                                        SVMXC.INTF_WebServicesDef.APL_SerialCollection serialNo = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
                                        serialNo.serialNumber = lstSerialNumber[i];
                                        lstserialNo.add(serialNo);
                                    }
                                    
                                    //COMM_PerformanceUtils.stop('004:r:1: INITIALSYNCorBATCHCALL _ LoopLstOrderLines _ LoopLstSerialNos');
                                    orderLine.serialNumbers = lstserialNo;  
                                }
                            }
                        }
                        else if(strProcessType.toUpperCase() == 'DELIVERYONRECEIPT')
                        {   
                            String strSN = mapOrderLines.get(line.id).SVMXC__Serial_Number_List__c;
                            list<String> lstSerialNos = new list<String>(); 
                            if(strSN != null && strSN.length() > 0)
                                lstSerialNos = strSN.split(';');
                            if(lstSerialNos.size() > 0)
                            {
                                list<SVMXC.INTF_WebServicesDef.APL_SerialCollection> lstserialNo = new list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>();
                                
                                //COMM_PerformanceUtils.start('004:r:1: INITIALSYNCorBATCHCALL _ LoopLstOrderLines _ LoopLstSerialNos');
                                
                                for(Integer i=0;i<lstSerialNos.size();i++)
                                {
                                    SVMXC.INTF_WebServicesDef.APL_SerialCollection serialNo = new SVMXC.INTF_WebServicesDef.APL_SerialCollection();
                                    serialNo.serialNumber = lstSerialNos[i];
                                    lstserialNo.add(serialNo);
                                }                               
                                //COMM_PerformanceUtils.stop('004:r:1: INITIALSYNCorBATCHCALL _ LoopLstOrderLines _ LoopLstSerialNos');
                                
                                orderLine.serialNumbers = lstserialNo;  
                            }
                        } 
                        lstOrderLine.add(orderLine);
                    }   
                }  
                //COMM_PerformanceUtils.stop('004:r: INITIALSYNCorBATCHCALL _ LoopLstOrderLines');    
            }
            aplOrder.orderLines = lstOrderLine;
        
        }
        
        //COMM_PerformanceUtils.stop('004: INITIALSYNCorBATCHCALL');
        
        response.valueMap = lstSVMXMapForResponse;
        response.success = true;
        response.eventType = strEventType;
        response.aplOrder = aplOrder;
        system.debug('response'+response);
        
        //COMM_PerformanceUtils.start('005: Attachment');
        if(isDebugMode)
        {
            strLog += '\n \n'+'METHOD_EXIT: getAPLOrder1';
            system.debug('Log:'+strLog);
            String strName = 'Log For '+Userinfo.getUserName()+date.Today();
            
            //COMM_PerformanceUtils.start('005:a: Attachment _ QueringAttachment');
            
            queryFields = new List<String> {'SystemModstamp', 'ParentId', 'OwnerId', 'Name', 'LastModifiedDate', 'LastModifiedById', 'IsPrivate', 'IsDeleted', 'Id', 'Description', 'CreatedDate', 'CreatedById', 'ContentType', 'BodyLength', 'Body' };
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Attachment', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            list<Attachment> lstAttchment = [Select SystemModstamp, ParentId, OwnerId, Name, LastModifiedDate, LastModifiedById, IsPrivate, IsDeleted, Id, Description, CreatedDate, CreatedById, ContentType, BodyLength, Body From Attachment where ParentId =: strRecordId and Name =: strName]; //SDL-SVMX-READ-FLS-ENFORCED
            
            //COMM_PerformanceUtils.stop('005:a: Attachment _ QueringAttachment');
            
            if(lstAttchment.size() > 0)
            {
                String str = lstAttchment[0].body.tostring();
                str += '\n \n'+ strLog;
                lstAttchment[0].body = Blob.valueof(str); 
                
                //COMM_PerformanceUtils.start('005:b: Attachment _ UpdatingAttachment');              
                
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstAttchment[0], COMM_SecurityUtils.Access.Updateable ) ) {
                    update lstAttchment[0];
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }                
                
                //COMM_PerformanceUtils.stop('005:b: Attachment _ UpdatingAttachment');       
            }
            else
            {
                system.debug('Entered..');
                Attachment attachment = new Attachment();
                attachment.ParentId = strRecordId;
                attachment.Name = strName;
                attachment.Body = Blob.valueof(strLog);
                attachment.ContentType = 'text/plain';
                system.debug('Entered..'+attachment);
                
                //COMM_PerformanceUtils.start('005:c: Attachment _ InsertingAttachment');
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( attachment, COMM_SecurityUtils.Access.Createable ) ) {
                    insert attachment; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
                
                //COMM_PerformanceUtils.stop('005:c: Attachment _ InsertingAttachment');
            }
        }    
        //COMM_PerformanceUtils.stop('005: Attachment');
        //perfUtil.end(strRecordId, 'GET of: '+strProcessId);
        return response;
    }
   
    public String MakeColumn(list<SVMXC__ServiceMax_Config_Data__c> lstConfigData,String processType)
    {
        Integer i = 0;
        system.debug('lstConfigData'+lstConfigData.size()+lstConfigData);
        system.debug('processType'+processType);
        set<String> addedColumnFields = new set<String>();
        map<String,String> mapAPINameLableProduct = new map<String,String>();
        map<String,String> mapAPINameLablePOLine = new map<String,String>();
        map<String, Schema.SObjectField> mapProductField = Schema.SObjectType.Product2.fields.getMap();
        map<String, Schema.SObjectField> mapOrderLineField = Schema.SObjectType.SVMXC__RMA_Shipment_Line__c.fields.getMap();
        
        if(mapProductField.size() > 0)
        {
            for(String str:mapProductField.keyset())
            {
                mapAPINameLableProduct.put(mapProductField.get(str).getDescribe().getName(),mapProductField.get(str).getDescribe().getLabel());
            }
        }
        if(mapOrderLineField.size() > 0)
        {
            for(String str : mapOrderLineField.keyset())
            {
                Schema.DescribeFieldResult F = mapOrderLineField.get(str).getDescribe();
                mapAPINameLablePOLine.put(F.getName(),F.getLabel());
            }
        }
        String columnInfo = '';
        columnInfo += '({Id:{name:"Id", label:"' +system.label.APL003_TAG008+ '", displayable: false, type: \'text\'},';
        if(processType.toUpperCase() != 'FULFILLMENTPROCESS')
        columnInfo += 'Name:{name:"Name", label: "' +system.label.APL003_TAG008+ '", displayable: true, type: \'text\'},';
        columnInfo += 'SVMXC__Product__rProductCode:{name:"SVMXC__Product__r.ProductCode", label:"'+system.label.APL003_TAG040+'", displayable: true},';
        columnInfo += 'SVMXC__Product__rName:{name:"SVMXC__Product__r.Name", label:"'+system.label.APL003_TAG009+'", displayable: true},';
        if(lstConfigData.size() > 0)
        {
            //
            i = 1;
            for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
            {
                if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE' && mapAPINameLableProduct.containskey(config.SVMXC__Field_Name__c))
                {
                    columnInfo += config.SVMXC__Configuration_Type__c+i+':{name:"SVMXC__Product__r.'+config.SVMXC__Field_Name__c+'", label:"'+mapAPINameLableProduct.get(config.SVMXC__Field_Name__c)+'", displayable: true},';
                    i++;
                }   
            }
        }
        columnInfo += 'SVMXC__Product__c:{name:"SVMXC__Product__c", label:"", displayable: false, reference: "SVMXC__Product__r", referencefields: {name:{name:"Name", label:"", displayable: true},productcode:{name:"ProductCode", label:"", displayable: true}';
        //for reference fields
        if(lstConfigData.size() > 0)
        {
            i = 1;
            for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
            {
                if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE' && mapAPINameLableProduct.containskey(config.SVMXC__Field_Name__c))
                {
                    columnInfo += ',SVMXC__Product__r'+config.SVMXC__Configuration_Type__c+i+':{name:"'+config.SVMXC__Field_Name__c+'", label:"'+mapAPINameLableProduct.get(config.SVMXC__Field_Name__c)+'", displayable: true}';
                    i++;
                }   
            }
        }
        columnInfo += '}}';
        if(processType.toUpperCase() == 'FULFILLMENTPROCESS')
        {
            columnInfo += ',SVMXC__Expected_Quantity2__c:{name:"SVMXC__Expected_Quantity2__c", label:"'+system.label.APL005_TAG009+'", displayable: true, defaultvalue:0, type: \'number\'}';
            columnInfo += ',SVMXC__Actual_Quantity2__c:{name:"SVMXC__Actual_Quantity2__c", label:"'+system.label.APL005_TAG010+'", displayable: true, defaultvalue:0, type: \'text\'}';
            columnInfo += ',SVMXC__Fulfillment_Qty__c:{name:"SVMXC__Fulfillment_Qty__c", label:"'+system.label.APL005_TAG011+'", displayable: true, defaultvalue:0, type: \'number\'}';
            addedColumnFields.add('SVMXC__Expected_Quantity2__c');
            addedColumnFields.add('SVMXC__Fulfillment_Qty__c');
            addedColumnFields.add('SVMXC__Actual_Quantity2__c');
        }  
        if(processType.toUpperCase() == 'PICKNMOVE' || processType.toUpperCase() == 'SHIPCONFIRM')
        {
            columnInfo += ',SVMXC__Expected_Quantity2__c:{name:"SVMXC__Expected_Quantity2__c", label:"'+system.label.APL003_TAG010+'", displayable: true, type: \'number\'}';
            columnInfo += ',SVMXC__Picked_Qty__c:{name:"SVMXC__Picked_Qty__c", label:"'+system.label.APL002_TAG021+'", displayable: true, defaultvalue:0, type: \'number\'}';
            addedColumnFields.add('SVMXC__Expected_Quantity2__c');
            addedColumnFields.add('SVMXC__Picked_Qty__c');
        }
        if(processType.toUpperCase() == 'PROCESSRECEIPT')
        {
            columnInfo += ',SVMXC__Expected_Quantity2__c:{name:"SVMXC__Expected_Quantity2__c", label:"'+system.label.APL003_TAG010+'", displayable: true, type: \'number\'}';
            columnInfo += ',SVMXC__Actual_Quantity2__c:{name:"SVMXC__Actual_Quantity2__c", label:"'+system.label.APL003_TAG042+'", displayable: true, defaultvalue:0, type: \'number\'}';
            //columnInfo += ',SVMXC__Reconciliation_Action__c:{name:"SVMXC__Reconciliation_Action__c", label:"Reconciliation Action", displayable: true, defaultvalue:{none:{key: \'None\', value: \'None\'}}, type: \'picklist\'}';
            addedColumnFields.add('SVMXC__Expected_Quantity2__c');
            addedColumnFields.add('SVMXC__Actual_Quantity2__c');
            //addedColumnFields.add('SVMXC__Reconciliation_Action__c');  
        }
        if(processType.toUpperCase() == 'SHIPCONFIRM')
        {
            //Amar : We are no longer showing Shipped Quantity
            //columnInfo += ',SVMXC__Actual_Quantity2__c:{name:"SVMXC__Actual_Quantity2__c", label:"'+system.label.APL002_TAG024+'", displayable: true, type: \'number\'}';
            //addedColumnFields.add('SVMXC__Actual_Quantity2__c');
        }
        if(processType.toUpperCase() == 'DELIVERYONRECEIPT')
        {
            columnInfo+= ',SVMXC__Delivery_Location__c:{name:"SVMXC__Delivery_Location__c", label:"'+system.label.APL003_TAG012+'", displayable: true, defaultvalue:{none:{key: \'None\', value: \'None\'}}, type: \'picklist\', onchange : \'onchangeDeliveryLocation(this)\'}';
            columnInfo += ',SVMXC__Actual_Quantity2__c:{name:"SVMXC__Actual_Quantity2__c", label:"'+system.label.APL003_TAG063+'", displayable: true, defaultvalue:0, type: \'number\'}';
            addedColumnFields.add('SVMXC__Delivery_Location__c');
            addedColumnFields.add('SVMXC__Actual_Quantity2__c');
        }   
        addedColumnFields.add('Id');
        addedColumnFields.add('Name');
        addedColumnFields.add('SVMXC__Product__c');
        //
        if(lstConfigData.size() > 0)
        {
            i = 1;
            for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
            {
                if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && mapAPINameLablePOLine.containskey(config.SVMXC__Field_Name__c))
                {
                    if(config.SVMXC__Display_Type__c != 'REFERENCE')
                    {
                        addedColumnFields.add(config.SVMXC__Field_Name__c);
                        columnInfo += ','+config.SVMXC__Configuration_Type__c+i+':{name:"'+config.SVMXC__Field_Name__c+'", label:"'+mapAPINameLablePOLine.get(config.SVMXC__Field_Name__c)+'", displayable: true}';
                    }
                    i++;
                }
            }
        }
        if(lstConfigData.size() > 0)
        {
            i = 1;
            for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
            {
                if(config.SVMXC__Display_Type__c == 'REFERENCE')
                {
                    if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && mapAPINameLablePOLine.containskey(config.SVMXC__Field_Name__c))
                    {
                        addedColumnFields.add(config.SVMXC__Field_Name__c);
                        columnInfo += ','+config.SVMXC__Field_Relationship_Name__c+config.SVMXC__FKey_Name_Field__c+':{name:"'+config.SVMXC__Field_Relationship_Name__c+'.'+config.SVMXC__FKey_Name_Field__c+'", label:"'+mapAPINameLablePOLine.get(config.SVMXC__Field_Name__c)+'", displayable: true}';
                    }
                }    
            }
        }
        if(lstConfigData.size() > 0)
        {
            i = 1;
            for(SVMXC__ServiceMax_Config_Data__c config : lstConfigData)
            {
                if(config.SVMXC__Display_Type__c == 'REFERENCE')
                {
                    if(config.SVMXC__Field_Name__c != null && config.SVMXC__Configuration_Type__c == 'DOCUMENT_LINE_ATTRIBUTE' && mapAPINameLablePOLine.containskey(config.SVMXC__Field_Name__c) && config.SVMXC__Object_Name__c != null && config.SVMXC__Field_Relationship_Name__c != null && config.SVMXC__FKey_Name_Field__c != null)
                    {
                        columnInfo += ','+config.SVMXC__Field_Name__c+':{name:"'+config.SVMXC__Field_Name__c+'", label:"", displayable: false, reference: "'+config.SVMXC__Field_Relationship_Name__c+'", referencefields: {name:{name:"'+config.SVMXC__FKey_Name_Field__c+'", label:"'+mapAPINameLablePOLine.get(config.SVMXC__Field_Name__c)+'", displayable: true}}}';
                    }
                }    
            }
        }
                
        if(mapOrderLineField.size() > 0)
        {
            for(String str:mapOrderLineField.keyset())
            {
                String fieldName = mapOrderLineField.get(str).getDescribe().getName();
                if(!addedColumnFields.contains(fieldName))
                {
                    columnInfo += ',' + fieldName + ':{name:"' + fieldName + '", displayable: false, type: \'text\'}';
                    addedColumnFields.add(fieldName);
                }
            }
        }
        columnInfo += '})';
        system.debug('columnInfo'+columnInfo);
        mapAPINameLableProduct.clear();
        mapProductField.clear();
        mapOrderLineField.clear();
        mapAPINameLableProduct = null;
        mapProductField = null;
        mapOrderLineField = null;
        return columnInfo;
        
    }
    public String getSortingColumns(list<SVMXC__ServiceMax_Config_Data__c> lstConfigData,String processType)
    {
        String sortColumn = '[{ "bSortable": true },{ "bSortable": true },{ "bSortable": true },';
        if(processType.toUpperCase() == 'PICKNMOVE')
        {
            sortColumn += '{ "bSortable": true },{ "bSortable": true },';
        }
        else if(processType.toUpperCase() == 'SHIPCONFIRM')
        {
            sortColumn += '{ "bSortable": true },{ "bSortable": true },{ "bSortable": true },';
        }
        else if(processType.toUpperCase() == 'PROCESSRECEIPT')
        {
            sortColumn += '{ "bSortable": true },{ "bSortable": true },{ "bSortable": true },{ "bSortable": false },';
        }
        else if(processType.toUpperCase() == 'DELIVERYONRECEIPT')
        {
            sortColumn += '{ "bSortable": true },{ "bSortable": true },{ "bSortable": false },';
        }
        if(lstConfigData.size() > 0)
        {
            for(Integer i = 0;i<lstConfigData.size();i++)
            {
                if(lstConfigData[i].SVMXC__Configuration_Type__c == 'PRODUCT_ATTRIBUTE')
                    sortColumn += ',{ "bSortable": true }';
            }
        }
        return sortColumn;
    }
    public SVMXC.INTF_WebServicesDef.INTF_SFMResponse SaveAPLOrder(SVMXC.INTF_WebServicesDef.INTF_SFMRequest request)
    {
        //Added by Naveen V on 08-March-2012 For Performance
        //COMM_PerformanceUtils //perfUtil = new //COMM_PerformanceUtils();
        //perfUtil.begin();
        //COMM_PerformanceUtils.start('1.VARIABLE-DECLARATION');
        
        //COMM_PerformanceUtils.start('1.a.VARIABLE-DECLARATION - SimpleVariables');
        //Variable Declaration...
        system.debug('Save Order Start Time: '+system.now());
        system.debug('request'+request);
        SVMXC.INTF_WebServicesDef.INTF_SFMResponse response = new SVMXC.INTF_WebServicesDef.INTF_SFMResponse();
        response.success = true;
        response.message = '';
        SVMXC.INTF_WebServicesDef.APL_Order newAPLOrder = new SVMXC.INTF_WebServicesDef.APL_Order();
        SVMXC.APL_Utils sourceUpdateUtil = new SVMXC.APL_Utils();
        list<SVMXC.INTF_WebServicesDef.SVMXMap> lstSVMXMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        list<SVMXC__RMA_Shipment_Line__c> lstupdatedLines = new list<SVMXC__RMA_Shipment_Line__c>();
        list<SVMXC__RMA_Shipment_Line__c> lstPOLines = new list<SVMXC__RMA_Shipment_Line__c>();
        list<SVMXC__ServiceMax_Config_Data__c> lstConfigDataForSourceUpdateDetail = new list<SVMXC__ServiceMax_Config_Data__c>();
        list<RecordType> RecordTypes = new list<RecordType>();
        map<String,Schema.SObjectField> mapPOLinesFldDesc = new  map<String,Schema.SObjectField>();
        map<String,list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>> mapLineIDSerialNos = new map<String,list<SVMXC.INTF_WebServicesDef.APL_SerialCollection>>();
        SVMXC__ServiceMax_Processes__c objSVMXProcess = new SVMXC__ServiceMax_Processes__c();
        SVMXC__RMA_Shipment_Order__c objPartsOrder = new SVMXC__RMA_Shipment_Order__c();
        map<String,String> mapLineIdClonedFromId = new map<String,String>();
        list<String> setClonedFromId = new list<String>();
        list<String> lstUnexpectedSN = new list<String>();
        String strProcessId = '';
        String strRecordId;
        String strProcessType = '';
        String fldMapRecTypeId = '';
        String strEventName = '';
        //COMM_PerformanceUtils.stop('1.a.VARIABLE-DECLARATION - SimpleVariables');
        //COMM_PerformanceUtils.start('1.b.VARIABLE-DECLARATION - ExtractingRequest');
        if(request.eventName != null && request.eventName.length() > 0)
            strEventName = request.eventName;
        lstSVMXMap = request.valueMap;
        if(lstSVMXMap.size() > 0)
        {
            for(Integer i = 0;i<lstSVMXMap.size();i++)
            {
                if(lstSVMXMap[i].key.touppercase() == 'SVMX_RECORDID')
                    strRecordId = lstSVMXMap[i].value;
                else if(lstSVMXMap[i].key.toUppercase() == 'SVMX_PROCESSTYPE')
                    strProcessType = lstSVMXMap[i].value;
                else if(lstSVMXMap[i].key.toUppercase() == 'SVMX_PROCESSID')
                    strProcessId = lstSVMXMap[i].value;
                else if(lstSVMXMap[i].key.toUppercase() == 'UNEXPECTEDSERIALNUMBERS')
                    lstUnexpectedSN = lstSVMXMap[i].values; 
            }
        }
        
        /*
        List<SVMXC.INTF_WebServicesDef.INTF_SFMRequest> lstReq = new List<SVMXC.INTF_WebServicesDef.INTF_SFMRequest>(); 
        SVMXC.INTF_WebServicesDef.INTF_SFMRequest requ = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
        requ.valueMap = lstSVMXMap;
        lstReq.add(requ);
        lstReq.add(requ);
            // 18/April/2012 :- Added by Vasu for POC purpose.
            String jsonString = JSON.serialize(lstReq);
            
            List<Attachment> lstAttachTodelete = new List<Attachment>();
            lstAttachTodelete = [select id from Attachment where ParentId =: strRecordId AND Name = 'JSON String'];
            if(lstAttachTodelete != null && lstAttachTodelete.size() > 0)
                delete lstAttachTodelete;
            
            Attachment attach = new Attachment();
            attach.ParentId = strRecordId;
            attach.Name = 'JSON String';
            attach.ContentType = 'text/plain';
            attach.Body = Blob.valueof(jsonString);
            insert attach;
            system.debug('JSON String Created from the request: ' + request);
            
            SaveAPLOrderFuture(strRecordId);*/
            
            
        //COMM_PerformanceUtils.stop('1.b.VARIABLE-DECLARATION - ExtractingRequest');
        //COMM_PerformanceUtils.start('1.c.VARIABLE-DECLARATION - ExtractingSettings');
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
        
        //COMM_PerformanceUtils.stop('1.c.VARIABLE-DECLARATION - ExtractingSettings');
        //Added by Naveen V on 08-March-2012 For Performance
        //COMM_PerformanceUtils.stop('1.VARIABLE-DECLARATION');
        
        // If process type is FULFILLMENTPROCESS call fullfillment save and just skip
        if(strProcessType == 'FULFILLMENTPROCESS')
        {
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('2.SAVE-FULFILLMENT');
            
            APL_FulfillmentConsole clsAPLFulfillmentEngine = new APL_FulfillmentConsole();
            SVMXC.INTF_WebServicesDef.INTF_SFMResponse res = clsAPLFulfillmentEngine.saveFulfillmentOrder(strRecordId, request);
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('2.SAVE-FULFILLMENT');
            //perfUtil.end(strRecordId, strProcessType);
            return res;
            //return clsAPLFulfillmentEngine.saveFulfillmentOrder(strRecordId, request);
        }
        newAPLOrder = request.aplOrder;
        objPartsOrder = newAPLOrder.orderHdrRecord;
        
        //Added by Naveen V on 08-March-2012 For Performance
        //COMM_PerformanceUtils.start('2.QUERY-PROCESS');
        
        if(strProcessId != null && strProcessId.length() > 0)
        {

            List<String> queryFields = new List<String> {'SVMXC__Target_Record_Type__c','SVMXC__Target_Object_Name__c','SVMXC__Submodule__c','SVMXC__SubmoduleID__c','SVMXC__Source_Object_Name__c','SVMXC__SettingID__c','SVMXC__Sequence__c','SVMXC__Resolve_Unexpected_SN_To_IB__c','SVMXC__Record_Type_Name__c','SVMXC__Purpose__c','SVMXC__Process__c','SVMXC__ProcessID__c','SVMXC__Process2__c','SVMXC__Process1__c','SVMXC__Parent_Object__c','SVMXC__Parent_Object_Criteria__c','SVMXC__Parent_Error_Msg__c','SVMXC__Parent_Error_Msg2__c','SVMXC__Parent_Column_Name__c','SVMXC__Node_Parent__c','SVMXC__Node_Parent_API__c','SVMXC__Name__c','SVMXC__Module__c','SVMXC__ModuleID__c','SVMXC__MapID__c','SVMXC__Final_Exception_Process__c','SVMXC__Entitlement_Scope__c','SVMXC__Entitlement_By__c','SVMXC__Description__c','SVMXC__Default_Location__c','SVMXC__Data_Type__c','SVMXC__Counter_Vs_Dates_Rule__c','SVMXC__Consider_Location_From__c','SVMXC__Consider_Location_From_Object__c','SVMXC__Child_Object_Criteria__c','SVMXC__Child_Error_Msg__c','SVMXC__Child_Error_Msg2__c','SVMXC__Advance_Expression__c','SVMXC__Active__c','SVMXC__APL_Split_Lines__c','SVMXC__APL_Shipment_Note_Template__c','SVMXC__APL_Serial_Number_Source__c','SVMXC__APL_Scan_First__c','SVMXC__APL_Route_Rule_Type__c','SVMXC__APL_Print_RMA_Template__c','SVMXC__APL_Print_Label_Template__c','SVMXC__APL_Perform_Route_Calculations__c','SVMXC__APL_Perform_Entitlement__c','SVMXC__APL_Group_Work_Order_By__c','SVMXC__APL_Field_Name__c','SVMXC__APL_Create_Work_Order_On__c','SVMXC__APL_Create_WO_Preference__c','SVMXC__APL_Create_Supplier_RMA__c','SVMXC__APL_Create_Internal_RMA__c','SVMXC__APL_Allow_Partial_Shipment__c','SVMXC__APL_Allow_Partial_Delivery__c','SVMXC__APL_Action_On_Unexpected_SN__c','SVMXC__APL_Action_On_Unexpected_Product__c','SVMXC__APL_Action_On_Less_Qty__c','SVMXC__APL_Action_On_Excess_Qty__c','RecordTypeId','OwnerId','Name','Id'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            objSVMXProcess = [Select SVMXC__Target_Record_Type__c, SVMXC__Target_Object_Name__c, SVMXC__Submodule__c, SVMXC__SubmoduleID__c, SVMXC__Source_Object_Name__c, SVMXC__SettingID__c, SVMXC__Sequence__c, SVMXC__Resolve_Unexpected_SN_To_IB__c, SVMXC__Record_Type_Name__c, SVMXC__Purpose__c,  SVMXC__Process__c, SVMXC__ProcessID__c, SVMXC__Process2__c, SVMXC__Process1__c, SVMXC__Parent_Object__c, SVMXC__Parent_Object_Criteria__c, SVMXC__Parent_Error_Msg__c, SVMXC__Parent_Error_Msg2__c, SVMXC__Parent_Column_Name__c, SVMXC__Node_Parent__c, SVMXC__Node_Parent_API__c, SVMXC__Name__c, SVMXC__Module__c, SVMXC__ModuleID__c, SVMXC__MapID__c, SVMXC__Final_Exception_Process__c,  SVMXC__Entitlement_Scope__c, SVMXC__Entitlement_By__c,SVMXC__Description__c,  SVMXC__Default_Location__c, SVMXC__Data_Type__c, SVMXC__Counter_Vs_Dates_Rule__c, SVMXC__Consider_Location_From__c, SVMXC__Consider_Location_From_Object__c, SVMXC__Child_Object_Criteria__c, SVMXC__Child_Error_Msg__c, SVMXC__Child_Error_Msg2__c,SVMXC__Advance_Expression__c, SVMXC__Active__c, SVMXC__APL_Split_Lines__c, SVMXC__APL_Shipment_Note_Template__c, SVMXC__APL_Serial_Number_Source__c, SVMXC__APL_Scan_First__c, SVMXC__APL_Route_Rule_Type__c, SVMXC__APL_Print_RMA_Template__c, SVMXC__APL_Print_Label_Template__c, SVMXC__APL_Perform_Route_Calculations__c, SVMXC__APL_Perform_Entitlement__c, SVMXC__APL_Group_Work_Order_By__c, SVMXC__APL_Field_Name__c, SVMXC__APL_Create_Work_Order_On__c, SVMXC__APL_Create_WO_Preference__c, SVMXC__APL_Create_Supplier_RMA__c, SVMXC__APL_Create_Internal_RMA__c, SVMXC__APL_Allow_Partial_Shipment__c, SVMXC__APL_Allow_Partial_Delivery__c, SVMXC__APL_Action_On_Unexpected_SN__c, SVMXC__APL_Action_On_Unexpected_Product__c, SVMXC__APL_Action_On_Less_Qty__c, SVMXC__APL_Action_On_Excess_Qty__c, RecordTypeId, OwnerId, Name, Id From SVMXC__ServiceMax_Processes__c where SVMXC__ProcessID__c =: strProcessId or id =: strProcessId]; //SDL-SVMX-READ-FLS-ENFORCED
        }   
        
        //Added by Naveen V on 08-March-2012 For Performance
        //COMM_PerformanceUtils.stop('2.QUERY-PROCESS');
        //COMM_PerformanceUtils.start('3.APL-LIST_MAP_CREATION');
            
        newAPLOrder.svmxProcess = objSVMXProcess;
        system.debug('newAPLOrder'+newAPLOrder);
        list<String> lstUniqueIdForClient = new list<String>();
        if(newAPLOrder.orderLines.size() > 0)
        {
            for(Integer i = 0;i<newAPLOrder.orderLines.size();i++)
            {
               lstUniqueIdForClient.add(newAPLOrder.orderLines[i].uniqueIdForClient);
               lstPOLines.add(newAPLOrder.orderLines[i].orderLineRecord);
               //Create a map of LineID and ClonedFromID so it can be used for Route Card Update
               setClonedFromId.add(newAPLOrder.orderLines[i].clonedFromId);
                if(newAPLOrder.orderLines[i].clonedFromId != null) 
                    mapLineIdClonedFromId.put(newAPLOrder.orderLines[i].orderLineRecord.Name,newAPLOrder.orderLines[i].clonedFromId);
            }
        }
        
        //Added by Naveen V on 08-March-2012 For Performance
        //COMM_PerformanceUtils.stop('3.APL-LIST_MAP_CREATION');
        
        system.debug('lstUniqueIdForClient: '+lstUniqueIdForClient.size()+lstUniqueIdForClient);
        system.debug('lstPOLines: '+lstPOLines.size()+lstPOLines);
        system.debug('setClonedFromId: '+setClonedFromId.size()+setClonedFromId);
        system.debug('mapLineIdClonedFromId: '+mapLineIdClonedFromId.size()+mapLineIdClonedFromId);
        system.debug('strProcessType :'+strProcessType);
        if(lstPOLines.size() > 0)
        {
            if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstPOLines, COMM_SecurityUtils.Access.Upsertable ) ) {
                upsert lstPOLines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
            } else {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
        }
        //For all 4 Process Types  Do the Detail Source Updates.. 
        if(strProcessType == 'PROCESSRECEIPT')
        {
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('4.PROCESS-RECEIPT-SOURCE-UPDATE');
            //COMM_PerformanceUtils.start('4.a.PROCESS-RECEIPT-SOURCE-UPDATE - QueryRTDescribeRMALineFields');
            List<String> queryFields = new List<String> {'SystemModstamp', 'SobjectType', 'NamespacePrefix', 'Name', 'LastModifiedDate', 'LastModifiedById', 'IsActive', 'Id', 'DeveloperName', 'Description', 'CreatedDate', 'CreatedById', 'BusinessProcessId'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'RecordType', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c']; //SDL-SVMX-READ-FLS-ENFORCED
            if(RecordTypes.size() > 0 )
            {
                for(RecordType r : RecordTypes)
                {
                    if(r.Name == 'Field Mapping')
                        fldMapRecTypeId = r.id;
                }
            }
            map<String,Schema.SObjectField> mapTempL = Schema.SObjectType.SVMXC__RMA_Shipment_Line__c.fields.getMap(); 
            if(mapTempL.size() > 0)
            {
                for(String s : mapTempL.keyset())
                {
                    mapPOLinesFldDesc.put(mapTempL.get(s).getDescribe().getName(),mapTempL.get(s));
                }
            }
            //COMM_PerformanceUtils.stop('4.a.PROCESS-RECEIPT-SOURCE-UPDATE - QueryRTDescribeRMALineFields');
            //COMM_PerformanceUtils.start('4.b.PROCESS-RECEIPT-SOURCE-UPDATE - QueryConfData');
            queryFields = new List<String> {'id', 'RecordTypeId', 'SVMXC__Dispatch_Process__c', 'SVMXC__Target_Field_Name__c', 'SVMXC__Action__c', 'SVMXC__Display_Value__c', 'SVMXC__Configuration_Type__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            lstConfigDataForSourceUpdateDetail = [select id, RecordTypeId, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: fldMapRecTypeId and SVMXC__Configuration_Type__c = 'LINE_UPD_ON_RECEIPT' and SVMXC__Dispatch_Process__c =: objSVMXProcess.id]; //SDL-SVMX-READ-FLS-ENFORCED
            //COMM_PerformanceUtils.stop('4.b.PROCESS-RECEIPT-SOURCE-UPDATE - QueryConfData');
            
            //Do Details' update
            if(lstPOLines.size() > 0 && lstConfigDataForSourceUpdateDetail.size() > 0 && mapPOLinesFldDesc.size() > 0)
            {
                list<SVMXC__RMA_Shipment_Line__c> lstLinesForSU = new list<SVMXC__RMA_Shipment_Line__c>();
                for(Integer i = 0;i<lstPOLines.size();i++)
                {
                    if(lstPOLines[i].SVMXC__Received__c)
                    {
                        lstLinesForSU.add(lstPOLines[i]);
                    } 
                }   
                //COMM_PerformanceUtils.start('4.c.PROCESS-RECEIPT-SOURCE-UPDATE - ActualUpdateMethodCalled');
                lstPOLines.clear();
                lstPOLines = sourceUpdateUtil.DoSourceUpdate(lstLinesForSU,lstConfigDataForSourceUpdateDetail,mapPOLinesFldDesc);
                //COMM_PerformanceUtils.stop('4.c.PROCESS-RECEIPT-SOURCE-UPDATE - ActualUpdateMethodCalled');
            }
            //COMM_PerformanceUtils.start('4.d.PROCESS-RECEIPT-SOURCE-UPDATE - LoopPOLine');
            for(Integer i = 0;i<lstPOLines.size();i++)
            {
                if(lstPOLines[i].SVMXC__Received__c)
                { 
                    lstPOLines[i].SVMXC__Received_By__c = Userinfo.getUserId();
                    lstPOLines[i].SVMXC__Received_On__c = system.now();
                }   
            }
            //COMM_PerformanceUtils.stop('4.d.PROCESS-RECEIPT-SOURCE-UPDATE - LoopPOLine');
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('4.PROCESS-RECEIPT-SOURCE-UPDATE');
            
        }
        else if(strProcessType == 'DELIVERYONRECEIPT')
        {
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('4.SOURCE-UPDATE-DELIVERY-ON-RECEIPT');
            //COMM_PerformanceUtils.start('4.a.SOURCE-UPDATE-DELIVERY-ON-RECEIPT - QueryRTDescribeRMALineFields');
            List<String> queryFields = new List<String> {'SystemModstamp', 'SobjectType', 'NamespacePrefix', 'Name', 'LastModifiedDate', 'LastModifiedById', 'IsActive', 'Id', 'DeveloperName', 'Description', 'CreatedDate', 'CreatedById', 'BusinessProcessId'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'RecordType', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c']; //SDL-SVMX-READ-FLS-ENFORCED
            if(RecordTypes.size() > 0 )
            {
                for(RecordType r : RecordTypes)
                {
                    if(r.Name == 'Field Mapping')
                        fldMapRecTypeId = r.id;
                }
            }
            map<String,Schema.SObjectField> mapTempL = Schema.SObjectType.SVMXC__RMA_Shipment_Line__c.fields.getMap(); 
            if(mapTempL.size() > 0)
            {
                for(String s : mapTempL.keyset())
                {
                    mapPOLinesFldDesc.put(mapTempL.get(s).getDescribe().getName(),mapTempL.get(s));
                }
            }
            //COMM_PerformanceUtils.stop('4.a.SOURCE-UPDATE-DELIVERY-ON-RECEIPT - QueryRTDescribeRMALineFields');
            //COMM_PerformanceUtils.start('4.b.SOURCE-UPDATE-DELIVERY-ON-RECEIPT - QueryConfData');
            queryFields = new List<String> {'id', 'RecordTypeId', 'SVMXC__Dispatch_Process__c', 'SVMXC__Target_Field_Name__c', 'SVMXC__Action__c', 'SVMXC__Display_Value__c', 'SVMXC__Configuration_Type__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            lstConfigDataForSourceUpdateDetail = [select id, RecordTypeId, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: fldMapRecTypeId and SVMXC__Configuration_Type__c = 'LINE_UPD_ON_DELIVERY' and SVMXC__Dispatch_Process__c =: objSVMXProcess.id]; //SDL-SVMX-READ-FLS-ENFORCED
            //COMM_PerformanceUtils.stop('4.b.SOURCE-UPDATE-DELIVERY-ON-RECEIPT - QueryConfData');
            //Do Details' update
            if(lstPOLines.size() > 0 && lstConfigDataForSourceUpdateDetail.size() > 0 && mapPOLinesFldDesc.size() > 0)
            {
                //COMM_PerformanceUtils.start('4.c.SOURCE-UPDATE-DELIVERY-ON-RECEIPT - ActualUpdate');
                lstPOLines = sourceUpdateUtil.DoSourceUpdate(lstPOLines,lstConfigDataForSourceUpdateDetail,mapPOLinesFldDesc);
                //COMM_PerformanceUtils.stop('4.c.SOURCE-UPDATE-DELIVERY-ON-RECEIPT - ActualUpdate');
            }
            //COMM_PerformanceUtils.start('4.d.SOURCE-UPDATE-DELIVERY-ON-RECEIPT - LoopPOLine');
            for(Integer i = 0;i<lstPOLines.size();i++)
            {
                lstPOLines[i].SVMXC__Delivered__c = true;
                lstPOLines[i].SVMXC__Delivered_By__c = UserInfo.getUserId();
                lstPOLines[i].SVMXC__Delivered_On__c = system.now();
                lstPOLines[i].SVMXC__Line_Status__c = strRMALineStatus;
            }
            //COMM_PerformanceUtils.stop('4.d.SOURCE-UPDATE-DELIVERY-ON-RECEIPT - LoopPOLine');
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('4.SOURCE-UPDATE-DELIVERY-ON-RECEIPT');
            
        }
        else if(strProcessType == 'PICKNMOVE')
        {
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('4.PICK-N-MOVE-SOURCE-UPDATE');
            //COMM_PerformanceUtils.start('4.a.PICK-N-MOVE-SOURCE-UPDATE - QueryRTDescribeRMALineFields');
            List<String> queryFields = new List<String> {'SystemModstamp', 'SobjectType', 'NamespacePrefix', 'Name', 'LastModifiedDate', 'LastModifiedById', 'IsActive', 'Id', 'DeveloperName', 'Description', 'CreatedDate', 'CreatedById', 'BusinessProcessId'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'RecordType', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c']; //SDL-SVMX-READ-FLS-ENFORCED
            if(RecordTypes.size() > 0 )
            {
                for(RecordType r : RecordTypes)
                {
                    if(r.Name == 'Field Mapping')
                        fldMapRecTypeId = r.id;
                }
            }
            map<String,Schema.SObjectField> mapTempL = Schema.SObjectType.SVMXC__RMA_Shipment_Line__c.fields.getMap(); 
            if(mapTempL.size() > 0)
            {
                for(String s : mapTempL.keyset())
                {
                    mapPOLinesFldDesc.put(mapTempL.get(s).getDescribe().getName(),mapTempL.get(s));
                }
            }
            //COMM_PerformanceUtils.stop('4.a.PICK-N-MOVE-SOURCE-UPDATE - QueryRTDescribeRMALineFields');
            //COMM_PerformanceUtils.start('4.b.PICK-N-MOVE-SOURCE-UPDATE - QueryConfData');
            queryFields = new List<String> {'id','RecordTypeId','SVMXC__Dispatch_Process__c','SVMXC__Target_Field_Name__c','SVMXC__Action__c','SVMXC__Display_Value__c','SVMXC__Configuration_Type__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            lstConfigDataForSourceUpdateDetail = [select id, RecordTypeId, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: fldMapRecTypeId and SVMXC__Configuration_Type__c = 'LINE_UPD_ON_PICKING' and SVMXC__Dispatch_Process__c =: objSVMXProcess.id]; //SDL-SVMX-READ-FLS-ENFORCED
            //COMM_PerformanceUtils.stop('4.b.PICK-N-MOVE-SOURCE-UPDATE - QueryConfData');
            //Do Details' update
            
            if(lstPOLines.size() > 0 && lstConfigDataForSourceUpdateDetail.size() > 0 && mapPOLinesFldDesc.size() > 0)
            {
                list<SVMXC__RMA_Shipment_Line__c> lstLinesForSU = new list<SVMXC__RMA_Shipment_Line__c>();
                for(Integer i = 0;i<lstPOLines.size();i++)
                {
                    if(lstPOLines[i].SVMXC__Picked__c)
                    {
                        lstLinesForSU.add(lstPOLines[i]);
                    } 
                }   
                lstPOLines.clear();
                //COMM_PerformanceUtils.start('4.c.PICK-N-MOVE-SOURCE-UPDATE - ActualUpdate');
                lstPOLines = sourceUpdateUtil.DoSourceUpdate(lstLinesForSU,lstConfigDataForSourceUpdateDetail,mapPOLinesFldDesc);
                //COMM_PerformanceUtils.stop('4.c.PICK-N-MOVE-SOURCE-UPDATE - ActualUpdate');
            }
            //COMM_PerformanceUtils.start('4.d.PICK-N-MOVE-SOURCE-UPDATE - LoopPOLine');
            for(Integer i = 0;i<lstPOLines.size();i++)
            {
                if(lstPOLines[i].SVMXC__Picked__c)
                {
                    lstPOLines[i].SVMXC__Picked_By__c = UserInfo.getUserId();
                    lstPOLines[i].SVMXC__Picked_On__c = system.now();
                }   
            }
            //COMM_PerformanceUtils.stop('4.d.PICK-N-MOVE-SOURCE-UPDATE - LoopPOLine');
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('4.PICK-N-MOVE-SOURCE-UPDATE');
            
        }
        else if(strProcessType == 'SHIPCONFIRM')
        {
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('4.SHIP-CONFIRM-SOURCE-UPDATE');
            //COMM_PerformanceUtils.start('4.a.SHIP-CONFIRM-SOURCE-UPDATE - QueryRTDescribeRMALineFields');
            RecordTypes = [Select SystemModstamp, SobjectType, NamespacePrefix, Name, LastModifiedDate, LastModifiedById, IsActive, Id, DeveloperName, Description, CreatedDate, CreatedById, BusinessProcessId From RecordType where SobjectType = 'SVMXC__ServiceMax_Config_Data__c']; //SDL-SVMX-FLS-NOT-ENFORCED-META-DATA
            if(RecordTypes.size() > 0 )
            {
                for(RecordType r : RecordTypes)
                {
                    if(r.Name == 'Field Mapping')
                        fldMapRecTypeId = r.id;
                }
            }
            map<String,Schema.SObjectField> mapTempL = Schema.SObjectType.SVMXC__RMA_Shipment_Line__c.fields.getMap(); 
            if(mapTempL.size() > 0)
            {
                for(String s : mapTempL.keyset()) 
                {
                    mapPOLinesFldDesc.put(mapTempL.get(s).getDescribe().getName(),mapTempL.get(s));
                }
            }
            //COMM_PerformanceUtils.stop('4.a.SHIP-CONFIRM-SOURCE-UPDATE - QueryRTDescribeRMALineFields');
            //COMM_PerformanceUtils.start('4.b.SHIP-CONFIRM-SOURCE-UPDATE - QueryConfData');
            List<String> queryFields = new List<String> {'id','RecordTypeId','SVMXC__Dispatch_Process__c','SVMXC__Target_Field_Name__c','SVMXC__Action__c','SVMXC__Display_Value__c','SVMXC__Configuration_Type__c'};
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Config_Data__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
                }
            lstConfigDataForSourceUpdateDetail = [select id, RecordTypeId, SVMXC__Dispatch_Process__c, SVMXC__Target_Field_Name__c, SVMXC__Action__c, SVMXC__Display_Value__c, SVMXC__Configuration_Type__c from SVMXC__ServiceMax_Config_Data__c where RecordTypeId =: fldMapRecTypeId and SVMXC__Configuration_Type__c = 'LINE_UPD_ON_SHIP' and SVMXC__Dispatch_Process__c =: objSVMXProcess.id]; //SDL-SVMX-READ-FLS-ENFORCED
            //COMM_PerformanceUtils.stop('4.b.SHIP-CONFIRM-SOURCE-UPDATE - QueryConfData');
            //Do Details' update
            if(lstPOLines.size() > 0 && lstConfigDataForSourceUpdateDetail.size() > 0 && mapPOLinesFldDesc.size() > 0)
            {
            //COMM_PerformanceUtils.start('4.c.SHIP-CONFIRM-SOURCE-UPDATE - ActualUpdate');
                lstPOLines = sourceUpdateUtil.DoSourceUpdate(lstPOLines,lstConfigDataForSourceUpdateDetail,mapPOLinesFldDesc);
                //COMM_PerformanceUtils.stop('4.c.SHIP-CONFIRM-SOURCE-UPDATE - ActualUpdate');
            }
            //COMM_PerformanceUtils.start('4.d.SHIP-CONFIRM-SOURCE-UPDATE - LoopPOLine');
            for(Integer i = 0;i<lstPOLines.size();i++)
            {
                lstPOLines[i].SVMXC__Shipped__c = true;
                lstPOLines[i].SVMXC__Shipped_By__c = UserInfo.getUserId();
                lstPOLines[i].SVMXC__Shipped_On__c = system.now();
                lstPOLines[i].SVMXC__Line_Status__c = strShipmentLineStatus;
            }
            //COMM_PerformanceUtils.stop('4.d.SHIP-CONFIRM-SOURCE-UPDATE - LoopPOLine');
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('4.SHIP-CONFIRM');
            
        }
        
        //Added by Naveen V on 08-March-2012 For Performance
        //COMM_PerformanceUtils.start('5.UPDATING-PO-LINES');
        if(lstPOLines.size() > 0)
        {
            for(Integer i = 0;i<lstPOLines.size();i++)
            {
                lstupdatedLines.add((SVMXC__RMA_Shipment_Line__c)lstPOLines[i]);
            }
        }
        Savepoint sp;
        sp = Database.setSavepoint();
        try
        {
            if(lstupdatedLines.size() > 0) {
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( lstupdatedLines, COMM_SecurityUtils.Access.Upsertable ) ) {
                    upsert lstupdatedLines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    
                    Database.rollback(sp);
                    if(strEventName != null && strEventName.length() > 0) {
                        response.eventName = strEventName;    
                    }
                    
                    response.success = false;
                    response.message = System.Label.COMM001_TAG142;
                    return response;
                }
            }  
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('5.UPDATING-PO-LINES');
            
        }
        catch(System.DmlException e)
        {
            for (Integer i = 0; i < e.getNumDml(); i++) 
            {
                SVMXC.INTF_WebServicesDef.SVMXError error = new SVMXC.INTF_WebServicesDef.SVMXError(); 
                error.errorMsg = e.getDmlMessage(i) + ' For Unique Id: '+lstUniqueIdForClient[i];
                error.uniqueId = lstUniqueIdForClient[i];
                response.errors.add(error);
            }
            response.success = false;
            Database.rollback(sp);
            if(strEventName != null && strEventName.length() > 0)
                    response.eventName = strEventName;
            system.debug('response: '+response);
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('5.UPDATING-PO-LINES');
            //perfUtil.end(strRecordId, strProcessType);
            
            return response;
        }
        system.debug('lstupdatedLines'+lstupdatedLines.size()+lstupdatedLines);
       
        set<Id> uniqueOrderLines = new  set<Id>();
        list<INTF_WebServicesDef.APL_OrderLineCollection> OrderLinesList = new list<INTF_WebServicesDef.APL_OrderLineCollection>();
        //Update  Route Cards  (Don't Update Route Cards if RMA is from Supplier's RMA (i.e. RAM Type is external))
        if(lstupdatedLines.size() > 0 && setClonedFromId.size() > 0 && objPartsOrder.SVMXC__RMA_Type__c != 'External')
        {
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('6.AFTER-UPDATE-PO-LINES');
            
            if(strProcessType.toUpperCase() == 'PROCESSRECEIPT' || strProcessType.toUpperCase() == 'PICKNMOVE')
            {
                for(Integer i = 0;i<lstupdatedLines.size();i++)
                {
                    uniqueOrderLines.add(lstupdatedLines[i].id);
                    INTF_WebServicesDef.APL_OrderLineCollection orderLine = new INTF_WebServicesDef.APL_OrderLineCollection();
                    orderLine.orderLineRecord = lstupdatedLines[i];
                    orderLine.uniqueIdForClient = lstUniqueIdForClient[i];
                    /*if(mapLineIdClonedFromId.containskey(lstupdatedLines[i].Name))
                        orderLine.clonedFromId = mapLineIdClonedFromId.get(lstupdatedLines[i].Name);*/
                    if(setClonedFromId[i] != null || setClonedFromId[i] != 'null')  
                        orderLine.clonedFromId = setClonedFromId[i];
                    OrderLinesList.add(orderLine);
                }
            }
            else if(strProcessType.toUpperCase() == 'DELIVERYONRECEIPT')
            {
                for(Integer i = 0;i<lstupdatedLines.size();i++)
                {
                    if(lstupdatedLines[i].SVMXC__Delivered__c)
                    {
                        uniqueOrderLines.add(lstupdatedLines[i].id);
                        INTF_WebServicesDef.APL_OrderLineCollection orderLine = new INTF_WebServicesDef.APL_OrderLineCollection();
                        orderLine.orderLineRecord = lstupdatedLines[i];
                        orderLine.uniqueIdForClient = lstUniqueIdForClient[i];
                        /*if(mapLineIdClonedFromId.containskey(lstupdatedLines[i].Name))
                            orderLine.clonedFromId = mapLineIdClonedFromId.get(lstupdatedLines[i].Name);*/
                        if(setClonedFromId[i] != null || setClonedFromId[i] != 'null')  
                            orderLine.clonedFromId = setClonedFromId[i];
                        OrderLinesList.add(orderLine);
                    }   
                }
            }
            else if(strProcessType.toUpperCase() == 'SHIPCONFIRM')
            {
                for(Integer i = 0;i<lstupdatedLines.size();i++)
                {
                    if(lstupdatedLines[i].SVMXC__Shipped__c)
                    {
                        uniqueOrderLines.add(lstupdatedLines[i].id);
                        INTF_WebServicesDef.APL_OrderLineCollection orderLine = new INTF_WebServicesDef.APL_OrderLineCollection();
                        orderLine.orderLineRecord = lstupdatedLines[i];
                        orderLine.uniqueIdForClient = lstUniqueIdForClient[i];
                        /*if(mapLineIdClonedFromId.containskey(lstupdatedLines[i].Name))
                            orderLine.clonedFromId = mapLineIdClonedFromId.get(lstupdatedLines[i].Name);*/
                        if(setClonedFromId[i] != null || setClonedFromId[i] != 'null')  
                            orderLine.clonedFromId = setClonedFromId[i];
                        OrderLinesList.add(orderLine);
                    }   
                }
            }   
            system.debug('Enterd for route update');
            SVMXC.APL_Utils aplutils = new SVMXC.APL_Utils();
            system.debug('Update Route Calculation Start Time: '+system.now());
            response = aplutils.updateRouteCalculations(OrderLinesList,uniqueOrderLines,strProcessType);
            system.debug('Update Route Calculation End Time: '+system.now());
            system.debug('response from route Card: '+response);
            if(!response.success)
            {
                Database.rollback(sp);
                if(strEventName != null && strEventName.length() > 0)
                    response.eventName = strEventName;
                return response;
            }
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('6.AFTER-UPDATE-PO-LINES');
            
        }
        list<SVMXC.INTF_WebServicesDef.SVMXMap> preserveValueMap = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
        // Identify IB for unexpected serial numbers and perform entitlement
        if(strProcessType == 'PROCESSRECEIPT' && objSVMXProcess.SVMXC__Resolve_Unexpected_SN_To_IB__c == true)
        {
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('7.RESOLVE-IB');
            
            set<String> setUnexpectedSerialNumbers = new set<String>();
            for(String serialNO: lstUnexpectedSN)
            {
                setUnexpectedSerialNumbers.add(serialNO);
            }
            System.debug('TEST LOG setUnexpectedSerialNumbers: ' + setUnexpectedSerialNumbers);
            list<SVMXC__RMA_Shipment_Line__c> unexpectedOrderLines = new list<SVMXC__RMA_Shipment_Line__c>();
            list<SVMXC.INTF_WebServicesDef.SVMXMap> lstUnResolvedLines = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
            list<SVMXC.INTF_WebServicesDef.SVMXMap> lstUnExpectedSerialNumberLines = new list<SVMXC.INTF_WebServicesDef.SVMXMap>(); 
            for(SVMXC__RMA_Shipment_Line__c lines: lstupdatedLines)
            {
                if(setUnexpectedSerialNumbers.contains(lines.SVMXC__Serial_Number_List__c))
                {
                    unexpectedOrderLines.add(lines);
                    lstUnExpectedSerialNumberLines.add(new SVMXC.INTF_WebServicesDef.SVMXMap('UNEXPECTEDLINES', lines.Id));
                }
            }
            if(lstUnExpectedSerialNumberLines != NULL && lstUnExpectedSerialNumberLines.size() > 0)
                preserveValueMap.addAll(lstUnExpectedSerialNumberLines);
            System.debug('TEST LOG unexpectedOrderLines: ' + unexpectedOrderLines);
            if(unexpectedOrderLines != NULL && unexpectedOrderLines.size() > 0)
            {
                APL_Entitlement clsEntitlement = new APL_Entitlement();
                List<SVMXC__RMA_Shipment_Line__c> processedOrderLines = clsEntitlement.APL_ResolveIB_On_PD(unexpectedOrderLines);
                //if(objSVMXProcess.SVMXC__APL_Perform_Entitlement__c == true)
                    //processedOrderLines = clsEntitlement.APL_Entitlement_On_PD(processedOrderLines);
                if( COMM_SecurityUtils.getInstance().verifyFieldAccess( processedOrderLines, COMM_SecurityUtils.Access.Updateable ) ) {
                    update processedOrderLines; //SDL-SVMX-CREATE-UPDATE-FLS-ENFORCED
                } else {
                    
                    Database.rollback(sp);
                    if(strEventName != null && strEventName.length() > 0) {
                    	response.eventName = strEventName;    
                    }
                    
                    response.success = false;
        			response.message = System.Label.COMM001_TAG142;
                    return response;
                }
                
                System.debug('TEST LOG processedOrderLines: ' + processedOrderLines);
                for(SVMXC__RMA_Shipment_Line__c orderLine: processedOrderLines)
                {
                    if(orderLine.SVMXC__Serial_Number__c == NULL)
                    {
                        lstUnResolvedLines.add(new SVMXC.INTF_WebServicesDef.SVMXMap('UNRESOLVEDLINES', orderLine.Id));
                    }
                    if(lstUnResolvedLines != NULL && lstUnResolvedLines.size() > 0)
                        preserveValueMap.addAll(lstUnResolvedLines);
                }
            }

            System.debug('TEST LOG lstUnResolvedLines: ' + lstUnResolvedLines);
            list<SVMXC.INTF_WebServicesDef.SVMXMap> lstEvent = new list<SVMXC.INTF_WebServicesDef.SVMXMap>();
            List<SVMXC__SFM_Event__c> lstEvents = new List<SVMXC__SFM_Event__c>();
            List<String> queryFields = new List<String> {'id','SVMXC__Namespace__c','SVMXC__Method__c','SVMXC__Class__c' };
                if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__SFM_Event__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                    
                    Database.rollback(sp);
                    if(strEventName != null && strEventName.length() > 0) {
                        response.eventName = strEventName;    
                    }
                    
                    response.success = false;
                    response.message = System.Label.COMM001_TAG142;
                    return response;
                }
            lstEvents = [Select Id, SVMXC__Namespace__c, SVMXC__Method__c, SVMXC__Class__c from SVMXC__SFM_Event__c where SVMXC__ServiceMax_Process__c = :objSVMXProcess.Id and SVMXC__Event_Call_Type__c = 'WEBSERVICE' and SVMXC__Event_Type__c = 'Before Entitlement' and SVMXC__IsStandard__c = false]; //SDL-SVMX-READ-FLS-ENFORCED
            for(SVMXC__SFM_Event__c event: lstEvents)
            {
                if(event.SVMXC__Namespace__c != NULL && event.SVMXC__Class__c != NULL && event.SVMXC__Method__c != NULL && event.SVMXC__Namespace__c != '' && event.SVMXC__Class__c != '' && event.SVMXC__Method__c != '')
                {
                    SVMXC.INTF_WebServicesDef.SVMXMap wrpNameSpace = new SVMXC.INTF_WebServicesDef.SVMXMap('NAMESPACE', event.SVMXC__Namespace__c);
                    SVMXC.INTF_WebServicesDef.SVMXMap wrpClass = new SVMXC.INTF_WebServicesDef.SVMXMap('CLASS', event.SVMXC__Class__c);
                    SVMXC.INTF_WebServicesDef.SVMXMap wrpMethod = new SVMXC.INTF_WebServicesDef.SVMXMap('METHOD', event.SVMXC__Method__c);
                    lstEvent.add(wrpNameSpace);
                    lstEvent.add(wrpClass);
                    lstEvent.add(wrpMethod);
                }
            }
            if(lstEvent != NULL && lstEvent.size() > 0)
                preserveValueMap.addAll(lstEvent);
            // Find whether we need to perform entitlement
            if(objSVMXProcess.SVMXC__APL_Perform_Entitlement__c == true)
            {
                //If all IB's are resolved than perform entitlement
                if(lstUnResolvedLines == NULL || lstUnResolvedLines.size() == 0)
                {
                    SVMXC.INTF_WebServicesDef.INTF_SFMRequest entitlementReq = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
                    entitlementReq.valueMap = lstUnExpectedSerialNumberLines;
                    INTF_WebServicesDef.INTF_APL_PerformEntitlement_On_PD(entitlementReq);
                    preserveValueMap.clear();
                }
            }
            else
            {
                if(lstEvent == NULL || lstEvent.size() == 0)// If entitlement is not allowed and if there is no consecutive custom event to fire just skip it
                    preserveValueMap.clear();
            }
            System.debug('TEST LOG response.valueMap: ' + preserveValueMap);
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('7.RESOLVE-IB');
            
        }
        //Do inventory updates..
        if(lstupdatedLines.size() > 0)
        {
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('8.INVENTORY-UPDATES');
            //COMM_PerformanceUtils.start('8.a.INVENTORY-UPDATES - VariableDeclaration');
            set<String> setProductIds = new set<String>();
            map<String,Boolean> mapProIdStockable = new map<String,Boolean>();
            list<Product2> lstProduct = new list<Product2>();
            list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection> orderLineCollectionForInvUpdate = new list<SVMXC.INTF_WebServicesDef.APL_OrderLineCollection>();
            //map<String,Boolean> mapProIdSerializable = new map<String,Boolean>();
            //COMM_PerformanceUtils.stop('8.a.INVENTORY-UPDATES - VariableDeclaration');
            //COMM_PerformanceUtils.start('8.b.INVENTORY-UPDATES - QueryProductsCreateMap');
            for(SVMXC__RMA_Shipment_Line__c rsl : lstupdatedLines)
            {
                if(rsl.SVMXC__Product__c != null)
                    setProductIds.add(rsl.SVMXC__Product__c);
            }//Get all the product record to check the product is stockable or not.
            if(setProductIds.size() > 0)
            {
                List<String> queryFields = new List<String> {'id','Name','SVMXC__Stockable__c','SVMXC__Enable_Serialized_Tracking__c' };
                    if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'Product2', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                        
                        Database.rollback(sp);
                        if(strEventName != null && strEventName.length() > 0) {
                            response.eventName = strEventName;    
                        }
                        
                        response.success = false;
                        response.message = System.Label.COMM001_TAG142;
                        return response;
                    }
                lstProduct = [select id,Name,SVMXC__Stockable__c,SVMXC__Enable_Serialized_Tracking__c from Product2 where id IN : setProductIds]; //SDL-SVMX-READ-FLS-ENFORCED
            }
            if(lstProduct.size() > 0)
            {
                for(Product2 p : lstProduct)
                {
                    if(p.SVMXC__Stockable__c != null)
                        mapProIdStockable.put(String.valueof(p.id),p.SVMXC__Stockable__c);
                    //if(p.SVMXC__Enable_Serialized_Tracking__c != null)
                       // mapProIdSerializable.put(String.valueof(p.id).substring(0,15),p.SVMXC__Enable_Serialized_Tracking__c);
                }   
            }
            //COMM_PerformanceUtils.stop('8.b.INVENTORY-UPDATES - QueryProductsCreateMap');
            system.debug('mapProIdStockable: '+mapProIdStockable.size()+mapProIdStockable);
            //COMM_PerformanceUtils.start('8.c.INVENTORY-UPDATES - ListPrepareOrderLine');
            if(strProcessType.toUpperCase() == 'PROCESSRECEIPT')
            {
                for(Integer i = 0;i<lstupdatedLines.size();i++)
                {
                    if(lstupdatedLines[i].SVMXC__Actual_Quantity2__c >= 1 && lstupdatedLines[i].SVMXC__Received__c == true)
                    {
                        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
                        orderLine.orderLineRecord = lstupdatedLines[i];
                        orderLine.uniqueIdForClient = lstUniqueIdForClient[i];
                        orderLine.serialNumbers = newAPLOrder.orderLines[i].serialNumbers;
                        orderLineCollectionForInvUpdate.add(orderLine);
                    }
                }   
            }
            else if(strProcessType.toUpperCase() == 'DELIVERYONRECEIPT')
            {
                for(Integer i = 0;i<lstupdatedLines.size();i++)
                {
                    if(lstupdatedLines[i].SVMXC__Actual_Quantity2__c >= 1 && lstupdatedLines[i].SVMXC__Delivered__c == true)
                    {
                        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
                        orderLine.orderLineRecord = lstupdatedLines[i];
                        orderLine.uniqueIdForClient = lstUniqueIdForClient[i];
                        orderLine.serialNumbers = newAPLOrder.orderLines[i].serialNumbers;
                        orderLineCollectionForInvUpdate.add(orderLine);
                    }
                }
            }
            else if(strProcessType.toUpperCase() == 'PICKNMOVE')
            {
                for(Integer i = 0;i<lstupdatedLines.size();i++)
                {
                    if(lstupdatedLines[i].SVMXC__Picked_Qty__c >= 1 && lstupdatedLines[i].SVMXC__Picked__c == true)
                    {
                        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
                        orderLine.orderLineRecord = lstupdatedLines[i];
                        orderLine.uniqueIdForClient = lstUniqueIdForClient[i];
                        orderLine.serialNumbers = newAPLOrder.orderLines[i].serialNumbers;
                        orderLineCollectionForInvUpdate.add(orderLine);
                    }
                }
            }
            else if(strProcessType.toUpperCase() == 'SHIPCONFIRM')
            {
                for(Integer i = 0;i<lstupdatedLines.size();i++)
                {
                    if(lstupdatedLines[i].SVMXC__Picked_Qty__c >= 1 && lstupdatedLines[i].SVMXC__Shipped__c == true)
                    {
                        SVMXC.INTF_WebServicesDef.APL_OrderLineCollection orderLine = new SVMXC.INTF_WebServicesDef.APL_OrderLineCollection();
                        orderLine.orderLineRecord = lstupdatedLines[i];
                        orderLine.uniqueIdForClient = lstUniqueIdForClient[i];
                        orderLine.serialNumbers = newAPLOrder.orderLines[i].serialNumbers;
                        orderLineCollectionForInvUpdate.add(orderLine);
                    }
                }
            }
            system.debug('orderLineCollectionForInvUpdate'+orderLineCollectionForInvUpdate);
            newAPLOrder.orderLines = orderLineCollectionForInvUpdate;
            newAPLOrder.processType = strProcessType;
            SVMXC.APL_Inventory doInvUpdate = new SVMXC.APL_Inventory();
            system.debug('amarrrrr'+newAPLOrder);
            system.debug('Invontory Update Start Time: '+system.now());
            //COMM_PerformanceUtils.stop('8.c.INVENTORY-UPDATES - ListPrepareOrderLine');
            //COMM_PerformanceUtils.stop('8.d.INVENTORY-UPDATES - ActualInventoryMethodCalled');
            response = doInvUpdate.PopulateProductStockAndStockSerial(newAPLOrder);
            system.debug('Invontory Update End Time: '+system.now());
            system.debug('response from inventory: '+response);
            if(!response.success)
            {
                Database.rollback(sp);
                if(strEventName != null && strEventName.length() > 0)
                    response.eventName = strEventName;
                
                //Added by Naveen V on 08-March-2012 For Performance
                //COMM_PerformanceUtils.stop('8.d.INVENTORY-UPDATES - ActualInventoryMethodCalled');
                //COMM_PerformanceUtils.stop('8.INVENTORY-UPDATES');
                //perfUtil.end(strRecordId, strProcessType);
                
                return response;
            }
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('8.d.INVENTORY-UPDATES - ActualInventoryMethodCalled');
            //COMM_PerformanceUtils.stop('8.INVENTORY-UPDATES');
            
        }    
        //Do WorkOrder Updates..
        if(response.success)
        {
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('9.WO-UPDATES');
            
            SVMXC.INTF_WebServicesDef.INTF_SFMRequest req = new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            list<INTF_WebServicesDef.APL_OrderLineCollection> OrderLinesListForWOUpdate = new list<INTF_WebServicesDef.APL_OrderLineCollection>();
            if(strProcessType == 'PROCESSRECEIPT')
            {
                for(Integer i = 0;i<lstupdatedLines.size();i++)
                {
                    if(lstupdatedLines[i].SVMXC__Received__c)
                    {
                        INTF_WebServicesDef.APL_OrderLineCollection orderLine = new INTF_WebServicesDef.APL_OrderLineCollection();
                        orderLine.orderLineRecord = lstupdatedLines[i];
                        orderLine.uniqueIdForClient = lstUniqueIdForClient[i];
                        OrderLinesListForWOUpdate.add(orderLine);
                    }
                }
                newAPLOrder.orderLines = OrderLinesListForWOUpdate;
                req.aplOrder = newAPLOrder;
                SVMXC.APL_WorkOrderUtils woutils = new SVMXC.APL_WorkOrderUtils();
                system.debug('Create WO Creation Start Time: '+system.now());
                response = woutils.APL_CreateWorkOrdersOnReceipt(req);
                system.debug('Create WO Creation End Time: '+system.now());
                if(preserveValueMap != NULL && preserveValueMap.size() > 0)
                    response.valueMap.addall(preserveValueMap);
            }
            else if(strProcessType == 'DELIVERYONRECEIPT')
            {
                for(Integer i = 0;i<lstupdatedLines.size();i++)
                {
                    if(lstupdatedLines[i].SVMXC__Delivered__c)
                    {
                        INTF_WebServicesDef.APL_OrderLineCollection orderLine = new INTF_WebServicesDef.APL_OrderLineCollection();
                        orderLine.orderLineRecord = lstupdatedLines[i];
                        orderLine.uniqueIdForClient = lstUniqueIdForClient[i];
                        OrderLinesListForWOUpdate.add(orderLine);
                    }
                }
                newAPLOrder.orderLines = OrderLinesListForWOUpdate;
                req.aplOrder = newAPLOrder;
                SVMXC.APL_WorkOrderUtils woutils = new SVMXC.APL_WorkOrderUtils();
                system.debug('Create WO Creation Start Time: '+system.now());
                response = woutils.APL_CreateWorkOrdersOnReceipt(req);
                system.debug('Create WO Creation End Time: '+system.now());
                if(preserveValueMap != NULL && preserveValueMap.size() > 0)
                    response.valueMap.addall(preserveValueMap);
            }
            if(!response.success)
            {
                Database.rollback(sp);
                if(strEventName != null && strEventName.length() > 0)
                    response.eventName = strEventName;
                
                //Added by Naveen V on 08-March-2012 For Performance
                //COMM_PerformanceUtils.stop('WO-UPDATES');
                //perfUtil.end(strRecordId, strProcessType);
                
                return response;
            }        
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('9.WO-UPDATES');
            
        }
        //If Process Type is Ship Confirm Create External Internal RAMs
        if(response.success && strProcessType == 'SHIPCONFIRM')
        {
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.start('10.ERMA-CREATION-FOR-SHIPCONFIRM');
            
            SVMXC.APL_Utils aplutils = new SVMXC.APL_Utils();
            request= new SVMXC.INTF_WebServicesDef.INTF_SFMRequest();
            request.aplOrder = newAPLOrder;
            system.debug('Create I/E RMA Start Time: '+system.now());
            response = aplutils.CreateInternalExternalRMA(request);
            system.debug('response3: '+response);
            system.debug('Create I/E RMA End Time: '+system.now());
            if(!response.success)
            {
                Database.rollback(sp);
                if(strEventName != null && strEventName.length() > 0)
                    response.eventName = strEventName;
                
                //Added by Naveen V on 08-March-2012 For Performance
                //COMM_PerformanceUtils.stop('10.ERMA-CREATION-FOR-SHIPCONFIRM');
                //perfUtil.end(strRecordId, strProcessType);
                
                return response;
            }
            
            //Added by Naveen V on 08-March-2012 For Performance
            //COMM_PerformanceUtils.stop('10.ERMA-CREATION-FOR-SHIPCONFIRM');
            
        }
        if(strEventName != null && strEventName.length() > 0)
            response.eventName = strEventName;
        system.debug('response: '+response);
        system.debug('Save Order End Time: '+system.now());
        
        //Added by Naveen V on 08-March-2012 For Performance
        //perfUtil.end(strRecordId, strProcessType);
        
        return response;
       
    }
    
    /*
    @future
    public static void  SaveAPLOrderFuture(string strRecordID)
    {
        List<SVMXC.INTF_WebServicesDef.INTF_SFMRequest> request = new List<SVMXC.INTF_WebServicesDef.INTF_SFMRequest>();
        Attachment attachToGet = new Attachment();
        attachToGet = [select id, Body from Attachment where ParentId =: strRecordID AND Name = 'JSON String'];
        
        String JSONString = string.valueOf(attachToGet.Body);
        
        if(JSONString != null && JSONString.length() > 0)
        {
            request = (List<SVMXC.INTF_WebServicesDef.INTF_SFMRequest>)JSON.deserialize(JSONString, List<SVMXC.INTF_WebServicesDef.INTF_SFMRequest>.class);
        }
        
        system.debug('Request Created from JSON: ' + request);
    }*/
}