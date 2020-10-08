/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The APFT_WrapperDef implements wrapper request and response structures.
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
global with sharing class APFT_WrapperDef {

    global class ObjectInfo implements Comparable {
    
        public String label;
        public String name;
        
        public ObjectInfo() {}
        
        /**
         * @brief Defining Comparable interface method to support object level sorting.
         * 
         * @param compareTo object to be compared with this object instance.
         * 
         * @return Returns 0 if equal, 1 if this instance is greter and -1 if this instance is less.
         */
        global Integer compareTo( Object compareTo ) {
            
            if( compareTo != null && compareTo instanceof ObjectInfo ) {
                
                ObjectInfo compareToObjectInfo = (ObjectInfo) compareTo;
                if( compareToObjectInfo != this ) {
                    
                    if (label == compareToObjectInfo.label) return 0;
			        if (label > compareToObjectInfo.label) return 1;
			        return -1;
                }
                return 0;
            }
            return -1;
        }
    }
    
    global class APFT_FilterInfo implements Comparable {
        
        webservice String name {set; get;}        
        webservice String processId {set; get;}  
        webservice String description {set; get;}
        
        webservice Boolean onlineEnabled {set; get;}
        webservice Boolean iPadEnabled {set; get;}
        webservice Boolean androidTabletEnabled {set; get;}
        webservice Boolean windowsEnabled {set; get;}
        webservice Boolean iPhoneEnabled {set; get;}
        webservice Boolean androidPhoneEnabled {set; get;}
        
        webservice List<APFT_FilterInfo> filterInfoList = new List<APFT_FilterInfo>();
        
        global APFT_FilterInfo() {
            
            onlineEnabled = false;
            iPadEnabled = false;
            androidTabletEnabled = false;
            windowsEnabled = false;
            iPhoneEnabled = false;
            androidPhoneEnabled = false;
        }
        
        global Integer compareTo( Object compareTo ) {
            
            if( compareTo != null && compareTo instanceof APFT_FilterInfo ) {
                
                APFT_FilterInfo compareToFilterInfo = (APFT_FilterInfo) compareTo;
                if( compareToFilterInfo != this ) {
                    
                    if (processId == compareToFilterInfo.processId) return 0;
			        if (processId > compareToFilterInfo.processId) return 1;
			        return -1;
                }
                return 0;
            }
            return -1;
        }
    }
    
    global class APFT_Request {
    
        webservice String recordTypeName {set; get;}
        webservice String sourceObjectName {set; get;}
        
        webservice Datetime lastModifiedOn {set; get;}
        
        webservice List<APFT_FilterInfo> filterInfoList = new List<APFT_FilterInfo>();
       
        global APFT_Request() {}
    }
    
    global class APFT_Response {

        webservice Boolean success {set; get;}
        webservice Boolean warning {set; get;}
        webservice String message {set; get;}
        
        webservice Datetime lastModifiedOn {set; get;}
        
        webservice List<ObjectInfo> objectInfoList = new List<ObjectInfo>();
        webservice List<APFT_FilterInfo> filterInfoList = new List<APFT_FilterInfo>();
        
        global APFT_Response() {            
            success = true; warning = false;
        }
    }
}