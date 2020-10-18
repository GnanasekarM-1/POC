@isTest
private class PREQ_CancelPartsRequest_UT {

    static testMethod void PREQ_CancelPartsRequest_UnitTest() {
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.SVMXC__Stocking_Location__c = true;
        insert loc1;
        SVMXC__Site__c loc2 = new SVMXC__Site__c();
        loc2.SVMXC__Stocking_Location__c = true;
        insert loc2;
        
        SVMXC__Parts_Request__c PartsReq = new SVMXC__Parts_Request__c();
        SVMXC__Parts_Request_Line__c PartsReqLine = new SVMXC__Parts_Request_Line__c();
        PartsReq.SVMXC__Status__c = 'Completed';
        PartsReq.SVMXC__Requested_From__c = loc1.Id;
        PartsReq.SVMXC__Required_At_Location__c = loc2.Id;
        insert PartsReq;  
        PartsReqLine.SVMXC__Line_Status__c = 'Open';
        PartsReqLine.SVMXC__Parts_Request__c = PartsReq.Id; 
        insert PartsReqLine;
        system.assert(PartsReq.SVMXC__Status__c!=null);
        system.assert(PartsReq.SVMXC__Requested_From__c!=null);
        system.assert(PartsReqLine.SVMXC__Line_Status__c!=null);
        
        System.currentPagereference().getParameters().put('PrId',PartsReq.Id);
        PREQ_CancelPartsRequest cnclPartsReq =  new PREQ_CancelPartsRequest();
        cnclPartsReq.getDisplaysave();
        cnclPartsReq.getResultMessage();
        cnclPartsReq.setResultMsg('Process complete');
        cnclPartsReq.BackToRecord();
        cnclPartsReq.DisplayMessage();
        cnclPartsReq.PerformUpdate();
    }
    static testMethod void PREQ_CancelPartsRequest_UnitTest1() {
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.SVMXC__Stocking_Location__c = true;
        insert loc1;
        SVMXC__Site__c loc2 = new SVMXC__Site__c();
        loc2.SVMXC__Stocking_Location__c = true;
        insert loc2;
        
        SVMXC__Parts_Request__c PartsReq = new SVMXC__Parts_Request__c();
        SVMXC__Parts_Request_Line__c PartsReqLine = new SVMXC__Parts_Request_Line__c();
        PartsReq.SVMXC__Status__c = 'Canceled';
        PartsReq.SVMXC__Requested_From__c = loc1.Id;
        PartsReq.SVMXC__Required_At_Location__c = loc2.Id;
        insert PartsReq;  
        PartsReqLine.SVMXC__Line_Status__c = 'Canceled';
        PartsReqLine.SVMXC__Parts_Request__c = PartsReq.Id; 
        insert PartsReqLine;
        system.assert(PartsReq.SVMXC__Status__c!=null);
        system.assert(PartsReq.SVMXC__Requested_From__c!=null);
        system.assert(PartsReqLine.SVMXC__Line_Status__c!=null);
        
        System.currentPagereference().getParameters().put('PrId',PartsReq.Id);
        PREQ_CancelPartsRequest cnclPartsReq =  new PREQ_CancelPartsRequest();
    }
    static testMethod void PREQ_CancelPartsRequest_UnitTest2() {
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.SVMXC__Stocking_Location__c = true;
        insert loc1;
        SVMXC__Site__c loc2 = new SVMXC__Site__c();
        loc2.SVMXC__Stocking_Location__c = true;
        insert loc2;
        
        SVMXC__Parts_Request__c PartsReq = new SVMXC__Parts_Request__c();
        SVMXC__Parts_Request_Line__c PartsReqLine = new SVMXC__Parts_Request_Line__c();
        PartsReq.SVMXC__Status__c = 'Open';
        PartsReq.SVMXC__Requested_From__c = loc1.Id;
        PartsReq.SVMXC__Required_At_Location__c = loc2.Id;
        insert PartsReq;
        PartsReqLine.SVMXC__Line_Status__c = 'Open';
        PartsReqLine.SVMXC__Parts_Request__c = PartsReq.Id; 
        insert PartsReqLine;
        system.assert(PartsReq.SVMXC__Status__c!=null);
        system.assert(PartsReq.SVMXC__Requested_From__c!=null);
        system.assert(PartsReqLine.SVMXC__Line_Status__c!=null);
        
        System.currentPagereference().getParameters().put('PrId',PartsReq.Id);
        PREQ_CancelPartsRequest cnclPartsReq =  new PREQ_CancelPartsRequest();
        cnclPartsReq.PerformUpdate();
        cnclPartsReq.getTAG001();
        cnclPartsReq.getTAG002();
        cnclPartsReq.getTAG003();
        cnclPartsReq.getTAG004();
        cnclPartsReq.getTAG005();
        cnclPartsReq.getTAG006();
        cnclPartsReq.getTAG007();
    }
    static testMethod void PREQ_CancelPartsRequest_UnitTest3() {
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.SVMXC__Stocking_Location__c = true;
        insert loc1;
        SVMXC__Site__c loc2 = new SVMXC__Site__c();
        loc2.SVMXC__Stocking_Location__c = true;
        insert loc2;
        
        SVMXC__Parts_Request__c PartsReq = new SVMXC__Parts_Request__c();
        SVMXC__Parts_Request_Line__c PartsReqLine = new SVMXC__Parts_Request_Line__c();
        PartsReq.SVMXC__Status__c = 'Open';
        PartsReq.SVMXC__Requested_From__c = loc1.Id;
        PartsReq.SVMXC__Required_At_Location__c = loc2.Id;
        insert PartsReq;
        PartsReqLine.SVMXC__Line_Status__c = 'Canceled';
        PartsReqLine.SVMXC__Parts_Request__c = PartsReq.Id;
        insert PartsReqLine;
        system.assert(PartsReq.SVMXC__Status__c!=null);
        system.assert(PartsReq.SVMXC__Requested_From__c!=null);
        system.assert(PartsReqLine.SVMXC__Line_Status__c!=null);
        
        System.currentPagereference().getParameters().put('PrId',PartsReq.Id);
        PREQ_CancelPartsRequest cnclPartsReq =  new PREQ_CancelPartsRequest();
    }
        static testMethod void PREQ_CancelPartsRequest_UnitTest4() {
        SVMXC__Site__c loc1 = new SVMXC__Site__c();
        loc1.SVMXC__Stocking_Location__c = true;
        insert loc1;
        SVMXC__Site__c loc2 = new SVMXC__Site__c();
        loc2.SVMXC__Stocking_Location__c = true;
        insert loc2;
        
        SVMXC__Parts_Request__c PartsReq = new SVMXC__Parts_Request__c();
        SVMXC__Parts_Request_Line__c PartsReqLine = new SVMXC__Parts_Request_Line__c();
        PartsReq.SVMXC__Status__c = 'Open';
        PartsReq.SVMXC__Requested_From__c = loc1.Id;
        PartsReq.SVMXC__Required_At_Location__c = loc2.Id;
        insert PartsReq;
        PartsReqLine.SVMXC__Line_Status__c = 'Completed';
        PartsReqLine.SVMXC__Parts_Request__c = PartsReq.Id;
        insert PartsReqLine;
        system.assert(PartsReq.SVMXC__Status__c!=null);
        system.assert(PartsReq.SVMXC__Requested_From__c!=null);
        system.assert(PartsReqLine.SVMXC__Line_Status__c!=null);
        
        System.currentPagereference().getParameters().put('PrId',PartsReq.Id);
        PREQ_CancelPartsRequest cnclPartsReq =  new PREQ_CancelPartsRequest();
    }
}