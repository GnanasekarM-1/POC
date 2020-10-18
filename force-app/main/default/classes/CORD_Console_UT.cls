@isTest
public class CORD_Console_UT {

    @testSetup 
    static void setup() {
        // insert account
        Account accountRecord = new Account(name='test');
        insert accountRecord;

        // insert product 
        Product2 productRecord = new Product2(name='test', isActive=true, SVMXC__Stockable__c=true, SVMXC__Enable_Serialized_Tracking__c = true, SVMXC__Product_Line__c='techLine', family='techFamily');
        Product2 productRecord2 = new Product2(name='test2', isActive=true, SVMXC__Stockable__c=true, SVMXC__SM_Enable_Batch_Lot_Tracking__c = true, SVMXC__Product_Line__c='techLine', family='techFamily');
        List<Product2> productList = new List<Product2> {productRecord, productRecord2};
        insert productList; 

        //insert ib record
        SVMXC__Installed_Product__c installedProdRecord = new SVMXC__Installed_Product__c();
        installedProdRecord.SVMXC__Product__c = productRecord.Id;
        installedProdRecord.SVMXC__Zip__c = '12345';
        insert installedProdRecord;

        // insert site
        SVMXC__Site__c site = new SVMXC__Site__c(Name='siteTest', SVMXC__Account__c=accountRecord.Id);
        insert site;

        // insert product stock
        SVMXC__Product_Stock__c prodStock = new SVMXC__Product_Stock__c(SVMXC__Location__c=site.Id);
        insert prodStock;

        // insert batch lot
        SVMXC__SM_Batch_Lot__c batchLot = new SVMXC__SM_Batch_Lot__c();
        batchLot.Name = 'batch_001';
        batchLot.SVMXC__SM_Active__c = true;
        batchLot.SVMXC__SM_Product__c = productRecord.Id;
        batchLot.SVMXC__SM_Quantity__c = 50;
        insert batchLot;

        //insert stock serial record
        SVMXC__Product_Serial__c stockSerial = new SVMXC__Product_Serial__c();
        stockSerial.Name = 'Stock1';    
        stockSerial.SVMXC__Active__c = true;
        stockSerial.SVMXC__Product_Stock__c = prodStock.Id;
        stockSerial.SVMXC__Product__c = productRecord.Id;
        stockSerial.SVMXC__SM_Quantity__c = 5;
        stockSerial.SVMXC__SM_Batch_Lot2__c = batchLot.Id;
        insert stockSerial;

        /*SVMXC__ServiceMax_Processes__c process1 = new SVMXC__ServiceMax_Processes__c();
        process1.SVMXC__Source_Object_Name__c=CORD_ConsoleImpl.CHANGE_ORDER_OBJECT;
        process1.SVMXC__Target_Object_Name__c='SVMXC__Service_Order__c';
        process1.SVMXC__Record_Type_Name__c = 'Object Mapping';
        insert process1;

        List<SVMXC__ServiceMax_Config_Data__c> mappingList = new List<SVMXC__ServiceMax_Config_Data__c> ();
        SVMXC__ServiceMax_Config_Data__c data1 = new SVMXC__ServiceMax_Config_Data__c();
        data1.SVMXC__Target_Field_Name__c
        data1.SVMXC__Target_Field_Name__c

        mappingList.add(data1);
        List<SVMXC__ServiceMax_Config_Data__c> fieldMapping = [SELECT Id, SVMXC__Target_Field_Name__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__MapID__c =: changeOrderMappingProcessId AND recordtype.name =:FIELD_MAPPING_RT AND SVMXC__Target_Field_Name__c IN : defaultFieldList];

        FIELD_MAPPING_RT
*/
        // create change order config Record

        // Create FCO Record

        // create Change Order Required Parts Record
    }

    @isTest
    static void JSRSaveFieldChangeOrder_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        String requestString = JSON.serialize(request);
        System.assert(CORD_Console.JSRSaveFieldChangeOrder(requestString) != NULL);
        /*Object o = CORD_Console.JSRSaveFieldChangeOrder(requestString);
        String s = JSON.serialize(o);
        System.debug('@@'+s);
        s = s.removeEnd('"');
        s = s.removeStart('"');
        s = s.remove('\\');
        System.debug('@@@'+s);

        CORD_WrapperDef.FCO_Response response = (CORD_WrapperDef.FCO_Response) JSON.deserialize(s, CORD_WrapperDef.FCO_Response.class );
        System.assert(response.success);*/
        //System.debug('test##'+CORD_Console.JSRSaveFieldChangeOrder(requestString));
        //CORD_WrapperDef.FCO_Response response = CORD_Console.JSRSaveFieldChangeOrder(requestString);
        //Object response = (Object) System.JSON.deserializeStrict( JSON.stringify(CORD_Console.JSRSaveFieldChangeOrder(requestString)), Object.Class );

