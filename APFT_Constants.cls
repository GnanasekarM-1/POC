/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The APFT_Constants defines all consts used accross all application filters files.
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
public with sharing class APFT_Constants {
    
    public static final String RECORD_TYPE_SFM						= 'Target Manager';
    public static final String RECORD_TYPE_SFM_PROCESS_NODE_OBJECT	= 'Process Node Objects';
    public static final String RECORD_TYPE_WIZARD               	= 'Wizard';
    public static final String RECORD_TYPE_WIZARD_STEP          	= 'Wizard Step';
    public static final String RECORD_TYPE_CUSTOM_ACTION        	= 'SF Action';    
    public static final String RECORD_TYPE_APPLICATION_PROFILE  	= 'Application Profile';
    
    public static final String ACTION_TYPE_OTHERS					= 'OTHERS';
    
    public static final String APPLICATION_PROFILE_ID_ONLINE            = 'APPPRO001';
    public static final String APPLICATION_PROFILE_ID_IPAD              = 'APPPRO002';
    public static final String APPLICATION_PROFILE_ID_IPHONE            = 'APPPRO003';
    public static final String APPLICATION_PROFILE_ID_ANDROID_PHONE     = 'APPPRO004';
    public static final String APPLICATION_PROFILE_ID_ANDROID_TABLET    = 'APPPRO005';
    public static final String APPLICATION_PROFILE_ID_WINDOWS           = 'APPPRO006';
    
    public static final Map<String,String> RecordTypeCompareFieldMap = new Map<String, String> {
        RECORD_TYPE_WIZARD          		=> 'SVMXC__ProcessID__c',
        RECORD_TYPE_WIZARD_STEP     		=> 'SVMXC__Process__r.SVMXC__ProcessID__c',
        RECORD_TYPE_CUSTOM_ACTION			=> 'SVMXC__ProcessID__c',
        RECORD_TYPE_SFM						=> 'SVMXC__ProcessID__c',
        RECORD_TYPE_SFM_PROCESS_NODE_OBJECT	=> 'SVMXC__Process__r.SVMXC__ProcessID__c'
    };
    
    // Custom labels
    public static final Map<String,String> SupportedRecordTypeMap = new Map<String, String> {
        
        RECORD_TYPE_WIZARD          			=> System.label.APFT001_TAG007,
        RECORD_TYPE_SFM_PROCESS_NODE_OBJECT     => System.label.APFT001_TAG008,
        RECORD_TYPE_CUSTOM_ACTION   			=> System.label.APFT001_TAG009
    };
}