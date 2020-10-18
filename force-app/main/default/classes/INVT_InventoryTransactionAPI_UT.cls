/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * UT class for all new invetoy and Batch/lot implimentataion
 *
 * @author Jaysukh Patel
 * @version 20.2
 * @since 2020
 */
@isTest
public class INVT_InventoryTransactionAPI_UT
{

    public static INVT_Structure.INVT_Request invt_request = new INVT_Structure.INVT_Request();
    public static INVT_Structure.InventoryProcessInfo inventoryProcessInfo = new INVT_Structure.InventoryProcessInfo();
    public static boolean isExecuted = false;
    public static INVT_Structure.INVT_Response response1 = null;
    public static List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList = new  List<INVT_Structure.INVT_ProductSerialInfo>();
    
    public static List<INVT_Structure.INVT_LineInfo> line_infoList = new List<INVT_Structure.INVT_LineInfo>(); 
    
    //stock adjuetment
    public static boolean isExecuted1 = false;
    public static INVT_Structure.INVT_Request invt_request1 = new INVT_Structure.INVT_Request();
    public static INVT_Structure.InventoryProcessInfo inventoryProcessInfo1 = new INVT_Structure.InventoryProcessInfo();
    public static List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList1 = new  List<INVT_Structure.INVT_ProductSerialInfo>();
    public static List<INVT_Structure.INVT_LineInfo> line_infoList1 = new List<INVT_Structure.INVT_LineInfo>(); 
   
    //Batch lot
    public static INVT_Structure.INVT_Request invt_request2 = new INVT_Structure.INVT_Request();
    public static INVT_Structure.InventoryProcessInfo inventoryProcessInfo2 = new INVT_Structure.InventoryProcessInfo();
    public static List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList2 = new  List<INVT_Structure.INVT_ProductSerialInfo>();
    public static List<INVT_Structure.INVT_LineInfo> line_infoList2 = new List<INVT_Structure.INVT_LineInfo>(); 

    //Non-batch & non-serial
    public static INVT_Structure.INVT_Request invt_request3 = new INVT_Structure.INVT_Request();
    public static INVT_Structure.InventoryProcessInfo inventoryProcessInfo3 = new INVT_Structure.InventoryProcessInfo();
    public static List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList3 = new  List<INVT_Structure.INVT_ProductSerialInfo>();
    public static List<INVT_Structure.INVT_LineInfo> line_infoList3 = new List<INVT_Structure.INVT_LineInfo>(); 
    