        //System.assert(response.success);
        /*CORD_WrapperDef.FCO_Response response = (CORD_WrapperDef.FCO_Response) CORD_Console.JSRSaveFieldChangeOrder(requestString);
        System.assert(response.success);*/

    }
       
    @isTest
    static void JSRSaveFieldChangeOrder_Test_Negative1(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        String requestString = JSON.serialize(request);
        CORD_WrapperDef.keyValuePair pair = new CORD_WrapperDef.keyValuePair('test','test');
        System.assert(CORD_Console.JSRSaveFieldChangeOrder(requestString) != NULL);
    }

    @isTest
    static void JSRSaveFieldChangeOrder_Test_Negative2(){
        String requestString = JSON.serialize('test'); // invalid request
        System.assert(CORD_Console.JSRSaveFieldChangeOrder(requestString) != NULL);
    }

   

    @isTest
    static void JSRDeleteFieldChangeOrderRecords_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        String requestString = JSON.serialize(request);
        CORD_Console.JSRSaveFieldChangeOrder(requestString);
        List<SVMXC__SM_Change_Order__c> changeOrderRecords = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        if(!changeOrderRecords.isEmpty()){
            request.fcosfId = changeOrderRecords[0].Id;
            requestString = JSON.serialize(request);
            Object response = CORD_Console.JSRDeleteFieldChangeOrderRecords(requestString);
            System.assert(response != NULL);
        }
    }

    @isTest
    static void JSRgetPicklistValues_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        String requestString = JSON.serialize(request);
        CORD_Console.JSRSaveFieldChangeOrder(requestString);
        List<SVMXC__SM_Change_Order__c> changeOrderRecords = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        if(!changeOrderRecords.isEmpty()){
            request.fcosfId = changeOrderRecords[0].Id;
            requestString = JSON.serialize(request);
            Object response = CORD_Console.JSRGetPicklistValues(requestString);
            System.assert(response != NULL);
        }
    }

    @isTest
    static void JSRGetCustomLabels_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        List<SVMXC__SM_Change_Order__c> changeOrderRecords = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        if(!changeOrderRecords.isEmpty()){
            request.fcosfId = changeOrderRecords[0].Id;
            String requestString = JSON.serialize(request);
            Object response = CORD_Console.JSRGetCustomLabels(requestString);
            System.assert(response != NULL);
        }
    }

    @isTest
    static void createFieldTypeOperatorMap_Test(){
        Map<String,  List<String>> fieldTypeOperMap = new Map<String,  List<String>> ();
        Test.startTest();   
        CORD_ConsoleImpl.createFieldTypeOperatorMap(CORD_ConsoleImpl.fieldTypeOperatorMap);
        Test.stopTest();
    }

    @isTest
    static void getOperatorsList_Test(){
        List<CORD_WrapperDef.KeyValuePair> keyValuePairList = new List<CORD_WrapperDef.KeyValuePair> ();
        Test.startTest();   
        CORD_ConsoleImpl.getOperatorsList('STRING');
        Test.stopTest();
    }

    @isTest
    static void getBatchDetails_Test(){
        Product2 productRecord = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();   
        CORD_ConsoleImpl.getBatchDetails(productRecord.Id);
        Test.stopTest();
    }

    @isTest
    static void getUserConfigForSearch_Test(){
        Test.startTest();   
        new CORD_ConsoleImpl().getUserConfigForSearch();
        Test.stopTest();
    }
    
    @isTest
    static void JSRDeleteFieldChangeOrderRecords_Negative_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.fcosfId = '';
        String requestString = JSON.serialize(request);
        Object response = CORD_Console.JSRDeleteFieldChangeOrderRecords(requestString);
        System.assert(response != NULL);
    }

    @isTest
    static void JSRCloneFieldChangeOrderRecord_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        String requestString = JSON.serialize(request);
        CORD_Console.JSRSaveFieldChangeOrder(requestString);
        List<SVMXC__SM_Change_Order__c> changeOrderRecords = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        if(!changeOrderRecords.isEmpty()){
            request.fcosfId = changeOrderRecords[0].Id;
            requestString = JSON.serialize(request);
            Object response = CORD_Console.JSRCloneFieldChangeOrderRecord(requestString);
            System.assert(response != NULL);
        }
    }

    @isTest
    static void JSRCloneFieldChangeOrderRecord_Negative_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.fcosfId = '';
        String requestString = JSON.serialize(request);
        Object response = CORD_Console.JSRCloneFieldChangeOrderRecord(requestString);
        System.assert(response != NULL);
    }



    @isTest
    static void JSRGetFieldChangeOrder_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        String requestString = JSON.serialize(request);
        CORD_Console.JSRSaveFieldChangeOrder(requestString);
        List<SVMXC__SM_Change_Order__c> changeOrderRecords = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        if(!changeOrderRecords.isEmpty()){
            request.fcosfId = changeOrderRecords[0].Id;
            requestString = JSON.serialize(request);
            Object response = CORD_Console.JSRGetFieldChangeOrder(requestString);
            System.assert(response != NULL);
        }
    }

    @isTest
    static void JSRGetFieldChangeOrder_Negative_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.fcosfId = '';
        String requestString = JSON.serialize(request);
        Object response = CORD_Console.JSRGetFieldChangeOrder(requestString);
        System.assert(response != NULL);
    }
    

    @isTest
    static void JSRGetFieldChangeOrdersList_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
            CORD_WrapperDef.FCOFieldInfo titleField = new CORD_WrapperDef.FCOFieldInfo();
            titleField.fieldName = 'SVMXC__SM_CORD_Config__c';
            titleField.displayName = 'SVMXC__SM_CORD_Config__r.Name';
            titleField.fieldType = 'REFERENCE';
            List<CORD_WrapperDef.FCOFieldInfo> selectedColumns = new List<CORD_WrapperDef.FCOFieldInfo> ();
            selectedColumns.add(titleField);
            request.selectedColumns = selectedColumns;
            new CORD_ConsoleImpl().getConfiguredFields(selectedColumns);            
            Object response = CORD_Console.JSRGetFieldChangeOrdersList(JSON.serialize(request));
            System.assert(response != NULL);
    }

    @isTest
    static void getWorkDetailsList_Test(){
        CORD_WorkOrderBatch workOrderBatch = new CORD_WorkOrderBatch('','','');
        List<Product2> prodList = [SELECT Id FROM Product2 LIMIT 1];
        SVMXC__SM_Change_Order_Parts__c parts = new SVMXC__SM_Change_Order_Parts__c(SVMXC__SM_Quantity__c = 5,
        SVMXC__SM_Product__c = prodList[0].Id);
        workOrderBatch.changeOrderPartsList =  new List<SVMXC__SM_Change_Order_Parts__c> {parts};
        workOrderBatch.getWorkDetailsList(NULL);
    }

    

    @isTest
    static void JSRGetFieldChangeOrdersList_Neg_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        Test.startTest();
        Object response = CORD_Console.JSRGetFieldChangeOrdersList(JSON.serialize(request));
        Test.stopTest();
    }

    @isTest
    static void JSRCreateFCOLines_Neg_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        Test.startTest();
        Object response = CORD_Console.JSRCreateFCOLines(JSON.serialize(request));
        Test.stopTest();
    }

    @isTest
    static void JSRSearchInstalledProduct_Neg_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        Test.startTest();
        Object response = CORD_Console.JSRSearchInstalledProduct(JSON.serialize(request));
        Test.stopTest();
    }

    @isTest
    static void JSRGetFCOScreen_Neg_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        Test.startTest();
        Object response = CORD_Console.JSRGetFCOScreen(JSON.serialize(request));
        Test.stopTest();
    }

    @isTest
    static void JSRCreateWorkOrders_Neg_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        Test.startTest();
        Object response = CORD_Console.JSRCreateWorkOrders(JSON.serialize(request));
        Test.stopTest();
    }

    

    @isTest
    static void JSRGetSearchResultInfo_Neg_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        Test.startTest();
        Object response = CORD_Console.JSRGetSearchResultInfo(JSON.serialize(request));
        Test.stopTest();
    }

    @isTest
    static void getAdditionalFieldsForWokrOrder_Test(){
        Test.startTest();
        Object response = CORD_ConsoleImpl.getAdditionalFieldsForWokrOrder();
        Test.stopTest();
    }

    @isTest
    static void getUserConfigForWorkOrder_Test(){
        Test.startTest();
        Object response = new CORD_ConsoleImpl().getUserConfigForWorkOrder();
        Test.stopTest();
    }

  
    
    
    

    

    

    @isTest
    static void JSRGetRequiredParts_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.searchKeyword = '';
        String requestString = JSON.serialize(request);
        Object response = CORD_Console.JSRGetRequiredParts(requestString);
        System.assert(response != NULL);
        
    }

    @isTest
    static void JSRGetRequiredParts_Test2(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.searchKeyword = 'test';
        String requestString = JSON.serialize(request);
        Object response = CORD_Console.JSRGetRequiredParts(requestString);
        System.assert(response != NULL);
        
    }

    @isTest
    static void saveFieldChangeOrder_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        CORD_WrapperDef.FCO_Response response;
        Test.startTest();
        response = new CORD_ConsoleImpl().saveFieldChangeOrder(request.fieldChangeOrderInfo);
        Test.stopTest();
        System.assertEquals(Label.FCO001_TAG002 , response.message);    
        System.assert(response.success);        
    }

    @isTest
    static void saveFieldChangeOrder_Negative_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        fieldChangeOrderInfo.fcoName = ''; // invalid request
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        CORD_WrapperDef.FCO_Response response;
        Test.startTest();
        response = new CORD_ConsoleImpl().saveFieldChangeOrder(request.fieldChangeOrderInfo);
        Test.stopTest();
        System.assert(!response.success);        
    }

    

    @isTest
    static void getFieldChangeOrder_Negative_Test(){
        CORD_WrapperDef.FCO_Response response;
        Test.startTest();
        response = new CORD_ConsoleImpl().getFieldChangeOrder('');
        Test.stopTest();
        System.assert(!response.success);        
    }

        @isTest
    static void JSRGetSearchProductList_Test(){
        CORD_WrapperDef.FCO_Response response;
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.searchKeyword = 'test';
        Test.startTest();
        CORD_Console.JSRGetSearchProductList(JSON.serialize(request));
        Test.stopTest();
    }

    @isTest
    static void JSRGetSearchProductList_Neg_Test(){
        CORD_WrapperDef.FCO_Response response;
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.searchKeyword = '';
        Test.startTest();
        CORD_Console.JSRGetSearchProductList(JSON.serialize(request));
        Test.stopTest();
    }
    

    @isTest
    static void JSRGetFieldsInfo_Test(){
        CORD_WrapperDef.FCO_Response response;
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.objectAPIName = CORD_ConsoleImpl.CHANGE_ORDER_OBJECT;
        CORD_Console.JSRGetFieldsInfo(JSON.serialize(request));
        System.assert(CORD_Console.JSRGetFieldsInfo(JSON.serialize(request)) != NULL);        
    }

    @isTest
    static void JSRGetFieldsInfo_IB_Test(){
        CORD_WrapperDef.FCO_Response response;
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.objectAPIName = CORD_ConsoleImpl.INSTALLED_PRODUCT_OBJECT;
        CORD_Console.JSRGetFieldsInfo(JSON.serialize(request));
        System.assert(CORD_Console.JSRGetFieldsInfo(JSON.serialize(request)) != NULL);        
    }

    @isTest
    static void JSRGetFieldsInfo_Picklist_Test(){
        CORD_WrapperDef.FCO_Response response;
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.objectAPIName = CORD_ConsoleImpl.CHANGE_ORDER_OBJECT;
        CORD_Console.JSRGetFieldsInfo(JSON.serialize(request));
        System.assert(CORD_Console.JSRGetFieldsInfo(JSON.serialize(request)) != NULL);        
    }

    @isTest
    static void JSRGetFieldsInfo_Neg_Test(){
        CORD_WrapperDef.FCO_Response response;
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.objectAPIName = 'testabc';
        System.assert(CORD_Console.JSRGetFieldsInfo(JSON.serialize(request)) != NULL);    
        request.objectAPIName = '';     
        System.assert(CORD_Console.JSRGetFieldsInfo(JSON.serialize(request)) != NULL);               
    }

    

    @isTest
    static void getFieldChangeOrdersList_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        CORD_WrapperDef.FCO_Response response;
        Test.startTest();
        new CORD_ConsoleImpl().saveFieldChangeOrder(request.fieldChangeOrderInfo);

        CORD_WrapperDef.FCOFieldInfo titleField = new CORD_WrapperDef.FCOFieldInfo();
        titleField.fieldName = 'SVMXC__SM_CORD_Config__c';
        titleField.displayName = 'SVMXC__SM_CORD_Config__r.Name'; 
        titleField.fieldType = 'REFERENCE';
        List<CORD_WrapperDef.FCOFieldInfo> selectedColumns = new List<CORD_WrapperDef.FCOFieldInfo> ();
        selectedColumns.add(titleField);

        response = new CORD_ConsoleImpl().getFieldChangeOrdersList(selectedColumns);
        Test.stopTest();
        System.assert(response.success);  
        
    }

    @isTest
    static void getFieldChangeOrder_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        CORD_WrapperDef.FCO_Response response;
        Test.startTest();
        new CORD_ConsoleImpl().saveFieldChangeOrder(request.fieldChangeOrderInfo);
        List<SVMXC__SM_Change_Order__c> changeOrderRecords = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        if(!changeOrderRecords.isEmpty()){
            response = new CORD_ConsoleImpl().getFieldChangeOrder(changeOrderRecords[0].Id);
        }
        Test.stopTest();
        System.assert(response.success);        
    }

    @isTest
    static void deleteFieldChangeOrderRecords_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        CORD_WrapperDef.FCO_Response response;
        Test.startTest();
        response = new CORD_ConsoleImpl().saveFieldChangeOrder(request.fieldChangeOrderInfo);
        List<SVMXC__SM_Change_Order__c> changeOrderRecords = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        if(!changeOrderRecords.isEmpty()){
            response = new CORD_ConsoleImpl().deleteFieldChangeOrderRecords(changeOrderRecords[0].Id);
        }
        Test.stopTest();
        System.assertEquals(Label.FCO001_TAG001, response.message);    
        System.assert(response.success);        
    }

    @isTest
    static void deleteFieldChangeOrderRecords_Negative_Test(){
        CORD_WrapperDef.FCO_Response response;
        Test.startTest();
        response = new CORD_ConsoleImpl().deleteFieldChangeOrderRecords('');
        Test.stopTest();
        System.assert(!response.success);        
    }

    @isTest
    static void createExceptionLogs_Test(){
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try{
            Integer i = 1/0;
        }
        catch(Exception ex){
            Test.startTest();
            new CORD_ConsoleImpl().createExceptionLogs(ex, response, 'dummyMethod', 'dummy error message');
            Test.stopTest();
            System.assert(response.message != NULL);  
        }
              
    }

    @isTest
    static void isValidReqPartsRequest_Test(){
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        CORD_WrapperDef.RequiredParts requiredParts;
        Boolean isValidRequest = true;
        Test.startTest();
        requiredParts = createRequiredPartsWrapper();
        requiredParts.quantity = -4;
        isValidRequest = new CORD_ConsoleImpl().isValidReqPartsRequest(new List<CORD_WrapperDef.RequiredParts> {requiredParts});
        Test.stopTest();
        System.assert(!isValidRequest);        
    }

   
    @isTest
    static void JSRSaveSearchExpression_Neg_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        Test.startTest();
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        Test.stopTest();
        
    }
    

    @isTest
    static void JSRSaveSearchExpressionIB_Test(){
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        CORD_WrapperDef.FCOSearchExpression searchExpression = new CORD_WrapperDef.FCOSearchExpression();
        
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.searchTopLevelIBOnly = true;
        request.fieldChangeOrderInfo = changeOrderInfo;
        List<CORD_WrapperDef.ExpressionRows> expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        List<String> operatorForRows = new List<String> {'AND','AND'};
        
        // ROW-1
        CORD_WrapperDef.ExpressionRows row1 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row1ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns1 = new List<String> {'AND'};

        CORD_WrapperDef.Expression row1Col1 = new CORD_WrapperDef.Expression();
        row1Col1.fieldName = 'SVMXC__Alternate_Company__c';
        row1Col1.operator = 'eq';
        row1Col1.value = 'k';
        row1Col1.fieldType = 'STRING';

        CORD_WrapperDef.Expression row1Col2 = new CORD_WrapperDef.Expression();
        row1Col2.fieldName = 'createdDate';
        row1Col2.operator = 'lt';
        row1Col2.value = String.valueOf(System.today()+2);
        row1Col2.fieldType = 'DATETIME';

        row1ColList.add(row1Col1);
        row1ColList.add(row1Col2);

        row1.expressions = row1ColList;
        row1.operatorForColumns = operatorForColumns1;
        row1.selectedProductId = product.Id;

        // ROW-2
        CORD_WrapperDef.ExpressionRows row2 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row2ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns2 = new List<String> {'OR'}; 

        CORD_WrapperDef.Expression row2Col1 = new CORD_WrapperDef.Expression();
        row2Col1.fieldName = 'SVMXC__Distributor_Company__c';
        row2Col1.operator = 'eq';
        row2Col1.value = 'k';
        row2Col1.fieldType = 'REFERENCE';
        row2Col1.displayName = 'SVMXC__Distributor_Company__r.Name';

        CORD_WrapperDef.Expression row2Col2 = new CORD_WrapperDef.Expression();
        row2Col2.fieldName = 'SVMXC__Status__c';
        row2Col2.operator = 'cntn';
        row2Col2.value = 'test';
        row2Col2.fieldType = 'PICKLIST';

        row2ColList.add(row2Col1);
        row2ColList.add(row2Col2);

        row2.expressions = row2ColList;
        row2.operatorForColumns = operatorForColumns2;
        row2.selectedProductId = product.Id;

        // ROW-3
        CORD_WrapperDef.ExpressionRows row3 = new CORD_WrapperDef.ExpressionRows();
        
        List<CORD_WrapperDef.Expression> row3ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns3 = new List<String> {'AND'};

        CORD_WrapperDef.Expression row3Col1 = new CORD_WrapperDef.Expression();
        row3Col1.fieldName = 'SVMXC__Latitude__c';
        row3Col1.operator = 'eq';
        row3Col1.value = '7';
        row3Col1.fieldType = 'DOUBLE';

        CORD_WrapperDef.Expression row3Col2 = new CORD_WrapperDef.Expression();
        row3Col2.fieldName = 'SVMXC__IsSwapped__c';
        row3Col2.operator = 'eq';
        row3Col2.value = 'TRUE';
        row3Col2.fieldType = 'BOOLEAN';

        row3ColList.add(row3Col1);
        row3ColList.add(row3Col2);

        row3.expressions = row3ColList;
        row3.operatorForColumns = operatorForColumns3;
        row3.selectedProductId = product.Id;

        expressionRows.add(row1);
        expressionRows.add(row2);
        expressionRows.add(row3);

        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = operatorForRows;

        searchExpressions.instProdExpression = searchExpression;
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        Test.startTest();
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        new CORD_ConsoleImpl().getSearchExpression(request.fcoSfId);
        Test.stopTest();
        

    }

    @isTest
    static void JSRSaveSearchExpressionTA_Test(){
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        CORD_WrapperDef.FCOSearchExpression searchExpression = new CORD_WrapperDef.FCOSearchExpression();
        
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.searchTopLevelIBOnly = true;
        request.fieldChangeOrderInfo = changeOrderInfo;
        List<CORD_WrapperDef.ExpressionRows> expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        List<String> operatorForRows = new List<String> {'AND','AND'};
        
        // ROW-1
        CORD_WrapperDef.ExpressionRows row1 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row1ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns1 = new List<String> {'AND'};

        CORD_WrapperDef.Expression row1Col1 = new CORD_WrapperDef.Expression();
        row1Col1.fieldName = 'SVMXC__Alternate_Company__c';
        row1Col1.operator = 'eq';
        row1Col1.value = 'k';
        row1Col1.fieldType = 'STRING';

        CORD_WrapperDef.Expression row1Col2 = new CORD_WrapperDef.Expression();
        row1Col2.fieldName = 'SVMXC__Date_Installed__c';
        row1Col2.operator = 'eq';
        row1Col2.value = String.valueOf(System.today());
        row1Col2.fieldType = 'DATE';

        row1ColList.add(row1Col1);
        row1ColList.add(row1Col2);

        row1.expressions = row1ColList;
        row1.operatorForColumns = operatorForColumns1;
        row1.selectedProductId = product.Id;

        // ROW-2
        CORD_WrapperDef.ExpressionRows row2 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row2ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns2 = new List<String> {'OR'}; 

        CORD_WrapperDef.Expression row2Col1 = new CORD_WrapperDef.Expression();
        row2Col1.fieldName = 'SVMXC__Distributor_Company__c';
        row2Col1.operator = 'eq';
        row2Col1.value = 'k';
        row2Col1.fieldType = 'REFERENCE';
        row2Col1.displayName = 'SVMXC__Distributor_Company__r.Name';

        CORD_WrapperDef.Expression row2Col2 = new CORD_WrapperDef.Expression();
        row2Col2.fieldName = 'SVMXC__Status__c';
        row2Col2.operator = 'cntn';
        row2Col2.value = 'test';
        row2Col2.fieldType = 'PICKLIST';

        row2ColList.add(row2Col1);
        row2ColList.add(row2Col2);

        row2.expressions = row2ColList;
        row2.operatorForColumns = operatorForColumns2;
        row2.selectedProductId = product.Id;

        // ROW-3
        CORD_WrapperDef.ExpressionRows row3 = new CORD_WrapperDef.ExpressionRows();
        
        List<CORD_WrapperDef.Expression> row3ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns3 = new List<String> {'AND'};

        CORD_WrapperDef.Expression row3Col1 = new CORD_WrapperDef.Expression();
        row3Col1.fieldName = 'SVMXC__Latitude__c';
        row3Col1.operator = 'eq';
        row3Col1.value = '7';
        row3Col1.fieldType = 'DOUBLE';

        CORD_WrapperDef.Expression row3Col2 = new CORD_WrapperDef.Expression();
        row3Col2.fieldName = 'SVMXC__IsSwapped__c';
        row3Col2.operator = 'eq';
        row3Col2.value = 'TRUE';
        row3Col2.fieldType = 'BOOLEAN';

        row3ColList.add(row3Col1);
        row3ColList.add(row3Col2);

        row3.expressions = row3ColList;
        row3.operatorForColumns = operatorForColumns3;
        row3.selectedProductId = product.Id;

        expressionRows.add(row1);
        expressionRows.add(row2);
        expressionRows.add(row3);

        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = operatorForRows;

        searchExpressions.instProdExpression = searchExpression;
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        Test.startTest();
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        new CORD_ConsoleImpl().getSearchExpression(request.fcoSfId);
        Test.stopTest();
        

    }

    @isTest
    static void getSearchExpression_Test(){
        createChangeOrder();
        List<SVMXC__SM_Change_Order__c>  changeOrderList = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        if(!changeOrderList.isEmpty()){
            new CORD_ConsoleImpl().getSearchExpression(changeOrderList[0].Id);
        }
    }

    @isTest
    static void JSRGetSearchResultInfo_Test(){
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        CORD_WrapperDef.FCOSearchExpression searchExpression = new CORD_WrapperDef.FCOSearchExpression();
        
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.searchTopLevelIBOnly = false;
        request.fieldChangeOrderInfo = changeOrderInfo;
        List<CORD_WrapperDef.ExpressionRows> expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        List<String> operatorForRows = new List<String> ();
        
        // ROW-1
        CORD_WrapperDef.ExpressionRows row1 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row1ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns1 = new List<String> ();

        CORD_WrapperDef.Expression row1Col1 = new CORD_WrapperDef.Expression();
        row1Col1.fieldName = 'SVMXC__Zip__c';
        row1Col1.operator = 'eq';
        row1Col1.value = '12345';
        row1Col1.fieldType = 'STRING';

        row1ColList.add(row1Col1);

        row1.expressions = row1ColList;
        row1.operatorForColumns = operatorForColumns1;
        row1.selectedProductId = product.Id;

        expressionRows.add(row1);

        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = operatorForRows;

        searchExpressions.instProdExpression = searchExpression;
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));

        CORD_WrapperDef.FCO_Request request2 = new CORD_WrapperDef.FCO_Request();
        request2.fcoSfId = changeOrder.Id;

        Test.startTest();
        CORD_Console.JSRGetSearchResultInfo(JSON.serialize(request2));
        Test.stopTest();
        

    }

    @isTest 
    static void getSearchResultStatus_Test(){
        SVMXC__SM_Change_Order__c changeOrder = createChangeOrder();
        SVMXC__SM_Change_Order_Log__c changeOrderLog = new SVMXC__SM_Change_Order_Log__c();
        changeOrderLog.SVMXC__SM_Log_Type__c = 'FCO Line Generation';
        changeOrderLog.SVMXC__SM_Change_Order__c = changeOrder.Id;
        changeOrderLog.SVMXC__SM_Completed_On__c = System.now();
        changeOrderLog.SVMXC__SM_Started_On__c = System.now();
        insert changeOrderLog;

        CORD_ConsoleImpl.batchStatusByTestClass = 'Holding';
        new CORD_ConsoleImpl().getSearchResultInfo(changeOrder.Id);

        CORD_ConsoleImpl.batchStatusByTestClass = 'Processing';
        new CORD_ConsoleImpl().getSearchResultInfo(changeOrder.Id);

        CORD_ConsoleImpl.batchStatusByTestClass = CORD_ConsoleImpl.BATCH_COMPLETED;
        new CORD_ConsoleImpl().getSearchResultInfo(changeOrder.Id);

        CORD_ConsoleImpl.batchStatusByTestClass = CORD_ConsoleImpl.BATCH_ABORTED;
        new CORD_ConsoleImpl().getSearchResultInfo(changeOrder.Id);

        CORD_ConsoleImpl.batchStatusByTestClass = CORD_ConsoleImpl.BATCH_FAILED;
        new CORD_ConsoleImpl().getSearchResultInfo(changeOrder.Id);

        CORD_ConsoleImpl.batchStatusByTestClass = CORD_ConsoleImpl.BLANK_STRING;
        CORD_ConsoleImpl.getSearchResultStatus(changeOrder.Id);
    }

    

    @isTest 
    static void getFCOScreen_Test(){
        SVMXC__SM_Change_Order__c changeOrder = createChangeOrder();
        SVMXC__SM_Change_Order_Log__c changeOrderLog = new SVMXC__SM_Change_Order_Log__c();
        changeOrderLog.SVMXC__SM_Log_Type__c = CORD_ConsoleImpl.LOG_TYPE_FCO_GENERATION;
        changeOrderLog.SVMXC__SM_Change_Order__c = changeOrder.Id;
        changeOrderLog.SVMXC__SM_Completed_On__c = System.now();
        changeOrderLog.SVMXC__SM_Started_On__c = System.now();
        insert changeOrderLog;
        new CORD_ConsoleImpl().getFCOScreen(changeOrder.Id);
        changeOrderLog.SVMXC__SM_Log_Type__c = CORD_ConsoleImpl.LOG_TYPE_WO_GENERATION;
        update changeOrderLog;
        new CORD_ConsoleImpl().getFCOScreen(changeOrder.Id);
    }   

   
  

    @isTest
    static void JSRGetSearchResultInfo_BatchLot_Test(){
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];

        List<Product2> productList = [SELECT Id,SVMXC__Enable_Serialized_Tracking__c, SVMXC__SM_Enable_Batch_Lot_Tracking__c FROM Product2];
        Product2 productRecord = productList[0];
        productRecord.SVMXC__Enable_Serialized_Tracking__c = true;
        productRecord.SVMXC__SM_Enable_Batch_Lot_Tracking__c = true;
        update productRecord;
        
        SVMXC__SM_Batch_Lot__c batchLot = new SVMXC__SM_Batch_Lot__c();
        batchLot.Name = 'batch_001';
        batchLot.SVMXC__SM_Quantity__c = 50;
        batchLot.SVMXC__SM_Active__c = true;
        batchLot.SVMXC__SM_Product__c = productRecord.Id;       
        insert batchLot;

        SVMXC__Product_Serial__c stockSerial = new SVMXC__Product_Serial__c(SVMXC__Active__c = true);
        stockSerial.Name = '12345'; // name is seial number
        stockSerial.SVMXC__SM_Batch_Lot2__c = batchLot.Id;
        stockSerial.SVMXC__Product__c = productRecord.Id;
        stockSerial.SVMXC__SM_Quantity__c = 25;
        insert stockSerial;

        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        CORD_WrapperDef.FCOSearchExpression searchExpression = new CORD_WrapperDef.FCOSearchExpression();
        
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.searchTopLevelIBOnly = false;
        request.fieldChangeOrderInfo = changeOrderInfo;

        List<CORD_WrapperDef.ExpressionRows> expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        List<String> operatorForRows = new List<String> {'AND'};

        // ROW-1
        CORD_WrapperDef.ExpressionRows row1 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row1ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns1 = new List<String> {'OR'};

        CORD_WrapperDef.Expression row1Col1 = new CORD_WrapperDef.Expression();
        row1Col1.fieldName = CORD_ConsoleImpl.BATCH_LOT_NUMBER_PLACEHOLDER_FIELD;
        row1Col1.operator = 'eq';
        row1Col1.value = '12345';
        row1Col1.fieldType = 'STRING';

        CORD_WrapperDef.Expression row1Col2 = new CORD_WrapperDef.Expression();
        row1Col2.fieldName = CORD_ConsoleImpl.BATCH_LOT_NUMBER_PLACEHOLDER_FIELD;
        row1Col2.operator = 'eq';
        row1Col2.value = '01234';
        row1Col2.fieldType = 'STRING';

        row1ColList.add(row1Col1);
        row1ColList.add(row1Col2);


        row1.expressions = row1ColList;
        row1.operatorForColumns = operatorForColumns1;
        row1.selectedProductId = productRecord.Id;

        expressionRows.add(row1);
        //-----row one added-----//

        CORD_WrapperDef.ExpressionRows row2 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row2ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns2 = new List<String> ();

        CORD_WrapperDef.Expression row2Col1 = new CORD_WrapperDef.Expression();

        row2Col1.fieldName = 'Name';
        row2Col1.operator = 'eq';
        row2Col1.value = '12345';
        row2Col1.fieldType = 'STRING';
        row2ColList.add(row2Col1);


        row2.expressions = row2ColList;
        row2.operatorForColumns = operatorForColumns2;
        row2.selectedProductId = productRecord.Id;

        expressionRows.add(row2);

        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = operatorForRows;

        searchExpressions.batchLotExpression = searchExpression;
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));

        CORD_WrapperDef.FCO_Request request2 = new CORD_WrapperDef.FCO_Request();
        request2.fcoSfId = changeOrder.Id;

        Test.startTest();
        CORD_Console.JSRGetSearchResultInfo(JSON.serialize(request2));
        Test.stopTest();
        

    }


    @isTest
    static void JSRCreateFCOLines_Test(){
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        CORD_WrapperDef.FCOSearchExpression searchExpression = new CORD_WrapperDef.FCOSearchExpression();
        
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.searchTopLevelIBOnly = false;
        request.fieldChangeOrderInfo = changeOrderInfo;
        List<CORD_WrapperDef.ExpressionRows> expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        List<String> operatorForRows = new List<String> ();
        
        // ROW-1
        CORD_WrapperDef.ExpressionRows row1 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row1ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns1 = new List<String> ();

        CORD_WrapperDef.Expression row1Col1 = new CORD_WrapperDef.Expression();
        row1Col1.fieldName = 'SVMXC__Zip__c';
        row1Col1.operator = 'eq';
        row1Col1.value = '12345';
        row1Col1.fieldType = 'STRING';

        row1ColList.add(row1Col1);

        row1.expressions = row1ColList;
        row1.operatorForColumns = operatorForColumns1;
        row1.selectedProductId = product.Id;

        expressionRows.add(row1);

        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = operatorForRows;

        searchExpressions.instProdExpression = searchExpression;
        
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));

        CORD_WrapperDef.FCO_Request request2 = new CORD_WrapperDef.FCO_Request();
        request2.fcoSfId = changeOrder.Id;
        CORD_ConsoleImpl.getToBeGeneratedWOCount(request2.fcoSfId);
        

        Test.startTest();
        CORD_Console.JSRCreateFCOLines(JSON.serialize(request2));
        Test.stopTest();
    }
    
    @isTest
    static void JSRHasFcoHeaderUpdated_Test(){
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];

        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();

        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.fcoSfId = changeOrder.Id;
        changeOrderInfo.lastModifiedDate = '43243242';

        request.fieldChangeOrderInfo = changeOrderInfo;
        CORD_Console.JSRHasFcoHeaderUpdated(JSON.serialize(request));
    }

    @isTest
    static void JSRHasFcoHeaderUpdated_Neg_Test(){
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];

        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();

        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.fcoSfId = CORD_ConsoleImpl.BLANK_STRING;
        request.fieldChangeOrderInfo = changeOrderInfo;
        CORD_Console.JSRHasFcoHeaderUpdated(JSON.serialize(request));
        new CORD_ConsoleImpl().hasFcoHeaderUpdated('test','test'); // negative test for impl class

    }




    
    @isTest
    static void JSRCreateWorkOrders_Old_Test(){
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        CORD_WrapperDef.FCOSearchExpression searchExpression = new CORD_WrapperDef.FCOSearchExpression();
        
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.searchTopLevelIBOnly = false;
        request.fieldChangeOrderInfo = changeOrderInfo;
        List<CORD_WrapperDef.ExpressionRows> expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        List<String> operatorForRows = new List<String> ();
        
        // ROW-1
        CORD_WrapperDef.ExpressionRows row1 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row1ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns1 = new List<String> ();

        CORD_WrapperDef.Expression row1Col1 = new CORD_WrapperDef.Expression();
        row1Col1.fieldName = 'SVMXC__Zip__c';
        row1Col1.operator = 'eq';
        row1Col1.value = '12345';
        row1Col1.fieldType = 'STRING';

        row1ColList.add(row1Col1);

        row1.expressions = row1ColList;
        row1.operatorForColumns = operatorForColumns1;
        row1.selectedProductId = product.Id;

        expressionRows.add(row1);

        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = operatorForRows;

        String fcoSfId = changeOrder.Id;
        searchExpressions.instProdExpression = searchExpression;
        request.fcoSfId = fcoSfId;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));

        CORD_WrapperDef.FCO_Request request2 = new CORD_WrapperDef.FCO_Request();
        request2.fcoSfId = fcoSfId;
        
       // CORD_Console.JSRCreateFCOLines(JSON.serialize(request2));
        insertIbLine(fcoSfId);
        //insertStockSerialLine(fcoSfId); 
        insertBatchLotLine(fcoSfId);
        List<SVMXC__SM_Change_Order_Line__c> changeOrderLines = [SELECT Id,SVMXC__SM_Generate_WORD__c,SVMXC__SM_Line_Status__c,SVMXC__SM_Batch_Lot2__c,SVMXC__SM_Stocked_Serial__c,SVMXC__SM_Installed_Product__c FROM SVMXC__SM_Change_Order_Line__c WHERE SVMXC__SM_Change_Order__c =: fcoSfId];
        System.debug('changeOrderLines@@'+changeOrderLines);
        System.debug('getToBeGeneratedWOCount@@'+CORD_ConsoleImpl.getToBeGeneratedWOCount(fcoSfId));

        CORD_WorkOrderBatch.isFailedFromTestClass = true;
        Test.startTest();
        CORD_Console.JSRCreateWorkOrders(JSON.serialize(request2));
        Test.stopTest();
    }

    @isTest
    static void JSRGetWorkOrderInfo_Neg_Test(){
        CORD_WrapperDef.FCO_Request request2 = new CORD_WrapperDef.FCO_Request();
        request2.fcoSfId = '';
        Test.startTest();
        CORD_Console.JSRGetWorkOrderInfo(JSON.serialize(request2));
        Test.stopTest();
    }

    @isTest
    static void JSRGetCustomLabels2_Test(){
        CORD_WrapperDef.FCO_Request request2 = new CORD_WrapperDef.FCO_Request();
        Test.startTest();
        CORD_Console.JSRGetCustomLabels(JSON.serialize(request2));
        Test.stopTest();
    }

    @isTest
    static void JSRGetFCOScreen_Test(){
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        CORD_WrapperDef.FCOSearchExpression searchExpression = new CORD_WrapperDef.FCOSearchExpression();
        
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.searchTopLevelIBOnly = false;
        request.fieldChangeOrderInfo = changeOrderInfo;
        List<CORD_WrapperDef.ExpressionRows> expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        List<String> operatorForRows = new List<String> ();
        
        // ROW-1
        CORD_WrapperDef.ExpressionRows row1 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row1ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns1 = new List<String> ();

        CORD_WrapperDef.Expression row1Col1 = new CORD_WrapperDef.Expression();
        row1Col1.fieldName = 'SVMXC__Zip__c';
        row1Col1.operator = 'eq';
        row1Col1.value = '12345';
        row1Col1.fieldType = 'STRING';

        row1ColList.add(row1Col1);

        row1.expressions = row1ColList;
        row1.operatorForColumns = operatorForColumns1;
        row1.selectedProductId = product.Id;

        expressionRows.add(row1);

        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = operatorForRows;

        searchExpressions.instProdExpression = searchExpression;
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));

        CORD_WrapperDef.FCO_Request request2 = new CORD_WrapperDef.FCO_Request();
        request2.fcoSfId = changeOrder.Id;
        
        Test.startTest();
        CORD_Console.JSRGetFCOScreen(JSON.serialize(request2));
        Test.stopTest();
    }

    @isTest
    static void JSRUpdateFCOLines_Test(){
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        createChangeOrder();
        SVMXC__SM_Change_Order__c changeOrder = [SELECT Id, (SELECT Id FROM Change_Order_Lines__r) FROM SVMXC__SM_Change_Order__c LIMIT 1];

        //new line
        List<SVMXC__Installed_Product__c> ibList = [SELECT Id FROM SVMXC__Installed_Product__c LIMIT 1];
        SVMXC__SM_Change_Order_Line__c fcoLineWithIb = new SVMXC__SM_Change_Order_Line__c(SVMXC__SM_Line_Status__c = 'Draft', SVMXC__SM_Change_Order__c = changeOrder.Id, SVMXC__SM_Generate_WORD__c = true);
        if(!ibList.isEmpty()){
            fcoLineWithIb.SVMXC__SM_Installed_Product__c = ibList[0].id;
        }

        request.fcoSfId = changeOrder.Id;
        request.oldRecordList = changeOrder.Change_Order_Lines__r;
        request.newRecordList = new List<sObject> {fcoLineWithIb};
       
        Test.startTest();
        CORD_Console.JSRUpdateFCOLines(JSON.serialize(request));
        Test.stopTest();
    }


    @isTest
    static void JSRSearchInstalledProduct_Test(){
        CORD_WrapperDef.FCO_Request request2 = new CORD_WrapperDef.FCO_Request();
        List<Product2> productList = [SELECT Id, Name FROM Product2 LIMIT 1];
        request2.productId = productList[0].Id;
        request2.searchKeyword = 'test';
        Test.startTest();
        CORD_Console.JSRSearchInstalledProduct(JSON.serialize(request2));
        Test.stopTest();
    }

    @isTest
    static void JSRSaveUserPreference_Test(){
        CORD_WrapperDef.FCO_Request request2 = new CORD_WrapperDef.FCO_Request();
        Test.startTest();
        CORD_Console.JSRSaveUserPreference( JSON.serialize(new CORD_ConsoleImpl().getUserConfigForSearch()));
        Test.stopTest();
    }

    @isTest
    static void techAttribSearch_test(){
        List<Product2> productList = [SELECT Id, Family, SVMXC__Product_Line__c FROM Product2 LIMIT 1];
        PIQ_TestDataFactory.createAccountsContacts(1,1);   
        PIQ_TestDataFactory.createInstalledProducts(productList);
    
        SVMXC__Installed_Product__c ib = [SELECT Id FROM SVMXC__Installed_Product__c LIMIT 1];
    
        List<SVMXC__SM_IB_Technical_Attributes__c> techAttribList = new List<SVMXC__SM_IB_Technical_Attributes__c> ();
    
        SVMXC__SM_IB_Technical_Attributes__c textTechAttribute1 = new SVMXC__SM_IB_Technical_Attributes__c();
        textTechAttribute1.SVMXC__SM_Installed_Product_id__c = ib.Id;
        textTechAttribute1.SVMXC__SM_Attr_Name__c = 'textAttrib';
        textTechAttribute1.SVMXC__SM_Attr_Value__c = 'test';
        textTechAttribute1.SVMXC__SM_Type__c = 'Text';
        techAttribList.add(textTechAttribute1);
    
    
        SVMXC__SM_IB_Technical_Attributes__c booleanTechAttribute1 = new SVMXC__SM_IB_Technical_Attributes__c();
        booleanTechAttribute1.SVMXC__SM_Installed_Product_id__c = ib.Id;
        booleanTechAttribute1.SVMXC__SM_Attr_Name__c = 'booleanAttrib';
        booleanTechAttribute1.SVMXC__SM_Boolean_Value__c = true;
        booleanTechAttribute1.SVMXC__SM_Type__c = 'Boolean';
        techAttribList.add(booleanTechAttribute1);
    
        SVMXC__SM_IB_Technical_Attributes__c textTechAttribute2 = new SVMXC__SM_IB_Technical_Attributes__c();
        textTechAttribute2.SVMXC__SM_Installed_Product_id__c = ib.Id;
        textTechAttribute2.SVMXC__SM_Attr_Name__c = 'textAttrib';
        textTechAttribute2.SVMXC__SM_Attr_Value__c = 'test';
        textTechAttribute2.SVMXC__SM_Type__c = 'Text';
        techAttribList.add(textTechAttribute2);
    
    
        SVMXC__SM_IB_Technical_Attributes__c booleanTechAttribute2 = new SVMXC__SM_IB_Technical_Attributes__c();
        booleanTechAttribute2.SVMXC__SM_Installed_Product_id__c = ib.Id;
        booleanTechAttribute2.SVMXC__SM_Attr_Name__c = 'booleanAttrib';
        booleanTechAttribute2.SVMXC__SM_Boolean_Value__c = true;
        booleanTechAttribute2.SVMXC__SM_Type__c = 'Boolean';
        techAttribList.add(booleanTechAttribute2);
    
        SVMXC__SM_IB_Technical_Attributes__c textTechAttribute3 = new SVMXC__SM_IB_Technical_Attributes__c();
        textTechAttribute3.SVMXC__SM_Installed_Product_id__c = ib.Id;
        textTechAttribute3.SVMXC__SM_Attr_Name__c = 'textAttrib';
        textTechAttribute3.SVMXC__SM_Attr_Value__c = 'test';
        textTechAttribute3.SVMXC__SM_Type__c = 'Text';
        techAttribList.add(textTechAttribute3);
    
    
        SVMXC__SM_IB_Technical_Attributes__c booleanTechAttribute3 = new SVMXC__SM_IB_Technical_Attributes__c();
        booleanTechAttribute3.SVMXC__SM_Installed_Product_id__c = ib.Id;
        booleanTechAttribute3.SVMXC__SM_Attr_Name__c = 'booleanAttrib';
        booleanTechAttribute3.SVMXC__SM_Boolean_Value__c = true;
        booleanTechAttribute3.SVMXC__SM_Type__c = 'Boolean';
        techAttribList.add(booleanTechAttribute3);
    
        insert techAttribList;
        
    
        SVMXC__SM_Change_Order__c changeOrder = createChangeOrder();
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        CORD_WrapperDef.FCOSearchExpression searchExpression = new CORD_WrapperDef.FCOSearchExpression();
    
        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.searchTopLevelIBOnly = true;
        request.fieldChangeOrderInfo = changeOrderInfo;
        
        List<CORD_WrapperDef.ExpressionRows> expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        List<String> operatorForRows = new List<String> {'OR','OR'};
    
        // ROW-1
        CORD_WrapperDef.ExpressionRows row1 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row1ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns1 = new List<String> {'AND'};
    
        CORD_WrapperDef.Expression row1Col1 = new CORD_WrapperDef.Expression();
        row1Col1.fieldName = 'textAttrib';
        row1Col1.operator = 'eq';
        row1Col1.value = 'test';
        row1Col1.fieldType = 'STRING';
    
        CORD_WrapperDef.Expression row1Col2 = new CORD_WrapperDef.Expression();
        row1Col2.fieldName = 'booleanAttrib';
        row1Col2.operator = 'is';
        row1Col2.value = 'true';
        row1Col2.fieldType = 'BOOLEAN';
    
        row1ColList.add(row1Col1);
        row1ColList.add(row1Col2);
    
        row1.expressions = row1ColList;
        row1.operatorForColumns = operatorForColumns1;
        row1.selectedProductId = product.Id;
    
        // ROW-2
        CORD_WrapperDef.ExpressionRows row2 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row2ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns2 = new List<String> {'OR'}; 
    
        CORD_WrapperDef.Expression row2Col1 = new CORD_WrapperDef.Expression();
        row2Col1.fieldName = 'textAttrib';
        row2Col1.operator = 'eq';
        row2Col1.value = 'test';
        row2Col1.fieldType = 'STRING';
    
        CORD_WrapperDef.Expression row2Col2 = new CORD_WrapperDef.Expression();
        row2Col2.fieldName = 'SVMXC__Status__c';
        row2Col2.operator = 'is';
        row2Col2.value = 'true';
        row2Col2.fieldType = 'BOOLEAN';
    
        row2ColList.add(row2Col1);
        row2ColList.add(row2Col2);
    
        row2.expressions = row2ColList;
        row2.operatorForColumns = operatorForColumns2;
        row2.selectedProductId = product.Id;
    
        // ROW-3
        CORD_WrapperDef.ExpressionRows row3 = new CORD_WrapperDef.ExpressionRows();
    
        List<CORD_WrapperDef.Expression> row3ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns3 = new List<String> {'AND'};
    
        CORD_WrapperDef.Expression row3Col1 = new CORD_WrapperDef.Expression();
        row3Col1.fieldName = 'textAttrib';
        row3Col1.operator = 'eq';
        row3Col1.value = 'test';
        row3Col1.fieldType = 'STRING';
    
        CORD_WrapperDef.Expression row3Col2 = new CORD_WrapperDef.Expression();
        row3Col2.fieldName = 'booleanAttrib';
        row3Col2.operator = 'is';
        row3Col2.value = 'true';
        row3Col2.fieldType = 'BOOLEAN';
    
        row3ColList.add(row3Col1);
        //row3ColList.add(row3Col2);
    
        row3.expressions = row3ColList;
        row3.operatorForColumns = operatorForColumns3;
        row3.selectedProductId = product.Id;
    
        expressionRows.add(row1);
        expressionRows.add(row2);
        expressionRows.add(row3);
    
        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = operatorForRows;
        searchExpression.sequence = 1;
    
        searchExpressions.techAttribExpression = searchExpression;
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        String changeOrderId = changeOrder.Id;
        changeOrder = [SELECT Id, SVMXC__SM_Top_Level_IBs_Only__c, SVMXC__SM_Criteria_Advanced_Expression__c, (SELECT Id, SVMXC__SM_Type__c, SVMXC__SM_Criteria_Definition__c FROM SVMXC__Change_Order_Criterias__r)  FROM SVMXC__SM_Change_Order__c LIMIT 1];
        System.debug('changeOrder@@'+changeOrder);
        new CORD_ConsoleImpl().getFCOLinesPreviewBatch(changeOrder, CORD_ConsoleImpl.PREVIEW_REQUEST);
        new CORD_ConsoleImpl().getSearchExpression(changeOrder.Id);

        List<String> andOeratorForRows = new List<String> {'AND','AND'};
        searchExpression.operatorForRows = andOeratorForRows;
        searchExpressions.techAttribExpression = searchExpression;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        changeOrder = [SELECT Id, SVMXC__SM_Top_Level_IBs_Only__c, SVMXC__SM_Criteria_Advanced_Expression__c, (SELECT Id, SVMXC__SM_Type__c, SVMXC__SM_Criteria_Definition__c FROM SVMXC__Change_Order_Criterias__r)  FROM SVMXC__SM_Change_Order__c LIMIT 1];
        System.debug('changeOrder@@'+changeOrder);
        new CORD_ConsoleImpl().getFCOLinesPreviewBatch(changeOrder, CORD_ConsoleImpl.PREVIEW_REQUEST);
    }

    @isTest
    static void batchLot_test(){
        List<Product2> productList = [SELECT Id, Family, SVMXC__Product_Line__c FROM Product2 LIMIT 1];
       
        SVMXC__SM_Change_Order__c changeOrder = createChangeOrder();
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FCOSearchExpressions searchExpressions = new CORD_WrapperDef.FCOSearchExpressions();
        CORD_WrapperDef.FCOSearchExpression searchExpression = new CORD_WrapperDef.FCOSearchExpression();
    
        CORD_WrapperDef.FieldChangeOrderInfo changeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        changeOrderInfo.searchTopLevelIBOnly = true;
        request.fieldChangeOrderInfo = changeOrderInfo;
        
        List<CORD_WrapperDef.ExpressionRows> expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        List<String> operatorForRows = new List<String> {'OR'};
    
        // ROW-1
        CORD_WrapperDef.ExpressionRows row1 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row1ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns1 = new List<String> ();
    
        CORD_WrapperDef.Expression row1Col1 = new CORD_WrapperDef.Expression();
        row1Col1.fieldName = 'Name';
        row1Col1.operator = 'strtWith';
        row1Col1.value = 'Stock1';
        row1Col1.fieldType = 'STRING';
    
        row1ColList.add(row1Col1);
    
        row1.expressions = row1ColList;
        row1.operatorForColumns = operatorForColumns1;
        row1.selectedProductId = product.Id;
    
        // ROW-2
        CORD_WrapperDef.ExpressionRows row2 = new CORD_WrapperDef.ExpressionRows();
        List<CORD_WrapperDef.Expression> row2ColList = new List<CORD_WrapperDef.Expression> ();
        List<String> operatorForColumns2 = new List<String> {'AND'}; 
    
        CORD_WrapperDef.Expression row2Col1 = new CORD_WrapperDef.Expression();
        row2Col1.fieldName = CORD_ConsoleImpl.BATCH_LOT_NUMBER_PLACEHOLDER_FIELD;
        row2Col1.operator = 'lt';
        row2Col1.value = 'batch_002';
        row2Col1.fieldType = 'STRING';
    
        CORD_WrapperDef.Expression row2Col2 = new CORD_WrapperDef.Expression();
        row2Col2.fieldName = CORD_ConsoleImpl.BATCH_LOT_NUMBER_PLACEHOLDER_FIELD;
        row2Col2.operator = 'eq';
        row2Col2.value = 'batch_001';
        row2Col2.fieldType = 'STRING';
    
        row2ColList.add(row2Col1);
        row2ColList.add(row2Col2);
    
        row2.expressions = row2ColList;
        row2.operatorForColumns = operatorForColumns2;
        row2.selectedProductId = product.Id;
    
        expressionRows.add(row1);
        expressionRows.add(row2);
    
        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = operatorForRows;
        searchExpression.sequence = 1;
    
        searchExpressions.batchLotExpression = searchExpression;
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        new CORD_ConsoleImpl().createFCOLines(changeOrder.Id);
        String changeOrderId = changeOrder.Id;
        changeOrder = [SELECT Id, SVMXC__SM_Top_Level_IBs_Only__c, SVMXC__SM_Criteria_Advanced_Expression__c, (SELECT Id, SVMXC__SM_Type__c, SVMXC__SM_Criteria_Definition__c FROM SVMXC__Change_Order_Criterias__r)  FROM SVMXC__SM_Change_Order__c LIMIT 1];
        System.debug('changeOrder@@'+changeOrder);
        new CORD_ConsoleImpl().getFCOLinesPreviewBatch(changeOrder, CORD_ConsoleImpl.PREVIEW_REQUEST);

        List<String> andOeratorForRows = new List<String> {'AND'};
        searchExpression.operatorForRows = andOeratorForRows;
        searchExpressions.batchLotExpression = searchExpression;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        changeOrder = [SELECT Id, SVMXC__SM_Top_Level_IBs_Only__c, SVMXC__SM_Criteria_Advanced_Expression__c, (SELECT Id, SVMXC__SM_Type__c, SVMXC__SM_Criteria_Definition__c FROM SVMXC__Change_Order_Criterias__r)  FROM SVMXC__SM_Change_Order__c LIMIT 1];
        System.debug('changeOrder@@'+changeOrder);
        new CORD_ConsoleImpl().getFCOLinesPreviewBatch(changeOrder, CORD_ConsoleImpl.PREVIEW_REQUEST);
        new CORD_ConsoleImpl().getSearchExpression(changeOrder.Id);

        expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        expressionRows.add(row2);
        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = null;
        searchExpression.sequence = 1;
    
        searchExpressions.batchLotExpression = searchExpression;
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        new CORD_ConsoleImpl().createFCOLines(changeOrder.Id);

        expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        expressionRows.add(row1);
        searchExpression.expressionRows = expressionRows;
        searchExpression.operatorForRows = null;
        searchExpression.sequence = 1;
    
        searchExpressions.batchLotExpression = searchExpression;
        request.fcoSfId = changeOrder.Id;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        new CORD_ConsoleImpl().createFCOLines(changeOrder.Id);
        
        /*searchExpression.expressionRows = new List<CORD_WrapperDef.ExpressionRows> ();
        searchExpression.operatorForRows = new List<String> ();
        expressionRows.add(row2);
        searchExpressions.batchLotExpression = searchExpression;
        request.searchExpressions = searchExpressions;
        CORD_Console.JSRSaveSearchExpression(JSON.serialize(request));
        new CORD_ConsoleImpl().createFCOLines(changeOrder.Id);*/

    }

    @isTest
    static void JSRGetTechAttributes_Test(){
        List<Product2> productList = [SELECT Id, Family, SVMXC__Product_Line__c FROM Product2];
        PIQ_TestDataFactory.createAccountsContacts(1,1);   

        PIQ_TestDataFactory.createInstalledProducts(productList);
        PIQ_TestDataFactory.createPicklistDefinition(1);
        PIQ_TestDataFactory.createTemplateData();
        List<SVMXC__SM_Attributes_Template__c> tempAttributes = [SELECT Id, SVMXC__SM_Template_Json__c,SVMXC__SM_Picklist_Id__c,SVMXC__SM_Title__c,SVMXC__SM_Attr_Type_Template__c FROM SVMXC__SM_Attributes_Template__c LIMIT 1];
        String templateJSON = tempAttributes[0].SVMXC__SM_Template_Json__c;
        System.debug('templateJSON@@'+templateJSON);

        TechnicalAttributeConfiguration.IbInstancePayload templateJsonPayload =
                        (TechnicalAttributeConfiguration.IbInstancePayload) JSON.deserialize(templateJSON, TechnicalAttributeConfiguration.IbInstancePayload.class);
                        
       System.debug('payload@@'+templateJsonPayload);
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        List<String> productIdList = new List<String> ();

        for(Product2 product : productList){
            productIdList.add(product.Id);
        }
        request.recordIdList = productIdList;
        Test.startTest();
        CORD_Console.JSRGetTechAttributes(JSON.serialize(request));
        Test.stopTest();
    }

    
    @isTest
    static void isValidFcoRequest_Test(){
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
        fieldChangeOrderInfo.fcoName = CORD_ConsoleImpl.BLANK_STRING;
        fieldChangeOrderInfo.startDate = System.today() + 3;
        fieldChangeOrderInfo.decisionDate = System.today();
        fieldChangeOrderInfo.dueDate = System.today();
        Boolean isValidFcoRequest = true;

        Test.startTest();
        isValidFcoRequest = new CORD_ConsoleImpl().isValidFcoRequest(fieldChangeOrderInfo);
        Test.stopTest();

        fieldChangeOrderInfo.fcoName = 'dummyName';
        fieldChangeOrderInfo.startDate =  null;
        fieldChangeOrderInfo.decisionDate =  null;
        fieldChangeOrderInfo.dueDate = null;
        fieldChangeOrderInfo.fcoConfiguration = 'dummyValue';
        SVMXC__SM_Change_Order__c changeOrder = createChangeOrder();
        fieldChangeOrderInfo.fcoSfId = changeOrder.Id; 
        fieldChangeOrderInfo.requiredPartsList = NULL;
        isValidFcoRequest = new CORD_ConsoleImpl().isValidFcoRequest(fieldChangeOrderInfo);
    }

    @isTest
    static void JSRGetBatchLotFields_Test(){
        List<String> productIdList = new List<String> (); 
        for(Product2 productRecord : [SELECT Id, Family, SVMXC__Product_Line__c FROM Product2]){
            productIdList.add(productRecord.Id);
        }
        
        CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        request.recordIdList = productIdList;

        Test.startTest();
        Object response = CORD_Console.JSRgetBatchLotFields(JSON.serialize(request));
        Test.stopTest();
        System.assert(response != NULL);
    }
        
   private static CORD_WrapperDef.FieldChangeOrderInfo createFieldChangeOrderWrapper(){
    CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = new CORD_WrapperDef.FieldChangeOrderInfo();
    fieldChangeOrderInfo.fcoName = 'FCO Test Record';
    fieldChangeOrderInfo.description = 'test';
    fieldChangeOrderInfo.priority = 'Low';
    fieldChangeOrderInfo.status = 'Draft';
    fieldChangeOrderInfo.dueDate = System.today() + 2;
    fieldChangeOrderInfo.startDate = System.today();
    fieldChangeOrderInfo.decisionDate = System.today() + 2;
    fieldChangeOrderInfo.fcoType = 'Service';
    fieldChangeOrderInfo.deliveryMethod = 'Work Order';
    fieldChangeOrderInfo.searchTopLevelIBOnly = true;
    fieldChangeOrderInfo.fcosfId = '';
    fieldChangeOrderInfo.notifyFCOOwner = true;
    fieldChangeOrderInfo.fcoConfiguration = createConfiguration().Id;
    return fieldChangeOrderInfo;
}

