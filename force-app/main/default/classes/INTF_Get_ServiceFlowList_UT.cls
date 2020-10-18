@isTest
private with sharing class INTF_Get_ServiceFlowList_UT {

static testmethod void test1()
{
    List<RecordType> RtypeLst = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'SVMXC__ServiceMax_Processes__c' AND Name='Target Manager'];
    SVMXC__ServiceMax_Processes__c processNodes = new SVMXC__ServiceMax_Processes__c();
    processNodes.RecordTypeId=RtypeLst[0].Id;
    processNodes.SVMXC__Purpose__c = 'VIEW RECORD';
    processNodes.SVMXC__IsDefault__C=true;
    processNodes.SVMXC__ProcessID__c='servicemax001';
    insert processNodes;
    System.assertEquals(true, processNodes.SVMXC__Purpose__c != null);
    System.assertEquals(true, processNodes.SVMXC__ProcessID__c != null);
    System.assertEquals(true, processNodes.SVMXC__IsDefault__C != null);
     
    SVMXC__ServiceMax_Processes__c processNodes2 = new SVMXC__ServiceMax_Processes__c();
    processNodes2.RecordTypeId=RtypeLst[0].Id;
    processNodes2.SVMXC__Purpose__c = 'VIEW RECORD';
    processNodes2.SVMXC__IsDefault__C=true;
    processNodes2.SVMXC__ProcessID__c='servicemax001';
    insert processNodes2;
    System.assertEquals(true, processNodes2.SVMXC__Purpose__c != null);
    System.assertEquals(true, processNodes2.SVMXC__ProcessID__c != null);
    
    SVMXC__ServiceMax_Processes__c processNodes3 = new SVMXC__ServiceMax_Processes__c();
    processNodes3.RecordTypeId=RtypeLst[0].Id;
    processNodes3.SVMXC__Purpose__c = 'STANDALONE CREATE';
    processNodes3.SVMXC__IsDefault__C=true;
    processNodes3.SVMXC__ProcessID__c='servicemax001';
    insert processNodes3;
    
    SVMXC__ServiceMax_Processes__c processNodes4 = new SVMXC__ServiceMax_Processes__c();
    processNodes4.RecordTypeId=RtypeLst[0].Id;
    processNodes4.SVMXC__Purpose__c = 'STANDALONE CREATE';
    processNodes4.SVMXC__IsDefault__C=true;
    processNodes4.SVMXC__ProcessID__c='servicemax001';
    insert processNodes4;
    
    SVMXC__ServiceMax_Processes__c processNodes5 = new SVMXC__ServiceMax_Processes__c();
    processNodes5.RecordTypeId=RtypeLst[0].Id;
    processNodes5.SVMXC__Type__c = 'TARGET';
    processNodes5.SVMXC__IsDefault__C=true;
    processNodes5.SVMXC__ProcessID__c = 'TESTPROCESS111';
    processNodes5.SVMXC__Source_Object_Name__c = 'OBJECT1';
    processNodes5.SVMXC__Process__c=processNodes4.Id;
    insert processNodes5;
    
    SVMXC__ServiceMax_Processes__c processNodes6 = new SVMXC__ServiceMax_Processes__c();
    processNodes6.RecordTypeId=RtypeLst[0].Id;
    processNodes6.SVMXC__Type__c = 'TARGET';
    processNodes6.SVMXC__IsDefault__C=true;
    processNodes6.SVMXC__ProcessID__c = 'TESTPROCESS111';
    processNodes6.SVMXC__Source_Object_Name__c = 'OBJECT1';
    processNodes6.SVMXC__Process__c=processNodes4.Id;
    insert processNodes6;
    
    INTF_Get_ServiceFlowList  layout = new INTF_Get_ServiceFlowList();
    layout.INTF_Get_View_Layouts();
    layout.INTF_Get_StandaloneCreate_Layouts();
}

}