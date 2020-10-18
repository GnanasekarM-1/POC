/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/** 
 * The CONF_TriggerSetting is controller class for to manage Trigger enable & disable functionality, which 
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
 *              Anchal               31 July 2017       Created.
 *****************************************************************************************************/
 
 global with sharing class CONF_TriggerSetting {


    @RemoteAction
    global static Object getObjectName (String requestStr) {
        System.debug(logginglevel.info, 'Object Name() - Request : ' + requestStr);
        CONF_TriggerSettingImpl.TriggerSetting_Request request = (CONF_TriggerSettingImpl.TriggerSetting_Request) JSON.deserialize (requestStr, CONF_TriggerSettingImpl.TriggerSetting_Request.Class);
        
        CONF_TriggerSettingImpl.TriggerSetting_Response response = new CONF_TriggerSettingImpl().getObjectName(request);
        System.debug(logginglevel.Info, 'getObjectName() - Response : ' + response);
        return JSON.serialize(response);
    }
    
    @RemoteAction
    global static Object getObjectTrigger(String requestStr) {
        System.debug(logginglevel.info, 'Object Trigger - Request : ' + requestStr);
        CONF_TriggerSettingImpl.TriggerSetting_Request request = (CONF_TriggerSettingImpl.TriggerSetting_Request) JSON.deserialize (requestStr, CONF_TriggerSettingImpl.TriggerSetting_Request.Class);
        
        CONF_TriggerSettingImpl.TriggerSetting_Response response = new CONF_TriggerSettingImpl().getObjectTrigger(request);
        System.debug(logginglevel.Info, 'Object Trigger - Response : ' + response);
        return JSON.serialize(response);
    }
    
    @RemoteAction
    global static Object saveTriggerSetting(String requestStr) {
        System.debug(logginglevel.info, 'Save Setting - Request : ' + requestStr);
        CONF_TriggerSettingImpl.TriggerSetting_Request request = (CONF_TriggerSettingImpl.TriggerSetting_Request) JSON.deserialize (requestStr, CONF_TriggerSettingImpl.TriggerSetting_Request.Class);
        
        CONF_TriggerSettingImpl.TriggerSetting_Response response = new CONF_TriggerSettingImpl().saveTriggerSetting(request);
        System.debug(logginglevel.Info, 'Save Setting  - Response : ' + response);
        return JSON.serialize(response);
    }
}