private static SVMXC__SM_Change_Order_Configuration__c createConfiguration(){

        
    RecordType objectMappingRT = [select Id from RecordType where Name= 'Object Mapping'and SobjectType = 'SVMXC__ServiceMax_Processes__c'];

    SVMXC__ServiceMax_Processes__c objectMappingProcess = new SVMXC__ServiceMax_Processes__c(SVMXC__Name__c='ProcessObjectMapping',SVMXC__Target_Object_Name__c='SVMXC__Service_Order__c',SVMXC__Source_Object_Name__c='SVMXC__SM_Change_Order__c',SVMXC__MapID__c='MAP001002A',RecordTypeId = objectMappingRT.Id, SVMXC__Active__c = true, SVMXC__Mode_Of_Execution__c = 'Interactive', SVMXC__SM_Include_Object_Data_Set__c =  true);
    insert objectMappingProcess;

    RecordType fieldMappingRT = [select Id from RecordType where Name='Field Mapping'and SobjectType='SVMXC__ServiceMax_Config_Data__c' Limit 1];

    //SVMXC__ServiceMax_Config_Data__c fieldMapping1 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Target_Field_Name__c='SVMXC__Order_Type__c',SVMXC__Source_Field_Name__c='SVMXC__State__c',SVMXC__Active__c = true, SVMXC__MapID__c=objectMappingProcess.Id,RecordTypeId = fieldMappingRT.Id, SVMXC__Action_Type__c = 'Set Value', SVMXC__Parameter_Type__c = 'Value', SVMXC__Configuration_Type__c='Field Mapping
    //',SVMXC__Display_Type__c='PICKLIST');

    SVMXC__ServiceMax_Config_Data__c fieldMapping1 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Target_Field_Name__c='SVMXC__Order_Type__c',SVMXC__Active__c = true, SVMXC__MapID__c=objectMappingProcess.Id,RecordTypeId = fieldMappingRT.Id, SVMXC__Action_Type__c = 'Set Value', SVMXC__Parameter_Type__c = 'Value', SVMXC__Configuration_Type__c='Field Mapping', SVMXC__Display_Value__c='Field Service', SVMXC__Display_Type__c='PICKLIST');
    SVMXC__ServiceMax_Config_Data__c fieldMapping2 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Target_Field_Name__c='SVMXC__Site__c',SVMXC__Active__c = true, SVMXC__MapID__c=objectMappingProcess.Id,RecordTypeId = fieldMappingRT.Id, SVMXC__Action_Type__c = 'Set Value', SVMXC__Parameter_Type__c = 'Value', SVMXC__Configuration_Type__c='Field Mapping', SVMXC__Display_Value__c='', SVMXC__Display_Type__c='REFERENCE');
    SVMXC__ServiceMax_Config_Data__c fieldMapping3 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Target_Field_Name__c='SVMXC__Product__c',SVMXC__Active__c = true, SVMXC__MapID__c=objectMappingProcess.Id,RecordTypeId = fieldMappingRT.Id, SVMXC__Action_Type__c = 'Set Value', SVMXC__Parameter_Type__c = 'Value', SVMXC__Configuration_Type__c='Field Mapping', SVMXC__Display_Value__c='', SVMXC__Display_Type__c='REFERENCE');
    SVMXC__ServiceMax_Config_Data__c fieldMapping4 = new SVMXC__ServiceMax_Config_Data__c(SVMXC__Target_Field_Name__c='SVMXC__Component__c',SVMXC__Active__c = true, SVMXC__MapID__c=objectMappingProcess.Id,RecordTypeId = fieldMappingRT.Id, SVMXC__Action_Type__c = 'Set Value', SVMXC__Parameter_Type__c = 'Value', SVMXC__Configuration_Type__c='Field Mapping', SVMXC__Display_Value__c='', SVMXC__Display_Type__c='REFERENCE');

    List<SVMXC__ServiceMax_Config_Data__c> conflist= new List<SVMXC__ServiceMax_Config_Data__c>();
    conflist.add(fieldMapping1);
    conflist.add(fieldMapping2);
    conflist.add(fieldMapping3);
    conflist.add(fieldMapping4);

    insert conflist;

    SVMXC__SM_Change_Order_Configuration__c config = new SVMXC__SM_Change_Order_Configuration__c(SVMXC__SM_Email__c='test@gmail.com',
                                                                                                        SVMXC__SM_Name__c ='test',
                                                                                                        SVMXC__SM_Description__c='test');
    config.SVMXC__SM_Process2__c = objectMappingProcess.Id;
    insert config;
    return config;
}