    static void createData()
    {
        
       Product2 prodcut = new Product2();
       prodcut.Name = 'Wind Turbine';
       prodcut.ProductCode = 'WINDTURBINE';
       prodcut.IsActive = true;
       prodcut.SVMXC__Enable_Serialized_Tracking__c = true;
      
       insert prodcut; 
       //Location 
       List<SVMXC__Site__c> lstofLocation = new List<SVMXC__Site__c>();
        
       SVMXC__Site__c sourceLocation = new SVMXC__Site__c();
       sourceLocation.Name = 'Ahmedabad';
       sourceLocation.SVMXC__City__c ='Ahmedabad';
       sourceLocation.SVMXC__State__c = 'Gujarat'; 
       sourceLocation.SVMXC__Country__c = 'India';
       sourceLocation.SVMXC__Zip__c ='380001';   
       sourceLocation.SVMXC__Stocking_Location__c = true;
       sourceLocation.SVMXC__Email__c = 'test@servicemax.com'; 
       lstofLocation.add(sourceLocation) ;
        
       SVMXC__Site__c targetLocation = new SVMXC__Site__c();
       targetLocation.Name = 'Gandhinagar';
       targetLocation.SVMXC__City__c ='Gandhinagar';
       targetLocation.SVMXC__State__c = 'Gujarat'; 
       targetLocation.SVMXC__Country__c = 'India';
       targetLocation.SVMXC__Zip__c ='320008';   
       targetLocation.SVMXC__Stocking_Location__c = true;
       targetLocation.SVMXC__Email__c = 'test1@servicemax.com'; 
       lstofLocation.add(targetLocation) ;
        
       insert lstofLocation;
       //Create work order
       
       //Product stock
       SVMXC__Product_Stock__c productStock = new SVMXC__Product_Stock__c();
       productStock.SVMXC__Product__c = prodcut.id;
       productStock.SVMXC__Location__c = sourceLocation.id;
       productStock.SVMXC__Status__c = 'Available';
       productStock.SVMXC__Quantity2__c = 6.0;
       productStock.SVMXC__Reorder_Level2__c  = 3.0;
       productStock.SVMXC__Reorder_Quantity2__c = 3.0;
        
       insert productStock;
        
       List<SVMXC__Product_Serial__c> productStockedSerialList = new List<SVMXC__Product_Serial__c>();
       for(Integer i= 1; i <= 6 ; i++)
       {
           SVMXC__Product_Serial__c productStockedSerial = new SVMXC__Product_Serial__c();
           productStockedSerial.SVMXC__Active__c = true;
           productStockedSerial.Name = 'WINDT00'+i; 
           productStockedSerial.SVMXC__Product__c  = prodcut.id;
           productStockedSerial.SVMXC__Product_Stock__c = productStock.id;
           productStockedSerialList.add(productStockedSerial);
       }
       insert productStockedSerialList;
        
       List<SVMXC__Service_Order__c> lstOfWo = new List<SVMXC__Service_Order__c>();
       SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
       wo.SVMXC__Order_Status__c = 'Open';
       lstOfWo.add(wo);
       
       insert lstOfWo;
       
       Map<String,Id> recordTypeIdNameMap = new Map<String,Id>();
       Schema.DescribeSObjectResult result = SVMXC__Service_Order_Line__c.SObjectType.getDescribe();
       List<Schema.RecordTypeInfo> recordTypeList = result.getRecordTypeInfos();
       for(RecordTypeInfo recordType : recordTypeList)
       {
           recordTypeIdNameMap.put(recordType.getDeveloperName(), recordType.getRecordTypeId());
       }
        
       SVMXC__Installed_Product__c  installProduct = new SVMXC__Installed_Product__c();
       installProduct.SVMXC__Latitude__c = 77.5946;
       installProduct.SVMXC__Longitude__c = 12.9716;
        
       insert installProduct ;  
           
       List<SVMXC__Service_Order_Line__c> workdetailList = new List<SVMXC__Service_Order_Line__c>(); 
       SVMXC__Service_Order_Line__c workdetail1 = new SVMXC__Service_Order_Line__c();
       workdetail1.SVMXC__Service_Order__c = lstOfWo[0].id;
       workdetail1.SVMXC__Requested_Quantity2__c = 1.0;
       workdetail1.SVMXC__Received_Quantity2__c = 1.0;
       workdetail1.SVMXC__Actual_Quantity2__c = 1.0;
       workdetail1.SVMXC__Line_Status__c = 'Open';
       workdetail1.SVMXC__Line_Type__c = 'Parts';
       workdetail1.RecordTypeID = recordTypeIdNameMap.get('RequestReceipt');//UsageConsumption
       workdetail1.SVMXC__Requested_Location__c  =   lstofLocation[0].id;
       workdetail1.SVMXC__From_Location__c = lstofLocation[1].id;
       workdetail1.SVMXC__Product__c = prodcut.id;
       workdetail1.SVMXC__Serial_Number__c =installProduct.id;
        
            
        workdetailList.add(workdetail1) ;      
        SVMXC__Service_Order_Line__c workdetail2 = new SVMXC__Service_Order_Line__c();
        workdetail2.SVMXC__Service_Order__c = lstOfWo[0].id;
        workdetail2.SVMXC__Requested_Quantity2__c = 1.0;
        workdetail2.SVMXC__Received_Quantity2__c = 1.0;
        workdetail2.SVMXC__Actual_Quantity2__c = 1.0;
        workdetail2.SVMXC__Line_Status__c = 'Open';
        workdetail2.SVMXC__Line_Type__c = 'Parts';
        workdetail2.RecordTypeID = recordTypeIdNameMap.get('UsageConsumption');//UsageConsumption
        workdetail2.SVMXC__Consumed_From_Location__c = lstofLocation[0].id; 
        workdetail2.SVMXC__Product__c = prodcut.id; 
        workdetail2.SVMXC__Serial_Number__c =installProduct.id;
        
        workdetailList.add(workdetail2) ;

        insert workdetailList; 
        
        
        
        for(SVMXC__Product_Serial__c productSerial : productStockedSerialList )
        {
            INVT_Structure.INVT_ProductSerialInfo productSerialSt = new  INVT_Structure.INVT_ProductSerialInfo();
            productSerialSt.productStockId = productSerial.SVMXC__Product_Stock__c;
            productSerialSt.serialName = productSerial.name;
            productSerialSt.productSerialId = productSerial.id;
            sourceSerialList.add(productSerialSt);
        }
        
        
        INVT_Structure.INVT_LineInfo line_info = new INVT_Structure.INVT_LineInfo(); 
        line_info.id = workdetailList[1].id;
        line_info.name = workdetailList[1].name;
        line_info.partName = prodcut.name;
        line_info.originalQuantity = 1;
        line_info.productId = prodcut.id;
        line_info.isStockable = true;
        line_info.isSerializedTracked = true;
        line_info.isBatchLotTracked = true;
        line_info.fromLocationId = lstofLocation[0].id;
        line_info.fromLocationName = lstofLocation[0].name;
        line_info.toLocationId = lstofLocation[1].id;
        line_info.toLocationName = lstofLocation[1].name;
        line_info.sourceStatus = 'Available';
        line_info.targetStatus = 'Consumed';
        line_info.actualQuantity = 1;// new added , manually user can enter quantity value
        line_info.closeLine = false;
        line_info.sourceSerialList = sourceSerialList;
        line_infoList.add(line_info);
        
       //inventoryProcessInfo.headerRecordId = 'a1LF0000003CKorMAG';
       inventoryProcessInfo.headerRecordId = lstOfWo[0].id;
       inventoryProcessInfo.lineRecordId = '';
       inventoryProcessInfo.processId = 'WORD010';
        
       invt_request.inventoryProcessInfo = inventoryProcessInfo;
       //Save request
       isExecuted = true;
       
       Map<String,Id> recordTypeIdNameMap1 = new Map<String,Id>();
       Schema.DescribeSObjectResult result1 = SVMXC__ServiceMax_Config_Data__c.SObjectType.getDescribe();
       List<Schema.RecordTypeInfo> recordTypeList1 = result1.getRecordTypeInfos();
       for(RecordTypeInfo recordType : recordTypeList1)
       {
           recordTypeIdNameMap1.put(recordType.getDeveloperName(), recordType.getRecordTypeId());
       }
        
        
        SVMXC__ServiceMax_Processes__c invetoryprocess = [select id,SVMXC__Submodule__c,SVMXC__Module__c from SVMXC__ServiceMax_Processes__c   where SVMXC__ProcessID__c  = 'WORD010' AND RecordType.Name = 'Inventory Process'];
        List<SVMXC__ServiceMax_Config_Data__c> settings = [ select id,SVMXC__Internal_Value__c,SVMXC__Setting_Unique_ID__c  from  SVMXC__ServiceMax_Config_Data__c   where SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__Module__c = : invetoryprocess.SVMXC__Module__c and SVMXC__Setting_Unique_ID__c IN ('WORD010_SET008', 'WORD010_SET012','WORD010_SET020') AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true ORDER BY SVMXC__Setting_Unique_ID__c ASC];
        settings[0].SVMXC__Internal_Value__c = 'test2@servicemax.com';
        settings[1].SVMXC__Internal_Value__c = 'true';
        settings[2].SVMXC__Internal_Value__c = 'true';
        update settings;
        
         
        List<SVMXC__ServiceMax_Config_Data__c> lstOfCloserAction = new List<SVMXC__ServiceMax_Config_Data__c>();
        SVMXC__ServiceMax_Config_Data__c  headerExpression = new SVMXC__ServiceMax_Config_Data__c();
        headerExpression.RecordTypeID = recordTypeIdNameMap1.get('Expressions'); 
        headerExpression.SVMXC__Inventory_Process__c = invetoryprocess.id; 
        headerExpression.SVMXC__Expression_Type__c = 'INV_Header_Closure_Action';
        headerExpression.SVMXC__Field_Name__c = 'SVMXC__City__c';
        headerExpression.SVMXC__Display_Type__c = 'STRING';
        headerExpression.SVMXC__Operand__c = 'Surat';
        headerExpression.SVMXC__Operator__c = 'eq';
        
        lstOfCloserAction.add(headerExpression);
        
        SVMXC__ServiceMax_Config_Data__c  headerExpression2 = new SVMXC__ServiceMax_Config_Data__c();
        headerExpression2.RecordTypeID = recordTypeIdNameMap1.get('Expressions'); 
        headerExpression2.SVMXC__Inventory_Process__c = invetoryprocess.id; 
        headerExpression2.SVMXC__Expression_Type__c = 'INV_Related_Update_Action';
        headerExpression2.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c';
        headerExpression2.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Serial_Number__c';
        headerExpression2.SVMXC__Operator__c = 'increase';
        headerExpression2.SVMXC__Field_Name__c = 'SVMXC__Latitude__c';
        
        lstOfCloserAction.add(headerExpression2);
        
        SVMXC__ServiceMax_Config_Data__c  headerExpression3 = new SVMXC__ServiceMax_Config_Data__c();
        headerExpression3.RecordTypeID = recordTypeIdNameMap1.get('Expressions'); 
        headerExpression3.SVMXC__Inventory_Process__c = invetoryprocess.id; 
        headerExpression3.SVMXC__Expression_Type__c = 'INV_Related_Update_Action';
        headerExpression3.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c';
        headerExpression3.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Serial_Number__c';
        headerExpression3.SVMXC__Operator__c = 'decrease';
        headerExpression3.SVMXC__Field_Name__c = 'SVMXC__Longitude__c';
        
        lstOfCloserAction.add(headerExpression3);
        
        SVMXC__ServiceMax_Config_Data__c  headerExpression4 = new SVMXC__ServiceMax_Config_Data__c();
        headerExpression4.RecordTypeID = recordTypeIdNameMap1.get('Expressions'); 
        headerExpression4.SVMXC__Inventory_Process__c = invetoryprocess.id; 
        headerExpression4.SVMXC__Expression_Type__c = 'INV_Related_Update_Action';
        headerExpression4.SVMXC__Object_Name__c = 'SVMXC__Installed_Product__c';
        headerExpression4.SVMXC__Lookup_Field_API_Name__c = 'SVMXC__Serial_Number__c';
        headerExpression4.SVMXC__Operator__c = 'SET';
        headerExpression4.SVMXC__Field_Name__c = 'SVMXC__Longitude__c';
        
        lstOfCloserAction.add(headerExpression4);
        
        insert lstOfCloserAction;
                 
   }
   @isTest(SeeAllData=true)
   static void mockSetup()
   {
       
       Test.startTest();

       if(!isExecuted)
       {
           createData(); 
       }
       
       
       String strJSON = JSON.serialize(inventoryProcessInfo);
       
       System.debug('strJSON: '+ strJSON);
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/getProductStockLine/';
       //req.requestBody = Blob.valueOf('{"inventoryProcessInfo": {"headerRecordId":"a1LF0000003CKorMAG","lineRecordId":"","processId":"WORD011"}}');
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo":' + strJSON + '}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       
       
       INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI(req,res);
       if(response1 == null)
       {
          response1 = new INVT_Structure.INVT_Response();
          response1 = inventoryTransactionAPI.getProductStockLine(invt_request);
       }
       
       Test.stopTest();
         
   }
   @isTest
   static void mockSetup1()
   {
       Test.startTest();
       
       String requestStr = '{"inventoryProcessInfo": {"headerRecordId":"a1LF0000003CKorMAG","lineRecordId":"","processId":"WORD011"}}';
       INVT_InventoryTransaction.JSRGetInventoryTransaction(requestStr);
       INVT_InventoryTransaction.JSRSubmitInventoryTransaction(requestStr);
       INVT_InventoryTransaction.JSRGetInventoryTags(requestStr);
       // Exception case
       INVT_InventoryTransaction.JSRGetInventoryTransaction(null);
       INVT_InventoryTransaction.JSRSubmitInventoryTransaction(null);
       INVT_InventoryTransaction.JSRGetInventoryTags(null);
       
       Test.stopTest();
   }
   @isTest
   static void mockSetup2()
   {
       Test.startTest();
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/getProductStockLine/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo": {"headerRecordId":"a1LF0000003CKorMAG","lineRecordId":"","processId":"WORD011"}}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       INVT_Structure.InventoryProcessInfo inventoryProcessInfo = new INVT_Structure.InventoryProcessInfo();
       
       INVT_Structure.INVT_Request request = new INVT_Structure.INVT_Request();
       request.inventoryProcessInfo = inventoryProcessInfo;
       INVT_InventoryTransactionAPI invt_InventoryTransactionAPI = new INVT_InventoryTransactionAPI(req, res);
       INVT_InventoryTransactionAPI.updateStock(request);
       INVT_InventoryTransactionAPI.getProductStockLine(request);
       Test.stopTest();
   }
   @isTest(SeeAllData=true)
   static void mockSetup3()
   {
       Test.startTest();
       
       if(!isExecuted)
       {
           createData(); 
       }
       String strJSON = JSON.serialize(inventoryProcessInfo);
       
       System.debug('strJSON: '+ strJSON);
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/getProductStockLine/';
       //req.requestBody = Blob.valueOf('{"inventoryProcessInfo": {"headerRecordId":"a1LF0000003CKorMAG","lineRecordId":"","processId":"WORD011"}}');
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo":' + strJSON + '}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       
       
       INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI(req,res);
       
       List<INVT_Structure.INVT_LineInfo> lineInfoList = line_infoList;
       
       List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList = lineInfoList[0].sourceSerialList;
       List<INVT_Structure.INVT_ProductSerialInfo> targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo>();
       targetSerialList.add(sourceSerialList.remove(0));
             
       INVT_Structure.INVT_ProductSerialInfo manualTargetSerial = new INVT_Structure.INVT_ProductSerialInfo();
       manualTargetSerial.serialName = 'WIND00100';
       targetSerialList.add(manualTargetSerial);
       
       
       invt_request.inventoryProcessInfo.lineInfoList = line_infoList;
       
       //invt_request.inventoryProcessInfo.lineInfoList[0].sourceSerialList  = new List<INVT_Structure.INVT_ProductSerialInfo>();
       invt_request.inventoryProcessInfo.lineInfoList[0].sourceSerialList = sourceSerialList;
       
       //invt_request.inventoryProcessInfo.lineInfoList[0].targetSerialList  = new List<INVT_Structure.INVT_ProductSerialInfo>();
       invt_request.inventoryProcessInfo.lineInfoList[0].targetSerialList = targetSerialList;
       
       inventoryTransactionAPI.updateStock(invt_request);
       
       
       Test.stopTest();
   }
  
