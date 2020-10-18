/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The CONF_ApplicationFilters implements methods to retrieve/save list of objects used 
 * in SFW, SFW and Custom Actions and associated application filter configurations. This 
 * class internally calls CONF_ApplicationFiltersImpl methods to get the response.
 * 
 *
 * @author Ramachandra Mohan
 * @version 16.39000
 * @since 2016
 */
/*****************************************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      13 May 2016     Created. 
 *****************************************************************************************************/

global with sharing class CONF_ApplicationFilters {
    
    /**
     * Inner class which holds response structure.
     */
    public class Output {
    
        public Boolean success = true;
        public Boolean warning = false;
        public String message;
        
        public Datetime lastModifiedOn;
        
        public List<APFT_WrapperDef.ObjectInfo> objectInfoList = new List<APFT_WrapperDef.ObjectInfo>();
        public List<APFT_WrapperDef.APFT_FilterInfo> filterInfoList = new List<APFT_WrapperDef.APFT_FilterInfo>();
        
        public Output() {}
    }
    
	/**
	 * @brief This method is used to retrieve list of supported device types.
	 * 
	 * @param requestString NOT IN USE
	 * 
	 * @return Returns list of supported devuce types as json string.
	 */    
    @RemoteAction
    global static Object getSupportedRecordTypes( String requestString ) {
        
        System.debug(LoggingLevel.DEBUG, 'getSupportedRecordTypes() - enter; requestString= ' + requestString );
        
        Output result = new Output();        
        
        try {
            // Retrieving supported device from implementation class.
            APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getSupportedRecordTypes();
            
            result.success = response.success;
            result.warning = response.warning;
            result.message = response.message;
            result.objectInfoList = response.objectInfoList;
        }
        catch( Exception ex) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            result.success = false;            
            result.message = System.Label.APFT001_TAG006;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSupportedRecordTypes() - exit; result= ' + result );            
        }
        
        return JSON.serialize( result );
    }
    
    /**
     * @brief This method is used to retrieve all source object names for requested process type.
     * 
     * @param requestString Process type for which source object list to be retrieved.
     * 
     * @return Returns list of source object names for given process type.
     */
    @RemoteAction
    global static Object getAllSourceObjects( String requestString ) {
        
        System.debug(LoggingLevel.DEBUG, 'getAllSourceObjects() - enter; requestString= ' + requestString );
        
        Output result = new Output();        
        
        try {
            
            if( requestString != null ) {
                
                APFT_WrapperDef.APFT_Request request = (APFT_WrapperDef.APFT_Request) JSON.deserialize( requestString, APFT_WrapperDef.APFT_Request.class );            
                APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getAllSourceObjects(request);
                
                result.success = response.success;
                result.warning = response.warning;
                result.message = response.message;
                result.objectInfoList = response.objectInfoList;    
            } else {
                
                result.success = false;            
                result.message = System.Label.APFT001_TAG010;            
            }
        }
        catch( JSONException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            result.success = false;            
            result.message = System.Label.APFT001_TAG010;
        }
        catch( Exception ex) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            result.success = false;            
            result.message = System.Label.APFT001_TAG006;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllSourceObjects() - exit; result= ' + result );            
        }
        
        return JSON.serialize( result );
    }
    
    @RemoteAction
    global static Object getApplicationFilter( String requestString ) {
        
        System.debug(LoggingLevel.DEBUG, 'getApplicationFilter() - enter; requestString= ' + requestString );
        
        Output result = new Output();
        
        try {
            
            if( requestString != null ) {
                
                APFT_WrapperDef.APFT_Request request = (APFT_WrapperDef.APFT_Request) JSON.deserialize( requestString, APFT_WrapperDef.APFT_Request.class );
                APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().getApplicationFilter(request);
                
                result.success = response.success;
                result.warning = response.warning;
                result.message = response.message;
                result.lastModifiedOn = response.lastModifiedOn;
                result.filterInfoList = response.filterInfoList;
            } else {
                
                result.success = false;            
                result.message = System.Label.APFT001_TAG010;            
            }
        }
        catch( JSONException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            result.success = false;            
            result.message = System.Label.APFT001_TAG010;
        }
        catch( Exception ex) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            result.success = false;            
            result.message = System.Label.APFT001_TAG006;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getApplicationFilter() - exit; result= ' + result );
        }
        
        return JSON.serialize( result );
    }
    
    @RemoteAction
    global static Object saveApplicationFilter( String requestString ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveApplicationFilter() - enter; requestString=' + requestString );
        
        Output result = new Output();
        try {
            
            if( requestString != null ) {
                
                APFT_WrapperDef.APFT_Request request = (APFT_WrapperDef.APFT_Request) JSON.deserialize( requestString, APFT_WrapperDef.APFT_Request.class );            
                APFT_WrapperDef.APFT_Response response = new CONF_ApplicationFiltersImpl().saveApplicationFilter(request);
                
                result.success = response.success;
                result.warning = response.warning;
                result.message = response.message;
                result.lastModifiedOn = response.lastModifiedOn;
            } else {
                
                result.success = false;            
                result.message = System.Label.APFT001_TAG010;            
            }
        }
        catch( JSONException ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            result.success = false;
            result.message = System.Label.APFT001_TAG010;
        }
        catch( Exception ex) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
            
            result.success = false;            
            result.message = System.Label.APFT001_TAG006;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'saveApplicationFilter() - exit; result= ' + result );
        }
        
        return JSON.serialize( result );
    }
    
    public CONF_ApplicationFilters(){}
}