private static CORD_WrapperDef.RequiredParts createRequiredPartsWrapper(){
    CORD_WrapperDef.RequiredParts requiredPartsWrapper = new CORD_WrapperDef.RequiredParts();
    List<Product2> productList = [SELECT Id, Name FROM Product2 LIMIT 1];
    requiredPartsWrapper.productId = productList[0].Id;
    requiredPartsWrapper.quantity = 4;
    requiredPartsWrapper.Name = productList[0].Name;
    requiredPartsWrapper.sfId = '';
    return requiredPartsWrapper;
}

@isTest
static void getFCOLines_Test(){
    createChangeOrder();
    SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
    System.assert(new CORD_ConsoleImpl().getFCOLines(changeOrder.Id) != NULL);
}

@isTest
static void getFCOLineCount_Test(){
    createChangeOrder();
    SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
    System.assert(new CORD_ConsoleImpl().getFCOLineCount(changeOrder.Id) != NULL);
}

@isTest
static void getFCOLinesWithWO_Test(){
    createChangeOrder();
    SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
    System.assert(new CORD_ConsoleImpl().getFCOLinesWithWO(changeOrder.Id, '') != NULL);
}

@isTest
static void getWorkOrderList_Test(){
    createChangeOrder();
    SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
    List<SVMXC__SM_Change_Order_Line__c> lines = [SELECT Id, SVMXC__SM_Work_Order__c FROM SVMXC__SM_Change_Order_Line__c WHERE SVMXC__SM_Change_Order__c =: changeOrder.Id];
    System.assert(new CORD_ConsoleImpl().getWorkOrderList(lines) != NULL);
}

