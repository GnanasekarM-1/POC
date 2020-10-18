@isTest
private class INVT_ConfigurationRecord_UT {
    
    private static List<String> SETTING_ID_LIST = new List<String> {
        
        'SET001','SET002','SET003','SET004','SET005',
        'SET006','SET007','SET008','SET009','SET010',
        'SET011','SET012','SET013','SET014','SET015',
        'SET016','SET017','SET018','SET019','SET020',
        'SET021','SET022','SET023','SET024','SET025',
        'SET026','SET027','SET028','SET029','SET030',
        'SET031','SET032','SET033','SET034','SET035',
        'SET036','SET037','SET038','SET039','SET040'
    };
    
    private static Map<String,String> SETTING_DATA_MAP = new Map<String,String>();
     
    static { 
        
        SETTING_DATA_MAP.put('SET001', null);
        SETTING_DATA_MAP.put('SET002', 'false');
        SETTING_DATA_MAP.put('SET003', 'false');
        SETTING_DATA_MAP.put('SET004', 'false');
        SETTING_DATA_MAP.put('SET005', null);
        SETTING_DATA_MAP.put('SET006', null);
        SETTING_DATA_MAP.put('SET007', null);
        SETTING_DATA_MAP.put('SET008', null);
        SETTING_DATA_MAP.put('SET009', 'false');
        SETTING_DATA_MAP.put('SET010', 'false');
        SETTING_DATA_MAP.put('SET011', null);
        SETTING_DATA_MAP.put('SET012', 'false');
        SETTING_DATA_MAP.put('SET013', 'false');
        SETTING_DATA_MAP.put('SET014', 'false');
        SETTING_DATA_MAP.put('SET015', 'false');
        SETTING_DATA_MAP.put('SET016', 'false');
        SETTING_DATA_MAP.put('SET017', 'false');
        SETTING_DATA_MAP.put('SET018', 'false');
        SETTING_DATA_MAP.put('SET019', null);
        SETTING_DATA_MAP.put('SET020', 'false');
        SETTING_DATA_MAP.put('SET021', 'false');
        SETTING_DATA_MAP.put('SET022', null);
        SETTING_DATA_MAP.put('SET023', null);
        SETTING_DATA_MAP.put('SET024', null);
        SETTING_DATA_MAP.put('SET025', null);
        SETTING_DATA_MAP.put('SET026', null);
        SETTING_DATA_MAP.put('SET027', null);
        SETTING_DATA_MAP.put('SET028', null);
        SETTING_DATA_MAP.put('SET029', null);
        SETTING_DATA_MAP.put('SET030', null);
        SETTING_DATA_MAP.put('SET031', null);
        SETTING_DATA_MAP.put('SET032', null);
        SETTING_DATA_MAP.put('SET033', null);
        SETTING_DATA_MAP.put('SET034', null);
        SETTING_DATA_MAP.put('SET035', null);
        SETTING_DATA_MAP.put('SET036', null);
        SETTING_DATA_MAP.put('SET037', null);
        SETTING_DATA_MAP.put('SET038', null);
        SETTING_DATA_MAP.put('SET039', null);
        SETTING_DATA_MAP.put('SET040', null);
    }
 
    
    static testMethod void testINVTConfigurationRecord() {
        
        SVMXC__ServiceMax_Processes__c svmxProcess;
        Map<String, SVMXC__ServiceMax_Config_Data__c> mapSetting;       
        
        INVT_ConfigurationRecord configurationRecord = new INVT_ConfigurationRecord( svmxProcess, mapSetting );     
        validateInstanceVariables( configurationRecord );
        
        svmxProcess = new  SVMXC__ServiceMax_Processes__c();
        mapSetting = new Map<String, SVMXC__ServiceMax_Config_Data__c>();
        configurationRecord = new INVT_ConfigurationRecord( svmxProcess, mapSetting );
        validateInstanceVariables( configurationRecord );
                                
        updateMapSetting(mapSetting);   
        
        configurationRecord = new INVT_ConfigurationRecord( svmxProcess, mapSetting );
        validateInstanceVariables( configurationRecord );
    }
    
    private static void updateMapSetting( Map<String, SVMXC__ServiceMax_Config_Data__c> mapSetting ) {
        
        updateMapSettings( mapSetting, 'SET001', 'ActualQuantityAPIName' );
        updateMapSettings( mapSetting, 'SET002', 'true' );
        updateMapSettings( mapSetting, 'SET003', 'true' );
        updateMapSettings( mapSetting, 'SET004', 'true' );
        updateMapSettings( mapSetting, 'SET005', 'ChildAdvancedOption' );
        updateMapSettings( mapSetting, 'SET006', 'ChildObjectName' );
        updateMapSettings( mapSetting, 'SET007', 'ChildObjectRecordType' );
        updateMapSettings( mapSetting, 'SET008', 'EmailForNegativeStockAlert' );
        updateMapSettings( mapSetting, 'SET009', 'true' );
        updateMapSettings( mapSetting, 'SET010', 'true' );
        updateMapSettings( mapSetting, 'SET011', 'true' );
        updateMapSettings( mapSetting, 'SET012', 'true' );
        updateMapSettings( mapSetting, 'SET013', 'true' );
        updateMapSettings( mapSetting, 'SET014', 'true' );
        updateMapSettings( mapSetting, 'SET015', 'true' );
        updateMapSettings( mapSetting, 'SET016', 'true' );
        updateMapSettings( mapSetting, 'SET017', 'true' );
        updateMapSettings( mapSetting, 'SET018', 'true' );
        updateMapSettings( mapSetting, 'SET019', 'LookupFieldToParent' );
        updateMapSettings( mapSetting, 'SET020', 'true' );
        updateMapSettings( mapSetting, 'SET021', 'true' );  
        updateMapSettings( mapSetting, 'SET022', 'NumberOfLocation' );
        updateMapSettings( mapSetting, 'SET023', 'OriginalQuantityAPIName' );
        updateMapSettings( mapSetting, 'SET024', 'ParentAdvancedOption' );
        updateMapSettings( mapSetting, 'SET025', 'ParentObjectName' );
        updateMapSettings( mapSetting, 'SET026', 'ProductFieldAPIName' );
        updateMapSettings( mapSetting, 'SET027', 'RelatedProductField' );
        updateMapSettings( mapSetting, 'SET028', 'RelationshipNameToParent' );
        updateMapSettings( mapSetting, 'SET029', 'RelationshipNameToProduct' );
        updateMapSettings( mapSetting, 'SET030', 'RelationshipToSourceLocation' );
        updateMapSettings( mapSetting, 'SET031', 'RelationshipToTargetLocation' );
        updateMapSettings( mapSetting, 'SET032', 'SourceAction' );
        updateMapSettings( mapSetting, 'SET033', 'SourceLocationAPIName' ); 
        updateMapSettings( mapSetting, 'SET034', 'SourceStatus' );
        updateMapSettings( mapSetting, 'SET035', 'StockHistoryHeaderAPIName' );
        updateMapSettings( mapSetting, 'SET036', 'StockHistoryLineAPIName' );
        updateMapSettings( mapSetting, 'SET037', 'TargetAction' );
        updateMapSettings( mapSetting, 'SET038', 'TargetLocationAPIName' );
        updateMapSettings( mapSetting, 'SET039', 'TargetStatus' );
        updateMapSettings( mapSetting, 'SET040', 'Serial_1,Serial_2,Serial_3' );
    }
    
