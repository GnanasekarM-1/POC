/*****************************************************************************
*                       Copyright (C) 2020 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The class COMM_ProductStockUtils used to get the data for ProductStock.
* This call is used by ProductStock LWC component
*
* @author Soumyaranjan Pati
* @version V.1
* @since 2020
*/
/*****************************************************************************************************
*    ID        Name                     Date            Comment
*****************************************************************************************************
*              Soumyaranjan Pati      2nd Aprl 2020     Created. 
*****************************************************************************************************/
public with sharing class COMM_ProductStockUtils{
    @AuraEnabled(cacheable = true)  
   public static List<SVMXC__Product_Stock__c> getProductsList(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String searchString, String sfdcRecordId,String sortByfield, String sortOrder) { 
     //Check Field Security Check
        List<String> queryFields = new List<String> {'SVMXC__Product__c', 'SVMXC__Status__c', 'SVMXC__Quantity2__c', 'SVMXC__Available_Qty__c', 'SVMXC__Required_Quantity2__c', 'SVMXC__Reorder_Quantity2__c'};
        if( ! COMM_SecurityUtils.getInstance().verifyFieldAccess( 'SVMXC__Product_Stock__c', queryFields, COMM_SecurityUtils.Access.Accessible ) ) {
            throw new COMM_SecurityUtils.SecurityAccessException( System.Label.COMM001_TAG142 );
        }
     //End of Check Field Security Check
     String query = 'select Id, SVMXC__Product__r.Name, SVMXC__Quantity2__c, SVMXC__Available_Qty__c, SVMXC__Required_Quantity2__c, SVMXC__Reorder_Quantity2__c,SVMXC__Status__c, Name from SVMXC__Product_Stock__c ';  
      
     if(sfdcRecordId != null){
         query += 'where SVMXC__Location__c =\''+ sfdcRecordId+'\'';
     }
     
     if (searchString != null && searchString != '') {  
       query += ' and ' + searchString;  
     }
     query += 'ORDER BY '+sortByfield+' '+sortOrder+' ';
     query += ' limit ' + pageSize + ' offset ' + (pageSize * (pagenumber - 1)); 
     System.debug('query '+query); 
     return Database.query(query);  
   }  
   @AuraEnabled(cacheable = true)  
   public static Integer getProductsCount(String searchString, String sfdcRecordId) {  
     String query = 'select count() from SVMXC__Product_Stock__c '; 
     if(sfdcRecordId != null){
         query += 'where SVMXC__Location__c =\''+ sfdcRecordId+'\'';
     } 
     
     if (searchString != null && searchString != '') {  
       query += ' and ' + searchString;  
     }  
     System.debug('query '+query); 
     return Database.countQuery(query);  
   } 
}