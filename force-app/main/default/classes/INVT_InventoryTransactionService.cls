/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Service endpoint for all Inventory Transaction services.
 *
 * @author Ramachandra Mohan
 * @version 20.2
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       16 Jan 2020     Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/svmx/rest/InventoryTransaction/*')
global class INVT_InventoryTransactionService {
    
    @HttpPost
    global static void doPost() {

        System.debug(LoggingLevel.DEBUG, 'INVT_InventoryProcessService::doPost() - enter' );
        
        try {

            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI( request, response );
            inventoryTransactionAPI.invokePost();
        } 
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'INVT_InventoryProcessService::doPost() : Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug(LoggingLevel.DEBUG, 'INVT_InventoryProcessService::doPost() - exit' );
        }
    }
    
    /*
    @HttpGet
    global static void doGet() {

        System.debug(LoggingLevel.DEBUG, 'INVT_InventoryProcessService::doPost() - enter' );
        
        try {

            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            INVT_InventoryTransactionAPI inventoryTransactionAPI = new INVT_InventoryTransactionAPI( request, response );
            inventoryTransactionAPI.invokePost();
        } 
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'INVT_InventoryProcessService::doPost() : Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug(LoggingLevel.DEBUG, 'INVT_InventoryProcessService::doPost() - exit' );
        }
    }*/
}