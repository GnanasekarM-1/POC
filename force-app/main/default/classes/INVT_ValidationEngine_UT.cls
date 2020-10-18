@isTest(SeeAllData=true)
private class INVT_ValidationEngine_UT {
    
    private static final Integer SETTINGS_COUNT = 41;
    
    private static final String STRING_WORKORDER_ID = 'CUSTOMWORD101';
    
    private static final String CHILD_ERROR_MESSAGE = 'No pending usage lines in this work order to post to inventory.';
    
    private static List<Id> lineIdList = null;
    
    private static Id headerId = null;
    
    private static final String STRING_RMA                      = 'RMA';
    private static final String STRING_GLOBAL                   = 'Global';
    private static final String STRING_SUBMODULE                = 'Submodule';
    private static final String STRING_SETTINGS                 = 'Settings';
    private static final String STRING_SHIPMENT                 = 'Shipment';
    private static final String STRING_SETTING_VALUE            = 'Setting Value';
    private static final String STRING_INVENTORY_PROCESS        = 'Inventory Process';
    private static final String STRING_CONFIGURATION_PROFILE    = 'Configuration Profile';
    private static final String STRING_USAGE_CONSUMPTION        = 'Usage/Consumption';
    
    
    private static final COMM_SVMXC_Utils3 oCommUtils = new COMM_SVMXC_Utils3( true );
    
    private static final String[] SETTING = new String[] {  'SET001','SET002','SET003','SET004','SET005',
                                                            'SET006','SET007','SET008','SET009','SET010',
                                                            'SET011','SET012','SET013','SET014','SET015',
                                                            'SET016','SET017','SET018','SET019','SET020',
                                                            'SET021','SET022','SET023','SET024','SET025',
                                                            'SET026','SET027','SET028','SET029','SET030',
                                                            'SET031','SET032','SET033','SET034','SET035',
                                                            'SET036','SET037','SET038','SET039','SET040','SET041' };
    
    private static final String[] DEFAULT_SETTING_VALUE = new String[] {    '','FALSE','FALSE','FALSE','',
                                                            'SVMXC__Service_Order_Line__c','Usage/Consumption','','FALSE','TRUE',
                                                            'Soft','FALSE','TRUE','FALSE','TRUE',
                                                            'FALSE','FALSE','FALSE','SVMXC__Service_Order__c','FALSE',
                                                            'TRUE','TWO','SVMXC__Actual_Quantity2__c','','SVMXC__Service_Order__c',
                                                            'SVMXC__Product__c','Name','SVMXC__Service_Order__r','SVMXC__Product__r','SVMXC__Consumed_From_Location__r',
                                                            'SVMXC__Consumed_From_Location__r','Decrease','SVMXC__Consumed_From_Location__c','Available','SVMXC__Service_Order__c',
                                                            'SVMXC__Service_Order_Line__c','Increase','SVMXC__Consumed_From_Location__c','Consumed', 'SVMXC__Work_Description__c',
                                                            'SVMXC__Transaction_Results__c' };

    private static String[] SETTING_VALUE = new String[] {  '','FALSE','FALSE','FALSE','',
                                                            'SVMXC__Service_Order_Line__c','Usage/Consumption','','FALSE','TRUE',
                                                            'Soft','FALSE','TRUE','FALSE','TRUE',
                                                            'FALSE','FALSE','FALSE','SVMXC__Service_Order__c','FALSE',
                                                            'TRUE','TWO','SVMXC__Actual_Quantity2__c','','SVMXC__Service_Order__c',
                                                            'SVMXC__Product__c','Name','SVMXC__Service_Order__r','SVMXC__Product__r','SVMXC__Consumed_From_Location__r',
                                                            'SVMXC__Consumed_From_Location__r','Decrease','SVMXC__Consumed_From_Location__c','Available','SVMXC__Service_Order__c',
                                                            'SVMXC__Service_Order_Line__c','Increase','SVMXC__Consumed_From_Location__c','Consumed', 'SVMXC__Work_Description__c',
                                                            'SVMXC__Transaction_Results__c' };
    
    
    private static Map<Id,List<String>> idResultListMap;
    