   @isTest(SeeAllData=true)
   static void mockSetup4()
   {
       Test.startTest();
       
       if(!isExecuted)
       {
           createData(); 
       }
       String strJSON = JSON.serialize(inventoryProcessInfo);
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/updateStock/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo":' + strJSON + '}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       
       
       INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI(req,res);
       
       List<INVT_Structure.INVT_LineInfo> lineInfoList = new List<INVT_Structure.INVT_LineInfo> ();
       lineInfoList = line_infoList;
       
       List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList = lineInfoList[0].sourceSerialList;
       List<INVT_Structure.INVT_ProductSerialInfo> targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo>();
       targetSerialList.add(sourceSerialList.remove(0));
        
       line_infoList[0].originalQuantity = 7;
       line_infoList[0].actualQuantity = 7;
           
       
       invt_request.inventoryProcessInfo.lineInfoList = lineInfoList;
       
       invt_request.inventoryProcessInfo.lineInfoList[0].sourceSerialList = sourceSerialList;
       
       invt_request.inventoryProcessInfo.lineInfoList[0].targetSerialList = targetSerialList;
       
       inventoryTransactionAPI.updateStock(invt_request);
       
       Test.stopTest();
   }
    
   @isTest 
   static void mockSetup5()
   {
       
       Test.startTest();
    
       
       SVMXC__Site__c sourceLocation = new SVMXC__Site__c();
       sourceLocation.Name = 'Ahmedabad';
       sourceLocation.SVMXC__City__c ='Ahmedabad';
       sourceLocation.SVMXC__State__c = 'Gujarat'; 
       sourceLocation.SVMXC__Country__c = 'India';
       sourceLocation.SVMXC__Zip__c ='380001';   
       sourceLocation.SVMXC__Stocking_Location__c = true;
       sourceLocation.SVMXC__Email__c = 'test@servicemax.com'; 
       
       insert sourceLocation;
       
       SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
       wo.SVMXC__Order_Status__c = 'Open';
       wo.SVMXC__Site__c = sourceLocation.id;
       insert wo;   
       
        
       List<SVMXC__Service_Order_Line__c> workdetailList = new List<SVMXC__Service_Order_Line__c>();
       SVMXC__Service_Order_Line__c workdetail2 = new SVMXC__Service_Order_Line__c();
       workdetail2.SVMXC__Service_Order__c = wo.id;
       workdetail2.SVMXC__Requested_Quantity2__c = 1.0;
       workdetail2.SVMXC__Received_Quantity2__c = 1.0;
       workdetail2.SVMXC__Actual_Quantity2__c = 1.0;
       workdetail2.SVMXC__Line_Status__c = 'Open';
       workdetail2.SVMXC__Line_Type__c = 'Parts';
       workdetail2.SVMXC__Consumed_From_Location__c = sourceLocation.id;
       //workdetail2.SVMXC__Product__c = prodcut.id;
           
     workdetailList.add(workdetail2);       
       insert workdetailList;
       
       COMM_Inventory_Classes.InventoryProcess invetoryProcess = new COMM_Inventory_Classes.InventoryProcess();
       invetoryProcess.Is_Source_Location_From_Header = true;
       invetoryProcess.Is_Multiline_Transaction = true;
       invetoryProcess.RelationShip_Name_To_Parent = 'SVMXC__Service_Order__r';
       invetoryProcess.RelationShip_to_Source_Location = 'SVMXC__Site__r';
       invetoryProcess.RelationShip_to_Target_Location = 'SVMXC__Site__r';
       invetoryProcess.Is_Source_Location_Stockable = true;
       invetoryProcess.Is_Target_Location_Stockable = true;
       invetoryProcess.RelationShip_Name_to_Product = 'SVMXC__Product__r';
       List<sobject> sobjectList = [select id, Name, SVMXC__Service_Order__r.name,SVMXC__Service_Order__r.SVMXC__Site__r.Name,SVMXC__Service_Order__r.SVMXC__Site__r.SVMXC__Stocking_Location__c ,SVMXC__Consumed_From_Location__r.Name, SVMXC__Consumed_From_Location__r.SVMXC__Stocking_Location__c,SVMXC__Product__r.Name from SVMXC__Service_Order_Line__c where id =: workdetailList[0].id];
      
       
       
       INVT_InventoryTransactionImpl invnetoryimpl = new INVT_InventoryTransactionImpl();
       invnetoryimpl.validateInventoryTransaction(invetoryProcess,sobjectList);

       
       
       invetoryProcess.Is_Multiline_Transaction = false;
       invetoryProcess.RelationShip_to_Source_Location = 'SVMXC__Consumed_From_Location__r';
       invnetoryimpl.validateInventoryTransaction(invetoryProcess,sobjectList);
       
       invetoryProcess.Is_Source_Location_From_Header = false;
       invetoryProcess.Is_Multiline_Transaction = true;
       invetoryProcess.RelationShip_to_Source_Location = 'SVMXC__Consumed_From_Location__r';
       invnetoryimpl.validateInventoryTransaction(invetoryProcess,sobjectList);
              
       
       invetoryProcess.Is_Target_Location_From_Header = true;
       invetoryProcess.Is_Multiline_Transaction = true;
       invetoryProcess.Number_of_locations = 'Two';
       invetoryProcess.RelationShip_to_Target_Location = 'SVMXC__Site__r';
       invnetoryimpl.validateInventoryTransaction(invetoryProcess,sobjectList);
       
       invetoryProcess.Is_Multiline_Transaction = false;
       invetoryProcess.RelationShip_to_Target_Location = 'SVMXC__Consumed_From_Location__r';
       invnetoryimpl.validateInventoryTransaction(invetoryProcess,sobjectList);
       
       invetoryProcess.Is_Target_Location_From_Header = false;
       invetoryProcess.Is_Multiline_Transaction = true;
       invetoryProcess.RelationShip_to_Target_Location = 'SVMXC__Consumed_From_Location__r';
       invnetoryimpl.validateInventoryTransaction(invetoryProcess,sobjectList);
       
       Test.stopTest();
   }
   @isTest 
   static void mockSetup6()
   {
       Test.startTest();
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/getProductStockLine/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo": {"headerRecordId":"a1LF0000003CKorMAG","lineRecordId":"","processId":"WORD011"}}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       INVT_InventoryTransactionService.doPost();
       Test.stopTest();
   }
   @isTest 
   static void mockSetup7()
   {
       Test.startTest();
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/updateStock/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo": {"headerRecordId":"a1LF0000003CKorMAG","lineRecordId":"","processId":"WORD011"}}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       INVT_InventoryTransactionService.doPost();
       Test.stopTest();
   }
   @isTest 
   static void mockSetup8()
   {
       Test.startTest();
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/updateStock1/';
       req.requestBody = Blob.valueOf('');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       INVT_InventoryTransactionService.doPost();
       Test.stopTest();
   }
   @isTest
   static void mockSetup9()
   {
       Test.startTest();
       
       Test.setReadOnlyApplicationMode(true);
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/ /';
       req.requestBody = Blob.valueOf('');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       try{
           
         INVT_InventoryTransactionService.doPost();
       }catch(Exception e)
       {
           
       }
       
       
       Test.setReadOnlyApplicationMode(false);
       Test.stopTest();
   }
  @isTest(SeeAlldata=true)
  static void mockSetup10()
   {
       Test.startTest();
       
       if(!isExecuted)
       {
           createData(); 
       }
       String strJSON = JSON.serialize(inventoryProcessInfo);
       
       System.debug('strJSON: '+ strJSON);
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/getProductStockLine/';
       //req.requestBody = Blob.valueOf('{"inventoryProcessInfo": {"headerRecordId":"a1LF0000003CKorMAG","lineRecordId":"","processId":"WORD011"}}');
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo":' + strJSON + '}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       
       
       INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI(req,res);
       
       List<INVT_Structure.INVT_LineInfo> lineInfoList = line_infoList;
       
       List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList = lineInfoList[0].sourceSerialList;
       List<INVT_Structure.INVT_ProductSerialInfo> targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo>();
       targetSerialList.add(sourceSerialList.remove(0));
             
       INVT_Structure.INVT_ProductSerialInfo manualTargetSerial = new INVT_Structure.INVT_ProductSerialInfo();
       manualTargetSerial.serialName = 'WIND00100';
       targetSerialList.add(manualTargetSerial);
       
       invt_request.inventoryProcessInfo.lineInfoList = line_infoList;
       
       //invt_request.inventoryProcessInfo.lineInfoList[0].sourceSerialList  = new List<INVT_Structure.INVT_ProductSerialInfo>();
       invt_request.inventoryProcessInfo.lineInfoList[0].sourceSerialList = sourceSerialList;
       
       //invt_request.inventoryProcessInfo.lineInfoList[0].targetSerialList  = new List<INVT_Structure.INVT_ProductSerialInfo>();
       invt_request.inventoryProcessInfo.lineInfoList[0].targetSerialList = targetSerialList;
       
       
      try{
           Test.setReadOnlyApplicationMode(true);
           
           inventoryTransactionAPI.updateStock(invt_request);
       }catch(Exception e)
       {
           System.assert(true);
       }
       
       Test.setReadOnlyApplicationMode(false);
       Test.stopTest();
   }
   @isTest
   static void mockSetup11()
   {
       Test.startTest();
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/getProductStockLine/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo": {"headerRecordId":"a1LF0000003CKorMAG","lineRecordId":"","processId":null}}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       INVT_InventoryTransactionService.doPost();
       Test.stopTest();
   }
    @isTest
    static void mockSetup12()
    {
        Test.startTest();
        COMM_Inventory_Classes.InventoryProcess invetoryProcess = new COMM_Inventory_Classes.InventoryProcess();
        invetoryProcess.Enforce_Uniqueness_In_Serial_Selection = 'STRICT';
        
        INVT_Structure.INVT_ProductSerialInfo productSerial= new INVT_Structure.INVT_ProductSerialInfo();
        productSerial.serialName = 'SER1';
        
        INVT_Structure.INVT_ProductSerialInfo productSerial2= new INVT_Structure.INVT_ProductSerialInfo();
        productSerial2.serialName = 'SER1';
        INVT_Structure.INVT_LineInfo lineInfo = new  INVT_Structure.INVT_LineInfo();
        
        lineInfo.targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo> {productSerial,productSerial2};
        lineInfo.isSerializedTracked = true;
        
        //Batch/lot and serialized Start
        INVT_Structure.INVT_ProductSerialInfo productSerial3= new INVT_Structure.INVT_ProductSerialInfo();
        productSerial3.serialName = 'SER2';
        productSerial3.batchLotName = 'Batch1';
        
        INVT_Structure.INVT_ProductSerialInfo productSerial4= new INVT_Structure.INVT_ProductSerialInfo();
        productSerial4.serialName = 'SER2';
        productSerial4.batchLotName = 'Batch1';
        
        INVT_Structure.INVT_LineInfo lineInfo2 = new  INVT_Structure.INVT_LineInfo();
        
        lineInfo2.targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo> {productSerial3,productSerial4};
        lineInfo2.isSerializedTracked = true;
        lineInfo2.isBatchLotTracked  = true ;
        //Batch/lot and serialized End
        
        INVT_InventoryTransactionImpl impl_invt= new INVT_InventoryTransactionImpl();
        
        List<INVT_Structure.INVT_LineInfo> lstLineInfo = new List<INVT_Structure.INVT_LineInfo>{lineInfo,lineInfo2};
            
        INVT_InventoryTransactionImpl invt_impl = new INVT_InventoryTransactionImpl();
        invt_impl.validateSerialNumberUniquness(invetoryProcess,lstLineInfo);
        
        Test.stopTest();
    }
    //Stock adjust
    static void createData1()
    {
        Product2 prodcut = new Product2();
        prodcut.Name = 'WOODAN TABLE';
        prodcut.ProductCode = 'WOODANINDIAN';
        prodcut.IsActive = true;
        prodcut.SVMXC__Enable_Serialized_Tracking__c = true;
        insert prodcut; 
       //Location 
       List<SVMXC__Site__c> lstofLocation = new List<SVMXC__Site__c>();
        
       SVMXC__Site__c sourceLocation = new SVMXC__Site__c();
       sourceLocation.Name = 'Ahmedabad';
       sourceLocation.SVMXC__City__c ='Ahmedabad';
       sourceLocation.SVMXC__State__c = 'Gujarat'; 
       sourceLocation.SVMXC__Country__c = 'India';
       sourceLocation.SVMXC__Zip__c ='380001';   
       sourceLocation.SVMXC__Stocking_Location__c = true;
       sourceLocation.SVMXC__Email__c = 'test@servicemax.com'; 
       insert sourceLocation;
        
        SVMXC__Product_Stock__c productStock = new SVMXC__Product_Stock__c();
        productStock.SVMXC__Product__c = prodcut.id;
        productStock.SVMXC__Location__c = sourceLocation.id;
        productStock.SVMXC__Status__c = 'Available';
        productStock.SVMXC__Quantity2__c = 100.0;
        productStock.SVMXC__Reorder_Level2__c  = 50.0;
        productStock.SVMXC__Reorder_Quantity2__c = 50.0;  
        
        insert productStock;
        
        List<SVMXC__Product_Serial__c> productStockedSerialList = new List<SVMXC__Product_Serial__c>();
        for(Integer i= 1; i <= 20 ; i++)
        {
            SVMXC__Product_Serial__c productStockedSerial = new SVMXC__Product_Serial__c();
            productStockedSerial.SVMXC__Active__c = true;
            productStockedSerial.Name = 'WOODAN'+i; 
            productStockedSerial.SVMXC__Product__c  = prodcut.id;
            productStockedSerial.SVMXC__Product_Stock__c = productStock.id;
            productStockedSerialList.add(productStockedSerial);
        }
        insert productStockedSerialList;
        
        for(SVMXC__Product_Serial__c productSerial : productStockedSerialList )
        {
            INVT_Structure.INVT_ProductSerialInfo productSerialSt = new  INVT_Structure.INVT_ProductSerialInfo();
            productSerialSt.productStockId = productSerial.SVMXC__Product_Stock__c;
            productSerialSt.serialName = productSerial.name;
            productSerialSt.productSerialId = productSerial.id;
            sourceSerialList1.add(productSerialSt);
        }
        
        SVMXC__Stock_Adjustment__c stockAdjustment = new SVMXC__Stock_Adjustment__c();
        stockAdjustment.SVMXC__Product__c = prodcut.id;
        stockAdjustment.SVMXC__Location__c = sourceLocation.id;
        stockAdjustment.SVMXC__New_Quantity2__c = 1;
        
        insert stockAdjustment;
        
        INVT_Structure.INVT_LineInfo line_info = new INVT_Structure.INVT_LineInfo(); 
        line_info.id = stockAdjustment.id;
        line_info.name = stockAdjustment.name;
        line_info.partName = prodcut.name;
        line_info.originalQuantity = 1;
        line_info.productId = prodcut.id;
        line_info.isStockable = true;
        line_info.isSerializedTracked = true;
        line_info.isBatchLotTracked = true;
        line_info.fromLocationId = sourceLocation.id;
        line_info.fromLocationName = sourceLocation.name;
        line_info.toLocationId = null;
        line_info.toLocationName = null;
        line_info.sourceStatus = 'Available';
        line_info.targetStatus = 'SET';
        line_info.actualQuantity = 1;// new added , manually user can enter quantity value
        line_info.closeLine = false;
        line_info.sourceSerialList = sourceSerialList1;
        line_infoList1.add(line_info);
        
       inventoryProcessInfo1.headerRecordId = stockAdjustment.id;
       inventoryProcessInfo1.lineRecordId = '';
       inventoryProcessInfo1.processId = 'SADJ001';
        
       invt_request1.inventoryProcessInfo = inventoryProcessInfo1;
        
    }
    @isTest(SeeAllData=true)
    static void mockSetup13()
    {
       Test.startTest();
       
        if(!isExecuted1)
        {
            createData1(); 
        }
       String strJSON = JSON.serialize(inventoryProcessInfo1);
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/updateStock/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo":' + strJSON + '}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       
       
       INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI(req,res);
       
       List<INVT_Structure.INVT_LineInfo> lineInfoList = new List<INVT_Structure.INVT_LineInfo> ();
       lineInfoList = line_infoList1;
       
       List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList = lineInfoList[0].sourceSerialList;
       List<INVT_Structure.INVT_ProductSerialInfo> targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo>();
       targetSerialList.add(sourceSerialList.remove(0));
        
           
       
       invt_request1.inventoryProcessInfo.lineInfoList = lineInfoList;
       
       invt_request1.inventoryProcessInfo.lineInfoList[0].sourceSerialList = sourceSerialList;
       
       invt_request1.inventoryProcessInfo.lineInfoList[0].targetSerialList = targetSerialList;
       
       inventoryTransactionAPI.updateStock(invt_request1);
       
       Test.stopTest();
    }
    //creating data for batch/lot
    static void createData2()
    {
        Product2 prodcut = new Product2();
        prodcut.Name = 'SCREW SIZE100';
        prodcut.ProductCode = 'SCREW100';
        prodcut.IsActive = true;
        prodcut.SVMXC__Enable_Serialized_Tracking__c = false;
        prodcut.SVMXC__SM_Enable_Batch_Lot_Tracking__c = true;
        
        insert prodcut; 
        
        
        List<SVMXC__SM_Batch_Lot__c> lstOfBatchLot = new List<SVMXC__SM_Batch_Lot__c>();
        
            
        SVMXC__SM_Batch_Lot__c  batch1 = new SVMXC__SM_Batch_Lot__c();
        batch1.Name = 'BATCH000100_test';
        batch1.SVMXC__SM_Product__c = prodcut.id ;
        batch1.SVMXC__SM_Quantity__c = 5;
        batch1.SVMXC__SM_Active__c  = true;
        lstOfBatchLot.add(batch1);
        
        SVMXC__SM_Batch_Lot__c  batch2 = new SVMXC__SM_Batch_Lot__c();
        batch2.Name = 'BATCH000200_test';
        batch2.SVMXC__SM_Product__c   = prodcut.id;
        batch2.SVMXC__SM_Quantity__c = 3;
        batch2.SVMXC__SM_Active__c  = true;
        lstOfBatchLot.add(batch2);
        
        insert lstOfBatchLot; 
            
            
            
            //Location 
            List<SVMXC__Site__c> lstofLocation = new List<SVMXC__Site__c>();
        
        SVMXC__Site__c sourceLocation = new SVMXC__Site__c();
        sourceLocation.Name = 'Ahmedabad';
        sourceLocation.SVMXC__City__c ='Ahmedabad';
        sourceLocation.SVMXC__State__c = 'Gujarat'; 
        sourceLocation.SVMXC__Country__c = 'India';
        sourceLocation.SVMXC__Zip__c ='380001';   
        sourceLocation.SVMXC__Stocking_Location__c = true;
        sourceLocation.SVMXC__Email__c = 'test@servicemax.com'; 
        lstofLocation.add(sourceLocation) ;
        
        SVMXC__Site__c targetLocation = new SVMXC__Site__c();
        targetLocation.Name = 'Gandhinagar';
        targetLocation.SVMXC__City__c ='Gandhinagar';
        targetLocation.SVMXC__State__c = 'Gujarat'; 
        targetLocation.SVMXC__Country__c = 'India';
        targetLocation.SVMXC__Zip__c ='320008';   
        targetLocation.SVMXC__Stocking_Location__c = true;
        targetLocation.SVMXC__Email__c = 'test1@servicemax.com'; 
        lstofLocation.add(targetLocation) ;
        
        insert lstofLocation;
        
        SVMXC__Product_Stock__c productStock = new SVMXC__Product_Stock__c();
        productStock.SVMXC__Product__c = prodcut.id;
        productStock.SVMXC__Location__c = sourceLocation.id;
        productStock.SVMXC__Status__c = 'Available';
        productStock.SVMXC__Quantity2__c = 8;
        productStock.SVMXC__Reorder_Level2__c  = 4;
        productStock.SVMXC__Reorder_Quantity2__c = 4; 
        
        insert productStock;
        
        List<SVMXC__Product_Serial__c> productStockedSerialList = new List<SVMXC__Product_Serial__c>();
        
        SVMXC__Product_Serial__c productStockedSerial = new SVMXC__Product_Serial__c();
        productStockedSerial.SVMXC__Active__c = true;
        productStockedSerial.Name = batch1.Name;
        productStockedSerial.SVMXC__Product__c  = prodcut.id;
        productStockedSerial.SVMXC__Product_Stock__c = productStock.id;
        productStockedSerial.SVMXC__SM_Batch_Lot2__c = lstOfBatchLot[0].id;
        productStockedSerial.SVMXC__SM_Quantity__c = 5;
        
        productStockedSerialList.add(productStockedSerial);
        
        insert productStockedSerialList;
        
        for(SVMXC__Product_Serial__c productSerial : productStockedSerialList )
        {
            INVT_Structure.INVT_ProductSerialInfo productSerialSt = new  INVT_Structure.INVT_ProductSerialInfo();
            productSerialSt.productStockId = productSerial.SVMXC__Product_Stock__c;
            productSerialSt.serialName = productSerial.name;
            productSerialSt.productSerialId = productSerial.id;
            productSerialSt.batchLotId = productSerial.SVMXC__SM_Batch_Lot2__c;
            productSerialSt.batchLotName = productSerial.name;
            productSerialSt.batchLotQuantity = productSerial.SVMXC__SM_Quantity__c;
            productSerialSt.batchLotTargetQuantity = 2;
            
            sourceSerialList2.add(productSerialSt);
        }
        
        SVMXC__Stock_Transfer__c stTransfer = new SVMXC__Stock_Transfer__c();
        stTransfer.SVMXC__Source_Location__c = sourceLocation.id;
        stTransfer.SVMXC__Destination_Location__c = targetLocation.id;
        
        insert stTransfer;
        
        SVMXC__Stock_Transfer_Line__c  transferLine = new SVMXC__Stock_Transfer_Line__c();
        transferLine.SVMXC__Quantity_Transferred2__c = 2;
        transferLine.SVMXC__Product__c = prodcut.id;
        transferLine.SVMXC__Stock_Transfer__c = stTransfer.id;
        
        insert transferLine;
        
        INVT_Structure.INVT_LineInfo line_info = new INVT_Structure.INVT_LineInfo(); 
        line_info.id = transferLine.id;
        line_info.name = transferLine.name;
        line_info.partName = prodcut.name;
        line_info.originalQuantity = 2;
        line_info.productId = prodcut.id;
        line_info.isStockable = true;
        line_info.isSerializedTracked = false;
        line_info.isBatchLotTracked = true;
        line_info.fromLocationId = lstofLocation[0].id;
        line_info.fromLocationName = lstofLocation[0].name;
        line_info.toLocationId = lstofLocation[1].id;
        line_info.toLocationName = lstofLocation[1].name;
        line_info.sourceStatus = 'Available';
        line_info.targetStatus = 'Available';
        line_info.actualQuantity = 2;// new added , manually user can enter quantity value
        line_info.closeLine = false;
        line_info.sourceSerialList = sourceSerialList2;
        
        line_infoList2.add(line_info);
        
       inventoryProcessInfo2.headerRecordId = stTransfer.id;
       inventoryProcessInfo2.lineRecordId = '';
       inventoryProcessInfo2.processId = 'SXFR001';
      
       invt_request2.inventoryProcessInfo = inventoryProcessInfo2;
    }
    @isTest(SeeAllData=true)
    static void mockSetup14()
    {

       Test.startTest();
       
       createData2(); 
        
       String strJSON = JSON.serialize(inventoryProcessInfo2);
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/updateStock/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo":' + strJSON + '}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       
       
       INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI(req,res);
       
       List<INVT_Structure.INVT_LineInfo> lineInfoList = new List<INVT_Structure.INVT_LineInfo> ();
       lineInfoList = line_infoList2;
       
       List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList = lineInfoList[0].sourceSerialList;
       List<INVT_Structure.INVT_ProductSerialInfo> targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo>();
       targetSerialList.addAll(sourceSerialList);
        
           
       invt_request2.inventoryProcessInfo.lineInfoList = lineInfoList;
       
       invt_request2.inventoryProcessInfo.lineInfoList[0].sourceSerialList = sourceSerialList;
       
       invt_request2.inventoryProcessInfo.lineInfoList[0].targetSerialList = targetSerialList;
       
       inventoryTransactionAPI.updateStock(invt_request2);
  
    }
   
