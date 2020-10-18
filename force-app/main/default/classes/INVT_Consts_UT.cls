@isTest
private class INVT_Consts_UT {
    static testMethod void testINVT_Consts() {      
        
        System.assert( INVT_Consts.FIELD_NAME_ID == 'Id' );
        System.assert( INVT_Consts.FIELD_NAME_NAME == 'Name' );
        System.assert( INVT_Consts.FIELD_NAME_STOCKABLE == 'SVMXC__Stockable__c' );
        System.assert( INVT_Consts.FIELD_NAME_STOCKING_LOCATION == 'SVMXC__Stocking_Location__c' );
        System.assert( INVT_Consts.FIELD_NAME_ENABLE_SERIALIZED_TRACKING == 'SVMXC__Enable_Serialized_Tracking__c' );
        
        System.assert( INVT_Consts.EMPTY_STRING == '' );
        System.assert( INVT_Consts.SEPARATOR_DOT == '.' );
        System.assert( INVT_Consts.SEPARATOR_COMMA == ',' );
    
        System.assert( INVT_Consts.NUMBER_OF_LOCATIONS_ONE  == 'ONE' );
        System.assert( INVT_Consts.NUMBER_OF_LOCATIONS_TWO  == 'TWO' );
    
        System.assert( INVT_Consts.SVMX_LINEIDS_STRING == 'SVMX_LineIds' );
        System.assert( INVT_Consts.SVMX_HEADERID_STRING == 'SVMX_HearderId' );
        System.assert( INVT_Consts.SVMX_INVETORYID_STRING == 'SVMX_InventoryProcessId' );
        System.assert( INVT_Consts.SVMX_ALLOW_WARNING_STRING == 'SVMX_AllowWarning' );
    
        System.assert( INVT_Consts.BOOLEAN_TRUE == Boolean.valueOf('True') );
        System.assert( INVT_Consts.BOOLEAN_FALSE == Boolean.valueOf('False') );
    
        System.assert( INVT_Consts.EXPRESSION_TYPE_HEADER_CLOSURE_ACTION == 'INV_Header_Closure_Action' );
        System.assert( INVT_Consts.EXPRESSION_TYPE_LINE_CLOSURE_ACTION == 'INV_Line_Closure_Action' );
        System.assert( INVT_Consts.EXPRESSION_TYPE_RELATED_UPDATE_ACTION == 'INV_Related_Update_Action' );
    
        System.assert( INVT_Consts.SOURCE_ACTION_SET == 'Set' );
        System.assert( INVT_Consts.SOURCE_ACTION_INCREASE == 'Increase' );
        System.assert( INVT_Consts.SOURCE_ACTION_DECREASE == 'Decrease' );
        
        System.assert( INVT_Consts.getInstance() != null );
    }
}