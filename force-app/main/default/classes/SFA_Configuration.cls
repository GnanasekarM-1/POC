/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * The SFA_Configuration provides methods to retrieve list of Service Flow Automation
 * Processes. Also, it provides method to save, edit and delete SFA processes.
 *
 *
 * @author Manish Kushwah
 * @version 19.2
 * @since 2019
 */
/*****************************************************************************************************
 *   Name                   Date              Comment
 *****************************************************************************************************
 *   Manish Kushwah         20 March 2019     Created.
 *****************************************************************************************************/

global with sharing class SFA_Configuration {

    @RemoteAction
    global static Object JsrGetSFAProcessList(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetListOfProcesses(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.lstSFAProcesses;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetSFAProcessInfo(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetProcessInfo(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.objSFAProcessInfo;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrDeleteProcess(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_DeleteProcess(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = null;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrSaveProcess(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_SaveProcess(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = null;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetExpressionDetails(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetExpressionDetails(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.objExpression;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetFieldList(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetFieldList(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.lstItemListInformation[0].lstFieldList;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetSFMList(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetSFMList(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.objItemListInformation.lstSFM;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetCustomActionList(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetCustomActionList(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.objItemListInformation.lstSFM;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetFilterList(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetFilterList(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.objItemListInformation.lstFilterList;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetGroupProfileList(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetGroupProfileList(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.objItemListInformation.lstGroupProfile;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetFieldsOfLookupToObject(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetFieldsOfLookupToObject(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.objItemListInformation.lstFieldList;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetObjectList(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetObjectList(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.objItemListInformation.lstObject;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetCustomLabels(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetCustomLabels(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.lstCustomLabel;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetFieldListByDataType(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetFieldListByDataType(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.lstItemListInformation;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }
    @RemoteAction
    global static Object JsrGetUserInfo(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetUserInfo(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.objUserInfo;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }

    @RemoteAction
    global static Object JsrGetRelatedList(String requestStr){
        SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest objRequest = (SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest)JSON.deserialize(requestStr, SVMXC.SFA_WrapperDef.SFA_ConfigurationRequest.class);
        SFA_WrapperDef.SFA_ConfigurationResponse response  = new SVMXC.SFA_ConfigurationUtility().SFA_GetRelatedListToObject(objRequest);
        SFA_WrapperDef.SFA_RestResponse objSFA_RestResponse =  new SFA_WrapperDef.SFA_RestResponse();
        objSFA_RestResponse.data = response.lstItemListInformation;
        objSFA_RestResponse.success = response.success;
        objSFA_RestResponse.message = response.message;
        return JSON.serialize(objSFA_RestResponse);
    }
}