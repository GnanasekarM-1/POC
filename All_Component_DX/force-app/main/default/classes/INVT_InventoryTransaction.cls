/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief 
 *
 * @author Ramachandra Mohan
 * @version 20.2
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       29 Jan 2020     Created.
 *              Jaysukh                 19th Aug 2020   Modified for new Inventory and added JSRGetInventoryTags
 *****************************************************************************************************/
global with sharing class INVT_InventoryTransaction {
    
    //public static final String headerRecordId = System.currentPageReference().getParameters().get('hdrId');
    //public static final String processId = System.currentPageReference().getParameters().get('SMId');
    
    //Do not migrate 
    @RemoteAction
    global static Object JSRGetInventoryTransaction(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetInventoryTransaction() - enter; requestStr=' + requestStr);
        
        INVT_Structure.INVT_Response response = new INVT_Structure.INVT_Response();
        try {
            INVT_Structure.INVT_Request request = (INVT_Structure.INVT_Request) JSON.deserialize(requestStr, INVT_Structure.INVT_Request.class);
            response = new INVT_InventoryTransactionImpl().getProductStockLine(request.inventoryProcessInfo);
        }
        catch( Exception e ) {
            
            response.success = false;
            response.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetInventoryTransaction() - exit;Success=' + response.success);
        }
        return JSON.serialize( response );  
    }
    
    @RemoteAction
    global static Object JSRSubmitInventoryTransaction(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRSubmitInventoryTransaction() - enter; requestStr=' + requestStr);
        
        INVT_Structure.INVT_Response response = new INVT_Structure.INVT_Response();
        response.success = true;
        try {
             INVT_Structure.INVT_Request request = (INVT_Structure.INVT_Request) JSON.deserialize(requestStr, INVT_Structure.INVT_Request.class);
             response = new INVT_InventoryTransactionImpl().updateInventoryProcess(request.inventoryProcessInfo);
        }
        catch( Exception e ) {
            
            response.success = false;
            response.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetInventoryTransaction() - exit;Success=' + response.success);
        }
        return JSON.serialize( response );  
    }
    
    @RemoteAction
    global static Object JSRGetInventoryTags(String requestStr) {
        System.debug( LoggingLevel.DEBUG, 'JSRGetInventoryTags() - enter;');
        
        INVT_Structure.INVT_Response response = new INVT_Structure.INVT_Response();
        response.success = true;
        try {
            //INVT_Structure.INVT_Request request = (INVT_Structure.INVT_Request) JSON.deserialize(requestStr, INVT_Structure.INVT_Request.class);
            //response = new INVT_InventoryTransactionImpl().retrieveInventoryTags(request.inventoryProcessInfo);
            response = new INVT_InventoryTransactionImpl().retrieveInventoryTags();
        }
        catch( Exception e ) {
            
            response.success = false;
            response.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetInventoryTags() - exit;Success=' + response.success);
        }
        return JSON.serialize( response ); 
    }
}