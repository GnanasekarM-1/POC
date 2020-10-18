/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is used to intract directly with Visualforce Page. This class 
 * also has definition for all available JSR methods required for FCO. 
 *
 * @author Ramachandra Mohan
 * @version 20.2
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       07 Feb 2020     Created.
 *****************************************************************************************************/
public with sharing class CORD_Console {
     
    public static final String BLANK_STRING = '';

    /** Created By: Arpit
     * Used to get field change order details
     * @parameter CORD_WrapperDef.FCO_Request, fcoSfId to be provided
     * @return Returns Object
     */
    @RemoteAction
    public static Object JSRGetFieldChangeOrder(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetFieldChangeOrder() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoSfId)){
                response = new CORD_ConsoleImpl().getFieldChangeOrder(request.fcoSfId);
            }
            else {
                 response.success = false;
                 response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRGetFieldChangeOrder', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetFieldChangeOrder() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
        //return JSON.serialize (response);
    }

    /** Created By: Arpit
     * Used to get field change order list
     * @parameter CORD_WrapperDef.FCO_Request, selectedColumns to be provided
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetFieldChangeOrdersList(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetFieldChangeOrdersList() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(request.selectedColumns != NULL && !request.selectedColumns.isEmpty()){
                    response = new CORD_ConsoleImpl().getFieldChangeOrdersList(request.selectedColumns);
            }
            else {
                    response.success = false;
                    response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRGetFieldChangeOrdersList', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetFieldChangeOrdersList() - exit;Success=' + response.success);
        }
        System.debug('final response===>'+JSON.serialize( response ));
        return JSON.serialize (response);
    }
    
    /** Created By: Arpit
     * Used to save field change order information
     * @parameter CORD_WrapperDef.FCO_Request, fieldChangeOrderInfo to be provided
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRSaveFieldChangeOrder(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRSaveFieldChangeOrder() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
             CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
             if(request.fieldChangeOrderInfo != NULL){
                response = new CORD_ConsoleImpl().saveFieldChangeOrder( request.fieldChangeOrderInfo );
            }
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRSaveFieldChangeOrder', BLANK_STRING);
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRSaveFieldChangeOrder() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    /** Created By: Arpit
     * Used to get products based on the provided search keyword
     * @parameter CORD_WrapperDef.FCO_Request, searchKeyword to be provided
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetRequiredParts(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetRequiredParts() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            String searchKeyword = String.isNotBlank(request.searchKeyword) ? request.searchKeyword.trim() : NULL;
            if(String.isNotBlank(searchKeyword)){
                response = new CORD_ConsoleImpl().getRequiredParts(searchKeyword);
            }
            else{
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRGetRequiredParts', BLANK_STRING);
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetRequiredParts() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }


    /** Created By: Arpit
     * Used to get picklist values requied on FCO creation Page.
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetPicklistValues(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetPicklistValues() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
          // response = new CORD_ConsoleImpl().getPicklistValues();
          response = new CORD_ConsoleImpl().getPicklistValues(request.fcoSfId);
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRGetPicklistValues', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetPicklistValues() - exit;Success=' + response.success);
        }
        return JSON.serialize( response );
       // return JSON.serialize (response);
    }

    /** Created By: Arpit
     * Used to delete FCO Record
     * @parameter CORD_WrapperDef.FCO_Request, fcoSfId to be provided
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRDeleteFieldChangeOrderRecords(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRDeleteChangeOrderRecords() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoSfId)){
                    response = new CORD_ConsoleImpl().deleteFieldChangeOrderRecords(request.fcoSfId);
            }
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {           
             createExceptionLogs(e, response, 'JSRDeleteChangeOrderRecords', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRDeleteChangeOrderRecords() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    /** Created By: Arpit
     * Used to clone FCO Record
     * @parameter CORD_WrapperDef.FCO_Request, fcoSfId to be provided
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRCloneFieldChangeOrderRecord(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRDeleteChangeOrderRecords() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoSfId)){
                response = new CORD_ConsoleImpl().cloneFieldChangeOrderRecord(request.fcoSfId);
            }
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRCloneFieldChangeOrderRecord', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRCloneFieldChangeOrderRecord() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    /** Created By: Arpit
     * Used to clone FCO Record
     * @parameter CORD_WrapperDef.FCO_Request, fcoId to be provided
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRSaveUserPreference(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRSaveUserPreference() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
                CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
                response = new CORD_ConsoleImpl().saveUserPreference(request.userPreference);
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRSaveUserPreference', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRSaveUserPreference() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }
    
    /** Created By: Arpit
     * Used to clone FCO Record
     * @parameter CORD_WrapperDef.FCO_Request, fcoId to be provided
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetSearchProductList(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetSearchProductList() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
                CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
                String searchKeyword = String.isNotBlank(request.searchKeyword) ? request.searchKeyword.trim() : NULL;
                if(String.isNotBlank(searchKeyword)){
                    response = new CORD_ConsoleImpl().getSearchProductList(request.searchKeyword, request.requestType);
                }
                else{
                    response.success = false;
                    response.message = Label.FCO001_TAG005; // value : Invalid Request.
                }
            }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRGetSearchProductList', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetSearchProductList() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    
/** Created By: Arpit
     * Used to get fields info of requested object
     * @parameter CORD_WrapperDef.FCO_Request, objectAPIName to be provided
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetFieldsInfo(String requestStr) {
        System.debug( LoggingLevel.DEBUG, 'JSRGetFieldsInfo() - enter;');
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.objectAPIName)){
                response = new CORD_ConsoleImpl().getFieldsInfo(request.objectAPIName);
            }
            else{
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        return JSON.serialize (response);
    }

     /** Created By: Arpit
     * Used to save search expression for the change order
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRSaveSearchExpression(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRSaveSearchExpression() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoSfId)){
                response = new CORD_ConsoleImpl().saveSearchExpression(request);
            }
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRSaveSearchExpression', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRSaveSearchExpression() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    /** Created By: Arpit
     * Used to get search result info of the change order
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetSearchResultInfo(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetSearchResultInfo() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoSfId)){ 
                response = new CORD_ConsoleImpl().getSearchResultInfo((request.fcoSfId));
            }
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRGetSearchResultInfo', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetSearchResultInfo() - exit;Success=' + response.success);
        }
        return response;
        //return JSON.serialize (response);
    }
    /** Created By: Arpit
     * Used to save search expression for the change order
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRCreateFCOLines(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRCreateFCOLines() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoSfId)){
                response = new CORD_ConsoleImpl().createFCOLines(request.fcoSfId);
            }
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRCreateFCOLines', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRCreateFCOLines() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    
    /** Created By: Arpit
     * Used to save search expression for the change order
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRSearchInstalledProduct(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRSearchInstalledProduct() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.productId) && String.isNotBlank(request.searchKeyword)){
                 response = new CORD_ConsoleImpl().searchInstalledProduct(request.productId, request.searchKeyword);
             }
             else {
                 response.success = false;
                 response.message = Label.FCO001_TAG005; // value : Invalid Request.
             }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRSearchInstalledProduct', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRSearchInstalledProduct() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

     /** Created By: Arpit
     * Used to save search expression for the change order
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRUpdateFCOLines(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRSearchInstalledProduct() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if((request.newRecordList != NULL || request.oldRecordList != NULL) && String.isNotBlank(request.fcoSfId)){
                List<SVMXC__SM_Change_Order_Line__c> oldRecordList = (List<SVMXC__SM_Change_Order_Line__c>) request.oldRecordList;
                List<SVMXC__SM_Change_Order_Line__c> newRecordList = (List<SVMXC__SM_Change_Order_Line__c>) request.newRecordList;
                response = new CORD_ConsoleImpl().updateFCOLines(oldRecordList, newRecordList, request.fcoSfId);
             }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRUpdateFCOLines', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRUpdateFCOLines() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    /** Created By: Arpit
     * Used to get FCO screen tab to be rendered
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetFCOScreen(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetFCOScreen() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoSfId)){
                response = new CORD_ConsoleImpl().getFCOScreen(request.fcoSfId);
            }
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRGetFCOScreen', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetFCOScreen() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    /** Created By: Arpit
     * Used to get custom labels
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns CORD_WrapperDef.FCO_Response
     */ 
    @RemoteAction
    public static Object JSRGetCustomLabels(String requestStr) {
        System.debug( LoggingLevel.INFO, 'getCustomLabels() - enter' );

        CORD_WrapperDef.FCO_Response response = new CORD_ConsoleImpl().getCustomLabels();
        return JSON.serialize (response);
    }

    
    /** Created By: Arpit
     * Used to get Work Order Information
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetWorkOrderInfo(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetFCOScreen() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoSfId)){
                response = new CORD_ConsoleImpl().getWorkOrderInfo(request.fcoSfId);
            }
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRGetWorkOrderInfo', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRGetWorkOrderInfo() - exit;Success=' + response.success);
        }
        return response;
        //return JSON.serialize (response);
    }

    
    /** Created By: Arpit
     * Used to get Work Order Information
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRCreateWorkOrders(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRCreateWorkOrders() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoSfId)){
                response = new CORD_ConsoleImpl().createWorkOrders(request.fcoSfId);
            }
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRCreateWorkOrders', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRCreateWorkOrders() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    /** Created By: Arpit
     * Used to get Work Order Information
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetTechAttributes(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'getTechAttributes() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
                response = new CORD_ConsoleImpl().getTechAttributes(request.recordIdList);
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'getTechAttributes', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechAttributes() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

     /** Created By: Arpit
     * Used to get Work Order Information
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */ 
    @RemoteAction
    public static Object JSRGetBatchLotFields(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetBatchLotFields() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
        response = new CORD_ConsoleImpl().getBatchLotFields(request.recordIdList);
        return JSON.serialize (response);
    }

     /** Created By: Arpit
     * Used to get Work Order Information
     * @parameter CORD_WrapperDef.FCO_Request
     * @return Returns Object
     */
    @RemoteAction
    public static Object JSRHasFcoHeaderUpdated(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRHasFcoHeaderUpdated() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            CORD_WrapperDef.FieldChangeOrderInfo fieldChangeOrderInfo = request.fieldChangeOrderInfo;
            if(fieldChangeOrderInfo != NULL && String.isNotBlank(fieldChangeOrderInfo.fcoSfId) && String.isNotBlank(fieldChangeOrderInfo.lastModifiedDate)){
                response = new CORD_ConsoleImpl().hasFcoHeaderUpdated(fieldChangeOrderInfo.fcoSfId, fieldChangeOrderInfo.lastModifiedDate);
            } 
            else {
                response.success = false;
                response.message = Label.FCO001_TAG005; // value : Invalid Request.
            }
        }
        catch( Exception e ) {
            createExceptionLogs(e, response, 'JSRHasFcoHeaderUpdated', BLANK_STRING);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'JSRHasFcoHeaderUpdated() - exit;Success=' + response.success);
        }
        return JSON.serialize (response);
    }

    


    @testvisible 
    private static void createExceptionLogs(Exception e, CORD_WrapperDef.FCO_Response response, String methodName, String customErrorMsg){
        response.success = false;
        response.message = String.isBlank(customErrorMsg) ? e.getMessage() : customErrorMsg;
        System.debug('Error==>'+ e.getMessage());
        System.debug( LoggingLevel.ERROR, methodName + ' Failed;  Error=' + e.getStackTraceString() );
    
    }
    
}