@isTest
static void updateFCOLines_Test(){
    createChangeOrder();
    SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
    List<SVMXC__SM_Change_Order_Line__c> lines = [SELECT Id, SVMXC__SM_Work_Order__c FROM SVMXC__SM_Change_Order_Line__c WHERE SVMXC__SM_Change_Order__c =: changeOrder.Id];
    System.assert(new CORD_ConsoleImpl().updateFCOLines(lines, lines, changeOrder.Id) != NULL);
}

@isTest
static void coverStaticVariables_Test(){
    String BLANK_STRING = CORD_ConsoleImpl.BLANK_STRING;
    String SPACE = CORD_ConsoleImpl.SPACE;
    String CHANGE_ORDER_OBJECT = CORD_ConsoleImpl.CHANGE_ORDER_OBJECT;
    String FCO_LINE_OBJECT = CORD_ConsoleImpl.FCO_LINE_OBJECT;
    String WORK_ORDER_OBJECT = CORD_ConsoleImpl.WORK_ORDER_OBJECT; 
    String INSTALLED_PRODUCT_SEARCH_TYPE = CORD_ConsoleImpl.INSTALLED_PRODUCT_SEARCH_TYPE;
    String TECH_ATTRIB_SEARCH_TYPE = CORD_ConsoleImpl.TECH_ATTRIB_SEARCH_TYPE;
    String BATCH_LOT_SEARCH_TYPE = CORD_ConsoleImpl.BATCH_LOT_SEARCH_TYPE;
    String INSTALLED_PRODUCT_OBJECT = CORD_ConsoleImpl.INSTALLED_PRODUCT_OBJECT;
    String BATCH_LOT_MASTER_OBJECT = CORD_ConsoleImpl.BATCH_LOT_MASTER_OBJECT;
    String STOCKED_SERIAL_OBJECT = CORD_ConsoleImpl.STOCKED_SERIAL_OBJECT;
    String SITE_OBJECT = CORD_ConsoleImpl.SITE_OBJECT;
    String errorMessage = CORD_ConsoleImpl.errorMessage;
    String CHANGE_ORDER_ACCESS_RT = CORD_ConsoleImpl.CHANGE_ORDER_ACCESS_RT;
    String BATCH_STATUS_OPEN = CORD_ConsoleImpl.BATCH_STATUS_OPEN;
    String LOG_TYPE_FCO_GENERATION = CORD_ConsoleImpl.LOG_TYPE_FCO_GENERATION;
    String LOG_TYPE_WO_GENERATION = CORD_ConsoleImpl.LOG_TYPE_WO_GENERATION;
    String FCO_STATUS_DRAFT = CORD_ConsoleImpl.FCO_STATUS_DRAFT;
    String FCO_STATUS_IN_PROGRESS = CORD_ConsoleImpl.FCO_STATUS_IN_PROGRESS;
    String FCO_STATUS_COMPLETED = CORD_ConsoleImpl.FCO_STATUS_COMPLETED;
    String LOG_TYPE_CANCELED = CORD_ConsoleImpl.LOG_TYPE_CANCELED;
    String BATCH_NOT_STARTED = CORD_ConsoleImpl.BATCH_NOT_STARTED;
    String BATCH_IN_PROGRESS = CORD_ConsoleImpl.BATCH_IN_PROGRESS;
    String BATCH_QUEUED = CORD_ConsoleImpl.BATCH_QUEUED;
    String BATCH_STATUS_IN_PROGRESS= CORD_ConsoleImpl.BATCH_STATUS_IN_PROGRESS;
    String USER_PREF_TYPE_FCO = CORD_ConsoleImpl.USER_PREF_TYPE_FCO;
    String DETAILS_TAB = CORD_ConsoleImpl.DETAILS_TAB;
    String SEARCH_RESULTS_TAB = CORD_ConsoleImpl.SEARCH_RESULTS_TAB;
    String WORK_ORDER_TAB = CORD_ConsoleImpl.WORK_ORDER_TAB;
    String FCO_LINE_STATUS_WO_GEN = CORD_ConsoleImpl.FCO_LINE_STATUS_WO_GEN;
    String FCO_LINE_STATUS_CONFIRMED = CORD_ConsoleImpl.FCO_LINE_STATUS_CONFIRMED;
    String FCO_LINE_STATUS_DRAFT = CORD_ConsoleImpl.FCO_LINE_STATUS_DRAFT;
    //Integer totalExpectedFCOLineCount = CORD_ConsoleImpl.totalExpectedFCOLineCount;
    String PREVIEW_REQUEST = CORD_ConsoleImpl.PREVIEW_REQUEST;
    String FCO_LINE_BATCH_REQUEST = CORD_ConsoleImpl.FCO_LINE_BATCH_REQUEST;
    String BATCH_LOT_REQUEST = CORD_ConsoleImpl.BATCH_LOT_REQUEST;
    String IB_REQUEST = CORD_ConsoleImpl.IB_REQUEST;
}

