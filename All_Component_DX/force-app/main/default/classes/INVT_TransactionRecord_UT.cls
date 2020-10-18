@isTest
private class INVT_TransactionRecord_UT {
    
    private static SVMXC.INVT_TransactionRecord transectionRecord = new SVMXC.INVT_TransactionRecord( new SVMXC__Service_Order_Line__c() );
    
    static testMethod void testConstructor() {
        
        System.assert( transectionRecord.getTransactionRecord() != null, 'getTransactionRecord() assertion failed.' );
        System.assert( transectionRecord.getSerialNumberList() != null, 'getSerialNumberList() assertion failed.' );
        
        System.assert( transectionRecord.getSelected() == false, 'getSelected() assertion failed.' );
        System.assert( transectionRecord.doCloseLine() == false, 'getCloseLine() assertion failed.' );
        System.assert( transectionRecord.isNegativeStockAtSource() == false, 'isNegativeStockAtSource() assertion failed.' );
        System.assert( transectionRecord.isEnableSerialSelection() == false, 'isEnableSerialSelection() assertion failed.' );
    }
    
    static testMethod void testAddSerialNumber() {
        
        SVMXC.INVT_TransactionRecord localTransactionRecord = new SVMXC.INVT_TransactionRecord( new SVMXC__Service_Order_Line__c() );
        
        System.assert( localTransactionRecord.getSerialNumberList().isEmpty() );
        
        // Null serial number check
        localTransactionRecord.addSerialNumber(null);
        System.assert( localTransactionRecord.getSerialNumberList().isEmpty() );
        
        // Empty serial number check
        localTransactionRecord.addSerialNumber('');
        System.assert( localTransactionRecord.getSerialNumberList().isEmpty() );
        
        // add serial number check
        localTransactionRecord.addSerialNumber('Serial_1');
        localTransactionRecord.addSerialNumber('Serial_2');
        localTransactionRecord.addSerialNumber('Serial_3');
        localTransactionRecord.addSerialNumber('Serial_4');
        localTransactionRecord.addSerialNumber('Serial_5');
        System.assert( localTransactionRecord.getSerialNumberList().size() == 5 );
    }
    
    static testMethod void testSetSerialNumberList() {
        
        SVMXC.INVT_TransactionRecord localTransactionRecord = new SVMXC.INVT_TransactionRecord( new SVMXC__Service_Order_Line__c() );
        
        System.assert( localTransactionRecord.getSerialNumberList().isEmpty() );
        
        // Null serial number list check
        List<String> serialNumberList = null;       
        localTransactionRecord.setSerialNumberList( serialNumberList );
        System.assert( localTransactionRecord.getSerialNumberList().isEmpty() );
        
        // Empty serial number list check
        serialNumberList = new List<String>();      
        localTransactionRecord.setSerialNumberList( serialNumberList );
        System.assert( localTransactionRecord.getSerialNumberList().isEmpty() );
        
        // set serial number list check
        serialNumberList.add('Serial_1');
        serialNumberList.add('Serial_2');
        serialNumberList.add('Serial_3');
        serialNumberList.add('Serial_4');
        serialNumberList.add('Serial_5');
        System.assert( localTransactionRecord.getSerialNumberList().size() == 5 );
        
        // resetset serial number list check
        serialNumberList.clear();
        serialNumberList.add('Serial_1');
        serialNumberList.add('Serial_2');
        serialNumberList.add('Serial_3');
        System.assert( localTransactionRecord.getSerialNumberList().size() == 3 );
    }
    
    static testMethod void testSetTransactionRecord() {
        
        System.assert( transectionRecord.getTransactionRecord() != null );
        
        transectionRecord.setTransactionRecord( null );
        System.assert( transectionRecord.getTransactionRecord() == null );
        
        transectionRecord.setTransactionRecord( new SVMXC__Service_Order_Line__c() );
        System.assert( transectionRecord.getTransactionRecord() != null );
    }
    
    static testMethod void testSetEnableSerialSelection() {
        
        System.assert( transectionRecord.isEnableSerialSelection() == false );
        
        transectionRecord.setEnableSerialSelection( true );
        System.assert( transectionRecord.isEnableSerialSelection() == true );
    }
    
    static testMethod void testSetNegativeStockAtSource() {
        
        System.assert( transectionRecord.isNegativeStockAtSource() == false );
        
        transectionRecord.setNegativeStockAtSource( true );
        System.assert( transectionRecord.isNegativeStockAtSource() == true );
    }
    
    static testMethod void testSetSelected() {
        
        System.assert( transectionRecord.getSelected() == false );
        
        transectionRecord.setSelected( true );
        System.assert( transectionRecord.getSelected() == true );
    }
    
    static testMethod void testSetNameFieldValue() {
        
        System.assert( transectionRecord.getNameFieldValue() == '' );
        
        transectionRecord.setNameFieldValue( null );
        System.assert( transectionRecord.getNameFieldValue() == null );
        
        transectionRecord.setNameFieldValue('LineName');
        System.assert( transectionRecord.getNameFieldValue() == 'LineName' );
        
        transectionRecord.setNameFieldValue( '' );
        System.assert( transectionRecord.getNameFieldValue() == '' );
    }
    