    private static String listToString( List<String> listOfStrings ) {
        
        String retValue = '';
        
        for( String str : listOfStrings ) {
            retValue += str + '\n';
        }
        
        return retValue;
    }
    
    private static void printStatusMessageMap() {
        
        for( Id transactionId : idResultListMap.keyset() ) {
            System.debug( LoggingLevel.INFO, 'Transaction Record Id : ' + (String) transactionId + '; Message : ' + listToString( idResultListMap.get(transactionId) ) );
        }
    }
     
    private static void resetSettingValuesToDefault() {
        
        for( Integer i = 0; i < SETTINGS_COUNT; i++ ) {
            SETTING_VALUE[i] = DEFAULT_SETTING_VALUE[i];
        }
    } 
    
    static testMethod void testOnLoadValidation_Invalid_Arguments() {
        
        // Null arguments
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation(null, null, null);
                
        System.Assert( !svmxMessageList.isEmpty() );
        System.Assert( svmxMessageList.get(0).message.equalsIgnoreCase( oCommUtils.getTAG038() ) );
        
        // Empty string arguments.
        validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        svmxMessageList = validationEngine.onLoadValidation('', '', null);
                
        System.Assert( !svmxMessageList.isEmpty() );
        System.Assert( svmxMessageList.get(0).message.equalsIgnoreCase( oCommUtils.getTAG038() ) );
    }
    
    static testMethod void testOnLoadValidation_Unknown_InventoryID() {
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( 'headerId', 'InventoryId', null);                
                
        System.Assert( !svmxMessageList.isEmpty() );     
    }
    
    static testMethod void testOnLoadValidation_Unknown_HeaderID() {
        
        Test.startTest();
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( 'headerId', STRING_WORKORDER_ID, null);              
        
        System.Assert( !svmxMessageList.isEmpty() );            
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Invalid_LineId() {
        
        Test.startTest();
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, null);
        
        System.Assert( svmxMessageList.isEmpty() );
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Unknown_LineId() {
        
        Test.startTest();
        
        setupInventoryData();
        
        lineIdList = new List<Id>();
        lineIdList.add('a1LF0000001t7R7');
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList );             
        
        System.Assert( !svmxMessageList.isEmpty() );
        //System.Assert( svmxMessageList.get(0).message.equalsIgnoreCase( CHILD_ERROR_MESSAGE ) );
        
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation() {
        
        Test.startTest();
    
        // isMultilineTransaction = TRUE        
        // isSourceLocationFromHeader = FALSE
        // isSourceLocationStockable = TRUE
        // isTargetLocationFromHeader = FALSE
        // isTargetLocationStockable = FALSE
        setupInventoryData();
                
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );        
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList );
        
        idResultListMap = validationEngine.getRecordStatusMap();
        printStatusMessageMap();
        
        System.Assert( svmxMessageList.isEmpty() ); 
        System.Assert( validationEngine.isProcessComplete() );  
        
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Invalid_NumberOfLocation() {
        
        Test.startTest();
        
        // numberOfLocation = Null/Empty
        SETTING_VALUE[21] = '';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList);  
        
        System.Assert( svmxMessageList.isEmpty() );
        System.Assert( validationEngine.isProcessComplete() );
        
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Invalid_ChildObjectName() {
        
        Test.startTest();
        
        resetSettingValuesToDefault();
        
        // childObjectName = Null/Empty
        SETTING_VALUE[5] = '';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList);              
        
        System.Assert( !svmxMessageList.isEmpty() );
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Invalid_Product() {
        
        Test.startTest();
        
        resetSettingValuesToDefault();
        
        // SVMXC__Product__c = Null/Empty
        SETTING_VALUE[25] = '';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList);              
        
