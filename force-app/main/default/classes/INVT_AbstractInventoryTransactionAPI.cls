/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Abstract class which defines all supported Inventory Transaction APIs.
 *
 * @author Ramachandra Mohan
 * @version 20.2
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       29 Jan 2020     Created.
 *****************************************************************************************************/
public abstract class INVT_AbstractInventoryTransactionAPI extends SVMXRestBase {

    /**
     * 
     */
    static final String REST_PROCESS_INVENTORY          = 'processInventory';
    
    static final String REST_UPDATE_STOCK               = 'updateStock';
    
    static final String REST_GET_PRODUCT_STOCK          = 'getProductStockLine';
    
    /**
     * 
     */
    //static final String REST_PROCESS_SHIPMENTS            = 'processShipments';
    
    /**
     * 
     */
    //static final String REST_PROCESS_RECEIPTS             = 'processReceipts';
    
    /**
     * 
     */
    //static final String REST_RECEIVE_PARTS                = 'receiveParts';
    
    /**
     * 
     */
    private INVT_Structure.INVT_Request invtRequest;
    
    /**
     * 
     */
    private INVT_AbstractInventoryTransactionAPI() {    
    }
    
    /**
     * 
     */
    protected INVT_AbstractInventoryTransactionAPI( final RestRequest request, final RestResponse response ) {
        //super(request, response, 'InventoryProcess');
        
        super(request, response, 'InventoryTransaction');
        this.invtRequest = (INVT_Structure.INVT_Request) deserializeRequestTo(INVT_Structure.INVT_Request.class);
    }
    
    /**
     * Override method to invoke individual API methods as per rest request.
     */
    override public Object invokeMethod( final SVMXRestMethodInfo restMethodInfo ) {
        
        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; serviceName=' + serviceName + '; methodName=' + methodName );
        
        INVT_Structure.INVT_Response response = new INVT_Structure.INVT_Response();
        response.success = true;
        
        try {
            
            if( restMethodInfo != null && String.isNotEmpty( restMethodInfo.MethodName ) ) {
            
                if( restMethodInfo.MethodName.equalsIgnoreCase(REST_UPDATE_STOCK)){
                    response = updateStock(invtRequest);
                } else if( restMethodInfo.MethodName.equalsIgnoreCase(REST_GET_PRODUCT_STOCK) ) {
                    response = getProductStockLine(invtRequest);
                } 
                /*else if( restMethodInfo.MethodName.equalsIgnoreCase(REST_PROCESS_RECEIPTS) ) {
                    response = processReceipts(invtRequest);
                } else if( restMethodInfo.MethodName.equalsIgnoreCase(REST_RECEIVE_PARTS) ) {
                    response = receiveParts(invtRequest);
                } */else {
                     
                     response.success = false;
                     response.message = 'Method not exists';
                }
            } else {
                
                response.success = false;
                response.message = 'Invalid Request';
                
                System.debug( LoggingLevel.ERROR, 'invokeMethod() : Invalid request or method' );
            }
        }
        
        catch( Exception e ) {
            
            response.success = false;
            response.message = 'Internal Server Error';
            
            System.debug( LoggingLevel.ERROR, 'invokeMethod() : Error=' + e.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit' );
        }
        
        return response;
    }
    
    /**
     * This abstract method is to implement below three post to inventory processes.
     *      - SADJ001 : Post to Inventory - Stock Adjustment
     *      - SXFR001 : Post to Inventory - Stock Transfer
     *      - WORD010 : Post to Inventory - Work Order Usage
     */
    public abstract INVT_Structure.INVT_Response updateStock( final INVT_Structure.INVT_Request request );
    
     /**
     * This abstract method is to implement below three post to inventory processes.
     *      - SADJ001 : Post to Inventory - Stock Adjustment
     *      - SXFR001 : Post to Inventory - Stock Transfer
     *      - WORD010 : Post to Inventory - Work Order Usage
     */
    public abstract INVT_Structure.INVT_Response getProductStockLine( final INVT_Structure.INVT_Request request );
    
    /**
     * This abstract method is to implement below two shipment processes.
     *      - PORD007   Process Shipments (Basic) for Shipment Order
     *      - PORD008   Process Shipments (Advanced) for Shipment Order
     */
    //public abstract INVT_Structure.INVT_Response processShipments( final INVT_Structure.INVT_Request request );
    
    /**
     * This abstract method is to implement below receipt process.
     *      - PORD009   Process Receipts (Advanced) for RMA
     */
    //public abstract INVT_Structure.INVT_Response processReceipts( final INVT_Structure.INVT_Request request );
    
    /**
     * This abstract method is to implement below three receive parts processes.
     *      - PREQ004   Receive Parts from Warehouse for a Parts Request
     *      - PREQ005   Receive Parts from Supplier for a Parts Request
     *      - WORD011   Receive Parts for a Work Order
     */
    //public abstract INVT_Structure.INVT_Response receiveParts( final INVT_Structure.INVT_Request request );
}