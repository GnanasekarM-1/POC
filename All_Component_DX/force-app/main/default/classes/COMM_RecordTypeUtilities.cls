/*****************************************************************************
*                       Copyright (C) 2018 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The class COMM_RecordTypeUtilities implements utility methods which is used across all apex class for getting record type details.
*
* @author Soumyaranjan Pati
* @version V.5
* @since 2018
*/
/*****************************************************************************************************
*    ID        Name                     Date            Comment
*****************************************************************************************************
*              Soumyaranjan Pati      31st Oct 2018     Created. 
*****************************************************************************************************/

public class COMM_RecordTypeUtilities {
    
    /** Name - getObjectRecordTypeId
    * This method is used to get the recordType id with given recordTypeName. 
    * 
    * @param objectAPIName and recordTypeName.
    * @return recordType id.
    * 
    * objectAPIName -: Any object name as string format
    * recordTypeName -: recordTypeName for given Sobject.
    * 
    * @exception no.
    */
    public static String getObjectRecordTypeId(String objectAPIName, String recordTypeName)
    {
        if(objectAPIName == null || objectAPIName == '' || recordTypeName == null || recordTypeName == '')
            return null;
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = new Map<String,Schema.RecordTypeInfo>();
        try{
        List<String> lstobjectAPIName = new List<String>();
        lstobjectAPIName.add(objectAPIName);
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>(lstobjectAPIName));
        //Generate a map of tokens for all the Record Types for the desired object 
        recordTypeInfo = results[0].getRecordTypeInfosByDeveloperName();

        if(!recordTypeInfo.containsKey(recordTypeName))
            return null;
        else
            //Retrieve the record type id by name
            return recordTypeInfo.get(recordTypeName).getRecordTypeId();
        }catch(Exception e){
            return null;
        }finally{
            recordTypeInfo=null;
        }
    }
    
    
    
    /** Name - getObjectRecordTypeId
    * This method is used to get the recordType id with given recordTypeName. 
    * 
    * @param objectAPIName and recordTypeName.
    * @return recordType id.
    * 
    * objectAPIName -: Any object name as SObjectType format
    * recordTypeName -: recordTypeName for given Sobject.
    * 
    * @exception no.
    */
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName)
    {
        if(sObjectType == null || recordTypeName == null || recordTypeName == '')
            return null;
        Map<string, Schema.RecordTypeInfo> recordTypeInfo = new Map<string, Schema.RecordTypeInfo>();
        try{
        //Generate a map of tokens for all the Record Types for the desired object
        //recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();
        recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

        if(!recordTypeInfo.containsKey(recordTypeName))
            return null;
        else
            //Retrieve the record type id by name
            return recordTypeInfo.get(recordTypeName).getRecordTypeId();
        }catch(Exception e){
            return null;
        }finally{
            recordTypeInfo=null;
        }
    }
    /** Name - getObjectRecordTypeId
    * This method is used to get the recordType id with given list of lstrecordTypeName. 
    * 
    * @param objectAPIName and lstrecordTypeName.
    * @return recordType id.
    * 
    * objectAPIName -: Any object name as SObjectType format
    * lstrecordTypeName -: List of recordTypeName for given Sobject.
    * 
    * @exception no.
    */
    public static Map<String,Id> getObjectRecordTypeId(String objectAPIName, List<String> lstrecordTypeName)
    {
        if(objectAPIName == null || lstrecordTypeName == null || lstrecordTypeName.size() == 0)
            return null;
        Map<String,Id> mapReturnData = new Map<String,Id>();
        Map<string, Schema.RecordTypeInfo> recordTypeInfo = new Map<string, Schema.RecordTypeInfo>();
        try{
        /*
        List<String> lstobjectAPIName = new List<String>();
        lstobjectAPIName.add(objectAPIName);
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>(lstobjectAPIName));
        //Generate a map of tokens for all the Record Types for the desired object
        recordTypeInfo = results[0].getRecordTypeInfosByDeveloperName();
        */
        //Commented above code and added below code for fixing philips performance issue 047517
        Schema.DescribeSobjectResult result = COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objectAPIName);
        recordTypeInfo = result.getRecordTypeInfosByDeveloperName();
        
        for(String recordTypeName:lstrecordTypeName){
            if(recordTypeInfo.containsKey(recordTypeName))
                mapReturnData.put(recordTypeName,recordTypeInfo.get(recordTypeName).getRecordTypeId());
        }
        if(mapReturnData.size()>0){
            return mapReturnData;
        }else{
            return null;
        }
        }catch(Exception e){
            return null;
        }finally{
            recordTypeInfo=null;
        }
    }
    
    public static Map<String,Id> getObjectRecordTypeId( String objectAPIName ) {
        
        System.debug(LoggingLevel.DEBUG, 'getObjectRecordTypeId() - enter; objectAPIName= '+ objectAPIName );
        
        final Map<String,Id> mapReturnData = new Map<String,Id>();
        
        try {
            
            Map<String, Schema.RecordTypeInfo> recordTypeInfo = new Map<String, Schema.RecordTypeInfo>();
            //Schema.DescribeSobjectResult[] results = Schema.describeSObjects( new List<String>{objectAPIName} );
            Schema.DescribeSobjectResult result = COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objectAPIName);
            //if( results != null && results.size() > 0 ) {
            if( result != null ) {
                //recordTypeInfo = results[0].getRecordTypeInfosByDeveloperName();
                recordTypeInfo = result.getRecordTypeInfosByDeveloperName();
            }
            
            for(String recordTypeName : recordTypeInfo.keySet() ) {
                mapReturnData.put(recordTypeName,recordTypeInfo.get(recordTypeName).getRecordTypeId());
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'getObjectRecordTypeId(): Failed to retrieve record type id. Error: ' + e.getStackTraceString() );
        }
        
        finally {
            System.debug(LoggingLevel.DEBUG, 'getObjectRecordTypeId() - exit;' );
        }
        
        return mapReturnData;
    }

    // This method is used to get record type name and its corresponding id, todo:- need to store in
    // cache 
    public static Map<String,Id> getObjectRecordTypeNameId( String objectAPIName ) {
        
        System.debug(LoggingLevel.DEBUG, 'getObjectRecordTypeNameId() - enter; objectAPIName= '+ objectAPIName );
        
        final Map<String,Id> mapReturnData = new Map<String,Id>();
        
        try {
            
            Map<String, Schema.RecordTypeInfo> recordTypeInfo = new Map<String, Schema.RecordTypeInfo>();
            //Schema.DescribeSobjectResult[] results = Schema.describeSObjects( new List<String>{objectAPIName} );
            Schema.DescribeSobjectResult result = COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objectAPIName);
            //if( results != null && results.size() > 0 ) {
            if( result != null ) {
                //recordTypeInfo = results[0].getRecordTypeInfosByDeveloperName();
                recordTypeInfo = result.getRecordTypeInfosByName();
            }
            
            for(String recordTypeName : recordTypeInfo.keySet() ) {
                mapReturnData.put(recordTypeName,recordTypeInfo.get(recordTypeName).getRecordTypeId());
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'getObjectRecordTypeNameId(): Failed to retrieve record type id. Error: ' + e.getStackTraceString() );
        }
        
        finally {
            System.debug(LoggingLevel.DEBUG, 'getObjectRecordTypeNameId() - exit;' );
        }
        
        return mapReturnData;
    }
}