    private static void updateMapSettings( Map<String, SVMXC__ServiceMax_Config_Data__c> mapSetting, String key, String value ) {
        
        SVMXC__ServiceMax_Config_Data__c configData = new SVMXC__ServiceMax_Config_Data__c();
        configData.SVMXC__Internal_Value__c = value;
        mapSetting.put(key, configData );
        
        SETTING_DATA_MAP.put( key, value );
    }
    
    private static void validateInstanceVariables( INVT_ConfigurationRecord configurationRecord ) {
        
        Set<String> settingKeySet = SETTING_DATA_MAP.keySet();
        for( String key :  settingKeySet ) {
            
            if( key == 'SET001' ) System.assert( configurationRecord.getActualQuantityAPIName() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET002' ) System.assert( configurationRecord.isAllowExcessQuantity() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET003' ) System.assert( configurationRecord.isAllowPartialClosure() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET004' ) System.assert( configurationRecord.isAllowPartialQuantity() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET005' ) System.assert( configurationRecord.getChildAdvancedOption() == SETTING_DATA_MAP.get(key) );          
            else if( key == 'SET006' ) System.assert( configurationRecord.getChildObjectName() == SETTING_DATA_MAP.get(key) );                      
            else if( key == 'SET007' ) System.assert( configurationRecord.getChildObjectRecordType() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET008' ) System.assert( configurationRecord.getEmailForNegativeStockAlert() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET009' ) System.assert( configurationRecord.isEnableBarCodeEntry() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET010' ) System.assert( configurationRecord.isEnableSerialSelection() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET011' ) System.assert( configurationRecord.getEnforceUniquenessInSerialSelection() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET012' ) System.assert( configurationRecord.isEmailSentToLocationOwner() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET013' ) System.assert( configurationRecord.isMultilineTransaction() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET014' ) System.assert( configurationRecord.isSourceLocationFromHeader() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET015' ) System.assert( configurationRecord.isSourceLocationStockable() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET016' ) System.assert( configurationRecord.isTargetLocationFromHeader() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET017' ) System.assert( configurationRecord.isTargetLocationStockable() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET018' ) System.assert( configurationRecord.isActualQuantityEditable() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET019' ) System.assert( configurationRecord.getLookupFieldToParent() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET020' ) System.assert( configurationRecord.isMaintainSerialHistory() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET021' ) System.assert( configurationRecord.isMaintainStockHistory() == Boolean.valueOf( SETTING_DATA_MAP.get(key) ) );
            else if( key == 'SET022' ) System.assert( configurationRecord.getNumberOfLocation() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET023' ) System.assert( configurationRecord.getOriginalQuantityAPIName() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET024' ) System.assert( configurationRecord.getParentAdvancedOption() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET025' ) System.assert( configurationRecord.getParentObjectName() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET026' ) System.assert( configurationRecord.getProductFieldAPIName() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET027' ) System.assert( configurationRecord.getRelatedProductField() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET028' ) System.assert( configurationRecord.getRelationshipNameToParent() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET029' ) System.assert( configurationRecord.getRelationshipNameToProduct() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET030' ) System.assert( configurationRecord.getRelationshipToSourceLocation() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET031' ) System.assert( configurationRecord.getRelationshipToTargetLocation() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET032' ) System.assert( configurationRecord.getSourceAction() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET033' ) System.assert( configurationRecord.getSourceLocationAPIName() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET034' ) System.assert( configurationRecord.getSourceStatus() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET035' ) System.assert( configurationRecord.getStockHistoryHeaderAPIName() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET036' ) System.assert( configurationRecord.getStockHistoryLineAPIName() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET037' ) System.assert( configurationRecord.getTargetAction() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET038' ) System.assert( configurationRecord.getTargetLocationAPIName() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET039' ) System.assert( configurationRecord.getTargetStatus() == SETTING_DATA_MAP.get(key) );
            else if( key == 'SET040' ) System.assert( configurationRecord.getSerialNumberFieldAPIName() == SETTING_DATA_MAP.get(key) ); 
        }           
    }
}