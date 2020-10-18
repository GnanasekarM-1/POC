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
private class SVMXDescribeObjectUtils_UT {

    static testMethod void myUnitTest() {
        SVMXC__Object_Cache__c objOC = new SVMXC__Object_Cache__c();
        objOC.SVMXC__Object_API_Name__c = 'SVMXC__Site__c';
        insert objOC;
        
        SVMXC__Field_Cache__c objFC = new SVMXC__Field_Cache__c();
        objFC.SVMXC__Field_API_Name__c = 'RecordTypeId';
        objFC.SVMXC__Object_Cache__c = objOC.id;
        insert objFC;
        SVMXC__Field_Cache__c objFC1 = new SVMXC__Field_Cache__c();
        objFC1.SVMXC__Field_API_Name__c = 'SVMXC__Location_Type__c';
        objFC1.SVMXC__Object_Cache__c = objOC.id;
        insert objFC1;
        SVMXC__Field_Cache__c objFC2 = new SVMXC__Field_Cache__c();
        objFC2.SVMXC__Field_API_Name__c = 'SVMXC__Country__c';
        objFC2.SVMXC__Object_Cache__c = objOC.id;
        insert objFC2;
    
        list<SVMXC__Picklist_Cache__c> lstPC = new list<SVMXC__Picklist_Cache__c>();    
        SVMXC__Picklist_Cache__c objPC = new SVMXC__Picklist_Cache__c();
        objPC.SVMXC__Source_Field__c = objFC.id;
        objPC.SVMXC__Target_Field__c = objFC1.id;
        objPC.SVMXC__Source_Value__c = 'BLABLA';
        objPC.SVMXC__Target_Value__c = '0;1;2';
        insert objPC;
        
        SVMXDescribeObjectUtils dou = new SVMXDescribeObjectUtils();
        dou.getDescribe('SVMXC__Site__c');
    
        SVMXDescribeObjectUtils.SaveObjectDescriptionRequest saveobj = new SVMXDescribeObjectUtils.SaveObjectDescriptionRequest();
        SVMXDescribeObjectUtils.RecordTypeMappings rtMap =  new SVMXDescribeObjectUtils.RecordTypeMappings();
        SVMXDescribeObjectUtils.PicklistForRecordType plRtype = new SVMXDescribeObjectUtils.PicklistForRecordType();
        SVMXDescribeObjectUtils.ObjectDescription objDesc = new SVMXDescribeObjectUtils.ObjectDescription();
        SVMXDescribeObjectUtils.PicklistResultFromDescribe prDesc = new SVMXDescribeObjectUtils.PicklistResultFromDescribe();
        SVMXDescribeObjectUtils.ObjectPicklistFieldEntry opfe = new SVMXDescribeObjectUtils.ObjectPicklistFieldEntry();
        SVMXDescribeObjectUtils.PicklistResultFromCache prfc = new SVMXDescribeObjectUtils.PicklistResultFromCache();
        SVMXDescribeObjectUtils.DependendPicklist dp = new SVMXDescribeObjectUtils.DependendPicklist();
    }
}