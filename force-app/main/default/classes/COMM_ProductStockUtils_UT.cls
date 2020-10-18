/*****************************************************************************
*                       Copyright (C) 2020 ServiceMax, Inc
*                               All rights reserved
*
*****************************************************************************/

/**
* The class COMM_ProductStockUtils_UT is the UT class for COMM_ProductStockUtils.
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
@isTest
public class COMM_ProductStockUtils_UT {
//TODO
    static testMethod void checkProductStock() {
        Product2 prod = new Product2();
        prod.name = 'TestProduct product stock';
        insert prod;

        Account acc = new Account();
        acc.Name = 'Acc Name';
        insert acc;

        SVMXC__Site__c loc = new SVMXC__Site__c ();
        loc.Name = 'Bangalore';
        loc.SVMXC__Street__c = 'Bangalore Central';
        loc.SVMXC__Country__c = 'India';
        loc.SVMXC__Zip__c = '560048';
        loc.SVMXC__Account__c = acc.id;
        insert loc;

        SVMXC__Product_Stock__c productStockVar = new SVMXC__Product_Stock__c ();
        productStockVar.SVMXC__Product__c = prod.id;
        productStockVar.SVMXC__Location__c = loc.id;
        productStockVar.SVMXC__Quantity2__c = 10;
        productStockVar.SVMXC__Reorder_Level2__c = 12;
        productStockVar.SVMXC__Reorder_Quantity2__c = 8;
        productStockVar.SVMXC__Status__c = 'DECREASED';
        insert productStockVar;

        String searchString = 'SVMXC__Status__c !=null ';
        List<SVMXC__Product_Stock__c> listProductStock = COMM_ProductStockUtils.getProductsList(1, 1, 1, searchString, String.valueOf(loc.id),'SVMXC__Available_Qty__c', 'asc');
        Integer countlistProductStock = COMM_ProductStockUtils.getProductsCount(searchString, String.valueOf(loc.id));
    }
}