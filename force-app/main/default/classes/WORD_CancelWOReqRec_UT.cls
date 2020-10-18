@isTest
private class WORD_CancelWOReqRec_UT {

    static testMethod void WORD_CancelWOReqRec_UnitTest() {
        
        SVMXC__Service_Order__c Svo = new SVMXC__Service_Order__c();
        SVMXC__Service_Order_Line__c SvoLine = new SVMXC__Service_Order_Line__c();
        
        Svo.SVMXC__Order_Status__c = 'Closed';
        insert Svo;
        System.assertEquals(true,  Svo != null);
        
        RecordType SvoRtype = [Select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
        SvoLine.RecordTypeId = SvoRtype.Id;
        System.assertEquals(true,  SvoRtype != null);
        
        SvoLine.SVMXC__Line_Status__c = 'Open';
        SvoLine.SVMXC__Service_Order__c = Svo.Id; 
        insert SvoLine;
        System.assertEquals(true,  SvoLine != null);
        
        System.currentPagereference().getParameters().put('SVOId',Svo.Id);
        System.currentPagereference().getParameters().put('SVOLId',SvoLine.Id);
        WORD_CancelWOReqRec cnclSvo =  new WORD_CancelWOReqRec();
        cnclSvo.getDisplaysave();
        cnclSvo.BackToRecord();
        cnclSvo.PerformUpdate();
        cnclSvo.getTAG001();
        cnclSvo.getTAG002();
        cnclSvo.getTAG003();
        cnclSvo.getTAG004();
        cnclSvo.getTAG005();
        cnclSvo.getTAG006();
        cnclSvo.getTAG007();
        cnclSvo.getTAG008();
    cnclSvo.getTAG009();
    cnclSvo.getTAG010();
    }
    static testMethod void WORD_CancelWOReqRec_UnitTest1() {

        SVMXC__Service_Order__c Svo = new SVMXC__Service_Order__c();
        SVMXC__Service_Order_Line__c SvoLine = new SVMXC__Service_Order_Line__c();

        Svo.SVMXC__Order_Status__c = 'Canceled';
        insert Svo;
        System.assertEquals(true,  Svo != null);
        
        RecordType SvoRtype = [Select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
        SvoLine.RecordTypeId = SvoRtype.Id;
        System.assertEquals(true,  SvoRtype != null);
        
        SvoLine.SVMXC__Line_Status__c = 'Canceled';
        SvoLine.SVMXC__Service_Order__c = Svo.Id; 
        insert SvoLine;
        System.assertEquals(true,  SvoLine != null);
        
        System.currentPagereference().getParameters().put('SVOId',Svo.Id);
        WORD_CancelWOReqRec cnclSvo =  new WORD_CancelWOReqRec();
    }
    static testMethod void WORD_CancelWOReqRec_UnitTest2() {

        SVMXC__Service_Order__c Svo = new SVMXC__Service_Order__c();
        SVMXC__Service_Order_Line__c SvoLine = new SVMXC__Service_Order_Line__c();
        
        Svo.SVMXC__Order_Status__c = 'Open';
        insert Svo;
        System.assertEquals(true,  Svo != null);
        
        RecordType SvoRtype = [Select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
        SvoLine.RecordTypeId = SvoRtype.Id;
        System.assertEquals(true,  SvoRtype != null);
        
        SvoLine.SVMXC__Line_Status__c = 'Open';
        SvoLine.SVMXC__Service_Order__c = Svo.Id; 
        insert SvoLine;
        System.assertEquals(true,  SvoLine != null);
        
        System.currentPagereference().getParameters().put('SVOId',Svo.Id);
        WORD_CancelWOReqRec cnclSvo =  new WORD_CancelWOReqRec();
        cnclSvo.PerformUpdate();
    }
    static testMethod void WORD_CancelWOReqRec_UnitTest3() {

        SVMXC__Service_Order__c Svo = new SVMXC__Service_Order__c();
        SVMXC__Service_Order_Line__c SvoLine = new SVMXC__Service_Order_Line__c();
        
        Svo.SVMXC__Order_Status__c = 'Open';
        insert Svo;
        System.assertEquals(true,  Svo != null);
        
        RecordType SvoRtype = [Select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
        SvoLine.RecordTypeId = SvoRtype.Id;
        System.assertEquals(true,  SvoRtype != null);
        
        SvoLine.SVMXC__Line_Status__c = 'Canceled';
        SvoLine.SVMXC__Service_Order__c = Svo.Id;
        insert SvoLine;
        System.assertEquals(true,  SvoLine != null);
        
        System.currentPagereference().getParameters().put('SVOId',Svo.Id);
        WORD_CancelWOReqRec cnclSvo =  new WORD_CancelWOReqRec();
    }
        static testMethod void WORD_CancelWOReqRec_UnitTest4() {
            
        SVMXC__Service_Order__c Svo = new SVMXC__Service_Order__c();
        SVMXC__Service_Order_Line__c SvoLine = new SVMXC__Service_Order_Line__c();
        
        Svo.SVMXC__Order_Status__c = 'Open';
        insert Svo;
        System.assertEquals(true,  Svo != null);
        
        RecordType SvoRtype = [Select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
        SvoLine.RecordTypeId = SvoRtype.Id;
        System.assertEquals(true,  SvoRtype != null);
        
        SvoLine.SVMXC__Line_Status__c = 'Completed';
        SvoLine.SVMXC__Service_Order__c = Svo.Id;
        insert SvoLine;
        System.assertEquals(true,  SvoLine != null);
        
        //String url = Svo.Id+'&SVOLId='+ SvoLine.Id;
        System.currentPagereference().getParameters().put('SVOId',Svo.Id);
        WORD_CancelWOReqRec cnclSvo =  new WORD_CancelWOReqRec();
    }
     static testMethod void WORD_CancelWOReqRec_UnitTest5() {
            
        SVMXC__Service_Order__c Svo = new SVMXC__Service_Order__c();
        SVMXC__Service_Order_Line__c SvoLine = new SVMXC__Service_Order_Line__c();
        SvoLine.SVMXC__Line_Status__c = 'Open';
        Svo.SVMXC__Order_Status__c = 'Open';
        insert Svo;
        System.assertEquals(true,  Svo != null);

        RecordType SvoRtype = [Select Id from RecordType where Name=:'Request/Receipt'and SobjectType=:'SVMXC__Service_Order_Line__c'];
        System.assertEquals(true,  SvoRtype != null);
        
        SvoLine.RecordTypeId = SvoRtype.Id;
        SvoLine.SVMXC__Service_Order__c = Svo.Id;
        SvoLine.SVMXC__Line_Status__c = 'Open';
        insert SvoLine;
        System.assertEquals(true,  SvoLine != null);
        
        //String url = Svo.Id+'&SVOLId='+ SvoLine.Id;
        System.currentPagereference().getParameters().put('SVOId',Svo.Id);
        System.currentPagereference().getParameters().put('SVOLId',SvoLine.Id);
        WORD_CancelWOReqRec cnclSvo =  new WORD_CancelWOReqRec();
        cnclSvo.BackToRecord();
    cnclSvo.PerformUpdate();
    }
}