@isTest
static void getLogDetails_Test(){
    createChangeOrder();
    SVMXC__SM_Change_Order__c changeOrder = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
    CORD_WorkOrderBatch batch = new CORD_WorkOrderBatch(changeOrder.Id, '', '');
    Map<String, String> batchMap = new Map<String, String> ();
    batchMap.put('test','test');
    Map<Integer, Map<String, String>> failedRecordsWithBatchNoMap = new Map<Integer, Map<String, String>> ();
    failedRecordsWithBatchNoMap.put(1, batchMap);

    Map<Integer, Integer> recordCountInBatchMap = new Map<Integer, Integer> ();
    recordCountInBatchMap.put(1, 1);
    String output = batch.getLogDetails(failedRecordsWithBatchNoMap, recordCountInBatchMap);
    System.assert(output !=  NULL);
    //getLogDetails(Map<Integer, Map<String, String>> failedRecordsWithBatchNoMap, Map<Integer, List<String>> allRecordsInFailedBatchMap){
}


private static SVMXC__SM_Change_Order__c createChangeOrder(){
    CORD_WrapperDef.FCO_Request request = new CORD_WrapperDef.FCO_Request();
        CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = createFieldChangeOrderWrapper();
        List<CORD_WrapperDef.RequiredParts> requiredPartsWrapperList = new List<CORD_WrapperDef.RequiredParts> ();
        CORD_WrapperDef.RequiredParts requiredPartsWrapper = createRequiredPartsWrapper();
        requiredPartsWrapperList.add(requiredPartsWrapper);
        fieldChangeOrderInfo.requiredPartsList = requiredPartsWrapperList;
        request.fieldChangeOrderInfo = fieldChangeOrderInfo;
        String requestString = JSON.serialize(request);
        CORD_Console.JSRSaveFieldChangeOrder(requestString);
        List<SVMXC__SM_Change_Order__c> changeOrderList = [SELECT Id FROM SVMXC__SM_Change_Order__c LIMIT 1];
        if(!changeOrderList.isEmpty()){
            insertIbLine(changeOrderList[0].Id);
            insertStockSerialLine(changeOrderList[0].Id);
            insertBatchLotLine(changeOrderList[0].Id);

            //SVMXC__SM_Change_Order_Line__c coLineWithIB = 

           // List<SVMXC__SM_Change_Order_Line__c> changeOrderLines = new List<SVMXC__SM_Change_Order_Line__c> {ibLine, stockSerialLine, batchLotLine};
        }
        return !changeOrderList.isEmpty() ? changeOrderList[0] : NULL;
}

    private static void insertIbLine(String fcoSfId){
        List<SVMXC__Installed_Product__c> ibList = [SELECT Id FROM SVMXC__Installed_Product__c LIMIT 1];
        SVMXC__SM_Change_Order_Line__c fcoLineWithIb = new SVMXC__SM_Change_Order_Line__c(SVMXC__SM_Line_Status__c = 'Draft', SVMXC__SM_Change_Order__c = fcoSfId, SVMXC__SM_Generate_WORD__c = true);
        if(!ibList.isEmpty()){
            fcoLineWithIb.SVMXC__SM_Installed_Product__c = ibList[0].id;
        }
        insert fcoLineWithIb;
    }

    private static void insertStockSerialLine(String fcoSfId){
        List<SVMXC__Product_Serial__c> stockSerialList = [SELECT Id FROM SVMXC__Product_Serial__c LIMIT 1];
        SVMXC__SM_Change_Order_Line__c fcoLineWithStockedSerial = new SVMXC__SM_Change_Order_Line__c(SVMXC__SM_Line_Status__c = 'Draft', SVMXC__SM_Change_Order__c = fcoSfId, SVMXC__SM_Generate_WORD__c = true);
        if(!stockSerialList.isEmpty()){
            fcoLineWithStockedSerial.SVMXC__SM_Stocked_Serial__c = stockSerialList[0].id;
        }
        insert fcoLineWithStockedSerial;
        System.debug('fcoLineWithStockedSerial@@'+fcoLineWithStockedSerial.Id);
    }

    private static void insertBatchLotLine(String fcoSfId){
        List<SVMXC__SM_Batch_Lot__c> batchLotList = [SELECT Id FROM SVMXC__SM_Batch_Lot__c LIMIT 1];
        SVMXC__SM_Change_Order_Line__c fcoLineWithBatch = new SVMXC__SM_Change_Order_Line__c(SVMXC__SM_Line_Status__c = 'Draft', SVMXC__SM_Change_Order__c = fcoSfId, SVMXC__SM_Generate_WORD__c = true);
        if(!batchLotList.isEmpty()){
            fcoLineWithBatch.SVMXC__SM_Batch_Lot2__c = batchLotList[0].id;
        }
        insert fcoLineWithBatch;
        System.debug('fcoLineWithBatch@@'+fcoLineWithBatch.Id);

    }

}