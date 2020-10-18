public class INTF_IG_ReconcileMapping{

    private static String mappingJSON =  
        '[{' +
          '"baseobject": "SVMXC__Site__c",' + 
          '"baseobject_uid_field":"SVMXC__SM_External_ID__c",' +
          '"fields_to_update": [' + 
            '{' +
              '"baseobject_field_to_update": "SVMXC__Account__c",' + 
              '"baseobject_field_reference_uid": "SVMXC__SM_External_Company__c",' +
              '"referenceobject": "Account",' +
              '"referenceobject_uid_field": "SVMXC__SM_External_ID__c"' +
            '},' +  
            '{' + 
              '"baseobject_field_to_update": "SVMXC__Parent__c",' + 
              '"baseobject_field_reference_uid": "SVMXC__SM_External_Parent__c",' + 
              '"referenceobject": "SVMXC__Site__c",' + 
              '"referenceobject_uid_field": "SVMXC__SM_External_ID__c"' + 
            '}' +
          ']' + 
        '},' + 
        '{' +
          '"baseobject": "SVMXC__Installed_Product__c",' + 
          '"baseobject_uid_field":"SVMXC__SM_External_ID__c",' + 
          '"fields_to_update": [' + 
            '{' + 
              '"baseobject_field_to_update": "SVMXC__Company__c",' + 
              '"baseobject_field_reference_uid": "SVMXC__SM_External_Company__c",' + 
              '"referenceobject": "Account",' + 
              '"referenceobject_uid_field": "SVMXC__SM_External_ID__c"' + 
            '},' + 
            '{' +
              '"baseobject_field_to_update": "SVMXC__Site__c",' + 
              '"baseobject_field_reference_uid": "SVMXC__SM_External_Site__c",' + 
              '"referenceobject": "SVMXC__Site__c",' + 
              '"referenceobject_uid_field": "SVMXC__SM_External_ID__c"' + 
            '},' + 
            '{' + 
              '"baseobject_field_to_update": "SVMXC__Parent__c",' + 
              '"baseobject_field_reference_uid": "SVMXC__SM_External_Parent__c",' + 
              '"referenceobject": "SVMXC__Installed_Product__c",' + 
              '"referenceobject_uid_field": "SVMXC__SM_External_ID__c"' + 
            '},' + 
            '{' + 
              '"baseobject_field_to_update": "SVMXC__Product__c",' + 
              '"baseobject_field_reference_uid": "SVMXC__SM_External_Product__c",' + 
              '"referenceobject": "Product2",' + 
              '"referenceobject_uid_field": "SVMXC__SM_External_ID__c"' + 
            '},' + 
            '{' + 
              '"baseobject_field_to_update": "SVMXC__Top_Level__c",' + 
              '"baseobject_field_reference_uid": "SVMXC__SM_External_Top_Level__c",' + 
              '"referenceobject": "SVMXC__Installed_Product__c",' + 
              '"referenceobject_uid_field": "SVMXC__SM_External_ID__c"' + 
            '}' + 
          ']' +
        '}]';
    
    public static String getMappingJSON() {
        return mappingJSON;
    }
}