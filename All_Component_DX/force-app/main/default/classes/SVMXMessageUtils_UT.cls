/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SVMXMessageUtils_UT {

    static testMethod void SVMXMessageUtilsTest() {
        // TO DO: implement unit test
        RecordType depotParent = [select id, Name from RecordType where Name = 'Depot Parent'and SobjectType='SVMXC__Site__c' Limit 1];
        SVMXC.SVMXMessageUtils msgUtils = new SVMXC.SVMXMessageUtils();
        SVMXC__Site__c objLocation = new SVMXC__Site__c();
        objLocation.RecordTypeId = depotParent.Id;
        objLocation.Name = 'Mysore';
        insert objLocation;
        SVMXC__Parts_Request__c objPR = new SVMXC__Parts_Request__c(); 
        objPR.SVMXC__Requested_From__c = objLocation.id;
        objPR.SVMXC__Required_At_Location__c = objLocation.id;
        objPR.SVMXC__Status__c='open';
        try{
            insert objPR;
        }
        catch(Exception ex){
            msgUtils.buildExceptionMessage(ex,'Bla','Bla');
            msgUtils.buildExceptionMessage(ex,null,'Bla');  
        }
         try{
            throw new SecurityException('You dont have access.');
        }catch(Exception ex){
            msgUtils.buildExceptionMessage(ex,'Bla','Bla');
        }   
    }
}