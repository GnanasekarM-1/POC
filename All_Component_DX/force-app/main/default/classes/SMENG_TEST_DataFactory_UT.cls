@isTest
public with sharing class SMENG_TEST_DataFactory_UT {

    public static String postInstallTestData = '{"notificationMessages":{"SVMXEG-MSG001":{"SVMXEG__SME_Message_Id__c":"SVMXEG-MSG001","SVMXEG__SME_Message_Title__c":"Appointment Confirmation","SVMXEG__SME_Message_Body__c":"New appointment for {!What.SVMXC__Component__r.SVMXC__Product__r.Name} has been scheduled.","SVMXEG__SME_Message_Description__c":"","SVMXEG__SME_Referenced_Fields__c":"{\\"objectName\\":\\"Event\\",\\"fields\\":[{\\"fieldName\\":\\"WhatId\\",\\"childRefObj\\":\\"SVMXC__Service_Order__c\\",\\"refFields\\":[{\\"fieldName\\":\\"SVMXC__Component__r.SVMXC__Product__r.Name\\",\\"fieldType\\":\\"String\\",\\"messageRef\\":\\"What.SVMXC__Component__r.SVMXC__Product__r.Name\\"}]}]}"},"SVMXEG-MSG002":{"SVMXEG__SME_Message_Id__c":"SVMXEG-MSG002","SVMXEG__SME_Message_Title__c":"Appointment Update","SVMXEG__SME_Message_Body__c":"Your appointment detail for {!What.SVMXC__Component__r.SVMXC__Product__r.Name} has been updated.","SVMXEG__SME_Message_Description__c":"","SVMXEG__SME_Referenced_Fields__c":"{\\"objectName\\":\\"Event\\",\\"fields\\":[{\\"fieldName\\":\\"WhatId\\",\\"childRefObj\\":\\"SVMXC__Service_Order__c\\",\\"refFields\\":[{\\"fieldName\\":\\"SVMXC__Component__r.SVMXC__Product__r.Name\\",\\"fieldType\\":\\"String\\",\\"messageRef\\":\\"What.SVMXC__Component__r.SVMXC__Product__r.Name\\"}]}]}"},"SVMXEG-MSG003":{"SVMXEG__SME_Message_Id__c":"SVMXEG-MSG003","SVMXEG__SME_Message_Title__c":"Appointment Confirmation","SVMXEG__SME_Message_Body__c":"New appointment for {!SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name} has been scheduled.","SVMXEG__SME_Message_Description__c":"","SVMXEG__SME_Referenced_Fields__c":"{\\"objectName\\":\\"SVMXC__SVMX_Event__c\\",\\"fields\\":[{\\"fieldName\\":\\"SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name\\",\\"fieldType\\":\\"String\\",\\"messageRef\\":\\"SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name\\"}]}"},"SVMXEG-MSG004":{"SVMXEG__SME_Message_Id__c":"SVMXEG-MSG004","SVMXEG__SME_Message_Title__c":"Appointment Update","SVMXEG__SME_Message_Body__c":"Your appointment detail for {!SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name} has been updated.","SVMXEG__SME_Message_Description__c":"","SVMXEG__SME_Referenced_Fields__c":"{\\"objectName\\":\\"SVMXC__SVMX_Event__c\\",\\"fields\\":[{\\"fieldName\\":\\"SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name\\",\\"fieldType\\":\\"String\\",\\"messageRef\\":\\"SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name\\"}]}"},"SVMXEG-MSG005":{"SVMXEG__SME_Message_Id__c":"SVMXEG-MSG005","SVMXEG__SME_Message_Title__c":"Asset Created","SVMXEG__SME_Message_Body__c":"New record for {!(SVMXEG__SME_Data_Request_Details__r:SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name)} has been created based on your request.","SVMXEG__SME_Message_Description__c":"","SVMXEG__SME_Referenced_Fields__c":"{\\"objectName\\":\\"SVMXEG__SME_Customer_Request__c\\",\\"fields\\":[{\\"childRefObj\\":\\"SVMXEG__SME_Data_Request_Details__c\\",\\"childRefObjRelationshipName\\":\\"SVMXEG__SME_Data_Request_Details__r\\",\\"refFields\\":[{\\"fieldName\\":\\"SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name\\",\\"fieldType\\":\\"String\\",\\"messageRef\\":\\"SVMXEG__SME_Data_Request_Details__r:SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name\\"}]}]}"},"SVMXEG-MSG006":{"SVMXEG__SME_Message_Id__c":"SVMXEG-MSG006","SVMXEG__SME_Message_Title__c":"Asset Updated","SVMXEG__SME_Message_Body__c":"Suggested update to {!(SVMXEG__SME_Data_Request_Details__r:SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name)} has been completed.","SVMXEG__SME_Message_Description__c":"","SVMXEG__SME_Referenced_Fields__c":"{\\"objectName\\":\\"SVMXEG__SME_Customer_Request__c\\",\\"fields\\":[{\\"childRefObj\\":\\"SVMXEG__SME_Data_Request_Details__c\\",\\"childRefObjRelationshipName\\":\\"SVMXEG__SME_Data_Request_Details__r\\",\\"refFields\\":[{\\"fieldName\\":\\"SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name\\",\\"fieldType\\":\\"String\\",\\"messageRef\\":\\"SVMXEG__SME_Data_Request_Details__r:SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name\\"}]}]}"},"SVMXEG-MSG007":{"SVMXEG__SME_Message_Id__c":"SVMXEG-MSG007","SVMXEG__SME_Message_Title__c":"Service Appointment Completed","SVMXEG__SME_Message_Body__c":"Your service appointment for {!SVMXC__Component__r.SVMXC__Product__r.Name} has been completed.","SVMXEG__SME_Message_Description__c":"","SVMXEG__SME_Referenced_Fields__c":"{\\"objectName\\":\\"SVMXC__Service_Order__c\\",\\"fields\\":[{\\"fieldName\\":\\"SVMXC__Component__r.SVMXC__Product__r.Name\\",\\"fieldType\\":\\"String\\",\\"messageRef\\":\\"SVMXC__Component__r.SVMXC__Product__r.Name\\"}]}"}},"messageTranslations":{"SVMXEG-MSG001":{"it":{"SVMXEG__SME_Language__c":"it","SVMXEG__SME_Message_Body__c":"ITALIAN: New appointment for {!What.SVMXC__Component__r.SVMXC__Product__r.Name} has been scheduled.","SVMXEG__SME_Message_Title__c":"ITALIAN: Appointment Confirmation"}},"SVMXEG-MSG002":{"fr":{"SVMXEG__SME_Language__c":"fr","SVMXEG__SME_Message_Body__c":"FRENCH: Your appointment detail for {!What.SVMXC__Component__r.SVMXC__Product__r.Name} has been updated.","SVMXEG__SME_Message_Title__c":"FRENCH: Appointment Update"},"it":{"SVMXEG__SME_Language__c":"it","SVMXEG__SME_Message_Body__c":"ITALIAN: Your appointment detail for {!What.SVMXC__Component__r.SVMXC__Product__r.Name} has been updated.","SVMXEG__SME_Message_Title__c":"ITALIAN: Appointment Update"}},"SVMXEG-MSG003":{"de":{"SVMXEG__SME_Language__c":"de","SVMXEG__SME_Message_Body__c":"GERMAN: New appointment for {!SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name} has been scheduled.","SVMXEG__SME_Message_Title__c":"GERMAN: Appointment Confirmation"},"es":{"SVMXEG__SME_Language__c":"es","SVMXEG__SME_Message_Body__c":"SPANISH: New appointment for {!SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name} has been scheduled.","SVMXEG__SME_Message_Title__c":"SPANISH: Appointment Confirmation"},"it":{"SVMXEG__SME_Language__c":"it","SVMXEG__SME_Message_Body__c":"ITALIAN: New appointment for {!SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name} has been scheduled.","SVMXEG__SME_Message_Title__c":"ITALIAN: Appointment Confirmation"}},"SVMXEG-MSG004":{"en_US":{"SVMXEG__SME_Language__c":"en_US","SVMXEG__SME_Message_Body__c":"Your appointment detail for {!SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name} has been updated.","SVMXEG__SME_Message_Title__c":"Appointment Update"},"de":{"SVMXEG__SME_Language__c":"de","SVMXEG__SME_Message_Body__c":"GERMAN: Your appointment detail for {!SVMXC__Service_Order__r.SVMXC__Component__r.SVMXC__Product__r.Name} has been updated.","SVMXEG__SME_Message_Title__c":"GERMAN: Appointment Update"}},"SVMXEG-MSG005":{"en_US":{"SVMXEG__SME_Language__c":"en_US","SVMXEG__SME_Message_Body__c":"New record for {!(SVMXEG__SME_Data_Request_Details__r:SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name)} has been created based on your request.","SVMXEG__SME_Message_Title__c":"Asset Created"},"es":{"SVMXEG__SME_Language__c":"es","SVMXEG__SME_Message_Body__c":"SPANISH: New record for {!(SVMXEG__SME_Data_Request_Details__r:SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name)} has been created based on your request.","SVMXEG__SME_Message_Title__c":"SPANISH: Asset Created"}},"SVMXEG-MSG006":{"es":{"SVMXEG__SME_Language__c":"es","SVMXEG__SME_Message_Body__c":"SPANISH: Suggested update to {!(SVMXEG__SME_Data_Request_Details__r:SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name)} has been completed.","SVMXEG__SME_Message_Title__c":"SPANISH: Asset Updated"},"it":{"SVMXEG__SME_Language__c":"it","SVMXEG__SME_Message_Body__c":"ITALIAN: Suggested update to {!(SVMXEG__SME_Data_Request_Details__r:SVMXEG__SME_Installed_Product__r.SVMXC__Product__r.Name)} has been completed.","SVMXEG__SME_Message_Title__c":"ITALIAN: Asset Updated"}},"SVMXEG-MSG007":{"en_US":{"SVMXEG__SME_Language__c":"en_US","SVMXEG__SME_Message_Body__c":"Your service appointment for {!SVMXC__Component__r.SVMXC__Product__r.Name} has been completed.","SVMXEG__SME_Message_Title__c":"Service Appointment Completed"},"fr":{"SVMXEG__SME_Language__c":"fr","SVMXEG__SME_Message_Body__c":"FRENCH: Your service appointment for {!SVMXC__Component__r.SVMXC__Product__r.Name} has been completed.","SVMXEG__SME_Message_Title__c":"FRENCH: Service Appointment Completed"}}}}';
    public static SMENG_COMM_Wrapper.CommunityWrapper communityTestData = new SMENG_COMM_Wrapper.CommunityWrapper('TestId123','TestCommunity','https://testurl.com/');

    private static Set<String> ignoreFieldSet = new Set<String>{
        'OWNERID',
        'RECORDTYPEID'
    };

    private static final SMENG_COMM_DescribeManager describeManager = SMENG_COMM_DescribeManager.getInstance();
    
    public static SObject insertSObject( final String objectName ) {
        return insertSObject( objectName, new Map<String,Object>() ) ;
    }
    
    public static SObject insertSObject( final String objectName, final Map<String,Object> valueMapping ) {
        return insertSObjectList( objectName, valueMapping, 1 ).get(0);
    }
    
    public static List<SObject> insertSObjectList( final String objectName, final Integer objectCount ) {
        return insertSObjectList( objectName, new Map<String,Object>(), objectCount );
    }
    
    public static List<SObject> insertSObjectList( final String objectName, final Map<String,Object> valueMapping, final Integer objectCount ) {
        
        List<SObject> newSObjectList = createSObjectList( objectName, valueMapping, objectCount );
        
        insert newSObjectList;
        
        return newSObjectList;
    }
    
    public static SObject createSObject( final String objectName ) {
        return createSObject( objectName, new Map<String,Object>() ) ;
    }
    
    public static SObject createSObject( final String objectName, final Map<String,Object> valueMapping ) {
        return createSObjectList( objectName, new Map<String,Object>(), 1 ).get(0) ;
    }
    
    public static List<SObject> createSObjectList( final String objectName, final Integer objectCount ){
        return createSObjectList( objectName, new Map<String,Object>(), objectCount );
    }
    
    public static List<SObject> createSObjectList( final String objectName, final Map<String,Object> valueMapping, final Integer objectCount ) {
        
        final List<SObject> sObjectList = new List<SObject>();
        
        final Schema.DescribeSobjectResult describeSobjectResult = describeManager.getObjectDescribe( objectName );
        
        final Map<String, Schema.SObjectField> sObjectFieldMap = describeSobjectResult.fields.getMap();
        final Map<String, Schema.DescribeFieldResult> describeFieldResultMap = new Map<String, Schema.DescribeFieldResult>();
        
        for( Schema.SObjectField sObjectField : sObjectFieldMap.values() ) {
                
            final Schema.DescribeFieldResult describeFieldResult = describeManager.getFieldDescribe( sObjectField );
            
            if( !ignoreFieldSet.contains(describeFieldResult.getName().toUpperCase()) ) {
                
                if( ( describeFieldResult.isCustom() && !describeFieldResult.isCalculated() ) || ( !describeFieldResult.isCustom() && describeFieldResult.isCreateable() )  ) {
                    describeFieldResultMap.put( describeFieldResult.getName(), describeFieldResult );
                }
            }
        }
        
        final Schema.SobjectType sobjectType = describeSobjectResult.getSobjectType();
        final String nameFieldValue = ( objectName.length() > 34 ) ? objectName.substring(0, 34) : objectName;
        
        for( Integer index = 0; index < objectCount; index++ ) {
            
            if( describeFieldResultMap.values().size() != 0 ) {
                
                SObject newSObject = sobjectType.newSObject();
                for( Schema.DescribeFieldResult describeFieldResult : describeFieldResultMap.values() ) {
                    
                    if( describeFieldResult.getType() == Schema.DisplayType.REFERENCE && !valueMapping.containsKey( describeFieldResult.getName() ) ) {
                        continue;
                    }
                       
                    final Object fieldValue = valueMapping.containsKey( describeFieldResult.getName() ) 
                        ? valueMapping.get( describeFieldResult.getName() )
                        : describeFieldResult.isNameField() 
                            ? ( nameFieldValue + index ) 
                            : getDefaultFieldValue( describeFieldResult, index, describeFieldResult.getLength() );
                    
                    newSObject.put( describeFieldResult.getSObjectField(), fieldValue );
                }
                
                sObjectList.add(newSObject);
            }
        }
        
        return sObjectList;
    }

    public static void applyPermissionSetToCurrentUser(String permissionSetName) {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        applyPermissionSet(currentUser, permissionSetName);
    }

    public static void applyPermissionSet(User user, String permissionSetName) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName];

        if (ps != null) {
            Integer assignmentCount = [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId =: user.Id AND PermissionSetId =: ps.Id];

            if (assignmentCount == 0) {
                upsert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
            }
        }
    }

    private static Object getDefaultFieldValue( final Schema.DescribeFieldResult describeFieldResult, final Integer recordIndex, final Integer length ) {
        
        Object retValue = null;
        
        switch on describeFieldResult.getType() {
            
            when Base64 {
                retValue = Blob.valueOf(recordIndex.format());
            }
            when Boolean {
                retValue = Boolean.valueOf(true);
            }
            when Currency {
                retValue = Decimal.valueOf(recordIndex);
            }
            when Date {
                retValue = Date.today();
            }
            when Email {
                retValue = 'testemail' + recordIndex.format() + '@servicemax.com';
            }
            when Location {
                retValue = Location.newInstance(0,0);
            }
            when Integer {
                retValue = Integer.valueOf(recordIndex);
            }
            when Double {
                retValue = Double.valueOf(recordIndex);
            }
            when Percent {
                retValue = Double.valueOf( (Math.random() * 100) );
            }
            when Phone {
                retValue = String.valueOf('9876543210');
            }
            when Picklist, MultiPicklist {
                retValue = getPicklistDefaultValue( describeFieldResult );
            }
            when String, TextArea {
                retValue = 'Default Text ' + recordIndex.format();
                retValue = ((String)retValue).length() > length ? ((String)retValue).substring(0, length-1) : retValue;
            }
            when Time {
                retValue = Time.newInstance(12, 0, 0, 0); 
            }
            when URL {
                retValue = 'http://testurl' + recordIndex + '.com';
            }
        }
        return retValue;
    }
    
    private static String getPicklistDefaultValue( final Schema.DescribeFieldResult describeFieldResult) {
        
        String picklistValue;
        
        List<Schema.PicklistEntry> picklistEntryList = describeFieldResult.getPicklistValues();        
        for( Schema.PicklistEntry picklistEntry : picklistEntryList ) {
            
            if( picklistEntry.isDefaultValue() ) {
                picklistValue = picklistEntry.getValue(); break;
            }    
        }
        
        if( picklistValue == null ) {
            picklistValue = picklistEntryList.get(0).getValue();
        }
        
        return picklistValue;
    }
}