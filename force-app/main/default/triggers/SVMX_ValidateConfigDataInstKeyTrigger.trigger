/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Trigger class for Servicemax Config Data object
 *
 * @author 
 * @version 19.3 Patch
 * @since 2019
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       15 Oct 2019     Updated to implement platform cache clear logic.
 *****************************************************************************************************/

trigger SVMX_ValidateConfigDataInstKeyTrigger on SVMXC__ServiceMax_Config_Data__c (before insert, before update) {
    
    Map<String,Id> recordTypeMap = COMM_RecordTypeUtilities.getObjectRecordTypeId('SVMXC__ServiceMax_Config_Data__c', new List<String>{'Configuration_Profile','Setting_Value'}); // Added for BAC-4386
    
    Id recordTypeIdforConfigData = recordTypeMap.get('Configuration_Profile');
    Id recordTypeIdforSettingValue = recordTypeMap.get('Setting_Value');
    Boolean hasSettingValueChanges = false;

    for (Integer i = 0; i < Trigger.new.size(); i++) {
        
		// If no installation key is given, the data must adhere to min-length requirements
        if (Trigger.new[i].SVMXC__Installation_Key__c == null) {
            
            // Added for BAC-4386
            if (Trigger.new[i].RecordTypeId == recordTypeIdforConfigData && Trigger.new[i].SVMXC__IsDefault__c == true && Trigger.isUpdate == false) {
               	 	Trigger.new[i].addError(System.Label.CONF014_TAG010);
            }
        } else {
            // If installation key IS given make sure the key is valid for the org and hasn't expired
            
            new SVMXC.COMM_Utils().SVMX_IsValidInstallationKey(Trigger.new[i].SVMXC__Installation_Key__c, Trigger.new[i]);
            Trigger.new[i].SVMXC__Installation_Key__c = null;
        }
            
        // Check whether setting values are modified.
        if( Trigger.new[i].RecordTypeId == recordTypeIdforSettingValue || Trigger.new[i].RecordTypeId == recordTypeIdforConfigData ) {
            hasSettingValueChanges = true;
        }
    }
    
    // Clear all group setting cache if setting values are updated
    if( hasSettingValueChanges ) {
        
        COMM_CreateServerCache.getInstance().clearGlobalSettingCache();
        COMM_CreateServerCache.getInstance().clearAllGroupSettingCache();
    }
}