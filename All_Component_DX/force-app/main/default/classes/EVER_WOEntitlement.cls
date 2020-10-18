/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The EVER_WOEntitlement is controller class for Manual Entitlement Page, which 
 * handles the remote calls for various Services implemented.
 * 
 *
 * @author Sachin S
 * @version 
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Sachin S               01 Mar 2016     Created.
 *****************************************************************************************************/
global with sharing class EVER_WOEntitlement {
    
    /**
     * To get all the Default Settings for Manual Entitlement based on which the 
     * Entitlement Check has to be performed.
     */
    @RemoteAction
    global static Object getWOEntitlementSettings () {
        EVER_WrapperDef.EVER_Response response = new EVER_WOEntitlementImpl().getWOEntitlementSettings();
        System.debug(logginglevel.Info, 'getWOEntitlementSettings() - Response : ' + response);
        return JSON.serialize(response);
    }
    
    
    /** 
     * To get the Work Order and related Product Serviced Line details for which Manual 
     * Entitlement to be performed.
     */
    @RemoteAction
    global static Object getWorkOrderDetails (String requestStr) {
        System.debug(logginglevel.Info, 'getWorkOrderDetails() - Request String : ' + requestStr);
        EVER_WrapperDef.EVER_Request request = (EVER_WrapperDef.EVER_Request) JSON.deserialize (requestStr, EVER_WrapperDef.EVER_Request.Class);
        EVER_WrapperDef.EVER_Response response = new EVER_WOEntitlementImpl().getWorkOrderDetails(request);
        System.debug(logginglevel.Info, 'getWorkOrderDetails() - Response : ' + response);
        return JSON.serialize(response);
    }   

    /**
     * To get all the qualified Service Contracts/Warranties available for the WorkOrder/Product Line
     * based on the user provided Settings/Filter.
     */
    @RemoteAction
    global static Object checkEntitlement (String requestStr){
        System.debug(logginglevel.info, 'checkEntitlement() - Request : ' + requestStr);
        EVER_WrapperDef.EVER_Request request = (EVER_WrapperDef.EVER_Request) JSON.deserialize (requestStr, EVER_WrapperDef.EVER_Request.Class);
        EVER_WrapperDef.EVER_Response response = new EVER_WOEntitlementImpl().checkEntitlement(request);
        System.debug(logginglevel.info, 'checkEntitlement() - Response : ' + response);
        return JSON.serialize(response);

    }

    /**
     * To update the Service Contract/Warranty info on the Work order/Product Line based on User selection
     */    
    @RemoteAction
    global static Object saveEntitlement(String requestStr){
        System.debug(logginglevel.info, 'saveEntitlementInfo() - request : ' + requestStr);
        EVER_WrapperDef.EVER_Request request = (EVER_WrapperDef.EVER_Request) JSON.deserialize (requestStr, EVER_WrapperDef.EVER_Request.Class);
        EVER_WrapperDef.EVER_Response response = new EVER_WOEntitlementImpl().saveEntitlementInfo(request);
        System.debug(logginglevel.info, 'saveEntitlementInfo() - response : ' + response);
        return JSON.serialize(response);        
    }

    /**
     * To fetch Entitlement History Records for the given Work Order or PS Line
     */    
    @RemoteAction
    global static Object getEntitlementHistory(String requestStr){
        System.debug(logginglevel.info, 'getEntitlementHistory() - request : ' + requestStr);
        EVER_WrapperDef.EVER_Request request = (EVER_WrapperDef.EVER_Request) JSON.deserialize (requestStr, EVER_WrapperDef.EVER_Request.Class);
        EVER_WrapperDef.EVER_Response response = new EVER_WOEntitlementImpl().getEntitlementHistory(request);
        System.debug(logginglevel.info, 'getEntitlementHistory() - response : ' + response);
        return JSON.serialize(response);        
    }


}