        System.Assert( svmxMessageList.isEmpty() );
        System.Assert( !validationEngine.isProcessComplete() );
        
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Invalid_Product_Reference() {
        
        Test.startTest();
        
        resetSettingValuesToDefault();
        
        // SVMXC__Product__r = Null/Empty
        SETTING_VALUE[28] = '';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList);              
        
        System.Assert( !svmxMessageList.isEmpty() );
        
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Invalid_ParentObjectName() {
        
        Test.startTest();
        
        resetSettingValuesToDefault();
        
        // parentObjectName = Null/Empty
        SETTING_VALUE[24] = '';
        
        // isMultilineTransaction = FALSE
        SETTING_VALUE[12] = 'FALSE';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList);              
        
        System.Assert( !svmxMessageList.isEmpty() );
        Test.stopTest();
    }   
    
    static testMethod void testOnLoadValidation_Invalid_RelatedProductField() {
        
        Test.startTest();
        
        resetSettingValuesToDefault();
        
        // relatedProductField = Null/Empty
        SETTING_VALUE[26] = '';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList);              
        
        System.Assert( svmxMessageList.isEmpty() );
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Invalid_isMultilineTransaction_False() {
        
        Test.startTest();
        
        resetSettingValuesToDefault();
        
        // isMultilineTransaction = FALSE
        SETTING_VALUE[12] = 'FALSE';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList);              
        
        System.Assert( !svmxMessageList.isEmpty() );
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Invalid_RelationshipToTargetLocation() {
        
        Test.startTest();
        
        resetSettingValuesToDefault();
        
        // relationshipToTargetLocation = Null/Empty
        SETTING_VALUE[30] = '';
        
        // isTargetLocationFromHeader = TRUE
        SETTING_VALUE[15] = 'TRUE';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList);              
        
        System.Assert( !validationEngine.isProcessComplete() );
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_Invalid_RelationshipToSourceLocation() {        
        
        Test.startTest();
        
        resetSettingValuesToDefault();
        
        // relationshipToSourceLocation = NULL / Empty
        SETTING_VALUE[29] = null;
        
        // isTargetLocationStockable = TRUE
        SETTING_VALUE[16] = 'TRUE';
        
        // isSourceLocationFromHeader = TRUE
        SETTING_VALUE[13] = 'TRUE';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );        
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList );
        
        System.Assert( svmxMessageList.isEmpty() ); 
        System.Assert( !validationEngine.isProcessComplete() );
        
        Test.stopTest();
    }
    
    static testMethod void testOnLoadValidation_TargetLocationFromHeader() {        
        
        Test.startTest();
        
        resetSettingValuesToDefault();
        
        // relationshipToSourceLocation = NULL / Empty
        SETTING_VALUE[29] = null;
        
        // isTargetLocationFromHeader = TRUE
        SETTING_VALUE[15] = 'TRUE';
        
        setupInventoryData();
        
        INVT_ValidationEngine validationEngine = new INVT_ValidationEngine( new INVT_InventoryAPIEngine() );        
        List<INVT_WrapperDef.SVMXMessage> svmxMessageList = validationEngine.onLoadValidation( headerId, STRING_WORKORDER_ID, lineIdList );
        
        System.Assert( !svmxMessageList.isEmpty() );            
        
        Test.stopTest();
    }
    
    private static SVMXC__ServiceMax_Processes__c createSubmodule( String submoduleRecordTypeId, String submoduleId ) {
        
        SVMXC__ServiceMax_Processes__c submodule = new SVMXC__ServiceMax_Processes__c();
        submodule.RecordTypeId = submoduleRecordTypeId;
        submodule.SVMXC__SubmoduleID__c = submoduleId;
        
        insert submodule;
        
        return submodule;
    }
    
    private static void setupInventoryData() {
        
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
        
        System.assert( strSubmoduleRecordTypeId != null );
        System.assert( strInventoryProcessRecordTypeId != null );
        System.assert( strSettingRecordTypeId != null );
        System.assert( strSettingValueRecordTypeId != null );
        System.assert( strConfigProfileRecordTypeId != null );      
        System.assert( strWrokDetailRecordTypeId != null );     
        
        // Create Submodule..
        SVMXC__ServiceMax_Processes__c submodule = createSubmodule( strSubmoduleRecordTypeId, STRING_WORKORDER_ID );
        
        // Create Configuration Profile
        SVMXC__ServiceMax_Config_Data__c configProfile = new SVMXC__ServiceMax_Config_Data__c( RecordTypeId = strConfigProfileRecordTypeId,
                                                                                                   SVMXC__Configuration_Type__c = STRING_GLOBAL,
                                                                                                   SVMXC__Active__c  = true );
        insert configProfile;       
        
        //Create settings
        SVMXC__ServiceMax_Processes__c []settingArray = new SVMXC__ServiceMax_Processes__c[SETTINGS_COUNT];
        
        // To update setting valies
        String installationKey = EncodingUtil.base64Encode( Blob.valueOf( UserInfo.getOrganizationId().subString(0,15) ) );
        
        for( Integer i = 0; i < SETTINGS_COUNT; i++ ) {
            
            settingArray[i] = new SVMXC__ServiceMax_Processes__c( RecordTypeId = strSettingRecordTypeId, 
                                                                    SVMXC__Submodule__c  = submodule.Id,
                                                                    SVMXC__SettingID__c = SETTING[i],
                                                                    SVMXC__Active__c = true,
                                                                    SVMXC__Search_Order__c = STRING_GLOBAL,
                                                                    SVMXC__INSTALLATION_KEY__C = installationKey );         
        }       
        
        List<SVMXC__ServiceMax_Processes__c> lstSettings = new List<SVMXC__ServiceMax_Processes__c>();
        lstSettings.addAll( settingArray );         
        insert lstSettings;
        
        Map<String,SVMXC__ServiceMax_Processes__c> mapSettingIdSettingRecord = new Map<String,SVMXC__ServiceMax_Processes__c>(); 
        
        List<SVMXC__ServiceMax_Processes__c> listofSettings = [select id,SVMXC__Search_Order__c, SVMXC__Submodule__c,SVMXC__SettingID__c, SVMXC__Active__c 
            FROM SVMXC__ServiceMax_Processes__c 
            WHERE  SVMXC__Active__c = true AND recordType.Name = 'Settings' AND SVMXC__Submodule__c =: submodule.Id]; 
            
        for( SVMXC__ServiceMax_Processes__c pro : listofSettings ) {
            mapSettingIdSettingRecord.put(pro.SVMXC__SettingID__c,pro);
        }
        
        //Create Setting Values
        SVMXC__ServiceMax_Config_Data__c [] settingValueArray = new SVMXC__ServiceMax_Config_Data__c[SETTINGS_COUNT];
        
        for( Integer i = 0; i < SETTINGS_COUNT; i++ ) {
            
            settingValueArray[i] = new SVMXC__ServiceMax_Config_Data__c(    RecordTypeId = strSettingValueRecordTypeId,
                                                                            SVMXC__Setting_Configuration_Profile__c = configProfile.id,
                                                                            SVMXC__Setting_ID__c = mapSettingIdSettingRecord.get(SETTING[i]).Id,
                                                                            SVMXC__Internal_Value__c = SETTING_VALUE[i] );
        }
        
        List<SVMXC__ServiceMax_Config_Data__c> lstSettingValue = new List<SVMXC__ServiceMax_Config_Data__c>();
        lstSettingValue.addAll( settingValueArray );
        
        insert lstSettingValue;
        
        // Create inventory Process
        SVMXC__ServiceMax_Processes__c inventoryProcess = new SVMXC__ServiceMax_Processes__c();
        inventoryProcess.RecordTypeId = strInventoryProcessRecordTypeId;
        inventoryProcess.SVMXC__ProcessID__c = STRING_WORKORDER_ID;
        inventoryProcess.SVMXC__Submodule__c = submodule.id;
        inventoryProcess.SVMXC__Parent_Object_Criteria__c = 'SVMXC__Order_Status__c = \'Open\''; 
        inventoryProcess.SVMXC__Child_Object_Criteria__c  = 'SVMXC__Posted_To_Inventory__c = FALSE';
        inventoryProcess.SVMXC__Parent_Error_Msg__c = 'This work order is not open.';
        inventoryProcess.SVMXC__Child_Error_Msg__c = CHILD_ERROR_MESSAGE;   
         
        insert inventoryProcess;
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
                //SVMXC__Street__c = 'millers road',
                //SVMXC__Country__c = 'india',
                //SVMXC__Zip__c = '123456', 
                SVMXC__Email__c = 'testEmail@servicemax.com');
        insert location1;
         
        SVMXC__Site__c location2 = new SVMXC__Site__c( Name = 'Trinity',
                SVMXC__Stocking_Location__c = true,
                SVMXC__Account__c = account.Id,
                //SVMXC__Street__c = 'millers road',
                //SVMXC__Country__c = 'india',
                //SVMXC__Zip__c = '123456', 
                SVMXC__Email__c = 'testEmail@servicemax.com');
        
        insert location2;
        
        // Creating product2
        Product2 product2 = new Product2( Name = 'prodPR1',
                ProductCode='prodPR1',
                SVMXC__Inherit_Parent_Warranty__c = True,
                SVMXC__Enable_Serialized_Tracking__c = True,
                SVMXC__Stockable__c = True );
        insert product2;
                        
        // Create workorder
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c( 
                SVMXC__Company__c = account.Id,
                SVMXC__Contact__c = contact.Id,             
                SVMXC__Order_Status__c = 'open' );
                
        insert workOrder;
       
        headerId = workOrder.Id;
        //headerId = 'a1LF0000001t7R7';// To do change 
        
        // Creating work details
        SVMXC__Service_Order_Line__c workDetail = new SVMXC__Service_Order_Line__c(
            SVMXC__Service_Order__c = headerId,
            SVMXC__Consumed_From_Location__c = location1.id,
            RecordTypeId = strWrokDetailRecordTypeId,
            SVMXC__Actual_Quantity2__c = 2,
            SVMXC__Product__c = product2.id,
            SVMXC__Work_Description__c = 'SerailNo1,SerailNo2'          
        );
        insert workDetail;
        // Crete stock
        /*SVMXC__Product_Stock__c proStock1 = new SVMXC__Product_Stock__c();
        proStock1.SVMXC__Status__c = 'Available';
        proStock1.SVMXC__Product__c = product2.id;
        proStock1.SVMXC__Location__c = location1.Id;
                
        SVMXC__Product_Stock__c proStock2 = new SVMXC__Product_Stock__c();
        proStock1.SVMXC__Status__c = 'In Transit';
        proStock1.SVMXC__Product__c = product2.id;
        proStock1.SVMXC__Location__c = location2.Id;
        
        List<SVMXC__Product_Stock__c> productStockList = new List<SVMXC__Product_Stock__c>();
        productStockList.add(proStock1);
        productStockList.add(proStock2);
        
        insert productStockList;
        
        // create serial
        SVMXC__Product_Serial__c proSerial = new SVMXC__Product_Serial__c();
        proSerial.SVMXC__Product__c = product2.id;
        proSerial.SVMXC__Product_Stock__c = proStock1.id;
        proSerial.SVMXC__Active__c = true;
        proSerial.Name = 'Serial1';
        
        insert proSerial;*/
        
        lineIdList = new List<Id>();
        //lineIdList.add('a1KF00000034jQH'); // TODO need to use workDetail.id
        lineIdList.add(workDetail.id); // TODO need to use workDetail.id
    }
}