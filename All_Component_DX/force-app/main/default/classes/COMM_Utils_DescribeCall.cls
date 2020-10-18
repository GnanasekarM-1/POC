/*****************************************************************************
 *                       Copyright (C) 2016 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * For story BAC-2 (Update SFM Framework to respect object name space), as Salesforce and other ISV's introduce more objects, 
 * we must ensure that there are no conflicts in the way SFM Search works when similar object names are present in an org. 
 * As the namespace is used to differentiate between "Like" objects, we need to make sure we do not drop the namespace when we 
 * reference objects. 
 *
 * @author Anchal Sharma
 * @version 16.49024
 * @since 2016
 */
/*****************************************************************************
 *    ID        Name                   Date            Comment
 *****************************************************************************
 *              Anchal Sharma        01 Aug  2016        Created. 
 *              Jaysukh Patel        18 Dec 2019         Added method getObjectDescribe(String) - BAC- 5355
 *              Jaysukh Patel        18 Dec 2019         Added method getObjectDescribe(List<String>) - BAC-5355
 *              Jaysukh Patel        18 Dec 2019         Marked constrctor as private to qualify the class for singlton BAC-5355
 *              Jaysukh patel        26 Dec 2019         Added method getDefaultPicklistValue - BAC -5355
 ******************************************************************************************/

