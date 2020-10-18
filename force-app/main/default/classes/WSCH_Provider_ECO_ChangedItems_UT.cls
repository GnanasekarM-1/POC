@isTest(seeAllData = false)
public with sharing class WSCH_Provider_ECO_ChangedItems_UT {
    
    static testMethod void testEcoChangedItems() {
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Order_Status__c='Open';
        wo.SVMXC__City__c='Austin';
        wo.SVMXC__State__c='CA';
        wo.SVMXC__Zip__c='75001';
        insert wo;
        
        //String jsonStr='{"workItems":[{"id":"'+wo.Name+'", "booking":{"start":"21-07-2014 09:00", "arr":"21-07-2014 09:00", "end":"21-07-2014 17:00", "tech":"T004"}, "task":{"action":"NOTIFIED", "tied":"true"}, "atRisk":{"type":"Allocation Issue", "offset":"20"}}]}';
        //{"state":"ON_TENTATIVE","errorcode":"[No error!]","workItems":[{"id":"WO-00015361","type":"JOB","booking":{"start":"2016-12-04 07:08","end_x":"2016-12-06 18:58","arr":"2016-12-06 17:58","tech":""}}],"changeTime":"2016-11-30 06:58","requested":false}
        
        String jsonStr = '{"state":"ON_TENTATIVE","errorcode":"[No error!]","workItems":[{"id":"'+ wo.Name +'","type":"JOB","booking":{"start":"2016-12-04 07:08","end_x":"2016-12-06 18:58","arr":"2016-12-06 17:58","tech":""}}],"changeTime":"2016-11-30 06:58","requested":false}';
        
        WSCH_Provider_ECO_ChangedItems.doProcessRestRequest(jsonStr);
        
         String jsonStr1 = '{"state":"ON_TENTATIVE","errorcode":"[No error!]","workItems":[],"changeTime":"","requested":false}';
         WSCH_Provider_ECO_ChangedItems.doProcessRestRequest(jsonStr1);
         
          String jsonStr2 = '{"state":"ON_TENTATIVE","errorcode":"[No error!]","workItems":[],"changeTime":","requested":false}';
         WSCH_Provider_ECO_ChangedItems.doProcessRestRequest(jsonStr2);
         
         String jsonStr3 = '{"state":"ON_TENTATIVE","errorcode":"[No error!]","workItems":[{"id":"'+ wo.Name +'","type":"JOB","booking":{"start":"2016-12-04 07:08","end_x":"2016-12-06 18:58","arr":"2016-12-06 17:58","tech":""}}],"changeTime":"2016-11-30 06:58","requested":false}';
         
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/scheduling/eco/changeditems';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonStr3);
        RestContext.request = req;
        WSCH_Provider_ECO_ChangedItems.doPost();
    }

    static testMethod void testNoneOptimizablePush() {
        
        SVMXC__Territory__c territory1 = WSCH_LTP_StageService_Handler_UT.createTerritory('RealTime Territory2');
        SVMXC__ServiceMax_Processes__c prcessObjone1 = WSCH_LTP_StageService_Handler_UT.createDP(territory1,'Real Time Optimization');
        SVMXC__SVMX_Jobs__c svmxJob1 = WSCH_LTP_StageService_Handler_UT.createSVMXJob(prcessObjone1.Id,territory1.Id,'Running','RTO');        
        SVMXC__Service_Group_Members__c sfTech1 = WSCH_LTP_StageService_Handler_UT.createSFTech(territory1);
        SVMXC__Service_Group_Members__c svmxTech1 = WSCH_LTP_StageService_Handler_UT.createSVMXTech(territory1);
        String sfTechId1 = sfTech1.Id+'_'+sfTech1.Name;
        String svmxTechId1 = svmxTech1.Id+'_'+svmxTech1.Name;
        Event sfEvent = WSCH_LTP_StageService_Handler_UT.createSFEvent(sfTech1.Id);
        SVMXC__SVMX_Event__c svmxEvent =WSCH_LTP_StageService_Handler_UT.createSVMXEvent(svmxTech1.Id);
        String techEventId = 'Event_'+sfEvent.Id+'_'+sfTech1.Id;
        String techEventId1 = 'Event_'+svmxEvent.Id+'_'+svmxTech1.Id;

        String jsonStr = '{"state": "NON_OPTIMIZABLE","errorcode": null, "workItems": [{"id": "'+techEventId+'","type": "ACTIVITY","booking": null,"errorMsg": "Element is UnReachable. Complete route has been marked as non optimizable.","ignored": false,"resolvedLatitude": 0.0,"resolvedLongitude": 0.0}],"changeTime": "2020-04-02 09:17","jobId": "DP2_Territory2","dispatched": false}';
        WSCH_Provider_ECO_ChangedItems.doProcessRestRequest(jsonStr);        

        String jsonStr1 = '{"state": "NON_OPTIMIZABLE","errorcode": null, "workItems": [{"id": "'+techEventId1+'","type": "ACTIVITY","booking": null,"errorMsg": "Element is UnReachable. Complete route has been marked as non optimizable.","ignored": false,"resolvedLatitude": 0.0,"resolvedLongitude": 0.0}],"changeTime": "2020-04-02 09:17","jobId": "DP2_Territory2","dispatched": false}';
        WSCH_Provider_ECO_ChangedItems.doProcessRestRequest(jsonStr1);        

    }
}