/*****************************************************************************
 *                       Copyright (C) 2015 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The singleton class COMM_SecurityUtils implements utility methods to verify object and field level access.
 * As part of CRUD and FLS Enforcement before each select queries and DML operations which has direct 
 * reference to VisualForce page and Apex controllers must verify object and field level access.
 *
 *
 * @author Ramachandra Mohan
 * @version 16.10000
 * @since 2015
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       15 Dec 2015     Created.
 * 026416       Ramachandra Mohan       08 Jan 2016     Updated additional check for calculated fields.
 *              Ramachandra Mohan       01 Feb 2016     Updated code to respect global setting GBL031.
 *                                                      Updated Account and Contact in ignore field list.\
 *  BAC-5355    Jaysukh Patel           18 Dec 2019     Modified isDeletableObject,isCreateable,isAccessible \
 *                                                      getSObjectFieldMap methods, commented objectSobjectFieldMap\
 *****************************************************************************************************/

public with sharing class COMM_SecurityUtils {
    
    /**
     * Custom exception class which will be used on field permission issues.
     */
    public class SecurityAccessException extends Exception {
    }

    /**
     * Private static variable to hold SObject internal map key 'attributes'.
     */
    private static final String STRING_ATTRIBUTES   = 'attributes';
    
    /**
     * Private static variable to hold SObject internal map key 'type'.
     */
    private static final String STRING_TYPE         = 'type';
    
    /**
     * Static variable to hold instance of COMM_SecurityUtils class.
     */
    private static COMM_SecurityUtils instance = new COMM_SecurityUtils();
    
    /*
     * Instance variable to hold global describe map.
     */
    //private Map<String, Schema.SObjectType> globalDescribeMap = null;
    
    /**
     * Instance variable to hole ignore select field flag.
     */
    private Boolean ignoreSelectFields = false;
    
    /**
     * Instance variable to map object name and map of fields associated to it.
     */
    //BAC-5355 commented below variable\
    //private Map<String, Map<String,Schema.SObjectField>> objectSobjectFieldMap = new Map<String, Map<String, Schema.SObjectField>>();
    
    @TestVisible private Boolean isSecurityCheckEnabled = false;
    
    /**
     * Set of system fields to be ignored while verifying field access.
     */
    @TestVisible private Set<String> systemFieldsSet = new Set<String> {
        'name', 
        'id', 
        'isdeleted', 
        'createdbyid', 
        'createdby', 
        'createddate', 
        'lastmodifiedbyid',
        'lastmodifiedby',
        'lastmodifieddate', 
        'systemmodstamp', 
        'lastactivitydate', 
        'ownerid',
        'lastreferenceddate', 
        'lastvieweddate', 
        'recordtypeid',
        'recordtype',
        'isprivate',
        'contenttype',
        'bodylength',
        'parentid',
        'currencyisocode',
         'contact',
         'account',
     'mayedit',
        'islocked',
         'owner'
    };
    /**
     * Enum class to define supported access types.
     */
    public enum Access { Accessible, Createable, Updateable, Upsertable }
    
    /**
     * This method is used to retrieve instance of this class.
     * 
     * @return Returns instance of COMM_SecurityUtils.
     */
    public static COMM_SecurityUtils getInstance() {
        return instance;
    }
    
    /**
     * This method is used to verify object access for delete operation.
     * 
     * @param objectAPIName Object API name for which delete operation access to be verified.
     * 
     * @return Returns true if the object has deletable access, Otherwise, returns false.
     */
    public Boolean isDeletableObject( String objectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'isDeletableObject() - enter; objectName: ' + objectAPIName );
        
        Boolean returnValue = false;
        
        if( isSecurityCheckEnabled ) {
            
            //BAC - 5355 Start
            /*Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType sobjectType = globalDescribeMap.get(objectAPIName);
            
            // Retrieve the object type from global describe and verify whether the object has 
            // delete access or not.
            if( sobjectType != null ) {
                returnValue = sobjectType.getDescribe().isDeletable();
            } */
            //BAC - 5355 End
            Schema.DescribeSobjectResult sobjectDescribe = COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objectAPIName);
            if(sobjectDescribe != null)
            {
                returnValue = sobjectDescribe.isDeletable();
            }  
        } else {
            returnValue = true;
        }
        
        System.debug( LoggingLevel.DEBUG, 'isDeletableObject() - exit; returnValue: ' + returnValue );
        
        return returnValue;
    }

    /**
     * This method is used to verify object access for Createable operation.
     * 
     * @param objectAPIName Object API name for which Createable operation access to be verified.
     * 
     * @return Returns true if the object has Createable access, Otherwise, returns false.
     */
    public Boolean isCreateable( String objectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'isCreateable() - enter; objectName: ' + objectAPIName );
        
        Boolean returnValue = false;
        
        if( isSecurityCheckEnabled ) {
            //BAC-5355 Start
            /*Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType sobjectType = globalDescribeMap.get(objectAPIName);
            
            // Retrieve the object type from global describe and verify whether the object has 
            // Accessible access or not.
            if( sobjectType != null ) {
                returnValue = sobjectType.getDescribe().isCreateable();
            } */
            Schema.DescribeSobjectResult sobjectDescribe = COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objectAPIName);
            if(sobjectDescribe != null)
            {
                returnValue = sobjectDescribe.isCreateable();
            }
            //BAC-5355 End   
        } else {
            returnValue = true;
        }
        
        System.debug( LoggingLevel.DEBUG, 'isCreateable() - exit; returnValue: ' + returnValue );
        
        return returnValue;
    }

    /**
     * This method is used to verify object access for Accessible operation.
     * 
     * @param objectAPIName Object API name for which Accessible operation access to be verified.
     * 
     * @return Returns true if the object has Accessible access, Otherwise, returns false.
     */
    public Boolean isAccessible( String objectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'isAccessible() - enter; objectName: ' + objectAPIName );
        
        Boolean returnValue = false;
        
        if( isSecurityCheckEnabled ) {
            //BAC-5355 Start
            /*Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType sobjectType = globalDescribeMap.get(objectAPIName);
            
            // Retrieve the object type from global describe and verify whether the object has 
            // Accessible access or not.
            if( sobjectType != null ) {
                returnValue = sobjectType.getDescribe().isAccessible();
            }*/
            //BAC-5355 End
            Schema.DescribeSobjectResult sobjectDescribe = COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objectAPIName);
            if(sobjectDescribe != null)
            {
                returnValue = sobjectDescribe.isAccessible();
            }    
        } else {
            returnValue = true;
        }
        
        System.debug( LoggingLevel.DEBUG, 'isAccessible() - exit; returnValue: ' + returnValue );
        
        return returnValue;
    }
    /**
     * This method is used to verify field access for requested sobject and access type.
     * 
     * @param sourceObjectList List of SObject from which single instance field access to be verified.
     * @param accessType Access type for which fields to be verified.
     * @param ignoreSelectFields Flag to ignore check for fields which are queried in select query 
     *        and used in update DML operation.
     * 
     * @returns Returns true if all the fields has requested access, Otherwise, returns false.     
     */
    public Boolean verifyFieldAccess( List<SObject> sourceObjectList, Access accessType, Boolean ignoreSelectFields ) {
        
        this.ignoreSelectFields = ignoreSelectFields;
        return verifyFieldAccess( sourceObjectList, accessType );
    }
    
    /**
     * This method is used to verify field access for requested sobject and access type.
     * 
     * @param sourceObjectList List of SObject from which single instance field access to be verified.
     * @param accessType Access type for which fields to be verified.
     * 
     * @returns Returns true if all the fields has requested access, Otherwise, returns false.     
     */
    public Boolean verifyFieldAccess( List<SObject> sourceObjectList, Access accessType ) {
        
        Boolean returnValue = true;
        
        if( isSecurityCheckEnabled ) {
            
            if( sourceObjectList != null && !sourceObjectList.isEmpty() ) {
                returnValue = verifyFieldAccess( sourceObjectList.get(0), accessType );
            }    
        }
        
        return returnValue;
    }
    
    /**
     * This method is used to verify field access for requested sobject and access type.
     * 
     * @param sourceObject SObject instance of which field access to be verified.
     * @param accessType Access type for which fields to be verified.
     * 
     * @returns Returns true if all the fields has requested access, Otherwise, returns false.     
     */
    public Boolean verifyFieldAccess( SObject sourceObject, Access accessType ) {
        
        System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - enter; sObject: ' + sourceObject + '; accessType: ' + accessType );
        
        Boolean returnValue = false;
        
        try {
            
            if( isSecurityCheckEnabled ) {
                
                // Convert SObject to Map which will have only those field information which 
                // are accessed or configured.
                Map<String, Object> objectFieldValues = ( Map<String, Object> ) JSON.deserializeUntyped( JSON.serialize( sourceObject ) );
                
                List<String> fieldAPINameList = new List<String>();
                String objectAPIName = null;
                for( String key : objectFieldValues.keySet() ) {
                    
                    // The map will have additional element attributes other that the field values pairs. This will 
                    // have map of properties of which one of the property is type. The type will have object API name
                    // from which this SObject instance has been created.
                    if( key.endsWithIgnoreCase( STRING_ATTRIBUTES ) ) {
                        
                        objectAPIName = (String) ( (Map<String, Object>) objectFieldValues.get( key ) ).get( STRING_TYPE );
                        System.debug( LoggingLevel.DEBUG, 'Object API name: ' + objectAPIName );
                        continue;
                    }
                    
                    // Ignore verification of system fields.
                    if( accessType != Access.Accessible && systemFieldsSet.contains( key.toLowerCase() ) ) {
                        
                        returnValue = true;
                        continue;
                    }
                    
                    if( !key.contains('.') && !key.contains('__r') ) {
                        
                        // All the keys in this map, other than attributes, are field API names. 
                        fieldAPINameList.add( key );    
                    }
                }
                
                System.debug( LoggingLevel.DEBUG, 'fieldAPINameList: ' + fieldAPINameList );
                
                // Call overload method with list of field names to verify the access.
                if( objectAPIName != null && fieldAPINameList != null && !fieldAPINameList.isEmpty() ) {
                    returnValue = verifyFieldAccess( objectAPIName, fieldAPINameList, accessType );
                }
            } else {
                returnValue = true;
            }
        }
        
        catch( Exception ex ) {
            
            System.debug( LoggingLevel.ERROR, ex.getMessage() );
            System.debug( LoggingLevel.ERROR, ex.getStackTraceString() );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - exit; returnValue: ' + returnValue );
        }
        
        return returnValue;
    }
    
    /**
     * This method is used to verify field access for requested list of field API names and access type.
     * 
     * @param objectAPIName Source object name for which field access to be verified.
     * @param fieldAPINameList List of field names for which access to be verified.
     * @param accessType Access type for which requested list of fields to be verified.
     * 
     * @return Returns true if all the fields has requested access, Otherwise, returns false.
     */
    public Boolean verifyFieldAccess( String objectAPIName, List<String> fieldAPINameList, Access accessType ) {
        
        System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - enter; objectAPIName: ' + objectAPIName + '; fieldAPINameList: ' + fieldAPINameList + '; accessType: ' + accessType );
        
        Boolean returnValue = false;
        
        if( isSecurityCheckEnabled ) {
            
            // Verify access of each field in the list.
            for( String fieldAPIName : fieldAPINameList ) {
                
                returnValue = verifyFieldAccess(objectAPIName, fieldAPIName, accessType );
                
                if(!returnValue) {
                    
                    System.debug( LoggingLevel.DEBUG, fieldAPIName + '; Insufficient permission to perform ' + accessType );
                    break;
                }
            }    
        } else {
            returnValue = true;
        }
        
        System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - exit; returnValue: ' + returnValue );
        
        return returnValue;
    }
    
    /**
     * This method is used to verify field access for requested list of field API names and access type.
     * 
     * @param objectAPIName Source object name for which field access to be verified.
     * @param fieldAPIName field names for which access to be verified.
     * @param accessType Access type for which requested list of fields to be verified.
     * 
     * @return Returns true if all the fields has requested access, Otherwise, returns false.
     */
    public Boolean verifyFieldAccess( String objectAPIName, String fieldAPIName, Access accessType ) {
        
        System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - enter; objectAPIName: ' + objectAPIName + '; fieldAPIName: ' + fieldAPIName + '; accessType: ' + accessType );
        
        Boolean returnValue = false;
        if( isSecurityCheckEnabled ) {
            
            Map<String, Schema.SObjectField> sobjectFieldMap = getSObjectFieldMap( objectAPIName );
            
            // Continue verifing field accedd only if the object API name is valid. The map sobjectFieldMap 
            // will be null if the objectAPIName is invalid.
            if( sobjectFieldMap != null ) {
                
                fieldAPIName = fieldAPIName.trim();
                
                // Return false if the list has invalid field API name.
                if( sobjectFieldMap.containsKey( fieldAPIName ) ) {
                    
                    // Ignore verification of system fields.
                    if( accessType == Access.Accessible || !systemFieldsSet.contains( fieldAPIName.toLowerCase() ) ) {
                        // Call overload method with list of field describe to verify the access.
                        returnValue = verifyFieldAccess( sobjectFieldMap.get(fieldAPIName).getDescribe(), accessType );
                    } else {
                        returnValue = true;
                    }
                } else if( fieldAPIName.contains('.') ) {
                    //Jaysukh : Fixed defect BAC-5054 : SFA: Added below fix to handled multiple  '__r' contains in string
                    // ex : svmxc__related_work_order__r.name
                    //String referenceField = fieldAPIName.substring(0, fieldAPIName.indexOf('.') ).replace('__r', '__c');
                    String referenceField = fieldAPIName.substring(0, fieldAPIName.indexOf('.'));
                    if(referenceField.endsWithIgnoreCase('__r'))
                    {
                      referenceField = referenceField.removeEndIgnoreCase('__r')+'__c';    
                    }
                    Schema.DescribeFieldResult describeFieldResult;

                    if(referenceField.contains('__c') && sobjectFieldMap.containsKey(referenceField) ) {
                        
                        describeFieldResult = sobjectFieldMap.get(referenceField).getDescribe();
                        
                        if( describeFieldResult.getType() == Schema.DisplayType.REFERENCE ) {
                            
                            List<Schema.sObjectType> referenceList = describeFieldResult.getReferenceTo();
                            String referenceTo = null;
                            for( Schema.sObjectType objectType : referenceList ) {
                                
                                Schema.DescribeSObjectResult result = objectType.getDescribe();
                                referenceTo = result.getName().replace('__r', '__c');
                                break;
                            }
                            
                            System.debug( LoggingLevel.DEBUG, 'referenceField: ' + referenceField +'; referenceTo: ' + referenceTo );
                            
                            if( referenceTo != null ) {
                                
                                fieldAPIName = fieldAPIName.substring( fieldAPIName.indexOf('.') + 1 );
                                returnValue = verifyFieldAccess( referenceTo, fieldAPIName, accessType );
                            }                       
                        }    
                    } else {

                        if( sobjectFieldMap.containsKey(referenceField+'Id') ) {

                            describeFieldResult = sobjectFieldMap.get(referenceField+'Id').getDescribe();
                            List<Schema.sObjectType> referenceList = describeFieldResult.getReferenceTo();
                            if(!referenceList.isEmpty()){
                                referenceField = referenceList[0].getDescribe().getName();
                                System.debug('referenceField: ' + referenceField );
                            }
                            
                        } 

                        fieldAPIName = fieldAPIName.substring( fieldAPIName.indexOf('.') + 1 );
                        returnValue = verifyFieldAccess( referenceField, fieldAPIName, accessType );
                    } 
                }
            }
        } else {
            returnValue = true;
        }
        
        System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - exit; returnValue: ' + returnValue );
        
        return returnValue;
    }
    
    /**
     * This method is used to verify field access for requested SObjectField and access type.
     * 
     * @param sobjectField Schema.SObjectField for which field access to be verified.     
     * @param accessType Access type for which requested Schema.SObjectField to be verified.
     * 
     * @return Returns true if all the fields has requested access, Otherwise, returns false.
     */
    public Boolean verifyFieldAccess( Schema.SObjectField sobjectField, Access accessType ) {
        
        System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - enter; sobjectField: ' + sobjectField + '; accessType: ' + accessType );
        
        Boolean returnValue = false;
        if( isSecurityCheckEnabled ) {
            
            if( sobjectField != null ) {
                
                // Call overload method with list of field describe to verify the access.
                returnValue = verifyFieldAccess( sobjectField.getDescribe(), accessType);
            }    
        } else {
            returnValue = true;
        }
        
        System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - exit; returnValue: ' + returnValue );
        
        return returnValue;
    }
    
    /**
     * This method is used to verify field access for requested DescribeFieldResult and access type.
     * 
     * @param describeFieldResult Schema.DescribeFieldResult for which field access to be verified.     
     * @param accessType Access type for which requested Schema.DescribeFieldResult to be verified.
     * 
     * @return Returns true if all the fields has requested access, Otherwise, returns false.
     */    
    public Boolean verifyFieldAccess( Schema.DescribeFieldResult describeFieldResult, Access accessType ) {
        
        System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - enter; describeFieldResult: ' + describeFieldResult + '; accessType: ' + accessType );
        
        Boolean returnValue = false;
        if( isSecurityCheckEnabled ) {
            
            if( describeFieldResult != null && describeFieldResult.getType() == Schema.DisplayType.REFERENCE && accessType == Access.Updateable ) {
                returnValue = true;
            } else if( describeFieldResult != null && ( describeFieldResult.isCalculated() || describeFieldResult.isAutoNumber() ) ) {
                returnValue = true;
            } else    
                // Return false if describeFieldResult or accessType is invalid.
                if( describeFieldResult != null && accessType != null ) {
                    
                    if( accessType == Access.Accessible ) {
                        returnValue = describeFieldResult.isAccessible();
                    } else if( accessType == Access.Createable ) {
                        returnValue = describeFieldResult.isCreateable();
                    } else if( accessType == Access.Updateable ) {
                        returnValue = describeFieldResult.isUpdateable();
                        if( ignoreSelectFields ) {
                            returnValue = describeFieldResult.isAccessible();
                        }
                    } else if( accessType == Access.Upsertable ) {
                        // For upsert operation, one of update and create access must be enabled.
                        returnValue = ( describeFieldResult.isUpdateable() || describeFieldResult.isCreateable() );
                    } else {
                        System.debug( LoggingLevel.ERROR, 'Unsupported access type to verify field access. accessType: ' + accessType.name() );
                    }
                }    
        } else {
            returnValue = true;
        }
        
        System.debug( LoggingLevel.DEBUG, 'verifyFieldAccess() - exit; returnValue: ' + returnValue );
        
        return returnValue;
    }
    
    /**
     * This method is used to retrieve cached Map of SObjectField for given object name.
     * 
     * @param objectName Object API name for which map of SObjectField to be retrieved.
     * 
     * @return If valid object name, then returns map of field API name and SObjectField 
     *         for requested object name, Otherwise, returns null.
     */
    @TestVisible private Map<String, Schema.SObjectField> getSObjectFieldMap( String objectName ) {
        
        //BAC-5355 start
        /*Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        
        // Describe fields only if the object name is valid and the cache map has no entry on it.
        if( !objectSobjectFieldMap.containsKey( objectName ) && globalDescribeMap.containsKey( objectName ) ) {
            objectSobjectFieldMap.put( objectName, globalDescribeMap.get( objectName ).getDescribe().fields.getMap() );
        }
        
        return objectSobjectFieldMap.get( objectName );*/
        //BAC-5355 End
        Map<String, Schema.SObjectField> objectSobjectFieldMap = COMM_Utils_DescribeCall.getObjectFieldDetails(objectName);
        if(objectSobjectFieldMap.isEmpty())
        {
            objectSobjectFieldMap = null;
        }
        return objectSobjectFieldMap;
    }
    
    /**
     * Private class constructor to create instance of this class.
     */
    private COMM_SecurityUtils() {
        
        // Global describe map will be constructed only when this class instance has been created.
        //globalDescribeMap = Schema.getGlobalDescribe();
        
        //----Start-----Added for the story BAC-4410 and below code is commented to avoid fetching all global setting
        String settingValue = new SVMXC.COMM_Utils_ManageSettings().SVMX_getGlobalSettingList('GLOB001_GBL031');
        if(!String.isBlank(settingValue)){ //Added String.isBlank check for defect 045626 fix
            isSecurityCheckEnabled = Boolean.valueOf(settingValue);
        }
        //----End------Added for the story BAC-4410 and below code is commented to avoid fetching all global setting

        // Global setting to enable/disable security check. GBL031.
        /*Map<String, String> commonGlobalSettings = new SVMXC.COMM_Utils_ManageSettings().SVMX_getSettingList('GLOB001');
        if( commonGlobalSettings.containsKey('GBL031') && commonGlobalSettings.get('GBL031') != null ) {
            isSecurityCheckEnabled = Boolean.valueOf( commonGlobalSettings.get('GBL031') );
        }*/
        
        /*if( Test.isRunningTest() ) {
            isSecurityCheckEnabled = true;
        }*/
    }

    /////////////////////////////NEW APIs for CRUD-FLS WITHOUT USING GLOBAL DESCRIBE////////////////////////////////////
    //////////////////////TODO: Handles only DMLs as of now, will be expanded to handle SOQLs in future////////////////////////
    public enum Action { Accessible, Createable, Deletable, Updateable, Upsertable }

    public void insertAsUser(SObject devObj) {
        Map<String, Object> fieldsAndValues = devObj.getPopulatedFieldsAsMap();
        if(canCRUD(devObj.getSObjectType(), fieldsAndValues.keySet(), Action.Createable)) {
            insert devObj;
        }
    }

    public void insertAsUser(List<SObject> devObjList) {
        Map<String, Object> fieldsAndValues = devObjList.get(0).getPopulatedFieldsAsMap();
        if(canCRUD(devObjList.get(0).getSObjectType(), fieldsAndValues.keySet(), Action.Createable)) {
            insert devObjList;
        }
    }

    public void updateAsUser(SObject devObj) {
        Map<String, Object> fieldsAndValues = devObj.getPopulatedFieldsAsMap();
        if(canCRUD(devObj.getSObjectType(), fieldsAndValues.keySet(), Action.Updateable)) {
            update devObj;
        }
    }

    public void updateAsUser(List<SObject> devObjList) {
        Map<String, Object> fieldsAndValues = devObjList.get(0).getPopulatedFieldsAsMap();
        if(canCRUD(devObjList.get(0).getSObjectType(), fieldsAndValues.keySet(), Action.Updateable)) {
            update devObjList;
        }
    }

    public void upsertAsUser(SObject devObj) {
        Map<String, Object> fieldsAndValues = devObj.getPopulatedFieldsAsMap();
        if(canCRUD(devObj.getSObjectType(), fieldsAndValues.keySet(), Action.Upsertable)) {
            upsert devObj;
        }
    }

    public void upsertAsUser(List<SObject> devObjList) {
        Map<String, Object> fieldsAndValues = devObjList.get(0).getPopulatedFieldsAsMap();
        if(canCRUD(devObjList.get(0).getSObjectType(), fieldsAndValues.keySet(), Action.Upsertable)) {
            upsert devObjList;
        }
    }

    public void deleteAsUser(SObject devObj) {
        Map<String, Object> fieldsAndValues = devObj.getPopulatedFieldsAsMap();
        if(canCRUD(devObj.getSObjectType(), fieldsAndValues.keySet(), Action.Deletable)) {
            delete devObj;
        }
    }

    public void deleteAsUser(List<SObject> devObjList) {
        Map<String, Object> fieldsAndValues = devObjList.get(0).getPopulatedFieldsAsMap();
        if(canCRUD(devObjList.get(0).getSObjectType(), fieldsAndValues.keySet(), Action.Deletable)) {
            delete devObjList;
        }
    }

    public boolean canCRUD(Schema.SObjectType objectType, Set<String> fieldNames, Action actionType) {
        //if security check global setting is not enabled then no need to do CRUD-FLS
        if(!isSecurityCheckEnabled) 
            return true;

        Schema.DescribeSObjectResult objDesc = objectType.getDescribe();
        if (!isObjCRUD(objDesc,actionType)){
            COMM_AccessControlException.ExceptionReason reason = null;
            if(actionType == Action.Createable) {
                reason = COMM_AccessControlException.ExceptionReason.NO_CREATE;
            } else if(actionType == Action.Updateable) {
                reason = COMM_AccessControlException.ExceptionReason.NO_UPDATE;
            } else if(actionType == Action.Deletable) {
                reason = COMM_AccessControlException.ExceptionReason.NO_DELETE;
            } else if(actionType == Action.Accessible) {
                reason = COMM_AccessControlException.ExceptionReason.NO_READ;
            } else if(actionType == Action.Upsertable) {
                reason = COMM_AccessControlException.ExceptionReason.NO_UPSERT;
            }
               throw new COMM_AccessControlException('Access Violation :'+ COMM_AccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION+' '+ reason+' '+objDesc.getName(), 
                    COMM_AccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, 
                    reason, objDesc.getName(), null);
        }
        // get the fields on the object
        Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult sobjectFldDesc;

        //No need of FLS for delete action
        if(actionType != Action.Deletable) {
            for (String f : fieldNames) {
            
                // Ignore verification of system fields.
                if(systemFieldsSet.contains(f.toLowerCase()))
                    continue;
                
                if(f.contains('__r'))
                    continue;

                Schema.SObjectField sObjectFld = fieldMap.get(f);
                if (sObjectFld == null) {
                    throw new COMM_AccessControlException('Field not found', 
                            COMM_AccessControlException.ExceptionType.FIELD_NOT_FOUND, 
                            COMM_AccessControlException.ExceptionReason.GENERIC,
                            objDesc.getName(), f);
                } else {
                    sobjectFldDesc = sObjectFld.getDescribe();
                }
                system.debug('field type: '+sobjectFldDesc.getType().name());
                if(!(sobjectFldDesc.isCalculated() || sobjectFldDesc.isAutoNumber() 
                        || sobjectFldDesc.getType().name().equalsIgnoreCase('location')
                        || sobjectFldDesc.getType().name().equalsIgnoreCase('address'))) {
                    if(!isFieldCRUD(sObjectFld.getDescribe(),actionType)) {
                        COMM_AccessControlException.ExceptionReason reason = null;
                        if(actionType == Action.Createable) {
                            reason = COMM_AccessControlException.ExceptionReason.NO_CREATE;
                        } else if(actionType == Action.Updateable) {
                            reason = COMM_AccessControlException.ExceptionReason.NO_UPDATE;
                        } else if(actionType == Action.Accessible) {
                            reason = COMM_AccessControlException.ExceptionReason.NO_READ;
                        } else if(actionType == Action.Upsertable) {
                            reason = COMM_AccessControlException.ExceptionReason.NO_UPSERT;
                        }
                          throw new COMM_AccessControlException('Access Violation :'+ COMM_AccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION+' '+ reason+' '+objDesc.getName(), 
                                COMM_AccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION, 
                                reason, objDesc.getName(), f);
                    }
                }
            }
        }
        return true;
    }

    private boolean isObjCRUD(DescribeSObjectResult objRes, Action actionType) {
        if(actionType == Action.Createable) {
            return objRes.isCreateable();
        } else if(actionType == Action.Updateable) {
            return objRes.isUpdateable();
        } else if(actionType == Action.Deletable) {
            return objRes.isDeletable();
        } else if(actionType == Action.Upsertable) {
            return (objRes.isUpdateable() && objRes.isCreateable());
        } else if(actionType == Action.Accessible) {
            return (objRes.isAccessible());
        }
        return false;
    } 

    private boolean isFieldCRUD(DescribeFieldResult fieldRes, Action actionType) {
        if(actionType == Action.Createable) {
            return fieldRes.isCreateable();
        } else if(actionType == Action.Updateable) {
            return fieldRes.isUpdateable();
        } else if(actionType == Action.Upsertable) {
            return (fieldRes.isUpdateable() && fieldRes.isCreateable());
        } else if(actionType == Action.Accessible) {
            return (fieldRes.isAccessible());
        }
        return false;
    }
}