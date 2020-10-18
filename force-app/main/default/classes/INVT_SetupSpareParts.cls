/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/** 
 * The INVT_SetupSpareParts is controller class for Create Spare Parts configuration setup, which 
 * handles the remote calls for various Services implemented.
 * 
 *
 * @author Anchal
 * @version 39
 * @since 2017
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Anchal               7 June 2017       Created.
 *****************************************************************************************************/
global with sharing class INVT_SetupSpareParts {


    @RemoteAction
    global static Object getSparePartsProfile (String requestStr) {
        System.debug(logginglevel.info, 'profile() - Request : ' + requestStr);
        INVT_SpareParts_Wrapper.SpareParts_Request request = (INVT_SpareParts_Wrapper.SpareParts_Request) JSON.deserialize (requestStr, INVT_SpareParts_Wrapper.SpareParts_Request.Class);
        
        INVT_SpareParts_Wrapper.SpareParts_Response response = new INVT_SetupSparePartsImpl().getProfileDetails(request);
        System.debug(logginglevel.Info, 'getProfileDetails() - Response : ' + response);
        return JSON.serialize(response);
    }
    
    @RemoteAction
    global static Object getSparePartConfig (String requestStr) {
        System.debug(logginglevel.info, 'Spare part cofig() - Request : ' + requestStr);
        INVT_SpareParts_Wrapper.SpareParts_Request request = (INVT_SpareParts_Wrapper.SpareParts_Request) JSON.deserialize (requestStr, INVT_SpareParts_Wrapper.SpareParts_Request.Class);
        
        INVT_SpareParts_Wrapper.SpareParts_Response response = new INVT_SetupSparePartsImpl().getSparePartConfig(request);
        System.debug(logginglevel.Info, 'getProfileDetails() - Response : ' + response);
        return JSON.serialize(response);
    }
    
    @RemoteAction
    global static Object saveSparePartConfig (String requestStr) {
        System.debug(logginglevel.info, 'Spare part save() - Request : ' + requestStr);
        INVT_SpareParts_Wrapper.SpareParts_Request request = (INVT_SpareParts_Wrapper.SpareParts_Request) JSON.deserialize (requestStr, INVT_SpareParts_Wrapper.SpareParts_Request.Class);
        
        INVT_SpareParts_Wrapper.SpareParts_Response response = new INVT_SetupSparePartsImpl().saveSparePartConfig(request);
        System.debug(logginglevel.Info, 'Spare Part save - Response : ' + response);
        return JSON.serialize(response);
    }
}