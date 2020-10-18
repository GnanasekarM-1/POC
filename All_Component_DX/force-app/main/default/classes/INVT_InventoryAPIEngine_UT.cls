@isTest(SeeAllData = true)
Private class INVT_InventoryAPIEngine_UT
{
    private static final String STRING_RMA            = 'RMA';
    private static final String STRING_GLOBAL          = 'Global';
    private static final String STRING_SUBMODULE        = 'Submodule';
    private static final String STRING_SETTINGS          = 'Settings';
    private static final String STRING_SHIPMENT          = 'Shipment';
    private static final String STRING_SETTING_VALUE      = 'Setting Value';
    private static final String STRING_INVENTORY_PROCESS    = 'Inventory Process';
    private static final String STRING_CONFIGURATION_PROFILE  = 'Configuration Profile';
    private static final String STRING_USAGE_CONSUMPTION    = 'Usage/Consumption';
  
    static testMethod void INVT_InventoryAPIEngineTest1_UT()
    {
    
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c(      
            SVMXC__Order_Status__c = 'open' );
        
        insert workOrder; 
        

             SVMXC__Service_Order_Line__c workDetail = new SVMXC__Service_Order_Line__c(
                SVMXC__Service_Order__c = workOrder.Id,
                SVMXC__Actual_Quantity2__c = 2,
                SVMXC__Serial_Number_List__c = 'SerailNo1,SerailNo2',
                SVMXC__Posted_To_Inventory__c = false
        ); 
        insert workDetail; 
        
        
        INVT_WrapperDef.INVT_Request objReq = new INVT_WrapperDef.INVT_Request();
        List<INVT_WrapperDef.INVT_StringMap> stringMapLst = new List<INVT_WrapperDef.INVT_StringMap>();

        // creating req 
        INVT_WrapperDef.INVT_StringMap stingVal = new INVT_WrapperDef.INVT_StringMap();
        stingVal.key = 'SVMX_HearderId';
        stingVal.value = workOrder.Id;
        stringMapLst.add(stingVal);
        
        INVT_WrapperDef.INVT_StringMap stingVal2 = new INVT_WrapperDef.INVT_StringMap();
        stingVal2.key = 'SVMX_InventoryProcessId';
        stingVal2.value = 'WORD010';
        stringMapLst.add(stingVal2);
        
        INVT_WrapperDef.INVT_StringMap stingVal3 = new INVT_WrapperDef.INVT_StringMap();
        stingVal3.key = 'SVMX_AllowWarning';
        stingVal3.value = 'false';
        stringMapLst.add(stingVal3);
        
        List<INVT_WrapperDef.INVT_StringListMap> objListValue = new List<INVT_WrapperDef.INVT_StringListMap>();
        INVT_WrapperDef.INVT_StringListMap objvaluteList = new INVT_WrapperDef.INVT_StringListMap();
        objvaluteList.key = 'SVMX_LineIds';
        List<String> lstString = new List<String>();
        lstString.add(workDetail.Id);
        objvaluteList.valueList = lstString;
        objListValue.add(objvaluteList);
        objReq.listOfStringlistMap = objListValue;
        
        
        
        objReq.listOfStringMap =  stringMapLst;
        INVT_InventoryAPIEngine  objInventoryAPIEngine = new INVT_InventoryAPIEngine();
        System.debug('response for all: '+objInventoryAPIEngine.processINVTRequest(objReq));
        
        objInventoryAPIEngine.getProduct2Map();
        objInventoryAPIEngine.getSerializedProduct2Map();
        objInventoryAPIEngine.getINVTTransactionRecordList();
        objInventoryAPIEngine.setLineRecordQueryString('test');
        objInventoryAPIEngine.setHeaderRecord(new Account());
        objInventoryAPIEngine.getToLocationMap();
        objInventoryAPIEngine.getFromLocationMap();
        objInventoryAPIEngine.getProduct2List();
        objInventoryAPIEngine.setLineRecordList(new List<sObject>());
        objInventoryAPIEngine.setInvtTransactionRecordList(new List<INVT_TransactionRecord>());
        objInventoryAPIEngine.getObjInventoryProcess();
        objInventoryAPIEngine.setInventoryEnabled(true);
        objInventoryAPIEngine.setLocationInvolved(true);
        objInventoryAPIEngine.getRecordTypeMap();
        
        INVT_WrapperDef.INVT_Request objReq1 = new INVT_WrapperDef.INVT_Request();
        System.debug('response for all: '+objInventoryAPIEngine.processINVTRequest(objReq1)); 
        
        
        INVT_WrapperDef.INVT_Request objReq2 = new INVT_WrapperDef.INVT_Request();
        List<INVT_WrapperDef.INVT_StringMap> stringMapLst1 = new List<INVT_WrapperDef.INVT_StringMap>();

        // creating req 
        INVT_WrapperDef.INVT_StringMap stingVal4 = new INVT_WrapperDef.INVT_StringMap();
        stingVal4.key = 'SVMX_HearderId';
        stingVal4.value = null;
        stringMapLst1.add(stingVal4);
        objReq2.listOfStringMap =  stringMapLst1;
        System.debug('response for all: '+objInventoryAPIEngine.processINVTRequest(objReq2)); 
        
    }
    
    static testMethod void INVT_InventoryAPIEngineTest2_UT() 
    {
    
        // Getting record types    
        List<RecordType> recordTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE sobjectType IN ('SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c','SVMXC__Service_Order_Line__c')];

        String strSubmoduleRecordTypeId, strSettingRecordTypeId, strInventoryProcessRecordTypeId, strSettingValueRecordTypeId, strConfigProfileRecordTypeId, strWrokDetailRecordTypeId;
            
        for( RecordType recordTypeSObject : recordTypeList ) {

            if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SUBMODULE ) ) {
                strSubmoduleRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_INVENTORY_PROCESS ) ) {
                strInventoryProcessRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTINGS ) ) {
                strSettingRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTING_VALUE ) ) {
                strSettingValueRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_CONFIGURATION_PROFILE ) ) {
                strConfigProfileRecordTypeId = recordTypeSObject.id;
            }else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_USAGE_CONSUMPTION ) ) {
                strWrokDetailRecordTypeId = recordTypeSObject.id;
            }
        }

        
        
        // Create Account
            Account account = new Account( Name = 'Account',
            ShippingStreet = 'ABC',
            ShippingCity = 'PQR',
            ShippingState = 'XYZ',
            ShippingPostalCode = '111',
            ShippingCountry = 'XYZ',
            BillingStreet = 'ABC',
            BillingCity = 'PQR',
            BillingState = 'XYZ',
            BillingPostalCode = '111',
            BillingCountry = 'XYZ'); 
            insert account;
            // Create Contact
            Contact contact = new Contact( LastName='Last',
                AccountId = account.Id,
                Email = 'svmxmailfortest@servicemax.com');
            insert contact;
            
            // Create locations       
        
            SVMXC__Site__c location1 = new SVMXC__Site__c( Name = 'MG Road',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            insert location1;
             
            SVMXC__Site__c location2 = new SVMXC__Site__c( Name = 'Trinity',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            
            insert location2;
            
            // Creating product2
            Product2 product2 = new Product2( Name = 'prodPR1',
                ProductCode='prodPR1',
                SVMXC__Inherit_Parent_Warranty__c = True,
                SVMXC__Enable_Serialized_Tracking__c = True,
                SVMXC__Stockable__c = True );
            insert product2;
                            
        //  Create workorder
            SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c( 
                SVMXC__Company__c = account.Id,
                SVMXC__Contact__c = contact.Id,        
                SVMXC__Order_Status__c = 'Open' );
            
            insert workOrder;
           
            // Creating work details
                SVMXC__Service_Order_Line__c workDetail = new SVMXC__Service_Order_Line__c(
                    SVMXC__Service_Order__c = workOrder.Id,
                    SVMXC__Consumed_From_Location__c = location1.id,
                    RecordTypeId = strWrokDetailRecordTypeId,
                    SVMXC__Actual_Quantity2__c = 2,
                    SVMXC__Product__c = product2.id,
                    SVMXC__Serial_Number_List__c = 'SerailNo1,SerailNo2',
                    SVMXC__Posted_To_Inventory__c = False,
                    SVMXC__Line_Type__c = 'Parts'
            ); 
            insert workDetail;
            
            INVT_WrapperDef.INVT_Request objReq = new INVT_WrapperDef.INVT_Request();
        List<INVT_WrapperDef.INVT_StringMap> stringMapLst = new List<INVT_WrapperDef.INVT_StringMap>();

    
        INVT_WrapperDef.INVT_StringMap stingVal = new INVT_WrapperDef.INVT_StringMap();
        stingVal.key = 'SVMX_HearderId';
        stingVal.value = workOrder.Id;
        stringMapLst.add(stingVal);
        
        INVT_WrapperDef.INVT_StringMap stingVal2 = new INVT_WrapperDef.INVT_StringMap();
        stingVal2.key = 'SVMX_InventoryProcessId';
        stingVal2.value = 'WORD010';
        stringMapLst.add(stingVal2);
        
        INVT_WrapperDef.INVT_StringMap stingVal3 = new INVT_WrapperDef.INVT_StringMap();
        stingVal3.key = 'SVMX_AllowWarning';
        stingVal3.value = 'true';
        stringMapLst.add(stingVal3);
        
        objReq.listOfStringMap =  stringMapLst;
        INVT_InventoryAPIEngine objInventoryAPIEngine = new INVT_InventoryAPIEngine();
        objInventoryAPIEngine.setLineRecordQueryString('test');
        objInventoryAPIEngine.setHeaderRecord(new Account());
        objInventoryAPIEngine.setLineRecordList(new List<sObject>());
        objInventoryAPIEngine.setInvtTransactionRecordList(new List<INVT_TransactionRecord>());
        objInventoryAPIEngine.setInventoryEnabled(true);
        objInventoryAPIEngine.setLocationInvolved(true);
        System.debug('response for all: '+objInventoryAPIEngine.processINVTRequest(objReq));
        
  }
  static testMethod void INVT_InventoryAPIEngineTest3_UT() 
    {
    
        // Getting record types    
        List<RecordType> recordTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE sobjectType IN ('SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c','SVMXC__Service_Order_Line__c')];

        String strSubmoduleRecordTypeId, strSettingRecordTypeId, strInventoryProcessRecordTypeId, strSettingValueRecordTypeId, strConfigProfileRecordTypeId, strWrokDetailRecordTypeId;
            
        for( RecordType recordTypeSObject : recordTypeList ) {

            if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SUBMODULE ) ) {
                strSubmoduleRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_INVENTORY_PROCESS ) ) {
                strInventoryProcessRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTINGS ) ) {
                strSettingRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTING_VALUE ) ) {
                strSettingValueRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_CONFIGURATION_PROFILE ) ) {
                strConfigProfileRecordTypeId = recordTypeSObject.id;
            }else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_USAGE_CONSUMPTION ) ) {
                strWrokDetailRecordTypeId = recordTypeSObject.id;
            }
        }

        
        
        // Create Account
            Account account = new Account( Name = 'Account',
            ShippingStreet = 'ABC',
            ShippingCity = 'PQR',
            ShippingState = 'XYZ',
            ShippingPostalCode = '111',
            ShippingCountry = 'XYZ',
            BillingStreet = 'ABC',
            BillingCity = 'PQR',
            BillingState = 'XYZ',
            BillingPostalCode = '111',
            BillingCountry = 'XYZ'); 
            insert account;
            // Create Contact
            Contact contact = new Contact( LastName='Last',
                AccountId = account.Id,
                Email = 'svmxmailfortest@servicemax.com');
            insert contact;
            
            // Create locations       
        
            SVMXC__Site__c location1 = new SVMXC__Site__c( Name = 'MG Road',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            insert location1;
             
            SVMXC__Site__c location2 = new SVMXC__Site__c( Name = 'Trinity',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            
            insert location2;
            
            // Creating product2
            Product2 product2 = new Product2( Name = 'prodPR1',
                ProductCode='prodPR1',
                SVMXC__Inherit_Parent_Warranty__c = True,
                SVMXC__Enable_Serialized_Tracking__c = True,
                SVMXC__Stockable__c = True );
            insert product2;
                            
        //  Create workorder
            SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c( 
                SVMXC__Company__c = account.Id,
                SVMXC__Contact__c = contact.Id,        
                SVMXC__Order_Status__c = 'Open' );
            
            insert workOrder;
           
            // Creating work details
                SVMXC__Service_Order_Line__c workDetail = new SVMXC__Service_Order_Line__c(
                    SVMXC__Service_Order__c = workOrder.Id,
                    SVMXC__Consumed_From_Location__c = location1.id,
                    RecordTypeId = strWrokDetailRecordTypeId,
                    SVMXC__Actual_Quantity2__c = 2,
                    SVMXC__Product__c = product2.id,
                    SVMXC__Serial_Number_List__c = 'SerailNo1,SerailNo2',
                    SVMXC__Posted_To_Inventory__c = False,
                    SVMXC__Line_Type__c = 'Parts'
            ); 
            insert workDetail;
            
            INVT_WrapperDef.INVT_Request objReq = new INVT_WrapperDef.INVT_Request();
        List<INVT_WrapperDef.INVT_StringMap> stringMapLst = new List<INVT_WrapperDef.INVT_StringMap>();

    
        INVT_WrapperDef.INVT_StringMap stingVal = new INVT_WrapperDef.INVT_StringMap();
        stingVal.key = 'SVMX_HearderId';
        stingVal.value = workOrder.Id;
        stringMapLst.add(stingVal);
        
        INVT_WrapperDef.INVT_StringMap stingVal2 = new INVT_WrapperDef.INVT_StringMap();
        stingVal2.key = 'SVMX_InventoryProcessId';
        stingVal2.value = 'WORD010';
        stringMapLst.add(stingVal2);
        
        INVT_WrapperDef.INVT_StringMap stingVal3 = new INVT_WrapperDef.INVT_StringMap();
        stingVal3.key = 'SVMX_AllowWarning';
        stingVal3.value = 'false';
        stringMapLst.add(stingVal3);
        
        objReq.listOfStringMap =  stringMapLst;
        INVT_InventoryAPIEngine objInventoryAPIEngine = new INVT_InventoryAPIEngine();
        objInventoryAPIEngine.setInvtTransactionRecordList(new List<INVT_TransactionRecord>());
        System.debug('response for all: '+objInventoryAPIEngine.processINVTRequest(objReq));
        
  }
  
    static testMethod void INVT_InventoryAPIEngineTest4_UT() 
    {
    
        // Getting record types    
        List<RecordType> recordTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE sobjectType IN ('SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c','SVMXC__Service_Order_Line__c')];

        String strSubmoduleRecordTypeId, strSettingRecordTypeId, strInventoryProcessRecordTypeId, strSettingValueRecordTypeId, strConfigProfileRecordTypeId, strWrokDetailRecordTypeId;
            
        for( RecordType recordTypeSObject : recordTypeList ) {

            if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SUBMODULE ) ) {
                strSubmoduleRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_INVENTORY_PROCESS ) ) {
                strInventoryProcessRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTINGS ) ) {
                strSettingRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTING_VALUE ) ) {
                strSettingValueRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_CONFIGURATION_PROFILE ) ) {
                strConfigProfileRecordTypeId = recordTypeSObject.id;
            }else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_USAGE_CONSUMPTION ) ) {
                strWrokDetailRecordTypeId = recordTypeSObject.id;
            }
        }

        
        
        // Create Account
            Account account = new Account( Name = 'Account',
            ShippingStreet = 'ABC',
            ShippingCity = 'PQR',
            ShippingState = 'XYZ',
            ShippingPostalCode = '111',
            ShippingCountry = 'XYZ',
            BillingStreet = 'ABC',
            BillingCity = 'PQR',
            BillingState = 'XYZ',
            BillingPostalCode = '111',
            BillingCountry = 'XYZ'); 
            insert account;
            // Create Contact
            Contact contact = new Contact( LastName='Last',
                AccountId = account.Id,
                Email = 'svmxmailfortest@servicemax.com');
            insert contact;
            
            // Create locations       
        
            SVMXC__Site__c location1 = new SVMXC__Site__c( Name = 'MG Road',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            insert location1;
             
            SVMXC__Site__c location2 = new SVMXC__Site__c( Name = 'Trinity',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            
            insert location2;
            
            // Creating product2
            Product2 product2 = new Product2( Name = 'prodPR1',
                ProductCode='prodPR1',
                SVMXC__Inherit_Parent_Warranty__c = True,
                SVMXC__Enable_Serialized_Tracking__c = True,
                SVMXC__Stockable__c = True );
            insert product2;
                            
        //  Create workorder
            SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c( 
                SVMXC__Company__c = account.Id,
                SVMXC__Contact__c = contact.Id,        
                SVMXC__Order_Status__c = 'Open' );
            
            insert workOrder;
           
            // Creating work details
                SVMXC__Service_Order_Line__c workDetail = new SVMXC__Service_Order_Line__c(
                    SVMXC__Service_Order__c = workOrder.Id,
                    SVMXC__Consumed_From_Location__c = location1.id,
                    RecordTypeId = strWrokDetailRecordTypeId,
                    SVMXC__Actual_Quantity2__c = 2,
                    SVMXC__Product__c = product2.id,
                    SVMXC__Serial_Number_List__c = 'SerailNo1,SerailNo2',
                    SVMXC__Posted_To_Inventory__c = False,
                    SVMXC__Line_Type__c = 'Parts'
            ); 
            insert workDetail;
            
            SVMXC__Product_Stock__c proStock1 = new SVMXC__Product_Stock__c();
        proStock1.SVMXC__Status__c = 'Available';
        proStock1.SVMXC__Product__c = product2.id;
        proStock1.SVMXC__Location__c = location1.Id;
                
        
        List<SVMXC__Product_Stock__c> productStockList = new List<SVMXC__Product_Stock__c>();
        productStockList.add(proStock1);
        
        insert productStockList;
        
        // create serial
        SVMXC__Product_Serial__c proSerial = new SVMXC__Product_Serial__c();
        proSerial.SVMXC__Product__c = product2.id;
        proSerial.SVMXC__Product_Stock__c = proStock1.id;
        proSerial.SVMXC__Active__c = true;
        proSerial.Name = 'Serial1';
        
        insert proSerial;
            
            INVT_WrapperDef.INVT_Request objReq = new INVT_WrapperDef.INVT_Request();
        List<INVT_WrapperDef.INVT_StringMap> stringMapLst = new List<INVT_WrapperDef.INVT_StringMap>();

    
        INVT_WrapperDef.INVT_StringMap stingVal = new INVT_WrapperDef.INVT_StringMap();
        stingVal.key = 'SVMX_HearderId';
        stingVal.value = workOrder.Id;
        stringMapLst.add(stingVal);
        
        INVT_WrapperDef.INVT_StringMap stingVal2 = new INVT_WrapperDef.INVT_StringMap();
        stingVal2.key = 'SVMX_InventoryProcessId';
        stingVal2.value = 'WORD010';
        stringMapLst.add(stingVal2);
        
        INVT_WrapperDef.INVT_StringMap stingVal3 = new INVT_WrapperDef.INVT_StringMap();
        stingVal3.key = 'SVMX_AllowWarning';
        stingVal3.value = 'true';
        stringMapLst.add(stingVal3);
        
        objReq.listOfStringMap =  stringMapLst;
        INVT_InventoryAPIEngine objInventoryAPIEngine = new INVT_InventoryAPIEngine();
        objInventoryAPIEngine.setInvtTransactionRecordList(new List<INVT_TransactionRecord>());
        System.debug('response for all: '+objInventoryAPIEngine.processINVTRequest(objReq));
        
  }
  static testMethod void INVT_InventoryAPIEngineTest5_UT() 
    {
    
        // Getting record types    
        List<RecordType> recordTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE sobjectType IN ('SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c','SVMXC__Service_Order_Line__c')];

        String strSubmoduleRecordTypeId, strSettingRecordTypeId, strInventoryProcessRecordTypeId, strSettingValueRecordTypeId, strConfigProfileRecordTypeId, strWrokDetailRecordTypeId;
            
        for( RecordType recordTypeSObject : recordTypeList ) {

            if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SUBMODULE ) ) {
                strSubmoduleRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_INVENTORY_PROCESS ) ) {
                strInventoryProcessRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTINGS ) ) {
                strSettingRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTING_VALUE ) ) {
                strSettingValueRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_CONFIGURATION_PROFILE ) ) {
                strConfigProfileRecordTypeId = recordTypeSObject.id;
            }else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_USAGE_CONSUMPTION ) ) {
                strWrokDetailRecordTypeId = recordTypeSObject.id;
            }
        }

        
        
        // Create Account
            Account account = new Account( Name = 'Account',
            ShippingStreet = 'ABC',
            ShippingCity = 'PQR',
            ShippingState = 'XYZ',
            ShippingPostalCode = '111',
            ShippingCountry = 'XYZ',
            BillingStreet = 'ABC',
            BillingCity = 'PQR',
            BillingState = 'XYZ',
            BillingPostalCode = '111',
            BillingCountry = 'XYZ'); 
            insert account;
            // Create Contact
            Contact contact = new Contact( LastName='Last',
                AccountId = account.Id,
                Email = 'svmxmailfortest@servicemax.com');
            insert contact;
            
            // Create locations       
        
            SVMXC__Site__c location1 = new SVMXC__Site__c( Name = 'MG Road',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            insert location1;
             
            SVMXC__Site__c location2 = new SVMXC__Site__c( Name = 'Trinity',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            
            insert location2;
            
            // Creating product2
            Product2 product2 = new Product2( Name = 'prodPR1',
                ProductCode='prodPR1',
                SVMXC__Inherit_Parent_Warranty__c = True,
                SVMXC__Enable_Serialized_Tracking__c = True,
                SVMXC__Stockable__c = True );
            insert product2;
                            
        //  Create workorder
            SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c( 
                SVMXC__Company__c = account.Id,
                SVMXC__Contact__c = contact.Id,        
                SVMXC__Order_Status__c = 'Open' );
            
            insert workOrder;
           
            // Creating work details
                SVMXC__Service_Order_Line__c workDetail = new SVMXC__Service_Order_Line__c(
                    SVMXC__Service_Order__c = workOrder.Id,
                    SVMXC__Consumed_From_Location__c = location1.id,
                    RecordTypeId = strWrokDetailRecordTypeId,
                    SVMXC__Actual_Quantity2__c = 2,
                    SVMXC__Product__c = product2.id,
                    SVMXC__Serial_Number_List__c = 'SerailNo1,SerailNo2',
                    SVMXC__Posted_To_Inventory__c = False,
                    SVMXC__Line_Type__c = 'Parts'
            ); 
            insert workDetail;
            
            INVT_WrapperDef.INVT_Request objReq = new INVT_WrapperDef.INVT_Request();
        List<INVT_WrapperDef.INVT_StringMap> stringMapLst = new List<INVT_WrapperDef.INVT_StringMap>();

    
        INVT_WrapperDef.INVT_StringMap stingVal = new INVT_WrapperDef.INVT_StringMap();
        stingVal.key = 'SVMX_HearderId';
        stingVal.value = workOrder.Id;
        stringMapLst.add(stingVal);
        
        INVT_WrapperDef.INVT_StringMap stingVal2 = new INVT_WrapperDef.INVT_StringMap();
        stingVal2.key = 'SVMX_InventoryProcessId';
        stingVal2.value = 'WORD010';
        stringMapLst.add(stingVal2);
        
        INVT_WrapperDef.INVT_StringMap stingVal3 = new INVT_WrapperDef.INVT_StringMap();
        stingVal3.key = 'SVMX_AllowWarning';
        stingVal3.value = 'false';
        stringMapLst.add(stingVal3);
        
        objReq.listOfStringMap =  stringMapLst;
        INVT_InventoryAPIEngine objInventoryAPIEngine = new INVT_InventoryAPIEngine();
        objInventoryAPIEngine.setInvtTransactionRecordList(new List<INVT_TransactionRecord>());
        System.debug('response for all: '+objInventoryAPIEngine.processINVTRequest(objReq));
        
  }
  
    static testMethod void INVT_InventoryAPIEngineTest6_UT() 
    {
    
        // Getting record types    
        List<RecordType> recordTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE sobjectType IN ('SVMXC__ServiceMax_Processes__c', 'SVMXC__ServiceMax_Config_Data__c','SVMXC__Service_Order_Line__c')];

        String strSubmoduleRecordTypeId, strSettingRecordTypeId, strInventoryProcessRecordTypeId, strSettingValueRecordTypeId, strConfigProfileRecordTypeId, strWrokDetailRecordTypeId;
            
        for( RecordType recordTypeSObject : recordTypeList ) {

            if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SUBMODULE ) ) {
                strSubmoduleRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_INVENTORY_PROCESS ) ) {
                strInventoryProcessRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTINGS ) ) {
                strSettingRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_SETTING_VALUE ) ) {
                strSettingValueRecordTypeId = recordTypeSObject.id;
            } else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_CONFIGURATION_PROFILE ) ) {
                strConfigProfileRecordTypeId = recordTypeSObject.id;
            }else if( recordTypeSObject.Name.equalsIgnoreCase( STRING_USAGE_CONSUMPTION ) ) {
                strWrokDetailRecordTypeId = recordTypeSObject.id;
            }
        }

        
        
        // Create Account
            Account account = new Account( Name = 'Account',
            ShippingStreet = 'ABC',
            ShippingCity = 'PQR',
            ShippingState = 'XYZ',
            ShippingPostalCode = '111',
            ShippingCountry = 'XYZ',
            BillingStreet = 'ABC',
            BillingCity = 'PQR',
            BillingState = 'XYZ',
            BillingPostalCode = '111',
            BillingCountry = 'XYZ'); 
            insert account;
            // Create Contact
            Contact contact = new Contact( LastName='Last',
                AccountId = account.Id,
                Email = 'svmxmailfortest@servicemax.com');
            insert contact;
            
            // Create locations       
        
            SVMXC__Site__c location1 = new SVMXC__Site__c( Name = 'MG Road',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            insert location1;
             
            SVMXC__Site__c location2 = new SVMXC__Site__c( Name = 'Trinity',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                SVMXC__Email__c = 'testEmail@servicemax.com');
            
            insert location2;
            
            // Creating product2
            Product2 product2 = new Product2( Name = 'prodPR1',
                ProductCode='prodPR1',
                SVMXC__Inherit_Parent_Warranty__c = True,
                SVMXC__Enable_Serialized_Tracking__c = True,
                SVMXC__Stockable__c = True );
            insert product2;
                            
        //  Create workorder
            SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c( 
                SVMXC__Company__c = account.Id,
                SVMXC__Contact__c = contact.Id,        
                SVMXC__Order_Status__c = 'Open' );
            
            insert workOrder;
           
            // Creating work details
                SVMXC__Service_Order_Line__c workDetail = new SVMXC__Service_Order_Line__c(
                    SVMXC__Service_Order__c = workOrder.Id,
                    SVMXC__Consumed_From_Location__c = location1.id,
                    RecordTypeId = strWrokDetailRecordTypeId,
                    SVMXC__Actual_Quantity2__c = 2,
                    SVMXC__Product__c = product2.id,
                    SVMXC__Serial_Number_List__c = 'Serial1,SerailNo2,SerailNo3',
                    SVMXC__Posted_To_Inventory__c = False,
                    SVMXC__Line_Type__c = 'Parts'
            ); 
            insert workDetail;
            
            SVMXC__Product_Stock__c proStock1 = new SVMXC__Product_Stock__c();
        proStock1.SVMXC__Status__c = 'Available';
        proStock1.SVMXC__Product__c = product2.id;
        proStock1.SVMXC__Location__c = location1.Id;
                
        
        List<SVMXC__Product_Stock__c> productStockList = new List<SVMXC__Product_Stock__c>();
        productStockList.add(proStock1);
        
        insert productStockList;
        
        // create serial
        SVMXC__Product_Serial__c proSerial = new SVMXC__Product_Serial__c();
        proSerial.SVMXC__Product__c = product2.id;
        proSerial.SVMXC__Product_Stock__c = proStock1.id;
        proSerial.SVMXC__Active__c = true;
        proSerial.Name = 'Serial1';
        
        insert proSerial;
            
            INVT_WrapperDef.INVT_Request objReq = new INVT_WrapperDef.INVT_Request();
        List<INVT_WrapperDef.INVT_StringMap> stringMapLst = new List<INVT_WrapperDef.INVT_StringMap>();

    
        INVT_WrapperDef.INVT_StringMap stingVal = new INVT_WrapperDef.INVT_StringMap();
        stingVal.key = 'SVMX_HearderId';
        stingVal.value = workOrder.Id;
        stringMapLst.add(stingVal);
        
        INVT_WrapperDef.INVT_StringMap stingVal2 = new INVT_WrapperDef.INVT_StringMap();
        stingVal2.key = 'SVMX_InventoryProcessId';
        stingVal2.value = 'WORD010';
        stringMapLst.add(stingVal2);
        
        INVT_WrapperDef.INVT_StringMap stingVal3 = new INVT_WrapperDef.INVT_StringMap();
        stingVal3.key = 'SVMX_AllowWarning';
        stingVal3.value = 'false';
        stringMapLst.add(stingVal3);
        
        objReq.listOfStringMap =  stringMapLst;
        INVT_InventoryAPIEngine objInventoryAPIEngine = new INVT_InventoryAPIEngine();
        objInventoryAPIEngine.setInvtTransactionRecordList(new List<INVT_TransactionRecord>());
        System.debug('response for all: '+objInventoryAPIEngine.processINVTRequest(objReq));
        
  }
}