public with sharing class COMM_Utils_DescribeCall {
  
    private COMM_Utils_DescribeCall()
    {
    
    }
    private static final COMM_Utils_DescribeCall instance= new COMM_Utils_DescribeCall( );
    
    /** 
     * private static map variable to hold object api name and DescribeSobjectResult
     */
    private static Map<String, Schema.DescribeSobjectResult> objectDescribeResultMap= new Map<String,Schema.DescribeSobjectResult>();
     
     /** 
     *private static map variable to hold object api name and map of fields
     */
    private static Map<String, Map<String, Schema.sObjectField>> objectFieldMap = new Map<String,Map<String, Schema.sObjectField>> ();
   
    /** 
     * public static map variable to hold object api name and map of fieldset
     */
    private static Map<String, Map<String, Schema.FieldSet>> objectfieldSetMap = new Map<String, Map<String, Schema.FieldSet>> (); 
   
    /** 
     * public static map variable to hold global setting map
     */
    public static Map<String, Map<String,String>> settingMap = new Map<String, Map<String,String>> ();
    
    private Map<String, Schema.SObjectType> globalDescribe = null;
    
    public static COMM_Utils_DescribeCall getInstance( ) {
      return instance;
    }
    
    public Map<String, Schema.SObjectType> getGlobalDescribeCall( ) {
        
        System.debug(LoggingLevel.DEBUG, 'getGlobalDescribeCall() - enter' );
        try {
            if( System.isBatch() ) {
                return Schema.getGlobalDescribe();
            }
            
            if( globalDescribe == null ) {
                globalDescribe = Schema.getGlobalDescribe();
            }
        }
        catch( Exception e ) {
            
            System.debug(LoggingLevel.DEBUG, 'getGlobalDescribeCall() : Failed to perform global describe. Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug(LoggingLevel.DEBUG, 'getGlobalDescribeCall() - exit' );
        }
        return globalDescribe;
    }
    /**
     * 
     */
    public Schema.DescribeFieldResult describeField( final Schema.SObjectField sObjectField ) {
        
        System.debug(LoggingLevel.DEBUG, 'describeField() - enter' );
        
        Schema.DescribeFieldResult result = null;
        
        try {
            
            if( sObjectField != null ) {
                result = sObjectField.getDescribe();
            } else {
                System.debug(LoggingLevel.ERROR, 'describeField() : Invalid argument. sObjectField=' + sObjectField );
            }
        }
        
        catch( Exception e ) {
            
            System.debug(LoggingLevel.ERROR, 'describeField() : Failed to describe field. Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug(LoggingLevel.DEBUG, 'describeField() - exit' );
        }
        
        return result;
    }
    public Map<String, Schema.sObjectField> getObjectFieldMap( final String objectApiName ) {
        
        System.debug(LoggingLevel.DEBUG, 'getObjectFieldMap() - enter; objectApiName=' + objectApiName );
        
        Map<String, Schema.sObjectField> fieldMap = new Map<String, Schema.sObjectField>();
        
        try {
            
            if( objectFieldMap.containsKey(objectApiName) ) {
                fieldMap =  objectFieldMap.get(objectApiName);
            }
            else
            {
                if( objectDescribeResultMap.containsKey(objectApiName) ) {
                    fieldMap = objectDescribeResultMap.get(objectApiName).fields.getMap();
                } else {
                    
                    Schema.DescribeSobjectResult[] results = Schema.describeSObjects( new List<String> {objectApiName} );
                    if( results != null && !results.isEmpty() ) {
                        fieldMap = results[0].fields.getMap();
                    }
                }
                
                objectFieldMap.put(objectApiName, fieldMap);
            }
        }
        
        catch( Exception e ) {
            
            System.debug(LoggingLevel.ERROR, 'getObjectFieldMap() : Failed to describe object. Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectFieldMap() - exit' );
        }
        
        return fieldMap;
    }
     /**
     * Static method to retrieve map of fields. This method will make sure to return field map 
     * of the provided object api name. If object does not exist in org then it returns null. 
     * This method makes sure that describe call is not made again for the same object in a single
     * transaction.
     * 
     * @return Returns map of fields
     * @example COMM_Utils_DescribeCall.getObjectFieldDetails('Account')
     */
    public static Map<String, Schema.sObjectField> getObjectFieldDetails(String objAPIName){
       Map<String, Schema.sObjectField> fieldMap = new Map<String, Schema.sObjectField>();
       try
       {
            if(objectFieldMap.containsKey(objAPIName))
            {
                fieldMap =  objectFieldMap.get(objAPIName);
            }
            else
            {
                /*
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String> {objAPIName});
                if(results != null && !results.isEmpty())
                {
                    fieldMap = results[0].fields.getMap(); 
                    objectFieldMap.put(objAPIName, fieldMap); 
                }
                */
                //Commented above code and added below code for fixing philips performance issue 047517

                if(objectDescribeResultMap.containsKey(objAPIName) ) {
                    fieldMap = objectDescribeResultMap.get(objAPIName).fields.getMap();
                } else {
                    Schema.DescribeSobjectResult result = COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objAPIName);
                    fieldMap = result.fields.getMap();
                }
                objectFieldMap.put(objAPIName, fieldMap);
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception in getObjectFieldDetails');
        }
        return fieldMap;
    }
    
    /**
     * Static method to retrieve map of field set. This method will make sure to return map of the fieldset
     * of the provided object api name. If object does not exist in org then it returns null. 
     * This method makes sure that describe call is not made again for the same object in a single
     * transaction.
     * 
     * @return Returns map of fieldset
     * @example COMM_Utils_DescribeCall.getObjectFieldSets('Account')
     */
    public static Map<String, Schema.FieldSet> getObjectFieldSets(String objAPIName){
        Map<String, Schema.FieldSet> fieldSetMap = new Map<String, Schema.FieldSet>();
        try
        {
            if(objectfieldSetMap.containsKey(objAPIName))
            {
              fieldSetMap = objectfieldSetMap.get(objAPIName);
            }
            else
            {
                /*
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String> {objAPIName});
                if(results != null && !results.isEmpty())
                {
                    fieldSetMap = results[0].fieldSets.getMap();
                    objectfieldSetMap.put(objAPIName, fieldSetMap);
                }
                */
                //Commented above code and added below code for fixing philips performance issue 047517

                if(objectDescribeResultMap.containsKey(objAPIName) ) {
                    fieldSetMap = objectDescribeResultMap.get(objAPIName).fieldSets.getMap();
                } else {
                    Schema.DescribeSobjectResult result = COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objAPIName);
                    fieldSetMap = result.fieldSets.getMap();
                }
                objectfieldSetMap.put(objAPIName, fieldSetMap);
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Exception in getObjectFieldSets');
        }
        return fieldSetMap;  
    }

        
    /**
     * Static method to retrieve map of settings. This method will make sure to return map of the settings
     * of the provided sub module id.
     * 
     * @return Returns map of fieldset
     * @example COMM_Utils_DescribeCall.getObjectFieldSets('Account')
     */
    public Map<String, Map<String,String>> getSettings(String submoduleId){
        if(settingMap.containsKey(submoduleId)){
            return settingMap;
        }
        else{
            COMM_Utils_ManageSettings manageSetting = new COMM_Utils_ManageSettings();
            Map<String, Map<String,String>> setting = manageSetting.SVMX_getSettingList(new List<String> {submoduleId});
            settingMap.putAll(setting);
            return settingMap;
        }
        
    }
    /**
     * Method to retrieve specific object  picklist. This method required to pass as object name and fieldname as a parameter
     * 
     * @return Map<String,String>
     * 
     */
    public Map<String,String> getDefaultPicklistValue(String objName, List<String> fieldName)
    {
        System.debug(LoggingLevel.DEBUG, objName + fieldName);
        String defVal;
        Map<String,String> mapofDefaulPickList = new Map<String,String>();
        try{

            Map<String,Schema.SObjectField> objfieldMap = getObjectFieldDetails(objName);

            if(objfieldMap != null && !objfieldMap.isEmpty()){
                for(Integer i = 0; i < fieldName.size(); i++)
                {     
                    for(Schema.SObjectField fld:objfieldMap.values())
                    {
                       Schema.DescribeFieldResult fso = fld.getDescribe();
                      
                       if(fso != null &&  fso.getname() == fieldName[i])
                       {
                            if(fso.getType() == Schema.DisplayType.PickList)
                            {
                                List<Schema.PicklistEntry> p = fso.getPicklistValues(); // returing picklist values
                                for(Integer v=0;v<p.size();v++)
                                {
                                    if(p[v].isDefaultValue()) // check for default value
                                    {
                                        defVal = p[v].getValue();
                                        if(defVal != null && defVal.length()> 0)
                                            mapofDefaulPickList.put(fieldName[i],defVal);
                                    }  
                                }
                             } 
                             break;  
                         }
                     }  
                }
            }
            else
            {
             System.debug(LoggingLevel.WARN,'Either objfieldMap is null or empty');
            } 
        }catch(Exception e)
        {
            System.debug(LoggingLevel.ERROR, 'Exception in getDefaultPicklistValue');
        }
        return mapofDefaulPickList;
    }
    
    /**
     * Method to retrieve specific object describe. This method required to pass as object name api as a parameter
     * 
     * @return DescribeSobjectResult of object
     * @example COMM_Utils_DescribeCall.getObjectDescribe('Account')
     */
    public Schema.DescribeSobjectResult getObjectDescribe(String objAPIName)
    {
        Schema.DescribeSobjectResult result = null;
        try{
        
            if(objectDescribeResultMap.containsKey(objAPIName))
            {
                result = objectDescribeResultMap.get(objAPIName);
            }
            else
            {
                Schema.DescribeSobjectResult[] results = getObjectDescribe(new List<String>{objAPIName});
                if(!results.isEmpty())
                {
                    result = results[0];
                }
            }
        }
        catch(Exception e)
        {
          System.debug(LoggingLevel.ERROR, 'Exception in getObjectDescribe');
        }
        return result;
    }
    //BAC-5355
    /**
     * Method to retrieve list of object describe. This method required to pass as list of specific object name api as a parameter
     * 
     * @return DescribeSobjectResult of object
     * @example COMM_Utils_DescribeCall.getObjectDescribe(List<String>{'Account'})
     */
    public List<Schema.DescribeSobjectResult> getObjectDescribe(List<String> objectAPINameList)
    {
        System.debug('getObjectDescribe() - enter');
        List<Schema.DescribeSobjectResult> describeSobjectResultList = new List<Schema.DescribeSobjectResult>();
        List<String> descList = new List<String>();
        try {
            
            for( String objectName : objectAPINameList ) {
            
                if(!objectDescribeResultMap.containsKey(objectName)) {
                    descList.add(objectName);
                } else {
                    describeSobjectResultList.add(objectDescribeResultMap.get(objectName) );
                }
            }
            if(!descList.isEmpty()) {
                /*
                List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(descList);
                for(Schema.DescribeSobjectResult result : results) {
                    objectDescribeResultMap.put( result.getName(), result);
                    describeSobjectResultList.add(result);
                }
                */
                //Commented above code and added below code for fixing philips performance issue 047517

                for (String objName : descList) {
                    Schema.DescribeSobjectResult result = ((SObject)(Type.forName('Schema.'+objName).newInstance())).getSObjectType().getDescribe();
                    objectDescribeResultMap.put(result.getName(), result);
                    describeSobjectResultList.add(result);
                }
            }    
        }
        catch(Exception e ) {
            System.debug(LoggingLevel.ERROR, 'Exception in getObjectDescribe');
        }
        
        finally {
            System.debug(LoggingLevel.DEBUG,'getObjectDescribe() - exit');
        }
        return describeSobjectResultList;
    }
    
}