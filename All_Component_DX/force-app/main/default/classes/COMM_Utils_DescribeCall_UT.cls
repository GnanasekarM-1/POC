/*****************************************************************************
 *                       Copyright (C) 2019 ServiceMax, Inc
 *                               All rights reserved
 *
 * Created this class for story BAC-5355.
 * COMM_Utils_DescribeCall_UT is unit testing class of the class COMM_Utils_DescribeCall
 *
 * @author Jaysukh patel
 * @version 19.99007
 * @since 2019
 *
 *****************************************************************************/
@isTest(SeeAllData=false)
private class COMM_Utils_DescribeCall_UT {

    @isTest static void test_getObjectFieldDetails() {
        
        Test.startTest();
        
        COMM_Utils_DescribeCall.getObjectFieldDetails('SVMXC__Service_Order__c');
        COMM_Utils_DescribeCall.getObjectFieldDetails('SVMXC__Service_Order__c');
        COMM_Utils_DescribeCall.getObjectFieldDetails(null);
        
        Test.stopTest();
    }
    @isTest static void test_getObjectFieldSets() {
   
        Test.startTest();
        
        COMM_Utils_DescribeCall.getObjectFieldSets('SVMXC__Service_Order__c');
        COMM_Utils_DescribeCall.getObjectFieldSets('SVMXC__Service_Order__c');
        COMM_Utils_DescribeCall.getObjectFieldSets(null);
        
        Test.stopTest();
    }
    
    @isTest static void test_getGlobalDescribeCall()
    {
        Test.startTest();
        
        COMM_Utils_DescribeCall.getInstance().getGlobalDescribeCall();
        
        Test.stopTest();

    }
    @isTest static void test_getSettings()
    {
        Test.startTest();
        
        COMM_Utils_DescribeCall.getInstance().getSettings('GLOB001_GBL031');
        Test.stopTest();

    }
    @isTest static void test_getDefaultPicklistValue()
    {
        Test.startTest();
        
        List<String> fieldName = new List<String>();
        fieldName.add('SVMXC__Billing_Type__c');
        fieldName.add('SVMXC__Order_Status__c');
        fieldName.add('SVMXC__Priority__c');
        fieldName.add('ID');
        COMM_Utils_DescribeCall.getInstance().getDefaultPicklistValue('SVMXC__Service_Order__c',fieldName);
        COMM_Utils_DescribeCall.getInstance().getDefaultPicklistValue('SVMXC__Service_Order__c',null);
        COMM_Utils_DescribeCall.getInstance().getDefaultPicklistValue(null,fieldName);
        

    }
    @isTest static void test_getObjectDescribe()
    {
        Test.startTest();
        List<String> objectApiNameList = new List<String>();
        objectApiNameList.add('SVMXC__Service_Order__c');
        objectApiNameList.add('Account');
        COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objectApiNameList[0]);
        COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objectApiNameList[0]);
        COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objectApiNameList);
        
        List<String> objApiNameListnull = null;
        COMM_Utils_DescribeCall.getInstance().getObjectDescribe(objApiNameListnull);
        Test.stopTest();
    }
}