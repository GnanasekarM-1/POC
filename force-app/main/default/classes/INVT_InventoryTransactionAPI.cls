/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has definision for all available Inventory Transaction APIs.
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
public with sharing class INVT_InventoryTransactionAPI extends INVT_AbstractInventoryTransactionAPI {

    public INVT_InventoryTransactionAPI( RestRequest request, RestResponse response ) {
        super( request, response);
    }
        
    override public INVT_Structure.INVT_Response updateStock( final INVT_Structure.INVT_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateStock() - enter' );
        
        INVT_Structure.INVT_Response response = new INVT_Structure.INVT_Response();
        response.success = true;
        try {
            
            if( request != null && request.inventoryProcessInfo != null ) {
                response = new INVT_InventoryTransactionImpl().updateInventoryProcess( request.inventoryProcessInfo );
            }
        }
        
        catch( Exception e ) {
            
            response.success = false;
            response.message = 'Internal server error';
            
            System.debug( LoggingLevel.ERROR, 'updateStock() : Failed to process request; Error=' + e.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateStock() - exit; success=' + response.success );
        }
        
        return response;
    }
    
    override public INVT_Structure.INVT_Response getProductStockLine( final INVT_Structure.INVT_Request request ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProductStockLine() - enter' );
        
        INVT_Structure.INVT_Response response = new INVT_Structure.INVT_Response();
        
        try {
            
            if( request != null && request.inventoryProcessInfo != null ) {
                response = new INVT_InventoryTransactionImpl().getProductStockLine( request.inventoryProcessInfo );
            }
        }
        
        catch( Exception e ) {
            
            response.success = false;
            response.message = 'Internal server error';
            
            System.debug( LoggingLevel.ERROR, 'getProductStockLine() : Failed to process request; Error=' + e.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProductStockLine() - exit; success=' + response.success );
        }
        
        return response;
    }
}