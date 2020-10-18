/**
 * This class contains inventory related const variables.
 */
public with sharing class INVT_Consts {
    
    /*
     * Fields name const variables
     */
    public static final String FIELD_NAME_ID                            = 'Id';
    public static final String FIELD_NAME_NAME                          = 'Name';
    public static final String FIELD_NAME_STOCKABLE                     = 'SVMXC__Stockable__c';
    public static final String FIELD_NAME_STOCKING_LOCATION             = 'SVMXC__Stocking_Location__c';
    public static final String FIELD_NAME_ENABLE_SERIALIZED_TRACKING    = 'SVMXC__Enable_Serialized_Tracking__c';
        
    /*
     * String const variables.
     */
    public static final String EMPTY_STRING             = '';
    public static final String SEPARATOR_DOT            = '.';
    public static final String SEPARATOR_COMMA          = ',';
    
    public static final String NUMBER_OF_LOCATIONS_ONE  = 'ONE';
    public static final String NUMBER_OF_LOCATIONS_TWO  = 'TWO';
    
    /*
     * Const request attribute names
     */
    public static final String SVMX_LINEIDS_STRING          = 'SVMX_LineIds';
    public static final String SVMX_HEADERID_STRING         = 'SVMX_HearderId';
    public static final String SVMX_INVETORYID_STRING       = 'SVMX_InventoryProcessId';
    public static final String SVMX_ALLOW_WARNING_STRING    = 'SVMX_AllowWarning';
    
    public static final Boolean BOOLEAN_TRUE    =   Boolean.valueOf('True');
    public static final Boolean BOOLEAN_FALSE   =   Boolean.valueOf('False');
    
    public static final String EXPRESSION_TYPE_HEADER_CLOSURE_ACTION    = 'INV_Header_Closure_Action';
    public static final String EXPRESSION_TYPE_LINE_CLOSURE_ACTION      = 'INV_Line_Closure_Action';
    public static final String EXPRESSION_TYPE_RELATED_UPDATE_ACTION    = 'INV_Related_Update_Action';
    
    public static final String SOURCE_ACTION_SET        = 'Set';
    public static final String SOURCE_ACTION_INCREASE   = 'Increase';
    public static final String SOURCE_ACTION_DECREASE   = 'Decrease';
    
    private static final INVT_Consts instance = new INVT_Consts();
    
    public static INVT_Consts getInstance() {
        return instance;
    }
    /**
     * Private class constructor. Instence of this class will not be created.
     */
    private INVT_Consts() {
    }
}