    static testMethod void testSetProductName() {
        
        System.assert( transectionRecord.getProductName() == '' );
        
        transectionRecord.setProductName( null );
        System.assert( transectionRecord.getProductName() == null );
        
        transectionRecord.setProductName('ProductName');
        System.assert( transectionRecord.getProductName() == 'ProductName' );
        
        transectionRecord.setProductName('');
        System.assert( transectionRecord.getProductName() == '' );
    }
    
    static testMethod void testSetProductId() {
        
        System.assert( transectionRecord.getProductId() == null );
        
        transectionRecord.setProductId( null );
        System.assert( transectionRecord.getProductId() == null );
        
        transectionRecord.setProductId(Id.valueOf('0013000000f3adA'));
        System.assert( transectionRecord.getProductId() == '0013000000f3adA' ); 
    }
    
    static testMethod void testSetOriginalQty() {
        
        System.assert( transectionRecord.getOriginalQty() == 0.0 );
        
        transectionRecord.setOriginalQty( Double.valueOf('1.0') );
        System.assert( transectionRecord.getOriginalQty() == 1.0 );
        
        transectionRecord.setOriginalQty( (String) null);
        System.assert( transectionRecord.getOriginalQty() == 0.0 );
        
        transectionRecord.setOriginalQty('1.0');
        System.assert( transectionRecord.getOriginalQty() == 1.0 );
        
        transectionRecord.setOriginalQty( 'abc' );
        System.assert( transectionRecord.getOriginalQty() == 0.0 );
    }
    
    static testMethod void testSetActualQty() {
        
        System.assert( transectionRecord.getActualQty() == 0.0 );
        
        transectionRecord.setActualQty( Double.valueOf('1.0') );
        System.assert( transectionRecord.getActualQty() == 1.0 );
        
        transectionRecord.setActualQty( (String) null);
        System.assert( transectionRecord.getActualQty() == 0.0 );
        
        transectionRecord.setActualQty('1.0');
        System.assert( transectionRecord.getActualQty() == 1.0 );
        
        transectionRecord.setActualQty( 'abc' );
        System.assert( transectionRecord.getActualQty() == 0.0 );
    }
    
    static testMethod void testSetCloseLine() {
        
        System.assert( transectionRecord.doCloseLine() == false );
        
        transectionRecord.setCloseLine( true );
        System.assert( transectionRecord.doCloseLine() == true );
    }
    
    static testMethod void testSetTransactionRecordId() {
        
        System.assert( transectionRecord.getTransactionRecordId() == null );
        
        transectionRecord.setTransactionRecordId( null );
        System.assert( transectionRecord.getTransactionRecordId() == null );
                
        transectionRecord.setTransactionRecordId( Id.valueOf('0013000000f3adA'));
        System.assert( transectionRecord.getTransactionRecordId() == '0013000000f3adA' );
    }
    
    static testMethod void testSetFromLocationId() {
        
        System.assert( transectionRecord.getFromLocationId() == null );
        
        transectionRecord.setFromLocationId( null );
        System.assert( transectionRecord.getFromLocationId() == null );
        
        transectionRecord.setFromLocationId(Id.valueOf('0013000000f3adA'));
        System.assert( transectionRecord.getFromLocationId() == '0013000000f3adA' );    
    }
    
    static testMethod void testSetToLocationId() {
        
        System.assert( transectionRecord.getToLocationId() == null );
        
        transectionRecord.setToLocationId( null );
        System.assert( transectionRecord.getToLocationId() == null );
        
        transectionRecord.setToLocationId(Id.valueOf('0013000000f3adA'));
        System.assert( transectionRecord.getToLocationId() == '0013000000f3adA' );  
    }
    
    static testMethod void testSetFromLocationName() {
        
        System.assert( transectionRecord.getFromLocationName() == '' );
        
        transectionRecord.setFromLocationName( null );
        System.assert( transectionRecord.getFromLocationName() == null );
        
        transectionRecord.setFromLocationName('FromLocationName');
        System.assert( transectionRecord.getFromLocationName() == 'FromLocationName' );
        
        transectionRecord.setFromLocationName('');
        System.assert( transectionRecord.getFromLocationName() == '' );
    }
    
    static testMethod void testSetToLocationName() {
        
        System.assert( transectionRecord.getToLocationName() == '' );
        
        transectionRecord.setToLocationName( null );
        System.assert( transectionRecord.getToLocationName() == null );
        
        transectionRecord.setToLocationName('ToLocationName');
        System.assert( transectionRecord.getToLocationName() == 'ToLocationName' );
        
        transectionRecord.setToLocationName('');
        System.assert( transectionRecord.getToLocationName() == '' );
    }
    
    static testMethod void testSetFromStatus() {
        
        System.assert( transectionRecord.getFromStatus() == '' );
        
        transectionRecord.setFromStatus( null );
        System.assert( transectionRecord.getFromStatus() == null );
        
        transectionRecord.setFromStatus('FromStatus');
        System.assert( transectionRecord.getFromStatus() == 'FromStatus' );
        
        transectionRecord.setFromStatus('');
        System.assert( transectionRecord.getFromStatus() == '' );
    }
    
    static testMethod void testSetToStatus() {
        
        System.assert( transectionRecord.getToStatus() == '' );
        
        transectionRecord.setToStatus( null );
        System.assert( transectionRecord.getToStatus() == null );
        
        transectionRecord.setToStatus('ToStatus');
        System.assert( transectionRecord.getToStatus() == 'ToStatus' );
        
        transectionRecord.setToStatus('');
        System.assert( transectionRecord.getToStatus() == '' );
    }
}