/**
 * This class used to hold single transaction record information.
 */
public with sharing class INVT_TransactionRecord {
    
    /*
     * Private instance variable to hold boolean flag for selected transaction record. 
     */
    private Boolean isSelected = false;
    
    /*
     * Private instance variable to hold name field value.
     */
    private String nameFieldValue = '';
    
    /*
     * Private instance variable to hold product name.
     */
    private String productName = '';
    
    /*
     * Private instance variable to hold product id.
     */
    private Id productId;
    
    /*
     * Private instance variable to hold original quantity of transaction record.
     */
    private Double originalQty = 0;
    
    /*
     * Private instance variable to hold acrual quantity of transaction record.
     */
    private Double actualQty = 0;
    
    /*
     * Private instance variable to hold do close line flag.
     */
    private Boolean doCloseLine = false;
    
    /*
     * Private instance variable to hold transaction record id.
     */
    private Id transactionRecordId;
    
    /*
     * Private instance variable to hold transaction record from location id.
     */
    private Id fromLocationId;
    
    /*
     * Private instance variable to hold transaction record to location id.
     */
    private Id toLocationId;
    
    /*
     * Private instance variable to hold transaction record from location name.
     */
    private String fromLocationName = '';
    
    /*
     * Private instance variable to hold transaction record to location name.
     */
    private String toLocationName = '';
    
    /*
     * Private instance variable to hold transaction record from status.
     */
    private String fromStatus = '';
    
    /*
     * Private instance variable to hold transaction record to status.
     */
    private String toStatus = '';
    
    /*
     * Private instance variable to hold transaction record SObject reference.
     */
    private SObject transactionRecord;
    
    /*
     * Private instance variable to hold source negative stock update flag.
     */
    private Boolean isNegativeStockAtSource = false;
    
    /*
     * Private instance variable to hold product serial selection enable flag.
     */
    private Boolean isEnableSerialSelection = false;
    
    /*
     * Private instance variable to hold list of serial numbers.
     */
    private List<String> serialNumberList;
    
    /*
     * Private instance variable to hold  label of name field of header object
     */
    private String headerObjectNameFieldLabel;
    
    /*
     * Private instance variable to hold label of name field of line object
     */
    private String lineObjectNameFieldLabel;
    
    
    /*
     * Class constructor to create instance of this class.
     */
    public INVT_TransactionRecord( SObject transactionRecord ) {
        
        this.transactionRecord = transactionRecord;
        serialNumberList = new List<String>();
    }
    
    public void addSerialNumber( String serialNumber ) {
        
        if( serialNumber != null && !serialNumber.equalsIgnoreCase( INVT_Consts.EMPTY_STRING ) ) {
            serialNumberList.add( serialNumber );
        }
    }
    
    public void setSerialNumberList( List<String> serialNumberList ) {
        
        if( serialNumberList != null ) {            
            this.serialNumberList = serialNumberList;
        }
    }
    
    public List<String> getSerialNumberList() {
        return serialNumberList;
    }
    
    public SObject getTransactionRecord() {
        return transactionRecord;
    }
    
    public void setTransactionRecord( SObject transactionRecord ) {
        this.transactionRecord = transactionRecord;
    }
            
    public void setEnableSerialSelection( Boolean enabled ) { isEnableSerialSelection = enabled; }
    public Boolean isEnableSerialSelection() { return isEnableSerialSelection; }
    
    public void setNegativeStockAtSource( Boolean enabled ) { isNegativeStockAtSource = enabled; }
    public Boolean isNegativeStockAtSource() { return isNegativeStockAtSource; }
    
    public boolean getSelected()        { return this.isSelected; }
    public void setSelected(Boolean s)  { this.isSelected = s; } 
    
    public String getNameFieldValue()        { return this.nameFieldValue; }
    public void setNameFieldValue(String s)  { this.nameFieldValue = s; } 
    
    public String getProductName()        { return this.productName; }
    public void setProductName(String s)  { this.productName = s; } 
    
    public Id getProductId()        { return this.productId; }
    public void setProductId(Id s)  { this.productId = s; } 

    public Double getOriginalQty()        { return this.originalQty; }
    public void setOriginalQty(Double s)  { this.originalQty = s;}
    public void setOriginalQty(String s)  { 
        try {
            this.originalQty = Double.valueOf( String.valueOf(s) );
        }
        catch( Exception ex ) {
            this.originalQty = 0.0;
        }
    } 

    public Double getActualQty()        { return this.actualQty; }
    public void setActualQty(Double s)  { this.actualQty = s; }
    public void setActualQty(String s)  { 
        try {
            this.actualQty = Double.valueOf( String.valueOf(s) );
        }
        catch( Exception ex ) {
            this.actualQty = 0.0;
        }
    } 

    public Boolean doCloseLine()        { return this.doCloseLine; }
    public void setCloseLine(Boolean s)  { this.doCloseLine = s; } 
    
    public Id getTransactionRecordId()        { return this.transactionRecordId; }
    public void setTransactionRecordId(Id s)  { this.transactionRecordId = s; } 
    
    public Id getFromLocationId()        { return this.fromLocationId; }
    public void setFromLocationId(Id o)  { this.fromLocationId = o; } 
    
    public Id getToLocationId()        { return this.toLocationId; }
    public void setToLocationId(Id o)  { this.toLocationId = o; } 
    
    public String getFromLocationName()        { return this.fromLocationName; }
    public void setFromLocationName(String o)  { this.fromLocationName = o; } 
    
    public String getToLocationName()        { return this.toLocationName; }
    public void setToLocationName(String o)  { this.toLocationName = o; } 
    
    public String getFromStatus()        { return this.fromStatus; }
    public void setFromStatus(String s)  { this.fromStatus = s; } 
    
    public String getToStatus()        { return this.toStatus; }
    public void setToStatus(String s)  { this.toStatus = s; }
    
    public String getHeaderObjectNameFieldLabel()        { return this.headerObjectNameFieldLabel; }
    public void setHeaderObjectNameFieldLabel(String s)  { this.headerObjectNameFieldLabel = s; }
    
    public String getLineObjectNameFieldLabel()        { return this.lineObjectNameFieldLabel; }
    public void setLineObjectNameFieldLabel(String s)  { this.lineObjectNameFieldLabel = s; }
    
}