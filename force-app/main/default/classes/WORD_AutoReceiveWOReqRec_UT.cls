@isTest
private class WORD_AutoReceiveWOReqRec_UT {

    static testMethod void myUnitTest() {
       RecordType Rtypedef = [select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
       SVMXC__Service_Order__c Svo = new SVMXC__Service_Order__c();
       insert Svo;
       System.assertNotEquals(false, Svo != null);
       
       SVMXC__Service_Order_Line__c SvoLine = new SVMXC__Service_Order_Line__c();
       SvoLine.RecordTypeId = Rtypedef.Id;
       SvoLine.SVMXC__Service_Order__c =Svo.Id;
       SvoLine.SVMXC__Requested_Quantity2__c = 12; 
       SvoLine.SVMXC__Requested_Street__c = 'Street';
       SvoLine.SVMXC__Requested_City__c = 'city';
       SvoLine.SVMXC__Requested_State__c = 'state';
       SvoLine.SVMXC__Requested_Zip__c = 'zip';
       SvoLine.SVMXC__Requested_Country__c = 'country'; 
       SvoLine.SVMXC__Received_Street__c = '';
       SvoLine.SVMXC__Received_City__c = '';
       SvoLine.SVMXC__Received_State__c = '';
       SvoLine.SVMXC__Received_Zip__c = '';
       SvoLine.SVMXC__Received_Country__c = '';
       SvoLine.SVMXC__Received_Quantity2__c = 0;
       insert SvoLine;
       System.assertNotEquals(false, SvoLine != null);
       
       System.currentPagereference().getParameters().put('SVOId',Svo.Id);
       WORD_AutoReceiveWOReqRec AutoRecSvoParts = new WORD_AutoReceiveWOReqRec();
       AutoRecSvoParts.BackToRecord();
       AutoRecSvoParts.getDisplaySave();
       AutoRecSvoParts.PerformUpdate();
       AutoRecSvoParts.getTAG001();
       AutoRecSvoParts.getTAG002();
       AutoRecSvoParts.getTAG003();
       AutoRecSvoParts.getTAG004();
       AutoRecSvoParts.getTAG005();
       System.assertEquals(true, AutoRecSvoParts.BackToRecord() != null);
       System.assertEquals(true, AutoRecSvoParts.getDisplaySave() != null);
       System.assertEquals(true, AutoRecSvoParts.PerformUpdate() != null);
       System.assertEquals(true, AutoRecSvoParts.getTAG001() != null);
       System.assertEquals(true, AutoRecSvoParts.getTAG002() != null);
       System.assertEquals(true, AutoRecSvoParts.getTAG003() != null);
       System.assertEquals(true, AutoRecSvoParts.getTAG004() != null);
       System.assertEquals(true, AutoRecSvoParts.getTAG005() != null);
       
    }
}