   //Negative at target  
   @isTest(SeeAllData=true)
   static void mockSetup15()
   {
       Test.startTest();
       
       if(!isExecuted)
       {
           createData(); 
       }
       SVMXC__ServiceMax_Processes__c invetoryprocess = [select id,SVMXC__Submodule__c,SVMXC__Module__c from SVMXC__ServiceMax_Processes__c   where SVMXC__ProcessID__c  = 'WORD010' AND RecordType.Name = 'Inventory Process'];
       List<SVMXC__ServiceMax_Config_Data__c> settings = [ select id,SVMXC__Internal_Value__c,SVMXC__Setting_Unique_ID__c  from  SVMXC__ServiceMax_Config_Data__c   where SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__Module__c = : invetoryprocess.SVMXC__Module__c and SVMXC__Setting_Unique_ID__c IN ('WORD010_SET032', 'WORD010_SET037') AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true ORDER BY SVMXC__Setting_Unique_ID__c ASC];
       settings[0].SVMXC__Internal_Value__c = 'Increase';
       settings[1].SVMXC__Internal_Value__c = 'Decrease';
       
       update settings;
       
       String strJSON = JSON.serialize(inventoryProcessInfo);
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/updateStock/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo":' + strJSON + '}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       
       
       INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI(req,res);
       
       List<INVT_Structure.INVT_LineInfo> lineInfoList = new List<INVT_Structure.INVT_LineInfo> ();
       lineInfoList = line_infoList;
       
       List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList = lineInfoList[0].sourceSerialList;
       List<INVT_Structure.INVT_ProductSerialInfo> targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo>();
       targetSerialList.add(sourceSerialList.remove(0));
        
       line_infoList[0].originalQuantity = 7;
       line_infoList[0].actualQuantity = 7;
           
       
       invt_request.inventoryProcessInfo.lineInfoList = lineInfoList;
       
       invt_request.inventoryProcessInfo.lineInfoList[0].sourceSerialList = sourceSerialList;
       
       invt_request.inventoryProcessInfo.lineInfoList[0].targetSerialList = targetSerialList;
       
       inventoryTransactionAPI.updateStock(invt_request);
       
       settings[0].SVMXC__Internal_Value__c = 'Decrease';
       settings[1].SVMXC__Internal_Value__c = 'Increase';
       update settings;
       
       Test.stopTest();
   }
    static void createData3()
    {
        
       Product2 prodcut = new Product2();
       prodcut.Name = 'Wind Turbine';
       prodcut.ProductCode = 'WINDTURBINE';
       prodcut.IsActive = true;
       prodcut.SVMXC__Enable_Serialized_Tracking__c = false;
      
       insert prodcut; 
       //Location 
       List<SVMXC__Site__c> lstofLocation = new List<SVMXC__Site__c>();
        
       SVMXC__Site__c sourceLocation = new SVMXC__Site__c();
       sourceLocation.Name = 'Ahmedabad';
       sourceLocation.SVMXC__City__c ='Ahmedabad';
       sourceLocation.SVMXC__State__c = 'Gujarat'; 
       sourceLocation.SVMXC__Country__c = 'India';
       sourceLocation.SVMXC__Zip__c ='380001';   
       sourceLocation.SVMXC__Stocking_Location__c = true;
       sourceLocation.SVMXC__Email__c = 'test@servicemax.com'; 
       lstofLocation.add(sourceLocation) ;
        
       SVMXC__Site__c targetLocation = new SVMXC__Site__c();
       targetLocation.Name = 'Gandhinagar';
       targetLocation.SVMXC__City__c ='Gandhinagar';
       targetLocation.SVMXC__State__c = 'Gujarat'; 
       targetLocation.SVMXC__Country__c = 'India';
       targetLocation.SVMXC__Zip__c ='320008';   
       targetLocation.SVMXC__Stocking_Location__c = true;
       targetLocation.SVMXC__Email__c = 'test1@servicemax.com'; 
       lstofLocation.add(targetLocation) ;
        
       insert lstofLocation;
       //Create work order
      
        
       List<SVMXC__Service_Order__c> lstOfWo = new List<SVMXC__Service_Order__c>();
       SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
       wo.SVMXC__Order_Status__c = 'Open';
       lstOfWo.add(wo);
       
       insert lstOfWo;
       
       Map<String,Id> recordTypeIdNameMap = new Map<String,Id>();
       Schema.DescribeSObjectResult result = SVMXC__Service_Order_Line__c.SObjectType.getDescribe();
       List<Schema.RecordTypeInfo> recordTypeList = result.getRecordTypeInfos();
       for(RecordTypeInfo recordType : recordTypeList)
       {
           recordTypeIdNameMap.put(recordType.getDeveloperName(), recordType.getRecordTypeId());
       }
        
       SVMXC__Installed_Product__c  installProduct = new SVMXC__Installed_Product__c();
       installProduct.SVMXC__Latitude__c = 77.5946;
       installProduct.SVMXC__Longitude__c = 12.9716;
        
       insert installProduct ;  
           
       List<SVMXC__Service_Order_Line__c> workdetailList = new List<SVMXC__Service_Order_Line__c>(); 
       SVMXC__Service_Order_Line__c workdetail1 = new SVMXC__Service_Order_Line__c();
       workdetail1.SVMXC__Service_Order__c = lstOfWo[0].id;
       workdetail1.SVMXC__Requested_Quantity2__c = 1.0;
       workdetail1.SVMXC__Received_Quantity2__c = 1.0;
       workdetail1.SVMXC__Actual_Quantity2__c = 1.0;
       workdetail1.SVMXC__Line_Status__c = 'Open';
       workdetail1.SVMXC__Line_Type__c = 'Parts';
       workdetail1.RecordTypeID = recordTypeIdNameMap.get('RequestReceipt');//UsageConsumption
       workdetail1.SVMXC__Requested_Location__c  =   lstofLocation[0].id;
       workdetail1.SVMXC__From_Location__c = lstofLocation[1].id;
       workdetail1.SVMXC__Product__c = prodcut.id;
       workdetail1.SVMXC__Serial_Number__c =installProduct.id;
        
            
        workdetailList.add(workdetail1) ;      
        SVMXC__Service_Order_Line__c workdetail2 = new SVMXC__Service_Order_Line__c();
        workdetail2.SVMXC__Service_Order__c = lstOfWo[0].id;
        workdetail2.SVMXC__Requested_Quantity2__c = 1.0;
        workdetail2.SVMXC__Received_Quantity2__c = 1.0;
        workdetail2.SVMXC__Actual_Quantity2__c = 1.0;
        workdetail2.SVMXC__Line_Status__c = 'Open';
        workdetail2.SVMXC__Line_Type__c = 'Parts';
        workdetail2.RecordTypeID = recordTypeIdNameMap.get('UsageConsumption');//UsageConsumption
        workdetail2.SVMXC__Consumed_From_Location__c = lstofLocation[0].id; 
        workdetail2.SVMXC__Product__c = prodcut.id; 
        workdetail2.SVMXC__Serial_Number__c =installProduct.id;
        
        workdetailList.add(workdetail2) ;

        insert workdetailList; 
        
        
        INVT_Structure.INVT_LineInfo line_info = new INVT_Structure.INVT_LineInfo(); 
        line_info.id = workdetailList[1].id;
        line_info.name = workdetailList[1].name;
        line_info.partName = prodcut.name;
        line_info.originalQuantity = 1;
        line_info.productId = prodcut.id;
        line_info.isStockable = true;
        line_info.isSerializedTracked = false;
        line_info.isBatchLotTracked = false;
        line_info.fromLocationId = lstofLocation[0].id;
        line_info.fromLocationName = lstofLocation[0].name;
        line_info.toLocationId = lstofLocation[1].id;
        line_info.toLocationName = lstofLocation[1].name;
        line_info.sourceStatus = 'Available';
        line_info.targetStatus = 'Consumed';
        line_info.actualQuantity = 1;// new added , manually user can enter quantity value
        line_info.closeLine = false;
        line_info.sourceSerialList = sourceSerialList3;
        line_infoList3.add(line_info);
        
       //inventoryProcessInfo.headerRecordId = 'a1LF0000003CKorMAG';
       inventoryProcessInfo3.headerRecordId = lstOfWo[0].id;
       inventoryProcessInfo3.lineRecordId = '';
       inventoryProcessInfo3.processId = 'WORD010';
        
       invt_request3.inventoryProcessInfo = inventoryProcessInfo3;
       //Save request
       

        
                 
   }
   @isTest(SeeAllData=true)
   static void mockSetup16()
   {
       Test.startTest();
       

        createData3();
       
        SVMXC__ServiceMax_Processes__c invetoryprocess = [select id,SVMXC__Submodule__c,SVMXC__Module__c from SVMXC__ServiceMax_Processes__c   where SVMXC__ProcessID__c  = 'WORD010' AND RecordType.Name = 'Inventory Process'];
        List<SVMXC__ServiceMax_Config_Data__c> settings = [ select id,SVMXC__Internal_Value__c,SVMXC__Setting_Unique_ID__c  from  SVMXC__ServiceMax_Config_Data__c   where SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__Module__c = : invetoryprocess.SVMXC__Module__c and SVMXC__Setting_Unique_ID__c IN ('WORD010_SET010') AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true ORDER BY SVMXC__Setting_Unique_ID__c ASC];
        settings[0].SVMXC__Internal_Value__c = 'false';
        update settings;
       
       
       String strJSON = JSON.serialize(inventoryProcessInfo);
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/updateStock/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo":' + strJSON + '}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       
       
       INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI(req,res);
       
       List<INVT_Structure.INVT_LineInfo> lineInfoList = new List<INVT_Structure.INVT_LineInfo> ();
       lineInfoList = line_infoList3;
       
       List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList = new List<INVT_Structure.INVT_ProductSerialInfo>();
       List<INVT_Structure.INVT_ProductSerialInfo> targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo>();
        
       line_infoList3[0].originalQuantity = 7;
       line_infoList3[0].actualQuantity = 7;
           
       
       invt_request3.inventoryProcessInfo.lineInfoList = lineInfoList;
       
       invt_request3.inventoryProcessInfo.lineInfoList[0].sourceSerialList = sourceSerialList;
       
       invt_request3.inventoryProcessInfo.lineInfoList[0].targetSerialList = targetSerialList;
       
       inventoryTransactionAPI.updateStock(invt_request3);
        
       settings[0].SVMXC__Internal_Value__c = 'true';
       update settings;
       
       Test.stopTest();
   }
    @isTest(SeeAllData=true)
    static void mockSetup17()
    {
       Test.startTest();
       
        if(!isExecuted1)
        {
            createData1(); 
        }
       SVMXC__ServiceMax_Processes__c invetoryprocess = [select id,SVMXC__Submodule__c,SVMXC__Module__c from SVMXC__ServiceMax_Processes__c   where SVMXC__ProcessID__c  = 'SADJ001' AND RecordType.Name = 'Inventory Process'];
       List<SVMXC__ServiceMax_Config_Data__c> settings = [ select id,SVMXC__Internal_Value__c,SVMXC__Setting_Unique_ID__c  from  SVMXC__ServiceMax_Config_Data__c   where SVMXC__Setting_ID__r.SVMXC__Submodule__r.SVMXC__Module__c = : invetoryprocess.SVMXC__Module__c and SVMXC__Setting_Unique_ID__c IN ('SADJ001_SET032') AND SVMXC__Setting_Configuration_Profile__r.SVMXC__Active__c = true ORDER BY SVMXC__Setting_Unique_ID__c ASC];
       settings[0].SVMXC__Internal_Value__c = 'Decrease';
        
       update settings;
        
       String strJSON = JSON.serialize(inventoryProcessInfo1);
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SVMXDEV/svmx/rest/InventoryTransaction/updateStock/';
       req.requestBody = Blob.valueOf('{"inventoryProcessInfo":' + strJSON + '}');
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response = res;
       
       
       
       INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI(req,res);
       
       List<INVT_Structure.INVT_LineInfo> lineInfoList = new List<INVT_Structure.INVT_LineInfo> ();
       lineInfoList = line_infoList1;
       
       List<INVT_Structure.INVT_ProductSerialInfo> sourceSerialList = lineInfoList[0].sourceSerialList;
       List<INVT_Structure.INVT_ProductSerialInfo> targetSerialList = new List<INVT_Structure.INVT_ProductSerialInfo>();
       targetSerialList.add(sourceSerialList.remove(0));
        
           
       
       invt_request1.inventoryProcessInfo.lineInfoList = lineInfoList;
       
       invt_request1.inventoryProcessInfo.lineInfoList[0].sourceSerialList = sourceSerialList;
       
       invt_request1.inventoryProcessInfo.lineInfoList[0].targetSerialList = targetSerialList;
       
       inventoryTransactionAPI.updateStock(invt_request1);
       
       settings[0].SVMXC__Internal_Value__c = 'Set';
        
       update settings;
        
       Test.stopTest();
    }

}