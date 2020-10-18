/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * This class implements utility methods commanly used by Timesheet Manager 
 * and Engine.
 *
 * @author Ramachandra Mohan
 * @version 15.39100
 * @since 2015
 */
/**************************************************************************************************
 *    ID        Name                   Date            Comment
 **************************************************************************************************
 *              Ramachandra Mohan      02 Apr 2015     Created. 
 * 018852       Ramachandra Mohan      10 Jul 2015     Implemented new method to retrieve all 
 *                                                     available timezones, getAllTimezones()
 *              Ramachandra Mohan      31 Mar 2016     Security fixes.
 *              Sourabh Singh          19 Dec 2016     BAC-1276:support prior timesheet autofill
 **************************************************************************************************/
public with sharing class TMST_TimesheetUtils  {

    /* Private Map instance variable to hold tag name vs Tag info object mapping.*/
    private Map<String,TagInfo> timesheetTags = new Map<String,TagInfo>();
    
    /* Private Map instance variable to hold id vs list of tag info object mapping.*/
    private Map<Id, List<TagInfo>> loggingMap = new Map<Id, List<TagInfo>>();
    
    private List<BusinessHours> businessHoursList = new List<BusinessHours>();
    
    /* Inner immutable class to used to create tag name and tag description data.*/
    class TagInfo {
    
        private String tagName;
        private String tagValue;
        
        /* Class constructor to create instance of this class with tag name and tag description. */
        public TagInfo( String tagName, String tagValue ) {
        
            this.tagName = tagName;
            this.tagValue = tagValue;
        }
        
        /* Method to get tag value(description). */
        public String getTagValue() {
            return tagValue;
        }
        
        /* Method to get tag name. */
        public String getTagName() {
            return tagName;
        }
    }
    
    /**
     * This static method is used to get instance of this class.
     *
     * @return Returns instance of TMST_TimesheetUtils class.
     */
    public static TMST_TimesheetUtils getInstance() {
        return instance;
    }
    
    /**
     * This method is used to get tag value for given tag name.
     *
     * @param tagName Tag name for which value needs to be returned.
     * @return Returns tag value for specified tag name, If tag name not exists, 
     *         then returns empty string.
     */
    public String getTagValue( String tagName ) {
    
        if( !timesheetTags.containsKey( tagName ) ) {
        
            System.debug( LoggingLevel.ERROR, 'Invalid label name ' + tagName );
            return '';
        }
        
        return timesheetTags.get( tagName ).getTagValue();
    }
    
    /**
     * This method is used to cache tags for specified id. This internally 
     * creates id vs list of tag map.
     *
     * @param objectId SObject id for which tag name needs to be cached.
     * @param tagName Valid tag name to be mapped to specified SObject Id.
     */
    public void cacheTag( Id objectId, String tagName ) {
    
        /* Update the map only if requested tagName is valid. */
        if( timesheetTags.containsKey( tagName ) ) {
        
            /* Create list of taginfo object if not exists in cache map. */
            if( !loggingMap.containsKey( objectId ) ) {
                loggingMap.put( objectId, new List<TagInfo>() );
            }
            
            loggingMap.get( objectId ).add( timesheetTags.get( tagName ) );
        }
    }
    
    /**
     * This method is used to build string from cached tags.
     * 
     * @param objectId SObject id for which list of tags needs to be returned as string.
     * @param additionalInfoMap Map to add any additional info for each tag.
     * @param separator Seperator used to build list of tags.
     *
     * @return Return string from cached tag list. 
     */
    public String buildStringFromCache( Id objectId, Map<String,String> additionalInfoMap, String separator ) {
        
        String message = '';
        
        if( separator == null ) separator = TMST_Consts.NEWLINE;
        
        if( loggingMap.containsKey( objectId ) ) {
        
            List<TagInfo> tagInfoList = loggingMap.get( objectId );
            for( TagInfo info : tagInfoList ) {
            
                if( message.length() != 0 ) {
                    message += separator;
                }
                
                message += info.getTagValue();
                
                if( additionalInfoMap != null && additionalInfoMap.containsKey( info.getTagName() ) ) {
                    message += additionalInfoMap.get( info.getTagName() );
                }
            }
        }
        
        return message;
    }
    
    public String buildString( List<String> stringList, String separator ) {
    
        String resultString = '';
        
        if( stringList != null && separator != null ) {
        
            for( String str : stringList ) {
            
                if( str != null ) {
                
                    if( !resultString.equals('') ) resultString += separator;
                    resultString += str;
                }
            }
        }
        
        return resultString;
    }
    
    public TMST_WrapperDef.TMST_Response getAllTimezones() {
    
        System.debug( LoggingLevel.DEBUG, 'getAllTimezones() - enter' );        
        
        TMST_WrapperDef.TMST_Response response = new TMST_WrapperDef.TMST_Response();
        List<TMST_WrapperDef.ObjectInfo> timezoneList = new List<TMST_WrapperDef.ObjectInfo>();
        
        Schema.DescribeFieldResult timezoneDescribe = User.TimeZoneSidKey.getDescribe();
        List<Schema.PicklistEntry> picklistEntryList = timezoneDescribe.getPicklistValues();
    
        for(Schema.PicklistEntry picklistEntry : picklistEntryList ) {
            
            TMST_WrapperDef.ObjectInfo timezoneInfo = new TMST_WrapperDef.ObjectInfo();
            timezoneInfo.Id = picklistEntry.getValue();            
            timezoneInfo.name = picklistEntry.getLabel();
            
            timezoneList.add(timezoneInfo);
        }
        
        response.timezoneList = timezoneList;
        
        return response;
    }
    
    /**added BAC-1276:19Dec2016:Sourabh
      Returns the picklist values for given object and picklist field name in response object
    */
    public TMST_WrapperDef.TMST_Response getPickValues(String object_name, String field_name) 
        {   
        System.debug( LoggingLevel.DEBUG, 'getPickValues() - enter:Objname='+object_name+' , fieldName='+field_name );     
        Schema.SObjectType sobject_type = Schema.getGlobalDescribe().get(object_name);
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> picklistEntryList = field_map.get(field_name).getDescribe().getPickListValues();
        TMST_WrapperDef.TMST_Response response = new TMST_WrapperDef.TMST_Response();

     /**
        Please add similar if block for every new object and picklist field you call the getPickValues method for
        Note that you need to define the required variables in TMST_WrapperDef class as well 
     */
        if(object_name =='SVMXC__ServiceMax_Config_Data__c' && field_name == 'SVMXC__SM_Prior_Timesheet_Periods__c')
            {
                List<TMST_WrapperDef.ObjectInfo> priorPeriodList = new List<TMST_WrapperDef.ObjectInfo>();       
                for(Schema.PicklistEntry picklistEntry : picklistEntryList ) 
                {    
                    TMST_WrapperDef.ObjectInfo priorPeriodInfo = new TMST_WrapperDef.ObjectInfo();
                    priorPeriodInfo.Id = picklistEntry.getValue();            
                    priorPeriodInfo.name = picklistEntry.getLabel();          
                    priorPeriodList.add(priorPeriodInfo);
                }        
                response.priorPeriodList = priorPeriodList;
            }
        return response;
    }

    public TMST_WrapperDef.TMST_Response getBusinessHours() {
    
        System.debug( LoggingLevel.DEBUG, 'getBusinessHours() - enter' );        
        
        TMST_WrapperDef.TMST_Response response = new TMST_WrapperDef.TMST_Response();
        
        if( businessHoursList.isEmpty() ) {
            
            List<String> queryFields = new List<String> {'Id','Name'};
            if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'BusinessHours', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
                throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
            }
            
            businessHoursList = [SELECT Id,Name FROM BusinessHours WHERE IsActive = true];
        }
        
        response.businessHoursList = businessHoursList;
        
        return response;
    }
    
    public TMST_WrapperDef.TMST_Response getWorkDetailOwnership() {
    
        System.debug( LoggingLevel.DEBUG, 'getBusinessHours() - enter' );        
        
        TMST_WrapperDef.TMST_Response response = new TMST_WrapperDef.TMST_Response();
    
        Map<String, Schema.SObjectField> workDetailFieldsMap = Schema.SObjectType.SVMXC__Service_Order_Line__c.fields.getMap();
        for( Schema.SObjectField field: workDetailFieldsMap.values() ) {
        
            if( field.getDescribe().getType() == Schema.DisplayType.Reference ) {
            
                List<Schema.SObjectType> objectType = field.getDescribe().getReferenceTo();
                if( String.valueOf( objectType[0] ).equalsIgnoreCase( 'SVMXC__SERVICE_GROUP_MEMBERS__C' ) || 
                    String.valueOf( objectType[0] ).equalsIgnoreCase( 'User' ) ) {
                    
                    TMST_WrapperDef.TMST_WorkDetailOwnership workDetailOwnership = new TMST_WrapperDef.TMST_WorkDetailOwnership();
                    workDetailOwnership.labelName = field.getDescribe().getLabel();
                    workDetailOwnership.apiName = field.getDescribe().getName();
                    /*
                    if( workDetailOwnership.apiName != null && workDetailOwnership.apiName.startsWith( TMST_Consts.NAMESPACE ) ) {
                        workDetailOwnership.apiName = workDetailOwnership.apiName.substring( TMST_Consts.NAMESPACE.length() );
                    }
                    */
                    response.workDetailOwnershipList.add(workDetailOwnership);
                }
            }
        }
        return response;
    }
    
    public TMST_WrapperDef.TMST_Response getObjectMappingAndSVMXRules () {
    
        System.debug( LoggingLevel.DEBUG, 'getBusinessHours() - enter' );        
        
        TMST_WrapperDef.TMST_Response response = new TMST_WrapperDef.TMST_Response();
        
        List<String> queryFields = new List<String> {'Id','SVMXC__Name__c', 'SVMXC__Record_Type_Name__c', 'SVMXC__Source_Object_Name__c', 'SVMXC__Target_Object_Name__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__ServiceMax_Processes__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
        
        for( SVMXC__ServiceMax_Processes__c process : [SELECT Id,SVMXC__Name__c, SVMXC__Record_Type_Name__c, SVMXC__Source_Object_Name__c, SVMXC__Target_Object_Name__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Source_Object_Name__c IN ( 'Event', 'Task', 'SVMXC__Service_Order_Line__c', 'SVMXC__SVMX_Event__c' ) AND ( SVMXC__Record_Type_Name__c = 'SVMX Rule' OR ( SVMXC__Record_Type_Name__c = 'Object Mapping' AND SVMXC__Target_Object_Name__c = 'SVMXC__Timesheet_Entry__c' ) ) ] ) {
            
            TMST_WrapperDef.ObjectInfo info = new TMST_WrapperDef.ObjectInfo();
            info.Id = process.Id;
            info.name = process.SVMXC__Name__c;
            
            if( process.SVMXC__Name__c != null &&  !process.SVMXC__Name__c.trim().equalsIgnorecase('') ) {
            
                if( process.SVMXC__Record_Type_Name__c.equalsIgnoreCase( 'Object Mapping' ) ) {
                    if( process.SVMXC__Source_Object_Name__c.equalsIgnoreCase( 'SVMXC__Service_Order_Line__c' ) ) {
                        response.workDetailsMappingList.add( info );
                    } else if( process.SVMXC__Source_Object_Name__c.equalsIgnoreCase( 'Task' ) ) {
                        response.taskMappingList.add( info );
                    } else if( process.SVMXC__Source_Object_Name__c.equalsIgnoreCase( 'Event' ) ) {
                        response.eventMappingList.add( info );
                    } else if( process.SVMXC__Source_Object_Name__c.equalsIgnoreCase( 'SVMXC__SVMX_Event__c' ) ) {
                        response.servicemaxEventMappingList.add( info );
                    }                 
                } else if( process.SVMXC__Record_Type_Name__c.equalsIgnoreCase( 'SVMX Rule' ) ) {
                    if( process.SVMXC__Source_Object_Name__c.equalsIgnoreCase( 'SVMXC__Service_Order_Line__c' ) ) {
                        response.workDetailsRuleList.add( info );
                    } else if( process.SVMXC__Source_Object_Name__c.equalsIgnoreCase( 'Task' ) ) {
                        response.taskRuleList.add( info );
                    } else if( process.SVMXC__Source_Object_Name__c.equalsIgnoreCase( 'Event' ) ) {
                        response.eventRuleList.add( info );
                    } else if( process.SVMXC__Source_Object_Name__c.equalsIgnoreCase( 'SVMXC__SVMX_Event__c' ) ) {
                        response.servicemaxEventRuleList.add( info );
                    }
                }
            }
        }
        
        return response;
    }
    //Added for BAC-5411
    public static Map<String,String> getStatusPickListValue(){
        Map<String,String> retVal = new Map<String,String>();
            
        Schema.DescribeFieldResult fieldResult = SVMXC__Timesheet__c.SVMXC__Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry fVal : ple)
            {
               retVal.put(fVal.getValue(), fVal.getLabel());
            }       
        return retVal;
    }
    //End for BAC-5411
    private TMST_TimesheetUtils () {
        initTimesheetTags();
    }
    
    private void initTimesheetTags() {
    
        timesheetTags.put( TMST_Consts.TMST001_TAG001, new TagInfo( TMST_Consts.TMST001_TAG001, System.label.TMST001_TAG001 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG002, new TagInfo( TMST_Consts.TMST001_TAG002, System.label.TMST001_TAG002 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG003, new TagInfo( TMST_Consts.TMST001_TAG003, System.label.TMST001_TAG003 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG004, new TagInfo( TMST_Consts.TMST001_TAG004, System.label.TMST001_TAG004 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG005, new TagInfo( TMST_Consts.TMST001_TAG005, System.label.TMST001_TAG005 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG006, new TagInfo( TMST_Consts.TMST001_TAG006, System.label.TMST001_TAG006 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG007, new TagInfo( TMST_Consts.TMST001_TAG007, System.label.TMST001_TAG007 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG008, new TagInfo( TMST_Consts.TMST001_TAG008, System.label.TMST001_TAG008 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG009, new TagInfo( TMST_Consts.TMST001_TAG009, System.label.TMST001_TAG009 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG010, new TagInfo( TMST_Consts.TMST001_TAG010, System.label.TMST001_TAG010 ) );        
        timesheetTags.put( TMST_Consts.TMST001_TAG011, new TagInfo( TMST_Consts.TMST001_TAG011, System.label.TMST001_TAG011 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG012, new TagInfo( TMST_Consts.TMST001_TAG012, System.label.TMST001_TAG012 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG013, new TagInfo( TMST_Consts.TMST001_TAG013, System.label.TMST001_TAG013 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG014, new TagInfo( TMST_Consts.TMST001_TAG014, System.label.TMST001_TAG014 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG015, new TagInfo( TMST_Consts.TMST001_TAG015, System.label.TMST001_TAG015 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG016, new TagInfo( TMST_Consts.TMST001_TAG016, System.label.TMST001_TAG016 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG017, new TagInfo( TMST_Consts.TMST001_TAG017, System.label.TMST001_TAG017 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG018, new TagInfo( TMST_Consts.TMST001_TAG018, System.label.TMST001_TAG018 ) );
        
        timesheetTags.put( TMST_Consts.TMST001_TAG020, new TagInfo( TMST_Consts.TMST001_TAG020, System.label.TMST001_TAG020 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG021, new TagInfo( TMST_Consts.TMST001_TAG021, System.label.TMST001_TAG021 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG022, new TagInfo( TMST_Consts.TMST001_TAG022, System.label.TMST001_TAG022 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG023, new TagInfo( TMST_Consts.TMST001_TAG023, System.label.TMST001_TAG023 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG024, new TagInfo( TMST_Consts.TMST001_TAG024, System.label.TMST001_TAG024 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG025, new TagInfo( TMST_Consts.TMST001_TAG025, System.label.TMST001_TAG025 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG026, new TagInfo( TMST_Consts.TMST001_TAG026, System.label.TMST001_TAG026 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG023, new TagInfo( TMST_Consts.TMST001_TAG027, System.label.TMST001_TAG027 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG024, new TagInfo( TMST_Consts.TMST001_TAG028, System.label.TMST001_TAG028 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG025, new TagInfo( TMST_Consts.TMST001_TAG029, System.label.TMST001_TAG029 ) );
        timesheetTags.put( TMST_Consts.TMST001_TAG026, new TagInfo( TMST_Consts.TMST001_TAG030, System.label.TMST001_TAG030 ) );
    }
    
    private static TMST_TimesheetUtils instance = new TMST_TimesheetUtils();
}