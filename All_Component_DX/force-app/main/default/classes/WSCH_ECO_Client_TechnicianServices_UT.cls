@isTest
private class WSCH_ECO_Client_TechnicianServices_UT {

    static testMethod void ECO_Client_TechnicianServices_UT1() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        insert team;
        
        SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'Tech1';
        technician1.SVMXC__Service_Group__c = team.Id;
        insert technician1;
        
        
        SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
        optimizer.SVMXC__WhatType__c = 'TECHNICIAN';
        optimizer.SVMXC__WhatId__c = technician1.Id + '_' + technician1.Name;
        optimizer.SVMXC__Optimizer_Connection_ID__c = prcessObjone.id + '_' + territory.id;
        optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
        optimizer.SVMXC__Optimizer_Status__c = 'OPT_COMPLETED';
        optimizer.SVMXC__Optimizer_Error_Text__c = 'Technician added through initJob call';
        insert optimizer;
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/technician';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '"}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        String response = WSCH_ECO_Client_TechnicianServices.doPost();
        Test.stopTest();
        //System.assertEquals('Empty or Invalid operation type', response);
    }
    
    static testMethod void ECO_Client_TechnicianServices_UT2() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        insert team;
        
        SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'Tech1';
        technician1.SVMXC__Service_Group__c = team.Id;
        insert technician1;
        
        
        SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
        optimizer.SVMXC__WhatType__c = 'TECHNICIAN';
        optimizer.SVMXC__WhatId__c = technician1.Id + '_' + technician1.Name;
        optimizer.SVMXC__Optimizer_Connection_ID__c = prcessObjone.id + '_' + territory.id;
        optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
        optimizer.SVMXC__Optimizer_Status__c = 'OPT_COMPLETED';
        optimizer.SVMXC__Optimizer_Error_Text__c = 'Technician added through initJob call';
        insert optimizer;
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/technician';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","operation":"HORIZON_UPDATE"}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        String response = WSCH_ECO_Client_TechnicianServices.doPost();
        Test.stopTest();
        //System.assertEquals('Technician Horizon Updated', response);
    }

    private static SVMXC__Territory__c createTerritory() {
        list<SVMXC__Territory__c> Territorylst = new List<SVMXC__Territory__c>();
        BusinessHours bh = [Select Id from BusinessHours where IsDefault=true];
        SVMXC__Territory__c Territory1 = new SVMXC__Territory__c();
        Territory1.name = 'ECO_Client_TechnicianServices_T1';
        Territory1.SVMXC__Territory_s_Business_Hours__c = bh.id;
        Territorylst.add(Territory1);
        insert Territorylst;
        
        return Territorylst[0];
    }
    
    private static SVMXC__ServiceMax_Processes__c createDP(SVMXC__Territory__c territory) {
        List<RecordType> RecType = new  List<RecordType>();
        string DispatchRTypeId;
        RecType = Database.Query('Select r.SystemModstamp, r.SobjectType, r.NamespacePrefix, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsActive, r.Id, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById, r.BusinessProcessId From RecordType r where SobjectType = \'SVMXC__ServiceMax_Processes__c\'');
        for(RecordType Rt : RecType)
        {
            if(Rt.Name == 'Dispatch Process')
            {
                DispatchRTypeId  = Rt.id;
            }
        }
        SVMXC__ServiceMax_Processes__c prcessObjone = new SVMXC__ServiceMax_Processes__c();
        prcessObjone.RecordTypeId = DispatchRTypeId;
        prcessObjone.SVMXC__Name__c = 'Test one';
        prcessObjone.SVMXC__Dispatch_Method__c = 'Real Time Optimization';
        prcessObjone.SVMXC__Email_On_Error__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Email_On_Success__c = 'test@servicemax.com';
        prcessObjone.SVMXC__Weight_Time_Window__c = 1;
        prcessObjone.SVMXC__Weight_Total_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Distance__c = 1;
        prcessObjone.SVMXC__Weight_Route_Time__c = 1;
        prcessObjone.SVMXC__Weight_Node_Type__c = 1;
        prcessObjone.SVMXC__Values__c = territory.id + ':U,';
        prcessObjone.SVMXC__Route_Type__c = 'CLOSED';
        prcessObjone.SVMXC__Dispatch_Threshold__c = 30;
        prcessObjone.SVMXC__Optimizer_Sync_Interval__c = 30;
        prcessObjone.SVMXC__Calendar_End_Days__c = 5;
        insert prcessObjone;
        
        return prcessObjone;
    }
    
    static testMethod void ECO_Client_TechnicianServices_UT3() {
        List<String> lstStrings = new List<String>();
        lstStrings.add('1234');
        WSCH_ECO_Client_TechnicianServices.scheduleEventsInHorizon(lstStrings);
        WSCH_ECO_Client_TechnicianServices.scheduleWOsInHorizon(lstStrings);
        
        WSCH_ECO_Client_TechnicianServices.scheduleEventsInHorizon(null);
        WSCH_ECO_Client_TechnicianServices.scheduleWOsInHorizon(null);
    }
    
    static testMethod void manageWOsInHorizon() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        insert team;
        
        SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'Tech1';
        technician1.SVMXC__Service_Group__c = team.Id;
        insert technician1;
        
        
        SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
        optimizer.SVMXC__WhatType__c = 'TECHNICIAN';
        optimizer.SVMXC__WhatId__c = technician1.Id + '_' + technician1.Name;
        optimizer.SVMXC__Optimizer_Connection_ID__c = prcessObjone.id + '_' + territory.id;
        optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
        optimizer.SVMXC__Optimizer_Status__c = 'OPT_COMPLETED';
        optimizer.SVMXC__Optimizer_Error_Text__c = 'Technician added through initJob call';
        insert optimizer;
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/technician';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","operation":"WO_UPDATE"}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        String response = WSCH_ECO_Client_TechnicianServices.doPost();
        Test.stopTest();
    }
    
    static testMethod void manageNonWOEventsInHorizon() {
        SVMXC__Territory__c territory = createTerritory();
        SVMXC__ServiceMax_Processes__c prcessObjone = createDP(territory);
        
        SVMXC__Service_Group__c team = new SVMXC__Service_Group__c();
        team.Name = 'team1';
        insert team;
        
        SVMXC__Service_Group_Members__c technician1 = new SVMXC__Service_Group_Members__c();
        technician1.Name = 'Tech1';
        technician1.SVMXC__Service_Group__c = team.Id;
        insert technician1;
        
        
        SVMXC__SVMX_Optimizer__c optimizer = new SVMXC__SVMX_Optimizer__c();
        optimizer.SVMXC__WhatType__c = 'TECHNICIAN';
        optimizer.SVMXC__WhatId__c = technician1.Id + '_' + technician1.Name;
        optimizer.SVMXC__Optimizer_Connection_ID__c = prcessObjone.id + '_' + territory.id;
        optimizer.SVMXC__Optimizer_Change_Token__c = 'CHANGE_CREATE_TECH';
        optimizer.SVMXC__Optimizer_Status__c = 'OPT_COMPLETED';
        optimizer.SVMXC__Optimizer_Error_Text__c = 'Technician added through initJob call';
        insert optimizer;
        
        RestRequest req = new RestRequest();
        
        req.requestURI = '/services/apexrest/scheduling/eco/technician';
        String reqBody = '{"dispatchProcessGuid":"' + prcessObjone.id + '","territoryGuid":"' + territory.id + '","operation":"NON_WO_EVENT_UPDATE"}';
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        Test.startTest();
        String response = WSCH_ECO_Client_TechnicianServices.doPost();
        WSCH_ECO_Client_TechnicianServices.createOptimizerObject('id', 'CHANGE_CREATE_TECH','TECHNICIAN',prcessObjone.Id,territory.Id,technician1);
        Test.stopTest();
    }
    
    /*static testMethod void ECO_Client_TechnicianServices_UT4() {                
        List<String> woNames = new List<String>();
        woNames.add('WO-1221122');
        String strOrgIdDPIdTerritoryId = 'OrgId-DPId-TerritoryId';
        WSCH_ECO_Client_TechnicianServices.doPrepareWorkOrderWP(woNames,strOrgIdDPIdTerritoryId);
        
        List<String> techIds = new List<String>();
        techIds.add('techId');
        WSCH_ECO_Client_TechnicianServices.doPrepareTechnicianWP(techIds, strOrgIdDPIdTerritoryId, 'resourceUpdate');
        WSCH_ECO_Client_TechnicianServices.doPrepareTechnicianWP(techIds, strOrgIdDPIdTerritoryId, 'resource');   
        
        WSCH_ECO_Client_TechnicianServices.doPrepareTechnicianEventWP(techIds, strOrgIdDPIdTerritoryId);    
        WSCH_ECO_Client_TechnicianServices.doPrepareSkippedEventWP(techIds, strOrgIdDPIdTerritoryId);   
        
        WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP techHorizonUpdateReqObj1 = new WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP();
        techHorizonUpdateReqObj1.dispatchProcessGuid = 'DP1';
        techHorizonUpdateReqObj1.territoryGuid = 'Territory1';
        techHorizonUpdateReqObj1.operation = 'RESUME_IDS';
        
        WSCH_ECO_Client_TechnicianServices.doPrepareResumeIds(techHorizonUpdateReqObj1);
                            
    }*/

    static testMethod void rtoBatchedTestCases() {  
        Test.startTest();              
        SVMXC__Territory__c territory1 = WSCH_LTP_StageService_Handler_UT.createTerritory('RealTime Territory2');
        SVMXC__ServiceMax_Processes__c prcessObjone1 = WSCH_LTP_StageService_Handler_UT.createDP(territory1,'Real Time Optimization');
        SVMXC__SVMX_Jobs__c svmxJob1 = WSCH_LTP_StageService_Handler_UT.createSVMXJob(prcessObjone1.Id,territory1.Id,'Running','RTO');        
        SVMXC__Service_Group_Members__c sfTech1 = WSCH_LTP_StageService_Handler_UT.createSFTech(territory1);
        SVMXC__Service_Group_Members__c svmxTech1 = WSCH_LTP_StageService_Handler_UT.createSVMXTech(territory1);
        String sfTechId1 = sfTech1.Id+'_'+sfTech1.Name;
        String svmxTechId1 = svmxTech1.Id+'_'+svmxTech1.Name;
        Event sfEvent = WSCH_LTP_StageService_Handler_UT.createSFEvent(sfTech1.Id);
        SVMXC__SVMX_Event__c svmxEvent =WSCH_LTP_StageService_Handler_UT.createSVMXEvent(svmxTech1.Id);
        String techEventId = 'Event_'+sfEvent.Id+'_'+sfTech1.Name;
        String techEventId1 = 'Event_'+svmxEvent.Id+'_'+svmxTech1.Name;
        List<SVMXC__Service_Order__c> lstWOs = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c wo = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,Datetime.now()+10,Datetime.now()+20,false);
        SVMXC__Service_Order__c wo1 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,Datetime.now()-10,Datetime.now()+1,false);
        SVMXC__Service_Order__c wo2 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,Datetime.now()+400,Datetime.now()+10,false);
        SVMXC__Service_Order__c wo3 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,null,Datetime.now()+30,true);
        SVMXC__Service_Order__c wo4 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,Datetime.now()+5,null,false);
        SVMXC__Service_Order__c wo5 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,null,null,true);

   
        List<String> woIds = new List<String>();
        woIds.add(wo.Id);
        woIds.add(wo1.Id);
        woIds.add(wo2.Id);
        woIds.add(wo3.Id);
        woIds.add(wo4.Id);
        woIds.add(wo5.Id);      
        lstWOs = WSCH_ECO_CommonUtils.fetchWorkOrders(woIds);

        //initiate - workOrder / skipped WO
        String strJobInstanceGuid = '00DF00000007BzN-'+prcessObjone1.id+'-'+territory1.id;
        String initWOjson = '{"jobInstanceGuid":"'+strJobInstanceGuid+'","ids":["'+lstWOs[0]+'","'+lstWOs[1]+'","'+lstWOs[2]+'","'+lstWOs[3]+'","'+lstWOs[4]+'"}';
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/scheduling/eco/technician/workOrder';
        String reqBody = initWOjson;
        req.requestBody = Blob.valueOf(reqBody);
        req.httpMethod = 'POST';
        RestContext.request = req;

        WSCH_ECO_Client_TechnicianServices.doPrepareWorkOrderWP(woIds, strJobInstanceGuid);
        String response = WSCH_ECO_Client_TechnicianServices.doPost();

        // RestRequest req1 = new RestRequest();
        // req1.requestURI = '/services/apexrest/scheduling/eco/technician/skippedWorkOrder';
        // String reqBody1 = initWOjson;
        // req1.requestBody = Blob.valueOf(reqBody1);
        // req1.httpMethod = 'POST';
        // RestContext.request = req1;
        
        // String response1 = WSCH_ECO_Client_TechnicianServices.doPost();

        //initiate - resource/event/resource update
        String initTechjson = '{"jobInstanceGuid":"'+strJobInstanceGuid+'","ids":["'+sfTechId1+'","'+svmxTechId1+'"}';
        List<String> techIds = new List<String>();
        techIds.add(sfTechId1);
        techIds.add(svmxTechId1);
        RestRequest req2 = new RestRequest();
        req2.requestURI = '/services/apexrest/scheduling/eco/technician/resource';
        String reqBody2 = initTechjson;
        req2.requestBody = Blob.valueOf(reqBody2);
        req2.httpMethod = 'POST';
        RestContext.request = req2;

        WSCH_ECO_Client_TechnicianServices.doPrepareTechnicianWP(techIds, strJobInstanceGuid, 'resourceUpdate');
        WSCH_ECO_Client_TechnicianServices.doPrepareTechnicianWP(techIds, strJobInstanceGuid, 'resource'); 
        WSCH_ECO_Client_TechnicianServices.doPrepareTechnicianEventWP(techIds, strJobInstanceGuid);    
  
        String response2 = WSCH_ECO_Client_TechnicianServices.doPost();

        RestRequest req3 = new RestRequest();
        req3.requestURI = '/services/apexrest/scheduling/eco/technician/resourceUpdate';
        String reqBody3 = initTechjson;
        req3.requestBody = Blob.valueOf(reqBody3);
        req3.httpMethod = 'POST';
        RestContext.request = req3;

        String response3 = WSCH_ECO_Client_TechnicianServices.doPost();

        //Resume - skipped event
        String resumeEventjson = '{"jobInstanceGuid":"'+strJobInstanceGuid+'","ids":["'+techEventId+'","'+techEventId1+'"}';        
        List<String> techEventIds = new List<String>();
        techEventIds.add(techEventId);
        techEventIds.add(techEventId1);
  
        RestRequest req4 = new RestRequest();
        req4.requestURI = '/services/apexrest/scheduling/eco/technician/skippedEvent';
        String reqBody4 = resumeEventjson;
        req4.requestBody = Blob.valueOf(reqBody4);
        req4.httpMethod = 'POST';
        RestContext.request = req4;

        WSCH_ECO_Client_TechnicianServices.doPrepareSkippedEventWP(techEventIds, strJobInstanceGuid);    
        String response4 = WSCH_ECO_Client_TechnicianServices.doPost();
        
        Test.stopTest();
    }  
    
    static testMethod void resumeIDStest() {          
        Test.startTest();
        SVMXC__Territory__c territory1 = WSCH_LTP_StageService_Handler_UT.createTerritory('RealTime Territory2');
        SVMXC__ServiceMax_Processes__c prcessObjone1 = WSCH_LTP_StageService_Handler_UT.createDP(territory1,'Real Time Optimization');
        SVMXC__SVMX_Jobs__c svmxJob1 = WSCH_LTP_StageService_Handler_UT.createSVMXJob(prcessObjone1.Id,territory1.Id,'Running','RTO');        
        SVMXC__Service_Group_Members__c sfTech1 = WSCH_LTP_StageService_Handler_UT.createSFTech(territory1);
        SVMXC__Service_Group_Members__c svmxTech1 = WSCH_LTP_StageService_Handler_UT.createSVMXTech(territory1);
        String sfTechId1 = sfTech1.Id+'_'+sfTech1.Name;
        String svmxTechId1 = svmxTech1.Id+'_'+svmxTech1.Name;
        Event sfEvent = WSCH_LTP_StageService_Handler_UT.createSFEvent(sfTech1.Id);
        SVMXC__SVMX_Event__c svmxEvent =WSCH_LTP_StageService_Handler_UT.createSVMXEvent(svmxTech1.Id);
        String techEventId = 'Event_'+sfEvent.Id+'_'+sfTech1.Name;
        String techEventId1 = 'Event_'+svmxEvent.Id+'_'+svmxTech1.Name;
        List<SVMXC__Service_Order__c> lstWOs = new list<SVMXC__Service_Order__c>();
        SVMXC__Service_Order__c wo = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,Datetime.now()+10,Datetime.now()+20,false);
        SVMXC__Service_Order__c wo1 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,Datetime.now()-10,Datetime.now()+1,false);
        SVMXC__Service_Order__c wo2 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,Datetime.now()+400,Datetime.now()+10,false);
        SVMXC__Service_Order__c wo3 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,null,Datetime.now()+30,true);
        SVMXC__Service_Order__c wo4 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,Datetime.now()+5,null,false);
        SVMXC__Service_Order__c wo5 = WSCH_LTP_StageService_Handler_UT.createWorkOrder(prcessObjone1.Id,territory1.Id,null,null,true);
        
        
        List<String> woIds = new List<String>();
        woIds.add(wo.Id);
        woIds.add(wo1.Id);
        woIds.add(wo2.Id);
        woIds.add(wo3.Id);
        woIds.add(wo4.Id);
        woIds.add(wo5.Id);      
    
        //Resume - ResumeID operation
        String resumeId = '{"territoryGuid":"'+territory1.id+'","dispatchProcessGuid":"'+prcessObjone1.id+'","operation":"RESUME_IDS"}';

        RestRequest req5 = new RestRequest();
        req5.requestURI = '/services/apexrest/scheduling/eco/technician';
        String reqBody5 = resumeId;
        req5.requestBody = Blob.valueOf(reqBody5);
        req5.httpMethod = 'POST';
        RestContext.request = req5;
        WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP techHorizonUpdateReqObj1 = new WSCH_ECO_Client_Stubs.TechnicianHorizonUpdateRequest_WP();
        techHorizonUpdateReqObj1.dispatchProcessGuid = prcessObjone1.id;
        techHorizonUpdateReqObj1.territoryGuid = territory1.id;
        techHorizonUpdateReqObj1.operation = 'RESUME_IDS';
        WSCH_ECO_Client_TechnicianServices.doPrepareResumeIds(techHorizonUpdateReqObj1);
        String response5 = WSCH_ECO_Client_TechnicianServices.doPost();        
        Test.stopTest();
        
    }

}