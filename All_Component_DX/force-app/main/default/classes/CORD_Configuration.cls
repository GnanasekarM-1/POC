/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is used to interact directly with Visualforce Page. This class 
 * also has definition for all available JSR methods required for FCO Configuration. 
 *
 * @author Nidhi Hegde
 * @version 20.2
 * @since 2020
 */
 
public with sharing class CORD_Configuration {
    @RemoteAction
    public static Object JSRGetFCOConfigurationList(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetFCOConfigurationList() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            response = new CORD_ConfigurationImpl().getFCOConfigurationList();
        }
        catch( Exception e ) {
            
            response.success = false;
            response.message = e.getMessage();
        }
        return JSON.serialize( response );  
    } 
    
    @RemoteAction
    public static Object JSRDeleteFCOConfig(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRDeleteFCOConfig() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
        CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoConfigId)){
                response = new CORD_ConfigurationImpl().deleteFCOConfiguration(request);
            }
        }
        catch( Exception e ) {
            response.success = false;
            response.message = e.getMessage();
        }
        return JSON.serialize( response );  
    }
    
    @RemoteAction
    public static Object JSRCloneFCOConfig(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRCloneFCOConfig() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
        CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoConfigId)){
                response = new CORD_ConfigurationImpl().cloneFCOConfiguration(request);
            }
        }
        catch( Exception e ) {
            response.success = false;
            response.message = e.getMessage();
        }
        return JSON.serialize( response );  
    }
    @RemoteAction
    public static Object JSRGetConfigData(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetConfigData() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
        CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );
            if(String.isNotBlank(request.fcoConfigId)){
                response = new CORD_ConfigurationImpl().getConfigData(request);
            }
        }
        catch( Exception e ) {
            response.success = false;
            response.message = e.getMessage();
        }
        return JSON.serialize( response );  
    }
    @RemoteAction
    public static Object JSRSaveConfigData(String requestStr) {        
        System.debug( LoggingLevel.DEBUG, 'JSRSaveConfigData() - enter;'+requestStr);        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
        CORD_WrapperDef.FCO_Request request = (CORD_WrapperDef.FCO_Request) JSON.deserialize( requestStr, CORD_WrapperDef.FCO_Request.Class );         
        System.debug('request=='+request);   
        if(request.configurationInfo != null){
            response = new CORD_ConfigurationImpl().saveConfigData(request);
        }
        }
        catch( Exception e ) {
            response.success = false;
            response.message = e.getMessage();
        }
        return JSON.serialize( response );  
    }
    
    @RemoteAction
    public static Object JSRGetProcessData(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetProcessData() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            response = new CORD_ConfigurationImpl().getProcessData();            
        }
        catch( Exception e ) {
            response.success = false;
            response.message = e.getMessage();
        }
        return JSON.serialize( response );  
    }
    
    @RemoteAction
    public static Object JSRGetProfileData(String requestStr) {
        
        System.debug( LoggingLevel.DEBUG, 'JSRGetProfileData() - enter;');
        
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            response = new CORD_ConfigurationImpl().getProfileData();            
        }
        catch( Exception e ) {
            response.success = false;
            response.message = e.getMessage();
        }
        return JSON.serialize( response );  
    }
    
    @RemoteAction
    public static Object JSRGetCustomLabels(String request) {
        System.debug( LoggingLevel.DEBUG, 'JSRGetCustomLabels() - enter;');
        CORD_WrapperDef.FCO_Response response = new CORD_WrapperDef.FCO_Response();
        try {
            response = new CORD_ConfigurationImpl().getCustomLabels();
        }
        catch( Exception e ) {
            response.success = false;
            response.message = e.getMessage();
        }
        return JSON.serialize( response );  
    }
   
}